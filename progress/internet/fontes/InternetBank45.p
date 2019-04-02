/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank45.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Janeiro/2009                     Ultima atualizacao: 02/04/2019
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Alterar endereco do titular - Modulo "Meu Cadastro".
   
   Alteracoes: 24/05/2010 - Ajustes referente a alteracao nas BO's para tela
                            CONTAS (David).
                            
               04/07/2011 - Incluidos novos parametros na chamada da procedure
                            alterar-endereco-viainternetbank (Henrique).

               02/04/2019 - PRB0040682 - Correcao na rotina 45 para receber numero de logradouro com mais do que
                            9 posicoes para entao tratar na rotina 45 (Andreatta-Mouts)
 
..............................................................................*/
 
CREATE WIDGET-POOL.

{ sistema/generico/includes/var_internet.i }

DEF VAR h-b1wgen0038 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapttl.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_flgtpenc AS LOGI                                  NO-UNDO.
DEF  INPUT PARAM par_dsendere AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_nrendere AS INT64                                 NO-UNDO.
DEF  INPUT PARAM par_complend AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_nrdoapto AS INTE                                  NO-UNDO. 
DEF  INPUT PARAM par_cddbloco AS CHAR                                  NO-UNDO. 
DEF  INPUT PARAM par_nrcepend AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrcxapst AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nmbairro AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_nmcidade AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_cdufende AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_cdseqinc AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_tpendass AS INTE                                  NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

RUN sistema/generico/procedures/b1wgen0038.p PERSISTENT SET h-b1wgen0038.
                
IF  NOT VALID-HANDLE(h-b1wgen0038)  THEN
    DO:
        ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0038.".
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
                
        RETURN "NOK".
    END.
      
RUN alterar-endereco-viainternetbank IN h-b1wgen0038 
                                     (INPUT par_cdcooper,
                                      INPUT 90,             /** PAC      **/
                                      INPUT 900,            /** Caixa    **/
                                      INPUT "996",          /** Operador **/
                                      INPUT "INTERNETBANK", /** Tela     **/
                                      INPUT 3,              /** Origem   **/
                                      INPUT par_nrdconta,
                                      INPUT 1,              /** Titular  **/
                                      INPUT par_flgtpenc,
                                      INPUT par_dsendere,
                                      INPUT par_nrendere,
                                      INPUT par_nrcepend,
                                      INPUT par_complend,
                                      INPUT par_nrdoapto,
                                      INPUT par_cddbloco,
                                      INPUT par_nmbairro,
                                      INPUT par_nmcidade,
                                      INPUT par_cdufende,
                                      INPUT par_nrcxapst,
                                      INPUT par_cdseqinc,
                                      INPUT par_tpendass,
                                      INPUT TRUE,           /** Logar    **/  
                                     OUTPUT TABLE tt-erro).

DELETE PROCEDURE h-b1wgen0038.

IF  RETURN-VALUE = "NOK"  THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR. 
                    
        IF  AVAILABLE tt-erro  THEN
            aux_dscritic = tt-erro.dscritic.
        ELSE           
            aux_dscritic = "Nao foi possivel alterar o endereco.".
                   
        xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
                                                       
        RETURN "NOK".    
    END.

RETURN "OK".

/*............................................................................*/
