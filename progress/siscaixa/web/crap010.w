/* .............................................................................

   Programa: siscaixa/web/crap010.w
   Sistema : Caixa On-line
   Sigla   : CRED   
   Autor   : Mirtes.
   Data    : Marco/2001                      Ultima atualizacao: 09/03/2006.

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Estorno Boletim Caixa

   Alteracoes: 01/09/2005 - Tratamentos para unificacao dos bancos, passar
                            codigo da cooperativa como parametro para as 
                            procedure (Julio)
                            
               09/03/2006 - Usar o codigo da cooperativa nas buscas (Evandro).
                            
............................................................................ */
&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD vh_foco AS CHARACTER FORMAT "X(256)":U 
       FIELD v_caixa AS CHARACTER FORMAT "X(256)":U 
       FIELD v_ccred AS CHARACTER FORMAT "X(256)":U 
       FIELD v_cdeb AS CHARACTER FORMAT "X(256)":U 
       FIELD v_chistcont AS CHARACTER FORMAT "X(256)":U 
       FIELD v_cod AS CHARACTER FORMAT "X(256)":U 
       FIELD v_complem1 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_complem2 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_complem3 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_complem4 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_complem5 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_coop AS CHARACTER FORMAT "X(256)":U 
       FIELD v_data AS CHARACTER FORMAT "X(256)":U 
       FIELD v_deschist AS CHARACTER FORMAT "X(256)":U 
       FIELD v_doc AS CHARACTER FORMAT "X(256)":U 
       FIELD v_hist AS CHARACTER FORMAT "X(256)":U 
       FIELD v_msg AS CHARACTER FORMAT "X(256)":U 
       FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
       FIELD v_pac AS CHARACTER FORMAT "X(256)":U 
       FIELD v_senha AS CHARACTER FORMAT "X(256)":U 
       FIELD v_valor AS CHARACTER FORMAT "X(256)":U .


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

DEF VAR h-b1crap00 AS HANDLE     NO-UNDO.
DEF VAR h-b1crap10 AS HANDLE     NO-UNDO.

DEF VAR p-pg            AS LOG   NO-UNDO.
DEF VAR p-literal       AS CHAR  NO-UNDO.
DEF VAR p-ult-sequencia AS INTE  NO-UNDO.
DEF VAR p-registro      AS RECID NO-UNDO.

DEF VAR l-houve-erro    AS LOG   NO-UNDO.

DEF TEMP-TABLE w-craperr         NO-UNDO
     FIELD cdcooper   LIKE craperr.cdcooper
     FIELD cdagenci   LIKE craperr.cdagenc
     FIELD nrdcaixa   LIKE craperr.nrdcaixa
     FIELD nrsequen   LIKE craperr.nrsequen
     FIELD cdcritic   LIKE craperr.cdcritic
     FIELD dscritic   LIKE craperr.dscritic
     FIELD erro       LIKE craperr.erro.

DEF VAR l-error AS LOGICAL NO-UNDO.
DEF VAR i-campo AS INTEGER NO-UNDO.




/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE F:/web/crap010.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS ab_unmap.vh_foco ab_unmap.v_caixa ab_unmap.v_ccred ab_unmap.v_cdeb ab_unmap.v_chistcont ab_unmap.v_cod ab_unmap.v_complem1 ab_unmap.v_complem2 ab_unmap.v_complem3 ab_unmap.v_complem4 ab_unmap.v_complem5 ab_unmap.v_coop ab_unmap.v_data ab_unmap.v_deschist ab_unmap.v_doc ab_unmap.v_hist ab_unmap.v_msg ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_senha ab_unmap.v_valor 
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.vh_foco ab_unmap.v_caixa ab_unmap.v_ccred ab_unmap.v_cdeb ab_unmap.v_chistcont ab_unmap.v_cod ab_unmap.v_complem1 ab_unmap.v_complem2 ab_unmap.v_complem3 ab_unmap.v_complem4 ab_unmap.v_complem5 ab_unmap.v_coop ab_unmap.v_data ab_unmap.v_deschist ab_unmap.v_doc ab_unmap.v_hist ab_unmap.v_msg ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_senha ab_unmap.v_valor 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     ab_unmap.vh_foco AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_caixa AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_ccred AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_cdeb AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_chistcont AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_cod AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_complem1 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_complem2 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_complem3 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_complem4 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_complem5 AT ROW 1 COL 1 HELP
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
     ab_unmap.v_deschist AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_doc AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_hist AT ROW 1 COL 1 HELP
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
     ab_unmap.v_senha AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_valor AT ROW 1 COL 1 HELP
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
          FIELD vh_foco AS CHARACTER FORMAT "X(256)":U 
          FIELD v_caixa AS CHARACTER FORMAT "X(256)":U 
          FIELD v_ccred AS CHARACTER FORMAT "X(256)":U 
          FIELD v_cdeb AS CHARACTER FORMAT "X(256)":U 
          FIELD v_chistcont AS CHARACTER FORMAT "X(256)":U 
          FIELD v_cod AS CHARACTER FORMAT "X(256)":U 
          FIELD v_complem1 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_complem2 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_complem3 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_complem4 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_complem5 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_coop AS CHARACTER FORMAT "X(256)":U 
          FIELD v_data AS CHARACTER FORMAT "X(256)":U 
          FIELD v_deschist AS CHARACTER FORMAT "X(256)":U 
          FIELD v_doc AS CHARACTER FORMAT "X(256)":U 
          FIELD v_hist AS CHARACTER FORMAT "X(256)":U 
          FIELD v_msg AS CHARACTER FORMAT "X(256)":U 
          FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
          FIELD v_pac AS CHARACTER FORMAT "X(256)":U 
          FIELD v_senha AS CHARACTER FORMAT "X(256)":U 
          FIELD v_valor AS CHARACTER FORMAT "X(256)":U 
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
/* SETTINGS FOR fill-in ab_unmap.vh_foco IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_caixa IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_ccred IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_cdeb IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_chistcont IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_cod IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_complem1 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_complem2 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_complem3 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_complem4 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_complem5 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_coop IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_data IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_deschist IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_doc IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_hist IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_msg IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_operador IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_pac IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_senha IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_valor IN FRAME Web-Frame
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
    ("vh_foco":U,"ab_unmap.vh_foco":U,ab_unmap.vh_foco:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_caixa":U,"ab_unmap.v_caixa":U,ab_unmap.v_caixa:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_ccred":U,"ab_unmap.v_ccred":U,ab_unmap.v_ccred:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_cdeb":U,"ab_unmap.v_cdeb":U,ab_unmap.v_cdeb:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_chistcont":U,"ab_unmap.v_chistcont":U,ab_unmap.v_chistcont:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_cod":U,"ab_unmap.v_cod":U,ab_unmap.v_cod:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_complem1":U,"ab_unmap.v_complem1":U,ab_unmap.v_complem1:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_complem2":U,"ab_unmap.v_complem2":U,ab_unmap.v_complem2:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_complem3":U,"ab_unmap.v_complem3":U,ab_unmap.v_complem3:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_complem4":U,"ab_unmap.v_complem4":U,ab_unmap.v_complem4:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_complem5":U,"ab_unmap.v_complem5":U,ab_unmap.v_complem5:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_coop":U,"ab_unmap.v_coop":U,ab_unmap.v_coop:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_data":U,"ab_unmap.v_data":U,ab_unmap.v_data:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_deschist":U,"ab_unmap.v_deschist":U,ab_unmap.v_deschist:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_doc":U,"ab_unmap.v_doc":U,ab_unmap.v_doc:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_hist":U,"ab_unmap.v_hist":U,ab_unmap.v_hist:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_msg":U,"ab_unmap.v_msg":U,ab_unmap.v_msg:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_operador":U,"ab_unmap.v_operador":U,ab_unmap.v_operador:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_pac":U,"ab_unmap.v_pac":U,ab_unmap.v_pac:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_senha":U,"ab_unmap.v_senha":U,ab_unmap.v_senha:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_valor":U,"ab_unmap.v_valor":U,ab_unmap.v_valor:HANDLE IN FRAME {&FRAME-NAME}).
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
    RUN findRecords.
 
    /* STEP 3 -    
     * AssignFields will save the data in the frame.
     * (it automatically upgrades the lock to exclusive while doing the update)
     * 
     *  If a new record needs to be created set AddMode to true before 
        running assignFields.  
     *     setAddMode(TRUE).   
     * RUN assignFields. */
    
    
    
    {include/assignfields.i} /* Colocado a chamada do assignFields dentro da in~clude */

     RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.

     IF  get-value("cancela") <> "" THEN DO:
         ASSIGN v_hist = ""  
                v_deschist = ""  
                v_chistcont = ""
                v_cdeb = "" 
                v_ccred = ""
                v_complem1 = ""
                v_complem2 = ""
                v_complem3 = ""
                v_complem4 = ""
                v_complem5 = ""
                v_doc   = ""  
                v_valor = ""
                vh_foco = "7"
                v_cod = ''
                v_senha = ''.
     END.
     ELSE DO:
     
         RUN valida-transacao IN h-b1crap00(INPUT v_coop,
                                            INPUT v_pac,
                                            INPUT v_caixa).
        
         IF RETURN-VALUE = "NOK" THEN  DO:
             ASSIGN v_cod = ''
                    v_senha = ''.
             {include/i-erro.i}
         END.
         ELSE DO:
             RUN dbo/b1crap10.p PERSISTENT SET h-b1crap10.
             RUN valida-estorno-boletim IN h-b1crap10(INPUT v_coop,       
                                                      INPUT v_operador,
                                                      INPUT v_pac,
                                                      INPUT v_caixa,
                                                      INPUT INT(v_hist)).
    
             IF  RETURN-VALUE = "NOK" THEN DO:
                 ASSIGN l-error = YES
                        i-campo = 7.
                 ASSIGN v_hist      = ""
                        v_deschist  = ""
                        v_chistcont = ""
                        v_cdeb      = ""
                        v_ccred     = ""
                        v_complem1  = ""
                        v_complem2  = " "
                        v_complem3  = " "
                        v_complem4  = " "
                        v_complem5  = " "
                        v_doc       = ""
                        v_valor     = ""
                        vh_foco = "7"
                        v_cod = ''
                        v_senha = ''.
                 {include/i-erro.i}
             END.
             ELSE DO:

                   RUN valida-existencia-boletim 
                            IN h-b1crap10(INPUT v_coop,        
                                          INPUT v_operador,
                                          INPUT INT(v_pac),
                                          INPUT INT(v_hist),
                                          INPUT INT(v_caixa),
                                          INPUT INT(v_doc),
                                          OUTPUT v_valor,
                                          OUTPUT v_complem1,
                                          OUTPUT v_complem2,
                                          OUTPUT v_complem3,
                                          OUTPUT v_complem4,
                                          OUTPUT v_complem5).
                   ASSIGN v_valor =
                           STRING(DEC(v_valor),"zzz,zzz,zzz,zz9.99").
                        
                   IF  RETURN-VALUE = "NOK" THEN DO:
                       {include/i-erro.i}
                       ASSIGN v_cod = ''
                              v_senha = ''.
                   END.
                   ELSE DO:
                 
                       RUN retorna-valor-historico 
                                         IN h-b1crap10(INPUT v_coop,       
                                                       INPUT v_pac,
                                                       INPUT INT(v_hist),
                                                       INPUT INT(v_caixa),
                                                       OUTPUT v_ccred,
                                                       OUTPUT v_cdeb,
                                                       OUTPUT v_chistcont,
                                                       OUTPUT v_deschist).
                       IF  RETURN-VALUE = "NOK" THEN DO:
                           ASSIGN v_cod = ''
                                  v_senha = ''.
                           {include/i-erro.i}
                       END.
                       ELSE DO:
                             ASSIGN vh_foco = "16".
                             IF GET-VALUE("ok") <> "" THEN DO:         
                                ASSIGN l-houve-erro = NO.
                   
                                DO TRANSACTION ON ERROR UNDO:
                
                                    RUN estorna-boletim 
                                     IN h-b1crap10(INPUT v_coop,         
                                                   INPUT v_operador,
                                                   INPUT INT(v_pac),
                                                   INPUT INT(v_caixa),
                                                   INPUT INT(v_hist),
                                                   INPUT INT(v_doc),
                                                   INPUT v_cod,
                                                   INPUT v_senha,
                                                   OUTPUT p-pg).
                                    IF  RETURN-VALUE = "OK"  THEN  DO:
                                        RUN grava-autenticacao 
                                         IN h-b1crap00 (INPUT v_coop,
                                                        INPUT INT(v_pac),
                                                        INPUT INT(v_caixa),
                                                        INPUT v_operador,
                                                        INPUT DEC(v_valor),
                                                        INPUT DEC(v_doc),
                                                        INPUT p-pg, 
                                                        INPUT "1",  
                                                        INPUT YES, 
                                                        INPUT INT(v_hist),
                                                        INPUT ?, 
                                                        INPUT 0, 
                                                        INPUT 0, 
                                                        INPUT 0,
                                                        OUTPUT p-literal,
                                                        OUTPUT p-ult-sequencia,
                                                        OUTPUT p-registro).
                                   END.
                                   ASSIGN v_valor = 
                                    STRING(DEC(v_valor),"zzz,zz~z,zzz,zz9.99").

                                   IF  RETURN-VALUE = "NOK" THEN DO:
                                       ASSIGN l-houve-erro = YES.
                                       FOR EACH w-craperr:
                                           DELETE w-craperr.
                                       END.
                                       FOR EACH craperr NO-LOCK WHERE
                                                craperr.cdcooper =
                                                  crapcop.cdcooper   AND
                                                craperr.cdagenci =
                                                  INT(v_pac)         AND
                                                craperr.nrdcaixa = 
                                                  INT(v_caixa):
                                           CREATE w-craperr.
                                           ASSIGN w-craperr.cdcooper   =
                                                  craperr.cdcooper
                                                  w-craperr.cdagenci   =
                                                  craperr.cdagenc
                                                  w-craperr.nrdcaixa   =
                                                  craperr.nrdcaixa
                                                  w-craperr.nrsequen   =
                                                  craperr.nrsequen
                                                  w-craperr.cdcritic   =
                                                  craperr.cdcritic
                                                  w-craperr.dscritic   = 
                                                  craperr.dscritic
                                                  w-craperr.erro       =
                                                  craperr.erro.
                                       END.
                                       UNDO.
                                   END.     
                                END.  /* do transaction */

                                IF  l-houve-erro = YES  THEN DO:

                                    FOR EACH craperr WHERE 
                                      craperr.cdcooper = crapcop.cdcooper  AND
                                      craperr.cdagenci = INTE(v_pac)       AND
                                      craperr.nrdcaixa = INTE(v_caixa)
                                      EXCLUSIVE-LOCK:
                                      DELETE craperr.
                                    END.

       
                                    FOR EACH w-craperr NO-LOCK:
                                        CREATE craperr.
                                        ASSIGN craperr.cdcooper   =
                                               w-craperr.cdcooper
                                               craperr.cdagenci   = 
                                               w-craperr.cdagenc
                                               craperr.nrdcaixa   =
                                               w-craperr.nrdcaixa
                                               craperr.nrsequen   =
                                               w-craperr.nrsequen
                                               craperr.cdcritic   = 
                                               w-craperr.cdcritic
                                               craperr.dscritic   =
                                               w-craperr.dscritic
                                               craperr.erro       = 
                                               w-craperr.erro.
                                    END.
                                    ASSIGN v_cod = ''
                                           v_senha = ''.
                                    {include/i-erro.i}
                                END.

                                IF  l-houve-erro = NO THEN do:  

                                   {&OUT}
                        '<script>window.open("autentica.html?v_plit=" +
                        "' p-literal '" + 
                        "&v_pseq=" + "' p-ult-sequencia '" + "&v_prec=" +
                         "NO"  + "&v_psetcook=" + "yes","waut","width=250,height=145,scrollbars=auto,alwaysRaised=true")
                                   </script>'.

                                   ASSIGN v_hist      = ""
                                          v_deschist  = ""
                                          v_chistcont = ""
                                          v_cdeb      = ""
                                          v_ccred     = ""
                                          v_complem1  = ""
                                          v_complem2  = " "
                                          v_complem3  = " "
                                          v_complem4  = ""
                                          v_complem5  = ""
                                          v_doc       = ""
                                          v_valor     = ""
                                          vh_foco = "7"
                                          v_cod = ''
                                          v_senha = ''.
                                END.
                             END.  /* get-value = "OK" */
                     END.  /* v_doc <> " " */
                 END.
             END.
                   
             DELETE PROCEDURE h-b1crap10.
    
    
         END.
     END.

   DELETE PROCEDURE h-b1crap00.

    
    
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


    IF INT(v_hist) = 701 OR INT(v_hist) = 702 THEN
        ENABLE  v_cod v_senha WITH FRAME {&FRAME-NAME}.
    ELSE
        DISABLE v_cod v_senha WITH FRAME {&FRAME-NAME}.





    /* STEP 4.2c -
     * OUTPUT the Progress form buffer to the WEB stream. */
    RUN outputFields.

        IF l-error = YES THEN
    {&out} '<script>document.forms[0].elements[' i-campo '].select();</script>'.
 
    
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
        vh_foco = "7".
    RUN displayFields.


    /* STEP 2b -
     * Enable objects that should be enabled. */
    RUN enableFields.
    DISABLE v_cod v_senha WITH FRAME {&FRAME-NAME}.




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

/* ......................................................................... */
