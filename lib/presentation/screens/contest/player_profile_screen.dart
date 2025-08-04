import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlayerProfileScreen extends StatefulWidget {
  final int initialIndex;
  final int? playerId;
  const PlayerProfileScreen({Key? key, this.initialIndex = 0, this.playerId})
      : super(key: key);

  @override
  State<PlayerProfileScreen> createState() => _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends State<PlayerProfileScreen> {
  List<dynamic> players = [];
  int pageIndex = 0;
  bool isLoading = true;
  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    pageIndex = widget.initialIndex;
    _loadData();
  }

  Future<void> _loadData() async {
    final String jsonString =
        await rootBundle.loadString('assets/json/player_profile.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    setState(() {
      players = jsonData['players'] ?? [];
      // If playerId is provided, find its index
      if (widget.playerId != null) {
        final idx = players.indexWhere((p) => p['id'] == widget.playerId);
        if (idx != -1) {
          pageIndex = idx;
        }
      }
      isLoading = false;
      _pageController = PageController(initialPage: pageIndex);
    });
  }

  void _showPointsBreakup(List<dynamic> pointsBreakup, int total) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Points Breakup',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: Text('Actions',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Text('Points', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Divider(),
              ...pointsBreakup.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Expanded(child: Text(item['action'].toString())),
                        Text(item['points'].toString()),
                      ],
                    ),
                  )),
              Divider(),
              Row(
                children: [
                  Expanded(
                      child: Text('Total',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Text(total.toString(),
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || players.isEmpty || _pageController == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Player Profile',
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
            SizedBox(height: 2),
            Text(
              players[pageIndex]['time_left'] ?? '',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.blue[900],
        toolbarHeight: 60,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: players.length,
        onPageChanged: (index) {
          setState(() {
            pageIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final player = players[index];
          final stats = player['stats'];
          final featured = player['featured'];
          final recentMatches = player['recent_matches'] as List;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Blue background for header (app bar + profile header)
                Container(
                  color: Colors.blue[900],
                  child: Column(
                    children: [
                      // Player profile header
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Backward Icon
                            if (pageIndex > 0)
                              IconButton(
                                icon: Icon(Icons.arrow_back_ios,
                                    color: Colors.white),
                                onPressed: () {
                                  _pageController!.previousPage(
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                              )
                            else
                              SizedBox(width: 40),

                            // Center Content
                            Expanded(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Stack(
                                    clipBehavior: Clip.none,
                                    alignment: Alignment.bottomLeft,
                                    children: [
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundImage: NetworkImage(
                                          players[pageIndex]['profile_image'],
                                        ),
                                        backgroundColor: Colors.white,
                                      ),
                                      Positioned(
                                        bottom: -5,
                                        right: 0,
                                        left: 0,
                                        child: Container(
                                          padding:
                                              EdgeInsets.symmetric(vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.blueAccent,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Center(
                                            child: Text(
                                              players[pageIndex]['team_code'],
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  // Name & Role
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              players[pageIndex]['name'],
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(width: 4),
                                            if (players[pageIndex]['role'] !=
                                                null)
                                              Text(
                                                '(${players[pageIndex]['role']})',
                                                style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 12,
                                                ),
                                              ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.sports_cricket,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              players[pageIndex]
                                                      ['batting_style'] ??
                                                  'Right Handed',
                                              style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 12),
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              players[pageIndex]
                                                      ['bowling_style'] ??
                                                  '-',
                                              style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Forward Icon
                            if (pageIndex < players.length - 1)
                              IconButton(
                                icon: Icon(Icons.arrow_forward_ios,
                                    color: Colors.white),
                                onPressed: () {
                                  _pageController!.nextPage(
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                              )
                            else
                              SizedBox(width: 40),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 8, right: 8, top: 2, bottom: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: _statCard('Avg. Total Points',
                            stats['avg_total_points'].toString()),
                      ),
                      Expanded(
                        child: _statCard(
                            'Avg. Selection', '${stats['avg_selection']}%'),
                      ),
                      Expanded(
                        child: _statCard(
                          'Status',
                          stats['status'],
                          isLink: true,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 8, right: 8, top: 2, bottom: 2),
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.shield,
                                color: Colors.red,
                                size: 16,
                              ),
                              SizedBox(width: 2),
                              Text(
                                'Featured in Ultimate Team (last ${featured['last_n_matches']} matches) ',
                                style: TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                          Text('${featured['featured_in_ultimate_team']} times',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 8, right: 8, top: 8, bottom: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Performance in recent T20 Matches',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                ...recentMatches
                    .map<Widget>((series) => _seriesWidget(series, player))
                    .toList(),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.person_add, color: Colors.white),
            label: Text(
              'Add Player',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF003FB4),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, {bool isLink = false}) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: Padding(
        padding: const EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 11, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isLink ? Colors.blue : Colors.black,
                  decoration: TextDecoration.none,
                  overflow: TextOverflow.ellipsis),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _seriesWidget(dynamic series, dynamic player) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 8),
                child: Text(
                  series['series'] ?? '',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              SizedBox(height: 4),
              // Matches (no card, just padding)
              ...((series['matches'] ?? []) as List)
                  .map<Widget>((match) => _matchRow(match))
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _matchRow(dynamic match) {
    String matchCode = match['match_code'] ?? '';
    List<String> teams = matchCode.split(' vs ');
    String team1 = teams.isNotEmpty ? teams[0] : '';
    String team2 = teams.length > 1 ? teams[1] : '';

    return InkWell(
      onTap: () {
        _showPointsBreakup(
          match['points_breakup'] ?? [],
          match['total_points'] ?? 0,
        );
      },
      child: Card(
        color: const Color.fromARGB(255, 249, 249, 249),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: Team names, icon, date
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        team1,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.shield, color: Colors.red, size: 16),
                      SizedBox(width: 4),
                      Text(
                        "vs",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 4),
                      Text(
                        team2,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    match['date'] ?? '',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            // Right: Points + arrow
            Row(
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Total Points : ',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                      TextSpan(
                        text: '${match['total_points'] ?? 0}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey[700],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
