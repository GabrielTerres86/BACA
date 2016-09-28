/* .............................................................................

   Programa: siscaixa/web/crap003.p
   Sistema : Caixa On-line
   Sigla   : CRED   
   Autor   : Mirtes.
   Data    : Marco/2001                      Ultima atualizacao: 10/10/2012.

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Consulta Extrato

   Alteracoes: 31/08/2005 - Tratamentos para unificacao dos bancos, passar
                            codigo da cooperativa como parametro para as 
                            procedure (Julio)

               26/10/2006 - Controle para exclusao das instancias das BO's
                           (Evandro).
                           
               10/10/2012 - Tratamento para novo campo da 'craphis' de descrição
                            do histórico em extratos (Lucas) [Projeto Tarifas].
               
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
DEFINE VARIABLE h-b1crap03 AS HANDLE     NO-UNDO.

DEF TEMP-TABLE ab_unmap
    FIELD v_coop      AS CHAR
    FIELD v_pac       AS CHAR
    FIELD v_caixa     AS CHAR
    FIELD v_operador  AS CHAR
    FIELD v_data      AS CHAR
    FIELD vh_foco     AS CHAR
    FIELD v_msg       AS CHAR.

DEF TEMP-TABLE tt-extrato
    FIELD conta    AS INT     
    FIELD dtmvtolt AS DATE    FORMAT "99/99/9999"
    FIELD nrdocmto AS CHAR    FORMAT "x(11)"
    FIELD indebcre AS CHAR    FORMAT " x "
    fIELD vllanmto AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"
    FIELD dsextrat LIKE craphis.dsextrat.

DEF VAR l-ok AS LOG INIT NO.
DEF VAR data AS CHAR FORMAT "99/99/9999".
DEF VAR d-data AS DATE FORMAT 99/99/9999.
DEF VAR c-conta     LIKE crapass.nrdconta.
DEF VAR v-log       AS CHAR.

 
{dbo/bo-erro1.i}

DEF VAR i-cod-erro  AS INTEGER.
DEF VAR c-desc-erro AS CHAR.

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
         HEIGHT             = 25.19
         WIDTH              = 114.29.
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
  
  vh_foco = "2".

  
  {&OUT}
    "<HTML>":U SKIP
    "<HEAD>":U SKIP
    '<meta http-equiv="cache-control" content="no-cache">' SKIP
    '<meta http-equiv="Pragma"        content="No-Cache">'
    '<meta http-equiv="Expires"       content="0">'
    '<script language=JavaScript src="/script/formatadadosie.js"></script>' SKIP
    '<link rel=StyleSheet type="text/css" href="/script/viacredi.css">' SKIP
    '<title>EXTRATO</title>' SKIP
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
         '  <td class=titulo>EXTRATO</td>' SKIP
         '  <td width="21%" class=programa align="right">P.003&nbsp; V.1.00</td>' SKIP
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
             '    <td width="10%" align="right" class="linhaform" nowrap>&nbsp;Conta / DV:</td>' SKIP
             '    <td width="20%" align="left" class="linhaform"><input type="text" name="v_conta" size="15" class="input" value="' get-value("v_cta") '" disabled></td>' SKIP
             '    <td width="51%" align="left" class="linhaform">' SKIP
             '    Nome:<input type="text" name="v_nome" size="40" class="input" value="' get-value("v_nom") '" disabled style="font-weight: bold"></td>' SKIP
            ' </tr>' SKIP.

            IF   get-value("cancela") <> "" THEN DO:
                 ASSIGN v_data    = ""
                        vh_foco = "2".
                {&OUT}
                 '  <tr>' SKIP
                  '  <td width="10%" class=linhaform align="right">Data:</td>' SKIP
                  '  <td width="20%"><input type="text" name="v_dt" size="15" class="input" maxlength="10" value="" onKeyDown="JavaScript:FormataData(this,event)" ></td>'
                  '  <td width="51%" align="left" class="linhaform">' SKIP
                  '    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="text" name="v_nomconj" size="40" class="input" value="' get-value("v_nomconj") '" disabled></td>' SKIP
                  ' </tr>' SKIP
                '<tr><td align="right" class="linhaform"></td><td>&nbsp;</td></tr>' SKIP.  

               {&OUT}
                 
                '<tr>'
                 '<td align="center" class="linhaform" colspan=4>'
                  '<input type="submit" value="Ok" name="ok" class="button">&nbsp;'
                  '<input type="submit" value="Cancelar" name="cancela" class="button"></td>'
                '</tr>'
                '<tr><td align="right" class="linhaform"></td><td>&nbsp;</td></tr>' SKIP . 

            END.
            ELSE DO:
               
               
                IF  get-value("ok") = "" THEN DO:
               
                   {&OUT}
                    '  <tr>' SKIP
                     '  <td width="10%" class=linhaform align="right">Data:</td>' SKIP
                     '  <td width="20%"><input type="text" name="v_dt" size="15" class="input" maxlength="10" value="" onKeyUp="JavaScript:preenchimento(event,0,this,10,~'ok~')"></ ></td>' SKIP
                     '    <td width="51%" align="left" class="linhaform">' SKIP
                     '    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="text" name="v_nomconj" size="40" class="input" value="' get-value("v_nomconj") '" disabled style="font-weight: bold"></td>' SKIP
                    ' </tr>' SKIP.
                  {&OUT}
                      '<tr><td align="right" class="linhaform"></td><td>&nbsp;</td></tr>'
                        '<tr>'
                         '<td align="center" class="linhaform" colspan=4>'
                          '<input type="submit" value="Ok" name="ok" class="button">&nbsp;'
                          '<input type="submit" value="Cancelar" name="cancela" class="button"></td>'
                        '</tr>'
                        '<tr><td align="right" class="linhaform"></td><td>&nbsp;</td></tr>' SKIP .
                
                END. 
                 
            END.

  IF REQUEST_METHOD = "POST":U THEN DO:
        RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
    
        RUN valida-transacao IN h-b1crap00(INPUT v_coop,
                                           INPUT v_pac,
                                           INPUT v_caixa).
    
        DELETE PROCEDURE h-b1crap00.
    
        IF RETURN-VALUE = "NOK" THEN DO:
            {include/i-erro.i}
        END.
        ELSE DO:
            IF  get-value("cancela") = "" THEN DO: 
                
                ASSIGN d-data = date(get-value("v_dt")) NO-ERROR.
                IF  ERROR-STATUS:ERROR = YES THEN 
                     ASSIGN d-data = ?.
                   
                RUN dbo/b1crap03.p PERSISTENT SET h-b1crap03.
                RUN consulta-extrato IN h-b1crap03(
                                                 INPUT v_coop,
                                                 INPUT INT(get-value("v_cta")),                                                  INPUT d-data,
                                                 OUTPUT TABLE tt-extrato).
                DELETE PROCEDURE h-b1crap03.

                FIND FIRST tt-extrato NO-LOCK NO-ERROR. 
                /* BO sempre gera tt-extrato */             

               {&OUT}
                   '  <tr>' SKIP
                    '  <td width="10%" class=linhaform align="right">Data:</td>' SKIP
                    '  <td width="20%"><input type="text" name="v_dt" size="15" class="input"  maxlength="10" value="'get-value("v_dt")'" ></disabled>'
                    '  <td width="51%" align="left" class="linhaform">' SKIP
                    '    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="text" name="v_nomconj" size="40" class="input" value="' get-value("v_nomconj") '" disabled></td>' SKIP
                   ' </tr>' SKIP
                   '<tr><td align="right" class="linhaform"></td><td>&nbsp;</td></tr>' SKIP.
                
                FOR EACH tt-extrato 
                    BREAK BY tt-extrato.conta:
                    IF FIRST-OF(tt-extrato.conta) THEN DO:
                       ASSIGN l-ok = NO.
                       {&OUT}
                             "<table width=100% cellspacing=0 cellpadding=1 border = 1>"   SKIP
                              "<tr>"  SKIP
                               '<td class=titulo style="BACKGROUND-COLOR:#2D862D; border=0">Data</td>'  SKIP
                               '<td class=titulo style="BACKGROUND-COLOR:#2D862D; border=0">Histórico</td>'  SKIP
                               '<td class=titulo style="BACKGROUND-COLOR:#2D862D; border=0" style="text-align: right">Documento</td>'  SKIP
                               '<td class=titulo style="BACKGROUND-COLOR:#2D862D; border=0"> D / C</td>'  SKIP
                               '<td class=titulo style="BACKGROUND-COLOR:#2D862D; border=0" style="text-align: right">Valor</td>'  SKIP
                              "</tr>"  SKIP.
                   END.
                  {&OUT}
                  "<tr>"
                    '<td class=campos align="left" readonly>' string(tt-extrato.dtmvtolt,"99/99/9999") '</td>'
                    '<td class=campos align="left" readonly>' tt-extrato.dsextrat '</td>'
                    '<td class=campos align="right" readonly>' tt-extrato.nrdocmto '</td>'
                    '<td class=campos align="center" readonly>' tt-extrato.indebcre '</td>'
                    '<td class=campos align="right" readonly>' tt-extrato.vllanmto FORMAT "zzz,zzz,zzz,zz9.99"'</td>'
                  "</tr>".
                END.
                ASSIGN vh_foco = "5".  
             END. 
        END.
 END.
   {&OUT}
           '</table>'
          '</center>'
         '</div>'
        '</td>'
       '</tr>'
       '</table>'
      '</center>'
     '</div>'.
 ASSIGN v-log   = "yes".      
 ASSIGN c-conta = int(get-value("v_cta")).
 {&OUT}
   '<input type="hidden" name="vh_foco" value="' vh_foco '">'
     '<div align="center">'
      '<table width="100%">'
       '<tr>'
        '<td align="right" class="linhaform">'
         '<input type="button" value="Conta" name="inclui" class="button" onClick=~'JavaScript:window.location = "crap002.html?v_conta=" + "' c-conta '" + "&v_log=" + "' v-log '"~'>'. 

 

        IF get-value("ok") <> ""  THEN        
         {&OUT}
         '&nbsp;<input type="button" value="Extrato" name="crap003" class="button" onClick=~'JavaScript:redireciona(this)~'">'.
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

/* ......................................................................... */

