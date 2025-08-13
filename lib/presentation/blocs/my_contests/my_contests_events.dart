abstract class MyContestsEvent {}

class AddContestToMyContests extends MyContestsEvent {
  final String contestId;
  final Map<String, dynamic> contestData;
  final String? teamId; // Optional teamId to track which team was used

  AddContestToMyContests(this.contestId, this.contestData, {this.teamId});
}

class LoadMyContests extends MyContestsEvent {}

class GetTeamsForContest extends MyContestsEvent {
  final String contestId;
  
  GetTeamsForContest(this.contestId);
}