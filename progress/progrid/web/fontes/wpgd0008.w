/*...............................................................................

Alterações: 10/12/2008 - Melhoria de performance para a tabela gnapses (Evandro).

            30/04/2009 - Utilizar cdcooper = 0 nas consultas (David).
			
            05/06/2012 - Adaptação dos fontes para projeto Oracle. Alterado
                         busca na gnapses de CONTAINS para MATCHES (Guilherme Maba).
            
            29/08/2013 - Nova forma de chamar as agências, de PAC agora 
                         a escrita será PA (André Euzébio - Supero).    
                            
            29/06/2015 - Melhorias OQS (Gabriel/RKAM). 
            
            11/08/2015 - Inclusao do campo qtdiaeve (Vanessa)
            
            05/10/2015 - Alteração para o campo qtmintur permitir numero com
                         mais de três digitos e ordenação dos temas (Vanessa)
						 
            09/10/2015 - Alteração da tela de Cadastro de Eventos (Eventos/Recursos)
                         (Carlos Rafael Tanholi)
                         
            30/12/2015 - Apresentação da nova aba de cadastro de recursos do PA por 
                         Evento. Projeto 229 - Melhorias OQS (Lombardi)
                         
            25/05/2016 - Correcao no carregamento de PA's na aba "Recurso por PA"
                         para listagem de apenas PA's habilitados. 
                         Correcao ortografica no campo "Restricao Publicacao", e
                         em manter os campos "limpos" ao entrar na tela.
                         (Carlos Rafael Tanholi)             
           
            09/06/2016 - Ajustado para exibir na lista de recursos apenas os 
                         recursos que possuem tipo definido(gnaprdp.cdtiprec <> 0).
                         PRJ229 - Melhorias OQS (Odirlei-AMcom)
						 
            27/06/2018 - Ajustes para RF05/RF06, inclusao de novas abas, 
                         PRJ229 - Melhorias OQS (Jean Michel).
			
            02/08/2016 - Inclusao insitage 3-Temporariamente Indisponivel.
                         (Jaison/Anderson)
			
			20/10/2016 - Inclusao do campo idvalloc, Prj. 229 (Jean Michel). 

            14/02/2017 - Inclusao de novos campos, Prj. 322 (Jean Michel)
                         
...............................................................................*/

{ sistema/generico/includes/var_log_progrid.i }

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
       FIELD aux_cdeixtem AS CHARACTER 
	     FIELD aux_dseixtem AS CHARACTER 	   
       FIELD aux_nrseqtem AS CHARACTER
       FIELD aux_nrseqpri AS CHARACTER
       FIELD aux_dsjustif AS CHARACTER
       FIELD tel_cdoperad AS CHARACTER
       FIELD aux_cdoperad AS CHARACTER
       FIELD aux_cdevento AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_cdorigem AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_idrecpor AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_cdtiprec AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nmpagina AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nrdrowid_rp AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nrseqdig AS CHARACTER FORMAT "X(256)":U 
       FIELD nrseqdig     AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_abaopcao AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_tpevento AS CHARACTER 
       FIELD aux_tppartic AS CHARACTER
       FIELD aux_dtanoage AS CHARACTER
       FIELD aux_qtrecage AS CHARACTER
       FIELD aux_qtgrppar AS CHARACTER
       FIELD aux_idrespub AS CHARACTER
       FIELD aux_idvalloc AS CHARACTER
       FIELD aux_nrseqpdp AS CHARACTER
       FIELD aux_nrseqpap AS CHARACTER
       FIELD aux_cdcopope AS CHARACTER FORMAT "X(256)":U 
       FIELD cdagenci AS CHARACTER FORMAT "X(256)":U
       FIELD aux_dsurlphp AS CHARACTER FORMAT "X(256)":U
       FIELD aux_nrseqpgm AS CHARACTER.

DEFINE TEMP-TABLE tt-evento
       FIELD dsevento AS CHARACTER 
       FIELD cdevento AS INTEGER. 


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
DEFINE VARIABLE ProgramaEmUso         AS CHARACTER INITIAL ["wpgd0008"].
DEFINE VARIABLE NmeDoPrograma         AS CHARACTER INITIAL ["wpgd0008.w"].

DEFINE VARIABLE opcao                 AS CHARACTER.
DEFINE VARIABLE msg-erro              AS CHARACTER.
DEFINE VARIABLE msg-erro-aux          AS INTEGER.
DEFINE VARIABLE aux_nrdrowid-auxiliar AS CHARACTER.
DEFINE VARIABLE pesquisa              AS CHARACTER.     
DEFINE VARIABLE FlagPermissoes        AS CHARACTER.
DEFINE VARIABLE IdentificacaoDaSessao AS CHARACTER FORMAT "x(47)".
DEFINE VARIABLE vauxsenha             AS CHARACTER FORMAT "X(16)".

DEFINE VARIABLE vetorpac              AS CHAR                           NO-UNDO.
DEFINE VARIABLE aux_crapcop           AS CHAR                           NO-UNDO.

DEFINE VARIABLE i                     AS INTEGER                        NO-UNDO.
DEFINE VARIABLE m-erros               AS CHARACTER                      NO-UNDO.
DEFINE VARIABLE v-qtdeerro            AS INTEGER                        NO-UNDO.
DEFINE VARIABLE v-descricaoerro       AS CHARACTER                      NO-UNDO.
DEFINE VARIABLE v-identificacao       AS CHARACTER                      NO-UNDO.

/*** Declaração de BOs ***/
DEFINE VARIABLE h-b1wpgd0008          AS HANDLE                         NO-UNDO.
DEFINE VARIABLE h-b1wpgd0008a         AS HANDLE                         NO-UNDO.

/*** Temp Tables ***/
DEFINE TEMP-TABLE cratedp NO-UNDO     LIKE crapedp.
DEFINE TEMP-TABLE cratrep NO-UNDO     LIKE craprep.
DEFINE TEMP-TABLE cratrpe NO-UNDO     LIKE craprpe.

DEFINE VARIABLE aux_tpevento          AS CHARACTER                      NO-UNDO.
DEFINE VARIABLE aux_tppartic          AS CHARACTER                      NO-UNDO.

DEF BUFFER crabedp FOR crapedp.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE fontes/wpgd0008.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS crapedp.flgativo crapedp.flgcerti ~
crapedp.flgcompr crapedp.flgrestr crapedp.flgsorte crapedp.flgtdpac ~
crapedp.nmevento crapedp.nridamin crapedp.prfreque crapedp.qtmaxtur ~
crapedp.qtmintur crapedp.qtparcta crapepd.nrseqtem ~
crapedp.qtdiaeve crapedp.idperint
&Scoped-define ENABLED-TABLES ab_unmap crapedp
&Scoped-define FIRST-ENABLED-TABLE ab_unmap
&Scoped-define SECOND-ENABLED-TABLE crapedp
&Scoped-define THIRD-ENABLED-TABLE craprpe
&Scoped-Define ENABLED-OBJECTS ab_unmap.aux_cdagenci ab_unmap.aux_cdcooper ~
ab_unmap.aux_dtanoage ab_unmap.aux_cdorigem ab_unmap.aux_nmpagina ~
ab_unmap.aux_cdeixtem ab_unmap.aux_dseixtem ab_unmap.aux_nrseqtem ~
ab_unmap.aux_dsjustif ab_unmap.tel_cdoperad ab_unmap.aux_nrseqpri ~
ab_unmap.aux_tpevento ab_unmap.aux_tppartic ab_unmap.aux_cdevento ~
ab_unmap.aux_idevento ab_unmap.aux_cddopcao ab_unmap.aux_dsendurl ~
ab_unmap.aux_dsretorn ab_unmap.aux_lspermis ab_unmap.aux_nrdrowid ~
ab_unmap.aux_stdopcao ab_unmap.aux_nrseqdig ab_unmap.cdagenci ~
ab_unmap.nrseqdig ab_unmap.aux_qtrecage ab_unmap.aux_qtgrppar ~
ab_unmap.aux_idrespub ab_unmap.aux_cdcopope ab_unmap.aux_abaopcao ~
ab_unmap.aux_cdoperad ab_unmap.aux_nrdrowid_rp ab_unmap.aux_idrecpor ~
ab_unmap.aux_cdtiprec ab_unmap.aux_dsurlphp ab_unmap.aux_nrseqpdp ~
ab_unmap.aux_nrseqpap ab_unmap.aux_idvalloc ab_unmap.aux_nrseqpgm
&Scoped-Define DISPLAYED-FIELDS crapedp.flgativo crapedp.flgcerti ~
crapedp.flgcompr crapedp.flgrestr crapedp.flgsorte crapedp.flgtdpac ~
crapedp.nmevento crapedp.nridamin crapedp.prfreque crapedp.qtmaxtur ~
crapedp.qtmintur crapedp.qtparcta crapedp.nrseqtem crapedp.qtdiaeve ~
crapedp.idperint
&Scoped-define DISPLAYED-TABLES ab_unmap crapedp
&Scoped-define FIRST-DISPLAYED-TABLE ab_unmap
&Scoped-define SECOND-DISPLAYED-TABLE crapedp
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.aux_cdagenci ab_unmap.aux_cdcooper ~
ab_unmap.aux_dtanoage ab_unmap.aux_cdorigem ab_unmap.aux_nmpagina ~
ab_unmap.aux_cdeixtem ab_unmap.aux_dseixtem ab_unmap.aux_nrseqtem ~
ab_unmap.aux_dsjustif ab_unmap.tel_cdoperad ab_unmap.aux_nrseqpri ~
ab_unmap.aux_tpevento ab_unmap.aux_tppartic ab_unmap.aux_cdevento ~
ab_unmap.aux_idevento ab_unmap.aux_cddopcao ab_unmap.aux_dsendurl ~
ab_unmap.aux_dsretorn ab_unmap.aux_lspermis ab_unmap.aux_nrdrowid ~
ab_unmap.aux_stdopcao ab_unmap.aux_nrseqdig  ab_unmap.cdagenci ~
ab_unmap.nrseqdig ab_unmap.aux_qtrecage ab_unmap.aux_qtgrppar ~
ab_unmap.aux_idrespub ab_unmap.aux_cdcopope ab_unmap.aux_abaopcao ~
ab_unmap.aux_cdoperad ab_unmap.aux_nrdrowid_rp ab_unmap.aux_idrecpor ~
ab_unmap.aux_cdtiprec ab_unmap.aux_dsurlphp ab_unmap.aux_nrseqpdp ~
ab_unmap.aux_nrseqpap ab_unmap.aux_idvalloc ab_unmap.aux_nrseqpgm
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
     ab_unmap.nrseqdig AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.aux_cdorigem AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_dtanoage AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nmpagina AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cdeixtem AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS FILL-IN
          SIZE 20 BY 1
    ab_unmap.aux_nrseqpgm AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.aux_dseixtem AT ROW 1 COL 1 HELP
          "" NO-LABEL  FORMAT "X(256)":U
          VIEW-AS FILL-IN
          SIZE 20 BY 1		  
     ab_unmap.aux_nrseqtem AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.aux_nrseqpri AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.aux_dsjustif AT ROW 1 COL 1 NO-LABEL
          VIEW-AS EDITOR NO-WORD-WRAP
          SIZE 20 BY 1
     ab_unmap.tel_cdoperad AT ROW 1 COL 1 HELP 
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cdoperad AT ROW 1 COL 1 HELP 
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_tpevento AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.aux_tppartic AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.aux_cdevento AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_idevento AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_idrecpor AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cdtiprec AT ROW 1 COL 1 HELP
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
     ab_unmap.aux_lspermis AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nrdrowid AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nrdrowid_rp AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_idrespub AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.aux_idvalloc AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.aux_stdopcao AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_abaopcao AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nrseqdig AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_qtrecage AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_qtgrppar AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapedp.flgativo AT ROW 1 COL 1
          LABEL "Ativo"
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
     crapedp.flgcerti AT ROW 1 COL 1
          LABEL "Certifica"
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
     crapedp.flgcompr AT ROW 1 COL 1
          LABEL "Termo de Compromisso"
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
     crapedp.flgrestr AT ROW 1 COL 1
          LABEL "Pre-inscricao associados PA"
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
     crapedp.flgsorte AT ROW 1 COL 1
          LABEL "Existencia de Sorteio"
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
     crapedp.flgtdpac AT ROW 1 COL 1
          LABEL "Obrigatorio a todos os PAs"
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
     crapedp.idperint AT ROW 1 COL 1 NO-LABEL
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1 
     crapedp.nmevento AT ROW 1 COL 1 NO-LABEL
          VIEW-AS EDITOR NO-WORD-WRAP
          SIZE 20 BY 1
     crapedp.nridamin AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapedp.prfreque AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapedp.qtmaxtur AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapedp.qtmintur AT ROW 1 COL 1 NO-LABEL FORMAT "zzzzz9":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapedp.qtparcta AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapedp.qtdiaeve AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cdcopope AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.cdagenci AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1     
     ab_unmap.aux_dsurlphp AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nrseqpdp AT ROW 1 COL 1 HELP
          "" NO-LABEL VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nrseqpap AT ROW 1 COL 1 HELP
          "" NO-LABEL VIEW-AS FILL-IN 
          SIZE 20 BY 1     
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 54.8 BY 19.76.


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
          FIELD aux_dtanoage AS CHARACTER 
          FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_cdeixtem AS CHARACTER 
          FIELD aux_dseixtem AS CHARACTER
          FIELD aux_nrseqtem AS CHARACTER
          FIELD aux_nrseqpri AS CHARACTER
          FIELD aux_cdevento AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_cdorigem AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_idrecpor AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_cdtiprec AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nmpagina AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nrdrowid_rp AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_qtgrppar AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_qtrecage AS CHARACTER FORMAT "X(256)":U           
          FIELD aux_nrseqdig AS CHARACTER FORMAT "X(256)":U 
          FIELD tel_cdoperad AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_cdoperad AS CHARACTER FORMAT "X(256)":U 
          FIELD nrseqdig AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U
          FIELD aux_abaopcao AS CHARACTER FORMAT "X(256)":U
          FIELD cdagenci AS CHARACTER FORMAT "X(256)":U
          FIELD aux_tpevento AS CHARACTER 
          FIELD aux_tppartic AS CHARACTER 
          FIELD aux_idrespub AS CHARACTER
          FIELD aux_idvalloc AS CHARACTER
          FIELD aux_cdcopope AS CHARACTER FORMAT "x(8)"
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW w-html ASSIGN
         HEIGHT             = 19.76
         WIDTH              = 54.8.
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
/* SETTINGS FOR FILL-IN ab_unmap.aux_cdeixtem IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dseixtem IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_cdagenci IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_cdcooper IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */  
/* SETTINGS FOR SELECTION-LIST ab_unmap.nrseqdig IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */  
/* SETTINGS FOR FILL-IN ab_unmap.dsjustif IN FRAME Web-Frame
    EXP-LABEL EXP-FORMAT EXP-HELP                                       */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dtanoage IN FRAME Web-Frame
    EXP-LABEL EXP-FORMAT EXP-HELP                                       */
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_nrseqpri IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN ab_unmap.aux_cdevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_cdorigem IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dsendurl IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dsretorn IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_idevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_idrecpor IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_cdtiprec IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lspermis IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nmpagina IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */   
/* SETTINGS FOR FILL-IN ab_unmap.aux_qtrecage IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_qtgrppar IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */   
/* SETTINGS FOR FILL-IN ab_unmap.aux_nrdrowid IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */   
/* SETTINGS FOR FILL-IN ab_unmap.aux_nrdrowid_rp IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.cdagenci IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */   
/* SETTINGS FOR FILL-IN ab_unmap.aux_stdopcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_abaopcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_tpevento IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_tppartic IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_nrseqpgm IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */     
/* SETTINGS FOR TOGGLE-BOX crapedp.flgativo IN FRAME Web-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX crapedp.flgcerti IN FRAME Web-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX crapedp.flgcompr IN FRAME Web-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX crapedp.flgrestr IN FRAME Web-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX crapedp.flgsorte IN FRAME Web-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_idrespub IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */ 
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_idvalloc IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */ 
/* SETTINGS FOR TOGGLE-BOX crapedp.flgtdpac IN FRAME Web-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN crapedp.nrseqtem IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN crapedp.nmevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN crapedp.nridamin IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN crapedp.prfreque IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN crapedp.qtmaxtur IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN crapedp.qtmintur IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN ab_unmap.aux_cdcopope IN FRAME Web-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN crapedp.qtparcta IN FRAME Web-Frame
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
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaPublicoAlvo w-html 
PROCEDURE CriaListaPublicoAlvo:

  RUN RodaJavaScript("var mpublico = new Array();").
  
  FOR EACH crappae NO-LOCK WHERE crappae.idevento = INTEGER(ab_unmap.aux_idevento)
                     AND crappae.cdcooper = 0
                     AND crappae.dtanoage = 0
                     AND crappae.cdevento = INTEGER(ab_unmap.aux_cdevento),
      EACH crappap NO-LOCK WHERE crappap.nrseqpap = crappae.nrseqpap BY crappap.dspubalv:

		RUN RodaJavaScript("mpublico.push(~{nrseqpap:'" + STRING(crappap.nrseqpap)
                                   + "',dspubalv:'" + crappap.dspubalv + "'~});").
    
       END.


END PROCEDURE.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaProdutoSugerido w-html 
PROCEDURE CriaListaProdutoSugerido:

  RUN RodaJavaScript("var mproduto = new Array();").
  
  FOR EACH crappde NO-LOCK WHERE crappde.idevento = INTEGER(ab_unmap.aux_idevento)
                     AND crappde.cdcooper = 0
                     AND crappde.dtanoage = 0
                     AND crappde.cdevento = INTEGER(ab_unmap.aux_cdevento),
      EACH crappdp NO-LOCK WHERE crappdp.nrseqpdp = crappde.nrseqpdp BY crappdp.dsprodut:

		RUN RodaJavaScript("mproduto.push(~{nrseqpdp:'" + STRING(crappdp.nrseqpdp)
                                  + "',dsprodut:'" + crappdp.dsprodut + "'~});").     
    
       END.

END PROCEDURE.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaLista w-html 
PROCEDURE CriaLista :

    /* Cria as Listas que são mostradas na tela */
    
    DEF VAR aux_nrseqtem AS CHAR NO-UNDO.
    DEF VAR aux_nrseqpri AS CHAR NO-UNDO.
    DEF VAR aux_idrespub AS CHAR NO-UNDO.
    DEF VAR aux_idvalloc AS CHAR NO-UNDO.
    DEF VAR aux_nrseqpgm AS CHAR NO-UNDO.
    DEF VAR i            AS INT  NO-UNDO.
    
    /* Para Assembléias, duas opções:
     - Faz fixo no programa as opções de assembléia, e tira da CRAPTAB;
     - Cria dois registros de CRAPTAB: um pra tipo de evento PROGRID, outro pra Assembléia
     */
        
    /* Busca as listas de Tipo de Evento, Participacao Permitida e Eixos Tematicos */
    FIND FIRST craptab WHERE craptab.cdcooper = 0               AND
                             craptab.nmsistem = "CRED"          AND
                             craptab.tptabela = "CONFIG"        AND
                             craptab.cdempres = 0               AND
                             craptab.cdacesso = "PGTPEVENTO"    AND
                             craptab.tpregist = 0               NO-LOCK NO-ERROR.
    
    IF AVAILABLE craptab THEN
      DO:
    
        DO i = 1 TO (NUM-ENTRIES(craptab.dstextab) / 2):
          CREATE tt-evento.
          ASSIGN tt-evento.dsevento = ENTRY(i * 2 - 1, craptab.dstextab,",")
                 tt-evento.cdevento = INT(ENTRY(i * 2, craptab.dstextab,",")).
        END.
    
        FOR EACH tt-evento NO-LOCK BY tt-evento.dsevento:
          IF aux_tpevento <> "" AND aux_tpevento <> ? THEN
            ASSIGN aux_tpevento = aux_tpevento + ",".
            
          ASSIGN aux_tpevento = aux_tpevento + STRING(tt-evento.dsevento) + "," + STRING(tt-evento.cdevento).
          
        END.         
        
      END.
      
    ASSIGN aux_tpevento = ",0," + aux_tpevento.  
        
    FIND FIRST craptab WHERE craptab.cdcooper = 0               AND
                             craptab.nmsistem = "CRED"          AND
                             craptab.tptabela = "CONFIG"        AND
                             craptab.cdempres = 0               AND
                             craptab.cdacesso = "PGTPPARTIC"    AND
                             craptab.tpregist = 0               NO-LOCK NO-ERROR.
    
    ASSIGN aux_tppartic = ",0,".
    
    IF   AVAILABLE craptab   THEN
         ASSIGN aux_tppartic = aux_tppartic + craptab.dstextab.

    ASSIGN aux_nrseqtem = ",0,".

    /* Tema */
		RUN RodaJavaScript("var vetorTema = new Array();").
    FOR EACH craptem WHERE craptem.idsittem = "A"  NO-LOCK BY craptem.dstemeix:

        ASSIGN aux_nrseqtem = aux_nrseqtem + CAPS(craptem.dstemeix) /*+ " (" + STRING(craptem.nrseqtem) + ")"*/ +
                              "," + STRING(craptem.nrseqtem) + ",".


				RUN RodaJavaScript("vetorTema.push(~{nrseqtem:'" + STRING(craptem.nrseqtem) 
																			  + "',cdeixtem:'" + STRING(craptem.cdeixtem) + "'~});").

    END.

    ASSIGN aux_nrseqtem = SUBSTRING(aux_nrseqtem, 1, LENGTH(aux_nrseqtem) - 1).
   
	 RUN RodaJavaScript("var vetorEixo = new Array();").
	 
    /* Eixo tematico */
    FOR EACH gnapetp WHERE gnapetp.cdcooper = 0                           AND
                           gnapetp.idevento = INTE(ab_unmap.aux_idevento) NO-LOCK BY gnapetp.dseixtem:
    
			RUN RodaJavaScript("vetorEixo.push(~{cdeixtem:'" + STRING(gnapetp.cdeixtem) 
																			+ "',dseixtem:'" + gnapetp.dseixtem + "'~});").        
    END.

    /* Programas */
    ASSIGN aux_nrseqpgm = ",0,".
    FOR EACH crappgm WHERE crappgm.idsitpgm = 1  NO-LOCK BY crappgm.nmprogra:

        ASSIGN aux_nrseqpgm = aux_nrseqpgm + CAPS(crappgm.nmprogra) + "," + STRING(crappgm.nrseqpgm) + ",".

    END.
    
    ASSIGN aux_nrseqpgm = SUBSTRING(aux_nrseqpgm, 1, LENGTH(aux_nrseqpgm) - 1).
        
        
    ASSIGN aux_nrseqpri = ",0,".

    /* Parceria Institucional */
    FOR EACH crappri WHERE crappri.idsitpri = "A" NO-LOCK BY crappri.nmprcins: 

        ASSIGN aux_nrseqpri = aux_nrseqpri + CAPS(crappri.nmprcins) +
                              "," + STRING(crappri.nrseqpri) + ",".

    END.

    ASSIGN aux_nrseqpri = SUBSTRING(aux_nrseqpri, 1, LENGTH(aux_nrseqpri) - 1).
    ASSIGN aux_idrespub = ",,NÃO,N,SIM,S".
    ASSIGN aux_idvalloc = "SIM,1,NÃO,0".
    
    /* Preenche as listas com os elementos encontrados */
    ASSIGN 
        ab_unmap.aux_nrseqtem:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = aux_nrseqtem
        ab_unmap.aux_tpevento:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = aux_tpevento
        ab_unmap.aux_tppartic:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = aux_tppartic
        ab_unmap.aux_nrseqpri:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = aux_nrseqpri
        ab_unmap.aux_idrespub:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = aux_idrespub
        ab_unmap.aux_idvalloc:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = aux_idvalloc
        ab_unmap.aux_nrseqpgm:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = aux_nrseqpgm.
    
    /********* Lógica para diferenciar tipos de evento em Progrid e Assembléia *********/
    /* Para todos os tipos de evento da CRAPTAB */
    DO i = 1 TO (NUM-ENTRIES(aux_tpevento) / 2):

        /* Se for Progrid */
        IF   ab_unmap.aux_idevento = "1" THEN
             DO:
                 /* Apaga Assembléias(código 7) e Pré-Assembléias (código 8) */
                 IF ENTRY(i * 2, aux_tpevento) = "7"  OR 
                    ENTRY(i * 2, aux_tpevento) = "8"  OR 
                    ENTRY(i * 2, aux_tpevento) = "11" OR
                    ENTRY(i * 2, aux_tpevento) = "12" OR
                    ENTRY(i * 2, aux_tpevento) = "13" OR 
                    ENTRY(i * 2, aux_tpevento) = "14" OR 
                    ENTRY(i * 2, aux_tpevento) = "15" OR 
                    ENTRY(i * 2, aux_tpevento) = "16" OR
					ENTRY(i * 2, aux_tpevento) = "17" THEN                      
                      DO:
                          ab_unmap.aux_tpevento:DELETE(ENTRY(i * 2, aux_tpevento))
                               IN FRAME {&FRAME-NAME}.
                      END.
             END.
        /* Assembléias */
        ELSE 
            DO:
                /* Somente não apaga Assembléias(código 7) e Pré-Assembléias (código 8) */
                IF  ENTRY(i * 2, aux_tpevento) <> "7"  AND
                    ENTRY(i * 2, aux_tpevento) <> "8"  AND
                    ENTRY(i * 2, aux_tpevento) <> "11" AND
                    ENTRY(i * 2, aux_tpevento) <> "12" AND
                    ENTRY(i * 2, aux_tpevento) <> "13" AND
                    ENTRY(i * 2, aux_tpevento) <> "14" AND
                    ENTRY(i * 2, aux_tpevento) <> "15" AND 
                    ENTRY(i * 2, aux_tpevento) <> "16" AND
					ENTRY(i * 2, aux_tpevento) <> "17" THEN
                     DO:
                           ab_unmap.aux_tpevento:DELETE(ENTRY(i * 2, aux_tpevento)).
                     END.
            
            END.
    END.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaRecursos w-html 
PROCEDURE CriaListaRecursos :

    DEF VAR aux_nrseqdig AS CHARACTER NO-UNDO.
    
    RUN RodaJavaScript("var mrecurso = new Array();").
    
    FOR EACH gnaprdp WHERE gnaprdp.idevento = INTEGER(ab_unmap.aux_idevento) AND
                           gnaprdp.cdcooper = 0                              AND   
                           gnaprdp.idsitrec = 1                              AND
                           gnaprdp.cdtiprec <> 0 
                           NO-LOCK BY gnaprdp.dsrecurs :  

       FIND craprep WHERE craprep.idevento = gnaprdp.idevento 
                      AND craprep.cdcooper = gnaprdp.cdcooper
                      AND craprep.cdevento = INT(ab_unmap.aux_cdevento)
                      AND craprep.nrseqdig = gnaprdp.nrseqdig NO-LOCK NO-ERROR NO-WAIT.
         
         IF AVAILABLE craprep THEN
           DO:
					RUN RodaJavaScript("mrecurso.push(~{nrseqdig:'" + STRING(gnaprdp.nrseqdig) + 
																					 "',dsrecurs:'" + STRING(gnaprdp.dsrecurs) + 
																					 "',rowid:'" + STRING(ROWID(craprep)) + "'~});").
				END.
                
			IF TRIM(aux_nrseqdig) = "" OR
         TRIM(aux_nrseqdig) = ? THEN
          aux_nrseqdig = " ,0".
          
       ASSIGN aux_nrseqdig = aux_nrseqdig + "," + REPLACE(gnaprdp.dsrecurs,",",".") + "," + STRING(gnaprdp.nrseqdig).
    END.
    
    ab_unmap.nrseqdig:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = aux_nrseqdig.
    
END PROCEDURE.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaPac w-html 
PROCEDURE CriaListaPac :
    
    DEFINE INPUT PARAMETER aux_cdcooper AS INT.
    
    DEF VAR aux_cdagenci AS CHARACTER NO-UNDO.
    
    IF   AVAILABLE gnapses   THEN
         DO:
             /* Operador que vizualiza todos os PAC */
             IF   gnapses.nvoperad = 0   OR
                  gnapses.nvoperad = 3   THEN 
               DO:
                  aux_cdagenci = ",-2".
                  FOR EACH crapage WHERE crapage.cdcooper = aux_cdcooper   AND
                                         (crapage.insitage = 1  OR   /* Ativo */
                                         crapage.insitage = 3) AND  /* Temporariamente Indisponivel */
                                         crapage.flgdopgd = TRUE /* Habilitado no Progrid*/ NO-LOCK
                                         BY crapage.nmresage:

                     /* Despreza PAC 90-INTERNET e PAC 91-TAA */
                     IF crapage.cdagenci = 90   OR
                         crapage.cdagenci = 91   THEN
                         NEXT.
                     IF aux_cdagenci <> "" THEN
                        aux_cdagenci = aux_cdagenci + ",".
                     
                     ASSIGN aux_cdagenci = aux_cdagenci + crapage.nmresage + "," + TRIM(STRING(crapage.cdagenci)).
                       
                  END. /* for each */
                  aux_cdagenci = aux_cdagenci + ",TODOS,-1".
               END.
             ELSE
                  DO:
                      FIND crapage WHERE crapage.cdcooper = aux_cdcooper     AND
                                         crapage.cdagenci = gnapses.cdagenci AND
                                         crapage.flgdopgd = TRUE /* Habilitado no Progrid*/ AND
                                         (crapage.insitage = 1  OR   /* Ativo */
                                         crapage.insitage = 3) /* Temporariamente Indisponivel */                
                                         NO-LOCK NO-ERROR.
                      IF   AVAILABLE crapage   THEN                                   
                           ASSIGN aux_cdagenci = crapage.nmresage + "," + TRIM(STRING(crapage.cdagenci)).
                      ELSE
                           ASSIGN aux_cdagenci = "".
                  END.
         END.
    ELSE
         ASSIGN aux_cdagenci = "".
    
    ab_unmap.aux_cdagenci:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = aux_cdagenci.
    
    FIND gnaprdp WHERE gnaprdp.cdcooper = 0 AND
                       gnaprdp.idevento = INT(ab_unmap.aux_idevento) AND
                       gnaprdp.nrseqdig = INT(ab_unmap.nrseqdig)
                       NO-LOCK NO-ERROR.
    IF AVAILABLE gnaprdp THEN DO:
       ASSIGN ab_unmap.aux_idrecpor = STRING(gnaprdp.idrecpor)
              ab_unmap.aux_cdtiprec = STRING(gnaprdp.cdtiprec).
    END.
    ELSE DO:
       ASSIGN ab_unmap.aux_idrecpor = "0"
              ab_unmap.aux_cdtiprec = "0".
    END.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ExcluiRecurso w-html 
PROCEDURE ExcluiRecurso :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    /* Instancia a BO para executar as procedures */
    RUN dbo/b1wpgd0008a.p PERSISTENT SET h-b1wpgd0008a.
    
    /* Se BO foi instanciada */
    IF   VALID-HANDLE(h-b1wpgd0008a)   THEN
         DO:
            /* busca o Recurso do Evento */
            FIND craprep WHERE craprep.idevento = INTEGER(ab_unmap.aux_idevento)   AND
                               craprep.cdevento = INTEGER(ab_unmap.aux_cdevento)   AND
                               craprep.cdcooper = 0                                AND
                               craprep.nrseqdig = INTEGER(ab_unmap.aux_nrseqdig)   NO-LOCK.
            
            CREATE cratrep.
            BUFFER-COPY craprep TO cratrep.
            
                
            RUN exclui-registro IN h-b1wpgd0008a(INPUT TABLE cratrep, OUTPUT msg-erro).
        
            /* "mata" a instância da BO */
            DELETE PROCEDURE h-b1wpgd0008a NO-ERROR.
         END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ExcluiRecurso w-html 
PROCEDURE ExcluiRecursoPorPa :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

  FIND craprpe WHERE ROWID(craprpe) = TO-ROWID(ab_unmap.aux_nrdrowid_rp) EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
  
  IF AVAILABLE craprpe THEN
    DELETE craprpe.
  ELSE
    IF LOCKED craprpe THEN
      ASSIGN msg-erro-aux = 3.
    ELSE
      DO:
        ASSIGN msg-erro = "Registro não existe.".
        RETURN "NOK".
      END.
    
END PROCEDURE.

PROCEDURE ExcluiPublicoAlvo:

  FIND FIRST crappae WHERE crappae.idevento = INTEGER(ab_unmap.aux_idevento)
                       AND crappae.cdcooper = 0
                       AND crappae.dtanoage = 0
                       AND crappae.cdevento = INTEGER(ab_unmap.aux_cdevento)
                       AND crappae.nrseqpap = INTEGER(ab_unmap.aux_nrseqpap) EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                       
  IF AVAILABLE crappae THEN                     
    DELETE crappae.
    
  RETURN "OK".
    
END PROCEDURE.

PROCEDURE ExcluiProdutoSugerido:

  FIND FIRST crappde WHERE crappde.idevento = INTEGER(ab_unmap.aux_idevento)
                       AND crappde.cdcooper = 0
                       AND crappde.dtanoage = 0
                       AND crappde.cdevento = INTEGER(ab_unmap.aux_cdevento)
                       AND crappde.nrseqpdp = INTEGER(ab_unmap.aux_nrseqpdp) EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      
  IF AVAILABLE crappde THEN
    DELETE crappde.
    
  RETURN "OK".
    
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
    ("aux_dtanoage":U,"ab_unmap.aux_dtanoage":U,ab_unmap.aux_dtanoage:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdeixtem":U,"ab_unmap.aux_cdeixtem":U,ab_unmap.aux_cdeixtem:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dseixtem":U,"ab_unmap.aux_dseixtem":U,ab_unmap.aux_dseixtem:HANDLE IN FRAME {&FRAME-NAME}).	
	RUN htmAssociate
    ("aux_cdagenci":U,"ab_unmap.aux_cdagenci":U,ab_unmap.aux_cdagenci:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdcooper":U,"ab_unmap.aux_cdcooper":U,ab_unmap.aux_cdcooper:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
   ("aux_nrseqpri":U,"ab_unmap.aux_nrseqpri":U,ab_unmap.aux_nrseqpri:HANDLE IN FRAME {&FRAME-NAME}). 
  RUN htmAssociate
    ("aux_cdevento":U,"ab_unmap.aux_cdevento":U,ab_unmap.aux_cdevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdorigem":U,"ab_unmap.aux_cdorigem":U,ab_unmap.aux_cdorigem:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsendurl":U,"ab_unmap.aux_dsendurl":U,ab_unmap.aux_dsendurl:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsretorn":U,"ab_unmap.aux_dsretorn":U,ab_unmap.aux_dsretorn:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idevento":U,"ab_unmap.aux_idevento":U,ab_unmap.aux_idevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idrecpor":U,"ab_unmap.aux_idrecpor":U,ab_unmap.aux_idrecpor:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdtiprec":U,"ab_unmap.aux_cdtiprec":U,ab_unmap.aux_cdtiprec:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lspermis":U,"ab_unmap.aux_lspermis":U,ab_unmap.aux_lspermis:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nmpagina":U,"ab_unmap.aux_nmpagina":U,ab_unmap.aux_nmpagina:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_qtrecage":U,"ab_unmap.aux_qtrecage":U,ab_unmap.aux_qtrecage:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_qtgrppar":U,"ab_unmap.aux_qtgrppar":U,ab_unmap.aux_qtgrppar:HANDLE IN FRAME {&FRAME-NAME}).    
  RUN htmAssociate
    ("aux_nrdrowid":U,"ab_unmap.aux_nrdrowid":U,ab_unmap.aux_nrdrowid:HANDLE IN FRAME {&FRAME-NAME}).    
  RUN htmAssociate
    ("aux_nrdrowid_rp":U,"ab_unmap.aux_nrdrowid_rp":U,ab_unmap.aux_nrdrowid_rp:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrseqdig":U,"ab_unmap.aux_nrseqdig":U,ab_unmap.aux_nrseqdig:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_stdopcao":U,"ab_unmap.aux_stdopcao":U,ab_unmap.aux_stdopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_abaopcao":U,"ab_unmap.aux_abaopcao":U,ab_unmap.aux_abaopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_tpevento":U,"ab_unmap.aux_tpevento":U,ab_unmap.aux_tpevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_tppartic":U,"ab_unmap.aux_tppartic":U,ab_unmap.aux_tppartic:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsjustif":U,"ab_unmap.aux_dsjustif":U,ab_unmap.aux_dsjustif:HANDLE IN FRAME {&FRAME-NAME}). 
  RUN htmAssociate
    ("tel_cdoperad":U,"ab_unmap.tel_cdoperad":U,ab_unmap.tel_cdoperad:HANDLE IN FRAME {&FRAME-NAME}).  
  RUN htmAssociate
    ("aux_cdoperad":U,"ab_unmap.aux_cdoperad":U,ab_unmap.aux_cdoperad:HANDLE IN FRAME {&FRAME-NAME}).  
  RUN htmAssociate
    ("aux_nrseqtem":U,"ab_unmap.aux_nrseqtem":U,ab_unmap.aux_nrseqtem:HANDLE IN FRAME {&FRAME-NAME}). 
  RUN htmAssociate
    ("aux_idrespub":U,"ab_unmap.aux_idrespub":U,ab_unmap.aux_idrespub:HANDLE IN FRAME {&FRAME-NAME}).  
  RUN htmAssociate
    ("aux_idvalloc":U,"ab_unmap.aux_idvalloc":U,ab_unmap.aux_idvalloc:HANDLE IN FRAME {&FRAME-NAME}).  
  RUN htmAssociate
    ("aux_nrseqpgm":U,"ab_unmap.aux_nrseqpgm":U,ab_unmap.aux_nrseqpgm:HANDLE IN FRAME {&FRAME-NAME}). 
  RUN htmAssociate
    ("flgativo":U,"crapedp.flgativo":U,crapedp.flgativo:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("flgcerti":U,"crapedp.flgcerti":U,crapedp.flgcerti:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("flgcompr":U,"crapedp.flgcompr":U,crapedp.flgcompr:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("flgrestr":U,"crapedp.flgrestr":U,crapedp.flgrestr:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("flgsorte":U,"crapedp.flgsorte":U,crapedp.flgsorte:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("idperint":U,"crapedp.idperint":U,crapedp.idperint:HANDLE IN FRAME {&FRAME-NAME}).  
  RUN htmAssociate
    ("flgtdpac":U,"crapedp.flgtdpac":U,crapedp.flgtdpac:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nmevento":U,"crapedp.nmevento":U,crapedp.nmevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nridamin":U,"crapedp.nridamin":U,crapedp.nridamin:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("prfreque":U,"crapedp.prfreque":U,crapedp.prfreque:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("qtmaxtur":U,"crapedp.qtmaxtur":U,crapedp.qtmaxtur:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("qtmintur":U,"crapedp.qtmintur":U,crapedp.qtmintur:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("qtparcta":U,"crapedp.qtparcta":U,crapedp.qtparcta:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("qtdiaeve":U,"crapedp.qtdiaeve":U,crapedp.qtdiaeve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("cdagenci":U,"ab_unmap.cdagenci":U,ab_unmap.cdagenci:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nrseqdig":U,"ab_unmap.nrseqdig":U,ab_unmap.nrseqdig:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdcopope":U,"ab_unmap.aux_cdcopope":U,ab_unmap.aux_cdcopope:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsurlphp":U,"ab_unmap.aux_dsurlphp":U,ab_unmap.aux_dsurlphp:HANDLE IN FRAME {&FRAME-NAME}). 
  RUN htmAssociate
    ("aux_nrseqpdp":U,"ab_unmap.aux_nrseqpdp":U,ab_unmap.aux_nrseqpdp:HANDLE IN FRAME {&FRAME-NAME}).   
  RUN htmAssociate
    ("aux_nrseqpap":U,"ab_unmap.aux_nrseqpap":U,ab_unmap.aux_nrseqpap:HANDLE IN FRAME {&FRAME-NAME}).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-assign-record w-html 
PROCEDURE local-assign-record:
DEFINE INPUT PARAMETER opcao AS CHARACTER.
DEFINE INPUT PARAMETER abaopcao AS CHARACTER.

DEFINE VAR aux_regexist AS INT NO-UNDO.

    /* Instancia a BO para executar as procedures */
    RUN dbo/b1wpgd0008.p PERSISTENT SET h-b1wpgd0008.
    
    /* Se BO foi instanciada */
    IF   VALID-HANDLE(h-b1wpgd0008)   THEN
         DO:
            DO WITH FRAME {&FRAME-NAME}:
               
               IF   opcao = "inclusao"   THEN
                    DO:  
                        IF   abaopcao = "p" THEN
                             DO:
                                
                                FOR EACH crapage WHERE crapage.cdcooper = INT(ab_unmap.aux_cdcooper)
                                                   AND crapage.cdagenci <> 90
                                                   AND crapage.cdagenci <> 91
                                                   AND crapage.flgdopgd = TRUE /* Habilitado no Progrid*/
                                                   AND (crapage.cdagenci = INT(ab_unmap.aux_cdagenci) 
                                                    OR INT(ab_unmap.aux_cdagenci) = -1) NO-LOCK:
                                    aux_regexist = 0.
                                    
                                    FOR FIRST craprpe FIELDS(craprpe.qtrecage craprpe.qtgrppar craprpe.dtatuali
                                                             craprpe.cdcopope craprpe.cdoperad)
                                                       WHERE craprpe.idevento = INT(ab_unmap.aux_idevento)
                                                         AND craprpe.cdcooper = 0
                                                         AND craprpe.cdevento = INT(ab_unmap.aux_cdevento)
                                                         AND craprpe.nrseqdig = INT(ab_unmap.nrseqdig)
                                                         AND craprpe.cdcopage = INT(ab_unmap.aux_cdcooper)
                                                         AND craprpe.cdagenci = crapage.cdagenci
                                                                    EXCLUSIVE-LOCK BY nrseqdig DESCENDING:
                                                                    
                                        IF INT(ab_unmap.aux_cdagenci) <> -1 AND ab_unmap.aux_nrdrowid_rp = "" THEN DO:
                                          ASSIGN msg-erro = "Este recurso já está cadastrado para este PA!".
                                          RETURN "NOK".
                                        END.
                                        ELSE
                                          ASSIGN aux_regexist = 1
                                                 craprpe.qtrecage = (IF INT(ab_unmap.aux_cdtiprec) = 5 OR INT(ab_unmap.aux_cdtiprec) = 2 THEN 0 ELSE INT(ab_unmap.aux_qtrecage)) /*INT(ab_unmap.aux_qtrecage)*/
                                                 craprpe.qtgrppar = INT(ab_unmap.aux_qtgrppar)
                                                 craprpe.dtatuali = TODAY
                                                 craprpe.cdcopope = INT(ab_unmap.aux_cdcopope)
                                                 craprpe.cdoperad = ab_unmap.aux_cdoperad.
                                                 
                                    END.
                                    
                                    IF aux_regexist = 0 THEN
                                    DO:
                                      CREATE craprpe.
                                      ASSIGN craprpe.idevento = INT(ab_unmap.aux_idevento)
                                             craprpe.cdcooper = 0
                                             craprpe.cdevento = INT(ab_unmap.aux_cdevento)
                                             craprpe.cdcopage = INT(ab_unmap.aux_cdcooper)
                                             craprpe.cdagenci = crapage.cdagenci
                                             craprpe.nrseqdig = INT(ab_unmap.nrseqdig)
                                             craprpe.qtrecage = (IF INT(ab_unmap.aux_cdtiprec) = 5 OR INT(ab_unmap.aux_cdtiprec) = 2 THEN 0 ELSE INT(ab_unmap.aux_qtrecage)) /*INT(ab_unmap.aux_qtrecage)*/
                                             craprpe.qtgrppar = INT(ab_unmap.aux_qtgrppar)
                                             craprpe.cdoperad = ab_unmap.aux_cdoperad
                                             craprpe.cdprogra = "WPGD0008"
                                             craprpe.dtatuali = TODAY
                                             craprpe.cdcopope = INT(ab_unmap.aux_cdcopope).
                                    END.
                                END. /* FOR EACH */
                             END.
                        ELSE
                             DO:
                                CREATE cratedp.
                                ASSIGN cratedp.cdeixtem = INTEGER(ab_unmap.aux_cdeixtem)
                                       cratedp.cdcooper = 0
                                       cratedp.cdevento = 0
                                       cratedp.flgativo = INPUT crapedp.flgativo
                                       cratedp.flgcerti = INPUT crapedp.flgcerti
                                       cratedp.flgcompr = INPUT crapedp.flgcompr
                                       cratedp.flgrestr = INPUT crapedp.flgrestr
                                       cratedp.flgsorte = INPUT crapedp.flgsorte
                                       cratedp.flgtdpac = INPUT crapedp.flgtdpac
                                       cratedp.idevento = INTEGER(ab_unmap.aux_idevento)
                                       cratedp.nmevento = INPUT crapedp.nmevento
                                       cratedp.nridamin = INPUT crapedp.nridamin
                                       cratedp.prfreque = INPUT crapedp.prfreque
                                       cratedp.qtmaxtur = INPUT crapedp.qtmaxtur
                                       cratedp.idperint = INPUT crapedp.idperint
                                       cratedp.nrseqpgm = INTEGER(ab_unmap.aux_nrseqpgm)
                                       cratedp.qtmintur = INPUT crapedp.qtmintur
                                       cratedp.qtparcta = INPUT crapedp.qtparcta
                                       cratedp.tpevento = INTEGER(ab_unmap.aux_tpevento)
                                       cratedp.tppartic = INTEGER(ab_unmap.aux_tppartic)
                                       cratedp.nrseqtem = INTEGER(ab_unmap.aux_nrseqtem)
                                       cratedp.nrseqpri = INTEGER(ab_unmap.aux_nrseqpri)
                                       cratedp.dsjustif = ab_unmap.aux_dsjustif
                                       cratedp.cdoperad = ab_unmap.aux_cdoperad
                                       cratedp.cdcopope = INTEGER(ab_unmap.aux_cdcopope)
                                       cratedp.qtdiaeve = INPUT crapedp.qtdiaeve
                                       cratedp.idrespub = GET-VALUE("aux_idrespub")
                                       cratedp.idvalloc = INT(GET-VALUE("aux_idvalloc")).

                                RUN inclui-registro IN h-b1wpgd0008(INPUT TABLE cratedp, OUTPUT msg-erro, OUTPUT ab_unmap.aux_nrdrowid).
                             END.
                    END.
               ELSE  /* alteracao */
                    DO:    
                        /* cria a temp-table e joga o novo valor digitado para o campo */
                        CREATE cratedp.
                        BUFFER-COPY crapedp TO cratedp.  
                        
                        ASSIGN cratedp.cdeixtem = INTEGER(ab_unmap.aux_cdeixtem)
                               cratedp.cdcooper = crapedp.cdcooper
                               cratedp.flgativo = INPUT crapedp.flgativo
                               cratedp.flgcerti = INPUT crapedp.flgcerti
                               cratedp.flgcompr = INPUT crapedp.flgcompr
                               cratedp.flgrestr = INPUT crapedp.flgrestr
                               cratedp.flgsorte = INPUT crapedp.flgsorte
                               cratedp.flgtdpac = INPUT crapedp.flgtdpac
                               cratedp.idevento = INTEGER(ab_unmap.aux_idevento)
                               cratedp.nmevento = INPUT crapedp.nmevento
                               cratedp.nridamin = INPUT crapedp.nridamin
                               cratedp.prfreque = INPUT crapedp.prfreque
                               cratedp.qtmaxtur = INPUT crapedp.qtmaxtur
                               cratedp.idperint = INPUT crapedp.idperint
                               cratedp.nrseqpgm = INTEGER(ab_unmap.aux_nrseqpgm)
                               cratedp.qtmintur = INPUT crapedp.qtmintur
                               cratedp.qtparcta = INPUT crapedp.qtparcta
                               cratedp.tpevento = INTEGER(ab_unmap.aux_tpevento)
                               cratedp.tppartic = INTEGER(ab_unmap.aux_tppartic)
                               cratedp.nrseqtem = INTEGER(ab_unmap.aux_nrseqtem)
                               cratedp.nrseqpri = INTEGER(ab_unmap.aux_nrseqpri)
                               cratedp.dsjustif = ab_unmap.aux_dsjustif
                               cratedp.cdoperad = ab_unmap.aux_cdoperad
                               cratedp.cdcopope = INTEGER(ab_unmap.aux_cdcopope)
                               cratedp.qtdiaeve = INPUT crapedp.qtdiaeve       
                               cratedp.idrespub = GET-VALUE("aux_idrespub")
                               cratedp.idvalloc = INT(GET-VALUE("aux_idvalloc")).
                          
                        RUN altera-registro IN h-b1wpgd0008(INPUT TABLE cratedp, OUTPUT msg-erro).

                    END.    

            END. /* DO WITH FRAME {&FRAME-NAME} */
         
            /* "mata" a instância da BO */
            DELETE PROCEDURE h-b1wpgd0008 NO-ERROR.
         
         END. /* IF VALID-HANDLE(h-b1wpgd0008) */
      
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-delete-record w-html 
PROCEDURE local-delete-record:

/* Instancia a BO para executar as procedures */
    RUN dbo/b1wpgd0008.p PERSISTENT SET h-b1wpgd0008.
     
    /* Se BO foi instanciada */
    IF   VALID-HANDLE(h-b1wpgd0008)   THEN
         DO:
            CREATE cratedp.
            BUFFER-COPY crapedp TO cratedp.
                
            RUN exclui-registro IN h-b1wpgd0008(INPUT TABLE cratedp, OUTPUT msg-erro).
         
      IF RETURN-VALUE = "OK" THEN
        DO:
          /* EXCLUIR RECURSO */
          FOR EACH craprep WHERE craprep.idevento = INT(ab_unmap.aux_idevento) 
                             AND craprep.cdcooper = 0
                             AND craprep.cdevento = INT(ab_unmap.aux_cdevento) EXCLUSIVE-LOCK:
            DELETE craprep.
          END.
          
          /* EXCLUIR RECURSO POR PA */
          FOR EACH craprpe WHERE craprpe.idevento = INTEGER(ab_unmap.aux_idevento)
                             AND craprpe.cdcooper = 0
                             AND craprpe.cdevento = INTEGER(ab_unmap.aux_cdevento) EXCLUSIVE-LOCK:
            DELETE craprpe.
          END.

          /* EXCLUIR PUBLICO ALVO */
          FOR EACH crappae WHERE crappae.idevento = INTEGER(ab_unmap.aux_idevento)
                             AND crappae.cdcooper = 0
                             AND crappae.dtanoage = 0
                             AND crappae.cdevento = INTEGER(ab_unmap.aux_cdevento) EXCLUSIVE-LOCK:
            DELETE crappae.
          END.
          
          /* EXCLUIR PRODUTO SUGERIDO */
          FOR EACH crappde WHERE crappde.idevento = INTEGER(ab_unmap.aux_idevento)
                             AND crappde.cdcooper = 0
                             AND crappde.dtanoage = 0
                             AND crappde.cdevento = INTEGER(ab_unmap.aux_cdevento) EXCLUSIVE-LOCK:
            DELETE crappde.
          END.
        END.
            /* "mata" a instância da BO */
            DELETE PROCEDURE h-b1wpgd0008 NO-ERROR.
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
/*
FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.

IF   AVAILABLE {&SECOND-ENABLED-TABLE}   THEN
     DO:
         FIND PREV {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.
     
         IF   AVAILABLE {&SECOND-ENABLED-TABLE}   THEN
              DO:
                 ASSIGN ab_unmap.aux_nrdrowid = STRING(ROWID({&SECOND-ENABLED-TABLE})).
              
                 FIND PREV {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.
              
                 IF   AVAILABLE {&SECOND-ENABLED-TABLE}   THEN
                      ASSIGN ab_unmap.aux_stdopcao = "".
                 ELSE
                      ASSIGN ab_unmap.aux_stdopcao = "".
              
                 FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
              END.
         ELSE
              DO:
                 RUN RodaJavaScript("alert('Este já é o primeiro registro.')"). 
                  
                 FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
              
                 IF   AVAILABLE {&SECOND-ENABLED-TABLE}   THEN
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
FIND FIRST {&SECOND-ENABLED-TABLE} WHERE
               {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento)    AND
               {&SECOND-ENABLED-TABLE}.cdcooper = 0                                 AND
               {&SECOND-ENABLED-TABLE}.dtanoage = 0                                 AND
               {&SECOND-ENABLED-TABLE}.tpevento <> 10
               NO-LOCK NO-WAIT NO-ERROR.
    
    IF   NOT AVAILABLE {&SECOND-ENABLED-TABLE}   THEN
         ASSIGN ab_unmap.aux_nrdrowid = "?"
                ab_unmap.aux_stdopcao = "".
    ELSE
         ASSIGN ab_unmap.aux_nrdrowid = STRING(ROWID({&SECOND-ENABLED-TABLE}))
                ab_unmap.aux_stdopcao = "".  /* aqui p */
    
    /* Não traz inicialmente nenhum registro */ 
    RELEASE {&SECOND-ENABLED-TABLE}.
    
    ASSIGN ab_unmap.aux_nrdrowid = "?"
           ab_unmap.aux_stdopcao = "".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PosicionaNoSeguinte w-html 
PROCEDURE PosicionaNoSeguinte :
FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.

IF   AVAILABLE {&SECOND-ENABLED-TABLE}   THEN
     DO:
        FIND NEXT {&SECOND-ENABLED-TABLE} WHERE
                  {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento)    AND
                  {&SECOND-ENABLED-TABLE}.cdcooper = 0                                 AND
                  {&SECOND-ENABLED-TABLE}.dtanoage = 0                                 AND
                  {&SECOND-ENABLED-TABLE}.tpevento <> 10
               NO-LOCK NO-WAIT NO-ERROR.
        IF   AVAILABLE {&SECOND-ENABLED-TABLE}   THEN
             DO:
                ASSIGN ab_unmap.aux_nrdrowid = STRING(ROWID({&SECOND-ENABLED-TABLE})).
             
                FIND NEXT {&SECOND-ENABLED-TABLE} WHERE
                          {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento)    AND
                          {&SECOND-ENABLED-TABLE}.cdcooper = 0                                 AND
                          {&SECOND-ENABLED-TABLE}.dtanoage = 0                                 AND
                          {&SECOND-ENABLED-TABLE}.tpevento <> 10
                          NO-LOCK NO-WAIT NO-ERROR.
                          
                IF   AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                     ASSIGN ab_unmap.aux_stdopcao = "".
                ELSE
                     ASSIGN ab_unmap.aux_stdopcao = "".
             
                FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
             END.
        ELSE
             DO:
                RUN RodaJavaScript("alert('Este já é o último registro.')").
     
                FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
     
                IF   AVAILABLE {&SECOND-ENABLED-TABLE}   THEN
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
FIND LAST {&SECOND-ENABLED-TABLE} WHERE
                          {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento)    AND
                          {&SECOND-ENABLED-TABLE}.cdcooper = 0                                 AND
                          {&SECOND-ENABLED-TABLE}.dtanoage = 0                                 AND
                          {&SECOND-ENABLED-TABLE}.tpevento <> 10
                          NO-LOCK NO-WAIT NO-ERROR.
IF   NOT AVAILABLE {&SECOND-ENABLED-TABLE}   THEN
     ASSIGN ab_unmap.aux_nrdrowid = "?".
ELSE
     ASSIGN ab_unmap.aux_nrdrowid = STRING(ROWID({&SECOND-ENABLED-TABLE}))
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
       ab_unmap.aux_idevento = get-value("aux_idevento")
       ab_unmap.aux_idrecpor = get-value("aux_idrecpor")
       ab_unmap.aux_cdtiprec = get-value("aux_cdtiprec")
       ab_unmap.aux_dsendurl = AppURL                        
       ab_unmap.aux_lspermis = FlagPermissoes 
       ab_unmap.cdagenci     = GET-VALUE("cdagenci")
       ab_unmap.aux_cdcooper = GET-VALUE("aux_cdcooper")
       ab_unmap.aux_nrdrowid = GET-VALUE("aux_nrdrowid")
       ab_unmap.aux_nrdrowid_rp = GET-VALUE("aux_nrdrowid_rp")
       ab_unmap.aux_dtanoage = GET-VALUE("aux_dtanoage")         
       ab_unmap.aux_stdopcao = GET-VALUE("aux_stdopcao")         
       ab_unmap.aux_abaopcao = GET-VALUE("aux_abaopcao")
       ab_unmap.aux_cdevento = GET-VALUE("aux_cdevento")
       ab_unmap.aux_cdorigem = GET-VALUE("aux_cdorigem")
       ab_unmap.aux_nmpagina = GET-VALUE("aux_nmpagina")
       ab_unmap.aux_cdeixtem = GET-VALUE("aux_cdeixtem")
       ab_unmap.aux_dseixtem = GET-VALUE("aux_dseixtem")	   
       ab_unmap.aux_tpevento = GET-VALUE("aux_tpevento")
       ab_unmap.aux_tppartic = GET-VALUE("aux_tppartic")
       ab_unmap.aux_nrseqdig = GET-VALUE("aux_nrseqdig")
       ab_unmap.nrseqdig     = GET-VALUE("nrseqdig")
       ab_unmap.aux_nrseqtem = GET-VALUE("aux_nrseqtem")
       ab_unmap.aux_nrseqpri = GET-VALUE("aux_nrseqpri")
       ab_unmap.aux_dsjustif = GET-VALUE("aux_dsjustif")
       ab_unmap.aux_idrespub = GET-VALUE("aux_idrespub")
       ab_unmap.aux_idvalloc = GET-VALUE("aux_idvalloc")
       ab_unmap.aux_cdcopope = STRING(gnapses.cdcooper)
       ab_unmap.aux_cdagenci = GET-VALUE("aux_cdagenci")
       ab_unmap.aux_qtrecage = GET-VALUE("aux_qtrecage")
       ab_unmap.aux_qtgrppar = GET-VALUE("aux_qtgrppar")
       ab_unmap.aux_cdoperad = gnapses.cdoperad
       ab_unmap.aux_dsurlphp    = aux_srvprogrid + "-" + v-identificacao
       ab_unmap.aux_nrseqpdp = GET-VALUE("aux_nrseqpdp")
       ab_unmap.aux_nrseqpap = GET-VALUE("aux_nrseqpap")       
       ab_unmap.aux_nrseqpgm = GET-VALUE("aux_nrseqpgm").       

FIND crapope WHERE crapope.cdcooper = gnapses.cdcooper
               AND crapope.cdoperad = gnapses.cdoperad NO-LOCK NO-ERROR.

IF AVAILABLE crapope THEN
  ASSIGN ab_unmap.tel_cdoperad = gnapses.cdoperad + " - " + crapope.nmoperad.
    
RUN outputHeader.

/**********************/
/* gera lista de cooperativas */
{includes/wpgd0098.i}.
ab_unmap.aux_cdcooper:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = aux_crapcop.

/* Se a cooperativa ainda não foi escolhida, pega a da sessão do usuário */
IF   INT(ab_unmap.aux_cdcooper) = 0   THEN
     ab_unmap.aux_cdcooper = STRING(gnapses.cdcooper).

/* Se o PAC ainda não foi escolhido, pega o da sessão do usuário */  
IF   ab_unmap.cdagenci = " "   THEN
     ab_unmap.cdagenci = STRING(gnapses.cdagenci).

/* rotina para buscar o registro de parametro correto */
FIND LAST gnpapgd WHERE gnpapgd.idevento =  INT(ab_unmap.aux_idevento) AND 
                        gnpapgd.cdcooper =  INT(ab_unmap.aux_cdcooper) AND 
                        gnpapgd.dtanonov =  INT(ab_unmap.aux_dtanoage) NO-LOCK NO-ERROR.


IF NOT AVAILABLE gnpapgd THEN
   DO:
      IF ab_unmap.aux_dtanoage <> ""   
         THEN
             DO:
                RUN RodaJavaScript("alert('Não existe agenda para o ano (" + ab_unmap.aux_dtanoage + ") informado!');").
                opcao = "".
             END.

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
/**********************/
 
RUN insere_log_progrid("WPGD0008.w",STRING(ab_unmap.aux_idevento) + "|" + STRING(ab_unmap.aux_cdcooper) + "|" +
					  STRING(ab_unmap.aux_dtanoage) + "|" + STRING(ab_unmap.aux_cdevento)).
 
/* método POST */
IF   REQUEST_METHOD = "POST":U   THEN 
     DO:
               
        RUN inputFields.
        
        CASE opcao:
             WHEN "sa" THEN /* salvar */
                  DO:                   
                              
                      IF   ab_unmap.aux_stdopcao = "i"   THEN /* inclusao */
                           DO:
                           
                              RUN local-assign-record ("inclusao", ab_unmap.aux_abaopcao).

                              IF   msg-erro <> ""   THEN
                                   ASSIGN msg-erro-aux = 3. /* erros da validação de dados */
                              ELSE
                                   DO:
                                   
                                      ASSIGN msg-erro-aux          = 10
                                             ab_unmap.aux_stdopcao = "al".
                                    
                                      FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
                                
                                      IF   NOT AVAILABLE {&SECOND-ENABLED-TABLE}   THEN
                                           IF   LOCKED {&SECOND-ENABLED-TABLE}   THEN
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
                                           ASSIGN ab_unmap.aux_cdevento = STRING({&SECOND-ENABLED-TABLE}.cdevento).
                                
                                   END.                          

                           END.  /* fim inclusao */
                      ELSE     /* alteração */ 
                           DO: 
                              FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
     
                              IF   NOT AVAILABLE {&SECOND-ENABLED-TABLE}   THEN
                                   IF   LOCKED {&SECOND-ENABLED-TABLE}   THEN
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
                                    
                                         RUN local-assign-record ("alteracao", ab_unmap.aux_abaopcao).  
                                       
                                         IF   msg-erro = ""   THEN
                                              ASSIGN msg-erro-aux = 10. /* Solicitação realizada com sucesso */ 
                                         ELSE
                                              ASSIGN msg-erro-aux = 3. /* erros da validação de dados */
                                   END.     
                           END. /* fim alteração */
                  END. /* fim salvar */
     
             WHEN "in" THEN /* inclusao */
                  DO:
                     IF   ab_unmap.aux_stdopcao <> "i"   THEN
                          DO:
                             CLEAR FRAME {&FRAME-NAME}.
                             
                             ASSIGN ab_unmap.aux_stdopcao = "i".
                          END.
                  END. /* fim inclusao */
     
             WHEN "ex" THEN /* exclusao */
                  DO:
                     /*FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
     
                     /* busca o próximo registro para fazer o reposicionamento */
                     FIND NEXT {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.
     
                     IF   AVAILABLE {&SECOND-ENABLED-TABLE}   THEN
                          ASSIGN aux_nrdrowid-auxiliar = STRING(ROWID({&SECOND-ENABLED-TABLE})).
                     ELSE
                     DO:
                        /* nao encontrou próximo registro então procura pelo registro anterior para o reposicionamento */
                        FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                        
                        FIND PREV {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = int(ab_unmap.aux_idevento) NO-LOCK NO-WAIT NO-ERROR.
     
                        IF   AVAILABLE {&SECOND-ENABLED-TABLE}   THEN
                             ASSIGN aux_nrdrowid-auxiliar = STRING(ROWID({&SECOND-ENABLED-TABLE})).
                        ELSE
                             ASSIGN aux_nrdrowid-auxiliar = "?".
                     END.*/
                     
                     /*** PROCURA TABELA PARA VALIDAR -> COM NO-LOCK ***/
                     FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                      
                     /*** PROCURA TABELA PARA EXCLUIR -> COM EXCLUSIVE-LOCK ***/
                     FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
                      
                     IF   NOT AVAILABLE {&SECOND-ENABLED-TABLE}   THEN
                          IF   LOCKED {&SECOND-ENABLED-TABLE}   THEN
                               DO:
                                  ASSIGN msg-erro-aux = 1. /* registro em uso por outro usuário */ 
                                  
                                  FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                               END.
                          ELSE
                               ASSIGN msg-erro-aux = 2. /* registro não existe */
                     ELSE
                          DO:
                             IF   msg-erro = ""  THEN
                                  DO:
                                                                    
                                    FIND FIRST crabedp WHERE crabedp.cdevento = crapedp.cdevento
                                                         AND crabedp.cdcooper <> 0
                                                         AND crabedp.dtanoage <> 0 NO-LOCK NO-ERROR NO-WAIT.
                                                         
                                    IF NOT AVAILABLE crabedp THEN
                                      DO: 
                                     RUN local-delete-record.
                                  
                                     DO i = 1 TO ERROR-STATUS:NUM-MESSAGES:
                                        ASSIGN msg-erro = msg-erro + ERROR-STATUS:GET-MESSAGE(i).
                                     END.    
                                      END.
                                             ELSE
                                      ASSIGN msg-erro = "Evento já esta sendo utilizado. Exclusão nao permitida!".

                                    IF msg-erro = " "   THEN
                                      ASSIGN msg-erro-aux = 5. /* Exclusão realizada com sucesso */ 
                                     ELSE
                                          ASSIGN msg-erro-aux = 3. /* Exclusao rejeitada */ 
                                  END.
                             ELSE
                                  ASSIGN msg-erro-aux = 3. /* erros da validação de dados */
                          END.  
                  END. /* fim exclusao */
     
             WHEN "exr" THEN /* exclui recurso do evento */
                  DO:

                     ASSIGN msg-erro = "".
                     RUN ExcluiRecurso.  
                     
                     IF   msg-erro = ""   THEN
                          ASSIGN msg-erro-aux = 10. /* Solicitação realizada com sucesso */ 

                     FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) /*EXCLUSIVE-LOCK NO-WAIT*/ NO-ERROR.
                                
                     IF   NOT AVAILABLE {&SECOND-ENABLED-TABLE}   THEN
                          IF   LOCKED {&SECOND-ENABLED-TABLE}   THEN
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
                          ASSIGN ab_unmap.aux_nrdrowid = STRING(ROWID({&SECOND-ENABLED-TABLE})).

                  END.
     
             WHEN "exrp" THEN /* exclui recurso do evento */
                  DO:
                  
                     ASSIGN msg-erro = "".
                     RUN ExcluiRecursoPorPa.  
                     
                     IF msg-erro = "" THEN
                       DO:
                         ASSIGN msg-erro-aux = 10 /* Solicitação realizada com sucesso */ 
                                ab_unmap.aux_nrdrowid_rp = "".
                       END.
                  END.
             WHEN "pe" THEN /* pesquisar */
                  DO:   
                      FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                      IF   NOT AVAILABLE {&SECOND-ENABLED-TABLE}   THEN 
                           RUN PosicionaNoSeguinte.
                  END. /* fim pesquisar */
     
             WHEN "li" THEN /* listar */
                  DO:
                      FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                      
                      IF   NOT AVAILABLE {&SECOND-ENABLED-TABLE}   THEN 
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
          WHEN "expa" THEN /* seguinte */
            RUN ExcluiPublicoAlvo.        
          WHEN "exps" THEN /* seguinte */
            RUN ExcluiProdutoSugerido.     
      
        END CASE.
        
        ASSIGN ab_unmap.aux_idrespub = IF STRING(GET-VALUE("aux_idrespub")) <> "S" THEN "N" ELSE "S".
        ASSIGN ab_unmap.aux_idvalloc = STRING(GET-VALUE("aux_idvalloc")).
        
        RUN CriaLista.        
        RUN CriaListaRecursos.
        RUN CriaListaPublicoAlvo.        
        RUN CriaListaProdutoSugerido.
        
        IF   INT(GET-VALUE("aux_cdcooper")) <> 0   THEN
             RUN CriaListaPac(INT(GET-VALUE("aux_cdcooper"))).
        ELSE
             RUN CriaListaPac(gnapses.cdcooper).
        
        
        IF   msg-erro-aux = 10 OR (opcao <> "sa" AND opcao <> "ex" AND opcao <> "in")   THEN
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
             WHEN 5 THEN
                  DO:
                     RUN RodaJavaScript('LimparCampos();').
                     RUN RodaJavaScript('document.form.aux_cddopcao.value = "in";').
                     RUN RodaJavaScript('document.form.aux_stdopcao.value = "i"').
                     RUN RodaJavaScript('alert("Exclusão executada com sucesso."); '). 
                  END. 
             WHEN 10 THEN
                  DO:
                      RUN RodaJavaScript('alert("Atualização executada com sucesso."); '). 
                  END.
           
        END CASE.
    
        /* Se não for as telas 'Análise de Sugestões' e 'Seleção de Sugestões' */
        IF   ab_unmap.aux_cdorigem <> "2"   AND 
             ab_unmap.aux_cdorigem <> "3"   THEN
             RUN RodaJavaScript('top.frames[0].ZeraOp()').
        ELSE
             DO:
                RUN RodaJavaScript('window.opener.Recarrega();').  
                RUN RodaJavaScript('self.close();').
             END.
        
        RUN RodaJavaScript('dsjustif = "' + ab_unmap.aux_dsjustif + '";').
        
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
                     IF   GET-VALUE("LinkRowid") <> "" THEN
                          DO:
                             /* Se for Recurso por Pa */
                             IF GET-VALUE("ValorCampo3") = "recurso" THEN
                               FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(GET-VALUE("ValorCampo4")) NO-LOCK NO-WAIT NO-ERROR.
                             ELSE
                               FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(GET-VALUE("LinkRowid")) NO-LOCK NO-WAIT NO-ERROR.
                             
                             IF   AVAILABLE {&SECOND-ENABLED-TABLE}   THEN
                                  DO:
                                     ASSIGN ab_unmap.aux_nrdrowid = STRING(ROWID({&SECOND-ENABLED-TABLE}))
                                            ab_unmap.aux_idevento = STRING({&SECOND-ENABLED-TABLE}.idevento)
                                            ab_unmap.aux_cdevento = STRING({&SECOND-ENABLED-TABLE}.cdevento)
                                            ab_unmap.aux_tpevento = STRING({&SECOND-ENABLED-TABLE}.tpevento)
                                            ab_unmap.aux_tppartic = STRING({&SECOND-ENABLED-TABLE}.tppartic)
                                            ab_unmap.aux_nrseqpgm = STRING({&SECOND-ENABLED-TABLE}.nrseqpgm)
                                            ab_unmap.aux_cdeixtem = STRING({&SECOND-ENABLED-TABLE}.cdeixtem)
                                            ab_unmap.aux_nrseqtem = STRING({&SECOND-ENABLED-TABLE}.nrseqtem)
                                            ab_unmap.aux_dsjustif = CAPS(STRING({&SECOND-ENABLED-TABLE}.dsjustif))
                                            ab_unmap.aux_nrseqpri = STRING({&SECOND-ENABLED-TABLE}.nrseqpri)
                                            ab_unmap.aux_idrespub = IF STRING({&SECOND-ENABLED-TABLE}.idrespub) <> "S" THEN "N" ELSE "S"
                                            ab_unmap.aux_idvalloc = STRING({&SECOND-ENABLED-TABLE}.idvalloc).
                                            
                                     FIND crapope WHERE crapope.cdcooper =  gnapses.cdcooper  AND
                                                        crapope.cdoperad = {&SECOND-ENABLED-TABLE}.cdoperad 
                                                        NO-LOCK NO-ERROR.

                                     IF   AVAIL crapope   THEN
                                          ASSIGN ab_unmap.tel_cdoperad = crapope.cdoperad + " - " + 
                                                                         crapope.nmoperad.

                                     FIND gnapetp WHERE gnapetp.idevento = INT(ab_unmap.aux_idevento)
                                                    AND gnapetp.cdeixtem = INT(ab_unmap.aux_cdeixtem) NO-LOCK NO-ERROR NO-WAIT.
                                     
                                     IF AVAILABLE gnapetp THEN
                                       DO:
                                        ASSIGN ab_unmap.aux_dseixtem = gnapetp.dseixtem.
                                       END.
                                      
                                     FIND NEXT {&SECOND-ENABLED-TABLE} NO-LOCK NO-WAIT NO-ERROR.
     
                                     IF   NOT AVAILABLE {&SECOND-ENABLED-TABLE}   THEN
                                          ASSIGN ab_unmap.aux_stdopcao = "u".
                                     ELSE
                                          DO:
                                             FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                                           
                                             FIND PREV {&SECOND-ENABLED-TABLE} NO-LOCK NO-WAIT NO-ERROR.
     
                                             IF   NOT AVAILABLE {&SECOND-ENABLED-TABLE}   THEN
                                                  ASSIGN ab_unmap.aux_stdopcao = "p".        
                                             ELSE
                                                  ASSIGN ab_unmap.aux_stdopcao = "?".
                                          END.
     
                                     FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                                  
                                  END.  
                             ELSE
                                  ASSIGN ab_unmap.aux_nrdrowid = "?"
                                         ab_unmap.aux_stdopcao = "?".
                             
                             /* Se for Recurso por Pa */
                             IF GET-VALUE("ValorCampo3") = "recurso" THEN
                             DO:
                               FIND {&THIRD-ENABLED-TABLE} WHERE ROWID({&THIRD-ENABLED-TABLE}) = TO-ROWID(GET-VALUE("LinkRowid")) NO-LOCK NO-WAIT NO-ERROR.
                               
                               IF   AVAILABLE {&THIRD-ENABLED-TABLE}   THEN
                                    DO:
                                       
                                       RUN CriaListaPac({&THIRD-ENABLED-TABLE}.cdcopage).
                                       
                                       ASSIGN ab_unmap.aux_nrdrowid_rp = STRING(ROWID({&THIRD-ENABLED-TABLE}))
                                              ab_unmap.aux_cdcooper    = STRING({&THIRD-ENABLED-TABLE}.cdcopage)
                                              ab_unmap.aux_cdagenci    = STRING({&THIRD-ENABLED-TABLE}.cdagenci)
                                              ab_unmap.nrseqdig        = STRING({&THIRD-ENABLED-TABLE}.nrseqdig)
                                              ab_unmap.aux_qtrecage    = STRING({&THIRD-ENABLED-TABLE}.qtrecage)
                                              ab_unmap.aux_qtgrppar    = STRING({&THIRD-ENABLED-TABLE}.qtgrppar).
                                              
                                                                                
                                       FIND gnaprdp WHERE gnaprdp.cdcooper = 0 AND
                                                          gnaprdp.idevento = INT(ab_unmap.aux_idevento) AND
                                                          gnaprdp.nrseqdig = INT(ab_unmap.nrseqdig)
                                                          NO-LOCK NO-ERROR.
                                       IF AVAILABLE gnaprdp THEN DO:
                                          ASSIGN ab_unmap.aux_idrecpor = STRING(gnaprdp.idrecpor)
                                                 ab_unmap.aux_cdtiprec = STRING(gnaprdp.cdtiprec).
                                       END.
                                       ELSE DO:
                                          ASSIGN ab_unmap.aux_idrecpor = "0"
                                                 ab_unmap.aux_cdtiprec = "0".
                                       END.
                                       FIND {&THIRD-ENABLED-TABLE} WHERE ROWID({&THIRD-ENABLED-TABLE}) = TO-ROWID(ab_unmap.aux_nrdrowid) NO-LOCK NO-WAIT NO-ERROR.
                                    
                                    END.
                             END.
                          END.  
                     ELSE
                          RUN PosicionaNoPrimeiro.
                     
                     RUN CriaLista.     
                     RUN CriaListaRecursos.
                     RUN CriaListaPublicoAlvo.
                     RUN CriaListaProdutoSugerido.
                     RUN displayFields.
                     RUN enableFields.
                     RUN outputFields.
                     
                     /* Se não for as telas 'Análise de Sugestões' e 'Seleção de Sugestões' */
                     IF   ab_unmap.aux_cdorigem <> "2"   AND 
                          ab_unmap.aux_cdorigem <> "3"   AND 
                          ab_unmap.aux_cdorigem <> "4"   THEN
                          RUN RodaJavaScript('top.frcod.FechaZoom();').
                     ELSE
                          RUN RodaJavaScript('FechaZoom();').
                          
                     RUN RodaJavaScript('CarregaPrincipal();'). 
                      
                     IF   GET-VALUE("LinkRowid") = ""   THEN
                          DO:
                             RUN RodaJavaScript('LimparCampos();').
                             RUN RodaJavaScript('Incluir();').
                          END.

                     RUN RodaJavaScript('dsjustif = "' + ab_unmap.aux_dsjustif + '";').
                     
                     IF GET-VALUE("ValorCampo3") = "recurso" THEN
                        RUN RodaJavaScript("mostraDiv('divRecursoPA');").
                     
                  END. /* fim otherwise */                  
        END CASE. 
        
     END. /* fim do método GET */

/* Show error messages. */
IF   AnyMessage()   THEN 
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