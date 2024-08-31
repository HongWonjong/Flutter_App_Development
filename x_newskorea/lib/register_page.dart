import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String _email = '', _password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: '이메일'),
                validator: (value) => value!.isEmpty ? '이메일을 입력해주세요.' : null,
                onChanged: (value) => _email = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: '비밀번호'),
                obscureText: true,
                validator: (value) => value!.length < 10 ? '비밀번호는 최소 10자리 이상!' : null,
                onChanged: (value) => _password = value,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('회원가입'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      await _auth.createUserWithEmailAndPassword(email: _email, password: _password);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('회원가입 성공!')),
                      );
                      Navigator.pop(context); // Registration 성공 후 로그인 페이지로 돌아가기
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('회원가입 실패: $e')),
                      );
                    }
                  }
                },
              ),
              TextButton(
                child: const Text('이미 가입하셨다면 로그인 해 주세요.'),
                onPressed: () {
                  Navigator.pop(context); // 로그인 페이지로 돌아가기
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}