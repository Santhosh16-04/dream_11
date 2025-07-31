import 'package:clever_11/cubit/team/team_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../cubit/team/team_bloc.dart';
import '../../../cubit/team/team_state.dart';

class SelectTeamScreen extends StatefulWidget {
  final int timeLeftMinutes;
  final int maxTeams;
  final int initiallySelectedTeam;

  const SelectTeamScreen({
    Key? key,
    this.timeLeftMinutes = 0,
    this.maxTeams = 20,
    this.initiallySelectedTeam = 0,
  }) : super(key: key);

  @override
  _SelectTeamScreenState createState() => _SelectTeamScreenState();
}

class _SelectTeamScreenState extends State<SelectTeamScreen> {
  int? selectedTeamIndex;
  bool selectAll = false;

  @override
  void initState() {
    super.initState();
    selectedTeamIndex = widget.initiallySelectedTeam;
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
                        // TODO: Navigate to create team
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
                            onChanged: (val) {
                              setState(() {
                                selectAll = val ?? false;
                                selectedTeamIndex = selectAll ? 0 : null;
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
                            final team = teams[idx];
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
                                            _buildStat("EDC", team['edc']),
                                            _buildStat("SAC", team['sac']),
                                            _buildPlayerCard(
                                                team['captain'], 'C'),
                                            _buildPlayerCard(
                                                team['viceCaptain'], 'VC'),
                                          ],
                                        ),
                                        const SizedBox(height: 12),

                                        /// Role counts row
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            _buildRoleStat("WK", team['wk']),
                                            _buildRoleStat("BAT", team['bat']),
                                            _buildRoleStat("AR", team['ar']),
                                            _buildRoleStat(
                                                "BOWL", team['bowl']),
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
                                      value: selectedTeamIndex == idx,
                                      onChanged: (val) {
                                        setState(() {
                                          selectedTeamIndex = idx;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
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
