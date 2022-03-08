DECLARE
  CURSOR cr_crapcop is
  SELECT * 
    FROM CECRED.CRAPCOP C
   WHERE C.FLGATIVO = 1
     AND C.CDCOOPER <> 3;

  vr_cdcooper       cecred.crapcop.cdcooper%type;     
BEGIN
  FOR rw_crapcop in cr_crapcop LOOP
      vr_cdcooper := rw_crapcop.cdcooper;
      
      INSERT INTO CECRED.CRAPPRM
      (NMSISTEM, CDCOOPER, CDACESSO,DSTEXPRM, DSVLRPRM)
      VALUES
      ('CRED', vr_cdcooper, 'QTD_MAX_ESPERA_BLQPIX', 'Quantidade maxima de espera do farol da criacao da solicitacao de Bloqueio Pix', 10);
    
      COMMIT;
      
  END LOOP;
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,'Erro ao criar o parametro QTD_MAX_ESPERA_BLQPIX para a cooperativa: ' || vr_cdcooper);
END;
