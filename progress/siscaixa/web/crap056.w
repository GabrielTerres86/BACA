/**************************************************************************

Alteracoes:  21/12/2011 - Inclusao de parametro na rotina valida-saldo-conta
                          (Elton).
             
             13/12/2013 - Alteracao referente a integracao Progress X 
                          Dataserver Oracle 
                          Inclusao do VALIDATE ( Andre Euzebio / SUPERO)              

			 06/02/2018 - Adicionado novo historico. (SD 838581 - Kelvin)
                                        
                                        
***************************************************************************/
&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD ok AS CHARACTER FORMAT "X(256)":U 
       FIELD vh_foco AS CHARACTER FORMAT "X(256)":U 
       FIELD v_caixa AS CHARACTER FORMAT "X(256)":U 
       FIELD v_cod AS CHARACTER FORMAT "X(256)":U 
       FIELD v_complem1 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_complem2 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_complem3 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_complem4 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_conta AS CHARACTER FORMAT "X(256)":U 
       FIELD v_coop AS CHARACTER FORMAT "X(256)":U 
       FIELD v_data AS CHARACTER FORMAT "X(256)":U 
       FIELD v_deschist AS CHARACTER FORMAT "X(256)":U 
       FIELD v_documento AS CHARACTER FORMAT "X(256)":U 
       FIELD v_historico AS CHARACTER FORMAT "X(256)":U 
       FIELD v_liberacao AS CHARACTER FORMAT "X(256)":U 
       FIELD v_mensagem AS CHARACTER FORMAT "X(256)":U 
       FIELD v_msg AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nome AS CHARACTER FORMAT "X(256)":U 
       FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
       FIELD v_pac AS CHARACTER FORMAT "X(256)":U 
       FIELD v_poupanca AS CHARACTER FORMAT "X(256)":U 
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

DEF VAR p-poupanca            AS LOG  NO-UNDO.
DEF VAR p-transferencia-conta AS CHAR NO-UNDO.
DEF VAR p-conta-atualiza      AS INTE NO-UNDO.


DEF VAR h_b1crap56 AS HANDLE            NO-UNDO.
DEF VAR h_b1crap00 AS HANDLE            NO-UNDO.

DEF VAR p-literal            AS CHAR    NO-UNDO.
DEF VAR p-ult-sequencia      AS INTE    NO-UNDO.
DEF VAR p-pg                 AS LOG     NO-UNDO.
DEF VAR p-registro           AS RECID   NO-UNDO.

DEF VAR l-houve-erro         AS LOG     NO-UNDO.

DEF TEMP-TABLE w-craperr  NO-UNDO
     FIELD cdagenci   LIKE craperr.cdagenc
     FIELD nrdcaixa   LIKE craperr.nrdcaixa
     FIELD nrsequen   LIKE craperr.nrsequen
     FIELD cdcritic   LIKE craperr.cdcritic
     FIELD dscritic   LIKE craperr.dscritic
     FIELD erro       LIKE craperr.erro.



/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE F:/web/crap056.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS ab_unmap.ok ab_unmap.vh_foco ab_unmap.v_caixa ab_unmap.v_cod ab_unmap.v_complem1 ab_unmap.v_complem2 ab_unmap.v_complem3 ab_unmap.v_complem4 ab_unmap.v_conta ab_unmap.v_coop ab_unmap.v_data ab_unmap.v_deschist ab_unmap.v_documento ab_unmap.v_historico ab_unmap.v_liberacao ab_unmap.v_mensagem ab_unmap.v_msg ab_unmap.v_nome ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_poupanca ab_unmap.v_senha ab_unmap.v_valor 
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.ok ab_unmap.vh_foco ab_unmap.v_caixa ab_unmap.v_cod ab_unmap.v_complem1 ab_unmap.v_complem2 ab_unmap.v_complem3 ab_unmap.v_complem4 ab_unmap.v_conta ab_unmap.v_coop ab_unmap.v_data ab_unmap.v_deschist ab_unmap.v_documento ab_unmap.v_historico ab_unmap.v_liberacao ab_unmap.v_mensagem ab_unmap.v_msg ab_unmap.v_nome ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_poupanca ab_unmap.v_senha ab_unmap.v_valor 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     ab_unmap.ok AT ROW 1 COL 1 HELP
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
     ab_unmap.v_deschist AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_documento AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_historico AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_liberacao AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_mensagem AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_msg AT ROW 1 COL 1 HELP
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
     ab_unmap.v_poupanca AT ROW 1 COL 1 HELP
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
          FIELD ok AS CHARACTER FORMAT "X(256)":U 
          FIELD vh_foco AS CHARACTER FORMAT "X(256)":U 
          FIELD v_caixa AS CHARACTER FORMAT "X(256)":U 
          FIELD v_cod AS CHARACTER FORMAT "X(256)":U 
          FIELD v_complem1 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_complem2 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_complem3 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_complem4 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_conta AS CHARACTER FORMAT "X(256)":U 
          FIELD v_coop AS CHARACTER FORMAT "X(256)":U 
          FIELD v_data AS CHARACTER FORMAT "X(256)":U 
          FIELD v_deschist AS CHARACTER FORMAT "X(256)":U 
          FIELD v_documento AS CHARACTER FORMAT "X(256)":U 
          FIELD v_historico AS CHARACTER FORMAT "X(256)":U 
          FIELD v_liberacao AS CHARACTER FORMAT "X(256)":U 
          FIELD v_mensagem AS CHARACTER FORMAT "X(256)":U 
          FIELD v_msg AS CHARACTER FORMAT "X(256)":U 
          FIELD v_nome AS CHARACTER FORMAT "X(256)":U 
          FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
          FIELD v_pac AS CHARACTER FORMAT "X(256)":U 
          FIELD v_poupanca AS CHARACTER FORMAT "X(256)":U 
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
/* SETTINGS FOR fill-in ab_unmap.ok IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.vh_foco IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_caixa IN FRAME Web-Frame
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
/* SETTINGS FOR fill-in ab_unmap.v_conta IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_coop IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_data IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_deschist IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_documento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_historico IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_liberacao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_mensagem IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_msg IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_nome IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_operador IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_pac IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_poupanca IN FRAME Web-Frame
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
    ("ok":U,"ab_unmap.ok":U,ab_unmap.ok:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("vh_foco":U,"ab_unmap.vh_foco":U,ab_unmap.vh_foco:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_caixa":U,"ab_unmap.v_caixa":U,ab_unmap.v_caixa:HANDLE IN FRAME {&FRAME-NAME}).
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
    ("v_conta":U,"ab_unmap.v_conta":U,ab_unmap.v_conta:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_coop":U,"ab_unmap.v_coop":U,ab_unmap.v_coop:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_data":U,"ab_unmap.v_data":U,ab_unmap.v_data:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_deschist":U,"ab_unmap.v_deschist":U,ab_unmap.v_deschist:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_documento":U,"ab_unmap.v_documento":U,ab_unmap.v_documento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_historico":U,"ab_unmap.v_historico":U,ab_unmap.v_historico:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_liberacao":U,"ab_unmap.v_liberacao":U,ab_unmap.v_liberacao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_mensagem":U,"ab_unmap.v_mensagem":U,ab_unmap.v_mensagem:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_msg":U,"ab_unmap.v_msg":U,ab_unmap.v_msg:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nome":U,"ab_unmap.v_nome":U,ab_unmap.v_nome:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_operador":U,"ab_unmap.v_operador":U,ab_unmap.v_operador:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_pac":U,"ab_unmap.v_pac":U,ab_unmap.v_pac:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_poupanca":U,"ab_unmap.v_poupanca":U,ab_unmap.v_poupanca:HANDLE IN FRAME {&FRAME-NAME}).
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
    DEFINE VARIABLE lOpenAutentica      AS LOGICAL      NO-UNDO INITIAL NO.
    DEFINE VARIABLE lHabilitaLib        AS LOGICAL      NO-UNDO INITIAL NO.
    DEFINE VARIABLE dtAux               AS DATE         NO-UNDO.
    DEFINE VARIABLE p-valor-disponivel  AS DECIMAL      NO-UNDO.
    DEFINE VARIABLE lRecibo             AS LOGICAL      NO-UNDO.


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

        {include/assignfields.i}

        ASSIGN OK = "".

        ASSIGN dtAux = DATE(v_liberacao) NO-ERROR.
        IF ERROR-STATUS:ERROR THEN DO:
            {include/i-erro.i}
        END.
        ELSE DO:

            RUN dbo/b1crap00.p PERSISTENT SET h_b1crap00.

            RUN valida-transacao IN h_b1crap00(INPUT v_coop,
                                               INPUT v_pac, 
                                               INPUT v_caixa).

            IF RETURN-VALUE = "NOK" THEN DO:
                {include/i-erro.i}
            END.
            ELSE DO:
                IF get-value("cancela") <> "" THEN DO:
                    ASSIGN v_historico = ""
                           v_deschist  = ""
                           v_conta     = ""
                           v_nome      = ""
                           v_poupanca  = ""
                           v_documento = ""
                           v_valor     = ""
                           v_liberacao = ""
                           v_mensagem  = ""
                           v_complem1  = ""
                           v_complem2  = ""
                           v_complem3  = ""
                           v_complem4  = ""
                           vh_foco     = "7"
                           v_cod       = ''
                           v_senha     = ''.
                END.
                ELSE DO:
                    RUN verifica-abertura-boletim 
                             IN h_b1crap00(INPUT v_coop,
                                           INPUT INT(v_pac),
                                           INPUT INT(v_caixa),
                                           INPUT v_operador).
                    IF  RETURN-VALUE = "NOK" THEN DO:
                        {include/i-erro.i}
                    END.
                    ELSE DO:
                        RUN dbo/b1crap56.p PERSISTENT SET h_b1crap56.
                        RUN valida-outros-conta 
                         IN h_b1crap56(INPUT v_coop,
                                       INPUT  INT(v_pac),      
                                       INPUT  INT(v_caixa),        
                                       INPUT  INT(v_historico),         
                                       INPUT  INT(v_documento),        
                                       INPUT  INT(v_conta),        
                                       OUTPUT v_nome,     
                                       OUTPUT p-poupanca,
                                       OUTPUT v_deschist,
                                       OUTPUT v_mensagem).

                        IF p-poupanca = yes THEN 
                            ASSIGN v_poupanca =
                             "******* CONTA POUPANCA ********".
                        ELSE 
                            ASSIGN v_poupanca = " ".

                        IF   RETURN-VALUE = "NOK" THEN
                             ASSIGN vh_foco = "7".
                        ELSE
                        IF   v_historico <> "5"   AND
                             v_historico <> "612" AND
                             v_historico <> "355" AND 
                             v_historico <> "135" AND
                             v_historico <> "653" AND
                             v_historico <> "103" AND
                             v_historico <> "555" AND 
                             v_historico <> "503" AND
                             v_historico <> "486" AND 
                             v_historico <> "561" AND 
							 v_historico <> "2553" THEN
                             ASSIGN vh_foco = "10".
                        ELSE                        
                             ASSIGN vh_foco = "11" 
                                    v_documento = " ".
     
                        IF  RETURN-VALUE = "NOK" THEN DO:
                            IF CAN-FIND (FIRST craperr where
                                       craperr.cdcooper = crapcop.cdcooper  AND
                                       craperr.cdagenci = INT(v_pac)        AND
                                       craperr.nrdcaixa = INT(v_caixa)      AND
                                       craperr.cdcritic = 8) THEN
                                ASSIGN v_conta = " ".
                               {include/i-erro.i}
                        END.
                        ELSE DO:
                                IF get-value("ok") <> "" THEN DO:

                                    RUN valida-saldo-conta
                                     IN h_b1crap56(INPUT v_coop,
                                                   INPUT  INT(v_pac),
                                                   INPUT  INT(v_caixa),
                                                   INPUT  DEC(v_conta),
                                                   INPUT  DEC(v_valor),
                                                   INPUT  56, /* cod.rotina */
                                                   INPUT v_coop,  /** Coop. destino **/
                                                   OUTPUT v_mensagem,
                                                   OUTPUT p-valor-disponivel).

                                    IF  v_mensagem <> ' ' THEN DO:
                                        RUN valida-permissao-saldo-conta
                                         IN h_b1crap56
                                                  ( INPUT v_coop,
                                                    INPUT  v_historico,
                                                   INPUT  INT(v_pac),
                                                   INPUT  INT(v_caixa),
                                                   INPUT  DEC(v_valor),
                                                   INPUT  v_operador,
                                                   INPUT  v_cod,
                                                   INPUT  v_senha,
                                                   INPUT  p-valor-disponivel,
                                                   INPUT  v_mensagem).
                                        IF  RETURN-VALUE = 'NOK' THEN DO:
                                            ASSIGN lHabilitaLib = YES
                                                   vh_foco      = "17".
                                            IF  v_cod <> '' THEN DO:
                                                {include/i-erro.i}
                                            END.
                                        END.
                                    END.

                                    IF RETURN-VALUE <> 'NOK' THEN DO:
                                       RUN valida-outros 
                                         IN h_b1crap56(INPUT v_coop,
                                                       INPUT INT(v_pac),
                                                       INPUT INT(v_caixa),
                                                       INPUT INT(v_historico),
                                                       INPUT INT(v_conta),
                                                       INPUT INT(v_documento),
                                                       INPUT DEC(v_valor),
                                                       INPUT DATE(v_liberacao),
                                                 OUTPUT p-conta-atualiza).
                                        IF RETURN-VALUE = "NOK" THEN DO:
                                            ASSIGN vh_foco = "16".
                                            {include/i-erro.i}
                                            ASSIGN v_cod   = ''
                                                   v_senha = ''.
                                        END.
                                        ELSE DO:
                                            ASSIGN l-houve-erro = NO.
    
                                            DO TRANSACTION ON ERROR UNDO:
    
                                               RUN atualiza-outros 
                                                IN h_b1crap56
                                                  (INPUT v_coop,
                                                   INPUT INT(v_pac),
                                                   INPUT INT(v_caixa),
                                                   INPUT v_operador,
                                                   INPUT v_cod,
                                                   INPUT int(v_conta),
                                                   INPUT int(v_historico),
                                                   INPUT int(v_documento),
                                                   INPUT dec(v_valor),
                                                   INPUT v_liberacao,
                                                   INPUT p-conta-atualiza,
                                                   INPUT v_complem1,
                                                   INPUT v_complem2,
                                                   INPUT v_complem3,
                                                   OUTPUT p-pg,
                                                   OUTPUT p-literal,
                                                   OUTPUT p-ult-sequencia).
    
                                                IF RETURN-VALUE = "NOK" THEN DO:
                                                    ASSIGN l-houve-erro = YES.
                                                    FOR EACH w-craperr:
                                                        DELETE w-craperr.
                                                    END.
                                                    FOR EACH craperr NO-LOCK
                                                       WHERE
                                                        craperr.cdcooper = 
                                                        crapcop.cdcooper   AND
                                                        craperr.cdagenci =  
                                                        INT(v_pac)         AND
                                                        craperr.nrdcaixa =   
                                                        INT(v_caixa):
    
                                                        CREATE w-craperr.
                                                        ASSIGN 
                                                        w-craperr.cdagenci 
                                                        = craperr.cdagenc
                                                        w-craperr.nrdcaixa  
                                                        = craperr.nrdcaixa
                                                        w-craperr.nrsequen
                                                        = craperr.nrsequen
                                                        w-craperr.cdcritic  
                                                        = craperr.cdcritic
                                                        w-craperr.dscritic  
                                                        = craperr.dscritic
                                                        w-craperr.erro
                                                        = craperr.erro.
                                                    END.
                                                    UNDO.
                                                END.     

                                            END.  /* do transaction */
    
                                            IF  l-houve-erro = YES  THEN DO:
                                                FOR EACH craperr         
                                                    WHERE
                                                        craperr.cdcooper = 
                                                        crapcop.cdcooper   AND
                                                        craperr.cdagenci =  
                                                        INT(v_pac)         AND
                                                        craperr.nrdcaixa =   
                                                        INT(v_caixa):
                                                    DELETE craperr.
                                                END.    
                                                 
                                                
                                                FOR EACH w-craperr NO-LOCK:
                                                    CREATE craperr.
                                                    ASSIGN craperr.cdcooper
                                                         = crapcop.cdcooper
                                                           craperr.cdagenci  
                                                         = w-craperr.cdagenc
                                                           craperr.nrdcaixa  
                                                         = w-craperr.nrdcaixa
                                                           craperr.nrsequen 
                                                         = w-craperr.nrsequen
                                                           craperr.cdcritic 
                                                         = w-craperr.cdcritic
                                                           craperr.dscritic
                                                         = w-craperr.dscritic
                                                           craperr.erro 
                                                         = w-craperr.erro.
                                                    VALIDATE craperr.
                                                END.
                                                {include/i-erro.i}
                                            END.
    
                                            IF l-houve-erro = NO THEN do:     
                                                ASSIGN lOpenAutentica = YES.
    
                                                IF  INT(v_historico) = 5 THEN
                                                    ASSIGN lRecibo = YES.
                                                ELSE
                                                    ASSIGN lRecibo = NO.

                                                IF  INT(v_historico) = 355 OR
                                                    INT(v_historico) = 612 OR
                                                    INT(v_historico) = 135 OR
                                                    INT(v_historico) = 653 OR
                                                    INT(v_historico) = 103 OR
                                                    INT(v_historico) = 555 OR
                                                    INT(v_historico) = 503 OR
                                                    INT(v_historico) = 486 OR                                                    													 
													INT(v_historico) = 2553 THEN
                                                    ASSIGN lRecibo =  YES. 
                                                    
                                                    
                                                ASSIGN v_historico = ""
                                                       v_deschist  = ""
                                                       v_conta     = ""
                                                       v_nome      = ""
                                                       v_poupanca  = ""
                                                       v_documento = ""
                                                       v_valor     = ""
                                                       v_liberacao = ""
                                                       v_mensagem  = ""
                                                       v_complem1  = ""
                                                       v_complem2  = ""
                                                       v_complem3  = ""
                                                       v_complem4  = ""
                                                       vh_foco     = "7".
                                            END.

                                            ASSIGN v_cod   = ''
                                                   v_senha = ''.
                                        END.
                                    END.
                                END.
                        END.
                        DELETE PROCEDURE h_b1crap56.
                    END.
                END.
            END.
            DELETE PROCEDURE h_b1crap00.

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
       
    
    IF   GET-VALUE("v_historico") <> "355" AND
         GET-VALUE("v_historico") <> "612" AND
         GET-VALUE("v_historico") <> "135" AND
         GET-VALUE("v_historico") <> "653" AND
         GET-VALUE("v_historico") <> "103" AND
         GET-VALUE("v_historico") <> "555" AND
         GET-VALUE("v_historico") <> "503" AND
         GET-VALUE("v_historico") <> "486" AND  
         GET-VALUE("v_historico") <> "561" AND 
		 GET-VALUE("v_historico") <> "2553" THEN
         DO:
             ENABLE v_documento 
                    WITH FRAME {&FRAME-NAME}.
             DISABLE v_complem1
                     v_complem2
                     v_complem3
                     v_complem4
                     WITH FRAME {&FRAME-NAME}.
    END.
    ELSE
        DO:
            DISABLE v_documento 
                    WITH FRAME {&FRAME-NAME}.
            ENABLE  v_complem1
                    v_complem2
                    v_complem3
                    v_complem4
                    WITH FRAME {&FRAME-NAME}.
        END.
        
    IF  GET-VALUE("v_historico") = "5" THEN
        DO:
           DISABLE v_documento 
                   WITH FRAME {&FRAME-NAME}.
           DISABLE  v_complem1
                    v_complem2
                    v_complem3
                    v_complem4
                    WITH FRAME {&FRAME-NAME}.
        END.
                  
                 
    IF  get-value("v_historico") = "6" THEN
        ENABLE v_liberacao WITH FRAME {&FRAME-NAME}.
    ELSE
        DISABLE v_liberacao WITH FRAME {&FRAME-NAME}.

    IF  lHabilitaLib THEN
        ENABLE v_cod v_senha WITH FRAME {&FRAME-NAME}.
    ELSE
        DISABLE v_cod v_senha WITH FRAME {&FRAME-NAME}.


    /* STEP 4.2c -
     * OUTPUT the Progress form buffer to the WEB stream. */
    RUN outputFields.

    IF lOpenAutentica THEN DO:
       ASSIGN vh_foco = "7".
       {&OUT}
               '<script>window.open("autentica.html?v_plit=" +
                "' p-literal '" + "'
               '&v_pseq=' p-ult-sequencia '&v_prec=' STRING(lRecibo) '&v_psetco~ok=yes","waut","width=250,height=145,scrollbars=auto,alwaysRaised=true")'
               '</script>'.
    END.

    
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
    ASSIGN vh_foco = "7".
     
    RUN displayFields.

    /* STEP 2b -
     * Enable objects that should be enabled. */
    RUN enableFields.
    DISABLE v_documento
            v_complem1        
            v_complem2
            v_complem3
            v_complem4
            v_liberacao
            v_cod
            v_senha WITH FRAME {&FRAME-NAME}.
 
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

