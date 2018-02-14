/* ..................................................................................

Alterações:  26/02/2008 - Não permitir inscrições quando o mês da Data Final do
                                      evento já estiver Fechado, E usuário não possuir
                                                  permissão de acesso 'U' (Diego).                          

             30/05/2008 - Permitir isncrição automatica para assembleias.             

             10/12/2008 - Melhoria de performance para a tabela gnapses (Evandro).
                         
                         11/12/2009 - Nao permitir encerrar eventos cancelados (Diego).
             
             21/01/2010 - Alterado para gravar Inscricoes Automaticas como sendo
                          do tipo 2 'Comunidade' (Elton).
                          
             20/04/2012 - Tratado na procedure EncerraMatricula, o find na
                          crapadp, para verificar registros com cdagenci = 0
                          tambem. (Fabricio)
                                                  
             05/06/2012 - Adaptação dos fontes para projeto Oracle. Alterado
                          busca na gnapses de CONTAINS para MATCHES (Guilherme Maba).
                          
             26/01/2015 - Incluir find da crapadp no encerramento das matriculas,
                          pois estava lento para encerrar as matriculas
                          (Lucas R. #245866)
             
             04/05/2015 - Alterar o armazenamento do campo ab_unmap.nrseqeve para 
                          buscar do aux_nrseqeve (Lucas Ranghetti #280510)  
                          
             04/09/2015 - Alterado declaracao do array "mevento" na PROCEDURE CriaListaEventos
                          para que seja declarado no inicio do programa (Lucas Ranghetti #329533)
						  
			 15/09/2015 - Ajustado procedure CriaListaEventos, estava estourando
                          o tamanho da variavel, adicionado .push para adicionar
                          somente um evento por vez dentro do for each (Lucas Ranghetti #329533)

             08/03/2016 - Alterado para que os eventos do tipo EAD 
                          e EAD Assemblear não sejam apresentados.
                          Projeto 229 - Melhorias OQS (Lombardi)
                          
             02/08/2017 - Nao permitir inscriçoes duplicadas, nao permitir inscricoes com eventos
                          encerrados, solicitaçao de ficha de presenca quando evento AGO/AGE,
                          alterar inscritos nao confirmados para faltantes quando encerrar evento,
                          Prj. 322 (Jean Michel)
			 08/02/2018 - Mostrar os eventos encerrados na lista de valores de eventos, desde que
			              o mês do mesmo não esteja fechado na tela de parâmetros das agendas
						  PRJ. 322 - SM 8 (Andrei - Mouts) 
................................................................................... */

&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD aux_cdagenci AS CHARACTER 
       FIELD aux_cdcooper AS CHARACTER 
       FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dtanoage AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nrseqeve AS CHARACTER 
       FIELD aux_qtinscri AS CHARACTER FORMAT "X(256)":U 
       FIELD cdageins AS CHARACTER FORMAT "X(256)":U 
       FIELD cdcooper AS CHARACTER FORMAT "X(256)":U 
       FIELD cdgraupr AS CHARACTER FORMAT "X(256)":U 
       FIELD nrseqeve AS CHARACTER FORMAT "X(256)":U 
           FIELD aux_fechamen AS CHARACTER FORMAT "X(256)":U
  FIELD aux_idstaeve AS CHARACTER FORMAT "X(256)":U
  FIELD aux_nrficpre AS CHARACTER
  FIELD aux_tpevento AS CHARACTER.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w-html 

CREATE WIDGET-POOL.

DEFINE VARIABLE ProgramaEmUso         AS CHARACTER INITIAL ["wpgd0044"].
DEFINE VARIABLE NmeDoPrograma         AS CHARACTER INITIAL ["wpgd0044.w"].

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
DEFINE VARIABLE v-descricaoerro       AS CHARACTER                      NO-UNDO.
DEFINE VARIABLE v-identificacao       AS CHARACTER                      NO-UNDO.

/*** Declaração de BOs ***/
DEFINE VARIABLE h-b1wpgd0009          AS HANDLE                         NO-UNDO.

/*** Temp Tables ***/
DEFINE TEMP-TABLE cratidp    NO-UNDO  LIKE crapidp.

DEFINE VARIABLE vetorpac              AS CHAR                           NO-UNDO.
DEFINE VARIABLE vetorinscri           AS CHAR                           NO-UNDO.

DEFINE VARIABLE aux_crapcop           AS CHAR                           NO-UNDO.
DEFINE VARIABLE aux_contador          AS INT                            NO-UNDO.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE fontes/wpgd0044.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS ab_unmap.aux_cdagenci ab_unmap.aux_cdcooper ~
ab_unmap.aux_cddopcao ab_unmap.aux_dsendurl ab_unmap.aux_dtanoage ~
ab_unmap.aux_idevento ab_unmap.aux_lspermis ab_unmap.aux_nrdrowid ~
ab_unmap.aux_nrseqeve ab_unmap.aux_qtinscri ab_unmap.cdageins ~
ab_unmap.cdcooper ab_unmap.cdgraupr ab_unmap.nrseqeve ab_unmap.aux_fechamen ~
ab_unmap.aux_idstaeve ab_unmap.aux_nrficpre ab_unmap.aux_tpevento
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.aux_cdagenci ab_unmap.aux_cdcooper ~
ab_unmap.aux_cddopcao ab_unmap.aux_dsendurl ab_unmap.aux_dtanoage ~
ab_unmap.aux_idevento ab_unmap.aux_lspermis ab_unmap.aux_nrdrowid ~
ab_unmap.aux_nrseqeve ab_unmap.aux_qtinscri ab_unmap.cdageins ~
ab_unmap.cdcooper ab_unmap.cdgraupr ab_unmap.nrseqeve ab_unmap.aux_fechamen ~
ab_unmap.aux_idstaeve ab_unmap.aux_nrficpre ab_unmap.aux_tpevento

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
     ab_unmap.aux_cddopcao AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_dsendurl AT ROW 1 COL 1 HELP
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
     ab_unmap.aux_nrseqeve AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.aux_qtinscri AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.cdageins AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.cdcooper AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.cdgraupr AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.nrseqeve AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_fechamen AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_idstaeve AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1                  
     ab_unmap.aux_nrficpre AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_tpevento AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
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
          FIELD aux_cdagenci AS CHARACTER 
          FIELD aux_cdcooper AS CHARACTER 
          FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dtanoage AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nrseqeve AS CHARACTER 
          FIELD aux_qtinscri AS CHARACTER FORMAT "X(256)":U 
          FIELD cdageins AS CHARACTER FORMAT "X(256)":U 
          FIELD cdcooper AS CHARACTER FORMAT "X(256)":U 
          FIELD cdgraupr AS CHARACTER FORMAT "X(256)":U 
          FIELD nrseqeve AS CHARACTER FORMAT "X(256)":U 
                  FIELD aux_fechamen AS CHARACTER FORMAT "X(256)":U
                  FIELD aux_idstaeve AS CHARACTER FORMAT "X(256)":U
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW w-html ASSIGN
         HEIGHT             = 25.67
         WIDTH              = 52.6.
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
/* SETTINGS FOR selection-list ab_unmap.aux_cdagenci IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR selection-list ab_unmap.aux_cdcooper IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR fill-in ab_unmap.aux_cddopcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.aux_dsendurl IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.aux_dtanoage IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.aux_idevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.aux_lspermis IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.aux_nrdrowid IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR selection-list ab_unmap.aux_nrseqeve IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR fill-in ab_unmap.aux_qtinscri IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.cdageins IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.cdcooper IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.cdgraupr IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.nrseqeve IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects w-html  _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaEventos w-html 
PROCEDURE CriaListaEventos :

    DEFINE VARIABLE aux_tppartic AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_idademin AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_flgcompr AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_flgrest  AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_qtmaxtur AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_nrinscri AS INT  NO-UNDO.
    DEFINE VARIABLE aux_nrconfir AS INT  NO-UNDO.
    DEFINE VARIABLE aux_nrseqeve AS INT  NO-UNDO.
    DEFINE VARIABLE aux_nrdturma AS INT  NO-UNDO.
    DEFINE VARIABLE aux_nmevento AS CHAR NO-UNDO.
    DEFINE VARIABLE vetormes     AS CHAR EXTENT 12
        INITIAL ["Janeiro","Fevereiro","Março","Abril","Maio","Junho",
                 "Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"].
        DEFINE VARIABLE aux_fechamen AS CHAR NO-UNDO.
    
  ASSIGN aux_contador = 0.
    
  RUN RodaJavaScript("var mevento = new Array();"). 
    
    FOR EACH crapeap WHERE crapeap.idevento       = INT(ab_unmap.aux_idevento)  AND
                           crapeap.cdcooper       = INT(ab_unmap.aux_cdcooper)  AND
                         ((crapeap.cdagenci       = INT(ab_unmap.cdageins))     OR
                          (crapeap.cdagenci       = 0                           AND 
                       INT(ab_unmap.aux_idevento) = 2))                         AND  /*assembléia */
                           crapeap.dtanoage       = INT(ab_unmap.aux_dtanoage)  AND
                           crapeap.flgevsel       = YES                         NO-LOCK, 
       FIRST crapedp WHERE crapedp.cdevento       = crapeap.cdevento            AND
                           crapedp.idevento       = crapeap.idevento            AND
                           crapedp.cdcooper       = crapeap.cdcooper            AND
                           crapedp.dtanoage       = crapeap.dtanoage            AND
                           crapedp.tpevento       <> 10                         AND
                           crapedp.tpevento       <> 11                         NO-LOCK,
        EACH crapadp WHERE crapadp.idevento       = crapeap.idevento            AND
                           crapadp.cdcooper       = crapeap.cdcooper            AND
                           crapadp.cdagenci       = crapeap.cdagenci            AND
                           crapadp.dtanoage       = crapeap.dtanoage            AND
                         crapadp.cdevento       = crapeap.cdevento            //AND
                         //crapadp.idstaeve       <> 4 PRJ 322 - SM - 8 -- Linha comentada para mostrar eventos encerrados
						 NO-LOCK
                           BREAK BY crapadp.cdagenci
                                    BY crapedp.nmevento
                                       BY crapadp.nrseqdig:
    
    FIND FIRST crapagp WHERE crapagp.idevento = INT(ab_unmap.aux_idevento)  
                         AND crapagp.cdcooper = crapeap.cdcooper            
                         AND crapagp.dtanoage = INT(ab_unmap.aux_dtanoage)  
                         AND crapagp.cdagenci = crapeap.cdagenci            
                         AND crapagp.idstagen = 5 NO-LOCK NO-ERROR.
     
        IF NOT AVAIL crapagp AND ab_unmap.aux_idevento = "1" THEN NEXT. 
      
        ASSIGN aux_nrseqeve = IF crapadp.nrseqdig <> ? THEN crapadp.nrseqdig ELSE 0
               aux_nmevento = crapedp.nmevento.
                                                                                   
    IF crapadp.dtinieve <> ?  THEN
      ASSIGN aux_nmevento = aux_nmevento + " - " + STRING(crapadp.dtinieve,"99/99/9999").
    ELSE IF  crapadp.nrmeseve <> 0  AND crapadp.nrmeseve <> ? THEN
      ASSIGN aux_nmevento = aux_nmevento + " - " + vetormes[crapadp.nrmeseve].
    
    IF crapadp.dshroeve <> "" THEN
      DO:
        ASSIGN aux_nmevento = aux_nmevento + " - " + crapadp.dshroeve.
      END.

            ASSIGN aux_fechamen = "Não".  
    
    DO aux_contador = 1 TO NUM-ENTRIES(gnpapgd.lsmesctb):

      IF INT(ENTRY(aux_contador,gnpapgd.lsmesctb)) = MONTH(crapadp.dtfineve)  THEN
                 DO:
                             ASSIGN aux_fechamen = "Sim".
                                 LEAVE.
                          END.
                END.
    
    IF 	aux_fechamen = "Não" THEN //PRJ 322 - SM - 8 -- Só carregar eventos que não estão com mês fechado
	  DO:
        RUN RodaJavaScript("mevento.push(~{cdagenci:'" + STRING(crapeap.cdagenci)  
                       + "',cdcooper:'" + STRING(crapeap.cdcooper)  
                       + "',cdevento:'" + STRING(crapeap.cdevento)  
                       + "',nmevento:'" + STRING(aux_nmevento)      
                       + "',idstaeve:'" + STRING(crapadp.idstaeve)  
                       + "',flgcompr:'" + STRING(aux_flgcompr)      
                       + "',flgrest:'"  + STRING(aux_flgrest)       
                       + "',qtmaxtur:'" + STRING(aux_qtmaxtur)      
                       + "',nrinscri:'" + STRING(aux_nrinscri)      
                       + "',nrconfir:'" + STRING(aux_nrconfir)      
                       + "',nrseqeve:'" + STRING(aux_nrseqeve)      
                       + "',idademin:'" + STRING(aux_idademin)      
                       + "',tppartic:'" + STRING(aux_tppartic)      
                       + "',tpevento:'" + STRING(crapedp.tpevento)  
                       + "',fechamen:'" + STRING(aux_fechamen) + "'~});").    
      END.	//PRJ 322 - SM - 8 -- Só carregar eventos que não estão com mês fechado			   
    END.    
	
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
    DEFINE VARIABLE aux_nmresag2 AS CHAR NO-UNDO.
    
    /*  Progrid */
    IF ab_unmap.aux_idevento = "1" THEN
       DO: 
           { includes/wpgd0099.i ab_unmap.aux_dtanoage }
    
       END.
    ELSE
       DO:
           { includes/wpgd0097.i }
       END.
    
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
    ("aux_dtanoage":U,"ab_unmap.aux_dtanoage":U,ab_unmap.aux_dtanoage:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idevento":U,"ab_unmap.aux_idevento":U,ab_unmap.aux_idevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lspermis":U,"ab_unmap.aux_lspermis":U,ab_unmap.aux_lspermis:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrdrowid":U,"ab_unmap.aux_nrdrowid":U,ab_unmap.aux_nrdrowid:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrseqeve":U,"ab_unmap.aux_nrseqeve":U,ab_unmap.aux_nrseqeve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_qtinscri":U,"ab_unmap.aux_qtinscri":U,ab_unmap.aux_qtinscri:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("cdageins":U,"ab_unmap.cdageins":U,ab_unmap.cdageins:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("cdcooper":U,"ab_unmap.cdcooper":U,ab_unmap.cdcooper:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("cdgraupr":U,"ab_unmap.cdgraupr":U,ab_unmap.cdgraupr:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nrseqeve":U,"ab_unmap.nrseqeve":U,ab_unmap.nrseqeve:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_fechamen":U,"ab_unmap.aux_fechamen":U,ab_unmap.aux_fechamen:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idstaeve":U,"ab_unmap.aux_idstaeve":U,ab_unmap.aux_idstaeve:HANDLE IN FRAME {&FRAME-NAME}).        
  RUN htmAssociate
    ("aux_nrficpre":U,"ab_unmap.aux_nrficpre":U,ab_unmap.aux_nrficpre:HANDLE IN FRAME {&FRAME-NAME}).        
  RUN htmAssociate
    ("aux_tpevento":U,"ab_unmap.aux_tpevento":U,ab_unmap.aux_tpevento:HANDLE IN FRAME {&FRAME-NAME}).        
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-assign-record w-html 
PROCEDURE local-assign-record:

  DEFINE VARIABLE aux_contador AS INTEGER INIT 0 NO-UNDO.
  DEFINE VARIABLE aux_registro AS INTEGER INIT 0 NO-UNDO.

    DEFINE VARIABLE tmp_cdevento AS INT                NO-UNDO.
  DEFINE VARIABLE aux_continsc AS INT                NO-UNDO INIT 0.
    DEFINE VARIABLE tmp_cdagenci LIKE crapidp.cdagenci NO-UNDO.

    /* Instancia a BO para executar as procedures */
    RUN dbo/b1wpgd0009.p PERSISTENT SET h-b1wpgd0009.

    /* Se BO foi instanciada */
    IF VALID-HANDLE(h-b1wpgd0009) THEN
       DO:
        FIND FIRST crapadp WHERE crapadp.nrseqdig = INT(ab_unmap.nrseqeve)
                             AND crapadp.cdcooper = INT(ab_unmap.aux_cdcooper)
                             //AND crapadp.idstaeve <> 4 PRJ 322 - SM - 8 -- Linha comentada para permitir incrições de eventos encerrados
							 NO-LOCK NO-ERROR.
        
                    IF NOT AVAIL crapadp THEN 
                       DO:
                          /* "mata" a instância da BO */
                          DELETE PROCEDURE h-b1wpgd0009 NO-ERROR.
                          NEXT.
                       END.
                        
                    ASSIGN tmp_cdevento = crapadp.cdevento.
    
        FIND FIRST crapedp WHERE crapedp.cdevento = tmp_cdevento                
                             AND crapedp.cdcooper = INT(ab_unmap.aux_cdcooper)
                             AND crapedp.dtanoage = INT(ab_unmap.aux_dtanoage)
                             AND crapedp.idevento = INT(ab_unmap.aux_idevento)  NO-LOCK NO-ERROR.
                             
        IF crapedp.tpevento = 7 OR
           crapedp.tpevento = 12 THEN /* é assembléia */
          DO:
                        ASSIGN tmp_cdagenci = 0.
            
            RUN verificaFichaInscricao(INPUT INT(ab_unmap.aux_idevento)
                                      ,INPUT INT(ab_unmap.aux_cdcooper)
                                      ,INPUT INT(ab_unmap.aux_dtanoage)
                                      ,INPUT INT(ab_unmap.cdageins)
                                      ,INPUT tmp_cdevento
                                      ,INPUT INT(ab_unmap.nrseqeve)
                                      ,INPUT INT(ab_unmap.aux_nrficpre)).
                                        
            IF RETURN-VALUE = "NOK" THEN
              DO:
                RETURN "NOK".
              END.
          END.  
                    ELSE
                        ASSIGN tmp_cdagenci = INT(ab_unmap.cdageins).


		/* VERIFICA QTD DE INSCRICOES AUTOMATICAS */		
		IF crapedp.tpevento = 7 OR
		   crapedp.tpevento = 12 THEN
			DO:
				ASSIGN aux_continsc = 0.
				
				FOR EACH crapidp WHERE crapidp.idevento = INT(ab_unmap.aux_idevento)
								   AND crapidp.cdcooper = INT(ab_unmap.aux_cdcooper)
								   AND crapidp.dtanoage = INT(ab_unmap.aux_dtanoage)
								   AND crapidp.cdagenci = tmp_cdagenci
								   AND crapidp.cdevento = tmp_cdevento
								   AND crapidp.nrseqeve = INT(ab_unmap.nrseqeve)
								   AND crapidp.nminseve MATCHES "Inscri*" 
								   AND crapidp.nrficpre = INT(ab_unmap.aux_nrficpre) NO-LOCK:

				  ASSIGN aux_continsc = aux_continsc + 1.

				END.
						
				/* FIM VERIFICACAO */		
						
				IF aux_continsc < INT(ab_unmap.aux_qtinscri) THEN
					DO:
					
						FOR EACH crapidp WHERE crapidp.idevento = INT(ab_unmap.aux_idevento)
										   AND crapidp.cdcooper = INT(ab_unmap.aux_cdcooper)
										   AND crapidp.dtanoage = INT(ab_unmap.aux_dtanoage)
										   AND crapidp.cdagenci = tmp_cdagenci
										   AND crapidp.cdevento = tmp_cdevento
										   AND crapidp.nrseqeve = INT(ab_unmap.nrseqeve)
										   AND crapidp.nminseve MATCHES "Inscri*" 
										   AND crapidp.nrficpre = INT(ab_unmap.aux_nrficpre) EXCLUSIVE-LOCK:

						  DELETE crapidp.

						END.
						
						DO aux_contador = 1 TO INT(ab_unmap.aux_qtinscri):
				   
						   EMPTY TEMP-TABLE cratidp.
						   
						   
						   IF aux_registro = 0 THEN
							 ASSIGN aux_registro = ((INT(ab_unmap.aux_nrficpre) - 1) * 25 + 1).
						   ELSE
							 ASSIGN aux_registro = aux_registro + 1.
														
						   CREATE cratidp.
						   ASSIGN cratidp.cdagenci = tmp_cdagenci
								  cratidp.cdageins = INT(ab_unmap.cdageins)
								  cratidp.cdcooper = INT(ab_unmap.aux_cdcooper)
								  cratidp.cdevento = tmp_cdevento
								  cratidp.nrseqeve = INT(ab_unmap.nrseqeve)
								  cratidp.cdgraupr = 9
								  cratidp.cdoperad = gnapses.cdoperad
								  cratidp.dsdemail = ""
								  cratidp.flgdispe = YES
								  cratidp.tpinseve = 2      /**Comunidade**/
								  cratidp.dsobsins = ""
								  cratidp.dtanoage = INT(ab_unmap.aux_dtanoage)
								  cratidp.dtconins = TODAY
								  cratidp.dtpreins = TODAY
								  cratidp.idevento = INT(ab_unmap.aux_idevento)
								  cratidp.idseqttl = 0
								  cratidp.idstains = 2
								  cratidp.nminseve = "Inscrição Automática " + STRING(aux_registro,"9999")
								  cratidp.nrdconta = 0
								  cratidp.nrdddins = 0
								  cratidp.nrseqdig = ?
								  cratidp.nrtelins = 0
								  cratidp.nrficpre = INT(ab_unmap.aux_nrficpre).
						   
						   RUN inclui-registro IN h-b1wpgd0009(INPUT  TABLE cratidp, 
															   OUTPUT msg-erro, 
															   OUTPUT ab_unmap.aux_nrdrowid).
						END.
					END.
			END.
		ELSE
			DO:
				ASSIGN aux_continsc = 0.
				
				FOR EACH crapidp WHERE crapidp.idevento = INT(ab_unmap.aux_idevento)
								   AND crapidp.cdcooper = INT(ab_unmap.aux_cdcooper)
								   AND crapidp.dtanoage = INT(ab_unmap.aux_dtanoage)
								   AND crapidp.cdagenci = tmp_cdagenci
								   AND crapidp.cdevento = tmp_cdevento
								   AND crapidp.nrseqeve = INT(ab_unmap.nrseqeve)
								   AND crapidp.nminseve MATCHES "Inscri*" 
								   AND crapidp.nrficpre = INT(ab_unmap.aux_nrficpre) NO-LOCK:

				  ASSIGN aux_continsc = aux_continsc + 1.

				END.
						
				/* FIM VERIFICACAO */		
						
				IF aux_continsc < INT(ab_unmap.aux_qtinscri) THEN
					DO:
					
						FOR EACH crapidp WHERE crapidp.idevento = INT(ab_unmap.aux_idevento)
										   AND crapidp.cdcooper = INT(ab_unmap.aux_cdcooper)
										   AND crapidp.dtanoage = INT(ab_unmap.aux_dtanoage)
										   AND crapidp.cdagenci = tmp_cdagenci
										   AND crapidp.cdevento = tmp_cdevento
										   AND crapidp.nrseqeve = INT(ab_unmap.nrseqeve)
										   AND crapidp.nminseve MATCHES "Inscri*" 
										   AND crapidp.nrficpre = INT(ab_unmap.aux_nrficpre) EXCLUSIVE-LOCK:

						  DELETE crapidp.

						END.
						
          DO aux_contador = 1 TO INT(ab_unmap.aux_qtinscri):

             EMPTY TEMP-TABLE cratidp.
											
             CREATE cratidp.
             ASSIGN cratidp.cdagenci = tmp_cdagenci
                    cratidp.cdageins = INT(ab_unmap.cdageins)
                    cratidp.cdcooper = INT(ab_unmap.aux_cdcooper)
                    cratidp.cdevento = tmp_cdevento
                    cratidp.nrseqeve = INT(ab_unmap.nrseqeve)
                    cratidp.cdgraupr = 9
                    cratidp.cdoperad = gnapses.cdoperad
                    cratidp.dsdemail = ""
                    cratidp.flgdispe = YES
                    cratidp.tpinseve = 2      /**Comunidade**/
                    cratidp.dsobsins = ""
                    cratidp.dtanoage = INT(ab_unmap.aux_dtanoage)
                    cratidp.dtconins = TODAY
                    cratidp.dtpreins = TODAY
                    cratidp.idevento = INT(ab_unmap.aux_idevento)
                    cratidp.idseqttl = 0
                    cratidp.idstains = 2
                    cratidp.nminseve = "Inscrição Automática " + STRING(aux_contador,"9999")
                    cratidp.nrdconta = 0
                    cratidp.nrdddins = 0
                    cratidp.nrseqdig = ?
								  cratidp.nrtelins = 0
								  cratidp.nrficpre = INT(ab_unmap.aux_nrficpre).
             
             RUN inclui-registro IN h-b1wpgd0009(INPUT  TABLE cratidp, 
                                                 OUTPUT msg-erro, 
                                                 OUTPUT ab_unmap.aux_nrdrowid).
          END.
				END.
			END.
          /* "mata" a instância da BO */
          DELETE PROCEDURE h-b1wpgd0009 NO-ERROR.
               
     END.

  ASSIGN msg-erro-aux = 10.
  
  RETURN "OK".
  
END PROCEDURE.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE verificaFichaInscricao w-html 
PROCEDURE verificaFichaInscricao:
  
  DEFINE INPUT PARAMETER par_idevento LIKE crapidp.idevento.
  DEFINE INPUT PARAMETER par_cdcooper LIKE crapidp.cdcooper.
  DEFINE INPUT PARAMETER par_dtanoage LIKE crapidp.dtanoage.
  DEFINE INPUT PARAMETER par_cdagenci LIKE crapidp.cdagenci.
  DEFINE INPUT PARAMETER par_cdevento LIKE crapidp.cdevento.
  DEFINE INPUT PARAMETER par_nrseqeve LIKE crapidp.nrseqeve.
  DEFINE INPUT PARAMETER par_nrficpre LIKE crapfpa.nrficpre.
  
  DEFINE VARIABLE aux_contador AS INTEGER INIT 0.
  
  /* Primeiro verifica se ficha de inscricao existe */
  FIND FIRST crapfpa WHERE crapfpa.nrficpre = par_nrficpre
                       AND crapfpa.cdcopfic = par_cdcooper
                       AND crapfpa.cdagefic = par_cdagenci NO-LOCK NO-ERROR NO-WAIT.
  
  IF NOT AVAILABLE crapfpa THEN
    DO:
      ASSIGN msg-erro-aux = 5
             msg-erro = "Ficha de Inscrição não cadastrada.".
             
      RETURN "NOK".       
    END.
  /* Fim verificacao ficha de inscricao */
  
  /* Verifica quantidade de inscritos por ficha */
  FOR EACH crapidp where crapidp.idevento = par_idevento
                     AND crapidp.cdcooper = par_cdcooper
                     AND crapidp.dtanoage = par_dtanoage
                     AND crapidp.cdagenci = par_cdagenci
                     AND crapidp.cdevento = par_cdevento
                     AND crapidp.nrseqeve = par_nrseqeve NO-LOCK:
    
    ASSIGN aux_contador = aux_contador + 1.
    
       END.
     
  IF aux_contador <= 25 THEN
    RETURN "OK".
  ELSE
    DO:
      ASSIGN msg-erro-aux = 6
             msg-erro = "Limite de Ficha de Inscrição Excedido.".
             
      RETURN "NOK".
    END.
  
  /* Fim verifica quantidade de inscritos por ficha */
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-delete-record w-html 
PROCEDURE local-delete-record :
    
    /* Instancia a BO para executar as procedures */
    RUN dbo/b1wpgd0009.p PERSISTENT SET h-b1wpgd0009.
     
    /* Se BO foi instanciada */
    IF VALID-HANDLE(h-b1wpgd0009) THEN
       DO:
        IF INT(ab_unmap.aux_tpevento) = 7 OR INT(ab_unmap.aux_tpevento) = 12 Then
          DO:
            FOR EACH crapidp WHERE crapidp.idevento = INT(ab_unmap.aux_idevento)           
                               AND crapidp.cdcooper = INT(ab_unmap.aux_cdcooper)             
                               AND crapidp.dtanoage = INT(ab_unmap.aux_dtanoage)             
                               AND (crapidp.cdageins = INT(ab_unmap.cdageins) 
                                OR (crapidp.cdageins = 0 AND INT(ab_unmap.aux_idevento) = 2)) 
                               AND crapidp.nrseqeve = INT(ab_unmap.nrseqeve)
                               AND crapidp.nminseve BEGINS "Inscrição Automática" 
                               AND crapidp.nrficpre = INT(ab_unmap.aux_nrficpre) NO-LOCK:

              EMPTY TEMP-TABLE cratidp.
              CREATE cratidp.
              BUFFER-COPY crapidp TO cratidp.
              
              RUN exclui-registro IN h-b1wpgd0009(INPUT TABLE cratidp, OUTPUT msg-erro).
            END.
          END.
        ELSE
          DO:
          FOR EACH crapidp WHERE crapidp.idevento = INT(ab_unmap.aux_idevento)             AND
                                 crapidp.cdcooper = INT(ab_unmap.aux_cdcooper)             AND
                                 crapidp.dtanoage = INT(ab_unmap.aux_dtanoage)             AND
                                (crapidp.cdageins = INT(ab_unmap.cdageins) OR     
                                (crapidp.cdageins = 0 AND INT(ab_unmap.aux_idevento) = 2)) AND
                                 crapidp.nrseqeve = INT(ab_unmap.nrseqeve)                 AND
                                 crapidp.nminseve BEGINS "Inscrição Automática"            NO-LOCK:

              EMPTY TEMP-TABLE cratidp.
              CREATE cratidp.
              BUFFER-COPY crapidp TO cratidp.
              
              RUN exclui-registro IN h-b1wpgd0009(INPUT TABLE cratidp, OUTPUT msg-erro).
          END.
          END.
    
          /* "mata" a instância da BO */
          DELETE PROCEDURE h-b1wpgd0009 NO-ERROR.
       END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE EncerraMatricula w-html 
PROCEDURE EncerraMatricula :

    DEF VAR i AS INT NO-UNDO.
    DEF VAR aux_msg-erro AS CHAR NO-UNDO.
    
    FIND crapadp WHERE crapadp.cdcooper = INT(ab_unmap.aux_cdcooper) AND
                       crapadp.nrseqdig = INT(ab_unmap.nrseqeve)
                       NO-LOCK NO-ERROR.

    /* Instancia a BO para executar as procedures */
    RUN dbo/b1wpgd0009.p PERSISTENT SET h-b1wpgd0009.
    
    /* Se BO foi instanciada */
    IF VALID-HANDLE(h-b1wpgd0009) THEN
    DO:
        
      FOR EACH crapidp WHERE crapidp.cdcooper = INT(ab_unmap.aux_cdcooper)  
                         AND crapidp.idevento = INT(ab_unmap.aux_idevento)  
                         AND crapidp.cdevento = crapadp.cdevento            
                         AND crapidp.dtanoage = INT(ab_unmap.aux_dtanoage)  
                         AND crapidp.cdageins = INT(ab_unmap.cdageins) NO-LOCK:
        
            
            FOR EACH cratidp EXCLUSIVE-LOCK:
                DELETE cratidp NO-ERROR.
            END.
    
            CREATE cratidp.
            BUFFER-COPY crapidp TO cratidp.
    
        IF cratidp.idstains = 1 THEN
                 ASSIGN cratidp.idstains = 4.
            
        IF INT(ab_unmap.aux_tpevento) = 8  OR
           INT(ab_unmap.aux_tpevento) = 13 OR
           INT(ab_unmap.aux_tpevento) = 14 OR
           INT(ab_unmap.aux_tpevento) = 15 OR
           INT(ab_unmap.aux_tpevento) = 16 THEN
          DO:
           IF cratidp.idstains = 1 OR cratidp.idstains = 4 THEN
             ASSIGN cratidp.qtfaleve = crapadp.qtdiaeve.
          END.

            RUN altera-registro IN h-b1wpgd0009(INPUT TABLE cratidp, OUTPUT aux_msg-erro).

            msg-erro = msg-erro + aux_msg-erro.

        END.
    
        /* "mata" a instância da BO */
        DELETE PROCEDURE h-b1wpgd0009 NO-ERROR.
    
    END.

    FIND FIRST crapadp WHERE crapadp.idevento = INT(ab_unmap.aux_idevento)  AND
                             crapadp.cdcooper = INT(ab_unmap.aux_cdcooper)  AND
                            (crapadp.cdagenci = INT(ab_unmap.cdageins)      OR
                             crapadp.cdagenci = 0)                          AND
                             crapadp.dtanoage = INT(ab_unmap.aux_dtanoage)  AND
                             crapadp.nrseqdig = INT(ab_unmap.nrseqeve)      EXCLUSIVE-LOCK NO-ERROR.
    
  IF AVAILABLE crapadp THEN
    ASSIGN crapadp.idstaeve = 4.
    ELSE
    ASSIGN msg-erro = msg-erro + "Problemas para encerrar matrículas. ".

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

  /* To make this a state-aware Web object, pass in the timeout period
   * (in minutes) before running outputContentType.  If you supply a 
   * timeout period greater than 0, the Web object becomes state-aware 
   * and the following happens:
   *
   *   - 4GL variables webState and webTimeout are set
   *   - a cookie is created for the broker to id the client on the return trip
   *   - a cookie is created to id the correct procedure on the return trip
   *
   * If you supply a timeout period less than 1, the following happens:
   *
   *   - 4GL variables webState and webTimeout are set to an empty string
   *   - a cookie is killed for the broker to id the client on the return trip
   *   - a cookie is killed to id the correct procedure on the return trip
   *
   * For example, set the timeout period to 5 minutes.
   *
   *   setWebState (5.0).
   */
    
  /* Output additional cookie information here before running outputContentType.
   *   For more information about the Netscape Cookie Specification, see
   *   http://home.netscape.com/newsref/std/cookie_spec.html  
   *   
   *   Name         - name of the cookie
   *   Value        - value of the cookie
   *   Expires date - Date to expire (optional). See TODAY function.
   *   Expires time - Time to expire (optional). See TIME function.
   *   Path         - Override default URL path (optional)
   *   Domain       - Override default domain (optional)
   *   Secure       - "secure" or unknown (optional)
   * 
   *   The following example sets custNum=23 and expires tomorrow at (about)
   *   the same time but only for secure (https) connections.
   *      
   *   RUN SetCookie IN web-utilities-hdl 
   *     ("custNum":U, "23":U, TODAY + 1, TIME, ?, ?, "secure":U).
   */ 
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
       ab_unmap.aux_idevento = GET-VALUE("aux_idevento")
       ab_unmap.aux_dsendurl = AppURL                        
       ab_unmap.aux_lspermis = FlagPermissoes                
       ab_unmap.aux_nrdrowid = GET-VALUE("aux_nrdrowid")         
       ab_unmap.aux_cdcooper = GET-VALUE("aux_cdcooper")
       ab_unmap.aux_dtanoage = GET-VALUE("aux_dtanoage")
       ab_unmap.aux_qtinscri = GET-VALUE("aux_qtinscri")
       ab_unmap.cdageins     = GET-VALUE("cdageins")
       ab_unmap.nrseqeve     = GET-VALUE("aux_nrseqeve")
       ab_unmap.aux_nrficpre = GET-VALUE("aux_nrficpre")
       ab_unmap.aux_tpevento = GET-VALUE("aux_tpevento").

RUN outputHeader.

{includes/wpgd0098.i}

ab_unmap.aux_cdcooper:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = aux_crapcop.

/* Se a cooperativa ainda não foi escolhida, pega a da sessão do usuário */
IF   INT(ab_unmap.aux_cdcooper) = 0   THEN
     ab_unmap.aux_cdcooper = STRING(gnapses.cdcooper).

/* Se o PAC ainda não foi escolhido, pega o da sessão do usuário */
IF   INT(ab_unmap.cdageins) = 0   THEN
     ab_unmap.cdageins = STRING(gnapses.cdagenci).

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

/* método POST */
IF REQUEST_METHOD = "POST":U THEN 
   DO:
      RUN inputFields.

      CASE opcao:
           WHEN "sa" THEN /* salvar */
                DO:
                    RUN local-assign-record. 
                END. /* fim salvar */
           WHEN "ex" THEN /* exclusao */
                DO:
                    RUN local-delete-record.
                                
                    IF msg-erro <> "" THEN
                       ASSIGN msg-erro-aux = 3. /* erros da validação de dados */
                    ELSE 
                       ASSIGN msg-erro-aux = 10.
                END. /* fim exclusao */
           WHEN "enc" THEN /* encerra incrições */
                DO:
                    RUN EncerraMatricula.

                    IF msg-erro = "" THEN
                       ASSIGN msg-erro-aux = 10. /* Solicitação realizada com sucesso */ 
                    ELSE
                       ASSIGN msg-erro-aux = 3. /* erros da validação de dados */
                END. /* fim encerra incrições */
      END CASE.

      /* Busca a quantidade de inscrições automáticas já existentes */
      IF   ab_unmap.nrseqeve <> ""   THEN
           DO:
               FIND LAST crapidp WHERE crapidp.idevento = INT(ab_unmap.aux_idevento)             AND
                                       crapidp.cdcooper = INT(ab_unmap.aux_cdcooper)             AND
                                       crapidp.dtanoage = INT(ab_unmap.aux_dtanoage)             AND
                                      (crapidp.cdageins = INT(ab_unmap.cdageins) OR     
                                      (crapidp.cdageins = 0 AND INT(ab_unmap.aux_idevento) = 2)) AND
                                       crapidp.nrseqeve = INT(ab_unmap.nrseqeve)                 AND
                                       crapidp.nminseve BEGINS "Inscrição Automática"            NO-LOCK NO-ERROR.

               IF   AVAILABLE crapidp   THEN
                    ab_unmap.aux_qtinscri = STRING(INT(SUBSTRING(crapidp.nminseve,21))).
               ELSE
                    ab_unmap.aux_qtinscri = "0".
           END.

      RUN CriaListaPac.
      RUN CriaListaEventos.
      RUN displayFields.
      RUN enableFields.
      RUN outputFields.

      CASE msg-erro-aux:
           WHEN 1 THEN
                DO:
                    ASSIGN v-descricaoerro = 'Registro esta em uso por outro usuário. Solicitação não pode ser executada. Espere alguns instantes e tente novamente.'.

                    RUN RodaJavaScript('alert("'+ v-descricaoerro + '"); ').
                END.

           WHEN 2 THEN
                RUN RodaJavaScript("alert('Registro foi excluído. Solicitação não pode ser executada.')").
      
           WHEN 3 THEN
                DO:
                    ASSIGN v-descricaoerro = msg-erro.

                    RUN RodaJavaScript('alert("'+ v-descricaoerro + '"); ').
                END.

           WHEN 4 THEN
                DO:
                    ASSIGN v-descricaoerro = m-erros.

                    RUN RodaJavaScript('alert("'+ v-descricaoerro + '"); ').
                END.
           WHEN 5 THEN
                DO:
                    RUN RodaJavaScript('alert("'+ msg-erro + '"); ').
                END.
           WHEN 6 THEN
                DO:
                    RUN RodaJavaScript('alert("'+ msg-erro + '"); ').
                END.

           WHEN 10 THEN
                DO:
                   RUN RodaJavaScript('alert("Atualização executada com sucesso.")'). 
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
                    RUN CriaListaPac.
                    RUN CriaListaEventos.
                    RUN displayFields.
                    RUN enableFields.
                    RUN outputFields.
                    RUN RodaJavaScript('FechaZoom();').
                    
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

