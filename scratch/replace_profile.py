import os

file_path = "c:/final edusphere app/edusphere/lib/screens/profile_screen.dart"
with open(file_path, "r", encoding="utf-8") as f:
    lines = f.readlines()

# find exact start and end
start_idx = -1
end_idx = -1
for i, line in enumerate(lines):
    if line.startswith("  Widget _buildTeacherProfile() {"):
        start_idx = i
    if line.startswith("  Widget _buildBulletPoint(String text) {"):
        end_idx = i
        break

new_content = """  Widget _buildTeacherProfile() {
    final bool isPushed = Navigator.canPop(context);

    return Scaffold(
      key: _teacherScaffoldKey,
      drawer: isPushed ? const EduSphereDrawer(role: 'teacher', activeLabel: 'My Profile') : null,
      bottomNavigationBar: isPushed ? const TeacherBottomNavBar(activeIndex: 13) : null,
      backgroundColor: const Color(0xFFEFF6FF), // From image background color
      appBar: widget.showAppBar
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
              leading: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => _teacherScaffoldKey.currentState?.openDrawer(),
              ),
              actions: [
                IconButton(
                  icon: Stack(
                    children: [
                      Icon(Icons.notifications_none, color: const Color(0xFF0F172A), size: 22.sp),
                      Positioned(
                        right: 2,
                        top: 2,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                        ),
                      )
                    ],
                  ),
                  onPressed: () {},
                ),
                SizedBox(width: 8.w),
              ],
            )
          : null,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.r, 20.r, 16.r, 120.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Subtitle Header
            Text(
              'My Profile',
              style: GoogleFonts.outfit(
                fontSize: 24.sp,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF0F2547),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Manage your account and view your detailed\\ninformation',
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                color: const Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            SizedBox(height: 24.h),

            // Core Profile Card
            _buildCoreProfileCard(),
            SizedBox(height: 16.h),

            // Summary Cards
            _buildSummaryCard('Last Session', _lastSession, Icons.access_time_rounded, const Color(0xFF3B82F6), true),
            SizedBox(height: 16.h),
            _buildSummaryCard('Activity Status', _activityStatus, Icons.check_circle_outline, const Color(0xFF10B981), false),
            SizedBox(height: 16.h),
            _buildSummaryCard('Employment', _designation, Icons.business_center_outlined, const Color(0xFF8B5CF6), false, true),
            SizedBox(height: 16.h),
            _buildSummaryCard('Joined Date', _joinedDate, Icons.calendar_month_outlined, const Color(0xFF06B6D4), false),
            SizedBox(height: 24.h),

            // Detail Cards
            _buildPersonalInfoCard(),
            SizedBox(height: 16.h),
            _buildIdentityInfoCard(),
            SizedBox(height: 16.h),
            _buildSecurityStatusCard(),
            SizedBox(height: 16.h),
            _buildNotificationPreferencesCard(),
            SizedBox(height: 16.h),
            _buildTeacherDigitalIdentityCard(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showEditProfileSheet,
        backgroundColor: const Color(0xFF0284C7),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: const Icon(Icons.edit_note, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color, bool isTopBorder, [bool isUpperValue = false]) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -20.w,
            top: -24.h,
            bottom: -24.h,
            child: Container(
              width: 4.w,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  bottomLeft: Radius.circular(16.r),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    isUpperValue ? value.toUpperCase() : value,
                    style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 16.sp),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoreProfileCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Initials circle avatar with edit overlays
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 90.r,
                height: 90.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 3),
                  image: (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                      ? DecorationImage(image: NetworkImage(_avatarUrl!), fit: BoxFit.cover)
                      : const DecorationImage(image: AssetImage('assets/images/bus.png'), fit: BoxFit.cover), // placeholder image like in mockup
                ),
              ),
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(Icons.camera_alt_outlined, color: Colors.white, size: 12.sp),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          Text(
            _userName,
            style: GoogleFonts.inter(
              fontSize: 22.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F2547),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              widget.role.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2563EB),
                letterSpacing: 0.5,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16.w,
            runSpacing: 8.h,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.email_outlined, size: 16.sp, color: const Color(0xFF64748B)),
                  SizedBox(width: 6.w),
                  Text(
                    _email,
                    style: GoogleFonts.inter(fontSize: 13.sp, color: const Color(0xFF475569)),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.phone_outlined, size: 16.sp, color: const Color(0xFF64748B)),
                  SizedBox(width: 6.w),
                  Text(
                    _phone,
                    style: GoogleFonts.inter(fontSize: 13.sp, color: const Color(0xFF475569)),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Update avatar action
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                showToast(context, 'Avatar picker activated!');
              },
              icon: Icon(Icons.camera_alt_outlined, size: 16.sp, color: const Color(0xFF0F172A)),
              label: Text(
                'Update Avatar',
                style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFF8FAFC),
                side: const BorderSide(color: Color(0xFFE2EAF4)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListCard(String title, IconData titleIcon, List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Row(
              children: [
                Icon(titleIcon, color: const Color(0xFF0284C7), size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F2547),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(IconData icon, String label, String value, {bool isRedValue = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18.sp, color: const Color(0xFF64748B)),
                  SizedBox(width: 12.w),
                  Text(
                    label,
                    style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
                  ),
                ],
              ),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: isRedValue ? const Color(0xFFEF4444) : const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    return _buildListCard(
      'Personal Information',
      Icons.person_outline,
      [
        _buildListItem(Icons.person_outline, 'Gender', _gender),
        _buildListItem(Icons.calendar_today_outlined, 'Date of Birth', _dob),
        _buildListItem(Icons.favorite_border, 'Blood Group', _bloodGroup),
        _buildListItem(Icons.location_on_outlined, 'Address', _address),
      ],
    );
  }

  Widget _buildIdentityInfoCard() {
    return _buildListCard(
      'Professional Identity',
      Icons.military_tech_outlined,
      [
        _buildListItem(Icons.badge_outlined, 'Employee ID', _employeeId),
        _buildListItem(Icons.business_center_outlined, 'Designation', _designation),
        _buildListItem(Icons.domain, 'Department', _department),
      ],
    );
  }

  Widget _buildSecurityStatusCard() {
    return _buildListCard(
      'Security Status',
      Icons.lock_outline,
      [
        _buildListItem(Icons.access_time, 'Last Password Change', _lastPasswordChange, isRedValue: _lastPasswordChange.contains('Action')),
        SizedBox(height: 4.h),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              showToast(context, 'Change password initiated');
            },
            icon: Icon(Icons.vpn_key_outlined, size: 16.sp, color: const Color(0xFF0F172A)),
            label: Text(
              'Change Password',
              style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: const Color(0xFFF8FAFC),
              side: const BorderSide(color: Color(0xFFE2EAF4)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 12.h),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationPreferencesCard() {
    return _buildListCard(
      'Notification Preferences',
      Icons.notifications_outlined,
      [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Push Notifications', style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
                SizedBox(height: 2.h),
                Text('Receive browser push alerts', style: GoogleFonts.inter(fontSize: 11.sp, color: const Color(0xFF64748B))),
              ],
            ),
            Switch(
              value: _pushEnabled,
              onChanged: (val) {
                setState(() => _pushEnabled = val);
                SharedPreferences.getInstance().then((p) => p.setBool('notifications_enabled', val));
              },
              activeColor: Colors.white,
              activeTrackColor: const Color(0xFF3B82F6),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        const Divider(height: 1, color: Color(0xFFF1F5F9)),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('In-App Notifications', style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
                SizedBox(height: 2.h),
                Text('Show alerts inside dashboard', style: GoogleFonts.inter(fontSize: 11.sp, color: const Color(0xFF64748B))),
              ],
            ),
            Switch(
              value: _inAppEnabled,
              onChanged: (val) {
                setState(() => _inAppEnabled = val);
                SharedPreferences.getInstance().then((p) => p.setBool('in_app_notifications', val));
              },
              activeColor: Colors.white,
              activeTrackColor: const Color(0xFF3B82F6),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTeacherDigitalIdentityCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Row(
              children: [
                Icon(Icons.qr_code, color: const Color(0xFF0284C7), size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  'Digital Identity & QR Attendance',
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F2547),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.qr_code_2, size: 16.sp, color: const Color(0xFF475569)),
                          SizedBox(width: 6.w),
                          Text(
                            'ATTENDANCE QR CODE',
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF475569),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Container(
                        width: 220.r,
                        height: 220.r,
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: _dbQrCode != null && _dbQrCode!.startsWith('data:image')
                            ? (() {
                                try {
                                  final base64Str = _dbQrCode!.split(',').last;
                                  final bytes = base64Decode(base64Str);
                                  return Image.memory(
                                    bytes,
                                    fit: BoxFit.contain,
                                    errorBuilder: (cxt, err, stack) {
                                      return Center(
                                        child: Text(
                                          'QR Error',
                                          style: GoogleFonts.inter(color: const Color(0xFF0F172A), fontSize: 10.sp),
                                        ),
                                      );
                                    },
                                  );
                                } catch (e) {
                                  return Center(
                                    child: Text(
                                      'QR Error',
                                      style: GoogleFonts.inter(color: const Color(0xFF0F172A), fontSize: 10.sp),
                                    ),
                                  );
                                }
                              })()
                            : QrImageView(
                                data: _employeeId,
                                version: QrVersions.auto,
                                size: 200.r,
                                gapless: false,
                                eyeStyle: const QrEyeStyle(
                                  eyeShape: QrEyeShape.square,
                                  color: Color(0xFF0F172A),
                                ),
                                dataModuleStyle: const QrDataModuleStyle(
                                  dataModuleShape: QrDataModuleShape.square,
                                  color: Color(0xFF0F172A),
                                ),
                                errorStateBuilder: (cxt, err) {
                                  return Center(
                                    child: Text(
                                      'Error',
                                      style: GoogleFonts.inter(color: const Color(0xFF0F172A)),
                                    ),
                                  );
                                },
                              ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        _userName,
                        style: GoogleFonts.inter(fontSize: 15.sp, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A)),
                      ),
                      SizedBox(height: 4.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDBEAFE),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          widget.role.toUpperCase(),
                          style: GoogleFonts.inter(fontSize: 10.sp, fontWeight: FontWeight.w800, color: const Color(0xFF2563EB)),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      ElevatedButton.icon(
                        onPressed: () {
                          showToast(context, 'Simulated QR code download complete!');
                        },
                        icon: const Icon(Icons.file_download_outlined, size: 18, color: Colors.white),
                        label: Text('Download', style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                          minimumSize: Size(double.infinity, 44.h),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      'ISSUED & LOCKED',
                      style: GoogleFonts.inter(fontSize: 10.sp, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Container(width: 8.r, height: 8.r, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                    SizedBox(width: 8.w),
                    Text(
                      'QR Code Info',
                      style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                    ),
                    SizedBox(width: 6.w),
                    Icon(Icons.lock_outline, size: 14.sp, color: const Color(0xFF64748B)),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  'This QR code is used for scanning attendance at QR scanner devices located throughout the campus.',
                  style: GoogleFonts.inter(fontSize: 13.sp, color: const Color(0xFF64748B), height: 1.5),
                ),
                SizedBox(height: 16.h),
                _buildInfoBulletPoint('Each user has a unique, permanent QR code tied to their account.'),
                SizedBox(height: 12.h),
                _buildInfoBulletPoint('The QR is valid at any active scanner the user\\'s role is allowed on.'),
                SizedBox(height: 12.h),
                _buildInfoBulletPoint('Admins can regenerate the QR if it is lost or compromised.'),
                SizedBox(height: 12.h),
                _buildInfoBulletPoint('GPS geofencing is enforced by the scanner device, not the QR code itself.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
"""

lines = lines[:start_idx] + [new_content + "\n"] + lines[end_idx:]

with open(file_path, "w", encoding="utf-8") as f:
    f.writelines(lines)
