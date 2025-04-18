import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';
class GeminiService {
  static const String apiKey = "AIzaSyDMDk46x0ghi-9Z3rzx3TB29tU2LGBMILs";

  static Future<Map<String, dynamic>> generateMeal(List<Map<String, dynamic>> tasks) async{
    final prompt = _buildPrompt(tasks);


  final model = GenerativeModel(
    model: 'gemini-2.0-flash',
    apiKey: apiKey,
    generationConfig: GenerationConfig(
      temperature: 1,
      topK: 40,
      topP: 0.95,
      maxOutputTokens: 8192,
      responseMimeType: 'text/plain',
    ),
  );

    final chat = model.startChat(history: [
      Content.multi([
          TextPart('''You are a nutrition assistant creating a realistic and healthy weekly meal plan based on Indonesian cuisine. Consider meal variety, balanced nutrition, and user preferences. Provide output in JSON format with sections for each day of the week ("Monday" to "Sunday"). Each day should have "breakfast", "lunch", "dinner" and "day" fields, with each meal containing "dish" and "time" fields. Add more emoticons and do not include any additional text outside the JSON structure..'''),
    ]),
      
  ]);
    final message = prompt;
    final content = Content.text(message);
    try{
     final response = await chat.sendMessage(content);

      final responseText = (response.candidates.first.content.parts.first as TextPart).text;

      if(responseText.isEmpty){
        return {"error": "No response from Gemini"};
    }
      // json pattern
      RegExp jsonPattern = RegExp(r'\{.*\}', dotAll: true);
      final match = jsonPattern.firstMatch(responseText);
      if(match != null){
       return json.decode(match.group(0)!);
     }
    }catch(e){
      return {"error": "Error generating schedule\n$e"};
    }
    
    return {"prompt": prompt};
  }
   static String _buildPrompt(List<Map<String, dynamic>> meals){
      String mealList = meals.map((task) => "- ${task['task']}, (Priority: ${task['priority']}), Meal time: ${task['mealTime']}").join('\n');

      return "Create a realistic and healthy weekly meal plan based on Indonesian and halal cuisine. Make sure there is a variety of foods, nutritional balance, and according to the user's preferences. Provide the output in JSON format with one key 'day' representing the day of the week. Each day should have 'breakfast', 'lunch', 'dinner', and 'day', where each meal includes 'meal' and 'time'. Add more emoticons and don't include any extra text outside the JSON structure.\n\n$mealList";

    }
}