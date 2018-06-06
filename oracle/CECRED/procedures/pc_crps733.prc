CREATE OR REPLACE PROCEDURE CECRED.pc_crps733 IS
/* .............................................................................

   Programa: pc_crps733
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Supero
   Data    : Junho/2018                    Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo: Busca todas as propostas efetivadas para efetivação na esteira.

   Alteracoes:

  ............................................................................. */

  -- Declarações
  -- Tabela que contém o arquivo
  vr_exc_erro              EXCEPTION;
  vr_cdcritic              NUMBER;
  vr_dscritic              VARCHAR2(4000);
  --
  -- Propostas Solicitadas
  CURSOR cur_propostas_crd IS
    SELECT crw.cdcooper
          ,crw.nrdconta
          ,crw.nrctrcrd
          ,crw.cdagenci
          ,crw.cdoperad
          ,crw.cdorigem
          ,crw.dtmvtolt
  FROM crawcrd crw
  WHERE crw.insitcrd in (2,3,4) -- (2 - Solic., 3 - Liberada, 4 - Em uso)
   AND crw.insitdec = 3
   AND crw.flgprcrd = 1 -- considerar só titular
   AND crw.nrcctitg > 0 -- com conta cartao (efetivou no Bancoob)
   AND crw.cdadmcrd between 10 and 80; -- Cartão Cecred
   
  -- Solicitação de limite de credito
  CURSOR cur_alt_limite_crd IS
    select tbla.cdcooper
      ,tbla.nrdconta
      ,crcrd.nrctrcrd
      ,crcrd.cdagenci
      ,crcrd.cdoperad
      ,crcrd.cdorigem
      ,crcrd.dtmvtolt
      ,crcrd.cdadmcrd
  from tbcrd_limite_atualiza tbla
      ,crawcrd crcrd
 where 1=1
   AND tbla.cdcooper   = crcrd.cdcooper
   AND tbla.nrdconta   = crcrd.nrdconta
   AND tbla.insitdec   = 3 -- Aprovado manual
   and tbla.tpsituacao = 3
   AND crcrd.insitcrd  = 4
   AND crcrd.flgprcrd  = 1
   AND crcrd.nrcctitg  = tbla.nrconta_cartao
   AND crcrd.cdadmcrd  = tbla.cdadmcrd
   AND NOT EXISTS (SELECT 1
                   FROM   tbgen_webservice_aciona tbwa
                   WHERE tbwa.dsoperacao LIKE 'ENVIO%PROPOSTA%ESTEIRA%CREDITO'
                   AND tbwa.cdcooper  = tbla.cdcooper
                   AND tbwa.nrdconta  = tbla.nrdconta
                   AND tbwa.nrctrprp  = crcrd.nrctrcrd
                   AND tbwa.tpproduto = 4)
   AND tbla.dtalteracao = (SELECT MAX(tbla1.dtalteracao)
                           FROM   tbcrd_limite_atualiza tbla1
                           WHERE  tbla1.cdcooper = tbla.cdcooper
                           AND    tbla1.nrdconta = tbla.nrdconta);
  --
  -- Subrotinas
  -- Controla Controla log
  PROCEDURE pc_controla_log_batch(pr_idtiplog IN NUMBER   -- Tipo de Log
                                 ,pr_dscritic IN VARCHAR2 -- Descrição do Log
                                 ,pr_cdcooper IN crapcop.cdcooper%TYPE
                                 ) IS
    --
    vr_dstiplog VARCHAR2(10);
    --
  BEGIN
    -- Descrição do tipo de log
    IF pr_idtiplog = 2 THEN
      --
      vr_dstiplog := 'ERRO: ';
      --
    ELSE
      --
      vr_dstiplog := 'ALERTA: ';
      --
    END IF;
    -- Envio centralizado de log de erro
    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                              ,pr_ind_tipo_log => pr_idtiplog
                              ,pr_cdprograma   => 'CRPS733'
                              ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper, 'NOME_ARQ_LOG_MESSAGE')
                              ,pr_des_log      => to_char(sysdate,'hh24:mi:ss') || ' - '
                                                          || 'CRPS733' || ' --> ' || vr_dstiplog
                                                          || pr_dscritic );
  EXCEPTION
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log
      pc_internal_exception (pr_cdcooper => 3);
  END pc_controla_log_batch;

BEGIN
  --
  -- Inicia processo
  pc_controla_log_batch(1, 'Início crps733',3);
  -- 
  FOR r_propostas_crd IN cur_propostas_crd LOOP
    --
    cecred.este0005.pc_efetivar_proposta_est(pr_cdcooper => r_propostas_crd.cdcooper,
                                             pr_cdagenci => r_propostas_crd.cdagenci,
                                             pr_cdoperad => r_propostas_crd.cdoperad,
                                             pr_cdorigem => r_propostas_crd.cdorigem,
                                             pr_nrdconta => r_propostas_crd.nrdconta,
                                             pr_nrctrcrd => r_propostas_crd.nrctrcrd,
                                             pr_dtmvtolt => r_propostas_crd.dtmvtolt,
                                             pr_nmarquiv => NULL, -- TODO - Ver informaticao de arquivo PDF
                                             pr_tpregistro => 'I',
                                             pr_cdcritic => vr_cdcritic,
                                             pr_dscritic => vr_dscritic);
    --
  END LOOP;
  
  FOR r_alt_limite_crd IN cur_alt_limite_crd LOOP
    cecred.este0005.pc_efetivar_proposta_est(pr_cdcooper => r_alt_limite_crd.cdcooper,
                                             pr_cdagenci => r_alt_limite_crd.cdagenci,
                                             pr_cdoperad => r_alt_limite_crd.cdoperad,
                                             pr_cdorigem => r_alt_limite_crd.cdorigem,
                                             pr_nrdconta => r_alt_limite_crd.nrdconta,
                                             pr_nrctrcrd => r_alt_limite_crd.nrctrcrd,
                                             pr_dtmvtolt => r_alt_limite_crd.dtmvtolt,
                                             pr_nmarquiv => NULL, -- TODO - Ver informaticao de arquivo PDF
                                             pr_tpregistro => 'A',
                                             pr_cdcritic => vr_cdcritic,
                                             pr_dscritic => vr_dscritic);
  END LOOP;
  --
  --FOR 
  pc_controla_log_batch(1, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps733 --> Finalizado o processamento.',3);
  --
EXCEPTION
  WHEN vr_exc_erro THEN
    -- Incluído controle de Log
    pc_controla_log_batch(2, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps733 --> ' || vr_dscritic,3);
  WHEN OTHERS THEN
    -- Incluído controle de Log
    pc_controla_log_batch(2, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps733 --> ' || SQLERRM,3);
  --
END;
/
