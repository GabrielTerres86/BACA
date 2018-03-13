/*...............................................................................

Alterações: 10/12/2008 - Melhoria de performance para a tabela gnapses (Evandro).

            17/11/2009 - Inicializar tela com o ano da agenda atual (Diego).
			
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
       FIELD aux_cdagenci AS CHARACTER 
       FIELD aux_cdcooper AS CHARACTER 
       FIELD aux_cdcuseve AS CHARACTER 
       FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nrseqeve AS CHARACTER 
       FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dtanoage AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nrseqdig AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_tpcuseve AS CHARACTER 
       FIELD cdagenci     AS CHARACTER
       FIELD nrseqeve     AS CHARACTER 
       FIELD cdcuseve     AS CHARACTER .


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
DEFINE VARIABLE ProgramaEmUso AS CHARACTER INITIAL ["wpgd0022"].
DEFINE VARIABLE NmeDoPrograma AS CHARACTER INITIAL ["wpgd0022.w"].

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
DEFINE VARIABLE h-b1wpgd0022          AS HANDLE                         NO-UNDO.

/*** Temp Tables ***/
DEFINE TEMP-TABLE cratcrp             LIKE crapcrp.

DEFINE VARIABLE vetorevento AS CHAR NO-UNDO.
DEFINE VARIABLE vetorpac    AS CHAR NO-UNDO.
DEFINE VARIABLE vetorcusto  AS CHAR NO-UNDO.
DEFINE VARIABLE aux_crapcop AS CHAR NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE fontes/wpgd0022.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS crapcrp.vlcusrea ~
crapcrp.dsobserv crapcrp.dtanoage ~
crapcrp.dtmvtolt crapcrp.tpcuseve 
&Scoped-define ENABLED-TABLES ab_unmap crapcrp
&Scoped-define FIRST-ENABLED-TABLE ab_unmap
&Scoped-define SECOND-ENABLED-TABLE crapcrp
&Scoped-Define ENABLED-OBJECTS ab_unmap.aux_cdagenci ab_unmap.aux_cdcooper ~
ab_unmap.aux_cdcuseve ab_unmap.aux_cddopcao ab_unmap.aux_nrseqeve ~
ab_unmap.aux_dsendurl ab_unmap.aux_dsretorn ab_unmap.aux_dtanoage ~
ab_unmap.aux_idevento ab_unmap.aux_lspermis ab_unmap.aux_nrdrowid ~
ab_unmap.aux_nrseqdig ab_unmap.aux_stdopcao ab_unmap.aux_tpcuseve ~
ab_unmap.cdagenci     ab_unmap.nrseqeve     ab_unmap.cdcuseve
&Scoped-Define DISPLAYED-FIELDS crapcrp.vlcusrea ~
crapcrp.dsobserv crapcrp.dtanoage ~
crapcrp.dtmvtolt crapcrp.tpcuseve 
&Scoped-define DISPLAYED-TABLES ab_unmap crapcrp
&Scoped-define FIRST-DISPLAYED-TABLE ab_unmap
&Scoped-define SECOND-DISPLAYED-TABLE crapcrp
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.aux_cdagenci ~
ab_unmap.aux_cdcooper ab_unmap.aux_cdcuseve ab_unmap.aux_cddopcao ~
ab_unmap.aux_nrseqeve ab_unmap.aux_dsendurl ab_unmap.aux_dsretorn ~
ab_unmap.aux_dtanoage ab_unmap.aux_idevento ab_unmap.aux_lspermis ~
ab_unmap.aux_nrdrowid ab_unmap.aux_nrseqdig ab_unmap.aux_stdopcao ~
ab_unmap.aux_tpcuseve ab_unmap.cdagenci     ab_unmap.nrseqeve ~
ab_unmap.cdcuseve

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     ab_unmap.aux_cdagenci AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.aux_cdcooper AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.aux_cdcuseve AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.aux_cddopcao AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nrseqeve AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
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
     ab_unmap.aux_nrseqdig AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_stdopcao AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_tpcuseve AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS 
                    "aux_tpcuseve 1", "1", "aux_tpcuseve 2", "2"
          SIZE 20 BY 3
     ab_unmap.cdagenci AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapcrp.vlcusrea AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.cdcuseve AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.nrseqeve AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapcrp.dsobserv AT ROW 1 COL 1 NO-LABEL
          VIEW-AS EDITOR NO-WORD-WRAP
          SIZE 20 BY 4
     crapcrp.dtanoage AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapcrp.dtmvtolt AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapcrp.tpcuseve AT ROW 1 COL 1 NO-LABEL
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
          FIELD aux_cdagenci AS CHARACTER 
          FIELD aux_cdcooper AS CHARACTER 
          FIELD aux_cdcuseve AS CHARACTER 
          FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_cdevento AS CHARACTER 
          FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dtanoage AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nrseqdig AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_tpcuseve AS CHARACTER 
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
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_cdagenci IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_cdcooper IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_cdcuseve IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN ab_unmap.aux_cddopcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_cdevento IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dsendurl IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dsretorn IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dtanoage IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_idevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lspermis IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nrdrowid IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nrseqdig IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_stdopcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR RADIO-SET ab_unmap.aux_tpcuseve IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN crapcrp.cdagenci IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN crapcrp.cdcuseve IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN crapcrp.cdevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR EDITOR crapcrp.dsobserv IN FRAME Web-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN crapcrp.dtanoage IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN crapcrp.dtmvtolt IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN crapcrp.tpcuseve IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN crapcrp.vlcusrea IN FRAME Web-Frame
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaCusto w-html 
PROCEDURE CriaListaCusto :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE aux_dscuseve AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE aux_cdcuseve AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE i            AS INTEGER    NO-UNDO.
    
    FIND FIRST craptab WHERE craptab.cdcooper = 0               AND
                             craptab.nmsistem = "CRED"          AND
                             craptab.tptabela = "CONFIG"        AND
                             craptab.cdempres = 0               AND
                             craptab.cdacesso = "PGDCUSTEVE"    AND
                             craptab.tpregist = 0               NO-LOCK NO-ERROR.
    
    /* Copia pro vetor todos os custos diretos */
    IF AVAIL craptab THEN
    DO:
        DO i = 1 TO (NUM-ENTRIES(craptab.dstextab) / 2):
            ASSIGN 
                /* Entradas ímpares são as descrições */
                aux_dscuseve = ENTRY(2 * i - 1, craptab.dstextab)
                /* Entradas pares são os códigos */ 
                aux_cdcuseve = ENTRY(2 * i, craptab.dstextab).
    
            IF  vetorcusto = "" THEN
                vetorcusto = "~{" +
                     "cdcuseve:'" +  STRING(aux_cdcuseve) + "'," + 
                     "dscuseve:'" +  STRING(aux_dscuseve) + "'," + 
                     "tpcuseve:'" +  STRING(1) + "'" + "~}".
            ELSE
                vetorcusto = vetorcusto + "," + "~{" +
                     "cdcuseve:'" +  STRING(aux_cdcuseve) + "'," + 
                     "dscuseve:'" +  STRING(aux_dscuseve) + "'," + 
                     "tpcuseve:'" +  STRING(1) + "'" + "~}".
        END.
    END.
    
    FOR EACH crapcdi WHERE crapcdi.idevento = INT(ab_unmap.aux_idevento) NO-LOCK:
        IF  vetorcusto = "" THEN
            vetorcusto = "~{" +
                 "cdcuseve:'" +  STRING(crapcdi.nrseqdig) + "'," + 
                 "dscuseve:'" +  STRING(crapcdi.dscusind) + "'," + 
                 "tpcuseve:'" +  STRING(2) + "'" + "~}".
        ELSE
            vetorcusto = vetorcusto + "," + "~{" +
                 "cdcuseve:'" +  STRING(crapcdi.nrseqdig) + "'," + 
                 "dscuseve:'" +  STRING(crapcdi.dscusind) + "'," + 
                 "tpcuseve:'" +  STRING(2) + "'" + "~}".
    END.
    
    RUN RodaJavaScript("var mcusto=new Array();mcusto=["  + vetorcusto + "]").

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaEventos w-html 
PROCEDURE CriaListaEventos :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE aux_tppartic AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_flgcompr AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_qtmaxtur AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_nrinscri AS INT  NO-UNDO.
    DEFINE VARIABLE aux_nrconfir AS INT  NO-UNDO.
    DEFINE VARIABLE aux_nrseqeve AS INT  NO-UNDO.
    DEFINE VARIABLE aux_nmevento AS CHAR NO-UNDO.
    DEFINE VARIABLE vetormes     AS CHAR EXTENT 12
        INITIAL ["Janeiro","Fevereiro","Março","Abril","Maio","Junho",
                 "Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"].
    
    IF NOT AVAIL gnpapgd THEN LEAVE.
    
    FOR EACH crapeap WHERE crapeap.idevento = INT(ab_unmap.aux_idevento)    AND 
                           crapeap.cdcooper = INT(ab_unmap.aux_cdcooper)    AND
                          (crapeap.cdagenci = INT(ab_unmap.cdagenci)        OR
                           crapeap.cdagenci = 0)                            AND
                           /*crapeap.idevento = 1                           AND*/
                           crapeap.dtanoage = INT(ab_unmap.aux_dtanoage)    AND
                           crapeap.flgevsel = YES                           NO-LOCK, 
       FIRST crapedp WHERE crapedp.cdevento = crapeap.cdevento              AND
                           crapedp.idevento = crapeap.idevento              AND
                           crapedp.cdcooper = crapeap.cdcooper              AND
                           crapedp.dtanoage = crapeap.dtanoage              NO-LOCK,
       EACH crapadp WHERE crapadp.idevento = crapeap.idevento              AND
                           crapadp.cdcooper = crapeap.cdcooper              AND
                           crapadp.cdagenci = crapeap.cdagenci              AND
                           crapadp.dtanoage = crapeap.dtanoage              AND
                           crapadp.cdevento = crapeap.cdevento              NO-LOCK
                           BREAK BY crapadp.cdagenci
                                 BY crapedp.nmevento
                                 BY crapadp.nrseqdig:

        FIND FIRST crapagp WHERE crapagp.idevento = INT(ab_unmap.aux_idevento)  AND
                                 crapagp.cdcooper = crapeap.cdcooper            AND
                                 crapagp.dtanoage = INT(ab_unmap.aux_dtanoage)  AND
                                 crapagp.cdagenci = crapeap.cdagenci            AND
                                 crapagp.idstagen = 5                           NO-LOCK NO-ERROR.
    
        
        IF NOT AVAIL crapagp AND ab_unmap.aux_idevento = "1" THEN NEXT. 
        
        ASSIGN aux_nrseqeve = IF crapadp.nrseqdig <> ? THEN crapadp.nrseqdig ELSE 0
               aux_nmevento = crapedp.nmevento.
                                                                                   
        IF  crapadp.dtinieve <> ?  THEN
            aux_nmevento = aux_nmevento + " - " + STRING(crapadp.dtinieve,"99/99/9999").
        ELSE
        IF  crapadp.nrmeseve <> 0  AND crapadp.nrmeseve <> ? THEN
            aux_nmevento = aux_nmevento + " - " + vetormes[crapadp.nrmeseve].
    
        IF  crapadp.dshroeve <> "" THEN
            aux_nmevento = aux_nmevento + " - " + crapadp.dshroeve.

        IF  vetorevento = "" THEN
            vetorevento = "~{" +
                 "cdagenci:'" +  STRING(crapeap.cdagenci) + "'," + 
                 "cdcooper:'" +  STRING(crapeap.cdcooper) + "'," +
                 "cdevento:'" +  STRING(crapeap.cdevento) + "'," +
                 "nmevento:'" +  STRING(aux_nmevento) + "'," +
                 "idstaeve:'" +  STRING(crapadp.idstaeve) + "'," +
                 "flgcompr:'" +  STRING(aux_flgcompr)     + "'," +
                 "qtmaxtur:'" +  STRING(aux_qtmaxtur)     + "'," +
                 "nrinscri:'" +  STRING(aux_nrinscri)     + "'," +
                 "nrconfir:'" +  STRING(aux_nrconfir)     + "'," +
                 "nrseqeve:'" +  STRING(aux_nrseqeve)     + "'," +
                 "tppartic:'" +  STRING(aux_tppartic) + "'" + "~}".
        ELSE
            vetorevento = vetorevento + "," + "~{" +
                 "cdagenci:'" +  STRING(crapeap.cdagenci) + "'," + 
                 "cdcooper:'" +  STRING(crapeap.cdcooper) + "'," +
                 "cdevento:'" +  STRING(crapeap.cdevento) + "'," +
                 "nmevento:'" +  STRING(aux_nmevento) + "'," +
                 "idstaeve:'" +  STRING(crapadp.idstaeve) + "'," +
                 "flgcompr:'" +  STRING(aux_flgcompr)     + "'," +
                 "qtmaxtur:'" +  STRING(aux_qtmaxtur)     + "'," +
                 "nrinscri:'" +  STRING(aux_nrinscri)     + "'," +
                 "nrconfir:'" +  STRING(aux_nrconfir)     + "'," +
                 "nrseqeve:'" +  STRING(aux_nrseqeve)     + "'," +
                 "tppartic:'" +  STRING(aux_tppartic) + "'" + "~}".
    END.
    
    RUN RodaJavaScript("var mevento=new Array();mevento=["  + vetorevento + "]").

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaPac w-html 
PROCEDURE CriaListaPac :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    {includes/wpgd0099.i ab_unmap.aux_dtanoage}
    
    RUN RodaJavaScript("var mpac=new Array();mpac=["  + vetorpac + "]"). 

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaPacAssemb w-html 
PROCEDURE CriaListaPacAssemb :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    {includes/wpgd0097.i}
    
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
    ("aux_cdagenci":U,"ab_unmap.aux_cdagenci":U,ab_unmap.aux_cdagenci:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdcooper":U,"ab_unmap.aux_cdcooper":U,ab_unmap.aux_cdcooper:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdcuseve":U,"ab_unmap.aux_cdcuseve":U,ab_unmap.aux_cdcuseve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cddopcao":U,"ab_unmap.aux_cddopcao":U,ab_unmap.aux_cddopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrseqeve":U,"ab_unmap.aux_nrseqeve":U,ab_unmap.aux_nrseqeve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsendurl":U,"ab_unmap.aux_dsendurl":U,ab_unmap.aux_dsendurl:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsretorn":U,"ab_unmap.aux_dsretorn":U,ab_unmap.aux_dsretorn:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dtanoage":U,"ab_unmap.aux_dtanoage":U,ab_unmap.aux_dtanoage:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idevento":U,"ab_unmap.aux_idevento":U,ab_unmap.aux_idevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lspermis":U,"ab_unmap.aux_lspermis":U,ab_unmap.aux_lspermis:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrdrowid":U,"ab_unmap.aux_nrdrowid":U,ab_unmap.aux_nrdrowid:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrseqdig":U,"ab_unmap.aux_nrseqdig":U,ab_unmap.aux_nrseqdig:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_stdopcao":U,"ab_unmap.aux_stdopcao":U,ab_unmap.aux_stdopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_tpcuseve":U,"ab_unmap.aux_tpcuseve":U,ab_unmap.aux_tpcuseve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("cdagenci":U,"ab_unmap.cdagenci":U,ab_unmap.cdagenci:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("cdcuseve":U,"ab_unmap.cdcuseve":U,ab_unmap.cdcuseve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nrseqeve":U,"ab_unmap.nrseqeve":U,ab_unmap.nrseqeve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dsobserv":U,"crapcrp.dsobserv":U,crapcrp.dsobserv:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dtanoage":U,"crapcrp.dtanoage":U,crapcrp.dtanoage:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dtmvtolt":U,"crapcrp.dtmvtolt":U,crapcrp.dtmvtolt:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("tpcuseve":U,"crapcrp.tpcuseve":U,crapcrp.tpcuseve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("vlcusrea":U,"crapcrp.vlcusrea":U,crapcrp.vlcusrea:HANDLE IN FRAME {&FRAME-NAME}).
END PROCEDURE.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-assign-record w-html 
PROCEDURE local-assign-record :
    
    DEFINE INPUT PARAMETER opcao AS CHARACTER.
    DEFINE VARIABLE tmp_cdevento AS INT.
    
    /* Instancia a BO para executar as procedures */
    RUN dbo/b1wpgd0022.p PERSISTENT SET h-b1wpgd0022.
    
    IF DAY(INPUT FRAME {&FRAME-NAME} crapcrp.dtmvtolt) = ? THEN
    DO:
        msg-erro = "Data de movimentação inválida. ".
        LEAVE.
    END.
    
    /* Se BO foi instanciada */

    IF VALID-HANDLE(h-b1wpgd0022) THEN
       DO:
          DO WITH FRAME {&FRAME-NAME}:
             IF opcao = "inclusao" THEN
                DO:
                    IF  ab_unmap.aux_tpcuseve = "1" THEN /*custo direto atribui o valor ao pa e ao evento*/
                        DO:
                            FIND FIRST crapadp WHERE
                                       crapadp.nrseqdig = INT(ab_unmap.nrseqeve) NO-LOCK NO-ERROR.
                                IF NOT AVAIL crapadp THEN NEXT.
                                  
                                 ASSIGN tmp_cdevento = crapadp.cdevento.
                        END.
                    ELSE  /* custo indireto não atribui o valor a um pa e nem a um evento específico*/
                        ASSIGN tmp_cdevento = 0
                               ab_unmap.nrseqeve = "0"
                               ab_unmap.cdagenci = "0".
                    
                    CREATE cratcrp.
                    ASSIGN
                           cratcrp.cdagenci = INT(ab_unmap.cdagenci)
                           cratcrp.cdcooper = INT(ab_unmap.aux_cdcooper)
                           cratcrp.cdcuseve = INT(ab_unmap.cdcuseve)
                           cratcrp.cdevento = tmp_cdevento
                           cratcrp.cdoperad = gnapses.cdoperad
                           cratcrp.dsobserv = INPUT crapcrp.dsobserv
                           cratcrp.dtanoage = INT(ab_unmap.aux_dtanoage)
                           cratcrp.dtmvtolt = INPUT crapcrp.dtmvtolt
                           cratcrp.idevento = INT(ab_unmap.aux_idevento)
                           cratcrp.tpcuseve = INT(ab_unmap.aux_tpcuseve)
                           cratcrp.vlcusrea = INPUT crapcrp.vlcusrea
                           cratcrp.nrseqeve = INT(ab_unmap.nrseqeve)
                           .
                    RUN inclui-registro IN h-b1wpgd0022(INPUT TABLE cratcrp, OUTPUT msg-erro, OUTPUT ab_unmap.aux_nrdrowid).
                END.
             ELSE  /* alteracao */
                DO:
                    /* cria a temp-table e joga o novo valor digitado para o campo */
                    
                    IF  ab_unmap.aux_tpcuseve = "1" THEN /*custo direto atribui o valor ao pa e ao evento*/
                        DO:
                            FIND FIRST crapadp WHERE
                                       crapadp.nrseqdig = INT(ab_unmap.nrseqeve) NO-LOCK NO-ERROR.
                                IF NOT AVAIL crapadp THEN NEXT.
                                  
                                 ASSIGN tmp_cdevento = crapadp.cdevento.
                        END.
                    ELSE  /* custo indireto não atribui o valor a um pa e nem a um evento específico*/
                        ASSIGN tmp_cdevento = 0
                               ab_unmap.nrseqeve = "0"
                               ab_unmap.cdagenci = "0".
                       
                    CREATE cratcrp.
                    BUFFER-COPY crapcrp TO cratcrp.
    
                    ASSIGN
                        cratcrp.cdagenci = INT(ab_unmap.cdagenci)
                        cratcrp.cdcooper = INT(ab_unmap.aux_cdcooper)
                        cratcrp.cdcuseve = INT(ab_unmap.cdcuseve)
                        cratcrp.cdevento = tmp_cdevento
                        cratcrp.cdoperad = gnapses.cdoperad
                        cratcrp.dsobserv = INPUT crapcrp.dsobserv
                        cratcrp.dtanoage = INT(ab_unmap.aux_dtanoage)
                        cratcrp.dtmvtolt = INPUT crapcrp.dtmvtolt
                        cratcrp.idevento = INT(ab_unmap.aux_idevento)
                        cratcrp.tpcuseve = INT(ab_unmap.aux_tpcuseve)
                        cratcrp.vlcusrea = INPUT crapcrp.vlcusrea
                        cratcrp.nrseqeve = INT(ab_unmap.nrseqeve)
                        .
                     
                    RUN altera-registro IN h-b1wpgd0022(INPUT TABLE cratcrp, OUTPUT msg-erro).
                END.    
          END. /* DO WITH FRAME {&FRAME-NAME} */
       
          /* "mata" a instância da BO */
          DELETE PROCEDURE h-b1wpgd0022 NO-ERROR.
       
       END. /* IF VALID-HANDLE(h-b1wpgd0022) */
      
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-delete-record w-html 
PROCEDURE local-delete-record :
    
/* Instancia a BO para executar as procedures */
    RUN dbo/b1wpgd0022.p PERSISTENT SET h-b1wpgd0022.
     
    /* Se BO foi instanciada */
    IF VALID-HANDLE(h-b1wpgd0022) THEN
       DO:
          CREATE cratcrp.
          BUFFER-COPY crapcrp TO cratcrp.
              
          RUN exclui-registro IN h-b1wpgd0022(INPUT TABLE cratcrp, OUTPUT msg-erro).
    
          /* "mata" a instância da BO */
          DELETE PROCEDURE h-b1wpgd0022 NO-ERROR.
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
FIND NEXT {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.



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
       ab_unmap.aux_tpcuseve    = GET-VALUE("aux_tpcuseve")
       ab_unmap.aux_cdcooper    = GET-VALUE("aux_cdcooper") 
       ab_unmap.aux_dtanoage    = GET-VALUE("aux_dtanoage")
       ab_unmap.cdcuseve        = GET-VALUE("cdcuseve")
       ab_unmap.cdagenci        = GET-VALUE("cdagenci")
       ab_unmap.nrseqeve        = GET-VALUE("nrseqeve").

RUN outputHeader.

{includes/wpgd0098.i}

ab_unmap.aux_cdcooper:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = aux_crapcop.

/* Se a cooperativa ainda não foi escolhida, pega a da sessão do usuário */
IF   INT(ab_unmap.aux_cdcooper) = 0   THEN
     ab_unmap.aux_cdcooper = STRING(gnapses.cdcooper).

/* Se o PA ainda não foi escolhido, pega o da sessão do usuário */
IF   INT(ab_unmap.cdagenci) = 0   THEN
     ab_unmap.cdagenci = STRING(gnapses.cdagenci).

FIND LAST gnpapgd WHERE gnpapgd.idevento = INT(ab_unmap.aux_idevento)   AND 
                        gnpapgd.cdcooper = INT(ab_unmap.aux_cdcooper)   AND 
                        gnpapgd.dtanonov = INT(ab_unmap.aux_dtanoage)   NO-LOCK NO-ERROR.

IF NOT AVAILABLE gnpapgd THEN
   DO:
      IF   ab_unmap.aux_dtanoage <> ""   THEN
           RUN RodaJavaScript("alert('Nao existe agenda para o ano (" + ab_unmap.aux_dtanoage + ") informado!');").

      FIND LAST gnpapgd WHERE gnpapgd.idevento = INT(ab_unmap.aux_idevento) AND 
                              gnpapgd.cdcooper = INT(ab_unmap.aux_cdcooper) NO-LOCK NO-ERROR.
   END.

IF AVAILABLE gnpapgd THEN
   DO:
       IF   ab_unmap.aux_dtanoage = ""   THEN
            ab_unmap.aux_dtanoage = STRING(gnpapgd.dtanoage).
       ELSE
            ab_unmap.aux_dtanoage = STRING(gnpapgd.dtanonov).
   END.
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
                            ELSE
                               DO:
                                  RUN local-assign-record ("alteracao").  
                                  IF msg-erro = "" THEN
                                     ASSIGN msg-erro-aux = 10. /* Solicitação realizada com sucesso */ 
                                  ELSE
                                     ASSIGN msg-erro-aux = 3. /* erros da validação de dados */
                               END.     
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
                                              ELSE
                                                  ASSIGN ab_unmap.aux_idevento = STRING({&SECOND-ENABLED-TABLE}.idevento)
                                                         ab_unmap.aux_dtanoage = STRING({&SECOND-ENABLED-TABLE}.dtanoage)
                                                         ab_unmap.aux_cdcooper = STRING({&SECOND-ENABLED-TABLE}.cdcooper)
                                                         ab_unmap.cdcuseve     = STRING({&SECOND-ENABLED-TABLE}.cdcuseve)
                                                         ab_unmap.cdagenci     = STRING({&SECOND-ENABLED-TABLE}.cdagenci)
                                                         ab_unmap.nrseqeve     = STRING({&SECOND-ENABLED-TABLE}.nrseqeve).
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

      IF msg-erro-aux = 10 OR (opcao <> "sa" AND opcao <> "ex" AND opcao <> "in") THEN
         RUN displayFields.

      RUN CriaListaCusto.

      IF INT(ab_unmap.aux_idevento) = 1 THEN
         RUN CriaListaPac.
      ELSE
         RUN CriaListaPacAssemb.

      RUN CriaListaEventos.
 
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
                DO:
                    RUN RodaJavaScript('alert("Atualizacao executada com sucesso.")'). 
                    RUN RodaJavaScript('TravaTudo();'). 
                END.
         
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
                           IF AVAIL  {&SECOND-ENABLED-TABLE} THEN
                           DO:
                              
                               ASSIGN ab_unmap.aux_idevento = STRING({&SECOND-ENABLED-TABLE}.idevento)
                                      ab_unmap.aux_dtanoage = STRING({&SECOND-ENABLED-TABLE}.dtanoage)
                                      ab_unmap.aux_cdcooper = STRING({&SECOND-ENABLED-TABLE}.cdcooper)
                                      ab_unmap.cdcuseve     = STRING({&SECOND-ENABLED-TABLE}.cdcuseve)
                                      ab_unmap.cdagenci     = STRING({&SECOND-ENABLED-TABLE}.cdagenci)
                                      ab_unmap.nrseqeve     = STRING({&SECOND-ENABLED-TABLE}.nrseqeve).

                               /* Recarrega a cooperativa de acordo com o registro selecionado */
                               SET-USER-FIELD("aux_idevento",STRING(ab_unmap.aux_idevento)).
                               aux_crapcop = "".
                               {includes/wpgd0098.i}
                               ab_unmap.aux_cdcooper:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = aux_crapcop.

                               FIND LAST gnpapgd WHERE gnpapgd.idevento = INT(ab_unmap.aux_idevento)    AND 
                                                       gnpapgd.cdcooper = INT(ab_unmap.aux_cdcooper)    AND 
                                                       gnpapgd.dtanonov = INT(ab_unmap.aux_dtanoage) 
                                                       NO-LOCK NO-ERROR.
                                      
                           END.
                       END.  
                    ELSE                    
                    RUN PosicionaNoPrimeiro.

                    RUN CriaListaEventos.
                    RUN CriaListaCusto.

                    IF INT(ab_unmap.aux_idevento) = 1 THEN
                       RUN CriaListaPac.
                    ELSE
                       RUN CriaListaPacAssemb.

                    RUN displayFields.
                    RUN enableFields.
                    RUN outputFields.
                    RUN RodaJavaScript('top.frcod.FechaZoom()').
                    RUN RodaJavaScript('CarregaPrincipal()').

                    
                    
                    IF GET-VALUE("LinkRowid") = "" THEN
                       DO:
                           RUN RodaJavaScript('LimparCampos();').
                           RUN RodaJavaScript('top.frcod.Incluir();').
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

