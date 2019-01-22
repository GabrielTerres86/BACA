
/* ...........................................................................

   Programa: siscaixa/web/dbo/b1crap61.p
   Sistema : Caixa On-line
   Sigla   : CRED   
   Autor   : Evandro.
   Data    : Marco/2010                      Ultima atualizacao: 12/06/2018

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Tratar a liberacao dos envelopes depositados no cash

   Alteracoes: 05/07/2010 - Verificar dia util de data informada (Evandro).

               15/02/2011 - Incluir procedure busca_nome_taa
                          - Incluir procedure busca_envelopes_deposito
                          - Incluir procedure grava_dados_envelope
                          - Incluir procedure deposita_envelope_dinheiro
                            (Guilherme).

               21/06/2011 - Validar sit do enl na deposita_envelope_dinheiro
                            para evitar excesso de click do operador(Guilherme) 

               17/12/2013 - Adicionado validate para tabela craplcm (Tiago).

               01/07/2014 - Deposito InterCooperativas
                            - Novo parametro OUT na verifica_envelope
                            (Guilherme/SUPERO)
                            
               06/08/2014 - Substituido crapenl.cdcooper por crapenl.cdcoptfn 
                            na leitura da procedure 'busca_envelopes_deposito'
                            (Diego).             
                            
               17/11/2014 - Efetuar RETURN "NOK" quando a procedure 
                           'realiza-deposito' retornar <> "OK" (Diego).
                           
               03/12/2014 - Validaçãod e LOCKED na crapmdw e verificação de
                            sequencial zerado
                            (Lucas Lunelli SD. 227937)     
                            
               05/01/2015 - Ajustes na rotina deposita_envelope_dinheiro:
                            - Criado controle de transacao
                            - Alterado as variaveis globais i-cod-erro,
                              c-desc-erro para NO-UNDO
                           (Adriano SD - 237890).   
                           
               18/02/2015 - Alteração para retornar de uma vez todos os envelopes de DINHEIRO a
                            serem processados naquela data para aquele TAA (Lunelli - SD 229246).
                            
               13/10/2015 - Corrigida conversão de tipos na procedure 'deposita_envelope_dinheiro'
                            durante a criação da CRAPLCM (Lucas Lunelli)

			   17/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
							(Adriano - P339).

			   04/05/2018 - Possibilidade de utilizar o caixa on-line mesmo com o processo 
                            batch (noturno) executando (Fabio Adriano - AMcom)

               12/06/2018 - PRJ450 - Centralizaçao do lançamento em conta corrente - Rangel Decker AMcom     
               
               16/01/2019 - Revitalizacao (Remocao de lotes) - Pagamentos, Transferencias, Poupanca
                     Heitor (Mouts)

............................................................................ */

{dbo/bo-erro1.i}
{sistema/generico/includes/b1wgen0200tt.i }

DEF VAR i-cod-erro    AS INTEGER                                NO-UNDO.
DEF VAR c-desc-erro   AS CHAR                                   NO-UNDO.

/* temp-table tambem usada no crap061.htm */
DEFINE TEMP-TABLE tt-depositos-env NO-UNDO
    FIELD nrsequen AS INTE
    FIELD cdcopdst AS INTE
    FIELD nmcopdst AS CHAR
    FIELD nrdconta AS INTE
    FIELD nrconfer AS INTE
    FIELD vlinform AS DECI
    FIELD vlcomput AS DECI
    FIELD dssituac AS CHAR
    FIELD dtlibcom AS DATE
    INDEX tt-depositos-env1 nrsequen DESC.

/* buscar o nome do taa informado */
PROCEDURE busca_nome_taa:

    DEFINE INPUT  PARAM par_nmrescop    AS CHAR             NO-UNDO.
    DEFINE INPUT  PARAM par_cdagenci    AS INT              NO-UNDO.
    DEFINE INPUT  PARAM par_nrdcaixa    AS INT              NO-UNDO.
    DEFINE INPUT  PARAM par_nrterfin    AS INT              NO-UNDO.
    DEFINE OUTPUT PARAM par_dsterfin    AS CHAR             NO-UNDO.

    FIND crapcop WHERE crapcop.nmrescop = par_nmrescop NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcop  THEN
        DO:
            RUN cria-erro (INPUT par_nmrescop,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 794,
                           INPUT "",
                           INPUT YES).
            RETURN "NOK".
        END.
    
    FIND craptfn WHERE craptfn.cdcooper = crapcop.cdcooper AND
                       craptfn.nrterfin = par_nrterfin 
                       NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE craptfn   THEN
         DO:
             RUN cria-erro (INPUT par_nmrescop,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 0,
                            INPUT "Terminal financeiro nao cadastrado!",
                            INPUT YES).
             RETURN "NOK".
         END.

    IF  craptfn.cdagenci <> INTE(par_cdagenci)  THEN
    DO:
        RUN cria-erro (INPUT par_nmrescop,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 0,
                       INPUT "Terminal financeiro pertence ao PAC " +
                             STRING(craptfn.cdagenci) + ".",
                       INPUT YES).
        RETURN "NOK".
    END.

    ASSIGN par_dsterfin = craptfn.nmterfin.

    RETURN "OK".

END PROCEDURE.

/* buscar os envelopes que estao sendo depositados na rotina 61 */
PROCEDURE busca_envelopes_deposito:

    DEF  INPUT PARAM par_nmrescop     AS CHAR        NO-UNDO.
    DEF  INPUT PARAM par_cdagenci     AS INT         NO-UNDO. 
    DEF  INPUT PARAM par_nrdcaixa     AS INT         NO-UNDO. 
    DEF  INPUT PARAM par_tpdeposi     AS INT         NO-UNDO.
    /* 1-Dinheiro 2-Cheque */
    DEF  INPUT PARAM par_nrseqdig    AS INT              NO-UNDO.
    DEF  INPUT PARAM par_vldincpt    AS CHAR             NO-UNDO.
    DEF  INPUT PARAM par_dssituac    AS CHAR             NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-depositos-env.

    DEF BUFFER crabcop FOR crapcop.


    DEFINE VARIABLE aux_nrsequen AS INTEGER     NO-UNDO.

    EMPTY TEMP-TABLE tt-depositos-env.
               
    FIND crapcop WHERE crapcop.nmrescop = par_nmrescop NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcop  THEN
        DO:
            RUN cria-erro (INPUT par_nmrescop,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 794,
                           INPUT "",
                           INPUT YES).
            RETURN "NOK".
        END.

    IF  par_tpdeposi = 1  THEN
    DO:
        FOR EACH crapmdw WHERE crapmdw.cdcooper = crapcop.cdcooper AND
                               crapmdw.cdagenci = par_cdagenci     AND
                               crapmdw.nrdcaixa = par_nrdcaixa EXCLUSIVE-LOCK,
           FIRST crapenl WHERE crapenl.cdcoptfn = crapcop.cdcooper AND
                               crapenl.dtmvtolt = crapmdw.dtlibcom AND
                               crapenl.nrseqenv = crapmdw.nrcheque NO-LOCK
                               BY crapmdw.nrseqdig:
            CREATE tt-depositos-env.
            ASSIGN aux_nrsequen = aux_nrsequen + 1
                   tt-depositos-env.nrsequen = aux_nrsequen
                   tt-depositos-env.nrdconta = crapenl.nrdconta
                   tt-depositos-env.nrconfer = crapmdw.nrcheque
                   tt-depositos-env.dtlibcom = crapmdw.dtlibcom
                   tt-depositos-env.vlinform = IF  par_tpdeposi = 1  THEN 
                                                   crapenl.vldininf 
                                               ELSE crapenl.vlchqinf.
            
            IF  crapenl.cdcooper <> crapenl.cdcoptfn THEN DO:
                FIND FIRST crabcop
                     WHERE crabcop.cdcooper = crapenl.cdcooper
                NO-LOCK NO-ERROR.
                IF  AVAIL crabcop THEN
                    ASSIGN tt-depositos-env.cdcopdst = crabcop.cdcooper
                           tt-depositos-env.nmcopdst = crabcop.nmrescop.
                ELSE
                    ASSIGN tt-depositos-env.cdcopdst = 0
                           tt-depositos-env.nmcopdst = 'ERRO COP DST'.
            END.
            ELSE
                ASSIGN tt-depositos-env.cdcopdst = crapcop.cdcooper
                       tt-depositos-env.nmcopdst = crapcop.nmrescop.



            IF  crapmdw.nrseqdig = par_nrseqdig  THEN
                ASSIGN crapmdw.dsdocmc7 = par_dssituac /* descartado */
                       crapmdw.lsdigctr = par_vldincpt. /* computado */
            
            IF  par_tpdeposi = 1  THEN
                ASSIGN tt-depositos-env.vlcomput = DECI(crapmdw.lsdigctr)
                       tt-depositos-env.dssituac = crapmdw.dsdocmc7.
            ELSE
               ASSIGN tt-depositos-env.vlcomput = crapenl.vlchqcmp 
                      tt-depositos-env.dssituac = IF  crapenl.cdsitenv = 0  THEN
                                                       "A confirmar"
                                                  ELSE
                                                  IF  crapenl.cdsitenv = 1  THEN
                                                      "Processado"
                                                  ELSE
                                                      "Descartado".




        END.
    END.
    ELSE
    DO: 

        FOR EACH crapmdw WHERE crapmdw.cdcooper = crapcop.cdcooper AND
                               crapmdw.cdagenci = par_cdagenci     AND
                               crapmdw.nrdcaixa = par_nrdcaixa NO-LOCK:
        
            CREATE tt-depositos-env.
            ASSIGN aux_nrsequen = aux_nrsequen + 1
                   tt-depositos-env.nrsequen = aux_nrsequen
                   tt-depositos-env.nrdconta = crapmdw.nrdconta
                   tt-depositos-env.nrconfer = crapmdw.nrcheque
                   tt-depositos-env.dtlibcom = crapmdw.dtlibcom
                   tt-depositos-env.vlcomput = crapmdw.vlcompel.
        END.
    END.
    
    RETURN "OK".

END PROCEDURE.


PROCEDURE verifica_envelope:
    DEFINE INPUT  PARAM par_nmrescop    AS CHAR             NO-UNDO.
    DEFINE INPUT  PARAM par_cdagenci    AS INT              NO-UNDO.
    DEFINE INPUT  PARAM par_nrdcaixa    AS INT              NO-UNDO.
    DEFINE INPUT  PARAM par_dtmvtolt    AS DATE             NO-UNDO.
    DEFINE INPUT  PARAM par_nrsequni    AS INT              NO-UNDO.
    DEFINE INPUT  PARAM par_nrterfin    AS INT              NO-UNDO.
    DEFINE INPUT  PARAM par_flgdinhe    AS LOGICAL          NO-UNDO.

    /* Devolve como CHAR porque usa no HTM */
    DEFINE OUTPUT PARAM par_nrdocmto    AS CHAR             NO-UNDO.
    DEFINE OUTPUT PARAM par_nmcopdst    AS CHAR             NO-UNDO.
    DEFINE OUTPUT PARAM par_nrdconta    AS CHAR             NO-UNDO.
    DEFINE OUTPUT PARAM par_nmextttl    AS CHAR             NO-UNDO.
    DEFINE OUTPUT PARAM par_vldininf    AS CHAR             NO-UNDO.
    DEFINE OUTPUT PARAM par_vlchqinf    AS CHAR             NO-UNDO.

    DEF BUFFER crabcop FOR crapcop.

    RUN elimina-erro (INPUT par_nmrescop,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa).

    FIND crapcop WHERE crapcop.nmrescop = par_nmrescop NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN i-cod-erro  = 794
                   c-desc-erro = "".
        END.
    ELSE
        DO:
            FIND crapenl WHERE crapenl.cdcoptfn = crapcop.cdcooper  AND
                               crapenl.dtmvtolt = par_dtmvtolt      AND
                               crapenl.nrseqenv = par_nrsequni
                               NO-LOCK NO-ERROR.
            
            IF  NOT AVAILABLE crapenl   THEN
                ASSIGN i-cod-erro  = 0
                       c-desc-erro = "Envelope nao encontrado.".
            ELSE
            IF  crapenl.nrterfin <> par_nrterfin  THEN
                ASSIGN i-cod-erro  = 0
                       c-desc-erro = "Envelope pertence ao terminal financeiro " +
                                     STRING(crapenl.nrterfin) + ".".
            ELSE
            IF  crapenl.cdsitenv = 1  THEN
                ASSIGN i-cod-erro  = 0
                       c-desc-erro = "Envelope ja liberado.".
            ELSE
            IF  crapenl.cdsitenv = 2  THEN
                ASSIGN i-cod-erro  = 0
                       c-desc-erro = "Envelope ja descartado.".
            ELSE
            IF  par_flgdinhe      AND
                crapenl.vldininf <= 0 THEN
                ASSIGN i-cod-erro  = 0
                       c-desc-erro = "Deve ser informado envelope de dinheiro.".
            ELSE
            IF  NOT par_flgdinhe  AND
                crapenl.vlchqinf <= 0 THEN
                ASSIGN i-cod-erro  = 0
                       c-desc-erro = "Deve ser informado envelope de cheque.".
            ELSE
                DO:
                    FIND crapass WHERE crapass.cdcooper = crapenl.cdcooper  AND
                                       crapass.nrdconta = crapenl.nrdconta
                                       NO-LOCK NO-ERROR.

                    IF  NOT AVAILABLE crapass   THEN
                        ASSIGN i-cod-erro  = 9
                               c-desc-erro = "".
                END.
        END.
    
    IF  i-cod-erro  <> 0   OR
        c-desc-erro <> ""  THEN
        DO: 
            RUN cria-erro (INPUT par_nmrescop,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    /** Deposito Intercooperativas **/
    FIND FIRST crabcop
         WHERE crabcop.cdcooper = crapenl.cdcooper
        NO-LOCK NO-ERROR.
    IF  AVAIL crabcop THEN
        ASSIGN par_nmcopdst = TRIM(crabcop.nmrescop) + " - " +
                              TRIM(crabcop.nmextcop).
    ELSE
        IF  crapenl.cdcoptfn = crapenl.cdcooper THEN
            ASSIGN par_nmcopdst = TRIM(crapcop.nmrescop) + " - " +
                                  TRIM(crapcop.nmextcop).
        ELSE
            ASSIGN par_nmcopdst = "COOPERATIVA INVALIDA! Cod:"   +
                                   STRING(crapenl.cdcooper,"9999").


    /* verifica o documento */
    FIND crapltr WHERE crapltr.cdcooper = crapenl.cdcoptfn  AND
                       crapltr.dtmvtolt = crapenl.dtmvtolt  AND
                       crapltr.nrdconta = crapenl.nrdconta  AND
                       crapltr.cdhistor = 698               AND /* envelope */
                       crapltr.nrsequni = crapenl.nrseqenv
                       NO-LOCK NO-ERROR.
    
    ASSIGN par_nrdocmto = IF  AVAILABLE crapltr  THEN
                              STRING(crapltr.hrtransa,"99999")
                          ELSE "00000"
           par_nrdconta = STRING(crapenl.nrdconta,"zzzz,zzz,9")
           par_nmextttl = crapass.nmprimtl
           par_vldininf = STRING(crapenl.vldininf,"z,zzz,zz9.99")
           par_vlchqinf = STRING(crapenl.vlchqinf,"z,zzz,zz9.99").

    RETURN "OK".

END PROCEDURE.
/* Fim verifica_envelope */


/* gravar os dados do envelope para depois efetuar o deposito na c/c */
PROCEDURE grava_dados_envelope:

    DEFINE INPUT  PARAM par_nmrescop    AS CHAR             NO-UNDO.
    DEFINE INPUT  PARAM par_cdagenci    AS INT              NO-UNDO.
    DEFINE INPUT  PARAM par_nrdcaixa    AS INT              NO-UNDO.
    DEFINE INPUT  PARAM par_dtmvtolt    AS DATE             NO-UNDO.
    DEFINE INPUT  PARAM par_nrsequni    AS INT              NO-UNDO.
    DEFINE INPUT  PARAM par_nrterfin    AS INT              NO-UNDO.
    DEFINE INPUT  PARAM par_flgdinhe    AS LOGICAL          NO-UNDO.

    DEFINE VARIABLE i-digito     AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_nrdocmto AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE aux_nrdconta AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE aux_nmcopdst AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE aux_nmextttl AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE aux_vldininf AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE aux_vlchqinf AS CHARACTER   NO-UNDO.

    DEF VAR in99          AS INTE               NO-UNDO.

    DEF BUFFER crabcop FOR crapcop.

    /*
    RUN verifica_envelope(INPUT  par_nmrescop,
                          INPUT  par_cdagenci,
                          INPUT  par_nrdcaixa,
                          INPUT  par_dtmvtolt,
                          INPUT  par_nrsequni,
                          INPUT  par_nrterfin,
                          INPUT  par_flgdinhe,
                          OUTPUT aux_nrdocmto,
                          OUTPUT aux_nmcopdst,
                          OUTPUT aux_nrdconta,
                          OUTPUT aux_nmextttl,
                          OUTPUT aux_vldininf,
                          OUTPUT aux_vlchqinf).
                          

    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK". */

    RUN elimina-erro (INPUT par_nmrescop,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa).

    FIND crapcop WHERE crapcop.nmrescop = par_nmrescop NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcop  THEN
        DO:
            RUN cria-erro (INPUT par_nmrescop,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 794,
                           INPUT "",
                           INPUT YES).
            RETURN "NOK".
        END.


   ASSIGN i-digito = 1.

   FOR EACH crapmdw WHERE crapmdw.cdcooper = crapcop.cdcooper AND
                          crapmdw.cdagenci = par_cdagenci     AND
                          crapmdw.nrdcaixa = par_nrdcaixa 
                          NO-LOCK BREAK BY crapmdw.nrseqdig:
       IF  LAST(crapmdw.nrseqdig)   THEN
           ASSIGN i-digito = crapmdw.nrseqdig + 1.
    END. 


    ASSIGN in99 = 0. 

   ENV:
   FOR EACH crapenl WHERE crapenl.cdcoptfn = crapcop.cdcooper  AND
                          crapenl.dtmvtolt = par_dtmvtolt      AND
                          crapenl.nrterfin = par_nrterfin      AND
                          crapenl.cdsitenv = 3                 AND /* Recolhidos */
                          crapenl.vldininf > 0
                          NO-LOCK.

       /* verifica o documento */
       FIND crapltr WHERE crapltr.cdcooper = crapenl.cdcoptfn  AND
                          crapltr.dtmvtolt = crapenl.dtmvtolt  AND
                          crapltr.nrdconta = crapenl.nrdconta  AND
                          crapltr.cdhistor = 698               AND /* envelope */
                          crapltr.nrsequni = crapenl.nrseqenv
                          NO-LOCK NO-ERROR.

       FIND crapass WHERE crapass.cdcooper = crapenl.cdcooper  AND
                          crapass.nrdconta = crapenl.nrdconta
                          NO-LOCK NO-ERROR.
        
       IF  NOT AVAILABLE crapass   THEN
           DO:
               ASSIGN i-cod-erro  = 9
                      c-desc-erro = "".
               LEAVE ENV.
           END.

       ASSIGN aux_nrdocmto = IF  AVAILABLE crapltr  THEN
                                 STRING(crapltr.hrtransa,"99999")
                             ELSE "00000"
              aux_nrdconta = STRING(crapenl.nrdconta,"zzzz,zzz,9")
              aux_nmextttl = crapass.nmprimtl
              aux_vldininf = STRING(crapenl.vldininf,"z,zzz,zz9.99")
              aux_vlchqinf = STRING(crapenl.vlchqinf,"z,zzz,zz9.99").

       /** Deposito Intercooperativas **/
        FIND FIRST crabcop WHERE crabcop.cdcooper = crapenl.cdcooper NO-LOCK NO-ERROR.

        IF  AVAIL crabcop THEN
            ASSIGN aux_nmcopdst = TRIM(crabcop.nmrescop) + " - " +
                                  TRIM(crabcop.nmextcop).
        ELSE
            IF  crapenl.cdcoptfn = crapenl.cdcooper THEN
                ASSIGN aux_nmcopdst = TRIM(crapcop.nmrescop) + " - " +
                                      TRIM(crapcop.nmextcop).
            ELSE
                ASSIGN aux_nmcopdst = "COOPERATIVA INVALIDA! Cod:"   +
                                       STRING(crapenl.cdcooper,"9999").

       DO WHILE TRUE:

            ASSIGN in99 = in99 + 1.
    
            FIND FIRST crapmdw WHERE crapmdw.cdcooper = crapenl.cdcoptfn   AND
                                     crapmdw.cdagenci = par_cdagenci       AND
                                     crapmdw.nrdcaixa = par_nrdcaixa       AND
                                     crapmdw.nrctabdb = INTE(aux_nrdconta) AND
                                     crapmdw.nrcheque = crapenl.nrseqenv
                                     EXCLUSIVE-LOCK NO-ERROR.
        
            IF   NOT AVAIL crapmdw   THEN 
                 DO:
                    IF  LOCKED crapmdw THEN 
                        DO:
                            IF  in99 <= 10  THEN 
                                DO:
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                            ELSE 
                                DO:
                                    RUN cria-erro (INPUT par_nmrescop,
                                                   INPUT par_cdagenci,
                                                   INPUT par_nrdcaixa,
                                                   INPUT 0,
                                                   INPUT "Tabela CRAPMDW em uso. ",
                                                   INPUT YES).
                                    RETURN "NOK".
                                END.
                        END.
                    ELSE 
                        DO:
                             CREATE crapmdw.
                             ASSIGN crapmdw.cdcooper  = crapcop.cdcooper
                                    crapmdw.cdagenci  = par_cdagenci
                                    crapmdw.nrdcaixa  = par_nrdcaixa
                                    crapmdw.nrctabdb  = INTE(aux_nrdconta)
                                    crapmdw.nrcheque  = crapenl.nrseqenv
                                    crapmdw.nrdconta = INTE(aux_nrdconta)
                                    crapmdw.dsdocmc7 = "A confirmar" /* Situacao */
                                    crapmdw.vlcompel = DECI(aux_vldininf) /* Valor do envelope */
                                    crapmdw.lsdigctr = aux_vldininf /* Valor do envelope */
                                    crapmdw.dtlibcom = crapenl.dtmvtolt
                                    crapmdw.nrseqdig = i-digito.
    
                             LEAVE.
                        END.
                 END.
            ELSE
                 DO:
                     RUN cria-erro (INPUT par_nmrescop,
                                    INPUT par_cdagenci,
                                    INPUT par_nrdcaixa,
                                    INPUT 0,
                                    INPUT "Envelope ja informado.",
                                    INPUT YES).
                     RETURN "NOK".
                 END.

       END.    /* DO WHILE TRUE */

       RELEASE crapmdw.
       ASSIGN i-digito = i-digito + 1.

   END. /* FOR EACH crapenl */   

   IF  i-cod-erro  <> 0   OR
       c-desc-erro <> ""  THEN
       DO: 
           RUN cria-erro (INPUT par_nmrescop,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT i-cod-erro,
                          INPUT c-desc-erro,
                          INPUT YES).
           RETURN "NOK".
       END.

END PROCEDURE.

/* autenticar cheques da cooperativa no envelope de cheque */
PROCEDURE autentica_cheques_coop:

    DEFINE INPUT  PARAM par_nmrescop    AS CHAR             NO-UNDO.
    DEFINE INPUT  PARAM par_cdagenci    AS INT              NO-UNDO.
    DEFINE INPUT  PARAM par_nrdcaixa    AS INT              NO-UNDO.
    DEFINE INPUT  PARAM v_operador      AS CHAR             NO-UNDO.

    DEFINE VARIABLE h-b1crap00 AS HANDLE     NO-UNDO.
    DEFINE VARIABLE aux_nrcheque    AS INTE       NO-UNDO.
    DEFINE VARIABLE p-literal       AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE p-ult-sequencia AS INTEGER    NO-UNDO.
    DEFINE VARIABLE p-registro      AS RECID      NO-UNDO.


    RUN elimina-erro (INPUT par_nmrescop,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa).

    FIND crapcop WHERE crapcop.nmrescop = par_nmrescop NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN i-cod-erro  = 794
                   c-desc-erro = "".
        END.
    ELSE
    DO:
        RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.

        FOR EACH crapmdw WHERE crapmdw.cdcooper = crapcop.cdcooper AND
                               crapmdw.cdagenci = par_cdagenci     AND
                               crapmdw.nrdcaixa = par_nrdcaixa     AND
                               crapmdw.inautent = FALSE            AND 
                               crapmdw.cdhistor = 386 EXCLUSIVE-LOCK:
    
            ASSIGN aux_nrcheque = 
                       INTE(STRING(crapmdw.nrcheque,"zzz,zz9") +                                             
                            STRING(crapmdw.nrddigc3,"9")).
    
            RUN grava-autenticacao
                  IN h-b1crap00 (INPUT par_nmrescop,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT v_operador,
                                 INPUT crapmdw.vlcompel,
                                 INPUT aux_nrcheque, 
                                 INPUT YES, /* YES (PG), NO (REC) */
                                 INPUT "1",  /* On-line            */                                             
                                 INPUT NO,   /* Nao estorno        */
                                 INPUT 386, 
                                 INPUT ?, /* Data off-line */
                                 INPUT 0, /* Sequencia off-line */
                                 INPUT 0, /* Hora off-line */
                                 INPUT 0, /* Seq.orig.Off-line */
                                 OUTPUT p-literal,
                                 OUTPUT p-ult-sequencia,
                                 OUTPUT p-registro).
    
            ASSIGN crapmdw.nrautdoc = p-ult-sequencia.
    
            IF RETURN-VALUE = "NOK" THEN
            DO:
                ASSIGN i-cod-erro  = 0
                       c-desc-erro = "Erro na Autenticacao".
                LEAVE.
            END.

        END.

        DELETE PROCEDURE h-b1crap00.

    END.

    IF  i-cod-erro  <> 0   OR
        c-desc-erro <> ""  THEN
        DO: 
            RUN cria-erro (INPUT par_nmrescop,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.

/* efetuar o deposito do envelope em dinheiro 
   procedure criada com base na atualiza-deposito-com-captura da b1crap51.p */
PROCEDURE deposita_envelope_dinheiro:

    DEF INPUT  PARAM  p-cooper       AS CHAR                  NO-UNDO.
    DEF INPUT  PARAM  p-cod-agencia  AS INT                   NO-UNDO. 
    DEF INPUT  PARAM  p-nro-caixa    AS INT                   NO-UNDO. 
    DEF INPUT  PARAM  p-cod-operador AS CHAR                  NO-UNDO.
    DEF INPUT  PARAM  p-cooper-dest  AS CHAR                  NO-UNDO.
    DEF INPUT  PARAM  p-nro-conta    AS INT                   NO-UNDO.

    DEF INPUT  PARAM  p-identifica  AS CHAR                   NO-UNDO.
    DEF INPUT  PARAM  p-dtmvtolt    AS DATE                   NO-UNDO.
    DEF INPUT  PARAM  p-nrsequni    AS INTE                   NO-UNDO.
    DEF INPUT  PARAM  p-vlcomput    AS DECI                   NO-UNDO.

    DEF VAR i-nro-lote              AS INTE                   NO-UNDO.
    DEF VAR aux_nrdconta            AS INTE                   NO-UNDO.
    DEF VAR l-achou-horario-corte   AS LOG                    NO-UNDO.
    DEF VAR c-docto-salvo           AS CHAR                   NO-UNDO.
    DEF VAR c-docto                 AS CHAR                   NO-UNDO.
    DEF VAR de-valor                AS DEC                    NO-UNDO.
    DEF VAR de-dinheiro             AS DEC                    NO-UNDO.
    DEF VAR i-nro-docto             AS INTE                   NO-UNDO.
    DEF VAR h_b1crap00              AS HANDLE                 NO-UNDO.
    DEF VAR h-b1crap22              AS HANDLE                 NO-UNDO.
    DEF VAR c-literal               AS CHAR   FORMAT "x(48)" 
                                              EXTENT 35       NO-UNDO.
    DEF VAR p-literal               AS CHAR                   NO-UNDO.
    DEF VAR p-literal-autentica     AS CHAR                   NO-UNDO.
    DEF VAR p-ult-sequencia         AS INTE                   NO-UNDO.
    DEF VAR p-registro              AS RECID                  NO-UNDO.
    DEF VAR glb_dsdctitg            AS CHAR                   NO-UNDO.
    DEF VAR glb_stsnrcal            AS LOGICAL                NO-UNDO.
    DEF VAR c-nome-titular1         AS CHAR                   NO-UNDO.
    DEF VAR c-nome-titular2         AS CHAR                   NO-UNDO.
    DEF VAR in99                    AS INTE                   NO-UNDO.
    DEF VAR aux_returnvl            AS CHAR INIT "NOK"        NO-UNDO.
    DEF VAR aux_nrseqdig            AS INTE                   NO-UNDO.
    
    DEF VAR h-b1wgen0200 AS HANDLE                                        NO-UNDO.
    DEF VAR aux_incrineg AS INT NO-UNDO.
    DEF VAR aux_cdcritic AS INT NO-UNDO.
    DEF VAR aux_dscritic AS CHAR NO-UNDO.
    
    
    /* Identificar orgao expedidor */
    IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
    RUN sistema/generico/procedures/b1wgen0200.p
        PERSISTENT SET h-b1wgen0200.
    
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    DepDinheiro:
    DO TRANSACTION ON STOP   UNDO DepDinheiro, LEAVE DepDinheiro
                   ON QUIT   UNDO DepDinheiro, LEAVE DepDinheiro
                   ON ERROR  UNDO DepDinheiro, LEAVE DepDinheiro
                   ON ENDKEY UNDO DepDinheiro, LEAVE DepDinheiro:

       FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
       
       IF NOT AVAILABLE crapcop THEN
          DO:
             ASSIGN i-cod-erro  = 651
                    c-desc-erro = " ".
       
             UNDO DepDinheiro, LEAVE DepDinheiro.
           
          END.
       
       FIND crapenl WHERE crapenl.cdcoptfn = crapcop.cdcooper AND
                          crapenl.dtmvtolt = p-dtmvtolt       AND
                          crapenl.nrseqenv = p-nrsequni
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
       
       IF NOT AVAILABLE crapenl THEN
          DO:
              IF LOCKED crapenl  THEN
                 ASSIGN i-cod-erro  = 0
                        c-desc-erro = "Registro do Envelope em Uso.".
              ELSE
                 ASSIGN i-cod-erro  = 0
                        c-desc-erro = "Envelope nao encontrado.".
          END.
       ELSE
          DO:
             IF p-vlcomput <= 0 THEN
                ASSIGN i-cod-erro  = 0
                       c-desc-erro = "Valor computado deve ser maior que 0,00.".
             ELSE
                /* se ja depositou da OK, tratado para excesso de click */
                IF crapenl.cdsitenv = 1 THEN 
                   RETURN "OK".

          END.
       
       IF i-cod-erro  <> 0  OR
          c-desc-erro <> "" THEN
          UNDO DepDinheiro, LEAVE DepDinheiro.
       
       ASSIGN i-nro-lote = 11000 + p-nro-caixa
              p-nro-conta = DEC(REPLACE(STRING(crapenl.nrdconta),".",""))
              aux_nrdconta = crapenl.nrdconta.
       
       FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                          NO-LOCK NO-ERROR.
       
       IF NOT AVAILABLE crapdat THEN
          DO:
             ASSIGN i-cod-erro  = 1
                    c-desc-erro = " ".
       
             UNDO DepDinheiro, LEAVE DepDinheiro.
           
          END.
       
       ASSIGN l-achou-horario-corte = NO.
       
       IF p-vlcomput <> 0 THEN
          ASSIGN l-achou-horario-corte = YES
                 de-dinheiro = de-dinheiro + p-vlcomput
                 de-valor = de-dinheiro.
       
       IF l-achou-horario-corte THEN  
          DO:
             /* Verifica horario de Corte */
             FIND FIRST craptab WHERE craptab.cdcooper = crapcop.cdcooper AND
                                      craptab.nmsistem = "CRED"           AND
                                      craptab.tptabela = "GENERI"         AND
                                      craptab.cdempres = 0                AND
                                      craptab.cdacesso = "HRTRCOMPEL"     AND
                                      craptab.tpregist = p-cod-agencia  
                                      NO-LOCK NO-ERROR.
                                      
             IF NOT AVAIL craptab THEN  
                DO:
                   ASSIGN i-cod-erro  = 676
                          c-desc-erro = " ".

                   UNDO DepDinheiro, LEAVE DepDinheiro.

                END.
       
             IF INT(SUBSTR(craptab.dstextab,1,1)) <> 0 THEN 
                DO:
                   ASSIGN i-cod-erro  = 677
                          c-desc-erro = " ".
                   
                   UNDO DepDinheiro, LEAVE DepDinheiro.

                END.
       
             IF INT(SUBSTR(craptab.dstextab,3,5)) <= TIME THEN 
                DO:
                   ASSIGN i-cod-erro  = 676
                          c-desc-erro = " ".
                   
                   UNDO DepDinheiro, LEAVE DepDinheiro.

                END.
           END.    /* Verifica Horario de Corte */
       
       ASSIGN c-docto-salvo = STRING(p-nrsequni).
       
       /** DEP. INTERCOOP. **/
       IF p-cooper-dest <> p-cooper AND
          p-cooper-dest <> " "      THEN 
          DO:
             /** COOP Diferente -> realiza-deposito b1crap22  **/
             IF NOT VALID-HANDLE(h-b1crap22) THEN
                RUN dbo/b1crap22.p PERSISTENT SET h-b1crap22.
       
             RUN realiza-deposito IN h-b1crap22 (INPUT p-cooper,
                                                 INPUT p-cod-agencia,
                                                 INPUT p-nro-caixa,
                                                 INPUT p-cod-operador,
                                                 INPUT p-cooper-dest, /** COOP Destino */
                                                 INPUT p-nro-conta,    
                                                 INPUT p-vlcomput,
                                                 INPUT p-identifica,
                                                OUTPUT c-docto-salvo,
                                                OUTPUT i-nro-lote,
                                                OUTPUT p-literal,
                                                OUTPUT p-ult-sequencia).
             
             IF VALID-HANDLE(h-b1crap22) THEN
                DELETE PROCEDURE h-b1crap22.
             
             IF RETURN-VALUE <> "OK" THEN
                DO:    
                   FIND craperr WHERE craperr.cdcooper = crapcop.cdcooper AND
                                      craperr.cdagenci = p-cod-agencia    AND
                                      craperr.nrdcaixa = p-nro-caixa
                                      NO-LOCK NO-ERROR.

                   IF AVAIL craperr THEN
                      DO:
                         IF craperr.cdcritic = 0 THEN
                            ASSIGN i-cod-erro  = craperr.cdcritic
                                   c-desc-erro = craperr.dscritic.
                         ELSE
                            ASSIGN i-cod-erro  = craperr.cdcritic
                                   c-desc-erro = "".

                      END.
                   ELSE
                      ASSIGN i-cod-erro  = 0
                             c-desc-erro = "Nao foi possível realizar o " + 
                                           "deposito.".
                    
                   UNDO DepDinheiro, LEAVE DepDinheiro.

                END.
             
             IF p-ult-sequencia = 0 THEN
                DO:
                   ASSIGN i-cod-erro  = 0
                          c-desc-erro = " Sequencial de autenticacao vazio.".
       
                   UNDO DepDinheiro, LEAVE DepDinheiro.
       
                END.
             
             /** Atualiza Envelope **/
             ASSIGN crapenl.cdsitenv = 1 /* Liberado */
                    crapenl.nrautdoc = p-ult-sequencia
                    crapenl.vldincmp = p-vlcomput.
             
          END.
       ELSE
          DO: 
             /** Executa processo normal de Deposito Envelope Dinheiro **/
             FIND FIRST craplot WHERE craplot.cdcooper = crapcop.cdcooper  AND
                                      craplot.dtmvtolt = crapdat.dtmvtocd  AND
                                      craplot.cdagenci = p-cod-agencia     AND
                                      craplot.cdbccxlt = 11                AND /* Fixo */
                                      craplot.nrdolote = i-nro-lote 
                                      NO-LOCK NO-ERROR.
                  
             IF NOT AVAIL craplot THEN 
                DO: 
                   CREATE craplot.
       
                   ASSIGN craplot.cdcooper = crapcop.cdcooper
                          craplot.dtmvtolt = crapdat.dtmvtocd
                          craplot.cdagenci = p-cod-agencia
                          craplot.cdbccxlt = 11
                          craplot.nrdolote = i-nro-lote
                          craplot.tplotmov = 1
                          craplot.cdoperad = p-cod-operador
                          craplot.cdhistor = 0 /* 700 */
                          craplot.nrdcaixa = p-nro-caixa
                          craplot.cdopecxa = p-cod-operador.

                END.
                      
             ASSIGN i-nro-docto = INT(c-docto-salvo).
             
             /*--- Grava Autenticacao Arquivo/Spool --*/
             IF NOT VALID-HANDLE(h_b1crap00) THEN
                RUN dbo/b1crap00.p PERSISTENT SET h_b1crap00.
       
             RUN grava-autenticacao  IN h_b1crap00 (INPUT p-cooper,
                                                    INPUT p-cod-agencia,
                                                    INPUT p-nro-caixa,
                                                    INPUT p-cod-operador,
                                                    INPUT de-valor,
                                                    INPUT dec(i-nro-docto),
                                                    INPUT NO, /* YES (PG), NO (REC) */
                                                    INPUT "1",  /* On-line  */     
                                                    INPUT NO,   /* Nao estorno */     
                                                    INPUT 700,
                                                    INPUT ?, /* Data off-line */
                                                    INPUT 0, /* Sequencia off-line */
                                                    INPUT 0, /* Hora off-line */
                                                    INPUT 0, /* Seq.orig.Off-line */
                                                    OUTPUT p-literal,
                                                    OUTPUT p-ult-sequencia,
                                                    OUTPUT p-registro).

             IF VALID-HANDLE(h_b1crap00) THEN
                DELETE PROCEDURE h_b1crap00.
            
             IF RETURN-VALUE <> "OK" THEN
                DO:    
                   FIND craperr WHERE craperr.cdcooper = crapcop.cdcooper AND
                                      craperr.cdagenci = p-cod-agencia    AND
                                      craperr.nrdcaixa = p-nro-caixa
                                      NO-LOCK NO-ERROR.

                   IF AVAIL craperr THEN
                      DO:
                         IF craperr.cdcritic = 0 THEN
                            ASSIGN i-cod-erro  = craperr.cdcritic
                                   c-desc-erro = craperr.dscritic.
                         ELSE
                            ASSIGN i-cod-erro  = craperr.cdcritic
                                   c-desc-erro = "".

                      END.
                   ELSE
                      ASSIGN i-cod-erro  = 0
                             c-desc-erro = "Nao foi possível gerar a " + 
                                           "autenticacao.".
                    
                   UNDO DepDinheiro, LEAVE DepDinheiro.

                END.
            
             IF de-dinheiro > 0 THEN
                DO:
                   /* Formata conta integracao */
                   RUN fontes/digbbx.p (INPUT  p-nro-conta,
                                        OUTPUT glb_dsdctitg,
                                        OUTPUT glb_stsnrcal).
                                               
                   ASSIGN c-docto = c-docto-salvo + 
                                    /* 'Sequencial' fixo 01 */
                                    "01" + 
                                    "1".
                
                   { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                    /* Busca a proxima sequencia do campo CRAPLOT.NRSEQDIG */
                    RUN STORED-PROCEDURE pc_sequence_progress
                    aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPLOT"
                                      ,INPUT "NRSEQDIG"
                                      ,STRING(crapcop.cdcooper) + ";" + STRING(crapdat.dtmvtocd,"99/99/9999") + ";" + STRING(p-cod-agencia) + ";11;" + STRING(i-nro-lote)
                                      ,INPUT "N"
                                      ,"").

                    CLOSE STORED-PROC pc_sequence_progress
                    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                    ASSIGN aux_nrseqdig = INTE(pc_sequence_progress.pr_sequence)
                                WHEN pc_sequence_progress.pr_sequence <> ?.
                
                   /*--- Verifica se Lancamento ja Existe ---*/
                   FIND FIRST craplcm WHERE
                              craplcm.cdcooper = crapcop.cdcooper    AND
                              craplcm.dtmvtolt = crapdat.dtmvtocd    AND
                              craplcm.cdagenci = p-cod-agencia       AND
                              craplcm.cdbccxlt = 11                  AND
                              craplcm.nrdolote = i-nro-lote          AND
                              craplcm.nrseqdig = aux_nrseqdig
                              USE-INDEX craplcm3 NO-LOCK NO-ERROR.
                
                   IF AVAIL craplcm THEN   
                      DO:
                          ASSIGN i-cod-erro  = 0
                                 c-desc-erro = "Lancamento ja existente".
       
                          UNDO DepDinheiro, LEAVE DepDinheiro.
       
                      END.
                
                   FIND FIRST craplcm WHERE 
                              craplcm.cdcooper = crapcop.cdcooper    AND
                              craplcm.dtmvtolt = crapdat.dtmvtocd    AND
                              craplcm.cdagenci = p-cod-agencia       AND
                              craplcm.cdbccxlt = 11                  AND
                              craplcm.nrdolote = i-nro-lote          AND
                              craplcm.nrdctabb = p-nro-conta         AND
                              craplcm.nrdocmto = DECI(c-docto) 
                              USE-INDEX craplcm1 NO-LOCK NO-ERROR.
                
                   IF AVAIL craplcm THEN 
                      DO:
                         ASSIGN i-cod-erro  = 0
                                c-desc-erro = 
                                    "Lancamento(Primario) ja existente".
       
                         UNDO DepDinheiro, LEAVE DepDinheiro.
       
                      END.
                
                    RUN gerar_lancamento_conta_comple IN h-b1wgen0200
                                      ( INPUT crapdat.dtmvtolt        /* par_dtmvtolt */
                                       ,INPUT p-cod-agencia           /* par_cdagenci */
                                       ,INPUT 11                      /* par_cdbccxlt */
                                       ,INPUT i-nro-lote              /* par_nrdolote */
                                       ,INPUT aux_nrdconta            /* par_nrdconta */
                                       ,INPUT DECI(c-docto)           /* par_nrdocmto */
                                       ,INPUT 1                       /* par_cdhistor */
                                       ,INPUT aux_nrseqdig            /* par_nrseqdig */
                                       ,INPUT p-vlcomput              /* par_vllanmto */
                                       ,INPUT p-nro-conta             /* par_nrdctabb */
                                       ,INPUT "CRAP51"                /* par_cdpesqbb */
                                       ,INPUT 0                       /* par_vldoipmf */
                                       ,INPUT p-ult-sequencia         /* par_nrautdoc */
                                       ,INPUT 0                       /* par_nrsequni */
                                       ,INPUT 0                       /* par_cdbanchq */
                                       ,INPUT 0                       /* par_cdcmpchq */
                                       ,INPUT 0                       /* par_cdagechq */
                                       ,INPUT 0                       /* par_nrctachq */
                                       ,INPUT 0                       /* par_nrlotchq */
                                       ,INPUT 0                       /* par_sqlotchq */
                                       ,INPUT ""                    /* par_dtrefere */
                                       ,INPUT ""                    /* par_hrtransa */
                                       ,INPUT 0                       /* par_cdoperad */                               
                                       ,INPUT p-identifica            /* par_dsidenti */
                                       ,INPUT crapcop.cdcooper        /* par_cdcooper */
                                       ,INPUT glb_dsdctitg            /* par_nrdctitg */
                                       ,INPUT ""                      /* par_dscedent */
                                       ,INPUT 0                       /* par_cdcoptfn */
                                       ,INPUT 0                       /* par_cdagetfn */
                                       ,INPUT 0                       /* par_nrterfin */
                                       ,INPUT 0                       /* par_nrparepr */
                                       ,INPUT 0                       /* par_nrseqava */
                                       ,INPUT 0                       /* par_nraplica */
                                       ,INPUT 0                       /*par_cdorigem*/
                                       ,INPUT 0                       /* par_idlautom */
                                       ,INPUT 0                       /*par_inprolot*/ 
                                       ,INPUT 0                      /*par_tplotmov */
                                       ,OUTPUT TABLE tt-ret-lancto
                                       ,OUTPUT aux_incrineg
                                       ,OUTPUT aux_cdcritic
                                       ,OUTPUT aux_dscritic).

                   IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
                    DO:  
                      ASSIGN i-cod-erro  = aux_cdcritic
                             c-desc-erro = aux_dscritic.
       
					  UNDO DepDinheiro, LEAVE DepDinheiro.
                   END.  
                   
                   DELETE PROCEDURE h-b1wgen0200.      
                     
                   ASSIGN crapenl.cdsitenv = 1 /* Liberado */
                          crapenl.nrautdoc = p-ult-sequencia
                          crapenl.vldincmp = p-vlcomput. /*craplcm.vllanmto.*/

                   VALIDATE craplot.
       
                END.
                  
             /*---- Gera literal autenticacao - RECEBIMENTO(Rolo) ----*/
             ASSIGN c-nome-titular1 = " "
                    c-nome-titular2 = " ".
            
             FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper AND
                                crapass.nrdconta = aux_nrdconta 
                                NO-LOCK NO-ERROR.
             
             IF AVAIL crapass  THEN
			    DO:
                   ASSIGN c-nome-titular1 = crapass.nmprimtl.

				   IF crapass.inpessoa = 1 THEN
				      DO:
					     FOR FIRST crapttl FIELDS(crapttl.nmextttl)
						                    WHERE crapttl.cdcooper = crapass.cdcooper AND
    						                      crapttl.nrdconta = crapass.nrdconta AND
											      crapttl.idseqttl = 2
											      NO-LOCK:

						   ASSIGN c-nome-titular2 = crapttl.nmextttl.

						 END.
					  END.

		        END.
            
             ASSIGN c-literal = " "
                    c-literal[1]  = TRIM(crapcop.nmrescop) + " - " + 
                                    TRIM(crapcop.nmextcop)
                    c-literal[2]  = " "
                    c-literal[3]  = STRING(crapdat.dtmvtocd,"99/99/99") + " " + 
                                    STRING(TIME,"HH:MM:SS") +  " PAC " +
                                    STRING(p-cod-agencia,"999") + "  CAIXA: " + 
                                    STRING(p-nro-caixa,"Z99") + "/" +
                                    SUBSTR(p-cod-operador,1,10)
                    c-literal[4]  = " "
                    c-literal[5]  = "      ** COMPROVANTE DE DEPOSITO " + 
                                    STRING(i-nro-docto,"ZZZ,ZZ9")  + " **"
                    c-literal[6]  = " "
                    c-literal[7]  = "CONTA: "    +  
                                    TRIM(STRING(aux_nrdconta,"zzzz,zzz,9"))     +
                                    "   PAC: " + TRIM(STRING(crapass.cdagenci)) 
                    c-literal[8]  = "       "    +  TRIM(c-nome-titular1)
                    c-literal[9]  = "       "    +  TRIM(c-nome-titular2)
                    c-literal[10] = " ".
                            
             IF p-identifica <> "  "   THEN
                ASSIGN c-literal[11] = "DEPOSITADO POR"  
                       c-literal[12] = TRIM(p-identifica)
                       c-literal[13] = " ".  
                      
             ASSIGN c-literal[14] = "   TIPO DE DEPOSITO     VALOR EM R$ LIBERACAO EM"
                    c-literal[15] = "------------------------------------------------".
            
             IF de-dinheiro > 0   THEN
                ASSIGN c-literal[16] = "   EM DINHEIRO.....: " +  
                                       STRING(de-dinheiro,"ZZZ,ZZZ,ZZ9.99") + "   ".
            
             ASSIGN c-literal[22] = " "
                    c-literal[23] = "TOTAL DEPOSITADO...: " +   
                                    STRING(de-valor,"ZZZ,ZZZ,ZZ9.99")
                    c-literal[24] = " "
                    c-literal[25] = p-literal
                    c-literal[26] = " "
                    c-literal[27] = " "
                    c-literal[28] = " "
                    c-literal[29] = " "
                    c-literal[30] = " "
                    c-literal[31] = " "
                    c-literal[32] = " "
                    c-literal[33] = " "
                    c-literal[34] = " "
                    c-literal[35] = " "
                    p-literal-autentica = STRING(c-literal[1],"x(48)")   +
                                          STRING(c-literal[2],"x(48)")   +
                                          STRING(c-literal[3],"x(48)")   +
                                          STRING(c-literal[4],"x(48)")   +
                                          STRING(c-literal[5],"x(48)")   +
                                          STRING(c-literal[6],"x(48)")   +
                                          STRING(c-literal[7],"x(48)")   +
                                          STRING(c-literal[8],"x(48)")   +
                                          STRING(c-literal[9],"x(48)")   +
                                          STRING(c-literal[10],"x(48)").   
               
             IF c-literal[12] <> " "   THEN
                ASSIGN p-literal-autentica =
                       p-literal-autentica + STRING(c-literal[11],"x(48)")
                       p-literal-autentica =
                       p-literal-autentica + STRING(c-literal[12],"x(48)")
                       p-literal-autentica =
                       p-literal-autentica + STRING(c-literal[13],"x(48)").
            
             ASSIGN p-literal-autentica =
                    p-literal-autentica + STRING(c-literal[14],"x(48)")
                    p-literal-autentica =
                    p-literal-autentica + STRING(c-literal[15],"x(48)").
            
             IF c-literal[16] <> " " THEN
                ASSIGN p-literal-autentica = p-literal-autentica + 
                                             STRING(c-literal[16],"x(48)").
            
             IF c-literal[17] <> " " THEN
                ASSIGN p-literal-autentica = p-literal-autentica + 
                                             STRING(c-literal[17],"x(48)").
            
             ASSIGN p-literal-autentica = p-literal-autentica         +
                                          STRING(c-literal[22],"x(48)")   +
                                          STRING(c-literal[23],"x(48)")   +
                                          STRING(c-literal[24],"x(48)")   +
                                          STRING(c-literal[25],"x(48)")   +
                                          STRING(c-literal[26],"x(48)")   +
                                          STRING(c-literal[27],"x(48)")   +
                                          STRING(c-literal[28],"x(48)")   +
                                          STRING(c-literal[29],"x(48)")   +
                                          STRING(c-literal[30],"x(48)")   +
                                          STRING(c-literal[31],"x(48)")   +
                                          STRING(c-literal[32],"x(48)")   +
                                          STRING(c-literal[33],"x(48)")   +
                                          STRING(c-literal[34],"x(48)")   +
                                          STRING(c-literal[35],"x(48)")
                                          in99 = 0.
       
             DO WHILE TRUE:
       
                ASSIGN in99 = in99 + 1.
       
                FIND FIRST crapaut WHERE RECID(crapaut) = p-registro 
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
            
                IF NOT AVAIL crapaut THEN 
                   DO:
                      IF LOCKED crapaut THEN 
                         DO:
                             IF in99 < 100 THEN 
                                DO:
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                             ELSE 
                                DO:
                                    ASSIGN i-cod-erro  = 0
                                           c-desc-erro = 
                                                     "Tabela CRAPAUT em uso ".
       
                                    UNDO DepDinheiro, LEAVE DepDinheiro.
       
                                END.
                         END.
                   END.
                ELSE 
                   DO:
                      ASSIGN  crapaut.dslitera = p-literal-autentica.
                      RELEASE crapaut.
                      LEAVE.
                   END.

             END. /* DO WHILE */
            
             RELEASE craplot.
            
          END.

       ASSIGN aux_returnvl = "OK".

    END.

    IF i-cod-erro <> 0   OR
       c-desc-erro <> "" THEN
       RUN cria-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa,
                      INPUT i-cod-erro,
                      INPUT c-desc-erro,
                      INPUT YES).

    RETURN aux_returnvl.

END PROCEDURE.


PROCEDURE descarta_envelope:
    DEFINE INPUT  PARAM par_nmrescop    AS CHAR             NO-UNDO.
    DEFINE INPUT  PARAM par_cdagenci    AS INT              NO-UNDO.
    DEFINE INPUT  PARAM par_nrdcaixa    AS INT              NO-UNDO.
    DEFINE INPUT  PARAM par_dtmvtolt    AS DATE             NO-UNDO.
    DEFINE INPUT  PARAM par_nrsequni    AS INT              NO-UNDO.

    FIND crapcop WHERE crapcop.nmrescop = par_nmrescop NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN i-cod-erro  = 794
                   c-desc-erro = "".
        END.
    ELSE
        DO:
            FIND crapenl WHERE crapenl.cdcoptfn = crapcop.cdcooper  AND
                               crapenl.dtmvtolt = par_dtmvtolt      AND
                               crapenl.nrseqenv = par_nrsequni
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
            
            IF  NOT AVAILABLE crapenl   THEN
                DO:
                    IF  LOCKED crapenl  THEN
                        ASSIGN i-cod-erro  = 0
                               c-desc-erro = "Registro do Envelope em Uso.".
                    ELSE
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "Envelope nao encontrado.".
                END.
        END.

    IF  i-cod-erro  <> 0   OR
        c-desc-erro <> ""  THEN
        DO: 
            RUN cria-erro (INPUT par_nmrescop,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    ASSIGN crapenl.cdsitenv = 2  /* Descartado */
           crapenl.vldincmp = 0
           crapenl.vlchqcmp = 0.

    FIND CURRENT crapenl NO-LOCK.

    RETURN "OK".
END PROCEDURE.
/* Fim descarta_envelope */







PROCEDURE confere_envelope:
    DEFINE INPUT  PARAM par_nmrescop    AS CHAR             NO-UNDO.
    DEFINE INPUT  PARAM par_cdagenci    AS INT              NO-UNDO.
    DEFINE INPUT  PARAM par_nrdcaixa    AS INT              NO-UNDO.
    DEFINE INPUT  PARAM par_dtmvtolt    AS DATE             NO-UNDO.
    DEFINE INPUT  PARAM par_nrsequni    AS INT              NO-UNDO.
    DEFINE INPUT  PARAM par_vldincmp    AS DEC              NO-UNDO.
    DEFINE INPUT  PARAM par_vlchqcmp    AS DEC              NO-UNDO.

    FIND crapcop WHERE crapcop.nmrescop = par_nmrescop NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN i-cod-erro  = 794
                   c-desc-erro = "".
        END.
    ELSE
        DO:
            FIND crapenl WHERE crapenl.cdcoptfn = crapcop.cdcooper  AND
                               crapenl.dtmvtolt = par_dtmvtolt      AND
                               crapenl.nrseqenv = par_nrsequni
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
            
            IF  NOT AVAILABLE crapenl   THEN
                DO:
                    IF  LOCKED crapenl  THEN
                        ASSIGN i-cod-erro  = 0
                               c-desc-erro = "Registro do Envelope em Uso.".
                    ELSE
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "Envelope nao encontrado.".
                END.
        END.

    IF  i-cod-erro  <> 0   OR
        c-desc-erro <> ""  THEN
        DO: 
            RUN cria-erro (INPUT par_nmrescop,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    /* Atualiza os valores porem a finalizacao da situação para "1"
       eh feita na rotina 51 apos o deposito dos valores */
    ASSIGN crapenl.vldincmp = par_vldincmp
           crapenl.vlchqcmp = par_vlchqcmp.

    FIND CURRENT crapenl NO-LOCK.

    RETURN "OK".
END PROCEDURE.
/* Fim confere_envelope */


PROCEDURE libera_envelope:
    DEFINE INPUT  PARAM par_nmrescop    AS CHAR             NO-UNDO.
    DEFINE INPUT  PARAM par_cdagenci    AS INT              NO-UNDO.
    DEFINE INPUT  PARAM par_nrdcaixa    AS INT              NO-UNDO.
    DEFINE INPUT  PARAM par_dtmvtolt    AS DATE             NO-UNDO.
    DEFINE INPUT  PARAM par_nrsequni    AS INT              NO-UNDO.
    DEFINE INPUT  PARAM par_nrautdoc    AS INT              NO-UNDO.

    FIND crapcop WHERE crapcop.nmrescop = par_nmrescop NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN i-cod-erro  = 794
                   c-desc-erro = "".
        END.
    ELSE
        DO:
            FIND crapenl WHERE crapenl.cdcoptfn = crapcop.cdcooper  AND
                               crapenl.dtmvtolt = par_dtmvtolt      AND
                               crapenl.nrseqenv = par_nrsequni
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
            
            IF  NOT AVAILABLE crapenl   THEN
                DO:
                    IF  LOCKED crapenl  THEN
                        ASSIGN i-cod-erro  = 0
                               c-desc-erro = "Registro do Envelope em Uso.".
                    ELSE
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "Envelope nao encontrado.".
                END.
        END.

    IF  i-cod-erro  <> 0   OR
        c-desc-erro <> ""  THEN
        DO: 
            RUN cria-erro (INPUT par_nmrescop,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    ASSIGN crapenl.cdsitenv = 1 /* Liberado */
           crapenl.nrautdoc = par_nrautdoc.

    FIND CURRENT crapenl NO-LOCK.

    RETURN "OK".
END PROCEDURE.
/* Fim libera_envelope */





PROCEDURE verifica_dia_util:
    DEFINE INPUT  PARAM par_nmrescop    AS CHAR             NO-UNDO.
    DEFINE INPUT  PARAM par_dtmvtinf    AS DATE             NO-UNDO.
    /* retorna char para ficar compativel com o campo html */
    DEFINE OUTPUT PARAM par_dtmvtret    AS CHAR             NO-UNDO.

    DEFINE VARIABLE     aux_dtmvtolt    AS DATE             NO-UNDO.

    /* data informada */
    ASSIGN aux_dtmvtolt = par_dtmvtinf.

    FIND crapcop WHERE crapcop.nmrescop = par_nmrescop NO-LOCK NO-ERROR.

    IF  AVAILABLE crapcop  THEN
        DO:
            /* valida se a data é dia útil, caso contrario, retorna
               o proximo dia útil */
            DO  WHILE TRUE:

                IF  CAN-DO("1,7",STRING(WEEKDAY(aux_dtmvtolt))) OR
                    CAN-FIND(crapfer WHERE crapfer.cdcooper = crapcop.cdcooper  AND
                                           crapfer.dtferiad = aux_dtmvtolt)     THEN
                    aux_dtmvtolt = aux_dtmvtolt + 1.
                ELSE
                    LEAVE.
            END.
        END.

    /* retorno da data */
    par_dtmvtret = STRING(aux_dtmvtolt).
        
    RETURN "OK".

END PROCEDURE.
/* Fim verifica_dia_util */

/* .......................................................................... */




