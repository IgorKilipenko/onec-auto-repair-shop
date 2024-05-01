﻿#Область ОбработчикиСобытий

Процедура ОбработкаЗаполнения(_, __, ___)
    Если ЗначениеЗаполнено(ЭтотОбъект.АвторДокумента) = Ложь Тогда
        ЭтотОбъект.АвторДокумента = ПараметрыСеанса.ТекущийПользователь;
    КонецЕсли;
КонецПроцедуры

Процедура ОбработкаПроведения(отказ, __)
    результатДвижений = выполнитьВсеДвижения();
    Если результатДвижений.Успех = Ложь Тогда
        отказ = Истина;
    КонецЕсли;
КонецПроцедуры

#КонецОбласти // ОбработчикиСобытий

#Область СлужебныеПроцедурыИФункции

#Область Движения
Функция выполнитьВсеДвижения()
    результат = Новый Структура("Успех", Истина);

    // Проверка заполненности СтатьиЗатрат объекта ВидРасчета
    результатПроверки = проверитьЗаполнениеСтатьиЗатратДляВидаРасчета(ПланыВидовРасчета.Начисления.Больничный);
    Если результатПроверки.Успех = Ложь Тогда
        результат.Успех = Ложь;
        результатПроверки.СообщениеОбОшибке.Сообщить();
        Возврат результат;
    КонецЕсли;

    // Попытка выполнить движения по регистру расчетов Начисления (без записи)
    результатДвижения = выполнитьДвиженияРасчетовПоВсемНачислениям();
    Если результатДвижения.Успех = Ложь Тогда
        // Ошибка при выполнении движений
        результат.Успех = Ложь;
        результатДвижения.СообщениеОбОшибке.Сообщить();
        Возврат результат;
    КонецЕсли;

    // Расчет начислений
    ЭтотОбъект.Движения.Начисления.Записывать = Истина;
    ЭтотОбъект.Движения.Начисления.Записать();
    ЭтотОбъект.Движения.Начисления.РассчитатьСуммуНачисления();

    ЭтотОбъект.Движения.Хозрасчетный.Записывать = Истина;
    ЭтотОбъект.Движения.УчетЗатрат.Записывать = Истина;

    данныеНачислений = РегистрыРасчета.Начисления.ПолучитьДанныеНачисленийДокументаРегистратора(
            ЭтотОбъект.Ссылка, Истина, Ложь);
    ДиагностикаКлиентСервер.Утверждение(данныеНачислений.НачисленияПоСтатьямЗатрат.Количество() = 1,
            "Для документа ""Больничный лист"" количество различных записей в ""РегистреРасчетов"" должно быть = 1.");

    // Учет затрат
    структураНачисления = Новый Структура("СтатьяЗатрат, Сумма");
    ЗаполнитьЗначенияСвойств(структураНачисления, данныеНачислений.НачисленияПоСтатьямЗатрат[0]);
    выполнитьДвижениеУчетЗатратОборот(структураНачисления.СтатьяЗатрат, структураНачисления.Сумма);

    // Отражение выплат сотруднику в бухучете
    структураНачисления.Вставить("Сотрудник", ЭтотОбъект.Сотрудник);
    структураНачисления.Вставить("СодержаниеОперации", "Отражено начисление по больничному листу за счет работодателя");
    выполнитьДвижениеНачислениеПоБольничному(структураНачисления);

    Возврат результат;
КонецФункции

// Добавляет записи в регистр расчета начислений всех начислений с разделением периода больничного на календарные периоды.
//  Выполняется контроль установленного оклада для сотрудника.
// Возвращаемое значение:
//  - Структура
//      * Успех - Булево
//      * СообщениеОбОшибке - Строка, Неопределено
Функция выполнитьДвиженияРасчетовПоВсемНачислениям()
    ДиагностикаКлиентСервер.Утверждение(ЗначениеЗаполнено(ЭтотОбъект.Сотрудник),
        "Поле ""Сотрудник"" должно быть заполнено до начала выполнения проведения.");

    результатДвижения = Новый Структура("Успех, СообщениеОбОшибке", Истина, Неопределено);

    окладСотрудника = РегистрыСведений.КадроваяИсторияСотрудников.ПолучитьОкладСотрудника(
            ЭтотОбъект.Сотрудник, ЭтотОбъект.ДатаОкончания);
    Если окладСотрудника = Неопределено Тогда
        сообщение = Новый СообщениеПользователю;
        сообщение.Текст = СтрШаблон(
                "Оклад сотрудника: ""%1"" на период больничного не установлен.
                |Проверьте правильность заполнения данных сотрудника в регистре ""Кадровая история сотрудников"".",
                Строка(ЭтотОбъект.Сотрудник));
        сообщение.УстановитьДанные(ЭтотОбъект);

        результатДвижения.Успех = Ложь;
        результатДвижения.СообщениеОбОшибке = сообщение;

        Возврат результатДвижения;
    КонецЕсли;

    месяцНачисления = НачалоМесяца(ЭтотОбъект.ДатаНачала);
    месяцОкончания = НачалоМесяца(ЭтотОбъект.ДатаОкончания);

    Пока месяцНачисления <= месяцОкончания Цикл
        структураНачисления = РегистрыРасчета.Начисления.СоздатьПустуюСтруктуруНачисления();

        структураНачисления.ВидРасчета = ПланыВидовРасчета.Начисления.Больничный;
        структураНачисления.ДатаНачала = Макс(ЭтотОбъект.ДатаНачала, месяцНачисления);
        структураНачисления.ДатаОкончания = Мин(ЭтотОбъект.ДатаОкончания, КонецМесяца(месяцНачисления));

        структураНачисления.Сотрудник = ЭтотОбъект.Сотрудник;
        структураНачисления.ПоказательРасчета = окладСотрудника;

        выполнитьДвижениеРасчетаНачисления(структураНачисления);

        месяцНачисления = ДобавитьМесяц(месяцНачисления, 1);
    КонецЦикла;

    Возврат результатДвижения;
КонецФункции

// Добавляет запись в регистр расчета начислений
// Параметры:
//  структураНачисления - Структура, ФиксированнаяСтруктура
//      * ВидРасчета - ПланВидовРасчетаСсылка.Начисления
//      * ДатаНачала - Дата
//      * ДатаОкончания - Дата
//      * Сотрудник - СправочникСсылка.Сотрудник
//      * ПоказательРасчета - Число
//      * График - СправочникСсылка.График
//      * Сумма - Число, Неопределено
Процедура выполнитьДвижениеРасчетаНачисления(Знач структураНачисления)
    ЭтотОбъект.Движения.Начисления.ДобавитьНачисление(ЭтотОбъект.ПериодНачисления, структураНачисления);
КонецПроцедуры

Процедура выполнитьДвижениеНачислениеПоБольничному(Знач структураНачисления)
    ЭтотОбъект.Движения.Хозрасчетный.ДобавитьЗаписьРасчетаСПерсоналом(ЭтотОбъект.Дата, структураНачисления);
КонецПроцедуры

Процедура выполнитьДвижениеУчетЗатратОборот(Знач статьяЗатрат, Знач сумма)
    движение = Движения.УчетЗатрат.Добавить();
    движение.Период = ЭтотОбъект.Дата;
    движение.СтатьяЗатрат = статьяЗатрат;
    движение.Сумма = сумма;
КонецПроцедуры
#КонецОбласти // Движения

// Параметры:
//  видРасчетаСсылка - ПланВидовРасчетаСсылка.Начисления
// Возвращаемое значение:
//  - Структура
//      * Успех - Булево
//      * СообщениеОбОшибке - СообщениеПользователю
Функция проверитьЗаполнениеСтатьиЗатратДляВидаРасчета(Знач видРасчетаСсылка)
    ДиагностикаКлиентСервер.Утверждение(
        ТипЗнч(видРасчетаСсылка) = Тип("ПланВидовРасчетаСсылка.Начисления")
            И ЗначениеЗаполнено(видРасчетаСсылка), "Значение аргумента ""ВидРасчетаСсылка"" не соответствует ожиданию.
            |Значение должно иметь Тип ""ПланВидовРасчетаСсылка.Начисления"" и быть заполнено.");

    результат = Новый Структура("Успех, СообщениеОбОшибке", Истина);
    статьяЗатратВидаРасчета = РаботаСРеквизитами.ЗначенияРеквизитовОбъекта(видРасчетаСсылка, "СтатьяЗатрат").СтатьяЗатрат;
    Если ТипЗнч(статьяЗатратВидаРасчета) <> Тип("СправочникСсылка.СтатьиЗатрат")
        ИЛИ ЗначениеЗаполнено(статьяЗатратВидаРасчета) = Ложь Тогда

        сообщение = Новый СообщениеПользователю;
        сообщение.Текст = СтрШаблон("Не установлена статья затрат для выбранного вида расчетов.
                |Заполните поле ""статья затрат"" для вида расчетов: ""%1"".", Строка(видРасчетаСсылка));
        сообщение.Поле = "ВидРасчета";
        сообщение.УстановитьДанные(ЭтотОбъект);

        результат.Успех = Ложь;
        результат.СообщениеОбОшибке = сообщение;
        Возврат результат;
    КонецЕсли;

    Возврат результат;
КонецФункции

#КонецОбласти // СлужебныеПроцедурыИФункции
