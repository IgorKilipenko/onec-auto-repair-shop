﻿#Область ПрограммныйИнтерфейс

// Возвращаемое значение:
//	- ФиксированнаяСтруктура из КлючИЗначение
//      * Ключ - Строка - Имя значения перечисления
//      * Значение - ПеречислениеСсылка.ТипыНоменклатуры - Значение элемента перечисления
Функция ПолучитьТипыНоменклатуры() Экспорт
    результат = РаботаСМетаданными.ПолучитьЗначенияПеречисления(Тип("ПеречислениеСсылка.ТипыНоменклатуры"));
    ДиагностикаКлиентСервер.Утверждение(
        ПроверкаТиповКлиентСервер.ЭтоСтруктура(результат, Ложь)
        И ЗначениеЗаполнено(результат),
        "Структура значений перечисления ""ТипыНоменклатуры"" не соответствует ожиданию.
        |Структура значений должна иметь тип ""Структура"" и быть заполненной.",
        получитьКонтекстДиагностики("ПолучитьТипыНоменклатуры"));

    Возврат результат;
КонецФункции

// Параметры:
//  номенклатура - СправочникСсылка.Номенклатура, СправочникОбъект.Номенклатура
// Возвращаемое значение:
//	- ПеречислениеСсылка.ТипыНоменклатуры, Неопределено
Функция ПолучитьЗначениеТипаНоменклатуры(Знач номенклатура) Экспорт
    ДиагностикаКлиентСервер.Утверждение(номенклатура <> Неопределено
        И ЗначениеЗаполнено(номенклатура)
        И (ТипЗнч(номенклатура) = Тип("СправочникСсылка.Номенклатура")
                ИЛИ ТипЗнч(номенклатура) = Тип("СправочникОбъект.Номенклатура")),
            "Недопустимое значение аргумента ""Номенклатура"".",
            получитьКонтекстДиагностики("ПолучитьЗначениеТипаНоменклатуры"));

    результат = РаботаСРеквизитами.ЗначенияРеквизитовОбъекта(номенклатура, "ТипНоменклатуры");

    Возврат результат.ТипНоменклатуры;
КонецФункции

#КонецОбласти // ПрограммныйИнтерфейс

#Область СлужебныйПрограммныйИнтерфейс

// Получает карту соответствий групп в типы номенклатуры.
// Возвращаемое значение:
//	- ФиксированноеСоответствие из КлючИЗначение
//      * Ключ - СправочникСсылка.Номенклатура - элемент группы
//      * Значение - ПеречислениеСсылка.ТипыНоменклатуры - Значение типа номенклатуры
Функция ПолучитьКартуГруппВТипыНоменклатуры() Экспорт
    группы = Новый Соответствие;

    группы.Вставить(Справочники.Номенклатура.Материалы, Перечисления.ТипыНоменклатуры.Материал);
    группы.Вставить(Справочники.Номенклатура.МатериалыКлиента, Перечисления.ТипыНоменклатуры.МатериалКлиента);
    группы.Вставить(Справочники.Номенклатура.Товары, Перечисления.ТипыНоменклатуры.Товар);
    группы.Вставить(Справочники.Номенклатура.Услуги, Перечисления.ТипыНоменклатуры.Услуга);

    Возврат Новый ФиксированноеСоответствие(группы);
КонецФункции

// Устарела. Нужно перенести в отдельный модуль (например РаботаБУ)
// Получает карту соответствий типов номенклатуры и планов видов счетов (БУ) Хозрасчетный.
// Возвращаемое значение:
//	- ФиксированноеСоответствие из КлючИЗначение
//      * Ключ - Перечисления.ТипыНоменклатуры
//      * Значение - ПланыСчетов.Хозрасчетный
Функция ПолучитьКартуПланыСчетовДляТиповНоменклатуры() Экспорт
    группы = Новый Соответствие;

    списокСчетов = Новый Массив;
    списокСчетов.Добавить(ПланыСчетов.Хозрасчетный.Товары);
    группы.Вставить(Перечисления.ТипыНоменклатуры.Товар, списокСчетов);

    списокСчетов = Новый Массив;
    списокСчетов.Добавить(ПланыСчетов.Хозрасчетный.Материалы);
    группы.Вставить(Перечисления.ТипыНоменклатуры.Материал, списокСчетов);

    списокСчетов = Новый Массив;
    списокСчетов.Добавить(ПланыСчетов.Хозрасчетный.РасходыНаПродажу);
    списокСчетов.Добавить(ПланыСчетов.Хозрасчетный.ПрочиеДоходыИРасходы);
    группы.Вставить(Перечисления.ТипыНоменклатуры.Услуга, списокСчетов);

    Возврат Новый ФиксированноеСоответствие(группы);
КонецФункции

// Параметры:
//  группа - СправочникСсылка.Номенклатура - элемент группы
// Возвращаемое значение:
//  - ПеречислениеСсылка.ТипыНоменклатуры
//  - Неопределено
Функция ПолучитьТипНоменклатурыПоГруппе(Знач группа) Экспорт
    ДиагностикаКлиентСервер.Утверждение(ТипЗнч(группа) = Тип("СправочникСсылка.Номенклатура")
            И ЗначениеЗаполнено(группа)
            И группа.ЭтоГруппа);

    картаСоответствий = ПолучитьКартуГруппВТипыНоменклатуры();
    результат = картаСоответствий.Получить(группа);

    Возврат результат;
КонецФункции

#КонецОбласти // СлужебныйПрограммныйИнтерфейс

#Область СлужебныеПроцедурыИФункции

Функция получитьКонтекстДиагностики(Знач имяФункции = Неопределено)
    базовыйКонтекстДиагностики = "Справочники.Номенклатура.МодульМенеджера";
    Возврат ?(имяФункции = Неопределено, базовыйКонтекстДиагностики, СтрШаблон("%1.%2", базовыйКонтекстДиагностики, имяФункции));
КонецФункции

#КонецОбласти // СлужебныеПроцедурыИФункции
