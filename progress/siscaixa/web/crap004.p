/* .............................................................................

   Programa: siscaixa/web/crap004.p
   Sistema : Caixa On-line
   Sigla   : CRED   
   Autor   : Mirtes.
   Data    : Marco/2001                      Ultima atualizacao: 03/07/2012.

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Consulta Extrato

   Alteracoes: 31/08/2005 - Tratamentos para unificacao dos bancos, passar
                            codigo da cooperativa como parametro para as 
                            procedure (Julio)

               26/10/2006 - Controle para exclusao das instancias das BO's
                            (Evandro).
               
               03/07/2012 - Ajuste operador como CHARACTER (Guilherme).
               
               07/11/2013 - Nova forma de chamar as agências, de PAC agora 
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

DEFINE VARIABLE h-b1crap00 AS HANDLE     NO-UNDO.
DEFINE VARIABLE h-b1crap04 AS HANDLE     NO-UNDO.

DEF TEMP-TABLE ab_unmap
    FIELD v_coop      AS CHAR
    FIELD v_pac       AS CHAR
    FIELD v_caixa     AS CHAR
    FIELD v_operador  AS CHAR
    FIELD v_data      AS CHAR
    FIELD v_rowid     AS CHAR
    FIELD vh_foco     AS CHAR
    FIELD v_msg       AS CHAR.

DEF TEMP-TABLE tt-cartao
    FIELD id          AS INTEGER
    FIELD nom-titular AS CHAR FORMAT "x(28)"
    FIELD nro-cartao  AS CHAR FORMAT "9999,9999,9999,9999"
    FIELD situacao    AS CHAR FORMAT "x(30)"
    FIELD d           AS CHAR FORMAT "x(01)"
    FIELD rwcrapcrm   AS ROWID.

DEF VAR l-ok AS LOG INIT NO.
DEF VAR data AS CHAR FORMAT "99/99/9999".
DEF VAR c-conta     LIKE crapass.nrdconta.
DEF VAR v-log       AS CHAR.

DEFINE VARIABLE l-achou-ttcartao AS LOGICAL    NO-UNDO.

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
  
  
  vh_foco = "4".
  ASSIGN l-achou-ttcartao = NO.

  IF REQUEST_method = "Get" THEN
  DO:   
      {&OUT}
        "<HTML>":U SKIP
        "<HEAD>":U SKIP
        '<meta http-equiv="cache-control" content="no-cache">' SKIP
        '<meta http-equiv="Pragma"        content="No-Cache">'
        '<meta http-equiv="Expires"       content="0">'
        '<script language=JavaScript src="/script/formatadadosie.js"></script>' SKIP
        '<link rel=StyleSheet type="text/css" href="/script/viacredi.css">' SKIP
        '<title>CARTÃO MAGNÉTICO</title>' SKIP
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
             '  <td class=titulo>CARTÃO MAGNÉTICO</td>' SKIP
             '  <td width="21%" class=programa align="right">P.004&nbsp; V.1.00</td>' SKIP
           ' </tr>' SKIP
          '</table>' SKIP
         '</center>' SKIP
        '</div>' SKIP.
    
      {&OUT}
       '<div align="center">' SKIP
        '<center>' SKIP
         '<table width=100% cellspacing = 0 cellpadding = 0>' SKIP
          '<tr>' SKIP
           '  <td width="100%" valign="middle" align="center">' SKIP
            '  <div align="center">' SKIP
             '  <center>' SKIP
              '  <table width="100%" cellspacing = 0 cellpadding = 1 class=tcampo>' SKIP
               '  <tr><td align="right" class="linhaform">&nbsp;&nbsp;</td></tr>' SKIP
               '  <tr>' SKIP
                '    <td width="15%" align="right" class="linhaform" nowrap>&nbsp;Conta / DV:</td>' SKIP
                '    <td width="25%" align="left" class="linhaform"><input type="text" name="v_conta" size="15" class="input" value="' get-value("v_cta") '" disabled></td>' SKIP
                '    <td width="51%" align="left" class="linhaform">' SKIP
                '    Nome:<input type="text" name="v_nome" size="30" class="input" value="' get-value("v_nom") '" disabled style="font-weight: bold"></td>' SKIP
               ' </tr>' SKIP.

      IF get-value("ok") = "" THEN DO:
          {&OUT}
              '  <tr>' SKIP
               '  <td width="15%" class=linhaform align="right"></td>' SKIP
               '  <td width="25%" class=linhaform align="right"><input type="hidden" name="v_rowid"></td>' SKIP
               '    <td width="51%" align="left" class="linhaform">' SKIP
               '    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="text" name="v_nomconj" size="30" class="input" value="' get-value("v_nomconj") '" disabled style="font-weight: bold"></td>' SKIP
              ' </tr>' SKIP.
      END.
      ELSE
      DO:
           ASSIGN data = get-value("v_dt").
       {&OUT}
           '  <tr>' SKIP
            '  <td width="15%" class=linhaform align="right"></td>' SKIP
            '  <td width="25%" class=linhaform align="right"><input type="hidden" name="v_rowid"></td>' SKIP
            '    <td width="51%" align="left" class="linhaform">' SKIP
            '    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="text" name="v_nomconj" size="30" class="input" value="' get-value("v_nomconj") '" disabled></td>' SKIP
           ' </tr>' SKIP.
      END.
    
    
    
       RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
       RUN valida-transacao IN h-b1crap00(INPUT v_coop,
                                          INPUT v_pac,
                                          INPUT v_caixa).
       DELETE PROCEDURE h-b1crap00.
    
       IF RETURN-VALUE = "NOK" THEN
       DO:
           {include/i-erro.i}
       END.
       ELSE
       DO:
           RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
           RUN verifica-abertura-boletim IN h-b1crap00(INPUT v_coop,
                                                       INPUT v_pac,
                                                       INPUT v_caixa,
                                                       INPUT v_operador).
           DELETE PROCEDURE h-b1crap00.
           
           IF RETURN-VALUE = "NOK" THEN
           DO:
               {include/i-erro.i}
           END.
           ELSE
           DO:
               RUN dbo/b1crap04.p PERSISTENT SET h-b1crap04.
               RUN consulta-cartao IN h-b1crap04(INPUT v_coop,               
                                                 INPUT get-value("v_cta"),
                                                 OUTPUT TABLE tt-cartao).
               DELETE PROCEDURE h-b1crap04.
               
               FIND FIRST TT-CARTAO NO-LOCK NO-ERROR.
               ASSIGN l-achou-ttcartao = AVAIL tt-cartao.

               IF l-achou-ttcartao THEN
               DO:

                   IF get-value("ok") = "" THEN DO:

                       {&OUT}
                             '<tr><td align="right" class="linhaform"></td><td>&nbsp;</td></tr>'
                          "<table width=100% cellspacing=0 cellpadding=1 border = 1>"   SKIP
                           "<tr>"  SKIP
                             '<td class=titulo style="BACKGROUND-COLOR:#2D862D; border=0"></td>'  SKIP
                             '<td class=titulo style="BACKGROUND-COLOR:#2D862D; border=0">Cartão</td>'  SKIP
                             '<td class=titulo style="BACKGROUND-COLOR:#2D862D; border=0">Titular</td>'  SKIP
                             '<td class=titulo style="BACKGROUND-COLOR:#2D862D; border=0">Situação</td>'  SKIP
                            
                           "</tr>"  SKIP.

                   END.
               END.

               

               FOR EACH tt-cartao:
                   
                   {&OUT}
                       "<tr>"
                         '<td class=campos><input type="radio" name="opt" value="' string(tt-cartao.rwcrapcrm) '" Checked> </td>' 
                         '<td class=campos align="left"><a>' tt-cartao.nro-cartao '</a></td>'
                         '<td class=campos align="left">' tt-cartao.nom-titular '</td>'
                         '<td class=campos align="left">' tt-cartao.situacao ' </td>'
                       "</tr>" SKIP.
               END.
           END.
       END.
    
       {&OUT}
               '</table>'.
       IF l-achou-ttcartao THEN
       DO:
           {&OUT}
                 '<tr><td align="right" class="tcampot" style="BACKGROUND-COLOR:#FFFFCE; border=0" colspan=4>&nbsp;</td></tr>'
                   '<tr>'
                    '<td align="center" class="tcampo" style="BACKGROUND-COLOR:#FFFFCE; border=0" colspan=4>'
                     '<input type="submit" value="Ok" name="crap004a" class="button">&nbsp;</td>'
                   '</tr>'.
       END.

       {&OUT}

               '<tr><td align="right" style="BACKGROUND-COLOR:#FFFFCE; border=0" colspan=4>&nbsp;</td></tr>' SKIP 
/*               '  <tr><td align="right" class="linhaform">&nbsp;&nbsp;</td></tr>' SKIP 
               '  <tr><td align="right" class="linhaform">'
               '<input type="button" value="Conta" name="inclui" class="button" onClick="location=~'crap002.w~'"></td></tr>' SKIP */
           '</table>'
          '</center>'
         '</div>'
        '</td>'
       '</tr>'.
       {&OUT}
       '</table>'
      '</center>'
     '</div>'.
           
  END.
  ELSE
  DO:
      RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
      RUN valida-transacao
                    IN h-b1crap00(INPUT v_coop,
                                  INPUT int(v_pac),
                                  INPUT int(v_caixa)).
      DELETE PROCEDURE h-b1crap00.


      IF  RETURN-VALUE = "NOK" THEN DO:
          {include/i-erro.i}
      END.
      ELSE   DO:
          RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
          RUN verifica-abertura-boletim 
                     IN h-b1crap00(INPUT v_coop,
                                   INPUT INT(v_pac),
                                   INPUT INT(v_caixa),
                                   INPUT v_operador).
          DELETE PROCEDURE h-b1crap00.

          IF  RETURN-VALUE = "NOK" THEN DO:
            {include/i-erro.i}
          END.
          ELSE  DO:
    
              ASSIGN v_rowid = get-value("opt").
        
              IF v_rowid <> "" THEN
              DO:
                  {&OUT}
                      '<script>window.location = "crap004a.html?v_row=" + "'get-value("opt")'" + 
                       "&v_ctaa=" + "'get-value("v_cta")'" + "&v_noma=" + "'get-value("v_nom")'" + "&v_nomconja=" + "'get-value("v_nomconj")'"
                      </script>'.
              END.
          END.
      END.
  END.
  ASSIGN v-log   = "yes".      
  ASSIGN c-conta = int(get-value("v_cta")).

     {&OUT}
         '<input type="hidden" name="vh_foco" value="' vh_foco '">'
         '<div align="center">'
          '<table width="100%">'
            '<tr><td align="right" class="linhaform">'
              '<input type="button" value="Conta" name="inclui" class="button" onClick=~'JavaScript:window.location = "crap002.html?v_conta=" + "' c-conta '" + "&v_log=" + "' v-log '"~'>'
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

/* ......................................................................... */

