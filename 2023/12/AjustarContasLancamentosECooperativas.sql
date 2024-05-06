DECLARE
  FUNCTION digitoConta(pr_nrconta IN INTEGER) RETURN INTEGER IS
  BEGIN
    DECLARE
      vr_digito  INTEGER := 0;
      vr_peso    INTEGER := 9;
      vr_calculo INTEGER := 0;
      vr_resto   INTEGER := 0;
      vr_nrconta VARCHAR2(20);
    BEGIN
      vr_nrconta := pr_nrconta;
      FOR idx IN REVERSE 1 .. (LENGTH(vr_nrconta))
      LOOP
        vr_calculo := vr_calculo + (TO_NUMBER(SUBSTR(vr_nrconta, idx, 1)) * vr_peso);
        vr_peso    := vr_peso - 1;
        IF vr_peso = 1 THEN
          vr_peso := 9;
        END IF;
      END LOOP;
    
      vr_resto := MOD(vr_calculo, 11);
    
      IF vr_resto > 9 THEN
        vr_digito := 0;
      ELSE
        vr_digito := vr_resto;
      END IF;
    
      RETURN vr_digito;
    END;
  END digitoConta;
  FUNCTION numeroConta_char(numeroOriginal VARCHAR2) RETURN VARCHAR2 AS
    soma     INT;
    orig     VARCHAR2(100);
    nrmod    VARCHAR2(100);
    i        INT;
    temp     INT;
    vr_conta VARCHAR2(11) := '';
    n        INT;
    c2       NUMBER;
    nconta   NUMBER;
  BEGIN
    IF (numeroOriginal IS NULL) OR (numeroOriginal = '9999999999') THEN
      RETURN numeroOriginal;
    END IF;
    orig     := regexp_replace(numeroOriginal, '[^0-9]', '');
    orig     := substr(orig, 1, length(orig) - 1);
    nconta   := power(10, 7) - (to_number(orig) + 7);
    vr_conta := to_char(nconta);
    RETURN vr_conta || digitoConta(vr_conta);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN numeroOriginal;
  END;

  procedure altera_lancamentos is
    vr_nrconta NUMBER;
  BEGIN
    FOR r_cur IN (
                  
                  SELECT lcm.nrdconta
                         ,lcm.rowid
                    FROM cecred.craplcm lcm
                   WHERE (lcm.CDCOOPER, lcm.DTMVTOLT, lcm.CDAGENCI, lcm.CDBCCXLT, lcm.NRDOLOTE, lcm.NRDCTABB, lcm.NRDOCMTO) IN
                         ((3, to_date('05122023', 'ddmmyyyy'), 1, 85, 7101, 1150006, 2115)
                         ,(3, to_date('05122023', 'ddmmyyyy'), 1, 85, 7101, 1150006, 1115)
                         ,(3, to_date('05122023', 'ddmmyyyy'), 1, 85, 7101, 1150006, 115)
                         ,(3, to_date('05122023', 'ddmmyyyy'), 1, 85, 7101, 1110004, 4111)
                         ,(3, to_date('05122023', 'ddmmyyyy'), 1, 85, 7101, 1110004, 3111)
                         ,(3, to_date('05122023', 'ddmmyyyy'), 1, 85, 7101, 1110004, 2111)
                         ,(3, to_date('05122023', 'ddmmyyyy'), 1, 85, 7101, 1110004, 1111)
                         ,(3, to_date('05122023', 'ddmmyyyy'), 1, 85, 7101, 1110004, 111)
                         ,(3, to_date('05122023', 'ddmmyyyy'), 1, 85, 7101, 1090003, 109)
                         ,(3, to_date('05122023', 'ddmmyyyy'), 1, 85, 7101, 1070002, 1107)
                         ,(3, to_date('05122023', 'ddmmyyyy'), 1, 85, 7101, 1070002, 107)
                         ,(3, to_date('05122023', 'ddmmyyyy'), 1, 85, 7101, 1050001, 3105)
                         ,(3, to_date('05122023', 'ddmmyyyy'), 1, 85, 7101, 1050001, 2105)
                         ,(3, to_date('05122023', 'ddmmyyyy'), 1, 85, 7101, 1050001, 1105)
                         ,(3, to_date('05122023', 'ddmmyyyy'), 1, 85, 7101, 1050001, 105)
                         ,(3, to_date('05122023', 'ddmmyyyy'), 1, 85, 7101, 1010000, 4101)
                         ,(3, to_date('05122023', 'ddmmyyyy'), 1, 85, 7101, 1010000, 3101)
                         ,(3, to_date('05122023', 'ddmmyyyy'), 1, 85, 7101, 1010000, 2101)
                         ,(3, to_date('05122023', 'ddmmyyyy'), 1, 85, 7101, 1010000, 1101)
                         ,(3, to_date('05122023', 'ddmmyyyy'), 1, 85, 7101, 1010000, 101)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1150006, 7115)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1150006, 6115)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1150006, 5115)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1150006, 4115)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1150006, 3115)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1150006, 2115)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1150006, 1115)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1150006, 115)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1130005, 7113)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1130005, 6113)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1130005, 5113)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1130005, 4113)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1130005, 3113)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1130005, 2113)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1130005, 1113)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1130005, 113)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1120000, 5112)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1120000, 4112)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1120000, 3112)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1120000, 2112)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1120000, 1112)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1120000, 112)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1110004, 4111)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1110004, 3111)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1110004, 2111)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1110004, 1111)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1110004, 111)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1090003, 7109)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1090003, 6109)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1090003, 5109)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1090003, 4109)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1090003, 3109)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1090003, 2109)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1090003, 1109)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1090003, 109)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1100009, 5110)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1100009, 4110)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1100009, 3110)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1100009, 2110)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1100009, 1110)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1100009, 110)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1080008, 6108)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1080008, 5108)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1080008, 4108)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1080008, 3108)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1080008, 2108)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1080008, 1108)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1080008, 108)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1070002, 1107)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1070002, 107)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1060007, 4106)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1060007, 3106)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1060007, 2106)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1060007, 1106)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1060007, 106)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1050001, 3105)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1050001, 2105)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1050001, 1105)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1050001, 105)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1040006, 5104)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1040006, 4104)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1040006, 3104)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1040006, 2104)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1040006, 1104)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1040006, 104)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1020005, 9102)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1020005, 8102)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1020005, 7102)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1020005, 6102)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1020005, 5102)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1020005, 4102)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1020005, 3102)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1020005, 2102)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1020005, 1102)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1020005, 102)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1010000, 12101)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1010000, 11101)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1010000, 10101)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1010000, 9101)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1010000, 8101)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1010000, 7101)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1010000, 6101)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1010000, 5101)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1010000, 4101)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1010000, 3101)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1010000, 2101)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1010000, 1101)
                         ,(3, to_date('19102023', 'ddmmyyyy'), 1, 85, 7101, 1010000, 101)
                         ,(3, to_date('01122023', 'ddmmyyyy'), 1, 85, 7101, 1110004, 6111)
                         ,(3, to_date('01122023', 'ddmmyyyy'), 1, 85, 7101, 1110004, 5111)
                         ,(3, to_date('01122023', 'ddmmyyyy'), 1, 85, 7101, 1110004, 4111)
                         ,(3, to_date('01122023', 'ddmmyyyy'), 1, 85, 7101, 1110004, 3111)
                         ,(3, to_date('01122023', 'ddmmyyyy'), 1, 85, 7101, 1110004, 2111)
                         ,(3, to_date('01122023', 'ddmmyyyy'), 1, 85, 7101, 1110004, 1111)
                         ,(3, to_date('01122023', 'ddmmyyyy'), 1, 85, 7101, 1110004, 111)
                         ,(3, to_date('01122023', 'ddmmyyyy'), 1, 85, 7101, 1090003, 5109)
                         ,(3, to_date('01122023', 'ddmmyyyy'), 1, 85, 7101, 1090003, 4109)
                         ,(3, to_date('01122023', 'ddmmyyyy'), 1, 85, 7101, 1090003, 3109)
                         ,(3, to_date('01122023', 'ddmmyyyy'), 1, 85, 7101, 1090003, 2109)
                         ,(3, to_date('01122023', 'ddmmyyyy'), 1, 85, 7101, 1090003, 1109)
                         ,(3, to_date('01122023', 'ddmmyyyy'), 1, 85, 7101, 1090003, 109)
                         ,(3, to_date('01122023', 'ddmmyyyy'), 1, 85, 7101, 1100009, 110)
                         ,(3, to_date('01122023', 'ddmmyyyy'), 1, 85, 7101, 1080008, 1108)
                         ,(3, to_date('01122023', 'ddmmyyyy'), 1, 85, 7101, 1080008, 108)
                         ,(3, to_date('01122023', 'ddmmyyyy'), 1, 85, 7101, 1050001, 3105)
                         ,(3, to_date('01122023', 'ddmmyyyy'), 1, 85, 7101, 1050001, 2105)
                         ,(3, to_date('01122023', 'ddmmyyyy'), 1, 85, 7101, 1050001, 1105)
                         ,(3, to_date('01122023', 'ddmmyyyy'), 1, 85, 7101, 1050001, 105)
                         ,(3, to_date('01122023', 'ddmmyyyy'), 1, 85, 7101, 1010000, 4101)
                         ,(3, to_date('01122023', 'ddmmyyyy'), 1, 85, 7101, 1010000, 3101)
                         ,(3, to_date('01122023', 'ddmmyyyy'), 1, 85, 7101, 1010000, 2101)
                         ,(3, to_date('01122023', 'ddmmyyyy'), 1, 85, 7101, 1010000, 1101)
                         ,(3, to_date('01122023', 'ddmmyyyy'), 1, 85, 7101, 1010000, 101)))
    LOOP
      vr_nrconta := numeroConta_char(r_cur.nrdconta);
      dbms_output.put_line(r_cur.nrdconta || ' - ' || vr_nrconta);
      
      UPDATE cecred.craplcm lcm
         SET lcm.nrdconta = vr_nrconta
       WHERE lcm.rowid = r_cur.rowid;
       
    END LOOP;
  END;
  
  procedure altera_cooperativas is
    vr_nrconta NUMBER;
  BEGIN
    FOR r_cur IN (SELECT t.cdcooper, t.nrctacmp, ROWID FROM crapcop t WHERE t.nrctacmp > 0)
    LOOP
      vr_nrconta := numeroConta_char(r_cur.nrctacmp);
      dbms_output.put_line(r_cur.cdcooper||' - '||r_cur.nrctacmp||' - '||vr_nrconta);
      
      UPDATE cecred.crapcop cop
         SET cop.nrctacmp = vr_nrconta
       WHERE cop.rowid = r_cur.rowid;
       
    END LOOP;
  END;
  
BEGIN
  altera_lancamentos;
  altera_cooperativas;
  COMMIT;
END;
