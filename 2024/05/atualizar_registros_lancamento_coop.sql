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
    FOR r_cur IN (SELECT lcm.nrdconta
                        ,lcm.rowid
                    FROM cecred.craplcm lcm
                   WHERE ROWID IN ('AAArCwAAAAAHADSAAK'
                                  ,'AAArCwAAAAAHADSAAL'
                                  ,'AAArCwAAAAAHADSAAM'
                                  ,'AAArCwAAAAAHADSAAN'
                                  ,'AAArCwAAAAAHADSAAO'
                                  ,'AAArCwAAAAAHADSAAP'
                                  ,'AAArCwAAAAAHADSAAQ'
                                  ,'AAArCwAAAAAHADSAAR'
                                  ,'AAArCwAAAAAHADSAAT'
                                  ,'AAArCwAAAAAHADSAAS'
                                  ,'AAArCwAAAAAHADSAAU'
                                  ,'AAArCwAAAAAHADSAAV'
                                  ,'AAArCwAAAAAHADSAAW'
                                  ,'AAArCwAAAAAHADSAAX'
                                  ,'AAArCwAAAAAHADSAAY'
                                  ,'AAArCwAAAAAHADSAAZ'
                                  ,'AAArCwAAAAAHADSAAa'
                                  ,'AAArCwAAAAAHADSAAb'
                                  ,'AAArCwAAAAAHADSAAc'))
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
