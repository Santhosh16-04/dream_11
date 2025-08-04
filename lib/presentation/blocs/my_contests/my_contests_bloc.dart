import 'package:flutter_bloc/flutter_bloc.dart';
import 'my_contests_events.dart';
import 'my_contests_states.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MyContestsBloc extends Bloc<MyContestsEvent, MyContestsState> {
  List<Map<String, dynamic>> _contests = [];

  MyContestsBloc() : super(MyContestsInitial()) {
    on<AddContestToMyContests>((event, emit) async {
      // Add the complete contest data to the list
      _contests.add(event.contestData);
      
      // Save to SharedPreferences
      await _saveContestsToPrefs(_contests);
      
      // Emit the updated state with the new list
      emit(MyContestsLoaded(_contests));
    });

    on<LoadMyContests>((event, emit) async {
      // Load contests from SharedPreferences
      final loadedContests = await _loadContestsFromPrefs();
      _contests = loadedContests;
      emit(MyContestsLoaded(_contests));
    });
  }

  Future<void> _saveContestsToPrefs(List<Map<String, dynamic>> contests) async {
    final prefs = await SharedPreferences.getInstance();
    final contestsJson = jsonEncode(contests);
    await prefs.setString('joined_contests', contestsJson);
  }

  Future<List<Map<String, dynamic>>> _loadContestsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final contestsJson = prefs.getString('joined_contests');
    if (contestsJson == null) return [];
    final List<dynamic> decoded = jsonDecode(contestsJson);
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }
}