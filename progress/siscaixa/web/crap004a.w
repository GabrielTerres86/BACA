&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD radio AS CHARACTER 
       FIELD vh_foco AS CHARACTER FORMAT "X(256)":U 
       FIELD v_caixa AS CHARACTER FORMAT "X(256)":U 
       FIELD v_cartao AS CHARACTER FORMAT "X(256)":U 
       FIELD v_confirmsenha AS CHARACTER FORMAT "X(256)":U 
       FIELD v_conta AS CHARACTER FORMAT "X(256)":U 
       FIELD v_coop AS CHARACTER FORMAT "X(256)":U 
       FIELD v_d AS CHARACTER FORMAT "X(256)":U 
       FIELD v_data AS CHARACTER FORMAT "X(256)":U 
       FIELD v_log AS CHARACTER FORMAT "X(256)":U 
       FIELD v_msg AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nomconj AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nome AS CHARACTER FORMAT "X(256)":U 
       FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
       FIELD v_pac AS CHARACTER FORMAT "X(256)":U 
       FIELD v_rowid AS CHARACTER FORMAT "X(256)":U 
       FIELD v_satual AS CHARACTER FORMAT "X(256)":U 
       FIELD v_sit AS CHARACTER FORMAT "X(256)":U 
       FIELD v_snova AS CHARACTER FORMAT "X(256)":U 
       FIELD v_tit AS CHARACTER FORMAT "X(256)":U .


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

DEFINE VARIABLE h-b1crap00    AS HANDLE     NO-UNDO.
DEFINE VARIABLE h-b2crap04    AS HANDLE     NO-UNDO.
DEFINE VARIABLE l-senha-atual AS LOGICAL    NO-UNDO.
DEFINE VARIABLE l-ok          AS LOGICAL    NO-UNDO.
DEFINE VARIABLE c-senha-atual AS CHARACTER  NO-UNDO.
DEF VAR c-conta     LIKE crapass.nrdconta.
DEF VAR v-log       AS CHAR.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE crap004a.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS ab_unmap.v_log ab_unmap.v_msg ab_unmap.vh_foco ab_unmap.v_d ab_unmap.v_rowid ab_unmap.v_nomconj ab_unmap.radio ab_unmap.v_caixa ab_unmap.v_cartao ab_unmap.v_confirmsenha ab_unmap.v_conta ab_unmap.v_coop ab_unmap.v_data ab_unmap.v_nome ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_satual ab_unmap.v_sit ab_unmap.v_snova ab_unmap.v_tit 
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.v_log ab_unmap.v_msg ab_unmap.vh_foco ab_unmap.v_d ab_unmap.v_rowid ab_unmap.v_nomconj ab_unmap.radio ab_unmap.v_caixa ab_unmap.v_cartao ab_unmap.v_confirmsenha ab_unmap.v_conta ab_unmap.v_coop ab_unmap.v_data ab_unmap.v_nome ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_satual ab_unmap.v_sit ab_unmap.v_snova ab_unmap.v_tit 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     ab_unmap.v_log AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_msg AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.vh_foco AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_d AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_rowid AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_nomconj AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.radio AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS 
                    "radio 1", "yes":U,
"radio 2", "no":U
          SIZE 20 BY 3
     ab_unmap.v_caixa AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_cartao AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_confirmsenha AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_conta AT ROW 1 COL 1 HELP
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
     ab_unmap.v_nome AT ROW 1 COL 1 HELP
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
     ab_unmap.v_satual AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_sit AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_snova AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_tit AT ROW 1 COL 1 HELP
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
          FIELD v_cartao AS CHARACTER FORMAT "X(256)":U 
          FIELD v_confirmsenha AS CHARACTER FORMAT "X(256)":U 
          FIELD v_conta AS CHARACTER FORMAT "X(256)":U 
          FIELD v_coop AS CHARACTER FORMAT "X(256)":U 
          FIELD v_d AS CHARACTER FORMAT "X(256)":U 
          FIELD v_data AS CHARACTER FORMAT "X(256)":U 
          FIELD v_log AS CHARACTER FORMAT "X(256)":U 
          FIELD v_msg AS CHARACTER FORMAT "X(256)":U 
          FIELD v_nomconj AS CHARACTER FORMAT "X(256)":U 
          FIELD v_nome AS CHARACTER FORMAT "X(256)":U 
          FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
          FIELD v_pac AS CHARACTER FORMAT "X(256)":U 
          FIELD v_rowid AS CHARACTER FORMAT "X(256)":U 
          FIELD v_satual AS CHARACTER FORMAT "X(256)":U 
          FIELD v_sit AS CHARACTER FORMAT "X(256)":U 
          FIELD v_snova AS CHARACTER FORMAT "X(256)":U 
          FIELD v_tit AS CHARACTER FORMAT "X(256)":U 
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
/* SETTINGS FOR FILL-IN ab_unmap.v_cartao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_confirmsenha IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_conta IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_coop IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_d IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_data IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_log IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_msg IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_nomconj IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_nome IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_operador IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_pac IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_rowid IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_satual IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_sit IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_snova IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_tit IN FRAME Web-Frame
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
    ("v_cartao":U,"ab_unmap.v_cartao":U,ab_unmap.v_cartao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_confirmsenha":U,"ab_unmap.v_confirmsenha":U,ab_unmap.v_confirmsenha:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_conta":U,"ab_unmap.v_conta":U,ab_unmap.v_conta:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_coop":U,"ab_unmap.v_coop":U,ab_unmap.v_coop:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_d":U,"ab_unmap.v_d":U,ab_unmap.v_d:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_data":U,"ab_unmap.v_data":U,ab_unmap.v_data:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_log":U,"ab_unmap.v_log":U,ab_unmap.v_log:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_msg":U,"ab_unmap.v_msg":U,ab_unmap.v_msg:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nomconj":U,"ab_unmap.v_nomconj":U,ab_unmap.v_nomconj:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nome":U,"ab_unmap.v_nome":U,ab_unmap.v_nome:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_operador":U,"ab_unmap.v_operador":U,ab_unmap.v_operador:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_pac":U,"ab_unmap.v_pac":U,ab_unmap.v_pac:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_rowid":U,"ab_unmap.v_rowid":U,ab_unmap.v_rowid:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_satual":U,"ab_unmap.v_satual":U,ab_unmap.v_satual:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_sit":U,"ab_unmap.v_sit":U,ab_unmap.v_sit:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_snova":U,"ab_unmap.v_snova":U,ab_unmap.v_snova:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_tit":U,"ab_unmap.v_tit":U,ab_unmap.v_tit:HANDLE IN FRAME {&FRAME-NAME}).
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
  RUN outputHeader.
  {include/i-global.i}

  /* Describe whether to receive FORM input for all the fields.  For example,
   * check particular input fields (using GetField in web-utilities-hdl). 
   * Here we look at REQUEST_METHOD. 
   */

  ASSIGN l-senha-atual  = NO
         c-senha-atual = "9999999".

  IF REQUEST_METHOD = "POST":U THEN DO:
    /* STEP 1 -
     * Copy HTML input field values to the Progress form buffer. */
    RUN inputFields.
    /* STEP 2 -
     * Open the database or SDO query and and fetch the first record. 
    RUN findRecords.                                                  */
    
    /* STEP 3 -    
     * AssignFields will save the data in the frame.
     * (it automatically upgrades the lock to exclusive while doing the update)
     * 
     *  If a new record needs to be created set AddMode to true before 
        running assignFields.  
     *     setAddMode(TRUE).   */

    {include/assignfields.i} /* Colocado a chamada do assignFields dentro da include */

    IF get-value("crap002") <> "" THEN DO:
        ASSIGN v-log   = "yes".      
        ASSIGN c-conta = int(get-value("v_ctaa")).
        {&OUT}
        '<script>window.location = "crap002.html?v_conta=" + "' c-conta '" + "&v_log=" + "' v-log '"</script>'.
        /*'<script> window.location = "crap002.html?v_cta=" + "'get-value("v_ctaa")'" + 
                                    "&v_log=" + "'get-value("v_log")'" </script>'.*/
    END.
    ELSE DO:
     RUN dbo/b2crap04.p PERSISTENT SET h-b2crap04.
     RUN busca-cartao IN h-b2crap04(INPUT v_coop,
                                    INPUT TO-ROWID(v_rowid),
                                    OUTPUT v_tit,
                                    OUTPUT v_cartao,
                                    OUTPUT v_sit,
                                    OUTPUT v_d).


     RUN verifica-senha-atual IN h-b2crap04(INPUT v_coop,
                                            INPUT TO-ROWID(v_rowid),
                                            OUTPUT l-senha-atual).
     DELETE PROCEDURE h-b2crap04.

     IF get-value("cancela") <> "" THEN DO:
        ASSIGN v_snova        = ""
               v_confirmsenha = ""
               vh_foco = "17".
        IF l-senha-atual THEN
            ASSIGN v_satual = ""
            vh_foco = "16".
     END.
     ELSE DO:
         RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
         RUN valida-transacao IN h-b1crap00(INPUT v_coop,
                                            INPUT int(v_pac),
                                            INPUT int(v_caixa)).
         DELETE PROCEDURE h-b1crap00.
    
         IF  RETURN-VALUE = "NOK" THEN DO:
             {include/i-erro.i}
         END.
         ELSE   DO:
             RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
             RUN verifica-abertura-boletim IN h-b1crap00(INPUT v_coop,
                                                         INPUT INT(v_pac),
                                                         INPUT INT(v_caixa),
                                                         INPUT v_operador).
             DELETE PROCEDURE h-b1crap00.

             IF  RETURN-VALUE = "NOK" THEN DO:
                 {include/i-erro.i}
             END.
             ELSE  DO:


                 ASSIGN l-ok = YES.

                 ASSIGN c-senha-atual = get-value("v_satual").

                 IF v_sit = "SOLICITADO" THEN
                 DO:
                     RUN dbo/b2crap04.p PERSISTENT SET h-b2crap04.
                     RUN grava-cartao IN h-b2crap04(INPUT v_coop,
                                                    INPUT INT(v_pac),
                                                    INPUT INT(v_caixa),
                                                    INPUT v_operador,
                                                    INPUT TO-ROWID(v_rowid),
                                                    INPUT l-senha-atual,
                                                    INPUT c-senha-atual,
                                                    INPUT get-value("v_snova"),
                                                    INPUT get-value("v_confirmsenha")).
                     DELETE PROCEDURE h-b2crap04.

                     IF RETURN-VALUE = "NOK" THEN
                     DO:
                         {include/i-erro.i}
                     END.
                     ELSE
                     DO:
                         {&out}
                         '<script> window.location = "crap004.html?v_cta=" + "'get-value("v_ctaa")'" + 
                           "&v_nom=" + "'get-value("v_noma")'" + "&v_nomconj=" + "'get-value("v_nomconja")'" </script>'.
                     END.
                 END.
                 ELSE
                 DO:
                     RUN dbo/b2crap04.p PERSISTENT SET h-b2crap04.
                     RUN grava-senha IN h-b2crap04(INPUT v_coop,
                                                   INPUT INT(v_pac),
                                                   INPUT INT(v_caixa),
                                                   INPUT v_operador,
                                                   INPUT TO-ROWID(v_rowid),
                                                   INPUT l-senha-atual,
                                                   INPUT c-senha-atual,
                                                   INPUT get-value("v_snova"),
                                                   INPUT get-value("v_confirmsenha")).
                     DELETE PROCEDURE h-b2crap04.

                     IF RETURN-VALUE = "NOK" THEN
                     DO:
                         {include/i-erro.i}

                     END.
                     ELSE
                     DO:
                         {&out}
                         '<script> window.location = "crap004.html?v_cta=" + "'get-value("v_ctaa")'" + 
                           "&v_nom=" + "'get-value("v_noma")'" + "&v_nomconj=" + "'get-value("v_nomconja")'" </script>'.
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


     ASSIGN v_rowid   = get-value("v_row").
     ASSIGN v_conta   = get-value("v_ctaa").
     ASSIGN v_nome    = get-value("v_noma").
     ASSIGN v_nomconj = get-value("v_nomconja").

     IF v_sit = "ENTREGUE" THEN
         ASSIGN radio = "NO".
     ELSE
         ASSIGN radio = "YES".

    RUN displayFields.
   
    /* STEP 4.2b -
     * Enable objects that should be enabled. */
    RUN enableFields.

    IF l-senha-atual THEN
        ENABLE v_satual WITH FRAME {&FRAME-NAME}.
    ELSE
        DISABLE v_satual WITH FRAME {&FRAME-NAME}.

    /* STEP 4.2c -
     * OUTPUT the Progress form buffer to the WEB stream. */
    RUN outputFields.


  END. /* Form has been submitted. */
 
  /* REQUEST-METHOD = GET */ 
  ELSE DO:

    ASSIGN v_rowid   = get-value("v_row").
    ASSIGN v_conta   = get-value("v_ctaa").
    ASSIGN v_nome    = get-value("v_noma").
    ASSIGN v_nomconj = get-value("v_nomconja").

    RUN dbo/b2crap04.p PERSISTENT SET h-b2crap04.
    RUN verifica-senha-atual IN h-b2crap04(INPUT v_coop,
                                           INPUT TO-ROWID(v_rowid),
                                           OUTPUT l-senha-atual).

    RUN busca-cartao IN h-b2crap04(INPUT v_coop,
                                   INPUT TO-ROWID(v_rowid),
                                   OUTPUT v_tit,
                                   OUTPUT v_cartao,
                                   OUTPUT v_sit,
                                   OUTPUT v_d).
    DELETE PROCEDURE h-b2crap04.


    IF v_sit = "ENTREGUE" THEN
        ASSIGN radio = "NO".
    ELSE
        ASSIGN radio = "YES".
   /* This is the first time that the form has been called. Just return the
     * form.  Move 'RUN outputHeader.' here if you are going to simulate
     * another Web request. */ 
   
    /* STEP 1 -
     * Open the database or SDO query and and fetch the first record. 
    RUN findRecords.                                                  */
    
    /* Return the form again. Set data values, display them, and output them
     * to the WEB stream.  
     *
     * STEP 2a -
     * Set any values that need to be set, then display them. */

    vh_foco = "16".
    RUN displayFields.

    /* STEP 2b -
     * Enable objects that should be enabled. */
    RUN enableFields.

    IF  l-senha-atual THEN
        ENABLE v_satual WITH FRAME {&FRAME-NAME}.
    ELSE
        DISABLE v_satual WITH FRAME {&FRAME-NAME}.


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


