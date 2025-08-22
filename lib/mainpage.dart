import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.user, this.userData});
  final Map<String, dynamic>? userData;
  final User user;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> /*with TickerProviderStateMixin<MainPage>*/ {
  final mainpagebackgroundcolor = Colors.black;
  final selectedItemColor = Colors.white;
  final iconTheme = IconThemeData(color: Colors.white);
  final bottomnavigatorTextStyle = TextStyle(color: Colors.white);
  SvgPicture scheduleIcon = SvgPicture.asset("assets/calendar-days-regular-full.svg", width: 50, height: 50,);
  SvgPicture accountIcon = SvgPicture.asset("assets/user-regular-full.svg", width: 50, height: 50,);
  SvgPicture homeIcon = SvgPicture.asset("assets/house-solid-full.svg", width: 50, height: 50,);
  int _selectedIndex = 0;
  List<Widget> get _navBarWidgets => <Widget>[HomePage(user: widget.user, userData: widget.userData,), SchedulePage(user: widget.user), AccountPage(user: widget.user)];
  
  void _onTapBottomNavbar(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1) {
        scheduleIcon = SvgPicture.asset("assets/calendar-days-solid-full.svg", width: 50, height: 50,);
        homeIcon = SvgPicture.asset("assets/house-regular-full.svg", width: 50, height: 50,);
        accountIcon = SvgPicture.asset("assets/user-regular-full.svg", width: 50, height: 50,);
      }
      else if (index == 2){
        scheduleIcon = SvgPicture.asset("assets/calendar-days-regular-full.svg", width: 50, height: 50,);
        homeIcon = SvgPicture.asset("assets/house-regular-full.svg", width: 50, height: 50,);
        accountIcon = SvgPicture.asset("assets/user-solid-full.svg", width: 50, height: 50,);
      }
      else {
        scheduleIcon = SvgPicture.asset("assets/calendar-days-regular-full.svg", width: 50, height: 50,);
        homeIcon = SvgPicture.asset("assets/house-solid-full.svg", width: 50, height: 50,);
        accountIcon = SvgPicture.asset("assets/user-regular-full.svg", width: 50, height: 50,);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainpagebackgroundcolor,
      bottomNavigationBar: BottomNavigationBar(
        selectedFontSize: 18,
        currentIndex: _selectedIndex,
        backgroundColor: Colors.black,
        unselectedIconTheme: iconTheme,
        unselectedLabelStyle: bottomnavigatorTextStyle,
        selectedLabelStyle: bottomnavigatorTextStyle,
        selectedItemColor: selectedItemColor,
        unselectedItemColor: Colors.white,
        showUnselectedLabels: true,
        iconSize: 50,
        onTap: _onTapBottomNavbar,
        items: [
          BottomNavigationBarItem(icon: homeIcon, label: "Início"), 
          BottomNavigationBarItem(icon: scheduleIcon, label: "Agendamentos"),
          BottomNavigationBarItem(icon: accountIcon, label: "Conta"),
        ],
        ),
      body: _navBarWidgets.elementAt(_selectedIndex)
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.user, required this.userData});
  final Map<String, dynamic>? userData;
  final User user;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    
    return Column(
      children: [
        Padding(padding: EdgeInsetsGeometry.only(top: 20, left: 20, right: 20), 
        child: Row(
          children: [
            FittedBox(child: Text("Seja Bem-Vindo(a),\n${widget.userData?['Name']} ${widget.userData?['Surname']}", style: TextStyle(color: Colors.white, fontSize: 40))),
            

          ],
          ),
        ),

        Row(children: [
          Expanded(child: Padding(padding: EdgeInsetsGeometry.only(top: 520, left: 20, right: 20), 
            child: Text("Primeira vez?\nSolicite o agendamento agora!", style: TextStyle(color: Colors.white, fontSize: 25)),
            )
          )
          ],
        ),

        Row(children: [
          Expanded(child:
            Padding(padding: EdgeInsetsGeometry.symmetric(horizontal: 20), 
              child: TextButton(onPressed: null,
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
  const SchedulePage({super.key, required this.user});
  final User user;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class AccountPage extends StatefulWidget {
  const AccountPage({super.key, required this.user});
  final User user;

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