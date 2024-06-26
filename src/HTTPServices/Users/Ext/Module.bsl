﻿#Область ОбработчикиСобытий

#Область User
#Область GET
Функция User_ПолучитьПользователя(Знач запрос)
    телоОтвета = Новый Структура("Успех, Пользователь, Сообщение", Истина);
    ответ = Новый HTTPСервисОтвет(200);
    ответ.Заголовки.Вставить("Content-type", "application/json");

    имяПользователя = запрос.ПараметрыЗапроса.Получить("name");
    Если ТипЗнч(имяПользователя) <> Тип("Строка") ИЛИ ПустаяСтрока(имяПользователя) Тогда
        ответ.КодСостояния = 400;
        телоОтвета.Сообщение = "Не указано имя пользователя.";
        ответ.УстановитьТелоИзСтроки(ЗаписатьЗначениеJSON(телоОтвета));

        Возврат ответ;
    КонецЕсли;

    пользовательПриложения = Справочники.Пользователи.НайтиПользователяПриложения(имяПользователя);
    Если пользовательПриложения = Неопределено Тогда
        телоОтвета.Успех = Ложь;
        телоОтвета.Сообщение = "Пользователь не найден.";
    КонецЕсли;

    Если пользовательПриложения <> Неопределено Тогда
        телоОтвета.Пользователь = Новый Структура("Имя, УникальныйИдентификатор",
                пользовательПриложения.Имя, пользовательПриложения.УникальныйИдентификатор);
    КонецЕсли;

    ответ.УстановитьТелоИзСтроки(ЗаписатьЗначениеJSON(телоОтвета));
    Возврат ответ;
КонецФункции
#КонецОбласти // GET

#Область POST
Функция User_СоздатьПользователя(Знач запрос)
    телоОтвета = Новый Структура("Успех, Пользователь, Сообщение", Истина);
    ответ = Новый HTTPСервисОтвет(200);
    ответ.Заголовки.Вставить("Content-type", "application/json");

    структураТелаЗапроса = ПрочитатьЗначениеJSON(запрос.ПолучитьТелоКакСтроку());
    результатПроверки = проверитьЗаполнениеТелаЗапросаСозданияПользователя(структураТелаЗапроса);
    Если результатПроверки.Успех = Ложь Тогда
        ответ.КодСостояния = 400;
        телоОтвета.Успех = Ложь;
        телоОтвета.Сообщение = результатПроверки.Сообщение;
        ответ.УстановитьТелоИзСтроки(ЗаписатьЗначениеJSON(телоОтвета));

        Возврат ответ;
    КонецЕсли;

    имяПользователя = структураТелаЗапроса.name;
    пользовательПриложения = Справочники.Пользователи.НайтиПользователяПриложения(имяПользователя);
    Если пользовательПриложения <> Неопределено Тогда // Пользователь существует
        телоОтвета.Успех = Ложь;
        телоОтвета.Сообщение = СтрШаблон(
                "Неправильное имя пользователя. Пользователь с именем ""%1"" уже существует в базе.",
                имяПользователя);

    Иначе // Создание нового пользователя
        новыйПользователь = Справочники.Пользователи.СоздатьПользователяПриложения(имяПользователя, Истина);
        пользовательПриложения = Новый Структура;
        пользовательПриложения.Вставить("Имя", новыйПользователь.Наименование);
        пользовательПриложения.Вставить("УникальныйИдентификатор", новыйПользователь.Код);

        // Создание нового клиента связанного с пользователем
        новыйКлиент = создатьКлиента(имяПользователя, структураТелаЗапроса.phone);
        ДиагностикаКлиентСервер.Утверждение(ЗначениеЗаполнено(новыйКлиент.Ссылка));
        новыйПользователь.Клиент = новыйКлиент.Ссылка;
        новыйПользователь.Записать();
    КонецЕсли;

    Если пользовательПриложения <> Неопределено Тогда
        телоОтвета.Пользователь = Новый Структура("Имя, УникальныйИдентификатор",
                пользовательПриложения.Имя, пользовательПриложения.УникальныйИдентификатор);
    КонецЕсли;

    ответ.УстановитьТелоИзСтроки(ЗаписатьЗначениеJSON(телоОтвета));
    Возврат ответ;
КонецФункции
#КонецОбласти // POST
#КонецОбласти // User

#КонецОбласти // ОбработчикиСобытий

#Область СлужебныеПроцедурыИФункции

Функция проверитьЗаполнениеТелаЗапросаСозданияПользователя(Знач структураТелаЗапроса)
    результат = Новый Структура("Успех, Сообщение", Ложь);

    Если ПроверкаТиповКлиентСервер.ЭтоСтруктура(структураТелаЗапроса, Ложь) = Ложь
        ИЛИ ЗначениеЗаполнено(структураТелаЗапроса) = Ложь Тогда
        результат.Сообщение = "В запросе отсутствуют необходимые данные для создания пользователя.";
        Возврат результат;
    КонецЕсли;

    имяПользователя = Неопределено;
    Если структураТелаЗапроса.Свойство("name", имяПользователя) = Ложь
        ИЛИ ТипЗнч(имяПользователя) <> Тип("Строка")
        ИЛИ ПустаяСтрока(имяПользователя) Тогда
        результат.Сообщение = "Не указано имя пользователя.";
        Возврат результат;
    КонецЕсли;

    телефонПользователя = Неопределено;
    Если структураТелаЗапроса.Свойство("phone", телефонПользователя) = Ложь
        ИЛИ ТипЗнч(телефонПользователя) <> Тип("Строка")
        ИЛИ ПустаяСтрока(телефонПользователя) Тогда
        результат.Сообщение = "Не указан контактный телефон пользователя.";
        Возврат результат;
    КонецЕсли;

    результат.Успех = Истина;
    Возврат результат;
КонецФункции

Функция создатьКлиента(Знач наименование, Знач телефон)
    новыйКлиент = Справочники.Контрагенты.СоздатьЭлемент();
    новыйКлиент.Наименование = наименование;
    новыйКлиент.КонтактныйТелефон = телефон;
    новыйКлиент.ТипКонтрагента = Перечисления.ТипыКонтрагентов.Покупатель;
    новыйКлиент.Комментарий = "Контрагент зарегистрирован через мобильное приложение";
    новыйКлиент.Записать();

    Возврат новыйКлиент;
КонецФункции

#КонецОбласти // СлужебныеПроцедурыИФункции
