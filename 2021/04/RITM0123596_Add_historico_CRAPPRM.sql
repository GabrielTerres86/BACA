DECLARE
  --
  TYPE tp_hist IS TABLE OF VARCHAR2(10);
  vr_hist_cred tp_hist;
  vr_hist_debt tp_hist;
  --
  vr_exception Exception;
  vr_msg_excpt VARCHAR2(255);
  vr_cdacesso  VARCHAR2(50);
  --
BEGIN
  --
  -- Históricos a Crédito.
  --
  vr_hist_cred := tp_hist('2103','1833','2101','2102','2106','2107','2108','2525','3398','3400','3402','3404','2631','1688','1689','1089','3373','3318','3374','3336');
  --
  FOR x IN vr_hist_cred.first .. vr_hist_cred.last LOOP
    --
    DBMS_OUTPUT.PUT_LINE( vr_hist_cred(x) );
    --
    BEGIN
      --
      SELECT cdacesso
        INTO vr_cdacesso
      FROM cecred.crapprm
      WHERE INSTR( dsvlrprm, ';' || vr_hist_cred(x) || ';' ) > 0
        AND nmsistem = 'CRED'
        AND cdacesso = 'HIS_CRED_RECEBIDOS';
      --
      DBMS_OUTPUT.PUT_LINE( 'JÁ EXISTE' );
      --
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        --
        UPDATE cecred.crapprm
        SET dsvlrprm = dsvlrprm || vr_hist_cred(x) || ';'
        WHERE nmsistem = 'CRED'
          AND cdacesso = 'HIS_CRED_RECEBIDOS';
        --
        DBMS_OUTPUT.PUT_LINE('ATUALIZADOS ' || SQL%ROWCOUNT || ' REGISTROS');
        --
      WHEN OTHERS THEN
        --
        vr_msg_excpt := 'Erro ao atualizar lista de crédito: ' || SQLERRM;
        RAISE vr_exception;
        --
    END;
  END LOOP;
  --
  -- Históricos a Débito.
  --
  vr_hist_debt := tp_hist('3375','3319','3376','3337');
  vr_cdacesso  := NULL;
  --
  DBMS_OUTPUT.PUT_LINE(chr(10) || 'DÉBITOS: ');
  --
  FOR y IN vr_hist_debt.first .. vr_hist_debt.last LOOP
    DBMS_OUTPUT.PUT_LINE(vr_hist_debt(y));
    BEGIN
      --
      SELECT cdacesso
        INTO vr_cdacesso
      FROM cecred.crapprm
      WHERE INSTR( dsvlrprm, ';' || vr_hist_debt(y) || ';' ) > 0
        AND nmsistem = 'CRED'
        AND cdacesso = 'HIS_DEB_DESCONTADOS';
      --
      DBMS_OUTPUT.PUT_LINE( 'JÁ EXISTE' );
      --
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        --
        UPDATE cecred.crapprm
        SET dsvlrprm = dsvlrprm || vr_hist_debt(y) || ';'
        WHERE nmsistem = 'CRED'
          AND cdacesso = 'HIS_DEB_DESCONTADOS';
        --
        DBMS_OUTPUT.PUT_LINE('ATUALIZADOS ' || SQL%ROWCOUNT || ' REGISTROS');
        --
      WHEN OTHERS THEN
        --
        vr_msg_excpt := 'Erro ao atualizar lista de DÉBITO: ' || SQLERRM;
        RAISE vr_exception;
        --
    END;
  END LOOP;
  --
  COMMIT;
  --
EXCEPTION
  WHEN vr_exception THEN
    --
    RAISE_APPLICATION_ERROR(20001, 'Erro: ' || vr_msg_excpt);
    
  WHEN OTHERS THEN
    --
    RAISE_APPLICATION_ERROR(20001, 'Erro: ' || SQLERRM);
END;
