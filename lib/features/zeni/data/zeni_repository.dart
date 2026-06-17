import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

sealed class ZeniResult {}
class ZeniTaskCreated extends ZeniResult {
  final String title, dueDate, dueTime, priority, category;
  ZeniTaskCreated({required this.title, required this.dueDate, required this.dueTime, required this.priority, required this.category});
}
class ZeniAttendanceLogged extends ZeniResult {
  final String subject;
  final bool isPresent;
  ZeniAttendanceLogged({required this.subject, required this.isPresent});
}
class ZeniNoteCreated extends ZeniResult {
  final String title, body;
  ZeniNoteCreated({required this.title, required this.body});
}
class ZeniChatResponse extends ZeniResult {
  final String message;
  ZeniChatResponse(this.message);
}
class ZeniError extends ZeniResult {
  final String error;
  ZeniError(this.error);
}

class ZeniRepository {
  static const _systemPrompt = """
You are Zeni, AI assistant for Zyvora productivity app.
Respond ONLY with valid JSON. No markdown. No extra text.
Detect intent and respond:
Task creation: {"action":"create_task","title":"...","dueDate":"YYYY-MM-DD or null","dueTime":"HH:mm or null","priority":"Low|Medium|High","category":"Study|Work|Personal|Health"}
Attendance: {"action":"log_attendance","subject":"...","isPresent":true/false}
Note: {"action":"create_note","title":"...","body":"..."}
Chat: {"action":"chat","message":"..."}
Be warm, encouraging, concise.
""";

  Future<ZeniResult> process(String input, String apiKey) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        systemInstruction: Content.system(_systemPrompt),
      );
      final resp = await model.generateContent([Content.text(input)]);
      final text = resp.text ?? '{"action":"chat","message":"Sorry, I had trouble with that."}';
      final clean = text.replaceAll(RegExp(r'```json|```'), '').trim();
      final json = jsonDecode(clean) as Map<String, dynamic>;
      return _parseResult(json);
    } catch (e) {
      return ZeniError(e.toString());
    }
  }

  ZeniResult _parseResult(Map<String,dynamic> json) {
    switch(json['action']) {
      case 'create_task': 
        return ZeniTaskCreated(
          title: json['title'] ?? 'Task', 
          dueDate: json['dueDate']?.toString() ?? '',
          dueTime: json['dueTime']?.toString() ?? '', 
          priority: json['priority']?.toString() ?? 'Low',
          category: json['category']?.toString() ?? 'Personal'
        );
      case 'log_attendance': 
        return ZeniAttendanceLogged(
          subject: json['subject']?.toString() ?? 'Unknown', 
          isPresent: json['isPresent'] ?? true
        );
      case 'create_note': 
        return ZeniNoteCreated(
          title: json['title']?.toString() ?? 'Note', 
          body: json['body']?.toString() ?? ''
        );
      default: 
        return ZeniChatResponse(json['message']?.toString() ?? '');
    }
  }
}
