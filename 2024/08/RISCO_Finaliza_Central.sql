PL/SQL Developer Test script 3.0
257
declare 

  vr_exc_erro  EXCEPTION;
  vr_dscritic  VARCHAR2(4000);
  vr_cdcritic  crapcri.cdcritic%TYPE;

  vr_flgmensal        BOOLEAN;
  vr_dtmvcentral      crapdat.dtmvcentral%TYPE;
  vr_dtmvcentral_ant  crapdat.dtmvcentral%TYPE;
  vr_dtrefere         crapdat.dtmvtolt%TYPE;
  vr_cdproduto        INTEGER;

  vr_cdprogra   VARCHAR2(50) := 'finalizarCentralRisco';
  pr_cdcooper   INTEGER:=1;
  vr_tpCalculo  INTEGER;

  vr_vltotprv NUMBER(14,2); --> Total acumulado de provisão
  vr_vltotdiv NUMBER(14,2); --> Total acumulado de dívida

  CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT cop.nmrescop
          ,cop.nrctactl
          ,cop.dsdircop
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;
BEGIN


  pr_cdcooper        := 1; -- VIACREDI
  vr_dtmvcentral     := to_date('31/07/2024','dd/mm/rrrr');
  vr_dtmvcentral_ant := to_date('30/07/2024','dd/mm/rrrr'); -- Manter a central anterior
  vr_dtrefere        := vr_dtmvcentral;  -- alterar para vr_dtmvcentral quando subir a liberacao final
  vr_cdproduto       := 0; -- Todos disponiveis vr_tpCalculo = 1
  vr_flgmensal       := TRUE;
  vr_tpCalculo       := 1;




  --------------------------------------------------------------------------------------------------------------------------------------------------
  btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                            ,pr_ind_tipo_log => 1
                            ,pr_cdprograma   => 'finalizarCentralRisco-INC0349091'
                            ,pr_nmarqlog     => 'finaliza_central.log'
                            ,pr_des_log      => to_char(sysdate,'dd/mm/rrrr hh24:mi:ss')||' - Iniciando: ' || vr_cdprogra);
  --------------------------------------------------------------------------------------------------------------------------------------------------

  IF vr_tpCalculo = 1 THEN

    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    CLOSE cr_crapcop;


  --------------------------------------------------pc_segregacao_submodalidade--------------------------------------------------------------------
    IF vr_flgmensal AND pr_cdcooper <> 3 THEN
      vr_cdprogra := 'pc_segregacao_submodalidade';
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 1
                                ,pr_cdprograma   => 'finalizarCentralRisco-INC0349091'
                                ,pr_nmarqlog     => 'finaliza_central.log'
                                ,pr_des_log      => to_char(sysdate,'dd/mm/rrrr hh24:mi:ss')||' - Iniciando: ' || vr_cdprogra);

      TELA_CADMOB.pc_segregacao_submodalidade(pr_cdcooper => pr_cdcooper
                                             ,pr_dtmvtolt => vr_dtmvcentral        -- rw_crapdat.dtmvcentral -- ultimo dia do mes - busca da ris.dtrefere
                                             ,pr_dtmvtopr => vr_dtrefere);         -- rw_crapdat.dtmvtolt    -- dia atual info impressa, nao usa em regra de negocio

      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 1
                                ,pr_cdprograma   => 'finalizarCentralRisco-INC0349091'
                                ,pr_nmarqlog     => 'finaliza_central.log'
                                ,pr_des_log      => to_char(sysdate,'dd/mm/rrrr hh24:mi:ss')||' - Finalizado: ' || vr_cdprogra);
    END IF;

  --------------------------------------------------------------contabeis da crps280---------------------------------------------------------------

    IF vr_flgmensal THEN

      vr_cdprogra := 'gerarRelatoriosAjusteCompensacao';
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 1
                                ,pr_cdprograma   => 'finalizarCentralRisco-INC0349091'
                                ,pr_nmarqlog     => 'finaliza_central.log'
                                ,pr_des_log      => to_char(sysdate,'dd/mm/rrrr hh24:mi:ss')||' - Iniciando: ' || vr_cdprogra);

      GESTAODERISCO.gerarRelatoriosAjusteCompensacao(pr_cdcooper => pr_cdcooper
                                                    ,pr_dtrefere => vr_dtrefere
                                                    ,pr_dscritic => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 1
                                ,pr_cdprograma   => 'finalizarCentralRisco-INC0349091'
                                ,pr_nmarqlog     => 'finaliza_central.log'
                                ,pr_des_log      => to_char(sysdate,'dd/mm/rrrr hh24:mi:ss')||' - Finalizado: ' || vr_cdprogra);

      -------------------------- starta o relatorio de cessoes crps715 --------------------------
      IF pr_cdcooper <> 3 THEN

        vr_cdprogra := 'pc_job_contab_cessao';
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 1
                                  ,pr_cdprograma   => 'finalizarCentralRisco-INC0349091'
                                  ,pr_nmarqlog     => 'finaliza_central.log'
                                  ,pr_des_log      => to_char(sysdate,'dd/mm/rrrr hh24:mi:ss')||' - Iniciando: ' || vr_cdprogra);

        pc_job_contab_cessao(pr_cdcooper => pr_cdcooper
                            ,pr_dsjobnam => 'JBCRD_CBCESSAO');

        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 1
                                  ,pr_cdprograma   => 'finalizarCentralRisco-INC0349091'
                                  ,pr_nmarqlog     => 'finaliza_central.log'
                                  ,pr_des_log      => to_char(sysdate,'dd/mm/rrrr hh24:mi:ss')||' - Finalizado: ' || vr_cdprogra);
      END IF;
    END IF;
  --------------------------------------------------------------------------------------------------------------------------------------------------



  ----------------------------------------------------------obterProvisoesBNDES---------------------------------------------------------------------
    IF vr_flgmensal AND pr_cdcooper <> 3 THEN

      vr_cdprogra := 'obterProvisoesBNDES';
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 1
                                ,pr_cdprograma   => 'finalizarCentralRisco-INC0349091'
                                ,pr_nmarqlog     => 'finaliza_central.log'
                                ,pr_des_log      => to_char(sysdate,'dd/mm/rrrr hh24:mi:ss')||' - Iniciando: ' || vr_cdprogra);

      GESTAODERISCO.obterProvisoesBNDES(pr_cdcooper => pr_cdcooper
                                       ,pr_dtrefere => vr_dtmvcentral
                                       ,pr_vltotprv => vr_vltotprv
                                       ,pr_vltotdiv => vr_vltotdiv
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);

      IF NVL(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      BEGIN
        INSERT INTO crapbnd(cdcooper
                           ,dtmvtolt
                           ,nrdconta
                           ,vltotprv
                           ,vltotdiv)
         VALUES(3                      --> Cooperativa conectada
               ,vr_dtrefere    --> Data atual
               ,rw_crapcop.nrctactl    --> Conta da cooperativa conectada
               ,vr_vltotprv            --> Total acumulado de provisão
               ,vr_vltotdiv);          --> Total acumulado de dívidas
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          BEGIN
            UPDATE crapbnd
               SET vltotprv = vr_vltotprv          --> Total acumulado de provisão
                  ,vltotdiv = vr_vltotdiv          --> Total acumulado de dívidas
             WHERE cdcooper = 3                    --> Cooperativa Gravar sempre na Cecred
               AND dtmvtolt = vr_dtrefere  --> Data atual
               AND nrdconta = rw_crapcop.nrctactl; --> Conta da cooperativa conectada
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar crapbnd - '||
                             'vltotprv: '   || vr_vltotprv ||
                             ', vltotdiv: ' || vr_vltotdiv ||
                             ' com cdcooper:3, dtmvtolt: ' || vr_dtrefere ||
                             ', nrdconta:' || rw_crapcop.nrctactl ||
                             '. ' || SQLERRM ;
              RAISE vr_exc_erro;
          END;
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir crapbnd - '||
                         'vltotprv: '   || vr_vltotprv ||
                         ', vltotdiv: ' || vr_vltotdiv ||
                         ' com cdcooper:3, dtmvtolt: ' || vr_dtrefere ||
                         ', nrdconta:' || rw_crapcop.nrctactl ||
                         '. ' || SQLERRM ;
          RAISE vr_exc_erro;
      END;

      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 1
                                ,pr_cdprograma   => 'finalizarCentralRisco-INC0349091'
                                ,pr_nmarqlog     => 'finaliza_central.log'
                                ,pr_des_log      => to_char(sysdate,'dd/mm/rrrr hh24:mi:ss')||' - Finalizado: ' || vr_cdprogra);
    END IF;
  --------------------------------------------------------------------------------------------------------------------------------------------------




  --------------------------------------------------------------limparCentralAnterior--------------------------------------------------------------
    vr_cdprogra := 'limparCentralAnterior';
    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                              ,pr_ind_tipo_log => 1
                              ,pr_cdprograma   => 'finalizarCentralRisco-INC0349091'
                              ,pr_nmarqlog     => 'finaliza_central.log'
                              ,pr_des_log      => to_char(sysdate,'dd/mm/rrrr hh24:mi:ss')||' - Iniciando: ' || vr_cdprogra);

    GESTAODERISCO.limparCentralAnterior(pr_cdcooper => pr_cdcooper
                                       ,pr_dtrefere => vr_dtmvcentral_ant -- central do dia anterior
                                       ,pr_dscritic => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;


   GESTAODERISCO.Limparcargascentralrisco(pr_cdcooper   => pr_cdcooper
                                         ,pr_dtrefere => vr_dtmvcentral_ant -- central do dia anterior
                                         ,pr_cdProcesso => 0
                                         ,pr_dscritic   => vr_dscritic);
   IF vr_dscritic IS NOT NULL THEN
     RAISE vr_exc_erro;
   END IF;

  END IF;
  --------------------------------------------------------------------------------------------------------------------------------------------------




  --------------------------------------------------------------------------------------------------------------------------------------------------
  btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                            ,pr_ind_tipo_log => 1
                            ,pr_cdprograma   => 'finalizarCentralRisco-INC0349091'
                            ,pr_nmarqlog     => 'finaliza_central.log'
                            ,pr_des_log      => to_char(sysdate,'dd/mm/rrrr hh24:mi:ss')||' - Finalizado: ' || vr_cdprogra);
  --------------------------------------------------------------------------------------------------------------------------------------------------
  COMMIT;

EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                              ,pr_ind_tipo_log => 1
                              ,pr_cdprograma   => 'finalizarCentralRisco-INC0349091'
                              ,pr_nmarqlog     => 'finaliza_central.log'
                              ,pr_des_log      => to_char(sysdate,'dd/mm/rrrr hh24:mi:ss') ||
                                                  ' - Erro na execucao: ' || vr_cdprogra ||
                                                  ' - Critica: ' || vr_dscritic);

  WHEN OTHERS THEN
    ROLLBACK;
    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                              ,pr_ind_tipo_log => 1
                              ,pr_cdprograma   => 'finalizarCentralRisco-INC0349091'
                              ,pr_nmarqlog     => 'finaliza_central.log'
                              ,pr_des_log      => to_char(sysdate,'dd/mm/rrrr hh24:mi:ss') ||
                                                  ' - Erro geral na execucao ' ||
                                                  ' - Critica: ' || SQLERRM || ' - ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);


END;
0
6
pr_cdcooper
vr_dtmvcentral
vr_dtrefere
vr_dtmvcentral_ant
vr_flgmensal
vr_tpCalculo
