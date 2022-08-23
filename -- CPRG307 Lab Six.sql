-- CPRG307 Lab Six Prelab
-- Brent Martin

--1
CREATE SEQUENCE seq_contract_number
    Start with 10
    Increment by 1;

CREATE OR REPLACE PROCEDURE proc_insert_Contract
(p_entertainer IN VARCHAR2 , p_client IN VARCHAR2, p_event IN VARCHAR2, p_fee IN NUMBER)
IS

BEGIN
    INSERT INTO ata_contract
    VALUES (seq_contract_number.NEXTVAL, p_entertainer, p_client, p_event, p_fee);

END;
/

--2
CREATE OR REPLACE FUNCTION func_char_Counter
(paramString VARCHAR2) RETURN NUMBER IS
   
    v_count NUMBER;

BEGIN
    v_count := LENGTH(paramString);

    RETURN v_count;

END;
/

--3
CREATE OR REPLACE FUNCTION func_fee_Finder
(contractNum NUMBER) RETURN NUMBER IS
    v_contractFee NUMBER;

BEGIN
    select fee
    into v_contractFee
    from ata_contract
    where contract_Number = contractNum;

    RETURN v_contractFee;

EXCEPTION
    WHEN no_data_found THEN
        RAISE_APPLICATION_ERROR (-20001, 'Contract Number Not Found!');
END;
/

--test statments
--1: execute proc_insert_contract('0000011', '0000005', 'Wedding', 1000)
--2: select func_char_counter('Test') from dual;
--3: select func_fee_finder(1) from dual;

-- CPRG307 Lab Six
-- Brent Martin

-- Calculate event time (Func)
CREATE OR REPLACE FUNCTION func_eLen
(eventStart string, eventEnd string) RETURN NUMBER IS

    eventLength NUMBER;
    eventBegin DATE;
    eventFinish DATE;

BEGIN

   eventBegin := TO_DATE(eventStart,'YYYY-MM-DD HH24:MI:SS');
   eventFinish := TO_DATE(eventEnd,'YYYY-MM-DD HH24:MI:SS');


    eventLength := (eventFinish - eventBegin) * 24;

    RETURN eventLength;

END;
/

-- Get event rate (Func)
CREATE OR REPLACE FUNCTION func_eRate
(eventType VARCHAR2) RETURN NUMBER IS

    v_eventRate NUMBER;

BEGIN
    CASE (eventType)
        WHEN 'Childrens Party' THEN  v_eventRate := 335;
        WHEN 'Concert' THEN v_eventRate := 1000;
        WHEN 'Divorce Party' THEN v_eventRate := 170;
        WHEN 'Wedding' THEN v_eventRate := 300;
        ELSE v_eventRate := 100;
    END CASE;

    RETURN v_eventRate;
END;
/
   
-- Calculate event cost (Func)
CREATE OR REPLACE FUNCTION func_eCost
(eventLength NUMBER, eventRate NUMBER) RETURN NUMBER IS

    eventCost NUMBER;

BEGIN
    eventCost := eventLength * eventRate;

    RETURN eventCost;
END;
/

-- Caluate extra costs (Func)
CREATE OR REPLACE FUNCTION func_eventExtras
(StartTime VARCHAR2, eventCost NUMBER) RETURN NUMBER IS

    extraCost NUMBER;
    dayWeek VARCHAR2(40);
   
BEGIN
    dayWeek := TO_DATE(StartTime,'YYYY-MM-DD HH24:MI:SS');

    IF dayWeek = 'Monday' OR dayWeek = 'Friday' THEN
        extraCost := eventCost + 100;

        RETURN extraCost;

    ELSE
        extraCost := eventCost;

        RETURN extraCost;

    END IF;

END;
/

-- Add cost to contract table (Procedure)
CREATE OR REPLACE PROCEDURE proc_insert_ContractCost
(contractNum IN NUMBER, contractTotal IN NUMBER)
IS

BEGIN
    UPDATE ata_contract
    SET fee = contractTotal
    WHERE contract_number = contractNum;

END;
/

Set SERVEROUTPUT On

DECLARE
    StartTime VARCHAR2(40) := '2021-06-15 9:30:00';
    EndTime VARCHAR2(40) := '2021-06-15 12:30:00' ;
    eventType VARCHAR2(40) := 'Childrens Party';
    eventTotal NUMBER;
    eventLen NUMBER;
    rate NUMBER;
    eventCost NUMBER;
    dayOfWeek VARCHAR2(20);
    numContract VARCHAR2(2);

BEGIN
   
    Select func_eLen(StartTime, EndTime)
    into eventLen
    from dual;
    DBMS_OUTPUT.PUT_LINE(eventLen);

   
    Select func_eRate(eventType)
    into rate
    from dual;
    DBMS_OUTPUT.PUT_LINE(rate);

   
    select func_eCost(eventLen, rate)
    into eventCost
    from dual;
    DBMS_OUTPUT.PUT_LINE(eventCost);
   
    select func_eventExtras(StartTime, eventCost)
    into eventTotal
    from dual;
    DBMS_OUTPUT.PUT_LINE(eventTotal);

    numContract := '1';
    proc_insert_ContractCost(numContract, eventTotal);

EXCEPTION
     WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);

END;
/