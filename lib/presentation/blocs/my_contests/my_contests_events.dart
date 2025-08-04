abstract class MyContestsEvent {}

class AddContestToMyContests extends MyContestsEvent {
  final String contestId;
  final Map<String, dynamic> contestData;

  AddContestToMyContests(this.contestId, this.contestData);
}

class LoadMyContests extends MyContestsEvent {}