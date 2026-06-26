import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/colors.dart';

class ProfileInfoCard extends StatelessWidget {
  final String studentGender;
  final String studentDob;
  final String studentBloodGroup;
  final String religion;
  final String casteGroup;
  final String nationality;

  const ProfileInfoCard({
    super.key,
    required this.studentGender,
    required this.studentDob,
    required this.studentBloodGroup,
    required this.religion,
    required this.casteGroup,
    required this.nationality,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
          child: Text(
            '👤 Core Identity',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: Colors.white, 
            borderRadius: BorderRadius.circular(24.r), 
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _infoRow(Icons.person_outline_rounded, 'Gender', studentGender),
              _divider(),
              _infoRow(Icons.cake_outlined, 'Date of Birth', studentDob),
              _divider(),
              _infoRow(Icons.water_drop_outlined, 'Blood Group', studentBloodGroup),
              _divider(),
              _infoRow(Icons.account_balance_rounded, 'Religion', religion),
              _divider(),
              _infoRow(Icons.groups_outlined, 'Caste Group', casteGroup),
              _divider(),
              _infoRow(Icons.public_rounded, 'Nationality', nationality),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String k, String v) => Padding(
    padding: EdgeInsets.symmetric(vertical: 4.h),
    child: Row(
      children: [
        Icon(icon, size: 18.sp, color: AppColors.textLight),
        SizedBox(width: 12.w),
        Text(k, style: GoogleFonts.inter(fontSize: 13.sp, color: AppColors.textMedium)),
        const Spacer(),
        Text(v, style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.textDark)),
      ],
    ),
  );

  Widget _divider() => Divider(height: 24.h, color: AppColors.border.withValues(alpha: 0.5));
}
