import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:healthapp/models/form_fields_model.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, this.userData});
  final Map<String, dynamic>? userData;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> /*with TickerProviderStateMixin<MainPage>*/ {
  final bottomNavBarColor = Colors.grey.withValues(alpha: 0.2);
  final backgroundScaffoldColor = Colors.white.withValues(alpha: 0);
  final selectedItemColor = Colors.cyan.withValues(alpha: 0.8);
  final double iconSize = 60;
  SvgPicture scheduleIcon = SvgPicture.asset("assets/calendar-days-regular-full.svg", width: 60, height: 60);
  SvgPicture accountIcon = SvgPicture.asset("assets/user-regular-full.svg", width: 60, height: 60);
  SvgPicture homeIcon = SvgPicture.asset("assets/house-regular-full.svg", width: 60, height: 60);
  SvgPicture selectedhomeIcon = SvgPicture.asset("assets/house-solid-full.svg", width: 60, height: 60);
  SvgPicture selectedscheduleIcon = SvgPicture.asset("assets/calendar-days-solid-full.svg", width: 60, height: 60);
  SvgPicture selectedaccountIcon = SvgPicture.asset("assets/user-solid-full.svg", width: 60, height: 60);
  int _selectedIndex = 0;
  List<Widget> get _navBarWidgets => <Widget>[HomePage(userData: widget.userData), SchedulePage(), AccountPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundScaffoldColor,
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          padding: EdgeInsets.all(10),
          height: 60,
          decoration: BoxDecoration(
            color: bottomNavBarColor,
            borderRadius: BorderRadius.circular(25),

          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
                Expanded(child: Container(margin: EdgeInsets.all(0), decoration: BoxDecoration(color: _selectedIndex == 0 ? selectedItemColor : null, borderRadius: BorderRadius.circular(25)), child: IconButton(isSelected: _selectedIndex == 0 ? true : false, onPressed: () { setState(() { _selectedIndex = 0; });}, icon: homeIcon, selectedIcon: selectedhomeIcon,)),),
                Expanded(child: Container(margin: EdgeInsets.all(0), decoration: BoxDecoration(color: _selectedIndex == 1 ? selectedItemColor : null, borderRadius: BorderRadius.circular(25)), child: IconButton(isSelected: _selectedIndex == 1 ? true : false, onPressed: () { setState(() { _selectedIndex = 1; });}, icon: scheduleIcon, selectedIcon: selectedscheduleIcon,)),),
                Expanded(child: Container(margin: EdgeInsets.all(0), decoration: BoxDecoration(color: _selectedIndex == 2 ? selectedItemColor : null, borderRadius: BorderRadius.circular(25)), child: IconButton(isSelected: _selectedIndex == 2 ? true : false, onPressed: () { setState(() { _selectedIndex = 2; });}, icon: accountIcon, selectedIcon: selectedaccountIcon,)),),
            ]
              ),
          )
        ),
      body: _navBarWidgets[_selectedIndex],
      );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.userData});
  final Map<String, dynamic>? userData;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //TODO: Schedule page / account page
  //TODO: redesign

  void isFormAnswered() {
    if (widget.userData!['isformAnswered'] == false) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration: Duration(seconds: 2), behavior: SnackBarBehavior.floating, showCloseIcon: true, content: Text("Primeiro preencha o formulário!", style: TextStyle(color: Colors.black), textScaler: TextScaler.linear(1.2),), backgroundColor: Colors.yellow));
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => FormPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(padding: EdgeInsetsGeometry.only(top: 20, left: 20, right: 20), 
        child: Row(
          children: [
            FittedBox(child: Text("Seja Bem-Vindo(a),\n${widget.userData!['Name']} ${widget.userData!['Surname']}\n${widget.userData!['Account_Type']}", style: TextStyle(color: Colors.white, fontSize: 40))),

          ],
          ),
        ),

        Row(children: [
          Expanded(child: Padding(padding: EdgeInsetsGeometry.only(top: 470, left: 20, right: 20), 
            child: Text("Primeira vez?\nSolicite o agendamento agora!", style: TextStyle(color: Colors.white, fontSize: 25)),
            )
          )
          ],
        ),

        Row(children: [
          Expanded(child:
            Padding(padding: EdgeInsetsGeometry.symmetric(horizontal: 20), 
              child: TextButton(onPressed: () async { 
                  isFormAnswered();
                },
                style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.white)), 
                child: Text("Solicitar Agendamento!", style: TextStyle(color: Colors.black), textScaler: TextScaler.linear(1.4),))
            ),
          )  
          ],
        )

        
      ],
    );
  }
}

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {

  void signOut() {
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsetsGeometry.all(100), child: FloatingActionButton.large(onPressed: signOut, child: Text("Sign Out")));
  }
}

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  Color appbarColor = Colors.black;
  Color backgroundColor = Color.fromRGBO(172, 180, 180, 100);
  Color appbarForegroundColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Formulário"), backgroundColor: appbarColor, foregroundColor: appbarForegroundColor,),
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
              
            ]
          ,
        ),
      )
    );
  }
}