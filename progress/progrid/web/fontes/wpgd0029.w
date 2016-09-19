  /*...............................................................................

     Alterações: 28/01/2008 - Acrescentados Data e Hora na descrição dos eventos no Combo (Diego).
     
                 01/02/2008 - Efetuar ordenação através do campo crapgap.nrordgru (Diego).
     
                 10/12/2008 - Melhoria de performance para a tabela gnapses (Evandro).
                 
                 30/04/2009 - Utilizar cdcooper = 0 nas consultas (David).
                 
                 09/06/2011 - Corrigido os itens da aba Sugestão para não aparecerem
                              mais de uma vez.
                            - Mostrar os eventos de integração.
                            (Isara - RKAM)
                                                    
                 05/06/2012 - Adaptação dos fontes para projeto Oracle. Alterado
                              busca na gnapses de CONTAINS para MATCHES (Guilherme Maba).
                              
                 08/07/2012 - Tratamento de CLOB com CHAR (Guilherme).
                 
                 05/09/2012 - Desfeito tratamento no campo dsobserv clob (Tiago).           
                 
                 16/06/2014 - Ajustes na procedure local-delete-record para
                              gravar registros na temp-table do buffer Softdesk
                              165668 (Lucas R.)
                              
                 05/08/2015 - Implementação de novas funcionalidades  referente 
                              ao projeto de melhorias do progrid etapa rf01(Jean MICHEL).    
                              
                 01/09/2015 - Ajustes de Homologaçao RF01(Vanessa).
                 
                 10/12/2015 - Ajustado procedure CriaListaEvento, estava estourando
                              o tamanho da variavel, adicionado .push para adicionar
                              somente um evento por vez dentro do for each 
                              (Lucas Ranghetti. #371145 )
                 
                 16/12/2015 - Ajustado nas sugestoes da tela de avaliacoes conforme
                              solicitado no chamado 371145. (Kelvin)            
  ...............................................................................*/

  &ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
  &ANALYZE-RESUME
  /* Connected Databases 
            bancjo            PROGRESS
  */
  &Scoped-define WINDOW-NAME CURRENT-WINDOW

  /* Temp-Table and Buffer definitions                                    */
  DEFINE TEMP-TABLE ab_unmap
         FIELD aux_cdagenci AS CHARACTER 
         FIELD aux_cdcooper AS CHARACTER 
         FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
         FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
         FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
         FIELD aux_dtanoage AS CHARACTER FORMAT "X(256)":U 
         FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
         FIELD aux_iditeava AS CHARACTER FORMAT "X(256)":U 
         FIELD aux_lsaltern AS CHARACTER FORMAT "X(256)":U 
         FIELD aux_lsavabom AS CHARACTER FORMAT "X(256)":U 
         FIELD aux_lsavains AS CHARACTER FORMAT "X(256)":U 
         FIELD aux_lsavaoti AS CHARACTER FORMAT "X(256)":U 
         FIELD aux_lsavareg AS CHARACTER FORMAT "X(256)":U 
         FIELD aux_lsdescri AS CHARACTER FORMAT "X(256)":U 
         FIELD aux_lsiteav2 AS CHARACTER FORMAT "X(256)":U 
         FIELD aux_lsiteava AS CHARACTER FORMAT "X(256)":U 
         FIELD aux_lsobserv AS CHARACTER FORMAT "X(256)":U 
         FIELD arrQtsugeve AS CHARACTER FORMAT "X(256)":U       
         FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
         FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
         FIELD aux_nrseqeve AS CHARACTER FORMAT "X(256)":U
         FIELD aux_qtdparti AS CHARACTER FORMAT "X(256)":U 
         FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
         FIELD cdagenci AS CHARACTER FORMAT "X(256)":U 
         FIELD cdcooper AS CHARACTER FORMAT "X(256)":U 
         FIELD nrseqeve AS CHARACTER FORMAT "X(256)":U 
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
  DEFINE VARIABLE ProgramaEmUso         AS CHARACTER INITIAL ["wpgd0029"].
  DEFINE VARIABLE NmeDoPrograma         AS CHARACTER INITIAL ["wpgd0029.w"].

  DEFINE VARIABLE opcao                 AS CHARACTER.
  DEFINE VARIABLE msg-erro              AS CHARACTER.
  DEFINE VARIABLE msg-erro-aux          AS INTEGER.
  DEFINE VARIABLE aux_nrdrowid-auxiliar AS CHARACTER.
  DEFINE VARIABLE pesquisa              AS CHARACTER.     
  DEFINE VARIABLE FlagPermissoes        AS CHARACTER.
  DEFINE VARIABLE IdentificacaoDaSessao AS CHARACTER FORMAT "x(47)".
  DEFINE VARIABLE vauxsenha             AS CHARACTER FORMAT "X(16)".

  DEFINE VARIABLE aux_qtsugeve          AS INTEGER.
  DEFINE VARIABLE aux_nrseqdig          AS INTEGER.

  DEFINE VARIABLE i                     AS INTEGER                        NO-UNDO.
  DEFINE VARIABLE m-erros               AS CHARACTER                      NO-UNDO.
  DEFINE VARIABLE v-qtdeerro            AS INTEGER                        NO-UNDO.
  DEFINE VARIABLE v-descricaoerro       AS CHARACTER                      NO-UNDO.
  DEFINE VARIABLE v-identificacao       AS CHARACTER                      NO-UNDO.

  DEFINE VARIABLE aux_cont AS INTEGER NO-UNDO.
  DEFINE VARIABLE aux_regi AS INTEGER NO-UNDO.

  DEFINE VARIABLE aux_info   AS CHAR NO-UNDO.

  /*** Declaração de BOs ***/
  DEFINE VARIABLE h-b1wpgd0029          AS HANDLE                         NO-UNDO.
  DEFINE VARIABLE h-b1wpgd0011          AS HANDLE                         NO-UNDO.

  /*** Temp Tables ***/
  DEF TEMP-TABLE cratrap
          FIELD cdagenci LIKE craprap.cdagenci        
          FIELD cdcooper LIKE craprap.cdcooper
          FIELD cdevento LIKE craprap.cdevento
          FIELD cdgruava LIKE craprap.cdgruava
          FIELD cditeava LIKE craprap.cditeava
          FIELD dsobserv AS CHAR
          FIELD dtanoage LIKE craprap.dtanoage
          FIELD idevento LIKE craprap.idevento
          FIELD nrseqeve LIKE craprap.nrseqeve
          FIELD qtavabom LIKE craprap.qtavabom
          FIELD qtavains LIKE craprap.qtavains
          FIELD qtavaoti LIKE craprap.qtavaoti
          FIELD qtavareg LIKE craprap.qtavareg
          FIELD qtavares LIKE craprap.qtavares.

  DEFINE VARIABLE aux_crapcop AS CHAR NO-UNDO.                                                                       
  DEFINE VARIABLE vetorpac    AS CHAR NO-UNDO.
  DEFINE VARIABLE vetorevento AS CHAR NO-UNDO.
  DEFINE VARIABLE vetorava    AS CHAR NO-UNDO.
  DEFINE VARIABLE vetorsug    AS CHAR NO-UNDO.
  DEFINE VARIABLE vetortema   AS CHAR NO-UNDO.

  DEFINE VARIABLE aux_sugestao          LIKE crapsdp.dssugeve.
  DEFINE VARIABLE frequenciaMinima      LIKE crapedp.prfreque.

  DEFINE BUFFER crabrap FOR craprap.
  
  /*** Temp Tables ***/
  DEFINE TEMP-TABLE cratsdp             LIKE crapsdp.
  /* _UIB-CODE-BLOCK-END */
  &ANALYZE-RESUME

  &ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

  /* ********************  Preprocessor Definitions  ******************** */

  &Scoped-define PROCEDURE-TYPE Web-Object
  &Scoped-define DB-AWARE no

  &Scoped-define WEB-FILE fontes/wpgd0029.htm

  /* Name of first Frame and/or Browse and/or first Query                 */
  &Scoped-define FRAME-NAME Web-Frame

  /* Standard List Definitions                                            */
  &Scoped-Define ENABLED-FIELDS craprap.qtavares 
  &Scoped-define ENABLED-TABLES ab_unmap craprap
  &Scoped-define FIRST-ENABLED-TABLE ab_unmap
  &Scoped-define SECOND-ENABLED-TABLE craprap
  &Scoped-Define ENABLED-OBJECTS ab_unmap.aux_nrseqeve ab_unmap.nrseqeve ab_unmap.aux_lsiteav2 ab_unmap.aux_lsobserv ab_unmap.arrQtsugeve ab_unmap.aux_lsavabom ab_unmap.aux_lsavains ab_unmap.aux_lsavaoti ab_unmap.aux_lsavareg ab_unmap.aux_lsiteava ab_unmap.aux_iditeava ab_unmap.aux_cdagenci ab_unmap.aux_cdcooper ab_unmap.aux_cddopcao ab_unmap.aux_dsendurl ab_unmap.aux_dsretorn ab_unmap.aux_dtanoage ab_unmap.aux_idevento ab_unmap.aux_lsaltern ab_unmap.aux_lsdescri ab_unmap.aux_lspermis ab_unmap.aux_nrdrowid ab_unmap.aux_qtdparti ab_unmap.aux_stdopcao ab_unmap.cdagenci ab_unmap.cdcooper ab_unmap.pagina 
  &Scoped-Define DISPLAYED-FIELDS craprap.qtavares 
  &Scoped-define DISPLAYED-TABLES ab_unmap craprap
  &Scoped-define FIRST-DISPLAYED-TABLE ab_unmap
  &Scoped-define SECOND-DISPLAYED-TABLE craprap
  &Scoped-Define DISPLAYED-OBJECTS ab_unmap.aux_nrseqeve ab_unmap.nrseqeve ab_unmap.aux_lsiteav2 ab_unmap.aux_lsobserv ab_unmap.arrQtsugeve ab_unmap.aux_lsavabom ab_unmap.aux_lsavains ab_unmap.aux_lsavaoti ab_unmap.aux_lsavareg ab_unmap.aux_lsiteava ab_unmap.aux_iditeava ab_unmap.aux_cdagenci ab_unmap.aux_cdcooper ab_unmap.aux_cddopcao ab_unmap.aux_dsendurl ab_unmap.aux_dsretorn ab_unmap.aux_dtanoage ab_unmap.aux_idevento ab_unmap.aux_lsaltern ab_unmap.aux_lsdescri ab_unmap.aux_lspermis ab_unmap.aux_nrdrowid ab_unmap.aux_qtdparti ab_unmap.aux_stdopcao ab_unmap.cdagenci ab_unmap.cdcooper ab_unmap.pagina 

  /* Custom List Definitions                                              */
  /* List-1,List-2,List-3,List-4,List-5,List-6                            */

  /* _UIB-PREPROCESSOR-BLOCK-END */
  &ANALYZE-RESUME

  /* ***********************  Control Definitions  ********************** */
  /* Definitions of the field level widgets                               */
  /* ************************  Frame Definitions  *********************** */

  DEFINE FRAME Web-Frame
       ab_unmap.aux_nrseqeve AT ROW 1 COL 1 HELP
            "" NO-LABEL
            VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
            SIZE 20 BY 4
       ab_unmap.nrseqeve AT ROW 1 COL 1 HELP
            "" NO-LABEL FORMAT "X(256)":U
            VIEW-AS FILL-IN 
            SIZE 20 BY 1
       ab_unmap.aux_lsiteav2 AT ROW 1 COL 1 HELP
            "" NO-LABEL FORMAT "X(256)":U
            VIEW-AS FILL-IN 
            SIZE 20 BY 1
       ab_unmap.aux_lsobserv AT ROW 1 COL 1 HELP
            "" NO-LABEL FORMAT "X(256)":U
            VIEW-AS FILL-IN 
            SIZE 20 BY 1
       ab_unmap.arrQtsugeve AT ROW 1 COL 1 HELP
            "" NO-LABEL FORMAT "X(256)":U
            VIEW-AS FILL-IN 
            SIZE 20 BY 1
       ab_unmap.aux_lsavabom AT ROW 1 COL 1 HELP
            "" NO-LABEL FORMAT "X(256)":U
            VIEW-AS FILL-IN 
            SIZE 20 BY 1
       ab_unmap.aux_lsavains AT ROW 1 COL 1 HELP
            "" NO-LABEL FORMAT "X(256)":U
            VIEW-AS FILL-IN 
            SIZE 20 BY 1
       ab_unmap.aux_lsavaoti AT ROW 1 COL 1 HELP
            "" NO-LABEL FORMAT "X(256)":U
            VIEW-AS FILL-IN 
            SIZE 20 BY 1
       ab_unmap.aux_lsavareg AT ROW 1 COL 1 HELP
            "" NO-LABEL FORMAT "X(256)":U
            VIEW-AS FILL-IN 
            SIZE 20 BY 1
       ab_unmap.aux_lsiteava AT ROW 1 COL 1 HELP
            "" NO-LABEL FORMAT "X(256)":U
            VIEW-AS FILL-IN 
            SIZE 20 BY 1
       ab_unmap.aux_iditeava AT ROW 1 COL 1 HELP
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
       ab_unmap.aux_lsaltern AT ROW 1 COL 1 HELP
            "" NO-LABEL FORMAT "X(256)":U
            VIEW-AS FILL-IN 
            SIZE 20 BY 1
       ab_unmap.aux_lsdescri AT ROW 1 COL 1 HELP
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
       ab_unmap.aux_qtdparti AT ROW 1 COL 1 HELP
            "" NO-LABEL FORMAT "X(256)":U
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
      WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
           SIDE-LABELS 
           AT COL 1 ROW 1
           SIZE 45 BY 25.52.

  /* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
  DEFINE FRAME Web-Frame
       ab_unmap.cdcooper AT ROW 1 COL 1 HELP
            "" NO-LABEL FORMAT "X(256)":U
            VIEW-AS FILL-IN 
            SIZE 20 BY 1
       ab_unmap.pagina AT ROW 1 COL 1 HELP
            "" NO-LABEL FORMAT "X(256)":U
            VIEW-AS FILL-IN 
            SIZE 20 BY 1
       craprap.qtavares AT ROW 1 COL 1 NO-LABEL
            VIEW-AS FILL-IN 
            SIZE 20 BY 1
      WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
           SIDE-LABELS 
           AT COL 1 ROW 1
           SIZE 45 BY 25.52.

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
            FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
            FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
            FIELD aux_dtanoage AS CHARACTER FORMAT "X(256)":U 
            FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
            FIELD aux_iditeava AS CHARACTER FORMAT "X(256)":U 
            FIELD aux_lsaltern AS CHARACTER FORMAT "X(256)":U 
            FIELD aux_lsavabom AS CHARACTER FORMAT "X(256)":U 
            FIELD aux_lsavains AS CHARACTER FORMAT "X(256)":U 
            FIELD aux_lsavaoti AS CHARACTER FORMAT "X(256)":U 
            FIELD aux_lsavareg AS CHARACTER FORMAT "X(256)":U 
            FIELD aux_lsdescri AS CHARACTER FORMAT "X(256)":U 
            FIELD aux_lsiteav2 AS CHARACTER FORMAT "X(256)":U 
            FIELD aux_lsiteava AS CHARACTER FORMAT "X(256)":U 
            FIELD aux_lsobserv AS CHARACTER FORMAT "X(256)":U 
            FIELD arrQtsugeve AS CHARACTER FORMAT "X(256)":U 
            FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
            FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
            FIELD aux_nrseqeve AS CHARACTER FORMAT "X(256":U
            FIELD aux_qtdparti AS CHARACTER FORMAT "X(256)":U 
            FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
            FIELD cdagenci AS CHARACTER FORMAT "X(256)":U 
            FIELD cdcooper AS CHARACTER FORMAT "X(256)":U 
            FIELD nrseqeve AS CHARACTER FORMAT "X(256)":U 
            FIELD pagina AS CHARACTER FORMAT "X(256)":U 
        END-FIELDS.
     END-TABLES.
   */
  &ANALYZE-RESUME _END-PROCEDURE-SETTINGS

  /* *************************  Create Window  ************************** */

  &ANALYZE-SUSPEND _CREATE-WINDOW
  /* DESIGN Window definition (used by the UIB) 
    CREATE WINDOW w-html ASSIGN
           HEIGHT             = 25.52
           WIDTH              = 45.
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
  /* SETTINGS FOR FILL-IN ab_unmap.aux_dsendurl IN FRAME Web-Frame
     ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
  /* SETTINGS FOR FILL-IN ab_unmap.aux_dsretorn IN FRAME Web-Frame
     ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
  /* SETTINGS FOR FILL-IN ab_unmap.aux_dtanoage IN FRAME Web-Frame
     ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
  /* SETTINGS FOR FILL-IN ab_unmap.aux_idevento IN FRAME Web-Frame
     ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
  /* SETTINGS FOR FILL-IN ab_unmap.aux_iditeava IN FRAME Web-Frame
     ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
  /* SETTINGS FOR FILL-IN ab_unmap.aux_lsaltern IN FRAME Web-Frame
     ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
  /* SETTINGS FOR FILL-IN ab_unmap.aux_lsavabom IN FRAME Web-Frame
     ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
  /* SETTINGS FOR FILL-IN ab_unmap.aux_lsavains IN FRAME Web-Frame
     ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
  /* SETTINGS FOR FILL-IN ab_unmap.aux_lsavaoti IN FRAME Web-Frame
     ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
  /* SETTINGS FOR FILL-IN ab_unmap.aux_lsavareg IN FRAME Web-Frame
     ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
  /* SETTINGS FOR FILL-IN ab_unmap.aux_lsdescri IN FRAME Web-Frame
     ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
  /* SETTINGS FOR FILL-IN ab_unmap.aux_lsiteav2 IN FRAME Web-Frame
     ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
  /* SETTINGS FOR FILL-IN ab_unmap.aux_lsiteava IN FRAME Web-Frame
     ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
  /* SETTINGS FOR FILL-IN ab_unmap.aux_lsobserv IN FRAME Web-Frame
     ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
  /* SETTINGS FOR FILL-IN ab_unmap.arrQtsugeve IN FRAME Web-Frame
     ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
  /* SETTINGS FOR FILL-IN ab_unmap.aux_lspermis IN FRAME Web-Frame
     ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
  /* SETTINGS FOR FILL-IN ab_unmap.aux_nrdrowid IN FRAME Web-Frame
     ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
  /* SETTINGS FOR SELECTION-LIST ab_unmap.aux_nrseqeve IN FRAME Web-Frame
     EXP-LABEL EXP-FORMAT EXP-HELP                                        */
  /* SETTINGS FOR FILL-IN ab_unmap.aux_qtdparti IN FRAME Web-Frame
     ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
  /* SETTINGS FOR FILL-IN ab_unmap.aux_stdopcao IN FRAME Web-Frame
     ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
  /* SETTINGS FOR FILL-IN ab_unmap.cdagenci IN FRAME Web-Frame
     ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
  /* SETTINGS FOR FILL-IN ab_unmap.cdcooper IN FRAME Web-Frame
     ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
  /* SETTINGS FOR FILL-IN ab_unmap.nrseqeve IN FRAME Web-Frame
     ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
  /* SETTINGS FOR FILL-IN ab_unmap.pagina IN FRAME Web-Frame
     ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
  /* SETTINGS FOR FILL-IN craprap.qtavares IN FRAME Web-Frame
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

  &ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaAva w-html 
  PROCEDURE CriaListaAva :
  /*------------------------------------------------------------------------------
    Purpose:     
    Parameters:  <none>
    Notes:       
  ------------------------------------------------------------------------------*/
      DEF VAR aux_peavaoti    AS INT  NO-UNDO.
      DEF VAR aux_peavabom    AS INT  NO-UNDO.
      DEF VAR aux_peavareg    AS INT  NO-UNDO.
      DEF VAR aux_peavains    AS INT  NO-UNDO.
      DEF VAR aux_qtavanre    AS INT  NO-UNDO.
      DEF VAR aux_peavanre    AS INT  NO-UNDO.
      DEF VAR aux_qtpartic    AS INT  NO-UNDO.
      DEF VAR aux_nrseqeve    AS INT  NO-UNDO.
      DEF VAR aux_contador    AS INT  NO-UNDO.
      DEF VAR aux_tpiteava    AS INT  NO-UNDO.
      DEF VAR aux_qtavares    LIKE craprap.qtavares.   
      
      DEF VAR aux_dsobserv    AS CHAR NO-UNDO.
      
      DEF VAR dataFinal       AS DATE.
      DEF VAR numDiasDoEvento AS INTEGER.
      
      FOR EACH craprap WHERE craprap.dtanoage = gnpapgd.dtanonov           AND
                             craprap.cdcooper = INT(ab_unmap.aux_cdcooper) AND
                             craprap.cdagenci = INT(ab_unmap.cdagenci)     AND
                             craprap.nrseqeve = INT(ab_unmap.nrseqeve)     NO-LOCK, 
         FIRST crapiap WHERE crapiap.cdcooper = 0                AND
                             crapiap.cditeava = craprap.cditeava NO-LOCK,
         FIRST crapgap WHERE crapgap.cdcooper = 0                AND
                             crapgap.cdgruava = crapiap.cdgruava NO-LOCK
                                 BY crapgap.nrordgru:
      
          aux_qtpartic = 0.
      
          FIND crapadp WHERE crapadp.idevento = craprap.idevento  AND
                             crapadp.cdcooper = craprap.cdcooper  AND
                             crapadp.cdagenci = craprap.cdagenci  AND
                             crapadp.dtanoage = craprap.dtanoage  AND
                             crapadp.cdevento = craprap.cdevento  AND
                             crapadp.nrseqdig = craprap.nrseqeve  NO-LOCK NO-ERROR.
          IF AVAILABLE crapadp
             THEN
                 ASSIGN dataFinal       = crapadp.dtfineve
                        numDiasDoEvento = crapadp.qtdiaeve.
             ELSE
                 ASSIGN dataFinal = ?.  

          FIND  crapedp WHERE crapedp.idevento = Craprap.IdEvento AND
                              crapedp.cdcooper = Craprap.cdCooper AND
                              crapedp.dtanoage = Craprap.dtAnoAge AND
                              crapedp.cdevento = Craprap.CdEvento NO-LOCK NO-ERROR.
          IF AVAILABLE Crapadp THEN
              ASSIGN frequenciaMinima = crapedp.prfreque.
          
          FOR EACH crapidp WHERE crapidp.idevento = craprap.idevento  AND
                                 crapidp.cdcooper = craprap.cdcooper  AND
                                 crapidp.dtanoage = craprap.dtanoage  AND
                                 crapidp.cdagenci = craprap.cdagenci  AND                               
                                 crapidp.nrseqeve = craprap.nrseqeve  AND                               
                                 crapidp.idstains = 2:
                                                                      
              /* *** Se incricao cofirmada e evento encerrado, verifica faltas ****/
              IF dataFinal <> ? THEN
                 DO:
                       /* se evento encerrado */
                       IF ((dataFinal + 1) < TODAY) AND Crapidp.QtFalEve > 0
                           THEN
                               DO:
                                  IF NOT (((crapidp.qtfaleve * 100) / Crapadp.QtDiaEve) > (100 - frequenciaMinima))  /* faltou mais da metade do evento */
                                      THEN
                                          ASSIGN aux_qtpartic = aux_qtpartic + 1.
                               END.
                           ELSE
                               ASSIGN aux_qtpartic = aux_qtpartic + 1.
                     END.
                 ELSE
                     ASSIGN aux_qtpartic = aux_qtpartic + 1.
      
          END. /* FOR EACH crapidp */
          
          ASSIGN 
          aux_peavaoti = IF (craprap.qtavaoti / craprap.qtavares ) <> ? THEN (craprap.qtavaoti / craprap.qtavares * 100) ELSE 0
          aux_peavabom = IF (craprap.qtavabom / craprap.qtavares ) <> ? THEN (craprap.qtavabom / craprap.qtavares * 100) ELSE 0
          aux_peavareg = IF (craprap.qtavareg / craprap.qtavares ) <> ? THEN (craprap.qtavareg / craprap.qtavares * 100) ELSE 0
          aux_peavains = IF (craprap.qtavains / craprap.qtavares ) <> ? THEN (craprap.qtavains / craprap.qtavares * 100) ELSE 0
      
          aux_qtavanre = craprap.qtavares - (craprap.qtavaoti + craprap.qtavabom + craprap.qtavareg + craprap.qtavains)
          aux_peavanre = IF (aux_qtavanre / craprap.qtavares ) <> ? THEN (aux_qtavanre / craprap.qtavares * 100) ELSE 0
      
          aux_qtavares = craprap.qtavares
          
          aux_nrseqeve = IF craprap.nrseqeve <> ? THEN craprap.nrseqeve ELSE 0
      
          /* Trata a observação pois se tiver CTRL-J (quebra de linha), tem que trocar por '\n' */
          aux_dsobserv = "".
          
          DO aux_contador = 1 TO LENGTH(craprap.dsobserv):
             IF  SUBSTRING(craprap.dsobserv,aux_contador,1) = CHR(10) THEN
                 aux_dsobserv = aux_dsobserv + "~\n".
             ELSE
                 aux_dsobserv = aux_dsobserv + SUBSTRING(craprap.dsobserv,aux_contador,1).
          END.                    
          
          aux_sugestao = "".
      
          IF  vetorava = "" THEN  
              vetorava = "~{" +   
                   "cdagenci:'" +  STRING(craprap.cdagenci) + "'," + 
                   "cdcooper:'" +  STRING(craprap.cdcooper) + "'," +
                   "cdevento:'" +  STRING(craprap.cdevento) + "'," +
                   "nrseqeve:'" +  STRING(aux_nrseqeve)     + "'," +
                   "iditeava:'" +  STRING(ROWID(craprap))   + "'," +
                   "tpiteava:'" +  STRING(crapgap.tpiteava) + "'," +
                   "cditeava:'" +  STRING(crapiap.cditeava) + "'," +
                   "dsiteava:'" +  STRING(crapiap.dsiteava) + "'," +
                   "cdgruava:'" +  STRING(crapgap.cdgruava) + "'," +
                   "dsgruava:'" +  STRING(crapgap.dsgruava) + "'," +
                   "dsobserv:'" +  STRING(aux_dsobserv) + "'," +
                   "qtavabom:'" +  STRING(craprap.qtavabom) + "'," +
                   "peavabom:'" +  STRING(aux_peavabom)     + "'," +
                   "qtavains:'" +  STRING(craprap.qtavains) + "'," +  
                   "peavains:'" +  STRING(aux_peavains)     + "'," +
                   "qtavaoti:'" +  STRING(craprap.qtavaoti) + "'," +  
                   "peavaoti:'" +  STRING(aux_peavaoti)     + "'," +
                   "qtavareg:'" +  STRING(craprap.qtavareg) + "'," + 
                   "peavareg:'" +  STRING(aux_peavareg)     + "'," +
                   "qtavares:'" +  STRING(aux_qtavares)     + "'," +
                   "qtpartic:'" +  STRING(aux_qtpartic)     + "'," +
                   "qtavanre:'" +  STRING(aux_qtavanre)     + "'," +
                   "peavanre:'" +  STRING(aux_peavanre)     + "'," +
                   "nrseqdig:'" +  STRING(0)                + "'," +
                   "qtsugeve:'" +  STRING(0)                + "'," +
                   "dssugeve:'" +  STRING(aux_sugestao)     + "'"  + "~}".
                   
          ELSE
              vetorava = vetorava + "," + "~{" +
                   "cdagenci:'" +  STRING(craprap.cdagenci) + "'," + 
                   "cdcooper:'" +  STRING(craprap.cdcooper) + "'," +
                   "cdevento:'" +  STRING(craprap.cdevento) + "'," +
                   "nrseqeve:'" +  STRING(craprap.nrseqeve)     + "'," +
                   "iditeava:'" +  STRING(ROWID(craprap))   + "'," +
                   "tpiteava:'" +  STRING(crapgap.tpiteava) + "'," +
                   "cditeava:'" +  STRING(crapiap.cditeava) + "'," +
                   "dsiteava:'" +  STRING(crapiap.dsiteava) + "'," +
                   "cdgruava:'" +  STRING(crapgap.cdgruava) + "'," +
                   "dsgruava:'" +  STRING(crapgap.dsgruava) + "'," +
                   "dsobserv:'" +  STRING(aux_dsobserv) + "'," +
                   "qtavabom:'" +  STRING(craprap.qtavabom) + "'," +
                   "peavabom:'" +  STRING(aux_peavabom)     + "'," +
                   "qtavains:'" +  STRING(craprap.qtavains) + "'," +  
                   "peavains:'" +  STRING(aux_peavains)     + "'," +
                   "qtavaoti:'" +  STRING(craprap.qtavaoti) + "'," +  
                   "peavaoti:'" +  STRING(aux_peavaoti)     + "'," +
                   "qtavareg:'" +  STRING(craprap.qtavareg) + "'," + 
                   "peavareg:'" +  STRING(aux_peavareg)     + "'," +
                   "qtavares:'" +  STRING(aux_qtavares)     + "'," +
                   "qtpartic:'" +  STRING(aux_qtpartic)     + "'," +
                   "qtavanre:'" +  STRING(aux_qtavanre)     + "'," +
                   "peavanre:'" +  STRING(aux_peavanre)     + "'," +
                   "nrseqdig:'" +  STRING(0)                + "'," +
                   "qtsugeve:'" +  STRING(0)                + "'," +
                   "dssugeve:'" +  STRING(aux_sugestao)     + "'"  + "~}".
                   
      END.

      /* Todas as sugestões com origem de avaliação */
      FOR FIRST craprap WHERE craprap.dtanoage = gnpapgd.dtanonov           AND
                              craprap.cdcooper = INT(ab_unmap.aux_cdcooper) AND
                              craprap.cdagenci = INT(ab_unmap.cdagenci)     AND
                              craprap.nrseqeve = INT(ab_unmap.nrseqeve)     NO-LOCK,
          FIRST crapiap WHERE crapiap.cdcooper = 0                AND
                              crapiap.cditeava = craprap.cditeava NO-LOCK,
          FIRST crapgap WHERE crapgap.cdcooper = 0                AND
                              crapgap.cdgruava = crapiap.cdgruava NO-LOCK
                              BREAK BY crapgap.nrordgru BY craprap.nrseqeve:

          IF FIRST-OF(craprap.nrseqeve) THEN DO:
          
             FOR EACH crapsdp WHERE crapsdp.idevento = craprap.idevento   AND
                                    crapsdp.cdcooper = craprap.cdcooper   AND
                                    crapsdp.cdagenci = craprap.cdagenci   AND
                                    crapsdp.nrmsgint = craprap.nrseqeve   AND
                                    crapsdp.cdorisug = 7                  NO-LOCK:

                 /* Trata a sugestão pois se tiver CTRL-J (quebra de linha), tem que trocar por '\n' */
                 aux_sugestao = "".
   
                 DO aux_contador = 1 TO LENGTH(crapsdp.dssugeve):
                    IF  SUBSTRING(crapsdp.dssugeve,aux_contador,1) = CHR(10) THEN
                        aux_sugestao = aux_sugestao + "~\n".
                    ELSE
                        aux_sugestao = aux_sugestao + SUBSTRING(crapsdp.dssugeve,aux_contador,1).
                 END.  

                 IF  vetorava = "" THEN  
                     vetorava = "~{" +   
                       "cdagenci:'" +  STRING(craprap.cdagenci) + "'," + 
                       "cdcooper:'" +  STRING(craprap.cdcooper) + "'," +
                       "cdevento:'" +  STRING(craprap.cdevento) + "'," +
                       "nrseqeve:'" +  STRING(aux_nrseqeve)     + "'," +
                       "iditeava:'" +  STRING(ROWID(craprap))   + "'," +
                       "tpiteava:'" +  STRING(3)                + "'," +
                       "cditeava:'" +  STRING(0)                + "'," +
                       "dsiteava:'" +  STRING(0)                + "'," +
                       "cdgruava:'" +  STRING(0)                + "'," +
                       "dsgruava:'" +  STRING(0)                + "'," +
                       "dsobserv:'" +  STRING(0)                + "'," +
                       "qtavabom:'" +  STRING(0)                + "'," +
                       "peavabom:'" +  STRING(0)                + "'," +
                       "qtavains:'" +  STRING(0)                + "'," +  
                       "peavains:'" +  STRING(0)                + "'," +
                       "qtavaoti:'" +  STRING(0)                + "'," +  
                       "peavaoti:'" +  STRING(0)                + "'," +
                       "qtavareg:'" +  STRING(0)                + "'," + 
                       "peavareg:'" +  STRING(0)                + "'," +
                       "qtavares:'" +  STRING(aux_qtavares)     + "'," +
                       "qtpartic:'" +  STRING(aux_qtpartic)     + "'," +
                       "qtavanre:'" +  STRING(0)                + "'," +
                       "peavanre:'" +  STRING(0)                + "'," +
                       "nrseqdig:'" +  STRING(crapsdp.nrseqdig) + "'," +
                       "qtsugeve:'" +  STRING(crapsdp.qtsugeve) + "'," +
                       "dssugeve:'" +  STRING(aux_sugestao)     + "'"  + "~}".
                       
                 ELSE
                    vetorava = vetorava + "," + "~{" +
                       "cdagenci:'" +  STRING(craprap.cdagenci) + "'," + 
                       "cdcooper:'" +  STRING(craprap.cdcooper) + "'," +
                       "cdevento:'" +  STRING(craprap.cdevento) + "'," +
                       "nrseqeve:'" +  STRING(craprap.nrseqeve) + "'," +
                       "iditeava:'" +  STRING(ROWID(craprap))   + "'," +
                       "tpiteava:'" +  STRING(3)                + "'," +
                       "cditeava:'" +  STRING(0)                + "'," +
                       "dsiteava:'" +  STRING(0)                + "'," +
                       "cdgruava:'" +  STRING(0)                + "'," +
                       "dsgruava:'" +  STRING(0)                + "'," +
                       "dsobserv:'" +  STRING(0)                + "'," +
                       "qtavabom:'" +  STRING(0)                + "'," +
                       "peavabom:'" +  STRING(0)                + "'," +
                       "qtavains:'" +  STRING(0)                + "'," +  
                       "peavains:'" +  STRING(0)                + "'," +
                       "qtavaoti:'" +  STRING(0)                + "'," +  
                       "peavaoti:'" +  STRING(0)                + "'," +
                       "qtavareg:'" +  STRING(0)                + "'," + 
                       "peavareg:'" +  STRING(0)                + "'," +
                       "qtavares:'" +  STRING(aux_qtavares)     + "'," +
                       "qtpartic:'" +  STRING(aux_qtpartic)     + "'," +
                       "qtavanre:'" +  STRING(0)                + "'," +
                       "peavanre:'" +  STRING(0)                + "'," +
                       "nrseqdig:'" +  STRING(crapsdp.nrseqdig) + "'," +
                       "qtsugeve:'" +  STRING(crapsdp.qtsugeve) + "'," +
                       "dssugeve:'" +  STRING(aux_sugestao)     + "'"  + "~}".
             END.
          END.
      END.

      RUN RodaJavaScript("var mava=new Array();mava=["  + vetorava + "]").

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
      /* A combo-box criada com estes elemento possui como valores os sequenciais dos eventos,
      ao invés dos códigos de evento. */
      
      DEFINE VARIABLE aux_tppartic AS CHAR NO-UNDO.
      DEFINE VARIABLE aux_flgcompr AS CHAR NO-UNDO.
      DEFINE VARIABLE aux_qtmaxtur AS CHAR NO-UNDO.
      DEFINE VARIABLE aux_nrinscri AS INT  NO-UNDO.
      DEFINE VARIABLE aux_nrconfir AS INT  NO-UNDO.
      DEFINE VARIABLE aux_nrseqeve AS INT  NO-UNDO.
      DEFINE VARIABLE aux_nrdturma AS INT  NO-UNDO.
      DEFINE VARIABLE aux_nmevento AS CHAR NO-UNDO.
      DEFINE VARIABLE vetormes     AS CHAR EXTENT 12.
      
      ASSIGN vetorevento = "".
      RUN RodaJavaScript("var mevento=new Array();"). 
      
      FOR EACH crapeap WHERE crapeap.idevento = INT(ab_unmap.aux_idevento)    AND
                             crapeap.cdcooper = INT(ab_unmap.aux_cdcooper)    AND
                             crapeap.cdagenci = INT(ab_unmap.cdagenci)        AND
                             crapeap.dtanoage = gnpapgd.dtanonov              AND
                             crapeap.flgevsel = YES                           NO-LOCK, 
         FIRST crapedp WHERE crapedp.cdevento = crapeap.cdevento              AND
                             crapedp.idevento = crapeap.idevento              AND
                             crapedp.cdcooper = crapeap.cdcooper              AND
                             crapedp.dtanoage = crapeap.dtanoage              NO-LOCK,
          EACH crapadp WHERE crapadp.idevento = crapeap.idevento              AND
                             crapadp.cdcooper = crapeap.cdcooper              AND
                             crapadp.cdagenci = crapeap.cdagenci              AND
                             crapadp.dtanoage = crapeap.dtanoage              AND
                             crapadp.cdevento = crapeap.cdevento              AND
                             crapadp.idstaeve <> 2                            NO-LOCK /*2 = cancelado*/
                             BREAK BY crapadp.cdagenci
                                      BY crapedp.nmevento
                                         BY crapadp.nrseqdig:
           
          FIND FIRST craptab WHERE craptab.cdcooper = 0               AND
                                   craptab.nmsistem = "CRED"          AND
                                   craptab.tptabela = "CONFIG"        AND
                                   craptab.cdempres = 0               AND
                                   craptab.cdacesso = "PGTPPARTIC"    AND
                                   craptab.tpregist = 0               NO-LOCK NO-ERROR.
      
          IF AVAILABLE craptab THEN
               ASSIGN aux_tppartic = ENTRY(LOOKUP(STRING(crapedp.tppartic), craptab.dstextab) - 1, craptab.dstextab).
          IF aux_tppartic = ? THEN
              aux_tppartic = "".
          
          IF crapedp.flgcompr = TRUE THEN
              aux_flgcompr = "TERMO DE COMPROMISSO".
          ELSE
              aux_flgcompr = "".
      
          IF crapedp.qtmaxtur <> ? THEN
              ASSIGN aux_qtmaxtur = STRING(crapedp.qtmaxtur).
          ELSE
              ASSIGN aux_qtmaxtur = "0".
      
          FOR EACH crapidp WHERE crapidp.idevento = crapeap.idevento  AND
                                 crapidp.cdcooper = crapeap.cdcooper  AND
                                 crapidp.dtanoage = crapeap.dtanoage  AND
                                 crapidp.cdagenci = crapeap.cdagenci  AND
                                 crapidp.cdevento = crapeap.cdevento  NO-LOCK:
      
              /* Pendentes e Confirmados */
              IF crapidp.idstains < 3 THEN
                  aux_nrinscri = aux_nrinscri + 1.
              
              /* Somente Confirmados */            
              IF crapidp.idstains = 2 THEN
                  aux_nrconfir = aux_nrconfir + 1.
          END.
      
          aux_nrseqeve = IF crapadp.nrseqdig <> ? THEN crapadp.nrseqdig ELSE 0.
                  aux_nmevento = crapedp.nmevento.
                                                                                     
          IF  crapadp.dtinieve <> ?  THEN
              aux_nmevento = aux_nmevento + " - " + STRING(crapadp.dtinieve,"99/99/9999").
          ELSE
          IF  crapadp.nrmeseve <> 0  AND crapadp.nrmeseve <> ? THEN
              aux_nmevento = aux_nmevento + " - " + vetormes[crapadp.nrmeseve].
      
          IF  crapadp.dshroeve <> "" THEN
              aux_nmevento = aux_nmevento + " - " + crapadp.dshroeve.
      
          vetorevento = "~{" +
                        "cdagenci:'" +  STRING(crapeap.cdagenci) + "'," + 
                        "cdcooper:'" +  STRING(crapeap.cdcooper) + "'," +
                        "cdevento:'" +  STRING(crapeap.cdevento) + "'," +
                        "nmevento:'" +  STRING(aux_nmevento)     + "'," +
                        "idstaeve:'" +  STRING(crapadp.idstaeve) + "'," +
                        "flgcompr:'" +  STRING(aux_flgcompr)     + "'," +
                        "qtmaxtur:'" +  STRING(aux_qtmaxtur)     + "'," +
                        "nrinscri:'" +  STRING(aux_nrinscri)     + "'," +
                        "nrconfir:'" +  STRING(aux_nrconfir)     + "'," +
                        "nrseqeve:'" +  STRING(aux_nrseqeve)     + "'," +
                        "tppartic:'" +  STRING(aux_tppartic) + "'" + "~}".
                  
          RUN RodaJavaScript("mevento.push("  + vetorevento + ");").    

          ASSIGN vetorevento = "".
      END.

  END PROCEDURE.
  /* _UIB-CODE-BLOCK-END */
  &ANALYZE-RESUME

  &ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaTema w-html 
  PROCEDURE CriaListaTema :
  /*------------------------------------------------------------------------------
    Purpose:     
    Parameters:  <none>
    Notes:       
  ------------------------------------------------------------------------------*/
     
     IF INT(ab_unmap.nrseqeve) <> 0 THEN
       DO:
       ASSIGN vetortema = "".
        
       FIND FIRST crapadp WHERE crapadp.idevento = 1 
                              AND crapadp.cdcooper = INT(ab_unmap.aux_cdcooper)
                              AND crapadp.cdagenci = INT(ab_unmap.cdagenci)
                              AND crapadp.nrseqdig = INT(ab_unmap.nrseqeve) NO-LOCK NO-ERROR NO-WAIT.
                              
       FOR EACH craptem WHERE craptem.idsittem = 'A' /* Ativo */
                          AND craptem.idrelava = 'S' /* Temas listados no relatório de Avaliação */
                   NO-LOCK BY craptem.dstemeix:
         
         ASSIGN aux_qtsugeve = 0
                aux_nrseqdig = 0.       
         
         FIND FIRST crapsdp WHERE crapsdp.nrseqtem = craptem.nrseqtem 
                              AND crapsdp.cdorisug = 8                          /* Avaliação Evento - Tema */
                              AND crapsdp.nrmsgint = INT(ab_unmap.nrseqeve)     /* Campo nrmsgint da tela */
                              AND crapsdp.cdcooper = INT(ab_unmap.aux_cdcooper) /* Cooperativa da tela */
                              AND crapsdp.cdagenci = INT(ab_unmap.cdagenci)     /* PA da tela */
                              AND crapsdp.cdevento = crapadp.cdevento           /* Evento da Tela */
                              NO-LOCK NO-ERROR NO-WAIT. 
         
         IF AVAILABLE crapsdp THEN
           DO:
              ASSIGN aux_qtsugeve = crapsdp.qtsugeve
                     aux_nrseqdig = crapsdp.nrseqdig.                         
           END.
            
         IF  vetortema = "" THEN
             vetortema = "~{" +
                  "cdeixtem:'" +  STRING(craptem.cdeixtem) + "'," + 
                  "nrseqtem:'" +  STRING(craptem.nrseqtem) + "'," +
                  "dstemeix:'" +  STRING(craptem.dstemeix) + "'," +
                  "nrseqdig:'" +  STRING(aux_nrseqdig)     + "'," +
                  "qtsugeve:'" +  STRING(aux_qtsugeve)     + "'"  + "~}".
          ELSE
              vetortema = vetortema + "," + "~{" +
                    "cdeixtem:'" +  STRING(craptem.cdeixtem) + "'," + 
                    "nrseqtem:'" +  STRING(craptem.nrseqtem) + "'," +
                    "dstemeix:'" +  STRING(craptem.dstemeix) + "'," +
                    "nrseqdig:'" +  STRING(aux_nrseqdig)     + "'," + 
                    "qtsugeve:'" +  STRING(aux_qtsugeve)     + "'"  + "~}".
       END.
      END.
      
      
      RUN RodaJavaScript("var mtema=new Array();mtema=["  + vetortema + "]"). 

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
      {includes/wpgd0099.i ab_unmap.aux_dtanoage}
      
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
      ("aux_dtanoage":U,"ab_unmap.aux_dtanoage":U,ab_unmap.aux_dtanoage:HANDLE IN FRAME {&FRAME-NAME}).
    RUN htmAssociate
      ("aux_idevento":U,"ab_unmap.aux_idevento":U,ab_unmap.aux_idevento:HANDLE IN FRAME {&FRAME-NAME}).
    RUN htmAssociate
      ("aux_iditeava":U,"ab_unmap.aux_iditeava":U,ab_unmap.aux_iditeava:HANDLE IN FRAME {&FRAME-NAME}).
    RUN htmAssociate
      ("aux_lsaltern":U,"ab_unmap.aux_lsaltern":U,ab_unmap.aux_lsaltern:HANDLE IN FRAME {&FRAME-NAME}).
    RUN htmAssociate
      ("aux_lsavabom":U,"ab_unmap.aux_lsavabom":U,ab_unmap.aux_lsavabom:HANDLE IN FRAME {&FRAME-NAME}).
    RUN htmAssociate
      ("aux_lsavains":U,"ab_unmap.aux_lsavains":U,ab_unmap.aux_lsavains:HANDLE IN FRAME {&FRAME-NAME}).
    RUN htmAssociate
      ("aux_lsavaoti":U,"ab_unmap.aux_lsavaoti":U,ab_unmap.aux_lsavaoti:HANDLE IN FRAME {&FRAME-NAME}).
    RUN htmAssociate
      ("aux_lsavareg":U,"ab_unmap.aux_lsavareg":U,ab_unmap.aux_lsavareg:HANDLE IN FRAME {&FRAME-NAME}).
    RUN htmAssociate
      ("aux_lsdescri":U,"ab_unmap.aux_lsdescri":U,ab_unmap.aux_lsdescri:HANDLE IN FRAME {&FRAME-NAME}).
    RUN htmAssociate
      ("aux_lsiteav2":U,"ab_unmap.aux_lsiteav2":U,ab_unmap.aux_lsiteav2:HANDLE IN FRAME {&FRAME-NAME}).
    RUN htmAssociate
      ("aux_lsiteava":U,"ab_unmap.aux_lsiteava":U,ab_unmap.aux_lsiteava:HANDLE IN FRAME {&FRAME-NAME}).
    RUN htmAssociate
      ("aux_lsobserv":U,"ab_unmap.aux_lsobserv":U,ab_unmap.aux_lsobserv:HANDLE IN FRAME {&FRAME-NAME}).
    RUN htmAssociate
      ("arrQtsugeve":U,"ab_unmap.arrQtsugeve":U,ab_unmap.arrQtsugeve:HANDLE IN FRAME {&FRAME-NAME}).
    RUN htmAssociate
      ("aux_lspermis":U,"ab_unmap.aux_lspermis":U,ab_unmap.aux_lspermis:HANDLE IN FRAME {&FRAME-NAME}).
    RUN htmAssociate
      ("aux_nrdrowid":U,"ab_unmap.aux_nrdrowid":U,ab_unmap.aux_nrdrowid:HANDLE IN FRAME {&FRAME-NAME}).
    RUN htmAssociate
      ("aux_nrseqeve":U,"ab_unmap.aux_nrseqeve":U,ab_unmap.aux_nrseqeve:HANDLE IN FRAME {&FRAME-NAME}).
    RUN htmAssociate
      ("aux_qtdparti":U,"ab_unmap.aux_qtdparti":U,ab_unmap.aux_qtdparti:HANDLE IN FRAME {&FRAME-NAME}).
    RUN htmAssociate
      ("aux_stdopcao":U,"ab_unmap.aux_stdopcao":U,ab_unmap.aux_stdopcao:HANDLE IN FRAME {&FRAME-NAME}).
    RUN htmAssociate
      ("cdagenci":U,"ab_unmap.cdagenci":U,ab_unmap.cdagenci:HANDLE IN FRAME {&FRAME-NAME}).
    RUN htmAssociate
      ("cdcooper":U,"ab_unmap.cdcooper":U,ab_unmap.cdcooper:HANDLE IN FRAME {&FRAME-NAME}).
    RUN htmAssociate
      ("nrseqeve":U,"ab_unmap.nrseqeve":U,ab_unmap.nrseqeve:HANDLE IN FRAME {&FRAME-NAME}).
    RUN htmAssociate
      ("pagina":U,"ab_unmap.pagina":U,ab_unmap.pagina:HANDLE IN FRAME {&FRAME-NAME}).
    RUN htmAssociate
      ("qtavares":U,"craprap.qtavares":U,craprap.qtavares:HANDLE IN FRAME {&FRAME-NAME}).
  END PROCEDURE.


  /* _UIB-CODE-BLOCK-END */
  &ANALYZE-RESUME

  &ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-assign-record w-html 
  PROCEDURE local-assign-record :
  DEFINE INPUT PARAMETER opcao AS CHARACTER.
      
      DEF VAR i AS INT NO-UNDO.
      
      DEF VAR aux_msgderro AS CHAR NO-UNDO.
      
      /* Instancia a BO para executar as procedures */
      RUN dbo/b1wpgd0029.p PERSISTENT SET h-b1wpgd0029.
      
      /* Se BO foi instanciada */
      IF VALID-HANDLE(h-b1wpgd0029) THEN
         DO:
      
            DO WITH FRAME {&FRAME-NAME}:
      
                /* Alternativos */
                DO i = 1 TO NUM-ENTRIES(ab_unmap.aux_lsiteava):
      
                    FIND FIRST craprap WHERE craprap.cdcooper = INT(ab_unmap.aux_cdcooper)            AND
                                             craprap.cdagenci = INT(ab_unmap.cdagenci)                AND
                                             craprap.idevento = INT(ab_unmap.aux_idevento)            AND
                                             craprap.cditeava = INT(ENTRY(i, ab_unmap.aux_lsiteava))  AND
                                             craprap.dtanoage = INT(ab_unmap.aux_dtanoage)            AND 
                                             craprap.nrseqeve = INT(ab_unmap.nrseqeve)
                                             NO-LOCK NO-ERROR.
      
                    IF AVAIL craprap THEN
                    DO:
                        EMPTY TEMP-TABLE cratrap.
      
                        CREATE cratrap.
                        ASSIGN cratrap.dsobserv = craprap.dsobserv
                               cratrap.cdagenci = craprap.cdagenci
                               cratrap.nrseqeve = craprap.nrseqeve
                               cratrap.cdcooper = craprap.cdcooper
                               cratrap.cdevento = craprap.cdevento
                               cratrap.cdgruava = craprap.cdgruava
                               cratrap.cditeava = craprap.cditeava
                               cratrap.dtanoage = craprap.dtanoage
                               cratrap.idevento = craprap.idevento
                               cratrap.qtavares = INPUT craprap.qtavares                  
                               cratrap.qtavabom = INT(ENTRY(i, ab_unmap.aux_lsavabom))
                               cratrap.qtavains = INT(ENTRY(i, ab_unmap.aux_lsavains))
                               cratrap.qtavaoti = INT(ENTRY(i, ab_unmap.aux_lsavaoti))
                               cratrap.qtavareg = INT(ENTRY(i, ab_unmap.aux_lsavareg)).
      
                        RUN altera-registro IN h-b1wpgd0029(INPUT TABLE cratrap, OUTPUT aux_msgderro).
      
                        msg-erro = msg-erro + aux_msgderro.
      
                    END. /* IF AVAIL craprap */
      
                END. /* DO i = 1 TO NUM-ENTRIES(ab_unmap.aux_lsiteava) */
      
                /* Descritivas */
                DO i = 1 TO NUM-ENTRIES(ab_unmap.aux_lsiteav2):
                    FIND FIRST craprap WHERE craprap.cdcooper = INT(ab_unmap.aux_cdcooper)            AND
                                             craprap.cdagenci = INT(ab_unmap.cdagenci)                AND
                                             craprap.idevento = INT(ab_unmap.aux_idevento)            AND
                                             craprap.cditeava = INT(ENTRY(i, ab_unmap.aux_lsiteav2))  AND
                                             craprap.dtanoage = INT(ab_unmap.aux_dtanoage)            AND 
                                             craprap.nrseqeve = INT(ab_unmap.nrseqeve)
                                             NO-LOCK NO-ERROR.
      
                    IF AVAIL craprap THEN
                    DO:
      
                        EMPTY TEMP-TABLE cratrap.
      
                        CREATE cratrap.
                        ASSIGN cratrap.qtavares = INPUT craprap.qtavares    
                               cratrap.dsobserv = ENTRY(i, ab_unmap.aux_lsobserv,"§")
                               cratrap.cdagenci = craprap.cdagenci
                               cratrap.nrseqeve = craprap.nrseqeve
                               cratrap.cdcooper = craprap.cdcooper
                               cratrap.cdevento = craprap.cdevento
                               cratrap.cdgruava = craprap.cdgruava
                               cratrap.cditeava = craprap.cditeava
                               cratrap.dtanoage = craprap.dtanoage
                               cratrap.idevento = craprap.idevento
                               cratrap.qtavabom = craprap.qtavabom
                               cratrap.qtavains = craprap.qtavains
                               cratrap.qtavaoti = craprap.qtavaoti
                               cratrap.qtavareg = craprap.qtavareg.
      
                        RUN altera-registro IN h-b1wpgd0029(INPUT TABLE cratrap, OUTPUT aux_msgderro).
      
                        msg-erro = msg-erro + aux_msgderro.
      
                    END. /* IF AVAIL craprap */
      
                END. /* DO i = 1 TO NUM-ENTRIES(ab_unmap.aux_lsiteava) */
                     
            END. /* DO WITH FRAME {&FRAME-NAME} */
         
            /* "mata" a instância da BO */
            DELETE PROCEDURE h-b1wpgd0029 NO-ERROR.
         
         END. /* IF VALID-HANDLE(h-b1wpgd0029) */
      
       /* Posiciona o registro */
       FIND FIRST craprap WHERE craprap.cdcooper = INT(ab_unmap.aux_cdcooper)             AND
                                craprap.cdagenci = INT(ab_unmap.cdagenci)                 AND
                                craprap.idevento = INT(ab_unmap.aux_idevento)             AND
                                craprap.cditeava = INT(ENTRY(i, ab_unmap.aux_lsiteava))   AND
                                craprap.dtanoage = INT(ab_unmap.aux_dtanoage)             AND 
                                craprap.nrseqeve = INT(ab_unmap.nrseqeve)                 NO-LOCK NO-ERROR.
              
  END PROCEDURE.

  /* _UIB-CODE-BLOCK-END */
  &ANALYZE-RESUME

  &ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-delete-record w-html 
  PROCEDURE local-delete-record :
      
  /* Verifica se algum PAC usou o item a ser excluido */
      FIND FIRST craprap WHERE ROWID(craprap) = TO-ROWID(ab_unmap.aux_iditeava) NO-LOCK NO-ERROR.

      FIND FIRST crabrap WHERE crabrap.idevento = craprap.idevento   AND
                               crabrap.cdcooper = craprap.cdcooper   AND
                               crabrap.dtanoage = craprap.dtanoage   AND
                               crabrap.cdevento = craprap.cdevento   AND
                               crabrap.cdgruava = craprap.cdgruava   AND
                               crabrap.cditeava = craprap.cditeava   AND

                              (crabrap.qtavabom <> 0                 OR
                               crabrap.qtavains <> 0                 OR
                               crabrap.qtavaoti <> 0                 OR
                               crabrap.qtavareg <> 0)                NO-LOCK NO-ERROR.

      IF   AVAILABLE crabrap   THEN
           DO:
              /*IF  crabrap.dsobserv <> ""  THEN */
                  ASSIGN msg-erro-aux = 3
                         msg-erro = "Este item já foi utilizado por algum PA. Impossível excluir!".

              RETURN.
           END.
      
      /* Instancia a BO para executar as procedures */
      RUN dbo/b1wpgd0029.p PERSISTENT SET h-b1wpgd0029.
       
      /* Se BO foi instanciada */
      IF VALID-HANDLE(h-b1wpgd0029) THEN
      DO:
          FOR EACH crabrap WHERE crabrap.idevento = craprap.idevento   AND
                                 crabrap.cdcooper = craprap.cdcooper   AND
                                 crabrap.dtanoage = craprap.dtanoage   AND
                                 crabrap.cdevento = craprap.cdevento   AND
                                 crabrap.cdgruava = craprap.cdgruava   AND
                                 crabrap.cditeava = craprap.cditeava   NO-LOCK:
          
              EMPTY TEMP-TABLE cratrap.

              CREATE cratrap.
              ASSIGN cratrap.dsobserv = crabrap.dsobserv
                     cratrap.cdagenci = crabrap.cdagenci
                     cratrap.nrseqeve = crabrap.nrseqeve
                     cratrap.cdcooper = crabrap.cdcooper
                     cratrap.cdevento = crabrap.cdevento
                     cratrap.cdgruava = crabrap.cdgruava
                     cratrap.cditeava = crabrap.cditeava
                     cratrap.dtanoage = crabrap.dtanoage
                     cratrap.idevento = crabrap.idevento
                     cratrap.qtavares = crabrap.qtavares    
                     cratrap.qtavabom = crabrap.qtavabom
                     cratrap.qtavains = crabrap.qtavains
                     cratrap.qtavaoti = crabrap.qtavaoti
                     cratrap.qtavareg = crabrap.qtavareg.

                  
              RUN exclui-registro IN h-b1wpgd0029(INPUT TABLE cratrap, OUTPUT msg-erro).
          
          END.
          /* "mata" a instância da BO */
          DELETE PROCEDURE h-b1wpgd0029 NO-ERROR.
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

  DEF BUFFER crabsdp FOR crapsdp.

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
         ab_unmap.aux_iditeava    = GET-VALUE("aux_iditeava")
         ab_unmap.cdcooper        = GET-VALUE("cdcooper")
         ab_unmap.cdagenci        = GET-VALUE("cdagenci")
         ab_unmap.nrseqeve        = GET-VALUE("nrseqeve")
         ab_unmap.aux_lsiteava    = GET-VALUE("aux_lsiteava")
         ab_unmap.aux_lsavaoti    = GET-VALUE("aux_lsavaoti")
         ab_unmap.aux_lsavabom    = GET-VALUE("aux_lsavabom")
         ab_unmap.aux_lsavareg    = GET-VALUE("aux_lsavareg")
         ab_unmap.aux_lsavains    = GET-VALUE("aux_lsavains")
         ab_unmap.pagina          = GET-VALUE("pagina")
         ab_unmap.aux_lsiteav2    = GET-VALUE("aux_lsiteav2")
         ab_unmap.aux_lsobserv    = GET-VALUE("aux_lsobserv")
         ab_unmap.aux_dtanoage    = GET-VALUE("aux_dtanoage")
         ab_unmap.arrQtsugeve    = GET-VALUE("arrQtsugeve").
         
  RUN outputHeader.

  {includes/wpgd0098.i}

  ab_unmap.aux_cdcooper:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = aux_crapcop.

  /* Se a cooperativa ainda não foi escolhida, pega a da sessão do usuário */
  IF   INT(ab_unmap.aux_cdcooper) = 0   THEN
       ab_unmap.aux_cdcooper = STRING(gnapses.cdcooper).

  /* Se o PAC ainda não foi escolhido, pega o da sessão do usuário */
  IF   INT(ab_unmap.cdagenci) = 0   THEN
       ab_unmap.cdagenci = STRING(gnapses.cdagenci).

  /* Posiciona por default, na agenda atual */
  IF   ab_unmap.aux_dtanoage = ""   THEN
       FIND LAST gnpapgd WHERE gnpapgd.idevento = INT(ab_unmap.aux_idevento) AND 
                               gnpapgd.cdcooper = INT(ab_unmap.aux_cdcooper) AND 
                               gnpapgd.dtanoage = INT(ab_unmap.aux_dtanoage) NO-LOCK NO-ERROR.
  ELSE
       /* Se informou a data da agenda, permite que veja a agenda de um ano não atual */
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
     DO:
         IF   ab_unmap.aux_dtanoage = ""   THEN
              ab_unmap.aux_dtanoage = STRING(gnpapgd.dtanoage).
         ELSE
              ab_unmap.aux_dtanoage = STRING(gnpapgd.dtanonov).
     END.


  /*******/   

  /* método POST */
  IF REQUEST_METHOD = "POST":U THEN 
     DO:
        RUN inputFields.
        CASE opcao:
             WHEN "sa" THEN /* salvar */
                  DO:
                      IF ab_unmap.aux_stdopcao = "i" THEN /* inclusao */
                          DO: 
                            
                              ASSIGN aux_cont = NUM-ENTRIES(ab_unmap.arrQtsugeve,"#").
                             
                              DO aux_regi = 1 TO aux_cont:

                                aux_info = entry(aux_regi,ab_unmap.arrQtsugeve,"#").
                                IF INT(ENTRY(2,aux_info,",")) = 0 AND 
                                   INT(ENTRY(3,aux_info,",")) = 0 THEN
                                   NEXT.
                                
                                FIND FIRST crapadp WHERE crapadp.idevento = 1 
                                                     AND crapadp.cdcooper = INT(ab_unmap.aux_cdcooper)
                                                     AND crapadp.cdagenci = INT(ab_unmap.cdagenci)
                                                     AND crapadp.nrseqdig = INT(ab_unmap.nrseqeve) NO-LOCK NO-ERROR NO-WAIT.
                                
                                IF INT(ENTRY(3,aux_info,",")) > 0 THEN
                                  DO: 
                                    FIND LAST crapsdp WHERE crapsdp.idevento = 1
                                                        AND crapsdp.cdcooper = INT(ab_unmap.aux_cdcooper)
                                                        AND crapsdp.cdagenci = INT(ab_unmap.cdagenci)
                                                        AND crapsdp.nrseqdig = INT(ENTRY(3,aux_info,",")) EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                    IF AVAILABLE crapsdp THEN
                                    DO:
                                      ASSIGN aux_qtsugeve = crapsdp.qtsugeve.
                                      IF INT(ENTRY(2,aux_info,",")) = aux_qtsugeve  THEN
                                        DO:
                                          NEXT.
                                        END.
                                      FIND CURRENT crapsdp EXCLUSIVE-LOCK.
                                    END.
                                  END.
                                ELSE IF INT(ENTRY(2,aux_info,",")) > 0 THEN   
                                  DO:   
                                    FIND LAST crapsdp EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                    ASSIGN aux_nrseqdig = crapsdp.nrseqdig + 1
                                           aux_qtsugeve = 0.
                                    DO WHILE TRUE:
                                      FOR FIRST crabsdp WHERE crabsdp.nrseqdig = aux_nrseqdig NO-LOCK: END.
                                      IF avail crabsdp THEN 
                                      DO:
                                        ASSIGN aux_nrseqdig = aux_nrseqdig + 1.
                                        NEXT.
                                      END.
                                      CREATE crapsdp.
                                      ASSIGN crapsdp.idevento = 1
                                             crapsdp.cdcooper = INT(ab_unmap.aux_cdcooper)  /* Cooperativa da tela */
                                             crapsdp.cdagenci = INT(ab_unmap.cdagenci)      /* Codigo do PA */
                                             crapsdp.nrseqdig = aux_nrseqdig.
                                      LEAVE.
                                    END.
                                  END.                                   
                                
                                IF INT(ENTRY(2,aux_info,",")) > 0 THEN
                                  DO:
                                      ASSIGN crapsdp.idevento = 1
                                             crapsdp.cdcooper = INT(ab_unmap.aux_cdcooper)  /* Cooperativa da tela */
                                             crapsdp.cdagenci = INT(ab_unmap.cdagenci)      /* Codigo do PA */
                                             crapsdp.nrseqtem = INT(ENTRY(1,aux_info,","))  
                                             crapsdp.dtmvtolt = TODAY
                                             crapsdp.flgsugca = NO 
                                             crapsdp.cdorisug = 8                           /* Avaliação Evento - Tema */
                                             crapsdp.dtanoage = ?                           /* Ano da Agenda */
                                             crapsdp.nrmsgint = INT(ab_unmap.nrseqeve)      /* Campo nrmsgint da tela */
                                             crapsdp.qtsugeve = INT(ENTRY(2,aux_info,","))  /* Quantidade de Sugestoes */                                      
                                             crapsdp.cdevento = crapadp.cdevento
                                             crapsdp.cdoperad = gnapses.cdoperad
                                             crapsdp.dssugeve = "Sugestao criada por tema a partir da avaliacao do evento".
                                  END.
                                ELSE
                                  DO:
                                    DELETE crapsdp.
                                  END.
                                                                    
                                RUN local-assign-record ("inclusao"). 
                                IF msg-erro <> "" THEN
                                   ASSIGN msg-erro-aux = 3. /* erros da validação de dados */
                                ELSE 
                                DO:
                                   ASSIGN 
                                       msg-erro-aux = 10
                                       ab_unmap.aux_stdopcao = "al".
                                END.
                              
                              END.
                                
                              RUN local-assign-record ("inclusao"). 
                              IF msg-erro <> "" THEN
                                 ASSIGN msg-erro-aux = 3. /* erros da validação de dados */
                              ELSE 
                              DO:
                                 ASSIGN msg-erro-aux = 10
                                        ab_unmap.aux_stdopcao = "al".
                              END.
                          END.  /* fim inclusao */
                      ELSE     /* alteração */ 
                        DO:
                          ASSIGN aux_cont = NUM-ENTRIES(ab_unmap.arrQtsugeve,"#").
                          
                          DO aux_regi = 1 TO aux_cont:
                            
                            aux_info = entry(aux_regi,ab_unmap.arrQtsugeve,"#").
                            IF INT(ENTRY(2,aux_info,",")) = 0 AND 
                               INT(ENTRY(3,aux_info,",")) = 0 THEN
                               NEXT.
                            
                            FIND FIRST crapadp WHERE crapadp.idevento = 1 
                                                 AND crapadp.cdcooper = INT(ab_unmap.aux_cdcooper)
                                                 AND crapadp.cdagenci = INT(ab_unmap.cdagenci)
                                                 AND crapadp.nrseqdig = INT(ab_unmap.nrseqeve) NO-LOCK NO-ERROR NO-WAIT.
                            
                            IF INT(ENTRY(3,aux_info,",")) > 0 THEN
                              DO: 
                                FIND LAST crapsdp WHERE crapsdp.idevento = 1
                                                    AND crapsdp.cdcooper = INT(ab_unmap.aux_cdcooper)
                                                    AND crapsdp.cdagenci = INT(ab_unmap.cdagenci)
                                                    AND crapsdp.nrseqdig = INT(ENTRY(3,aux_info,",")) EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                IF AVAILABLE crapsdp THEN
                                DO:
                                  ASSIGN aux_qtsugeve = crapsdp.qtsugeve.
                                  IF INT(ENTRY(2,aux_info,",")) = aux_qtsugeve  THEN
                                    DO:
                                      NEXT.
                                    END.
                                  FIND CURRENT crapsdp EXCLUSIVE-LOCK.
                                END.
                              END.
                            ELSE IF INT(ENTRY(2,aux_info,",")) > 0 THEN   
                              DO:
                                FIND LAST crapsdp EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                ASSIGN aux_nrseqdig = crapsdp.nrseqdig + 1
                                       aux_qtsugeve = 0.
                                DO WHILE TRUE:
                                  FOR FIRST crabsdp WHERE crabsdp.nrseqdig = aux_nrseqdig NO-LOCK: END.
                                  IF avail crabsdp THEN 
                                  DO:
                                    ASSIGN aux_nrseqdig = aux_nrseqdig + 1.
                                    NEXT.
                                  END.
                                  
                                  CREATE crapsdp.
                                  ASSIGN crapsdp.idevento = 1
                                         crapsdp.cdcooper = INT(ab_unmap.aux_cdcooper)  /* Cooperativa da tela */
                                         crapsdp.cdagenci = INT(ab_unmap.cdagenci)      /* Codigo do PA */
                                         crapsdp.nrseqdig = aux_nrseqdig.
                                  LEAVE.
                                END.
                              END.                                           
                        
                            IF INT(ENTRY(2,aux_info,",")) > 0 THEN
                              DO: 
                                  ASSIGN crapsdp.nrseqtem = INT(ENTRY(1,aux_info,","))
                                         crapsdp.idevento = 1
                                         crapsdp.dtmvtolt = TODAY
                                         crapsdp.flgsugca = NO 
                                         crapsdp.cdorisug = 8                           /* Avaliação Evento - Tema */
                                         crapsdp.dtanoage = ?                           /* Ano da Agenda */
                                         crapsdp.nrmsgint = INT(ab_unmap.nrseqeve)      /* Campo nrmsgint da tela */
                                         crapsdp.cdcooper = INT(ab_unmap.aux_cdcooper)  /* Cooperativa da tela */
                                         crapsdp.cdagenci = INT(ab_unmap.cdagenci)      /* Codigo do PA */
                                         crapsdp.qtsugeve = INT(ENTRY(2,aux_info,","))  /* Quantidade de Sugestoes */                                      
                                         crapsdp.cdevento = crapadp.cdevento
                                         crapsdp.cdoperad = gnapses.cdoperad
                                         crapsdp.dssugeve = "Sugestao criada por tema a partir da avaliacao do evento".
                              END.
                            ELSE
                              DO:                          
                                DELETE crapsdp.
                              END.
                    
                            RUN local-assign-record ("inclusao"). 
                    
                            IF msg-erro <> "" THEN
                              ASSIGN msg-erro-aux = 3. /* erros da validação de dados */
                            ELSE 
                              DO:
                                ASSIGN msg-erro-aux = 10
                                       ab_unmap.aux_stdopcao = "al".
                              END.                    
                        END.
                        
                        /***/
                        RUN local-assign-record ("inclusao"). 
                    
                        IF msg-erro <> "" THEN
                          ASSIGN msg-erro-aux = 3. /* erros da validação de dados */
                        ELSE 
                          DO:
                            ASSIGN msg-erro-aux = 10
                                   ab_unmap.aux_stdopcao = "al".
                          END.
                        /***/
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
              DO:
                RUN PosicionaNoPrimeiro.
              END.
             WHEN "ul" THEN /* ultimo */
              DO:
                RUN PosicionaNoUltimo.
              END.
        
             WHEN "an" THEN /* anterior */
              DO:
              
               RUN PosicionaNoAnterior.
              END.
        
             WHEN "se" THEN /* seguinte */
             DO:
                  RUN PosicionaNoSeguinte.
             END.

             WHEN "exa" THEN /* exclui item de avaliação */
             DO:
                 RUN local-delete-record.
                 
                 IF   msg-erro = ""   THEN
                      msg-erro-aux = 10.
             END.
      
        END CASE.

        IF msg-erro-aux = 10 OR (opcao <> "sa" AND opcao <> "ex" AND opcao <> "in") THEN
           RUN displayFields.

        RUN CriaListaPac.
        RUN CriaListaEvento.
        RUN CriaListaAva.
        RUN CriaListaTema.
   
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
                      RUN CriaListaEvento.
                      RUN CriaListaAva.
                      RUN CriaListaTema.

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

