# Анализ проекта YealinkMeetingPlanner

**Дата:** 2026-09-05  
**Статус:** 🔴 Требуется рефакторинг  
**Оценка:** MVVM: 5/10 | SOLID: 4/10 | Clean Code: 5/10

---

## 📊 Сводная оценка

| Критерий | Оценка | Критических нарушений |
|----------|--------|----------------------|
| **MVVM** | 5/10 | 3 критических |
| **SOLID** | 4/10 | 9 нарушений SRP, 9 нарушений DIP |
| **Clean Code** | 5/10 | 5 опечаток, 2 файла мёртвого кода |

---

## 🔴 Критические нарушения

### 1. MVVM — View читает из `@Query` напрямую

**Файл:** `Conference/ConferenceRoomScreen.swift:14-15`

```swift
@Query(sort: \ConfDataModel.startDateTimeStamp, order: .forward)
private var conferences: [ConfDataModel]
```

**Проблема:** View использует `@Query` для чтения из SwiftData, минуя ViewModel. Создаётся **два источника правды**: `@Query` во View и `confDataItems` в ViewModel. Данные могут рассинхронизироваться.

**Решение:** Убрать `@Query` из View, использовать только данные из `viewModel.confDataItems`.

---

### 2. MVVM — Бизнес-логика во View

**Файл:** `Conference/ConferenceRoomScreen.swift:88-142`

View самостоятельно:
- Маппит `ConfDataModel` → `BusySlot`
- Определяет состояние текущей встречи (noRoom / occupied / free / noMeetings)
- Проверяет `conferences.isEmpty`

**Решение:** Перенести всю логику принятия решений в ViewModel. View должен получать только данные для отображения.

---

### 3. SOLID — SRP нарушен в каждом ViewModel

`ConferenceViewModel` (165 строк) имеет 6+ ответственностей:
1. API-запросы (`loadSchedule`, `refreshSchedule`)
2. SwiftData CRUD (`loadCachedData`, `saveData`, `clearData`)
3. Периодическое обновление через Timer
4. Определение текущей встречи (`currentMeeting`)
5. Маппинг данных из API в модель
6. Управление состоянием UI (`isLoading`, `errorMessage`)

---

### 4. SOLID — DIP нарушен: прямые зависимости

Все ViewModel зависят от конкретных классов:
- `ModelContext` (SwiftData)
- `KeychainManager` (синглтон)
- `UserDefaults` (глобальный синглтон)
- `AppState` (конкретный класс)

**Решение:** Создать протоколы-абстракции для каждого хранилища.

---

### 5. Clean Code — Опечатки в именах

| Опечатка | Правильно |
|----------|-----------|
| `ConferenseSheduler` | `ConferenceScheduler` |
| `WetherView` | `WeatherView` |
| `metting` (ассет) | `meeting` |
| `fioIniciator` | `organizerName` |

---

### 6. Clean Code — Мёртвый код

- `MockData.swift` — весь файл закомментирован
- `CodeNDecode.swift` — 249 строк `JSONAny`, не используется

---

## 📋 План исправлений

### Этап 1: Критические нарушения MVVM (1-2 дня)

- [ ] **1.1** Убрать `@Query` из `ConferenceRoomScreen`, использовать только `viewModel.confDataItems`
  - Файл: `Conference/ConferenceRoomScreen.swift`
  - Удалить строки 14-15, использовать данные из ViewModel

- [ ] **1.2** Заменить `@StateObject` на property для инжектированных ViewModel
  - Файл: `Conference/ConferenceRoomScreen.swift:17-23`
  - ViewModel уже передаётся из родителя, `@StateObject` избыточен

- [ ] **1.3** Добавить отмену Timer в Combine
  - Файлы: `Conference/ConferenceViewModel.swift:35-44`, `Header/HeaderViewModel.swift:31-36`
  - Добавить `cancel()` в `deinit` или хранение reference для `.sink`

- [ ] **1.4** Заменить `try!` на `try?` или `do-catch`
  - Файлы: `Conference/ConferenceRoomScreen.swift:150`, `Conference/SelectRoomView.swift:71`

---

### Этап 2: Перенос бизнес-логики в ViewModel (2-3 дня)

- [ ] **2.1** Добавить `currentMeetingDisplay` в `ConferenceViewModel`
  - Создать enum `MeetingDisplayState` (noRoom / occupied / free / noMeetings)
  - View получает только данные для отображения

- [ ] **2.2** Добавить `busySlots` в `ConferenceViewModel`
  - Маппинг `ConfDataModel` → `BusySlot` перенести в ViewModel
  - View получает готовый массив

- [ ] **2.3** Перенести форматирование дат из `WeatherForecastView` в `WeatherViewModel`
  - Метод `formatDate` перенести в ViewModel

- [ ] **2.4** Перенести маппинг иконок погоды в `WeatherViewModel`
  - View получает готовый `iconName`

---

### Этап 3: Рефакторинг по SOLID (3-5 дней)

- [ ] **3.1** Создать протоколы для хранилищ (DIP)
  - `KeychainService` — вместо прямого `KeychainManager`
  - `DataStorage` — вместо прямого `UserDefaults`
  - `ConferenceRepository` — вместо прямого `ModelContext`

- [ ] **3.2** Разделить `ConferenceViewModel` по SRP
  - `ConferenceDataFetcher` — API + кэширование
  - `ConferenceDatabaseService` — SwiftData CRUD
  - `ConferenceTimeCalculator` — логика определения текущей встречи

- [ ] **3.3** Заменить switch-логику на словари/протоколы (OCP)
  - `weatherIconName` → словарь `Dictionary<Int, String>`
  - `busyBlockColor` → расширение `ScheduleBlockTone` с computed property

---

### Этап 4: Clean Code (2-3 дня)

- [ ] **4.1** Исправить опечатки
  - `ConferenseSheduler` → `ConferenceScheduler`
  - `WetherView` → `WeatherView`
  - `metting` → `meeting`

- [ ] **4.2** Удалить мёртвый код
  - Удалить `MockData.swift`
  - Удалить неиспользуемый `JSONAny` из `CodeNDecode.swift`

- [ ] **4.3** Убрать дублирование
  - `timeToMinutes` → единый `TimeUtils`
  - `DateFormatter` → единый `DateFormatters` enum
  - `clearDataInternal` → generic-расширение `ModelContext`

- [ ] **4.4** Заменить магические числа на именованные константы
  - Создать `enum LayoutDimensions` для всех hardcoded значений

---

### Этап 5: Консолидация паттернов (1-2 дня)

- [ ] **5.1** Перевести все ViewModel на `@Observable` (Observation framework)
  - Убрать `ObservableObject` + `@Published` + Combine
  - Проект уже использует `@Observable` в `AppState` и `SettingsStore`

- [ ] **5.2** Добавить doc-comments для публичных API

---

## 🎯 Приоритет выполнения

```
Высокий приоритет (блок разработки):
├── Этап 1 → устраняет критические нарушения MVVM
└── Этап 3.1 → позволяет тестировать код

Средний приоритет (улучшение качества):
├── Этап 2 → возвращает правильную архитектуру MVVM
├── Этап 3.2-3.3 → улучшает поддерживаемость
└── Этап 4.1-4.3 → повышает читаемость

Низкий приоритет (косметика):
└── Этап 4.4-5.2 → улучшает консистентность
```

---

## 📁 Структура проекта

```
YealinkMeetingPlanner/
├── YealinkMeetingPlannerApp.swift       # Точка входа
├── AppState.swift                        # Глобальное состояние (@Observable)
├── Conference/                           # Главный экран конференции
│   ├── ConferenceRoomScreen.swift        # View (161 строка)
│   ├── ConferenceViewModel.swift         # ViewModel (165 строк)
│   ├── SelectRoomView.swift              # Выбор комнаты
│   └── SelectRoomViewModel.swift         # ViewModel выбора
├── HeaderView/                           # Заголовок с часами
├── CurrentMeetingView/                   # Карточка текущей встречи
├── ScheduleView/                         # Расписание занятости
├── WetherView/                           # Прогноз погоды (опечатка!)
├── ScanSecretKey/                        # QR-сканер для ключей API
├── Settings/                             # Настройки приложения
├── Model/                                # Бизнес-модели и DTO
│   ├── SwiftData/                        # Модели persistent-хранилища
│   ├── ConferenceSheduler.swift          # DTO расписания (опечатка!)
│   ├── WeatherModel.swift                # DTO погоды
│   └── CodeNDecode.swift                 # JSON-утилиты (249 строк мёртвого кода)
├── NetworkLayers/                        # Сетевой слой
│   ├── YmsApiResponse.swift              # YMS API клиент
│   ├── WeatherService.swift              # Weather API клиент
│   └── NetError.swift                    # Сетевые ошибки
├── LocalProperties/                      # Конфигурация
└── Helpers/                              # Вспомогательные утилиты
```

---

## 🔑 Ключевые рекомендации

1. **Начать с Этапа 1** — устраняет критические нарушения MVVM без изменения архитектуры
2. **Создать протоколы** для всех внешних зависимостей (хранилища, API)
3. **Перенести бизнес-логику** из View в ViewModel
4. **Удалить мёртвый код** — сразу повысит качество кодовой базы
5. **Консолидировать паттерны** — выбрать `@Observable` или `ObservableObject`

---

*Сгенерировано: 2026-09-05*
