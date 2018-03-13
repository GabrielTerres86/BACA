    &ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
/* Connected Databases 
          banco            PROGRESS
*/

/* ......................................................................

Alterações: 23/11/2009 - Aumento do campo referente Verba Total (Diego).
            
            14/06/2010 - Tratamento para PAC 91 - TAA (Elton).
			
			05/06/2012 - Adaptação dos fontes para projeto Oracle. Alterado
						 busca na gnapses de CONTAINS para MATCHES (Guilherme Maba).

            02/08/2016 - Inclusao insitage 3-Temporariamente Indisponivel.
                         (Jaison/Anderson)

......................................................................... */

&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD aux_cdcooper AS CHARACTER 
       FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_idexclui AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_pedispac AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_pemedpac AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_persaldo AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_vldispac AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dtanoage AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_vlmedpac AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_vlrsaldo AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_vlrselec AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_vlverbad AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_vlverbap AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_vlverbat AS CHARACTER FORMAT "X(256)":U .


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
DEFINE VARIABLE ProgramaEmUso AS CHARACTER INITIAL ["wpgd0017"].
DEFINE VARIABLE NmeDoPrograma AS CHARACTER INITIAL ["wpgd0017.w"].

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
DEFINE VARIABLE h-b1wpgd0017          AS HANDLE                         NO-UNDO.

/*** Temp Tables ***/
DEFINE TEMP-TABLE cratvdp             LIKE crapvdp.

DEFINE VARIABLE aux_crapcop AS CHAR NO-UNDO.

DEFINE VARIABLE vetorpac    AS CHAR INITIAL "" NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE fontes/wpgd0017.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS  
&Scoped-define ENABLED-TABLES ab_unmap crapvdp
&Scoped-define FIRST-ENABLED-TABLE ab_unmap
&Scoped-define SECOND-ENABLED-TABLE crapvdp
&Scoped-Define ENABLED-OBJECTS ab_unmap.aux_vlverbad ab_unmap.aux_vlverbap ~
ab_unmap.aux_vlverbat ab_unmap.aux_vlrselec ab_unmap.aux_cdcooper ~
ab_unmap.aux_cddopcao ab_unmap.aux_dsendurl ab_unmap.aux_dsretorn ~
ab_unmap.aux_idevento ab_unmap.aux_idexclui ab_unmap.aux_lspermis ~
ab_unmap.aux_nrdrowid ab_unmap.aux_pedispac ab_unmap.aux_pemedpac ~
ab_unmap.aux_persaldo ab_unmap.aux_stdopcao ab_unmap.aux_vldispac ~
ab_unmap.aux_vlmedpac ab_unmap.aux_vlrsaldo ab_unmap.aux_dtanoage
&Scoped-Define DISPLAYED-FIELDS  
&Scoped-define DISPLAYED-TABLES ab_unmap crapvdp
&Scoped-define FIRST-DISPLAYED-TABLE ab_unmap
&Scoped-define SECOND-DISPLAYED-TABLE crapvdp
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.aux_vlverbad ~
ab_unmap.aux_vlverbap ab_unmap.aux_vlverbat ab_unmap.aux_vlrselec ~
ab_unmap.aux_cdcooper ab_unmap.aux_cddopcao ab_unmap.aux_dsendurl ~
ab_unmap.aux_dsretorn ab_unmap.aux_idevento ab_unmap.aux_idexclui ~
ab_unmap.aux_lspermis ab_unmap.aux_nrdrowid ab_unmap.aux_pedispac ~
ab_unmap.aux_pemedpac ab_unmap.aux_persaldo ab_unmap.aux_stdopcao ~
ab_unmap.aux_vldispac ab_unmap.aux_vlmedpac ab_unmap.aux_vlrsaldo ~
ab_unmap.aux_dtanoage

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     ab_unmap.aux_vlverbad AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_vlverbap AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_vlverbat AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_vlrselec AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cdcooper AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.aux_cddopcao AT ROW 1 COL 1 HELP
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
     ab_unmap.aux_idevento AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_idexclui AT ROW 1 COL 1 HELP
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
     ab_unmap.aux_pedispac AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_pemedpac AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_persaldo AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_stdopcao AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_vldispac AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_vlmedpac AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_vlrsaldo AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_dtanoage AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 71.4 BY 19.05.


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
          FIELD aux_cdcooper AS CHARACTER 
          FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_idexclui AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_pedispac AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_pemedpac AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_persaldo AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_vldispac AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_vlmedpac AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_vlrsaldo AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_vlrselec AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_vlverbad AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_vlverbap AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_vlverbat AS CHARACTER FORMAT "X(256)":U 
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW w-html ASSIGN
         HEIGHT             = 19.05
         WIDTH              = 71.4.
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
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_cdcooper IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN ab_unmap.aux_cddopcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dsendurl IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dsretorn IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_idevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_idexclui IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lspermis IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nrdrowid IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_pedispac IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_pemedpac IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_persaldo IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_stdopcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_vldispac IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_vlmedpac IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_vlrsaldo IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_vlrselec IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_vlverbad IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_vlverbap IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_vlverbat IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dtanoage IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
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
    DEFINE VARIABLE tot_vlverbat AS DEC    NO-UNDO.
    DEFINE VARIABLE tot_vlverbap AS DEC    NO-UNDO.

    DEFINE VARIABLE aux_vlverbat AS DEC    NO-UNDO.
    DEFINE VARIABLE aux_qtdepacs AS INT    NO-UNDO.
    DEFINE VARIABLE aux_nmresage AS CHAR   NO-UNDO.
    DEFINE VARIABLE aux_cdageagr AS INT    NO-UNDO.

    DEFINE VARIABLE tmp_cdcooper AS INT    NO-UNDO.

    DEFINE BUFFER bf-crapvdp FOR crapvdp.
    DEFINE BUFFER bf-crapagp FOR crapagp.
    DEFINE BUFFER bf-crapage FOR crapage.

    IF   AVAIL crapvdp   THEN
         ASSIGN tmp_cdcooper = crapvdp.cdcooper
                tot_vlverbap = crapvdp.vlverbap.
    ELSE
         ASSIGN tmp_cdcooper = INT(ab_unmap.aux_cdcooper)
                tot_vlverbap = 0.
    
    /* Conta quantos PACs agrupadores existem */
    IF   INT(ab_unmap.aux_idevento) = 1  THEN
         DO:
             FOR EACH crapagp WHERE crapagp.idevento = INT(ab_unmap.aux_idevento)  AND
                                    crapagp.cdcooper = tmp_cdcooper                AND 
                                    crapagp.dtanoage = INT(ab_unmap.aux_dtanoage)  AND
                                    crapagp.cdagenci = crapagp.cdageagr            NO-LOCK:

                 aux_qtdepacs = aux_qtdepacs + 1.
             END.
         END.
    ELSE
         DO:
             /* Todos os PACS ativos menos 90-INTERNET e 91-TAA */
             FOR EACH crapage where crapage.cdcooper = tmp_cdcooper AND
                                   (crapage.insitage = 1  OR        /* Ativo */
                                    crapage.insitage = 3) NO-LOCK:  /* Temporariamente Indisponivel */

                 IF   crapage.cdagenci <> 90   AND
                      crapage.cdagenci <> 91   THEN
                      aux_qtdepacs = aux_qtdepacs + 1.
             END.
         END.
 
   /* Inclusao da linha de propagacao */
   FIND FIRST bf-crapvdp WHERE bf-crapvdp.idevento = INT(ab_unmap.aux_idevento)  AND
                               bf-crapvdp.cdcooper = tmp_cdcooper                AND
                               bf-crapvdp.dtanoage = INT(ab_unmap.aux_dtanoage)  AND
                               bf-crapvdp.cdagenci = 0
                               NO-LOCK NO-ERROR.

   ASSIGN aux_vlverbat = IF   AVAIL bf-crapvdp   THEN
                              (bf-crapvdp.vlverbap / aux_qtdepacs)
                         ELSE 0

          vetorpac     = "~{" + "nmresage:"  + "'" + REPLACE(aux_nmresage, "'","`")           + "'"
                              + ",cdcooper:" + "'" + STRING(tmp_cdcooper)                     + "'"
                              + ",vlprogri:" + "'" + STRING(aux_vlverbat, ">>>,>>>,>>9.99")   + "'"
                              + ",peprogri:" + "'" + STRING(100 / aux_qtdepacs, ">>>,>>9.99") + "'"
                              + ",cdagenci:" + "'" + STRING(0) + "'" + "~}".

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


   /* Monta as informações relativas a cada PAC */
   FOR EACH crapage WHERE crapage.cdcooper = tmp_cdcooper  AND
                         (crapage.insitage = 1  OR        /* Ativo */
                          crapage.insitage = 3) NO-LOCK:  /* Temporariamente Indisponivel */

       /* Despreza PAC 90-INTERNET e 91-TAA */
       IF   crapage.cdagenci = 90   OR
            crapage.cdagenci = 91   THEN
            NEXT.

       /* Controle de visualização por PAC */
       IF  (gnapses.nvoperad = 1    OR
            gnapses.nvoperad = 2)                  AND
            gnapses.cdagenci <> crapage.cdagenci   AND
            crapage.cdagenci <> aux_cdageagr       THEN
            NEXT.

       /* Se for progrid, considera só os PACs agrupadores. Do contrário é todos */
       FIND crapagp WHERE crapagp.idevento = INT(ab_unmap.aux_idevento)  AND
                          crapagp.cdcooper = tmp_cdcooper                AND 
                          crapagp.dtanoage = INT(ab_unmap.aux_dtanoage)  AND 
                          crapagp.cdagenci = crapage.cdagenci
                          NO-LOCK NO-ERROR.

       IF   INT(ab_unmap.aux_idevento) = 1  THEN
            DO:
                IF   NOT AVAIL crapagp   THEN
                     NEXT.

                IF   crapagp.cdagenci <> crapagp.cdageagr   THEN
                     NEXT.
            END.

       aux_nmresage = crapage.nmresage.

       IF   INT(ab_unmap.aux_idevento) = 1   THEN
            DO:
                /* Pega os PACS agrupados */
                FOR EACH bf-crapagp  WHERE bf-crapagp.idevento  = crapagp.idevento      AND
                                           bf-crapagp.cdcooper  = crapagp.cdcooper      AND
                                           bf-crapagp.dtanoage  = crapagp.dtanoage      AND
                                           bf-crapagp.cdageagr  = crapagp.cdagenci      AND
                                           bf-crapagp.cdagenci <> crapagp.cdagenci      NO-LOCK,
                    FIRST bf-crapage WHERE bf-crapage.cdcooper  = bf-crapagp.cdcooper   AND
                                           bf-crapage.cdagenci  = bf-crapagp.cdagenci   NO-LOCK
                                           BY bf-crapage.nmresage:
           
                    aux_nmresage = aux_nmresage + " / " + bf-crapage.nmresage.
                END.
            END.


       FIND FIRST bf-crapvdp WHERE bf-crapvdp.idevento = INT(ab_unmap.aux_idevento) AND
                                   bf-crapvdp.cdcooper = tmp_cdcooper               AND
                                   bf-crapvdp.cdagenci = crapage.cdagenci           AND
                                   bf-crapvdp.dtanoage = INT(crapvdp.dtanoage)
                                   NO-LOCK NO-ERROR.

       /* Se tem verba lançada, pega de lá. Se não tem, atribui 0 */
       IF   AVAIL bf-crapvdp   THEN 
            aux_vlverbat = bf-crapvdp.vlverbat.
       ELSE
            aux_vlverbat = 0.

       ASSIGN ab_unmap.aux_vldispac = STRING(DEC(ab_unmap.aux_vldispac) + aux_vlverbat, "->>>,>>>,>>9.99")
              ab_unmap.aux_vlrsaldo = STRING(tot_vlverbap - DEC(ab_unmap.aux_vldispac), "->>>,>>9.99").

       /* Trata divisões por zero */
       IF   aux_qtdepacs <> 0   THEN
            ASSIGN ab_unmap.aux_vlmedpac = STRING(tot_vlverbap / aux_qtdepacs, "->>>,>>9.99").
       ELSE
            ASSIGN ab_unmap.aux_vlmedpac = "0,00".

       IF   tot_vlverbap <> 0   THEN
            ASSIGN ab_unmap.aux_pemedpac = STRING(DEC(ab_unmap.aux_vlmedpac) / tot_vlverbap * 100, "->>>,>>9.99")
                   ab_unmap.aux_pedispac = STRING(DEC(ab_unmap.aux_vldispac) / tot_vlverbap * 100, "->>>,>>9.99")
                   ab_unmap.aux_persaldo = STRING(DEC(ab_unmap.aux_vlrsaldo) / tot_vlverbap * 100, "->>>,>>9.99").
       ELSE
            ASSIGN ab_unmap.aux_pemedpac = "0,00"
                   ab_unmap.aux_pedispac = "0,00"
                   ab_unmap.aux_persaldo = "0,00".

       IF   tot_vlverbap <> 0   THEN
            IF   vetorpac = ""   THEN
                 vetorpac = "~{" + "nmresage:"  + "'" + REPLACE(aux_nmresage, "'","`")                          + "'"
                                 + ",cdcooper:" + "'" + STRING(crapage.cdcooper)                                + "'"
                                 + ",vlprogri:" + "'" + STRING(aux_vlverbat, ">>>,>>>,>>9.99")                  + "'"
                                 + ",peprogri:" + "'" + STRING(aux_vlverbat / tot_vlverbap * 100, ">>>,>>>,>>9.99") + "'"
                                 + ",cdagenci:" + "'" + STRING(crapage.cdagenci) + "'" + "~}".
            ELSE
                 vetorpac = vetorpac + "," + 
                            "~{" + "nmresage:"  + "'" + REPLACE(aux_nmresage, "'","`")                          + "'"
                                 + ",cdcooper:" + "'" + STRING(crapage.cdcooper)                                + "'"
                                 + ",vlprogri:" + "'" + STRING(aux_vlverbat, ">>>,>>>,>>9.99")                  + "'"
                                 + ",peprogri:" + "'" + STRING(aux_vlverbat / tot_vlverbap * 100, ">>>,>>>,>>9.99") + "'"
                                 + ",cdagenci:" + "'" + STRING(crapage.cdagenci) + "'" + "~}".
        ELSE
            IF   vetorpac = ""   THEN
                 vetorpac = "~{" + "nmresage:"  + "'" + REPLACE(aux_nmresage, "'","`")     + "'"
                                 + ",cdcooper:" + "'" + STRING(crapage.cdcooper)           + "'"
                                 + ",vlprogri:" + "'" + STRING(aux_vlverbat, ">>>,>>>,>>9.99") + "'"
                                 + ",peprogri:" + "'" + STRING("0,00")                     + "'"
                                 + ",cdagenci:" + "'" + STRING(crapage.cdagenci) + "'" + "~}".
            ELSE
                 vetorpac = vetorpac + "," + 
                            "~{" + "nmresage:"  + "'" + REPLACE(aux_nmresage, "'","`")     + "'"
                                 + ",cdcooper:" + "'" + STRING(crapage.cdcooper)           + "'"
                                 + ",vlprogri:" + "'" + STRING(aux_vlverbat, ">>>,>>>,>>9.99") + "'"
                                 + ",peprogri:" + "'" + STRING("0,00")                     + "'"
                                 + ",cdagenci:" + "'" + STRING(crapage.cdagenci) + "'" + "~}".

   END. /* FOR EACH crapage */

   /* Se não teve PAC, pelo menos cria o array vazio */
   IF   vetorpac = ?   THEN
        ASSIGN vetorpac = "".

   RUN RodaJavaScript("var mpac=new Array();mpac=["  + vetorpac + "]").

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
    ("aux_dsendurl":U,"ab_unmap.aux_dsendurl":U,ab_unmap.aux_dsendurl:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsretorn":U,"ab_unmap.aux_dsretorn":U,ab_unmap.aux_dsretorn:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idevento":U,"ab_unmap.aux_idevento":U,ab_unmap.aux_idevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idexclui":U,"ab_unmap.aux_idexclui":U,ab_unmap.aux_idexclui:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lspermis":U,"ab_unmap.aux_lspermis":U,ab_unmap.aux_lspermis:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrdrowid":U,"ab_unmap.aux_nrdrowid":U,ab_unmap.aux_nrdrowid:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_pedispac":U,"ab_unmap.aux_pedispac":U,ab_unmap.aux_pedispac:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_pemedpac":U,"ab_unmap.aux_pemedpac":U,ab_unmap.aux_pemedpac:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_persaldo":U,"ab_unmap.aux_persaldo":U,ab_unmap.aux_persaldo:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_stdopcao":U,"ab_unmap.aux_stdopcao":U,ab_unmap.aux_stdopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_vldispac":U,"ab_unmap.aux_vldispac":U,ab_unmap.aux_vldispac:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_vlmedpac":U,"ab_unmap.aux_vlmedpac":U,ab_unmap.aux_vlmedpac:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_vlrsaldo":U,"ab_unmap.aux_vlrsaldo":U,ab_unmap.aux_vlrsaldo:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_vlrselec":U,"ab_unmap.aux_vlrselec":U,ab_unmap.aux_vlrselec:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_vlverbad":U,"ab_unmap.aux_vlverbad":U,ab_unmap.aux_vlverbad:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_vlverbap":U,"ab_unmap.aux_vlverbap":U,ab_unmap.aux_vlverbap:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_vlverbat":U,"ab_unmap.aux_vlverbat":U,ab_unmap.aux_vlverbat:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dtanoage":U,"ab_unmap.aux_dtanoage":U,ab_unmap.aux_dtanoage:HANDLE IN FRAME {&FRAME-NAME}).
END PROCEDURE.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-assign-record w-html 
PROCEDURE local-assign-record :
DEFINE INPUT PARAMETER opcao AS CHARACTER.

DEFINE VARIABLE aux_qtpacsel AS INT NO-UNDO.

DEFINE VARIABLE aux_msgderro AS CHAR NO-UNDO.

/* Instancia a BO para executar as procedures */
RUN dbo/b1wpgd0017.p PERSISTENT SET h-b1wpgd0017.

/* Se BO foi instanciada */
IF VALID-HANDLE(h-b1wpgd0017) THEN
   DO:
      DO WITH FRAME {&FRAME-NAME}:
         IF opcao = "inclusao" THEN
            DO: 
                ASSIGN msg-erro = msg-erro + "nao tem inclusao".
            END.
         ELSE  /* alteracao */
            DO:
                /* Para todos os PACs */
                DO aux_qtpacsel = 1 TO (NUM-ENTRIES(ab_unmap.aux_vlrselec, ";") / 2):

                    /*RUN RodaJavaScript('alert("tpcuseve: '+ ab_unmap.aux_vlrselec, ";") + '"); ').*/

                    FIND FIRST cratvdp NO-ERROR.
                    IF AVAIL cratvdp THEN
                        DELETE cratvdp.

                    CREATE cratvdp.
                    ASSIGN
                        cratvdp.cdagenci = INT(ENTRY(aux_qtpacsel * 2 - 1, ab_unmap.aux_vlrselec, ";"))
                        cratvdp.cdcooper = INT(ab_unmap.aux_cdcooper)
                        cratvdp.dtanoage = INT(INPUT ab_unmap.aux_dtanoage)
                        cratvdp.idevento = INT(ab_unmap.aux_idevento)
                        cratvdp.cdoperad = gnapses.cdoperad.

                    IF INT(ENTRY(aux_qtpacsel * 2 - 1, ab_unmap.aux_vlrselec, ";")) = 0 THEN
                        ASSIGN 
                        cratvdp.vlverbat = DEC(ab_unmap.aux_vlverbat)
                        cratvdp.vlverbap = DEC(ab_unmap.aux_vlverbat) - DEC(ab_unmap.aux_vlverbad).
                    ELSE
                        ASSIGN 
                            cratvdp.vlverbat = DEC(ENTRY(aux_qtpacsel * 2, ab_unmap.aux_vlrselec, ";"))
                            cratvdp.vlverbap = 0.
                        /*NEXT.*/

                   /* IF aux_qtpacsel = 1 THEN DO:
                        RUN RodaJavaScript('alert("Valor Recebido: ' + string(aux_vlrdecim) + '"); ').
                        RUN RodaJavaScript('alert("Valor Tabela: ' + string(cratcdp.vlcuseve) + '"); ').
                    END.*/

                    FIND FIRST crapvdp WHERE
                        crapvdp.idevento = cratvdp.idevento AND
                        crapvdp.cdcooper = cratvdp.cdcooper AND
                        crapvdp.cdagenci = cratvdp.cdagenci AND
                        crapvdp.dtanoage = cratvdp.dtanoage NO-LOCK NO-ERROR.

                    IF AVAIL crapvdp THEN
                        RUN altera-registro IN h-b1wpgd0017(INPUT TABLE cratvdp, OUTPUT aux_msgderro).
                    ELSE
                        RUN inclui-registro IN h-b1wpgd0017(INPUT TABLE cratvdp, OUTPUT aux_msgderro, OUTPUT ab_unmap.aux_nrdrowid).

                    ASSIGN msg-erro = msg-erro + aux_msgderro.

                END. /* DO aux_qtpacsel */
            END.    
      END. /* DO WITH FRAME {&FRAME-NAME} */
   
      /* "mata" a instância da BO */
      DELETE PROCEDURE h-b1wpgd0017 NO-ERROR.
   
   END. /* IF VALID-HANDLE(h-b1wpgd0017) */
      
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-delete-record w-html 
PROCEDURE local-delete-record :
/* Instancia a BO para executar as procedures */
RUN dbo/b1wpgd0017.p PERSISTENT SET h-b1wpgd0017.
 
/* Se BO foi instanciada */
IF VALID-HANDLE(h-b1wpgd0017) THEN
   DO:
      CREATE cratvdp.
      BUFFER-COPY crapvdp TO cratvdp.
          
      RUN exclui-registro IN h-b1wpgd0017(INPUT TABLE cratvdp, OUTPUT msg-erro).

      /* "mata" a instância da BO */
      DELETE PROCEDURE h-b1wpgd0017 NO-ERROR.
   END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-display-fields w-html 
PROCEDURE local-display-fields :
RUN displayFields.

IF AVAIL crapvdp THEN
DO:
    ab_unmap.aux_vlverbat:SCREEN-VALUE IN FRAME {&FRAME-NAME} = string(crapvdp.vlverbat, ">>>,>>>,>>9.99").
END.

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

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PesquisaVerba w-html 
PROCEDURE PesquisaVerba :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       Verifica se existe verba para a cooperativa selecionada e o ano da agenda
  Se tiver, mostra tudo na tela, senão, limpa tudo pra que possa ser inserido novo registro
------------------------------------------------------------------------------*/

 
 
 FIND FIRST crapvdp WHERE 
     crapvdp.idevento = INT(ab_unmap.aux_idevento) AND
     crapvdp.cdcooper = INT(ab_unmap.aux_cdcooper) AND
     crapvdp.cdagenci = 0 AND
     crapvdp.dtanoage = INT(ab_unmap.aux_dtanoage)
      NO-LOCK NO-ERROR.

 IF AVAIL crapvdp THEN
 DO:
     ASSIGN
         ab_unmap.aux_vlverbat = TRIM(STRING(crapvdp.vlverbat, "->>>,>>>,>>9.99"))
         ab_unmap.aux_vlverbap = TRIM(STRING(crapvdp.vlverbap, "->>>,>>>,>>9.99"))
         ab_unmap.aux_vlverbad = TRIM(STRING((crapvdp.vlverbat - crapvdp.vlverbap), "->>>,>>>,>>9.99"))
         ab_unmap.aux_stdopcao = "al".
 END.

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
/*FIND FIRST {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.


IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
    ASSIGN ab_unmap.aux_nrdrowid  = "?"
           ab_unmap.aux_stdopcao = "".
ELSE
    ASSIGN ab_unmap.aux_nrdrowid  = STRING(ROWID({&SECOND-ENABLED-TABLE}))
           ab_unmap.aux_stdopcao = "".  /* aqui p */

/* Não traz inicialmente nenhum registro */ 
RELEASE {&SECOND-ENABLED-TABLE}.

ASSIGN ab_unmap.aux_nrdrowid  = "?"
       ab_unmap.aux_stdopcao = "".*/



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
  
ASSIGN opcao                    = GET-FIELD("aux_cddopcao")
       FlagPermissoes           = GET-VALUE("aux_lspermis")
       msg-erro-aux             = 0
       ab_unmap.aux_idevento    = GET-VALUE("aux_idevento")
       ab_unmap.aux_dsendurl    = AppURL                        
       ab_unmap.aux_lspermis    = FlagPermissoes                
       ab_unmap.aux_nrdrowid    = GET-VALUE("aux_nrdrowid")         
       ab_unmap.aux_stdopcao    = GET-VALUE("aux_stdopcao")
       ab_unmap.aux_cdcooper    = GET-VALUE("aux_cdcooper")
       ab_unmap.aux_vlrselec    = GET-VALUE("aux_vlrselec")
       ab_unmap.aux_vlverbat    = GET-VALUE("aux_vlverbat")
       ab_unmap.aux_vlverbap    = GET-VALUE("aux_vlverbap")
       ab_unmap.aux_vlverbad    = GET-VALUE("aux_vlverbad")
       ab_unmap.aux_dtanoage    = GET-VALUE("aux_dtanoage")
       .

RUN outputHeader.

{includes/wpgd0098.i}

ASSIGN
    ab_unmap.aux_cdcooper:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = aux_crapcop.


/* Se a cooperativa ainda não foi escolhida, pega a da sessão do usuário */
IF   INT(ab_unmap.aux_cdcooper) = 0   THEN
     ab_unmap.aux_cdcooper = STRING(gnapses.cdcooper).

FIND LAST gnpapgd WHERE gnpapgd.idevento = INT(ab_unmap.aux_idevento) AND 
                        gnpapgd.cdcooper = INT(ab_unmap.aux_cdcooper) AND 
                        gnpapgd.dtanonov = INT(ab_unmap.aux_dtanoage) NO-LOCK NO-ERROR.

IF NOT AVAILABLE gnpapgd THEN
   DO:
      IF   ab_unmap.aux_dtanoage <> ""   THEN
           DO:
               RUN RodaJavaScript("alert('Nao existe agenda para o ano (" + ab_unmap.aux_dtanoage + ") informado!');").
               opcao = "".
           END.

      FIND LAST gnpapgd WHERE gnpapgd.idevento = INT(ab_unmap.aux_idevento) AND 
                              gnpapgd.cdcooper = INT(ab_unmap.aux_cdcooper) NO-LOCK NO-ERROR.

   END.

IF AVAILABLE gnpapgd THEN
   ASSIGN ab_unmap.aux_dtanoage = STRING(gnpapgd.dtanonov).
ELSE
   ASSIGN ab_unmap.aux_dtanoage = "".


/*******/   
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
                           /*    END.     */
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
               RUN PesquisaVerba.

               /* FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
               IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN 
                  RUN PosicionaNoSeguinte.*/
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
      RUN PesquisaVerba.
      RUN CriaListaPAC.

      IF msg-erro-aux = 10 OR (opcao <> "sa" AND opcao <> "ex" AND opcao <> "in") THEN
         RUN displayFields.
 
      RUN enableFields.
      RUN outputFields.

      CASE msg-erro-aux:
           WHEN 1 THEN
                DO:
                    ASSIGN v-qtdeerro      = 1
                           v-descricaoerro = 'Registro esta em uso por outro usuário. Solicitação não pode ser executada. Espere alguns instantes e tente novamente.'.

                    RUN RodaJavaScript(' top.frames[0].MostraResultado(' + STRING(v-qtdeerro) + ',"'+ v-descricaoerro + '"); ').
                END.

           WHEN 2 THEN
                RUN RodaJavaScript(" top.frames[0].MostraMsg('Registro foi excluído. Solicitação não pode ser executada.')").
      
           WHEN 3 THEN
                DO:
                    ASSIGN v-qtdeerro      = 1
                           v-descricaoerro = msg-erro.

                    RUN RodaJavaScript('top.frames[0].MostraResultado(' + STRING(v-qtdeerro) + ',"'+ v-descricaoerro + '"); ').
                END.

           WHEN 4 THEN
                DO:
                    ASSIGN v-qtdeerro      = 1
                           v-descricaoerro = m-erros.

                    RUN RodaJavaScript('top.frames[0].MostraResultado(' + STRING(v-qtdeerro) + ',"'+ v-descricaoerro + '"); ').
                END.

           WHEN 10 THEN
                RUN RodaJavaScript('alert("Atualizacao executada com sucesso.")'). 
         
      END CASE.     
      RUN RodaJavaScript('top.frames[0].ZeraOp()').   

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
                       RUN PosicionaNoPrimeiro.
                    RUN PesquisaVerba.
                    RUN CriaListaPAC. 
                    RUN local-display-fields.
                    /*RUN displayFields.*/

                    RUN enableFields.
                    RUN outputFields.
                    /*RUN RodaJavaScript('top.frcod.FechaZoom()').*/
                    RUN RodaJavaScript('CarregaPrincipal()').
                    
                    /*
                    IF GET-VALUE("LinkRowid") = "" THEN
                    DO:
                        RUN RodaJavaScript('document.form.aux_cdcooper.value = "";').
                    END.
                    */
                END. /* fim otherwise */                  
      END CASE. 
END. /* fim do método GET */
RUN Incluir.
IF vetorpac <> "" THEN DO:
   RUN RodaJavaScript('mostraPACs();').   
END.
   
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
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Incluir w-html 
PROCEDURE Incluir:
  IF NOT AVAIL crapvdp THEN DO:
     FIND FIRST crapagp WHERE
          crapagp.idevento = INT(ab_unmap.aux_idevento) AND
          crapagp.cdcooper = INT(ab_unmap.aux_cdcooper) AND
          crapagp.dtanoage = INT(ab_unmap.aux_dtanoage) NO-LOCK NO-ERROR.
     IF NOT AVAIL crapagp AND 
        ab_unmap.aux_idevento <> "2" THEN DO:
        RUN RodaJavaScript("alert('Não existe eventos para o ano/cooperativa informado.')"). 
     END.                      
     ELSE DO:
         RUN RodaJavaScript('LimparCampos();').
         /* RUN RodaJavaScript('top.frcod.Incluir();'). */
     END.
  END.
END PROCEDURE.
&ANALYZE-RESUME
