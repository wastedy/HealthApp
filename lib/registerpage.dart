import 'package:flutter/material.dart';
import 'main.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});
  final registerformbackgroundcolor = const Color.fromARGB(255, 199, 199, 199);
  final registerpagebackgroundcolor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cadastro"), backgroundColor: const Color.fromARGB(255, 199, 199, 199),),
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
                        RegisterForm(),

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

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _registerFormKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final mailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final filledTextColor = const Color.fromARGB(255, 146, 142, 142);
  bool isPasswordVisible = false;
  ClientOrWorker? _clientOrWorker = ClientOrWorker.client;

  String? registerFormValidator({required String? value, required String? inputType}) {
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

  Widget registerPageInputTextFormField({required TextEditingController controller, Widget? label, Widget? prefixIcon, String? validator, String? hintText, required bool obscureText}) { 
    var icon = Icon(Icons.cancel_outlined);
    var onPressed = controller.clear;
    if (validator == "password") {
      icon = isPasswordVisible ? Icon(Icons.visibility_off) : Icon(Icons.visibility);
      onPressed = togglePasswordVisibility;
    }
    
    return TextFormField(
      controller: controller,
      validator: (value) => registerFormValidator(value: value, inputType: validator),
      obscureText: obscureText,
      decoration: InputDecoration(
        filled: true,
        fillColor: filledTextColor,
        label: label,
        prefixIcon: prefixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
        suffixIcon: IconButton(onPressed: onPressed, icon: icon),
        hintText: hintText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          Row(mainAxisSize: MainAxisSize.min, spacing: 10,
            children: [
              Expanded(child: registerPageInputTextFormField(controller: nameController, obscureText: false, hintText: "Insira seu Nome", label: Text("Nome")),),
              Expanded(child: registerPageInputTextFormField(controller: surnameController, obscureText: false, hintText: "Insira seu Sobrenome", label: Text("Sobrenome"))),
            ],
          ),
          Padding(
            padding: EdgeInsetsGeometry.symmetric(vertical: 30), 
            child: Row(
              children: [
                Expanded(child: registerPageInputTextFormField(validator: 'mail', controller: mailController, obscureText: false, hintText: "exemplo@exemplo.com", label: Text("Email")),)
              ],
            ),
          ),
          Row(
            children: [
              SizedBox(
                width: 250,
                child: registerPageInputTextFormField(validator: 'phone', controller: phoneController, obscureText: false, hintText: "(00) 0000-0000", label: Text("Celular")),
              )
            ],
          ),
          Padding(
            padding: EdgeInsetsGeometry.only(top: 40, left: 20, right: 20),
            child: Row(
              children: [
                Expanded(child: Text("Deseja utilizar o aplicativo ou trabalhar com ele?"),),
              ]
            ),
          ),
          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 60),
            child: Row(
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
            ),
          ),
          Padding(
            padding: EdgeInsetsGeometry.only(top: 80),
            child: SizedBox(
              width: 400,
              height: 50,
              child: FilledButton(
                onPressed: () => {
                  if(_registerFormKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Dados Enviados!")))
                  }
                }, 
                style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Color.fromARGB(217, 121, 119, 119))), 
                child: Text("Cadastrar!", textScaler: TextScaler.linear(2), style: TextStyle(color: Colors.black),)
              )
            ),
          ),
          //InputDatePickerFormField(firstDate: firstDate, lastDate: lastDate)
        ],
      ),
    );
  }
}