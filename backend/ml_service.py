from flask import Flask, request, jsonify
from tensorflow.keras.models import load_model
from tensorflow.keras.preprocessing import image
import numpy as np
import os
from PIL import Image, UnidentifiedImageError
import cv2
import numpy as np


app = Flask(__name__)

MODEL_PATH = os.path.join(os.path.dirname(__file__), 'models', 'body_fat_model.keras')
model = load_model(MODEL_PATH)
print("✅ Body Fat model loaded")

# Person detector (option B) – MobileNetSSD on COCO 'person' class
# Uses files in backend/models that you just downloaded:
#   - MobileNetSSD_deploy.prototxt
#   - MobileNetSSD_deploy.caffemodel
PERSON_MODEL_PROTO = os.path.join(os.path.dirname(__file__), 'models', 'MobileNetSSD_deploy.prototxt')
PERSON_MODEL_WEIGHTS = os.path.join(os.path.dirname(__file__), 'models', 'MobileNetSSD_deploy.caffemodel')

person_net = None
person_class_id = 15  # COCO / MobileNetSSD 'person' class index


def load_person_detector():
    """Lazy-load the MobileNetSSD person detector if model files are present."""
    global person_net
    if person_net is not None:
        return

    if not (os.path.exists(PERSON_MODEL_PROTO) and os.path.exists(PERSON_MODEL_WEIGHTS)):
        print("⚠️ Person detector model files not found. Person validation will be skipped.")
        return

    person_net = cv2.dnn.readNetFromCaffe(PERSON_MODEL_PROTO, PERSON_MODEL_WEIGHTS)
    print("✅ Person detector model loaded (MobileNetSSD).")

def preprocess_img(img_path, target_size=(224, 224)):
    """Load and normalize image for model input."""
    img = image.load_img(img_path, target_size=target_size)
    img_array = image.img_to_array(img)
    img_array = img_array / 255.0
    img_array = np.expand_dims(img_array, axis=0)
    return img_array


def validate_basic_image(path, min_width=256, min_height=256):
    """Basic image sanity checks: file is real image and not too small."""
    try:
      with Image.open(path) as img:
          width, height = img.size
          if width < min_width or height < min_height:
              return False, f"Image is too small ({width}x{height}). Please upload a clearer, larger image."
    except UnidentifiedImageError:
        return False, "Uploaded file is not a valid image."
    except Exception as e:
        return False, f"Error reading image: {e}"

    return True, None


def is_blurry(path, threshold: float = 15.0):
    """Return (is_blurry, focus_score) using variance of Laplacian.

    Lower threshold means we accept slightly softer images.
    """
    img = cv2.imread(path)
    if img is None:
        # Cannot decode image, treat as bad
        return True, 0.0

    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    fm = cv2.Laplacian(gray, cv2.CV_64F).var()
    return fm < threshold, float(fm)


def has_face(path):
    """Return True if at least one face is detected in the image.

    This is a lightweight sanity check that there's a real person in the frame.
    """
    img = cv2.imread(path)
    if img is None:
        return False

    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    face_cascade = cv2.CascadeClassifier(
        cv2.data.haarcascades + "haarcascade_frontalface_default.xml"
    )
    faces = face_cascade.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=3)
    return len(faces) > 0


def is_low_color_variance(path, threshold: float = 5.0):
    """Heuristic to catch obviously abnormal images (e.g., almost single-color).

    Very low overall standard deviation of pixel values suggests a mostly flat
    or synthetic image that is unlikely to be a real body photo.
    """
    img = cv2.imread(path)
    if img is None:
        return True

    std_dev = img.std()
    return std_dev < threshold


def has_skin_tone_like_region(path, min_fraction: float = 0.02):
    """Heuristic: check if there is a noticeable skin-tone-like region.

    This is *not* perfect, but combined with face detection it helps reject
    images that clearly do not contain any human skin (e.g., trees, objects).
    """
    img = cv2.imread(path)
    if img is None:
        return False

    # Convert to YCrCb color space where skin tones occupy a rough range
    ycrcb = cv2.cvtColor(img, cv2.COLOR_BGR2YCrCb)
    lower = np.array([0, 135, 85], dtype=np.uint8)
    upper = np.array([255, 180, 135], dtype=np.uint8)
    mask = cv2.inRange(ycrcb, lower, upper)

    skin_pixels = cv2.countNonZero(mask)
    total_pixels = img.shape[0] * img.shape[1]

    if total_pixels == 0:
        return False

    fraction = skin_pixels / float(total_pixels)
    return fraction >= min_fraction


def has_person(path, conf_threshold: float = 0.5):
    """Return True if a 'person' is detected using MobileNetSSD (option B).

    This uses OpenCV's DNN module to run a lightweight object detector.
    """
    global person_net
    if person_net is None:
        load_person_detector()
        if person_net is None:
            # Person detector not available; treat as no person detected
            print("[Validation] Person detector not available; skipping person check.")
            return False

    img = cv2.imread(path)
    if img is None:
        return False

    (h, w) = img.shape[:2]
    blob = cv2.dnn.blobFromImage(
        cv2.resize(img, (300, 300)),
        0.007843,  # scale factor
        (300, 300),
        127.5      # mean subtraction
    )
    person_net.setInput(blob)
    detections = person_net.forward()

    # Look for 'person' class with enough confidence
    for i in range(0, detections.shape[2]):
        confidence = detections[0, 0, i, 2]
        class_id = int(detections[0, 0, i, 1])
        if confidence >= conf_threshold and class_id == person_class_id:
            return True

    return False

@app.route("/predict", methods=["POST"])
def predict():
    if 'image' not in request.files:
        return jsonify({"error": "No image file"}), 400

    img_file = request.files['image']
    temp_path = os.path.join("temp", img_file.filename or "upload.jpg")
    os.makedirs("temp", exist_ok=True)
    img_file.save(temp_path)

    try:
        # 1) Basic validation (real image, reasonable size)
        ok, error = validate_basic_image(temp_path)
        if not ok:
            os.remove(temp_path)
            return jsonify({"error": error}), 400
        print(f"[Validation] Basic image check passed for {temp_path}")

        # 2) Blurriness check
        blurry, focus_score = is_blurry(temp_path)
        if blurry:
            print(f"[Validation] Blur check FAILED (focusScore={focus_score:.2f}) for {temp_path}")
            os.remove(temp_path)
            return jsonify({
                "error": "Image is too blurry. Please retake the photo.",
                "focusScore": focus_score,
            }), 400
        print(f"[Validation] Blur check passed (focusScore={focus_score:.2f}) for {temp_path}")

        # 3) Person detection (option B - main content gate)
        has_person_flag = has_person(temp_path)
        print(f"[Validation] has_person={has_person_flag} for {temp_path}")
        if not has_person_flag:
            os.remove(temp_path)
            return jsonify({
                "error": "No person detected in the image. Please upload a clear photo of your body.",
            }), 400

        # 4) Very low color variance heuristic (catch obviously abnormal images)
        if is_low_color_variance(temp_path):
            os.remove(temp_path)
            return jsonify({
                "error": "The image appears invalid or too uniform. Please upload a normal photo.",
            }), 400
        print(f"[Validation] Color variance check passed for {temp_path}")

        # 5) If checks pass, run model
        img_array = preprocess_img(temp_path)
        bf_percent = float(model.predict(img_array)[0][0])
        print(f"[Python Server] Predicted BF%: {bf_percent:.2f}")
        os.remove(temp_path)  
        return jsonify({"bfPercent": round(bf_percent, 2)})
    except Exception as e:
        # Log internal error details for debugging but return a friendly message to the client
        print(f"[Error] /predict failed: {e}")
        if os.path.exists(temp_path):
            os.remove(temp_path)
        return jsonify({
            "error": "We couldn't analyze your photo due to a server issue. Please try again in a moment or upload a different photo."
        }), 500
