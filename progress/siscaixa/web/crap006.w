/* .............................................................................

   Programa: siscaixa/web/crap006.w
   Sistema : Caixa On-line
   Sigla   : CRED   
   Autor   : Mirtes.
   Data    : Marco/2001                      Ultima atualizacao: 30/09/2009.

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Estorno Talao Normal

   Alteracoes: 31/08/2005 - Tratamentos para unificacao dos bancos, passar
                            codigo da cooperativa como parametro para as 
                            procedure (Julio)
                            
               15/02/2007 - Adequacao ao BANCOOB (Evandro).
               
               16/03/2007 - Passagem do nome do sistema por parametro para a 
                            BO (Evandro).
                            
               02/05/2008 - Passado como parametro para a BO exclui-solicitacao-
                            entrega-talao a quantidade de talonarios, tambem 
                            quando ocorrer somente o estorno de soliciticao
                            (Elton).
                            
               30/09/2009 - Adaptacoes projeto IF CECRED (Guilherme).

............................................................................ */

&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD radio AS CHARACTER 
       FIELD vh_foco AS CHARACTER FORMAT "X(256)":U 
       FIELD v_caixa AS CHARACTER FORMAT "X(256)":U 
       FIELD v_conta AS CHARACTER FORMAT "X(256)":U 
       FIELD v_coop AS CHARACTER FORMAT "X(256)":U 
       FIELD v_data AS CHARACTER FORMAT "X(256)":U 
       FIELD v_msg AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nome AS CHARACTER FORMAT "X(256)":U 
       FIELD v_numfin AS CHARACTER FORMAT "X(256)":U 
       FIELD v_numini AS CHARACTER FORMAT "X(256)":U 
       FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
       FIELD v_pac AS CHARACTER FORMAT "X(256)":U 
       FIELD v_talao AS CHARACTER FORMAT "X(256)":U
       FIELD v_banco AS CHARACTER FORMAT "X(256)":U 
       FIELD v_agencia AS CHARACTER FORMAT "X(256)":U .


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

DEFINE VARIABLE h-b1crap06  AS HANDLE             NO-UNDO.
DEFINE VARIABLE h-b1crap00  AS HANDLE             NO-UNDO.

DEF VAR aux_tprequis        LIKE crapreq.tprequis NO-UNDO.

DEF VAR glb_nrcalcul        AS DECIMAL            NO-UNDO.
DEF VAR glb_dscalcul        AS CHAR               NO-UNDO.
DEF VAR glb_stsnrcal        AS LOGICAL            NO-UNDO.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE crap006.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS ab_unmap.v_nome ab_unmap.v_msg ab_unmap.vh_foco ab_unmap.radio ab_unmap.v_caixa ab_unmap.v_conta ab_unmap.v_coop ab_unmap.v_data ab_unmap.v_numfin ab_unmap.v_numini ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_talao ab_unmap.v_banco ab_unmap.v_agencia
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.v_nome ab_unmap.v_msg ab_unmap.vh_foco ab_unmap.radio ab_unmap.v_caixa ab_unmap.v_conta ab_unmap.v_coop ab_unmap.v_data ab_unmap.v_numfin ab_unmap.v_numini ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_talao ab_unmap.v_banco ab_unmap.v_agencia

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     ab_unmap.v_nome AT ROW 1 COL 1 HELP
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
     ab_unmap.v_numfin AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_numini AT ROW 1 COL 1 HELP
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
     ab_unmap.v_talao AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_banco AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_agencia AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 60.57 BY 14.14.


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
          FIELD v_conta AS CHARACTER FORMAT "X(256)":U 
          FIELD v_coop AS CHARACTER FORMAT "X(256)":U 
          FIELD v_data AS CHARACTER FORMAT "X(256)":U 
          FIELD v_msg AS CHARACTER FORMAT "X(256)":U 
          FIELD v_nome AS CHARACTER FORMAT "X(256)":U 
          FIELD v_numfin AS CHARACTER FORMAT "X(256)":U 
          FIELD v_numini AS CHARACTER FORMAT "X(256)":U 
          FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
          FIELD v_pac AS CHARACTER FORMAT "X(256)":U 
          FIELD v_talao AS CHARACTER FORMAT "X(256)":U 
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW w-html ASSIGN
         HEIGHT             = 14.14
         WIDTH              = 60.57.
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
/* SETTINGS FOR FILL-IN ab_unmap.v_conta IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_coop IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_data IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_msg IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_nome IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_numfin IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_numini IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_operador IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_pac IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_talao IN FRAME Web-Frame
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
    ("v_conta":U,"ab_unmap.v_conta":U,ab_unmap.v_conta:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_coop":U,"ab_unmap.v_coop":U,ab_unmap.v_coop:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_data":U,"ab_unmap.v_data":U,ab_unmap.v_data:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_msg":U,"ab_unmap.v_msg":U,ab_unmap.v_msg:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nome":U,"ab_unmap.v_nome":U,ab_unmap.v_nome:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_numfin":U,"ab_unmap.v_numfin":U,ab_unmap.v_numfin:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_numini":U,"ab_unmap.v_numini":U,ab_unmap.v_numini:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_operador":U,"ab_unmap.v_operador":U,ab_unmap.v_operador:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_pac":U,"ab_unmap.v_pac":U,ab_unmap.v_pac:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_talao":U,"ab_unmap.v_talao":U,ab_unmap.v_talao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_banco":U,"ab_unmap.v_banco":U,ab_unmap.v_banco:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_agencia":U,"ab_unmap.v_agencia":U,ab_unmap.v_agencia:HANDLE IN FRAME {&FRAME-NAME}).
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
     * Open the database or SDO query and and fetch the first record. 
    RUN findRecords.                                                  */
    
    /* STEP 3 -    
     * AssignFields will save the data in the frame.
     * (it automatically upgrades the lock to exclusive while doing the update)
     * 
     *  If a new record needs to be created set AddMode to true before 
        running assignFields.  
     *     setAddMode(TRUE).   */

     /* Colocado a chamada do assignFields dentro da include */
     {include/assignfields.i}    

     RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.

     IF get-value("cancela") <> "" THEN DO:
        ASSIGN v_conta   = ""
               v_nome    = ""
               radio     = "YES"
               v_talao   = ""
               v_numini  = ""
               v_numfin  = ""
               v_banco   = ""
               v_agencia = ""
               vh_foco   = "7".
     END.
     ELSE DO:
         RUN valida-transacao IN h-b1crap00(INPUT v_coop,
                                            INPUT int(v_pac),
                                            INPUT int(v_caixa)).
    
    
         IF  RETURN-VALUE = "NOK" THEN
             DO:
                 {include/i-erro.i}
             END.
         ELSE  
             DO:
                 ASSIGN aux_tprequis = 0.

                 IF   get-value("radio") = "YES"   THEN
                      ASSIGN aux_tprequis = 1. /* Normal */ 
                 ELSE
                      ASSIGN aux_tprequis = 2. /* TB */

                 /* Carrega o nome do associado e a agencia de acordo com cada
                    banco */
                 IF   GET-VALUE("v_banco")      <> ""   AND
                      INT(GET-VALUE("v_banco")) <> 0    THEN
                      DO:
                          /* Banco do Brasil - sem DV */
                          IF   INT(GET-VALUE("v_banco")) = 1   THEN
                               DO:
                                   /* Procura pela conta integração */
                                   glb_nrcalcul = INT(v_conta).

                                   RUN fontes/digbbx.p (INPUT  glb_nrcalcul,
                                                        OUTPUT glb_dscalcul,
                                                        OUTPUT glb_stsnrcal).

                                   FIND crapass WHERE
                                        crapass.cdcooper = crapcop.cdcooper AND
                                        crapass.nrdctitg = glb_dscalcul
                                        NO-LOCK NO-ERROR.

                                   ASSIGN v_agencia = SUBSTRING(STRING(
                                                      crapcop.cdagedbb),1,
                                                      LENGTH(STRING(
                                                      crapcop.cdagedbb)) - 1).
                               END.
                          ELSE
                          DO:
                          /* Procura pela conta corrente */
                          FIND crapass WHERE
                               crapass.cdcooper = crapcop.cdcooper AND
                               crapass.nrdconta = INT(v_conta)
                               NO-LOCK NO-ERROR.                          
                          /* BANCOOB */
                          IF   INT(GET-VALUE("v_banco")) = 756   THEN
                               ASSIGN v_agencia = STRING(crapcop.cdagebcb).
                          ELSE
                           DO: /* IF CECRED */
                               IF INT(GET-VALUE("v_banco")) = 
                                                          crapcop.cdbcoctl  AND
                                  GET-VALUE("v_banco") <> ""   THEN
                                  ASSIGN v_agencia = STRING(crapcop.cdagectl).
                               ELSE
                                  ASSIGN v_agencia = "0".
                           END.
                          END.
                          vh_foco = "14".
                      END.
                 ELSE
                      /* Se nao informou banco pega nome pela conta corrente */
                      DO:
                          /* Procura pela conta corrente */
                          FIND crapass WHERE
                               crapass.cdcooper = crapcop.cdcooper   AND
                               crapass.nrdconta = INT(v_conta)
                               NO-LOCK NO-ERROR.
                      END.


                 IF   AVAILABLE crapass   THEN
                      ASSIGN v_nome  = crapass.nmprimtl
                             vh_foco = "14".
                 ELSE
                      DO:
                          FOR EACH craperr WHERE 
                                   craperr.cdcooper = crapcop.cdcooper  AND
                                   craperr.cdagenci = INTE(v_pac)       AND
                                   craperr.nrdcaixa = INTE(v_caixa)
                                   EXCLUSIVE-LOCK:
                               DELETE craperr.
                          END.

                          CREATE craperr.
                          ASSIGN craperr.cdcooper   = crapcop.cdcooper
                                 craperr.cdagenci   = INTE(v_pac)
                                 craperr.nrdcaixa   = INTE(v_caixa)
                                 craperr.nrsequen   = 1
                                 craperr.cdcritic   = 9
                                 craperr.dscritic   = 
                                         "009 - Associado nao cadastrado."
                                 craperr.erro       = YES
                                 vh_foco            = "7".

                          {include/i-erro.i}
                      END.


                 /* Verifica o lancamento */
                 IF   GET-VALUE("v_numini") <> ""   THEN
                      DO:
                          IF   INT(v_numini) <> 0   THEN
                               DO:
                                   /* Verifica se o cheque existe */
                                   FIND crapfdc WHERE
                                        crapfdc.cdcooper = crapcop.cdcooper AND
                                        crapfdc.cdbanchq = INT(v_banco)     AND
                                        crapfdc.cdagechq = INT(v_agencia)   AND
                                        crapfdc.nrctachq = INT(v_conta)     AND
                                        crapfdc.nrcheque =
                                              INTE(SUBSTR(STRING(INT(v_numini),
                                                          "99999999"),1,7))
                                        USE-INDEX crapfdc1 NO-LOCK NO-ERROR.
                                   
                                   IF   NOT AVAILABLE crapfdc   THEN
                                        DO:
                                            FOR EACH craperr WHERE 
                                                     craperr.cdcooper = 
                                                        crapcop.cdcooper  AND
                                                     craperr.cdagenci = 
                                                        INTE(v_pac)       AND
                                                     craperr.nrdcaixa = 
                                                        INTE(v_caixa)
                                                     EXCLUSIVE-LOCK:
                                                 DELETE craperr.
                                            END.
                                            
                                            CREATE craperr.
                                            ASSIGN craperr.cdcooper   = 
                                                           crapcop.cdcooper
                                                   craperr.cdagenci   = 
                                                           INTE(v_pac)
                                                   craperr.nrdcaixa   = 
                                                           INTE(v_caixa)
                                                   craperr.nrsequen   = 1
                                                   craperr.cdcritic   = 108
                                                   craperr.dscritic   = 
                                                           "108 - Talonario " +
                                                           "nao emitido."
                                                   craperr.erro       = YES.
                                            
                                            {include/i-erro.i}
                                        END.
                               END.

                          FIND crapreq WHERE 
                               crapreq.cdcooper = crapcop.cdcooper       AND
                               crapreq.dtmvtolt = crapdat.dtmvtolt       AND
                               crapreq.cdagelot = INT(v_pac)             AND
                               crapreq.tprequis = aux_tprequis           AND
                               crapreq.nrdolote = 19000 + INT(v_caixa)   AND
                               crapreq.nrdctabb = INT(v_conta)           AND
                               crapreq.nrinichq = INT(v_numini)
                               USE-INDEX crapreq1
                               NO-LOCK NO-ERROR.

                          IF   NOT AVAILABLE crapreq   THEN
                               DO: 
                                   FOR EACH craperr WHERE 
                                            craperr.cdcooper = 
                                                    crapcop.cdcooper  AND
                                            craperr.cdagenci = 
                                                    INTE(v_pac)       AND
                                            craperr.nrdcaixa = 
                                                    INTE(v_caixa)
                                            EXCLUSIVE-LOCK:
                                        DELETE craperr.
                                   END.
                                   
                                   CREATE craperr.
                                   ASSIGN craperr.cdcooper   = crapcop.cdcooper
                                          craperr.cdagenci   = INTE(v_pac)
                                          craperr.nrdcaixa   = INTE(v_caixa)
                                          craperr.nrsequen   = 1
                                          craperr.cdcritic   = 108
                                          craperr.dscritic   = "108 - " +
                                                  "Talonario nao emitido."
                                          craperr.erro       = YES.
                                   
                                   {include/i-erro.i}
                               END.
                          ELSE
                               ASSIGN v_talao  = STRING(crapreq.qtreqtal)
                                      v_numfin = STRING(crapreq.nrfinchq).
                          
                          vh_foco = "16".
                      END.
                 ELSE
                      FIND crapreq WHERE 
                               crapreq.cdcooper = crapcop.cdcooper       AND
                               crapreq.dtmvtolt = crapdat.dtmvtolt       AND
                               crapreq.cdagelot = INT(v_pac)             AND
                               crapreq.tprequis = aux_tprequis           AND
                               crapreq.nrdolote = 19000 + INT(v_caixa)   AND
                               crapreq.nrdctabb = INT(v_conta)           AND
                               crapreq.nrinichq = 0 
                               USE-INDEX crapreq1
                               NO-LOCK NO-ERROR.
                       
                       IF  AVAIL crapreq THEN
                           ASSIGN v_talao  = STRING(crapreq.qtreqtal).

                 IF   GET-VALUE("ok") <> ""   THEN
                      DO:
                          RUN dbo/b1crap06.p PERSISTENT SET h-b1crap06.

                          IF   VALID-HANDLE(h-b1crap06)   THEN
                               DO:
                                   RUN exclui-solicitacao-entrega-talao
                                                     IN h-b1crap06
                                                    (INPUT v_coop,
                                                     INPUT INT(v_pac),
                                                     INPUT INT(v_caixa),
                                                     INPUT INT(v_conta),
                                                     INPUT aux_tprequis,
                                                     INPUT INT(v_talao),
                                                     INPUT INT(v_banco),
                                                     INPUT INT(v_agencia),
                                                     INPUT INT(v_numini),
                                                     INPUT INT(v_numfin),
                                                     INPUT "CAIXA").

                                   DELETE PROCEDURE h-b1crap06.
                               END.

                          IF   RETURN-VALUE = "NOK"   THEN
                               {include/i-erro.i}
                          ELSE
                               ASSIGN v_conta   = ""
                                      v_nome    = ""
                                      radio     = "YES"
                                      v_talao   = ""
                                      v_numini  = ""
                                      v_numfin  = ""
                                      v_banco   = ""
                                      v_agencia = ""
                                      vh_foco   = "7".
                      END.
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
    vh_foco = "7".
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

