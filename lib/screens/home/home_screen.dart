import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:schedule_generator_with_gemini/network/gemini_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';

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
  List<String> suggestions = [];

  void _addTask() {
    if(_mealController.text.isNotEmpty && 
       _priority != null && _mealTime != null) {
         print("Meal: \${_mealController.text}, MealTime: \$_mealTime, Priority: \$_priority");
        setState(() {
          _tasks.add({
          "task": _mealController.text,
          "mealTime": _mealTime ?? "",
          "priority": _priority ?? "",
          "deadline": ""
          });
        });
        print('task added : ${_tasks}');
        print('MealTime dari task terakhir: ${_tasks.last['mealTime']}');
        _mealController.clear();
        _mealTime = null;
        _priority = null;
       }

  }
  Future<void> _generateMeal()async{
    setState(() {
      isLoading = true;
    });
    try{

      final result = await GeminiService.generateMeal(_tasks);

       print("Result from API: $result");
       print("Result Type: ${result.runtimeType}");
      // if(result == null || !result.containsKey('weekly_meal_plan')){
      //   setState(() {
      //     errorMessage = result['error'] ?? "Unknown error occured";
      //     isLoading = false;
      //     weeklyMeal.clear();
      //     suggestions.clear();
      //   });
      // }
      if(result.containsKey('error')){
       print("Result from GeminiService: $result");
       setState(() {
          errorMessage = result['error'];
          isLoading = false;
          weeklyMeal.clear();
          // _priority = null;
          suggestions.clear();
       });
       return;
      }
      setState(() {
        weeklyMeal = Map<String, dynamic>.from(result['weekly_meal_plan'] ?? {});
        suggestions = List<String>.from(result['suggestions'] ?? []);
        isLoading = false;
      });
       print('Weekly meal data : $weeklyMeal');
       weeklyMeal.forEach((day, meals) {
      print("Processing: $day");
      print("Breakfast: ${meals['breakfast']}");
      print("Lunch: ${meals['lunch']}");
      print("Dinner: ${meals['dinner']}");
});
    }catch(e){
      setState(() {
          errorMessage = "Failed to generate schedule\n$e";
          isLoading = false;
          weeklyMeal.clear();
       });
    }
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
                    Icon(Icons.notifications,
                    size: 25,
                    color: Colors.white,
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
                          setState(() {
                            _tasks.removeAt(index);
                          });
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
            if(errorMessage.isNotEmpty && !isLoading )
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Shimmer.fromColors(child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                       ), child: SizedBox(height: 10, width: 250,),
                      ), 
                      baseColor: Colors.grey[300]!, highlightColor: Colors.grey[400]!
                  ),
                  Shimmer.fromColors(child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                       ), child: SizedBox(height: 30, width: 200,),
                      ), 
                      baseColor: Colors.grey[300]!, highlightColor: Colors.grey[400]!
                  ),
                  Shimmer.fromColors(child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                       ), child: SizedBox(height: 20, width: 150,),
                      ), 
                      baseColor: Colors.grey[300]!, highlightColor: Colors.grey[200]!
                  ),
                  Shimmer.fromColors(child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                       ), child: SizedBox(height: 10, width: 300,),
                      ), 
                      baseColor: Colors.grey[300]!, highlightColor: Colors.grey[200]!
                  ),
                ],
              ),  
            ),
            if(!isLoading && errorMessage.isEmpty && weeklyMeal.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: weeklyMeal.keys.map((day){
                    print("Membuat UI untuk: $day");
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildScheduleGenerator("Breakfast", weeklyMeal[day]?['breakfast'], day),
                        _buildScheduleGenerator("Lunch", weeklyMeal[day]?['lunch'], day),
                        _buildScheduleGenerator("Dinner", weeklyMeal[day]?['dinner'], day),
                        const SizedBox(height: 10,),
                        if(suggestions.isNotEmpty)
                        _buildSuggestionGenerator("Suggestion", suggestions ?? []),
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
Card _buildSuggestionGenerator(String title, List<String> suggestions) {
  return Card(
    color: Color.fromARGB(255, 54, 42, 133),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    child: Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Suggestions",
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          ...suggestions.map(
            (suggestion) => ListTile(
              title: Text(
                suggestion ?? "There is no Suggestion", // Penanganan null
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Card _buildScheduleGenerator(String title, dynamic meal, String day) {
  if (meal == null || meal is! Map<String, dynamic>) {
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
              "There is no suggestion!",
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
              meal['meal'] ?? "Unknown meal", // Penanganan null
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              meal['time'] ?? "Unknown time",
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