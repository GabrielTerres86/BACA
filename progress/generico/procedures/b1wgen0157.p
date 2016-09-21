/*..............................................................................
    
   Programa: b1wgen0157.p                  
   Autora  : Guilherme / SUPERO
   Data    : 21/05/2013                        Ultima atualizacao:28/05/2015

   Dados referentes ao programa:

   Objetivo  : BO DE PROCEDURES PARA RATBND

   Alteracoes: 13/11/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (Guilherme Gielow)
                            
               28/05/2015 - Alterado para apresentar mensagem ao realizar inclusao
                            de nova proposta emprestimo para menores nao 
                            emancipados. (Reinert)

..............................................................................*/
 
{ sistema/generico/includes/b1wgen0002tt.i }
{ sistema/generico/includes/b1wgen0024tt.i }
{ sistema/generico/includes/b1wgen0043tt.i }
{ sistema/generico/includes/b1wgen0056tt.i }
{ sistema/generico/includes/b1wgen0030tt.i }
{ sistema/generico/includes/b1wgen0138tt.i }
{ sistema/generico/includes/b1wgen0059tt.i }
{ sistema/generico/includes/b1wgen0069tt.i }
{ sistema/generico/includes/b1wgen0084tt.i }
{ sistema/generico/includes/b1wgen0084att.i }
{ sistema/generico/includes/b1wgen0157tt.i }
{ sistema/generico/includes/b1wgen9999tt.i } 


{ includes/var_online.i }

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ includes/gera_rating.i }

DEF VAR h-b1wgen0002 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0024 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0040 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0110 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0157 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                         NO-UNDO.

           
DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_nrsequen AS INTE                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_qtctarel AS INT FORMAT "zz9"                               NO-UNDO.

DEF STREAM str_1.



/*............................................................................*/

PROCEDURE validar-rating-bndes:

    DEF INPUT  PARAM par_cdcooper AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_inproces AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_idorigem AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_nrdconta AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_inpessoa AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_nrcpfcgc AS DECI                              NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF INPUT  PARAM par_inconfir AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_inconfi2 AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_tpvalida AS CHAR                              NO-UNDO.
    /* PARAMETROS DE TELA */
    DEF INPUT  PARAM par_vlempbnd AS DECI                              NO-UNDO.
    DEF INPUT  PARAM par_qtparbnd AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_nrinfcad AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_nrgarope AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_nrliquid AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_nrpatlvr AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_nrperger AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_nrctrato AS INT                               NO-UNDO.
    
    DEF OUTPUT PARAM aux_nrctrato AS INT         INIT 0                NO-UNDO.
    DEF OUTPUT PARAM aux_dsdrisco AS CHAR                              NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-msg-confirma.
    DEF OUTPUT PARAM TABLE FOR tt-ge-epr.


    DEF VAR          aux_dstpoper AS CHAR                              NO-UNDO.
    DEF VAR          aux_dsoperac AS CHAR                              NO-UNDO.
    DEF VAR          par_dsmesage AS CHAR                              NO-UNDO.
    DEF VAR          aux_vlutiliz AS DECI                              NO-UNDO.
    DEF VAR          aux_idseqbem AS INT                               NO-UNDO.
    DEF VAR          aux_dsdfinan AS CHAR                              NO-UNDO.
    DEF VAR          aux_dsdrendi AS CHAR                              NO-UNDO.
    DEF VAR          aux_dsdebens AS CHAR                              NO-UNDO.
    DEF VAR          aux_dsdbeavt AS CHAR                              NO-UNDO.
    DEF VAR          aux_dsdalien AS CHAR                              NO-UNDO.
    DEF VAR          aux_dsinterv AS CHAR                              NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-msg-confirma.
    EMPTY TEMP-TABLE tt-ge-epr.


    /** VALIDACOES CAMPOS **/
    IF  par_vlempbnd <= 0 THEN DO:
        ASSIGN aux_dscritic = "Valor do Emprestimo BNDES " +
                              "deve ser informado!".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.
    
    IF  par_qtparbnd <= 0 THEN DO:
        ASSIGN aux_dscritic = "Qtde de Parcelas do Emprestimo BNDES " +
                              "deve ser informado!".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.
    /** VALIDACOES CAMPOS **/


    
    IF  NOT VALID-HANDLE(h-b1wgen0002) THEN
        RUN sistema/generico/procedures/b1wgen0002.p
            PERSISTENT SET h-b1wgen0002.    
    
    RUN obtem-dados-proposta-emprestimo IN h-b1wgen0002
                                 (INPUT par_cdcooper,
                                  INPUT 0,
                                  INPUT 0,
                                  INPUT par_cdoperad,
                                  INPUT par_nmdatela,
                                  INPUT par_inproces,
                                  INPUT par_idorigem,
                                  INPUT par_nrdconta,
                                  INPUT 1,   /* Tit. */
                                  INPUT par_dtmvtolt,
                                  INPUT 0,   /* Sem contrato ainda */
                                  INPUT "I", /* Inclusao */
                                  INPUT 0,
                                  INPUT TRUE,
                                  OUTPUT TABLE tt-erro,
                                  OUTPUT TABLE tt-dados-coope, 
                                  OUTPUT TABLE tt-dados-assoc,
                                  OUTPUT TABLE tt-tipo-rendi,
                                  OUTPUT TABLE tt-itens-topico-rating,

                                  OUTPUT TABLE tt-proposta-epr,
                                  OUTPUT TABLE tt-crapbem,
                                  OUTPUT TABLE tt-bens-alienacao,
                                  OUTPUT TABLE tt-rendimento,
                                  OUTPUT TABLE tt-faturam,
                                  OUTPUT TABLE tt-dados-analise,
                                  OUTPUT TABLE tt-interv-anuentes,
                                  OUTPUT TABLE tt-hipoteca,
                                  OUTPUT TABLE tt-dados-avais,
                                  OUTPUT TABLE tt-aval-crapbem,
                                  OUTPUT TABLE tt-msg-confirma).

    IF  VALID-HANDLE(h-b1wgen0002) THEN
        DELETE PROCEDURE h-b1wgen0002.

    IF   RETURN-VALUE <> "OK"   THEN
         DO: 
             FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
             IF   AVAIL tt-erro   THEN
                  MESSAGE tt-erro.dscritic.
             ELSE
                  MESSAGE "Erro na busca dos dados da proposta.".

             RETURN.
         END.

    /* Dados gerais da cooperativa */
    FIND FIRST tt-dados-coope NO-LOCK NO-ERROR.

    /* Dados gerias do cooperado */
    FIND FIRST tt-dados-assoc NO-LOCK NO-ERROR.

    /* Dados na crawepr */
    FIND FIRST tt-proposta-epr NO-LOCK NO-ERROR.

    FIND FIRST tt-rendimento NO-LOCK NO-ERROR.

    FIND FIRST tt-dados-analise NO-LOCK NO-ERROR.




    /*Verifica se o associado esta no cadastro restritivo*/
    IF  NOT VALID-HANDLE(h-b1wgen0110) THEN
        RUN sistema/generico/procedures/b1wgen0110.p
            PERSISTENT SET h-b1wgen0110.

    IF  par_tpvalida = "I" THEN
        ASSIGN aux_dstpoper = "inclusao de nova".
    ELSE
        ASSIGN aux_dstpoper = "alteracao da".

    /*Monta a mensagem da opereacao para envio no e-mail*/
    ASSIGN aux_dsoperac =  "Tentativa de " + aux_dstpoper + 
                           " proposta de "   + 
                           "emprestimo/financiamento BNDES na conta "     +
                           STRING(par_nrdconta,"zzzz,zzz,9")          +
                           " - CPF/CNPJ "                                 +
                           (IF par_inpessoa = 1 THEN
                               STRING((STRING(par_nrcpfcgc,
                                       "99999999999")),"xxx.xxx.xxx-xx")
                            ELSE
                               STRING((STRING(par_nrcpfcgc,
                                       "99999999999999")),
                                       "xx.xxx.xxx/xxxx-xx")).

    /*Verifica se o associado esta no cadastro restritivo*/
    RUN alerta_fraude IN h-b1wgen0110(INPUT par_cdcooper,
                                      INPUT 0,
                                      INPUT 0,
                                      INPUT par_cdoperad,
                                      INPUT par_nmdatela,
                                      INPUT par_dtmvtolt,
                                      INPUT 1,
                                      INPUT par_nrcpfcgc,
                                      INPUT par_nrdconta,
                                      INPUT 1,
                                      INPUT TRUE, /*bloqueia operacao*/
                                      INPUT IF par_tpvalida = "A" THEN 9 ELSE 12, /*cdoperac*/
                                      INPUT aux_dsoperac,
                                      OUTPUT TABLE tt-erro).

    IF  VALID-HANDLE(h-b1wgen0110) THEN
        DELETE PROCEDURE(h-b1wgen0110).
    
    IF RETURN-VALUE <> "OK" THEN
       DO:
          IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
             DO:
                ASSIGN aux_dscritic = "Nao foi possivel verificar o " + 
                                      "cadastro restritivo.".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT 0,
                               INPUT 0,
                               INPUT 1, /*sequencia*/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
          END.

          RETURN "NOK".

    END.


    
    IF  NOT VALID-HANDLE(h-b1wgen0002) THEN
        RUN sistema/generico/procedures/b1wgen0002.p
            PERSISTENT SET h-b1wgen0002.

    FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper.

    RUN verifica-limites-excedidos IN h-b1wgen0002
                                   (INPUT par_cdcooper,
                                    INPUT 0,
                                    INPUT 0,
                                    INPUT par_cdoperad,
                                    INPUT par_nmdatela,
                                    INPUT par_idorigem,
                                    INPUT par_nrdconta,
                                    INPUT par_vlempbnd,

                                    INPUT tt-dados-coope.vlmaxutl,
                                    INPUT tt-dados-coope.vlmaxleg,
                                    INPUT tt-dados-coope.vlcnsscr,

                                    INPUT 1, /* titular */ 
                                    INPUT crapdat.dtmvtolt,
                                    INPUT crapdat.dtmvtopr,

                                    INPUT "",
                                    INPUT par_inconfir,
                                    INPUT 0,
                                    INPUT par_inconfi2,

                                    OUTPUT TABLE tt-erro,
                                    OUTPUT TABLE tt-msg-confirma,
                                    OUTPUT TABLE tt-ge-epr,
                                    OUTPUT par_dsmesage,
                                    OUTPUT aux_vlutiliz).

    IF  VALID-HANDLE(h-b1wgen0002) THEN
        DELETE PROCEDURE h-b1wgen0002.

    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".


    IF  par_tpvalida = "I" THEN DO:
        /* Busca Nr Contrato */
        FIND LAST crapprp
            WHERE crapprp.cdcooper = par_cdcooper
              AND crapprp.nrdconta = par_nrdconta
              AND crapprp.tpctrato = 90
          NO-LOCK NO-ERROR.
    
        IF  NOT AVAIL crapprp THEN
            ASSIGN aux_nrctrato = 1.
        ELSE
            ASSIGN aux_nrctrato = crapprp.nrctrato + 1.
    
    
        IF  NOT VALID-HANDLE(h-b1wgen0002) THEN
            RUN sistema/generico/procedures/b1wgen0002.p 
                PERSISTENT SET h-b1wgen0002.
    
        DO WHILE TRUE:
            aux_dscritic = DYNAMIC-FUNCTION("verificaContrato" 
                                           IN h-b1wgen0002,
                       INPUT par_cdcooper,
                       INPUT par_nrdconta,
                       INPUT aux_nrctrato,
                       INPUT 0,
                       INPUT 0,
                       INPUT 0).
            IF  aux_dscritic <> ""   THEN DO:
                aux_nrctrato = aux_nrctrato + 1.
                NEXT.
            END.
    
            LEAVE.
        END.
    
        IF  VALID-HANDLE(h-b1wgen0002) THEN
            DELETE PROCEDURE h-b1wgen0002.
        /* Busca Nr Contrato */
    END.


    

    /* Listar as criticas do RATING (se existir) */
    IF  NOT VALID-HANDLE(h-b1wgen0043) THEN
        RUN sistema/generico/procedures/b1wgen0043.p
            PERSISTENT SET h-b1wgen0043.

    IF  NOT VALID-HANDLE (h-b1wgen0043)  THEN
        DO:
        MESSAGE "Handle invalida para a BO h-b1wgen0043.".
        PAUSE 3 NO-MESSAGE.
        RETURN "NOK".
    END.


    IF  par_tpvalida = "A" THEN
        ASSIGN aux_nrctrato = par_nrctrato.

    RUN lista_criticas IN h-b1wgen0043
                                   (INPUT par_cdcooper,
                                    INPUT 0,
                                    INPUT 0,
                                    INPUT par_cdoperad,
                                    INPUT par_dtmvtolt,
                                    INPUT par_nrdconta,
                                    INPUT 0,
                                    INPUT aux_nrctrato,
                                    INPUT 1,
                                    INPUT 1,
                                    INPUT par_nmdatela,
                                    INPUT par_inproces,
                                    INPUT FALSE,
                                    OUTPUT TABLE tt-erro).

    IF  VALID-HANDLE(h-b1wgen0043) THEN
        DELETE PROCEDURE h-b1wgen0043.

    IF  RETURN-VALUE <> "OK"  THEN
        RETURN "NOK".


    RETURN "OK".

END PROCEDURE.

/*............................................................................*/

PROCEDURE incluir-rating-bndes:

    DEF INPUT  PARAM par_cdcooper AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_inproces AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_idorigem AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_nrdconta AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_inpessoa AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_nrcpfcgc AS DECI                              NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF INPUT  PARAM par_inconfir AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_inconfi2 AS INT                               NO-UNDO.
    /* PARAMETROS DE TELA */
    DEF INPUT  PARAM par_vlempbnd AS DECI                              NO-UNDO.
    DEF INPUT  PARAM par_qtparbnd AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_nrinfcad AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_nrgarope AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_nrliquid AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_nrpatlvr AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_nrperger AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_nrctrato AS INT                               NO-UNDO.
    DEF OUTPUT PARAM ret_nrctrato AS INT         INIT 0                NO-UNDO.
    DEF OUTPUT PARAM aux_dsdrisco AS CHAR                              NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-msg-confirma.
    DEF OUTPUT PARAM TABLE FOR tt-ge-epr.


    DEF VAR aux_dsoperac AS CHAR                                       NO-UNDO.
    DEF VAR par_dsmesage AS CHAR                                       NO-UNDO.
    DEF VAR aux_vlutiliz AS DECI                                       NO-UNDO.
    DEF VAR aux_idseqbem AS INT                                        NO-UNDO.
    DEF VAR aux_dsdfinan AS CHAR                                       NO-UNDO.
    DEF VAR aux_dsdrendi AS CHAR                                       NO-UNDO.
    DEF VAR aux_dsdebens AS CHAR                                       NO-UNDO.
    DEF VAR aux_dsdbeavt AS CHAR                                       NO-UNDO.
    DEF VAR aux_dsdalien AS CHAR                                       NO-UNDO.
    DEF VAR aux_dsinterv AS CHAR                                       NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-msg-confirma.
    EMPTY TEMP-TABLE tt-ge-epr.


    ASSIGN aux_dsdrisco = "".

    IF  NOT VALID-HANDLE(h-b1wgen0002) THEN
        RUN sistema/generico/procedures/b1wgen0002.p
            PERSISTENT SET h-b1wgen0002.

    RUN obtem-dados-proposta-emprestimo IN h-b1wgen0002
                                 (INPUT par_cdcooper,
                                  INPUT 0,
                                  INPUT 0,
                                  INPUT par_cdoperad,
                                  INPUT par_nmdatela,
                                  INPUT par_inproces,
                                  INPUT par_idorigem,
                                  INPUT par_nrdconta,
                                  INPUT 1,   /* Tit. */
                                  INPUT par_dtmvtolt,
                                  INPUT 0,   /* Sem contrato ainda */
                                  INPUT "I", /* Inclusao */
                                  INPUT 0,
                                  INPUT TRUE,
                                  OUTPUT TABLE tt-erro,
                                  OUTPUT TABLE tt-dados-coope, 
                                  OUTPUT TABLE tt-dados-assoc,
                                  OUTPUT TABLE tt-tipo-rendi,
                                  OUTPUT TABLE tt-itens-topico-rating,

                                  OUTPUT TABLE tt-proposta-epr,
                                  OUTPUT TABLE tt-crapbem,
                                  OUTPUT TABLE tt-bens-alienacao,
                                  OUTPUT TABLE tt-rendimento,
                                  OUTPUT TABLE tt-faturam,
                                  OUTPUT TABLE tt-dados-analise,
                                  OUTPUT TABLE tt-interv-anuentes,
                                  OUTPUT TABLE tt-hipoteca,
                                  OUTPUT TABLE tt-dados-avais,
                                  OUTPUT TABLE tt-aval-crapbem,
                                  OUTPUT TABLE tt-msg-confirma).        

    IF  VALID-HANDLE(h-b1wgen0002) THEN
        DELETE PROCEDURE h-b1wgen0002.

    IF   RETURN-VALUE <> "OK"   THEN
         DO: 
             FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
             IF   AVAIL tt-erro   THEN
                  MESSAGE tt-erro.dscritic.
             ELSE
                  MESSAGE "Erro na busca dos dados da proposta.".

             RETURN.
         END.

    /* Dados gerais da cooperativa */
    FIND FIRST tt-dados-coope NO-LOCK NO-ERROR.

    /* Dados gerias do cooperado */
    FIND FIRST tt-dados-assoc NO-LOCK NO-ERROR.

    /* Dados na crawepr */
    FIND FIRST tt-proposta-epr NO-LOCK NO-ERROR.

    FIND FIRST tt-rendimento NO-LOCK NO-ERROR.

    FIND FIRST tt-dados-analise NO-LOCK NO-ERROR.


    /* Busca Nr Contrato */
    FIND LAST crapprp
        WHERE crapprp.cdcooper = par_cdcooper
          AND crapprp.nrdconta = par_nrdconta
          AND crapprp.nrctrato = par_nrctrato
          AND crapprp.tpctrato = 90
     NO-LOCK NO-ERROR.

    /* Se ja exisitr, tenta encontrar outro valido */
    IF  AVAIL crapprp THEN DO:
        FIND LAST crapprp
            WHERE crapprp.cdcooper = par_cdcooper
              AND crapprp.nrdconta = par_nrdconta
              AND crapprp.tpctrato = 90
          NO-LOCK NO-ERROR.
    
        IF  NOT AVAIL crapprp THEN
            ASSIGN ret_nrctrato = 1.
        ELSE
            ASSIGN ret_nrctrato = crapprp.nrctrato + 1.


        DO WHILE TRUE:
            IF  NOT VALID-HANDLE(h-b1wgen0002) THEN
                RUN sistema/generico/procedures/b1wgen0002.p 
                    PERSISTENT SET h-b1wgen0002.

            aux_dscritic = DYNAMIC-FUNCTION("verificaContrato" 
                                           IN h-b1wgen0002,
                       INPUT par_cdcooper,
                       INPUT par_nrdconta,
                       INPUT ret_nrctrato,
                       INPUT 0,
                       INPUT 0,
                       INPUT 0).
            
            IF  VALID-HANDLE(h-b1wgen0002) THEN
                DELETE PROCEDURE h-b1wgen0002.            

            IF  aux_dscritic <> ""   THEN DO:
                ret_nrctrato = ret_nrctrato + 1.
                NEXT.
            END.
    
            LEAVE.
        END.
    END.
    ELSE /* Se nao existe, assume como valido */
        ret_nrctrato = par_nrctrato.
    /* Busca Nr Contrato */


    /* Juntar os rendimentos  */
    DO aux_contador = 1 TO 6:
    
       IF   tt-rendimento.tpdrendi[aux_contador] = 0   THEN
            NEXT.
    
       IF   aux_dsdrendi <> ""  THEN
            aux_dsdrendi = aux_dsdrendi + "|". 
                             
       ASSIGN aux_dsdrendi = aux_dsdrendi + 
                        STRING(tt-rendimento.tpdrendi[aux_contador]) + ";" +
                        STRING(tt-rendimento.vldrendi[aux_contador]).                
    END.


    /* Juntar os bens do cooperado */
    IF   TEMP-TABLE tt-crapbem:HAS-RECORDS   THEN
         FOR EACH tt-crapbem NO-LOCK:
    
             IF   aux_dsdebens <> ""  THEN
                  aux_dsdebens = aux_dsdebens + "|".

           /* Esta montagem tem que ficar no mesmo estilo dos bens dos aval */
              /* Neste caso vai sem CPF apos a conta */
              ASSIGN aux_dsdebens = aux_dsdebens + 
                                            STRING(tt-crapbem.nrdconta) + ";;" +
                                                   tt-crapbem.dsrelbem  + ";"  +
                                            STRING(tt-crapbem.persemon) + ";"  +
                                            STRING(tt-crapbem.qtprebem) + ";"  +
                                            STRING(tt-crapbem.vlprebem) + ";"  +
                                            STRING(tt-crapbem.vlrdobem) + ";"  +
                                            STRING(tt-crapbem.idseqbem).                                 
         END.


    IF  NOT VALID-HANDLE(h-b1wgen0024) THEN
        RUN sistema/generico/procedures/b1wgen0024.p
            PERSISTENT SET h-b1wgen0024.

    /* Gravar os dados que sao comuns as operacoes de credito */
    RUN grava-dados-proposta IN h-b1wgen0024(
                          INPUT par_cdcooper,
                          INPUT 0, /*par_cdagenci,*/
                          INPUT 0, /*par_nrdcaixa,*/
                          INPUT par_cdoperad,
                          INPUT par_nmdatela,
                          INPUT par_idorigem,
                          INPUT par_nrdconta,
                          INPUT 1, /*par_idseqttl,*/
                          INPUT par_dtmvtolt,
                          /* Emprestimo */
                          INPUT 90,
                          INPUT ret_nrctrato,
                          /* Analise da proposta */
                          INPUT par_vlempbnd,
                          INPUT par_qtparbnd,
                          INPUT par_nrgarope,
                          INPUT par_nrperger,
                          INPUT tt-dados-analise.dtcnsspc,
                          INPUT par_nrinfcad,
                          INPUT tt-dados-analise.dtdrisco,
                          INPUT tt-dados-analise.vltotsfn,
                          INPUT tt-dados-analise.qtopescr,
                          INPUT tt-dados-analise.qtifoper,
                          INPUT par_nrliquid,
                          INPUT tt-dados-analise.vlopescr,
                          INPUT tt-dados-analise.vlrpreju,
                          INPUT par_nrpatlvr,
                          INPUT tt-dados-analise.dtoutspc,
                          INPUT tt-dados-analise.dtoutris,
                          INPUT tt-dados-analise.vlsfnout,
                          /* Rendimentos */
                          INPUT tt-rendimento.vlsalari,
                          INPUT tt-rendimento.vloutras,
                          INPUT tt-rendimento.vlalugue,
                          INPUT tt-rendimento.vlsalcon,
                          INPUT tt-rendimento.nmextemp,
                          INPUT tt-rendimento.flgdocje,
                          INPUT tt-rendimento.nrctacje,
                          INPUT tt-rendimento.nrcpfcjg,
                          INPUT tt-rendimento.vlmedfat,
                          INPUT tt-proposta-epr.dsobserv,
                          INPUT aux_dsdrendi,
                          /* Bens */
                          INPUT aux_dsdebens,
                          INPUT TRUE,  /** nao usa */
                          INPUT tt-rendimento.dsjusren,
                         OUTPUT TABLE tt-erro,
                         OUTPUT aux_idseqbem).

    IF  VALID-HANDLE(h-b1wgen0024) THEN
        DELETE PROCEDURE h-b1wgen0024.

    IF  RETURN-VALUE <> "OK"   THEN
        /*UNDO Gravar,*/ RETURN "NOK".


    
    IF  NOT VALID-HANDLE(h-b1wgen0043) THEN
        RUN sistema/generico/procedures/b1wgen0043.p
            PERSISTENT SET h-b1wgen0043.
    
    IF  NOT VALID-HANDLE(h-b1wgen0043)  THEN
        DO:
            MESSAGE "Handle invalido para BO b1wgen0043.".
            RETURN "NOK".
    END.

    FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper.

    RUN gera_rating IN h-b1wgen0043
                    (INPUT par_cdcooper,
                     INPUT 0,   /** Pac   **/
                     INPUT 0,   /** Caixa **/
                     INPUT par_cdoperad,
                     INPUT par_nmdatela,
                     INPUT 1,   /** Ayllos  **/
                     INPUT par_nrdconta,
                     INPUT 1,   /** Titular **/
                     INPUT crapdat.dtmvtolt,
                     INPUT crapdat.dtmvtopr,
                     INPUT par_inproces,
                     INPUT 90,
                     INPUT ret_nrctrato,
                     INPUT FALSE,  /* NAO GRAVA */
                     INPUT TRUE,   /** Log **/
                    OUTPUT TABLE tt-erro,
                    OUTPUT TABLE tt-cabrel,
                    OUTPUT TABLE tt-impressao-coop,
                    OUTPUT TABLE tt-impressao-rating,
                    OUTPUT TABLE tt-impressao-risco,
                    OUTPUT TABLE tt-impressao-risco-tl,
                    OUTPUT TABLE tt-impressao-assina,
                    OUTPUT TABLE tt-efetivacao,
                    OUTPUT TABLE tt-ratings).

    IF  VALID-HANDLE(h-b1wgen0043) THEN
        DELETE PROCEDURE h-b1wgen0043.

    HIDE MESSAGE NO-PAUSE.

    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".


    FIND FIRST tt-impressao-risco NO-LOCK NO-ERROR.
    IF  AVAIL tt-impressao-risco THEN
        aux_dsdrisco = tt-impressao-risco.dsdrisco.
    ELSE
        aux_dsdrisco = "ERR".

    RETURN "OK".

END PROCEDURE.

/*............................................................................*/

PROCEDURE alterar-rating-bndes:
    
    DEF INPUT  PARAM par_cdcooper AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_inproces AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_idorigem AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_nrdconta AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_inpessoa AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_nrcpfcgc AS DECI                              NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF INPUT  PARAM par_inconfir AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_inconfi2 AS INT                               NO-UNDO.
    /* PARAMETROS DE TELA */
    DEF INPUT  PARAM par_vlempbnd AS DECI                              NO-UNDO.
    DEF INPUT  PARAM par_qtparbnd AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_nrinfcad AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_nrgarope AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_nrliquid AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_nrpatlvr AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_nrperger AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_nrctrato AS INT                               NO-UNDO.

    DEF OUTPUT PARAM aux_dsdrisco AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-msg-confirma.
    DEF OUTPUT PARAM TABLE FOR tt-ge-epr.


    DEF VAR          aux_dsoperac AS CHAR                              NO-UNDO.
    DEF VAR          par_dsmesage AS CHAR                              NO-UNDO.
    DEF VAR          aux_vlutiliz AS DECI                              NO-UNDO.
    DEF VAR          aux_idseqbem AS INT                               NO-UNDO.
    DEF VAR          aux_dsdfinan AS CHAR                              NO-UNDO.
    DEF VAR          aux_dsdrendi AS CHAR                              NO-UNDO.
    DEF VAR          aux_dsdebens AS CHAR                              NO-UNDO.
    DEF VAR          aux_dsdbeavt AS CHAR                              NO-UNDO.
    DEF VAR          aux_dsdalien AS CHAR                              NO-UNDO.
    DEF VAR          aux_dsinterv AS CHAR                              NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-msg-confirma.
    EMPTY TEMP-TABLE tt-ge-epr.

    
    ASSIGN aux_dsdrisco = "".

    
    IF  NOT VALID-HANDLE(h-b1wgen0002) THEN
        RUN sistema/generico/procedures/b1wgen0002.p
            PERSISTENT SET h-b1wgen0002.
    
    RUN obtem-dados-proposta-emprestimo IN h-b1wgen0002
             (INPUT par_cdcooper,
              INPUT 0,
              INPUT 0,
              INPUT par_cdoperad,
              INPUT par_nmdatela,
              INPUT par_inproces,
              INPUT par_idorigem,
              INPUT par_nrdconta,
              INPUT 1,   /* Tit. */
              INPUT par_dtmvtolt,
              INPUT 0,   /* Sem contrato ainda */
              INPUT "I", /* Inclusao */  /*verificar a validacao do crapprp na BO0002 - linha 2172-> IF   par_cddopcao <> "I"   THEN */
              INPUT 0,
              INPUT TRUE,
              OUTPUT TABLE tt-erro,
              OUTPUT TABLE tt-dados-coope, 
              OUTPUT TABLE tt-dados-assoc,
              OUTPUT TABLE tt-tipo-rendi,
              OUTPUT TABLE tt-itens-topico-rating,

              OUTPUT TABLE tt-proposta-epr,
              OUTPUT TABLE tt-crapbem,
              OUTPUT TABLE tt-bens-alienacao,
              OUTPUT TABLE tt-rendimento,
              OUTPUT TABLE tt-faturam,
              OUTPUT TABLE tt-dados-analise,
              OUTPUT TABLE tt-interv-anuentes,
              OUTPUT TABLE tt-hipoteca,
              OUTPUT TABLE tt-dados-avais,
              OUTPUT TABLE tt-aval-crapbem,
              OUTPUT TABLE tt-msg-confirma).

    IF  VALID-HANDLE(h-b1wgen0002) THEN
        DELETE PROCEDURE h-b1wgen0002.

    IF   RETURN-VALUE <> "OK"   THEN
         DO: 
             FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
             IF   AVAIL tt-erro   THEN
                  MESSAGE tt-erro.dscritic.
             ELSE
                  MESSAGE "Erro na busca dos dados da proposta.".

             RETURN.
         END.

    /* Dados gerais da cooperativa */
    FIND FIRST tt-dados-coope NO-LOCK NO-ERROR.

    /* Dados gerias do cooperado */
    FIND FIRST tt-dados-assoc NO-LOCK NO-ERROR.

    /* Dados na crawepr */
    FIND FIRST tt-proposta-epr NO-LOCK NO-ERROR.

    FIND FIRST tt-rendimento NO-LOCK NO-ERROR.

    FIND FIRST tt-dados-analise NO-LOCK NO-ERROR.




    /* Juntar os rendimentos  */
    DO aux_contador = 1 TO 6:
    
       IF   tt-rendimento.tpdrendi[aux_contador] = 0   THEN
            NEXT.
    
       IF   aux_dsdrendi <> ""  THEN
            aux_dsdrendi = aux_dsdrendi + "|". 
                             
       ASSIGN aux_dsdrendi = aux_dsdrendi + 
                        STRING(tt-rendimento.tpdrendi[aux_contador]) + ";" +
                        STRING(tt-rendimento.vldrendi[aux_contador]).                
    END.


    /* Juntar os bens do cooperado */
    IF   TEMP-TABLE tt-crapbem:HAS-RECORDS   THEN
         FOR EACH tt-crapbem NO-LOCK:
    
             IF   aux_dsdebens <> ""  THEN
                  aux_dsdebens = aux_dsdebens + "|".

           /* Esta montagem tem que ficar no mesmo estilo dos bens dos aval */
              /* Neste caso vai sem CPF apos a conta */
              ASSIGN aux_dsdebens = aux_dsdebens + 
                                            STRING(tt-crapbem.nrdconta) + ";;" +
                                                   tt-crapbem.dsrelbem  + ";"  +
                                            STRING(tt-crapbem.persemon) + ";"  +
                                            STRING(tt-crapbem.qtprebem) + ";"  +
                                            STRING(tt-crapbem.vlprebem) + ";"  +
                                            STRING(tt-crapbem.vlrdobem) + ";"  +
                                            STRING(tt-crapbem.idseqbem).                                 
         END.






    IF  NOT VALID-HANDLE(h-b1wgen0024) THEN
        RUN sistema/generico/procedures/b1wgen0024.p
            PERSISTENT SET h-b1wgen0024.

    /* Gravar os dados que sao comuns as operacoes de credito */
    RUN grava-dados-proposta IN h-b1wgen0024(
                     INPUT par_cdcooper,
                     INPUT 0, /*par_cdagenci,*/
                     INPUT 0, /*par_nrdcaixa,*/
                     INPUT par_cdoperad,
                     INPUT par_nmdatela,
                     INPUT par_idorigem,
                     INPUT par_nrdconta,
                     INPUT 1, /*par_idseqttl,*/
                     INPUT par_dtmvtolt,
                     /* Emprestimo */
                     INPUT 90,
                     INPUT par_nrctrato,
                     /* Analise da proposta */
                     INPUT par_vlempbnd,
                     INPUT par_qtparbnd,
                     INPUT par_nrgarope,
                     INPUT par_nrperger,
                     INPUT tt-dados-analise.dtcnsspc,
                     INPUT par_nrinfcad,
                     INPUT tt-dados-analise.dtdrisco,
                     INPUT tt-dados-analise.vltotsfn,
                     INPUT tt-dados-analise.qtopescr,
                     INPUT tt-dados-analise.qtifoper,
                     INPUT par_nrliquid,
                     INPUT tt-dados-analise.vlopescr,
                     INPUT tt-dados-analise.vlrpreju,
                     INPUT par_nrpatlvr,
                     INPUT tt-dados-analise.dtoutspc,
                     INPUT tt-dados-analise.dtoutris,
                     INPUT tt-dados-analise.vlsfnout,
                     /* Rendimentos */
                     INPUT tt-rendimento.vlsalari,
                     INPUT tt-rendimento.vloutras,
                     INPUT tt-rendimento.vlalugue,
                     INPUT tt-rendimento.vlsalcon,
                     INPUT tt-rendimento.nmextemp,
                     INPUT tt-rendimento.flgdocje,
                     INPUT tt-rendimento.nrctacje,
                     INPUT tt-rendimento.nrcpfcjg,
                     INPUT tt-rendimento.vlmedfat,
                     INPUT tt-proposta-epr.dsobserv,
                     INPUT aux_dsdrendi,
                     /* Bens */
                     INPUT aux_dsdebens,
                     INPUT TRUE,  /** nao usa */
                     INPUT tt-rendimento.dsjusren,
                    OUTPUT TABLE tt-erro,
                    OUTPUT aux_idseqbem).

    IF  VALID-HANDLE(h-b1wgen0024) THEN
        DELETE PROCEDURE h-b1wgen0024.

    IF  RETURN-VALUE <> "OK"   THEN
        /*UNDO Gravar,*/ RETURN "NOK".


    IF  NOT VALID-HANDLE(h-b1wgen0043) THEN
        RUN sistema/generico/procedures/b1wgen0043.p
            PERSISTENT SET h-b1wgen0043.
    
    IF  NOT VALID-HANDLE(h-b1wgen0043)  THEN
        DO:
            MESSAGE "Handle invalido para BO b1wgen0043.".
            RETURN "NOK".
    END.


    FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper.

    RUN gera_rating IN h-b1wgen0043
                    (INPUT par_cdcooper,
                     INPUT 0,   /** Pac   **/
                     INPUT 0,   /** Caixa **/
                     INPUT par_cdoperad,
                     INPUT par_nmdatela,
                     INPUT 1,   /** Ayllos  **/
                     INPUT par_nrdconta,
                     INPUT 1,   /** Titular **/
                     INPUT crapdat.dtmvtolt,
                     INPUT crapdat.dtmvtopr,
                     INPUT par_inproces,
                     INPUT 90,
                     INPUT par_nrctrato,
                     INPUT FALSE,  /* NAO GRAVA */
                     INPUT TRUE,   /** Log **/
                    OUTPUT TABLE tt-erro,
                    OUTPUT TABLE tt-cabrel,
                    OUTPUT TABLE tt-impressao-coop,
                    OUTPUT TABLE tt-impressao-rating,
                    OUTPUT TABLE tt-impressao-risco,
                    OUTPUT TABLE tt-impressao-risco-tl,
                    OUTPUT TABLE tt-impressao-assina,
                    OUTPUT TABLE tt-efetivacao,
                    OUTPUT TABLE tt-ratings).

    IF  VALID-HANDLE(h-b1wgen0043) THEN
        DELETE PROCEDURE h-b1wgen0043.

    HIDE MESSAGE NO-PAUSE.

    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".


    FIND FIRST tt-impressao-risco NO-LOCK NO-ERROR.
    IF  AVAIL tt-impressao-risco THEN
        aux_dsdrisco = tt-impressao-risco.dsdrisco.
    ELSE
        aux_dsdrisco = "ERR".

    RETURN "OK".

END PROCEDURE.

/*............................................................................*/

PROCEDURE efetivar-rating-bndes:
    
    DEF INPUT  PARAM par_cdcooper AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_inproces AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_nrdconta AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_nrctrato AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF INPUT  PARAM par_dtmvtopr AS DATE                              NO-UNDO.
    DEF OUTPUT PARAM ret_dsdrisco AS CHAR                              NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    IF  NOT VALID-HANDLE(h-b1wgen0043) THEN
        RUN sistema/generico/procedures/b1wgen0043.p
            PERSISTENT SET h-b1wgen0043.

    IF  NOT VALID-HANDLE(h-b1wgen0043)  THEN
        DO:
            MESSAGE "Handle invalido para BO b1wgen0043.".
            RETURN "NOK".
    END.

    
    RUN gera_rating IN h-b1wgen0043 (INPUT par_cdcooper,
                                     INPUT 0,   /** Pac   **/
                                     INPUT 0,   /** Caixa **/
                                     INPUT par_cdoperad,
                                     INPUT par_nmdatela,
                                     INPUT 1,   /** Ayllos  **/
                                     INPUT par_nrdconta,
                                     INPUT 1,   /** Titular **/
                                     INPUT par_dtmvtolt,
                                     INPUT par_dtmvtopr,
                                     INPUT par_inproces,
                                     INPUT 90,
                                     INPUT par_nrctrato,
                                     INPUT TRUE,  /* GRAVA */
                                     INPUT TRUE,   /** Log **/
                                    OUTPUT TABLE tt-erro,
                                    OUTPUT TABLE tt-cabrel,
                                    OUTPUT TABLE tt-impressao-coop,
                                    OUTPUT TABLE tt-impressao-rating,
                                    OUTPUT TABLE tt-impressao-risco,
                                    OUTPUT TABLE tt-impressao-risco-tl,
                                    OUTPUT TABLE tt-impressao-assina,
                                    OUTPUT TABLE tt-efetivacao,
                                    OUTPUT TABLE tt-ratings).

    IF  VALID-HANDLE(h-b1wgen0043) THEN
        DELETE PROCEDURE h-b1wgen0043.

    HIDE MESSAGE NO-PAUSE.
        
    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".


    FIND FIRST tt-impressao-risco NO-LOCK NO-ERROR.
    IF  AVAIL tt-impressao-risco THEN
        ret_dsdrisco = tt-impressao-risco.dsdrisco.
    ELSE
        ret_dsdrisco = "ERR".

    RETURN "OK".

END PROCEDURE.

/*............................................................................*/

PROCEDURE consultar-rating-bndes:
    
    DEF INPUT  PARAM par_cdcooper AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_inproces AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF INPUT  PARAM par_nrdconta AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_inpessoa AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_nrcpfcgc AS DECI                              NO-UNDO.
    DEF INPUT  PARAM par_cdagenci AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_nrctrato AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_tppesqui AS CHAR                              NO-UNDO.

    DEF OUTPUT PARAM aux_vlctrbnd AS DECI                              NO-UNDO.
    DEF OUTPUT PARAM aux_qtparbnd AS INT                               NO-UNDO.
    DEF OUTPUT PARAM aux_nrinfcad AS INT                               NO-UNDO.
    DEF OUTPUT PARAM aux_dsinfcad AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM aux_nrgarope AS INT                               NO-UNDO.
    DEF OUTPUT PARAM aux_dsgarope AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM aux_nrliquid AS INT                               NO-UNDO.
    DEF OUTPUT PARAM aux_dsliquid AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM aux_nrpatlvr AS INT                               NO-UNDO.
    DEF OUTPUT PARAM aux_dspatlvr AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM aux_nrperger AS INT                               NO-UNDO.
    DEF OUTPUT PARAM aux_dsperger AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM aux_insitrat AS INT                               NO-UNDO.
    DEF OUTPUT PARAM aux_dssitcrt AS CHAR                              NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR          aux_dsdrisco AS CHAR                              NO-UNDO.

    ASSIGN aux_dsdrisco = "".

    /* Busca dados da proposta */
    IF  par_nrctrato = 0 OR par_nrctrato = ? THEN DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Contrato deve ser informado!".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.


    IF  par_tppesqui = "A" OR par_tppesqui = "E" THEN DO: /* PROPOSTOS */
        FIND FIRST crapprp WHERE crapprp.cdcooper = par_cdcooper
                             AND crapprp.nrdconta = par_nrdconta
                             AND crapprp.nrctrato = par_nrctrato
                             AND crapprp.tpctrato = 90 /* TP  Contrato BNDES */
                             AND crapprp.vlctrbnd > 0  /* Vlr Contrato BNDES */
                             NO-LOCK NO-ERROR.

        IF CAN-FIND(  FIRST crapnrc   /* RATING EFETIVO */
                      WHERE crapnrc.cdcooper = crapprp.cdcooper
                        AND crapnrc.nrdconta = crapprp.nrdconta
                        AND crapnrc.nrctrrat = crapprp.nrctrato
                        AND crapnrc.tpctrrat = 90) THEN DO:
        
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "PERMITIDO APENAS PARA RATINGs PROPOSTOS!".

            RUN gera_erro (INPUT crapprp.cdcooper,
                           INPUT 1,
                           INPUT 1,
                           INPUT 1, 
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".

        END.

    END.
    ELSE DO: /* EFETIVOS E PROPOSTOS */
        FIND FIRST crapprp WHERE crapprp.cdcooper = par_cdcooper
                             AND crapprp.nrdconta = par_nrdconta
                             AND crapprp.nrctrato = par_nrctrato
                             AND crapprp.tpctrato = 90 /* TP  Contrato BNDES */
                             AND crapprp.vlctrbnd > 0  /* Vlr Contrato BNDES */
                             NO-LOCK NO-ERROR.

        
        IF  par_tppesqui = "C" 
        AND NOT CAN-FIND(  FIRST crapnrc   /* RATING EFETIVO */
                           WHERE crapnrc.cdcooper = crapprp.cdcooper
                             AND crapnrc.nrdconta = crapprp.nrdconta
                             AND crapnrc.nrctrrat = crapprp.nrctrato
                             AND crapnrc.tpctrrat = 90)  THEN DO:

            IF  NOT VALID-HANDLE(h-b1wgen0043)  THEN
                RUN sistema/generico/procedures/b1wgen0043.p
                    PERSISTENT SET h-b1wgen0043.
            
            IF  NOT VALID-HANDLE(h-b1wgen0043)  THEN
                DO:
                    MESSAGE "Handle invalido para BO b1wgen0043.".
                    RETURN "NOK".
            END.
            
            
            FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper
               NO-LOCK NO-ERROR.


            RUN gera_rating IN h-b1wgen0043 (INPUT par_cdcooper,
                                             INPUT 0,   /** Pac   **/
                                             INPUT 0,   /** Caixa **/
                                             INPUT par_cdoperad,
                                             INPUT par_nmdatela,
                                             INPUT 1,   /** Ayllos  **/
                                             INPUT par_nrdconta,
                                             INPUT 1,   /** Titular **/
                                             INPUT crapdat.dtmvtolt,
                                             INPUT crapdat.dtmvtopr,
                                             INPUT par_inproces,
                                             INPUT 90,
                                             INPUT par_nrctrato,
                                             INPUT FALSE,  /* NAO GRAVA */
                                             INPUT TRUE,   /** Log **/
                                            OUTPUT TABLE tt-erro,
                                            OUTPUT TABLE tt-cabrel,
                                            OUTPUT TABLE tt-impressao-coop,
                                            OUTPUT TABLE tt-impressao-rating,
                                            OUTPUT TABLE tt-impressao-risco,
                                            OUTPUT TABLE tt-impressao-risco-tl,
                                            OUTPUT TABLE tt-impressao-assina,
                                            OUTPUT TABLE tt-efetivacao,
                                            OUTPUT TABLE tt-ratings).
            
            IF  VALID-HANDLE(h-b1wgen0043)  THEN
                DELETE PROCEDURE h-b1wgen0043.
    
            HIDE MESSAGE NO-PAUSE.
            
            IF  RETURN-VALUE = "NOK"  THEN
                RETURN "NOK".
            
            FIND FIRST tt-impressao-risco NO-LOCK NO-ERROR.
            IF  AVAIL tt-impressao-risco THEN
                aux_dsdrisco = tt-impressao-risco.dsdrisco.
            ELSE
                aux_dsdrisco = "ERR".
        END.
    END.



    IF  AVAIL crapprp THEN DO:

        FIND FIRST crapnrc
             WHERE crapnrc.cdcooper = crapprp.cdcooper
               AND crapnrc.nrdconta = crapprp.nrdconta
               AND crapnrc.nrctrrat = crapprp.nrctrato
               AND crapnrc.tpctrrat = 90
            NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapnrc THEN
            ASSIGN aux_insitrat = 0
                   aux_dssitcrt = "RISCO PROPOSTO: " + aux_dsdrisco .
        ELSE
            ASSIGN aux_insitrat = crapnrc.insitrat
                   aux_dssitcrt = "RISCO EFETIVO: " + STRING(crapnrc.indrisco).


        ASSIGN aux_nrinfcad = crapprp.nrinfcad
               aux_nrgarope = crapprp.nrgarope
               aux_nrliquid = crapprp.nrliquid
               aux_nrpatlvr = crapprp.nrpatlvr
               aux_nrperger = crapprp.nrperger
               aux_vlctrbnd = crapprp.vlctrbnd
               aux_qtparbnd = crapprp.qtparbnd.


       IF  par_inpessoa = 1 THEN DO:
            RUN busca_desc_opcoes(INPUT  1,
                                  INPUT  4,
                                  INPUT  aux_nrinfcad,
                                  OUTPUT aux_dsinfcad). /*nrinfcad*/

            RUN busca_desc_opcoes(INPUT  2,
                                  INPUT  2,
                                  INPUT  aux_nrgarope,
                                  OUTPUT aux_dsgarope). /*nrgarope*/

            RUN busca_desc_opcoes(INPUT  2,
                                  INPUT  3,
                                  INPUT  aux_nrliquid,
                                  OUTPUT aux_dsliquid). /*nrliquid*/

            RUN busca_desc_opcoes(INPUT  1,
                                  INPUT  8,
                                  INPUT  aux_nrpatlvr,
                                  OUTPUT aux_dspatlvr). /*nrpatlvr*/
        END.
        ELSE DO: /* juridica */
            RUN busca_desc_opcoes(INPUT  3,
                                  INPUT  3,
                                  INPUT  aux_nrinfcad,
                                  OUTPUT aux_dsinfcad). /*nrinfcad*/

            RUN busca_desc_opcoes(INPUT  4,
                                  INPUT  2,
                                  INPUT  aux_nrgarope,
                                  OUTPUT aux_dsgarope). /*nrgarope*/

            RUN busca_desc_opcoes(INPUT  4,
                                  INPUT  3,
                                  INPUT  aux_nrliquid,
                                  OUTPUT aux_dsliquid). /*nrliquid*/

            RUN busca_desc_opcoes(INPUT  3,
                                  INPUT  9,
                                  INPUT  aux_nrpatlvr,
                                  OUTPUT aux_dspatlvr). /*nrpatlvr*/

            RUN busca_desc_opcoes(INPUT  3,
                                  INPUT  11,
                                  INPUT  aux_nrperger,
                                  OUTPUT aux_dsperger). /*nrperger*/
        END.

    END. /* Fim IF AVAIL */

    ELSE DO:
        ASSIGN aux_dsinfcad = ""
               aux_dsgarope = ""
               aux_dsliquid = ""
               aux_dspatlvr = ""
               aux_dsperger = ""
               aux_nrinfcad = 0
               aux_nrgarope = 0     
               aux_nrliquid = 0     
               aux_nrpatlvr = 0
               aux_nrperger = 0
               aux_vlctrbnd = 0
               aux_qtparbnd = 0.
        
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 1,
                       INPUT 1,
                       INPUT 1, 
                       INPUT 356,
                       INPUT-OUTPUT aux_dscritic).
        RETURN "NOK".
    END.

    RETURN "OK".

END PROCEDURE.



PROCEDURE busca_desc_opcoes:
    
    DEF INPUT  PARAM par_nrtopico AS INT                                NO-UNDO.
    DEF INPUT  PARAM par_nritetop AS INT                                NO-UNDO.
    DEF INPUT  PARAM par_nrseqite AS INT                                NO-UNDO.
    DEF OUTPUT PARAM ret_dsseqite AS CHAR                               NO-UNDO.

    FIND FIRST craprad
         WHERE craprad.nrtopico = par_nrtopico   AND
               craprad.nritetop = par_nritetop   AND
               craprad.nrseqite = par_nrseqite   NO-LOCK NO-ERROR.

    IF  AVAIL craprad THEN
        ASSIGN ret_dsseqite = craprad.dsseqite.
    ELSE
        ASSIGN ret_dsseqite = "".

END PROCEDURE.



/*............................................................................*/
PROCEDURE busca_dados_associado:

   DEF INPUT  PARAM par_cdcooper AS INT                               NO-UNDO.
   DEF INPUT  PARAM par_nrdconta LIKE crapass.nrdconta                NO-UNDO.

   DEF OUTPUT PARAM TABLE FOR tt-associado.
   DEF OUTPUT PARAM TABLE FOR tt-erro.

   EMPTY TEMP-TABLE tt-associado.
   EMPTY TEMP-TABLE tt-erro.
   
   /* Busca o associado pesquisado  */
   FIND crapass WHERE crapass.cdcooper = par_cdcooper
                  AND crapass.nrdconta = par_nrdconta
              NO-LOCK NO-ERROR.
   
   IF  AVAILABLE  crapass  THEN DO:
       CREATE tt-associado.
       BUFFER-COPY crapass TO tt-associado.
   END.
   ELSE DO:
       RUN gera_erro (INPUT par_cdcooper,
                      INPUT 1,
                      INPUT 1,
                      INPUT 1, 
                      INPUT 9,
                      INPUT-OUTPUT aux_dscritic).
       RETURN "NOK".
   END.

   RETURN "OK".

END PROCEDURE.

/*...........................................................................*/

PROCEDURE retorna_contratos_bndes:
    
    DEF INPUT PARAM par_cdcooper AS INT                      NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INT                      NO-UNDO.
    DEF INPUT PARAM par_tipopesq AS CHAR                     NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-ctrbndes.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF          VAR aux_cdagenci AS INT                     NO-UNDO.


    EMPTY TEMP-TABLE tt-ctrbndes.
    EMPTY TEMP-TABLE tt-erro.



    IF  NOT CAN-DO("A,C,E,R",par_tipopesq) THEN DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Parametro 'Tipo Pesquisa' nao informado ou " +
                               "invalido!".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 1,
                       INPUT 1,
                       INPUT 1, 
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
        RETURN "NOK".
    END.


    FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper   AND
                             crapass.nrdconta = par_nrdconta
        NO-LOCK NO-ERROR.
    IF  AVAIL crapass THEN
        ASSIGN aux_cdagenci = crapass.cdagenci.
    ELSE
        ASSIGN aux_cdagenci = 0.

    IF  par_tipopesq = "A"
    OR  par_tipopesq = "E" THEN DO: /* APENAS PROPOSTOS */
        FOR EACH crapprp WHERE crapprp.cdcooper = par_cdcooper
                           AND crapprp.nrdconta = par_nrdconta
                           AND crapprp.tpctrato = 90
                           AND crapprp.vlctrbnd > 0
                          NO-LOCK USE-INDEX crapprp1:
    
            IF CAN-FIND( FIRST crapnrc   /* DESCONSIDERA RATINGs EFETIVOs */
                         WHERE crapnrc.cdcooper = crapprp.cdcooper
                           AND crapnrc.nrdconta = crapprp.nrdconta
                           AND crapnrc.nrctrrat = crapprp.nrctrato
                           AND crapnrc.tpctrrat = 90) THEN
                    NEXT. /* Nao lista EFETIVOS */

            CREATE tt-ctrbndes.
            ASSIGN tt-ctrbndes.nrctrato = crapprp.nrctrato
                   tt-ctrbndes.cdagenci = aux_cdagenci
                   tt-ctrbndes.nrdconta = crapprp.nrdconta
                   tt-ctrbndes.vlctrbnd = crapprp.vlctrbnd
                   tt-ctrbndes.dtmvtolt = crapprp.dtmvtolt.

         END.
    END.
    ELSE
    IF  par_tipopesq = "C" THEN DO: /* PROPOSTOS E EFETIVOS */
        FOR EACH crapprp WHERE crapprp.cdcooper = par_cdcooper
                           AND crapprp.nrdconta = par_nrdconta
                           AND crapprp.tpctrato = 90   
                           AND crapprp.vlctrbnd > 0
                           NO-LOCK USE-INDEX crapprp1:
    
            CREATE tt-ctrbndes.
            ASSIGN tt-ctrbndes.nrctrato = crapprp.nrctrato
                   tt-ctrbndes.cdagenci = aux_cdagenci
                   tt-ctrbndes.nrdconta = crapprp.nrdconta
                   tt-ctrbndes.vlctrbnd = crapprp.vlctrbnd
                   tt-ctrbndes.dtmvtolt = crapprp.dtmvtolt.

         END.
    END.
    ELSE DO: /* APENAS EFETIVOS */
        FOR EACH crapprp WHERE crapprp.cdcooper = par_cdcooper
                           AND crapprp.nrdconta = par_nrdconta
                           AND crapprp.tpctrato = 90
                           AND crapprp.vlctrbnd > 0
                           NO-LOCK USE-INDEX crapprp1:

            IF CAN-FIND( FIRST crapnrc
                         WHERE crapnrc.cdcooper = crapprp.cdcooper
                           AND crapnrc.nrdconta = crapprp.nrdconta
                           AND crapnrc.nrctrrat = crapprp.nrctrato
                           AND crapnrc.tpctrrat = 90) THEN DO:

                CREATE tt-ctrbndes.
                ASSIGN tt-ctrbndes.nrctrato = crapprp.nrctrato
                       tt-ctrbndes.cdagenci = aux_cdagenci
                       tt-ctrbndes.nrdconta = crapprp.nrdconta
                       tt-ctrbndes.vlctrbnd = crapprp.vlctrbnd
                       tt-ctrbndes.dtmvtolt = crapprp.dtmvtolt.
            END.

         END.
    END.

    FIND FIRST tt-ctrbndes NO-LOCK NO-ERROR.
    IF  NOT AVAIL tt-ctrbndes THEN DO:

        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Nao existem contratos BNDES para essa Conta/DV".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 1,
                       INPUT 1,
                       INPUT 1,
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
        RETURN "NOK".
    END.

    RETURN "OK".

END PROCEDURE.

/*...........................................................................*/

PROCEDURE relatorio-bndes-efetivados:
    
    DEF INPUT PARAM par_cdcooper AS INT                               NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INT                               NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INT                               NO-UNDO.
    DEF INPUT PARAM par_dtrefini AS DATE                              NO-UNDO.
    DEF INPUT PARAM par_dtreffim AS DATE                              NO-UNDO.
    DEF INPUT PARAM par_tipopesq AS LOGI                              NO-UNDO.
    /* TRUE - EFETIVO  /  FALSE - PROPOSTO */

    DEF OUTPUT PARAM TABLE FOR tt-ctrbndes.
    DEF OUTPUT PARAM TABLE FOR tt-erro.


    EMPTY TEMP-TABLE tt-ctrbndes.
    EMPTY TEMP-TABLE tt-erro.



    IF  par_tipopesq = TRUE
    AND par_nrdconta <> 0 THEN DO:
        FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper   AND
                                 crapass.nrdconta = par_nrdconta
            NO-LOCK NO-ERROR.
        IF  NOT AVAIL crapass THEN DO:
            ASSIGN aux_cdcritic = 9.

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 1,
                           INPUT 1,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".

        END.
    END.


    IF  (par_dtrefini  = ? OR par_dtreffim = ?) THEN DO:

            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Datas inicio e fim devem ser " +
                                  "informadas!".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 1,
                           INPUT 1,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
    END.

    IF  (par_dtreffim < par_dtrefini) THEN DO:

            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Data Fim superior a data Inicio!".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 1,
                           INPUT 1,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
    END.


    IF  par_tipopesq = FALSE THEN DO: /* APENAS PROPOSTOS - SEM NRC */

        DO WHILE (par_dtrefini <= par_dtreffim):

            FOR EACH crapprp WHERE crapprp.cdcooper = par_cdcooper
                               AND crapprp.dtmvtolt = par_dtrefini
                               AND crapprp.tpctrato = 90
                               AND crapprp.vlctrbnd > 0
                           NO-LOCK USE-INDEX crapprp2,
               FIRST crapass WHERE crapass.cdcooper = crapprp.cdcooper
                               AND crapass.nrdconta = crapprp.nrdconta
                               AND (crapass.cdagenci = par_cdagenci OR
                                        par_cdagenci = 0)
                          NO-LOCK:
        
                IF CAN-FIND( FIRST crapnrc   /* DESCONSIDERA RATINGs EFETIVOs */
                             WHERE crapnrc.cdcooper = crapprp.cdcooper
                               AND crapnrc.nrdconta = crapprp.nrdconta
                               AND crapnrc.nrctrrat = crapprp.nrctrato
                               AND crapnrc.tpctrrat = 90) THEN
                        NEXT. /* Nao lista EFETIVOS */
    
                CREATE tt-ctrbndes.
                ASSIGN tt-ctrbndes.nrctrato = crapprp.nrctrato
                       tt-ctrbndes.tpctrato = crapnrc.tpctrrat
                       tt-ctrbndes.cdagenci = crapass.cdagenci
                       tt-ctrbndes.nrdconta = crapprp.nrdconta
                       tt-ctrbndes.vlctrbnd = crapprp.vlctrbnd
                       tt-ctrbndes.dtmvtolt = crapprp.dtmvtolt
                       tt-ctrbndes.nmprimtl = crapass.nmprimtl.

            END.
            ASSIGN par_dtrefini = par_dtrefini + 1.
        END. /* FIM do DO WHILE de Datas */
    END.
    ELSE DO: /* APENAS EFETIVOS */

        DO WHILE (par_dtrefini <= par_dtreffim):
        
            FOR EACH crapprp WHERE   crapprp.cdcooper  = par_cdcooper
                               AND   crapprp.dtmvtolt  = par_dtrefini
                               AND   crapprp.tpctrato  = 90
                               AND ( crapprp.nrdconta  = par_nrdconta OR
                                         par_nrdconta  = 0)
                               AND   crapprp.vlctrbnd  > 0
                           NO-LOCK USE-INDEX crapprp2,
               FIRST crapass WHERE   crapass.cdcooper  = crapprp.cdcooper
                               AND   crapass.nrdconta  = crapprp.nrdconta
                               AND ( crapass.cdagenci  = par_cdagenci OR
                                         par_cdagenci  = 0)
                   NO-LOCK:
    
                FIND FIRST crapnrc
                     WHERE crapnrc.cdcooper = crapprp.cdcooper
                       AND crapnrc.nrdconta = crapprp.nrdconta
                       AND crapnrc.nrctrrat = crapprp.nrctrato
                       AND crapnrc.tpctrrat = 90
                   NO-LOCK NO-ERROR.
    
                IF  AVAIL crapnrc THEN DO:
    
                    FIND FIRST crapope
                         WHERE crapope.cdcooper = crapnrc.cdcooper
                           AND crapope.cdoperad = crapnrc.cdoperad
                       NO-LOCK NO-ERROR.
    
                    CREATE tt-ctrbndes.
                    ASSIGN tt-ctrbndes.nrctrato = crapprp.nrctrato
                           tt-ctrbndes.tpctrato = crapnrc.tpctrrat
                           tt-ctrbndes.cdagenci = crapass.cdagenci
                           tt-ctrbndes.nrdconta = crapprp.nrdconta
                           tt-ctrbndes.vlctrbnd = crapprp.vlctrbnd
                           tt-ctrbndes.dtmvtolt = crapprp.dtmvtolt
                           tt-ctrbndes.inrisctl = crapnrc.inrisctl
                           tt-ctrbndes.nrnotrat = crapnrc.nrnotrat
                           tt-ctrbndes.indrisco = crapnrc.indrisco
                           tt-ctrbndes.nrnotatl = crapnrc.nrnotatl
                           tt-ctrbndes.dteftrat = crapnrc.dteftrat
                           tt-ctrbndes.cdoperad = crapnrc.cdoperad
                           tt-ctrbndes.nmprimtl = crapass.nmprimtl
                           tt-ctrbndes.nmoperad = IF  AVAIL crapope THEN
                                                      crapope.nmoperad
                                                  ELSE
                                                      ""
                           .
                END.
    
            END.

            ASSIGN par_dtrefini = par_dtrefini + 1.
        END. /* FIM do DO WHILE de Datas */
    END.

    FIND FIRST tt-ctrbndes NO-LOCK NO-ERROR.
    IF  NOT AVAIL tt-ctrbndes THEN DO:

        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Nao existem propostas BNDES com os parametros" +
                              " informados em tela".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 1,
                       INPUT 1,
                       INPUT 1,
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
        RETURN "NOK".
    END.

                    
    FIND FIRST crapage
         WHERE crapage.cdcooper = par_cdcooper
           AND crapage.cdagenci = tt-ctrbndes.cdagenci
       NO-LOCK NO-ERROR.

    IF   AVAIL crapage   THEN
         ASSIGN tt-ctrbndes.dsagenci = crapage.nmresage.
     ELSE
         ASSIGN tt-ctrbndes.dsagenci = "AGENCIA NAO CADASTRADA.".


    RETURN "OK".

END PROCEDURE.

/*...........................................................................*/

PROCEDURE relatorio-bndes-propostos:
    
    DEF INPUT  PARAM par_cdcooper AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_nrdconta AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_cdagenci AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_dtrefini AS DATE                              NO-UNDO.
    DEF INPUT  PARAM par_dtreffim AS DATE                              NO-UNDO.
    DEF INPUT  PARAM par_idorigem AS INT                               NO-UNDO.

    DEF OUTPUT PARAM ret_nmarquiv AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM ret_nmarqpdf AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-ctrbndes.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-ctrbndes.
    EMPTY TEMP-TABLE tt-erro.

    DEF VAR aux_nmdircop AS CHAR                        NO-UNDO.
    DEF VAR aux_dsagenci AS CHAR                        NO-UNDO.
   
    DEF VAR tel_cddopcao AS CHAR FORMAT "!(1)" INIT "T" NO-UNDO.



    FIND FIRST crapcop
         WHERE crapcop.cdcooper = par_cdcooper
       NO-LOCK NO-ERROR.

    FIND FIRST crapdat
         WHERE crapdat.cdcooper = par_cdcooper
       NO-LOCK NO-ERROR.
    
    FORM aux_dsagenci FORMAT "x(100)" 
         WITH NO-LABEL WIDTH 132 FRAME f_pac.

    FORM tt-relat.cdagenci COLUMN-LABEL "PA"            FORMAT "zz9"
         tt-relat.nrdconta COLUMN-LABEL "Conta/dv"      FORMAT "zzzz,zzz,9"
         tt-relat.nmprimtl COLUMN-LABEL "Nome"          FORMAT "x(25)"
         tt-relat.vlctrbnd COLUMN-LABEL "Valor"         FORMAT "zzz,zzz,zz9.99"
         tt-relat.nrctrato COLUMN-LABEL "Contrato"      FORMAT "z,zzz,zz9"
         WITH DOWN WIDTH 133 FRAME f_relatorio.

    FORM HEADER
         crapcop.nmrescop           AT   1 FORMAT "x(15)"
         "-"                        AT  16
         "OPERACOES BNDES SEM RATING EFETIVADO" AT  18
         "- REF."                   AT  58
         crapdat.dtmvtolt               AT  65 FORMAT "99/99/99"
         "EM"                       AT  98
         TODAY                      AT 101 FORMAT "99/99/99"
         "AS"                       AT 110
         STRING(TIME,"HH:MM")       AT 113 FORMAT "x(5)"
         "HR PAG.:"                 AT 119
         PAGE-NUMBER(str_1)         AT 127 FORMAT "zzzz9"
         SKIP(1)
         WITH PAGE-TOP NO-BOX NO-ATTR-SPACE WIDTH 132 FRAME f_cabecalho.



    IF  (par_dtrefini  = ? OR par_dtreffim = ?) THEN DO:

            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Datas inicio e fim devem ser " +
                                  "informadas!".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 1,
                           INPUT 1,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
    END.

    IF  (par_dtreffim < par_dtrefini) THEN DO:

            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Data Fim superior a data Inicio!".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 1,
                           INPUT 1,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
    END.


    DO WHILE (par_dtrefini <= par_dtreffim):

        FOR EACH crapprp WHERE   crapprp.cdcooper = par_cdcooper
                           AND   crapprp.dtmvtolt = par_dtrefini
                           AND   crapprp.tpctrato = 90
                           AND   crapprp.vlctrbnd > 0
                       NO-LOCK USE-INDEX crapprp2,
           FIRST crapass WHERE   crapass.cdcooper = crapprp.cdcooper
                           AND   crapass.nrdconta = crapprp.nrdconta
                           AND ( crapass.cdagenci = par_cdagenci OR
                                 par_cdagenci = 0)
                      NO-LOCK:
        
            IF CAN-FIND( FIRST crapnrc   /* DESCONSIDERA RATINGs EFETIVOs */
                         WHERE crapnrc.cdcooper = crapprp.cdcooper
                           AND crapnrc.nrdconta = crapprp.nrdconta
                           AND crapnrc.nrctrrat = crapprp.nrctrato
                           AND crapnrc.tpctrrat = 90) THEN
                    NEXT. /* Nao lista EFETIVOS */
    
            CREATE tt-relat.
            ASSIGN tt-relat.nrctrato = crapprp.nrctrato
                   tt-relat.cdagenci = crapass.cdagenci
                   tt-relat.nrdconta = crapprp.nrdconta
                   tt-relat.vlctrbnd = crapprp.vlctrbnd
                   tt-relat.dtmvtolt = crapprp.dtmvtolt
                   tt-relat.nmprimtl = crapass.nmprimtl.
        END.

        ASSIGN par_dtrefini = par_dtrefini + 1.
    END. /* FIM do DO WHILE de Datas */


    FIND FIRST tt-relat NO-LOCK NO-ERROR.
    IF  NOT AVAIL tt-relat THEN DO:

        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Nao existem propostas BNDES com os parametros" +
                              " informados em tela".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 1,
                       INPUT 1,
                       INPUT 1,
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
        RETURN "NOK".
    END.

                    
    FIND FIRST crapage
         WHERE crapage.cdcooper = par_cdcooper
           AND crapage.cdagenci = tt-relat.cdagenci
       NO-LOCK NO-ERROR.

    IF   AVAIL crapage   THEN
         ASSIGN tt-relat.dsagenci = crapage.nmresage.
    ELSE
         ASSIGN tt-relat.dsagenci = "AGENCIA NAO CADASTRADA.".



    /*** PROCESSSAMENTO DO RELATORIO ***/

    /* Busca descricao da Cooperativa */
   FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper
                         NO-LOCK NO-ERROR.

   IF  AVAIL crapcop THEN
       ASSIGN aux_nmdircop = "/usr/coop/" + crapcop.dsdircop +
                             "/rl/"
              ret_nmarquiv = aux_nmdircop + "crrl999_" + STRING(TIME) + ".lst".
              ret_nmarqpdf = aux_nmdircop + "crrl999_" + STRING(TIME) + ".ex".

    OUTPUT STREAM str_1 TO VALUE (ret_nmarquiv) PAGED PAGE-SIZE 82. 


    VIEW STREAM str_1 FRAME f_cabecalho.


    FOR EACH tt-relat NO-LOCK BREAK BY tt-relat.cdagenci
                                    BY tt-relat.nrdconta
                                    BY tt-relat.nrctrato:
     
        DISPLAY STREAM str_1 tt-relat.cdagenci 
                             tt-relat.nrdconta
                             tt-relat.nmprimtl
                             tt-relat.vlctrbnd
                             tt-relat.nrctrato
                        WITH FRAME f_relatorio.

        DOWN WITH FRAME f_relatorio.

    END.

    OUTPUT STREAM str_1 CLOSE.


    IF  par_idorigem = 5 THEN DO: /* INTERNET */
        DO WHILE TRUE:

            UNIX SILENT VALUE("cp " + ret_nmarquiv + " " + ret_nmarqpdf +
                              " 2> /dev/null").

            RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                SET h-b1wgen0024.

            IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                DO:
                   ASSIGN aux_cdcritic = 0
                          aux_dscritic = "Handle invalido para BO " +
                                         "b1wgen0024.".
          
                   RUN gera_erro (INPUT par_cdcooper,
                                  INPUT 0,
                                  INPUT 0,
                                  INPUT 1, /*sequencia*/
                                  INPUT aux_cdcritic,
                                  INPUT-OUTPUT aux_dscritic).
        
                   RETURN "NOK".
                END.
            
            RUN envia-arquivo-web IN h-b1wgen0024
                ( INPUT par_cdcooper,
                  INPUT 1, /* cdagenci */
                  INPUT 1, /* nrdcaixa */
                  INPUT ret_nmarqpdf,
                 OUTPUT ret_nmarqpdf,
                 OUTPUT TABLE tt-erro ).

            IF  VALID-HANDLE(h-b1wgen0024)  THEN
                DELETE PROCEDURE h-b1wgen0024.

            IF  RETURN-VALUE <> "OK" THEN
                RETURN "NOK".
            
            LEAVE.

        END. /** Fim do DO WHILE TRUE **/
    END. /* END do IF idorigem */

    RETURN "OK".

END PROCEDURE.

PROCEDURE busca-contrato. 

    DEF INPUT PARAM par_cdcooper AS INT                               NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INT                               NO-UNDO.

    DEF INPUT PARAM par_tipopesq AS CHAR                              NO-UNDO.

    DEF INPUT  PARAM par_cdoperad AS CHAR                             NO-UNDO.
    DEF INPUT  PARAM par_nmdatela AS CHAR                             NO-UNDO.
    DEF INPUT  PARAM par_inproces AS INT                              NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                             NO-UNDO.
    DEF INPUT  PARAM par_inpessoa AS INT                              NO-UNDO.
    DEF INPUT  PARAM par_nrcpfcgc AS DECI                             NO-UNDO.
    DEF INPUT  PARAM par_cdagenci AS INT                              NO-UNDO.
    DEF INPUT  PARAM par_nrctrato AS INT                              NO-UNDO.
    DEF INPUT  PARAM par_tppesqui AS CHAR                             NO-UNDO.
    
    DEF OUTPUT PARAM aux_vlctrbnd AS DECI                              NO-UNDO.
    DEF OUTPUT PARAM aux_qtparbnd AS INT                               NO-UNDO.
    DEF OUTPUT PARAM aux_nrinfcad AS INT                               NO-UNDO.
    DEF OUTPUT PARAM aux_dsinfcad AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM aux_nrgarope AS INT                               NO-UNDO.
    DEF OUTPUT PARAM aux_dsgarope AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM aux_nrliquid AS INT                               NO-UNDO.
    DEF OUTPUT PARAM aux_dsliquid AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM aux_nrpatlvr AS INT                               NO-UNDO.
    DEF OUTPUT PARAM aux_dspatlvr AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM aux_nrperger AS INT                               NO-UNDO.
    DEF OUTPUT PARAM aux_dsperger AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM aux_insitrat AS INT                               NO-UNDO.
    DEF OUTPUT PARAM aux_dssitcrt AS CHAR                              NO-UNDO.

    RUN busca_dados_associado
            ( INPUT par_cdcooper,   
              INPUT par_nrdconta,
              OUTPUT TABLE tt-associado,
              OUTPUT TABLE tt-erro ).     

    RUN retorna_contratos_bndes
            ( INPUT par_cdcooper,
              INPUT par_nrdconta,
              INPUT par_tipopesq,
              OUTPUT TABLE tt-ctrbndes, 
              OUTPUT TABLE tt-erro ).
    
    RUN consultar-rating-bndes
            ( INPUT par_cdcooper,
              INPUT par_cdoperad, 
              INPUT par_nmdatela,
              INPUT par_inproces,
              INPUT par_dtmvtolt,
              INPUT par_nrdconta,
              INPUT par_inpessoa,
              INPUT par_nrcpfcgc,
              INPUT par_cdagenci,
              INPUT par_nrctrato,
              INPUT par_tppesqui,
              OUTPUT aux_vlctrbnd,  
              OUTPUT aux_qtparbnd,
              OUTPUT aux_nrinfcad, 
              OUTPUT aux_dsinfcad, 
              OUTPUT aux_nrgarope, 
              OUTPUT aux_dsgarope, 
              OUTPUT aux_nrliquid, 
              OUTPUT aux_dsliquid, 
              OUTPUT aux_nrpatlvr, 
              OUTPUT aux_dspatlvr, 
              OUTPUT aux_nrperger, 
              OUTPUT aux_dsperger, 
              OUTPUT aux_insitrat, 
              OUTPUT aux_dssitcrt,
              OUTPUT TABLE tt-erro ).

END PROCEDURE.
/*...........................................................................*/

PROCEDURE consulta-conta:

    DEF INPUT  PARAM par_cdcooper LIKE crapcop.cdcooper                NO-UNDO.
    DEF INPUT  PARAM par_nrdconta LIKE crapass.nrdconta                NO-UNDO.

    DEF INPUT  PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_cdagenci LIKE crapass.cdagenci                NO-UNDO.
    DEF INPUT  PARAM par_tipopesq AS CHAR                               NO-UNDO.

    DEF OUTPUT PARAM par_qtrequis AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM par_nmprimtl AS CHAR        FORMAT "x(30)"        NO-UNDO.
    DEF OUTPUT PARAM par_dsmsgcnt AS CHAR                              NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-associado.
    DEF OUTPUT PARAM TABLE FOR tt-ctrbndes.
    DEF OUTPUT PARAM TABLE FOR tt-erro.


    IF par_nrdconta <> 0 THEN DO:
        IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
            RUN sistema/generico/procedures/b1wgen9999.p
                PERSISTENT SET h-b1wgen9999.

        RUN dig_fun IN h-b1wgen9999 
                  ( INPUT par_cdcooper,
                    INPUT par_cdagenci,
                    INPUT 0,
                    INPUT-OUTPUT par_nrdconta,
                   OUTPUT TABLE tt-erro ).
        
        IF  VALID-HANDLE(h-b1wgen9999) THEN
            DELETE PROCEDURE h-b1wgen9999.
        
        IF  TEMP-TABLE tt-erro:HAS-RECORDS  THEN
            RETURN "NOK".
        
        IF  NOT VALID-HANDLE(h-b1wgen0040) THEN
            RUN sistema/generico/procedures/b1wgen0040.p
                PERSISTENT SET h-b1wgen0040.
        
        RUN verifica-conta IN h-b1wgen0040
                           ( INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT 0,
                             INPUT par_cdoperad,
                             INPUT par_nmdatela,
                             INPUT 1,
                             INPUT par_nrdconta,
                             INPUT 0,
                             INPUT YES,
                            OUTPUT par_nmprimtl, 
                            OUTPUT par_qtrequis, 
                            OUTPUT par_dsmsgcnt, 
                            OUTPUT TABLE tt-erro).
        
        IF  VALID-HANDLE(h-b1wgen0040) THEN
            DELETE PROCEDURE h-b1wgen0040.
        
        /* Busca dados Cooperado */
        RUN busca_dados_associado
                                ( INPUT par_cdcooper,
                                  INPUT par_nrdconta,
                                 OUTPUT TABLE tt-associado,
                                 OUTPUT TABLE tt-erro ).
        
        IF  TEMP-TABLE tt-erro:HAS-RECORDS  THEN
            RETURN "NOK".

        IF  par_tipopesq = "C" OR
            par_tipopesq = "E" OR
            par_tipopesq = "A" THEN DO:

            RUN retorna_contratos_bndes (INPUT par_cdcooper,
                                         INPUT par_nrdconta,
                                         INPUT par_tipopesq,
                                         OUTPUT TABLE tt-ctrbndes,
                                         OUTPUT TABLE tt-erro ).

            IF  TEMP-TABLE tt-erro:HAS-RECORDS  THEN
                RETURN "NOK".
        END.
        
    END.
    ELSE
    IF (par_tipopesq = "I" OR
        par_tipopesq = "A" OR
        par_tipopesq = "E" OR
        par_tipopesq = "C") AND
        par_nrdconta = 0   THEN DO:

        ASSIGN aux_cdcritic = 8
               aux_dscritic = "".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
        
        RETURN "NOK".

    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE validacao-campos-ratbnd:

    DEF INPUT  PARAM par_cdcooper LIKE crapcop.cdcooper                NO-UNDO.
    DEF INPUT  PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF INPUT  PARAM par_nrdconta LIKE crapass.nrdconta                NO-UNDO.
    DEF INPUT  PARAM par_nrgarope AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_nrinfcad AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_nrliquid AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_nrpatlvr AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_nrperger AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_nmdatela AS CHAR                              NO-UNDO.
     
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    /* Validar campos do RATING */
    IF  NOT VALID-HANDLE(h-b1wgen0043) THEN
        RUN sistema/generico/procedures/b1wgen0043.p
        PERSISTENT SET h-b1wgen0043.

    IF  NOT VALID-HANDLE(h-b1wgen0043)   THEN DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Handle invalido para a BO b1wgen0043.".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
        
        RETURN "NOK".
    END.

    RUN valida-itens-rating IN h-b1wgen0043 
                           (INPUT  par_cdcooper,
                            INPUT  0,
                            INPUT  0,
                            INPUT  par_cdoperad,
                            INPUT  par_dtmvtolt,
                            INPUT  par_nrdconta,
                            INPUT  par_nrgarope,
                            INPUT  par_nrinfcad,
                            INPUT  par_nrliquid,
                            INPUT  par_nrpatlvr,
                            INPUT  par_nrperger,
                            INPUT  1, /* Titular */
                            INPUT  1, /* Ayllos par_idorigem */
                            INPUT  par_nmdatela,
                            INPUT  FALSE,
                           OUTPUT TABLE tt-erro).
    
    IF  VALID-HANDLE(h-b1wgen0043) THEN
        DELETE PROCEDURE h-b1wgen0043.
    
    IF  RETURN-VALUE <> "OK"   THEN
        RETURN "NOK".

    RETURN "OK".

END PROCEDURE.


PROCEDURE validacao-rating-bndes:

    DEF INPUT  PARAM par_cdcooper LIKE crapcop.cdcooper                NO-UNDO.
    DEF INPUT  PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_inproces AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_nrdconta LIKE crapass.nrdconta                NO-UNDO.
    DEF INPUT  PARAM par_inpessoa AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_nrcpfcgc AS DECI                              NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF INPUT  PARAM par_inconfir AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_vlempbnd AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_qtparbnd AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_nrinfcad AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_nrgarope AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_nrliquid AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_nrpatlvr AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_nrperger AS INTE                              NO-UNDO.

    DEF OUTPUT PARAM ret_nrctrato AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM ret_dsdrisco AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM ret_criticas AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM ret_tpcritic AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM ret_dscritic AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM ret_flgvalid AS LOGICAL                           NO-UNDO.
    DEF OUTPUT PARAM ret_flgsuces AS LOGICAL                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-msg-confirma.
    DEF OUTPUT PARAM TABLE FOR tt-grupo.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-msg-confirma.
    EMPTY TEMP-TABLE tt-grupo.
    EMPTY TEMP-TABLE tt-erro.

    DEF VAR aux_inconfi2 AS INTE                                       NO-UNDO.
    
    /* Se nao criticar Valor Maximo Utilizado (aux_inconfirm = 2),
    passa variavel (aux_inconfirm = 3) para validar Valor
    Maximo Legal */

    /* par_inconfir = 2  --> Valida Valor Max. Utilizado
       par_inconfir = 3  --> Valida Valor Max. Legal */

    ASSIGN aux_inconfi2 = 30.

    /* Processo de Validação */
    RUN validar-rating-bndes (INPUT par_cdcooper,
                              INPUT par_cdoperad,
                              INPUT par_nmdatela,
                              INPUT par_inproces,
                              INPUT 1,   /* Ayllos */
                              INPUT par_nrdconta,
                              INPUT par_inpessoa,
                              INPUT par_nrcpfcgc,
                              INPUT par_dtmvtolt,
                              INPUT par_inconfir,
                              INPUT aux_inconfi2,
                              INPUT "I",
                              /* Parametros da Tela */
                              INPUT par_vlempbnd,
                              INPUT par_qtparbnd,
                              INPUT par_nrinfcad,
                              INPUT par_nrgarope,
                              INPUT par_nrliquid,
                              INPUT par_nrpatlvr,
                              INPUT par_nrperger,
                              INPUT 0,
                             OUTPUT ret_nrctrato,
                             OUTPUT ret_dsdrisco,
                             OUTPUT TABLE tt-erro,
                             OUTPUT TABLE tt-msg-confirma,
                             OUTPUT TABLE tt-grupo).

    IF  RETURN-VALUE <> "OK" THEN DO:

        ASSIGN ret_flgvalid = FALSE   /* Encerra o Processo */
               ret_flgsuces = FALSE   /* Ocorreu um erro    */
               ret_criticas = "erro". /* Tipo de Ocorrência */

        /* Atingiu Valor Maximo LEGAL e/ou ULTILIZADO, mostra 
        contas do grupo economico caso exista e ABORTA operacao */

        /*Se a conta em questao faz parte de um grupo economico,
        serao listados as contas que se relacionam com a mesma.*/

        IF  NOT CAN-FIND(FIRST tt-erro WHERE tt-erro.nrsequen > 1) THEN DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            ASSIGN ret_tpcritic = 1. /* Mostra o erro encontrado */

            IF  AVAILABLE tt-erro  THEN DO:

                FIND FIRST tt-msg-confirma NO-LOCK NO-ERROR.

                IF AVAIL tt-msg-confirma THEN
                    ASSIGN ret_dscritic = tt-msg-confirma.dsmensag.
                ELSE
                    ASSIGN ret_dscritic = tt-erro.dscritic.

            END.
            ELSE
                ASSIGN ret_dscritic = "Erro na efetivacao da proposta.".
    
            RETURN "NOK".
        END.
        ELSE DO:
            
            /* Verifica se encontra o erro 830 entre os demais ocorridos */
            FIND tt-erro WHERE tt-erro.cdcritic = 830
                            NO-LOCK NO-ERROR.
    
            /** Faltam dados cadastrais **/
            IF  AVAILABLE tt-erro  THEN
                ASSIGN ret_dscritic = tt-erro.dscritic.
            ELSE
                ASSIGN ret_dscritic = "Erro na efetivacao da proposta.".
    
            ASSIGN ret_tpcritic = 2. /* Mostra todos os erros encontrados */
            
            RETURN "NOK".

        END.
            
        RETURN "NOK".
        
    END. /* END do RETURN-VALUE <> "OK" */

    /* Verifica se atingiu Valor Maximo Utilizado(aux_inconfir = 2)*/

    FIND FIRST tt-msg-confirma NO-LOCK NO-ERROR.

    /* Se tem mensagem de confirmacao e foi RETURN "OK" */
    IF  AVAIL tt-msg-confirma  THEN DO:

        ASSIGN ret_flgvalid = FALSE   /* Encerra o Processo */
               ret_flgsuces = FALSE   /* Ocorreu um erro    */
               ret_criticas = "critica" /* Tipo de ocorrencia */
               ret_tpcritic = 0
               ret_dscritic = "".

        RETURN "OK".

    END.
    ELSE DO:

        /* Se nao houve criticas com aux_inconfir = 2 e aux_inconfir = 3,
        quando for aux_inconfir = 3, mostra contas do grupo economico
        quando existir e finaliza operacao */

        ASSIGN ret_flgvalid = TRUE   /* Encerra o Processo */
               ret_flgsuces = TRUE   /* Ocorreu um erro    */
               ret_criticas = "sucesso" /* Tipo de ocorrencia */
               ret_tpcritic = 0
               ret_dscritic = "".

        RETURN "OK".

    END.

    RETURN "OK".
    
END PROCEDURE.


PROCEDURE consulta-informacao-ratbnd:

    DEF INPUT  PARAM par_cdcooper AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_inproces AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF INPUT  PARAM par_nrdconta AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_inpessoa AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_nrcpfcgc AS DECI                              NO-UNDO.
    DEF INPUT  PARAM par_cdagenci AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_nrctrato AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_tppesqui AS CHAR                              NO-UNDO.

    DEF OUTPUT PARAM aux_vlctrbnd AS DECI                              NO-UNDO.
    DEF OUTPUT PARAM aux_qtparbnd AS INT                               NO-UNDO.
    DEF OUTPUT PARAM aux_nrinfcad AS INT                               NO-UNDO.
    DEF OUTPUT PARAM aux_dsinfcad AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM aux_nrgarope AS INT                               NO-UNDO.
    DEF OUTPUT PARAM aux_dsgarope AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM aux_nrliquid AS INT                               NO-UNDO.
    DEF OUTPUT PARAM aux_dsliquid AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM aux_nrpatlvr AS INT                               NO-UNDO.
    DEF OUTPUT PARAM aux_dspatlvr AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM aux_nrperger AS INT                               NO-UNDO.
    DEF OUTPUT PARAM aux_dsperger AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM aux_insitrat AS INT                               NO-UNDO.
    DEF OUTPUT PARAM aux_dssitcrt AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM ret_tpcritic AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM ret_dscritic AS CHAR                              NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR          aux_dsdrisco AS CHAR                              NO-UNDO.
    
    RUN consultar-rating-bndes (INPUT par_cdcooper, 
                                INPUT par_cdoperad, 
                                INPUT par_nmdatela, 
                                INPUT par_inproces,
                                INPUT par_dtmvtolt,
                                INPUT par_nrdconta, 
                                INPUT par_inpessoa, 
                                INPUT par_nrcpfcgc, 
                                INPUT par_cdagenci,
                                INPUT par_nrctrato,
                                INPUT par_tppesqui,
                                OUTPUT aux_vlctrbnd, 
                                OUTPUT aux_qtparbnd, 
                                OUTPUT aux_nrinfcad, 
                                OUTPUT aux_dsinfcad, 
                                OUTPUT aux_nrgarope, 
                                OUTPUT aux_dsgarope,
                                OUTPUT aux_nrliquid, 
                                OUTPUT aux_dsliquid, 
                                OUTPUT aux_nrpatlvr, 
                                OUTPUT aux_dspatlvr,
                                OUTPUT aux_nrperger, 
                                OUTPUT aux_dsperger,
                                OUTPUT aux_insitrat,
                                OUTPUT aux_dssitcrt,
                                OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN DO:
        
        IF NOT CAN-FIND(FIRST tt-erro WHERE tt-erro.nrsequen > 1) THEN DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            ASSIGN ret_tpcritic = 1. /* Mostra o erro encontrado */

            IF  AVAILABLE tt-erro  THEN
                ASSIGN ret_dscritic = tt-erro.dscritic.
            ELSE
                ASSIGN ret_dscritic = "Erro na efetivacao da proposta.".
    
            RETURN "NOK".
        END.
        ELSE DO:
            
            /* Verifica de encontra o erro 830 entre os demais ocorridos */
            FIND tt-erro WHERE tt-erro.cdcritic = 830
                            NO-LOCK NO-ERROR.
    
            /** Faltam dados cadastrais **/
            IF  AVAILABLE tt-erro  THEN
                ASSIGN ret_dscritic = tt-erro.dscritic.
            ELSE
                ASSIGN ret_dscritic = "Erro na efetivacao da proposta.".
    
            ASSIGN ret_tpcritic = 2. /* Mostra todos os erros encontrados */
            
            RETURN "NOK".

        END.
 
    END.
    ELSE DO:
        ASSIGN ret_tpcritic = 0
               ret_dscritic = "".
    
        RETURN "OK".
    END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE efetivacao-rating:

    DEF INPUT  PARAM par_cdcooper LIKE crapcop.cdcooper                NO-UNDO.
    DEF INPUT  PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_inproces AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_nrdconta LIKE crapass.nrdconta                NO-UNDO.
    DEF INPUT  PARAM par_nrctrato AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF INPUT  PARAM par_dtmvtopr AS DATE                              NO-UNDO.

    DEF OUTPUT PARAM ret_tpcritic AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM ret_dscritic AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM ret_dsdrisco AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    DEF VAR aux_dsdrisco AS CHAR                                       NO-UNDO.
    
    RUN efetivar-rating-bndes (INPUT par_cdcooper,
                               INPUT par_cdoperad,
                               INPUT par_nmdatela,
                               INPUT par_inproces,
                               INPUT par_nrdconta,
                               INPUT INT(par_nrctrato),
                               INPUT par_dtmvtolt,
                               INPUT par_dtmvtopr,
                               OUTPUT aux_dsdrisco,
                               OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN DO:
        
        IF NOT CAN-FIND(FIRST tt-erro WHERE tt-erro.nrsequen > 1) THEN DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            ASSIGN ret_tpcritic = 1. /* Mostra o erro encontrado */

            IF  AVAILABLE tt-erro  THEN
                ASSIGN ret_dscritic = tt-erro.dscritic.
            ELSE
                ASSIGN ret_dscritic = "Erro na efetivacao da proposta.".
    
            RETURN "NOK".
        END.
        ELSE DO:
            
            /* Verifica de encontra o erro 830 entre os demais ocorridos */
            FIND tt-erro WHERE tt-erro.cdcritic = 830
                            NO-LOCK NO-ERROR.
    
            /** Faltam dados cadastrais **/
            IF  AVAILABLE tt-erro  THEN
                ASSIGN ret_dscritic = tt-erro.dscritic.
            ELSE
                ASSIGN ret_dscritic = "Erro na efetivacao da proposta.".
    
            ASSIGN ret_tpcritic = 2. /* Mostra todos os erros encontrados */
            
            RETURN "NOK".

        END.
 
    END.
    ELSE DO:
        ASSIGN ret_tpcritic = 0
               ret_dscritic = "".
    
        /* Grava o RISCO */
        ASSIGN ret_dsdrisco = "RISCO EFETIVO: " + aux_dsdrisco.
    
        RETURN "OK".
    END.

END PROCEDURE.


PROCEDURE impressao-rating:

    DEF INPUT  PARAM par_cdcooper LIKE crapcop.cdcooper                NO-UNDO.
    DEF INPUT  PARAM par_nrdconta LIKE crapass.nrdconta                NO-UNDO.
    DEF INPUT  PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF INPUT  PARAM par_dtiniper AS DATE                              NO-UNDO.
    DEF INPUT  PARAM par_dtfimper AS DATE                              NO-UNDO.
    DEF INPUT  PARAM par_tprelato AS CHAR                              NO-UNDO.

    DEF OUTPUT PARAM ret_nmarquiv AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM ret_nmarqpdf AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-ctrbndes.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    DEF VAR aux_dsdrisco AS CHAR                                       NO-UNDO.
    DEF VAR aux_tpralbnd AS LOGICAL                                    NO-UNDO.
    
    EMPTY TEMP-TABLE tt-ctrbndes.
    EMPTY TEMP-TABLE tt-erro.

    IF  par_tprelato = "R" THEN DO: /* EFETIVOS */
    
        ASSIGN aux_tpralbnd = TRUE.

        RUN relatorio-bndes-efetivados (INPUT par_cdcooper,
                                        INPUT par_nrdconta,
                                        INPUT par_cdagenci,
                                        INPUT par_dtiniper,
                                        INPUT par_dtfimper,
                                        INPUT aux_tpralbnd,
                                       OUTPUT TABLE tt-ctrbndes,
                                       OUTPUT TABLE tt-erro).
         
        IF  RETURN-VALUE <> "OK" THEN
            RETURN "NOK".

    END.
    ELSE DO:
         
        /* PROPOSTOS */
        RUN relatorio-bndes-propostos (INPUT par_cdcooper,
                                       INPUT par_nrdconta,
                                       INPUT par_cdagenci,
                                       INPUT par_dtiniper,
                                       INPUT par_dtfimper,
                                       INPUT 5, /* Ayllos Web */
                                      OUTPUT ret_nmarquiv,
                                      OUTPUT ret_nmarqpdf,
                                      OUTPUT TABLE tt-relat,
                                      OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE <> "OK" THEN
            RETURN "NOK".

        ELSE DO:
             /* Busca descricao da Cooperativa */
        FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper
                              NO-LOCK NO-ERROR.
    
         IF  AVAIL crapcop THEN
             ASSIGN ret_nmarqpdf = ret_nmarqpdf.
                    
        END.
    
    END.
    
    RETURN "OK".
    
END PROCEDURE.


PROCEDURE imprimir-ratbnd-efetivos:

    DEF INPUT PARAM par_cdcooper AS INTE                                  NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                                  NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                                  NO-UNDO.
    DEF INPUT PARAM par_dtmvtopr AS DATE                                  NO-UNDO.
    DEF INPUT PARAM par_inproces AS INTE                                  NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                                  NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                                  NO-UNDO.
    DEF INPUT PARAM par_tpctrato AS INTE                                  NO-UNDO.
    DEF INPUT PARAM par_nrctrato AS INTE                                  NO-UNDO.
    DEF INPUT PARAM par_flgcriar AS LOGI                                  NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                                  NO-UNDO.

    DEF OUTPUT PARAM ret_nmarquiv AS CHAR                                 NO-UNDO.
    DEF OUTPUT PARAM ret_nmarqpdf AS CHAR                                 NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    IF  NOT VALID-HANDLE(h-b1wgen0043) THEN
        RUN sistema/generico/procedures/b1wgen0043.p
        PERSISTENT SET h-b1wgen0043.

    RUN gera_rating IN h-b1wgen0043 (INPUT par_cdcooper,
                                     INPUT 0,   /** Pac   **/
                                     INPUT 0,   /** Caixa **/
                                     INPUT par_cdoperad,
                                     INPUT par_nmdatela,
                                     INPUT 1,   /** Ayllos  **/
                                     INPUT par_nrdconta,
                                     INPUT 1,   /** Titular **/
                                     INPUT par_dtmvtolt,
                                     INPUT par_dtmvtopr,
                                     INPUT par_inproces,
                                     INPUT par_tpctrato,
                                     INPUT par_nrctrato,
                                     INPUT par_flgcriar,
                                     INPUT TRUE,   /** Log **/
                                    OUTPUT TABLE tt-erro,
                                    OUTPUT TABLE tt-cabrel,
                                    OUTPUT TABLE tt-impressao-coop,
                                    OUTPUT TABLE tt-impressao-rating,
                                    OUTPUT TABLE tt-impressao-risco,
                                    OUTPUT TABLE tt-impressao-risco-tl,
                                    OUTPUT TABLE tt-impressao-assina,
                                    OUTPUT TABLE tt-efetivacao,
                                    OUTPUT TABLE tt-ratings).

    IF  VALID-HANDLE(h-b1wgen0043) THEN
        DELETE PROCEDURE h-b1wgen0043.

    IF  RETURN-VALUE = "NOK"  THEN DO:
        RETURN "NOK".
    END.
    ELSE DO:

       RUN imprimir_rating(INPUT par_cdcooper,
                           INPUT par_nrdconta,
                           INPUT par_idorigem,
                           INPUT par_dtmvtolt,
                           INPUT TABLE tt-impressao-coop,
                           INPUT TABLE tt-impressao-rating,
                           INPUT TABLE tt-impressao-risco,
                           INPUT TABLE tt-impressao-risco-tl,
                           INPUT TABLE tt-impressao-assina,
                           INPUT TABLE tt-efetivacao,
                           OUTPUT ret_nmarquiv,
                           OUTPUT ret_nmarqpdf,
                           OUTPUT TABLE tt-erro).
        
    END.

    RETURN "OK".

END.


PROCEDURE imprimir_rating:

    DEF INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.

    DEF INPUT PARAM TABLE FOR tt-impressao-coop.
    DEF INPUT PARAM TABLE FOR tt-impressao-rating.
    DEF INPUT PARAM TABLE FOR tt-impressao-risco.
    DEF INPUT PARAM TABLE FOR tt-impressao-risco-tl.
    DEF INPUT PARAM TABLE FOR tt-impressao-assina.
    DEF INPUT PARAM TABLE FOR tt-efetivacao.
    
    DEF OUTPUT PARAM ret_nmarquiv AS CHAR                             NO-UNDO.
    DEF OUTPUT PARAM ret_nmarqpdf AS CHAR                             NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    DEF VAR aux_nmdircop AS CHAR                                      NO-UNDO.
    DEF VAR aux_dsagenci AS CHAR                                      NO-UNDO.
    DEF VAR aux_notaoperacao AS DECI                                  NO-UNDO.
    
    /*** PROCESSSAMENTO DO RELATORIO ***/

    /* Busca descricao da Cooperativa */
    FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper
                          NO-LOCK NO-ERROR.

    IF  AVAIL crapcop THEN
        ASSIGN aux_nmdircop = "/usr/coop/" + crapcop.dsdircop +
                              "/rl/"
               ret_nmarquiv = aux_nmdircop + "rating_" + STRING(TIME) + ".lst".
               ret_nmarqpdf = aux_nmdircop + "rating_" + STRING(TIME) + ".ex".

    OUTPUT STREAM str_1 TO VALUE (ret_nmarquiv) PAGED PAGE-SIZE 82.

    /*
    glb_cdempres    = 11.
    glb_cdrelato[1] = 367 - Relatorio de impressao do rating
    Em 132 colunas
    */

    { sistema/generico/includes/cabrel.i "11" "367" "132" }
    
    VIEW STREAM str_1 FRAME f_cabrel132_1.
    
    /** Dados do cooperado **/
    FIND FIRST tt-impressao-coop NO-LOCK NO-ERROR.
    
    DISPLAY STREAM str_1 tt-impressao-coop.nrdconta
                         tt-impressao-coop.nmprimtl
                         tt-impressao-coop.dspessoa
                         tt-impressao-coop.nrctrrat
                         tt-impressao-coop.dsdopera
                         WITH FRAME f_cooperado.
    
    /** Topícos do rating **/
    FOR EACH tt-impressao-rating NO-LOCK BREAK BY tt-impressao-rating.nrtopico
                                               BY tt-impressao-rating.nritetop
                                               BY tt-impressao-rating.nrseqite:
    
        IF  FIRST-OF(tt-impressao-rating.nrtopico)  THEN
            DISPLAY STREAM str_1 tt-impressao-rating.nrtopico
                                 tt-impressao-rating.dsitetop   
                                 WITH FRAME f_rating_1.
        ELSE
        IF  FIRST-OF(tt-impressao-rating.nritetop)  THEN
            DISPLAY STREAM str_1 tt-impressao-rating.dsitetop
                                 tt-impressao-rating.dspesoit                              
                                 WITH FRAME f_rating_2.
        ELSE
            DISPLAY STREAM str_1 tt-impressao-rating.dsitetop
                                 tt-impressao-rating.dspesoit                       
                                 WITH FRAME f_rating_3.                 
    
    END. /** Fim do FOR EACH tt-impressao-rating **/
    
    FIND FIRST tt-impressao-risco-tl NO-LOCK NO-ERROR.
    
    FIND FIRST tt-impressao-risco NO-LOCK NO-ERROR.
    
    ASSIGN aux_notaoperacao = tt-impressao-risco.vlrtotal - 
                              tt-impressao-risco-tl.vlrtotal.
    
    /* Nota do cooperado, seu correspondente risco e a nota da operação */
    DISPLAY STREAM str_1 tt-impressao-risco-tl.vlrtotal
                         tt-impressao-risco-tl.dsdrisco
                         aux_notaoperacao
                         WITH FRAME f_nota_risco_coop.
    
    /** Valor do rating(cooperado + operacao) e o seu correspondente risco **/ 
    DISPLAY STREAM str_1 tt-impressao-risco.vlrtotal
                         tt-impressao-risco.dsdrisco
                         tt-impressao-risco.vlprovis
                         tt-impressao-risco.dsparece
                         WITH FRAME f_nota_risco.
    
    FIND FIRST tt-impressao-assina NO-LOCK NO-ERROR.
    
    DISPLAY STREAM str_1 tt-impressao-assina WITH FRAME f_assina.
    
    /** Imprimir como observacao qual Rating foi efetivado **/
    FIND tt-efetivacao WHERE tt-efetivacao.idseqmen = 2 NO-LOCK NO-ERROR.
            
    IF  AVAIL tt-efetivacao  THEN
        DISPLAY STREAM str_1 tt-efetivacao.dsdefeti WITH FRAME f_observacao.
         
    OUTPUT STREAM str_1 CLOSE.

    IF  par_idorigem = 5 THEN DO: /* INTERNET */
        DO WHILE TRUE:

            UNIX SILENT VALUE("cp " + ret_nmarquiv + " " + ret_nmarqpdf +
                              " 2> /dev/null").

            UNIX SILENT VALUE("cp " + ret_nmarquiv + "  " + aux_nmdircop + "santos-"+ ret_nmarqpdf +
                              " 2> /dev/null").

            RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                SET h-b1wgen0024.

            IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                DO:
                   ASSIGN aux_cdcritic = 0
                          aux_dscritic = "Handle invalido para BO " +
                                         "b1wgen0024.".
          
                   RUN gera_erro (INPUT par_cdcooper,
                                  INPUT 0,
                                  INPUT 0,
                                  INPUT 1, /*sequencia*/
                                  INPUT aux_cdcritic,
                                  INPUT-OUTPUT aux_dscritic).
        
                   RETURN "NOK".
                END.
            
            RUN envia-arquivo-web IN h-b1wgen0024
                ( INPUT par_cdcooper,
                  INPUT 1, /* cdagenci */
                  INPUT 1, /* nrdcaixa */
                  INPUT ret_nmarqpdf,
                 OUTPUT ret_nmarqpdf,
                 OUTPUT TABLE tt-erro ).

            IF  VALID-HANDLE(h-b1wgen0024)  THEN
                DELETE PROCEDURE h-b1wgen0024.

            IF  RETURN-VALUE <> "OK" THEN
                RETURN "NOK".
            
            LEAVE.

        END. /** Fim do DO WHILE TRUE **/
    END. /* END do IF idorigem */

    RETURN "OK".

END PROCEDURE.

