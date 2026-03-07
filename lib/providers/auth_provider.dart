import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ⭐ Web에서는 반드시 clientId 필요 (네가 쓰던 값 그대로 사용)
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? '127546533956-dgquefldu0671hkjbd0obr357ke078he.apps.googleusercontent.com'
        : null,
  );

  User? _user;
  bool _isAuthReady = false;   // FirebaseAuth 초기 복구 완료 플래그
  bool _isSigningIn = false;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isAuthReady => _isAuthReady;
  bool get isSigningIn => _isSigningIn;

  AuthProvider() {
    // 앱 시작 후 FirebaseAuth 상태 변화를 계속 감시
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    print(" AUTH CHANGED");
    print(" currentUser.uid = ${firebaseUser?.uid}");
    print(" currentUser.email = ${firebaseUser?.email}");

    _user = firebaseUser;

    // 최초 한 번만 auth 준비 완료 플래그 true
    if (!_isAuthReady) {
      _isAuthReady = true;
    }

    // 로그인된 상태라면 Firestore에 유저 정보 저장/업데이트
    if (_user != null) {
      await _saveUserToFirestore(_user!);
    }

    notifyListeners();
  }

  Future<void> _saveUserToFirestore(User user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'lastSignInAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print(" Firestore 저장 완료 for UID = ${user.uid}");
    } catch (e, st) {
      print("⚠️ Firestore user 저장 실패: $e");
      debugPrintStack(stackTrace: st);
    }
  }

  // 🔐 Google 로그인
  Future<void> signInWithGoogle() async {
    if (_isSigningIn) return; // 중복 클릭 방지
    _isSigningIn = true;
    notifyListeners();

    try {
      print("🔥 Google 로그인 시작 (kIsWeb=$kIsWeb)");

      // Web / Mobile 둘 다 google_sign_in 사용 (지금 네 구조 유지)
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print("⚠️ Google 로그인 취소됨");
        return;
      }

      final googleAuth = await googleUser.authentication;

      print(" GOOGLE ACCOUNT = ${googleUser.email}");

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      print(
        " Firebase 로그인 성공, uid = ${userCredential.user?.uid}, email = ${userCredential.user?.email}",
      );
    } catch (e, st) {
      print("❌ Google 로그인 실패: $e");
      debugPrintStack(stackTrace: st);
      rethrow;
    } finally {
      _isSigningIn = false;
      notifyListeners();
    }
  }

  // 🔥 로그아웃
  Future<void> signOut() async {
    print("🔥 로그아웃 실행");

    try {
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        print("⚠️ GoogleSignIn 로그아웃 실패: $e");
      }

      await _auth.signOut();
    } catch (e, st) {
      print("❌ 로그아웃 실패: $e");
      debugPrintStack(stackTrace: st);
      rethrow;
    }
  }
}
