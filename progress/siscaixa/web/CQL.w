&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w-html 
/*------------------------------------------------------------------------

   Programa: CQL.w
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo
   Data    : Maio/2012.                      Ultima atualizacao: 12/07/2019
      
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Programa que gera os dados para a CQL (Cheque Legal).
   
   Ambiente de testes: http://dwebayllos.cecred.coop.br/telas/imgchq/cheque_legal.php (rodando em dev1)
   
   Alteracoes: 18/06/2013 - Alteracao no codigo da situacao e ocorrencia (Ze).
               
               09/09/2014 - #198262 Incorporacao concredi e credimilsul 
                            (Carlos)
                            
               27/03/2015 - Removido a criacao do arquivo a.txt. (James)

               06/12/2016 - Incorporacao Transulcred (Guilherme/SUPERO)
			   
			   12/07/2019 - 2|8 retornar somente em cdsitdct = 4 (RITM0022371)

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

DEF NEW SHARED VAR glb_nrcalcul AS DECIMAL FORMAT ">>>>>>>>>>>>>9"     NO-UNDO.
DEF NEW SHARED VAR glb_stsnrcal AS LOGICAL                             NO-UNDO.

DEF VAR aux_dsdocmc7 AS CHAR                                           NO-UNDO.
DEF VAR aux_nrcpfcgc AS DEC                                            NO-UNDO.

DEF VAR aux_dsocorre AS CHAR                                           NO-UNDO.
DEF VAR aux_dssitcon AS CHAR                                           NO-UNDO.

DEF VAR aux_nrdocmto AS INT                                            NO-UNDO.
DEF VAR aux_cdbanchq AS INT                                            NO-UNDO.
DEF VAR aux_cdagechq AS INT                                            NO-UNDO.
DEF VAR aux_cdcmpchq AS INT                                            NO-UNDO.
DEF VAR aux_nrctachq AS DEC                                            NO-UNDO.
DEF VAR aux_nrcheque AS INT                                            NO-UNDO.

DEF VAR aux_cdcooper LIKE crapcop.cdcooper                             NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE CQL.html

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
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
  RUN outputHeader.
   */ 
  
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
                    
    RUN outputHeader.
                    
    /* STEP 1 -
     * Open the database or SDO query and and fetch the first record. */ 
    RUN findRecords.
    
    /* Return the form again. Set data values, display them, and output them
     * to the WEB stream.  
     *
     * STEP 2a -
     * Set any values that need to be set, then display them. */
     

    /*  Recebe os parametros da CQL (cooperativa) */
    ASSIGN aux_dsdocmc7 = GET-VALUE("codigoCMC7")
           aux_nrcpfcgc = DEC(GET-VALUE("cpf_cnpj")).

    
    ASSIGN aux_dssitcon = ""
           aux_dsocorre = "".
        
    ASSIGN aux_cdbanchq = INT(SUBSTRING(aux_dsdocmc7,01,03))
           aux_cdagechq = INT(SUBSTRING(aux_dsdocmc7,04,04))
           aux_cdcmpchq = INT(SUBSTRING(aux_dsdocmc7,09,03))
           aux_nrctachq = DEC(SUBSTRING(aux_dsdocmc7,20,10))
           aux_nrcheque = INT(SUBSTRING(aux_dsdocmc7,12,06))
           NO-ERROR.

    IF   ERROR-STATUS:ERROR THEN
         aux_dssitcon = "11".  /* CMC7 Cheque invalido - Anterior 5 */
    ELSE
        DO:
            FIND FIRST crapcop WHERE crapcop.cdbcoctl = aux_cdbanchq AND
                                     crapcop.cdagectl = aux_cdagechq
                                     NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE crapcop THEN
                 aux_dssitcon = "11". /* Agencia nao cadastrada para a if
                                         - Anterior 17 */
            ELSE
                 DO:      
                     /**** Incorporacao ****/
                     IF crapcop.cdcooper = 4 THEN /** Concredi **/
                        aux_cdcooper = 1.
                     ELSE
                     IF crapcop.cdcooper = 15 THEN /** Credimilsul **/
                        aux_cdcooper = 13.
                     ELSE
                     IF crapcop.cdcooper = 17 THEN /** Transulcred **/
                        aux_cdcooper = 9. /* Transpocred */
                     ELSE
                        aux_cdcooper = crapcop.cdcooper.

                     FIND FIRST crapdat WHERE 
                                crapdat.cdcooper = aux_cdcooper
                                NO-LOCK NO-ERROR.

                     IF   NOT AVAILABLE crapdat THEN
                          aux_dssitcon = "11". /* Agencia nao cadastrada para 
                                                  a if - Anterior 17 */
                     ELSE
                          DO:  
                              FIND crapfdc WHERE 
                                   crapfdc.cdcooper = aux_cdcooper AND
                                   crapfdc.cdbanchq = aux_cdbanchq     AND
                                   crapfdc.cdagechq = aux_cdagechq     AND
                                   crapfdc.nrctachq = aux_nrctachq     AND
                                   crapfdc.nrcheque = aux_nrcheque     AND
                                   crapfdc.cdcmpchq = aux_cdcmpchq
                                   NO-LOCK NO-ERROR.
                                                                                
                              IF   NOT AVAIlABLE crapfdc THEN
                                   aux_dssitcon = "11". /* Cheque inexistente
                                                           na base - Anter 18 */         
                              ELSE
                                   DO: 
                                       FIND crapass WHERE
                                        crapass.cdcooper = aux_cdcooper    AND
                                        crapass.nrdconta = crapfdc.nrdconta
                                        NO-LOCK NO-ERROR.

                                       IF   NOT AVAIlABLE crapass THEN
                                            aux_dssitcon = "11". /* CNPJ/CPF 
                                                      Emit.nao cadast. - Ant 3*/
                                       ELSE
                                            DO: 
                                               IF   CAN-DO("5,6,7",
                                                    STRING(crapfdc.incheque))
                                                    THEN
                                                     aux_dssitcon = "11". 
                                                       /* Cheque ja comp. -
                                                          Anterior 7*/
                                               ELSE
                                               IF   STRING(crapass.nrcpfcgc,
                                                           "99999999999999") <>
                                                    STRING(aux_nrcpfcgc,
                                                           "99999999999999")
                                                    THEN
                                                    aux_dssitcon = "11".  
                                                     /* Cheque nao pertencente
                                                        ao emitente - Ant. 4 */
                                               ELSE
                                               IF   CAN-DO("4",
                                                    STRING(crapass.cdsitdct))
                                                    THEN
                                                    ASSIGN aux_dssitcon = "2"
                                                           /* Com Ocorrencia */
                                                           aux_dsocorre = "8".
                                                           /* Conta de dep. a
                                                              vista encerrada */
                                               ELSE
                                               IF   crapfdc.incheque = 8 THEN
                                                    ASSIGN aux_dssitcon = "2"
                                                           /* Com Ocorrencia */
                                                           aux_dsocorre = "4".
                                                           /* Cheque cancelado
                                                              pela if */
                                               ELSE
                                               IF   crapfdc.incheque = 1 THEN
                                                    DO:
                                                        glb_nrcalcul = 
                                                          crapfdc.nrcheque * 10.

                                                        RUN fontes/digfun.p.

                                                        aux_nrdocmto = 
                                                           INTE(glb_nrcalcul).

                                                        FIND crapcor WHERE
                                                          crapcor.cdcooper =
                                                            crapfdc.cdcooper AND
                                                          crapcor.cdbanchq =
                                                            crapfdc.cdbanchq AND
                                                          crapcor.cdagechq =
                                                            crapfdc.cdagechq AND
                                                          crapcor.nrctachq =
                                                            crapfdc.nrctachq AND
                                                          crapcor.nrcheque =
                                                            aux_nrdocmto     AND
                                                          crapcor.flgativo =
                                                            TRUE
                                                          USE-INDEX crapcor1
                                                          NO-LOCK NO-ERROR.

                                                        IF   NOT AVAILABLE 
                                                             crapcor   THEN
                                                             ASSIGN 
                                                             aux_dssitcon = "2"
                                                            /* Com Ocorrencia */
                                                             aux_dsocorre = "1".
                                                            /* Cheque sustado */
                                                        ELSE
                                                        IF   crapcor.dtvalcor =
                                                             ? THEN
                                                             ASSIGN 
                                                             aux_dssitcon = "2"
                                                           /* Com Ocorrencia  */
                                                             aux_dsocorre = "1".
                                                           /* Cheque susteado */
                                                        ELSE
                                                             ASSIGN 
                                                             aux_dssitcon = "2"
                                                            /* Com Ocorrencia */
                                                             aux_dsocorre = "2".
                                                 /* Cheque sustado temporario */
                                                    END.
                                            END.
                                   END.
                          END.
                 END.
        END.
        
        IF   aux_dssitcon = "" AND
             aux_dsocorre = "" THEN
             {&OUT} "1|0".
        ELSE
             DO:
                 IF   aux_dssitcon = "" THEN
                      aux_dssitcon = "0".
                      
                 IF   aux_dsocorre = "" THEN
                      aux_dsocorre = "0".
                 
                 {&OUT} aux_dssitcon + "|" + aux_dsocorre.
             END.    
       
        RUN displayFields.

    /* STEP 2b -
     * Enable objects that should be enabled. */
    RUN enableFields.
    /*
    /* STEP 2c -
     * OUTPUT the Progress from buffer to the WEB stream. */
    RUN outputFields.
    */
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

