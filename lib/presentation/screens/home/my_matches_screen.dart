import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:clever_11/presentation/widgets/network_image_loader.dart';

class MyMatchesScreen extends StatefulWidget {
  const MyMatchesScreen({super.key});

  @override
  State<MyMatchesScreen> createState() => _MyMatchesScreenState();
}

class _MyMatchesScreenState extends State<MyMatchesScreen> {
  List<dynamic> _matchesData = [];
  bool _isLoading = true;
  int _selectedSportIndex = 0;
  int _selectedStatusIndex = 0;

  final List<Map<String, dynamic>> _sportCategories = [
    {'name': 'All', 'icon': Icons.sports_cricket},
    {'name': 'Cricket', 'icon': Icons.sports_cricket},
  ];

  final List<String> _matchStatuses = ['Upcoming', 'Live', 'Completed'];

  @override
  void initState() {
    super.initState();
    _loadMatchesData();
  }

  Future<void> _loadMatchesData() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/json/my_matches.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      setState(() {
        _matchesData = jsonData['matches'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<dynamic> _getFilteredMatches() {
    if (_matchesData.isEmpty) return [];

    String selectedSport = _sportCategories[_selectedSportIndex]['name'];
    String selectedStatus = _matchStatuses[_selectedStatusIndex];

    return _matchesData.where((match) {
      bool sportMatch =
          selectedSport == 'All' || match['sport'] == selectedSport;
      bool statusMatch = match['status'] == selectedStatus;
      return sportMatch && statusMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.grey[900],
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.person, color: Colors.white),
            onPressed: () {
              // Navigate to profile
            },
          ),
          title: Text(
            'My Matches',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Sport Categories
                  Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _sportCategories.length,
                      itemBuilder: (context, index) {
                        final category = _sportCategories[index];
                        final isSelected = _selectedSportIndex == index;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedSportIndex = index;
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: 16),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.red[50]
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color:
                                    isSelected ? Colors.red : Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  category['icon'],
                                  size: 16,
                                  color: isSelected
                                      ? Colors.red
                                      : Colors.grey[600],
                                ),
                                SizedBox(width: 6),
                                Text(
                                  category['name'],
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.red
                                        : Colors.grey[600],
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Match Status Filters
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Container(
                      height: 40,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: _matchStatuses.asMap().entries.map((entry) {
                          final index = entry.key;
                          final status = entry.value;
                          final isSelected = _selectedStatusIndex == index;

                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedStatusIndex = index;
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.red[50]
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.red
                                          : Colors.grey[600],
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  // Matches List
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: _getFilteredMatches().length,
                      itemBuilder: (context, index) {
                        final match = _getFilteredMatches()[index];
                        return _buildMatchCard(match);
                      },
                    ),
                  ),
                ],
              ));
  }

  Widget _buildMatchCard(Map<String, dynamic> match) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Match Type and League
            Row(
              children: [
                Icon(
                  _getSportIcon(match['sport']),
                  size: 16,
                  color: Colors.grey[600],
                ),
                SizedBox(width: 6),
                Text(
                  '${match['match_type']} · ${match['league']}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            // Teams
            Row(
              children: [
                // Team 1
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _getTeamColor(match['team1']['name']),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            match['team1']['short_name'],
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              match['team1']['short_name'],
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              match['team1']['full_name'],
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // VS
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'vs',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // Team 2
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              match['team2']['short_name'],
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              match['team2']['full_name'],
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _getTeamColor(match['team2']['name']),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            match['team2']['short_name'],
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            // Match Info and User Participation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Match Date and Time
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      match['date'],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      match['time'],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                // Status or Time Left
                if (match['status'] == 'Upcoming')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        match['time_left'],
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      if (match['lineups_out'] == true)
                        Text(
                          'Lineups Out',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  )
                else if (match['status'] == 'Live')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        match['score'] ?? '',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'COMPLETED',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                      if (match['result'] != null)
                        Text(
                          match['result'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
              ],
            ),

            SizedBox(height: 8),

            // User Participation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${match['user_teams']} Team${match['user_teams'] > 1 ? 's' : ''} · ${match['user_contests']} Contest${match['user_contests'] > 1 ? 's' : ''}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Row(
                  children: [
                    if (match['winnings'] != null)
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Text(
                          '₹${match['winnings']}',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.notifications_outlined,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getSportIcon(String sport) {
    switch (sport.toLowerCase()) {
      case 'cricket':
        return Icons.sports_cricket;
      case 'football':
        return Icons.sports_soccer;
      case 'basketball':
        return Icons.sports_basketball;
      case 'tennis':
        return Icons.sports_tennis;
      case 'hockey':
        return Icons.sports_hockey;
      default:
        return Icons.sports_cricket;
    }
  }

  Color _getTeamColor(String teamName) {
    // Generate consistent colors based on team name
    final colors = [
      Colors.red[600]!,
      Colors.blue[600]!,
      Colors.green[600]!,
      Colors.orange[600]!,
      Colors.purple[600]!,
      Colors.teal[600]!,
      Colors.indigo[600]!,
      Colors.pink[600]!,
    ];

    int index = teamName.hashCode % colors.length;
    return colors[index.abs()];
  }
}
