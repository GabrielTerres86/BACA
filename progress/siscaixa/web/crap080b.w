/*..............................................................................

   Programa: siscaixa/web/crap080b.w
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
       FIELD v_codbarras AS CHARACTER FORMAT "X(256)":U 
       FIELD v_coop AS CHARACTER FORMAT "X(256)":U 
       FIELD v_data AS CHARACTER FORMAT "X(256)":U 
       FIELD v_msg AS CHARACTER FORMAT "X(256)":U 
       FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
       FIELD v_pac AS CHARACTER FORMAT "X(256)":U 
       FIELD v_tppagmto    AS CHARACTER FORMAT "X(256)":U
       FIELD v_valor AS CHARACTER FORMAT "X(256)":U 
       FIELD v_valor1 AS CHARACTER FORMAT "X(256)":U
       FIELD v_cod AS CHARACTER FORMAT "X(256)":U
       FIELD v_senha AS CHARACTER FORMAT "X(256)":U
       FIELD hdnValorAcima AS CHARACTER FORMAT "X(256)":U.


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


DEF VAR v_pcmc7      AS CHAR NO-UNDO.
DEF VAR v_pvalor     AS CHAR NO-UNDO.
DEF VAR v_pvalor1    AS CHAR NO-UNDO.
DEF VAR c_codbarras  AS CHARACTER  NO-UNDO.
DEF VAR aux_valor    AS DECIMAL    NO-UNDO.
DEF VAR p_valor      AS DEC        NO-UNDO.
DEF VAR p_dtvencto   AS DATE       NO-UNDO.
DEF VAR c_dtvencto   AS CHAR       NO-UNDO.
DEF VAR de_tit1      AS DECIMAL    NO-UNDO.
DEF VAR de_tit2      AS DECIMAL    NO-UNDO.
DEF VAR de_tit3      AS DECIMAL    NO-UNDO.
DEF VAR de_tit4      AS DECIMAL    NO-UNDO.
DEF VAR de_tit5      AS DECIMAL    NO-UNDO.

DEF VAR aux_dia      AS INTE       NO-UNDO.
DEF VAR aux_mes      AS INTE       NO-UNDO.
DEF VAR aux_ano      AS INTE       NO-UNDO.

DEFINE VARIABLE vr_cdcriticValorAcima AS INTEGER NO-UNDO INIT 0.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE F:/web/crap080b.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS ab_unmap.radio ab_unmap.vh_foco ab_unmap.v_caixa ab_unmap.v_cmc7 ab_unmap.v_codbarras ab_unmap.v_coop ab_unmap.v_data ab_unmap.v_msg ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_tppagmto ab_unmap.v_valor ab_unmap.v_valor1 ab_unmap.v_cod ab_unmap.v_senha ab_unmap.hdnValorAcima
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.radio ab_unmap.vh_foco ab_unmap.v_caixa ab_unmap.v_cmc7 ab_unmap.v_codbarras ab_unmap.v_coop ab_unmap.v_data ab_unmap.v_msg ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_tppagmto ab_unmap.v_valor ab_unmap.v_valor1 ab_unmap.v_cod ab_unmap.v_senha ab_unmap.hdnValorAcima

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
                    "radio 1","1",
"radio 2","2"
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
     ab_unmap.v_tppagmto AT ROW 1 COL 1 HELP
          "" NO-LABEL VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS 
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
     ab_unmap.v_cod AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_senha AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.hdnValorAcima AT ROW 1 COL 1 HELP
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
          FIELD v_codbarras AS CHARACTER FORMAT "X(256)":U 
          FIELD v_coop AS CHARACTER FORMAT "X(256)":U 
          FIELD v_data AS CHARACTER FORMAT "X(256)":U 
          FIELD v_msg AS CHARACTER FORMAT "X(256)":U 
          FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
          FIELD v_pac AS CHARACTER FORMAT "X(256)":U 
          FIELD v_tppagmto AS CHARACTER FORMAT "X(256)":U 
          FIELD v_valor AS CHARACTER FORMAT "X(256)":U 
          FIELD v_valor1 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_cod AS CHARACTER FORMAT "X(256)":U 
          FIELD v_senha AS CHARACTER FORMAT "X(256)":U
          FIELD hdnValorAcima AS CHARACTER FORMAT "X(256)":U
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
/* SETTINGS FOR fill-in ab_unmap.v_codbarras IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_coop IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_data IN FRAME Web-Frame
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
/* SETTINGS FOR fill-in ab_unmap.v_cod IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_senha IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.hdnValorAcima IN FRAME Web-Frame
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
    ("v_tppagmto":U,"ab_unmap.v_tppagmto":U,ab_unmap.v_tppagmto:HANDLE IN FRAME {&FRAME-NAME}).    
  RUN htmAssociate
    ("v_valor":U,"ab_unmap.v_valor":U,ab_unmap.v_valor:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_valor1":U,"ab_unmap.v_valor1":U,ab_unmap.v_valor1:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_cod":U,"ab_unmap.v_cod":U,ab_unmap.v_cod:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_senha":U,"ab_unmap.v_senha":U,ab_unmap.v_senha:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("hdnValorAcima":U,"ab_unmap.hdnValorAcima":U,ab_unmap.hdnValorAcima:HANDLE IN FRAME {&FRAME-NAME}).    
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
     
  DEF VAR aux_des_erro    AS CHAR       NO-UNDO.
  DEF VAR aux_dscritic    AS CHAR       NO-UNDO.
  DEF VAR aux_inssenha    AS INTEGER    NO-UNDO.
  DEF VAR hdnValorAcima   AS  CHAR      NO-UNDO.
     
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
          v_cmc7    = get-value("v_pcmc7")
          v_tppagmto = get-value("v_tppagmto")
          v_valor   = STRING(DEC(get-value("v_pvalor")),"zzz,zzz,zzz,zz9.99")
          v_valor1  = STRING(DEC(get-value("v_pvalor1")),"zzz,zzz,zzz,zz9.99").
        
      ASSIGN aux_valor = DEC(v_valor) + DEC(v_valor1).

      IF  get-value("cancela") <> "" THEN DO:
          ASSIGN radio       = "1"
                 v_codbarras = ""
				 v_tppagmto = "0"
                 vh_foco     = "12".
      END.
      ELSE DO:

      RUN validar-valor-limite (INPUT v_coop,
                                  INPUT STRING(ab_unmap.v_cod),
                                  INPUT INT(v_pac),
                                  INPUT INT(v_caixa),
                                  INPUT (DEC(v_valor) + DEC(v_valor1)),
                                  INPUT STRING(ab_unmap.v_senha),
                                  OUTPUT aux_des_erro,
                                  OUTPUT aux_dscritic,
                                  OUTPUT aux_inssenha).
         IF RETURN-VALUE = 'NOK' THEN  
          DO:
             {include/i-erro.i}
          END.
         ELSE
           DO:

          IF  get-value("manual") <> "" THEN  DO:
              IF  get-value("radio") = "1" THEN DO: /* Titulo */
                  ASSIGN p_valor = aux_valor.
                  ASSIGN c_dtvencto = "".
                  {&OUT}             
                      '<script>window.location =
                      "crap080c.html?v_pradio=" +
                      "'get-value("radio")'" + 
                      "&v_tppagmto="   + 
                      "' v_tppagmto '"  +
                      "&v_pvalor="   + 
                      "' v_valor '"  +
                      "&v_pvalor1="  +
                      "' v_valor1 '" +
                      "&v_pcmc7="    +
                      "' v_cmc7 '"   +
                      "&v_pbarras="     + 
                      "'get-value("v_codbarras")'"   +
                      "&v_pvalor_inf="  +
                      "' p_valor '"     +
                      "&v_pdata_inf="  +
                      "' c_dtvencto '"
                      </script>'.
              END.
              ELSE DO:
                   ASSIGN p_valor = aux_valor.
            
                   {&OUT}                 /* Fatura Manual */
                      '<script>window.location =
                      "crap080d.html?v_pradio=" +
                      "'get-value("radio")'" + 
                      "&v_tppagmto="              +
                      "' v_tppagmto '"             +
                      "&v_pvalor="              +
                      "' v_valor '"             +
                      "&v_pvalor1="             +
                      "' v_valor1 '"            +
                      "&v_pcmc7="               +
                      "' v_cmc7 '"              +
                      "&v_pbarras="             +
                      "'get-value("v_codbarras")'"   +
                      "&v_pvalor_inf="          +
                      "' p_valor '"
                      </script>'.
              END.
          END.
          ELSE DO:
   
              RUN dbo/b1crap14.p PERSISTENT SET h_b1crap14.
              
              RUN valida-codigo-barras 
                           IN h_b1crap14(INPUT v_coop,
                                         INPUT 0,
                                         INPUT 0,
                                         INPUT v_operador,
                                         INPUT INT(v_pac),
                                         INPUT INT(v_caixa),
                                         INPUT get-value("v_codbarras")).
              DELETE PROCEDURE h_b1crap14.
    
             
              IF  RETURN-VALUE = "NOK" THEN DO:
                  {include/i-erro.i}
                  ASSIGN vh_foco = "11".
              END.
              ELSE DO:  
                  ASSIGN c_codbarras = get-value("v_codbarras").
    
                  IF  get-value("radio") = "1" THEN 
                      RUN processa_titulos.
                  ELSE 
                      RUN processa_faturas.
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
    
    IF vr_cdcriticValorAcima = 1 THEN
       {&out} '<script>document.getElementById("hdnValorAcima").value = 1;</script>'.
     ELSE
       {&out} '<script>document.getElementById("hdnValorAcima").value = 0;</script>'.       
     
     {&out} '<script>habilitarCampos();</script>'.
    
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
          vh_foco    = "12".
         
    RUN displayFields.

    /* STEP 2b -
     * Enable objects that should be enabled. */
    RUN enableFields.

    /* STEP 2c -
     * OUTPUT the Progress from buffer to the WEB stream. */
    RUN outputFields.
    
    IF vr_cdcriticValorAcima = 1 THEN
       {&out} '<script>document.getElementById("hdnValorAcima").value = 1;</script>'.
     ELSE
       {&out} '<script>document.getElementById("hdnValorAcima").value = 0;</script>'.       
     
     {&out} '<script>habilitarCampos();</script>'.
    
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




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE processa_faturas w-html 
PROCEDURE processa_faturas :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    FIND FIRST ab_unmap.

   
    RUN dbo/b1crap80.p PERSISTENT SET h_b1crap80.

    RUN retorna-valores-fatura IN h_b1crap80(INPUT v_coop,
                                             INPUT v_operador,
                                             INPUT INT(v_pac),
                                             INPUT INT(v_caixa),
                                             INPUT 0,
                                             INPUT 0,
                                             INPUT 0,
                                             INPUT 0,
                                             INPUT-OUTPUT c_codbarras,
                                             OUTPUT p_valor).
    DELETE PROCEDURE h_b1crap80.

    IF  RETURN-VALUE = "NOK" THEN DO:
        {include/i-erro.i}
        ASSIGN v_codbarras = "".
        ASSIGN vh_foco = "11".
    END.

    ELSE  DO:
        IF  p_valor = 0 THEN
            ASSIGN p_valor = aux_valor.
            
       {&OUT}                 /* Fatura Manual */
        '<script>window.location =
                 "crap080d.html?v_pradio=" +
                 "'get-value("radio")'" + 
                 "&v_tppagmto="            +
                 "' v_tppagmto '"          +
                 "&v_pvalor="              +
                 "' v_valor '"             +
                 "&v_pvalor1="             +
                 "' v_valor1 '"            +
                 "&v_pcmc7="               +
                 "' v_cmc7 '"              +
                 "&v_pbarras="             +
                 "'get-value("v_codbarras")'"   +
                 "&v_pvalor_inf="          +
                 "' p_valor '"
          </script>'.
    END.

END PROCEDURE.
 
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE processa_titulos w-html 
PROCEDURE processa_titulos :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    FIND FIRST ab_unmap.

    ASSIGN de_tit1     = 0
           de_tit2     = 0
           de_tit3     = 0
           de_tit4     = 0            
           de_tit5     = 0.
   
     RUN dbo/b1crap80.p PERSISTENT SET h_b1crap80.

     RUN retorna-valores-titulo IN h_b1crap80(
                                             INPUT v_coop,
                                             INPUT v_operador,
                                             INPUT int(v_pac),
                                             INPUT int(v_caixa),
                                             INPUT-OUTPUT de_tit1,
                                             INPUT-OUTPUT de_tit2,
                                             INPUT-OUTPUT de_tit3,
                                             INPUT-OUTPUT de_tit4,
                                             INPUT-OUTPUT de_tit5,
                                             INPUT-OUTPUT c_codbarras,
                                             OUTPUT p_valor,
                                             OUTPUT p_dtvencto).
     DELETE PROCEDURE h_b1crap80.

    IF  RETURN-VALUE = "NOK" THEN DO:
        {include/i-erro.i}
        ASSIGN v_codbarras = "".
        ASSIGN vh_foco = "11".
    END.
    ELSE  DO:
         IF  p_valor = 0 THEN
            ASSIGN p_valor = aux_valor.

         IF p_dtvencto <> ? THEN 
            ASSIGN aux_dia    = DAY(p_dtvencto)
                   aux_mes    = MONTH(p_dtvencto)
                   aux_ano    = YEAR(p_dtvencto)
                   c_dtvencto = STRING(aux_dia,"99") + 
                                STRING(aux_mes,"99") +
                                STRING(aux_ano,"9999").
         ELSE
            ASSIGN c_dtvencto = " ". 
    
        {&OUT}             
        '<script>window.location =
              "crap080c.html?v_pradio=" +
              "'get-value("radio")'" + 
              "&v_tppagmto="   + 
              "' v_tppagmto '"  +
              "&v_pvalor="   + 
              "' v_valor '"  +
              "&v_pvalor1="  +
              "' v_valor1 '" +
              "&v_pcmc7="    +
              "' v_cmc7 '"   +
              "&v_pbarras="     + 
              "'get-value("v_codbarras")'"   +
              "&v_pvalor_inf="  +
              "' p_valor '"     +
             "&v_pdata_inf="   +
              "' c_dtvencto '"
          </script>'.
    
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE validar-valor-limite w-html 

/* valida o valor recebido como parâmetro com o limite da agencia / cooperativa e solicita senha do coordenador se for maior */
PROCEDURE validar-valor-limite:

    DEF INPUT PARAM par_nmrescop  AS CHARACTER                       NO-UNDO.
    DEF INPUT PARAM par_cdoperad  AS CHARACTER                       NO-UNDO.
    DEF INPUT PARAM par_cdagenci  AS INTEGER                         NO-UNDO.
    DEF INPUT PARAM par_nrocaixa  AS INTEGER                         NO-UNDO.
    DEF INPUT PARAM par_vltitfat  AS DECIMAL                         NO-UNDO.
    DEF INPUT PARAM par_senha     AS CHARACTER                       NO-UNDO.
    DEF OUTPUT PARAM par_des_erro AS CHARACTER                       NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHARACTER                       NO-UNDO.
    DEF OUTPUT PARAM par_inssenha AS INTEGER                         NO-UNDO.

    DEF VAR aux_inssenha          AS INTEGER                         NO-UNDO.
    DEF VAR h_b1crap80            AS HANDLE                          NO-UNDO.
    
    RUN dbo/b1crap80.p PERSISTENT SET h_b1crap80.
                           
    RUN validar-valor-limite IN h_b1crap80(INPUT par_nmrescop,
                                           INPUT par_cdoperad,
                                           INPUT par_cdagenci,
                                           INPUT par_nrocaixa,
                                           INPUT par_vltitfat,
                                           INPUT par_senha,
                                           OUTPUT par_des_erro,
                                           OUTPUT par_dscritic,
                                           OUTPUT par_inssenha).
                                          
    DELETE PROCEDURE h_b1crap80.
    
    IF RETURN-VALUE = 'NOK' THEN  
     DO:
        
        ASSIGN vr_cdcriticValorAcima = 1.
     
        RETURN "NOK".
     END.
     
     ASSIGN vr_cdcriticValorAcima = 0.
        
    RETURN "OK".
END PROCEDURE.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

