import 'package:equatable/equatable.dart';

abstract class TeamEvent extends Equatable {
  const TeamEvent();
  @override
  List<Object?> get props => [];
}

class AddTeam extends TeamEvent {
  final Map<String, dynamic> team;
  const AddTeam(this.team);
  @override
  List<Object?> get props => [team];
}

class EditTeam extends TeamEvent {
  final int teamId;
  final Map<String, dynamic> newTeamData;
  const EditTeam(this.teamId, this.newTeamData);
  @override
  List<Object?> get props => [teamId, newTeamData];
}

class DuplicateTeam extends TeamEvent {
  final int teamId;
  const DuplicateTeam(this.teamId);
  @override
  List<Object?> get props => [teamId];
}

class DeleteTeam extends TeamEvent {
  final int teamId;
  const DeleteTeam(this.teamId);
  @override
  List<Object?> get props => [teamId];
}

class LoadTeams extends TeamEvent {} 