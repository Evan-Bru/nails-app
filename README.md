# Nails

App de agendamento para manicure, em Flutter, com arquitetura **MVP**
(Model–View–Presenter).

## Telas

- **Agenda** — visão semanal com colunas por dia e blocos de horário
  coloridos por serviço, inspirada na referência que você enviou (grade de
  calendário com faixas de horário à esquerda e agendamentos coloridos por
  categoria). Tocar num horário vazio abre um novo agendamento já com aquele
  dia/hora preenchidos; tocar num agendamento existente abre pra edição.
- **Clientes** — cadastro com busca, telefone, data de nascimento e
  observações (alergias, preferências), com histórico de agendamentos de
  cada cliente.
- **Serviços** — catálogo dos procedimentos oferecidos (nome, duração,
  preço, cor de identificação usada na Agenda).
- **Início** — resumo do dia: quantos agendamentos, receita prevista,
  total de clientes e os próximos horários.

O agendamento também checa conflito de horário automaticamente (não deixa
marcar dois atendimentos que se sobrepõem).

## Arquitetura

```
lib/
├── models/            Entidades (Client, Service, Appointment) — Dart puro
├── data/repositories/ Acesso a dados. Hoje em memória; a interface já está
│                       pronta para trocar por SQLite/API sem mexer no resto
├── presenters/         Lógica de negócio. Cada arquivo define:
│                         - o contrato da View (o que o Presenter pode pedir
│                           pra tela mostrar)
│                         - o contrato do Presenter (o que a tela pode pedir
│                           pro Presenter fazer)
│                         - a implementação
│                       Nenhum arquivo aqui importa o Flutter widgets —
│                       são testáveis sem rodar um app.
├── views/              Telas (StatefulWidget). Cada tela implementa a
│                       interface *View* do seu Presenter e só faz
│                       apresentação: sem regra de negócio.
├── widgets/             Componentes reutilizados entre telas
└── core/                Tema, injeção de dependência manual (ServiceLocator),
                          formatação de data/moeda
```

O fluxo típico numa tela (ex.: Agenda) é:

1. A View (`AgendaScreen`) cria o Presenter e chama `attachView(this)`.
2. A View chama um método do Presenter (`loadWeekContaining`, `goToNextWeek`...).
3. O Presenter busca dados nos repositórios, monta o resultado e chama um
   método da interface `AgendaView` (`showWeek(...)`).
4. A View implementa `showWeek` fazendo apenas `setState(...)`.

Isso mantém a lógica (cálculo de semana, checagem de conflito, formatação de
resumo) longe dos widgets — dá pra escrever teste de unidade pros Presenters
sem precisar de `WidgetTester`. Tem um exemplo disso em
`test/presenters/appointment_form_presenter_test.dart`, testando a checagem
de conflito de horário com uma View falsa (sem nenhum widget de verdade).
Rode com `flutter test`.

## Como rodar

Pré-requisitos: Flutter SDK (canal stable) instalado.

```bash
flutter pub get
flutter run
```

## Testes

```bash
flutter test
```

Como a lógica de negócio vive nos Presenters (sem Flutter widgets), os testes
rodam sem `WidgetTester`: uso uma *View* falsa que só grava o que o Presenter
mandou exibir. A suíte cobre os formatadores (`AppFormatters`), os modelos
(`copyWith`/`AppointmentDetails`) e os Presenters (agenda, resumo da Início,
lista de clientes e a checagem de conflito de horário do formulário).

## Limitações atuais / próximos passos

- **Sem persistência**: os dados vivem em memória (`InMemoryClientRepository`
  e afins) e resetam a cada abertura do app, com alguns dados de exemplo
  gerados na semana atual pra você ver a Agenda populada. Os repositórios já
  são interfaces (`ClientRepository`, `ServiceRepository`,
  `AppointmentRepository`) — trocar por SQLite (`sqflite` + `sqflite_common_ffi`
  se for rodar desktop) é o próximo passo natural, e os Presenters/Views não
  precisam mudar.
- **Uma manicure só**: não há conceito de múltiplos profissionais/salas.
- **Sem notificações** de lembrete pra cliente (WhatsApp, SMS, etc.).
- Dias de trabalho fixos em segunda–sábado — ajustável em
  `AgendaPresenterImpl._workingDaysCount` e no início/fim de expediente em
  `AgendaGridConfig` (`views/agenda/agenda_widgets.dart`).

Posso implementar qualquer um desses next steps — a persistência com SQLite
é provavelmente o mais valioso primeiro passo, já que hoje os dados somem ao
fechar o app.
