﻿#Область ОбработчикиСобытий

Процедура ОбработкаПроверкиЗаполнения(отказ, проверяемыеРеквизиты)
    проверенныеРеквизиты = Новый Массив();
    Если проверитьЗаполнениеИНН() = Ложь Тогда
        проверенныеРеквизиты.Добавить("ИНН");
        отказ = Истина;
    КонецЕсли;

    исключитьПроверенныеРеквизитыИзМассива(проверенныеРеквизиты, проверяемыеРеквизиты);
КонецПроцедуры

Процедура ПередЗаписью(Отказ)
    Если ЭтотОбъект.ТипОрганизации <> Перечисления.ТипыОрганизаций.ЮридическоеЛицо
        И ЗначениеЗаполнено(ЭтотОбъект.ГлавныйБухгалтер) Тогда

        ЭтотОбъект.ГлавныйБухгалтер = Справочники.Сотрудники.ПустаяСсылка();
    КонецЕсли;
КонецПроцедуры

#КонецОбласти // ОбработчикиСобытий

#Область СлужебныеПроцедурыИФункции

Процедура исключитьПроверенныеРеквизитыИзМассива(Знач проверенныеРеквизитов, Знач проверяемыеРеквизиты) Экспорт
    Для Каждого элементМассива Из проверенныеРеквизитов Цикл
        ПорядковыйНомер = проверяемыеРеквизиты.Найти(элементМассива);
        Если ПорядковыйНомер <> Неопределено Тогда
            проверяемыеРеквизиты.Удалить(ПорядковыйНомер);
        КонецЕсли;
    КонецЦикла;
КонецПроцедуры

Функция проверитьЗаполнениеИНН()
    #Область ДиагностикаПолей
    ДиагностикаКлиентСервер.Утверждение(ЗначениеЗаполнено(ЭтотОбъект.ИНН), "Поле ""ИНН"" должно быть заполнено.");
    ДиагностикаКлиентСервер.Утверждение(ЗначениеЗаполнено(ЭтотОбъект.ТипОрганизации), "Поле ""ТипОрганизации"" должно быть заполнено.");
    ДиагностикаКлиентСервер.Утверждение(
        ЭтотОбъект.ТипОрганизации = Перечисления.ТипыОрганизаций.ЮридическоеЛицо
            ИЛИ ЭтотОбъект.ТипОрганизации = Перечисления.ТипыОрганизаций.ИндивидуальныйПредприниматель,
            "Поле ""ТипОрганизации"" должно иметь значение из списка: [ЮридическоеЛицо, ИндивидуальныйПредприниматель].");
    #КонецОбласти // ДиагностикаПолей

    ожидаемаяДлинаИНН = ?(ЭтотОбъект.ТипОрганизации = Перечисления.ТипыОрганизаций.ЮридическоеЛицо, 10, 12);
    фактическаяДлинаИНН = СтрДлина(ЭтотОбъект.ИНН);
    Если фактическаяДлинаИНН <> ожидаемаяДлинаИНН Тогда
        сообщение = Новый СообщениеПользователю;
        сообщение.Текст = СтрШаблон(
                "Проверьте правильность заполнения поля ""ИНН"".
                |Длина строки поля ""ИНН"" должна быть равна ""%1"" знакам, указанная длина строки - ""%2"" знаков.",
                ожидаемаяДлинаИНН, фактическаяДлинаИНН);
        сообщение.Поле = "ИНН";
        сообщение.УстановитьДанные(ЭтотОбъект);
        сообщение.Сообщить();

        Возврат Ложь;
    КонецЕсли;

    Возврат Истина;
КонецФункции

#КонецОбласти // СлужебныеПроцедурыИФункции
