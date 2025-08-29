import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'registerpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'forgotpasswordpage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mainpage.dart';
import 'config/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseAuth.instance.authStateChanges().listen((User? user) async {
    Map<String, dynamic>? data;
    if (user == null) {
      debugPrint("[Firebase Auth] User is signed out");
    }
    else {
      debugPrint("[Firebase Auth] User is signed in");
      if (FirebaseAuth.instance.currentUser != null) {
        data = await getUserData(user);
      }    
    }
    runApp(HealthApp(userData: data));
  });
}

class HealthApp extends StatelessWidget {
  const HealthApp({super.key, this.user, this.userData});
  final User? user;
  final Map<String, dynamic>? userData;

  Widget signedInOrSignedOut() {
    String inicio = '/login';
    User? user = FirebaseAuth.instance.currentUser;

    Map<String, WidgetBuilder> rotas = {
      '/login' : (context) => const LoginPage(),
      '/register' : (context) => const RegisterPage(),
      '/forgotpassword' : (context) => const ForgotPasswordPage(),
    };
  
    if (user != null && userData != null) {
      rotas['/home'] = (context) => MainPage(userData: userData);
      debugPrint("[signedInOrSignedOut method] ${userData.toString()}");
      inicio = '/home';
      return MaterialApp(
        title: "HealthApp",
        initialRoute: inicio,
        routes: rotas,
      );
    }
    return MaterialApp(
      title: "HealthApp",
      initialRoute: inicio,
      routes: rotas,
    );
  }

  @override
  Widget build(BuildContext context) {
    return signedInOrSignedOut();
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = FirebaseAuth.instance;
  final _loginFormKey = GlobalKey<FormState>();
  final List<TextEditingController> _controllers = List.generate(2, (i) => TextEditingController());
  final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      surface: Colors.white,
      primary: Colors.purple,
    )
  );
  final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      surface: Colors.grey.shade900,
      primary: Colors.blue,
    )
  );
  bool isDarkMode = false;
  User? user;
  bool isPasswordVisible = true;
  bool isLoadingGoogleSignIn = false;
  bool isLoadingSignIn = false;

  //TODO: Retrieve google user data for database
  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String? loginFormValidator({required String? value, required String? inputType}) {
    if (value == null || value.isEmpty) { return "Esse campo não pode estar vazio"; }
    if (inputType == 'mail' && !value.contains("@")) {
      return "Insira um email valido";
    }
    if (inputType == 'password') {
      if (value.length < 5) {
        return "Insira uma senha com pelo menos 5 dígitos";
      }
    }
    
    return null;
  }

  void togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  Widget loginPageInputTextFormField({required TextEditingController controller, String? labelText, Widget? prefixIcon, required String? validator, String? hintText, required bool obscureText}) { 
    var icon = Icon(Icons.cancel_outlined);
    var onPressed = controller.clear;
    if (validator == "password") {
      icon = isPasswordVisible ?  Icon(Icons.visibility_off) : Icon(Icons.visibility);
      onPressed = togglePasswordVisibility;
    }
    return TextFormField(
      controller: controller,
      validator: (value) => loginFormValidator(value: value, inputType: validator),
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: prefixIcon,
        suffixIcon: IconButton(onPressed: onPressed, icon: icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
        hintText: hintText,
      ),
    );
  }

  Future<void> isloggedIn(User? user) async {
    if (user != null) {
      notifyMessenger(context: context, msg: 'Logado com sucesso!', colortext: Colors.white, colorbar: Colors.green);
      
      final userData = await getUserData(user);

      if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MainPage(userData: userData)));
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      
      final googleUser = await GoogleSignIn().signIn();
      final googleAuth = await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(idToken: googleAuth?.idToken, accessToken: googleAuth?.accessToken);

      UserCredential usercred = await _auth.signInWithCredential(credential);
      isloggedIn(usercred.user);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> loginFirebase() async {
    try {
      String email = _controllers[0].text;
      String password = _controllers[1].text;
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      isloggedIn(credential.user);

    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          if(mounted) notifyMessenger(context: context, msg: 'Email Inválido.', colorbar: Colors.red, colortext: Colors.white);
          break;
        case 'invalid-credential':
          if(mounted) notifyMessenger(context: context, msg: 'Usuário e/ou senha inválidos', colorbar: Colors.blueGrey, colortext: Colors.white);
        case 'too-many-requests':
          if(mounted) notifyMessenger(context: context, msg: "Muitas tentativas, tente novamente mais tarde", colortext: Colors.white, colorbar: Colors.blue);
        default:
          debugPrint(e.toString());
          break;
      }
    }
  }

  Future<void> saveDarkMode(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
  }

  Future<void> loadDarkMode() async {
    bool? isDarkModeprefs;
    final prefs = await SharedPreferences.getInstance();
    isDarkModeprefs = prefs.getBool('isDarkMode');
    isDarkMode == isDarkModeprefs ? null : toggleDarkMode();

  }

  void toggleDarkMode() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
    saveDarkMode(isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    loadDarkMode();
    return Theme(data: isDarkMode ? darkTheme : lightTheme, child: Scaffold(
      body: Center(
        child: SingleChildScrollView(
          //padding: EdgeInsets.symmetric(vertical: 0),
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(iconSize: 48, onPressed: toggleDarkMode, icon: isDarkMode ? Icon(Icons.light_mode) : Icon(Icons.dark_mode)),
                ],
              ),
              avatarLogoImage(radius: 80),
              Text("HealthApp", textAlign: TextAlign.center, textScaler: TextScaler.linear(5)),
              Form(key: _loginFormKey, child: 
                Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30), 
                      child: loginPageInputTextFormField(validator: "mail", obscureText: false, controller: _controllers[0], labelText: "Endereço de email", prefixIcon: Icon(Icons.mail_outline), hintText: "exemplo@exemplo.com")
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30), 
                      child: loginPageInputTextFormField(validator: "password", obscureText: isPasswordVisible, controller: _controllers[1], labelText: "Senha", prefixIcon: Icon(Icons.lock_outline))
                    ),
                    Padding(
                      padding: EdgeInsetsGeometry.symmetric(vertical: 20),
                      child: isLoadingSignIn ? const CircularProgressIndicator.adaptive(padding: EdgeInsets.all(6),) : SizedBox(
                        width: 350, 
                        child: FilledButton(
                          onPressed: () async {
                            setState(() {
                              isLoadingSignIn = true;
                            });
                            if(_loginFormKey.currentState!.validate()) {
                              await loginFirebase();
                            }
                            setState(() {
                              isLoadingSignIn = false;
                            });
                          }, 
                          style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.green)), 
                          child: Text("Entrar", style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)))),
                    ),
                    isLoadingGoogleSignIn ? const CircularProgressIndicator.adaptive(padding: EdgeInsets.all(6),) : SizedBox(
                      width: 350, 
                      child: FilledButton.icon(
                        icon: Image.asset('assets/google-icon.png', width: 20, height: 20), 
                        onPressed: () async {
                          setState(() {
                            isLoadingGoogleSignIn = true;
                          });
                          //await loginWithGoogle();
                          setState(() {
                            isLoadingGoogleSignIn = false;
                          });
                        }, 
                        style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Color.fromARGB(217, 121, 119, 119))), 
                        label: Text("Entrar com o Google", style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),)
                      )
                    ),


                  ],
                )
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text("Não possui conta?", textScaler: TextScaler.linear(1.5),),
                  TextButton(child: Text("Registrar", style: TextStyle(color: Colors.green, fontSize: 20),), onPressed: () { Navigator.pushNamed(context, '/register'); },)
                ],
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextButton(child: Text("Esqueci a senha", style: TextStyle(fontSize: 20),), onPressed: () => ( Navigator.pushNamed(context, '/forgotpassword') ),),
                ],
              ),
            ],
          )
        )
      )
    )
    );
  }
}

Widget avatarLogoImage({required double? radius}) => CircleAvatar(
  radius: radius, 
  backgroundColor: const Color(0xD9D9D9D9), 
  child: Text(
    "Logo", 
    style: TextStyle(color: Colors.grey, fontSize: 40), 
  )
);

void notifyMessenger({required BuildContext context, required msg, required colortext, required colorbar}){
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration: Duration(seconds: 2), behavior: SnackBarBehavior.floating, showCloseIcon: true, content: Text(msg, style: TextStyle(color: colortext), textScaler: TextScaler.linear(1.2),), backgroundColor: colorbar));
}

Future<Map<String, dynamic>?> getUserData(User user) async {
  final db = FirebaseFirestore.instance;
  final userDoc = db.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);
  Map<String, dynamic>? data;
  await userDoc.get().then((DocumentSnapshot doc) {
    data = doc.data() as Map<String, dynamic>;
  }, onError: (e) => debugPrint("[getUserData method main] Error retrieving data $e"));
  return data;
}