import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:healthapp/main.dart';
import 'package:healthapp/models/form_questions.dart';
import 'package:healthapp/registerpage.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.userData});
  final Map<String, dynamic> userData;
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final bottomNavBarColor = Colors.grey.withValues(alpha: 0.2);
  final backgroundScaffoldColor = Color.fromRGBO(32, 32, 32, 1);
  final selectedItemColor = Colors.cyan.withValues(alpha: 0.8);
  final double iconSize = 60;
  SvgPicture scheduleIcon = SvgPicture.asset("assets/calendar-days-regular-full.svg");
  SvgPicture accountIcon = SvgPicture.asset("assets/user-regular-full.svg");
  SvgPicture homeIcon = SvgPicture.asset("assets/house-regular-full.svg");
  SvgPicture selectedhomeIcon = SvgPicture.asset("assets/house-solid-full.svg");
  SvgPicture selectedscheduleIcon = SvgPicture.asset("assets/calendar-days-solid-full.svg");
  SvgPicture selectedaccountIcon = SvgPicture.asset("assets/user-solid-full.svg");
  int _selectedIndex = 0;
  List<Widget> get _navBarWidgets => <Widget>[HomePage(userData: widget.userData), SchedulePage(), AccountPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundScaffoldColor,
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.all(10),
          height: 60,
          decoration: BoxDecoration(
            color: bottomNavBarColor,
          ),
          child: Theme(data: ThemeData(iconTheme: IconThemeData(size: 5), splashFactory: NoSplash.splashFactory, splashColor: Colors.transparent, highlightColor: Colors.transparent), 
            child: Row(mainAxisAlignment: MainAxisAlignment.center, 
              children: [
                Expanded(child: IconButton(splashColor: Colors.transparent, highlightColor: Colors.transparent, isSelected: _selectedIndex == 0 ? true : false, onPressed: () { setState(() { _selectedIndex = 0; });}, icon: homeIcon, selectedIcon: selectedhomeIcon,)),
                Expanded(child: IconButton(splashColor: Colors.transparent, highlightColor: Colors.transparent, isSelected: _selectedIndex == 1 ? true : false, onPressed: () { setState(() { _selectedIndex = 1; });}, icon: scheduleIcon, selectedIcon: selectedscheduleIcon,)),
                Expanded(child: IconButton(splashColor: Colors.transparent, highlightColor: Colors.transparent, isSelected: _selectedIndex == 2 ? true : false, onPressed: () { setState(() { _selectedIndex = 2; });}, icon: accountIcon, selectedIcon: selectedaccountIcon,)),
              ]
              )
            )
          )
        ),
      body: _navBarWidgets[_selectedIndex],
      );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.userData});
  final Map<String, dynamic> userData;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final headerTextStyle = TextStyle(color: Colors.white, fontSize: 30);
  
  void isFormAnswered() async {
    Map<String, dynamic>? userData = await getUserData(FirebaseAuth.instance.currentUser!);
    if (userData!['isformAnswered'] == false) {
      if(mounted) Navigator.of(context).push(MaterialPageRoute(builder: (context) => FormPage(userData: widget.userData)));
    }
    else {
      if(mounted) ScaffoldMessenger.of(context).clearSnackBars();
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration: Duration(seconds: 2), behavior: SnackBarBehavior.floating, showCloseIcon: true, content: Text("Formulário preenchido!", style: TextStyle(color: Colors.black), textScaler: TextScaler.linear(1.2),), backgroundColor: Colors.yellow));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(padding: EdgeInsetsGeometry.only(top: 37)),
          Center(child: avatarLogoImage(radius: 90, fontSize: 30, backgroundColor: Color.fromRGBO(71, 71, 71, 1))),
          Padding(padding: EdgeInsetsGeometry.only(bottom: 120)),
          SizedBox(
            width: MediaQuery.sizeOf(context).width - 40,
            height: MediaQuery.sizeOf(context).height - 455,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Seja bem-vindo(a),\n${widget.userData['Name']}", style: headerTextStyle.copyWith(fontSize: 42)),
              Spacer(flex: 1),
              Text("Primeira vez?", style: headerTextStyle),
              Text("Preencha o formulário agora!", style: headerTextStyle.copyWith(fontSize: 28)),
              SizedBox(width: MediaQuery.sizeOf(context).width - 40, 
                child: TextButton(style: ButtonStyle(shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(10))), backgroundColor: WidgetStatePropertyAll(Colors.white)), onPressed: isFormAnswered, child: Text("Preencher o formulário", style: TextStyle(color: Colors.black, fontSize: 20))),
              ),

            ],
            ),
          )
        ],
      ),
    );
  }
}

class SchedulePage extends StatelessWidget {
  //TODO: Schedule page
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class UpdatePage extends StatefulWidget {
  const UpdatePage({super.key, required this.type, required this.userData});
  final String type;
  final Map<String, dynamic> userData;
  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  final appbarColor = Colors.black;
  final backgroundScaffoldColor = Color.fromRGBO(32, 32, 32, 1);
  final _formkey = GlobalKey<FormState>();
  final formFieldColor = Color.fromRGBO(175, 175, 175, 0.21);
  final textStyle = TextStyle(color: Colors.white, fontSize: 22);
  final List<TextEditingController> _controllers = List.generate(7, (index) => TextEditingController());

  Widget customScaffold({Widget? appbartitle, Widget? body}) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: appbartitle, backgroundColor: appbarColor, foregroundColor: Colors.white, scrolledUnderElevation: 0,),
      backgroundColor: backgroundScaffoldColor,
      body: body,
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (var controller in _controllers) {
      controller.dispose();
    }
  }

  @override
  void initState() {
    super.initState();
    _controllers[0].text = widget.userData['Name'];
    _controllers[1].text = widget.userData['Surname'];
    _controllers[2].text = widget.userData['CPF'];
    _controllers[3].text = widget.userData['Phone'];
    _controllers[4].text = FirebaseAuth.instance.currentUser!.email!;

  }

  Widget customScaffoldBody({required int fieldCount, required List<int> controllers, required int type, required List<String> fieldsName}) {
    //TODO: merge one big form and submit only edited fields
    if (fieldCount == 1) {
      return Form(key: _formkey,
        child: Container(
          margin: EdgeInsets.all(40),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(fieldsName[0], style: textStyle),
              Padding(padding: EdgeInsetsGeometry.only(bottom: 20)),
              TextFormField(
                style: textStyle,
                controller: _controllers[controllers[0]],
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(width: 2, color: Colors.green)), 
                  filled: true, 
                  fillColor: formFieldColor, 
                  border: OutlineInputBorder(borderRadius: BorderRadius.zero)),
              ),
              Padding(padding: EdgeInsetsGeometry.only(bottom: 20)),
              Spacer(flex: 1),
              TextButton(
                onPressed: () {
                  if (_formkey.currentState!.validate()) {
                    updateData(type); 
                  }
                }, 
                style: ButtonStyle(
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(15))),
                  minimumSize: WidgetStatePropertyAll(Size(433, 36)),
                  backgroundColor: WidgetStatePropertyAll(Color.fromRGBO(0, 255, 0, 0.5)),
                ),
                child: Text("Atualizar", style: textStyle)
              ),

            ],
          ),
        )
      );
    }
    else if (fieldCount == 3) {
      return Form(key: _formkey,
        child: Container(
          margin: EdgeInsets.all(40),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(fieldsName[0], style: textStyle),
              Padding(padding: EdgeInsetsGeometry.only(bottom: 20)),
              TextFormField(
                style: textStyle,
                controller: _controllers[controllers[0]],
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(width: 2, color: Colors.green)), 
                  filled: true, 
                  fillColor: formFieldColor, 
                  border: OutlineInputBorder(borderRadius: BorderRadius.zero)),
              ),
              Padding(padding: EdgeInsetsGeometry.only(bottom: 20)),
              Text(fieldsName[1], style: textStyle),
              Padding(padding: EdgeInsetsGeometry.only(bottom: 20)),
              TextFormField(
                controller: _controllers[controllers[1]],
                style: textStyle,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(width: 2, color: Colors.green)), 
                  filled: true, 
                  fillColor: formFieldColor, 
                  border: OutlineInputBorder(borderRadius: BorderRadius.zero)),
              ),
              Spacer(flex: 1),
              TextButton(
                onPressed: () {
                  if (_formkey.currentState!.validate()) {
                    updateData(type); 
                  }
                },  
                style: ButtonStyle(
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(15))),
                  minimumSize: WidgetStatePropertyAll(Size(433, 36)),
                  backgroundColor: WidgetStatePropertyAll(Color.fromRGBO(0, 255, 0, 0.5)),
                ),
                child: Text("Atualizar", style: textStyle)
              ),

            ],
          ),
        )
      );
    }
    return Form(key: _formkey,
      child: Container(
        margin: EdgeInsets.all(40),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(fieldsName[0], style: textStyle),
            Padding(padding: EdgeInsetsGeometry.only(bottom: 20)),
            TextFormField(
              style: textStyle,
              controller: _controllers[controllers[0]],
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(width: 2, color: Colors.green)), 
                filled: true, 
                fillColor: formFieldColor, 
                border: OutlineInputBorder(borderRadius: BorderRadius.zero)),
            ),
            Padding(padding: EdgeInsetsGeometry.only(bottom: 20)),
            Text(fieldsName[1], style: textStyle),
            Padding(padding: EdgeInsetsGeometry.only(bottom: 20)),
            TextFormField(
              controller: _controllers[controllers[1]],
              style: textStyle,
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(width: 2, color: Colors.green)), 
                filled: true, 
                fillColor: formFieldColor, 
                border: OutlineInputBorder(borderRadius: BorderRadius.zero)),
            ),
            Spacer(flex: 1),
            TextButton(
              onPressed: () {
                if (_formkey.currentState!.validate()) {
                  updateData(type); 
                }
              }, 
              style: ButtonStyle(
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(15))),
                minimumSize: WidgetStatePropertyAll(Size(433, 36)),
                backgroundColor: WidgetStatePropertyAll(Color.fromRGBO(0, 255, 0, 0.5)),
              ),
              child: Text("Atualizar", style: textStyle)
            ),

          ],
        ),
      )
    );
  }

  //handle user input form edit option
  void updateData(int option) async {
    User user = FirebaseAuth.instance.currentUser!;
    Map<String, dynamic> data = {};
    switch (option) {
      case 0:
        data['Name'] = _controllers[0].text;
        data['Surname'] = _controllers[1].text;
        break;
      case 1:
        data['CPF'] = _controllers[2].text;
        break;
      case 2:
        data['Phone'] = _controllers[3].text;
        break;
      case 3:
        try { 
          await user.updatePassword(_controllers[5].text);
          if(mounted) notifyMessenger(context: context, msg: "Dados atualizados com sucesso!", colortext: Colors.white, colorbar: Colors.green);
          return;
        } on FirebaseAuthException catch (e) {
          switch (e.code) {
            case 'weak-password':
              if(mounted) notifyMessenger(context: context, msg: 'Nova senha fraca demais', colortext: Colors.white, colorbar: Colors.red);
              break;
            default:
              if(mounted) notifyMessenger(context: context, msg: "Houve um erro ao atualizar", colortext: Colors.white, colorbar: Colors.red);
              break;
          }
          return;
        }
    }
    try {
      FirebaseFirestore.instance.collection('users').doc(user.uid).update(data);
      if(mounted) notifyMessenger(context: context, msg: "Dados atualizados com sucesso!", colortext: Colors.white, colorbar: Colors.green);
    } catch (e) {
      debugPrint("[updateData method error: ${e.toString()}]");
    }
    
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.type) {
      case 'name-surname':
        return customScaffold(
          appbartitle: Text("Alterar nome e sobrenome"), 
          body: customScaffoldBody(fieldCount: 2, controllers: [0, 1], type: 0, fieldsName: ['Nome', 'Sobrenome'])
        );
      case 'cpf':
        return customScaffold(
          appbartitle: Text("Alterar CPF"), 
          body: customScaffoldBody(fieldCount: 1, controllers: [2], type: 1, fieldsName: ['CPF'])
        );
      case 'phone-mail':
        return customScaffold(
          appbartitle: Text("Alterar celular e email"), 
          body: customScaffoldBody(fieldCount: 2, controllers: [3, 4], type: 2, fieldsName: ['Celular', 'Email'])
        );
      case 'password':
        return customScaffold(
          appbartitle: Text("Alterar senha"), 
          body: customScaffoldBody(fieldCount: 3, controllers: [5, 6], type: 3, fieldsName: ['Nova senha', 'Confirmar nova senha'])
        );
      default:
        return customScaffold(
          appbartitle: Text("Atualização cadastral"), 
          body: null
        );
    }
  }
}

class UpdateUserDataPage extends StatefulWidget {
  const UpdateUserDataPage({super.key});

  @override
  State<UpdateUserDataPage> createState() => _UpdateUserDataPageState();
}

class _UpdateUserDataPageState extends State<UpdateUserDataPage> {
  final appbarColor = Colors.black;
  final backgroundScaffoldColor = Color.fromRGBO(32, 32, 32, 1);
  TextStyle textstyle = TextStyle(color: Colors.white, fontSize: 20);
  final iconColor = Colors.white;
  double iconSize = 46;

  void updateData(String type) async {
    Map<String, dynamic>? userData = await getUserData(FirebaseAuth.instance.currentUser!);
    if(mounted) Navigator.of(context).push(MaterialPageRoute(builder: (context) => UpdatePage(userData: userData!, type: type)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("Atualização cadastral"), backgroundColor: appbarColor, foregroundColor: Colors.white, scrolledUnderElevation: 0,),
      backgroundColor: backgroundScaffoldColor,
      body: Container(
        margin: EdgeInsets.all(20),
        width: MediaQuery.sizeOf(context).width-40,
        child: Column(
          children: [
            Padding(padding: EdgeInsetsGeometry.only(top: 30)),
            ListTile(onTap: () { updateData('name-surname'); }, title: Text("Alterar nome e sobrenome", style: textstyle), trailing: Icon(Icons.keyboard_arrow_right, size: iconSize, color: iconColor)),
            ListTile(onTap: () { updateData('cpf'); }, title: Text("CPF", style: textstyle), trailing: Icon(Icons.keyboard_arrow_right, size: iconSize, color: iconColor)),
            ListTile(onTap: () { updateData('phone-mail'); }, title: Text("Celular e email", style: textstyle), trailing: Icon(Icons.keyboard_arrow_right, size: iconSize, color: iconColor)),
            ListTile(onTap: () { updateData('password'); }, title: Text("Senha", style: textstyle), trailing: Icon(Icons.keyboard_arrow_right, size: iconSize, color: iconColor)),
          ],
        ),
      )
    );
  }
}

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  TextStyle textstyle = TextStyle(color: Colors.white);
  Color iconColor = Colors.white;
  double iconSize = 36;
  SvgPicture trashIcon = SvgPicture.asset('assets/trash-solid-full.svg', width: 36, height: 36, colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn));
  SvgPicture editIcon = SvgPicture.asset('assets/edit-solid-full.svg', width: 36, height: 36, colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn));
  SvgPicture leaveIcon = SvgPicture.asset('assets/arrow-right-solid-full.svg', width: 36, height: 36, colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),);
  
  Future<bool?> showCustomDialog(BuildContext context, String title, Widget? content) {
    return showDialog<bool>(context: context, 
      builder: (context) {
        return AlertDialog(
          title: Text(title, style: textstyle),
          content: content,
          backgroundColor: Color.fromRGBO(12, 12, 12, 1),
          actions: <Widget>[
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: TextButton(
                  style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.white.withAlpha(175))),
                  onPressed: () { Navigator.of(context).pop(false); },
                  child: Text("Cancelar", style: textstyle),
                ),
                ),
                Expanded(child: TextButton(
                  style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Color.fromRGBO(255, 86, 86, 1))),
                  onPressed: () { Navigator.of(context).pop(true); }, 
                  child: Text("Confirmar", style: textstyle)
                )
                )
              ],
            )
          ],
        );
      }
    );
  }

  void signOut(BuildContext context) async {
    final bool? confirmation = await showCustomDialog(context, "Deseja sair de sua conta?", Padding(padding: EdgeInsets.only(bottom: 10)));
    if (confirmation == true) {
      FirebaseAuth.instance.signOut();
      if(context.mounted) Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void deleteAccount(BuildContext context) async {
    final bool? confirmation = await showCustomDialog(context, "Tem certeza que deseja excluir sua conta?", Text("Atenção: essa ação é irreversível", style: textstyle));
    if (confirmation == true) {
      User user = FirebaseAuth.instance.currentUser!;
      await FirebaseFirestore.instance.collection('form_answers').doc(user.uid).delete();
      await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
      await user.delete();
      if(context.mounted) Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: Column(
        children: [
          Padding(padding: EdgeInsetsGeometry.all(48)),
          avatarLogoImage(radius: 80, fontSize: 35, backgroundColor: Colors.white),
          Padding(padding: EdgeInsetsGeometry.only(bottom: 137)),
          SizedBox(
            width: MediaQuery.sizeOf(context).width*0.95,
            height: MediaQuery.sizeOf(context).height*0.2,
            child:  Column(
              children: [
                ListTile(onTap: () { Navigator.of(context).push(MaterialPageRoute(builder: (context) => UpdateUserDataPage())); }, leading: editIcon, title: Text("Atualizar dados cadastrais", style: textstyle), trailing: Icon(Icons.keyboard_arrow_right, size: iconSize, color: iconColor,),),
                ListTile(onTap: () { deleteAccount(context); }, leading: trashIcon, title: Text("Deletar conta", style: textstyle), trailing: Icon(Icons.keyboard_arrow_right, size: iconSize, color: iconColor,),),
                ListTile(onTap: () { signOut(context); }, leading: Transform.scale(scaleX: -1, child: leaveIcon), title: Text("Sair", style: textstyle),),

              ],
            ),

          ),
        ],
      )
    );
  }
}

class FormPage extends StatefulWidget {
  const FormPage({super.key, required this.userData});
  final Map<String, dynamic>? userData;
  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();
  Color appbarColor = Colors.black;
  Color backgroundColor = Color.fromRGBO(172, 180, 180, 100);
  Color appbarForegroundColor = Colors.white;
  late final formType = widget.userData!['Account_Type'];
  bool isLoading = false;
  late final numberFields = formFieldsItems[formType]!.length;
  bool isFormValid = false;
  late final List<TextEditingController> _controllers = List.generate(numberFields, (i) => TextEditingController());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<bool> sendFormAnswers() async {
    final db = FirebaseFirestore.instance;
    final uid = FirebaseAuth.instance.currentUser!.uid;
    Map<String, dynamic> data = {};
    for (var index = 0; index < _controllers.length; index++) {
      String question = formFieldsItems[formType]![index]['label'];
      final value = _controllers[index].text;
      final questionValue = <String, dynamic>{question: value};
      data.addAll(questionValue);
    }
    try {
      DocumentReference formAnswersDoc = db.collection('form_answers').doc(uid);
      await formAnswersDoc.set(data, SetOptions(merge: true));
      if(mounted) notifyMessenger(context: context, msg: 'Formulário enviado com sucesso!', colortext: Colors.white, colorbar: Colors.green);
      db.collection('users').doc(uid).update({'isformAnswered': true});
      return true;
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
    return false;
  }

  void isFormComplete() {
    if (_formKey.currentState!.validate()) {
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

  List<Widget> formBuilder({required String label, required controller, required inputType, required isRequired}) {
    return [Text(label), TextFormField(
        controller: controller,
        validator: (value) => formValidator(value: value, inputType: inputType, isRequired: isRequired),
        onChanged: (value) => { isFormComplete() },
        decoration: InputDecoration(
          filled: true,
          border: OutlineInputBorder(),
        ),
      )
    ];
    
  }

  void submitForm() async {
    setState(() {
      isLoading = true;
    });
    if (_formKey.currentState!.validate()) {
      if(await sendFormAnswers()) {
        await Future.delayed(Duration(seconds: 1));
        if (mounted) Navigator.of(context).pop();
      }
      else {
        if(mounted) notifyMessenger(context: context, msg: "Houve algum erro no envio do formulário", colortext: Colors.white, colorbar: Colors.red);
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  String? formValidator({required String? value, required String? inputType, required String isRequired}) {
    if (inputType == 'TextField' && (isRequired == 'true' && value!.isEmpty)) {
      return "Esse campo não pode estar vazio";
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Formulário ${widget.userData!['Account_Type']}"), backgroundColor: appbarColor, foregroundColor: appbarForegroundColor,),
      backgroundColor: backgroundColor,
      body: Form(key: _formKey, 
        child:
          Padding(padding: EdgeInsetsGeometry.all(10),
            child: ListView(children: [
              
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: numberFields,
                itemBuilder: ((context, index) {
                  final widgetinfo = formFieldsItems[formType]![index];
                  final widget = formBuilder(label: widgetinfo['label'], controller: _controllers[index], inputType: widgetinfo['inputType'], isRequired: widgetinfo['required']);
                  return Padding(padding: EdgeInsetsGeometry.only(bottom: 10),
                    child:
                      Column(spacing: 10, crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          widget[0], 
                          widget[1]
                        ],
                      ),
                  );
                })
              ),

              TextButton(style: ButtonStyle(backgroundColor: isFormValid ? WidgetStatePropertyAll(Colors.green) : WidgetStatePropertyAll(Colors.grey)), 
                onPressed: submitForm,
                child: isLoading ? const CircularProgressIndicator.adaptive() : Text("Enviar", style: TextStyle(color: Colors.black, fontSize: 20),)),

            ])
          ),
          ),


      );
  }
}