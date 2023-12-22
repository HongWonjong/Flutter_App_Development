class loginpage_lan {
  static const String loginPageTitle = '로그인 페이지';
  static const String emailLabel = '이메일';
  static const String passwordLabel = '비밀번호';
  static const Map<String, String> togglePasswordVisibility = {
    'tooltip': '비밀번호 표시 전환',
    'visible': '비밀번호 표시',
    'hidden': '비밀번호 숨김',
  };
  static const String loginButton = '로그인';
  static const String signupButton = '회원가입';
  static const String resetPasswordButton = '비밀번호 재설정';
  static String loginFailureMessage(dynamic error) => '로그인 실패: $error';
}

class mainpage_lan {
  static const String mainPageTitle = '메인 페이지';
  static const String centerMessage = "앱의 중심 내용이 여기에 들어갑니다.";
}
