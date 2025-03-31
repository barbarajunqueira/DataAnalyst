-- Nivell 1 Exercici 1
CREATE TABLE credit_card (
	id VARCHAR(255) PRIMARY KEY, 
    iban VARCHAR(255), 
    pan VARCHAR(255), 
    pin VARCHAR(255), 
    cvv VARCHAR(255), 
    expiring_date DATE
);

ALTER TABLE transaction
ADD FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);

SELECT *
from credit_card;

-- Nivell 1 Exercici 2
select *
from credit_card
where id = "CcU-2938";

UPDATE credit_card
SET iban = "R323456312213576817699999"
WHERE id = "CcU-2938";

select *
from credit_card
where id = "CcU-2938";

-- Nivel 1 Exercici 3
SELECT * 
FROM company
WHERE id = "b-9999";

INSERT INTO company (id)
VALUES ("b-9999");

SELECT * 
FROM company
WHERE id = "b-9999";

SELECT * 
FROM credit_card
WHERE id = "CcU-9999";

INSERT INTO credit_card(id)
VALUES ("CcU-9999");

SELECT * 
FROM credit_card
WHERE id = "CcU-9999";

INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
VALUES ("108B1D1D-5B23-A76C-55EF-C568E49A99DD", "CcU-9999", "b-9999", 9999, 829.999, 117.999, 111.11, 0);

SELECT * 
FROM transaction
WHERE id = "108B1D1D-5B23-A76C-55EF-C568E49A99DD";

-- Nivell 1 Exercici 4
ALTER TABLE credit_card
DROP COLUMN pan;

SELECT * from credit_card;

-- Nivell 2 Exercici 1
DELETE FROM transaction
WHERE id = "02C6201E-D90A-1859-B4EE-88D2986D3B02";

SELECT *
FROM transaction
WHERE id = "02C6201E-D90A-1859-B4EE-88D2986D3B02";

drop view VistaMarketing;

-- Nivell 2 Exercici 2
CREATE VIEW VistaMarketing AS
SELECT company_name as nomCompanya, phone as telefon, country as pais, round(avg(amount), 2) as avgPerCompanya
FROM company c
JOIN transaction t
WHERE c.id = t.company_id
GROUP BY c.id
ORDER BY avgPerCompanya;

SELECT *
FROM vistamarketing;

-- Nivell 2 Exercici 3
SELECT *
FROM vistamarketing
WHERE pais = "Germany";

-- Nivell 3 Exercici 1
-- alterando tabla credit_card

SHOW CREATE TABLE transaction;
ALTER TABLE transaction DROP FOREIGN KEY transaction_ibfk_5;

ALTER TABLE credit_card
MODIFY COLUMN id VARCHAR(20),
MODIFY COLUMN iban VARCHAR(50),
MODIFY COLUMN cvv INT,
MODIFY COLUMN pin VARCHAR(4),
MODIFY COLUMN expiring_date VARCHAR(20),
ADD COLUMN fecha_actual DATE;

ALTER TABLE transaction
ADD FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);

-- deletando columna webpage de company
ALTER TABLE company
DROP COLUMN website;

-- adicionando tabla data_user
CREATE INDEX idx_user_id ON transaction(user_id);
 
CREATE TABLE IF NOT EXISTS user (
        id INT PRIMARY KEY,
        name VARCHAR(100),
        surname VARCHAR(100),
        phone VARCHAR(150),
        email VARCHAR(150),
        birth_date VARCHAR(100),
        country VARCHAR(150),
        city VARCHAR(150),
        postal_code VARCHAR(100),
        address VARCHAR(255)
    );

SELECT * FROM user
WHERE id="9999";

ALTER TABLE transaction
ADD FOREIGN KEY (user_id) REFERENCES user(id);

ALTER TABLE user RENAME TO data_user;

ALTER TABLE data_user 
CHANGE COLUMN email personal_email VARCHAR(150);

SELECT * FROM data_user;

-- alterando tabla 

-- Nivell 3 Exercici 2
CREATE VIEW informetecnico AS
SELECT t.id as idTransaccio, u.name as nomUsuari, u.surname as cognomUsuari, cc.iban as iban, c.company_name as nomCompanya 
FROM transaction t
JOIN company c ON c.id = t.company_id
JOIN credit_card cc ON cc.id = t.credit_card_id
JOIN data_user u ON u.id = t.user_id;

SELECT *
FROM informetecnico
ORDER BY idTransaccio DESC;


