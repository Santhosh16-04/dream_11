import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:clever_11/presentation/widgets/network_image_loader.dart';
import 'package:clever_11/routes/m11_routes.dart';
import 'package:clever_11/presentation/screens/contest/contest_details_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';

class M11_Home extends StatefulWidget {
  const M11_Home({super.key});

  @override
  State<M11_Home> createState() => _M11_HomeState();
}

class _M11_HomeState extends State<M11_Home> {
  int _selectedIndex = 0;
  List<dynamic> _homeTemplates = [];
  bool _isLoading = true;
  int _selectedCategoryTab = 0;
  String _selectedSportsCategory = 'Cricket';
  String _selectedContestType = 'Recommended';
  int _selectedSpecialCategoryTab = 0;
  String _selectedSpecialCategory = '';
  bool _showSpecialContestRow = false;
  PageController? _sliderController;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _loadHomeTemplates();
  }

  @override
  void dispose() {
    super.dispose();
    _sliderController?.dispose();
    _autoPlayTimer?.cancel();
  }

  Future<void> _loadHomeTemplates() async {
    final String jsonString =
        await rootBundle.loadString('assets/json/home_templates.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    setState(() {
      _homeTemplates = jsonData;
      _isLoading = false;
    });
  }

  void _startAutoPlay(dynamic options) {
    final autoPlay = options['autoPlay']?.toString().toLowerCase() == 'true';
    final interval = _parseInt(options['autoPlayInterval'] ?? '3');

    if (autoPlay && interval > 0) {
      _autoPlayTimer?.cancel();
      _autoPlayTimer = Timer.periodic(Duration(seconds: interval), (timer) {
        if (_sliderController != null && _sliderController!.hasClients) {
          final currentPage = _sliderController!.page?.round() ?? 0;
          final nextPage = (currentPage + 1) %
              _homeTemplates
                  .firstWhere((t) => t['type'] == 'templateSlider',
                      orElse: () => {'items': []})['items']
                  .length;
          _sliderController!.animateToPage(
            nextPage.toInt(),
            duration: Duration(
                milliseconds:
                    _parseInt(options['autoPlayAnimationDuration'] ?? '800')),
            curve: _parseCurve(options['autoPlayCurve'] ?? 'fastOutSlowIn'),
          );
        }
      });
    }
  }

  Curve _parseCurve(String curveString) {
    switch (curveString.toLowerCase()) {
      case 'fastoutslowin':
        return Curves.fastOutSlowIn;
      case 'ease':
        return Curves.ease;
      case 'easein':
        return Curves.easeIn;
      case 'easeout':
        return Curves.easeOut;
      case 'linear':
        return Curves.linear;
      default:
        return Curves.fastOutSlowIn;
    }
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      // Navigate to My Matches screen
      Navigator.pushNamed(context, M11_AppRoutes.my_matches);
    } else if (index == 2) {
      // Navigate to profile screen with personal data
      final personalData = _homeTemplates
          .firstWhere((t) => t['type'] == 'personal_data', orElse: () => {});
      Navigator.pushNamed(context, '/m11_profile', arguments: personalData);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _onSpecialCategoryChanged(int index, String specialCategory) {
    setState(() {
      if (_selectedSpecialCategoryTab == index && _showSpecialContestRow) {
        _showSpecialContestRow = false;
        _selectedSpecialCategory = '';
      } else {
        _selectedSpecialCategoryTab = index;
        _selectedSpecialCategory = specialCategory;
        _showSpecialContestRow = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF003FB4),
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Color(0xFF003FB4)),
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Image.asset('assets/images/m1_logo_text.png', scale: 2.0),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.account_balance_wallet_outlined,
                color: Colors.white),
            onPressed: () {
              // Navigate to payment screen for wallet functionality
              Navigator.pushNamed(
                context,
                M11_AppRoutes.c11_main_payment,
                arguments: {
                  'contestId': 'wallet_add_cash',
                  'contestData': {
                    'title': 'Add Cash to Wallet',
                    'description':
                        'Add money to your wallet for contest participation',
                    'amount': '0',
                  },
                },
              );
            },
          ),
        ],
      ),
      drawer: _buildDynamicDrawer(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _buildBody(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAnimatedNavItem(0, Icons.home, 'Home'),
                _buildAnimatedNavItem(
                    1, Icons.emoji_events_outlined, 'My Matches'),
                _buildAnimatedNavItem(2, Icons.person_outline, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    List<Widget> widgets = [];
    bool contestFilterAdded = false;
    for (var template in _homeTemplates) {
      if (template['type'] == 'templateSlider') {
        widgets.add(_buildDynamicSlider(template));
      } else if (template['type'] == 'templateCategoryTabs') {
        widgets.add(_buildDynamicTabs(template));
      } else if (template['type'] == 'templateSpecialCategoryTabs') {
        widgets.add(_buildDynamicSpecialCategories(template));
        if (_showSpecialContestRow) {
          final specialContestWidget = _buildSpecialContestRow();
          if (specialContestWidget != null) {
            widgets.add(specialContestWidget);
          }
        }
      } else if (template['type'] == 'templateContestType' &&
          !contestFilterAdded) {
        widgets.add(_buildContestFilters());
        contestFilterAdded = true;
      }
    }
    // Filter and show only contests based on selected category and contest type
    final filteredContests = _getFilteredContests(
      sportsCategory: _selectedSportsCategory,
      contestType: _selectedContestType,
    );

    if (filteredContests.isEmpty) {
      // Show "No Contest" UI when no contests are available
      widgets.add(_buildNoContestUI());
    } else {
      // Show available contests
      for (var contest in filteredContests) {
        widgets.add(GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ContestDetailsScreen(initialTabIndex: 0)),
            );
          },
          child: _buildMatchCard(
            league: contest['league_name'] ?? '',
            team1: contest['team_code1_text'] ?? '',
            team1FullName: contest['team_text1'] ?? '',
            team2: contest['team_code2_text'] ?? '',
            team2FullName: contest['team_text2'] ?? '',
            time: contest['live_text'] ?? contest['live_text1'] ?? '',
            prize: contest['prize_text'] ?? contest['prize_text1'] ?? '',
            favorites: null, // You can add favorites if available in JSON
            isLive: false, // You can set this based on your logic
            liveText: contest['live_text'] ?? contest['live_text1'] ?? '',
            contestJson: contest,
          ),
        ));
      }
    }

    return Container(
      color: Color(0xFFF5F5F5),
      child: ListView(
        children: widgets,
      ),
    );
  }

  Widget _buildDynamicSlider(dynamic template) {
    final items = template['items'] as List<dynamic>;
    final options = template['options']?[0] ?? {};

    // Initialize controller if not exists
    if (_sliderController == null) {
      _sliderController = PageController(
        viewportFraction: _parseDouble(options['viewportFraction'] ?? '0.8'),
        initialPage: _parseInt(options['initialPage'] ?? '0'),
      );
      // Start auto-play after widget is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startAutoPlay(options);
      });
    }

    return Container(
      height: _parseDouble(options['height'] ?? '100'),
      color: _parseColor(options['backgroundColor'] ?? '0xFF003FB4'),
      margin: _parseEdgeInsets(options['margin'] ?? '0'),
      padding: _parseEdgeInsets(options['padding'] ?? '0'),
      child: Center(
        child: SizedBox(
          height: _parseDouble(options['height'] ?? '100'),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: PageView.builder(
              controller: _sliderController,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                        _parseDouble(options['borderRadius'] ?? '10')),
                    child: NetworkImageWithLoader(
                      imageUrl: item['url'] ?? '',
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicTabs(dynamic template) {
    final items = template['items'] as List<dynamic>;
    final options = template['options']?[0] ?? {};
    final selectedColor =
        _parseColor(options['selectedLabelColor'] ?? '0xFFD62A23');
    final unselectedColor =
        _parseColor(options['unselectedLabelColor'] ?? '0xFF000000');
    final indicatorColor =
        _parseColor(options['indicatorColor'] ?? '0xFFD62A23');
    final indicatorWeight = _parseDouble(options['indicatorWeight'] ?? '4.0');
    final tabHeight = _parseDouble(options['height'] ?? '50');

    return Container(
      height: tabHeight < 40 ? 48 : tabHeight, // Ensure enough height
      color: _parseColor(options['backgroundColor'] ?? '0xFFFFFFFF'),
      margin: _parseEdgeInsets(options['margin'] ?? '0'),
      padding: _parseEdgeInsets(options['padding'] ?? '0'),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = _selectedCategoryTab == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryTab = index;
                _selectedSportsCategory = item['sports_category'] ?? 'Cricket';
                _selectedContestType =
                    'Recommended'; // Reset to default when category changes
                _selectedSpecialCategoryTab = 0;
                _selectedSpecialCategory = '';
                _showSpecialContestRow = false;
              });
            },
            child: Container(
              constraints: BoxConstraints(minHeight: 48),
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: isSelected
                  ? BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: indicatorColor,
                          width: indicatorWeight,
                        ),
                      ),
                    )
                  : null,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      item['url'] != null && item['url'] != ''
                          ? NetworkImageWithLoader(
                              imageUrl: item['url'],
                              width: _parseDouble(item['icon_size'] ?? '20'),
                              height: _parseDouble(item['icon_size'] ?? '20'),
                            )
                          : Icon(
                              Icons.sports_cricket,
                              size: _parseDouble(item['icon_size'] ?? '20'),
                              color:
                                  isSelected ? indicatorColor : unselectedColor,
                            ),
                      Padding(
                        padding: const EdgeInsets.only(left: 6.0),
                        child: Text(
                          item['text'] ?? '',
                          style: TextStyle(
                            fontSize:
                                _parseDouble(options['labelSize'] ?? '14'),
                            fontWeight: _parseFontWeight(item['textWeight'] ??
                                options['labelWeight'] ??
                                'normal'),
                            color:
                                isSelected ? indicatorColor : unselectedColor,
                            fontFamily: isSelected ? 'Roboto' : null,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDynamicSpecialCategories(dynamic template) {
    final allItems = template['items'] as List<dynamic>;
    final items = allItems
        .where((item) => item['sports_category'] == _selectedSportsCategory)
        .toList();
    if (items.isEmpty) return SizedBox.shrink();
    final options = template['options']?[0] ?? {};

    return Container(
      height: _parseDouble(options['height'] ?? '50'),
      padding: _parseEdgeInsets(options['padding'] ?? '8.0'),
      color: _parseColor(options['backgroundColor'] ?? '0xFFF5F5F5'),
      margin: _parseEdgeInsets(options['margin'] ?? '0'),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected =
              _selectedSpecialCategoryTab == index && _showSpecialContestRow;
          return GestureDetector(
            onTap: () {
              _onSpecialCategoryChanged(index, item['special_category'] ?? '');
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white
                    : _parseColor(options['color'] ?? '0xFFFFFFFF'),
                borderRadius: BorderRadius.circular(
                    _parseDouble(options['borderRadius'] ?? '20')),
                border: Border.all(
                  color: isSelected
                      ? Color(0xFF000000)
                      : _parseColor(options['borderColor'] ?? '0xFFCCCCCC'),
                  width: _parseDouble(options['borderWidth'] ?? '1'),
                ),
              ),
              child: Center(
                child: Text(
                  item['text'] ?? '',
                  style: TextStyle(
                    color: _parseColor(item['text_color'] ?? '0xFF000000'),
                    fontWeight:
                        _parseFontWeight(item['textWeight'] ?? 'normal'),
                    fontSize: _parseDouble(item['text_size'] ?? '14'),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget? _buildSpecialContestRow() {
    final specialContestTemplate = _homeTemplates.firstWhere(
      (t) => t['type'] == 'templateSpecialContest',
      orElse: () => null,
    );
    if (specialContestTemplate == null ||
        specialContestTemplate['items'] == null) return null;
    final items = (specialContestTemplate['items'] as List<dynamic>)
        .where((item) =>
            item['sports_category'] == _selectedSportsCategory &&
            item['special_category'] == _selectedSpecialCategory)
        .toList();
    if (items.isEmpty) return null;

    final options = specialContestTemplate['options']?[0] ?? {};
    final cardHeight = _parseDouble(options['cardHeight'] ?? '140');
    final cardWidth = _parseDouble(options['cardWidth'] ?? '320');
    final cardBorderRadius = _parseDouble(options['cardBorderRadius'] ?? '12');
    final cardColor = _parseColor(options['cardColor'] ?? '0xFFFFFFFF');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      _selectedSpecialCategory,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Icon(Icons.arrow_forward_ios,
                        size: 14, color: Colors.grey[600]),
                  ],
                ),
              ),
              Icon(Icons.notifications_none_outlined, color: Colors.grey[600]),
            ],
          ),
        ),
        SizedBox(
          height: cardHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildSpecialContestCard(item, options);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialContestCard(dynamic item, dynamic options) {
    final cardWidth = _parseDouble(options['cardWidth'] ?? '320');
    final cardBorderRadius = _parseDouble(options['cardBorderRadius'] ?? '12');
    final cardColor = _parseColor(options['cardColor'] ?? '0xFFFFFFFF');
    final prize = item['prize'] ?? item['prize_text'] ?? '';
    final team1Logo = item['team1_logo'] ?? '';
    final team2Logo = item['team2_logo'] ?? '';
    final team1Code = item['team1_name'] ?? '';
    final team2Code = item['team2_name'] ?? '';
    final team1Full = item['team1_full_name'] ?? '';
    final team2Full = item['team2_full_name'] ?? '';
    final matchTime = item['start_time'] ?? '';
    final matchStatus = item['remaining_time'] ?? '';
    final isTimeUp = matchStatus.toLowerCase().contains("time's up");

    return Container(
      width: cardWidth,
      margin: EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(cardBorderRadius),
        border: Border.all(color: Color.fromARGB(255, 211, 211, 211)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 239, 248, 255), // Light Blue
                    Color.fromARGB(255, 255, 243, 241), // Slightly deeper Blue
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        team1Logo.isNotEmpty
                            ? ClipOval(
                                child: NetworkImageWithLoader(
                                  imageUrl: team1Logo,
                                  width: 32,
                                  height: 32,
                                  backgroundColor: Colors.grey[200],
                                ),
                              )
                            : CircleAvatar(
                                backgroundColor: Colors.grey[200],
                                radius: 16,
                              ),
                        SizedBox(width: 8),
                        Text(team1Code,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(width: 4),
                        Text('v',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.grey[600])),
                        SizedBox(width: 4),
                        Text(team2Code,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(width: 8),
                        team2Logo.isNotEmpty
                            ? ClipOval(
                                child: NetworkImageWithLoader(
                                  imageUrl: team2Logo,
                                  width: 32,
                                  height: 32,
                                  backgroundColor: Colors.grey[200],
                                ),
                              )
                            : CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.grey[200],
                              ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      '$team1Full / $team2Full',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 6),
                    Divider(height: 1, color: Colors.grey[300]),
                    SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.access_time,
                            size: 16,
                            color: isTimeUp
                                ? Color(0xFFD62A23)
                                : Colors.grey[700]),
                        SizedBox(width: 4),
                        Text(
                          matchStatus.isNotEmpty ? matchStatus : matchTime,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                isTimeUp ? Color(0xFFD62A23) : Colors.grey[800],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.0, bottom: 8),
            child: Row(
              children: [
                Icon(Icons.monetization_on, color: Color(0xFFD62A23), size: 18),
                SizedBox(width: 4),
                Text(
                  prize,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFFD62A23),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContestFilters() {
    // Get contest types for the selected sports category
    final contestTypeTemplate = _homeTemplates.firstWhere(
      (t) => t['type'] == 'templateContestType',
      orElse: () => null,
    );

    List<String> filters = ['Recommended', 'Start Soon'];
    if (contestTypeTemplate != null && contestTypeTemplate['items'] != null) {
      final seen = <String, String>{};
      for (var item in (contestTypeTemplate['items'] as List<dynamic>)) {
        if (item['sports_category'] == _selectedSportsCategory &&
            item['contest_type'] != null) {
          final key = item['contest_type'].toString().trim().toLowerCase();
          if (!seen.containsKey(key)) {
            seen[key] = item['contest_type'];
          }
        }
      }
      if (seen.isNotEmpty) {
        filters = seen.values.toList();
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: filters.map((filter) {
          final isSelected = filter == _selectedContestType;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedContestType = filter;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0, top: 8),
              child: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Color(0xFFD62A23) : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMatchCard({
    required String league,
    required String team1,
    required String team1FullName,
    required String team2,
    required String team2FullName,
    required String time,
    required String prize,
    String? favorites,
    required bool isLive,
    String? liveText,
    Map<String, dynamic>? contestJson,
  }) {
    // Get options from templateContest
    final contestTemplate = _homeTemplates.firstWhere(
      (t) => t['type'] == 'templateContest',
      orElse: () => null,
    );
    final options = contestTemplate?['options']?[0] ?? {};
    final liveTextColor = _parseColor(contestJson?['live_text_color'] ??
        contestJson?['live_text1_color'] ??
        '0xFFD62A23');

    // Extract team icon URLs from contest data
    final team1IconUrl = contestJson?['team_icon1_url'] ?? '';
    final team2IconUrl = contestJson?['team_icon2_url'] ?? '';

    return Container(
      margin: EdgeInsets.fromLTRB(12, 4, 12, 8),
      decoration: BoxDecoration(
        color: _parseColor(options['cardColor'] ?? '0xFFFFFFFF'),
        borderRadius: BorderRadius.circular(
            _parseDouble(options['cardBorderRadius'] ?? '8')),
        border: Border.all(color: Color.fromARGB(255, 211, 211, 211)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 0),
            child: Row(
              children: [
                Text(
                  league,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: _parseFontWeight(
                        options['league_textWeight'] ?? 'normal'),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 239, 248, 255), // Light Blue
                  Color.fromARGB(255, 255, 243, 241), // Slightly deeper Blue
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  // Start: Team names column
                  Flexible(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _teamInfo(team1, team1FullName,
                            teamIconUrl: team1IconUrl),
                        SizedBox(height: 4),
                        _teamInfo(team2, team2FullName,
                            teamIconUrl: team2IconUrl),
                      ],
                    ),
                  ),

                  // Center: Vertical Divider
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.grey.shade400,
                    margin: EdgeInsets.symmetric(horizontal: 8),
                  ),

                  // End: Live/Time column
                  Flexible(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (isLive)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: liveTextColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              liveText ?? 'Live',
                              style: TextStyle(
                                color: liveTextColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        SizedBox(height: 4),
                        Text(
                          time.split('\n').join(' '),
                          style: TextStyle(
                            fontSize: 12,
                            color: isLive ? liveTextColor : Colors.black,
                          ),
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.shield, color: Colors.green[800], size: 18),
                    SizedBox(width: 4),
                    Text(prize,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize:
                              _parseDouble(options['prize_text_size'] ?? '14'),
                          color: _parseColor(
                              options['prize_text_color'] ?? '0xFF000000'),
                        )),
                    if (favorites != null) ...[
                      SizedBox(width: 12),
                      Icon(Icons.star_border,
                          color: Colors.blueAccent, size: 18),
                      SizedBox(width: 4),
                      Text(favorites,
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[700])),
                    ]
                  ],
                ),
                Icon(Icons.notifications_none_outlined,
                    color: Colors.grey[600]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _teamInfo(String teamCode, String teamName, {String? teamIconUrl}) {
    return Row(
      children: [
        teamIconUrl != null && teamIconUrl.isNotEmpty
            ? ClipOval(
                child: NetworkImageWithLoader(
                  imageUrl: teamIconUrl,
                  width: 28,
                  height: 28,
                  backgroundColor: Colors.grey[300],
                ),
              )
            : CircleAvatar(
                radius: 14,
                backgroundColor: Colors.grey[300],
              ),
        SizedBox(width: 8),
        Flexible(
          child: Row(
            children: [
              Text(
                teamCode,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: _parseColor('0xFF000000'),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Text(
                    teamName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper methods to parse JSON values
  Color _parseColor(dynamic colorValue) {
    String colorString = colorValue.toString();
    if (colorString.startsWith('0x')) {
      return Color(int.parse(colorString));
    } else if (colorString.startsWith('#')) {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    }
    return Colors.black;
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    try {
      return double.parse(value.toString());
    } catch (e) {
      return 0.0;
    }
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    try {
      return int.parse(value.toString());
    } catch (e) {
      return 0;
    }
  }

  FontWeight _parseFontWeight(dynamic weight) {
    if (weight == null) return FontWeight.normal;
    String weightString = weight.toString().toLowerCase();
    switch (weightString) {
      case 'bold':
        return FontWeight.bold;
      case 'normal':
        return FontWeight.normal;
      case 'w100':
        return FontWeight.w100;
      case 'w200':
        return FontWeight.w200;
      case 'w300':
        return FontWeight.w300;
      case 'w400':
        return FontWeight.w400;
      case 'w500':
        return FontWeight.w500;
      case 'w600':
        return FontWeight.w600;
      case 'w700':
        return FontWeight.w700;
      case 'w800':
        return FontWeight.w800;
      case 'w900':
        return FontWeight.w900;
      default:
        return FontWeight.normal;
    }
  }

  EdgeInsets _parseEdgeInsets(dynamic value) {
    if (value == null) return EdgeInsets.zero;
    try {
      if (value is int) {
        return EdgeInsets.all(value.toDouble());
      }
      if (value is double) {
        return EdgeInsets.all(value);
      }
      final doubleValue = double.parse(value.toString());
      return EdgeInsets.all(doubleValue);
    } catch (e) {
      return EdgeInsets.zero;
    }
  }

  bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    return false;
  }

  // Add this function to filter contests by sports_category and contest_type
  List<dynamic> _getFilteredContests({
    required String sportsCategory,
    required String contestType,
  }) {
    final contestTemplate = _homeTemplates.firstWhere(
      (t) => t['type'] == 'templateContest',
      orElse: () => null,
    );
    if (contestTemplate == null || contestTemplate['items'] == null) return [];
    return (contestTemplate['items'] as List<dynamic>).where((item) {
      return item['sports_category'] == sportsCategory &&
          item['contest_type'] == contestType;
    }).toList();
  }

  Widget _buildNoContestUI() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFF5F5F5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.sports_soccer,
              size: 48,
              color: Color(0xFFD62A23),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'No Contests Available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'No ${_selectedContestType} contests found for ${_selectedSportsCategory}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Color(0xFFD62A23).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Try selecting a different category or contest type',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFFD62A23),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildInfoChip('Check back later', Icons.schedule),
              _buildInfoChip('Try other sports', Icons.sports),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicDrawer() {
    final drawerData = _homeTemplates.firstWhere(
      (t) => t['type'] == 'drawer',
      orElse: () => null,
    );
    if (drawerData == null) return SizedBox.shrink();

    final user = drawerData['user'] ?? {};
    final singleMenus = drawerData['single_menus'] as List<dynamic>? ?? [];
    final groupMenus = drawerData['group_menus'] as List<dynamic>? ?? [];
    final moreApps = drawerData['more_apps'] as List<dynamic>? ?? [];
    final appVersion = drawerData['app_version'] ?? '';

    return Drawer(
      child: Container(
        color: Color.fromARGB(255, 243, 243, 243),
        child: Column(
          children: [
            // Top Black Section - Fixed height
            GestureDetector(
              onTap: () {
                final personalData = _homeTemplates.firstWhere(
                    (t) => t['type'] == 'personal_data',
                    orElse: () => {});
                Navigator.pushNamed(
                  context,
                  M11_AppRoutes.m11_profile,
                  arguments: personalData,
                );
              },
              child: Container(
                color: Color(0xFF003FB4),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Padding(
                  padding: const EdgeInsets.only(top: 32.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        child: ClipOval(
                          child: user['profile_image'] != null
                              ? NetworkImageWithLoader(
                                  imageUrl: user['profile_image'],
                                  width: 56,
                                  height: 56,
                                  backgroundColor: Colors.white,
                                )
                              : Container(
                                  width: 56,
                                  height: 56,
                                  color: Colors.white,
                                  child: Icon(Icons.person,
                                      size: 28, color: Colors.grey),
                                ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    user['user_name'] ?? '',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios,
                                    color: Colors.white, size: 18),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Text('Skill Score: ',
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 13)),
                                Icon(Icons.lock, color: Colors.white, size: 15),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Balance Card - Fixed height
            Container(
              color: Color.fromARGB(255, 243, 243, 243),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            user['wallet_icon'] != null
                                ? NetworkImageWithLoader(
                                    imageUrl: user['wallet_icon'],
                                    width: 24,
                                    height: 24,
                                  )
                                : Icon(Icons.account_balance_wallet, size: 24),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text('My Balance',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500)),
                            ),
                            Text('₹${user['balance'] ?? '0'}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFEAF7EA),
                              foregroundColor: Color(0xFF1BA345),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text('ADD CASH',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Scrollable Menus Section - Takes remaining space
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ...singleMenus.map((menu) => Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 4),
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                            color: Colors.white,
                            child: ListTile(
                              leading: menu['icon'] != null
                                  ? NetworkImageWithLoader(
                                      imageUrl: menu['icon'],
                                      width: 24,
                                      height: 24,
                                    )
                                  : null,
                              title: Text(menu['title'] ?? '',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w500)),
                              onTap: () {},
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 0),
                              dense: true,
                            ),
                          ),
                        )),
                    // Group Menus in a single card with dividers
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8),
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                        color: Colors.white,
                        child: Column(
                          children: [
                            for (int i = 0; i < groupMenus.length; i++) ...[
                              ListTile(
                                leading: groupMenus[i]['icon'] != null
                                    ? NetworkImageWithLoader(
                                        imageUrl: groupMenus[i]['icon'],
                                        width: 24,
                                        height: 24,
                                      )
                                    : null,
                                title: Text(groupMenus[i]['title'] ?? '',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500)),
                                onTap: () {},
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 0),
                                dense: true,
                              ),
                              if (i != groupMenus.length - 1)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0),
                                  child: Divider(height: 1),
                                ),
                            ]
                          ],
                        ),
                      ),
                    ),
                    // App Version at the bottom
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('App Version: $appVersion',
                          style: TextStyle(color: Colors.grey)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: Icon(
                icon,
                size: isSelected ? 28 : 24,
                color: isSelected ? Color(0xFFD62A23) : Colors.grey[600],
              ),
            ),
            SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: isSelected ? 13 : 12,
                color: isSelected ? Color(0xFFD62A23) : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
