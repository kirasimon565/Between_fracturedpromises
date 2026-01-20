import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 👈 Add this
import 'package:get/get.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance; // 👈 Add this
  Rx<User?> user = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_auth.authStateChanges());
    signInAnonymously();
  }

  Future<void> signInAnonymously() async {
    try {
      if (_auth.currentUser == null) {
        UserCredential result = await _auth.signInAnonymously();
        User? user = result.user;
        
        // 🛠️ NEW: Create the actual profile in Firestore
        if (user != null) {
          await _createPlayerProfile(user.uid);
        }
      }
    } catch (e) {
      print("Error signing in anonymously: $e");
    }
  }

  // This creates the "User ID" you see in the game
  Future<void> _createPlayerProfile(String uid) async {
    final userDoc = _db.collection('users').doc(uid);
    
    // Only create it if it doesn't exist already
    final doc = await userDoc.get();
    if (!doc.exists) {
      await userDoc.set({
        'id': uid,
        'created_at': FieldValue.serverTimestamp(),
        'suspicion_level': 0,
        'unlocked_secrets': [],
        'current_episode': 'ep1_the_spark',
      });
    }
  }

  String get uid => _auth.currentUser?.uid ?? '';
}
