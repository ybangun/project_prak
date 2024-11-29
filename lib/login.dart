import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:project_akhir/utils/user_manager.dart';
import 'pages/main_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: MyStatefulWidget(),
      ),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({super.key});

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  String username = "";
  String password = "";

  bool isLoggedIn = false;
  bool isPasswordVisible = true;

  late TextEditingController usernameController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController();
    passwordController = TextEditingController();
    checkLoginStatus();
  }

  void checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool loggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (loggedIn) {
      setState(() {
        isLoggedIn = true;
      });
    }
  }

  String hashPassword(String password) {
    var bytes = utf8.encode(password); // Encode password to UTF-8
    var digest = sha256.convert(bytes); // Perform SHA-256 encryption
    return digest.toString(); // Return encrypted password
  }

  Future<void> _login() async {
    String enteredPassword =
    hashPassword(passwordController.text.trim()); // Encrypt entered password

    if (UserManager.users.containsKey(username) &&
        UserManager.users[username] == enteredPassword) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true); // Save login status

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainPage(),
        ),
      );
      setState(() {
        isLoggedIn = true;

      });
    } else {
      var snackBar = const SnackBar(
        content: Text("Login Failed"),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xffe0f7fa),
                    Color(0xffb2ebf2),
                    Color(0xff80deea),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                'Asset/images/login.png',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
        Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'Asset/images/login.png',
                  width: double.infinity,
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Welcome',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    letterSpacing: 4.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Please Login First !',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black, width: 2.0),
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      contentPadding:
                      const EdgeInsets.only(left: 30.0, top: 20.0, bottom: 20.0),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black, width: 2.0),
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      suffixIcon: const Icon(
                        Icons.attach_money,
                        color: Colors.black,
                      ),
                      labelText: 'Username',
                      hintText: 'Enter username',
                      labelStyle: const TextStyle(
                        color: Colors.black45,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: passwordController,
                    obscureText: !isPasswordVisible,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black, width: 2.0),
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      contentPadding:
                      const EdgeInsets.only(left: 30.0, top: 20.0, bottom: 20.0),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black, width: 2.0),
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                      labelText: 'Password',
                      hintText: 'Enter password',
                      labelStyle: const TextStyle(
                        color: Colors.black45,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    username = usernameController.text;
                    _login();
                  },
                  style: ElevatedButton.styleFrom(
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
    ]
      ),
    );
  }
}
