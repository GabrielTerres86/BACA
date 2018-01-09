/* .............................................................................

  Programa: autentica.p

Alteracoes: 16/12/2008 - Ajustes para unificacao dos bancos de dados (Evandro).

            08/02/2013 - Ajuste para realizar a impressao da comprovacao de vida
                         gerado na rotina 85. 
                         Projeto Prova de vida (Adriano).
                         
            04/06/2013 - Imprimir autenticação de DARFs em 2 partes (Lucas).
            
            03/05/2014 - Imprimir autenticação de GPS em 2 partes (Carlos).
            
            15/10/2015 - Autenticacao GPS limitado com 48 colunas 
                         (Guilherme/SUPERO).

		    13/02/2017 - Passado por parametro que a autenticação da GPS está
			             Ok qdo for a segunda parte GPS2, para que seja possível
						 fechar a janela de autenticação com o comando ESC
						 (Tiago/Elton SD585615).
						 
			16/11/2017 - Ajuste feito para adptar a rotina na impressao da rotina 97. (SD 788441 - Kelvin).
   
            11/12/2017 - Inclusão do parametro par_cdmensagem - Codigo da mensagem ou critica (Origem crapcri.cdcritic)
                         (Belli - Envolti - Chamado 786752)
						
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
DEFINE VARIABLE h-b1crap03 AS HANDLE     NO-UNDO.

DEF TEMP-TABLE ab_unmap
    FIELD v_coop      AS CHAR
    FIELD v_pac       AS CHAR
    FIELD v_caixa     AS CHAR
    FIELD v_operador  AS CHAR
    FIELD v_data      AS CHAR
    FIELD vh_foco     AS CHAR
    FIELD v_msg       AS CHAR
    FIELD v_seq       AS CHAR.

{dbo/bo-erro1.i}

DEF VAR i-cod-erro  AS INTEGER.
DEF VAR c-desc-erro AS CHAR.

DEF VAR aux         AS CHAR.

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
         WIDTH              = 60.8.
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
   
  IF get-value("aut") <> "" THEN 
      ASSIGN aux = "Ok".
  ELSE 
      ASSIGN aux = "Nok".

  IF REQUEST_method = "get" THEN
  DO:
      IF get-value("v_pseq") <> "" AND get-value("v_psetcook") = "yes" THEN
        RUN SetCookie IN web-utilities-hdl ("Autenticacao":U, get-value("v_pseq"), DATE("31/12/9999"), TIME, ?, ?, ?).
  END.

  
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
    '<title>AUTENTICACAO</title>' SKIP
    "</HEAD>":U SKIP
    '<body background="/images/moeda.jpg" bgproperties="fixed" class=fundo onLoad="JavaScript:onTop(); click();" onKeyDown="JavaScript:onKeyAutent(event,' + KEYLABEL(39) + aux + KEYLABEL(39) + ')">' SKIP
    '<form name=action method=post>' SKIP
    '<input type=hidden name=aut>' SKIP.
   
   IF get-value("v_rotina") = "crap097" THEN 
      DO:
   {&OUT}
    '<div align="center">' SKIP
     '<center>' SKIP
             '<table width=90% cellspacing = 0 cellpadding = 0>' SKIP
              '<tr>' SKIP
               '<tr><td align="right" class="linhaform"></td><td>&nbsp;</td></tr>'
               '  <td width="101%" valign="middle" align="center">' SKIP
                '  <div align="center">' SKIP
                 '  <center>' SKIP
                  '  <table width="100%" cellspacing = 0 cellpadding = 1 class=tcampo>' SKIP
                   '  <tr><td align="right" class="linhaform">&nbsp;&nbsp;</td></tr>' SKIP
                   '  <tr><td align="right" class="linhaform">&nbsp;&nbsp;</td></tr>' SKIP
                   '  <tr>' SKIP                    
                    '    <td width="100%" align="left" class="linhaform">Pressione ENTER para autenticar o inicio do atendimento.</td>' SKIP
                   ' </tr>' SKIP
                   '<tr><td align="right" class="linhaform"></td><td>&nbsp;</td></tr>'
                   /*'<tr>'
                    '<td align="center" class="linhaform" colspan=2>'
                     '<input type="submit" value="Autenticar" name="autentica" class="button">&nbsp;'
                     '<input type="submit" value="Retornar" name="retorna" class="button"></td>'
                   '</tr>'*/
                   '<tr><td align="right" class="linhaform"></td><td>&nbsp;</td></tr>' SKIP 
                  '</table>'
                 '</center>'
                '</div>'
               '</td>'
              '</tr>' 
             '</table>'
            '</center>'
           '</div>' SKIP.    	  
	  END.
   ELSE
      DO:
	     {&OUT}
			'<div align="center">' SKIP
			 '<center>' SKIP
      '<table width=70% cellspacing = 0 cellpadding = 0>' SKIP
       '<tr>' SKIP
        '<tr><td align="right" class="linhaform"></td><td>&nbsp;</td></tr>'
        '  <td width="101%" valign="middle" align="center">' SKIP
         '  <div align="center">' SKIP
          '  <center>' SKIP
           '  <table width="100%" cellspacing = 0 cellpadding = 1 class=tcampo>' SKIP
            '  <tr><td align="right" class="linhaform">&nbsp;&nbsp;</td></tr>' SKIP
            '  <tr><td align="right" class="linhaform">&nbsp;&nbsp;</td></tr>' SKIP
            '  <tr>' SKIP
             '    <td width="20%" align="right" class="linhaform" nowrap>&nbsp;Seqüência:</td>' SKIP
             '    <td width="30%" align="left" class="linhaform"><input type="text" name="v_seq" size="15" class="input" value="' get-value("v_pseq") '" disabled></td>' SKIP
            ' </tr>' SKIP
            '<tr><td align="right" class="linhaform"></td><td>&nbsp;</td></tr>'
            /*'<tr>'
             '<td align="center" class="linhaform" colspan=2>'
              '<input type="submit" value="Autenticar" name="autentica" class="button">&nbsp;'
              '<input type="submit" value="Retornar" name="retorna" class="button"></td>'
            '</tr>'*/
            '<tr><td align="right" class="linhaform"></td><td>&nbsp;</td></tr>' SKIP 
           '</table>'
          '</center>'
         '</div>'
        '</td>'
       '</tr>' 
      '</table>'
     '</center>'
    '</div>' SKIP.
			  END.	 
 {&OUT}
   "</form>":U SKIP
   '<OBJECT  classid="clsid:7F8735B1-EC41-4134-9083-E059B3F56262" codebase="edimpbmp20ci.ocx#version=2,1,3,1" width=0 height=0 align=CENTER hspace=0 vspace=0 id=bematech>'
   '</OBJECT>' 
   "</BODY>":U SKIP
   "</HTML>":U SKIP.

 IF REQUEST_METHOD = "POST":U THEN DO:
         
     
	 IF get-value("v_rotina") = "crap097" THEN 
	    DO:
		   /* Autenticação */
		   {&OUT} '<script> bematech.Imprimir("LPT1","' trim(get-value("v_plit")) '",2,1,0,0,0,0)                   </script>'.
		   { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
	 
			RUN STORED-PROCEDURE pc_gera_log_batch 
					aux_handproc = PROC-HANDLE NO-ERROR 
					 (INPUT crapcop.cdcooper,   /* Cooperativa */  
					  INPUT 1,               /* Nivel criticidade do log "Erro tratato" */ 			 
					  INPUT trim(get-value("v_plit")),   /* Descriçao do log em si */ 
					  INPUT "rot097",       /* Nome para gravaçao de log  */ 
					  INPUT "N",            /* Flag S/N para criar um arquivo novo */  
					  INPUT "N",            /* Flag S/N  para informaR [PL/SQL] */ 
					  INPUT ?,              /* Diretorio onde será gerado o log */ 
					  INPUT "O",            /* Tipo do log  */ 
					  INPUT 'b1crap00.p',   /* Programa/job */ 
					  INPUT 3,              /* Execucao via BATCH */ 
					  INPUT 0,              /* Criticidade BAIXA */  
					  INPUT 1,              /* Processo executado com sucesso */ 
		              INPUT 0               /* Codigo da mensagem ou critica - 11/12/2017 - Chamado 786752 */
				      ).
																			   
			CLOSE STORED-PROC pc_gera_log_batch 
				 aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
								 
			 { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
		END.
	 ELSE
	    DO:
     /*Para a rotina 85 - Realiza a impressao da Comprovacao de Vida*/
     IF get-value("v_plit") = "crap085" THEN
        DO:
            FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper AND         
                               craptab.nmsistem = "CRED"           AND         
                               craptab.tptabela = "GENERI"         AND         
                               craptab.cdempres = INT(v_caixa)     AND         
                               craptab.cdacesso = v_operador       AND
                               craptab.tpregist = INT(v_pac)
                               NO-LOCK NO-ERROR.

            IF AVAIL craptab THEN
               {&OUT} '<script> bematech.ImpAjust("LPT1", "' craptab.dstextab '" ,48,1,2,0,0,0,0)                   </script>'.
        END.
     ELSE
        IF  get-value("v_plit") = " " THEN 
            DO:  /* Somente para DOC/TED */
                FIND crapaut  WHERE
                     crapaut.cdcooper = crapdat.cdcooper AND 
                     crapaut.dtmvtolt = crapdat.dtmvtolt AND 
                     crapaut.cdagenci = INT(v_pac)       AND 
                     crapaut.nrdcaixa = INT(v_caixa)     AND 
                     crapaut.nrsequen = INT(get-value("v_pseq")) 
                     NO-ERROR.
               
                IF  AVAIL crapaut THEN 
                    {&OUT} '<script> bematech.ImpAjust("LPT1", "' crapaut.dslitera '" ,48,1,2,0,0,0,0)                   </script>'.
        
           END.
        ELSE 
           DO:
              CASE get-value("v_prec"):
        
                  WHEN "YES" THEN 
                      DO: /* Recibo */ 
                          {&OUT} '<script> bematech.ImpAjust("LPT1","' get-value("v_plit") '",48,1,2,0,0,0,0)                   </script>'.
                      END.
                  WHEN "NO" THEN 
                      DO: /* Autenticação */
                          {&OUT} '<script> bematech.Imprimir("LPT1","' trim(get-value("v_plit")) '",2,1,0,0,0,0)                   </script>'. 
                      END.
                  WHEN "NO2" THEN 
                      DO: /* Autenticação c/ Conta */
                          {&OUT} '<script> bematech.Imprimir("LPT1","' trim(SUBSTRING(get-value("v_plit"),1,48))'",2,1,0,0,0,0) </script>'. 
                          {&OUT} '<script> bematech.Imprimir("LPT1","' trim(substring(get-value("v_plit"),49,48)) '",2,1,0,0,0,0) </script>'. 
                      END.
                  WHEN "NO3" THEN 
                      DO: /* Parte 1 Autenticação de DARFs */
                          {&OUT} '<script> bematech.Imprimir("LPT1","' trim(SUBSTRING(get-value("v_plit"),1, 48)) '",2,1,0,0,0,0)   </script>'. 

                          {&OUT}
                           '<script>window.open("autentica.html?v_plit=" + "' get-value("v_plit") '" + 
                             "&v_pseq=" + "' get-value("v_pseq") '" + "&v_prec=" + "NO4" + "&vias=" + "'STRING(INTE(get-value("vias")) + 1)'"  + 
                             "&v_psetcook=" +         "YES","_self","width=250,height=145,scrollbars=auto,alwaysRaised=true")
                           </script>'.

                      END.
                  WHEN "NO4" THEN 
                      DO: /* Parte 2 Autenticação de DARFs */
                          {&OUT} '<script> bematech.Imprimir("LPT1","' trim(SUBSTRING(get-value("v_plit"), 49)) '",2,1,0,0,0,0) </script>'.

                          IF  INTE(get-value("vias")) >= 4 THEN
                              DO:
                                 {&OUT}
                                 '<script>window.open("autentica.html?v_plit=" + "' get-value("v_plit") '" + 
                                   "&v_pseq=" + "' get-value("v_pseq") '" + "&v_prec=" + "NO3"  + "&aut=" + "ok"  + 
                                   "&v_psetcook=" +         "YES","_self","width=250,height=145,scrollbars=auto,alwaysRaised=true")
                                 </script>'.
                              END.

                          {&OUT}
                           '<script>window.open("autentica.html?v_plit=" + "' get-value("v_plit") '" + 
                             "&v_pseq=" + "' get-value("v_pseq") '" + "&v_prec=" + "NO3" + "&vias=" + "'STRING(INTE(get-value("vias")) + 1)'"  + 
                             "&v_psetcook=" +         "YES","_self","width=250,height=145,scrollbars=auto,alwaysRaised=true")
                           </script>'.
                          
                      END.
                  WHEN "GPS1" THEN 
                      DO: /* Parte 1 Autenticação de GPS */
                          {&OUT} '<script> bematech.Imprimir("LPT1","' trim(SUBSTRING(get-value("v_plit"),1, 48)) '",2,1,0,0,0,0)   </script>'.
                          {&OUT}
                          '<script>window.open("autentica.html?v_plit=" + "' get-value("v_plit") '" + 
                          "&v_pseq=" + "' get-value("v_pseq") '" + "&v_prec=" + "GPS2" + 
                          "&v_psetcook=" + "YES","_self","width=250,height=145,scrollbars=auto,alwaysRaised=true")
                          </script>'.
                      END.
                  WHEN "GPS2" THEN 
                      DO: /* Parte 2 Autenticação de GPS */
                          {&OUT} '<script> bematech.Imprimir("LPT1","' trim(SUBSTRING(get-value("v_plit"), 48)) '",2,1,0,0,0,0) </script>'.
                          {&OUT}
                          '<script>window.open("autentica.html?v_plit=" + "' get-value("v_plit") '" + 
                          "&v_pseq=" + "' get-value("v_pseq") '" + "&v_prec=" + "GPS1" + "&aut=" + "ok"  + 
                          "&v_psetcook=" + "YES","_self","width=250,height=145,scrollbars=auto,alwaysRaised=true")
                          </script>'.
                      END.
        
              END CASE.
        
           END.
		 END.

 END.
 

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF


