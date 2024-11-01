import 'package:shared_preferences/shared_preferences.dart';

class OnlyYouSharedPreference {
  static OnlyYouSharedPreference? _instance;
  static SharedPreferences? _prefs;

  OnlyYouSharedPreference._internal();

  factory OnlyYouSharedPreference() =>
      _instance ??= OnlyYouSharedPreference._internal();

  Future<SharedPreferences> get prefs async {
    if (_prefs != null) return _prefs!;
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  // 이메일 저장
  Future<void> setEmail(String email) async {
    SharedPreferences preferences = await prefs;
    preferences.setString('email', email);
  }

  // 성별 저장
  Future<void> setGender(String gender) async {
    SharedPreferences preferences = await prefs;
    preferences.setString('gender', gender);
  }

  // 닉네임 저장
  Future<void> setNickname(String nickname) async {
    SharedPreferences preferences = await prefs;
    preferences.setString('nickname', nickname);
  }

  // 전화번호 저장
  Future<void> setPhone(String phone) async {
    SharedPreferences preferences = await prefs;
    preferences.setString('phone', phone);
  }

  // 이메일 읽기
  Future<String> getEmail() async {
    SharedPreferences preferences = await prefs;
    return preferences.getString('email') ?? "";
  }

  // 성별 읽기
  Future<String> getGender() async {
    SharedPreferences preferences = await prefs;
    return preferences.getString('gender') ?? "";
  }

  // 닉네임 읽기
  Future<String> getNickname() async {
    SharedPreferences preferences = await prefs;
    return preferences.getString('nickname') ?? "";
  }

  // 전화번호 읽기
  Future<String> getPhone() async {
    SharedPreferences preferences = await prefs;
    return preferences.getString('phone') ?? "";
  }

  // 유저 정보 삭제
  Future<void> removeUserInfo() async {
    SharedPreferences preferences = await prefs;
    await preferences.remove('email');
    await preferences.remove('gender');
    await preferences.remove('nickname');
    await preferences.remove('phone');
  }

  // 전체 데이터 삭제
  Future<void> clearPreference() async {
    SharedPreferences preferences = await prefs;
    await preferences.clear();
  }

  // userId 저장
  Future<void> setUserId(String userId) async {
    SharedPreferences preferences = await prefs;
    await preferences.setString('userId', userId);
  }

  // userId 가져오기
  Future<String> getCurrentUserId() async {
    SharedPreferences preferences = await prefs;
    return preferences.getString('userId') ?? 'temp_user_id';
  }

  // 로그아웃 시 userId 포함하여 모든 정보 삭제

  // 디버깅용 사용자 정보 체크 메서드
  Future<void> checkCurrentUser() async {
    print('=== User Info Check ===');
    print('User ID: ${await getCurrentUserId()}');
    print('Email: ${await getEmail()}');
    print('Nickname: ${await getNickname()}');
    print('Phone: ${await getPhone()}');
    print('Gender: ${await getGender()}');
    print('=====================');
  }
}
