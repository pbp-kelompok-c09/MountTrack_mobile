
import 'package:flutter/material.dart';
import '../../widgets/app_navbar.dart';

class PaymentPage extends StatefulWidget {
  final String bookingId;
  final int totalAmount;
  final String? qrisPayload;

  const PaymentPage({
    super.key,
    required this.bookingId,
    required this.totalAmount,
    this.qrisPayload,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  static const cafeNoir = Color(0xFF4C3019);
  static const kombuGreen = Color(0xFF354024);
  static const mossGreen = Color(0xFF889063);
  static const tan = Color(0xFFCFBB99);
  static const bone = Color(0xFFE5D7C4);
  static const sacramento = Color(0xFF102114);
  static const pine = Color(0xFF294122);
  static const salmon = Color(0xFFFFBBA6);
  static const tangerine = Color(0xFFEB3D00);
  static const chiffon = Color(0xFFFFEED2);

  bool _isProcessing = false;
  bool _paymentSuccess = false;

  Future<void> _simulatePayment() async {
    setState(() {
      _isProcessing = true;
    });

    // Simulasi delay untuk proses pembayaran
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isProcessing = false;
      _paymentSuccess = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bone,
      appBar: AppNavBar(title: 'Pembayaran'),
      body: _paymentSuccess
          ? _buildSuccessView(context)
          : _buildPaymentView(context),
    );
  }

  Widget _buildPaymentView(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kombuGreen, pine],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Pembayaran',
                    style: TextStyle(
                      color: bone,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Rp ${widget.totalAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}',
                    style: const TextStyle(
                      color: bone,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Booking ID: ${widget.bookingId}',
                    style: const TextStyle(
                      color: chiffon,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // QRIS Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: tan, width: 2),
                borderRadius: BorderRadius.circular(12),
                color: chiffon,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'QRIS Payment',
                    style: TextStyle(
                      color: cafeNoir,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Dummy QRIS Code Display
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        // Placeholder for QRIS code (in real app, generate QR code here)
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: mossGreen, width: 3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.qr_code,
                                  size: 80,
                                  color: mossGreen.withOpacity(0.5),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'QRIS Code\n(Dummy)',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: mossGreen.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Scan kode QRIS di atas menggunakan aplikasi pembayaran Anda',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: cafeNoir.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Payment details
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: bone,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Booking ID:', style: TextStyle(fontSize: 12)),
                            Text(
                              widget.bookingId,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Metode:', style: TextStyle(fontSize: 12)),
                            Text(
                              'QRIS',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: tangerine,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Status:', style: TextStyle(fontSize: 12)),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: salmon.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Menunggu Pembayaran',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: tangerine,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Info Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: chiffon,
                border: Border.all(color: tan),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '💡 Tips Pembayaran',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: cafeNoir,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1. Pastikan saldo cukup sebelum melakukan pembayaran\n'
                    '2. Jangan refresh halaman selama proses pembayaran\n'
                    '3. Pembayaran akan dikonfirmasi secara otomatis',
                    style: TextStyle(
                      fontSize: 12,
                      color: cafeNoir.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: _isProcessing ? null : _simulatePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mossGreen,
                    foregroundColor: bone,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(bone),
                          ),
                        )
                      : const Text(
                          'Konfirmasi Pembayaran',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _isProcessing ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cafeNoir,
                    side: const BorderSide(color: cafeNoir),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Kembali ke Booking'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: mossGreen,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle,
                    color: bone,
                    size: 60,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Success Message
              const Text(
                'Pembayaran Berhasil!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: cafeNoir,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Booking Anda telah dikonfirmasi. Silakan tunggu konfirmasi lebih lanjut.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: cafeNoir.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),

              // Details Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: chiffon,
                  border: Border.all(color: tan),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Booking ID:',
                          style: TextStyle(fontSize: 12, color: cafeNoir),
                        ),
                        Text(
                          widget.bookingId,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: cafeNoir,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Pembayaran:',
                          style: TextStyle(fontSize: 12, color: cafeNoir),
                        ),
                        Text(
                          'Rp ${widget.totalAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: mossGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/booking/history',
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mossGreen,
                      foregroundColor: bone,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Lihat Riwayat Booking',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: cafeNoir,
                      side: const BorderSide(color: cafeNoir),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Kembali ke Home'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// // payment_page.dart
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:pbp_django_auth/pbp_django_auth.dart';
// import 'package:provider/provider.dart';
// import '../../widgets/app_navbar.dart';
// import '../models/booking.dart';
// import 'booking_summary.dart';

// class PaymentPage extends StatefulWidget {
 
//   final String? bookingId;
//   final num? totalAmount;
//   final dynamic qrisPayload;

//   const PaymentPage({
//     super.key,
//     this.bookingId,
//     this.totalAmount,
//     this.qrisPayload,
//   });

//   @override
//   State<PaymentPage> createState() => _PaymentPageState();
// }

// class _PaymentPageState extends State<PaymentPage> {
//   bool _paymentComplete = false;
//   bool _isLoading = false;

//   String? bookingId;
//   dynamic qrisPayload;
//   num? totalAmount;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     // Prefer constructor args, fallback to route arguments
//     final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

//     bookingId = widget.bookingId ?? args?['bookingId']?.toString();
//     totalAmount = widget.totalAmount ?? (args != null ? args['totalAmount'] : null);
//     qrisPayload = widget.qrisPayload ?? (args != null ? args['qris_payload'] : null);
//   }

//   // helper to show success fallback dialog
//   void _showSuccessFallback() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         title: const Text('Pembayaran Berhasil'),
//         content: const Text('Booking Anda telah dikonfirmasi. Terima kasih telah menggunakan MountTrack!'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context); // Close dialog
//               Navigator.popUntil(context, (route) => route.isFirst);
//             },
//             child: const Text('Kembali ke Home'),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _simulateQRISPayment() async {
  
//   if (!mounted) return;
//   setState(() {
//     _isLoading = true;
//   });

//   final request = context.read<CookieRequest>();

 
//   final id = bookingId?.toString().trim();
//   if (id == null || id.isEmpty) {
//     if (mounted) setState(() { _isLoading = false; });
//     _showSuccessFallback();
//     return;
//   }

//   final payUrl = 'http://localhost:8000/booking/api/pay/$id/';
//   try {
//     print('Calling pay endpoint -> $payUrl');
//     final payResp = await request.post(payUrl, {}); 

//     print('payResp -> $payResp');

//     if (payResp is Map && payResp['success'] == true) {
      
//       final dynamic payload = payResp['qris_payload'] ?? payResp['qris'] ?? payResp['qrisPayload'];
//       final dynamic amt = payResp['amount'] ?? payResp['total'] ?? payResp['amount_due'];

//       if (mounted) {
//         setState(() {
//           qrisPayload = payload ?? qrisPayload;
//           if (amt != null) {
//             totalAmount = (amt is num) ? amt : (num.tryParse(amt.toString()) ?? totalAmount);
//           }
//           _isLoading = false;
//         });
//       }

      
//       await Future.delayed(const Duration(seconds: 2));
//       if (!mounted) return;
//       setState(() { _paymentComplete = true; });

    
//       try {
//         final detailUrl = 'http://localhost:8000/booking/api/$id/';
//         print('Fetching booking detail -> $detailUrl');
//         final detailResp = await request.get(detailUrl);
//         print('detailResp -> $detailResp');

//         Map<String, dynamic>? respMap;
//         if (detailResp is Map && detailResp['success'] == true && detailResp['booking'] != null) {
//           respMap = Map<String, dynamic>.from(detailResp['booking'] as Map);
//         } else if (detailResp is Map && detailResp.containsKey('booking_id')) {
//           respMap = Map<String, dynamic>.from(detailResp as Map);
//         }

//         if (respMap != null) {
//           final booking = Booking.fromJson(respMap);
//           if (!mounted) return;
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => BookingSummaryPage(booking: booking)),
//           );
//           return;
//         }
//       } catch (e) {
//         print('Error fetching booking detail after pay: $e');
//       }

     
//       _showSuccessFallback();
//       return;
//     } else {
     
//       print('Pay endpoint responded unexpectedly: $payResp');
//     }
//   } catch (e) {
//     print('Error calling pay endpoint: $e');
   
//   } finally {
   
//     if (mounted && _isLoading) setState(() { _isLoading = false; });
//   }


//   try {
//     final candidates = [
//       'http://localhost:8000/booking/api/$id/',
//       'http://localhost:8000/booking/$id/',
//     ];

//     Map<String, dynamic>? respMap;
//     for (final url in candidates) {
//       print('Trying fallback URL -> $url');
//       try {
//         final resp = await request.get(url);
//         print('Response for $url -> $resp');
//         if (resp is Map && resp['success'] == true && resp['booking'] != null) {
//           respMap = Map<String, dynamic>.from(resp['booking'] as Map);
//           break;
//         }
//         if (resp is Map && resp.containsKey('booking_id')) {
//           respMap = Map<String, dynamic>.from(resp as Map);
//           break;
//         }
//       } catch (e) {
//         print('Error requesting $url: $e');
//       }
//     }

//     if (respMap != null) {
      
//       await Future.delayed(const Duration(seconds: 1));
//       if (!mounted) return;
//       setState(() { _paymentComplete = true; });

//       final booking = Booking.fromJson(respMap);
//       if (!mounted) return;
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => BookingSummaryPage(booking: booking)),
//       );
//       return;
//     }
//   } catch (e) {
//     print('Fallback GET flow error: $e');
//   }


//   if (mounted) {
//     setState(() {
//       _isLoading = false;
//       _paymentComplete = true;
//     });
//   }
//   _showSuccessFallback();
// }


//   Widget _buildQrisCard() {
//     final payloadText = qrisPayload != null
//         ? (qrisPayload is String ? qrisPayload : const JsonEncoder.withIndent('  ').convert(qrisPayload))
//         : 'QRIS payload belum tersedia';
//     return Column(
//       children: [
//         Container(
//           width: 220,
//           height: 220,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             border: Border.all(color: Colors.grey[300]!, width: 2),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.qr_code_2,
//                 size: 140,
//                 color: Colors.grey[400],
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 'QRIS Code Placeholder',
//                 style: TextStyle(
//                   color: Colors.grey[500],
//                   fontSize: 12,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 12),
//         SizedBox(
//           width: 260,
//           child: SelectableText(
//             payloadText,
//             textAlign: TextAlign.center,
//             style: const TextStyle(fontSize: 12),
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final displayAmount = totalAmount ?? 0;
//     return Scaffold(
//       appBar: AppNavBar(title: 'Pembayaran'),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Ringkasan Pembayaran',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 16),
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//                       const Text('Booking ID'),
//                       Text(bookingId ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
//                     ]),
//                     const SizedBox(height: 12),
//                     Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//                       const Text('Total Pembayaran'),
//                       Text('Rp $displayAmount',
//                           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
//                     ]),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 32),
//               const Text('Metode Pembayaran (Simulasi)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 16),
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration:
//                     BoxDecoration(border: Border.all(color: const Color(0xFF2E7D32), width: 2), borderRadius: BorderRadius.circular(12), color: Colors.green[50]),
//                 child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                   const Row(children: [
//                     Icon(Icons.qr_code_2, color: Color(0xFF2E7D32), size: 28),
//                     SizedBox(width: 12),
//                     Text('QRIS (Simulasi)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                   ]),
//                   const SizedBox(height: 16),
//                   const Text('QRIS simulation for demo. In production, backend will return real QR / link.',
//                       style: TextStyle(fontSize: 13, color: Colors.grey)),
//                   const SizedBox(height: 16),
//                   Center(child: _buildQrisCard()),
//                   const SizedBox(height: 16),
//                   if (!_paymentComplete)
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: _isLoading ? null : _simulateQRISPayment,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF2E7D32),
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                         ),
//                         child: _isLoading
//                             ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
//                             : const Text('Pembayaran QRIS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                       ),
//                     ),
//                   if (!_paymentComplete) const SizedBox(height: 12),
//                   if (!_paymentComplete)
//                     SizedBox(
//                       width: double.infinity,
//                       child: OutlinedButton.icon(onPressed: _isLoading ? null : _simulateQRISPayment, icon: const Icon(Icons.account_balance), label: const Text('Transfer Bank / E-Wallet (Sim)')),
//                     ),
//                   if (_paymentComplete)
//                     Column(children: [
//                       const SizedBox(height: 12),
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: () {
//                             Navigator.popUntil(context, (route) => route.isFirst);
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF2E7D32),
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                           ),
//                           child: const Text('Kembali ke Home'),
//                         ),
//                       ),
//                     ])
//                 ]),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
