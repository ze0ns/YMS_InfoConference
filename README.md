# YMS_InfoConference

Планировщик конференц-залов для устройств Yealink на SwiftUI. Приложение
показывает расписание занятости зала, текущее собрание, прогноз погоды на
несколько дней и позволяет отсканировать QR-код, чтобы загрузить ключи API.

## Возможности

- Живое расписание зала с подсветкой идущего сейчас собрания
- Выбор зала из полученного списка доступных помещений
- Прогноз погоды для выбранного города (Open-Meteo)
- Сканирование QR-кода для загрузки `ylSecretKey` / `ylAccessKey` в Keychain
- Настройки под PIN-кодом
- Демо-режим, который генерирует синтетический день для предпросмотра
  интерфейса без сервера

## Архитектура

Приложение построено по MVVM, а SwiftUI-вью остаются тонкими. Все
ViewModel используют макрос `@Observable`; Combine и `ObservableObject`
полностью удалены.

Протоколы внедряются повсюду. `ConferenceRepository` и `RoomRepository`
стоят перед SwiftData. `YmsApiService` и `YmsApiClient` стоят перед слоем
HTTP. `DataStorage`, `KeychainService` и `APICredentialsProviding` можно
заглушить в тестах, поэтому вью и ViewModel не обращаются напрямую ни к
`ModelContext`, ни к `UserDefaults`, ни к Keychain.

`ConferenceScheduleStore` владеет расписанием, кешем и таймером обновления,
а `ConferenceViewModel` остаётся presentation-only. `ConferenceTimeCalculator`
содержит чистую логику отображения.

## Настройка

В `YealinkMeetingPlanner/LocalProperties/` лежат `Config.plist` (в gitignore)
и `Config.example.plist`. Скопируйте пример в `Config.plist` и укажите
`hostURL`.

Ключи API никогда не хранятся в plist. Отсканируйте QR в настройках, и
приложение сохранит их в Keychain.

## Сборка и тесты

```sh
xcodebuild -project YealinkMeetingPlanner.xcodeproj \
  -scheme YealinkMeetingPlanner \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  build

xcodebuild -project YealinkMeetingPlanner.xcodeproj \
  -scheme YealinkMeetingPlanner \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  test
```

Общая схема включает тестовое действие. Тесты покрывают чистую логику:
`ConferenceTimeCalculator`, `ScheduleSlotFormatter`, `TimeUtils`,
`WeatherIconMapper`, `DemoData` и `YmsRequestSigner`. Они работают в памяти
и не требуют сети.

## Структура проекта

```
YealinkMeetingPlanner/YealinkMeetingPlanner/
  AppState.swift
  Conference/          Хранилище расписания, калькулятор, репозиторий, демо
  HeaderView/          Шапка с датой и временем
  WeatherView/         Прогноз, кеш, маппинг иконок
  ScanSecretKey/       QR-сканер, Keychain
  ScheduleView/        Слоты расписания
  Settings/            PIN, город, переключатель демо
  Helpers/             Константы разметки, утилиты дат, протокол хранилища
  NetworkLayers/       HTTP-клиент, подпись запросов
  Model/               Модели SwiftData, модель погоды
  LocalProperties/     Config.plist (хост и источник ключей)
```

`YealinkMeetingPlannerTests/` содержит целевой таргет модульных тестов.
