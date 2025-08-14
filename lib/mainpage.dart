import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final registerpagebackgroundcolor = Colors.black;
  final selectedItemColor = Colors.white;
  final iconTheme = IconThemeData(color: Colors.white);
  final bottomnavigatorTextStyle = TextStyle(color: Colors.white);
  SvgPicture scheduleIcon = SvgPicture.asset("assets/calendar-days-regular-full.svg", width: 50, height: 50,);
  SvgPicture accountIcon = SvgPicture.asset("assets/user-regular-full.svg", width: 50, height: 50,);
  SvgPicture homeIcon = SvgPicture.asset("assets/house-solid-full.svg", width: 50, height: 50,);
  int _selectedIndex = 0;
  static const List<Widget> _navBarWidgets = <Widget>[ HomePage(),  SchedulePage(), AccountPage()];

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
      backgroundColor: registerpagebackgroundcolor,
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

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(padding: EdgeInsetsGeometry.only(top: 20, left: 20, right: 20), 
        child: Row(
          children: [
            Text("Seja Bem-Vindo,\nNome", style: TextStyle(color: Colors.white), textScaler: TextScaler.linear(3)),
          ],
          ),
        ),

        Row(children: [
          Expanded(child: Padding(padding: EdgeInsetsGeometry.only(top: 500, left: 20, right: 20), 
            child: Text("Primeira vez?\nSolicite o agendamento agora!", style: TextStyle(color: Colors.white), textScaler: TextScaler.linear(1.9),),
            )
          )
          ],
        ),

        Row(children: [
          Expanded(child:
            Padding(padding: EdgeInsetsGeometry.symmetric(horizontal: 20), 
              child: TextButton(onPressed: null, 
                style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.white)), 
                child: Text("Solicitar Agendamento!", style: TextStyle(color: Colors.black), textScaler: TextScaler.linear(1.5),))
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

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}