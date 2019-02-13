/*..............................................................................

   Programa: siscaixa/web/crap080d.w
   Sistema :                                        
   Sigla   :     
   Autor   : 
   Data    :                                    Ultima atualizacao: 02/01/2019
   
   Dados referentes ao programa:

   Frequencia: 
   Objetivo  : 

   Alteracoes:      22/08/2007 - Incluido parametros nas chamadas para a BO
                                 valida-codigo-barras do programa dbo/b1crap14.p
                                 (Elton).

                    18/12/2008 - Ajustes para unificacao dos bancos de dados
                                 (Evandro).
                                 
                    05/09/2013 - Nova forma de chamar as agências, de PAC agora
                                 a escrita será PA (André Euzébio - Supero).
                                 
                    29/11/2013 - Adicionado "DO TRANSACTION" no CREATE craperr
                                 na procedure gera-autenticacao. (Reinert) 

                    13/12/2013 - Adicionado validate para tabela craperr (Tiago).
                    
                    02/01/2019 - Projeto 510 - Incluí tipo de pagamento e validação do valor máximo para pagto em espécie. (Daniel - Envolti)
..............................................................................*/
    &ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD radio AS CHARACTER 
       FIELD vh_foco AS CHARACTER FORMAT "X(256)":U 
       FIELD v_caixa AS CHARACTER FORMAT "X(256)":U 
       FIELD v_cmc7 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_coop AS CHARACTER FORMAT "X(256)":U 
       FIELD v_data AS CHARACTER FORMAT "X(256)":U 
       FIELD v_fat1 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_fat2 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_fat3 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_fat4 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_msg AS CHARACTER FORMAT "X(256)":U 
       FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
       FIELD v_pac AS CHARACTER FORMAT "X(256)":U 
       FIELD v_tppagmto    AS CHARACTER FORMAT "X(256)":U
       FIELD v_valor AS CHARACTER FORMAT "X(256)":U 
       FIELD v_valor1 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_valordoc AS CHARACTER FORMAT "X(256)":U .


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


DEFINE VARIABLE h_b1crap80 AS HANDLE     NO-UNDO.
DEFINE VARIABLE h_b1crap14 AS HANDLE     NO-UNDO.
DEFINE VARIABLE h_b1crap00 AS HANDLE     NO-UNDO.


DEF VAR v_pcmc7      AS CHAR NO-UNDO.
DEF VAR v_pvalor     AS CHAR NO-UNDO.
DEF VAR v_pvalor1    AS CHAR NO-UNDO.
DEF VAR v_pradio     AS CHAR NO-UNDO.
DEF VAR v_pbarras    AS CHAR NO-UNDO.
DEF VAR v_pvalor_inf AS CHAR NO-UNDO.

DEF VAR c_codbarras  AS CHARACTER  NO-UNDO.
DEF VAR p_codbarras  AS CHARACTER  NO-UNDO.

DEF VAR aux_valor    AS DECIMAL    NO-UNDO.

DEF VAR p_valor      AS DEC        NO-UNDO.
DEF VAR p-literal    AS CHAR       NO-UNDO.
DEF VAR p-literal-cop AS CHAR      NO-UNDO.
DEF VAR p-ult-sequencia AS INTE    NO-UNDO.
DEF VAR p-histor     AS INTEGER    NO-UNDO.
DEF VAR p-pg         AS LOGICAL    NO-UNDO.
DEF VAR p-docto      AS INTEGER    NO-UNDO.
DEF VAR p-dsautent   AS CHAR       NO-UNDO.
DEF VAR p-autchave   AS INTE       NO-UNDO.
DEF VAR p-cdchave    AS CHAR       NO-UNDO.
DEF VAR p-registro-crapcbb AS RECID      NO-UNDO.
DEF VAR p-registro         AS RECID      NO-UNDO.
DEF VAR l-houve-erro    AS LOG           NO-UNDO.
                                      
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

&Scoped-define WEB-FILE F:/web/crap080d.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS ab_unmap.radio ab_unmap.vh_foco ab_unmap.v_caixa ab_unmap.v_cmc7 ab_unmap.v_coop ab_unmap.v_data ab_unmap.v_fat1 ab_unmap.v_fat2 ab_unmap.v_fat3 ab_unmap.v_fat4 ab_unmap.v_msg ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_tppagmto ab_unmap.v_valor ab_unmap.v_valor1 ab_unmap.v_valordoc 
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.radio ab_unmap.vh_foco ab_unmap.v_caixa ab_unmap.v_cmc7 ab_unmap.v_coop ab_unmap.v_data ab_unmap.v_fat1 ab_unmap.v_fat2 ab_unmap.v_fat3 ab_unmap.v_fat4 ab_unmap.v_msg ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_tppagmto ab_unmap.v_valor ab_unmap.v_valor1 ab_unmap.v_valordoc 

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
                   "radio 3", "3":U,
                   "radio 1", "1":U,
                   "radio 2", "2":U
          SIZE 20 BY 3
     ab_unmap.vh_foco AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_caixa AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_cmc7 AT ROW 1 COL 1 HELP
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
     ab_unmap.v_fat1 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_fat2 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_fat3 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_fat4 AT ROW 1 COL 1 HELP
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
     ab_unmap.v_tppagmto AT ROW 1 COL 1 HELP
          "" NO-LABEL VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS 
           "v_tppagmto 2", "2":U,
           "v_tppagmto 0", "0":U,
           "v_tppagmto 1", "1":U 
           SIZE 20 BY 2
     ab_unmap.v_valor AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_valor1 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_valordoc AT ROW 1 COL 1 HELP
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
          FIELD radio AS CHARACTER 
          FIELD vh_foco AS CHARACTER FORMAT "X(256)":U 
          FIELD v_caixa AS CHARACTER FORMAT "X(256)":U 
          FIELD v_cmc7 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_coop AS CHARACTER FORMAT "X(256)":U 
          FIELD v_data AS CHARACTER FORMAT "X(256)":U 
          FIELD v_fat1 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_fat2 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_fat3 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_fat4 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_msg AS CHARACTER FORMAT "X(256)":U 
          FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
          FIELD v_pac AS CHARACTER FORMAT "X(256)":U 
          FIELD v_tppagmto AS CHARACTER FORMAT "X(256)":U 
          FIELD v_valor AS CHARACTER FORMAT "X(256)":U 
          FIELD v_valor1 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_valordoc AS CHARACTER FORMAT "X(256)":U 
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
/* SETTINGS FOR radio-set ab_unmap.radio IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR fill-in ab_unmap.vh_foco IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_caixa IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_cmc7 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_coop IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_data IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_fat1 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_fat2 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_fat3 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_fat4 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_msg IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_operador IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_pac IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_tppagmto IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_valor IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_valor1 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_valordoc IN FRAME Web-Frame
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
    ("v_cmc7":U,"ab_unmap.v_cmc7":U,ab_unmap.v_cmc7:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_coop":U,"ab_unmap.v_coop":U,ab_unmap.v_coop:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_data":U,"ab_unmap.v_data":U,ab_unmap.v_data:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_fat1":U,"ab_unmap.v_fat1":U,ab_unmap.v_fat1:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_fat2":U,"ab_unmap.v_fat2":U,ab_unmap.v_fat2:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_fat3":U,"ab_unmap.v_fat3":U,ab_unmap.v_fat3:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_fat4":U,"ab_unmap.v_fat4":U,ab_unmap.v_fat4:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_msg":U,"ab_unmap.v_msg":U,ab_unmap.v_msg:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_operador":U,"ab_unmap.v_operador":U,ab_unmap.v_operador:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_pac":U,"ab_unmap.v_pac":U,ab_unmap.v_pac:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_tppagmto":U,"ab_unmap.v_tppagmto":U,ab_unmap.v_tppagmto:HANDLE IN FRAME {&FRAME-NAME}).    
  RUN htmAssociate
    ("v_valor":U,"ab_unmap.v_valor":U,ab_unmap.v_valor:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_valor1":U,"ab_unmap.v_valor1":U,ab_unmap.v_valor1:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_valordoc":U,"ab_unmap.v_valordoc":U,ab_unmap.v_valordoc:HANDLE IN FRAME {&FRAME-NAME}).
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
     
     ASSIGN
          v_cmc7     = get-value("v_pcmc7")
          v_tppagmto = get-value("v_tppagmto")
          v_valor    = STRING(DEC(get-value("v_pvalor")),"zzz,zzz,zzz,zz9.99")
          v_valor1   = STRING(DEC(get-value("v_pvalor1")),"zzz,zzz,zzz,zz9.99")
          radio       = get-value("v_pradio")
          c_codbarras = get-value("v_pbarras").

     IF c_codbarras <> " " THEN
        ASSIGN
           v_valordoc = STRING(DEC(get-value("v_pvalor_inf"))
                       ,"zzz,zzz,zzz,zz9.99")
           v_fat1 = STRING(DEC(SUBSTR(c_codbarras,1,11)),"99999,99999,9")
           v_fat2 = STRING(DEC(SUBSTR(c_codbarras,12,11)),"99999,99999,9")
           v_fat3 = STRING(DEC(SUBSTR(c_codbarras,23,11)),"99999,99999,9")
           v_fat4 = STRING(DEC(SUBSTR(c_codbarras,34,11)),"99999,99999,9").

     ASSIGN vh_foco = "11".
  
     ASSIGN aux_valor = DEC(v_valor) + DEC(v_valor1).

     
     IF  get-value("cancela") <> "" THEN 
     DO:
         ASSIGN v_fat1      = ""
                v_fat2      = ""
                v_fat3      = ""
                v_fat4      = ""
                v_valordoc  = "0,00".
     END.
     ELSE DO:
         
         IF   c_codbarras = " " THEN
              DO:
                RUN valida_caracteres (INPUT get-value("v_fat1"),
                                      OUTPUT v_fat1).
                RUN valida_caracteres (INPUT get-value("v_fat2"),
                                      OUTPUT v_fat2).
                RUN valida_caracteres (INPUT get-value("v_fat3"),
                                      OUTPUT v_fat3).
                RUN valida_caracteres (INPUT get-value("v_fat4"),
                                      OUTPUT v_fat4).
              ASSIGN p_codbarras =
                   SUBSTR(STRING(DEC(v_fat1),"999999999999"),1,11) + 
                   SUBSTR(STRING(DEC(v_fat2),"999999999999"),1,11) + 
                   SUBSTR(STRING(DEC(v_fat3),"999999999999"),1,11) + 
                   SUBSTR(STRING(DEC(v_fat4),"999999999999"),1,11).
              END.
        ELSE
             ASSIGN p_codbarras = c_codbarras.

        RUN dbo/b1crap14.p PERSISTENT SET h_b1crap14.
    
        RUN valida-codigo-barras IN h_b1crap14(INPUT v_coop,
                                               INPUT 0,
                                               INPUT 0,
                                               INPUT v_operador,
                                               INPUT INT(v_pac),
                                               INPUT INT(v_caixa),
                                               INPUT p_codbarras).
                 
        DELETE PROCEDURE h_b1crap14.

        IF RETURN-VALUE = "NOK" THEN  DO:
           {include/i-erro.i}
           ASSIGN v_fat1 = "" 
                  v_fat2 = ""
                  v_fat3 = ""
                  v_fat4 = "".
           ASSIGN vh_foco = "11".
        END.
        ELSE DO:
          
           RUN dbo/b1crap80.p PERSISTENT SET h_b1crap80.
 
           RUN retorna-valores-fatura 
                            IN h_b1crap80(INPUT v_coop,
                                          INPUT v_operador,
                                          INPUT INT(v_pac),
                                          INPUT INT(v_caixa),
                                          INPUT 0,
                                          INPUT 0,
                                          INPUT 0,
                                          INPUT 0,
                                          INPUT-OUTPUT p_codbarras,
                                          OUTPUT p_valor).
         
            DELETE PROCEDURE h_b1crap80.

            IF  RETURN-VALUE = "NOK" THEN DO:
                {include/i-erro.i}
                ASSIGN v_fat1 = "" 
                       v_fat2 = ""
                       v_fat3 = ""
                       v_fat4 = "".
                ASSIGN vh_foco = "11".
            END.
            ELSE  DO:
                IF  p_valor = 0 THEN
                    ASSIGN p_valor  = aux_valor.
                
                ASSIGN  v_valordoc =
                        STRING(dec(p_valor),"zzz,zzz,zzz,zz9.99").
                
                IF  get-value("OK") <> " " THEN  DO:
                             
                    RUN dbo/b1crap80.p PERSISTENT SET h_b1crap80.
    
                    RUN verifica-valor-desconto 
                              IN h_b1crap80(INPUT v_coop,
                                            INPUT INT(v_pac),    
                                            INPUT INT(v_caixa),
                                            INPUT DEC(v_valor),
                                            INPUT DEC(v_valor1),
                                            INPUT DEC(v_valordoc),
                                            INPUT 0).
                  
                    DELETE PROCEDURE h_b1crap80.

                    IF  RETURN-VALUE = "NOK" THEN DO:
                        {include/i-erro.i}
                        ASSIGN vh_foco = "17".
                    END.
                    ELSE DO:
                         
                        /*  Correspondente  Bancario  */
                        
                        RUN dbo/b1crap80.p PERSISTENT SET h_b1crap80.
    
                        RUN gera-arquivo-correspondente 
                              IN h_b1crap80(INPUT v_coop,
                                            INPUT v_operador,
                                            INPUT int(v_pac),    
                                            INPUT int(v_caixa),
                                            INPUT p_codbarras,
                                            INPUT v_cmc7,
                                            INPUT DEC(v_valor),
                                            INPUT DEC(v_valor1),
                                            INPUT DEC(v_valordoc),
                                            INPUT 0, /* Desconto */
                                            INPUT "", /* Data Vencimento */ 
                                            INPUT 2,  /* Faturas */
                                            OUTPUT p-dsautent,
                                            OUTPUT p-autchave,
                                            OUTPUT p-cdchave).
                        DELETE PROCEDURE h_b1crap80.
                              
                        IF  RETURN-VALUE = "NOK"  THEN DO:
                            {include/i-erro.i}
                            ASSIGN vh_foco = "17".
                        END.
                        ELSE DO:
                         
                            RUN gera-faturas.
                            
                            IF  RETURN-VALUE = "NOK"  THEN DO:
                                {include/i-erro.i}
                                ASSIGN vh_foco = "17".
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
    
    
    ASSIGN 
          v_cmc7     = get-value("v_pcmc7")
          v_tppagmto = get-value("v_tppagmto")
          v_valor    = STRING(DEC(get-value("v_pvalor")),"zzz,zzz,zzz,zz9.99")
          v_valor1   = STRING(DEC(get-value("v_pvalor1")),"zzz,zzz,zzz,zz9.99")
          radio     = get-value("v_pradio")
          c_codbarras = get-value("v_pbarras").
    
    IF  c_codbarras <> " " THEN
        ASSIGN
           v_valordoc = STRING(DEC(get-value("v_pvalor_inf"))
                       ,"zzz,zzz,zzz,zz9.99")
           v_fat1 = STRING(DEC(SUBSTR(c_codbarras,1,11)),"99999,99999,9")
           v_fat2 = STRING(DEC(SUBSTR(c_codbarras,12,11)),"99999,99999,9")
           v_fat3 = STRING(DEC(SUBSTR(c_codbarras,23,11)),"99999,99999,9")
           v_fat4 = STRING(DEC(SUBSTR(c_codbarras,34,11)),"99999,99999,9") 
           vh_foco = "17".
    ELSE
        ASSIGN vh_foco = "11".
 
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE gera-faturas w-html 
PROCEDURE gera-faturas :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>                       
  Notes:       
------------------------------------------------------------------------------*/
    FIND FIRST ab_unmap.

    ASSIGN l-houve-erro = NO.
         
    RUN dbo/b1crap80.p PERSISTENT SET h_b1crap80.
 
    RUN gera-titulos-faturas 
                      IN h_b1crap80(INPUT v_coop,
                                    INPUT v_operador,
                                    INPUT INT(v_pac),
                                    INPUT INT(v_caixa),
                                    INPUT p_codbarras,
                                    INPUT v_cmc7,
                                    INPUT aux_valor,
                                    INPUT 0,    /* Desconto */
                                    INPUT "",   /* Data de  Vencimento */                                          INPUT 2,    /* Fatura */
                                    INPUT DEC(v_valordoc),
                                    INPUT  p-dsautent,
                                    INPUT  p-autchave,
                                    INPUT  p-cdchave,
                                    INPUT  v_tppagmto,
                                    OUTPUT p-histor,
                                    OUTPUT p-pg,    
                                    OUTPUT p-docto,
                                    OUTPUT p-registro-crapcbb).
                                    
    DELETE PROCEDURE h_b1crap80.

    RUN gera-autenticacao.
         
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


    
    
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE gera-autenticacao w-html 
PROCEDURE gera-autenticacao :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>                       
  Notes:       
------------------------------------------------------------------------------*/
    FIND FIRST ab_unmap.

   
        DO  TRANSACTION ON ERROR UNDO:
            
            RUN dbo/b1crap00.p PERSISTENT SET h_b1crap00.
            RUN grava-autenticacao 
               IN h_b1crap00 (INPUT v_coop,
                              INPUT INT(v_pac),
                              INPUT INT(v_caixa),
                              INPUT v_operador,
                              INPUT aux_valor,  /* Valor pago */
                              INPUT p-docto, 
                              INPUT p-pg, /* YES (PG), NO (REC) */
                              INPUT "1",  /* On-line            */ 
                              INPUT NO,    /* Nro estorno        */
                              INPUT p-histor, 
                              INPUT ?, /* Data off-line */
                              INPUT 0, /* Sequencia off-line */
                              INPUT 0, /* Hora off-line */
                              INPUT 0, /* Seq.orig.Off-line */
                              OUTPUT p-literal-cop,
                              OUTPUT p-ult-sequencia,
                              OUTPUT p-registro).

            DELETE PROCEDURE h_b1crap00.
            IF  RETURN-VALUE = "NOK" THEN DO:
                ASSIGN l-houve-erro = YES.
                FOR EACH w-craperr:
                    DELETE w-craperr.
                END.
                FOR EACH craperr NO-LOCK WHERE
                         craperr.cdcooper =  crapcop.cdcooper  AND 
                         craperr.cdagenci =  INT(v_pac)        AND
                         craperr.nrdcaixa =  INT(v_caixa):
                    CREATE w-craperr.
                    ASSIGN w-craperr.cdagenci   = craperr.cdagenc
                           w-craperr.nrdcaixa   = craperr.nrdcaixa
                           w-craperr.nrsequen   = craperr.nrsequen
                           w-craperr.cdcritic   = craperr.cdcritic
                           w-craperr.dscritic   = craperr.dscritic
                           w-craperr.erro       = craperr.erro.
                END.
                UNDO.
            END.     
        END.  /* do transaction */

        IF  l-houve-erro = YES  THEN DO:
            FIND FIRST w-craperr NO-LOCK NO-ERROR.
            IF  NOT AVAILABLE w-craperr THEN DO TRANSACTION:
                CREATE craperr.
                ASSIGN craperr.cdcooper   = crapcop.cdcooper
                       craperr.cdagenci   = INTE(v_pac)
                       craperr.nrdcaixa   = INTE(v_caixa)
                       craperr.nrsequen   = 1
                       craperr.cdcritic   = 0
                       craperr.dscritic   = 
                       "ERRO!!! PA ZERADO. FECHE O CAIXA E AVISE O CPD"
                       craperr.erro       = YES.
                VALIDATE craperr.
            END. /* TRANSACTION */
            ELSE
               FOR EACH w-craperr NO-LOCK WHERE
                        w-craperr.cdagenci =  INT(v_pac)   AND
                        w-craperr.nrdcaixa =  INT(v_caixa):
                   CREATE craperr.
                   ASSIGN craperr.cdcooper   = crapcop.cdcooper
                          craperr.cdagenci   = w-craperr.cdagenc
                          craperr.nrdcaixa   = w-craperr.nrdcaixa
                          craperr.nrsequen   = w-craperr.nrsequen
                          craperr.cdcritic   = w-craperr.cdcritic
                          craperr.dscritic   = w-craperr.dscritic
                          craperr.erro       = w-craperr.erro.
                   VALIDATE craperr.
               END.
 
           {include/i-erro.i}
        END.
    
        IF  l-houve-erro = NO THEN DO:   

            /* Autenticacao Cooperativa + BB */
            ASSIGN p-literal = p-literal-cop + p-dsautent.

            RUN dbo/b1crap80.p PERSISTENT SET h_b1crap80.
            RUN gera-retorno-autenticacao 
                IN h_b1crap80 (INPUT v_coop,
                               INPUT INT(v_pac),
                               INPUT INT(v_caixa),
                               INPUT v_operador,
                               INPUT "9900",     /* Autenticacao OK */
                               INPUT p-registro-crapcbb, 
                               INPUT p-ult-sequencia,
                               INPUT p-literal,
                               OUTPUT p-dsautent,
                               OUTPUT p-autchave,
                               OUTPUT p-cdchave).
                               
            DELETE PROCEDURE h_b1crap80.

            IF  RETURN-VALUE = "NOK" THEN DO:

               {include/i-erro.i}.

               {&OUT}

               '<script>alert("Pendencias existentes - Execute Pendencias");
                </script>' SKIP.
 
            END.
            ELSE DO:
         
            
               {&OUT}
               '<script>window.location =
               "crap080e.html?v_pliteral=" +
               "' p-literal-cop '"  +
               "&v_pliteral_recibo=" +
               "' p-literal '" +
               "&v_pseq=" + 
               "' p-ult-sequencia '"   
               </script>'.
             
            
            END.

            {&OUT}                    
            '<script> window.location = "crap080.html" </script>'.
        
        END.
        
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE valida_caracteres w-html 
PROCEDURE valida_caracteres:
    /* Rotina de validacao de caracteres com base parametros informados */

    /*  - par_validar  : Campo a ser validado.
        - par_validado : Retorna campo sem caracteres especiais. */

    DEF INPUT  PARAM par_validar     AS CHAR            NO-UNDO.
    DEF OUTPUT PARAM par_validado    AS CHAR            NO-UNDO.

    DEF VAR aux_numeros             AS CHAR             NO-UNDO.
    DEF VAR aux_caracteres          AS CHAR             NO-UNDO.
    DEF VAR aux_contador            AS INTE             NO-UNDO.
    DEF VAR aux_posicao             AS CHAR             NO-UNDO.
 
    ASSIGN aux_numeros  = "1234567890"
   
    aux_caracteres = aux_caracteres + aux_numeros.

    DO aux_contador = 1 TO LENGTH(par_validar):
    
        ASSIGN aux_posicao = SUBSTRING(par_validar,aux_contador,1).

        IF INDEX(aux_caracteres,aux_posicao) > 0 THEN DO:
		  par_validado = par_validado + aux_posicao.
		END.

    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
