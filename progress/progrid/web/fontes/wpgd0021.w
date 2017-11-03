/* ..................................................................................

Alterações:  26/02/2007 - Incluída Aba de "Fechamento" (Diego).
           
             02/05/2008 - Somente criticar a data da agenda caso nao esteja iniciando
                          uma nova agenda (Evandro).

             10/12/2008 - Melhoria de performance para a tabela gnapses (Evandro).
			 
			       05/06/2012 - Adaptação dos fontes para projeto Oracle. Alterado
						              busca na gnapses de CONTAINS para MATCHES (Guilherme Maba).

             08/08/2016 - Alterações para Aba de "Fechamento", Prj. 229, alterações
                          dos registro com situação do evento(1 – Agendado,3 – Transferido,
                          5 – Realizado, 6 - Acrescido) para 4 – Encerrado(Jean Michel).

             02/08/2016 - Inclusao insitage 3-Temporariamente Indisponivel.
                          (Jaison/Anderson)

						 16/03/2017 - Mostrar div de Manutencao para Assembléias, Prj. 322 (Jean Michel)								
						 
.................................................................................. */

&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
/* Connected Databases 
          gener            PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD aux_carpacs AS LOGICAL 
       FIELD aux_cdfreint AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_idexclui AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_mes01eve AS LOGICAL 
	   FIELD aux_mes01int AS LOGICAL 
       FIELD aux_mes01fec AS LOGICAL
	   FIELD aux_mes02eve AS LOGICAL 
       FIELD aux_mes02int AS LOGICAL
	   FIELD aux_mes02fec AS LOGICAL 
       FIELD aux_mes03eve AS LOGICAL 
       FIELD aux_mes03int AS LOGICAL
	   FIELD aux_mes03fec AS LOGICAL 
       FIELD aux_mes04eve AS LOGICAL 
       FIELD aux_mes04int AS LOGICAL
	   FIELD aux_mes04fec AS LOGICAL 
       FIELD aux_mes05eve AS LOGICAL 
       FIELD aux_mes05int AS LOGICAL
	   FIELD aux_mes05fec AS LOGICAL 
       FIELD aux_mes06eve AS LOGICAL 
       FIELD aux_mes06int AS LOGICAL
	   FIELD aux_mes06fec AS LOGICAL 
       FIELD aux_mes07eve AS LOGICAL 
       FIELD aux_mes07int AS LOGICAL
	   FIELD aux_mes07fec AS LOGICAL 
       FIELD aux_mes08eve AS LOGICAL 
       FIELD aux_mes08int AS LOGICAL
	   FIELD aux_mes08fec AS LOGICAL 
       FIELD aux_mes09eve AS LOGICAL 
       FIELD aux_mes09int AS LOGICAL
	   FIELD aux_mes09fec AS LOGICAL 
       FIELD aux_mes10eve AS LOGICAL 
       FIELD aux_mes10int AS LOGICAL
	   FIELD aux_mes10fec AS LOGICAL 
       FIELD aux_mes11eve AS LOGICAL 
       FIELD aux_mes11int AS LOGICAL 
	   FIELD aux_mes11fec AS LOGICAL
       FIELD aux_mes12eve AS LOGICAL 
       FIELD aux_mes12int AS LOGICAL
	   FIELD aux_mes12fec AS LOGICAL 
       FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
       FIELD pagina AS CHARACTER FORMAT "X(256)":U
       FIELD aux_cdcooper AS CHARACTER
       FIELD aux_idevento AS CHARACTER
       FIELD aux_dtanoage_eve AS CHARACTER FORMAT "X(256)":U
       FIELD aux_dtanoage_int AS CHARACTER FORMAT "X(256)":U
       FIELD aux_dtanoage_que AS CHARACTER FORMAT "X(256)":U
       FIELD aux_dtanoage_fec AS CHARACTER FORMAT "X(256)":U
       FIELD cdfreint     AS CHARACTER
       FIELD aux_mesatual AS CHARACTER
	   FIELD aux_fechamen AS CHARACTER
	   FIELD aux_dtanonov AS CHARACTER
		 FIELD aux_cdcopope AS CHARACTER
		 FIELD aux_dsaltfec AS CHARACTER
	   FIELD aux_cdoperad AS CHARACTER.

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
DEFINE VARIABLE ProgramaEmUso         AS CHARACTER INITIAL ["wpgd0021"].
DEFINE VARIABLE NmeDoPrograma         AS CHARACTER INITIAL ["wpgd0021.w"].

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
DEFINE VARIABLE aux_meses             AS CHARACTER  EXTENT 12 INITIAL ["1","2","3","4","5","6","7","8","9","10","11","12"] NO-UNDO.
DEFINE VARIABLE aux_crapcop           AS CHARACTER                      NO-UNDO.
DEFINE VARIABLE aux_mesfech           AS CHARACTER  										NO-UNDO.

/*** Declarao de BOs ***/
DEFINE VARIABLE h-b1wpgd0021          AS HANDLE                         NO-UNDO.
DEFINE VARIABLE h-b1wpgd0021a         AS HANDLE                         NO-UNDO.

/*** Temp Tables ***/
DEFINE TEMP-TABLE gtpapgd             LIKE gnpapgd.
DEFINE TEMP-TABLE cratagp NO-UNDO     LIKE crapagp.

DEFINE BUFFER b-gnpapgd FOR gnpapgd.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE fontes/wpgd0021.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS gnpapgd.cdcooper gnpapgd.dtanoage ~
gnpapgd.idevento gnpapgd.qtmpreve gnpapgd.qtpreeve gnpapgd.qtpreint ~
gnpapgd.dtanonov gnpapgd.qtretque
&Scoped-define ENABLED-TABLES ab_unmap gnpapgd
&Scoped-define FIRST-ENABLED-TABLE ab_unmap
&Scoped-define SECOND-ENABLED-TABLE gnpapgd
&Scoped-Define ENABLED-OBJECTS ab_unmap.aux_carpacs ab_unmap.aux_cddopcao ~
ab_unmap.aux_cdfreint ab_unmap.aux_dsendurl ab_unmap.aux_dsretorn ~
ab_unmap.aux_idexclui ab_unmap.aux_lspermis ab_unmap.aux_mes01eve ~
ab_unmap.aux_mes01int ab_unmap.aux_mes02eve ab_unmap.aux_mes02int ~
ab_unmap.aux_mes03eve ab_unmap.aux_mes03int ab_unmap.aux_mes04eve ~
ab_unmap.aux_mes04int ab_unmap.aux_mes05eve ab_unmap.aux_mes05int ~
ab_unmap.aux_mes06eve ab_unmap.aux_mes06int ab_unmap.aux_mes07eve ~
ab_unmap.aux_mes07int ab_unmap.aux_mes08eve ab_unmap.aux_mes08int ~
ab_unmap.aux_mes09eve ab_unmap.aux_mes09int ab_unmap.aux_mes10eve ~
ab_unmap.aux_mes10int ab_unmap.aux_mes11eve ab_unmap.aux_mes11int ~
ab_unmap.aux_mes12eve ab_unmap.aux_mes12int ab_unmap.aux_mes01fec ~
ab_unmap.aux_mes02fec ab_unmap.aux_mes03fec ab_unmap.aux_mes04fec ~
ab_unmap.aux_mes05fec ab_unmap.aux_mes06fec ab_unmap.aux_mes07fec ~
ab_unmap.aux_mes08fec ab_unmap.aux_mes09fec ab_unmap.aux_mes10fec ~
ab_unmap.aux_mes11fec ab_unmap.aux_mes12fec ab_unmap.aux_nrdrowid ~
ab_unmap.aux_stdopcao ab_unmap.pagina ab_unmap.aux_cdcooper ~
ab_unmap.aux_idevento ab_unmap.aux_dtanoage_eve ab_unmap.aux_dtanoage_int ~
ab_unmap.cdfreint     ab_unmap.aux_dtanoage_que ab_unmap.aux_dtanoage_fec ~
ab_unmap.aux_mesatual ab_unmap.aux_fechamen ab_unmap.aux_dtanonov ~
ab_unmap.aux_cdcopope ab_unmap.aux_cdoperad ab_unmap.aux_dsaltfec
&Scoped-Define DISPLAYED-FIELDS gnpapgd.cdcooper gnpapgd.dtanoage ~
gnpapgd.idevento gnpapgd.qtmpreve gnpapgd.qtpreeve gnpapgd.qtpreint ~
gnpapgd.dtanonov gnpapgd.dtiniage gnpapgd.dtmvtolt gnpapgd.qtretque
&Scoped-define DISPLAYED-TABLES ab_unmap gnpapgd
&Scoped-define FIRST-DISPLAYED-TABLE ab_unmap
&Scoped-define SECOND-DISPLAYED-TABLE gnpapgd
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.aux_carpacs ab_unmap.aux_cddopcao ~
ab_unmap.aux_cdfreint ab_unmap.aux_dsendurl ab_unmap.aux_dsretorn ~
ab_unmap.aux_idexclui ab_unmap.aux_lspermis ab_unmap.aux_mes01eve ~
ab_unmap.aux_mes01int ab_unmap.aux_mes02eve ab_unmap.aux_mes02int ~
ab_unmap.aux_mes03eve ab_unmap.aux_mes03int ab_unmap.aux_mes04eve ~
ab_unmap.aux_mes04int ab_unmap.aux_mes05eve ab_unmap.aux_mes05int ~
ab_unmap.aux_mes06eve ab_unmap.aux_mes06int ab_unmap.aux_mes07eve ~
ab_unmap.aux_mes07int ab_unmap.aux_mes08eve ab_unmap.aux_mes08int ~
ab_unmap.aux_mes09eve ab_unmap.aux_mes09int ab_unmap.aux_mes10eve ~
ab_unmap.aux_mes10int ab_unmap.aux_mes11eve ab_unmap.aux_mes11int ~
ab_unmap.aux_mes12eve ab_unmap.aux_mes12int ab_unmap.aux_mes01fec ~
ab_unmap.aux_mes02fec ab_unmap.aux_mes03fec ab_unmap.aux_mes04fec ~
ab_unmap.aux_mes05fec ab_unmap.aux_mes06fec ab_unmap.aux_mes07fec ~
ab_unmap.aux_mes08fec ab_unmap.aux_mes09fec ab_unmap.aux_mes10fec ~
ab_unmap.aux_mes11fec ab_unmap.aux_mes12fec ab_unmap.aux_nrdrowid ~
ab_unmap.aux_stdopcao ab_unmap.pagina ab_unmap.aux_cdcooper ~
ab_unmap.aux_idevento ab_unmap.aux_dtanoage_eve ab_unmap.aux_dtanoage_int ~
ab_unmap.cdfreint     ab_unmap.aux_dtanoage_que ab_unmap.aux_dtanoage_fec ~
ab_unmap.aux_mesatual ab_unmap.aux_fechamen ab_unmap.aux_dtanonov ~
ab_unmap.aux_cdcopope ab_unmap.aux_cdoperad abunmap.aux_dsaltfec


/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     ab_unmap.aux_carpacs AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
     ab_unmap.aux_cddopcao AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cdfreint AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.cdfreint AT ROW 1 COL 1 HELP
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
     ab_unmap.aux_idexclui AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_lspermis AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_mes01eve AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
     ab_unmap.aux_mes01int AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
     ab_unmap.aux_mes02eve AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
     ab_unmap.aux_mes02int AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
     ab_unmap.aux_mes03eve AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
     ab_unmap.aux_mes03int AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
     ab_unmap.aux_mes04eve AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
     ab_unmap.aux_mes04int AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
     ab_unmap.aux_mes05eve AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
     ab_unmap.aux_mes05int AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
     ab_unmap.aux_mes06eve AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
     ab_unmap.aux_mes06int AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
     ab_unmap.aux_mes07eve AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
     ab_unmap.aux_mes07int AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
     ab_unmap.aux_mes08eve AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
     ab_unmap.aux_mes08int AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
     ab_unmap.aux_mes09eve AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
     ab_unmap.aux_mes09int AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
     ab_unmap.aux_mes10eve AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
     ab_unmap.aux_cdcooper AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.aux_idevento AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.aux_dtanoage_eve AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.aux_dtanoage_int AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 80 BY 20.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Web-Frame
     ab_unmap.aux_mes10int AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
     ab_unmap.aux_mes11eve AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
     ab_unmap.aux_mes11int AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
     ab_unmap.aux_mes12eve AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
     ab_unmap.aux_mes12int AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
	      ab_unmap.aux_mes01fec AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
     ab_unmap.aux_mes02fec AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
     ab_unmap.aux_mes03fec AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
     ab_unmap.aux_mes04fec AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
     ab_unmap.aux_mes05fec AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
     ab_unmap.aux_mes06fec AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
     ab_unmap.aux_mes07fec AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
     ab_unmap.aux_mes08fec AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
     ab_unmap.aux_mes09fec AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
     ab_unmap.aux_mes10fec AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
     ab_unmap.aux_mes11fec AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
     ab_unmap.aux_mes12fec AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
     ab_unmap.aux_nrdrowid AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_stdopcao AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_dtanoage_que AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
	 ab_unmap.aux_dtanoage_fec AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     gnpapgd.cdcooper AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     gnpapgd.dtanoage AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     gnpapgd.dtiniage AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     gnpapgd.dtmvtolt AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     gnpapgd.dtanonov AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     gnpapgd.idevento AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.pagina AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
	 ab_unmap.aux_mesatual AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
	 ab_unmap.aux_dtanonov AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
	 ab_unmap.aux_fechamen AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1 
		ab_unmap.aux_cdoperad AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1 
     ab_unmap.aux_cdcopope AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1 					
		ab_unmap.aux_dsaltfec AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1 					
     gnpapgd.qtmpreve AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     gnpapgd.qtpreeve AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     gnpapgd.qtpreint AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     gnpapgd.qtretque AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 80 BY 20.


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
          FIELD aux_carpacs AS LOGICAL 
          FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_cdfreint AS CHARACTER 
          FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_idexclui AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_mes01eve AS LOGICAL 
          FIELD aux_mes01int AS LOGICAL 
          FIELD aux_mes02eve AS LOGICAL 
          FIELD aux_mes02int AS LOGICAL 
          FIELD aux_mes03eve AS LOGICAL 
          FIELD aux_mes03int AS LOGICAL 
          FIELD aux_mes04eve AS LOGICAL 
          FIELD aux_mes04int AS LOGICAL 
          FIELD aux_mes05eve AS LOGICAL 
          FIELD aux_mes05int AS LOGICAL 
          FIELD aux_mes06eve AS LOGICAL 
          FIELD aux_mes06int AS LOGICAL 
          FIELD aux_mes07eve AS LOGICAL 
          FIELD aux_mes07int AS LOGICAL 
          FIELD aux_mes08eve AS LOGICAL 
          FIELD aux_mes08int AS LOGICAL 
          FIELD aux_mes09eve AS LOGICAL 
          FIELD aux_mes09int AS LOGICAL 
          FIELD aux_mes10eve AS LOGICAL 
          FIELD aux_mes10int AS LOGICAL 
          FIELD aux_mes11eve AS LOGICAL 
          FIELD aux_mes11int AS LOGICAL 
          FIELD aux_mes12eve AS LOGICAL 
          FIELD aux_mes12int AS LOGICAL 
		  FIELD aux_mes01fec AS LOGICAL 
          FIELD aux_mes02fec AS LOGICAL 
          FIELD aux_mes03fec AS LOGICAL 
          FIELD aux_mes04fec AS LOGICAL 
          FIELD aux_mes05fec AS LOGICAL 
          FIELD aux_mes06fec AS LOGICAL 
          FIELD aux_mes07fec AS LOGICAL 
          FIELD aux_mes08fec AS LOGICAL 
          FIELD aux_mes09fec AS LOGICAL 
          FIELD aux_mes10fec AS LOGICAL 
          FIELD aux_mes11fec AS LOGICAL 
          FIELD aux_mes12fec AS LOGICAL 
          FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
          FIELD pagina AS CHARACTER FORMAT "X(256)":U
		  FIELD aux_mesatual AS CHARACTER 
		  FIELD aux_dtanonov AS CHARACTER
		  FIELD aux_fechamen AS CHARACTER
			FIELD aux_cdcopope AS CHARACTER
			FIELD aux_dsfecalt AS CHARACTER
		  FIELD aux_cdoperad AS CHARACTER
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW w-html ASSIGN
         HEIGHT             = 24.71
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
/* SETTINGS FOR toggle-box ab_unmap.aux_carpacs IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR fill-in ab_unmap.aux_cddopcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR selection-list ab_unmap.aux_cdfreint IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR fill-in ab_unmap.aux_dsendurl IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.aux_dsretorn IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.aux_idexclui IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.aux_lspermis IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR toggle-box ab_unmap.aux_mes01eve IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR toggle-box ab_unmap.aux_mes01int IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR toggle-box ab_unmap.aux_mes02eve IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR toggle-box ab_unmap.aux_mes02int IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR toggle-box ab_unmap.aux_mes03eve IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR toggle-box ab_unmap.aux_mes03int IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR toggle-box ab_unmap.aux_mes04eve IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR toggle-box ab_unmap.aux_mes04int IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR toggle-box ab_unmap.aux_mes05eve IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR toggle-box ab_unmap.aux_mes05int IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR toggle-box ab_unmap.aux_mes06eve IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR toggle-box ab_unmap.aux_mes06int IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR toggle-box ab_unmap.aux_mes07eve IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR toggle-box ab_unmap.aux_mes07int IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR toggle-box ab_unmap.aux_mes08eve IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR toggle-box ab_unmap.aux_mes08int IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR toggle-box ab_unmap.aux_mes09eve IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR toggle-box ab_unmap.aux_mes09int IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR toggle-box ab_unmap.aux_mes10eve IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR toggle-box ab_unmap.aux_mes10int IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR toggle-box ab_unmap.aux_mes11eve IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR toggle-box ab_unmap.aux_mes11int IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR toggle-box ab_unmap.aux_mes12eve IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR toggle-box ab_unmap.aux_mes12int IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR toggle-box ab_unmap.aux_mes01fec IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR toggle-box ab_unmap.aux_mes02fec IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR toggle-box ab_unmap.aux_mes03fec IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR toggle-box ab_unmap.aux_mes04fec IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR toggle-box ab_unmap.aux_mes05fec IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR toggle-box ab_unmap.aux_mes06fec IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR toggle-box ab_unmap.aux_mes07fec IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR toggle-box ab_unmap.aux_mes08fec IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR toggle-box ab_unmap.aux_mes09fec IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR toggle-box ab_unmap.aux_mes10fec IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR toggle-box ab_unmap.aux_mes11fec IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR toggle-box ab_unmap.aux_mes12fec IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */   
/* SETTINGS FOR fill-in ab_unmap.aux_nrdrowid IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.aux_stdopcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in gnpapgd.cdcooper IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR fill-in gnpapgd.dtanoage IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR fill-in gnpapgd.idevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR fill-in ab_unmap.pagina IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in gnpapgd.qtmpreve IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR fill-in ab_unmap.aux_mesatual IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.aux_dtanonov IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.aux_fechamen IN FRAME Web-Frame
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
    ("aux_carpacs":U,"ab_unmap.aux_carpacs":U,ab_unmap.aux_carpacs:HANDLE IN FRAME {&FRAME-NAME}).
  
  RUN htmAssociate
    ("aux_cddopcao":U,"ab_unmap.aux_cddopcao":U,ab_unmap.aux_cddopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdfreint":U,"ab_unmap.aux_cdfreint":U,ab_unmap.aux_cdfreint:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("cdfreint":U,"ab_unmap.cdfreint":U,ab_unmap.cdfreint:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsendurl":U,"ab_unmap.aux_dsendurl":U,ab_unmap.aux_dsendurl:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsretorn":U,"ab_unmap.aux_dsretorn":U,ab_unmap.aux_dsretorn:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idexclui":U,"ab_unmap.aux_idexclui":U,ab_unmap.aux_idexclui:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lspermis":U,"ab_unmap.aux_lspermis":U,ab_unmap.aux_lspermis:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_mes01eve":U,"ab_unmap.aux_mes01eve":U,ab_unmap.aux_mes01eve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_mes01int":U,"ab_unmap.aux_mes01int":U,ab_unmap.aux_mes01int:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_mes02eve":U,"ab_unmap.aux_mes02eve":U,ab_unmap.aux_mes02eve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_mes02int":U,"ab_unmap.aux_mes02int":U,ab_unmap.aux_mes02int:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_mes03eve":U,"ab_unmap.aux_mes03eve":U,ab_unmap.aux_mes03eve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_mes03int":U,"ab_unmap.aux_mes03int":U,ab_unmap.aux_mes03int:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_mes04eve":U,"ab_unmap.aux_mes04eve":U,ab_unmap.aux_mes04eve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_mes04int":U,"ab_unmap.aux_mes04int":U,ab_unmap.aux_mes04int:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_mes05eve":U,"ab_unmap.aux_mes05eve":U,ab_unmap.aux_mes05eve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_mes05int":U,"ab_unmap.aux_mes05int":U,ab_unmap.aux_mes05int:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_mes06eve":U,"ab_unmap.aux_mes06eve":U,ab_unmap.aux_mes06eve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_mes06int":U,"ab_unmap.aux_mes06int":U,ab_unmap.aux_mes06int:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_mes07eve":U,"ab_unmap.aux_mes07eve":U,ab_unmap.aux_mes07eve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_mes07int":U,"ab_unmap.aux_mes07int":U,ab_unmap.aux_mes07int:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_mes08eve":U,"ab_unmap.aux_mes08eve":U,ab_unmap.aux_mes08eve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_mes08int":U,"ab_unmap.aux_mes08int":U,ab_unmap.aux_mes08int:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_mes09eve":U,"ab_unmap.aux_mes09eve":U,ab_unmap.aux_mes09eve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_mes09int":U,"ab_unmap.aux_mes09int":U,ab_unmap.aux_mes09int:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_mes10eve":U,"ab_unmap.aux_mes10eve":U,ab_unmap.aux_mes10eve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_mes10int":U,"ab_unmap.aux_mes10int":U,ab_unmap.aux_mes10int:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_mes11eve":U,"ab_unmap.aux_mes11eve":U,ab_unmap.aux_mes11eve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_mes11int":U,"ab_unmap.aux_mes11int":U,ab_unmap.aux_mes11int:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_mes12eve":U,"ab_unmap.aux_mes12eve":U,ab_unmap.aux_mes12eve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_mes12int":U,"ab_unmap.aux_mes12int":U,ab_unmap.aux_mes12int:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_mes01fec":U,"ab_unmap.aux_mes01fec":U,ab_unmap.aux_mes01fec:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_mes02fec":U,"ab_unmap.aux_mes02fec":U,ab_unmap.aux_mes02fec:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_mes03fec":U,"ab_unmap.aux_mes03fec":U,ab_unmap.aux_mes03fec:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_mes04fec":U,"ab_unmap.aux_mes04fec":U,ab_unmap.aux_mes04fec:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_mes05fec":U,"ab_unmap.aux_mes05fec":U,ab_unmap.aux_mes05fec:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_mes06fec":U,"ab_unmap.aux_mes06fec":U,ab_unmap.aux_mes06fec:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_mes07fec":U,"ab_unmap.aux_mes07fec":U,ab_unmap.aux_mes07fec:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_mes08fec":U,"ab_unmap.aux_mes08fec":U,ab_unmap.aux_mes08fec:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_mes09fec":U,"ab_unmap.aux_mes09fec":U,ab_unmap.aux_mes09fec:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_mes10fec":U,"ab_unmap.aux_mes10fec":U,ab_unmap.aux_mes10fec:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_mes11fec":U,"ab_unmap.aux_mes11fec":U,ab_unmap.aux_mes11fec:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_mes12fec":U,"ab_unmap.aux_mes12fec":U,ab_unmap.aux_mes12fec:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrdrowid":U,"ab_unmap.aux_nrdrowid":U,ab_unmap.aux_nrdrowid:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_stdopcao":U,"ab_unmap.aux_stdopcao":U,ab_unmap.aux_stdopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dtanoage_eve":U,"ab_unmap.aux_dtanoage_eve":U,ab_unmap.aux_dtanoage_eve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dtanoage_int":U,"ab_unmap.aux_dtanoage_int":U,ab_unmap.aux_dtanoage_int:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dtanoage_que":U,"ab_unmap.aux_dtanoage_que":U,ab_unmap.aux_dtanoage_que:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dtanoage_fec":U,"ab_unmap.aux_dtanoage_fec":U,ab_unmap.aux_dtanoage_fec:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("cdcooper":U,"gnpapgd.cdcooper":U,gnpapgd.cdcooper:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dtanoage":U,"gnpapgd.dtanoage":U,gnpapgd.dtanoage:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dtanonov":U,"gnpapgd.dtanonov":U,gnpapgd.dtanonov:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dtiniage":U,"gnpapgd.dtiniage":U,gnpapgd.dtiniage:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dtmvtolt":U,"gnpapgd.dtmvtolt":U,gnpapgd.dtmvtolt:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("idevento":U,"gnpapgd.idevento":U,gnpapgd.idevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("pagina":U,"ab_unmap.pagina":U,ab_unmap.pagina:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("qtmpreve":U,"gnpapgd.qtmpreve":U,gnpapgd.qtmpreve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("qtpreeve":U,"gnpapgd.qtpreeve":U,gnpapgd.qtpreeve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("qtpreint":U,"gnpapgd.qtpreint":U,gnpapgd.qtpreint:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdcooper":U,"ab_unmap.aux_cdcooper":U,ab_unmap.aux_cdcooper:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idevento":U,"ab_unmap.aux_idevento":U,ab_unmap.aux_idevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("qtretque":U,"gnpapgd.qtretque":U,gnpapgd.qtretque:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_mesatual":U,"ab_unmap.aux_mesatual":U,ab_unmap.aux_mesatual:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dtanonov":U,"ab_unmap.aux_dtanonov":U,ab_unmap.aux_dtanonov:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_fechamen":U,"ab_unmap.aux_fechamen":U,ab_unmap.aux_fechamen:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdoperad":U,"ab_unmap.aux_cdoperad":U,ab_unmap.aux_cdoperad:HANDLE IN FRAME {&FRAME-NAME}).
	RUN htmAssociate
    ("aux_cdcopope":U,"ab_unmap.aux_cdcopope":U,ab_unmap.aux_cdcopope:HANDLE IN FRAME {&FRAME-NAME}).
	RUN htmAssociate
    ("aux_dsaltfec":U,"ab_unmap.aux_dsaltfec":U,ab_unmap.aux_dsaltfec:HANDLE IN FRAME {&FRAME-NAME}).
END PROCEDURE.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-assign-record w-html 
PROCEDURE local-assign-record :
    DEFINE INPUT PARAMETER opcao AS CHARACTER.
    
    /* Instancia a BO para executar as procedures */
    RUN dbo/b1wpgd0021.p PERSISTENT SET h-b1wpgd0021.
    
    /* Se BO foi instanciada */
    IF VALID-HANDLE(h-b1wpgd0021) THEN
       DO:
          DO WITH FRAME {&FRAME-NAME}:
             IF opcao = "inclusao" THEN
                DO: 
					CREATE gtpapgd.
                    /*ASSIGN gtpapgd.campo = INPUT gnpapgd.campo.*/
    
                    RUN inclui-registro IN h-b1wpgd0021(INPUT TABLE gtpapgd, OUTPUT msg-erro, OUTPUT ab_unmap.aux_nrdrowid).
                END.
             ELSE  /* alteracao */
                DO:
					/* cria a temp-table e joga o novo valor digitado para o campo */
                    CREATE gtpapgd.
                    BUFFER-COPY gnpapgd TO gtpapgd.
                    ASSIGN gtpapgd.idevento  = INPUT gnpapgd.idevento        
                           gtpapgd.cdcooper  = INPUT gnpapgd.cdcooper        
                           gtpapgd.dtanoage  = INPUT gnpapgd.dtanoage
                           gtpapgd.cdfreint  = INT(INPUT ab_unmap.aux_cdfreint)            
                           gtpapgd.qtpreint  = INPUT gnpapgd.qtpreint
                           gtpapgd.qtpreeve  = INPUT gnpapgd.qtpreeve
                           gtpapgd.qtmpreve  = INPUT gnpapgd.qtmpreve
                           gtpapgd.qtretque  = INPUT gnpapgd.qtretque.
    
                    IF   ab_unmap.aux_fechamen = "Sim"  THEN
					     RUN gravaMesesFechamento.
				    ELSE
					     RUN gravaMeses. 
					
                    RUN altera-registro IN h-b1wpgd0021(INPUT TABLE gtpapgd, INPUT ab_unmap.aux_fechamen, OUTPUT msg-erro).

                END.    
          END. /* DO WITH FRAME {&FRAME-NAME} */
       
          /* "mata" a instncia da BO */
          DELETE PROCEDURE h-b1wpgd0021 NO-ERROR.
       
       END. /* IF VALID-HANDLE(h-b1wpgd0021) */
      
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-delete-record w-html 
PROCEDURE local-delete-record :
    /* Instancia a BO para executar as procedures */
    RUN dbo/b1wpgd0021.p PERSISTENT SET h-b1wpgd0021.
     
    /* Se BO foi instanciada */
    IF VALID-HANDLE(h-b1wpgd0021) THEN
       DO:
          CREATE gtpapgd.
          BUFFER-COPY gnpapgd TO gtpapgd.
              
          RUN exclui-registro IN h-b1wpgd0021(INPUT TABLE gtpapgd, OUTPUT msg-erro).
    
          /* "mata" a instncia da BO */
          DELETE PROCEDURE h-b1wpgd0021 NO-ERROR.
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
       FIND PREV {&SECOND-ENABLED-TABLE} /*WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) */ NO-LOCK NO-WAIT NO-ERROR.

       IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
           DO:
               ASSIGN ab_unmap.aux_nrdrowid = STRING(ROWID({&SECOND-ENABLED-TABLE})).

               FIND PREV {&SECOND-ENABLED-TABLE} /*WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) */ NO-LOCK NO-WAIT NO-ERROR.

               IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                   ASSIGN ab_unmap.aux_stdopcao = "".
               ELSE
                   ASSIGN ab_unmap.aux_stdopcao = "".

               FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
           END.
       ELSE
           DO:
               RUN RodaJavaScript("alert('Este j  o primeiro registro.')"). 
               
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
FIND FIRST {&SECOND-ENABLED-TABLE} /*WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) */ NO-LOCK NO-WAIT NO-ERROR.


IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
    ASSIGN ab_unmap.aux_nrdrowid  = "?"
           ab_unmap.aux_stdopcao = "".
ELSE
    ASSIGN ab_unmap.aux_nrdrowid  = STRING(ROWID({&SECOND-ENABLED-TABLE}))
           ab_unmap.aux_stdopcao = "".  /* aqui p */



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PosicionaNoSeguinte w-html 
PROCEDURE PosicionaNoSeguinte :
FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.


IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
    DO:
       FIND NEXT {&SECOND-ENABLED-TABLE} /*WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) */ NO-LOCK NO-WAIT NO-ERROR.

       IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
           DO:
               ASSIGN ab_unmap.aux_nrdrowid = STRING(ROWID({&SECOND-ENABLED-TABLE})).

               FIND NEXT {&SECOND-ENABLED-TABLE} /*WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) */ NO-LOCK NO-WAIT NO-ERROR.

               IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                   ASSIGN ab_unmap.aux_stdopcao = "".
               ELSE
                   ASSIGN ab_unmap.aux_stdopcao = "".

               FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
           END.
       ELSE
           DO:
               RUN RodaJavaScript("alert('Este j  o ltimo registro.')").

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
FIND LAST {&SECOND-ENABLED-TABLE} /*WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) */ NO-LOCK NO-WAIT NO-ERROR.

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
   Nome: includes/webreq.i - Verso WebSpeed 2.1
  Autor: B&T/Solusoft
 Funo: Processo de requisio web p/ cadastros simples na web - Verso WebSpeed 3.0
  Notas: Este  o procedimento principal onde ter as requisies GET e POST.
         GET -  ativa quando o formulrio  chamado pela 1a vez
         POST - Aps o get somente ocorrer POST no formulrio      
         Caso seja necessrio custimiz-lo para algum programa especfico 
         Favor cpiar este procedimento para dentro do procedure process-web-requeste 
         faa l alteraes necessrias.
-------------------------------------------------------------------------------*/
v-identificacao = get-cookie("cookie-usuario-em-uso").

/* Usado FOR EACH para poder utilizar o CONTAINS e WORD-INDEX, alterado para MATCHES */
FOR EACH gnapses WHERE gnapses.idsessao MATCHES "*" + v-identificacao + "*" NO-LOCK:
    LEAVE.
END.
  
ASSIGN opcao                     = GET-FIELD("aux_cddopcao")
       FlagPermissoes            = GET-VALUE("aux_lspermis")
       msg-erro-aux              = 0
       ab_unmap.aux_idevento     = GET-VALUE("aux_idevento")
       ab_unmap.aux_dsendurl     = AppURL                        
       ab_unmap.aux_lspermis     = FlagPermissoes                
       ab_unmap.aux_nrdrowid     = GET-VALUE("aux_nrdrowid")         
       ab_unmap.aux_stdopcao     = GET-VALUE("aux_stdopcao")
       ab_unmap.pagina           = GET-VALUE("pagina")
       ab_unmap.aux_cdcooper     = GET-VALUE("aux_cdcooper")
       ab_unmap.cdfreint         = GET-VALUE("cdfreint")
       ab_unmap.aux_dtanoage_eve = GET-VALUE("aux_dtanoage_eve")
       ab_unmap.aux_dtanoage_int = GET-VALUE("aux_dtanoage_int")
       ab_unmap.aux_dtanoage_que = GET-VALUE("aux_dtanoage_que")
	   ab_unmap.aux_dtanoage_fec = GET-VALUE("aux_dtanoage_fec")
	   ab_unmap.aux_mesatual     = STRING(MONTH(TODAY),"99") + STRING(YEAR(TODAY),"9999")
	   ab_unmap.aux_fechamen     = GET-VALUE("aux_fechamen")
		 ab_unmap.aux_cdcopope     = GET-VALUE("aux_cdcopope")
		 ab_unmap.aux_cdoperad     = GET-VALUE("aux_cdoperad")
		 ab_unmap.aux_dsaltfec     = GET-VALUE("aux_dsaltfec").
	   
RUN recebeMeses.

FIND LAST gnpapgd WHERE gnpapgd.idevento = INT(ab_unmap.aux_idevento)  AND
                        gnpapgd.cdcooper = INT(ab_unmap.aux_cdcooper) NO-LOCK NO-ERROR.
						
IF   AVAIL gnpapgd  THEN
     ASSIGN ab_unmap.aux_dtanonov = STRING(gnpapgd.dtanonov).

RUN outputHeader.

/* Carrega o combo das cooperativas */
{includes/wpgd0098.i}
ab_unmap.aux_cdcooper:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = aux_crapcop.

/* Valida a existência de parâmetros após a escolha da cooperativa, somente
   permite que não haja parâmetros cadastrados, caso for a execução de uma
   nova agenda porque pode ser a primeira vez que a cooperativa faz isso */
IF   NOT AVAILABLE gnpapgd             AND
     INT(ab_unmap.aux_cdcooper) <> 0   AND
     opcao <> "nova"                   THEN
     DO:
         RUN displayFields.
         RUN enableFields.
         RUN outputFields.
         RUN RodaJavaScript("alert('Parâmetro da Agenda Não Encontrado!!!');").
         LEAVE.
     END.

RUN CriaLista.

/* mtodo POST */
IF REQUEST_METHOD = "POST":U THEN 
   DO:
      RUN inputFields.

      /* Instancia a BO para executar as procedures */
      RUN dbo/b1wpgd0021.p PERSISTENT SET h-b1wpgd0021.

      /* Se BO foi instanciada */
      IF VALID-HANDLE(h-b1wpgd0021) THEN
         DO:
            RUN posiciona-registro IN h-b1wpgd0021(INPUT TO-ROWID(ab_unmap.aux_nrdrowid), OUTPUT msg-erro).
            DELETE PROCEDURE h-b1wpgd0021 NO-ERROR.
         END.

      CASE opcao:
           WHEN "sa" THEN /* salvar */
                DO:
                    IF ab_unmap.aux_stdopcao = "i" THEN /* inclusao */
                        DO:
                            RUN local-assign-record ("inclusao"). 
                            IF msg-erro <> "" THEN
                               ASSIGN msg-erro-aux = 3. /* erros da validao de dados */
                            ELSE 
                            DO:
                               ASSIGN 
                                   msg-erro-aux = 10
                                   ab_unmap.aux_stdopcao = "al".
                               FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) EXCLUSIVE-LOCK NO-WAIT NO-ERROR.

                               IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                                  IF LOCKED {&SECOND-ENABLED-TABLE} THEN
                                     DO:
                                         ASSIGN msg-erro-aux = 1. /* registro em uso por outro usurio */  
                                         FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                                     END.
                                  ELSE
                                     DO: 
                                         ASSIGN msg-erro-aux = 2. /* registro no existe */
                                         RUN PosicionaNoSeguinte.
                                     END.

                            END.
                        END.  /* fim inclusao */
                    ELSE     /* alterao */ 
                        DO: 
                            FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) EXCLUSIVE-LOCK NO-WAIT NO-ERROR.

                            IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                               IF LOCKED {&SECOND-ENABLED-TABLE} THEN
                                  DO:
                                      ASSIGN msg-erro-aux = 1. /* registro em uso por outro usurio */  
                                      FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                                  END.
                               ELSE
                                  DO: 
                                      ASSIGN msg-erro-aux = 2. /* registro no existe */
                                      RUN PosicionaNoSeguinte.
                                  END.
                            ELSE
                               DO:
                                  RUN local-assign-record ("alteracao").  

                                  IF msg-erro = "" THEN
                                     ASSIGN msg-erro-aux = 10. /* Solicitao realizada com sucesso */ 
                                  ELSE
                                     ASSIGN msg-erro-aux = 3. /* erros da validao de dados */
                               END.     
                        END. /* fim alterao */
                END. /* fim salvar */

           WHEN "nova" THEN
                DO:
				   /* Preparação de uma nova Agenda */

                   /* Instancia a BO para executar as procedures */
                   RUN dbo/b1wpgd0021.p PERSISTENT SET h-b1wpgd0021.
               
                   /* Se BO foi instanciada */
                   IF VALID-HANDLE(h-b1wpgd0021) THEN
                      DO:
                         /* Busca a ultima data de agenda da cooperativa */
                         FIND LAST gnpapgd WHERE gnpapgd.idevento = INTEGER(ab_unmap.aux_idevento)   AND
                                                 gnpapgd.cdcooper = INTEGER(ab_unmap.aux_cdcooper)
                                                 NO-LOCK NO-ERROR.

                         /* cria a temp-table e joga os valores para o campo */
                         

                         CREATE gtpapgd.
                         ASSIGN gtpapgd.idevento  = INTEGER(ab_unmap.aux_idevento)
                                gtpapgd.cdcooper  = INTEGER(ab_unmap.aux_cdcooper)
                                gtpapgd.dtanonov  = INPUT gnpapgd.dtanonov
                                gtpapgd.dtiniage  = TODAY
                                gtpapgd.cdfreint  = 0
                                gtpapgd.qtpreint  = 0
                                gtpapgd.qtpreeve  = 0
                                gtpapgd.qtmpreve  = 0
                                gtpapgd.qtretque  = 0.

                         /* Progrid */
                         IF  INTEGER(ab_unmap.aux_idevento) = 1  THEN
                             DO:
                                ASSIGN gtpapgd.dtanoage  = IF AVAILABLE gnpapgd THEN
                                                              gnpapgd.dtanoage
                                                           ELSE
                                                               YEAR(TODAY)
                                       gtpapgd.dtmvtolt  = IF AVAILABLE gnpapgd THEN
                                                              gnpapgd.dtmvtolt
                                                           ELSE
                                                              TODAY.
                             END.
                         ELSE /* Assembléia*/
                             ASSIGN gtpapgd.dtanoage = gtpapgd.dtanonov
                                    gtpapgd.dtmvtolt = gtpapgd.dtiniage.
                         
                         RUN inclui-registro IN h-b1wpgd0021(INPUT TABLE gtpapgd, OUTPUT msg-erro, OUTPUT ab_unmap.aux_nrdrowid).

                         IF msg-erro <> "" THEN
                            ASSIGN msg-erro-aux = 3. /* erros da validao de dados */
                         ELSE 
                            DO:
                                /* criação dos parâmetros OK */
                                ASSIGN msg-erro-aux = 10.

                                /* Se for Progrid */
                                /*IF   INTEGER(ab_unmap.aux_idevento) = 1  THEN Prj. 322*/
                               RUN carrega_PACS (gtpapgd.dtanonov).
                            END.                            

                         /* "mata" a instncia da BO */
                         DELETE PROCEDURE h-b1wpgd0021 NO-ERROR.
               
                      END. /* IF VALID-HANDLE(h-b1wpgd0021) */
                END.
           
           WHEN "atual" THEN
                DO:
                   /* Atualização da Agenda */

                   /* Instancia a BO para executar as procedures */
                   RUN dbo/b1wpgd0021.p PERSISTENT SET h-b1wpgd0021.
               
                   /* Se BO foi instanciada */
                   IF VALID-HANDLE(h-b1wpgd0021) THEN
                      DO:
                         /* Busca a ultima data de agenda da cooperativa */
                         FIND LAST gnpapgd WHERE gnpapgd.idevento = INTEGER(ab_unmap.aux_idevento)   AND
                                                 gnpapgd.cdcooper = INTEGER(ab_unmap.aux_cdcooper)
                                                 NO-LOCK NO-ERROR.

                         /* cria a temp-table e joga os valores para o campo */
                         CREATE gtpapgd.

                         BUFFER-COPY gnpapgd EXCEPT gnpapgd.dtanoage gnpapgd.dtmvtolt TO gtpapgd.

                         ASSIGN gtpapgd.dtanoage  = INPUT gnpapgd.dtanoage
                                gtpapgd.dtmvtolt  = TODAY.
                         
						 RUN altera-registro IN h-b1wpgd0021(INPUT TABLE gtpapgd, INPUT ab_unmap.aux_fechamen, OUTPUT msg-erro).

                         IF msg-erro <> "" THEN
                            ASSIGN msg-erro-aux = 3. /* erros da validao de dados */
                         ELSE 
                            DO:
                                /* criação dos parâmetros OK */
                                ASSIGN msg-erro-aux = 10.

                                IF   INPUT ab_unmap.aux_carpacs = YES   THEN
                                     RUN carrega_PACS (gtpapgd.dtanoage).
                            END.                            

                         /* "mata" a instncia da BO */
                         DELETE PROCEDURE h-b1wpgd0021 NO-ERROR.
               
                      END. /* IF VALID-HANDLE(h-b1wpgd0021) */
                END.

      END CASE.

	  /* Tratar aba "Fechamento" diferente das demais */ 
	  IF   ab_unmap.aux_fechamen = "Sim"  THEN
	       DO:
			   /* Busca a ultima data de agenda da cooperativa com a data informada */
      		   FIND LAST gnpapgd WHERE gnpapgd.idevento = INTEGER(ab_unmap.aux_idevento)       AND
                         		       gnpapgd.cdcooper = INTEGER(ab_unmap.aux_cdcooper)       AND
                              		   gnpapgd.dtanonov = INTEGER(ab_unmap.aux_dtanoage_fec)   NO-LOCK NO-ERROR.
               
               /* Se não achar com aquela data, pega o último registro */
      		   IF   NOT AVAILABLE gnpapgd   THEN
           	   		FIND LAST gnpapgd WHERE gnpapgd.idevento = INTEGER(ab_unmap.aux_idevento)   AND
                    	 	  		        gnpapgd.cdcooper = INTEGER(ab_unmap.aux_cdcooper)   NO-LOCK NO-ERROR.

               IF   AVAIL gnpapgd  THEN
			        DO:
					    RUN mostraRegistroFechamento.
						ASSIGN ab_unmap.aux_dtanoage_fec = STRING(gnpapgd.dtanonov)
						       ab_unmap.aux_nrdrowid     = STRING(ROWID(gnpapgd)). 
	                END.
									
					/* Se for alterado algum mes na aba de fechamento, encerra alguns eventos */		
					IF INT(aux_dsaltfec) = 1 THEN
						DO:					
							FOR EACH crapadp WHERE crapadp.idevento = INTEGER(ab_unmap.aux_idevento)
																 AND crapadp.cdcooper = INTEGER(ab_unmap.aux_cdcooper)
                                 AND crapadp.dtanoage = INTEGER(ab_unmap.aux_dtanoage_fec) 
																 AND CAN-DO("1,3,5,6",STRING(crapadp.idstaeve))
																 AND CAN-DO(aux_mesfech,STRING(crapadp.nrmeseve))
                                 AND crapadp.cdevento < 50000 EXCLUSIVE-LOCK:
								
								ASSIGN crapadp.idstaeve = 4
											 crapadp.cdcopope = INTEGER(ab_unmap.aux_cdcopope)
											 crapadp.cdoperad = STRING(ab_unmap.aux_cdoperad).
							
                /* ATUALIZAR STATUS IDP */
                FOR EACH crapidp WHERE crapidp.idevento = INTEGER(ab_unmap.aux_idevento)
                                   AND crapidp.cdcooper = INTEGER(ab_unmap.aux_cdcooper)
                                   AND crapidp.dtanoage = INTEGER(ab_unmap.aux_dtanoage_fec)
                                   AND crapidp.cdevento = crapadp.cdevento
                                   AND crapidp.nrseqeve = crapadp.nrseqdig
                                   and crapidp.idstains = 1 EXCLUSIVE-LOCK:
                                   
                    ASSIGN crapidp.idstains = 4
                           crapidp.dtconins = TODAY.
                    
                END.                                   
                /* FIM ATUALIZAR STATUS IDP */
              
              END.
						END.
		   END.
	  ELSE
	       DO:
			   /* Para poder carregar a aba "Fechamento" com o ano da Agenda Atual, 
			      na primeira vez que entrar na tela, ao selecionar a cooperativa */ 
               FIND LAST b-gnpapgd WHERE b-gnpapgd.idevento = INTEGER(ab_unmap.aux_idevento)   AND
                                         b-gnpapgd.cdcooper = INTEGER(ab_unmap.aux_cdcooper)   NO-LOCK NO-ERROR.

			   ab_unmap.aux_dtanoage_fec = STRING(b-gnpapgd.dtanoage).

			   FIND LAST gnpapgd WHERE gnpapgd.idevento = INTEGER(ab_unmap.aux_idevento)       AND
                                       gnpapgd.cdcooper = INTEGER(ab_unmap.aux_cdcooper)       AND
                              		   gnpapgd.dtanonov = INTEGER(ab_unmap.aux_dtanoage_fec)   NO-LOCK NO-ERROR.
						
			   RUN mostraRegistroFechamento. 
			   
			   /* Busca a ultima data de agenda da cooperativa com a data informada */
      		   FIND LAST gnpapgd WHERE gnpapgd.idevento = INTEGER(ab_unmap.aux_idevento)       AND
                              	 	   gnpapgd.cdcooper = INTEGER(ab_unmap.aux_cdcooper)       AND
                              		   gnpapgd.dtanonov = INTEGER(ab_unmap.aux_dtanoage_eve)   NO-LOCK NO-ERROR.

      	       /* Se não achar com aquela data, pega o último registro */
      		   IF   NOT AVAILABLE gnpapgd   THEN
           	   		FIND LAST gnpapgd WHERE gnpapgd.idevento = INTEGER(ab_unmap.aux_idevento)   AND
                    	 	  		        gnpapgd.cdcooper = INTEGER(ab_unmap.aux_cdcooper)   NO-LOCK NO-ERROR.

      		   /* Atualiza os campos para a agenda que está sendo preparada */
      		   IF   AVAILABLE gnpapgd   THEN
           	   		DO:
               		    ASSIGN ab_unmap.aux_dtanoage_eve = STRING(gnpapgd.dtanonov)
                      		   ab_unmap.aux_dtanoage_int = STRING(gnpapgd.dtanonov)
                      		   ab_unmap.aux_dtanoage_que = STRING(gnpapgd.dtanonov)
                      		   ab_unmap.aux_nrdrowid     = STRING(ROWID(gnpapgd)).

               		    RUN mostraRegistro.

           		    END.
		   END.

      RUN displayFields.
      RUN enableFields.
      RUN outputFields.

      /* Esconde a parte de Manutenção da Agenda se for Assembléia */
      IF   INTEGER(ab_unmap.aux_idevento) = 2  THEN
           DO:
              RUN RodaJavaScript('document.form.all.divAbaEventos.style.visibility = "hidden";').
              RUN RodaJavaScript('document.form.all.divAbaIntegra.style.visibility = "hidden";').
              /*RUN RodaJavaScript('document.form.all.divManutencao.style.visibility = "hidden";').*/
              RUN RodaJavaScript('document.form.all.divAbaQuest.style.visibility = "hidden";').
           END.

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
                IF opcao <> "" THEN
                   RUN RodaJavaScript('alert("Atualização executada com sucesso.")'). 
         
      END CASE.     

      RUN RodaJavaScript('top.frames[0].ZeraOp()').   

   END. /* Fim do mtodo POST */
ELSE /* Mtodo GET */ 
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
                                         /*ab_unmap.aux_idevento = STRING({&SECOND-ENABLED-TABLE}.idevento)*/ .

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
                       DO:
						   /* Busca a ultima data de agenda da cooperativa */
                           FIND LAST gnpapgd WHERE gnpapgd.idevento = INTEGER(ab_unmap.aux_idevento)   AND
                                                   gnpapgd.cdcooper = INTEGER(ab_unmap.aux_cdcooper)
                                                   NO-LOCK NO-ERROR.
                           
                           /* Atualiza os campos para a agenda que está sendo preparada */
                           IF   AVAILABLE gnpapgd THEN
                                DO:
									ASSIGN ab_unmap.aux_dtanoage_eve = STRING(gnpapgd.dtanonov)
                                           ab_unmap.aux_dtanoage_int = STRING(gnpapgd.dtanonov)
                                           ab_unmap.aux_dtanoage_que = STRING(gnpapgd.dtanonov)
                                           ab_unmap.aux_nrdrowid     = STRING(ROWID(gnpapgd)).
										                                       
                                    RUN mostraRegistro.
                                END.
                       END.

                    ASSIGN ab_unmap.aux_stdopcao = "al".

				    RUN displayFields.
                    RUN enableFields.
                    RUN outputFields.
                    RUN RodaJavaScript('top.frcod.FechaZoom()').
                    RUN RodaJavaScript('CarregaPrincipal()').

                    /* Deixa a cooperativa em branco quando entra na tela */
                    RUN RodaJavaScript('document.form.aux_cdcooper.value = "";').
                    /* Esconte as datas de atualizacao e inicio da agenda */
                    RUN RodaJavaScript('document.form.all.divDataIni.style.visibility = "hidden";').
                    RUN RodaJavaScript('document.form.all.divDataAtu.style.visibility = "hidden";').

                    /* Esconde a parte de Manutenção da Agenda se for Assembléia */
                    IF   INTEGER(ab_unmap.aux_idevento) = 2  THEN
                         DO:
                            RUN RodaJavaScript('document.form.all.divAbaEventos.style.visibility = "hidden";').
                            RUN RodaJavaScript('document.form.all.divAbaIntegra.style.visibility = "hidden";').
                            /*RUN RodaJavaScript('document.form.all.divManutencao.style.visibility = "hidden";').*/
                            RUN RodaJavaScript('document.form.all.divAbaQuest.style.visibility = "hidden";').
                         END.
                    
                END. /* fim otherwise */                  
      END CASE. 
END. /* fim do mtodo GET */

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
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE mostraRegistro w-html 
PROCEDURE mostraRegistro:
    ASSIGN ab_unmap.cdfreint     = IF   ab_unmap.aux_idevento = "2"   THEN "" /* Para assembleia */
                                   ELSE STRING(gnpapgd.cdfreint)
           ab_unmap.aux_mes01eve = FALSE
           ab_unmap.aux_mes02eve = FALSE
           ab_unmap.aux_mes03eve = FALSE
           ab_unmap.aux_mes04eve = FALSE
           ab_unmap.aux_mes05eve = FALSE
           ab_unmap.aux_mes06eve = FALSE
           ab_unmap.aux_mes07eve = FALSE
           ab_unmap.aux_mes08eve = FALSE
           ab_unmap.aux_mes09eve = FALSE
           ab_unmap.aux_mes10eve = FALSE
           ab_unmap.aux_mes11eve = FALSE

           ab_unmap.aux_mes01int = FALSE
           ab_unmap.aux_mes02int = FALSE
           ab_unmap.aux_mes03int = FALSE
           ab_unmap.aux_mes04int = FALSE
           ab_unmap.aux_mes05int = FALSE
           ab_unmap.aux_mes06int = FALSE
           ab_unmap.aux_mes07int = FALSE
           ab_unmap.aux_mes08int = FALSE
           ab_unmap.aux_mes09int = FALSE
           ab_unmap.aux_mes10int = FALSE
           ab_unmap.aux_mes11int = FALSE
           ab_unmap.aux_mes12int = FALSE.
		   
    IF LOOKUP("1",gnpapgd.lsmeseve) <> 0 THEN 
       ASSIGN ab_unmap.aux_mes01eve = TRUE.
    IF LOOKUP("2",gnpapgd.lsmeseve) <> 0 THEN 
       ASSIGN ab_unmap.aux_mes02eve = TRUE.
    IF LOOKUP("3",gnpapgd.lsmeseve) <> 0 THEN 
       ASSIGN ab_unmap.aux_mes03eve = TRUE.
    IF LOOKUP("4",gnpapgd.lsmeseve) <> 0 THEN 
       ASSIGN ab_unmap.aux_mes04eve = TRUE.
    IF LOOKUP("5",gnpapgd.lsmeseve) <> 0 THEN 
       ASSIGN ab_unmap.aux_mes05eve = TRUE.
    IF LOOKUP("6",gnpapgd.lsmeseve) <> 0 THEN 
       ASSIGN ab_unmap.aux_mes06eve = TRUE.
    IF LOOKUP("7",gnpapgd.lsmeseve) <> 0 THEN 
       ASSIGN ab_unmap.aux_mes07eve = TRUE.
    IF LOOKUP("8",gnpapgd.lsmeseve) <> 0 THEN 
       ASSIGN ab_unmap.aux_mes08eve = TRUE.
    IF LOOKUP("9",gnpapgd.lsmeseve) <> 0 THEN 
       ASSIGN ab_unmap.aux_mes09eve = TRUE.
    IF LOOKUP("10",gnpapgd.lsmeseve) <> 0 THEN 
       ASSIGN ab_unmap.aux_mes10eve = TRUE.
    IF LOOKUP("11",gnpapgd.lsmeseve) <> 0 THEN 
       ASSIGN ab_unmap.aux_mes11eve = TRUE.
    IF LOOKUP("12",gnpapgd.lsmeseve) <> 0 THEN 
       ASSIGN ab_unmap.aux_mes12eve = TRUE.
    
    IF LOOKUP("1",gnpapgd.lsmesint) <> 0 THEN 
       ASSIGN ab_unmap.aux_mes01int = TRUE.
    IF LOOKUP("2",gnpapgd.lsmesint) <> 0 THEN 
       ASSIGN ab_unmap.aux_mes02int = TRUE.
    IF LOOKUP("3",gnpapgd.lsmesint) <> 0 THEN 
       ASSIGN ab_unmap.aux_mes03int = TRUE.
    IF LOOKUP("4",gnpapgd.lsmesint) <> 0 THEN 
       ASSIGN ab_unmap.aux_mes04int = TRUE.
    IF LOOKUP("5",gnpapgd.lsmesint) <> 0 THEN 
       ASSIGN ab_unmap.aux_mes05int = TRUE.
    IF LOOKUP("6",gnpapgd.lsmesint) <> 0 THEN 
       ASSIGN ab_unmap.aux_mes06int = TRUE.
    IF LOOKUP("7",gnpapgd.lsmesint) <> 0 THEN 
       ASSIGN ab_unmap.aux_mes07int = TRUE.
    IF LOOKUP("8",gnpapgd.lsmesint) <> 0 THEN 
       ASSIGN ab_unmap.aux_mes08int = TRUE.
    IF LOOKUP("9",gnpapgd.lsmesint) <> 0 THEN 
       ASSIGN ab_unmap.aux_mes09int = TRUE.
    IF LOOKUP("10",gnpapgd.lsmesint) <> 0 THEN 
       ASSIGN ab_unmap.aux_mes10int = TRUE.
    IF LOOKUP("11",gnpapgd.lsmesint) <> 0 THEN 
       ASSIGN ab_unmap.aux_mes11int = TRUE.
    IF LOOKUP("12",gnpapgd.lsmesint) <> 0 THEN 
       ASSIGN ab_unmap.aux_mes12int = TRUE.
	   
END PROCEDURE.
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE mostraRegistroFechamento w-html 
PROCEDURE mostraRegistroFechamento:
    ASSIGN ab_unmap.aux_mes01fec = FALSE
           ab_unmap.aux_mes02fec = FALSE
           ab_unmap.aux_mes03fec = FALSE
           ab_unmap.aux_mes04fec = FALSE
           ab_unmap.aux_mes05fec = FALSE
           ab_unmap.aux_mes06fec = FALSE
           ab_unmap.aux_mes07fec = FALSE
           ab_unmap.aux_mes08fec = FALSE
           ab_unmap.aux_mes09fec = FALSE
           ab_unmap.aux_mes10fec = FALSE
           ab_unmap.aux_mes11fec = FALSE
           ab_unmap.aux_mes12fec = FALSE.
           
    IF LOOKUP("1",gnpapgd.lsmesctb) <> 0 THEN 
       ASSIGN ab_unmap.aux_mes01fec = TRUE.
    IF LOOKUP("2",gnpapgd.lsmesctb) <> 0 THEN 
       ASSIGN ab_unmap.aux_mes02fec = TRUE.
    IF LOOKUP("3",gnpapgd.lsmesctb) <> 0 THEN 
       ASSIGN ab_unmap.aux_mes03fec = TRUE.
    IF LOOKUP("4",gnpapgd.lsmesctb) <> 0 THEN 
       ASSIGN ab_unmap.aux_mes04fec = TRUE.
    IF LOOKUP("5",gnpapgd.lsmesctb) <> 0 THEN 
       ASSIGN ab_unmap.aux_mes05fec = TRUE.
    IF LOOKUP("6",gnpapgd.lsmesctb) <> 0 THEN 
       ASSIGN ab_unmap.aux_mes06fec = TRUE.
    IF LOOKUP("7",gnpapgd.lsmesctb) <> 0 THEN 
       ASSIGN ab_unmap.aux_mes07fec = TRUE.
    IF LOOKUP("8",gnpapgd.lsmesctb) <> 0 THEN 
       ASSIGN ab_unmap.aux_mes08fec = TRUE.
    IF LOOKUP("9",gnpapgd.lsmesctb) <> 0 THEN 
       ASSIGN ab_unmap.aux_mes09fec = TRUE.
    IF LOOKUP("10",gnpapgd.lsmesctb) <> 0 THEN 
       ASSIGN ab_unmap.aux_mes10fec = TRUE.
    IF LOOKUP("11",gnpapgd.lsmesctb) <> 0 THEN 
       ASSIGN ab_unmap.aux_mes11fec = TRUE.
    IF LOOKUP("12",gnpapgd.lsmesctb) <> 0 THEN 
       ASSIGN ab_unmap.aux_mes12fec = TRUE.
	   
END PROCEDURE.
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE recebeMeses w-html 
PROCEDURE recebeMeses:

  IF GET-VALUE("aux_mes01eve") = "1" THEN
    ASSIGN ab_unmap.aux_mes01eve = TRUE.
  ELSE
    ASSIGN ab_unmap.aux_mes01eve = FALSE.
  IF GET-VALUE("aux_mes02eve") = "2" THEN
    ASSIGN ab_unmap.aux_mes02eve = TRUE.
  ELSE
    ASSIGN ab_unmap.aux_mes02eve = FALSE.
  IF GET-VALUE("aux_mes03eve") = "3" THEN
    ASSIGN ab_unmap.aux_mes03eve = TRUE.
  ELSE
    ASSIGN ab_unmap.aux_mes03eve = FALSE.
  IF GET-VALUE("aux_mes04eve") = "4" THEN
    ASSIGN ab_unmap.aux_mes04eve = TRUE.
  ELSE
    ASSIGN ab_unmap.aux_mes04eve = FALSE.
  IF GET-VALUE("aux_mes05eve") = "5" THEN
    ASSIGN ab_unmap.aux_mes05eve = TRUE.
  ELSE
    ASSIGN ab_unmap.aux_mes05eve = FALSE.
  IF GET-VALUE("aux_mes06eve") = "6" THEN
    ASSIGN ab_unmap.aux_mes06eve = TRUE.
  ELSE
    ASSIGN ab_unmap.aux_mes06eve = FALSE.
  IF GET-VALUE("aux_mes07eve") = "7" THEN
    ASSIGN ab_unmap.aux_mes07eve = TRUE.
  ELSE
    ASSIGN ab_unmap.aux_mes07eve = FALSE.
  IF GET-VALUE("aux_mes08eve") = "8" THEN
    ASSIGN ab_unmap.aux_mes08eve = TRUE.
  ELSE
    ASSIGN ab_unmap.aux_mes08eve = FALSE.
  IF GET-VALUE("aux_mes09eve") = "9" THEN
    ASSIGN ab_unmap.aux_mes09eve = TRUE.
  ELSE
    ASSIGN ab_unmap.aux_mes09eve = FALSE.
  IF GET-VALUE("aux_mes10eve") = "10" THEN
    ASSIGN ab_unmap.aux_mes10eve = TRUE.
  ELSE
    ASSIGN ab_unmap.aux_mes10eve = FALSE.
  IF GET-VALUE("aux_mes11eve") = "11" THEN
    ASSIGN ab_unmap.aux_mes11eve = TRUE.
  ELSE
    ASSIGN ab_unmap.aux_mes11eve = FALSE.
  IF GET-VALUE("aux_mes12eve") = "12" THEN
    ASSIGN ab_unmap.aux_mes12eve = TRUE.
  ELSE
    ASSIGN ab_unmap.aux_mes12eve = FALSE.

  IF GET-VALUE("aux_mes01int") = "1" THEN
    ASSIGN ab_unmap.aux_mes01int = TRUE.
  ELSE
    ASSIGN ab_unmap.aux_mes01int = FALSE.
  IF GET-VALUE("aux_mes02int") = "2" THEN
    ASSIGN ab_unmap.aux_mes02int = TRUE.
  ELSE
    ASSIGN ab_unmap.aux_mes02int = FALSE.
  IF GET-VALUE("aux_mes03int") = "3" THEN
    ASSIGN ab_unmap.aux_mes03int = TRUE.
  ELSE
    ASSIGN ab_unmap.aux_mes03int = FALSE.
  IF GET-VALUE("aux_mes04int") = "4" THEN
    ASSIGN ab_unmap.aux_mes04int = TRUE.
  ELSE
    ASSIGN ab_unmap.aux_mes04int = FALSE.
  IF GET-VALUE("aux_mes05int") = "5" THEN
    ASSIGN ab_unmap.aux_mes05int = TRUE.
  ELSE
    ASSIGN ab_unmap.aux_mes05int = FALSE.
  IF GET-VALUE("aux_mes06int") = "6" THEN
    ASSIGN ab_unmap.aux_mes06int = TRUE.
  ELSE
    ASSIGN ab_unmap.aux_mes06int = FALSE.
  IF GET-VALUE("aux_mes07int") = "7" THEN
    ASSIGN ab_unmap.aux_mes07int = TRUE.
  ELSE
    ASSIGN ab_unmap.aux_mes07int = FALSE.
  IF GET-VALUE("aux_mes08int") = "8" THEN
    ASSIGN ab_unmap.aux_mes08int = TRUE.
  ELSE
    ASSIGN ab_unmap.aux_mes08int = FALSE.
  IF GET-VALUE("aux_mes09int") = "9" THEN
    ASSIGN ab_unmap.aux_mes09int = TRUE.
  ELSE
    ASSIGN ab_unmap.aux_mes09int = FALSE.
  IF GET-VALUE("aux_mes10int") = "10" THEN
    ASSIGN ab_unmap.aux_mes10int = TRUE.
  ELSE
    ASSIGN ab_unmap.aux_mes10int = FALSE.
  IF GET-VALUE("aux_mes11int") = "11" THEN
    ASSIGN ab_unmap.aux_mes11int = TRUE.
  ELSE
    ASSIGN ab_unmap.aux_mes11int = FALSE.
  IF GET-VALUE("aux_mes12int") = "12" THEN
    ASSIGN ab_unmap.aux_mes12int = TRUE.
  ELSE
    ASSIGN ab_unmap.aux_mes12int = FALSE.
	
	/*MESES DE FECHAMENTO*/
	ASSIGN aux_mesfech = "".
  IF GET-VALUE("aux_mes01fec") = "1" THEN
	DO:
    ASSIGN ab_unmap.aux_mes01fec = TRUE
					 aux_mesfech = aux_mesfech + "1".
	END.
  ELSE
    ASSIGN ab_unmap.aux_mes01fec = FALSE.

  IF GET-VALUE("aux_mes02fec") = "2" THEN
    DO:
			ASSIGN ab_unmap.aux_mes02fec = TRUE
					 aux_mesfech = aux_mesfech + ",2".
		 END.
  ELSE
    ASSIGN ab_unmap.aux_mes02fec = FALSE.
  IF GET-VALUE("aux_mes03fec") = "3" THEN
    DO:
			ASSIGN ab_unmap.aux_mes03fec = TRUE
					 aux_mesfech = aux_mesfech + ",3".
		 END.
  ELSE
    ASSIGN ab_unmap.aux_mes03fec = FALSE.
  IF GET-VALUE("aux_mes04fec") = "4" THEN
    DO:
			ASSIGN ab_unmap.aux_mes04fec = TRUE
					 aux_mesfech = aux_mesfech + ",4".
		 END.
  ELSE
    ASSIGN ab_unmap.aux_mes04fec = FALSE.
  IF GET-VALUE("aux_mes05fec") = "5" THEN
    DO:
			ASSIGN ab_unmap.aux_mes05fec = TRUE
					 aux_mesfech = aux_mesfech + ",5".
		 END.
  ELSE
    ASSIGN ab_unmap.aux_mes05fec = FALSE.
  IF GET-VALUE("aux_mes06fec") = "6" THEN
    DO:
			ASSIGN ab_unmap.aux_mes06fec = TRUE
					 aux_mesfech = aux_mesfech + ",6".
		 END.
  ELSE
    ASSIGN ab_unmap.aux_mes06fec = FALSE.
  IF GET-VALUE("aux_mes07fec") = "7" THEN
    DO:
			ASSIGN ab_unmap.aux_mes07fec = TRUE
					 aux_mesfech = aux_mesfech + ",7".
		 END.
  ELSE
    ASSIGN ab_unmap.aux_mes07fec = FALSE.
  IF GET-VALUE("aux_mes08fec") = "8" THEN
   DO:
			ASSIGN ab_unmap.aux_mes08fec = TRUE
					 aux_mesfech = aux_mesfech + ",8".
		 END.
  ELSE
    ASSIGN ab_unmap.aux_mes08fec = FALSE.
  IF GET-VALUE("aux_mes09fec") = "9" THEN
		DO:
			ASSIGN ab_unmap.aux_mes09fec = TRUE
					 aux_mesfech = aux_mesfech + ",9".
		END.
  ELSE
    ASSIGN ab_unmap.aux_mes09fec = FALSE.
  IF GET-VALUE("aux_mes10fec") = "10" THEN
    DO:
			ASSIGN ab_unmap.aux_mes10fec = TRUE
					 aux_mesfech = aux_mesfech + ",10".
		END.
  ELSE
    ASSIGN ab_unmap.aux_mes10fec = FALSE.
  IF GET-VALUE("aux_mes11fec") = "11" THEN
    DO:
			ASSIGN ab_unmap.aux_mes11fec = TRUE
					 aux_mesfech = aux_mesfech + ",11".
		END.
  ELSE
    ASSIGN ab_unmap.aux_mes11fec = FALSE.
  IF GET-VALUE("aux_mes12fec") = "12" THEN
    DO:
			ASSIGN ab_unmap.aux_mes12fec = TRUE
					 aux_mesfech = aux_mesfech + ",12".
		END.
  ELSE
    ASSIGN ab_unmap.aux_mes12fec = FALSE.	
END PROCEDURE.
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE gravaMeses w-html 
PROCEDURE gravaMeses:
  ASSIGN gtpapgd.lsmeseve = "".
  IF ab_unmap.aux_mes01eve = TRUE THEN DO:
     IF gtpapgd.lsmeseve = "" THEN
        ASSIGN gtpapgd.lsmeseve = "1".
     ELSE
        ASSIGN gtpapgd.lsmeseve = gtpapgd.lsmeseve + ",1".
  END.
  IF ab_unmap.aux_mes02eve = TRUE THEN DO:
     IF gtpapgd.lsmeseve = "" THEN
        ASSIGN gtpapgd.lsmeseve = "2".
     ELSE
        ASSIGN gtpapgd.lsmeseve = gtpapgd.lsmeseve + ",2".
  END.
  IF ab_unmap.aux_mes03eve = TRUE THEN DO:
     IF gtpapgd.lsmeseve = "" THEN
        ASSIGN gtpapgd.lsmeseve = "3".
     ELSE
        ASSIGN gtpapgd.lsmeseve = gtpapgd.lsmeseve + ",3".
  END.
  IF ab_unmap.aux_mes04eve = TRUE THEN DO:
     IF gtpapgd.lsmeseve = "" THEN
        ASSIGN gtpapgd.lsmeseve = "4".
     ELSE
        ASSIGN gtpapgd.lsmeseve = gtpapgd.lsmeseve + ",4".
  END.
  IF ab_unmap.aux_mes05eve = TRUE THEN DO:
     IF gtpapgd.lsmeseve = "" THEN
        ASSIGN gtpapgd.lsmeseve = "5".
     ELSE
        ASSIGN gtpapgd.lsmeseve = gtpapgd.lsmeseve + ",5".
  END.
  IF ab_unmap.aux_mes06eve = TRUE THEN DO:
     IF gtpapgd.lsmeseve = "" THEN
        ASSIGN gtpapgd.lsmeseve = "6".
     ELSE
        ASSIGN gtpapgd.lsmeseve = gtpapgd.lsmeseve + ",6".
  END.
  IF ab_unmap.aux_mes07eve = TRUE THEN DO:
     IF gtpapgd.lsmeseve = "" THEN
        ASSIGN gtpapgd.lsmeseve = "7".
     ELSE
        ASSIGN gtpapgd.lsmeseve = gtpapgd.lsmeseve + ",7".
  END.
  IF ab_unmap.aux_mes08eve = TRUE THEN DO:
     IF gtpapgd.lsmeseve = "" THEN
        ASSIGN gtpapgd.lsmeseve = "8".
     ELSE
        ASSIGN gtpapgd.lsmeseve = gtpapgd.lsmeseve + ",8".
  END.
  IF ab_unmap.aux_mes09eve = TRUE THEN DO:
     IF gtpapgd.lsmeseve = "" THEN
        ASSIGN gtpapgd.lsmeseve = "9".
     ELSE
        ASSIGN gtpapgd.lsmeseve = gtpapgd.lsmeseve + ",9".
  END.
  IF ab_unmap.aux_mes10eve = TRUE THEN DO:
     IF gtpapgd.lsmeseve = "" THEN
        ASSIGN gtpapgd.lsmeseve = "10".
     ELSE
        ASSIGN gtpapgd.lsmeseve = gtpapgd.lsmeseve + ",10".
  END.
  IF ab_unmap.aux_mes11eve = TRUE THEN DO:
     IF gtpapgd.lsmeseve = "" THEN
        ASSIGN gtpapgd.lsmeseve = "11".
     ELSE
        ASSIGN gtpapgd.lsmeseve = gtpapgd.lsmeseve + ",11".
  END.
  IF ab_unmap.aux_mes12eve = TRUE THEN DO:
     IF gtpapgd.lsmeseve = "" THEN
        ASSIGN gtpapgd.lsmeseve = "12".
     ELSE
        ASSIGN gtpapgd.lsmeseve = gtpapgd.lsmeseve + ",12".
  END.
  ASSIGN gtpapgd.lsmesint = "".
  IF ab_unmap.aux_mes01int = TRUE THEN DO:
     IF gtpapgd.lsmesint = "" THEN
        ASSIGN gtpapgd.lsmesint = "1".
     ELSE
        ASSIGN gtpapgd.lsmesint = gtpapgd.lsmesint + ",1".
  END.
  IF ab_unmap.aux_mes02int = TRUE THEN DO:
     IF gtpapgd.lsmesint = "" THEN
        ASSIGN gtpapgd.lsmesint = "2".
     ELSE
        ASSIGN gtpapgd.lsmesint = gtpapgd.lsmesint + ",2".
  END.
  IF ab_unmap.aux_mes03int = TRUE THEN DO:
     IF gtpapgd.lsmesint = "" THEN
        ASSIGN gtpapgd.lsmesint = "3".
     ELSE
        ASSIGN gtpapgd.lsmesint = gtpapgd.lsmesint + ",3".
  END.
  IF ab_unmap.aux_mes04int = TRUE THEN DO:
     IF gtpapgd.lsmesint = "" THEN
        ASSIGN gtpapgd.lsmesint = "4".
     ELSE
        ASSIGN gtpapgd.lsmesint = gtpapgd.lsmesint + ",4".
  END.
  IF ab_unmap.aux_mes05int = TRUE THEN DO:
     IF gtpapgd.lsmesint = "" THEN
        ASSIGN gtpapgd.lsmesint = "5".
     ELSE
        ASSIGN gtpapgd.lsmesint = gtpapgd.lsmesint + ",5".
  END.
  IF ab_unmap.aux_mes06int = TRUE THEN DO:
     IF gtpapgd.lsmesint = "" THEN
        ASSIGN gtpapgd.lsmesint = "6".
     ELSE
        ASSIGN gtpapgd.lsmesint = gtpapgd.lsmesint + ",6".
  END.
  IF ab_unmap.aux_mes07int = TRUE THEN DO:
     IF gtpapgd.lsmesint = "" THEN
        ASSIGN gtpapgd.lsmesint = "7".
     ELSE
        ASSIGN gtpapgd.lsmesint = gtpapgd.lsmesint + ",7".
  END.
  IF ab_unmap.aux_mes08int = TRUE THEN DO:
     IF gtpapgd.lsmesint = "" THEN
        ASSIGN gtpapgd.lsmesint = "8".
     ELSE
        ASSIGN gtpapgd.lsmesint = gtpapgd.lsmesint + ",8".
  END.
  IF ab_unmap.aux_mes09int = TRUE THEN DO:
     IF gtpapgd.lsmesint = "" THEN
        ASSIGN gtpapgd.lsmesint = "9".
     ELSE
        ASSIGN gtpapgd.lsmesint = gtpapgd.lsmesint + ",9".
  END.
  IF ab_unmap.aux_mes10int = TRUE THEN DO:
     IF gtpapgd.lsmesint = "" THEN
        ASSIGN gtpapgd.lsmesint = "10".
     ELSE
        ASSIGN gtpapgd.lsmesint = gtpapgd.lsmesint + ",10".
  END.
  IF ab_unmap.aux_mes11int = TRUE THEN DO:
     IF gtpapgd.lsmesint = "" THEN
        ASSIGN gtpapgd.lsmesint = "11".
     ELSE
        ASSIGN gtpapgd.lsmesint = gtpapgd.lsmesint + ",11".
  END.
  IF ab_unmap.aux_mes12int = TRUE THEN DO:
     IF gtpapgd.lsmesint = "" THEN
        ASSIGN gtpapgd.lsmesint = "12".
     ELSE
        ASSIGN gtpapgd.lsmesint = gtpapgd.lsmesint + ",12".
  END.                
END PROCEDURE.
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE gravaMesesFechamento w-html 
PROCEDURE gravaMesesFechamento:
  ASSIGN gtpapgd.lsmesctb = "".
  IF ab_unmap.aux_mes01fec = TRUE THEN DO:
     IF gtpapgd.lsmesctb = "" THEN
        ASSIGN gtpapgd.lsmesctb = "1".
     ELSE
        ASSIGN gtpapgd.lsmesctb = gtpapgd.lsmesctb + ",1".
  END.
  IF ab_unmap.aux_mes02fec = TRUE THEN DO:
     IF gtpapgd.lsmesctb = "" THEN
        ASSIGN gtpapgd.lsmesctb = "2".
     ELSE
        ASSIGN gtpapgd.lsmesctb = gtpapgd.lsmesctb + ",2".
  END.
  IF ab_unmap.aux_mes03fec = TRUE THEN DO:
     IF gtpapgd.lsmesctb = "" THEN
        ASSIGN gtpapgd.lsmesctb = "3".
     ELSE
        ASSIGN gtpapgd.lsmesctb = gtpapgd.lsmesctb + ",3".
  END.
  IF ab_unmap.aux_mes04fec = TRUE THEN DO:
     IF gtpapgd.lsmesctb = "" THEN
        ASSIGN gtpapgd.lsmesctb = "4".
     ELSE
        ASSIGN gtpapgd.lsmesctb = gtpapgd.lsmesctb + ",4".
  END.
  IF ab_unmap.aux_mes05fec = TRUE THEN DO:
     IF gtpapgd.lsmesctb = "" THEN
        ASSIGN gtpapgd.lsmesctb = "5".
     ELSE
        ASSIGN gtpapgd.lsmesctb = gtpapgd.lsmesctb + ",5".
  END.
  IF ab_unmap.aux_mes06fec = TRUE THEN DO:
     IF gtpapgd.lsmesctb = "" THEN
        ASSIGN gtpapgd.lsmesctb = "6".
     ELSE
        ASSIGN gtpapgd.lsmesctb = gtpapgd.lsmesctb + ",6".
  END.
  IF ab_unmap.aux_mes07fec = TRUE THEN DO:
     IF gtpapgd.lsmesctb = "" THEN
        ASSIGN gtpapgd.lsmesctb = "7".
     ELSE
        ASSIGN gtpapgd.lsmesctb = gtpapgd.lsmesctb + ",7".
  END.
  IF ab_unmap.aux_mes08fec = TRUE THEN DO:
     IF gtpapgd.lsmesctb = "" THEN
        ASSIGN gtpapgd.lsmesctb = "8".
     ELSE
        ASSIGN gtpapgd.lsmesctb = gtpapgd.lsmesctb + ",8".
  END.
  IF ab_unmap.aux_mes09fec = TRUE THEN DO:
     IF gtpapgd.lsmesctb = "" THEN
        ASSIGN gtpapgd.lsmesctb = "9".
     ELSE
        ASSIGN gtpapgd.lsmesctb = gtpapgd.lsmesctb + ",9".
  END.
  IF ab_unmap.aux_mes10fec = TRUE THEN DO:
     IF gtpapgd.lsmesctb = "" THEN
        ASSIGN gtpapgd.lsmesctb = "10".
     ELSE
        ASSIGN gtpapgd.lsmesctb = gtpapgd.lsmesctb + ",10".
  END.
  IF ab_unmap.aux_mes11fec = TRUE THEN DO:
     IF gtpapgd.lsmesctb = "" THEN
        ASSIGN gtpapgd.lsmesctb = "11".
     ELSE
        ASSIGN gtpapgd.lsmesctb = gtpapgd.lsmesctb + ",11".
  END.
  IF ab_unmap.aux_mes12fec = TRUE THEN DO:
     IF gtpapgd.lsmesctb = "" THEN
        ASSIGN gtpapgd.lsmesctb = "12".
     ELSE
        ASSIGN gtpapgd.lsmesctb = gtpapgd.lsmesctb + ",12".
  END.                   
END PROCEDURE.
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaLista w-html 
PROCEDURE CriaLista :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    /* Cria as Listas que são mostradas na tela */
        
    /* Busca as listas  */
    FIND FIRST craptab WHERE craptab.cdcooper = 0               AND
                             craptab.nmsistem = "CRED"          AND
                             craptab.tptabela = "CONFIG"        AND
                             craptab.cdempres = 0               AND
                             craptab.cdacesso = "PGFREQDINT"    AND
                             craptab.tpregist = 0               NO-LOCK NO-ERROR.
    
    /* Fim do Busca as listas de Tipo de Evento, Participacao Permitida e Eixos Tematicos */
    
    /* Preenche as listas com os elementos encontrados */
    ASSIGN ab_unmap.aux_cdfreint:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = UPPER(craptab.dstextab).

END PROCEDURE.
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE carrega_PACS w-html 
PROCEDURE carrega_PACS :

  DEFINE INPUT PARAM par_dtanoage AS INTEGER.

  /* Carrega os PACS que ainda não participam da agenda do ano escolhido */
    
  /* Instancia a BO para executar as procedures */
  RUN dbo/b1wpgd0021a.p PERSISTENT SET h-b1wpgd0021a.
    
  /* Se BO foi instanciada */
  IF VALID-HANDLE(h-b1wpgd0021a) THEN
    DO:
      FOR EACH crapage WHERE crapage.cdcooper = INTEGER(ab_unmap.aux_cdcooper) NO-LOCK:

        /* Verifica se o PAC já está participando da agenda escolhida */
        FIND crapagp WHERE crapagp.idevento = INTEGER(ab_unmap.aux_idevento) 
                       AND crapagp.cdcooper = crapage.cdcooper              
                       AND crapagp.dtanoage = par_dtanoage                  
                       AND crapagp.cdagenci = crapage.cdagenci NO-LOCK NO-ERROR.

        IF NOT AVAILABLE crapagp THEN
          DO:
            IF (crapage.insitage = 1   OR   /* Ativo */
                crapage.insitage = 3)  AND  /* Temporariamente Indisponivel */
                crapage.flgdopgd = YES   THEN
              DO:
                /* Limpa a temp-table */
                EMPTY TEMP-TABLE cratagp.
              
                CREATE cratagp.
                ASSIGN cratagp.cdageagr = crapage.cdageagr
                       cratagp.cdagenci = crapage.cdagenci
                       cratagp.cdcooper = crapage.cdcooper
                       cratagp.dtanoage = par_dtanoage
                       cratagp.dtmvtolt = TODAY
                       cratagp.idevento = INTEGER(ab_unmap.aux_idevento)
                       cratagp.idstagen = 0.
              
                RUN inclui-registro IN h-b1wpgd0021a(INPUT TABLE cratagp, OUTPUT msg-erro, OUTPUT ab_unmap.aux_nrdrowid).
              END.
          END.
        ELSE
          DO:
                 
            /* Atualiza o pac agrupador e a data de movimento */

            /* Limpa a temp-table */
            EMPTY TEMP-TABLE cratagp.
                 
            CREATE cratagp.

            /* Se o pac estiver com  insitage <> 1 ele será excluido (1-pac ativo)*/
            IF (crapage.insitage = 1     OR   /* Ativo */
                crapage.insitage = 3)    AND  /* Temporariamente Indisponivel */
                crapage.flgdopgd = YES   THEN
              DO:
                BUFFER-COPY crapagp EXCEPT crapagp.cdageagr crapagp.dtmvtolt TO cratagp.
                ASSIGN cratagp.cdageagr = crapage.cdageagr
                       cratagp.dtmvtolt = TODAY.


                RUN altera-registro IN h-b1wpgd0021a(INPUT TABLE cratagp, OUTPUT msg-erro).
              END.
            ELSE
              DO:
                BUFFER-COPY crapagp TO cratagp.
                RUN exclui-registro IN h-b1wpgd0021a(INPUT TABLE cratagp, OUTPUT msg-erro).
             END.
          END.
      END. /* FIM FOR EACH */ 

      IF INTEGER(ab_unmap.aux_idevento) = 2 THEN
        DO:
          FIND crapagp WHERE crapagp.idevento = INTEGER(ab_unmap.aux_idevento) 
                         AND crapagp.cdcooper = INTEGER(ab_unmap.aux_cdcooper)           
                         AND crapagp.dtanoage = par_dtanoage                  
                         AND crapagp.cdagenci = 0 NO-LOCK NO-ERROR.

          IF NOT AVAILABLE crapagp THEN
            DO:
              /* Limpa a temp-table */
              EMPTY TEMP-TABLE cratagp.
            
              CREATE cratagp.
              ASSIGN cratagp.cdageagr = 0
                     cratagp.cdagenci = 0
                     cratagp.cdcooper = INTEGER(ab_unmap.aux_cdcooper)
                     cratagp.dtanoage = par_dtanoage
                     cratagp.dtmvtolt = TODAY
                     cratagp.idevento = INTEGER(ab_unmap.aux_idevento)
                     cratagp.idstagen = 0.
            
              RUN inclui-registro IN h-b1wpgd0021a(INPUT TABLE cratagp, OUTPUT msg-erro, OUTPUT ab_unmap.aux_nrdrowid).
            END.
          ELSE
            DO:
              BUFFER-COPY crapagp EXCEPT crapagp.cdageagr crapagp.dtmvtolt TO cratagp.
              ASSIGN cratagp.cdageagr = 0
                     cratagp.dtmvtolt = TODAY.

              RUN altera-registro IN h-b1wpgd0021a(INPUT TABLE cratagp, OUTPUT msg-erro).
            END.
        END.
      
      /* "mata" a instâcia da BO */
      DELETE PROCEDURE h-b1wpgd0021a NO-ERROR.
  
    END. /* FIM IF VALID-HANDLE(h-b1wpgd0021a) */

END PROCEDURE.
&ANALYZE-RESUME