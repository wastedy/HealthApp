import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      title: "HealthApp",
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/forgotpassword': (context) => const ForgotPassword()
      },
    )
  );
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          body: Center(child: Builder(builder: (context) {
            return SingleChildScrollView(padding: EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                    Padding(
                      padding: EdgeInsetsGeometry.symmetric(vertical: 10), 
                      child: CircleAvatar(radius: 80, backgroundColor: const Color(0xD9D9D9D9), child: Text("Logo", style: TextStyle(color: Colors.grey),textScaler: TextScaler.linear(2),)),
                    ),
                    Text("HealthApp", textAlign: TextAlign.center, textScaler: TextScaler.linear(5)),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30), 
                      child: TextFormField(decoration: InputDecoration(labelText: "Endereço de email", border: OutlineInputBorder(borderRadius: BorderRadius.circular(25))),),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30), 
                      child: TextFormField(decoration: InputDecoration(labelText: "Senha", border: OutlineInputBorder(borderRadius: BorderRadius.circular(25))),),
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(child: ListTile(
                          title: const Text("Lembrar por 30 dias?"),
                          leading: CheckboxRememberLoginPage(),
                          ),
                        ),
                        TextButton(child: Text("Esqueceu a senha?"), onPressed: () => ( Navigator.pushNamed(context, '/forgotpassword') ),),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsetsGeometry.symmetric(vertical: 20),
                      child: SizedBox(width: 350, child: FilledButton(onPressed: () => (), style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.green)), child: Text("Entrar"))),
                    ),
                    SizedBox(width: 350, child: FilledButton.icon(icon: Image.asset('assets/google-icon.png', width: 20, height: 20), onPressed: () => (), style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Color.fromARGB(217, 121, 119, 119))), label: Text("Entrar com o Google"))),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text("Não possui conta?", textScaler: TextScaler.linear(1.5),),
                        TextButton(child: Text("Registrar"), onPressed: () { Navigator.pushNamed(context, '/register'); },)
                      ],
                    )
                  ],
                )
              );
            },
          )
        )
      );
  }
}
class CheckboxRememberLoginPage extends StatefulWidget {
    const CheckboxRememberLoginPage({super.key});

    @override
    State<CheckboxRememberLoginPage> createState() => _CheckboxRememberLoginState();
}

class _CheckboxRememberLoginState extends State<CheckboxRememberLoginPage> {
    bool isChecked = false;
    @override
    Widget build(BuildContext context) {
      return Checkbox(value: isChecked, onChanged: (value) => setState(() {
        isChecked = value!;
      }),);
    }
}

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cadastro")),
      body: Placeholder()
    );
  }
}

class ForgotPassword extends StatelessWidget {
  const ForgotPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Esqueci a senha")),
      body: Placeholder()
    );
  }
}
