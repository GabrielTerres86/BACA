/* .............................................................................

   Programa: siscaixa/web/crap057d.p
   Sistema : Caixa On-line
   Sigla   : CRED   
   Autor   : Mirtes.
   Data    : Marco/2001                      Ultima atualizacao: 14/03/2006.

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Depositos Cheques Liberados(Varios) 

   Alteracoes: 17/08/2005 - Tratamentos para unificacao dos bancos, passar
                            codigo da cooperativa como parametro para as 
                            procedure (Julio)

               14/03/2006 - Acrescentada leitura do campo cdcooper na tabela 
                            crapmdw (Diego).
               
               11/11/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (Guilherme Gielow)
             
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

DEF TEMP-TABLE ab_unmap
    FIELD v_coop      AS CHAR
    FIELD v_pac       AS CHAR
    FIELD v_caixa     AS CHAR
    FIELD v_operador  AS CHAR
    FIELD v_data      AS CHAR
    FIELD v_rowid     AS CHAR
    FIELD v_msg       AS CHAR
    FIELD vh_foco     AS CHAR.

DEFINE VARIABLE in99            AS INTEGER    NO-UNDO.
DEFINE VARIABLE l_achou         AS LOGICAL    NO-UNDO.
DEFINE VARIABLE p-literal       AS CHARACTER  NO-UNDO.
DEFINE VARIABLE p-ult-sequencia AS INTEGER    NO-UNDO.
DEFINE VARIABLE p-registro      AS RECID      NO-UNDO.


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


  {&OUT}
    "<HTML>":U SKIP
    "<HEAD>":U SKIP
    '<meta http-equiv="cache-control" content="no-cache">' SKIP
    '<meta http-equiv="Pragma"        content="No-Cache">'
    '<meta http-equiv="Expires"       content="0">'
    '<script language=JavaScript src="/script/formatadadosie.js"></script>' SKIP
    '<link rel=StyleSheet type="text/css" href="/script/viacredi.css">' SKIP
    '<title>AUTENTICAÇÃO DE CHEQUE LIBERADO DIVERSOS</title>' SKIP
    "</HEAD>":U SKIP
    '<body background="/images/moeda.jpg" bgproperties="fixed" class=fundo onLoad="JavaScript:mudaFoco(); click();" onKeyUp="callBLini(event); callBLsal(event);">' SKIP
    '<form onKeyDown="JavaScript: if (event.keyCode == 27) window.close();" method=post>' SKIP.

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
         '  <td class=titulo>AUTENTICAÇÃO DE CHEQUE LIBERADO DIVERSOS</td>' SKIP
         '  <td width="21%" class=programa align="right">P.057d&nbsp; V.1.00</td>' SKIP
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
           ' <tr>'
             ' <td align="center" class="linhaform" colspan="2">&nbsp;&nbsp;</td>'
           ' </tr>'
            '<tr>'
              '<td width="18%" align="right" class="linhaform">Conta/DV:</td>'
              '<td width="67%">'
              '<input type="text" name="v_conta" size="11" class="input" disable~ d style="text-align: right" value="' get-value("v_pconta") '" disabled> &nbsp;'
                  '<input type="text" name="v_nome" size="40" class="input" style="font-weight: bold" disabled maxlength="40" value="' get-value("v_pnome") '" disabled>'
              '</td>'
            '</tr>'
            '<tr>'
              '<td width="18%" align="right" class="linhaform" nowrap></td>'
              '<td width="67%"><input type="text" name="v_poupanca" size="52" class="input" maxlength="50" value="' get-value("v_ppoup") '" disabled></td>'
            '</tr>'
            '<tr>'
              '<td align="right" class="linhaform" width="23%">Dinheiro:</td>'
              '<td align="left" class="linhaform" width="77%">'
              '<p align="left">'
              '<input type="text" name="v_valor" size="20" class="input" disabled maxlength="18" style="text-align: right" value="' string(dec(get-value("v_pvalor")),"zzz,zzz,zzz,zz9.99") '" disabled></p>'
              '</td>'
            '</tr>'
            '<tr>'
              '<td align="right" class="linhaform" width="23%">Cheque Liberado:</td>'
              '<td align="left" class="linhaform" width="77%">'
              '<input type="text" name="v_valor1" size="20" class="input" disabled maxlength="18" style="text-align: right" value="' string(dec(get-value("v_pvalor1")),"zzz,zzz,zzz,zz9.99") '" disabled>'
              '&nbsp;'
              '</td>'
            '</tr>'
            '<tr>'
              '<td align="right" class="linhaform" width="15%" colspan="2">'
                '<hr class="input">'
                '</td>'
            '</tr>'
            '<tr>'
              '<td align="right" class="linhaform" width="23%">Agência:</td>'
              '<td align="left" class="linhaform" width="77%">'
              '<input type="text" name="v_agencia" size="6" class="input" maxlength="4" style="text-align: right">'
               '&nbsp;'
              '</td>'
            '</tr>' 
            '<tr>'
              '<td align="right" class="linhaform" width="23%">Nro. Cheque:</td>'
              '<td align="left" class="linhaform" width="77%">'
              '<input type="text" name="v_cheque" size="8" class="input" maxlength="6" style="text-align: right">'
               '&nbsp;'
              '</td>'
            '</tr>' 
      SKIP.

   {&OUT}
            '<tr><td align="right" class="tcampo" style="BACKGROUND-COLOR:#FFFFCE; border=0" colspan=7>&nbsp;</td></tr>'
              '<tr>'
               '<td align="center" class="tcampo" style="BACKGROUND-COLOR:#FFFFCE; border=0" colspan=7>'
                '<input type="submit" value="Autenticar" name="autentica" class="button">&nbsp;'
                '<input type="button" value="Retornar" name="fecha" class="button" onClick="JavaScript:window.close()">&nbsp;'
              '</tr>' SKIP.

   {&OUT}

           '<tr><td align="right" style="BACKGROUND-COLOR:#FFFFCE; border=0" colspan=7>&nbsp;</td></tr>' SKIP 
       '</table>'
      '</center>'
     '</div>'
    '</td>'
   '</tr>'.
   {&OUT}
   '</table>'
  '</center>'
 '</div>'.
     ASSIGN vh_foco = "5".     
     {&OUT}
       '<input type="hidden" name="vh_foco" value="' vh_foco '">'
       "</form>":U SKIP
       "</BODY>":U SKIP
       "</HTML>":U SKIP.



 IF get-value("autentica") <> "" THEN
 DO:
     ASSIGN in99    = 0
            l_achou = NO.

     DO WHILE TRUE:
         FIND FIRST crapmdw EXCLUSIVE-LOCK
              WHERE crapmdw.cdcooper = crapcop.cdcooper
                AND crapmdw.cdagenci = INT(v_pac)
                AND crapmdw.nrdcaixa   = INT(v_caixa)
                AND crapmdw.nrcheque    = INT(get-value("v_cheque"))
                AND crapmdw.cdagechq    = INT(get-value("v_agencia")) 
                AND crapmdw.cdhistor    = 386 NO-ERROR NO-WAIT.

         ASSIGN in99 = in99 + 1.
         IF   NOT AVAILABLE crapmdw   THEN  DO:
              IF   LOCKED crapmdw     THEN DO:
                   IF  in99 <  100  THEN DO:
                       PAUSE 1 NO-MESSAGE.
                       NEXT.
                   END.
                   ELSE DO:
                       {&OUT}
                         '<script> alert("Tabela CRAPMDW em uso") </script>'.
                   END.
              END.
              ELSE DO:
                  {&OUT}
                    '<script> alert("Não encontrado cheque informado ou cheque de outro banco") </script>'.
              END.
         END.
         ELSE
             ASSIGN l_achou = YES.
         LEAVE.
     END.

     IF l_achou THEN
     DO:
         IF crapmdw.inautent THEN
         DO:
             {&OUT}
               '<script> alert("Cheque já autenticado") </script>'.
         END.
         ELSE
         DO:
             RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
             IF get-value("v_pestorno") = "NO" THEN
                 RUN grava-autenticacao 
                          IN h-b1crap00 (INPUT v_coop,
                                         INPUT int(v_pac),
                                         INPUT int(v_caixa),
                                         INPUT v_operador,
                                         INPUT crapmdw.vlcompel,
                                         INPUT crapmdw.nrcheque, 
                                         INPUT YES, /* YES (PG), NO (REC) */
                                         INPUT "1",  /* On-line            */                                            INPUT NO,   /* NÆo estorno        */
                                         INPUT 386, 
                                         INPUT ?, /* Data off-line */
                                         INPUT 0, /* Sequencia off-line */
                                         INPUT 0, /* Hora off-line */
                                         INPUT 0, /* Seq.orig.Off-line */
                                         OUTPUT p-literal,
                                         OUTPUT p-ult-sequencia,
                                         OUTPUT p-registro).
             ELSE
                 RUN grava-autenticacao  
                          IN h-b1crap00 (INPUT v_coop,
                                         INPUT int(v_pac),
                                         INPUT int(v_caixa),
                                         INPUT v_operador,
                                         INPUT crapmdw.vlcompel,
                                         INPUT crapmdw.nrcheque, 
                                         INPUT YES, /* YES (PG), NO (REC) */
                                         INPUT "1",  /* On-line            */                                            INPUT YES,   /* NÆo estorno        */
                                         INPUT 386, 
                                         INPUT ?, /* Data off-line */
                                         INPUT 0, /* Sequencia off-line */
                                         INPUT 0, /* Hora off-line */
                                         INPUT 0, /* Seq.orig.Off-line */
                                         OUTPUT p-literal,
                                         OUTPUT p-ult-sequencia,
                                         OUTPUT p-registro).
                DELETE PROCEDURE h-b1crap00.

             IF RETURN-VALUE = "NOK" THEN
             DO:
                 {&OUT}
                   '<script> alert("Erro na Autenticação") </script>'.
             END.
             ELSE
             DO:
                 ASSIGN crapmdw.inautent = YES.
                 {&OUT}
                 '<script>window.open("autentica.html?v_plit=" + "' p-literal '" + 
                  "&v_pseq=" + "' p-ult-sequencia '" + "&v_prec=" + "NO"  + "&v_psetcook=" + "yes","waut","width=250,height=145,scrollbars=auto,alwaysRaised=true,left=0,top=0")
                 </script>'.

             END.
         END.
     END.
 END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

