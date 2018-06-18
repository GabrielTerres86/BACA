CREATE OR REPLACE PROCEDURE CECRED.pc_crps732 IS
/* .............................................................................

   Programa: pc_crps732
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Supero
   Data    : Maio/2018                    Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo: Busca todas as propostas de alteração de limite de cartão que estão expiradas e efetua o cancelamento.

   Alteracoes:

  ............................................................................. */

  -- Declarações
  -- Tabela que contém o arquivo
  vr_exc_erro              EXCEPTION;
  vr_dscritic              VARCHAR2(4000);
  --
  vr_dias_expiracap_prop   NUMBER:=10;
  --
  --
  vr_current_cooper      crapcop.cdcooper%TYPE;
  -- Cooperativas
  CURSOR cur_cooper IS
    SELECT cdcooper
    FROM crapcop
    WHERE flgativo = 1;
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
                              ,pr_cdprograma   => 'CRPS732'
                              ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper, 'NOME_ARQ_LOG_MESSAGE')
                              ,pr_des_log      => to_char(sysdate,'hh24:mi:ss') || ' - '
                                                          || 'CRPS732' || ' --> ' || vr_dstiplog
                                                          || pr_dscritic );
  EXCEPTION
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log
      pc_internal_exception (pr_cdcooper => 3);
  END pc_controla_log_batch;



BEGIN
  --
  FOR rcooper IN cur_cooper LOOP
    --
    vr_current_cooper := rcooper.cdcooper;
    --
    -- Inicia processo
    pc_controla_log_batch(1, 'Início crps732',rcooper.cdcooper);
    --

    BEGIN
      UPDATE crawcrd
      SET  insitcrd = 6--Cancelado.
      WHERE 1=1
      AND   insitcrd = 0
      AND   cdcooper = rcooper.cdcooper
	  AND   cdadmcrd BETWEEN 10 AND 80 -- Bancoob
      AND   dtpropos < TRUNC(SYSDATE)-vr_dias_expiracap_prop;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao tentar cancelar a proposta. '||SQLERRM;
        RAISE vr_exc_erro;
    END;
      --
    --
    BEGIN
      UPDATE tbcrd_limite_atualiza
      SET  tpsituacao = 4
          ,insitdec   = 7
      WHERE 1=1
      AND   cdcooper   = rcooper.cdcooper
      AND   dtalteracao < TRUNC(SYSDATE)-vr_dias_expiracap_prop
      AND   tpsituacao = 6 --Em Análise
      AND   insitdec   = 1; --Sem Aprovacao
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao tentar cancelar a proposta de alteração de limite. '||SQLERRM;
        RAISE vr_exc_erro;
    END;
    --
    COMMIT;
    --
    pc_controla_log_batch(1, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps732 --> Finalizado o processamento.',rcooper.cdcooper);
  END LOOP;
  --
EXCEPTION
  WHEN vr_exc_erro THEN
    -- Incluído controle de Log
    pc_controla_log_batch(2, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps732 --> ' || vr_dscritic,vr_current_cooper);
  WHEN OTHERS THEN
    -- Incluído controle de Log
    pc_controla_log_batch(2, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps732 --> ' || SQLERRM,vr_current_cooper);
  --
END;
/
