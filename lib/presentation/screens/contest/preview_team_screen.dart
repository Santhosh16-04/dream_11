import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PreviewTeamScreen extends StatelessWidget {
  final List<Map<String, dynamic>> selectedPlayers;
  final double creditsLeft;
  final String team1;
  final String team2;
  final int team1Count;
  final int team2Count;

  const PreviewTeamScreen({
    Key? key,
    required this.selectedPlayers,
    required this.creditsLeft,
    required this.team1,
    required this.team2,
    required this.team1Count,
    required this.team2Count,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalPlayers = 11;
    final wk = selectedPlayers.where((p) => p['role'] == 'WK').toList();
    final bat = selectedPlayers.where((p) => p['role'] == 'BAT').toList();
    final ar = selectedPlayers.where((p) => p['role'] == 'AR').toList();
    final bowl = selectedPlayers.where((p) => p['role'] == 'BOWL').toList();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.black, // ✅ Black background for status bar
        statusBarIconBrightness: Brightness.light, // ✅ White icons
      ),
    );
    return Scaffold(
      backgroundColor: Colors.black, // fallback
      body: Stack(
        children: [
          // ✅ Background image covers whole screen
          Positioned.fill(
            child: Image.asset(
              'assets/images/cricket_ground.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // ✅ Main content layered over background
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  // ✅ TOP BAR OVER BACKGROUND
                  Container(
                    color: Colors.black87,
                    padding: EdgeInsets.only(bottom: 8),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  "SANDY CHOSEN ONES 1278513",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 48),
                          ],
                        ),
                        Divider(color: Colors.white70, thickness: 1),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Players\n${selectedPlayers.length}/$totalPlayers',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white12,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    Text(team1,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13)),
                                    SizedBox(width: 6),
                                    Text('$team1Count : $team2Count',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15)),
                                    SizedBox(width: 6),
                                    Text(team2,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13)),
                                  ],
                                ),
                              ),
                              Text(
                                'Credits Left\n${creditsLeft.toStringAsFixed(1)}',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ✅ Players Area
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 8),
                      child: selectedPlayers.isEmpty
                          ? Center(
                              child: Container(
                                padding: EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "No players selected yet",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                    SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text("START SELECTING"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Column(
                              children: [
                                if (wk.isNotEmpty)
                                  _buildRoleSection('WICKET-KEEPERS', wk),
                                SizedBox(height: 4),  
                                if (bat.isNotEmpty)
                                  _buildRoleSection('BATTERS', bat),
                                SizedBox(height: 4),
                                if (ar.isNotEmpty)
                                  _buildRoleSection('ALL-ROUNDERS', ar),
                                SizedBox(height: 4),
                                if (bowl.isNotEmpty)
                                  _buildRoleSection('BOWLERS', bowl),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSection(String label, List<Map<String, dynamic>> players) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
        SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: players.map((player) => _buildPlayerCard(player)).toList(),
        ),
        SizedBox(height: 12),
      ],
    );
  }

  Widget _buildPlayerCard(Map<String, dynamic> player) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          CircleAvatar(
            backgroundImage: AssetImage(player['image']),
            radius: 25,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              player['name'],
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
          SizedBox(height: 4),
          Text(
            '${player['credits']} Cr',
            style: TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
