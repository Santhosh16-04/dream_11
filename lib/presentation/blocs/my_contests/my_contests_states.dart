abstract class MyContestsState {}

class MyContestsInitial extends MyContestsState {}

class MyContestsLoaded extends MyContestsState {
  final List<Map<String, dynamic>> contests;
  final Map<String, List<String>> contestTeamMappings; // contestId -> List of teamIds
  
  MyContestsLoaded({
    required this.contests,
    required this.contestTeamMappings,
  });
}

class TeamsForContestLoaded extends MyContestsState {
  final List<String> teamsUsed; // List of teamIds already used in this contest
  
  TeamsForContestLoaded({
    required this.teamsUsed,
  });
}