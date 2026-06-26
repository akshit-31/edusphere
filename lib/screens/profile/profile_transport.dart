import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:edusphere/theme/typography.dart';

class ProfileTransport extends StatelessWidget {
  final Map<String, dynamic>? transportAllocation;

  const ProfileTransport({
    super.key,
    required this.transportAllocation,
  });

  @override
  Widget build(BuildContext context) {
    final String routeName = transportAllocation != null && transportAllocation!['route'] != null
        ? transportAllocation!['route']['name'].toString()
        : 'Route 102 - North Delhi Bypass';
    final String stopName = transportAllocation != null && transportAllocation!['stop'] != null
        ? transportAllocation!['stop']['name'].toString()
        : 'Rohini Sector 15 Crossing';
    final String startLoc = transportAllocation != null && transportAllocation!['route'] != null
        ? transportAllocation!['route']['startLocation']?.toString() ?? 'School Campus'
        : 'School Campus';
    final String endLoc = transportAllocation != null && transportAllocation!['route'] != null
        ? transportAllocation!['route']['endLocation']?.toString() ?? 'Rohini Bus Depot'
        : 'Rohini Bus Depot';
    final String transStatus = transportAllocation != null
        ? transportAllocation!['status'].toString()
        : 'ACTIVE';

    return Container(
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
              Text(
                'Transport Bus Allocation',
                style: AppTypography.small.copyWith(color: const Color(0xFF0F2547)),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  transStatus.toUpperCase(),
                  style: AppTypography.caption.copyWith(color: const Color(0xFF10B981)),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          _buildGridRow('Assigned Route', routeName, 'Assigned Bus Stop', stopName),
          SizedBox(height: 16.h),
          _buildGridRow('Route Start Location', startLoc, 'Route End Location', endLoc),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFE2EAF4)),
            ),
            child: Row(
              children: [
                Icon(Icons.directions_bus_filled_outlined, color: const Color(0xFF1A6FDB), size: 20.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Bus routes run on schedule every working day. Student scans RFID card upon entry and exit for real-time tracking.',
                    style: AppTypography.caption.copyWith(color: const Color(0xFF64748B), height: 1.3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
}
