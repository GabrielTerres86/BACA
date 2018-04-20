/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank43.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Dezembro/2008                     Ultima atualizacao: 03/09/2011
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Gerenciar operadores da conta e itens do menu do InternetBank.
   
   Alteracoes: 03/09/2011 - Gerar nova senha do operador (Guilherme).
 
..............................................................................*/
 
CREATE WIDGET-POOL.
    
{ sistema/generico/includes/var_internet.i }

DEF VAR h-b1wnet0002 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapttl.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_nrcpfope LIKE crapopi.nrcpfope                    NO-UNDO.
DEF  INPUT PARAM par_desdacao AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_nmoperad LIKE crapopi.nmoperad                    NO-UNDO.
DEF  INPUT PARAM par_dsdemail LIKE crapopi.dsdemail                    NO-UNDO.
DEF  INPUT PARAM par_dsdcargo LIKE crapopi.dsdcargo                    NO-UNDO.
DEF  INPUT PARAM par_flgsitop LIKE crapopi.flgsitop                    NO-UNDO.
DEF  INPUT PARAM par_geraflux AS INTE	                    		   NO-UNDO.
DEF  INPUT PARAM par_cdditens AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_vllbolet LIKE crapopi.vllbolet                    NO-UNDO.
DEF  INPUT PARAM par_vllimtrf LIKE crapopi.vllimtrf                    NO-UNDO.
DEF  INPUT PARAM par_vllimted LIKE crapopi.vllimted                    NO-UNDO.
DEF  INPUT PARAM par_vllimvrb LIKE crapopi.vllimvrb                    NO-UNDO.
DEF  INPUT PARAM par_vllimflp LIKE crapopi.vllimflp                    NO-UNDO.
DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

IF par_geraflux = ? THEN
DO:
	ASSIGN par_geraflux = 0.
END.

RUN sistema/internet/procedures/b1wnet0002.p PERSISTENT SET h-b1wnet0002.
                
IF  NOT VALID-HANDLE(h-b1wnet0002)  THEN
    DO:
        ASSIGN aux_dscritic = "Handle invalido para BO b1wnet0002.".
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
        RETURN "NOK".
    END.
       
RUN gerenciar-operador IN h-b1wnet0002 (INPUT par_cdcooper,
                                        INPUT 90,             /** PAC      **/
                                        INPUT 900,            /** Caixa    **/
                                        INPUT "996",          /** Operador **/
                                        INPUT "INTERNETBANK", /** Tela     **/
                                        INPUT 3,              /** Origem   **/
                                        INPUT par_nrdconta,
                                        INPUT par_idseqttl,
                                        INPUT par_nrcpfope,
                                        INPUT par_desdacao,
                                        INPUT par_nmoperad,
                                        INPUT par_dsdemail,
                                        INPUT par_dsdcargo,
                                        INPUT par_flgsitop,
										INPUT par_geraflux,
                                        INPUT par_cdditens,
                                        INPUT par_vllbolet,
                                        INPUT par_vllimtrf,
                                        INPUT par_vllimted,
                                        INPUT par_vllimvrb,
                                        INPUT par_vllimflp,
                                        INPUT TRUE,           /** Logar    **/  
                                       OUTPUT TABLE tt-erro).
    
DELETE PROCEDURE h-b1wnet0002.

IF  RETURN-VALUE = "NOK"  THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR. 
                    
        IF  AVAILABLE tt-erro  THEN
            aux_dscritic = tt-erro.dscritic.
        ELSE
        DO:
            IF  par_desdacao = "GERARNOVASENHA"  THEN
            DO:
                aux_dscritic = "Nao foi possivel gerar nova senha" +
                               " para o operador.".
            END.
            ELSE
            aux_dscritic = "Nao foi possivel " +  LC(par_desdacao) +
                           " o operador.".
        END.           
        xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
                                                       
        RETURN "NOK".    
    END.

IF  par_desdacao = "GERARNOVASENHA"  THEN
DO:
    aux_dscritic = "A nova senha numerica para acesso" +
                   " a conta-online sera enviada para" +
                   " o e-mail do operador.".
END.
ELSE
DO:
    IF par_geraflux = 1 AND aux_dscritic = "" THEN
	DO:
		ASSIGN aux_dscritic = "Alteracao registrada, aguardando aprovacao dos demais prepostos para ser finalizada".
	END.
	ELSE
	DO:
    aux_dscritic = "Operador " + 
                  (IF  par_desdacao = "CADASTRAR"  THEN 
                       "cadastrado" 
                   ELSE
                       "alterado") + 
                   " com sucesso.".
	END.
END.

FIND FIRST tt-erro NO-LOCK NO-ERROR.

IF  AVAILABLE tt-erro  THEN
    aux_dscritic = aux_dscritic + "#" + tt-erro.dscritic.
    
xml_dsmsgerr = "<dsmsgsuc>" + aux_dscritic + "</dsmsgsuc>".
                                                       
RETURN "OK".

/*............................................................................*/
