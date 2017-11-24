/*-----------------------------------------------------------------------------
    Alteracoes: 
------------------------------------------------------------------------------*/


&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD aux_cdagenci AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_cdcooper AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_cdevento AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dtanoage AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nmpagina AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nmrescop AS CHARACTER 
       FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
       FIELD glb_cdcooper AS CHARACTER FORMAT "X(256)":U
       FIELD aux_cdcopope AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_cdoperad AS CHARACTER FORMAT "X(256)":U.


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
DEFINE VARIABLE ProgramaEmUso AS CHARACTER INITIAL ["wpgd0053"].
DEFINE VARIABLE NmeDoPrograma AS CHARACTER INITIAL ["wpgd0053.w"].

DEFINE VARIABLE opcao                 AS CHARACTER.
DEFINE VARIABLE msg-erro              AS CHARACTER.
DEFINE VARIABLE msg-erro-aux          AS INTEGER.
DEFINE VARIABLE pesquisa              AS CHARACTER.     
DEFINE VARIABLE FlagPermissoes        AS CHARACTER.
DEFINE VARIABLE IdentificacaoDaSessao AS CHARACTER FORMAT "x(47)".
DEFINE VARIABLE vauxsenha             AS CHARACTER FORMAT "X(16)".

DEFINE VARIABLE i                     AS INTEGER                        NO-UNDO.
DEFINE VARIABLE m-erros               AS CHARACTER                      NO-UNDO.
DEFINE VARIABLE v-qtdeerro            AS INTEGER                        NO-UNDO.
DEFINE VARIABLE v-descricaoerro       AS CHARACTER                      NO-UNDO.
DEFINE VARIABLE v-identificacao       AS CHARACTER                      NO-UNDO.

DEFINE VARIABLE aux_nmrescop          AS CHARACTER                      NO-UNDO.
DEFINE VARIABLE aux_crapcop           AS CHAR                           NO-UNDO.

/* Para os PA'S */
DEFINE VARIABLE vetorpacs             AS CHARACTER FORMAT "X(2000)"     NO-UNDO.
DEFINE VARIABLE aux_qtevepac          AS INTEGER                        NO-UNDO.
DEFINE VARIABLE aux_nmevepac          AS CHARACTER                      NO-UNDO.

/*** Declaração de BOs ***/
DEFINE VARIABLE h-b1wpgd0014          AS HANDLE                         NO-UNDO.
DEFINE VARIABLE h-b1wpgd0014a         AS HANDLE                         NO-UNDO.

/*** Temp Tables ***/
DEFINE TEMP-TABLE cratedp NO-UNDO     LIKE crapedp.

DEFINE TEMP-TABLE cratagp NO-UNDO
       FIELD cdagenci LIKE crapage.cdagenci
       FIELD nmresage LIKE crapage.nmresage
			 FIELD idstagen LIKE crapagp.idstagen
       INDEX cratagp1 AS PRIMARY UNIQUE cdagenci.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE fontes/wpgd0053.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS ab_unmap.aux_dtanoage ab_unmap.aux_cdagenci ab_unmap.aux_nmpagina ab_unmap.aux_cdcooper ab_unmap.glb_cdcooper ab_unmap.aux_nmrescop ab_unmap.aux_cddopcao ab_unmap.aux_cdevento ab_unmap.aux_dsendurl ab_unmap.aux_idevento ab_unmap.aux_cdcopope ab_unmap.aux_cdoperad   ab_unmap.aux_lspermis ab_unmap.aux_stdopcao 
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.aux_dtanoage ab_unmap.aux_cdagenci ab_unmap.aux_nmpagina ab_unmap.aux_cdcooper ab_unmap.glb_cdcooper ab_unmap.aux_nmrescop ab_unmap.aux_cddopcao ab_unmap.aux_cdevento ab_unmap.aux_dsendurl ab_unmap.aux_idevento ab_unmap.aux_lspermis ab_unmap.aux_cdcopope ab_unmap.aux_cdoperad  ab_unmap.aux_stdopcao 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME

/* ***********************  Control Definitions  ********************** */
/* Definitions of the field level widgets                               */
/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     ab_unmap.aux_dtanoage AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cdagenci AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nmpagina AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cdcooper AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.glb_cdcooper AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nmrescop AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
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
     ab_unmap.aux_stdopcao AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cdcopope AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cdoperad AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
          
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 49.2 BY 16.95.

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
          FIELD aux_cdagenci AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_cdcooper AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_cdevento AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dtanoage AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nmpagina AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nmrescop AS CHARACTER 
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
         HEIGHT             = 16.95
         WIDTH              = 49.2.
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
/* SETTINGS FOR FILL-IN ab_unmap.aux_cdagenci IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_cdcooper IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_cddopcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_cdevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dsendurl IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dtanoage IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_idevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lspermis IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nmpagina IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_nmrescop IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaCooperativa w-html 
PROCEDURE CriaListaCooperativa :
  ASSIGN aux_nmrescop = "".

  {includes/wpgd0098.i}

  ab_unmap.aux_nmrescop:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = aux_crapcop.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaEventos w-html 
PROCEDURE CriaListaEventos :
  
	DEF VAR aux_flpacenv AS INTEGER NO-UNDO.
 
	RUN RodaJavaScript("var meventos = new Array();").
    
  /* Eventos já selecionados para sugerir aos PA'S da cooperativa */
  FOR EACH crapedp WHERE crapedp.cdcooper = INTEGER(ab_unmap.aux_cdcooper)   
                     AND crapedp.idevento = INTEGER(ab_unmap.aux_idevento)   
                     AND crapedp.dtanoage = INTEGER(ab_unmap.aux_dtanoage)   
                     AND (crapedp.tpevento = 7	                               
											OR  crapedp.tpevento = 12) NO-LOCK
                      BY crapedp.nmevento:

      /* Busca os PA'S cadastrados no Evento */
      FOR EACH  crapeap WHERE crapeap.cdcooper = crapedp.cdcooper   AND
                              crapeap.idevento = crapedp.idevento   AND
                              crapeap.cdevento = crapedp.cdevento   AND
                              crapeap.dtanoage = crapedp.dtanoage   NO-LOCK,
          
          /* Busca o nome do PA */
          FIRST crapagp WHERE crapagp.cdcooper = crapeap.cdcooper
													AND crapagp.dtanoage = crapeap.dtanoage
                          AND crapagp.cdagenci = 0 NO-LOCK:
          
					IF NOT AVAILABLE crapagp THEN
            DO:
              ASSIGN aux_flpacenv = 0. /* Eventos não enviados para o PA */
            END.
          ELSE
            DO:        
              IF crapagp.idstagen = 0 THEN
                DO:
                  ASSIGN aux_flpacenv = 0. /* Eventos não enviados para o PA */
                END.
              ELSE
                DO:
                  ASSIGN aux_flpacenv = 1.  /* Eventos já enviados para o PA */
                END.
            END.
				                             
					RUN RodaJavaScript("meventos.push(~{cdevento:'" + STRING(crapedp.cdevento)     
                                         + "',nmevento:'" + crapedp.nmevento           
                                         + "',flpacenv:'" + TRIM(STRING(aux_flpacenv)) + "'~});").
				
      END.

  END.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Descartar w-html 
PROCEDURE Descartar :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
/* Descarta as sugestões que não foram utilizadas */

/* Todas as sugestões que já foram associadas a algum evento */
FOR EACH crapsdp WHERE crapsdp.idevento = INT(ab_unmap.aux_idevento) AND
                       crapsdp.cdcooper = INT(ab_unmap.aux_cdcooper) AND
                       crapsdp.cdevento <> 0                         EXCLUSIVE-LOCK:

    /* Busca o evento da cooperativa associado a sugestão */
    FIND crapedp WHERE crapedp.idevento = crapsdp.idevento           AND
                       crapedp.cdcooper = crapsdp.cdcooper           AND
                       crapedp.dtanoage = INT(ab_unmap.aux_dtanoage) AND
                       crapedp.cdevento = crapsdp.cdevento           AND
                       (crapedp.tpevento = 7                         OR
                        crapedp.tpevento <> 12) NO-LOCK NO-ERROR.

    /* Se o evento não foi escolhido */
    IF  NOT AVAILABLE crapedp  THEN
        DO:
            /* Busca o evento "genérico" para ver se é evento de integração */
            FIND crapedp WHERE crapedp.idevento = crapsdp.idevento   AND
                               crapedp.cdcooper = 0                  AND
                               crapedp.dtanoage = 0                  AND
                               crapedp.cdevento = crapsdp.cdevento   AND
															 (crapedp.tpevento = 7                 OR                
                              	crapedp.tpevento = 12) NO-LOCK NO-ERROR.

            /* Se não for integração, a sugestão é descartada */
            IF  AVAILABLE crapedp      AND 
                crapedp.tpevento <> 2  THEN
                ASSIGN crapsdp.flgsugca = YES.
        END.
        
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE envia-email w-html 
PROCEDURE envia-email:
  DEFINE INPUT PARAMETER par_cdagenci AS INTEGER NO-UNDO.

  DEF VAR h-b1wgen0011 AS HANDLE NO-UNDO.
  DEF VAR aux_dsdemail AS CHAR NO-UNDO.
  DEF VAR aux_dsconteu AS CHAR NO-UNDO.
  DEF VAR aux_dscritic AS CHAR NO-UNDO.
            
  FOR FIRST crapppc FIELDS(dsemlade) WHERE crapppc.cdcooper = INTEGER(ab_unmap.aux_cdcooper)
                                       AND crapppc.dtanoage = INTEGER(ab_unmap.aux_dtanoage) NO-LOCK. END.
                     
  IF AVAILABLE crapppc AND crapppc.dsemlade <> ? THEN
    DO:
      IF aux_dsdemail <> ? THEN
        DO:
          aux_dsdemail = aux_dsdemail + ";" + crapppc.dsemlade.
        END.
      ELSE
        DO:
          aux_dsdemail = crapppc.dsemlade.
        END.
    END.                
  ELSE
    DO:
      ASSIGN msg-erro = "Email nao cadastrado para a cooperativa informada."  
             msg-erro-aux = 3.
      RETURN "NOK".
    END.
    
  ASSIGN aux_dsdemail = REPLACE(aux_dsdemail,";",",")
         aux_dsconteu = "Prezado(a)," + 
							"\n\nChegou o momento de definir a agenda de realização dos eventos AGO/AGE." +
							"\nFaça a seleção dos eventos para sua Cooperativa acessando o Sistema de Gestão de Eventos em: ASSEMBLEIAS > Processos > Seleção Eventos - AGO/AGE." +
							"\nLembre-se de considerar as necessidades da cooperativa e dos cooperados ao escolher os eventos." +
							"\n\nAtenção: Solicitamos que a escolha das datas sejam feitas com cautela para evitarmos retrabalhos.".

  IF aux_dsdemail <> ? THEN
    DO:          
      RUN sistema/generico/procedures/b1wgen0011.p PERSISTENT SET h-b1wgen0011.

      IF VALID-HANDLE (h-b1wgen0011) THEN
        DO:
          RUN solicita_email_oracle IN h-b1wgen0011(INPUT  INTEGER(ab_unmap.aux_cdcooper)             							/* par_cdcooper        */
                                                   ,INPUT  "wpgd0053"                                 							/* par_cdprogra        */
                                                   ,INPUT  aux_dsdemail                               							/* par_des_destino     */
                                                   ,INPUT  "ASSEMBLEIA – DEFINA A NOVA AGENDA DOS EVENTOS AGO/AGE" /* par_des_assunto     */
                                                   ,INPUT  aux_dsconteu                               							/* par_des_corpo       */
                                                   ,INPUT  ""                                         							/* par_des_anexo       */
                                                   ,INPUT  "N"                                    									/* par_flg_remove_anex */
                                                   ,INPUT  "N"                                    									/* par_flg_remete_coop */
                                                   ,INPUT  "Sistema de Relacionamento"            									/* par_des_nome_reply  */
                                                   ,INPUT  "gc.oqs@cecred.coop.br"                									/* par_des_email_reply */
                                                   ,INPUT  "N"                                    									/* par_flg_log_batch   */
                                                   ,INPUT  "N"                                    									/* par_flg_enviar      */
                                                   ,OUTPUT aux_dscritic).                         									/* par_des_erro        */
                                   
          DELETE PROCEDURE h-b1wgen0011.
        END.
    END.

  RETURN "OK".
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE EnviaPac w-html 
PROCEDURE EnviaPac:

  /* Instancia a BO para executar as procedures */
  RUN dbo/b1wpgd0014.p PERSISTENT SET h-b1wpgd0014.

  /* Se BO foi instanciada */
  IF VALID-HANDLE(h-b1wpgd0014)   THEN
    DO:
        
      FOR EACH crapagp WHERE crapagp.idevento  = INTEGER(ab_unmap.aux_idevento)
                         AND crapagp.cdcooper  = INTEGER(ab_unmap.aux_cdcooper)
                         AND crapagp.dtanoage  = INTEGER(ab_unmap.aux_dtanoage)
                         AND crapagp.cdagenci  = 0 NO-LOCK
                         BREAK BY crapagp.cdageagr:
   
        IF FIRST-OF(crapagp.cdageagr) THEN
          DO:
            
            RUN envia-email(INPUT crapagp.cdageagr).
          
            IF RETURN-VALUE <> "OK" THEN
              DO:
                ASSIGN msg-erro-aux = 3.
              END.
                        
            RUN incrementa-status IN h-b1wpgd0014(INPUT ROWID(crapagp), OUTPUT msg-erro).
            
          END.
        
      END.
        
      /* "mata" a instância da BO */
      DELETE PROCEDURE h-b1wpgd0014 NO-ERROR.
   
    END. /* IF VALID-HANDLE(h-b1wpgd14) */
     
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ExcluiEvento w-html 
PROCEDURE ExcluiEvento :

  /* Instancia a BO para executar as procedures */
  RUN dbo/b1wpgd0014a.p PERSISTENT SET h-b1wpgd0014a.
 
  /* Se BO foi instanciada */
  IF   VALID-HANDLE(h-b1wpgd0014a)   THEN
       DO:
          FIND crapedp WHERE crapedp.cdcooper = INTEGER(ab_unmap.aux_cdcooper)  AND
                             crapedp.cdevento = INTEGER(ab_unmap.aux_cdevento)  AND
                             crapedp.idevento = INTEGER(ab_unmap.aux_idevento)  AND
                             crapedp.dtanoage = INTEGER(ab_unmap.aux_dtanoage)  AND
															 (crapedp.tpevento = 7                                 
														OR	crapedp.tpevento = 12) NO-LOCK NO-ERROR.
      
          CREATE cratedp.
          BUFFER-COPY crapedp TO cratedp.
              
          RUN exclui-registro IN h-b1wpgd0014a(INPUT TABLE cratedp, OUTPUT msg-erro).
      
          /* "mata" a instância da BO */
          DELETE PROCEDURE h-b1wpgd0014a NO-ERROR.
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
    ("aux_lspermis":U,"ab_unmap.aux_lspermis":U,ab_unmap.aux_lspermis:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nmpagina":U,"ab_unmap.aux_nmpagina":U,ab_unmap.aux_nmpagina:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nmrescop":U,"ab_unmap.aux_nmrescop":U,ab_unmap.aux_nmrescop:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_stdopcao":U,"ab_unmap.aux_stdopcao":U,ab_unmap.aux_stdopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("glb_cdcooper":U,"ab_unmap.glb_cdcooper":U,ab_unmap.glb_cdcooper:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdcopope":U,"ab_unmap.aux_cdcopope":U,ab_unmap.aux_cdcopope:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdoperad":U,"ab_unmap.aux_cdoperad":U,ab_unmap.aux_cdoperad:HANDLE IN FRAME {&FRAME-NAME}).
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
PROCEDURE outputHeader:
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
         ab_unmap.aux_nmpagina = GET-VALUE("aux_nmpagina")
         ab_unmap.aux_stdopcao = GET-VALUE("aux_stdopcao")
         ab_unmap.aux_cdevento = GET-VALUE("aux_cdevento")
         ab_unmap.aux_cdagenci = GET-VALUE("aux_cdagenci")
         ab_unmap.aux_nmrescop = GET-VALUE("aux_nmrescop")      
         /* COOPERATIVA do Usuário */
         ab_unmap.glb_cdcooper = GET-VALUE("glb_cdcooper")
         /* COOPERATIVA que está sendo trabalhada */
         ab_unmap.aux_cdcooper = GET-VALUE("aux_cdcooper")
         ab_unmap.aux_dtanoage = GET-VALUE("aux_dtanoage")
         ab_unmap.aux_cdcopope = GET-VALUE("aux_cdcopope")
         ab_unmap.aux_cdoperad = GET-VALUE("aux_cdoperad").

  RUN outputHeader.

  /* Se a cooperativa ainda não foi escolhida, pega a da sessão do usuário */
  IF   INT(ab_unmap.aux_cdcooper) = 0   THEN
       ab_unmap.aux_cdcooper = STRING(gnapses.cdcooper).

  FIND LAST gnpapgd WHERE gnpapgd.idevento = INT(ab_unmap.aux_idevento) AND 
                          gnpapgd.cdcooper = INT(ab_unmap.aux_nmrescop) AND 
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
             WHEN "exe" THEN /* exclui o evento da cooperativa */
                  DO:
                     RUN ExcluiEvento.  
                      
                     IF   msg-erro = ""   THEN
                          ASSIGN msg-erro-aux = 10. /* Solicitação realizada com sucesso */ 
                     ELSE
                          ASSIGN msg-erro-aux = 3. /* erros da validação de dados */
                  END.
             WHEN "env" THEN
                  DO:
                     RUN EnviaPAC.
                      
                     IF   msg-erro = ""   THEN
                          ASSIGN msg-erro-aux = 10. /* Solicitação realizada com sucesso */ 
                     ELSE
                          ASSIGN msg-erro-aux = 3. /* erros da validação de dados */
                  END.

             WHEN "des" THEN
                  DO:
                     RUN Descartar.

                     IF   msg-erro = ""   THEN
                          ASSIGN msg-erro-aux = 10. /* Solicitação realizada com sucesso */ 
                     ELSE
                          ASSIGN msg-erro-aux = 3. /* erros da validação de dados */
                  END.

        END CASE.
        RUN CriaListaCooperativa.
        RUN CriaListaEventos.
        
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
                  RUN RodaJavaScript('alert("Atualização executada com sucesso.")').
           
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
                      RUN CriaListaCooperativa.
                      RUN CriaListaEventos.
                      RUN displayFields.
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