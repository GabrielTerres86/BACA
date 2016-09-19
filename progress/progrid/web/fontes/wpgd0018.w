/*...............................................................................

Altera��es: 19/11/2009 - Alterado tamanho da variavel aux_ttevento para 
                         ">>>,>>9.99" ;
                       - Na exclusao do evento, alterado para nao excluir 
                         registros de anos diferentes do ano que foi selecionado 
                         (Elton).
						 
			05/06/2012 - Adapta��o dos fontes para projeto Oracle. Alterado
						 busca na gnapses de CONTAINS para MATCHES (Guilherme Maba).
                         
            11/11/2014 - Ajustado procedure CriaListaEventos para listar os eventos
                         encontrados no for each e n�o buscar todos. (Lucas R. #220033)
                         
            19/11/2014 - Incluir query para quebra de pagina na procedure CriaListaEventos
                         (Lucas R.)             
                     
            16/12/2014 - Adicionado GET FIRST q_custos na procedure CriaListaEventos, 
                         pois estava repitindo o primeiro registro (Lucas R. #233615)
...............................................................................*/

&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD aux_cdcooper AS CHARACTER 
       FIELD aux_carregar AS CHARACTER
       FIELD aux_reginils AS CHARACTER
       FIELD aux_regfimls AS CHARACTER
       FIELD aux_contarow AS INT
       FIELD aux_maxrows  AS INT
       FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_cdevento AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dtanoage AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_idecusto AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_idexclui AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lsqtdbri AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lsqtdkit AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lstcusto AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lstnovos AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lsvlrbri AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lsvlrkit AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_vlcusind AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_vlunibri AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_vlunikit AS CHARACTER FORMAT "X(256)":U 
       FIELD pagina AS CHARACTER FORMAT "X(256)":U .

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
DEFINE VARIABLE NmeDoPrograma         AS CHARACTER INITIAL ["wpgd0018.w"].

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

/*** Declara��o de BOs ***/
DEFINE VARIABLE h-b1wpgd0018          AS HANDLE                         NO-UNDO.
DEFINE VARIABLE h-b1wpgd0018d         AS HANDLE                         NO-UNDO.

/*** Temp Tables ***/
DEFINE TEMP-TABLE cratcdp             LIKE crapcdp.
DEFINE TEMP-TABLE cratcdi             LIKE crapcdi.

DEFINE VARIABLE vetorevento           AS CHAR                           NO-UNDO.
DEFINE VARIABLE aux_crapcop           AS CHAR                           NO-UNDO.
DEFINE VARIABLE vetorcusto            AS CHAR                           NO-UNDO.
DEFINE VARIABLE vetorpac              AS CHAR                           NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE fontes/wpgd0018.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS  
&Scoped-define ENABLED-TABLES ab_unmap crapcdp
&Scoped-define FIRST-ENABLED-TABLE ab_unmap
&Scoped-define SECOND-ENABLED-TABLE crapcdp
&Scoped-Define ENABLED-OBJECTS ab_unmap.aux_vlunibri ab_unmap.aux_vlunikit ~
ab_unmap.aux_idecusto ab_unmap.aux_lstnovos ab_unmap.aux_lsqtdbri ~
ab_unmap.aux_lsqtdkit ab_unmap.aux_lsvlrbri ab_unmap.aux_lsvlrkit ~
ab_unmap.aux_lstcusto ab_unmap.aux_vlcusind ab_unmap.pagina ~
ab_unmap.aux_cdevento ab_unmap.aux_cdcooper ab_unmap.aux_cddopcao ~
ab_unmap.aux_dsendurl ab_unmap.aux_dsretorn ab_unmap.aux_idevento ~
ab_unmap.aux_idexclui ab_unmap.aux_lspermis ab_unmap.aux_nrdrowid ~
ab_unmap.aux_stdopcao ab_unmap.aux_dtanoage ab_unmap.aux_carregar ~
ab_unmap.aux_reginils ab_unmap.aux_regfimls ab_unmap.aux_contarow ab_unmap.aux_maxrows
&Scoped-Define DISPLAYED-FIELDS 
&Scoped-define DISPLAYED-TABLES ab_unmap crapcdp
&Scoped-define FIRST-DISPLAYED-TABLE ab_unmap
&Scoped-define SECOND-DISPLAYED-TABLE crapcdp
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.aux_vlunibri ~
ab_unmap.aux_vlunikit ab_unmap.aux_idecusto ab_unmap.aux_lstnovos ~
ab_unmap.aux_lsqtdbri ab_unmap.aux_lsqtdkit ab_unmap.aux_lsvlrbri ~
ab_unmap.aux_lsvlrkit ab_unmap.aux_lstcusto ab_unmap.aux_vlcusind ~
ab_unmap.pagina ab_unmap.aux_cdevento ab_unmap.aux_cdcooper ~
ab_unmap.aux_cddopcao ab_unmap.aux_dsendurl ab_unmap.aux_dsretorn ~
ab_unmap.aux_idevento ab_unmap.aux_idexclui ab_unmap.aux_lspermis ~
ab_unmap.aux_nrdrowid ab_unmap.aux_stdopcao ab_unmap.aux_dtanoage ~
ab_unmap.aux_carregar ab_unmap.aux_reginils ab_unmap.aux_regfimls ab_unmap.aux_contarow ab_unmap.aux_maxrows

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     ab_unmap.aux_vlunibri AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_vlunikit AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_idecusto AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_lstnovos AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_lsqtdbri AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_lsqtdkit AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_lsvlrbri AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_lsvlrkit AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_lstcusto AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_vlcusind AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.pagina AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cdevento AT ROW 1 COL 1 HELP
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
     ab_unmap.aux_stdopcao AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_dtanoage AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_carregar AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_reginils AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_regfimls AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.aux_contarow AT ROW 1 COL 1 HELP
          "" NO-LABEL 
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.aux_maxrows AT ROW 1 COL 1 HELP
          "" NO-LABEL 
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 52.8 BY 17.76.


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
          FIELD aux_cdevento AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dtanoage AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_idecusto AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_idexclui AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lsqtdbri AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lsqtdkit AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lstcusto AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lstnovos AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lsvlrbri AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lsvlrkit AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_vlcusind AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_vlunibri AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_vlunikit AS CHARACTER FORMAT "X(256)":U 
          FIELD pagina AS CHARACTER FORMAT "X(256)":U 
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW w-html ASSIGN
         HEIGHT             = 17.76
         WIDTH              = 52.8.
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
/* SETTINGS FOR FILL-IN ab_unmap.aux_cdevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dsendurl IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dsretorn IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dtanoage IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN ab_unmap.aux_idecusto IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_idevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_idexclui IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lspermis IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lsqtdbri IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lsqtdkit IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lstcusto IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lstnovos IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lsvlrbri IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lsvlrkit IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nrdrowid IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_stdopcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_vlcusind IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_vlunibri IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_vlunikit IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.pagina IN FRAME Web-Frame
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaCusto w-html 
PROCEDURE CriaListaCusto :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE VARIABLE aux_flgescol AS LOG NO-UNDO.

FOR EACH crapcdp WHERE crapcdp.idevento = INT(ab_unmap.aux_idevento)        AND
                       crapcdp.cdcooper = INT(ab_unmap.aux_cdcooper)        AND
                       crapcdp.dtanoage = INT(ab_unmap.aux_dtanoage)        AND
                       crapcdp.tpcuseve = 2 /* somente custos indiretos */  NO-LOCK:

    /* Seguran�a de Cooperativas */
    IF gnapses.cdcooper <> 0 AND gnapses.cdcooper <> crapcdp.cdcooper  AND gnapses.nvoperad <> 0 THEN NEXT.

    FIND FIRST crapcdi WHERE crapcdi.nrseqdig = crapcdp.cdcuseve NO-LOCK NO-ERROR.
    
    IF NOT AVAIL crapcdi THEN NEXT. /* rafael */
    

    IF  vetorcusto = "" THEN
        vetorcusto =
                      "~{" + "idcusto:"    + "'" + string(crapcdi.nrseqdig)
                           + "',cdcooper:" + "'" + STRING(crapcdp.cdcooper)
                           + "',nmcusto:"  + "'" + TRIM(string(crapcdi.dscusind))
                           + "',vlcusto:"  + "'" + STRING(crapcdp.vlcuseve, "->>,>>9.99")
                           + "',flgescol:"  + "'" + STRING(aux_flgescol,"yes/no") + "'~}".
    ELSE
       vetorcusto = vetorcusto + "," + 
                      "~{" + "idcusto:"    + "'" + string(crapcdi.nrseqdig)
                           + "',cdcooper:" + "'" + STRING(crapcdp.cdcooper)
                           + "',nmcusto:"  + "'" + TRIM(string(crapcdi.dscusind))
                           + "',vlcusto:"  + "'" + STRING(crapcdp.vlcuseve, "->>,>>9.99")
                           + "',flgescol:"  + "'" + STRING(aux_flgescol,"yes/no") + "'~}".

END. /* for each */

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
DEF VAR aux_ttevento AS DEC                          NO-UNDO.
DEF VAR aux_qtpagina AS INT  INIT 100                NO-UNDO.
DEF VAR aux_qtregist AS INT  INIT 0                  NO-UNDO.
DEF VAR aux_cdeveant AS INT                          NO-UNDO.
DEF VAR aux_cdcuseveant AS INTE                      NO-UNDO.
DEF VAR aux_dados    AS CHAR                         NO-UNDO.
  
DEF QUERY q_custos FOR crapcdp SCROLLING.

  /* Busca o registro de par�metro da agenda */
  IF NOT AVAIL gnpapgd THEN LEAVE.

  OPEN QUERY q_custos 
       FOR EACH crapcdp WHERE crapcdp.cdagenci = 0                           AND
                              crapcdp.cdcooper = INT(ab_unmap.aux_cdcooper)  AND
                              crapcdp.idevento = INT(ab_unmap.aux_idevento)  AND
                              crapcdp.dtanoage = INT(ab_unmap.aux_dtanoage)   
                              NO-LOCK 
                              INDEXED-REPOSITION MAX-ROWS aux_qtpagina.
  
   ASSIGN aux_cdeveant = 0
          aux_cdcuseveant = 0.

   GET FIRST q_custos.

   IF  ab_unmap.aux_carregar = "proximos"   THEN
       DO: 
           REPOSITION q_custos TO ROWID TO-ROWID(ab_unmap.aux_regfimls).
           REPOSITION q_custos FORWARDS aux_qtpagina.
           REPOSITION q_custos TO ROWID TO-ROWID(ab_unmap.aux_regfimls).
           
       END.
   ELSE 
   IF  ab_unmap.aux_carregar = "anteriores"   THEN
       DO: 
           REPOSITION q_custos TO ROWID TO-ROWID(ab_unmap.aux_reginils).
           REPOSITION q_custos BACKWARDS aux_qtpagina - 1.
           
       END.

    ASSIGN ab_unmap.aux_maxrows  = 100
           ab_unmap.aux_contarow = 0. 
    
    /* Verifica se a Query abriu */
    IF  NUM-RESULTS("q_custos") <> ?   THEN
        DO  aux_qtregist = 1 TO aux_qtpagina:
                
            GET NEXT q_custos.

            IF  AVAIL crapcdp THEN
                DO: 
                    IF  aux_qtregist = 1   THEN
                        ab_unmap.aux_reginils = STRING(CURRENT-RESULT-ROW("q_custos")).

                    ASSIGN ab_unmap.aux_regfimls = STRING(ROWID(crapcdp)).
                
                    /* Seguran�a de Cooperativas */
                    IF  gnapses.cdcooper <> 0                AND 
                        gnapses.cdcooper <> crapcdp.cdcooper AND 
                        gnapses.nvoperad <> 0 THEN
                        NEXT.

                      FIND FIRST crapedp WHERE 
                                 crapedp.cdcooper = crapcdp.cdcooper AND
                                 crapedp.dtanoage = crapcdp.dtanoage AND
                                 crapedp.idevento = crapcdp.idevento AND
                                 crapedp.cdevento = crapcdp.cdevento          
                                 NO-LOCK NO-ERROR.
    
                      /* Se n�o achou o evento, pula pro pr�ximo */
                      IF  NOT AVAIL crapedp THEN
                          NEXT.

                      IF  aux_cdeveant <> crapcdp.cdevento AND  
                          aux_cdcuseveant <> crapcdp.cdcuseve  THEN
                          DO:
                               ab_unmap.aux_contarow = ab_unmap.aux_contarow + 1.

                              aux_dados = "~{" + 
                                          "cdcooper:'" + STRING(crapcdp.cdcooper) + "'," +
                                          "cdevento:'" + STRING(crapcdp.cdevento) + "'," +
                                          "nmevento:'" + STRING(crapedp.nmevento) + "'," + 
                                          "nrdrowid:'" +  STRING(ROWID(crapcdp))  + "'" + "~}".
                              
                              ASSIGN aux_cdeveant = crapcdp.cdevento
                                     aux_cdcuseveant = crapcdp.cdcuseve.

                              IF  vetorevento = "" THEN
                                   vetorevento = aux_dados.
                               ELSE
                                   vetorevento = vetorevento + "," + aux_dados.
                          END.
                END.
        END.
    
    CLOSE QUERY q_custos.

   RUN RodaJavaScript("var mevento=new Array(" + vetorevento + ");").  
   /*RUN RodaJavaScript("var mevento=new Array();mevento=["  + vetorevento + "]"). */

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
    
    DEFINE VARIABLE aux_qtcuskit AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_vlcuskit AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_qtcusbri AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_vlcusbri AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_vlcustot AS DEC  NO-UNDO.

    /* Se nao tiver parametrizacao da cooperativa, nao carrega nada */
    IF   NOT AVAIL gnpapgd   THEN
         DO:
             RUN RodaJavaScript("var mpac=new Array();mpac=[]").
             LEAVE.
         END.

    /* Verificar se j� possui custos de kits e brindes lan�ados */
    FOR EACH crapage WHERE crapage.cdcooper = INT(ab_unmap.aux_cdcooper)   AND
                           crapage.insitage = 1 /* Ativo */                NO-LOCK 
                           BY crapage.nmresage:
    
        /* Seguran�a de PAs */
        IF   (gnapses.nvoperad = 1    OR
              gnapses.nvoperad = 2)                  AND 
              gnapses.cdagenci <> crapage.cdagenci   THEN
              NEXT.
        

        ASSIGN aux_qtcuskit = "0"
               aux_vlcuskit = "0"
               aux_qtcusbri = "0"
               aux_vlcusbri = "0"
               aux_vlcustot = 0.
                
        /* Busca os custos de Novos Socios */
        FOR EACH crapcdp WHERE crapcdp.idevento = INT(ab_unmap.aux_idevento)    AND
                               crapcdp.cdcooper = crapage.cdcooper              AND
                               crapcdp.cdagenci = crapage.cdagenci              AND
                               crapcdp.dtanoage = INT(ab_unmap.aux_dtanoage)    AND
                               crapcdp.tpcuseve = 3                             NO-LOCK:

            CASE crapcdp.cdcuseve:

                /* Kits */
                WHEN 1 THEN
                DO:
                    ASSIGN aux_qtcuskit = STRING(crapcdp.qtditens, "->>>,>>9") 
                           aux_vlcuskit = STRING(crapcdp.vlcuseve, "->>>,>>9.99")
                           aux_vlcustot = aux_vlcustot + crapcdp.vlcuseve.
                    /* Calcula o valor unit�rio */
                    IF crapcdp.qtditens * crapcdp.vlcuseve <> 0 THEN
                        ASSIGN ab_unmap.aux_vlunikit = STRING(crapcdp.vlcuseve / crapcdp.qtditens, "->>>,>>9.99").
                    
                END.

                /* Brindes */
                WHEN 2 THEN
                DO:
                    ASSIGN aux_qtcusbri = STRING(crapcdp.qtditens, "->>>,>>9") 
                           aux_vlcusbri = STRING(crapcdp.vlcuseve, "->>>,>>9.99")
                           aux_vlcustot = aux_vlcustot + crapcdp.vlcuseve.
                    /* Calcula o valor unit�rio */
                    IF crapcdp.qtditens * crapcdp.vlcuseve <> 0 THEN
                        ASSIGN ab_unmap.aux_vlunibri = STRING(crapcdp.vlcuseve / crapcdp.qtditens, "->>>,>>9.99").
                END.

            END CASE.

        END.
        
        IF   vetorpac = ""   THEN
             vetorpac = "~{" + "cdcooper:"    + "'" + TRIM(string(crapage.cdcooper))
                             + "',cdagenci:"  + "'" + TRIM(string(crapage.cdagenci))
                             + "',qtcuskit:"  + "'" + string(aux_qtcuskit)
                             + "',vlcuskit:"  + "'" + string(aux_vlcuskit)
                             + "',qtcusbri:"  + "'" + string(aux_qtcusbri)
                             + "',vlcusbri:"  + "'" + string(aux_vlcusbri)
                             + "',vlcustot:"  + "'" + STRING(aux_vlcustot, "->>>,>>9.99")
                             + "',nmresage:"  + "'" + crapage.nmresage + "'~}".
        ELSE
             vetorpac = vetorpac + "," + 
                        "~{" + "cdcooper:"    + "'" + TRIM(string(crapage.cdcooper))
                             + "',cdagenci:"  + "'" + TRIM(string(crapage.cdagenci))
                             + "',qtcuskit:"  + "'" + string(aux_qtcuskit)
                             + "',vlcuskit:"  + "'" + string(aux_vlcuskit)
                             + "',qtcusbri:"  + "'" + string(aux_qtcusbri)
                             + "',vlcusbri:"  + "'" + string(aux_vlcusbri)
                             + "',vlcustot:"  + "'" + STRING(aux_vlcustot, "->>>,>>9.99")
                             + "',nmresage:"  + "'" + crapage.nmresage + "'~}".
    END.

    RUN RodaJavaScript("var mpac=new Array();mpac=["  + vetorpac + "]").

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ExcluiEvento w-html 
PROCEDURE ExcluiEvento :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEF VAR aux_msgderro AS CHAR NO-UNDO.

    /* Instancia a BO para executar as procedures */
    RUN dbo/b1wpgd0018.p PERSISTENT SET h-b1wpgd0018.

    IF NOT AVAIL gnpapgd THEN
    DO:
        msg-erro = "Erro com os par�metros da agenda. ".
        LEAVE.
    END.
 
    /* Se BO foi instanciada */
    IF VALID-HANDLE(h-b1wpgd0018) THEN
    DO:

        /* procura se o Evento j� foi criado para a Cooperativa, no Progrid */
        FIND FIRST crapedp WHERE crapedp.cdcooper = INT(ab_unmap.aux_cdcooper)  AND
                                 crapedp.cdevento = INT(ab_unmap.aux_cdevento)  AND
                                 crapedp.idevento = INT(aux_idevento)           AND
                                 crapedp.dtanoage = INT(ab_unmap.aux_dtanoage)  NO-LOCK NO-ERROR.
    

        IF AVAIL crapedp AND crapedp.idevento = 1 THEN
        DO:
            ASSIGN msg-erro = msg-erro + "Evento j� utilizado na sele��o das sugest�es. Exclus�o n�o permitida".
        END.
        ELSE
        DO:
            FOR EACH crapcdp WHERE STRING(crapcdp.cdevento) = ab_unmap.aux_cdevento         AND
                                   crapcdp.dtanoage         = INT(ab_unmap.aux_dtanoage)    AND
                                   crapcdp.idevento         = INT(aux_idevento)             AND
                                   crapcdp.cdcooper         = INT(ab_unmap.aux_cdcooper)    NO-LOCK:
        
                FIND FIRST cratcdp NO-ERROR.
                IF AVAIL cratcdp THEN DELETE cratcdp.
                
                CREATE cratcdp.
                BUFFER-COPY crapcdp TO cratcdp.
                    
                RUN exclui-registro IN h-b1wpgd0018(INPUT TABLE cratcdp, OUTPUT aux_msgderro).
        
                msg-erro = msg-erro + aux_msgderro.
        
            END. /* FOR EACH crapcdp */
        END.
  
       /* "mata" a inst�ncia da BO */
       DELETE PROCEDURE h-b1wpgd0018 NO-ERROR.
    END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ExCusto w-html 
PROCEDURE ExCusto :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

/* Instancia a BO para executar as procedures */
RUN dbo/b1wpgd0018.p PERSISTENT SET h-b1wpgd0018.

/* Se BO foi instanciada */
IF VALID-HANDLE(h-b1wpgd0018) THEN
   DO:
      DO WITH FRAME {&FRAME-NAME}:

              FOR EACH cratcdp:
                  DELETE cratcdp NO-ERROR.
              END.

              CREATE cratcdp.
              ASSIGN cratcdp.cdagenci = 0
                     cratcdp.cdcooper = INT(ab_unmap.aux_cdcooper)
                     cratcdp.cdcuseve = INT(ab_unmap.aux_idecusto)
                     cratcdp.cdevento = ?
                     cratcdp.dtanoage = INT(INPUT ab_unmap.aux_dtanoage)
                     cratcdp.idevento = INT(ab_unmap.aux_idevento)
                     cratcdp.tpcuseve = 2 /* Este programa s� lan�a custos indiretos */.

              RUN exclui-registro IN h-b1wpgd0018(INPUT TABLE cratcdp, OUTPUT msg-erro).

              
              ASSIGN ab_unmap.aux_lstcusto = ""
                     ab_unmap.aux_vlcusind = "".

      END. /* DO WITH FRAME {&FRAME-NAME} */
   
      /* "mata" a inst�ncia da BO */
      DELETE PROCEDURE h-b1wpgd0018 NO-ERROR.
   
   END. /* IF VALID-HANDLE(h-b1wpgd0018e) */

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
    ("aux_idecusto":U,"ab_unmap.aux_idecusto":U,ab_unmap.aux_idecusto:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idevento":U,"ab_unmap.aux_idevento":U,ab_unmap.aux_idevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idexclui":U,"ab_unmap.aux_idexclui":U,ab_unmap.aux_idexclui:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lspermis":U,"ab_unmap.aux_lspermis":U,ab_unmap.aux_lspermis:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lsqtdbri":U,"ab_unmap.aux_lsqtdbri":U,ab_unmap.aux_lsqtdbri:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lsqtdkit":U,"ab_unmap.aux_lsqtdkit":U,ab_unmap.aux_lsqtdkit:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lstcusto":U,"ab_unmap.aux_lstcusto":U,ab_unmap.aux_lstcusto:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lstnovos":U,"ab_unmap.aux_lstnovos":U,ab_unmap.aux_lstnovos:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lsvlrbri":U,"ab_unmap.aux_lsvlrbri":U,ab_unmap.aux_lsvlrbri:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lsvlrkit":U,"ab_unmap.aux_lsvlrkit":U,ab_unmap.aux_lsvlrkit:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrdrowid":U,"ab_unmap.aux_nrdrowid":U,ab_unmap.aux_nrdrowid:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_stdopcao":U,"ab_unmap.aux_stdopcao":U,ab_unmap.aux_stdopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_vlcusind":U,"ab_unmap.aux_vlcusind":U,ab_unmap.aux_vlcusind:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_vlunibri":U,"ab_unmap.aux_vlunibri":U,ab_unmap.aux_vlunibri:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_vlunikit":U,"ab_unmap.aux_vlunikit":U,ab_unmap.aux_vlunikit:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("pagina":U,"ab_unmap.pagina":U,ab_unmap.pagina:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_carregar":U,"ab_unmap.aux_carregar":U,ab_unmap.aux_carregar:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_reginils":U,"ab_unmap.aux_reginils":U,ab_unmap.aux_reginils:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_regfimls":U,"ab_unmap.aux_regfimls":U,ab_unmap.aux_regfimls:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_contarow":U,"ab_unmap.aux_contarow":U,ab_unmap.aux_contarow:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_maxrows":U,"ab_unmap.aux_maxrows":U,ab_unmap.aux_maxrows:HANDLE IN FRAME {&FRAME-NAME}).
END PROCEDURE.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-assign-record w-html 
PROCEDURE local-assign-record :
DEFINE INPUT PARAMETER opcao AS CHARACTER.

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
                /* cria a temp-table e joga o novo valor digitado para o campo */
                CREATE cratcdp.
                BUFFER-COPY crapcdp TO cratcdp.
                RUN altera-registro IN h-b1wpgd0018(INPUT TABLE cratcdp, OUTPUT msg-erro).
            END.    
      END. /* DO WITH FRAME {&FRAME-NAME} */
   
      /* "mata" a inst�ncia da BO */
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

      /* "mata" a inst�ncia da BO */
      DELETE PROCEDURE h-b1wpgd0018 NO-ERROR.
   END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-display-fields w-html 
PROCEDURE local-display-fields :
RUN displayFields.

/* Busca o registro de par�metro da agenda */

IF NOT AVAIL gnpapgd THEN LEAVE.

ASSIGN
    ab_unmap.aux_dtanoage:SCREEN-VALUE IN FRAME {&FRAME-NAME} = STRING(ab_unmap.aux_dtanoage).

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
               RUN RodaJavaScript("alert('Este j� � o primeiro registro.')"). 
               
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

/* N�o traz inicialmente nenhum registro */ 
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
               RUN RodaJavaScript("alert('Este j� � o �ltimo registro.')").

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
   Nome: includes/webreq.i - Vers�o WebSpeed 2.1
  Autor: B&T/Solusoft
 Fun��o: Processo de requisi��o web p/ cadastros simples na web - Vers�o WebSpeed 3.0
  Notas: Este � o procedimento principal onde ter� as requisi��es GET e POST.
         GET - � ativa quando o formul�rio � chamado pela 1a vez
         POST - Ap�s o get somente ocorrer� POST no formul�rio      
         Caso seja necess�rio custimiz�-lo para algum programa espec�fico 
         Favor c�piar este procedimento para dentro do procedure process-web-requeste 
         fa�a l� altera��es necess�rias.

Altera��es: 10/12/2008 - Melhoria de performance para a tabela gnapses (Evandro).

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
       ab_unmap.aux_cdevento    = GET-VALUE("aux_cdevento")
       ab_unmap.aux_cdcooper    = GET-VALUE("aux_cdcooper")
       ab_unmap.aux_vlcusind    = GET-VALUE("aux_vlcusind")
       ab_unmap.aux_lstcusto    = GET-VALUE("aux_lstcusto")
       ab_unmap.aux_lstnovos    = GET-VALUE("aux_lstnovos")
       ab_unmap.aux_lsqtdkit    = GET-VALUE("aux_lsqtdkit")
       ab_unmap.aux_lsvlrkit    = GET-VALUE("aux_lsvlrkit")
       ab_unmap.aux_lsqtdbri    = GET-VALUE("aux_lsqtdbri")
       ab_unmap.aux_lsvlrbri    = GET-VALUE("aux_lsvlrbri")
       ab_unmap.pagina          = GET-VALUE("pagina")
       ab_unmap.aux_idecusto    = GET-VALUE("aux_idecusto")
       ab_unmap.aux_vlunikit    = GET-VALUE("aux_vlunikit")
       ab_unmap.aux_vlunibri    = GET-VALUE("aux_vlunibri")
       ab_unmap.aux_dtanoage    = GET-VALUE("aux_dtanoage")
       ab_unmap.aux_carregar    = GET-VALUE("aux_carregar")
       ab_unmap.aux_reginils    = GET-VALUE("aux_reginils")
       ab_unmap.aux_regfimls    = GET-VALUE("aux_regfimls")
       ab_unmap.aux_contarow    = INT(GET-VALUE("aux_contarow"))
       ab_unmap.aux_maxrows     = INT(GET-VALUE("aux_maxrows")).

RUN outputHeader.

{includes/wpgd0098.i}

ASSIGN
    ab_unmap.aux_cdcooper:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = aux_crapcop.

/* Se a cooperativa ainda n�o foi escolhida, pega a da sess�o do usu�rio */
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

/* m�todo POST */
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
                               ASSIGN msg-erro-aux = 3. /* erros da valida��o de dados */
                            ELSE 
                            DO:
                               ASSIGN 
                                   msg-erro-aux = 10
                                   ab_unmap.aux_stdopcao = "al".
                               FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) EXCLUSIVE-LOCK NO-WAIT NO-ERROR.

                               IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                                  IF LOCKED {&SECOND-ENABLED-TABLE} THEN
                                     DO:
                                         ASSIGN msg-erro-aux = 1. /* registro em uso por outro usu�rio */  
                                         FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                                     END.
                                  ELSE
                                     DO: 
                                         ASSIGN msg-erro-aux = 2. /* registro n�o existe */
                                         RUN PosicionaNoSeguinte.
                                     END.

                            END.
                        END.  /* fim inclusao */
                    ELSE     /* altera��o */ 
                        DO: 
                            FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) EXCLUSIVE-LOCK NO-WAIT NO-ERROR.

                            IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                               IF LOCKED {&SECOND-ENABLED-TABLE} THEN
                                  DO:
                                      ASSIGN msg-erro-aux = 1. /* registro em uso por outro usu�rio */  
                                      FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                                  END.
                               ELSE
                                  DO: 
                                      ASSIGN msg-erro-aux = 2. /* registro n�o existe */
                                      RUN PosicionaNoSeguinte.
                                  END.
                            ELSE
                               DO:
                                  RUN local-assign-record ("alteracao").  
                                  IF msg-erro = "" THEN
                                     ASSIGN msg-erro-aux = 10. /* Solicita��o realizada com sucesso */ 
                                  ELSE
                                     ASSIGN msg-erro-aux = 3. /* erros da valida��o de dados */
                               END.     
                        END. /* fim altera��o */
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

                    /* busca o pr�ximo registro para fazer o reposicionamento */
                    FIND NEXT {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.

                    IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                       ASSIGN aux_nrdrowid-auxiliar = STRING(ROWID({&SECOND-ENABLED-TABLE})).
                    ELSE
                       DO:
                           /* nao encontrou pr�ximo registro ent�o procura pelo registro anterior para o reposicionamento */
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
                              ASSIGN msg-erro-aux = 1. /* registro em uso por outro usu�rio */ 
                              FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                          END.
                       ELSE
                          ASSIGN msg-erro-aux = 2. /* registro n�o existe */
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
                                          
                                       ASSIGN msg-erro-aux = 10. /* Solicita��o realizada com sucesso */ 
                                   END.
                                ELSE
                                   ASSIGN msg-erro-aux = 3. /* Exclusao rejeitada */ 
                             END.
                          ELSE
                             ASSIGN msg-erro-aux = 3. /* erros da valida��o de dados */
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

           WHEN "exe" THEN /* exclui evento */
           DO:
              RUN ExcluiEvento.  
               IF msg-erro = "" THEN
                  ASSIGN msg-erro-aux = 10. /* Solicita��o realizada com sucesso */ 
               ELSE
                  ASSIGN msg-erro-aux = 3. /* erros da valida��o de dados */
           END.

           WHEN "exc" THEN /* exclui custo */
           DO:
              RUN ExCusto.  
               IF msg-erro = "" THEN
                  ASSIGN msg-erro-aux = 10. /* Solicita��o realizada com sucesso */ 
               ELSE
                  ASSIGN msg-erro-aux = 3. /* erros da valida��o de dados */
           END.

           WHEN "si" THEN DO:
               RUN SalvaIndiretos.

               IF msg-erro = "" THEN
                  ASSIGN msg-erro-aux = 10. /* Solicita��o realizada com sucesso */ 
               ELSE
                  ASSIGN msg-erro-aux = 3. /* erros da valida��o de dados */
           END.

           WHEN "sn" THEN DO:
                   
               RUN SalvaNovos.

               IF msg-erro = "" THEN
                  ASSIGN msg-erro-aux = 10. /* Solicita��o realizada com sucesso */ 
               ELSE
                  ASSIGN msg-erro-aux = 3. /* erros da valida��o de dados */
           END.
    
      END CASE.

      RUN CriaListaEventos.
      RUN CriaListaCusto.
      RUN CriaListaPac.
     
      IF msg-erro-aux = 10 OR (opcao <> "sa" AND opcao <> "ex" AND opcao <> "in") THEN
         /*RUN displayFields.*/
          RUN local-display-fields.
 
      RUN enableFields.
      RUN outputFields.

      CASE msg-erro-aux:
           WHEN 1 THEN
                DO:
                    ASSIGN v-qtdeerro      = 1
                           v-descricaoerro = 'Registro esta em uso por outro usu�rio. Solicita��o n�o pode ser executada. Espere alguns instantes e tente novamente.'.

                    RUN RodaJavaScript(' top.frames[0].MostraResultado(' + STRING(v-qtdeerro) + ',"'+ v-descricaoerro + '"); ').
                END.

           WHEN 2 THEN
                RUN RodaJavaScript(" top.frames[0].MostraMsg('Registro foi exclu�do. Solicita��o n�o pode ser executada.')").
      
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

   END. /* Fim do m�todo POST */
ELSE /* M�todo GET */ 
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

                    RUN CriaListaEventos.
                    RUN CriaListaCusto.
                    RUN CriaListaPac.

                    /*RUN displayFields.*/
                    RUN local-display-fields.
                    RUN enableFields.
                    RUN outputFields.
                    RUN RodaJavaScript('top.frcod.FechaZoom()').
                    RUN RodaJavaScript('CarregaPrincipal()').
                    /*
                    IF GET-VALUE("LinkRowid") = "" THEN
                    DO:
                        RUN RodaJavaScript('LimparCampos();').
                        RUN RodaJavaScript('top.frcod.Incluir();').
                    END.
                    */
                END. /* fim otherwise */                  
      END CASE. 
END. /* fim do m�todo GET */

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE SalvaIndiretos w-html 
PROCEDURE SalvaIndiretos :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEF VAR i            AS INT  NO-UNDO.
DEF VAR aux_msgderro AS CHAR NO-UNDO.

/* Instancia a BO para executar as procedures */
RUN dbo/b1wpgd0018.p PERSISTENT SET h-b1wpgd0018.

/* Se BO foi instanciada */
IF VALID-HANDLE(h-b1wpgd0018) THEN
   DO:
      DO WITH FRAME {&FRAME-NAME}:

          DO i = 1 TO NUM-ENTRIES(ab_unmap.aux_lstcusto, ";"):
              FOR EACH cratcdp:
                  DELETE cratcdp NO-ERROR.
              END.

              CREATE cratcdp.
              ASSIGN cratcdp.cdagenci = 0
                     cratcdp.cdcooper = INT(ab_unmap.aux_cdcooper)
                     cratcdp.cdcuseve = int(ENTRY(i, ab_unmap.aux_lstcusto, ";"))
                     cratcdp.cdevento = ?
                     cratcdp.dtanoage = INT(INPUT ab_unmap.aux_dtanoage)
                     cratcdp.idevento = INT(ab_unmap.aux_idevento)
                     cratcdp.vlcuseve = DEC(ENTRY(i, ab_unmap.aux_vlcusind, ";"))
                     cratcdp.tpcuseve = 2 /* Este programa s� lan�a custos indiretos */
                     cratcdp.flgfecha = NO.

              RUN altera-registro IN h-b1wpgd0018(INPUT TABLE cratcdp, OUTPUT aux_msgderro).

              ASSIGN msg-erro = msg-erro + aux_msgderro.

          END.
          ASSIGN ab_unmap.aux_lstcusto = ""
                 ab_unmap.aux_vlcusind = "".

      END. /* DO WITH FRAME {&FRAME-NAME} */
   
      /* "mata" a inst�ncia da BO */
      DELETE PROCEDURE h-b1wpgd0018 NO-ERROR.
   
   END. /* IF VALID-HANDLE(h-b1wpgd0018e) */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE SalvaNovos w-html 
PROCEDURE SalvaNovos :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

DEF VAR i AS INT NO-UNDO.
DEF VAR aux_msgderro AS CHAR NO-UNDO.

/* Instancia a BO para executar as procedures */
RUN dbo/b1wpgd0018.p PERSISTENT SET h-b1wpgd0018.

/*RUN RodaJavaScript("alert('" + ab_unmap.aux_lsvlrbri + "');").*/

/* Se BO foi instanciada */
IF VALID-HANDLE(h-b1wpgd0018) THEN
   DO:
      DO WITH FRAME {&FRAME-NAME}:

          /* Grava os kits para os PAs */
          DO i = 1 TO NUM-ENTRIES(ab_unmap.aux_lstnovos, ";"):
              FOR EACH cratcdp:
                  DELETE cratcdp NO-ERROR.
              END.

              CREATE cratcdp.
              ASSIGN cratcdp.cdagenci = INT(ENTRY(i, ab_unmap.aux_lstnovos, ";"))
                     cratcdp.cdcooper = INT(ab_unmap.aux_cdcooper)
                     cratcdp.cdcuseve = 1 /* Kits */
                     cratcdp.cdevento = ?
                     cratcdp.dtanoage = INT(INPUT ab_unmap.aux_dtanoage)
                     cratcdp.idevento = INT(ab_unmap.aux_idevento)
                     cratcdp.vlcuseve = DEC(ENTRY(i, ab_unmap.aux_lsvlrkit, ";"))
                     cratcdp.tpcuseve = 3 /* Este programa s� lan�a custos de novos s�cios */
                     cratcdp.flgfecha = NO
                     cratcdp.qtditens = DEC(ENTRY(i, ab_unmap.aux_lsqtdkit, ";")) .

              FIND FIRST crapcdp WHERE crapcdp.cdagenci = cratcdp.cdagenci AND
                                       crapcdp.cdcooper = cratcdp.cdcooper AND
                                       crapcdp.cdcuseve = cratcdp.cdcuseve AND
                                       crapcdp.cdevento = cratcdp.cdevento AND
                                       crapcdp.dtanoage = cratcdp.dtanoage AND
                                       crapcdp.idevento = cratcdp.idevento AND
                                       crapcdp.tpcuseve = cratcdp.tpcuseve NO-LOCK NO-ERROR.

              IF NOT AVAIL crapcdp THEN
                  RUN inclui-registro IN h-b1wpgd0018(INPUT TABLE cratcdp, OUTPUT aux_msgderro, OUTPUT ab_unmap.aux_nrdrowid).
              ELSE
                  RUN altera-registro IN h-b1wpgd0018(INPUT TABLE cratcdp, OUTPUT aux_msgderro).

              ASSIGN msg-erro = msg-erro + aux_msgderro.

          END.

          /* Grava os Brindes para os PAs */
          DO i = 1 TO NUM-ENTRIES(ab_unmap.aux_lstnovos, ";"):
              FOR EACH cratcdp:
                  DELETE cratcdp NO-ERROR.
              END.

              CREATE cratcdp.
              ASSIGN cratcdp.cdagenci = INT(ENTRY(i, ab_unmap.aux_lstnovos, ";"))
                     cratcdp.cdcooper = INT(ab_unmap.aux_cdcooper)
                     cratcdp.cdcuseve = 2 /* Brindes */
                     cratcdp.cdevento = ?
                     cratcdp.dtanoage = INT(INPUT ab_unmap.aux_dtanoage)
                     cratcdp.idevento = INT(ab_unmap.aux_idevento)
                     cratcdp.vlcuseve = DEC(ENTRY(i, ab_unmap.aux_lsvlrbri, ";"))
                     cratcdp.tpcuseve = 3 /* Este programa s� lan�a custos de novos s�cios */
                     cratcdp.flgfecha = NO
                     cratcdp.qtditens = DEC(ENTRY(i, ab_unmap.aux_lsqtdbri, ";")) .

              FIND FIRST crapcdp WHERE crapcdp.cdagenci = cratcdp.cdagenci AND
                                       crapcdp.cdcooper = cratcdp.cdcooper AND
                                       crapcdp.cdcuseve = cratcdp.cdcuseve AND
                                       crapcdp.cdevento = cratcdp.cdevento AND
                                       crapcdp.dtanoage = cratcdp.dtanoage AND
                                       crapcdp.idevento = cratcdp.idevento AND
                                       crapcdp.tpcuseve = cratcdp.tpcuseve NO-LOCK NO-ERROR.
              
              IF NOT AVAIL crapcdp THEN
                  RUN inclui-registro IN h-b1wpgd0018(INPUT TABLE cratcdp, OUTPUT aux_msgderro, OUTPUT ab_unmap.aux_nrdrowid).
              ELSE
                  RUN altera-registro IN h-b1wpgd0018(INPUT TABLE cratcdp, OUTPUT aux_msgderro).

              ASSIGN msg-erro = msg-erro + aux_msgderro.

          END.
      END. /* DO WITH FRAME {&FRAME-NAME} */
   
      /* "mata" a inst�ncia da BO */
      DELETE PROCEDURE h-b1wpgd0018 NO-ERROR.
   
   END. /* IF VALID-HANDLE(h-b1wpgd0018e) */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

