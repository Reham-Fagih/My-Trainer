from flask import Flask, request, jsonify
from tensorflow.keras.models import load_model
from tensorflow.keras.preprocessing import image
import numpy as np
import os

app = Flask(__name__)

MODEL_PATH = os.path.join(os.path.dirname(__file__), 'models', 'body_fat_model.keras')
model = load_model(MODEL_PATH)
print("✅ Body Fat model loaded")

def preprocess_img(img_path, target_size=(224, 224)):
    img = image.load_img(img_path, target_size=target_size)
    img_array = image.img_to_array(img)
    img_array = img_array / 255.0  
    img_array = np.expand_dims(img_array, axis=0)  
    return img_array

@app.route("/predict", methods=["POST"])
def predict():
    if 'image' not in request.files:
        return jsonify({"error": "No image file"}), 400

    img_file = request.files['image']
    temp_path = os.path.join("temp", img_file.filename)
    os.makedirs("temp", exist_ok=True)
    img_file.save(temp_path)

    try:
        img_array = preprocess_img(temp_path)
        bf_percent = float(model.predict(img_array)[0][0])
        print(f"[Python Server] Predicted BF%: {bf_percent:.2f}")
        os.remove(temp_path)  
        return jsonify({"bfPercent": round(bf_percent, 2)})
    except Exception as e:
        return jsonify({"error": str(e)}), 500
