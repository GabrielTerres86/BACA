/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0114.p
    Autor   : Rogerius Militao (DB1)
    Data    : Setembro/2011                      Ultima atualizacao: 18/04/2017

    Objetivo  : BO - CMAPRV.

    Alteracoes: 11/10/2012 - Incluido a passagem de um novo parametro na 
                             chamada da procedure saldo_utiliza - Projeto GE
                             (Adriano).
        
                06/08/2013 - Incluido verificacao de proposta de emprestimo
                             aprovado que ainda nao esta na crapepr para
                             não estourar limite do comite local (Tiago).
                
                13/11/2013 - Nova forma de chamar as agências, de PAC agora 
                             a escrita será PA (Guilherme Gielow)
                             
                23/01/2014 - Validação de CPF/CNPJ do proprietário dos bens como
                            interveniente (Lucas).
                
                22/01/2015 - Alterado o formato do campo nrctremp para 8 
                             caracters (Kelvin - 233714)
                             
                16/03/2015 - Incluir campo Parecer de Credito (Jonata-RKAM).             

                07/05/2015 - Inclusao do contrato no log na procedure 
                             Grava_Dados. (Jaison/Gielow - SD: 283541)

                28/05/2015 - Ajustado a gravação da observacao do comite para
                             qualquer alteração no situação da proposta
                             (Douglas - Melhoria 18) 

                16/06/2015 - Adicionado validação para não permitir que seja
                             alterado a situação da proposta quando o emprestimo
                             tiver sido efetuado (Douglas - Chamado 293668)
                
                19/06/2015 - Ajustado a busca da observação para o relatório 
                            (Douglas - Melhoria 18) 
                            
                07/07/2015 - Incluido alteração para o Projeto de portabilidade
                             de credito. (Reinert)
                             
                01/09/2015 - Correção na listagem de contratos a serem liquidados
                             com o contrato atual, impactando no cálculo de 
                             endividamento da conta em operações de aprovações.
                             - Lucas Lunelli (Melhoria 167 [SD 316063])
                             
                02/10/2015 - Retornar Observação na mensagem de retorno da verificação 
                             de motivo (Lucas Lunelli SD 323711)
                             
                01/02/2016 - Incluir consulta de situacao antes do cancelamento
                             de uma proposta de portabilidade. (Reinert)

                11/03/2016 - Tratar para apenas permitir aprovar pela tela CAMPRV
                             se a esteira estiver em contigencia.
                             PRJ207 - Esteira de credito (Odirlei-AMcom)

                             
                01/02/2016 - Incluir consulta de situacao antes do cancelamento
                             de uma proposta de portabilidade. (Reinert)  

                24/03/2016 - Passar informacoes da cooperativa para inclusao 
                             da portabilidade (SD 422198 - Carlos Rafael Tanholi)

                12/04/2016 - Adicionado nova situacao "SI8" na consulta para 
                             cancelamento de propostas de portabilidade. (Reinert)
                             
                18/04/2017 - Adicionado validações referentes ao cadastro de proposta
                             na procedure Valida_Dados. (Reinert - PRJ337).

                18/04/2017 - Retirado a validação dos campos RATING antigo no Valida_Dados
                             (Luiz Otavio Olinger Momm - AMCOM).
.............................................................................*/

/*............................. DEFINICOES ..................................*/

{ sistema/generico/includes/b1wgen0043tt.i }
{ sistema/generico/includes/b1wgen0114tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i    }
{ sistema/generico/includes/gera_log.i     }
{ sistema/generico/includes/var_oracle.i   }


DEF VAR aux_cdcritic AS INTE                                         NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                         NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                         NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                         NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                        NO-UNDO.

DEF VAR h-b1wgen0024 AS HANDLE                                       NO-UNDO.
DEF VAR h-b1wgen0043 AS HANDLE                                       NO-UNDO.

DEF STREAM str_1.

/*................................ PROCEDURES ..............................*/

/* ------------------------------------------------------------------------ */
/*                     EFETUA A BUSCA TITULO DA TELA                        */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Titulo:
    
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_dscomite AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_dsdircop AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN  aux_dscritic = ""
            aux_cdcritic = 0
            aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
            aux_dstransa = "Busca titulo da tela do comite aprova"
            aux_returnvl = "NOK".

    Busca: DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
        
        IF  NOT AVAILABLE crapcop  THEN 
            DO:
                ASSIGN aux_cdcritic = 651.
                LEAVE.
            END.
        
        FIND crapope WHERE crapope.cdcooper = par_cdcooper AND
                           crapope.cdoperad = par_cdoperad NO-LOCK NO-ERROR.
        
        IF  NOT AVAILABLE crapope  THEN
            DO:
    
                ASSIGN aux_cdcritic = 67.
                LEAVE.
            END.
            
        ASSIGN par_dsdircop = crapcop.dsdircop.
               par_dscomite = (IF  crapcop.flgcmtlc AND 
                                   crapope.cdcomite = 1 THEN
                                  "Local "
                              ELSE
                              IF  crapcop.flgcmtlc AND 
                                  crapope.cdcomite = 2 THEN
                                  "Sede "
                              ELSE "").

        ASSIGN aux_returnvl = "OK".
        LEAVE.

    END. /*  Busca:  */


    IF  TEMP-TABLE tt-erro:HAS-RECORDS OR
        aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAIL tt-erro THEN
                ASSIGN aux_dscritic = tt-erro.dscritic.
            ELSE 
                RUN gera_erro ( INPUT par_cdcooper,
                                INPUT par_cdagenci,
                                INPUT par_nrdcaixa,
                                INPUT 1,            /** Sequencia **/
                                INPUT aux_cdcritic,
                                INPUT-OUTPUT aux_dscritic ).

             ASSIGN aux_returnvl = "NOK".
        END.

    RETURN aux_returnvl.

END PROCEDURE. /* Busca_Titulo */

/* ------------------------------------------------------------------------ */
/*                   EFETUA A BUSCA DOS DADOS DO EMPRESTIMO                 */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Dados:

     DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
     DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
     DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
     DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
     DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
     DEF  INPUT PARAM par_cdagenc1 AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_dtpropos AS DATE                           NO-UNDO.
     DEF  INPUT PARAM par_dtaprova AS DATE                           NO-UNDO.
     DEF  INPUT PARAM par_dtaprfim AS DATE                           NO-UNDO.
     DEF  INPUT PARAM par_aprovad1 AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_aprovad2 AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_cdopeapv AS CHAR                           NO-UNDO.
     DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.

     DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
     DEF OUTPUT PARAM TABLE FOR tt-cmaprv.
     DEF OUTPUT PARAM TABLE FOR tt-erro.
     
     DEF VAR aux_cdagefim AS INTE                                    NO-UNDO.
     DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.

     EMPTY TEMP-TABLE tt-cmaprv.
     EMPTY TEMP-TABLE tt-erro.

     ASSIGN aux_dscritic = ""
            aux_cdcritic = 0
            aux_returnvl = "NOK".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:

        IF  par_cddopcao = "C" OR par_cddopcao = "A" OR par_cddopcao = "R" THEN
            DO:
                RUN Valida_Dados(  INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT par_cdoperad,
                                   INPUT par_nmdatela,
                                   INPUT par_idorigem,
                                   INPUT par_dtmvtolt,
                                   INPUT par_dtmvtopr,
                                   INPUT par_inproces,
                                   INPUT par_cddopcao,
                                   INPUT par_nrdconta,
                                   INPUT par_dtpropos,
                                   INPUT par_dtaprova,
                                   INPUT par_dtaprfim,
                                   INPUT par_aprovad1,
                                   INPUT par_aprovad2,
                                   INPUT 0, /* nrdcont1 */
                                   INPUT "",/* nrctrliq */
                                   INPUT 0, /* vlemprst */
                                   INPUT NO, /* flgerlog*/
                                   INPUT 0, /* nrctremp */
                                  OUTPUT TABLE tt-erro).

                 IF  RETURN-VALUE <> "OK" THEN
                     LEAVE.
              
              END. /* par_cddopcao = "C" */
    
         ASSIGN aux_cdagefim = IF  par_cdagenc1 = 0  THEN
                                   9999
                               ELSE
                                   par_cdagenc1.
    
         IF   par_nrdconta > 0 THEN 
              DO:
                  FOR EACH crawepr NO-LOCK WHERE
                           crawepr.cdcooper = par_cdcooper     AND
                           crawepr.nrdconta = par_nrdconta USE-INDEX crawepr1,
                      FIRST crapass NO-LOCK WHERE
                            crapass.cdcooper = par_cdcooper       AND
                            crapass.nrdconta = crawepr.nrdconta:
           
                      IF   par_dtpropos <> ? THEN
                           IF   crawepr.dtmvtolt < par_dtpropos THEN
                                NEXT.
           
                       RUN verifica_selecao(INPUT par_cdcooper,
                                            INPUT par_dtmvtolt,
                                            INPUT par_dtaprova,
                                            INPUT par_dtaprfim,
                                            INPUT par_aprovad1,
                                            INPUT par_aprovad2, 
                                            INPUT par_cdopeapv).

                  END.
              END.
         ELSE 
              DO:  
                  FOR EACH crawepr NO-LOCK WHERE
                           crawepr.cdcooper  = par_cdcooper         AND
                           crawepr.dtmvtolt >= par_dtpropos USE-INDEX crawepr3,
                      FIRST crapass NO-LOCK WHERE
                            crapass.cdcooper = par_cdcooper         AND
                            crapass.nrdconta = crawepr.nrdconta     AND
                           ((crapass.cdagenci = par_cdagenc1        AND 
                             par_cdagenc1 <> 0)                     OR
                            (crapass.cdagenci >= par_cdagenc1       AND
                             crapass.cdagenci <= aux_cdagefim)):       
                      
                      RUN verifica_selecao(INPUT par_cdcooper,
                                           INPUT par_dtmvtolt,
                                           INPUT par_dtaprova,
                                           INPUT par_dtaprfim,
                                           INPUT par_aprovad1,
                                           INPUT par_aprovad2, 
                                           INPUT par_cdopeapv).
                  END.
            END.
        
        ASSIGN aux_returnvl = "OK".
        LEAVE Busca.
        

     END. /*  Busca: DO WHILE TRUE ON ENDKEY UNDO, LEAVE: */
    
     IF  TEMP-TABLE tt-erro:HAS-RECORDS OR
         aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.

             IF  AVAIL tt-erro THEN
                 ASSIGN aux_dscritic = tt-erro.dscritic.
             ELSE 
                 RUN gera_erro ( INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT 1,            /** Sequencia **/
                                 INPUT aux_cdcritic,
                                 INPUT-OUTPUT aux_dscritic ).

             RETURN "NOK".
         END.
     ELSE 
         DO:
         
            IF  par_cddopcao <> 'R' THEN
                RUN paginacao ( INPUT par_nriniseq, 
                                INPUT par_nrregist, 
                                OUTPUT par_qtregist ).
         
         END.


     RETURN "OK".

END PROCEDURE. /* Busca_Dados */


/* ------------------------------------------------------------------------ */
/*                 EFETUA A VALIDAÇÃO DOS DADOS DO EMPRESTIMO               */
/* ------------------------------------------------------------------------ */
PROCEDURE Valida_Dados:

     DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
     DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
     DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
     DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
     DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
     DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_dtpropos AS DATE                           NO-UNDO.
     DEF  INPUT PARAM par_dtaprova AS DATE                           NO-UNDO.
     DEF  INPUT PARAM par_dtaprfim AS DATE                           NO-UNDO.
     DEF  INPUT PARAM par_aprovad1 AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_aprovad2 AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_nrdcont1 AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_nrctrliq AS CHAR                           NO-UNDO.
     DEF  INPUT PARAM par_vlemprst AS DECI                           NO-UNDO.
     DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
     DEF  INPUT PARAM par_nrctremp LIKE crawepr.nrctremp             NO-UNDO.


     DEF OUTPUT PARAM TABLE FOR tt-erro.
     
     DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
     DEF VAR aux_vlutiliz AS DECI                                    NO-UNDO.
     DEF VAR aux_contigen AS CHAR                                    NO-UNDO.
     DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.
     DEF VAR aux_habrat   AS CHAR                                    NO-UNDO.
     EMPTY TEMP-TABLE tt-erro.

     FIND FIRST crapprm WHERE crapprm.nmsistem = 'CRED' AND
                              crapprm.cdacesso = 'HABILITA_RATING_NOVO' AND
                              crapprm.cdcooper = par_cdcooper
                              NO-LOCK NO-ERROR.

     ASSIGN aux_habrat = 'N'.
     IF AVAIL crapprm THEN DO:
       ASSIGN aux_habrat = crapprm.dsvlrprm.
     END.
     ASSIGN aux_dscritic = ""
            aux_cdcritic = 0
            aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
            aux_dstransa = "Validacao dos dados situacao do emprestimo"
            aux_returnvl = "NOK".

     Valida: DO ON ERROR UNDO Valida, LEAVE Valida:
         
	     IF ( par_cddopcao = "A" ) THEN
       DO:
       
          IF par_nrdcont1 <> 0 AND
             par_nrctremp <> 0 AND
            (aux_habrat = 'N'  OR
	     par_cdcooper = 3) THEN
            DO:
              FIND FIRST crapprp WHERE crapprp.cdcooper = par_cdcooper AND 
                                       crapprp.nrdconta = par_nrdcont1 AND 
                                       crapprp.nrctrato = par_nrctremp NO-LOCK NO-ERROR.
              IF  NOT AVAIL crapprp THEN
              DO:
                  ASSIGN aux_dscritic = "Registro de Cadastro de Propostas nao encontrado.".
                  LEAVE Valida.
              END.
              
              IF crapprp.nrgarope = 0 THEN
              DO:
                  ASSIGN aux_dscritic = "Favor Preencher a Garantia na Proposta - tela ATENDA.".
                  LEAVE Valida.
              END.

              IF crapprp.nrliquid = 0 THEN
              DO:
                  ASSIGN aux_dscritic = "Favor Preencher a Liquidez na Proposta - tela ATENDA.".
                                        LEAVE Valida.
              END.

              IF crapprp.nrpatlvr = 0 THEN
              DO:
                  ASSIGN aux_dscritic = "Favor Preencher Patr. Pessoal Livre na Proposta - tela ATENDA.".
                  LEAVE Valida.
              END.

              IF crapprp.nrinfcad = 0 THEN
              DO:
                  ASSIGN aux_dscritic = "Favor Preencher Inf. Cadastrais na Proposta - tela ATENDA.".
                  LEAVE Valida.
              END.
              
              FIND crapass WHERE crapass.cdcooper = par_cdcooper  AND  
                                 crapass.nrdconta = par_nrdcont1  NO-LOCK NO-ERROR.
              
              IF  NOT AVAILABLE crapass  THEN
                  DO:
                      ASSIGN aux_dscritic = "Registro de Titular nao encontrado.".
                      LEAVE Valida.
                  END.

              IF crapass.inpessoa = 2 AND crapprp.nrperger = 0 THEN
              DO:
                  ASSIGN aux_dscritic = "Favor Preencher a Percep. Geral Empresa na Proposta - tela ATENDA.".
                  LEAVE Valida.
              END.          
              
            END.
                                
          /* Verificar se a Esteira esta em contigencia para a cooperativa*/
          { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
          RUN STORED-PROCEDURE pc_param_sistema aux_handproc = PROC-HANDLE
            (INPUT "CRED",           /* pr_nmsistem */
            INPUT par_cdcooper,     /* pr_cdcooper */
            INPUT "CONTIGENCIA_ESTEIRA_IBRA",  /* pr_cdacesso */
            OUTPUT ""               /* pr_dsvlrprm */
            ).

          CLOSE STORED-PROCEDURE pc_param_sistema WHERE 
          PROC-HANDLE = aux_handproc.
          { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }


          ASSIGN aux_contigen = "0"
                 aux_contigen = pc_param_sistema.pr_dsvlrprm
                              when pc_param_sistema.pr_dsvlrprm <> ?.
            
          /* se nao estiver em contigencia nao deve permitir 
            aprovar pela tela CMAPRV */
          IF aux_contigen = "0" THEN
          DO:
            ASSIGN aux_dscritic = "Esta funcionalidade esta bloqueada, " + 
                      "aprovacao deve ser realizada pela " +
                      "esteira de credito.".
            LEAVE Valida.
          END.
        END.

         IF  ( par_cddopcao = "C"  OR par_cddopcao = "R" OR 
             ( par_cddopcao = "A" AND par_nrdcont1 = 0 ) ) THEN
             DO:
                 IF   par_nrdconta = 0 AND
                      par_dtpropos = ?  THEN
                      DO:
                          ASSIGN aux_dscritic = "Conta ou Data da " + 
                                                "Proposta deve ser informado.".
                          LEAVE Valida. 
                      END.
        
                 IF   par_dtaprova <> ?  AND  par_dtaprfim = ?  THEN
                      DO:
                          ASSIGN aux_dscritic = "Datas Aprovacao devem ser " +  
                                                "preenchidas corretamente.".
                          LEAVE Valida.
                      END.
        
                IF   par_aprovad2 < par_aprovad1  THEN
                     DO:
                        aux_cdcritic = 444.
                        LEAVE Valida.
                     END.
         END.
         ELSE 
             IF ( par_cddopcao = "A" ) THEN
                DO:
                    
                    FIND crapcop 
                        WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

                    FIND crapope 
                        WHERE crapope.cdcooper = par_cdcooper AND
                              crapope.cdoperad = par_cdoperad NO-LOCK NO-ERROR.
                    
                    IF   crapcop.flgcmtlc     AND
                         crapope.cdcomite = 0 THEN  /* Comite Nao Cadastrado */
                         DO:
                             ASSIGN aux_dscritic =  
                                    "Operador nao permitido! " + 
                                    "Necessario cadastrar um comite.".
                             LEAVE Valida.
                         END.

                    /* Validar se os proprietários do(s) bem(ns) são interveniente do contrato. */
                    FIND FIRST crawepr WHERE crawepr.cdcooper = par_cdcooper AND 
                                             crawepr.nrdconta = par_nrdcont1 AND 
                                             crawepr.nrctremp = par_nrctremp NO-LOCK NO-ERROR.

                    IF  NOT AVAIL crawepr THEN
                        DO:
                            ASSIGN aux_dscritic =  
                                    "Registro de Contrato nao encontrado.".
                            LEAVE Valida.
                        END.

                    /* Validar se o emprestimo ja foi efetuado */
                    FIND FIRST crapepr WHERE crapepr.cdcooper = crawepr.cdcooper AND 
                                             crapepr.nrdconta = crawepr.nrdconta AND 
                                             crapepr.nrctremp = crawepr.nrctremp NO-LOCK NO-ERROR.
                    IF  AVAIL crapepr THEN
                        DO:
                            ASSIGN aux_dscritic = "Atencao: Alteracao nao permitida. Proposta liberada".
                            LEAVE Valida.
                        END.

                    FIND crapass WHERE crapass.cdcooper = par_cdcooper      AND  
                                       crapass.nrdconta = crawepr.nrdconta  NO-LOCK NO-ERROR.
                    
                    IF  NOT AVAILABLE crapass  THEN
                        DO:
                            ASSIGN aux_dscritic = "Registro de Titular nao encontrado.".
                            LEAVE Valida.
                        END.

                    FOR EACH crapbpr WHERE crapbpr.cdcooper = crawepr.cdcooper   AND
                                           crapbpr.nrdconta = crawepr.nrdconta   AND
                                           crapbpr.tpctrpro = 90                 AND
                                           crapbpr.nrctrpro = crawepr.nrctremp   AND
                                           crapbpr.flgalien = TRUE               NO-LOCK:

                        IF  crapbpr.nrcpfbem = 0                OR
                            crapbpr.nrcpfbem = crapass.nrcpfcgc THEN
                            NEXT.
                        
                        IF  NOT CAN-FIND(crapavt WHERE crapavt.cdcooper = crawepr.cdcooper   AND 
                                                       crapavt.nrcpfcgc = crapbpr.nrcpfbem   AND
                                                       crapavt.nrdconta = crawepr.nrdconta   AND
                                                       crapavt.nrctremp = crawepr.nrctremp   AND
                                                       crapavt.tpctrato = 9 NO-LOCK)         THEN
                            DO:
                                ASSIGN aux_dscritic = "CPF/CNPJ PROPR. DO(S) BEM(NS) DEVE SER CADASTRADO COMO INTERVENIENTE!".
                                LEAVE Valida.
                            END.

                    END.
    
                    IF  crapcop.flgcmtlc         AND
                        crapope.cdcomite = 1     THEN  /* Comite Local */
                        DO:
                            IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
                                RUN sistema/generico/procedures/b1wgen9999.p
                                    PERSISTENT SET h-b1wgen9999.

                            RUN saldo_utiliza IN h-b1wgen9999 
                                ( INPUT  par_cdcooper,
                                  INPUT  par_cdagenci,
                                  INPUT  par_nrdcaixa,
                                  INPUT  par_cdoperad,
                                  INPUT  "b1wgen0114",
                                  INPUT  par_idorigem,
                                  INPUT  par_nrdcont1,
                                  INPUT  1, /* idseqttl */
                                  INPUT  par_dtmvtolt,
                                  INPUT  par_dtmvtopr,
                                  INPUT  par_nrctrliq,
                                  INPUT  par_inproces,
                                  INPUT  FALSE, /*Consulta por cpf*/
                                 OUTPUT aux_vlutiliz,
                                 OUTPUT TABLE tt-erro).

                            IF  VALID-HANDLE(h-b1wgen9999) THEN
                                DELETE PROCEDURE h-b1wgen9999.

                            IF  RETURN-VALUE <> "OK" THEN
                                LEAVE Valida.

                            FIND crapage WHERE 
                                 crapage.cdcooper = par_cdcooper     AND
                                 crapage.cdagenci = crapope.cdagenci 
                                 NO-LOCK NO-ERROR.
    
                              IF   NOT AVAILABLE crapage   THEN
                                   DO:
                                       BELL.
                                       ASSIGN aux_dscritic =  
                                              "O operador nao possui PA " +
                                              "associado ao seu cadastro.".
                                       LEAVE Valida.
                                   END.
                              
                            /*
                            /*insitapr = 1 (aprovado), insitapr = 3 (aprovado com restricoes)*/
                            FOR EACH crawepr WHERE crawepr.cdcooper =  par_cdcooper AND 
                                                   crawepr.nrdconta =  par_nrdcont1 AND 
                                                   crawepr.nrctremp <> par_nrctremp AND
                                                  (crawepr.insitapr =  1  OR 
                                                   crawepr.insitapr =  3) NO-LOCK:
                                
                                FIND crapepr WHERE crapepr.cdcooper = crawepr.cdcooper AND
                                                   crapepr.nrdconta = crawepr.nrdconta AND
                                                   crapepr.nrctremp = crawepr.nrctremp 
                                                   NO-LOCK NO-ERROR.
                            
                                IF  NOT AVAIL(crapepr) THEN
                                    DO: 
                                        ASSIGN aux_vlutiliz = aux_vlutiliz + crawepr.vlemprst.
                                    END.
                            END.
                            */

                            IF   crapage.vllimapv < 
                                (aux_vlutiliz + par_vlemprst)   THEN
                                 DO:
                                     BELL.
                                     ASSIGN aux_dscritic = 
                                         "Essa proposta deve ser aprovada " +
                                         "pelo COMITE SEDE.".
                                     LEAVE Valida.
                                 END.
                         END.
                    IF  par_idorigem = 1 THEN
                        DO:

                            FIND tbepr_portabilidade WHERE tbepr_portabilidade.cdcooper = par_cdcooper AND 
                                                           tbepr_portabilidade.nrdconta = par_nrdcont1 AND 
                                                           tbepr_portabilidade.nrctremp = par_nrctremp 
                                                     NO-LOCK NO-ERROR.

                            IF  AVAIL tbepr_portabilidade THEN
                                DO:
                                     BELL.
                                     ASSIGN aux_dscritic = 
                                         "Operacao invalida para esse tipo de contrato.".
                                     LEAVE Valida.
                                END.

                        END.
                END.
     
         ASSIGN aux_returnvl = "OK".
         LEAVE Valida.

     END. /* Valida: DO WHILE TRUE ON ENDKEY UNDO, LEAVE: */

     IF  TEMP-TABLE tt-erro:HAS-RECORDS OR
         aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.

             IF  AVAIL tt-erro THEN
                 ASSIGN aux_dscritic = tt-erro.dscritic.
             ELSE 
                 RUN gera_erro ( INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT 1,            /** Sequencia **/
                                 INPUT aux_cdcritic,
                                 INPUT-OUTPUT aux_dscritic ).

             IF  par_flgerlog  THEN
                 RUN proc_gerar_log ( INPUT par_cdcooper,
                                      INPUT par_cdoperad,
                                      INPUT aux_dscritic,
                                      INPUT aux_dsorigem,
                                      INPUT aux_dstransa,
                                      INPUT FALSE,
                                      INPUT 1,
                                      INPUT par_nmdatela,
                                      INPUT par_nrdconta,
                                     OUTPUT aux_nrdrowid ).

             RETURN "NOK".
         END.

     RETURN "OK".

END PROCEDURE. /* Valida_Dados */


/* ------------------------------------------------------------------------ */
/*               EFETUA A VERIFICACAO DO RATING PARA EMPRESTIMO              */
/* ------------------------------------------------------------------------ */
PROCEDURE Verifica_Rating:
    
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcont1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_msgalert AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_msgretor AS CHAR                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    Verifica: DO ON ERROR UNDO Verifica, LEAVE Verifica:

        IF  NOT VALID-HANDLE(h-b1wgen0043) THEN
            RUN sistema/generico/procedures/b1wgen0043.p
                PERSISTENT SET h-b1wgen0043.
    
        RUN calcula-rating IN h-b1wgen0043
            (INPUT par_cdcooper,
             INPUT par_cdagenci,
             INPUT par_nrdcaixa,
             INPUT par_cdoperad,
             INPUT par_dtmvtolt,
             INPUT par_dtmvtopr,
             INPUT par_inproces, 
             INPUT par_nrdcont1, /* conta */
             INPUT 90,           /* emprestimo */
             INPUT par_nrctremp, /* contrato */
             INPUT FALSE,        /* nao criar rating */
             INPUT TRUE,         /* calcular rating */
             INPUT 1,            /* sequencia ttl */
             INPUT par_idorigem, /* origem */
             INPUT par_nmdatela, /* tela */
             INPUT FALSE,        /* gera log */
             OUTPUT TABLE tt-erro,
             OUTPUT TABLE tt-impressao-coop,
             OUTPUT TABLE tt-impressao-rating,
             OUTPUT TABLE tt-impressao-risco,
             OUTPUT TABLE tt-impressao-risco-tl,
             OUTPUT TABLE tt-impressao-assina,
             OUTPUT TABLE tt-efetivacao,
             OUTPUT TABLE tt-ratings).
    
        IF  VALID-HANDLE(h-b1wgen0043) THEN
            DELETE OBJECT h-b1wgen0043.
    
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
        IF   AVAILABLE tt-erro THEN
             DO:
                 ASSIGN par_msgalert = 
                                    "Atencao! Proposta sem cadastro no Risco.".
                 EMPTY TEMP-TABLE tt-erro.
             END.   
        ELSE
             DO:
                 FIND tt-impressao-risco NO-LOCK NO-ERROR.
             
                 IF   AVAILABLE tt-impressao-risco THEN
                      DO:
                          IF   tt-impressao-risco.dsdrisco = "C" OR
                               tt-impressao-risco.dsdrisco = "D" OR
                               tt-impressao-risco.dsdrisco = "E" OR
                               tt-impressao-risco.dsdrisco = "F" OR
                               tt-impressao-risco.dsdrisco = "G" OR
                               tt-impressao-risco.dsdrisco = "H" THEN
                               DO:

                                  ASSIGN par_msgretor = "Risco da proposta: " +
                                        STRING(tt-impressao-risco.dsdrisco,"x")
                                          + " - Continuar a operacao? (S/N)".
    
                               END.
                      END.
             END.

        LEAVE Verifica.
        
    END. /* Verifica */

    RETURN "OK".


END PROCEDURE. /* Verifica_Rating */


/* ------------------------------------------------------------------------ */
/*            EFETUA VERIFICAÇÃO MOTIVO NAO APROVACAO DO EMPRESTIMO         */
/* ------------------------------------------------------------------------ */
PROCEDURE Verifica_Motivo:

     DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
     DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
     DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_flgerlog AS LOGICAL                        NO-UNDO.

     DEF OUTPUT PARAM par_cdcomite AS INTE                           NO-UNDO.
     DEF OUTPUT PARAM par_dsobscmt AS CHAR                           NO-UNDO.
     DEF OUTPUT PARAM par_flgcmtlc AS LOGICAL                        NO-UNDO.
     DEF OUTPUT PARAM par_msgretor AS CHAR                           NO-UNDO.

     DEF OUTPUT PARAM TABLE FOR tt-erro.

     DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.

     EMPTY TEMP-TABLE tt-erro.

     ASSIGN par_msgretor = ""
            aux_dscritic = ""
            aux_cdcritic = 0
            aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
            aux_dstransa = "Verifica motivo nao aprovacao do emprestimo."
            aux_returnvl = "NOK".

     Verifica: DO ON ERROR UNDO Verifica, LEAVE Verifica:
            
            FIND crawepr WHERE 
                 crawepr.cdcooper = par_cdcooper        AND
                 crawepr.nrdconta = par_nrdconta        AND
                 crawepr.nrctremp = par_nrctremp 
                NO-LOCK NO-ERROR.
    
            IF   LENGTH(crawepr.dsobscmt) >= 650 THEN
                 DO:
                    ASSIGN par_msgretor = "Ultrapassou o limite de " +
                           "caracteres no campo observacao."
                           par_dsobscmt = crawepr.dsobscmt.
                 END.   
            ELSE
                 DO:
                    FIND crapcop 
                        WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

                    IF  NOT AVAILABLE crapcop  THEN 
                        DO:
                            ASSIGN aux_cdcritic = 61.
                            LEAVE Verifica.
                        END.

                    FIND crapope 
                        WHERE crapope.cdcooper = par_cdcooper AND
                              crapope.cdoperad = par_cdoperad NO-LOCK NO-ERROR.

                    IF  NOT AVAILABLE crapope  THEN 
                        DO:
                            ASSIGN aux_cdcritic = 67.
                            LEAVE Verifica.
                        END.

                    ASSIGN par_cdcomite = crapope.cdcomite
                           par_dsobscmt = crawepr.dsobscmt
                           par_flgcmtlc = crapcop.flgcmtlc.
    
                 END.
            
            ASSIGN aux_returnvl = "OK".
            LEAVE Verifica.

     END. /* Verifica: DO WHILE TRUE ON ENDKEY UNDO, LEAVE: */


     IF  TEMP-TABLE tt-erro:HAS-RECORDS OR
         aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.

             IF  AVAIL tt-erro THEN
                 ASSIGN aux_dscritic = tt-erro.dscritic.
             ELSE 
                 RUN gera_erro ( INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT 1,            /** Sequencia **/
                                 INPUT aux_cdcritic,
                                 INPUT-OUTPUT aux_dscritic ).

             IF  par_flgerlog  THEN
                 RUN proc_gerar_log ( INPUT par_cdcooper,
                                      INPUT par_cdoperad,
                                      INPUT aux_dscritic,
                                      INPUT aux_dsorigem,
                                      INPUT aux_dstransa,
                                      INPUT FALSE,
                                      INPUT 1,
                                      INPUT par_nmdatela,
                                      INPUT par_nrdconta,
                                     OUTPUT aux_nrdrowid ).

             ASSIGN aux_returnvl = "NOK".
         END.

     RETURN aux_returnvl.

END PROCEDURE. /* Verifica_Motivo */


/* ------------------------------------------------------------------------ */
/*                  EFETUA GRAVACAO DA SITUACAO DO EMPRESTIMO               */
/* ------------------------------------------------------------------------ */
PROCEDURE Grava_Dados:

     DEF  INPUT PARAM par_cdcooper AS INTE              NO-UNDO.
     DEF  INPUT PARAM par_cdagenci AS INTE              NO-UNDO.
     DEF  INPUT PARAM par_nrdcaixa AS INTE              NO-UNDO.
     DEF  INPUT PARAM par_nmdatela AS CHAR              NO-UNDO.
     DEF  INPUT PARAM par_idorigem AS INTE              NO-UNDO.
     DEF  INPUT PARAM par_dtmvtolt AS DATE              NO-UNDO.
     DEF  INPUT PARAM par_cdoperad AS CHAR              NO-UNDO.
     DEF  INPUT PARAM par_nrdcont1 AS INTE              NO-UNDO.
     DEF  INPUT PARAM par_nrctremp AS INTE              NO-UNDO.
     DEF  INPUT PARAM par_insitapv AS INTE              NO-UNDO.
     DEF  INPUT PARAM par_dsobscmt AS CHAR              NO-UNDO.
     DEF  INPUT PARAM par_dsobstel AS CHAR              NO-UNDO.
     DEF  INPUT PARAM par_dscmaprv AS CHAR              NO-UNDO.
     DEF  INPUT PARAM par_flgalter AS LOGICAL           NO-UNDO.
     DEF  INPUT PARAM par_insitaux AS INTE              NO-UNDO.
     DEF  INPUT PARAM par_flgerlog AS LOGICAL           NO-UNDO.

     DEF OUTPUT PARAM TABLE FOR tt-emprestimo.
     DEF OUTPUT PARAM TABLE FOR tt-erro.

     DEF   VAR aux_des_erro AS CHAR                     NO-UNDO.
     DEF   VAR aux_dsobscmt AS CHAR                     NO-UNDO.
     DEF   VAR aux_datahora AS CHAR                     NO-UNDO.
     DEF   VAR aux_returnvl AS CHAR                     NO-UNDO. 
     DEF   VAR aux_contador AS INTE                     NO-UNDO.
     DEF   VAR aux_dsresapr AS CHAR                     NO-UNDO.
     DEF   VAR aux_nrtelefo AS CHAR FORMAT "x(15)"      NO-UNDO.
     DEF   VAR aux_txjureft AS DECI                     NO-UNDO.
     DEF   VAR aux_dsendere AS CHAR                     NO-UNDO.
     DEF   VAR aux_nrendere AS INTE                     NO-UNDO.
     DEF   VAR aux_nmcidade AS CHAR                     NO-UNDO.
     DEF   VAR aux_cdufende AS CHAR                     NO-UNDO.
     DEF   VAR aux_nrcepend AS INTE                     NO-UNDO.
     DEF   VAR aux_idsolici AS INTE                     NO-UNDO.
     DEF   VAR aux_flgrespo AS INTE                     NO-UNDO.
     DEF   VAR aux_txjurnom AS CHAR                     NO-UNDO.
     DEF   VAR aux_txjuranu AS DECI                     NO-UNDO.
     DEF   VAR aux_txjurefp AS CHAR                     NO-UNDO.
     DEF   VAR aux_vlrtxcet AS CHAR                     NO-UNDO.
     DEF   VAR aux_vlpreemp AS CHAR                     NO-UNDO.
     DEF   VAR aux_dtprvcto AS DATE                     NO-UNDO.
     DEF   VAR aux_dtulvcto AS DATE                     NO-UNDO.
     DEF   VAR aux_cdmodali AS CHAR                     NO-UNDO.
     DEF   VAR aux_nrcpfcgc LIKE crapass.nrcpfcgc       NO-UNDO.
	 DEF   VAR aux_indremun AS CHAR                     NO-UNDO.

     EMPTY TEMP-TABLE tt-emprestimo.
     EMPTY TEMP-TABLE tt-erro.

     ASSIGN aux_dscritic = ""
            aux_cdcritic = 0
            aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
            aux_dstransa = "Grava situacao do emprestimo."
            aux_returnvl = "NOK".

     Grava: DO TRANSACTION
        ON ERROR  UNDO Grava, LEAVE Grava
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:
        
    	IF  par_insitapv = 1 THEN
    	    ASSIGN aux_dsresapr = "".
    	ELSE IF par_insitapv = 2 THEN
    	    ASSIGN aux_dsresapr = "NA :".
    	ELSE IF par_insitapv = 3 THEN
    	    ASSIGN aux_dsresapr = "AR :".
    	ELSE IF par_insitapv = 4 THEN
    	    ASSIGN aux_dsresapr = "RF :".

        IF  SUBSTR(par_dsobstel,1,4) <> aux_dsresapr THEN
            DO:
                ASSIGN par_dsobstel = aux_dsresapr + par_dsobstel.
            END.

        CREATE tt-emprestimo.

        Contador: DO aux_contador = 1 TO 10:
                                
            FIND crawepr WHERE 
                 crawepr.cdcooper = par_cdcooper AND
                 crawepr.nrdconta = par_nrdcont1 AND
                 crawepr.nrctremp = par_nrctremp 
                 EXCLUSIVE-LOCK NO-ERROR.

            IF  NOT AVAIL crawepr THEN
                DO:
                    IF  LOCKED crawepr   THEN
                        DO:
                            IF  aux_contador = 10 THEN
                                DO:
                                    ASSIGN aux_cdcritic = 77.
                                    LEAVE Contador.
                                END.
                            ELSE
                                DO:
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT Contador.
                                END.
                        END.
                    ELSE
                        DO:
                            ASSIGN aux_cdcritic = 356.
                            LEAVE Contador.
                        END.
                END.
            ELSE
                LEAVE Contador.

        END. /* Contador */

        IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
            UNDO Grava, LEAVE Grava.

        IF crawepr.dsobscmt = ? THEN
        DO:
            crawepr.dsobscmt = "".
        END.

		/*vr_indRemun := (CASE WHEN rw_crawepr.cddindex = 1 THEN '08' ELSE '06' END); IndRemun (06 - TR, 08 -	CDI)*/
		IF crawepr.cddindex = 1 THEN
		  DO:
		    aux_indremun = "08".
		  END.
		ELSE
		  DO:
		    aux_indremun = "06".
		  END.

        IF (par_flgalter AND 
            LENGTH(par_dsobstel + "" + par_dscmaprv) > 650)
            OR
           (NOT par_flgalter AND 
            LENGTH(crawepr.dsobscmt + "" + par_dsobstel + "" + par_dscmaprv) > 650)  THEN
            DO:
                ASSIGN aux_dscritic = "Mensagem ultrapassa limite de 650 caracteres.".
                UNDO Grava, LEAVE Grava.               
            END.

        ASSIGN aux_dsobscmt = par_dscmaprv.

        IF  aux_dsobscmt <> ""   AND
            par_dsobstel <> ""   THEN
            ASSIGN par_dsobscmt = par_dsobscmt + " - ".

        IF  NOT par_flgalter THEN
            DO:
                ASSIGN aux_datahora = " [" + STRING(par_dtmvtolt,
                "99/99/99") + " OPERADOR " + STRING(par_cdoperad) + "]"
                       aux_dsobscmt = aux_dsobscmt + par_dsobstel
                       crawepr.dsobscmt = crawepr.dsobscmt + " " +
                                          UPPER(aux_dsobscmt)
                       crawepr.dsobscmt = SUBSTR(crawepr.dsobscmt,1,650)
                       aux_dsobscmt = crawepr.dsobscmt. 

                IF  aux_dsobscmt <> "" THEN
                    DO:
                        ASSIGN crawepr.dsobscmt         = crawepr.dsobscmt + aux_datahora
                               tt-emprestimo.dsobscmt   = aux_dsobscmt.
                    END.
            END.
        ELSE
            ASSIGN aux_dsobscmt     = par_dsobstel
                   crawepr.dsobscmt = UPPER(aux_dsobscmt)
                   tt-emprestimo.dsobscmt = aux_dsobscmt.

        IF  par_insitapv <> par_insitaux  THEN
            DO:
                ASSIGN tt-emprestimo.cdopeapv  = par_cdoperad
                       tt-emprestimo.dtaprova  = par_dtmvtolt
                       tt-emprestimo.hrtransa  = TIME
                       tt-emprestimo.hrtransf  = STRING(TIME,"HH:MM:SS")
                       crawepr.insitapr        = par_insitapv
                       crawepr.cdopeapr        = par_cdoperad
                       crawepr.dtaprova        = par_dtmvtolt
                       crawepr.hraprova        = TIME
                       /* Se foi aprovado pela tela CMAPRV é pq 
                          esteira esta em contigencia, marcar flag com true */
                       crawepr.flgaprvc        = TRUE
                       crawepr.insitest        = 3.

                 FIND crapcop 
                     WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
                 
                 IF  NOT AVAILABLE crapcop  THEN 
                     DO:
                         ASSIGN aux_cdcritic = 61.
                         UNDO Grava, LEAVE Grava.
                     END.
   
                 FIND crapope WHERE 
                      crapope.cdcooper = par_cdcooper AND
                      crapope.cdoperad = tt-emprestimo.cdopeapv
                      NO-LOCK NO-ERROR.

                 IF  NOT AVAILABLE crapope  THEN 
                     DO:
                         ASSIGN aux_cdcritic = 67.
                         UNDO Grava, LEAVE Grava.
                     END.

                 IF  crapcop.flgcmtlc  THEN
                     ASSIGN crawepr.cdcomite       = crapope.cdcomite
                            tt-emprestimo.cdcomite = crapope.cdcomite.
                 ELSE
                     /* Comite Local */
                     ASSIGN crawepr.cdcomite       = 1
                            tt-emprestimo.cdcomite = 1.
            
                 IF   AVAIL crapope  THEN
                      ASSIGN tt-emprestimo.nmoperad = crapope.nmoperad.


                 FIND crapfin WHERE crapfin.cdcooper = crawepr.cdcooper
                                AND crapfin.cdfinemp = crawepr.cdfinemp
                                AND crapfin.tpfinali = 2
                                NO-LOCK NO-ERROR.

                 FIND craplcr WHERE craplcr.cdcooper = crawepr.cdcooper
                                AND craplcr.cdlcremp = crawepr.cdlcremp
                                NO-LOCK NO-ERROR.

                 IF  AVAIL crapfin AND AVAIL craplcr THEN
                     DO:
                        
                        ASSIGN aux_cdmodali = craplcr.cdmodali + craplcr.cdsubmod.
                     
                        FIND crapban WHERE cdbccxlt = 85 NO-LOCK NO-ERROR.

                        IF  NOT AVAIL crapban THEN
                            DO:
                                ASSIGN aux_cdcritic = 57.
                                UNDO Grava, LEAVE Grava.
                            END.

                        FIND tbepr_portabilidade WHERE tbepr_portabilidade.cdcooper = par_cdcooper
                                                   AND tbepr_portabilidade.nrdconta = par_nrdcont1
                                                   AND tbepr_portabilidade.nrctremp = par_nrctremp
                                                EXCLUSIVE-LOCK NO-ERROR.

                        IF  NOT AVAIL tbepr_portabilidade THEN
                            DO:
                                ASSIGN  aux_cdcritic = 0
                                        aux_dscritic = "Operacao de portabilidade nao encontrada.".
                                UNDO Grava, LEAVE Grava.
                            END.

                        /* Se campo o tbepr_portabilidade.nrunico_portabilidade estiver alimentado,
                           a proposta de portabilidade já existe na JDCTC e precisa ser cancelada 
                           para a inclusao de outra proposta */
                        IF  tbepr_portabilidade.dtaprov_portabilidade <> ? AND 
                            par_insitapv = 2 THEN
                            DO:

                                /* Busca cpf/cnpj do cooperado */
                                FOR FIRST crapass FIELDS (nrcpfcgc)
                                                  WHERE crapass.cdcooper = par_cdcooper
                                                    AND crapass.nrdconta = par_nrdcont1
                                                  NO-LOCK:
                                    ASSIGN aux_nrcpfcgc = crapass.nrcpfcgc.                                           
                                END.
                                    
                                /* Consulta situacao da portabilidade no JDCTC */
                                RUN consulta_situacao(INPUT par_cdcooper,                                   /* Código da Cooperativa*/
                                                     INPUT crapban.nrispbif,                                /* Nr. ISPB IF */
                                                           INPUT SUBSTRING(STRING(crapcop.nrdocnpj, 
                                                                 "99999999999999"), 1, 8),                  /* Identificador Participante Administrado */
                                                           INPUT SUBSTRING(STRING(tbepr_portabilidade.nrcnpjbase_if_origem,
                                                                 "99999999999999"), 1, 8),                  /* CNPJ Base IF Credora Original Contrato */
                                                           INPUT tbepr_portabilidade.nrunico_portabilidade, /* Número único da portabilidade na CTC */  
                                                     INPUT tbepr_portabilidade.nrcontrato_if_origem,        /* Código Contrato Original                */
                                                     INPUT aux_cdmodali,                                    /* Tipo Contrato                           */
                                                     INPUT aux_nrcpfcgc,                                    /* CNPJ CPF Cliente                        */
                                                     OUTPUT aux_des_erro,                                   /* Indicador erro OK/NOK */
                                                     OUTPUT aux_dscritic,                                   /* Descrição da crítica */ 
                                                     OUTPUT TABLE tt-dados-portabilidade).                  /* TT com dados de portabilidade */   

                                FIND FIRST tt-dados-portabilidade.

                                /* Se nao encontrou portabilidade ou houve algum erro */
                                IF  NOT AVAIL tt-dados-portabilidade OR 
                                    aux_des_erro <> "OK"             THEN
                                    DO:
                                        IF aux_dscritic = "" THEN
                                            ASSIGN aux_dscritic = "Nao foi possivel consultar a situacao da portabilidade no sistema JDCTC.".
                                         
                                        UNDO Grava, LEAVE Grava.

                                    END.

                                /* Se portabilidade ainda nao foi cancelada no JDCTC */
                                IF  NOT CAN-DO("PS7,PX7,RX9,SXA,SXB,SX7,SX9,SI3,SR6,SR7,SI8", 
                                          tt-dados-portabilidade.stportabilidade) THEN
                                    DO:
                                        /* Chama metodo de cancelamento no JDCTC */
                                RUN cancela_portabilidade (INPUT par_cdcooper,                              /* Cod. Cooperativa */
                                                           INPUT 1,                                         /* Tipo de servico(1-Proponente/2-Credora) */
                                                           INPUT "LEG",                                     /* Cod. Legado */
                                                           INPUT crapban.nrispbif,                          /* Nr. ISPB IF */
                                                           INPUT SUBSTRING(STRING(crapcop.nrdocnpj, 
                                                                 "99999999999999"), 1, 8),                  /* Identificador Participante Administrado */
                                                           INPUT SUBSTRING(STRING(tbepr_portabilidade.nrcnpjbase_if_origem,
                                                                 "99999999999999"), 1, 8),                  /* CNPJ Base IF Credora Original Contrato */
                                                           INPUT tbepr_portabilidade.nrunico_portabilidade, /* Número único da portabilidade na CTC */                                               
                                                           OUTPUT aux_flgrespo,                             /* 1 - Se o registro na JDCTC for atualizado com sucesso */
                                                           OUTPUT aux_des_erro,                             /* Indicador erro OK/NOK */
                                                           OUTPUT aux_dscritic).                            /* Descricao do erro */

                                IF  aux_des_erro <> "OK" OR 
                                    aux_flgrespo <> 1    THEN
                                    DO:
                                        IF aux_dscritic = "" THEN
                                            ASSIGN aux_dscritic = "Nao foi possivel efetuar o cancelamento da portabilidade no sistema JDCTC.".
                                         
                                        UNDO Grava, LEAVE Grava.
                                    END.

                                    END.

                                /* Quando cancelada a portabilidade devemos zerar os campos de nr de portabilidade e 
                                   data de aprovacao para que o contrato possa ser aprovado novamente */
                                ASSIGN tbepr_portabilidade.nrunico_portabilidade = ?
                                       tbepr_portabilidade.dtaprov_portabilidade = ?.
                                
                            END.
                        
                        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                           crapass.nrdconta = par_nrdcont1 NO-LOCK NO-ERROR.

                        IF  NOT AVAIL crapass THEN
                            DO:
                                ASSIGN aux_cdcritic = 9.
                                UNDO Grava, LEAVE Grava.
                            END.

                        FOR FIRST craptfc WHERE craptfc.cdcooper = par_cdcooper AND
                                                craptfc.nrdconta = par_nrdcont1 
                                          NO-LOCK BY craptfc.tptelefo:
                            ASSIGN aux_nrtelefo = TRIM(STRING(craptfc.nrdddtfc, "z99")) + 
                                                  TRIM(STRING(craptfc.nrtelefo, "zz99999999")).
                        END.

                        /* buscar informacoes da cooperativa para inclusao da portabilidade (SD 422198) */
						FOR FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper 
                                                NO-LOCK:

                            ASSIGN aux_dsendere = crapcop.dsendcop
                                   aux_nrendere = crapcop.nrendcop
                                   aux_nmcidade = crapcop.nmcidade
                                   aux_cdufende = crapcop.cdufdcop
                                   aux_nrcepend = crapcop.nrcepend.                                                       
                        END.                                

                        FOR EACH crappep WHERE crappep.cdcooper = crawepr.cdcooper
                                           AND crappep.nrdconta = crawepr.nrdconta
                                           AND crappep.nrctremp = crawepr.nrctremp
                                          NO-LOCK BREAK BY crappep.nrparepr:

                            IF  FIRST(crappep.nrparepr) THEN
                                ASSIGN aux_dtprvcto = crappep.dtvencto.

                            IF  LAST(crappep.nrparepr) THEN
                                ASSIGN aux_dtulvcto = crappep.dtvencto.

                        END.
                        
                        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                        RUN STORED-PROCEDURE pc_calc_taxa_juros
                            aux_handproc = PROC-HANDLE NO-ERROR(INPUT par_cdcooper
                                                               ,INPUT par_dtmvtolt
                                                               ,INPUT 0
                                                               ,INPUT crawepr.vlemprst
                                                               ,INPUT crawepr.txmensal
                                                               ,INPUT 0
                                                               ,INPUT 0
                                                               ,OUTPUT 0
                                                               ,OUTPUT 0
                                                               ,OUTPUT "").

                        CLOSE STORED-PROC pc_calc_taxa_juros
                            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                        
                        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                           

                        ASSIGN aux_txjureft  = pc_calc_taxa_juros.pr_vlrjuros
                                               WHEN pc_calc_taxa_juros.pr_vlrjuros <> ?
                               aux_cdcritic  = pc_calc_taxa_juros.pr_cdcritic
                                               WHEN pc_calc_taxa_juros.pr_cdcritic <> ?
                               aux_dscritic  = pc_calc_taxa_juros.pr_dscritic
                                               WHEN pc_calc_taxa_juros.pr_dscritic <> ?.
                                                                                   

                        ASSIGN aux_txjuranu = (EXP(1 + (crawepr.txdiaria / 100), 360) - 1) * 100
                               aux_txjurnom = REPLACE(TRIM(STRING(((EXP((aux_txjuranu / 100) + 1, 1 / 12) - 1) * 12) * 100,
                                                           "zzzzzzzzzzz9.99999")),",",".")
                               aux_txjurefp = REPLACE(TRIM(STRING(aux_txjureft,"zzzzzzzzzzz9.99")),",",".")
                               aux_vlrtxcet = REPLACE(TRIM(STRING(crawepr.percetop, "zzzzzzzzzzz9.99999")),",",".")
                               aux_vlpreemp = REPLACE(TRIM(STRING(crawepr.vlpreemp, "zzzzzzzzzzzzz9.99")),",",".").
                       
                        IF (craplcr.cdmodali + craplcr.cdsubmod) = "0401" AND
                           CAN-DO("1,3",STRING(par_insitapv))             AND 
                           tbepr_portabilidade.dtaprov_portabilidade = ?  THEN /* IncluirVeicular */
                            DO:
                                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                                RUN STORED-PROCEDURE pc_incluir_veicular
                                    aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,
                                                                         INPUT 1,
                                                                         INPUT "LEG",
                                                                         INPUT STRING(crapban.nrispbif, "99999999"),
                                                                         /*INPUT STRING(crapban.nrispbif, "99999999"),*/
                                                                         INPUT SUBSTRING(STRING(crapcop.nrdocnpj, 
                                                                                      "99999999999999"), 1, 8),
                                                                         INPUT STRING(tbepr_portabilidade.nrcontrato_if_origem),
                                                                         INPUT "0401",
                                                                         INPUT SUBSTRING(STRING(tbepr_portabilidade.nrcnpjbase_if_origem,
                                                                                         "99999999999999"), 1, 8),
                                                                         INPUT par_dtmvtolt,
                                                                         INPUT STRING(crawepr.vlemprst),
                                                                         INPUT STRING(crapass.nrcpfcgc),
                                                                         INPUT crapass.nmprimtl,
                                                                         INPUT aux_nrtelefo,
                                                                         INPUT "01",
                                                                         INPUT aux_txjurnom,
                                                                         INPUT aux_txjurefp,
                                                                         INPUT aux_vlrtxcet,
                                                                         INPUT "09",
                                                                         INPUT "01",
                                                                         INPUT par_dtmvtolt,
                                                                         INPUT STRING(crawepr.qtpreemp),
                                                                         INPUT "N",
                                                                         INPUT aux_vlpreemp,
                                                                         INPUT aux_dtprvcto,
                                                                         INPUT aux_dtulvcto,
                                                                         INPUT aux_dsendere,
                                                                         INPUT STRING(aux_nrendere),
                                                                         INPUT aux_nmcidade,
                                                                         INPUT aux_cdufende,
                                                                         INPUT STRING(aux_nrcepend),
																		 INPUT aux_indremun,
                                                                        OUTPUT 0,
                                                                        OUTPUT "",
                                                                        OUTPUT "").
                                CLOSE STORED-PROC pc_incluir_veicular
                                    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                                
                                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                                ASSIGN aux_idsolici  = pc_incluir_veicular.pr_idsolici
                                                       WHEN pc_incluir_veicular.pr_idsolici <> ?
                                       aux_des_erro  = pc_incluir_veicular.pr_des_erro
                                                       WHEN pc_incluir_veicular.pr_des_erro <> ?
                                       aux_dscritic  = pc_incluir_veicular.pr_dscritic
                                                       WHEN pc_incluir_veicular.pr_dscritic <> ?.

                                IF  aux_idsolici = 0     OR 
                                    aux_des_erro <> "OK" OR 
                                    aux_dscritic <> ""   THEN
                                    DO:
                                        ASSIGN  aux_cdcritic = 0.  
                                        IF  aux_dscritic = "" THEN
                                            DO:
                                                ASSIGN aux_dscritic = "Nao foi possivel incluir a proposta no sistema JDCTC.".
                                            END.                                        

                                        UNDO Grava, LEAVE Grava.
                                    END.
                                ELSE
                                  ASSIGN tbepr_portabilidade.dtaprov_portabilidade = par_dtmvtolt.
                            END.
                        ELSE /* IncluirPessoal */
                        IF (craplcr.cdmodali + craplcr.cdsubmod) = "0203" AND
                           CAN-DO("1,3",STRING(par_insitapv))             AND 
                           tbepr_portabilidade.dtaprov_portabilidade = ?  THEN
                            DO:
                               
                                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                                RUN STORED-PROCEDURE pc_incluir_pessoal
                                    aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,
                                                                         INPUT 1,
                                                                         INPUT "LEG",
                                                                         INPUT STRING(crapban.nrispbif, "99999999"),
                                                                         /*INPUT STRING(crapban.nrispbif, "99999999"),*/
                                                                         INPUT SUBSTRING(STRING(crapcop.nrdocnpj, 
                                                                                      "99999999999999"), 1, 8),
                                                                         INPUT STRING(tbepr_portabilidade.nrcontrato_if_origem),
                                                                         INPUT "0203",
                                                                         INPUT SUBSTRING(STRING(tbepr_portabilidade.nrcnpjbase_if_origem,
                                                                                         "99999999999999"), 1, 8),
                                                                         INPUT par_dtmvtolt,
                                                                         INPUT STRING(crawepr.vlemprst),
                                                                         INPUT STRING(crapass.nrcpfcgc),
                                                                         INPUT crapass.nmprimtl,
                                                                         INPUT aux_nrtelefo,
                                                                         INPUT "01",
                                                                         INPUT aux_txjurnom,                                                                                                   
                                                                         INPUT aux_txjurefp,
                                                                         INPUT aux_vlrtxcet,
                                                                         INPUT "09",
                                                                         INPUT "01",
                                                                         INPUT par_dtmvtolt,
                                                                         INPUT STRING(crawepr.qtpreemp),
                                                                         INPUT "N",
                                                                         INPUT aux_vlpreemp,
                                                                         INPUT aux_dtprvcto,
                                                                         INPUT aux_dtulvcto,
                                                                         INPUT aux_dsendere,
                                                                         INPUT "",
                                                                         INPUT STRING(aux_nrendere),
                                                                         INPUT aux_nmcidade,
                                                                         INPUT aux_cdufende,
                                                                         INPUT STRING(aux_nrcepend),
																		 INPUT aux_indremun,
                                                                        OUTPUT 0,
                                                                        OUTPUT "",
                                                                        OUTPUT "").
                                CLOSE STORED-PROC pc_incluir_pessoal
                                    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                                
                                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                                ASSIGN aux_idsolici  = pc_incluir_pessoal.pr_idsolici
                                                       WHEN pc_incluir_pessoal.pr_idsolici <> ?
                                       aux_des_erro  = pc_incluir_pessoal.pr_des_erro
                                                       WHEN pc_incluir_pessoal.pr_des_erro <> ?
                                       aux_dscritic  = pc_incluir_pessoal.pr_dscritic
                                                       WHEN pc_incluir_pessoal.pr_dscritic <> ?.

                                IF  aux_idsolici = 0     OR 
                                    aux_des_erro <> "OK" OR 
                                    aux_dscritic <> ""   THEN
                                    DO:
                                        ASSIGN  aux_cdcritic = 0.  
                                        IF  aux_dscritic = "" THEN
                                            ASSIGN aux_dscritic = "Nao foi possivel incluir a proposta no sistema JDCTC.".

                                        UNDO Grava, LEAVE Grava.
                                    END.
                                ELSE
                                  ASSIGN tbepr_portabilidade.dtaprov_portabilidade = par_dtmvtolt.

                            END.

                        
                    
                    END.
            END.
            
        RUN gera_log(par_cdcooper,
                     par_cdoperad, 
                     par_dtmvtolt,
                     par_nrdcont1,
                     par_nrctremp,
                     par_insitaux,
                     par_insitapv).

        RELEASE crawepr.
        ASSIGN aux_returnvl = "OK".
        LEAVE Grava.

     END. /* Grava */   
   
     IF  TEMP-TABLE tt-erro:HAS-RECORDS OR
         aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.

             IF  AVAIL tt-erro THEN
                 ASSIGN aux_dscritic = tt-erro.dscritic.
             ELSE 
                 RUN gera_erro ( INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT 1,            /** Sequencia **/
                                 INPUT aux_cdcritic,
                                 INPUT-OUTPUT aux_dscritic ).

             ASSIGN aux_returnvl = "NOK".
         END.

     IF  par_flgerlog  THEN
         DO:
             RUN proc_gerar_log ( INPUT par_cdcooper,
                                  INPUT par_cdoperad,
                                  INPUT aux_dscritic,
                                  INPUT aux_dsorigem,
                                  INPUT aux_dstransa,
                                  INPUT (IF aux_returnvl = "OK" THEN TRUE ELSE FALSE),
                                  INPUT 1,
                                  INPUT par_nmdatela,
                                  INPUT par_nrdcont1,
                                 OUTPUT aux_nrdrowid ).

             RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                      INPUT "nrctremp",
                                      INPUT par_nrctremp,
                                      INPUT par_nrctremp).

            IF  aux_returnvl = "OK" THEN
                RUN proc_gerar_log_item 
                    ( INPUT aux_nrdrowid,
                      INPUT "insitapv",
                      INPUT par_insitaux,
                      INPUT par_insitapv ).


         END.

     RETURN aux_returnvl.

END PROCEDURE. /* Grava_Dados */

/* ------------------------------------------------------------------------ */
/*                   GERA IMPRESSAO DOS DADOS DO EMPRESTIMO                 */
/* ------------------------------------------------------------------------ */
PROCEDURE Gera_Impressao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenc1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtpropos AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtaprova AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtaprfim AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_aprovad1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_aprovad2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdopeapv AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_confcmpl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_confimpr AS CHAR                           NO-UNDO.
    
    DEF INPUT-OUTPUT PARAM aux_nmarqimp AS CHAR                     NO-UNDO.
    DEF OUTPUT PARAM aux_nmarqpdf AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-cmaprv.       
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_dsagenci AS CHAR   FORMAT "x(40)"                   NO-UNDO.
    DEF VAR aux_dsaprova AS CHAR   FORMAT "x(40)"                   NO-UNDO.
    DEF VAR aux_dshisobs AS CHAR                                    NO-UNDO.
    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmendter AS CHAR                                    NO-UNDO.
    DEF VAR aux_qtregist AS INTE                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-cmaprv.
    EMPTY TEMP-TABLE tt-erro.

    FORM "PA"                      AT 1
         "Situacao"                AT 5
         "Dt.Apro."                AT 20
         "Conta"                   AT 37
         "Contrato"                AT 46
         "Nome"                    AT 55
         "Emprestado"              AT 91
         "Linha"                   AT 102
         "Prest."                  AT 108
         "Valor"                   AT 124
         "Dt.Prop."                AT 131
         "Operador"                AT 142
         "Historico Observacoes"   AT 153
         SKIP(1)
         WITH NO-LABEL NO-BOX WIDTH 234 FRAME f_titulo_compl.

    FORM SKIP(1)
         aux_dsagenci
         WITH NO-BOX NO-LABEL WIDTH 132 FRAME f_pac.

    FORM SKIP(1)
         aux_dsaprova
         SKIP(1)
         WITH NO-LABEL SIDE-LABELS NO-BOX WIDTH 132 FRAME f_situacao.

    FORM "Dt.Apro."     AT  1
         "Conta"        AT 17
         "Contrato"     AT 25
         "Nome"         AT 34
         "Emprestado"   AT 69
         "Linha"        AT 80
         "Prest."       AT 86
         "Valor"        AT 102
         "Dt.Prop."     AT 109
         "Operador"     AT 121
         SKIP(1)
         WITH NO-LABEL NO-BOX WIDTH 132 FRAME f_titulo.

    FORM tt-cmaprv.cdagenci    AT 1
         aux_dsaprova          AT 5     FORMAT "x(13)"
         tt-cmaprv.dtaprova    AT 20
         tt-cmaprv.nrdconta    AT 32
         tt-cmaprv.nrctremp    AT 44
         tt-cmaprv.nmprimtl    AT 55
         tt-cmaprv.vlemprst    AT 87
         tt-cmaprv.cdlcremp    AT 102
         tt-cmaprv.qtpreemp    AT 109
         tt-cmaprv.vlpreemp    AT 115
         tt-cmaprv.dtmvtolt    AT 131
         tt-cmaprv.cdopeapv    AT 142
         tt-cmaprv.dshisobs    AT 153
         WITH DOWN NO-LABEL NO-BOX WIDTH 234 FRAME f_rel_observ.

    FORM tt-cmaprv.dtaprova  
         tt-cmaprv.nrdconta  
         tt-cmaprv.nrctremp  
         tt-cmaprv.nmprimtl
         tt-cmaprv.vlemprst
         tt-cmaprv.cdlcremp    AT 80
         tt-cmaprv.qtpreemp    AT 87
         tt-cmaprv.vlpreemp    AT 93
         tt-cmaprv.dtmvtolt    AT 109
         tt-cmaprv.cdopeapv    AT 121
         WITH DOWN NO-LABEL NO-BOX WIDTH 132 FRAME f_rel.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK".

     Imprimir: DO ON ERROR UNDO Imprimir, LEAVE Imprimir:
         
         FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

         IF  par_confimpr = "N" OR par_idorigem = 5  THEN
             DO:
                  ASSIGN aux_nmendter = "/usr/coop/" + crapcop.dsdircop +
                                        "/rl/" + par_dsiduser.

                  UNIX SILENT VALUE("rm " + aux_nmendter + "* 2>/dev/null").

                  ASSIGN aux_nmendter = aux_nmendter + STRING(TIME)
                         aux_nmarqimp = aux_nmendter + ".ex"
                         aux_nmarqpdf = aux_nmendter + ".pdf".

                  OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 64.

                  /** Configura a impressora para 1/8" **/
                  PUT STREAM str_1 CONTROL "\022\024\033\120\0330\033x0" NULL.
            END.
         ELSE 
            OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 64.
         
         /* Gera o cabecalho do arquivo */
         { sistema/generico/includes/b1cabrelvar.i }

         IF  par_confcmpl = "S" THEN
             DO:
                 { sistema/generico/includes/b1cabrel234.i "11"  "439" }
             END.

         ELSE
             DO:
                 { sistema/generico/includes/b1cabrel132.i "11"  "439" }
             END.
         
         EMPTY TEMP-TABLE tt-cmaprv.

         RUN Busca_Dados 
           ( INPUT par_cdcooper,
             INPUT par_cdagenci,
             INPUT 0,
             INPUT par_cdoperad,
             INPUT par_nmdatela,
             INPUT 1,
             INPUT par_dtmvtolt,
             INPUT par_dtmvtopr,
             INPUT par_inproces,
             INPUT par_cddopcao,     
             INPUT par_cdagenci,
             INPUT par_nrdconta,
             INPUT par_dtpropos,
             INPUT par_dtaprova,
             INPUT par_dtaprfim,
             INPUT par_aprovad1,
             INPUT par_aprovad2,
             INPUT par_cdopeapv,
             INPUT 1,
             INPUT 999999999,
            OUTPUT aux_qtregist,
            OUTPUT TABLE tt-cmaprv,
            OUTPUT TABLE tt-erro).
         
         IF  TEMP-TABLE tt-erro:HAS-RECORDS THEN
             LEAVE Imprimir.

         IF  NOT TEMP-TABLE tt-cmaprv:HAS-RECORDS THEN
             DO: 
                ASSIGN aux_cdcritic = 263.
                LEAVE Imprimir.
             END.

         IF par_confcmpl = "S" THEN
            VIEW STREAM str_1 FRAME f_titulo_compl.

         FOR EACH tt-cmaprv BREAK BY tt-cmaprv.cdagenci
                                  BY tt-cmaprv.insitapv
                                  BY tt-cmaprv.dtaprova
                                  BY tt-cmaprv.nrdconta
                                  BY tt-cmaprv.nrctremp:
             
             IF   FIRST-OF(tt-cmaprv.cdagenci)  THEN
                  DO:
                      FIND crapage NO-LOCK WHERE 
                           crapage.cdcooper = par_cdcooper  AND
                           crapage.cdagenci = tt-cmaprv.cdagenci NO-ERROR.

                      ASSIGN aux_dsagenci = "PA: " + STRING(tt-cmaprv.cdagenci) + 
                                            "-" + crapage.nmresage.

                      IF par_confcmpl = "N" THEN
                         DISPLAY STREAM str_1 aux_dsagenci WITH FRAME f_pac.

                  END.

             IF   FIRST-OF(tt-cmaprv.insitapv)  THEN
                  DO:
                      IF par_confcmpl = "S" THEN
                         DO:                       
                           IF   tt-cmaprv.insitapv = 0  THEN
                                ASSIGN aux_dsaprova = "Nao Analisado".
                           ELSE
                           IF   tt-cmaprv.insitapv = 1  THEN
                                ASSIGN aux_dsaprova = "Aprovado".
                           ELSE
                           IF   tt-cmaprv.insitapv = 2  THEN
                                ASSIGN aux_dsaprova = "Nao Aprovado".
                           ELSE
                           IF   tt-cmaprv.insitapv = 3  THEN
                                ASSIGN aux_dsaprova = "Com Restricao".
                           ELSE
                                ASSIGN aux_dsaprova = "Refazer".

                         END.
                      ELSE
                        DO: 
                           IF   tt-cmaprv.insitapv = 0  THEN
                                ASSIGN aux_dsaprova = " => Nao Analisado".
                           ELSE
                           IF   tt-cmaprv.insitapv = 1  THEN
                                ASSIGN aux_dsaprova = " => Aprovado".
                           ELSE
                           IF   tt-cmaprv.insitapv = 2  THEN
                                ASSIGN aux_dsaprova = " => Nao Aprovado".
                           ELSE
                           IF   tt-cmaprv.insitapv = 3  THEN
                                ASSIGN aux_dsaprova = " => Com Restricao".
                           ELSE
                                ASSIGN aux_dsaprova = " => Refazer".

                           DISPLAY STREAM str_1  aux_dsaprova 
                               WITH FRAME f_situacao.

                           VIEW STREAM str_1 FRAME f_titulo.
                        END.   
                  END.


             IF   par_confcmpl = "S" THEN 
                  DO:

                      DISPLAY STREAM str_1  tt-cmaprv.cdagenci  aux_dsaprova
                                            tt-cmaprv.dtaprova  tt-cmaprv.nrdconta
                                            tt-cmaprv.nrctremp  tt-cmaprv.nmprimtl
                                            tt-cmaprv.vlemprst  tt-cmaprv.cdlcremp
                                            tt-cmaprv.qtpreemp  tt-cmaprv.vlpreemp
                                            tt-cmaprv.dtmvtolt  tt-cmaprv.cdopeapv
                                            tt-cmaprv.dshisobs     
                                            WITH FRAME f_rel_observ.

                      DOWN STREAM str_1 WITH FRAME f_rel_observ.
                  END.
             ELSE 
                  DO:
                      ASSIGN aux_dshisobs = "".

                      DISPLAY STREAM str_1  tt-cmaprv.dtaprova  tt-cmaprv.nrdconta
                                            tt-cmaprv.nrctremp  tt-cmaprv.nmprimtl
                                            tt-cmaprv.vlemprst  tt-cmaprv.cdlcremp
                                            tt-cmaprv.qtpreemp  tt-cmaprv.vlpreemp
                                            tt-cmaprv.dtmvtolt  tt-cmaprv.cdopeapv
                                            WITH FRAME f_rel.

                      DOWN STREAM str_1 WITH FRAME f_rel.
                  END.

             IF   LINE-COUNTER(str_1) > (PAGE-SIZE(str_1) - 4)  THEN
                  DO:
                      PAGE STREAM str_1.

                      IF   par_confcmpl = "S" THEN
                         DO:
                           VIEW STREAM str_1 FRAME f_cabrel234_1.
                           VIEW STREAM str_1 FRAME f_titulo_compl.
                         END.
                      ELSE
                         DO:  
                           VIEW STREAM str_1 FRAME f_cabrel132_1.
                           VIEW STREAM str_1 FRAME f_situacao.
                           VIEW STREAM str_1 FRAME f_titulo.
                         END.  
                  END.

         END.

         OUTPUT STREAM str_1 CLOSE.

         IF  par_idorigem = 5  THEN  /** Ayllos Web **/
             DO:
                 RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                     SET h-b1wgen0024.

                 IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                     DO:
                         ASSIGN aux_dscritic = "Handle invalido para BO " +
                                               "b1wgen0024.".

                     END.

                 RUN envia-arquivo-web IN h-b1wgen0024 
                     ( INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT aux_nmarqimp,
                      OUTPUT aux_nmarqpdf,
                      OUTPUT TABLE tt-erro ).

                 IF  VALID-HANDLE(h-b1wgen0024)  THEN
                     DELETE PROCEDURE h-b1wgen0024.

                 IF  RETURN-VALUE <> "OK" THEN
                     ASSIGN aux_returnvl = "NOK".
             END.
         
         ASSIGN aux_returnvl = "OK".
         LEAVE Imprimir.

     END. /* Imprimir: DO WHILE TRUE ON ENDKEY UNDO, LEAVE: */


     IF  TEMP-TABLE tt-erro:HAS-RECORDS OR
         aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
         DO:

             OUTPUT STREAM str_1 CLOSE.
             FIND FIRST tt-erro NO-LOCK NO-ERROR.

             IF  AVAIL tt-erro THEN
                 ASSIGN aux_dscritic = tt-erro.dscritic.
             ELSE 
                 RUN gera_erro ( INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT 1,            /** Sequencia **/
                                 INPUT aux_cdcritic,
                                 INPUT-OUTPUT aux_dscritic ).

             ASSIGN aux_returnvl = "NOK".
         END.

     RETURN aux_returnvl.

END PROCEDURE. /* Gera_Impressao */

/*............................ FUNCOES  INTERNAS ..........................*/

FUNCTION f_busca_complementos RETURN CHAR (INPUT par_conteudo AS CHAR):

    DEF VAR aux_contador AS INT                                     NO-UNDO.    
    DEF VAR aux_dsretorn AS CHAR                                    NO-UNDO.
    DEF VAR aux_tipohist AS CHAR                                    NO-UNDO.
    DEF VAR aux_conteudo AS CHAR                                    NO-UNDO.
    
    ASSIGN aux_dsretorn = "".

    IF NUM-ENTRIES(par_conteudo,STRING("-")) = 0 THEN RETURN "".

    /***
        Alterado conforme solicitação do Guilherme Gielow.
        Buscar a descrição que foi informada em tela. 
        Iniciar a pesquisa em ":" e terminar no primeiro "[" que encontrar
    ***/
    ASSIGN aux_dsretorn = "".
    DO aux_contador = 1 TO NUM-ENTRIES(par_conteudo,STRING(":")):
        ASSIGN aux_conteudo = ENTRY(aux_contador,par_conteudo,":").

        IF INDEX(aux_conteudo,"[") = 0 THEN
            NEXT.

        ASSIGN aux_conteudo = TRIM( SUBSTR(aux_conteudo,1,
                                           INDEX(aux_conteudo,"[") - 1)).

        IF aux_conteudo = "" THEN
            NEXT.

        IF aux_dsretorn <> "" THEN
            aux_dsretorn = aux_dsretorn + " / ".

        ASSIGN aux_dsretorn = aux_dsretorn + aux_conteudo.
    END.
    
    /* Limitar a 80 caracteres que é o máximo do relatório */
    RETURN SUBSTR(aux_dsretorn,1,80).

END. /* END FUNCTION */


/*............................ PROCEDURES INTERNAS ..........................*/
PROCEDURE paginacao:

    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    
    FOR EACH tt-cmaprv:

        ASSIGN par_qtregist = par_qtregist + 1.

       /* controles da paginação */
       IF  (par_qtregist < par_nriniseq) OR
           (par_qtregist > (par_nriniseq + par_nrregist - 1)) THEN
            DO:
                DELETE tt-cmaprv.
            END.

    END.


END PROCEDURE.

PROCEDURE verifica_selecao.
   
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtaprova AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtaprfim AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_aprovad1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_aprovad2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdopeapv AS CHAR                           NO-UNDO.

    DEF  VAR aux_controle AS LOGICAL                                NO-UNDO.

    ASSIGN aux_controle = FALSE.

    IF  (par_aprovad1 > 0  OR
        par_aprovad2 > 0) AND
        par_dtaprfim = ?  THEN
        ASSIGN par_dtaprfim = par_dtmvtolt.
    
    IF  par_dtaprova  = ?                 AND
        par_dtaprfim <> ?                 AND
        crawepr.dtaprova <= par_dtaprfim  THEN
        aux_controle = TRUE.
    ELSE
        IF  par_dtaprova = ?      OR
            par_dtaprfim = ?      AND
            crawepr.dtaprova = ?  THEN
            aux_controle = TRUE.
        ELSE
            IF  par_dtaprova <> ?                 AND
                par_dtaprfim <> ?                 AND
                crawepr.dtaprova >= par_dtaprova  AND
                crawepr.dtaprova <= par_dtaprfim  THEN
                aux_controle = TRUE.

    IF aux_controle THEN
        RUN cria_temporaria( INPUT par_cdcooper,
                             INPUT par_dtaprova,
                             INPUT par_dtaprfim,
                             INPUT par_aprovad1,
                             INPUT par_aprovad2, 
                             INPUT par_cdopeapv).

END PROCEDURE.
 


PROCEDURE cria_temporaria.

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtaprova AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtaprfim AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_aprovad1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_aprovad2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdopeapv AS CHAR                           NO-UNDO.

    DEF  VAR aux_contador AS INT                                    NO-UNDO.    
    DEF  VAR aux_nrctrliq AS CHAR                                   NO-UNDO.
	DEF  VAR aux_dsobscmt AS CHAR                                   NO-UNDO.
    DEF  VAR aux_dsaprova AS CHAR                                   NO-UNDO.
    DEF  VAR aux_nmoperad AS CHAR                                   NO-UNDO.
    DEF  VAR aux_instatus AS INTE                                   NO-UNDO.
    DEF  VAR aux_dsstatus AS CHAR                                   NO-UNDO.


    IF   crawepr.insitapr >= par_aprovad1                          AND
         crawepr.insitapr <= par_aprovad2                          AND
       ((crawepr.cdopeapr >= par_cdopeapv AND par_cdopeapv = " ")  OR
        (crawepr.cdopeapr  = par_cdopeapv))                        THEN
         DO:    
             FIND crapepr NO-LOCK WHERE
                  crapepr.cdcooper = par_cdcooper     AND
                  crapepr.nrdconta = crawepr.nrdconta AND
                  crapepr.nrctremp = crawepr.nrctremp  NO-ERROR.
             IF   AVAIL crapepr  THEN
                  DO:
                      IF   crawepr.dtaprova = ?  OR
                          (par_dtaprfim     = ?  AND
                           par_dtaprova     = ?)  THEN 
                           NEXT.
                  END.     
             
             
             /* Pega a descrição da SITUACAO ( insitapv ) 
             e nome do OPERADOR  nmoperad */
             FIND crapcop 
                 WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
             
             IF   crawepr.insitapr = 0  THEN
                  ASSIGN aux_dsaprova = "Nao Analisado".
             ELSE
             IF   crawepr.insitapr = 1  THEN
                  ASSIGN aux_dsaprova = "Aprovado".
             ELSE
             IF   crawepr.insitapr = 2  THEN
                  ASSIGN aux_dsaprova = "Nao Aprovado".
             ELSE
             IF   crawepr.insitapr = 3  THEN
                  ASSIGN aux_dsaprova = "Com Restric.".
             ELSE
             IF   crawepr.insitapr = 4  THEN
                  ASSIGN aux_dsaprova = "Refazer".
             ELSE
                  ASSIGN aux_dsaprova = "".

			 ASSIGN aux_dsobscmt = crawepr.dsobscmt.
			 RUN fontes/substitui_caracter.p (INPUT-OUTPUT aux_dsobscmt).
           
             IF   crapcop.flgcmtlc       AND
                  crawepr.insitapr > 0 THEN
                  DO:
                      /** Comite Local **/
                      IF   crawepr.cdcomite = 1 THEN
                           aux_dsaprova = aux_dsaprova + " - Local".
                      ELSE
                      IF   crawepr.cdcomite = 2 THEN
                      /** Comite Sede **/
                           aux_dsaprova = aux_dsaprova + " - Sede".
                  END.
           
             FIND crapope WHERE crapope.cdcooper = par_cdcooper AND
                                crapope.cdoperad = crawepr.cdopeapr 
                                NO-LOCK NO-ERROR.
            
             IF   AVAILABLE crapope  THEN
                  ASSIGN aux_nmoperad = crapope.nmoperad.       

             RUN retorna_parecer_credito (INPUT crawepr.cdcooper,
                                          INPUT crawepr.nrdconta,
                                          INPUT crawepr.nrctremp,
                                         OUTPUT aux_dscritic,
                                         OUTPUT aux_instatus,
                                         OUTPUT aux_dsstatus).

             CREATE tt-cmaprv. 
             ASSIGN tt-cmaprv.cdagenci = crapass.cdagenci
                    tt-cmaprv.dtmvtolt = crawepr.dtmvtolt
                    tt-cmaprv.nrdconta = crawepr.nrdconta
                    tt-cmaprv.nrctremp = crawepr.nrctremp
                    tt-cmaprv.vlemprst = crawepr.vlemprst
                    tt-cmaprv.cdlcremp = crawepr.cdlcremp
                    tt-cmaprv.cdfinemp = crawepr.cdfinemp       
                    tt-cmaprv.cdopeapv = crawepr.cdopeapr
                    tt-cmaprv.nmoperad = aux_nmoperad /*crapope.nmoperad*/
                    tt-cmaprv.insitapv = crawepr.insitapr
                    tt-cmaprv.dsaprova = aux_dsaprova
                    tt-cmaprv.dtaprova = crawepr.dtaprova
                    tt-cmaprv.hrtransa = crawepr.hraprova
                    tt-cmaprv.hrtransf = STRING(crawepr.hraprova,"HH:MM:SS")
                    tt-cmaprv.qtpreemp = crawepr.qtpreemp
                    tt-cmaprv.vlpreemp = crawepr.vlpreemp
                    tt-cmaprv.nmprimtl = crapass.nmprimtl
                    tt-cmaprv.dsobscmt = aux_dsobscmt
                    tt-cmaprv.cdcomite = crawepr.cdcomite
                    tt-cmaprv.instatus = aux_instatus
                    tt-cmaprv.dsstatus = aux_dsstatus
                    tt-cmaprv.dshisobs = 
                            f_busca_complementos(INPUT crawepr.dsobscmt).
             
             DO  aux_contador = 1 TO 10:
                 IF  crawepr.nrctrliq[aux_contador] <> 0 THEN
                     DO:
                        ASSIGN aux_nrctrliq = aux_nrctrliq + STRING(crawepr.nrctrliq[aux_contador]) + ",".
                     END.
             END.

             IF   aux_nrctrliq = "" THEN
                  tt-cmaprv.nrctrliq = "Sem liquidacoes".
             ELSE
                  tt-cmaprv.nrctrliq = SUBSTR(aux_nrctrliq,1,
                                              LENGTH(aux_nrctrliq) - 1).
         END.

END PROCEDURE.

PROCEDURE retorna_parecer_credito:

    DEF INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF INPUT  PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF INPUT  PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_instatus AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dsstatus AS CHAR                           NO-UNDO.

    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_contado2 AS INTE                                    NO-UNDO.  
    DEF VAR aux_dsvldtag AS CHAR                                    NO-UNDO.

    DEF VAR xml_req      AS LONGCHAR                                NO-UNDO.
    DEF VAR xDoc         AS HANDLE                                  NO-UNDO.  
    DEF VAR xRoot        AS HANDLE                                  NO-UNDO. 
    DEF VAR xRoot2       AS HANDLE                                  NO-UNDO. 
    DEF VAR xRoot3       AS HANDLE                                  NO-UNDO.

    DEF VAR ponteiro_xml AS MEMPTR                                  NO-UNDO.


    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
            
    RUN STORED-PROCEDURE pc_retorna_analise_ctr
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,
                                             INPUT par_nrdconta,
                                             INPUT par_nrctremp,
                                            OUTPUT "",
                                            OUTPUT 0,
                                            OUTPUT "").

    CLOSE STORED-PROC pc_retorna_analise_ctr
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN par_dscritic  = pc_retorna_analise_ctr.pr_dscritic
                          WHEN pc_retorna_analise_ctr.pr_dscritic <> ?.
    
    IF  par_dscritic  <> ""   THEN
        RETURN "NOK".
    
    ASSIGN xml_req = pc_retorna_analise_ctr.pr_retxml.  
    
    IF   xml_req = "" OR xml_req = ? THEN
         RETURN "NOK".

    CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */
    CREATE X-NODEREF  xRoot.
    CREATE X-NODEREF  xRoot2.
    CREATE X-NODEREF  xRoot3.

    SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1.
    PUT-STRING(ponteiro_xml,1) = xml_req.
    
    xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE).
    
    xDoc:GET-DOCUMENT-ELEMENT(xRoot).

    DO aux_contador = 1 TO xRoot:NUM-CHILDREN:
      
        xRoot:GET-CHILD(xRoot2,aux_contador).

      IF  xRoot2:SUBTYPE <> "ELEMENT"   THEN
          NEXT.

      IF  CAN-DO("instatus,dsstatus",xRoot2:NAME)   THEN
          DO aux_contado2 = 1 TO xRoot2:NUM-CHILDREN:  
             
              xRoot2:GET-CHILD(xRoot3,aux_contado2).
         
              ASSIGN aux_dsvldtag = xRoot3:NODE-VALUE NO-ERROR.

              IF   xRoot2:NAME = "instatus"   THEN
                   ASSIGN par_instatus = INTE(aux_dsvldtag).
              ELSE
                   ASSIGN par_dsstatus = aux_dsvldtag.

          END.

    END.

    SET-SIZE(ponteiro_xml) = 0.
    
    DELETE OBJECT xDoc.
    DELETE OBJECT xRoot.
    DELETE OBJECT xRoot2.
    DELETE OBJECT xRoot3.

    RETURN "OK".

END PROCEDURE.


PROCEDURE pi_cria_tt_obser:
 /** Procedure da FUNCTION **/

 DEF INPUT PARAM par_tipo     AS CHAR NO-UNDO.
 DEF INPUT PARAM par_seq      AS INT  NO-UNDO.
 DEF INPUT PARAM par_conteudo AS CHAR NO-UNDO.
    
    CREATE tt-complemento.
    ASSIGN tt-complemento.dstipcpl = par_tipo
           tt-complemento.cdsequen = par_seq
           tt-complemento.dscontdo = par_conteudo.

END PROCEDURE.


PROCEDURE gera_log:
    
    DEF     INPUT PARAM par_cdcooper    AS INTE                     NO-UNDO.
    DEF     INPUT PARAM par_cdoperad    AS CHAR                     NO-UNDO.
    DEF     INPUT PARAM par_dtmvtolt    AS DATE                     NO-UNDO.
    DEF     INPUT PARAM log_nrdconta    AS INT                      NO-UNDO.
    DEF     INPUT PARAM log_nrctremp    AS INT                      NO-UNDO.
    DEF     INPUT PARAM log_insitant    AS INT                      NO-UNDO.
    DEF     INPUT PARAM log_insitatu    AS INT                      NO-UNDO.

    FOR FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK: END.

    UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999")        + 
                      " "     + STRING(TIME,"HH:MM:SS")   + "' --> '"    +
                      "Operador "  + par_cdoperad         + " - "        +
                      "alterou a conta " + STRING(log_nrdconta,"zzzz,zzz,9") +
                      ", " + STRING(log_nrctremp,"zz,zzz,zz9") +
                      " da situacao " + STRING(log_insitant,"9") + " para " +
                      STRING(log_insitatu,"9") + 
                      " >> /usr/coop/" + TRIM(crapcop.dsdircop) + 
                      "/log/cmaprv.log").         
    
END.
   
PROCEDURE cancela_portabilidade.

    DEF INPUT   PARAM par_cdcooper LIKE crapcop.cdcooper      NO-UNDO.
    DEF INPUT   PARAM par_idservic AS INTE                    NO-UNDO.
    DEF INPUT   PARAM par_cdlegado AS CHAR                    NO-UNDO.
    DEF INPUT   PARAM par_nrispbif AS DECI                    NO-UNDO.
    DEF INPUT   PARAM par_inparadm AS DECI                    NO-UNDO.
    DEF INPUT   PARAM par_cnpjifcr AS DECI                    NO-UNDO.
    DEF INPUT   PARAM par_nuportld AS CHAR                    NO-UNDO.
    DEF OUTPUT  PARAM par_flgrespo AS INTE                    NO-UNDO.
    DEF OUTPUT  PARAM par_des_erro AS CHAR                    NO-UNDO.
    DEF OUTPUT  PARAM par_dscritic AS CHAR                    NO-UNDO.  

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_cancelar_portabilidade
        aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper,
                          INPUT par_idservic,
                          INPUT par_cdlegado,               /* Codigo Legado */
                          INPUT par_nrispbif,               /* Numero ISPB IF */
                          INPUT par_inparadm,               /* Identificador Participante Administrado */
                          INPUT par_cnpjifcr,               /* CNPJ Base IF Credora Original Contrato */
                          INPUT par_nuportld,               /* Numero Portabilidade CTC */
                          INPUT "002",                      /* Motivo Cancelamento Portabilidade */
                         OUTPUT 0,                          /* 1 - Se o registro na JDCTC for atualizado com sucesso */
                         OUTPUT "",                         /* Indicador erro OK/NOK */
                         OUTPUT "").                        /* Descricao do erro */
    
    CLOSE STORED-PROC pc_cancelar_portabilidade
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN par_flgrespo = pc_cancelar_portabilidade.pr_flgrespo
                          WHEN pc_cancelar_portabilidade.pr_flgrespo <> ?                  
           par_des_erro = pc_cancelar_portabilidade.pr_des_erro
                          WHEN pc_cancelar_portabilidade.pr_des_erro <> ?
           par_dscritic = pc_cancelar_portabilidade.pr_dscritic 
                          WHEN pc_cancelar_portabilidade.pr_dscritic <> ?.
    
END PROCEDURE.

PROCEDURE consulta_situacao:

    DEF INPUT  PARAM par_cdcooper LIKE crapcop.cdcooper                              NO-UNDO.
    DEF INPUT  PARAM par_nrispbif LIKE crapban.nrispbif                              NO-UNDO.    
    DEF INPUT  PARAM par_nrdocnpj AS CHAR                                            NO-UNDO.
    DEF INPUT  PARAM par_cnpjbase AS CHAR                                            NO-UNDO.
    DEF INPUT  PARAM par_nrportab LIKE tbepr_portabilidade.nrunico_portabilidade     NO-UNDO.
    DEF INPUT  PARAM par_nrctrifo LIKE tbepr_portabilidade.nrcontrato_if_origem      NO-UNDO.
    DEF INPUT  PARAM par_cdmodali AS CHAR                                            NO-UNDO.
    DEF INPUT  PARAM par_nrcpfcgc LIKE crapass.nrcpfcgc                              NO-UNDO.
    DEF OUTPUT PARAM par_des_erro AS CHAR                                            NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                                            NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-dados-portabilidade.

    /* Variaveis utilizadas para receber clob da rotina no oracle */
    DEF VAR xDoc          AS HANDLE   NO-UNDO.   
    DEF VAR xRoot         AS HANDLE   NO-UNDO.  
    DEF VAR xRoot2        AS HANDLE   NO-UNDO.  
    DEF VAR xField        AS HANDLE   NO-UNDO. 
    DEF VAR xText         AS HANDLE   NO-UNDO. 
    DEF VAR aux_cont_raiz AS INTEGER  NO-UNDO. 
    DEF VAR aux_cont      AS INTEGER  NO-UNDO. 
    DEF VAR ponteiro_xml  AS MEMPTR   NO-UNDO. 
    DEF VAR xml_req       AS LONGCHAR NO-UNDO.


    /******** CONSULTA SITUACAO DE PORTABILIDADE NA JDCTC *********/    
    
    /* Inicializando objetos para leitura do XML */ 
    CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
    CREATE X-NODEREF  xRoot.   /* Vai conter a tag raiz em diante */ 
    CREATE X-NODEREF  xRoot2.   
    CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
    CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
    
    /* Efetuar a chamada a rotina Oracle */
    RUN STORED-PROCEDURE pc_consulta_situacao_car
    aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper         /* Código da Cooperativa*/
                                        ,INPUT 1                    /* Proponente */
                                        ,INPUT "LEG"                /* Codigo Legado */
                                        ,INPUT par_nrispbif         /* Numero ISPB IF (085)                    */
                                        ,INPUT DECI(par_nrdocnpj)   /* Identificador Participante Administrado */
                                        ,INPUT DECI(par_cnpjbase)   /* CNPJ Base IF Credora Original Contrato  */
                                        ,INPUT par_nrportab         /* Número único da portabilidade na CTC    */
                                        ,INPUT par_nrctrifo         /* Código Contrato Original                */
                                        ,INPUT par_cdmodali         /* Tipo Contrato                           */
                                        ,INPUT "F"                  /* Tipo Cliente - Fixo 'F'                 */
                                        ,INPUT par_nrcpfcgc         /* CNPJ CPF Cliente                        */
                                        ,OUTPUT ?                   /* XML com dados da portabilidade*/
                                        ,OUTPUT ""                  /* Indicador erro OK/NOK */
                                        ,OUTPUT "").                /* Descrição da crítica */

    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_consulta_situacao_car
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

    /* Busca possíveis erros */ 
    ASSIGN par_des_erro = ""
           par_dscritic = ""
           par_des_erro = pc_consulta_situacao_car.pr_des_erro 
                          WHEN pc_consulta_situacao_car.pr_des_erro <> ?
           par_dscritic = pc_consulta_situacao_car.pr_dscritic 
                          WHEN pc_consulta_situacao_car.pr_dscritic <> ?.

    /* Buscar o XML na tabela de retorno da procedure Progress */ 
    ASSIGN xml_req = pc_consulta_situacao_car.pr_clobxmlc.

    /* Efetuar a leitura do XML*/ 
    SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
    PUT-STRING(ponteiro_xml,1) = xml_req. 
     
    IF ponteiro_xml <> ? THEN
       DO:
           xDoc:LOAD("MEMPTR",ponteiro_xml, FALSE). 
           xDoc:GET-DOCUMENT-ELEMENT(xRoot).
           
           DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 
           
               xRoot:GET-CHILD(xRoot2,aux_cont_raiz).
           
               IF xRoot2:SUBTYPE <> "ELEMENT"   THEN 
                 NEXT.            

               IF xRoot2:NUM-CHILDREN > 0 THEN
                  CREATE tt-dados-portabilidade.

               DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
               
                   xRoot2:GET-CHILD(xField,aux_cont).
                       
                   IF xField:SUBTYPE <> "ELEMENT" THEN 
                       NEXT. 
                   
                   xField:GET-CHILD(xText,1).            

                   ASSIGN tt-dados-portabilidade.ispbif               = DECI(xText:NODE-VALUE) WHEN xField:NAME = "ispbif"
                          tt-dados-portabilidade.identdpartadmdo      = DECI(xText:NODE-VALUE) WHEN xField:NAME = "identdpartadmdo"
                          tt-dados-portabilidade.cnpjbase_iforcontrto = DECI(xText:NODE-VALUE) WHEN xField:NAME = "cnpjbase_iforcontrto"
                          tt-dados-portabilidade.nuportlddctc         = xText:NODE-VALUE WHEN xField:NAME = "nuportlddctc"
                          tt-dados-portabilidade.codcontrtoor         = xText:NODE-VALUE WHEN xField:NAME = "codcontrtoor"
                          tt-dados-portabilidade.tpcontrto            = xText:NODE-VALUE WHEN xField:NAME = "tpcontrto"
                          tt-dados-portabilidade.tpcli                = xText:NODE-VALUE WHEN xField:NAME = "tpcli"
                          tt-dados-portabilidade.cnpj_cpfcli          = DECI(xText:NODE-VALUE) WHEN xField:NAME = "cnpj_cpfcli"
                          tt-dados-portabilidade.stportabilidade      = xText:NODE-VALUE WHEN xField:NAME = "stportabilidade".
               END.            

           END.                
    
      END.

    SET-SIZE(ponteiro_xml) = 0. 
 
    DELETE OBJECT xDoc. 
    DELETE OBJECT xRoot. 
    DELETE OBJECT xRoot2. 
    DELETE OBJECT xField. 
    DELETE OBJECT xText.

    /*******FIM CONSULTA SITUACAO DE PORTABILIDADE NA JDCTC *********/    
END PROCEDURE.
