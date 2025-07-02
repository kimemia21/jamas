import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  Future<PaymentTransaction> processPayment(BookingRequest booking, String phoneNumber) async {
    await _simulateDelay();
    
    // Simulate payment processing
    final bool paymentSuccess = DateTime.now().millisecond % 2 == 0; // Random success/failure
    
    return PaymentTransaction(
      transactionId: 'TXN${DateTime.now().millisecondsSinceEpoch}',
      amount: booking.fare * booking.passengers,
      method: booking.paymentMethod,
      status: paymentSuccess ? 'success' : 'failed',
      mpesaCode: paymentSuccess && booking.paymentMethod == 'M-Pesa' 
          ? 'MP${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}' 
          : null,
      timestamp: DateTime.now(),
    );
  }

  Future<Receipt> generateReceipt(BookingRequest booking, PaymentTransaction transaction, Tout tout) async {
    await _simulateDelay();
    
    return Receipt(
      receiptNumber: 'REC${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
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
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _passengersController = TextEditingController(text: '1');
  final TextEditingController _phoneController = TextEditingController();
  
  // State variables
  late Future<Tout> _toutDataFuture;
  late Future<Map<String, double>> _faresFuture;
  String _selectedPaymentMethod = 'M-Pesa';
  bool _isProcessingPayment = false;
  double _calculatedFare = 0.0;
  
  // Kenya-specific colors
  static const Color kenyaGreen = Color(0xFF006B3C);
  static const Color kenyaRed = Color(0xFFCE1126);
  static const Color premiumGold = Color(0xFFFFD700);

  @override
  void initState() {
    super.initState();
    _initializeData();
    _passengersController.addListener(_calculateFare);
  }

  void _initializeData() {
    _toutDataFuture = _apiService.fetchToutData();
    _faresFuture = _apiService.fetchRouteFares();
  }

  void _calculateFare() {
    if (_fromController.text.isNotEmpty && _toController.text.isNotEmpty) {
      _faresFuture.then((fares) {
        final routeKey = '${_fromController.text}-${_toController.text}';
        final fare = fares[routeKey] ?? 0.0;
        final passengers = int.tryParse(_passengersController.text) ?? 1;
        
        setState(() {
          _calculatedFare = fare * passengers;
        });
      });
    }
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _passengersController.dispose();
    _phoneController.dispose();
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
      title: const Text('Tout Booking System', 
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      backgroundColor: kenyaGreen,
      elevation: 0,
      actions: [
        FutureBuilder<Tout>(
          future: _toutDataFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: snapshot.data!.isActive ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  snapshot.data!.isActive ? 'ACTIVE' : 'INACTIVE',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kenyaGreen, kenyaGreen.withOpacity(0.8)],
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
                    child: Text(tout.name[0], style: const TextStyle(color: kenyaGreen, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tout.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(tout.phone, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip('Bus Number', tout.busNumber, Icons.directions_bus),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBookingForm() {
    return Container(
      padding: const EdgeInsets.all(16),
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
          const Text('Booking Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          // From and To
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _fromController,
                  decoration: const InputDecoration(
                    labelText: 'From',
                    prefixIcon: Icon(Icons.radio_button_checked, color: kenyaGreen),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Enter departure location' : null,
                  onChanged: (_) => _calculateFare(),
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: _swapLocations,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kenyaGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.swap_horiz, color: kenyaGreen),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _toController,
                  decoration: const InputDecoration(
                    labelText: 'To',
                    prefixIcon: Icon(Icons.location_on, color: kenyaGreen),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Enter destination' : null,
                  onChanged: (_) => _calculateFare(),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Passengers
          TextFormField(
            controller: _passengersController,
            decoration: const InputDecoration(
              labelText: 'Number of Passengers',
              prefixIcon: Icon(Icons.people, color: kenyaGreen),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              final num = int.tryParse(value ?? '');
              return num == null || num < 1 ? 'Enter valid number of passengers' : null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Fare Display
          if (_calculatedFare > 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kenyaGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text('Total Fare', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  Text(
                    'KSh ${_calculatedFare.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kenyaGreen),
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
      padding: const EdgeInsets.all(16),
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
          const Text('Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          // Payment Method Selection
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: Row(
                    children: [
                      Image.asset('assets/mpesa.png', width: 24, height: 24, errorBuilder: (_, __, ___) => 
                          const Icon(Icons.phone_android, color: Colors.green)),
                      const SizedBox(width: 8),
                      const Text('M-Pesa'),
                    ],
                  ),
                  value: 'M-Pesa',
                  groupValue: _selectedPaymentMethod,
                  onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
                  activeColor: kenyaGreen,
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Row(
                    children: [
                      Icon(Icons.credit_card, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Card'),
                    ],
                  ),
                  value: 'Card',
                  groupValue: _selectedPaymentMethod,
                  onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
                  activeColor: kenyaGreen,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Phone Number for M-Pesa
          if (_selectedPaymentMethod == 'M-Pesa')
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixText: '+254 ',
                prefixIcon: Icon(Icons.phone, color: kenyaGreen),
                border: OutlineInputBorder(),
                helperText: 'Enter M-Pesa registered number',
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (_selectedPaymentMethod == 'M-Pesa') {
                  return value?.isEmpty ?? true ? 'Enter phone number for M-Pesa' : null;
                }
                return null;
              },
            ),
            
          // Card details placeholder
          if (_selectedPaymentMethod == 'Card')
            Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Card Number',
                    prefixIcon: Icon(Icons.credit_card, color: kenyaGreen),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Expiry (MM/YY)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'CVV',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildProcessButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isProcessingPayment ? null : _processBooking,
        style: ElevatedButton.styleFrom(
          backgroundColor: kenyaGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isProcessingPayment
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Processing Payment...'),
                ],
              )
            : const Text('Process Payment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _swapLocations() {
    final from = _fromController.text;
    _fromController.text = _toController.text;
    _toController.text = from;
    _calculateFare();
  }

  Future<void> _processBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_calculatedFare <= 0) {
      _showSnackBar('Please select valid route', isError: true);
      return;
    }

    setState(() => _isProcessingPayment = true);

    try {
      // Create booking request
      final booking = BookingRequest(
        from: _fromController.text,
        to: _toController.text,
        passengers: int.parse(_passengersController.text),
        fare: _calculatedFare / int.parse(_passengersController.text),
        paymentMethod: _selectedPaymentMethod,
      );

      // Process payment
      final transaction = await _apiService.processPayment(booking, _phoneController.text);
      
      if (transaction.status == 'success') {
        // Generate receipt
        final tout = await _toutDataFuture;
        final receipt = await _apiService.generateReceipt(booking, transaction, tout);
        
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
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 8),
            const Text('Payment Successful'),
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
              _buildReceiptRow('Total Amount:', 'KSh ${receipt.totalAmount.toStringAsFixed(2)}'),
              _buildReceiptRow('Payment Method:', receipt.paymentMethod),
              if (transaction.mpesaCode != null)
                _buildReceiptRow('M-Pesa Code:', transaction.mpesaCode!),
              _buildReceiptRow('Date:', _formatDateTime(receipt.timestamp)),
              _buildReceiptRow('Tout:', receipt.toutName),
              _buildReceiptRow('Bus:', receipt.busNumber),
              const Divider(),
              const Text('Thank you for traveling with us!', 
                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Print Receipt', style: TextStyle(color: kenyaGreen)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: kenyaGreen),
            child: const Text('Done'),
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
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _clearForm() {
    _fromController.clear();
    _toController.clear();
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
        backgroundColor: isError ? kenyaRed : kenyaGreen,
      ),
    );
  }
}