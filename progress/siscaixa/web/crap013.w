/* .............................................................................

  Programa: crap013.w

Alteracoes: 16/12/2008 - Ajustes para unificacao dos bancos de dados (Evandro).
                       
            20/10/2010 - Incluido caminho completo nas referencias do diretorio
                         spool (Elton).
            28/09/2011 - Incluido no caminho crapcop.dsdircop da geracao do
                         relatorio em tela (Elton).
            30/09/2011 - Alterar diretorio spool para
                         /usr/coop/sistema/siscaixa/web/spool (Fernando). 
                         
            05/05/2015 - (Chamado 279202) Retirar impressao durante a abertura 
                         de caixa (Tiago Castro - RKAM).

		    23/08/2016 - Agrupamento das informacoes (M36 - Kelvin).
............................................................................. */


&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD vh_arquivo AS CHARACTER FORMAT "X(256)":U 
       FIELD v_abert AS CHARACTER FORMAT "X(256)":U 
       FIELD v_caixa AS CHARACTER FORMAT "X(256)":U 
       FIELD v_coop AS CHARACTER FORMAT "X(256)":U 
       FIELD v_data AS CHARACTER FORMAT "X(256)":U 
       FIELD v_fecha AS CHARACTER FORMAT "X(256)":U 
       FIELD v_lacre AS CHARACTER FORMAT "X(256)":U 
       FIELD v_msg AS CHARACTER FORMAT "X(256)":U 
       FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
       FIELD v_pac AS CHARACTER FORMAT "X(256)":U 
       FIELD v_saldofin AS CHARACTER FORMAT "X(256)":U 
       FIELD v_saldoini AS CHARACTER FORMAT "X(256)":U .


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
DEF TEMP-TABLE tt-consulta
    FIELD registro        AS   ROWID
    FIELD hora-abertura   LIKE crapbcx.hrabtbcx         
    FIELD hora-fechamento LIKE crapbcx.hrfecbcx   
    FIELD saldo-inicial   LIKE crapbcx.vldsdini  
    FIELD saldo-final     LIKE crapbcx.vldsdfin   
    FIELD nro-lacre       LIKE crapbcx.nrdlacre.

DEF VAR  h-b1crap00   AS HANDLE     NO-UNDO.
DEF VAR  h-b1crap13   AS HANDLE     NO-UNDO.
DEF VAR  h-b2crap13   AS HANDLE     NO-UNDO.
DEF VAR  h-b3crap13   AS HANDLE     NO-UNDO.
DEF VAR  h-b1wgen0120 AS HANDLE     NO-UNDO.

DEF VAR  p-nome-arquivo     AS CHAR NO-UNDO.
DEF VAR  p-valor-credito    AS DEC  NO-UNDO.
DEF VAR  p-valor-debito     AS DEC  NO-UNDO.
DEF VAR  p-nome-arquivo-url AS CHAR NO-UNDO.

DEF VAR aux_flgsemhi AS LOGI                                    NO-UNDO.
DEF VAR aux_vlrttcrd AS DECI                                    NO-UNDO.
DEF VAR aux_vlrttdeb AS DECI                                    NO-UNDO.
DEF VAR aux_sdfinbol LIKE crapbcx.vldsdfin                      NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                    NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                    NO-UNDO.

DEF TEMP-TABLE tt-erro NO-UNDO LIKE craperr.


/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE crap013.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS ab_unmap.vh_arquivo ab_unmap.v_msg ab_unmap.v_abert ab_unmap.v_caixa ab_unmap.v_coop ab_unmap.v_data ab_unmap.v_fecha ab_unmap.v_lacre ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_saldofin ab_unmap.v_saldoini 
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.vh_arquivo ab_unmap.v_msg ab_unmap.v_abert ab_unmap.v_caixa ab_unmap.v_coop ab_unmap.v_data ab_unmap.v_fecha ab_unmap.v_lacre ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_saldofin ab_unmap.v_saldoini 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     ab_unmap.vh_arquivo AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_msg AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_abert AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_caixa AT ROW 1 COL 1 HELP
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
     ab_unmap.v_fecha AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_lacre AT ROW 1 COL 1 HELP
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
     ab_unmap.v_saldofin AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_saldoini AT ROW 1 COL 1 HELP
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
          FIELD vh_arquivo AS CHARACTER FORMAT "X(256)":U 
          FIELD v_abert AS CHARACTER FORMAT "X(256)":U 
          FIELD v_caixa AS CHARACTER FORMAT "X(256)":U 
          FIELD v_coop AS CHARACTER FORMAT "X(256)":U 
          FIELD v_data AS CHARACTER FORMAT "X(256)":U 
          FIELD v_fecha AS CHARACTER FORMAT "X(256)":U 
          FIELD v_lacre AS CHARACTER FORMAT "X(256)":U 
          FIELD v_msg AS CHARACTER FORMAT "X(256)":U 
          FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
          FIELD v_pac AS CHARACTER FORMAT "X(256)":U 
          FIELD v_saldofin AS CHARACTER FORMAT "X(256)":U 
          FIELD v_saldoini AS CHARACTER FORMAT "X(256)":U 
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
/* SETTINGS FOR FILL-IN ab_unmap.vh_arquivo IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_abert IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_caixa IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_coop IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_data IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_fecha IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_lacre IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_msg IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_operador IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_pac IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_saldofin IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_saldoini IN FRAME Web-Frame
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
    ("vh_arquivo":U,"ab_unmap.vh_arquivo":U,ab_unmap.vh_arquivo:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_abert":U,"ab_unmap.v_abert":U,ab_unmap.v_abert:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_caixa":U,"ab_unmap.v_caixa":U,ab_unmap.v_caixa:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_coop":U,"ab_unmap.v_coop":U,ab_unmap.v_coop:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_data":U,"ab_unmap.v_data":U,ab_unmap.v_data:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_fecha":U,"ab_unmap.v_fecha":U,ab_unmap.v_fecha:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_lacre":U,"ab_unmap.v_lacre":U,ab_unmap.v_lacre:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_msg":U,"ab_unmap.v_msg":U,ab_unmap.v_msg:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_operador":U,"ab_unmap.v_operador":U,ab_unmap.v_operador:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_pac":U,"ab_unmap.v_pac":U,ab_unmap.v_pac:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_saldofin":U,"ab_unmap.v_saldofin":U,ab_unmap.v_saldofin:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_saldoini":U,"ab_unmap.v_saldoini":U,ab_unmap.v_saldoini:HANDLE IN FRAME {&FRAME-NAME}).
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
  
  RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
  RUN valida-transacao IN h-b1crap00(INPUT v_coop,
                                     INPUT v_pac,
                                     INPUT v_caixa).
  DELETE PROCEDURE h-b1crap00.
  IF RETURN-VALUE = "NOK" THEN DO:
     {include/i-erro.i}
  END.
  ELSE DO:
      
      RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.

      RUN verifica-abertura-boletim IN h-b1crap00(INPUT v_coop,
                                                  INPUT v_pac,
                                                  INPUT v_caixa,
                                                  INPUT v_operador).

      DELETE PROCEDURE h-b1crap00.
      

      IF RETURN-VALUE = "NOK" THEN DO:
         {include/i-erro.i}
      END.
      ELSE DO:
         RUN dbo/b1crap13.p PERSISTENT SET h-b1crap13.
         RUN consulta-boletim  IN h-b1crap13 (INPUT v_coop,
                                              INPUT v_operador,
                                              INPUT int(v_pac),
                                              INPUT int(v_caixa),
                                              OUTPUT TABLE tt-consulta).
         DELETE PROCEDURE h-b1crap13.
         IF  RETURN-VALUE = "NOK" THEN  DO:
             {include/i-erro.i}
         END.
             
      END.
   END.    
   
  /* Describe whether to receive FORM input for all the fields.  For example,
   * check particular input fields (using GetField in web-utilities-hdl). 
   * Here we look at REQUEST_METHOD. 
   */
  IF REQUEST_METHOD = "POST":U THEN DO:
    /* STEP 1 -
     * Copy HTML input field values to the Progress form buffer. */
    RUN inputFields.
    
    /* STEP 2 -
     * Open the database or SDO query and and fetch the first record. 
    RUN findRecords.*/
    
    /* STEP 3 -    
     * AssignFields will save the data in the frame.
     * (it automatically upgrades the lock to exclusive while doing the update)
     * 
     *  If a new record needs to be created set AddMode to true before 
        running assignFields.  
     *     setAddMode(TRUE).   */

    {include/assignfields.i} /* Colocado a chamada do assignFields dentro da include */
     FIND FIRST tt-consulta NO-LOCK NO-ERROR.
     IF  get-value("b1") <> ""  AND 
         AVAIL tt-consulta THEN DO:   
                              /* Visualizar Boletim Tela */
         
         RUN sistema/generico/procedures/b1wgen0120.p PERSISTENT 
             SET h-b1wgen0120.

         FIND crapcop WHERE crapcop.nmrescop = v_coop NO-LOCK NO-ERROR.
         
         FIND crapbcx WHERE crapbcx.cdcooper = crapcop.cdcooper AND
                            crapbcx.dtmvtolt = DATE(v_data)         AND
                            crapbcx.cdagenci = INT(v_pac)      AND
                            crapbcx.nrdcaixa = INT(v_caixa)     AND
                            crapbcx.cdopecxa = STRING(v_operador) NO-LOCK NO-ERROR.
         
         
         RUN Gera_Boletim IN h-b1wgen0120 (INPUT crapcop.cdcooper,       
                                           INPUT INT(v_pac),
                                           INPUT INT(v_caixa),
                                           INPUT 2,
                                           INPUT "CRAP013",
                                           INPUT v_data,       
                                           INPUT STRING(RANDOM(1,10000)),
                                           INPUT YES, /* tipconsu */
                                           INPUT RECID(crapbcx),
                                          OUTPUT aux_flgsemhi,
                                          OUTPUT aux_sdfinbol,
                                          OUTPUT aux_vlrttcrd,
                                          OUTPUT aux_vlrttdeb,
                                          OUTPUT aux_nmarqimp,
                                          OUTPUT aux_nmarqpdf,
                                          OUTPUT TABLE tt-erro).
                                          
          DELETE PROCEDURE h-b1wgen0120.
          
          IF TEMP-TABLE tt-erro:HAS-RECORDS THEN 
             DO:
             
                FIND FIRST tt-erro NO-LOCK NO-ERROR.  
             
                IF AVAIL tt-erro THEN
                   DO:
                      CREATE craperr.
                      ASSIGN craperr.cdcooper = crapcop.cdcooper
                             craperr.cdagenci = INT(v_pac)
                             craperr.nrdcaixa = INT(v_caixa)
                             craperr.nrsequen = tt-erro.nrsequen
                             craperr.cdcritic = tt-erro.cdcritic
                             craperr.dscritic = tt-erro.dscritic.
                      VALIDATE craperr.
                      {include/i-erro.i}
                   END.
          END.
          
          ASSIGN p-nome-arquivo     = aux_nmarqimp
                 p-nome-arquivo-url = "spool/" + ENTRY(8,aux_nmarqimp,"/")
                 vh_arquivo         = HostURL + "/" + p-nome-arquivo-url
                 p-valor-credito    = aux_vlrttcrd
                 p-valor-debito     = aux_vlrttdeb.
         
     END.

     ELSE IF  get-value("b3") <> ""  and
         AVAIL tt-consulta THEN DO:                
                              /* Impressao Boletim */

     RUN sistema/generico/procedures/b1wgen0120.p PERSISTENT 
             SET h-b1wgen0120.

         FIND crapcop WHERE crapcop.nmrescop = v_coop NO-LOCK NO-ERROR.
         
         FIND crapbcx WHERE crapbcx.cdcooper = crapcop.cdcooper AND
                            crapbcx.dtmvtolt = DATE(v_data)         AND
                            crapbcx.cdagenci = INT(v_pac)      AND
                            crapbcx.nrdcaixa = INT(v_caixa)     AND
                            crapbcx.cdopecxa = STRING(v_operador) NO-LOCK NO-ERROR.
         
         
         RUN Gera_Boletim IN h-b1wgen0120 (INPUT crapcop.cdcooper,       
                                           INPUT INT(v_pac),
                                           INPUT INT(v_caixa),
                                           INPUT 2,
                                           INPUT "CRAP013",
                                           INPUT v_data,       
                                           INPUT STRING(RANDOM(1,10000)),
                                           INPUT NO, /* tipconsu */
                                           INPUT RECID(crapbcx),
                                          OUTPUT aux_flgsemhi,
                                          OUTPUT aux_sdfinbol,
                                          OUTPUT aux_vlrttcrd,
                                          OUTPUT aux_vlrttdeb,
                                          OUTPUT aux_nmarqimp,
                                          OUTPUT aux_nmarqpdf,
                                          OUTPUT TABLE tt-erro).
                                          
          DELETE PROCEDURE h-b1wgen0120.
          
          IF TEMP-TABLE tt-erro:HAS-RECORDS THEN 
             DO:
             
                FIND FIRST tt-erro NO-LOCK NO-ERROR.  
             
                IF AVAIL tt-erro THEN
                   DO:
                      CREATE craperr.
                      ASSIGN craperr.cdcooper = crapcop.cdcooper
                             craperr.cdagenci = INT(v_pac)
                             craperr.nrdcaixa = INT(v_caixa)
                             craperr.nrsequen = tt-erro.nrsequen
                             craperr.cdcritic = tt-erro.cdcritic
                             craperr.dscritic = tt-erro.dscritic.
                      VALIDATE craperr.
                      {include/i-erro.i}
                   END.
          END.
     
     
     
     
     END.
     ELSE IF  get-value("b4") <> ""  and
         AVAIL tt-consulta THEN DO:   

         RUN dbo/b1crap13.p PERSISTENT SET h-b1crap13.
                     
         RUN impressao-fita-caixa IN h-b1crap13 (INPUT v_coop,
                                                 INPUT  int(v_pac),
                                                 INPUT  INT(v_caixa),
                                                 INPUT  v_operador,
                                                 INPUT crapdat.dtmvtolt).
         DELETE PROCEDURE h-b1crap13.
         ASSIGN vh_arquivo = " ".
         IF RETURN-VALUE = "NOK" THEN  DO:
            {include/i-erro.i}
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

   
     FIND FIRST tt-consulta NO-LOCK NO-ERROR.
     IF  AVAIL tt-consulta  THEN DO:
         ASSIGN v_abert    = string(tt-consulta.hora-abertura,"hh:mm")
                v_fecha    = string(tt-consulta.hora-fechamento,"hh:mm")
                v_saldoini = string(tt-consulta.saldo-inicial)
                v_saldofin = string(tt-consulta.saldo-final)
                v_lacre    = string(tt-consulta.nro-lacre).
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

    FIND FIRST tt-consulta NO-LOCK NO-ERROR.
    IF  AVAIL tt-consulta  THEN DO:
        ASSIGN v_abert    = string(tt-consulta.hora-abertura,"hh:mm")
               v_fecha    = string(tt-consulta.hora-fechamento,"hh:mm")
               v_saldoini = trim(string(dec(tt-consulta.saldo-inicial),"zzz,zzz,zz9.99"))
               v_saldofin = trim(string(dec(tt-consulta.saldo-final),"zzz,zzz,zz9.99"))
               v_lacre    = string(tt-consulta.nro-lacre).
    END.

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

