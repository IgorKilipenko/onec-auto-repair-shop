﻿
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

		ТабДок.Вывести(ОбластьЗаголовок);

		Шапка.Параметры.Заполнить(Выборка);
		ТабДок.Вывести(Шапка, Выборка.Уровень());

		ТабДок.Вывести(ОбластьТоварыШапка);
		ВыборкаТовары = Выборка.Товары.Выбрать();
		Пока ВыборкаТовары.Следующий() Цикл
			ОбластьТовары.Параметры.Заполнить(ВыборкаТовары);
			ТабДок.Вывести(ОбластьТовары, ВыборкаТовары.Уровень());
		КонецЦикла;

		ТабДок.Вывести(ОбластьУслугиШапка);
		ВыборкаУслуги = Выборка.Услуги.Выбрать();
		Пока ВыборкаУслуги.Следующий() Цикл
			ОбластьУслуги.Параметры.Заполнить(ВыборкаУслуги);
			ТабДок.Вывести(ОбластьУслуги, ВыборкаУслуги.Уровень());
		КонецЦикла;

		ТабДок.Вывести(ОбластьМатериалыЗаказчикаШапка);
		ВыборкаМатериалыЗаказчика = Выборка.МатериалыЗаказчика.Выбрать();
		Пока ВыборкаМатериалыЗаказчика.Следующий() Цикл
			ОбластьМатериалыЗаказчика.Параметры.Заполнить(ВыборкаМатериалыЗаказчика);
			ТабДок.Вывести(ОбластьМатериалыЗаказчика, ВыборкаМатериалыЗаказчика.Уровень());
		КонецЦикла;

		Подвал.Параметры.Заполнить(Выборка);
		ТабДок.Вывести(Подвал);

		ВставлятьРазделительСтраниц = Истина;
	КонецЦикла;
	//}}
КонецПроцедуры
