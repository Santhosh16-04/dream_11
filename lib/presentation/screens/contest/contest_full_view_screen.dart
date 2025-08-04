import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:clever_11/presentation/screens/contest/select_team_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clever_11/cubit/team/team_bloc.dart';
import 'package:clever_11/routes/m11_routes.dart';

class ContestFullViewScreen extends StatefulWidget {
  const ContestFullViewScreen({Key? key}) : super(key: key);

  @override
  State<ContestFullViewScreen> createState() => _ContestFullViewScreenState();
}

class _ContestFullViewScreenState extends State<ContestFullViewScreen>
    with TickerProviderStateMixin {
  Map<String, dynamic>? data;
  bool isLoading = true;
  late TabController _tabController;
  late TabController _subTabController;
  int selectedSubTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final String jsonString =
        await rootBundle.loadString('assets/json/contest_full_view.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    setState(() {
      data = jsonData;
      isLoading = false;
      _tabController = TabController(length: data!["tabs"].length, vsync: this);
      _subTabController =
          TabController(length: data!["sub_tabs"].length, vsync: this);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _subTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || data == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final match = data!["match"];
    final contest = data!["contest"];
    final tabs = data!["tabs"];
    final subTabs = data!["sub_tabs"];
    final winnings = data!["winnings"];
    final leaderboard = data!["leaderboard"];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF003FB4),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${match['team1']} v ${match['team2']}',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: 2),
            Text(
              match['time_left'] ?? '',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        actions: [
          Container(
            width: 100,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.white24),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(Icons.wallet_membership, color: Colors.white, size: 18),
                  Text(
                    '₹${match['wallet_balance']}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.add_circle_outline,
                      color: Colors.greenAccent, size: 20),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Contest Info Row
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      // Guaranteed + Prize Pool
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (contest['guaranteed'] == true)
                                  Icon(Icons.verified,
                                      color: Colors.green, size: 18),
                                if (contest['plus'] == true)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4.0),
                                    child: Text('plus',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Colors.blue)),
                                  ),
                                SizedBox(width: 4),
                                Text('Prize Pool',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13)),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(contest['prize_pool'],
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20)),
                          ],
                        ),
                      ),
                      // Max Prize Pool
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(Icons.stacked_line_chart,
                                    color: Colors.deepPurple, size: 18),
                                SizedBox(width: 4),
                                Text('Max Prize Pool',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13)),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(contest['max_prize_pool'],
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Progress Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            '${contest['spots_left'].toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ",")} Left',
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                                fontSize: 12),
                          ),
                          Spacer(),
                          Text(
                            '${contest['total_spots'].toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ",")} Spots',
                            style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                                fontSize: 12),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          children: [
                            Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                              ),
                            ),
                            FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: (contest['total_spots'] != null &&
                                      contest['spots_left'] != null &&
                                      contest['total_spots'] > 0)
                                  ? (1 -
                                      ((contest['spots_left'] as num)
                                              .toDouble() /
                                          (contest['total_spots'] as num)
                                              .toDouble()))
                                  : 0.0,
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color.fromARGB(255, 255, 157, 157),
                                      const Color.fromARGB(255, 181, 12, 12)!
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Join Button
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 8),
                      ),
                      onPressed: () {
                        // Check team count and navigate accordingly
                        final teamState = context.read<TeamBloc>().state;
                        if (teamState.teams.length == 1) {
                          // If only one team, go directly to payment
                          Navigator.pushNamed(
                            context,
                            M11_AppRoutes.c11_main_payment,
                            arguments: {
                              'contestId':
                                  contest['id']?.toString() ?? 'default',
                              'contestData': contest,
                            },
                          );
                        } else {
                          // If multiple teams, go to select team screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SelectTeamScreen(
                                timeLeftMinutes: 109,
                                maxTeams: 20,
                                contestData: contest,
                                contestId:
                                    contest['id']?.toString() ?? 'default',
                              ),
                            ),
                          );
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('JOIN ',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                          if (contest['original_entry'] != null)
                            Text('₹${contest['original_entry']}',
                                style: TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.white70,
                                    fontSize: 16)),
                          SizedBox(width: 8),
                          Text('₹${contest['discounted_entry']}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                        ],
                      ),
                    ),
                  ),
                ),
                // Info Row
                Container(
                  decoration:
                      BoxDecoration(color: Color.fromARGB(255, 245, 253, 255)),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.emoji_events, color: Colors.amber, size: 18),
                      SizedBox(width: 4),
                      Text('${contest['first_prize']}',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(width: 16),
                      Icon(Icons.emoji_events_outlined,
                          color: Colors.blue, size: 18),
                      SizedBox(width: 4),
                      Text('${contest['winning_percent']}%',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(width: 16),
                      Icon(Icons.person_2, color: Colors.grey, size: 18),
                      SizedBox(width: 4),
                      Text('M ${contest['max_members']}',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Spacer(),
                      Icon(Icons.stacked_line_chart,
                          color: Colors.deepPurple, size: 18),
                      SizedBox(width: 4),
                      Text('${contest['max_pool']}',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                // Tabs
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.red,
                  labelColor: Colors.red,
                  unselectedLabelColor: Colors.black,
                  tabs: [
                    for (var tab in tabs)
                      Tab(
                          child: Text(tab['title'],
                              style: TextStyle(fontSize: 15))),
                  ],
                ),
                buildBreakupToggle(
                  selectedIndex: selectedSubTabIndex,
                  onTabSelected: (index) {
                    setState(() {
                      selectedSubTabIndex = index;
                    });
                  },
                ),

                // TabBarView for winnings/leaderboard
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Winnings Tab
                      TabBarView(
                        controller: _subTabController,
                        children: [
                          // Guaranteed Breakup
                          ListView.builder(
                            itemCount: winnings['guaranteed_breakup'].length,
                            itemBuilder: (context, idx) {
                              final item = winnings['guaranteed_breakup'][idx];
                              return ListTile(
                                leading: Text('#${item['rank']}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                title: Text(item['winnings'],
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500)),
                              );
                            },
                          ),
                          // Maximum Breakup
                          ListView.builder(
                            itemCount: winnings['maximum_breakup'].length,
                            itemBuilder: (context, idx) {
                              final item = winnings['maximum_breakup'][idx];
                              return ListTile(
                                leading: Text('#${item['rank']}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                title: Text(item['winnings'],
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500)),
                              );
                            },
                          ),
                        ],
                      ),
                      // Leaderboard Tab
                      ListView.builder(
                        itemCount: leaderboard.length,
                        itemBuilder: (context, idx) {
                          final item = leaderboard[idx];
                          return ListTile(
                            leading: Text('#${item['rank']}',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            title: Text(item['user'],
                                style: TextStyle(fontWeight: FontWeight.w500)),
                            trailing: Text('${item['points']} pts',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget buildBreakupToggle({
    required int selectedIndex,
    required Function(int) onTabSelected,
  }) {
    return Container(
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Color(0xFFF1F3F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Guaranteed Breakup
          Expanded(
            child: InkWell(
              onTap: () => onTabSelected(0),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selectedIndex == 0 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: selectedIndex == 0
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          )
                        ]
                      : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  "Guaranteed Breakup",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        selectedIndex == 0 ? FontWeight.w600 : FontWeight.w500,
                    color: selectedIndex == 0 ? Colors.red : Colors.black87,
                  ),
                ),
              ),
            ),
          ),
          // Maximum Breakup
          Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(1),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selectedIndex == 1 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: selectedIndex == 1
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          )
                        ]
                      : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  "Maximum Breakup",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        selectedIndex == 1 ? FontWeight.w600 : FontWeight.w500,
                    color: selectedIndex == 1 ? Colors.red : Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
