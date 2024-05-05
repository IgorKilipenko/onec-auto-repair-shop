﻿#Область ОбработчикиСобытий

#Область Order
#Область POST
Функция Заказ_СоздатьЗаказ(Знач запрос)
    телоОтвета = Новый Структура("Успех, ИдентификаторДокумента, Сообщение", Истина);
    ответ = Новый HTTPСервисОтвет(200);
    ответ.Заголовки.Вставить("Content-type", "application/json");

    строкаТелаЗапроса = запрос.ПолучитьТелоКакСтроку();
    структураТелаЗапроса = ПрочитатьЗначениеJSON(?(ПустаяСтрока(строкаТелаЗапроса), "{}", строкаТелаЗапроса));
    результатПроверки = проверитьЗаполнениеТелаЗапросаСозданияЗаказа(структураТелаЗапроса);
    Если результатПроверки.Успех = Ложь Тогда
        ответ.КодСостояния = 400;
        телоОтвета.Успех = Ложь;
        телоОтвета.Сообщение = результатПроверки.Сообщение;
        ответ.УстановитьТелоИзСтроки(ЗаписатьЗначениеJSON(телоОтвета));

        Возврат ответ;
    КонецЕсли;

    Если структураТелаЗапроса.Услуги.Количество() = 0 Тогда
        телоОтвета.Успех = Ложь;
        телоОтвета.Сообщение = "Не указаны услуги заказа.";
        ответ.УстановитьТелоИзСтроки(ЗаписатьЗначениеJSON(телоОтвета));

        Возврат ответ;
    КонецЕсли;

    пользовательПриложения = Справочники.Пользователи.НайтиПользователяПриложения(
        структураТелаЗапроса.ИдентификаторПользователя, Истина);
    Если пользовательПриложения = Неопределено Тогда // Пользователь не найден
        телоОтвета.Успех = Ложь;
        телоОтвета.Сообщение = "Пользователь не зарегистрирован.";

    Иначе // Создание нового заказа
        новыйДокументЗаказНаряд = Документы.ЗаказНаряд.СоздатьДокумент();
        новыйДокументЗаказНаряд.Дата = ТекущаяДатаСеанса();
        новыйДокументЗаказНаряд.ДатаЗаписи = ПрочитатьДатуJSON(структураТелаЗапроса.ДатаЗаписи, ФорматДатыJSON.ISO);
        новыйДокументЗаказНаряд.Клиент = пользовательПриложения.Клиент;

        доступныеДляЗаказаУслуги = Неопределено;
        Попытка
            доступныеДляЗаказаУслуги = получитьУслугиЗаказа(структураТелаЗапроса.Услуги);
        Исключение
            телоОтвета.Успех = Ложь;
            телоОтвета.Сообщение = "Ошибка при получении списка услуг.";
            ответ.УстановитьТелоИзСтроки(ЗаписатьЗначениеJSON(телоОтвета));

            Возврат ответ;  // Ошибка списка услуг
        КонецПопытки;

        // Если все услуги из записи клиента отсутствуют в справочнике Номенклатура
        Если доступныеДляЗаказаУслуги.Количество() = 0 Тогда
            телоОтвета.Успех = Ложь;
            телоОтвета.Сообщение = "Отсутствуют доступные для записи услуги.";
            ответ.УстановитьТелоИзСтроки(ЗаписатьЗначениеJSON(телоОтвета));

            Возврат ответ;  // Ошибка списка услуг
        КонецЕсли;

        общаяСтоимостьУслуг = 0;
        Для каждого строкаУслугЗаказаПользователя Из доступныеДляЗаказаУслуги Цикл
            новаяСтрокаУслуг = новыйДокументЗаказНаряд.Услуги.Добавить();
            новаяСтрокаУслуг.Номенклатура = строкаУслугЗаказаПользователя.Ссылка;
            новаяСтрокаУслуг.Количество = строкаУслугЗаказаПользователя.Количество;
            новаяСтрокаУслуг.Цена = строкаУслугЗаказаПользователя.Цена;
            новаяСтрокаУслуг.Сумма = новаяСтрокаУслуг.Количество * новаяСтрокаУслуг.Цена;

            общаяСтоимостьУслуг = общаяСтоимостьУслуг + новаяСтрокаУслуг.Сумма;
        КонецЦикла;
        новыйДокументЗаказНаряд.СуммаДокумента = общаяСтоимостьУслуг;

        Попытка
            новыйДокументЗаказНаряд.Записать(РежимЗаписиДокумента.Проведение, РежимПроведенияДокумента.Неоперативный);
            телоОтвета.ИдентификаторДокумента = Строка(новыйДокументЗаказНаряд.Ссылка.УникальныйИдентификатор());
        Исключение
            телоОтвета.Успех = Ложь;
            телоОтвета.Сообщение = "Ошибка создания документа заказа.";
        КонецПопытки;
    КонецЕсли;

    ответ.УстановитьТелоИзСтроки(ЗаписатьЗначениеJSON(телоОтвета));
    Возврат ответ;
КонецФункции
#КонецОбласти // POST
#КонецОбласти // Order

#КонецОбласти // СлужебныеПроцедурыИФункции

#Область СлужебныеПроцедурыИФункции

Функция проверитьЗаполнениеТелаЗапросаСозданияЗаказа(Знач структураТелаЗапроса)
    результат = Новый Структура("Успех, Сообщение", Ложь);

    Если ПроверкаТиповКлиентСервер.ЭтоСтруктура(структураТелаЗапроса, Ложь) = Ложь
        ИЛИ ЗначениеЗаполнено(структураТелаЗапроса) = Ложь Тогда
        результат.Сообщение = "В запросе отсутствуют необходимые данные для создания заказа.";

        Возврат результат;
    КонецЕсли;

    обязательныеПоля = Новый Массив;
    ключиОбязательногоПоля = "Имя, Сообщение, Тип";
    обязательныеПоля.Добавить(Новый Структура(ключиОбязательногоПоля, "ИдентификаторПользователя",
            "Не указан идентификатор пользователя для создания заказа.", Тип("Строка")));
    обязательныеПоля.Добавить(Новый Структура(ключиОбязательногоПоля, "ДатаЗаписи", "Не указана дата записи.", Тип("Строка")));
    обязательныеПоля.Добавить(Новый Структура(ключиОбязательногоПоля, "Услуги", "Не указан список услуг заказа.", Тип("Массив")));

    Для каждого поле Из обязательныеПоля Цикл
        значениеПоля = Неопределено;
        Если структураТелаЗапроса.Свойство(поле.Имя, значениеПоля) = Ложь
            ИЛИ ТипЗнч(значениеПоля) <> поле.Тип
            ИЛИ ЗначениеЗаполнено(значениеПоля) = Ложь Тогда

            результат.Сообщение = поле.Сообщение;
            Возврат результат;
        КонецЕсли;
    КонецЦикла;

    результат.Успех = Истина;
    Возврат результат;
КонецФункции

Функция создатьДокументЗаказНаряд(Знач наименование, Знач телефон)
    новыйКлиент = Справочники.Контрагенты.СоздатьЭлемент();
    новыйКлиент.Наименование = наименование;
    новыйКлиент.КонтактныйТелефон = телефон;
    новыйКлиент.ТипКонтрагента = Перечисления.ТипыКонтрагентов.Покупатель;
    новыйКлиент.Записать();

    Возврат новыйКлиент;
КонецФункции

Функция получитьУслугиЗаказа(Знач услугиЗаказаКлиента)
    таблицаУслугЗаписиКлиента = Новый ТаблицаЗначений;
    таблицаУслугЗаписиКлиента.Колонки.Добавить("Наименование", Новый ОписаниеТипов("Строка", , , , Новый КвалификаторыСтроки(100)));
    таблицаУслугЗаписиКлиента.Колонки.Добавить("Стоимость", Новый ОписаниеТипов("Число"));
    таблицаУслугЗаписиКлиента.Колонки.Добавить("Количество", Новый ОписаниеТипов("Число"));

    Для каждого строкаУслуг Из услугиЗаказаКлиента Цикл
        новаяСтрока = таблицаУслугЗаписиКлиента.Добавить();
        ЗаполнитьЗначенияСвойств(новаяСтрока, строкаУслуг);
    КонецЦикла;

    запрос = Новый Запрос;
    запрос.Текст =
        "ВЫБРАТЬ
        |	ТаблицаУслугЗаписиКлиента.Наименование КАК Наименование,
        |	ТаблицаУслугЗаписиКлиента.Стоимость КАК Стоимость,
        |	ТаблицаУслугЗаписиКлиента.Количество КАК Количество
        |ПОМЕСТИТЬ ВТ_ТаблицаУслугЗаписиКлиента
        |ИЗ
        |	&ТаблицаУслугЗаписиКлиента КАК ТаблицаУслугЗаписиКлиента
        |
        |ИНДЕКСИРОВАТЬ ПО
        |	Наименование
        |;
        |
        |////////////////////////////////////////////////////////////////////////////////
        |ВЫБРАТЬ
        |	МАКСИМУМ(Услуги.Ссылка) КАК Ссылка,
        |	Услуги.Наименование КАК Наименование
        |ПОМЕСТИТЬ ВТ_Услуги
        |ИЗ
        |	Справочник.Номенклатура КАК Услуги
        |ГДЕ
        |	Услуги.ПометкаУдаления = ЛОЖЬ
        |	И Услуги.ТипНоменклатуры = ЗНАЧЕНИЕ(Перечисление.ТипыНоменклатуры.Услуга)
        |	И Услуги.Наименование В
        |			(ВЫБРАТЬ
        |				ВТ_ТаблицаУслугЗаписиКлиента.Наименование
        |			ИЗ
        |				ВТ_ТаблицаУслугЗаписиКлиента)
        |
        |СГРУППИРОВАТЬ ПО
        |	Услуги.Наименование
        |;
        |
        |////////////////////////////////////////////////////////////////////////////////
        |ВЫБРАТЬ
        |	ВТ_Услуги.Ссылка КАК Ссылка,
        |	ВТ_ТаблицаУслугЗаписиКлиента.Наименование КАК Наименование,
        |	ВТ_ТаблицаУслугЗаписиКлиента.Стоимость КАК Цена,
        |	ВТ_ТаблицаУслугЗаписиКлиента.Количество КАК Количество
        |ИЗ
        |	ВТ_ТаблицаУслугЗаписиКлиента КАК ВТ_ТаблицаУслугЗаписиКлиента
        |		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_Услуги КАК ВТ_Услуги
        |		ПО (ВТ_Услуги.Наименование = ВТ_ТаблицаУслугЗаписиКлиента.Наименование)
        |";

    запрос.УстановитьПараметр("ТаблицаУслугЗаписиКлиента", таблицаУслугЗаписиКлиента);
    Возврат запрос.Выполнить().Выгрузить();
КонецФункции

#КонецОбласти // СлужебныеПроцедурыИФункции
