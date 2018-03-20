/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0077.p                  
    Autor(a): Jose Luis Marchezoni, Gabriel Capoia (DB1)
    Data    : Setembro/2010                      Ultima atualizacao: 19/04/2017
  
    Dados referentes ao programa:
  
    Objetivo  : Gerencia replicacao de dados do entre titular de contas 'pai'
                e conta 'filha'
    
    Alteracoes: 28/04/2011 - Alterado campo tempo resid. para dtinires devido 
                             a inserção do campo inicio de residencia na
                             rotina ENDERECO , tela CONTAS. (André - DB1)
                             
                01/07/2011 - Novos parametros na chamada da validar-endereco 
                             na b1wgen0038 (Henrique)
                             
                16/04/2012 - Ajuste referente ao projeto GP - Socios Menores
                            (Adriano).      
                            
                01/10/2012 - Incluido o FIELD nrcpfcgc no FOR FIRST crabass 
                             (Adriano).
                             
                14/10/2013 - Adicionado parameto aux_cotcance nas chamadas
                             da procedure Grava_Dados(b1wgen0075). (Fabricio)
                             
                09/07/2014 - Correcao na rotina de replicacao de telefones. 
                             Para nao replicar na exclusao. 
                             S170059 (Carlos Rafael Tanholi)
                             
                24/07/2015 - Reformulacao cadastral (Gabriel-RKAM).      
                
                12/08/2015 - Projeto Reformulacao cadastral
                             Eliminado o campo nmdsecao (Tiago Castro - RKAM).    
                             
                08/01/2016 - #350828 Criacao da tela PEP (Carlos) 
                
                22/01/2016 - Melhoria 147 - Adicionar Campos e Aprovacao de
				             Transferencia entre PAs (Heitor - RKAM)

				25/02/2016 - Adicionado validacao na rotina Revisao_Cadastral 
                             para que gere mensagem apenas para contas que nao
                             tenham revisao cadastral a um ano conforme solicitado
                             no chamado 393002 (Kelvin).    
                             
                19/04/2017 - Alteraçao DSNACION pelo campo CDNACION.
                             PRJ339 - CRM (Odirlei-AMcom)      
                             
                14/03/2018 - Substituida validacao "cdtipcta = (6, 7, 17, 18)" 
                             pela modalidade do tipo de conta = 3. PRJ339 (Lombardi).
                             
.............................................................................*/


/*............................... DEFINICOES ................................*/

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/b1wgen0038tt.i }
{ sistema/generico/includes/b1wgen0047tt.i }
{ sistema/generico/includes/b1wgen0054tt.i }
{ sistema/generico/includes/b1wgen0056tt.i }
{ sistema/generico/includes/b1wgen0057tt.i }
{ sistema/generico/includes/b1wgen0070tt.i }
{ sistema/generico/includes/b1wgen0071tt.i }
{ sistema/generico/includes/b1wgen0072tt.i }
{ sistema/generico/includes/b1wgen0075tt.i }
{ sistema/generico/includes/var_oracle.i }

DEF VAR aux_tpatlcad AS INTE                                        NO-UNDO.
DEF VAR aux_msgatcad AS CHAR                                        NO-UNDO.
DEF VAR aux_msgalert AS CHAR                                        NO-UNDO.
DEF VAR aux_chavealt AS CHAR                                        NO-UNDO.

DEF VAR aux_cotcance AS CHAR                                        NO-UNDO.

DEFINE TEMP-TABLE tt-aux-crapcrl LIKE tt-crapcrl.

DEFINE TEMP-TABLE tta-crapbem LIKE tt-crapbem.
DEFINE TEMP-TABLE tta-telefone-cooperado LIKE tt-telefone-cooperado.
DEFINE TEMP-TABLE tta-email-cooperado LIKE tt-email-cooperado.
DEFINE TEMP-TABLE tta-dependente LIKE tt-dependente.
DEFINE TEMP-TABLE tta-crapcrl LIKE tt-crapcrl.

/* Pre-Processador para controle de erros 'Progress' */
&SCOPED-DEFINE GET-MSG ERROR-STATUS:GET-MESSAGE(1)

FUNCTION RetornoErro RETURNS LOGICAL 
    ( INPUT-OUTPUT par_dscritic AS CHARACTER ) FORWARD.

FUNCTION RetornaErroReplica RETURNS LOGICAL 
    ( INPUT        par_nrdconta AS INTEGER ,
      INPUT        par_auxmensg AS CHARACTER ,
      INPUT-OUTPUT par_dscritic AS CHARACTER ) FORWARD.

/*........................... PROCEDURES EXTERNAS ...........................*/

/* ------------------------------------------------------------------------ */
/*        VERIFICA SE O COOPERADO E PRIMEIRO TITULAR EM OUTRA CONTA         */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Conta:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_nrctattl AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_msgconta AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_dtaltera AS DATE                                    NO-UNDO.
    DEF VAR aux_cdmodali AS INTE                                    NO-UNDO.
    DEF VAR aux_des_erro AS CHAR                                    NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.

    DEF BUFFER crabass FOR crapass.
    DEF BUFFER crabttl FOR crapttl.

    Conta: DO ON ERROR UNDO Conta, LEAVE Conta:

        /** Busca conta ativa mais atual do cooperado **/ 
        ASSIGN aux_dtaltera = 01/01/0001.

        FOR EACH crabttl FIELDS(cdcooper nrdconta)
                         WHERE crabttl.cdcooper  = par_cdcooper AND
                               crabttl.nrcpfcgc  = par_nrcpfcgc AND
                               crabttl.idseqttl  = 1            
                               NO-LOCK, 

           FIRST crabass FIELDS(cdcooper nrdconta cdtipcta inpessoa)
                         WHERE crabass.cdcooper = crabttl.cdcooper AND
                               crabass.nrdconta = crabttl.nrdconta AND
                               crabass.dtdemiss = ?                
                               NO-LOCK:
           
            { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
            
            RUN STORED-PROCEDURE pc_busca_modalidade_tipo
            aux_handproc = PROC-HANDLE NO-ERROR (INPUT crabass.inpessoa, /* Tipo de pessoa */
                                                 INPUT crabass.cdtipcta, /* Tipo de conta */
                                                OUTPUT 0,                /* Modalidade */
                                                OUTPUT "",               /* Flag Erro */
                                                OUTPUT "").              /* Descriçao da crítica */
            
            CLOSE STORED-PROC pc_busca_modalidade_tipo
                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
            
            { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
            
            ASSIGN aux_cdmodali = 0
                   aux_des_erro = ""
                   aux_dscritic = ""
                   aux_cdmodali = pc_busca_modalidade_tipo.pr_cdmodalidade_tipo 
                                  WHEN pc_busca_modalidade_tipo.pr_cdmodalidade_tipo <> ?
                   aux_des_erro = pc_busca_modalidade_tipo.pr_des_erro 
                                  WHEN pc_busca_modalidade_tipo.pr_des_erro <> ?
                   aux_dscritic = pc_busca_modalidade_tipo.pr_dscritic
                                  WHEN pc_busca_modalidade_tipo.pr_dscritic <> ?.
            
            IF aux_des_erro = "NOK"  THEN
                DO:
                   ASSIGN par_dscritic = aux_dscritic.
                   LEAVE Conta.
                END.
            
            /** Ignora conta aplicacao **/
            IF  aux_cdmodali = 3 THEN
                NEXT.

            FOR LAST crapalt FIELDS(nrdconta dtaltera)
                             WHERE crapalt.cdcooper = crabass.cdcooper AND
                                   crapalt.nrdconta = crabass.nrdconta 
                                   USE-INDEX crapalt1 NO-LOCK:
            END.

            IF  AVAILABLE crapalt THEN
                DO:   
                   IF  crapalt.dtaltera > aux_dtaltera THEN
                       ASSIGN 
                           par_nrctattl = crapalt.nrdconta
                           aux_dtaltera = crapalt.dtaltera.
                END.
            ELSE
                IF  par_nrctattl = 0 THEN
                    ASSIGN par_nrctattl = crabass.nrdconta.
        END.   
        
        FOR FIRST crabttl FIELDS(nrdconta)
                          WHERE par_idseqttl     <> 1           AND 
                                crabttl.cdcooper = par_cdcooper AND
                                crabttl.nrcpfcgc = par_nrcpfcgc AND
                                crabttl.idseqttl = 1            AND
                                crabttl.nrdconta = par_nrctattl 
                                NO-LOCK:

            ASSIGN par_msgconta = "Dados deste titular somente podem ser " +
                                  "alterados na conta: " + 
                                  TRIM(STRING(crabttl.nrdconta,"zzzz,zzz,9")).

        END.

        LEAVE Conta.

    END.

    RETURN "OK".

END PROCEDURE. /* Busca_Conta */

/* ------------------------------------------------------------------------ */
/*    VERIFICA A NECESSIDADE DE REVISAO CADASTRAL PARA PRIMEIRO TITULAR     */
/* ------------------------------------------------------------------------ */
PROCEDURE Revisao_Cadastral:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_msgalert AS CHAR                           NO-UNDO.
    
    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR aux_dtmvtolt AS DATE                                    NO-UNDO. 
    DEF VAR aux_qtrevdia AS INTE                                    NO-UNDO. 
   
    DEF BUFFER crabass FOR crapass.

    ASSIGN aux_returnvl = "OK".
    
    FOR FIRST crabass FIELDS(cdtipcta)
                      WHERE crabass.cdcooper = par_cdcooper AND
                            crabass.nrdconta = par_nrdconta 
                            NO-LOCK:

        /** Ignora conta aplicacao **/
        IF  CAN-DO("6,7,17,18",STRING(crabass.cdtipcta))  THEN
            RETURN aux_returnvl.

    END.
    
    FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    
    IF AVAILABLE(crapdat) THEN
       ASSIGN aux_dtmvtolt = crapdat.dtmvtolt.
    
    /*Buscando a quantidade de dias parametrizado para criticar a revisao cadastral*/
    FIND FIRST craptab WHERE craptab.cdcooper = par_cdcooper AND
                             craptab.nmsistem = 'CRED'       AND 
                             craptab.tptabela = 'GENERI'     AND 
                             craptab.cdempres = par_cdcooper AND
                             craptab.cdacesso = 'ATUALIZCAD' AND 
                             craptab.tpregist = 0
                             NO-LOCK NO-ERROR.
    
    IF AVAILABLE(craptab) THEN 
       ASSIGN aux_qtrevdia = INTE(craptab.dstextab).
    
    FOR EACH crabass FIELDS(nrdconta cdtipcta)
                     WHERE crabass.cdcooper  = par_cdcooper AND
                           crabass.nrcpfcgc  = par_nrcpfcgc AND
                           crabass.dtdemiss  = ?            AND
                           crabass.nrdconta <> par_nrdconta 
                           NO-LOCK:
                           
        /** Ignora conta aplicacao **/
        IF  CAN-DO("6,7,17,18",STRING(crabass.cdtipcta))  THEN
            NEXT.
        
        /*Valida se teve revisao cadastral cadastrao dentro do periodo parametrizado na craptab*/
        FIND FIRST crapalt WHERE crapalt.cdcooper = crabass.cdcooper                                      AND 
                                 crapalt.nrdconta = crabass.nrdconta                                      AND 
                                 crapalt.dtaltera >= ADD-INTERVAL(aux_dtmvtolt, aux_qtrevdia * -1, "DAY") AND 
                                 CAN-DO(crapalt.dsaltera, "revisao cadastral") NO-LOCK NO-ERROR.
        
        IF NOT AVAILABLE(crapalt) THEN
           DO:
               IF  par_msgalert = "" THEN
                   ASSIGN par_msgalert = "Efetuar revisao cadastral na(s) "
                                       + "conta(s) ".

               ASSIGN par_msgalert = par_msgalert + TRIM(STRING
                                     (crabass.nrdconta,"zzzz,zzz,9")) + 
                                     ", ".

           END.
     END.
       
    IF  par_msgalert <> "" THEN
        ASSIGN par_msgalert = par_msgalert + "onde o cooperado e 1o. titular.".

    RETURN aux_returnvl.

END PROCEDURE. /*Revisao_Cadastral*/

/* ------------------------------------------------------------------------ */
/*   DADOS EM CONTA FILHA NA INCLUSAO A PARTIR DA TELA IDENTIFICACAO        */
/* ------------------------------------------------------------------------ */
PROCEDURE Recebe_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                  NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                  NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                  NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                  NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                  NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                  NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                  NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                  NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                  NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                  NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGICAL               NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                  NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                  NO-UNDO.
    
    DEF VAR aux_nrctattl AS INTE                           NO-UNDO.
    DEF VAR aux_msgrvcad AS CHAR                           NO-UNDO.
    DEF VAR aux_msgconta AS CHAR                           NO-UNDO.
    DEF VAR aux_msgalert AS CHAR                           NO-UNDO.
    DEF VAR aux_tpatlcad AS CHAR                           NO-UNDO.
    DEF VAR aux_msgatcad AS CHAR                           NO-UNDO.
    DEF VAR aux_msgrecad AS CHAR                           NO-UNDO.
    DEF VAR aux_chavealt AS CHAR                           NO-UNDO.
    DEF VAR aux_menorida AS CHAR                           NO-UNDO.
    DEF VAR aux_inpessoa AS CHAR                           NO-UNDO.
    DEF VAR aux_nrdrowid AS ROWID                          NO-UNDO.
    
    DEF  VAR aux_nrdctato AS DEC                           NO-UNDO.
    DEF  VAR aux_nrcpfcto AS DEC                           NO-UNDO.
    DEF  VAR aux_nmdavali AS CHAR                          NO-UNDO.
    DEF  VAR aux_tpdocava AS CHAR                          NO-UNDO.
    DEF  VAR aux_nrdocava AS CHAR                          NO-UNDO.
    DEF  VAR aux_cdoeddoc AS CHAR                          NO-UNDO.
    DEF  VAR aux_cdufddoc AS CHAR                          NO-UNDO.
    DEF  VAR aux_dtemddoc AS DATE                          NO-UNDO.
    DEF  VAR aux_dtnascto AS DATE                          NO-UNDO.
    DEF  VAR aux_cdsexcto AS INTE                          NO-UNDO.
    DEF  VAR aux_cdestcvl AS INTE                          NO-UNDO.
    DEF  VAR aux_cdnacion AS INTE                          NO-UNDO.
    DEF  VAR aux_dsnatura AS CHAR                          NO-UNDO.
    DEF  VAR aux_nrcepend AS INTE                          NO-UNDO.
    DEF  VAR aux_dsendere AS CHAR                          NO-UNDO.
    DEF  VAR aux_nmbairro AS CHAR                          NO-UNDO.
    DEF  VAR aux_nmcidade AS CHAR                          NO-UNDO.
    DEF  VAR aux_nrendere AS INTE                          NO-UNDO.
    DEF  VAR aux_cdufende AS CHAR                          NO-UNDO.
    DEF  VAR aux_complend AS CHAR                          NO-UNDO.
    DEF  VAR aux_nrcxapst AS INTE                          NO-UNDO.
    DEF  VAR aux_nmmaecto AS CHAR                          NO-UNDO.
    DEF  VAR aux_nmpaicto AS CHAR                          NO-UNDO.
    DEF  VAR aux_cpfprocu AS DEC                           NO-UNDO.
    DEF  VAR aux_cdrlcrsp AS INTE                          NO-UNDO.
    DEF  VAR aux_nmrotina AS CHAR                          NO-UNDO.

    DEF VAR h-b1wgen0038 AS HANDLE                         NO-UNDO.
    DEF VAR h-b1wgen0047 AS HANDLE                         NO-UNDO.
    DEF VAR h-b1wgen0054 AS HANDLE                         NO-UNDO.
    DEF VAR h-b1wgen0056 AS HANDLE                         NO-UNDO.
    DEF VAR h-b1wgen0057 AS HANDLE                         NO-UNDO.
    DEF VAR h-b1wgen0070 AS HANDLE                         NO-UNDO.
    DEF VAR h-b1wgen0071 AS HANDLE                         NO-UNDO.
    DEF VAR h-b1wgen0072 AS HANDLE                         NO-UNDO.
    DEF VAR h-b1wgen0075 AS HANDLE                         NO-UNDO.
    
    /* Buscar a conta onde o cooperado e primeiro */
    RUN Busca_Conta ( INPUT par_cdcooper,
                      INPUT par_nrdconta,
                      INPUT par_nrcpfcgc,
                      INPUT par_idseqttl,
                      OUTPUT aux_nrctattl,
                      OUTPUT aux_msgconta,
                      OUTPUT par_cdcritic,
                      OUTPUT par_dscritic ) NO-ERROR.
    
    IF  aux_nrctattl = 0  THEN
        RETURN "OK".
    
    REPLICA: DO ON ERROR UNDO REPLICA, LEAVE REPLICA:
        
        /****************** FILIACAO ******************/
        EMPTY TEMP-TABLE tt-erro.

        IF  NOT VALID-HANDLE(h-b1wgen0054)  THEN
            RUN sistema/generico/procedures/b1wgen0054.p 
                PERSISTENT SET h-b1wgen0054.

        RUN Busca_Dados IN h-b1wgen0054 
            ( INPUT par_cdcooper, 
              INPUT par_cdagenci,            
              INPUT par_nrdcaixa,            
              INPUT par_cdoperad, 
              INPUT par_nmdatela, 
              INPUT par_idorigem,            
              INPUT aux_nrctattl, 
              INPUT 1,/*idseqttl*/
              INPUT NO, 
             OUTPUT aux_msgconta,
             OUTPUT TABLE tt-filiacao,
             OUTPUT TABLE tt-erro).
        
        FIND FIRST tt-filiacao NO-LOCK NO-ERROR.

        IF  AVAILABLE tt-filiacao THEN
            DO:
               RUN Grava_Dados IN h-b1wgen0054 
                   ( INPUT par_cdcooper, 
                     INPUT par_cdagenci,            
                     INPUT par_nrdcaixa,            
                     INPUT par_cdoperad, 
                     INPUT par_nmdatela, 
                     INPUT par_idorigem,            
                     INPUT par_nrdconta, 
                     INPUT par_idseqttl, 
                     INPUT par_flgerlog,
                     INPUT tt-filiacao.nmmaettl,
                     INPUT tt-filiacao.nmpaittl,
                     INPUT "A",/*cddopcao*/
                     INPUT par_dtmvtolt,
                    OUTPUT aux_msgalert,
                    OUTPUT aux_tpatlcad,
                    OUTPUT aux_msgatcad,
                    OUTPUT aux_chavealt,
                    OUTPUT TABLE tt-erro ).

               IF  RETURN-VALUE <> "OK" THEN
                   UNDO REPLICA, LEAVE REPLICA.
            END.

        IF  VALID-HANDLE(h-b1wgen0054) THEN
            DELETE OBJECT h-b1wgen0054.
        
        /**************** DEPENDENTES *****************/
        EMPTY TEMP-TABLE tt-erro.

        IF  NOT VALID-HANDLE(h-b1wgen0047)  THEN
            RUN sistema/generico/procedures/b1wgen0047.p 
                PERSISTENT SET h-b1wgen0047.

        RUN obtem-dependentes IN h-b1wgen0047 
            ( INPUT par_cdcooper, 
              INPUT par_cdagenci,            
              INPUT par_nrdcaixa,            
              INPUT par_cdoperad, 
              INPUT par_nmdatela, 
              INPUT par_idorigem,            
              INPUT aux_nrctattl, 
              INPUT 1,/*idseqttl*/ 
              INPUT NO,
             OUTPUT aux_msgconta,
             OUTPUT TABLE tt-dependente ).
        
        FOR EACH tt-dependente NO-LOCK:

            RUN gerenciar-dependente IN h-b1wgen0047 
                (INPUT par_cdcooper,
                 INPUT par_cdagenci,
                 INPUT par_nrdcaixa,
                 INPUT par_cdoperad,
                 INPUT par_nmdatela,
                 INPUT par_idorigem,
                 INPUT par_nrdconta,
                 INPUT par_idseqttl,
                 INPUT par_dtmvtolt,
                 INPUT "I",/*cddopcao*/
                 INPUT tt-dependente.nrdrowid,
                 INPUT tt-dependente.nmdepend,
                 INPUT tt-dependente.dtnascto,
                 INPUT tt-dependente.cdtipdep,
                 INPUT par_flgerlog,
                OUTPUT aux_tpatlcad,
                OUTPUT aux_msgatcad,
                OUTPUT aux_chavealt,
                OUTPUT aux_msgrvcad,
                OUTPUT TABLE tt-erro ).

            IF  RETURN-VALUE <> "OK" THEN
                UNDO REPLICA, LEAVE REPLICA.
        END.

        IF  VALID-HANDLE(h-b1wgen0047) THEN
            DELETE OBJECT h-b1wgen0047.
        
        /******************** BENS ********************/
        EMPTY TEMP-TABLE tt-erro.

        IF  NOT VALID-HANDLE(h-b1wgen0056)  THEN
            RUN sistema/generico/procedures/b1wgen0056.p 
                PERSISTENT SET h-b1wgen0056.

        RUN Busca-Dados IN h-b1wgen0056 
           ( INPUT par_cdcooper,
             INPUT par_cdagenci,
             INPUT par_nrdcaixa,
             INPUT par_cdoperad,
             INPUT aux_nrctattl,
             INPUT par_idorigem,
             INPUT par_nmdatela,
             INPUT 1,  /*idseqttl*/
             INPUT NO,
             INPUT 0,  /*idseqbem*/
             INPUT "C",/*cddopcao*/
             INPUT ?,  /*nrdrowid*/
            OUTPUT aux_msgconta,
            OUTPUT TABLE tt-crapbem,
            OUTPUT TABLE tt-erro ).
        
        FOR EACH tt-crapbem NO-LOCK:

            IF  VALID-HANDLE(h-b1wgen0056) THEN
                DELETE OBJECT h-b1wgen0056.

            IF  NOT VALID-HANDLE(h-b1wgen0056)  THEN
                RUN sistema/generico/procedures/b1wgen0056.p 
                    PERSISTENT SET h-b1wgen0056.
            
            RUN inclui-registro IN h-b1wgen0056
                ( INPUT par_cdcooper,
                  INPUT par_cdagenci,
                  INPUT par_nrdcaixa,
                  INPUT par_nrdconta,
                  INPUT par_idseqttl,
                  INPUT par_cdoperad,
                  INPUT par_nmdatela,
                  INPUT par_idorigem,
                  INPUT par_flgerlog,
                  INPUT tt-crapbem.dsrelbem,
                  INPUT ?,  /*nrdrowid*/
                  INPUT par_dtmvtolt,
                  INPUT "I",/*cddopcao*/
                  INPUT tt-crapbem.persemon,
                  INPUT tt-crapbem.qtprebem,
                  INPUT tt-crapbem.vlprebem,
                  INPUT tt-crapbem.vlrdobem,
                 OUTPUT aux_msgalert,
                 OUTPUT aux_tpatlcad,
                 OUTPUT aux_msgatcad,
                 OUTPUT aux_chavealt,
                 OUTPUT aux_msgrvcad,
                 OUTPUT TABLE tt-erro ).

            IF  RETURN-VALUE <> "OK" THEN
                UNDO REPLICA, LEAVE REPLICA.
        END.

        IF  VALID-HANDLE(h-b1wgen0056) THEN
            DELETE OBJECT h-b1wgen0056.
        
        /***************** CONJUGE *********************/
        EMPTY TEMP-TABLE tt-erro.

        IF  NOT VALID-HANDLE(h-b1wgen0057)  THEN
            RUN sistema/generico/procedures/b1wgen0057.p 
                PERSISTENT SET h-b1wgen0057.
        
        RUN Busca_Dados IN h-b1wgen0057
           ( INPUT par_cdcooper,
             INPUT par_cdagenci,
             INPUT par_nrdcaixa,
             INPUT par_cdoperad,
             INPUT par_nmdatela,
             INPUT par_idorigem,
             INPUT aux_nrctattl,
             INPUT 1,  /*idseqttl*/
             INPUT NO,
             INPUT "C",/*cddopcao*/
             INPUT ?,  /*nrdrowid*/
             INPUT 0,  /*nrctacje*/
             INPUT 0,  /*nrcpfcje*/
            OUTPUT aux_msgconta,
            OUTPUT TABLE tt-crapcje,
            OUTPUT TABLE tt-erro).
        
        FIND FIRST tt-crapcje NO-LOCK NO-ERROR.

        IF  AVAILABLE tt-crapcje THEN
            DO:
               RUN Grava_Dados IN h-b1wgen0057
                   ( INPUT par_cdcooper,
                     INPUT par_cdagenci,
                     INPUT par_nrdcaixa,
                     INPUT par_cdoperad,
                     INPUT par_nmdatela,
                     INPUT par_idorigem,
                     INPUT par_nrdconta,
                     INPUT par_idseqttl,
                     INPUT par_flgerlog,
                     INPUT tt-crapcje.nrctacje,  
                     INPUT tt-crapcje.nrcpfcjg,  
                     INPUT tt-crapcje.nmconjug,  
                     INPUT tt-crapcje.dtnasccj,  
                     INPUT tt-crapcje.tpdoccje,  
                     INPUT tt-crapcje.nrdoccje,  
                     INPUT tt-crapcje.cdoedcje,  
                     INPUT tt-crapcje.cdufdcje,  
                     INPUT tt-crapcje.dtemdcje,  
                     INPUT tt-crapcje.grescola,  
                     INPUT tt-crapcje.cdfrmttl,  
                     INPUT tt-crapcje.cdnatopc,  
                     INPUT tt-crapcje.cdocpcje,  
                     INPUT tt-crapcje.tpcttrab,  
                     INPUT tt-crapcje.nmextemp,  
                     INPUT tt-crapcje.nrdocnpj,  
                     INPUT tt-crapcje.dsproftl,  
                     INPUT tt-crapcje.cdnvlcgo,  
                     INPUT tt-crapcje.nrfonemp,  
                     INPUT tt-crapcje.nrramemp,  
                     INPUT tt-crapcje.cdturnos,  
                     INPUT tt-crapcje.dtadmemp,  
                     INPUT tt-crapcje.vlsalari,
                     INPUT par_dtmvtolt,
                     INPUT "A",/*cddopcao*/
                    OUTPUT aux_tpatlcad,
                    OUTPUT aux_msgatcad,
                    OUTPUT aux_chavealt,
                    OUTPUT aux_msgrvcad,
                    OUTPUT TABLE tt-erro ).

               IF  RETURN-VALUE <> "OK" THEN
                   UNDO REPLICA, LEAVE REPLICA.
            END.

        IF  VALID-HANDLE(h-b1wgen0057) THEN
            DELETE OBJECT h-b1wgen0057.
        
        /******************* TELEFONE ******************/
        EMPTY TEMP-TABLE tt-erro.

        IF  NOT VALID-HANDLE(h-b1wgen0070)  THEN
            RUN sistema/generico/procedures/b1wgen0070.p 
                PERSISTENT SET h-b1wgen0070.
        
        RUN obtem-telefone-cooperado IN h-b1wgen0070 
            ( INPUT par_cdcooper,
              INPUT par_cdagenci,
              INPUT par_nrdcaixa,
              INPUT par_cdoperad,
              INPUT par_nmdatela,
              INPUT par_idorigem,
              INPUT aux_nrctattl,
              INPUT 1,/*idseqttl*/
              INPUT NO,
             OUTPUT aux_msgconta,
             OUTPUT TABLE tt-erro,
             OUTPUT TABLE tt-telefone-cooperado ).
        
        FOR EACH tt-telefone-cooperado NO-LOCK:
            
            RUN gerenciar-telefone IN h-b1wgen0070 
                ( INPUT par_cdcooper,
                  INPUT par_cdagenci,
                  INPUT par_nrdcaixa,
                  INPUT par_cdoperad,
                  INPUT par_nmdatela,
                  INPUT par_idorigem,
                  INPUT par_nrdconta,
                  INPUT par_idseqttl,
                  INPUT "I",/*cddopcao*/
                  INPUT par_dtmvtolt,
                  INPUT ?,  /*nrdrowid*/
                  INPUT tt-telefone-cooperado.tptelefo,
                  INPUT tt-telefone-cooperado.nrdddtfc,
                  INPUT tt-telefone-cooperado.nrtelefo,
                  INPUT tt-telefone-cooperado.nrdramal,
                  INPUT tt-telefone-cooperado.secpscto,
                  INPUT tt-telefone-cooperado.nmpescto,
                  INPUT tt-telefone-cooperado.cdopetfn,
                  INPUT "A",/*prgqfalt*/
                  INPUT tt-telefone-cooperado.idsittfc,
                  INPUT tt-telefone-cooperado.idorigem, 
                  INPUT par_flgerlog,
                 OUTPUT aux_tpatlcad,
                 OUTPUT aux_msgatcad,
                 OUTPUT aux_chavealt,
                 OUTPUT aux_msgrvcad,
                 OUTPUT TABLE tt-erro ).

            IF  RETURN-VALUE <> "OK" THEN
                UNDO REPLICA, LEAVE REPLICA.
        END.

        IF  VALID-HANDLE(h-b1wgen0070) THEN
            DELETE OBJECT h-b1wgen0070.
        
        /******************** EMAIL *******************/
        EMPTY TEMP-TABLE tt-erro.

        IF  NOT VALID-HANDLE(h-b1wgen0071) THEN
            RUN sistema/generico/procedures/b1wgen0071.p 
                PERSISTENT SET h-b1wgen0071.
        
        RUN obtem-email-cooperado IN h-b1wgen0071 
            ( INPUT par_cdcooper,
              INPUT par_cdagenci,
              INPUT par_nrdcaixa,
              INPUT par_cdoperad,
              INPUT par_nmdatela,
              INPUT par_idorigem,
              INPUT aux_nrctattl,
              INPUT 1,/*idseqttl*/
              INPUT NO,
             OUTPUT aux_msgconta,
             OUTPUT TABLE tt-email-cooperado ).
        
        FOR EACH tt-email-cooperado NO-LOCK:

            RUN gerenciar-email IN h-b1wgen0071 
                ( INPUT par_cdcooper,
                  INPUT par_cdagenci,
                  INPUT par_nrdcaixa,
                  INPUT par_cdoperad,
                  INPUT par_nmdatela,
                  INPUT par_idorigem,
                  INPUT par_nrdconta,
                  INPUT par_idseqttl,
                  INPUT "I",/*cddopcao*/
                  INPUT par_dtmvtolt,
                  INPUT ?,  /*nrdrowid*/
                  INPUT tt-email-cooperado.dsdemail,
                  INPUT tt-email-cooperado.secpscto,
                  INPUT tt-email-cooperado.nmpescto,
                  INPUT "A",/*prgqfalt*/
                  INPUT par_flgerlog,
                 OUTPUT aux_tpatlcad,
                 OUTPUT aux_msgatcad,
                 OUTPUT aux_chavealt,
                 OUTPUT aux_msgrvcad,
                 OUTPUT TABLE tt-erro ).

            IF  RETURN-VALUE <> "OK" THEN
                UNDO REPLICA, LEAVE REPLICA.
        END.

        IF  VALID-HANDLE(h-b1wgen0071) THEN
            DELETE OBJECT h-b1wgen0071.
        
        /******************* COMERCIAL *****************/
        EMPTY TEMP-TABLE tt-erro.

        IF  NOT VALID-HANDLE(h-b1wgen0075)  THEN
            RUN sistema/generico/procedures/b1wgen0075.p 
                PERSISTENT SET h-b1wgen0075.
        
        RUN Busca_Dados IN h-b1wgen0075
           ( INPUT par_cdcooper, 
             INPUT par_cdagenci,            
             INPUT par_nrdcaixa,            
             INPUT par_cdoperad, 
             INPUT par_nmdatela, 
             INPUT par_idorigem,            
             INPUT aux_nrctattl, 
             INPUT 1,  /*idseqttl*/
             INPUT NO,
             INPUT "C",/*cddopcao*/
             INPUT "",
             INPUT "",
             INPUT "",
             INPUT "",
             INPUT "",
             INPUT "",
             INPUT "",
             INPUT "",
             INPUT "",
             INPUT "",
             INPUT "",
             INPUT "",
             INPUT "",
             INPUT "",
             INPUT "",
             INPUT "",
             INPUT "",
             INPUT "",
             INPUT "",
             INPUT "",
            OUTPUT aux_msgconta,
            OUTPUT TABLE tt-comercial,
            OUTPUT TABLE tt-erro ) .
        
        ASSIGN aux_nrdrowid = ?.

        FIND FIRST tt-comercial NO-LOCK NO-ERROR.

        IF  AVAILABLE tt-comercial THEN
            DO: 
               FOR FIRST crapttl WHERE crapttl.cdcooper = par_cdcooper AND 
                                       crapttl.nrdconta = par_nrdconta AND
                                       crapttl.idseqttl = par_idseqttl 
                                       NO-LOCK:

                   ASSIGN aux_nrdrowid = ROWID(crapttl).
               END.

               RUN Grava_Dados IN h-b1wgen0075
                   ( INPUT par_cdcooper, 
                     INPUT par_cdagenci,            
                     INPUT par_nrdcaixa,            
                     INPUT par_cdoperad, 
                     INPUT par_nmdatela, 
                     INPUT par_idorigem,            
                     INPUT par_nrdconta, 
                     INPUT par_idseqttl, 
                     INPUT par_flgerlog,
                     INPUT "A",/*cddopcao*/
                     INPUT par_dtmvtolt,
                     INPUT aux_nrdrowid,
                     INPUT tt-comercial.cdnatopc,
                     INPUT tt-comercial.cdocpttl,
                     INPUT tt-comercial.tpcttrab,
                     INPUT tt-comercial.cdempres,
                     INPUT tt-comercial.nmextemp,
                     INPUT tt-comercial.nrcpfemp,
                     INPUT tt-comercial.dsproftl,
                     INPUT tt-comercial.cdnvlcgo,
                     INPUT tt-comercial.nrcadast,
                     INPUT tt-comercial.ufresct1,
                     INPUT tt-comercial.endrect1,
                     INPUT tt-comercial.bairoct1,
                     INPUT tt-comercial.cidadct1,
                     INPUT tt-comercial.complcom,
                     INPUT tt-comercial.cepedct1,
                     INPUT tt-comercial.cxpotct1,
                     INPUT tt-comercial.cdturnos,
                     INPUT tt-comercial.dtadmemp,
                     INPUT tt-comercial.vlsalari,
                     INPUT "",
                     INPUT tt-comercial.nrendcom,
                     INPUT tt-comercial.tpdrendi[1],
                     INPUT tt-comercial.vldrendi[1],
                     INPUT tt-comercial.tpdrendi[2],
                     INPUT tt-comercial.tpdrendi[3],
                     INPUT tt-comercial.tpdrendi[4],
                     INPUT tt-comercial.vldrendi[2],
                     INPUT tt-comercial.vldrendi[3],
                     INPUT tt-comercial.vldrendi[4],
                     INPUT tt-comercial.inpolexp,
                    OUTPUT aux_tpatlcad,
                    OUTPUT aux_msgatcad,
                    OUTPUT aux_chavealt,
                    OUTPUT aux_msgrvcad,
                    OUTPUT aux_cotcance,
                    OUTPUT TABLE tt-erro ) .

               IF  RETURN-VALUE <> "OK" THEN
                   UNDO REPLICA, LEAVE REPLICA.
            END.

        IF  VALID-HANDLE(h-b1wgen0075) THEN
            DELETE OBJECT h-b1wgen0075.
        
        /************** RESPONSAVEL LEGAL *************/
        EMPTY TEMP-TABLE tt-erro.

        IF  NOT VALID-HANDLE(h-b1wgen0072)  THEN
            RUN sistema/generico/procedures/b1wgen0072.p 
                PERSISTENT SET h-b1wgen0072.
        
        RUN Busca_Dados IN h-b1wgen0072
           ( INPUT par_cdcooper,
             INPUT par_cdagenci,
             INPUT par_nrdcaixa,
             INPUT par_cdoperad,
             INPUT par_nmdatela,
             INPUT par_idorigem,
             INPUT aux_nrctattl,
             INPUT 1,  /*idseqttl*/
             INPUT NO,
             INPUT par_dtmvtolt,
             INPUT "C",/*cddopcao*/
             INPUT 0,  /*nrdctato*/
             INPUT 0,  /*nrcpfcto*/
             INPUT ?,  /*nrdrowid*/
             INPUT (IF aux_nrctattl = 0 THEN /*se nao for coop passa cpf*/
                       par_nrcpfcgc
                    ELSE
                       0),  
             INPUT "",
             INPUT ?,
             INPUT 0,
             INPUT FALSE,
            OUTPUT aux_menorida,
            OUTPUT aux_msgconta,
            OUTPUT TABLE tt-crapcrl,
            OUTPUT TABLE tt-erro ) .
        
        FOR EACH tt-crapcrl NO-LOCK:
            
            IF tt-crapcrl.nrdconta = 0 THEN
                DO:            
                    RUN Busca_Dados IN h-b1wgen0072
                        ( INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT par_cdoperad,
                          INPUT par_nmdatela,
                          INPUT par_idorigem,
                          INPUT par_nrdconta,
                          INPUT par_idseqttl,
                          INPUT NO,
                          INPUT par_dtmvtolt,
                          INPUT "A",
                          INPUT tt-crapcrl.nrdconta,
                          INPUT (IF tt-crapcrl.nrdconta = 0 THEN /*se nao for */
                                    tt-crapcrl.nrcpfcgc          /*coop passa */
                                 ELSE                            /*cpf */
                                    0),
                          INPUT tt-crapcrl.nrdrowid,
                          INPUT (IF par_nrdconta = 0 THEN /*se nao for coop*/
                                    tt-crapcrl.nrcpfmen   /*passa cpf */
                                 ELSE
                                    0),
                          INPUT "",
                          INPUT tt-crapcrl.dtdenasc,
                          INPUT tt-crapcrl.cdhabmen,
                          INPUT FALSE,
                        OUTPUT aux_menorida,
                        OUTPUT aux_msgconta,
                        OUTPUT TABLE tt-aux-crapcrl,
                        OUTPUT TABLE tt-erro ) NO-ERROR.

                    FOR FIRST tt-aux-crapcrl: END.
                    
                    IF AVAILABLE tt-aux-crapcrl THEN
                       ASSIGN aux_nrdrowid = tt-aux-crapcrl.nrdrowid
                              aux_nrdctato = tt-aux-crapcrl.nrdconta
                              aux_nrcpfcto = tt-aux-crapcrl.nrcpfcgc
                              aux_cpfprocu = tt-aux-crapcrl.nrcpfmen
                              aux_nmdavali = tt-aux-crapcrl.nmrespon

                              aux_tpdocava = tt-aux-crapcrl.tpdeiden 
                              aux_nrdocava = tt-aux-crapcrl.nridenti 
                              aux_cdoeddoc = tt-aux-crapcrl.dsorgemi 
                              aux_cdufddoc = tt-aux-crapcrl.cdufiden 
                              aux_dtemddoc = tt-aux-crapcrl.dtemiden
                              aux_dtnascto = tt-aux-crapcrl.dtnascin
                              aux_cdsexcto = tt-aux-crapcrl.cddosexo 
                              aux_cdestcvl = tt-aux-crapcrl.cdestciv 
                              aux_cdnacion = tt-aux-crapcrl.cdnacion 
                              aux_dsnatura = tt-aux-crapcrl.dsnatura 
                              aux_nrcepend = tt-aux-crapcrl.cdcepres
                              aux_dsendere = tt-aux-crapcrl.dsendres

                              aux_nmbairro = tt-aux-crapcrl.dsbaires 
                              aux_nmcidade = tt-aux-crapcrl.dscidres 
                              aux_nrendere = tt-aux-crapcrl.nrendres 
                              aux_cdufende = tt-aux-crapcrl.dsdufres 
                              aux_complend = tt-aux-crapcrl.dscomres 
                              aux_nrcxapst = tt-aux-crapcrl.nrcxpost 
                              aux_nmmaecto = tt-aux-crapcrl.nmmaersp
                              aux_nmpaicto = tt-aux-crapcrl.nmpairsp
                              aux_cdrlcrsp = tt-aux-crapcrl.cdrlcrsp.
                    
                END.
            ELSE 
                DO:
                   ASSIGN aux_nrdrowid = tt-crapcrl.nrdrowid
                          aux_nrdctato = tt-crapcrl.nrdconta
                          aux_nrcpfcto = tt-crapcrl.nrcpfcgc
                          aux_cpfprocu = tt-crapcrl.nrcpfmen
                          aux_nmdavali = tt-crapcrl.nmrespon 
                          aux_tpdocava = tt-crapcrl.tpdeiden 
                          aux_nrdocava = tt-crapcrl.nridenti 
                          aux_cdoeddoc = tt-crapcrl.dsorgemi 
                          aux_cdufddoc = tt-crapcrl.cdufiden 
                          aux_dtemddoc = tt-crapcrl.dtemiden 
                          aux_dtnascto = tt-crapcrl.dtnascin 
                          aux_cdsexcto = tt-crapcrl.cddosexo 
                          aux_cdestcvl = tt-crapcrl.cdestciv 
                          aux_cdnacion = tt-crapcrl.cdnacion 
                          aux_dsnatura = tt-crapcrl.dsnatura 
                          aux_nrcepend = tt-crapcrl.cdcepres 
                          aux_dsendere = tt-crapcrl.dsendres 
                          aux_nmbairro = tt-crapcrl.dsbaires 
                          aux_nmcidade = tt-crapcrl.dscidres 
                          aux_nrendere = tt-crapcrl.nrendres 
                          aux_cdufende = tt-crapcrl.dsdufres 
                          aux_complend = tt-crapcrl.dscomres 
                          aux_nrcxapst = tt-crapcrl.nrcxpost 
                          aux_nmmaecto = tt-crapcrl.nmmaersp 
                          aux_nmpaicto = tt-crapcrl.nmpairsp
                          aux_cdrlcrsp = tt-crapcrl.cdrlcrsp.

                END.

            RUN Grava_Dados IN h-b1wgen0072
                ( INPUT par_cdcooper,
                  INPUT par_cdagenci,
                  INPUT par_nrdcaixa,
                  INPUT par_cdoperad,
                  INPUT par_nmdatela,
                  INPUT par_idorigem,
                  INPUT par_nrdconta,
                  INPUT par_idseqttl,
                  INPUT par_flgerlog,
                  INPUT aux_nrdrowid,
                  INPUT par_dtmvtolt,
                  INPUT "I",/*cddopcao*/
                  INPUT aux_nrdctato,
                  INPUT (IF aux_nrdctato = 0 THEN /*se nao for coop */
                            aux_nrcpfcto          /*passa cpf*/
                         ELSE
                            0),
                  INPUT aux_nmdavali,
                  INPUT aux_tpdocava,
                  INPUT aux_nrdocava,
                  INPUT aux_cdoeddoc,
                  INPUT aux_cdufddoc,
                  INPUT aux_dtemddoc,
                  INPUT aux_dtnascto,
                  INPUT aux_cdsexcto,
                  INPUT aux_cdestcvl,
                  INPUT aux_cdnacion,
                  INPUT aux_dsnatura,
                  INPUT aux_nrcepend,
                  INPUT aux_dsendere,
                  INPUT aux_nmbairro,
                  INPUT aux_nmcidade,
                  INPUT aux_nrendere,
                  INPUT aux_cdufende,
                  INPUT aux_complend,
                  INPUT aux_nrcxapst,
                  INPUT aux_nmmaecto,
                  INPUT aux_nmpaicto,
                  INPUT (IF par_nrdconta = 0 THEN /*se nao for coop passa cpf*/
                            aux_cpfprocu
                         ELSE
                            0),
                  INPUT aux_cdrlcrsp,
                  INPUT aux_nmrotina,
                 OUTPUT aux_msgalert,
                 OUTPUT aux_tpatlcad,
                 OUTPUT aux_msgatcad, 
                 OUTPUT aux_chavealt, 
                 OUTPUT TABLE tt-erro ).

            IF  RETURN-VALUE <> "OK" THEN
                UNDO REPLICA, LEAVE REPLICA.
        END.

        IF  VALID-HANDLE(h-b1wgen0072) THEN
            DELETE OBJECT h-b1wgen0072.
        
        /******************* ENDERECO ******************/
        EMPTY TEMP-TABLE tt-erro.

        IF  NOT VALID-HANDLE(h-b1wgen0038)  THEN
            RUN sistema/generico/procedures/b1wgen0038.p 
                PERSISTENT SET h-b1wgen0038.
        
        RUN obtem-endereco IN h-b1wgen0038 
            ( INPUT par_cdcooper,
              INPUT par_cdagenci,
              INPUT par_nrdcaixa,
              INPUT par_cdoperad,
              INPUT par_nmdatela,
              INPUT par_idorigem,
              INPUT aux_nrctattl,
              INPUT 1,/*idseqttl*/
              INPUT NO,
             OUTPUT aux_msgconta,
             OUTPUT aux_inpessoa,
             OUTPUT TABLE tt-erro,
             OUTPUT TABLE tt-endereco-cooperado ).
        
        FIND FIRST tt-endereco-cooperado NO-LOCK NO-ERROR.

        IF  AVAILABLE tt-endereco-cooperado THEN
            DO:
               RUN alterar-endereco IN h-b1wgen0038 
                   ( INPUT par_cdcooper,
                     INPUT par_cdagenci,
                     INPUT par_nrdcaixa,
                     INPUT par_cdoperad,
                     INPUT par_nmdatela,
                     INPUT par_idorigem,
                     INPUT par_nrdconta,
                     INPUT par_idseqttl,
                     INPUT "",/*cddopcao*/
                     INPUT par_dtmvtolt,
                     INPUT tt-endereco-cooperado.incasprp,
                     INPUT tt-endereco-cooperado.dtinires,
                     INPUT tt-endereco-cooperado.vlalugue,
                     INPUT tt-endereco-cooperado.dsendere,
                     INPUT tt-endereco-cooperado.nrendere,
                     INPUT tt-endereco-cooperado.nrcepend,
                     INPUT tt-endereco-cooperado.complend,
                     INPUT tt-endereco-cooperado.nrdoapto,
                     INPUT tt-endereco-cooperado.cddbloco,
                     INPUT tt-endereco-cooperado.nmbairro,
                     INPUT tt-endereco-cooperado.nmcidade,
                     INPUT tt-endereco-cooperado.cdufende,
                     INPUT tt-endereco-cooperado.nrcxapst,
                     INPUT tt-endereco-cooperado.qtprebem,
                     INPUT tt-endereco-cooperado.vlprebem,
                     INPUT 0,
                     INPUT par_flgerlog,
                     INPUT tt-endereco-cooperado.idorigem,
                    OUTPUT aux_msgalert,
                    OUTPUT aux_tpatlcad,
                    OUTPUT aux_msgatcad,
                    OUTPUT aux_chavealt,
                    OUTPUT aux_msgrvcad,
                    OUTPUT TABLE tt-erro ).

               IF  RETURN-VALUE <> "OK" THEN
                   UNDO REPLICA, LEAVE REPLICA.
            END.

        IF  VALID-HANDLE(h-b1wgen0038) THEN
            DELETE OBJECT h-b1wgen0038.

    END.
    
    IF  VALID-HANDLE(h-b1wgen0054) THEN
        DELETE OBJECT h-b1wgen0054.

    IF  VALID-HANDLE(h-b1wgen0047) THEN
        DELETE OBJECT h-b1wgen0047.

    IF  VALID-HANDLE(h-b1wgen0056) THEN
        DELETE OBJECT h-b1wgen0056.

    IF  VALID-HANDLE(h-b1wgen0057) THEN
        DELETE OBJECT h-b1wgen0057.
    
    IF  VALID-HANDLE(h-b1wgen0070) THEN
        DELETE OBJECT h-b1wgen0070.

    IF  VALID-HANDLE(h-b1wgen0071) THEN
        DELETE OBJECT h-b1wgen0071.
    
    IF  VALID-HANDLE(h-b1wgen0075) THEN
        DELETE OBJECT h-b1wgen0075.

    IF  VALID-HANDLE(h-b1wgen0072) THEN
        DELETE OBJECT h-b1wgen0072.

    IF  VALID-HANDLE(h-b1wgen0038) THEN
        DELETE OBJECT h-b1wgen0038.

    /* Verifica se houve erro */
    FIND FIRST tt-erro NO-ERROR.

    IF  AVAILABLE tt-erro THEN
        ASSIGN par_dscritic = tt-erro.dscritic.
    ELSE
        ASSIGN par_dscritic = "".
    
    IF  par_dscritic <> "" THEN
        RETURN "NOK".
    ELSE
        RETURN "OK".

END PROCEDURE. /*Gerencia_Replicacao*/

/* ------------------------------------------------------------------------ */
/*         REPLICACAO DOS DADOS DA CONTA PAI(PRIMEIRO TTL) P/ FILHAS        */
/* ------------------------------------------------------------------------ */
PROCEDURE Replica_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmrotina AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGICAL                        NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_returnvl AS CHAR INITIAL "NOK"                      NO-UNDO.
    DEF VAR aux_msgconta AS CHAR                                    NO-UNDO.
    DEF VAR aux_inpessoa AS INTE                                    NO-UNDO.
    DEF VAR aux_operacao AS CHAR                                    NO-UNDO.
    DEF VAR aux_msgvalid AS CHAR                                    NO-UNDO.
    DEF VAR aux_menorida AS LOG                                     NO-UNDO.
    DEF VAR h_rotinabase AS HANDLE                                  NO-UNDO.
    DEF VAR aux_nrcpfcgc AS DEC                                     NO-UNDO.

    DEF BUFFER crabttl FOR crapttl.
    DEF BUFFER crabass FOR crapass.

    ASSIGN aux_nrcpfcgc = 0.
    
    Replica: DO TRANSACTION
        ON ERROR  UNDO Replica, LEAVE Replica
        ON QUIT   UNDO Replica, LEAVE Replica
        ON STOP   UNDO Replica, LEAVE Replica
        ON ENDKEY UNDO Replica, LEAVE Replica:

        FOR FIRST crabass FIELDS(cdtipcta nrcpfcgc) 
                          WHERE crabass.cdcooper = par_cdcooper AND 
                                crabass.nrdconta = par_nrdconta 
                                NO-LOCK:

            /** Ignora conta aplicacao **/
            IF  CAN-DO("6,7,17,18",STRING(crabass.cdtipcta))  THEN
                DO:
                    ASSIGN aux_returnvl = "OK".
                    UNDO Replica, LEAVE Replica.

                END.

            ASSIGN aux_nrcpfcgc = crabass.nrcpfcgc.

        END.

        CASE par_nmrotina:
            WHEN "FILIACAO" THEN DO:
                IF  NOT VALID-HANDLE(h_rotinabase) THEN
                    RUN sistema/generico/procedures/b1wgen0054.p 
                        PERSISTENT SET h_rotinabase.

                EMPTY TEMP-TABLE tt-filiacao.

                /* Buscar os dados alterados pela rotina origem */
                RUN Busca_Dados IN h_rotinabase
                    ( INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT par_cdoperad,
                      INPUT par_nmdatela,
                      INPUT par_idorigem,
                      INPUT par_nrdconta,
                      INPUT par_idseqttl,
                      INPUT NO,
                     OUTPUT aux_msgconta,
                     OUTPUT TABLE tt-filiacao,
                     OUTPUT TABLE tt-erro ) NO-ERROR.

                IF  NOT RetornoErro( INPUT-OUTPUT par_dscritic ) THEN
                    UNDO Replica, LEAVE Replica.

                IF  VALID-HANDLE(h_rotinabase) THEN
                    DELETE OBJECT h_rotinabase.

            END.
            WHEN "ENDERECO" THEN DO:
                IF  NOT VALID-HANDLE(h_rotinabase) THEN
                    RUN sistema/generico/procedures/b1wgen0038.p 
                        PERSISTENT SET h_rotinabase.

                EMPTY TEMP-TABLE tt-endereco-cooperado.

                /* Buscar os dados alterados pela rotina origem */
                RUN obtem-endereco IN h_rotinabase
                    ( INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT par_cdoperad,
                      INPUT par_nmdatela,
                      INPUT par_idorigem,
                      INPUT par_nrdconta,
                      INPUT par_idseqttl,
                      INPUT NO,
                     OUTPUT aux_msgconta,
                     OUTPUT aux_inpessoa,
                     OUTPUT TABLE tt-erro,
                     OUTPUT TABLE tt-endereco-cooperado ) NO-ERROR.

                IF  NOT RetornoErro( INPUT-OUTPUT par_dscritic ) THEN
                    UNDO Replica, LEAVE Replica.

                IF  VALID-HANDLE(h_rotinabase) THEN
                    DELETE OBJECT h_rotinabase.
                 
            END.
            WHEN "COMERCIAL" THEN DO:
                IF  NOT VALID-HANDLE(h_rotinabase) THEN
                    RUN sistema/generico/procedures/b1wgen0075.p 
                        PERSISTENT SET h_rotinabase.

                EMPTY TEMP-TABLE tt-comercial.

                /* Buscar os dados alterados pela rotina origem */
                RUN Busca_Dados IN h_rotinabase
                    ( INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT par_cdoperad,
                      INPUT par_nmdatela,
                      INPUT par_idorigem,
                      INPUT par_nrdconta,
                      INPUT par_idseqttl,
                      INPUT NO,
                      INPUT "C",
                      INPUT "",INPUT "",INPUT "",INPUT "",INPUT "",
                      INPUT "",INPUT "",INPUT "",INPUT "",INPUT "",
                      INPUT "",INPUT "",INPUT "",INPUT "",INPUT "",
                      INPUT "",INPUT "",INPUT "",INPUT "",INPUT "",
                     OUTPUT aux_msgconta,
                     OUTPUT TABLE tt-comercial,
                     OUTPUT TABLE tt-erro ) NO-ERROR.

                IF  NOT RetornoErro( INPUT-OUTPUT par_dscritic ) THEN
                    UNDO Replica, LEAVE Replica.

                IF  VALID-HANDLE(h_rotinabase) THEN
                        DELETE OBJECT h_rotinabase.
                
            END.
            WHEN "BENS" THEN DO:
                IF  NOT VALID-HANDLE(h_rotinabase) THEN
                    RUN sistema/generico/procedures/b1wgen0056.p 
                        PERSISTENT SET h_rotinabase.

                EMPTY TEMP-TABLE tt-crapbem.
                
                /* Buscar os dados existentes na conta filha */
                RUN Busca-Dados IN h_rotinabase
                    ( INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT par_cdoperad,
                      INPUT par_nrdconta,
                      INPUT par_idorigem,
                      INPUT par_nmdatela,
                      INPUT par_idseqttl,
                      INPUT NO,
                      INPUT 0,
                      INPUT "C",
                      INPUT ?,
                     OUTPUT aux_msgconta,
                     OUTPUT TABLE tt-crapbem,
                     OUTPUT TABLE tt-erro ) NO-ERROR.

                IF  NOT RetornoErro( INPUT-OUTPUT par_dscritic ) THEN
                    UNDO Replica, LEAVE Replica.

                IF  VALID-HANDLE(h_rotinabase) THEN
                    DELETE OBJECT h_rotinabase.
                
            END.
            WHEN "TELEFONE" THEN DO:
                IF  NOT VALID-HANDLE(h_rotinabase) THEN
                    RUN sistema/generico/procedures/b1wgen0070.p 
                        PERSISTENT SET h_rotinabase.

                EMPTY TEMP-TABLE tt-telefone-cooperado.

                /* Buscar os dados gravados na rotina origem */
                RUN obtem-telefone-cooperado IN h_rotinabase
                    ( INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT par_cdoperad,
                      INPUT par_nmdatela,
                      INPUT par_idorigem,
                      INPUT par_nrdconta,
                      INPUT par_idseqttl,
                      INPUT NO,
                     OUTPUT aux_msgconta,
                     OUTPUT TABLE tt-erro,
                     OUTPUT TABLE tt-telefone-cooperado  ) NO-ERROR.

                IF  NOT RetornoErro( INPUT-OUTPUT par_dscritic ) THEN
                    UNDO Replica, LEAVE Replica.

                IF  VALID-HANDLE(h_rotinabase) THEN
                    DELETE OBJECT h_rotinabase.
                
            END.
            WHEN "EMAIL" THEN DO:
                IF  NOT VALID-HANDLE(h_rotinabase) THEN
                    RUN sistema/generico/procedures/b1wgen0071.p 
                        PERSISTENT SET h_rotinabase.

                EMPTY TEMP-TABLE tt-email-cooperado.
                
                /* Buscar os dados gravados na rotina origem */
                RUN obtem-email-cooperado IN h_rotinabase
                    ( INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT par_cdoperad,
                      INPUT par_nmdatela,
                      INPUT par_idorigem,
                      INPUT par_nrdconta,
                      INPUT par_idseqttl,
                      INPUT NO,
                     OUTPUT aux_msgconta,
                     OUTPUT TABLE tt-email-cooperado ) NO-ERROR.

                IF  NOT RetornoErro( INPUT-OUTPUT par_dscritic ) THEN
                    UNDO Replica, LEAVE Replica.

                IF  VALID-HANDLE(h_rotinabase) THEN
                    DELETE OBJECT h_rotinabase.

            END.
            WHEN "CONJUGE" THEN DO:
                IF  NOT VALID-HANDLE(h_rotinabase) THEN
                    RUN sistema/generico/procedures/b1wgen0057.p 
                        PERSISTENT SET h_rotinabase.

                EMPTY TEMP-TABLE tt-crapcje.

                /* Buscar os dados alterados pela rotina origem */
                RUN Busca_Dados IN h_rotinabase
                    ( INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT par_cdoperad,
                      INPUT par_nmdatela,
                      INPUT par_idorigem,
                      INPUT par_nrdconta,
                      INPUT par_idseqttl,
                      INPUT NO,
                      INPUT "C",
                      INPUT ?,
                      INPUT 0,
                      INPUT 0,
                     OUTPUT aux_msgconta,
                     OUTPUT TABLE tt-crapcje,
                     OUTPUT TABLE tt-erro).

                IF NOT RetornoErro( INPUT-OUTPUT par_dscritic ) THEN
                    UNDO Replica, LEAVE Replica.

                IF  VALID-HANDLE(h_rotinabase) THEN
                    DELETE OBJECT h_rotinabase.

            END.
            WHEN "DEPENDENTE" THEN DO:
                IF  NOT VALID-HANDLE(h_rotinabase) THEN
                    RUN sistema/generico/procedures/b1wgen0047.p 
                        PERSISTENT SET h_rotinabase.

                EMPTY TEMP-TABLE tt-dependente.

                /* Buscar os dados gravados na rotina origem */
                RUN obtem-dependentes IN h_rotinabase
                    ( INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT par_cdoperad,
                      INPUT par_nmdatela,
                      INPUT par_idorigem,
                      INPUT par_nrdconta,
                      INPUT par_idseqttl,
                      INPUT NO,
                     OUTPUT aux_msgconta,
                     OUTPUT TABLE tt-dependente ) NO-ERROR.

                IF  NOT RetornoErro( INPUT-OUTPUT par_dscritic ) THEN
                    UNDO Replica, LEAVE Replica.

                IF  VALID-HANDLE(h_rotinabase) THEN
                     DELETE OBJECT h_rotinabase.
                
            END.
            WHEN "RESPONSAVEL" THEN DO:
                IF  NOT VALID-HANDLE(h_rotinabase) THEN
                    RUN sistema/generico/procedures/b1wgen0072.p 
                        PERSISTENT SET h_rotinabase.

                EMPTY TEMP-TABLE tt-crapcrl.
                    
                /* Buscar os dados gravados na rotina origem */
                RUN Busca_Dados IN h_rotinabase
                    ( INPUT par_cdcooper,       
                      INPUT par_cdagenci,       
                      INPUT par_nrdcaixa,       
                      INPUT par_cdoperad,       
                      INPUT par_nmdatela,       
                      INPUT par_idorigem,       
                      INPUT par_nrdconta,       
                      INPUT par_idseqttl,       
                      INPUT NO,                 
                      INPUT par_dtmvtolt,       
                      INPUT "C",                
                      INPUT 0,                  
                      INPUT 0,                  
                      INPUT ?, 
                      INPUT (IF par_nrdconta = 0 THEN /*se nao for coop */
                                aux_nrcpfcgc          /*passa cpf */
                             ELSE
                                0),
                      INPUT "",
                      INPUT ?,
                      INPUT 0,
                      INPUT FALSE,
                    OUTPUT aux_menorida,
                    OUTPUT aux_msgconta,
                    OUTPUT TABLE tt-crapcrl,
                    OUTPUT TABLE tt-erro ) NO-ERROR.
                

                IF  NOT RetornoErro( INPUT-OUTPUT par_dscritic ) THEN
                    UNDO Replica, LEAVE Replica.
                
                IF  VALID-HANDLE(h_rotinabase) THEN
                    DELETE OBJECT h_rotinabase.
                
            END.

        END CASE.
        
        /* Procura por contas onde o cooperado nao e primeiro titular */
        FOR FIRST crabass FIELDS(nrcpfcgc)
                          WHERE crabass.cdcooper = par_cdcooper AND
                                crabass.nrdconta = par_nrdconta 
                                NO-LOCK,

            EACH crabttl FIELDS(nrdconta idseqttl nrcpfcgc)
                         WHERE crabttl.cdcooper  = par_cdcooper     AND
                               crabttl.nrcpfcgc  = crabass.nrcpfcgc AND 
                               crabttl.idseqttl  > 1                
                               NO-LOCK:

            EMPTY TEMP-TABLE tt-erro.

            IF  VALID-HANDLE(h_rotinabase) THEN
                DELETE OBJECT h_rotinabase.

            CASE par_nmrotina:
                WHEN "FILIACAO" THEN DO:
                    
                    /* Replica os dados para a conta filha */
                    RUN Replica_Filiacao
                        ( INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT par_cdoperad,
                          INPUT par_nmdatela,
                          INPUT par_idorigem,
                          INPUT crabttl.nrdconta,
                          INPUT crabttl.idseqttl,
                          INPUT par_dtmvtolt,
                          INPUT par_flgerlog,
                          INPUT TABLE tt-filiacao,
                         OUTPUT par_cdcritic,
                         OUTPUT par_dscritic,
                         OUTPUT TABLE tt-erro ) NO-ERROR.
                    
                    IF  NOT RetornaErroReplica
                        ( INPUT crabttl.nrdconta,
                          INPUT "",
                          INPUT-OUTPUT par_dscritic ) THEN
                        UNDO Replica, LEAVE Replica.
                END.
                WHEN "ENDERECO" THEN DO:
                    
                    /* Replica os dados para a conta filha */
                    RUN Replica_Endereco
                        ( INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT par_cdoperad,
                          INPUT par_nmdatela,
                          INPUT par_idorigem,
                          INPUT crabttl.nrdconta,
                          INPUT crabttl.idseqttl,
                          INPUT par_dtmvtolt,
                          INPUT par_flgerlog,
                          INPUT TABLE tt-endereco-cooperado,
                         OUTPUT par_cdcritic,
                         OUTPUT par_dscritic,
                         OUTPUT TABLE tt-erro ) NO-ERROR.
                    
                    IF  NOT RetornaErroReplica
                        ( INPUT crabttl.nrdconta,
                          INPUT "",
                          INPUT-OUTPUT par_dscritic ) THEN
                        UNDO Replica, LEAVE Replica.
                END.
                WHEN "COMERCIAL" THEN DO:
                    
                    /* Replica os dados para a conta filha */
                    RUN Replica_Comercial
                        ( INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT par_cdoperad,
                          INPUT par_nmdatela,
                          INPUT par_idorigem,
                          INPUT crabttl.nrdconta,
                          INPUT crabttl.idseqttl,
                          INPUT par_dtmvtolt,
                          INPUT par_flgerlog,
                          INPUT TABLE tt-comercial,
                         OUTPUT par_cdcritic,
                         OUTPUT par_dscritic,
                         OUTPUT TABLE tt-erro ) NO-ERROR.

                    IF  NOT RetornaErroReplica
                        ( INPUT crabttl.nrdconta,
                          INPUT "",
                          INPUT-OUTPUT par_dscritic ) THEN
                        UNDO Replica, LEAVE Replica.
                END.
                WHEN "BENS" THEN DO:
                    IF  NOT VALID-HANDLE(h_rotinabase) THEN
                        RUN sistema/generico/procedures/b1wgen0056.p 
                            PERSISTENT SET h_rotinabase.

                    EMPTY TEMP-TABLE tta-crapbem.

                    /* Buscar os dados existentes na conta filha */
                    RUN Busca-Dados IN h_rotinabase
                        ( INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT par_cdoperad,
                          INPUT crabttl.nrdconta,
                          INPUT par_idorigem,
                          INPUT par_nmdatela,
                          INPUT crabttl.idseqttl,
                          INPUT NO,
                          INPUT 0,
                          INPUT "C",
                          INPUT ?,
                        OUTPUT aux_msgconta,
                        OUTPUT TABLE tta-crapbem,
                        OUTPUT TABLE tt-erro ) NO-ERROR.
                    
                    IF  NOT RetornoErro( INPUT-OUTPUT par_dscritic ) THEN
                        UNDO Replica, LEAVE Replica.

                    IF  VALID-HANDLE(h_rotinabase) THEN
                        DELETE OBJECT h_rotinabase.

                    /* Sincroniza os dados existentes na conta filha */
                    RUN Replica_Bens
                        ( INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT par_cdoperad,
                          INPUT par_nmdatela,
                          INPUT par_idorigem,
                          INPUT crabttl.nrdconta,
                          INPUT crabttl.idseqttl,
                          INPUT par_dtmvtolt,
                          INPUT "S", /*sincronizar/excluir os reg.existentes*/
                          INPUT par_flgerlog,
                          INPUT TABLE tta-crapbem,
                         OUTPUT par_cdcritic,
                         OUTPUT par_dscritic,
                         OUTPUT aux_msgvalid,
                         OUTPUT TABLE tt-erro ) NO-ERROR.

                    IF  NOT RetornaErroReplica
                        ( INPUT crabttl.nrdconta,
                          INPUT aux_msgvalid,
                          INPUT-OUTPUT par_dscritic ) THEN
                        UNDO Replica, LEAVE Replica.
                    
                    /* Replicar os dados para as conta filha */
                    RUN Replica_Bens
                        ( INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT par_cdoperad,
                          INPUT par_nmdatela,
                          INPUT par_idorigem,
                          INPUT crabttl.nrdconta,
                          INPUT crabttl.idseqttl,
                          INPUT par_dtmvtolt,
                          INPUT "R", /*replicar os dados para as ctas.filhas*/
                          INPUT par_flgerlog,
                          INPUT TABLE tt-crapbem,
                         OUTPUT par_cdcritic,
                         OUTPUT par_dscritic,
                         OUTPUT aux_msgvalid,
                         OUTPUT TABLE tt-erro ) NO-ERROR.

                    IF  NOT RetornaErroReplica
                        ( INPUT crabttl.nrdconta,
                          INPUT aux_msgvalid,
                          INPUT-OUTPUT par_dscritic ) THEN
                        UNDO Replica, LEAVE Replica.

                END.
                WHEN "TELEFONE" THEN DO:
                    IF  NOT VALID-HANDLE(h_rotinabase) THEN
                        RUN sistema/generico/procedures/b1wgen0070.p 
                            PERSISTENT SET h_rotinabase.

                    EMPTY TEMP-TABLE tta-telefone-cooperado.

                    /* Buscar os dados existentes na conta filha */
                    RUN obtem-telefone-cooperado IN h_rotinabase
                        ( INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT par_cdoperad,
                          INPUT par_nmdatela,
                          INPUT par_idorigem,
                          INPUT crabttl.nrdconta,
                          INPUT crabttl.idseqttl,
                          INPUT NO,
                        OUTPUT aux_msgconta,
                        OUTPUT TABLE tt-erro,
                        OUTPUT TABLE tta-telefone-cooperado ) NO-ERROR.

                    IF  NOT RetornoErro( INPUT-OUTPUT par_dscritic ) THEN
                        UNDO Replica, LEAVE Replica.

                    IF  VALID-HANDLE(h_rotinabase) THEN
                        DELETE OBJECT h_rotinabase.
                    
                    /* Sincroniza os dados existentes na conta filha */
                    RUN Replica_Telefone
                        ( INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT par_cdoperad,
                          INPUT par_nmdatela,
                          INPUT par_idorigem,
                          INPUT crabttl.nrdconta,
                          INPUT crabttl.idseqttl,
                          INPUT par_nrdconta,
                          INPUT par_dtmvtolt,
                          INPUT "E", /*sincronizar/excluir os reg.existentes*/
                          INPUT par_flgerlog,
                          INPUT TABLE tta-telefone-cooperado,
                         OUTPUT par_cdcritic,
                         OUTPUT par_dscritic,
                         OUTPUT aux_msgvalid,
                         OUTPUT TABLE tt-erro ) NO-ERROR.

                    IF  NOT RetornaErroReplica
                        ( INPUT crabttl.nrdconta,
                          INPUT aux_msgvalid,
                          INPUT-OUTPUT par_dscritic ) THEN
                        UNDO Replica, LEAVE Replica.
                    
                /* Replicar os dados para as conta filha */
                RUN Replica_Telefone
                    ( INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT par_cdoperad,
                      INPUT par_nmdatela,
                      INPUT par_idorigem,
                      INPUT crabttl.nrdconta,
                      INPUT crabttl.idseqttl,
                      INPUT par_nrdconta,
                      INPUT par_dtmvtolt,
                      INPUT "I", /* replicar os dados p/conta filha */
                      INPUT par_flgerlog,
                      INPUT TABLE tt-telefone-cooperado,
                     OUTPUT par_cdcritic,
                     OUTPUT par_dscritic,
                     OUTPUT aux_msgvalid,
                     OUTPUT TABLE tt-erro ) NO-ERROR.

                IF  NOT RetornaErroReplica
                    ( INPUT crabttl.nrdconta,
                      INPUT aux_msgvalid,
                      INPUT-OUTPUT par_dscritic ) THEN
                    UNDO Replica, LEAVE Replica. 

                END.
                WHEN "EMAIL" THEN DO:
                    IF  NOT VALID-HANDLE(h_rotinabase) THEN
                        RUN sistema/generico/procedures/b1wgen0071.p 
                            PERSISTENT SET h_rotinabase.

                    EMPTY TEMP-TABLE tta-email-cooperado.

                    /* Buscar os dados existentes na conta filha */
                    RUN obtem-email-cooperado IN h_rotinabase
                        ( INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT par_cdoperad,
                          INPUT par_nmdatela,
                          INPUT par_idorigem,
                          INPUT crabttl.nrdconta,
                          INPUT crabttl.idseqttl,
                          INPUT NO,
                        OUTPUT aux_msgconta,
                        OUTPUT TABLE tta-email-cooperado ) NO-ERROR.

                    IF  NOT RetornoErro( INPUT-OUTPUT par_dscritic ) THEN
                        UNDO Replica, LEAVE Replica.

                    IF  VALID-HANDLE(h_rotinabase) THEN
                        DELETE OBJECT h_rotinabase.

                    /* Sincroniza os dados existentes na conta filha */
                    RUN Replica_Email
                        ( INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT par_cdoperad,
                          INPUT par_nmdatela,
                          INPUT par_idorigem,
                          INPUT crabttl.nrdconta,
                          INPUT crabttl.idseqttl,
                          INPUT par_nrdconta,
                          INPUT par_dtmvtolt,
                          INPUT "E", /*sincronizar/excluir os reg.existentes*/
                          INPUT par_flgerlog,
                          INPUT TABLE tta-email-cooperado,
                         OUTPUT par_cdcritic,
                         OUTPUT par_dscritic,
                         OUTPUT aux_msgvalid,
                         OUTPUT TABLE tt-erro ) NO-ERROR.

                    IF  NOT RetornaErroReplica
                        ( INPUT crabttl.nrdconta,
                          INPUT aux_msgvalid,
                          INPUT-OUTPUT par_dscritic ) THEN
                        UNDO Replica, LEAVE Replica.
                    
                    /* Replicar os dados para as conta filha */
                    RUN Replica_Email
                        ( INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT par_cdoperad,
                          INPUT par_nmdatela,
                          INPUT par_idorigem,
                          INPUT crabttl.nrdconta,
                          INPUT crabttl.idseqttl,
                          INPUT par_nrdconta,
                          INPUT par_dtmvtolt,
                          INPUT "I", /* replicar os dados p/conta filha */
                          INPUT par_flgerlog,
                          INPUT TABLE tt-email-cooperado,
                         OUTPUT par_cdcritic,
                         OUTPUT par_dscritic,
                         OUTPUT aux_msgvalid,
                         OUTPUT TABLE tt-erro ) NO-ERROR.

                    IF  NOT RetornaErroReplica
                        ( INPUT crabttl.nrdconta,
                          INPUT aux_msgvalid,
                          INPUT-OUTPUT par_dscritic ) THEN
                        UNDO Replica, LEAVE Replica.
                END.
                WHEN "CONJUGE" THEN DO:
                    
                    IF  CAN-FIND(crapcje WHERE
                                 crapcje.cdcooper = crabttl.cdcooper  AND
                                 crapcje.nrdconta = crabttl.nrdconta  AND
                                 crapcje.idseqttl = crabttl.idseqttl) THEN
                        ASSIGN aux_operacao = "A".
                    ELSE
                        ASSIGN aux_operacao = "I".
                        
                    /* Replica os dados para a conta filha */
                    RUN Replica_Conjuge
                        ( INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT par_cdoperad,
                          INPUT par_nmdatela,
                          INPUT par_idorigem,
                          INPUT crabttl.nrdconta,
                          INPUT crabttl.idseqttl,
                          INPUT par_dtmvtolt,
                          INPUT aux_operacao,
                          INPUT par_flgerlog,
                          INPUT TABLE tt-crapcje,
                         OUTPUT par_cdcritic,
                         OUTPUT par_dscritic,
                         OUTPUT TABLE tt-erro ) NO-ERROR.

                    IF  NOT RetornaErroReplica
                        ( INPUT crabttl.nrdconta,
                          INPUT "",
                          INPUT-OUTPUT par_dscritic ) THEN
                        UNDO Replica, LEAVE Replica.
                END.
                WHEN "DEPENDENTE" THEN DO:
                    IF  NOT VALID-HANDLE(h_rotinabase) THEN
                        RUN sistema/generico/procedures/b1wgen0047.p 
                            PERSISTENT SET h_rotinabase.

                    EMPTY TEMP-TABLE tta-dependente.

                    /* Buscar os dados existentes na conta filha */
                    RUN obtem-dependentes IN h_rotinabase
                        ( INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT par_cdoperad,
                          INPUT par_nmdatela,
                          INPUT par_idorigem,
                          INPUT crabttl.nrdconta,
                          INPUT crabttl.idseqttl,
                          INPUT NO,
                        OUTPUT aux_msgconta,
                        OUTPUT TABLE tta-dependente ) NO-ERROR.

                    IF  NOT RetornoErro( INPUT-OUTPUT par_dscritic ) THEN
                        UNDO Replica, LEAVE Replica.

                    IF  VALID-HANDLE(h_rotinabase) THEN
                        DELETE OBJECT h_rotinabase.

                    /* Sincroniza os dados existentes na conta filha */
                    RUN Replica_Dependente
                        ( INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT par_cdoperad,
                          INPUT par_nmdatela,
                          INPUT par_idorigem,
                          INPUT crabttl.nrdconta,
                          INPUT crabttl.idseqttl,
                          INPUT par_dtmvtolt,
                          INPUT "E", /*sincronizar/excluir os reg.existentes*/
                          INPUT par_flgerlog,
                          INPUT TABLE tta-dependente,
                         OUTPUT par_cdcritic,
                         OUTPUT par_dscritic,
                         OUTPUT aux_msgvalid,
                         OUTPUT TABLE tt-erro ) NO-ERROR.

                    IF  NOT RetornaErroReplica
                        ( INPUT crabttl.nrdconta,
                          INPUT aux_msgvalid,
                          INPUT-OUTPUT par_dscritic ) THEN
                        UNDO Replica, LEAVE Replica.
                    
                    /* Replicar os dados para as conta filha */
                    RUN Replica_Dependente
                        ( INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT par_cdoperad,
                          INPUT par_nmdatela,
                          INPUT par_idorigem,
                          INPUT crabttl.nrdconta,
                          INPUT crabttl.idseqttl,
                          INPUT par_dtmvtolt,
                          INPUT "I", /* replicar os dados p/conta filha */
                          INPUT par_flgerlog,
                          INPUT TABLE tt-dependente,
                         OUTPUT par_cdcritic,
                         OUTPUT par_dscritic,
                         OUTPUT aux_msgvalid,
                         OUTPUT TABLE tt-erro ) NO-ERROR.

                    IF  NOT RetornaErroReplica
                        ( INPUT crabttl.nrdconta,
                          INPUT aux_msgvalid,
                          INPUT-OUTPUT par_dscritic ) THEN
                        UNDO Replica, LEAVE Replica.
                END.
                WHEN "RESPONSAVEL" THEN DO:
                    IF  NOT VALID-HANDLE(h_rotinabase) THEN
                        RUN sistema/generico/procedures/b1wgen0072.p 
                            PERSISTENT SET h_rotinabase.

                    EMPTY TEMP-TABLE tta-crapcrl.
                    
                    /* Buscar os dados existentes na conta filha */
                    RUN Busca_Dados IN h_rotinabase
                        ( INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT par_cdoperad,
                          INPUT par_nmdatela,
                          INPUT par_idorigem,
                          INPUT crabttl.nrdconta,
                          INPUT crabttl.idseqttl,
                          INPUT NO,
                          INPUT par_dtmvtolt,
                          INPUT "C",
                          INPUT 0,
                          INPUT 0,
                          INPUT ?,
                          INPUT (IF crabttl.nrdconta = 0 THEN /*se nao for */
                                    crabttl.nrcpfcgc          /*coop passa */
                                 ELSE                         /*cpf */
                                    0),
                          INPUT "",
                          INPUT ?,
                          INPUT 0,
                          INPUT FALSE,
                        OUTPUT aux_menorida,
                        OUTPUT aux_msgconta,
                        OUTPUT TABLE tta-crapcrl,
                        OUTPUT TABLE tt-erro ) NO-ERROR.

                    IF  NOT RetornoErro( INPUT-OUTPUT par_dscritic ) THEN
                        UNDO Replica, LEAVE Replica.

                    IF  VALID-HANDLE(h_rotinabase) THEN
                        DELETE OBJECT h_rotinabase.

                    /* Sincroniza os dados existentes na conta filha */
                    RUN Replica_Responsavel
                        ( INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT par_cdoperad,
                          INPUT par_nmdatela,
                          INPUT par_idorigem,
                          INPUT par_nrdconta,
                          INPUT par_idseqttl,
                          INPUT crabttl.nrdconta,
                          INPUT crabttl.idseqttl,
                          INPUT par_dtmvtolt,
                          INPUT "E", /*sincronizar/excluir os reg.existentes*/
                          INPUT par_flgerlog,
                          INPUT TABLE tta-crapcrl,
                         OUTPUT par_cdcritic,
                         OUTPUT par_dscritic,
                         OUTPUT aux_msgvalid,
                         OUTPUT TABLE tt-erro ) NO-ERROR.

                    IF  NOT RetornaErroReplica
                        ( INPUT crabttl.nrdconta,
                          INPUT aux_msgvalid,
                          INPUT-OUTPUT par_dscritic ) THEN
                        UNDO Replica, LEAVE Replica.
                    
                    /* Replicar os dados para as conta filha */
                    RUN Replica_Responsavel
                        ( INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT par_cdoperad,
                          INPUT par_nmdatela,
                          INPUT par_idorigem,
                          INPUT par_nrdconta,
                          INPUT par_idseqttl,
                          INPUT crabttl.nrdconta,
                          INPUT crabttl.idseqttl,
                          INPUT par_dtmvtolt,
                          INPUT "I", /* replicar os dados p/conta filha */
                          INPUT par_flgerlog,
                          INPUT TABLE tt-crapcrl,
                         OUTPUT par_cdcritic,
                         OUTPUT par_dscritic,
                         OUTPUT aux_msgvalid,
                         OUTPUT TABLE tt-erro ) NO-ERROR.

                    IF  NOT RetornaErroReplica
                        ( INPUT crabttl.nrdconta,
                          INPUT aux_msgvalid,
                          INPUT-OUTPUT par_dscritic ) THEN
                        UNDO Replica, LEAVE Replica.
                END.

            END CASE.
        END.

        ASSIGN aux_returnvl = "OK".

        LEAVE Replica.
    END.

    IF  VALID-HANDLE(h_rotinabase) THEN
        DELETE OBJECT h_rotinabase.

    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        ASSIGN aux_returnvl = "NOK".

    RETURN aux_returnvl.

END PROCEDURE. /* Fim Replica_Dados */

/* ------------------------------------------------------------------------ */
/*   FILIACAO - REPLICACAO DOS DADOS DA CONTA PAI(PRIMEIRO TTL) P/ FILHAS   */
/* ------------------------------------------------------------------------ */
PROCEDURE Replica_Filiacao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGICAL                        NO-UNDO.
    DEF  INPUT PARAM TABLE FOR tt-filiacao. 

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_returnvl AS CHAR INITIAL "NOK"                      NO-UNDO.
    DEF VAR aux_nmdcampo AS CHAR                                    NO-UNDO.
    DEF VAR h_b1wgen0054 AS HANDLE                                  NO-UNDO.

    Filiacao: DO ON ERROR UNDO Filiacao, LEAVE Filiacao:

        FIND FIRST tt-filiacao NO-ERROR.

        IF  AVAILABLE tt-filiacao THEN 
            DO:

               IF  NOT VALID-HANDLE(h_b1wgen0054) THEN
                   RUN sistema/generico/procedures/b1wgen0054.p 
                       PERSISTENT SET h_b1wgen0054.

               RUN Valida_Dados IN h_b1wgen0054 
                   ( INPUT par_cdcooper,
                     INPUT par_cdagenci,
                     INPUT par_nrdcaixa,
                     INPUT par_cdoperad,
                     INPUT par_nmdatela,
                     INPUT par_idorigem,
                     INPUT par_nrdconta,
                     INPUT par_idseqttl,
                     INPUT par_flgerlog,
                     INPUT tt-filiacao.nmmaettl,
                     INPUT tt-filiacao.nmpaittl,
                    OUTPUT aux_nmdcampo,
                    OUTPUT TABLE tt-erro ).

               IF  RETURN-VALUE <> "OK" THEN DO:
                   UNDO Filiacao, LEAVE Filiacao.
               END.
               
               IF  VALID-HANDLE(h_b1wgen0054) THEN
                   DELETE OBJECT h_b1wgen0054.

               IF  NOT VALID-HANDLE(h_b1wgen0054) THEN
                   RUN sistema/generico/procedures/b1wgen0054.p 
                       PERSISTENT SET h_b1wgen0054.

               RUN Grava_Dados IN h_b1wgen0054
                   ( INPUT par_cdcooper,
                     INPUT par_cdagenci,
                     INPUT par_nrdcaixa,
                     INPUT par_cdoperad,
                     INPUT par_nmdatela,
                     INPUT par_idorigem,
                     INPUT par_nrdconta,
                     INPUT par_idseqttl,
                     INPUT par_flgerlog,
                     INPUT tt-filiacao.nmmaettl,
                     INPUT tt-filiacao.nmpaittl,
                     INPUT "A",
                     INPUT par_dtmvtolt,
                    OUTPUT aux_msgalert,
                    OUTPUT aux_tpatlcad,
                    OUTPUT aux_msgatcad,
                    OUTPUT aux_chavealt,
                    OUTPUT TABLE tt-erro ) NO-ERROR.

               IF  NOT RetornoErro( INPUT-OUTPUT par_dscritic ) THEN
                   UNDO Filiacao, LEAVE Filiacao.
            END.

        ASSIGN aux_returnvl = "OK".

        LEAVE Filiacao.
    END.

    IF  VALID-HANDLE(h_b1wgen0054) THEN
        DELETE OBJECT h_b1wgen0054.

    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        ASSIGN aux_returnvl = "NOK".

    RETURN aux_returnvl.

END PROCEDURE. /* Fim Replica_Filiacao */

/* ------------------------------------------------------------------------ */
/*   ENDERECO - REPLICACAO DOS DADOS DA CONTA PAI(PRIMEIRO TTL) P/ FILHAS   */
/* ------------------------------------------------------------------------ */
PROCEDURE Replica_Endereco:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGICAL                        NO-UNDO.
    DEF  INPUT PARAM TABLE FOR tt-endereco-cooperado.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_returnvl AS CHAR INITIAL "NOK"                      NO-UNDO.
    DEF VAR h_b1wgen0038 AS HANDLE                                  NO-UNDO.
    DEF VAR aux_msgrvcad AS CHAR                                    NO-UNDO.
    
    Endereco: DO ON ERROR UNDO Endereco, LEAVE Endereco:

        FIND FIRST tt-endereco-cooperado NO-ERROR.

        IF  AVAILABLE tt-endereco-cooperado THEN 
            DO:

               IF  NOT VALID-HANDLE(h_b1wgen0038) THEN
                   RUN sistema/generico/procedures/b1wgen0038.p 
                       PERSISTENT SET h_b1wgen0038.

               RUN validar-endereco IN h_b1wgen0038 
                   ( INPUT par_cdcooper,                   
                     INPUT par_cdagenci,                   
                     INPUT par_nrdcaixa,                   
                     INPUT par_cdoperad,                   
                     INPUT par_nmdatela,                   
                     INPUT par_idorigem,                   
                     INPUT par_nrdconta,                   
                     INPUT par_idseqttl,                   
                     INPUT tt-endereco-cooperado.incasprp, 
                     INPUT tt-endereco-cooperado.dtinires, 
                     INPUT tt-endereco-cooperado.vlalugue, 
                     INPUT tt-endereco-cooperado.dsendere, 
                     INPUT tt-endereco-cooperado.nrendere, 
                     INPUT tt-endereco-cooperado.nrcepend, 
                     INPUT tt-endereco-cooperado.complend, 
                     INPUT tt-endereco-cooperado.nrdoapto,
                     INPUT tt-endereco-cooperado.cddbloco,
                     INPUT tt-endereco-cooperado.nmbairro, 
                     INPUT tt-endereco-cooperado.nmcidade, 
                     INPUT tt-endereco-cooperado.cdufende, 
                     INPUT tt-endereco-cooperado.nrcxapst,
                     INPUT tt-endereco-cooperado.tpendass,
                     INPUT TRUE,
                     INPUT par_flgerlog,                   
                    OUTPUT TABLE tt-erro ).

               IF  VALID-HANDLE(h_b1wgen0038) THEN
                   DELETE OBJECT h_b1wgen0038.

               IF  RETURN-VALUE <> "OK" THEN DO:
                   UNDO Endereco, LEAVE Endereco.
               END.

               IF  NOT VALID-HANDLE(h_b1wgen0038) THEN
                   RUN sistema/generico/procedures/b1wgen0038.p 
                       PERSISTENT SET h_b1wgen0038.

               RUN alterar-endereco IN h_b1wgen0038
                   ( INPUT par_cdcooper,                    
                     INPUT par_cdagenci,                    
                     INPUT par_nrdcaixa,                    
                     INPUT par_cdoperad,                    
                     INPUT par_nmdatela,                    
                     INPUT par_idorigem,                    
                     INPUT par_nrdconta,                    
                     INPUT par_idseqttl,                    
                     INPUT "A",                             
                     INPUT par_dtmvtolt,                    
                     INPUT tt-endereco-cooperado.incasprp,  
                     INPUT tt-endereco-cooperado.dtinires,  
                     INPUT tt-endereco-cooperado.vlalugue,  
                     INPUT tt-endereco-cooperado.dsendere,  
                     INPUT tt-endereco-cooperado.nrendere,  
                     INPUT tt-endereco-cooperado.nrcepend,  
                     INPUT tt-endereco-cooperado.complend, 
                     INPUT tt-endereco-cooperado.nrdoapto, 
                     INPUT tt-endereco-cooperado.cddbloco, 
                     INPUT tt-endereco-cooperado.nmbairro,  
                     INPUT tt-endereco-cooperado.nmcidade,  
                     INPUT tt-endereco-cooperado.cdufende,  
                     INPUT tt-endereco-cooperado.nrcxapst, 
                     INPUT tt-endereco-cooperado.qtprebem,
                     INPUT tt-endereco-cooperado.vlprebem,
                     INPUT 0,
                     INPUT par_flgerlog,                    
                     INPUT tt-endereco-cooperado.idorigem,
                    OUTPUT aux_msgalert,
                    OUTPUT aux_tpatlcad,
                    OUTPUT aux_msgatcad,
                    OUTPUT aux_chavealt,
                    OUTPUT aux_msgrvcad,
                    OUTPUT TABLE tt-erro ) NO-ERROR.
    
               IF  NOT RetornoErro( INPUT-OUTPUT par_dscritic ) THEN
                   UNDO Endereco, LEAVE Endereco.
            END.

        ASSIGN aux_returnvl = "OK".

        LEAVE Endereco.
    END.

    IF  VALID-HANDLE(h_b1wgen0038) THEN
        DELETE OBJECT h_b1wgen0038.

    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        ASSIGN aux_returnvl = "NOK".

    RETURN aux_returnvl.

END PROCEDURE. /* Fim Replica_Endereco */

/* ------------------------------------------------------------------------ */
/*   COMERCIAL - REPLICACAO DOS DADOS DA CONTA PAI(PRIMEIRO TTL) P/ FILHAS  */
/* ------------------------------------------------------------------------ */
PROCEDURE Replica_Comercial:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGICAL                        NO-UNDO.
    DEF  INPUT PARAM TABLE FOR tt-comercial.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_msgrvcad AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmdcampo AS CHAR                                    NO-UNDO.
    DEF VAR aux_returnvl AS CHAR INITIAL "NOK"                      NO-UNDO.
    DEF VAR aux_nrdrowid AS ROWID                                   NO-UNDO.
    DEF VAR h_b1wgen0075 AS HANDLE                                  NO-UNDO.
    
    Comercial: DO ON ERROR UNDO Comercial, LEAVE Comercial:

        FIND FIRST tt-comercial NO-ERROR.

        IF  AVAILABLE tt-comercial THEN
            DO:
               IF  NOT VALID-HANDLE(h_b1wgen0075) THEN
                   RUN sistema/generico/procedures/b1wgen0075.p 
                       PERSISTENT SET h_b1wgen0075.
               
               ASSIGN  aux_nrdrowid = ?.

               FOR FIRST crapttl WHERE crapttl.cdcooper = par_cdcooper AND 
                                       crapttl.nrdconta = par_nrdconta AND
                                       crapttl.idseqttl = par_idseqttl NO-LOCK:
                   ASSIGN aux_nrdrowid = ROWID(crapttl).
               END.

               RUN Valida_Dados IN h_b1wgen0075
                  ( INPUT par_cdcooper,                 
                    INPUT par_cdagenci,                 
                    INPUT par_nrdcaixa,                 
                    INPUT par_cdoperad,                 
                    INPUT par_nmdatela,                 
                    INPUT par_idorigem,                 
                    INPUT par_nrdconta,                 
                    INPUT par_idseqttl,                 
                    INPUT par_flgerlog,                 
                    INPUT par_dtmvtolt,                 
                    INPUT "A",                          
                    INPUT tt-comercial.cdnatopc,        
                    INPUT tt-comercial.cdocpttl,        
                    INPUT tt-comercial.tpcttrab,        
                    INPUT tt-comercial.cdempres,        
                    INPUT tt-comercial.nmextemp,        
                    INPUT tt-comercial.nrcpfemp,        
                    INPUT tt-comercial.dsproftl,        
                    INPUT tt-comercial.cdnvlcgo,        
                    INPUT tt-comercial.nrcadast,        
                    INPUT tt-comercial.ufresct1,        
                    INPUT tt-comercial.cdturnos,        
                    INPUT tt-comercial.dtadmemp,        
                    INPUT tt-comercial.vlsalari,        
                    INPUT tt-comercial.tpdrendi[1],     
                    INPUT tt-comercial.vldrendi[1],     
                    INPUT tt-comercial.tpdrendi[2],     
                    INPUT tt-comercial.tpdrendi[2],     
                    INPUT tt-comercial.tpdrendi[3],     
                    INPUT tt-comercial.vldrendi[3],     
                    INPUT tt-comercial.vldrendi[4],     
                    INPUT tt-comercial.vldrendi[4],     
                    INPUT tt-comercial.cepedct1,
                    INPUT tt-comercial.endrect1,
                    INPUT tt-comercial.inpolexp,
                   OUTPUT aux_nmdcampo,                 
                   OUTPUT TABLE tt-erro ).              

               IF  VALID-HANDLE(h_b1wgen0075) THEN
                   DELETE OBJECT h_b1wgen0075.

               IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
                   DO:
                       UNDO Comercial, LEAVE Comercial.
                   END.

               IF  NOT VALID-HANDLE(h_b1wgen0075) THEN
                   RUN sistema/generico/procedures/b1wgen0075.p 
                       PERSISTENT SET h_b1wgen0075.

               RUN Grava_Dados IN h_b1wgen0075
                   ( INPUT par_cdcooper,            
                     INPUT par_cdagenci,            
                     INPUT par_nrdcaixa,            
                     INPUT par_cdoperad,            
                     INPUT par_nmdatela,            
                     INPUT par_idorigem,            
                     INPUT par_nrdconta,            
                     INPUT par_idseqttl,            
                     INPUT par_flgerlog,            
                     INPUT "A",                     
                     INPUT par_dtmvtolt,            
                     INPUT aux_nrdrowid,            
                     INPUT tt-comercial.cdnatopc,   
                     INPUT tt-comercial.cdocpttl,   
                     INPUT tt-comercial.tpcttrab,   
                     INPUT tt-comercial.cdempres,   
                     INPUT tt-comercial.nmextemp,   
                     INPUT tt-comercial.nrcpfemp,   
                     INPUT tt-comercial.dsproftl,   
                     INPUT tt-comercial.cdnvlcgo,   
                     INPUT tt-comercial.nrcadast,   
                     INPUT tt-comercial.ufresct1,   
                     INPUT tt-comercial.endrect1,   
                     INPUT tt-comercial.bairoct1,   
                     INPUT tt-comercial.cidadct1,   
                     INPUT tt-comercial.complcom,   
                     INPUT tt-comercial.cepedct1,   
                     INPUT tt-comercial.cxpotct1,   
                     INPUT tt-comercial.cdturnos,   
                     INPUT tt-comercial.dtadmemp,   
                     INPUT tt-comercial.vlsalari,   
                     INPUT "",   
                     INPUT tt-comercial.nrendcom,   
                     INPUT tt-comercial.tpdrendi[1],
                     INPUT tt-comercial.vldrendi[1],
                     INPUT tt-comercial.tpdrendi[2],
                     INPUT tt-comercial.tpdrendi[3],
                     INPUT tt-comercial.tpdrendi[4],
                     INPUT tt-comercial.vldrendi[2],
                     INPUT tt-comercial.vldrendi[3],
                     INPUT tt-comercial.vldrendi[4],
                     INPUT tt-comercial.inpolexp,
                    OUTPUT aux_tpatlcad,
                    OUTPUT aux_msgatcad,
                    OUTPUT aux_chavealt,
                    OUTPUT aux_msgrvcad,
                    OUTPUT aux_cotcance,
                    OUTPUT TABLE tt-erro ) NO-ERROR.

               IF  NOT RetornoErro( INPUT-OUTPUT par_dscritic ) THEN
                   UNDO Comercial, LEAVE Comercial.
            END.

        ASSIGN aux_returnvl = "OK".

        LEAVE Comercial.
    END.

    IF  VALID-HANDLE(h_b1wgen0075) THEN
        DELETE OBJECT h_b1wgen0075.

    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        ASSIGN aux_returnvl = "NOK".

    RETURN aux_returnvl.

END PROCEDURE. /* Fim Replica_Comercial */

/* ------------------------------------------------------------------------ */
/*  BENS - SINCRONIZA/REPLICA OS DADOS DA CONTA PAI(PRIMEIRO TTL) P/ FILHAS */
/* ------------------------------------------------------------------------ */
PROCEDURE Replica_Bens:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_operacao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGICAL                        NO-UNDO.
    DEF  INPUT PARAM TABLE FOR tta-crapbem.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_auxmensg AS CHAR INITIAL ""                NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_returnvl AS CHAR INITIAL "NOK"                      NO-UNDO.
    DEF VAR aux_msgrvcad AS CHAR                                    NO-UNDO.
    DEF VAR h_b1wgen0056 AS HANDLE                                  NO-UNDO.
    
    Bens: DO ON ERROR UNDO Bens, LEAVE Bens:

        FOR EACH tta-crapbem:

            IF  NOT VALID-HANDLE(h_b1wgen0056) THEN
                RUN sistema/generico/procedures/b1wgen0056.p 
                    PERSISTENT SET h_b1wgen0056.

            RUN Valida-Dados IN h_b1wgen0056 
                ( INPUT par_cdcooper,
                  INPUT par_cdagenci,
                  INPUT par_nrdcaixa,
                  INPUT par_nrdconta,
                  INPUT par_idorigem,
                  INPUT par_nmdatela,
                  INPUT par_idseqttl,
                  INPUT par_cdoperad,
                  INPUT (IF par_operacao = "S" THEN "E" ELSE "I"),
                  INPUT tta-crapbem.dsrelbem,
                  INPUT tta-crapbem.persemon,
                  INPUT tta-crapbem.qtprebem,
                  INPUT tta-crapbem.vlprebem,
                  INPUT tta-crapbem.vlrdobem,
                  INPUT tta-crapbem.idseqbem,
                 OUTPUT TABLE tt-erro ).

            IF  VALID-HANDLE(h_b1wgen0056) THEN
                DELETE OBJECT h_b1wgen0056.
            
            IF  RETURN-VALUE <> "OK" THEN
                DO:
                    IF  par_operacao = "R"  THEN
                        ASSIGN par_auxmensg = "bem " + CAPS(dsrelbem) .
                    UNDO Bens, LEAVE Bens.
                END.
                   
            IF  NOT VALID-HANDLE(h_b1wgen0056) THEN
                RUN sistema/generico/procedures/b1wgen0056.p 
                    PERSISTENT SET h_b1wgen0056.

            CASE par_operacao:
                WHEN "S" THEN DO:
                    /* Operacao de sincronizacao/limpeza */
                    RUN exclui-registro IN h_b1wgen0056
                        ( INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT par_cdoperad,
                          INPUT par_nrdconta,
                          INPUT par_idseqttl,
                          INPUT tta-crapbem.nrdrowid,
                          INPUT tta-crapbem.idseqbem,
                          INPUT par_nmdatela,
                          INPUT par_idorigem,
                          INPUT par_flgerlog,
                          INPUT par_dtmvtolt,
                          INPUT "E",
                        OUTPUT aux_msgalert,
                        OUTPUT aux_tpatlcad,
                        OUTPUT aux_msgatcad,
                        OUTPUT aux_chavealt,
                        OUTPUT aux_msgrvcad,
                        OUTPUT TABLE tt-erro ) NO-ERROR. 

                    IF  NOT RetornoErro( INPUT-OUTPUT par_dscritic ) THEN
                        UNDO Bens, LEAVE Bens.
                END.
                WHEN "R" THEN DO:
                    
                    /* Operacao de inclusão/replicacao */
                    RUN inclui-registro IN h_b1wgen0056
                        ( INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT par_nrdconta,
                          INPUT par_idseqttl,
                          INPUT par_cdoperad,
                          INPUT par_nmdatela,
                          INPUT par_idorigem,
                          INPUT par_flgerlog,
                          INPUT tta-crapbem.dsrelbem,
                          INPUT ?,
                          INPUT par_dtmvtolt,
                          INPUT "I",
                          INPUT tta-crapbem.persemon,
                          INPUT tta-crapbem.qtprebem,
                          INPUT tta-crapbem.vlprebem,
                          INPUT tta-crapbem.vlrdobem,
                         OUTPUT aux_msgalert,
                         OUTPUT aux_tpatlcad,
                         OUTPUT aux_msgatcad,
                         OUTPUT aux_chavealt,
                         OUTPUT aux_msgrvcad,
                         OUTPUT TABLE tt-erro ) NO-ERROR.

                    IF  NOT RetornoErro( INPUT-OUTPUT par_dscritic ) THEN
                        UNDO Bens, LEAVE Bens.
                END.
            END CASE.

            IF  VALID-HANDLE(h_b1wgen0056) THEN
                DELETE OBJECT h_b1wgen0056.
        END.

        ASSIGN aux_returnvl = "OK".

        LEAVE Bens.
    END.

    IF  VALID-HANDLE(h_b1wgen0056) THEN
        DELETE OBJECT h_b1wgen0056.

    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        ASSIGN aux_returnvl = "NOK".

    RETURN aux_returnvl.

END PROCEDURE. /* Fim Replica_Bens */

/* ------------------------------------------------------------------------ */
/*   TELEFONE - REPLICACAO DOS DADOS DA CONTA PAI(PRIMEIRO TTL) P/ FILHAS   */
/* ------------------------------------------------------------------------ */
PROCEDURE Replica_Telefone:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctarep AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_operacao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGICAL                        NO-UNDO.
    DEF  INPUT PARAM TABLE FOR tta-telefone-cooperado.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_auxmensg AS CHAR INITIAL ""                NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_returnvl AS CHAR INITIAL "NOK"                      NO-UNDO.
    DEF VAR h_b1wgen0070 AS HANDLE                                  NO-UNDO.
    DEF VAR aux_nrdrowid AS ROWID                                   NO-UNDO.
    DEF VAR aux_inpessoa AS CHAR                                    NO-UNDO.
    DEF VAR aux_msgrvcad AS CHAR                                    NO-UNDO.
   
    Telefone: DO ON ERROR UNDO Telefone, LEAVE Telefone:
        
        FOR EACH tta-telefone-cooperado:

            IF  NOT VALID-HANDLE(h_b1wgen0070) THEN
                RUN sistema/generico/procedures/b1wgen0070.p 
                    PERSISTENT SET h_b1wgen0070.

            ASSIGN aux_nrdrowid = IF par_operacao = "I" THEN ? 
                                  ELSE tta-telefone-cooperado.nrdrowid.

            
            IF par_operacao <> "E" THEN DO:
    
                RUN validar-telefone IN h_b1wgen0070 
                    ( INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT par_cdoperad,
                      INPUT par_nmdatela,
                      INPUT par_idorigem,
                      INPUT par_nrdconta,
                      INPUT par_idseqttl,                       
                      INPUT par_operacao,
                      INPUT aux_nrdrowid,
                      INPUT tta-telefone-cooperado.tptelefo,
                      INPUT tta-telefone-cooperado.nrdddtfc,
                      INPUT tta-telefone-cooperado.nrtelefo,
                      INPUT tta-telefone-cooperado.nrdramal,
                      INPUT tta-telefone-cooperado.secpscto,
                      INPUT tta-telefone-cooperado.nmpescto,
                      INPUT tta-telefone-cooperado.cdopetfn,
                      INPUT par_flgerlog,
                      INPUT par_nrctarep, /* Conta replicadora */
                     OUTPUT TABLE tt-erro).

            END.

            IF  VALID-HANDLE(h_b1wgen0070) THEN
                DELETE OBJECT h_b1wgen0070.
            
            IF  RETURN-VALUE <> "OK"  THEN
                DO: 
                    IF  par_operacao = "I"  THEN
                        ASSIGN par_auxmensg = "telefone " + 
                                       STRING(tta-telefone-cooperado.nrtelefo).
                    UNDO Telefone, LEAVE Telefone.
                END.

            IF  NOT VALID-HANDLE(h_b1wgen0070) THEN
                RUN sistema/generico/procedures/b1wgen0070.p 
                    PERSISTENT SET h_b1wgen0070. 

            /* E=Exclui registros existentes - I=Inclui conf.conta pai */
            RUN gerenciar-telefone IN h_b1wgen0070 
                ( INPUT par_cdcooper,
                  INPUT par_cdagenci,
                  INPUT par_nrdcaixa,
                  INPUT par_cdoperad,
                  INPUT par_nmdatela,
                  INPUT par_idorigem,
                  INPUT par_nrdconta,
                  INPUT par_idseqttl,
                  INPUT par_operacao,
                  INPUT par_dtmvtolt,
                  INPUT aux_nrdrowid,
                  INPUT tta-telefone-cooperado.tptelefo,
                  INPUT tta-telefone-cooperado.nrdddtfc,
                  INPUT tta-telefone-cooperado.nrtelefo,
                  INPUT tta-telefone-cooperado.nrdramal,
                  INPUT tta-telefone-cooperado.secpscto,
                  INPUT tta-telefone-cooperado.nmpescto,
                  INPUT tta-telefone-cooperado.cdopetfn,
                  INPUT "A",
                  INPUT par_flgerlog,
                  INPUT tta-telefone-cooperado.idsittfc,
                  INPUT tta-telefone-cooperado.idorigem,
                 OUTPUT aux_tpatlcad,
                 OUTPUT aux_msgatcad,
                 OUTPUT aux_chavealt,
                 OUTPUT aux_msgrvcad,
                 OUTPUT TABLE tt-erro ) NO-ERROR.
            
            IF  NOT RetornoErro( INPUT-OUTPUT par_dscritic ) THEN
                UNDO Telefone, LEAVE Telefone.

            IF  VALID-HANDLE(h_b1wgen0070) THEN
                DELETE OBJECT h_b1wgen0070.
        END.

        ASSIGN aux_returnvl = "OK".

        LEAVE Telefone.
    END.

    IF  VALID-HANDLE(h_b1wgen0070) THEN
        DELETE OBJECT h_b1wgen0070.

    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        ASSIGN aux_returnvl = "NOK".

    RETURN aux_returnvl.

END PROCEDURE. /* Fim Replica_Telefone */

/* ------------------------------------------------------------------------ */
/*     EMAIL - REPLICACAO DOS DADOS DA CONTA PAI(PRIMEIRO TTL) P/ FILHAS    */
/* ------------------------------------------------------------------------ */
PROCEDURE Replica_Email:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctarep AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_operacao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGICAL                        NO-UNDO.
    DEF  INPUT PARAM TABLE FOR tta-email-cooperado.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_auxmensg AS CHAR INITIAL ""                NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_msgrvcad AS CHAR                                    NO-UNDO.
    DEF VAR aux_returnvl AS CHAR INITIAL "NOK"                      NO-UNDO.
    DEF VAR h_b1wgen0071 AS HANDLE                                  NO-UNDO.

    Email: DO ON ERROR UNDO Email, LEAVE Email:

        FOR EACH tta-email-cooperado:

            IF  NOT VALID-HANDLE(h_b1wgen0071) THEN
                RUN sistema/generico/procedures/b1wgen0071.p 
                    PERSISTENT SET h_b1wgen0071.

            RUN validar-email IN h_b1wgen0071 
                ( INPUT par_cdcooper,
                  INPUT par_cdagenci,
                  INPUT par_nrdcaixa,
                  INPUT par_cdoperad,
                  INPUT par_nmdatela,
                  INPUT par_idorigem,
                  INPUT par_nrdconta,
                  INPUT par_idseqttl,
                  INPUT par_operacao,
                  INPUT tta-email-cooperado.nrdrowid,
                  INPUT tta-email-cooperado.dsdemail,
                  INPUT tta-email-cooperado.secpscto,
                  INPUT tta-email-cooperado.nmpescto,
                  INPUT par_flgerlog,
                  INPUT par_nrctarep,
                 OUTPUT TABLE tt-erro).

            IF  VALID-HANDLE(h_b1wgen0071) THEN
                DELETE OBJECT h_b1wgen0071.

            IF  RETURN-VALUE <> "OK"  THEN
                DO:
                    IF  par_operacao = "I"  THEN
                        ASSIGN par_auxmensg = "email " + 
                                          tta-email-cooperado.dsdemail.
                    UNDO Email, LEAVE Email.
                END.

            IF  NOT VALID-HANDLE(h_b1wgen0071) THEN
                RUN sistema/generico/procedures/b1wgen0071.p 
                    PERSISTENT SET h_b1wgen0071.

            /* E=Exclui registros existentes - I=Inclui conf.conta pai */
            RUN gerenciar-email IN h_b1wgen0071 
                ( INPUT par_cdcooper,
                  INPUT par_cdagenci,
                  INPUT par_nrdcaixa,
                  INPUT par_cdoperad,
                  INPUT par_nmdatela,
                  INPUT par_idorigem,
                  INPUT par_nrdconta,
                  INPUT par_idseqttl,
                  INPUT par_operacao,
                  INPUT par_dtmvtolt,
                  INPUT tta-email-cooperado.nrdrowid,
                  INPUT tta-email-cooperado.dsdemail,
                  INPUT tta-email-cooperado.secpscto,
                  INPUT tta-email-cooperado.nmpescto,
                  INPUT "A",
                  INPUT par_flgerlog,
                 OUTPUT aux_tpatlcad,
                 OUTPUT aux_msgatcad,
                 OUTPUT aux_chavealt,
                 OUTPUT aux_msgrvcad,
                 OUTPUT TABLE tt-erro ) NO-ERROR.

            IF  NOT RetornoErro( INPUT-OUTPUT par_dscritic ) THEN
                UNDO Email, LEAVE Email.

            IF  VALID-HANDLE(h_b1wgen0071) THEN
                DELETE OBJECT h_b1wgen0071.
        END.

        ASSIGN aux_returnvl = "OK".

        LEAVE Email.
    END.

    IF  VALID-HANDLE(h_b1wgen0071) THEN
        DELETE OBJECT h_b1wgen0071.

    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        ASSIGN aux_returnvl = "NOK".

    RETURN aux_returnvl.

END PROCEDURE. /* Fim Replica_Email */

/* ------------------------------------------------------------------------ */
/*    CONJUGE - REPLICACAO DOS DADOS DA CONTA PAI(PRIMEIRO TTL) P/ FILHAS   */
/* ------------------------------------------------------------------------ */
PROCEDURE Replica_Conjuge:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_operacao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGICAL                        NO-UNDO.
    DEF  INPUT PARAM TABLE FOR tt-crapcje. 

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_msgrvcad AS CHAR                                    NO-UNDO.
    DEF VAR aux_returnvl AS CHAR INITIAL "NOK"                      NO-UNDO.
    DEF VAR h_b1wgen0057 AS HANDLE                                  NO-UNDO.

    Conjuge: DO ON ERROR UNDO Conjuge, LEAVE Conjuge:

        IF  NOT VALID-HANDLE(h_b1wgen0057) THEN
            RUN sistema/generico/procedures/b1wgen0057.p 
                PERSISTENT SET h_b1wgen0057.

        FIND FIRST tt-crapcje NO-ERROR.

        RUN Valida_Dados IN h_b1wgen0057
            (INPUT par_cdcooper,
             INPUT par_cdagenci,
             INPUT par_nrdcaixa,
             INPUT par_cdoperad,
             INPUT par_nmdatela,
             INPUT par_idorigem,
             INPUT par_nrdconta,
             INPUT par_idseqttl,
             INPUT par_flgerlog,
             INPUT tt-crapcje.nrcpfcjg,  
             INPUT tt-crapcje.nmconjug,  
             INPUT tt-crapcje.dtnasccj,  
             INPUT tt-crapcje.tpdoccje,
             INPUT tt-crapcje.cdufdcje,
             INPUT tt-crapcje.grescola,
             INPUT tt-crapcje.cdfrmttl,
             INPUT tt-crapcje.cdnatopc,
             INPUT tt-crapcje.cdocpcje,
             INPUT tt-crapcje.tpcttrab,
             INPUT tt-crapcje.nmextemp,
             INPUT tt-crapcje.nrdocnpj,
             INPUT tt-crapcje.dsproftl,
             INPUT tt-crapcje.cdnvlcgo,
             INPUT tt-crapcje.cdturnos,
             INPUT tt-crapcje.dtadmemp,
             INPUT tt-crapcje.nrctacje,
            OUTPUT TABLE tt-erro).

        IF  VALID-HANDLE(h_b1wgen0057) THEN
            DELETE OBJECT h_b1wgen0057.

        IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
            DO:
                UNDO Conjuge, LEAVE Conjuge.
            END.

        IF  NOT VALID-HANDLE(h_b1wgen0057) THEN
            RUN sistema/generico/procedures/b1wgen0057.p 
                PERSISTENT SET h_b1wgen0057.

        IF  AVAILABLE tt-crapcje THEN 
            DO:
               RUN Grava_Dados IN h_b1wgen0057
                   ( INPUT par_cdcooper,
                     INPUT par_cdagenci,
                     INPUT par_nrdcaixa,
                     INPUT par_cdoperad,
                     INPUT par_nmdatela,
                     INPUT par_idorigem,
                     INPUT par_nrdconta,
                     INPUT par_idseqttl,
                     INPUT par_flgerlog,
                     INPUT tt-crapcje.nrctacje,
                     INPUT tt-crapcje.nrcpfcjg,
                     INPUT tt-crapcje.nmconjug,
                     INPUT tt-crapcje.dtnasccj,
                     INPUT tt-crapcje.tpdoccje,
                     INPUT tt-crapcje.nrdoccje,
                     INPUT tt-crapcje.cdoedcje,
                     INPUT tt-crapcje.cdufdcje,
                     INPUT tt-crapcje.dtemdcje,
                     INPUT tt-crapcje.grescola,
                     INPUT tt-crapcje.cdfrmttl,
                     INPUT tt-crapcje.cdnatopc,
                     INPUT tt-crapcje.cdocpcje,
                     INPUT tt-crapcje.tpcttrab,
                     INPUT tt-crapcje.nmextemp,
                     INPUT tt-crapcje.nrdocnpj,
                     INPUT tt-crapcje.dsproftl,
                     INPUT tt-crapcje.cdnvlcgo,
                     INPUT tt-crapcje.nrfonemp,
                     INPUT tt-crapcje.nrramemp,
                     INPUT tt-crapcje.cdturnos,
                     INPUT tt-crapcje.dtadmemp,
                     INPUT tt-crapcje.vlsalari,
                     INPUT par_dtmvtolt,
                     INPUT par_operacao,
                    OUTPUT aux_tpatlcad,
                    OUTPUT aux_msgatcad,
                    OUTPUT aux_chavealt,
                    OUTPUT aux_msgrvcad,
                    OUTPUT TABLE tt-erro ) NO-ERROR.

               IF  NOT RetornoErro( INPUT-OUTPUT par_dscritic ) THEN
                   UNDO Conjuge, LEAVE Conjuge.
            END.

        ASSIGN aux_returnvl = "OK".

        LEAVE Conjuge.
    END.

    IF  VALID-HANDLE(h_b1wgen0057) THEN
        DELETE OBJECT h_b1wgen0057.

    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        ASSIGN aux_returnvl = "NOK".

    RETURN aux_returnvl.

END PROCEDURE. /* Fim Replica_Conjuge */

/* ------------------------------------------------------------------------ */
/* DEPENDENTES - REPLICACAO DOS DADOS DA CONTA PAI(PRIMEIRO TTL) P/ FILHAS  */
/* ------------------------------------------------------------------------ */
PROCEDURE Replica_Dependente:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_operacao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGICAL                        NO-UNDO.
    DEF  INPUT PARAM TABLE FOR tta-dependente.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_auxmensg AS CHAR INITIAL ""                NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_returnvl AS CHAR INITIAL "NOK"                      NO-UNDO.
    DEF VAR aux_msgrecad AS CHAR                                    NO-UNDO.
    DEF VAR h_b1wgen0047 AS HANDLE                                  NO-UNDO.

    Dependente: DO ON ERROR UNDO Dependente, LEAVE Dependente:

        FOR EACH tta-dependente:

            IF  NOT VALID-HANDLE(h_b1wgen0047) THEN
                RUN sistema/generico/procedures/b1wgen0047.p 
                    PERSISTENT SET h_b1wgen0047.

            RUN valida-operacao IN h_b1wgen0047 
                ( INPUT par_cdcooper,
                  INPUT par_cdagenci,
                  INPUT par_nrdcaixa,
                  INPUT par_cdoperad,
                  INPUT par_nmdatela,
                  INPUT par_idorigem,
                  INPUT par_nrdconta,
                  INPUT par_idseqttl,
                  INPUT par_dtmvtolt,
                  INPUT par_operacao,
                  INPUT tta-dependente.nrdrowid,
                  INPUT tta-dependente.nmdepend,
                  INPUT tta-dependente.dtnascto,
                  INPUT tta-dependente.cdtipdep,
                  INPUT par_flgerlog,
                 OUTPUT TABLE tt-erro ).

            IF  VALID-HANDLE(h_b1wgen0047) THEN
                DELETE OBJECT h_b1wgen0047.
                                                    
            IF  RETURN-VALUE <> "OK"  THEN 
                DO:
                    IF  par_operacao = "I"  THEN
                        ASSIGN par_auxmensg = "dependente " + 
                                          CAPS(tta-dependente.nmdepend).
                    UNDO Dependente, LEAVE Dependente.
                END.

            IF  NOT VALID-HANDLE(h_b1wgen0047) THEN
                RUN sistema/generico/procedures/b1wgen0047.p 
                    PERSISTENT SET h_b1wgen0047.

            /* E=Exclui registros existentes - I=Inclui conf.conta pai */
            RUN gerenciar-dependente IN h_b1wgen0047 
                ( INPUT par_cdcooper,
                  INPUT par_cdagenci,
                  INPUT par_nrdcaixa,
                  INPUT par_cdoperad,
                  INPUT par_nmdatela,
                  INPUT par_idorigem,
                  INPUT par_nrdconta,
                  INPUT par_idseqttl,
                  INPUT par_dtmvtolt,
                  INPUT par_operacao,
                  INPUT tta-dependente.nrdrowid,
                  INPUT tta-dependente.nmdepend,
                  INPUT tta-dependente.dtnascto,
                  INPUT tta-dependente.cdtipdep,
                  INPUT par_flgerlog,
                 OUTPUT aux_tpatlcad,
                 OUTPUT aux_msgatcad,
                 OUTPUT aux_chavealt,
                 OUTPUT aux_msgrecad,
                 OUTPUT TABLE tt-erro ) NO-ERROR.

            IF  NOT RetornoErro( INPUT-OUTPUT par_dscritic ) THEN
                UNDO Dependente, LEAVE Dependente.

            IF  VALID-HANDLE(h_b1wgen0047) THEN
                DELETE OBJECT h_b1wgen0047.
        END.

        ASSIGN aux_returnvl = "OK".

        LEAVE Dependente.
    END.

    IF  VALID-HANDLE(h_b1wgen0047) THEN
        DELETE OBJECT h_b1wgen0047.

    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        ASSIGN aux_returnvl = "NOK".

    RETURN aux_returnvl.

END PROCEDURE. /* Fim Replica_Dependente */

/* ------------------------------------------------------------------------ */
/*  RESPONSAVEL LEGAL - REPLICA DADOS DA CONTA PAI(PRIMEIRO TTL) P/ FILHAS  */
/* ------------------------------------------------------------------------ */
PROCEDURE Replica_Responsavel:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdctato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqcta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_operacao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGICAL                        NO-UNDO.
    DEF  INPUT PARAM TABLE FOR tta-crapcrl.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_auxmensg AS CHAR INITIAL ""                NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF  VAR aux_nrdrowid AS ROWID                                  NO-UNDO.
    DEF  VAR aux_nrdctato AS DEC                                    NO-UNDO.
    DEF  VAR aux_nrcpfcto AS DEC                                    NO-UNDO.
    DEF  VAR aux_nmdavali AS CHAR                                   NO-UNDO.
    DEF  VAR aux_tpdocava AS CHAR                                   NO-UNDO.
    DEF  VAR aux_nrdocava AS CHAR                                   NO-UNDO.
    DEF  VAR aux_cdoeddoc AS CHAR                                   NO-UNDO.
    DEF  VAR aux_cdufddoc AS CHAR                                   NO-UNDO.
    DEF  VAR aux_dtemddoc AS DATE                                   NO-UNDO.
    DEF  VAR aux_dtnascto AS DATE                                   NO-UNDO.
    DEF  VAR aux_cdsexcto AS INTE                                   NO-UNDO.
    DEF  VAR aux_cdestcvl AS INTE                                   NO-UNDO.
    DEF  VAR aux_cdnacion AS INTE                                   NO-UNDO.
    DEF  VAR aux_dsnatura AS CHAR                                   NO-UNDO.
    DEF  VAR aux_nrcepend AS INTE                                   NO-UNDO.
    DEF  VAR aux_dsendere AS CHAR                                   NO-UNDO.
    DEF  VAR aux_nmbairro AS CHAR                                   NO-UNDO.
    DEF  VAR aux_nmcidade AS CHAR                                   NO-UNDO.
    DEF  VAR aux_nrendere AS INTE                                   NO-UNDO.
    DEF  VAR aux_cdufende AS CHAR                                   NO-UNDO.
    DEF  VAR aux_complend AS CHAR                                   NO-UNDO.
    DEF  VAR aux_nrcxapst AS INTE                                   NO-UNDO.
    DEF  VAR aux_nmmaecto AS CHAR                                   NO-UNDO.
    DEF  VAR aux_nmpaicto AS CHAR                                   NO-UNDO.
    DEF  VAR aux_cpfprocu AS DEC                                    NO-UNDO.
    DEF  VAR aux_cdrlcrsp AS INTE                                   NO-UNDO.
    DEF  VAR aux_nmrotina AS CHAR                                   NO-UNDO.

    DEF VAR aux_returnvl AS CHAR INITIAL "NOK"                      NO-UNDO.
    DEF VAR h_b1wgen0072 AS HANDLE                                  NO-UNDO.
    DEF VAR aux_menorida AS CHAR                                    NO-UNDO.
    DEF VAR aux_msgconta AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmdcampo AS CHAR                                    NO-UNDO.
    
    Responsavel: DO ON ERROR UNDO Responsavel, LEAVE Responsavel:
        
        FOR EACH tta-crapcrl:
            
            IF  NOT VALID-HANDLE(h_b1wgen0072) THEN
                RUN sistema/generico/procedures/b1wgen0072.p 
                    PERSISTENT SET h_b1wgen0072.

            IF par_operacao = "I"  THEN
                DO:               
                    RUN Busca_Dados IN h_b1wgen0072
                        ( INPUT par_cdcooper,                  
                          INPUT par_cdagenci,                  
                          INPUT par_nrdcaixa,                  
                          INPUT par_cdoperad,                  
                          INPUT par_nmdatela,                  
                          INPUT par_idorigem,                  
                          INPUT par_nrdconta,                  
                          INPUT par_idseqttl,                  
                          INPUT NO,                            
                          INPUT par_dtmvtolt,                  
                          INPUT "C",                           
                          INPUT tta-crapcrl.nrdconta,          
                          INPUT (IF tta-crapcrl.nrdconta = 0 THEN /*se nao for*/
                                    tta-crapcrl.nrcpfcgc          /*coop passa*/
                                 ELSE                             /*cpf */
                                    0),          
                          INPUT tta-crapcrl.nrdrowid,          
                          INPUT (IF par_nrdconta = 0 THEN /*se nao for*/
                                    tta-crapcrl.nrcpfmen  /*coop passa*/
                                 ELSE                     /*cpf */      
                                    0),
                          INPUT "",
                          INPUT tta-crapcrl.dtdenasc,
                          INPUT tta-crapcrl.cdhabmen,
                          INPUT FALSE,
                          OUTPUT aux_menorida,                   
                          OUTPUT aux_msgconta,                   
                          OUTPUT TABLE tt-aux-crapcrl,           
                          OUTPUT TABLE tt-erro ) NO-ERROR.       
                
                    FOR FIRST tt-aux-crapcrl: END.
                   
                    IF AVAILABLE tt-aux-crapcrl THEN
                        ASSIGN aux_nrdrowid = tt-aux-crapcrl.nrdrowid
                               aux_nrdctato = tt-aux-crapcrl.nrdconta
                               aux_nrcpfcto = tt-aux-crapcrl.nrcpfcgc
                               aux_cpfprocu = tt-aux-crapcrl.nrcpfmen
                               aux_nmdavali = tt-aux-crapcrl.nmrespon 
                               aux_tpdocava = tt-aux-crapcrl.tpdeiden 
                               aux_nrdocava = tt-aux-crapcrl.nridenti 
                               aux_cdoeddoc = tt-aux-crapcrl.dsorgemi 
                               aux_cdufddoc = tt-aux-crapcrl.cdufiden 
                               aux_dtemddoc = tt-aux-crapcrl.dtemiden 
                               aux_dtnascto = tt-aux-crapcrl.dtnascin 
                               aux_cdsexcto = tt-aux-crapcrl.cddosexo 
                               aux_cdestcvl = tt-aux-crapcrl.cdestciv 
                               aux_cdnacion = tt-aux-crapcrl.cdnacion 
                               aux_dsnatura = tt-aux-crapcrl.dsnatura 
                               aux_nrcepend = tt-aux-crapcrl.cdcepres 
                               aux_dsendere = tt-aux-crapcrl.dsendres 
                               aux_nmbairro = tt-aux-crapcrl.dsbaires 
                               aux_nmcidade = tt-aux-crapcrl.dscidres 
                               aux_nrendere = tt-aux-crapcrl.nrendres 
                               aux_cdufende = tt-aux-crapcrl.dsdufres 
                               aux_complend = tt-aux-crapcrl.dscomres
                               aux_nrcxapst = tt-aux-crapcrl.nrcxpost 
                               aux_nmmaecto = tt-aux-crapcrl.nmmaersp
                               aux_nmpaicto = tt-aux-crapcrl.nmpairsp
                               aux_cdrlcrsp = tt-aux-crapcrl.cdrlcrsp.
                    
                END.
            ELSE 
                DO:
                   ASSIGN aux_nrdrowid = tta-crapcrl.nrdrowid
                          aux_nrdctato = tta-crapcrl.nrdconta
                          aux_nrcpfcto = tta-crapcrl.nrcpfcgc
                          aux_cpfprocu = tta-crapcrl.nrcpfmen
                          aux_nmdavali = tta-crapcrl.nmrespon 
                          aux_tpdocava = tta-crapcrl.tpdeiden 
                          aux_nrdocava = tta-crapcrl.nridenti 
                          aux_cdoeddoc = tta-crapcrl.dsorgemi 
                          aux_cdufddoc = tta-crapcrl.cdufiden 
                          aux_dtemddoc = tta-crapcrl.dtemiden 
                          aux_dtnascto = tta-crapcrl.dtnascin 
                          aux_cdsexcto = tta-crapcrl.cddosexo 
                          aux_cdestcvl = tta-crapcrl.cdestciv 
                          aux_cdnacion = tta-crapcrl.cdnacion 
                          aux_dsnatura = tta-crapcrl.dsnatura 
                          aux_nrcepend = tta-crapcrl.cdcepres 
                          aux_dsendere = tta-crapcrl.dsendres 
                          aux_nmbairro = tta-crapcrl.dsbaires 
                          aux_nmcidade = tta-crapcrl.dscidres 
                          aux_nrendere = tta-crapcrl.nrendres 
                          aux_cdufende = tta-crapcrl.dsdufres 
                          aux_complend = tta-crapcrl.dscomres
                          aux_nrcxapst = tta-crapcrl.nrcxpost 
                          aux_nmmaecto = tta-crapcrl.nmmaersp 
                          aux_nmpaicto = tta-crapcrl.nmpairsp
                          aux_cdrlcrsp = tta-crapcrl.cdrlcrsp.

                END.
             
            IF  VALID-HANDLE(h_b1wgen0072) THEN
                DELETE OBJECT h_b1wgen0072.
            
            IF  NOT VALID-HANDLE(h_b1wgen0072) THEN
                RUN sistema/generico/procedures/b1wgen0072.p 
                    PERSISTENT SET h_b1wgen0072.
              
            RUN Valida_Dados IN h_b1wgen0072
                ( INPUT par_cdcooper,                 
                  INPUT par_cdagenci,                 
                  INPUT par_nrdcaixa,                 
                  INPUT par_cdoperad,                 
                  INPUT par_nmdatela,                 
                  INPUT par_idorigem,                 
                  INPUT par_nrdctato,                 
                  INPUT par_idseqcta,                 
                  INPUT par_flgerlog,                 
                  INPUT aux_nrdrowid,                 
                  INPUT par_dtmvtolt,                 
                  INPUT par_operacao,                 
                  INPUT aux_nrdctato,                 
                  INPUT (IF aux_nrdctato = 0 THEN /*se nao for coop */
                            aux_nrcpfcto          /*passa cpf */
                         ELSE
                            0),                 
                  INPUT aux_nmdavali,                 
                  INPUT aux_tpdocava,                 
                  INPUT aux_nrdocava,                 
                  INPUT aux_cdoeddoc,                 
                  INPUT aux_cdufddoc,                 
                  INPUT aux_dtemddoc,                 
                  INPUT aux_dtnascto,                 
                  INPUT aux_cdsexcto,                 
                  INPUT aux_cdestcvl,                 
                  INPUT aux_cdnacion,                 
                  INPUT aux_dsnatura,                 
                  INPUT aux_nrcepend,                 
                  INPUT aux_dsendere,                 
                  INPUT aux_nmbairro,                 
                  INPUT aux_nmcidade,                 
                  INPUT aux_cdufende,                 
                  INPUT aux_nmmaecto,                 
                  INPUT YES, /*Flag replica*/     
                  INPUT (IF par_nrdctato = 0 THEN /*se nao for coop passa cpf*/
                            aux_cpfprocu
                         ELSE
                            0),
                  INPUT aux_nmrotina,
                  INPUT ?,
                  INPUT 0,
                  INPUT FALSE,
                  INPUT TABLE tt-resp,
                 OUTPUT aux_nmdcampo,
                 OUTPUT TABLE tt-erro) NO-ERROR.

            IF  VALID-HANDLE(h_b1wgen0072) THEN
                DELETE OBJECT h_b1wgen0072.
            
            IF  ERROR-STATUS:ERROR THEN
                DO: 
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).
                END.
            
            IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
                DO:
                    IF  par_operacao = "I"  THEN
                        ASSIGN par_auxmensg = "responsavel " + 
                                          STRING(aux_nrcpfcto,"999.999.999-99").
                    UNDO Responsavel, LEAVE Responsavel.
                END.

            IF  NOT VALID-HANDLE(h_b1wgen0072) THEN
                RUN sistema/generico/procedures/b1wgen0072.p 
                    PERSISTENT SET h_b1wgen0072.

            /* E=Exclui registros existentes - I=Inclui conf.conta pai */
            RUN Grava_Dados IN h_b1wgen0072
                ( INPUT par_cdcooper,    
                  INPUT par_cdagenci,    
                  INPUT par_nrdcaixa,    
                  INPUT par_cdoperad,    
                  INPUT par_nmdatela,    
                  INPUT par_idorigem,    
                  INPUT par_nrdctato,  
                  INPUT par_idseqcta,    
                  INPUT par_flgerlog,    
                  INPUT aux_nrdrowid,    
                  INPUT par_dtmvtolt,    
                  INPUT par_operacao,    
                  INPUT aux_nrdctato,    
                  INPUT (IF aux_nrdctato = 0 THEN /*se nao for coop passa cpf*/
                            aux_nrcpfcto
                         ELSE
                            0),    
                  INPUT aux_nmdavali,    
                  INPUT aux_tpdocava,    
                  INPUT aux_nrdocava,    
                  INPUT aux_cdoeddoc,    
                  INPUT aux_cdufddoc,    
                  INPUT aux_dtemddoc,    
                  INPUT aux_dtnascto,    
                  INPUT aux_cdsexcto,    
                  INPUT aux_cdestcvl,    
                  INPUT aux_cdnacion,    
                  INPUT aux_dsnatura,    
                  INPUT aux_nrcepend,    
                  INPUT aux_dsendere,    
                  INPUT aux_nmbairro,    
                  INPUT aux_nmcidade,    
                  INPUT aux_nrendere,    
                  INPUT aux_cdufende,    
                  INPUT aux_complend,    
                  INPUT aux_nrcxapst,    
                  INPUT aux_nmmaecto,    
                  INPUT aux_nmpaicto,    
                  INPUT (IF par_nrdctato = 0 THEN /*se nao for coop passa cpf*/
                            aux_cpfprocu
                         ELSE
                            0),
                  INPUT aux_cdrlcrsp,
                  INPUT aux_nmrotina,
                  OUTPUT aux_msgalert,
                  OUTPUT aux_tpatlcad,
                  OUTPUT aux_msgatcad, 
                  OUTPUT aux_chavealt, 
                  OUTPUT TABLE tt-erro ) NO-ERROR.

            IF  NOT RetornoErro( INPUT-OUTPUT par_dscritic ) THEN
                UNDO Responsavel, LEAVE Responsavel.

            IF  VALID-HANDLE(h_b1wgen0072) THEN
                DELETE OBJECT h_b1wgen0072.
        END.

        ASSIGN aux_returnvl = "OK".

        LEAVE Responsavel.

    END.

    IF  VALID-HANDLE(h_b1wgen0072) THEN
        DELETE OBJECT h_b1wgen0072.

    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        ASSIGN aux_returnvl = "NOK".

    RETURN aux_returnvl.

END PROCEDURE. /* Fim Replica_Responsavel */

/*........................... PROCEDURES INTERNAS ...........................*/


/*............................... FUNCTIONS .................................*/

/* ------------------------------------------------------------------------ */
/*       VERIFICA SE HOUVE ERRO NA EXECUCAO OU RETORNO DAS PROCEDURES       */
/* ------------------------------------------------------------------------ */
FUNCTION RetornoErro RETURNS LOGICAL 
    ( INPUT-OUTPUT par_dscritic AS CHARACTER ):

DEFINE VARIABLE laux AS LOGICAL INITIAL YES NO-UNDO.

    IF  ERROR-STATUS:ERROR THEN DO:
        ASSIGN par_dscritic = par_dscritic + ERROR-STATUS:GET-MESSAGE(1)
               laux         = NO.
    END.
    
    IF  RETURN-VALUE <> "OK" THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               ASSIGN par_dscritic = par_dscritic + tt-erro.dscritic.

           EMPTY TEMP-TABLE tt-erro.

           ASSIGN laux = NO.

        END.
    
    RETURN (laux).

END FUNCTION.

/* ------------------------------------------------------------------------ */
/*       VERIFICA SE HOUVE ERRO NA EXECUCAO OU RETORNO DAS PROCEDURES       */
/* ------------------------------------------------------------------------ */
FUNCTION RetornaErroReplica RETURNS LOGICAL 
    (   INPUT        par_nrdconta AS INTEGER ,
        INPUT        par_auxmensg AS CHARACTER ,
        INPUT-OUTPUT par_dscritic AS CHARACTER ):

    DEFINE VARIABLE laux AS LOGICAL INITIAL YES NO-UNDO.

    IF  ERROR-STATUS:ERROR THEN DO:
        ASSIGN par_dscritic = par_dscritic + ERROR-STATUS:GET-MESSAGE(1) 
               + " Verificar " + 
               ( IF par_auxmensg = "" THEN
                   "conta " + TRIM(STRING(par_nrdconta,"zzzz,zzz,9")) + "."
               ELSE par_auxmensg + ".")
               laux         = NO.
    END.
    
    IF  RETURN-VALUE <> "OK" THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               ASSIGN par_dscritic = par_dscritic + tt-erro.dscritic
                      + " Verificar " +
               ( IF par_auxmensg = "" THEN
                   "conta " + TRIM(STRING(par_nrdconta,"zzzz,zzz,9")) + "."
               ELSE par_auxmensg + ".").

           EMPTY TEMP-TABLE tt-erro.

           ASSIGN laux = NO.
        END.
    
    RETURN (laux).

END FUNCTION.


