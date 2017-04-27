CREATE OR REPLACE PROCEDURE CECRED.pc_crps700 (pr_cdcooper IN crapcop.cdcooper%TYPE
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                       ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps700
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Tiago Castro (RKAM)
     Data    : Janeiro/2016                     Ultima atualizacao: 22/03/2017

       Dados referentes ao programa:

       Frequencia: Di�rio (JOB)
       Objetivo  : Popular a tabela de beneficiarios do INSS, apenas inicia JOBS
                   chamando crps700_1.

       Alteracoes: 05/04/2016 - PRJ 255 Fase 2 - Mudan�a no conceito, alterado para
                                apenas importar o arquivo de Prova de Vida enviado
                                pelo SICREDI (Guilherme/SUPERO)
                                
                   17/05/2016 - Incluido tratamento para gerar log de execu��o do job
                                no proc_batch (Odirlei-AMcom)             

                 22/03/2017 - Processamento da planilha foi movido para a PACKAGE0003
                              para que seja utilizada pelo crps e pela tela PRCINS
                              (Douglas - Chamado 618510)

    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- C�digo do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS700';
      vr_nomdojob CONSTANT VARCHAR2(100) := 'JBINSS_IMPBNF_700';

      -- Tratamento de erros
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);
      vr_flgerlog   BOOLEAN := FALSE;
    vr_exc_erro   EXCEPTION;

      -- Variaveis
      vr_dsdireto   VARCHAR2(200);

      ------------------------------- CURSORES ---------------------------------
      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
      ------------------------------- VARIAVEIS -------------------------------

      --------------------------- SUBROTINAS INTERNAS --------------------------
      --> Controla log proc_batch, para apensa exibir qnd realmente processar informa��o
      PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2,
                                      pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
      BEGIN
        
        --> Controlar gera��o de log de execu��o dos jobs 
        BTCH0001.pc_log_exec_job( pr_cdcooper  => nvl(pr_cdcooper,3) --> Cooperativa
                                 ,pr_cdprogra  => vr_cdprogra    --> Codigo do programa
                                 ,pr_nomdojob  => vr_nomdojob    --> Nome do job
                                 ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                                 ,pr_dscritic  => pr_dscritic    --> Critica a ser apresentada em caso de erro
                                 ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim
          
      END pc_controla_log_batch;
      
     
      --------------- VALIDACOES INICIAIS -----------------
    BEGIN
      --> Log de inicio de execu��o
      pc_controla_log_batch(pr_dstiplog => 'I');   

      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
    vr_dsdireto  := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                             ,pr_cdcooper => 0
                                             ,pr_cdacesso => 'DIR_INSS_RECEBE_PV');

    INSS0003.pc_importar_prova_vida(pr_cdprogra => vr_cdprogra   -- Programa que esta executando
                                   ,pr_dsdireto => vr_dsdireto   -- Diretorio onde esta o arquivo
                                   ,pr_cdcritic => vr_cdcritic   -- C�digo da cr�tica
                                   ,pr_dscritic => vr_dscritic); -- Descri��o da cr�tica

    -- Verificar se ocorreu erro no processamento
    IF NVL(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
        END IF;

      ----------------- ENCERRAMENTO DO PROGRAMA -------------------

      --> Log de final de execu��o
      pc_controla_log_batch(pr_dstiplog => 'F');
      
    EXCEPTION
    
    WHEN vr_exc_erro THEN 
        -- Se foi retornado apenas c�digo
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descri��o
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
      
      -- Efetuar retorno do erro n�o tratado
      pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        --> Final da execu��o com ERRO
        pc_controla_log_batch(pr_dstiplog => 'E',
                              pr_dscritic => vr_dscritic);
                          
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') ||
                                                    ' - ' || vr_cdprogra ||
                                                    ' --> ' || pr_dscritic);
                          
        -- Efetuar rollback
        ROLLBACK;


      WHEN OTHERS THEN
        -- Efetuar retorno do erro n�o tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;

        --> Final da execu��o com ERRO
        pc_controla_log_batch(pr_dstiplog => 'E',
                              pr_dscritic => vr_dscritic);
                          
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') ||
                                                    ' - ' || vr_cdprogra ||
                                                    ' --> ' || pr_dscritic);
                          
        -- Efetuar rollback
        ROLLBACK;
    END;

  END pc_crps700;
/
