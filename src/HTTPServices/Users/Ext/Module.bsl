﻿#Область СлужебныеПроцедурыИФункции

#Область User
#Область GET
Функция User_ПолучитьПользователя(запрос)
    имяПользователя = запрос.ПараметрыЗапроса.Получить("name");
    Если НЕ (ТипЗнч(имяПользователя) = Тип("Строка") И НЕ ПустаяСтрока(имяПользователя)) Тогда
        ответ = Новый HTTPСервисОтвет(400);
        телоОтвета = ЗаписатьЗначениеJSON(Новый Структура("Ошибка", "Не указано имя пользователя."));
        Возврат ответ;
    КонецЕсли;

    ответ = Новый HTTPСервисОтвет(200);

    пользовательБД = Справочники.Пользователи.НайтиПользователяПоИмени(имяПользователя);
    Если пользовательБД <> Неопределено Тогда
        пользовательБД.Вставить("Представление", Строка(пользовательБД.Ссылка));
        пользовательБД.Ссылка = Строка(пользовательБД.Ссылка.УникальныйИдентификатор());
    КонецЕсли;

    структураТелаОтвета = Новый Структура("Пользователь", пользовательБД);
    телоОтвета = ЗаписатьЗначениеJSON(структураТелаОтвета);

    ответ.УстановитьТелоИзСтроки(телоОтвета);
    ответ.Заголовки.Вставить("Content-type", "application/json");

    Возврат ответ;
КонецФункции
#КонецОбласти // GET
#КонецОбласти // User

#КонецОбласти // СлужебныеПроцедурыИФункции
