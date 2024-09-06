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
  bool _isLoading = false;
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('로그인')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // Prevents keyboard from covering fields
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
                    if (value!.length < 10) return '비밀번호는 최소 10자리 이상!';
                    return null;
                  },
                  onChanged: (value) => _password = value,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  child: Text('이메일로 로그인'),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() => _isLoading = true);
                      try {
                        await _auth.signInWithEmailAndPassword(email: _email, password: _password);
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('로그인 실패: $e')),
                        );
                      } finally {
                        setState(() => _isLoading = false);
                      }
                    }
                  },
                ),
                TextButton(
                  child: Text('비밀번호를 잊으셨나요?'),
                  onPressed: () {
                    // Implement password reset functionality here
                    // Typically, you would navigate to a password reset page or show a dialog
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
                // Add social login buttons here
              ],
            ),
          ),
        ),
      ),
    );
  }
}