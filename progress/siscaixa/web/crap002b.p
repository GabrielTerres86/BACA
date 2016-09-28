/* .............................................................................

Programa: crap002b.p                               Ultima alteracao: 03/10/2014

Alteracoes: 27/03/2009 - Acerto para o uso do zoom, na chamada da tela crap002
                         nao estava sendo passado parametro correto (Evandro).
                         
            04/09/2013 - Nova forma de chamar as agências, de PAC agora 
                         a escrita será PA (André Euzébio - Supero).
                         
            03/10/2014 - Setado format para o campo nrdconta no retorno para
                         o form principal da rotina 2, devido a consulta do
                         do cartao de assinatura utilizar o nº de conta c/
                         format. (Chamado 174180) - (Fabricio)
 
            12/09/2016 - Adicionado chamada da função "callBlass(event)" - (Evandro - RKAM).           
............................................................................. */


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

DEF TEMP-TABLE ab_unmap
    FIELD v_coop      AS CHAR
    FIELD v_pac       AS CHAR
    FIELD v_caixa     AS CHAR
    FIELD v_operador  AS CHAR
    FIELD v_data      AS CHAR
    FIELD vh_foco     AS CHAR
    FIELD v_msg       AS CHAR.

{dbo/bo-erro1.i}

DEF VAR i-cod-erro  AS INTEGER.
DEF VAR c-desc-erro AS CHAR.
DEF VAR c-nome      AS CHAR.
DEF VAR r-rowid     AS CHAR.
DEF VAR v-rowid     AS ROWID.
DEF VAR i-cont      AS INT INIT 0 NO-UNDO.
DEF VAR c-conta     AS CHAR.
DEF VAR v-log       AS CHAR.
DEF VAR aux_nrcpfcgc AS CHAR.
DEF VAR c-contaform  AS CHAR.

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
         HEIGHT             = 20.62
         WIDTH              = 128.
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
  RUN outputHeader.

  CREATE ab_unmap.
  {include/i-global.i}

  vh_foco = "1".

  {&OUT}
    "<HTML>":U SKIP
    "<HEAD>":U SKIP
    '<meta http-equiv="cache-control" content="no-cache">' SKIP
    '<meta http-equiv="Pragma"        content="No-Cache">'
    '<meta http-equiv="Expires"       content="0">'
    '<script language=JavaScript src="/script/formatadadosie.js"></script>' SKIP
    '<link rel=StyleSheet type="text/css" href="/script/viacredi.css">' SKIP
    '<title>Pesquisa Conta</title>' SKIP
    "</HEAD>":U SKIP
    '<body background="/images/moeda.jpg" bgproperties="fixed" class=fundo onLoad="JavaScript:mudaFoco(); click();" onKeyUp="callBlass(event); callBLini(event); callBLsal(event);">' SKIP
    '<form onKeyDown="change_page(event)" method=post>' SKIP.
  
  {&OUT}
    '<p style="word-spacing: 0; line-height: 100%; margin-top: 0; margin-bottom: 0">&nbsp;</p>' SKIP
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
         '  <td class=titulo>Pesquisa Conta</td>' SKIP
         '  <td width="21%" class=programa align="right">P.002b&nbsp; V.1.00</td>' SKIP
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
          '  <center>' SKIP.

        RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
    
        RUN valida-transacao IN h-b1crap00(INPUT v_coop,
                                           INPUT v_pac,
                                           INPUT v_caixa).
    
        DELETE PROCEDURE h-b1crap00.
    
        IF RETURN-VALUE = "NOK" THEN DO:
            {include/i-erro.i}
        END.    
        ELSE DO:

            /* se clicou em OK, volta para a tela levando a conta escolhida */
            IF get-value("ok") <> "" THEN DO:
                FIND FIRST crapass
                    WHERE crapass.cdcooper = crapcop.cdcooper  AND
                          rowid(crapass) = to-rowid(get-value("opt")) NO-LOCK NO-ERROR.
                IF AVAIL crapass THEN DO:
                    ASSIGN c-conta = TRIM(STRING(crapass.nrdconta,"ZZZZ,ZZZ,9"))
                           v-log   = "yes".

                    {&OUT}
                        '<script>window.location = "' + get-value("v_tela") + '?v_conta=" + "' c-conta '" + "&v_log=" + "' v-log '"</script>'.
                    END.
            END.


            ASSIGN c-nome = get-value("v_nome").
            FIND FIRST crapass NO-LOCK USE-INDEX crapass6 WHERE
                       crapass.cdcooper = crapcop.cdcooper  AND
                       crapass.nmprimtl BEGINS c-nome NO-ERROR.
               
            IF AVAIL crapass THEN DO:
                ASSIGN vh_foco = "1".
                {&OUT}
                '<input type="hidden" name="vh_foco" value="' vh_foco '">'.
                {&OUT}
                    "<br><table width=100% cellspacing=0 cellpadding=1 border = 1>"   SKIP
                       "<tr>"  SKIP
                        '<td class=titulo style="BACKGROUND-COLOR:#2D862D; border=0"></td>'  SKIP 
                        '<td class=titulo style="BACKGROUND-COLOR:#2D862D; border=0">Nome</td>'  SKIP
                        '<td class=titulo style="BACKGROUND-COLOR:#2D862D; border=0">Conta</td>'  SKIP
                        '<td class=titulo style="BACKGROUND-COLOR:#2D862D; border=0">PA</td>'  SKIP
                        '<td class=titulo style="BACKGROUND-COLOR:#2D862D; border=0">CNPJ</td>'  SKIP
                        '<td class=titulo style="BACKGROUND-COLOR:#2D862D; border=0">Dt Nasc.</td>'  SKIP
                       "</tr>"  SKIP.
            END. 
            ELSE DO:
                {&out} "<script>alert('Não há registros para nome: ' + '" c-nome "');"
                       "window.location = 'crap002a.htm?v_tela=crap002.htm';</script>".
            END.
            ASSIGN i-cont = 0.
            FOR EACH crapass NO-LOCK USE-INDEX crapass6
               WHERE crapass.cdcooper = crapcop.cdcooper  AND
                     crapass.nmprimtl BEGINS c-nome 
               BREAK BY crapass.nmprimtl
                     BY crapass.nrdconta:
                IF crapass.inpessoa = 1 THEN
                   ASSIGN aux_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999")
                          aux_nrcpfcgc = STRING(aux_nrcpfcgc,"999.999.999-99").
                ELSE 
                    ASSIGN aux_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999999")
                           aux_nrcpfcgc = STRING(aux_nrcpfcgc,"99.999.9999/99-99").
               ASSIGN c-contaform = STRING(crapass.nrdconta,"ZZZZ,ZZZ,9").
               ASSIGN v-rowid = ROWID(crapass).
               ASSIGN i-cont = i-cont + 1.
               IF i-cont = 1 THEN DO:
                   {&OUT}
                    "<tr>"
                      '<td class=campos align="right" readonly><input type="radio" name="opt" value="' string(v-rowid) '" checked></td>'
                      '<td class=campos align="right" style="font-size=10" readonly>' crapass.nmprimtl '</td>'
                      '<td class=campos align="right" style="font-size=10" readonly>' c-contaform '</td>'
                      '<td class=campos align="right" style="font-size=10" readonly>' crapass.cdagenc '</td>'
                      '<td class=campos align="right" style="font-size=10" readonly>' aux_nrcpfcgc '</td>'
                      '<td class=campos style="font-size=10; text-align: left" readonly>' string(crapass.dtnasctl,"99/99/9999") '</td>'
                    "</tr>".
               END.
               ELSE DO:
                  {&OUT}
                   "<tr>"
                     '<td class=campos align="right" readonly><input type="radio" name="opt" value="' string(v-rowid) '"></td>'
                     '<td class=campos align="right" style="font-size=10" readonly>' crapass.nmprimtl '</td>'
                     '<td class=campos align="right" style="font-size=10" readonly>' c-contaform '</td>'
                     '<td class=campos align="right" style="font-size=10" readonly>' crapass.cdagenc '</td>'
                     '<td class=campos align="right" style="font-size=10" readonly>' aux_nrcpfcgc '</td>'
                     '<td class=campos align="right" style="font-size=10; text-align: left" readonly>' string(crapass.dtnasctl,"99/99/9999") '</td>'
                   "</tr>".
               END.
            END.
            IF AVAIL crapass THEN DO:
                {&OUT}
                  '</table>'.
            END.
        END.     
    {&OUT}
       '<tr><td align="center" class="linhaform" colspan=6 style="BACKGROUND-COLOR:#FFFFCE; border=0">'
        '&nbsp;</td></tr>' SKIP
       '<tr><td align="center" class="linhaform" colspan=6 style="BACKGROUND-COLOR:#FFFFCE; border=0">'
        '<input type="submit" value="Ok" name="ok" class="button"></td></tr>' SKIP
        '<tr><td align="center" class="linhaform" colspan=6 style="BACKGROUND-COLOR:#FFFFCE; border=0">'
        ' &nbsp;</td></tr>' SKIP.
    
       {&OUT}   
           '</table>'
          '</center>'
         '</div>'
        '</td>'
       '</tr>'
       '</table>'
      '</center>'
     '</div>'.
 {&OUT}
   '<input type="hidden" name="vh_conta">'

   '<div align="center">'
    '<center>'
     '<table width="100%">'
       '<tr>'
         '<td width="100%" align="center" > <marquee>' v_msg '</marquee>'
         '</td>'
       '</tr>'
     '</table>'
    '</center>'
    '<table cellspacing = 0 cellpadding= 0 width="100%">'
         '<tr>'
            '<td align="right" class="linhaform">'.

         IF get-value("ok") = "" THEN
         {&OUT}
             '<input type="button" value="Conta" name="inclui" class="button" onClick="location=~'crap002.w~'">&nbsp;'
             '<input type="button" value="Zoom"  name="zoom" class="button" onClick="location=~'crap002a.htm?v_tela=crap002.htm~'">'.
         {&OUT}
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

