﻿#Область ПрограммныйИнтерфейс

// Устарела. Не используется в текущей реализации
// Параметры:
//  документСсылка - ДокументСсылка.НачислениеЗарплаты
//  менеджер - МенеджерВременныхТаблиц, Неопределено - Если задан `МенеджерВременныхТаблиц` результата
//      будет помещен в `ВТ_НачислениеЗарплатыНачисления`
// Возвращаемое значение:
//  - ТаблицаЗначений - Если `МенеджерВременныхТаблиц` = Неопределено
//  - МенеджерВременныхТаблиц - Результат в `ВТ_НачислениеЗарплатыНачисления`
Функция ПолучитьНачисленияДокумента(Знач документСсылка, менеджер = Неопределено) Экспорт
    запрос = Новый Запрос;
    запрос.МенеджерВременныхТаблиц = ?(менеджер = Неопределено, Новый МенеджерВременныхТаблиц, менеджер);
    запрос.Текст =
        "ВЫБРАТЬ
        |   НачислениеЗарплатыНачисления.Сотрудник КАК Сотрудник,
        |   НачислениеЗарплатыНачисления.ГрафикРаботы КАК ГрафикРаботы,
        |   НачислениеЗарплатыНачисления.ВидРасчета КАК ВидРасчета,
        |   НачислениеЗарплатыНачисления.ДатаНачала КАК ДатаНачала,
        |   НачислениеЗарплатыНачисления.ДатаОкончания КАК ДатаОкончания,
        |   НачислениеЗарплатыНачисления.ПоказательРасчета КАК ПоказательРасчета
        |ПОМЕСТИТЬ ВТ_НачислениеЗарплатыНачисления
        |ИЗ
        |   Документ.НачислениеЗарплаты.Начисления КАК НачислениеЗарплатыНачисления
        |ГДЕ
        |   НачислениеЗарплатыНачисления.Ссылка = &Ссылка
        |";

    запрос.УстановитьПараметр("Ссылка", документСсылка);

    результатЗапроса = запрос.Выполнить();

    Если менеджер <> Неопределено Тогда // Если нужно только создать временную таблицу
        Возврат запрос.МенеджерВременныхТаблиц;
    Иначе
        запрос.Текст = СтрЗаменитьПоРегулярномуВыражению(запрос.Текст, "(?m)^ПОМЕСТИТЬ ВТ_НачислениеЗарплатыНачисления", "");
    КонецЕсли;

    Возврат результатЗапроса.выгрузить();
КонецФункции

#КонецОбласти // ПрограммныйИнтерфейс
