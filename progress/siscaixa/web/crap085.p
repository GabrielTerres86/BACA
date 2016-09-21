
&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Procedure 
/* .............................................................................

   Programa: siscaixa/web/crap085.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Novembro/2007                    Ultima atualizacao: 13/12/2013

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Recebimento de Beneficios - BANCOOB

   Alteracoes: 15/08/2008 - Ajuste para leitura do cartao (Evandro).

               11/09/2008 - Bloqueio no botao OK para nao conseguir executar
                            mais de uma vez (Evandro).

               31/10/2008 - Ajuste para leitoras SuperPIN (Evandro).
               
               03/12/2008 - alterado o campo nrdocpcd para dsdocpcd(rosangela)
               
               21/01/2013 - Ajustes referente ao projeto Prova de Vida(Adriano).
               
               11/11/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (Guilherme Gielow)
   
               13/12/2013 - Adicionado validate para tabela craptab (Tiago).
   ......................................................................... */

/*--------------------------------------------------------------------------*/
/*  b1crap84.p   - Recebimento de Beneficios                                */
/*--------------------------------------------------------------------------*/

/*----------------------------------------------------------------------*/
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
                                                                      
DEFINE VARIABLE h-b1crap85       AS HANDLE                             NO-UNDO.
DEFINE VARIABLE h-b1wgen0091     AS HANDLE                             NO-UNDO.
DEFINE VARIABLE aux_corfundo     AS CHARACTER                          NO-UNDO.
DEFINE VARIABLE aux_tpbloque     AS INT                                NO-UNDO.
DEFINE VARIABLE aux_nmendter     AS CHAR                               NO-UNDO.
DEFINE VARIABLE aux_nmarqimp     AS CHAR                               NO-UNDO.
DEFINE VARIABLE aux_dscomand     AS CHAR                               NO-UNDO.
DEFINE VARIABLE c-fnc-javascript AS CHAR                               NO-UNDO.
DEFINE VARIABLE aux_setlinha     AS CHAR                               NO-UNDO.


DEF STREAM str_1.

DEF TEMP-TABLE tt-erro NO-UNDO LIKE craperr.

DEF TEMP-TABLE ab_unmap
    FIELD v_coop      AS CHAR
    FIELD v_pac       AS CHAR
    FIELD v_caixa     AS CHAR
    FIELD v_operador  AS CHAR
    FIELD v_data      AS CHAR
    FIELD v_rowid     AS CHAR
    FIELD v_msg       AS CHAR
    FIELD vh_foco     AS CHAR
    FIELD v_tela      AS CHAR
    

    FIELD nrbenefi    AS CHAR
    FIELD nrrecben    AS CHAR
    FIELD nmrecben    AS CHAR
    FIELD nrcpfcgc    AS CHAR
    FIELD nmmaeben    AS CHAR.

/* procedures de erro */ 
{dbo/bo-erro1.i}

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
  DEFINE VARIABLE h-b1crap00      AS HANDLE                 NO-UNDO.

  DEFINE VARIABLE aux_vlliquid    AS DEC                    NO-UNDO.
  DEFINE VARIABLE aux_vldoipmf    AS DEC                    NO-UNDO.
  DEFINE VARIABLE aux_cfrvipmf    AS DEC                    NO-UNDO.
  DEFINE VARIABLE aux_flgpgprd    AS LOGICAL                NO-UNDO.
  DEFINE VARIABLE aux_cdstatus    AS INTEGER                NO-UNDO.
  DEFINE VARIABLE aux_dscritic    AS CHARACTER              NO-UNDO.
  DEFINE VARIABLE p-literal       AS CHAR                   NO-UNDO.
  DEFINE VARIABLE p-ult-sequencia AS INTE                   NO-UNDO.
  DEFINE VARIABLE aux_flgexist    AS LOGICAL                NO-UNDO.
 
   
  RUN outputHeader.

  CREATE ab_unmap.

  {include/i-global.i}

  ASSIGN ab_unmap.v_tela = "crap085.p"
         c-fnc-javascript = "".

  RUN elimina-erro (INPUT ab_unmap.v_coop,
                    INPUT ab_unmap.v_pac,
                    INPUT ab_unmap.v_caixa).
 

  /* Montagem do HTML */
  {&OUT}
    "<HTML>":U SKIP
    "<HEAD>":U SKIP
    '<meta http-equiv="cache-control" content="no-cache">' SKIP
    '<meta http-equiv="Pragma"        content="No-Cache">'
    '<meta http-equiv="Expires"       content="0">'
    '<script language=JavaScript src="/script/formatadadosie.js"></script>' SKIP
    '<link rel=StyleSheet type="text/css" href="/script/viacredi.css">' SKIP
    '<title>INSS - BANCOOB</title>' SKIP.
    

  /* Funcoes JavaScript */
  {&OUT}
    '<script language="JavaScript">' SKIP

      'function habilita_cartao()~{' SKIP
        'document.all.v_nrcartao.style.visibility=~'visible~';' SKIP
        'document.all.v_nrcartao.disabled=false;' SKIP
        'document.all.v_nrbenefi.disabled=true;' SKIP
        'document.all.v_nrrecben.disabled=true;' SKIP
        'document.all.v_nrcartao.focus();' SKIP
      '~}' SKIP

      'function habilita_recibo()~{' SKIP
        'document.all.v_nrcartao.style.visibility=~'hidden~';' SKIP
        'document.all.v_nrcartao.disabled=true;' SKIP
        'document.all.v_nrbenefi.disabled=false;' SKIP
        'document.all.v_nrrecben.disabled=false;' SKIP
        'document.all.v_nrbenefi.focus();' SKIP
      '~}' SKIP

      'function habilita_campos()~{' SKIP
        'document.all.v_tpmepgto[0].disabled=false;' SKIP
        'document.all.v_tpmepgto[1].disabled=false;' SKIP
        'document.all.v_nrcartao.disabled=false;' SKIP
        'document.all.v_nrbenefi.disabled=false;' SKIP
        'document.all.v_nrrecben.disabled=false;' SKIP
      '~}' SKIP

      'function desabilita_campos()~{' SKIP
        'document.all.v_tpmepgto[0].disabled=true;' SKIP
        'document.all.v_tpmepgto[1].disabled=true;' SKIP
        'document.all.v_nrcartao.disabled=true;' SKIP
        'document.all.v_nrbenefi.disabled=true;' SKIP
        'document.all.v_nrrecben.disabled=true;' SKIP
      '~}' SKIP

      'function habilita_beneficios()~{' SKIP
        'document.all.ok.disabled=false;' SKIP
        'document.all.cancelar.disabled=false;' SKIP
        'if(document.all.opt_benefi.length != null)~{' SKIP
          'for(var i=0;i<document.all.opt_benefi.length;i++)' SKIP
            'document.all.opt_benefi[i].disabled=false;' SKIP
        '~}' SKIP
        'else~{' SKIP
          'document.all.opt_benefi.disabled=false;' SKIP
        '~}' SKIP
        'if(document.all.v_nmprocur.value!="")~{' SKIP
          'document.all.v_flgpgprd.disabled=false;' SKIP
        '~}' SKIP
      '~}' SKIP

      'function desabilita_beneficios()~{' SKIP
        'document.all.ok.disabled=true;' SKIP
        'document.all.cancelar.disabled=true;' SKIP
        'if(document.all.opt_benefi.length != null)~{' SKIP
          'for(var i=0;i<document.all.opt_benefi.length;i++)' SKIP
            'document.all.opt_benefi[i].disabled=true;' SKIP
        '~}' SKIP
        'else~{' SKIP
          'document.all.opt_benefi.disabled=true;' SKIP
        '~}' SKIP
        'document.all.v_flgpgprd.disabled=true;' SKIP
      '~}' SKIP


      'function paga_beneficio()~{' SKIP

         'var selecionou=false;' SKIP
      
         /* se tem beneficios a pagar */
         'if(document.all.opt_benefi != null)~{' SKIP
      
             'document.all.ok.disabled = true;' SKIP
        
             /* verifica se algum beneficio foi selecionado */
             'if(document.all.opt_benefi.length != null)~{' SKIP
               'for(var i=0;i<document.all.opt_benefi.length;i++)~{' SKIP
                 'if(document.all.opt_benefi[i].checked)' SKIP
                   'selecionou=true;' SKIP
               '~}' SKIP
             '~}' SKIP
             'else~{' SKIP
               'if(document.all.opt_benefi.checked)' SKIP
                 'selecionou=true;' SKIP
             '~}' SKIP
        
             'if(!selecionou)~{' SKIP
               'document.all.ok.disabled = false;' SKIP
               'document.all.v_comprova.value="";' SKIP
               'return false;' SKIP
             '~}' SKIP
        
             'if(document.all.v_tpmepgto[0].checked)~{' SKIP
               'desabilita_beneficios();' SKIP
               'document.all.div_senha.style.visibility="visible";' SKIP
               'document.all.v_senha.focus();' SKIP
             '~}' SKIP
             'else~{' SKIP
               'habilita_campos();' SKIP
               'document.forms[0].submit();' SKIP
             '~}' SKIP

         '~}' SKIP

      '~}' SKIP

      'function carrega_procurador(campo)~{' SKIP

          'document.all.v_nmprocur.value = document.all["v_nmprocur_" + campo].value;' SKIP
          'document.all.v_dsdocpcd.value = document.all["v_dsdocpcd_" + campo].value;' SKIP
          'document.all.v_cdoedpcd.value = document.all["v_cdoedpcd_" + campo].value;' SKIP
          'document.all.v_cdufdpcd.value = document.all["v_cdufdpcd_" + campo].value;' SKIP
          'document.all.v_flgpgprd.checked=false;' SKIP
          
          'if(document.all.v_nmprocur.value!="")~{' SKIP
              'document.all.v_flgpgprd.disabled=false;' SKIP
          '~}' SKIP
          'else~{' SKIP
              'document.all.v_flgpgprd.disabled=true;' SKIP
          '~}' SKIP
        
          'if(document.all["v_tpbloque_" + campo].value!=0)~{' SKIP

              'document.all.ok.disabled=true;' SKIP
        
              'if(document.all["v_tpbloque_" + campo].value==1)~{' SKIP
              
                  'alert("Beneficio bloqueado por falta de "      + 
                         "comprovacao de vida. Solicite "         + 
                         "documentacao com foto do "              + 
                         "beneficiario. \\nNecessario efetuar a " + 
                         "comprovacao.");' SKIP
              
              '~} else if(document.all["v_tpbloque_" + campo].value==2)~{' SKIP
              
                          'alert("Necessario efetuar a comprovacao de vida. "    + 
                                 "Solicite documentacao com foto do beneficiario.");' SKIP
              
              '~} else if(document.all["v_tpbloque_" + campo].value==3)~{' SKIP
              
                          'alert("Este beneficiario devera efetuar a comprovacao "  + 
                                 "de vida para este beneficio. "                    + 
                                 "A falta de renovacao implicara no bloqueio "      + 
                                 "do \\nbeneficio pelo INSS. Solicite documentacao com foto do beneficiario");' SKIP
              
              '~}' SKIP
        
        
          '~}else ~{' SKIP
               'document.all.ok.disabled=false;' SKIP
          '~}' SKIP

      '~}' SKIP

      'function alertaBloqueio()~{' SKIP

         'var nmdcampo = "";' SKIP

         'if(document.all.v_flgpgprd.checked)~{' SKIP

             /* pega o valor do campo "opt_benefi" selecionado */
             'if(document.all.opt_benefi.length != null)~{' SKIP
             
                 'for(var i=0;i<document.all.opt_benefi.length;i++)~{' SKIP
                      'if(document.all.opt_benefi[i].checked)~{' SKIP
                         'nmdcampo=document.all.opt_benefi[i].value;' SKIP
                      '~}' SKIP
                 
                 '~}' SKIP
             
             '~} else if(document.all.opt_benefi.checked)~{' SKIP
                        'nmdcampo=document.all.opt_benefi.value;' SKIP
             '~}' SKIP
             
             /*Se houver uma critica de comprovacao de vida mostra as respectivas mensagens*/
             'if(document.all["v_tpbloque_" + nmdcampo].value!=0)~{' SKIP
             
                  'if(document.all["v_tpbloque_" + nmdcampo].value==1)~{' SKIP

                      'alert("Beneficio bloqueado por falta de "     + 
                             "comprovacao de vida. Solicite "        + 
                             "documentacao do procurador. "          + 
                             "\\nNecessario efetuar a comprovacao.");' SKIP
                      
                  '~} else if(document.all["v_tpbloque_" + nmdcampo].value==2)~{' SKIP

                              'alert("Necessario efetuar a comprovacao de vida. "  + 
                                     "Solicite documentacao do procurador.");' SKIP

                   '~} else if(document.all["v_tpbloque_" + nmdcampo].value==3)~{' SKIP

                               'alert("Este beneficiario devera efetuar a comprovacao "  + 
                                      "de vida para este beneficio. "                    + 
                                      "A falta de renovacao implicara no bloqueio "      + 
                                       "do \\nbeneficio pelo INSS. Solicite documentacao com foto do procurador");' SKIP
                      
                  '~}' SKIP
             
             '~}' SKIP

         '~}' SKIP

      '~}'

    '</script>' SKIP.


  {&OUT}
    "</HEAD>":U SKIP
    '<body background="/images/moeda.jpg" bgproperties="fixed" class=fundo onLoad="JavaScript:mudaFoco(); click();" onKeyUp="callBLini(event); callBLsal(event);">' SKIP
    '<form onKeyDown="change_page(event)" method=post>' SKIP
    '<p style="word-spacing: 0; line-height: 100%; margin-top: 0; margin-bottom: 0">&nbsp;</p>'
    '<input type="hidden" name="vh_foco" value="">'
    '<input type="hidden" name="v_comprova" value="">'
    
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
    '</div>' SKIP
    '<div align="center">' SKIP
     '<center>' SKIP
      '<table width="100%" class=cabtab>' SKIP
       ' <tr>' SKIP
         '  <td class=titulo>INSS - BANCOOB</td>' SKIP
         '  <td width="21%" class=programa align="right">P.085&nbsp; V.1.00</td>' SKIP
       ' </tr>' SKIP
      '</table>' SKIP
     '</center>' SKIP
    '</div>' SKIP.



  IF REQUEST_METHOD = "POST"   THEN
     DO:
        RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.


        RUN valida-transacao IN h-b1crap00(INPUT v_coop,
                                           INPUT v_pac,
                                           INPUT v_caixa).

        IF RETURN-VALUE = "OK"   THEN
           RUN verifica-abertura-boletim IN h-b1crap00(INPUT v_coop,
                                                       INPUT v_pac,
                                                       INPUT v_caixa,
                                                       INPUT v_operador).

        DELETE PROCEDURE h-b1crap00.

        IF RETURN-VALUE = "NOK"   THEN 
           DO:
               {include/i-erro.i}
                  
               {&OUT} '<script language="JavaScript">' SKIP
                        'window.location=~'crap085.html~';' SKIP
                      '</script>' SKIP.

               LEAVE.

           END.

                                
        /*  Tabela com o horario limite para digitacao  */
        FIND craptab NO-LOCK WHERE craptab.cdcooper = crapcop.cdcooper AND
                                   craptab.nmsistem = "CRED"           AND
                                   craptab.tptabela = "GENERI"         AND
                                   craptab.cdempres = 0                AND
                                   craptab.cdacesso = "HRPGTOINSS"     AND
                                   craptab.tpregist = INT(v_pac)    
                                   NO-ERROR.
    
        IF NOT AVAILABLE craptab           OR 
           TIME >= INT(craptab.dstextab)   THEN  
           DO:
              RUN cria-erro (INPUT ab_unmap.v_coop,
                             INPUT INT(ab_unmap.v_pac),
                             INPUT INT(ab_unmap.v_caixa),
                             INPUT 676,
                             INPUT "",
                             INPUT YES).

              {include/i-erro.i}

              {&OUT} '<script language="JavaScript">' SKIP
                          'window.location=~'crap085.html~';' SKIP
                     '</script>' SKIP.
                     
              LEAVE.
              
           END.          

        /*Limpa a tab usada para geracao do conteudo do arquivo de comprovacao*/
        FOR EACH craptab WHERE craptab.cdcooper = crapcop.cdcooper      AND         
                               craptab.nmsistem = "CRED"                AND         
                               craptab.tptabela = "GENERI"              AND         
                               craptab.cdempres = INT(ab_unmap.v_caixa) AND         
                               craptab.cdacesso = ab_unmap.v_operador   AND
                               craptab.tpregist = INT(ab_unmap.v_pac)
                               EXCLUSIVE-LOCK:

            DELETE craptab.

        END.


        /* Se informou cartao, separa o NB do NIT */
        IF get-value("v_nrcartao") <> ""   THEN
           DO:  
              /* Se tiver 11 digitos eh NIT */
              IF LENGTH(STRING(DEC(SUBSTRING(get-value("v_nrcartao"),7,11)))) = 11 THEN
                 ab_unmap.nrrecben = TRIM(SUBSTRING(get-value("v_nrcartao"),7,11)).
              ELSE
                 ab_unmap.nrbenefi = TRIM(SUBSTRING(get-value("v_nrcartao"),7,11)).

           END.
        ELSE
           /* Le os campos informados na tela */
           ASSIGN ab_unmap.nrbenefi = get-value("v_nrbenefi")
                  ab_unmap.nrrecben = get-value("v_nrrecben").

        /* Busca o cadastro por NB */
        FIND crapcbi WHERE crapcbi.cdcooper = crapcop.cdcooper       AND
                           crapcbi.nrrecben = 0                      AND
                           crapcbi.nrbenefi = DEC(ab_unmap.nrbenefi)
                           NO-LOCK NO-ERROR.

        /* Busca o cadastro por NIT */
        IF NOT AVAILABLE crapcbi   THEN
           FIND crapcbi WHERE crapcbi.cdcooper = crapcop.cdcooper       AND
                              crapcbi.nrrecben = DEC(ab_unmap.nrrecben) AND
                              crapcbi.nrbenefi = 0
                              NO-LOCK NO-ERROR.       

        IF AVAILABLE crapcbi   THEN
           DO:
               ASSIGN ab_unmap.nrbenefi = STRING(crapcbi.nrbenefi,"9999999999")
                      ab_unmap.nrrecben = STRING(crapcbi.nrrecben,"99999999999")
                      ab_unmap.nmrecben = crapcbi.nmrecben
                      ab_unmap.nrcpfcgc = STRING(STRING(crapcbi.nrcpfcgc,"99999999999"),"xxx.xxx.xxx-xx")
                      ab_unmap.nmmaeben = crapcbi.nmmaeben.

               /* Paga o beneficio */
               IF get-value("opt_benefi") <> ""   THEN
                  DO:
                      /* Se for CARTAO, valida a senha */
                      IF get-value("v_tpmepgto") = "1"   THEN
                         DO:
                            /* A trilha lida pelo SuperPIN nao traz o "=" mas deve existir */

                            /* Chamada para a DLL que valida o cartao e a senha */
                            RUN fontes/bancoob_inss.p (INPUT  SUBSTRING(get-value("v_nrcartao"),1,17) + "=" +
                                                              SUBSTRING(get-value("v_nrcartao"),18),
                                                       INPUT  get-value("v_senha"),
                                                       INPUT  crapcop.cdagebcb,
                                                       OUTPUT aux_cdstatus,
                                                       OUTPUT aux_dscritic).

                            IF aux_cdstatus <> 0   THEN
                               DO:
                                  /* Cria o erro retornado pela DLL */
                                  RUN cria-erro (INPUT ab_unmap.v_coop,
                                                 INPUT INT(ab_unmap.v_pac),
                                                 INPUT INT(ab_unmap.v_caixa),
                                                 INPUT 0,
                                                 INPUT aux_dscritic,
                                                 INPUT YES).

                                  {include/i-erro.i}

                                  {&OUT} '<script language="JavaScript">' SKIP
                                              'window.location=~'crap085.html~';' SKIP
                                         '</script>' SKIP.

                                  LEAVE.

                               END.

                         END.

                      /* Pago ao procurador */
                      IF get-value("v_flgpgprd") = "on" THEN
                         ASSIGN aux_flgpgprd = YES.
                      ELSE
                         ASSIGN aux_flgpgprd = NO.


                      IF NOT VALID-HANDLE(h-b1wgen0091) THEN
                         RUN sistema/generico/procedures/b1wgen0091.p
                             PERSISTENT SET h-b1wgen0091.
                       
                      /*Verifica se existe um bloqueio referente a comprovacao de vida*/
                      ASSIGN aux_tpbloque = DYNAMIC-FUNCTION("verificacao_bloqueio" 
                                            IN h-b1wgen0091,                        
                                            INPUT crapcop.cdcooper,                  
                                            INPUT INT(ab_unmap.v_caixa),                
                                            INPUT INT(ab_unmap.v_pac),             
                                            INPUT ab_unmap.v_operador,             
                                            INPUT ab_unmap.v_tela,             
                                            INPUT 2, /*caixa on-line*/             
                                            INPUT DATE(ab_unmap.v_data),             
                                            INPUT crapcbi.nrcpfcgc,         
                                            INPUT (IF crapcbi.nrrecben <> 0 THEN 
                                                      crapcbi.nrrecben
                                                   ELSE
                                                      crapcbi.nrbenefi),
                                            INPUT 2 /*Ben. Especifico*/).


                      IF VALID-HANDLE(h-b1wgen0091) THEN
                         DELETE PROCEDURE h-b1wgen0091.

                      
                      /*Efetua a comprovacao de vida*/
                      IF get-value("v_comprova") = "OK" THEN
                         DO:
                             /*Comprovacao atraves do proprio beneficiario*/
                             IF get-value("v_flgpgprd") <> "on" THEN
                                DO:
                                    FIND crapope WHERE crapope.cdcooper = crapcop.cdcooper    AND
                                                       crapope.cdoperad = ab_unmap.v_operador
                                                       NO-LOCK NO-ERROR.
                                    
                                    ASSIGN aux_nmendter = crapope.cdoperad + ab_unmap.v_tela.
                                    
                                    IF NOT VALID-HANDLE(h-b1wgen0091) THEN
                                       RUN sistema/generico/procedures/b1wgen0091.p
                                           PERSISTENT SET h-b1wgen0091.
                                    
                                    RUN comprova_vida IN h-b1wgen0091(INPUT crapcop.cdcooper,
                                                                      INPUT ab_unmap.v_operador,
                                                                      INPUT INT(ab_unmap.v_caixa),
                                                                      INPUT DATE(ab_unmap.v_data),
                                                                      INPUT ab_unmap.v_tela,
                                                                      INPUT INT(ab_unmap.v_pac),
                                                                      INPUT 2, /*caixa on-line*/
                                                                      INPUT crapcbi.nrrecben,
                                                                      INPUT crapcbi.nrbenefi,
                                                                      INPUT crapcbi.nrcpfcgc,
                                                                      INPUT crapcbi.nmrecben,
                                                                      INPUT STRING(TIME,"HH:MM:SS"),
                                                                      INPUT 1,  /*Pelo Beneficiario*/
                                                                      INPUT "", /*nmprocur*/
                                                                      INPUT "", /*dsdocpcd*/
                                                                      INPUT "", /*cdoedpcd*/
                                                                      INPUT "", /*cdufdpcd*/
                                                                      INPUT ?,  /*dtvalprc*/
                                                                      INPUT aux_nmendter,
                                                                      OUTPUT aux_nmarqimp,
                                                                      OUTPUT TABLE tt-erro).
                                    
                                    IF VALID-HANDLE(h-b1wgen0091) THEN
                                       DELETE PROCEDURE h-b1wgen0091.
                                    
                                    IF RETURN-VALUE <> "OK" THEN
                                       DO:
                                          FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                    
                                          IF AVAIL tt-erro THEN
                                             {&OUT} '<script>' SKIP 
                                                         'alert('" + tt-erro.dscritic + "');' SKIP 
                                                         'window.location = "crap085.html";' SKIP 
                                                    '</script>' SKIP.    
                                          ELSE
                                             {&OUT} '<script>' SKIP 
                                                        'alert("Nao foi possivel comprovar vida pelo beneficiario.");' SKIP
                                                        'window.location = "crap085.html";' SKIP 
                                                    '</script>' SKIP.    
                                                
                                          LEAVE.
                                    
                                       END.
                                    
                                    
                                    INPUT STREAM str_1 FROM VALUE(aux_nmarqimp) NO-ECHO .
                                    
                                    /* Registros */
                                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                    
                                       IMPORT STREAM str_1 UNFORMATTED aux_setlinha.
                                        
                                    
                                       ASSIGN p-literal = p-literal + STRING(aux_setlinha,"X(48)").
                                    
                                    END.
                                    
                                    INPUT STREAM str_1 CLOSE. 
                                    
                                    
                                    FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper      AND         
                                                       craptab.nmsistem = "CRED"                AND         
                                                       craptab.tptabela = "GENERI"              AND         
                                                       craptab.cdempres = INT(ab_unmap.v_caixa) AND         
                                                       craptab.cdacesso = ab_unmap.v_operador   AND
                                                       craptab.tpregist = INT(ab_unmap.v_pac)
                                                       NO-LOCK NO-ERROR.
                                    
                                    IF NOT AVAILABLE craptab THEN
                                       DO:
                                          CREATE craptab.
                                    
                                          ASSIGN craptab.cdcooper = crapcop.cdcooper
                                                 craptab.nmsistem = "CRED"
                                                 craptab.tptabela = "GENERI"
                                                 craptab.cdempres = INT(ab_unmap.v_caixa)
                                                 craptab.cdacesso = ab_unmap.v_operador
                                                 craptab.tpregist = INT(ab_unmap.v_pac)
                                                 craptab.dstextab = p-literal.
                                          VALIDATE craptab.
                                       END.
                                    
                                    ASSIGN p-ult-sequencia = 99999.
                                    
                                    {&OUT} '<script> alert("Comprovacao de vida efetuada com sucesso. Realize o pagamento do beneficio");
                                                     window.open("autentica.html?v_plit=crap085&v_pseq=" + 
                                                              "' p-ult-sequencia '" + "&v_prec=" + "yes" +
                                                              "&v_psetcook=" + "no","waut", 
                                          "width=250,height=145,scrollbars=auto,alwaysRaised=true,left=0,top =0")
                                                              </script>'. 
                                      
                                    
                               END.
                            ELSE
                               DO: /*Comprovacao de vida atraves do procurador*/
                                   FIND crapope WHERE crapope.cdcooper = crapcop.cdcooper    AND
                                                      crapope.cdoperad =  ab_unmap.v_operador
                                                      NO-LOCK NO-ERROR.

                                   ASSIGN aux_nmendter = crapope.cdoperad + ab_unmap.v_tela.

                                   IF NOT VALID-HANDLE(h-b1wgen0091) THEN
                                      RUN sistema/generico/procedures/b1wgen0091.p
                                          PERSISTENT SET h-b1wgen0091.
                                   
                                   FIND crappbi WHERE crappbi.cdcooper = crapcbi.cdcooper AND
                                                      crappbi.nrrecben = crapcbi.nrrecben AND
                                                      crappbi.nrbenefi = crapcbi.nrbenefi
                                                      NO-LOCK NO-ERROR.
                                   
                                   IF NOT AVAIL crappbi THEN
                                      DO:
                                         {&OUT} '<script>' SKIP 
                                                     'alert("Procurador nao cadastrado pelo INSS. ' +
                                                            'Comprovacao nao permitida.");' SKIP
                                                     'window.location = "crap085.html";' SKIP 
                                                '</script>' SKIP.    
                                                 
                                         LEAVE.
                                   
                                      END.
                                   
                                   IF crappbi.dtvalprc < DATE(ab_unmap.v_data) THEN
                                      DO:
                                         {&OUT} '<script>' SKIP 
                                                     'alert("Procurador com validade ja expirada.");' SKIP
                                                     'window.location = "crap085.html";' SKIP 
                                                '</script>' SKIP.    
                                                 
                                         LEAVE.

                                      END.

                                        
                                   RUN comprova_vida IN h-b1wgen0091(INPUT crapcop.cdcooper,
                                                                     INPUT ab_unmap.v_operador,
                                                                     INPUT INT(ab_unmap.v_caixa),
                                                                     INPUT DATE(ab_unmap.v_data),
                                                                     INPUT ab_unmap.v_tela,
                                                                     INPUT INT(ab_unmap.v_pac),
                                                                     INPUT 2, /*caixa on-line*/
                                                                     INPUT crapcbi.nrrecben,
                                                                     INPUT crapcbi.nrbenefi,
                                                                     INPUT crapcbi.nrcpfcgc,
                                                                     INPUT crapcbi.nmrecben,
                                                                     INPUT STRING(TIME,"HH:MM:SS"),
                                                                     INPUT 2,  /*Pelo procurador*/
                                                                     INPUT crappbi.nmprocur, 
                                                                     INPUT crappbi.dsdocpcd, 
                                                                     INPUT crappbi.cdoedpcd, 
                                                                     INPUT crappbi.cdufdpcd, 
                                                                     INPUT crappbi.dtvalprc, 
                                                                     INPUT aux_nmendter,
                                                                     OUTPUT aux_nmarqimp,
                                                                     OUTPUT TABLE tt-erro).
                                   
                                   IF VALID-HANDLE(h-b1wgen0091) THEN
                                      DELETE PROCEDURE h-b1wgen0091.
                                   
                                   IF RETURN-VALUE <> "OK" THEN
                                      DO:
                                         FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                   
                                         IF AVAIL tt-erro THEN
                                            {&OUT} '<script>' SKIP 
                                                         'alert('" + tt-erro.dscritic + "');' SKIP 
                                                         'window.location = "crap085.html";' SKIP 
                                                   '</script>' SKIP.    
                                         ELSE
                                            {&OUT} '<script>' SKIP 
                                                         'alert("Nao foi possivel comprovar vida pelo procurador.");' SKIP
                                                         'window.location = "crap085.html";' SKIP 
                                                    '</script>' SKIP.    
                                               
                                         LEAVE.
                                   
                                      END.

                                   INPUT STREAM str_1 FROM VALUE(aux_nmarqimp) NO-ECHO .
                                   
                                   /* Registros */
                                   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                   
                                      IMPORT STREAM str_1 UNFORMATTED aux_setlinha.
                                       

                                      ASSIGN p-literal = p-literal + STRING(aux_setlinha,"X(48)").
                                   
                                   END.

                                   INPUT STREAM str_1 CLOSE. 


                                   FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper      AND         
                                                      craptab.nmsistem = "CRED"                AND         
                                                      craptab.tptabela = "GENERI"              AND         
                                                      craptab.cdempres = INT(ab_unmap.v_caixa) AND         
                                                      craptab.cdacesso = ab_unmap.v_operador   AND
                                                      craptab.tpregist = INT(ab_unmap.v_pac)
                                                      NO-LOCK NO-ERROR.

                                   IF NOT AVAILABLE craptab THEN
                                      DO:
                                         CREATE craptab.

                                         ASSIGN craptab.cdcooper = crapcop.cdcooper
                                                craptab.nmsistem = "CRED"
                                                craptab.tptabela = "GENERI"
                                                craptab.cdempres = INT(ab_unmap.v_caixa)
                                                craptab.cdacesso = ab_unmap.v_operador
                                                craptab.tpregist = INT(ab_unmap.v_pac)
                                                craptab.dstextab = p-literal.
                                         VALIDATE craptab.
                                      END.

                                   ASSIGN p-ult-sequencia = 99999.

                                   {&OUT} '<script> alert("Comprovacao de vida efetuada com sucesso. Realize o pagamento do beneficio");
                                                    window.open("autentica.html?v_plit=crap085&v_pseq=" + 
                                                                "' p-ult-sequencia '" + "&v_prec=" + "yes" +
                                                                "&v_psetcook=" + "no","waut", 
                                            "width=250,height=145,scrollbars=auto,alwaysRaised=true,left=0,top =0")
                                                                </script>'. 
                            
                               END.
                               
                         END.
                      ELSE
                         DO:
                             RUN dbo/b1crap85.p PERSISTENT SET h-b1crap85.
                                     

                             RUN paga_beneficio IN h-b1crap85(INPUT  ab_unmap.v_coop,
                                                              INPUT  INT(ab_unmap.v_pac),
                                                              INPUT  INT(ab_unmap.v_caixa),
                                                              INPUT  ab_unmap.v_operador,
                                                              INPUT  DATE(ab_unmap.v_data),
                                                              INPUT  TO-ROWID(get-value("opt_benefi")),
                                                              INPUT  INT(get-value("v_tpmepgto")),
                                                              INPUT  aux_flgpgprd,
                                                              OUTPUT p-literal,
                                                              OUTPUT p-ult-sequencia).
                             
                             
                             DELETE PROCEDURE h-b1crap85.

                             IF RETURN-VALUE = "NOK"   THEN
                                DO:
                                    {include/i-erro.i}

                                    {&OUT} '<script language="JavaScript">' SKIP
                                             'window.location=~'crap085.html~';' SKIP
                                           '</script>' SKIP.
                             
                                    LEAVE.
                             
                                END.
                             
                             /* abre a tela que faz a impressao da autenticacao */
                             {&OUT} '<script>' SKIP 
                                         'window.open("autentica.html?v_plit=" + "' p-literal '" + 
                                                      "&v_pseq=" + "' p-ult-sequencia '" + 
                                                      "&v_prec=" + "YES"  +
                                                      "&v_psetcook=" + 
                                                      "yes","waut","width=250,height=145,scrollbars=auto,alwaysRaised=true")' SKIP
                                     '</script>'.
                             
                         END.
                           
                  END.

           END.
        ELSE
           DO:
               /* Cria o erro de beneficio nao encontrado e reinicia a tela */
               RUN cria-erro (INPUT ab_unmap.v_coop,
                              INPUT INT(ab_unmap.v_pac),
                              INPUT INT(ab_unmap.v_caixa),
                              INPUT 0,
                              INPUT "Beneficio nao encontrado!",
                              INPUT YES).

               {include/i-erro.i}

               {&OUT} '<script language="JavaScript">' SKIP
                          'window.location=~'crap085.html~';' SKIP
                      '</script>' SKIP.

               LEAVE.

           END.

     END.

  {&OUT}
    '<div align="center">' SKIP
      '<center>' SKIP
        '<table width=100% cellspacing = 0 cellpadding = 0>' SKIP
          '<tr>' SKIP
            '<td width="100%" valign="middle" align="center">' SKIP
              '<div align="center">' SKIP
                '<center>' SKIP
                  '<table width="100%" cellspacing = 0 cellpadding = 1 class=tcampo border=0>' SKIP
                    '<tr>' SKIP
                      '<td align="center" class="linhaform" colspan="2">&nbsp;&nbsp;</td>' SKIP
                    '</tr>' SKIP
                    '<tr>' SKIP
                      '<td width="18%" align="left" class="linhaform">' SKIP
                        '<input type="radio" value="1" name="v_tpmepgto" onclick="habilita_cartao();" ' IF get-value("v_tpmepgto") = "1" THEN 'checked' ELSE '' IF REQUEST_METHOD = "POST" THEN ' disabled' ELSE '' '>Cartao Magnetico' SKIP
                      '</td>' SKIP
                      '<td width="18%" align="left" class="linhaform" colspan="2">' SKIP
                        '<input type="radio" value="2" name="v_tpmepgto" onclick="habilita_recibo();" ' IF get-value("v_tpmepgto") = "2" THEN 'checked' ELSE '' IF REQUEST_METHOD = "POST" THEN ' disabled' ELSE '' '>Recibo' SKIP
                      '</td>' SKIP
                    '</tr>' SKIP
                    '<tr>' SKIP
                      '<td width="18%" align="left" class="linhaform" colspan="3">' SKIP
                        '<input type="text" name="v_nrcartao" size="41" maxlength="36" class="input" OnKeyUp="Javascript:preenchimento(event,0,this,36,~'submit~')" style="visibility:~'hidden~'" value="' get-value("v_nrcartao") '" disabled>' SKIP
                      '</td>' SKIP
                    '</tr>' SKIP
                    '<tr>' SKIP
                      '<td align="left" class="linhaform" colspan="3"><hr></td>' SKIP
                    '</tr>' SKIP.

  {&OUT}            '<tr>' SKIP
                      '<td width="18%" align="left" class="linhaform">' SKIP
                        'NB: <input type="text" name="v_nrbenefi" size="10" maxlength="10" class="input" OnKeyDown="JavaScript:validaInteiro(event)" OnKeyUp="Javascript:preenchimento(event,0,this,10,~'submit~')" value="' ab_unmap.nrbenefi '" disabled>' SKIP
                      '</td>' SKIP
                      '<td width="18%" align="left" class="linhaform" colspan="2">' SKIP
                        'NIT: <input type="text" name="v_nrrecben" size="11" maxlength="11" class="input" OnKeyDown="JavaScript:validaInteiro(event)" OnKeyUp="Javascript:preenchimento(event,0,this,11,~'submit~')" value="' ab_unmap.nrrecben '" disabled>' SKIP
                      '</td>' SKIP
                    '</tr>' SKIP
                    '<tr>' SKIP
                      '<td align="left" class="linhaform" colspan="3"><hr></td>' SKIP
                    '</tr>' SKIP
                    '<tr>' SKIP
                      '<td width="57%" align="left" class="linhaform">' SKIP
                        'Nome: <input type="text" name="v_nmrecben" class="input" size="40" disabled value="' ab_unmap.nmrecben '">' SKIP
                      '</td>' SKIP
                      '<td width="18%" align="left" class="linhaform" colspan="2">' SKIP
                        'CPF: <input type="text" name="v_nrcpfcgc" class="input" size="14" disabled value="' ab_unmap.nrcpfcgc '">' SKIP
                      '</td>' SKIP
                    '</tr>' SKIP
                    '<tr>' SKIP
                      '<td width="25%" align="left" class="linhaform" colspan="3">' SKIP
                        'Nome da Mae: <input type="text" name="v_nmmaeben" class="input" size="40" disabled value="' ab_unmap.nmmaeben '">' SKIP
                      '</td>' SKIP
                    '</tr>' SKIP
                    '<tr>' SKIP
                      '<td align="left" class="linhaform" colspan="3"><hr></td>' SKIP
                    '</tr>' SKIP
                    '<tr>' SKIP
                      '<td width="25%" align="left" class="linhaform" colspan="3">' SKIP
                        'Procurador: <input type="text" name="v_nmprocur" class="input" size="40" disabled value="">' SKIP
                      '</td>' SKIP
                    '</tr>' SKIP
                    '<tr>' SKIP
                      '<td width="25%" align="left" class="linhaform">' SKIP
                        'Identidade: <input type="text" name="v_dsdocpcd" class="input" size="12" disabled value="">' SKIP
                      '</td>' SKIP
                      '<td width="26%" align="left" class="linhaform">' SKIP
                        'O.E: <input type="text" name="v_cdoedpcd" class="input" size="10" disabled value="">' SKIP
                      '</td>' SKIP
                      '<td width="15%" align="left" class="linhaform">' SKIP
                        'UF: <input type="text" name="v_cdufdpcd" class="input" size="2" disabled value="">' SKIP
                      '</td>' SKIP
                    '</tr>' SKIP
                    '<tr>' SKIP
                      '<td width="25%" align="left" class="linhaform" colspan="3">' SKIP
                        '<input type="checkbox" name="v_flgpgprd" DISABLED onclick="alertaBloqueio();">Pagamento ao procurador' SKIP
                      '</td>' SKIP
                    '</tr>' SKIP
                    '<tr>' SKIP
                      '<td align="left" class="linhaform" colspan="3"><hr></td>' SKIP
                    '</tr>' SKIP.


  IF REQUEST_METHOD = "POST"   THEN
     DO:
        /* Cabecalho */
        {&OUT} '<tr>' SKIP
                 '<td align="left" class="linhaform" colspan="3">' SKIP
                   '<table width=100% cellspacing=0 cellpadding=1 border=1>' SKIP
                     '<tr>' SKIP
                       '<td class=titulo style="BACKGROUND-COLOR:#2D862D; border=0" align="center">Pagar</td>'  SKIP
                       '<td class=titulo style="BACKGROUND-COLOR:#2D862D; border=0" align="right">Beneficio</td>'  SKIP
                       '<td class=titulo style="BACKGROUND-COLOR:#2D862D; border=0" align="right">Valor</td>'  SKIP
                       '<td class=titulo style="BACKGROUND-COLOR:#2D862D; border=0" align="right">Inicio Periodo</td>'  SKIP
                       '<td class=titulo style="BACKGROUND-COLOR:#2D862D; border=0" align="right">Fim Periodo</td>'  SKIP
                       '<td class=titulo style="BACKGROUND-COLOR:#2D862D; border=0" align="right">Natureza</td>'  SKIP
                    '</tr>'  SKIP.
  
        /* BO com o calculo do CPMF */
        RUN dbo/b1crap85.p PERSISTENT SET h-b1crap85.

        /* Lista de creditos que podem ser pagos */
        ASSIGN aux_corfundo = "#bee9be".

        IF AVAILABLE crapcbi   THEN
           DO:
               IF DEC(ab_unmap.nrrecben) <> 0   THEN
                  ASSIGN ab_unmap.nrbenefi = "?".
               ELSE
               IF DEC(ab_unmap.nrbenefi) <> 0   THEN
                  ASSIGN ab_unmap.nrrecben = "?".

               ASSIGN aux_flgexist = NO.

               FOR EACH craplbi WHERE (craplbi.cdcooper  = crapcop.cdcooper             AND
                                       craplbi.nrrecben  = DECIMAL(ab_unmap.nrrecben)   AND
                                       craplbi.dtinipag <= DATE(ab_unmap.v_data)        AND
                                       craplbi.dtfimpag >= DATE(ab_unmap.v_data)        AND
                                       craplbi.tpmepgto  = 1 /* Cartao ou recibo */     AND
                                      (craplbi.cdsitcre  = 1 /* Nao bloqueado */        OR
                                       craplbi.cdbloque  = 9) /*Falta comp. vida*/      AND
                                       craplbi.dtdpagto  = ?) /* Nao pago */                  OR

                                      (craplbi.cdcooper  = crapcop.cdcooper             AND 
                                       craplbi.nrbenefi  = DECIMAL(ab_unmap.nrbenefi)   AND 
                                       craplbi.dtinipag <= DATE(ab_unmap.v_data)        AND 
                                       craplbi.dtfimpag >= DATE(ab_unmap.v_data)        AND 
                                       craplbi.tpmepgto  = 1 /* Cartao ou recibo */     AND 
                                      (craplbi.cdsitcre  = 1 /* Nao bloqueado */        OR 
                                       craplbi.cdbloque  = 9 ) /*Falta comp. vida*/     AND 
                                       craplbi.dtdpagto  = ?) /* Nao pago */                 
                                       NO-LOCK BREAK BY craplbi.nrbenefi
                                                       BY craplbi.dtiniper
                                                         BY craplbi.nrseqcre
                                                           BY craplbi.vllanmto:

                   ASSIGN aux_flgexist = YES.

                   IF FIRST-OF(craplbi.nrbenefi)   THEN
                      IF aux_corfundo = ""   THEN
                         ASSIGN aux_corfundo = "#bee9be".
                      ELSE
                         ASSIGN aux_corfundo = "".

                    /* Procurador do benefício */
                    FIND crappbi WHERE crappbi.cdcooper = craplbi.cdcooper   AND
                                       crappbi.nrrecben = craplbi.nrrecben   AND
                                       crappbi.nrbenefi = craplbi.nrbenefi
                                       NO-LOCK NO-ERROR.


                    RUN calcula_cpmf IN h-b1crap85(INPUT  v_coop,
                                                   INPUT  INT(v_pac),
                                                   INPUT  INT(v_caixa),
                                                   INPUT  DATE(v_data),
                                                   INPUT  craplbi.vllanmto,
                                                   OUTPUT aux_vlliquid,
                                                   OUTPUT aux_vldoipmf,
                                                   OUTPUT aux_cfrvipmf).

                    IF RETURN-VALUE = "NOK"   THEN
                       DO:
                           DELETE PROCEDURE h-b1crap85.

                           {include/i-erro.i}

                           {&OUT} '<script language="JavaScript">' SKIP
                                      'window.location=~'crap085.html~';' SKIP
                                  '</script>' SKIP.

                           LEAVE.
                            
                       END.

                    IF NOT VALID-HANDLE(h-b1wgen0091) THEN
                       RUN sistema/generico/procedures/b1wgen0091.p
                           PERSISTENT SET h-b1wgen0091.
                      
                    /*Verifica se existe um bloqueio referente a comprovacao de vida*/
                    ASSIGN aux_tpbloque = DYNAMIC-FUNCTION("verificacao_bloqueio" 
                                          IN h-b1wgen0091,                        
                                          INPUT crapcop.cdcooper,                  
                                          INPUT INT(ab_unmap.v_caixa),                
                                          INPUT INT(ab_unmap.v_pac),             
                                          INPUT ab_unmap.v_operador,             
                                          INPUT ab_unmap.v_tela,             
                                          INPUT 2, /*caixa on-line*/             
                                          INPUT DATE(ab_unmap.v_data),             
                                          INPUT crapcbi.nrcpfcgc,         
                                          INPUT (IF crapcbi.nrrecben <> 0 THEN 
                                                    crapcbi.nrrecben
                                                 ELSE
                                                    crapcbi.nrbenefi),
                                          INPUT 2 /*Ben. Especifico*/).


                    IF VALID-HANDLE(h-b1wgen0091) THEN
                       DELETE PROCEDURE h-b1wgen0091.

                    {&OUT} '<tr>' SKIP
                             '<td class="campos" align="center" style="BACKGROUND-COLOR:' aux_corfundo ';">' SKIP
                                  '<input type="radio" name="opt_benefi" value="' STRING(ROWID(craplbi)) '" onclick="carrega_procurador(this.value);">' SKIP
                             '</td>' SKIP
                             '<td class="campos" align="right"  style="BACKGROUND-COLOR:' aux_corfundo ';">' STRING(craplbi.nrbenefi,"9999999999") '</td>' SKIP
                             '<td class="campos" align="right"  style="BACKGROUND-COLOR:' aux_corfundo ';">' STRING(aux_vlliquid,"zzz,zzz,zz9.99") '</td>' SKIP
                             '<td class="campos" align="right"  style="BACKGROUND-COLOR:' aux_corfundo ';">' STRING(craplbi.dtiniper,"99/99/9999") '</td>' SKIP
                             '<td class="campos" align="right"  style="BACKGROUND-COLOR:' aux_corfundo ';">' STRING(craplbi.dtfimper,"99/99/9999") '</td>' SKIP
                             '<td class="campos" align="right"  style="BACKGROUND-COLOR:' aux_corfundo ';">' STRING(craplbi.nrseqcre,"99")         '</td>' SKIP
                             '<input type="hidden" name="v_nmprocur_' STRING(ROWID(craplbi)) '" value="' IF AVAILABLE crappbi THEN crappbi.nmprocur         ELSE '' '">' SKIP
                             '<input type="hidden" name="v_dsdocpcd_' STRING(ROWID(craplbi)) '" value="' IF AVAILABLE crappbi THEN 
                             crappbi.dsdocpcd ELSE '' '">' SKIP
                             '<input type="hidden" name="v_cdoedpcd_' STRING(ROWID(craplbi)) '" value="' IF AVAILABLE crappbi THEN crappbi.cdoedpcd         ELSE '' '">' SKIP
                             '<input type="hidden" name="v_cdufdpcd_' STRING(ROWID(craplbi)) '" value="' IF AVAILABLE crappbi THEN crappbi.cdufdpcd         ELSE '' '">' SKIP
                             '<input type="hidden" name="v_tpbloque_' STRING(ROWID(craplbi)) '" value="' aux_tpbloque '">' SKIP
                           '</tr>' SKIP.

               END.

               /* Caso nao exista beneficios a pagar, coloca a mensagem */
               IF aux_flgexist = NO   THEN
                  DO:
                     {&OUT} '<tr>' SKIP
                              '<td class="campos" align="center" colspan="6">' SKIP
                                'Nao ha creditos disponiveis para pagamento.' SKIP
                              '</td>' SKIP
                            '</tr>' SKIP.

                  END.

           END.
        
        DELETE PROCEDURE h-b1crap85.

        {&OUT}     '</table>' SKIP
                 '</td>' SKIP
               '</tr>' SKIP.

     END.


  {&OUT}            '<tr>' SKIP
                      '<td align="center" class="linhaform" colspan="3">&nbsp;</td>' SKIP
                    '</tr>' SKIP
                    '<tr>' SKIP
                      '<td align="center" class="linhaform" colspan="3">' SKIP
                        '<input type="button" value="OK" name="ok" class="button" onclick="paga_beneficio();">' SKIP
                        '<input type="button" value="Comprovar" name="comprovar" class="button" onclick="document.all.v_comprova.value=~'OK~';paga_beneficio();">' SKIP
                        '<input type="button" value="Cancelar" name="cancelar" class="button" onclick="window.location=~'crap085.html~'">' SKIP
                      '</td>' SKIP
                    '</tr>' SKIP
                    '<tr>' SKIP
                      '<td align="center" class="linhaform" colspan="3">&nbsp;</td>' SKIP
                    '</tr>' SKIP
                  '</table>' SKIP
                '</center>' SKIP
              '</div>' SKIP
            '</td>' SKIP
          '</tr>' SKIP
        '</table>' SKIP
      '</center>' SKIP
    '</div>' SKIP.

  /* div da janela que solicita a senha */
  {&OUT} '<div id="div_senha" style="position:absolute; border:0px; width:200px; height:100; z-index:1; left: 120px; top: 150px; BACKGROUND-COLOR:#2D862D; visibility:hidden">' SKIP
           '<table align="center" width="190px" height="90px" cellspacing = 0 cellpadding = 1 class="tcampo" border="0" style="margin-top:5px;">' SKIP
             '<tr>' SKIP
               '<td align="right" class="linhaform">Senha:</td>' SKIP
               '<td align="left" class="linhaform">' SKIP
                 '<input class=input type="password" name="v_senha" size="4" maxlength="4" OnKeyDown="JavaScript:validaInteiro(event); if(event.keyCode==13) senha_ok.click();">' SKIP
               '</td>' SKIP
             '</tr>' SKIP
             '<tr>' SKIP
               '<td align="center" class="linhaform" colspan="2">' SKIP
                 '<input type="button" value="OK" name="senha_ok" class="button" onclick="habilita_campos(); habilita_beneficios(); document.forms[0].submit();">' SKIP
                 '<input type="button" value="Cancelar" name="senha_cancelar" class="button" onclick="document.all.v_senha.value=~'~'; habilita_beneficios(); document.all.div_senha.style.visibility=~'hidden~';">' SKIP
               '</td>' SKIP
             '</tr>' SKIP
           '</table>' SKIP
         '</div>' SKIP.

  {&OUT} 
    "</form>":U SKIP
    "</BODY>":U SKIP
    "</HTML>":U SKIP.
   

  {&OUT} '<script type="text/javascript">' SKIP
             'document.all.v_comprova.value="";' SKIP
         '</script>' SKIP.
   
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

