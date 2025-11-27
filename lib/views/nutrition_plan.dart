import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'nutrition_goal.dart';
import 'home.dart';

class NutritionPlanPage extends StatefulWidget {
  final String activityLevel;
  final String goal;

  const NutritionPlanPage({
    super.key,
    required this.activityLevel,
    required this.goal,
  });

  @override
  State<NutritionPlanPage> createState() => _NutritionPlanPageState();
}

class _NutritionPlanPageState extends State<NutritionPlanPage> {
  Map<String, dynamic>? mealPlan;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMealPlan();
  }

  //Load Meal Plan from AI Server
  Future<void> _loadMealPlan() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('authToken') ?? "";

      final uri = Uri.parse("http://10.0.2.2:5000/api/mealplan");
      final body = jsonEncode({
        "weight": 75,
        "bodyFat": 18,
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

  // Save Meal Plan to MongoDB
  Future<void> saveNutritionPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('userEmail') ?? "";
    final authToken = prefs.getString('authToken') ?? "";

    if (userEmail.isEmpty || mealPlan == null) return;

    final uri = Uri.parse("http://10.0.2.2:5000/api/user/$userEmail/nutrition");

    try {
      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $authToken",
        },
        body: jsonEncode(mealPlan),
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
        // Back button
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

        // Info Box
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
              const Text("Weight: 75 kg"),
              const Text("Height: 180 cm"),
              const Text("Body Fat: 18 %"),
            ],
          ),
        ),

        // Calories Box
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            "Your calories",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2A4F53),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Macros
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

        // Save Plan Button
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

        // Meal Cards
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

        // Home button
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

  Widget _buildMealCard({
    required String title,
    required List items,
  }) {
    final totalCalories =
        items.fold<int>(0, (sum, item) => sum + (item["calories"] as int));

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
          const SizedBox(height: 10),
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
