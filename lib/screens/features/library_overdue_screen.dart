import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import '../../theme/colors.dart';
import '../../widgets/common_widgets.dart';
import '../main_screen.dart';
import '../../services/api_service.dart';
import 'dart:developer' as dev;
import 'dart:async';
import 'package:edusphere/theme/typography.dart';

class LibraryOverdueScreen extends StatefulWidget {
  final RoleTheme theme;
  const LibraryOverdueScreen({super.key, required this.theme});

  @override
  State<LibraryOverdueScreen> createState() => _LibraryOverdueScreenState();
}

class _LibraryOverdueScreenState extends State<LibraryOverdueScreen> {
  bool _loading = false;
  List<Map<String, dynamic>> _overdueBooks = [];
  int _totalOverdue = 0;
  double _totalFines = 0.0;

  @override
  void initState() {
    super.initState();
    _loadOverdueBooks();
  }

  Future<void> _loadOverdueBooks() async {
    if (mounted) {
      setState(() {
        _loading = true;
      });
    }

    try {
      final response = await ApiService.instance.get('library/overdue');
      if (response != null && response['success'] == true) {
        final List<dynamic> rawList = response['overdueBooks'] ?? [];
        _overdueBooks = List<Map<String, dynamic>>.from(rawList);
        _totalOverdue = response['total'] as int? ?? _overdueBooks.length;

        double fines = 0.0;
        for (var b in _overdueBooks) {
          fines += (b['calculatedFine'] as num?)?.toDouble() ?? 0.0;
        }
        _totalFines = fines;
      }
    } catch (e) {
      dev.log('Error loading overdue books: $e', name: 'LibraryOverdueScreen');
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
      return intl.DateFormat('dd MMM yyyy').format(parsed);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          PageHeader(
            title: 'Overdue Books',
            subtitle: 'Library Fine Management',
            theme: widget.theme,
          ),
          
          // Stats summary
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10.r,
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('Total Overdue', '$_totalOverdue Books', AppColors.error),
                Container(width: 1.w, height: 40.h, color: AppColors.border),
                _buildStat('Pending Fines', '₹${_totalFines.toStringAsFixed(0)}', const Color(0xFF7C3AED)),
              ],
            ),
          ),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    color: widget.theme.primary,
                    onRefresh: _loadOverdueBooks,
                    child: _overdueBooks.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                            itemCount: _overdueBooks.length,
                            itemBuilder: (ctx, i) {
                              final item = _overdueBooks[i];
                              final book = item['book'] as Map<String, dynamic>? ?? {};
                              final studentObj = item['student'] as Map<String, dynamic>? ?? {};
                              final userObj = studentObj['user'] as Map<String, dynamic>? ?? {};
                              final firstName = userObj['firstName'] as String? ?? '';
                              final lastName = userObj['lastName'] as String? ?? '';
                              final borrowerName = '$firstName $lastName'.trim().isNotEmpty
                                  ? '$firstName $lastName'
                                  : 'Borrower';
                              
                              final title = book['title'] as String? ?? 'Untitled Book';
                              final author = book['author'] as String? ?? 'Unknown Author';
                              final days = item['daysOverdue'] as int? ?? 0;
                              final fine = (item['calculatedFine'] as num?)?.toDouble() ?? 0.0;
                              final dueDateStr = item['dueDate'] as String?;

                              return Container(
                                margin: EdgeInsets.only(bottom: 12.h),
                                padding: EdgeInsets.all(16.r),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: Border.all(color: AppColors.border),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.01),
                                      blurRadius: 8.r,
                                    )
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48.w,
                                      height: 48.h,
                                      decoration: BoxDecoration(
                                        color: AppColors.error.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                      child: Icon(
                                        Icons.menu_book_rounded,
                                        color: AppColors.error,
                                        size: 24.sp,
                                      ),
                                    ),
                                    SizedBox(width: 14.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title,
                                            style: AppTypography.small.copyWith(
                                                color: AppColors.textDark,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            'By $author',
                                            style: AppTypography.caption.copyWith(
                                                color: AppColors.textMedium),
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            'Issued to: $borrowerName',
                                            style: AppTypography.caption.copyWith(
                                                color: AppColors.textLight),
                                          ),
                                          Text(
                                            'Due Date: ${_formatDate(dueDateStr)}',
                                            style: AppTypography.caption.copyWith(
                                                color: AppColors.textLight),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '₹${fine.toStringAsFixed(0)}',
                                          style: AppTypography.body.copyWith(
                                              color: AppColors.error,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          '$days days late',
                                          style: AppTypography.caption.copyWith(
                                              color: AppColors.textMedium),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.bodyLarge.copyWith(
              color: color, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: AppTypography.caption.copyWith(color: AppColors.textLight),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 64.sp,
            color: const Color(0xFF10B981),
          ),
          SizedBox(height: 16.h),
          Text(
            'All Clear!',
            style: AppTypography.body.copyWith(
                color: AppColors.textDark, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4.h),
          Text(
            'There are no overdue books or pending fines.',
            style: AppTypography.caption.copyWith(color: AppColors.textMedium),
          ),
        ],
      ),
    );
  }
}
