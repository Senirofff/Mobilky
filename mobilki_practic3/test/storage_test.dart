import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rally_stage_analyzer/cubits/stages_cubit.dart';
import 'package:rally_stage_analyzer/models/rally_stage.dart';
import 'package:rally_stage_analyzer/services/stage_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Создание, изменение, перезапуск и удаление участков', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = StageStorageService(await SharedPreferences.getInstance());
    final cubit = StagesCubit(storage);
    const stage = RallyStage(
      id: '1',
      name: 'Лесной',
      latitude: 55,
      longitude: 37,
    );
    await cubit.put(stage);
    expect(storage.load().single.name, 'Лесной');
    await cubit.put(
      const RallyStage(id: '1', name: 'Горный', latitude: -90, longitude: 180),
    );
    final restarted = StagesCubit(storage);
    expect(restarted.state.single.name, 'Горный');
    await restarted.remove('1');
    expect(storage.load(), isEmpty);
    await cubit.close();
    await restarted.close();
  });
  test('Повреждённое хранилище не вызывает падения', () async {
    SharedPreferences.setMockInitialValues({'rally_stages': 'bad'});
    final cubit = StagesCubit(
      StageStorageService(await SharedPreferences.getInstance()),
    );
    expect(cubit.state, isEmpty);
    expect(cubit.loadError, isNotNull);
    await cubit.close();
  });
}
