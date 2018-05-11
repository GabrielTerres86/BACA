&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
/* ......................................................................

Alterações: 24/01/2008 - Incluído campo crapldp.dsrefloc (Diego).

            10/12/2008 - Melhoria de performance para a tabela gnapses (Evandro).
			
			05/06/2012 - Adaptação dos fontes para projeto Oracle. Alterado
						 busca na gnapses de CONTAINS para MATCHES (Guilherme Maba).

            24/06/2016 - Inclusão da janela na tela de Agenda Anual RF05 - Vanessa	

            09/11/2016 - Inclusao de LOG. (Jean Michel)

            10/03/2017 - Inclusao de novos campos, Prj. 322. (Jean Michel)

......................................................................... */

{ sistema/generico/includes/var_log_progrid.i }

&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD aux_cdagenci AS CHARACTER 
       FIELD aux_cdcooper AS CHARACTER 
       FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nrseqdig AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U
       FIELD aux_origem   AS CHARACTER FORMAT "X(256)":U
       FIELD aux_cdcopope AS CHARACTER FORMAT "X(256)":U
       FIELD aux_cdoperad AS CHARACTER FORMAT "X(256)":U
       FIELD hdn_cdagenci AS CHARACTER FORMAT "X(256)":U
       FIELD hdn_cdcooper AS CHARACTER FORMAT "X(256)":U
       FIELD aux_idsonori AS CHARACTER FORMAT "X(256)":U
       FIELD aux_idprojet AS CHARACTER FORMAT "X(256)":U
       FIELD aux_idtelpro AS CHARACTER FORMAT "X(256)":U
       FIELD aux_idcadeir AS CHARACTER FORMAT "X(256)":U
       FIELD aux_idclimat AS CHARACTER FORMAT "X(256)":U
       FIELD aux_idacecad AS CHARACTER FORMAT "X(256)":U
       FIELD aux_idestaci AS CHARACTER FORMAT "X(256)":U
       FIELD aux_idloceva AS CHARACTER FORMAT "X(256)":U
       FIELD aux_dsdiaind AS LOGICAL
       FIELD tel_dsdiaind AS CHARACTER FORMAT "X(256)":U
       FIELD aux_nrceprua AS CHARACTER FORMAT "X(256)":U       
       FIELD aux_dsendtel AS CHARACTER FORMAT "X(256)":U
       FIELD aux_nmbaitel AS CHARACTER FORMAT "X(256)":U
       FIELD aux_nmcidtel AS CHARACTER FORMAT "X(256)":U.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w-html 

CREATE WIDGET-POOL.

DEFINE VARIABLE ProgramaEmUso AS CHARACTER INITIAL ["wpgd0013"].
DEFINE VARIABLE NmeDoPrograma AS CHARACTER INITIAL ["wpgd0013.w"].

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

DEFINE VARIABLE h-b1wpgd0013          AS HANDLE                         NO-UNDO.

DEFINE TEMP-TABLE cratldp             LIKE crapldp.

DEFINE VARIABLE aux_crapcop AS CHAR NO-UNDO.

DEFINE VARIABLE vetorpac AS CHAR NO-UNDO.

&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE fontes/wpgd0013.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS crapldp.dsendloc crapldp.dsestloc ~
crapldp.dslocali crapldp.dsobserv crapldp.nmbailoc crapldp.nmcidloc ~
crapldp.nmconloc crapldp.nrceploc crapldp.nrdddfax crapldp.nrdddtel ~
crapldp.nrfaxsim crapldp.nrtelefo crapldp.qtmaxpes crapldp.vldialoc ~
crapldp.dsrefloc crapldp.dsmotind
&Scoped-define ENABLED-TABLES ab_unmap crapldp
&Scoped-define FIRST-ENABLED-TABLE ab_unmap
&Scoped-define SECOND-ENABLED-TABLE crapldp
&Scoped-Define ENABLED-OBJECTS ab_unmap.aux_cdagenci ab_unmap.aux_cdcooper ~
ab_unmap.aux_cddopcao ab_unmap.aux_dsendurl ab_unmap.aux_dsretorn ~
ab_unmap.aux_idevento ab_unmap.aux_lspermis ab_unmap.aux_nrdrowid ~
ab_unmap.aux_nrseqdig ab_unmap.aux_stdopcao ab_unmap.aux_origem ~
ab_unmap.aux_cdcopope ab_unmap.aux_cdoperad ~
ab_unmap.hdn_cdagenci ab_unmap.hdn_cdcooper ab_unmap.aux_dsdiaind ab_unmap.aux_idloceva ~
ab_unmap.aux_idsonori ab_unmap.aux_idprojet ~
ab_unmap.aux_idtelpro ab_unmap.aux_idcadeir ab_unmap.aux_idclimat ~
ab_unmap.aux_idacecad ab_unmap.aux_idestaci ab_unmap.tel_dsdiaind ~
ab_unmap.aux_nrceprua ab_unmap.aux_dsendtel ab_unmap.aux_nmbaitel ~
ab_unmap.aux_nmcidtel
&Scoped-Define DISPLAYED-FIELDS crapldp.dsendloc crapldp.dsestloc ~
crapldp.dslocali crapldp.dsobserv crapldp.nmbailoc crapldp.nmcidloc ~
crapldp.nmconloc crapldp.nrceploc crapldp.nrdddfax crapldp.nrdddtel ~
crapldp.nrfaxsim crapldp.nrtelefo crapldp.qtmaxpes crapldp.vldialoc ~
crapldp.dsrefloc crapldp.dsmotind
&Scoped-define DISPLAYED-TABLES ab_unmap crapldp
&Scoped-define FIRST-DISPLAYED-TABLE ab_unmap
&Scoped-define SECOND-DISPLAYED-TABLE crapldp
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.aux_cdagenci ~
ab_unmap.aux_cdcooper ab_unmap.aux_cddopcao ab_unmap.aux_dsendurl ~
ab_unmap.aux_dsretorn ab_unmap.aux_idevento ab_unmap.aux_lspermis ~
ab_unmap.aux_nrdrowid ab_unmap.aux_nrseqdig ab_unmap.aux_stdopcao ~
ab_unmap.aux_origem ab_unmap.aux_cdcopope ~
ab_unmap.aux_cdoperad ab_unmap.hdn_cdagenci ab_unmap.aux_dsdiaind ~
ab_unmap.aux_idloceva ab_unmap.aux_idsonori ab_unmap.hdn_cdcooper ~
ab_unmap.aux_idprojet ab_unmap.aux_idtelpro ab_unmap.aux_idcadeir ~
ab_unmap.aux_idclimat ab_unmap.aux_idacecad ab_unmap.aux_idestaci ~
ab_unmap.tel_dsdiaind ab_unmap.aux_nrceprua ab_unmap.aux_dsendtel ~
ab_unmap.aux_nmbaitel ab_unmap.aux_nmcidtel

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME

DEFINE FRAME Web-Frame
     ab_unmap.aux_cdagenci AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.aux_cdcooper AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.aux_idsonori AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.aux_idprojet AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4     
     ab_unmap.aux_idtelpro AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.aux_idcadeir AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.aux_idclimat AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4          
     ab_unmap.aux_idacecad AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4          
     ab_unmap.aux_idestaci AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4         
     ab_unmap.aux_idloceva AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4          
     crapldp.dsmotind AT ROW 1 COL 1 NO-LABEL
          VIEW-AS EDITOR NO-WORD-WRAP
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
     ab_unmap.aux_nrseqdig AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_stdopcao AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapldp.dsendloc AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapldp.dsestloc AT ROW 1 COL 1 NO-LABEL
          VIEW-AS EDITOR NO-WORD-WRAP
          SIZE 20 BY 4
     crapldp.dslocali AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapldp.dsobserv AT ROW 1 COL 1 NO-LABEL
          VIEW-AS EDITOR NO-WORD-WRAP
          SIZE 20 BY 4
     crapldp.nmbailoc AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapldp.nmcidloc AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapldp.nmconloc AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapldp.nrceploc AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapldp.nrdddfax AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapldp.nrdddtel AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapldp.nrfaxsim AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapldp.nrtelefo AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapldp.qtmaxpes AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapldp.vldialoc AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
	 crapldp.dsrefloc AT ROW 1 COL 1 NO-LABEL
          VIEW-AS EDITOR NO-WORD-WRAP
          SIZE 20 BY 1
    ab_unmap.aux_origem AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
   ab_unmap.aux_cdcopope AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1 
   ab_unmap.aux_cdoperad AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1 
   ab_unmap.hdn_cdcooper AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1         
   ab_unmap.hdn_cdagenci AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1     
   ab_unmap.aux_dsdiaind AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
   ab_unmap.tel_dsdiaind AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1       
   ab_unmap.aux_nrceprua AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1  
   ab_unmap.aux_dsendtel AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1    
   ab_unmap.aux_nmbaitel AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1       
   ab_unmap.aux_nmcidtel AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1     
	 WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 57.2 BY 15.91.

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW w-html ASSIGN
         HEIGHT             = 15.91
         WIDTH              = 57.2.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB w-html 
/* *********************** Included-Libraries ************************* */

{src/web2/html-map.i}

/* _UIB-CODE-BLOCK-END */
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
PROCEDURE CriaListaPac:

    DEF VAR aux_dtanoage AS CHAR          NO-UNDO.

  RUN RodaJavaScript("var mpac=new Array();").
  
    /* busca a data da agenda atual */
    FIND LAST gnpapgd WHERE gnpapgd.idevento = INT(ab_unmap.aux_idevento) AND 
                            gnpapgd.cdcooper = INT(ab_unmap.aux_cdcooper) NO-LOCK NO-ERROR.
    
    IF   AVAILABLE gnpapgd   THEN
         aux_dtanoage = STRING(gnpapgd.dtanonov).
    ELSE
         aux_dtanoage = "0".
		 
    {includes/wpgd0099.i aux_dtanoage}

  RUN RodaJavaScript("mpac.push("  + vetorpac + ");"). 

END PROCEDURE.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaPacAssemb w-html 
PROCEDURE CriaListaPacAssemb :

  RUN RodaJavaScript("var mpac=new Array();"). 
  
    {includes/wpgd0097.i}
    
  RUN RodaJavaScript("mpac.push("  + vetorpac + ");").     

END PROCEDURE.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE carregaCEP w-html 
PROCEDURE carregaCEP:

  FOR FIRST crapdne FIELDS(dstiplog nmextlog nmrescid nmresbai) WHERE crapdne.nrceplog = DEC(ab_unmap.aux_nrceprua) NO-LOCK. END.

  IF AVAILABLE crapdne THEN
    DO:
      ASSIGN ab_unmap.aux_dsendtel = UPPER(crapdne.dstiplog + ": " + crapdne.nmextlog)
             ab_unmap.aux_nmbaitel = UPPER(crapdne.nmresbai)
             ab_unmap.aux_nmcidtel = UPPER(crapdne.nmrescid).
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
    ("aux_cdagenci":U,"ab_unmap.aux_cdagenci":U,ab_unmap.aux_cdagenci:HANDLE IN FRAME {&FRAME-NAME}).
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
    ("aux_lspermis":U,"ab_unmap.aux_lspermis":U,ab_unmap.aux_lspermis:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrdrowid":U,"ab_unmap.aux_nrdrowid":U,ab_unmap.aux_nrdrowid:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrseqdig":U,"ab_unmap.aux_nrseqdig":U,ab_unmap.aux_nrseqdig:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_stdopcao":U,"ab_unmap.aux_stdopcao":U,ab_unmap.aux_stdopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dsendloc":U,"crapldp.dsendloc":U,crapldp.dsendloc:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dsestloc":U,"crapldp.dsestloc":U,crapldp.dsestloc:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dslocali":U,"crapldp.dslocali":U,crapldp.dslocali:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dsobserv":U,"crapldp.dsobserv":U,crapldp.dsobserv:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nmbailoc":U,"crapldp.nmbailoc":U,crapldp.nmbailoc:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nmcidloc":U,"crapldp.nmcidloc":U,crapldp.nmcidloc:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nmconloc":U,"crapldp.nmconloc":U,crapldp.nmconloc:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nrceploc":U,"crapldp.nrceploc":U,crapldp.nrceploc:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nrdddfax":U,"crapldp.nrdddfax":U,crapldp.nrdddfax:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nrdddtel":U,"crapldp.nrdddtel":U,crapldp.nrdddtel:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nrfaxsim":U,"crapldp.nrfaxsim":U,crapldp.nrfaxsim:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nrtelefo":U,"crapldp.nrtelefo":U,crapldp.nrtelefo:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("qtmaxpes":U,"crapldp.qtmaxpes":U,crapldp.qtmaxpes:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("vldialoc":U,"crapldp.vldialoc":U,crapldp.vldialoc:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dsrefloc":U,"crapldp.dsrefloc":U,crapldp.dsrefloc:HANDLE IN FRAME {&FRAME-NAME}).
	RUN htmAssociate
    ("aux_origem":U,"ab_unmap.aux_origem":U,ab_unmap.aux_origem:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdcopope":U,"ab_unmap.aux_cdcopope":U,ab_unmap.aux_cdcopope:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdoperad":U,"ab_unmap.aux_cdoperad":U,ab_unmap.aux_cdoperad:HANDLE IN FRAME {&FRAME-NAME}).
   RUN htmAssociate
    ("hdn_cdagenci":U,"ab_unmap.hdn_cdagenci":U,ab_unmap.hdn_cdagenci:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("hdn_cdcooper":U,"ab_unmap.hdn_cdcooper":U,ab_unmap.hdn_cdcooper:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsdiaind":U,"ab_unmap.aux_dsdiaind":U,ab_unmap.aux_dsdiaind:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dsmotind":U,"crapldp.dsmotind":U,crapldp.dsmotind:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate                                       
    ("aux_idsonori":U,"ab_unmap.aux_idsonori":U,ab_unmap.aux_idsonori:HANDLE IN FRAME {&FRAME-NAME}).    
  RUN htmAssociate                                       
    ("aux_idprojet":U,"ab_unmap.aux_idprojet":U,ab_unmap.aux_idprojet:HANDLE IN FRAME {&FRAME-NAME}).    
  RUN htmAssociate                                       
    ("aux_idtelpro":U,"ab_unmap.aux_idtelpro":U,ab_unmap.aux_idtelpro:HANDLE IN FRAME {&FRAME-NAME}).    
  RUN htmAssociate                                       
    ("aux_idcadeir":U,"ab_unmap.aux_idcadeir":U,ab_unmap.aux_idcadeir:HANDLE IN FRAME {&FRAME-NAME}).    
  RUN htmAssociate                                       
    ("aux_idclimat":U,"ab_unmap.aux_idclimat":U,ab_unmap.aux_idclimat:HANDLE IN FRAME {&FRAME-NAME}).    
  RUN htmAssociate                                       
    ("aux_idacecad":U,"ab_unmap.aux_idacecad":U,ab_unmap.aux_idacecad:HANDLE IN FRAME {&FRAME-NAME}).    
  RUN htmAssociate                                       
    ("aux_idestaci":U,"ab_unmap.aux_idestaci":U,ab_unmap.aux_idestaci:HANDLE IN FRAME {&FRAME-NAME}).       
  RUN htmAssociate                                       
    ("aux_idloceva":U,"ab_unmap.aux_idloceva":U,ab_unmap.aux_idloceva:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("tel_dsdiaind":U,"ab_unmap.tel_dsdiaind":U,ab_unmap.tel_dsdiaind:HANDLE IN FRAME {&FRAME-NAME}).   
  RUN htmAssociate
    ("aux_nrceprua":U,"ab_unmap.aux_nrceprua":U,ab_unmap.aux_nrceprua:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsendtel":U,"ab_unmap.aux_dsendtel":U,ab_unmap.aux_dsendtel:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nmbaitel":U,"ab_unmap.aux_nmbaitel":U,ab_unmap.aux_nmbaitel:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nmcidtel":U,"ab_unmap.aux_nmcidtel":U,ab_unmap.aux_nmcidtel:HANDLE IN FRAME {&FRAME-NAME}).
END PROCEDURE.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-assign-record w-html 
PROCEDURE local-assign-record :
DEFINE INPUT PARAMETER opcao AS CHARACTER.

/* Instancia a BO para executar as procedures */
RUN dbo/b1wpgd0013.p PERSISTENT SET h-b1wpgd0013.

/* Se BO foi instanciada */
IF VALID-HANDLE(h-b1wpgd0013) THEN
   DO:
      DO WITH FRAME {&FRAME-NAME}:
          
          IF opcao = "inclusao" THEN
            DO: 
                CREATE cratldp.
                ASSIGN cratldp.cdagenci = INT(ab_unmap.aux_cdagenci)
                    cratldp.cdcooper = INT(ab_unmap.aux_cdcooper)
                    cratldp.dsendloc = INPUT crapldp.dsendloc
                    cratldp.dsestloc = INPUT crapldp.dsestloc
                    cratldp.dslocali  = INPUT crapldp.dslocali 
                    cratldp.dsobserv = INPUT crapldp.dsobserv
                    /*cratldp.idevento = INT(ab_unmap.aux_idevento)*/
                       cratldp.idevento = INT(ab_unmap.aux_idevento) /* IDEVENTO é sempre 1 para locais */
                    cratldp.nmbailoc = INPUT crapldp.nmbailoc
                    cratldp.nmcidloc = INPUT crapldp.nmcidloc
                    cratldp.nmconloc = INPUT crapldp.nmconloc
                    cratldp.nrceploc = INPUT crapldp.nrceploc
                    cratldp.nrdddfax = INPUT crapldp.nrdddfax
                    cratldp.nrdddtel = INPUT crapldp.nrdddtel
                    cratldp.nrfaxsim = INPUT crapldp.nrfaxsim
                    /*cratldp.nrseqdig = */
                    cratldp.nrtelefo = INPUT crapldp.nrtelefo
                    cratldp.qtmaxpes = INPUT crapldp.qtmaxpes
                    cratldp.vldialoc = INPUT crapldp.vldialoc
					cratldp.dsrefloc = INPUT crapldp.dsrefloc
                       cratldp.dsmotind = INPUT crapldp.dsmotind
                       cratldp.idsonori = INT(ab_unmap.aux_idsonori)
                       cratldp.idprojet = INT(ab_unmap.aux_idprojet)
                       cratldp.idtelpro = INT(ab_unmap.aux_idtelpro)
                       cratldp.idcadeir = INT(ab_unmap.aux_idcadeir)
                       cratldp.idclimat = INT(ab_unmap.aux_idclimat)
                       cratldp.idacecad = INT(ab_unmap.aux_idacecad)
                       cratldp.idestaci = INT(ab_unmap.aux_idestaci)
                       cratldp.idloceva = INT(ab_unmap.aux_idloceva)
                       cratldp.dsdiaind = ab_unmap.tel_dsdiaind.

                RUN inclui-registro IN h-b1wpgd0013(INPUT TABLE cratldp, OUTPUT msg-erro, OUTPUT ab_unmap.aux_nrdrowid).
            END.
         ELSE  /* alteracao */
            DO:
               
				/* cria a temp-table e joga o novo valor digitado para o campo */
                CREATE cratldp.
                BUFFER-COPY crapldp TO cratldp.

              ASSIGN cratldp.dsendloc = INPUT crapldp.dsendloc
                    cratldp.dsestloc = INPUT crapldp.dsestloc
                    cratldp.dslocali  = INPUT crapldp.dslocali 
                    cratldp.dsobserv = INPUT crapldp.dsobserv
                     cratldp.idevento = INT(ab_unmap.aux_idevento) /* IDEVENTO é sempre 1 para locais */
                    cratldp.nmbailoc = INPUT crapldp.nmbailoc
                    cratldp.nmcidloc = INPUT crapldp.nmcidloc
                    cratldp.nmconloc = INPUT crapldp.nmconloc
                    cratldp.nrceploc = INPUT crapldp.nrceploc
                    cratldp.nrdddfax = INPUT crapldp.nrdddfax
                    cratldp.nrdddtel = INPUT crapldp.nrdddtel
                    cratldp.nrfaxsim = INPUT crapldp.nrfaxsim
                    cratldp.nrtelefo = INPUT crapldp.nrtelefo
                    cratldp.qtmaxpes = INPUT crapldp.qtmaxpes
                    cratldp.vldialoc = INPUT crapldp.vldialoc
					cratldp.dsrefloc = INPUT crapldp.dsrefloc
                     cratldp.dsmotind = INPUT crapldp.dsmotind
                     cratldp.idsonori = INT(ab_unmap.aux_idsonori)
                     cratldp.idprojet = INT(ab_unmap.aux_idprojet)
                     cratldp.idtelpro = INT(ab_unmap.aux_idtelpro)
                     cratldp.idcadeir = INT(ab_unmap.aux_idcadeir)
                     cratldp.idclimat = INT(ab_unmap.aux_idclimat)
                     cratldp.idacecad = INT(ab_unmap.aux_idacecad)
                     cratldp.idestaci = INT(ab_unmap.aux_idestaci)
										 cratldp.idloceva = INT(ab_unmap.aux_idloceva)
                     cratldp.dsdiaind = ab_unmap.tel_dsdiaind.
                 
                RUN altera-registro IN h-b1wpgd0013(INPUT TABLE cratldp, OUTPUT msg-erro).
            END.    
      END. /* DO WITH FRAME {&FRAME-NAME} */
   
      /* "mata" a instância da BO */
      DELETE PROCEDURE h-b1wpgd0013 NO-ERROR.
   
   END. /* IF VALID-HANDLE(h-b1wpgd0013) */
      
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-delete-record w-html 
PROCEDURE local-delete-record :
/* Instancia a BO para executar as procedures */
RUN dbo/b1wpgd0013.p PERSISTENT SET h-b1wpgd0013.
 
/* Se BO foi instanciada */
IF VALID-HANDLE(h-b1wpgd0013) THEN
   DO:
      CREATE cratldp.
      BUFFER-COPY crapldp TO cratldp.
          
      RUN exclui-registro IN h-b1wpgd0013(INPUT TABLE cratldp, OUTPUT msg-erro).

      /* "mata" a instância da BO */
      DELETE PROCEDURE h-b1wpgd0013 NO-ERROR.
   END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-display-fields w-html 
PROCEDURE local-display-fields:

IF AVAIL crapldp THEN
DO:
      ASSIGN ab_unmap.aux_cdcooper:SCREEN-VALUE IN FRAME {&FRAME-NAME} = string(crapldp.cdcooper).
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE outputHeader w-html 
PROCEDURE outputHeader:
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
-------------------------------------------------------------------------------*/

v-identificacao = get-cookie("cookie-usuario-em-uso").

/* Usado FOR EACH para poder utilizar o CONTAINS e WORD-INDEX, alterado para MATCHES */
FOR EACH gnapses WHERE gnapses.idsessao MATCHES "*" + v-identificacao + "*" NO-LOCK:
    LEAVE.
END.
  
ASSIGN opcao                 = GET-FIELD("aux_cddopcao")
       FlagPermissoes        = GET-VALUE("aux_lspermis")
       msg-erro-aux          = 0
       ab_unmap.aux_idevento = "1" /*get-value("aux_idevento") SEMPRE VALOR 1 */
       ab_unmap.aux_dsendurl = AppURL                        
       ab_unmap.aux_lspermis = FlagPermissoes                
       ab_unmap.aux_nrdrowid = GET-VALUE("aux_nrdrowid")         
       ab_unmap.aux_stdopcao = GET-VALUE("aux_stdopcao")
       ab_unmap.aux_cdcooper = GET-VALUE("aux_cdcooper")
       
       ab_unmap.hdn_cdcooper = GET-VALUE("hdn_cdcooper")
       ab_unmap.hdn_cdagenci = GET-VALUE("hdn_cdagenci")
       
       ab_unmap.aux_origem   = GET-VALUE("aux_origem")
       ab_unmap.aux_cdcopope = GET-VALUE("aux_cdcopope")
       ab_unmap.aux_cdoperad = GET-VALUE("aux_cdoperad")
       ab_unmap.aux_idloceva = GET-VALUE("aux_idloceva")
       ab_unmap.aux_idsonori = GET-VALUE("aux_idsonori")
       ab_unmap.aux_idprojet = GET-VALUE("aux_idprojet")
       ab_unmap.aux_idtelpro = GET-VALUE("aux_idtelpro")
       ab_unmap.aux_idcadeir = GET-VALUE("aux_idcadeir")
       ab_unmap.aux_idclimat = GET-VALUE("aux_idclimat")
       ab_unmap.aux_idacecad = GET-VALUE("aux_idacecad")
       ab_unmap.aux_idestaci = GET-VALUE("aux_idestaci")
       ab_unmap.tel_dsdiaind = GET-VALUE("tel_dsdiaind")
       ab_unmap.aux_cdagenci = GET-VALUE("aux_cdagenci")
       ab_unmap.aux_nrceprua = REPLACE(REPLACE(STRING(GET-VALUE("aux_nrceprua")),".",""),"-","").

RUN outputHeader.

{includes/wpgd0098.i}

ASSIGN ab_unmap.aux_idsonori:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = "NÃO,0,SIM,1"
       ab_unmap.aux_idprojet:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = "NÃO,0,SIM,1"
       ab_unmap.aux_idtelpro:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = "NÃO,0,SIM,1"
       ab_unmap.aux_idcadeir:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = "NÃO,0,SIM,1"
       ab_unmap.aux_idclimat:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = "NÃO,0,SIM,1"
       ab_unmap.aux_idacecad:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = "NÃO,0,SIM,1"
       ab_unmap.aux_idestaci:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = "NÃO,0,SIM,1"
       ab_unmap.aux_idloceva:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = "NÃO,0,SIM,1"
ab_unmap.aux_cdcooper:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = aux_crapcop.

/* Se a cooperativa ainda não foi escolhida, pega a da sessão do usuário */
IF INT(ab_unmap.hdn_cdcooper) = 0 THEN
     ab_unmap.aux_cdcooper = STRING(gnapses.cdcooper).
ELSE IF INT(ab_unmap.aux_cdcooper) = 0 THEN
  ab_unmap.aux_cdcooper = ab_unmap.hdn_cdcooper.

   RUN CriaListaPac.

RUN insere_log_progrid("WPGD0013.w",STRING(opcao) + "|" + STRING(ab_unmap.aux_idevento) + "|" +
					  STRING(ab_unmap.aux_cdcooper) + "|" + STRING(ab_unmap.aux_cdcopope) + "|" +
					  STRING(ab_unmap.aux_cdoperad)).

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
                    FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.

                    /* busca o próximo registro para fazer o reposicionamento */
                    FIND NEXT {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.

                    IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                       ASSIGN aux_nrdrowid-auxiliar = STRING(ROWID({&SECOND-ENABLED-TABLE})).
                    ELSE
                       DO:
                           /* nao encontrou próximo registro então procura pelo registro anterior para o reposicionamento */
                           FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                           
                           FIND PREV {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = int(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.

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
           WHEN "cep" THEN 
            RUN carregaCEP.
    
      END CASE.

      IF msg-erro-aux = 10 OR (opcao <> "sa" AND opcao <> "ex" AND opcao <> "in") THEN
         DO:
            RUN local-display-fields.
         END.
      
         RUN displayFields.
      RUN enableFields.
 
      RUN outputFields.

      RUN RodaJavaScript('PosicionaPAC();').

      CASE msg-erro-aux:
           WHEN 1 THEN
                DO:
                    ASSIGN v-qtdeerro      = 1
                           v-descricaoerro = 'Registro esta em uso por outro usuário. Solicitação não pode ser executada. Espere alguns instantes e tente novamente.'.

                     RUN RodaJavaScript('alert("'+ v-descricaoerro + '"); ').
                END.

           WHEN 2 THEN
            RUN RodaJavaScript('alert("Registro foi excluído. Solicitação não pode ser executada"); ').
      
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
              RUN RodaJavaScript('alert("Atualização executada com sucesso.")').
               IF aux_origem = "agenda" THEN
               DO:
                  RUN RodaJavaScript('window.opener.history.go();').
                  RUN RodaJavaScript('self.close();'). 
               END. 
               
               IF opcao = "ex" THEN
               DO:
                  RUN RodaJavaScript('LimparCampos();').
               END.
           END.
      END CASE.     

      /*RUN RodaJavaScript('top.frames[0].ZeraOp()').   */

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

                                  /* Recarrega a cooperativa de acordo com o registro selecionado */
                                  SET-USER-FIELD("aux_idevento",STRING(ab_unmap.aux_idevento)).
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
                                  
                                  IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                                    DO:
                                      ASSIGN ab_unmap.aux_idsonori = STRING({&SECOND-ENABLED-TABLE}.idsonori)
                                             ab_unmap.aux_idprojet = STRING({&SECOND-ENABLED-TABLE}.idprojet)
                                             ab_unmap.aux_idtelpro = STRING({&SECOND-ENABLED-TABLE}.idtelpro)
                                             ab_unmap.aux_idcadeir = STRING({&SECOND-ENABLED-TABLE}.idcadeir)
                                             ab_unmap.aux_idclimat = STRING({&SECOND-ENABLED-TABLE}.idclimat)
                                             ab_unmap.aux_idacecad = STRING({&SECOND-ENABLED-TABLE}.idacecad)
                                             ab_unmap.aux_idestaci = STRING({&SECOND-ENABLED-TABLE}.idestaci)
                                             ab_unmap.aux_idloceva = STRING({&SECOND-ENABLED-TABLE}.idloceva)
                                             ab_unmap.hdn_cdcooper = STRING({&SECOND-ENABLED-TABLE}.cdcooper)
                                             ab_unmap.hdn_cdagenci = STRING({&SECOND-ENABLED-TABLE}.cdagenci)
                                             ab_unmap.tel_dsdiaind = STRING({&SECOND-ENABLED-TABLE}.dsdiaind).  
                                    END.
                              END.  
                           ELSE
                              ASSIGN ab_unmap.aux_nrdrowid = "?"
                                     ab_unmap.aux_stdopcao = "?".
                       END.  
                    ELSE                    
                       RUN PosicionaNoPrimeiro.

                    RUN local-display-fields.
                    RUN displayFields.
                    RUN enableFields.
                    RUN outputFields.
                    IF aux_origem <> "agenda" THEN
                    RUN RodaJavaScript('top.frcod.FechaZoom()').
                    
                    RUN RodaJavaScript('CarregaPrincipal()').
                    
                    IF GET-VALUE("LinkRowid") = "" THEN
                    DO:
                        RUN RodaJavaScript('LimparCampos();').
                    END.

                    RUN RodaJavaScript('PosicionaPAC();').
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
