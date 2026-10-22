/// ============================================================================
/// FILE: lib/features/sos/domain/repositories/emergency_repository.dart
/// MODULE: Emergency & SOS - Domain Repository Interface
/// ROLE:
///   Quy định hợp đồng kích hoạt, kiểm tra và hủy phiên khẩn cấp SOS.
/// ============================================================================

import '../../../../core/error/result.dart';
import '../entities/emergency_session_entity.dart';

abstract class EmergencyRepository {
  /// Kích hoạt phiên báo động khẩn cấp SOS
  Future<Result<EmergencySessionEntity>> triggerSos({
    String triggerType = 'MANUAL_SOS',
    double? latitude,
    double? longitude,
    double? accuracyMeters,
    String? notes,
    String? recordingId,
  });

  /// Hủy phiên khẩn cấp SOS (Bắt buộc xác thực Mã PIN 4 số)
  Future<Result<EmergencySessionEntity>> cancelSos({
    required String pinCode,
    String? reason,
  });

  /// Lấy trạng thái phiên SOS đang hoạt động nếu có
  Future<Result<EmergencySessionEntity?>> getActiveSosSession();
}
