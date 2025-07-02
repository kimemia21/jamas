import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zcs_sdk_plugin/zcs_sdk_plugin_platform_interface.dart';

// Data Models
class Tout {
  final String id;
  final String name;
  final String phone;
  final String busNumber;
  final String route;
  final bool isActive;

  Tout({
    required this.id,
    required this.name,
    required this.phone,
    required this.busNumber,
    required this.route,
    required this.isActive,
  });
}

class BookingRequest {
  final String from;
  final String to;
  final int passengers;
  final double fare;
  final String paymentMethod;

  BookingRequest({
    required this.from,
    required this.to,
    required this.passengers,
    required this.fare,
    required this.paymentMethod,
  });
}

class Receipt {
  final String receiptNumber;
  final String from;
  final String to;
  final int passengers;
  final double totalAmount;
  final String paymentMethod;
  final DateTime timestamp;
  final String toutName;
  final String busNumber;

  Receipt({
    required this.receiptNumber,
    required this.from,
    required this.to,
    required this.passengers,
    required this.totalAmount,
    required this.paymentMethod,
    required this.timestamp,
    required this.toutName,
    required this.busNumber,
  });
}

class PaymentTransaction {
  final String transactionId;
  final double amount;
  final String method;
  final String status; // pending, success, failed
  final String? mpesaCode;
  final DateTime timestamp;

  PaymentTransaction({
    required this.transactionId,
    required this.amount,
    required this.method,
    required this.status,
    this.mpesaCode,
    required this.timestamp,
  });
}

// API Service Class
class ToutApiService {
  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(seconds: 2));
  }

  Future<Tout> fetchToutData() async {
    await _simulateDelay();
    return Tout(
      id: 'tout_001',
      name: 'Peter Kamau',
      phone: '+254712345678',
      busNumber: 'KCA 123X',
      route: 'Nairobi - Mombasa',
      isActive: true,
    );
  }

  Future<Map<String, double>> fetchRouteFares() async {
    await _simulateDelay();
    return {
      'Nairobi-Mombasa': 1200.0,
      'Nairobi-Kisumu': 800.0,
      'Nairobi-Nakuru': 500.0,
      'Mombasa-Nairobi': 1200.0,
      'Kisumu-Nairobi': 800.0,
      'Nakuru-Nairobi': 500.0,
    };
  }

  Future<List<String>> fetchAvailableLocations() async {
    await _simulateDelay();
    return [
      'Nairobi',
      'Mombasa',
      'Kisumu',
      'Nakuru',
      'Eldoret',
      'Thika',
      'Machakos',
      'Kitui',
    ];
  }

  Future<PaymentTransaction> processPayment(
    BookingRequest booking,
    String phoneNumber,
  ) async {
    await _simulateDelay();

    // Simulate payment processing
    final bool paymentSuccess =
        DateTime.now().millisecond % 2 == 0; // Random success/failure

    return PaymentTransaction(
      transactionId: 'TXN${DateTime.now().millisecondsSinceEpoch}',
      amount: booking.fare * booking.passengers,
      method: booking.paymentMethod,
      status: paymentSuccess ? 'success' : 'failed',
      mpesaCode:
          paymentSuccess && booking.paymentMethod == 'M-Pesa'
              ? 'MP${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}'
              : null,
      timestamp: DateTime.now(),
    );
  }

  Future<Receipt> generateReceipt(
    BookingRequest booking,
    PaymentTransaction transaction,
    Tout tout,
  ) async {
    await _simulateDelay();

    return Receipt(
      receiptNumber:
          'REC${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      from: booking.from,
      to: booking.to,
      passengers: booking.passengers,
      totalAmount: booking.fare * booking.passengers,
      paymentMethod: booking.paymentMethod,
      timestamp: DateTime.now(),
      toutName: tout.name,
      busNumber: tout.busNumber,
    );
  }
}

class ToutHomePage extends StatefulWidget {
  const ToutHomePage({Key? key}) : super(key: key);

  @override
  State<ToutHomePage> createState() => _ToutHomePageState();
}

class _ToutHomePageState extends State<ToutHomePage> {
  final ToutApiService _apiService = ToutApiService();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _passengersController = TextEditingController(
    text: '1',
  );
  final TextEditingController _phoneController = TextEditingController();

  final ZcsSdkPluginPlatform _plugin = ZcsSdkPluginPlatform.instance;

  // State variables
  late Future<Tout> _toutDataFuture;
  late Future<Map<String, double>> _faresFuture;
  late Future<List<String>> _locationsFuture;
  String _selectedPaymentMethod = 'M-Pesa';
  bool _isProcessingPayment = false;
  double _calculatedFare = 0.0;

  // Dropdown selections
  String? _selectedFrom;
  String? _selectedTo;

  // Outdoor-optimized colors
  static const Color primaryBlue = Color(0xFF1976D2);
  static const Color darkBlue = Color(0xFF0D47A1);
  static const Color kenyaRed = Color(0xFFCE1126);
  static const Color outdoorOrange = Color(0xFFFF6F00); // High contrast for outdoor visibility

  @override
  void initState() {
    super.initState();
    _initializeData();
    _passengersController.addListener(_calculateFare);
   
  }

  void _initializeData() async{
    _toutDataFuture = _apiService.fetchToutData();
    _faresFuture = _apiService.fetchRouteFares();
    _locationsFuture = _apiService.fetchAvailableLocations();
    await   _plugin.initializeDevice();

   await   _plugin.openDevice();
  
  }

  void _calculateFare() {
    if (_selectedFrom != null &&
        _selectedTo != null &&
        _selectedFrom != _selectedTo) {
      _faresFuture.then((fares) {
        final routeKey = '$_selectedFrom-$_selectedTo';
        final fare = fares[routeKey] ?? 100.0;
        final passengers = int.tryParse(_passengersController.text) ?? 1;

        setState(() {
          _calculatedFare = fare * passengers;
          print(
            'Calculated fare: $_calculatedFare for route $routeKey with $passengers passengers',
          );
        });
      });
    }
  }

  @override
  void dispose() {
    _passengersController.dispose();
    _phoneController.dispose();
    _plugin.closeDevice();
     super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildToutInfoCard(),
              const SizedBox(height: 20),
              _buildBookingForm(),
              const SizedBox(height: 20),
              _buildPaymentSection(),
              const SizedBox(height: 30),
              _buildProcessButton(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: primaryBlue,
      elevation: 0,
      actions: [
        FutureBuilder<Tout>(
          future: _toutDataFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: snapshot.data!.isActive ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  snapshot.data!.isActive ? 'ACTIVE' : 'INACTIVE',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ],
    );
  }

  Widget _buildToutInfoCard() {
    return FutureBuilder<Tout>(
      future: _toutDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) return const SizedBox();

        final tout = snapshot.data!;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryBlue, darkBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 22,
                    child: Text(
                      tout.name[0],
                      style: const TextStyle(
                        color: primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tout.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          tout.phone,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      'Bus Number',
                      tout.busNumber,
                      Icons.directions_bus,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoChip('Route', tout.route, Icons.route),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingForm() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Booking Details',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // From and To Dropdowns
          FutureBuilder<List<String>>(
            future: _locationsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData) return const SizedBox();

              final locations = snapshot.data!;

              return Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedFrom,
                      decoration: const InputDecoration(
                        labelText: 'From',
                        labelStyle: TextStyle(fontSize: 16),
                        prefixIcon: Icon(
                          Icons.radio_button_checked,
                          color: primaryBlue,
                        ),
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                      items:
                          locations
                              .map(
                                (location) => DropdownMenuItem(
                                  value: location,
                                  child: Text(location, style: const TextStyle(fontSize: 16)),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedFrom = value;
                        });
                        _calculateFare();
                      },
                      validator:
                          (value) =>
                              value == null
                                  ? 'Select departure location'
                                  : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: _swapLocations,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.swap_horiz, color: primaryBlue, size: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedTo,
                      decoration: const InputDecoration(
                        labelText: 'To',
                        labelStyle: TextStyle(fontSize: 16),
                        prefixIcon: Icon(Icons.location_on, color: primaryBlue),
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                      items:
                          locations
                              .map(
                                (location) => DropdownMenuItem(
                                  value: location,
                                  child: Text(location, style: const TextStyle(fontSize: 16)),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedTo = value;
                        });
                        _calculateFare();
                      },
                      validator:
                          (value) =>
                              value == null ? 'Select destination' : null,
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 16),

          // Passengers
          TextFormField(
            controller: _passengersController,
            style: const TextStyle(fontSize: 16),
            decoration: const InputDecoration(
              labelText: 'Number of Passengers',
              labelStyle: TextStyle(fontSize: 16),
              prefixIcon: Icon(Icons.people, color: primaryBlue),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              final num = int.tryParse(value ?? '');
              return num == null || num < 1
                  ? 'Enter valid number of passengers'
                  : null;
            },
          ),

          const SizedBox(height: 16),

          // Fare Display
          if (_calculatedFare > 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text(
                    'Total Fare',
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                  Text(
                    'KSh ${_calculatedFare.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Method',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Payment Method Selection
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: Row(
                    children: [
                      Image.asset(
                        'assets/mpesa.png',
                        width: 26,
                        height: 26,
                        errorBuilder:
                            (_, __, ___) => const Icon(
                              Icons.phone_android,
                              color: Colors.green,
                              size: 26,
                            ),
                      ),
                      const SizedBox(width: 8),
                      const Text('M-Pesa', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  value: 'M-Pesa',
                  groupValue: _selectedPaymentMethod,
                  onChanged:
                      (value) =>
                          setState(() => _selectedPaymentMethod = value!),
                  activeColor: primaryBlue,
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Row(
                    children: [
                      Icon(Icons.credit_card, color: Colors.blue, size: 26),
                      SizedBox(width: 8),
                      Text('Card', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  value: 'Card',
                  groupValue: _selectedPaymentMethod,
                  onChanged:
                      (value) =>
                          setState(() => _selectedPaymentMethod = value!),
                  activeColor: primaryBlue,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Phone Number for M-Pesa
          if (_selectedPaymentMethod == 'M-Pesa')
            TextFormField(
              controller: _phoneController,
              style: const TextStyle(fontSize: 16),
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                labelStyle: TextStyle(fontSize: 16),
                prefixText: '+254 ',
                prefixStyle: TextStyle(fontSize: 16),
                prefixIcon: Icon(Icons.phone, color: primaryBlue),
                border: OutlineInputBorder(),
                helperText: 'Enter M-Pesa registered number',
                helperStyle: TextStyle(fontSize: 14),
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (_selectedPaymentMethod == 'M-Pesa') {
                  return value?.isEmpty ?? true
                      ? 'Enter phone number for M-Pesa'
                      : null;
                }
                return null;
              },
            ),

          // Custom Card Display
          if (_selectedPaymentMethod == 'Card') _buildCustomCardDisplay(),
        ],
      ),
    );
  }

  Widget _buildCustomCardDisplay() {
    return GestureDetector(
      onTap: _showCardPaymentAlert,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [outdoorOrange, outdoorOrange.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: outdoorOrange.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'KAPS Card',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Image.asset(
                  'assets/images/kaps.png',
                  width: 52,
                  height: 32,
                  errorBuilder:
                      (_, __, ___) => const Icon(
                        Icons.credit_card,
                        color: Colors.white,
                        size: 32,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              '**** **** **** 1234',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                letterSpacing: 2,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CARDHOLDER NAME',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Text(
                  'EXPIRES',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'JOHN DOE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '12/28',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Tap card to process payment',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isProcessingPayment ? null : _processBooking,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child:
            _isProcessingPayment
                ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text('Processing Payment...', style: TextStyle(fontSize: 16)),
                  ],
                )
                : const Text(
                  'Process Payment',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
      ),
    );
  }

  void _swapLocations() {
    setState(() {
      final temp = _selectedFrom;
      _selectedFrom = _selectedTo;
      _selectedTo = temp;
    });
    _calculateFare();
  }

  void _showCardPaymentAlert() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Image.asset(
                  'assets/images/kaps.png',
                  width: 42,
                  height: 27,
                  errorBuilder:
                      (_, __, ___) => const Icon(
                        Icons.credit_card,
                        color: outdoorOrange,
                        size: 32,
                      ),
                ),
                const SizedBox(width: 12),
                const Text('KAPS Card Payment', style: TextStyle(fontSize: 18)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: outdoorOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.tap_and_play,
                        size: 54,
                        color: outdoorOrange,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Tap your KAPS card to process payment',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_calculatedFare > 0)
                        Text(
                          'Amount: KSh ${_calculatedFare.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: outdoorOrange,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Make sure your card is enabled for contactless payments',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(fontSize: 16)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _processBooking();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: outdoorOrange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Process Payment', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
    );
  }

  Future<void> _processBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_calculatedFare <= 0) {
      _showSnackBar('Please select valid route', isError: true);
      return;
    }

    // Prepare receipt data for printing
    final receiptData = {
      "storeName": "Bus Service",
      "receiptType": _selectedPaymentMethod == "M-Pesa" ? "Sale Receipt" : "Card Receipt",
      "date": DateTime.now().toString().split(' ')[0],
      "time": TimeOfDay.now().format(context),
      "orderNumber": "TXN${DateTime.now().millisecondsSinceEpoch}",
      "items": [
      {
        "name": "${_selectedFrom ?? ''} - ${_selectedTo ?? ''}",
        "quantity": _passengersController.text,
        "price": (_calculatedFare / (int.tryParse(_passengersController.text) ?? 1)).toStringAsFixed(2),
      }
      ],
      "subtotal": (_calculatedFare).toStringAsFixed(2),
      "tax": "0.00",
      "total": (_calculatedFare).toStringAsFixed(2),
      "paymentMethod": _selectedPaymentMethod,
    };
    await _plugin.printReceipt(receiptData);


    if (_selectedFrom == _selectedTo) {
      _showSnackBar(
        'Please select different departure and destination',
        isError: true,
      );
      return;
    }

    setState(() => _isProcessingPayment = true);

    try {
      // Create booking request
      final booking = BookingRequest(
        from: _selectedFrom!,
        to: _selectedTo!,
        passengers: int.parse(_passengersController.text),
        fare: _calculatedFare / int.parse(_passengersController.text),
        paymentMethod: _selectedPaymentMethod,
      );

      // Process payment
      final transaction = await _apiService.processPayment(
        booking,
        _phoneController.text,
      );

      if (transaction.status == 'success') {
        // Generate receipt
        final tout = await _toutDataFuture;
        final receipt = await _apiService.generateReceipt(
          booking,
          transaction,
          tout,
        );

        // Show receipt
        _showReceiptDialog(receipt, transaction);

        // Clear form
        _clearForm();
      } else {
        _showSnackBar('Payment failed. Please try again.', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error processing payment: $e', isError: true);
    } finally {
      setState(() => _isProcessingPayment = false);
    }
  }

  void _showReceiptDialog(Receipt receipt, PaymentTransaction transaction) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 30),
                const SizedBox(width: 8),
                const Text('Payment Successful', style: TextStyle(fontSize: 18)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildReceiptRow('Receipt No:', receipt.receiptNumber),
                  _buildReceiptRow('From:', receipt.from),
                  _buildReceiptRow('To:', receipt.to),
                  _buildReceiptRow('Passengers:', '${receipt.passengers}'),
                  _buildReceiptRow(
                    'Total Amount:',
                    'KSh ${receipt.totalAmount.toStringAsFixed(2)}',
                  ),
                  _buildReceiptRow('Payment Method:', receipt.paymentMethod),
                  if (transaction.mpesaCode != null)
                    _buildReceiptRow('M-Pesa Code:', transaction.mpesaCode!),
                  _buildReceiptRow('Date:', _formatDateTime(receipt.timestamp)),
                  _buildReceiptRow('Tout:', receipt.toutName),
                  _buildReceiptRow('Bus:', receipt.busNumber),
                  const Divider(),
                  const Text(
                    'Thank you for traveling with us!',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Print Receipt',
                  style: TextStyle(color: primaryBlue, fontSize: 16),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
                child: const Text('Done', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _clearForm() {
    _selectedFrom = null;
    _selectedTo = null;
    _passengersController.text = '1';
    _phoneController.clear();
    setState(() {
      _calculatedFare = 0.0;
      _selectedPaymentMethod = 'M-Pesa';
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? kenyaRed : primaryBlue,
      ),
    );
  }
}
