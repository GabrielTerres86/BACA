/*.............................................................................

   Programa: siscaixa/web/crap022b.p
   Sistema : Caixa On-Line
   Autor   : Andre Santos - Supero
   Data    : Junho/2014                      Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia:  Diario (on-line)
   Objetivo  :  Transferencia e deposito entre cooperativas.

   Alteracoes:   
                          
-----------------------------------------------------------------------------*/
&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Procedure 
/*------------------------------------------------------------------------

                                                  
Alteracoes: 11/11/2013 - Nova forma de chamar as agências, de PAC agora 
                         a escrita será PA (Guilherme Gielow)
                
                            
                            
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

DEFINE VARIABLE h-b1crap51 AS HANDLE     NO-UNDO.
DEFINE VARIABLE h-b1crap00 AS HANDLE     NO-UNDO.

DEF TEMP-TABLE ab_unmap
    FIELD v_coop          AS CHARACTER FORMAT "X(256)":U
    FIELD v_cooppara      AS CHARACTER FORMAT "X(256)":U
    FIELD TpDocto         AS CHARACTER FORMAT "X(256)":U
    FIELD v_nroconta      AS CHARACTER FORMAT "X(256)":U
    FIELD v_vlrdocumento  AS CHARACTER FORMAT "X(256)":U
    FIELD v_identificador AS CHARACTER FORMAT "X(256)":U
    FIELD v_nome1         AS CHARACTER FORMAT "X(256)":U
    FIELD v_cpfcgc1       AS CHARACTER FORMAT "X(256)":U
    FIELD v_nome2         AS CHARACTER FORMAT "X(256)":U
    FIELD v_cpfcgc2       AS CHARACTER FORMAT "X(256)":U
    FIELD v_pac           AS CHARACTER FORMAT "X(256)":U
    FIELD v_caixa         AS CHARACTER FORMAT "X(256)":U
    FIELD v_operador      AS CHARACTER FORMAT "X(256)":U
    FIELD v_data          AS CHARACTER FORMAT "X(256)":U
    FIELD v_rowid         AS CHARACTER FORMAT "X(256)":U
    FIELD v_msg           AS CHARACTER FORMAT "X(256)":U
    FIELD vh_foco         AS CHARACTER FORMAT "X(256)":U
    FIELD v_nrsequni      AS CHARACTER FORMAT "X(256)":U
    FIELD v_dtenvelo      AS CHARACTER FORMAT "X(256)":U
    FIELD v_vlcomput      AS CHARACTER FORMAT "X(256)":U
    FIELD v_vlenvelo      AS CHARACTER FORMAT "X(256)":U
    FIELD v_nrterfin      AS CHARACTER FORMAT "X(256)":U
    FIELD v_valorproc     AS CHARACTER FORMAT "X(256)":U.

DEFINE VARIABLE i-cont AS INTEGER    NO-UNDO.
DEFINE VARIABLE de_saldo AS DECIMAL  NO-UNDO.
DEFINE VARIABLE de_difer AS DECIMAL  NO-UNDO.

DEF VAR v_flg-cta-migrada       AS LOGICAL             NO-UNDO.
DEF VAR p_flg-cta-migrada       AS CHAR                NO-UNDO.
DEF VAR v_flg-coop-host         AS LOGICAL             NO-UNDO.
DEF VAR p_flg-coop-host         AS CHAR                NO-UNDO.
DEF VAR v_coop-migrada          AS CHAR                NO-UNDO.


DEF BUFFER crabcop FOR crapcop.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no
&Scoped-define FRAME-NAME Web-Frame

&Scoped-Define ENABLED-OBJECTS ab_unmap.v_cooppara ab_unmap.TpDocto ab_unmap.v_nome1
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.v_cooppara ab_unmap.TpDocto ab_unmap.v_nome1


/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Web-Frame
    ab_unmap.v_cooppara AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
    ab_unmap.TpDocto AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS 
           "TpDocto 1", "Deposito":U,
           "TpDocto 3", "Cheque":U,
           "TpDocto 2", "Transferencia":U
          SIZE 20 BY 4
    ab_unmap.v_nome1 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 60.6 BY 14.19.



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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _PROCEDURE carregaCooperativa Procedure 
PROCEDURE carregaCooperativa :
    
    DEFINE INPUT PARAMETER pCoopPara AS CHAR NO-UNDO.

    FIND FIRST crabcop WHERE crabcop.nmrescop = pCoopPara NO-LOCK NO-ERROR.
            
    IF  AVAIL crabcop THEN
        ASSIGN v_cooppara:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = STRING(crabcop.nmrescop) + ',' +
                                                                   STRING(crabcop.nmrescop).
        
    RETURN 'OK'.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _PROCEDURE htmOffsets Procedure
PROCEDURE htmOffsets :

RUN htmAssociate
    ("TpDocto":U,"ab_unmap.TpDocto":U,ab_unmap.TpDocto:HANDLE IN FRAME {&FRAME-NAME}).
RUN htmAssociate
    ("v_cooppara":U,"ab_unmap.v_cooppara":U,ab_unmap.v_cooppara:HANDLE IN FRAME {&FRAME-NAME}).
RUN htmAssociate
    ("v_nome1":U,"ab_unmap.v_nome1":U,ab_unmap.v_nome1:HANDLE IN FRAME {&FRAME-NAME}).

END PROCEDURE.


/* _UIB-CODE-BLOCK-END */
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
    
  DEFINE VARIABLE lOpenAutentica  AS LOGICAL      NO-UNDO INITIAL NO.

  RUN outputHeader.
  CREATE ab_unmap.
  {include/i-global.i}

  IF  REQUEST_METHOD = 'POST':U THEN DO:

      ASSIGN v_cooppara = GET-VALUE("v_coop")
             p_flg-cta-migrada = GET-VALUE("v_cta-migrada")
             v_flg-cta-migrada = LOGICAL(p_flg-cta-migrada)
             p_flg-coop-host   = GET-VALUE("v_flg-coop-host")
             v_flg-coop-host   = LOGICAL(p_flg-coop-host)
             v_coop-migrada    = GET-VALUE("v_coop-migrada").

      RUN carregaCooperativa IN THIS-PROCEDURE (v_cooppara).
    
      IF  TpDocto = 'Deposito'  THEN DO:
          FOR EACH crapmdw EXCLUSIVE-LOCK
             WHERE crapmdw.cdcooper  = crapcop.cdcooper
               AND crapmdw.cdagenci  = INT(v_pac)
               AND crapmdw.nrdcaixa  = INT(v_caixa):
              DELETE crapmdw.
          END.
          FOR EACH crapmrw EXCLUSIVE-LOCK
              WHERE crapmrw.cdcooper = crapcop.cdcooper
                 AND crapmrw.cdagenci = INT(v_pac)
                 AND crapmrw.nrdcaixa = INT(v_caixa):
                DELETE crapmrw.
          END.

          /* Volta a tela Principal Iniciando a Opercao */
          {&OUT} "<script>window.location='crap022.w"      + 
                 "?tpDoctoSel=" + TpDocto                  +
                 "'</script>".
          
      END.
      
      IF  TpDocto = 'Transferencia'  THEN DO:
          FOR EACH crapmdw EXCLUSIVE-LOCK
             WHERE crapmdw.cdcooper  = crapcop.cdcooper
               AND crapmdw.cdagenci  = INT(v_pac)
               AND crapmdw.nrdcaixa  = INT(v_caixa):
              DELETE crapmdw.
          END.
          FOR EACH crapmrw EXCLUSIVE-LOCK
              WHERE crapmrw.cdcooper = crapcop.cdcooper
                 AND crapmrw.cdagenci = INT(v_pac)
                 AND crapmrw.nrdcaixa = INT(v_caixa):
                DELETE crapmrw.
          END.

          /* Volta a tela Principal Iniciando a Opercao */
          {&OUT} "<script>window.location='crap022.w"      + 
                 "?tpDoctoSel=" + TpDocto                  +
                 "'</script>".
          
      END. /** Fim transferencia **/

      IF  GET-VALUE('dep') <> '' THEN DO: /* Botao Deposito */

          /* Retorna para a tela principal CRAP022 */
          {&OUT} "<script>window.location='crap022.w"               +
                 "?v_coop="          + GET-VALUE("v_cooppara")      +
                 "&v_nroconta="      + GET-VALUE("v_nroconta")      +
                 "&v_valortotchq="   + GET-VALUE("v_vlrdocumento")  +
                 "&v_identificador=" + GET-VALUE("v_identificador") +
                 "&v_nome1="         + GET-VALUE("v_nome1")         +
                 "&v_cpfcgc1="       + GET-VALUE("v_cpfcgc1")       +
                 "&v_nome2="         + GET-VALUE("v_nome2")         +
                 "&v_cpfcgc2="       + GET-VALUE("v_cpfcgc2")       +
                 "&v_cta-migrada="   + STRING(v_flg-cta-migrada)    +
                 "&v_coop-migrada="  + STRING(v_coop-migrada)       +
                 "&v_flg-coop-host=" + STRING(v_flg-coop-host)      +
                 "&v_tela="          + "crap022b"                   +
                 "'</script>".
    
      END.
    
      IF GET-VALUE("inclui") <> "" THEN DO:
         RUN dbo/b1crap51.p PERSISTENT SET h-b1crap51.
         RUN critica-saldo-cheque 
              IN h-b1crap51(INPUT v_coop,
                            INPUT INT(v_pac),
                            INPUT INT(v_caixa),
                            INPUT YES,  /* validação incluir */
                            INPUT DEC(GET-VALUE("v_vlrdocumento"))).
         DELETE PROCEDURE h-b1crap51.
      
         IF RETURN-VALUE = "NOK" THEN  DO:
            {include/i-erro.i}
         END.
         ELSE DO:
             
             {&OUT} "<script>window.location='crap022a.w"              +
                   "?v_cooppara="      + GET-VALUE("v_cooppara")      +
                   "&v_nroconta="      + GET-VALUE("v_nroconta")      +
                   "&v_vlrdocumento="  + GET-VALUE("v_vlrdocumento")  +
                   "&v_identificador=" + GET-VALUE("v_identificador") +
                   "&v_nome1="         + GET-VALUE("v_nome1")         + 
                   "&v_cpfcgc1="       + GET-VALUE("v_cpfcgc1")       +
                   "&v_nome2="         + GET-VALUE("v_nome2")         +
                   "&v_cpfcgc2="       + GET-VALUE("v_cpfcgc2")       +
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
      
      IF  GET-VALUE('finaliza') <> '' THEN DO:
          RUN dbo/b1crap51.p PERSISTENT SET h-b1crap51.
          RUN critica-saldo-cheque IN h-b1crap51(INPUT v_coop,
                                                 INPUT INT(v_pac),
                                                 INPUT INT(v_caixa),
                                                 INPUT NO,
                                                 INPUT DEC(GET-VALUE("v_vlrdocumento"))).
          DELETE PROCEDURE h-b1crap51.
      
          IF RETURN-VALUE = "NOK" THEN DO:
              {include/i-erro.i}
          END.
          ELSE DO:
              
              {&OUT} "<script>window.location='crap022c.w"              +
                     "?v_pcoop="         + GET-VALUE("v_cooppara")      +
                     "&v_nroconta="      + GET-VALUE("v_nroconta")      +
                     "&v_vlrdocumento="  + GET-VALUE("v_vlrdocumento")  +
                     "&v_identificador=" + GET-VALUE("v_identificador") +
                     "&v_nome1="         + GET-VALUE("v_nome1")         + 
                     "&v_cpfcgc1="       + GET-VALUE("v_cpfcgc1")       +
                     "&v_nome2="         + GET-VALUE("v_nome2")         +
                     "&v_cpfcgc2="       + GET-VALUE("v_cpfcgc2")       +
                     "&v_cta-migrada="   + STRING(v_flg-cta-migrada)    +
                     "&v_coop-migrada="  + STRING(v_coop-migrada)       +
                     "&v_flg-coop-host=" + STRING(v_flg-coop-host)      +
                     "'</script>".
          END.
      END.
      
  END. /* Form has been submitted. */
  ELSE DO: /* REQUEST-METHOD = GET */ 

      /* Carrega Dados */
      ASSIGN v_cooppara      = GET-VALUE("v_cooppara")
             v_nroconta      = GET-VALUE("v_nroconta")
             v_vlrdocumento  = GET-VALUE("v_vlrdocumento")
             v_identificador = GET-VALUE("v_identificador")
             v_nome1         = GET-VALUE("v_nome1")
             v_cpfcgc1       = GET-VALUE("v_cpfcgc1")
             v_nome2         = GET-VALUE("v_nome2")
             v_cpfcgc2       = GET-VALUE("v_cpfcgc2")
             p_flg-cta-migrada = GET-VALUE("v_cta-migrada")
             v_flg-cta-migrada = LOGICAL(p_flg-cta-migrada)
             p_flg-coop-host   = GET-VALUE("v_flg-coop-host")
             v_flg-coop-host   = LOGICAL(p_flg-coop-host)
             v_coop-migrada    = GET-VALUE("v_coop-migrada").

      RUN carregaCooperativa IN THIS-PROCEDURE (v_cooppara).
      
  END.

  {&OUT}
    "<HTML>":U SKIP
    "<HEAD>":U SKIP
    '<meta http-equiv="cache-control" content="no-cache">' SKIP
    '<meta http-equiv="Pragma"        content="No-Cache">'
    '<meta http-equiv="Expires"       content="0">'
    '<script language=JavaScript src="/script/formatadadosie.js"></script>' SKIP
    '<link rel=StyleSheet type="text/css" href="/script/viacredi.css">' SKIP
    '<title>DEPÓSITO COM CAPTURA</title>' SKIP
    "</HEAD>":U SKIP
    '<body background="/images/moeda.jpg" bgproperties="fixed" class=fundo onLoad="JavaScript: click();" onKeyUp="callBLini(event); callBLsal(event);">' SKIP
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
         '  <td class=titulo height="19">DEPOSITO E TRANSFERENCIA ENTRE COOPERATIVAS</td>' SKIP
         '  <td width="21%" class=programa align="right">P.022b&nbsp; V.1.00</td>' SKIP
       ' </tr>' SKIP
      '</table>' SKIP
     '</center>' SKIP
    '</div>' SKIP.

    ASSIGN de_saldo = 0
           de_difer = 0.
    FOR EACH crapmdw WHERE crapmdw.cdcooper = crapcop.cdcooper
                       AND crapmdw.cdagenci = INT(v_pac) 
                       AND crapmdw.nrdcaixa = INT(v_caixa) NO-LOCK:
        ASSIGN de_saldo = de_saldo + crapmdw.vlcompel.
    END.
    ASSIGN de_difer = dec(get-value("v_vlrdocumento")) - de_saldo.
   
    {&OUT}
     '<div align="center">' SKIP
        '<center>' SKIP
          '<table cellspacing = 0 cellpadding= 0 width=100%>' SKIP
            '<tr>' SKIP
              '<td width="100%" valign="middle" align="center">' SKIP
                '<div align="center">'
                  '<center>' SKIP
                    '<table width="100%" cellspacing = 0 cellpadding = 1 class=tcampo>'  SKIP
                      '<tr>' SKIP
                        '<td colspan="2">&nbsp;</td>' SKIP
                      '</tr>' SKIP
                      '<tr>' SKIP
                        '<td class="linhaform" align="right"></td>' SKIP
                        '<td>' SKIP
                          '<table cellspacing="0" cellpadding="0" width="100%">' SKIP
                            '<tr>' SKIP
                              '<td class="linhaform">' SKIP
                                '<input type="radio" name="TpDocto" value="Deposito"      onClick=~'JavaScript:window.location =  "crap022.w?tpDoctoSel=Deposito"~'>Deposito em dinheiro' SKIP
                                '<input type="radio" name="TpDocto" value="Cheque"        onClick=""checked>Deposito em cheque' SKIP
                                '<input type="radio" name="TpDocto" value="Transferencia" onClick=~'JavaScript:window.location =  "crap022.w?tpDoctoSel=Transferencia"~'>Transferencia' SKIP
                              '</td>' SKIP
                            '</tr>' SKIP
                            '<tr>' SKIP
                              '<td class="linhaform" nowrap><hr></td>' SKIP
                            '</tr>' SKIP
                          '</table>' SKIP
                        '</td>' SKIP
                      '</tr>' SKIP
                    '</table>' SKIP
                  '</center>' SKIP
                '</div>' SKIP
              '</td>' SKIP
            '</tr>' SKIP
          '</table>' SKIP
        '</center>' SKIP
     '</div>' SKIP
     '<div align="center">'
       '<center>'
         '<table width=100% cellspacing = 0 cellpadding = 0>'
           '<tr>'
             '<td width="100%" valign="middle" align="center">'
               '<div align="center">'
                 '<center>'
                   '<table width="100%" cellspacing = 0 cellpadding = 1>'
                     '<tr>'
                       '<td align="right" class="linhaform">Cooperativa:</td>'
                       '<td nowrap class="linhaform">'
                         '<select name="v_cooppara" size="1" disabled><option value="'GET-VALUE("v_cooppara")'" >'GET-VALUE("v_cooppara")'</option></select>'
                       '</td>'
                     '</tr>'
                     '<tr>'
                       '<td width="18%" align="right" class="linhaform">Conta/DV:</td>'
                       '<td width="67%">'
                         '<input type="text" name="v_conta" size="10" class="input" style="text-align: right" value='GET-VALUE("v_nroconta")' disabled> &nbsp;'  SKIP
                       '</td>'
                     '</tr>'
                     '<tr>'
                       '<td align="right" class="linhaform">Tit1:&nbsp;</td>'
                       '<td><input type="text" id="v_nome1" name="v_nome1" size="42" class="input" maxlength="42" style="font-weight: bold" value="'GET-VALUE("v_nome1")'" disabled></td>'
                     '</tr>'
                     '<tr>'
                       '<td align="right" class="linhaform">CPF/CNPJ:&nbsp;</td>'
                       '<td><input type="text" name="v_cpfcgc1" size="18" class="input" maxlength="14" class="input" value="'GET-VALUE("v_cpfcgc1")'" disabled></td>'
                     '</tr>'
                     '<tr>'
                       '<td align="right" class="linhaform">Tit2:&nbsp;</td>'
                       '<td><input type="text" id="v_nome2" name="v_nome2" size="42" class="input" maxlength="42" style="font-weight: bold" value="'GET-VALUE("v_nome2")'" disabled></td>'
                     '</tr>'
                     '<tr>'
                       '<td align="right" class="linhaform">CPF/CNPJ:&nbsp;</td>'
                       '<td><input type="text" name="v_cpfcgc2" size="18" class="input" maxlength="18" class="input" value="'GET-VALUE("v_cpfcgc2")'" disabled></td>'
                     '</tr>'
                     '<tr>'
                       '<td align="right" class="linhaform" width="23%">Ident.Deposito:</td>'
                       '<td align="left" class="linhaform" width="77%">'
                         '<p align="left">'
                           '<input type="text" name="v_identificador" size="18" class="input" maxlength="18" value="'GET-VALUE("v_identificador")'" disabled></p>'
                       '</td>'
                     '</tr>'
                     '<tr>'
                       '<td align="right" class="linhaform" width="23%">Cheque Informado:</td>'
                       '<td align="left" class="linhaform" width="77%">'
                         '<input type="text" name="v_vlrdocumento" size="20" class="input" disabled maxlength="18" style="text-align: right" value="'GET-VALUE("v_vlrdocumento")'" disabled>&nbsp;'
                       '</td>'
                     '</tr>'
                     '<tr>'
                       '<td align="right" class="linhaform" width="23%">Cheque Processado:</td>'
                       '<td align="left" class="linhaform" width="77%">'
                         '<input type="text" name="v_valorproc" size="20" class="input" disabled maxlength="18" style="text-align: right" value="'string(de_saldo,"zzz,zzz,zzz,zz9.99")'" disabled>&nbsp;'
                       '</td>'
                     '</tr>'
                     '<tr>'
                       '<td align="right" class="linhaform" width="23%">Diferenca:</td>'
                       '<td align="left" class="linhaform" width="77%">'
                         '<input type="text" name="v_difer" size="20" class="input" disabled maxlength="18" style="text-align: right"
                         value="' string(de_difer,"zzz,zzz,zzz,zz9.99") '" disabled>' '&nbsp;'
                       '</td>'
                     '</tr>' SKIP.
   
                     FIND FIRST crapmdw WHERE crapmdw.cdcooper = crapcop.cdcooper  
                                          AND crapmdw.cdagenci = INT(v_pac) 
                                          AND crapmdw.nrdcaixa   = INT(v_caixa) NO-LOCK NO-ERROR.
              
                     IF AVAIL crapmdw THEN DO:
                         IF  get-value("ok") = "" THEN DO:
              
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
   
                     FOR EACH crapmdw  NO-LOCK WHERE crapmdw.cdcooper = crapcop.cdcooper
                                                 AND crapmdw.cdagenci = INT(v_pac) 
                                                 AND crapmdw.nrdcaixa = INT(v_caixa)
                                                 BREAK BY crapmdw.nrseqdig :
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
                           '<tr>'
                             '<td align="right" class="tcampo" style="BACKGROUND-COLOR:#FFFFCE; border=0" colspan=8>&nbsp; </td>'
                           '</tr>'
                           '<tr>'
                             '<td align="center" class="tcampo" style="BACKGROUND-COLOR:#FFFFCE; border=0" colspan=8>'
                               '<input type="submit" value="Incluir"   name="inclui" class="button">&nbsp;'
                               '<input type="submit" value="Excluir"   name="exclui" class="button">&nbsp;'
                               '<input type="submit" value="Finalizar" name="finaliza" class="button">&nbsp;'
                             '</td>'
                           '</tr>' SKIP.
                     {&OUT}
                    '<tr>'
                      '<td align="right" style="BACKGROUND-COLOR:#FFFFCE; border=0" colspan=8>&nbsp;</td></tr>' SKIP 
                   '</table>'
                 '</center>'
               '</div>'
             '</td>'
           '</tr>'.
         {&OUT}
         '</table>'
       '</center>'
     '</div>'.
     /*ASSIGN vh_foco = STRING(i-cont + 6).*/
     {&OUT}
         '<input type="hidden" name="vh_foco" value="' vh_foco '">'
         '<input type="hidden" name="v_nrsequni" value="' get-value("v_nrsequni") '">'
         '<input type="hidden" name="v_dtenvelo" value="' get-value("v_dtenvelo") '">'
         '<input type="hidden" name="v_nrterfin" value="' get-value("v_nrterfin") '">'
         '<input type="hidden" name="v_vlcomput" value="' get-value("v_vlcomput") '">'
         '<input type="hidden" name="v_vlenvelo" value="' get-value("v_vlenvelo") '">'
         '<div align="center">'
           '<table width="100%">'
             '<tr><td align="right" class="linhaform">'
               '<input align="right" type="submit" value="Depósito" name="dep"  class="button" >'
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

