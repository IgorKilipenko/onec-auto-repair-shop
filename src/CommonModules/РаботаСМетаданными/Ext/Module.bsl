﻿#Область ПрограммныйИнтерфейс

// Возвращает менеджер объекта по ссылке.
// Параметры:
//  типОбъекта - Тип
// Возвращаемое значение:
//  - Менеджер
Функция ПолучитьМенеджерОбъекта(Знач типОбъекта) Экспорт
    метаданныеОбъекта = Метаданные.НайтиПоТипу(типОбъекта);
    Если метаданныеОбъекта = Неопределено Тогда
        Возврат Неопределено;
    КонецЕсли;

    полноеИмяМетаданных = метаданныеОбъекта.ПолноеИмя();
    ДиагностикаКлиентСервер.Утверждение(
        РаботаСоСтрокамиВызовСервера.ПодобнаПоРегулярномуВыражению(
            полноеИмяМетаданных, "[А-ЯЁ][А-ЯЁа-яё0-9_]+\.[А-ЯЁ][А-ЯЁа-яё0-9_]+"),
        СтрШаблон("Указан неверный Тип контейнера ""%1"".", полноеИмяМетаданных),
        получитьКонтекстДиагностики("ПолучитьМенеджерОбъектаПоСсылке"));

    имяТипаМенеджера = СтрЗаменить(полноеИмяМетаданных, ".", "Менеджер.");
    менеджерОбъекта = Новый(Тип(имяТипаМенеджера));

    Возврат менеджерОбъекта;
КонецФункции

// Параметры:
//	типПеречисления - Тип - Тип перечисления
// Возвращаемое значение:
//	- ФиксированнаяСтруктура из КлючИЗначение
//      * Ключ - Строка - Имя элемента перечисления
//      * Значение - ПеречислениеСсылка.ИмяПеречисления - Значение элемента перечисления
//	- Неопределено - Если указан неверный тип перечисления
Функция ПолучитьЗначенияПеречисления(Знач типПеречисления) Экспорт
    контекстДиагностики = получитьКонтекстДиагностики("ПолучитьЗначенияПеречисления");
    ДиагностикаКлиентСервер.Утверждение(типПеречисления <> Неопределено,
        "Аргумент ""ТипПеречисления"" должен иметь определенное значение.",
        контекстДиагностики);

    метаданныеПеречисления = Метаданные.НайтиПоТипу(типПеречисления);
    Если метаданныеПеречисления = Неопределено Тогда
        Возврат Неопределено;
    КонецЕсли;

    ДиагностикаКлиентСервер.Утверждение(
        РаботаСоСтрокамиВызовСервера.ПодобнаПоРегулярномуВыражению(
            метаданныеПеречисления.ПолноеИмя(), "^Перечисление\..+"),
        "Тип аргумента ""ТипПеречисления"" должен быть типом объекта или ссылки ""Перечисления"".",
        ДиагностикаКлиентСервер);

    результат = Новый Структура;
    Для Каждого значениеПеречисления Из метаданныеПеречисления.ЗначенияПеречисления Цикл
        имя = значениеПеречисления.Имя;
        значение = Перечисления[метаданныеПеречисления.Имя][имя];
        результат.Вставить(имя, значение);
    КонецЦикла;

    Возврат Новый ФиксированнаяСтруктура(результат);
КонецФункции

// Параметры:
//	типКонтейнера - Тип - Тип контейнера (Справочник, ПланСчетов, ПланВидовРасчета, ПланВидовХарактеристик)
// Возвращаемое значение:
//	ФиксированнаяСтруктура - Структура вида: { ИмяПредопределенного, ЗначениеПредопределенного }
//			               - Неопределено - Если указан неверный тип перечисления
Функция ПолучитьЗначенияПредопределенных(Знач типКонтейнера) Экспорт
    ДиагностикаКлиентСервер.Утверждение(типКонтейнера <> Неопределено,
        "Аргумент ""ТипКонтейнера"" должен иметь определенное значение.",
        получитьКонтекстДиагностики("ПолучитьЗначенияПредопределенных"));

    метаданныеКонтейнера = Метаданные.НайтиПоТипу(типКонтейнера);
    Если метаданныеКонтейнера = Неопределено Тогда
        Возврат Неопределено;
    КонецЕсли;

    менеджерОбъекта = ПолучитьМенеджерОбъекта(типКонтейнера);

    результат = Новый Структура;
    именаПредопределенных = метаданныеКонтейнера.ПолучитьИменаПредопределенных();
    Для Каждого имяПредопределенного Из именаПредопределенных Цикл
        результат.Вставить(имяПредопределенного, менеджерОбъекта[имяПредопределенного]);
    КонецЦикла;

    Возврат Новый ФиксированнаяСтруктура(результат);
КонецФункции

#КонецОбласти // ПрограммныйИнтерфейс

#Область СлужебныеПроцедурыИФункции

// Параметры:
//  имяФункции - Строка, Неопределено
// Возвращаемое значение:
//  - Строка
Функция получитьКонтекстДиагностики(Знач имяФункции = Неопределено)
    базовыйКонтекстДиагностики = "РаботаСМетаданными";
    Возврат ?(имяФункции = Неопределено, базовыйКонтекстДиагностики, СтрШаблон("%1.%2", базовыйКонтекстДиагностики, имяФункции));
КонецФункции

#КонецОбласти // СлужебныеПроцедурыИФункции
