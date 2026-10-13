import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  bool get _hasFirebase => Firebase.apps.isNotEmpty;
  FirebaseAuth? get _auth => _hasFirebase ? FirebaseAuth.instance : null;
  FirebaseFirestore? get _firestore => _hasFirebase ? FirebaseFirestore.instance : null;

  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  bool get isTrainer => _currentUser?.role == UserRole.trainer;
  bool get isClient => _currentUser?.role == UserRole.client;

  AuthService() {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    if (!_hasFirebase) return;
    try {
      _auth?.authStateChanges().listen((User? user) async {
        if (user != null) {
          await fetchUserProfile(user.uid);
        } else {
          _currentUser = null;
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint('Auth state listener notice: $e');
    }
  }

  Future<void> fetchUserProfile(String uid) async {
    if (!_hasFirebase) return;
    try {
      final doc = await _firestore?.collection('users').doc(uid).get();
      if (doc != null && doc.exists && doc.data() != null) {
        _currentUser = UserModel.fromMap(doc.data()!, uid);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  }) async {
    _isLoading = true;
    notifyListeners();

    if (!_hasFirebase) {
      // Offline / Local fallback mode
      await Future.delayed(const Duration(milliseconds: 400));
      _currentUser = UserModel(
        uid: 'local_${DateTime.now().millisecondsSinceEpoch}',
        email: email.trim(),
        displayName: displayName.trim().isEmpty ? 'Athlete' : displayName.trim(),
        role: role,
        createdAt: DateTime.now(),
      );
      _isLoading = false;
      notifyListeners();
      return true;
    }

    try {
      final credential = await _auth!.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        final newUser = UserModel(
          uid: user.uid,
          email: email.trim(),
          displayName: displayName.trim(),
          role: role,
          createdAt: DateTime.now(),
        );

        await _firestore?.collection('users').doc(user.uid).set(newUser.toMap());
        _currentUser = newUser;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException during register: ${e.message}');
    } catch (e) {
      debugPrint('Registration error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    if (!_hasFirebase) {
      // Offline / Local fallback mode
      await Future.delayed(const Duration(milliseconds: 400));
      final role = email.toLowerCase().contains('trainer') ? UserRole.trainer : UserRole.client;
      _currentUser = UserModel(
        uid: 'local_${DateTime.now().millisecondsSinceEpoch}',
        email: email.trim(),
        displayName: email.split('@').first,
        role: role,
        createdAt: DateTime.now(),
      );
      _isLoading = false;
      notifyListeners();
      return true;
    }

    try {
      final credential = await _auth!.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        await fetchUserProfile(credential.user!.uid);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException during login: ${e.message}');
    } catch (e) {
      debugPrint('Login error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    if (_hasFirebase) {
      try {
        await _auth?.signOut();
      } catch (e) {
        debugPrint('Sign out error: $e');
      }
    }
    _currentUser = null;
    notifyListeners();
  }

  // Demo switch for previewing Client vs Trainer experience without signing in
  void setDemoUser(UserRole role) {
    _currentUser = UserModel(
      uid: role == UserRole.trainer ? 'trainer_demo_1' : 'client_demo_1',
      email: role == UserRole.trainer ? 'trainer@gympro.com' : 'client@gympro.com',
      displayName: role == UserRole.trainer ? 'Coach Alex Carter' : 'Jordan Smith',
      role: role,
      createdAt: DateTime.now(),
    );
    notifyListeners();
  }
}
