/* .............................................................................

   Programa: Fontes/crps631.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Tiago
   Data    : Dezembro/2012.                  Ultima atualizacao: 26/12/2013    

   Dados referentes ao programa:

   Frequencia: 
   Objetivo  : Efetuar o repasse de diversos valores da Viacredi 
               para a AltoVale (INSS).

   Alteracoes: 14/01/2013 - Efetuar repasse de cheques pagos na Viacredi (Ze).
   
               05/09/2013 - Implementado tratamento para a migracao Acrecicoop
                            x Viacredi(Reinert).
                            
               26/12/2013 - Tratamento para Acredicoop (Ze).             
............................................................................ */

DEF STREAM str_1.

{ includes/var_batch.i }  

DEF VAR aux_vllanmto    AS  DECI                                        NO-UNDO.
DEF VAR aux_vllanmtc    AS  DECI                                        NO-UNDO.
DEF VAR aux_nmarquiv    AS  CHAR                                        NO-UNDO.
DEF VAR aux_nrcontad    AS  INT                                         NO-UNDO.
DEF VAR aux_nrcontac    AS  INT                                         NO-UNDO.

DEF BUFFER crabcop FOR crapcop.

ASSIGN glb_cdprogra = "crps631"
       aux_nmarquiv = "integra/crrl631.lst".

RUN fontes/iniprg.p.                   

IF glb_cdcritic > 0 THEN
   DO:
       UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                          glb_cdprogra + "' --> '" +
                          glb_dscritic + " >> log/proc_batch.log").
       RETURN.

   END.

OUTPUT STREAM str_1 TO VALUE(aux_nmarquiv) PAGED PAGE-SIZE 84.

FORM
    aux_nrcontad AT  1    FORMAT "zzzz,zzz,9"          LABEL "Conta Debitada"
    aux_vllanmto AT  16   FORMAT "zzz,zzz,zzz,zz9.99"  LABEL "Valor Debito"
    aux_nrcontac AT  35   FORMAT "zzzz,zzz,9"          LABEL "Conta Creditada"
    aux_vllanmtc AT  51   FORMAT "zzz,zzz,zzz,zz9.99"  LABEL "Valor Credito"
    WITH DOWN NO-BOX NO-LABEL WIDTH 80 FRAME f_contlanc.

/*********** TRATAMENTO PARA INSS **************/

/*Migracao Viacredi x Alto Vale*/
 
RUN somar_lancamentos(INPUT  16, /*altovale*/
                      INPUT  glb_dtmvtolt,
                      INPUT  1118, /*cdhistor*/
                      OUTPUT aux_vllanmto).

IF  aux_vllanmto <> 0 THEN
    DO: 
        ASSIGN aux_nrcontad = 19
               aux_nrcontac = 159
               aux_vllanmtc = aux_vllanmto.

        /*debito INSS viacredi*/
        RUN cria_lancamento(INPUT 3,
                            INPUT aux_nrcontad,
                            INPUT 1119,
                            INPUT 10121,
                            INPUT glb_dtmvtolt,
                            INPUT aux_vllanmto).
        
        /*credito INSS altovale*/
        RUN cria_lancamento(INPUT 3,
                            INPUT aux_nrcontac,
                            INPUT 1120,
                            INPUT 10122,
                            INPUT glb_dtmvtolt,
                            INPUT aux_vllanmto).
        
        DISPLAY STREAM str_1
                aux_nrcontad
                aux_vllanmto
                aux_nrcontac
                aux_vllanmtc
                WITH FRAME f_contlanc.
        DOWN STREAM str_1 WITH FRAME f_contlanc.

    END.

/*Migracao Acredicop x Viacredi */

RUN somar_lancamentos(INPUT 1, /*viacredi*/
                      INPUT glb_dtmvtolt,
                      INPUT 1118, /*cdhistor*/
                      OUTPUT aux_vllanmto).

IF aux_vllanmto <> 0 THEN
    DO:
    ASSIGN aux_nrcontad = 27
           aux_nrcontac = 19
           aux_vllanmtc = aux_vllanmto.

    /*debito INSS Acredicoop*/
    RUN cria_lancamento(INPUT 3,
                        INPUT aux_nrcontad,
                        INPUT 1119,
                        INPUT 10121,
                        INPUT glb_dtmvtolt,
                        INPUT aux_vllanmto).
    
    /*credito INSS Viacredi*/
    RUN cria_lancamento(INPUT 3,
                        INPUT aux_nrcontac,
                        INPUT 1120,
                        INPUT 10122,
                        INPUT glb_dtmvtolt,
                        INPUT aux_vllanmto).

    DISPLAY STREAM str_1
            aux_nrcontad
            aux_vllanmto
            aux_nrcontac
            aux_vllanmtc
            WITH FRAME f_contlanc.
    DOWN STREAM str_1 WITH FRAME f_contlanc.
    
    END.

/*********** TRATAMENTO PARA CHEQUES **************/


/*  AltoVale */    
ASSIGN aux_vllanmto = 0.

RUN somar_lancamentos_cheque(INPUT  16,             /* cdcooper */
                             INPUT  glb_dtmvtolt,
                             INPUT  101,            /* Agencia do Cheque */
                             OUTPUT aux_vllanmto).

IF  aux_vllanmto <> 0 THEN
    DO: 
        FIND crabcop WHERE crabcop.cdcooper = 1 NO-LOCK NO-ERROR.
        
        IF   AVAILABLE crabcop THEN
             DO:
                  IF   crabcop.nrctacmp <> 0 THEN
                       /* CHEQUE viacredi */
                       RUN cria_lancamento(INPUT 3,
                                           INPUT crabcop.nrctacmp,
                                           INPUT 1137,
                                           INPUT 10123,
                                           INPUT glb_dtmvtolt,
                                           INPUT aux_vllanmto).
             END.
             
        
        FIND crabcop WHERE crabcop.cdcooper = 16 NO-LOCK NO-ERROR.
        
        IF   AVAILABLE crabcop THEN
             DO:
                  IF   crabcop.nrctacmp <> 0 THEN
                       /* CHEQUE altovale */
                       RUN cria_lancamento(INPUT 3,
                                           INPUT crabcop.nrctacmp,
                                           INPUT 1136,
                                           INPUT 10123,
                                           INPUT glb_dtmvtolt,
                                           INPUT aux_vllanmto).
             END.
    END.
    
    
    /* Acredicoop */
    ASSIGN aux_vllanmto = 0.

    RUN somar_lancamentos_cheque(INPUT  1,             /* cdcooper */
                                 INPUT  glb_dtmvtolt,
                                 INPUT  102,           /* Agencia do Cheque */
                                 OUTPUT aux_vllanmto).

    IF  aux_vllanmto <> 0 THEN
        DO: 
            FIND crabcop WHERE crabcop.cdcooper = 2 NO-LOCK NO-ERROR.

            IF   AVAILABLE crabcop THEN
                 DO:
                      IF   crabcop.nrctacmp <> 0 THEN
                           /* CHEQUE viacredi */
                           RUN cria_lancamento(INPUT 3,
                                               INPUT crabcop.nrctacmp,
                                               INPUT 1137,
                                               INPUT 10123,
                                               INPUT glb_dtmvtolt,
                                               INPUT aux_vllanmto).
                 END.


            FIND crabcop WHERE crabcop.cdcooper = 1 NO-LOCK NO-ERROR.

            IF   AVAILABLE crabcop THEN
                 DO:
                      IF   crabcop.nrctacmp <> 0 THEN
                           /* CHEQUE altovale */
                           RUN cria_lancamento(INPUT 3,
                                               INPUT crabcop.nrctacmp,
                                               INPUT 1136,
                                               INPUT 10123,
                                               INPUT glb_dtmvtolt,
                                               INPUT aux_vllanmto).
                 END.
        END.

    
    
RUN fontes/fimprg.p.


/* ***************************** PROCEDURES ******************************* */
PROCEDURE somar_lancamentos:

    DEF INPUT PARAM par_cdcooper    LIKE    crapcop.cdcooper        NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt    AS      DATE                    NO-UNDO.
    DEF INPUT PARAM par_cdhistor    LIKE    craplcm.cdhistor        NO-UNDO.

    DEF OUTPUT PARAM par_vllanmto   LIKE    craplcm.vllanmto        NO-UNDO.


    ASSIGN par_vllanmto = 0.

    FOR EACH craplcm WHERE craplcm.cdcooper = par_cdcooper AND
                           craplcm.dtmvtolt = par_dtmvtolt AND
                           craplcm.cdhistor = par_cdhistor NO-LOCK:

        ASSIGN par_vllanmto = par_vllanmto + craplcm.vllanmto.

    END.

    RETURN "OK".
END PROCEDURE.

PROCEDURE cria_lancamento:

    DEF INPUT PARAM par_cdcooper    LIKE    crapcop.cdcooper        NO-UNDO.
    DEF INPUT PARAM par_nrdconta    LIKE    craplcm.nrdconta        NO-UNDO.
    DEF INPUT PARAM par_cdhistor    LIKE    craplcm.cdhistor        NO-UNDO.
    DEF INPUT PARAM par_nrdolote    LIKE    craplot.nrdolote        NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt    AS      DATE                    NO-UNDO.
    DEF INPUT PARAM par_vllanmto    LIKE    craplcm.vllanmto        NO-UNDO.

    FIND craplot WHERE craplot.cdcooper = par_cdcooper AND
                       craplot.dtmvtolt = par_dtmvtolt AND
                       craplot.cdagenci = 1            AND
                       craplot.cdbccxlt = 100          AND
                       craplot.nrdolote = par_nrdolote NO-ERROR.

    IF  NOT AVAIL craplot THEN
        DO:
            CREATE craplot.
            ASSIGN craplot.cdcooper = par_cdcooper
                   craplot.dtmvtolt = par_dtmvtolt
                   craplot.cdagenci = 1
                   craplot.cdbccxlt = 100
                   craplot.nrdolote = par_nrdolote
                   craplot.tplotmov = 1.
        END.

    CREATE craplcm.
    ASSIGN craplcm.dtmvtolt = craplot.dtmvtolt
           craplcm.cdagenci = craplot.cdagenci
           craplcm.cdbccxlt = craplot.cdbccxlt
           craplcm.nrdolote = craplot.nrdolote
           craplcm.nrdconta = par_nrdconta
           craplcm.nrdctabb = par_nrdconta
           craplcm.nrdctitg = STRING(par_nrdconta,"99999999")
           craplcm.vllanmto = par_vllanmto
           craplcm.cdhistor = par_cdhistor
           craplcm.nrseqdig = craplot.nrseqdig + 1
           craplcm.nrdocmto = craplot.nrseqdig + 1
           craplcm.cdcooper = craplot.cdcooper.

    FIND craphis WHERE craphis.cdcooper = par_cdcooper AND
                       craphis.cdhistor = par_cdhistor
                       NO-LOCK NO-ERROR.

    IF  AVAIL craphis THEN
        DO:
            IF  craphis.indebcre = "D" THEN
                DO:
                    craplot.vlcompdb = craplot.vlcompdb + par_vllanmto.
                    craplot.vlinfodb = craplot.vlcompdb.
                END.
            ELSE
                DO:  
                    IF  craphis.indebcre = "C" THEN
                        DO:
                            craplot.vlcompcr = craplot.vlcompcr + par_vllanmto.
                            craplot.vlinfocr = craplot.vlcompcr.
                        END.
                END.
        END.

    ASSIGN craplot.nrseqdig = craplot.nrseqdig + 1
           craplot.qtcompln = craplot.qtcompln + 1
           craplot.qtinfoln = craplot.qtcompln. 

END PROCEDURE.

PROCEDURE somar_lancamentos_cheque:

    DEF INPUT PARAM par_cdcooper    LIKE    crapcop.cdcooper        NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt    AS      DATE                    NO-UNDO.
    DEF INPUT PARAM par_cdagechq    LIKE    craplcm.cdagechq        NO-UNDO.

    DEF OUTPUT PARAM par_vllanmto   LIKE    craplcm.vllanmto        NO-UNDO.
    
    ASSIGN par_vllanmto = 0.

    FOR EACH craplcm WHERE craplcm.cdcooper = par_cdcooper      AND
                           craplcm.dtmvtolt = par_dtmvtolt      AND
                           craplcm.cdbccxlt = 100               AND
                           craplcm.nrdolote > 205000            AND
                           craplcm.nrdolote < 205099            NO-LOCK:
                       
        IF   craplcm.cdbanchq <> 85           OR
             craplcm.cdagechq <> par_cdagechq THEN
             NEXT.
    
        IF   par_cdagechq = 102 THEN
             FIND craptco WHERE craptco.cdcooper = craplcm.cdcooper      AND
                                craptco.nrdconta = INT(craplcm.nrctachq) AND
                                craptco.tpctatrf = 1                     AND
                                craptco.flgativo = TRUE                  AND
                               (craptco.cdageant = 02                    OR
                                craptco.cdageant = 04                    OR
                                craptco.cdageant = 06                    OR
                                craptco.cdageant = 07                    OR
                                craptco.cdageant = 11)
                                NO-LOCK NO-ERROR.
        ELSE
            FIND craptco WHERE craptco.cdcooper = craplcm.cdcooper      AND
                               craptco.nrdconta = INT(craplcm.nrctachq) AND
                               craptco.tpctatrf = 1                     AND
                               craptco.flgativo = TRUE
                               NO-LOCK NO-ERROR.

        IF   AVAILABLE craptco THEN
             ASSIGN par_vllanmto = par_vllanmto + craplcm.vllanmto.
    END.

    RETURN "OK".

END PROCEDURE.


OUTPUT STREAM str_1 CLOSE.
/* .......................................................................... */
