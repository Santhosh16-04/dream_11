import 'package:equatable/equatable.dart';

class TeamState extends Equatable {
  final List<Map<String, dynamic>> teams;
  final int? selectedTeamId;

  const TeamState({this.teams = const [], this.selectedTeamId});

  TeamState copyWith({List<Map<String, dynamic>>? teams, int? selectedTeamId}) {
    return TeamState(
      teams: teams ?? this.teams,
      selectedTeamId: selectedTeamId ?? this.selectedTeamId,
    );
  }

  @override
  List<Object?> get props => [teams, selectedTeamId];
} 