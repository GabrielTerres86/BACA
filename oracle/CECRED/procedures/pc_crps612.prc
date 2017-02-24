CREATE OR REPLACE PROCEDURE CECRED.pc_crps612 (pr_dscritic OUT VARCHAR2) IS

  /* ............................................................................

     Programa: PC_CRPS612                       Antigo: Fontes/crps612.p
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Henrique
     Data    : Outubro/2011                         Ultima alteracao: 12/01/2017

     Dados referentes ao programa:

     Frequencia: Diario
     Objetivo  : Buscar titulos gerados no DDA diariamente e gerar mensagem de
                 chegada.
     Alteracoes:
              19/12/2013 - Conversão Progress >> Oracle PL/SQL ( Renato - Supero)
              
              22/02/2016 - Alterado rotina para retirar programa da cadeia e colocar
                           em job com execução diaria SD388026 (Odirlei-AMcom).

              12/01/2017 - #551192 Melhorias de performance e inclusão de logs de controle de execução (Carlos)
  ............................................................................ */
  -- Código do programa
  vr_cdprogra     CONSTANT crapprg.cdprogra%TYPE := 'CRPS612';

  ------------------------------- CURSORES ---------------------------------
  -- Busca dos dados da cooperativa
  CURSOR cr_crapcop IS
    SELECT cop.cdcooper
      FROM crapcop cop
     WHERE cop.cdcooper <> 3
       AND cop.flgativo = 1
     ORDER BY cop.cdcooper;  
  
  ------------------------------- REGISTROS -------------------------------
  rw_crapcop cr_crapcop%ROWTYPE;

  ------------------------------- VARIAVEIS -------------------------------
  
  -- Data de movimento e mês de referencia
  vr_dtmvtolt     DATE;
  vr_dtmvtoan     DATE;

  vr_cdcooper     crapcop.cdcooper%TYPE;

  -- Tratamento de erros
  vr_cdcritic   PLS_INTEGER;
  vr_dscritic   VARCHAR2(4000);

  vr_nomdojob  CONSTANT VARCHAR2(100) := 'jbcobran_crps612';
  vr_idprglog  PLS_INTEGER := 0;


BEGIN

  cecred.pc_log_programa(PR_DSTIPLOG   => 'I'
                        ,PR_CDPROGRAMA => vr_nomdojob                        
                        ,PR_IDPRGLOG   => vr_idprglog);

  -- Incluir nome do módulo logado
  GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra);
  vr_cdcooper := 3;

  --> Definir datas de filtro, processo será rodado todos os dia,
  -- assim buscará sempre os dados do dia anterior
  vr_dtmvtoan := SYSDATE - 1;
  vr_dtmvtolt := SYSDATE;

  -- Buscar os titulos DDA por cooperativa  
  FOR rw_crapcop IN cr_crapcop LOOP
  
    --> Armazenar codigo da cooperativa
    vr_cdcooper := rw_crapcop.cdcooper;

    -- Chama a rotina para envio de mensagens atraves do site de chegada de novos titulos DDA
    DDDA0001.pc_chegada_titulos_DDA(pr_cdcooper => vr_cdcooper
                                   ,pr_cdprogra => vr_cdprogra
                                   ,pr_dtemiini => vr_dtmvtoan
                                   ,pr_dtemifim => vr_dtmvtolt
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);

    -- Verifica se houve crítica
    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);   

    IF TRIM(vr_dscritic) IS NOT NULL THEN
      
      pr_dscritic := 'Coop: ' || vr_cdcooper || ' - ' || vr_dscritic;

      -- Log de alerta de execucao
      cecred.pc_log_programa(PR_DSTIPLOG   => 'E'
                            ,PR_CDPROGRAMA => vr_nomdojob
                            ,pr_tpocorrencia  => 3 -- alerta
                            ,pr_cdcriticidade => 1 -- media
                            ,pr_dsmensagem    => pr_dscritic
                            ,PR_IDPRGLOG      => vr_idprglog);

      ROLLBACK;
      --> Buscar proxima cooperativa
      CONTINUE;
    END IF;

    -- Commitar as alterações
    COMMIT;
    
  END LOOP;  

  -- Log de fim da execucao
  cecred.pc_log_programa(PR_DSTIPLOG   => 'F'
                        ,PR_CDPROGRAMA => vr_nomdojob                        
                        ,PR_IDPRGLOG   => vr_idprglog);
                        
  -- Salvar informacoes no banco de dados
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    
    pc_internal_exception(vr_cdcooper);

    pr_dscritic := 'Coop: ' || vr_cdcooper || ' - ' || sqlerrm;
           
    -- Log de erro de execucao
    cecred.pc_log_programa(PR_DSTIPLOG   => 'E'
                          ,PR_CDPROGRAMA => vr_nomdojob
                          ,pr_tpocorrencia  => 2 -- erro nao tratado
                          ,pr_cdcriticidade => 4
                          ,pr_dsmensagem    => pr_dscritic
                          ,PR_IDPRGLOG      => vr_idprglog);
    -- Efetuar rollback
    ROLLBACK;
END PC_CRPS612;
/
