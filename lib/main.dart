import 'package:flutter/material.dart';

void main() {
  runApp(LoginPage());
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
          body: Center(child: Builder(builder: (context) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 121), // Change here if it overflows
              child: Column(
                children: [
                    CircleAvatar(radius: 80, backgroundColor: const Color(0xD9D9D9D9), child: Text("Logo", style: TextStyle(color: Colors.black),textScaler: TextScaler.linear(2),)),
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
                          leading: CheckboxRememberLogin(),
                          ),
                        ),
                        TextButton(child: Text("Esqueceu a senha?"), onPressed: () => (),),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsetsGeometry.symmetric(vertical: 20),
                      child: SizedBox(width: 350, child: FilledButton(onPressed: () => (), style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.green)), child: Text("Entrar"))),
                    ),
                    SizedBox(width: 350, child: FilledButton.icon(icon: Image.asset('assets/google-icon.png', width: 20, height: 20), onPressed: () => (), style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Color.fromARGB(217, 121, 119, 119))), label: Text("Entrar com o Google"))),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text("Não possui conta?", textScaler: TextScaler.linear(1.5),),
                      TextButton(child: Text("Registrar"), onPressed: () {},)
                    ],)
                  ],
                )
              );
            },
          )
        )
      )
    );
  
  }
}
class CheckboxRememberLogin extends StatefulWidget {
  const CheckboxRememberLogin({super.key});

  @override
  State<CheckboxRememberLogin> createState() => _CheckboxRememberLoginState();
}

class _CheckboxRememberLoginState extends State<CheckboxRememberLogin> {
  bool isChecked = false;
  @override
  Widget build(BuildContext context) {
    return Checkbox(value: isChecked, onChanged: (value) => setState(() {
      isChecked = value!;
    }),);
  }
}

