﻿#Область ОбработчикиСобытий

Процедура ОбработкаЗаполнения(_, __, ___)
    Если ЗначениеЗаполнено(ЭтотОбъект.АвторДокумента) = Ложь Тогда
        ЭтотОбъект.АвторДокумента = ПараметрыСеанса.ТекущийПользователь;
    КонецЕсли;
КонецПроцедуры

Процедура ОбработкаПроверкиЗаполнения(отказ, __)
    Если ЭтотОбъект.Товары.Количество() = 0 И ЭтотОбъект.Услуги.Количество() = 0 Тогда
        сообщение = Новый СообщениеПользователю;
        сообщение.Текст = "Документ должен содержать не менее одной записи номенклатуры товаров или услуг.";
        сообщение.Сообщить();

        отказ = Истина;
    КонецЕсли;
КонецПроцедуры

Процедура ОбработкаПроведения(_, __)
    выполнитьВсеДвиженияДокумента();
КонецПроцедуры

#КонецОбласти // ОбработчикиСобытий

#Область СлужебныеПроцедурыИФункции

#Область Движения
Процедура выполнитьВсеДвиженияДокумента()
    Движения.ТоварыНаСкладах.Записывать = Истина;
    Движения.УчетЗатрат.Записывать = Истина;

    выполнитьВсеДвиженияПоСкладам();
    выполнитьВсеДвиженияУчетаЗатрат();
КонецПроцедуры

Процедура выполнитьВсеДвиженияПоСкладам()
    отражатьСрокиГодности = получитьУчетнуюПолитику() = Перечисления.СпособыСписанияЗапасов.FEFO;

    выборкаТоварыДокумента = Документы.ПоступлениеТоваровИУслуг.ПолучитьТоварыДокумента(ЭтотОбъект.Ссылка, отражатьСрокиГодности);
    Если выборкаТоварыДокумента = Неопределено Тогда
        ДиагностикаКлиентСервер.Утверждение(ЭтотОбъект.Товары.Количество() = 0,
                "Ожидается что ТЧ Товары должна быть пустой.");
        Возврат;
    КонецЕсли;

    Пока выборкаТоварыДокумента.Следующий() Цикл
        выполнитьДвижениеТоварыНаСкладахПриход(выборкаТоварыДокумента, отражатьСрокиГодности);
    КонецЦикла;
КонецПроцедуры

Процедура выполнитьВсеДвиженияУчетаЗатрат()
    таблицаСтатьиЗатрат = Документы.ПоступлениеТоваровИУслуг.ПолучитьСтатьиЗатратДокумента(ЭтотОбъект.Ссылка);
    Если таблицаСтатьиЗатрат = Неопределено Тогда
        ДиагностикаКлиентСервер.Утверждение(ЭтотОбъект.Услуги.Количество() = 0,
                "Ожидается что ТЧ Услуги должна быть пустой когда статьи затрат отсутствуют.");
        Возврат;
    КонецЕсли;

    Для Каждого данныеЗатрат Из таблицаСтатьиЗатрат Цикл
        выполнитьДвижениеУчетЗатратОборот(данныеЗатрат);
    КонецЦикла;
КонецПроцедуры

Процедура выполнитьДвижениеТоварыНаСкладахПриход(Знач текСтрокаНоменклатуры, Знач отражатьСрокиГодности = Ложь)
    движение = Движения.ТоварыНаСкладах.Добавить();
    движение.ВидДвижения = ВидДвиженияНакопления.Приход;
    движение.Период = ЭтотОбъект.Дата;
    движение.Номенклатура = текСтрокаНоменклатуры.Номенклатура;
    движение.Склад = ЭтотОбъект.Склад;
    движение.Количество = текСтрокаНоменклатуры.Количество;
    движение.Сумма = текСтрокаНоменклатуры.Сумма;
    Если отражатьСрокиГодности Тогда
        движение.СрокГодности = текСтрокаНоменклатуры.СрокГодности;
    КонецЕсли;
КонецПроцедуры

Процедура выполнитьДвижениеУчетЗатратОборот(Знач данныеЗатрат)
    движение = Движения.УчетЗатрат.Добавить();
    движение.Период = ЭтотОбъект.Дата;
    движение.СтатьяЗатрат = данныеЗатрат.СтатьяЗатрат;
    движение.Сумма = данныеЗатрат.Сумма;

    ДиагностикаКлиентСервер.Утверждение(движение.Сумма <> Неопределено И движение.СтатьяЗатрат <> Неопределено,
        "Значения строки ""УчетЗатрат"" не заполнены.");
КонецПроцедуры
#КонецОбласти // Движения

Функция получитьУчетнуюПолитику()
    Возврат РегистрыСведений.УчетнаяПолитика.ПолучитьТекущийСпособСписанияЗапасов(ЭтотОбъект.Дата);
КонецФункции

#КонецОбласти // СлужебныеПроцедурыИФункции
