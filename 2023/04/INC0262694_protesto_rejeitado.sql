DECLARE
  vr_dserro   VARCHAR2(100);
  vr_dscritic VARCHAR2(4000);
  vr_cdcritic NUMBER;
  vr_excerro EXCEPTION;

  vr_tab_remessa_dda DDDA0001.typ_tab_remessa_dda;
  vr_tab_retorno_dda DDDA0001.typ_tab_retorno_dda;

  CURSOR cr_crapcob IS
    SELECT cob.rowid
          ,cob.dtvencto
          ,cob.vldescto
          ,cob.vlabatim
          ,cob.flgdprot
      FROM cecred.crapcob cob
     WHERE cob.cdcooper = 1
       AND (cob.nrdconta, cob.nrcnvcob, cob.nrdocmto) IN ((11303697,101004,927)
                                                         ,(11303697,101004,930))
       AND incobran = 0;
  
  CURSOR cr_crapcob2 IS 
    SELECT cob.rowid dsdrowid
         , cop.cdbcoctl
         , cop.cdagectl
      FROM cecred.crapcop cop
         , cecred.crapcob cob
     WHERE cob.cdcooper = cop.cdcooper
       AND cob.cdcooper = 1
       AND cob.nrdconta = 19504748
       AND cob.nrcnvcob = 101004
       AND cob.nrdocmto = 4385;
  
  rw_crapdat    BTCH0001.cr_crapdat%ROWTYPE; 
  vr_nrretcoo   NUMBER := 0;
  
BEGIN
  
  OPEN  btch0001.cr_crapdat(1);
  FETCH btch0001.cr_crapdat INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;

  FOR rw IN cr_crapcob LOOP
  
    UPDATE cecred.crapcob
       SET crapcob.insitcrt = 0
          ,crapcob.dtsitcrt = NULL
          ,crapcob.dtbloque = NULL
          ,crapcob.flgdprot = 0
          ,crapcob.qtdiaprt = 0
          ,crapcob.dtlipgto = ADD_MONTHS(crapcob.dtlipgto, -60)
     WHERE ROWID = rw.rowid;
  
    paga0001.pc_cria_log_cobranca(pr_idtabcob => rw.rowid
                                 ,pr_cdoperad => '1'
                                 ,pr_dtmvtolt => trunc(SYSDATE)
                                 ,pr_dsmensag => 'Instr de protesto cancelada. Valor superior ao suportado.'
                                 ,pr_des_erro => vr_dserro
                                 ,pr_dscritic => vr_dscritic);
  
  END LOOP;
  
  FOR rw IN cr_crapcob2 LOOP
    
    cobr0011.pc_proc_devolucao(pr_idtabcob     => rw.dsdrowid           
                              ,pr_cdbanpag     => rw.cdbcoctl           
                              ,pr_cdagepag     => rw.cdagectl           
                              ,pr_dtocorre     => TRUNC(SYSDATE)        
                              ,pr_cdocorre     => 89                    
                              ,pr_dsmotivo     => '98'                  
                              ,pr_crapdat      => rw_crapdat            
                              ,pr_cdoperad     => '1'                   
                              ,pr_vltarifa     => 0                     
                              ,pr_ret_nrremret => vr_nrretcoo           
                              ,pr_cdcritic     => vr_cdcritic           
                              ,pr_dscritic     => vr_dscritic);
                                        
    IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      IF TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      
      RAISE vr_excerro;
    END IF; 
    
  END LOOP;
  
  COMMIT;
  
EXCEPTION
  WHEN vr_excerro THEN
    ROLLBACK;
    raise_application_error(-20500, vr_cdcritic || '-' || vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    SISTEMA.excecaoInterna(pr_cdcooper => 3);  
    raise_application_error(-20000, 'ERRO GERAL: '||SQLERRM);
END;
