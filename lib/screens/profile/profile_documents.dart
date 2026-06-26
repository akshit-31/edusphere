import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/colors.dart';

class ProfileDocuments extends StatelessWidget {
  final List<Map<String, String>> uploadedDocuments;
  final Function(int index) onRemoveDocument;

  const ProfileDocuments({
    super.key,
    required this.uploadedDocuments,
    required this.onRemoveDocument,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
          child: Text(
            '📁 Documents Asset Vault',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: Colors.white, 
            borderRadius: BorderRadius.circular(24.r), 
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (uploadedDocuments.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    child: Column(
                      children: [
                        Icon(Icons.insert_drive_file_outlined, size: 48.sp, color: AppColors.textLight),
                        SizedBox(height: 12.h),
                        Text(
                          'No documents uploaded yet',
                          style: GoogleFonts.inter(fontSize: 13.sp, color: AppColors.textLight),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: uploadedDocuments.length,
                  separatorBuilder: (context, idx) => SizedBox(height: 10.h),
                  itemBuilder: (context, idx) {
                    final doc = uploadedDocuments[idx];
                    final String name = doc['name'] ?? 'Document';
                    final String date = doc['date'] ?? '—';
                    final String url = doc['url'] ?? '';
                    final bool isPdf = name.toLowerCase().endsWith('.pdf');
                    return GestureDetector(
                      onTap: () async {
                        if (url.isNotEmpty) {
                          try {
                            final uri = Uri.parse(url);
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Could not open document. Please check if a viewer is installed.')),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Document link is unavailable.')),
                          );
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: const Color(0xFFE2EAF4)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                color: isPdf ? const Color(0xFFFEF2F2) : const Color(0xFFEFF6FF),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isPdf ? Icons.picture_as_pdf_rounded : Icons.image_rounded, 
                                size: 20.sp, 
                                color: isPdf ? const Color(0xFFEF4444) : const Color(0xFF3B82F6),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name, 
                                    style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColors.textDark),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    'Uploaded on: $date', 
                                    style: GoogleFonts.inter(fontSize: 10.sp, color: AppColors.textLight),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 18.sp),
                              onPressed: () => onRemoveDocument(idx),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}
