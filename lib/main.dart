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
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              avatarLogoImage(radius: 80),
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
        }
      ),
    );
  }
}

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});
  final registerformbackgroundcolor = Colors.grey;
  final registerpagebackgroundcolor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cadastro")),
      body: Container(padding: EdgeInsets.symmetric(vertical: 20),
        color: registerpagebackgroundcolor,
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                avatarLogoImage(radius: 80),
                Container(margin: EdgeInsets.symmetric(vertical: 50, horizontal: 10),
                  decoration: BoxDecoration(color: registerformbackgroundcolor, borderRadius: BorderRadius.circular(25), border: Border.all(width: 10, color: registerformbackgroundcolor)),
                  child: Padding(
                    padding: EdgeInsetsGeometry.only(top: 20, bottom: 10), 
                    child: Column(
                      children: [
                        Row(mainAxisSize: MainAxisSize.min, spacing: 10,
                          children: [
                            Expanded(child: TextFormField(decoration: InputDecoration(hintText: "Insira seu Nome", label: Text("Nome"), border: OutlineInputBorder(borderRadius: BorderRadius.circular(25))),),),
                            Expanded(child: TextFormField(decoration: InputDecoration(hintText: "Insira seu Sobrenome", label: Text("Sobrenome"), border: OutlineInputBorder(borderRadius: BorderRadius.circular(25))),))
                          ],
                        ),
                        Padding(
                          padding: EdgeInsetsGeometry.symmetric(vertical: 30), 
                          child: Row(
                            children: [
                              Expanded(child: TextFormField(decoration: InputDecoration(hintText: "exemplo@dominio.com", label: Text("Email"), border: OutlineInputBorder(borderRadius: BorderRadius.circular(25))),),)
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 250,
                              child: TextFormField(decoration: InputDecoration(hintText: "(00) 0000-0000", label: Text("Celular"), border: OutlineInputBorder(borderRadius: BorderRadius.circular(25))),),
                            )
                          ],
                        ),
                        Padding(
                          padding: EdgeInsetsGeometry.symmetric(vertical: 20, horizontal: 20),
                          child: Row(
                            children: [
                              Expanded(child: Text("Deseja utilizar o aplicativo ou trabalhar com ele?"),),
                            ]
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsGeometry.symmetric(horizontal: 60),
                          child: ClientOrWorkerRadioList(),
                        ),
                        Padding(
                          padding: EdgeInsetsGeometry.only(top: 100),
                          child: SizedBox(
                            width: 400,
                            height: 50,
                            child: FilledButton(
                              onPressed: () => (), 
                              style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Color.fromARGB(217, 121, 119, 119))), 
                              child: Text("Cadastrar!", textScaler: TextScaler.linear(2), style: TextStyle(color: Colors.white),)
                            )
                          ),
                        ),
                        

                      ],
                    )
                  ),
                )
              ],
            ),
          )
        ),
      )
    );
  }
}

enum ClientOrWorker { client, worker }

class ClientOrWorkerRadioList extends StatefulWidget {
  const ClientOrWorkerRadioList({super.key});

  @override
  State<ClientOrWorkerRadioList> createState() => _ClientOrWorkerRadioListState();
}

class _ClientOrWorkerRadioListState extends State<ClientOrWorkerRadioList> {
  ClientOrWorker? _clientOrWorker = ClientOrWorker.client;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Radio<ClientOrWorker>(
          value: ClientOrWorker.client, 
          groupValue: _clientOrWorker, 
          onChanged: (ClientOrWorker? value) {
            setState(() {
              _clientOrWorker = value;
            });
          }
        ),
        Expanded(child: Text("Cliente")),
        Radio<ClientOrWorker>(
          value: ClientOrWorker.worker, 
          groupValue: _clientOrWorker, 
          onChanged: (ClientOrWorker? value) {
            setState(() {
              _clientOrWorker = value;
            });
          }
        ),
        Expanded(child: Text("Profissional"))
      ],
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
