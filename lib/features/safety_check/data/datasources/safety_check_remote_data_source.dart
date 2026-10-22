/// ============================================================================
/// FILE: lib/features/safety_check/data/datasources/safety_check_remote_data_source.dart
/// MODULE: Safety Check - Remote Data Source
/// ROLE:
///   Giao tiếp trực tiếp với FastAPI backend qua ApiClient.
///   Xử lý bóc tách envelope chuẩn {success: true, data: ..., message: ...}.
/// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/safety_check_model.dart';
import '../models/safety_check_template_model.dart';

final safetyCheckRemoteDataSourceProvider =
    Provider<SafetyCheckRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SafetyCheckRemoteDataSource(apiClient);
});

class SafetyCheckRemoteDataSource {
  const SafetyCheckRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<SafetyCheckTemplateModel> saveTemplate(Map<String, dynamic> body,
      {String? templateId}) async {
    final response = templateId == null
        ? await _apiClient.post<dynamic>(ApiConstants.safetyCheckTemplates,
            data: body)
        : await _apiClient.put<dynamic>(
            '${ApiConstants.safetyCheckTemplates}/$templateId',
            data: body);
    return SafetyCheckTemplateModel.fromJson((response.data
        as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  Future<void> deleteTemplate(String templateId) async {
    await _apiClient
        .delete<dynamic>('${ApiConstants.safetyCheckTemplates}/$templateId');
  }

  /// Lấy danh sách mẫu hẹn giờ
  Future<List<SafetyCheckTemplateModel>> getTemplates() async {
    final response = await _apiClient.get(ApiConstants.safetyCheckTemplates);
    final data = response.data;
    if (data is Map<String, dynamic> && data['data'] is List) {
      final list = data['data'] as List;
      return list
          .map((item) =>
              SafetyCheckTemplateModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Lấy phiên hẹn giờ hiện tại
  Future<SafetyCheckModel?> getCurrentSafetyCheck() async {
    final response = await _apiClient.get(ApiConstants.safetyCheckCurrent);
    final data = response.data;
    if (data is Map<String, dynamic> && data['data'] != null) {
      return SafetyCheckModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    return null;
  }

  /// Bắt đầu phiên đếm ngược mới
  Future<SafetyCheckModel> startSafetyCheck({
    String? templateId,
    String? customName,
    required int durationMinutes,
    int? gracePeriodSeconds,
    double? latitude,
    double? longitude,
    String? notes,
  }) async {
    final payload = <String, dynamic>{
      'duration_minutes': durationMinutes,
    };
    if (templateId != null) payload['template_id'] = templateId;
    if (customName != null) payload['custom_name'] = customName;
    if (gracePeriodSeconds != null)
      payload['grace_period_seconds'] = gracePeriodSeconds;
    if (latitude != null) payload['latitude'] = latitude;
    if (longitude != null) payload['longitude'] = longitude;
    if (notes != null) payload['notes'] = notes;

    final response = await _apiClient.post(
      ApiConstants.safetyCheckStart,
      data: payload,
    );
    final data = response.data as Map<String, dynamic>;
    return SafetyCheckModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  /// Xác nhận 'Tôi an toàn'
  Future<SafetyCheckModel> confirmSafe({
    required String instanceId,
    String? pinCode,
    String? note,
  }) async {
    final payload = <String, dynamic>{};
    if (pinCode != null) payload['pin_code'] = pinCode;
    if (note != null) payload['note'] = note;

    final response = await _apiClient.post(
      ApiConstants.safetyCheckConfirmSafe(instanceId),
      data: payload,
    );
    final data = response.data as Map<String, dynamic>;
    return SafetyCheckModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  /// Gia hạn thêm thời gian
  Future<SafetyCheckModel> extendSafetyCheck({
    required String instanceId,
    int extendMinutes = 15,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.safetyCheckExtend(instanceId),
      data: {'extend_minutes': extendMinutes},
    );
    final data = response.data as Map<String, dynamic>;
    return SafetyCheckModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  /// Hủy phiên hẹn giờ
  Future<void> cancelSafetyCheck({
    required String instanceId,
    String? reason,
  }) async {
    await _apiClient.post(
      ApiConstants.safetyCheckCancel(instanceId),
      data: {'reason': reason ?? 'Người dùng chủ động hủy hẹn giờ.'},
    );
  }

  /// Cập nhật vị trí GPS checkpoint
  Future<void> updateLocation({
    required String instanceId,
    required double latitude,
    required double longitude,
    double? accuracyMeters,
  }) async {
    await _apiClient.post(
      ApiConstants.safetyCheckCheckpoint(instanceId),
      data: {
        'latitude': latitude,
        'longitude': longitude,
        if (accuracyMeters != null) 'accuracy_meters': accuracyMeters,
      },
    );
  }
}
