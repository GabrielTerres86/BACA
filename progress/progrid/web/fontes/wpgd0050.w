/* ............................................................................

Alterações: 03/01/2012 - Ajustes:
                       - Criado a funcao Descriptografa;
                       - Realizado os devidos ajustes para descriptografar 
                         os dados importados na procedure ImportaInscricoes;
                       - Realizado ajustes na procedure SelecionaArquivo para
                         quando nao houver trailer, utilizar o contador dos
                         inscritos para mostrar na tela (Adriano). 
            
            11/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).   
                            
            11/11/2013 - Ajustes na PROCEDURE ImportaInscricoes (Lucas R.)
            
            12/12/2013 - Incluido VALIDATE crapidp (Lucas R.)
			
			      17/01/2014 - Alterado critica ao nao encontrar PA para "962 - PA
                         nao cadastrado.". (Reinert)
                         
            27/10/2015 - Inscrição automática com cartão CECRED (Lunelli SD 350182)	

            08/03/2016 - Alterado para que os eventos do tipo EAD 
                         e EAD Assemblear nÃ£o sejam apresentados.
                         Projeto 229 - Melhorias OQS (Lombardi)
                         
            14/06/2016 - Ajustado para permitir importar inscritos
                         de eventos progrid, extensao .EVE
                         Projeto 229 - Melhorias OQS (Odirlei-AMcom)

            02/08/2017 - Ajustado para nao permitir importar inscritos
                         de eventos já encerrados, Nao permitir inscriçoes
                         duplicadas e nao permitir importaçao no eventos
                         assembleares, Prj. 322 (Jean Michel)
						 
            26/10/2017 - Ajustado para permitir importar inscritos PJ 
                         e Criar arquivo de Inconsistência - Prj. 322 (Mateus)						 
   		    09/02/2018 - Mostrar os eventos encerrados na lista de valores de eventos, desde que
			             o mês do mesmo não esteja fechado na tela de parâmetros das agendas
			 		     PRJ. 322 - SM 8 (Andrei - Mouts) 
                           
............................................................................ */

&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD aux_cdagenci AS CHARACTER 
       FIELD aux_cdcooper AS CHARACTER 
       FIELD aux_nmarqimp AS CHARACTER
       FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dtanoage AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nrseqeve AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_fechamen AS CHARACTER FORMAT "X(256)":U
       FIELD aux_idstaeve AS CHARACTER FORMAT "X(256)":U
       FIELD aux_dsabearq AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_cdagearq AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dsopearq AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dslocarq AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_qtinsarq AS CHARACTER FORMAT "X(256)":U
       FIELD aux_nmevearq AS CHARACTER FORMAT "X(256)":U
       FIELD cdageins     AS CHARACTER FORMAT "X(256)":U
       FIELD cdarqsel     AS CHARACTER FORMAT "X(256)":U
       FIELD nmarqsel     AS CHARACTER FORMAT "X(256)":U
       FIELD cdevesel     AS CHARACTER FORMAT "X(256)":U.

DEFINE TEMP-TABLE tt-crapass LIKE crapass.

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
DEFINE VARIABLE ProgramaEmUso         AS CHARACTER INITIAL ["wpgd0050"].
DEFINE VARIABLE NmeDoPrograma         AS CHARACTER INITIAL ["wpgd0050.w"].

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

DEF STREAM str_1.
DEF STREAM str_2.

/*** Declaração de BOs ***/
DEFINE VARIABLE h-b1wgen0025          AS HANDLE                         NO-UNDO.

DEFINE VARIABLE vetorpac              AS CHAR                           NO-UNDO.
DEFINE VARIABLE vetorarquiv           AS CHAR                           NO-UNDO.
DEFINE VARIABLE dadosarquivo          AS CHAR                           NO-UNDO.

DEFINE VARIABLE aux_crapcop           AS CHAR                           NO-UNDO.
DEFINE VARIABLE aux_contador          AS INT                            NO-UNDO.
DEFINE VARIABLE aux_inregdel          AS INT INIT 0                     NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE fontes/wpgd0050.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS ab_unmap.aux_cdagenci ab_unmap.aux_cdcooper ab_unmap.aux_cddopcao ab_unmap.aux_dsendurl ab_unmap.aux_dtanoage ab_unmap.aux_idevento ab_unmap.aux_lspermis ab_unmap.aux_nrdrowid ab_unmap.aux_nrseqeve ab_unmap.aux_fechamen ab_unmap.aux_idstaeve ab_unmap.aux_nmarqimp ab_unmap.aux_dsabearq ab_unmap.aux_dsopearq ab_unmap.aux_dslocarq ab_unmap.aux_nmevearq ab_unmap.aux_qtinsarq ab_unmap.aux_cdagearq ab_unmap.cdageins ab_unmap.cdarqsel ab_unmap.nmarqsel  ab_unmap.cdevesel
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.aux_cdagenci ab_unmap.aux_cdcooper ab_unmap.aux_cddopcao ab_unmap.aux_dsendurl ab_unmap.aux_dtanoage ab_unmap.aux_idevento ab_unmap.aux_lspermis ab_unmap.aux_nrdrowid ab_unmap.aux_nrseqeve ab_unmap.aux_fechamen ab_unmap.aux_idstaeve ab_unmap.aux_nmarqimp ab_unmap.aux_dsabearq ab_unmap.aux_dsopearq ab_unmap.aux_dslocarq ab_unmap.aux_nmevearq ab_unmap.aux_qtinsarq ab_unmap.aux_cdagearq ab_unmap.cdageins ab_unmap.cdarqsel ab_unmap.nmarqsel ab_unmap.cdevesel

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
    ab_unmap.aux_fechamen AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_idstaeve AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.aux_nmarqimp AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
    ab_unmap.cdageins AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.cdarqsel AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.nmarqsel AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.cdevesel AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.aux_dsabearq AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_dsopearq AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.aux_cdagearq AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_dslocarq AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1     
     ab_unmap.aux_nmevearq AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_qtinsarq AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1                  
     WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 80 BY 20.


/************************ Procedure Settings *************************/

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


/*Funcao para descriptografar valores numericos.
  PS.:O valor deve ser passado no formato CHAR para realizar a descriptografia;
      O valor descriptografado sera retornado pela funcao no formato INTEGER.
*/
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION Descriptografa w-html 
FUNCTION Descriptografa RETURNS DECI
         (INPUT par_vlrentra AS CHAR):
    
    DEF VAR aux_vlrdescr AS CHAR                                NO-UNDO.
    DEF VAR aux_contador AS INT                                 NO-UNDO.

    ASSIGN aux_vlrdescr = ""
           aux_contador = 0.

    /*Percorre todas as posicoes (numeros) da string*/
    DO aux_contador = 1 TO LENGTH(par_vlrentra):

       /*Faz a descriptografia de cada posicao (numero)*/
       CASE SUBSTR(par_vlrentra,aux_contador,1):

           WHEN "0" THEN
                ASSIGN aux_vlrdescr = aux_vlrdescr + "9".
           WHEN "1" THEN
                ASSIGN aux_vlrdescr = aux_vlrdescr + "4".
           WHEN "2" THEN
                ASSIGN aux_vlrdescr = aux_vlrdescr + "8".
           WHEN "3" THEN
                ASSIGN aux_vlrdescr = aux_vlrdescr + "1".
           WHEN "4" THEN
                ASSIGN aux_vlrdescr = aux_vlrdescr + "3".
           WHEN "5" THEN
                ASSIGN aux_vlrdescr = aux_vlrdescr + "0".
           WHEN "6" THEN
                ASSIGN aux_vlrdescr = aux_vlrdescr + "5".
           WHEN "7" THEN                               
                ASSIGN aux_vlrdescr = aux_vlrdescr + "2".
           WHEN "8" THEN
                ASSIGN aux_vlrdescr = aux_vlrdescr + "6".
           WHEN "9" THEN
                ASSIGN aux_vlrdescr = aux_vlrdescr + "7".

       
       END CASE.


    END.

    /*Retorna o valor descriptografado no formato DECIMAL */
    RETURN DECI(aux_vlrdescr).

END FUNCTION.

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

  RUN RodaJavaScript("var mevento = new Array();").

  FOR EACH crapeap WHERE crapeap.idevento = INT(ab_unmap.aux_idevento)  
                    AND  crapeap.cdcooper = INT(ab_unmap.aux_cdcooper)  
                    AND((crapeap.cdagenci = INT(ab_unmap.cdageins))     
                    OR (crapeap.cdagenci = 0                           
                    AND  INT(ab_unmap.aux_idevento) = 2))                 /*assembléia */
                    AND  crapeap.dtanoage = INT(ab_unmap.aux_dtanoage)  
                    AND  crapeap.flgevsel = YES NO-LOCK, 

      FIRST crapedp WHERE crapedp.cdevento = crapeap.cdevento 
                      AND crapedp.idevento = crapeap.idevento 
                      AND crapedp.cdcooper = crapeap.cdcooper 
                      AND crapedp.dtanoage = crapeap.dtanoage 
                      AND crapedp.tpevento <> 10              
                      AND crapedp.tpevento <> 11 NO-LOCK,

            EACH crapadp WHERE (crapadp.idevento = crapeap.idevento
                            OR (crapadp.nrseqint = 0 AND crapadp.idevento = 2))
                           AND crapadp.cdcooper = crapeap.cdcooper 
                           AND crapadp.cdagenci = crapeap.cdagenci
                           AND crapadp.dtanoage = crapeap.dtanoage
                           AND crapadp.cdevento = crapeap.cdevento
                           //AND crapadp.idstaeve <> 4 /* Evento Encerrado */ //PRJ 322 - SM - 8 -- Linha comentada para mostrar eventos encerrados
						   NO-LOCK BREAK BY crapadp.cdagenci
                                         BY crapedp.nmevento
                                         BY crapadp.nrseqdig:

                 FIND FIRST crapagp WHERE crapagp.idevento = INT(ab_unmap.aux_idevento)
                                      AND crapagp.cdcooper = crapeap.cdcooper          
                                      AND crapagp.dtanoage = INT(ab_unmap.aux_dtanoage)
                                      AND crapagp.cdagenci = crapeap.cdagenci          
                                      AND crapagp.idstagen = 5 NO-LOCK NO-ERROR.

    IF NOT AVAILABLE crapagp AND ab_unmap.aux_idevento = "1" THEN 
      NEXT.                 
                 
    IF INT(ab_unmap.aux_idevento) = 1 THEN
      DO:
        /* Somente apresentar os nao cancelados, e onde a data de fim do  evento seja menor ou igual a data atual. */
        IF crapadp.IDSTAEVE = 2 OR
           crapadp.DTFINEVE > TODAY THEN
          NEXT.
          
      END.
                 
    ASSIGN aux_nrseqeve = IF crapadp.nrseqdig <> ? THEN crapadp.nrseqdig ELSE 0
           aux_nmevento = crapedp.nmevento.
                                                                                            
    IF crapadp.dtinieve <> ?  THEN
      ASSIGN aux_nmevento = aux_nmevento + " - " + STRING(crapadp.dtinieve,"99/99/9999").
    ELSE
      IF crapadp.nrmeseve <> 0  AND crapadp.nrmeseve <> ? THEN
        ASSIGN aux_nmevento = aux_nmevento + " - " + 
               vetormes[crapadp.nrmeseve].
                 
    IF crapadp.dshroeve <> "" THEN
      ASSIGN aux_nmevento = aux_nmevento + " - " + crapadp.dshroeve.
                 
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
                                      + "',fechamen:'" + STRING(aux_fechamen) + "'~});").
      END.	//PRJ 322 - SM - 8 -- Só carregar eventos que não estão com mês fechado			   								  
    
  END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaPac w-html 
PROCEDURE CriaListaPac :
/*------------------------------------------------------------------------------
  Purpose: Criar Lista de PA's da Coop.
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
    ("aux_fechamen":U,"ab_unmap.aux_fechamen":U,ab_unmap.aux_fechamen:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idstaeve":U,"ab_unmap.aux_idstaeve":U,ab_unmap.aux_idstaeve:HANDLE IN FRAME {&FRAME-NAME}).        
  RUN htmAssociate
    ("aux_nmarqimp":U,"ab_unmap.aux_nmarqimp":U,ab_unmap.aux_nmarqimp:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsabearq":U,"ab_unmap.aux_dsabearq":U,ab_unmap.aux_dsabearq:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("cdageins":U,"ab_unmap.cdageins":U,ab_unmap.cdageins:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("cdarqsel":U,"ab_unmap.cdarqsel":U,ab_unmap.cdarqsel:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nmarqsel":U,"ab_unmap.nmarqsel":U,ab_unmap.nmarqsel:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("cdevesel":U,"ab_unmap.cdevesel":U,ab_unmap.cdevesel:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsopearq":U,"ab_unmap.aux_dsopearq":U,ab_unmap.aux_dsopearq:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dslocarq":U,"ab_unmap.aux_dslocarq":U,ab_unmap.aux_dslocarq:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nmevearq":U,"ab_unmap.aux_nmevearq":U,ab_unmap.aux_nmevearq:HANDLE IN FRAME {&FRAME-NAME}).    
  RUN htmAssociate
    ("aux_qtinsarq":U,"ab_unmap.aux_qtinsarq":U,ab_unmap.aux_qtinsarq:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdagearq":U,"ab_unmap.aux_cdagearq":U,ab_unmap.aux_cdagearq:HANDLE IN FRAME {&FRAME-NAME}).
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ImportaInscricoes w-html  _ADM-CREATE-OBJECTS
PROCEDURE ImportaInscricoes:

  DEF  VAR aux_dtpreins AS DATE                                  NO-UNDO.
  DEF  VAR aux_dsabearq AS CHAR                                  NO-UNDO.
  DEF  VAR aux_cdagepac AS INTE                                  NO-UNDO.
  DEF  VAR aux_nmarquiv AS CHAR FORMAT "x(300)"                  NO-UNDO.
  DEF  VAR aux_nmarqimp AS CHAR FORMAT "x(300)"                  NO-UNDO.
  DEF  VAR aux_setlinha AS CHAR                                  NO-UNDO.

  DEF  VAR aux_invalido AS INTE NO-UNDO.
  DEF  VAR aux_contjuri AS INTE NO-UNDO.
  DEF  VAR aux_importad AS INTE NO-UNDO.
  DEF  VAR aux_impordup AS INTE NO-UNDO.
  DEF  VAR aux_ctrinval AS INTE NO-UNDO.
  DEF  VAR aux_contfisi AS INTE NO-UNDO.
  
  DEF  VAR aux_mensagem AS CHAR NO-UNDO.
  DEF  VAR aux_idseqttl AS INTE NO-UNDO.
  DEF  VAR aux_nrcrcard AS CHAR NO-UNDO.
  DEF  VAR aux_dscartao AS CHAR NO-UNDO.

  DEF  VAR aux_cdcooper AS INTE NO-UNDO.
  DEF  VAR aux_nrdconta AS INTE NO-UNDO.
  DEF  VAR aux_nrcartao AS DECI NO-UNDO.
  DEF  VAR aux_inpessoa AS INTE NO-UNDO.
  DEF  VAR aux_idsenlet AS LOGI NO-UNDO.
  DEF  VAR aux_tpusucar AS INTE NO-UNDO.
  DEF  VAR aux_dscritic AS CHAR NO-UNDO.
  
  DEF  VAR aux_nmarqinc AS CHAR FORMAT "x(300)"  NO-UNDO. /* PJ 322 - Mateus)*/
  DEF  VAR aux_nrtamarq AS INTE                  NO-UNDO. /* PJ 322 - Mateus)*/

  FIND crapcop WHERE crapcop.cdcooper = INT(ab_unmap.aux_cdcooper) NO-LOCK NO-ERROR NO-WAIT.

  FIND FIRST crapadp WHERE crapadp.nrseqdig = INT(ab_unmap.cdevesel) 
                       AND crapadp.cdcooper = INT(ab_unmap.aux_cdcooper) NO-LOCK NO-ERROR.

  IF NOT AVAILABLE crapadp THEN
    NEXT.

  FIND FIRST crapedp WHERE crapedp.cdevento = crapadp.cdevento            
                       AND crapedp.cdcooper = INT(ab_unmap.aux_cdcooper)  
                       AND crapedp.dtanoage = INT(ab_unmap.aux_dtanoage)  
                       AND crapedp.idevento = INT(ab_unmap.aux_idevento)  
                       AND crapedp.tpevento <> 10                         
                       AND crapedp.tpevento <> 11 NO-LOCK NO-ERROR.
    
  IF NOT AVAILABLE crapedp THEN
    NEXT.
    
  ASSIGN aux_cdagepac = IF crapedp.tpevento = 7 THEN 0 ELSE crapadp.cdagenci.                        

  ASSIGN aux_nmarqimp = "/usr/coop/" + crapcop.dsdircop + "/integra/wpgd0050" + STRING(TIME).
  ASSIGN aux_nmarquiv = "/micros/" + crapcop.dsdircop + "/" + ab_unmap.nmarqsel + "".    

  UNIX SILENT VALUE("ls """ + aux_nmarquiv + """ > " + aux_nmarqimp + ".txt 2> /dev/null").
  UNIX SILENT VALUE("quoter " + aux_nmarqimp + ".txt > " + aux_nmarqimp + ".q").
  
  ASSIGN aux_nrtamarq = LENGTH(aux_nmarquiv,"CHARACTER").        /* PJ 322 - Mateus)*/
  ASSIGN aux_nrtamarq = aux_nrtamarq - 3.                        /* PJ 322 - Mateus)*/
  ASSIGN aux_nmarqinc = SUBSTRING(aux_nmarquiv,1,aux_nrtamarq).  /* PJ 322 - Mateus)*/
  ASSIGN aux_nmarqinc = aux_nmarqinc + "INC".                    /* PJ 322 - Mateus)*/  
  
  UNIX SILENT VALUE("rm " + aux_nmarqinc). /* PJ 322 - Mateus)*/ 
  UNIX SILENT VALUE("echo Inconsistência............ Linha do arquivo........................ Inscrito/Conta..................."
                    + " >> " + aux_nmarqinc).  /* PJ 322 - Mateus)*/   

  INPUT STREAM str_1 FROM VALUE(aux_nmarqimp + ".q") NO-ECHO.     
  
  DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
    
    SET STREAM str_1 aux_nmarquiv WITH FRAME AA WIDTH 600. 

    INPUT STREAM str_2 FROM VALUE(aux_nmarquiv) NO-ECHO.

    ASSIGN aux_dsabearq = ENTRY(2, ENTRY(4, aux_nmarquiv, "/"), "-")
           aux_dsabearq = SUBSTRING(aux_dsabearq,1,12)
           aux_dtpreins = DATE(SUBSTRING(aux_dsabearq,1,2) + "/" + SUBSTRING(aux_dsabearq,3,2) + "/" + SUBSTRING(aux_dsabearq,5,4)).

    IMPORT STREAM str_2 UNFORMATTED aux_setlinha. 

    IF (SUBSTR(aux_setlinha,1,1) = "1") THEN
      ASSIGN aux_invalido = 0
             aux_contjuri = 0
             aux_importad = 0
             aux_impordup = 0
             aux_ctrinval = 0
             aux_contfisi = 0.
       
    DO WHILE TRUE TRANSACTION ON ENDKEY UNDO, LEAVE:

      SET STREAM str_2 aux_setlinha FORMAT "x(60)".

        IF (SUBSTR(aux_setlinha,1,1) = "2") THEN /* Detalhe */
          DO:
            ASSIGN aux_nrcrcard = STRING(Descriptografa(aux_setlinha))
                   aux_dscartao = "2ç" + SUBSTR(SUBSTR(aux_nrcrcard,2),1,16) + "=" + SUBSTR(SUBSTR(aux_nrcrcard,2),17).
                            
            FOR FIRST crapcrd FIELDS(cdcooper) WHERE crapcrd.cdcooper = INT(ab_unmap.aux_cdcooper)
                                                 AND crapcrd.nrcrcard = DECI(SUBSTR(aux_nrcrcard,2,16)) NO-LOCK: END.

            /* Cartao de credito CECRED */
            IF AVAILABLE crapcrd THEN
              DO:
                FOR FIRST crapdat FIELDS(dtmvtocd) WHERE crapdat.cdcooper = INT(ab_unmap.aux_cdcooper) NO-LOCK: END.
                      
                RUN sistema/generico/procedures/b1wgen0025.p PERSISTENT SET h-b1wgen0025.
                       
                IF VALID-HANDLE (h-b1wgen0025) THEN
                  DO:        
                    RUN verifica_cartao_cecred IN h-b1wgen0025(INPUT crapcrd.cdcooper,
                                                               INPUT 0, /* NAO TAA */
                                                               INPUT aux_dscartao,
                                                               INPUT crapdat.dtmvtocd,
                                                               INPUT RECID(crapcrd),
                                                              OUTPUT aux_cdcooper,
                                                              OUTPUT aux_nrdconta,                                      
                                                              OUTPUT aux_nrcartao,
                                                              OUTPUT aux_inpessoa,
                                                              OUTPUT aux_idsenlet,
                                                              OUTPUT aux_idseqttl,
                                                              OUTPUT aux_dscritic).
                    IF RETURN-VALUE <> "OK" THEN
                      DO:
                         UNIX SILENT VALUE("echo Cartão Inválido............" + aux_setlinha
                                           + " >> " + aux_nmarqinc).  /* PJ 322 - Mateus)*/ 
                        ASSIGN aux_ctrinval = aux_ctrinval + 1.
                        NEXT.
                      END.

                    DELETE PROCEDURE h-b1wgen0025.
                  END.
              END.
              /* Cartão Magnético */
            ELSE
              DO:
                ASSIGN aux_nrdconta = (Descriptografa(SUBSTR(aux_setlinha,11,8)))
                       aux_idseqttl = (Descriptografa(STRING(SUBSTR(aux_setlinha,28,2)))).
              END.

            FIND FIRST crapass WHERE crapass.cdcooper = INT(ab_unmap.aux_cdcooper)
                                 AND crapass.nrdconta = aux_nrdconta
                                 AND crapass.dtdemiss = ? NO-LOCK NO-ERROR. 

            /* Se nao achou registro contabiliza registro invalido */
            IF NOT AVAILABLE crapass THEN
              DO:
                UNIX SILENT VALUE("echo Conta Inexistente/Demitida " + aux_setlinha
                                  + " >> " + aux_nmarqinc).  /* PJ 322 - Mateus)*/ 
                ASSIGN aux_invalido = aux_invalido + 1.
              END.
            ELSE   
              DO:
                /* Conta quantos registros sao de pessoa juridica */
                  IF crapass.inpessoa = 2 OR crapass.inpessoa = 3 THEN
                    ASSIGN aux_contjuri = aux_contjuri + 1.
                  ELSE
                    ASSIGN aux_contfisi = aux_contfisi + 1.
              END.
			IF (crapass.inpessoa = 2 OR crapass.inpessoa = 3) and  INT(ab_unmap.aux_idevento) = 2 THEN /* INPESSOA*/
         	DO:
 
            FIND FIRST crapavt WHERE crapavt.cdcooper = crapass.cdcooper
                                 AND crapavt.nrdconta = crapass.nrdconta
                                 AND crapavt.tpctrato = 6 NO-LOCK NO-ERROR.

            IF NOT AVAILABLE crapavt THEN
			DO:
              NEXT.
			END.

            FIND FIRST crapidp WHERE crapidp.idevento = crapedp.idevento       
                                 AND crapidp.cdcooper = crapedp.cdcooper       
                                 AND crapidp.dtanoage = crapedp.dtanoage       
                                 AND crapidp.nrdconta = crapass.nrdconta       
                                 AND crapidp.nrseqeve = crapadp.nrseqdig NO-LOCK NO-ERROR.

            IF AVAILABLE crapidp THEN /* Se já houver inscrição importada */
              DO:
                UNIX SILENT VALUE("echo Inscrição Duplicada PJ.... " + aux_setlinha + " " + crapidp.nminseve + " / " + STRING(crapass.nrdconta)
                                  + " >> " + aux_nmarqinc).  /* PJ 322 - Mateus)*/ 
			  
                ASSIGN aux_impordup = aux_impordup + 1.
              END.
            ELSE  /* Se ainda não houver inscrição para o coop., cria */
              DO:
                /* Busca algum dos telefones do titular */
                FIND FIRST craptfc WHERE craptfc.cdcooper = crapttl.cdcooper
                                     AND craptfc.nrdconta = crapttl.nrdconta
                                     AND craptfc.idseqttl = 1
                                     AND craptfc.tptelefo = 1 /*Residencial*/ NO-LOCK NO-ERROR.
                   
                IF NOT AVAILABLE craptfc THEN
                  FIND FIRST craptfc WHERE craptfc.cdcooper = crapttl.cdcooper
                                       AND craptfc.nrdconta = crapttl.nrdconta
                                       AND craptfc.idseqttl = 1
                                       AND craptfc.tptelefo = 3 /*Comercial*/ NO-LOCK NO-ERROR.
                   
                  IF NOT AVAILABLE craptfc THEN
                    FIND FIRST craptfc WHERE craptfc.cdcooper = crapttl.cdcooper
                                         AND craptfc.nrdconta = crapttl.nrdconta
                                         AND craptfc.idseqttl = 1
                                         AND craptfc.tptelefo = 2 /*Celular*/ NO-LOCK NO-ERROR.
                  CREATE crapidp.
                  ASSIGN crapidp.cdagenci = aux_cdagepac
                         crapidp.cdageins = INT(ab_unmap.cdageins)
                         crapidp.cdcooper = INT(ab_unmap.aux_cdcooper)
                         crapidp.cdevento = crapedp.cdevento
                         crapidp.nrseqeve = INT(ab_unmap.cdevesel)
                         crapidp.cdgraupr = 9 /** Nenhum **/
                         crapidp.cdoperad = gnapses.cdoperad
                         crapidp.dsdemail = ""
                         crapidp.flgdispe = YES /* dispensa confirmação*/
                         crapidp.flgimpor = YES /* IMPORTADO */
                         crapidp.tpinseve = 1   /* Propria */
                         crapidp.dsobsins = ""
                         crapidp.dtanoage = INT(ab_unmap.aux_dtanoage)
                         crapidp.dtconins = TODAY
                         crapidp.dtpreins = aux_dtpreins
                         crapidp.idevento = INT(ab_unmap.aux_idevento)
                         crapidp.idseqttl = 1
                         crapidp.idstains = 2 /** confirmado **/
                         crapidp.nminseve = crapass.nmprimtl
                         crapidp.nrdconta = crapass.nrdconta
                         crapidp.nrdddins = craptfc.nrdddtfc WHEN AVAILABLE craptfc 
                         crapidp.nrseqdig = NEXT-VALUE(nrseqidp)
                         crapidp.nrtelins = craptfc.nrtelefo WHEN AVAILABLE craptfc
						 crapidp.tpctrato = crapavt.tpctrato
						 crapidp.nrctremp = crapavt.nrctremp
						 crapidp.nrcpfcgc = crapavt.nrcpfcgc.
                  
                  VALIDATE crapidp.

                  /* Contabiliza quantos registros foram importados */
                  ASSIGN aux_importad = aux_importad + 1.      
              END.
				 
			END.
			ELSE			  
			DO:
            FIND FIRST crapttl WHERE crapttl.cdcooper = crapass.cdcooper
                                 AND crapttl.nrdconta = crapass.nrdconta
                                 AND crapttl.idseqttl = aux_idseqttl NO-LOCK NO-ERROR.

            IF NOT AVAILABLE crapttl THEN
              NEXT.

            FIND FIRST crapidp WHERE crapidp.idevento = crapedp.idevento       
                                 AND crapidp.cdcooper = crapedp.cdcooper       
                                 AND crapidp.dtanoage = crapedp.dtanoage       
                                 AND crapidp.cdageins = INT(ab_unmap.cdageins) 
                                 AND crapidp.cdagenci = aux_cdagepac           
                                 AND crapidp.nrdconta = crapass.nrdconta       
                                 AND crapidp.idseqttl = crapttl.idseqttl       
                                 AND crapidp.nrseqeve = crapadp.nrseqdig NO-LOCK NO-ERROR.

            IF AVAILABLE crapidp THEN /* Se já houver inscrição importada */
              DO:
                UNIX SILENT VALUE("echo Inscrição Duplicada PF.... " + aux_setlinha + " " + crapidp.nminseve + " / " + STRING(crapass.nrdconta)
                                  + " >> " + aux_nmarqinc).  /* PJ 322 - Mateus)*/ 
			  
                ASSIGN aux_impordup = aux_impordup + 1.
              END.
            ELSE  /* Se ainda não houver inscrição para o coop., cria */
              DO:
                /* Busca algum dos telefones do titular */
                FIND FIRST craptfc WHERE craptfc.cdcooper = crapttl.cdcooper
                                     AND craptfc.nrdconta = crapttl.nrdconta
                                     AND craptfc.idseqttl = crapttl.idseqttl
                                     AND craptfc.tptelefo = 1 /*Residencial*/ NO-LOCK NO-ERROR.
                   
                IF NOT AVAILABLE craptfc THEN
                  FIND FIRST craptfc WHERE craptfc.cdcooper = crapttl.cdcooper
                                       AND craptfc.nrdconta = crapttl.nrdconta
                                       AND craptfc.idseqttl = crapttl.idseqttl
                                       AND craptfc.tptelefo = 3 /*Comercial*/ NO-LOCK NO-ERROR.
                   
                  IF NOT AVAILABLE craptfc THEN
                    FIND FIRST craptfc WHERE craptfc.cdcooper = crapttl.cdcooper
                                         AND craptfc.nrdconta = crapttl.nrdconta
                                         AND craptfc.idseqttl = crapttl.idseqttl
                                         AND craptfc.tptelefo = 2 /*Celular*/ NO-LOCK NO-ERROR.

                  CREATE crapidp.
                  ASSIGN crapidp.cdagenci = aux_cdagepac
                         crapidp.cdageins = INT(ab_unmap.cdageins)
                         crapidp.cdcooper = INT(ab_unmap.aux_cdcooper)
                         crapidp.cdevento = crapedp.cdevento
                         crapidp.nrseqeve = INT(ab_unmap.cdevesel)
                         crapidp.cdgraupr = 9 /** Nenhum **/
                         crapidp.cdoperad = gnapses.cdoperad
                         crapidp.dsdemail = ""
                         crapidp.flgdispe = YES /* dispensa confirmação*/
                         crapidp.flgimpor = YES /* IMPORTADO */
                         crapidp.tpinseve = 1   /* Propria */
                         crapidp.dsobsins = ""
                         crapidp.dtanoage = INT(ab_unmap.aux_dtanoage)
                         crapidp.dtconins = TODAY
                         crapidp.dtpreins = aux_dtpreins
                         crapidp.idevento = INT(ab_unmap.aux_idevento)
                         crapidp.idseqttl = crapttl.idseqttl
                         crapidp.idstains = 2 /** confirmado **/
                         crapidp.nminseve = crapttl.nmextttl
                         crapidp.nrdconta = crapass.nrdconta
                         crapidp.nrdddins = craptfc.nrdddtfc WHEN AVAILABLE craptfc 
                         crapidp.nrseqdig = NEXT-VALUE(nrseqidp)
                         crapidp.nrtelins = craptfc.nrtelefo WHEN AVAILABLE craptfc.
                  
                  VALIDATE crapidp.
                  
                  IF INT(ab_unmap.aux_idevento) = 1 AND crapadp.nrseqint <> ? THEN
                    DO:
                      CREATE crapidp.
                      ASSIGN crapidp.cdagenci = aux_cdagepac
                             crapidp.cdageins = INT(ab_unmap.cdageins)
                             crapidp.cdcooper = INT(ab_unmap.aux_cdcooper)
                             crapidp.cdevento = crapedp.cdevento
                             crapidp.nrseqeve = crapadp.nrseqint
                             crapidp.cdgraupr = 9 /** Nenhum **/
                             crapidp.cdoperad = gnapses.cdoperad
                             crapidp.dsdemail = ""
                             crapidp.flgdispe = YES /* dispensa confirmação*/
                             crapidp.flgimpor = YES /* IMPORTADO */
                             crapidp.tpinseve = 1   /* Propria */
                             crapidp.dsobsins = ""
                             crapidp.dtanoage = INT(ab_unmap.aux_dtanoage)
                             crapidp.dtconins = TODAY
                             crapidp.dtpreins = aux_dtpreins
                             crapidp.idevento = 2
                             crapidp.idseqttl = crapttl.idseqttl
                             crapidp.idstains = 2 /** confirmado **/
                             crapidp.nminseve = crapttl.nmextttl
                             crapidp.nrdconta = crapass.nrdconta
                             crapidp.nrdddins = craptfc.nrdddtfc WHEN AVAILABLE craptfc 
                             crapidp.nrseqdig = NEXT-VALUE(nrseqidp)
                             crapidp.nrtelins = craptfc.nrtelefo WHEN AVAILABLE craptfc.
                    END.
                  

                  /* Contabiliza quantos registros foram importados */
                  ASSIGN aux_importad = aux_importad + 1.      
              END.
			END. /* IF INPESSOA*/
          END. /* IF DETALHE */
    
    END. /* fim DO WHILE TRUE */

    INPUT STREAM str_2 CLOSE.

  END.  /*  Fim do DO WHILE TRUE  */

  INPUT STREAM str_1 CLOSE.
  UNIX SILENT VALUE("rm " + aux_nmarqimp + ".* 2> /dev/null").

  /* Grava LOG */
  IF aux_inregdel = 1 THEN /* Não houve exclusão de registros manuais */
    UNIX SILENT VALUE("echo " + STRING(TODAY)                        
                    + " " + STRING(TIME,"HH:MM:SS") + "' --> '"     
                    + "Operador " + gnapses.cdoperad                
                    + " Importou o arquivo "                        
                    + TRIM(ENTRY(4, aux_nmarquiv, "/")) + " para o " 
                    + "evento "  + ab_unmap.cdevesel                
                    + " do PA "  + ab_unmap.cdageins                
                    + ", sem exclusao de registros manuais."        
                    + " >> /usr/coop/" + crapcop.dsdircop            
                    + "/log/wpgd0050.log").
  ELSE /* Houve exclusão de registros manuais */
    UNIX SILENT VALUE("echo " + STRING(TODAY)                        
                    + " " + STRING(TIME,"HH:MM:SS") + "' --> '"     
                    + "Operador " + gnapses.cdoperad                
                    + " Importou o arquivo "                        
                    + TRIM(ENTRY(4, aux_nmarquiv, "/")) + " para o " 
                    + "evento "  + ab_unmap.cdevesel                
                    + " do PA "  + ab_unmap.cdageins                
                    + ", com exclusao de registros manuais."        
                    + " >> /usr/coop/" + crapcop.dsdircop            
                    + "/log/wpgd0050.log").

  /* Move o arq importado para o diretório salvar da Coop */
  UNIX SILENT VALUE("mv """ + aux_nmarquiv + """ /usr/coop/""" + crapcop.dsdircop + """/salvar/").
                               
  RUN RodaJavaScript('alert("Importadas: ' + STRING(aux_importad) + ' \\nJurídicas: ' + STRING(aux_contjuri) + ' \\nFísicas: ' + STRING(aux_contfisi) + 
                     ' \\n\\n** Nao Importadas ** \\n\\nDuplicadas: ' + STRING(aux_impordup) + ' \\nConta Inexistente/Demitida: ' + STRING(aux_invalido) + 
                     ' \\nCartoes Inválidos: ' + STRING(aux_ctrinval) + '");').
    
  RUN CriaListaArquivos.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaArquivos w-html 
PROCEDURE CriaListaArquivos :
/*------------------------------------------------------------------------------
  Purpose: Cria Lista de arquivos .ASS ou .PRG disponíveis no diret. /micros 
           da Coop. selecionada
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEF        VAR aux_nmarquiv AS CHAR FORMAT "x(300)"                 NO-UNDO.
    DEF        VAR aux_nmarqimp AS CHAR FORMAT "x(300)"                 NO-UNDO.
    DEF        VAR aux_nmarquiv2 AS CHAR                                NO-UNDO.
    DEF        VAR aux_dsagearq AS CHAR                                 NO-UNDO.
    DEF        VAR aux_dsopearq AS CHAR                                 NO-UNDO.
    
    FORM aux_nmarquiv WITH FRAME AA NO-BOX NO-LABELS.
    

    FIND crapcop WHERE crapcop.cdcooper = INT(ab_unmap.aux_cdcooper)
                                            NO-LOCK NO-ERROR NO-WAIT.

    ASSIGN vetorarquiv = "".

    /* Após importação, limpa o arquivo selecionado, pois ele foi movido */
    IF (ab_unmap.aux_cddopcao = 'imp') THEN
        ASSIGN ab_unmap.cdarqsel     = ""
               ab_unmap.nmarqsel     = ""
               ab_unmap.aux_cddopcao = 'selarq'.

    IF  INT(ab_unmap.aux_idevento) = 2  THEN /* Assembléia */
        ASSIGN aux_nmarquiv = "/micros/" + crapcop.dsdircop + "/" + "*.ASS".
    ELSE                                    /* PROGRID */
        ASSIGN aux_nmarquiv = "/micros/" + crapcop.dsdircop + "/" + "*.EVE".
    
    ASSIGN aux_nmarqimp = "/usr/coop/" + crapcop.dsdircop + "/integra/wpgd0050" + STRING(TIME).     
   
    UNIX SILENT VALUE("ls " + aux_nmarquiv + " > " + aux_nmarqimp + ".txt 2> /dev/null").
    UNIX SILENT VALUE("quoter " + aux_nmarqimp + ".txt > " + aux_nmarqimp + ".q").
   
    INPUT STREAM str_1 FROM VALUE(aux_nmarqimp + ".q")
          NO-ECHO. 
   
	  RUN RodaJavaScript("var nmarqui = new Array();").
		
    DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
    
        SET STREAM str_1 aux_nmarquiv WITH FRAME AA WIDTH 600.        
        
        IF  ab_unmap.aux_dtanoage <> SUBSTRING(ENTRY(4, aux_nmarquiv, "/"),15,4) THEN
            NEXT.

        ASSIGN aux_dsagearq = SUBSTRING(ENTRY(4, aux_nmarquiv, "/"),4,6).

        FIND crapage WHERE crapage.cdcooper = INT(ab_unmap.aux_cdcooper) AND
                           crapage.cdagenci = INT(aux_dsagearq) 
                           NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapage THEN
            DO:
                IF  ab_unmap.aux_cddopcao = '' THEN
                    RUN RodaJavaScript("alert('Arquivo " + ENTRY(4, aux_nmarquiv, "/") + 
                                       " não pode ser importado pois PA" + 
                                       " não está cadastrado.');").
                NEXT.
            END.
                                    
        ASSIGN aux_dsopearq = ENTRY(1, ENTRY(3, ENTRY(4, aux_nmarquiv, "/"), "-"), ".").

        FIND crapope WHERE crapope.cdcooper = INT(ab_unmap.aux_cdcooper) AND
                           crapope.cdoperad = STRING(aux_dsopearq)
                           NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapope THEN
            DO:
                IF  ab_unmap.aux_cddopcao = '' THEN
                    RUN RodaJavaScript("alert('Arquivo " + ENTRY(4, aux_nmarquiv, "/") + " com Operador inválido!');").

                NEXT.
            END.
         
				RUN RodaJavaScript("nmarqui.push(~{nmarqimp:'" +  STRING(ENTRY(4, aux_nmarquiv, "/")) + "'~});").
				
    END.  /*  Fim do DO WHILE TRUE  */

    INPUT STREAM str_1 CLOSE.
    
    UNIX SILENT VALUE("rm " + aux_nmarqimp + ".* 2> /dev/null").

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE SelecionaArquivo w-html  _ADM-CREATE-OBJECTS
PROCEDURE SelecionaArquivo:

  DEF        VAR aux_dsagearq AS CHAR                                  NO-UNDO.
  DEF        VAR aux_cdagearq AS CHAR                                  NO-UNDO.
  DEF        VAR aux_dsabearq AS CHAR                                  NO-UNDO.
  DEF        VAR aux_dsopearq AS CHAR                                  NO-UNDO.
  DEF        VAR aux_dslocarq AS CHAR                                  NO-UNDO.
  DEF        VAR aux_qtinsarq AS INTE                                  NO-UNDO.
  DEF        VAR aux_setlinha AS CHAR                                  NO-UNDO.
  DEF        VAR aux_nmarquiv AS CHAR FORMAT "x(300)"                  NO-UNDO.
  DEF        VAR aux_nmarqimp AS CHAR FORMAT "x(300)"                  NO-UNDO.
  DEF        VAR aux_qtdinscr AS INT                                   NO-UNDO.
  DEF        VAR aux_arqfecha AS LOG INIT FALSE                        NO-UNDO.
  DEF        VAR aux_qtdlinha AS INT                                   NO-UNDO.
  
  FORM aux_nmarquiv WITH FRAME AA NO-BOX NO-LABELS.

  RUN RodaJavaScript("var dadosarquivo = new Array();").
  
  FIND crapcop WHERE crapcop.cdcooper = INT(ab_unmap.aux_cdcooper) NO-LOCK NO-ERROR NO-WAIT.

  IF ab_unmap.nmarqsel = "" THEN
    LEAVE.

  ASSIGN aux_nmarqimp = "/usr/coop/" + crapcop.dsdircop + "/integra/wpgd0050" + STRING(TIME).
  ASSIGN aux_nmarquiv = "/micros/" + crapcop.dsdircop + "/" + ab_unmap.nmarqsel.

  UNIX SILENT VALUE("ls """ + aux_nmarquiv + """ > " + aux_nmarqimp + ".txt 2> /dev/null").
  UNIX SILENT VALUE("quoter " + aux_nmarqimp + ".txt > " + aux_nmarqimp + ".q").

  INPUT STREAM str_1 FROM VALUE(aux_nmarqimp + ".q") NO-ECHO.     


  DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

      /* Quando selecionado, converte o arq. para UNIX */
      UNIX SILENT VALUE("dos2ux """ + aux_nmarquiv + """ > """ +
                        aux_nmarquiv + """_ux 2> /dev/null").

      UNIX SILENT VALUE("mv """ + aux_nmarquiv + """_ux """ + aux_nmarquiv + 
                        """ 2> /dev/null").

      SET STREAM str_1 aux_nmarquiv WITH FRAME AA WIDTH 600.

      INPUT STREAM str_2 FROM VALUE(aux_nmarquiv) NO-ECHO.
      
      ASSIGN aux_qtinsarq = 0
             aux_arqfecha = FALSE
             aux_qtdinscr = 0.
        
      IMPORT STREAM str_2 UNFORMATTED aux_setlinha. 
      
      ASSIGN aux_qtdlinha = aux_qtdlinha + 1.

      IF  (SUBSTR(aux_setlinha,1,1) = "1") THEN /* Header */
      DO:
        /* Assembleia */
        IF INT(ab_unmap.aux_idevento) = 2  THEN
          DO: 
             ASSIGN aux_dslocarq = TRIM(SUBSTR(aux_setlinha,33)).
          END.
        ELSE 
          DO:
             ASSIGN aux_dslocarq = TRIM(SUBSTR(aux_setlinha,33,30))
                    aux_nmevearq = TRIM(SUBSTR(aux_setlinha,63,50)).
          END.
      END.    
      /* LUCAS R */
      DO  WHILE TRUE TRANSACTION ON ENDKEY UNDO, LEAVE:
         
          SET STREAM str_2 aux_setlinha FORMAT "x(60)".         
          ASSIGN aux_qtdlinha = aux_qtdlinha + 1.
          
          IF  (SUBSTR(aux_setlinha,1,1) = "2") THEN /*Inscritos*/
              ASSIGN aux_qtdinscr = aux_qtdinscr + 1. 
          
          IF  (SUBSTR(aux_setlinha,1,1) = "3") THEN /* Trailer */
              ASSIGN aux_qtinsarq = INT(ENTRY(3, aux_setlinha, "-"))
                     aux_arqfecha = TRUE. 
           NEXT.
          
      END. /* fim DO WHILE TRUE */ 

      INPUT STREAM str_2 CLOSE.
      
      IF ab_unmap.aux_dtanoage <> SUBSTRING(ENTRY(4, aux_nmarquiv, "/"),15,4) THEN
        NEXT.

      ASSIGN aux_dsagearq = SUBSTRING(ENTRY(4, aux_nmarquiv, "/"),4,6).

      FIND crapage WHERE crapage.cdcooper = INT(ab_unmap.aux_cdcooper)
                     AND crapage.cdagenci = INT(aux_dsagearq) NO-LOCK NO-ERROR.

      IF NOT AVAIL crapage THEN
        DO:
          IF ab_unmap.cdarqsel = '' THEN
            RUN RodaJavaScript("alert('Arquivo " + ENTRY(4, aux_nmarquiv, "/") + " com PA inválido!');").

          NEXT.

        END.
      ELSE
        DO:
          /* PROGRID */ 
          IF  ab_unmap.aux_idevento = "1" THEN
            DO:
              FIND FIRST crapagp WHERE crapagp.idevento = INT(ab_unmap.aux_idevento)
                                   AND crapagp.cdcooper = INT(ab_unmap.aux_cdcooper)
                                   AND crapagp.dtanoage = INT(ab_unmap.aux_dtanoage)
                                   AND crapagp.cdagenci = crapage.cdagenci NO-LOCK NO-ERROR.
          
              IF NOT AVAILABLE crapagp  THEN
                DO:
                  RUN RodaJavaScript("alert('PA do arquivo não liberado para esta agenda!');").
                  NEXT.
                END.
          
            END.
        
          ASSIGN aux_dsagearq = STRING(crapage.cdagenci) + " - " + TRIM(crapage.nmresage)
                 aux_cdagearq = STRING(crapage.cdagenci).
           
          IF ab_unmap.cdageins <> ab_unmap.aux_cdagenci THEN   
            DO:
              ASSIGN ab_unmap.cdageins = STRING(crapage.cdagenci).
            END.                                        
        
        END.
      
      ASSIGN aux_dsopearq = ENTRY(1, ENTRY(3, ENTRY(4, aux_nmarquiv, "/"), "-"), ".").
        
      FIND crapope WHERE crapope.cdcooper = INT(ab_unmap.aux_cdcooper)
                     AND crapope.cdoperad = STRING(aux_dsopearq) NO-LOCK NO-ERROR.

      IF NOT AVAIL crapope THEN
        DO:
          IF ab_unmap.cdarqsel = '' THEN
            RUN RodaJavaScript("alert('Arquivo " + ENTRY(4, aux_nmarquiv, "/") + " com Operador inválido!');").

          NEXT.

        END.
      ELSE
        ASSIGN aux_dsopearq = CAPS(crapope.cdoperad) + " - " + crapope.nmoperad.

      ASSIGN aux_dsabearq = ENTRY(2, ENTRY(4, aux_nmarquiv, "/"), "-")
             aux_dsabearq = SUBSTRING(aux_dsabearq,1,12)
             aux_dsabearq = SUBSTRING(aux_dsabearq,1,2) + "/" +
                            SUBSTRING(aux_dsabearq,3,2) + "/" +
                            SUBSTRING(aux_dsabearq,5,4) + " " +
                            SUBSTRING(aux_dsabearq,9,2) + ":" +
                            SUBSTRING(aux_dsabearq,11,2).

      IF NOT aux_arqfecha THEN
        ASSIGN aux_qtinsarq = aux_qtdinscr.
        
      IF dadosarquivo <> "" THEN
        ASSIGN dadosarquivo = dadosarquivo + ",".
          
          
      ASSIGN dadosarquivo = dadosarquivo + "~{dsagearq:'" + STRING(aux_dsagearq)
                                         + "',cdagearq:'" + STRING(aux_cdagearq)
                                         + "',dsabearq:'" + STRING(aux_dsabearq)
                                         + "',dsopearq:'" + STRING(aux_dsopearq)
                                         + "',dslocarq:'" + STRING(aux_dslocarq)
                                         + "',qtinsarq:'" + STRING(aux_qtinsarq)
                                         + "',nmevearq:'" + STRING(aux_nmevearq)
                                         + "',nmarqimp:'" + STRING(ENTRY(4, aux_nmarquiv, "/")) + "'~}".
  
    END.  /*  Fim do DO WHILE TRUE  */
    
  IF aux_qtdlinha = 0 THEN
    DO:
      RUN RodaJavaScript("alert('Não foi possível identificar os dados a serem importados pois o arquivo está vazio.');").        
    END.
  
  RUN RodaJavaScript("dadosarquivo.push("  + dadosarquivo + ");").
  
  INPUT STREAM str_1 CLOSE.
  
  UNIX SILENT VALUE("rm " + aux_nmarqimp + ".* 2> /dev/null").
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE DeletaInscrManuais w-html  _ADM-CREATE-OBJECTS
PROCEDURE DeletaInscrManuais:
/*------------------------------------------------------------------------------
  Purpose:     Deleta as inscrições com flgimpor = FALSE, ou seja, não importadas.
  Parameters:  <none>
------------------------------------------------------------------------------*/

    DEFINE VARIABLE aux_cdagepac       AS INT                           NO-UNDO.

    FIND FIRST crapadp WHERE crapadp.nrseqdig = INT(ab_unmap.cdevesel)    AND
                             crapadp.cdcooper = INT(ab_unmap.aux_cdcooper)
                             NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapadp THEN 
        NEXT.

    FIND FIRST crapedp WHERE crapedp.cdevento = crapadp.cdevento            AND
                             crapedp.cdcooper = crapadp.cdcooper            AND
                             crapedp.dtanoage = INT(ab_unmap.aux_dtanoage)  AND
                             crapedp.idevento = INT(ab_unmap.aux_idevento)
                             NO-LOCK NO-ERROR.
                         
    ASSIGN aux_cdagepac = IF crapedp.tpevento = 7 THEN 0 ELSE crapadp.cdagenci.
                         
    FOR EACH crapidp WHERE crapidp.idevento = crapedp.idevento       AND
                           crapidp.cdcooper = crapedp.cdcooper       AND
                           crapidp.dtanoage = crapedp.dtanoage       AND
                           crapidp.cdageins = INT(ab_unmap.cdageins) AND
                           crapidp.cdagenci = aux_cdagepac           AND
                           crapidp.nrseqeve = crapadp.nrseqdig       AND
                           crapidp.flgimpor = FALSE
                           EXCLUSIVE-LOCK.

        DELETE crapidp.

    END.

    ASSIGN ab_unmap.aux_cddopcao = 'imp'
           aux_inregdel = 2. /* Houve exclusão */

    RUN ImportaInscricoes.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE VerificaReg w-html  _ADM-CREATE-OBJECTS
PROCEDURE VerificaReg:
/*------------------------------------------------------------------------------
  Purpose:     Verifica a existência da inscrições manuais para o evento selecionado.
  Parameters:  <none>
------------------------------------------------------------------------------*/

    DEFINE VARIABLE registro           AS CHAR                           NO-UNDO.
    DEFINE VARIABLE aux_cdagepac       AS INT                            NO-UNDO.

    FIND FIRST crapadp WHERE crapadp.nrseqdig = INT(ab_unmap.aux_nrseqeve) AND
                             crapadp.cdcooper = INT(ab_unmap.aux_cdcooper)
                             NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapadp THEN 
        NEXT.

    FIND FIRST crapedp WHERE crapedp.cdevento = crapadp.cdevento            AND
                             crapedp.cdcooper = crapadp.cdcooper            AND
                             crapedp.dtanoage = INT(ab_unmap.aux_dtanoage)  AND
                             crapedp.idevento = INT(ab_unmap.aux_idevento)
                             NO-LOCK NO-ERROR.
                         
    ASSIGN aux_cdagepac = IF crapedp.tpevento = 7 THEN 0 ELSE crapadp.cdagenci.
                         
    FOR EACH crapidp WHERE crapidp.idevento = crapedp.idevento       AND
                           crapidp.cdcooper = crapedp.cdcooper       AND
                           crapidp.dtanoage = crapedp.dtanoage       AND
                           crapidp.cdageins = INT(ab_unmap.cdageins) AND
                           crapidp.cdagenci = aux_cdagepac           AND
                           crapidp.nrseqeve = crapadp.nrseqdig 
                           NO-LOCK.

        ASSIGN registro = registro + "'" + STRING(crapidp.flgimpor) + "',". 

    END.

    RUN RodaJavaScript("var regexist=new Array();regexist=[" + registro + "]").

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
    
ASSIGN opcao                    = GET-FIELD("aux_cddopcao")
       FlagPermissoes           = GET-VALUE("aux_lspermis")
       msg-erro-aux             = 0
       ab_unmap.aux_idevento    = GET-VALUE("aux_idevento")
       ab_unmap.aux_dsendurl    = AppURL                        
       ab_unmap.aux_lspermis    = FlagPermissoes                
       ab_unmap.aux_nrdrowid    = GET-VALUE("aux_nrdrowid")         
       ab_unmap.aux_cdcooper    = GET-VALUE("aux_cdcooper")
       ab_unmap.aux_dtanoage    = GET-VALUE("aux_dtanoage")
       ab_unmap.aux_nmarqimp    = GET-VALUE("aux_nmarqimp")
       ab_unmap.aux_cddopcao    = GET-VALUE("aux_cddopcao")
       ab_unmap.aux_nrseqeve    = GET-VALUE("aux_nrseqeve")
       ab_unmap.cdageins        = GET-VALUE("cdageins")
       ab_unmap.aux_cdagenci    = GET-VALUE("aux_cdagenci")
       ab_unmap.cdarqsel        = GET-VALUE("cdarqsel")
       ab_unmap.nmarqsel        = GET-VALUE("nmarqsel")
       ab_unmap.cdevesel        = GET-VALUE("cdevesel").

RUN outputHeader.

{includes/wpgd0098.i}

ab_unmap.aux_cdcooper:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = aux_crapcop.

/* Se a cooperativa ainda não foi escolhida, pega a da sessão do usuário */
IF   INT(ab_unmap.aux_cdcooper) = 0   THEN
     ab_unmap.aux_cdcooper = STRING(gnapses.cdcooper).

/* Se o PA ainda não foi escolhido, pega o da sessão do usuário */
IF   INT(ab_unmap.cdageins) = 0   THEN
     ab_unmap.cdageins = STRING(gnapses.cdagenci).

/* Posiciona por default, na agenda atual */

IF ab_unmap.aux_dtanoage = ""   THEN
   FIND LAST gnpapgd WHERE gnpapgd.idevento = INT(ab_unmap.aux_idevento) AND 
                           gnpapgd.cdcooper = INT(ab_unmap.aux_cdcooper) AND 
                           gnpapgd.dtanoage = INT(ab_unmap.aux_dtanoage) 
                           NO-LOCK NO-ERROR.
ELSE
   /* Se informou a data da agenda, permite que veja a agenda de um ano não atual */
   FIND LAST gnpapgd WHERE gnpapgd.idevento = INT(ab_unmap.aux_idevento) AND 
                           gnpapgd.cdcooper = INT(ab_unmap.aux_cdcooper) AND 
                           gnpapgd.dtanonov = INT(ab_unmap.aux_dtanoage) 
                           NO-LOCK NO-ERROR.

IF NOT AVAILABLE gnpapgd THEN
   DO:
      IF ab_unmap.aux_dtanoage <> ""   THEN
         DO:
             RUN RodaJavaScript("alert('Nao existe agenda para o ano (" + ab_unmap.aux_dtanoage + ") informado!');").
             ASSIGN opcao = "".

         END.

      FIND LAST gnpapgd WHERE gnpapgd.idevento = INT(ab_unmap.aux_idevento) AND 
                              gnpapgd.cdcooper = INT(ab_unmap.aux_cdcooper)
                              NO-LOCK NO-ERROR.

   END.

IF AVAILABLE gnpapgd THEN
   DO:
       IF ab_unmap.aux_dtanoage = ""   THEN
          ASSIGN ab_unmap.aux_dtanoage = STRING(gnpapgd.dtanoage).
       ELSE
          ASSIGN ab_unmap.aux_dtanoage = STRING(gnpapgd.dtanonov).
   END.
ELSE
   ASSIGN ab_unmap.aux_dtanoage = "".

/* método POST */
IF REQUEST_METHOD = "POST":U THEN 
   DO:
      IF (ab_unmap.aux_cddopcao = "imp") THEN
          DO:
             ASSIGN aux_inregdel = 1. /* Não houve exclusão */
             RUN ImportaInscricoes.
          END.    
          
      IF (ab_unmap.aux_cddopcao = "del-manual") THEN
          RUN DeletaInscrManuais.

      IF (ab_unmap.aux_cddopcao = "verreg") THEN
          RUN VerificaReg.

      RUN CriaListaPac.
      RUN CriaListaArquivos.
      RUN SelecionaArquivo.
      RUN CriaListaEventos.
      RUN displayFields.
      RUN enableFields.
      RUN outputFields.
      RUN RodaJavaScript('CarregaPrincipal();').
                           
   END. /* Fim do método POST */

ELSE /* Método GET */   
   DO:
      
      RUN PermissaoDeAcesso(INPUT ProgramaEmUso, 
                            OUTPUT IdentificacaoDaSessao, 
                            OUTPUT ab_unmap.aux_lspermis).
      
      CASE ab_unmap.aux_lspermis:
           WHEN "1" THEN /* get-cookie em usuario-em-uso voltou valor nulo */
                RUN RodaJavaScript('top.close(); window.open("falha","janela_principal","toolbar=yes,location=yes,diretories=no,status=yes,menubar=yes,scrollbars=yes,resizable=yes"); ').

           WHEN "2" THEN /* identificacao vinda do cookie bao existe na tabela de log de sessao */ 
                DO: 
                    DELETE-COOKIE("cookie-usuario-em-uso",?,?).
                    RUN RodaJavaScript('top.close(); window.open("falha","janela_principal","toolbar=yes,location=yes,diretories=no,status=yes,menubar=yes,scrollbars=yes,resizable=yes"); ').
                END.
  
           WHEN "3" THEN /* usuario nao tem permissao para acessa o programa */
                RUN RodaJavaScript('window.location.href = "' + ab_unmap.aux_dsendurl + '/gerenciador/negado";').
          
           OTHERWISE
                DO:
                    RUN CriaListaPac.
                    RUN CriaListaArquivos.
                    RUN displayFields.
                    RUN CriaListaEventos.
                    RUN enableFields.
                    RUN outputFields.  
                    RUN RodaJavaScript('CarregaPrincipal()').

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
