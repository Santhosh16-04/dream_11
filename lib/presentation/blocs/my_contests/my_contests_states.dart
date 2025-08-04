abstract class MyContestsState {}

class MyContestsInitial extends MyContestsState {}

class MyContestsLoaded extends MyContestsState {
  final List<Map<String, dynamic>> contests;
  
  MyContestsLoaded(this.contests);
}