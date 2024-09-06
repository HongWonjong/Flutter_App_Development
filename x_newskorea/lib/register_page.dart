import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String _email = '', _password = '', _confirmPassword = '';
  bool _isLoading = false;
  bool _obscureText = true;
  bool _termsAgreed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: '이메일'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value!.isEmpty || !value.contains('@')) {
                    return '유효한 이메일을 입력해주세요.';
                  }
                  return null;
                },
                onChanged: (value) => _email = value,
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  suffixIcon: IconButton(
                    icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
                obscureText: _obscureText,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 입력해 주세요.';
                  }

                  if (value.length < 10) {
                    return '비밀번호는 최소 10자리 이상이어야 합니다.';
                  }

                  // 문자 포함 여부 확인
                  if (!value.contains(RegExp(r'[A-Za-z]'))) {
                    return '비밀번호는 적어도 하나의 문자를 포함해야 합니다.';
                  }

                  // 숫자 포함 여부 확인
                  if (!value.contains(RegExp(r'\d'))) {
                    return '비밀번호는 적어도 하나의 숫자를 포함해야 합니다.';
                  }

                  // 특수문자 포함 여부 확인
                  if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                    return '비밀번호는 적어도 하나의 특수문자를 포함해야 합니다.';
                  }

                  return null; // 모든 조건을 통과하면 null을 반환하여 유효함을 나타냄
                },
                onChanged: (value) => _password = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: '비밀번호 확인'),
                obscureText: true,
                validator: (value) {
                  if (value != _password) return '비밀번호가 일치하지 않습니다.';
                  return null;
                },
                onChanged: (value) => _confirmPassword = value,
              ),
              CheckboxListTile(
                title: Text("서비스 약관 및 개인정보 처리방침에 동의합니다."),
                value: _termsAgreed,
                onChanged: (newValue) {
                  setState(() {
                    _termsAgreed = newValue!;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              ElevatedButton(
                child: Text('회원가입'),
                onPressed: _termsAgreed ? () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() => _isLoading = true);
                    try {
                      await _auth.createUserWithEmailAndPassword(email: _email, password: _password);
                      // Here you might want to send an email verification
                      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('회원가입 성공! 이메일 확인을 해주세요.')),
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('회원가입 실패: $e')),
                      );
                    } finally {
                      setState(() => _isLoading = false);
                    }
                  }
                } : null,
              ),
              TextButton(
                child: Text('이미 가입하셨다면 로그인 해 주세요.'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}