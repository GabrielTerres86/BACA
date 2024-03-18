DECLARE
vr_cdpartar CRAPPAT.cdpartar%TYPE;
CDPARTAR    CRAPPAT.cdpartar%TYPE;

 CURSOR cr_crapcop IS
      SELECT CDCOOPER
        FROM CECRED.CRAPCOP COP
       WHERE COP.FLGATIVO = 1;
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
    , 'QTD_MESES_TEIMOSINHA_COTAS'
    , 1
  )
  RETURNING CDPARTAR INTO vr_cdpartar;    
  
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
      ,'1'
    );
END LOOP;

COMMIT;
END;
