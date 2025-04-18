import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:schedule_generator_with_gemini/network/gemini_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<Map<String, dynamic>> _tasks = [];
  Map<String, dynamic> weeklyMeal = {};
  TextEditingController _mealController = TextEditingController();
  // TextEditingController _durationController = TextEditingController();

  String? _priority;
  bool isLoading = false;
  String errorMessage = "";
  String? _mealTime;
  String? day;

  Map<String, dynamic> breakfast = {};
  Map<String, dynamic> lunch = {};
  Map<String, dynamic> dinner = {};
  // Map<String, dynamic> suggestions = {};

  Future<void> _loadMealGenerator() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedMealGenerator = prefs.getString('mealGenerator');
    setState(() {
        weeklyMeal = Map<String, dynamic>.from(jsonDecode(savedMealGenerator!));
    });
  }
  Future<void> _saveMealGenerator() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('mealGenerator', jsonEncode(weeklyMeal));
  }

  Future<void> _loadSavedMeal() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedMeal = prefs.getString('todayMealPlan');
    if(savedMeal != null){
      setState(() {
        _tasks = List<Map<String, dynamic>>.from(jsonDecode(savedMeal));
      });
    }
  }
  // Menyimpan makan
  Future<void> _saveMealPlan() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('todayMealPlan', jsonEncode(_tasks));
  }

  Future<void> _deleteMealPlan(int index) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _tasks.removeAt(index);
    });
    _saveMealPlan();
  }


  void _addTask() {
    if(_mealController.text.isNotEmpty && 
       _priority != null && _mealTime != null)  {
         print("Meal: \${_mealController.text}, MealTime: \$_mealTime, Priority: \$_priority");
        setState(() {
          _tasks.add({
          "task": _mealController.text,
          "mealTime": _mealTime ?? "",
          "priority": _priority ?? "",
          });
        });
        print('task added : ${_tasks}');
        print('MealTime dari task terakhir: ${_tasks.last['mealTime']}');
        _mealController.clear();
        _mealTime = null;
        _priority = null;

         _saveMealPlan();
       }
  }
  Future<void> _generateMeal() async {
    setState(() {
      isLoading = true;
    });
    try{
      final result = await GeminiService.generateMeal(_tasks);

      //  print("Result from API: $result");
      //  print("Result Type: ${result.runtimeType}");
      // if(result == null || !result.containsKey('weekly_meal_plan')){
      //   setState(() {
      //     // weeklyMeal = Map<String, dynamic>.from(result['weekly_meal_plan'] ?? {});
      //     errorMessage = result['error'];
      //     isLoading = false;
      //     weeklyMeal.clear();
      //     // suggestions.clear();
      //   });
      //   return;
      // }
      if(result.containsKey('error')){
      //  print("Result from GeminiService: $result");
       setState(() {
          errorMessage = result['error'];
          isLoading = false;
          weeklyMeal.clear();
          breakfast.clear();
          lunch.clear();
          dinner.clear();
          // _priority = null;
          // suggestions.clear();
       });
       return;
      }
      setState(() {
        weeklyMeal = Map<String, dynamic>.from(result['weekly_meal_plan'] ?? {});
        isLoading = false;
      });
       print('Weekly meal data : $weeklyMeal');
      weeklyMeal.forEach((day, meals) {
      // print("Breakfast: ${meals['breakfast']}");
      // print("Lunch: ${meals['lunch']}");
      // print("Dinner: ${meals['dinner']}");    
    });
    }catch(e){
      setState(() {
          errorMessage = "Failed to generate meal\n$e";
          isLoading = false;
          weeklyMeal.clear();
       });
    }
  }
  @override
  void initState(){
    _loadSavedMeal();
    _loadMealGenerator();
    super.initState();
  }

  @override
  void dispose(){
    _mealController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 10),
               decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.deepPurple, Colors.black],
                  end: Alignment.bottomCenter,
                  begin: Alignment.topCenter
                  ),
                  color:  Color.fromARGB(255,54,42,133),
              ),
              child:const Padding(
                padding: EdgeInsets.only(top: 50.0),
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Hello, Darda 👋🏻",style: TextStyle(color: Colors.white),),
                        Text("Good morning",style: TextStyle(color: Colors.white, fontSize: 20),),
                      ],
                    ),
                      ],
                    ),
                SizedBox(height: 10),
                Text("Let's make your meal\nplan today!",style: TextStyle(color: Colors.white,fontSize: 28, fontWeight: FontWeight.w500),),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _mealController,
                decoration: InputDecoration(
                  hintText: "Enter Your Meal",
                  labelText: "Your Meal",
                  prefixIcon: const Icon(Icons.dining),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  )
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                        hintText: "Meal time",
                        prefixIcon: Icon(Icons.calendar_month),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items: ["Breakfast","Lunch","Dinner"].map((mealTime) =>DropdownMenuItem(
                      value: mealTime,
                      child: Text(mealTime))).toList(), onChanged: (String? mealTime){
                        setState(() {
                          _mealTime = mealTime;
                        });
                      }),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                        hintText: "Choose Category",
                        prefixIcon: Icon(Icons.dinner_dining),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items: ["Healthy 🥗","High Protein 🍗","Low Carb 🥑", "Sweet Treat 🍩"].map((priority) =>DropdownMenuItem(
                      value: priority,
                      child: Text(priority))).toList(), onChanged: (String? priority){
                        setState(() {
                          _priority = priority ?? "";
                        });
                      }),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8 ),
              child: Center(
                child: SizedBox(
                  width: 400,
                  height: 50,
                  child: ElevatedButton.icon(onPressed: _addTask, label: Text("Add Your Meal!", style: TextStyle(color: Colors.black),), icon: Icon(Icons.add, color: Colors.black,),
                   style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5.0,
                    shadowColor: Colors.black.withOpacity(1),
                    
                   ),
                  ),
                ),
              ),
            ),
            if(_tasks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 150,
                child:ListView.builder(
                  itemCount: _tasks.length,
                  itemBuilder: (context, index){
                  var task = _tasks[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Card(
                      child: ListTile(
                        leading:const Icon(FontAwesomeIcons.listCheck,color:Colors.blueAccent,),
                        title: Text(task["task"]),
                        subtitle: Text("Meal time: ${task["mealTime"] ?? ""}, Priority: ${task["priority"] }", style: TextStyle(color: Colors.grey, fontSize: 12),),
                        trailing: IconButton(onPressed: (){
                          _deleteMealPlan(index);
                        }, icon: Icon(Icons.delete, color: Colors.red,)),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 18,),
            if(_tasks.isNotEmpty )
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 8),
              child: Center(
                child: SizedBox(
                  width: 400,
                  height: 50,
                  child: ElevatedButton.icon(onPressed: _generateMeal,
                  label:Text(isLoading 
                  ? "Generating..." 
                  :"Generate your Meal for a week", style: TextStyle(color: Colors.white),), 
                  icon: isLoading 
                  ? SizedBox( width:20, height: 20,child: CircularProgressIndicator(  color: Colors.white,),) 
                  : Icon(Icons.flash_on, color: Colors.white,),
                   style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255,54,42,133),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    )
                   ),
                  ),
                ),
              ),
            ),
            if(errorMessage.isNotEmpty && !isLoading && (breakfast.isNotEmpty || lunch.isNotEmpty || dinner.isNotEmpty))
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                color: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.error, color: Colors.white,),
                      SizedBox(width: 8,),
                      Expanded(
                        child: Text(errorMessage.isNotEmpty ? errorMessage : "", 
                        style:GoogleFonts.poppins(color:Colors.white),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        )
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if(isLoading)
            const Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: CircularProgressIndicator()
              ),  
            ),
            if(!isLoading && errorMessage.isEmpty && weeklyMeal.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: weeklyMeal.keys.map((day){
                    print("Membuat UI untuk: $day ");
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildScheduleGenerator("Breakfast", weeklyMeal[day]?['breakfast'], day, weeklyMeal[day]?['time'] ?? "No time availabe"),
                        _buildScheduleGenerator("Lunch", weeklyMeal[day]?['lunch'], day, weeklyMeal[day]?['time'] ?? "No time availabe"),
                        _buildScheduleGenerator("Dinner", weeklyMeal[day]?['dinner'], day, weeklyMeal[day]?['time'] ?? "No time availabe"),
                        const SizedBox(height: 10,),
                        // if(suggestions.isNotEmpty)
                        // _buildSuggestionGenerator("Suggestion", suggestions),
                      ]
                    );
                  }).toList()
                ),
              ),
          ],
        ),
      ),
    );
  }


  }

Card _buildScheduleGenerator(String title, dynamic meal, String day, String time) {
  if (meal == null || meal is! Map<String, dynamic>) 
  {
    return Card(
      color: Color.fromARGB(255, 54, 42, 133),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "no meal data available",
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  return Card(
    color: Color.fromARGB(255, 54, 42, 133),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "🗓️ $day",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ListTile(
            title: Text(
              meal['dish'] ?? "Failed to generate, try to regenerate!" , 
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              meal['time'] ?? "Unknown Time",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    ),
  );

}