import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class ImageUtil {
  static Future<String> getImageUrl(String imagePath) async {
    // Firebase Storage 인스턴스 생성
    firebase_storage.FirebaseStorage storage =
        firebase_storage.FirebaseStorage.instance;

    // Firebase Storage에서 이미지 다운로드
    try {
      firebase_storage.Reference ref = storage.ref(imagePath);
      String imageUrl = await ref.getDownloadURL();

      // 다운로드된 이미지의 URL 반환
      return imageUrl;
    } catch (e) {
      print('Error getting image URL: $e');
      // 에러가 발생할 경우 대체할 URL 또는 기본 이미지 URL을 반환할 수 있습니다.
      return 'default_image_url';
    }
  }
}
