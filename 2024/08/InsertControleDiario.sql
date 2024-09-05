DECLARE
  vr_cdcooper cecred.crapdat.cdcooper%TYPE := 8;
BEGIN
  MERGE INTO cobranca.tbcobran_controle_diario_liquidacao des
  USING (SELECT dat.dtmvtolt dtreferencia
               ,1            tpmarco
           FROM cecred.crapdat dat
          WHERE dat.cdcooper = vr_cdcooper) ori
  ON (des.dtreferencia = ori.dtreferencia 
  AND des.tpmarco = ori.tpmarco)
  
  WHEN NOT MATCHED THEN
    INSERT
      (dtreferencia
      ,tpmarco
      ,dsobservacao)
    VALUES
      (ori.dtreferencia
      ,ori.tpmarco
      ,' ');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
