import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _mailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _cpfController = TextEditingController();
  final filledTextColor = const Color.fromARGB(255, 146, 142, 142);
  final today = DateTime.now();
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  bool isloading = false;
  User? user;
  bool isPasswordVisible = true;
  ClientOrWorker? _clientOrWorker = ClientOrWorker.client;
  List<TextEditingController?> controllers = [];
  
  //Dispose giving too much headache
  //@override
  //void dispose() {
    //for (var controller in controllers) {
      //controller?.dispose();
    //}
    //super.dispose();
  //}

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
    if (user != null && context.mounted) {
      Navigator.of(context).popAndPushNamed('/home');
    }
  }

  Widget registerPageInputTextFormField({TextInputType? keyboardType, int? maxLength, required TextEditingController controller, Widget? label, Widget? prefixIcon, String? validator, GestureTapCallback? onTap, String? hintText, required bool obscureText}) { 
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
         _birthdayController.text = "$day/$month/$year";
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
    return Form(key: _registerFormKey,
      child: Column(
        children: [
          Row(mainAxisSize: MainAxisSize.min, spacing: 5,
            children: [
              Expanded(child: registerPageInputTextFormField(keyboardType: TextInputType.name, prefixIcon: Icon(Icons.person), controller: _nameController, obscureText: false, hintText: "Insira seu Nome", label: Text("Nome")),),
              Expanded(child: registerPageInputTextFormField(keyboardType: TextInputType.name, controller: _surnameController, obscureText: false, hintText: "Insira seu Sobrenome", label: Text("Sobrenome"))),
            ],
          ),
          Padding(
            padding: EdgeInsetsGeometry.symmetric(vertical: 30), 
            child: Row(
              children: [
                Expanded(child: registerPageInputTextFormField(keyboardType: TextInputType.emailAddress, prefixIcon: Icon(Icons.email), validator: 'mail', controller: _mailController, obscureText: false, hintText: "exemplo@exemplo.com", label: Text("Email")),)
              ],
            ),
          ),
          Padding(padding: EdgeInsetsGeometry.only(bottom: 30), child: 
            Row(
              children: [
                Expanded(child: registerPageInputTextFormField(keyboardType: TextInputType.number, maxLength: 11, prefixIcon: Icon(Icons.south_america_outlined), validator: 'cpf', controller: _cpfController, obscureText: false, hintText: "000.000.000-00", label: Text("CPF"))),
              ],
            )
          ),
          Row(spacing: 3,
            children: [
              SizedBox(width: 207, child: registerPageInputTextFormField(keyboardType: TextInputType.phone, maxLength: 11, prefixIcon: Icon(Icons.phone_android_rounded), validator: 'phone', controller: _phoneController, obscureText: false, hintText: "(00) 0000-0000", label: Text("Celular"))),
              Expanded(child: registerPageInputTextFormField(validator: 'birthday', controller: _birthdayController, obscureText: false, hintText: "dd/mm/aaaa", label: Text("Data de nascimento")),)
            ],
          ),
          Padding(padding: EdgeInsetsGeometry.only(top: 30), child: 
            Row(
              children: [
                Expanded(child: registerPageInputTextFormField(keyboardType: TextInputType.text, prefixIcon: Icon(Icons.lock), validator: 'password', controller: _passwordController, obscureText: isPasswordVisible, hintText: "******", label: Text("Senha"))),
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
            child: isloading ? const CircularProgressIndicator() : SizedBox(
              width: 400,
              height: 50,
              child: FilledButton(
                onPressed: () async {
                  setState(() {
                    isloading = true;
                  });
                  if(_registerFormKey.currentState!.validate()) {
                    user = await registerFirebase(_mailController.text, _passwordController.text, _nameController.text, _surnameController.text, _cpfController.text, _phoneController.text);
                    hasUser(user);
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
    );
  }

  void notifyAuthError(String error, {required Color colortext, required Color colorbar}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(behavior: SnackBarBehavior.floating, showCloseIcon: true, content: Text(error, style: TextStyle(color: colortext), textScaler: TextScaler.linear(1.2),), backgroundColor: colorbar,));
  }
  
  Future<User?> registerFirebase(String email, String password, name, surname, cpf, phone) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await createFirestore(credential.user!.uid, name, surname, cpf, phone);
      return credential.user;

    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          notifyAuthError("Email inválido", colortext: Colors.white, colorbar: Colors.red);
          break;
        case 'weak-password':
          notifyAuthError("Senha fraca", colortext: Colors.white, colorbar: Colors.red);
          break;
        case 'email-already-in-use':
          notifyAuthError("Já existe uma conta com esse email!", colortext: Colors.white, colorbar: Colors.red);
          break;
        case 'too-many-requests':
          notifyAuthError("Muitas tentativas, tente novamente mais tarde", colortext: Colors.black, colorbar: Colors.grey);
          break;
        default:
          debugPrint(e.toString());
          break;
      }
      debugPrint(e.toString());
    }
    return null;
  }
  
  Future<void> createFirestore(String uid, String name, String surname, String cpf, String phonenumber) async {
    await _db.collection("users").doc(uid).set({
      'Name': name,
      'Surname': surname,
      'CPF': cpf,
      'Phone': phonenumber
    });
  }
}