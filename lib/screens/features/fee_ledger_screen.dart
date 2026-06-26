import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../services/socket_service.dart';
import 'package:file_saver/file_saver.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/colors.dart';
import 'fee_payment_screen.dart';
import 'dart:async';
import 'dart:developer' as dev;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import '../../services/api_service.dart';
class FeeLedgerScreen extends StatefulWidget {
  final RoleTheme theme;
  final bool showBackButton;
  const FeeLedgerScreen({super.key, required this.theme, this.showBackButton = true});

  @override
  State<FeeLedgerScreen> createState() => _FeeLedgerScreenState();
}

class _FeeLedgerScreenState extends State<FeeLedgerScreen> {
  bool _loading = false;

  // Summary values
  double _totalFee = 0;
  double _totalPaid = 0;
  double get _balance => _totalFee - _totalPaid;

  // Fee heads list
  List<Map<String, dynamic>> _feeHeads = [];

  // Payment history list
  List<Map<String, dynamic>> _paymentHistory = [];

  // Student info
  String _studentId = '';
  String _studentName = 'Student';
  String _studentEmail = '';
  String _feeStructureId = '';
  String _ledgerId = '';
  String _academicYearId = '';

  Timer? _feePollTimer;

  @override
  void initState() {
    super.initState();
    _loadLedgerData(showLoading: true);
    _connectRealTime();
  }

  @override
  void dispose() {
    _feePollTimer?.cancel();
    try {
      SocketService().off('FEE_UPDATED');
    } catch (e) {
      dev.log('Error unregistering Socket.IO events: $e', name: 'FeeLedgerScreen');
    }
    super.dispose();
  }

  void _connectRealTime() {
    try {
      dev.log('📡 Subscribing to Socket.IO changes for Fees Screen...', name: 'FeeLedgerScreen');
      
      SocketService().on('FEE_UPDATED', (payload) {
        dev.log('🔥 Real-time fee event received | Data: $payload', name: 'FeeLedgerScreen');
        if (mounted) {
          _loadLedgerData(showLoading: false);
        }
      });
    } catch (e) {
      dev.log('⚠️ Error connecting Socket.IO for Fees: $e', name: 'FeeLedgerScreen');
    }
    
    // Polling fallback
    _feePollTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _loadLedgerData(showLoading: false);
      }
    });
  }



  Future<void> _loadLedgerData({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _loading = true;
      });
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      _studentId = prefs.getString('student_id') ?? '';
      _studentName = prefs.getString('student_name') ?? prefs.getString('user_name') ?? 'Student';
      _studentEmail = prefs.getString('student_email') ?? prefs.getString('user_email') ?? '';

      final response = await ApiService.instance.get('fees/students/$_studentId/status');
      
      if (response != null && response['success'] == true) {
        final List<dynamic> ledgers = response['ledgers'] as List<dynamic>? ?? [];
        final List<Map<String, dynamic>> heads = [];
        double totalFee = 0;
        double totalPaid = 0;

        for (var entry in ledgers) {
          final structure = entry['feeStructure'] as Map<String, dynamic>? ?? {};
          _feeStructureId = structure['id']?.toString() ?? '';
          _ledgerId = entry['id']?.toString() ?? '';
          if (entry['academicYearId'] != null) {
            _academicYearId = entry['academicYearId']?.toString() ?? '';
          }
          
          final headName = structure['name']?.toString() ?? 'Fee';
          final amount = (entry['totalPayable'] ?? structure['totalAmount'] ?? 0).toDouble();
          final paid = (entry['totalPaid'] ?? 0).toDouble();
          final status = entry['status']?.toString() ?? 'PENDING';
          
          totalFee += amount;
          totalPaid += paid;

          heads.add({
            'id': entry['id'],
            'name': headName,
            'amount': amount,
            'paid': paid,
            'status': status == 'PAID' ? 'PAID' : (paid > 0 ? 'PARTIAL' : 'PENDING'),
            'feeStructureId': _feeStructureId,
            'academicYearId': _academicYearId,
          });
        }
        
        _feeHeads = heads;
        _totalFee = totalFee;
        _totalPaid = totalPaid;

        // Process recent payments
        final List<dynamic> payments = response['recentPayments'] as List<dynamic>? ?? [];
        _paymentHistory = payments.map((p) {
          return {
            'date': p['paymentDate']?.toString() ?? p['createdAt']?.toString() ?? '',
            'amount': (p['amount'] as num? ?? 0).toDouble(),
            'method': p['paymentMode']?.toString() ?? 'UPI',
            'receipt': p['receiptNumber']?.toString() ?? 'RCT-00000000',
            'status': p['status']?.toString() ?? 'SUCCESS',
          };
        }).toList();
      }

    } catch (e) {
      _feeHeads = [];
      _totalFee = 0;
      _totalPaid = 0;
      _paymentHistory = [];
      debugPrint('Error loading fee ledger via REST API: $e');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }



  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final parsed = DateTime.parse(dateStr);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${parsed.day.toString().padLeft(2, '0')} ${months[parsed.month - 1]} ${parsed.year}';
    } catch (e) {
      return dateStr;
    }
  }

  String _formatCurrency(double amount) {
    if (amount >= 100000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }
    final str = amount.toStringAsFixed(0);
    // Add commas for Indian numbering
    final parts = <String>[];
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      parts.insert(0, str[i]);
      count++;
      if (count == 3 && i > 0) {
        parts.insert(0, ',');
        count = 0;
      }
    }
    return '₹${parts.join('')}';
  }

  Future<void> _downloadStatement() async {
    // Show a loading snackbar
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text('Generating PDF receipt...', style: GoogleFonts.inter(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
        backgroundColor: const Color(0xFF1A6FDB),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );

    try {
      final pdf = pw.Document();
      final now = DateTime.now();
      final dateStr = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
      final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      final receiptNo = 'STMT-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch % 100000}';

      // Colors
      final primaryBlue = PdfColor.fromHex('#1A6FDB');
      final darkText = PdfColor.fromHex('#0F172A');
      final lightGray = PdfColor.fromHex('#F8FAFC');
      final borderGray = PdfColor.fromHex('#E2E8F0');
      final greenColor = PdfColor.fromHex('#10B981');
      final redColor = PdfColor.fromHex('#EF4444');

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // ── Header ──────────────────────────────────────────
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: primaryBlue,
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('EDUSPHERE',
                            style: pw.TextStyle(
                              fontSize: 22,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                            )),
                        pw.SizedBox(height: 4),
                        pw.Text('Smart School ERP',
                             style: const pw.TextStyle(fontSize: 11, color: PdfColors.white)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('FEE STATEMENT',
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                            )),
                        pw.SizedBox(height: 4),
                        pw.Text('Receipt #: $receiptNo',
                            style: const pw.TextStyle(fontSize: 9, color: PdfColors.white)),
                        pw.Text('Date: $dateStr  $timeStr',
                            style: const pw.TextStyle(fontSize: 9, color: PdfColors.white)),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // ── Student Info ──────────────────────────────────
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: lightGray,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: borderGray),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('STUDENT DETAILS',
                              style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 6),
                          pw.Text(_studentName.isNotEmpty ? _studentName : 'Student',
                              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: darkText)),
                          if (_studentEmail.isNotEmpty)
                            pw.Text(_studentEmail, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                          pw.Text('Student ID: $_studentId',
                              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                        ],
                      ),
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('FINANCIAL SUMMARY',
                            style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 6),
                        pw.Text('Total Fee: ${_formatCurrency(_totalFee)}',
                            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: darkText)),
                        pw.Text('Total Paid: ${_formatCurrency(_totalPaid)}',
                            style: pw.TextStyle(fontSize: 11, color: greenColor, fontWeight: pw.FontWeight.bold)),
                        pw.Text(
                            'Balance Due: ${_formatCurrency(_balance)}',
                            style: pw.TextStyle(
                              fontSize: 11,
                              color: _balance > 0 ? redColor : greenColor,
                              fontWeight: pw.FontWeight.bold,
                            )),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // ── Fee Breakdown Table ──────────────────────────
              if (_feeHeads.isNotEmpty) ...[
                pw.Text('FEE BREAKDOWN',
                    style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: darkText)),
                pw.SizedBox(height: 8),
                pw.Table(
                  border: pw.TableBorder.all(color: borderGray, width: 0.5),
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: primaryBlue),
                      children: [
                        _pdfCell('Fee Head', isHeader: true, color: PdfColors.white),
                        _pdfCell('Total Amount', isHeader: true, color: PdfColors.white),
                        _pdfCell('Paid', isHeader: true, color: PdfColors.white),
                        _pdfCell('Due', isHeader: true, color: PdfColors.white),
                        _pdfCell('Status', isHeader: true, color: PdfColors.white),
                      ],
                    ),
                    ..._feeHeads.map((head) {
                      final amount = head['amount'] as double;
                      final paid = head['paid'] as double;
                      final due = amount - paid;
                      final status = head['status'] as String;
                      return pw.TableRow(
                        children: [
                          _pdfCell(head['name'] as String),
                          _pdfCell(_formatCurrency(amount)),
                          _pdfCell(_formatCurrency(paid), textColor: greenColor),
                          _pdfCell(_formatCurrency(due), textColor: due > 0 ? redColor : greenColor),
                          _pdfCell(status,
                              textColor: status == 'PAID' ? greenColor : status == 'PARTIAL' ? PdfColor.fromHex('#F59E0B') : redColor),
                        ],
                      );
                    }),
                  ],
                ),
                pw.SizedBox(height: 20),
              ],

              // ── Payment History Table ────────────────────────
              pw.Text('PAYMENT HISTORY',
                  style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: darkText)),
              pw.SizedBox(height: 8),
              if (_paymentHistory.isEmpty)
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: lightGray,
                    borderRadius: pw.BorderRadius.circular(6),
                    border: pw.Border.all(color: borderGray),
                  ),
                  child: pw.Center(
                    child: pw.Text('No payment records found.',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                  ),
                )
              else
                pw.Table(
                  border: pw.TableBorder.all(color: borderGray, width: 0.5),
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: primaryBlue),
                      children: [
                        _pdfCell('Date', isHeader: true, color: PdfColors.white),
                        _pdfCell('Method', isHeader: true, color: PdfColors.white),
                        _pdfCell('Receipt No.', isHeader: true, color: PdfColors.white),
                        _pdfCell('Amount', isHeader: true, color: PdfColors.white),
                        _pdfCell('Status', isHeader: true, color: PdfColors.white),
                      ],
                    ),
                    ..._paymentHistory.map((p) {
                      final status = (p['status'] as String? ?? 'SUCCESS').toUpperCase();
                      return pw.TableRow(
                        children: [
                          _pdfCell(_formatDate(p['date'] as String?)),
                          _pdfCell(p['method'] as String? ?? 'UPI'),
                          _pdfCell(p['receipt'] as String? ?? '—'),
                          _pdfCell(_formatCurrency(p['amount'] as double),
                              textColor: greenColor),
                          _pdfCell(status,
                              textColor: status == 'SUCCESS' ? greenColor : redColor),
                        ],
                      );
                    }),
                  ],
                ),
              pw.SizedBox(height: 24),

              // ── Footer ──────────────────────────────────────
              pw.Divider(color: borderGray),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Generated by EduSphere • $dateStr $timeStr',
                      style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
                  pw.Text('This is a system-generated statement.',
                      style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
                ],
              ),
            ];
          },
        ),
      );

      // Generate PDF bytes
      final pdfBytes = await pdf.save();
      final fileName = 'FeeStatement_$receiptNo.pdf';

      dev.log('✅ PDF generated: $fileName', name: 'FeeLedgerScreen');

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Use file_saver for all platforms (Web, Android, iOS, Desktop)
      final savedPath = await FileSaver.instance.saveFile(
        name: fileName.replaceAll('.pdf', ''),
        bytes: pdfBytes,
        fileExtension: 'pdf',
        mimeType: MimeType.pdf,
      );

      dev.log('✅ File saved to: $savedPath', name: 'FeeLedgerScreen');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Statement downloaded successfully',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );

    } catch (e) {
      dev.log('❌ PDF generation error: $e', name: 'FeeLedgerScreen');
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download PDF: $e',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.white)),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Helper: create a PDF table cell
  pw.Widget _pdfCell(String text, {bool isHeader = false, PdfColor? color, PdfColor? textColor}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 9 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: textColor ?? color ?? PdfColor.fromHex('#0F172A'),
        ),
      ),
    );
  }

  Widget _buildStatementSummary() {
    final double completionPercent = _totalFee == 0 ? 0.0 : (_totalPaid / _totalFee).clamp(0.0, 1.0);
    final String progressText = "${(completionPercent * 100).toStringAsFixed(0)}% Completed";

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.currency_rupee_rounded,
                  color: const Color(0xFF1A6FDB),
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Statement Summary',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _summaryStatColumn('Total Fees (Year)', _formatCurrency(_totalFee), const Color(0xFF0F172A)),
              _summaryStatColumn('Total Paid', _formatCurrency(_totalPaid), const Color(0xFF10B981)),
              _summaryStatColumn('Outstanding Due', _formatCurrency(_balance), const Color(0xFFEF4444)),
            ],
          ),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment Progress',
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
              Text(
                progressText,
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A6FDB),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: completionPercent,
              minHeight: 6.h,
              backgroundColor: const Color(0xFFF1F5F9),
              color: const Color(0xFF1A6FDB),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryStatColumn(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedLedger() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.r, 20.r, 20.r, 16.r),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.description_outlined,
                    color: const Color(0xFF1A6FDB),
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detailed Fee Ledger',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                        fontSize: 16.sp,
                      ),
                    ),
                    Text(
                      'Breakdown by fee structure items',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              width: 650.w, // Wide enough to perfectly fit all columns like the first image
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      border: Border(
                        top: BorderSide(color: Color(0xFFF1F5F9)),
                        bottom: BorderSide(color: Color(0xFFF1F5F9)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: _headerText('Fee Structure')),
                        Expanded(flex: 2, child: _headerText('Total', align: TextAlign.center)),
                        Expanded(flex: 2, child: _headerText('Paid', align: TextAlign.center)),
                        Expanded(flex: 2, child: _headerText('Due', align: TextAlign.center)),
                        Expanded(flex: 2, child: _headerText('Status', align: TextAlign.center)),
                        Expanded(flex: 2, child: _headerText('Action', align: TextAlign.center)),
                      ],
                    ),
                  ),
                  ..._feeHeads.map((head) {
                    final name = head['name'] as String;
                    final amount = head['amount'] as double;
                    final paid = head['paid'] as double;
                    final due = amount - paid;
                    final status = head['status'] as String;

                    Color statusColor = const Color(0xFFEF4444);
                    Color statusBg = const Color(0xFFFEF2F2);
                    if (status == 'PAID') {
                      statusColor = const Color(0xFF10B981);
                      statusBg = const Color(0xFFECFDF5);
                    } else if (status == 'PARTIAL') {
                      statusColor = const Color(0xFFF59E0B);
                      statusBg = const Color(0xFFFFFBEB);
                    }

                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'TUITION',
                                  style: GoogleFonts.inter(fontSize: 10.sp, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8)),
                                ),
                              ],
                            ),
                          ),
                          Expanded(flex: 2, child: Text(_formatCurrency(amount), textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)))),
                          Expanded(flex: 2, child: Text(_formatCurrency(paid), textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xFF10B981)))),
                          Expanded(flex: 2, child: Text(_formatCurrency(due), textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xFFEF4444)))),
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(6.r)),
                                child: Text(status, style: GoogleFonts.inter(fontSize: 9.sp, fontWeight: FontWeight.w800, color: statusColor)),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: due > 0
                                  ? SizedBox(
                                      height: 32.h,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF1A6FDB),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => FeePaymentScreen(
                                                theme: widget.theme,
                                                outstandingAmount: due,
                                                studentId: _studentId,
                                                feeStructureId: _feeStructureId,
                                                ledgerId: _ledgerId,
                                                academicYearId: _academicYearId,
                                              ),
                                            ),
                                          ).then((_) => _loadLedgerData());
                                        },
                                        child: Text('Pay Now', style: GoogleFonts.inter(fontSize: 11.sp, fontWeight: FontWeight.w700)),
                                      ),
                                    )
                                  : const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerText(String text, {TextAlign align = TextAlign.left}) {
    return Text(
      text,
      textAlign: align,
      style: GoogleFonts.inter(fontSize: 11.sp, fontWeight: FontWeight.w700, color: const Color(0xFF64748B)),
    );
  }

  Widget _buildRecentHistory() {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.access_time_rounded,
                  color: const Color(0xFF1A6FDB),
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent History',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      fontSize: 16.sp,
                    ),
                  ),
                  Text(
                    'Last 3 transactions',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24.h),
          if (_paymentHistory.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Center(
                child: Text(
                  'No transaction history',
                  style: GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
                ),
              ),
            )
          else
            Column(
              children: [
                ..._paymentHistory.take(3).map((payment) {
                  final date = _formatDate(payment['date'] as String?);
                  final amount = payment['amount'] as double;
                  final receipt = payment['receipt'] as String;

                  return Container(
                    padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
                    margin: EdgeInsets.only(bottom: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFE2EAF4)),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatCurrency(amount),
                              style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: const Color(0xFF0F172A), fontSize: 14.sp),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              date,
                              style: GoogleFonts.inter(fontSize: 11.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6.r),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Text(
                                payment['method']?.toString().toUpperCase() ?? 'PAID',
                                style: GoogleFonts.inter(fontSize: 9.sp, fontWeight: FontWeight.w800, color: const Color(0xFF475569)),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              receipt.startsWith('#') ? receipt : '#$receipt',
                              style: GoogleFonts.inter(fontSize: 10.sp, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
            
          SizedBox(height: 16.h),
          Center(
            child: TextButton.icon(
              onPressed: _downloadStatement,
              icon: Icon(Icons.picture_as_pdf_outlined, color: const Color(0xFF1A6FDB), size: 18.sp),
              label: Text(
                'Download Statement (PDF)',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A6FDB),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Row(
                children: [
                  if (widget.showBackButton) ...[
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 4.r,
                            )
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16.sp,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Finance Overview',
                          style: GoogleFonts.inter(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF1A6FDB),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Manage your school fee payments and receipts',
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.studentPrimary))
                  : RefreshIndicator(
                      onRefresh: () => _loadLedgerData(showLoading: true),
                      color: widget.theme.primary,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStatementSummary(),
                            SizedBox(height: 20.h),
                            if (isDesktop)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: _buildDetailedLedger(),
                                  ),
                                  SizedBox(width: 20.w),
                                  Expanded(
                                    flex: 3,
                                    child: _buildRecentHistory(),
                                  ),
                                ],
                              )
                            else ...[
                              _buildDetailedLedger(),
                              SizedBox(height: 20.h),
                              _buildRecentHistory(),
                            ],
                            SizedBox(height: 40.h),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
