/// ============================================================================
/// FILE: lib/features/safety_check/domain/repositories/safety_check_repository.dart
/// MODULE: Safety Check - Domain Repository Interface
/// ROLE:
///   Quy định hợp đồng kết nối dữ liệu tính năng Hẹn giờ kiểm tra an toàn.
///   Tuân thủ Pragmatic Clean Architecture, trả về Functional Result<T>.
/// ============================================================================

import '../../../../core/error/result.dart';
import '../entities/safety_check_entity.dart';
import '../entities/safety_check_template_entity.dart';

abstract class SafetyCheckRepository {
  /// Lấy danh sách mẫu hẹn giờ (hệ thống + người dùng tạo)
  Future<Result<List<SafetyCheckTemplateEntity>>> getTemplates();

  Future<Result<SafetyCheckTemplateEntity>> saveTemplate(
      Map<String, dynamic> data,
      {String? templateId});

  Future<Result<void>> deleteTemplate(String templateId);

  /// Lấy phiên hẹn giờ hiện tại đang hoạt động (nếu có)
  Future<Result<SafetyCheckEntity?>> getCurrentSafetyCheck();

  /// Bắt đầu một phiên đếm ngược hẹn giờ an toàn mới
  Future<Result<SafetyCheckEntity>> startSafetyCheck({
    String? templateId,
    String? customName,
    required int durationMinutes,
    int? gracePeriodSeconds,
    double? latitude,
    double? longitude,
    String? notes,
  });

  /// Bấm nút 'Tôi an toàn' để hoàn tất phiên
  Future<Result<SafetyCheckEntity>> confirmSafe({
    required String instanceId,
    String? pinCode,
    String? note,
  });

  /// Xin gia hạn thêm thời gian cho phiên đang chạy (mặc định 15 phút)
  Future<Result<SafetyCheckEntity>> extendSafetyCheck({
    required String instanceId,
    int extendMinutes = 15,
  });

  /// Người dùng chủ động hủy phiên hẹn giờ
  Future<Result<void>> cancelSafetyCheck({
    required String instanceId,
    String? reason,
  });

  /// Cập nhật vị trí GPS checkpoint cho phiên đang chạy
  Future<Result<void>> updateLocation({
    required String instanceId,
    required double latitude,
    required double longitude,
    double? accuracyMeters,
  });
}
