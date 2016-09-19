/*...............................................................................

Altera��es: 10/12/2008 - Melhoria de performance para a tabela gnapses (Evandro).

            04/05/2009 - Utilizar cdcooper = 0 nas consultas (David).
            
            29/11/2011 - Inclus�o do SUBSTRING na fun��o PUSH para desconsiderar
                         a v�rgula no in�cio da fun��o e carregar corretamente os
                         eventos em tela (Isara - RKAM).
						 
            05/06/2012 - Adapta��o dos fontes para projeto Oracle. Alterado
                         busca na gnapses de CONTAINS para MATCHES (Guilherme Maba).
                         
            10/08/2015 - Ajustes para projeto 229 - Melhorias OQS (Jean Michel). 
            
            24/09/2015 - Alterado crapeap.flgevsel = TRUE para FALSE (Jean Michel).
            
            17/12/2015 -  Alterado crapeap.flgevsel = FALSE para 
                          IF crapedp.tpevento = 2 THEN TRUE -- Integra��o j� � escolhida 
                                                 ELSE FALSE -- PA ainda n�o escolheu (Vanessa)

..............................................................................................*/

&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD aux_cdcooper AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_cdevento AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dtanoage AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lsevento AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
       FIELD glb_cdcooper AS CHARACTER FORMAT "X(256)":U .


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
DEFINE VARIABLE ProgramaEmUso         AS CHARACTER INITIAL ["wpgd0014a"].
DEFINE VARIABLE NmeDoPrograma         AS CHARACTER INITIAL ["wpgd0014a.w"].

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

DEFINE VARIABLE vetoreventos          AS CHARACTER                      NO-UNDO.
DEFINE VARIABLE aux_ttcabeca          AS INTEGER                        NO-UNDO.
DEFINE VARIABLE aux_dsorigem          AS CHARACTER     EXTENT 99        NO-UNDO.
DEFINE VARIABLE aux_qtorigem          AS INTEGER       EXTENT 99        NO-UNDO.
DEFINE VARIABLE aux_qttoteve          AS INTEGER                        NO-UNDO.
DEFINE VARIABLE aux_qttotdes          AS INTEGER                        NO-UNDO.
DEFINE VARIABLE aux_flgevobr          AS LOGICAL                        NO-UNDO.


/*** Declara��o de BOs ***/
DEFINE VARIABLE h-b1wpgd0014a         AS HANDLE                         NO-UNDO.
DEFINE VARIABLE h-b1wpgd0018          AS HANDLE                         NO-UNDO.

/*** Temp Tables ***/
DEFINE TEMP-TABLE cratedp NO-UNDO     LIKE crapedp.
DEFINE TEMP-TABLE cratcdp NO-UNDO     LIKE crapcdp.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE fontes/wpgd0014a.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS ab_unmap.aux_cdcooper ab_unmap.glb_cdcooper ~
ab_unmap.aux_lsevento ab_unmap.aux_cddopcao ab_unmap.aux_cdevento ~
ab_unmap.aux_dsendurl ab_unmap.aux_idevento ab_unmap.aux_lspermis ~
ab_unmap.aux_nrdrowid ab_unmap.aux_stdopcao ab_unmap.aux_dtanoage 
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.aux_cdcooper ~
ab_unmap.glb_cdcooper ab_unmap.aux_lsevento ab_unmap.aux_cddopcao ~
ab_unmap.aux_cdevento ab_unmap.aux_dsendurl ab_unmap.aux_idevento ~
ab_unmap.aux_lspermis ab_unmap.aux_nrdrowid ab_unmap.aux_stdopcao ~
ab_unmap.aux_dtanoage 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME

/* ***********************  Control Definitions  ********************** */
/* Definitions of the field level widgets                               */
/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     ab_unmap.aux_cdcooper AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.glb_cdcooper AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_lsevento AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cddopcao AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cdevento AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_dsendurl AT ROW 1 COL 1 HELP
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
     ab_unmap.aux_dtanoage AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 49.4 BY 16.33.


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
          FIELD aux_cdcooper AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_cdevento AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dtanoage AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lsevento AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
          FIELD glb_cdcooper AS CHARACTER FORMAT "X(256)":U 
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW w-html ASSIGN
         HEIGHT             = 16.33
         WIDTH              = 49.4.
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
/* SETTINGS FOR FILL-IN ab_unmap.aux_cdcooper IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_cddopcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_cdevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dsendurl IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dtanoage IN FRAME Web-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN ab_unmap.aux_idevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lsevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lspermis IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nrdrowid IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_stdopcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.glb_cdcooper IN FRAME Web-Frame
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
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaEventos w-html 
PROCEDURE CriaListaEventos :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEF VAR aux_dstemeix AS CHAR        NO-UNDO.

    ASSIGN vetoreventos = "".
    
    vetoreventos = "~{qtdcolun:'4',dseixtem:'Eixo Tem�tico',dstemeix:'Tema',cdevento:'0',nmevento:'Evento',flgtdpac:'Obrig.'~}".
    
    /* Carrega o array com todos os Eventos Ativos e sugest�es*/
    FOR EACH crapedp WHERE crapedp.cdcooper = 0                                 AND
                           crapedp.idevento = INTEGER(ab_unmap.aux_idevento)    AND 
                           crapedp.dtanoage = 0                                 AND
                           crapedp.flgativo = TRUE                              NO-LOCK,
       FIRST craptem WHERE craptem.cdcooper = 0                                 AND
                           craptem.nrseqtem = crapedp.nrseqtem                  NO-LOCK,                   
       FIRST gnapetp WHERE gnapetp.cdcooper = craptem.cdcooper                                 AND
                           gnapetp.idevento = crapedp.idevento                  AND
                           gnapetp.cdeixtem = craptem.cdeixtem                  NO-LOCK
                           BY gnapetp.dseixtem
                             BY craptem.dstemeix
                               BY crapedp.nmevento:    
                                    
         IF AVAILABLE craptem THEN
           ASSIGN aux_dstemeix = craptem.dstemeix.
         ELSE
           ASSIGN aux_dstemeix = "---------".
        
         ASSIGN vetoreventos = vetoreventos + ",~{dseixtem:'" + gnapetp.dseixtem + "',dstemeix:'" +
                                              STRING(aux_dstemeix) + "',cdevento:'" + 
                                              STRING(crapedp.cdevento) + "',nmevento:'" + crapedp.nmevento + "'" +
                                              ",flgtdpac:'" + STRING(crapedp.flgtdpac,"Sim/N�o") + "'}".

    END. /* FOR EACH crapedp WHERE */

    RUN RodaJavaScript("var meventos=new Array();meventos=[" + vetoreventos + "]").

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
    ("aux_dtanoage":U,"ab_unmap.aux_dtanoage":U,ab_unmap.aux_dtanoage:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idevento":U,"ab_unmap.aux_idevento":U,ab_unmap.aux_idevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lsevento":U,"ab_unmap.aux_lsevento":U,ab_unmap.aux_lsevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lspermis":U,"ab_unmap.aux_lspermis":U,ab_unmap.aux_lspermis:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrdrowid":U,"ab_unmap.aux_nrdrowid":U,ab_unmap.aux_nrdrowid:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_stdopcao":U,"ab_unmap.aux_stdopcao":U,ab_unmap.aux_stdopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("glb_cdcooper":U,"ab_unmap.glb_cdcooper":U,ab_unmap.glb_cdcooper:HANDLE IN FRAME {&FRAME-NAME}).
END PROCEDURE.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-assign-record w-html 
PROCEDURE local-assign-record :
DEFINE INPUT PARAMETER opcao AS CHARACTER.
    
    DEF VAR aux_tpcuseve AS INT  NO-UNDO.
    DEF VAR tmp_nrdrowid AS CHAR NO-UNDO.
    DEF VAR aux_msgderro AS CHAR NO-UNDO.
    
    /* Instancia a BO para executar as procedures */
    RUN dbo/b1wpgd0014a.p PERSISTENT SET h-b1wpgd0014a.
    RUN dbo/b1wpgd0018.p PERSISTENT SET h-b1wpgd0018.
    
    /* Se BO foi instanciada */
    IF VALID-HANDLE(h-b1wpgd0014a) AND VALID-HANDLE(h-b1wpgd0018) THEN
    DO:
       DO WITH FRAME {&FRAME-NAME}:
          IF   opcao = "inclusao"   THEN
          DO: 
    
             /* procura o evento de integra��o. Ele deve ser incorporado � lista */
              FIND FIRST crapedp WHERE crapedp.tpevento = 2 NO-LOCK NO-ERROR.
              IF AVAILABLE crapedp THEN
                  ASSIGN ab_unmap.aux_lsevento = ab_unmap.aux_lsevento + "," + STRING(crapedp.cdevento).
             
             /* Cria os registros para os Eventos escolhidos */
             DO i = 1 TO NUM-ENTRIES(ab_unmap.aux_lsevento,","):
                 
                FOR EACH crapagp WHERE crapagp.idevento = INTEGER(ab_unmap.aux_idevento)  AND
                                       crapagp.cdcooper = INTEGER(ab_unmap.aux_cdcooper)  AND
                                       crapagp.dtanoage = INTEGER(ab_unmap.aux_dtanoage) NO-LOCK
                                       BREAK BY crapagp.cdageagr:
                  
                  IF FIRST-OF(crapagp.cdageagr) THEN                     
                    DO:
                        FIND crapeap WHERE crapeap.idevento = INTEGER(ab_unmap.aux_idevento)
                                       AND crapeap.cdcooper = INTEGER(ab_unmap.aux_cdcooper)
                                       AND crapeap.dtanoage = INTEGER(ab_unmap.aux_dtanoage)
                                       AND crapeap.cdevento = INTEGER(ENTRY(i,ab_unmap.aux_lsevento))
                                       AND crapeap.cdagenci = crapagp.cdageagr NO-LOCK NO-ERROR NO-WAIT.

                        IF NOT AVAILABLE crapeap THEN         
                          DO:
                            FIND crapedp WHERE crapedp.cdcooper = 0
                                           AND crapedp.cdevento = INTEGER(ENTRY(i,ab_unmap.aux_lsevento))
                                           AND crapedp.idevento = INTEGER(ab_unmap.aux_idevento)
                                           AND crapedp.dtanoage = 0                                 
                                           AND crapedp.flgativo = TRUE NO-LOCK NO-ERROR NO-WAIT.                   
                          
                            IF AVAILABLE crapedp THEN
                              DO:
                                
                                ASSIGN aux_flgevobr = crapedp.flgtdpac.                                
                              END.
                            ELSE
                              DO:
                                
                                ASSIGN aux_flgevobr = FALSE.
                              END.
                              
                            CREATE crapeap.
                            ASSIGN crapeap.idevento = INTEGER(ab_unmap.aux_idevento)
                                   crapeap.cdcooper = INTEGER(ab_unmap.aux_cdcooper)
                                   crapeap.dtanoage = INTEGER(ab_unmap.aux_dtanoage)
                                   crapeap.cdevento = INTEGER(ENTRY(i,ab_unmap.aux_lsevento))
                                   crapeap.cdagenci = crapagp.cdageagr
                                   crapeap.flgevobr = aux_flgevobr
                                   crapeap.flgevsel =  IF crapedp.tpevento = 2 THEN TRUE  /* Integra��o j� � escolhida */
                                                        ELSE FALSE /* PA ainda n�o escolheu */
                                   crapeap.qtmaxtur = 0.
                          END.
                          
                      
                    END.            
                END.
                
                /* procura se o Evento j� foi criado para a Cooperativa */
                FIND crapedp WHERE crapedp.cdcooper = INTEGER(ab_unmap.aux_cdcooper)           AND
                                   crapedp.cdevento = INTEGER(ENTRY(i,ab_unmap.aux_lsevento))  AND
                                   crapedp.idevento = INTEGER(ab_unmap.aux_idevento)           AND
                                   crapedp.dtanoage = INTEGER(ab_unmap.aux_dtanoage)           
                                   NO-LOCK NO-ERROR.
                
                IF   NOT AVAILABLE crapedp THEN
                DO: 
                   /* Busca o evento gen�rico e "copia" para a cooperativa 
                      eventos gen�ricos n�o possuem cooperativa nem ano de agenda */
                   FIND crapedp WHERE crapedp.cdcooper = 0                                        AND  
                                      crapedp.idevento = INTEGER(ab_unmap.aux_idevento)           AND 
                                      crapedp.dtanoage = 0                                        AND
                                      crapedp.cdevento = INTEGER(ENTRY(i,ab_unmap.aux_lsevento))  
                                      NO-LOCK NO-ERROR.
    
                   IF   NOT AVAILABLE crapedp  THEN NEXT.
    
                   /* Apaga os registros da tabela tempor�ria para n�o acumular os eventos */
                   EMPTY TEMP-TABLE cratedp.
                   
                   CREATE cratedp.
                   BUFFER-COPY crapedp TO cratedp.
    
                   ASSIGN cratedp.cdcooper = INTEGER(ab_unmap.aux_cdcooper)
                          cratedp.dtanoage = INTEGER(ab_unmap.aux_dtanoage).
    
                   RUN inclui-registro IN h-b1wpgd0014a(INPUT TABLE cratedp, OUTPUT msg-erro).
    
                   /* Se n�o teve problemas para criar o evento, cria tamb�m os registros de custos */
                   IF msg-erro = "" THEN
                   DO:
                       FIND FIRST craptab WHERE craptab.cdcooper = 0            AND
                                                craptab.nmsistem = "CRED"       AND
                                                craptab.tptabela = "CONFIG"     AND
                                                craptab.cdempres = 0            AND
                                                craptab.cdacesso = "PGDCUSTEVE" AND
                                                craptab.tpregist = 0            NO-LOCK NO-ERROR.
    
                       IF NOT AVAIL craptab THEN
                       DO:
                           ASSIGN msg-erro = msg-erro + "Problemas com a tabela CRAPTAB. ". 
                           LEAVE.
                       END.
                        
                       /* Para todos os tipos de custo dos eventos */
                       DO aux_tpcuseve = 1 TO (NUM-ENTRIES(craptab.dstextab) / 2):
    
                           /* Apaga a tabela tempor�ria */
                           FIND FIRST cratcdp NO-ERROR.
                           IF AVAIL cratcdp THEN
                               DELETE cratcdp.
        
                           /* Cria novo registro na tabela tempor�ria, de acordo com o evento gravado */
                           CREATE cratcdp.
                           ASSIGN cratcdp.cdagenci = 0
                                  cratcdp.cdcooper = cratedp.cdcooper
                                  cratcdp.cdcuseve = INT(ENTRY(aux_tpcuseve * 2, craptab.dstextab))
                                  cratcdp.cdevento = cratedp.cdevento
                                  cratcdp.dtanoage = cratedp.dtanoage
                                  cratcdp.idevento = cratedp.idevento
                                  cratcdp.tpcuseve = 1 /* Sempre cria registro pra custos diretos */ 
                                  cratcdp.vlcuseve = 0.
    
                           /* Verifica se j� existe registro de custo criado para este evento */
                           FIND FIRST crapcdp WHERE crapcdp.idevento = cratcdp.idevento AND
                                                    crapcdp.cdcooper = cratcdp.cdcooper AND
                                                    crapcdp.cdagenci = cratcdp.cdagenci AND
                                                    crapcdp.dtanoage = cratcdp.dtanoage AND
                                                    crapcdp.tpcuseve = cratcdp.tpcuseve AND
                                                    crapcdp.cdevento = cratcdp.cdevento AND
                                                    crapcdp.cdcuseve = cratcdp.cdcuseve NO-LOCK NO-ERROR.
    
                           /* Se n�o tem, cria */
                           IF NOT AVAIL crapcdp THEN
                               RUN inclui-registro IN h-b1wpgd0018(INPUT TABLE cratcdp, OUTPUT aux_msgderro, OUTPUT tmp_nrdrowid).
    
                           msg-erro = msg-erro + aux_msgderro.
                       END. /* DO aux_tpcuseve */

                       /* Cria o registro do custo dos termos de compromisso */
                       EMPTY TEMP-TABLE cratcdp.

                       CREATE cratcdp.
                       ASSIGN cratcdp.cdagenci = 0
                              cratcdp.cdcooper = cratedp.cdcooper
                              cratcdp.cdcuseve = 1
                              cratcdp.cdevento = cratedp.cdevento
                              cratcdp.dtanoage = cratedp.dtanoage
                              cratcdp.idevento = cratedp.idevento
                              cratcdp.tpcuseve = 4 /* custos dos termos */ 
                              cratcdp.vlcuseve = 0
                              cratcdp.prdescon = 0.

                       /* Verifica se j� existe registro de custo criado para este evento */
                       FIND FIRST crapcdp WHERE crapcdp.idevento = cratcdp.idevento AND
                                                crapcdp.cdcooper = cratcdp.cdcooper AND
                                                crapcdp.cdagenci = cratcdp.cdagenci AND
                                                crapcdp.dtanoage = cratcdp.dtanoage AND
                                                crapcdp.tpcuseve = cratcdp.tpcuseve AND
                                                crapcdp.cdevento = cratcdp.cdevento AND
                                                crapcdp.cdcuseve = cratcdp.cdcuseve NO-LOCK NO-ERROR.

                       /* Se n�o tem, cria */
                       IF NOT AVAIL crapcdp THEN
                           RUN inclui-registro IN h-b1wpgd0018(INPUT TABLE cratcdp, OUTPUT aux_msgderro, OUTPUT tmp_nrdrowid).

                       msg-erro = msg-erro + aux_msgderro.
                   END. /* IF msg-erro = "" */ 
                END. /* IF   NOT AVAILABLE crapedp */
             END. /* DO i = 1 TO NUM-ENTRIES(ab_unmap.aux_lsevento,",") */
          END. /* IF   opcao = "inclusao"  */    
       END. /* DO WITH FRAME {&FRAME-NAME} */
    
       /* "mata" a inst�ncia da BO */
       DELETE PROCEDURE h-b1wpgd0014a NO-ERROR.
       DELETE PROCEDURE h-b1wpgd0018 NO-ERROR.
    END. /* IF VALID-HANDLE(h-b1wpgd0014a) */
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
    
    /* Permiss�o fixa, uma vez que ele j� tem permiss�o para a tela que 'chamou' */ 
    ASSIGN v-identificacao = get-cookie("cookie-usuario-em-uso")
           v-permissoes    = "IAEPLU".


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
  
ASSIGN opcao                 = GET-FIELD("aux_cddopcao")
       FlagPermissoes        = GET-VALUE("aux_lspermis")
       msg-erro-aux          = 0
       ab_unmap.aux_idevento = GET-VALUE("aux_idevento")
       ab_unmap.aux_dsendurl = AppURL                        
       ab_unmap.aux_lspermis = FlagPermissoes                
       ab_unmap.aux_nrdrowid = GET-VALUE("aux_nrdrowid")         
       ab_unmap.aux_stdopcao = GET-VALUE("aux_stdopcao")
       ab_unmap.aux_lsevento = GET-VALUE("aux_lsevento")
       /* COOPERATIVA do Usu�rio */
       ab_unmap.glb_cdcooper = GET-VALUE("glb_cdcooper")
       /* COOPERATIVA que est� sendo trabalhada */
       ab_unmap.aux_cdcooper = GET-VALUE("aux_cdcooper")
       ab_unmap.aux_dtanoage = GET-VALUE("aux_dtanoage").

RUN outputHeader.

/* Busca o ano da Agenda */
FIND LAST gnpapgd WHERE gnpapgd.idevento = INTEGER(ab_unmap.aux_idevento)  AND 
                        gnpapgd.cdcooper = INTEGER(ab_unmap.aux_cdcooper)  AND 
                        gnpapgd.dtanonov = INTEGER(ab_unmap.aux_dtanoage)  NO-LOCK NO-ERROR.

IF NOT AVAILABLE gnpapgd THEN
   FIND LAST gnpapgd WHERE gnpapgd.idevento = INT(ab_unmap.aux_idevento) AND 
                           gnpapgd.cdcooper = INT(ab_unmap.aux_cdcooper) NO-LOCK NO-ERROR.

IF   AVAILABLE gnpapgd   THEN
     ab_unmap.aux_dtanoage = STRING(gnpapgd.dtanonov).

/* m�todo POST */
IF   REQUEST_METHOD = "POST":U   THEN 
     DO:
        RUN inputFields.

        CASE opcao:
             WHEN "sa" THEN /* salvar */
                  IF   ab_unmap.aux_stdopcao = "i"   THEN /* inclusao */
                       DO:
                          
                          RUN local-assign-record ("inclusao").                                        
                                                    
                          IF   msg-erro <> ""   THEN
                               ASSIGN msg-erro-aux = 3. /* erros da valida��o de dados */
                          ELSE 
                               ASSIGN msg-erro-aux          = 10
                                      ab_unmap.aux_stdopcao = "al".
                       END. /* fim inclusao */
        END CASE.
          
        CASE msg-erro-aux:
             WHEN 10 THEN
                  DO:
                     RUN RodaJavaScript('window.opener.Recarrega();').  
                     RUN RodaJavaScript('self.close();').
                  END.
        END CASE.     
        
        RUN enableFields.
        RUN outputFields.
        
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
                    RUN CriaListaEventos.
                    RUN displayFields.
                    RUN enableFields.
                    RUN outputFields.
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

