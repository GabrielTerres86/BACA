/*...............................................................................

Alterações: 30/01/2008 - Verificar pré-inscritos no evento antes de efetuar a exclusão (Diego).

            10/12/2008 - Melhoria de performance para a tabela gnapses (Evandro).
            
            04/05/2009 - Utilizar cdcooper = 0 nas consultas (David).
            
            05/01/2010 - Corrigida ortografia da mensagem de erro na exclusão 
                         de evento (Elton).

            09/03/2011 - Tratamento estouro do vetor de eventos (Guilherme/Supero).
			
			05/06/2012 - Adaptação dos fontes para projeto Oracle. Alterado
						 busca na gnapses de CONTAINS para MATCHES (Guilherme Maba).
                         
            06/06/2016 - Ajuste para não exibir os eventos EAD (TPEVENTO= 11) (Vanessa)
...............................................................................*/

&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
/* Connected Databases 
          banco            PROGRESS
*/

&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD aux_cdcooper AS CHARACTER 
       FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_cdevento AS CHARACTER 
       FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dtanoage AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lsagenci AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lsdteven AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lshreven AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lsseqdig AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
       FIELD cdevento AS CHARACTER FORMAT "X(256)":U .


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
DEFINE VARIABLE ProgramaEmUso AS CHARACTER INITIAL ["wpgd0023"].
DEFINE VARIABLE NmeDoPrograma AS CHARACTER INITIAL ["wpgd0023.w"].

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
DEFINE VARIABLE h-b1wpgd0014b         AS HANDLE                         NO-UNDO.
DEFINE VARIABLE h-b1wpgd0014a         AS HANDLE                         NO-UNDO.

/*** Temp Tables ***/
DEFINE TEMP-TABLE cratadp             LIKE crapadp.
DEFINE TEMP-TABLE cratedp             LIKE crapedp.
DEFINE TEMP-TABLE crateap             LIKE crapeap.

/* Para os Eventos */
DEFINE VARIABLE vetoreventos1         AS CHARACTER FORMAT "X(2000)"     NO-UNDO.
DEFINE VARIABLE vetoreventos2         AS CHARACTER FORMAT "X(2000)"     NO-UNDO.

DEFINE VARIABLE aux_crapcop AS CHAR NO-UNDO.

DEFINE VARIABLE vetorevcoop AS CHAR NO-UNDO.
DEFINE VARIABLE vetorevento AS CHAR NO-UNDO.

DEFINE TEMP-TABLE ttevento
    FIELD cdagenci AS CHAR 
    FIELD cdcooper AS CHAR
    FIELD cdevento AS CHAR
    FIELD nmevento AS CHAR 
    FIELD tpevento AS CHAR
    FIELD nmresage AS CHAR
    FIELD idpropos AS CHAR
    FIELD idevento AS CHAR
    FIELD tppartic AS CHAR
    FIELD dtevento AS CHAR
    FIELD dslocali AS CHAR
    FIELD qtmaxtur AS CHAR
    FIELD qtmintur AS CHAR
    FIELD nrinscri AS CHAR
    FIELD idstaeve AS CHAR
    FIELD enlocali AS CHAR
    FIELD hrevento AS CHAR
    FIELD nrseqdig AS CHAR
    FIELD nrconfir AS CHAR.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE fontes/wpgd0023.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS crapeap.cdagenci crapeap.dtanoage 
&Scoped-define ENABLED-TABLES ab_unmap crapeap
&Scoped-define FIRST-ENABLED-TABLE ab_unmap
&Scoped-define SECOND-ENABLED-TABLE crapeap
&Scoped-Define ENABLED-OBJECTS ab_unmap.cdevento ab_unmap.aux_lsseqdig ~
ab_unmap.aux_lsagenci ab_unmap.aux_lsdteven ab_unmap.aux_lshreven ~
ab_unmap.aux_cdevento ab_unmap.aux_cdcooper ab_unmap.aux_cddopcao ~
ab_unmap.aux_dsendurl ab_unmap.aux_dsretorn ab_unmap.aux_dtanoage ~
ab_unmap.aux_idevento ab_unmap.aux_lspermis ab_unmap.aux_nrdrowid ~
ab_unmap.aux_stdopcao 
&Scoped-Define DISPLAYED-FIELDS crapeap.cdagenci crapeap.dtanoage 
&Scoped-define DISPLAYED-TABLES ab_unmap crapeap
&Scoped-define FIRST-DISPLAYED-TABLE ab_unmap
&Scoped-define SECOND-DISPLAYED-TABLE crapeap
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.cdevento ab_unmap.aux_lsseqdig ~
ab_unmap.aux_lsagenci ab_unmap.aux_lsdteven ab_unmap.aux_lshreven ~
ab_unmap.aux_cdevento ab_unmap.aux_cdcooper ab_unmap.aux_cddopcao ~
ab_unmap.aux_dsendurl ab_unmap.aux_dsretorn ab_unmap.aux_dtanoage ~
ab_unmap.aux_idevento ab_unmap.aux_lspermis ab_unmap.aux_nrdrowid ~
ab_unmap.aux_stdopcao 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     ab_unmap.cdevento AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_lsseqdig AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_lsagenci AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_lsdteven AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_lshreven AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cdevento AT ROW 1 COL 1 HELP
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
     crapeap.cdagenci AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapeap.dtanoage AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 71.4 BY 18.57.


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
          FIELD aux_cdevento AS CHARACTER 
          FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dtanoage AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lsagenci AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lsdteven AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lshreven AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lsseqdig AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
          FIELD cdevento AS CHARACTER FORMAT "X(256)":U 
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW w-html ASSIGN
         HEIGHT             = 18.57
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
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_cdcooper IN FRAME Web-Frame
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
/* SETTINGS FOR FILL-IN ab_unmap.aux_lsagenci IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lsdteven IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lshreven IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lspermis IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lsseqdig IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nrdrowid IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_stdopcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN crapeap.cdagenci IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN ab_unmap.cdevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN crapeap.dtanoage IN FRAME Web-Frame
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaEvCoop w-html 
PROCEDURE CriaListaEvCoop :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    FOR EACH crapedp WHERE crapedp.idevento = INT(ab_unmap.aux_idevento)   AND
                           crapedp.cdcooper = INT(ab_unmap.aux_cdcooper)   AND
                           crapedp.dtanoage = INT(ab_unmap.aux_dtanoage)   AND 
                           crapedp.tpevento <> 11                         NO-LOCK
                           BY crapedp.nmevento:
    
        IF  vetorevcoop = "" THEN
            vetorevcoop = "~{" + 
                 "cdcooper:'" +  STRING(crapedp.cdcooper) + "'," +
                 "cdevento:'" +  STRING(crapedp.cdevento) + "'," +
                 "nmevento:'" +  STRING(crapedp.nmevento) + "'" + "~}".
        ELSE
            vetorevcoop = vetorevcoop + "," + "~{" +
                 "cdcooper:'" +  STRING(crapedp.cdcooper) + "'," +
                 "cdevento:'" +  STRING(crapedp.cdevento) + "'," +
                 "nmevento:'" +  STRING(crapedp.nmevento) + "'" + "~}".
    END.
    
    RUN RodaJavaScript("var mevcoop=new Array();mevcoop=["  + vetorevcoop + "]"). 

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaEvento w-html 
PROCEDURE CriaListaEvento :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEF VAR aux_tpevento AS CHAR NO-UNDO.
    DEF VAR aux_tppartic AS CHAR NO-UNDO.
    DEF VAR aux_nrinscri AS INT  NO-UNDO.
    DEF VAR aux_nrconfir AS INT  NO-UNDO.
    DEF VAR aux_idpropos AS CHAR NO-UNDO.
    DEF VAR aux_idevento AS CHAR NO-UNDO.
    DEF VAR aux_nmresage AS CHAR NO-UNDO.
    DEF VAR aux_dslocali AS CHAR NO-UNDO.
    DEF VAR aux_enlocali AS CHAR NO-UNDO.
    DEF VAR aux_idstaeve AS CHAR NO-UNDO.
    DEF VAR aux_dtevento AS CHAR NO-UNDO.
    DEF VAR aux_hrevento AS CHAR NO-UNDO.
    
    DEF VAR aux_contador AS INT         NO-UNDO.
    DEF VAR aux_conteudo AS CHAR        NO-UNDO.
    DEF VAR aux_nrovetor AS INT  INIT 1 NO-UNDO.
    
    DEFINE BUFFER bf-craptab FOR craptab.

    FOR EACH crapeap WHERE crapeap.idevento = INT(ab_unmap.aux_idevento)   AND
                           crapeap.cdcooper = INT(ab_unmap.aux_cdcooper)   AND
                           crapeap.dtanoage = INT(ab_unmap.aux_dtanoage)   NO-LOCK, 
       FIRST crapadp WHERE crapadp.idevento = crapeap.idevento             AND
                           crapadp.cdcooper = crapeap.cdcooper             AND
                           crapadp.cdagenci = crapeap.cdagenci             AND
                           crapadp.dtanoage = crapeap.dtanoage             AND
                           crapadp.cdevento = crapeap.cdevento             NO-LOCK,
       FIRST crapedp WHERE crapedp.cdevento = crapeap.cdevento             AND
                           crapedp.cdcooper = crapeap.cdcooper             AND
                           crapedp.dtanoage = crapeap.dtanoage             AND
                           crapedp.idevento = crapeap.idevento             AND
                           crapedp.tpevento <> 11                         NO-LOCK
                           BY crapadp.idstaeve
                              BY crapedp.nmevento:
    
        ASSIGN aux_nrinscri = 0
               aux_nrconfir = 0.
    
        aux_idevento = STRING(ROWID(crapedp)).
        
        FIND FIRST gnapetp WHERE gnapetp.cdcooper = 0                AND
                                 gnapetp.cdeixtem = crapedp.cdeixtem NO-LOCK NO-ERROR.
    
        IF NOT AVAIL gnapetp THEN NEXT.
        
        /* Descrição do tipo de evento */
        FIND FIRST bf-craptab WHERE bf-craptab.cdcooper = 0             AND
                                    bf-craptab.nmsistem = "CRED"        AND
                                    bf-craptab.tptabela = "CONFIG"      AND
                                    bf-craptab.cdempres = 0             AND
                                    bf-craptab.cdacesso = "PGTPEVENTO"  AND
                                    bf-craptab.tpregist = 0             NO-LOCK NO-ERROR.
        
        IF AVAILABLE craptab THEN
             ASSIGN aux_tpevento = ENTRY(LOOKUP(STRING(crapedp.tpevento), bf-craptab.dstextab) - 1, bf-craptab.dstextab).
        
        ASSIGN aux_tpevento = STRING(crapedp.tpevento).

        /* Descrição do tipo de participação permitida */
        FIND FIRST bf-craptab WHERE bf-craptab.cdcooper = 0             AND
                                    bf-craptab.nmsistem = "CRED"        AND
                                    bf-craptab.tptabela = "CONFIG"      AND
                                    bf-craptab.cdempres = 0             AND
                                    bf-craptab.cdacesso = "PGTPPARTIC"  AND
                                    bf-craptab.tpregist = 0             NO-LOCK NO-ERROR.
    
        IF AVAILABLE bf-craptab THEN
             ASSIGN aux_tppartic = ENTRY(LOOKUP(STRING(crapedp.tppartic), bf-craptab.dstextab) - 1, bf-craptab.dstextab).
    
        IF aux_tppartic = ? THEN aux_tppartic = "".
        
        /* Descrição do status do evento */
        FIND FIRST bf-craptab WHERE bf-craptab.cdcooper = 0             AND
                                    bf-craptab.nmsistem = "CRED"        AND
                                    bf-craptab.tptabela = "CONFIG"      AND
                                    bf-craptab.cdempres = 0             AND
                                    bf-craptab.cdacesso = "PGSTEVENTO"  AND
                                    bf-craptab.tpregist = 0             NO-LOCK NO-ERROR.
    
        IF AVAILABLE bf-craptab THEN
             ASSIGN aux_idstaeve = ENTRY(LOOKUP(STRING(crapadp.idstaeve), bf-craptab.dstextab) - 1, bf-craptab.dstextab).
    
        /* Nome do PAC */
        
        aux_nmresage = "".
        
        FIND FIRST crapage WHERE crapage.cdcooper = crapeap.cdcooper    AND
                                 crapage.cdagenci = crapeap.cdagenci    NO-LOCK NO-ERROR.
        
            IF AVAIL crapage THEN
            DO:
                IF  crapage.insitage <> 1 THEN NEXT.
                ELSE
                    ASSIGN aux_nmresage = crapage.nmresage.
            END.
            
        /* Local */
        FIND FIRST crapldp WHERE crapldp.nrseqdig = crapadp.cdlocali AND 
                                 crapldp.cdcooper = crapadp.cdcooper NO-LOCK NO-ERROR.
        IF NOT AVAIL crapldp THEN
            ASSIGN 
                aux_dslocali = ""
                aux_enlocali = "".
        ELSE
            ASSIGN 
                aux_dslocali = crapldp.dslocali
                aux_enlocali = crapldp.dsendloc.
    
        /* Data do Evento */
        IF crapadp.dtinieve = ? THEN
            aux_dtevento = "".
        ELSE
            aux_dtevento = STRING(crapadp.dtinieve, "99/99/9999").
    
        IF aux_dtevento = ? THEN aux_dtevento = "".
    
        /* Horário do Evento */
        IF crapadp.dshroeve = ? THEN
            aux_hrevento = "".
        ELSE
            aux_hrevento = STRING(crapadp.dshroeve).
        
        /*Evento  Partic.Permitida  Data  Local  Participantes  Inscritos  Confirmados   Status */
        CREATE ttevento.
        ASSIGN ttevento.cdagenci = STRING(crapeap.cdagenci)
               ttevento.cdcooper = STRING(crapeap.cdcooper)
               ttevento.cdevento = STRING(crapeap.cdevento)
               ttevento.nmevento = STRING(crapedp.nmevento)
               ttevento.tpevento = STRING(aux_tpevento)    
               ttevento.nmresage = STRING(aux_nmresage)    
               ttevento.idpropos = STRING(aux_idpropos)    
               ttevento.idevento = STRING(aux_idevento)    
               ttevento.tppartic = STRING(aux_tppartic)    
               ttevento.dtevento = STRING(aux_dtevento)    
               ttevento.dslocali = STRING(aux_dslocali)    
               ttevento.qtmaxtur = STRING(crapedp.qtmaxtur)
               ttevento.qtmintur = STRING(crapedp.qtmintur)
               ttevento.nrinscri = STRING(aux_nrinscri)    
               ttevento.idstaeve = STRING(aux_idstaeve)    
               ttevento.enlocali = STRING(aux_enlocali)    
               ttevento.hrevento = STRING(aux_hrevento)    
               ttevento.nrseqdig = STRING(crapadp.nrseqdig)
               ttevento.nrconfir = STRING(aux_nrconfir).    
    END.
    
    FOR EACH ttevento BY ttevento.nmresage:

        /********************************************************************************************************/
        /********************************************************************************************************/
        aux_contador = aux_contador + 1.

        ASSIGN aux_conteudo = "~{" +
                              "cdagenci:'" +  ttevento.cdagenci + "'," + 
                              "cdcooper:'" +  ttevento.cdcooper + "'," +
                              "cdevento:'" +  ttevento.cdevento + "'," +
                              "nmevento:'" +  ttevento.nmevento + "'," +
                              "tpevento:'" +  ttevento.tpevento + "'," +
                              "nmresage:'" +  ttevento.nmresage + "'," +
                              "idpropos:'" +  ttevento.idpropos + "'," +
                              "idevento:'" +  ttevento.idevento + "'," +
                              "tppartic:'" +  ttevento.tppartic + "'," +
                              "dtevento:'" +  ttevento.dtevento + "'," +
                              "dslocali:'" +  ttevento.dslocali + "'," +
                              "qtmaxtur:'" +  ttevento.qtmaxtur + "'," +
                              "qtmintur:'" +  ttevento.qtmintur + "'," +
                              "nrinscri:'" +  ttevento.nrinscri + "'," +
                              "idstaeve:'" +  ttevento.idstaeve + "'," +
                              "enlocali:'" +  ttevento.enlocali + "'," +
                              "hrevento:'" +  ttevento.hrevento + "'," +
                              "nrseqdig:'" +  ttevento.nrseqdig + "'," +
                              "nrconfir:'" +  ttevento.nrconfir + "'" + "~}".
        
        /* Se a quantidade de caracteres armazenada + o dobro da qtde. do registro atual for superior a 32K  */
        IF   (LENGTH(vetoreventos1) + (LENGTH(aux_conteudo) * 2)) >= 31900  THEN
             DO:
                 IF   aux_nrovetor = 1   THEN
                      RUN RodaJavaScript("var meventos1=new Array();meventos1=[" + vetoreventos1 + "]").
                 ELSE 
                      RUN RodaJavaScript("meventos1.push(" + vetoreventos1 + ")").
    
                 ASSIGN vetoreventos1 = aux_conteudo
                        aux_nrovetor  = aux_nrovetor + 1.
             END.
        ELSE
             ASSIGN vetoreventos1 = vetoreventos1 + 
                                    (IF vetoreventos1 = "" THEN "" ELSE ",") +
                                    aux_conteudo.
                                    
        /********************************************************************************************************/
        /********************************************************************************************************/


/*         IF  vetorevento = "" THEN                                */
/*             vetorevento = "~{" +                                 */
/*                  "cdagenci:'" +  ttevento.cdagenci + "'," +      */
/*                  "cdcooper:'" +  ttevento.cdcooper + "'," +      */
/*                  "cdevento:'" +  ttevento.cdevento + "'," +      */
/*                  "nmevento:'" +  ttevento.nmevento + "'," +      */
/*                  "tpevento:'" +  ttevento.tpevento + "'," +      */
/*                  "nmresage:'" +  ttevento.nmresage + "'," +      */
/*                  "idpropos:'" +  ttevento.idpropos + "'," +      */
/*                  "idevento:'" +  ttevento.idevento + "'," +      */
/*                  "tppartic:'" +  ttevento.tppartic + "'," +      */
/*                  "dtevento:'" +  ttevento.dtevento + "'," +      */
/*                  "dslocali:'" +  ttevento.dslocali + "'," +      */
/*                  "qtmaxtur:'" +  ttevento.qtmaxtur + "'," +      */
/*                  "qtmintur:'" +  ttevento.qtmintur + "'," +      */
/*                  "nrinscri:'" +  ttevento.nrinscri + "'," +      */
/*                  "idstaeve:'" +  ttevento.idstaeve + "'," +      */
/*                  "enlocali:'" +  ttevento.enlocali + "'," +      */
/*                  "hrevento:'" +  ttevento.hrevento + "'," +      */
/*                  "nrseqdig:'" +  ttevento.nrseqdig + "'," +      */
/*                  "nrconfir:'" +  ttevento.nrconfir + "'" + "~}". */
/*         ELSE                                                     */
/*             vetorevento = vetorevento + "," + "~{" +             */
/*                  "cdagenci:'" +  ttevento.cdagenci + "'," +      */
/*                  "cdcooper:'" +  ttevento.cdcooper + "'," +      */
/*                  "cdevento:'" +  ttevento.cdevento + "'," +      */
/*                  "nmevento:'" +  ttevento.nmevento + "'," +      */
/*                  "tpevento:'" +  ttevento.tpevento + "'," +      */
/*                  "nmresage:'" +  ttevento.nmresage + "'," +      */
/*                  "idpropos:'" +  ttevento.idpropos + "'," +      */
/*                  "idevento:'" +  ttevento.idevento + "'," +      */
/*                  "tppartic:'" +  ttevento.tppartic + "'," +      */
/*                  "dtevento:'" +  ttevento.dtevento + "'," +      */
/*                  "dslocali:'" +  ttevento.dslocali + "'," +      */
/*                  "qtmaxtur:'" +  ttevento.qtmaxtur + "'," +      */
/*                  "qtmintur:'" +  ttevento.qtmintur + "'," +      */
/*                  "nrinscri:'" +  ttevento.nrinscri + "'," +      */
/*                  "idstaeve:'" +  ttevento.idstaeve + "'," +      */
/*                  "enlocali:'" +  ttevento.enlocali + "'," +      */
/*                  "hrevento:'" +  ttevento.hrevento + "'," +      */
/*                  "nrseqdig:'" +  ttevento.nrseqdig + "'," +      */
/*                  "nrconfir:'" +  ttevento.nrconfir + "'" + "~}". */
    END.

/*     RUN RodaJavaScript("alert('"  + STRING(aux_contador) +  " | " + STRING(aux_nrovetor) + "')"). */


    IF   aux_nrovetor = 1   THEN
         RUN RodaJavaScript("var meventos1=new Array();meventos1=[" + vetoreventos1 + "]").
    ELSE 
         RUN RodaJavaScript("meventos1.push(" + vetoreventos1 + ")").

/*     RUN RodaJavaScript("var mevento=new Array();mevento=["  + vetorevento + "]"). */
   
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
    ("aux_idevento":U,"ab_unmap.aux_idevento":U,ab_unmap.aux_idevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lsagenci":U,"ab_unmap.aux_lsagenci":U,ab_unmap.aux_lsagenci:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lsdteven":U,"ab_unmap.aux_lsdteven":U,ab_unmap.aux_lsdteven:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lshreven":U,"ab_unmap.aux_lshreven":U,ab_unmap.aux_lshreven:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lspermis":U,"ab_unmap.aux_lspermis":U,ab_unmap.aux_lspermis:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lsseqdig":U,"ab_unmap.aux_lsseqdig":U,ab_unmap.aux_lsseqdig:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrdrowid":U,"ab_unmap.aux_nrdrowid":U,ab_unmap.aux_nrdrowid:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_stdopcao":U,"ab_unmap.aux_stdopcao":U,ab_unmap.aux_stdopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("cdagenci":U,"crapeap.cdagenci":U,crapeap.cdagenci:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("cdevento":U,"ab_unmap.cdevento":U,ab_unmap.cdevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("dtanoage":U,"crapeap.dtanoage":U,crapeap.dtanoage:HANDLE IN FRAME {&FRAME-NAME}).
END PROCEDURE.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-assign-record w-html 
PROCEDURE local-assign-record :
DEFINE INPUT PARAMETER opcao AS CHARACTER.
    
    DEF VAR i AS INT NO-UNDO.
    
    DEF VAR aux_msgderro AS CHAR NO-UNDO.
    
    /* Instancia a BO para executar as procedures */
    RUN dbo/b1wpgd0030.p PERSISTENT SET h-b1wpgd0030.
    
    /* Se BO foi instanciada */
    IF VALID-HANDLE(h-b1wpgd0030) THEN
       DO:
          DO WITH FRAME {&FRAME-NAME}:
              /* alteracao */
    
              DO i = 1 TO NUM-ENTRIES(ab_unmap.aux_lsagenci, "§"):
    
                  FOR EACH cratadp:
                      DELETE cratadp NO-ERROR.
                  END.
    
                  FIND FIRST crapadp WHERE crapadp.idevento = INT(ab_unmap.aux_idevento)                AND
                                           crapadp.cdcooper = INT(ab_unmap.aux_cdcooper)                AND
                                           crapadp.dtanoage = INT(ab_unmap.aux_dtanoage)                AND
                                           crapadp.cdevento = INT(ab_unmap.cdevento)                    AND
                                           crapadp.cdagenci = INT(ENTRY(i, ab_unmap.aux_lsagenci, "§")) AND
                                           crapadp.nrseqdig = INT(ENTRY(i, ab_unmap.aux_lsseqdig, "§")) 
                                           NO-LOCK NO-ERROR.
    
                  IF NOT AVAIL crapadp THEN DO:
                      ASSIGN msg-erro = msg-erro + "Registro não encontrado para alteração. " + ab_unmap.cdevento.
                      LEAVE.
                  END.
    
                  /* Verifica se foi passada uma data válida */
                  IF DAY(DATE(ENTRY(i, ab_unmap.aux_lsdteven,"§"))) = ? AND ENTRY(i, ab_unmap.aux_lsdteven, "§") <> "" THEN
                  DO:
                      msg-erro = msg-erro + "Data " + ENTRY(i, ab_unmap.aux_lsdteven, "§") + " inválida. ".
                      LEAVE.
                  END.
                  
                  /* cria a temp-table e joga o novo valor digitado para o campo */
                  CREATE cratadp.
                  BUFFER-COPY crapadp TO cratadp.
    
                  ASSIGN cratadp.dshroeve = ENTRY(i, ab_unmap.aux_lshreven, "§")
                         cratadp.dtfineve = DATE(ENTRY(i, ab_unmap.aux_lsdteven, "§"))
                         cratadp.dtinieve = DATE(ENTRY(i, ab_unmap.aux_lsdteven, "§"))
                         cratadp.dsdiaeve = ""
                         cratadp.nrmeseve = MONTH(cratadp.dtinieve)
                         cratadp.qtdiaeve = 1.
    
                  RUN altera-registro IN h-b1wpgd0030(INPUT TABLE cratadp, OUTPUT aux_msgderro).
    
                  msg-erro = msg-erro + aux_msgderro.
                  
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
DEF VAR aux_msgderro AS CHAR NO-UNDO.
DEF VAR aux_flgexist AS LOGICAL NO-UNDO.
    
	ASSIGN aux_flgexist = FALSE.
    
	/* Verifica se existem pré-inscritos no evento */
	FOR EACH crapidp WHERE crapidp.cdcooper = INT(ab_unmap.aux_cdcooper)    AND
                           crapidp.dtanoage = INT(ab_unmap.aux_dtanoage)    AND
                           crapidp.cdevento = INT(ab_unmap.cdevento)        AND
                           crapidp.idevento = INT(ab_unmap.aux_idevento)    NO-LOCK:
						  
		ASSIGN aux_flgexist = TRUE.  
						          
	END.
	
	IF   aux_flgexist  THEN
	     DO:                         
		     ASSIGN msg-erro = "Este evento possui pré-inscritos. Sua exclusão não é permitida.".
             RETURN "NOK".
		 END.
		 
	/* Instancia a BO para executar as procedures */
    RUN dbo/b1wpgd0014a.p PERSISTENT SET h-b1wpgd0014a. /* BO de Eventos por Cooperativa - crapedp */
    RUN dbo/b1wpgd0014b.p PERSISTENT SET h-b1wpgd0014b. /* Eventos da Agenda - crapeap */
    RUN dbo/b1wpgd0030.p  PERSISTENT SET h-b1wpgd0030.  /* Informações da Agenda do Progrid por PAC - crapadp */  
      
    /* Se BO foi instanciada */
    IF VALID-HANDLE(h-b1wpgd0014a) AND 
       VALID-HANDLE(h-b1wpgd0014b) AND
       VALID-HANDLE(h-b1wpgd0030)  THEN
       DO:   
    
        FOR EACH crapadp WHERE crapadp.cdcooper = INT(ab_unmap.aux_cdcooper)    AND
                               crapadp.dtanoage = INT(ab_unmap.aux_dtanoage)    AND
                               crapadp.cdevento = INT(ab_unmap.cdevento)        AND
                               crapadp.idevento = INT(ab_unmap.aux_idevento)    NO-LOCK:
    
            FOR EACH cratadp:
                DELETE cratadp NO-ERROR.
            END.
    
            CREATE cratadp.
            BUFFER-COPY crapadp TO cratadp.
    
            RUN exclui-registro IN h-b1wpgd0030(INPUT TABLE cratadp, OUTPUT aux_msgderro).
    
            ASSIGN msg-erro = msg-erro + aux_msgderro.
        
        END.
        
        FOR EACH crapeap WHERE crapeap.cdcooper = INT(ab_unmap.aux_cdcooper)    AND
                               crapeap.dtanoage = INT(ab_unmap.aux_dtanoage)    AND
                               crapeap.cdevento = INT(ab_unmap.cdevento)        AND
                               crapeap.idevento = INT(ab_unmap.aux_idevento)    NO-LOCK:
    
            FOR EACH crateap:
                DELETE crateap NO-ERROR.
            END.
    
            CREATE crateap.
            BUFFER-COPY crapeap TO crateap.
    
            RUN exclui-registro IN h-b1wpgd0014b(INPUT TABLE crateap, OUTPUT aux_msgderro).
    
            ASSIGN msg-erro = msg-erro + aux_msgderro.
        
        END.
        
        FOR EACH crapedp WHERE crapedp.cdcooper = INT(ab_unmap.aux_cdcooper)    AND
                               crapedp.dtanoage = INT(ab_unmap.aux_dtanoage)    AND
                               crapedp.cdevento = INT(ab_unmap.cdevento)        AND
                               crapedp.idevento = INT(ab_unmap.aux_idevento)    NO-LOCK:
    
            FOR EACH cratedp:
                DELETE cratedp NO-ERROR.
            END.
    
            CREATE cratedp.
            BUFFER-COPY crapedp TO cratedp.
    
            RUN exclui-registro IN h-b1wpgd0014a(INPUT TABLE cratedp, OUTPUT aux_msgderro).
    
            ASSIGN msg-erro = msg-erro + aux_msgderro.
        
        END.
    
        /* "mata" a instância da BO */
        DELETE PROCEDURE h-b1wpgd0014a NO-ERROR.
        DELETE PROCEDURE h-b1wpgd0014b NO-ERROR.
        DELETE PROCEDURE h-b1wpgd0030  NO-ERROR.
    END.

    /*RUN RodaJavaScript("alert('" + ab_unmap.aux_idevento + "')").
    RUN RodaJavaScript("alert('" + ab_unmap.aux_dtanoage + "')").*/

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
  
ASSIGN opcao                    = GET-FIELD("aux_cddopcao")
       FlagPermissoes           = GET-VALUE("aux_lspermis")
       msg-erro-aux             = 0
       ab_unmap.aux_idevento    = GET-VALUE("aux_idevento")
       ab_unmap.aux_dsendurl    = AppURL                        
       ab_unmap.aux_lspermis    = FlagPermissoes                
       ab_unmap.aux_nrdrowid    = GET-VALUE("aux_nrdrowid")         
       ab_unmap.aux_stdopcao    = GET-VALUE("aux_stdopcao")
       ab_unmap.aux_lsagenci    = GET-VALUE("aux_lsagenci")
       ab_unmap.aux_lsdteven    = GET-VALUE("aux_lsdteven")
       ab_unmap.aux_lshreven    = GET-VALUE("aux_lshreven")
       ab_unmap.aux_lsseqdig    = GET-VALUE("aux_lsseqdig")
       ab_unmap.aux_dtanoage    = GET-VALUE("aux_dtanoage")
       ab_unmap.aux_cdcooper    = GET-VALUE("aux_cdcooper")
       ab_unmap.cdevento        = GET-VALUE("cdevento").

RUN outputHeader.

{includes/wpgd0098.i}

ab_unmap.aux_cdcooper:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = aux_crapcop.

/* Se a cooperativa ainda não foi escolhida, pega a da sessão do usuário */
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
                        RUN local-assign-record ("alteracao").  
                        IF msg-erro = "" THEN
                           ASSIGN msg-erro-aux = 10. /* Solicitação realizada com sucesso */ 
                        ELSE
                           ASSIGN msg-erro-aux = 3. /* erros da validação de dados */
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
               RUN local-delete-record.
               DO i = 1 TO ERROR-STATUS:NUM-MESSAGES:
                  ASSIGN msg-erro = msg-erro + ERROR-STATUS:GET-MESSAGE(i).
               END.  
               IF msg-erro = "" THEN
                  ASSIGN msg-erro-aux = 10. /* Solicitação realizada com sucesso */ 
               ELSE
                  ASSIGN msg-erro-aux = 3. /* erros da validação de dados */
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

      RUN CriaListaEvCoop.
      RUN CriaListaEvento.

      /*IF msg-erro-aux = 10 OR (opcao <> "sa" AND opcao <> "ex" AND opcao <> "in") THEN*/
         RUN displayFields.
 
      RUN enableFields.
      RUN outputFields.

      CASE msg-erro-aux:
           WHEN 1 THEN
                DO:
                    ASSIGN v-qtdeerro      = 1
                           v-descricaoerro = 'Registro esta em uso por outro usuário. Solicitação não pode ser executada. Espere alguns instantes e tente novamente.'.

                    RUN RodaJavaScript('alert("'+ v-descricaoerro + '"); ').
                END.

           WHEN 2 THEN
                RUN RodaJavaScript("alert('Registro foi excluído. Solicitação não pode ser executada.')").
      
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
                RUN RodaJavaScript('alert("Atualizacao executada com sucesso.")'). 
         
      END CASE.    

      /*RUN RodaJavaScript('top.frames[0].ZeraOp()').*/   

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

                    RUN CriaListaEvCoop.
                    RUN CriaListaEvento.

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

