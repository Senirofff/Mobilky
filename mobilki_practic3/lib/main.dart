import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'cubits/stages_cubit.dart';
import 'cubits/weather_cubit.dart';
import 'di.dart';
import 'models/rally_stage.dart';
import 'screens/stages_screen.dart';
import 'screens/analysis_screen.dart';
import 'screens/comparison_screen.dart';
import 'screens/start_planner_screen.dart';
import 'services/stage_storage_service.dart';
import 'services/weather_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await configureDependencies();
    runApp(const RallyApp());
  } catch (_) {
    runApp(
      MaterialApp(
        theme: rallyTheme(),
        home: const Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Не удалось открыть локальное хранилище. Перезапустите приложение.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

ThemeData rallyTheme() {
  final colors = ColorScheme.fromSeed(
    seedColor: const Color(0xffff4856),
    brightness: Brightness.dark,
    primary: const Color(0xffff555f),
    surface: const Color(0xff191c23),
  );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colors,
    scaffoldBackgroundColor: const Color(0xff0e1015),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xff0e1015),
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleSpacing: 16,
      titleTextStyle: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xff191c23),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xff191c23),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xffe83e4c),
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      height: 68,
      backgroundColor: Color(0xff171a20),
      indicatorColor: Color(0xff51232b),
    ),
  );
}

class RallyApp extends StatelessWidget {
  const RallyApp({super.key});
  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => StagesCubit(getIt<StageStorageService>())),
      BlocProvider(create: (_) => WeatherCubit(getIt<WeatherService>())),
    ],
    child: MaterialApp(
      title: 'Погодный штурман',
      debugShowCheckedModeBanner: false,
      theme: rallyTheme(),
      locale: const Locale('ru'),
      supportedLocales: const [Locale('ru')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const RallyHome(),
    ),
  );
}

class RallyHome extends StatefulWidget {
  const RallyHome({super.key});
  @override
  State<RallyHome> createState() => _RallyHomeState();
}

class _RallyHomeState extends State<RallyHome> {
  final activeTab = ValueNotifier<int>(0);
  String? selected;
  final pages = PageController();
  static const titles = ['Участки', 'Анализ', 'Сравнение', 'Старт'];

  void changeTab(int index) {
    if (!pages.hasClients) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      pages.jumpToPage(index);
    } else {
      pages.animateToPage(
        index,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void select(String? id) {
    setState(() => selected = id);
    if (id == null) {
      context.read<WeatherCubit>().clear();
      return;
    }
    context.read<WeatherCubit>().load(
      context.read<StagesCubit>().state.firstWhere((s) => s.id == id),
    );
  }

  @override
  void dispose() {
    activeTab.dispose();
    pages.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocListener<StagesCubit, List<RallyStage>>(
    listener: (context, stages) {
      if (selected != null) {
        final stage = stages.where((s) => s.id == selected).firstOrNull;
        if (stage == null) {
          select(null);
        } else {
          context.read<WeatherCubit>().load(stage);
        }
      }
    },
    child: ValueListenableBuilder<int>(
      valueListenable: activeTab,
      // This subtree is reused when only the navigation selection changes.
      child: SafeArea(
        child: BlocBuilder<StagesCubit, List<RallyStage>>(
          builder: (context, stages) => PageView(
            controller: pages,
            // There are only four tabs. Lay them out before the first swipe.
            allowImplicitScrolling: true,
            scrollCacheExtent: const ScrollCacheExtent.viewport(3),
            onPageChanged: (index) => activeTab.value = index,
            children: [
              _TabPage(
                index: 0,
                child: StagesScreen(
                  onAnalyze: (s) {
                    select(s.id);
                    changeTab(1);
                  },
                ),
              ),
              _TabPage(
                index: 1,
                child: AnalysisScreen(
                  stages: stages,
                  selected: selected,
                  onSelected: select,
                ),
              ),
              _TabPage(index: 2, child: ComparisonScreen(stages: stages)),
              _TabPage(index: 3, child: StartPlannerScreen(stages: stages)),
            ],
          ),
        ),
      ),
      builder: (context, tab, body) => Scaffold(
        appBar: AppBar(title: Text(titles[tab])),
        floatingActionButton: tab == 0
            ? FloatingActionButton.extended(
                onPressed: () => StagesScreen.editStage(context),
                icon: const Icon(Icons.add),
                label: const Text('Добавить участок'),
                backgroundColor: const Color(0xffe83e4c),
                foregroundColor: Colors.white,
              )
            : null,
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: changeTab,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.route_outlined),
              selectedIcon: Icon(Icons.route),
              label: 'Участки',
            ),
            NavigationDestination(
              icon: Icon(Icons.insights_outlined),
              selectedIcon: Icon(Icons.insights),
              label: 'Анализ',
            ),
            NavigationDestination(
              icon: Icon(Icons.compare_arrows),
              label: 'Сравнение',
            ),
            NavigationDestination(
              icon: Icon(Icons.flag_outlined),
              selectedIcon: Icon(Icons.flag),
              label: 'Старт',
            ),
          ],
        ),
        body: body,
      ),
    ),
  );
}

class _TabPage extends StatefulWidget {
  const _TabPage({required this.index, required this.child});
  final int index;
  final Widget child;
  @override
  State<_TabPage> createState() => _TabPageState();
}

class _TabPageState extends State<_TabPage> with AutomaticKeepAliveClientMixin {
  final scroll = ScrollController();
  @override
  bool get wantKeepAlive => true;
  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: LayoutBuilder(
          builder: (context, viewport) => SingleChildScrollView(
            controller: scroll,
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              widget.index == 0 ? 96 : 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.index == 0)
                  widget.child
                else
                  // Keep the footer below the first viewport, even on empty tabs.
                  ConstrainedBox(
                    constraints: BoxConstraints(minHeight: viewport.maxHeight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [widget.child],
                    ),
                  ),
                if (widget.index != 0)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Оценка погоды справочная и не гарантирует безопасность заезда.',
                      style: TextStyle(fontSize: 12, color: Colors.white54),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
