import 'package:clever_11/cubit/team/team_event.dart';
import 'package:clever_11/routes/m11_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../cubit/team/team_bloc.dart';
import '../../../cubit/team/team_state.dart';
import 'package:clever_11/presentation/screens/payment_screen.dart'; // Added import for PaymentScreen
import 'package:clever_11/presentation/screens/contest/create_team_screen.dart'; // Import for M11_CreateTeamScreen

class SelectTeamScreen extends StatefulWidget {
  final int timeLeftMinutes;
  final int maxTeams;
  final int initiallySelectedTeam;
  final Map<String, dynamic>? contestData;
  final String? contestId;

  const SelectTeamScreen({
    Key? key,
    this.timeLeftMinutes = 0,
    this.maxTeams = 20,
    this.initiallySelectedTeam = 0,
    this.contestData,
    this.contestId,
  }) : super(key: key);

  @override
  _SelectTeamScreenState createState() => _SelectTeamScreenState();
}

class _SelectTeamScreenState extends State<SelectTeamScreen> {
  int? selectedTeamIndex;
  bool selectAll = false;
  List<bool> teamSelections =
      []; // Add this to manage individual team selections

  // Ensure teamSelections is initialized correctly in initState
  @override
  void initState() {
    super.initState();
    selectedTeamIndex = widget.initiallySelectedTeam;
    teamSelections = List.filled(widget.maxTeams, false); // Initialize here
    // Load teams from storage
    context.read<TeamBloc>().add(LoadTeams());
  }

  String get timeLeftString {
    final h = widget.timeLeftMinutes ~/ 60;
    final m = widget.timeLeftMinutes % 60;
    return '${h}h ${m}m left';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeamBloc, TeamState>(
      builder: (context, state) {
        final teams = state.teams;

        // Ensure teamSelections matches team count
        if (teamSelections.length != teams.length) {
          teamSelections = List<bool>.filled(teams.length, false);
          // If all were previously selected, preserve that
          if (selectAll) {
            teamSelections = List<bool>.filled(teams.length, true);
          }
        }
        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            leading: BackButton(
              color: Colors.white,
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Teams',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
                SizedBox(height: 2),
                Text(
                  timeLeftString,
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline, color: Colors.white),
                    SizedBox(width: 4),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => M11_CreateTeamScreen(
                              source:
                                  'select_team', // Indicate source is select team screen
                            ),
                          ),
                        );
                      },
                      child: Text('CREATE TEAM',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ],
            backgroundColor: Color(0xFF4B0D1B),
            elevation: 0,
          ),
          body: teams.isEmpty
              ? Center(child: Text('No teams found. Please create a team.'))
              : Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.symmetric(
                          horizontal: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Text('Select All (${teams.length})',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          Spacer(),
                          Checkbox(
                            value: selectAll,
                            onChanged: (bool? value) {
                              setState(() {
                                selectAll = value ?? false;
                                for (int i = 0;
                                    i < teamSelections.length;
                                    i++) {
                                  teamSelections[i] = selectAll;
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SafeArea(
                        bottom: false,
                        child: ListView.builder(
                          itemCount: teams.length,
                          padding: const EdgeInsets.all(12),
                          itemBuilder: (context, idx) {
                            //  final team = teams[idx];
                            final team = state.teams[idx];
                            final players = List<Map<String, dynamic>>.from(
                                team['players'] ?? []);
                            final team1 = players.isNotEmpty
                                ? players.first['team']
                                : 'Team 1';
                            final team2 = players.length > 1
                                ? players[1]['team']
                                : 'Team 2';
                            final team1Count =
                                players.where((p) => p['team'] == team1).length;
                            final team2Count =
                                players.where((p) => p['team'] == team2).length;
                            Map<String, dynamic>? captain = players
                                .cast<Map<String, dynamic>?>()
                                .firstWhere(
                                  (p) =>
                                      p != null && p['id'] == team['captainId'],
                                  orElse: () => null,
                                );
                            Map<String, dynamic>? viceCaptain = players
                                .cast<Map<String, dynamic>?>()
                                .firstWhere(
                                  (p) =>
                                      p != null &&
                                      p['id'] == team['viceCaptainId'],
                                  orElse: () => null,
                                );
                            final wkCount =
                                players.where((p) => p['role'] == 'WK').length;
                            final batCount =
                                players.where((p) => p['role'] == 'BAT').length;
                            final arCount =
                                players.where((p) => p['role'] == 'AR').length;
                            final bowlCount = players
                                .where((p) => p['role'] == 'BOWL')
                                .length;
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Color(0xFF1E5631), // Green background
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        /// Team title
                                        Text('Team ${idx + 1}',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 8),

                                        /// EDC and SAC row
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            _buildStat(team1, team1Count),
                                            _buildStat(team2, team2Count),
                                            _buildPlayerCard(captain, 'C'),
                                            _buildPlayerCard(viceCaptain, 'VC'),
                                          ],
                                        ),
                                        const SizedBox(height: 12),

                                        /// Role counts row
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            _buildRoleStat("WK", wkCount),
                                            _buildRoleStat("BAT", batCount),
                                            _buildRoleStat("AR", arCount),
                                            _buildRoleStat("BOWL", bowlCount),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  /// Checkbox (top right)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Checkbox(
                                      value: teamSelections[idx],
                                      onChanged: (bool? value) {
                                        setState(() {
                                          teamSelections[idx] = value ?? false;
                                          selectAll = teamSelections.every(
                                              (isSelected) => isSelected);
                                        });
                                      },
                                      checkColor: Colors.red, // Tick color
                                      fillColor: MaterialStateProperty.all(Colors
                                          .white), // Box fill color when checked
                                      side: const BorderSide(
                                          color: Colors
                                              .white), // Border color when unchecked
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // Add the JOIN button at the bottom
                    InkWell(
                      onTap: () {
                        final isAnySelected =
                            teamSelections.any((selected) => selected);
                        if (isAnySelected) {
                          
                          Navigator.pushNamed(
                            context,
                            M11_AppRoutes.c11_main_payment,
                            arguments: {
                              'contestId': widget.contestId ?? 'default',
                              'contestData': widget.contestData ?? {},
                            },
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please select at least one team.'),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        color: Colors.green,
                        child: Center(
                          child: Text(
                            'JOIN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildStat(String label, int? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 2),
        Text("${value ?? 0}",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
      ],
    );
  }

  Widget _buildPlayerCard(Map<String, dynamic>? player, String tag) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage(player?['image'] ?? ''),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tag == 'C' ? Colors.black : Colors.white,
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: tag == 'C' ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: tag == 'VC' ? Colors.white : Colors.black87,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            player?['name'] ?? '',
            style: TextStyle(
              fontSize: 12,
              color: tag == 'VC' ? Colors.black : Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildRoleStat(String label, int? value) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 2),
        Text("${value ?? 0}",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14)),
      ],
    );
  }
}
