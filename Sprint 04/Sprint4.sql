CREATE DATABASE sprint4;

-- Creando, importando y haciendo el check de la creacion de 
-- Tabla COMPANIES: creacion, importacion y check
CREATE TABLE IF NOT EXISTS companies(
	company_id VARCHAR(15) PRIMARY KEY,
    company_name VARCHAR(255),
    phone VARCHAR(15),
    email VARCHAR(100),
    country VARCHAR (100),
    website VARCHAR (100)
);

LOAD DATA INFILE '/Users/barbarajunqueira/Desktop/RecursosDataAnalyst/Sprint4/companies.csv'
INTO TABLE companies
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

SELECT * FROM companies;

-- Tabla CREDIT_CARDS: creacion, importacion y check
CREATE TABLE IF NOT EXISTS credit_cards(
	id VARCHAR(20) PRIMARY KEY,
    user_id VARCHAR(20),
    iban VARCHAR(50),
    pan VARCHAR(50),
    pin VARCHAR(4),
    cvv INT,
    track1 VARCHAR(100),
    track2 VARCHAR(100),
    expiring_date VARCHAR (20)
);

LOAD DATA INFILE '/Users/barbarajunqueira/Desktop/RecursosDataAnalyst/Sprint4/credit_cards.csv'
INTO TABLE credit_cards
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n' 
IGNORE 1 LINES;

SELECT * FROM credit_cards;

-- Tabla USERS: creacion, importacion y check
CREATE TABLE users (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    surname VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(255),
    birth_date DATE,
    country VARCHAR(100),
    city VARCHAR(100),
    postal_code VARCHAR(100),
    address VARCHAR(255)
);

LOAD DATA INFILE '/Users/barbarajunqueira/Desktop/RecursosDataAnalyst/Sprint4/users_ca.csv'
INTO TABLE users
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(id, name, surname, phone, email, @birth_date, country, city, postal_code, address)
SET 
    birth_date = STR_TO_DATE(@birth_date, '%b %d, %Y');  -- Convertiendo la fecha para el formato correcto
    
LOAD DATA INFILE '/Users/barbarajunqueira/Desktop/RecursosDataAnalyst/Sprint4/users_uk.csv'
INTO TABLE users
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(id, name, surname, phone, email, @birth_date, country, city, postal_code, address)
SET 
    birth_date = STR_TO_DATE(@birth_date, '%b %d, %Y');
    
LOAD DATA INFILE '/Users/barbarajunqueira/Desktop/RecursosDataAnalyst/Sprint4/users_usa.csv'
INTO TABLE users
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(id, name, surname, phone, email, @birth_date, country, city, postal_code, address)
SET 
    birth_date = STR_TO_DATE(@birth_date, '%b %d, %Y');

SELECT * FROM users;

-- Tabla PRODUCTS: creacion, importacion y check, que tiene que ser creada a posteriori de la tabla de TRANSACTIONS_PRODUCTS
CREATE TABLE products(
	id INT PRIMARY KEY,
    product_name VARCHAR(200),
    price DECIMAL (5, 2),
    colour VARCHAR(20),
    weight DECIMAL (5, 1),
    warehouse_id VARCHAR(10)
);

LOAD DATA INFILE '/Users/barbarajunqueira/Desktop/RecursosDataAnalyst/Sprint4/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n' 
IGNORE 1 LINES
(@id, @product_name, @price, @colour, @weight, @warehouse_id)
SET id = @id,
	price = REPLACE(@price, '$', ''),
    product_name = @product_name,
    colour = @colour,
    weight = @weight,
    warehouse_id = @warehouse_id;

SELECT * FROM products;

-- Tabla TRANSACTIONS: creacion, importacion y check
CREATE TABLE transactions (
	id VARCHAR(200) PRIMARY KEY,
	card_id VARCHAR(100),
    business_id VARCHAR(100),
    timestamp TIMESTAMP,
    amount DECIMAL(5, 2),
    declined TINYINT,
	product_ids VARCHAR(50),
    user_id INT,
    lat FLOAT,
    longitude FLOAT,
    FOREIGN KEY (business_id) REFERENCES companies(company_id),
    FOREIGN KEY (card_id) REFERENCES credit_cards(id),
	FOREIGN KEY (user_id) REFERENCES users(id)
);

LOAD DATA INFILE '/Users/barbarajunqueira/Desktop/RecursosDataAnalyst/Sprint4/transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ';' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

SELECT * from transactions;

-- Tabla de union entre produtcs y transactions: TRANSACTIONS_PRODUCTS creacion, importacion y check
CREATE TABLE transactions_products (
    transaction_id VARCHAR(50),
	product_id INT,
    PRIMARY KEY (transaction_id, product_id),
	FOREIGN KEY (transaction_id) REFERENCES transactions(id),
	FOREIGN KEY (product_id) REFERENCES products(id)
);

INSERT INTO transactions_products (transaction_id, product_id)
WITH RECURSIVE numbers AS (
    SELECT 1 AS n     -- Genera números secuenciales, empezando desde 1
    UNION ALL
    SELECT n + 1     -- Continuamos generando números incrementales mientras sea necesario
    FROM numbers
    WHERE n < (SELECT MAX(LENGTH(t.product_ids) - LENGTH(REPLACE(t.product_ids, ',', '')) + 1) FROM transactions t)
)
SELECT 
    t.id AS transaction_id, -- Insertamos el ID de la transacción
    CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(t.product_ids, ',', n.n), ',', -1) AS UNSIGNED) AS product_id 
FROM 
    transactions t
JOIN 
    numbers n ON n.n <= (LENGTH(t.product_ids) - LENGTH(REPLACE(t.product_ids, ',', '')) + 1);

SELECT * FROM transactions_products;

-- check de se o caminho de transactions até produtos está bem feito:
SELECT p.id as productIdFromProduct, t.id as transactionsIdFromTransactions
FROM transactions t
JOIN transactions_products tp ON t.id = tp.transaction_id
JOIN products p ON p.id = tp.product_id;

-- alterando a tabela de transactions para criar o link com transactions_products -- no he podido y no tiene sentido porque
-- quiero crear una conexion de many-to-many entonces dejé sin el enlace en el diagrama y esa tabla funciona como
-- tabla de union
ALTER TABLE transactions 
ADD CONSTRAINT transactions_ibfk_4 
FOREIGN KEY (product_ids) REFERENCES transactions_products(transaction_id) ON DELETE CASCADE;

-- Nivell 1 Exercici 1
-- Realitza una subconsulta que mostri tots els usuaris amb més de 30 transaccions utilitzant almenys 2 taules.
SELECT u.name AS userName, u.surname AS userSurname, (SELECT SUM(t.amount) FROM transactions t WHERE t.user_id = u.id) AS totalAmount
FROM users u
WHERE u.id IN ( SELECT t.user_id
				FROM transactions t
				GROUP BY t.user_id
				HAVING COUNT(t.id) > 30
);

-- Nivell 1 Exercici 2
-- Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.
-- pre consulta para entender si seria un avg alto o bajo, y se puede calcular manualmente. tendria que ser (364,61 + 42,82) /2 = 203,715
SELECT * 
FROM credit_cards cc
JOIN transactions t ON t.card_id = cc.id
JOIN companies c ON t.business_id = c.company_id
WHERE c.company_name = "Donec Ltd";

-- querry en question:
SELECT ROUND(AVG(amount), 2) as avgAmount, company_name as companyName, card_id as iban
FROM transactions t
JOIN companies c ON t.business_id = c.company_id
WHERE c.company_name = "Donec Ltd"
GROUP BY iban, companyName;

-- Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les últimes tres transaccions van ser declinades
CREATE TABLE credit_card_declined_status AS
WITH lastThreeTransactions AS (
    SELECT t.card_id, t.declined,ROW_NUMBER() OVER (PARTITION BY t.card_id ORDER BY t.timestamp DESC) AS numRow 
    FROM transactions t
)
SELECT card_id,
    CASE 
        WHEN SUM(declined) = 3 THEN 'declined' 
        ELSE 'active'
    END AS status
FROM lastThreeTransactions
WHERE numRow <= 3  
GROUP BY card_id;
    
SELECT * FROM credit_card_declined_status;

SELECT count(status) as tarjetasActivas
FROM credit_card_declined_status
WHERE status = 'active';

-- Necessitem conèixer el nombre de vegades que s'ha venut cada producte.
SELECT product_id as producte, count(product_id) as nombreVegadesVenut
FROM transactions_products tp
JOIN transactions t ON tp.transaction_id = t.id
WHERE declined = 0
GROUP BY producte
ORDER BY producte;









