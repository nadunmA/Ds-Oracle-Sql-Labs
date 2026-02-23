ALTER TYPE stock_t ADD (
  MEMBER FUNCTION yield RETURN NUMBER,
  MEMBER FUNCTION price_usd(rate NUMBER) RETURN NUMBER,
  MEMBER FUNCTION exchange_count RETURN NUMBER
) CASCADE;
/

-- b
CREATE OR REPLACE TYPE BODY stock_t AS

  MEMBER FUNCTION yield RETURN NUMBER IS
  BEGIN
    IF SELF.currentprice IS NULL OR SELF.currentprice = 0 THEN
      RETURN 0;
    END IF;
    RETURN (SELF.lastdividend / SELF.currentprice) * 100;
  END;

  MEMBER FUNCTION price_usd(rate NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN SELF.currentprice * rate;
  END;

  MEMBER FUNCTION exchange_count RETURN NUMBER IS
  BEGIN
    IF SELF.exchanges IS NULL THEN
      RETURN 0;
    END IF;
    RETURN SELF.exchanges.COUNT;
  END;

END;
/



-- c
CREATE TYPE client_t AS OBJECT (
  clientno    NUMBER,
  firstname   VARCHAR2(20),
  lastname    VARCHAR2(20),
  address     address_t,
  investments investments_nt_t,
  MEMBER FUNCTION purchase_value RETURN NUMBER,
  MEMBER FUNCTION total_profit RETURN NUMBER
);
/

-- d
CREATE OR REPLACE TYPE BODY client_t AS

  MEMBER FUNCTION purchase_value RETURN NUMBER IS
    v_total NUMBER := 0;
  BEGIN
    IF SELF.investments IS NULL THEN
      RETURN 0;
    END IF;
    FOR i IN 1 .. SELF.investments.COUNT LOOP
      v_total := v_total + (SELF.investments(i).purchaseprice * SELF.investments(i).qty);
    END LOOP;
    RETURN v_total;
  END;

  MEMBER FUNCTION total_profit RETURN NUMBER IS
    v_total NUMBER := 0;
    v_curr  NUMBER;
  BEGIN
    IF SELF.investments IS NULL THEN
      RETURN 0;
    END IF;
    FOR i IN 1 .. SELF.investments.COUNT LOOP
      SELECT s.currentprice
      INTO   v_curr
      FROM   stocks s
      WHERE  s.company = SELF.investments(i).company;
      v_total := v_total + ((v_curr - SELF.investments(i).purchaseprice) * SELF.investments(i).qty);
    END LOOP;
    RETURN v_total;
  END;

END;
/

SHOW ERRORS TYPE BODY client_t;


-- e
CREATE TABLE clients OF client_t
  NESTED TABLE investments STORE AS clients_inv_store;
/

INSERT INTO clients
  SELECT client_t(clientno, firstname, lastname, address, investments)
  FROM   clients_or;
COMMIT;



-- f
CREATE TABLE stocks OF stock_t (
  CONSTRAINT pk_stocks PRIMARY KEY (company)
);
/

INSERT INTO stocks
  SELECT stock_t(company, currentprice, exchanges, lastdividend, eps)
  FROM   stocks_or;
COMMIT;



-- querie part

-- a
SELECT s.company,
       s.exchanges,
       ROUND(s.yield(), 2) AS yield_percent,
       ROUND(s.price_usd(0.74), 2) AS price_usd
FROM   stocks s;

-- b
SELECT s.company,
       s.currentprice,
       s.exchange_count() AS no_of_exchanges
FROM   stocks s
WHERE  s.exchange_count() > 1;

-- c
SELECT c.firstname || ' ' || c.lastname AS client_name,
       i.company,
       ROUND(s.yield(), 2) AS yield,
       s.currentprice,
       s.eps
FROM   clients c,
       TABLE(c.investments) i,
       stocks s
WHERE  i.company = s.company
ORDER  BY client_name, i.company;

-- d
SELECT c.firstname || ' ' || c.lastname AS client_name,
       c.purchase_value() AS total_purchase_value
FROM   clients c;

-- e
SELECT c.firstname || ' ' || c.lastname AS client_name,
       c.total_profit() AS book_profit
FROM   clients c;
