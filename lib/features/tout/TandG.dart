import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_android.dart';
import 'package:zcs_sdk_plugin/zcs_sdk_plugin_platform_interface.dart';

class TapAndGoPage extends StatefulWidget {
  const TapAndGoPage({Key? key}) : super(key: key);

  @override
  State<TapAndGoPage> createState() => _TapAndGoPageState();
}

class _TapAndGoPageState extends State<TapAndGoPage> {
  final ZcsSdkPluginPlatform _plugin = ZcsSdkPluginPlatform.instance;
  
  // State variables
  bool isNfcActive = false;
  bool isProcessingPayment = false;
  String? currentCardUid;
  List<PaymentRecord> paymentHistory = [];
  String? nfcStatusMessage;
  
  // Colors
  static const Color primaryBlue = Color(0xFF1976D2);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color errorRed = Color(0xFFE53935);
  static const Color warningOrange = Color(0xFFFF9800);
  
  @override
  void initState() {
    super.initState();
    _initializeNfcAndDevice();
  }

  @override
  void dispose() {
    _stopNfcSession();
    _plugin.closeDevice();
    super.dispose();
  }

  Future<void> _initializeNfcAndDevice() async {
    try {
      // Initialize printer device
      await _plugin.initializeDevice();
      await _plugin.openDevice();
      
      // Check NFC availability and start session
      await _checkNfcAndStartSession();
    } catch (e) {
      setState(() {
        nfcStatusMessage = 'Device initialization failed: $e';
      });
    }
  }

  Future<void> _checkNfcAndStartSession() async {
    try {
      bool isAvailable = await NfcManager.instance.isAvailable();
      if (!isAvailable) {
        setState(() {
          nfcStatusMessage = 'NFC is not available on this device';
        });
        return;
      }

      await _startNfcSession();
    } catch (e) {
      setState(() {
        nfcStatusMessage = 'NFC check failed: $e';
      });
    }
  }

  Future<void> _startNfcSession() async {
    try {
      await NfcManager.instance.startSession(
        pollingOptions: {NfcPollingOption.iso14443},
        onDiscovered: (NfcTag tag) async {
          await _handleCardTap(tag);
        },
      );
      
      setState(() {
        isNfcActive = true;
        nfcStatusMessage = 'Ready for card taps';
      });
    } catch (e) {
      setState(() {
        isNfcActive = false;
        nfcStatusMessage = 'Failed to start NFC session: $e';
      });
    }
  }

  Future<void> _handleCardTap(NfcTag tag) async {
    if (isProcessingPayment) return;
    
    try {
      setState(() {
        isProcessingPayment = true;
        currentCardUid = null;
      });

      final MifareClassicAndroid? mifareClassic = MifareClassicAndroid.from(tag);
      if (mifareClassic != null) {
        // Extract card UID
        final List<int> uidBytes = mifareClassic.tag.id;
        final String hexUid = uidBytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
        
        // Convert to decimal (reversed byte order)
        final int decimalUid = _reverseHexBytesToDecimal(hexUid);
        final String cardUid = decimalUid.toString();
        
        setState(() {
          currentCardUid = cardUid;
        });

        // Process payment
        await _processPayment(cardUid);
        
        // Show success alert
        _showPaymentAlert(cardUid, true);
        
      } else {
        throw Exception('Invalid card type detected');
      }
    } catch (e) {
      _showPaymentAlert(null, false, error: e.toString());
    } finally {
      setState(() {
        isProcessingPayment = false;
      });
    }
  }

  Future<void> _processPayment(String cardUid) async {
    try {
      // Create payment record
      final paymentRecord = PaymentRecord(
        cardUid: cardUid,
        amount: 100.0, // Default amount for tap and go
        timestamp: DateTime.now(),
        status: 'success',
      );

      // Add to history
      setState(() {
        paymentHistory.insert(0, paymentRecord);
      });

      // Print receipt
      await _printReceipt(paymentRecord);
      
    } catch (e) {
      throw Exception('Payment processing failed: $e');
    }
  }

  Future<void> _printReceipt(PaymentRecord record) async {
    try {
      final receiptData = {
        "storeName": "Jamas Bus Service",
        "receiptType": "Quick Payment",
        "date": _formatDate(record.timestamp),
        "time": _formatTime(record.timestamp),
        "orderNumber": "TNG${record.timestamp.millisecondsSinceEpoch}",
        "cardUid": record.cardUid,
        "items": [
          {
            "name": "Bus Service",
            "quantity": "1",
            "price": record.amount.toStringAsFixed(2),
          },
        ],
        "subtotal": record.amount.toStringAsFixed(2),
        "tax": "0.00",
        "total": record.amount.toStringAsFixed(2),
        "paymentMethod": "KAPS Card",
      };

      await _plugin.printReceipt(receiptData);
    } catch (e) {
      throw Exception('Receipt printing failed: $e');
    }
  }

  void _showPaymentAlert(String? cardUid, bool isSuccess, {String? error}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: isSuccess ? successGreen : errorRed,
              size: 30,
            ),
            const SizedBox(width: 8),
            Text(
              isSuccess ? 'Payment Successful' : 'Payment Failed',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isSuccess && cardUid != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.credit_card,
                      size: 48,
                      color: successGreen,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Card Number: $cardUid',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Amount: KSh 100.00',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: successGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Payment processed successfully!\nReceipt has been printed.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: errorRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: errorRed,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      error ?? 'Unknown error occurred',
                      style: const TextStyle(
                        fontSize: 14,
                        color: errorRed,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: isSuccess ? successGreen : errorRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Future<void> _stopNfcSession() async {
    try {
      await NfcManager.instance.stopSession();
      setState(() {
        isNfcActive = false;
        nfcStatusMessage = 'NFC session stopped';
      });
    } catch (e) {
      setState(() {
        nfcStatusMessage = 'Error stopping NFC session: $e';
      });
    }
  }

  Future<void> _restartNfcSession() async {
    await _stopNfcSession();
    await Future.delayed(const Duration(milliseconds: 500));
    await _startNfcSession();
  }

  int _reverseHexBytesToDecimal(String hexString) {
    if (hexString.length % 2 != 0) {
      throw FormatException('Invalid hex string length');
    }

    List<String> bytes = [];
    for (int i = 0; i < hexString.length; i += 2) {
      bytes.add(hexString.substring(i, i + 2));
    }

    List<String> reversedBytes = bytes.reversed.toList();
    String reversedHex = reversedBytes.join();
    return int.parse(reversedHex, radix: 16);
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Jamas Tap And Go'),
        backgroundColor: primaryBlue,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isNfcActive ? Icons.nfc : Icons.nfc_outlined),
            onPressed: isNfcActive ? _stopNfcSession : _restartNfcSession,
          ),
        ],
      ),
      body: Column(
        children: [
          // NFC Status Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  isNfcActive ? successGreen : errorRed,
                  (isNfcActive ? successGreen : errorRed).withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (isNfcActive ? successGreen : errorRed).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  isNfcActive ? Icons.nfc : Icons.nfc_outlined,
                  size: 64,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  isNfcActive ? 'Ready for Payment' : 'NFC Inactive',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isProcessingPayment 
                      ? 'Processing payment...' 
                      : (nfcStatusMessage ?? 'Tap your card to pay'),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (isProcessingPayment) ...[
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ],
              ],
            ),
          ),

          // Control Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isNfcActive ? _stopNfcSession : _restartNfcSession,
                    icon: Icon(isNfcActive ? Icons.stop : Icons.play_arrow),
                    label: Text(isNfcActive ? 'Stop NFC' : 'Start NFC'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isNfcActive ? errorRed : successGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        paymentHistory.clear();
                      });
                    },
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear History'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: warningOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Payment History
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
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
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: primaryBlue,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.history, color: Colors.white),
                        const SizedBox(width: 8),
                        const Text(
                          'Payment History',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${paymentHistory.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: paymentHistory.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.credit_card_outlined,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No payments yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  'Tap a card to make your first payment',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: paymentHistory.length,
                            itemBuilder: (context, index) {
                              final payment = paymentHistory[index];
                              return _buildPaymentHistoryItem(payment, index);
                            },
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

  Widget _buildPaymentHistoryItem(PaymentRecord payment, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: successGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.credit_card,
              color: successGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Card: ${payment.cardUid}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Amount: KSh ${payment.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '${_formatDate(payment.timestamp)} at ${_formatTime(payment.timestamp)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: successGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              payment.status.toUpperCase(),
              style: const TextStyle(
                color: successGreen,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentRecord {
  final String cardUid;
  final double amount;
  final DateTime timestamp;
  final String status;

  PaymentRecord({
    required this.cardUid,
    required this.amount,
    required this.timestamp,
    required this.status,
  });
}