DECLARE
 vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS538';
 pr_cdcooper crapcop.cdcooper%TYPE := 1;
 vr_typ_craprej_array  TYP_CRAPREJ_ARRAY := TYP_CRAPREJ_ARRAY();

 vr_cdcritic     INTEGER:= 0;
 vr_dscritic     VARCHAR2(4000);

 -- Busca dados para craprej
 CURSOR cr_craprej (pr_cdcooper    IN NUMBER
                   ,PR_cdprograma  IN VARCHAR2
                   ,pr_dsrelatorio IN VARCHAR2
                   ,pr_dtmvtolt    IN DATE) IS
   SELECT cdcooper
         ,cdprograma
         ,dsrelatorio
         ,dtmvtolt
         ,cdagenci
         ,nrdconta    nrdconta
         ,nrcnvcob    nrseqdig
         ,nrdocmto    nrdocmto
         ,nrctremp    cdbccxlt
         ,tpparcel    cdcritic
         ,vltitulo    vllanmto
         ,dscritic    cdpesqbb
    from TBGEN_BATCH_RELATORIO_WRK
   WHERE cdcooper = pr_cdcooper
     AND cdprograma = PR_cdprograma
     AND dsrelatorio = pr_dsrelatorio
     AND TO_CHAR(dtmvtolt,'YYYYMMDD') = TO_CHAR(pr_dtmvtolt,'YYYYMMDD')
   ORDER BY nrcnvcob
           ,nrdconta
           ,nrdocmto;

 --Procedimento para gravar dados na tabela memoria cratrej
 PROCEDURE pc_carga_cratrej IS
 BEGIN
   -- Refeita procedure - Chamado 714566 - 11/08/2017 
   DECLARE
     vr_index_cratrej   NUMBER(20) := 0;
   BEGIN
     -- Inclusao do nome do modulo logado - 15/03/2018 - Chamado 801483
     GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra || '.pc_carga_cratrej', pr_action => NULL); 
     --Percorrer toda a tabela do relatório
     FOR rw_craprej IN cr_craprej (pr_cdcooper => pr_cdcooper
                                  ,pr_cdprograma => vr_cdprogra
                                  ,pr_dsrelatorio => 'CRAPREJ'
                                  ,pr_dtmvtolt => TO_DATE('20/10/2020','DD/MM/YYYY')) LOOP
         
       --Montar Indice
       vr_index_cratrej := vr_index_cratrej + 1;
       --Gravar dados na tabela memoria
       vr_typ_craprej_array.EXTEND;
       vr_typ_craprej_array(vr_index_cratrej) := 
            TYP_CRAPREJ( rw_craprej.dtmvtolt
                        ,rw_craprej.cdagenci
                        ,rw_craprej.vllanmto
                        ,rw_craprej.nrseqdig
                        ,rw_craprej.cdpesqbb
                        ,rw_craprej.cdcritic
                        ,rw_craprej.cdcooper
                        ,rw_craprej.nrdconta
                        ,rw_craprej.cdbccxlt
                        ,rw_craprej.nrdocmto);
     END LOOP;
   EXCEPTION
     WHEN OTHERS THEN
       -- No caso de erro de programa gravar tabela especifica de log - Chamado 714566 - 11/08/2017 
       CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 
       -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483 
       --Variavel de erro recebe critica ocorrida
       vr_cdcritic := 9999;
       vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                      'CRPS538.pc_carga_cratrej' || 
                      '. ' || SQLERRM; 
       -- Excluido RAISE vr_exc_saida - 15/03/2018 - Chamado 801483
   END;
 END pc_carga_cratrej;

BEGIN
  --
  pc_carga_cratrej;  
  --
  PC_CRPS538_1(pr_cdcooper => 1,
               pr_nmtelant => 'COMPEFORA',
               pr_dsreproc => 'false',
               pr_nmarquiv => '29999O20.RET',
               pr_tab_cratrej => vr_typ_craprej_array);
  --
END;
