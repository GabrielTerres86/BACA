/*...............................................................................

Altera��es: 10/12/2008 - Melhoria de performance para a tabela gnapses (Evandro).

			05/06/2012 - Adapta��o dos fontes para projeto Oracle. Alterado
						 busca na gnapses de CONTAINS para MATCHES (Guilherme Maba).

            16/04/2015 - Incluir tratamento na procedire CriaListaPac, se idevento for 
                         1(Progrid) chama o wpgd0099.i se nao, faz como antes 
                         (Lucas Ranghetti #271148)
                         
            18/05/2015 - Inclus�o de novos campos conforme Projeto 229 (Vanessa)
            
            25/08/2015 - Ajustes de homologa�ao( Vanessa)

			29/04/2016 - Correcao na listagem origens de sugestao para nao listar
						 origens do tipo "Avaliacao". (Carlos Rafael Tanholi)
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
       FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_cdorisug AS CHARACTER 
       FIELD aux_datahoje AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nrseqdig AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nrseqeve AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
       FIELD nmtitular    AS CHARACTER FORMAT "X(256)":U 
       FIELD origem       AS CHARACTER FORMAT "X(256)":U 
       FIELD nrseqpri     AS CHARACTER FORMAT "X(256)":U 
       FIELD cdcooper     AS CHARACTER
       FIELD nmpessug     AS CHARACTER FORMAT "X(256)":U
       FIELD nrdddtel     AS CHARACTER FORMAT "X(256)":U
       FIELD nrtelcto     AS CHARACTER FORMAT "X(256)":U
       FIELD nrdddcel     AS CHARACTER FORMAT "X(256)":U
       FIELD nrcelcto     AS CHARACTER FORMAT "X(256)":U
       FIELD dsemlcto     AS CHARACTER FORMAT "X(256)":U
       FIELD aux_cdcodpri AS CHARACTER FORMAT "X(256)":U.
       
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
DEFINE VARIABLE ProgramaEmUso         AS CHARACTER INITIAL ["wpgd0011"].
DEFINE VARIABLE NmeDoPrograma         AS CHARACTER INITIAL ["wpgd0011.w"].

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
DEFINE VARIABLE h-b1wpgd0011          AS HANDLE                         NO-UNDO.

/*** Temp Tables ***/
DEFINE TEMP-TABLE cratsdp             LIKE crapsdp.

DEFINE VARIABLE aux_tporigem          AS CHAR                           NO-UNDO.
DEFINE VARIABLE aux_nmprimtl          AS CHAR                           NO-UNDO.
DEFINE VARIABLE aux_crapcop           AS CHAR                           NO-UNDO.
DEFINE VARIABLE vetorpac              AS CHAR                           NO-UNDO.
DEFINE VARIABLE aux_nmprcins          AS CHAR                           NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE fontes/wpgd0011.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS crapsdp.cdagenci crapsdp.dssugeve ~
crapsdp.dtmvtolt crapsdp.idseqttl crapsdp.nrdconta crapsdp.nrseqdig ~
crapsdp.qtsugeve crapsdp.nmpessug crapsdp.nrdddtel crapsdp.nrtelcto ~
crapsdp.nrdddcel crapsdp.nrcelcto crapsdp.dsemlcto crapsdp.nrseqpri
&Scoped-define ENABLED-TABLES ab_unmap crapsdp
&Scoped-define FIRST-ENABLED-TABLE ab_unmap
&Scoped-define SECOND-ENABLED-TABLE crapsdp

&Scoped-Define ENABLED-OBJECTS ab_unmap.aux_datahoje ab_unmap.aux_nrseqeve ~
ab_unmap.origem ab_unmap.aux_cdagenci ab_unmap.aux_cdcooper ~
ab_unmap.aux_cddopcao ab_unmap.aux_cdorisug ab_unmap.aux_dsendurl ~
ab_unmap.aux_dsretorn ab_unmap.aux_idevento ab_unmap.aux_lspermis ~
ab_unmap.aux_nrdrowid ab_unmap.aux_nrseqdig ab_unmap.aux_stdopcao ~
ab_unmap.nmtitular    ab_unmap.cdcooper     ab_unmap.nmpessug ~
ab_unmap.nrdddtel     ab_unmap.nrtelcto     ab_unmap.nrdddcel ~
ab_unmap.nrcelcto     ab_unmap.dsemlcto     ab_unmap.aux_cdcodpri 

&Scoped-Define DISPLAYED-FIELDS crapsdp.cdagenci crapsdp.dssugeve ~
crapsdp.dtmvtolt crapsdp.idseqttl crapsdp.nrdconta crapsdp.nrseqdig ~
crapsdp.qtsugeve crapsdp.nmpessug crapsdp.nrdddtel crapsdp.nrtelcto ~
crapsdp.nrdddcel crapsdp.nrcelcto crapsdp.dsemlcto crapsdp.nrseqpri
&Scoped-define DISPLAYED-TABLES ab_unmap crapsdp
&Scoped-define FIRST-DISPLAYED-TABLE ab_unmap
&Scoped-define SECOND-DISPLAYED-TABLE crapsdp
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.aux_datahoje ~
ab_unmap.aux_nrseqeve ab_unmap.origem ab_unmap.aux_cdagenci ~
ab_unmap.aux_cdcooper ab_unmap.aux_cddopcao ab_unmap.aux_cdorisug ~
ab_unmap.aux_dsendurl ab_unmap.aux_dsretorn ab_unmap.aux_idevento ~
ab_unmap.aux_lspermis ab_unmap.aux_nrdrowid ab_unmap.aux_nrseqdig ~
ab_unmap.aux_stdopcao ab_unmap.nmtitular    ab_unmap.cdcooper ~
ab_unmap.nmpessug     ab_unmap.nrdddtel     ab_unmap.nrtelcto ~
ab_unmap.nrdddcel     ab_unmap.nrcelcto     ab_unmap.dsemlcto ~
ab_unmap.aux_cdcodpri    

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME

/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     ab_unmap.aux_datahoje AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nrseqeve AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.origem AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    
     ab_unmap.aux_cdagenci AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.aux_cdcooper AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.cdcooper AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cddopcao AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     
    ab_unmap.aux_cdorisug AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG SORT 
          SIZE 20 BY 4
          
     ab_unmap.aux_cdcodpri AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG SORT 
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
     
     crapsdp.cdagenci AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1

     crapsdp.nrseqpri AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1

     crapsdp.dssugeve AT ROW 1 COL 1 NO-LABEL
          VIEW-AS EDITOR NO-WORD-WRAP
          SIZE 20 BY 4
     crapsdp.dtmvtolt AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapsdp.idseqttl AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.nmtitular AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    /***************/
    crapsdp.nmpessug AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    crapsdp.nrdddtel AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    crapsdp.nrtelcto AT ROW 1 COL 1 FORMAT "zzzzzzzzzz9":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    crapsdp.nrdddcel AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    crapsdp.nrcelcto AT ROW 1 COL 1 FORMAT "zzzzzzzzzz9":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    crapsdp.dsemlcto AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    /***************/
     crapsdp.nrdconta AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapsdp.nrseqdig AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapsdp.qtsugeve AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 71.4 BY 19.29.

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
          FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_cdorisug AS CHARACTER 
          FIELD aux_datahoje AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nrseqdig AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nrseqeve AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
          FIELD nmtitular AS CHARACTER FORMAT "X(256)":U 
          FIELD origem AS CHARACTER FORMAT "X(256)":U 
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW w-html ASSIGN
         HEIGHT             = 19.29
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
/* SETTINGS FOR FILL-IN ab_unmap.aux_cddopcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_cdorisug IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN ab_unmap.aux_datahoje IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dsendurl IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dsretorn IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_idevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lspermis IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nrdrowid IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nrseqdig IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nrseqeve IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_stdopcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN crapsdp.cdagenci IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR EDITOR crapsdp.dssugeve IN FRAME Web-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN crapsdp.dtmvtolt IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN crapsdp.idseqttl IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN ab_unmap.nmtitular IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN crapsdp.nrdconta IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN crapsdp.nrseqdig IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN ab_unmap.origem IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN crapsdp.qtsugeve IN FRAME Web-Frame
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaPac w-html 
PROCEDURE CriaListaPac :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

   /* Progrid */
   IF INT(ab_unmap.aux_idevento) = 1 THEN
      { includes/wpgd0099.i STRING(YEAR(TODAY)) }
   ELSE /* Assembleias */
      {includes/wpgd0097.i}
    
    RUN RodaJavaScript("var mpac=new Array();mpac=["  + vetorpac + "]"). 
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaParceriaInst w-html 
PROCEDURE CriaParceriaInst :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
   
------------------------------------------------------------------------------*/
    ASSIGN aux_nmprcins = ',0' .
    FOR EACH crappri NO-LOCK WHERE crappri.idsitpri = "A":
        ASSIGN aux_nmprcins  = aux_nmprcins  +
                              ',' + 
                              crappri.nmprcins + ',' +
                              STRING(crappri.nrseqpri).
    END.

    ASSIGN aux_cdcodpri:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = aux_nmprcins.

END PROCEDURE. 

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaOrigemSug w-html 
PROCEDURE CriaOrigemSug :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
	
    FIND FIRST craptab WHERE craptab.cdcooper = 0               AND
                             craptab.nmsistem = "CRED"          AND
                             craptab.tptabela = "CONFIG"        AND
                             craptab.cdempres = 0               AND
                             craptab.cdacesso = "PGTPORIGEM"    AND
                             craptab.tpregist = 0               NO-LOCK NO-ERROR.
    
    ASSIGN aux_cdorisug:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = craptab.dstextab.

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
    ("cdcooper":U,"ab_unmap.cdcooper":U,ab_unmap.cdcooper:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cddopcao":U,"ab_unmap.aux_cddopcao":U,ab_unmap.aux_cddopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdorisug":U,"ab_unmap.aux_cdorisug":U,ab_unmap.aux_cdorisug:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdcodpri":U,"ab_unmap.aux_cdcodpri":U,ab_unmap.aux_cdcodpri:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_datahoje":U,"ab_unmap.aux_datahoje":U,ab_unmap.aux_datahoje:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsendurl":U,"ab_unmap.aux_dsendurl":U,ab_unmap.aux_dsendurl:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsretorn":U,"ab_unmap.aux_dsretorn":U,ab_unmap.aux_dsretorn:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idevento":U,"ab_unmap.aux_idevento":U,ab_unmap.aux_idevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lspermis":U,"ab_unmap.aux_lspermis":U,ab_unmap.aux_lspermis:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrdrowid":U,"ab_unmap.aux_nrdrowid":U,ab_unmap.aux_nrdrowid:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrseqdig":U,"ab_unmap.aux_nrseqdig":U,ab_unmap.aux_nrseqdig:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrseqeve":U,"ab_unmap.aux_nrseqeve":U,ab_unmap.aux_nrseqeve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_stdopcao":U,"ab_unmap.aux_stdopcao":U,ab_unmap.aux_stdopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("cdagenci":U,"crapsdp.cdagenci":U,crapsdp.cdagenci:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dssugeve":U,"crapsdp.dssugeve":U,crapsdp.dssugeve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dtmvtolt":U,"crapsdp.dtmvtolt":U,crapsdp.dtmvtolt:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("idseqttl":U,"crapsdp.idseqttl":U,crapsdp.idseqttl:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nmtitular":U,"ab_unmap.nmtitular":U,ab_unmap.nmtitular:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nrdconta":U,"crapsdp.nrdconta":U,crapsdp.nrdconta:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nrseqdig":U,"crapsdp.nrseqdig":U,crapsdp.nrseqdig:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("origem":U,"ab_unmap.origem":U,ab_unmap.origem:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("qtsugeve":U,"crapsdp.qtsugeve":U,crapsdp.qtsugeve:HANDLE IN FRAME {&FRAME-NAME}).
  
  RUN htmAssociate
    ("nrseqpri":U,"crapsdp.nrseqpri":U,crapsdp.nrseqpri:HANDLE IN FRAME {&FRAME-NAME}).

  RUN htmAssociate
    ("nmpessug":U,"crapsdp.nmpessug":U,crapsdp.nmpessug:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nrdddtel":U,"crapsdp.nrdddtel":U,crapsdp.nrdddtel:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nrtelcto":U,"crapsdp.nrtelcto":U,crapsdp.nrtelcto:HANDLE IN FRAME {&FRAME-NAME}).
   RUN htmAssociate
    ("nrdddcel":U,"crapsdp.nrtelcto":U,crapsdp.nrdddcel:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nrcelcto":U,"crapsdp.nrcelcto":U,crapsdp.nrcelcto:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dsemlcto":U,"crapsdp.dsemlcto":U,crapsdp.dsemlcto:HANDLE IN FRAME {&FRAME-NAME}).
END PROCEDURE.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-assign-record w-html 
PROCEDURE local-assign-record :
DEFINE INPUT PARAMETER opcao AS CHARACTER.
    
    /* Instancia a BO para executar as procedures */
    RUN dbo/b1wpgd0011.p PERSISTENT SET h-b1wpgd0011.
    
    /* Se BO foi instanciada */
    IF VALID-HANDLE(h-b1wpgd0011) THEN
       DO:
          DO WITH FRAME {&FRAME-NAME}:
             IF opcao = "inclusao" THEN
                DO: 
              
                    CREATE cratsdp.
                    ASSIGN
                        cratsdp.cdagenci = INT(GET-VALUE("aux_cdagenci"))
                        cratsdp.cdcooper = INT(ab_unmap.aux_cdcooper)
                        cratsdp.cdevento = ?
                        cratsdp.cdoperad = gnapses.cdoperad
                        cratsdp.cdorisug = INT(INPUT ab_unmap.aux_cdorisug)
                        cratsdp.dssugeve = INPUT crapsdp.dssugeve
                        cratsdp.dtanoage = ?
                        cratsdp.dtmvtolt = TODAY
                        cratsdp.idevento = int(ab_unmap.aux_idevento)
                        cratsdp.idseqttl = INPUT crapsdp.idseqttl
                        cratsdp.nrdconta = INPUT crapsdp.nrdconta
                        cratsdp.nrmsgint = INT(ab_unmap.aux_nrseqeve)
                        /*cratsdp.nrseqdig = INPUT crapsdp.nrseqdig*/
                        cratsdp.nmpessug = INPUT crapsdp.nmpessug
                        cratsdp.nrdddtel = INT(INPUT crapsdp.nrdddtel)
                        cratsdp.nrtelcto = INT(INPUT crapsdp.nrtelcto)
                        cratsdp.nrdddcel = INT(INPUT crapsdp.nrdddcel)
                        cratsdp.nrcelcto = INT(INPUT crapsdp.nrcelcto)
                        cratsdp.dsemlcto = INPUT crapsdp.dsemlcto
                        cratsdp.qtsugeve = INPUT crapsdp.qtsugeve
                        cratsdp.nrseqpri = INT(INPUT ab_unmap.aux_cdcodpri)
                        cratsdp.nrseqtem = ?
                        cratsdp.flgsugca = NO.
    
                    RUN inclui-registro IN h-b1wpgd0011(INPUT TABLE cratsdp, OUTPUT msg-erro, OUTPUT ab_unmap.aux_nrdrowid).
                    
                END.
             ELSE  /* alteracao */
                DO:
                    /* cria a temp-table e joga o novo valor digitado para o campo */
                    CREATE cratsdp.
                    BUFFER-COPY crapsdp  TO cratsdp.
    
                    ASSIGN
                        /*cratsdp.cdagenci = INT(GET-VALUE("aux_cdagenci"))*/
                        /*cratsdp.cdcooper = INT(ab_unmap.aux_cdcooper)*/
                        cratsdp.cdevento = ?
                        cratsdp.cdoperad = gnapses.cdoperad
                        cratsdp.cdorisug = INT(INPUT ab_unmap.aux_cdorisug)
                        cratsdp.dssugeve = INPUT crapsdp.dssugeve
                        cratsdp.dtanoage = ?
                        cratsdp.dtmvtolt = TODAY
                        /*cratsdp.idevento = int(ab_unmap.aux_idevento)*/
                        cratsdp.idseqttl = INPUT crapsdp.idseqttl
                        cratsdp.nrdconta = INPUT crapsdp.nrdconta
                        /*cratsdp.nrmsgint = INPUT crapsdp.nrmsgint*/
                        /*cratsdp.nrseqdig = INPUT crapsdp.nrseqdig*/
                        cratsdp.nmpessug = INPUT crapsdp.nmpessug
                        cratsdp.nrdddtel = INT(INPUT crapsdp.nrdddtel)
                        cratsdp.nrtelcto = INT(INPUT crapsdp.nrtelcto)
                        cratsdp.nrdddcel = INT(INPUT crapsdp.nrdddcel)
                        cratsdp.nrcelcto = INT(INPUT crapsdp.nrcelcto)
                        cratsdp.dsemlcto = INPUT crapsdp.dsemlcto
                        cratsdp.qtsugeve = INPUT crapsdp.qtsugeve
                        cratsdp.nrseqpri = INT(INPUT ab_unmap.aux_cdcodpri)
                        cratsdp.nrseqtem = ?
                        cratsdp.flgsugca = NO.
                     
                    RUN altera-registro IN h-b1wpgd0011(INPUT TABLE cratsdp, OUTPUT msg-erro).
                END.    
          END. /* DO WITH FRAME {&FRAME-NAME} */
       
          /* "mata" a inst�ncia da BO */
          DELETE PROCEDURE h-b1wpgd0011 NO-ERROR.
       
       END. /* IF VALID-HANDLE(h-b1wpgd0011) */
      
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-delete-record w-html 
PROCEDURE local-delete-record :
/* Instancia a BO para executar as procedures */
    RUN dbo/b1wpgd0011.p PERSISTENT SET h-b1wpgd0011.
     
    /* Se BO foi instanciada */
    IF VALID-HANDLE(h-b1wpgd0011) THEN
       DO:
          CREATE cratsdp.
          BUFFER-COPY crapsdp TO cratsdp.
              
          RUN exclui-registro IN h-b1wpgd0011(INPUT TABLE cratsdp, OUTPUT msg-erro).
    
          /* "mata" a inst�ncia da BO */
          DELETE PROCEDURE h-b1wpgd0011 NO-ERROR.
       END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-display-fields w-html 
PROCEDURE local-display-fields :
RUN displayFields.
    
    IF AVAIL crapsdp THEN
    DO:
        ASSIGN
            ab_unmap.aux_cdcooper:SCREEN-VALUE IN FRAME {&FRAME-NAME} = string(crapsdp.cdcooper).
    
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PosicionaNoAnterior w-html 
PROCEDURE PosicionaNoAnterior :
/* O pre-processador {&SECOND-ENABLED-TABLE} tem como valor, o nome da tabela usada */
/*
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
ELSE */
   RUN PosicionaNoPrimeiro.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PosicionaNoPrimeiro w-html 
PROCEDURE PosicionaNoPrimeiro :
CASE gnapses.nvoperad:
    /* Pessoal da CECRED */
            WHEN 0 THEN
            DO:
                FIND FIRST {&SECOND-ENABLED-TABLE} WHERE 
                    {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.
            END.
            /* Operadores e Supervisores */
            WHEN 1 OR 
            WHEN 2 THEN
            DO:
                FIND FIRST {&SECOND-ENABLED-TABLE} WHERE 
                    {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) AND
                    {&SECOND-ENABLED-TABLE}.cdcooper = gnapses.cdcooper AND
                    {&SECOND-ENABLED-TABLE}.cdagenci = gnapses.cdagenci
                    NO-LOCK NO-WAIT NO-ERROR.

            END.
            /* Gerentes */
            WHEN 3 THEN
            DO:
                FIND FIRST {&SECOND-ENABLED-TABLE} WHERE 
                    {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) AND
                    {&SECOND-ENABLED-TABLE}.cdcooper = gnapses.cdcooper 
                    NO-LOCK NO-WAIT NO-ERROR.
            END.
END CASE.

IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
    ASSIGN ab_unmap.aux_nrdrowid  = "?"
           ab_unmap.aux_stdopcao = "".
ELSE
    ASSIGN ab_unmap.aux_nrdrowid  = STRING(ROWID({&SECOND-ENABLED-TABLE}))
           ab_unmap.aux_stdopcao = "".  /* aqui p */

/*/* N�o traz inicialmente nenhum registro */ 
RELEASE {&SECOND-ENABLED-TABLE}.

ASSIGN ab_unmap.aux_nrdrowid  = "?"
       ab_unmap.aux_stdopcao = "".*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PosicionaNoSeguinte w-html 
PROCEDURE PosicionaNoSeguinte :
/*FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.


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
    RUN PosicionaNoUltimo.*/
    
RUN PosicionaNoPrimeiro.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PosicionaNoUltimo w-html 
PROCEDURE PosicionaNoUltimo :
/*FIND LAST {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.

IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
    ASSIGN ab_unmap.aux_nrdrowid = "?".
ELSE
    ASSIGN ab_unmap.aux_nrdrowid  = STRING(ROWID({&SECOND-ENABLED-TABLE}))
           ab_unmap.aux_stdopcao = "".   /* aqui u */*/
           
           
           
RUN PosicionaNoPrimeiro.           

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
       /*ab_unmap.aux_cdagenci    = GET-VALUE("aux_cdagenci")*/
       ab_unmap.aux_cdorisug    = GET-VALUE("aux_cdorisug")
       ab_unmap.origem          = GET-VALUE("origem")
       ab_unmap.nrseqpri        = GET-VALUE("nrseqpri")
       ab_unmap.aux_nrseqeve    = GET-VALUE("aux_nrseqeve")
       ab_unmap.aux_datahoje    = STRING(TODAY, "99/99/9999")
       ab_unmap.nmtitular       = GET-VALUE("nmtitular").

RUN outputHeader.

{includes/wpgd0098.i}

ab_unmap.aux_cdcooper:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = aux_crapcop.

RUN CriaListaPac.

RUN criaOrigemSug.

RUN CriaParceriaInst.
   
/* m�todo POST */

IF REQUEST_METHOD = "POST":U THEN 
   DO:
      RUN inputFields.

      /* Instancia a BO para executar as procedures */
      RUN dbo/b1wpgd0011.p PERSISTENT SET h-b1wpgd0011.

      /* Se BO foi instanciada */
      IF VALID-HANDLE(h-b1wpgd0011) THEN
         DO:
            RUN posiciona-registro IN h-b1wpgd0011(INPUT TO-ROWID(ab_unmap.aux_nrdrowid), OUTPUT msg-erro).
            DELETE PROCEDURE h-b1wpgd0011 NO-ERROR.
         END.

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
                    /*FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.

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
                       END.  */        
                       
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

                                              ASSIGN ab_unmap.aux_cdorisug = STRING({&SECOND-ENABLED-TABLE}.cdorisug)
                                                     ab_unmap.cdcooper     = STRING({&SECOND-ENABLED-TABLE}.cdcooper).

                                              /* Busca o nome do associado */
                                              FIND FIRST crapttl WHERE crapttl.cdcooper = {&SECOND-ENABLED-TABLE}.cdcooper AND
                                                                       crapttl.nrdconta = {&SECOND-ENABLED-TABLE}.nrdconta AND
                                                                       crapttl.idseqttl = {&SECOND-ENABLED-TABLE}.idseqttl NO-LOCK NO-ERROR.
                        
                                              ASSIGN ab_unmap.aux_nrdrowid = STRING(ROWID({&SECOND-ENABLED-TABLE}))
                                                     ab_unmap.aux_idevento = STRING({&SECOND-ENABLED-TABLE}.idevento)
                                                     ab_unmap.aux_cdorisug = STRING({&SECOND-ENABLED-TABLE}.cdorisug)
                                                     ab_unmap.nmtitular    = IF AVAIL crapttl THEN crapttl.nmextttl
                                                                             ELSE "".

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
    
      END CASE.

      IF msg-erro-aux = 10 OR (opcao <> "sa" AND opcao <> "ex" AND opcao <> "in") THEN
         RUN displayFields.
 
      RUN enableFields.
      RUN outputFields.

      CASE msg-erro-aux:
           WHEN 1 THEN
                DO:
                    ASSIGN v-qtdeerro      = 1
                           v-descricaoerro = 'Registro esta em uso por outro usu�rio. Solicita��o n�o pode ser executada. Espere alguns instantes e tente novamente.'.

                    RUN RodaJavaScript('alert("'+ v-descricaoerro + '"); ').
                END.

           WHEN 2 THEN
                RUN RodaJavaScript("alert('Registro foi exclu�do. Solicita��o n�o pode ser executada.')").
      
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
                   IF  ab_unmap.origem = "ava" THEN
                       RUN RodaJavaScript("Avaliacao();").

                   RUN RodaJavaScript('alert("Atualizacao executada com sucesso.")'). 
                   RUN RodaJavaScript('TravaTudo();').
                   IF ab_unmap.origem = "ava" THEN
                      DO:
                          RUN RodaJavaScript('window.opener.Salvar();').
                          RUN RodaJavaScript('self.close();'). 
                      END.
           END.
                
         
      END CASE.     

      /*RUN RodaJavaScript('top.frames[0].ZeraOp()').   */

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
                                  /* Busca o nome do associado */
                                  FIND FIRST crapttl WHERE crapttl.cdcooper = {&SECOND-ENABLED-TABLE}.cdcooper AND
                                                           crapttl.nrdconta = {&SECOND-ENABLED-TABLE}.nrdconta AND
                                                           crapttl.idseqttl = {&SECOND-ENABLED-TABLE}.idseqttl NO-LOCK NO-ERROR.

                                  ASSIGN ab_unmap.aux_nrdrowid = STRING(ROWID({&SECOND-ENABLED-TABLE}))
                                         ab_unmap.aux_idevento = STRING({&SECOND-ENABLED-TABLE}.idevento)
                                         ab_unmap.aux_cdorisug = STRING({&SECOND-ENABLED-TABLE}.cdorisug)
                                         ab_unmap.cdcooper     = STRING({&SECOND-ENABLED-TABLE}.cdcooper)
                                         ab_unmap.nmtitular    = IF AVAIL crapttl THEN crapttl.nmextttl
                                                                                  ELSE "".
                                         /*ab_unmap.aux_cdagenci = STRING({&SECOND-ENABLED-TABLE}.cdagenci).*/

                                  /* Para carregar a cooperativa de acordo com o registro carregado */
                                  SET-USER-FIELD("aux_idevento",ab_unmap.aux_idevento).
                                  aux_crapcop = "".
                                  {includes/wpgd0098.i}
                                  ab_unmap.aux_cdcooper:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = aux_crapcop.
                                  
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

                    RUN displayFields.
                    RUN enableFields.
                    RUN outputFields.
                    /*RUN RodaJavaScript('top.frcod.FechaZoom()').*/
                    RUN RodaJavaScript('CarregaPrincipal();').

                    
                    IF GET-VALUE("LinkRowid") = "" THEN
                    DO:
                        RUN RodaJavaScript('LimparCampos();').
                        RUN RodaJavaScript('Incluir();').
                        RUN RodaJavaScript('document.form.dtmvtolt.value = "' + STRING(TODAY, "99/99/9999") + '"').

                        IF ab_unmap.origem = "ava" THEN
                        DO:
                            /* Assumimos que o tipo de origem AVALIA��O tem c�digo 7 */
                            RUN RodaJavaScript("document.form.aux_cdorisug.value = '7';").
                            RUN RodaJavaScript("document.form.aux_cdcooper.value = '" + GET-VALUE("aux_cdcooper") + "';").
                            RUN RodaJavaScript("document.form.cdagenci.value = '" + GET-VALUE("cdagenci") + "';").
                            RUN RodaJavaScript("document.form.nrseqpri.value = '" + GET-VALUE("nrseqpri") + "';").
                            RUN RodaJavaScript("Avaliacao();").

                        END.
                    END.
                    ELSE
                        RUN RodaJavaScript('TravaTudo();').
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




