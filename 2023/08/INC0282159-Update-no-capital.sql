DECLARE
  vr_cdprograma VARCHAR2(15) := 'INC0282159';
  vr_idprglog   tbgen_prglog.idprglog%TYPE := 0;
  pr_dscritic   VARCHAR2(4000);
  vr_saldo_capital craplct.vllanmto%TYPE;
     
BEGIN
  SELECT SUM(DECODE(his.indebcre, 'D', -1, 1) * lct.vllanmto)
    INTO vr_saldo_capital   
  FROM cecred.craplct lct, cecred.craphis his
 WHERE lct.cdcooper = his.cdcooper
   AND lct.cdhistor = his.cdhistor
   and lct.cdcooper = 1
   and lct.nrdconta = 11644184;          
   
    UPDATE cecred.crapcot a
       SET a.vldcotas = vr_saldo_capital
     WHERE a.cdcooper = 1
       AND a.nrdconta = 11644184;
   
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    pr_dscritic :=  sqlerrm;
    CECRED.pc_log_programa(pr_dstiplog      => 'O'
                          ,pr_dsmensagem    => pr_dscritic
                          ,pr_cdmensagem    => 111
                          ,pr_cdprograma    => vr_cdprograma
                          ,pr_cdcooper      => 3 
                          ,pr_idprglog      => vr_idprglog);    
    ROLLBACK;  
END;    
