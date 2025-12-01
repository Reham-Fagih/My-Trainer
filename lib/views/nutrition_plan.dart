import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/config.dart';
import 'nutrition_goal.dart';
import 'home.dart';
import '../widgets/app_footer.dart';

class NutritionPlanPage extends StatefulWidget {
  final String activityLevel;
  final String goal;
  final bool useExistingPlan; // when true, load latest saved plan

  const NutritionPlanPage({
    super.key,
    required this.activityLevel,
    required this.goal,
    this.useExistingPlan = false,
  });

  @override
  State<NutritionPlanPage> createState() => _NutritionPlanPageState();
}

class _NutritionPlanPageState extends State<NutritionPlanPage> {
  Map<String, dynamic>? mealPlan;
  bool isLoading = true;
  String? errorMessage;

  // User metrics coming from profile/backend
  double? userWeight;
  double? userHeight;
  double? userBodyFat;

  Map<String, bool> completedMeals = {};

  @override
  void initState() {
    super.initState();
    if (widget.useExistingPlan) {
      _loadExistingMealPlan();
    } else {
      _loadMealPlan();
    }
  }

  // LOAD LATEST SAVED MEAL PLAN FROM BACKEND
  Future<void> _loadExistingMealPlan() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('authToken') ?? "";

      if (authToken.isEmpty) {
        setState(() {
          errorMessage = "No user session found. Please log in again.";
          isLoading = false;
        });
        return;
      }

      final uri = Uri.parse("http://10.0.2.2:5000/api/mealplan/latest");

      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $authToken",
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final latest = decoded["latestPlan"] as Map<String, dynamic>?;

        if (latest == null) {
          setState(() {
            errorMessage = "No saved nutrition plan found.";
            isLoading = false;
          });
          return;
        }

        setState(() {
          mealPlan = latest;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              "Failed to load current nutrition plan: ${response.statusCode} ${response.body}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  // LOAD MEAL PLAN FROM AI SERVER
  Future<void> _loadMealPlan() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('authToken') ?? "";
      final userEmail = prefs.getString('userEmail');

      if (userEmail == null || userEmail.isEmpty) {
        setState(() {
          errorMessage = "Please log in again. User email not found.";
          isLoading = false;
        });
        return;
      }

      // Fetch latest profile data to get weight/height/bodyFat
      final userResponse = await http.get(
        Uri.parse("http://10.0.2.2:5000/api/user/$userEmail"),
        headers: {
          "Content-Type": "application/json",
          if (authToken.isNotEmpty) "Authorization": "Bearer $authToken",
        },
      );

      if (userResponse.statusCode != 200) {
        setState(() {
          errorMessage = "Failed to load profile information.";
          isLoading = false;
        });
        return;
      }

      final userData = jsonDecode(userResponse.body) as Map<String, dynamic>;

      final double? weight = (userData["weight"] != null)
          ? double.tryParse(userData["weight"].toString())
          : null;
      final double? height = (userData["height"] != null)
          ? double.tryParse(userData["height"].toString())
          : null;

      // Body fat from last prediction if available
      double? bodyFat;
      if (userData["predictions"] != null &&
          (userData["predictions"] as List).isNotEmpty) {
        final lastPred =
            (userData["predictions"] as List).last as Map<String, dynamic>;
        bodyFat = double.tryParse(lastPred["value"].toString());
      }

      // Guard: user must complete profile and have body fat prediction
      if (weight == null || height == null || bodyFat == null) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Please complete your profile (weight, height) and body fat scan before generating a meal plan.",
            ),
          ),
        );

        // Navigate user to profile page to complete missing data
        Future.microtask(() {
          Navigator.pushNamed(context, "/ProfilePage");
        });
        return;
      }

      // Store for display
      setState(() {
        userWeight = weight;
        userHeight = height;
        userBodyFat = bodyFat;
      });

      final uri = Uri.parse("http://10.0.2.2:5000/api/mealplan");
      final body = jsonEncode({
        "weight": weight,
        "bodyFat": bodyFat,
        // TODO: replace with real gender field if available on user
        "gender": "male",
        "activityLevel": widget.activityLevel,
        "goal": widget.goal,
      });

      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      if (authToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $authToken';
      }

      final response = await http
          .post(uri, headers: headers, body: body)
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final plan = decoded is Map<String, dynamic>
            ? decoded["nutritionPlan"] as Map<String, dynamic>?
            : null;

        setState(() {
          mealPlan = plan ?? decoded as Map<String, dynamic>;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Failed: ${response.statusCode} ${response.body}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _addPointsForMeal(String mealName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("userId") ?? "";

      if (userId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("User not found. Please log in again."),
          ),
        );
        return;
      }

      final uri = Uri.parse("$baseUrl/api/user/$userId/points");

      final response = await http.post(
        uri,
        headers: const {"Content-Type": "application/json"},
        body: jsonEncode({"points": 4}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$mealName completed! +4 points added")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text("Failed to add points for $mealName: ${response.body}"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding points: $e")),
      );
    }
  }

  // SAVE MEAL PLAN
  Future<void> saveNutritionPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('userEmail') ?? "";
    final authToken = prefs.getString('authToken') ?? "";

    if (userEmail.isEmpty || mealPlan == null) return;

    final uri = Uri.parse("http://10.0.2.2:5000/api/user/$userEmail/nutrition");

    try {
      // Build payload including required metadata for schema
      final body = {
        "activityLevel": widget.activityLevel,
        "goal": widget.goal,
        "weight": userWeight,
        "bodyFat": userBodyFat,
        // TODO: replace with real gender from profile if available
        "gender": "male",
        "calories": mealPlan!["calories"],
        "macros": mealPlan!["macros"],
        "mealPlans": mealPlan!["mealPlans"],
      };

      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $authToken",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Nutrition plan saved successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save plan: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppFooter(),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bgNutrition.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
                  ? Center(child: Text("Error: $errorMessage"))
                  : _buildContent(context, mealPlan),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Map<String, dynamic>? plan) {
    final calories = plan?["calories"];
    final macros = plan?["macros"] as Map<String, dynamic>?;
    final meals = plan?["mealPlans"] as List<dynamic>?;

    final protein = macros != null ? macros["protein"] : null;
    final fats = macros != null ? macros["fats"] : null;
    final carbs = macros != null ? macros["carbohydrates"] : null;

    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      NutritionGoalPage(activityLevel: widget.activityLevel),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        // INFO BOX
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 5,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Activity Level: ${widget.activityLevel}",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              Text("Goal: ${widget.goal}",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(
                  "Weight: ${userWeight != null ? userWeight!.toStringAsFixed(1) : 'N/A'} kg"),
              Text(
                  "Height: ${userHeight != null ? userHeight!.toStringAsFixed(1) : 'N/A'} cm"),
              Text(
                  "Body Fat: ${userBodyFat != null ? userBodyFat!.toStringAsFixed(1) : 'N/A'} %"),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            _buildMacroBox(
              calories != null ? "$calories Cal" : "Cal: N/A",
            ),
            _buildMacroBox(
              protein != null ? "$protein g P" : "P: N/A",
            ),
            _buildMacroBox(
              fats != null ? "$fats g F" : "F: N/A",
            ),
            _buildMacroBox(
              carbs != null ? "$carbs g C" : "C: N/A",
            ),
          ],
        ),

        const SizedBox(height: 20),

        // SAVE PLAN BUTTON
        Center(
          child: ElevatedButton(
            onPressed: saveNutritionPlan,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF04383D),
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
            ),
            child: const Text(
              "Save Plan",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // MEALS LIST WITH CHECKBOXES
        Expanded(
          child: meals == null || meals.isEmpty
              ? const Center(
                  child: Text(
                    "No meal plan data available.",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: meals.map<Widget>((meal) {
                    final mealMap = meal as Map<String, dynamic>;
                    final title = mealMap["meal"] ?? "Meal";
                    final items =
                        (mealMap["items"] as List<dynamic>? ?? <dynamic>[]);

                    return _buildMealCard(
                      title: title,
                      items: items,
                    );
                  }).toList(),
                ),
        ),

        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: IconButton(
            icon: const Icon(Icons.home, size: 32, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMacroBox(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF05262F),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }

  // MEAL CARD WITH CHECKBOX
  Widget _buildMealCard({
    required String title,
    required List items,
  }) {
    final totalCalories =
        items.fold<int>(0, (sum, item) => sum + (item["calories"] as int));

    // Initialize checkbox state if first time
    completedMeals.putIfAbsent(title, () => false);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // TITLE + CALORIES
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A4F53),
                    ),
                  ),
                  Text(
                    "$totalCalories kcal",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF05262F),
                    ),
                  ),
                ],
              ),

              // CHECKBOX
              Checkbox(
                value: completedMeals[title],
                activeColor: const Color(0xFF04383D),
                onChanged: (value) async {
                  setState(() {
                    completedMeals[title] = value ?? false;
                  });

                  if (value == true) {
                    await _addPointsForMeal(title);
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 10),

          // MEAL ITEMS
          Column(
            children: items.map<Widget>((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item["food"],
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                    Text(
                      "${item["calories"]} Cal | "
                      "P:${item["protein"]}g "
                      "C:${item["carbohydrates"]}g "
                      "F:${item["fat"]}g",
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
