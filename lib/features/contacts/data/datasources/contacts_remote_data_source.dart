/// ============================================================================
/// FILE: lib/features/contacts/data/datasources/contacts_remote_data_source.dart
/// MODULE: Contacts - Remote Data Source
/// ROLE:
///   Giao tiếp trực tiếp với FastAPI backend phục vụ quản lý Guardian Circle.
/// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/contact_model.dart';

final contactsRemoteDataSourceProvider = Provider<ContactsRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ContactsRemoteDataSource(apiClient);
});

class ContactsRemoteDataSource {
  const ContactsRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  /// Lấy danh sách tối đa 10 người thân
  Future<List<ContactModel>> getContacts() async {
    final response = await _apiClient.get(ApiConstants.contactsList);
    final data = response.data;
    if (data is Map<String, dynamic> && data['data'] is List) {
      final list = data['data'] as List;
      return list
          .map((item) => ContactModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Thêm người thân mới
  Future<ContactModel> addContact(Map<String, dynamic> body) async {
    final response = await _apiClient.post(
      ApiConstants.contactsAdd,
      data: body,
    );
    final data = response.data as Map<String, dynamic>;
    return ContactModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  /// Cập nhật thông tin người thân
  Future<ContactModel> updateContact(String id, Map<String, dynamic> body) async {
    final response = await _apiClient.put(
      '${ApiConstants.contactsList}/$id',
      data: body,
    );
    final data = response.data as Map<String, dynamic>;
    return ContactModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  /// Xóa người thân
  Future<void> deleteContact(String id) async {
    await _apiClient.delete('${ApiConstants.contactsList}/$id');
  }

  /// Sắp xếp lại thứ tự ưu tiên
  Future<List<ContactModel>> reorderContacts(List<Map<String, dynamic>> orders) async {
    final response = await _apiClient.put(
      '${ApiConstants.contactsList}/reorder',
      data: {'orders': orders},
    );
    final data = response.data as Map<String, dynamic>;
    final list = data['data'] as List;
    return list
        .map((item) => ContactModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
