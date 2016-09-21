/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+---------------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL                   |
  +---------------------------------+---------------------------------------+
  | b1wgen0171.p                    | GRVM0001                              |
  | solicita_baixa_automatica       | pc_solicita_baixa_automatica          |
  | gravames_geracao_arquivo        | pc_gravames_geracao_arquivo           |
  | desfazer_solicitacao_baixa_     |                                       |
  | automatica                      | pc_desfazer_baixa_automatica          |
  +---------------------------------+---------------------------------------+

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
   Data    : Agosto/2013                     Ultima atualizacao: 01/04/2016

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
............................................................................. */
DEF STREAM str_1.
DEF STREAM str_2.

/*{ sistema/generico/includes/b1wgen0002tt.i }*/

{ sistema/generico/includes/b1wgen0171tt.i }

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }


DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
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
    DEF  INPUT PARAM par_cddopcao AS CHAR                            NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.


    /* Verifica Cooperativa */
    FIND LAST crapcop
        WHERE crapcop.cdcooper = par_cdcooper
      NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapcop THEN
        DO:
            ASSIGN aux_cdcritic = 794.

            RUN gera_erro (INPUT 3, /*par_cdcooper,*/
                           INPUT 0,
                           INPUT 0,
                           INPUT 1, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

           RETURN "NOK".
    END.

    /* Verifica Associado */
    IF  par_nrdconta = 0 THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = " Informar o numero da Conta! ".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 2, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
    END.

    FIND LAST crapass WHERE crapass.cdcooper = par_cdcooper AND
                            crapass.nrdconta = par_nrdconta
                            NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapass THEN
        DO:
           ASSIGN aux_cdcritic = 9.

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 3, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

           RETURN "NOK".
    END.

    /* Validar se eh Proposta Valida/Existente */
    FIND FIRST crawepr
         WHERE crawepr.cdcooper = par_cdcooper
           AND crawepr.nrdconta = par_nrdconta
           AND crawepr.nrctremp = par_nrctrpro
       NO-LOCK NO-ERROR.

    IF  NOT AVAIL crawepr   THEN DO: /* Contrato nao encontrado */

        ASSIGN aux_cdcritic = 356.
               aux_dscritic = "".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 4, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.

    /** VALIDAR LINHA DE CREDITO DA PROPOSTA - ALIENACAO FIDUCIARIA **/
    FIND FIRST craplcr
         WHERE craplcr.cdcooper = crawepr.cdcooper
           AND craplcr.cdlcremp = crawepr.cdlcremp
           AND craplcr.tpctrato = 2
        NO-LOCK NO-ERROR.

    IF  NOT AVAIL craplcr THEN DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = " Linha de Credito invalida para essa operacao! ".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 5, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".

    END.

    /* Verificar se ha algum BEM tipo AUTOMOVEL/MOTO/CAMINHAO */
    FIND FIRST crapbpr NO-LOCK
         WHERE crapbpr.cdcooper = crawepr.cdcooper
           AND crapbpr.nrdconta = crawepr.nrdconta
           AND crapbpr.tpctrpro = 90
           AND crapbpr.nrctrpro = crawepr.nrctremp
           AND crapbpr.flgalien = TRUE
           AND (crapbpr.dscatbem MATCHES "*AUTOMOVEL*" OR
                crapbpr.dscatbem MATCHES "*MOTO*"      OR
                crapbpr.dscatbem MATCHES "*CAMINHAO*")
        NO-ERROR.

    IF  NOT AVAIL crapbpr THEN DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = " Proposta sem Bem valido ou Bem nao encontado! ".

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

    /* Irlan: Funcao bloqueada temporariamente para demais coops.
       Apenas 1, 4, 7 */
/*     IF  NOT CAN-DO("1,4,7",STRING(par_cdcooper)) THEN */
/*         RETURN "OK".                                  */
/* 23/12/2014 -> LIBERACAO PARA TODAS AS COOPERATIVAS */


    /* Validar se eh Proposta Valida/Existente */
    FIND FIRST crawepr
         WHERE crawepr.cdcooper = par_cdcooper
           AND crawepr.nrdconta = par_nrdconta
           AND crawepr.nrctremp = par_nrctrpro
       NO-LOCK NO-ERROR.

    IF  NOT AVAIL crawepr   THEN DO: /* Contrato nao encontrado */

        ASSIGN aux_cdcritic = 356.
               aux_dscritic = "".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 40, /*sequencia*/
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
    ELSE
        /** Conforme liberando novas Coops, havera novas datas*/
        IF  (crawepr.cdcooper = 1 AND
             crawepr.dtmvtolt < 11/18/2014)
        OR  (crawepr.cdcooper = 4 AND
             crawepr.dtmvtolt < 07/23/2014)
        OR  (crawepr.cdcooper = 7 AND
             crawepr.dtmvtolt < 10/06/2014)
        OR  (NOT CAN-DO("1,4,7",STRING(crawepr.cdcooper)) AND
             crawepr.dtmvtolt < 02/26/2015) THEN
            RETURN "OK".

    /******* VALIDACOES *******/
    RUN valida_eh_alienacao_fiduciaria (INPUT par_cdcooper,
                                        INPUT par_nrdconta,
                                        INPUT par_nrctrpro,
                                        INPUT par_cddopcao,
                                       OUTPUT TABLE tt-erro).
    /** OBS: Sempre retornara OK pois a chamada da valida_bens_alienados
             vem da "EFETIVAR" (LANCTRI e BO00084), nesses casos nao pode
             impedir de seguir para demais contratos. **/
    IF  RETURN-VALUE <> "OK" THEN
        RETURN "OK".

    IF  crawepr.flgokgrv = FALSE THEN DO:

        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Opcao Registro de Gravames, na tela ATENDA " +
                              "nao efetuada! Verifique.".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 7, /*sequencia*/
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

    FOR EACH crapbpr NO-LOCK  /* Todos Bens da Proposta */
       WHERE crapbpr.cdcooper = par_cdcooper
         AND crapbpr.nrdconta = par_nrdconta
         AND crapbpr.tpctrpro = 90
         AND crapbpr.nrctrpro = par_nrctrpro
         AND crapbpr.flgalien = TRUE
         AND (crapbpr.dscatbem MATCHES "*AUTOMOVEL*" OR
              crapbpr.dscatbem MATCHES "*MOTO*"      OR
              crapbpr.dscatbem MATCHES "*CAMINHAO*") :


        IF  crapbpr.cdsitgrv <> 2 THEN DO: /* Se nao tiver alienacao OK */

            CASE crapbpr.cdsitgrv:
                WHEN 0 THEN aux_dscritic = "Arquivo Gravame nao enviado. Verifique".
                WHEN 1 THEN aux_dscritic = "Falta retorno arquivo Gravames. Verifique.".
                WHEN 3 THEN aux_dscritic = "Arquivo Gravames com problemas de processamento. Verifique.".
                WHEN 4 THEN aux_dscritic = "Bem baixado.".
                WHEN 5 THEN aux_dscritic = "Bem cancelado.".
            END CASE.

            ASSIGN aux_cdcritic = 0.

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 8, /*sequencia*/
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
    END.


    RETURN "OK".

END PROCEDURE.

/******************************************************************************/

PROCEDURE gravames_busca_pa_associado:

    DEF  INPUT PARAM par_cdcooper AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INT                             NO-UNDO.
    DEF OUTPUT PARAM ret_cdagenci AS INT                             NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.


    /******* VALIDACOES *******/

    /* Verifica Cooperativa */
    FIND LAST crapcop
        WHERE crapcop.cdcooper = par_cdcooper
      NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapcop THEN
        DO:
           ASSIGN aux_cdcritic = 794.

           RUN gera_erro (INPUT 3, /*par_cdcooper,*/
                          INPUT 0,
                          INPUT 0,
                          INPUT 9, /*sequencia*/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).

           RETURN "NOK".
       END.

    /* Verifica Associado */
    IF  par_nrdconta = 0 THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = " Informar o numero da Conta".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 10, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.

    FIND LAST crapass WHERE crapass.cdcooper = par_cdcooper AND
                            crapass.nrdconta = par_nrdconta
                            NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapass THEN
        DO:
           ASSIGN aux_cdcritic = 9.

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT 0,
                          INPUT 0,
                          INPUT 11, /*sequencia*/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).

           RETURN "NOK".
       END.

    ASSIGN ret_cdagenci = crapass.cdagenci.

    RETURN "OK".

END PROCEDURE.

/******************************************************************************/

PROCEDURE gravames_busca_valida_contrato:

    DEF  INPUT PARAM par_cdcooper AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_nrctrpro AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_flgfirst AS LOGI                            NO-UNDO.
    DEF OUTPUT PARAM ret_qtctrepr AS INT  INIT 0                     NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-contratos.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-contratos.



    /* Cria TT de Propostas Validas para o F7 */
    FOR EACH crawepr NO-LOCK
       WHERE crawepr.cdcooper = par_cdcooper
         AND crawepr.nrdconta = par_nrdconta,
       FIRST craplcr NO-LOCK /** Alienacao Fiduciaria **/
       WHERE craplcr.cdcooper = crawepr.cdcooper
         AND craplcr.cdlcremp = crawepr.cdlcremp
         AND craplcr.tpctrato = 2,
        EACH crapbpr NO-LOCK  /* Bens da Proposta */
       WHERE crapbpr.cdcooper = crawepr.cdcooper
         AND crapbpr.nrdconta = crawepr.nrdconta
         AND crapbpr.tpctrpro = 90
         AND crapbpr.nrctrpro = crawepr.nrctremp
         AND crapbpr.flgalien = TRUE
         AND (crapbpr.dscatbem MATCHES "*AUTOMOVEL*" OR
              crapbpr.dscatbem MATCHES "*MOTO*"      OR
              crapbpr.dscatbem MATCHES "*CAMINHAO*")
        BREAK BY crawepr.nrctremp:

        IF  FIRST-OF (crawepr.nrctremp) THEN DO:
            CREATE tt-contratos.
            ASSIGN tt-contratos.nrctrpro = crawepr.nrctremp
                   ret_qtctrepr          = ret_qtctrepr + 1.
        END.
    END.

    IF  ret_qtctrepr = 0 THEN
        RETURN "NOK".



    IF  par_nrctrpro <> 0 THEN DO:

        /******* VALIDACOES *******/
        RUN valida_eh_alienacao_fiduciaria (INPUT par_cdcooper,
                                            INPUT par_nrdconta,
                                            INPUT par_nrctrpro,
                                            INPUT par_cddopcao,
                                           OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN
            RETURN "NOK".

    END.
    ELSE DO:
        IF  NOT par_flgfirst THEN DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = " Numero da Proposta de Emprestimo deve ser informada! ".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 12, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") + " - " +
                              STRING(TIME,"HH:MM:SS") +
                              " - GRAVAM '-->' "  +
                              "ERRO: " + STRING(aux_cdcritic) + " - " +
                              "'" + aux_dscritic + "'"              +
                              " [gravames_busca_valida_contrato]"    +
                              " >> log/gravam.log").
            RETURN "NOK".
        END.
    END.



    RETURN "OK".

END PROCEDURE.

/******************************************************************************/

PROCEDURE gravames_consultar_bens :

    DEF  INPUT PARAM par_cdcooper AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_nrctrpro AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_nrgravam AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_tpconsul AS CHAR                            NO-UNDO.

    DEF OUTPUT PARAM ret_qtdebens AS INT  INIT 0                     NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-bens-gravames.
    DEF OUTPUT PARAM TABLE FOR tt-bens-zoom.


    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-bens-gravames.
    EMPTY TEMP-TABLE tt-bens-zoom.


    /******* VALIDACOES *******/
    RUN valida_eh_alienacao_fiduciaria (INPUT par_cdcooper,
                                        INPUT par_nrdconta,
                                        INPUT par_nrctrpro,
                                        INPUT par_cddopcao,
                                       OUTPUT TABLE tt-erro).
    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".



    /* Cria TT de Propostas Validas para o F7 */
    FOR EACH crawepr NO-LOCK
       WHERE crawepr.cdcooper = par_cdcooper
         AND crawepr.nrdconta = par_nrdconta
         AND crawepr.nrctremp = par_nrctrpro,
       FIRST craplcr NO-LOCK /** Alienacao Fiduciaria **/
       WHERE craplcr.cdcooper = crawepr.cdcooper
         AND craplcr.cdlcremp = crawepr.cdlcremp
         AND craplcr.tpctrato = 2,
        EACH crapbpr NO-LOCK  /* Bens da Proposta */
       WHERE crapbpr.cdcooper = crawepr.cdcooper
         AND crapbpr.nrdconta = crawepr.nrdconta
        /* AND crapbpr.tpctrpro = 90 */
         AND crapbpr.nrctrpro = crawepr.nrctremp
         AND crapbpr.flgalien = TRUE
         AND (crapbpr.dscatbem MATCHES "*AUTOMOVEL*" OR
              crapbpr.dscatbem MATCHES "*MOTO*"      OR
              crapbpr.dscatbem MATCHES "*CAMINHAO*")
        BREAK BY crawepr.nrctremp:

        CREATE tt-bens-zoom.
        BUFFER-COPY crapbpr TO tt-bens-zoom.

        ASSIGN ret_qtdebens          = ret_qtdebens + 1
               tt-bens-zoom.nrseqbem = ret_qtdebens
               tt-bens-zoom.rowidbpr = ROWID(crapbpr).

        IF  par_nrgravam = 0 THEN DO:
            /*Se informou Zero na tela, deve pesquisar todos.
              Basta entao, copiar da tt de Zoom os mesmos dados */


            CREATE tt-bens-gravames.
            BUFFER-COPY tt-bens-zoom TO tt-bens-gravames.


            /** Verificar o tipo do CPF/CNPJ do bem **/
            RUN sistema/generico/procedures/b1wgen9999.p
                PERSISTENT SET h-b1wgen9999.

            RUN valida-cpf-cnpj IN h-b1wgen9999
                      (INPUT crapbpr.nrcpfbem,
                      OUTPUT aux_stsnrcal,
                      OUTPUT aux_inpessoa).

            IF  VALID-HANDLE(h-b1wgen9999)  THEN
                DELETE PROCEDURE h-b1wgen9999.

            IF  aux_inpessoa = 1  THEN
                ASSIGN tt-bens-gravames.dscpfbem =
                       STRING(STRING(tt-bens-gravames.nrcpfbem,
                         "99999999999"),"xxx.xxx.xxx-xx").
            ELSE
                ASSIGN tt-bens-gravames.dscpfbem =
                       STRING(STRING(tt-bens-gravames.nrcpfbem,
                         "99999999999999"),"xx.xxx.xxx/xxxx-xx").

            ASSIGN tt-bens-gravames.vlctrgrv = crawepr.vlemprst
                   tt-bens-gravames.dtoperac = crawepr.dtmvtolt
                   tt-bens-gravames.dtmvtolt = crapbpr.dtatugrv.

            ASSIGN tt-bens-gravames.dschassi = crapbpr.dschassi.

            IF  crapbpr.ufplnovo <> ""
            AND crapbpr.nrplnovo <> ""
            AND crapbpr.nrrenovo > 0 THEN
                ASSIGN tt-bens-gravames.nrdplaca = crapbpr.nrplnovo
                       tt-bens-gravames.ufdplaca = crapbpr.ufplnovo
                       tt-bens-gravames.nrrenava = crapbpr.nrrenovo.

            CASE crapbpr.cdsitgrv:
                WHEN 0 THEN tt-bens-gravames.dssitgrv = "Nao Enviado".
                WHEN 1 THEN tt-bens-gravames.dssitgrv = "Em Processamento".
                WHEN 2 THEN tt-bens-gravames.dssitgrv = "Alienacao".
                WHEN 3 THEN tt-bens-gravames.dssitgrv = "Processado com Critica".
                WHEN 4 THEN tt-bens-gravames.dssitgrv = "Baixado".
                WHEN 5 THEN tt-bens-gravames.dssitgrv = "Cancelado".
            END CASE.

            IF  crapbpr.flblqjud = 1 THEN
                ASSIGN tt-bens-gravames.dsblqjud = "SIM".
            ELSE
                ASSIGN tt-bens-gravames.dsblqjud = "NAO".
        END.
    END.

/*** Condicao retirada em 13/10/2014, permitir Baixa Manual sem informar Nr.Registro
    IF  par_nrgravam = 0
    AND par_cddopcao = "B"
    AND par_tpconsul = "T" THEN DO: /* BAIXA MANUAL NAO PERMITE PESQUISAR TODOS*/

        ASSIGN aux_cdcritic = 0
               aux_dscritic = " Para Baixa Manual, numero do Gravame deve ser informado!".

        RETURN "NOK".
    END.
************/


    IF  par_nrgravam <> 0 THEN DO:
        FIND FIRST crapbpr NO-LOCK  /* Bens da Proposta */
             WHERE crapbpr.cdcooper = par_cdcooper
               AND crapbpr.nrdconta = par_nrdconta
               AND crapbpr.tpctrpro = 90
               AND crapbpr.nrctrpro = par_nrctrpro
               AND crapbpr.nrgravam = par_nrgravam
               AND crapbpr.flgalien = TRUE
               AND (crapbpr.dscatbem MATCHES "*AUTOMOVEL*" OR
                    crapbpr.dscatbem MATCHES "*MOTO*"      OR
                    crapbpr.dscatbem MATCHES "*CAMINHAO*") NO-ERROR.

        IF  AVAIL crapbpr THEN DO:

            FIND FIRST crawepr NO-LOCK
                 WHERE crawepr.cdcooper = par_cdcooper
                   AND crawepr.nrdconta = par_nrdconta
                   AND crawepr.nrctremp = par_nrctrpro
                NO-ERROR.

            CREATE tt-bens-gravames.
            BUFFER-COPY crapbpr TO tt-bens-gravames.

            find first tt-bens-zoom
                where tt-bens-zoom.idseqbem = tt-bens-gravames.idseqbem
                 no-lock no-error.

            ASSIGN tt-bens-gravames.vlctrgrv = crawepr.vlemprst
                   tt-bens-gravames.dtoperac = crawepr.dtmvtolt
                   tt-bens-gravames.dtmvtolt = crapbpr.dtatugrv
                   tt-bens-gravames.nrseqbem = tt-bens-zoom.nrseqbem
                   /*1*/
                   tt-bens-gravames.rowidbpr = ROWID(crapbpr).

            ASSIGN tt-bens-gravames.dschassi = crapbpr.dschassi.

            IF  crapbpr.nrplnovo <> ""
            AND crapbpr.ufplnovo <> ""
            AND crapbpr.nrrenovo > 0 THEN
                ASSIGN tt-bens-gravames.nrdplaca = crapbpr.nrplnovo
                       tt-bens-gravames.ufdplaca = crapbpr.ufplnovo
                       tt-bens-gravames.nrrenava = crapbpr.nrrenovo.

            CASE crapbpr.cdsitgrv:
                WHEN 0 THEN tt-bens-gravames.dssitgrv = "Nao Enviado".
                WHEN 1 THEN tt-bens-gravames.dssitgrv = "Em Processamento".
                WHEN 2 THEN tt-bens-gravames.dssitgrv = "Alienacao".
                WHEN 3 THEN tt-bens-gravames.dssitgrv = "Processado com Critica".
                WHEN 4 THEN tt-bens-gravames.dssitgrv = "Baixado".
                WHEN 5 THEN tt-bens-gravames.dssitgrv = "Cancelado".
            END CASE.

            IF  crapbpr.flblqjud = 1 THEN
                ASSIGN tt-bens-gravames.dsblqjud = "SIM".
            ELSE
                ASSIGN tt-bens-gravames.dsblqjud = "NAO".
        END.
    END.


    RETURN "OK".

END PROCEDURE.

/******************************************************************************/

PROCEDURE gravames_alterar :

    DEF  INPUT PARAM par_cdcooper AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_nrctrpro AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_idseqbem AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.

    DEF  INPUT PARAM par_dscatbem AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_dschassi AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_ufdplaca AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_nrdplaca AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_nrrenava AS DECI                            NO-UNDO.
    DEF  INPUT PARAM par_nranobem AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrmodbem AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_tpctrpro AS INTE                            NO-UNDO.

    DEF  INPUT PARAM par_cddopcao AS CHAR                            NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_dstransa AS CHAR                                     NO-UNDO.
    DEF VAR aux_nrdrowid AS ROWID                                    NO-UNDO.

    DEF VAR aux_antdscha LIKE crapbpr.dschassi                       NO-UNDO.
    DEF VAR aux_antufdpl LIKE crapbpr.ufdplaca                       NO-UNDO.
    DEF VAR aux_antnrdpl LIKE crapbpr.nrdplaca                       NO-UNDO.
    DEF VAR aux_antnrren LIKE crapbpr.nrrenava                       NO-UNDO.
    DEF VAR aux_nranobem LIKE crapbpr.nranobem                       NO-UNDO.
    DEF VAR aux_nrmodbem LIKE crapbpr.nrmodbem                       NO-UNDO.
    
    DEF VAR aux_flchassi AS LOG INIT FALSE                           NO-UNDO.
    DEF VAR aux_flrenava AS LOG INIT FALSE                           NO-UNDO.
    DEF VAR aux_flufplac AS LOG INIT FALSE                           NO-UNDO.
    DEF VAR aux_flnrplac AS LOG INIT FALSE                           NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.


    ASSIGN aux_dstransa = "Alterar o valor do gravames".

    /******* VALIDACOES *******/
    RUN valida_eh_alienacao_fiduciaria (INPUT par_cdcooper,
                                        INPUT par_nrdconta,
                                        INPUT par_nrctrpro,
                                        INPUT par_cddopcao,
                                       OUTPUT TABLE tt-erro).
    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

    /** VALIDAR **/
    IF   par_dschassi = ""
    OR   par_nrdplaca = ""
    OR   par_ufdplaca = ""
    OR   par_nrrenava = 0 THEN
         ASSIGN aux_cdcritic = 0
                aux_dscritic = "Chassi, UF, Nr. da Placa e Renavam sao obrigatorios!".
    
    IF   CAN-DO("MOTO,AUTOMOVEL",TRIM(par_dscatbem)) AND
         LENGTH(TRIM(par_dschassi)) < 17 THEN
         ASSIGN aux_cdcritic = 0
                aux_dscritic = "Numero do chassi incompleto, verifique.".
        
    IF   CAN-DO("MOTO,AUTOMOVEL,CAMINHAO",TRIM(par_dscatbem)) AND
         LENGTH(TRIM(par_dschassi)) > 17 THEN
         ASSIGN aux_cdcritic = 0
                aux_dscritic = "Numero do chassi maior que o tamanho maximo.".
    
    IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
    DO:
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 14, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") + " - " +
                          STRING(TIME,"HH:MM:SS") +
                          " - GRAVAM '-->' "  +
                          "ERRO: " + STRING(aux_cdcritic) + " - " +
                          "'" + aux_dscritic + "'"              +
                          " [gravames_alterar]"    +
                          " >> log/gravam.log").
        RETURN "NOK".
    END.

    /* Localizar registro e efetuar alteracao */
    FIND FIRST crapbpr EXCLUSIVE-LOCK
         WHERE crapbpr.cdcooper = par_cdcooper
           AND crapbpr.nrdconta = par_nrdconta
           AND crapbpr.tpctrpro = par_tpctrpro
           AND crapbpr.nrctrpro = par_nrctrpro
           AND crapbpr.idseqbem = par_idseqbem
           AND crapbpr.flgalien = TRUE
           AND (crapbpr.dscatbem MATCHES "*AUTOMOVEL*" OR
                crapbpr.dscatbem MATCHES "*MOTO*"      OR
                crapbpr.dscatbem MATCHES "*CAMINHAO*")
            NO-ERROR.

    IF  AVAIL crapbpr THEN 
    DO:
        /* Apenas poder alterar chassi quando 
           status for 0 ("nao enviado") ou 
                      3 (processado com critica)  */
        IF  crapbpr.dschassi <> par_dschassi AND 
            crapbpr.cdsitgrv <> 0 AND crapbpr.cdsitgrv <> 3 THEN
        DO:
            ASSIGN aux_dscritic = "Alteracao de chassi nao permitida.".
            RUN gera_erro(INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 14, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") + " - " +
                              STRING(TIME,"HH:MM:SS") +
                              " - GRAVAM '-->' "  +
                              "ERRO: " + STRING(aux_cdcritic) + " - " +
                              "'" + aux_dscritic + "'"              +
                              " [gravames_alterar]"    +
                              " >> log/gravam.log").
            RETURN "NOK".
        END.

        ASSIGN aux_nranobem     = crapbpr.nranobem
               aux_nrmodbem     = crapbpr.nrmodbem
               crapbpr.flgalter = TRUE
               crapbpr.dtaltera = par_dtmvtolt
               crapbpr.tpaltera = "M".
               

        /* guardar em log apenas campos que tiveram seu conteudo alterado */
        
        IF crapbpr.dschassi <> TRIM(par_dschassi) THEN
           ASSIGN aux_antdscha = crapbpr.dschassi
                  aux_flchassi = TRUE.
               
        IF (crapbpr.ufdplaca <> TRIM(par_ufdplaca) AND crapbpr.ufplnovo = "") OR
           (crapbpr.ufplnovo <> TRIM(par_ufdplaca) AND crapbpr.ufplnovo <> "") THEN
           ASSIGN aux_antufdpl = IF   crapbpr.ufplnovo = "" 
                                 THEN crapbpr.ufdplaca
                                 ELSE crapbpr.ufplnovo
                  aux_flufplac = TRUE.
               
        IF (crapbpr.nrdplaca <> TRIM(par_nrdplaca) AND crapbpr.nrplnovo = "") OR
           (crapbpr.nrplnovo <> TRIM(par_nrdplaca) AND crapbpr.nrplnovo <> "") THEN
           ASSIGN aux_antnrdpl = IF   crapbpr.nrplnovo = "" 
                                 THEN crapbpr.nrdplaca
                                 ELSE crapbpr.nrplnovo
                  aux_flnrplac = TRUE.
               
        IF (crapbpr.nrrenava <> par_nrrenava AND crapbpr.nrrenovo = 0) OR
           (crapbpr.nrrenovo <> par_nrrenava AND crapbpr.nrrenovo <> 0) THEN
           ASSIGN aux_antnrren = IF   crapbpr.nrrenovo = 0 
                                 THEN crapbpr.nrrenava
                                 ELSE crapbpr.nrrenovo
                  aux_flrenava = TRUE.
               
        ASSIGN crapbpr.dschassi = par_dschassi
               crapbpr.ufplnovo = par_ufdplaca
               crapbpr.nrplnovo = par_nrdplaca
               crapbpr.nrrenovo = par_nrrenava
               crapbpr.nranobem = par_nranobem
               crapbpr.nrmodbem = par_nrmodbem.
    END.

    ASSIGN aux_dstransa = aux_dstransa     + " " + 
                          crapbpr.dsbemfin + " " + 
                          crapbpr.dscorbem.

    RUN proc_gerar_log (INPUT par_cdcooper,
                        INPUT par_cdoperad,
                        INPUT "", /* dscritic */
                        INPUT 1,  /* dsorigem */
                        INPUT aux_dstransa,
                        INPUT TRUE,
                        INPUT 1,  /* idseqttl */
                        INPUT "GRAVAM",
                        INPUT par_nrdconta,
                        OUTPUT aux_nrdrowid).
    
    IF  aux_flchassi THEN
        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                 INPUT "dschassi",
                                 INPUT TRIM(aux_antdscha),
                                 INPUT TRIM(par_dschassi)).

    IF  aux_flufplac THEN
        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                 INPUT "ufdplaca",
                                 INPUT aux_antufdpl,
                                 INPUT par_ufdplaca).

    IF  aux_flnrplac THEN
        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                 INPUT "nrdplaca",
                                 INPUT aux_antnrdpl,
                                 INPUT par_nrdplaca).

    IF  aux_flrenava THEN
        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                 INPUT "nrrenava",
                                 INPUT aux_antnrren,
                                 INPUT par_nrrenava).

    IF  crapbpr.nranobem <> aux_nranobem THEN
        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                 INPUT "nranobem",
                                 INPUT aux_nranobem,
                                 INPUT crapbpr.nranobem).

    IF  crapbpr.nrmodbem <> aux_nrmodbem THEN
        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                 INPUT "nrmodbem",
                                 INPUT aux_nrmodbem,
                                 INPUT crapbpr.nrmodbem).


    RETURN "OK".

END PROCEDURE.

/******************************************************************************/

PROCEDURE gravames_blqjud :

    DEF  INPUT PARAM par_cdcooper AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_nrctrpro AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_idseqbem AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.

    DEF  INPUT PARAM par_dschassi AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_ufdplaca AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_nrdplaca AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_nrrenava AS DECI                            NO-UNDO.

    DEF  INPUT PARAM par_cddopcao AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_flblqjud AS INTE                            NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_dstransa AS CHAR                                     NO-UNDO.
    DEF VAR aux_nrdrowid AS ROWID                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.


    ASSIGN aux_dstransa = "Bloqueio ou Liberacao judicial do bem no gravames".

    /******* VALIDACOES *******/
    RUN valida_eh_alienacao_fiduciaria (INPUT par_cdcooper,
                                        INPUT par_nrdconta,
                                        INPUT par_nrctrpro,
                                        INPUT par_cddopcao,
                                       OUTPUT TABLE tt-erro).
    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".


    /** JORGE VERIFICAR ESTA VALIDACAO VALIDAR SE OS 4 CAMPOS ESTAO PREENCHIDOS... AQUI**/
    IF   par_dschassi = ""
    OR   par_nrdplaca = ""
    OR   par_ufdplaca = ""
    OR   par_nrrenava = 0 THEN DO:

        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Chassi, UF, Nr. da Placa e Renavam sao obrigatorios!".

        UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") + " - " +
                          STRING(TIME,"HH:MM:SS") +
                          " - GRAVAM '-->' "  +
                          "ERRO: " + STRING(aux_cdcritic) + " - " +
                          "'" + aux_dscritic + "'"              +
                          " [gravames_alterar]"    +
                          " >> log/gravam.log").
        RETURN "NOK".
    END.



    /* Localizar registro e efetuar alteracao */
    FIND FIRST crapbpr EXCLUSIVE-LOCK
         WHERE crapbpr.cdcooper = par_cdcooper
           AND crapbpr.nrdconta = par_nrdconta
           AND crapbpr.tpctrpro = 90
           AND crapbpr.nrctrpro = par_nrctrpro
           AND crapbpr.idseqbem = par_idseqbem
           AND crapbpr.flgalien = TRUE
           AND (crapbpr.dscatbem MATCHES "*AUTOMOVEL*" OR
                crapbpr.dscatbem MATCHES "*MOTO*"      OR
                crapbpr.dscatbem MATCHES "*CAMINHAO*")
            NO-ERROR.

    IF  AVAIL crapbpr THEN
        ASSIGN crapbpr.flblqjud = par_flblqjud.
    ELSE


    RUN proc_gerar_log (INPUT par_cdcooper,
                        INPUT par_cdoperad,
                        INPUT "", /* dscritic */
                        INPUT 1,  /* dsorigem */
                        INPUT aux_dstransa,
                        INPUT TRUE,
                        INPUT 1,  /* idseqttl */
                        INPUT "GRAVAM",
                        INPUT par_nrdconta,
                        OUTPUT aux_nrdrowid).


    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                             INPUT "flblqjud",
                             INPUT crapbpr.flblqjud,
                             INPUT par_flblqjud).

    RETURN "OK".

END PROCEDURE.


/******************************************************************************/

PROCEDURE gravames_cancelar :

    DEF  INPUT PARAM par_cdcooper AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_nrctrpro AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_idseqbem AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_tpcancel AS LOG FORMAT "Automatico/Manual"  NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                            NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.


    EMPTY TEMP-TABLE tt-erro.


    /******* VALIDACOES *******/
    RUN valida_eh_alienacao_fiduciaria (INPUT par_cdcooper,
                                        INPUT par_nrdconta,
                                        INPUT par_nrctrpro,
                                        INPUT par_cddopcao,
                                       OUTPUT TABLE tt-erro).
    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".


    /* Localizar registro e efetuar alteracao */
    FIND FIRST crapbpr EXCLUSIVE-LOCK
         WHERE crapbpr.cdcooper = par_cdcooper
           AND crapbpr.nrdconta = par_nrdconta
           AND crapbpr.tpctrpro = 90
           AND crapbpr.nrctrpro = par_nrctrpro
           AND crapbpr.idseqbem = par_idseqbem
           AND crapbpr.flgalien = TRUE
           AND (crapbpr.dscatbem MATCHES "*AUTOMOVEL*" OR
                crapbpr.dscatbem MATCHES "*MOTO*"      OR
                crapbpr.dscatbem MATCHES "*CAMINHAO*")
            NO-ERROR.

    IF  AVAIL crapbpr THEN DO:

        IF  crapbpr.cdsitgrv = 1 THEN DO:

            ASSIGN aux_cdcritic = 0
                   aux_dscritic = " Cancelamento nao efetuado!" +
                                  " Em processamento CETIP.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 15, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") + " - " +
                              STRING(TIME,"HH:MM:SS") +
                              " - GRAVAM '-->' "  +
                              "ERRO: " + STRING(aux_cdcritic) + " - " +
                              "'" + aux_dscritic + "'"              +
                              " [gravames_cancelar]"    +
                              " >> log/gravam.log").
            RETURN "NOK".
        END.

        IF  (par_dtmvtolt - crapbpr.dtatugrv) > 30 THEN DO:

            ASSIGN aux_cdcritic = 0
                   aux_dscritic = " Prazo para cancelamento ultrapassado! ".

            UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") + " - " +
                              STRING(TIME,"HH:MM:SS") +
                              " - GRAVAM '-->' "  +
                              "ERRO: " + STRING(aux_cdcritic) + " - " +
                              "'" + aux_dscritic + "'"              +
                              " [gravames_cancelar]"    +
                              " >> log/gravam.log").
            RETURN "NOK".
        END.

        /* TRUE = AUTOMATICO  /  FALSE = MANUAL */
        ASSIGN crapbpr.tpcancel = IF par_tpcancel THEN "A" ELSE "M"
               crapbpr.flcancel = TRUE
               crapbpr.dtcancel = par_dtmvtolt.

        IF  par_tpcancel = FALSE THEN
            ASSIGN crapbpr.cdsitgrv = 5.            /* MANUAL     */
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


    { sistema/generico/includes/var_oracle.i }

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

PROCEDURE gravames_processamento_retorno:  /** Importacao arquivo RETORNO **/

    DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                 NO-UNDO.
    DEF  INPUT PARAM par_cdcoptel LIKE crapcop.cdcooper                 NO-UNDO.
    DEF  INPUT PARAM par_tparquiv AS CHAR                               NO-UNDO.
    DEF  INPUT PARAM par_dtrefere AS DATE                               NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                               NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF          VAR aux_nmtiparq AS CHAR                               NO-UNDO.
    DEF          VAR aux_nmarqret AS CHAR                               NO-UNDO.
    DEF          VAR aux_nmarquiv AS CHAR                               NO-UNDO.
    DEF          VAR aux_nmarqdir AS CHAR                               NO-UNDO.
    DEF          VAR tab_nmarqret AS CHAR    FORMAT "x(60)" EXTENT 99   NO-UNDO.
    DEF          VAR i            AS INT                                NO-UNDO.
    DEF          VAR aux_tparquiv AS CHAR                               NO-UNDO.
    DEF          VAR aux_cdoperac AS INT                                NO-UNDO.

    DEF          VAR aux_cdcooper AS INT                                NO-UNDO.
    DEF          VAR aux_cdfingrv LIKE crapcop.cdfingrv                 NO-UNDO.
    DEF          VAR aux_nrseqlot AS INT                                NO-UNDO.
    DEF          VAR aux_nrgravam LIKE crapbpr.nrgravam                 NO-UNDO.
    DEF          VAR aux_dtatugrv LIKE crapbpr.dtatugrv                 NO-UNDO.
    DEF          VAR aux_dschassi LIKE crapbpr.dschassi                 NO-UNDO.

    DEF          VAR aux_cdretlot AS INT /*Cod Retorno Arq. (Header) */ NO-UNDO.
    DEF          VAR aux_cdretgrv AS INT /*Cod Retorno Gravames (Det)*/ NO-UNDO.
    DEF          VAR aux_cdretctr AS INT /*Cod Retorno Contrato (Det)*/ NO-UNDO.


    EMPTY TEMP-TABLE tt-erro.


    /***** VALIDACOES *****/
    /* Validar cooper selecionada */
    IF  par_cdcoptel <> 0 THEN DO:

        IF  NOT CAN-FIND( FIRST crapcop
                          WHERE crapcop.cdcooper = par_cdcoptel) THEN DO:
            ASSIGN aux_cdcritic = 794.

            UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") + " - " +
                              STRING(TIME,"HH:MM:SS") +
                              " - GRAVAM '-->' "  +
                              "ERRO: " + STRING(aux_cdcritic) + " - " +
                              "'" + aux_dscritic + "'"              +
                              " [gravames_processamento_retorno]"    +
                              " >> log/gravam.log").
            RETURN "NOK".
        END.
    END.

    IF  NOT CAN-DO("TODAS,INCLUSAO,BAIXA,CANCELAMENTO",par_tparquiv) THEN DO:

        ASSIGN aux_cdcritic = 0
               aux_dscritic = " Tipo invalido para Importacao do Retorno! ".

        UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") + " - " +
                          STRING(TIME,"HH:MM:SS") +
                          " - GRAVAM '-->' "  +
                          "ERRO: " + STRING(aux_cdcritic) + " - " +
                          "'" + aux_dscritic + "'"              +
                          " [gravames_processamento_retorno]"    +
                          " >> log/gravam.log").
        RETURN "NOK".
    END.



    ASSIGN aux_nmarqdir = "/micros/cecred/gravames/retorno/".

    IF  par_cdcoptel <> 0 THEN DO: /*** SELECIONOU COOPERATIVA NA TELA **/

        FIND FIRST crapcop
             WHERE crapcop.cdcooper = par_cdcoptel
           NO-LOCK NO-ERROR.

        CASE par_tparquiv:
            WHEN "BAIXA"        THEN
                ASSIGN aux_nmarqret = aux_nmarqdir + "RET_B_" +
                                      STRING(crapcop.cdcooper,"999") +
                                      "_*.txt".
            WHEN "CANCELAMENTO" THEN
                ASSIGN aux_nmarqret = aux_nmarqdir + "RET_C_" +
                                      STRING(crapcop.cdcooper,"999") +
                                      "_*.txt".
            WHEN "INCLUSAO"     THEN
                ASSIGN aux_nmarqret = aux_nmarqdir + "RET_I_" +
                                      STRING(crapcop.cdcooper,"999") +
                                      "_*.txt".
            OTHERWISE
                ASSIGN aux_nmarqret = aux_nmarqdir + "RET_*_" +
                                      STRING(crapcop.cdcooper,"999") +
                                      "_*.txt".
        END CASE.
    END.
    ELSE DO: /*** NAO SELECIONOU COOPERATIVA NA TELA (TODAS) **/
        CASE par_tparquiv:
            WHEN "BAIXA"        THEN
                ASSIGN aux_nmarqret = aux_nmarqdir + "RET_B_*_*.txt".
            WHEN "CANCELAMENTO" THEN
                ASSIGN aux_nmarqret = aux_nmarqdir + "RET_C_*_*.txt".
            WHEN "INCLUSAO"     THEN
                ASSIGN aux_nmarqret = aux_nmarqdir + "RET_I_*_*.txt".
            OTHERWISE
                ASSIGN aux_nmarqret = aux_nmarqdir + "RET_*.txt".
        END CASE.
    END.


    /* Remove os arquivos ".ux" caso existam */
    UNIX SILENT VALUE("rm " + aux_nmarqret + ".ux 2> /dev/null").

    /* Listar o nome do arquivo caso exista*/
    INPUT STREAM str_1 THROUGH VALUE( "ls " + aux_nmarqret + " 2> /dev/null")
                 NO-ECHO.

    ASSIGN aux_contador = 0.

    /*Le o conteudo do diretorio*/
    DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

       SET STREAM str_1 aux_nmarquiv FORMAT "X(78)".

       UNIX SILENT VALUE("dos2ux " + aux_nmarquiv + " > " +
                         aux_nmarquiv + ".ux 2> /dev/null") .

       /* Gravando a qtd de arquivos processados */
       ASSIGN aux_contador               = aux_contador + 1
              tab_nmarqret[aux_contador] = aux_nmarquiv.

    END. /*  Fim do DO WHILE TRUE  */

    INPUT STREAM str_1 CLOSE.


    /* Se nao houver arquivos para processar */
    IF  aux_contador = 0 THEN DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = " Nao foram encontrados arquivos de retorno " +
                              "com parametros informados!".

        UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") + " - " +
                          STRING(TIME,"HH:MM:SS") +
                          " - GRAVAM '-->' "  +
                          "ERRO: " + STRING(aux_cdcritic) + " - " +
                          "'" + aux_dscritic + "'"              +
                          " [gravames_processamento_retorno]"    +
                          " >> log/gravam.log").

        RETURN "NOK".
    END.

    /* Variavel de contador trouxe arquivos */
    DO  i = 1 TO aux_contador:

        /** PEGA LETRA PARA IDENTIFICAR O TIPO DO ARQUIVO -> RET*  **/
        ASSIGN aux_nmtiparq = SUBSTR(tab_nmarqret[i],
                                     R-INDEX(tab_nmarqret[i],"/") + 5,1).

        INPUT STREAM str_2 FROM VALUE(tab_nmarqret[i] + ".ux") NO-ECHO.

        /* Leitura da linha do HEADER */
        IMPORT STREAM str_2 UNFORMATTED aux_setlinha.

        /** Passa para a linha de Header Lote **/
        IMPORT STREAM str_2 UNFORMATTED aux_setlinha.



        /** Tenta encontrar cdfingrv com 4 posicoes **/
        ASSIGN aux_cdfingrv = INT(TRIM(SUBSTR(aux_setlinha,01,04))).

        FIND FIRST crapcop
             WHERE crapcop.cdfingrv = aux_cdfingrv
           NO-LOCK NO-ERROR.

        IF  aux_cdfingrv = 0
        OR  NOT AVAIL crapcop THEN DO:
            /** Se eh zero ou nao achou, pode ser 15 posicoes **/
            ASSIGN aux_cdfingrv = INT(TRIM(SUBSTR(aux_setlinha,01,15)))
                                  NO-ERROR.

            /** Se nao deu erro na atribuicao, pesquisa com 15pos.
                Pq NO-ERROR? Pode ocorrer que nao encontre a COOP
                com 4 caracteres pelo fato de realmente nao existir,
                e ao tentar com 15, pode pegar as proximas colunas,
                e nessa pode ocorrer de ter um caracter string no
                conteudo.  */
            IF  NOT ERROR-STATUS:ERROR THEN DO:
                /** Atribuiu substr de 15 com sucesso */
                FIND FIRST crapcop
                     WHERE crapcop.cdfingrv = aux_cdfingrv
                   NO-LOCK NO-ERROR.

                IF  NOT AVAIL crapcop THEN DO:
                    /** Se nao encontrou crapcop, gera erro */
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = " ERRO na integracao do arquivo " +
                                          SUBSTR(tab_nmarqret[i],
                                            R-INDEX(tab_nmarqret[i],"/") + 1,
                                            LENGTH(tab_nmarqret[i])) +
                                          " ! [COOP/15]".

                    UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") + " - " +
                                      STRING(TIME,"HH:MM:SS") +
                                      " - GRAVAM '-->' "  +
                                      "ERRO: " + STRING(aux_cdcritic) + " - " +
                                      "'" + aux_dscritic + "'"              +
                                      " [gravames_processamento_retorno]"    +
                                      " >> log/gravam.log").
                    NEXT. /** Passa para o proximo arquivo **/
                END.
                ELSE
                    /** Achou crapcop com 15 caracteres
                        11 eh a diferenca de 15 com 4, usado
                        para reposicionar os campos e colunas
                        nos substr's **/
                    ASSIGN aux_qtsubstr = 11.
            END. /** Fim do IF NOT ERROR-STATUS **/
            ELSE DO:
                /* Se deu erro, provavelmente pegou o substr com
                   caracteres dentro, significa que era com 4 carac.
                   mas nao achou crapcop que veio no arquivo  */
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = " ERRO na integracao do arquivo " +
                                      SUBSTR(tab_nmarqret[i],
                                        R-INDEX(tab_nmarqret[i],"/") + 1,
                                        LENGTH(tab_nmarqret[i])) +
                                      " !".

                UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") + " - " +
                                  STRING(TIME,"HH:MM:SS") +
                                  " - GRAVAM '-->' "  +
                                  "ERRO: " + STRING(aux_cdcritic) + " - " +
                                  "'" + aux_dscritic + "'"              +
                                  " [gravames_processamento_retorno]"    +
                                  " >> log/gravam.log").
                NEXT. /** Passa para o proximo arquivo **/
            END.
        END.
        ELSE
            /** Encontrou crapcop com 4 caracteres (cdfingrv) **/
            ASSIGN aux_qtsubstr = 0.



        ASSIGN aux_cdcooper = crapcop.cdcooper.



        /*** A partir desse ponto, os SUBSTR serao tratados dinamicamente,
             somando a posicao inicial a variavel aux_qtsubstr por conta do
             tratamento de 4 ou 15 caracteres para o campo cdfingrv  ******/
        ASSIGN aux_nrseqlot = INT(TRIM(SUBSTR(aux_setlinha,16 + aux_qtsubstr,07))).

        /*** Pega o Codigo de Retorno do Lote **/
        CASE aux_nmtiparq:
            WHEN "B"  THEN ASSIGN aux_cdoperac = 3
                                  aux_cdretlot = INT(SUBSTR(aux_setlinha,
                                                            85 + aux_qtsubstr,03)).
            WHEN "C"  THEN ASSIGN aux_cdoperac = 2
                                  aux_cdretlot = INT(SUBSTR(aux_setlinha,
                                                            85 + aux_qtsubstr,03)).
            WHEN "I"  THEN ASSIGN aux_cdoperac = 1
                                  aux_cdretlot = INT(SUBSTR(aux_setlinha,
                                                            60 + aux_qtsubstr,03)).
        END CASE.


        /** Se houve retorno com erro no HEADER do LOTE **/
        IF  aux_cdretlot <> 0 THEN DO:

            /** Atualiza todos GRV e BENS do LOTE com o Retorno **/
            FOR EACH crapgrv
               WHERE crapgrv.cdcooper = aux_cdcooper
                 AND crapgrv.nrseqlot = aux_nrseqlot
                 AND crapgrv.cdoperac = aux_cdoperac
                EXCLUSIVE-LOCK:

                FOR EACH crapbpr
                   WHERE crapbpr.cdcooper = crapgrv.cdcooper
                     AND crapbpr.nrdconta = crapgrv.nrdconta
                     AND crapbpr.tpctrpro = crapgrv.tpctrpro
                     AND crapbpr.nrctrpro = crapgrv.nrctrpro
                     AND TRIM(crapbpr.dschassi) = TRIM(crapgrv.dschassi)
                     AND crapbpr.flgalien = TRUE
/*                     AND crapbpr.idseqbem = crapgrv.idseqbem */
                    EXCLUSIVE-LOCK:

                    ASSIGN crapbpr.cdsitgrv = 3. /** Retorno com Erro */

                END.

                ASSIGN crapgrv.cdretlot = aux_cdretlot
                       crapgrv.cdretgrv = 0
                       crapgrv.cdretctr = 0
                       crapgrv.dtretgrv = par_dtmvtolt.
            END.

            UNIX SILENT VALUE("rm " + tab_nmarqret[i] + ".ux 2> /dev/null").
            NEXT. /** Passa para o proximo arquivo **/
        END.


        TRANS_1:
        /*** Leitura das Linhas do Detalhe - Se nao houver erros ***/
        DO WHILE TRUE TRANSACTION ON ENDKEY UNDO TRANS_1, LEAVE TRANS_1
                                  ON ERROR  UNDO TRANS_1, LEAVE TRANS_1:

            IMPORT STREAM str_2 UNFORMATTED aux_setlinha.

            ASSIGN aux_nrseqlot = INT(SUBSTR(aux_setlinha,16 + aux_qtsubstr,07))
                   aux_nrseqreg = INT(SUBSTR(aux_setlinha,23 + aux_qtsubstr,06)).

            /*** LINHAS DE TRAILLER - SEM TRATAMENTOS ***/
            IF  aux_nrseqlot = 9999999
            OR  SUBSTR(aux_setlinha,30 + aux_qtsubstr,8) = "TRAILLER" THEN
                NEXT.

            IF  aux_nmtiparq = "I" THEN
                ASSIGN aux_cdretgrv = INT(SUBSTR(aux_setlinha,
                                                 30 + aux_qtsubstr,03))
                       aux_cdretctr = INT(SUBSTR(aux_setlinha,
                                                 33 + aux_qtsubstr,03))
                       aux_dschassi = TRIM(SUBSTR(aux_setlinha,
                                                 36 + aux_qtsubstr,21)).
            ELSE
                ASSIGN aux_dschassi = TRIM(SUBSTR(aux_setlinha,
                                                  30 + aux_qtsubstr,21))
                       aux_cdretgrv = INT(SUBSTR(aux_setlinha,
                                                 85 + aux_qtsubstr,03))
                       aux_cdretctr = 0.

            FIND FIRST crapgrv
                 WHERE crapgrv.cdcooper = aux_cdcooper
                   AND crapgrv.nrseqlot = aux_nrseqlot
                   AND crapgrv.cdoperac = aux_cdoperac
                   AND TRIM(crapgrv.dschassi) = aux_dschassi
                   /*AND crapgrv.nrseqreg = aux_nrseqreg*/
             EXCLUSIVE-LOCK NO-ERROR.

            IF  AVAIL crapgrv THEN DO:

                FIND FIRST crapbpr
                     WHERE crapbpr.cdcooper = crapgrv.cdcooper
                       AND crapbpr.nrdconta = crapgrv.nrdconta
                       AND crapbpr.tpctrpro = crapgrv.tpctrpro
                       AND crapbpr.nrctrpro = crapgrv.nrctrpro
                       AND TRIM(crapbpr.dschassi) = TRIM(crapgrv.dschassi)
                       AND crapbpr.flgalien = TRUE
/*                        AND crapbpr.idseqbem = crapgrv.idseqbem */
                 EXCLUSIVE-LOCK NO-ERROR.

                IF  AVAIL crapbpr THEN DO:

                    IF  (aux_cdretgrv = 30 AND
                         aux_cdretctr = 90) /* Sucesso em ambos */
                    OR  (aux_cdretgrv = 30 AND
                         aux_cdretctr =  0) /* Sucesso GRV - nada CTR*/
                    OR  (aux_cdretgrv = 0  AND
                         aux_cdretctr = 90) /* Nada GRV - Sucesso CTR */ THEN DO:

                        CASE aux_nmtiparq:
                            WHEN "I" THEN DO:
                                ASSIGN aux_nrgravam = INT(SUBSTR(aux_setlinha,
                                                                 62 + aux_qtsubstr,08)).

                                /** Validar se data veio Zerada **/
                                IF  (INT(SUBSTR(aux_setlinha,
                                              74 + aux_qtsubstr,02))) = 0
                                OR  (INT(SUBSTR(aux_setlinha,
                                              76 + aux_qtsubstr,02))) = 0
                                OR  (INT(SUBSTR(aux_setlinha,
                                              70 + aux_qtsubstr,04))) = 0 THEN
                                     ASSIGN aux_dtatugrv = par_dtmvtolt.
                                ELSE
                                    ASSIGN aux_dtatugrv = DATE(
                                                        INT(SUBSTR(aux_setlinha,
                                                                   74 + aux_qtsubstr,02)),
                                                        INT(SUBSTR(aux_setlinha,
                                                                   76 + aux_qtsubstr,02)),
                                                        INT(SUBSTR(aux_setlinha,
                                                                   70 + aux_qtsubstr,04))
                                                       ).

                                ASSIGN crapbpr.dtatugrv = aux_dtatugrv
                                       crapbpr.nrgravam = aux_nrgravam
                                       crapbpr.flgalfid = TRUE
                                       crapbpr.flginclu = FALSE
                                       crapbpr.cdsitgrv = 2 /* ALIENADO OK */ .
                            END.
                            WHEN "B" THEN
                                ASSIGN crapbpr.flgbaixa = FALSE
                                       crapbpr.cdsitgrv = 4 /* BAIXADO OK */ .
                            WHEN "C" THEN
                                ASSIGN crapbpr.flcancel = FALSE
                                       crapbpr.cdsitgrv = 5 /* CANCELADO OK */ .
                        END CASE.

                        ASSIGN crapgrv.dtretgrv = par_dtmvtolt
                               crapgrv.cdretlot = 0     /* Sucesso no LOTE */
                               crapgrv.cdretgrv = aux_cdretgrv
                               crapgrv.cdretctr = aux_cdretctr.

                    END. /** END do IF  aux_cdretgrv = 90 **/
                    ELSE DO:
                        ASSIGN crapgrv.dtretgrv = par_dtmvtolt
                               crapbpr.cdsitgrv = 3 /* Retorno com ERRO */
                               crapgrv.cdretlot = 0 /* Sucesso no LOTE  */
                               crapgrv.cdretgrv = aux_cdretgrv
                               crapgrv.cdretctr = aux_cdretctr.
                    END.

                    NEXT. /** Vai para a proxima linha do arqivo **/

                END. /** END do IF AVAIL crapbpr **/
                ELSE DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = " Registro tipo " + aux_nmtiparq     +
                                          " Coop:" + STRING(aux_cdcooper,"99") +
                                          " Lote:" + STRING(aux_nrseqlot)      +
                                          " Chassi: " + aux_dschassi           +
                                          " nao Integrado! [BPR]".

                    UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") + " - " +
                                      STRING(TIME,"HH:MM:SS") +
                                      " - GRAVAM '-->' "  +
                                      "ERRO: " + STRING(aux_cdcritic) + " - " +
                                      "'" + aux_dscritic + "'"              +
                                      " [gravames_processamento_retorno]"    +
                                      " >> log/gravam.log").
                END.
            END. /** END do IF AVAIL crapgrv **/
            ELSE DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = " Registro tipo " + aux_nmtiparq     +
                                      " Coop:" + STRING(aux_cdcooper,"99") +
                                      " Lote:" + STRING(aux_nrseqlot)      +
                                      " Chassi: " + aux_dschassi           +
                                      " nao Integrado! [GRV]".

                UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") + " - " +
                                  STRING(TIME,"HH:MM:SS") +
                                  " - GRAVAM '-->' "  +
                                  "ERRO: " + STRING(aux_cdcritic) + " - " +
                                  "'" + aux_dscritic + "'"              +
                                  " [gravames_processamento_retorno]"    +
                                  " >> log/gravam.log").
            END.

        END. /*** END do DO WHILE TRUE ... **/

        /* Fim Leitura header */
        INPUT STREAM str_2 CLOSE.

        UNIX SILENT VALUE("rm " + tab_nmarqret[i] + ".ux 2> /dev/null").
        UNIX SILENT VALUE("cp " + tab_nmarqret[i] + " " + aux_nmarqdir +
                          "processado/ 2> /dev/null").
        UNIX SILENT VALUE("mv " + tab_nmarqret[i] + " salvar/ 2> /dev/null").
    END. /*** END do DO i TO aux_contador ... ***/


    IF  TEMP-TABLE tt-erro:HAS-RECORDS THEN
        RETURN "NOK".


    RETURN "OK".

END PROCEDURE.

/******************************************************************************/

PROCEDURE gravames_baixa_manual :

    DEF  INPUT PARAM par_cdcooper AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_nrctrpro AS INT                             NO-UNDO.

    DEF  INPUT PARAM par_rowidbpr AS ROWID                           NO-UNDO.
    DEF  INPUT PARAM par_nrgravam AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_dsjstbxa AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                            NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.


    EMPTY TEMP-TABLE tt-erro.


    /******* VALIDACOES *******/
    RUN valida_eh_alienacao_fiduciaria (INPUT par_cdcooper,
                                        INPUT par_nrdconta,
                                        INPUT par_nrctrpro,
                                        INPUT par_cddopcao,
                                       OUTPUT TABLE tt-erro).
    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".


    FIND FIRST crapbpr NO-LOCK
         WHERE ROWID(crapbpr) = par_rowidbpr
       NO-ERROR.


    FIND FIRST crapepr WHERE crapepr.nrdconta = par_nrdconta AND
                             crapepr.cdcooper = par_cdcooper AND
                             crapepr.nrctremp = par_nrctrpro NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapepr 
    AND crapbpr.cdsitgrv = 0 THEN
        DO:
            ASSIGN aux_cdcritic = 0
               aux_dscritic = " Situacao do Bem invalida! " +
                              " Gravame nao OK!".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 27, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") + " - " +
                              STRING(TIME,"HH:MM:SS") +
                              " - GRAVAM '-->' "  +
                              "ERRO: " + STRING(aux_cdcritic) + " - " +
                              "'" + aux_dscritic + "'"              +
                              " [gravames_baixa_manual]"    +
                              " >> log/gravam.log").
    
            RETURN "NOK".

        END.


    IF  crapbpr.cdsitgrv <> 0
    AND crapbpr.cdsitgrv <> 2
    AND crapbpr.cdsitgrv <> 3     THEN DO:  /* Processado com Critica */
        ASSIGN aux_cdcritic = 0
               aux_dscritic = " Situacao do Bem invalida! " +
                              " Gravame nao OK!".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 27, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") + " - " +
                          STRING(TIME,"HH:MM:SS") +
                          " - GRAVAM '-->' "  +
                          "ERRO: " + STRING(aux_cdcritic) + " - " +
                          "'" + aux_dscritic + "'"              +
                          " [gravames_baixa_manual]"    +
                          " >> log/gravam.log").

        RETURN "NOK".
        
    END.

    /******* FIM VALIDACOES *******/


    FIND CURRENT crawepr EXCLUSIVE-LOCK.
    FIND CURRENT crapbpr EXCLUSIVE-LOCK.

    ASSIGN crapbpr.cdsitgrv = 4  /* Baixado */
           crapbpr.flgbaixa = TRUE
           crapbpr.dtdbaixa = par_dtmvtolt
           crapbpr.dsjstbxa = par_dsjstbxa
           crapbpr.tpdbaixa = "M". /* Manual */

    RELEASE crawepr.
    RELEASE crapbpr.


    RETURN "OK".

END PROCEDURE.

/******************************************************************************/

PROCEDURE gravames_inclusao_manual :

    DEF  INPUT PARAM par_cdcooper AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_nrctrpro AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.

    DEF  INPUT PARAM par_rowidbpr AS ROWID                           NO-UNDO.
    DEF  INPUT PARAM par_nrgravam AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_dtmvttel AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_dsjstinc AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                            NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF          VAR aux_dsmensag AS CHAR                            NO-UNDO.


    EMPTY TEMP-TABLE tt-erro.


    /******* VALIDACOES *******/
    RUN valida_eh_alienacao_fiduciaria (INPUT par_cdcooper,
                                        INPUT par_nrdconta,
                                        INPUT par_nrctrpro,
                                        INPUT par_cddopcao,
                                       OUTPUT TABLE tt-erro).
    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".


    FIND FIRST crapbpr NO-LOCK
         WHERE ROWID(crapbpr) = par_rowidbpr
       NO-ERROR.

    IF  crapbpr.tpinclus = "A" THEN
        ASSIGN aux_dsmensag = " via arquivo".
    ELSE
        ASSIGN aux_dsmensag = " de forma manual".

    IF  (crapbpr.cdsitgrv <> 0 AND crapbpr.cdsitgrv <> 3) THEN DO:

        ASSIGN aux_cdcritic = 0.

        IF  crapbpr.cdsitgrv = 1 THEN
            ASSIGN aux_dscritic = " Contrato sendo processado via arquivo." +
                                  " Verifique!".
        ELSE
        IF  crapbpr.cdsitgrv = 2 THEN
            ASSIGN aux_dscritic = " Contrato ja foi alienado" + aux_dsmensag +
                                  " Verifique!".
        ELSE
            ASSIGN aux_dscritic = " Situacao invalida! (Sit: " +
                                  STRING(crapbpr.cdsitgrv)   +
                                  "). Verifique!".


        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 28, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).


        UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") + " - " +
                          STRING(TIME,"HH:MM:SS") +
                          " - GRAVAM '-->' "  +
                          "ERRO: " + STRING(aux_cdcritic) + " - " +
                          "'" + aux_dscritic + "'"              +
                          " [gravames_inclusao_manual]"    +
                          " >> log/gravam.log").

        RETURN "NOK".
    END.

    /******* FIM VALIDACOES *******/


    FIND CURRENT crawepr EXCLUSIVE-LOCK.
    FIND CURRENT crapbpr EXCLUSIVE-LOCK.

    ASSIGN crapbpr.flginclu = TRUE
           crapbpr.dtdinclu = par_dtmvtolt
           crapbpr.dsjstinc = par_dsjstinc
           crapbpr.tpinclus = "M"
           crapbpr.cdsitgrv = 2 /* Alienacao Ok */
           crapbpr.nrgravam = par_nrgravam
           crapbpr.dtatugrv = par_dtmvttel
           crapbpr.flgalfid = TRUE
           crawepr.flgokgrv = TRUE. /* 25/02/2014 */


    RETURN "OK".

END PROCEDURE.

/******************************************************************************/

PROCEDURE gravames_impressao_relatorio :

    DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                 NO-UNDO.
    DEF  INPUT PARAM par_cdcoptel LIKE crapcop.cdcooper                 NO-UNDO.
    DEF  INPUT PARAM par_tparquiv AS CHAR                               NO-UNDO.
    DEF  INPUT PARAM par_nrseqlot AS INT                                NO-UNDO.
    DEF  INPUT PARAM par_dtrefere AS DATE                               NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                               NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INT                                NO-UNDO.
    DEF OUTPUT PARAM ret_nmarquiv AS CHAR                               NO-UNDO.
    DEF OUTPUT PARAM ret_nmarqpdf AS CHAR                               NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF          VAR aux_nmarquiv AS CHAR                               NO-UNDO.
    DEF          VAR aux_tparquiv AS CHAR                               NO-UNDO.
    DEF          VAR aux_dstitulo AS CHAR                               NO-UNDO.
    DEF          VAR aux_dssituac AS CHAR                               NO-UNDO.
    DEF          VAR aux_dsoperac AS CHAR                               NO-UNDO.
    DEF          VAR aux_cdoperac AS INT                                NO-UNDO.
    DEF          VAR aux_cdretorn AS INT                                NO-UNDO.
    DEF          VAR aux_nrtabela AS INT                                NO-UNDO.
    DEF          VAR aux_qtdlotes AS INT                                NO-UNDO.
    DEF          VAR aux_qtreglot AS INT                                NO-UNDO.
    DEF          VAR aux_qtsemret AS INT                                NO-UNDO.
    DEF          VAR aux_qtdregok AS INT                                NO-UNDO.
    DEF          VAR aux_qtregnok AS INT                                NO-UNDO.
    DEF          VAR aux_nrcpfcgc AS CHAR                               NO-UNDO.
    DEF          VAR aux_cdagenci AS INTE                               NO-UNDO.
    DEF          VAR aux_dsbemfin AS CHAR                               NO-UNDO.


    EMPTY TEMP-TABLE tt-erro.

    FORM SKIP(1)
         aux_dstitulo   FORMAT "X(60)"                   AT 045
         SKIP(2)
         "COOP"                                          AT 005
         "PA"                                            AT 011
         "OPERACAO"                                      AT 015
         "LOTE"                                          AT 029
         "CONTA/DV"                                      AT 040
         "CPF/CNPJ"                                      AT 050
         "CONTRATO"                                      AT 067
         "DESCRICAO DO BEM"                              AT 077
         "DAT ENVIO"                                     AT 108
         "DAT RETORNO"                                   AT 121
         "SITUACAO"                                      AT 134
        WITH NO-BOX NO-ATTR-SPACE NO-LABELS WIDTH 230 FRAME f_header.

    FORM SKIP
         crapgrv.cdcooper       FORMAT "999"             AT 005
         aux_cdagenci           FORMAT "999"             AT 011
         aux_dsoperac           FORMAT "X(12)"           AT 015
         crapgrv.nrseqlot       FORMAT "9999999"         AT 029
         crapgrv.nrdconta       FORMAT "zzzz,zzz,9"      AT 038
         aux_nrcpfcgc           FORMAT "x(14)"           AT 050
         crapgrv.nrctrpro       FORMAT "z,zzz,zz9"       AT 066
         aux_dsbemfin           FORMAT "x(30)"           AT 077
         crapgrv.dtenvgrv       FORMAT "99/99/9999"      AT 108
         crapgrv.dtretgrv       FORMAT "99/99/9999"      AT 122
         aux_dssituac           FORMAT "X(96)"          AT 134
        WITH NO-BOX NO-ATTR-SPACE NO-LABELS WIDTH 230 FRAME f_dados.


    FORM SKIP(4)
         "TOTAL DE REGISTROS:"                           AT 026
         aux_qtreglot           FORMAT "zz,zz9"          AT 046
         SKIP(1)
         "TOTAL DE REGISTROS SEM RETORNO:"               AT 014
         aux_qtsemret           FORMAT "zz,zz9"          AT 046
         "TOTAL DE REGISTROS COM SUCESSO:"               AT 014
         aux_qtdregok           FORMAT "zz,zz9"          AT 046
         SKIP
         "TOTAL DE REGISTROS COM ERRO:"                  AT 017
         aux_qtregnok           FORMAT "zz,zz9 "         AT 046
         WITH NO-BOX NO-ATTR-SPACE NO-LABELS WIDTH 80 FRAME f_totais.




    /*** VALIDACOES ***/
    IF  par_cdcoptel <> 0 THEN DO:

        FIND FIRST crapcop
             WHERE crapcop.cdcooper = par_cdcoptel NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapcop THEN DO:
            ASSIGN aux_cdcritic = 794.

            UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") + " - " +
                              STRING(TIME,"HH:MM:SS") +
                              " - GRAVAM '-->' "  +
                              "ERRO: " + STRING(aux_cdcritic) + " - " +
                              "'" + aux_dscritic + "'"              +
                              " [gravames_impressao_relatorio]"    +
                              " >> log/gravam.log").
            RETURN "NOK".
        END.
    END.

    IF  NOT CAN-DO("TODAS,INCLUSAO,BAIXA,CANCELAMENTO",par_tparquiv) THEN DO:

        ASSIGN aux_cdcritic = 0
               aux_dscritic = " Tipo invalido para Geracao do Arquivo! ".

        UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") + " - " +
                          STRING(TIME,"HH:MM:SS") +
                          " - GRAVAM '-->' "  +
                          "ERRO: " + STRING(aux_cdcritic) + " - " +
                          "'" + aux_dscritic + "'"              +
                          " [gravames_impressao_relatorio]"    +
                          " >> log/gravam.log").
        RETURN "NOK".
    END.


    FIND FIRST crapcop
         WHERE crapcop.cdcooper = par_cdcooper
        NO-LOCK NO-ERROR.

    ASSIGN aux_nmdircop = "/usr/coop/" + crapcop.dsdircop +
                              "/rl/"
           ret_nmarquiv = aux_nmdircop + "crrl670_" +
                          STRING(RANDOM(1,999999))
           ret_nmarqpdf = ret_nmarquiv + ".ex"
           ret_nmarquiv = ret_nmarquiv + ".lst".


    CASE par_tparquiv:
        WHEN "BAIXA"        THEN ASSIGN aux_cdoperac = 3.
        WHEN "CANCELAMENTO" THEN ASSIGN aux_cdoperac = 2.
        WHEN "INCLUSAO"     THEN ASSIGN aux_cdoperac = 1.
        OTHERWISE                ASSIGN aux_cdoperac = 0.
    END CASE.



    OUTPUT STREAM str_1 TO VALUE(ret_nmarquiv)
           PAGED PAGE-SIZE 62.

    { sistema/generico/includes/b1cabrelvar.i }
    { sistema/generico/includes/b1cabrel132.i "11" 670}

    VIEW STREAM str_1 FRAME f_cabrel234_1.

    ASSIGN aux_qtreglot = 0
           aux_qtsemret = 0
           aux_qtdregok = 0
           aux_qtregnok = 0.

    /*** PROCESSAMENTO REGISTROS SEM RETORNO CETIP ****/
    ASSIGN aux_dstitulo = "GRAVAMES SEM RETORNO".

    DISPLAY STREAM str_1 aux_dstitulo
              WITH FRAME f_header.
    DOWN WITH FRAME f_header.

    ASSIGN aux_dsoperac = ""
           aux_nrcpfcgc = ""
           aux_cdagenci = 0
           aux_dsbemfin = ""
           aux_dssituac = "".

    FOR EACH crapgrv NO-LOCK
       WHERE ((crapgrv.cdcooper = par_cdcoptel AND par_cdcoptel <> 0)
                OR par_cdcoptel = 0)
         AND  (crapgrv.cdoperac = aux_cdoperac OR
                   aux_cdoperac = 0)
         AND  (crapgrv.nrseqlot = par_nrseqlot OR
                   par_nrseqlot = 0)
         AND   crapgrv.dtretgrv = ?     /** Que NAO tiveram retorno **/
         AND   crapgrv.dtenvgrv = par_dtrefere
          BY crapgrv.cdcooper
          BY crapgrv.cdoperac
          BY crapgrv.nrseqlot
          BY crapgrv.nrdconta
          BY crapgrv.nrctrpro
          BY crapgrv.idseqbem:

        ASSIGN aux_qtreglot = aux_qtreglot + 1
               aux_qtsemret = aux_qtsemret + 1.

        FIND FIRST crapbpr
             WHERE crapbpr.cdcooper = crapgrv.cdcooper
               AND crapbpr.nrdconta = crapgrv.nrdconta
               AND crapbpr.tpctrpro = crapgrv.tpctrpro
               AND crapbpr.nrctrpro = crapgrv.nrctrpro
               AND TRIM(crapbpr.dschassi) = TRIM(crapgrv.dschassi)
               AND crapbpr.flgalien = TRUE
/*                AND crapbpr.idseqbem = crapgrv.idseqbem */
           NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapbpr THEN DO:
            UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") + " - " +
                              STRING(TIME,"HH:MM:SS") +
                              " - GRAVAM '-->' "  +
                              "ERRO: 0 - " +
                              "'Erro na localizacao do Bem [" +
                              " Cop:" + STRING(crapgrv.cdcooper,"99") +
                              " Cta:" + STRING(crapgrv.nrdconta)      +
                              " Tip:" + STRING(crapgrv.tpctrpro)      +
                              " Ctr:" + STRING(crapgrv.nrctrpro)      +
                              " Chassi:" + crapgrv.dschassi           +
                              "][BPR_1]' [gravames_impressao_relatorio]"    +
                              " >> log/gravam.log").
        END.


        CASE crapgrv.cdoperac:
            WHEN 1  THEN ASSIGN aux_dsoperac = "INCLUSAO"
                                aux_tparquiv = "I".
            WHEN 2  THEN ASSIGN aux_dsoperac = "CANCELAMENTO"
                                aux_tparquiv = "C".
            WHEN 3  THEN ASSIGN aux_dsoperac = "BAIXA"
                                aux_tparquiv = "B".
        END CASE.


        ASSIGN aux_dssituac = "SEM ARQUIVO DE RETORNO - GRAVAMES".

        IF  LINE-COUNTER(str_1) >  PAGE-SIZE(str_1) - 1   THEN DO:
            PAGE STREAM str_1.

            DISPLAY STREAM str_1 aux_dstitulo
                WITH FRAME f_header.
            DOWN WITH FRAME f_header.
        END.


        FIND FIRST crapass
             WHERE crapass.cdcooper = crapgrv.cdcooper
               AND crapass.nrdconta = crapgrv.nrdconta
           NO-LOCK NO-ERROR.
        IF  AVAIL crapass THEN
            ASSIGN /*aux_nrcpfcgc = TRIM(STRING(crapass.nrcpfcgc,"zzz99999999999"))*/
                   aux_cdagenci = crapass.cdagenci.

        IF  AVAIL crapbpr AND crapbpr.nrcpfbem <>  0 THEN
            ASSIGN aux_nrcpfcgc = TRIM(STRING(crapbpr.nrcpfbem,"zzz99999999999")).

        IF  AVAIL crapbpr THEN
            ASSIGN aux_dsbemfin = crapbpr.dsbemfin.

        DISPLAY STREAM str_1  aux_dsoperac     crapgrv.nrseqlot
                              crapgrv.cdcooper crapgrv.nrdconta
                              aux_nrcpfcgc     aux_cdagenci
                              crapgrv.nrctrpro crapgrv.dtenvgrv
                              crapgrv.dtretgrv
                              aux_dsbemfin     aux_dssituac
                              WITH FRAME f_dados.
        DOWN WITH FRAME f_dados.
    END.



    /*** PROCESSAMENTO REGISTROS SUCESSO ****/
    ASSIGN aux_dstitulo = "GRAVAMES IMPORTADOS COM SUCESSO"
           aux_dssituac = "".

/*     DISPLAY STREAM str_1 "" SKIP(1). */

    DISPLAY STREAM str_1 aux_dstitulo
              WITH FRAME f_header.
    DOWN WITH FRAME f_header.

    ASSIGN aux_dsoperac = ""
           aux_nrcpfcgc = ""
           aux_cdagenci = 0
           aux_dsbemfin = ""
           aux_dssituac = "".

    FOR EACH crapgrv NO-LOCK
       WHERE ((crapgrv.cdcooper = par_cdcoptel AND par_cdcoptel <> 0)
                OR par_cdcoptel = 0)
         AND  (crapgrv.cdoperac = aux_cdoperac OR
                   aux_cdoperac = 0)
         AND  (crapgrv.nrseqlot = par_nrseqlot OR
                   par_nrseqlot = 0)
         AND   crapgrv.cdretlot = 0     /** Sucesso no LOTE */
         AND  (crapgrv.cdretgrv = 0 OR crapgrv.cdretgrv = 30)
         AND  (crapgrv.cdretctr = 0 OR crapgrv.cdretctr = 90)
         AND   crapgrv.dtretgrv <> ?    /** Que tiveram retorno **/
         AND   crapgrv.dtenvgrv = par_dtrefere
          BY crapgrv.cdcooper
          BY crapgrv.cdoperac
          BY crapgrv.nrseqlot
          BY crapgrv.nrdconta
          BY crapgrv.nrctrpro
          BY crapgrv.idseqbem:

        ASSIGN aux_qtreglot = aux_qtreglot + 1
               aux_qtdregok = aux_qtdregok + 1.

        FIND FIRST crapbpr
             WHERE crapbpr.cdcooper = crapgrv.cdcooper
               AND crapbpr.nrdconta = crapgrv.nrdconta
               AND crapbpr.tpctrpro = crapgrv.tpctrpro
               AND crapbpr.nrctrpro = crapgrv.nrctrpro
               AND TRIM(crapbpr.dschassi) = TRIM(crapgrv.dschassi)
               AND crapbpr.flgalien = TRUE
/*                AND crapbpr.idseqbem = crapgrv.idseqbem */
           NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapbpr THEN DO:
            UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") + " - " +
                              STRING(TIME,"HH:MM:SS") +
                              " - GRAVAM '-->' "  +
                              "ERRO: 0 - " +
                              "'Erro na localizacao do Bem [" +
                              " Cop:" + STRING(crapgrv.cdcooper,"99") +
                              " Cta:" + STRING(crapgrv.nrdconta)      +
                              " Tip:" + STRING(crapgrv.tpctrpro)      +
                              " Ctr:" + STRING(crapgrv.nrctrpro)      +
                              " Chassi:" + crapgrv.dschassi           +
                              "][BPR_2]' [gravames_impressao_relatorio]"    +
                              " >> log/gravam.log").
        END.


        CASE crapgrv.cdoperac:
            WHEN 1  THEN ASSIGN aux_dsoperac = "INCLUSAO"
                                aux_tparquiv = "I"
                                aux_dssituac = aux_dsoperac + " - SUCESSO! " +
                                               "Nr. Registro: "              +
                                               (IF AVAIL crapbpr THEN
                                                   STRING(crapbpr.nrgravam)
                                                ELSE "").
            WHEN 2  THEN ASSIGN aux_dsoperac = "CANCELAMENTO"
                                aux_tparquiv = "C"
                                aux_dssituac = aux_dsoperac + " - SUCESSO! " +
                                               "Nr. Registro: "              +
                                               (IF AVAIL crapbpr THEN
                                                   STRING(crapbpr.nrgravam)
                                                ELSE "").
            WHEN 3  THEN ASSIGN aux_dsoperac = "BAIXA"
                                aux_tparquiv = "B"
                                aux_dssituac = aux_dsoperac + " - SUCESSO! " +
                                               "Nr. Registro: "              +
                                               (IF AVAIL crapbpr THEN
                                                   STRING(crapbpr.nrgravam)
                                                ELSE "").
        END CASE.


        IF  LINE-COUNTER(str_1) >  PAGE-SIZE(str_1) - 1   THEN DO:
            PAGE STREAM str_1.

            DISPLAY STREAM str_1 aux_dstitulo
                WITH FRAME f_header.
            DOWN WITH FRAME f_header.
        END.


        FIND FIRST crapass
             WHERE crapass.cdcooper = crapgrv.cdcooper
               AND crapass.nrdconta = crapgrv.nrdconta
           NO-LOCK NO-ERROR.
        IF  AVAIL crapass THEN
            ASSIGN /*aux_nrcpfcgc = TRIM(STRING(crapass.nrcpfcgc,"zzz99999999999"))*/
                   aux_cdagenci = crapass.cdagenci.

        IF  AVAIL crapbpr AND crapbpr.nrcpfbem <> 0 THEN
            ASSIGN aux_nrcpfcgc = TRIM(STRING(crapbpr.nrcpfbem,"zzz99999999999")).

        IF  AVAIL crapbpr THEN
            ASSIGN aux_dsbemfin = crapbpr.dsbemfin.

        DISPLAY STREAM str_1  aux_dsoperac     crapgrv.nrseqlot
                              crapgrv.cdcooper crapgrv.nrdconta
                              aux_nrcpfcgc     aux_cdagenci
                              crapgrv.nrctrpro crapgrv.dtenvgrv
                              crapgrv.dtretgrv
                              aux_dsbemfin aux_dssituac
                              WITH FRAME f_dados.
        DOWN WITH FRAME f_dados.
    END.




    /*** PROCESSAMENTO REGISTROS ERRO ****/
    ASSIGN aux_dstitulo = "GRAVAMES IMPORTADOS COM ERROS"
           aux_dssituac = "".

/*     DISPLAY STREAM str_1 "" SKIP(1). */

    DISPLAY STREAM str_1 aux_dstitulo
              WITH FRAME f_header.
    DOWN WITH FRAME f_header.

    ASSIGN aux_dsoperac = ""
           aux_nrcpfcgc = ""
           aux_cdagenci = 0
           aux_dsbemfin = ""
           aux_dssituac = "".

    FOR EACH crapgrv NO-LOCK
       WHERE ((crapgrv.cdcooper = par_cdcoptel AND par_cdcoptel <> 0)
                OR par_cdcoptel = 0)
         AND  (crapgrv.cdoperac = aux_cdoperac OR
                   aux_cdoperac = 0)
         AND  (crapgrv.nrseqlot = par_nrseqlot OR
                   par_nrseqlot = 0)
         AND  (crapgrv.cdretlot <> 0  OR /** Algum retorno com erro **/
              (crapgrv.cdretgrv <> 0  AND crapgrv.cdretgrv <> 30) OR
              (crapgrv.cdretctr <> 0  AND crapgrv.cdretctr <> 90) )
         AND   crapgrv.dtretgrv <> ?     /** Que tiveram retorno **/
         AND   crapgrv.dtenvgrv = par_dtrefere
          BY crapgrv.cdcooper
          BY crapgrv.cdoperac
          BY crapgrv.nrseqlot
          BY crapgrv.nrdconta
          BY crapgrv.nrctrpro
          BY crapgrv.idseqbem:

        ASSIGN aux_qtreglot = aux_qtreglot + 1
               aux_qtregnok = aux_qtregnok + 1.

        FIND FIRST crapbpr
             WHERE crapbpr.cdcooper = crapgrv.cdcooper
               AND crapbpr.nrdconta = crapgrv.nrdconta
               AND crapbpr.tpctrpro = crapgrv.tpctrpro
               AND crapbpr.nrctrpro = crapgrv.nrctrpro
               AND TRIM(crapbpr.dschassi) = TRIM(crapgrv.dschassi)
               AND crapbpr.flgalien = TRUE
/*                AND crapbpr.idseqbem = crapgrv.idseqbem */
           NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapbpr THEN DO:
            UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") + " - " +
                              STRING(TIME,"HH:MM:SS") +
                              " - GRAVAM '-->' "  +
                              "ERRO: 0 - " +
                              "'Erro na localizacao do Bem [" +
                              " Cop:" + STRING(crapgrv.cdcooper,"99") +
                              " Cta:" + STRING(crapgrv.nrdconta)      +
                              " Tip:" + STRING(crapgrv.tpctrpro)      +
                              " Ctr:" + STRING(crapgrv.nrctrpro)      +
                              " Chassi:" + crapgrv.dschassi           +
                              "][BPR_3]' [gravames_impressao_relatorio]"    +
                              " >> log/gravam.log").
        END.


        CASE crapgrv.cdoperac:
            WHEN 1  THEN ASSIGN aux_dsoperac = "INCLUSAO"
                                aux_tparquiv = "I".
            WHEN 2  THEN ASSIGN aux_dsoperac = "CANCELAMENTO"
                                aux_tparquiv = "C".
            WHEN 3  THEN ASSIGN aux_dsoperac = "BAIXA"
                                aux_tparquiv = "Q". /*** Para retornos, foi
                                                    utilizada a letra "Q" e
                                                    nao letra "B" ********/
        END CASE.


        ASSIGN aux_dssituac = "".

        /** Exibir todos os retornos com erros **/
        IF  crapgrv.cdretlot <> 0 THEN DO:
            FIND FIRST craprto
                 WHERE craprto.cdprodut = 1 /* Produto Gravames */
                   AND craprto.cdoperac = aux_tparquiv
                   AND craprto.nrtabela = 1
                   AND craprto.cdretorn = crapgrv.cdretlot
               NO-LOCK NO-ERROR.

            IF  NOT AVAIL craprto THEN
                ASSIGN aux_dssituac = "LOT: " + STRING(crapgrv.cdretlot,"999") +
                                      " - SITUACAO NAO CADASTRADA".
            ELSE
                ASSIGN aux_dssituac = "LOT: " + STRING(craprto.cdretorn,"999") +
                                      " - " + craprto.dsretorn.
        END.

        IF   crapgrv.cdretlot  = 0
        AND (crapgrv.cdretgrv <> 0 AND crapgrv.cdretgrv <> 30) THEN DO:
            FIND FIRST craprto
                 WHERE craprto.cdprodut = 1 /* Produto Gravames */
                   AND craprto.cdoperac = aux_tparquiv
                   AND craprto.nrtabela = 2
                   AND craprto.cdretorn = crapgrv.cdretgrv
               NO-LOCK NO-ERROR.

            IF  aux_dssituac <> "" THEN
                aux_dssituac = aux_dssituac + " / ".

            IF  NOT AVAIL craprto THEN
                ASSIGN aux_dssituac = aux_dssituac +
                                      "GRV: " + STRING(crapgrv.cdretgrv,"999") +
                                      " - SITUACAO NAO CADASTRADA".
            ELSE
                IF  (crapgrv.cdretctr <> 0 AND crapgrv.cdretctr <> 90) THEN
                    ASSIGN aux_dssituac = aux_dssituac +
                                          "GRV: " + STRING(craprto.cdretorn,"999") +
                                          " - " + SUBSTR(craprto.dsretorn,1,40).
                ELSE
                    ASSIGN aux_dssituac = aux_dssituac +
                                          "GRV: " + STRING(craprto.cdretorn,"999") +
                                          " - " + craprto.dsretorn.
        END.

        IF   crapgrv.cdretlot  = 0
        AND (crapgrv.cdretctr <> 0 AND crapgrv.cdretctr <> 90) THEN DO:
            FIND FIRST craprto
                 WHERE craprto.cdprodut = 1 /* Produto Gravames */
                   AND craprto.cdoperac = aux_tparquiv
                   AND craprto.nrtabela = 3
                   AND craprto.cdretorn = crapgrv.cdretctr
               NO-LOCK NO-ERROR.

            IF  aux_dssituac <> "" THEN
                aux_dssituac = aux_dssituac + " / ".

            IF  NOT AVAIL craprto THEN
                ASSIGN aux_dssituac = aux_dssituac +
                                      "CTR: " + STRING(crapgrv.cdretctr,"999") +
                                      " - SITUACAO NAO CADASTRADA".
            ELSE
                IF  (crapgrv.cdretgrv <> 0 AND crapgrv.cdretgrv <> 30) THEN
                    ASSIGN aux_dssituac = aux_dssituac +
                                          "CTR: " + STRING(craprto.cdretorn,"999") +
                                          " - " + SUBSTR(craprto.dsretorn,1,40).
                ELSE
                    ASSIGN aux_dssituac = aux_dssituac +
                                          "CTR: " + STRING(craprto.cdretorn,"999") +
                                          " - " + craprto.dsretorn.
        END.



        IF  LINE-COUNTER(str_1) >  PAGE-SIZE(str_1) - 1   THEN DO:
            PAGE STREAM str_1.

            DISPLAY  STREAM str_1 aux_dstitulo
                 WITH FRAME f_header.
            DOWN WITH FRAME f_header.
        END.



        FIND FIRST crapass
             WHERE crapass.cdcooper = crapgrv.cdcooper
               AND crapass.nrdconta = crapgrv.nrdconta
           NO-LOCK NO-ERROR.
        IF  AVAIL crapass THEN
            ASSIGN /*aux_nrcpfcgc = TRIM(STRING(crapass.nrcpfcgc,"zzz99999999999"))*/
                   aux_cdagenci = crapass.cdagenci.

        IF  AVAIL crapbpr AND crapbpr.nrcpfbem <> 0 THEN
            ASSIGN aux_nrcpfcgc = TRIM(STRING(crapbpr.nrcpfbem,"zzz99999999999")).

        IF  AVAIL crapbpr THEN
            ASSIGN aux_dsbemfin = crapbpr.dsbemfin.

        DISPLAY STREAM str_1  aux_dsoperac     crapgrv.nrseqlot
                              crapgrv.cdcooper crapgrv.nrdconta
                              aux_nrcpfcgc     aux_cdagenci
                              crapgrv.nrctrpro crapgrv.dtenvgrv
                              crapgrv.dtretgrv
                              aux_dsbemfin aux_dssituac
                              WITH FRAME f_dados.
        DOWN WITH FRAME f_dados.
    END.

    DISPLAY STREAM str_1 aux_qtreglot  aux_qtsemret aux_qtdregok  aux_qtregnok
        WITH FRAME f_totais.

    OUTPUT STREAM str_1 CLOSE.



    IF  par_idorigem = 5 THEN DO: /* Ayllos Web */

        UNIX SILENT VALUE("cp " + ret_nmarquiv + " " + ret_nmarqpdf +
                          " 2> /dev/null").

        RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
            SET h-b1wgen0024.

        IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
            DO:
               ASSIGN aux_cdcritic = 0
                      aux_dscritic = "Handle invalido para BO " +
                                     "b1wgen0024.".

               UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") + " - " +
                                 STRING(TIME,"HH:MM:SS") +
                                  " - GRAVAM '-->' "  +
                                  "ERRO: " + STRING(aux_cdcritic) + " - " +
                                  "'" + aux_dscritic + "'"              +
                                  " [gravames_impressao_relatorio]"    +
                                  " >> log/gravam.log").
               RETURN "NOK".
            END.

        RUN envia-arquivo-web IN h-b1wgen0024 ( INPUT par_cdcooper,
                                                INPUT 1, /* cdagenci */
                                                INPUT 1, /* nrdcaixa */
                                                INPUT  ret_nmarqpdf,
                                                OUTPUT ret_nmarqpdf,
                                                OUTPUT TABLE tt-erro ).


        IF  VALID-HANDLE(h-b1wgen0024)  THEN
            DELETE PROCEDURE h-b1wgen0024.

        IF  RETURN-VALUE <> "OK"   THEN
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

    /* Irlan: Funcao bloqueada temporariamente para demais coops.
       Apenas 1, 4, 7 */
/*     IF  NOT CAN-DO("1,4,7",STRING(par_cdcooper)) THEN DO:           */
/*                                                                     */
/*         ASSIGN aux_cdcritic = 0                                     */
/*                aux_dscritic = " Operacao bloqueada!".               */
/*                                                                     */
/*         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +       */
/*                           " - GRAVAM '-->' "  +                     */
/*                           "ERRO: " + STRING(aux_cdcritic) + " - " + */
/*                           "'" + aux_dscritic + "'"              +   */
/*                           " [registrar_gravames]"    +              */
/*                           " >> log/gravam.log").                    */
/*         RETURN "NOK".                                               */
/*     END.                                                            */
/** 23/12/2014 -> LIBERACAO PARA TODAS AS COOPERATIVAS */

    /** Validar Data de Inclusao do Contrato **/
    FIND FIRST crawepr
         WHERE crawepr.cdcooper = par_cdcooper
           AND crawepr.nrdconta = par_nrdconta
           AND crawepr.nrctremp = par_nrctrpro
       NO-LOCK NO-ERROR.

    IF  NOT AVAIL crawepr   THEN DO: /* Contrato nao encontrado */

        ASSIGN aux_cdcritic = 356.
               aux_dscritic = "".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 41, /*sequencia*/
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
    ELSE
        /** Conforme liberando novas Coops, havera novas datas*/
        IF  (crawepr.cdcooper = 1 AND
             crawepr.dtmvtolt < 11/18/2014)
        OR  (crawepr.cdcooper = 4 AND
             crawepr.dtmvtolt < 07/23/2014)
        OR  (crawepr.cdcooper = 7 AND
             crawepr.dtmvtolt < 10/06/2014)
        OR  (NOT CAN-DO("1,4,7",
                        STRING(crawepr.cdcooper)) AND
             crawepr.dtmvtolt < 02/26/2015) THEN DO:

            ASSIGN aux_cdcritic = 0
                   aux_dscritic = " Operacao bloqueada![Data Contrato]".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 32, /*sequencia*/
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


    /******* VALIDACOES *******/
    RUN valida_eh_alienacao_fiduciaria (INPUT par_cdcooper,
                                        INPUT par_nrdconta,
                                        INPUT par_nrctrpro,
                                        INPUT par_cddopcao,
                                       OUTPUT TABLE tt-erro).
    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

    IF  crapbpr.cdsitgrv <> 0 THEN DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = " Situacao do Gravame invalida! ".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 33, /*sequencia*/
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

    IF  crawepr.flgokgrv = TRUE THEN DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = " Proposta ja OK para envio ao GRAVAMES! ".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 34, /*sequencia*/
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
    /**** FIM VALIDACOES ***/


    FIND CURRENT crawepr EXCLUSIVE-LOCK.

    ASSIGN crawepr.flgokgrv = TRUE.

    /* Registrar TODOS os bens da Proposta */
    FOR EACH crapbpr EXCLUSIVE-LOCK
       WHERE crapbpr.cdcooper = crawepr.cdcooper
         AND crapbpr.nrdconta = crawepr.nrdconta
         AND crapbpr.tpctrpro = 90
         AND crapbpr.nrctrpro = crawepr.nrctremp
         AND crapbpr.flgalien = TRUE
         AND (crapbpr.dscatbem MATCHES "*AUTOMOVEL*" OR
              crapbpr.dscatbem MATCHES "*MOTO*"      OR
              crapbpr.dscatbem MATCHES "*CAMINHAO*"):

        ASSIGN crapbpr.flginclu = TRUE
               crapbpr.cdsitgrv = 0
               crapbpr.tpinclus = "A".
    END.

    RELEASE crawepr.
    RELEASE crapbpr.


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
                                        INPUT "", /*par_cddopcao,*/
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
              crapbpr.dscatbem MATCHES "*CAMINHAO*") :

        IF  crapbpr.tpdbaixa = "M" THEN /* Se já foi baixado manual */
            NEXT.

        ASSIGN crapbpr.flgbaixa = TRUE
               crapbpr.dtdbaixa = par_dtmvtolt
               crapbpr.tpdbaixa = "A".
    END.


    RETURN "OK".

END PROCEDURE.

/******************************************************************************/

PROCEDURE gravames_historico :

    DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                 NO-UNDO.
    DEF  INPUT PARAM par_cdcoptel LIKE crapcop.cdcooper                 NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INT                                NO-UNDO.
    DEF  INPUT PARAM par_nrctrpro AS INT                                NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                               NO-UNDO.

    DEF OUTPUT PARAM ret_nmarquiv AS CHAR                               NO-UNDO.

    DEF          VAR aux_dsoperac AS CHAR                               NO-UNDO.

    FORM "CONTA/DV"                                      AT 003
         "CONTRATO"                                      AT 014
         "OPERACAO"                                      AT 025
         "LOTE"                                          AT 038
         "DAT ENVIO"                                     AT 048
         "DAT RETORNO"                                   AT 058
         "CHASSI"                                        AT 071
        WITH NO-BOX NO-ATTR-SPACE NO-LABELS WIDTH 230 FRAME f_header.

    FORM SKIP
         crapgrv.nrdconta       FORMAT "zzzz,zzz,9"      AT 001
         crapgrv.nrctrpro       FORMAT "z,zzz,zz9"       AT 013
         aux_dsoperac           FORMAT "x(12)"           AT 025
         crapgrv.nrseqlot       FORMAT "9999999"         AT 038
         crapgrv.dtenvgrv       FORMAT "99/99/9999"      AT 047
         crapgrv.dtretgrv       FORMAT "99/99/9999"      AT 059
         crapgrv.dschassi       FORMAT "x(20)"           AT 071
        WITH NO-BOX NO-ATTR-SPACE NO-LABELS WIDTH 230 FRAME f_dados.


    FIND FIRST crapcop
         WHERE crapcop.cdcooper = par_cdcooper
         NO-LOCK NO-ERROR.

    ASSIGN aux_nmdircop = "/usr/coop/" + crapcop.dsdircop +
                              "/rl/"
           ret_nmarquiv = aux_nmdircop + "crrl670_" +
                          STRING(RANDOM(1,999999))
           ret_nmarquiv = ret_nmarquiv + ".lst".


    OUTPUT STREAM str_1 TO VALUE(ret_nmarquiv).
           /*PAGED PAGE-SIZE 62.*/

    { sistema/generico/includes/b1cabrelvar.i }
    /*{ sistema/generico/includes/b1cabrel132.i "11" 670}*/

    /*VIEW STREAM str_1 FRAME f_cabrel234_1.*/
    
    DISPLAY STREAM str_1
              WITH FRAME f_header.
    DOWN WITH FRAME f_header.

    ASSIGN aux_dsoperac = "".

    FOR EACH crapgrv NO-LOCK
       WHERE crapgrv.cdcooper = par_cdcoptel         
         AND crapgrv.nrdconta = par_nrdconta
         AND (crapgrv.nrctrpro = par_nrctrpro OR par_nrctrpro = 0)
          BY crapgrv.nrctrpro DESC
          BY crapgrv.dtenvgrv DESC
          BY crapgrv.nrseqlot DESC:

        CASE crapgrv.cdoperac:
            WHEN 1  THEN ASSIGN aux_dsoperac = "INCLUSAO".
            WHEN 2  THEN ASSIGN aux_dsoperac = "CANCELAMENTO".
            WHEN 3  THEN ASSIGN aux_dsoperac = "BAIXA".
        END CASE.

        /*IF  LINE-COUNTER(str_1) >  PAGE-SIZE(str_1) - 1   THEN DO:
            PAGE STREAM str_1.

            DISPLAY STREAM str_1
                WITH FRAME f_header.
            DOWN WITH FRAME f_header.
        END.                         */

        DISPLAY STREAM str_1  crapgrv.nrdconta crapgrv.nrctrpro
                              aux_dsoperac     crapgrv.nrseqlot
                              crapgrv.dtenvgrv crapgrv.dtretgrv
                              crapgrv.dschassi
                              WITH FRAME f_dados.
        DOWN WITH FRAME f_dados.
    END.

    OUTPUT STREAM str_1 CLOSE.

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
                                        INPUT "", /*par_cddopcao,*/
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

