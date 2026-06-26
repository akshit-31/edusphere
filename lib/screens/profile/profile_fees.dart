import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/colors.dart';
import 'package:edusphere/theme/typography.dart';

class ProfileFees extends StatelessWidget {
  final Map<String, dynamic>? feeLedger;
  final List<Map<String, dynamic>> feePayments;
  final String batch;

  const ProfileFees({
    super.key,
    required this.feeLedger,
    required this.feePayments,
    required this.batch,
  });

  @override
  Widget build(BuildContext context) {
    final double payable = feeLedger != null
        ? double.tryParse(feeLedger!['totalPayable']?.toString() ?? '0') ?? 0.0
        : 0.0;
    final double paid = feeLedger != null
        ? double.tryParse(feeLedger!['totalPaid']?.toString() ?? '0') ?? 0.0
        : 0.0;
    final double pending = feeLedger != null
        ? (double.tryParse(feeLedger!['totalPending']?.toString() ?? '') ?? (payable - paid))
        : 0.0;
    final String status = feeLedger != null
        ? feeLedger!['status']?.toString() ?? 'PENDING'
        : 'PENDING';
    final String structureName = feeLedger != null && feeLedger!['feeStructure'] != null
        ? feeLedger!['feeStructure']['name'].toString()
        : (feeLedger != null ? 'Fee Structure' : 'No Active Fee Structure');

    Color statusColor = const Color(0xFFF59E0B);
    Color statusBg = const Color(0xFFFFFBEB);
    if (status.toUpperCase() == 'PAID') {
      statusColor = const Color(0xFF10B981);
      statusBg = const Color(0xFFECFDF5);
    } else if (status.toUpperCase() == 'PENDING') {
      statusColor = const Color(0xFFEF4444);
      statusBg = const Color(0xFFFEF2F2);
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFE2EAF4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      structureName,
                      style: AppTypography.small.copyWith(color: const Color(0xFF0F2547)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      status.replaceAll('_', ' ').toUpperCase(),
                      style: AppTypography.caption.copyWith(color: statusColor),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              _buildGridRow(
                'Total Fee Payable',
                '₹${payable.toStringAsFixed(2)}',
                'Total Amount Paid',
                '₹${paid.toStringAsFixed(2)}',
              ),
              SizedBox(height: 16.h),
              _buildGridRow(
                'Pending Balance',
                '₹${pending.toStringAsFixed(2)}',
                'Academic Year',
                batch,
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFE2EAF4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent Payment Transactions',
                style: AppTypography.small.copyWith(color: const Color(0xFF0F2547)),
              ),
              SizedBox(height: 16.h),
              if (feePayments.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: Center(
                    child: Text(
                      'No payment transactions found.',
                      style: AppTypography.caption.copyWith(color: AppColors.textLight),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: feePayments.length,
                  itemBuilder: (ctx, idx) {
                    final p = feePayments[idx];
                    final receipt = p['receiptNumber']?.toString() ?? '—';
                    final amount = double.tryParse(p['amount']?.toString() ?? '0') ?? 0.0;
                    final dateStr = p['paymentDate']?.toString() ?? '—';
                    final mode = p['paymentMode']?.toString() ?? 'ONLINE';
                    return _buildFeePaymentRow(receipt, amount, dateStr, mode);
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGridRow(String label1, String value1, String label2, String value2) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label1, style: AppTypography.caption.copyWith(color: const Color(0xFF64748B))),
              SizedBox(height: 4.h),
              Text(value1, style: AppTypography.caption.copyWith(color: const Color(0xFF0F2547)), maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label2, style: AppTypography.caption.copyWith(color: const Color(0xFF64748B))),
              SizedBox(height: 4.h),
              Text(value2, style: AppTypography.caption.copyWith(color: const Color(0xFF0F2547)), maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeePaymentRow(String receipt, double amount, String dateStr, String mode) {
    String formattedDate = dateStr;
    try {
      final dateObj = DateTime.parse(dateStr);
      formattedDate = '${dateObj.day}/${dateObj.month}/${dateObj.year}';
    } catch (_) {}

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE2EAF4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Receipt #$receipt', style: AppTypography.caption.copyWith(color: const Color(0xFF0F2547))),
              SizedBox(height: 2.h),
              Text('Paid on $formattedDate via $mode', style: AppTypography.caption.copyWith(color: const Color(0xFF868E96))),
            ],
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: AppTypography.caption.copyWith(color: const Color(0xFF10B981)),
          ),
        ],
      ),
    );
  }
}
