/*...............................................................................

Alterações: 04/05/2009 - Utilizar cdcooper = 0 nas consultas (David).
            22/12/2009 - Criada consistencia para a existencia da tabela 
                         crapedp (Elton).
						 
			05/06/2012 - Adaptação dos fontes para projeto Oracle. Alterado
						 busca na gnapses de CONTAINS para MATCHES (Guilherme Maba).
...............................................................................*/

&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
/* Connected Databases 
          banco            PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD aux_cdcooper AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_cdevento AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dtanoage AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_flgselec AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_flgtermo AS LOGICAL FORMAT "yes/no":U 
       FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lscpfcgc AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lspropos AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nmpagina AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_vlrselec AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_vlrselec_termo AS CHARACTER FORMAT "X(256)":U 
       FIELD nmevento AS CHARACTER FORMAT "X(256)":U 
       FIELD nmrescop AS CHARACTER FORMAT "X(256)":U
       FIELD aux_qtmaxtur AS CHARACTER FORMAT "X(256)":U.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w-html 
/*------------------------------------------------------------------------

  File: 

  Description: 

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: 

  Created: 

------------------------------------------------------------------------*/
/*           This .W file was created with AppBuilder.                  */
/*----------------------------------------------------------------------*/

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Preprocessor Definitions ---                                         */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
DEFINE VARIABLE ProgramaEmUso         AS CHARACTER INITIAL ["wpgd0018"].
DEFINE VARIABLE NmeDoPrograma         AS CHARACTER INITIAL ["wpgd0018b.w"].

DEFINE VARIABLE opcao                 AS CHARACTER.
DEFINE VARIABLE msg-erro              AS CHARACTER.
DEFINE VARIABLE msg-erro-aux          AS INTEGER.
DEFINE VARIABLE aux_nrdrowid-auxiliar AS CHARACTER.
DEFINE VARIABLE pesquisa              AS CHARACTER.     
DEFINE VARIABLE FlagPermissoes        AS CHARACTER.
DEFINE VARIABLE IdentificacaoDaSessao AS CHARACTER FORMAT "x(47)".
DEFINE VARIABLE vauxsenha             AS CHARACTER FORMAT "X(16)".

DEFINE VARIABLE i                     AS INTEGER                        NO-UNDO.
DEFINE VARIABLE m-erros               AS CHARACTER                      NO-UNDO.
DEFINE VARIABLE v-qtdeerro            AS INTEGER                        NO-UNDO.
DEFINE VARIABLE v-descricaoerro       AS CHARACTER                      NO-UNDO.
DEFINE VARIABLE v-identificacao       AS CHARACTER                      NO-UNDO.

/*** Declaração de BOs ***/
DEFINE VARIABLE h-b1wpgd0018          AS HANDLE                         NO-UNDO.

/*** Temp Tables ***/
DEFINE TEMP-TABLE cratcdp NO-UNDO     LIKE crapcdp.

DEFINE VARIABLE vetorevento           AS CHAR                           NO-UNDO.
DEFINE VARIABLE vetortermo            AS CHAR                           NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE fontes/wpgd0018b.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS crapcdp.dtanoage 
&Scoped-define ENABLED-TABLES ab_unmap crapcdp
&Scoped-define FIRST-ENABLED-TABLE ab_unmap
&Scoped-define SECOND-ENABLED-TABLE crapcdp
&Scoped-Define ENABLED-OBJECTS ab_unmap.aux_flgtermo ~
ab_unmap.aux_vlrselec_termo ab_unmap.aux_nmpagina ab_unmap.aux_lspropos ~
ab_unmap.aux_lscpfcgc ab_unmap.aux_flgselec ab_unmap.nmevento ~
ab_unmap.nmrescop ab_unmap.aux_vlrselec ab_unmap.aux_cdcooper ~
ab_unmap.aux_cddopcao ab_unmap.aux_cdevento ab_unmap.aux_dsendurl ~
ab_unmap.aux_dsretorn ab_unmap.aux_dtanoage ab_unmap.aux_idevento ~
ab_unmap.aux_lspermis ab_unmap.aux_nrdrowid ab_unmap.aux_stdopcao ~
ab_unmap.aux_qtmaxtur
&Scoped-Define DISPLAYED-FIELDS crapcdp.dtanoage 
&Scoped-define DISPLAYED-TABLES ab_unmap crapcdp
&Scoped-define FIRST-DISPLAYED-TABLE ab_unmap
&Scoped-define SECOND-DISPLAYED-TABLE crapcdp
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.aux_flgtermo ~
ab_unmap.aux_vlrselec_termo ab_unmap.aux_nmpagina ab_unmap.aux_lspropos ~
ab_unmap.aux_lscpfcgc ab_unmap.aux_flgselec ab_unmap.nmevento ~
ab_unmap.nmrescop ab_unmap.aux_vlrselec ab_unmap.aux_cdcooper ~
ab_unmap.aux_cddopcao ab_unmap.aux_cdevento ab_unmap.aux_dsendurl ~
ab_unmap.aux_dsretorn ab_unmap.aux_dtanoage ab_unmap.aux_idevento ~
ab_unmap.aux_lspermis ab_unmap.aux_nrdrowid ab_unmap.aux_stdopcao ~
ab_unmap.aux_qtmaxtur

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     ab_unmap.aux_flgtermo AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "yes/no":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_vlrselec_termo AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nmpagina AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_lspropos AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_lscpfcgc AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_flgselec AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.nmevento AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.nmrescop AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_vlrselec AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cdcooper AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cddopcao AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cdevento AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_dsendurl AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_dsretorn AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_dtanoage AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_idevento AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_lspermis AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nrdrowid AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_stdopcao AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapcdp.dtanoage AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_qtmaxtur AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 50.2 BY 25.67.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Web-Object
   Allow: Query
   Frames: 1
   Add Fields to: Neither
   Editing: Special-Events-Only
   Events: web.output,web.input
   Other Settings: COMPILE
   Temp-Tables and Buffers:
      TABLE: ab_unmap W "?" ?  
      ADDITIONAL-FIELDS:
          FIELD aux_cdcooper AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_cdevento AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dtanoage AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_flgselec AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_flgtermo AS LOGICAL FORMAT "yes/no":U 
          FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lscpfcgc AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lspropos AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nmpagina AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_vlrselec AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_vlrselec_termo AS CHARACTER FORMAT "X(256)":U 
          FIELD nmevento AS CHARACTER FORMAT "X(256)":U 
          FIELD nmrescop AS CHARACTER FORMAT "X(256)":U 
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW w-html ASSIGN
         HEIGHT             = 25.67
         WIDTH              = 50.2.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB w-html 
/* *********************** Included-Libraries ************************* */

{src/web2/html-map.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w-html
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME Web-Frame
   UNDERLINE                                                            */
/* SETTINGS FOR FILL-IN ab_unmap.aux_cdcooper IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_cddopcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_cdevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dsendurl IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dsretorn IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dtanoage IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_flgselec IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_flgtermo IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_idevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lscpfcgc IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lspermis IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lspropos IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nmpagina IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nrdrowid IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_stdopcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_vlrselec IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_vlrselec_termo IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN crapcdp.dtanoage IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN ab_unmap.nmevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.nmrescop IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w-html 


/* ************************  Main Code Block  ************************* */

/* Standard Main Block that runs adm-create-objects, initializeObject 
 * and process-web-request.
 * The bulk of the web processing is in the Procedure process-web-request
 * elsewhere in this Web object.
 */
{src/web2/template/hmapmain.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaPAC w-html 
PROCEDURE CriaListaPAC :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE aux_vlrcusto AS DEC  NO-UNDO.
    DEFINE VARIABLE aux_vlrtotal AS DEC  NO-UNDO.
    DEFINE VARIABLE aux_nrcpfcgc AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_nrpropos AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_nmfornec AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_flgfecha AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_envfecha AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_nmresage AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_cdageagr AS INT  NO-UNDO.

    DEFINE BUFFER bf-crapcdp FOR crapcdp.
    DEFINE BUFFER bf-crapagp FOR crapagp.
    DEFINE BUFFER bf-crapage FOR crapage.

    /* Primeiro, monta a informação para o registro com PAC = 0 (modelo) */
    FOR EACH crapcdp WHERE string(crapcdp.cdevento) = ab_unmap.aux_cdevento AND 
                           crapcdp.idevento = INT(ab_unmap.aux_idevento)    AND
                           crapcdp.cdagenci = 0                             AND
                           crapcdp.tpcuseve = 1 /* custos diretos */        AND
                           crapcdp.cdcooper = INT(ab_unmap.aux_cdcooper)    AND
                           crapcdp.dtanoage = INT(ab_unmap.aux_dtanoage)
                           BREAK BY crapcdp.cdcooper
                                    BY crapcdp.cdevento
                                       BY crapcdp.cdcuseve:

        aux_vlrcusto = crapcdp.vlcuseve.
        aux_flgfecha = IF crapcdp.flgfecha THEN "checked" ELSE "".
        aux_envfecha = IF crapcdp.flgfecha THEN "disabled" ELSE "".

        FIND FIRST gnapfdp WHERE gnapfdp.cdcooper = 0                AND
                                 gnapfdp.nrcpfcgc = crapcdp.nrcpfcgc NO-LOCK NO-ERROR.
        IF AVAIL gnapfdp THEN
            aux_nmfornec = gnapfdp.nmfornec.
        ELSE
            aux_nmfornec = "".

        /* Para cada evento que foi selecionado */
          IF FIRST-OF(crapcdp.cdevento) THEN
          DO:
              aux_vlrtotal = 0.
              IF  vetorevento = "" THEN
                  vetorevento = "~{" + 
                     "cdagenci:" + "'0" + "'"
                  + ",nmresage:" + "'" + "'".
              ELSE
                  vetorevento = vetorevento + "," + "~{" + 
                     "cdagenci:" + "'" + "'"
                  + ",nmresage:" + "'" + "'".
          END.

          aux_vlrtotal = aux_vlrtotal + crapcdp.vlcuseve.
          
          CASE crapcdp.cdcuseve:
              WHEN 1 THEN /* Honorários */
              DO:
                  aux_nrcpfcgc = IF crapcdp.nrcpfcgc <> ? THEN STRING(crapcdp.nrcpfcgc) ELSE "".
                  aux_nrpropos = IF crapcdp.nrpropos <> ? THEN STRING(crapcdp.nrpropos) ELSE "".
                  vetorevento = vetorevento + ",vlhonora:" + "'" + string(aux_vlrcusto,">>,>>9.99") + "'"
                      + ",nrcpfcgc:'" + aux_nrcpfcgc + "'"
                      + ",nrpropos:'" + aux_nrpropos + "'"
                      + ",nmfornec:'" + aux_nmfornec + "'"
                      + ",flgfecha:'" + aux_flgfecha + "'"
                      + ",envfecha:'" + aux_envfecha + "'".
              END.
    
              WHEN 2 THEN /* Local */
              DO:
                  vetorevento = vetorevento + ",vlrlocal:" + "'" + string(aux_vlrcusto,">>,>>9.99") + "'".
              END.
    
              WHEN 3 THEN /* Alimentação */
              DO:
                  vetorevento = vetorevento + ",vlalimen:" + "'" + string(aux_vlrcusto,">>,>>9.99") + "'".
              END.
    
              WHEN 4 THEN /* Material */
              DO:
                  vetorevento = vetorevento + ",vlmateri:" + "'" + string(aux_vlrcusto,">>,>>9.99") + "'".
              END.
    
              WHEN 5 THEN /* Transportes */
              DO:
                  vetorevento = vetorevento + ",vltransp:" + "'" + string(aux_vlrcusto,">>,>>9.99") + "'".
              END.
    
              WHEN 6 THEN /* Brindes */
              DO:
                  vetorevento = vetorevento + ",vlbrinde:" + "'" + string(aux_vlrcusto,">>,>>9.99") + "'".
              END.
    
              WHEN 7 THEN /* Divulgação */
              DO:
                  vetorevento = vetorevento + ",vldivulg:" + "'" + string(aux_vlrcusto,">>,>>9.99") + "'".
              END.
    
              WHEN 8 THEN /* Outros */
              DO:
                  vetorevento = vetorevento + ",vloutros:" + "'" + string(aux_vlrcusto,">>,>>9.99") + 
                                             "',vlrtotal:" + "'" + STRING(aux_vlrtotal,">>,>>9.99") + "'~}".
              END.
    
          END CASE. /* CASE crapcdp.cdcuseve */
    END. /* FOR EACH crapcdp */

    /* Verifica o PAC agrupador do PAC do usuario */
    FIND crapagp WHERE crapagp.idevento = INT(ab_unmap.aux_idevento)   AND
                       crapagp.cdcooper = INT(ab_unmap.aux_cdcooper)   AND
                       crapagp.dtanoage = INT(ab_unmap.aux_dtanoage)   AND
                       crapagp.cdagenci = gnapses.cdagenci
                       NO-LOCK NO-ERROR.

    IF   AVAILABLE crapagp   THEN
         aux_cdageagr = crapagp.cdageagr.
    ELSE
         aux_cdageagr = gnapses.cdagenci.    

    /* Segundo, monta as informações relativas a cada PAC */
    ASSIGN aux_nrpropos = "".

    FOR EACH crapage WHERE crapage.cdcooper = INT(ab_unmap.aux_cdcooper)    AND
                           crapage.insitage = 1                             NO-LOCK
                           BY crapage.nmresage:

        /* Controle de visualização por PAC */
        IF  (gnapses.nvoperad = 1    OR
             gnapses.nvoperad = 2)                  AND
             gnapses.cdagenci <> crapage.cdagenci   AND
             crapage.cdagenci <> aux_cdageagr       THEN
             NEXT.

        /* Para Progrid, os PACs são agrupados */
        FIND crapagp WHERE crapagp.idevento = INT(ab_unmap.aux_idevento)  AND
                           crapagp.cdcooper = INT(ab_unmap.aux_cdcooper)  AND
                           crapagp.dtanoage = INT(ab_unmap.aux_dtanoage)  AND
                           crapagp.cdagenci = crapage.cdagenci
                           NO-LOCK NO-ERROR.

        IF   INT(ab_unmap.aux_idevento) = 1   THEN
             DO:
                 IF   NOT AVAIL crapagp   THEN
                      NEXT.  

                 IF   crapagp.cdagenci <> crapagp.cdageagr   THEN
                      NEXT.
             END.
        
        aux_nmresage = crapage.nmresage.

        /* Pega os PACS agrupados */
        IF   INT(ab_unmap.aux_idevento) = 1   THEN
             FOR EACH bf-crapagp  WHERE bf-crapagp.idevento  = crapagp.idevento      AND
                                        bf-crapagp.cdcooper  = crapagp.cdcooper      AND
                                        bf-crapagp.dtanoage  = crapagp.dtanoage      AND
                                        bf-crapagp.cdageagr  = crapagp.cdagenci      AND
                                        bf-crapagp.cdagenci <> crapagp.cdagenci      NO-LOCK,
                 FIRST bf-crapage WHERE bf-crapage.cdagenci  = bf-crapagp.cdagenci   NO-LOCK 
                                        BY bf-crapage.nmresage:
           
                 ASSIGN aux_nmresage = aux_nmresage + " / " + bf-crapage.nmresage.
            END.
 

        FOR EACH crapcdp WHERE crapcdp.cdevento = INT(ab_unmap.aux_cdevento)    AND
                               crapcdp.idevento = INT(ab_unmap.aux_idevento)    AND
                               crapcdp.dtanoage = INT(ab_unmap.aux_dtanoage)    AND
                               crapcdp.tpcuseve = 1 /* custos diretos */        AND
                               crapcdp.cdagenci = 0                             AND
                               crapcdp.cdcooper = INT(ab_unmap.aux_cdcooper)    NO-LOCK
                               BREAK BY crapcdp.cdcooper
                                        BY crapcdp.cdevento
                                           BY crapcdp.cdcuseve:
          /* Verifica se já foi lançado custo para esse PAC */
          FIND FIRST bf-crapcdp WHERE bf-crapcdp.cdevento = crapcdp.cdevento            AND
                                      bf-crapcdp.cdcuseve = crapcdp.cdcuseve            AND
                                      bf-crapcdp.idevento = INT(ab_unmap.aux_idevento)  AND
                                      bf-crapcdp.dtanoage = INT(ab_unmap.aux_dtanoage)  AND
                                      bf-crapcdp.cdcooper = INT(ab_unmap.aux_cdcooper)  AND
                                      bf-crapcdp.tpcuseve = 1 /* custos diretos */      AND
                                      bf-crapcdp.cdagenci = crapage.cdagenci            NO-LOCK NO-ERROR.

          /* Se tem custo lançado, pega de lá. Se não tem, atribui 0 */
          IF AVAIL bf-crapcdp THEN  
          DO:

              /* Verifica se a agenda já foi enviada ao PAC */
              IF   INT(ab_unmap.aux_idevento) = 1   THEN
                   DO:
                       IF   crapagp.idstagen <> 0   THEN 
                            aux_envfecha = "disabled". 
                       ELSE 
                            aux_envfecha = "".
                   END.

              FIND FIRST gnapfdp WHERE gnapfdp.cdcooper = 0                   AND
                                       gnapfdp.nrcpfcgc = bf-crapcdp.nrcpfcgc NO-LOCK NO-ERROR.

              IF AVAIL gnapfdp THEN
                  aux_nmfornec = gnapfdp.nmfornec.
              ELSE
                  aux_nmfornec = "".

              IF ab_unmap.aux_idevento = "2" THEN DO:
              
                  ASSIGN aux_envfecha = IF bf-crapcdp.flgfecha THEN "disabled" ELSE "".
              END.
              ASSIGN aux_vlrcusto = bf-crapcdp.vlcuseve
                     aux_flgfecha = IF bf-crapcdp.flgfecha THEN "checked" ELSE ""
                     aux_envfecha = IF bf-crapcdp.flgfecha THEN "disabled" ELSE "".

              aux_nrcpfcgc = IF bf-crapcdp.nrcpfcgc <> ? THEN STRING(bf-crapcdp.nrcpfcgc) ELSE "".
              aux_nrpropos = IF bf-crapcdp.nrpropos <> ? THEN STRING(bf-crapcdp.nrpropos) ELSE "".
          END.
          ELSE
              ASSIGN
                  aux_vlrcusto = 0
                  aux_flgfecha = ""
                  aux_envfecha = "".

          IF FIRST-OF(crapcdp.cdevento) THEN
          DO:
              ASSIGN aux_vlrtotal = 0.
              IF  vetorevento = "" THEN
                  vetorevento = "~{" + 
                     "cdagenci:" + "'" + string(crapage.cdagenci) + "'"
                  + ",nmresage:" + "'" + REPLACE(STRING(aux_nmresage),"'","`") + "'".
              ELSE
                  vetorevento = vetorevento + "," + "~{" + 
                     "cdagenci:" + "'" + string(crapage.cdagenci) + "'"
                  + ",nmresage:" + "'" + REPLACE(STRING(aux_nmresage),"'","`") + "'".
          END.

          ASSIGN aux_vlrtotal = aux_vlrtotal + aux_vlrcusto.
          
          CASE crapcdp.cdcuseve:
              WHEN 1 THEN /* Honorários */
              DO:
                  vetorevento = vetorevento + ",vlhonora:" + "'" + string(aux_vlrcusto,">>,>>9.99") + "'"
                      + ",nrcpfcgc:'" + aux_nrcpfcgc + "'"
                      + ",nrpropos:'" + aux_nrpropos + "'"
                      + ",nmfornec:'" + aux_nmfornec + "'"
                      + ",flgfecha:'" + aux_flgfecha + "'"
                      + ",envfecha:'" + aux_envfecha + "'".
              END.
    
              WHEN 2 THEN /* Local */
              DO:
                  vetorevento = vetorevento + ",vlrlocal:" + "'" + string(aux_vlrcusto,">>,>>9.99") + "'".
              END.
    
              WHEN 3 THEN /* Alimentação */
              DO:
                  vetorevento = vetorevento + ",vlalimen:" + "'" + string(aux_vlrcusto,">>,>>9.99") + "'".
              END.
    
              WHEN 4 THEN /* Material */
              DO:
                  vetorevento = vetorevento + ",vlmateri:" + "'" + string(aux_vlrcusto,">>,>>9.99") + "'".
              END.
    
              WHEN 5 THEN /* Transportes */
              DO:
                  vetorevento = vetorevento + ",vltransp:" + "'" + string(aux_vlrcusto,">>,>>9.99") + "'".
              END.
    
              WHEN 6 THEN /* Brindes */
              DO:
                  vetorevento = vetorevento + ",vlbrinde:" + "'" + string(aux_vlrcusto,">>,>>9.99") + "'".
              END.
    
              WHEN 7 THEN /* Divulgação */
              DO:
                  vetorevento = vetorevento + ",vldivulg:" + "'" + string(aux_vlrcusto,">>,>>9.99") + "'".
              END.
    
              WHEN 8 THEN /* Outros */
              DO:
                  vetorevento = vetorevento + ",vloutros:" + "'" + string(aux_vlrcusto,">>,>>9.99") + 
                                             "',vlrtotal:" + "'" + string(aux_vlrtotal,">>,>>9.99") + "'~}".
              END.
    
          END CASE. /* CASE crapcdp.cdcuseve */

      END. /* FOR EACH crapcdp */

   END. /* FOR EACH crapage */
   RUN RodaJavaScript("var mevento=new Array();mevento=["  + vetorevento + "]").

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaTermo w-html 
PROCEDURE CriaListaTermo :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE aux_nmresage AS CHAR                   NO-UNDO.
    DEFINE VARIABLE aux_vlcuseve LIKE crapcdp.vlcuseve     NO-UNDO.
    DEFINE VARIABLE aux_prdescon LIKE crapcdp.prdescon     NO-UNDO.
    DEFINE VARIABLE aux_cdageagr AS INT                    NO-UNDO.

    DEFINE BUFFER bf-crapcdp FOR crapcdp.
    DEFINE BUFFER bf-crapagp FOR crapagp.
    DEFINE BUFFER bf-crapage FOR crapage.

    /* Primeiro, monta a informação para o registro com PAC = 0 (modelo) */
    FOR EACH crapcdp WHERE string(crapcdp.cdevento) = ab_unmap.aux_cdevento AND 
                           crapcdp.idevento = INT(ab_unmap.aux_idevento)    AND
                           crapcdp.cdagenci = 0                             AND
                           crapcdp.tpcuseve = 4                             AND
                           crapcdp.cdcuseve = 1                             AND
                           crapcdp.cdcooper = INT(ab_unmap.aux_cdcooper)    AND
                           crapcdp.dtanoage = INT(ab_unmap.aux_dtanoage)
                           BREAK BY crapcdp.cdcooper
                                    BY crapcdp.cdevento
                                       BY crapcdp.cdcuseve:

        /* Para cada evento que foi selecionado */
        IF FIRST-OF(crapcdp.cdevento) THEN
          DO:
              IF  vetortermo = "" THEN
                  vetortermo = "~{" + 
                               "cdagenci:'0'," +
                               "nmresage:'',"  +
                               "vlcuseve:'" + TRIM(STRING(crapcdp.vlcuseve,"zzz,zz9.99")) + "'," +
                               "prdescon:'" + STRING(crapcdp.prdescon) + "'" +
                               "~}". 
              ELSE
                  vetortermo = vetortermo + 
                               ",~{" + 
                               "cdagenci:'0'," +
                               "nmresage:'',"  +
                               "vlcuseve:'" + TRIM(STRING(crapcdp.vlcuseve,"zzz,zz9.99")) + "'," +
                               "prdescon:'" + STRING(crapcdp.prdescon) + "'" +
                               "~}". 
          END.

    END. /* FOR EACH crapcdp */

    /* Verifica o PAC agrupador do PAC do usuario */
    FIND crapagp WHERE crapagp.idevento = INT(ab_unmap.aux_idevento)   AND
                       crapagp.cdcooper = INT(ab_unmap.aux_cdcooper)   AND
                       crapagp.dtanoage = INT(ab_unmap.aux_dtanoage)   AND
                       crapagp.cdagenci = gnapses.cdagenci
                       NO-LOCK NO-ERROR.

    IF   AVAILABLE crapagp   THEN
         aux_cdageagr = crapagp.cdageagr.
    ELSE
         aux_cdageagr = gnapses.cdagenci.    


    /* Segundo, monta as informações relativas a cada PAC */
    FOR EACH crapage WHERE crapage.cdcooper = INT(ab_unmap.aux_cdcooper)    AND
                           crapage.insitage = 1                             NO-LOCK
                           BY crapage.nmresage:

        /* Controle de visualização por PAC */
        IF  (gnapses.nvoperad = 1    OR
             gnapses.nvoperad = 2)                  AND
             gnapses.cdagenci <> crapage.cdagenci   AND
             crapage.cdagenci <> aux_cdageagr       THEN
             NEXT.

        /* Para Progrid, os PACs são agrupados */
        FIND FIRST crapagp WHERE crapagp.idevento = INT(ab_unmap.aux_idevento)  AND
                                 crapagp.cdcooper = INT(ab_unmap.aux_cdcooper)  AND
                                 crapagp.dtanoage = INT(ab_unmap.aux_dtanoage)  AND
                                 crapagp.cdagenci = crapage.cdagenci            NO-LOCK NO-ERROR.

        IF   INT(ab_unmap.aux_idevento) = 1   THEN
             DO:
                 IF   NOT AVAIL crapagp   THEN
                      NEXT.  

                 IF   crapagp.cdagenci <> crapagp.cdageagr   THEN
                      NEXT.
             END.
        
        aux_nmresage = crapage.nmresage.

        /* Pega os PACS agrupados */
        IF   INT(ab_unmap.aux_idevento) = 1   THEN
             FOR EACH bf-crapagp  WHERE bf-crapagp.idevento  = crapagp.idevento      AND
                                        bf-crapagp.cdcooper  = crapagp.cdcooper      AND
                                        bf-crapagp.dtanoage  = crapagp.dtanoage      AND
                                        bf-crapagp.cdageagr  = crapagp.cdagenci      AND
                                        bf-crapagp.cdagenci <> crapagp.cdagenci      NO-LOCK,
                 FIRST bf-crapage WHERE bf-crapage.cdagenci  = bf-crapagp.cdagenci   NO-LOCK 
                                        BY bf-crapage.nmresage:
           
                 ASSIGN aux_nmresage = aux_nmresage + " / " + bf-crapage.nmresage.
            END.

        FIND crapcdp WHERE crapcdp.cdevento = INT(ab_unmap.aux_cdevento)    AND
                           crapcdp.idevento = INT(ab_unmap.aux_idevento)    AND
                           crapcdp.dtanoage = INT(ab_unmap.aux_dtanoage)    AND
                           crapcdp.tpcuseve = 4                             AND
                           crapcdp.cdcuseve = 1                             AND
                           crapcdp.cdagenci = crapage.cdagenci              AND
                           crapcdp.cdcooper = INT(ab_unmap.aux_cdcooper)    NO-LOCK NO-ERROR.

        IF   NOT AVAILABLE crapcdp   THEN
             ASSIGN aux_vlcuseve = 0
                    aux_prdescon = 0.
        ELSE
             ASSIGN aux_vlcuseve = crapcdp.vlcuseve
                    aux_prdescon = crapcdp.prdescon.

        IF  vetortermo = "" THEN
            vetortermo = "~{" + 
                         "cdagenci:'" + STRING(crapage.cdagenci) + "'," +
                         "nmresage:'" + REPLACE(STRING(aux_nmresage),"'","`") + "',"  +
                         "vlcuseve:'" + TRIM(STRING(aux_vlcuseve,"zzz,zz9.99")) + "'," +
                         "prdescon:'" + STRING(aux_prdescon) + "'" +
                         "~}".
        ELSE
            vetortermo = vetortermo + 
                         ",~{" + 
                         "cdagenci:'" + STRING(crapage.cdagenci) + "'," +
                         "nmresage:'" + REPLACE(STRING(aux_nmresage),"'","`") + "',"  +
                         "vlcuseve:'" + TRIM(STRING(aux_vlcuseve,"zzz,zz9.99")) + "'," +
                         "prdescon:'" + STRING(aux_prdescon) + "'" +
                         "~}".

   END. /* FOR EACH crapage */

   RUN RodaJavaScript("var mtermo=new Array();mtermo=["  + vetortermo + "]").

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE htmOffsets w-html  _WEB-HTM-OFFSETS
PROCEDURE htmOffsets :
/*------------------------------------------------------------------------------
  Purpose:     Runs procedure to associate each HTML field with its
               corresponding widget name and handle.
  Parameters:  
  Notes:       
------------------------------------------------------------------------------*/
  RUN readOffsets ("{&WEB-FILE}":U).
  RUN htmAssociate
    ("aux_cdcooper":U,"ab_unmap.aux_cdcooper":U,ab_unmap.aux_cdcooper:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cddopcao":U,"ab_unmap.aux_cddopcao":U,ab_unmap.aux_cddopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdevento":U,"ab_unmap.aux_cdevento":U,ab_unmap.aux_cdevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsendurl":U,"ab_unmap.aux_dsendurl":U,ab_unmap.aux_dsendurl:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsretorn":U,"ab_unmap.aux_dsretorn":U,ab_unmap.aux_dsretorn:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dtanoage":U,"ab_unmap.aux_dtanoage":U,ab_unmap.aux_dtanoage:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_flgselec":U,"ab_unmap.aux_flgselec":U,ab_unmap.aux_flgselec:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_flgtermo":U,"ab_unmap.aux_flgtermo":U,ab_unmap.aux_flgtermo:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idevento":U,"ab_unmap.aux_idevento":U,ab_unmap.aux_idevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lscpfcgc":U,"ab_unmap.aux_lscpfcgc":U,ab_unmap.aux_lscpfcgc:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lspermis":U,"ab_unmap.aux_lspermis":U,ab_unmap.aux_lspermis:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lspropos":U,"ab_unmap.aux_lspropos":U,ab_unmap.aux_lspropos:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nmpagina":U,"ab_unmap.aux_nmpagina":U,ab_unmap.aux_nmpagina:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrdrowid":U,"ab_unmap.aux_nrdrowid":U,ab_unmap.aux_nrdrowid:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_stdopcao":U,"ab_unmap.aux_stdopcao":U,ab_unmap.aux_stdopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_vlrselec":U,"ab_unmap.aux_vlrselec":U,ab_unmap.aux_vlrselec:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_vlrselec_termo":U,"ab_unmap.aux_vlrselec_termo":U,ab_unmap.aux_vlrselec_termo:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dtanoage":U,"crapcdp.dtanoage":U,crapcdp.dtanoage:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nmevento":U,"ab_unmap.nmevento":U,ab_unmap.nmevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nmrescop":U,"ab_unmap.nmrescop":U,ab_unmap.nmrescop:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_qtmaxtur":U,"ab_unmap.aux_qtmaxtur":U,ab_unmap.aux_qtmaxtur:HANDLE IN FRAME {&FRAME-NAME}).
END PROCEDURE.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-assign-record w-html 
PROCEDURE local-assign-record :
DEFINE INPUT PARAMETER opcao AS CHARACTER.
    
    DEF VAR aux_qtevesel AS INT                NO-UNDO.
    DEF VAR aux_tpcuseve AS INT                NO-UNDO.
    DEF VAR aux_msgderro AS CHAR               NO-UNDO.
    DEF VAR aux_indselec AS INT                NO-UNDO.
    
    DEF VAR aux_vlrdecim LIKE crapcdp.vlcuseve NO-UNDO.
    
    /* Instancia a BO para executar as procedures */
    RUN dbo/b1wpgd0018.p PERSISTENT SET h-b1wpgd0018.
    
    /* Se BO foi instanciada */
    IF VALID-HANDLE(h-b1wpgd0018) THEN
       DO:
          DO WITH FRAME {&FRAME-NAME}:
             IF opcao = "inclusao" THEN
                DO: 
                    CREATE cratcdp.
    
                    RUN inclui-registro IN h-b1wpgd0018(INPUT TABLE cratcdp, OUTPUT msg-erro, OUTPUT ab_unmap.aux_nrdrowid).
                END.
             ELSE  /* alteracao */
                DO:

                    IF   ab_unmap.aux_stdopcao = "al"   THEN /* Altera os custos */
                         DO:
                             FIND FIRST craptab WHERE craptab.cdcooper = 0               AND
                                                      craptab.nmsistem = "CRED"          AND
                                                      craptab.tptabela = "CONFIG"        AND
                                                      craptab.cdempres = 0               AND
                                                      craptab.cdacesso = "PGDCUSTEVE"    AND
                                                      craptab.tpregist = 0               NO-LOCK NO-ERROR.
                             
                             aux_indselec = 1.
                             
                             /* Para todos os PACs */
                             DO aux_qtevesel = 1 TO (NUM-ENTRIES(ab_unmap.aux_vlrselec, ";") / 9):
                             
                                 /*RUN RodaJavaScript('alert("tpcuseve: '+ ENTRY(aux_indselec, ab_unmap.aux_vlrselec, ";") + '"); ').*/
                             
                                 /* Para todos os tipos de custo dos eventos */
                                 DO aux_tpcuseve = 1 TO (NUM-ENTRIES(craptab.dstextab) / 2):
                             
                                     FIND FIRST cratcdp NO-ERROR.
                                     IF AVAIL cratcdp THEN
                                         DELETE cratcdp.
                             
                                     aux_vlrdecim = DEC(ENTRY(aux_tpcuseve + aux_indselec, ab_unmap.aux_vlrselec, ";")).
                                     
                                     CREATE cratcdp.
                                     ASSIGN
                                         cratcdp.cdagenci = INT(ENTRY(aux_indselec, ab_unmap.aux_vlrselec, ";"))
                                         cratcdp.cdcooper = INT(ab_unmap.aux_cdcooper)
                                         cratcdp.cdcuseve = INT(ENTRY(aux_tpcuseve * 2, craptab.dstextab))
                                         cratcdp.cdevento = INT(ab_unmap.aux_cdevento)
                                         cratcdp.dtanoage = INT(ab_unmap.aux_dtanoage)
                                         cratcdp.idevento = INT(ab_unmap.aux_idevento)
                                         cratcdp.vlcuseve = aux_vlrdecim
                                         cratcdp.tpcuseve = 1 /* Este programa só lança custos diretos */
                                         cratcdp.flgfecha = IF ENTRY(aux_qtevesel, ab_unmap.aux_flgselec,";") = "true" THEN YES ELSE NO
                                         cratcdp.nrcpfcgc = DEC(ENTRY(aux_qtevesel, ab_unmap.aux_lscpfcgc,";"))
                                         cratcdp.nrpropos = ENTRY(aux_qtevesel, ab_unmap.aux_lspropos,";").
                             
                                    /* IF aux_qtevesel = 1 THEN DO:
                                         RUN RodaJavaScript('alert("Valor Recebido: ' + string(aux_vlrdecim) + '"); ').
                                         RUN RodaJavaScript('alert("Valor Tabela: ' + string(cratcdp.vlcuseve) + '"); ').
                                     END.*/
                             
                                     FIND FIRST crapcdp WHERE crapcdp.idevento = cratcdp.idevento    AND
                                                              crapcdp.cdcooper = cratcdp.cdcooper    AND
                                                              crapcdp.cdagenci = cratcdp.cdagenci    AND
                                                              crapcdp.cdevento = cratcdp.cdevento    AND
                                                              crapcdp.cdcuseve = cratcdp.cdcuseve    AND
                                                              crapcdp.tpcuseve = cratcdp.tpcuseve    AND
                                                              crapcdp.dtanoage = cratcdp.dtanoage    NO-LOCK NO-ERROR.
                             
                                     IF AVAIL crapcdp THEN DO:
                                         RUN altera-registro IN h-b1wpgd0018(INPUT TABLE cratcdp, OUTPUT aux_msgderro).
                                     END.
                                     ELSE
                                     DO:
                                         RUN inclui-registro IN h-b1wpgd0018(INPUT TABLE cratcdp, OUTPUT aux_msgderro, OUTPUT ab_unmap.aux_nrdrowid).
                                     END.
                             
                                     ASSIGN msg-erro = msg-erro + aux_msgderro.
                             
                                 END. /* DO aux_tpcuseve */
                             
                                 aux_indselec = aux_indselec + 9.
                             
                             END. /* DO aux_qtevesel */
                          END.
                    ELSE
                    /* Altera os termos de compromisso */
                          DO:
                             aux_indselec = 1.
                             
                             /* Para todos os PACs */
                             DO aux_qtevesel = 1 TO (NUM-ENTRIES(ab_unmap.aux_vlrselec_termo,";") / 3):

                                EMPTY TEMP-TABLE cratcdp.

                                CREATE cratcdp.
                                ASSIGN cratcdp.cdagenci = INT(ENTRY(aux_indselec, ab_unmap.aux_vlrselec_termo, ";"))
                                       cratcdp.cdcooper = INT(ab_unmap.aux_cdcooper)
                                       cratcdp.cdcuseve = 1
                                       cratcdp.cdevento = INT(ab_unmap.aux_cdevento)
                                       cratcdp.dtanoage = INT(ab_unmap.aux_dtanoage)
                                       cratcdp.idevento = INT(ab_unmap.aux_idevento)
                                       cratcdp.vlcuseve = DEC(ENTRY(aux_indselec + 1, ab_unmap.aux_vlrselec_termo, ";"))
                                       cratcdp.prdescon = INT(ENTRY(aux_indselec + 2, ab_unmap.aux_vlrselec_termo, ";"))
                                       cratcdp.tpcuseve = 4
                                       cratcdp.flgfecha = YES
                                       cratcdp.nrcpfcgc = 0
                                       cratcdp.nrpropos = "0".

                                FIND FIRST crapcdp WHERE crapcdp.idevento = cratcdp.idevento    AND
                                                         crapcdp.cdcooper = cratcdp.cdcooper    AND
                                                         crapcdp.cdagenci = cratcdp.cdagenci    AND
                                                         crapcdp.cdevento = cratcdp.cdevento    AND
                                                         crapcdp.cdcuseve = cratcdp.cdcuseve    AND
                                                         crapcdp.tpcuseve = cratcdp.tpcuseve    AND
                                                         crapcdp.dtanoage = cratcdp.dtanoage    NO-LOCK NO-ERROR.
                             
                                IF AVAIL crapcdp THEN DO:
                                    RUN altera-registro IN h-b1wpgd0018(INPUT TABLE cratcdp, OUTPUT aux_msgderro).
                                END.
                                ELSE
                                DO:
                                    RUN inclui-registro IN h-b1wpgd0018(INPUT TABLE cratcdp, OUTPUT aux_msgderro, OUTPUT ab_unmap.aux_nrdrowid).
                                END.
                             
                                ASSIGN msg-erro = msg-erro + aux_msgderro.
                             
                                aux_indselec = aux_indselec + 3.

                             END. /* DO aux_qtevesel */

                          END.
                END.    
          END. /* DO WITH FRAME {&FRAME-NAME} */
       
          /* "mata" a instância da BO */
          DELETE PROCEDURE h-b1wpgd0018 NO-ERROR.
       
       END. /* IF VALID-HANDLE(h-b1wpgd0018) */
      
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-delete-record w-html 
PROCEDURE local-delete-record :
/* Instancia a BO para executar as procedures */
    RUN dbo/b1wpgd0018.p PERSISTENT SET h-b1wpgd0018.
     
    /* Se BO foi instanciada */
    IF VALID-HANDLE(h-b1wpgd0018) THEN
       DO:
          CREATE cratcdp.
          BUFFER-COPY crapcdp TO cratcdp.
              
          RUN exclui-registro IN h-b1wpgd0018(INPUT TABLE cratcdp, OUTPUT msg-erro).
    
          /* "mata" a instância da BO */
          DELETE PROCEDURE h-b1wpgd0018 NO-ERROR.
       END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-display-fields w-html 
PROCEDURE local-display-fields :
RUN displayFields.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE outputHeader w-html 
PROCEDURE outputHeader :
/*------------------------------------------------------------------------
  Purpose:     Output the MIME header, and any "cookie" information needed 
               by this procedure.  
  Parameters:  <none>
  Notes:       In the event that this Web object is state-aware, this is 
               a good place to set the WebState and WebTimeout attributes.
------------------------------------------------------------------------*/

  output-content-type ("text/html":U).
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PermissaoDeAcesso w-html 
PROCEDURE PermissaoDeAcesso :
{includes/wpgd0009.i}

/*ASSIGN 
    v-identificacao = get-cookie("cookie-usuario-em-uso")
    v-permissoes    = "IAEPLU".
*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PosicionaNoAnterior w-html 
PROCEDURE PosicionaNoAnterior :
/* O pre-processador {&SECOND-ENABLED-TABLE} tem como valor, o nome da tabela usada */

FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.

IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
   DO:
       FIND PREV {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.

       IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
           DO:
               ASSIGN ab_unmap.aux_nrdrowid = STRING(ROWID({&SECOND-ENABLED-TABLE})).

               FIND PREV {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.

               IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                   ASSIGN ab_unmap.aux_stdopcao = "".
               ELSE
                   ASSIGN ab_unmap.aux_stdopcao = "".

               FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
           END.
       ELSE
           DO:
               RUN RodaJavaScript("alert('Este já é o primeiro registro.')"). 
               
               FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.

               IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                   ASSIGN ab_unmap.aux_stdopcao = "".
               ELSE
                   ASSIGN ab_unmap.aux_stdopcao = "?".

           END.
   END.
ELSE 
   RUN PosicionaNoPrimeiro.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PosicionaNoPrimeiro w-html 
PROCEDURE PosicionaNoPrimeiro :
FIND FIRST {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.


IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
    ASSIGN ab_unmap.aux_nrdrowid  = "?"
           ab_unmap.aux_stdopcao = "".
ELSE
    ASSIGN ab_unmap.aux_nrdrowid  = STRING(ROWID({&SECOND-ENABLED-TABLE}))
           ab_unmap.aux_stdopcao = "".  /* aqui p */

/* Não traz inicialmente nenhum registro */ 
RELEASE {&SECOND-ENABLED-TABLE}.

ASSIGN ab_unmap.aux_nrdrowid  = "?"
       ab_unmap.aux_stdopcao = "".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PosicionaNoSeguinte w-html 
PROCEDURE PosicionaNoSeguinte :
FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.


IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
    DO:
       FIND NEXT {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.

       IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
           DO:
               ASSIGN ab_unmap.aux_nrdrowid = STRING(ROWID({&SECOND-ENABLED-TABLE})).

               FIND NEXT {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.

               IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                   ASSIGN ab_unmap.aux_stdopcao = "".
               ELSE
                   ASSIGN ab_unmap.aux_stdopcao = "".

               FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
           END.
       ELSE
           DO:
               RUN RodaJavaScript("alert('Este já é o último registro.')").

               FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.

               IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                   ASSIGN ab_unmap.aux_stdopcao = "".
               ELSE
                   ASSIGN ab_unmap.aux_stdopcao = "?".
           END.
    END.
ELSE
    RUN PosicionaNoUltimo.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PosicionaNoUltimo w-html 
PROCEDURE PosicionaNoUltimo :
FIND LAST {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.

IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
    ASSIGN ab_unmap.aux_nrdrowid = "?".
ELSE
    ASSIGN ab_unmap.aux_nrdrowid  = STRING(ROWID({&SECOND-ENABLED-TABLE}))
           ab_unmap.aux_stdopcao = "".   /* aqui u */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE process-web-request w-html 
PROCEDURE process-web-request :
/*------------------------------------------------------------------------------
   Tipo: Procedure interna
   Nome: includes/webreq.i - Versão WebSpeed 2.1
  Autor: B&T/Solusoft
 Função: Processo de requisição web p/ cadastros simples na web - Versão WebSpeed 3.0
  Notas: Este é o procedimento principal onde terá as requisições GET e POST.
         GET - É ativa quando o formulário é chamado pela 1a vez
         POST - Após o get somente ocorrerá POST no formulário      
         Caso seja necessário custimizá-lo para algum programa específico 
         Favor cópiar este procedimento para dentro do procedure process-web-requeste 
         faça lá alterações necessárias.

Alterações: 10/12/2008 - Melhoria de performance para a tabela gnapses (Evandro).

-------------------------------------------------------------------------------*/

v-identificacao = get-cookie("cookie-usuario-em-uso").

/* Usado FOR EACH para poder utilizar o CONTAINS e WORD-INDEX, alterado para MATCHES */
FOR EACH gnapses WHERE gnapses.idsessao MATCHES "*" + v-identificacao + "*" NO-LOCK:
    LEAVE.
END.
  
ASSIGN opcao                       = GET-FIELD("aux_cddopcao")
       FlagPermissoes              = GET-VALUE("aux_lspermis")
       msg-erro-aux                = 0
       ab_unmap.aux_idevento       = GET-VALUE("aux_idevento")
       ab_unmap.aux_dsendurl       = AppURL                        
       ab_unmap.aux_lspermis       = FlagPermissoes                
       ab_unmap.aux_nrdrowid       = GET-VALUE("aux_nrdrowid")         
       ab_unmap.aux_stdopcao       = GET-VALUE("aux_stdopcao")
       ab_unmap.aux_cdevento       = GET-VALUE("aux_cdevento")
       ab_unmap.aux_cdcooper       = GET-VALUE("aux_cdcooper")
       ab_unmap.aux_vlrselec       = GET-VALUE("aux_vlrselec")
       ab_unmap.aux_dtanoage       = GET-VALUE("aux_dtanoage")
       ab_unmap.aux_flgselec       = GET-VALUE("aux_flgselec")
       ab_unmap.aux_lscpfcgc       = GET-VALUE("aux_lscpfcgc")
       ab_unmap.aux_lspropos       = GET-VALUE("aux_lspropos")
       ab_unmap.aux_nmpagina       = GET-VALUE("aux_nmpagina")
       ab_unmap.aux_vlrselec_termo = GET-VALUE("aux_vlrselec_termo")
       ab_unmap.aux_qtmaxtur       = GET-VALUE("aux_qtmaxtur").

RUN outputHeader.

/* Preenche o nome do evento */ 
/* Um evento pode ser incluído sem passar pela Sugestão de Eventos */
/* Essa situação serve para acrescer eventos na agenda */
/* Alterado em 31/01/2007 - Rosangela */
/*FIND FIRST crapedp WHERE crapedp.cdcooper = 0  AND
                         crapedp.dtanoage = 0  AND
                         crapedp.cdevento = INT(ab_unmap.aux_cdevento)  NO-LOCK NO-ERROR.
                                             
*/
FIND FIRST crapedp WHERE crapedp.cdcooper = INT(ab_unmap.aux_cdcooper)  AND
                         crapedp.dtanoage = INT(ab_unmap.aux_dtanoage)  AND
                         crapedp.cdevento = INT(ab_unmap.aux_cdevento)  NO-LOCK NO-ERROR.

IF  NOT AVAIL crapedp THEN
    DO:
        RUN RodaJavaScript("alert('O evento precisa constar na Seleção de Sugestões.');top.close();").
        LEAVE.
    END.

ASSIGN ab_unmap.nmevento     = IF AVAIL crapedp THEN crapedp.nmevento ELSE ""
       ab_unmap.aux_qtmaxtur = IF AVAIL crapedp THEN STRING(crapedp.qtmaxtur) ELSE "".

/* Preenche o nome da cooperativa */                                                                       
FIND FIRST crapcop WHERE crapcop.cdcooper = INT(ab_unmap.aux_cdcooper)  NO-LOCK NO-ERROR.
ASSIGN ab_unmap.nmrescop = IF AVAIL crapcop THEN crapcop.nmrescop ELSE "".

                           
/* Verifica se deve mostrar a aba de termos de compromisso */
IF   ab_unmap.aux_idevento = "1"   AND
     crapedp.flgcompr      = YES   THEN
     ab_unmap.aux_flgtermo = YES.
ELSE                                
     ab_unmap.aux_flgtermo = NO.
                                     
/* método POST */
IF REQUEST_METHOD = "POST":U THEN 
   DO:
      RUN inputFields.

      CASE opcao:
           WHEN "sa" THEN /* salvar */
                DO:
                    IF ab_unmap.aux_stdopcao = "i" THEN /* inclusao */
                        DO:
                            RUN local-assign-record ("inclusao"). 
                            IF msg-erro <> "" THEN
                               ASSIGN msg-erro-aux = 3. /* erros da validação de dados */
                            ELSE 
                            DO:
                               ASSIGN 
                                   msg-erro-aux = 10
                                   ab_unmap.aux_stdopcao = "al".
                               FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) EXCLUSIVE-LOCK NO-WAIT NO-ERROR.

                               IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                                  IF LOCKED {&SECOND-ENABLED-TABLE} THEN
                                     DO:
                                         ASSIGN msg-erro-aux = 1. /* registro em uso por outro usuário */  
                                         FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                                     END.
                                  ELSE
                                     DO: 
                                         ASSIGN msg-erro-aux = 2. /* registro não existe */
                                         RUN PosicionaNoSeguinte.
                                     END.

                            END.
                        END.  /* fim inclusao */
                    ELSE     /* alteração */ 
                        DO: 
                            /*FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) EXCLUSIVE-LOCK NO-WAIT NO-ERROR.

                            IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                               IF LOCKED {&SECOND-ENABLED-TABLE} THEN
                                  DO:
                                      ASSIGN msg-erro-aux = 1. /* registro em uso por outro usuário */  
                                      FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                                  END.
                               ELSE
                                  DO: 
                                      ASSIGN msg-erro-aux = 2. /* registro não existe */
                                      RUN PosicionaNoSeguinte.
                                  END.
                            ELSE
                               DO:*/
                                  RUN local-assign-record ("alteracao").  
                                  IF msg-erro = "" THEN
                                     ASSIGN msg-erro-aux = 10. /* Solicitação realizada com sucesso */ 
                                  ELSE
                                     ASSIGN msg-erro-aux = 3. /* erros da validação de dados */
                           /*    END.    */ 
                        END. /* fim alteração */
                END. /* fim salvar */

           WHEN "in" THEN /* inclusao */
                DO:
                    IF ab_unmap.aux_stdopcao <> "i" THEN
                       DO:
                          CLEAR FRAME {&FRAME-NAME}.
                          ASSIGN ab_unmap.aux_stdopcao = "i".
                       END.
                END. /* fim inclusao */

           WHEN "ex" THEN /* exclusao */
                DO:
                    FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.

                    /* busca o próximo registro para fazer o reposicionamento */
                    FIND NEXT {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.

                    IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                       ASSIGN aux_nrdrowid-auxiliar = STRING(ROWID({&SECOND-ENABLED-TABLE})).
                    ELSE
                       DO:
                           /* nao encontrou próximo registro então procura pelo registro anterior para o reposicionamento */
                           FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                           
                           FIND PREV {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.

                           IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                              ASSIGN aux_nrdrowid-auxiliar = STRING(ROWID({&SECOND-ENABLED-TABLE})).
                           ELSE
                              ASSIGN aux_nrdrowid-auxiliar = "?".
                       END.          
                       
                    /*** PROCURA TABELA PARA VALIDAR -> COM NO-LOCK ***/
                    FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                    
                    /*** PROCURA TABELA PARA EXCLUIR -> COM EXCLUSIVE-LOCK ***/
                    FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
                    
                    IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                       IF LOCKED {&SECOND-ENABLED-TABLE} THEN
                          DO:
                              ASSIGN msg-erro-aux = 1. /* registro em uso por outro usuário */ 
                              FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                          END.
                       ELSE
                          ASSIGN msg-erro-aux = 2. /* registro não existe */
                    ELSE
                       DO:
                          IF msg-erro = "" THEN
                             DO:
                                RUN local-delete-record.
                                DO i = 1 TO ERROR-STATUS:NUM-MESSAGES:
                                   ASSIGN msg-erro = msg-erro + ERROR-STATUS:GET-MESSAGE(i).
                                END.    

                                IF msg-erro = " " THEN
                                   DO:
                                       IF aux_nrdrowid-auxiliar = "?" THEN
                                          RUN PosicionaNoPrimeiro.
                                       ELSE
                                          DO:
                                              ASSIGN ab_unmap.aux_nrdrowid = aux_nrdrowid-auxiliar.
                                              FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                                              
                                              IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                                                 RUN PosicionaNoSeguinte.
                                          END.   
                                          
                                       ASSIGN msg-erro-aux = 10. /* Solicitação realizada com sucesso */ 
                                   END.
                                ELSE
                                   ASSIGN msg-erro-aux = 3. /* Exclusao rejeitada */ 
                             END.
                          ELSE
                             ASSIGN msg-erro-aux = 3. /* erros da validação de dados */
                       END.  
                END. /* fim exclusao */

           WHEN "pe" THEN /* pesquisar */
                DO:   
                    FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                    IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN 
                       RUN PosicionaNoSeguinte.
                END. /* fim pesquisar */

           WHEN "li" THEN /* listar */
                DO:
                    FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                    IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN 
                       RUN PosicionaNoSeguinte.
                END. /* fim listar */

           WHEN "pr" THEN /* primeiro */
                RUN PosicionaNoPrimeiro.
      
           WHEN "ul" THEN /* ultimo */
                RUN PosicionaNoUltimo.
      
           WHEN "an" THEN /* anterior */
                RUN PosicionaNoAnterior.
      
           WHEN "se" THEN /* seguinte */
                RUN PosicionaNoSeguinte.
    
      END CASE.

      RUN CriaListaPAC.
      RUN CriaListaTermo.

      IF msg-erro-aux = 10 OR (opcao <> "sa" AND opcao <> "ex" AND opcao <> "in") THEN
         RUN displayFields.
 
      RUN enableFields.
      RUN outputFields.

      CASE msg-erro-aux:
           WHEN 1 THEN
                DO:
                    ASSIGN v-qtdeerro      = 1
                           v-descricaoerro = 'Registro esta em uso por outro usuário. Solicitação não pode ser executada. Espere alguns instantes e tente novamente.'.

                    RUN RodaJavaScript('alert("'+ v-descricaoerro + '"); ').
                END.

           WHEN 2 THEN
                RUN RodaJavaScript("alert('Registro foi excluído. Solicitação não pode ser executada.')").
      
           WHEN 3 THEN
                DO:
                    ASSIGN v-qtdeerro      = 1
                           v-descricaoerro = msg-erro.

                    RUN RodaJavaScript('alert("'+ v-descricaoerro + '"); ').
                END.

           WHEN 4 THEN
                DO:
                    ASSIGN v-qtdeerro      = 1
                           v-descricaoerro = m-erros.

                    RUN RodaJavaScript('alert("'+ v-descricaoerro + '"); ').
                END.

           WHEN 10 THEN DO:
               RUN RodaJavaScript('window.opener.Recarrega();'). 
               RUN RodaJavaScript('alert("Atualizacao executada com sucesso.")'). 
           END.
         
      END CASE.     

     /* RUN RodaJavaScript('top.frames[0].ZeraOp()').  */ 

   END. /* Fim do método POST */
ELSE /* Método GET */ 
   DO:
      RUN PermissaoDeAcesso(INPUT ProgramaEmUso, OUTPUT IdentificacaoDaSessao, OUTPUT ab_unmap.aux_lspermis).
      
      CASE ab_unmap.aux_lspermis:
           WHEN "1" THEN /* get-cookie em usuario-em-uso voltou valor nulo */
                RUN RodaJavaScript('top.close(); window.open("falha","janela_principal","toolbar=yes,location=yes,diretories=no,status=yes,menubar=yes,scrollbars=yes,resizable=yes"); ').

           WHEN "2" THEN /* identificacao vinda do cookie bao existe na tabela de log de sessao */ 
                DO: 
                    DELETE-COOKIE("cookie-usuario-em-uso",?,?).
                    RUN RodaJavaScript('top.close(); window.open("falha","janela_principal","toolbar=yes,location=yes,diretories=no,status=yes,menubar=yes,scrollbars=yes,resizable=yes"); ').
                END.
  
           WHEN "3" THEN /* usuario nao tem permissao para acessa o programa */
                RUN RodaJavaScript('window.location.href = "' + ab_unmap.aux_dsendurl + '/gerenciador/negado"').
          
           OTHERWISE
                DO:
                    IF GET-VALUE("LinkRowid") <> "" THEN
                       DO:
                           FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(GET-VALUE("LinkRowid")) NO-LOCK NO-WAIT NO-ERROR.
                           
                           IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                              DO:
                                  ASSIGN ab_unmap.aux_nrdrowid = STRING(ROWID({&SECOND-ENABLED-TABLE}))
                                         ab_unmap.aux_idevento = STRING({&SECOND-ENABLED-TABLE}.idevento).

                                  FIND NEXT {&SECOND-ENABLED-TABLE} NO-LOCK NO-WAIT NO-ERROR.

                                  IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                                     ASSIGN ab_unmap.aux_stdopcao = "u".
                                  ELSE
                                     DO:
                                         FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                                         
                                         FIND PREV {&SECOND-ENABLED-TABLE} NO-LOCK NO-WAIT NO-ERROR.

                                         IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                                            ASSIGN ab_unmap.aux_stdopcao = "p".        
                                         ELSE
                                            ASSIGN ab_unmap.aux_stdopcao = "?".
                                     END.

                                  FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                              END.  
                           ELSE
                              ASSIGN ab_unmap.aux_nrdrowid = "?"
                                     ab_unmap.aux_stdopcao = "?".
                       END.  
                    ELSE                    
                       /*RUN PosicionaNoPrimeiro*/ .

                    RUN CriaListaPAC.
                    RUN CriaListaTermo.

                    RUN displayFields.
                    RUN enableFields.
                    RUN outputFields.
                   /* RUN RodaJavaScript('top.frcod.FechaZoom()').*/
                    RUN RodaJavaScript('CarregaPrincipal();').
                    
                    IF GET-VALUE("LinkRowid") = "" THEN
                       DO:
                           RUN RodaJavaScript('LimparCampos();').
                           RUN RodaJavaScript('Incluir();').
                       END.
                END. /* fim otherwise */                  
      END CASE. 
END. /* fim do método GET */

/* Show error messages. */
IF AnyMessage() THEN 
DO:
   /* ShowDataMessage may return a Progress column name. This means you
    * can use the function as a parameter to HTMLSetFocus instead of 
    * calling it directly.  The first parameter is the form name.   
    *
    * HTMLSetFocus("document.DetailForm",ShowDataMessages()). */
   ShowDataMessages().
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE RodaJavaScript w-html 
PROCEDURE RodaJavaScript :
{includes/rodajava.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

