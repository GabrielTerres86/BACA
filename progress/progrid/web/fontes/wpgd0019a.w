/*
 * Programa wpgd0019a.w
 *
 * Alteracoes: 30/04/2009 - Utilizar cdcooper = 0 nas consultas (David).
 
			   05/06/2012 - Adaptação dos fontes para projeto Oracle. Alterado
						    busca na gnapses de CONTAINS para MATCHES (Guilherme Maba).
                            
               11/12/2013 - Incluir VALIDATE craphep. (Lucas R.)
*/
/*****************************************************************************/

&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
/* Connected Databases 
          banco            PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD aux_cdabrido AS CHARACTER 
       FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_cdlocali AS CHARACTER 
       FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_idexclui AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_motivo   AS CHARACTER 
       FIELD aux_nmevento AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nmfornec AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nmpagina AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nmresage AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nrmeseve AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_idinseve AS CHARACTER .


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
DEFINE VARIABLE ProgramaEmUso AS CHARACTER INITIAL ["wpgd0019"].
DEFINE VARIABLE NmeDoPrograma AS CHARACTER INITIAL ["wpgd0019a.w"].

DEF VAR aux_idstaeve LIKE crapadp.idstaeve NO-UNDO.
DEF VAR aux_cor AS CHAR NO-UNDO.
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
DEFINE VARIABLE h-b1wpgd0030          AS HANDLE                         NO-UNDO.
DEFINE VARIABLE h-b1wpgd0009          AS HANDLE                         NO-UNDO.

/*** Temp Tables ***/
DEFINE TEMP-TABLE cratadp             LIKE crapadp.
DEFINE TEMP-TABLE cratidp  NO-UNDO    LIKE crapidp.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE P:/web/fontes/wpgd0019a.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS crapadp.idstaeve crapadp.qtdiaeve ~
crapadp.cdabrido crapadp.cdlocali crapadp.cdcooper crapadp.cdagenci ~
crapadp.dsdiaeve crapadp.dshroeve crapadp.dtfineve crapadp.dtinieve 
&Scoped-define ENABLED-TABLES ab_unmap crapadp
&Scoped-define FIRST-ENABLED-TABLE ab_unmap
&Scoped-define SECOND-ENABLED-TABLE crapadp
&Scoped-Define ENABLED-OBJECTS ab_unmap.aux_motivo ab_unmap.aux_nmfornec ~
ab_unmap.aux_cdabrido ab_unmap.aux_cdlocali ab_unmap.aux_nmresage ~
ab_unmap.aux_cddopcao ab_unmap.aux_dsendurl ab_unmap.aux_dsretorn ~
ab_unmap.aux_idevento ab_unmap.aux_idexclui ab_unmap.aux_lspermis ~
ab_unmap.aux_nmevento ab_unmap.aux_nmpagina ab_unmap.aux_nrdrowid ~
ab_unmap.aux_nrmeseve ab_unmap.aux_stdopcao ab_unmap.aux_idinseve
&Scoped-Define DISPLAYED-FIELDS crapadp.idstaeve crapadp.qtdiaeve ~
crapadp.cdabrido crapadp.cdlocali crapadp.cdcooper crapadp.cdagenci ~
crapadp.dsdiaeve crapadp.dshroeve crapadp.dtfineve crapadp.dtinieve 
&Scoped-define DISPLAYED-TABLES ab_unmap crapadp
&Scoped-define FIRST-DISPLAYED-TABLE ab_unmap
&Scoped-define SECOND-DISPLAYED-TABLE crapadp
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.aux_motivo ab_unmap.aux_nmfornec ~
ab_unmap.aux_cdabrido ab_unmap.aux_cdlocali ab_unmap.aux_nmresage ~
ab_unmap.aux_cddopcao ab_unmap.aux_dsendurl ab_unmap.aux_dsretorn ~
ab_unmap.aux_idevento ab_unmap.aux_idexclui ab_unmap.aux_lspermis ~
ab_unmap.aux_nmevento ab_unmap.aux_nmpagina ab_unmap.aux_nrdrowid ~
ab_unmap.aux_nrmeseve ab_unmap.aux_stdopcao ab_unmap.aux_idinseve

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     ab_unmap.aux_motivo AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS EDITOR NO-WORD-WRAP
          SIZE 20 BY 4
     crapadp.idstaeve AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "->,>>>,>>9"
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapadp.qtdiaeve AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nmfornec AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapadp.cdabrido AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "zzz,zz9"
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapadp.cdlocali AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "zzz,zz9"
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cdabrido AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.aux_cdlocali AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     crapadp.cdcooper AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "zz,zz9"
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nmresage AT ROW 1 COL 1 HELP
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
     ab_unmap.aux_idexclui AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_lspermis AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nmevento AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nmpagina AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nrdrowid AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nrmeseve AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_stdopcao AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapadp.cdagenci AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapadp.dsdiaeve AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapadp.dshroeve AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapadp.dtfineve AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 71.4 BY 24.71.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Web-Frame
     crapadp.dtinieve AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_idinseve AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 71.4 BY 24.71.


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
          FIELD aux_cdabrido AS CHARACTER 
          FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_cdlocali AS CHARACTER 
          FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_idexclui AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_motivo AS CHARACTER 
          FIELD aux_nmevento AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nmfornec AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nmpagina AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nmresage AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nrmeseve AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
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
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_cdabrido IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN ab_unmap.aux_cddopcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_cdlocali IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
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
/* SETTINGS FOR editor ab_unmap.aux_motivo IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nmevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nmfornec IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nmpagina IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nmresage IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nrdrowid IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nrmeseve IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_stdopcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN crapadp.cdabrido IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN crapadp.cdagenci IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN crapadp.cdcooper IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN crapadp.cdlocali IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN crapadp.dsdiaeve IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN crapadp.dshroeve IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN crapadp.dtfineve IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN crapadp.dtinieve IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN crapadp.idstaeve IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN crapadp.qtdiaeve IN FRAME Web-Frame
   ALIGN-L                                                              */
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE carregaDescricao w-html 
PROCEDURE carregaDescricao :
DEF VAR aux_meses AS CHAR EXTENT 12 INIT ["JANEIRO","FEVEREIRO","MARÇO","ABRIL","MAIO","JUNHO","JULHO","AGOSTO","SETEMBRO","OUTUBRO","NOVEMBRO","DEZEMBRO"].
    FIND FIRST crapage WHERE 
           crapage.cdcooper = {&SECOND-ENABLED-TABLE}.cdcooper AND 
           crapage.cdagenci = {&SECOND-ENABLED-TABLE}.cdagenci  NO-LOCK NO-ERROR.
      IF AVAIL crapage THEN
         ab_unmap.aux_nmresage =  crapage.nmresage.
    ab_unmap.aux_nrmeseve =  aux_meses[{&SECOND-ENABLED-TABLE}.nrmeseve].
    FIND FIRST crapedp WHERE 
       crapedp.idevento = {&SECOND-ENABLED-TABLE}.idevento AND 
       crapedp.cdcooper = {&SECOND-ENABLED-TABLE}.cdcooper  AND 
       crapedp.dtanoage = {&SECOND-ENABLED-TABLE}.dtanoage  AND 
       crapedp.cdevento = {&SECOND-ENABLED-TABLE}.cdevento   NO-LOCK NO-ERROR.
    IF AVAIL crapedp THEN
        ab_unmap.aux_nmevento = crapedp.nmevento.

    /* *** Localiza fornecedor *** */
    FIND FIRST crapcdp WHERE
         crapcdp.idevento = {&SECOND-ENABLED-TABLE}.idevento AND   
         crapcdp.cdcooper = {&SECOND-ENABLED-TABLE}.cdcooper AND  
         crapcdp.cdagenci = {&SECOND-ENABLED-TABLE}.cdagenci AND 
         crapcdp.dtanoage = {&SECOND-ENABLED-TABLE}.dtanoage AND  
         crapcdp.tpcuseve = 1 AND 
         crapcdp.cdevento = {&SECOND-ENABLED-TABLE}.cdevento AND
         crapcdp.cdcuseve = 1 NO-LOCK NO-ERROR.
    /* *** Localiza proposta do evento *** */
    FIND Gnappdp WHERE Gnappdp.IdEvento = Crapcdp.idEvento AND
                       Gnappdp.CdCooper = 0                AND
                       Gnappdp.NrCpfCgc = Crapcdp.NrCpfCgc AND
                       Gnappdp.NrPropos = Crapcdp.NrPropos NO-LOCK NO-ERROR.
    FIND gnapfdp WHERE gnapfdp.idevento = Gnappdp.IdEvento AND
                       Gnapfdp.cdcooper = 0                AND
                       Gnapfdp.nrcpfcgc = Gnappdp.NrCpfCgc NO-LOCK NO-ERROR.
    IF AVAIL gnapfdp THEN
        ab_unmap.aux_nmfornec = gnapfdp.nmfornec.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaLista w-html 
PROCEDURE CriaLista :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEF VAR aux_crapldp AS CHAR NO-UNDO.
DEF VAR aux_crapaep AS CHAR NO-UNDO.

/* Cria as Listas que são mostradas na tela */
    
/* Lista de Abridores */
aux_crapaep = ",0,".
FOR EACH crapaep WHERE 
    crapaep.cdcooper = {&SECOND-ENABLED-TABLE}.cdcooper AND 
    crapaep.flgativo = YES NO-LOCK :
    ASSIGN aux_crapaep = aux_crapaep + crapaep.nmabreve + "," + STRING(crapaep.nrseqdig) + ",".
END.
aux_crapaep = SUBSTRING(aux_crapaep, 1, LENGTH(aux_crapaep) - 1).
  /* Preenche as listas com os elementos encontrados */
ASSIGN ab_unmap.aux_cdabrido:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = aux_crapaep.
/* Lista de Locais */
aux_crapldp = ",0,".
FOR EACH crapldp WHERE 
    crapldp.cdcooper = {&SECOND-ENABLED-TABLE}.cdcooper AND
    crapldp.cdagenci = {&SECOND-ENABLED-TABLE}.cdagenci NO-LOCK :
    ASSIGN aux_crapldp = aux_crapldp + crapldp.dslocali + "," + STRING(crapldp.nrseqdig) + ",".
END.
aux_crapldp = SUBSTRING(aux_crapldp, 1, LENGTH(aux_crapldp) - 1).            
/* Preenche as listas com os elementos encontrados */
ASSIGN ab_unmap.aux_cdlocali:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = aux_crapldp.
       

IF REQUEST_METHOD = "POST" THEN DO: /* manter o valor informado (nao sobrepor com o valor do banco)*/
   ab_unmap.aux_cdabrido:SCREEN-VALUE IN FRAME {&FRAME-NAME} = GET-VALUE("aux_cdabrido"). 
   ab_unmap.aux_cdlocali:SCREEN-VALUE IN FRAME {&FRAME-NAME} = GET-VALUE("aux_cdlocali"). 
END.                                 

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListahistoricos w-html 
PROCEDURE CriaListahistoricos :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEF VAR vetorhistorico AS CHAR NO-UNDO.
ASSIGN vetorhistorico = "".

FOR EACH craphep WHERE craphep.cdcooper = 0                AND
                       craphep.cdagenci = crapadp.nrseqdig NO-LOCK:                        
    IF   vetorhistorico = ""   THEN
         vetorhistorico = "~{" + "dthist:" + "'" + STRING(craphep.dtmvtolt) + "',dshist:" + "'" + craphep.dshiseve + "'~}".
    ELSE
         vetorhistorico = vetorhistorico + "," + 
                       "~{" + "dthist:" + "'" + STRING(craphep.dtmvtolt) + "',dshist:" + "'" + craphep.dshiseve + "'~}".        
END.                                    

/* Cria o array */
RUN RodaJavaScript("var mhistorico=new Array();mhistorico=["  + vetorhistorico + "]").


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
    ("aux_cdabrido":U,"ab_unmap.aux_cdabrido":U,ab_unmap.aux_cdabrido:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cddopcao":U,"ab_unmap.aux_cddopcao":U,ab_unmap.aux_cddopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdlocali":U,"ab_unmap.aux_cdlocali":U,ab_unmap.aux_cdlocali:HANDLE IN FRAME {&FRAME-NAME}).
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
    ("aux_motivo":U,"ab_unmap.aux_motivo":U,ab_unmap.aux_motivo:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nmevento":U,"ab_unmap.aux_nmevento":U,ab_unmap.aux_nmevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nmfornec":U,"ab_unmap.aux_nmfornec":U,ab_unmap.aux_nmfornec:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nmpagina":U,"ab_unmap.aux_nmpagina":U,ab_unmap.aux_nmpagina:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nmresage":U,"ab_unmap.aux_nmresage":U,ab_unmap.aux_nmresage:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrdrowid":U,"ab_unmap.aux_nrdrowid":U,ab_unmap.aux_nrdrowid:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrmeseve":U,"ab_unmap.aux_nrmeseve":U,ab_unmap.aux_nrmeseve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_stdopcao":U,"ab_unmap.aux_stdopcao":U,ab_unmap.aux_stdopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("cdabrido":U,"crapadp.cdabrido":U,crapadp.cdabrido:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("cdagenci":U,"crapadp.cdagenci":U,crapadp.cdagenci:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("cdcooper":U,"crapadp.cdcooper":U,crapadp.cdcooper:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("cdlocali":U,"crapadp.cdlocali":U,crapadp.cdlocali:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dsdiaeve":U,"crapadp.dsdiaeve":U,crapadp.dsdiaeve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dshroeve":U,"crapadp.dshroeve":U,crapadp.dshroeve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dtfineve":U,"crapadp.dtfineve":U,crapadp.dtfineve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dtinieve":U,"crapadp.dtinieve":U,crapadp.dtinieve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("idstaeve":U,"crapadp.idstaeve":U,crapadp.idstaeve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("qtdiaeve":U,"crapadp.qtdiaeve":U,crapadp.qtdiaeve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idinseve":U,"ab_unmap.aux_idinseve":U,ab_unmap.aux_idinseve:HANDLE IN FRAME {&FRAME-NAME}).
END PROCEDURE.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-assign-record w-html 
PROCEDURE local-assign-record :
DEFINE INPUT PARAMETER opcao AS CHARACTER.

/* Instancia a BO para executar as procedures */
RUN dbo/b1wpgd0030.p PERSISTENT SET h-b1wpgd0030.

/* Se BO foi instanciada */
IF VALID-HANDLE(h-b1wpgd0030) THEN
   DO:
      DO WITH FRAME {&FRAME-NAME}:
         IF opcao = "inclusao" THEN
            DO: 
                CREATE cratadp.
               /* ASSIGN cratadp.campo = INPUT crapxxx.campo. */

                RUN inclui-registro IN h-b1wpgd0030(INPUT TABLE cratadp, OUTPUT msg-erro, OUTPUT ab_unmap.aux_nrdrowid).
            END.
         ELSE  /* alteracao */
            DO:
                /* cria a temp-table e joga o novo valor digitado para o campo */
                CREATE cratadp.
                BUFFER-COPY crapadp TO cratadp.
                 
                 ASSIGN
                    aux_idstaeve      = cratadp.idstaeve  
                    cratadp.cdlocali  = INTEGER(GET-VALUE("aux_cdlocali"))
                    cratadp.cdabrido  = INTEGER(GET-VALUE("aux_cdabrido"))
                   /* cratadp.nrmeseve  = INPUT crapadp.nrmeseve       */
                    cratadp.dtinieve  = INPUT crapadp.dtinieve        
                    cratadp.dtfineve  = INPUT crapadp.dtfineve         
                   /* cratadp.dsevento  = INPUT crapadp.dsevento          */
                    cratadp.dshroeve  = INPUT crapadp.dshroeve            
                    cratadp.dsdiaeve  = INPUT crapadp.dsdiaeve
                    cratadp.qtdiaeve  = INPUT crapadp.qtdiaeve
                    cratadp.idstaeve  = INPUT crapadp.idstaeve .
                 CASE cratadp.idstaeve :
                       WHEN 0  THEN aux_cor = '#FFFF99'.
                       WHEN 1  THEN aux_cor = '#FFFF99'.
                       WHEN 2  THEN aux_cor = 'tomato'.
                       WHEN 3  THEN aux_cor = '#FFFF99'. 
                       WHEN 4  THEN aux_cor = '#FFFF99'.
                       WHEN 5  THEN aux_cor = '#FFFF99'.
                       WHEN 6  THEN aux_cor = '#FFFF99'.
                   END CASE.
                 IF cratadp.idstaeve <> 2 THEN /* verificando se evento está com os dados completos e não cancelado */
                    IF cratadp.cdlocali <> 0  AND 
                       cratadp.dtinieve <> ?  AND
                       cratadp.dtfineve <> ?  AND   
                       cratadp.dshroeve <> "" THEN 
                       ASSIGN aux_cor = '#66CC66'.
                       
                RUN altera-registro IN h-b1wpgd0030(INPUT TABLE cratadp, OUTPUT msg-erro).
                IF msg-erro = "" THEN DO:
                   IF INPUT crapadp.idstaeve <> aux_idstaeve THEN DO: /* mudança no status do evento  */
                      IF INPUT crapadp.idstaeve = 2 THEN DO: /* cancelamento */
                         CREATE craphep.
                         ASSIGN craphep.nrseqdig  = NEXT-VALUE(nrseqhep)
                                craphep.cdagenci  = cratadp.nrseqdig
                                craphep.dshiseve  = "Evento cancelado em " + STRING(TODAY,"99/99/9999") + " pelo usuário " + gnapses.cdoperad + " Motivo : " + INPUT ab_unmap.aux_idexclui
                                craphep.dtmvtolt  = TODAY. 
                          
                      END.
                      IF cratadp.idstaeve <> 2 THEN DO: /* reativando */
                         CREATE craphep.
                         ASSIGN craphep.nrseqdig  = NEXT-VALUE(nrseqhep)
                                craphep.cdagenci  = cratadp.nrseqdig
                                craphep.dshiseve  = "Evento reativado em " + STRING(TODAY,"99/99/9999") + " pelo usuário " + gnapses.cdoperad + " Motivo : " + INPUT ab_unmap.aux_idexclui
                                craphep.dtmvtolt  = TODAY. 
                      END.

                      VALIDATE craphep.

                   END.
                END.
                
            END.    
      END. /* DO WITH FRAME {&FRAME-NAME} */
   
      /* "mata" a instância da BO */
      DELETE PROCEDURE h-b1wpgd0030 NO-ERROR.
   
   END. /* IF VALID-HANDLE(h-b1wpgd0030) */
      
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-delete-record w-html 
PROCEDURE local-delete-record :
/* Instancia a BO para executar as procedures */
RUN dbo/b1wpgd0030.p PERSISTENT SET h-b1wpgd0030.
RUN dbo/b1wpgd0009.p PERSISTENT SET h-b1wpgd0009.

/* Se BO foi instanciada */
IF VALID-HANDLE(h-b1wpgd0030) AND
   VALID-HANDLE(h-b1wpgd0009) THEN
   DO:
      CREATE cratadp.
      BUFFER-COPY crapadp TO cratadp.

      /* Exclui os pré-inscritos */
      FOR EACH crapidp WHERE crapidp.idevento = cratadp.idevento   AND
                             crapidp.cdcooper = cratadp.cdcooper   AND
                             crapidp.dtanoage = cratadp.dtanoage   AND
                             crapidp.cdageins = cratadp.cdagenci   AND
                             crapidp.cdevento = cratadp.cdevento   AND 
                             crapidp.nrseqeve = cratadp.nrseqdig   NO-LOCK:

          EMPTY TEMP-TABLE cratidp.
          CREATE cratidp.
          BUFFER-COPY crapidp TO cratidp.

          RUN exclui-registro IN h-b1wpgd0009(INPUT TABLE cratidp, OUTPUT msg-erro).
      END.
      /* Fim dos pré-inscritos */

      RUN RodaJavaScript("window.opener.mudaCorDiv('" + STRING(ROWID({&SECOND-ENABLED-TABLE})) + "','#000000');").       
      
      RUN exclui-registro IN h-b1wpgd0030(INPUT TABLE cratadp, OUTPUT msg-erro).

      /* "mata" a instância da BO */
      DELETE PROCEDURE h-b1wpgd0030 NO-ERROR.
      DELETE PROCEDURE h-b1wpgd0009 NO-ERROR.
   END.

RUN RodaJavaScript("window.close();").

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
       ab_unmap.aux_cdlocali    = GET-VALUE("aux_cdlocali")
       ab_unmap.aux_cdabrido    = GET-VALUE("aux_cdabrido")
       ab_unmap.aux_stdopcao    = GET-VALUE("aux_stdopcao").
RUN outputHeader.
/* método POST */
IF REQUEST_METHOD = "POST":U THEN 
   DO:
      RUN inputFields.

      /* Instancia a BO para executar as procedures */
      RUN dbo/b1wpgd0030.p PERSISTENT SET h-b1wpgd0030.

      /* Se BO foi instanciada */
      IF VALID-HANDLE(h-b1wpgd0030) THEN
         DO:
            RUN posiciona-registro IN h-b1wpgd0030(INPUT TO-ROWID(ab_unmap.aux_nrdrowid), OUTPUT msg-erro).
            DELETE PROCEDURE h-b1wpgd0030 NO-ERROR.
         END.

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
       RUN CriaLista.   
       RUN CriaListaHistoricos.
      IF msg-erro-aux = 10 OR (opcao <> "sa" AND opcao <> "ex" AND opcao <> "in") THEN DO:
          RUN carregaDescricao.
          RUN displayFields.
      END.
 
      RUN enableFields.
      RUN outputFields.
      RUN RodaJavaScript("window.opener.mudaCorDiv('" + STRING(ROWID({&SECOND-ENABLED-TABLE})) + "','" + aux_cor + "');"). 

      CASE msg-erro-aux:
           WHEN 1 THEN
                DO:
                    ASSIGN v-qtdeerro      = 1
                           v-descricaoerro = 'Registro esta em uso por outro usuário. Solicitação não pode ser executada. Espere alguns instantes e tente novamente.'.

                    RUN RodaJavaScript(' alert("' + v-descricaoerro + '"); ').
                END.

           WHEN 2 THEN
                RUN RodaJavaScript(" alert('Registro foi excluído. Solicitação não pode ser executada.')").
      
           WHEN 3 THEN
                DO:
                    ASSIGN v-qtdeerro      = 1
                           v-descricaoerro = msg-erro.

                    RUN RodaJavaScript(' alert("' + v-descricaoerro + '"); ').
                END.

           WHEN 4 THEN
                DO:
                    ASSIGN v-qtdeerro      = 1
                           v-descricaoerro = m-erros.

                    RUN RodaJavaScript(' alert("' + v-descricaoerro + '"); ').
                END.

           WHEN 10 THEN
                RUN RodaJavaScript('alert("Atualizacao executada com sucesso.")'). 
         
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
                           FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(GET-VALUE("LinkRowid")) NO-ERROR.
                           
                           IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                              DO:
                                  IF INT(GET-VALUE("mes")) <> {&SECOND-ENABLED-TABLE}.nrmeseve THEN DO:
                                      ASSIGN {&SECOND-ENABLED-TABLE}.nrmeseve = INT(GET-VALUE("mes"))
                                             {&SECOND-ENABLED-TABLE}.cdabrido = 0
                                             {&SECOND-ENABLED-TABLE}.cdlocali = 0
                                             {&SECOND-ENABLED-TABLE}.dtinieve = ?
                                             {&SECOND-ENABLED-TABLE}.dtfineve = ?
                                             {&SECOND-ENABLED-TABLE}.dshroeve = ""
                                             {&SECOND-ENABLED-TABLE}.dsdiaeve = ""
                                             {&SECOND-ENABLED-TABLE}.qtdiaeve = 0.
                                  END.
                                  ASSIGN ab_unmap.aux_nrdrowid = STRING(ROWID({&SECOND-ENABLED-TABLE}))
                                         ab_unmap.aux_idevento = STRING({&SECOND-ENABLED-TABLE}.idevento)
                                         ab_unmap.aux_cdabrido = STRING({&SECOND-ENABLED-TABLE}.cdabrido)
                                         ab_unmap.aux_cdlocali = STRING({&SECOND-ENABLED-TABLE}.cdlocali).

                                  /* Verifica se existe algum inscrito no evento com status "pendente" ou "confirmado" */
                                  IF   CAN-FIND(FIRST crapidp WHERE crapidp.idevento = {&SECOND-ENABLED-TABLE}.idevento   AND
                                                                    crapidp.cdcooper = {&SECOND-ENABLED-TABLE}.cdcooper   AND
                                                                    crapidp.dtanoage = {&SECOND-ENABLED-TABLE}.dtanoage   AND
                                                                    crapidp.cdageins = {&SECOND-ENABLED-TABLE}.cdagenci   AND
                                                                    crapidp.cdevento = {&SECOND-ENABLED-TABLE}.cdevento   AND
                                                                    crapidp.nrseqeve = {&SECOND-ENABLED-TABLE}.nrseqdig   AND
                                                                   (crapidp.idstains = 1 OR /*Pendente*/
                                                                    crapidp.idstains = 2)   /*Confirmado*/                NO-LOCK) THEN
                                       ab_unmap.aux_idinseve = "yes".
                                  ELSE
                                       ab_unmap.aux_idinseve = "no".

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
                    RUN CriaListaHistoricos.
                    RUN CriaLista.   
                    RUN carregaDescricao.
                    RUN displayFields.
                    RUN enableFields.
                    RUN outputFields.
                    RUN RodaJavaScript('CarregaPrincipal()').
                    
                    IF GET-VALUE("LinkRowid") = "" THEN
                       DO:
                           RUN RodaJavaScript('LimparCampos();').
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

