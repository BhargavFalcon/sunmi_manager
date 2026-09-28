import 'dart:convert';
import '../../main.dart';
import '../constants/api_constants.dart';
import '../model/login_models.dart';
import '../model/restaurant_details_model.dart';

class BranchUtils {
  /// Checks if current logged in user is admin.
  static bool isCurrentUserAdmin() {
    try {
      final loginData = box.read(ArgumentConstant.loginModelKey);
      if (loginData == null) return false;
      Map<String, dynamic>? data;
      if (loginData is String) {
        data = json.decode(loginData) as Map<String, dynamic>;
      } else if (loginData is Map) {
        data = Map<String, dynamic>.from(loginData);
      }
      if (data == null) return false;
      final loginModel = LoginModel.fromJson(data);
      return loginModel.data?.user?.isAdmin ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Gets the branch ID from storage login data.
  static int? getBranchIdFromStorage() {
    try {
      final loginData = box.read(ArgumentConstant.loginModelKey);
      if (loginData is! Map<String, dynamic>) return null;
      final loginModel = LoginModel.fromJson(loginData);
      return loginModel.data?.defaultBranchId ??
          loginModel.data?.user?.branchId;
    } catch (_) {
      return null;
    }
  }

  /// Gets the active branch from restaurantDetailsKey in storage.
  static Branches? getDefaultBranch() {
    try {
      final storedData = box.read(ArgumentConstant.restaurantDetailsKey);
      if (storedData != null && storedData is Map<String, dynamic>) {
        final restaurantModel = RestaurantModel.fromJson(storedData);
        final branches = restaurantModel.data?.branches;
        if (branches != null && branches.isNotEmpty) {
          final branchId = getBranchIdFromStorage();
          return branches.firstWhere(
            (b) => b.id == branchId,
            orElse: () => branches.first,
          );
        }
      }
    } catch (_) {}
    return null;
  }

  /// Gets the active branch's currency from restaurantDetailsKey.
  static Currency? getDefaultBranchCurrency() {
    return getDefaultBranch()?.currency;
  }

  /// Gets the active branch's timezone from restaurantDetailsKey.
  static String? getDefaultBranchTimezone() {
    final tz = getDefaultBranch()?.timezone?.trim();
    if (tz != null && tz.isNotEmpty) return tz;
    return null;
  }

  /// Saves the active branch's timezone from RestaurantModel to storage.
  static void saveBranchTimezone(RestaurantModel? restaurantModel) {
    try {
      final branches = restaurantModel?.data?.branches;
      if (branches != null && branches.isNotEmpty) {
        final branchId = getBranchIdFromStorage();
        final branch = branches.firstWhere(
          (b) => b.id == branchId,
          orElse: () => branches.first,
        );
        final tz = branch.timezone?.trim();
        if (tz != null && tz.isNotEmpty) {
          box.write(ArgumentConstant.restaurantTimezoneKey, tz);
        }
      }
    } catch (_) {}
  }
}
