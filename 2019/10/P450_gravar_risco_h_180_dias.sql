DECLARE

  vr_exc_erro EXCEPTION;
  vr_cdcritic NUMBER;
  vr_dscritic VARCHAR2(1000);
  
  vr_dtrating DATE;
  vr_cont NUMBER := 0;
  
  -- Buscar todas as cooperativas ativas
  CURSOR cr_crapcop IS
    SELECT cop.cdcooper
      FROM crapcop cop
     WHERE cop.flgativo = 1
       AND cop.cdcooper <> 3
     ORDER BY cop.cdcooper DESC;

  -- Cursor genérico de calendário
  CURSOR cr_crapdat(pr_cdcooper IN craptab.cdcooper%TYPE) IS
    SELECT dat.dtmvtolt
          ,dat.dtmvtopr
          ,dat.dtmvtoan
          ,dat.inproces
          ,dat.qtdiaute
          ,dat.cdprgant
          ,dat.dtmvtocd
          ,trunc(dat.dtmvtolt,'mm')               dtinimes -- Pri. Dia Mes Corr.
          ,trunc(Add_Months(dat.dtmvtolt,1),'mm') dtpridms -- Pri. Dia mes Seguinte
          ,last_day(add_months(dat.dtmvtolt,-1))  dtultdma -- Ult. Dia Mes Ant.
          ,last_day(dat.dtmvtolt)                 dtultdia -- Utl. Dia Mes Corr.
          ,rowid
      FROM crapdat dat
     WHERE dat.cdcooper = pr_cdcooper;
  rw_crapdat cr_crapdat%ROWTYPE;
  
  CURSOR cr_tbrisco_operacoes(pr_cdcooper IN crapcop.cdcooper%TYPE
                             ,pr_dtrating IN DATE
                             ,pr_crapdat  IN cr_crapdat%ROWTYPE) IS
    SELECT /*+ INDEX(erp CRAPEPR##CRAPEPR2) */
           epr.cdcooper    cdcooper
          ,epr.nrdconta    nrdconta
          ,epr.nrctremp    nrctrato
          ,opr.tpctrato    tpctrato
          ,2               tpsituacao -- Contrato ativo
          ,opr.rowid       row_id
      FROM tbrisco_operacoes opr
          ,crapepr epr
          ,tbrat_param_geral tpg
     WHERE epr.cdcooper = pr_cdcooper
       AND epr.cdcooper = opr.cdcooper
       AND epr.nrdconta = opr.nrdconta
       AND epr.nrctremp = opr.nrctremp
--       AND opr.flintegrar_sas = 0 -- Se ja esta no lote nao pesquisar novamente
--       AND epr.inliquid = 0   -- Nao pode estar liquidado

       AND (epr.inliquid = 0 OR (epr.inliquid = 1 AND epr.vlsdprej > 0)) --Não Liquidados
       AND epr.inprejuz = 1
       
       AND ((epr.cdfinemp = 68 AND epr.dtmvtolt < pr_dtrating OR
             epr.cdfinemp <> 68)) -- Não pode trazer Empréstimo Pré-Aprovado (Finalidade 68) após a Data de Corte do Projeto Reformulação do Rating (23/08/2019 - Marcelo Gonçalves/AMcom)
       AND epr.cdcooper = tpg.cdcooper
       AND NVL(opr.inpessoa,1) = tpg.inpessoa  -- 16/09/2019 - Na falta considera como PF o parametro
       AND tpg.tpproduto = 90
--       AND opr.inrisco_rating_autom IS NOT NULL
       AND opr.tpctrato = 90
--       AND opr.flencerrado = 0 -- Contratos ativos
       AND ( (nvl(opr.insituacao_rating,3) = 3)
        OR  ((opr.insituacao_rating = 4)
        AND  (nvl(opr.dtvencto_rating,pr_crapdat.dtmvtolt) <= CASE
              WHEN pr_crapdat.dtmvtopr < to_date(tpg.qtdias_atencede_atualizacao||to_char(pr_crapdat.dtmvtolt,'/MM/YYYY'),'DD/MM/YYYY')+1
              THEN pr_crapdat.dtmvtolt+1
              ELSE pr_crapdat.dtultdia END))
        OR (opr.insituacao_rating = 2)
           )
--       AND to_char(pr_crapdat.dtmvtolt,'DD') NOT BETWEEN tpg.qtdias_atencede_atualizacao+1 AND to_char(pr_crapdat.dtultdia,'DD')
       AND risc0004.fn_busca_dias_atraso_ctr(pr_cdcooper => opr.cdcooper
                                            ,pr_nrdconta => opr.nrdconta
                                            ,pr_nrctremp => opr.nrctremp
                                            ,pr_dtmvtoan => pr_crapdat.dtmvtoan
                                            ,pr_tpctrato => opr.tpctrato) > 180;

BEGIN
  vr_dtrating := to_date(gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                   pr_cdcooper => 0,
                                                   pr_cdacesso => 'DT_CORTE_REFOR_RATING'),'dd/mm/rrrr');
  FOR rw_crapcop IN cr_crapcop LOOP
    OPEN cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
   FETCH cr_crapdat
    INTO rw_crapdat;

    IF cr_crapdat%NOTFOUND THEN
      CLOSE cr_crapdat;
      vr_dscritic := 'Data da Cooperativa: '||rw_crapcop.cdcooper||' não encontrada.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapdat;
    END IF;
    
    FOR rw_tbrisco_operacoes IN cr_tbrisco_operacoes(pr_cdcooper => rw_crapcop.cdcooper
                                                    ,pr_dtrating => vr_dtrating
                                                    ,pr_crapdat  => rw_crapdat)  LOOP
      vr_cont := vr_cont + 1;
      -- Atualiza as informações do rating na tabela de operações, com informações internas
      -- Nesse caso do risco 9 ="H", grava esse risco e Não vai buscar na ibratan/lote
      RATI0003.pc_grava_rating_operacao
                           (pr_cdcooper => rw_tbrisco_operacoes.cdcooper   --> Código da Cooperativa
                           ,pr_nrdconta => rw_tbrisco_operacoes.nrdconta   --> Conta do associado
                           ,pr_tpctrato => rw_tbrisco_operacoes.tpctrato   --> Tipo do contrato de rating
                           ,pr_nrctrato => rw_tbrisco_operacoes.nrctrato   --> Número do contrato do rating

                           ,pr_ntrating => 9 	                 --> Nivel de Risco Rating 9- H
                           ,pr_ntrataut => 9                   --> Nivel de Risco Rating 9- H
                           ,pr_dtrating => rw_crapdat.dtmvtolt --> Data de Efetivacao do Rating
                           ,pr_dtrataut => rw_crapdat.dtmvtolt --> Data do Rating retorno
                           ,pr_strating => 4                   --> 4-efetivado

                           ,pr_orrating           =>  3    --> Identificador da Origem do Rating - 3 - Regra Aimaro
                           ,pr_cdoprrat           =>  '1'  --> Codigo Operador que Efetivou o Rating
                           ,pr_innivel_rating     =>  4    --> Classificacao do Nivel de Risco do Rating (1-Baixo/2-Medio/3-Alto/4-Altissimo)
                           ,pr_inpontos_rating    =>  0    --> Pontuacao do Rating quando risco H
                           ,pr_efetivacao_rating  =>  1    --> Não deverá verificar a contingencia
                           ,pr_nrcpfcnpj_base     =>  NULL --> Numero do CPF/CNPJ Base do associado
                           --Variáveis para gravar o histórico
                           ,pr_cdoperad           => '1'                  --> Operador que gerou historico de rating
                           ,pr_dtmvtolt           => rw_crapdat.dtmvtolt  --> Data/Hora do historico de rating
                           ,pr_justificativa      => 'Regra Aimaro 180 dias - ' || to_char(SYSDATE, 'dd/mm/yyyy hh24:mi:ss') || ' [rati0003.pc_atualizar_rating_sas]' --> Justificativa do operador para alteracao do Rating
                           --Variáveis de crítica
                           ,pr_cdcritic           => vr_cdcritic          --> Critica encontrada no processo
                           ,pr_dscritic           => vr_dscritic);        --> Descritivo do erro

      -- Testa inconsistencia
      IF NVL(vr_cdcritic,0) > 0 or TRIM(vr_dscritic) is not null then
        vr_dscritic := 'Erro RATI0003.pc_grava_rating_operacao. ' || vr_dscritic;
        RAISE vr_exc_erro;
      END IF;
      
      BEGIN
        UPDATE tbrisco_operacoes t
           SET t.flencerrado = 1
              ,t.flintegrar_sas = 0
         WHERE ROWID = rw_tbrisco_operacoes.row_id;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro atualizar flintegrar_sas. ' || SQLERRM;
          RAISE vr_exc_erro;
      END;
          
    END LOOP; -- rw_contratos
    
    dbms_output.put_line(rw_crapcop.cdcooper);
    dbms_output.put_line(vr_cont);
  END LOOP; -- rw_crapcop 
         
  COMMIT;

EXCEPTION
  WHEN vr_exc_erro THEN
    dbms_output.put_line(vr_dscritic);
    btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                               pr_ind_tipo_log => 1, 
                               pr_des_log      => vr_dscritic,
                               pr_dstiplog     => NULL,
                               pr_nmarqlog     => 'log_baca_p450',
                               pr_cdprograma   => 'BACAP450',
                               pr_tpexecucao   => 2);
    ROLLBACK;
  WHEN OTHERS THEN
    vr_dscritic:= 'Erro geral. Erro: ' || SQLERRM;
    dbms_output.put_line(vr_dscritic);
    btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                               pr_ind_tipo_log => 1, 
                               pr_des_log      => vr_dscritic,
                               pr_dstiplog     => NULL,
                               pr_nmarqlog     => 'log_baca_p450',
                               pr_cdprograma   => 'BACAP450',
                               pr_tpexecucao   => 2);
    ROLLBACK;
END;
