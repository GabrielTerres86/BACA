/* .............................................................................

  Programa: cronfigura.w

Alteracoes: 15/12/2008 - Ajustes para unificacao dos bancos de dados (Evandro).

            26/06/2009 - Validar se o caixa existe conforme b1crap07 (Evandro).
            
            25/01/2018 - Removido campos de Supervisor e Senha. (PRJ339 - Reinert)
............................................................................. */


&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD vh_erro AS CHARACTER FORMAT "X(256)":U 
       FIELD v_agencia AS CHARACTER FORMAT "X(256)":U 
       FIELD v_caixa AS CHARACTER FORMAT "X(256)":U 
       FIELD v_cooperativa AS CHARACTER FORMAT "X(256)":U .

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

DEFINE VARIABLE h-b1crap00 AS HANDLE     NO-UNDO.
DEFINE VARIABLE h-b1crap01 AS HANDLE     NO-UNDO.
DEFINE VARIABLE l-ok       AS LOGICAL    NO-UNDO.



/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE F:/web/configura.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS ab_unmap.vh_erro ab_unmap.v_agencia ab_unmap.v_caixa ab_unmap.v_cooperativa
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.vh_erro ab_unmap.v_agencia ab_unmap.v_caixa ab_unmap.v_cooperativa

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     ab_unmap.vh_erro AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_agencia AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_caixa AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_cooperativa AT ROW 1 COL 1 HELP
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
          FIELD vh_erro AS CHARACTER FORMAT "X(256)":U 
          FIELD v_agencia AS CHARACTER FORMAT "X(256)":U 
          FIELD v_caixa AS CHARACTER FORMAT "X(256)":U 
          FIELD v_cooperativa AS CHARACTER FORMAT "X(256)":U  
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW w-html ASSIGN
         HEIGHT             = 14.14
         WIDTH              = 60.6.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB w-html 
/* *********************** Included-Libraries ************************* */

{src/web2/html-map.i}
{dbo/bo-erro1.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w-html
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME Web-Frame
   UNDERLINE                                                            */
/* SETTINGS FOR fill-in ab_unmap.vh_erro IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_agencia IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_caixa IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_cooperativa IN FRAME Web-Frame
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
    ("vh_erro":U,"ab_unmap.vh_erro":U,ab_unmap.vh_erro:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_agencia":U,"ab_unmap.v_agencia":U,ab_unmap.v_agencia:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_caixa":U,"ab_unmap.v_caixa":U,ab_unmap.v_caixa:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_cooperativa":U,"ab_unmap.v_cooperativa":U,ab_unmap.v_cooperativa:HANDLE IN FRAME {&FRAME-NAME}).
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE process-web-request w-html 
PROCEDURE process-web-request :
/*------------------------------------------------------------------------
  Purpose:     Process the web request.
  Notes:       
------------------------------------------------------------------------*/
     
  /* STEP 0 -
   * Output the MIME header and set up the object as state-less or state-aware. 
   * This is required if any HTML is to be returned to the browser. 
   *
   * NOTE: Move 'RUN outputHeader.' to the GET section below if you are going
   * to simulate another Web request by running a Web Object from this
   * procedure.  Running outputHeader precludes setting any additional cookie
   * information.
   */ 

  ASSIGN l-ok = YES.

  FIND crapcop WHERE crapcop.cdcooper = INT(GET-VALUE("aux_cdcooper")) 
                     NO-LOCK NO-ERROR.
					 
  FIND crapdat WHERE crapdat.cdcooper = INT(GET-VALUE("aux_cdcooper")) 
                     NO-LOCK NO-ERROR.					 
					 
  IF   NOT AVAILABLE crapcop   OR
       NOT AVAILABLE crapdat   THEN
       LEAVE.
  ELSE
       DO:
           ab_unmap.v_cooperativa = crapcop.nmrescop.


           /* Grava o cookie da cooperativa no inicio para poder buscar os erros
              mesmo que o login nao seja com sucesso */
           RUN SetCookie IN web-utilities-hdl 
               ("User_coop":U, crapcop.nmrescop, DATE("31/12/9999"), TIME, ?, ?, ?).                           
       END.
    
  IF  REQUEST_METHOD = "POST":U THEN DO:

      IF  NOT VALID-HANDLE(h-b1crap00) THEN
          RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.

      RUN valida-agencia IN h-b1crap00(INPUT crapcop.nmrescop,
                                       INPUT get-value("v_agencia"),
                                       INPUT get-value("v_caixa")).

      IF  RETURN-VALUE = "NOK" THEN DO:
          ASSIGN l-ok = NO.
      END.
      ELSE DO:
          /* Valida se o caixa foi preenchido */
          IF   INT(get-value("v_caixa")) = 0   THEN
               DO:
                   l-ok = NO.

                   RUN cria-erro (INPUT crapcop.nmrescop,
                                  INPUT get-value("v_agencia"),
                                  INPUT get-value("v_caixa"),
                                  INPUT 0,
                                  INPUT "O caixa deve ser informado",
                                  INPUT YES).
               
               END.
          ELSE 
               DO:          
                   /* validacao se o caixa existe (igual a b1crap07.p) so nao valida o saldo */
                   FIND LAST crapbcx WHERE crapbcx.cdcooper = crapcop.cdcooper              AND
                                           crapbcx.dtmvtolt = crapdat.dtmvtolt              AND
                                           crapbcx.cdagenci = int(get-value("v_agencia"))   AND
                                           crapbcx.nrdcaixa = int(get-value("v_caixa"))
                                           USE-INDEX crapbcx1 NO-LOCK NO-ERROR.				   
										   
                   /* verifica se foi aberto alguma vez */
				   IF  NOT AVAIL crapbcx THEN
                       FIND FIRST crapbcx WHERE crapbcx.cdcooper = crapcop.cdcooper              AND
                                                crapbcx.cdagenci = int(get-value("v_agencia"))   AND
                                                crapbcx.nrdcaixa = int(get-value("v_caixa"))     AND
                                                crapbcx.dtmvtolt < crapdat.dtmvtolt
                                                USE-INDEX crapbcx5 NO-LOCK NO-ERROR.										   
				   
				   IF  NOT AVAIL crapbcx THEN DO:
                       l-ok = NO.

                       RUN cria-erro (INPUT crapcop.nmrescop,
                                      INPUT get-value("v_agencia"),
                                      INPUT get-value("v_caixa"),
                                      INPUT 701,
                                      INPUT "",
                                      INPUT YES).
                   END.
                   ELSE DO:
					   RUN valida-transacao IN h-b1crap00(INPUT crapcop.nmrescop,
														  INPUT get-value("v_agencia"),
														  INPUT get-value("v_caixa")).

					   IF get-value("cancela") <> "" THEN DO:
						  l-ok = NO.
					   END.
					   ELSE DO:
						   IF  RETURN-VALUE = "NOK" THEN DO:
							   ASSIGN l-ok = NO.
						   END.
						   ELSE   DO:
                            
                 RUN SetCookie IN
                  web-utilities-hdl ("User_cx":U,
                           get-value("v_caixa"),
                           DATE("31/12/9999"), TIME, ?, ?, ?).   
  
  
                 RUN SetCookie IN
                  web-utilities-hdl ("User_pac":U,
                           get-value("v_agencia"), 
                           DATE("31/12/9999"), TIME, ?, ?, ?).    
						   END.
						END.
					END.
           END.
      END.
      DELETE PROCEDURE h-b1crap00.
      
  END.

  RUN outputHeader.
  
  /* Describe whether to receive FORM input for all the fields.  For example,
   * check particular input fields (using GetField in web-utilities-hdl). 
   * Here we look at REQUEST_METHOD. 
   */
  IF REQUEST_METHOD = "POST":U THEN DO:
    /* STEP 1 -
     * Copy HTML input field values to the Progress form buffer. */
    RUN inputFields.
    
    /* STEP 2 -
     * Open the database or SDO query and and fetch the first record. */ 
    RUN findRecords.
    
    /* STEP 3 -    
     * AssignFields will save the data in the frame.
     * (it automatically upgrades the lock to exclusive while doing the update)
     * 
     *  If a new record needs to be created set AddMode to true before 
        running assignFields.  
     *     setAddMode(TRUE).   
     * RUN assignFields. */

    RUN assignFields.

    /* STEP 4 -
     * Decide what HTML to return to the user. Choose STEP 4.1 to simulate
     * another Web request -OR- STEP 4.2 to return the original form (the
     * default action).
     *
     * STEP 4.1 -
     * To simulate another Web request, change the REQUEST_METHOD to GET
     * and RUN the Web object here.  For example,
     *
     *  ASSIGN REQUEST_METHOD = "GET":U.
     *  RUN run-web-object IN web-utilities-hdl ("myobject.w":U).
     */
     
    /* STEP 4.2 -
     * To return the form again, set data values, display them, and output 
     * them to the WEB stream.  
     *
     * STEP 4.2a -
     * Set any values that need to be set, then display them. */

    IF get-value("cancela") <> "" THEN
       ASSIGN ab_unmap.v_agencia     = ""
              ab_unmap.v_caixa       = "".
    ELSE
    IF INT(get-value("v_agencia")) <> 0 AND l-ok THEN
       {&out} "<script>location='crap001.p'</script>".
    ELSE DO:
        vh_erro = "0".
        FIND FIRST craperr NO-LOCK  where
                   craperr.cdcooper = crapcop.cdcooper              AND
                   craperr.cdagenci = int(get-value("v_agencia"))   and
                   craperr.nrdcaixa = int(get-value("v_caixa")) no-error.

        IF   AVAILABLE craperr   THEN
             vh_erro = "1".
    END.


    
    RUN displayFields.
   
    /* STEP 4.2b -
     * Enable objects that should be enabled. */
    RUN enableFields.

    /* STEP 4.2c -
     * OUTPUT the Progress form buffer to the WEB stream. */
    RUN outputFields.
    
  END. /* Form has been submitted. */
 
  /* REQUEST-METHOD = GET */ 
  ELSE DO:
    /* This is the first time that the form has been called. Just return the
     * form.  Move 'RUN outputHeader.' here if you are going to simulate
     * another Web request. */ 
   
    /* STEP 1 -
     * Open the database or SDO query and and fetch the first record. */ 
    RUN findRecords.
    
    /* Return the form again. Set data values, display them, and output them
     * to the WEB stream.  
     *
     * STEP 2a -
     * Set any values that need to be set, then display them. */
    
      /*--- Eliminar Erros Pendentes  --*/
      FOR EACH craperr WHERE
          craperr.cdcooper = crapcop.cdcooper AND
          craperr.cdagenci = int(v_agencia) AND
          craperr.nrdcaixa = int(v_caixa):
          DELETE craperr.
      END.     
      /*-------------------------------*/

    
    
    
    RUN displayFields.

    /* STEP 2b -
     * Enable objects that should be enabled. */
    RUN enableFields.

    /* STEP 2c -
     * OUTPUT the Progress from buffer to the WEB stream. */
    RUN outputFields.
  END. 
  
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

