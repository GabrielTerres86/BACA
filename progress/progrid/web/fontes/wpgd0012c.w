/* ......................................................................

Alteraçoes: 29/01/2008 - Nao permitir a digitaçao do Número da proposta,
                         gerá-la automaticamente (Diego).
 
            10/12/2008 - Melhoria de performance para a tabela gnapses (Evandro).
            
            04/05/2009 - Utilizar cdcooper = 0 nas consultas (David).
                        
            05/06/2012 - Adaptaçao dos fontes para projeto Oracle. Alterado
                         busca na gnapses de CONTAINS para MATCHES (Guilherme Maba).

            22/10/2012 - Tratar nova estrutura gnappob (Gabriel).
            
            30/06/2015 - Inclusao de novos campos Projeto Progrid (Vanessa)
            
            08/10/2015 - Inclusao do campo Recurso e Transporte Incluso(Vanessa).
            
            09/12/2015 - Inclusão do campo cdcopope (Vanessa)

			19/04/2016 - Removi os campos de Publico Alvo (Carlos Rafael Tanhol).

            30/05/2016 - Ajustes PRJ229 - Melhorias OQS (Odirlei-AMcom)

......................................................................... */

&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
/* Connected Databases 
          gener            PROGRESS
*/

&Scoped-define WINDOW-NAME CURRENT-WINDOW

DEF BUFFER b-gnappdp  FOR gnappdp.

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_cdtemeix AS CHARACTER 
       FIELD aux_cdeixtem AS CHARACTER 
       FIELD aux_cdevento AS CHARACTER 
       FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_idexclui AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lsfacili AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nmpagina AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nrcpfcgc AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
       FIELD qtcarhor AS CHARACTER
       FIELD cdeixtem AS CHARACTER FORMAT "X(256)":U 
       FIELD cdevento AS CHARACTER FORMAT "X(256)":U 
       FIELD nrseqtem AS CHARACTER FORMAT "X(256)":U 
       FIELD txfacili AS CHARACTER
       FIELD txrecurs AS CHARACTER
       FIELD aux_flgtrinc AS LOGICAL
       FIELD aux_idforrev AS CHARACTER
       FIELD aux_dspublic AS CHARACTER
       FIELD idforrev AS CHARACTER
       FIELD aux_cdcopope AS CHARACTER FORMAT "X(256)":U
       FIELD aux_idvapost AS CHARACTER FORMAT "X(256)":U
       FIELD aux_nrpropos AS CHARACTER FORMAT "X(256)":U.
       
       
/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE temas
       FIELD dstemeix LIKE craptem.dstemeix
       FIELD nrseqtem LIKE craptem.nrseqtem
       FIELD idevento LIKE craptem.idevento
       FIELD cdcooper LIKE craptem.cdcooper
       FIELD cdeixtem LIKE craptem.cdeixtem.

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
DEFINE VARIABLE ProgramaEmUso AS CHARACTER INITIAL ["wpgdXXXX"].
DEFINE VARIABLE NmeDoPrograma AS CHARACTER INITIAL ["wpgdXXXX.w"].

DEFINE VARIABLE operacao              AS CHARACTER.

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

DEFINE VARIABLE aux_gnapetp           AS CHARACTER                      NO-UNDO.
DEFINE VARIABLE aux_flgescol          AS LOGICAL                        NO-UNDO.
DEFINE VARIABLE aux_nrpropos          AS CHAR                           NO-UNDO.


DEFINE VARIABLE vetorevento           AS CHAR FORMAT "x(2000)"          NO-UNDO.
DEFINE VARIABLE vetorfacili           AS CHAR FORMAT "x(2000)"          NO-UNDO.
DEFINE VARIABLE vetoreixo             AS CHAR FORMAT "x(2000)"          NO-UNDO.
DEFINE VARIABLE vetorecurso           AS CHAR FORMAT "x(2000)"          NO-UNDO. 
DEFINE VARIABLE vetopubalvo           AS CHAR FORMAT "x(2000)"          NO-UNDO.
DEFINE VARIABLE vetoforma             AS CHAR FORMAT "x(2000)"          NO-UNDO.                                                               
/*** Declaraçao de BOs ***/
DEFINE VARIABLE h-b1wpgd0012c          AS HANDLE                         NO-UNDO.
DEFINE VARIABLE h-b1wpgd0012d          AS HANDLE                         NO-UNDO.
DEFINE VARIABLE h-b1wpgd0012e          AS HANDLE                         NO-UNDO.
DEFINE VARIABLE aux_registros          AS INT NO-UNDO.
/*** Temp Tables ***/
DEFINE TEMP-TABLE gnatpdp  NO-UNDO    LIKE gnappdp.
                  
DEFINE TEMP-TABLE gtfacep  NO-UNDO    LIKE gnfacep.

DEFINE TEMP-TABLE cratrdf  NO-UNDO    LIKE craprdf.

DEFINE VARIABLE aux_craptem           AS CHARACTER                      NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE fontes/wpgd0012c.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame 

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS gnappdp.dsconteu gnappdp.dsmetodo gnappob.dsobjeti gnappdp.dsobserv gnappdp.dsidadpa gnappdp.dsprereq gnappdp.nrseqpap ~
 gnappdp.dtmvtolt gnappdp.dtvalpro gnappdp.nmevefor gnappdp.nrpropos gnappdp.vlinvest gnappdp.idtrainc gnappdp.idforrev
&Scoped-define ENABLED-TABLES ab_unmap gnappdp
&Scoped-define FIRST-ENABLED-TABLE ab_unmap
&Scoped-define SECOND-ENABLED-TABLE gnappdp
&Scoped-Define ENABLED-OBJECTS ab_unmap.txfacili ab_unmap.txrecurs ab_unmap.aux_lsfacili ab_unmap.aux_nmpagina ab_unmap.cdeixtem ab_unmap.aux_cddopcao ~
ab_unmap.aux_cdtemeix ab_unmap.aux_cdeixtem ab_unmap.aux_idvapost ab_unmap.aux_nrpropos ~
ab_unmap.aux_cdevento ab_unmap.aux_dsendurl ab_unmap.aux_dsretorn ab_unmap.aux_idevento ab_unmap.aux_idexclui ab_unmap.aux_lspermis ab_unmap.aux_nrcpfcgc ~
ab_unmap.aux_nrdrowid ab_unmap.aux_stdopcao ab_unmap.cdevento ab_unmap.qtcarhor ab_unmap.aux_flgtrinc ab_unmap.aux_idforrev ab_unmap.aux_dspublic ab_unmap.aux_cdcopope
&Scoped-Define DISPLAYED-FIELDS gnappdp.dsconteu gnappdp.dsmetodo gnappob.dsobjeti gnappdp.dsobserv gnappdp.dsidadpa gnappdp.dsprereq gnappdp.nrseqpap ~
gnappdp.dtmvtolt gnappdp.dtvalpro gnappdp.nmevefor gnappdp.nrpropos gnappdp.vlinvest gnappdp.idtrainc gnappdp.idforrev 
&Scoped-define DISPLAYED-TABLES ab_unmap gnappdp
&Scoped-define FIRST-DISPLAYED-TABLE ab_unmap
&Scoped-define SECOND-DISPLAYED-TABLE gnappdp
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.txfacili ab_unmap.txrecurs ab_unmap.aux_lsfacili ab_unmap.aux_nmpagina ab_unmap.cdeixtem ab_unmap.aux_cddopcao ~
ab_unmap.aux_cdtemeix ab_unmap.aux_idvapost ab_unmap.aux_nrpropos ~
ab_unmap.aux_cdeixtem ab_unmap.aux_cdevento ab_unmap.aux_dsendurl ab_unmap.aux_dsretorn ab_unmap.aux_idevento ab_unmap.aux_idexclui ab_unmap.aux_lspermis ~
ab_unmap.aux_nrcpfcgc ab_unmap.aux_nrdrowid ab_unmap.aux_stdopcao ab_unmap.cdevento ab_unmap.qtcarhor ab_unmap.aux_flgtrinc  ab_unmap.aux_idforrev ~
ab_unmap.aux_dspublic ab_unmap.aux_cdcopope

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     ab_unmap.txfacili AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS EDITOR NO-WORD-WRAP
          SIZE 20 BY 4
     ab_unmap.txrecurs AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS EDITOR NO-WORD-WRAP
          SIZE 20 BY 4
     ab_unmap.aux_lsfacili AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nmpagina AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.cdeixtem AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.nrseqtem AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cddopcao AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cdtemeix AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.aux_cdeixtem AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
          
     ab_unmap.aux_cdevento AT ROW 1 COL 1 HELP
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
     ab_unmap.aux_idevento AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cdcopope AT ROW 1 COL 1 HELP
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
     ab_unmap.aux_nrcpfcgc AT ROW 1 COL 1 HELP
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
     ab_unmap.cdevento AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1          
     ab_unmap.aux_idforrev AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.aux_idvapost AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1      
     ab_unmap.aux_nrpropos AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1       
     gnappdp.dsconteu AT ROW 1 COL 1 NO-LABEL
          VIEW-AS EDITOR NO-WORD-WRAP
          SIZE 20 BY 4
     gnappdp.dsmetodo AT ROW 1 COL 1 NO-LABEL
          VIEW-AS EDITOR NO-WORD-WRAP
          SIZE 20 BY 4
     gnappob.dsobjeti AT ROW 1 COL 1 NO-LABEL
          VIEW-AS EDITOR NO-WORD-WRAP
          SIZE 20 BY 4
     gnappdp.dsobserv AT ROW 1 COL 1 NO-LABEL
          VIEW-AS EDITOR NO-WORD-WRAP
          SIZE 20 BY 4
     gnappdp.nrseqpap AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_dspublic AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4    
     gnappdp.dsidadpa AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     gnappdp.dsprereq AT ROW 1 COL 1 NO-LABEL
          VIEW-AS EDITOR NO-WORD-WRAP
          SIZE 20 BY 4          
     gnappdp.dtmvtolt AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     gnappdp.dtvalpro AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     gnappdp.nmevefor AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     gnappdp.nrpropos AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     gnappdp.idtrainc AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1           
     gnappdp.idforrev AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1           
     WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 52.2 BY 12.67.
/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Web-Frame
     ab_unmap.qtcarhor AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     gnappdp.vlinvest AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1         
     ab_unmap.aux_flgtrinc AT ROW 1 COL 1
          LABEL "Transporte Incluso"
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
          
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 52.2 BY 12.67.

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
          FIELD aux_cdeixtem AS CHARACTER 
          FIELD aux_cdevento AS CHARACTER 
          FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_idexclui AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lsfacili AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nmpagina AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nrcpfcgc AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
          FIELD cdeixtem AS CHARACTER FORMAT "X(256)":U 
          FIELD cdevento AS CHARACTER FORMAT "X(256)":U 
          FIELD txfacili AS CHARACTER
          FIELD txrecurs AS CHARACTER
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW w-html ASSIGN
         HEIGHT             = 12.67
         WIDTH              = 52.2.
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
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_cdeixtem IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_cdevento IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dsendurl IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dsretorn IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_idevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_idexclui IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lsfacili IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lspermis IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nmpagina IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nrcpfcgc IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nrdrowid IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_stdopcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.cdeixtem IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.cdevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR EDITOR gnappdp.dsconteu IN FRAME Web-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR EDITOR gnappdp.dsmetodo IN FRAME Web-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR EDITOR gnappob.dsobjeti IN FRAME Web-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR EDITOR gnappdp.dsobserv IN FRAME Web-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR EDITOR gnappdp.dspublic IN FRAME Web-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN gnappdp.dtmvtolt IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN gnappdp.dtvalpro IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN gnappdp.nmevefor IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN gnappdp.nrpropos IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN gnappdp.qtcarhor IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR EDITOR ab_unmap.txfacili IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR EDITOR ab_unmap.txrecurs IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */     
/* SETTINGS FOR FILL-IN gnappdp.vlinvest IN FRAME Web-Frame
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaEixos w-html 
PROCEDURE CriaListaPublicoAlvo :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
   FOR EACH crappap  WHERE NO-LOCK BY crappap.dspubalv: 
      
       
          IF  vetopubalvo = "" THEN
              vetopubalvo =
                            "~{" + "nrseqpap:"    + "'" + TRIM(string(crappap.nrseqpap))  
                                 + "',dspubalv:"  + "'" + TRIM(string(crappap.dspubalv))+ "'~}".
          ELSE
             vetopubalvo = vetopubalvo + "," + 
                            "~{" + "nrseqpap:"    + "'" + TRIM(string(crappap.nrseqpap))  
                                 + "',dspubalv:"  + "'" + TRIM(string(crappap.dspubalv))+ "'~}".

    
    END. /* for each */
    RUN RodaJavaScript("var mpublicalvo=new Array();mpublicalvo=["  + vetopubalvo + "]").

END PROCEDURE.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaEixos w-html 
PROCEDURE CriaListaEixos :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
   FOR EACH gnapetp NO-LOCK BY gnapetp.dseixtem: 
      
       
          IF  vetoreixo = "" THEN
              vetoreixo =
                            "~{" + "idevento:"    + "'" + TRIM(string(gnapetp.idevento))  
                                 + "',cdcooper:"  + "'" + TRIM(string(gnapetp.cdcooper))
                                 + "',cdeixtem:"  + "'" + TRIM(string(gnapetp.cdeixtem))
                                 + "',dseixtem:"  + "'" + TRIM(string(gnapetp.dseixtem))+ "'~}".
          ELSE
             vetoreixo = vetoreixo + "," + 
                            "~{" + "idevento:"    + "'" + TRIM(string(gnapetp.idevento))  
                                 + "',cdcooper:"  + "'" + TRIM(string(gnapetp.cdcooper))
                                 + "',cdeixtem:"  + "'" + TRIM(string(gnapetp.cdeixtem))
                                 + "',dseixtem:"  + "'" + TRIM(string(gnapetp.dseixtem))+ "'~}".

    
    END. /* for each */
    RUN RodaJavaScript("var meixos=new Array();meixos=["  + vetoreixo + "]").

END PROCEDURE.
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaEvento w-html 
PROCEDURE CriaListaEvento :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
/*****###########ver######*/
    /*FOR EACH crapedp NO-LOCK 
        WHERE crapedp.flgativo = TRUE*/
      RUN RodaJavaScript("var mevento=new Array();").  
     
      FOR EACH crapedp WHERE
          crapedp.cdcooper = 0 AND
          crapedp.dtanoage = 0 AND
          crapedp.flgativo = TRUE  NO-LOCK 
          BY crapedp.nmevento:

          IF  vetorevento = "" THEN
              vetorevento =
                            "~{" + "cdeixtem:"    + "'" + TRIM(string(crapedp.cdeixtem))  
                                 + "',nrseqtem:"  + "'" + TRIM(string(crapedp.nrseqtem))
                                 + "',cdevento:"  + "'" + TRIM(string(crapedp.cdevento))
                                 + "',nmevento:"  + "'" + TRIM(string(crapedp.nmevento)) + "'~}".
          ELSE
             vetorevento = vetorevento + "," + 
                            "~{" + "cdeixtem:"    + "'" + TRIM(string(crapedp.cdeixtem)) 
                                 + "',nrseqtem:"  + "'" + TRIM(string(crapedp.nrseqtem))
                                 + "',cdevento:"  + "'" + TRIM(string(crapedp.cdevento))
                                 + "',nmevento:"  + "'" + TRIM(string(crapedp.nmevento)) + "'~}".
                                 
                                 
           aux_registros  = aux_registros  + 1.
        IF aux_registros > 50 THEN
          DO:
            RUN RodaJavaScript("mevento.push(" + STRING(vetorevento) + ");").
            
            ASSIGN vetorevento = ""
                   aux_registros = 0.
          END.

    
    END. /* for each */
    RUN RodaJavaScript("mevento.push(" + STRING(vetorevento) + ");").
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaFacili w-html 
PROCEDURE CriaListaFacili :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

FOR EACH gnapfep WHERE gnapfep.idevento = INTEGER(ab_unmap.aux_idevento)   AND
                       gnapfep.cdcooper = 0                                AND
                       gnapfep.nrcpfcgc = DECIMAL(ab_unmap.aux_nrcpfcgc)   NO-LOCK
                       BY gnapfep.nmfacili:

    /* Se é a primeira vez, busca na tabela, senao pega da tela */
    IF  REQUEST_METHOD = "GET"  THEN
        DO:
           /* Busca o registro caso ele nao esteja disponível */
          /* IF   NOT AVAILABLE {&SECOND-ENABLED-TABLE}   THEN
                FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-ERROR.        
*/         IF AVAILABLE {&SECOND-ENABLED-TABLE}   THEN
             ASSIGN aux_nrpropos = {&SECOND-ENABLED-TABLE}.nrpropos.
             
           FIND gnfacep WHERE gnfacep.cdcooper = 0                AND
                              gnfacep.cdfacili = gnapfep.cdfacili AND
                              gnfacep.idevento = gnapfep.idevento AND
                              gnfacep.nrcpfcgc = gnapfep.nrcpfcgc AND
                              gnfacep.nrpropos = {&SECOND-ENABLED-TABLE}.nrpropos
                              NO-LOCK NO-ERROR.
          
         
           IF  AVAILABLE gnfacep  THEN
              ASSIGN aux_flgescol = TRUE.
           ELSE
               ASSIGN aux_flgescol = FALSE.
                      /*aux_nrpropos = gnappdp.nrpropos.*/
                      
        END.
    ELSE 
    DO:
      
        IF CAN-DO(ab_unmap.aux_lsfacili,STRING(ROWID(gnapfep)))  THEN
           aux_flgescol = TRUE.
        ELSE
           aux_flgescol = FALSE.
    END.
    
    IF  vetorfacili = "" THEN
        vetorfacili =
                      "~{" + "idfacili:"    + "'" + string(rowid(gnapfep))
                           + "',nmfacili:"  + "'" + TRIM(string(gnapfep.nmfacili))
                           + "',flgescol:"  + "'" + STRING(aux_flgescol,"yes/no") + "'~}".
    ELSE
       vetorfacili = vetorfacili + "," + 
                      "~{" + "idfacili:"    + "'" + string(rowid(gnapfep))
                           + "',nmfacili:"  + "'" + TRIM(string(gnapfep.nmfacili))
                           + "',flgescol:"  + "'" + STRING(aux_flgescol,"yes/no") + "'~}".

END. /* for each */

RUN RodaJavaScript("var mfacili=new Array();mfacili=["  + vetorfacili + "]").

END PROCEDURE.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaRecurso w-html 
/* Procedimento para eliminar recursos que estajam 
   atrelados a proposta caso ela nao esteja salva */
PROCEDURE LimpaRecurso:
  
  /* Verificar se a proposta existe*/
  FIND FIRST gnappdp 
       WHERE gnappdp.IDEVENTO = INTEGER(ab_unmap.aux_idevento)
         AND gnappdp.NRCPFCGC = DECIMAL(ab_unmap.aux_nrcpfcgc)
         AND gnappdp.NRPROPOS = aux_nrpropos
         NO-LOCK NO-ERROR.
  /* Caso nao exista deve eliminar os recursos atrelados, 
    para garantir que nao mantenha sujeira na base */  
  IF NOT AVAILABLE gnappdp THEN       
    DO:
        FOR EACH gnaprdp WHERE gnaprdp.idevento = INTEGER(ab_unmap.aux_idevento)
                          AND  gnaprdp.cdcooper = 0
                          BY   gnaprdp.dsrecurs: 
                                                            
                                  
            FIND FIRST craprdf WHERE craprdf.idevento = gnaprdp.idevento
                                 AND craprdf.cdcooper = gnaprdp.cdcooper
                                 AND craprdf.nrcpfcgc = DECIMAL(ab_unmap.aux_nrcpfcgc)
                                 AND craprdf.dspropos = aux_nrpropos
                                 AND craprdf.nrseqdig = gnaprdp.nrseqdig EXCLUSIVE-LOCK  
                                 NO-ERROR.
                          
            IF AVAIL craprdf THEN
            DO:
              DELETE craprdf.
            END.  
        END.       
    END.
    
    
END PROCEDURE.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaRecurso w-html 
PROCEDURE CriaListaRecurso :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    /* Se é a primeira vez deve limpar registros 
       que podem ter ficado de sessoes anteriores */
    IF  REQUEST_METHOD = "GET"  THEN
    DO:
      RUN LimpaRecurso.
    END.  
    
    ASSIGN vetorecurso = "".
    FOR EACH gnaprdp WHERE gnaprdp.idevento = INTEGER(ab_unmap.aux_idevento)
                      AND  gnaprdp.cdcooper = 0
                      BY   gnaprdp.dsrecurs: 
                              
                              
        FIND FIRST craprdf WHERE craprdf.idevento = gnaprdp.idevento
                             AND craprdf.cdcooper = gnaprdp.cdcooper
                             AND craprdf.nrcpfcgc = DECIMAL(ab_unmap.aux_nrcpfcgc)
                             AND craprdf.dspropos = aux_nrpropos
                             AND craprdf.nrseqdig = gnaprdp.nrseqdig NO-LOCK  NO-ERROR.
                      
        IF AVAIL craprdf THEN
        DO:
            IF  vetorecurso = "" THEN
                vetorecurso =
                              "~{" + "nrseqdig:"    + "'" + TRIM(string(gnaprdp.nrseqdig))
                                   + "',dsrecurs:"  + "'" + TRIM(string(gnaprdp.dsrecurs))
                                   + "',rowidrec:"  + "'" + TRIM(string(ROWID(craprdf)))+ "'~}".
            ELSE
               vetorecurso = vetorecurso + "," + 
                              "~{" + "nrseqdig:"    + "'" + TRIM(string(gnaprdp.nrseqdig))
                                   + "',dsrecurs:"  + "'" + TRIM(string(gnaprdp.dsrecurs))
                                   + "',rowidrec:"  + "'" + TRIM(string(ROWID(craprdf)))+ "'~}".
        END.
    
    END. /* for each */
    
    RUN RodaJavaScript("var mrecurso=new Array();mrecurso=["  + vetorecurso + "]").

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
    ("aux_cdtemeix":U,"ab_unmap.aux_cdtemeix":U,ab_unmap.aux_cdtemeix:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdeixtem":U,"ab_unmap.aux_cdeixtem":U,ab_unmap.aux_cdeixtem:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdevento":U,"ab_unmap.aux_cdevento":U,ab_unmap.aux_cdevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsendurl":U,"ab_unmap.aux_dsendurl":U,ab_unmap.aux_dsendurl:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsretorn":U,"ab_unmap.aux_dsretorn":U,ab_unmap.aux_dsretorn:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idevento":U,"ab_unmap.aux_idevento":U,ab_unmap.aux_idevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idexclui":U,"ab_unmap.aux_idexclui":U,ab_unmap.aux_idexclui:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lsfacili":U,"ab_unmap.aux_lsfacili":U,ab_unmap.aux_lsfacili:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lspermis":U,"ab_unmap.aux_lspermis":U,ab_unmap.aux_lspermis:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nmpagina":U,"ab_unmap.aux_nmpagina":U,ab_unmap.aux_nmpagina:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrcpfcgc":U,"ab_unmap.aux_nrcpfcgc":U,ab_unmap.aux_nrcpfcgc:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrdrowid":U,"ab_unmap.aux_nrdrowid":U,ab_unmap.aux_nrdrowid:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_stdopcao":U,"ab_unmap.aux_stdopcao":U,ab_unmap.aux_stdopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("cdeixtem":U,"ab_unmap.cdeixtem":U,ab_unmap.cdeixtem:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nrseqtem":U,"ab_unmap.nrseqtem":U,ab_unmap.nrseqtem:HANDLE IN FRAME {&FRAME-NAME}).     
  RUN htmAssociate
    ("cdevento":U,"ab_unmap.cdevento":U,ab_unmap.cdevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dsconteu":U,"gnappdp.dsconteu":U,gnappdp.dsconteu:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dsmetodo":U,"gnappdp.dsmetodo":U,gnappdp.dsmetodo:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dsobjeti":U,"gnappob.dsobjeti":U,gnappob.dsobjeti:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dsobserv":U,"gnappdp.dsobserv":U,gnappdp.dsobserv:HANDLE IN FRAME {&FRAME-NAME}).
  /*RUN htmAssociate
    ("dspublic":U,"gnappdp.nrseqpap":U,gnappdp.nrseqpap:HANDLE IN FRAME {&FRAME-NAME}).*/
    
   RUN htmAssociate
    ("dsidadpa":U,"gnappdp.dsidadpa":U,gnappdp.dsidadpa:HANDLE IN FRAME {&FRAME-NAME}).
   RUN htmAssociate
    ("dsprereq":U,"gnappdp.dsprereq":U,gnappdp.dsprereq:HANDLE IN FRAME {&FRAME-NAME}).
  
    
  RUN htmAssociate
    ("dtmvtolt":U,"gnappdp.dtmvtolt":U,gnappdp.dtmvtolt:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dtvalpro":U,"gnappdp.dtvalpro":U,gnappdp.dtvalpro:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nmevefor":U,"gnappdp.nmevefor":U,gnappdp.nmevefor:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nrpropos":U,"gnappdp.nrpropos":U,gnappdp.nrpropos:HANDLE IN FRAME {&FRAME-NAME}). 
  RUN htmAssociate
    ("qtcarhor":U,"ab_unmap.qtcarhor":U,ab_unmap.qtcarhor:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("idtrainc":U,"gnappdp.idtrainc":U,gnappdp.idtrainc:HANDLE IN FRAME {&FRAME-NAME}). 
  RUN htmAssociate
    ("txfacili":U,"ab_unmap.txfacili":U,ab_unmap.txfacili:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("vlinvest":U,"gnappdp.vlinvest":U,gnappdp.vlinvest:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("txrecurs":U,"ab_unmap.txrecurs":U,ab_unmap.txrecurs:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_flgtrinc":U,"ab_unmap.aux_flgtrinc":U,ab_unmap.aux_flgtrinc:HANDLE IN FRAME {&FRAME-NAME}).  
    
  RUN htmAssociate
    ("aux_idforrev":U,"ab_unmap.aux_idforrev":U,ab_unmap.aux_idforrev:HANDLE IN FRAME {&FRAME-NAME}).  
   
    RUN htmAssociate
    ("idforrev":U,"gnappdp.idforrev":U,gnappdp.idforrev:HANDLE IN FRAME {&FRAME-NAME}).
   RUN htmAssociate
    ("aux_dspublic":U,"ab_unmap.aux_dspublic":U,ab_unmap.aux_dspublic:HANDLE IN FRAME {&FRAME-NAME}).
    RUN htmAssociate
    ("aux_cdcopope":U,"ab_unmap.aux_cdcopope":U,ab_unmap.aux_cdcopope:HANDLE IN FRAME {&FRAME-NAME}).
    RUN htmAssociate
    ("aux_idvapost":U,"ab_unmap.aux_idvapost":U,ab_unmap.aux_idvapost:HANDLE IN FRAME {&FRAME-NAME}).
    RUN htmAssociate
    ("aux_nrpropos":U,"ab_unmap.aux_nrpropos":U,ab_unmap.aux_nrpropos:HANDLE IN FRAME {&FRAME-NAME}).
    
    
END PROCEDURE.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE inclui-facilitador w-html 
PROCEDURE inclui-facilitador :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
/* Instancia a BO para executar as procedures */
RUN dbo/b1wpgd0012d.p PERSISTENT SET h-b1wpgd0012d.
 
/* Se BO foi instanciada */
IF VALID-HANDLE(h-b1wpgd0012d) THEN
   DO:
 MESSAGE "ab_unmap.aux_lsfacili: " + STRING(ab_unmap.aux_lsfacili).
      /* Busca o registro caso ele nao esteja disponível (acabou de ser incluído) */
      IF   NOT AVAILABLE {&SECOND-ENABLED-TABLE}   THEN
           FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-ERROR.
    
      /* Apaga todos os facilitadores da proposta e recria somente os escolhidos */
      FOR EACH gnfacep WHERE gnfacep.cdcooper = 0                                  AND
                             gnfacep.idevento = INTEGER(ab_unmap.aux_idevento)     AND
                             gnfacep.nrcpfcgc = DECIMAL(ab_unmap.aux_nrcpfcgc)     AND
                             gnfacep.nrpropos = {&SECOND-ENABLED-TABLE}.nrpropos   NO-LOCK:

          EMPTY TEMP-TABLE gtfacep.
          
          CREATE gtfacep.
          BUFFER-COPY gnfacep TO gtfacep.
          
          RUN exclui-registro IN h-b1wpgd0012d(INPUT TABLE gtfacep, OUTPUT msg-erro).
      END.

      /* Vincula os facilitadores escolhidos a proposta */
      DO i = 1 TO NUM-ENTRIES(ab_unmap.aux_lsfacili,","):
         
         FIND gnapfep WHERE ROWID(gnapfep) = TO-ROWID(ENTRY(i,ab_unmap.aux_lsfacili)) NO-LOCK NO-ERROR.

         IF   AVAILABLE gnapfep   THEN
              DO:
                 EMPTY TEMP-TABLE gtfacep.

                 CREATE gtfacep.
                 ASSIGN gtfacep.cdcooper = gnapfep.cdcooper
                        gtfacep.cdfacili = gnapfep.cdfacili
                        gtfacep.idevento = gnapfep.idevento
                        gtfacep.nrcpfcgc = gnapfep.nrcpfcgc
                        gtfacep.nrpropos = {&SECOND-ENABLED-TABLE}.nrpropos.

                 RUN inclui-registro IN h-b1wpgd0012d(INPUT TABLE gtfacep, OUTPUT msg-erro).
                 
              END.              
      END.

      /* "mata" a instância da BO */
      DELETE PROCEDURE h-b1wpgd0012d NO-ERROR.
   END.


END PROCEDURE.

&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE exclui-recurso w-html 
PROCEDURE exclui-recurso :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
/* Instancia a BO para executar as procedures */
RUN dbo/b1wpgd0012e.p PERSISTENT SET h-b1wpgd0012e.
 
/* Se BO foi instanciada */
IF VALID-HANDLE(h-b1wpgd0012e) THEN
   DO:

      /* Busca o registro caso ele nao esteja disponível (acabou de ser incluído) */
      /*IF   NOT AVAILABLE {&SECOND-ENABLED-TABLE}   THEN
           FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-ERROR.
    */
      /* Apaga todos os facilitadores da proposta e recria somente os escolhidos */
      FOR EACH craprdf WHERE  ROWID(craprdf) = TO-ROWID(ab_unmap.aux_nrdrowid)   NO-LOCK:
          EMPTY TEMP-TABLE cratrdf.
          
          CREATE cratrdf.
          BUFFER-COPY craprdf TO cratrdf.
          
          RUN exclui-registro IN h-b1wpgd0012e(INPUT TABLE cratrdf, OUTPUT msg-erro).
      END.


      /* "mata" a instância da BO */
      DELETE PROCEDURE h-b1wpgd0012e NO-ERROR.
   END.

END PROCEDURE.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-assign-record w-html 
PROCEDURE local-assign-record :
DEFINE INPUT PARAMETER opcao AS CHARACTER.

DEFINE VARIABLE aux_qtcarhor AS CHAR NO-UNDO.
DEFINE VARIABLE aux_idtrainc AS CHAR NO-UNDO.
aux_qtcarhor = string(INPUT FRAME {&FRAME-NAME} ab_unmap.qtcarhor).
aux_qtcarhor = REPLACE(aux_qtcarhor, ":", ",").

/* Instancia a BO para executar as procedures */
RUN dbo/b1wpgd0012c.p PERSISTENT SET h-b1wpgd0012c.

/* Se BO foi instanciada */
IF VALID-HANDLE(h-b1wpgd0012c) THEN
   DO: 
      IF INT(ab_unmap.aux_flgtrinc) = 1 THEN
        ASSIGN aux_idtrainc = 'S'.
      ELSE 
        ASSIGN aux_idtrainc = 'N'.
      
      DO WITH FRAME {&FRAME-NAME}:
         IF opcao = "inclusao" THEN
            DO:
                CREATE gnatpdp.
                ASSIGN
                    gnatpdp.cdevento = INT(get-value("aux_cdevento"))
                    gnatpdp.dsconteu = INPUT gnappdp.dsconteu 
                    gnatpdp.dsmetodo = INPUT gnappdp.dsmetodo
                    gnatpdp.dsobserv = INPUT gnappdp.dsobserv
                    /*gnatpdp.dspublic = (ab_unmap.aux_dspublic) */
                    gnatpdp.nrseqpap = INT(ab_unmap.aux_dspublic) 
                    gnatpdp.dsidadpa = INPUT gnappdp.dsidadpa
                    gnatpdp.dsprereq = INPUT gnappdp.dsprereq                    
                    gnatpdp.dtmvtolt = INPUT gnappdp.dtmvtolt
                    gnatpdp.dtvalpro = INPUT gnappdp.dtvalpro
                    gnatpdp.idevento = INT(ab_unmap.aux_idevento)
                    gnatpdp.nmevefor = INPUT gnappdp.nmevefor
                    gnatpdp.nrcpfcgc = DEC(ab_unmap.aux_nrcpfcgc)
                    gnatpdp.nrpropos = INPUT gnappdp.nrpropos
                    gnatpdp.nrctrpro = INT(SUBSTRING(gnatpdp.nrpropos,1,3))
                    gnatpdp.qtcarhor = DEC(aux_qtcarhor)
                    gnatpdp.vlinvest = INPUT gnappdp.vlinvest
                    gnatpdp.idforrev = INT(ab_unmap.aux_idforrev)
                    gnatpdp.idtrainc = aux_idtrainc .
                 
                RUN inclui-registro IN h-b1wpgd0012c
                                               (INPUT TABLE gnatpdp, 
                                                INPUT INPUT gnappob.dsobjeti,
                                                OUTPUT msg-erro, 
                                                OUTPUT ab_unmap.aux_nrdrowid).
            END.
         ELSE  /* alteracao */
            DO: 
                /* cria a temp-table e joga o novo valor digitado para o campo */
                CREATE gnatpdp.
                BUFFER-COPY gnappdp TO gnatpdp.
              
                ASSIGN
                    gnatpdp.cdevento = INT(get-value("aux_cdevento"))
                    gnatpdp.dsconteu = INPUT gnappdp.dsconteu
                    gnatpdp.dsmetodo = INPUT gnappdp.dsmetodo
                    gnatpdp.dsobserv = INPUT gnappdp.dsobserv
                    gnatpdp.dsidadpa = INPUT gnappdp.dsidadpa
                    gnatpdp.dsprereq = INPUT gnappdp.dsprereq 
                    /*gnatpdp.dspublic = (ab_unmap.aux_dspublic) */
                    gnatpdp.nrseqpap = INT(ab_unmap.aux_dspublic) 
                    gnatpdp.dtmvtolt = INPUT gnappdp.dtmvtolt
                    gnatpdp.dtvalpro = INPUT gnappdp.dtvalpro
                    gnatpdp.idevento = INT(ab_unmap.aux_idevento)
                    gnatpdp.nmevefor = INPUT gnappdp.nmevefor
                    gnatpdp.nrcpfcgc = DEC(ab_unmap.aux_nrcpfcgc)
                    gnatpdp.nrpropos = INPUT gnappdp.nrpropos
                    gnatpdp.qtcarhor = DEC(aux_qtcarhor)
                    gnatpdp.vlinvest = INPUT gnappdp.vlinvest
                    gnatpdp.idtrainc = aux_idtrainc
                    gnatpdp.idforrev = INT(ab_unmap.aux_idforrev).
                 
                RUN altera-registro IN h-b1wpgd0012c
                                            (INPUT TABLE gnatpdp, 
                                             INPUT INPUT gnappob.dsobjeti,
                                            OUTPUT msg-erro).
            END.    
      END. /* DO WITH FRAME {&FRAME-NAME} */
   
      /* "mata" a instância da BO */
      DELETE PROCEDURE h-b1wpgd0012c NO-ERROR.
   
   END. /* IF VALID-HANDLE(h-b1wpgd0012c) */
      
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-delete-record w-html 
PROCEDURE local-delete-record :
/* Instancia a BO para executar as procedures */
RUN dbo/b1wpgd0012c.p PERSISTENT SET h-b1wpgd0012c.
 
/* Se BO foi instanciada */
IF VALID-HANDLE(h-b1wpgd0012c) THEN
   DO:
      CREATE gnatpdp.
      BUFFER-COPY gnappdp TO gnatpdp.
          
      RUN exclui-registro IN h-b1wpgd0012c(INPUT TABLE gnatpdp, OUTPUT msg-erro).

      /* "mata" a instância da BO */
      DELETE PROCEDURE h-b1wpgd0012c NO-ERROR.
   END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-display-fields w-html 
PROCEDURE local-display-fields :
RUN displayFields.

IF REQUEST_METHOD = "GET" THEN
   DO: 
      /* Busca o registro caso ele nao esteja disponível */   
      IF NOT AVAILABLE {&SECOND-ENABLED-TABLE}   THEN
         FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-ERROR.
      
      IF AVAIL {&SECOND-ENABLED-TABLE} THEN
         DO: 
             ASSIGN ab_unmap.cdevento = STRING({&SECOND-ENABLED-TABLE}.cdevento).
      
             FIND gnappob WHERE 
                  gnappob.idevento = {&SECOND-ENABLED-TABLE}.idevento AND
                  gnappob.cdcooper = {&SECOND-ENABLED-TABLE}.cdcooper AND
                  gnappob.nrcpfcgc = {&SECOND-ENABLED-TABLE}.nrcpfcgc AND
                  gnappob.nrpropos = {&SECOND-ENABLED-TABLE}.nrpropos
                  NO-LOCK NO-ERROR.

             IF   AVAIL gnappob   THEN
                  ASSIGN 
                    gnappob.dsobjeti:SCREEN-VALUE IN FRAME {&FRAME-NAME} =
                         gnappob.dsobjeti.
         END. 
         
      FIND FIRST crapedp WHERE
          crapedp.cdcooper = 0 AND
          crapedp.dtanoage = 0 AND
          crapedp.cdevento = INT({&FIRST-ENABLED-TABLE}.cdevento) NO-LOCK NO-ERROR.

      IF AVAIL crapedp THEN  
       DO: 
        
          ASSIGN ab_unmap.cdeixtem:SCREEN-VALUE IN FRAME {&FRAME-NAME} = STRING(crapedp.nrseqtem) + "-" + STRING(crapedp.idevento) + "-" + STRING(crapedp.cdcooper) + "-" + STRING(crapedp.cdeixtem)
                 ab_unmap.cdevento:SCREEN-VALUE IN FRAME {&FRAME-NAME} = STRING(crapedp.cdevento)
                 ab_unmap.aux_cdtemeix:SCREEN-VALUE IN FRAME {&FRAME-NAME} = STRING(crapedp.nrseqtem) + "-" + STRING(crapedp.idevento) + "-" + STRING(crapedp.cdcooper) + "-" + STRING(crapedp.cdeixtem).
        END.
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
{ includes/wpgd0009.i }

ASSIGN 
    v-identificacao = get-cookie("cookie-usuario-em-uso")
    v-permissoes    = "IAEPLU".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PosicionaEvento w-html 
PROCEDURE PosicionaEvento :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    RUN RodaJavaScript('PosicionaEvento();').
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

/* Nao traz inicialmente nenhum registro */ 
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
   Nome: includes/webreq.i - Versao WebSpeed 2.1
  Autor: B&T/Solusoft
 Funçao: Processo de requisiçao web p/ cadastros simples na web - Versao WebSpeed 3.0
  Notas: Este é o procedimento principal onde terá as requisiçoes GET e POST.
         GET - É ativa quando o formulário é chamado pela 1a vez
         POST - Após o get somente ocorrerá POST no formulário      
         Caso seja necessário custimizá-lo para algum programa específico 
         Favor cópiar este procedimento para dentro do procedure process-web-requeste 
         faça lá alteraçoes necessárias.
-------------------------------------------------------------------------------*/

v-identificacao = get-cookie("cookie-usuario-em-uso").

/* Usado FOR EACH para poder utilizar o CONTAINS e WORD-INDEX , alterado para MATCHES */
FOR EACH gnapses WHERE gnapses.idsessao MATCHES "*" + v-identificacao + "*" NO-LOCK:
    LEAVE.
END.
  
ASSIGN opcao                 = GET-FIELD("aux_cddopcao")
       FlagPermissoes        = GET-VALUE("aux_lspermis")
       msg-erro-aux          = 0
       ab_unmap.aux_idevento = GET-VALUE("aux_idevento")
       ab_unmap.aux_dsendurl = AppURL                        
       ab_unmap.aux_lspermis = FlagPermissoes                
       ab_unmap.aux_nrdrowid = GET-VALUE("aux_nrdrowid")         
       ab_unmap.aux_stdopcao = GET-VALUE("aux_stdopcao")       
       ab_unmap.aux_cdtemeix = GET-VALUE("aux_cdtemeix")
       ab_unmap.aux_cdeixtem = GET-VALUE("aux_cdeixtem")
       ab_unmap.aux_nrcpfcgc = GET-VALUE("aux_nrcpfcgc")
       ab_unmap.aux_idexclui = GET-VALUE("aux_idexclui")
       ab_unmap.aux_nmpagina = GET-VALUE("aux_nmpagina")
       ab_unmap.aux_lsfacili = GET-VALUE("aux_lsfacili")
       ab_unmap.cdeixtem     = GET-VALUE("cdeixtem")
       ab_unmap.cdevento     = GET-VALUE("cdevento")
       ab_unmap.qtcarhor     = GET-VALUE("qtcarhor")
       operacao              = GET-VALUE("aux_operacao")
       ab_unmap.aux_idforrev = GET-VALUE("aux_idforrev")
       ab_unmap.aux_dspublic = GET-FIELD("aux_dspublic")
       ab_unmap.aux_cdcopope = GET-VALUE("aux_cdcopope")
       ab_unmap.aux_idvapost = GET-VALUE("aux_idvapost")
       ab_unmap.aux_nrpropos = GET-VALUE("aux_nrpropos").
      
      IF GET-VALUE("aux_flgtrinc") = "on" THEN
          ASSIGN ab_unmap.aux_flgtrinc = TRUE.
       ELSE
          ASSIGN ab_unmap.aux_flgtrinc = FALSE.

RUN outputHeader.
aux_craptem = ",0,".

EMPTY TEMP-TABLE temas.

FOR EACH gnapefp WHERE gnapefp.cdcooper = 0                AND
                       gnapefp.nrcpfcgc = dec(ab_unmap.aux_nrcpfcgc) NO-LOCK,
  FIRST gnapetp WHERE gnapetp.cdcooper = 0                AND
                      gnapetp.cdeixtem = gnapefp.cdeixtem NO-LOCK 
                      BY gnapetp.dseixtem:
      
  FOR EACH craptem NO-LOCK WHERE craptem.idevento = 1 
                             AND craptem.idsittem = 'A' 
                             AND craptem.cdeixtem = gnapetp.cdeixtem BY craptem.dstemeix: 
    CREATE temas.
    ASSIGN temas.dstemeix = craptem.dstemeix
           temas.nrseqtem = craptem.nrseqtem
           temas.idevento = craptem.idevento
           temas.cdcooper = craptem.cdcooper
           temas.cdeixtem = craptem.cdeixtem.
    
END.
    
END. /* for each */

FOR EACH temas NO-LOCK BY temas.dstemeix:
    ASSIGN aux_craptem = aux_craptem + temas.dstemeix + "," + string(temas.nrseqtem) + "-" + string(temas.idevento)+ "-" + string(temas.cdcooper)+ "-" + string(temas.cdeixtem) + ",".
END.    

aux_craptem = SUBSTRING(aux_craptem, 1, LENGTH(aux_craptem) - 1).

ASSIGN 
    ab_unmap.aux_cdtemeix:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = aux_craptem.

/***************#################***************/

aux_gnapetp = ",0,".
FOR EACH gnapetp NO-LOCK WHERE
    gnapetp.cdcooper = 0                      AND
    gnapetp.idevento = INT(ab_unmap.aux_idevento),
    FIRST gnapefp NO-LOCK WHERE
          gnapefp.cdcooper = 0                          AND 
          gnapefp.nrcpfcgc = dec(ab_unmap.aux_nrcpfcgc) AND
          gnapefp.cdeixtem = gnapetp.cdeixtem 
          BY gnapetp.dseixtem:

    ASSIGN aux_gnapetp = aux_gnapetp + gnapetp.dseixtem + "," + string(gnapetp.cdeixtem) + ",".
END.

aux_gnapetp = SUBSTRING(aux_gnapetp, 1, LENGTH(aux_gnapetp) - 1).
       
ASSIGN 
    ab_unmap.aux_cdeixtem:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = aux_gnapetp.
    
/***************#################***************/
DEF VAR aux_ano AS INT   NO-UNDO.   
   
IF   operacao = "incluir" THEN 
     DO:        
         /* busca última proposta cadastrada */ 
         FOR LAST b-gnappdp WHERE b-gnappdp.idevento       = INT(ab_unmap.aux_idevento) AND
                                     b-gnappdp.cdcooper       = 0                          AND
                                     YEAR(b-gnappdp.dtmvtolt) = YEAR(TODAY)
                             /*USE-INDEX gnappdp3 removido o indice devido a performace
                               por causa do filtro de ano n*/
                            NO-LOCK 
                              BY b-gnappdp.IDEVENTO      
                              BY b-gnappdp.CDCOOPER      
                              BY b-gnappdp.NRCTRPRO: END.
                              

         IF AVAIL b-gnappdp  THEN
         DO:
            gnappdp.nrpropos:SCREEN-VALUE IN FRAME {&FRAME-NAME} = STRING(b-gnappdp.nrctrpro + 1,"999") + "/" + STRING(YEAR(TODAY),"9999").
            aux_nrpropos = STRING(b-gnappdp.nrctrpro + 1,"999") + "/" + STRING(YEAR(TODAY),"9999").
         END.
         ELSE
         DO:
            gnappdp.nrpropos:SCREEN-VALUE IN FRAME {&FRAME-NAME} = "001/" + STRING(YEAR(TODAY),"9999"). /* Primeira Proposta do ano */ 
            aux_nrpropos = "001/" + STRING(YEAR(TODAY),"9999").
            
         END.
     END.
ELSE
  ASSIGN aux_nrpropos = ab_unmap.aux_nrpropos.
     
/* método POST */
IF REQUEST_METHOD = "POST":U THEN 
   DO:
    
      RUN inputFields.
          
      CASE opcao:
           WHEN "ft" THEN /* fechar tela */
                DO:
                  /* Procedimento para eliminar recursos que estajam 
                     atrelados a proposta caso ela nao esteja salva */
                  RUN LimpaRecurso.
                  RETURN "OK".
                END.
           WHEN "sa" THEN /* salvar */
                DO:
                    IF ab_unmap.aux_stdopcao = "i" THEN /* inclusao */
                        DO:
                            RUN local-assign-record ("inclusao").
                            
                            IF msg-erro <> "" THEN
                              DO:
                                
                                ASSIGN msg-erro-aux = 3. /* erros da validaçao de dados */
                              END.
                            ELSE 
                            DO:
                              
                               /* Se deu certo a inclusao da proposta, aí inclui os facilitadores */
                               RUN inclui-facilitador.

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
                                         ASSIGN msg-erro-aux = 2. /* registro nao existe */
                                         RUN PosicionaNoSeguinte.
                                     END.

                            END.
                        END.  /* fim inclusao */
                    ELSE     /* alteraçao */ 
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
                                      ASSIGN msg-erro-aux = 2. /* registro nao existe */
                                      RUN PosicionaNoSeguinte.
                                  END.
                            ELSE
                               DO:
                                  RUN local-assign-record ("alteracao").  
                                  IF msg-erro = "" THEN
                                     DO:
                                         ASSIGN msg-erro-aux = 10. /* Solicitaçao realizada com sucesso */ 

                                         /* Se deu certo a alteraçao da proposta, aí inclui os facilitadores */
                                         RUN inclui-facilitador.
                                     END.
                                  ELSE
                                     ASSIGN msg-erro-aux = 3. /* erros da validaçao de dados */
                               END.     
                        END. /* fim alteraçao */
                END. /* fim salvar */

          /* Recarrega */
          WHEN "rec" THEN
          DO:
            
              FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
              ASSIGN 
                  opcao = ""
                  msg-erro-aux = 11
                  ab_unmap.aux_cddopcao = "".
          END.
          
          WHEN "exr" THEN /*exclui recurso*/
           DO:
              RUN exclui-recurso.  
              IF msg-erro = "" THEN
                 ASSIGN msg-erro-aux = 10. /* Solicitação realizada com sucesso */ 
              ELSE
                 ASSIGN msg-erro-aux = 3. /* erros da validação de dados */

                 /* IF AVAIL gnapfdp THEN
                      IF gnapfdp.inpessoa = 1 THEN
                          ab_unmap.aux_nrcpfcgc = STRING(gnapfdp.nrcpfcgc, "99999999999").
                      ELSE
                          ab_unmap.aux_nrcpfcgc = STRING(gnapfdp.nrcpfcgc, "99999999999999"). */
                
          END.
           /***
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
                    FIND NEXT {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.cdcooper = 0                              AND
                                                            {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.

                    IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                       ASSIGN aux_nrdrowid-auxiliar = STRING(ROWID({&SECOND-ENABLED-TABLE})).
                    ELSE
                       DO:
                           /* nao encontrou próximo registro entao procura pelo registro anterior para o reposicionamento */
                           FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                           
                           FIND PREV {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.cdcooper = 0                              AND
                                                                   {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.

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
                          ASSIGN msg-erro-aux = 2. /* registro nao existe */
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
                                          
                                       ASSIGN msg-erro-aux = 10. /* Solicitaçao realizada com sucesso */ 
                                   END.
                                ELSE
                                   ASSIGN msg-erro-aux = 3. /* Exclusao rejeitada */ 
                             END.
                          ELSE
                             ASSIGN msg-erro-aux = 3. /* erros da validaçao de dados */
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
                *****/
    
      END CASE.
      
      RUN CriaListaEixos.
      RUN CriaListaEvento.
      RUN CriaListaFacili.
      RUN CriaListaRecurso.
      RUN CriaListaPublicoAlvo.

      IF msg-erro-aux = 10 OR (opcao <> "sa" AND opcao <> "ex" AND opcao <> "in") THEN
         RUN local-display-fields.

      RUN enableFields.
      RUN outputFields.
      RUN PosicionaEvento.

      CASE msg-erro-aux:
           WHEN 1 THEN
                DO:
                    ASSIGN v-qtdeerro      = 1
                           v-descricaoerro = 'Registro esta em uso por outro usuário. Solicitaçao nao pode ser executada. Espere alguns instantes e tente novamente.'.

                    RUN RodaJavaScript('alert("'+ v-descricaoerro + '"); ').
                END.

           WHEN 2 THEN
                RUN RodaJavaScript("alert('Registro foi excluído. Solicitaçao nao pode ser executada.')").
      
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

           WHEN 10 THEN
           DO:
             IF opcao <> "exr" THEN DO:
                RUN RodaJavaScript('window.opener.Recarrega();'). 
                RUN RodaJavaScript('self.close();'). 
               END.
           END.          
         
         
      END CASE.     

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
                                         ab_unmap.aux_idevento = STRING({&SECOND-ENABLED-TABLE}.idevento)
                                         ab_unmap.qtcarhor     = STRING({&SECOND-ENABLED-TABLE}.qtcarhor,"99.99")
                                         ab_unmap.aux_nrpropos = STRING({&SECOND-ENABLED-TABLE}.nrpropos).
                                    FIND NEXT {&SECOND-ENABLED-TABLE} 
                                            NO-LOCK NO-WAIT NO-ERROR.

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
                      DO:
                        RUN PosicionaNoPrimeiro.
                        ASSIGN ab_unmap.aux_nrpropos = aux_nrpropos.
                      END.
                    
                    /* Pega os facilitadores do fornecedor */
                    RUN CriaListaFacili.
                    RUN CriaListaRecurso.
                    RUN CriaListaEixos.
                    RUN CriaListaEvento.
                    RUN CriaListaPublicoAlvo.
                    RUN local-display-fields.
                    RUN enableFields.

                    RUN outputFields.

                    RUN RodaJavaScript('CarregaPrincipal()').
                                     
                    IF GET-VALUE("LinkRowid") = "" THEN
                    DO: 
                        RUN RodaJavaScript('LimparCampos();').
                        RUN RodaJavaScript('Incluir();').
                        RUN RodaJavaScript('document.form.dtmvtolt.value = "' + string(today, "99/99/9999") + '";').
                    END.

                    RUN PosicionaEvento.
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