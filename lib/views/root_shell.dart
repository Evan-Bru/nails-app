import 'package:flutter/material.dart';

import 'package:esmalte/views/agenda/agenda_screen.dart';
import 'package:esmalte/views/clients/client_list_screen.dart';
import 'package:esmalte/views/home/home_screen.dart';
import 'package:esmalte/views/services/service_list_screen.dart';

/// Estrutura de navegação por abas. Cada troca de aba cria uma instância
/// nova da tela (em vez de um IndexedStack que mantém tudo montado) para
/// garantir que os dados exibidos estejam sempre atualizados — importante
/// aqui porque um agendamento criado na Agenda deve refletir na Início
/// assim que o usuário trocar de aba.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 1; // abre direto na Agenda, tela de trabalho principal

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const AgendaScreen();
      case 2:
        return const ClientListScreen();
      case 3:
        return const ServiceListScreen();
      default:
        return const AgendaScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildScreen(_index),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Agenda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Clientes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.spa_outlined),
            activeIcon: Icon(Icons.spa),
            label: 'Serviços',
          ),
        ],
      ),
    );
  }
}
