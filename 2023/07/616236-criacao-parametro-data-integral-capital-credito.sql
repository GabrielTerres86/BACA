DECLARE 
  vr_cdpartar CECRED.CRAPPAT.CDPARTAR%TYPE;
  
  CURSOR cr_crapcop IS
    SELECT A.CDCOOPER
      FROM CECRED.CRAPCOP A
     WHERE A.FLGATIVO = 1;
BEGIN
  INSERT INTO CECRED.CRAPPAT
  (
    CDPARTAR
    ,NMPARTAR
    ,TPDEDADO
  )
  VALUES
  (
    ( SELECT MAX(C.CDPARTAR) + 1 FROM CECRED.CRAPPAT C )
    , 'DATA_INTEGRALIZACAO_CAPITAL_OPE_CREDITO'
    , 1
  )
  RETURNING CDPARTAR INTO vr_cdpartar;
  
  INSERT INTO CECRED.CRAPPRM
  (
    NMSISTEM
    ,CDCOOPER
    ,CDACESSO
    ,DSTEXPRM
    ,DSVLRPRM
  )
  VALUES
  (
    'CRED'
    ,0
    ,'HIST_BLOQ_INTEGRA'
    ,'Bloquear integralizacao ou plano de cotas caso possua esse historico de lancamento'
    ,'15'
  );
  
  FOR rw_cdcooper  IN cr_crapcop
  LOOP
    INSERT INTO CECRED.CRAPPCO
    (
      CDPARTAR
      ,CDCOOPER
      ,DSCONTEU
    )
    VALUES
    (
      vr_cdpartar
      ,rw_cdcooper.CDCOOPER
      ,'10'
    );
  END LOOP;
  
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    IF cr_crapcop%ISOPEN THEN
      CLOSE cr_crapcop;
    END IF;
    
    ROLLBACK;
END;
  
