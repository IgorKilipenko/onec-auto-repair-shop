﻿#Область ПрограммныйИнтерфейс

// Возвращает выборку товаров документа сгруппированных по Номенклатуре
//  и сроку годности если аргумент: отражатьСрокиГодности = Истина
// Параметры:
//  документСсылка - ДокументСсылка.ПоступлениеТоваровИУслуг
//  отражатьСрокиГодности - Булево - Если Истина тогда будет выполнена группировка по срокам годности
// Возвращаемое значение:
//  - ВыборкаИзРезультатаЗапроса
//      * Номенклатура - СправочникСсылка.Номенклатура
//      * Количество - Число
//      * Сумма - Число - Общая стоимость позиции
//      * СрокГодности - Дата, Неопределено - [Опциональное] в случае если отражатьСрокиГодности = Ложь - поле отсутствует в выборке
//  - Неопределено
Функция ПолучитьТоварыДокумента(Знач документСсылка, Знач отражатьСрокиГодности) Экспорт
    запросТовары = Новый Запрос;
    запросТовары.УстановитьПараметр("Ссылка", документСсылка);

    запросТовары.Текст =
        "ВЫБРАТЬ
        |	ПоступлениеТоваровТовары.Номенклатура КАК Номенклатура,
        |	СУММА(ПоступлениеТоваровТовары.Количество) КАК Количество,
        |   ПоступлениеТоваровТовары.СрокГодности КАК СрокГодности,
        |	СУММА(ПоступлениеТоваровТовары.Сумма) КАК Сумма
        |ИЗ
        |	Документ.ПоступлениеТоваровИУслуг.Товары КАК ПоступлениеТоваровТовары
        |ГДЕ
        |	ПоступлениеТоваровТовары.Ссылка = &Ссылка
        |
        |СГРУППИРОВАТЬ ПО
        |	ПоступлениеТоваровТовары.Номенклатура,
        |	ПоступлениеТоваровТовары.СрокГодности
        |";

    Если НЕ отражатьСрокиГодности Тогда // Удаляем поле СрокГодности из запроса
        запросТовары.Текст = СтрЗаменить(запросТовары.Текст,
                "ПоступлениеТоваровТовары.СрокГодности КАК СрокГодности,", "");
        запросТовары.Текст = СтрЗаменить(запросТовары.Текст, "ПоступлениеТоваровТовары.Номенклатура,",
                "ПоступлениеТоваровТовары.Номенклатура");
        запросТовары.Текст = СтрЗаменить(запросТовары.Текст, "ПоступлениеТоваровТовары.СрокГодности", "");
    КонецЕсли;

    результатЗапроса = запросТовары.Выполнить();
    Если результатЗапроса.Пустой() Тогда
        Возврат Неопределено;
    КонецЕсли;

    Возврат результатЗапроса.Выбрать();
КонецФункции

// Устарела. Не используется в текущей реализации
// Возвращает выборку услуг документа с группировкой по Номенклатуре и Итогами по СтатьямЗатрат
// Параметры:
//  документСсылка - ДокументСсылка.ПоступлениеТоваровИУслуг
// Возвращаемое значение:
//  - ВыборкаИзРезультатаЗапроса
//      * Номенклатура - СправочникСсылка.Номенклатура
//      * СтатьяЗатрат - СправочникСсылка.СтатьиЗатрат, Неопределено
//      * Сумма - Число - Общая стоимость позиции
//  - Неопределено
Функция ПолучитьВыборкуУслугПоСтатьямЗатрат(Знач документСсылка) Экспорт
    запросУслуг = Новый Запрос;
    запросУслуг.УстановитьПараметр("Ссылка", документСсылка);

    запросУслуг.Текст =
        "ВЫБРАТЬ
        |	ПоступлениеУслугУслуги.Номенклатура КАК Номенклатура,
        |	ПоступлениеУслугУслуги.СтатьяЗатрат КАК СтатьяЗатрат,
        |	СУММА(ПоступлениеУслугУслуги.Сумма) КАК Сумма
        |ИЗ
        |	Документ.ПоступлениеТоваровИУслуг.Услуги КАК ПоступлениеУслугУслуги
        |ГДЕ
        |	ПоступлениеУслугУслуги.Ссылка = &Ссылка
        |
        |СГРУППИРОВАТЬ ПО
        |   ПоступлениеУслугУслуги.СтатьяЗатрат,
        |   ПоступлениеУслугУслуги.Номенклатура,
        |ИТОГИ
        |	СУММА(Сумма)
        |ПО
        |	СтатьяЗатрат
        |";

    результатЗапроса = запросУслуг.Выполнить();

    Если результатЗапроса.Пустой() Тогда
        Возврат Неопределено;
    КонецЕсли;

    выборка = результатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
    Возврат выборка;
КонецФункции

// Возвращает выборку услуг документа с группировкой по Номенклатуре и Итогами по СтатьямЗатрат
// Параметры:
//  документСсылка - ДокументСсылка.ПоступлениеТоваровИУслуг
//  выгрузить - Булево - по умолчанию = Истина
// Возвращаемое значение:
//  - ВыборкаИзРезультатаЗапроса, ТаблицаЗначений
//      * Номенклатура - СправочникСсылка.Номенклатура
//      * СтатьяЗатрат - СправочникСсылка.СтатьиЗатрат, Неопределено
//      * Сумма - Число - Общая стоимость позиции
//  - Неопределено
Функция ПолучитьСтатьиЗатратДокумента(Знач документСсылка, выгрузить = Истина) Экспорт
    запросУслуг = Новый Запрос;
    запросУслуг.УстановитьПараметр("Ссылка", документСсылка);

    запросУслуг.Текст =
        "ВЫБРАТЬ
        |	ПоступлениеУслугУслуги.СтатьяЗатрат КАК СтатьяЗатрат,
        |	СУММА(ПоступлениеУслугУслуги.Сумма) КАК Сумма
        |ИЗ
        |	Документ.ПоступлениеТоваровИУслуг.Услуги КАК ПоступлениеУслугУслуги
        |ГДЕ
        |	ПоступлениеУслугУслуги.Ссылка = &Ссылка
        |
        |СГРУППИРОВАТЬ ПО
        |   ПоступлениеУслугУслуги.СтатьяЗатрат
        |";

    результатЗапроса = запросУслуг.Выполнить();

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
