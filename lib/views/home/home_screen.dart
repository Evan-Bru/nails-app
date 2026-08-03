import 'package:flutter/material.dart';

import 'package:esmalte/core/di/service_locator.dart';
import 'package:esmalte/core/theme/app_colors.dart';
import 'package:esmalte/core/utils/formatters.dart';
import 'package:esmalte/models/appointment_details.dart';
import 'package:esmalte/presenters/home_presenter.dart';
import 'package:esmalte/views/appointment_form/appointment_form_screen.dart';
import 'package:esmalte/widgets/app_card.dart';
import 'package:esmalte/widgets/stat_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> implements HomeView {
  late final HomePresenter _presenter;

  int _appointmentsToday = 0;
  double _expectedRevenueToday = 0;
  int _totalClients = 0;
  List<AppointmentDetails> _upcomingToday = [];
  String _greetingDate = '';

  @override
  void initState() {
    super.initState();
    _presenter = HomePresenterImpl(
      clientRepository: ServiceLocator.instance.clientRepository,
      serviceRepository: ServiceLocator.instance.serviceRepository,
      appointmentRepository: ServiceLocator.instance.appointmentRepository,
    );
    _presenter.attachView(this);
    _presenter.loadSummary();
  }

  @override
  void dispose() {
    _presenter.detachView();
    super.dispose();
  }

  @override
  void showSummary({
    required int appointmentsToday,
    required double expectedRevenueToday,
    required int totalClients,
    required List<AppointmentDetails> upcomingToday,
    required String greetingDate,
  }) {
    setState(() {
      _appointmentsToday = appointmentsToday;
      _expectedRevenueToday = expectedRevenueToday;
      _totalClients = totalClients;
      _upcomingToday = upcomingToday;
      _greetingDate = greetingDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Esmalte')),
      body: RefreshIndicator(
        onRefresh: () async => _presenter.loadSummary(),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(_greetingDate, style: textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text('Como está o seu dia?', style: textTheme.displaySmall),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 340;
                final cards = [
                  StatCard(
                    label: 'Hoje',
                    value: '$_appointmentsToday',
                    suffix: _appointmentsToday == 1
                        ? 'agendamento'
                        : 'agendamentos',
                  ),
                  StatCard(
                    label: 'Previsto hoje',
                    value: AppFormatters.currency(_expectedRevenueToday),
                    suffix: '',
                  ),
                ];

                if (isNarrow) {
                  return Column(
                    children: [
                      cards[0],
                      const SizedBox(height: 12),
                      cards[1],
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: cards[0]),
                    const SizedBox(width: 12),
                    Expanded(child: cards[1]),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            StatCard(
              label: 'Base de clientes',
              value: '$_totalClients',
              suffix: _totalClients == 1
                  ? 'cliente cadastrada'
                  : 'clientes cadastradas',
            ),
            const SizedBox(height: 28),
            Text('Próximos horários de hoje', style: textTheme.titleSmall),
            const SizedBox(height: 12),
            if (_upcomingToday.isEmpty)
              const AppCard(child: Text('Nenhum horário restante para hoje.'))
            else
              ..._upcomingToday.map((a) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _UpcomingCard(
                      details: a,
                      onTap: () async {
                        await Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => AppointmentFormScreen(
                              appointmentId: a.appointment.id),
                        ));
                        _presenter.loadSummary();
                      },
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  const _UpcomingCard({required this.details, required this.onTap});

  final AppointmentDetails details;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = details.service?.color ?? AppColors.primary;

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  details.clientName,
                  style: textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  details.serviceName,
                  style: textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(AppFormatters.time(details.start), style: textTheme.titleMedium),
        ],
      ),
    );
  }
}
