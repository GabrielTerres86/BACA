DECLARE
  vr_cdprograma VARCHAR2(15) := 'INCCOTAS';
  vr_dslog VARCHAR2(4000) := ''; 
  vr_idprglog   tbgen_prglog.idprglog%TYPE := 0;
  pr_dscritic   VARCHAR2(4000);

  CURSOR cr_crapcot(pr_cdcooper IN crapass.cdcooper%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT cot.nrdconta
          ,cot.vldcotas
      FROM cecred.crapcot cot
     WHERE cot.cdcooper = pr_cdcooper
       AND cot.nrdconta = pr_nrdconta;
    rw_crapcot cr_crapcot%ROWTYPE;

  CURSOR cr_crapcot_base IS
    SELECT a.*,(vldcotas - vllanmto)
      FROM(
      SELECT cot.CDCOOPER, lct.nrdconta, SUM(decode(his.indebcre, 'D', -1, 1) * lct.vllanmto)vllanmto, cot.vldcotas,cot.PROGRESS_RECID
        FROM craphis his,
             craplct lct,
             crapcot cot
       WHERE his.cdhistor = lct.cdhistor
         AND his.cdcooper = lct.cdcooper
         AND lct.cdcooper = cot.cdcooper 
         AND lct.nrdconta = cot.nrdconta
         AND ((lct.cdcooper = 1  and lct.nrdconta in (10602313,13532715,6191886,8528845,8134782,18032427,11801891,80413153,6977332,
                                                    18502431,3153533,4021878,6492444,14317400,7351224,12497630,12242586)) or
             (lct.cdcooper = 2  and lct.nrdconta in (1096648,917133,1031406,1014331,16700643,14426196)) or
             (lct.cdcooper = 5  and lct.nrdconta in (173088)) or
             (lct.cdcooper = 9  and lct.nrdconta in (107980)) or
             (lct.cdcooper = 10 and lct.nrdconta in (238350,192295)) or
             (lct.cdcooper = 12 and lct.nrdconta in (153214)) or
             (lct.cdcooper = 16 and lct.nrdconta in (60186,472840)))  
    group by lct.nrdconta,cot.vldcotas,cot.CDCOOPER,cot.PROGRESS_RECID) a;
    rw_crapcot_base cr_crapcot_base%ROWTYPE;  
    
BEGIN

  CECRED.pc_log_programa(pr_dstiplog   => 'O'
                        ,pr_dsmensagem => 'Inicio da execucao'
                        ,pr_cdmensagem => 111
                        ,pr_cdprograma => vr_cdprograma
                        ,pr_cdcooper   => 3 
                        ,pr_idprglog   => vr_idprglog);                                        

  FOR rw_crapcot_base IN cr_crapcot_base LOOP     
    vr_dslog := 'UPDATE cecred.crapcot SET vldcotas = '|| rw_crapcot_base.vldcotas ||' WHERE cdcooper = '|| rw_crapcot_base.cdcooper || ' and nrdconta = ' || rw_crapcot_base.nrdconta;
    CECRED.pc_log_programa(pr_dstiplog      => 'O'
                          ,pr_dsmensagem    => vr_dslog
                          ,pr_cdmensagem    => 222
                          ,pr_cdprograma    => vr_cdprograma
                          ,pr_cdcooper      => 3 
                          ,pr_idprglog      => vr_idprglog);
    IF rw_crapcot_base.vllanmto <> rw_crapcot_base.vldcotas THEN          
   
      UPDATE cecred.crapcot a
         SET a.vldcotas = rw_crapcot_base.vllanmto
       WHERE a.cdcooper = rw_crapcot_base.cdcooper
         AND a.nrdconta = rw_crapcot_base.nrdconta;
    ELSE  
      vr_dslog := 'Valores iguais  cdcooper  '|| rw_crapcot_base.cdcooper || ' nrdconta = ' || rw_crapcot_base.nrdconta;
      CECRED.pc_log_programa(pr_dstiplog      => 'O'
                          ,pr_dsmensagem    => vr_dslog
                          ,pr_cdmensagem    => 333
                          ,pr_cdprograma    => vr_cdprograma
                          ,pr_cdcooper      => 3 
                          ,pr_idprglog      => vr_idprglog);
    
    END IF;
   
  END LOOP;
  COMMIT;
EXCEPTION  
  WHEN OTHERS THEN
    pr_dscritic :=  sqlerrm;
    CECRED.pc_log_programa(pr_dstiplog      => 'O'
                          ,pr_dsmensagem    => pr_dscritic
                          ,pr_cdmensagem    => 555
                          ,pr_cdprograma    => vr_cdprograma
                          ,pr_cdcooper      => 3 
                          ,pr_idprglog      => vr_idprglog);    
    ROLLBACK;  
END;    
