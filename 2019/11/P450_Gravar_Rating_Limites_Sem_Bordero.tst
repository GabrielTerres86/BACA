PL/SQL Developer Test script 3.0
527
declare 
  vr_tempo_parcial_i DATE;
  vr_tempo_parcial_f VARCHAR2(20);
  vr_tempo_total_i   DATE;
  vr_tempo_total_f   VARCHAR2(20);
  vr_contador  INTEGER;
  vr_retxml      xmltype;
  vr_cdcritic    crapcri.cdcritic%TYPE; --> cód. erro
  vr_dscritic    VARCHAR2(1000); --> desc. erro
  vr_retorno     BOOLEAN DEFAULT(FALSE);

  CURSOR cr_cop IS
    SELECT c.cdcooper
      FROM crapcop c
     WHERE c.flgativo = 1
--       AND C.CDCOOPER = 2
       AND c.cdcooper <> 3
     ORDER BY c.cdcooper;
  RW_COP  CR_COP%ROWTYPE;

  CURSOR CR_DAT (pr_cdcooper  IN crapdat.cdcooper%TYPE) IS
    SELECT dtmvtolt
      FROM crapdat 
     WHERE cdcooper = pr_cdcooper;
  rw_dat  cr_dat%ROWTYPE;

  CURSOR cr_limites_sem_bordero (pr_cdcooper  IN crapcop.cdcooper%TYPE) IS
    SELECT t.cdcooper, t.nrdconta, t.nrctremp, t.tpctrato
          ,a.nrcpfcnpj_base, w.insitlim, a.inpessoa
     FROM tbrisco_operacoes t
         , craplim w
         ,crapass a
     WHERE t.cdcooper       = pr_cdcooper
       AND t.tpctrato       IN(2,3)
       AND t.inrisco_rating_autom IS NULL
       AND t.tpctrato       = w.tpctrlim
       AND t.flintegrar_sas = 0
       AND t.flencerrado    = 0
       AND a.cdcooper = w.cdcooper
       AND a.nrdconta = w.nrdconta
       AND w.cdcooper = t.cdcooper
       AND w.nrdconta = t.nrdconta
       AND w.nrctrlim = t.nrctremp
       AND w.tpctrlim = t.tpctrato
       AND w.insitlim > 1
     ORDER BY t.cdcooper DESC,Insituacao_Rating
             ,t.nrdconta, nrctremp, tpctrato
             ;
   rw_limites_sem_bordero  cr_limites_sem_bordero%ROWTYPE;

  CURSOR cr_limites_sem_rating (pr_cdcooper  IN crapcop.cdcooper%TYPE) IS
    SELECT l.cdcooper, l.nrdconta, l.nrctrlim nrctremp
          ,l.insitlim, l.tpctrlim tpctrato, o.inrisco_rating_autom, o.flintegrar_sas
          ,a.inpessoa, a.nrcpfcnpj_base
      FROM craplim l, tbrisco_operacoes o, crapass a
     WHERE l.cdcooper = pr_cdcooper
       AND l.tpctrlim IN(2,3)
       AND l.insitlim = 2          -- Limites ATIVOS
       AND a.cdcooper = l.cdcooper
       AND a.nrdconta = l.nrdconta
       -- QUE NAO TENHAM RATING
       AND o.cdcooper(+) = l.cdcooper
       AND o.nrdconta(+) = l.nrdconta
       AND o.nrctremp(+) = l.nrctrlim
       AND o.tpctrato(+) = l.tpctrlim
       AND o.inrisco_rating_autom(+) IS NULL
       AND o.flintegrar_sas(+) = 0
    ;

  PROCEDURE pc_insere_rating (pr_cdcooper  IN crapcop.cdcooper%TYPE
                             ,pr_nrdconta  IN crapass.nrdconta%TYPE
                             ,pr_nrctrato  IN crapepr.nrctremp%TYPE
                             ,pr_tpctrato  IN craplim.tpctrlim%TYPE
                             ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE
                             ,pr_Nrcpfcnpj_Base  IN crapass.nrcpfcnpj_base%TYPE
                             ,pr_inpessoa  IN crapass.inpessoa%TYPE)     IS
      vr_dtvencto_Rating  DATE;

    BEGIN

      vr_dtvencto_Rating := pr_dtmvtolt + 180;
      -------------------------------------------------
      --- Gravação do Rating para Limites Sem Rating
      -------------------------------------------------
       INSERT INTO tbrisco_operacoes
                 ( cdcooper
                  ,nrdconta
                  ,nrctremp
                  ,tpctrato
                  ,inrisco_rating
                  ,inrisco_rating_autom
                  ,dtrisco_rating
                  ,insituacao_rating
                  ,inorigem_rating
                  ,cdoperad_rating
                  ,dtrisco_rating_autom
                  ,innivel_rating
                  ,nrcpfcnpj_base
                  ,inpessoa
                  ,inpontos_rating
                  ,insegmento_rating
                  ,dtvencto_rating
                  ,qtdiasvencto_rating
                  ,flintegrar_sas)
           VALUES
                 ( pr_Cdcooper
                  ,pr_Nrdconta
                  ,pr_Nrctrato
                  ,pr_Tpctrato
                  ,NULL --Inrisco_Rating
                  ,NULL -- Inrisco_Rating
                  ,NULL -- dtrisco_rating
                  ,2 -- Analisado insituacao_rating
                  ,3 --REGRA AIMARO  --inorigem_rating
                  ,'1'     --cdoperad_rating
                  ,pr_dtmvtolt    --dtrisco_rating_autom
                  ,2 -- Medio
                  ,pr_Nrcpfcnpj_Base
                  ,pr_Inpessoa
                  ,0 --Pontos Rating
                  ,NULL
                  ,vr_dtvencto_Rating
                  ,180
                  ,1);

       --Deverá ser colocado o log aqui. Até o momento a tabela ainda não foi criada.
       vr_retorno := RATI0003.fn_registra_historico(pr_cdcooper    => pr_cdcooper
                                                   ,pr_cdoperad    => '1'
                                                   ,pr_nrdconta    => pr_nrdconta
                                                   ,pr_nrctro      => pr_Nrctrato
                                                   ,pr_dtmvtolt    => pr_dtmvtolt
                                                   ,pr_valor       => NULL
                                                   ,pr_tpctrato     => pr_Tpctrato
                                                   ,pr_rating_sugerido      => NULL
                                                   ,pr_justificativa        => 'Script LIM ATIVO sem BORDERO [SAS=1 / Rating=Nulo]'
                                                   ,pr_inrisco_rating       => NULL
                                                   ,pr_inrisco_rating_autom => NULL
                                                   ,pr_dtrisco_rating_autom => NULL
                                                   ,pr_dtrisco_rating       => NULL
                                                   ,pr_insituacao_rating    => 2
                                                   ,pr_inorigem_rating      => 3
                                                   ,pr_cdoperad_rating      => '1'
                                                   ,pr_tpoperacao_rating    => NULL
                                                   ,pr_retxml               => vr_retxml
                                                   ,pr_cdcritic             => vr_cdcritic
                                                   ,pr_dscritic             => vr_dscritic);

       IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                   pr_ind_tipo_log => 1, 
                                   pr_des_log      => 'Erro ao inserir/atualizar LOG Risco Operações: ' ||
                                                       ' [' || pr_Cdcooper || '|'||
                                                       pr_Nrdconta         || '|'||
                                                       pr_Nrctrato         || '|'||
                                                       pr_Tpctrato         || '] => '||
                                                       SQLERRM,
                                   pr_dstiplog     => NULL,
                                   pr_nmarqlog     => 'LOG_LIM ATIVO sem BORDERO',
                                   pr_cdprograma   => 'CARGA_UPD',
                                   pr_tpexecucao   => 2);
       END IF;
      -------------------------------------------------
    EXCEPTION
      WHEN OTHERS THEN

        btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                   pr_ind_tipo_log => 1, 
                                   pr_des_log      => 'Erro ao inserir/atualizar Risco Operações: ' ||
                                                       ' [' || pr_Cdcooper || '|'||
                                                       pr_Nrdconta         || '|'||
                                                       pr_Nrctrato         || '|'||
                                                       pr_Tpctrato         || '] => '||
                                                       SQLERRM,
                                   pr_dstiplog     => NULL,
                                   pr_nmarqlog     => 'LOG_Limites_Erro_Carga',
                                   pr_cdprograma   => 'CARGAINI',
                                   pr_tpexecucao   => 2);
   END pc_insere_rating;

  FUNCTION fn_valida_limite_chq_tit(pr_cdcooper IN tbrat_param_geral.cdcooper%TYPE
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE
                                   ,pr_nrctremp IN crapepr.nrctremp%TYPE
                                   ,pr_tpctrato IN tbrisco_operacoes.tpctrato%TYPE
                                   ,pr_dtrefere IN crapdat.dtmvtolt%TYPE)
  /* .............................................................................

        Programa: fn_valida_limite
        Sistema : CRED
        Sigla   :
        Autor   : Guilherme/AMCOM
        Data    : Agosto/2019                 Ultima atualizacao: 04/11/2019


        Frequencia: Sempre que for chamado

        Objetivo  : Verificar se o contrato de limite que esteja cancelado
                   tem Borderos ativo
                   Retorno 1 - Com Bordero Ativo  / 0 - Apenas Bordero Encerrado

        Observacao: -----

        Alteracoes: 04/11/2019 - PJ450 - Bug 27689 - Rating Desc de Titulos/Cheques (estória 26619)
                    Verificar se existem Limite Desconto de Cheque e Título conforme regras
                    já existentes na Central de Risco.
                    (Marcelo Elias Gonçalves - AMcom).                
    ..............................................................................*/

   RETURN INTEGER IS

    --Verificar se existem Borderos de Cheque Ativos
    --04/11/2019 - PJ450 - Bug 27689 - Rating Desc de Cheques (estória 26619)
    CURSOR cr_bordero_chq IS
      SELECT Count(1)  qtd_borderos
        FROM crapbdc bdc
       WHERE bdc.cdcooper  = pr_cdcooper
         AND bdc.nrdconta  = pr_nrdconta
         AND bdc.nrctrlim  = pr_nrctremp
         -- Regra conforme já é feito na Central de Risco.
         AND bdc.dtlibbdc <= pr_dtrefere         
         AND bdc.insitbdc  = 3            
         -- Buscar apenas os borderos que possuem cheque com data liberacao maior que a data do sistema.
         AND EXISTS (SELECT 1
                     FROM   crapcdb cdb
                     WHERE  cdb.cdcooper = bdc.cdcooper
                     AND    cdb.nrborder = bdc.nrborder
                     AND    cdb.dtlibera > pr_dtrefere
                     AND    Nvl(cdb.dtdevolu,pr_dtrefere+1) > pr_dtrefere);                   
    rw_bordero_chq cr_bordero_chq%ROWTYPE;

    --Verificar se existem Borderos de Titulo Ativos
    --04/11/2019 - PJ450 - Bug 27689 - Rating Desc de Titulos (estória 26619)
    CURSOR cr_bordero_tit IS
      SELECT Count(1)  qtd_borderos
        FROM crapbdt bdt
            ,craptdb tdb
       WHERE bdt.cdcooper = pr_cdcooper
         AND bdt.nrdconta = pr_nrdconta
         AND bdt.nrctrlim = pr_nrctremp
         AND tdb.cdcooper = bdt.cdcooper
         AND tdb.nrdconta = bdt.nrdconta
         AND tdb.nrborder = bdt.nrborder
         -- Regra conforme já é feito na Central de Risco.
         -- Borderos Situação 4-Liquidado OU 3-Liberado com data inferior ou igual a de referencia.         
         AND (bdt.insitbdt = 4 OR (bdt.insitbdt = 3 AND bdt.dtlibbdt <= pr_dtrefere))
         -- Titulos Situação 4-Liberado OU 2-Processado com data igual a de processo
         AND (tdb.insittit = 4 OR (tdb.insittit = 2 AND tdb.dtdpagto = pr_dtrefere))
         AND (tdb.insitapr = 1 OR bdt.flverbor = 0);     
    rw_bordero_tit cr_bordero_tit%ROWTYPE;

    vr_qtd_borderos INTEGER := 0;
  BEGIN

    IF pr_tpctrato = 2 THEN
      -- Cheques
      OPEN cr_bordero_chq;
      FETCH cr_bordero_chq
        INTO vr_qtd_borderos;
      CLOSE cr_bordero_chq;
    ELSIF pr_tpctrato = 3 THEN
      -- Titulos
      OPEN cr_bordero_tit;
      FETCH cr_bordero_tit
        INTO vr_qtd_borderos;
      CLOSE cr_bordero_tit;
    ELSE
      RETURN 0; -- Encerrado
    END IF;

    IF vr_qtd_borderos > 0 THEN
      RETURN 1; -- 1 - Com Bordero Ativo
    ELSE
      RETURN 0; -- 0 - Apenas Bordero Encerrado
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END fn_valida_limite_chq_tit;



BEGIN
  
  FOR rw_cop IN cr_cop LOOP
    dbms_output.put_line(rw_cop.cdcooper);
    
    OPEN cr_dat (pr_cdcooper => rw_cop.cdcooper);
    FETCH cr_dat INTO rw_dat;
    CLOSE cr_dat;

    vr_contador := 0;
    vr_tempo_parcial_i := SYSDATE;
    vr_tempo_total_i   := SYSDATE;

    FOR rw_limites_sem_bordero IN cr_limites_sem_bordero (pr_cdcooper => rw_cop.cdcooper) LOOP

      IF rw_limites_sem_bordero.insitlim = 3 THEN -- Limite Cancelado
        -- verificar se tem borderos ativos
        IF fn_valida_limite_chq_tit(pr_cdcooper => rw_limites_sem_bordero.cdcooper,
                                    pr_nrdconta => rw_limites_sem_bordero.nrdconta,
                                    pr_nrctremp => rw_limites_sem_bordero.nrctremp,
                                    pr_tpctrato => rw_limites_sem_bordero.tpctrato,
                                    pr_dtrefere => rw_dat.dtmvtolt) = 1 THEN
          -- se houver bordero ativo, marca para IntegrarSAS
          UPDATE tbrisco_operacoes t
             SET t.flintegrar_sas = 1
           WHERE t.cdcooper = rw_limites_sem_bordero.cdcooper
             AND t.nrdconta = rw_limites_sem_bordero.nrdconta
             AND t.nrctremp = rw_limites_sem_bordero.nrctremp
             AND t.tpctrato = rw_limites_sem_bordero.tpctrato;
          vr_retorno := RATI0003.fn_registra_historico(pr_cdcooper    => rw_limites_sem_bordero.cdcooper
                                                      ,pr_cdoperad    => '1'
                                                      ,pr_nrdconta    => rw_limites_sem_bordero.nrdconta
                                                      ,pr_nrctro      => rw_limites_sem_bordero.nrctremp
                                                      ,pr_dtmvtolt    => rw_dat.dtmvtolt
                                                      ,pr_valor       => NULL
                                                      ,pr_tpctrato     => rw_limites_sem_bordero.Tpctrato
                                                      ,pr_rating_sugerido      => NULL
                                                      ,pr_justificativa        => 'Script LIM ATIVO sem BORDERO [1] [SAS=1 / Rating=Nulo]'
                                                      ,pr_inrisco_rating       => NULL
                                                      ,pr_inrisco_rating_autom => NULL
                                                      ,pr_dtrisco_rating_autom => NULL
                                                      ,pr_dtrisco_rating       => NULL
                                                      ,pr_insituacao_rating    => 2
                                                      ,pr_inorigem_rating      => 3
                                                      ,pr_cdoperad_rating      => '1'
                                                      ,pr_tpoperacao_rating    => NULL
                                                      ,pr_retxml               => vr_retxml
                                                      ,pr_cdcritic             => vr_cdcritic
                                                      ,pr_dscritic             => vr_dscritic);
          IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                       pr_ind_tipo_log => 1, 
                                       pr_des_log      => 'Erro ao inserir/atualizar LOG Risco Operações: ' ||
                                                           ' [' || rw_limites_sem_bordero.Cdcooper || '|'||
                                                           rw_limites_sem_bordero.Nrdconta         || '|'||
                                                           rw_limites_sem_bordero.nrctremp         || '|'||
                                                           rw_limites_sem_bordero.Tpctrato         || '] => '||
                                                           SQLERRM,
                                       pr_dstiplog     => NULL,
                                       pr_nmarqlog     => 'LOG_LIM ATIVO sem BORDERO[1]',
                                       pr_cdprograma   => 'CARGA_UPD',
                                       pr_tpexecucao   => 2);
          END IF;
        ELSE
          -- Se Limite CANCELADO nao tem Bordero ATIVO
          -- Marca contrato como Encerrado
          UPDATE tbrisco_operacoes t
             SET t.flintegrar_sas = 0
                ,t.flencerrado    = 1
           WHERE t.cdcooper = rw_limites_sem_bordero.cdcooper
             AND t.nrdconta = rw_limites_sem_bordero.nrdconta
             AND t.nrctremp = rw_limites_sem_bordero.nrctremp
             AND t.tpctrato = rw_limites_sem_bordero.tpctrato;
          vr_retorno := RATI0003.fn_registra_historico(pr_cdcooper    => rw_limites_sem_bordero.cdcooper
                                                      ,pr_cdoperad    => '1'
                                                      ,pr_nrdconta    => rw_limites_sem_bordero.nrdconta
                                                      ,pr_nrctro      => rw_limites_sem_bordero.nrctremp
                                                      ,pr_dtmvtolt    => rw_dat.dtmvtolt
                                                      ,pr_valor       => NULL
                                                      ,pr_tpctrato     => rw_limites_sem_bordero.Tpctrato
                                                      ,pr_rating_sugerido      => NULL
                                                      ,pr_justificativa        => 'Script LIM CANCELADO sem BORDERO [1] [SAS=0 / ENCERRADO=1]'
                                                      ,pr_inrisco_rating       => NULL
                                                      ,pr_inrisco_rating_autom => NULL
                                                      ,pr_dtrisco_rating_autom => NULL
                                                      ,pr_dtrisco_rating       => NULL
                                                      ,pr_insituacao_rating    => 2
                                                      ,pr_inorigem_rating      => 3
                                                      ,pr_cdoperad_rating      => '1'
                                                      ,pr_tpoperacao_rating    => NULL
                                                      ,pr_retxml               => vr_retxml
                                                      ,pr_cdcritic             => vr_cdcritic
                                                      ,pr_dscritic             => vr_dscritic);
          IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                       pr_ind_tipo_log => 1, 
                                       pr_des_log      => 'Erro ao inserir/atualizar LOG Risco Operações: ' ||
                                                           ' [' || rw_limites_sem_bordero.Cdcooper || '|'||
                                                           rw_limites_sem_bordero.Nrdconta         || '|'||
                                                           rw_limites_sem_bordero.nrctremp         || '|'||
                                                           rw_limites_sem_bordero.Tpctrato         || '] => '||
                                                           SQLERRM,
                                       pr_dstiplog     => NULL,
                                       pr_nmarqlog     => 'LOG_LIM ATIVO sem BORDERO[1]',
                                       pr_cdprograma   => 'CARGA_UPD',
                                       pr_tpexecucao   => 2);
          END IF;
        END IF;
        COMMIT;
      ELSE -- Limite situacao = 2
        -- Independente se tem bordero ativo, mas se o limite está ATIVO
        -- marca para IntegrarSAS
        UPDATE tbrisco_operacoes t
           SET t.flintegrar_sas = 1
         WHERE t.cdcooper = rw_limites_sem_bordero.cdcooper
           AND t.nrdconta = rw_limites_sem_bordero.nrdconta
           AND t.nrctremp = rw_limites_sem_bordero.nrctremp
           AND t.tpctrato = rw_limites_sem_bordero.tpctrato;
         vr_retorno := RATI0003.fn_registra_historico(pr_cdcooper    => rw_limites_sem_bordero.cdcooper
                                                     ,pr_cdoperad    => '1'
                                                     ,pr_nrdconta    => rw_limites_sem_bordero.nrdconta
                                                     ,pr_nrctro      => rw_limites_sem_bordero.nrctremp
                                                     ,pr_dtmvtolt    => rw_dat.dtmvtolt
                                                     ,pr_valor       => NULL
                                                     ,pr_tpctrato     => rw_limites_sem_bordero.Tpctrato
                                                     ,pr_rating_sugerido      => NULL
                                                     ,pr_justificativa        => 'Script LIM ATIVO sem BORDERO [2] [SAS=1 / Rating=Nulo]'
                                                     ,pr_inrisco_rating       => NULL
                                                     ,pr_inrisco_rating_autom => NULL
                                                     ,pr_dtrisco_rating_autom => NULL
                                                     ,pr_dtrisco_rating       => NULL
                                                     ,pr_insituacao_rating    => 2
                                                     ,pr_inorigem_rating      => 3
                                                     ,pr_cdoperad_rating      => '1'
                                                     ,pr_tpoperacao_rating    => NULL
                                                     ,pr_retxml               => vr_retxml
                                                     ,pr_cdcritic             => vr_cdcritic
                                                     ,pr_dscritic             => vr_dscritic);

         IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                     pr_ind_tipo_log => 1, 
                                     pr_des_log      => 'Erro ao inserir/atualizar LOG Risco Operações: ' ||
                                                         ' [' || rw_limites_sem_bordero.Cdcooper || '|'||
                                                         rw_limites_sem_bordero.Nrdconta         || '|'||
                                                         rw_limites_sem_bordero.nrctremp         || '|'||
                                                         rw_limites_sem_bordero.Tpctrato         || '] => '||
                                                         SQLERRM,
                                     pr_dstiplog     => NULL,
                                     pr_nmarqlog     => 'LOG_LIM ATIVO sem BORDERO[2]',
                                     pr_cdprograma   => 'CARGA_UPD',
                                     pr_tpexecucao   => 2);
         END IF;
         COMMIT;
      END IF;
      vr_contador := vr_contador + 1;
    END LOOP;
    vr_tempo_parcial_f := LPAD(TRUNC(((SYSDATE - vr_tempo_parcial_i) * 86400 / 3600)), 2, '0') || ':' ||
                         LPAD(TRUNC(MOD((SYSDATE - vr_tempo_parcial_i) * 86400, 3600) / 60), 2, '0') || ':' ||
                         LPAD(TRUNC(MOD(MOD((SYSDATE - vr_tempo_parcial_i) * 86400, 3600), 60)),
                              2,
                              '0');
    dbms_output.put_line(rw_cop.cdcooper || ' Parte 1: ' ||vr_tempo_parcial_f );

---------------------------------------



---------------------------------------
    vr_tempo_parcial_i := SYSDATE;
    FOR rw_limites_sem_rating IN cr_limites_sem_rating (pr_cdcooper => rw_cop.cdcooper) LOOP

      IF rw_limites_sem_rating.flintegrar_sas IS NULL THEN
        -- registro nao existe
        pc_insere_rating (pr_cdcooper  => rw_limites_sem_rating.cdcooper
                         ,pr_nrdconta  => rw_limites_sem_rating.nrdconta
                         ,pr_nrctrato  => rw_limites_sem_rating.nrctremp
                         ,pr_tpctrato  => rw_limites_sem_rating.tpctrato
                         ,pr_dtmvtolt  => rw_dat.dtmvtolt
                         ,pr_Nrcpfcnpj_Base  => rw_limites_sem_rating.nrcpfcnpj_base
                         ,pr_inpessoa  => rw_limites_sem_rating.inpessoa);
      ELSE  -- existe, mas marca para IntegrarSAS
        UPDATE tbrisco_operacoes t
           SET t.flintegrar_sas = 1
         WHERE t.cdcooper = rw_limites_sem_rating.cdcooper
           AND t.nrdconta = rw_limites_sem_rating.nrdconta
           AND t.nrctremp = rw_limites_sem_rating.nrctremp
           AND t.tpctrato = rw_limites_sem_rating.tpctrato;

         vr_retorno := RATI0003.fn_registra_historico(pr_cdcooper    => rw_limites_sem_rating.cdcooper
                                                     ,pr_cdoperad    => '1'
                                                     ,pr_nrdconta    => rw_limites_sem_rating.nrdconta
                                                     ,pr_nrctro      => rw_limites_sem_rating.nrctremp
                                                     ,pr_dtmvtolt    => rw_dat.dtmvtolt
                                                     ,pr_valor       => NULL
                                                     ,pr_tpctrato     => rw_limites_sem_rating.Tpctrato
                                                     ,pr_rating_sugerido      => NULL
                                                     ,pr_justificativa        => 'Script LIM ATIVO sem BORDERO [3] [SAS=1 / Rating=Nulo]'
                                                     ,pr_inrisco_rating       => NULL
                                                     ,pr_inrisco_rating_autom => NULL
                                                     ,pr_dtrisco_rating_autom => NULL
                                                     ,pr_dtrisco_rating       => NULL
                                                     ,pr_insituacao_rating    => 2
                                                     ,pr_inorigem_rating      => 3
                                                     ,pr_cdoperad_rating      => '1'
                                                     ,pr_tpoperacao_rating    => NULL
                                                     ,pr_retxml               => vr_retxml
                                                     ,pr_cdcritic             => vr_cdcritic
                                                     ,pr_dscritic             => vr_dscritic);

         IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                     pr_ind_tipo_log => 1, 
                                     pr_des_log      => 'Erro ao inserir/atualizar LOG Risco Operações: ' ||
                                                         ' [' || rw_limites_sem_rating.Cdcooper || '|'||
                                                         rw_limites_sem_rating.Nrdconta         || '|'||
                                                         rw_limites_sem_rating.Nrctremp         || '|'||
                                                         rw_limites_sem_rating.Tpctrato         || '] => '||
                                                         SQLERRM,
                                     pr_dstiplog     => NULL,
                                     pr_nmarqlog     => 'LOG_LIM ATIVO sem BORDERO[3]',
                                     pr_cdprograma   => 'CARGA_UPD',
                                     pr_tpexecucao   => 2);
         END IF;
      END IF;
      COMMIT;
      vr_contador := vr_contador + 1;
    END LOOP;
    vr_tempo_parcial_f := LPAD(TRUNC(((SYSDATE - vr_tempo_parcial_i) * 86400 / 3600)), 2, '0') || ':' ||
                         LPAD(TRUNC(MOD((SYSDATE - vr_tempo_parcial_i) * 86400, 3600) / 60), 2, '0') || ':' ||
                         LPAD(TRUNC(MOD(MOD((SYSDATE - vr_tempo_parcial_i) * 86400, 3600), 60)),
                              2,
                              '0');
    dbms_output.put_line(rw_cop.cdcooper || ' Parte 2: ' ||vr_tempo_parcial_f );

    vr_tempo_total_f := LPAD(TRUNC(((SYSDATE - vr_tempo_total_i) * 86400 / 3600)), 2, '0') || ':' ||
                         LPAD(TRUNC(MOD((SYSDATE - vr_tempo_total_i) * 86400, 3600) / 60), 2, '0') || ':' ||
                         LPAD(TRUNC(MOD(MOD((SYSDATE - vr_tempo_total_i) * 86400, 3600), 60)),
                              2,
                              '0');
    dbms_output.put_line(rw_cop.cdcooper || ' TEMPO TOTAL: ' ||vr_tempo_total_f || ' QTD: ' || vr_contador);
    
  END LOOP;
  COMMIT;

end;
0
0
