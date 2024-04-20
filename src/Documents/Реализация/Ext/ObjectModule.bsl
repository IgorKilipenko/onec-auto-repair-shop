﻿#Область ОбработчикиСобытий

Процедура ОбработкаЗаполнения(Знач данныеЗаполнения, __, ___)
    Если ЗначениеЗаполнено(ЭтотОбъект.АвторДокумента) = Ложь Тогда
        ЭтотОбъект.АвторДокумента = ПараметрыСеанса.ТекущийПользователь;
    КонецЕсли;

    Если ТипЗнч(данныеЗаполнения) = Тип("ДокументСсылка.ЗаказНаряд") Тогда
        заполнитьНаОснованииДокументаЗакаНаряд(данныеЗаполнения);
    КонецЕсли;
КонецПроцедуры

Процедура ОбработкаПроведения(отказ, __)
    очиститьДвиженияДокумента();

    результатВыполненияДвижений = выполнитьВсеДвиженияДокумента();
    Если результатВыполненияДвижений.Отказ Тогда
        отказ = Истина;
    Иначе
        записатьДвижения();
        обновитьСтатусОказанияУслуги();
    КонецЕсли;
КонецПроцедуры

#КонецОбласти // ОбработчикиСобытий

#Область СлужебныеПроцедурыИФункции

#Область ЗапросыДанных
// Получает выборку Номенклатуры текущего документа и остатки на складе по товарам
// Параметры:
//  менеджерТаблиц - МенеджерВременныхТаблиц, Неопределено
// Возвращаемое значение:
//  - ВыборкаИзРезультатаЗапроса
Функция получитьТоварыДокументаИОстатки(Знач менеджерТаблиц)
    менеджерТаблиц = ?(менеджерТаблиц = Неопределено, Новый МенеджерВременныхТаблиц, менеджерТаблиц);

    Возврат Документы.Реализация.ПолучитьТоварыДокументаИОстатки(
        ЭтотОбъект.Ссылка, ЭтотОбъект.Склад, Новый Граница(ЭтотОбъект.МоментВремени()));
КонецФункции
#КонецОбласти // ЗапросыДанных

#Область Движения
Процедура записатьДвижения()
    Движения.ТоварыНаСкладах.Записывать = Истина;
    Движения.Продажи.Записывать = Истина;
    Движения.УчетЗатрат.Записывать = Истина;

    Движения.Записать();
КонецПроцедуры

Процедура очиститьДвиженияДокумента()
    записатьДвижения();
    Движения.ЗаказыКлиентов.Записывать = Истина;
КонецПроцедуры

Функция выполнитьВсеДвиженияДокумента()
    результатВыполнения = Новый Структура("Отказ", Ложь);

    менеджерТаблиц = Новый МенеджерВременныхТаблиц;

    блокировка = получитьБлокировкуИзмененияТоварыНаСкладах();
    блокировка.Заблокировать();

    выборкаПартияНоменклатуры = ПолучитьТоварыДокументаИОстатки(менеджерТаблиц);
    Пока выборкаПартияНоменклатуры.Следующий() Цикл
        Если выборкаПартияНоменклатуры.ЭтоТовар Тогда
            количествоОстатков = выборкаПартияНоменклатуры.КоличествоОстаток - выборкаПартияНоменклатуры.КоличествоВДокументе;

            Если количествоОстатков < 0 Тогда
                сообщитьПользователюОПревышенииОстатков(
                    -количествоОстатков,
                    выборкаПартияНоменклатуры.НоменклатураПредставление);

                результатВыполнения.Отказ = Истина;
            КонецЕсли;

            Если результатВыполнения.Отказ Тогда
                Продолжить;
            КонецЕсли;

            стоимостьПартии = выполнитьДвиженияПоПартииТоваров(выборкаПартияНоменклатуры);
            выполнитьДвижениеУчетЗатратОборот(выборкаПартияНоменклатуры,стоимостьПартии);
        КонецЕсли;

        Если НЕ результатВыполнения.Отказ Тогда
            выполнитьДвижениеПродажиОборот(выборкаПартияНоменклатуры.Номенклатура, выборкаПартияНоменклатуры.СуммаВДокументе);
        КонецЕсли;
    КонецЦикла;

    Если ЗначениеЗаполнено(ЭтотОбъект.Услуги) И получитьЭтоРеализацияНаОснованииЗаписиКлиента() Тогда
        выполнитьДвижениеЗаказыКлиентовРасход();
        результатКонтроляОстатковПоЗаказу = выполнитьКонтрольОстатковДляЗаказыКлиентов();

        Если результатКонтроляОстатковПоЗаказу.Отказ Тогда
            сообщитьПользователюОПревышенииОстатков(
                результатКонтроляОстатковПоЗаказу.ИнформацияОтказа.ПревышениеОстатка, ,
                результатКонтроляОстатковПоЗаказу.ИнформацияОтказа.ЗаписьКлиентаПредставление);
            результатВыполнения.Отказ = Истина;
        КонецЕсли;
    КонецЕсли;

    Возврат результатВыполнения;
КонецФункции

Процедура выполнитьДвижениеПродажиОборот(Знач номенклатураСсылка, Знач суммаВДокументе)
    движение = Движения.Продажи.Добавить();
    движение.Период = ЭтотОбъект.Дата;
    движение.Номенклатура = номенклатураСсылка;
    движение.Сотрудник = ЭтотОбъект.Сотрудник;
    движение.Клиент = ЭтотОбъект.Клиент;
    движение.Сумма = суммаВДокументе;
КонецПроцедуры

Функция выполнитьДвиженияПоПартииТоваров(Знач выборкаНоменклатураДокумента)
    общаяСтоимостьНоменклатуры = 0;
    несписанныйОстаток = выборкаНоменклатураДокумента.КоличествоВДокументе;

    выборкаНоменклатураДокументаПоСрокуГодности = выборкаНоменклатураДокумента.Выбрать();
    Пока выборкаНоменклатураДокументаПоСрокуГодности.Следующий() И несписанныйОстаток > 0 Цикл
        // Выполняем проводку по регистру ТоварыНаСкладах для партии товаров
        результатСписания = выполнитьДвижениеТоварыНаСкладахРасход(
                выборкаНоменклатураДокументаПоСрокуГодности,
                несписанныйОстаток);

        общаяСтоимостьНоменклатуры = общаяСтоимостьНоменклатуры + результатСписания.Сумма;
        несписанныйОстаток = несписанныйОстаток - результатСписания.Количество;
    КонецЦикла;

    Возврат общаяСтоимостьНоменклатуры;
КонецФункции

// Параметры:
//  выборкаТоварыПоПартиям - Выборка - выборка товаров на складе с группировкой по сроку годности
//  текущийОстатокВДокументе - Число - Остаток количества Номенклатуры (Товаров) в документе
//  этоОтрицательныйОстаток - Булево - Указывает закончились ли товары на складе
// Возвращаемое значение:
//  - Структура - { Сумма: Число - Стоимость выполненного списания по партии Товаров, Количество: Число - Количество выполненного списания }
Функция выполнитьДвижениеТоварыНаСкладахРасход(выборкаТоварыПоПартиям,
        Знач текущийОстатокВДокументе, Знач этоОтрицательныйОстаток = Ложь)

    доступноДляСписания = ?(этоОтрицательныйОстаток, текущийОстатокВДокументе,
            Мин(выборкаТоварыПоПартиям.КоличествоОстаток, текущийОстатокВДокументе));

    движение = Движения.ТоварыНаСкладах.ДобавитьРасход();
    движение.Период = Дата;
    движение.Номенклатура = выборкаТоварыПоПартиям.Номенклатура;
    движение.Склад = выборкаТоварыПоПартиям.Склад;
    движение.СрокГодности = выборкаТоварыПоПартиям.СрокГодности;
    движение.Количество = доступноДляСписания;
    Если доступноДляСписания = выборкаТоварыПоПартиям.КоличествоОстаток ИЛИ этоОтрицательныйОстаток Тогда
        движение.Сумма = выборкаТоварыПоПартиям.СуммаОстаток;
    Иначе
        движение.Сумма = доступноДляСписания / выборкаТоварыПоПартиям.КоличествоОстаток
            * выборкаТоварыПоПартиям.СуммаОстаток;
    КонецЕсли;

    результатСписания = Новый Структура("Сумма, Количество", движение.Сумма, движение.Количество);

    Возврат результатСписания;
КонецФункции

Процедура выполнитьДвижениеУчетЗатратОборот(Знач выборкаНоменклатураДокумента, Знач стоимостьОбщая)
    движение = Движения.УчетЗатрат.Добавить();
    движение.Период = ЭтотОбъект.Дата;
    движение.СтатьяЗатрат = выборкаНоменклатураДокумента.СтатьяЗатрат;
    движение.Сумма = стоимостьОбщая;
КонецПроцедуры

Процедура выполнитьДвижениеЗаказыКлиентовРасход()
    ожидаемыйТипДокумента = Тип("ДокументСсылка.ЗаписьКлиента");
    ДиагностикаКлиентСервер.Утверждение(
        ЗначениеЗаполнено(ЭтотОбъект.ДокументОснование)
        И ТипЗнч(ЭтотОбъект.ДокументОснование) = ожидаемыйТипДокумента,
            СтрШаблон("ДокументОснование должен быть заполнен и иметь тип значения ""%1"".",
                Строка(ожидаемыйТипДокумента)));

    движение = Движения.ЗаказыКлиентов.Добавить();
    движение.ВидДвижения = ВидДвиженияНакопления.Расход;

    движение.Период = ЭтотОбъект.Дата;
    движение.Клиент = ЭтотОбъект.Клиент;
    движение.ЗаписьКлиента = ЭтотОбъект.ДокументОснование;
    движение.Сумма = ЭтотОбъект.Услуги.Итог("Стоимость");
КонецПроцедуры
#КонецОбласти // Движения

// Выполняет проверку достаточности остатков по Номенклатуре.
// В случае отсутствия достаточного количества остатков - оповещает Пользователя.
// Параметры:
//	количествоВДокументе - Число - Количество Номенклатуры в документе для движения
//	остаток - Число - Остаток Номенклатуры на складах
//	наименованиеНоменклатуры - Строка - Наименование Номенклатуры, используется в тексте сообщения
// Возвращаемое значение:
//	Булево - Истина если остатков нехватает, иначе Ложь
Функция проверитьПревышениеОстатков(Знач количествоВДокументе, Знач остаток, Знач наименованиеНоменклатуры)
    превышениеОстатковНоменклатуры = количествоВДокументе - остаток;
    Если превышениеОстатковНоменклатуры > 0 Тогда
        сообщение = Новый СообщениеПользователю;
        сообщение.Текст = СтрШаблон("Превышение остатка по номенклатуре: ""%1"" в количестве: ""%2""",
                наименованиеНоменклатуры, превышениеОстатковНоменклатуры);
        сообщение.Сообщить();
        Возврат Истина;
    КонецЕсли;
    Возврат Ложь;
КонецФункции

// Возвращаемое значение:
//	- ФиксированнаяСтруктура - Структура вида { Отказ: Булево, ИнформацияОтказа: ФиксированнаяСтруктура | Неопределено}
Функция выполнитьКонтрольОстатковДляЗаказыКлиентов()
    Движения.ЗаказыКлиентов.БлокироватьДляИзменения = Истина;
    Движения.ЗаказыКлиентов.Записать();

    ДиагностикаКлиентСервер.Утверждение(ЭтотОбъект.ДокументОснование <> Неопределено
        И ТипЗнч(ЭтотОбъект.ДокументОснование) = Тип("ДокументСсылка.ЗаписьКлиента"),
            "Ошибка! ДокументОснование должен иметь значение типа ДокументСсылка.ЗаписьКлиента.");

    остатокПоЗаказу = Документы.Реализация.ПолучитьОстатокПоЗаписиКлиента(
            ЭтотОбъект.ДокументОснование, Новый Граница(ЭтотОбъект.МоментВремени()));

    отказ = остатокПоЗаказу <> Неопределено И остатокПоЗаказу.Сумма < 0;
    информацияОтказа = Неопределено;
    Если отказ Тогда
        информацияОтказа = Новый ФиксированнаяСтруктура("ПревышениеОстатка, ЗаписьКлиентаПредставление",
                -остатокПоЗаказу.Сумма, остатокПоЗаказу.ЗаписьКлиентаПредставление);
    КонецЕсли;

    Возврат Новый ФиксированнаяСтруктура("Отказ, ИнформацияОтказа", отказ, информацияОтказа);
КонецФункции

Функция получитьБлокировкуИзмененияТоварыНаСкладах()
    блокировка = Новый БлокировкаДанных;
    элементБлокировки = блокировка.Добавить("РегистрНакопления.ТоварыНаСкладах");
    элементБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
    элементБлокировки.ИсточникДанных = ЭтотОбъект.Товары;
    элементБлокировки.ИспользоватьИзИсточникаДанных("Номенклатура", "Номенклатура");
    элементБлокировки.УстановитьЗначение("Склад", ЭтотОбъект.Склад);

    Возврат блокировка;
КонецФункции

Функция получитьЭтоРеализацияНаОснованииЗаписиКлиента()
    Возврат ЗначениеЗаполнено(ЭтотОбъект.ДокументОснование) И ТипЗнч(ЭтотОбъект.ДокументОснование) = Тип("ДокументСсылка.ЗаписьКлиента");
КонецФункции

// Параметры:
//	превышениеОстатков - Число - Количество превышения остатков
//	наименованиеНоменклатуры - Строка, Неопределено - Наименование Номенклатуры, используется в тексте сообщения
//	записьКлиентаПредставление - Строка, Неопределено - Строковое представление записи клиента
Процедура сообщитьПользователюОПревышенииОстатков(
        Знач превышениеОстатков, Знач наименованиеНоменклатуры = Неопределено, Знач записьКлиентаПредставление = Неопределено)
    ДиагностикаКлиентСервер.Утверждение(наименованиеНоменклатуры <> Неопределено
        ИЛИ записьКлиентаПредставление <> Неопределено,
        "Один из необязательных аргументов: [НаименованиеНоменклатуры, ЗаписьКлиентаПредставление] должен быть заполнен.");

    форматФинансовыхДанных = "ЧДЦ=2; ЧРГ= ; ЧН=0.00";
    сообщение = Новый СообщениеПользователю;
    текстСообщения = "";
    Если записьКлиентаПредставление <> Неопределено Тогда // Это превышение суммы по записи клиента
        текстСообщения = СтрШаблон("Превышена сумма по записи клиента ""%1"" на ""%2"".",
                записьКлиентаПредставление, Формат(превышениеОстатков, форматФинансовыхДанных));
    Иначе
        текстСообщения = СтрШаблон("Превышение остатка по номенклатуре: ""%1"" в количестве: ""%2""",
                наименованиеНоменклатуры, превышениеОстатков);
    КонецЕсли;

    сообщение.Текст = текстСообщения;
    сообщение.Сообщить();
КонецПроцедуры

#КонецОбласти // СлужебныеПроцедурыИФункции
