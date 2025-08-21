import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'registerpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'forgotpasswordpage.dart';
import 'mainpage.dart';
import 'config/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      debugPrint("[Firebase Auth] User is signed out");
    }
    else {
      debugPrint("[Firebase Auth] User is signed in");
    }
  });

  String inicio = '/login';
  if (FirebaseAuth.instance.currentUser != null) {
    inicio = '/home';
  }

  runApp(
    MaterialApp(
      title: "HealthApp",
      initialRoute: inicio,
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/forgotpassword': (context) => const ForgotPasswordPage(),
        '/home': (context) => const MainPage(),
      },
    )
  );
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              avatarLogoImage(radius: 80),
              Text("HealthApp", textAlign: TextAlign.center, textScaler: TextScaler.linear(5)),
              LoginForm(),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text("Não possui conta?", textScaler: TextScaler.linear(1.5),),
                  TextButton(child: Text("Registrar", style: TextStyle(fontSize: 20),), onPressed: () { Navigator.pushNamed(context, '/register'); },)
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
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _auth = FirebaseAuth.instance;
  final _loginFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _email = "";
  String _password = "";
  User? user;
  bool isPasswordVisible = true;
  bool isLoadingGoogleSignIn = false;
  bool isLoadingSignIn = false;
  List<TextEditingController?> controllers = [];

  //TODO: Dispose not working properly and giving me headaches
  /*@override
  void dispose() {
    for (var controller in controllers) {
      controller?.dispose();
    }
    super.dispose();
    
  }*/

  String? loginFormValidator({required String? value, required String? inputType}) {
    if (value == null || value.isEmpty) { return "Esse campo não pode estar vazio"; }
    if (inputType == 'mail' && !value.contains("@")) {
      return "Insira um email valido";
    }
    if (inputType == 'password') {
      if (value.length < 5) {
        return "Insira uma senha com pelo menos 5 dígitos";
      }
      _email = _emailController.text;
    _password = _passwordController.text;
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
    controllers.add(controller);
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

  void isloggedIn(User? user) {
    if (user != null && context.mounted) {
      notifyAuthError('Logado com sucesso!', colortext: Colors.white, colorbar: Colors.green);
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void notifyAuthError(String error, {required Color colortext, required Color colorbar}) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration: Duration(seconds: 2), behavior: SnackBarBehavior.floating, showCloseIcon: true, content: Text(error, style: TextStyle(color: colortext), textScaler: TextScaler.linear(1.2),), backgroundColor: colorbar,));
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

  Future<void> loginFirebase(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      isloggedIn(credential.user);

    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          notifyAuthError('Email Inválido.', colorbar: Colors.red, colortext: Colors.white);
          break;
        case 'invalid-credential':
          notifyAuthError('Usuário e/ou senha inválidos', colorbar: Colors.blueGrey, colortext: Colors.white);
        case 'too-many-requests':
          notifyAuthError("Muitas tentativas, tente novamente mais tarde", colortext: Colors.white, colorbar: Colors.blue);
        default:
          debugPrint(e.toString());
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(key: _loginFormKey, child: 
      Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30), 
            child: loginPageInputTextFormField(validator: "mail", obscureText: false, controller: _emailController, labelText: "Endereço de email", prefixIcon: Icon(Icons.mail_outline), hintText: "exemplo@exemplo.com")
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30), 
            child: loginPageInputTextFormField(validator: "password", obscureText: isPasswordVisible, controller: _passwordController, labelText: "Senha", prefixIcon: Icon(Icons.lock_outline))
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
                    await loginFirebase(_email, _password);
                  }
                  setState(() {
                    isLoadingSignIn = false;
                  });
                }, 
                style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.green)), 
                child: Text("Entrar"))),
          ),
          isLoadingGoogleSignIn ? const CircularProgressIndicator.adaptive(padding: EdgeInsets.all(6),) : SizedBox(
            width: 350, 
            child: FilledButton.icon(
              icon: Image.asset('assets/google-icon.png', width: 20, height: 20), 
              onPressed: () async {
                setState(() {
                  isLoadingGoogleSignIn = true;
                });
                await loginWithGoogle();
                setState(() {
                  isLoadingGoogleSignIn = false;
                });
              }, 
              style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Color.fromARGB(217, 121, 119, 119))), 
              label: Text("Entrar com o Google")
            )
          ),


        ],
      )
    );
  }
}

Widget avatarLogoImage({required double? radius}) => CircleAvatar(
  radius: radius, 
  backgroundColor: const Color(0xD9D9D9D9), 
  child: Text(
    "Logo", 
    style: TextStyle(color: Colors.grey), 
    textScaler: TextScaler.linear(2),
  )
);


