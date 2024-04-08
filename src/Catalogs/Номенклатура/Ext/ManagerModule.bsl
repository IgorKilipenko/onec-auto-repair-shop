﻿#Область ПрограммныйИнтерфейс

// Возвращаемое значение:
//	- Структура
Функция ПолучитьТипыНоменклатуры() Экспорт
    результат = РаботаСМетаданными.ПолучитьЗначенияПеречисления(Тип("ПеречислениеСсылка.ТипыНоменклатуры"));
    ДиагностикаКлиентСервер.Утверждение(ТипЗнч(результат) = Тип("Структура") И ЗначениеЗаполнено(результат),
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

#Область СлужебныеПроцедурыИФункции

Функция получитьКонтекстДиагностики(Знач имяФункции = Неопределено)
    базовыйКонтекстДиагностики = "Справочники.Номенклатура.МодульМенеджера";
    Возврат ?(имяФункции = Неопределено, базовыйКонтекстДиагностики, СтрШаблон("%1.%2", базовыйКонтекстДиагностики, имяФункции));
КонецФункции

#КонецОбласти // СлужебныеПроцедурыИФункции
