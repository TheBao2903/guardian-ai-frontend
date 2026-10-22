/// ============================================================================
/// FILE: lib/features/contacts/data/repositories/contacts_repository_impl.dart
/// MODULE: Contacts - Data Repository Implementation
/// ROLE:
///   Triển khai ContactsRepository, chịu lỗi offline và chuyển sang Result<T>.
/// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/contact_entity.dart';
import '../../domain/repositories/contacts_repository.dart';
import '../datasources/contacts_remote_data_source.dart';
import '../models/contact_model.dart';

final contactsRepositoryProvider = Provider<ContactsRepository>((ref) {
  final dataSource = ref.watch(contactsRemoteDataSourceProvider);
  return ContactsRepositoryImpl(dataSource);
});

class ContactsRepositoryImpl implements ContactsRepository {
  ContactsRepositoryImpl(this._remoteDataSource);

  final ContactsRemoteDataSource _remoteDataSource;

  // Cache fallback khi offline - Danh sách rỗng, không có mock data
  final List<ContactEntity> _fallbackContacts = [];

  @override
  Future<Result<List<ContactEntity>>> getContacts() async {
    try {
      final models = await _remoteDataSource.getContacts();
      // Trả về dữ liệu thật từ server, không có mock data
      return Result.success(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      // Khi offline, trả về danh sách rỗng thay vì mock data
      return Result.success(_fallbackContacts);
    }
  }

  @override
  Future<Result<ContactEntity>> addContact({
    required String name,
    required ContactRelationshipEnum relationship,
    required String phone,
    String? telegramId,
    int? priority,
  }) async {
    try {
      final payload = {
        'name': name,
        'relationship': ContactModel.relationshipToDto(relationship),
        'phone': phone,
        if (telegramId != null) 'telegram_id': telegramId,
        if (priority != null) 'priority': priority,
        'is_active': true,
      };
      final model = await _remoteDataSource.addContact(payload);
      return Result.success(model.toEntity());
    } on AppException catch (e) {
      return Result.error(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      // Khi lỗi, không tạo local mock - chỉ trả về lỗi
      return Result.error(ServerFailure(
          'Không thể thêm người thân. Vui lòng thử lại: ${e.toString()}'));
    }
  }

  @override
  Future<Result<ContactEntity>> updateContact({
    required String id,
    String? name,
    ContactRelationshipEnum? relationship,
    String? phone,
    String? telegramId,
    int? priority,
    bool? isActive,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (name != null) payload['name'] = name;
      if (relationship != null)
        payload['relationship'] = ContactModel.relationshipToDto(relationship);
      if (phone != null) payload['phone'] = phone;
      if (telegramId != null) payload['telegram_id'] = telegramId;
      if (priority != null) payload['priority'] = priority;
      if (isActive != null) payload['is_active'] = isActive;

      final model = await _remoteDataSource.updateContact(id, payload);
      return Result.success(model.toEntity());
    } on AppException catch (e) {
      return Result.error(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Result.error(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteContact(String id) async {
    try {
      await _remoteDataSource.deleteContact(id);
      return Result.success(null);
    } on AppException catch (e) {
      return Result.error(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Result.error(
          ServerFailure('Không thể xóa người thân. Vui lòng thử lại.'));
    }
  }

  @override
  Future<Result<List<ContactEntity>>> reorderContacts(
    List<Map<String, dynamic>> orders,
  ) async {
    try {
      final models = await _remoteDataSource.reorderContacts(orders);
      return Result.success(models.map((m) => m.toEntity()).toList());
    } on AppException catch (e) {
      return Result.error(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Result.error(
          ServerFailure('Không thể sắp xếp ưu tiên. Vui lòng thử lại.'));
    }
  }
}
