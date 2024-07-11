DECLARE
  vr_cdcritic PLS_INTEGER;
  vr_dscritic VARCHAR(500);
  CURSOR cr_propostas IS
    SELECT  (case when TO_NUMBER(TO_CHAR(t.dtinivig,'MMYYYY')) = TO_NUMBER(TO_CHAR(SYSDATE,'MMYYYY')) THEN  
               3852 
            ELSE
               4425
            END)  as cdhistor, t.*
      FROM cecred.tbseg_prestamista t
     WHERE nrproposta IN ('202406211970','202408853661','202408750683','202409149538','202409156856');
BEGIN
  FOR rw_propostas IN cr_propostas LOOP
    cecred.segu0003.pc_efetuar_estorno(pr_cdcooper   => rw_propostas.cdcooper   
                                      ,pr_nrdconta   => rw_propostas.nrdconta   
                                      ,pr_nrctrseg   => rw_propostas.nrctrseg
                                      ,pr_nrctremp   => rw_propostas.nrctremp
                                      ,pr_nrproposta => rw_propostas.nrproposta 
                                      ,pr_dtmvtolt   => TRUNC(SYSDATE)
                                      ,pr_cdhistor   => rw_propostas.cdhistor
                                      ,pr_cdcritic   => vr_cdcritic
                                      ,pr_dscritic   => vr_dscritic);
  END LOOP;

  UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 'RISCO AGRAVADO - Não recomendado pela Comed' ,p.cdmotrec = 154 ,p.tpregist = 0 WHERE p.nrproposta = '202406211970';
  UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 'RISCO AGRAVADO - Não recomendado pela Comed' ,p.cdmotrec = 154 ,p.tpregist = 0 WHERE p.nrproposta = '202408853661';
  UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 'RISCO AGRAVADO - Não recomendado pela Comed' ,p.cdmotrec = 154 ,p.tpregist = 0 WHERE p.nrproposta = '202408750683';
  UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 'RISCO AGRAVADO - Não recomendado pela Comed' ,p.cdmotrec = 154 ,p.tpregist = 0 WHERE p.nrproposta = '202409149538';
  UPDATE cecred.tbseg_prestamista p SET p.situacao = 0, p.dtrecusa = SYSDATE ,p.tprecusa = 'RISCO AGRAVADO - Não recomendado pela Comed' ,p.cdmotrec = 154 ,p.tpregist = 0 WHERE p.nrproposta = '202409156856';

  commit;
  
  UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper =  2 AND s.NRDCONTA = 530867 AND s.nrctrseg = 426761 AND s.tpseguro = 4;
  UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 10 AND s.NRDCONTA = 176680 AND s.nrctrseg =  76010 AND s.tpseguro = 4;
  UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper =  9 AND s.NRDCONTA = 453862 AND s.nrctrseg = 127628 AND s.tpseguro = 4;
  UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper =  2 AND s.NRDCONTA = 530867 AND s.nrctrseg = 437233 AND s.tpseguro = 4;
  UPDATE cecred.crapseg s SET dtcancel= TRUNC(SYSDATE), cdsitseg= 5, cdopeexc= '1', cdageexc= 1, dtinsexc= TRUNC(SYSDATE), cdopecnl= '1' WHERE s.cdcooper = 11 AND s.NRDCONTA = 583685 AND s.nrctrseg = 441533 AND s.tpseguro = 4;

  COMMIT;
END;
