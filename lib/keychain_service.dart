import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// ============================================================== ///
/// ====================== Keychain Service ====================== ///
/// ============================================================== ///
// * SecureKeychain Methodchannel Actions
// * Originial values set in Swift Native Code
enum SecureKeychainActions {
  getValue,
  setValue,
  removeValue,
}

extension SecureKeychainActionsExtension on SecureKeychainActions {
  // * Action Types are Hard Coded in Swift Native Code
  // ! DON'T CHANGE ANY VALUE OF THESE !
  String? get action {
    switch (this) {
      case SecureKeychainActions.getValue:
        return "getSecureKeychainValue";
      case SecureKeychainActions.setValue:
        return "setSecureKeychainValue";
      case SecureKeychainActions.removeValue:
        return "removeSecureKeychainValue";
      default:
        return null;
    }
  }
}

class SecureKeychainService {
  const SecureKeychainService();

  static const MethodChannel _channel =
      const MethodChannel("com.flutter.baristikir/baristikir");
  static const String _method = "SDSecureKeychain";

  /// Saves [key] with the given [value] to Encrypted Store
  ///
  /// [key] shouldn't be null.
  /// [value] required value
  /// [iosOptions] optional iOS options.
  /// Can throw a [PlatformException].
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iosOptions = IOSOptions.defaultOptions,
  }) async {
    SecureKeychainActions actionType = SecureKeychainActions.setValue;
    String action = actionType.action!;
    try {
      if (value != null) {
        await _channel.invokeMethod(_method, <String, dynamic>{
          "action": action,
          "key": key,
          "value": value,
          "options": _selectOptions(iosOptions)
        });
      } else {
        delete(key: key, iosOptions: iosOptions);
      }
    } catch (e) {
      throw PlatformException(
          code: keychainCouldNotSetValue,
          message: "Writing value for associated key failed unexpectedly");
    }
  }

  /// Reads [value] from the storage for the associated [key]
  /// Can also return null, if no [value] was found.
  ///
  /// [key] shouldn't be null.
  /// [iosOptions] optional iOS options.
  /// Can throw a [PlatformException].
  Future<String?> read(
      {required String key,
      IOSOptions? iosOptions = IOSOptions.defaultOptions}) async {
    SecureKeychainActions actionType = SecureKeychainActions.getValue;
    String action = actionType.action!;

    try {
      final String? value = await _channel.invokeMethod(
          _method, <String, dynamic>{
        "action": action,
        "key": key,
        "options": _selectOptions(iosOptions)
      });
      return value;
    } catch (e) {
      throw PlatformException(
          code: keychainCouldNotGetValue,
          message: "Reading value for associated key failed unexpectedly");
    }
  }

  /// Deletes a [value] from the storage for the associated [key]
  ///
  /// [key] shouldn't be null.
  /// [iosOptions] optional iOS options.
  /// Can throw a [PlatformException].
  Future<void> delete(
      {required String key,
      IOSOptions? iosOptions = IOSOptions.defaultOptions}) async {
    SecureKeychainActions actionType = SecureKeychainActions.removeValue;
    String action = actionType.action!;

    try {
      await _channel.invokeMethod(_method, <String, dynamic>{
        "action": action,
        "key": key,
        "options": _selectOptions(iosOptions)
      });
    } catch (e) {
      throw PlatformException(
          code: keychainCouldNotDeleteValue,
          message: "Deleting value for associated key failed unexpectedly");
    }
  }

  // * Helper Functions * //

  /// Return true when [value] was found in the storage for the associated [key]
  ///
  /// [key] shouldn't be null.
  /// [iosOptions] optional iOS options.
  /// Can throw a [PlatformException].
  Future<bool> containsKey(
      {required String key,
      IOSOptions? iosOptions = IOSOptions.defaultOptions}) async {
    SecureKeychainActions actionType = SecureKeychainActions.getValue;
    String action = actionType.action!;

    try {
      final String? value = await _channel.invokeMethod(
          _method, <String, dynamic>{
        "action": action,
        "key": key,
        "options": _selectOptions(iosOptions)
      });
      return value != null;
    } catch (e) {
      throw PlatformException(
          code: keychainValueNoSet,
          message: "Searching value for key failed unexpectedly");
    }
  }

  /// Select correct options based on current platform
  /// ! Android Options Missing
  Map<String, String>? _selectOptions(IOSOptions? iOptions) {
    return Platform.isIOS ? iOptions?.params : null;
  }
}

class SecureKeychainChannelHandle {
  const SecureKeychainChannelHandle();

  static Future<dynamic> _handleSecureKeychainMethod(MethodCall call) async {
    switch (call.method) {
      case 'onCompleted':
        final bool completed = call.arguments["completed"];
        final String? error = call.arguments["error"];
        final String? code = call.arguments["code"];

        if (completed) {
          if (error != null && code != null) {
            throw PlatformException(
                code: code, message: "Keychain Action Failed", details: error);
          }
        }
        break;
      default:
        break;
    }
  }
}

/// ============================================================== ///
/// ====================== Keychain Options ====================== ///
/// ============================================================== ///
// * IOS Keychain Accessibilty Options
// * passcode - The data in the keychain can only be accessed when the device is unlocked and a passcode is set on the device.
// * unlocked - The data in the keychain item can be accessed only while the device is unlocked by the user.
enum IOSAccessibility { passcode, unlocked }

// * Default Options
// ! Android Implementation Missing
abstract class Options {
  const Options();

  Map<String, String> get params => _toMap();
  Map<String, String> _toMap() {
    throw Exception("Missing Implementation");
  }
}

// * IOS Secure Keychain Options
class IOSOptions extends Options {
  const IOSOptions({
    String? groupId,
    String? accountName = IOSOptions.defaultAccountName,
    IOSAccessibility accessibility = IOSAccessibility.unlocked,
  })  : _groupId = groupId,
        _accessibility = accessibility,
        _accountName = accountName;

  static const defaultAccountName = "SurgiData";
  static const defaultOptions = IOSOptions();

  final String? _groupId;
  final String? _accountName;
  final IOSAccessibility _accessibility;

  @override
  Map<String, String> _toMap() => <String, String>{
        'accessibility': describeEnum(_accessibility),
        if (_accountName != null) 'accountName': _accountName!,
        if (_groupId != null) 'groupId': _groupId!,
      };

  IOSOptions copyWith({
    String? groupId,
    String? accountName,
    IOSAccessibility? accessibility,
  }) =>
      IOSOptions(
        groupId: groupId ?? _groupId,
        accountName: accountName ?? _accountName,
        accessibility: accessibility ?? _accessibility,
      );
}

/// ============================================================= ///
/// ====================== Keychain Errors ====================== ///
/// ============================================================= ///
/// Keychain Error's Code Strings
const String keychainValueNoSet = 'KeychainValueNoSet';
const String keychainCouldNotDeleteValue = "KeychainCouldNotDeleteValue";
const String keychainCouldNotGetValue = "KeychainCouldNotGetValue";
const String keychainCouldNotSetValue = "KeychainCouldNotSetValue";
