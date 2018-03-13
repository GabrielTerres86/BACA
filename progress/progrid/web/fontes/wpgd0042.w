/*...............................................................................

Alterações: 10/12/2008 - Melhoria de performance para a tabela gnapses (Evandro).

            17/11/2009 - Substituida gnpapgd.dtanonov por ab_unmap.aux_dtanoage
                                     na procedure CriaListaEventos (Diego).
									 
			05/06/2012 - Adaptação dos fontes para projeto Oracle. Alterado
						 busca na gnapses de CONTAINS para MATCHES (Guilherme Maba).
                                  
			09/11/2016 - inclusao de LOG. (Jean Michel)

......................................................................... */

{ sistema/generico/includes/var_log_progrid.i }

&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD aux_cdagenci AS CHARACTER 
       FIELD aux_cdcooper AS CHARACTER 
       FIELD aux_cdevento AS CHARACTER 
       FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dsstatus AS CHARACTER 
       FIELD aux_dtanoage AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_flginter AS LOGICAL
       FIELD cdagenci AS CHARACTER FORMAT "X(256)":U 
       FIELD cdcooper AS CHARACTER FORMAT "X(256)":U 
       FIELD idevento AS CHARACTER FORMAT "X(256)":U
			 FIELD aux_nrseqpgm AS CHARACTER.


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
DEFINE VARIABLE ProgramaEmUso AS CHARACTER INITIAL ["wpgd0042"].
DEFINE VARIABLE NmeDoPrograma AS CHARACTER INITIAL ["wpgd0042.w"].

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

DEFINE VARIABLE aux_crapcop           AS CHAR                           NO-UNDO.
DEFINE VARIABLE vetorevento           AS CHARACTER                      NO-UNDO.
DEFINE VARIABLE vetorprogra           AS CHARACTER                      NO-UNDO.
DEFINE VARIABLE vetorpac              AS CHAR                           NO-UNDO.

DEFINE TEMP-TABLE ttEventos 
    FIELD CdCooper AS INTEGER
    FIELD CdAgenci AS INTEGER
    FIELD CdEvento AS INTEGER
    FIELD NmEvento AS CHARACTER
    FIELD NrSeqEve AS INTEGER.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE fontes/wpgd0042.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS ab_unmap.aux_cdagenci ab_unmap.aux_cdcooper ab_unmap.aux_cdevento ab_unmap.aux_dsendurl ab_unmap.aux_dsstatus ab_unmap.aux_dtanoage ab_unmap.aux_idevento ab_unmap.aux_lspermis ab_unmap.cdagenci ab_unmap.cdcooper ab_unmap.idevento ab_unmap.aux_flginter ab_unmap.aux_nrseqpgm
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.aux_cdagenci ab_unmap.aux_cdcooper ab_unmap.aux_cdevento ab_unmap.aux_dsendurl ab_unmap.aux_dsstatus ab_unmap.aux_dtanoage ab_unmap.aux_idevento ab_unmap.aux_lspermis ab_unmap.cdagenci ab_unmap.cdcooper ab_unmap.idevento ab_unmap.aux_flginter ab_unmap.aux_nrseqpgm

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
     ab_unmap.aux_cdevento AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.aux_dsendurl AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_dsstatus AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
		ab_unmap.aux_nrseqpgm AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
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
     ab_unmap.cdagenci AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.cdcooper AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.idevento AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_flginter AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS TOGGLE-BOX
          SIZE 20 BY 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 43.4 BY 24.71.


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
          FIELD aux_cdevento AS CHARACTER 
          FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dsstatus AS CHARACTER 
          FIELD aux_dtanoage AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
          FIELD cdagenci AS CHARACTER FORMAT "X(256)":U 
          FIELD cdcooper AS CHARACTER FORMAT "X(256)":U 
          FIELD idevento AS CHARACTER FORMAT "X(256)":U 
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW w-html ASSIGN
         HEIGHT             = 24.71
         WIDTH              = 43.4.
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
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_cdevento IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dsendurl IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_dsstatus IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dtanoage IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_idevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lspermis IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.cdagenci IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.cdcooper IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.idevento IN FRAME Web-Frame
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
  DEFINE VARIABLE aux_nrseqeve AS INT  NO-UNDO.
  DEFINE VARIABLE aux_nmevento AS CHAR NO-UNDO.
  DEFINE VARIABLE vetormes     AS CHAR EXTENT 12
      INITIAL ["Janeiro","Fevereiro","Março","Abril","Maio","Junho",
               "Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"].
  
  RUN RodaJavaScript("var mevento = new Array();").
  
    FOR EACH crapeap WHERE crapeap.idevento = INT(ab_unmap.aux_idevento)  AND
                           crapeap.cdcooper = INT(ab_unmap.cdcooper)      AND
                           crapeap.cdagenci = INT(ab_unmap.cdagenci)      AND 
                           crapeap.dtanoage = INT(ab_unmap.aux_dtanoage)  AND
                           crapeap.flgevsel = YES                         NO-LOCK, 
       FIRST crapedp WHERE crapedp.cdevento = crapeap.cdevento            AND
                           crapedp.idevento = crapeap.idevento            AND
                           crapedp.cdcooper = crapeap.cdcooper            AND
                           crapedp.dtanoage = crapeap.dtanoage            AND
													 (crapedp.nrseqpgm = INT(ab_unmap.aux_nrseqpgm)       OR
													 INT(ab_unmap.aux_nrseqpgm) = 0)                     NO-LOCK,
        EACH crapadp WHERE crapadp.idevento = crapeap.idevento            AND
                           crapadp.cdcooper = crapeap.cdcooper            AND
                           crapadp.cdagenci = crapeap.cdagenci            AND
                           crapadp.dtanoage = crapeap.dtanoage            AND
                           crapadp.cdevento = crapeap.cdevento            NO-LOCK
                           BREAK BY crapadp.cdagenci
                                    BY crapedp.nmevento
                                       BY crapadp.nrseqdig:
    
        FIND FIRST crapagp WHERE crapagp.idevento = INT(ab_unmap.aux_idevento)  AND
                                 crapagp.cdcooper = crapeap.cdcooper            AND
                                 crapagp.dtanoage = INT(ab_unmap.aux_dtanoage)  AND
                                 crapagp.cdagenci = crapeap.cdagenci            AND
                                 crapagp.idstagen = 5                           NO-LOCK NO-ERROR.
     
        IF NOT AVAIL crapagp THEN NEXT. 
      
        ASSIGN aux_nrseqeve = IF crapadp.nrseqdig <> ? THEN crapadp.nrseqdig ELSE 0
               aux_nmevento = crapedp.nmevento.
                                                                                   
        IF  crapadp.dtinieve <> ?  THEN
            aux_nmevento = aux_nmevento + " - " + STRING(crapadp.dtinieve,"99/99/9999").
        ELSE
        IF  crapadp.nrmeseve <> 0  AND crapadp.nrmeseve <> ? THEN
            aux_nmevento = aux_nmevento + " - " + vetormes[crapadp.nrmeseve].
    
        IF  crapadp.dshroeve <> "" THEN
            aux_nmevento = aux_nmevento + " - " + crapadp.dshroeve.
    
        
        RUN RodaJavaScript("mevento.push(~{cdagenci:'" +  STRING(crapeap.cdagenci)
                                      + "',cdcooper:'" +  STRING(crapeap.cdcooper)
                                      + "',cdevento:'" +  STRING(crapeap.cdevento)
                                      + "',nmevento:'" +  STRING(aux_nmevento)
                                      + "',nrseqeve:'" +  STRING(aux_nrseqeve) + "'~});").
        
    END.
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaEventosAssemb w-html 
PROCEDURE CriaListaEventosAssemb :

    DEFINE VARIABLE aux_nrseqeve AS INT  NO-UNDO.
    DEFINE VARIABLE aux_nmevento AS CHAR NO-UNDO.
    DEFINE VARIABLE vetormes     AS CHAR EXTENT 12
        INITIAL ["Janeiro","Fevereiro","Março","Abril","Maio","Junho",
                 "Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"].

	RUN RodaJavaScript("var mevento = new Array();").
	
    FOR EACH crapeap WHERE crapeap.idevento = INT(ab_unmap.aux_idevento)  AND
                           crapeap.cdcooper = INT(ab_unmap.cdcooper)      AND
                          (crapeap.cdagenci = INT(ab_unmap.cdagenci)   OR
                           crapeap.cdagenci = 0)                          AND 
                           crapeap.dtanoage = INT(ab_unmap.aux_dtanoage)  AND
                           crapeap.flgevsel = YES                         NO-LOCK, 
       FIRST crapedp WHERE crapedp.cdevento = crapeap.cdevento            AND
                           crapedp.idevento = crapeap.idevento            AND
                           crapedp.cdcooper = crapeap.cdcooper            AND
												 crapedp.dtanoage = crapeap.dtanoage            AND
												 (crapedp.nrseqpgm = INT(ab_unmap.aux_nrseqpgm)       OR
													INT(ab_unmap.aux_nrseqpgm) = 0) 									  NO-LOCK,
        EACH crapadp WHERE crapadp.idevento = crapeap.idevento            AND
                           crapadp.cdcooper = crapeap.cdcooper            AND
                           crapadp.cdagenci = crapeap.cdagenci            AND
                           crapadp.dtanoage = crapeap.dtanoage            AND
                           crapadp.cdevento = crapeap.cdevento            NO-LOCK
                           BREAK BY crapadp.cdagenci
                                    BY crapedp.nmevento
                                       BY crapadp.nrseqdig:
    
        ASSIGN aux_nrseqeve = IF crapadp.nrseqdig <> ? THEN crapadp.nrseqdig ELSE 0
               aux_nmevento = crapedp.nmevento.
                                                                                   
        IF  crapadp.dtinieve <> ?  THEN
            aux_nmevento = aux_nmevento + " - " + STRING(crapadp.dtinieve,"99/99/9999").
        ELSE
        IF  crapadp.nrmeseve <> 0  AND crapadp.nrmeseve <> ? THEN
            aux_nmevento = aux_nmevento + " - " + vetormes[crapadp.nrmeseve].
    
        IF  crapadp.dshroeve <> "" THEN
            aux_nmevento = aux_nmevento + " - " + crapadp.dshroeve.
    
			RUN RodaJavaScript("mevento.push(~{cdagenci:'" +  STRING(crapeap.cdagenci) 
																		+ "',cdcooper:'" +  STRING(crapeap.cdcooper) 
																		+ "',cdevento:'" +  STRING(crapeap.cdevento) 
																		+ "',nmevento:'" +  STRING(aux_nmevento)     
																		+ "',nrseqeve:'" +  STRING(aux_nrseqeve) + "'~});").
			
    END.
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE htmOffsets w-html  _WEB-HTM-OFFSETS
PROCEDURE htmOffsets :

  RUN readOffsets ("{&WEB-FILE}":U).
  RUN htmAssociate
    ("aux_cdagenci":U,"ab_unmap.aux_cdagenci":U,ab_unmap.aux_cdagenci:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdcooper":U,"ab_unmap.aux_cdcooper":U,ab_unmap.aux_cdcooper:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdevento":U,"ab_unmap.aux_cdevento":U,ab_unmap.aux_cdevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsendurl":U,"ab_unmap.aux_dsendurl":U,ab_unmap.aux_dsendurl:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsstatus":U,"ab_unmap.aux_dsstatus":U,ab_unmap.aux_dsstatus:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dtanoage":U,"ab_unmap.aux_dtanoage":U,ab_unmap.aux_dtanoage:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idevento":U,"ab_unmap.aux_idevento":U,ab_unmap.aux_idevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lspermis":U,"ab_unmap.aux_lspermis":U,ab_unmap.aux_lspermis:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("cdagenci":U,"ab_unmap.cdagenci":U,ab_unmap.cdagenci:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("cdcooper":U,"ab_unmap.cdcooper":U,ab_unmap.cdcooper:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("idevento":U,"ab_unmap.idevento":U,ab_unmap.idevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_flginter":U,"ab_unmap.aux_flginter":U,ab_unmap.aux_flginter:HANDLE IN FRAME {&FRAME-NAME}).
	RUN htmAssociate
    ("aux_nrseqpgm":U,"ab_unmap.aux_nrseqpgm":U,ab_unmap.aux_nrseqpgm:HANDLE IN FRAME {&FRAME-NAME}).
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaProgramas w-html 
PROCEDURE CriaListaProgramas:
	message "JMD".
 {includes/wpgd0010.i}
 ASSIGN ab_unmap.aux_nrseqpgm:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = vetorprogra.
  
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
DEFINE VARIABLE aux_flgfirst AS LOGICAL    INIT TRUE NO-UNDO.

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
       ab_unmap.aux_dtanoage    = GET-VALUE("aux_dtanoage")
       ab_unmap.cdagenci        = GET-VALUE("cdagenci")
       ab_unmap.cdcooper        = GET-VALUE("cdcooper")
			 ab_unmap.aux_nrseqpgm    = GET-VALUE("aux_nrseqpgm")
       ab_unmap.aux_flginter    = IF GET-VALUE("aux_flginter") = "on" THEN YES ELSE NO.

RUN outputHeader.

/* Se a cooperativa ainda não foi escolhida, pega a da sessão do usuário */
IF   INT(ab_unmap.cdcooper) = 0   THEN
     ab_unmap.cdcooper = STRING(gnapses.cdcooper).

/* Se o PA ainda não foi escolhido, pega o da sessão do usuário */
IF   INT(ab_unmap.cdagenci) = 0   AND
     ab_unmap.cdagenci      = ""  THEN
     ab_unmap.cdagenci = STRING(gnapses.cdagenci).

/* Posiciona por default, na agenda atual */
IF   ab_unmap.aux_dtanoage = ""   THEN
     FIND LAST gnpapgd WHERE gnpapgd.idevento = INT(ab_unmap.aux_idevento) AND 
                             gnpapgd.cdcooper = INT(ab_unmap.cdcooper)     AND 
                             gnpapgd.dtanoage = INT(ab_unmap.aux_dtanoage) NO-LOCK NO-ERROR.
ELSE 
     /* Se informou a data da agenda, permite que veja a agenda de um ano não atual */
     FIND LAST gnpapgd WHERE gnpapgd.idevento = INT(ab_unmap.aux_idevento) AND 
                             gnpapgd.cdcooper = INT(ab_unmap.cdcooper)     AND 
                             gnpapgd.dtanonov = INT(ab_unmap.aux_dtanoage) NO-LOCK NO-ERROR.
   
IF NOT AVAILABLE gnpapgd THEN
   DO:
      IF   ab_unmap.aux_dtanoage <> ""   THEN
           RUN RodaJavaScript("alert('Nao existe agenda para o ano (" + ab_unmap.aux_dtanoage + ") informado!');").

      FIND LAST gnpapgd WHERE gnpapgd.idevento = INT(ab_unmap.aux_idevento) AND 
                              gnpapgd.cdcooper = INT(ab_unmap.cdcooper)     NO-LOCK NO-ERROR.
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

/* gera lista de cooperativas */
{includes/wpgd0098.i}
ab_unmap.aux_cdcooper:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = aux_crapcop.

RUN CriaListaProgramas.

/* PROGRID */
IF   INT(ab_unmap.aux_idevento) = 1   THEN
     DO:
         /* gera lista de pa´s */
         {includes/wpgd0099.i ab_unmap.aux_dtanoage}         

         /* gera lista de eventos */
         RUN CriaListaEventos. 
     END.
ELSE 
/* ASSEMBLEIAS */
     DO:
        { includes/wpgd0097.i }

         vetorpac = "~{" + "cdcooper:"    + "'" + ab_unmap.cdcooper
                         + "',cdagenci:"  + "'" + "0"
                         + "',nmresage:"  + "'" + "TODOS" + "'~}" 
                         + "," + vetorpac.

        /* gera lista de eventos */
        RUN CriaListaEventosAssemb. 
    END.

/* Cria o array com os pa's */
RUN RodaJavaScript("var mpac=new Array();mpac=["  + vetorpac + "]").


/* Status das pré-inscrições */
FIND FIRST craptab WHERE craptab.cdcooper = 0               AND
                         craptab.nmsistem = "CRED"          AND
                         craptab.tptabela = "CONFIG"        AND    
                         craptab.cdempres = 0               AND  
                         craptab.cdacesso = "PGSTINSCRI"    AND  
                         craptab.tpregist = 0               NO-LOCK NO-ERROR.


ASSIGN ab_unmap.aux_dsstatus:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = craptab.dstextab.

RUN insere_log_progrid("WPGD0042.w",STRING(opcao) + "|" + STRING(ab_unmap.aux_idevento) + "|" +
					  STRING(ab_unmap.aux_dtanoage) + "|" + STRING(ab_unmap.cdagenci) + "|" +
					  STRING(ab_unmap.cdcooper) + "|" + STRING(ab_unmap.aux_flginter)).
   
/* método POST */
IF REQUEST_METHOD = "POST":U THEN 
   DO:
      RUN inputFields.
      RUN displayFields.
      RUN enableFields.
      RUN outputFields.
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
                    RUN displayFields.
                    RUN enableFields.
                    RUN outputFields.
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

