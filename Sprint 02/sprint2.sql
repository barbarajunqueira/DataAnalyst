/* Nivell 1 - Exercici 1
A partir dels documents adjunts (estructura_dades i dades_introduir), 
importa les dues taules. Mostra les característiques principals de 
l'esquema creat i explica les diferents taules i variables que existeixen. 
Assegura't d'incloure un diagrama que il·lustri la relació entre 
les diferents taules i variables.*/

/*Respuesta:  Duas tablas que se relacionan entre si por el ID de 
la company (primary key en la tabla company "ID" y forigner key en la tabla
transaction "COMPANY_ID". La tabla de company contiene informaciones de 
la compania como identificador, nombre, telefono, correo, pais y pagina
web mientras la tabla de transaction contiene informaciones a respeto de 
transaciones hechas por estas companias. En esta tabla estan en ID de la 
transacion, el identificador de la tarjeta, identificador de la compania
(relacional con tabla company) identificador del usuario, latitude, 
longitude, timestamp para saber hora y fecha de la transacion, cantitad 
transacionada y un elemento de identificacion para saber si ha sido 
concluida la operacion o declinada. */

/* Nivell 1 - Exercici 2
Utilitzant JOIN realitzaràs les següents consultes:
Llistat dels països que estan fent compres. */
SELECT distinct country AS llistatPaisosFentCompres
FROM company AS c
INNER JOIN transaction AS t ON c.id = t.company_id
WHERE declined = 0;

/* Nivell 1 - Exercici 2
Utilitzant JOIN realitzaràs les següents consultes:
Des de quants països es realitzen les compres.*/
SELECT count(DISTINCT country) AS qtdPaisosQueFanCompres
FROM company AS c
INNER JOIN transaction AS t ON c.id = t.company_id
WHERE declined = 0;

/* Nivell 1 - Exercici 2
Utilitzant JOIN realitzaràs les següents consultes:
Identifica la companyia amb la mitjana més gran de vendes.
*/
SELECT c.company_name, round(AVG(amount))
FROM company AS c
join transaction AS t
WHERE t.company_id = c.id AND declined = 0
GROUP BY c.id, c.company_name
ORDER BY AVG(amount) DESC
LIMIT 1;

/* Nivell 1 - Exercici 3
Utilitzant només subconsultes (sense utilitzar JOIN):
Mostra totes les transaccions realitzades per empreses d'Alemanya.*/
SELECT * 
FROM transactions.transaction 
WHERE declined = 0 AND company_id IN (
    SELECT id 
    FROM transactions.company 
    WHERE country = 'Germany'
);

/* Nivell 1 - Exercici 3
Utilitzant només subconsultes (sense utilitzar JOIN):
Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.*/
SELECT DISTINCT c.id, company_name
FROM company AS c
WHERE c.id IN (SELECT t.company_id 
				FROM transaction AS t 
				WHERE amount > (SELECT AVG(amount) FROM transaction) AND declined = 0);

/* Nivell 1 - Exercici 3
Utilitzant només subconsultes (sense utilitzar JOIN):
Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.*/
SELECT c.id
FROM company AS c
WHERE c.id NOT IN (SELECT company_id FROM transaction);

/* Nivell 2 - Exercici 1
Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes. Mostra la data de cada 
transacció juntament amb el total de les vendes. */
SELECT DATE(timestamp) AS dataTransacio, sum(amount) AS totalVendes 
FROM transaction
WHERE declined = 0
GROUP BY date(timestamp)
ORDER BY sum(amount) DESC
LIMIT 5; 

/* Nivell 2 - Exercici 2
Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.*/
SELECT round(AVG(amount)) AS mitjanaVendes, country AS pais
FROM company
JOIN transaction
WHERE transaction.company_id = company.id AND declined = 0
GROUP BY country
ORDER BY AVG(amount) DESC;

/* Nivell 2 - Exercici 3
En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries per a fer competència a la 
companyia "Non Institute". Per a això, et demanen la llista de totes les transaccions realitzades per empreses que estan 
situades en el mateix país que aquesta companyia.
Mostra el llistat aplicant JOIN i subconsultes.*/

SELECT * 
FROM transaction
JOIN company
WHERE transaction.company_id = company.id
AND country = (SELECT country FROM company WHERE company_name = "Non Institute") AND transaction.declined = 0;

/* Nivell 2 - Exercici 3
En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries per a fer competència a la 
companyia "Non Institute". Per a això, et demanen la llista de totes les transaccions realitzades per empreses que estan 
situades en el mateix país que aquesta companyia.
Mostra el llistat aplicant solament subconsultes.*/

SELECT * 
FROM transactions.transaction 
WHERE declined = 0 AND company_id IN (
    SELECT id 
    FROM transactions.company 
    WHERE country = (SELECT country FROM company WHERE company_name = "Non Institute")
);


/*Nivell 3 - Exercici 1
Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions amb un valor 
comprès entre 100 i 200 euros i en alguna d'aquestes dates: 29 d'abril del 2021, 20 de juliol del 2021 i 13 de març del 2022. 
Ordena els resultats de major a menor quantitat. */
SELECT c.company_name, c.phone, c.country, t.timestamp, t.amount
FROM transaction AS t
JOIN company AS c
WHERE declined = 0 AND c.id = t.company_id AND 100 <= amount AND amount <= 200 AND 
(date(timestamp) = '2021-04-29' OR date(timestamp) = '2021-07-20' OR date(timestamp) = '2022-03-13')
ORDER BY amount DESC;


/*Nivell 3 - Exercici 2
Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, per la qual cosa et 
demanen la informació sobre la quantitat de transaccions que realitzen les empreses, però el departament de recursos humans 
és exigent i vol un llistat de les empreses on especifiquis si tenen més de 4 transaccions o menys. */
SELECT company_name, count(company_id) AS transaccionsByCompany, 
		CASE 
			WHEN count(company_id) > 4 THEN 'Més de 4 transaccions'
			ELSE 'Menys de 4 transaccions'
		END AS categoriaTransaccions
FROM transaction
JOIN company
WHERE company.id = transaction.company_id 
GROUP BY company_id;