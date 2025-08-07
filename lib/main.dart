import 'package:flutter/material.dart';
import 'registerpage.dart';
import 'forgotpasswordpage.dart';
import 'homepage.dart';

void main() {
  runApp(
    MaterialApp(
      title: "HealthApp",
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/forgotpassword': (context) => const ForgotPasswordPage(),
        '/home': (context) => const HomePage(),
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
              loginWithGoogleButton(width: 350),
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
  final _loginFormKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool is30DayLoginRememberChecked = false;
  bool isPasswordVisible = true;

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

  @override
  Widget build(BuildContext context) {
    return Form(key: _loginFormKey, child: 
      Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30), 
            child: loginPageInputTextFormField(validator: "mail", obscureText: false, controller: emailController, labelText: "Endereço de email", prefixIcon: Icon(Icons.mail_outline), hintText: "exemplo@exemplo.com")
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30), 
            child: loginPageInputTextFormField(validator: "password", obscureText: isPasswordVisible, controller: passwordController, labelText: "Senha", prefixIcon: Icon(Icons.lock_outline))
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(child: ListTile(
                  title: const Text("Lembrar por 30 dias?"),
                  leading: Checkbox(value: is30DayLoginRememberChecked, onChanged: (value) => setState(() { 
                    is30DayLoginRememberChecked = value!;
                  })),
                ),
              ),
              TextButton(child: Text("Esqueceu a senha?"), onPressed: () => ( Navigator.pushNamed(context, '/forgotpassword') ),),
            ],
          ),
          Padding(
            padding: EdgeInsetsGeometry.symmetric(vertical: 20),
            child: SizedBox(
              width: 350, 
              child: FilledButton(
                onPressed: () => {
                  if(_loginFormKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Dados Enviados!"))),
                    Navigator.pushNamed(context, '/home')
                  }
                }, 
                style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.green)), 
                child: Text("Entrar"))),
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

Widget loginWithGoogleButton({required double? width}) {
  return SizedBox(
    width: width, 
    child: FilledButton.icon(
      icon: Image.asset('assets/google-icon.png', width: 20, height: 20), 
      onPressed: () => (), 
      style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Color.fromARGB(217, 121, 119, 119))), 
      label: Text("Entrar com o Google")
    )
  );
}
