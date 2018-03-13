/* ..................................................................................


   Programa: wpgd0034.p
   Sistema : PROGRID
                                             Ultima atualizacao: 30/10/2012

   Dados referentes ao programa:

   Frequencia: On-line.
   Objetivo  : Rodar a tela WPGD0034.
                                      
   Alteracoes: 26/09/2007 - Retirada a leitura da crapidp na procedure
                            CriaListaEventos porque não era necessária
                            (Evandro).
                            
               27/02/2008 - Não permitir atualizações quando o mês da Data Final do
                                        evento já estiver Fechado, E usuário não possuir
                            permissão de acesso 'U' (Diego).
                          - Melhoria de performance (alterada a paginacao, modo de
                            salvamento, lista de eventos) e inclusao da linha de
                            fim de listagem (Evandro).                                                  

               10/12/2008 - Melhoria de performance para a tabela gnapses (Evandro).
                           
                           17/11/2009 - Inicializar tela com o ano da agenda atual (Diego).
                           
                           05/06/2012 - Adaptação dos fontes para projeto Oracle. Alterado
                                                    busca na gnapses de CONTAINS para MATCHES (Guilherme Maba).

               30/12/2012 - Tratar reposition para evitar erros (Gabriel).

			   09/11/2016 - inclusao de LOG. (Jean Michel)

......................................................................... */

{ sistema/generico/includes/var_log_progrid.i }

&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
/* Connected Databases 
          banco            PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD aux_carregar AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_cdagenci AS CHARACTER 
       FIELD aux_cdcooper AS CHARACTER 
       FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_contador AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dtanoage AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_flgalter AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lsconsel AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lsevesel AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nrseqeve AS CHARACTER 
       FIELD aux_regfimls AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_reginils AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
       FIELD cdagenci AS CHARACTER FORMAT "X(256)":U 
       FIELD nrseqeve AS CHARACTER FORMAT "X(256)":U 
           FIELD aux_fechamen AS CHARACTER FORMAT "X(256)":U.

DEFINE TEMP-TABLE tt_eventos NO-UNDO
       FIELD idevento LIKE crapeap.idevento
       FIELD cdcooper LIKE crapeap.cdcooper
       FIELD cdagenci LIKE crapeap.cdagenci
       FIELD dtanoage LIKE crapeap.dtanoage
       FIELD cdevento LIKE crapedp.cdevento
       FIELD nmevento LIKE crapedp.nmevento
       FIELD nrseqdig LIKE crapadp.nrseqdig
       FIELD tppartic LIKE crapedp.tppartic
       FIELD flgcompr LIKE crapedp.flgcompr
       FIELD qtmaxtur LIKE crapedp.qtmaxtur
       FIELD dtinieve LIKE crapadp.dtinieve
           FIELD dtfineve LIKE crapadp.dtfineve
       FIELD nrmeseve LIKE crapadp.nrmeseve
       FIELD dshoreve LIKE crapadp.dshroeve
       FIELD idstaeve LIKE crapadp.idstaeve.






&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w-html 
/*----------------------------------------------------------------------*/
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
DEFINE VARIABLE ProgramaEmUso         AS CHARACTER INITIAL ["wpgd0034"].
DEFINE VARIABLE NmeDoPrograma         AS CHARACTER INITIAL ["wpgd0034.w"].

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

DEFINE VARIABLE vetorpac              AS CHAR                           NO-UNDO.
DEFINE VARIABLE vetorevento           AS CHAR                           NO-UNDO.
DEFINE VARIABLE vetorinscri           AS CHAR                           NO-UNDO.
                                                                        
DEFINE VARIABLE aux_crapcop           AS CHAR                           NO-UNDO.

DEFINE VARIABLE vetormes              AS CHAR EXTENT 12
    INITIAL ["Janeiro","Fevereiro","Março","Abril","Maio","Junho",
             "Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"].


/*** Declaração de BOs ***/
DEFINE VARIABLE h-b1wpgd0009          AS HANDLE                         NO-UNDO.

/*** Temp Tables ***/
DEFINE TEMP-TABLE cratidp NO-UNDO    LIKE crapidp.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE fontes/wpgd0034.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS crapidp.idevento 
&Scoped-define ENABLED-TABLES crapidp ab_unmap
&Scoped-define FIRST-ENABLED-TABLE ab_unmap
&Scoped-define SECOND-ENABLED-TABLE crapidp
&Scoped-Define ENABLED-OBJECTS ab_unmap.aux_cdagenci ab_unmap.aux_cdcooper ab_unmap.aux_cddopcao ab_unmap.aux_dsendurl ab_unmap.aux_dsretorn ab_unmap.aux_dtanoage ab_unmap.aux_idevento ab_unmap.aux_lsconsel ab_unmap.aux_lsevesel ab_unmap.aux_lspermis ab_unmap.aux_nrdrowid ab_unmap.aux_nrseqeve ab_unmap.nrseqeve ab_unmap.aux_stdopcao ab_unmap.cdagenci ab_unmap.aux_carregar ab_unmap.aux_reginils ab_unmap.aux_regfimls ab_unmap.aux_flgalter ab_unmap.aux_contador ab_unmap.aux_fechamen 
&Scoped-Define DISPLAYED-FIELDS crapidp.idevento 
&Scoped-define DISPLAYED-TABLES crapidp ab_unmap
&Scoped-define FIRST-DISPLAYED-TABLE crapidp
&Scoped-define SECOND-DISPLAYED-TABLE ab_unmap
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.aux_cdagenci ab_unmap.aux_cdcooper ab_unmap.aux_cddopcao ab_unmap.aux_dsendurl ab_unmap.aux_dsretorn ab_unmap.aux_dtanoage ab_unmap.aux_idevento ab_unmap.aux_lsconsel ab_unmap.aux_lsevesel ab_unmap.aux_lspermis ab_unmap.aux_nrdrowid ab_unmap.aux_nrseqeve ab_unmap.nrseqeve ab_unmap.aux_stdopcao ab_unmap.cdagenci ab_unmap.aux_carregar ab_unmap.aux_reginils ab_unmap.aux_regfimls ab_unmap.aux_flgalter ab_unmap.aux_contador ab_unmap.aux_fechamen

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     crapidp.idevento AT ROW 1 COL 1 NO-LABEL
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
     ab_unmap.aux_dtanoage AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_idevento AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_lsconsel AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_lsevesel AT ROW 1 COL 1 HELP
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
     ab_unmap.aux_nrseqeve AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.nrseqeve AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_stdopcao AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.cdagenci AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_carregar AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_reginils AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_regfimls AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_flgalter AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_contador AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
         ab_unmap.aux_fechamen AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
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
          FIELD aux_carregar AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_cdagenci AS CHARACTER 
          FIELD aux_cdcooper AS CHARACTER 
          FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_contador AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dtanoage AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_flgalter AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lsconsel AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lsevesel AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nrseqeve AS CHARACTER 
          FIELD aux_regfimls AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_reginils AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
          FIELD cdagenci AS CHARACTER FORMAT "X(256)":U 
          FIELD nrseqeve AS CHARACTER FORMAT "X(256)":U 
                  FIELD aux_fechamen AS CHARACTER FORMAT "X(256)":U
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
/* SETTINGS FOR FILL-IN ab_unmap.aux_carregar IN FRAME Web-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_cdagenci IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_cdcooper IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN ab_unmap.aux_cddopcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_contador IN FRAME Web-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dsendurl IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dsretorn IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dtanoage IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_flgalter IN FRAME Web-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN ab_unmap.aux_idevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lsconsel IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lsevesel IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lspermis IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nrdrowid IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_nrseqeve IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN ab_unmap.aux_regfimls IN FRAME Web-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN ab_unmap.aux_reginils IN FRAME Web-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN ab_unmap.aux_stdopcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.cdagenci IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN crapidp.idevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN ab_unmap.nrseqeve IN FRAME Web-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN ab_unmap.aux_fechamen IN FRAME Web-Frame
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaEventos w-html 
PROCEDURE CriaListaEventos :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE aux_tppartic AS CHAR      NO-UNDO.
    DEFINE VARIABLE aux_flgcompr AS CHAR      NO-UNDO.
    DEFINE VARIABLE aux_qtmaxtur AS CHAR      NO-UNDO.
    DEFINE VARIABLE aux_nrinscri AS INT       NO-UNDO.
    DEFINE VARIABLE aux_nrconfir AS INT       NO-UNDO.
    DEFINE VARIABLE aux_nrseqeve AS INT       NO-UNDO.
    DEFINE VARIABLE aux_nrdturma AS INT       NO-UNDO.
    DEFINE VARIABLE aux_nmevento AS CHAR      NO-UNDO.
    DEFINE VARIABLE txtHorario   AS CHARACTER.
    DEFINE VARIABLE txtPeriodo   AS CHARACTER.
    DEFINE VARIABLE mes          AS CHARACTER INITIAL ["janeiro,fevereiro,março,abril,maio,junho,julho,agosto,setembro,outubro,novembro,dezembro"].
        DEFINE VARIABLE aux_fechamen AS CHAR NO-UNDO.
        DEFINE VARIABLE aux_contador AS INTEGER.


   /* PROGRID ou ASSEMBLEIA com PAC especifico */
   IF   INT(ab_unmap.cdagenci) <> 0   THEN
        FOR EACH crapeap WHERE crapeap.idevento = INT(ab_unmap.aux_idevento)   AND
                               crapeap.cdcooper = INT(ab_unmap.aux_cdcooper)   AND
                               crapeap.cdagenci = INT(ab_unmap.cdagenci)       AND
                               crapeap.dtanoage = INT(ab_unmap.aux_dtanoage)   AND
                               crapeap.flgevsel = YES
                               NO-LOCK:

            RUN cria_tt_eventos.
        END.
   ELSE
   /* Assembléia - PAC TODOS */
   IF   INT(ab_unmap.aux_idevento) = 2   AND
        INT(ab_unmap.cdagenci)     = 0   THEN
        FOR EACH crapeap WHERE crapeap.idevento = INT(ab_unmap.aux_idevento)   AND
                               crapeap.cdcooper = INT(ab_unmap.aux_cdcooper)   AND
                               crapeap.dtanoage = INT(ab_unmap.aux_dtanoage)   AND
                               crapeap.flgevsel = YES
                               NO-LOCK:

            RUN cria_tt_eventos.
        END.

   FIND FIRST craptab WHERE craptab.cdcooper = 0               AND 
                            craptab.nmsistem = "CRED"          AND
                            craptab.tptabela = "CONFIG"        AND
                            craptab.cdempres = 0               AND
                            craptab.cdacesso = "PGTPPARTIC"    AND
                            craptab.tpregist = 0               NO-LOCK NO-ERROR.


   FOR EACH tt_eventos NO-LOCK BREAK BY tt_eventos.cdagenci
                                       BY tt_eventos.nmevento
                                          BY tt_eventos.nrseqdig:

        IF   AVAILABLE craptab   THEN
             ASSIGN aux_tppartic = ENTRY(LOOKUP(STRING(tt_eventos.tppartic), craptab.dstextab) - 1, craptab.dstextab).

        IF   aux_tppartic = ?   THEN
             aux_tppartic = "".
        
        IF   tt_eventos.flgcompr = TRUE   THEN
             aux_flgcompr = "TERMO DE COMPROMISSO".
        ELSE
             aux_flgcompr = "".
    
        IF   tt_eventos.qtmaxtur <> ?   THEN
             ASSIGN aux_qtmaxtur = STRING(tt_eventos.qtmaxtur).
        ELSE
             ASSIGN aux_qtmaxtur = "0".
               
        ASSIGN aux_nrinscri = 0
               aux_nrconfir = 0
               aux_nrseqeve = IF tt_eventos.nrseqdig <> ? THEN
                                 tt_eventos.nrseqdig
                              ELSE 0
               aux_nmevento = tt_eventos.nmevento.
    
        IF   tt_eventos.dtinieve <> ?   THEN
             aux_nmevento = aux_nmevento + " - " + STRING(tt_eventos.dtinieve,"99/99/9999").
        ELSE
        IF   tt_eventos.nrmeseve <> 0   AND
             tt_eventos.nrmeseve <> ?   THEN
             aux_nmevento = aux_nmevento + " - " + vetormes[tt_eventos.nrmeseve].
    
        IF   tt_eventos.dshoreve <> ""   THEN
             aux_nmevento = aux_nmevento + " - " + tt_eventos.dshoreve.
        
            ASSIGN aux_fechamen = "Não".  
                DO  aux_contador = 1 TO NUM-ENTRIES(gnpapgd.lsmesctb):

            IF   INT(ENTRY(aux_contador,gnpapgd.lsmesctb)) = MONTH(tt_eventos.dtfineve)  THEN
                 DO:
                             ASSIGN aux_fechamen = "Sim".
                                 LEAVE.
                         END.
                END.

        IF   vetorevento = ""   THEN
             vetorevento = "~{" +
                           "cdagenci:'" +  STRING(tt_eventos.cdagenci) + "'," + 
                           "cdcooper:'" +  STRING(tt_eventos.cdcooper) + "'," +
                           "cdevento:'" +  STRING(tt_eventos.cdevento) + "'," +
                           "nmevento:'" +  STRING(aux_nmevento)     + "'," +
                           "idstaeve:'" +  STRING(tt_eventos.idstaeve) + "'," +
                           "flgcompr:'" +  STRING(aux_flgcompr)     + "'," +
                           "qtmaxtur:'" +  STRING(aux_qtmaxtur)     + "'," +
                           "nrseqeve:'" +  STRING(aux_nrseqeve)     + "'," +
                           "txtperio:'" +  STRING(txtPeriodo)       + "'," +
                           "txthorar:'" +  STRING(txtHorario)       + "'," +
                           "tppartic:'" +  STRING(aux_tppartic)     + "'," +
                                                   "fechamen:'" +  STRING(aux_fechamen) + "'" + "~}".
        ELSE
             vetorevento = vetorevento + "," + "~{" +
                           "cdagenci:'" +  STRING(tt_eventos.cdagenci) + "'," + 
                           "cdcooper:'" +  STRING(tt_eventos.cdcooper) + "'," +
                           "cdevento:'" +  STRING(tt_eventos.cdevento) + "'," +
                           "nmevento:'" +  STRING(aux_nmevento)     + "'," +
                           "idstaeve:'" +  STRING(tt_eventos.idstaeve) + "'," +
                           "flgcompr:'" +  STRING(aux_flgcompr)     + "'," +
                           "qtmaxtur:'" +  STRING(aux_qtmaxtur)     + "'," +
                           "nrseqeve:'" +  STRING(aux_nrseqeve)     + "'," +
                           "txtperio:'" +  STRING(txtPeriodo)       + "'," +
                           "txthorar:'" +  STRING(txtHorario)       + "'," +
                           "tppartic:'" +  STRING(aux_tppartic)     + "'," +
                                                   "fechamen:'" +  STRING(aux_fechamen) + "'" + "~}".
    END.
    
    RUN RodaJavaScript("var mevento=new Array();mevento=["  + vetorevento + "]").

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cria_tt_eventos w-html 
PROCEDURE cria_tt_eventos:
                
    FIND crapedp WHERE crapedp.cdevento = crapeap.cdevento   AND
                       crapedp.idevento = crapeap.idevento   AND
                       crapedp.cdcooper = crapeap.cdcooper   AND
                       crapedp.dtanoage = crapeap.dtanoage
                       NO-LOCK NO-ERROR.

    FOR EACH crapadp WHERE crapadp.idevento = crapeap.idevento   AND
                           crapadp.cdcooper = crapeap.cdcooper   AND
                           crapadp.cdagenci = crapeap.cdagenci   AND
                           crapadp.dtanoage = crapeap.dtanoage   AND
                           crapadp.cdevento = crapeap.cdevento
                           NO-LOCK:

        CREATE tt_eventos.
        ASSIGN tt_eventos.idevento = crapeap.idevento
               tt_eventos.cdcooper = crapeap.cdcooper
               tt_eventos.cdagenci = crapeap.cdagenci
               tt_eventos.dtanoage = crapeap.dtanoage
               tt_eventos.cdevento = crapedp.cdevento
               tt_eventos.nmevento = crapedp.nmevento
               tt_eventos.nrseqdig = crapadp.nrseqdig
               tt_eventos.tppartic = crapedp.tppartic
               tt_eventos.flgcompr = crapedp.flgcompr
               tt_eventos.qtmaxtur = crapedp.qtmaxtur
               tt_eventos.dtinieve = crapadp.dtinieve
                           tt_eventos.dtfineve = crapadp.dtfineve
               tt_eventos.nrmeseve = crapadp.nrmeseve
               tt_eventos.dshoreve = crapadp.dshroeve
               tt_eventos.idstaeve = crapadp.idstaeve.
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaInscritos w-html 
PROCEDURE CriaListaInscritos :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEF VAR aux_nmextttl AS CHAR                        NO-UNDO.
    DEF VAR aux_qtstinsc AS CHAR                        NO-UNDO.
    DEF VAR aux_dtconins AS CHAR                        NO-UNDO.
    DEF VAR aux_cdgraupr AS CHAR                        NO-UNDO.
    DEF VAR aux_nmresage AS CHAR                        NO-UNDO.
    DEF VAR vetorstatus  AS CHAR                        NO-UNDO.
    DEF VAR i            AS INT                         NO-UNDO.

    DEF VAR aux_qtpagina AS INT  INIT 100               NO-UNDO.
    DEF VAR aux_dados    AS CHAR                        NO-UNDO.
    DEF VAR aux_qtregist AS INT  INIT 0                 NO-UNDO.

    DEF QUERY q_inscritos FOR crapidp SCROLLING.

    /* PROGRID ou ASSEMBLEIA com PAC especifico */
    IF   INT(ab_unmap.cdagenci) <> 0   THEN
         OPEN QUERY q_inscritos FOR EACH crapidp WHERE crapidp.idevento = INT(ab_unmap.aux_idevento)   AND
                                                       crapidp.cdcooper = INT(ab_unmap.aux_cdcooper)   AND
                                                       crapidp.cdagenci = INT(ab_unmap.cdagenci)       AND
                                                       crapidp.nrseqeve = INT(ab_unmap.nrseqeve)       AND
                                                       crapidp.dtanoage = INT(ab_unmap.aux_dtanoage)   AND
                                                       crapidp.IdStaIns = 2
                                                       NO-LOCK USE-INDEX crapidp5 INDEXED-REPOSITION MAX-ROWS aux_qtpagina.
    ELSE
    /* Assembléia - PAC TODOS */
    IF   INT(ab_unmap.aux_idevento)  = 2   AND
         INT(ab_unmap.cdagenci)      = 0   AND
         INT(ab_unmap.nrseqeve)     <> 0   THEN
         OPEN QUERY q_inscritos FOR EACH crapidp WHERE crapidp.idevento = INT(ab_unmap.aux_idevento)   AND
                                                       crapidp.cdcooper = INT(ab_unmap.aux_cdcooper)   AND
                                                       crapidp.nrseqeve = INT(ab_unmap.nrseqeve)       AND
                                                       crapidp.dtanoage = INT(ab_unmap.aux_dtanoage)   AND
                                                       crapidp.IdStaIns = 2
                                                       NO-LOCK USE-INDEX crapidp5 INDEXED-REPOSITION MAX-ROWS aux_qtpagina.
    

    IF   ab_unmap.aux_carregar = "proximos"   THEN
         DO:
            REPOSITION q_inscritos TO ROWID TO-ROWID(ab_unmap.aux_regfimls)
                                                         NO-ERROR.
            REPOSITION q_inscritos FORWARDS aux_qtpagina NO-ERROR.
            REPOSITION q_inscritos TO ROWID TO-ROWID(ab_unmap.aux_regfimls)
                                                         NO-ERROR.

            /* O primeiro registro se repete */
            ab_unmap.aux_contador = STRING(INT(ab_unmap.aux_contador) - 1).
         END.
    ELSE
    IF   ab_unmap.aux_carregar = "anteriores"   THEN
         DO:
            REPOSITION q_inscritos TO ROWID TO-ROWID(ab_unmap.aux_reginils)
                                                         NO-ERROR.
            REPOSITION q_inscritos BACKWARDS aux_qtpagina - 1
                                                         NO-ERROR.
            
            /* Diminui a quantidade para pagina anterior */
            ab_unmap.aux_contador = STRING(INT(ab_unmap.aux_contador) - 
                                            aux_qtpagina).
            
            IF   INT(ab_unmap.aux_contador) < 0   THEN
                 ab_unmap.aux_contador = "0".
         END.

    /* Verifica se a Query abriu */
    IF   NUM-RESULTS("q_inscritos") <> ?   THEN
         DO aux_qtregist = 1 TO aux_qtpagina:
         
            GET NEXT q_inscritos.
            
            IF   AVAILABLE crapidp   THEN
                 DO:
                    IF   aux_qtregist = 1   THEN
                         ab_unmap.aux_reginils = STRING(CURRENT-RESULT-ROW("q_inscritos")).
         
                    ASSIGN ab_unmap.aux_contador = STRING(INT(ab_unmap.aux_contador) + 1)
         
                           ab_unmap.aux_regfimls = STRING(ROWID(crapidp)).
         
                           aux_dados = "~{" +
                                       "numeroch:'" + STRING(INT(ab_unmap.aux_contador),"z999") + "'," +
                                       "nminseve:'" + REPLACE(crapidp.nminseve,"'","´")         + "'," +
                                       "nrdconta:'" + STRING(crapidp.nrdconta)                  + "'," +
                                       "cdageins:'" + STRING(crapidp.cdageins)                  + "'," +
                                       "cdcooper:'" + STRING(crapidp.cdcooper)                  + "'," +
                                       "nrseqeve:'" + STRING(crapidp.nrseqeve)                  + "'," +
                                       "qtfaleve:'" + STRING(crapidp.qtfaleve)                  + "'," +
                                       "nrdrowid:'" + STRING(ROWID(crapidp))                    + "'"  + "~}".
         
                    IF  vetorinscri = '' THEN
                        vetorinscri = aux_dados.
                    ELSE
                        vetorinscri = vetorinscri + ',' + aux_dados.
                 END.
         END.

    CLOSE QUERY q_inscritos.

    FIND FIRST craptab WHERE craptab.cdcooper = 0               AND
                             craptab.nmsistem = "CRED"          AND
                             craptab.tptabela = "CONFIG"        AND    
                             craptab.cdempres = 0               AND  
                             craptab.cdacesso = "PGSTINSCRI"    AND  
                             craptab.tpregist = 0               NO-LOCK NO-ERROR.
    
    DO i = 1 TO (NUM-ENTRIES(craptab.dstextab) / 2):
        IF  vetorstatus = "" THEN
            vetorstatus = "~{" +
                "dsstatus:'" + ENTRY(2 * i - 1,craptab.dstextab) + "'," +
                "cdstatus:'" + ENTRY(2 * i,craptab.dstextab) + "'" + "~}".
        ELSE
            vetorstatus = vetorstatus + "," + "~{" +
                "dsstatus:'" + ENTRY(2 * i - 1,craptab.dstextab) + "'," +
                "cdstatus:'" + ENTRY(2 * i,craptab.dstextab) + "'" + "~}".
    END.
    
    RUN RodaJavaScript("var mstatus=new Array();mstatus=["  + vetorstatus + "]").
    
    RUN RodaJavaScript("var minscri=new Array();minscri=["  + vetorinscri + "]").

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
    DEFINE VARIABLE aux_flgfirst AS LOGICAL    INIT TRUE NO-UNDO.

         /* PROGRID */
    IF   INT(ab_unmap.aux_idevento) = 1   THEN
         DO:
            /* gera lista de pac's */
            {includes/wpgd0099.i ab_unmap.aux_dtanoage}
         END.
    ELSE
         /* ASSEMBLEIAS */
         DO:
            /* gera lista de pac's nao agrupados */
            { includes/wpgd0097.i }

            vetorpac = "~{" + "cdcooper:" + "'" + ab_unmap.aux_cdcooper
                         + "',cdagenci:"  + "'" + "0"
                         + "',nmresage:"  + "'" + "TODOS" + "'~}" 
                         + "," + vetorpac.
                                                 
         END.

    /* Cria o array com os pacs */
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
    ("aux_carregar":U,"ab_unmap.aux_carregar":U,ab_unmap.aux_carregar:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdagenci":U,"ab_unmap.aux_cdagenci":U,ab_unmap.aux_cdagenci:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdcooper":U,"ab_unmap.aux_cdcooper":U,ab_unmap.aux_cdcooper:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cddopcao":U,"ab_unmap.aux_cddopcao":U,ab_unmap.aux_cddopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_contador":U,"ab_unmap.aux_contador":U,ab_unmap.aux_contador:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsendurl":U,"ab_unmap.aux_dsendurl":U,ab_unmap.aux_dsendurl:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsretorn":U,"ab_unmap.aux_dsretorn":U,ab_unmap.aux_dsretorn:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dtanoage":U,"ab_unmap.aux_dtanoage":U,ab_unmap.aux_dtanoage:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_flgalter":U,"ab_unmap.aux_flgalter":U,ab_unmap.aux_flgalter:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idevento":U,"ab_unmap.aux_idevento":U,ab_unmap.aux_idevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lsconsel":U,"ab_unmap.aux_lsconsel":U,ab_unmap.aux_lsconsel:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lsevesel":U,"ab_unmap.aux_lsevesel":U,ab_unmap.aux_lsevesel:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lspermis":U,"ab_unmap.aux_lspermis":U,ab_unmap.aux_lspermis:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrdrowid":U,"ab_unmap.aux_nrdrowid":U,ab_unmap.aux_nrdrowid:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrseqeve":U,"ab_unmap.aux_nrseqeve":U,ab_unmap.aux_nrseqeve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_regfimls":U,"ab_unmap.aux_regfimls":U,ab_unmap.aux_regfimls:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_reginils":U,"ab_unmap.aux_reginils":U,ab_unmap.aux_reginils:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_stdopcao":U,"ab_unmap.aux_stdopcao":U,ab_unmap.aux_stdopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("cdagenci":U,"ab_unmap.cdagenci":U,ab_unmap.cdagenci:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("idevento":U,"crapidp.idevento":U,crapidp.idevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nrseqeve":U,"ab_unmap.nrseqeve":U,ab_unmap.nrseqeve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_fechamen":U,"ab_unmap.aux_fechamen":U,ab_unmap.aux_fechamen:HANDLE IN FRAME {&FRAME-NAME}).
END PROCEDURE.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-assign-record w-html 
PROCEDURE local-assign-record :
DEFINE INPUT PARAMETER opcao AS CHARACTER.
    
    DEFINE VARIABLE tmp_cdevento AS INT                NO-UNDO.
    DEFINE VARIABLE tmp_cdagenci LIKE crapidp.cdagenci NO-UNDO.
    
    DEFINE VARIABLE conta        AS INTEGER.
    DEFINE VARIABLE valor        AS INTEGER.
    
    
    /* Instancia a BO para executar as procedures */
    RUN dbo/b1wpgd0009.p PERSISTENT SET h-b1wpgd0009.
    
    /*RUN RodaJavaScript("alert('" + ab_unmap.aux_cdagenci + "');").*/
    
    /* Se BO foi instanciada */
    IF VALID-HANDLE(h-b1wpgd0009) THEN
       DO:
          DO WITH FRAME {&FRAME-NAME}:
             IF opcao = "inclusao" THEN .
                /*Não tem inclusão*/
             ELSE  /* alteracao */
                DO:
                    conta = INT(ab_unmap.aux_contador).

                    DO WHILE TRUE:

                        FIND crapidp WHERE ROWID(crapidp) = TO-ROWID(GET-VALUE("nrdrowid" + STRING(conta,"z999")))
                                           NO-LOCK NO-ERROR.

                        IF   NOT AVAILABLE crapidp                              OR
                             GET-VALUE("nrdrowid" + STRING(conta,"z999")) = ""   THEN
                             LEAVE.

                        /* cria a temp-table e joga o novo valor digitado para o campo */
                        EMPTY TEMP-TABLE cratidp.

                        CREATE cratidp.
                        BUFFER-COPY crapidp TO cratidp.

                        ASSIGN valor = INTEGER(GET-VALUE("qtfaleve" + STRING(conta,"z999"))) NO-ERROR.

                        IF NOT ERROR-STATUS:ERROR THEN 
                           ASSIGN Cratidp.QtFalEve = valor.

                        RUN altera-registro IN h-b1wpgd0009(INPUT TABLE cratidp, OUTPUT msg-erro).

                        /* Incrementa conforme a direcao escolhida */
                        IF   ab_unmap.aux_carregar = "anteriores"   THEN
                             conta = conta + 1.
                        ELSE
                             conta = conta - 1.
                    END.
                END.    
          END. /* DO WITH FRAME {&FRAME-NAME} */
       
          /* "mata" a instância da BO */
          DELETE PROCEDURE h-b1wpgd0009 NO-ERROR.
       
       END. /* IF VALID-HANDLE(h-b1wpgd0009) */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-delete-record w-html 
PROCEDURE local-delete-record :
/*
    /* Instancia a BO para executar as procedures */
    RUN dbo/b1wpgdXXXX.p PERSISTENT SET h-b1wpgdXXXX.
     
    /* Se BO foi instanciada */
    IF VALID-HANDLE(h-b1wpgdXXXX) THEN
       DO:
          CREATE cratxxx.
          BUFFER-COPY crapxxx TO cratxxx.
              
          RUN exclui-registro IN h-b1wpgdXXXX(INPUT TABLE cratxxx, OUTPUT msg-erro).
    
          /* "mata" a instância da BO */
          DELETE PROCEDURE h-b1wpgdXXXX NO-ERROR.
       END.
    */
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
-------------------------------------------------------------------------------*/

v-identificacao = get-cookie("cookie-usuario-em-uso").

/* Usado FOR EACH para poder utilizar o CONTAINS e WORD-INDEX, alterado para MATCHES */
FOR EACH gnapses WHERE gnapses.idsessao MATCHES "*" + v-identificacao + "*" NO-LOCK:
    LEAVE.
END.
  
ASSIGN opcao                    = GET-VALUE("aux_cddopcao")
       FlagPermissoes           = GET-VALUE("aux_lspermis")
       msg-erro-aux             = 0
       ab_unmap.aux_idevento    = GET-VALUE("aux_idevento")
       ab_unmap.aux_cdcooper    = GET-VALUE("aux_cdcooper") 
       ab_unmap.aux_dtanoage    = GET-VALUE("aux_dtanoage")
       ab_unmap.cdagenci        = GET-VALUE("cdagenci")
       ab_unmap.nrseqeve        = GET-VALUE("nrseqeve")
       ab_unmap.aux_dsendurl    = AppURL                        
       ab_unmap.aux_lspermis    = FlagPermissoes                
       ab_unmap.aux_nrdrowid    = GET-VALUE("aux_nrdrowid")         
       ab_unmap.aux_stdopcao    = GET-VALUE("aux_stdopcao")
       ab_unmap.aux_carregar    = GET-VALUE("aux_carregar")
       ab_unmap.aux_reginils    = GET-VALUE("aux_reginils")
       ab_unmap.aux_regfimls    = GET-VALUE("aux_regfimls")
       ab_unmap.aux_contador    = GET-VALUE("aux_contador").

RUN outputHeader.

/* gera lista de cooperativas */
{includes/wpgd0098.i}.
ab_unmap.aux_cdcooper:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = aux_crapcop.

/* Se a cooperativa ainda não foi escolhida, pega a da sessão do usuário */
IF   INT(ab_unmap.aux_cdcooper) = 0   THEN
     ab_unmap.aux_cdcooper = STRING(gnapses.cdcooper).

/* Se o PAC ainda não foi escolhido, pega o da sessão do usuário */  
IF   ab_unmap.cdagenci = " "   THEN
     ab_unmap.cdagenci = STRING(gnapses.cdagenci).

ASSIGN ab_unmap.aux_stdopcao = STRING(ab_unmap.nrseqeve).

/* rotina para buscar o registro de parametro correto */
FIND LAST gnpapgd WHERE gnpapgd.idevento =  INT(ab_unmap.aux_idevento) AND 
                        gnpapgd.cdcooper =  INT(ab_unmap.aux_cdcooper) AND 
                        gnpapgd.dtanonov =  INT(ab_unmap.aux_dtanoage) NO-LOCK NO-ERROR.


IF NOT AVAILABLE gnpapgd THEN
   DO:
      IF ab_unmap.aux_dtanoage <> ""   
         THEN
             DO:
                RUN RodaJavaScript("alert('Nao existe agenda para o ano (" + ab_unmap.aux_dtanoage + ") informado!');").
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
       
RUN insere_log_progrid("WPGD0034.w",STRING(opcao) + "|" + STRING(ab_unmap.aux_idevento) + "|" +
					  STRING(ab_unmap.aux_cdcooper) + "|" + STRING(ab_unmap.aux_dtanoage) + "|" +
					  STRING(ab_unmap.cdagenci) + "|" + STRING(ab_unmap.nrseqeve)).
					         
/* método POST */
IF REQUEST_METHOD = "POST":U THEN 
   DO:            
       RUN inputFields.
      
      /* Instancia a BO para executar as procedures */
       RUN dbo/b1wpgd0009.p PERSISTENT SET h-b1wpgd0009. 
       
      /* Se BO foi instanciada */
      IF VALID-HANDLE(h-b1wpgd0009) THEN
         DO:
            RUN posiciona-registro IN h-b1wpgd0009(INPUT TO-ROWID(ab_unmap.aux_nrdrowid), OUTPUT msg-erro).
            DELETE PROCEDURE h-b1wpgd0009 NO-ERROR.
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
                             /*
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
                            ELSE */  
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

      RUN CriaListaPac.
      RUN CriaListaEventos. 
      RUN CriaListaInscritos. 

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


                    RUN CriaListaPac.
                    RUN CriaListaEventos. 
                    RUN CriaListaInscritos. 


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

