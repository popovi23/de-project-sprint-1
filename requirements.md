# Витрина RFM

## 1.1. Выясните требования к целевой витрине.

	Присвойте каждому клиенту три значения — значение фактора Recency, значение фактора Frequency и значение фактора Monetary Value:
	- Фактор Recency измеряется по последнему заказу. Распределите клиентов по шкале от одного до пяти, где значение 1 получат те, кто либо вообще не делал заказов, либо делал их очень давно, а 5 — те, кто заказывал относительно недавно.
	- Фактор Frequency оценивается по количеству заказов. Распределите клиентов по шкале от одного до пяти, где значение 1 получат клиенты с наименьшим количеством заказов, а 5 — с наибольшим.
	- Фактор Monetary Value оценивается по потраченной сумме. Распределите клиентов по шкале от одного до пяти, где значение 1 получат клиенты с наименьшей суммой, а 5 — с наибольшей.

**Проверки и условия:**
    - Проверьте, что количество клиентов в каждом сегменте одинаково. Например, если в базе всего 100 клиентов, то 20 клиентов должны получить значение 1, ещё 20 — значение 2 и т. д.
    - Для анализа нужно отобрать только выполненные заказы со статусом Closed.
    - При расчете витрины обращаться только к объектам из схемы analysis. Чтобы не дублировать данные (данные находятся в этой же базе), создаем view. View будут в схеме analysis и будут смотреть данные из схемы production. 

**Где хранятся данные:**
в схеме production.

**Куда надо сохранить витрину:**
витрина должна располагаться в той же базе в схеме analysis.

**Стуктура витрины:**
витрина должна называться dm_rfm_segments и состоять из следующих полей:
	- user_id
	- recency (число от 1 до 5)
	- frequency (число от 1 до 5)
	- monetary_value (число от 1 до 5)
**Глубина данных:** в витрине нужны данные с начала 2022 года.

**Обновления данных**
не требуется



## 1.2. Изучите структуру исходных данных.

Данные будут браться из схемы production, следующих таблиц и соответствующих столбцов:
- Таблица users. Используемые поля: 
    id(тип int4) - идентификатор пользователя

- Таблица orderstatuses. Используемые поля: 
    id(тип int4) - идентификатор статуса заказа
    key(тип varchar(255)) - значение ключа статуса

- Таблица orders. Используемые поля:
    user_id(тип int4) - идентификатор пользоавтеля
    order_ts(тип timestamp) - дата и время заказа
    payment(numeric(19,5)) - сумма оплаты по заказу


## 1.3. Проанализируйте качество данных

| Таблицы             | Объект                      | Инструмент      | Для чего используется |
| ------------------- | --------------------------- | --------------- | --------------------- |
| production.users    | id int4 NOT NULL PRIMARY KEY | Первичный ключ  | Обеспечивает уникальность записей о пользователях |
| production.orderstatuses | id int4 NOT NULL PRIMARY KEY | Первичный ключ  | Обеспечивает уникальность записей о пользователях |
| production.orderstatuses | key varchar(255) NOT NULL | NOT NULL  | Обеспечивает отсутствие пустых значений поля ключа статуса заказа |
| production.orders   | id int4 NOT NULL PRIMARY KEY | Первичный ключ  | Обеспечивает уникальность записей о заказах |
| production.orders   | status varchar(255) NOT NULL | NOT NULL  | Обеспечивает отсутствие пустых значений поля ключа статуса заказа |
| production.orders   | user_id int4 NOT NULL | NOT NULL  | Обеспечивает отсутствие пустых значений поля идентификатора пользователя |
| production.orders   | order_ts timestamp NOT NULL | NOT NULL  | Обеспечивает отсутствие пустых значений поля даты заказа |

**Таблицы users и orderstatuses.**

Нареканий по качеству данных нет. 

**Таблица orders.**

Нареканий по качеству имеющихся данных нет. Возможные источники появления проблем:
 - отсутствие проверки поля payment на значение больше 0;
 - отсутствие внешнего ключа, для поля  user_id.


## 1.4. Подготовьте витрину данных

### 1.4.1. Сделайте VIEW для таблиц из базы production.**

```SQL

CREATE OR REPLACE VIEW analysis.orderitems AS
SELECT * FROM production.orderitems;

CREATE OR REPLACE VIEW analysis.orders AS
SELECT * FROM production.orders;

CREATE OR REPLACE VIEW analysis.orderstatuses AS
SELECT * FROM production.orderstatuses;

CREATE OR REPLACE VIEW analysis.orderstatuslog AS
SELECT * FROM production.orderstatuslog;

CREATE OR REPLACE VIEW analysis.products AS
SELECT * FROM production.products;

CREATE OR REPLACE VIEW analysis.users AS
SELECT * FROM production.users;

```

### 1.4.2. Напишите DDL-запрос для создания витрины.**
  
```SQL 

CREAT TABLE analysis.dm_rfm_segments (
	user_id int NOT NULL PRIMARY KEY,
    recency int NOT NULL CHECK(recency >= 1 AND recency <= 5)
	frequency int NOT NULL CHECK(frequency >= 1 AND frequency <= 5)
	monetary_value int NOT NULL CHECK(monetary_value >= 1 AND monetary_value <= 5)
);

```

### 1.4.3. Напишите SQL запрос для заполнения витрины

Наконец, реализуйте расчет витрины на языке SQL и заполните таблицу, созданную в предыдущем пункте.

Для решения предоставьте код запроса.

```SQL

INSERT INTO analysis.dm_rfm_segments(user_id,recency,frequency,monetary_value)
SELECT u.id AS "user_id",
         r.recency,
         f.frequency,
         m.monetary_value
FROM analysis.tmp_rfm_frequency f, analysis.tmp_rfm_recency r, analysis.tmp_rfm_monetary_value m, analysis.users u
WHERE u.id = r.user_id
        AND u.id=m.user_id
        AND u.id=f.user_id


```