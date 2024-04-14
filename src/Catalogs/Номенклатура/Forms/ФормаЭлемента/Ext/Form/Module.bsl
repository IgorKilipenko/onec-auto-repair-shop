﻿#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(_, __)
    инициализацияНаСервере();
КонецПроцедуры

// Обработчик события формы ПриОткрытии
// Параметры:
// _ - ЭлементФормы - не используется в текущей реализации
&НаКлиенте
Процедура ПриОткрытии(_)
    Если Объект.Ссылка.Пустая() Тогда
        Объект.Родитель = ?(ЗначениеЗаполнено(Объект.Родитель), Объект.Родитель, ЭтотОбъект._Состояние.ГруппыНоменклатуры.Товары);
    КонецЕсли;

    установитьВидимостьПолейФормы();
КонецПроцедуры

#КонецОбласти // ОбработчикиСобытийФормы

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ТипНоменклатурыПриИзменении(_)
    установитьРодителя();
    установитьВидимостьПолейФормы();
КонецПроцедуры

&НаКлиенте
Процедура РодительПриИзменении(_)
    установитьТипНоменклатуры();
    установитьВидимостьПолейФормы();
КонецПроцедуры

#КонецОбласти // ОбработчикиСобытийЭлементовШапкиФормы

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура установитьРодителя()
    Если Объект.ТипНоменклатуры = ЭтотОбъект._Состояние.ТипыНоменклатуры.Товар Тогда
        Объект.Родитель = ЭтотОбъект._Состояние.ГруппыНоменклатуры.Товары;
    ИначеЕсли Объект.ТипНоменклатуры = ЭтотОбъект._Состояние.ТипыНоменклатуры.Материал Тогда
        Объект.Родитель = ЭтотОбъект._Состояние.ГруппыНоменклатуры.Материалы;
    ИначеЕсли Объект.ТипНоменклатуры = ЭтотОбъект._Состояние.ТипыНоменклатуры.МатериалКлиента Тогда
        Объект.Родитель = ЭтотОбъект._Состояние.ГруппыНоменклатуры.МатериалыКлиента;
    ИначеЕсли Объект.ТипНоменклатуры = ЭтотОбъект._Состояние.ТипыНоменклатуры.Услуга Тогда
        Объект.Родитель = ЭтотОбъект._Состояние.ГруппыНоменклатуры.Услуги;
    КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура установитьТипНоменклатуры()
    Если Объект.Родитель.Пустая() Тогда
        Возврат;
    КонецЕсли;

    типНоменклатурыДляГруппы = _Состояние.КартаСоответствияГруппНоменклатур.Получить(Объект.Родитель);
    ДиагностикаКлиентСервер.Утверждение(типНоменклатурыДляГруппы <> Неопределено,
        "Тип номенклатуры для группы должен быть определен.");

    Объект.ТипНоменклатуры = типНоменклатурыДляГруппы;
КонецПроцедуры

&НаКлиенте
Процедура установитьВидимостьПолейФормы()
    Элементы.ДлительностьУслуги.Видимость = Объект.ТипНоменклатуры = ЭтотОбъект._Состояние.ТипыНоменклатуры.Услуга;
КонецПроцедуры

&НаКлиенте
Функция получитьКонтекстДиагностики(Знач имяФункции = Неопределено)
    базовыйКонтекстДиагностики = "Номенклатура.ФормаЭлемента";
    Возврат ?(имяФункции = Неопределено, базовыйКонтекстДиагностики, СтрШаблон("%1.%2", базовыйКонтекстДиагностики, имяФункции));
КонецФункции

#КонецОбласти // СлужебныеПроцедурыИФункции

#Область Инициализация

&НаСервере
Процедура инициализацияНаСервере()
    ЭтотОбъект._Состояние = Новый Структура("ГруппыНоменклатуры, ТипыНоменклатуры, КартаСоответствияГруппНоменклатур");
    ЭтотОбъект._Состояние.ГруппыНоменклатуры = РаботаСМетаданными.ПолучитьЗначенияПредопределенных(Тип("СправочникСсылка.Номенклатура"));
    ЭтотОбъект._Состояние.ТипыНоменклатуры = Новый ФиксированнаяСтруктура(
            Справочники.Номенклатура.ПолучитьТипыНоменклатуры());
    ЭтотОбъект._Состояние.КартаСоответствияГруппНоменклатур = Справочники.Номенклатура.ПолучитьКартуГруппВТипыНоменклатуры();
КонецПроцедуры

#КонецОбласти // Инициализация
