/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank20.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Marco/2007                        Ultima atualizacao: 23/01/2015

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Gerenciamento de sacados para geracao de boleto bancario 
   
   Alteracoes: 25/07/2008 - Gerar log detalhado (David).
                            
               03/11/2008 - Inclusao widget-pool (martin)

               27/02/2009 - Melhorias no servico de cobranca (David).
               
               18/04/2013 - Projeto Melhorias da Cobranca - gerar instrucao
                            de alteracao de dados do sacado. (Rafael)
 
               02/12/2014 - De acordo com a circula 3.656 do Banco Central, substituir nomenclaturas 
                            Cedente por Beneficiário e  Sacado por Pagador 
                            Chamado 229313 (Jean Reddiga - RKAM).    
                           
               23/01/2015 - Adicionar os campos de email e celular do pagador
                            Projeto Boleto por E-mail (Douglas)
..............................................................................*/

CREATE WIDGET-POOL. 
 
{ sistema/generico/includes/var_internet.i }
{ sistema/internet/includes/b1wnet0001tt.i }

DEF VAR h-b1wnet0001 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

DEF  INPUT PARAM par_cdcooper LIKE crapcob.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapcob.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_nmdsacad LIKE crapsab.nmdsacad                    NO-UNDO.
DEF  INPUT PARAM par_cdtpinsc LIKE crapsab.cdtpinsc                    NO-UNDO.
DEF  INPUT PARAM par_nrinssac LIKE crapsab.nrinssac                    NO-UNDO.
DEF  INPUT PARAM par_dsendsac LIKE crapsab.dsendsac                    NO-UNDO.
DEF  INPUT PARAM par_nrendsac LIKE crapsab.nrendsac                    NO-UNDO.
DEF  INPUT PARAM par_complend LIKE crapsab.nmdsacad                    NO-UNDO.
DEF  INPUT PARAM par_nmbaisac LIKE crapsab.nmbaisac                    NO-UNDO.
DEF  INPUT PARAM par_nrcepsac LIKE crapsab.nrcepsac                    NO-UNDO.
DEF  INPUT PARAM par_nmcidsac LIKE crapsab.nmcidsac                    NO-UNDO.
DEF  INPUT PARAM par_cdufsaca LIKE crapsab.cdufsaca                    NO-UNDO.
DEF  INPUT PARAM par_cdsitsac LIKE crapsab.cdsitsac                    NO-UNDO.
DEF  INPUT PARAM par_dtmvtolt LIKE crapdat.dtmvtolt                    NO-UNDO.
DEF  INPUT PARAM par_tprotina AS INTE                                  NO-UNDO.
/* Tipo de instrução: 0 = Alteração Normal, 1 = instrução de alteração */
DEF  INPUT PARAM par_tpinstru AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_dsdemail LIKE crapsab.dsdemail                    NO-UNDO.
DEF  INPUT PARAM par_nrcelsac LIKE crapsab.nrcelsac                    NO-UNDO.
                                              
DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

RUN sistema/internet/procedures/b1wnet0001.p PERSISTENT SET h-b1wnet0001.

IF  NOT VALID-HANDLE(h-b1wnet0001)  THEN
    DO:
        ASSIGN aux_dscritic = "Handle invalido para BO b1wnet0001.".
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
        RETURN "NOK".
    END.

RUN gerencia-sacados IN h-b1wnet0001 (INPUT par_cdcooper,
                                      INPUT 90,             /** PAC      **/
                                      INPUT 900,            /** Caixa    **/
                                      INPUT "996",          /** Operador **/
                                      INPUT "INTERNETBANK", /** Tela     **/
                                      INPUT "3",            /** Origem   **/
                                      INPUT par_nrdconta,
                                      INPUT par_idseqttl,
                                      INPUT par_nmdsacad,
                                      INPUT par_cdtpinsc,
                                      INPUT par_nrinssac,
                                      INPUT par_dsendsac,
                                      INPUT par_nrendsac,
                                      INPUT par_complend,
                                      INPUT par_nmbaisac,
                                      INPUT par_nrcepsac,
                                      INPUT par_nmcidsac,
                                      INPUT par_cdufsaca,
                                      INPUT par_cdsitsac,
                                      INPUT par_dtmvtolt,
                                      INPUT par_tprotina,
                                      INPUT par_tpinstru,
                                      INPUT TRUE,           /** Logar    **/
                                      INPUT par_dsdemail,
                                      INPUT par_nrcelsac,
                                     OUTPUT TABLE tt-erro).
            
DELETE PROCEDURE h-b1wnet0001.
                
IF  RETURN-VALUE = "NOK"  THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                
        IF  AVAILABLE tt-erro  THEN
            aux_dscritic = tt-erro.dscritic.
        ELSE
            aux_dscritic = "Nao foi possivel " + 
                          (IF  par_tprotina = 1  THEN
                               "cadastrar"
                           ELSE
                           IF  par_tprotina = 2  THEN
                               "alterar"
                           ELSE
                               "remover") + " o pagador.".
                    
        xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
        RETURN "NOK".
    END.
        
RETURN "OK".

/*............................................................................*/
