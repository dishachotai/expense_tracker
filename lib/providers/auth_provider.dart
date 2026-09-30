import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/database/database_helper.dart';
import 'package:expense_tracker/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<void> checkSavedSession() async {
    final userId = await _dbHelper.getSessionUserId();
    if (userId != null) {
      final user = await _dbHelper.getUserById(userId);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
      }
    }
  }

  Future<bool> register(String name, String email, String password) async {
    final hashedPassword = _hashPassword(password);
    final newUser = UserModel(
      name: name,
      email: email.trim().toLowerCase(),
      password: hashedPassword,
    );
    final result = await _dbHelper.insertUser(newUser);
    if (result != -1) {
      _currentUser = UserModel(
        id: result,
        name: name,
        email: email.trim().toLowerCase(),
        password: hashedPassword,
      );
      await _dbHelper.saveSession(result);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> login(String email, String password) async {
    final hashedPassword = _hashPassword(password);
    final user = await _dbHelper.getUser(email.trim().toLowerCase(), hashedPassword);
    if (user != null) {
      _currentUser = user;
      await _dbHelper.saveSession(user.id!);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _currentUser = null;
    await _dbHelper.clearSession();
    notifyListeners();
  }

  
  Future<bool> updateProfile(String name, String email, String? newPassword) async {
    if (_currentUser == null) return false;
    
    final passwordToUse = newPassword != null && newPassword.isNotEmpty
        ? _hashPassword(newPassword)
        : _currentUser!.password;

    final updatedUser = UserModel(
      id: _currentUser!.id,
      name: name,
      email: email.trim().toLowerCase(),
      password: passwordToUse,
    );

    final result = await _dbHelper.updateUser(updatedUser);
    if (result > 0) {
      _currentUser = updatedUser;
      notifyListeners();
      return true;
    }
    return false;
  }
}
