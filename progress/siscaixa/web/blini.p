/*..............................................................................

   Programa: siscaixa/web/blini.p
   Sistema : CAIXA ON-LINE - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Mirtes/Evandro
   Data    : Marco/2007                        Ultima atualizacao: 18/03/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Exibie a tela do BL.

   Alteracoes: 21/03/2007 - Nao permitir iniciar um novo BL caso o BL anterior
                            nao tenha sido finalizado (Evandro).
                            
               31/07/2007 - Colocar o TIME ao final do nome do BL para evitar
                            que seja possível FECHAR e ABRIR um BL com o mesmo
                            nome e fazendo com que os valores nao "batam"
                            (Evandro).
               
               18/11/2008 - Incluido cdcooper na leitura do crapcbl (Elton).

               16/12/2008 - Ajustes para unificacao dos bancos de dados (Evandro).
               
               04/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                  
               13/12/2013 - Adicionado validate para tabela crapcbl (Tiago).
               
               18/03/2015 - Melhoria SD 260475 (Lunelli).
               
..............................................................................*/

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
    FIELD v_msg       AS CHAR
    FIELD vh_foco     AS CHAR
    FIELD v_ident     AS CHAR.

DEFINE VARIABLE de_troco     AS DECIMAL      NO-UNDO.
DEFINE VARIABLE aux_dsindent AS CHARACTER    NO-UNDO.
DEFINE VARIABLE aux_nrdconta AS CHARACTER    NO-UNDO.

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
PROCEDURE process-web-request:
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

  /* GET */
  IF REQUEST_method = "Get" AND v_pac <> "0" AND v_caixa <> "0" THEN
  DO: 

      FIND FIRST crapcbl WHERE crapcbl.cdcooper = crapcop.cdcooper   AND
                               crapcbl.cdagenci = INT(v_pac)         AND
                               crapcbl.nrdcaixa = INT(v_caixa)
                               EXCLUSIVE-LOCK NO-ERROR.

      IF  NOT AVAIL crapcbl  THEN 
          DO:

              CREATE crapcbl.
              ASSIGN crapcbl.cdcooper = crapcop.cdcooper
                     crapcbl.cdagenci = INT(v_pac)
                     crapcbl.nrdcaixa = INT(v_caixa).
          END.

     /* Se o BL nao tem valores, limpa a identificacao */
     IF   crapcbl.vlinicial = 0   AND
          crapcbl.vlcompcr  = 0   AND
          crapcbl.vlcompdb  = 0   THEN
          ASSIGN crapcbl.blidenti  = " "
                 crapcbl.nrdconta  = 0
                 de_troco          = 0.

      VALIDATE crapcbl.

      ASSIGN de_troco = crapcbl.vlinicial + crapcbl.vlcompdb - crapcbl.vlcompcr
             v_ident  = crapcbl.blidenti
             vh_foco = "3".

      {&OUT}
        "<HTML>":U SKIP
        "<HEAD>":U SKIP
        '<meta http-equiv="cache-control" content="no-cache">' SKIP
        '<meta http-equiv="Pragma"        content="No-Cache">'
        '<meta http-equiv="Expires"       content="0">'
        '<script language=JavaScript src="/script/formatadadosie.js"></script>' SKIP
        '<link rel=StyleSheet type="text/css" href="/script/viacredi.css">' SKIP
        '<title>BL - Inicialização</title>' SKIP
        "</HEAD>":U SKIP.


      {&OUT}
        '<body background="/images/moeda.jpg" bgproperties="fixed" class=fundo onLoad="JavaScript:mudaFoco(); click();" onKeyDown="JavaScript:onKey(event)">' SKIP
        '<form method=post>' SKIP
        '<input type="hidden" name="vh_foco" value="' vh_foco '">'.

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
             '  <td class=titulo>BL - Inicialização</td>' SKIP
             '  <td width="21%" class=programa align="right">P.BL&nbsp; V.1.10</td>' SKIP
           ' </tr>' SKIP
          '</table>' SKIP
         '</center>' SKIP
        '</div>' SKIP.

      {&OUT}
       '<div align="center">' SKIP
        '<center>' SKIP
         '<table width=100% cellspacing = 0 cellpadding = 0>' SKIP
          '<tr>' SKIP
           '<td width="100%" valign="middle" align="center">' SKIP
            '<div align="center">' SKIP
             '<center>' SKIP
              '<table width="100%" cellspacing = 0 cellpadding = 1 class=tcampo>' SKIP
               '<tr><td align="right" class="linhaform">&nbsp;&nbsp;</td></tr>' SKIP
               '<tr>' SKIP
                '<td width="15%"> </td>' SKIP
                '<td>' SKIP
                    '<input type="radio" value="1" checked name="incooper" onClick="mudaCooperado(this.value);" > Cooperado' SKIP
                '</td>' SKIP                
               '</tr>' SKIP               
               '<tr>' SKIP
                '<td width="15%"> </td>' SKIP
                '<td>' SKIP
                    '<input type="radio" value="2" name="incooper" onClick="mudaCooperado(this.value);" > Não Cooperado' SKIP
                '</td>' SKIP                
               '</tr>' SKIP
               '<tr>' SKIP
                '<td width="15%">&nbsp;</td>' SKIP
                '<td width="15%">&nbsp;</td>' SKIP
               '</tr>' SKIP
               '<tr>' SKIP
                '<td width="15%" align="right" class="linhaform" nowrap>&nbsp;Conta/DV:</td>' SKIP
                '<td width="35%" align="left" class="linhaform"><input type="text" name="v_conta" size="15" maxlength="12" onKeyDown="JavaScript:validaInteiro(event); FormataConta(this,11,event);" class="input" onChange = "submit();" value="'get-value("v_conta")'" ></td>' SKIP
               '</tr>' SKIP
               '<tr>' SKIP
                '<td width="15%" align="right" class="linhaform" nowrap>&nbsp;Identificação:</td>' SKIP
                '<td width="35%" align="left" class="linhaform"><input type="text" name="v_ident" size="52" maxlength="50" class="input" value="'get-value("v_ident")'" disabled ></td>' SKIP                
               '</tr>' SKIP
               '<tr>' SKIP
                '<td width="15%">&nbsp;</td>' SKIP
                '<td width="35%" align="left" class="linhaform" style="font-size: 9px;font-style: italic; font-weight: bold;">&nbsp;Ex.: João; 9999-9999</td>' SKIP          
               '</tr>' SKIP               
               '<tr>' SKIP
                '<td width="15%" align="right" class="linhaform" nowrap>&nbsp;Saldo Inicial:</td>' SKIP
                '<td width="35%" align="left" class="linhaform"><input type="text" name="v_sldini" size="19" class="input" value="'trim(string(crapcbl.vlinicial,">>>,>>>,>>>,>>9.99-"))'" disabled></td>' SKIP
               '</tr>' SKIP
               '<tr>' SKIP
                '<td width="15%" align="right" class="linhaform" nowrap>&nbsp;Pagamentos:</td>' SKIP
                '<td width="35%" align="left" class="linhaform"><input type="text" name="v_pagamentos" size="19" class="input" value="'TRIM(string(crapcbl.vlcompdb,">>>,>>>,>>>,>>9.99-"))'" disabled></td>' SKIP
               '</tr>' SKIP
               '<tr>' SKIP
                '<td width="15%" align="right" class="linhaform" nowrap>&nbsp;Recebimentos:</td>' SKIP
                '<td width="35%" align="left" class="linhaform"><input type="text" name="v_recebimentos" size="19" class="input" value="'trim(string(crapcbl.vlcompcr,">>>,>>>,>>>,>>9.99-"))'" disabled></td>' SKIP
               '</tr>' SKIP
               '<tr>' SKIP
                '<td width="15%" align="right" class="linhaform" nowrap>&nbsp;Troco:</td>' SKIP
                '<td width="35%" align="left" class="linhaform"><input type="text" name="v_troco" size="19" class="input" value="'TRIM(string(de_troco,">>>,>>>,>>>,>>9.99-"))'" disabled></td>' SKIP
               '</tr>' SKIP
               '<tr><td align="right" style="BACKGROUND-COLOR:#FFFFCE; border=0" colspan=5>&nbsp;</td></tr>' SKIP 
               '<tr>' SKIP
                '<td align="center" class="linhaform" colspan="2">' SKIP
                 '<input type="submit" value="Iniciar" name="ok" class="button" disabled>' SKIP
                '</td>' SKIP
               '</tr>' SKIP 
               '<tr><td align="right" class="linhaform">&nbsp;&nbsp;</td></tr>' SKIP 
              '<table>' SKIP
             '</center>' SKIP
            '</div>' SKIP
           '</td>' SKIP
          '</tr>' SKIP
         '</table>' SKIP
        '</center>' SKIP
       '</div>' SKIP
       '</form>' SKIP.    

      /* Habilita/Desabilita botão dependendo se a conta informada é válida ou não */
      IF  get-value("v_val") = "no" THEN
          {&OUT} "<script language='JavaScript'>" "document.forms[0].ok.disabled=true;" "</script>".
      ELSE
      IF  get-value("v_val") = "yes" THEN
          {&OUT} "<script language='JavaScript'>" "document.forms[0].ok.disabled=false;" "</script>".

       /* Tratamento de erros */
       IF   de_troco < 0   THEN
            DO:
                {&OUT} "<script language='JavaScript'>"
                       "alert('Troco Negativo - Verifique BL');"
                       "window.close();"
                       "</script>".
            END.
       ELSE 
            DO:
                /* Verifica se o BL esta fechado para poder iniciar um novo */
                IF   crapcbl.vlcompcr  <> 0   OR
                     crapcbl.vlcompdb  <> 0   OR
                     crapcbl.vlinicial <> 0   THEN
                     DO:
                         {&OUT} "<script language='JavaScript'>"
                                "alert('O BL atual deve ser finalizado antes de ' +
                                       'iniciar um novo BL.');"
                                "window.close();"
                                "</script>".
                     END.
            END.

       {&out} 
          '</BODY>':U SKIP
          '</HTML>':U SKIP.
  END.
  /* POST */
  ELSE DO:

      /* Se pressionou botão e não for cooperado */
     IF (get-value("ok") <> ""       AND 
         get-value("incooper") = "2")
         OR
     /* Se pressionou botão e for cooperado e conta tiver sido preenchida */
        (get-value("ok") <> ""       AND 
         get-value("incooper") = "1" AND
         get-value("v_conta") <> "") THEN DO:

      FIND FIRST crapcbl WHERE crapcbl.cdcooper = crapcop.cdcooper   AND
                               crapcbl.cdagenci = INT(v_pac)         AND
                               crapcbl.nrdcaixa = INT(v_caixa)
                               EXCLUSIVE-LOCK NO-ERROR.

      IF NOT AVAIL crapcbl  THEN
      DO:           
          CREATE crapcbl.
          ASSIGN crapcbl.cdcooper = crapcop.cdcooper
                 crapcbl.cdagenci = INT(v_pac)
                 crapcbl.nrdcaixa = INT(v_caixa).
      END.

      ASSIGN crapcbl.vlinicial = 0
             crapcbl.vlcompcr  = 0
             crapcbl.vlcompdb  = 0
             crapcbl.blidenti  = SUBSTRING(get-value("v_ident"),1,40) + " " + STRING(TIME,"HH:MM:SS").

      IF  get-value("incooper") = "1" THEN
          ASSIGN crapcbl.nrdconta  = DECI(REPLACE(get-value("v_conta"), ".", "")).

      VALIDATE crapcbl.

    /* Direciona o opener da janela de  BL. Caso forem usadas as teclas F8/F7, o elemento opener assumido
       não é o menu, e sim o próprio frame das rotinas (pane), portanto existem alguns parâmetros para controle.
       - Quando chamado via mouse (opener = menu) ele irá executar o evento onLoad do frame menu.
       - Quando chamado via teclado (opener = pane) ele irá direcionar para a rotina 2, e lá há um tratamento. */
      {&OUT} '<script>opener.location.href = "crap002.w?opener="+opener.name+"&rotina="+opener.location.href.replace(/=/g, "|")</script>'.

     END.
     /* Se não pressionou o botão (eventos de submit();) */
     ELSE DO:

         IF  DECI(get-value("v_conta")) <> 0 AND get-value("incooper") = "1" THEN
             DO:
                 FIND FIRST crapass WHERE crapass.cdcooper = crapcop.cdcooper           AND
                                          crapass.nrdconta = DECI(get-value("v_conta")) AND
                                          crapass.dtdemiss = ?
                                          NO-LOCK NO-ERROR.
                 IF  AVAIL crapass THEN
                     ASSIGN aux_dsindent = TRIM(STRING(crapass.nrdconta, "zzzz,zzz,9") + " - " + crapass.nmprimtl)
                            aux_nrdconta = get-value("v_conta").
                 ELSE
                    DO:
                        ASSIGN aux_dsindent = TRIM(get-value("v_conta") + " - COOPERADO NAO ENCONTRADO")
                               aux_nrdconta = "".
        
                        {&OUT} "<script language='JavaScript'>" 
                               "alert('Cooperado não encontrado!');"
                               "</script>".
                    END.
        
                 {&OUT} '<script> window.location = "blini.p?v_conta=" + "' aux_nrdconta '" +
                                                           "&v_ident=" + "' aux_dsindent '" +
                                                           "&v_val=" + "' string(AVAIL crapass) '"</script>'.
             END.
         /* Se não informou a conta */
         ELSE
             DO:
                ASSIGN aux_dsindent = get-value("v_ident")
                       aux_nrdconta = "".

                {&OUT} "<script language='JavaScript'>" 
                       "alert('Informe a Conta/DV do cooperado!');"
                       "</script>".

                {&OUT} '<script> window.location = "blini.p?v_conta=" + "' aux_nrdconta '" +
                                                          "&v_ident=" + "' aux_dsindent '" +
                                                          "&v_val="   + "no"</script>'.
             END.

     END.
     {&OUT}
       "<HTML>":U SKIP
       "<HEAD>":U SKIP
       '<meta http-equiv="cache-control" content="no-cache">' SKIP
       '<meta http-equiv="Pragma"        content="No-Cache">'
       '<meta http-equiv="Expires"       content="0">'
       '<title>BL - Inicialização</title>' SKIP
       '</HEAD>':U SKIP
       '</BODY>':U SKIP.

    IF (get-value("ok") <> ""       AND 
        get-value("incooper") = "2")
        OR 
        (get-value("ok") <> ""      AND 
        get-value("incooper") = "1" AND
        get-value("v_conta") <> "") THEN DO:
    {&OUT}
       '<script>window.close();</script>'.
    END.

    {&OUT}
        '</BODY>':U SKIP
        '</HTML>':U SKIP.
  END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

