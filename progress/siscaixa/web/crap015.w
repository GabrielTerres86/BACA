&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD radio       AS CHARACTER 
       FIELD vh_foco     AS CHARACTER FORMAT "X(256)":U 
       FIELD v_caixa     AS CHARACTER FORMAT "X(256)":U 
       FIELD v_codbarras AS CHARACTER FORMAT "X(256)":U 
       FIELD v_coop      AS CHARACTER FORMAT "X(256)":U 
       FIELD v_data      AS CHARACTER FORMAT "X(256)":U 
       FIELD v_msg       AS CHARACTER FORMAT "X(256)":U 
       FIELD v_operador  AS CHARACTER FORMAT "X(256)":U 
       FIELD v_pac       AS CHARACTER FORMAT "X(256)":U
       FIELD v_fmtcodbar AS CHARACTER FORMAT "X(256)":U
       FIELD v_tipdocto  AS CHARACTER FORMAT "X(256)":U
       FIELD v_tpproces  AS CHARACTER FORMAT "X(256)":U.


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
DEFINE VARIABLE h_b1crap15 AS HANDLE     NO-UNDO.
DEFINE VARIABLE h_b2crap15 AS HANDLE     NO-UNDO.

/***********************************************************************
 * GLOBAIS carregadas dentro de i-global.i que eh chamado dentro de    *
 * process-web-request                                                 *
 ***********************************************************************/
DEFINE VARIABLE glb_cdcooper LIKE crapcop.cdcooper              NO-UNDO.
DEFINE VARIABLE glb_nmrescop LIKE crapcop.nmrescop              NO-UNDO.
DEFINE VARIABLE glb_dtmvtolt LIKE crapdat.dtmvtolt              NO-UNDO.
DEFINE VARIABLE glb_dtmvtopr LIKE crapdat.dtmvtopr              NO-UNDO.
DEFINE VARIABLE glb_dtmvtoan LIKE crapdat.dtmvtoan              NO-UNDO.
DEFINE VARIABLE glb_cdagenci LIKE crapass.cdagenci              NO-UNDO.
DEFINE VARIABLE glb_cdbccxlt LIKE craptit.cdbccxlt              NO-UNDO.
DEFINE VARIABLE glb_cdoperad LIKE crapope.cdoperad              NO-UNDO.


DEFINE VARIABLE p_valor     AS DECIMAL    NO-UNDO.
DEFINE VARIABLE p_valordoc  AS DECIMAL    NO-UNDO.
DEFINE VARIABLE p_sequencia AS DECIMAL    NO-UNDO.
DEFINE VARIABLE p_digito    AS INTEGER    NO-UNDO.
DEFINE VARIABLE p_iptu      AS LOGICAL    NO-UNDO.
DEFINE VARIABLE c_codbarras AS CHARACTER  NO-UNDO.
DEFINE VARIABLE p_cdctrbxo  AS CHARACTER  NO-UNDO.

DEFINE VARIABLE de_tit1     AS DECIMAL    NO-UNDO.
DEFINE VARIABLE de_tit2     AS DECIMAL    NO-UNDO.
DEFINE VARIABLE de_tit3     AS DECIMAL    NO-UNDO.
DEFINE VARIABLE de_tit4     AS DECIMAL    NO-UNDO.
DEFINE VARIABLE de_tit5     AS DECIMAL    NO-UNDO.


DEFINE VARIABLE de_fat1     AS DECIMAL    NO-UNDO.
DEFINE VARIABLE de_fat2     AS DECIMAL    NO-UNDO.
DEFINE VARIABLE de_fat3     AS DECIMAL    NO-UNDO.
DEFINE VARIABLE de_fat4     AS DECIMAL    NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE crap015.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS ab_unmap.radio ab_unmap.vh_foco ab_unmap.v_caixa ab_unmap.v_codbarras ab_unmap.v_coop ab_unmap.v_data ab_unmap.v_msg ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_fmtcodbar ab_unmap.v_tipdocto ab_unmap.v_tpproces
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.radio ab_unmap.vh_foco ab_unmap.v_caixa ab_unmap.v_codbarras ab_unmap.v_coop ab_unmap.v_data ab_unmap.v_msg ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_fmtcodbar ab_unmap.v_tipdocto ab_unmap.v_tpproces

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     ab_unmap.radio AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS 
                    "radio 1", "1":U,
                    "radio 2", "2":U,
                    "radio 3", "3":U
          SIZE 20 BY 4
     ab_unmap.v_fmtcodbar AT ROW 1 COL 1 HELP
        "" NO-LABEL FORMAT "X(256)":U
        VIEW-AS FILL-IN
        SIZE 20 BY 1
     ab_unmap.vh_foco AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_caixa AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_codbarras AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_coop AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_data AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_msg AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_operador AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_pac AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_tipdocto AT ROW 1 COL 1 HELP
         "" NO-LABEL FORMAT "X(256)":U
         VIEW-AS FILL-IN
         SIZE 20 BY 1
    ab_unmap.v_tpproces AT ROW 1 COL 1 HELP
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
          FIELD radio AS CHARACTER 
          FIELD vh_foco AS CHARACTER FORMAT "X(256)":U 
          FIELD v_caixa AS CHARACTER FORMAT "X(256)":U 
          FIELD v_codbarras AS CHARACTER FORMAT "X(256)":U 
          FIELD v_coop AS CHARACTER FORMAT "X(256)":U 
          FIELD v_data AS CHARACTER FORMAT "X(256)":U 
          FIELD v_msg AS CHARACTER FORMAT "X(256)":U 
          FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
          FIELD v_pac AS CHARACTER FORMAT "X(256)":U 
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
/* SETTINGS FOR RADIO-SET ab_unmap.radio IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN ab_unmap.vh_foco IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_caixa IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_codbarras IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_coop IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_data IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_msg IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_operador IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_pac IN FRAME Web-Frame
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
    ("radio":U,"ab_unmap.radio":U,ab_unmap.radio:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("vh_foco":U,"ab_unmap.vh_foco":U,ab_unmap.vh_foco:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_caixa":U,"ab_unmap.v_caixa":U,ab_unmap.v_caixa:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_codbarras":U,"ab_unmap.v_codbarras":U,ab_unmap.v_codbarras:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_coop":U,"ab_unmap.v_coop":U,ab_unmap.v_coop:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_data":U,"ab_unmap.v_data":U,ab_unmap.v_data:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_msg":U,"ab_unmap.v_msg":U,ab_unmap.v_msg:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_operador":U,"ab_unmap.v_operador":U,ab_unmap.v_operador:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_pac":U,"ab_unmap.v_pac":U,ab_unmap.v_pac:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_fmtcodbar":U,"ab_unmap.v_fmtcodbar":U,ab_unmap.v_fmtcodbar:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_tipdocto":U,"ab_unmap.v_tipdocto":U,ab_unmap.v_tipdocto:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_tpproces":U,"ab_unmap.v_tpproces":U,ab_unmap.v_tpproces:HANDLE IN FRAME {&FRAME-NAME}).
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
     
    DEFINE VARIABLE deVlpago AS DECIMAL    NO-UNDO.
     
  /* STEP 0 -
   * Output the MIME header and set up the object as state-less or state-aware. 
   * This is required if any HTML is to be returned to the browser. 
   *
   * NOTE: Move 'RUN outputHeader.' to the GET section below if you are going
   * to simulate another Web request by running a Web Object from this
   * procedure.  Running outputHeader precludes setting any additional cookie
   * information.
   */ 
  RUN outputHeader.
  {include/i-global.i}
  ASSIGN glb_cdcooper = crapcop.cdcooper
         glb_nmrescop = crapcop.nmrescop
         glb_dtmvtolt = crapdat.dtmvtolt
         glb_dtmvtopr = crapdat.dtmvtopr
         glb_dtmvtoan = crapdat.dtmvtoan
         glb_cdagenci = INTE(get-value("user_pac"))
         glb_cdbccxlt = INTE(get-value("user_cx"))
         glb_cdoperad = get-value("operador").
  
  ASSIGN vh_foco = "7". 

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
     * RUN assignFields. */

    {include/assignfields.i}

    RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
    RUN valida-transacao IN h-b1crap00(INPUT v_coop,
                                       INPUT int(v_pac),
                                       INPUT int(v_caixa)).
    DELETE PROCEDURE h-b1crap00.

    IF RETURN-VALUE = "NOK" THEN DO:
        {include/i-erro.i}
    END.
    ELSE  DO:

        RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
        RUN verifica-abertura-boletim IN h-b1crap00(INPUT v_coop,
                                                    INPUT int(v_pac),
                                                    INPUT int(v_caixa),
                                                    INPUT v_operador).
   
        DELETE PROCEDURE h-b1crap00.

        IF RETURN-VALUE = "NOK" THEN DO:
           {include/i-erro.i}
        END.
        ELSE DO:
                 
            IF  get-value("v_tpproces") = "2" THEN /*Processo manual*/
                DO:
                    IF  get-value("v_tipdocto") = "1" THEN /*Titulo*/
                        DO:

                            ASSIGN de_tit1     = 0
                                   de_tit2     = 0
                                   de_tit3     = 0
                                   de_tit4     = 0
                                   de_tit5     = 0
                                   c_codbarras = get-value("v_codbarras").

                            ASSIGN de_tit1 = DEC( SUBSTR(c_codbarras,1,10)  )
                                   de_tit2 = DEC( SUBSTR(c_codbarras,11,11) )
                                   de_tit3 = DEC( SUBSTR(c_codbarras,22,11) ) 
                                   de_tit4 = DEC( SUBSTR(c_codbarras,33,1)  ) 
                                   de_tit5 = DEC( SUBSTR(c_codbarras,34,14) ).

                            RUN dbo/b2crap15.p PERSISTENT SET h_b2crap15.
                            RUN retorna-valores-titulo-iptu
                             IN h_b2crap15(INPUT v_coop,
                                           INPUT v_operador,
                                           INPUT int(v_pac),
                                           INPUT int(v_caixa),
                                           INPUT-OUTPUT de_tit1,
                                           INPUT-OUTPUT de_tit2,
                                           INPUT-OUTPUT de_tit3,
                                           INPUT-OUTPUT de_tit4,
                                           INPUT-OUTPUT de_tit5,
                                           INPUT-OUTPUT c_codbarras,
                                           INPUT NO,
                                           INPUT 0,
                                           INPUT 0,
                                           OUTPUT p_valor,
                                           OUTPUT p_valordoc,
                                           OUTPUT p_cdctrbxo).
                            IF VALID-HANDLE(h_b2crap15) THEN
                                DELETE PROCEDURE h_b2crap15.
                            IF RETURN-VALUE = "NOK" THEN
                            DO:
                                ASSIGN v_codbarras = "".
                                {include/i-erro.i}
                                ASSIGN vh_foco = "10".
                            END.
                            ELSE
                            DO:                 
                                {&OUT}
                                    '<script>window.location = "crap015b.html?v_pradio=" + "'get-value("radio")'" + 
                                     "&v_pvalordoc=" + "' p_valordoc '" + "&v_pvalor=" + "' p_valor '" + "&v_pbarras=" + "' c_codbarras '" +
                                     "&v_ptit1=" + "' de_tit1 '" + "&v_ptit2=" + "' de_tit2 '" + "&v_ptit3=" + "' de_tit3 '" +
                                     "&v_ptit4=" + "' de_tit4 '" + "&v_ptit5=" + "' de_tit5 '" + "&v_pcdctrbxo=" + "' p_cdctrbxo '"
                                    </script>'.   
                            END.                  
                           
                        END.
                    ELSE
                        DO:
                            IF  get-value("v_tipdocto") = "2" THEN /*Fatura*/
                                DO:
                                    ASSIGN c_codbarras = get-value("v_codbarras")
                                           de_fat1 = DEC(SUBSTR(c_codbarras,1,12))
                                           de_fat2 = DEC(SUBSTR(c_codbarras,13,12))
                                           de_fat3 = DEC(SUBSTR(c_codbarras,25,12))
                                           de_fat4 = DEC(SUBSTR(c_codbarras,37,12)).

                                    RUN dbo/b1crap15.p 
                                        PERSISTENT SET h_b1crap15.
                                    RUN retorna-valores-fatura
                                      IN h_b1crap15(INPUT v_coop,
                                                    INPUT v_operador,
                                                    INPUT INT(v_pac),
                                                    INPUT INT(v_caixa),
                                                    INPUT de_fat1,
                                                    INPUT de_fat2,
                                                    INPUT de_fat3,
                                                    INPUT de_fat4,
                                                    INPUT-OUTPUT c_codbarras,
                                                    OUTPUT p_sequencia,
                                                    OUTPUT p_valor,
                                                    OUTPUT p_valordoc,
                                                    OUTPUT p_digito,
                                                    OUTPUT p_iptu).
                                    DELETE PROCEDURE h_b1crap15.

                                    IF RETURN-VALUE = "NOK" THEN
                                    DO:
                                        {include/i-erro.i}
                                        ASSIGN v_codbarras = "".
                                        ASSIGN vh_foco = "10".
                                    END.
                                    ELSE
                                    DO:

                                        {&OUT}
                                            '<script>window.location = "crap015d.html?v_pradio=" + "2" + 
                                             "&v_pvalordoc=" + "' p_valordoc '" + "&v_pvalor=" + "' p_valor '" + "&v_pbarras=" + "'get-value("v_codbarras")'" + 
                                             "&v_psequencia=" + "' p_sequencia '" + "&v_pdigito=" + "' p_digito '"
                                            </script>'. 
                                    END.

                                END.
                        END.
                END.
            ELSE
                DO:
                    IF  get-value("v_tpproces") = "1" THEN /*Processo automatico*/
                        DO:
                            IF  get-value("v_tipdocto") = "1" THEN /*Titulo*/
                                DO:
                                    ASSIGN de_tit1     = 0
                                           de_tit2     = 0
                                           de_tit3     = 0
                                           de_tit4     = 0
                                           de_tit5     = 0
                                           c_codbarras = get-value("v_codbarras").


                                    RUN dbo/b2crap15.p PERSISTENT SET h_b2crap15.
                                    RUN retorna-valores-titulo-iptu
                                     IN h_b2crap15(INPUT v_coop,
                                                   INPUT v_operador,
                                                   INPUT int(v_pac),
                                                   INPUT int(v_caixa),
                                                   INPUT-OUTPUT de_tit1,
                                                   INPUT-OUTPUT de_tit2,
                                                   INPUT-OUTPUT de_tit3,
                                                   INPUT-OUTPUT de_tit4,
                                                   INPUT-OUTPUT de_tit5,
                                                   INPUT-OUTPUT c_codbarras,
                                                   INPUT NO,
                                                   INPUT 0,
                                                   INPUT 0,
                                                   OUTPUT p_valor,
                                                   OUTPUT p_valordoc,
                                                   OUTPUT p_cdctrbxo).
                                    IF VALID-HANDLE(h_b2crap15) THEN
                                        DELETE PROCEDURE h_b2crap15.
                                    IF RETURN-VALUE = "NOK" THEN
                                    DO:
                                        ASSIGN v_codbarras = "".
                                        {include/i-erro.i}
                                        ASSIGN vh_foco = "10".
                                    END.
                                    ELSE
                                    DO:                 
                                        {&OUT}
                                            '<script>window.location = "crap015b.html?v_pradio=" + "'get-value("radio")'" + 
                                             "&v_pvalordoc=" + "' p_valordoc '" + "&v_pvalor=" + "' p_valor '" + "&v_pbarras=" + "'get-value("v_codbarras")'" +
                                             "&v_ptit1=" + "' de_tit1 '" + "&v_ptit2=" + "' de_tit2 '" + "&v_ptit3=" + "' de_tit3 '" +
                                             "&v_ptit4=" + "' de_tit4 '" + "&v_ptit5=" + "' de_tit5 '" + "&v_pcdctrbxo=" + "' p_cdctrbxo '"
                                            </script>'.   
                                    END.                  
                                END.
                            ELSE
                                DO:
                                    IF  get-value("v_tipdocto") = "2" THEN /*Fatura*/
                                        DO:
                                            ASSIGN c_codbarras = get-value("v_codbarras").

                                            RUN dbo/b1crap15.p 
                                                PERSISTENT SET h_b1crap15.
                                            RUN retorna-valores-fatura
                                              IN h_b1crap15(INPUT v_coop,
                                                            INPUT v_operador,
                                                            INPUT INT(v_pac),
                                                            INPUT INT(v_caixa),
                                                            INPUT 0,
                                                            INPUT 0,
                                                            INPUT 0,
                                                            INPUT 0,
                                                            INPUT-OUTPUT c_codbarras,
                                                            OUTPUT p_sequencia,
                                                            OUTPUT p_valor,
                                                            OUTPUT p_valordoc,
                                                            OUTPUT p_digito,
                                                            OUTPUT p_iptu).
                                            DELETE PROCEDURE h_b1crap15.

                                            IF RETURN-VALUE = "NOK" THEN
                                            DO:
                                                {include/i-erro.i}
                                                ASSIGN v_codbarras = "".
                                                ASSIGN vh_foco = "10".
                                            END.
                                            ELSE
                                            DO:

                                                {&OUT}
                                                    '<script>window.location = "crap015d.html?v_pradio=" + "2" + 
                                                     "&v_pvalordoc=" + "' p_valordoc '" + "&v_pvalor=" + "' p_valor '" + "&v_pbarras=" + "'get-value("v_codbarras")'" + 
                                                     "&v_psequencia=" + "' p_sequencia '" + "&v_pdigito=" + "' p_digito '"
                                                    </script>'. 

                                            END.
                                        END.
                                END.
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

