/* .............................................................................

   Programa: Fontes/gera_rating.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Outubro/2009                       Ultima Atualizacao: 17/03/2011
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que chamado por outros programas.
   
   Objetivo  : Gerar o rating do cooperado e arquivo de impressao.
   
   ENTRADA   : par_cdcooper : Numero da cooperativa.
               par_nrdconta : Numero da conta.              
               par_tpctrato : Tipo de contrato.
                              ( 1- Cheque especial 
                                2- Desconto de cheque  
                                3- Desconto de titulo
                               90- Emprestimo)                
               par_nrctrato : Numero da proposta.                                                                                                   
               par_flgcriar : Se TRUE grava RATING. Senao soh imprime.                                                                       
                                                    
                                                        
   Alteracoes: 17/10/2009 - Incluido nas mensagens de efetivacao do rating o 
                            numero do contrato da pior nota (Elton).
                            
               01/03/2010 - Mostrar todas as criticas do Rating de uma vez
                            só (Gabriel).             
                            
               20/04/2010 - Alteracao referente a adaptacao do novo rating
                            para o Ayllos Web (David).
                            
               17/03/2011 - Incluso parametro tt-impressao-risco-tl na 
                            gera_rating (Guilherme).

.............................................................................*/

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0043tt.i }
{ sistema/generico/includes/b1wgen9999tt.i }
{ includes/var_online.i  }
{ includes/gera_rating.i }
                                                
DEF  INPUT PARAM par_cdcooper AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrdconta AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_tpctrato AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrctrato AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_flgcriar AS LOGI                                  NO-UNDO.

RUN sistema/generico/procedures/b1wgen0043.p PERSISTENT SET h-b1wgen0043.

IF  NOT VALID-HANDLE(h-b1wgen0043)  THEN
    DO:
        MESSAGE "Handle invalido para BO b1wgen0043.".
        RETURN "NOK".
    END.

RUN gera_rating IN h-b1wgen0043 (INPUT glb_cdcooper,
                                 INPUT 0,   /** Pac   **/
                                 INPUT 0,   /** Caixa **/
                                 INPUT glb_cdoperad,
                                 INPUT glb_nmdatela,
                                 INPUT 1,   /** Ayllos  **/
                                 INPUT par_nrdconta,
                                 INPUT 1,   /** Titular **/
                                 INPUT glb_dtmvtolt,
                                 INPUT glb_dtmvtopr,
                                 INPUT glb_inproces,
                                 INPUT par_tpctrato,
                                 INPUT par_nrctrato,
                                 INPUT par_flgcriar,
                                 INPUT TRUE,   /** Log **/
                                OUTPUT TABLE tt-erro,
                                OUTPUT TABLE tt-cabrel,
                                OUTPUT TABLE tt-impressao-coop,
                                OUTPUT TABLE tt-impressao-rating,
                                OUTPUT TABLE tt-impressao-risco,
                                OUTPUT TABLE tt-impressao-risco-tl,
                                OUTPUT TABLE tt-impressao-assina,
                                OUTPUT TABLE tt-efetivacao,
                                OUTPUT TABLE tt-ratings).

DELETE PROCEDURE h-b1wgen0043.

HIDE MESSAGE NO-PAUSE.

IF  RETURN-VALUE = "NOK"  THEN
    DO:
        RUN fontes/lista_criticas_rating.p (INPUT TABLE tt-erro).
        RETURN "NOK".
    END.

IF  NOT par_flgcriar  THEN 
    RUN fontes/imprimir_rating.p (INPUT TABLE tt-impressao-coop,
                                  INPUT TABLE tt-impressao-rating,
                                  INPUT TABLE tt-impressao-risco,
                                  INPUT TABLE tt-impressao-risco-tl,
                                  INPUT TABLE tt-impressao-assina,
                                  INPUT TABLE tt-efetivacao).
ELSE                                   
    RUN fontes/mostra_rating_gerado.p (INPUT par_nrdconta,
                                       INPUT par_tpctrato,
                                       INPUT par_nrctrato,
                                       INPUT TABLE tt-impressao-coop,
                                       INPUT TABLE tt-impressao-rating,
                                       INPUT TABLE tt-impressao-risco,
                                       INPUT TABLE tt-impressao-risco-tl,
                                       INPUT TABLE tt-impressao-assina,
                                       INPUT TABLE tt-efetivacao,
                                       INPUT TABLE tt-ratings).
     
RETURN "OK".
                                                                               
/*...........................................................................*/
