import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jamas/auth/Signup.dart';
import 'package:jamas/core/initializer.dart';

// Data Models
class User {
  final String name;
  final String email;
  final String avatar;
  final double walletBalance;
  final int rewardPoints;
  final bool isActivated;
  final DateTime? activationExpiry;

  User({
    required this.name,
    required this.email,
    required this.avatar,
    required this.walletBalance,
    required this.rewardPoints,
    required this.isActivated,
    this.activationExpiry,
  });
}

class DashboardData {
  final double walletBalance;
  final int remainingTrips;
  final bool activationStatus;
  final DateTime? activationExpiry;
  final double investmentEarnings;
  final double referralBonuses;
  final List<Alert> alerts;

  DashboardData({
    required this.walletBalance,
    required this.remainingTrips,
    required this.activationStatus,
    this.activationExpiry,
    required this.investmentEarnings,
    required this.referralBonuses,
    required this.alerts,
  });
}

class Alert {
  final String id;
  final String title;
  final String message;
  final AlertType type;
  final DateTime timestamp;
  final bool isRead;

  Alert({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });
}

enum AlertType { activation, tripExpiry, earning, referral, general }

class BusRoute {
  final String id;
  final String from;
  final String to;
  final String departureTime;
  final String arrivalTime;
  final double price;
  final int availableSeats;
  final String busType;
  final bool isEco;

  BusRoute({
    required this.id,
    required this.from,
    required this.to,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    required this.availableSeats,
    required this.busType,
    required this.isEco,
  });
}

class RecentTrip {
  final String id;
  final String route;
  final String date;
  final double amount;
  final String status;

  RecentTrip({
    required this.id,
    required this.route,
    required this.date,
    required this.amount,
    required this.status,
  });
}

// API Service Class
class ApiService {
  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<User> fetchUserData() async {
    await _simulateDelay();
    return User(
      name: 'John Mwangi',
      email: 'john.mwangi@gmail.com',
      avatar: 'https://via.placeholder.com/150',
      walletBalance: 12450.0,
      rewardPoints: 150,
      isActivated: true,
      activationExpiry: DateTime.now().add(const Duration(days: 25)),
    );
  }

  Future<DashboardData> fetchDashboardData() async {
    await _simulateDelay();
    return DashboardData(
      walletBalance: 12450.0,
      remainingTrips: 8,
      activationStatus: true,
      activationExpiry: DateTime.now().add(const Duration(days: 25)),
      investmentEarnings: 2340.50,
      referralBonuses: 850.0,
      alerts: [
        Alert(
          id: '1',
          title: 'Activation Expiring Soon',
          message: 'Your activation expires in 25 days. Renew now to continue earning!',
          type: AlertType.activation,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        Alert(
          id: '2',
          title: 'New Referral Bonus',
          message: 'You earned KSh 50 from your referral. Check your wallet!',
          type: AlertType.referral,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
        Alert(
          id: '3',
          title: 'Investment Payout',
          message: 'Your weekly investment earnings of KSh 120 have been credited.',
          type: AlertType.earning,
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ],
    );
  }

  Future<List<BusRoute>> fetchPopularRoutes() async {
    await _simulateDelay();
    return [
      BusRoute(
        id: '1',
        from: 'Nairobi CBD',
        to: 'Mombasa',
        departureTime: '14:30',
        arrivalTime: '22:00',
        price: 1200.0,
        availableSeats: 8,
        busType: 'Luxury',
        isEco: true,
      ),
      BusRoute(
        id: '2',
        from: 'Nairobi',
        to: 'Kisumu',
        departureTime: '08:00',
        arrivalTime: '14:30',
        price: 800.0,
        availableSeats: 15,
        busType: 'Standard',
        isEco: true,
      ),
    ];
  }

  Future<List<RecentTrip>> fetchRecentTrips() async {
    await _simulateDelay();
    return [
      RecentTrip(
        id: '1',
        route: 'Nairobi → Mombasa',
        date: '2025-06-28',
        amount: 1200.0,
        status: 'Completed',
      ),
      RecentTrip(
        id: '2',
        route: 'Mombasa → Nairobi',
        date: '2025-06-25',
        amount: 1200.0,
        status: 'Completed',
      ),
    ];
  }

  Future<bool> logout() async {
    await _simulateDelay();
    return true;
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Future variables for API integration
  late Future<User> _userDataFuture;
  late Future<DashboardData> _dashboardDataFuture;
  late Future<List<BusRoute>> _popularRoutesFuture;
  late Future<List<RecentTrip>> _recentTripsFuture;

  // Search controllers
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  // Kenya-specific colors
  static const Color kenyaGreen = Color(0xFF006B3C);
  static const Color kenyaRed = Color(0xFFCE1126);
  static const Color kenyaBlack = Color(0xFF000000);
  static const Color premiumGold = Color(0xFFFFD700);
  static const Color softGreen = Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _initializeData();
    _animationController.forward();
  }

  void _initializeData() {
    _userDataFuture = _apiService.fetchUserData();
    _dashboardDataFuture = _apiService.fetchDashboardData();
    _popularRoutesFuture = _apiService.fetchPopularRoutes();
    _recentTripsFuture = _apiService.fetchRecentTrips();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: kenyaGreen,
          child: CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildDashboardOverview(),
                    _buildAlertsSection(),
                    _buildSearchSection(),
                    _buildPopularRoutesSection(),
                    _buildRecentTripsSection(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kenyaGreen, Color(0xFF2E7D32)],
          ),
        ),
      ),
      title: FutureBuilder<User>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Row(
              children: [
                CircleAvatar(radius: 20, backgroundColor: Colors.white24),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Loading...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                    Text('Welcome back', style: TextStyle(fontSize: 12, color: Colors.white70)),
                  ],
                ),
              ],
            );
          }
          
          if (snapshot.hasError) return const Text('Error loading user data');
          
          final user = snapshot.data!;
          return Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child: Text(user.name[0], style: const TextStyle(color: kenyaGreen, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hello, ${user.name.split(' ')[0]}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                  Row(
                    children: [
                      Icon(
                        user.isActivated ? Icons.verified : Icons.warning,
                        size: 12,
                        color: user.isActivated ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        user.isActivated ? 'Activated' : 'Not Activated',
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
      actions: [
        FutureBuilder<DashboardData>(
          future: _dashboardDataFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final unreadAlerts = snapshot.data!.alerts.where((alert) => !alert.isRead).length;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                    onPressed: _showAlertsDialog,
                  ),
                  if (unreadAlerts > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: kenyaRed,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '$unreadAlerts',
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            }
            return IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
              onPressed: () {},
            );
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: _handleMenuAction,
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem(value: 'profile', child: Text('Profile')),
            const PopupMenuItem(value: 'settings', child: Text('Settings')),
            const PopupMenuItem(value: 'help', child: Text('Help & Support')),
            const PopupMenuItem(value: 'logout', child: Text('Logout', style: TextStyle(color: Colors.red))),
          ],
        ),
      ],
    );
  }

  Widget _buildDashboardOverview() {
    return FutureBuilder<DashboardData>(
      future: _dashboardDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            margin: const EdgeInsets.all(16),
            height: 200,
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        
        if (snapshot.hasError) {
          return Container(
            margin: const EdgeInsets.all(16),
            child: const Text('Error loading dashboard data'),
          );
        }
        
        final dashboard = snapshot.data!;
        
        return Container(
          margin: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dashboard Overview',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kenyaBlack),
              ),
              const SizedBox(height: 16),
              
              // Wallet Balance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kenyaGreen, softGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: kenyaGreen.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.account_balance_wallet, color: Colors.white, size: 28),
                        const SizedBox(width: 12),
                        const Text('Wallet Balance', style: TextStyle(color: Colors.white70, fontSize: 16)),
                        const Spacer(),
                        Icon(
                          dashboard.activationStatus ? Icons.verified : Icons.warning,
                          color: dashboard.activationStatus ? Colors.green : Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'KSh ${dashboard.walletBalance.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildMiniCard('Remaining Trips', '${dashboard.remainingTrips}', Icons.directions_bus),
                        const SizedBox(width: 16),
                        _buildMiniCard(
                          'Status',
                          dashboard.activationStatus ? 'Active' : 'Inactive',
                          dashboard.activationStatus ? Icons.check_circle : Icons.cancel,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Earnings Row
              Row(
                children: [
                  Expanded(
                    child: _buildEarningsCard(
                      'Investment Earnings',
                      dashboard.investmentEarnings,
                      Icons.trending_up,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildEarningsCard(
                      'Referral Bonuses',
                      dashboard.referralBonuses,
                      Icons.group,
                      premiumGold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsCard(String title, double amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(
            'KSh ${amount.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsSection() {
    return FutureBuilder<DashboardData>(
      future: _dashboardDataFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.alerts.isEmpty) {
          return const SizedBox();
        }
        
        final alerts = snapshot.data!.alerts.take(2).toList(); // Show only first 2 alerts
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text('Alerts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  TextButton(
                    onPressed: _showAlertsDialog,
                    child: const Text('View All', style: TextStyle(color: kenyaGreen)),
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                final alert = alerts[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getAlertColor(alert.message).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getAlertColor(alert.message).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(_getAlertIcon(alert.message), color: _getAlertColor(alert.message), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(alert.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            Text(alert.message, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      if (!alert.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: kenyaRed,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildSearchSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.search, color: kenyaGreen, size: 28),
              const SizedBox(width: 12),
              const Text('Book Your Journey', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kenyaGreen)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: softGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('ECO', style: TextStyle(color: softGreen, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildSearchField(controller: _fromController, hint: 'From', icon: Icons.radio_button_checked)),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: _swapLocations,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kenyaGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.swap_horiz, color: kenyaGreen),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: _buildSearchField(controller: _toController, hint: 'To', icon: Icons.location_on)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _searchBuses,
              style: ElevatedButton.styleFrom(
                backgroundColor: kenyaGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Search Buses', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField({required TextEditingController controller, required String hint, required IconData icon}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: kenyaGreen, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildPopularRoutesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Popular Routes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kenyaBlack)),
        ),
        FutureBuilder<List<BusRoute>>(
          future: _popularRoutesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
            }
            
            if (snapshot.hasError) return const Center(child: Text('Error loading routes'));
            
            final routes = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: routes.length,
              itemBuilder: (context, index) {
                final route = routes[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(route.from, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
                                    Text(route.to, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    if (route.isEco) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: softGreen.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text('ECO', style: TextStyle(color: softGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text('${route.departureTime} - ${route.arrivalTime}', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('KSh ${route.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kenyaGreen)),
                              Text('${route.availableSeats} seats left', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                            child: Text(route.busType, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () => _bookRoute(route),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kenyaGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Book Now'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentTripsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Recent Trips', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kenyaBlack)),
        ),
        FutureBuilder<List<RecentTrip>>(
          future: _recentTripsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
            }
            
            if (snapshot.hasError) return const Center(child: Text('Error loading trips'));
            
            final trips = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              physics:const NeverScrollableScrollPhysics(),
              itemCount: trips.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final trip = trips[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.directions_bus, color: kenyaGreen, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${trip.route}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('Date: ${trip.date}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            Text('Fare: KSh ${trip.amount}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    ],
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.home, color: kenyaGreen)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.book, color: Colors.grey)),
          // const SizedBox(width: 40), // space for FAB
          IconButton(onPressed: () {}, icon: const Icon(Icons.history, color: Colors.grey)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.person, color: Colors.grey)),
        ],
      ),
    );
  }



// Updated FloatingActionButton
Widget _buildFloatingActionButton() {
  return FloatingActionButton(
    backgroundColor: kenyaGreen,
    child: const Icon(Icons.add, color: Colors.white),
    onPressed: () {
      showDepositDialog(context);
    },
  );
}
void showDepositDialog(BuildContext context) {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    barrierDismissible :false,
    builder: (BuildContext context) {
      bool isLoading = false;

      return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: StatefulBuilder(
          builder: (context, setState) {
            Future<void> processDeposit() async {
              if (!_formKey.currentState!.validate()) {
                return;
              }
        
              setState(() {
                isLoading = true;
              });
        
      try {
        final random = DateTime.now().millisecondsSinceEpoch;
        final randomString = 'jams$random';
        final response = await comms.postRequest(
          endpoint: "pods/pay",
          data: {
            "sessionId": randomString,
            "payMethod": 1,
            "mpesaNo": phoneController.text,
            "cardName": "",
          },
        );

        if (response["rsp"]['success']) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Deposit of KES ${amountController.text} successful!'),
              backgroundColor: _HomePageState.kenyaGreen,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Deposit failed: ${response['message']}"),
              backgroundColor: _HomePageState.kenyaRed,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Deposit failed: ${e.toString()}"),
            backgroundColor: _HomePageState.kenyaRed,
          ),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
            }
        
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(Icons.account_balance_wallet, color: _HomePageState.kenyaGreen),
                  const SizedBox(width: 8),
                  Text(
                    'Deposit Money',
                    style: TextStyle(
                      color: _HomePageState.kenyaGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                   width: MediaQuery.of(context).size.width*0.75,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            // hintText: '0712345678',
                            prefixIcon: Icon(Icons.phone, color: _HomePageState.kenyaGreen),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.transparent,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter phone number';
                            }
                            if (value.length < 10) {
                              return 'Please enter valid phone number';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextFormField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Amount',
                            // hintText: '1000',
                            prefixIcon: Icon(Icons.money, color: _HomePageState.kenyaGreen),
                            prefixText: 'KES ',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.transparent,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter amount';
                            }
                            final amount = double.tryParse(value);
                            if (amount == null || amount <= 0) {
                              return 'Please enter valid amount';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : processDeposit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _HomePageState.kenyaGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Deposit'),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}

  Future<void> _refreshData() async {
    setState(() {
      _initializeData();
    });
  }

  void _swapLocations() {
    final from = _fromController.text;
    _fromController.text = _toController.text;
    _toController.text = from;
  }

  void _searchBuses() {
    if (_fromController.text.isEmpty || _toController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both locations')),
      );
      return;
    }
    // Proceed to search functionality (route to search results page)
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => 
    //     SearchResultsPage(
    //       from: _fromController.text,
    //       to: _toController.text,
    //     ),
    //   ),
    // );
  }

  void _bookRoute(BusRoute route) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegistrationPage()
      ),
    );
  }

  void _showAlertsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alerts'),
        content: FutureBuilder<DashboardData>(
          future: _dashboardDataFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
            }

            final alerts = snapshot.data!.alerts;
            return SizedBox(
              height: 300,
              width: double.maxFinite,
              child: ListView.builder(
                itemCount: alerts.length,
                itemBuilder: (context, index) {
                  final alert = alerts[index];
                  return ListTile(
                    leading: Icon(_getAlertIcon(alert.message), color: _getAlertColor(alert.message)),
                    title: Text(alert.title),
                    subtitle: Text(alert.message),
                  );
                },
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: kenyaGreen)),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String value) {
    switch (value) {
      case 'profile':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const RegistrationPage()));
        break;
      case 'settings':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const RegistrationPage()));
        break;
      case 'help':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const RegistrationPage()));
        break;
      case 'logout':
        _logout();
        break;
    }
  }

  void _logout() {
    // Handle logout logic like clearing user session/token
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegistrationPage()));
  }

  Color _getAlertColor(String type) {
    switch (type) {
      case 'warning':
        return Colors.orange;
      case 'success':
        return Colors.green;
      case 'info':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getAlertIcon(String type) {
    switch (type) {
      case 'warning':
        return Icons.warning_amber_rounded;
      case 'success':
        return Icons.check_circle;
      case 'info':
        return Icons.info_outline;
      default:
        return Icons.notifications;
    }
  }
}
