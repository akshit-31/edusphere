class AttendanceModel {
  final String id;
  final String attendeeType;
  final String? studentId;
  final String? teacherId;
  final String? staffId;
  final DateTime date;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final String status;
  final bool scannedByRFID;
  final bool scannedByQR;
  final String? deviceId;
  final String? scannerId;
  final double? scanLatitude;
  final double? scanLongitude;
  final bool? geofenceValid;
  final String? remarks;

  AttendanceModel({
    required this.id,
    required this.attendeeType,
    this.studentId,
    this.teacherId,
    this.staffId,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    required this.status,
    required this.scannedByRFID,
    required this.scannedByQR,
    this.deviceId,
    this.scannerId,
    this.scanLatitude,
    this.scanLongitude,
    this.geofenceValid,
    this.remarks,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] as String? ?? '',
      attendeeType: json['attendeeType'] as String? ?? 'STUDENT',
      studentId: json['studentId'] as String?,
      teacherId: json['teacherId'] as String?,
      staffId: json['staffId'] as String?,
      date: DateTime.parse(json['date'].toString()),
      checkInTime: json['checkInTime'] != null ? DateTime.tryParse(json['checkInTime'].toString()) : null,
      checkOutTime: json['checkOutTime'] != null ? DateTime.tryParse(json['checkOutTime'].toString()) : null,
      status: json['status'] as String? ?? 'ABSENT',
      scannedByRFID: json['scannedByRFID'] as bool? ?? false,
      scannedByQR: json['scannedByQR'] as bool? ?? false,
      deviceId: json['deviceId'] as String?,
      scannerId: json['scannerId'] as String?,
      scanLatitude: json['scanLatitude'] != null ? double.tryParse(json['scanLatitude'].toString()) : null,
      scanLongitude: json['scanLongitude'] != null ? double.tryParse(json['scanLongitude'].toString()) : null,
      geofenceValid: json['geofenceValid'] as bool?,
      remarks: json['remarks'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'attendeeType': attendeeType,
      'studentId': studentId,
      'teacherId': teacherId,
      'staffId': staffId,
      'date': date.toIso8601String(),
      'checkInTime': checkInTime?.toIso8601String(),
      'checkOutTime': checkOutTime?.toIso8601String(),
      'status': status,
      'scannedByRFID': scannedByRFID,
      'scannedByQR': scannedByQR,
      'deviceId': deviceId,
      'scannerId': scannerId,
      'scanLatitude': scanLatitude,
      'scanLongitude': scanLongitude,
      'geofenceValid': geofenceValid,
      'remarks': remarks,
    };
  }
}
