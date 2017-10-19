/* .............................................................................

Programa: fontes/wpgd0001.w 
Autor: B&T - solusoft

Alteracoes: ??/??/???? - Inclusao de widget-pool (Martin - SQWorks)
            
            09/12/2008 - Tratamento para vmdesen (David).
                       - Alteração da montagem do valor do campo gnapses.idsessao
                         para deixá-lo com valor único e melhoria de performance
                         (Evandro).
                                                 
            06/07/2009 - Alteração CDOPERAD (Diego).
                        
            19/10/2010 - Corrigir url para redirecionar erro de login quando
                         for ambiente de desenvolvimento (David).

            06/07/2012 - Substituido gncoper por crapcop (Tiago).                         
						
			25/06/2013 - Incluir redireciomento para pkghomol e pkglibera (David).
            
            11/12/2013 - Incluir VALIDATE gnapses (Lucas R.)
			
			04/02/2014 - Atribuido valor a variavel aux_nvoperad de acordo
			             com informacoes gravadas na crapope, e nao mais
						 buscando da craptab com cdacesso = "PGOPERADOR".
						 (Fabricio)
			
			06/12/2016 - P341-Automatização BACENJUD - Alterada a validação 
			             do departamento para que a mesma seja feita através
						 do código e não da descrição (Renato Darosci)

			23/08/2017 - Alteracao referente a validacao do usuario apenas pelo AD.
						 Removido campo operador no ambiente de producao.
						 Removido campo senha e checkbox "Armazenar as informacoes 
						 de login". (PRJ339 - Reinert)

............................................................................. */
&ANALYZE-SUSPEND _VERSION-NUMBER WDT_v2r12 Web-Object
/* Maps: wpgd0001.htm */
&ANALYZE-RESUME
&ANALYZE-SUSPEND _CODE-BLOCK _CUSTOM Definitions 
/*------------------------------------------------------------------------
------------------------------------------------------------------------*/
/*           This .W file was created with WebSpeed Workshop.           */
/*----------------------------------------------------------------------*/

create widget-pool.

/* ***************************  Definitions  ************************** */

/* Preprocessor Definitions ---                                         */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE conteudo-cookie AS CHARACTER            FORMAT "X(47)".
DEFINE VARIABLE ContadorAux     AS INTEGER.
DEFINE VARIABLE v-senha         as char        no-undo init " ".
DEFINE VARIABLE l-gera          as log                 init no.
DEFINE VARIABLE aux_nvoperad    LIKE crapope.nvoperad.
DEFINE VARIABLE des_login       AS CHAR        NO-UNDO.
DEFINE VARIABLE p-retorno       AS CHAR.
DEFINE VARIABLE l-sucesso       AS LOGICAL     NO-UNDO.
DEFINE VARIABLE contador        as char.
DEFINE VARIABLE c-para          as CHAR.
DEFINE VARIABLE c-assunto       as CHAR.
DEFINE VARIABLE c-mensagem      as CHAR.
DEFINE VARIABLE l-expirou       as log         NO-UNDO init no.
DEFINE VARIABLE d-data          as date        no-undo.

if proversion >= "9.1a" then
   l-gera = no.
else
   l-gera = yes.
&ANALYZE-RESUME
&ANALYZE-SUSPEND _PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&SCOPED-DEFINE PROCEDURE-TYPE Web-Object

&SCOPED-DEFINE WEB-FILE wpgd0001.htm

/* Default preprocessor names */
&SCOPED-DEFINE FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&SCOPED-DEFINE ENABLED-OBJECTS gidnumber cdcooper vusuario dsmsgerr
&SCOPED-DEFINE DISPLAYED-OBJECTS gidnumber cdcooper vusuario dsmsgerr

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */
&ANALYZE-RESUME



&ANALYZE-SUSPEND _FORM-BUFFER


/* Definitions of the field level widgets                               */
DEFINE VARIABLE gidnumber AS CHARACTER FORMAT "x(256)":U 
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.
                 
DEFINE VARIABLE cdcooper AS CHARACTER FORMAT "x(256)":U 
     VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
     SIZE 40 BY 12 NO-UNDO.

DEFINE VARIABLE vusuario AS CHARACTER FORMAT "x(256)":U 
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE dsmsgerr AS CHARACTER FORMAT "x(256)":U 
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     gidnumber SKIP
     cdcooper SKIP
     vusuario SKIP
     dsmsgerr SKIP
    WITH NO-LABELS.

 

&ANALYZE-RESUME

/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

&ANALYZE-SUSPEND _INCLUDED-LIBRARIES
/* Included Libraries --- */

{src/web/method/html-map.i}
&ANALYZE-RESUME _END-INCLUDED-LIBRARIES

&ANALYZE-SUSPEND _CODE-BLOCK _CUSTOM "Main Code Block" 


/* ************************  Main Code Block  ************************* */

/* 
 * Standard Main Code Block. This dispatches two events:
 *   'initialize'
 *   'process-web-request'
 * The bulk of the web processing is in the procedure 'process-web-request'
 * elsewhere in this Web object.
 */
{src/web/template/hmapmain.i}
&ANALYZE-RESUME
/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _CODE-BLOCK _PROCEDURE contatentativa 
PROCEDURE contatentativa :

def input parameter t-usuario as char no-undo.
def input parameter c-usuario as char no-undo.

if t-usuario <> "ERR" then do:
  case t-usuario:
    when "USU" then do:
      /*cra-usuario.tentativas = cra-usuario.tentativas + 1.          
        if cra-usuario.tentativas = 2 then do:
            /*
          assign c-para    = ws-param-global.u-char-4
                 c-assunto = "Segunda tentativa inválida de acessar o sistema. Usuário: " + ws-usuario.usuario
                 c-mensagem = "Administrador," + chr(13) + chr(10) + "O sistema verificou uma 2ª tentativa inválida de acessar o Web Sales com o usuário: " + ws-usuario.usuario + 
                              " na máquina com o I.P. :  " +  cra-logacesso.ip.
          create ws-email.
          assign ws-email.texto        = c-mensagem
                 ws-email.para         = c-para
                 ws-email.assunto      = c-assunto 
                 ws-email.u-log-1      = l-gera
                 ws-email.dt-envio     = today
                 ws-email.hora-envio   = string(time,"HH:MM:SS")
                 ws-email.de           = "Web Sales"
                 ws-email.u-char-2     = ws-param-global.u-char-5.
/*          RELEASE ws-email. */
          if c-para <> '' and l-gera = no THEN DO:
            RUN gerenciador/lemail.p(ROWID(ws-email)).  
          END.
          */
        end.
        if cra-usuario.tentativas = 3 then do:
          cra-usuario.bloqueado = yes.
          RUN rodajava('alert("Excedido nº máximo de tentantivas. Senha Bloqueada.")').
       end.  */  
    end.
  end case. 
end.
END PROCEDURE.

&ANALYZE-RESUME
&ANALYZE-SUSPEND _CODE-BLOCK _PROCEDURE GravaCookie 
PROCEDURE GravaCookie :
	SET-COOKIE("cookie-usuario-em-uso",conteudo-cookie,?,?,?,?,?).
	SET-USER-FIELD("cookie-usuario-em-uso",conteudo-cookie).
	RUN output-header.
	RUN rodajava('document.location.href="wpgd0002.htm"'). 
END PROCEDURE.

&ANALYZE-RESUME
&ANALYZE-SUSPEND _CODE-BLOCK _PROCEDURE htm-offsets _WEB-HTM-OFFSETS
PROCEDURE htm-offsets : 
/*------------------------------------------------------------------------------
  Purpose:     Runs procedure to associate each HTML field with its
               corresponding widget name and handle.
  Parameters:  
  Notes:       
------------------------------------------------------------------------------*/
  RUN web/support/rdoffr.p ("{&WEB-FILE}":U).
  RUN htm-associate IN THIS-PROCEDURE
    ("gidnumber":U,"gidnumber":U,gidnumber:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htm-associate IN THIS-PROCEDURE
    ("cdcooper":U,"cdcooper":U,cdcooper:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htm-associate IN THIS-PROCEDURE
    ("vusuario":U,"vusuario":U,vusuario:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htm-associate IN THIS-PROCEDURE
    ("dsmsgerr":U,"dsmsgerr":U,dsmsgerr:HANDLE IN FRAME {&FRAME-NAME}).                
END PROCEDURE.

&ANALYZE-RESUME
&ANALYZE-SUSPEND _CODE-BLOCK _PROCEDURE output-header 
PROCEDURE output-header :
/*------------------------------------------------------------------------
  Purpose:     Output the MIME header, and any "cookie" information needed 
               by this procedure.  
  Parameters:  <none>
  Notes:       In the event that this Web object is State-Aware, this is also
               a good place to set the "Web-State" and "Web-Timeout" 
               attributes.              
------------------------------------------------------------------------*/
   
   output-content-type ("text/html":U).
  
END PROCEDURE.

&ANALYZE-RESUME
&ANALYZE-SUSPEND _CODE-BLOCK _PROCEDURE process-web-request 
PROCEDURE process-web-request :
/*------------------------------------------------------------------------
  Purpose:     Process the web request.
  Notes:       Rotina usando operadores cadastrados na tabela crapope 
------------------------------------------------------------------------*/
	def var v-tipo        as char no-undo.
	def var v-codigo      as INT  no-undo.
	def var v-chaveacesso as char no-undo init " " .
	def var v-data        as DATE no-undo init "01/01/1970"  form "99/99/9999" .
	def var v-dia         as int  no-undo.
	def var v-mes         as int  no-undo.
	def var v-ano         as int  no-undo.
	def var v-ok          as log  no-undo init yes.
	def var l-ok          as log  no-undo init yes.
	def var coops         as char no-undo.

IF REQUEST_METHOD = "POST" THEN 
	DO WITH FRAME {&FRAME-NAME}:                
		ASSIGN cdcooper  = GET-VALUE("cdcooper")
           gidnumber = GET-VALUE("gidnumber")
           des_login = GET-VALUE("des_login").
                         
		/* Se for CECRED, valida a conta como Viacredi */    
        /*IF  cdcooper = "3"  THEN
			ASSIGN cdcooper = "1".*/
                                
        /* Montagem de Menu para seleção de cooperativa para login */
        ASSIGN coops = "var coops = new Array(); ".
		
        FOR EACH crapcop WHERE crapcop.cdcooper <> 3 NO-LOCK BY crapcop.cdcooper:
                
			/* Verifica grupo de usuarios - Se nao atender as condicoes carrega somente a coop do usuario */
            IF  gidnumber <> "103"  AND /* Cecred          */
                gidnumber <> "902"  AND /* Desenvolvimento */
                gidnumber <> "903"  AND /* Suporte         */
                gidnumber <> "905"  AND /* Admin           */
                crapcop.cdcooper <> INTE(cdcooper)  THEN
				NEXT.
                                                
            ASSIGN coops = coops + 'coops[' + STRING(crapcop.cdcooper) + '] = "' + CAPS(crapcop.nmrescop) + '"; '.
                
        END.                
		
        ASSIGN coops = coops + 'carregaCoops("' + cdcooper + '");'.
                                                
        RUN dispatch IN THIS-PROCEDURE ('input-fields':U).

        IF  INPUT vusuario <> "" THEN DO:
            ASSIGN v-tipo = "".                  
                
        IF CAPS(OS-GETENV("PKGNAME")) = "PKGPROD" THEN
           ASSIGN vusuario = des_login.
                
        FIND FIRST crapope WHERE crapope.cdoperad = INPUT vusuario AND
                                 crapope.cdcooper = INTE(cdcooper)  
                                 NO-LOCK NO-WAIT NO-ERROR.
                                
        IF  AVAIL crapope  THEN DO:
			ASSIGN v-tipo   = "USU"
                   v-codigo = 1.
        END. /* Fim do IF AVAIL crapope */
                                
        IF  v-tipo <> "" and v-ok  THEN DO:
			IF  v-tipo = "USU"  THEN
            DO:
				IF   AVAIL crapope  AND crapope.flgdopgd = FALSE  AND
                     crapope.cddepart <> 20 THEN    /* TI */
                DO:
					RUN output-header.
                    RUN dispatch IN THIS-PROCEDURE ('enable-fields':U).
                    RUN dispatch IN THIS-PROCEDURE ('output-fields':U). 
                    RUN rodajava(coops).
                    RUN rodajava('verificaAmbiente("' + CAPS(OS-GETENV("PKGNAME")) + '", "' + des_login + '");').
                    RUN rodajava('alert("Operador sem permissão para acessar o Sistema de Relacionamento.")'). 
                    RETURN.
                END. 
                                                         
                IF AVAIL crapope AND crapope.cdsitope = 2 THEN
                DO:
                    RUN output-header.
                    RUN dispatch IN THIS-PROCEDURE ('enable-fields':U).
                    RUN dispatch IN THIS-PROCEDURE ('output-fields':U).  
                    RUN rodajava(coops).
                    RUN rodajava('verificaAmbiente("' + CAPS(OS-GETENV("PKGNAME")) + '", "' + des_login + '");').              
                    RUN rodajava('alert("Senha do usuário bloqueada.")').
                END. /* Fim do if avail crapope and crapope.cdsitope = 2 */ 
                ELSE
                DO:
                    /* tratamento para a conta super */
                    IF  crapope.cddepart = 20 THEN    /* TI */
                        aux_nvoperad  = 0.
                    ELSE
                    DO:
                        IF crapope.flgdopgd AND NOT crapope.flgacres THEN
							ASSIGN aux_nvoperad = 3.
						ELSE
						IF crapope.flgacres THEN
							ASSIGN aux_nvoperad = crapope.nvoperad.

                    END.

                                CREATE gnapses.
                                ASSIGN gnapses.cdoperad = crapope.cdoperad
                                       gnapses.cdcooper = INT(cdcooper)
                                       gnapses.idsistem = 2 /* PROGRID */
                                       gnapses.cddsenha = "" /* Validacao da senha e feita no AD */
                                       gnapses.cdagenci = crapope.cdagenci
                                       gnapses.Dtsessao = TODAY
                                       gnapses.Hrsessao = STRING(TIME,"HH:MM:SS")
                                       gnapses.Idsessao = TRIM(STRING(gnapses.cdcooper)) +
                                                          TRIM(STRING(gnapses.cdagenci)) +
                                                          TRIM(STRING(gnapses.cdoperad)) +
                                                          STRING(gnapses.dtsessao,"99999999") +
                                                          SUBSTRING(gnapses.hrsessao,1,2) +
                                                          SUBSTRING(gnapses.hrsessao,4,2) +
                                                          SUBSTRING(gnapses.hrsessao,7,2)
                                       gnapses.nvoperad = aux_nvoperad

                                       conteudo-cookie  = gnapses.Idsessao.
                                                                                        
                                VALIDATE gnapses.
                                RUN GravaCookie.

                END. /* Fim do IF crapope.cddsenha = INPUT senha */            
            END. /* Fim do if v-tipo = "USU" */
        END.  /* Fim do IF v-tipo <> "" and v-ok */        
        ELSE DO:
          IF v-ok THEN 
                DO:
                    /*RUN contatentativa(input "err", input "").*/
                    RUN output-header. 
                    RUN dispatch IN THIS-PROCEDURE ('enable-fields':U).
                    RUN dispatch IN THIS-PROCEDURE ('output-fields':U).
                    RUN rodajava(coops).
                    RUN rodajava('verificaAmbiente("' + CAPS(OS-GETENV("PKGNAME")) + '", "' + des_login + '");'). 
                    RUN rodajava('alert("Usuario nao existe.")'). 
                END. /* Fim do IF v-ok */
        END. /* Fim do ELSE DO */
    END.                
    ELSE DO:                        
        RUN output-header.                                                                                                                                                        
        RUN dispatch IN THIS-PROCEDURE ('enable-fields':U).
        RUN dispatch IN THIS-PROCEDURE ('output-fields':U).                 
        RUN rodajava(coops).                                
        RUN rodajava('verificaAmbiente("' + CAPS(OS-GETENV("PKGNAME")) + '", "' + des_login + '");'). 
    END.                
END.  /* Fim do DO WITH FRAME {&FRAME-NAME} */
ELSE DO WITH FRAME {&frame-name}:
    RUN output-header.                                 
    RUN dispatch IN THIS-PROCEDURE ('enable-fields':U).
    RUN dispatch IN THIS-PROCEDURE ('output-fields':U).     
                            
    IF  OS-GETENV("PKGNAME") = "pkgdesen"  THEN
        RUN rodajava('document.frmErro.action = "http://intranetdev2.cecred.coop.br/login_sistemas.php";').
	ELSE
	IF  OS-GETENV("PKGNAME") = "pkghomol"  THEN
        RUN rodajava('document.frmErro.action = "http://aylloshomol1.cecred.coop.br/login_sistemas.php";').
	ELSE
	IF  OS-GETENV("PKGNAME") = "pkglibera"  THEN
        RUN rodajava('document.frmErro.action = "http://intranetlibera.cecred.coop.br/login_sistemas.php";').
        
    RUN rodajava('document.frmErro.dsmsgerr.value = "E necessario efetuar o login."; document.frmErro.submit();').
END.                           

END PROCEDURE.
&ANALYZE-RESUME
&ANALYZE-SUSPEND _CODE-BLOCK _PROCEDURE rodajava 
PROCEDURE rodajava :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

 {includes/rodajava.i}
 
END PROCEDURE.
&ANALYZE-RESUME
