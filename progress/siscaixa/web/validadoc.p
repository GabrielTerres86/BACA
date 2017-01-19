/*.............................................................................

    Programa: validadoc.p
    Autor   : Guilherme Strube
    Data    :                              Ultima atualizacao: 19/01/2017

    Objetivo  : Validação de Documentos

    Alteracoes: 05/11/2013 - Inclusão do parametro p_nraditivo (Jean Michel).
   
                05/08/2015 - Incluir validacao para p_nrdconta, p_nrctrato,
                             p_nrborder, p_nraditiv, pois nao devem iniciar 
                             com 0(zero) (Lucas Ranghetti #314745)
   
                19/01/2017 - Verificar se cooperativa esta ativa (Lucas Ranghetti #596704)
.............................................................................*/

/*** validadoc.p = Validação Documento ***/
&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Procedure 
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
/*           This .W file was created with the Progress AppBuilder.     */
/*----------------------------------------------------------------------*/

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
                                           
DEFINE VARIABLE par_cdstatus    AS INTE       NO-UNDO.

DEFINE VARIABLE p_cdcooper      AS INTE       NO-UNDO. 
DEFINE VARIABLE p_tpdocmto      AS INTE       NO-UNDO.
DEFINE VARIABLE p_nrdconta      AS CHAR       NO-UNDO.
DEFINE VARIABLE p_nrctrato      AS CHAR       NO-UNDO.
DEFINE VARIABLE p_nrborder      AS CHAR       NO-UNDO.
DEFINE VARIABLE p_key           AS CHAR       NO-UNDO.
DEFINE VARIABLE p_nraditiv      AS CHAR       NO-UNDO.

DEFINE VARIABLE h-b1wgen0137    AS HANDLE     NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no



/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Procedure
   Allow: 
   Frames: 0
   Add Fields to: Neither
   Other Settings: CODE-ONLY COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW Procedure ASSIGN
         HEIGHT             = 6.29
         WIDTH              = 60.6.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB Procedure 
/* ************************* Included-Libraries *********************** */

{src/web2/wrap-cgi.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Procedure 


/* ************************  Main Code Block  *********************** */

/* Process the latest Web event. */
RUN process-web-request.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-outputHeader) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE outputHeader Procedure 
PROCEDURE outputHeader :
/*-----------------------------------------------------------------------------
  Purpose:     Output the MIME header, and any "cookie" information needed 
               by this procedure.  
  Parameters:  <none>
  Notes:       In the event that this Web object is state-aware, this is
               a good place to set the webState and webTimeout attributes.
-----------------------------------------------------------------------------*/

  /* To make this a state-aware Web object, pass in the timeout period 
   * (in minutes) before running outputContentType.  If you supply a timeout 
   * period greater than 0, the Web object becomes state-aware and the 
   * following happens:
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
   * Example: Timeout period of 5 minutes for this Web object.
   *
   *   setWebState (5.0).
   */
    
  /* 
   * Output additional cookie information here before running outputContentType
   *      For more information about the Netscape Cookie Specification, see
   *      http://home.netscape.com/newsref/std/cookie_spec.html  
   *   
   *      Name         - name of the cookie
   *      Value        - value of the cookie
   *      Expires date - Date to expire (optional). See TODAY function.
   *      Expires time - Time to expire (optional). See TIME function.
   *      Path         - Override default URL path (optional)
   *      Domain       - Override default domain (optional)
   *      Secure       - "secure" or unknown (optional)
   * 
   *      The following example sets cust-num=23 and expires tomorrow at the 
   *      same time but only for secure (https) connections.
   *      
   *      RUN SetCookie IN web-utilities-hdl 
   *        ("custNum":U, "23":U, TODAY + 1, TIME, ?, ?, "secure":U).
   */ 
  output-content-type ("text/html":U).
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-process-web-request) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE process-web-request Procedure 
PROCEDURE process-web-request :
/*-----------------------------------------------------------------------------
  Purpose:     Process the web request.
  Parameters:  <none>
  Notes:       
-----------------------------------------------------------------------------*/
  /* 
   * Output the MIME header and set up the object as state-less or state-aware 
   * This is required if any HTML is to be returned to the browser.
   */

  RUN outputHeader.

  ASSIGN p_cdcooper = INTE (GET-VALUE("p_cdcooper"))
         p_tpdocmto = INTE (GET-VALUE("p_tpdocmto"))
         p_nrdconta = GET-VALUE("p_nrdconta")
         p_nrctrato = GET-VALUE("p_nrctrato")
         p_nrborder = GET-VALUE("p_nrborder")
         p_key      = GET-VALUE("p_key")
         p_nraditiv = GET-VALUE("p_nraditiv") NO-ERROR.

  IF   ERROR-STATUS:ERROR  OR 
      (INT(SUBSTR(p_nrdconta,1,1)) = 0    OR
      (INT(p_nrctrato) <> 0               AND
       INT(SUBSTR(p_nrctrato,1,1)) = 0) ) OR 
      (INT(STRING(p_nrborder)) <> 0       AND 
       INT(SUBSTR(p_nrborder,1,1)) = 0  ) OR
      (INT(p_nraditiv) <> 0               AND
       INT(SUBSTR(p_nraditiv,1,1)) = 0  ) THEN
       DO:
           ASSIGN par_cdstatus = 0.
       END.           
  ELSE
       DO: 
           RUN sistema/generico/procedures/b1wgen0137.p
                PERSISTENT SET  h-b1wgen0137.
           
           IF   NOT VALID-HANDLE(h-b1wgen0137)   THEN
                ASSIGN par_cdstatus = 0.
           ELSE           
                DO:
                    FIND crapcop WHERE crapcop.cdcooper = p_cdcooper 
                                   AND crapcop.flgativo = TRUE 
                                   NO-LOCK NO-ERROR.
                  
                    IF  AVAILABLE crapcop THEN                        
                        RUN traz_situacao_documento IN h-b1wgen0137 
                                                       (INPUT p_cdcooper,
                                                        INPUT p_nrdconta,
                                                        INPUT p_tpdocmto,
                                                        INPUT p_nrctrato,
                                                        INPUT p_nrborder,
                                                        INPUT INT(p_nraditiv),
                                                        INPUT p_key,
                                                       OUTPUT par_cdstatus). 
                    ELSE 
                        ASSIGN par_cdstatus = 0.
                        
                    IF  VALID-HANDLE(h-b1wgen0137) THEN
                        DELETE PROCEDURE h-b1wgen0137.
                END.
       END.

  {&OUT}
     '<?xml version="1.0" encoding="utf-8"?>'
     '<ValidaDocumentoResponse xmlns="ged.cecred.coop.br">'
     '<ValidaDocumentoResult>'
     '<StatusIndexacao>' par_cdstatus  '</StatusIndexacao>'
     '</ValidaDocumentoResult>'
     '</ValidaDocumentoResponse>'.
        
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF



