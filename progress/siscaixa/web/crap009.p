/* .............................................................................

   Programa: siscaixa/web/crap009.p
   Sistema : Caixa On-line
   Sigla   : CRED   
   Autor   : Mirtes.
   Data    : Marco/2001                      Ultima atualizacao: 26/10/2006.

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Consulta Lancamento Boletim Caixa 

   Alteracoes: 01/09/2005 - Tratamentos para unificacao dos bancos, passar
                            codigo da cooperativa como parametro para as 
                            procedure (Julio)

               26/10/2006 - Controle para exclusao das instancias das BO's                                 
               (Evandro).

               08/11/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (Guilherme Gielow)

               12/09/2016 - Adicionado chamada da função "callBlass(event)" - (Evandro - RKAM). 
............................................................................ */

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

DEF TEMP-TABLE tt-lancamento
    FIELD cdcooper  AS   INT
    FIELD controle  AS   INT
    FIELD cdhistor  LIKE craplcx.cdhistor      
    FIELD dshistor  LIKE craphis.dshistor
    FIELD dsdcompl  LIKE craplcx.dsdcompl   
    FIELD nrdocmto  LIKE craplcx.nrdocmto
    FIELD vldocmto  LIKE craplcx.vldocmto   
    FIELD nrseqdig  LIKE craplcx.nrseqdig.    


DEF TEMP-TABLE ab_unmap
    FIELD v_coop      AS CHAR
    FIELD v_pac       AS CHAR
    FIELD v_caixa     AS CHAR
    FIELD v_operador  AS CHAR
    FIELD v_data      AS CHAR
    FIELD v_deschist  AS CHAR
    FIELD vh_foco     AS CHAR
    FIELD v_msg       AS CHAR.


DEFINE VARIABLE h-b1crap09 AS HANDLE     NO-UNDO.
DEFINE VARIABLE h-b1crap00 AS HANDLE     NO-UNDO.
DEFINE VARIABLE i-cont     AS INTEGER    NO-UNDO.

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
         HEIGHT             = 14.14
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
/*------------------------------------------------------------------------------
  Purpose:     Output the MIME header, and any "cookie" information needed 
               by this procedure.  
  Parameters:  <none>
  Notes:       In the event that this Web object is state-aware, this is
               a good place to set the webState and webTimeout attributes.
------------------------------------------------------------------------------*/

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
   * Output additional cookie information here before running outputContentType.
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
   *      The following example sets cust-num=23 and expires tomorrow at (about) the 
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
/*-------------------------------
-----------------------------------------------
  Purpose:     Process the web request.
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  /* 
   * Output the MIME header and set up the object as state-less or state-aware. 
   * This is required if any HTML is to be returned to the browser.
   */

  RUN outputHeader.

  CREATE ab_unmap.

  {include/i-global.i}


  vh_foco = "1".

  {&OUT}
    "<HTML>":U SKIP
    "<HEAD>":U SKIP
    '<meta http-equiv="cache-control" content="no-cache">'  SKIP
    '<script language=JavaScript src="/script/formatadadosie.js"></script>' SKIP
    '<link rel=StyleSheet type="text/css" href="/script/viacredi.css">'  SKIP
    "<TITLE>LANÇAMENTO CONSULTA - BOLETIM DE CAIXA</TITLE>":U SKIP
    "</HEAD>":U SKIP
    '<BODY background="/images/moeda.jpg" bgproperties="fixed" class=fundo onLoad="JavaScript:mudaFoco(); click();" onKeyUp="callBlass(event); callBLini(event); callBLsal(event);">':U SKIP
    '<form name="action" onKeyDown="change_page(event)" method=post>'.
 
  /* Output your custom HTML to WEBSTREAM here (using {&OUT}).                */

   {&OUT}
       '<p style="word-spacing: 0; line-height: 100%; margin-top: 0; margin-bottom: 0">&nbsp;</p>'
       '<div align="center">'
         '<center>'
         '<table width="100%" class=cabtab>'
           '<tr>'
             '<td width="15%" align="center">' ab_unmap.v_coop
             '</td>'
             '<td width="20%" align="center"> PA&nbsp;' ab_unmap.v_pac
             '</td>'
             '<td width="20%" align="center"> CAIXA&nbsp;' ab_unmap.v_caixa
             '</td>'
             '<td width="30%" align="center"> OPERADOR&nbsp;' ab_unmap.v_operador
             '</td>'
             '<td width="15%" align="center">' ab_unmap.v_data
             '</td>'
           '</tr>'
         '</table>'
         '</center>'
       '</div>'.

    {&OUT}
    '<div align="center">'  SKIP
      '<table width=100% class=cabtab>'  SKIP
        '<tr>'  SKIP
          '<td width="70%" class=titulo>LANÇAMENTO CONSULTA - BOLETIM DE CAIXA</td>'  SKIP
          '<td width="30%" class=programa align="right">P.009&nbsp;V.1.00</td>'  SKIP
        '</tr>'  SKIP
      '</table>'  SKIP
    '</div><BR>'  SKIP.

    {&OUT}
       "<table width=100% cellspacing=0 cellpadding=1 border = 1>"   SKIP.

   RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
   RUN valida-transacao IN h-b1crap00(INPUT v_coop,
                                      INPUT v_pac,
                                      INPUT v_caixa).
   DELETE PROCEDURE h-b1crap00.

   IF  RETURN-VALUE = "NOK" THEN DO:
       {include/i-erro.i}
   END.
   ELSE DO:
    
       RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
       RUN verifica-abertura-boletim IN h-b1crap00(INPUT v_coop,
                                                   INPUT v_pac,
                                                   INPUT v_caixa,
                                                   INPUT v_operador).
       DELETE PROCEDURE h-b1crap00.

       IF  RETURN-VALUE = "NOK" THEN DO:
           {include/i-erro.i}
       END.
       ELSE DO:

           RUN dbo/b1crap09.p PERSISTENT SET h-b1crap09.
    
           RUN consulta-lancamento-boletim IN h-b1crap09(INPUT  v_coop,
                                                         INPUT  v_operador,
                                                         INPUT  v_pac,    
                                                         INPUT  v_caixa,
                                                  OUTPUT TABLE tt-lancamento).
           DELETE PROCEDURE h-b1crap09.
           i-cont = 0.                                             
           FOR EACH tt-lancamento 
               BREAK BY tt-lancamento.controle:
               i-cont = i-cont + 2.
               IF FIRST-OF(tt-lancamento.controle) THEN DO:
             {&OUT}
               "<tr>"  SKIP
                 '<td class=titulo style="BACKGROUND-COLOR:#2D862D; border=0">Hist.</td>'  SKIP
                 '<td class=titulo style="BACKGROUND-COLOR:#2D862D; border=0">Descrição</td>'  SKIP
                 '<td class=titulo style="BACKGROUND-COLOR:#2D862D; border=0">Complemento</td>'  SKIP
                 '<td class=titulo style="BACKGROUND-COLOR:#2D862D; border=0">Docto</td>'  SKIP
                 '<td class=titulo style="BACKGROUND-COLOR:#2D862D; border=0">Seq.</td>'  SKIP
                 '<td class=titulo style="BACKGROUND-COLOR:#2D862D; border=0">Valor</td>'  SKIP
               "</tr>"  SKIP.
               END.
               
            {&OUT}
                "<tr>"
                  '<td class=campos align="right">' tt-lancamento.cdhistor '</td>'
                  '<td class=campos align="right"><textarea rows="1" name="S1" cols="15" readonly>' tt-lancamento.dshistor '</textarea></td>'
                  '<td class=campos align="right"><textarea rows="1" name="S2" cols="10" readonly>' tt-lancamento.dsdcompl '</textarea></td>'
                  '<td class=campos align="right">' tt-lancamento.nrdocmto '</td>'
                  '<td class=campos align="right">' tt-lancamento.nrseqdig '</td>'
                  '<td class=campos align="right">' tt-lancamento.vldocmto FORMAT "zzz,zzz,zzz,zz9.99"'</td>'
            "</tr>".
           END.
    
           {&OUT}
              "</table>".
    
           vh_foco = string(i-cont + 1).
       END.
        
       END.
        

    
   {&OUT}
    '<input type="hidden" name="vh_foco" value="' vh_foco '">'
       '<div align="center">'
        '<table width="100%">'
        '<tr>'
         '<td align="right" class="linhaform">'
          '<input type="button" value="Inclusão" name="inclui" class="button" onClick="location=~'crap011.w~'">&nbsp;'
          '<input type="button" value="Estorno" name="estorno" class="button" onClick="JavaScript:redir_login(~'crap010.w~')"></td>'
         '</tr>'
        '</table>'
       '</div>' SKIP

  
    "</form>":U SKIP
    "</BODY>":U SKIP
    "</HTML>":U SKIP.
   
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

