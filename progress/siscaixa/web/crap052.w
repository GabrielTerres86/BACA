/* .............................................................................

  Programa: crap052.w

Alteracoes: 17/12/2008 - Ajustes para unificacao dos bancos de dados (Evandro).

            05/05/2011 - Ajuste nas data de liberacao do cheque (Gabriel)
            
            13/12/2013 - Alteracao referente a integracao Progress X 
                         Dataserver Oracle 
                         Inclusao do VALIDATE ( Andre Euzebio / SUPERO) 

............................................................................. */


&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD ok AS CHARACTER FORMAT "X(256)":U 
       FIELD vh_foco AS CHARACTER FORMAT "X(256)":U 
       FIELD v_caixa AS CHARACTER FORMAT "X(256)":U 
       FIELD v_chequesmaiores AS CHARACTER FORMAT "X(256)":U 
       FIELD v_chequesmaioresfora AS CHARACTER FORMAT "X(256)":U 
       FIELD v_chequesmenores AS CHARACTER FORMAT "X(256)":U 
       FIELD v_chequesmenoresfora AS CHARACTER FORMAT "X(256)":U 
       FIELD v_conta AS CHARACTER FORMAT "X(256)":U 
       FIELD v_coop AS CHARACTER FORMAT "X(256)":U 
       FIELD v_data AS CHARACTER FORMAT "X(256)":U 
       FIELD v_data1 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_data2 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_data3 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_data4 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_identifica AS CHARACTER FORMAT "X(256)":U 
       FIELD v_mensagem AS CHARACTER FORMAT "X(256)":U 
       FIELD v_msg AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nome AS CHARACTER FORMAT "X(256)":U 
       FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
       FIELD v_pac AS CHARACTER FORMAT "X(256)":U 
       FIELD v_poupanca AS CHARACTER FORMAT "X(256)":U .


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



DEF VAR h-b1crap52 AS HANDLE          NO-UNDO.
DEF VAR h-b1crap00 AS HANDLE          NO-UNDO.

DEF VAR p-literal       AS CHAR       NO-UNDO.
DEF VAR p-ult-sequencia AS INTE       NO-UNDO.
DEF VAR p-valor         AS DEC        NO-UNDO.
DEF VAR p-nro-docto     AS INTE       NO-UNDo.
DEF VAR p-poupanca      AS LOG        NO-UNDO.
DEF VAR p-nro-conta-atualiza AS INTE NO-UNDO.
DEF VAR p-registro           AS RECID NO-UNDO.

DEFINE VARIABLE dt_data1 AS DATE       NO-UNDO.
DEFINE VARIABLE dt_data2 AS DATE       NO-UNDO.
DEFINE VARIABLE dt_data3 AS DATE       NO-UNDO.
DEFINE VARIABLE dt_data4 AS DATE       NO-UNDO.


DEF VAR l-houve-erro    AS LOG          NO-UNDO.

DEF TEMP-TABLE w-craperr  NO-UNDO
     FIELD cdagenci   LIKE craperr.cdagenc
     FIELD nrdcaixa   LIKE craperr.nrdcaixa
     FIELD nrsequen   LIKE craperr.nrsequen
     FIELD cdcritic   LIKE craperr.cdcritic
     FIELD dscritic   LIKE craperr.dscritic
     FIELD erro       LIKE craperr.erro.

DEF VAR l-error AS LOGICAL NO-UNDO.
DEF VAR i-campo AS INTEGER NO-UNDO.


DEF VAR aux_contador    AS INTE NO-UNDO.
DEF VAR dt-menor-fpraca AS DATE NO-UNDO.
DEF VAR dt-maior-praca  AS DATE NO-UNDO.
DEF VAR dt-menor-praca  AS DATE NO-UNDO.
DEF VAR dt-maior-fpraca AS DATE NO-UNDO.




/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE F:/web/crap052.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS ab_unmap.ok ab_unmap.vh_foco ab_unmap.v_caixa ab_unmap.v_chequesmaiores ab_unmap.v_chequesmaioresfora ab_unmap.v_chequesmenores ab_unmap.v_chequesmenoresfora ab_unmap.v_conta ab_unmap.v_coop ab_unmap.v_data ab_unmap.v_data1 ab_unmap.v_data2 ab_unmap.v_data3 ab_unmap.v_data4 ab_unmap.v_identifica ab_unmap.v_mensagem ab_unmap.v_msg ab_unmap.v_nome ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_poupanca 
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.ok ab_unmap.vh_foco ab_unmap.v_caixa ab_unmap.v_chequesmaiores ab_unmap.v_chequesmaioresfora ab_unmap.v_chequesmenores ab_unmap.v_chequesmenoresfora ab_unmap.v_conta ab_unmap.v_coop ab_unmap.v_data ab_unmap.v_data1 ab_unmap.v_data2 ab_unmap.v_data3 ab_unmap.v_data4 ab_unmap.v_identifica ab_unmap.v_mensagem ab_unmap.v_msg ab_unmap.v_nome ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_poupanca 

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
     ab_unmap.v_chequesmaiores AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_chequesmaioresfora AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_chequesmenores AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_chequesmenoresfora AT ROW 1 COL 1 HELP
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
     ab_unmap.v_data1 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_data2 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_data3 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_data4 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_identifica AT ROW 1 COL 1 HELP
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
          FIELD v_chequesmaiores AS CHARACTER FORMAT "X(256)":U 
          FIELD v_chequesmaioresfora AS CHARACTER FORMAT "X(256)":U 
          FIELD v_chequesmenores AS CHARACTER FORMAT "X(256)":U 
          FIELD v_chequesmenoresfora AS CHARACTER FORMAT "X(256)":U 
          FIELD v_conta AS CHARACTER FORMAT "X(256)":U 
          FIELD v_coop AS CHARACTER FORMAT "X(256)":U 
          FIELD v_data AS CHARACTER FORMAT "X(256)":U 
          FIELD v_data1 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_data2 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_data3 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_data4 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_identifica AS CHARACTER FORMAT "X(256)":U 
          FIELD v_mensagem AS CHARACTER FORMAT "X(256)":U 
          FIELD v_msg AS CHARACTER FORMAT "X(256)":U 
          FIELD v_nome AS CHARACTER FORMAT "X(256)":U 
          FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
          FIELD v_pac AS CHARACTER FORMAT "X(256)":U 
          FIELD v_poupanca AS CHARACTER FORMAT "X(256)":U 
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
/* SETTINGS FOR fill-in ab_unmap.v_chequesmaiores IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_chequesmaioresfora IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_chequesmenores IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_chequesmenoresfora IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_conta IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_coop IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_data IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_data1 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_data2 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_data3 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_data4 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_identifica IN FRAME Web-Frame
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
    ("v_chequesmaiores":U,"ab_unmap.v_chequesmaiores":U,ab_unmap.v_chequesmaiores:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_chequesmaioresfora":U,"ab_unmap.v_chequesmaioresfora":U,ab_unmap.v_chequesmaioresfora:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_chequesmenores":U,"ab_unmap.v_chequesmenores":U,ab_unmap.v_chequesmenores:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_chequesmenoresfora":U,"ab_unmap.v_chequesmenoresfora":U,ab_unmap.v_chequesmenoresfora:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_conta":U,"ab_unmap.v_conta":U,ab_unmap.v_conta:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_coop":U,"ab_unmap.v_coop":U,ab_unmap.v_coop:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_data":U,"ab_unmap.v_data":U,ab_unmap.v_data:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_data1":U,"ab_unmap.v_data1":U,ab_unmap.v_data1:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_data2":U,"ab_unmap.v_data2":U,ab_unmap.v_data2:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_data3":U,"ab_unmap.v_data3":U,ab_unmap.v_data3:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_data4":U,"ab_unmap.v_data4":U,ab_unmap.v_data4:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_identifica":U,"ab_unmap.v_identifica":U,ab_unmap.v_identifica:HANDLE IN FRAME {&FRAME-NAME}).
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
      DEFINE VARIABLE lOpenAutentica AS LOGICAL    NO-UNDO INITIAL NO.
     
    
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
     /* Colocado a chamada do assignFields dentro da include */

     ASSIGN OK = "".

     /*  Monta a Data de Liberacao  para Depositos da Praca e Fora da Praca */
     ASSIGN dt-menor-praca  = crapdat.dtmvtolt + 1
            dt-maior-praca  = crapdat.dtmvtolt + 1.

     /* Verificar se 'Data menor' eh Sabado,Domingo ou Feriado */
     DO WHILE TRUE:
    
         IF   WEEKDAY(dt-menor-praca) = 1  OR /* Domingo */
              WEEKDAY(dt-menor-praca) = 7  OR /* Sabado  */
              CAN-FIND (crapfer WHERE         /* Feriado */
                        crapfer.cdcooper = crapcop.cdcooper  AND
                        crapfer.dtferiad = dt-menor-praca)   THEN
              DO:
                  ASSIGN dt-menor-praca = dt-menor-praca + 1
                         dt-maior-praca = dt-maior-praca + 1.
                  NEXT.
              END.

         ASSIGN dt-menor-praca  = dt-menor-praca + 1.

         DO WHILE TRUE:
     
            IF   WEEKDAY(dt-menor-praca) = 1  OR /* Domingo */
                 WEEKDAY(dt-menor-praca) = 7  OR /* Sabado  */
                 CAN-FIND (crapfer WHERE         /* Feriado */
                           crapfer.cdcooper = crapcop.cdcooper  AND
                           crapfer.dtferiad = dt-menor-praca)   THEN
                 DO:
                     ASSIGN dt-menor-praca = dt-menor-praca + 1.
                     NEXT.
                 END.
                 
            LEAVE.
     
         END.
              
         LEAVE.
    
     END.
         
     /* Fora da praca tem mesma data */
     ASSIGN dt-menor-fpraca = dt-menor-praca 
            dt-maior-fpraca = dt-maior-praca.

     ASSIGN v_data1 = IF dt-menor-praca  <> ? THEN
                      STRING(dt-menor-praca,"99/99/9999") ELSE ""
            v_data2 = IF dt-maior-praca  <> ? THEN
                      STRING(dt-maior-praca,"99/99/9999") ELSE ""
            v_data3 = IF dt-menor-fpraca <> ? THEN 
                      STRING(dt-menor-fpraca,"99/99/9999") ELSE ""
            v_data4 = IF dt-maior-fpraca <> ? THEN 
                      STRING(dt-maior-fpraca,"99/99/9999") ELSE "".
    
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

       
     RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.

     RUN valida-transacao IN h-b1crap00(INPUT v_coop,
                                        INPUT int(v_pac),
                                        INPUT int(v_caixa)).

     IF  RETURN-VALUE = "NOK" THEN DO:
         {include/i-erro.i}
     END.
     ELSE DO:
         IF  get-value("cancela") <> "" THEN DO:
              ASSIGN v_conta              = " "  
                     v_nome               = " "  
                     v_poupanca           = " "
                     v_chequesmenores     = " " 
                     v_chequesmaiores     = " " 
                     v_chequesmenoresfora = " "
                     v_chequesmaioresfora = " "  
                     v_mensagem = ""
                     v_identifica = " "
                     vh_foco    = "7".
         END.
         ELSE DO:

             RUN  verifica-abertura-boletim IN h-b1crap00(INPUT v_coop,
                                                          INPUT int(v_pac),
                                                          INPUT int(v_caixa),
                                                          INPUT v_operador).
             IF  RETURN-VALUE = "NOK" THEN DO:
                 {include/i-erro.i}
             END.
             ELSE DO:

                 RUN dbo/b1crap52.p PERSISTENT SET h-b1crap52.
                 RUN valida-cheque-sem-captura 
                     IN h-b1crap52(INPUT v_coop,
                                   INPUT  INT(v_pac),  
                                   INPUT  INT(v_caixa),
                                   INPUT  INT(v_conta),
                                   OUTPUT v_nome,
                                   OUTPUT dt_data1,
                                   OUTPUT dt_data2,
                                   OUTPUT dt_data3,
                                   OUTPUT dt_data4,
                                   OUTPUT p-poupanca,
                                   OUTPUT v_mensagem).
                 ASSIGN v_data1 = IF dt_data1 <> ? THEN
                                  STRING(dt_data1,"99/99/9999") ELSE ""
                        v_data2 = IF dt_data2 <> ? THEN
                                  STRING(dt_data2,"99/99/9999") ELSE ""
                        v_data3 = IF dt_data3 <> ? THEN 
                                  STRING(dt_data3,"99/99/9999") ELSE ""
                        v_data4 = IF dt_data4 <> ? THEN
                                  STRING(dt_data4,"99/99/9999") ELSE "".
                 
                 IF  p-poupanca = yes THEN 
                     ASSIGN v_poupanca = "******* CONTA POUPANCA ********".
                 ELSE 
                     ASSIGN v_poupanca = " ".
                 
                 ASSIGN vh_foco = "10".

                 IF  RETURN-VALUE = "NOK" THEN DO:
                     ASSIGN v_conta = "".
                     ASSIGN vh_foco = "7".
                     ASSIGN l-error = YES
                            i-campo = 7.
                     {include/i-erro.i}
                 END.
                 ELSE DO:

                     IF  get-value("ok") <> "" THEN DO:
                         RUN valida_identificacao_dep
                             IN h-b1crap52(INPUT v_coop,
                                           INPUT INT(v_pac),
                                           INPUT INT(v_caixa),
                                           INPUT INT(v_conta),
                                           INPUT v_identifica).

                         IF  RETURN-VALUE = "OK" THEN DO:
                             RUN valida-valores
                             IN h-b1crap52(INPUT v_coop,
                                           INPUT  INT(v_pac),    
                                           INPUT  INT(v_caixa),
                                           INPUT  DEC(v_chequesmenores),
                                           INPUT  DEC(v_chequesmaiores),
                                           INPUT  DEC(v_chequesmenoresfora),
                                           INPUT  DEC(v_chequesmaioresfora)).
                         END.
                         
                         IF  RETURN-VALUE = "NOK" THEN DO:
                             {include/i-erro.i}
                         END.
                         ELSE DO:
                             ASSIGN l-houve-erro = NO.
                             DO  TRANSACTION ON ERROR UNDO:

                                 RUN atualiza-cheque-sem-captura
                                     IN h-b1crap52
                                              (INPUT v_coop,
                                               INPUT INT(v_pac), 
                                               INPUT INT(v_caixa),
                                               INPUT v_operador,
                                               INPUT INT(v_conta),
                                               INPUT DEC(v_chequesmenores),
                                               INPUT DEC(v_chequesmaiores),
                                               INPUT DEC(v_chequesmenoresfora),
                                               INPUT DEC(v_chequesmaioresfora),
                                               INPUT v_data1,
                                               INPUT v_data2,
                                               INPUT v_data3,
                                               INPUT v_data4,
                                               INPUT v_nome,
                                               INPUT v_identifica,
                                               OUTPUT p-literal,
                                               OUTPUT p-ult-sequencia,
                                               OUTPUT p-nro-docto).
                                
                                 IF  RETURN-VALUE = "NOK" THEN DO:
                                     ASSIGN l-houve-erro = YES.
                                     FOR EACH w-craperr:
                                         DELETE w-craperr.
                                     END.
                                     FOR EACH craperr NO-LOCK WHERE
                                              craperr.cdcooper = 
                                                crapcop.cdcooper  AND
                                              craperr.cdagenci =  
                                                INT(v_pac)        AND
                                              craperr.nrdcaixa =  
                                                INT(v_caixa):

                                         CREATE w-craperr.
                                         ASSIGN w-craperr.cdagenci   =
                                                craperr.cdagenci
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
                             END. /* do transaction */
                      
                             IF  l-houve-erro = YES  THEN DO:
                                 FOR EACH w-craperr NO-LOCK:
                                     CREATE craperr.
                                     ASSIGN craperr.cdcooper   =
                                            crapcop.cdcooper
                                            craperr.cdagenci   = 
                                            w-craperr.cdagenci
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
                                     VALIDATE craperr.
                                 END.
                                 {include/i-erro.i}
                             END.
                             
                             IF   l-houve-erro = NO THEN DO:  

                                  ASSIGN lOpenAutentica = YES.

                                  ASSIGN v_conta              = " "  
                                         v_nome               = " "  
                                         v_poupanca           = " "
                                         v_chequesmenores     = " " 
                                         v_chequesmaiores     = " " 
                                         v_chequesmenoresfora = " "
                                         v_chequesmaioresfora = " " 
                                         v_identifica         = " "
                                         v_mensagem  = ""
                                         vh_foco     = "7".
                             END.
                         END. 
                     END.
                 END.
                 DELETE PROCEDURE h-b1crap52.
             END.
         END.
     END.
     DELETE PROCEDURE h-b1crap00.
 
    RUN displayFields.
   
    /* STEP 4.2b -
     * Enable objects that should be enabled. */
    RUN enableFields.

    /* STEP 4.2c -
     * OUTPUT the Progress form buffer to the WEB stream. */
    RUN outputFields.
 
    IF l-error = YES THEN
    {&out} '<script>document.forms[0].elements[' i-campo '].select();</script>'.
    

    IF lOpenAutentica THEN DO:
        /*----
        {&out} 
        "<script>alert('Documento Gerado: ' + '" p-nro-docto "');</script>"
         SKIP.
        ----*/

        {&OUT}
            '<script>window.open("autentica.html?v_plit=" + "' p-literal '" + 
            "&v_pseq=" +
             "' p-ult-sequencia '" + "&v_prec=" + "yes" + "&v_psetcook=" + 
             "yes","waut",
             "width=250,height=145,scrollbars=auto,alwaysRaised=true")
            </script>'.
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
        
    ASSIGN vh_foco = "7".

    /* Monta a Data de Liberacao para Depositos da Praca e Fora da Praca */
    ASSIGN dt-menor-praca  = crapdat.dtmvtolt + 1
           dt-maior-praca  = crapdat.dtmvtolt + 1.

    /* Verificar se 'Data menor' eh Sabado,Domingo ou Feriado */
    DO WHILE TRUE:
    
       IF   WEEKDAY(dt-menor-praca) = 1  OR /* Domingo */
            WEEKDAY(dt-menor-praca) = 7  OR /* Sabado  */
            CAN-FIND (crapfer WHERE         /* Feriado */
                      crapfer.cdcooper = crapcop.cdcooper  AND
                      crapfer.dtferiad = dt-menor-praca)   THEN
            DO:
                ASSIGN dt-menor-praca = dt-menor-praca + 1
                       dt-maior-praca = dt-maior-praca + 1.
                NEXT.
            END.

       ASSIGN dt-menor-praca  = dt-menor-praca + 1.

       DO WHILE TRUE:
     
          IF   WEEKDAY(dt-menor-praca) = 1  OR /* Domingo */
               WEEKDAY(dt-menor-praca) = 7  OR /* Sabado  */
               CAN-FIND (crapfer WHERE         /* Feriado */
                         crapfer.cdcooper = crapcop.cdcooper  AND
                         crapfer.dtferiad = dt-menor-praca)   THEN
               DO:
                   ASSIGN dt-menor-praca = dt-menor-praca + 1.
                   NEXT.
               END.
                 
          LEAVE.
     
       END.
              
       LEAVE. 

    END. 

    /* Fora da praca tem mesma data */
    ASSIGN dt-menor-fpraca = dt-menor-praca 
           dt-maior-fpraca = dt-maior-praca.

    ASSIGN v_data1 = IF dt-menor-praca  <> ? THEN
                     STRING(dt-menor-praca,"99/99/9999") ELSE ""
           v_data2 = IF dt-maior-praca  <> ? THEN
                     STRING(dt-maior-praca,"99/99/9999") ELSE ""
           v_data3 = IF dt-menor-fpraca <> ? THEN
                     STRING(dt-menor-fpraca,"99/99/9999") ELSE ""
           v_data4 = IF dt-maior-fpraca <> ? THEN 
                     STRING(dt-maior-fpraca,"99/99/9999") ELSE "".

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

