﻿#Область ПрограммныйИнтерфейс

Процедура Печать(ТабДок, Ссылка) Экспорт
    //{{_КОНСТРУКТОР_ПЕЧАТИ(Печать)
    Макет = Документы.Реализация.ПолучитьМакет("Печать");
    Запрос = Новый Запрос;
    Запрос.Текст =
        "ВЫБРАТЬ
        |	Реализация.Автомобиль,
        |	Реализация.АвторДокумента,
        |	Реализация.Дата,
        |	Реализация.ДокументОснование,
        |	Реализация.Контрагент,
        |	Реализация.Номер,
        |	Реализация.Склад,
        |	Реализация.Сотрудник,
        |	Реализация.СуммаДокумента,
        |	Реализация.Товары.(
        |		НомерСтроки,
        |		Номенклатура,
        |		Количество,
        |		Цена,
        |		Сумма
        |	),
        |	Реализация.Услуги.(
        |		НомерСтроки,
        |		Номенклатура,
        |		Количество,
        |		Цена,
        |		Сумма
        |	),
        |	Реализация.МатериалыЗаказчика.(
        |		НомерСтроки,
        |		Номенклатура,
        |		Количество,
        |		СостояниеМатериала,
        |		Использован
        |	)
        |ИЗ
        |	Документ.Реализация КАК Реализация
        |ГДЕ
        |	Реализация.Ссылка В (&Ссылка)";
    Запрос.Параметры.Вставить("Ссылка", Ссылка);
    Выборка = Запрос.Выполнить().Выбрать();

    ОбластьЗаголовок = Макет.ПолучитьОбласть("Заголовок");
    Шапка = Макет.ПолучитьОбласть("Шапка");
    ОбластьТоварыШапка = Макет.ПолучитьОбласть("ТоварыШапка");
    ОбластьТовары = Макет.ПолучитьОбласть("Товары");
    ОбластьУслугиШапка = Макет.ПолучитьОбласть("УслугиШапка");
    ОбластьУслуги = Макет.ПолучитьОбласть("Услуги");
    ОбластьМатериалыЗаказчикаШапка = Макет.ПолучитьОбласть("МатериалыЗаказчикаШапка");
    ОбластьМатериалыЗаказчика = Макет.ПолучитьОбласть("МатериалыЗаказчика");
    Подвал = Макет.ПолучитьОбласть("Подвал");

    ТабДок.Очистить();

    ВставлятьРазделительСтраниц = Ложь;
    Пока Выборка.Следующий() Цикл
        Если ВставлятьРазделительСтраниц Тогда
            ТабДок.ВывестиГоризонтальныйРазделительСтраниц();
        КонецЕсли;

        ОбластьЗаголовок.Параметры.Заполнить(Выборка);
        ТабДок.Вывести(ОбластьЗаголовок);

        Шапка.Параметры.Заполнить(Выборка);
        ТабДок.Вывести(Шапка, Выборка.Уровень());

        ВыборкаТовары = Выборка.Товары.Выбрать();
        Если ВыборкаТовары.Количество() > 0 Тогда
            ТабДок.Вывести(ОбластьТоварыШапка);

            Пока ВыборкаТовары.Следующий() Цикл
                ОбластьТовары.Параметры.Заполнить(ВыборкаТовары);
                ТабДок.Вывести(ОбластьТовары, ВыборкаТовары.Уровень());
            КонецЦикла;
        КонецЕсли;

        ВыборкаУслуги = Выборка.Услуги.Выбрать();
        Если ВыборкаУслуги.Количество() > 0 Тогда
            ТабДок.Вывести(ОбластьУслугиШапка);

            Пока ВыборкаУслуги.Следующий() Цикл
                ОбластьУслуги.Параметры.Заполнить(ВыборкаУслуги);
                ТабДок.Вывести(ОбластьУслуги, ВыборкаУслуги.Уровень());
            КонецЦикла;
        КонецЕсли;

        ВыборкаМатериалыЗаказчика = Выборка.МатериалыЗаказчика.Выбрать();
        Если ВыборкаМатериалыЗаказчика.Количество() > 0 Тогда
            ТабДок.Вывести(ОбластьМатериалыЗаказчикаШапка);

            Пока ВыборкаМатериалыЗаказчика.Следующий() Цикл
                ОбластьМатериалыЗаказчика.Параметры.Заполнить(ВыборкаМатериалыЗаказчика);
                ТабДок.Вывести(ОбластьМатериалыЗаказчика, ВыборкаМатериалыЗаказчика.Уровень());
            КонецЦикла;
        КонецЕсли;

        Подвал.Параметры.Заполнить(Выборка);
        Подвал.Параметры.Заполнить(Новый Структура("СуммаДокументаПрописью",
                ЧислоПрописью(Выборка.СуммаДокумента, "Л = ru_RU; ДП = Истина", "рубль, рубля, рублей, м, копейка, копейки, копеек, ж, 2")));
        ТабДок.Вывести(Подвал);

        ВставлятьРазделительСтраниц = Истина;
    КонецЦикла;
    //}}
КонецПроцедуры

// Возвращает выборку товаров документа сгруппированных по Номенклатуре
// Параметры:
//  документСсылка - ДокументСсылка.Реализация
//  выгрузить - Булево - Если **менеджер** <> Неопределено значение игнорируется
//  менеджер - МенеджерВременныхТаблиц
// Возвращаемое значение:
//  - ВыборкаИзРезультатаЗапроса, ТаблицаЗначений
//      * Номенклатура - СправочникСсылка.Номенклатура
//      * Количество - Число
//      * Сумма - Число - Общая стоимость позиции
//  - МенеджерВременныхТаблиц - Если значение аргумента **менеджер** заполнено
//  - Неопределено - Если данные отсутствуют (не используется если **менеджер** <> Неопределено)
Функция ПолучитьТоварыДокумента(Знач документСсылка, Знач выгрузить = Истина, Знач менеджер = Неопределено) Экспорт
    запрос = Новый Запрос;
    запрос.МенеджерВременныхТаблиц = ?(менеджер = Неопределено, Новый МенеджерВременныхТаблиц, менеджер);
    запрос.УстановитьПараметр("Ссылка", документСсылка);

    запрос.Текст =
        "ВЫБРАТЬ
        |	РеализацияТовары.Номенклатура КАК Номенклатура,
        |	СУММА(РеализацияТовары.Количество) КАК Количество,
        |	СУММА(РеализацияТовары.Сумма) КАК Сумма
        |ПОМЕСТИТЬ ВТ_ТоварыДокумента
        |ИЗ
        |	Документ.Реализация.Товары КАК РеализацияТовары
        |ГДЕ
        |	РеализацияТовары.Ссылка = &Ссылка
        |
        |СГРУППИРОВАТЬ ПО
        |	РеализацияТовары.Номенклатура
        |";

    Если менеджер <> Неопределено Тогда
        запрос.Выполнить();
        Возврат менеджер;
    Иначе
        запрос.Текст = СтрЗаменитьПоРегулярномуВыражению(
                запрос.Текст, "^ПОМЕСТИТЬ ВТ_ТоварыДокумента$", "", Ложь, Истина);
    КонецЕсли;

    результатЗапроса = запрос.Выполнить();
    Если результатЗапроса.Пустой() Тогда
        Возврат Неопределено;
    КонецЕсли;

    Если выгрузить = Истина Тогда
        Возврат результатЗапроса.Выгрузить();
    Иначе
        Возврат результатЗапроса.Выбрать();
    КонецЕсли;
КонецФункции

// Возвращает выборку услуг документа сгруппированных по Номенклатуре
// Параметры:
//  документСсылка - ДокументСсылка.Реализация
//  выгрузить - Булево - Если **менеджер** <> Неопределено значение игнорируется
//  менеджер - МенеджерВременныхТаблиц - Если значение заполнено таблица будет помещена в менеджер как **ВТ_УслугиДокумента**
// Возвращаемое значение:
//  - ВыборкаИзРезультатаЗапроса, ТаблицаЗначений
//      * Номенклатура - СправочникСсылка.Номенклатура
//      * Количество - Число
//      * Сумма - Число - Общая стоимость позиции
//  - МенеджерВременныхТаблиц - Если значение аргумента **менеджер** заполнено
//  - Неопределено - Если данные отсутствуют (не используется если **менеджер** <> Неопределено)
Функция ПолучитьУслугиДокумента(Знач документСсылка, Знач выгрузить = Истина, Знач менеджер = Неопределено) Экспорт
    запрос = Новый Запрос;
    запрос.МенеджерВременныхТаблиц = ?(менеджер = Неопределено, Новый МенеджерВременныхТаблиц, менеджер);
    запрос.УстановитьПараметр("Ссылка", документСсылка);

    запрос.Текст =
        "ВЫБРАТЬ
        |	РеализацияУслуги.Номенклатура КАК Номенклатура,
        |	СУММА(РеализацияУслуги.Количество) КАК Количество,
        |	СУММА(РеализацияУслуги.Сумма) КАК Сумма
        |ПОМЕСТИТЬ ВТ_УслугиДокумента
        |ИЗ
        |	Документ.Реализация.Услуги КАК РеализацияУслуги
        |ГДЕ
        |	РеализацияУслуги.Ссылка = &Ссылка
        |
        |СГРУППИРОВАТЬ ПО
        |	РеализацияУслуги.Номенклатура
        |";

    Если менеджер <> Неопределено Тогда
        запрос.Выполнить();
        Возврат менеджер;
    Иначе
        запрос.Текст = СтрЗаменитьПоРегулярномуВыражению(
                запрос.Текст, "^ПОМЕСТИТЬ ВТ_УслугиДокумента$", "", Ложь, Истина);
    КонецЕсли;

    результатЗапроса = запрос.Выполнить();
    Если результатЗапроса.Пустой() Тогда
        Возврат Неопределено;
    КонецЕсли;

    Если выгрузить = Истина Тогда
        Возврат результатЗапроса.Выгрузить();
    Иначе
        Возврат результатЗапроса.Выбрать();
    КонецЕсли;
КонецФункции

// Параметры:
//  документСсылка - ДокументСсылка.Реализация
//  выгрузить - Булево - Если **менеджер** <> Неопределено значение игнорируется
//  менеджер - МенеджерВременныхТаблиц - Если значение заполнено таблица будет помещена в менеджер как **ВТ_МатериалыЗаказчика**
// Возвращаемое значение:
//  - ВыборкаИзРезультатаЗапроса, ТаблицаЗначений
//      * Номенклатура - СправочникСсылка.Номенклатура
//      * Количество - Число
//      * СостояниеМатериала - ПеречислениеСсылка.СостоянияМатериалов
//      * Использован - Булево
//  - МенеджерВременныхТаблиц - Если значение аргумента **менеджер** заполнено
//  - Неопределено - Если данные отсутствуют (не используется если **менеджер** <> Неопределено)
Функция ПолучитьМатериалыЗаказчикаДокумента(Знач документСсылка, Знач выгрузить = Истина, Знач менеджер = Неопределено) Экспорт
    запрос = Новый Запрос;
    запрос.МенеджерВременныхТаблиц = ?(менеджер = Неопределено, Новый МенеджерВременныхТаблиц, менеджер);
    запрос.Текст =
        "ВЫБРАТЬ
        |   РеализацияМатериалыЗаказчика.Номенклатура КАК Номенклатура,
        |   РеализацияМатериалыЗаказчика.Количество КАК Количество,
        |   РеализацияМатериалыЗаказчика.СостояниеМатериала КАК СостояниеМатериала,
        |   РеализацияМатериалыЗаказчика.Использован КАК Использован
        |ПОМЕСТИТЬ ВТ_МатериалыЗаказчика
        |ИЗ
        |   Документ.Реализация.МатериалыЗаказчика КАК РеализацияМатериалыЗаказчика
        |ГДЕ
        |   РеализацияМатериалыЗаказчика.Ссылка = &Ссылка
        |";

    запрос.УстановитьПараметр("Ссылка", документСсылка);
    Если менеджер <> Неопределено Тогда
        запрос.Выполнить();
        Возврат менеджер;
    Иначе
        запрос.Текст = СтрЗаменитьПоРегулярномуВыражению(
                запрос.Текст, "^ПОМЕСТИТЬ ВТ_МатериалыЗаказчика$", "", Ложь, Истина);
    КонецЕсли;

    результатЗапроса = запрос.Выполнить();
    Если результатЗапроса.Пустой() Тогда
        Возврат Неопределено;
    КонецЕсли;

    Если выгрузить = Истина Тогда
        Возврат результатЗапроса.Выгрузить();
    Иначе
        Возврат результатЗапроса.Выбрать();
    КонецЕсли;
КонецФункции

#КонецОбласти // ПрограммныйИнтерфейс

#Область СлужебныйПрограммныйИнтерфейс

// Дополняет таблицу номенклатуры данными по остаткам на складах и статьям затрат
//  и добавляет итоги по партиям товаров (с упорядочиванием по сроку годности)
// Параметры:
//  менеджер - МенеджерВременныхТаблиц - Менеджер должен содержать таблицу с товарами документа
//  период - Дата, МоментВремени, Граница
//  склад - СправочникСсылка.Склады
//  выгрузить - Булево - По умолчанию = Истина
// Возвращаемое значение:
//  - ВыборкаИзРезультатаЗапроса - Если **выгрузить** = Ложь
//  - ДеревоЗначений - Если **выгрузить** = Истина
//      * Номенклатура - СправочникСсылка.Номенклатура
//      * НоменклатураПредставление - Строка
//      * КоличествоВДокументе - Число
//      * СуммаВДокументе - Число
//      * СрокГодности - Дата
//      * КоличествоОстаток - Число - Остаток на складе
//      * СуммаОстаток - Число - Сумма остатков на складе
//      * СтатьяЗатрат - СправочникСсылка.СтатьиЗатрат
//  - Неопределено - Если данные отсутствуют
Функция ПолучитьОстаткиИСтатьиЗатратДляВТ(Знач менеджер, Знач период, Знач склад, Знач выгрузить = Истина) Экспорт
    запрос = Новый Запрос;
    запрос.МенеджерВременныхТаблиц = менеджер;
    запрос.Текст =
        "ВЫБРАТЬ // Остатки товаров на складах
        |   ТоварыНаСкладахОстатки.Номенклатура КАК Номенклатура,
        |	ТоварыНаСкладахОстатки.СрокГодности КАК СрокГодности,
        |	ЕСТЬNULL(ТоварыНаСкладахОстатки.КоличествоОстаток, 0) КАК КоличествоОстаток,
        |	ЕСТЬNULL(ТоварыНаСкладахОстатки.СуммаОстаток, 0) КАК СуммаОстаток
        |ПОМЕСТИТЬ ВТ_ОстаткиИЗатратыНоменклатуры
        |ИЗ
        |   РегистрНакопления.ТоварыНаСкладах.Остатки(
        |				&МоментВремени,
        |				Склад = &Склад
        |					И Номенклатура В (
        |                       ВЫБРАТЬ Номенклатура КАК Номенклатура ИЗ ВТ_ТоварыДокумента)
        |               ) КАК ТоварыНаСкладахОстатки
        |ИНДЕКСИРОВАТЬ ПО
        |   Номенклатура
        |;
        |
        |////////////////////////////////////////////////////////////////////////////////
        |ВЫБРАТЬ // Остатки товаров на складах и Статьи затрат
        |	ВТ_ТоварыДокумента.Номенклатура КАК Номенклатура,
        |	ВТ_ТоварыДокумента.Номенклатура.Представление КАК НоменклатураПредставление,
        |   ВТ_ТоварыДокумента.Номенклатура.СтатьяЗатрат КАК СтатьяЗатрат,
        |	ВТ_ТоварыДокумента.Количество КАК КоличествоВДокументе,
        |	ВТ_ТоварыДокумента.Сумма КАК СуммаВДокументе,
        |	ВТ_ОстаткиИЗатратыНоменклатуры.СрокГодности КАК СрокГодности,
        |	ЕСТЬNULL(ВТ_ОстаткиИЗатратыНоменклатуры.КоличествоОстаток, 0) КАК КоличествоОстаток,
        |	ЕСТЬNULL(ВТ_ОстаткиИЗатратыНоменклатуры.СуммаОстаток, 0) КАК СуммаОстаток
        |ИЗ
        |	ВТ_ТоварыДокумента КАК ВТ_ТоварыДокумента
        |		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_ОстаткиИЗатратыНоменклатуры КАК ВТ_ОстаткиИЗатратыНоменклатуры
        |		ПО ВТ_ТоварыДокумента.Номенклатура = ВТ_ОстаткиИЗатратыНоменклатуры.Номенклатура
        |
        |УПОРЯДОЧИТЬ ПО
        |	ВТ_ОстаткиИЗатратыНоменклатуры.СрокГодности
        |ИТОГИ
        |	МАКСИМУМ(КоличествоВДокументе),
        |	МАКСИМУМ(СуммаВДокументе),
        |	СУММА(КоличествоОстаток)
        |ПО
        |	Номенклатура
        |";

    запрос.УстановитьПараметр("МоментВремени", период);
    запрос.УстановитьПараметр("Склад", склад);
    результатЗапроса = запрос.Выполнить();

    Если результатЗапроса.Пустой() Тогда
        Возврат Неопределено;
    КонецЕсли;

    Если выгрузить = Истина Тогда
        Возврат результатЗапроса.Выгрузить(ОбходРезультатаЗапроса.ПоГруппировкам);
    Иначе
        Возврат результатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
    КонецЕсли;
КонецФункции

#КонецОбласти // СлужебныйПрограммныйИнтерфейс
