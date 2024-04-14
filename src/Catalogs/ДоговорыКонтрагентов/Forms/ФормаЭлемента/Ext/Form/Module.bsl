﻿#Область ОписаниеПеременных

// Содержит массив ссылок полей формы доступных только для СрочногоДоговора (Только для чтения)
&НаКлиенте
Перем _ПоляТолькоДляСрочногоДоговора;

#КонецОбласти // ОписаниеПеременных

#Область ОбработчикиСобытийФормы

&НаКлиенте
Процедура ПриОткрытии(_)
    инициализация();
    установитьВидимостьЭлементовФормы();
КонецПроцедуры

&НаКлиенте
Процедура ПередЗаписью(отказ, __)
    заполнитьПолеНаименованияДоговора();
    Если этоБессрочныйДоговор() И ЗначениеЗаполнено(Объект.ДатаОкончания) Тогда
        очиститьПоляСрочногоДоговора();
    Иначе
        сообщение = проверкаЗаполненияДатыОкончанияДоговора();
        Если сообщение <> Неопределено Тогда
            сообщение.Сообщить();
            отказ = Истина;
        КонецЕсли;
    КонецЕсли;
КонецПроцедуры

#КонецОбласти // ОбработчикиСобытий

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ПризнакБессрочногоДоговораПриИзменении(_)
    установитьВидимостьЭлементовФормы();
КонецПроцедуры

&НаКлиенте
Процедура ДатаНачалаДоговораПриИзменении(_)
    заполнитьПолеНаименованияДоговора();
КонецПроцедуры

&НаКлиенте
Процедура НомерДоговораПриИзменении(_)
    заполнитьПолеНаименованияДоговора();
КонецПроцедуры

#КонецОбласти // ОбработчикиСобытийЭлементовШапкиФормы

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура инициализация()
    _ПоляТолькоДляСрочногоДоговора = Новый Массив;
    _ПоляТолькоДляСрочногоДоговора.Добавить(Элементы.ДатаОкончания);
КонецПроцедуры

// Устанавливает видимость для полей формы заполняемых в зависимости
// от признака бессрочности договора
&НаКлиенте
Процедура установитьВидимостьЭлементовФормы()
    этоСрочныйДоговор = НЕ этоБессрочныйДоговор();
    ЭтотОбъект.Элементы.ДатаОкончания.Видимость = этоСрочныйДоговор;
    ЭтотОбъект.Элементы.ДатаОкончания.АвтоОтметкаНезаполненного = этоСрочныйДоговор;
КонецПроцедуры

// Заполняет поле формы - НаименованиеДоговора по указанным в форме данным номера и даты договора
&НаКлиенте
Процедура заполнитьПолеНаименованияДоговора()
    ЭтотОбъект.Объект.Наименование = сформироватьСтрокуНаименованияДоговора(ЭтотОбъект.Объект.Номер,
            ЭтотОбъект.Объект.ДатаНачала);
КонецПроцедуры

// Параметры:
//  коллекцияПолейФормы - КоллекцияПолейФормы - коллекция объектов полей формы
&НаКлиенте
Процедура очиститьПоля(коллекцияПолейФормы)
    Для Каждого поле Из коллекцияПолейФормы Цикл
        Если (ТипЗнч(поле) = Тип("ТаблицаФормы")) И (ТипЗнч(Объект[поле.Имя]) =
                Тип("ДанныеФормыКоллекция")) Тогда
            ЭтотОбъект.Объект[поле.Имя].Очистить();
        Иначе
            ЭтотОбъект.Объект[поле.Имя] = Неопределено;
        КонецЕсли;
    КонецЦикла;
КонецПроцедуры

// Выполняет очистку значений полей формы используемых только для СрочногоДоговора
&НаКлиенте
Процедура очиститьПоляСрочногоДоговора()
    очиститьПоля(_ПоляТолькоДляСрочногоДоговора);
КонецПроцедуры

// Формирует строку наименования договора / вида: №договора от датаДоговора.
// Параметры:
//  номерДоговора - Строка - Номер договора
//  датаНачала - Дата - Дата заключения договора
// Возвращаемое значение:
//  Строка - наименования договора (прим. №123 от 12.05.2022 г)
&НаКлиенте
Функция сформироватьСтрокуНаименованияДоговора(Знач номерДоговора, Знач датаНачала)
    номерДоговораЗаполнен = ЗначениеЗаполнено(номерДоговора);
    датаДоговораЗаполнен = ЗначениеЗаполнено(датаНачала);

    Если НЕ номерДоговораЗаполнен Тогда
        Возврат "";
    КонецЕсли;

    номерДоговора = РаботаСоСтрокамиВызовСервера.ЗаменитьПоРегулярномуВыражению(
            номерДоговора, "^\s+|\s+$", "");
    номерДоговора = РаботаСоСтрокамиВызовСервера.ЗаменитьПоРегулярномуВыражению(
            номерДоговора, "^\D+(?=[0-9]+)", "");

    Возврат ?(НЕ датаДоговораЗаполнен, номерДоговора,
        СтрШаблон("№%1 от %2 г.", номерДоговора, Формат(датаНачала, "Л=ru_RU; ДФ=дд.MM.гггг")));
КонецФункции

&НаКлиенте
Функция этоБессрочныйДоговор()
    Возврат ЭтотОбъект.Объект.Бессрочный;
КонецФункции

// Выполняет проверку заполнения поля ДатаОкончания. \
// Если поле ДатаОкончания не прошло проверку - генерирует сообщение пользователю
// Параметры:
//   принудительно - Булево - Если Ложь проверка выполняется только для объекта с признаком БессрочностиДоговора
// Возвращаемое значение:
//   СообщениеПользователю - Если Неопределено - проверка прошла успешно, иначе возвращает сообщение с текстом ошибки проверки
&НаКлиенте
Функция проверкаЗаполненияДатыОкончанияДоговора(Знач принудительно = Ложь)
    этоСрочныйДоговор = НЕ этоБессрочныйДоговор();

    Если (принудительно ИЛИ этоСрочныйДоговор) И (НЕ ЗначениеЗаполнено(Объект.ДатаОкончания)) Тогда
        сообщение = Новый СообщениеПользователю();
        сообщение.Текст = "Поле ""дата окончания договора"" не заполнено";
        сообщение.Поле = Элементы.ДатаОкончания.Имя;
        сообщение.КлючДанных = Объект.Ссылка;
        сообщение.ПутьКДанным = "Объект";

        Возврат сообщение;
    КонецЕсли;

    Возврат Неопределено;
КонецФункции

#КонецОбласти // СлужебныеПроцедурыИФункции
