/* .............................................................................

   Programa: siscaixa/web/crap089a.p
   Sistema : Caixa On-line
   Sigla   : CRED   
   Autor   : Guilherme/SUPERO
   Data    : Outubro/2015                      Ultima atualizacao:  / /

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Cancelar Agendamentos GPS INSS

   Alteracoes: 
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
DEFINE VARIABLE h-b1crap02 AS HANDLE     NO-UNDO.

DEF TEMP-TABLE tt-erro NO-UNDO LIKE craperr.

/* Temp-Table and Buffer definitions                                    */
DEF TEMP-TABLE ab_unmap
    FIELD v_coop      AS CHAR
    FIELD v_pac       AS CHAR
    FIELD v_caixa     AS CHAR
    FIELD v_operador  AS CHAR
    FIELD v_data      AS CHAR
    FIELD vh_foco     AS CHAR
    FIELD v_msg       AS CHAR.

DEF TEMP-TABLE tt-dados NO-UNDO
    FIELD dsdrowid  AS CHAR
    FIELD nrseqagp  AS INTE
    FIELD cdagenci  AS INTE
    FIELD nrdcaixa  AS INTE
    FIELD cddpagto  AS INTE
    FIELD dsperiod  AS CHAR
    FIELD cdidenti  AS CHAR
    FIELD vlrtotal  AS DECI
    FIELD dspesgps  AS CHAR
    FIELD dtdebito  AS CHAR  
    FIELD insituac  AS INTE.


DEF VAR l-ok            AS LOG INIT NO.
DEF VAR data            AS CHAR FORMAT "99/99/9999".
DEF VAR d-data          AS DATE FORMAT 99/99/9999.
DEF VAR c-conta         LIKE crapass.nrdconta.
DEF VAR v-log           AS CHAR.

DEF VAR aux_nrseqagp     AS INTEGER                                 NO-UNDO.
DEF VAR aux_cdcritic     AS INTEGER                                 NO-UNDO.
DEF VAR aux_dscritic     AS CHAR                                    NO-UNDO.
DEF VAR xml_req          AS LONGCHAR                                NO-UNDO.
DEF VAR aux_controle     AS LOGICAL                                 NO-UNDO.

/* Variaveis para o XML */
DEF VAR xDoc          AS HANDLE                                     NO-UNDO.
DEF VAR xRoot         AS HANDLE                                     NO-UNDO.
DEF VAR xRoot2        AS HANDLE                                     NO-UNDO.
DEF VAR xField        AS HANDLE                                     NO-UNDO.
DEF VAR xText         AS HANDLE                                     NO-UNDO.
DEF VAR aux_cont_raiz AS INTEGER                                    NO-UNDO.
DEF VAR aux_cont_perf AS INTEGER                                    NO-UNDO.
DEF VAR ponteiro_xml  AS MEMPTR                                     NO-UNDO.
DEF VAR aux_linhadig  AS CHAR                                       NO-UNDO.

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
  
  vh_foco = "7".


  /* Se nao informou a conta, retorna para crap089 */
  IF  get-value("v_cta") = "" THEN 
        {&OUT} "<script>alert('Conta não foi informada!');window.location='crap089.htm?redir=1'"
               ";</script>".


  IF  REQUEST_METHOD = "POST":U THEN DO:

      IF  get-value("b_voltar") <> "" THEN DO:
          EMPTY TEMP-TABLE tt-dados.
          ASSIGN vh_foco     = "7".

          {&OUT} '<script>' SKIP 
                 '    location="crap089.htm?redir=1&v_conta=' get-value("v_cta") '&v_nome=' get-value("v_nom") '";' SKIP
                 '</script>' SKIP.
      END.

      IF  get-value("b_desativa") <> "" THEN DO:

          /* Verificar se tem algo clicado 
             Se nao tem, criticar */
          IF  get-value("nrseqagp") = "" THEN DO:

              IF  aux_controle = TRUE THEN
                  {&OUT} '<script>' SKIP 
                         '    alert("Não há nada para ser cancelado!");' SKIP
                         '</script>' SKIP.
              ELSE
                  {&OUT} '<script>' SKIP 
                         '    alert("Você deve selecionar um agendamento para cancelar!");' SKIP
                         '</script>' SKIP.
          END.
          ELSE DO:
              /** Se tiver algo selecionado...
                  processa cancelamento */

              /** Efetuar a Desativacao do Agendamentos selecionado **/
              { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
              
              FOR FIRST crapcop FIELDS (cdcooper) 
                  WHERE crapcop.nmrescop = v_coop NO-LOCK.
              END.
              
              RUN STORED-PROCEDURE pc_gps_agmto_desativar
                      aux_handproc = PROC-HANDLE NO-ERROR
                     (INPUT crapcop.cdcooper,
                      INPUT DECI(get-value("v_cta")),
                      INPUT 2, /* idorigem */
                      INPUT ab_unmap.v_operador,
                      INPUT "CRAP089A",
                      INPUT get-value("nrseqagp"),  /* ROWID */
					  INPUT 0, /* flmobile */
                      OUTPUT "").
              
              CLOSE STORED-PROC pc_gps_agmto_desativar
                 aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     
              
              ASSIGN aux_cdcritic = 0
                     aux_dscritic = ""
                     aux_dscritic = pc_gps_agmto_desativar.pr_dscritic 
                                    WHEN pc_gps_agmto_desativar.pr_dscritic <> ?.
              
              { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }                           
              /** FIM - Efetuar a consulta dos Agendamentos da Conta informada **/
              

              IF  aux_dscritic <> "" THEN DO:
                   {&OUT}
                      "<script>alert('Problemas no cancelamento! " aux_dscritic "' );
                       </script>".
              END.
              ELSE DO:
                  {&OUT}
                      "<script>alert('Cancelamento efetuado com Sucesso!')
                       </script>".
              END.

          END.

      END.

  END. /* METHOD POST **/



  {&OUT}
    "<HTML>":U SKIP
    "   <HEAD>":U SKIP
    '       <meta http-equiv="cache-control" content="no-cache">' SKIP
    '       <meta http-equiv="Pragma"        content="No-Cache">' SKIP
    '       <meta http-equiv="Expires"       content="0">'        SKIP
    '       <script language=JavaScript src="/script/formatadadosie.js"></script>' SKIP
    '       <link rel=StyleSheet type="text/css" href="/script/viacredi.css">' SKIP
    '       <title>GPS - Agendamentos Guias da Previdência Social</title>' SKIP
    "   </HEAD>":U SKIP
    '   <body background="/images/moeda.jpg" bgproperties="fixed" class=fundo onLoad="JavaScript:click();" onKeyUp="callBlass(event); callBLini(event); callBLsal(event);">' SKIP
    '       <form name="frmAction" id="frmAction" onKeyDown="change_page(event)" method=post>' SKIP.
  
  {&OUT}
    '       <p style="word-spacing: 0; line-height: 100%; margin-top: 0; margin-bottom: 0">&nbsp;</p>' SKIP
    '       <div align="center">' SKIP
    '           <center>' SKIP
    '           <table width="100%" class=cabtab>' SKIP
    '               <tr>' SKIP
    '                   <td width="15%" align="center">' ab_unmap.v_coop SKIP
    '                   </td>' SKIP
    '                   <td width="20%" align="center"> PA&nbsp;' ab_unmap.v_pac SKIP
    '                   </td>' SKIP
    '                   <td width="20%" align="center"> CAIXA&nbsp;' ab_unmap.v_caixa SKIP
    '                   </td>' SKIP
    '                   <td width="30%" align="center"> OPERADOR&nbsp;' ab_unmap.v_operador SKIP
    '                   </td>' SKIP
    '                   <td width="15%" align="center">' ab_unmap.v_data SKIP
    '                   </td>' SKIP
    '               </tr>' SKIP
    '           </table>' SKIP
    '           </center>' SKIP
    '       </div>' SKIP.
  
  {&OUT}
    '       <div align="center">' SKIP
    '           <center>' SKIP
    '           <table width="100%" class=cabtab>' SKIP
    '               <tr>' SKIP
    '                   <td class=titulo>CANCELAR AGENDAMENTO GPS(GUIAS PREVIDENCIA) SICREDI</td>' SKIP
    '                  <td width="21%" class=programa align="right">P.089a&nbsp; V.1.00</td>' SKIP
    '               </tr>' SKIP
    '           </table>' SKIP
    '           </center>' SKIP
    '       </div>' SKIP.

    {&OUT}
    '       <div align="center">' SKIP
    '       <center>' SKIP
    '           <table width=100% cellspacing = 0 cellpadding = 0>' SKIP
    '               <tr>' SKIP
    '                   <td width="100%" valign="middle" align="center">' SKIP
    '                       <div align="center">' SKIP
    '                           <center>' SKIP
    '                           <table width="100%" cellspacing = 0 cellpadding = 1 class=tcampo>' SKIP
    '                               <tr>' SKIP
    '                                   <td align="center" class="linhaform" colspan="4" >&nbsp;</td>' SKIP
    '                               </tr>' SKIP
    '                               <tr>'  SKIP
    '                                   <td align="center" class="linhaform" colspan="4">' SKIP
    '                                       <table width="100%" align="center" cellspacing = 0 cellpadding = 1 class=tcampo>' SKIP
    '                                           <tr>' SKIP
    '                                               <td width="10%" align="right" class="linhaform" nowrap>&nbsp;Conta / DV:</td>' SKIP
    '                                               <td width="20%" align="left" class="linhaform">' SKIP
    '                                                   <input type="text" name="v_conta" size="15" class="input" value="' get-value("v_cta") '" disabled>' SKIP
    '                                               </td>' SKIP
    '                                               <td width="51%" align="left" class="linhaform">' SKIP
    '                                                   Nome:<input type="text" name="v_nome" size="40" class="input" value="' get-value("v_nom") '" disabled style="font-weight: bold">' SKIP
    '                                               </td>' SKIP
    '                                           </tr>' SKIP
    '                                       </table>'  SKIP
    '                                   </td>'  SKIP 
    '                               </tr>'  SKIP
    '                               <tr>'  SKIP
    '                                   <td colspan = 4 class="linhaform"> <hr class=input></td>'  SKIP
    '                               </tr>'  SKIP
    '                               <tr>'  SKIP
    '                                   <td align="center" class="linhaform" colspan="4">'
    '                                       <div id="dados">'  SKIP.

                                            IF  get-value("v_cta") <> ""  THEN DO:

                                                EMPTY TEMP-TABLE tt-dados.

                                                FOR EACH tt-dados :
                                                    DELETE tt-dados.
                                                END.

                                                /** Efetuar a consulta dos Agendamentos da Conta informada **/
                                                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                                                FOR FIRST crapcop FIELDS (cdcooper) 
                                                    WHERE crapcop.nmrescop = v_coop NO-LOCK.
                                                END.

                                                RUN STORED-PROCEDURE pc_gps_agmto_consulta
                                                        aux_handproc = PROC-HANDLE NO-ERROR
                                                       (INPUT crapcop.cdcooper,
                                                        INPUT DECI(get-value("v_cta")),
                                                        INPUT 2, /* idorigem */
                                                        INPUT ab_unmap.v_operador,
                                                        INPUT "CAIXA",
                                                        OUTPUT 0,
                                                        OUTPUT "",
                                                        OUTPUT "").

                                                CLOSE STORED-PROC pc_gps_agmto_consulta
                                                   aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

                                                ASSIGN aux_cdcritic = 0
                                                       aux_dscritic = ""
                                                       aux_cdcritic = pc_gps_agmto_consulta.pr_cdcritic 
                                                                      WHEN pc_gps_agmto_consulta.pr_cdcritic <> ?
                                                       aux_dscritic = pc_gps_agmto_consulta.pr_dscritic 
                                                                      WHEN pc_gps_agmto_consulta.pr_dscritic <> ?
                                                       xml_req      = pc_gps_agmto_consulta.pr_retxml.

                                               { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }                           
                                               /** FIM - Efetuar a consulta dos Agendamentos da Conta informada **/
                                               
                                               /*** LEITURA DO XML RETORNO **/
                                               /* Inicializando objetos para leitura do XML de PERFIL */
                                               CREATE X-DOCUMENT xDoc.
                                               CREATE X-NODEREF xRoot.
                                               CREATE X-NODEREF xRoot2.
                                               CREATE X-NODEREF xField.
                                               CREATE X-NODEREF xText.

                                               /* Efetuar a leitura do XML*/
                                               SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1.
                                               PUT-STRING(ponteiro_xml,1) = xml_req.

                                               xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE).
                                               xDoc:GET-DOCUMENT-ELEMENT(xRoot).

                                               DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN:
                                                   xRoot:GET-CHILD(xRoot2,aux_cont_raiz).

                                                   CREATE tt-dados.

                                                   IF  xRoot2:SUBTYPE <> "ELEMENT" THEN
                                                       NEXT.

                                                   DO  aux_cont_perf = 1 TO xRoot2:NUM-CHILDREN:
                                                       xRoot2:GET-CHILD(xField,aux_cont_perf).

                                                       IF  xField:SUBTYPE <> "ELEMENT" 
                                                       OR xField:NAME = "detalhes" THEN
                                                           NEXT.

                                                       xField:GET-CHILD(xText,1).

                                                       ASSIGN tt-dados.dsdrowid = STRING(xText:NODE-VALUE)
                                                        WHEN xField:NAME = "dsdrowid".
                                                       ASSIGN tt-dados.nrseqagp = INTE(xText:NODE-VALUE)
                                                        WHEN xField:NAME = "nrseqagp".
                                                       ASSIGN tt-dados.cdagenci = INTE(xText:NODE-VALUE)
                                                        WHEN xField:NAME = "cdagenci".
                                                       ASSIGN tt-dados.nrdcaixa = INTE(xText:NODE-VALUE)
                                                        WHEN xField:NAME = "nrdcaixa".
                                                       ASSIGN tt-dados.cddpagto = INTE(xText:NODE-VALUE)
                                                        WHEN xField:NAME = "cddpagto".
                                                       ASSIGN tt-dados.dsperiod = STRING(xText:NODE-VALUE)
                                                        WHEN xField:NAME = "dsperiod".
                                                       ASSIGN tt-dados.cdidenti = STRING(xText:NODE-VALUE)
                                                        WHEN xField:NAME = "cdidenti".
                                                       ASSIGN tt-dados.vlrtotal = DECI(xText:NODE-VALUE)
                                                        WHEN xField:NAME = "vlrtotal".
                                                       ASSIGN tt-dados.dspesgps = STRING(xText:NODE-VALUE)
                                                        WHEN xField:NAME = "dspesgps".
                                                       ASSIGN tt-dados.dtdebito = STRING(xText:NODE-VALUE)
                                                        WHEN xField:NAME = "nrdiaesc".
                                                       ASSIGN tt-dados.insituac = INTE(xText:NODE-VALUE)
                                                        WHEN xField:NAME = "insituac".

                                                   END.
                                               END.

                                               SET-SIZE(ponteiro_xml) = 0.

                                               DELETE OBJECT xDoc.
                                               DELETE OBJECT xRoot.
                                               DELETE OBJECT xRoot2.
                                               DELETE OBJECT xField.
                                               DELETE OBJECT xText.

                                               /*** FIM - LEITURA O XML RETORNO **/
                                            
                                               FIND FIRST tt-dados WHERE tt-dados.insituac = 0 NO-LOCK NO-ERROR.

                                               IF  AVAIL tt-dados THEN DO:
                                                   /** ENCONTROU REGISTROS DE AGENDAMENTO **/
                                                   aux_controle = TRUE.
                                                   {&OUT}
                                                         "<table width=85% cellspacing=0 cellpadding=1 border = 1>"   SKIP
                                                         "    <tr>"  SKIP
                                                         '        <td class=titulo align="center" style="BACKGROUND-COLOR:#2D862D; border=0">&nbsp;</td>'  SKIP
                                                         '        <td class=titulo align="center" style="BACKGROUND-COLOR:#2D862D; border=0">PA</td>'  SKIP
                                                         '        <td class=titulo align="center" style="BACKGROUND-COLOR:#2D862D; border=0">Caixa</td>'  SKIP
                                                         '        <td class=titulo align="center" style="BACKGROUND-COLOR:#2D862D; border=0">Cód.Pagto</td>'  SKIP
                                                         '        <td class=titulo align="center" style="BACKGROUND-COLOR:#2D862D; border=0">Competência</td>'  SKIP
                                                         '        <td class=titulo align="center" style="BACKGROUND-COLOR:#2D862D; border=0">Identificador</td>'  SKIP
                                                         '        <td class=titulo align="center" style="BACKGROUND-COLOR:#2D862D; border=0" style="text-align: center">Valor Tot. INSS</td>'  SKIP
                                                         '        <td class=titulo align="center" style="BACKGROUND-COLOR:#2D862D; border=0" align="center">Tipo Pessoa</td>'  SKIP
                                                         '        <td class=titulo align="center" style="BACKGROUND-COLOR:#2D862D; border=0" align="center">Data do Débito</td>'  SKIP
                                                         "    </tr>"  SKIP.


                                                    FOR EACH tt-dados 
                                                          BY tt-dados.insituac
                                                          BY tt-dados.cdagenci
                                                          BY tt-dados.nrdcaixa
                                                          BY tt-dados.cddpagto
                                                          BY tt-dados.dspesgps
                                                          BY tt-dados.cdidenti:


                                                        IF  tt-dados.insituac <> 0 THEN
                                                            NEXT.

                                                        {&OUT}
                                                              "    <tr>"
                                                              '        <td class=campos align="left" readonly>' SKIP
                                                              '            <input type="radio" '
                                                              '         id="nrseqagp'  tt-dados.nrseqagp '" '
                                                              '         name="nrseqagp" '
                                                              '         value="' tt-dados.dsdrowid '" style="margin-left:20px">'
                                                              '        </td>' SKIP
                                                              '        <td class=campos align="center" readonly>' tt-dados.cdagenci '</td>'
                                                              '        <td class=campos align="center" readonly>' tt-dados.nrdcaixa '</td>'
                                                              '        <td class=campos align="center" readonly>' tt-dados.cddpagto '</td>'
                                                              '        <td class=campos align="center" readonly>' tt-dados.dsperiod '</td>'
                                                              '        <td class=campos align="center" readonly>' tt-dados.cdidenti '</td>'
                                                              '        <td class=campos align="right"  style="padding-right:10px"  readonly>' tt-dados.vlrtotal FORMAT "zzz,zzz,zzz,zz9.99"'</td>'
                                                              '        <td class=campos align="center" readonly>' tt-dados.dspesgps '</td>'
                                                              '        <td class=campos align="center" readonly>' tt-dados.dtdebito '</td>'
                                                              "    </tr>" SKIP.
                                                    END.
                                                       {&OUT}
                                                           '</table>' SKIP.
                                               END.
                                               ELSE DO:
                                                   aux_controle = FALSE.
                                                   /** NAO ENCONTROU REGISTROS DE AGENDAMENTO **/
                                                   {&OUT}
                                                       "<table width=85% cellspacing=0 cellpadding=1 border = 1>"   SKIP
                                                       "    <tr>"  SKIP
                                                       '        <td class=titulo align="center" style="BACKGROUND-COLOR:#2D862D; border=0">&nbsp;</td>'  SKIP
                                                       '        <td class=titulo align="center" style="BACKGROUND-COLOR:#2D862D; border=0">PA</td>'  SKIP
                                                       '        <td class=titulo align="center" style="BACKGROUND-COLOR:#2D862D; border=0">Caixa</td>'  SKIP
                                                       '        <td class=titulo align="center" style="BACKGROUND-COLOR:#2D862D; border=0">Cód.Pagto</td>'  SKIP
                                                       '        <td class=titulo align="center" style="BACKGROUND-COLOR:#2D862D; border=0">Competência</td>'  SKIP
                                                       '        <td class=titulo align="center" style="BACKGROUND-COLOR:#2D862D; border=0">Identificador</td>'  SKIP
                                                       '        <td class=titulo align="center" style="BACKGROUND-COLOR:#2D862D; border=0" >Valor Tot. INSS</td>'  SKIP
                                                       '        <td class=titulo align="center" style="BACKGROUND-COLOR:#2D862D; border=0" align="center">Tipo Pessoa</td>'  SKIP
                                                       '        <td class=titulo align="center" style="BACKGROUND-COLOR:#2D862D; border=0" align="center">Data do Débito</td>'  SKIP
                                                       "    </tr>"  SKIP.

                                                   {&OUT}
                                                       "    <tr>"  SKIP
                                                       "        <td heigth='40' colspan='9' align='center'>Não foram encontrados agendamentos para essa conta!"  SKIP
                                                       "        </td>"  SKIP
                                                       "    </tr>"  SKIP
                                                       "</table>"  SKIP.
                                               END.
                                            END. /** FIM - METHOD GET*/
    {&OUT}
    '                                   </div></td>'  SKIP
    '                               </tr>'  SKIP
    '                               <tr>'  SKIP
    '                                   <td colspan = 4 class="linhaform"> <hr class=input></td>'  SKIP
    '                               </tr>'  SKIP
    '                               <tr>'  SKIP
    '                                   <td align="center" class="linhaform" colspan="4">'  SKIP
    '                                       <input type="submit" value="Voltar"                name="b_voltar"   class="button">'  SKIP
    '                                       <input type="submit" value="Cancelar Agendamento"  name="b_desativa" class="button4">'  SKIP
    '                                   </td>'  SKIP
    '                               </tr>'  SKIP
    '                               <tr>'  SKIP
    '                                   <td align="center" class="linhaform" colspan="4">'  SKIP
    '                                   &nbsp;'  SKIP
    '                                   </td>'  SKIP
    '                               </tr>'  SKIP
    '                           </table>'  SKIP
    '                       </div>'  SKIP

    '                   </td>'  SKIP
    '               </tr>'  SKIP
    '           </table>'  SKIP
    '       </center>'  SKIP
    '       </div>'  SKIP
    "       </form>":U SKIP
    "   </BODY>":U SKIP
    "</HTML>":U SKIP.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

/* ......................................................................... */


