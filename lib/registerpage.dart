import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum ClientOrWorker { client , worker }

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final registerformbackgroundcolor = const Color.fromARGB(255, 199, 199, 199);
  final registerpagebackgroundcolor = Colors.white;
  final _registerFormKey = GlobalKey<FormState>();
  final _controllers = List.generate(8, (index) => TextEditingController());
  final filledTextColor = const Color.fromARGB(255, 146, 142, 142);
  final today = DateTime.now();
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  bool isloading = false;
  User? user;
  bool isPasswordVisible = true;
  ClientOrWorker? _accountType = ClientOrWorker.client;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String? registerFormValidator({required String? value, required String? validator}) {
    if (value == null || value.isEmpty) { return "Esse campo não pode estar vazio"; }
    if (validator == 'mail' && !value.contains("@")) {
      return "Insira um email valido";
    }
    if (validator == 'password') {
      if (value.length < 6) {
        return "Insira uma senha com pelo menos 6 dígitos";
      }
    }
    if (validator == 'password2') {
      if (value != _controllers[6].text) {
        return "Senhas não correspondem";
      }
    }
    if (validator == 'cpf') {
      if (value.length != 11) {
        return "Insira um cpf valido";
      }
    }
    if (validator == 'phone') {
      if (value.length != 11) {
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

  void hasUser(User? user) {
    if (user != null) {
      if(mounted) notifyMessenger(context: context, msg: 'Cadastrado com sucesso!', colortext: Colors.white, colorbar: Colors.green);
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Widget registerPageInputTextFormField({String? onSaved, TextInputType? keyboardType, int? maxLength, required TextEditingController controller, Widget? label, Widget? prefixIcon, String? validator, GestureTapCallback? onTap, String? hintText, required bool obscureText}) { 
    var icon = Icon(Icons.cancel_outlined);
    var onPressed = controller.clear;
    var readOnly = false;
    if (validator == "password") {
      icon = isPasswordVisible ? Icon(Icons.visibility_off) : Icon(Icons.visibility);
      onPressed = togglePasswordVisibility;
    }
    if (validator == "birthday") {
      icon = Icon(Icons.edit_calendar_rounded);
      readOnly = true;
      onPressed = () async {
        DateTime? selectedDate = await showDatePicker(keyboardType: TextInputType.text, context: context, firstDate: DateTime(1925), lastDate: today, fieldHintText: "mm/dd/aaaa");
        if (selectedDate != null) {
          var day = selectedDate.day.toString();
          var month = selectedDate.month.toString();
          var year = selectedDate.year;
          if (day.length < 2) { day = "0$day"; }
          if (month.length < 2) { month = "0$month"; }
         _controllers[5].text = "$day/$month/$year";
        }
      };
    }
    
    return TextFormField(
      controller: controller,
      buildCounter: (BuildContext context, { int? currentLength, int? maxLength, bool? isFocused }) => null,
      validator: (value) => registerFormValidator(value: value, validator: validator),
      obscureText: obscureText,
      onTap: onTap,
      maxLength: maxLength,
      keyboardType: keyboardType,
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
                        Form(key: _registerFormKey,
                          child: Column(
                            children: [
                              Row(mainAxisSize: MainAxisSize.min, spacing: 5,
                                children: [
                                  Expanded(child: registerPageInputTextFormField(keyboardType: TextInputType.name, prefixIcon: Icon(Icons.person), controller: _controllers[0], obscureText: false, hintText: "Insira seu Nome", label: Text("Nome")),),
                                  Expanded(child: registerPageInputTextFormField(keyboardType: TextInputType.name, controller: _controllers[1], obscureText: false, hintText: "Insira seu Sobrenome", label: Text("Sobrenome"))),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsetsGeometry.symmetric(vertical: 30), 
                                child: Row(
                                  children: [
                                    Expanded(child: registerPageInputTextFormField(keyboardType: TextInputType.emailAddress, prefixIcon: Icon(Icons.email), validator: 'mail', controller: _controllers[2], obscureText: false, hintText: "exemplo@exemplo.com", label: Text("Email")),)
                                  ],
                                ),
                              ),
                              Padding(padding: EdgeInsetsGeometry.only(bottom: 30), child: 
                                Row(
                                  children: [
                                    Expanded(child: registerPageInputTextFormField(keyboardType: TextInputType.number, maxLength: 11, prefixIcon: Icon(Icons.south_america_outlined), validator: 'cpf', controller: _controllers[3], obscureText: false, hintText: "000.000.000-00", label: Text("CPF"))),
                                  ],
                                )
                              ),
                              Row(spacing: 3,
                                children: [
                                  SizedBox(width: 210, child: registerPageInputTextFormField(keyboardType: TextInputType.phone, maxLength: 11, prefixIcon: Icon(Icons.phone_android_rounded), validator: 'phone', controller: _controllers[4], obscureText: false, hintText: "(00) 0000-0000", label: Text("Celular"))),
                                  Expanded(child: registerPageInputTextFormField(validator: 'birthday', controller: _controllers[5], obscureText: false, hintText: "dd/mm/aaaa", label: Text("Data de nasci\nmento")),)
                                ],
                              ),
                              Padding(padding: EdgeInsetsGeometry.only(top: 30), child: 
                                Row(
                                  children: [
                                    Expanded(child: registerPageInputTextFormField(keyboardType: TextInputType.text, prefixIcon: Icon(Icons.lock), validator: 'password', controller: _controllers[6], obscureText: isPasswordVisible, hintText: "******", label: Text("Senha"))),
                                  ],
                                )
                              ),
                              Padding(padding: EdgeInsetsGeometry.only(top: 30), child: 
                                Row(
                                  children: [
                                    Expanded(child: registerPageInputTextFormField(keyboardType: TextInputType.text, prefixIcon: Icon(Icons.lock), validator: 'password2', controller: _controllers[7], obscureText: true, hintText: "******", label: Text("Confirmar Senha"))),
                                  ],
                                ),
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
                                    RadioGroup<ClientOrWorker>(
                                      groupValue: _accountType,
                                      onChanged: (ClientOrWorker? value) {
                                        setState(() {
                                          _accountType = value;
                                        });
                                      }, 
                                      child: Row(children: [
                                        Radio<ClientOrWorker>(value: ClientOrWorker.client),
                                        Text("Cliente"),
                                        Radio<ClientOrWorker>(value: ClientOrWorker.worker),
                                        Text("Profissional"),
                                      ],)
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsGeometry.only(top: 40),
                                child: isloading ? const CircularProgressIndicator() : SizedBox(
                                  width: 400,
                                  height: 50,
                                  child: FilledButton(
                                    onPressed: () async {
                                      setState(() {
                                        isloading = true;
                                      });
                                      if(_registerFormKey.currentState!.validate()) {
                                        registerFirebase(_accountType, false);
                                      }
                                      setState(() {
                                        isloading = false;
                                      });
                                    }, 
                                    style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Color.fromARGB(217, 121, 119, 119))), 
                                    child: Text("Cadastrar!", textScaler: TextScaler.linear(2), style: TextStyle(color: Colors.black),)
                                  )
                                ),
                              ),
                              

                            ],
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
  
  Future<void> registerFirebase(ClientOrWorker? accountType, bool isformAnswered) async {
    try {
      String email = _controllers[2].text;
      String password = _controllers[7].text;
      String name = _controllers[0].text;
      String surname = _controllers[1].text;
      String cpf = _controllers[3].text;
      String phone = _controllers[4].text;
      String birthday = _controllers[5].text;
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await createFirestore(credential.user!.uid, name, surname, cpf, phone, birthday, accountType, isformAnswered);
      hasUser(credential.user);

    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          if(mounted) notifyMessenger(context: context, msg: "Email inválido", colortext: Colors.white, colorbar: Colors.red);
          break;
        case 'weak-password':
          if(mounted) notifyMessenger(context: context, msg: "Senha fraca", colortext: Colors.white, colorbar: Colors.red);
          break;
        case 'email-already-in-use':
          if(mounted) notifyMessenger(context: context, msg: "Já existe uma conta com esse email!", colortext: Colors.white, colorbar: Colors.red);
          break;
        case 'too-many-requests':
          if(mounted) notifyMessenger(context: context, msg: "Muitas tentativas, tente novamente mais tarde", colortext: Colors.black, colorbar: Colors.grey);
          break;
        default:
          debugPrint(e.toString());
          break;
      }
      debugPrint(e.toString());
    }
  }
  
  Future<void> createFirestore(String uid, String name, String surname, String cpf, String phonenumber, String birthday, ClientOrWorker? accountType, bool isformAnswered) async {
    await _db.collection("users").doc(uid).set({
      'Name': name,
      'Surname': surname,
      'CPF': cpf,
      'Phone': phonenumber,
      'Birthday': birthday,
      'Account_Type': accountType == ClientOrWorker.client ? 'Cliente' : 'Profissional',
      'isformAnswered': isformAnswered,
    });
  }
}