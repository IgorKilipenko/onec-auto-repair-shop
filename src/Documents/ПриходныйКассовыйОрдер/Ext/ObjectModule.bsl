﻿#Область ОбработчикиСобытий

Процедура ОбработкаЗаполнения(Знач данныеЗаполнения, __, ___)
    Если ЗначениеЗаполнено(ЭтотОбъект.АвторДокумента) = Ложь Тогда
        ЭтотОбъект.АвторДокумента = ПараметрыСеанса.ТекущийПользователь;
    КонецЕсли;

    Если ТипЗнч(данныеЗаполнения) = Тип("ДокументСсылка.Реализация") Тогда
        заполнитьНаОснованииДокументаРеализация(данныеЗаполнения);
    ИначеЕсли ТипЗнч(данныеЗаполнения) = Тип("ДокументСсылка.ПоступлениеТоваровИУслуг") Тогда
        заполнитьНаОснованииДокументаПоступлениеТоваровИУслуг(данныеЗаполнения);
    КонецЕсли;
КонецПроцедуры

Процедура ОбработкаПроведения(_, __)
    выполнитьВсеДвиженияДокумента();
КонецПроцедуры

#КонецОбласти // ОбработчикиСобытий

#Область СлужебныеПроцедурыИФункции

#Область Движения
Процедура выполнитьВсеДвиженияДокумента()
    Движения.ДенежныеСредства.Записывать = Истина;
    выполнитьДвижениеДенежныеСредстваПриход();
КонецПроцедуры

Процедура выполнитьДвижениеДенежныеСредстваПриход()
    движение = Движения.ДенежныеСредства.Добавить();
    движение.ВидДвижения = ВидДвиженияНакопления.Приход;
    движение.Период = ЭтотОбъект.Дата;
    движение.Касса = ЭтотОбъект.Касса;
    движение.Сумма = ЭтотОбъект.СуммаДокумента;
КонецПроцедуры
#КонецОбласти // Движения

#Область ЗаполнениеНаОсновании
Процедура заполнитьНаОснованииДокументаРеализация(Знач документСсылка)
    ДиагностикаКлиентСервер.Утверждение(ТипЗнч(документСсылка) = Тип("ДокументСсылка.Реализация"));
    ДиагностикаКлиентСервер.Утверждение(ЗначениеЗаполнено(документСсылка),
        "Для заполнения на основании документ должен иметь не пустую ссылку.");

    данныеЗаполнения = РаботаСРеквизитами.ЗначенияРеквизитовОбъекта(документСсылка, "Контрагент, СуммаДокумента");

    ЭтотОбъект.ДокументОснование = документСсылка;
    ЭтотОбъект.ВидОперации = Перечисления.ВидыОперацийПоступленияДенег.ОплатаОтПокупателя;
    ЭтотОбъект.Плательщик = данныеЗаполнения.Контрагент;
    ЭтотОбъект.СуммаДокумента = данныеЗаполнения.СуммаДокумента;
КонецПроцедуры

Процедура заполнитьНаОснованииДокументаПоступлениеТоваровИУслуг(Знач документСсылка)
    ДиагностикаКлиентСервер.Утверждение(ТипЗнч(документСсылка) = Тип("ДокументСсылка.ПоступлениеТоваровИУслуг"));
    ДиагностикаКлиентСервер.Утверждение(ЗначениеЗаполнено(документСсылка),
        "Для заполнения на основании документ должен иметь не пустую ссылку.");

    данныеЗаполнения = РаботаСРеквизитами.ЗначенияРеквизитовОбъекта(документСсылка, "Плательщик, Договор, СуммаДокумента");

    ЭтотОбъект.ДокументОснование = документСсылка;
    ЭтотОбъект.ВидОперации = Перечисления.ВидыОперацийПоступленияДенег.ВозвратОтПоставщика;
    ЭтотОбъект.Плательщик = данныеЗаполнения.Контрагент;
    ЭтотОбъект.Договор = данныеЗаполнения.Договор;
    ЭтотОбъект.СуммаДокумента = данныеЗаполнения.СуммаДокумента;
КонецПроцедуры
#КонецОбласти // ЗаполнениеНаОсновании

#КонецОбласти // СлужебныеПроцедурыИФункции
