import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  Future createPublicKey(
      {required String username, required String key}) async {
    final docUser =
        FirebaseFirestore.instance.collection('publicKey').doc(username);
    final json = {
      'key': key,
    };

    await docUser.set(json);
  }

  Future<String> fetchDataFromFirestore(String username) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('publicKey')
          .doc(username)
          .get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;

        // Truy cập các giá trị bằng cách sử dụng khóa tương ứng
        String key = data['key'];
        print(documentSnapshot.data());
        print('key' + key);
        return key;
      } else {
        print('key not exist');
        // Trả về null nếu tài liệu không tồn tại
        return '';
      }
    } catch (e) {
      // Xử lý lỗi nếu có
      print('Error fetching data: $e');
      return '';
    }
  }
}
