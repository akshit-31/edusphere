import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/colors.dart';

class ProfileHeader extends StatelessWidget {
  final String studentName;
  final String studentClass;
  final String section;
  final String rollNo;
  final String admissionNo;
  final bool isUploadingDoc;
  final VoidCallback onEditProfile;
  final VoidCallback onUploadDocument;

  const ProfileHeader({
    super.key,
    required this.studentName,
    required this.studentClass,
    required this.section,
    required this.rollNo,
    required this.admissionNo,
    required this.isUploadingDoc,
    required this.onEditProfile,
    required this.onUploadDocument,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> parts = studentName.trim().split(RegExp(r'\s+'));
    final String initials = parts.length >= 2 
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : (parts.isNotEmpty && parts[0].isNotEmpty ? parts[0][0].toUpperCase() : 'ST');

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: const Color(0xFFE2EAF4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 80.r,
                height: 80.r,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: GoogleFonts.inter(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0284C7),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              // Student Metadata
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            studentName,
                            style: GoogleFonts.inter(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        GestureDetector(
                          onTap: onEditProfile,
                          child: Container(
                            padding: EdgeInsets.all(4.r),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.edit_rounded, size: 14.sp, color: AppColors.textDark),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            admissionNo,
                            style: GoogleFonts.inter(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF166534),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(Icons.school_rounded, size: 14.sp, color: AppColors.textLight),
                        SizedBox(width: 4.w),
                        Text(
                          'Class $studentClass${section != '—' && section.isNotEmpty ? ' - $section' : ''}',
                          style: GoogleFonts.inter(fontSize: 12.sp, color: AppColors.textMedium),
                        ),
                        SizedBox(width: 12.w),
                        Icon(Icons.badge_rounded, size: 14.sp, color: AppColors.textLight),
                        SizedBox(width: 4.w),
                        Text(
                          'Roll No. $rollNo',
                          style: GoogleFonts.inter(fontSize: 12.sp, color: AppColors.textMedium),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Container(
                          width: 8.r,
                          height: 8.r,
                          decoration: const BoxDecoration(
                            color: Color(0xFF22C55E),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'Active Profile',
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF166534),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          // Upload Document Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isUploadingDoc ? null : onUploadDocument,
              icon: isUploadingDoc 
                  ? SizedBox(
                      width: 16.r, 
                      height: 16.r, 
                      child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.textDark),
                    )
                  : const Icon(Icons.add, size: 18),
              label: Text(
                isUploadingDoc ? 'Uploading...' : 'Upload Document',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF1F5F9),
                foregroundColor: AppColors.textDark,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
