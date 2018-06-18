/* .............................................................................

   Programa: siscaixa/web/crap057.w
   Sistema : Caixa On-line
   Sigla   : CRED   
   Autor   : Mirtes.
   Data    : Marco/2001                      Ultima atualizacao: 16/04/2013.

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Depositos Cheques Liberados(Varios) 

   Alteracoes: 17/08/2005 - Tratamentos para unificacao dos bancos, passar
                            codigo da cooperativa como parametro para as 
                            procedure (Julio)

               13/03/2006 - Acrescentada leitura do campo cdcooper nas tabelas
                            (Diego).

               30/10/2006 - Controle para exclusao das instancias das BO's
                            (Evandro).
                            
               03/11/2010 - Chama procedure atualiza-previa-caixa para 
                            verificar se caixa deve fazer previa dos cheques 
                            (Elton).
                            
               16/04/2013 - Adicionado verificacao de sangria de caixa no
                         REQUEST-METHOD = GET. (Fabricio)
............................................................................ */

&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD vh_foco AS CHARACTER FORMAT "X(256)":U 
       FIELD v_caixa AS CHARACTER FORMAT "X(256)":U 
       FIELD v_conta AS CHARACTER FORMAT "X(256)":U 
       FIELD v_coop AS CHARACTER FORMAT "X(256)":U 
       FIELD v_data AS CHARACTER FORMAT "X(256)":U 
       FIELD v_identifica AS CHARACTER FORMAT "X(256)":U 
       FIELD v_log AS CHARACTER FORMAT "X(256)":U 
       FIELD v_mensagem AS CHARACTER FORMAT "X(256)":U 
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

DEFINE VARIABLE h-b1crap00 AS HANDLE     NO-UNDO.
DEFINE VARIABLE h-b1crap57 AS HANDLE     NO-UNDO.
DEFINE VARIABLE h-b1crap52  AS HANDLE     NO-UNDO.

DEF VAR p-cod-erro         AS INTE       NO-UNDO.
DEF VAR p-poupanca         AS LOG NO-UNDO.
DEF VAR p-conta-atualiza   AS INTE NO-UNDO.
DEF VAR c-nome             AS CHAR.
DEF VAR c-poup             AS CHAR.
DEFINE VARIABLE l_achou_crapmdw AS LOGICAL    NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE F:/web/crap057.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS ab_unmap.vh_foco ab_unmap.v_caixa ab_unmap.v_conta ab_unmap.v_coop ab_unmap.v_data ab_unmap.v_identifica ab_unmap.v_log ab_unmap.v_mensagem ab_unmap.v_msg ab_unmap.v_nome ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_poupanca ab_unmap.v_valor ab_unmap.v_valor1 
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.vh_foco ab_unmap.v_caixa ab_unmap.v_conta ab_unmap.v_coop ab_unmap.v_data ab_unmap.v_identifica ab_unmap.v_log ab_unmap.v_mensagem ab_unmap.v_msg ab_unmap.v_nome ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_poupanca ab_unmap.v_valor ab_unmap.v_valor1 

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
     ab_unmap.v_identifica AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_log AT ROW 1 COL 1 HELP
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
          FIELD v_conta AS CHARACTER FORMAT "X(256)":U 
          FIELD v_coop AS CHARACTER FORMAT "X(256)":U 
          FIELD v_data AS CHARACTER FORMAT "X(256)":U 
          FIELD v_identifica AS CHARACTER FORMAT "X(256)":U 
          FIELD v_log AS CHARACTER FORMAT "X(256)":U 
          FIELD v_mensagem AS CHARACTER FORMAT "X(256)":U 
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
/* SETTINGS FOR fill-in ab_unmap.v_conta IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_coop IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_data IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_identifica IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_log IN FRAME Web-Frame
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
    ("v_conta":U,"ab_unmap.v_conta":U,ab_unmap.v_conta:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_coop":U,"ab_unmap.v_coop":U,ab_unmap.v_coop:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_data":U,"ab_unmap.v_data":U,ab_unmap.v_data:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_identifica":U,"ab_unmap.v_identifica":U,ab_unmap.v_identifica:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_log":U,"ab_unmap.v_log":U,ab_unmap.v_log:HANDLE IN FRAME {&FRAME-NAME}).
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


    RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
    RUN dbo/b1crap57.p PERSISTENT SET h-b1crap57.

    RUN valida-transacao IN h-b1crap00(INPUT v_coop,
                                       INPUT v_pac,
                                       INPUT v_caixa).

    
    IF RETURN-VALUE = "NOK" THEN DO:
       {include/i-erro.i}
    END.
    ELSE  DO:
       RUN verifica-abertura-boletim IN h-b1crap00(INPUT v_coop,
                                                   INPUT v_pac,
                                                   INPUT v_caixa,
                                                   INPUT v_operador).
       IF RETURN-VALUE = "NOK" THEN DO:
          {include/i-erro.i}
       END.
       ELSE DO:    
          IF GET-VALUE("cancela") <> "" THEN DO:
             ASSIGN v_conta    = ""
                    v_nome     = ""
                    v_poupanca = ""
                    v_identifica = " "
                    v_valor    = ""
                    v_valor1   = ""
                    vh_foco    = "7".
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
          END.
          ELSE DO:
             RUN valida-conta IN h-b1crap57(INPUT v_coop,         
                                            INPUT INT(v_pac),
                                            INPUT INT(v_caixa),
                                            INPUT INT(v_conta),
                                            OUTPUT v_nome,
                                            OUTPUT v_mensagem,
                                            OUTPUT p-poupanca).
             IF  p-poupanca = yes THEN 
                 ASSIGN v_poupanca = "******* CONTA POUPANCA ********".
             ELSE 
                 ASSIGN v_poupanca = " ".
                  
             ASSIGN c-nome     = v_nome.
             ASSIGN c-poup     = v_poupanca.
                  
             IF  RETURN-VALUE = "NOK"  THEN DO:
                 ASSIGN v_conta = "".
                 {include/i-erro.i}
             END.
             ELSE DO:

                  ASSIGN vh_foco = "10".
                  IF  GET-VALUE("v_captura") <> "" THEN DO:
                   
                      RUN dbo/b1crap52.p PERSISTENT SET h-b1crap52.

                      RUN valida_identificacao_dep
                                  IN h-b1crap52(INPUT v_coop,
                                                INPUT INT(v_pac),
                                                INPUT INT(v_caixa),
                                                INPUT INT(v_conta),
                                                INPUT v_identifica).
                      DELETE PROCEDURE h-b1crap52.

                      IF  RETURN-VALUE = "OK" THEN DO:
                        
                          RUN critica-valor 
                                IN h-b1crap57(INPUT v_coop,       
                                              INPUT int(v_pac),
                                              INPUT int(v_caixa),
                                              INPUT DEC(v_valor1),
                                              INPUT DEC(v_valor),
                                              OUTPUT p-cod-erro).
                      END.
                      
                      IF  RETURN-VALUE = "NOK" AND
                          p-cod-erro <> 760 THEN DO:
                          ASSIGN vh_foco = "7". 
                          {include/i-erro.i}
                      END.
                      ELSE DO:
                          IF   p-cod-erro = 760   THEN  DO:
                               {include/i-erro.i}
                          END.
                          
                          IF  GET-VALUE("v_pidentifica") <> " " THEN
                              ASSIGN v_identifica =
                              GET-VALUE("v_pidentifica").
                              
                          /** Verifica se caixa deve fazer previa dos cheques **/
                          RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
                          RUN atualiza-previa-caixa  IN h-b1crap00  (INPUT v_coop,
                                                                     INPUT int(v_pac),
                                                                     INPUT int(v_caixa),
                                                                     INPUT v_operador,
                                                                     INPUT v_data,
                                                                     INPUT 3). /*Consulta*/
                          IF   RETURN-VALUE = "NOK" THEN DO:
                               {include/i-erro.i}
                          END.

                          IF   VALID-HANDLE(h-b1crap00)   THEN
                               DELETE PROCEDURE h-b1crap00.
         
                          IF   VALID-HANDLE(h-b1crap57)   THEN
                               DELETE PROCEDURE h-b1crap57.

                          {&OUT}
                           '<script>window.location="crap057a.w?v_pconta="
                           + "'get-value("v_conta")'" + 
                           "&v_pnome=" + 
                           "' c-nome '" + 
                           "&v_ppoup=" +
                           "' c-poup '" +  
                           "&v_pvalor=" +
                           "'GET-VALUE("v_valor")'" +
                            "&v_pidentifica=" +
                           "'GET-VALUE("v_identifica")'" +
                            "&v_pvalor1=" +
                           "'GET-VALUE("v_valor1")'"</script>'.
                      END.
                  END.
                  ELSE DO:
                      IF  GET-VALUE("ok") <> " "   THEN DO: 
                  
                          RUN dbo/b1crap52.p PERSISTENT SET h-b1crap52.

                          RUN valida_identificacao_dep
                                  IN h-b1crap52(INPUT v_coop,
                                                INPUT INT(v_pac),
                                                INPUT INT(v_caixa),
                                                INPUT INT(v_conta),
                                                INPUT v_identifica).
                          DELETE PROCEDURE h-b1crap52.

                          IF  RETURN-VALUE = "OK" THEN DO:
                        
                              RUN critica-valor-dinheiro-cheque 
                                  IN h-b1crap57(INPUT v_coop,        
                                                INPUT INT(v_pac),
                                                INPUT INT(v_caixa),
                                                INPUT DEC(v_valor),
                                                INPUT DEC(v_valor1),
                                                OUTPUT l_achou_crapmdw).
                          END.
                          
                          IF  RETURN-VALUE = "NOK" THEN DO:
                              {include/i-erro.i}
                          END.
                          ELSE DO:
                              IF l_achou_crapmdw THEN
                                 DO:
                                    IF   VALID-HANDLE(h-b1crap00)   THEN
                                         DELETE PROCEDURE h-b1crap00.
             
                                    IF   VALID-HANDLE(h-b1crap57)   THEN
                                         DELETE PROCEDURE h-b1crap57.

                                     {&OUT}
                                     '<script> 
                                     window.location="crap057b.w?v_pconta=" + 
                                     "'get-value("v_conta")'"    +
                                     "&v_pnome=" +
                                     "' c-nome '"  + 
                                     "&v_ppoup=" + 
                                     "' c-poup  '" + 
                                     "&v_pidentifica=" +
                                     "'GET-VALUE("v_identifica")'" +
                                     "&v_pvalor=" + 
                                     "'GET-VALUE("v_valor")'" +
                                     "&v_pvalor1=" +
                                     "'GET-VALUE("v_valor1")'"
                                     </script>'.
                                 END.
                              ELSE
                                 DO:
                                    IF   VALID-HANDLE(h-b1crap00)   THEN
                                         DELETE PROCEDURE h-b1crap00.
             
                                    IF   VALID-HANDLE(h-b1crap57)   THEN
                                         DELETE PROCEDURE h-b1crap57.

                                    {&OUT}
                                    '<script>
                                    window.location="crap057c.w?v_pconta=" + 
                                    "'GET-VALUE("v_conta")'" +
                                    "&v_pnome=" +
                                    "' c-nome '" +
                                    "&v_ppoup=" +
                                    "' c-poup '" +
                                    "&v_pvalor=" +
                                    "'GET-VALUE("v_valor")'" +
                                    "&v_pidentifica=" +
                                    "'GET-VALUE("v_identifica")'" +
                                    "&v_pvalor1=" +
                                    "'GET-VALUE("v_valor1")'"
                                    </script>'.
                                 END.
                          END.    
                      END.
                  END.
             END.
          END.
       END.
    END.

    IF   VALID-HANDLE(h-b1crap00)   THEN
         DELETE PROCEDURE h-b1crap00.
         
    IF   VALID-HANDLE(h-b1crap57)   THEN
         DELETE PROCEDURE h-b1crap57.
    
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

    IF GET-VALUE("v_sangria") <> "" THEN
    DO:
        RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.

        RUN verifica-sangria-caixa IN h-b1crap00 (INPUT v_coop,
                                                  INPUT INT(v_pac),
                                                  INPUT INT(v_caixa),
                                                  INPUT v_operador).

        DELETE PROCEDURE h-b1crap00.

        IF RETURN-VALUE = "MAX" THEN
        DO:
            {include/i-erro.i}

            {&OUT}
                 '<script> window.location = "crap002.html" </script>'.
        
        END.

        IF RETURN-VALUE = "MIN" THEN
            {include/i-erro.i}

        IF RETURN-VALUE = "NOK" THEN
        DO:
            {include/i-erro.i}

            {&OUT}
                 '<script> window.location = "crap002.html" </script>'.
        END.
    END.
   
    /* STEP 1 -
     * Open the database or SDO query and and fetch the first record. */ 
    RUN findRecords.
    
    ASSIGN vh_foco = "7".

    IF get-value("v_pconta") <> "" THEN
    DO:
        ASSIGN v_conta    = GET-VALUE("v_pconta").
        ASSIGN v_nome     = GET-VALUE("v_pnome").
        ASSIGN v_poupanca = GET-VALUE("v_ppoup").
        ASSIGN v_identifica = GET-VALUE("v_pidentifica").
        ASSIGN v_valor    = GET-VALUE("v_pvalor").
        ASSIGN v_valor1   = GET-VALUE("v_pvalor1").
        ASSIGN vh_foco    = "14".
    END.
    ELSE
    DO:
        FOR EACH crapmdw EXCLUSIVE-LOCK
           WHERE crapmdw.cdcooper = crapcop.cdcooper
             AND crapmdw.cdagenci = INT(v_pac)
             AND crapmdw.nrdcaixa = INT(v_caixa):
            DELETE crapmdw.
        END.
        FOR EACH crapmrw EXCLUSIVE-LOCK
           WHERE crapmrw.cdcooper = crapcop.cdcooper
             AND crapmrw.cdagenci = INT(v_pac)
             AND crapmrw.nrdcaixa = INT(v_caixa):
            DELETE crapmrw.
        END.
    END.

    IF get-value("v_log") = "yes" THEN DO:
        /* traz os dados para a tela
           desabilita todos os campos 
           e seta no ok*/
    END.
    
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

