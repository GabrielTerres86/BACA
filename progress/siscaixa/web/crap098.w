/* .............................................................................

  Programa: crap098.w

Alteracoes: 17/12/2008 - Ajustes para unificacao dos bancos de dados (Evandro).

            13/12/2013 - Adicionado validate para a tabela craperr (Tiago).
............................................................................. */


&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
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
       FIELD v_docto AS CHARACTER FORMAT "X(256)":U 
       FIELD v_identifica AS CHARACTER FORMAT "X(256)":U 
       FIELD v_msg AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nome AS CHARACTER FORMAT "X(256)":U 
       FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
       FIELD v_pac AS CHARACTER FORMAT "X(256)":U 
       FIELD v_poupanca AS CHARACTER FORMAT "X(256)":U 
       FIELD v_valor AS CHARACTER FORMAT "X(256)":U 
       FIELD v_valor1 AS CHARACTER FORMAT "X(256)":U .


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



DEF VAR h-b1crap98 AS HANDLE          NO-UNDO.
DEF VAR h-b1crap00 AS HANDLE          NO-UNDO.
DEF VAR h-b1crap99 AS HANDLE          NO-UNDO.

DEF VAR p-literal       AS CHAR       NO-UNDO.
DEF VAR p-ult-sequencia AS INTE       NO-UNDO.
DEF VAR p-valor         AS DEC        NO-UNDO.
DEF VAR p-poupanca      AS LOG        NO-UNDO.
DEF VAR p-registro      AS RECID      NO-UNDO.


DEF VAR l-houve-erro    AS LOG          NO-UNDO.

DEF TEMP-TABLE w-craperr  NO-UNDO
     FIELD cdagenci   LIKE craperr.cdagenc
     FIELD nrdcaixa   LIKE craperr.nrdcaixa
     FIELD nrsequen   LIKE craperr.nrsequen
     FIELD cdcritic   LIKE craperr.cdcritic
     FIELD dscritic   LIKE craperr.dscritic
     FIELD erro       LIKE craperr.erro.


DEF VAR aux_contador    AS INTE NO-UNDO.
DEF VAR dt-menor-fpraca AS DATE NO-UNDO.
DEF VAR dt-maior-praca  AS DATE NO-UNDO.
DEF VAR dt-menor-praca  AS DATE NO-UNDO.
DEF VAR dt-maior-fpraca AS DATE NO-UNDO.

DEF VAR p-data1 AS DATE NO-UNDO.
DEF VAR p-data2 AS DATE NO-UNDO.
DEF VAR p-data3 AS DATE NO-UNDO.
DEF VAR p-data4 AS DATE NO-UNDO.

DEFINE VARIABLE de_valor1 AS DECIMAL    NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE F:/web/crap098.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS ab_unmap.vh_foco ab_unmap.v_caixa ab_unmap.v_chequesmaiores ab_unmap.v_chequesmaioresfora ab_unmap.v_chequesmenores ab_unmap.v_chequesmenoresfora ab_unmap.v_conta ab_unmap.v_coop ab_unmap.v_data ab_unmap.v_data1 ab_unmap.v_data2 ab_unmap.v_data3 ab_unmap.v_data4 ab_unmap.v_docto ab_unmap.v_identifica ab_unmap.v_msg ab_unmap.v_nome ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_poupanca ab_unmap.v_valor ab_unmap.v_valor1 
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.vh_foco ab_unmap.v_caixa ab_unmap.v_chequesmaiores ab_unmap.v_chequesmaioresfora ab_unmap.v_chequesmenores ab_unmap.v_chequesmenoresfora ab_unmap.v_conta ab_unmap.v_coop ab_unmap.v_data ab_unmap.v_data1 ab_unmap.v_data2 ab_unmap.v_data3 ab_unmap.v_data4 ab_unmap.v_docto ab_unmap.v_identifica ab_unmap.v_msg ab_unmap.v_nome ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_poupanca ab_unmap.v_valor ab_unmap.v_valor1 

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
     ab_unmap.v_docto AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_identifica AT ROW 1 COL 1 HELP
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
     ab_unmap.v_valor AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_valor1 AT ROW 1 COL 1 HELP
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
          FIELD v_docto AS CHARACTER FORMAT "X(256)":U 
          FIELD v_identifica AS CHARACTER FORMAT "X(256)":U 
          FIELD v_msg AS CHARACTER FORMAT "X(256)":U 
          FIELD v_nome AS CHARACTER FORMAT "X(256)":U 
          FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
          FIELD v_pac AS CHARACTER FORMAT "X(256)":U 
          FIELD v_poupanca AS CHARACTER FORMAT "X(256)":U 
          FIELD v_valor AS CHARACTER FORMAT "X(256)":U 
          FIELD v_valor1 AS CHARACTER FORMAT "X(256)":U 
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
/* SETTINGS FOR fill-in ab_unmap.v_docto IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_identifica IN FRAME Web-Frame
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
/* SETTINGS FOR fill-in ab_unmap.v_valor IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_valor1 IN FRAME Web-Frame
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
    ("v_docto":U,"ab_unmap.v_docto":U,ab_unmap.v_docto:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_identifica":U,"ab_unmap.v_identifica":U,ab_unmap.v_identifica:HANDLE IN FRAME {&FRAME-NAME}).
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
    ("v_valor":U,"ab_unmap.v_valor":U,ab_unmap.v_valor:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_valor1":U,"ab_unmap.v_valor1":U,ab_unmap.v_valor1:HANDLE IN FRAME {&FRAME-NAME}).
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
     
  DEFINE VARIABLE lOpen099d   AS LOGICAL      NO-UNDO INITIAL NO.

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

  ASSIGN dt-menor-praca  = ?
         dt-maior-praca  = ?
         dt-menor-fpraca = ?
         dt-maior-fpraca = ?
         dt-menor-fpraca = crapdat.dtmvtolt.

  DO  aux_contador = 1 TO 4:
      ASSIGN dt-menor-fpraca = dt-menor-fpraca + 1.

      IF  WEEKDAY(dt-menor-fpraca) = 1   THEN       
          dt-menor-fpraca = dt-menor-fpraca + 1.
      ELSE  
      IF  WEEKDAY(dt-menor-fpraca) = 7   THEN    
          dt-menor-fpraca = dt-menor-fpraca + 2.

      DO  WHILE TRUE: 
          FIND crapfer NO-LOCK WHERE 
               crapfer.cdcooper = crapcop.cdcooper  AND
               crapfer.dtferiad = dt-menor-fpraca NO-ERROR.
          IF  AVAIL crapfer  THEN DO:
              IF  WEEKDAY(dt-menor-fpraca + 1) = 1   THEN  
                  ASSIGN dt-menor-fpraca = dt-menor-fpraca + 2.
              ELSE
              IF  WEEKDAY(dt-menor-fpraca + 1) = 7   THEN          
                  ASSIGN dt-menor-fpraca = dt-menor-fpraca + 3.
              ELSE
                  ASSIGN dt-menor-fpraca = dt-menor-fpraca + 1.  
              NEXT.
          END. 
          IF  aux_contador = 1   THEN
              ASSIGN dt-maior-praca = dt-menor-fpraca.
          ELSE
          IF  aux_contador = 2   THEN
              ASSIGN dt-menor-praca = dt-menor-fpraca. 
          ELSE
          IF  aux_contador = 3   THEN
              ASSIGN dt-maior-fpraca = dt-menor-fpraca.
          LEAVE.
      END.  /*  do while */
  END.      /* do */


  IF REQUEST_METHOD = "POST":U THEN DO:

    RUN inputFields.

    {include/assignfields.i}

   ASSIGN v_data1 = IF dt-menor-praca  <> ? THEN 
                    STRING(dt-menor-praca,"99/99/9999")  ELSE ""
          v_data2 = IF dt-maior-praca  <> ? THEN
                    STRING(dt-maior-praca,"99/99/9999")  ELSE ""
          v_data3 = IF dt-menor-fpraca <> ? THEN
                    STRING(dt-menor-fpraca,"99/99/9999") ELSE ""
          v_data4 = IF dt-maior-fpraca <> ? THEN
                    STRING(dt-maior-fpraca,"99/99/9999") ELSE "".

   RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.

   RUN valida-transacao IN h-b1crap00(INPUT v_coop,
                                      INPUT v_pac,
                                      INPUT v_caixa).

   ASSIGN vh_foco = "22".

   IF  RETURN-VALUE = "NOK" THEN DO:
       {include/i-erro.i}
   END.
   ELSE DO:
       IF  get-value("cancela") <> "" THEN DO:
           ASSIGN  v_docto              = " "
                   v_conta              = " "  
                   v_nome               = " "  
                   v_poupanca           = " "
                   v_identifica         = " "
                   v_valor              = " "
                   v_valor1             = " "
                   v_chequesmenores     = " " 
                   v_chequesmaiores     = " " 
                   v_chequesmenoresfora = " "
                   v_chequesmaioresfora = " ".
       END.
       ELSE DO:

           RUN verifica-abertura-boletim IN h-b1crap00(INPUT v_coop,
                                                       INPUT v_pac,
                                                       INPUT v_caixa,
                                                       INPUT v_operador).
           IF  RETURN-VALUE = "NOK" THEN DO:
              {include/i-erro.i}
           END.
           ELSE DO:

               RUN dbo/b1crap98.p PERSISTENT SET h-b1crap98.
               RUN valida-cheque-com-captura 
                           IN h-b1crap98(INPUT  v_coop,
                                         INPUT  v_pac,    
                                         INPUT  v_caixa,
                                         INPUT  v_conta,
                                         INPUT  v_docto,
                                         OUTPUT v_identifica,
                                         OUTPUT v_valor,
                                         OUTPUT v_valor1,
                                         OUTPUT v_chequesmenores,
                                         OUTPUT v_chequesmaiores,
                                         OUTPUT v_chequesmenoresfora,
                                         OUTPUT v_chequesmaioresfora,
                                         OUTPUT p-data1,
                                         OUTPUT p-data2,
                                         OUTPUT p-data3,
                                         OUTPUT p-data4,
                                         OUTPUT v_nome,
                                         OUTPUT p-poupanca).
               ASSIGN v_valor   
                       = STRING(DEC(v_valor),"zzz,zzz,zzz,zz9.99")
                      v_valor1   
                       = STRING(DEC(v_valor1),"zzz,zzz,zzz,zz9.99")
                      v_chequesmenores  
                       = STRING(DEC(v_chequesmenores),"zzz,zzz,zzz,zz9.99")    
                      v_chequesmaiores 
                       = STRING(DEC(v_chequesmaiores),"zzz,zzz,zzz,zz9.99")    
                      v_chequesmenoresfora
                       = STRING(DEC(v_chequesmenoresfora),"zzz,zzz,zzz,zz9.99")
                      v_chequesmaioresfora 
                       = STRING(DEC(v_chequesmaioresfora),"zzz,zzz,zzz,zz9.99")
                      de_valor1  
                          = DEC(v_valor1) + DEC(v_chequesmenores) +  
                            DEC(v_chequesmaiores)     + 
                            DEC(v_chequesmenoresfora) +
                            DEC(v_chequesmaioresfora).
                      
               IF  RETURN-VALUE = "NOK" THEN DO:
                   {include/i-erro.i}.
               END.
               ELSE DO:

                   IF get-value("autentica") <> "" THEN
                      DO:
                          MESSAGE "GUILHERME NO NO CHAMOU critica-cheque-cooperativa-autenticado AQUI" get-value("autentica").
                          RUN dbo/b1crap99.p PERSISTENT SET h-b1crap99.
                          RUN critica-cheque-cooperativa-autenticado 
                              IN h-b1crap99(INPUT v_coop,
                                            INPUT INT(v_pac),
                                            INPUT INT(v_caixa),
                                            INPUT NO,
                                            INPUT NO).
                          DELETE PROCEDURE h-b1crap99.
                          IF RETURN-VALUE = "NOK" THEN
                          DO:
                             {include/i-erro.i}
                          END.
                          ELSE
                          DO:
                              ASSIGN lOpen099d = YES.
                          END.
                      END.
                      ELSE
                      DO:
                          IF  p-poupanca = yes THEN 
                              ASSIGN v_poupanca =
                               "******* CONTA POUPANCA *****~***".
                          ELSE 
                              ASSIGN v_poupanca = " ".

                          IF  DEC(v_valor1) > 0 THEN DO:
                              RUN grava-cheque-cooperativa
                                  IN h-b1crap98(INPUT v_coop,
                                                INPUT INT(v_pac),
                                                INPUT INT(v_caixa),
                                                INPUT INT(v_docto)).
                               ASSIGN vh_foco = "13".
                           END.

                          IF  get-value("sok") <> "" THEN DO:
                              RUN dbo/b1crap99.p PERSISTENT SET h-b1crap99.
                              MESSAGE 
                              "CHAMA critica-cheque-cooperativa-autenticado".
                              RUN critica-cheque-cooperativa-autenticado 
                                  IN h-b1crap99(INPUT v_coop,
                                                INPUT INT(v_pac),
                                                INPUT INT(v_caixa),
                                                INPUT NO,
                                                INPUT YES).
                              DELETE PROCEDURE h-b1crap99.
                              IF RETURN-VALUE = "NOK" THEN
                              DO:
                                 {include/i-erro.i}
                              END.
                              ELSE
                              DO:
                                  ASSIGN l-houve-erro = NO.
                                  DO TRANSACTION:

                                     RUN estorna-cheque-com-captura
                                        IN h-b1crap98 (INPUT  v_coop,
                                                       INPUT  v_pac, 
                                                       INPUT  v_caixa,
                                                       INPUT  v_operador,
                                                       INPUT  v_conta,
                                                       INPUT  v_docto,
                                                       INPUT  DEC(v_valor),
                                                       INPUT  DEC(v_valor1),
                                                       INPUT  v_chequesmenores,
                                                       INPUT  v_chequesmaiores,
                                                  INPUT  v_chequesmenoresfora,
                                                  INPUT  v_chequesmaioresfora,
                                                  OUTPUT p-valor).

                                     IF  RETURN-VALUE = "OK" THEN  DO:
                                         RUN grava-autenticacao 
                                          IN h-b1crap00 
                                              (INPUT v_coop,
                                               INPUT INT(v_pac),
                                               INPUT INT(v_caixa),
                                               INPUT v_operador,
                                               INPUT DEC(p-valor),
                                               INPUT DEC(v_docto),
                                               INPUT NO, /* YES(PG),NO(REC) */
                                               INPUT "1",
                                               INPUT yes,   /* Estorno  */
                                               INPUT "700", /* Historico */ 
                                               INPUT ?, /* Data off-line */
                                               INPUT 0, /* Sequencia off-line */
                                               INPUT 0, /* Hora off-line */
                                               INPUT 0, /* Seq.orig.Off-line */
                                               OUTPUT p-literal,
                                               OUTPUT p-ult-sequencia,
                                               OUTPUT p-registro).
                                     END.

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
                                             ASSIGN w-craperr.cdagenci  
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
                                  END.
                                  IF  l-houve-erro = YES  THEN DO:
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
                                  IF  l-houve-erro = NO THEN do:     

                                      {&OUT}
          '<script>window.open("autentica.html?
           v_plit=" + "' p-literal '" + 
          "&v_pseq=" + "' p-ult-sequencia '" +
          "&v_prec=" +
          "NO"  +  
          "&v_psetcook=" +  
          "yes","waut","width=250,height=145,
          scrollbars=auto,alwaysRaised=true")
          </script>'.

                                      FOR EACH crapmdw EXCLUSIVE-LOCK
                                         WHERE crapmdw.cdcooper =
                                                 crapcop.cdcooper  AND
                                               crapmdw.cdagenci = 
                                                 INT(v_pac)        AND
                                               crapmdw.nrdcaixa = 
                                                 INT(v_caixa):
                                          DELETE crapmdw.
                                      END.

                                      ASSIGN  v_docto              = " "
                                              v_conta              = " "  
                                              v_nome               = " "  
                                              v_poupanca           = " "
                                              v_identifica         = " "
                                              v_valor              = " "
                                              v_valor1             = " "
                                              v_chequesmenores     = " " 
                                              v_chequesmaiores     = " " 
                                              v_chequesmenoresfora = " "
                                              v_chequesmaioresfora = " ".

                                  END. 

                              END.

                          END.
                      END.
               END.
               DELETE PROCEDURE h-b1crap98.
           END.
       END.
   END.
   DELETE PROCEDURE h-b1crap00.

    RUN displayFields.
   
    RUN enableFields.

    RUN outputFields.
    

    /*Robinson Rafael Koprowski*/
    IF lOpen099d THEN DO:
        {&OUT}

        '<script language=JavaScript>' SKIP

        'var habilita = new CriaArray(window.document.forms[0].elements.length)~;' SKIP

        'function desabilitaForm() ~{' SKIP
        '  for (i = 0; i < window.document.forms[0].elements.length; i++) ~{' S~KIP
        '    habilita[i] = window.document.forms[0].elements[i].disabled;' SKIP
        '    window.document.forms[0].elements[i].disabled=true;' SKIP
        '  ~}' SKIP
        '~}' SKIP

        'function reabilitaForm() ~{' SKIP
        '  for (i = 0; i < window.document.forms[0].elements.length; i++) ~{' S~KIP
        '    window.document.forms[0].elements[i].disabled = habilita[i];' SKIP
        '  ~}' SKIP
        '~}' SKIP

        'desabilitaForm();' SKIP

        'window.open("crap099d.p?v_pconta=" + 
        "'get-value("v_conta")'" +
        "&v_pnome=" + 
        "' v_nome '" +
        "&v_ppoup=" +
        "' v_poupanca '" +
        "&v_pidentifica=" +
        "' v_identifica '" +
        "&v_pvalor=" + 
        "' v_valor '" +
        "&v_pvalor1=" + 
        "' STRING(de_valor1) '" +
        "&v_pestorno=" +         "YES","wautcoop",
        "width=500,height=290,scrollbars=auto,alwaysRaised=true")
        </script>'.
    END.


  END. /* Form has been submitted. */
 
  /* REQUEST-METHOD = GET */ 
  ELSE DO:

    ASSIGN vh_foco = "7".

   ASSIGN v_data1 = IF dt-menor-praca  <> ? THEN 
                    STRING(dt-menor-praca,"99/99/9999") ELSE ""
          v_data2 = IF dt-maior-praca  <> ? THEN 
                    STRING(dt-maior-praca,"99/99/9999") ELSE ""
          v_data3 = IF dt-menor-fpraca <> ? THEN
                    STRING(dt-menor-fpraca,"99/99/9999") ELSE ""
          v_data4 = IF dt-maior-fpraca <> ? THEN
                    STRING(dt-maior-fpraca,"99/99/9999") ELSE "".

    FOR EACH crapmdw EXCLUSIVE-LOCK
       WHERE crapmdw.cdcooper   = crapcop.cdcooper
         AND crapmdw.cdagenci   = INT(v_pac)
         AND crapmdw.nrdcaixa   = INT(v_caixa):
        DELETE crapmdw.
    END.
    FOR EACH crapmrw EXCLUSIVE-LOCK
       WHERE crapmrw.cdcooper   = crapcop.cdcooper
         AND crapmrw.cdagenci   = INT(v_pac)
         AND crapmrw.nrdcaixa   = INT(v_caixa):
        DELETE crapmrw.
    END.

    RUN displayFields.

    RUN enableFields.

    RUN outputFields.
  END. 
  
  IF AnyMessage() THEN 
  DO:
     ShowDataMessages().
  END.
 
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME







