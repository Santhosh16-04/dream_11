import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:clever_11/presentation/screens/contest/create_team_screen.dart';
import 'package:clever_11/routes/m11_routes.dart';
import 'package:clever_11/presentation/screens/contest/contest_full_view_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../cubit/team/team_bloc.dart';
import '../../../cubit/team/team_state.dart';
import '../../../cubit/team/team_event.dart';
import 'package:clever_11/presentation/screens/contest/select_team_screen.dart';

class ContestDetailsScreen extends StatefulWidget {
  final int initialTabIndex;
  const ContestDetailsScreen({Key? key, this.initialTabIndex = 0})
      : super(key: key);

  @override
  State<ContestDetailsScreen> createState() => _ContestDetailsScreenState();
}

class _ContestDetailsScreenState extends State<ContestDetailsScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? data;
  bool isLoading = true;
  TabController? _tabController;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
    // Load teams from local storage
    Future.microtask(() {
      final bloc = BlocProvider.of<TeamBloc>(context, listen: false);
      bloc.add(LoadTeams());
    });
    // Listen for tab changes to update FAB
    // _tabController?.addListener(_onTabChanged); // This line is removed as per the edit hint
  }

  void _onTabChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _tabController?.removeListener(_onTabChanged);
    _tabController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final String jsonString =
        await rootBundle.loadString('assets/json/contest_details.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    setState(() {
      data = jsonData;
      isLoading = false;
      // Dispose old controller if exists
      _tabController?.removeListener(_onTabChanged);
      _tabController?.dispose();
      _tabController = TabController(
          length: (data?['tabs']?.length ?? 1),
          vsync: this,
          initialIndex: widget.initialTabIndex);
      _tabController!.addListener(_onTabChanged);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || data == null || _tabController == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final match = data!['match'];
    final tabs = data!['tabs'] as List<dynamic>? ?? [];
    final filters = data!['filters'] as List<dynamic>? ?? [];
    final categories = data!['categories'] as List<dynamic>? ?? [];
    final floatingActions = data!['floating_actions'] as List<dynamic>? ?? [];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(90),
        child: AppBar(
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
                padding:
                    const EdgeInsets.only(left: 0, right: 0, top: 4, bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(Icons.wallet_membership,
                        color: Colors.white, size: 18),
                    Text(
                      '₹${match['balance']}',
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
          bottom: tabs.isNotEmpty
              ? PreferredSize(
                  preferredSize: Size.fromHeight(kToolbarHeight),
                  child: Container(
                    color: Colors.white, // White background for TabBar
                    child: SizedBox(
                      height:
                          36, // Reduced height (you can tweak this to 32, etc.)
                      child: TabBar(
                        controller: _tabController!,
                        indicatorColor: Colors.red,
                        labelColor: Colors.red,
                        unselectedLabelColor: Colors.black,
                        labelPadding: EdgeInsets.symmetric(
                            horizontal: 8.0), // Optional tighter padding
                        tabs: [
                          for (var tab in tabs)
                            Tab(
                              child: Text(
                                tab['title'] ?? '',
                                style:
                                    TextStyle(fontSize: 14), // Reduce font size
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                )
              : null,
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Only show filters if not on Teams tab
                if (filters.isNotEmpty && (_tabController!.index != 2))
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.sports_cricket, color: Colors.grey[600]),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 8),
                              height: 20,
                              width: 1,
                              color: Colors.grey[400],
                            ),
                          ],
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                ...filters.map(
                                  (f) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                            color: Colors.grey[300]!),
                                        foregroundColor: Colors.black,
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18),
                                        ),
                                        minimumSize: Size(0, 32),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12),
                                      ),
                                      onPressed: () {},
                                      child: Text(
                                        f['title'] ?? '',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.filter_alt_outlined,
                            color: Colors.grey[600]),
                      ],
                    ),
                  ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController!,
                    children: [
                      // Tab 0: Contests (existing content)
                      ListView.builder(
                        controller: _scrollController,
                        itemCount: categories.length,
                        itemBuilder: (context, catIdx) {
                          final cat = categories[catIdx];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (cat['title'] != null)
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 18, 16, 0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(cat['title'],
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16)),
                                          if (cat['subtitle'] != null)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 2.0),
                                              child: Text(cat['subtitle'],
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.grey[700])),
                                            ),
                                        ],
                                      ),
                                      if (cat['view_all'] == true)
                                        Row(
                                          children: [
                                            Text('View All',
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Icon(Icons.arrow_forward_ios,
                                                color: Colors.red, size: 14),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              if (cat['tag'] != null)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 16, top: 4),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.yellow[700],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(cat['tag'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12)),
                                  ),
                                ),
                              ...List.generate((cat['contests'] as List).length,
                                  (idx) {
                                final contest = cat['contests'][idx];
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16.0, right: 16, top: 8),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ContestFullViewScreen(),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Color(0xffffffff),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Color.fromARGB(
                                                255, 211, 211, 211)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            child: Column(
                                              children: [
                                                Container(
                                                  color: Color(0xffffffff),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              if (contest[
                                                                      'verified'] ==
                                                                  true)
                                                                Icon(
                                                                    Icons
                                                                        .verified,
                                                                    color: Colors
                                                                        .green,
                                                                    size: 14),
                                                              if (contest[
                                                                      'guaranteed'] ==
                                                                  true)
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              2.0),
                                                                  child: Text(
                                                                      'Guaranteed',
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                              13,
                                                                          color:
                                                                              Colors.black)),
                                                                ),
                                                              if (contest[
                                                                      'plus'] ==
                                                                  true)
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              4.0),
                                                                  child: Text(
                                                                      'plus',
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                              13,
                                                                          color:
                                                                              Colors.blue)),
                                                                ),
                                                            ],
                                                          ),
                                                          Text(
                                                              contest['prize'] ??
                                                                  '',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      20)),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          if (contest['original_entry'] !=
                                                                  null &&
                                                              contest['discounted_entry'] !=
                                                                  null)
                                                            Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                    '₹${contest['original_entry']}',
                                                                    style: TextStyle(
                                                                        decoration:
                                                                            TextDecoration
                                                                                .lineThrough,
                                                                        color: Colors
                                                                            .grey,
                                                                        fontSize:
                                                                            11)),
                                                                InkWell(
                                                                  onTap: () {
                                                                    Navigator
                                                                        .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                SelectTeamScreen(
                                                                          timeLeftMinutes:
                                                                              109, // Example: 1h 49m
                                                                          maxTeams:
                                                                              20,
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: const Color
                                                                          .fromARGB(
                                                                          255,
                                                                          0,
                                                                          153,
                                                                          5),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5),
                                                                    ),
                                                                    padding: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            24,
                                                                        vertical:
                                                                            4),
                                                                    child: Text(
                                                                        '₹${contest['discounted_entry']}',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight: FontWeight.bold)),
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          else if (contest[
                                                                  'entry'] !=
                                                              null)
                                                            Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    0,
                                                                    153,
                                                                    5),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5),
                                                              ),
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          12,
                                                                      vertical:
                                                                          4),
                                                              child: Text(
                                                                  '₹${contest['entry']}',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold)),
                                                            ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 16.0),
                                                  child: Row(
                                                    children: [
                                                      if (contest['spots_left'] !=
                                                              null &&
                                                          contest['total_spots'] !=
                                                              null)
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              buildProgressBar(
                                                                  contest[
                                                                      'spots_left'],
                                                                  contest[
                                                                      'total_spots']),
                                                            ],
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Container(
                                            decoration: BoxDecoration(
                                                color: Color.fromARGB(
                                                    244, 244, 244, 244),
                                                borderRadius: BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(5),
                                                    bottomRight:
                                                        Radius.circular(10))),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                children: [
                                                  if (contest['first_prize'] !=
                                                      null)
                                                    Row(
                                                      children: [
                                                        Icon(Icons.emoji_events,
                                                            color: Colors.amber,
                                                            size: 18),
                                                        SizedBox(width: 4),
                                                        Text(
                                                            '${contest['first_prize']}',
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                      ],
                                                    ),
                                                  if (contest[
                                                          'winning_percent'] !=
                                                      null)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 12.0),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                              Icons
                                                                  .emoji_events_outlined,
                                                              color:
                                                                  Colors.blue,
                                                              size: 18),
                                                          SizedBox(width: 4),
                                                          Text(
                                                              '${contest['winning_percent']}%',
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                        ],
                                                      ),
                                                    ),
                                                  if (contest['max_entries'] !=
                                                      null)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 12.0),
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.person_2,
                                                              color:
                                                                  Colors.grey,
                                                              size: 18),
                                                          SizedBox(width: 4),
                                                          Text(
                                                              'Upto ${contest['max_entries']}',
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                        ],
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          );
                        },
                      ),
                      // Tab 1: My Contests (placeholder)
                      Center(
                          child: Text(
                              'My Contests')), // You can replace with actual content
                      // Tab 2: Teams
                      BlocBuilder<TeamBloc, TeamState>(
                        builder: (context, state) {
                          if (state.teams.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "You haven't created a team yet!",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "The first step to winning starts here.",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  SizedBox(height: 32),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Color(0XFF00A203), // Green color
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: TextButton.icon(
                                      onPressed: () {
                                        Navigator.pushNamed(context,
                                            M11_AppRoutes.m11_team_create);
                                      },
                                      icon: Icon(Icons.add_circle,
                                          color: Colors.white, size: 20),
                                      label: Text(
                                        "CREATE A TEAM",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: state.teams.length,
                            itemBuilder: (context, idx) {
                              final team = state.teams[idx];
                              final players = List<Map<String, dynamic>>.from(
                                  team['players'] ?? []);
                              final team1 = players.isNotEmpty
                                  ? players.first['team']
                                  : 'T1';
                              final team2 = players.length > 1
                                  ? players[1]['team']
                                  : 'T2';
                              final team1Count = players
                                  .where((p) => p['team'] == team1)
                                  .length;
                              final team2Count = players
                                  .where((p) => p['team'] == team2)
                                  .length;
                              Map<String, dynamic>? captain = players
                                  .cast<Map<String, dynamic>?>()
                                  .firstWhere(
                                    (p) =>
                                        p != null &&
                                        p['id'] == team['captainId'],
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
                              final wkCount = players
                                  .where((p) => p['role'] == 'WK')
                                  .length;
                              final batCount = players
                                  .where((p) => p['role'] == 'BAT')
                                  .length;
                              final arCount = players
                                  .where((p) => p['role'] == 'AR')
                                  .length;
                              final bowlCount = players
                                  .where((p) => p['role'] == 'BOWL')
                                  .length;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Column(
                                  children: [
                                    // 🔺 Backup Info Banner
                                    /*  Container(
                                      margin: EdgeInsets.only(bottom: 6),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Color(0xFFFFEFEF),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.trending_up,
                                              color: Colors.green, size: 20),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: RichText(
                                              text: TextSpan(
                                                text: 'Add up to ',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 13),
                                                children: [
                                                  TextSpan(
                                                    text: '4 Backups ',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  TextSpan(text: 'in your team'),
                                                ],
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {},
                                            child: Row(
                                              children: [
                                                Text("Add",
                                                    style: TextStyle(
                                                        color: Colors.red)),
                                                Icon(Icons.chevron_right,
                                                    size: 16, color: Colors.red),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                 */
                                    // 🔷 White Card
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 8,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          // 🟩 Green Header
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Color(0xFF1B5E20),
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                      top: Radius.circular(16)),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 12),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        team['name'] ??
                                                            'SANDY C... (T1)',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                    IconButton(
                                                      icon: Icon(Icons.edit,
                                                          color: Colors.white),
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                M11_CreateTeamScreen(
                                                              key: UniqueKey(),
                                                              initialSelectedPlayerIds: players
                                                                  .map<int>((p) =>
                                                                      p['id']
                                                                          as int)
                                                                  .toSet(),
                                                              initialCaptainId:
                                                                  team[
                                                                      'captainId'],
                                                              initialViceCaptainId:
                                                                  team[
                                                                      'viceCaptainId'],
                                                              teamName:
                                                                  team['name'],
                                                              teamId:
                                                                  team['id'],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                    SizedBox(width: 10),
                                                    Icon(Icons.swap_vert,
                                                        color: Colors.white),
                                                    SizedBox(width: 10),
                                                    Icon(Icons.copy,
                                                        color: Colors.white),
                                                  ],
                                                ),
                                                SizedBox(height: 8),
                                                // 💠 Team 1 - Captain - ViceCaptain - Team 2
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Column(
                                                      children: [
                                                        Text(team1,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 13)),
                                                        Text('$team1Count',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                      ],
                                                    ),
                                                    // Captain
                                                    Column(
                                                      children: [
                                                        Stack(
                                                          clipBehavior:
                                                              Clip.none,
                                                          children: [
                                                            CircleAvatar(
                                                              backgroundImage:
                                                                  NetworkImage(
                                                                      captain![
                                                                          'image']),
                                                              radius: 27,
                                                            ),
                                                            Positioned(
                                                              top: -6,
                                                              left: -6,
                                                              child:
                                                                  CircleAvatar(
                                                                backgroundColor:
                                                                    Colors
                                                                        .white,
                                                                radius: 10,
                                                                child: Text('C',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            10,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: 4),
                                                        Text(captain['name'],
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 12)),
                                                      ],
                                                    ),
                                                    // Vice Captain
                                                    Column(
                                                      children: [
                                                        Stack(
                                                          clipBehavior:
                                                              Clip.none,
                                                          children: [
                                                            CircleAvatar(
                                                              backgroundImage:
                                                                  NetworkImage(
                                                                      viceCaptain![
                                                                          'image']),
                                                              radius: 27,
                                                            ),
                                                            Positioned(
                                                              top: -6,
                                                              left: -6,
                                                              child:
                                                                  CircleAvatar(
                                                                backgroundColor:
                                                                    Colors
                                                                        .white,
                                                                radius: 10,
                                                                child: Text(
                                                                    'VC',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            8,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: 4),
                                                        Text(
                                                            viceCaptain['name'],
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 12)),
                                                      ],
                                                    ),
                                                    Column(
                                                      children: [
                                                        Text(team2,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 13)),
                                                        Text('$team2Count',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          // 🔽 Role-wise Player Count
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 12),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                _playerTypeCount('WK', wkCount),
                                                _playerTypeCount(
                                                    'BAT', batCount),
                                                _playerTypeCount('AR', arCount),
                                                _playerTypeCount(
                                                    'BOWL', bowlCount),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: (_tabController!.index == 2)
          ? BlocBuilder<TeamBloc, TeamState>(
              builder: (context, state) {
                if (state.teams.length > 0) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                                context, M11_AppRoutes.m11_team_create);
                          },
                          icon: Icon(Icons.add_circle_outline,
                              color: Colors.white, size: 22),
                          label: Text(
                            'CREATE TEAM',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0D1B2A), // dark navy
                            shape: StadiumBorder(),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            elevation: 4,
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return SizedBox.shrink();
                }
              },
            )
          : (floatingActions.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 30.0),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 32),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 37, 37, 66),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildFloatingAction(floatingActions[0]),
                        Container(
                          width: 1,
                          height: 32,
                          color: Colors.white24,
                        ),
                        _buildFloatingAction(floatingActions[1]),
                      ],
                    ),
                  ),
                )
              : null),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildFloatingAction(dynamic action) {
    IconData iconData = Icons.help;
    if (action['icon'] == 'emoji_events') iconData = Icons.emoji_events;
    if (action['icon'] == 'add') iconData = Icons.add_circle_outline;

    return InkWell(
      onTap: () {
        if ((action['label'] ?? '').toString().toUpperCase() == 'CREATE TEAM') {
          Navigator.pushNamed(context, M11_AppRoutes.m11_team_create);
        } else {
          _showContestPopup(context);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.transparent, // Or use any background color
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iconData, color: Colors.white, size: 22),
            SizedBox(width: 4),
            Text(
              action['label'] ?? '',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContestPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /*    _buildModalRow(
                  icon: Icons.flash_on,
                  text: "Enter Quick Join Mode",
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate or perform action
                  },
                ),
                SizedBox(height: 16),
                _buildModalRow(
                  icon: Icons.add_circle_outline,
                  text: "Create A Contest",
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate or perform action
                  },
                ),
                SizedBox(height: 16),
                _buildModalRow(
                  icon: Icons.confirmation_number_outlined,
                  text: "Enter Contest Code",
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate or perform action
                  },
                ),
                SizedBox(height: 24), */
                Text(
                  "Contest Categories",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: data!['categories'].length,
                  itemBuilder: (context, index) {
                    final category = data!['categories'][index];
                    final contestCount = (category['contests'] as List).length;

                    return InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _scrollToCategory(index);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              category['title'] ?? '',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "$contestCount",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _scrollToCategory(int categoryIndex) {
    // Calculate the approximate position to scroll to
    // Each category has some padding and content, so we estimate the position
    double estimatedPosition = 0;

    // Add height for filters section
    estimatedPosition += 60; // Approximate height for filters

    // Calculate position based on previous categories
    for (int i = 0; i < categoryIndex; i++) {
      final category = data!['categories'][i];
      final contests = category['contests'] as List;

      // Add height for category header
      estimatedPosition += 80; // Title + subtitle + tag

      // Add height for each contest in this category
      estimatedPosition +=
          contests.length * 120; // Approximate height per contest
    }

    // Add height for the target category header
    estimatedPosition += 80;

    // Scroll to the calculated position
    _scrollController.animateTo(
      estimatedPosition,
      duration: Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildModalRow({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Icon(icon, color: Colors.black87, size: 24),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }

  Widget buildProgressBar(num spotsLeft, num totalSpots) {
    final double progress = totalSpots > 0
        ? (1 - (spotsLeft.toDouble() / totalSpots.toDouble()))
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${spotsLeft.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ",")} Left",
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                    fontSize: 12),
              ),
              Text(
                "${totalSpots.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ",")} Spots",
                style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                    fontSize: 12),
              ),
            ],
          ),
        ),
        SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              // Background (light red)
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.red[50],
                ),
              ),
              // Foreground (gradient progress)
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
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
    );
  }

  void _showContestCardPopup(BuildContext context, dynamic contest) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(contest['prize'] ?? 'Contest'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (contest['first_prize'] != null)
                Text('First Prize: ${contest['first_prize']}'),
              if (contest['entry'] != null) Text('Entry: ₹${contest['entry']}'),
              if (contest['discounted_entry'] != null)
                Text('Discounted Entry: ₹${contest['discounted_entry']}'),
              if (contest['spots_left'] != null &&
                  contest['total_spots'] != null)
                Text(
                    'Spots Left: ${contest['spots_left']} / ${contest['total_spots']}'),
              if (contest['winning_percent'] != null)
                Text('Winning %: ${contest['winning_percent']}%'),
              if (contest['max_entries'] != null)
                Text('Max Entries: ${contest['max_entries']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // You can add join logic here
              },
              child: Text('Join'),
            ),
          ],
        );
      },
    );
  }

  Widget _playerTypeCount(String type, int count) {
    return Row(
      children: [
        Text(type, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        SizedBox(width: 2),
        Text('$count',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
