{ /usr/coop/sistema/generico/includes/b1wgen0074tt.i }
{ /usr/coop/sistema/generico/includes/var_internet.i }
{ /usr/coop/sistema/generico/includes/gera_log.i }
{ /usr/coop/sistema/generico/includes/gera_erro.i }
{ /usr/coop/sistema/ayllos/includes/var_online.i "new" }
{ /usr/coop/sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM  &SESSAO-DESKTOP=SIM}

DEF STREAM str_1.

DEF VAR h-b1wgen0074    AS      HANDLE                              NO-UNDO.
DEF VAR aux_flgsuces    AS      LOGICAL                             NO-UNDO.
DEF VAR aux_flgexclu    AS      LOGICAL                             NO-UNDO.
DEF VAR aux_flgcreca    AS      LOGICAL                             NO-UNDO.
DEF VAR aux_tipconfi    AS      INTE                                NO-UNDO.
DEF VAR aux_msgconfi    AS      CHAR                                NO-UNDO.
DEF VAR aux_nmdcampo    AS      CHAR                                NO-UNDO.
DEF VAR aux_nrtextab    AS      INTE                                NO-UNDO.
DEF VAR aux_nmarqlog    AS      CHAR                                NO-UNDO.
DEF VAR aux_nmarqimp    AS      CHAR      FORMAT "x(50)"            NO-UNDO.
DEF VAR aux_nrregist    AS      INT                                 NO-UNDO.
DEF VAR aux_dsdlinha    AS      CHAR                                NO-UNDO.
DEF VAR aux_nmarquiv    AS      CHARACTER                           NO-UNDO.

glb_cdcooper = 1.
glb_cdoperad = "1".

RUN fontes/iniprg.p.

ASSIGN aux_nmarqlog = "log/prcitg_" + STRING(YEAR(glb_dtmvtolt),"9999") + 
                      STRING(MONTH(glb_dtmvtolt),"99") + 
                      STRING(DAY(glb_dtmvtolt),"99") + ".log".



/* Verifica o bloqueio do arquivo */
FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                   craptab.nmsistem = "CRED"         AND
                   craptab.tptabela = "GENERI"       AND
                   craptab.cdempres = 0              AND
                   craptab.cdacesso = "NRARQMVITG"   AND
                   craptab.tpregist = 409            NO-LOCK NO-ERROR.

IF   NOT AVAIL craptab   THEN
     DO:
         glb_cdcritic = 393.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> " + aux_nmarqlog).

         RUN fontes/fimprg.p.                   
         RETURN.
     END.    

ASSIGN aux_nrtextab = INTEGER(SUBSTRING(craptab.dstextab,1,5))
       aux_nmarqimp = "coo409" +
                      STRING(DAY(glb_dtmvtolt),"99") +
                      STRING(MONTH(glb_dtmvtolt),"99") +
                      STRING(aux_nrtextab,"99999") + ".rem"
       aux_nrregist = 0.


IF  NOT VALID-HANDLE(h-b1wgen0074) THEN
    RUN sistema/generico/procedures/b1wgen0074.p 
        PERSISTENT SET h-b1wgen0074.


ASSIGN aux_nmarquiv = "/usr/coop/sistema/equipe/irlan/altovale/cartao/contascoo409.txt".
OUTPUT STREAM str_1 TO VALUE(aux_nmarquiv).

FOR EACH crapass WHERE  crapass.cdcooper = glb_cdcooper   AND
                       (crapass.cdagenci = 7   OR
                        crapass.cdagenci = 33  OR
                        crapass.cdagenci = 38  OR
                        crapass.cdagenci = 60  OR
                        crapass.cdagenci = 62  OR
                        crapass.cdagenci = 66) AND
                        crapass.flgctitg = 3   AND
                        crapass.nrdctitg <> "" NO-LOCK
                        BY crapass.cdagenci
                        BY crapass.nrdconta
                        BY crapass.nmprimtl:


    ASSIGN glb_nmrotina = "CONTA CORRENTE"
           glb_cddopcao = "S".
    
    RUN Busca_Dados(INPUT crapass.nrdconta,
                    INPUT 1).

    IF  RETURN-VALUE <> "OK" THEN
        NEXT.
    
    ASSIGN aux_flgsuces = FALSE
           aux_flgexclu = FALSE.  
    
    FIND FIRST tt-conta-corr NO-LOCK NO-ERROR.

    RUN Valida_Dados(INPUT crapass.nrdconta,
                     INPUT 1,
                     INPUT "S",
                     INPUT crapass.cdtipcta,
                     INPUT tt-conta-corr.cdbcochq,
                     INPUT crapass.tpextcta,
                     INPUT crapass.cdagenci,
                     INPUT crapass.cdsitdct,
                     INPUT crapass.cdsecext,
                     INPUT crapass.tpavsdeb,
                     INPUT tt-conta-corr.inadimpl,
                     INPUT tt-conta-corr.inlbacen,
                     INPUT crapass.dtdsdspc,
                     INPUT aux_flgexclu).
    
    IF  RETURN-VALUE <> "OK" THEN
        NEXT.
    
    HIDE MESSAGE NO-PAUSE.
    
    ASSIGN aux_flgsuces = FALSE.
     
    RUN Grava_Dados ( INPUT "S",
                      INPUT crapass.inpessoa,
                      INPUT crapass.nrdconta,
                      INPUT 1,
                      INPUT crapass.cdtipcta,
                      INPUT crapass.cdsitdct,
                      INPUT crapass.cdsecext,
                      INPUT crapass.tpextcta, 
                      INPUT crapass.cdagenci,
                      INPUT tt-conta-corr.cdbcochq,
                      INPUT crapass.flgiddep,
                      INPUT crapass.tpavsdeb,
                      INPUT crapass.dtcnsscr,
                      INPUT crapass.dtcnsspc,
                      INPUT crapass.dtdsdspc,
                      INPUT tt-conta-corr.inadimpl,
                      INPUT tt-conta-corr.inlbacen).

    IF  RETURN-VALUE <> "OK" THEN
        NEXT.
    ELSE
        ASSIGN aux_flgsuces = YES.


END.

OUTPUT STREAM str_1 CLOSE.

RUN /usr/coop/sistema/equipe/irlan/altovale/cartao/crps503_baca.p.

IF  VALID-HANDLE(h-b1wgen0074) THEN
     DELETE OBJECT h-b1wgen0074.

/* ********************************* PROCEDURES ************************ */
PROCEDURE Valida_Dados:

    DEF INPUT PARAM par_nrdconta    LIKE    crapass.nrdconta            NO-UNDO.
    DEF INPUT PARAM par_idseqttl    AS      INTE                        NO-UNDO.
    DEF INPUT PARAM par_tpevento    AS      CHAR                        NO-UNDO.
    DEF INPUT PARAM par_cdtipcta    LIKE    crapass.cdtipcta            NO-UNDO.
    DEF INPUT PARAM par_cdbcochq    AS      INTE    FORMAT "999"        NO-UNDO.
    DEF INPUT PARAM par_tpextcta    LIKE    crapass.tpextcta            NO-UNDO.
    DEF INPUT PARAM par_cdagepac    LIKE    crapass.cdagenci            NO-UNDO.
    DEF INPUT PARAM par_cdsitdct    LIKE    crapass.cdsitdct            NO-UNDO.
    DEF INPUT PARAM par_cdsecext    LIKE    crapass.cdsecext            NO-UNDO.
    DEF INPUT PARAM par_tpavsdeb    LIKE    crapass.tpavsdeb            NO-UNDO.
    DEF INPUT PARAM par_inadimpl    AS      INTEGER                     NO-UNDO.
    DEF INPUT PARAM par_inlbacen    AS      INTEGER                     NO-UNDO.
    DEF INPUT PARAM par_dtdsdspc    LIKE    crapass.dtdsdspc            NO-UNDO.
    DEF INPUT PARAM par_flgexclu    AS      LOG                         NO-UNDO.


    RUN Valida_Dados IN h-b1wgen0074
        ( INPUT glb_cdcooper, 
          INPUT 0,            
          INPUT 0,            
          INPUT glb_cdoperad, 
          INPUT glb_nmdatela, 
          INPUT 1,            
          INPUT par_nrdconta, 
          INPUT par_idseqttl, 
          INPUT TRUE,
          INPUT glb_dtmvtolt,
          INPUT par_tpevento,
          INPUT par_cdtipcta,
          INPUT par_cdbcochq,
          INPUT par_tpextcta,
          INPUT par_cdagepac,
          INPUT par_cdsitdct,
          INPUT par_cdsecext, 
          INPUT par_tpavsdeb,
          INPUT par_inadimpl,
          INPUT par_inlbacen,
          INPUT par_dtdsdspc,
          INPUT par_flgexclu,
         OUTPUT aux_flgcreca,
         OUTPUT aux_tipconfi,
         OUTPUT aux_msgconfi,
         OUTPUT aux_nmdcampo,
         OUTPUT TABLE tt-erro ) NO-ERROR.

    IF  ERROR-STATUS:ERROR THEN
        DO:
           RETURN "NOK".
        END.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.
                  
           RETURN "NOK".
        END.

    RETURN "OK".
END.

PROCEDURE Busca_Dados:

    DEF INPUT PARAM par_nrdconta    LIKE    crapass.nrdconta           NO-UNDO.
    DEF INPUT PARAM par_idseqttl    AS      INTE                       NO-UNDO.

    RUN Busca_Dados IN h-b1wgen0074
        ( INPUT glb_cdcooper, 
          INPUT 0,            
          INPUT 0,            
          INPUT glb_cdoperad, 
          INPUT glb_nmdatela, 
          INPUT 1,            
          INPUT par_nrdconta, 
          INPUT glb_dtmvtolt,
          INPUT par_idseqttl, 
          INPUT YES,
          INPUT glb_cddopcao,
         OUTPUT TABLE tt-conta-corr,
         OUTPUT TABLE tt-erro ) NO-ERROR.

    IF  ERROR-STATUS:ERROR THEN
        DO:
           RETURN "NOK".
        END.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           RETURN "NOK".
        END.

    RETURN "OK".
END.          

PROCEDURE Grava_Dados:

    DEF INPUT PARAM par_tpevento    AS   CHAR                       NO-UNDO.
    DEF INPUT PARAM par_inpessoa    LIKE crapass.inpessoa           NO-UNDO.
    DEF INPUT PARAM par_nrdconta    LIKE crapass.nrdconta           NO-UNDO.
    DEF INPUT PARAM par_idseqttl    AS   INTE                       NO-UNDO.
    DEF INPUT PARAM par_cdtipcta    LIKE crapass.cdtipcta           NO-UNDO.
    DEF INPUT PARAM par_cdsitdct    LIKE crapass.cdsitdct           NO-UNDO.
    DEF INPUT PARAM par_cdsecext    LIKE crapass.cdsecext           NO-UNDO.
    DEF INPUT PARAM par_tpextcta    LIKE crapass.tpextcta           NO-UNDO.
    DEF INPUT PARAM par_cdagenci    LIKE crapass.cdagenci           NO-UNDO.
    DEF INPUT PARAM par_cdbcochq    LIKE crapass.cdbcochq           NO-UNDO.
    DEF INPUT PARAM par_flgiddep    LIKE crapass.flgiddep           NO-UNDO.
    DEF INPUT PARAM par_tpavsdeb    LIKE crapass.tpavsdeb           NO-UNDO.
    DEF INPUT PARAM par_dtcnsscr    LIKE crapass.dtcnsscr           NO-UNDO.
    DEF INPUT PARAM par_dtcnsspc    LIKE crapass.dtcnsspc           NO-UNDO.
    DEF INPUT PARAM par_dtdsdspc    LIKE crapass.dtdsdspc           NO-UNDO.
    DEF INPUT PARAM par_inadimpl    AS   INTEGER                    NO-UNDO.
    DEF INPUT PARAM par_inlbacen    AS   INTEGER                    NO-UNDO.

    DEF VARIABLE    aux_flgderro    AS   LOGICAL                    NO-UNDO.

    /* retornou 1 ou 2 da validacao de dados */
    CASE aux_tipconfi:
        WHEN 2 THEN DO:
            ASSIGN aux_flgderro = NO.
            
            /* impressao das criticas */
            IF  par_inpessoa = 1  THEN
                RUN fontes/critica_cadastro_fisica.p (INPUT par_nrdconta,
                                                     OUTPUT aux_flgderro).
            ELSE
                RUN fontes/critica_cadastro_juridica.p (INPUT par_nrdconta,
                                                       OUTPUT aux_flgderro).

            /* se encontrou erro deve abortar a operacao */
            IF  aux_flgderro THEN
                RETURN "NOK".
        END.
    END CASE.

    RUN Grava_Dados IN h-b1wgen0074
        ( INPUT glb_cdcooper, 
          INPUT 0,            
          INPUT 0,            
          INPUT glb_cdoperad, 
          INPUT glb_nmdatela, 
          INPUT 1,            
          INPUT par_nrdconta, 
          INPUT par_idseqttl, 
          INPUT YES,
          INPUT ?,
          INPUT glb_dtmvtolt,
          INPUT glb_cddopcao,
          INPUT par_tpevento,
          INPUT aux_flgcreca,
          INPUT par_cdtipcta,
          INPUT par_cdsitdct,
          INPUT par_cdsecext,
          INPUT par_tpextcta,
          INPUT par_cdagenci,
          INPUT par_cdbcochq,
          INPUT par_flgiddep,
          INPUT par_tpavsdeb,
          INPUT par_dtcnsscr,
          INPUT par_dtcnsspc,
          INPUT par_dtdsdspc,
          INPUT par_inadimpl,
          INPUT par_inlbacen,
          INPUT aux_flgexclu,
         OUTPUT aux_tpatlcad,
         OUTPUT aux_msgatcad,
         OUTPUT aux_chavealt,
         OUTPUT TABLE tt-erro ) NO-ERROR.

    PUT STREAM str_1 crapass.nrdconta SKIP.

    IF  ERROR-STATUS:ERROR THEN
        DO:
           RETURN "NOK".
        END.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           RETURN "NOK".
        END.

    /* verificar se é necessario registrar o crapalt */
    RUN proc_altcad (INPUT "b1wgen0074.p").

    RETURN "OK".
END.

/**************************************************************************/
