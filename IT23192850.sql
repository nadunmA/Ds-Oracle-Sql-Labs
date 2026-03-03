-- IT23192850
-- Nadun M.A
-- 3Y S1 WE 4.2
-- practical 5

SET SERVEROUTPUT ON;
-- Exercise 01
DECLARE
  v_company stock.company%TYPE := 'IBM';
  v_price   stock.price%TYPE;
BEGIN
  SELECT s.price
  INTO   v_price
  FROM   stock s
  WHERE  s.company = v_company;
  DBMS_OUTPUT.PUT_LINE('Company: ' || v_company || ' | Current Price: ' || v_price);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('No stock found for company ' || v_company);
  WHEN TOO_MANY_ROWS THEN
    DBMS_OUTPUT.PUT_LINE('Error: duplicate company rows found for ' || v_company);
END;
/


-- Exercise 02
DECLARE
  v_company stock.company%TYPE := 'IBM';
  v_price   stock.price%TYPE;
BEGIN
  SELECT s.price INTO v_price
  FROM stock s
  WHERE s.company = v_company;
  IF v_price < 45 THEN
    DBMS_OUTPUT.PUT_LINE('Current price is very low !');
  ELSIF v_price < 55 THEN
    DBMS_OUTPUT.PUT_LINE('Current price is low !');
  ELSIF v_price < 65 THEN
    DBMS_OUTPUT.PUT_LINE('Current price is medium !');
  ELSIF v_price < 75 THEN
    DBMS_OUTPUT.PUT_LINE('Current price is medium high !');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Current price is high !');
  END IF;
  DBMS_OUTPUT.PUT_LINE('Company: ' || v_company || ' | Price: ' || v_price);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('No stock found for company ' || v_company);
END;
/


-- Exercise 03
--FOR loops part
BEGIN
  FOR i IN REVERSE 1..9 LOOP
    FOR j IN 1..i LOOP
      DBMS_OUTPUT.PUT(i || ' ');
    END LOOP;
    DBMS_OUTPUT.NEW_LINE;
  END LOOP;
END;
/
--WHILE loops part
DECLARE
  i NUMBER := 9;
  j NUMBER;
BEGIN
  WHILE i >= 1 LOOP
    j := 1;
    WHILE j <= i LOOP
      DBMS_OUTPUT.PUT(i || ' ');
      j := j + 1;
    END LOOP;
    DBMS_OUTPUT.NEW_LINE;
    i := i - 1;
  END LOOP;
END;
/
--SIMPLE loops part
DECLARE
  i NUMBER := 9;
  j NUMBER;
BEGIN
  LOOP
    EXIT WHEN i < 1;
    j := 1;
    LOOP
      EXIT WHEN j > i;
      DBMS_OUTPUT.PUT(i || ' ');
      j := j + 1;
    END LOOP;
    DBMS_OUTPUT.NEW_LINE;
    i := i - 1;
  END LOOP;
END;
/



-- Exercise 04
SET SERVEROUTPUT ON;

SELECT clno, company, pdate, qty FROM purchase ORDER BY pdate;
DECLARE
  v_bonus NUMBER;
  v_rows  NUMBER := 0;
BEGIN
  FOR r IN (SELECT clno, company, pdate, price FROM purchase) LOOP
    IF r.pdate < DATE '2000-01-01' THEN
      v_bonus := 150;
    ELSIF r.pdate < DATE '2001-01-01' THEN
      v_bonus := 100;
    ELSIF r.pdate < DATE '2002-01-01' THEN
      v_bonus := 50;
    ELSE
      v_bonus := 0;
    END IF;
    IF v_bonus > 0 THEN
      UPDATE purchase
      SET qty = qty + v_bonus
      WHERE clno = r.clno
        AND company = r.company
        AND pdate = r.pdate
        AND price = r.price;
      v_rows := v_rows + SQL%ROWCOUNT;
    END IF;
  END LOOP;
  DBMS_OUTPUT.PUT_LINE('Ex04 Updated rows: ' || v_rows);
END;
/
SELECT clno, company, pdate, qty FROM purchase ORDER BY pdate;
ROLLBACK;
SELECT clno, company, pdate, qty FROM purchase ORDER BY pdate;





-- Exercise 05
SET SERVEROUTPUT ON;

DECLARE
  CURSOR c_p IS
    SELECT clno, company, pdate, price
    FROM purchase;

  r       c_p%ROWTYPE;
  v_bonus NUMBER;
  v_rows  NUMBER := 0;
BEGIN
  OPEN c_p;

  FETCH c_p INTO r;   -- first fetch
  WHILE c_p%FOUND LOOP -- WHILE loop

    IF r.pdate < DATE '2000-01-01' THEN
      v_bonus := 150;
    ELSIF r.pdate < DATE '2001-01-01' THEN
      v_bonus := 100;
    ELSIF r.pdate < DATE '2002-01-01' THEN
      v_bonus := 50;
    ELSE
      v_bonus := 0;
    END IF;

    IF v_bonus > 0 THEN
      UPDATE purchase
      SET qty = qty + v_bonus
      WHERE clno = r.clno
        AND company = r.company
        AND pdate = r.pdate
        AND price = r.price;

      v_rows := v_rows + SQL%ROWCOUNT;
    END IF;

    FETCH c_p INTO r; -- next fetch
  END LOOP;

  CLOSE c_p;

  DBMS_OUTPUT.PUT_LINE('Ex05 Updated rows: ' || v_rows);
END;
/

-- after Ex05
SELECT clno, company, pdate, qty
FROM purchase
ORDER BY pdate;
ROLLBACK;