import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String _email = '', _password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('로그인')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: '이메일'),
                validator: (value) => value!.isEmpty ? '이메일을 입력 해 주세요.' : null,
                onChanged: (value) => _email = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: '비밀번호'),
                obscureText: true,
                validator: (value) => value!.length < 10 ? '비밀번호는 최소 10자리 입니다.' : null,
                onChanged: (value) => _password = value,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('이메일로 로그인'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      await _auth.signInWithEmailAndPassword(email: _email, password: _password);
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('로그인 실패: $e')),
                      );
                    }
                  }
                },
              ),
              TextButton(
                child: Text('계정이 없으시다면 회원가입 해 주세요.'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

