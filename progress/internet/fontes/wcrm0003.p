/* .............................................................................
   
   Programa: wcrm0003.p
   Sistema : CRM 
   Sigla   : CRM
   Autor   : Evandro
   Data    : Agosto/2006                   Ultima Atualizacao:  28/10/216
   
   Dados referentes ao programa:
   
   Frequencia: esporadica(internet)
   Objetivo  : chama a BO de criação da inscrição e retona um XML caso haja
               algum erro
   
   Alteracoes: 10/04/2008 - Gravar cratidp.cdagenci = 0 quando 
                            crapedp.tpevento = 7 (Assembléia) (Diego).
           
               03/11/2008 - Inclusao widget-pool (martin)
               
               08/03/2010 - Atribuir codificacao ISO-8859-1 ao XML (David).
 
			   28/10/2016 - Inclusão da chamada da procedure pc_informa_acesso_progrid
							para gravar log de acesso. (Jean Michel)
														
..............................................................................*/

{ sistema/generico/includes/var_log_progrid.i }
 
CREATE WIDGET-POOL.
 
/* parâmetros recebidos pela URL */
DEFINE VARIABLE par_idevento LIKE crapidp.idevento                    NO-UNDO.
DEFINE VARIABLE par_cdcooper LIKE crapidp.cdcooper                    NO-UNDO.
DEFINE VARIABLE par_dtanoage LIKE crapidp.dtanoage                    NO-UNDO.
DEFINE VARIABLE par_cdagenci LIKE crapidp.cdagenci                    NO-UNDO.
DEFINE VARIABLE par_cdevento LIKE crapidp.cdevento                    NO-UNDO.
DEFINE VARIABLE par_nrseqeve LIKE crapidp.nrseqeve                    NO-UNDO.
DEFINE VARIABLE par_nrdconta LIKE crapidp.nrdconta                    NO-UNDO.
DEFINE VARIABLE par_idseqttl LIKE crapidp.idseqttl                    NO-UNDO.
DEFINE VARIABLE par_nminseve LIKE crapidp.nminseve                    NO-UNDO.
DEFINE VARIABLE par_dsdemail LIKE crapidp.dsdemail                    NO-UNDO.
DEFINE VARIABLE par_nrdddins LIKE crapidp.nrdddins                    NO-UNDO.
DEFINE VARIABLE par_nrtelins LIKE crapidp.nrtelins                    NO-UNDO.
DEFINE VARIABLE par_cdgraupr LIKE crapidp.cdgraupr                    NO-UNDO.
DEFINE VARIABLE par_tpinseve LIKE crapidp.tpinseve                    NO-UNDO.
DEFINE VARIABLE aux_dscritic AS CHARACTER                             NO-UNDO.
DEFINE VARIABLE aux_nrdrowid AS CHARACTER                             NO-UNDO.

/* Variaveis de controle do XML */
DEFINE VARIABLE xDoc         AS HANDLE                                NO-UNDO.
DEFINE VARIABLE xRoot        AS HANDLE                                NO-UNDO.
DEFINE VARIABLE xField       AS HANDLE                                NO-UNDO.
DEFINE VARIABLE xText        AS HANDLE                                NO-UNDO.

/*** Declaração de BOs ***/
DEFINE VARIABLE h-b1wpgd0009 AS HANDLE                                NO-UNDO.

/*** Temp Tables ***/
DEFINE TEMP-TABLE cratidp    NO-UNDO      LIKE crapidp.

/* Cria um campo com seu valor no XML */
FUNCTION criaCampo RETURNS LOGICAL
    (INPUT nomeCampo  AS CHAR,
     INPUT textoCampo AS CHAR):
    xDoc:CREATE-NODE(xField,CAPS(nomeCampo),"ELEMENT").
    xRoot:APPEND-CHILD(xField).
    xDoc:CREATE-NODE(xText,"","TEXT").
    xField:APPEND-CHILD(xText).
    xText:NODE-VALUE = STRING(textoCampo).
    RETURN TRUE.
END FUNCTION.

/* Include para usar os comandos para WEB */
{src/web2/wrap-cgi.i}

/* Configura a saída como XML */
OUTPUT-CONTENT-TYPE ("text/xml":U).

ASSIGN par_idevento = INT(GET-VALUE("aux_idevento"))
       par_cdcooper = INT(GET-VALUE("aux_cdcooper"))
       par_dtanoage = INT(GET-VALUE("aux_dtanoage"))
       par_cdagenci = INT(GET-VALUE("aux_cdagenci"))
       par_cdevento = INT(GET-VALUE("aux_cdevento"))
       par_nrseqeve = INT(GET-VALUE("aux_nrseqeve"))
       par_nrdconta = INT(GET-VALUE("aux_nrdconta"))
       par_idseqttl = INT(GET-VALUE("aux_idseqttl"))
       par_nminseve = GET-VALUE("aux_nminseve")
       par_dsdemail = GET-VALUE("aux_dsdemail")
       par_nrdddins = INT(GET-VALUE("aux_nrdddins"))
       par_nrtelins = INT(GET-VALUE("aux_nrtelins"))
       par_cdgraupr = INT(GET-VALUE("aux_cdgraupr"))
       par_tpinseve = INT(GET-VALUE("aux_tpinseve")).

RUN insere_log_progrid("WPGD0003.p",STRING(par_cdcooper) + "|" + STRING(par_nrdconta)).
			 
CREATE X-DOCUMENT xDoc.
CREATE X-NODEREF  xRoot.
CREATE X-NODEREF  xField.
CREATE X-NODEREF  xText.

xDoc:ENCODING = "ISO-8859-1".

/* Cria a raiz principal */
xDoc:CREATE-NODE( xRoot, "CECRED", "ELEMENT" ).
xDoc:APPEND-CHILD( xRoot ).

DO WHILE TRUE:

    /* se for cooperado ou familiar, valida conta */
    IF  par_tpinseve = 1 OR par_tpinseve = 2  THEN
        DO:         
           /* Valida a conta */
           FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                              crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
        
           /* Valida a titularidade */
           FIND crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                              crapttl.nrdconta = par_nrdconta AND
                              crapttl.idseqttl = par_idseqttl NO-LOCK NO-ERROR.
        
           IF  NOT AVAILABLE crapass  OR 
               NOT AVAILABLE crapttl  THEN
               DO:
                   criaCampo("ERRO","Conta-DV e/ou Titularidade inválidos").
                   LEAVE.
               END.
        END.

    /* Instancia a BO para executar as procedures */
    RUN dbo/b1wpgd0009.p PERSISTENT SET h-b1wpgd0009.
    
    /* Se BO foi instanciada */
    IF  VALID-HANDLE(h-b1wpgd0009)  THEN
        DO:
            EMPTY TEMP-TABLE cratidp.
            
            FIND crapedp WHERE crapedp.cdcooper = par_cdcooper AND
                               crapedp.idevento = par_idevento AND
                               crapedp.dtanoage = par_dtanoage AND
                               crapedp.cdevento = par_cdevento NO-LOCK NO-ERROR.
                        
            CREATE cratidp.
            ASSIGN cratidp.cdagenci = IF  crapedp.tpevento = 7  THEN
                                          0
                                      ELSE 
                                          par_cdagenci
                   cratidp.cdageins = par_cdagenci
                   cratidp.cdcooper = par_cdcooper
                   cratidp.cdevento = par_cdevento
                   cratidp.nrseqeve = par_nrseqeve
                   cratidp.cdgraupr = IF  par_cdgraupr = 0  THEN
                                          9 
                                      ELSE
                                          par_cdgraupr
                   cratidp.cdoperad = ""
                   cratidp.dsdemail = par_dsdemail
                   cratidp.flgdispe = NO
                   cratidp.flginsin = YES
                   cratidp.tpinseve = IF  par_tpinseve = 3  THEN
                                          2
                                      ELSE
                                          par_tpinseve
                   cratidp.dsobsins = ""
                   cratidp.dtanoage = par_dtanoage
                   cratidp.dtconins = ?
                   cratidp.dtpreins = TODAY
                   cratidp.idevento = par_idevento
                   cratidp.idseqttl = par_idseqttl
                   cratidp.idstains = 1
                   cratidp.nminseve = par_nminseve
                   cratidp.nrdconta = IF  par_tpinseve = 3  THEN
                                          0
                                      ELSE
                                          par_nrdconta
                   cratidp.nrdddins = par_nrdddins
                   cratidp.nrseqdig = ?
                   cratidp.nrtelins = par_nrtelins.
            
            RUN inclui-registro IN h-b1wpgd0009(INPUT TABLE cratidp, 
                                               OUTPUT aux_dscritic, 
                                               OUTPUT aux_nrdrowid).
        
            /* "mata" a instância da BO */
            DELETE PROCEDURE h-b1wpgd0009 NO-ERROR.
        
            IF  aux_dscritic <> ""  THEN
                DO:
                    criaCampo("ERRO",aux_dscritic).
                    LEAVE.
                END.
         
        END. /* IF VALID-HANDLE(h-b1wpgd0009) */
    ELSE
        DO:
            criaCampo("ERRO","BO não inicializada").
            LEAVE.
        END.

    LEAVE.

END. /* Fim do WHILE TRUE */

xDoc:SAVE("STREAM","WEBSTREAM").

DELETE OBJECT xDoc.
DELETE OBJECT xRoot.
DELETE OBJECT xField.
DELETE OBJECT xText.
  
/* .......................................................................... */
