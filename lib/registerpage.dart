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
      body: Container(padding: EdgeInsets.symmetric(vertical: 10),
        color: registerpagebackgroundcolor,
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                avatarLogoImage(radius: 80),
                Container(margin: EdgeInsets.only(top: 20, left: 10, right: 10),
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
  final birthdayController = TextEditingController();
  final cpfController = TextEditingController();
  final filledTextColor = const Color.fromARGB(255, 146, 142, 142);
  final today = DateTime.now();
  bool isPasswordVisible = true;
  ClientOrWorker? _clientOrWorker = ClientOrWorker.client;
  List<TextEditingController?> controllers = [];

  @override
  void dispose() {
    for (var controller in controllers) {
      controller?.dispose();
    }
    super.dispose();
  }

  String? registerFormValidator({required String? value, required String? validator}) {
    if (value == null || value.isEmpty) { return "Esse campo não pode estar vazio"; }
    if (validator == 'mail' && !value.contains("@")) {
      return "Insira um email valido";
    }
    if (validator == 'password') {
      if (value.length < 5) {
        return "Insira uma senha com pelo menos 5 dígitos";
      }
    }
    if (validator == 'cpf') {
      if (value.length != 11) {
        return "Insira um cpf valido";
      }
    }
    if (validator == 'phone') {
      if (value.length != 10) {
        return "Insira um número valido";
      }
    }

    return null;
  }

  void togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  } 

  Widget registerPageInputTextFormField({required TextEditingController controller, Widget? label, Widget? prefixIcon, String? validator, GestureTapCallback? onTap, String? hintText, required bool obscureText}) { 
    var icon = Icon(Icons.cancel_outlined);
    var onPressed = controller.clear;
    var readOnly = false;
    controllers.add(controller);
    if (validator == "password") {
      icon = isPasswordVisible ? Icon(Icons.visibility_off) : Icon(Icons.visibility);
      onPressed = togglePasswordVisibility;
    }
    if (validator == "birthday") {
      icon = Icon(Icons.edit_calendar_rounded);
      readOnly = true;
      onPressed = () async {
        DateTime? selectedDate = await showDatePicker(context: context, firstDate: DateTime(1925), lastDate: today, fieldHintText: "mm/dd/aaaa");
        if (selectedDate != null) {
          var day = selectedDate.day.toString();
          var month = selectedDate.month.toString();
          var year = selectedDate.year;
          if (day.length < 2) { day = "0$day"; }
          if (month.length < 2) { month = "0$month"; }
          birthdayController.text = "$day/$month/$year";
        }
      };
    }
    
    return TextFormField(
      controller: controller,
      validator: (value) => registerFormValidator(value: value, validator: validator),
      obscureText: obscureText,
      onTap: onTap,
      readOnly: readOnly,
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
    return Form(key: _registerFormKey,
      child: Column(
        children: [
          Row(mainAxisSize: MainAxisSize.min, spacing: 5,
            children: [
              Expanded(child: registerPageInputTextFormField(prefixIcon: Icon(Icons.person), controller: nameController, obscureText: false, hintText: "Insira seu Nome", label: Text("Nome")),),
              Expanded(child: registerPageInputTextFormField(controller: surnameController, obscureText: false, hintText: "Insira seu Sobrenome", label: Text("Sobrenome"))),
            ],
          ),
          Padding(
            padding: EdgeInsetsGeometry.symmetric(vertical: 30), 
            child: Row(
              children: [
                Expanded(child: registerPageInputTextFormField(prefixIcon: Icon(Icons.email), validator: 'mail', controller: mailController, obscureText: false, hintText: "exemplo@exemplo.com", label: Text("Email")),)
              ],
            ),
          ),
          Padding(padding: EdgeInsetsGeometry.only(bottom: 30), child: 
            Row(
              children: [
                Expanded(child: registerPageInputTextFormField(prefixIcon: Icon(Icons.south_america_outlined), validator: 'cpf', controller: cpfController, obscureText: false, hintText: "000.000.000-00", label: Text("CPF"))),
              ],
            )
          ),
          Row(spacing: 3,
            children: [
              SizedBox(width: 207, child: registerPageInputTextFormField(prefixIcon: Icon(Icons.phone_android_rounded), validator: 'phone', controller: phoneController, obscureText: false, hintText: "(00) 0000-0000", label: Text("Celular"))),
              Expanded(child: registerPageInputTextFormField(validator: 'birthday', controller: birthdayController, obscureText: false, hintText: "dd/mm/aaaa", label: Text("Data de nascimento")),)
            ],
          ),
          Padding(padding: EdgeInsetsGeometry.only(top: 30), child: 
            Row(
              children: [
                Expanded(child: registerPageInputTextFormField(prefixIcon: Icon(Icons.lock), validator: 'password', controller: passwordController, obscureText: isPasswordVisible, hintText: "******", label: Text("Senha"))),
              ],
            )
          ),

          Padding(
            padding: EdgeInsetsGeometry.only(top: 40, left: 20, right: 20),
            child: Row(
              children: [
                Expanded(child: Text("Deseja utilizar o aplicativo ou trabalhar com ele?", textScaler: TextScaler.linear(1.3),),),
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
            padding: EdgeInsetsGeometry.only(top: 40),
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
          

        ],
      ),
    );
  }
}