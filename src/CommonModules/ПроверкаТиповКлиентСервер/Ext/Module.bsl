﻿#Область ПрограммныйИнтерфейс

// Параметры:
//  объект - Произвольный, Тип
//  строго - Булево - По умолчанию: Истина
// Возвращаемое значение:
//  - Булево
Функция ЭтоМассив(Знач объект, Знач строго = Истина) Экспорт
    типОбъекта = ?(ТипЗнч(объект) = Тип("Тип"), объект, ТипЗнч(объект));
    Возврат типОбъекта = Тип("Массив") ИЛИ (НЕ строго И типОбъекта = Тип("ФиксированныйМассив"));
КонецФункции

// Параметры:
//  объект - Произвольный, Тип
//  строго - Булево - По умолчанию: Истина
// Возвращаемое значение:
//  - Булево
Функция ЭтоСтруктура(Знач объект, Знач строго = Истина) Экспорт
    типОбъекта = ?(ТипЗнч(объект) = Тип("Тип"), объект, ТипЗнч(объект));
    Возврат типОбъекта = Тип("Структура") ИЛИ (НЕ строго И типОбъекта = Тип("ФиксированнаяСтруктура"));
КонецФункции

// Параметры:
//  объект - Произвольный, Тип
//  строго - Булево - По умолчанию: Истина
// Возвращаемое значение:
//  - Булево
Функция ЭтоСоответствие(Знач объект, Знач строго = Истина) Экспорт
    типОбъекта = ?(ТипЗнч(объект) = Тип("Тип"), объект, ТипЗнч(объект));
    Возврат типОбъекта = Тип("Соответствие") ИЛИ (НЕ строго И типОбъекта = Тип("ФиксированноеСоответствие"));
КонецФункции

// Параметры:
//  объект - Произвольный, Тип
//  списокТипов - Массив, ФиксированныйМассив
// Возвращаемое значение:
//  - Булево
Функция ЭтоТипИзСписка(Знач объект, Знач списокТипов) Экспорт
    типОбъекта = ?(ТипЗнч(объект) = Тип("Тип"), объект, ТипЗнч(объект));
    Возврат списокТипов.Найти(типОбъекта) <> Неопределено;
КонецФункции

#КонецОбласти // ПрограммныйИнтерфейс
