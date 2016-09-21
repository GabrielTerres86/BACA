/* ............................................................................

   Programa: Fontes/crps632.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Rafael Cechet
   Data    : DEZEMBRO/2012                      Ultima atualizacao: 14/01/2014
   
   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Relatorio - Acerto Financeiro entre contas BB das singulares.
               Emite relatorio 633
               
   Alteracoes: 23/12/2013 - Ajuste na realizacao dos lancamentos de acerto
                            por cooperativa migrada. (Rafael)
                            
               14/01/2014 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO)              
   
............................................................................ */

{ includes/var_batch.i }

DEF STREAM str_1.   /*  Para relatorio de criticas  */

DEF TEMP-TABLE tt-rel NO-UNDO
    FIELD cdcopdst  LIKE crapafi.cdcopdst
    FIELD nrdconta  LIKE crapass.nrdconta
    FIELD nrdctabb  LIKE crapcco.nrdctabb
    FIELD cdhisafi  LIKE crapafi.cdhisafi
    FIELD vlareceb  AS DECI
    FIELD vlapagar  AS DECI.

/*** Campos novos ou utilizados ***/
DEF VAR aux_qtdregis AS INT                                      NO-UNDO.
DEF VAR aux_vltotreg AS DECI                                     NO-UNDO.

DEF VAR aux_cdcopini AS INTE                                     NO-UNDO.
DEF VAR aux_cdcopfim AS INTE                                     NO-UNDO.
DEF VAR aux_dtmvtopr AS DATE                                     NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                     NO-UNDO.
DEF VAR aux_nmtrfcop AS CHAR                                     NO-UNDO.
DEF VAR rel_vltotcre AS DECI                                     NO-UNDO.
DEF VAR rel_vltotdeb AS DECI                                     NO-UNDO. 

/* Relatorios */
DEF VAR rel_nmempres AS CHAR    FORMAT "x(15)"                   NO-UNDO.
DEF VAR rel_nmrelato AS CHAR    FORMAT "x(50)" EXTENT 5          NO-UNDO.
DEF VAR rel_nrmodulo AS INT     FORMAT "9"                       NO-UNDO.
DEF VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                        INIT ["DEP. A VISTA   ","CAPITAL        ",
                              "EMPRESTIMOS    ","DIGITACAO      ",
                              "GENERICO       "]                 NO-UNDO.

DEF BUFFER b-crapcop FOR crapcop.

FORM aux_dtmvtopr       AT 01 FORMAT "99/99/9999" LABEL "DATA"
     SKIP
     WITH NO-BOX SIDE-LABELS DOWN WIDTH 132 FRAME f_cab.

FORM "Origem: "
     crapcop.nmrescop           FORMAT "X(30)"    NO-LABEL
     SKIP
     "Valores a pagar/receber: "
     aux_nmtrfcop               FORMAT "X(30)"    NO-LABEL
     SKIP(1)
     WITH NO-BOX SIDE-LABELS DOWN WIDTH 132 FRAME f_coop.

FORM tt-rel.nrdctabb    LIKE crapcco.nrdctabb     COLUMN-LABEL "Conta BB"
     tt-rel.vlareceb    FORMAT "zzz,zzz,zz9.99"   COLUMN-LABEL "A receber "
     tt-rel.vlapagar    FORMAT "zzz,zzz,zz9.99"   COLUMN-LABEL "A pagar"
     WITH NO-BOX DOWN COL 1 WIDTH 132 FRAME f_relat_detalhe.

FORM 
  SKIP(1)
  "TOTAL"                                                      AT  5
  rel_vltotcre          FORMAT "zzz,zzz,zz9.99"       NO-LABEL AT 12
  rel_vltotdeb          FORMAT "zzz,zzz,zz9.99"       NO-LABEL AT 27
  SKIP(1)
  WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_relat_total.

/********************************* Inicio ***********************************/

ASSIGN glb_cdprogra = "crps632".

RUN fontes/iniprg.p.
                    
IF glb_cdcritic > 0 THEN
   DO:
       UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                          glb_cdprogra + "' --> '" +
                          glb_dscritic + " >> log/proc_batch.log").
       RETURN.
   END.
                            
DO WHILE TRUE:

   FIND FIRST crapdat WHERE crapdat.cdcooper = glb_cdcooper
                            NO-LOCK NO-ERROR NO-WAIT.

   IF   NOT AVAILABLE crapdat   THEN
        IF   LOCKED crapdat   THEN
             DO:
                 PAUSE 1 NO-MESSAGE.
                 NEXT.
             END.
        ELSE
             glb_cdcritic = 1.
   ELSE
        ASSIGN glb_cdcritic = 0
               glb_dtmvtolt = crapdat.dtmvtolt
               aux_dtmvtopr = crapdat.dtmvtopr.

   LEAVE.

END.                               


EMPTY TEMP-TABLE tt-rel.
RUN pi_acerto_financeiro_cobranca ( INPUT 1 ).

/**** GERAR RELATORIO 633 ******/
RUN pi_gera_relatorio ( INPUT 1 ).

EMPTY TEMP-TABLE tt-rel.
RUN pi_acerto_financeiro_cobranca ( INPUT 2 ).

/**** GERAR RELATORIO 633 ******/
RUN pi_gera_relatorio ( INPUT 2 ).

EMPTY TEMP-TABLE tt-rel.
RUN pi_acerto_financeiro_cobranca ( INPUT 16 ).

/**** GERAR RELATORIO 633 ******/
RUN pi_gera_relatorio ( INPUT 16 ).

RUN fontes/fimprg.p.

/*...........................................................................*/

PROCEDURE pi_acerto_financeiro_cobranca:

    DEF INPUT PARAM par_cdcooper    LIKE    crapcop.cdcooper        NO-UNDO.
/*    DEF INPUT PARAM par_nrdctabb    LIKE    crapcco.nrdctabb        NO-UNDO. */

    DEF VAR aux_vllanmto  AS DECI  INIT 0                           NO-UNDO.
    DEF VAR aux_cdhistor            LIKE    craphis.cdhistor        NO-UNDO.

    /* buscar valores de credito BB na VIACREDI */
    FOR EACH crapafi WHERE
             crapafi.cdcooper = par_cdcooper  AND
             crapafi.dtmvtolt = glb_dtmvtolt
        BREAK BY crapafi.cdcopdst
              BY crapafi.nrdctabb
              BY crapafi.cdhisafi:

        IF  FIRST-OF(crapafi.cdhisafi) THEN
            ASSIGN aux_vllanmto = 0.

        ASSIGN aux_vllanmto = aux_vllanmto + crapafi.vllanmto.

        FIND craphis WHERE craphis.cdcooper = glb_cdcooper AND
                           craphis.cdhistor = crapafi.cdhisafi
                           NO-LOCK NO-ERROR.

        FIND tt-rel WHERE 
             tt-rel.cdcopdst = crapafi.cdcopdst AND
             tt-rel.nrdctabb = crapafi.nrdctabb AND
             tt-rel.cdhisafi = crapafi.cdhisafi
             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAIL tt-rel THEN
            DO:
                CREATE tt-rel.
                ASSIGN tt-rel.cdcopdst = crapafi.cdcopdst
                       tt-rel.nrdctabb = crapafi.nrdctabb
                       tt-rel.cdhisafi = crapafi.cdhisafi.

                IF  craphis.indebcre = "C" THEN
                    tt-rel.vlareceb = crapafi.vllanmto.
                ELSE
                    tt-rel.vlapagar = crapafi.vllanmto.
            END.                  
        ELSE
            DO:
                IF  craphis.indebcre = "C" THEN
                    tt-rel.vlareceb = tt-rel.vlareceb + crapafi.vllanmto.
                ELSE
                    tt-rel.vlapagar = tt-rel.vlapagar + crapafi.vllanmto.
            END.

        IF  LAST-OF(crapafi.cdhisafi) THEN
            DO:
                /* conta BB da cooperativa */
                /*FIND FIRST gnctace WHERE gnctace.cddbanco = 001      AND
                                         gnctace.nrctacen = par_nrdctabb
                                         NO-LOCK NO-ERROR.*/
        
                /* Busca Numero da Conta na CECRED (cadastrado na crapass) */ 
                FIND crapcop WHERE crapcop.cdcooper = par_cdcooper
                                   NO-LOCK NO-ERROR.
        
                FIND crapass WHERE crapass.cdcooper = glb_cdcooper  AND
                                   crapass.nrdconta = crapcop.nrctactl 
                                   NO-LOCK NO-ERROR.
        
                IF  aux_vllanmto > 0 THEN
                    DO:
                        RUN cria_lancamento(INPUT crapass.cdcooper,
                                            INPUT crapass.nrdconta,
                                            INPUT crapafi.cdhisafi, 
                                            INPUT 10999, /* lote de acerto */
                                            INPUT glb_dtmvtopr,
                                            INPUT aux_vllanmto).
                    END.
            END.
    END.

END PROCEDURE.

/*...........................................................................*/

PROCEDURE pi_gera_relatorio:

    DEF INPUT PARAM par_cdcooper    LIKE crapcop.cdcooper             NO-UNDO.
  
    ASSIGN glb_cdcritic = 0.

    ASSIGN glb_cdempres    = 11
           glb_cdrelato[1] = 633.
    
   { includes/cabrel132_1.i }

   FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

   ASSIGN aux_nmarqimp = "rl/crrl633_" + crapcop.dsdircop + ".lst". 
   
   OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

   VIEW STREAM str_1 FRAME f_cabrel132_1.

   DISPLAY STREAM str_1  aux_dtmvtopr
           WITH FRAME f_cab.

   DISP STREAM str_1 SKIP(1).

   FOR EACH tt-rel NO-LOCK
       BREAK BY tt-rel.cdcopdst
             BY tt-rel.nrdctabb:

       IF  FIRST-OF(tt-rel.cdcopdst) THEN DO:

           FOR FIRST b-crapcop FIELD (nmrescop)
               WHERE b-crapcop.cdcooper = crapafi.cdcopdst
               NO-LOCK.

               ASSIGN aux_nmtrfcop = b-crapcop.nmrescop.
           END.

           DISPLAY STREAM str_1 
                   crapcop.nmrescop
                   aux_nmtrfcop
                   WITH FRAME f_coop.

           DOWN STREAM str_1 WITH FRAME f_coop.
       END.

       IF  FIRST-OF(tt-rel.nrdctabb) THEN
           ASSIGN rel_vltotcre = 0
                  rel_vltotdeb = 0.

       IF  LINE-COUNTER(str_1) > 84 THEN
           PAGE STREAM str_1.

       ASSIGN rel_vltotcre = rel_vltotcre + tt-rel.vlareceb
              rel_vltotdeb = rel_vltotdeb + tt-rel.vlapagar.

       DISPLAY STREAM str_1 tt-rel.nrdctabb
                            tt-rel.vlareceb
                            tt-rel.vlapagar
                            WITH FRAME f_relat_detalhe.

       DOWN STREAM str_1 WITH FRAME f_relat_detalhe.

       IF  LAST-OF(tt-rel.nrdctabb) THEN
           DO:
               DISPLAY STREAM str_1 
                              rel_vltotcre
                              rel_vltotdeb
                              WITH FRAME f_relat_total.
    
               DOWN STREAM str_1 WITH FRAME f_relat_total.
           END.
   END.                                        

   OUTPUT STREAM str_1 CLOSE.
              
   ASSIGN glb_nrcopias = 1
          glb_nmformul = "132col"
          glb_nmarqimp = aux_nmarqimp
          glb_cdcritic = 0.
    
   RUN fontes/imprim.p.
       
   
END PROCEDURE. /* fim */


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
            VALIDATE craplot.
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
    VALIDATE craplcm.
    
    FIND craphis WHERE craphis.cdcooper = par_cdcooper AND
                       craphis.cdhistor = par_cdhistor
                       NO-LOCK NO-ERROR.

    IF  AVAIL craphis THEN
        DO:
            IF  craphis.indebcre = "D" THEN
                DO:
                    craplot.vlcompdb = craplot.vlcompcr + par_vllanmto.
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


/*............................................................................*/


