/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+------------------------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL                            |
  +---------------------------------+------------------------------------------------+
  | b1wgen0171.p                    | GRVM0001                                       |
  | solicita_baixa_automatica       | grvm0001.pc_solicita_baixa_automatica          |
  | gravames_geracao_arquivo        | grvm0001.pc_gravames_geracao_arquivo           |
  | desfazer_solicitacao_baixa_     | grvm0001.                                      |
  | automatica                      | grvm0001.pc_desfazer_baixa_automatica          |
  | gravames_processamento_retorno  | grvm0001.pc_gravames_processamento_retorno     |
  | gravames_historico              | grvm0001.pc_gravames_historico                 |
  | gravames_impressao_relatorio	  | grvm0001.pc_gravames_impressao_relatorio       |
  | gravames_inclusao_manual        | grvm0001.pc_gravames_inclusao_manual           | 
  | gravames_baixa_manual           | grvm0001.pc_gravames_baixa_manual              |
  | gravames_blqjud                 | grvm0001.pc_gravames_blqjud                    |
  | gravames_cancelar               | grvm0001.pc_gravames_cancelar                  |
  | gravames_alterar                | grvm0001.pc_gravames_alterar                   |
  | gravames_consultar_bens         | grvm0001.pc_gravames_consultar_bens            |
  | gravames_busca_valida_contrato  | grvm0001.pc_gravames_busca_valida_contrato     |
  | valida_eh_alienacao_fiduciaria  | grvm0001.pc_valida_eh_alienacao_fiduciaria     |
  | carrega-cooperativas            | TELA_GRAVAM.pc_buscar_cooperativas             |
  | gravames_busca_pa_associado     | TELA_GRAVAM.pc_gravames_busca_pa_associado     |
  | valida_bens_alienados           | grvm0001.pc_valida_bens_alienados              |
  | registrar_gravames              | grvm0001.pc_registrar_gravames                 |
  +---------------------------------+------------------------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/



/* ..........................................................................

   Programa: Fontes/b1wgen0171.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme/SUPERO
   Data    : Agosto/2013                     Ultima atualizacao: 24/10/2018

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : BO referente a GRAVAM (GRAVAMES)

   Alteracoes: 19/02/2014 - Alteracao do layout do arquivo, deixando dinamico
                            em 4 ou 15 caracteres para o campo cdfingrv, tanto
                            na geracao quanto importacao do arquivo
                            (Guilherme/SUPERO)

               05/03/2014 - Incluso VALIDATE (Daniel).

               31/03/2014 - Alteracao da mensagem na gravames_inclusao_manual
                            (Guilherme/SUPERO)

               29/04/2014 - Alteracao nos parametros das procedures
                            gravames_baixa_manual e gravames_inclusao_manual
                            incluindo o ROWID da BPR para identificar correta-
                            mente a BPR. (Guilherme/SUPERO)

               17/07/2014 - Registrar gravames apenas para contratos criados
                            a partir da data de 23/jul/2014 - Coop 4
                            (Guilherme/SUPERO)

               02/08/2014 - Ajustes Gravames flgokgrv na geracao do arquivo
                            Liberacao Credcrea (7)   (Guilherme/SUPERO)

               29/08/2014 - Liberacao Credelesc (8)
                            Liberacao do baixa_manual independente da situac
                            Considerar apenas as coops liberadas no gerar
                            arquivo   (Guilherme/SUPERO)

               01/10/2014 - Validar gravames apenas para contratos criados
                            a partir da data de 06/Out/2014 - Coop 7
                            OBS.: Para liberacao da CredCrea em out/2014, foi
                            necessario retirar a liberacao da Credelesc(8) que
                            foi efetuada em 29/08. Apos liberacao out/2014,
                            retornar liberacao coop 8
                            (Guilherme/SUPERO)

               13/10/2014 - Permitir Baixa Manual sem informar o nr de registro
                            (Guilherme/SUPERO)

               07/11/2014 - Conversao gravames_geracao_arquivo para Oracle PLSQL
                            e remocao das rotinas dependentes (Marcos-Supero)

               05/12/2014 - Importacao Retorno - Tratar tab GRV por dschassi
                            Incluida geracao do log no arquivo gravam.log quando
                            chama gera_erro
                          - Liberacao para TODAS as cooperativas
                            (Guilherme/SUPERO)

               19/01/2015 - Incluso tratamento na procedure gravames_baixa_manual
                            para permitir baixa quando situacao igual a "3 - Proc.
                            com Critica". SoftDesk 240591 (Daniel)

               28/01/2015 - Adicionado campo PA no relatorio.
                            Adicionado campo dschassi,nranobem,nrmodbem e tpctrpro
                            em proc. gravames_alterar.
                            (Jorge/Gielow) - SD 221854

               26/02/2015 - Alteracao data liberacao Gravames demais coops
                            Remocao da "gera_erro" (Guilherme/SUPERO)

               05/03/2015 - Alterado impressao_relatorio para gerar arquivo de
                            log quando nao encontrar a BPR, com param pesquisa
                            FINDs da BPR incluido campo flgalien = TRUE
                            Incluido TRIM em todas comparacoes do dschassi
                            (Guilherme/SUPERO)

               12/03/2015 - Inclusao do include gera_erro.i e da geracao da
                            tabela de erros na procedure valida_bens_alienados.
                            (Jaison/Gielow - SD: 264448)

               24/03/2015 - Adicionado opcao H - Historico do contrato. 
                            Removido CPF/CNPJ da opcao 'I' quando nao acha 
                            na crapbpr. (Jaison/Irlan - SD: 269240)
                            
               10/04/2015 - Evitar baixa de bens do gravames quando o contrato
                            esta em prejuizo (Gabriel-RKAM).             
                            
               07/08/2015 - Incluido proceduredesfazer_solicitacao_baixa_automatica
                            (Reinert).
                            
               02/12/2015 - Adicionado ao "tt-error" da procedure gravames_geracao_arquivo
                            o erro retornado da chamada da rotina no oracle para resolver 
                            o problema relatado no chamado 363731 (Kelvin).
               
               11/12/2015 - Adicionado validacao para opcao B do gravames conforme solicitado
                            no chamado 365739 (Kelvin).
               
               01/04/2016 - Ajuste na procedure "gravames_alterar". (James)

			   20/05/2016 - Ajustes decorrente a conversção da tela GRAVAM
							(Andrei - RKAM).
              
               19/10/2018 - P442 - Inclusao de opcao OUTROS VEICULOS onde ha procura por CAMINHAO (Marcos-Envolti)

			   24/10/2018 - P442 - Direcionar a chamada das rotinas valida_eh_alienacao_fiduciaria, valida_bens_alienados 
                             e registrar_gravames jah convertidas para a rotina Oracle (Marcos-Envolti)
         
............................................................................. */
DEF STREAM str_1.
DEF STREAM str_2.

{ sistema/generico/includes/b1wgen0171tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_desretor AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdircop AS CHAR                                           NO-UNDO.
DEF VAR aux_dssitgrv AS CHAR                                           NO-UNDO.
DEF VAR aux_inpessoa AS INTE                                           NO-UNDO.
DEF VAR aux_stsnrcal AS LOGI                                           NO-UNDO.
DEF VAR aux_nmarquiv AS CHAR                                           NO-UNDO.
DEF VAR aux_nmrescop AS CHAR                                           NO-UNDO.
DEF VAR aux_hrmvtolt AS CHAR                                           NO-UNDO.
DEF VAR aux_nrseqreg AS INT   INIT 0                                   NO-UNDO.
DEF VAR aux_nrseqtot AS INT   INIT 0                                   NO-UNDO.
DEF VAR aux_contador AS INT                                            NO-UNDO.
DEF VAR aux_setlinha AS CHAR                                           NO-UNDO.
DEF VAR aux_cdfingrv AS CHAR                                           NO-UNDO.
DEF VAR aux_qtsubstr AS INT                                            NO-UNDO.

DEF VAR h-b1wgen0002 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0024 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                         NO-UNDO.

/********************************* PROCEDURES *********************************/

PROCEDURE carrega-cooperativas:

    DEF  INPUT PARAM par_flcecred   AS LOG                          NO-UNDO.
    DEF  INPUT PARAM par_flgtodas   AS LOG                          NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-cooper.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-cooper.


    FOR EACH crapcop NO-LOCK
        WHERE (crapcop.cdcooper <> 3 AND par_flcecred = FALSE)
           OR (par_flcecred):

        CREATE tt-cooper.
        ASSIGN tt-cooper.cdcooper = crapcop.cdcooper
               tt-cooper.nmrescop = crapcop.nmrescop.
    END.


    IF  par_flgtodas THEN DO:
        CREATE tt-cooper.
        ASSIGN tt-cooper.cdcooper = 0
               tt-cooper.nmrescop = "TODAS".
    END.


    RETURN "OK".

END PROCEDURE.

/******************************************************************************/

PROCEDURE valida_eh_alienacao_fiduciaria:

    DEF  INPUT PARAM par_cdcooper AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_nrctrpro AS INT                             NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
    
    RUN STORED-PROCEDURE pc_valida_alienacao_fiduc_prog
    aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper        /* Cooperativa              */ 
                                        ,INPUT par_nrdconta        /* Numero da Conta Corrente */
                                        ,INPUT par_nrctrpro        /* Emprestimo               */
                                        ,OUTPUT ""                 /* Saida OK/NOK */
                                        ,OUTPUT 0                  /* Codigo critica */
                                        ,OUTPUT "").               /* Descriçao da crítica */
    
    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_valida_alienacao_fiduc_prog
      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
    ASSIGN aux_desretor = ""
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_desretor = pc_valida_alienacao_fiduc_prog.pr_des_reto
                          WHEN pc_valida_alienacao_fiduc_prog.pr_des_reto <> ?
           aux_cdcritic = pc_valida_alienacao_fiduc_prog.pr_cdcritic
                          WHEN pc_valida_alienacao_fiduc_prog.pr_cdcritic <> ?
           aux_dscritic = pc_valida_alienacao_fiduc_prog.pr_dscritic
                          WHEN pc_valida_alienacao_fiduc_prog.pr_dscritic <> ?.
    /* Se retornou erro */
    IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN 
    DO:
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 6, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.

    RETURN "OK".

END PROCEDURE.

/******************************************************************************/

PROCEDURE valida_bens_alienados:

    DEF  INPUT PARAM par_cdcooper AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_nrctrpro AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                            NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
    
    RUN STORED-PROCEDURE pc_valida_bens_alienados
    aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper        /* Cooperativa              */ 
                                        ,INPUT par_nrdconta        /* Numero da Conta Corrente */
                                        ,INPUT par_nrctrpro        /* Emprestimo               */
                                        ,OUTPUT 0                  /* Codigo da Critica */
                                        ,OUTPUT "").               /* Descriçao da crítica */
    
    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_valida_bens_alienados
      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_valida_bens_alienados.pr_cdcritic
                          WHEN pc_valida_bens_alienados.pr_cdcritic <> ?
           aux_dscritic = pc_valida_bens_alienados.pr_dscritic
                          WHEN pc_valida_bens_alienados.pr_dscritic <> ?.
    /* Se retornou erro */
    IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN 
    DO:
        
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") + " - " +
                          STRING(TIME,"HH:MM:SS") +
                          " - GRAVAM '-->' "  +
                          "ERRO: " + STRING(aux_cdcritic) + " - " +
                          "'" + aux_dscritic + "'"              +
                          " [valida_bens_alienados]"    +
                          " >> log/gravam.log").
        RETURN "NOK".
    END.

    RETURN "OK".

END PROCEDURE.


/******************************************************************************/

PROCEDURE gravames_geracao_arquivo:

    DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                NO-UNDO.
    DEF  INPUT PARAM par_cdcoptel LIKE crapcop.cdcooper                NO-UNDO.
    DEF  INPUT PARAM par_tparquiv AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.


    EMPTY TEMP-TABLE tt-erro.

    /* Chamar Stored-Proc */
    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE PC_GRAVAMES_GERACAO_ARQUIVO
                         aux_handproc = PROC-HANDLE
       (INPUT par_cdcooper,
        INPUT par_cdcoptel,
        INPUT par_tparquiv,
        INPUT par_dtmvtolt,
        OUTPUT 0,
        OUTPUT "").
    
    IF  ERROR-STATUS:ERROR  THEN DO:
        DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
            ASSIGN aux_msgerora = aux_msgerora +
                                  ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
        END.

        ASSIGN aux_msgerora = "Erro ao executar Stored Procedure: " + aux_msgerora .              

        UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") + " - " +
                          STRING(TIME,"HH:MM:SS") +
                          " - GRAVAM '-->' "  +
                          "ERRO: " + STRING(aux_cdcritic) + " - " +
                          "'" + aux_dscritic + "'"              +
                          " [gravames_processamento_retorno]"    +
                          " >> log/gravam.log").
        RETURN "NOK".
    END.

    CLOSE STORED-PROCEDURE PC_GRAVAMES_GERACAO_ARQUIVO
    WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = PC_GRAVAMES_GERACAO_ARQUIVO.pr_cdcritic
                          WHEN PC_GRAVAMES_GERACAO_ARQUIVO.pr_cdcritic <> ?
           aux_dscritic = PC_GRAVAMES_GERACAO_ARQUIVO.pr_dscritic
                          WHEN PC_GRAVAMES_GERACAO_ARQUIVO.pr_dscritic <> ?.
           
    IF  aux_cdcritic <> 0   OR
        aux_dscritic <> ""  THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = aux_dscritic.
            
            UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") + " - " +
                              STRING(TIME,"HH:MM:SS") +
                              " - GRAVAM '-->' "  +
                              "ERRO: " + STRING(aux_cdcritic) + " - " +
                              "'" + aux_dscritic + "'"              +
                              " [gravames_geracao_arquivo]"    +
                              " >> log/gravam.log").
            RETURN "NOK".

        END.

    RETURN "OK".

END PROCEDURE.


/******************************************************************************/

PROCEDURE registrar_gravames:

    DEF  INPUT PARAM par_cdcooper AS INT                               NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INT                               NO-UNDO.
    DEF  INPUT PARAM par_nrctrpro AS INT                               NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR /* V-VALIDAR / E-EFETIVAR */ NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
    
    RUN STORED-PROCEDURE pc_registrar_gravames
    aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper        /* Cooperativa              */ 
                                        ,INPUT par_nrdconta        /* Numero da Conta Corrente */
                                        ,INPUT par_nrctrpro        /* Emprestimo               */
                                        ,OUTPUT 0                  /* Codigo da Critica */
                                        ,OUTPUT "").               /* Descriçao da crítica */
    
    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_registrar_gravames
      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_registrar_gravames.pr_cdcritic
                          WHEN pc_registrar_gravames.pr_cdcritic <> ?
           aux_dscritic = pc_registrar_gravames.pr_dscritic
                          WHEN pc_registrar_gravames.pr_dscritic <> ?.
    /* Se retornou erro */
    IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN 
    DO:
        
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") + " - " +
                          STRING(TIME,"HH:MM:SS") +
                          " - GRAVAM '-->' "  +
                          "ERRO: " + STRING(aux_cdcritic) + " - " +
                          "'" + aux_dscritic + "'"              +
                          " [registrar_gravames]"    +
                          " >> log/gravam.log").
        RETURN "NOK".
    END.
    

    RETURN "OK".

END PROCEDURE.

/******************************************************************************/

PROCEDURE solicita_baixa_automatica:

    DEF  INPUT PARAM par_cdcooper AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_nrctrpro AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    /* Irlan: Funcao bloqueada temporariamente para demais coops.
       Apenas 1, 4, 7 */
    /*     IF  NOT CAN-DO("1,4,7",STRING(par_cdcooper)) THEN */
    /*         RETURN "OK".                                  */
    /* 23/12/2014 -> LIBERACAO PARA TODAS AS COOPERATIVAS */
            
    /* Nao efetuar baixa do gravames quando contrato esta em prejuizo */
    FIND crapepr WHERE crapepr.cdcooper = par_cdcooper   AND
                       crapepr.nrdconta = par_nrdconta   AND
                       crapepr.nrctremp = par_nrctrpro   AND
                       crapepr.inprejuz = 1
                       NO-LOCK NO-ERROR.

    IF   AVAIL crapepr   THEN
         RETURN "OK".

    /******* VALIDACOES *******/
    RUN valida_eh_alienacao_fiduciaria (INPUT par_cdcooper,
                                        INPUT par_nrdconta,
                                        INPUT par_nrctrpro,
                                       OUTPUT TABLE tt-erro).
    /** OBS: Sempre retornara OK pois a chamada da solicita_baixa_automatica
             nos CRPS171,CRPS078,CRPS120_1,B1WGEN0136, nesses casos nao pode
             impedir de seguir para demais contratos. **/

    IF  RETURN-VALUE <> "OK" THEN
        RETURN "OK".

    FOR EACH crapbpr EXCLUSIVE-LOCK  /* Todos Bens da Proposta */
       WHERE crapbpr.cdcooper = par_cdcooper
         AND crapbpr.nrdconta = par_nrdconta
         AND crapbpr.tpctrpro = 90
         AND crapbpr.nrctrpro = par_nrctrpro
         AND crapbpr.flgalien = TRUE
         AND (crapbpr.dscatbem MATCHES "*AUTOMOVEL*" OR
              crapbpr.dscatbem MATCHES "*MOTO*"      OR
              crapbpr.dscatbem MATCHES "*CAMINHAO*"  OR 
              crapbpr.dscatbem MATCHES "*OUTROS VEICULOS*" ) :

        IF  crapbpr.tpdbaixa = "M" THEN /* Se já foi baixado manual */
            NEXT.

        ASSIGN crapbpr.flgbaixa = TRUE
               crapbpr.dtdbaixa = par_dtmvtolt
               crapbpr.tpdbaixa = "A".
    END.


    RETURN "OK".

END PROCEDURE.


/******************************************************************************/

PROCEDURE desfazer_solicitacao_baixa_automatica:

    DEF INPUT  PARAM par_cdcooper LIKE crapbpr.cdcooper                  NO-UNDO.
    DEF INPUT  PARAM par_nrdconta LIKE crapbpr.nrdconta                  NO-UNDO.
    DEF INPUT  PARAM par_nrctrpro LIKE crapbpr.nrctrpro                  NO-UNDO.   

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    /* Verifica se contrato existe */
    FIND crapepr WHERE crapepr.cdcooper = par_cdcooper   AND
                       crapepr.nrdconta = par_nrdconta   AND
                       crapepr.nrctremp = par_nrctrpro
                       NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapepr   THEN
        DO:
            ASSIGN  aux_cdcritic = 0
                    aux_dscritic = "Contrato de emprestimo nao encontrado.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.        
     
     
    /******* VALIDACOES *******/
    RUN valida_eh_alienacao_fiduciaria (INPUT par_cdcooper,
                                        INPUT par_nrdconta,
                                        INPUT par_nrctrpro,
                                       OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

    FOR EACH crapbpr FIELDS(flgbaixa dtdbaixa tpdbaixa)
                     WHERE crapbpr.cdcooper =  par_cdcooper         /* Cooperativa */
                       AND crapbpr.nrdconta =  par_nrdconta         /* Nr. da Conta */
                       AND crapbpr.nrctrpro =  par_nrctrpro         /* Nr. contrato */
                       AND CAN-DO("90,99",STRING(crapbpr.tpctrpro)) /* Tipo contrato para bens excluidos na ADITIV*/
                       AND crapbpr.flgbaixa =  TRUE                 /* Baixa Solicitada */
                       AND crapbpr.cdsitgrv <> 1                    /* Nao enviado */
                       AND crapbpr.tpdbaixa = "A"                   /* Automatico */
                       AND crapbpr.flblqjud <> 1                    /* Nao bloqueado judicialmente */
                     EXCLUSIVE-LOCK:

        ASSIGN crapbpr.flgbaixa = FALSE
               crapbpr.dtdbaixa = ?
               crapbpr.tpdbaixa = "".

    END.
      
    RETURN "OK".

END PROCEDURE.

/******************************************************************************/

