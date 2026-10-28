// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get cancel => 'Hủy bỏ';

  @override
  String get confirm => 'Xác nhận';

  @override
  String get save => 'Lưu lại';

  @override
  String get retry => 'Thử lại';

  @override
  String get delete => 'Xóa';

  @override
  String get close => 'Đóng';

  @override
  String get continueAction => 'Tiếp tục';

  @override
  String get back => 'Quay lại';

  @override
  String get edit => 'Chỉnh sửa';

  @override
  String get navHome => 'Trang chủ';

  @override
  String get navSos => 'SOS';

  @override
  String get navSafetyCheck => 'Hẹn giờ';

  @override
  String get navContacts => 'Người thân';

  @override
  String get navProfile => 'Cá nhân';

  @override
  String get homeGreeting => 'Guardian AI';

  @override
  String get homeStatusSafe => 'Bạn đang an toàn';

  @override
  String get homeStatusSafeDesc => 'Hệ thống giám sát an toàn đang hoạt động';

  @override
  String get homeStatusWarning => 'Cần chú ý';

  @override
  String get homeStatusEmergency => 'ĐANG BÁO ĐỘNG KHẨN CẤP';

  @override
  String get homeQuickActions => 'Công cụ an toàn nhanh';

  @override
  String get homeSirenAction => 'Còi hú';

  @override
  String get homeStrobeAction => 'Đèn chớp';

  @override
  String get homeCallPoliceAction => 'Gọi 113';

  @override
  String get homeSosHoldHint => 'Nhấn giữ 3 giây để kích hoạt SOS';

  @override
  String get sosTitle => 'SOS Khẩn cấp';

  @override
  String get sosActivate => 'KÍCH HOẠT SOS';

  @override
  String get sosActiveTitle => 'SOS ĐANG HOẠT ĐỘNG';

  @override
  String get sosActiveSubtitle =>
      'Đang gửi tọa độ trực tiếp và cảnh báo người thân';

  @override
  String get sosStop => 'DỪNG SOS';

  @override
  String get sosCallingHelp => 'Đang liên hệ cứu hộ khẩn cấp...';

  @override
  String get sosSharingLocation => 'Đang chia sẻ vị trí thời gian thực';

  @override
  String get sosStopConfirmTitle => 'Dừng báo động SOS?';

  @override
  String get sosStopConfirmDesc =>
      'Bạn có chắc chắn muốn dừng báo động không? Người thân sẽ nhận được thông báo rằng bạn đã an toàn.';

  @override
  String get sosEnterPinTitle => 'Nhập mã PIN để dừng SOS';

  @override
  String get sosEnterPinDesc =>
      'Nhập mã PIN 4 số của bạn để xác nhận hủy báo động';

  @override
  String get sosIncorrectPin => 'Mã PIN không đúng. Vui lòng thử lại.';

  @override
  String get safetyCheckTitle => 'Hẹn giờ An toàn';

  @override
  String get safetyCheckSubtitle =>
      'Đặt hẹn giờ và xác nhận an toàn trước khi hết hạn. Nếu quá giờ, SOS sẽ tự động kích hoạt.';

  @override
  String get safetyCheckStart => 'Bắt đầu hẹn giờ';

  @override
  String get safetyCheckSafeConfirm => 'Tôi an toàn';

  @override
  String get safetyCheckExpiringSoon => 'Sắp hết thời gian xác nhận';

  @override
  String get safetyCheckMissedAlert => 'Quá hạn xác nhận - Đã kích hoạt SOS';

  @override
  String get safetyCheckRemainingTime => 'Thời gian còn lại';

  @override
  String safetyCheckMinutesRemaining(int minutes) {
    return 'Còn $minutes phút';
  }

  @override
  String get safetyCheckTemplatesTitle => 'Mẫu hẹn giờ nhanh';

  @override
  String get customDuration => 'Tùy chỉnh';

  @override
  String get customMinutesPrompt => 'Nhập số phút';

  @override
  String get contactsTitle => 'Vòng tròn Khẩn cấp';

  @override
  String get contactsSubtitle =>
      'Tối đa 10 người thân nhận cảnh báo tức thời qua App & Telegram';

  @override
  String get contactsAdd => 'Thêm người thân';

  @override
  String get contactsConfirmed => 'Đã xác nhận';

  @override
  String get contactsPending => 'Chờ kết nối Telegram';

  @override
  String get contactsLimitReached => 'Đã đạt giới hạn tối đa 10 người thân';

  @override
  String get contactsRemoveConfirm =>
      'Xóa liên hệ này khỏi vòng tròn khẩn cấp?';

  @override
  String get profileTitle => 'Hồ sơ & Cài đặt';

  @override
  String get medicalProfileTitle => 'Hồ sơ Y tế';

  @override
  String get settingsLanguage => 'Ngôn ngữ';

  @override
  String get settingsLanguageVi => 'Tiếng Việt';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsDarkMode => 'Chế độ tối';

  @override
  String get settingsSystemTheme => 'Theo hệ thống';

  @override
  String get settingsLogout => 'Đăng xuất';

  @override
  String get errorGeneric => 'Đã xảy ra lỗi. Vui lòng thử lại.';

  @override
  String get errorNetwork => 'Không có kết nối mạng. Vui lòng kiểm tra lại.';

  @override
  String get errorLocationUnavailable =>
      'Không thể xác định vị trí GPS của bạn.';

  @override
  String get errorPermissionRequired =>
      'Ứng dụng cần được cấp quyền để thực hiện hành động này.';

  @override
  String get errorTryAgain => 'Thử lại';

  @override
  String get profileLoading => 'Đang tải thông tin...';

  @override
  String get profilePersonalTab => 'Cá nhân';

  @override
  String get profileMedicalTab => 'Y tế';

  @override
  String get profileSettingsTab => 'Cài đặt';

  @override
  String get phoneNumber => 'Số điện thoại';

  @override
  String get notUpdated => 'Chưa cập nhật';

  @override
  String get profileTelegramPersonal => 'Telegram Chat ID (Cá nhân)';

  @override
  String get profileTelegramUnlinked => 'Chưa liên kết ID';

  @override
  String get profileEditPersonal => 'Chỉnh sửa thông tin cá nhân';

  @override
  String get profileTestTelegramTitle => 'Kiểm tra kết nối Telegram Bot';

  @override
  String get profileTestTelegramDescription =>
      'Gửi thử thông báo cảnh báo mẫu để xác nhận bot Telegram hoạt động tốt, sẵn sàng nhận thông báo khi có sự cố khẩn cấp.';

  @override
  String get profileTelegramBot => '🤖 Bot nhận cảnh báo: @GuardianAINotiBot';

  @override
  String get profileTelegramSetupOne =>
      '1. Mở bot @GuardianAINotiBot bấm START (gõ /start) rồi gửi tin nhắn \"hello\" để kích hoạt.\n';

  @override
  String get profileTelegramSetupTwo =>
      '2. Dùng bot @userinfobot để lấy số Chat ID của bạn và người thân.';

  @override
  String get profileTestTelegramAction => '🔔 Kiểm tra gửi thông báo Telegram';

  @override
  String get medicalLockedTitle => 'Hồ sơ y tế được khóa bảo mật';

  @override
  String get medicalLockedDescription =>
      'Dữ liệu y tế là thông tin cá nhân nhạy cảm theo Nghị định 13/2023/NĐ-CP. Để bảo vệ quyền riêng tư, bạn cần nhập mã PIN 4 số của tài khoản để xem và sửa đổi.';

  @override
  String get medicalUnlockAction => '🔓 Mở khóa bằng mã PIN 4 số';

  @override
  String get medicalInitialHint =>
      'Khi bạn chưa lưu thông tin y tế, mục này sẽ mở tự do. Sau khi lưu, hệ thống tự động khóa bảo vệ.';

  @override
  String get medicalLockNow => 'Khóa lại ngay';

  @override
  String get medicalLockedSuccess => 'Đã khóa bảo vệ hồ sơ y tế';

  @override
  String get editInformation => 'Chỉnh sửa';

  @override
  String get enterInformation => 'Nhập thông tin';

  @override
  String get medicalBloodType => 'Nhóm máu';

  @override
  String get medicalAllergies => 'Tiền sử dị ứng';

  @override
  String get medicalNotes => 'Ghi chú y tế & Bệnh nền';

  @override
  String get medicalSosHint =>
      'Thông tin y tế này được đính kèm vào tin nhắn SOS gửi người thân và cứu hộ khi kích hoạt khẩn cấp.';

  @override
  String get settingsSafePinTitle => 'Mã PIN 4 số hủy báo động SOS';

  @override
  String get settingsSafePinSet => 'Đã cài đặt mã PIN bảo mật (4 số)';

  @override
  String get notConfigured => 'Chưa cài đặt';

  @override
  String get settingsChangePin => 'Đổi PIN';

  @override
  String get settingsDuressPinTitle => 'Mã PIN Cưỡng bức (Duress Code)';

  @override
  String get settingsDuressPinSet => 'Đã kích hoạt mã bí mật (4 số)';

  @override
  String get notEnabled => 'Chưa kích hoạt';

  @override
  String get settingsChangeCode => 'Đổi mã';

  @override
  String get settingsDuressDescription =>
      'Khi bị kẻ cướp/bắt cóc ép tắt SOS, hãy nhập mã này. Ứng dụng sẽ tắt còi hú giả vờ an toàn, nhưng ngầm gửi tin nhắn tối khẩn kèm GPS tới Telegram người thân!';

  @override
  String get settingsPasswordTitle => 'Mật khẩu đăng nhập';

  @override
  String get settingsPasswordSet => 'Đã cài đặt mật khẩu bảo mật';

  @override
  String get changeAction => 'Đổi';

  @override
  String get settingsAppearance => 'Giao diện ứng dụng';

  @override
  String get settingsLight => 'Sáng (Mặc định)';

  @override
  String get settingsDark => 'Tối';

  @override
  String get settingsLogoutAccount => 'Đăng xuất tài khoản';

  @override
  String get fullName => 'Họ và tên';

  @override
  String get fullNameExample => 'Nguyễn Văn A';

  @override
  String get telegramNumericId => 'Telegram Chat ID (Dãy số)';

  @override
  String get telegramIdExample => 'Ví dụ: 628392102';

  @override
  String get telegramIdHint => '💡 Lấy số ID qua bot Telegram @userinfobot.';

  @override
  String get saveChanges => 'Lưu thay đổi';

  @override
  String get nameRequired => 'Họ tên không được để trống';

  @override
  String get profileUpdateSuccess => 'Đã cập nhật thông tin thành công';

  @override
  String get profileUpdateFailed => 'Cập nhật thất bại. Vui lòng thử lại';

  @override
  String get telegramTestOptions => 'Tùy chọn kiểm tra gửi thông báo Telegram';

  @override
  String get telegramTestChoose =>
      'Chọn đối tượng bạn muốn gửi tin nhắn cảnh báo thử nghiệm qua bot @GuardianAINotiBot:';

  @override
  String get telegramTestSelf => '🎯 Chỉ Telegram cá nhân của tôi';

  @override
  String get telegramNotConfigured => 'Chưa cài đặt Telegram ID';

  @override
  String get telegramTestEveryone =>
      '👥 Tôi + Tất cả người thân Guardian Circle';

  @override
  String get telegramTestContacts =>
      '🛡️ Chỉ gửi tới Người thân (Không gửi vào Telegram của tôi)';

  @override
  String get telegramChecking => 'Đang kiểm tra kết nối Telegram...';

  @override
  String get telegramSending =>
      'Đang gửi tin nhắn qua bot @GuardianAINotiBot...';

  @override
  String get telegramRecipientHint =>
      '💡 Người nhận chưa nhận được cần mở bot @GuardianAINotiBot bấm /start gửi \"hello\" trước.';

  @override
  String get telegramChatNotConfigured => 'Chưa cài đặt Telegram Chat ID';

  @override
  String get sessionExpiredHint =>
      'Lỗi phiên xác thực (Vui lòng đăng xuất và đăng nhập lại)';

  @override
  String get telegramNotStarted => 'Chưa bấm /start với bot @GuardianAINotiBot';

  @override
  String get medicalEditTitle => 'Cập nhật hồ sơ y tế khẩn cấp';

  @override
  String get medicalAllergiesExample => 'Penicillin, Aspirin, phấn hoa...';

  @override
  String get medicalNotesExample => 'Hen suyễn nhẹ, mang theo thuốc...';

  @override
  String get medicalSave => 'Lưu hồ sơ y tế';

  @override
  String get medicalSaveSuccess => 'Đã cập nhật hồ sơ y tế thành công';

  @override
  String get medicalUnlockTitle => 'Mở khóa hồ sơ y tế';

  @override
  String get medicalEnterPin =>
      'Nhập mã PIN 4 số an toàn của bạn để xác thực quyền xem dữ liệu y tế:';

  @override
  String get medicalUnlockedSuccess => '🔓 Đã mở khóa hồ sơ y tế thành công';

  @override
  String get pinVerifyUnavailable => 'Không thể xác thực mã PIN';

  @override
  String get unlockAction => 'Mở khóa';

  @override
  String get pinChangeTitle => 'Đổi mã PIN 4 số hủy SOS';

  @override
  String get pinCurrentHint =>
      'Để bảo mật, vui lòng xác thực bằng cách nhập mã PIN hiện tại:';

  @override
  String get pinCurrent => 'Mã PIN hiện tại';

  @override
  String get pinNew => 'Mã PIN mới';

  @override
  String get pinConfirmNew => 'Xác nhận mã PIN mới';

  @override
  String get pinCurrentIncorrect => 'Mã PIN hiện tại không chính xác';

  @override
  String get pinFourDigits => 'Mã PIN phải đủ đúng 4 chữ số';

  @override
  String get pinConfirmationMismatch => 'Mã PIN mới và xác nhận không khớp';

  @override
  String get pinMustDiffer => 'Mã PIN mới phải khác mã PIN hiện tại';

  @override
  String get pinUpdateUnavailable => 'Không thể cập nhật mã PIN lên máy chủ';

  @override
  String get pinUpdateSuccess => 'Đã đổi mã PIN SOS thành công';

  @override
  String get pinSave => 'Lưu PIN';

  @override
  String get duressChangeTitle => 'Đổi Mã PIN Cưỡng bức';

  @override
  String get duressChangeDescription =>
      'Khi nhập mã này lúc nguy cấp, còi sẽ tắt giả vờ an toàn nhưng hệ thống phát ngầm cảnh báo cứu trợ tới người thân.\n\n';

  @override
  String get duressCurrentHint =>
      'Để bảo mật, vui lòng xác thực mã PIN cưỡng bức hiện tại:';

  @override
  String get duressCurrent => 'Mã PIN cưỡng bức hiện tại';

  @override
  String get duressNew => 'Mã PIN cưỡng bức mới';

  @override
  String get duressConfirmNew => 'Xác nhận mã PIN cưỡng bức mới';

  @override
  String get duressCurrentIncorrect =>
      'Mã PIN cưỡng bức hiện tại không chính xác';

  @override
  String get duressUpdateUnavailable =>
      'Không thể cập nhật mã PIN cưỡng bức lên máy chủ. Vui lòng kiểm tra kết nối mạng và thử lại.';

  @override
  String get duressUpdateSuccess => 'Đã cập nhật Mã PIN cưỡng bức mới';

  @override
  String get saveCode => 'Lưu mã';

  @override
  String get passwordChangeTitle => 'Đổi mật khẩu đăng nhập';

  @override
  String get passwordCurrentHint =>
      'Để bảo mật, vui lòng nhập mật khẩu hiện tại trước khi đổi:';

  @override
  String get passwordCurrent => 'Mật khẩu hiện tại';

  @override
  String get passwordNew => 'Mật khẩu mới';

  @override
  String get passwordRequirements => 'Tối thiểu 6 ký tự, có chữ + số';

  @override
  String get passwordConfirm => 'Xác nhận mật khẩu mới';

  @override
  String get passwordRepeat => 'Nhập lại mật khẩu mới';

  @override
  String get passwordCurrentRequired => 'Vui lòng nhập mật khẩu hiện tại';

  @override
  String get passwordTooShort => 'Mật khẩu mới phải có ít nhất 6 ký tự';

  @override
  String get passwordLettersDigits =>
      'Mật khẩu mới phải có cả chữ cái và chữ số';

  @override
  String get passwordConfirmationMismatch =>
      'Mật khẩu mới và xác nhận không khớp';

  @override
  String get passwordMustDiffer => 'Mật khẩu mới phải khác mật khẩu hiện tại';

  @override
  String get passwordChange => 'Đổi mật khẩu';

  @override
  String get logoutConfirmTitle => 'Xác nhận đăng xuất';

  @override
  String get logoutConfirmDescription =>
      'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản Guardian AI trên thiết bị này?';

  @override
  String get mobileDevice => 'Thiết bị di động';

  @override
  String get locationDeviceTitle => 'Định vị Khẩn cấp & Thiết bị Tin cậy';

  @override
  String get locationAuthorized => '🟢 Đã ủy quyền GPS - Sẵn sàng SOS 1-chạm';

  @override
  String get locationNotAuthorized => '🟠 Chưa cấp quyền vị trí nền';

  @override
  String get locationDeviceLabel => 'Thiết bị:';

  @override
  String get locationOsLabel => 'Hệ điều hành:';

  @override
  String get locationLastKnown => 'Vị trí kiểm tra gần nhất:';

  @override
  String get locationOpenMaps => '🗺️ Mở thử trên Google Maps';

  @override
  String get locationFinding => 'Đang lấy tọa độ GPS vệ tinh...';

  @override
  String get locationUpdate => '🔄 Cập nhật vị trí & kiểm tra GPS';

  @override
  String get locationAuthorize => '⚡ Kích hoạt Định vị khẩn cấp (1-Chạm)';

  @override
  String get locationAuthorizeHint =>
      'Ủy quyền 1 lần duy nhất để khi ấn SOS hệ thống tự động gửi GPS mà không cần hỏi lại.';

  @override
  String get locationUnavailableDescription =>
      'Không thể lấy vị trí. Vui lòng bật định vị hoặc cho phép quyền Vị trí trên trình duyệt/cài đặt máy.';

  @override
  String get homeCountdownActive => 'ĐANG ĐẾM NGƯỢC AN TOÀN';

  @override
  String get runningStatus => 'Đang chạy';

  @override
  String get homeProtectionDescription =>
      'Bạn đang trong hành trình bảo vệ. Nhấn để xem đồng hồ hoặc xác nhận an toàn.';

  @override
  String get homeViewCountdown => 'Xem đếm ngược chi tiết';

  @override
  String get contactsEmptyTitle => 'Chưa có người thân trong danh bạ';

  @override
  String get contactsEmptyDescription =>
      'Hãy thêm ít nhất 1 người thân để được bảo vệ khi có sự cố.';

  @override
  String get contactsPriorityBadge => '#1 Ưu tiên gọi';

  @override
  String get contactsTestCall => 'Gọi kiểm tra';

  @override
  String get contactsSetPriority => 'Đặt ưu tiên gọi #1';

  @override
  String get contactsAddTitle => 'Thêm người thân vào Guardian Circle';

  @override
  String get contactsFullName => 'Họ và tên người thân';

  @override
  String get contactsNameExample => 'Ví dụ: Bố, Mẹ, Bạn thân...';

  @override
  String get contactsTelegramLabel => 'Telegram Chat ID (bắt buộc)';

  @override
  String get contactsTelegramSetupTitle =>
      'Cách thiết lập nhận cảnh báo qua Telegram:';

  @override
  String get contactsTelegramSetupOne =>
      '1. Người thân mở Telegram, tìm bot @GuardianAINotiBot (link: t.me/GuardianAINotiBot).\n';

  @override
  String get contactsTelegramSetupTwo =>
      '2. Bấm START (hoặc gõ /start), rồi gửi 1 tin nhắn ví dụ \"hello\" là xong setup kết nối với bot.\n';

  @override
  String get contactsTelegramSetupThree =>
      '3. Tìm bot @userinfobot trên Telegram để lấy dãy số User ID của người thân, rồi dán dãy số đó vào ô Chat ID ở trên.';

  @override
  String get contactsTelegramNumericHint =>
      '💡 Lưu ý: Bot chỉ gửi được tin nhắn cảnh báo tới Chat ID số (không thể gửi qua @username).';

  @override
  String get contactRelationship => 'Mối quan hệ';

  @override
  String get relationshipParent => 'Bố / Mẹ';

  @override
  String get relationshipSpouse => 'Vợ / Chồng';

  @override
  String get relationshipSibling => 'Anh / Chị / Em';

  @override
  String get relationshipChild => 'Con';

  @override
  String get relationshipFriend => 'Bạn thân';

  @override
  String get relationshipColleague => 'Đồng nghiệp';

  @override
  String get contactsOldPriorityHint => 'Người ưu tiên cũ sẽ được chuyển xuống';

  @override
  String get contactsSave => 'Lưu người thân';

  @override
  String get contactsNamePhoneRequired =>
      'Vui lòng nhập họ tên và số điện thoại';

  @override
  String get contactsInvalidPhone =>
      'Số điện thoại không hợp lệ! Vui lòng nhập số di động 10 chữ số bắt đầu bằng 0 (03, 05, 07, 08, 09).';

  @override
  String get contactsInvalidTelegram =>
      'Vui lòng nhập Telegram Chat ID dạng số từ 6 đến 14 chữ số.';

  @override
  String get contactsDeleteTitle => 'Xác nhận xóa';

  @override
  String get contactsPriorityMovedHint =>
      'Người ưu tiên cũ sẽ được chuyển xuống vị trí thấp hơn.';

  @override
  String get contactsPriorityFailed => 'Không thể đặt ưu tiên gọi';

  @override
  String get safetyExtendShort => '+15 Phút';

  @override
  String get safetyMicrophoneUnavailable =>
      'Micro chưa hoạt động. Hẹn giờ an toàn vẫn đang chạy.';

  @override
  String get safetyExpiredDescription =>
      'Đã hết giờ! Vui lòng xác nhận an toàn ngay';

  @override
  String get safetyMonitoring => 'Đang theo dõi bảo vệ chủ động';

  @override
  String get safetyGracePeriod => 'Thời gian ân hạn';

  @override
  String get safetyConfirmed => 'Đã xác nhận an toàn thành công';

  @override
  String get safetyExtendAction => '+15 Phút gia hạn';

  @override
  String get safetyExtended => 'Đã gia hạn thêm 15 phút';

  @override
  String get safetyCancelTitle => 'Hủy đếm ngược';

  @override
  String get safetyCancelDescription =>
      'Bạn có chắc chắn muốn kết thúc phiên đếm ngược này không?';

  @override
  String get safetyCancelConfirm => 'Đồng ý dừng';

  @override
  String get safetyChooseScenario => '1. Chọn kịch bản di chuyển';

  @override
  String get safetyChooseDuration => '2. Chọn thời lượng đếm ngược';

  @override
  String get safetyDurationLabel => 'Thời lượng:';

  @override
  String get safetyNotesLabel =>
      '3. Ghi chú điểm đến / Người đồng hành (Tùy chọn)';

  @override
  String get safetyNotesExample =>
      'Ví dụ: Đang đi xe biển số 29A-12345, dự kiến về nhà lúc 22:30...';

  @override
  String get minutesUnit => 'phút';

  @override
  String get sirenRunning => 'Đang hú...';

  @override
  String get strobeRunning => 'Đang chớp...';

  @override
  String get policeCallTitle => 'Gọi Cảnh sát 113?';

  @override
  String get policeCallDescription =>
      'Bạn sắp thực hiện cuộc gọi khẩn cấp tới đầu số 113 của Cảnh sát.';

  @override
  String get callNow => 'Gọi ngay';

  @override
  String get languageSaveError => 'Không thể lưu ngôn ngữ. Vui lòng thử lại.';

  @override
  String get cancelShort => 'Hủy';

  @override
  String get contactsAlertDescription =>
      'Khi bạn kích hoạt SOS hoặc quá giờ Safety Check, hệ thống gửi cảnh báo tới Telegram người thân và kèm vị trí nếu có.';

  @override
  String get relationshipOther => 'Người quen';

  @override
  String get sosNoRecipients => 'Chưa có người thân đủ điều kiện nhận Telegram';

  @override
  String get sosSessionActive => 'SOS đang hoạt động';

  @override
  String get sosLocationMissing => 'Chưa có vị trí GPS';

  @override
  String get sirenOffAction => 'Tắt còi';

  @override
  String get sirenOnAction => 'Bật còi';

  @override
  String get strobeOffAction => 'Tắt đèn chớp';

  @override
  String get strobeOnAction => 'Bật đèn chớp';

  @override
  String get emergencyContacts => 'Liên hệ khẩn cấp';

  @override
  String get policeCallEmoji => '🚔 Gọi Cảnh Sát 113';

  @override
  String get policeCallPhone => '📞 Gọi Cảnh Sát 113';

  @override
  String get primaryContact => 'Liên hệ ưu tiên #1';

  @override
  String get callNowUpper => 'GỌI NGAY';

  @override
  String get messageNowUpper => 'NHẮN TIN';

  @override
  String get callAction => 'Gọi';

  @override
  String get messageAction => 'Nhắn tin';

  @override
  String get sosCurrentPinHint => 'Nhập mã PIN 4 số hiện tại để dừng SOS';

  @override
  String get sosPinRequired => 'Vui lòng nhập đủ 4 chữ số PIN';

  @override
  String get sosStoppedSuccess =>
      'Đã dừng báo động SOS thành công. Người thân đã nhận tin an toàn.';

  @override
  String get sosConfirmationTitle => 'Xác nhận SOS';

  @override
  String get screamDetected => 'Phát hiện tiếng la hét!';

  @override
  String get sosCancelling => 'Đang xác nhận hủy…';

  @override
  String get sosSending => 'Đang gửi SOS tới người thân…';

  @override
  String get sosSendFailed => 'Gửi SOS chưa thành công';

  @override
  String get sosWaitingServer => 'Đang chờ máy chủ xử lý SOS…';

  @override
  String get sosFalseAlarm => 'BÁO ĐỘNG GIẢ';

  @override
  String get sosActivateNow => 'KÍCH HOẠT SOS NGAY';

  @override
  String get sosRetry => 'GỬI LẠI SOS';

  @override
  String get sosPreparingTitle => 'CHUẨN BỊ PHÁT TÍN HIỆU SOS';

  @override
  String get sosCountdownDescription =>
      'Hệ thống sẽ gửi vị trí khẩn cấp tới 10 người thân Telegram sau:';

  @override
  String get sosCancelNow => 'HỦY BÁO ĐỘNG NGAY';

  @override
  String get sosCancelledSuccess => 'Đã hủy kích hoạt SOS thành công';

  @override
  String get loginTagline => 'Nền tảng bảo vệ an toàn cá nhân chủ động';

  @override
  String get loginTitle => 'Đăng nhập tài khoản';

  @override
  String get passwordLabel => 'Mật khẩu';

  @override
  String get loginAction => 'Đăng nhập';

  @override
  String get loginRequired => 'Vui lòng nhập đầy đủ Email và Mật khẩu';

  @override
  String get forgotPasswordLink => '🔑 Quên mật khẩu?';

  @override
  String get loginNoAccount => 'Chưa có tài khoản? ';

  @override
  String get registerLink => 'Đăng ký ngay';

  @override
  String get forgotPasswordTitle => 'Quên mật khẩu';

  @override
  String get forgotPasswordDescription =>
      'Nhập email tài khoản của bạn. Chúng tôi sẽ gửi liên kết khôi phục mật khẩu tới email này:';

  @override
  String get accountEmail => 'Email tài khoản';

  @override
  String get forgotPasswordSpamHint =>
      '💡 Vui lòng kiểm tra cả hộp thư Spam nếu không thấy email.';

  @override
  String get emailRequired => 'Vui lòng nhập email';

  @override
  String get emailInvalid => 'Email không hợp lệ';

  @override
  String get sendRequest => 'Gửi yêu cầu';

  @override
  String get registerTitle => 'Tạo tài khoản mới';

  @override
  String get registerSubtitle => 'Đăng ký bảo vệ an toàn';

  @override
  String get registerName => 'Họ và tên của bạn *';

  @override
  String get registerEmail => 'Địa chỉ Email *';

  @override
  String get registerPassword => 'Mật khẩu *';

  @override
  String get registerPasswordHint => 'Tối thiểu 6 ký tự';

  @override
  String get registerPasswordConfirm => 'Xác nhận mật khẩu *';

  @override
  String get registerPasswordRepeat => 'Nhập lại mật khẩu vừa tạo';

  @override
  String get registerConsent =>
      'Tôi đồng ý với Cam kết bảo mật dữ liệu vị trí và ghi âm theo Nghị định 13/2023/NĐ-CP của Guardian AI.';

  @override
  String get registerAction => 'Hoàn tất đăng ký';

  @override
  String get registerRequired =>
      'Vui lòng điền đầy đủ các thông tin bắt buộc (*)';

  @override
  String get registerInvalidEmail => 'Địa chỉ email không đúng định dạng';

  @override
  String get registerPasswordShort => 'Mật khẩu phải có tối thiểu 6 ký tự';

  @override
  String get registerPasswordMismatch =>
      'Mật khẩu xác nhận không khớp. Vui lòng kiểm tra lại!';

  @override
  String get registerConsentRequired =>
      'Vui lòng đồng ý với cam kết bảo mật theo Nghị định 13';

  @override
  String get registerSuccess => 'Đăng ký tài khoản thành công!';

  @override
  String get registerFailed => 'Đăng ký thất bại';

  @override
  String get registerHaveAccount => 'Đã có tài khoản? ';

  @override
  String get loginLink => 'Đăng nhập ngay';

  @override
  String contactsAddCount(int count) {
    return 'Thêm người thân ($count/10)';
  }

  @override
  String contactsCount(int count) {
    return '$count/10 Người';
  }

  @override
  String homeContactsReady(int count) {
    return '$count/10 Người thân sẵn sàng nhận tin Telegram';
  }

  @override
  String homeSessionRemaining(String name, String remaining) {
    return 'Phiên \"$name\": Còn $remaining';
  }

  @override
  String minutesDuration(int minutes) {
    return '$minutes phút';
  }

  @override
  String customMinutesDuration(int minutes) {
    return 'Tùy chỉnh: ${minutes}m';
  }

  @override
  String safetyStarted(int minutes) {
    return 'Đã kích hoạt hẹn giờ $minutes phút thành công';
  }

  @override
  String safetyExtensionCount(int count, int total) {
    return 'Đã gia hạn: $count/$total lần';
  }

  @override
  String contactsAdded(String name) {
    return 'Đã thêm $name vào Guardian Circle';
  }

  @override
  String contactsAddedPriority(String name) {
    return 'Đã thêm $name vào Guardian Circle và đặt làm ưu tiên gọi #1';
  }

  @override
  String contactsRemoveNamed(String name) {
    return 'Bạn có chắc muốn xóa $name khỏi danh bạ người thân không?';
  }

  @override
  String contactsPriorityNamed(String name) {
    return 'Bạn muốn đặt $name làm người được gọi đầu tiên khi có sự cố khẩn cấp?';
  }

  @override
  String contactsPrioritySuccess(String name) {
    return 'Đã đặt $name làm người ưu tiên gọi #1';
  }

  @override
  String profileSelf(String name) {
    return 'Bạn ($name)';
  }

  @override
  String profileTestEveryoneDetail(int count) {
    return 'Gửi đồng thời tới bạn và $count người thân đã có ID';
  }

  @override
  String profileTestContactsDetail(int count) {
    return 'Kiểm tra gửi báo động thử nghiệm tới $count người thân trong danh bạ';
  }

  @override
  String profileTestResults(int sent, int total) {
    return 'Kết quả: $sent/$total người nhận thành công';
  }

  @override
  String profileTestMessage(String name) {
    return '🔔 [Guardian AI - Test] Đây là tin nhắn kiểm tra kết nối cảnh báo an toàn từ $name. Hệ thống hoạt động tốt!';
  }

  @override
  String profileTestDelivered(String id) {
    return 'Đã nhận tin nhắn (ID: $id)';
  }

  @override
  String locationNetworkLabel(String coordinates) {
    return '$coordinates (Định vị IP Mạng)';
  }

  @override
  String locationGpsLabel(String coordinates, String accuracy) {
    return '$coordinates (GPS Sai số ~${accuracy}m)';
  }

  @override
  String locationNetworkSuccess(String device) {
    return 'Đã kích hoạt định vị qua mạng & đăng ký $device thành công!';
  }

  @override
  String locationGpsSuccess(String device) {
    return 'Đã kích hoạt định vị GPS & đăng ký $device thành công!';
  }

  @override
  String sosAutoActivateSeconds(int seconds) {
    return 'Tự động kích hoạt sau ${seconds}s';
  }

  @override
  String sosDetectionType(String type, String confidence) {
    return 'Loại: $type ($confidence%)';
  }

  @override
  String sosDeliveredCount(int sent, int total) {
    return 'Telegram đã nhận $sent/$total thông báo';
  }

  @override
  String sosDeliveryFailedCount(int sent, int total, int failed) {
    return 'Đã gửi $sent/$total; $failed lỗi gửi';
  }

  @override
  String sosDeliveryPendingCount(int sent, int total) {
    return 'Đang gửi tới người thân: $sent/$total';
  }

  @override
  String get templateWalkHome => 'Đi bộ về nhà';

  @override
  String get templateWalkHomeDescription =>
      'Bảo vệ khi đi bộ qua đoạn đường vắng hoặc trời tối.';

  @override
  String get templateLateRide => 'Đi xe / Taxi / Đặt xe';

  @override
  String get templateLateRideDescription =>
      'Theo dõi chuyến đi xe công nghệ, taxi ban đêm.';

  @override
  String get templateExercise => 'Chạy bộ / Thể thao';

  @override
  String get templateExerciseDescription =>
      'Theo dõi an toàn khi chạy bộ, tập thể dục ngoài trời.';

  @override
  String get templateMeetup => 'Gặp gỡ / Hẹn hò';

  @override
  String get templateMeetupDescription =>
      'Hẹn gặp đối tác, người mới quen hoặc nơi xa lạ.';

  @override
  String get templateOvertime => 'Làm việc / Trực đêm';

  @override
  String get templateOvertimeDescription =>
      'Làm việc tăng ca muộn tại văn phòng hoặc công tác.';

  @override
  String get templateCommute => 'Di chuyển bằng xe';

  @override
  String get templateCommuteDescription =>
      'Theo dõi chuyến đi xe taxi, xe ôm công nghệ hoặc phương tiện công cộng.';

  @override
  String get templateOutdoor => 'Khám phá ngoài trời';

  @override
  String get templateOutdoorDescription =>
      'Dành cho các hoạt động leo núi, dã ngoại, chạy bộ đường dài.';

  @override
  String get templateAlone => 'Kiểm tra an toàn';

  @override
  String get templateAloneDescription =>
      'Kiểm tra định kỳ khi ở nhà một mình hoặc làm việc đêm tại văn phòng.';

  @override
  String get templateStranger => 'Cuộc gặp an toàn';

  @override
  String get templateStrangerDescription =>
      'Bảo vệ khi gặp gỡ người mới quen, giao dịch mua bán hoặc phỏng vấn.';

  @override
  String get profileSignedIn => 'Đã đăng nhập';

  @override
  String get deviceWindowsPc => 'Máy tính Windows';

  @override
  String get deviceAppleMac => 'Máy tính Apple Mac';

  @override
  String get deviceAndroid => 'Thiết bị Android';

  @override
  String get deviceWebBrowser => 'Trình duyệt Web';

  @override
  String get deviceGuardian => 'Thiết bị Guardian AI';

  @override
  String get deviceUser => 'Thiết bị người dùng';

  @override
  String get contactsActions => 'Thao tác với người thân';

  @override
  String get contactsEditTitle => 'Chỉnh sửa thông tin người thân';

  @override
  String get contactsInvalidName =>
      'Tên người thân phải có từ 2 đến 100 ký tự.';

  @override
  String get contactsTelegramRequiredHint =>
      'Cần nhập Chat ID để người thân nhận cảnh báo qua Telegram.';

  @override
  String get contactsUpdated => 'Đã cập nhật thông tin người thân';

  @override
  String get contactsUpdateFailed =>
      'Không thể lưu thay đổi. Vui lòng thử lại.';

  @override
  String get scenarioCreate => 'Tạo kịch bản';

  @override
  String get scenarioEdit => 'Chỉnh sửa kịch bản';

  @override
  String get scenarioName => 'Tên kịch bản';

  @override
  String get scenarioDescription => 'Mô tả (không bắt buộc)';

  @override
  String get scenarioDuration => 'Thời lượng mặc định (phút)';

  @override
  String get scenarioGrace => 'Thời gian chờ xác nhận an toàn (giây)';

  @override
  String get scenarioGraceHint =>
      'Thời gian để xác nhận an toàn sau khi đồng hồ đếm ngược kết thúc.';

  @override
  String get scenarioPresets => 'Năm mốc thời gian gợi ý (phút)';

  @override
  String get scenarioPresetsHint =>
      'Ngăn cách bằng dấu phẩy, ví dụ: 15, 30, 45, 60, 90.';

  @override
  String get scenarioInvalidName => 'Tên kịch bản phải có từ 2 đến 100 ký tự.';

  @override
  String get scenarioInvalidDescription =>
      'Mô tả không được vượt quá 300 ký tự.';

  @override
  String get scenarioInvalidDuration => 'Nhập số nguyên từ 1 đến 1440 phút.';

  @override
  String get scenarioInvalidGrace => 'Nhập số nguyên từ 30 đến 1800 giây.';

  @override
  String get scenarioInvalidPresets =>
      'Nhập năm số nguyên khác nhau từ 1 đến 1440, ngăn cách bằng dấu phẩy.';

  @override
  String get scenarioSaveFailed => 'Không thể lưu kịch bản. Vui lòng thử lại.';

  @override
  String get scenarioSaved => 'Đã lưu kịch bản';

  @override
  String get scenarioDeleted => 'Đã xóa kịch bản';

  @override
  String get scenarioDeleteTitle => 'Xóa kịch bản?';

  @override
  String get scenarioDeleteConfirm =>
      'Kịch bản này sẽ được xóa khỏi danh sách của bạn. Kịch bản của tài khoản khác được giữ nguyên.';

  @override
  String get scenarioEmpty =>
      'Chưa có kịch bản. Hãy tạo kịch bản để bắt đầu Safety Check.';

  @override
  String get scenarioActions => 'Thao tác với kịch bản';

  @override
  String get registerNamePrompt => 'Nhập họ và tên';

  @override
  String get registerEmailPrompt => 'Nhập địa chỉ email';

  @override
  String get registerPhoneOptional => 'Số điện thoại (không bắt buộc)';

  @override
  String get authShowPassword => 'Hiện mật khẩu';

  @override
  String get authHidePassword => 'Ẩn mật khẩu';

  @override
  String get flashlightSetupTitle => 'Camera và đèn flash';

  @override
  String get flashlightSetupDescription =>
      'Cho phép camera để dùng đèn flash khi khẩn cấp. Camera chỉ mở khi kiểm tra hoặc dùng đèn; hình ảnh không được ghi hay gửi đi.';

  @override
  String get flashlightGrantAction => 'Cấp quyền camera';

  @override
  String get flashlightCheckAction => 'Kiểm tra lại';

  @override
  String get flashlightLaterAction => 'Để sau';

  @override
  String get flashlightCancelAction => 'Hủy kiểm tra';

  @override
  String get flashlightChecking => 'Đang kiểm tra camera và đèn flash…';

  @override
  String get flashlightReady => 'Camera hỗ trợ đèn flash. Sẵn sàng sử dụng.';

  @override
  String get flashlightUnknown =>
      'Chưa kiểm tra khả năng điều khiển đèn flash.';

  @override
  String get flashlightPermissionRequired =>
      'Cần cấp quyền camera để dùng đèn flash.';

  @override
  String get flashlightPermissionDenied =>
      'Quyền camera bị từ chối. Mở quyền Camera trong cài đặt của website trên trình duyệt, rồi kiểm tra lại.';

  @override
  String get flashlightUnsupported =>
      'Camera hoặc trình duyệt này không hỗ trợ điều khiển đèn flash. Các chức năng SOS khác vẫn sử dụng được.';

  @override
  String get flashlightInsecure =>
      'Mở Guardian AI bằng HTTPS để cấp quyền camera và sử dụng đèn flash.';

  @override
  String get flashlightCameraMissing =>
      'Không tìm thấy camera phù hợp trên thiết bị.';

  @override
  String get flashlightCameraBusy =>
      'Không mở được camera. Hãy đóng ứng dụng đang dùng camera rồi thử lại.';

  @override
  String get flashlightInterrupted =>
      'Đèn đã dừng vì camera bị ngắt hoặc bạn đã rời ứng dụng. Nhấn bật đèn để thử lại.';

  @override
  String get flashlightTimedOut =>
      'Chưa nhận được quyền camera. Bạn có thể tiếp tục sử dụng ứng dụng và kiểm tra lại sau.';

  @override
  String get flashlightFailed =>
      'Không điều khiển được đèn flash. Vui lòng thử lại.';

  @override
  String get flashlightPermissionNote =>
      'Quyền camera do trình duyệt quản lý trên thiết bị này và có thể cần cấp lại.';

  @override
  String get flashlightStopAction => 'Tắt đèn';

  @override
  String get audioPreparing => 'Đang chuẩn bị nhận diện âm thanh';

  @override
  String get audioLocalMode => 'Nhận diện trên thiết bị';

  @override
  String get audioServerMode => 'Nhận diện qua máy chủ';

  @override
  String get audioWaiting => 'Đang chờ đoạn âm thanh';

  @override
  String get audioAnalysisHealthy => 'Phân tích đang theo kịp âm thanh';

  @override
  String get audioAnalysisDelayed =>
      'Phân tích đang trễ; có thể bỏ qua một phần âm thanh';

  @override
  String get audioAnalysisUnavailable => 'Phân tích âm thanh đang gián đoạn';

  @override
  String get audioNetworkFailure => 'Kết nối máy chủ đang gián đoạn.';

  @override
  String get audioAuthFailure => 'Đăng nhập lại để kết nối máy chủ.';

  @override
  String get audioModelFailure =>
      'Mô hình âm thanh chưa sẵn sàng hoặc không chạy được.';

  @override
  String get audioStaleFailure =>
      'Tín hiệu âm thanh đã quá hạn hoặc Safety Check đã kết thúc.';

  @override
  String get audioServerFailure => 'Máy chủ chưa xử lý được yêu cầu.';

  @override
  String get audioMicrophoneActive => 'Micro đang thu âm';

  @override
  String get audioDeliveryRequiresNetwork =>
      'Gửi cảnh báo lên máy chủ cần có kết nối mạng.';

  @override
  String get audioAlertSending =>
      'Đã phát hiện âm thanh. Đang gửi cảnh báo lên máy chủ…';

  @override
  String get audioAlertRetrying =>
      'Đã phát hiện âm thanh. Kết nối gián đoạn; đang thử gửi lại cảnh báo…';

  @override
  String get audioAlertAccepted =>
      'Máy chủ đã tiếp nhận cảnh báo. Trạng thái gửi đến người thân được theo dõi riêng.';

  @override
  String get audioAlertFailed =>
      'Chưa nhận được xác nhận tiếp nhận cảnh báo từ máy chủ.';

  @override
  String get audioAlertExpired =>
      'Tín hiệu đã quá hạn trước khi nhận được xác nhận từ máy chủ.';

  @override
  String get audioRecipientsSent =>
      'Đã gửi cảnh báo đến tất cả người thân được chọn.';

  @override
  String get audioRecipientsMissing =>
      'Chưa có người thân đủ điều kiện nhận cảnh báo này.';

  @override
  String get audioRecipientsFailed =>
      'Một số lượt gửi cảnh báo thất bại. Kiểm tra trạng thái gửi SOS.';
}
