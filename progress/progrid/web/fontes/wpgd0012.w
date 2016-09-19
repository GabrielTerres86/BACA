/*...............................................................................

Alterações: 10/12/2008 - Melhoria de performance para a tabela gnapses (Evandro).

            30/04/2009 - Utilizar cdcooper = 0 nas consultas (David).
			
			05/06/2012 - Adaptação dos fontes para projeto Oracle. Alterado
						 busca na gnapses de CONTAINS para MATCHES (Guilherme Maba).

...............................................................................*/

&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
/* Connected Databases 
          gener            PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_datahoje AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_idexclui AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nrcpfcgc AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
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
DEFINE VARIABLE ProgramaEmUso AS CHARACTER INITIAL ["wpgd0012"].
DEFINE VARIABLE NmeDoPrograma AS CHARACTER INITIAL ["wpgd0012.w"].

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
DEFINE VARIABLE h-b1wpgd0012          AS HANDLE                         NO-UNDO.

/*** Temp Tables ***/
DEFINE TEMP-TABLE gnatfdp             LIKE gnapfdp.
DEFINE TEMP-TABLE gnatcfp             LIKE gnapcfp.
DEFINE TEMP-TABLE gnatefp             LIKE gnapefp.
DEFINE TEMP-TABLE gnatpdp             LIKE gnappdp.

DEFINE VARIABLE vetorcontato          AS CHARACTER FORMAT "X(2000)" NO-UNDO.
DEFINE VARIABLE vetoreixo             AS CHARACTER FORMAT "X(2000)" NO-UNDO.
DEFINE VARIABLE vetorproposta         AS CHARACTER FORMAT "X(2000)" NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE fontes/wpgd0012.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS gnapfdp.cddddfax gnapfdp.cddddfor ~
gnapfdp.cdufforn gnapfdp.dsendfor gnapfdp.dsobserv gnapfdp.dsreffor ~
gnapfdp.dtforati gnapfdp.dtforina gnapfdp.dtultalt gnapfdp.flgcoope ~
gnapfdp.inpessoa gnapfdp.nmbaifor gnapfdp.nmcidfor gnapfdp.nmcoofor ~
gnapfdp.nmfornec gnapfdp.nmhompag gnapfdp.nrcepfor gnapfdp.nrfaxfor ~
gnapfdp.nrfonfor 
&Scoped-define ENABLED-TABLES ab_unmap gnapfdp
&Scoped-define FIRST-ENABLED-TABLE ab_unmap
&Scoped-define SECOND-ENABLED-TABLE gnapfdp
&Scoped-Define ENABLED-OBJECTS ab_unmap.aux_nrcpfcgc ab_unmap.aux_idexclui ~
ab_unmap.aux_cddopcao ab_unmap.aux_dsendurl ab_unmap.aux_dsretorn ~
ab_unmap.aux_idevento ab_unmap.aux_lspermis ab_unmap.aux_nrdrowid ~
ab_unmap.aux_stdopcao ab_unmap.aux_datahoje ab_unmap.pagina 
&Scoped-Define DISPLAYED-FIELDS gnapfdp.cddddfax gnapfdp.cddddfor ~
gnapfdp.cdufforn gnapfdp.dsendfor gnapfdp.dsobserv gnapfdp.dsreffor ~
gnapfdp.dtforati gnapfdp.dtforina gnapfdp.dtultalt gnapfdp.flgcoope ~
gnapfdp.inpessoa gnapfdp.nmbaifor gnapfdp.nmcidfor gnapfdp.nmcoofor ~
gnapfdp.nmfornec gnapfdp.nmhompag gnapfdp.nrcepfor gnapfdp.nrfaxfor ~
gnapfdp.nrfonfor 
&Scoped-define DISPLAYED-TABLES ab_unmap gnapfdp
&Scoped-define FIRST-DISPLAYED-TABLE ab_unmap
&Scoped-define SECOND-DISPLAYED-TABLE gnapfdp
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.aux_nrcpfcgc ~
ab_unmap.aux_idexclui ab_unmap.aux_cddopcao ab_unmap.aux_dsendurl ~
ab_unmap.aux_dsretorn ab_unmap.aux_idevento ab_unmap.aux_lspermis ~
ab_unmap.aux_nrdrowid ab_unmap.aux_stdopcao ab_unmap.aux_datahoje ~
ab_unmap.pagina 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     ab_unmap.aux_nrcpfcgc AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_idexclui AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
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
     ab_unmap.aux_datahoje AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     gnapfdp.cddddfax AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     gnapfdp.cddddfor AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     gnapfdp.cdufforn AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     gnapfdp.dsendfor AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     gnapfdp.dsobserv AT ROW 1 COL 1 NO-LABEL
          VIEW-AS EDITOR NO-WORD-WRAP
          SIZE 20 BY 4
     gnapfdp.dsreffor AT ROW 1 COL 1 NO-LABEL
          VIEW-AS EDITOR NO-WORD-WRAP
          SIZE 20 BY 4
     gnapfdp.dtforati AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     gnapfdp.dtforina AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     gnapfdp.dtultalt AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     gnapfdp.flgcoope AT ROW 1 COL 1
          LABEL "cooperado"
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
     gnapfdp.inpessoa AT ROW 1 COL 1 NO-LABEL
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS 
                    "inpessoa 1", 1,
"inpessoa 2", 2
          SIZE 20 BY 3
     gnapfdp.nmbaifor AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     gnapfdp.nmcidfor AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     gnapfdp.nmcoofor AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     gnapfdp.nmfornec AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     gnapfdp.nmhompag AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     gnapfdp.nrcepfor AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     gnapfdp.nrfaxfor AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 71.4 BY 13.33.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Web-Frame
     gnapfdp.nrfonfor AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.pagina AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 71.4 BY 13.33.


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
          FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_datahoje AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_idexclui AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nrcpfcgc AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
          FIELD pagina AS CHARACTER FORMAT "X(256)":U 
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW w-html ASSIGN
         HEIGHT             = 13.33
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
/* SETTINGS FOR FILL-IN ab_unmap.aux_cddopcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_datahoje IN FRAME Web-Frame
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
/* SETTINGS FOR FILL-IN ab_unmap.aux_nrcpfcgc IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nrdrowid IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_stdopcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN gnapfdp.cddddfax IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN gnapfdp.cddddfor IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN gnapfdp.cdufforn IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN gnapfdp.dsendfor IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR EDITOR gnapfdp.dsobserv IN FRAME Web-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR EDITOR gnapfdp.dsreffor IN FRAME Web-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN gnapfdp.dtforati IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN gnapfdp.dtforina IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN gnapfdp.dtultalt IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR TOGGLE-BOX gnapfdp.flgcoope IN FRAME Web-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR RADIO-SET gnapfdp.inpessoa IN FRAME Web-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN gnapfdp.nmbaifor IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN gnapfdp.nmcidfor IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN gnapfdp.nmcoofor IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN gnapfdp.nmfornec IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN gnapfdp.nmhompag IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN gnapfdp.nrcepfor IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN gnapfdp.nrfaxfor IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN gnapfdp.nrfonfor IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaContatos w-html 
PROCEDURE CriaListaContatos :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

FOR EACH gnapcfp WHERE gnapcfp.cdcooper = 0               AND
                       gnapcfp.nrcpfcgc = gnapfdp.nrcpfcgc NO-LOCK
                       BY gnapcfp.nmconfor:
      IF  vetorcontato = "" THEN
          vetorcontato =
                        "~{" + "nmconfor:"    + "'" + replace(TRIM(string(gnapcfp.nmconfor)),"'","`")
                             + "',dsdepart:"  + "'" + replace(string(gnapcfp.dsdepart),"'","`") 
                             + "',dsdemail:"  + "'" + replace(string(gnapcfp.dsdemail),"'","`")
                             + "',cddddfor:'"        + string(gnapcfp.cddddfor) 
                             + "',nrfonfor:'"        + string(gnapcfp.nrfonfor)
                             + "',idconfor:"  + "'"  + string(rowid(gnapcfp)) + "'~}".
      ELSE
         vetorcontato = vetorcontato + "," + 
                        "~{" + "nmconfor:"    + "'" + replace(TRIM(string(gnapcfp.nmconfor)),"'","`")
                             + "',dsdepart:"  + "'" + replace(string(gnapcfp.dsdepart),"'","`") 
                             + "',dsdemail:"  + "'" + replace(string(gnapcfp.dsdemail),"'","`")
                             + "',cddddfor:'"        + string(gnapcfp.cddddfor) 
                             + "',nrfonfor:'"        + string(gnapcfp.nrfonfor)
                             + "',idconfor:"  + "'"  + string(rowid(gnapcfp)) + "'~}".

    
   END. /* for each */
   RUN RodaJavaScript("var mcontato=new Array();mcontato=["  + vetorcontato + "]"). 

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaEixos w-html 
PROCEDURE CriaListaEixos :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

FOR EACH gnapefp WHERE gnapefp.cdcooper = 0                AND
                       gnapefp.nrcpfcgc = gnapfdp.nrcpfcgc NO-LOCK,
    FIRST gnapetp WHERE gnapetp.cdcooper = 0                AND
                        gnapetp.cdeixtem = gnapefp.cdeixtem NO-LOCK 
                        BY gnapetp.dseixtem:
      IF  vetoreixo = "" THEN
          vetoreixo =
                        "~{" + "dseixtem:"    + "'" + REPLACE(TRIM(string(gnapetp.dseixtem)),"'","`")
                             + "',ideixfor:"  + "'"  + string(rowid(gnapefp)) + "'~}".
      ELSE
         vetoreixo = vetoreixo + "," + 
                        "~{" + "dseixtem:"    + "'" + REPLACE(TRIM(string(gnapetp.dseixtem)),"'","`")
                             + "',ideixfor:"  + "'"  + string(rowid(gnapefp)) + "'~}".

    
   END. /* for each */
   RUN RodaJavaScript("var meixo=new Array();meixo=["  + vetoreixo + "]").  

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaPropostas w-html 
PROCEDURE CriaListaPropostas :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

DEFINE VARIABLE aux_nmevento AS CHAR NO-UNDO.

    FOR EACH gnappdp WHERE gnappdp.cdcooper = 0                AND
                           gnappdp.nrcpfcgc = gnapfdp.nrcpfcgc NO-LOCK
                           BY gnappdp.nrpropos:

      FIND FIRST crapedp WHERE
          crapedp.cdcooper = 0 AND
          crapedp.dtanoage = 0 AND
          crapedp.cdevento = gnappdp.cdevento NO-LOCK NO-ERROR.

      IF AVAIL crapedp THEN
          aux_nmevento = crapedp.nmevento.
      ELSE
          aux_nmevento = "Sem vínculo.".

      IF  vetorproposta = "" THEN
          vetorproposta =
                        "~{" + "nrpropos:"    + "'" + REPLACE(TRIM(string(gnappdp.nrpropos)),"'","`")
                             + "',dtmvtolt:"  + "'" + string(gnappdp.dtmvtolt,"99/99/9999")
                             + "',dtvalpro:"  + "'" + string(gnappdp.dtvalpro,"99/99/9999") 
                             + "',nmevento:"  + "'" + REPLACE(string(aux_nmevento),"'","`")
                             + "',idprofor:"  + "'" + string(rowid(gnappdp))   + "'~}".
      ELSE
         vetorproposta = vetorproposta + "," + 
                        "~{" + "nrpropos:"    + "'" + REPLACE(TRIM(string(gnappdp.nrpropos)),"'","`")
                             + "',dtmvtolt:"  + "'" + string(gnappdp.dtmvtolt,"99/99/9999")
                             + "',dtvalpro:"  + "'" + string(gnappdp.dtvalpro,"99/99/9999") 
                             + "',nmevento:"  + "'" + REPLACE(string(aux_nmevento),"'","`")
                             + "',idprofor:"  + "'" + string(rowid(gnappdp))   + "'~}".
    
   END. /* for each */
   RUN RodaJavaScript("var mproposta=new Array();mproposta=["  + vetorproposta + "]").


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ExcluiContato w-html 
PROCEDURE ExcluiContato :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE h-b1wpgd0012a AS HANDLE NO-UNDO.

    /* Instancia a BO para executar as procedures */
    RUN dbo/b1wpgd0012a.p PERSISTENT SET h-b1wpgd0012a.

    FIND FIRST gnapcfp WHERE
        ROWID(gnapcfp) = TO-ROWID(ab_unmap.aux_idexclui) NO-LOCK NO-ERROR.

    IF AVAIL gnapcfp THEN
    DO:
        /* Se BO foi instanciada */
        IF VALID-HANDLE(h-b1wpgd0012a) THEN
        DO:
            CREATE gnatcfp.
            BUFFER-COPY gnapcfp TO gnatcfp.
          
            RUN exclui-registro IN h-b1wpgd0012a(INPUT TABLE gnatcfp, OUTPUT msg-erro).

            /* "mata" a instância da BO */
            DELETE PROCEDURE h-b1wpgd0012a NO-ERROR.
        END.
    END.
    ELSE
    DO:
        ASSIGN msg-erro = msg-erro + "Registro de Contato do Fornecedor não encontrado. ".
    END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ExcluiEixo w-html 
PROCEDURE ExcluiEixo :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE h-b1wpgd0012b AS HANDLE NO-UNDO.

    /* Instancia a BO para executar as procedures */
    RUN dbo/b1wpgd0012b.p PERSISTENT SET h-b1wpgd0012b.

    FIND FIRST gnapefp WHERE
        ROWID(gnapefp) = TO-ROWID(ab_unmap.aux_idexclui) NO-LOCK NO-ERROR.

    IF AVAIL gnapefp THEN
    DO:
        /* Se BO foi instanciada */
        IF VALID-HANDLE(h-b1wpgd0012b) THEN
        DO:
            CREATE gnatefp.
            BUFFER-COPY gnapefp TO gnatefp.
          
            RUN exclui-registro IN h-b1wpgd0012b(INPUT TABLE gnatefp, OUTPUT msg-erro).

            /* "mata" a instância da BO */
            DELETE PROCEDURE h-b1wpgd0012b NO-ERROR.
        END.
    END.
    ELSE
    DO:
        ASSIGN msg-erro = msg-erro + "Registro de Eixo relacionado ao Fornecedor não encontrado. ".
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ExcluiProposta w-html 
PROCEDURE ExcluiProposta :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE h-b1wpgd0012c AS HANDLE NO-UNDO.

    /* Instancia a BO para executar as procedures */
    RUN dbo/b1wpgd0012c.p PERSISTENT SET h-b1wpgd0012c.

    FIND FIRST gnappdp WHERE
        ROWID(gnappdp) = TO-ROWID(ab_unmap.aux_idexclui) NO-LOCK NO-ERROR.

    IF AVAIL gnappdp THEN
    DO:
        /* Se BO foi instanciada */
        IF VALID-HANDLE(h-b1wpgd0012c) THEN
        DO:
            CREATE gnatpdp.
            BUFFER-COPY gnappdp TO gnatpdp.
          
            RUN exclui-registro IN h-b1wpgd0012c(INPUT TABLE gnatpdp, OUTPUT msg-erro).

            /* "mata" a instância da BO */
            DELETE PROCEDURE h-b1wpgd0012c NO-ERROR.
        END.
    END.
    ELSE
    DO:
        ASSIGN msg-erro = msg-erro + "Registro de Proposta relacionado ao Fornecedor não encontrado. ".
    END.

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
    ("aux_cddopcao":U,"ab_unmap.aux_cddopcao":U,ab_unmap.aux_cddopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_datahoje":U,"ab_unmap.aux_datahoje":U,ab_unmap.aux_datahoje:HANDLE IN FRAME {&FRAME-NAME}).
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
    ("aux_nrcpfcgc":U,"ab_unmap.aux_nrcpfcgc":U,ab_unmap.aux_nrcpfcgc:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrdrowid":U,"ab_unmap.aux_nrdrowid":U,ab_unmap.aux_nrdrowid:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_stdopcao":U,"ab_unmap.aux_stdopcao":U,ab_unmap.aux_stdopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("cddddfax":U,"gnapfdp.cddddfax":U,gnapfdp.cddddfax:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("cddddfor":U,"gnapfdp.cddddfor":U,gnapfdp.cddddfor:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("cdufforn":U,"gnapfdp.cdufforn":U,gnapfdp.cdufforn:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dsendfor":U,"gnapfdp.dsendfor":U,gnapfdp.dsendfor:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dsobserv":U,"gnapfdp.dsobserv":U,gnapfdp.dsobserv:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dsreffor":U,"gnapfdp.dsreffor":U,gnapfdp.dsreffor:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dtforati":U,"gnapfdp.dtforati":U,gnapfdp.dtforati:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dtforina":U,"gnapfdp.dtforina":U,gnapfdp.dtforina:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dtultalt":U,"gnapfdp.dtultalt":U,gnapfdp.dtultalt:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("flgcoope":U,"gnapfdp.flgcoope":U,gnapfdp.flgcoope:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("inpessoa":U,"gnapfdp.inpessoa":U,gnapfdp.inpessoa:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nmbaifor":U,"gnapfdp.nmbaifor":U,gnapfdp.nmbaifor:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nmcidfor":U,"gnapfdp.nmcidfor":U,gnapfdp.nmcidfor:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nmcoofor":U,"gnapfdp.nmcoofor":U,gnapfdp.nmcoofor:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nmfornec":U,"gnapfdp.nmfornec":U,gnapfdp.nmfornec:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nmhompag":U,"gnapfdp.nmhompag":U,gnapfdp.nmhompag:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nrcepfor":U,"gnapfdp.nrcepfor":U,gnapfdp.nrcepfor:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nrfaxfor":U,"gnapfdp.nrfaxfor":U,gnapfdp.nrfaxfor:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nrfonfor":U,"gnapfdp.nrfonfor":U,gnapfdp.nrfonfor:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("pagina":U,"ab_unmap.pagina":U,ab_unmap.pagina:HANDLE IN FRAME {&FRAME-NAME}).
END PROCEDURE.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-assign-record w-html 
PROCEDURE local-assign-record :
DEFINE INPUT PARAMETER opcao AS CHARACTER.

/* Instancia a BO para executar as procedures */
RUN dbo/b1wpgd0012.p PERSISTENT SET h-b1wpgd0012.

/* Se BO foi instanciada */
IF VALID-HANDLE(h-b1wpgd0012) THEN
   DO:
      DO WITH FRAME {&FRAME-NAME}:
         IF opcao = "inclusao" THEN
            DO: 
                CREATE gnatfdp.
                ASSIGN
                    gnatfdp.cdcooper = 0
                    gnatfdp.cddddfax = INPUT gnapfdp.cddddfax 
                    gnatfdp.cddddfor = INPUT gnapfdp.cddddfor
                    gnatfdp.cdoperad = gnapses.cdoperad
                    gnatfdp.cdufforn = INPUT gnapfdp.cdufforn
                    gnatfdp.dsendfor = INPUT gnapfdp.dsendfor
                    gnatfdp.dsobserv = INPUT gnapfdp.dsobserv
                    gnatfdp.dsreffor = INPUT gnapfdp.dsreffor
                    gnatfdp.dtforati = INPUT gnapfdp.dtforati
                    gnatfdp.dtforina = INPUT gnapfdp.dtforina
                    gnatfdp.dtultalt = TODAY
                    gnatfdp.flgcoope = INPUT gnapfdp.flgcoope
                    gnatfdp.idevento = INT(ab_unmap.aux_idevento)
                    /*gnatfdp.inpessoa = int(INPUT ab_unmap.aux_inpessoa)*/
                    gnatfdp.inpessoa = INPUT gnapfdp.inpessoa
                    gnatfdp.nmbaifor = INPUT gnapfdp.nmbaifor
                    gnatfdp.nmcidfor = INPUT gnapfdp.nmcidfor
                    gnatfdp.nmcoofor = INPUT gnapfdp.nmcoofor
                    gnatfdp.nmfornec = INPUT gnapfdp.nmfornec
                    gnatfdp.nmhompag = INPUT gnapfdp.nmhompag
                    gnatfdp.nrcepfor = INPUT gnapfdp.nrcepfor
                    gnatfdp.nrcpfcgc = dec(INPUT ab_unmap.aux_nrcpfcgc)
                    gnatfdp.nrfaxfor = INPUT gnapfdp.nrfaxfor
                    gnatfdp.nrfonfor = INPUT gnapfdp.nrfonfor.


                RUN inclui-registro IN h-b1wpgd0012(INPUT TABLE gnatfdp, OUTPUT msg-erro, OUTPUT ab_unmap.aux_nrdrowid).
            END.
         ELSE  /* alteracao */
            DO:
                /* cria a temp-table e joga o novo valor digitado para o campo */
                CREATE gnatfdp.
                BUFFER-COPY gnapfdp TO gnatfdp.

                ASSIGN
                    gnatfdp.cdcooper = 0
                    gnatfdp.cddddfax = INPUT gnapfdp.cddddfax 
                    gnatfdp.cddddfor = INPUT gnapfdp.cddddfor
                    gnatfdp.cdoperad = gnapses.cdoperad
                    gnatfdp.cdufforn = INPUT gnapfdp.cdufforn
                    gnatfdp.dsendfor = INPUT gnapfdp.dsendfor
                    gnatfdp.dsobserv = INPUT gnapfdp.dsobserv
                    gnatfdp.dsreffor = INPUT gnapfdp.dsreffor
                    gnatfdp.dtforati = INPUT gnapfdp.dtforati
                    gnatfdp.dtforina = INPUT gnapfdp.dtforina
                    gnatfdp.dtultalt = TODAY
                    gnatfdp.flgcoope = INPUT gnapfdp.flgcoope
                    gnatfdp.idevento = int(ab_unmap.aux_idevento)
                    /*gnatfdp.inpessoa = int(INPUT ab_unmap.aux_inpessoa)*/
                    gnatfdp.inpessoa = INPUT gnapfdp.inpessoa
                    gnatfdp.nmbaifor = INPUT gnapfdp.nmbaifor
                    gnatfdp.nmcidfor = INPUT gnapfdp.nmcidfor
                    gnatfdp.nmcoofor = INPUT gnapfdp.nmcoofor
                    gnatfdp.nmfornec = INPUT gnapfdp.nmfornec
                    gnatfdp.nmhompag = INPUT gnapfdp.nmhompag
                    gnatfdp.nrcepfor = INPUT gnapfdp.nrcepfor
                    gnatfdp.nrcpfcgc = dec(INPUT ab_unmap.aux_nrcpfcgc)
                    gnatfdp.nrfaxfor = INPUT gnapfdp.nrfaxfor
                    gnatfdp.nrfonfor = INPUT gnapfdp.nrfonfor.
                 
                RUN altera-registro IN h-b1wpgd0012(INPUT TABLE gnatfdp, OUTPUT msg-erro).
            END.    
      END. /* DO WITH FRAME {&FRAME-NAME} */
   
      /* "mata" a instância da BO */
      DELETE PROCEDURE h-b1wpgd0012 NO-ERROR.
   
   END. /* IF VALID-HANDLE(h-b1wpgd0012) */
      
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-delete-record w-html 
PROCEDURE local-delete-record :
/* Instancia a BO para executar as procedures */
RUN dbo/b1wpgd0012.p PERSISTENT SET h-b1wpgd0012.
 
/* Se BO foi instanciada */
IF VALID-HANDLE(h-b1wpgd0012) THEN
   DO:
      CREATE gnatfdp.
      BUFFER-COPY gnapfdp TO gnatfdp.
          
      RUN exclui-registro IN h-b1wpgd0012(INPUT TABLE gnatfdp, OUTPUT msg-erro).

      /* "mata" a instância da BO */
      DELETE PROCEDURE h-b1wpgd0012 NO-ERROR.
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
       FIND PREV {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.cdcooper = 0                              AND
                                               {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.

       IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
           DO:
               ASSIGN ab_unmap.aux_nrdrowid = STRING(ROWID({&SECOND-ENABLED-TABLE})).

               FIND PREV {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.cdcooper = 0                              AND
                                                       {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.

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
FIND FIRST {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.cdcooper = 0                              AND
                                         {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.


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
       FIND NEXT {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.cdcooper = 0                              AND
                                               {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.

       IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
           DO:
               ASSIGN ab_unmap.aux_nrdrowid = STRING(ROWID({&SECOND-ENABLED-TABLE})).

               FIND NEXT {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.cdcooper = 0                              AND
                                                       {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.

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
FIND LAST {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.cdcooper = 0                              AND
                                        {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.

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
       ab_unmap.aux_idevento    = get-value("aux_idevento")
       ab_unmap.aux_dsendurl    = AppURL                        
       ab_unmap.aux_lspermis    = FlagPermissoes                
       ab_unmap.aux_nrdrowid    = GET-VALUE("aux_nrdrowid")         
       ab_unmap.aux_stdopcao    = GET-VALUE("aux_stdopcao")
       ab_unmap.aux_idexclui    = GET-VALUE("aux_idexclui")
       ab_unmap.aux_nrcpfcgc    = GET-VALUE("aux_nrcpfcgc")
       ab_unmap.pagina          = GET-VALUE("pagina")
       ab_unmap.aux_datahoje    = STRING(TODAY, "99/99/9999").

RUN outputHeader.

/* Controle de duplicação de registros */
IF LOCKED gnapses THEN
    ASSIGN 
    opcao = ""
    msg-erro-aux = 10.

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
                    /*FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.

                    /* busca o próximo registro para fazer o reposicionamento */
                    FIND NEXT {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.cdcooper = 0                              AND
                                                            {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.

                    IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                       ASSIGN aux_nrdrowid-auxiliar = STRING(ROWID({&SECOND-ENABLED-TABLE})).
                    ELSE
                       DO:
                           /* nao encontrou próximo registro então procura pelo registro anterior para o reposicionamento */
                           FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                           
                           FIND PREV {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.cdcooper = 0                              AND
                                                                   {&SECOND-ENABLED-TABLE}.idevento = int(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.

                           IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                              ASSIGN aux_nrdrowid-auxiliar = STRING(ROWID({&SECOND-ENABLED-TABLE})).
                           ELSE
                              ASSIGN aux_nrdrowid-auxiliar = "?".
                       END.*/         
                       
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

                                       IF AVAIL gnapfdp THEN
                                           IF gnapfdp.inpessoa = 1 THEN
                                               ab_unmap.aux_nrcpfcgc = STRING(gnapfdp.nrcpfcgc, "99999999999").
                                           ELSE
                                               ab_unmap.aux_nrcpfcgc = STRING(gnapfdp.nrcpfcgc, "99999999999999"). 

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

           WHEN "exc" THEN /* exclui contato */
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
                  RUN ExcluiContato.  
                  IF msg-erro = "" THEN
                     ASSIGN msg-erro-aux = 10. /* Solicitação realizada com sucesso */ 
                  ELSE
                     ASSIGN msg-erro-aux = 3. /* erros da validação de dados */

                  IF AVAIL gnapfdp THEN
                      IF gnapfdp.inpessoa = 1 THEN
                          ab_unmap.aux_nrcpfcgc = STRING(gnapfdp.nrcpfcgc, "99999999999").
                      ELSE
                          ab_unmap.aux_nrcpfcgc = STRING(gnapfdp.nrcpfcgc, "99999999999999"). 

               END.     
           END.

           WHEN "exe" THEN /* exclui eixo */
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
                  RUN ExcluiEixo.  
                  IF msg-erro = "" THEN
                     ASSIGN msg-erro-aux = 10. /* Solicitação realizada com sucesso */ 
                  ELSE
                     ASSIGN msg-erro-aux = 3. /* erros da validação de dados */

                  IF AVAIL gnapfdp THEN
                      IF gnapfdp.inpessoa = 1 THEN
                          ab_unmap.aux_nrcpfcgc = STRING(gnapfdp.nrcpfcgc, "99999999999").
                      ELSE
                          ab_unmap.aux_nrcpfcgc = STRING(gnapfdp.nrcpfcgc, "99999999999999"). 
               END.     
           END.

           WHEN "exp" THEN /* exclui proposta */
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
                  RUN ExcluiProposta.  
                  IF msg-erro = "" THEN
                     ASSIGN msg-erro-aux = 10. /* Solicitação realizada com sucesso */ 
                  ELSE
                     ASSIGN msg-erro-aux = 3. /* erros da validação de dados */

                  IF AVAIL gnapfdp THEN
                      IF gnapfdp.inpessoa = 1 THEN
                          ab_unmap.aux_nrcpfcgc = STRING(gnapfdp.nrcpfcgc, "99999999999").
                      ELSE
                          ab_unmap.aux_nrcpfcgc = STRING(gnapfdp.nrcpfcgc, "99999999999999"). 
               END.     
           END.
    
      END CASE.

      RUN CriaListaContatos.
      RUN CriaListaEixos.
      RUN CriaListaPropostas.

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

                    IF AVAIL gnapfdp THEN
                        IF gnapfdp.inpessoa = 1 THEN
                            ab_unmap.aux_nrcpfcgc = STRING(gnapfdp.nrcpfcgc, "99999999999").
                        ELSE
                            ab_unmap.aux_nrcpfcgc = STRING(gnapfdp.nrcpfcgc, "99999999999999").

                    RUN CriaListaContatos.
                    RUN CriaListaEixos.
                    RUN CriaListaPropostas.

                    RUN displayFields.
                    RUN enableFields.
                    RUN outputFields.
                    RUN RodaJavaScript('top.frcod.FechaZoom()').
                    RUN RodaJavaScript('CarregaPrincipal()').
                    
                    IF GET-VALUE("LinkRowid") = "" THEN
                       DO:
                           RUN RodaJavaScript('document.form.dtforati.value="' + STRING(TODAY, "99/99/9999") + '"').
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

