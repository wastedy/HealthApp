import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'registerpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'forgotpasswordpage.dart';
import 'mainpage.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  String inicio = '/login';
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
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
                  TextButton(child: Text("Registrar"), onPressed: () { Navigator.pushNamed(context, '/register'); },)
                ],
              )
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
  User? user;
  bool isPasswordVisible = true;
  bool isLoadingGoogleSignIn = false;
  List<TextEditingController?> controllers = [];

  @override
  void dispose() {
    for (var controller in controllers) {
      controller?.dispose();
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
    if (user != null) {
      notifyAuthError('Logado com sucesso!', colortext: Colors.white, colorbar: Colors.green);
      Navigator.popAndPushNamed(context, '/home');
    }
  }

  void notifyAuthError(String error, {required Color colortext, required Color colorbar}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(behavior: SnackBarBehavior.floating, showCloseIcon: true, content: Text(error, style: TextStyle(color: colortext), textScaler: TextScaler.linear(1.2),), backgroundColor: colorbar,));
  }

  Future<User?> loginWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      final googleAuth = await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(idToken: googleAuth?.idToken, accessToken: googleAuth?.accessToken);

      UserCredential usercred = await _auth.signInWithCredential(credential);
      return usercred.user;
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<User?> loginFirebase(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return credential.user;

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
    return null;
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
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton(child: Text("Esqueceu a senha?"), onPressed: () => ( Navigator.pushNamed(context, '/forgotpassword') ),),
            ],
          ),
          Padding(
            padding: EdgeInsetsGeometry.symmetric(vertical: 20),
            child: SizedBox(
              width: 350, 
              child: FilledButton(
                onPressed: () async {
                  if(_loginFormKey.currentState!.validate()) {
                    user = await loginFirebase(_emailController.text, _passwordController.text);
                    isloggedIn(user);
                  }
                }, 
                style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.green)), 
                child: Text("Entrar"))),
          ),
          isLoadingGoogleSignIn ? const CircularProgressIndicator(padding: EdgeInsets.all(6),) : SizedBox(
            width: 350, 
            child: FilledButton.icon(
              icon: Image.asset('assets/google-icon.png', width: 20, height: 20), 
              onPressed: () async {
                setState(() {
                  isLoadingGoogleSignIn = true;
                });
                user = await loginWithGoogle();
                isloggedIn(user);
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


