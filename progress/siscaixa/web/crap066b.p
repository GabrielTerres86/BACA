&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Procedure 
/*------------------------------------------------------------------------

Objetivo  : Lançamento de cheques (adaptacao da rotina 51 + lanchq)
Alteracoes: 29/07/2011 - Adaptado da rotina 51 (Guilherme).
                            
            11/11/2013 - Nova forma de chamar as agências, de PAC agora 
                         a escrita será PA (Guilherme Gielow) 
						 
			12/09/2016 - Adicionado chamada da função "callBlass(event)" - (Evandro - RKAM).			                
                            
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

DEFINE VARIABLE h-b1crap66 AS HANDLE     NO-UNDO.

DEF TEMP-TABLE ab_unmap
    FIELD v_coop      AS CHAR
    FIELD v_pac       AS CHAR
    FIELD v_caixa     AS CHAR
    FIELD v_operador  AS CHAR
    FIELD v_data      AS CHAR
    FIELD v_rowid     AS CHAR
    FIELD v_msg       AS CHAR
    FIELD vh_foco     AS CHAR
    FIELD v_nrsequni  AS CHAR
    FIELD v_dtenvelo  AS CHAR.
/*
DEF VAR l-ok AS LOG INIT NO.
DEF VAR data AS CHAR FORMAT "99/99/9999".
DEF VAR c-conta     LIKE crapass.nrdconta.
DEF VAR v-log       AS CHAR.
DEFINE VARIABLE l-achou-ttcartao AS LOGICAL    NO-UNDO.
*/

DEFINE VARIABLE i-cont AS INTEGER    NO-UNDO.
DEFINE VARIABLE de_saldo AS DECIMAL  NO-UNDO.
DEFINE VARIABLE de_difer AS DECIMAL  NO-UNDO. 

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
/*------------------------------------------------------------------------------
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

  IF GET-VALUE("inclui") <> "" THEN DO:
     RUN dbo/b1crap66.p PERSISTENT SET h-b1crap66.
     RUN critica-saldo-cheque 
          IN h-b1crap66(INPUT v_coop,
                        INPUT INT(v_pac),
                        INPUT INT(v_caixa),
                        INPUT YES,  /* validação incluir */
                        INPUT DEC(GET-VALUE("v_pvalor1"))).
     DELETE PROCEDURE h-b1crap66.

     IF RETURN-VALUE = "NOK" THEN  DO:
        {include/i-erro.i}
     END.
     ELSE DO:
        {&OUT} "<script>window.location='crap066a.w"          +
               "?v_pconta="      + GET-VALUE("v_pconta")      +
               "&v_pnome="       + GET-VALUE("v_pnome")       +
               "&v_ppoup="       + GET-VALUE("v_ppoup")       +
/*******************************guilherme
               "&v_pidentifica=" + GET-VALUE("v_pidentifica") +
               "&v_pvalor="      + GET-VALUE("v_pvalor")      +
***************************************/                
               "&v_pvalor1="     + GET-VALUE("v_pvalor1")     +
               "&v_pnrsequni="   + GET-VALUE("v_pnrsequni")   +
               "&v_pdtenvelo="   + GET-VALUE("v_pdtenvelo")   +
               "'</script>".
     END.
  END.
  IF GET-VALUE("exclui") <> "" THEN DO:
     FIND crapmdw EXCLUSIVE-LOCK WHERE
          crapmdw.cdcooper = crapcop.cdcooper  AND
          ROWID(crapmdw) = TO-ROWID(get-value("opt")) NO-ERROR.
     IF AVAIL crapmdw THEN
        DELETE crapmdw.
  END.

  IF  GET-VALUE("finaliza") <> "" THEN DO:
      RUN dbo/b1crap66.p PERSISTENT SET h-b1crap66.
      RUN critica-saldo-cheque IN h-b1crap66(INPUT v_coop,
                                             INPUT INT(v_pac),
                                             INPUT INT(v_caixa),
                                             INPUT NO,
                                             INPUT DEC(GET-VALUE("v_pvalor1"))).
      DELETE PROCEDURE h-b1crap66.

      IF RETURN-VALUE = "NOK" THEN DO:
          {include/i-erro.i}
      END.
      ELSE DO:
          {&OUT} "<script>window.location='crap066c.w"          +
                 "?v_pconta="      + GET-VALUE("v_pconta")      + 
                 "&v_pnome="       + GET-VALUE("v_pnome")       +
                 "&v_ppoup="       + GET-VALUE("v_ppoup")       +
/*********************************guilherme
                 "&v_pidentifica=" + GET-VALUE("v_pidentifica") +
                 "&v_pvalor="      + GET-VALUE("v_pvalor")      + 
*************************************/                 
                 "&v_pvalor1="     + GET-VALUE("v_pvalor1")     +
                 "&v_pnrsequni="   + GET-VALUE("v_pnrsequni")   +
                 "&v_pdtenvelo="   + GET-VALUE("v_pdtenvelo")   +
                 "'</script>".
      END.
  END.
  {&OUT}
    "<HTML>":U SKIP
    "<HEAD>":U SKIP
    '<meta http-equiv="cache-control" content="no-cache">' SKIP
    '<meta http-equiv="Pragma"        content="No-Cache">'
    '<meta http-equiv="Expires"       content="0">'
    '<script language=JavaScript src="/script/formatadadosie.js"></script>' SKIP
    '<link rel=StyleSheet type="text/css" href="/script/viacredi.css">' SKIP
    '<title>LANÇAMENTO DE CHEQUES</title>' SKIP
    "</HEAD>":U SKIP
    '<body background="/images/moeda.jpg" bgproperties="fixed" class=fundo onLoad="JavaScript:mudaFoco(); click();" onKeyUp="callBlass(event); callBLini(event); callBLsal(event);">' SKIP
    '<form onKeyDown="change_page(event)" method=post>' SKIP.
  {&OUT}
    '<p style="word-spacing: 0; line-height: 100%; margin-top: 0; margin-bottom: 0">&nbsp;</p>'
    '<div align="center">' SKIP
      '<center>' SKIP
      '<table width="100%" class=cabtab>' SKIP
        '<tr>' SKIP
          '<td width="15%" align="center">' ab_unmap.v_coop SKIP
          '</td>' SKIP
          '<td width="20%" align="center"> PA&nbsp;' ab_unmap.v_pac SKIP
          '</td>' SKIP
          '<td width="20%" align="center"> CAIXA&nbsp;' ab_unmap.v_caixa SKIP
          '</td>' SKIP
          '<td width="30%" align="center"> OPERADOR&nbsp;' ab_unmap.v_operador SKIP
          '</td>' SKIP
          '<td width="15%" align="center">' ab_unmap.v_data SKIP
          '</td>' SKIP
        '</tr>' SKIP
      '</table>' SKIP
      '</center>' SKIP
    '</div>' SKIP.
  {&OUT}
    '<div align="center">' SKIP
     '<center>' SKIP
      '<table width="100%" class=cabtab>' SKIP
       ' <tr>' SKIP
         '  <td class=titulo>LANÇAMENTO DE CHEQUES</td>' SKIP
         '  <td width="21%" class=programa align="right">P.066b&nbsp; V.1.00</td>' SKIP
       ' </tr>' SKIP
      '</table>' SKIP
     '</center>' SKIP
    '</div>' SKIP.

  ASSIGN de_saldo = 0
         de_difer = 0.
  FOR EACH crapmdw 
   WHERE crapmdw.cdcooper = crapcop.cdcooper
     AND crapmdw.cdagenci = INT(v_pac) 
     AND crapmdw.nrdcaixa   = INT(v_caixa) NO-LOCK:
      ASSIGN de_saldo = de_saldo + crapmdw.vlcompel.
  END.
  ASSIGN de_difer = dec(get-value("v_pvalor1")) - de_saldo.

  {&OUT}
   '<div align="center">' SKIP
    '<center>' SKIP
     '<table width=100% cellspacing = 0 cellpadding = 0>' SKIP
      '<tr>' SKIP
       '  <td width="100%" valign="middle" align="center">' SKIP
        '  <div align="center">' SKIP
         '  <center>' SKIP
          '  <table width="100%" cellspacing = 0 cellpadding = 1 class=tcampo>' SKIP
           ' <tr>'
             ' <td align="center" class="linhaform" colspan="2">&nbsp;&nbsp;</td>'
           ' </tr>'
            '<tr>'
              '<td width="18%" align="right" class="linhaform">Conta/DV:</td>'
              '<td width="67%">'
              '<input type="text" name="v_conta" size="10" class="input" disabled style="text-align: right" value="' get-value("v_pconta") '" disabled> &nbsp;'
                  '<input type="text" name="v_nome" size="40" class="input" style="font-weight: bold" disabled maxlength="40" value="' get-value("v_pnome") '" disabled>'
              '</td>'
            '</tr>'
            '<tr>'
              '<td width="18%" align="right" class="linhaform" nowrap></td>'
              '<td width="67%"><input type="text" name="v_poupanca" size="52" class="input" maxlength="50" value="' get-value("v_ppoup") '" disabled></td>'
            '</tr>'
            '<tr>'
              '<td align="right" class="linhaform" width="23%">Cheque Informado:</td>'
              '<td align="left" class="linhaform" width="77%">'
              '<input type="text" name="v_valor1" size="20" class="input" disabled maxlength="18" style="text-align: right" 
value="' string(dec(get-value("v_pvalor1")),"zzz,zzz,zzz,zz9.99") '" disabled>'
              '&nbsp;'
              '</td>'
            '</tr>'
            '<tr>'
              '<td align="right" class="linhaform" width="23%">Cheque Processado:</td>'
              '<td align="left" class="linhaform" width="77%">'
              '<input type="text" name="v_saldo" size="20" class="input" disabled maxlength="18" style="text-align: right" value="' string(de_saldo,"zzz,zzz,zzz,zz9.99") '" disabled>'
               '&nbsp;'
              '</td>'
            '</tr>'
            '<tr>'
            '<td align="right" class="linhaform" width="23%">Diferenca:</td>'
            '<td align="left" class="linhaform" width="77%">'
              '<input type="text" name="v_difer" size="20" class="input" disabled maxlength="18" style="text-align: right" value="' string(de_difer,"zz,zzz,zzz,zz9.99-") '" disabled>'
            '&nbsp;'
            '</td>'
            '</tr>'
             SKIP.

       FIND FIRST crapmdw 
            WHERE crapmdw.cdcooper = crapcop.cdcooper  
              AND crapmdw.cdagenci = INT(v_pac) 
              AND crapmdw.nrdcaixa   = INT(v_caixa) NO-LOCK NO-ERROR.

       IF AVAIL crapmdw THEN
       DO:
           IF get-value("ok") = "" THEN DO:

               {&OUT}
                     '<tr><td align="right" class="linhaform"></td><td>&nbsp;</td></tr>'
                  "<table width=100% cellspacing=0 cellpadding=1 border = 1>"   SKIP
                   "<tr>"  SKIP
                     '<td class=titulo style="BACKGROUND-COLOR:#2D862D; border=0"></td>'  SKIP
                     '<td class=titulo style="BACKGROUND-COLOR:#2D862D; border=0" align="right">Comp</td>'  SKIP
                     '<td class=titulo style="BACKGROUND-COLOR:#2D862D; border=0" align="right">Banco</td>'  SKIP
                     '<td class=titulo style="BACKGROUND-COLOR:#2D862D; border=0" align="right">Agência</td>'  SKIP
                     '<td class=titulo style="BACKGROUND-COLOR:#2D862D; border=0" align="right">Conta</td>'  SKIP
                     '<td class=titulo style="BACKGROUND-COLOR:#2D862D; border=0" align="right">Cheque</td>'  SKIP
                     '<td class=titulo style="BACKGROUND-COLOR:#2D862D; border=0" align="right">Valor</td>'  SKIP
                     '<td class=titulo style="BACKGROUND-COLOR:#2D862D; border=0" align="right">Aut</td>' SKIP
                   "</tr>"  SKIP.
           END.
       END.

       ASSIGN i-cont   = 0.

       FOR EACH crapmdw  NO-LOCK
          WHERE crapmdw.cdcooper = crapcop.cdcooper
            AND crapmdw.cdagenci = INT(v_pac) 
            AND crapmdw.nrdcaixa = INT(v_caixa) BREAK by
                crapmdw.nrseqdig :
           {&OUT}
               "<tr>"
                 '<td class=campos><input type="radio" name="opt" value="' string(rowid(crapmdw)) '" Checked> </td>' 
                 '<td class=campos align="right">' crapmdw.cdcmpchq '</td>'
                 '<td class=campos align="right">' crapmdw.cdbanchq '</td>'
                 '<td class=campos align="right">' crapmdw.cdagechq '</td>'
                 '<td class=campos align="right">' crapmdw.nrctabdb '</td>'
                 '<td class=campos align="right">' crapmdw.nrcheque '</td>' 
                 '<td class=campos align="right">' string(dec(crapmdw.vlcompel),"zzz,zzz,zzz,zz9.99") '</td>'
                 '<td class=campos align="right">' string(crapmdw.inautent,"S/N")  '</td>' 
               "</tr>" SKIP.
           ASSIGN i-cont   = i-cont + 1.
       END.
   {&OUT}
           '</table>'
            '<tr><td align="right" class="tcampo" style="BACKGROUND-COLOR:#FFFFCE; border=0" colspan=8>&nbsp;</td></tr>'
              '<tr>'
               '<td align="center" class="tcampo" style="BACKGROUND-COLOR:#FFFFCE; border=0" colspan=8>'
                '<input type="submit" value="Incluir" name="inclui" class="button">&nbsp;'
                '<input type="submit" value="Excluir" name="exclui" class="button">&nbsp;'
                '<input type="submit" value="Finalizar" name="finaliza" class="button">&nbsp;</td>'
              '</tr>' SKIP.
   {&OUT}
        '<tr><td align="right" style="BACKGROUND-COLOR:#FFFFCE; border=0" colspan=8>&nbsp;</td></tr>' SKIP 
       '</table>'
      '</center>'
     '</div>'
    '</td>'
   '</tr>'.
   {&OUT}
   '</table>'
  '</center>'
 '</div>'.
     ASSIGN vh_foco = STRING(i-cont + 6).
     {&OUT}
         '<input type="hidden" name="vh_foco" value="' vh_foco '">'
         '<input type="hidden" name="v_nrsequni" value="">'
         '<input type="hidden" name="v_dtenvelo" value="">'
         '<div align="center">'
          '<table width="100%">'
            '<tr><td align="right" class="linhaform">'
              '<input type="button" value="Depósito" name="inclui" class="button" onClick=~'JavaScript:window.location = "crap066.w?v_pconta=" + "'get-value("v_pconta")'" + "&v_pnome=" + "' get-value("v_pnome") '" + "&v_ppoup=" + "' get-value("v_ppoup") '" + "&v_pvalor1=" + "'get-value("v_pvalor1")'"~'>'
             '</td>'
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

