import 'package:flutter/foundation.dart';
import 'mock_data.dart';


class AdminStore extends ChangeNotifier {
  AdminStore._internal();
  static final AdminStore instance = AdminStore._internal();

  final Map<String, String> _userStatusOverrides = {};
  final Set<String> _deletedUserIds = {};

  String statusFor(AppUser user) => _userStatusOverrides[user.profileId] ?? user.status;

  bool isDeleted(AppUser user) => _deletedUserIds.contains(user.profileId);

  List<AppUser> get visibleUsers =>
      MockData.users.where((u) => !isDeleted(u)).toList(growable: false);

  void banUser(AppUser user) {
    _userStatusOverrides[user.profileId] = 'Suspended';
    notifyListeners();
  }

  void unbanUser(AppUser user) {
    _userStatusOverrides[user.profileId] = 'Active';
    notifyListeners();
  }

  void shadowbanUser(AppUser user) {
    _userStatusOverrides[user.profileId] = 'Shadowbanned';
    notifyListeners();
  }

  void deleteUser(AppUser user) {
    _deletedUserIds.add(user.profileId);
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Reports / moderation queue
  // ---------------------------------------------------------------------
  final Map<int, String> _reportStatus = {};

  String reportStatus(ReportRecord r) => _reportStatus[r.id] ?? 'Open';

  int get pendingReportsCount =>
      MockData.reports.where((r) => reportStatus(r) == 'Open').length;

  void warnFromReport(ReportRecord r) {
    _reportStatus[r.id] = 'Warned';
    notifyListeners();
  }

  void banFromReport(ReportRecord r) {
    _reportStatus[r.id] = 'Banned';
    notifyListeners();
  }

  void dismissReport(ReportRecord r) {
    _reportStatus[r.id] = 'Dismissed';
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Verification queue
  // ---------------------------------------------------------------------
  final Map<int, String> _verificationStatus = {};

  String verificationStatus(VerificationRecord v) => _verificationStatus[v.id] ?? 'Pending';

  int get pendingVerificationsCount =>
      MockData.verifications.where((v) => verificationStatus(v) == 'Pending').length;

  void approveVerification(VerificationRecord v) {
    _verificationStatus[v.id] = 'Approved';
    notifyListeners();
  }

  void rejectVerification(VerificationRecord v) {
    _verificationStatus[v.id] = 'Rejected';
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Support tickets
  // ---------------------------------------------------------------------
  final Map<int, String> _ticketStatus = {};

  String ticketStatus(TicketRecord t) => _ticketStatus[t.id] ?? t.status;

  void setTicketStatus(TicketRecord t, String status) {
    _ticketStatus[t.id] = status;
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Settings > Security > Require 2FA after login
  // ---------------------------------------------------------------------
  // Defaulted to true for this demo build so the OTP screen is visible
  // right after login. Flip off any time from Settings > Security.
  bool _twoFactorRequired = true;

  bool get twoFactorRequired => _twoFactorRequired;

  void setTwoFactorRequired(bool value) {
    _twoFactorRequired = value;
    notifyListeners();
  }
}

/// Global singleton instance used throughout the admin panel.
final AdminStore adminStore = AdminStore.instance;
