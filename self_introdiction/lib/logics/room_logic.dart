import 'package:cloud_firestore/cloud_firestore.dart';

class RoomLogic {
  Stream<DocumentSnapshot> getRoomStream(String roomKey) {
    return FirebaseFirestore.instance.collection('rooms').doc(roomKey).snapshots();
  }

  Future<void> createRoom(String roomKey) async {
    await FirebaseFirestore.instance.collection('rooms').doc(roomKey).set({
      'title': '',
      'backgroundColor': '#FFFFFF', // 기본값: 흰색
      'appBarColor': '#42A5F5', // 기본값: 파란색
      'widgets': [],
      'guidelines': [],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addWidget(String roomKey, Map<String, dynamic> widgetData) async {
    await FirebaseFirestore.instance.collection('rooms').doc(roomKey).update({
      'widgets': FieldValue.arrayUnion([widgetData]),
    });
  }

  Future<void> removeWidget(String roomKey, Map<String, dynamic> widgetData) async {
    await FirebaseFirestore.instance.collection('rooms').doc(roomKey).update({
      'widgets': FieldValue.arrayRemove([widgetData]),
    });
  }

  Future<void> updateWidget(String roomKey, Map<String, dynamic> widgetData) async {
    final docRef = FirebaseFirestore.instance.collection('rooms').doc(roomKey);
    final snapshot = await docRef.get();
    final data = snapshot.data() as Map<String, dynamic>?;
    final widgets = List<Map<String, dynamic>>.from(data?['widgets'] ?? []);
    final index = widgets.indexWhere((w) => w['id'] == widgetData['id']);
    if (index != -1) {
      widgets[index] = widgetData;
      await docRef.update({'widgets': widgets});
    }
  }

  Future<void> addGuideline(String roomKey, Map<String, dynamic> guidelineData) async {
    await FirebaseFirestore.instance.collection('rooms').doc(roomKey).update({
      'guidelines': FieldValue.arrayUnion([guidelineData]),
    });
  }

  Future<void> removeGuideline(String roomKey, Map<String, dynamic> guidelineData) async {
    await FirebaseFirestore.instance.collection('rooms').doc(roomKey).update({
      'guidelines': FieldValue.arrayRemove([guidelineData]),
    });
  }

  Future<void> updateGuideline(String roomKey, Map<String, dynamic> guidelineData) async {
    final docRef = FirebaseFirestore.instance.collection('rooms').doc(roomKey);
    final snapshot = await docRef.get();
    final data = snapshot.data() as Map<String, dynamic>?;
    final guidelines = List<Map<String, dynamic>>.from(data?['guidelines'] ?? []);
    final index = guidelines.indexWhere((g) => g['id'] == guidelineData['id']);
    if (index != -1) {
      guidelines[index] = guidelineData;
      await docRef.update({'guidelines': guidelines});
    }
  }

  Future<void> updateBackgroundColor(String roomKey, String color) async {
    await FirebaseFirestore.instance.collection('rooms').doc(roomKey).update({
      'backgroundColor': color,
    });
  }

  Future<void> updateAppBarColor(String roomKey, String color) async {
    await FirebaseFirestore.instance.collection('rooms').doc(roomKey).update({
      'appBarColor': color,
    });
  }
}