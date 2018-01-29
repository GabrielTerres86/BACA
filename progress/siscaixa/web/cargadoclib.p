
/*.............................................................................

    Programa: cargadoclib.p
    Autor   : Lucas Ranghetti
    Data    : Junho/2015                         Ultima atualizacao: 29/01/2018

    Objetivo  : Enviar para a Selbetti os documentos liberados e nao 
                digitalizados via WebService "JSON".

    Alteracoes: Utilizado a include b1wgen0137tt para nao ter que criar a 
                tt-documentos-liberados novamente. (Lombardi #799181)
                
                29/01/2018 - Ajustar format do Contrato (Lucas Ranghetti #838829)
   
.............................................................................*/

/*** cargadoclib.p = Carga de documentos liberados e nao digitalizados ***/
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

DEFINE VARIABLE p_cdcooper      AS INTE       NO-UNDO.
DEFINE VARIABLE p_dtlibera      AS DATE       NO-UNDO.
DEFINE VARIABLE p_tpdocmto      AS INTE       NO-UNDO.
DEFINE VARIABLE p_key           AS CHAR       NO-UNDO.

DEFINE VARIABLE aux_virgula    AS CHAR        NO-UNDO.
DEFINE VARIABLE aux_contador   AS INTE        NO-UNDO.
DEFINE VARIABLE aux_temerro    AS LOG         NO-UNDO.

DEFINE VARIABLE h-b1wgen0137    AS HANDLE     NO-UNDO.

{ sistema/generico/includes/b1wgen0137tt.i }

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

  ASSIGN p_key      = GET-VALUE("p_key")
         p_dtlibera = DATE (GET-VALUE("p_dtlibera"))
         p_tpdocmto = INTE (GET-VALUE("p_tpdocmto"))
         p_cdcooper = INTE (GET-VALUE("p_cdcooper"))
         NO-ERROR.

  IF  ERROR-STATUS:ERROR    THEN
      ASSIGN aux_temerro = TRUE.
  ELSE
      DO:
          ASSIGN  aux_temerro = FALSE.

          IF  NOT VALID-HANDLE(h-b1wgen0137)   THEN
              RUN sistema/generico/procedures/b1wgen0137.p
                  PERSISTENT SET h-b1wgen0137.
          
          RUN retorna_docs_liberados IN h-b1wgen0137 
                                    (INPUT p_cdcooper,
                                     INPUT p_dtlibera,
                                     INPUT p_tpdocmto,
                                     INPUT p_key,
                                    OUTPUT TABLE tt-documentos-liberados). 
        
          IF  RETURN-VALUE <> "OK" THEN
              ASSIGN aux_temerro = TRUE.

          IF  VALID-HANDLE(h-b1wgen0137)   THEN
              DELETE PROCEDURE h-b1wgen0137.

          aux_contador = 0.

          /* Contar quantos registros tem */
          FOR EACH tt-documentos-liberados NO-LOCK:
              
              aux_contador = aux_contador + 1.

          END.

          /* Inicio da saida do JSON */
          {&OUT}
               '['.

                      FOR EACH tt-documentos-liberados NO-LOCK 
                               BREAK BY tt-documentos-liberados.tpdocmto:
                          
                          /* Nao deve colocar virgula se tiver somente um registro ou 
                             for o ultimo registro */
                          IF  aux_contador = 1 OR 
                              LAST-OF(tt-documentos-liberados.tpdocmto) THEN
                              aux_virgula = "".
                          ELSE
                              aux_virgula = ",".
                           
                          {&OUT}
                          '~{' +
                               '"TipoDocumento":"' + STRING(tt-documentos-liberados.tpdocmto) + '",' +
                               '"Conta":"'         + STRING(tt-documentos-liberados.nrdconta,"zzzz,zzz,9") + '",' +
                               '"Cooperativa":"'   + STRING(tt-documentos-liberados.cdcooper) + '",' +
                               '"PA":"'            + STRING(tt-documentos-liberados.cdagenci,"zz9") + '",' +
                               '"Contrato":"'      + STRING(tt-documentos-liberados.nrctrato,"zzz,zzz,zz9") + '",' +
                               '"Bordero":"'       + STRING(tt-documentos-liberados.nrborder,"zzz,zzz,zz9") + '",' +
                               '"Aditivo":"'       + STRING(tt-documentos-liberados.nraditiv,"zzzzzzzzz9") + '",' +
                               '"DataLiberacao":"' + STRING(tt-documentos-liberados.dtlibera,"99/99/9999") + '",' +
                               '"Valor":"'         + STRING(tt-documentos-liberados.vllanmto,"zzzzzzzzz9.99") + '"' +
                          '~}' + aux_virgula.
                      END.

               {&OUT}
               ']' /* Fim Documento */
         .
      END.    

      IF  aux_temerro THEN
          DO:
               {&OUT}
                   '['
                    '~{' +
                        '"TipoDocumento":"' + '0",' +
                        '"Conta":"'         + '0",' +
                        '"Cooperativa":"'   + '0",' +
                        '"PA":"'            + '0",' +
                        '"Contrato":"'      + '0",' +
                        '"Bordero":"'       + '0",' +
                        '"Aditivo":"'       + '0",' +
                        '"DataLiberacao":"' + STRING(p_dtlibera,"99/99/9999") + '",' +
                        '"Valor":"'         + '0,00"' +
                    '~}'
                  ']' /* Fim Documento */
               . /* Fim saida OUT */
          END.
        
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF
