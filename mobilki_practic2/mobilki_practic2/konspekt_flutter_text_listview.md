# Конспект лекции
## «Работа с текстом в Flutter. TextEditingController и ListView»

Лекция состоит из двух частей:
1. **TextEditingController** — управление текстом в полях ввода.
2. **ListView** — отображение данных в виде прокручиваемого списка.

---

## 1. TextEditingController

**TextEditingController** — класс, который управляет текстом в `TextField` (поле для ввода данных) и других виджетах. Он позволяет:

- **получать** текущее значение текста;
- **изменять** текст программно;
- **реагировать на изменения** текста с помощью слушателей (listeners).

### 1.1. Создание и привязка к полю

Чтобы использовать контроллер, нужно создать его экземпляр:

```dart
final TextEditingController _controller = TextEditingController();
```

Чтобы связать контроллер с текстовым полем, передаём его в параметр `controller` виджета `TextField`:

```dart
TextField(
  controller: _controller,
  decoration: InputDecoration(hintText: "Введите текст заметки"),
),
```

### 1.2. Чтение и изменение текста

**Получить** текущее значение текста из контроллера можно через свойство `text` — например, при нажатии кнопки:

```dart
ElevatedButton(
  onPressed: () {
    String inputValue = _controller.text;
    // Используйте inputValue по вашему усмотрению
  },
  child: Text('Отправить'),
),
```

**Изменить** текст в `TextField` можно, установив новое значение в контроллер:

```dart
_controller.text = 'Новое значение';
```

### 1.3. Слушатели изменений

Чтобы отслеживать изменения текста и выполнять действия при каждом изменении, добавляют слушателя:

```dart
_controller.addListener(() {
  print('Текущий текст: ${_controller.text}');
});
```

### 1.4. Освобождение ресурсов (обязательно!)

Когда контроллер/слушатель больше не нужны, их нужно удалить, чтобы **избежать утечек памяти**:

```dart
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}
```

---

## 2. Пример работы 1 — «очистка текста»

StatefulWidget с полем ввода, кнопкой очистки и выводом введённого текста на экран.

**Ключевая логика State-класса:**

```dart
class _FirstExampleWidgetState extends State<FirstExampleWidget> {
  final TextEditingController _controller = TextEditingController();
  String _displayText = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateDisplayText);   // подписка на изменения
  }

  @override
  void dispose() {
    _controller.removeListener(_updateDisplayText); // отписка
    _controller.dispose();                          // освобождение
    super.dispose();
  }

  void _updateDisplayText() {
    setState(() {
      _displayText = _controller.text; // при каждом вводе обновляем состояние
    });
  }

  void _clearText() {
    _controller.clear(); // программная очистка поля
  }
  ...
}
```

**Интерфейс (build):**

```dart
@override
Widget build(BuildContext context) {
  return Column(
    children: [
      TextField(
        controller: _controller,
        decoration: InputDecoration(hintText: 'введите текст'),
      ),
      ElevatedButton(
        onPressed: _clearText,
        child: Text('очистить текст'),
      ),
      Text('тут то что вы ввели: $_displayText'),
    ],
  );
}
```

**Результат:** при вводе текста (например, «риба») он сразу отображается под кнопкой; кнопка «очистить текст» очищает поле.

**Полный код примера:**

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(FirstExample());
}

class FirstExample extends StatelessWidget {
  const FirstExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('очистка текста')),
        body: FirstExampleWidget(),
      ),
    );
  }
}

class FirstExampleWidget extends StatefulWidget {
  const FirstExampleWidget({super.key});

  @override
  _FirstExampleWidgetState createState() => _FirstExampleWidgetState();
}

class _FirstExampleWidgetState extends State<FirstExampleWidget> {
  final TextEditingController _controller = TextEditingController();
  String _displayText = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateDisplayText);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateDisplayText);
    _controller.dispose();
    super.dispose();
  }

  void _updateDisplayText() {
    setState(() {
      _displayText = _controller.text;
    });
  }

  void _clearText() {
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(hintText: 'введите текст'),
        ),
        ElevatedButton(
          onPressed: _clearText,
          child: Text('очистить текст'),
        ),
        Text('тут то что вы ввели: $_displayText'),
      ],
    );
  }
}
```

---

## 3. Пример работы 2 — «показ текста» (SnackBar)

Структура та же (StatefulWidget + контроллер + слушатель), но вместо очистки кнопка **показывает введённый текст во всплывающем SnackBar**:

```dart
void _showText() {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('текст: $_displayText')),
  );
}
```

**Интерфейс (build):**

```dart
@override
Widget build(BuildContext context) {
  return Column(
    children: [
      TextField(
        controller: _controller,
        decoration: InputDecoration(hintText: 'введите текст'),
      ),
      ElevatedButton(
        onPressed: _showText,
        child: Text('показать текст'),
      ),
      Text('текущий текст: $_displayText'),
    ],
  );
}
```

**Результат:** при вводе «риба» текст дублируется под кнопкой, а по нажатию «показать текст» снизу появляется SnackBar «текст: риба».

> **Общий вывод из примеров 1 и 2:** жизненный цикл работы с контроллером —
> создать → привязать к `TextField` → подписаться в `initState` → работать через `text` / `clear()` → отписаться и вызвать `dispose()` в `dispose`.

---

## 4. ListView и ключи

**ListView** — элемент интерфейса, который показывает данные в виде прокручиваемого вертикального списка или таблицы.

**Основные параметры (ключи):**

| Параметр | Описание |
|---|---|
| `children` | объект `List<Widget>` — список виджетов, добавляемых в ListView |
| `scrollDirection` | направление элементов; перечисление `Axis` с двумя константами: `Axis.horizontal` — горизонтальный список (слева направо / справа налево); `Axis.vertical` — вертикальный список (сверху вниз) |
| `padding` | отступы элементов от границ ListView; объект `EdgeInsetsGeometry` |
| `reverse` | если `true`, располагает элементы в обратном порядке |
| `physics` | параметры скроллинга через объект `ScrollPhysics` |
| `controller` | управление прокруткой и прослушивание положения прокрутки |

---

## 5. Статический ListView

Все элементы заранее известны и перечисляются вручную в `children`:

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(StaticListViewApp());
}

class StaticListViewApp extends StatelessWidget {
  const StaticListViewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('статический ListView')),
        body: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            ListTile(title: Text('Элемент 1')),
            ListTile(title: Text('Элемент 2')),
            ListTile(title: Text('Элемент 3')),
            ListTile(title: Text('Элемент 4')),
            ListTile(title: Text('Элемент 5')),
          ],
        ),
      ),
    );
  }
}
```

Подходит для небольшого фиксированного числа элементов.

---

## 6. Динамический ListView

Элементы создаются «на лету» через конструктор **`ListView.builder`** — по индексу. Данные генерируются списком из 20 строк:

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(DynamicListViewApp());
}

class DynamicListViewApp extends StatelessWidget {
  const DynamicListViewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('динамический ListView')),
        body: DynamicListView(),
      ),
    );
  }
}

class DynamicListView extends StatelessWidget {
  final List<String> items =
      List.generate(20, (index) => 'элемент ${index + 1}');

  DynamicListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16.0),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ListTile(title: Text(items[index]));
      },
    );
  }
}
```

Ключевые параметры `ListView.builder`:
- `itemCount` — количество элементов (`items.length`);
- `itemBuilder` — функция `(context, index)`, возвращающая виджет для каждого индекса.

Подходит для больших/динамических списков: виджеты строятся только для видимой области, а не все сразу.

---

## Итоги лекции (кратко)

1. `TextEditingController` — связующее звено между кодом и `TextField`: чтение (`text`), запись (`text = ...`, `clear()`), подписка на изменения (`addListener`).
2. Слушателей нужно снимать (`removeListener`), а контроллер уничтожать (`dispose`) в методе `dispose()` — иначе утечки памяти.
3. Изменения текста попадают в UI через `setState` внутри колбэка-слушателя.
4. `ListView` — прокручиваемый список; настраивается через `children`, `scrollDirection`, `padding`, `reverse`, `physics`, `controller`.
5. Статический список — `ListView(children: [...])`; динамический (для больших данных) — `ListView.builder(itemCount, itemBuilder)`.
