import 'package:cloud_firestore/cloud_firestore.dart';
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

    final defaultTheme = ThemeData(textTheme: TextTheme().apply(bodyColor: Colors.white, displayColor: Colors.white));
    if (user != null && userData != null) {
      rotas['/home'] = (context) => MainPage(userData: userData!);
      debugPrint("[signedInOrSignedOut method] ${userData.toString()}");
      inicio = '/home';
      return MaterialApp(
        title: "HealthApp",
        initialRoute: inicio,
        routes: rotas,
        theme: defaultTheme,
      );
    }
    return MaterialApp(
      title: "HealthApp",
      initialRoute: inicio,
      routes: rotas,
      theme: defaultTheme,
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
  final backgroundColor = Color.fromARGB(255, 32, 32, 32);
  final formColor = Color.fromARGB(255, 43, 43, 43);
  final iconsColor = Colors.white;
  final inputFieldColor = Color.fromRGBO(175, 175, 175, 0.21);
  final _auth = FirebaseAuth.instance;
  final _loginFormKey = GlobalKey<FormState>();
  final List<TextEditingController> _controllers = List.generate(2, (i) => TextEditingController());
  User? user;
  bool isFormValid = true; //change for button react to user changes
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

  void isFormComplete() {
    if (_loginFormKey.currentState!.validate()) {
      setState(() {
        isFormValid = true;
      });
    }
    else {
      setState(() {
        isFormValid = false;
      });
    }
  }

  void togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  Widget loginPageInputTextFormField({required TextEditingController controller, String? labelText, Widget? prefixIcon, required String? validator, String? hintText, required bool obscureText}) { 
    var icon = Icon(Icons.cancel_outlined, color: iconsColor,);
    var onPressed = controller.clear;
    if (validator == "password") {
      icon = isPasswordVisible ?  Icon(Icons.visibility_off, color: iconsColor,) : Icon(Icons.visibility, color: iconsColor,);
      onPressed = togglePasswordVisibility;
    }
    return TextFormField(
      controller: controller,
      validator: (value) => loginFormValidator(value: value, inputType: validator),
      obscureText: obscureText,
      textAlignVertical: TextAlignVertical.center,
      style: TextStyle(color: Colors.white),
      //onChanged: (value) { isFormComplete(); }, change for button react to user changes
      decoration: InputDecoration(
        filled: true,
        fillColor: inputFieldColor,
        hintStyle: TextStyle(color: Colors.black.withAlpha(127)),
        prefixIcon: prefixIcon,
        suffixIcon: IconButton(onPressed: onPressed, icon: icon),
        border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(25)),
        hintText: hintText,
        errorStyle: TextStyle(fontSize: 12)
      ),
    );
  }

  Future<void> isloggedIn(User? user) async {
    if (user != null) {
      notifyMessenger(context: context, msg: 'Logado com sucesso!', colortext: Colors.white, colorbar: Colors.green);
      
      final userData = await getUserData(user);
      if (userData == null) {
        if(mounted) notifyMessenger(context: context, msg: 'Logado mas sem dados', colortext: Colors.white, colorbar: Colors.red);
        //if(mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UpdatePage(user: user)));
      }
      else {
        if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MainPage(userData: userData)));
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
          padding: EdgeInsets.only(top: 153),
          child: Column(
            children: <Widget>[
              Row(mainAxisAlignment: MainAxisAlignment.center, spacing: 10,
                children: [
                  avatarLogoImage(radius: 25, fontSize: 15, backgroundColor: Color.fromARGB(255, 71, 71, 71)),
                  Text("HealthApp", textAlign: TextAlign.center, style: TextStyle(fontSize: 36, color: Colors.white),),
                ],
              ),
              Padding(padding: EdgeInsetsGeometry.only(top: 41)),
              Form(key: _loginFormKey, child: 
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  decoration: BoxDecoration(color: formColor, borderRadius: BorderRadius.circular(25)),
                  width: MediaQuery.sizeOf(context).width - 50,
                  height: 357,
                  child: Column(
                    children: <Widget>[
                      loginPageInputTextFormField(validator: "mail", obscureText: false, controller: _controllers[0], hintText: "Endereço de email", prefixIcon: Icon(Icons.mail_outline, color: iconsColor,)),
                      Padding(padding: EdgeInsetsGeometry.only(top: 25)),
                      loginPageInputTextFormField(validator: "password", obscureText: isPasswordVisible, controller: _controllers[1], prefixIcon: Icon(Icons.lock_outline, color: iconsColor,), hintText: "Senha"),
                      Padding(padding: EdgeInsetsGeometry.only(top: 25)),
                      isLoadingGoogleSignIn ? const CircularProgressIndicator.adaptive(padding: EdgeInsets.all(6),) : SizedBox(
                        width: 372,
                        height: 45,
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
                          label: Text("Entrar com o Google", style: TextStyle(fontSize: 20),)
                        )
                      ),
                      Padding(padding: EdgeInsetsGeometry.only(top: 25)),
                      isLoadingSignIn ? const CircularProgressIndicator.adaptive(padding: EdgeInsets.all(6),) : SizedBox(
                        width: 372,
                        height: 45, 
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
                          style: ButtonStyle(backgroundColor: isFormValid ? WidgetStatePropertyAll(Colors.green) : WidgetStatePropertyAll(Colors.grey)), 
                          child: Text("Entrar", style: TextStyle(fontSize: 20),))),
                  
                    ],
                  ),
                )
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, spacing: 0, children: <Widget>[
                  TextButton(onPressed: () { Navigator.pushNamed(context, '/register'); }, child: Text("Criar uma conta", style: TextStyle(color: const Color.fromARGB(255, 0, 119, 255), fontSize: 23),)),
                  TextButton(child: Text("Esqueci a senha", style: TextStyle(color: const Color.fromARGB(255, 142, 255, 236), fontSize: 23),), onPressed: () { Navigator.pushNamed(context, '/forgotpassword'); },)
                ],
              ),


            ],
          )
        )
    );
  }
}

Widget avatarLogoImage({required double? radius, required double? fontSize, required Color? backgroundColor}) => CircleAvatar(
  radius: radius, 
  backgroundColor: backgroundColor, 
  child: Text(
    "Logo", 
    style: TextStyle(color: Colors.white, fontSize: fontSize), 
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

class UserData {
  final String name;
  final String surname;
  final String mail;
  final String phone;
  final String cpf;
  final String birthday;

  const UserData({required this.name, required this.surname, required this.mail, required this.phone, required this.cpf, required this.birthday});
}