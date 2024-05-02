﻿#Область ПрограммныйИнтерфейс

// Возвращает структуру, содержащую значения реквизитов, прочитанные из информационной базы по ссылке на объект.
// Рекомендуется использовать вместо обращения к реквизитам объекта через точку от ссылки на объект
// для быстрого чтения отдельных реквизитов объекта из базы данных.
//
// Если необходимо зачитать реквизит независимо от прав текущего пользователя,
// то следует использовать предварительный переход в привилегированный режим.
//
// Параметры:
//  ссылка    - ЛюбаяСсылка - объект, значения реквизитов которого необходимо получить.
//  реквизиты - Строка - имена реквизитов, перечисленные через запятую, в формате
//                       требований к свойствам структуры.
//                       Например, "Код, Наименование, Родитель".
//            - Структура
//            - ФиксированнаяСтруктура - в качестве ключа передается
//                       псевдоним поля для возвращаемой структуры с результатом, а в качестве
//                       значения (опционально) фактическое имя поля в таблице.
//                       Если ключ задан, а значение не определено, то имя поля берется из ключа.
//                       НЕ допускается указание имени поля через точку.
//            - Массив из Строка
//            - ФиксированныйМассив из Строка - имена реквизитов в формате требований к свойствам структуры.
//  выбратьРазрешенные - Булево - если Истина, то запрос к объекту выполняется с учетом прав пользователя;
//                                если есть ограничение на уровне записей, то все реквизиты вернутся со
//                                значением Неопределено; если нет прав для работы с таблицей, то возникнет исключение;
//                                если Ложь, то возникнет исключение при отсутствии прав на таблицу
//                                или любой из реквизитов.
// Возвращаемое значение:
//              - Структура - содержит имена (ключи) и значения затребованных реквизитов.
//                  Если в параметр Реквизиты передана пустая строка, то возвращается пустая структура.
//                  Если в параметр Ссылка передана пустая ссылка, то возвращается структура,
//                  соответствующая именам реквизитов со значениями Неопределено.
//                  Если в параметр Ссылка передана ссылка несуществующего объекта (битая ссылка),
//                  то все реквизиты вернутся со значением Неопределено.
Функция ЗначенияРеквизитовОбъекта(Знач ссылка, Знач реквизиты, выбратьРазрешенные = Ложь) Экспорт
    контекстВыполнения = "РаботаСРеквизитами.ЗначенияРеквизитовОбъекта";

    // Проверка аргумента: ссылка
    полноеИмяОбъектаМетаданных = Неопределено;
    Попытка
        полноеИмяОбъектаМетаданных = ссылка.Метаданные().ПолноеИмя();
    Исключение
        ВызватьИсключение СтрШаблон(
            НСтр("ru = 'Неверный первый параметр %1 в функции %2:
                |Значение должно быть ссылкой или именем предопределенного элемента.'"),
            "Ссылка", контекстВыполнения);
    КонецПопытки;

    Если НЕ проверитьРеквизиты(реквизиты) Тогда
        ВызватьИсключение СтрШаблон(
            НСтр("ru = 'Неверный тип второго параметра %1 в функции %2: %3.'"),
            "Реквизиты", контекстВыполнения, Строка(ТипЗнч(реквизиты)));
    КонецЕсли;

    структураПолей = КонвертироватьРеквизитыВСтруктуру(реквизиты);

    Если ссылка = Неопределено ИЛИ НЕ ЗначениеЗаполнено(ссылка) Тогда
        Возврат структураПолей;
    КонецЕсли;

    запрос = Новый Запрос;
    запрос.УстановитьПараметр("Ссылка", ссылка);
    запрос.Текст = сформироватьТекстЗапросаПоРеквизитам(полноеИмяОбъектаМетаданных, структураПолей, выбратьРазрешенные);
    выборка = запрос.Выполнить().Выбрать();

    Если выборка.Следующий() Тогда
        ЗаполнитьЗначенияСвойств(структураПолей, выборка);
    КонецЕсли;

    Возврат структураПолей;
КонецФункции

// Параметры:
//	строкаРеквизитов - Строка - Список реквизитов вида: "Реквизит1, Реквизит2, ..."
// Возвращаемое значение:
//	Массив - Массив имен реквизитов
Функция КонвертироватьСтрокуРеквизитовВМассив(Знач строкаРеквизитов) Экспорт
    Если НЕ ЗначениеЗаполнено(строкаРеквизитов) Тогда
        Возврат Новый Массив;
    КонецЕсли;

    строкаРеквизитов = РаботаСоСтрокамиВызовСервера.ЗаменитьПоРегулярномуВыражению(строкаРеквизитов, "\s+", "");
    Если ПустаяСтрока(строкаРеквизитов) Тогда
        Возврат Новый Массив;
    КонецЕсли;

    Возврат СтрРазделить(строкаРеквизитов, ",", Ложь);
КонецФункции

// Параметры:
//  реквизиты - Строка, Массив, ФиксированныйМассив - Список имен реквизитов.
//            - Структура, ФиксированнаяСтруктура - Список реквизитов вида { Имя реквизита, Псевдоним реквизита }.
//
// Возвращаемое значение:
//  - Структура - Структура вида { Имя реквизита, Псевдоним реквизита }
//
Функция КонвертироватьРеквизитыВСтруктуру(Знач реквизиты) Экспорт
    контекстВыполнения = "РаботаСРеквизитами.КонвертироватьРеквизитыВСтруктуру";
    Если НЕ проверитьРеквизиты(реквизиты) Тогда
        ВызватьИсключение СтрШаблон(
            НСтр("ru = 'Неверный тип второго параметра %1 в функции %2: %3.'"),
            "Реквизиты", контекстВыполнения, Строка(ТипЗнч(реквизиты)));
    КонецЕсли;

    структураПолей = Новый Структура;

    Если ТипЗнч(реквизиты) = Тип("Строка") Тогда
        реквизиты = КонвертироватьСтрокуРеквизитовВМассив(реквизиты);
    КонецЕсли;

    Если реквизиты.Количество() = 0 Тогда
        Возврат структураПолей;
    КонецЕсли;

    Если ТипЗнч(реквизиты) = Тип("Структура") ИЛИ ТипЗнч(реквизиты) = Тип("ФиксированнаяСтруктура") Тогда
        Для Каждого элемент Из реквизиты Цикл
            структураПолей.Вставить(?(ЗначениеЗаполнено(элемент.Значение), элемент.Значение, элемент.Ключ),
                элемент.Ключ);
        КонецЦикла;

    Иначе
        Для Каждого реквизит Из реквизиты Цикл
            структураПолей.Вставить(реквизит, реквизит);
        КонецЦикла;
    КонецЕсли;

    Возврат структураПолей;
КонецФункции

#КонецОбласти // ПрограммныйИнтерфейс

#Область СлужебныйПрограммныйИнтерфейс

// Параметры:
//  структураПолей - Структура
//  псевдонимТаблицы - Строка, Неопределено - По умолчанию: "ПсевдонимЗаданнойТаблицы"
// Возвращаемое значение:
//  - Строка
Функция СформироватьТекстЗапросаПолейПоРеквизитам(Знач структураПолей, псевдонимТаблицы = Неопределено) Экспорт
    псевдонимТаблицы = ?(псевдонимТаблицы = Неопределено, "ПсевдонимЗаданнойТаблицы", псевдонимТаблицы);

    текстЗапросаПолей = "";
    Для Каждого ключИЗначение Из структураПолей Цикл
        имяПоля = ?(ЗначениеЗаполнено(ключИЗначение.Значение),
                ключИЗначение.Значение,
                ключИЗначение.Ключ);
        псевдонимПоля = ключИЗначение.Ключ;

        текстЗапросаПолей = СтрШаблон(
                "%1%2
                |	%3.%4 КАК %5",
                текстЗапросаПолей, ?(ПустаяСтрока(текстЗапросаПолей), "", ","),
                псевдонимТаблицы,
                имяПоля,
                псевдонимПоля);
    КонецЦикла;

    Возврат текстЗапросаПолей;
КонецФункции

#КонецОбласти // ПрограммныйИнтерфейс

#Область СлужебныйПрограммныйИнтерфейс

// Устарела. Не используется в текущей реализации
// Параметры:
//  проверенныеРеквизиты - Массив - Коллекция проверенных реквизитов
//  проверяемыеРеквизиты - Массив - Коллекция проверяемых реквизитов
Процедура ИсключитьПроверенныеРеквизиты(Знач проверенныеРеквизиты, Знач проверяемыеРеквизиты) Экспорт
    Для Каждого элементМассива Из проверенныеРеквизиты Цикл
        порядковыйНомер = проверяемыеРеквизиты.Найти(элементМассива);
        Если порядковыйНомер <> Неопределено Тогда
            проверяемыеРеквизиты.Удалить(порядковыйНомер);
        КонецЕсли;
    КонецЦикла;
КонецПроцедуры

Процедура ИсключитьПроверенныйРеквизит(Знач имяРеквизита, Знач проверяемыеРеквизиты) Экспорт
    индексЭлемента = проверяемыеРеквизиты.Найти(имяРеквизита);
    Если индексЭлемента >= 0 Тогда
        проверяемыеРеквизиты.Удалить(индексЭлемента);
    КонецЕсли;
КонецПроцедуры

#КонецОбласти // СлужебныйПрограммныйИнтерфейс

#Область СлужебныеПроцедурыИФункции

Функция проверитьРеквизиты(Знач реквизиты)
    типРеквизитов = ТипЗнч(реквизиты);
    реквизитыЭтоСтрока = типРеквизитов = Тип("Строка");
    реквизитыЭтоМассив = типРеквизитов = Тип("Массив") ИЛИ типРеквизитов = Тип("ФиксированныйМассив");
    реквизитыЭтоСтруктура = типРеквизитов = Тип("Структура") ИЛИ типРеквизитов = Тип("ФиксированнаяСтруктура");
    этоДопустимыйТипРеквизитов = реквизитыЭтоМассив ИЛИ реквизитыЭтоСтруктура ИЛИ реквизитыЭтоСтрока;

    Возврат этоДопустимыйТипРеквизитов;
КонецФункции

// Параметры:
//  полноеИмяОбъектаМетаданных - Строка
//  структураПолей - Структура
//  выбратьРазрешенные - Булево - если Истина, то запрос к объекту выполняется с учетом прав пользователя
// Возвращаемое значение:
//  - Строка
Функция сформироватьТекстЗапросаПоРеквизитам(Знач полноеИмяОбъектаМетаданных, Знач структураПолей, Знач выбратьРазрешенные = Ложь)
    текстЗапросаПолей = СформироватьТекстЗапросаПолейПоРеквизитам(структураПолей, "ПсевдонимЗаданнойТаблицы");
    текстЗапросаПолей = ?(ПустаяСтрока(текстЗапросаПолей), "*", текстЗапросаПолей);

    текстЗапроса =
        "ВЫБРАТЬ РАЗРЕШЕННЫЕ
        |&ТекстЗапросаПолей
        |ИЗ
        |	&ПолноеИмяОбъектаМетаданных КАК ПсевдонимЗаданнойТаблицы
        |ГДЕ
        |	ПсевдонимЗаданнойТаблицы.Ссылка = &Ссылка
        |";

    Если НЕ выбратьРазрешенные Тогда
        текстЗапроса = СтрЗаменить(текстЗапроса, "РАЗРЕШЕННЫЕ", "");
    КонецЕсли;

    текстЗапроса = СтрЗаменить(текстЗапроса, "&ТекстЗапросаПолей", текстЗапросаПолей);
    текстЗапроса = СтрЗаменить(текстЗапроса, "&ПолноеИмяОбъектаМетаданных", полноеИмяОбъектаМетаданных);

    Возврат текстЗапроса;
КонецФункции

#КонецОбласти // СлужебныеПроцедурыИФункции
