import 'package:flutter/material.dart';
import 'package:responsi/authServices.dart';
import 'package:responsi/content_page.dart';
import 'register_page.dart';

bool _isHidden = true;
final bool loginSucces = false;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Login Page"),
        //backgroundColor: Colors.yellowAccent.withOpacity(0.3),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/restoran1.jpg'),
                fit: BoxFit.cover, // Gambar menutupi seluruh layar
              ),
            ),
          ),
          Center(
            child: Container(
              width: 300,
              height: 330,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black.withOpacity(0.7),
                  width: 3,
                ),
                borderRadius: BorderRadius.all(Radius.circular(40)),
                color: Colors.white.withOpacity(0.85),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextField(
                      controller: _usernameController,
                      cursorColor: Colors.black,
                      decoration: InputDecoration(labelText: 'Username'),
                    ),
                    TextField(
                      controller: _passwordController,
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: InkWell(
                          onTap: _togglePasswordView,
                          child: Icon(
                            _isHidden ? Icons.visibility : Icons.visibility_off,
                          ),
                        ),
                      ),
                      obscureText: _isHidden,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        Future<bool> loginSucces = authServices.login(
                            _usernameController.text, _passwordController.text);
                        if (await loginSucces){
                          Navigator.push(
                              context, MaterialPageRoute(
                              builder: (context)=>ContentPage(
                                  username: _usernameController.text)
                          )
                          );
                        }
                        else  ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Login Gagal"))
                        );
                      },

                      child: Text('Login', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 36),
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white
                      ),
                    ),
                    Row(
                      children: [
                        Text("Belum Punya Akun?"),
                        TextButton(onPressed: (){
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => RegisterPage()
                          )
                          );
                        },
                            child: Text("Sign Up"))
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _togglePasswordView() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }
}