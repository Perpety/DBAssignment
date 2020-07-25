--Assignment_1




CREATE TABLE users (
	u_id integer PRIMARY KEY,
	name text NOT NULL,
	mobile text NOT NULL,
	wallet_id integer NOT NULL,
	when_created timestamp without time zone NOT NULL
	-- more stuff :)
);

CREATE TABLE transfers (
	transfer_id integer PRIMARY KEY,
	u_id integer NOT NULL,
	source_wallet_id integer NOT NULL,
	dest_wallet_id integer NOT NULL,
	send_amount_currency text NOT NULL,
	send_amount_scalar numeric NOT NULL,
	receive_amount_currency text NOT NULL,
	receive_amount_scalar numeric NOT NULL,
	kind text NOT NULL,
	dest_mobile text,
	dest_merchant_id integer,
	when_created timestamp without time zone NOT NULL
	-- more stuff :)
);

CREATE TABLE agents (
	agent_id integer PRIMARY KEY,
	name text,
	country text NOT NULL,
	region text,
	city text,
	subcity text,
	when_created timestamp without time zone NOT NULL
	-- more stuff :)
);

CREATE TABLE agent_transactions (
	atx_id integer PRIMARY KEY,
	u_id integer NOT NULL,
	agent_id integer NOT NULL,
	amount numeric NOT NULL,
	fee_amount_scalar numeric NOT NULL,
	when_created timestamp without time zone NOT NULL
	-- more stuff :)
);

CREATE TABLE wallets (
	wallet_id integer PRIMARY KEY,
	currency text NOT NULL,
	ledger_location text NOT NULL,
	when_created timestamp without time zone NOT NULL
	-- more stuff :)
);

--Output of the tables

SELECT * FROM agent_transactions;
SELECT * FROM agents;
SELECT * FROM transfers;
SELECT * FROM users;
SELECT * FROM wallets;

--Question 1
--How many users does Wave have?

SELECT COUNT(*) FROM users;

--Question 2
--How many transfers have been sent in the currency CFA?

SELECT COUNT(U_id) 
	FROM transfers 
	WHERE Send_Amount_Currency = 'CFA';

--Question 3
--How many different users have sent a transfer in CFA?

SELECT COUNT(DISTINCT U_id) 
	FROM transfers 
	WHERE Send_Amount_Currency = 'CFA';
	
--Question 4	
--How many agent_transactions did we have in the months of 2018 (broken down bymonth)?
	
SELECT COUNT(atx_id)
	FROM agent_transactions
	WHERE EXTRACT(YEAR FROM when_created) = 2018
	GROUP BY EXTRACT(MONTH FROM when_created);
	--when_created BETWEEN '2018-01-01' AND '2018-12-31';

--Question 5
--Over the course of the last week, how many Wave agents were “net depositors” vs. “netwithdrawers”?

SELECT COUNT(A.amount) AS count_net_depositor, COUNT(B.amount) AS count_net_withdrawer, B.when_created
	FROM agent_transactions A, agent_transactions B
	WHERE A.amount < 0 OR B.amount > 0
	AND B.when_created > (NOW() - INTERVAL '1 week')
	GROUP BY B.when_created; 

--Question 6
--Build an “atx volume city summary” table: find the volume of agent transactions createdin the last week, 
--grouped by city. You can determine the city where the agent transactiontook place from the agent’s city field.

SELECT city, volume --INTO atxvolumecitysummary 
	FROM (SELECT agents.city AS city, COUNT(agent_transactions.atx_id) AS Volume 
	FROM agents 
	INNER JOIN agent_transactions ON agent_transactions.agent_id = agents.agent_id
	WHERE (agent_transactions.when_created > (NOW() - INTERVAL '1 week'))
	GROUP BY agents.city) AS atx_volume_summary;

	--OR

SELECT COUNT(atx_id) AS "atx volume", agents.city
	FROM agent_transactions
	LEFT JOIN agents ON agent_transactions.agent_id = agents.agent_id
	WHERE agent_transactions.when_created BETWEEN '2020-07-12' AND '2020-07-18'
	GROUP BY City;

--Question 7
--Now separate the atx volume by country as well (so your columns should be country,city, volume).
SELECT city, volume, country --INTO atx_volume_city_summary_with_Country
	FROM (SELECT agents.city AS city, agents.country AS country, 
	COUNT(agent_transactions.atx_id) AS volume
	FROM agents INNER JOIN agent_transactions ON agents.agent_id = agent_transactions.agent_id
	WHERE agent_transactions.when_created > (NOW() - INTERVAL '1 week')
	GROUP BY agents.country, agents.city) AS atx_volume_summary_with_country;
	--FROM agent_transactions
	--LEFT JOIN agents ON agent_transactions.agent_id = agents.agent_id
	--GROUP BY country;
	
--Question 8
--Build a “send volume by country and kind” table: find the total volume of transfers (bysend_amount_scalar) 
--sent in the past week, grouped by country and transfer kind. 

SELECT SUM(transfers.send_amount_scalar) AS "transfer volume", wallets.ledger_location
	AS "country", transfers.kind AS "transfer kind"
	FROM transfers
	LEFT JOIN wallets ON transfers.source_wallet_id = wallets.wallet_id
	WHERE transfers.when_created > (NOW() - INTERVAL '1 week')
	GROUP BY wallets.ledger_location, transfers.kind;
		 
	
--Question 9
--Then add columns for transaction count and number of unique senders (still brokendown by country and transfer kind).

SELECT COUNT(transfers.source_wallet_id) AS unique_sender, 
		 COUNT(transfer_id) AS transsaction_count, transfers.kind AS transfer_kind, wallets.ledger_location
		 AS country, SUM(transfers.send_amount_scalar) AS volume FROM transfers
		 INNER JOIN wallets ON transfers.source_wallet_id = wallets.wallet_id
		 WHERE (transfers.when_created > (NOW() - INTERVAL '1 week'))
		 GROUP BY wallets.ledger_location, transfers.kind;
		 
--Question 10
--Finally, which wallets have sent more than 10,000,000 CFA in transfers in the last month
--(as identified by the source_wallet_id column on the transfers table), and how much didthey send?

SELECT source_wallet_id, send_amount_scalar
		 FROM transfers
		 WHERE send_amount_currency = 'CFA' OR (send_amount_scalar > 10000000) 
		 AND (transfers.when_created > (NOW() - INTERVAL '1 month'));
		 
		 

