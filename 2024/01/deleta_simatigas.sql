declare
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000);
  vr_exc_saida EXCEPTION;
  vr_des_reto varchar(3);
  vr_tab_erro GENE0001.typ_tab_erro;
  rw_crapdat  cecred.BTCH0001.cr_crapdat%ROWTYPE;
  
  vr_cdcooper crapass.cdcooper%TYPE := 1;
  vr_nrdconta crapass.nrdconta%TYPE := 86311417;

  CURSOR cr_crapsim is
      SELECT sim.cdcooper,
             sim.cdorigem,
             sim.nrdconta,
             sim.dtmvtolt,
             sim.nrsimula            
        FROM crapsim sim
       WHERE sim.CDCOOPER = vr_cdcooper
         AND sim.NRDCONTA = vr_nrdconta
         AND NOT EXISTS (SELECT 1
                            FROM crawepr wpr
                           WHERE wpr.cdcooper = sim.cdcooper
                             AND wpr.nrdconta = sim.nrdconta
                             AND wpr.nrsimula = sim.nrsimula)
         AND sim.dtmvtolt  < '01/11/2023'; 
         rw_crapsim cr_crapsim%rowtype;
         
     CURSOR cr_crapass IS
    SELECT ass.cdagenci
      FROM cecred.crapass ass
     WHERE ass.cdcooper = vr_cdcooper
       AND ass.nrdconta = vr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;


BEGIN
  OPEN cecred.btch0001.cr_crapdat(1);
  FETCH cecred.btch0001.cr_crapdat  
   INTO rw_crapdat;
  CLOSE cecred.btch0001.cr_crapdat;  

   OPEN cr_crapass;
    FETCH cr_crapass
      INTO rw_crapass;
    CLOSE cr_crapass;           
  
   FOR rw_crapsim in cr_crapsim LOOP
     EMPR0018.pc_exclui_simulacao(pr_cdcooper => rw_crapsim.cdcooper, 
                                pr_cdagenci => rw_crapass.cdagenci, 
                                pr_nrdcaixa => 0, 
                                pr_cdoperad => 1, 
                                pr_nmdatela => 'GERAR LOG', 
                                pr_cdorigem => 21, 
                                pr_nrdconta => rw_crapsim.nrdconta, 
                                pr_idseqttl => 1, 
                                pr_dtmvtolt => rw_crapdat.dtmvtolt, 
                                pr_flgerlog => SYS.DIUTIL.int_to_bool(1),
                                pr_nrsimula => rw_crapsim.nrsimula, 
                                pr_cdcritic => vr_cdcritic,
                                pr_des_erro => vr_dscritic, 
                                pr_des_reto => vr_des_reto, 
                                pr_tab_erro => vr_tab_erro);
                                
                                                                                                             
                        
       IF NOT ( vr_des_reto = 'OK' )
         THEN
           RAISE vr_exc_saida;
       END IF; 
  
   END LOOP;            
 
  COMMIT;
EXCEPTION
  WHEN vr_exc_saida THEN
    RAISE_application_error(-20500, vr_dscritic);
    ROLLBACK;
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
end;
/