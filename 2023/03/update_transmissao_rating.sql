DECLARE

  CURSOR cr_ope IS
    SELECT ROWID dsrowid
      FROM cecred.tbrisco_operacoes
     WHERE dhalteracao IS NOT NULL
       AND dhtransmissao IS NULL;
  TYPE typ_ope IS TABLE OF cr_ope%ROWTYPE INDEX BY PLS_INTEGER;
  vr_tab_ope typ_ope;
  
  CURSOR cr_nrc IS
    SELECT ROWID dsrowid
      FROM cecred.crapnrc
     WHERE dhalteracao IS NOT NULL
       AND dhtransmissao IS NULL;
  TYPE typ_nrc IS TABLE OF cr_nrc%ROWTYPE INDEX BY PLS_INTEGER;
  vr_tab_nrc typ_nrc;

BEGIN

  OPEN cr_ope;
  LOOP
    FETCH cr_ope BULK COLLECT INTO vr_tab_ope LIMIT 5000;
    EXIT WHEN vr_tab_ope.count = 0;
    BEGIN
      FORALL idx IN INDICES OF vr_tab_ope SAVE EXCEPTIONS
        UPDATE cecred.tbrisco_operacoes
           SET dhtransmissao = to_date('01/01/2000 08:00:00', 'DD/MM/RRRR HH24:MI:SS')
         WHERE ROWID = vr_tab_ope(idx).dsrowid;
        COMMIT;
      EXCEPTION
       WHEN OTHERS THEN
         dbms_output.put_line('Erro ao Atualizar tbrisco_operacoes');
    END;
  END LOOP;
  CLOSE cr_ope;
   
  OPEN cr_nrc;
  LOOP
    FETCH cr_nrc BULK COLLECT INTO vr_tab_nrc LIMIT 5000;
    EXIT WHEN vr_tab_nrc.count = 0;
    BEGIN
      FORALL idx IN INDICES OF vr_tab_nrc SAVE EXCEPTIONS
        UPDATE cecred.crapnrc
           SET dhtransmissao = to_date('01/01/2000 08:00:00', 'DD/MM/RRRR HH24:MI:SS')
         WHERE ROWID = vr_tab_nrc(idx).dsrowid;
        COMMIT;
      EXCEPTION
       WHEN OTHERS THEN
         dbms_output.put_line('Erro ao Atualizar crapnrc');
    END;
  END LOOP;
  CLOSE cr_ope;

  COMMIT;
  
END;