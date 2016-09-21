/* .............................................................................

   Programa: Fontes/sldrpp.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Marco/96.                           Ultima atualizacao: 21/06/2011

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para montar o saldo das poupancas programadas para a
               tela ATENDA.

   Alteracoes: 03/04/98 - Tratamento para milenio e troca para V8 (Margarete).

             25/05/2001 - Permitir que o usuario solicite o resgate de 
                          poupancas programadas. (Ze Eduardo).
 
             02/09/2004 - Incluido Flag Conta Investimento(Mirtes).
             
             16/09/2004 - Alinhamento dos campos (Evandro).

             10/11/2004 - Incluir na "Situacao" da Poupanca "-Bloq" se a
                          poupanca estiver bloqueada (Evandro).
            
             24/01/2005 - Aceitar valor negativo no saldo (Julio)
        
             01/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.   

             22/04/2008 - Vencimento de poupanca programada (Guilherme).
             
             27/04/2010 - Utilizar a BO b1wgen0006 (Gabriel).
             
             21/06/2011 - Adicionado param. aux. para controle de log (Jorge).  
             
...................... .......................................................*/

{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_rdcapp.i "NEW" }

{ sistema/generico/includes/var_internet.i }


DEF INPUT  PARAM par_flgsaldo AS LOGICAL                             NO-UNDO.

DEF VAR aux_flgftlog AS LOGI INITIAL TRUE                            NO-UNDO.

DEF VAR h-b1wgen0006 AS HANDLE                                       NO-UNDO.


/*  Leitura da poupanca programada  */
DO WHILE TRUE:

    IF par_flgsaldo AND aux_flgftlog THEN
        ASSIGN aux_flgftlog = TRUE.
    ELSE
        ASSIGN aux_flgftlog = FALSE.

    RUN sistema/generico/procedures/b1wgen0006.p 
                         PERSISTEN SET h-b1wgen0006.

    RUN consulta-poupanca IN h-b1wgen0006 (INPUT glb_cdcooper,
                                           INPUT 0,
                                           INPUT 0,
                                           INPUT glb_cdoperad,
                                           INPUT glb_nmdatela,
                                           INPUT 1, /* Ayllos */
                                           INPUT tel_nrdconta,
                                           INPUT 1, /* Titular */
                                           INPUT 0, /* Todos os Contratos*/
                                           INPUT glb_dtmvtolt,
                                           INPUT glb_dtmvtopr,
                                           INPUT glb_inproces,
                                           INPUT glb_cdprogra,
                                           INPUT aux_flgftlog,
                                           OUTPUT aux_vltotrpp,
                                           OUTPUT TABLE tt-erro,
                                           OUTPUT TABLE tt-dados-rpp).
    DELETE PROCEDURE h-b1wgen0006.
    
    /* gera log apenas no primeiro loop */
    ASSIGN aux_flgftlog = FALSE.

    IF   par_flgsaldo   THEN
         DO:
             RUN fontes/rdcapp.p(INPUT TABLE tt-dados-rpp).

             /* Se nao saiu da tela ... re-chama BO */
             IF   NOT aux_flgsaida   THEN
                  NEXT.

         END.

    LEAVE.

END. /* Fim do DO WHILE TRUE */


/* .......................................................................... */
