import 'package:flutter_bloc/flutter_bloc.dart';
import 'my_contests_events.dart';
import 'my_contests_states.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MyContestsBloc extends Bloc<MyContestsEvent, MyContestsState> {
  List<Map<String, dynamic>> _contests = [];
  // Track contest-team mappings: contestId -> List of teamIds
  Map<String, List<String>> _contestTeamMappings = {};
  // Track unique contest IDs to avoid duplicates in UI storage
  final Set<String> _contestIds = <String>{};

  MyContestsBloc() : super(MyContestsInitial()) {
    // Initialize with empty data to ensure we always have valid state
    _contests = [];
    _contestTeamMappings = {};
    
    on<AddContestToMyContests>((event, emit) async {
      try {
        // Add the complete contest data to the list only if not already present
        if (!_contestIds.contains(event.contestId)) {
          _contests.add(event.contestData);
          _contestIds.add(event.contestId);
        } else {
          // Ensure we keep contests list de-duplicated by content too
          _contests = _dedupeContests(_contests);
        }
        
        // Track the team used for this contest
        if (event.teamId != null) {
          if (!_contestTeamMappings.containsKey(event.contestId)) {
            _contestTeamMappings[event.contestId] = [];
          }
          if (!_contestTeamMappings[event.contestId]!.contains(event.teamId)) {
            _contestTeamMappings[event.contestId]!.add(event.teamId!);
          }
        }
        
        // Final safety: remove any accidental duplicates before save
        _contests = _dedupeContests(_contests);

        // Save to SharedPreferences
        await _saveContestsToPrefs(_contests);
        await _saveContestTeamMappingsToPrefs(_contestTeamMappings);
        
        // Emit the updated state with the new list
        emit(MyContestsLoaded(
          contests: _contests,
          contestTeamMappings: _contestTeamMappings,
        ));
      } catch (e) {
        print('Error in AddContestToMyContests: $e');
        // Emit current state even if save fails
        emit(MyContestsLoaded(
          contests: _contests,
          contestTeamMappings: _contestTeamMappings,
        ));
      }
    });

    on<LoadMyContests>((event, emit) async {
      try {
        // Load contests from SharedPreferences
        final loadedContests = await _loadContestsFromPrefs();
        final loadedMappings = await _loadContestTeamMappingsFromPrefs();
        
        print('Loaded contests: ${loadedContests.length}');
        print('Loaded mappings: ${loadedMappings.length}');
        print('Loaded mappings type: ${loadedMappings.runtimeType}');
        
        // De-duplicate any previously saved duplicates
        _contests = _dedupeContests(loadedContests);
        _contestTeamMappings = loadedMappings;

        // Rebuild contestIds set from mappings where possible to prevent future dupes
        _contestIds.clear();
        _contestIds.addAll(_contestTeamMappings.keys);
        
        print('Final contests: ${_contests.length}');
        print('Final mappings: ${_contestTeamMappings.length}');
        
        emit(MyContestsLoaded(
          contests: _contests,
          contestTeamMappings: _contestTeamMappings,
        ));
      } catch (e) {
        print('Error in LoadMyContests: $e');
        // Ensure we always emit a valid state
        _contests = [];
        _contestTeamMappings = {};
        emit(MyContestsLoaded(
          contests: _contests,
          contestTeamMappings: _contestTeamMappings,
        ));
      }
    });

    on<GetTeamsForContest>((event, emit) async {
      try {
        final teamsUsed = _contestTeamMappings[event.contestId] ?? [];
        emit(TeamsForContestLoaded(teamsUsed: teamsUsed));
      } catch (e) {
        print('Error in GetTeamsForContest: $e');
        emit(TeamsForContestLoaded(teamsUsed: []));
      }
    });
  }

  Future<void> _saveContestsToPrefs(List<Map<String, dynamic>> contests) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contestsJson = jsonEncode(contests);
      await prefs.setString('joined_contests', contestsJson);
    } catch (e) {
      print('Error saving contests to prefs: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _loadContestsFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contestsJson = prefs.getString('joined_contests');
      if (contestsJson == null || contestsJson.isEmpty) return [];
      
      final List<dynamic> decoded = jsonDecode(contestsJson);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      print('Error loading contests from prefs: $e');
      return [];
    }
  }

  Future<void> _saveContestTeamMappingsToPrefs(Map<String, List<String>> mappings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mappingsJson = jsonEncode(mappings);
      await prefs.setString('contest_team_mappings', mappingsJson);
    } catch (e) {
      print('Error saving contest team mappings to prefs: $e');
    }
  }

  Future<Map<String, List<String>>> _loadContestTeamMappingsFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mappingsJson = prefs.getString('contest_team_mappings');
      if (mappingsJson == null || mappingsJson.isEmpty) return {};
      
      final Map<String, dynamic> decoded = jsonDecode(mappingsJson);
      return decoded.map((key, value) {
        if (value is List) {
          return MapEntry(key.toString(), value.map((item) => item.toString()).toList());
        } else {
          return MapEntry(key.toString(), <String>[]);
        }
      });
    } catch (e) {
      print('Error loading contest team mappings: $e');
      return {};
    }
  }

  // Helper to remove duplicates by content equality
  List<Map<String, dynamic>> _dedupeContests(
      List<Map<String, dynamic>> contests) {
    final Set<String> seen = <String>{};
    final List<Map<String, dynamic>> result = [];
    for (final c in contests) {
      try {
        final key = jsonEncode(c);
        if (!seen.contains(key)) {
          seen.add(key);
          result.add(c);
        }
      } catch (_) {
        // If encoding fails for some reason, include the item
        result.add(c);
      }
    }
    return result;
  }
}