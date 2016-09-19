/* .............................................................................

   Programa: siscaixa/web/crap001.w
   Sistema : Caixa On-line
   Sigla   : CRED   
   Autor   : Mirtes.
   Data    : Marco/2001                      Ultima atualizacao: 15/12/2008.

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Validacao Acesso Usuario ao Sistema

   Alteracoes: 09/08/2005 - Passar codigo da cooperativa como parametro para
                            as procedures (Julio)

               15/12/2008 - Alteracoes para unificacao dos bancos de dados,
                            leitura da crapcop de acordo com o cookie
                            (Evandro)

............................................................................ */

&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD v_agencia AS CHARACTER FORMAT "X(256)":U 
       FIELD v_caixa AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nome AS CHARACTER FORMAT "X(256)":U 
       FIELD v_senha AS CHARACTER FORMAT "X(256)":U .


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

DEFINE VARIABLE h-b1crap01  AS HANDLE     NO-UNDO.
DEFINE VARIABLE h-b1crap00  AS HANDLE     NO-UNDO.
DEFINE VARIABLE h-b2crap01  AS HANDLE     NO-UNDO.
DEFINE VARIABLE l-login     AS LOGICAL    NO-UNDO.
DEFINE VARIABLE p-autentica AS CHAR       NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE crap001.html

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS ab_unmap.v_agencia ab_unmap.v_caixa ab_unmap.v_nome ab_unmap.v_senha 
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.v_agencia ab_unmap.v_caixa ab_unmap.v_nome ab_unmap.v_senha 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     ab_unmap.v_agencia AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_caixa AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_nome AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_senha AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 60.6 BY 14.14.


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
          FIELD v_agencia AS CHARACTER FORMAT "X(256)":U 
          FIELD v_caixa AS CHARACTER FORMAT "X(256)":U 
          FIELD v_nome AS CHARACTER FORMAT "X(256)":U 
          FIELD v_senha AS CHARACTER FORMAT "X(256)":U 
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

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w-html
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME Web-Frame
   UNDERLINE                                                            */
/* SETTINGS FOR FILL-IN ab_unmap.v_agencia IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_caixa IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_nome IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_senha IN FRAME Web-Frame
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
    ("v_agencia":U,"ab_unmap.v_agencia":U,ab_unmap.v_agencia:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_caixa":U,"ab_unmap.v_caixa":U,ab_unmap.v_caixa:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nome":U,"ab_unmap.v_nome":U,ab_unmap.v_nome:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_senha":U,"ab_unmap.v_senha":U,ab_unmap.v_senha:HANDLE IN FRAME {&FRAME-NAME}).
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
   
  ASSIGN l-login  = YES. 

  FIND crapcop WHERE crapcop.nmrescop = get-value("user_coop")
                     NO-LOCK NO-ERROR.

  /* Forca uma saida caso nao encontre a cooperativa */
  IF   NOT AVAILABLE crapcop   THEN
       DO:
           RUN outputHeader.
           {&out} "<script>"
                  "parent.location='index.html';"
                  "</script>".
       END.

  /*--- Eliminar Erros Pendentes  --*/
  FOR EACH craperr WHERE
      craperr.cdcooper = crapcop.cdcooper           AND
      craperr.cdagenci = INT(get-value("user_pac")) AND
      craperr.nrdcaixa = INT(get-value("user_cx")):
      DELETE craperr.
  END.     

              
  /*-------------------------------*/
  IF REQUEST_METHOD = "POST":U THEN DO:
      IF get-value("cancela") <> "" THEN DO:
         ASSIGN ab_unmap.v_nome  = ""
                ab_unmap.v_senha = "".
      END.
      ELSE DO:
          RUN SetCookie IN web-utilities-hdl ("operador":U, 
                                              get-value("v_nome"),
                                              DATE("31/12/9999"), 
                                              TIME, ?, ?, ?).      

          RUN dbo/b1crap01.p PERSISTENT SET h-b1crap01.
          
          RUN valida-operador IN h-b1crap01 (INPUT crapcop.nmrescop,
                                             INPUT get-value("v_nome"),
                                             INPUT get-value("v_senha"),
                                             INPUT INT(get-value("user_pac")),
                                             INPUT INT(get-value("user_cx"))).
          DELETE PROCEDURE h-b1crap01.
          ASSIGN l-login = (RETURN-VALUE <> "NOK").

          IF  l-login THEN
              RUN SetCookie IN web-utilities-hdl ("user_log":U, STRING(l-login), DATE("31/12/9999"), TIME, ?, ?, ?).     

     END.
  END.
  
  RUN outputHeader.
  /*
  IF INT(get-value("user_pac")) = 0 OR INT(get-value("user_cx")) = 0 THEN
     {&out} "<script>window.location='configura.p'</script>".
  */

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
    /*RUN findRecords.*/
    
    /* STEP 3 -    
     * AssignFields will save the data in the frame.
     * (it automatically upgrades the lock to exclusive while doing the update)
     * 
     *  If a new record needs to be created set AddMode to true before 
        running assignFields.  
     *     setAddMode(TRUE).   
     * RUN assignFields. 
                         */
    RUN assignFields.    



    IF   l-login = NO THEN DO:

        FIND FIRST craperr NO-LOCK  where
                   craperr.cdcooper = crapcop.cdcooper             AND
                   craperr.cdagenci = INT(get-value("user_pac"))   and
                   craperr.nrdcaixa = INT(get-value("user_cx")) no-error.
        IF AVAIL craperr THEN DO:
            {&out} "<script>window.open('mensagem.p','werro','height=220,width=400,scrollbars=yes,alwaysRaised=true')</script>".

        END.
    END.
    ELSE  DO:

        /*--- Eliminar Erros Pendentes  --*/
        FOR EACH craperr WHERE
            craperr.cdcooper = crapcop.cdcooper           AND
            craperr.cdagenci = INT(get-value("user_pac")) AND
            craperr.nrdcaixa = INT(get-value("user_cx")):
            DELETE craperr.
        END.     


        RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.


        IF get-value("cancela") <> "" THEN DO:
           ASSIGN v_nome  = ""
                  v_senha = "".
        END.
        ELSE DO:

           
            RUN valida-transacao IN h-b1crap00(INPUT crapcop.nmrescop,
                                               INPUT INT(get-value("user_pac")),
                                               INPUT INT(get-value("user_cx"))).

            DELETE PROCEDURE h-b1crap00.
            IF RETURN-VALUE = "NOK" THEN  DO:
                FIND FIRST craperr NO-LOCK  where
                           craperr.cdcooper = crapcop.cdcooper             and
                           craperr.cdagenci = INT(get-value("user_pac"))   and
                           craperr.nrdcaixa = INT(get-value("user_cx")) no-error.
                IF AVAIL craperr THEN DO:
                    {&out} "<script>window.open('mensagem.p','werro','height=220,width=400,scrollbars=yes,alwaysRaised=true')</script>".

                END.
            END.
            ELSE DO:
                RUN dbo/b1crap01.p PERSISTENT SET h-b1crap01.
                RUN valida-caixa-aberto IN h-b1crap01 
                                           (INPUT crapcop.nmrescop,
                                            INPUT get-value("v_nome"),
                                            INPUT INT(get-value("user_pac")),
                                            INPUT INT(get-value("user_cx"))).
                DELETE PROCEDURE h-b1crap01.
                IF RETURN-VALUE = "NOK" THEN  DO:
                    FIND FIRST craperr NO-LOCK  where
                               craperr.cdcooper = crapcop.cdcooper             and
                               craperr.cdagenci = INT(get-value("user_pac"))   and
                               craperr.nrdcaixa = INT(get-value("user_cx")) no-error.
                    IF AVAIL craperr THEN DO:
                        {&out} "<script>window.open('mensagem.p','werro','height=220,width=400,scrollbars=yes,alwaysRaised=true')</script>".

                    END.
                END.
                ELSE DO:
                    RUN dbo/b2crap01.p PERSISTENT SET h-b2crap01.

                    RUN GetCookie IN web-utilities-hdl
                       ( INPUT "Autenticacao" ,
                         OUTPUT p-autentica).

                    /* Nao eliminar tabela de Erros = Advertencia ---*/
                    RUN  verifica-importacao IN h-b2crap01 
                                            (INPUT crapcop.nmrescop,
                                             INPUT INT(get-value("user_pac")),
                                             INPUT INT(get-value("user_cx")),
                                             INPUT INT(p-autentica)).

                    RUN verifica-compensacao IN h-b2crap01 
                                            (INPUT crapcop.nmrescop,
                                             INPUT INT(get-value("user_pac")),
                                             INPUT INT(get-value("user_cx"))).

                    DELETE PROCEDURE h-b2crap01.

                    FIND FIRST craperr NO-LOCK  where
                               craperr.cdcooper = crapcop.cdcooper            and
                               craperr.cdagenci = INT(get-value("user_pac"))  AND
                               craperr.nrdcaixa = INT(get-value("user_cx")) 
                               no-error.

                    IF AVAIL craperr THEN DO:
                        {&out} "<script>window.open('mensagem.p','werro',
                               'height=220,width=400,scrollbars=yes,
                                alwaysRaised=true')</script>".

                    END.

                    {&OUT}
                       '<script>location= "main.p" </script>'.
                       /*'<script>window.open("main.p","wsis","width=640,
                          height=420,scrollbars=auto,
                          alwaysRaised=true,resizable=true") </script>'.*/
                END.
            END.
        END.
    END.


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
     
     ASSIGN ab_unmap.v_agencia = get-value("user_pac").

     ASSIGN ab_unmap.v_caixa = get-value("user_cx").



    RUN displayFields.
   
    /* STEP 4.2b -
     * Enable objects that should be enabled. */

    RUN enableFields.
  
/*  DISABLE  v_agencia
             v_caixa
             v_nome
             v_senha
             WITH FRAME {&FRAME-NAME}.*/

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
   /*  RUN findRecords.*/
    
    /* Return the form again. Set data values, display them, and output them
     * to the WEB stream.  
     *
     * STEP 2a -
     * Set any values that need to be set, then display them. */
       
    
    

    IF  get-value("operador") <> "" THEN
        ASSIGN ab_unmap.v_nome = get-value("operador").
        ASSIGN ab_unmap.v_agencia = get-value("user_pac").
        ASSIGN ab_unmap.v_caixa = get-value("user_cx").


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

