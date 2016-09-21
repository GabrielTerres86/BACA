/* .............................................................................

   Programa: Fontes/proepr.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/96.                        Ultima atualizacao: 20/01/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para tratar PROPOSTAS DE EMPRESTIMOS/FINANCIAMENTO para a
               tela ATENDA.

   Alteracoes: 18/03/97 - Alterado para tratar FINANCIAMENTO COM HIPOTECA
                          (Edson).

             03/04/98 - Tratamento para milenio e troca para V8 (Margarete).

             23/03/2003 - Incluir tratamento da Concredi (Margarete).

             30/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
             
             08/04/2008 - Alterado formato do campo "crawepr.qtpreemp" de "z9"  
                         para "zz9" - Kbase IT Solutions - Paulo Ricardo Maciel.
                        
             25/05/2009 - Alteracao CDOPERAD (Kbase).

             18/03/2010 - Alterar para um browser dinamico (Gabriel). 
             
             18/06/2010 - Utilizar a BO 02. Incluir campo de envio a sede
                         (Gabriel)
    
             05/08/2010 - Incluir retorno da idade do cooperado (Gabriel).
             
             20/01/2015 - Adicionado parametro de opcoes do tipo de veiculo.
                          (Jorge/Gielow) - SD 241854.
                                                                           
............................................................................. */

{ sistema/generico/includes/var_internet.i }

{ includes/var_online.i }
{ includes/var_proepr.i "NEW" }

DEF INPUT PARAM par_nrdconta AS INTE                                NO-UNDO.
DEF INPUT PARAM par_vltotemp AS DECI                                NO-UNDO.


DEF VAR h-b1wgen0002 AS HANDLE                                      NO-UNDO.
DEF VAR par_dsdidade AS CHAR                                        NO-UNDO.


DO WHILE TRUE:

   RUN sistema/generico/procedures/b1wgen0002.p PERSISTENT SET h-b1wgen0002.

   RUN obtem-propostas-emprestimo IN h-b1wgen0002 (INPUT glb_cdcooper,
                                                   INPUT 0,
                                                   INPUT 0,
                                                   INPUT glb_cdoperad,
                                                   INPUT glb_nmdatela,
                                                   INPUT 1, /* Ayllos */
                                                   INPUT par_nrdconta,
                                                   INPUT 1,
                                                   INPUT glb_dtmvtolt,
                                                   INPUT 0,/*Contrato(todos)*/
                                                   INPUT FALSE,
                                                   OUTPUT TABLE tt-erro,
                                                   OUTPUT TABLE tt-proposta-epr,
                                                   OUTPUT TABLE tt-dados-gerais,
                                                   OUTPUT par_dsdidade).
   DELETE PROCEDURE h-b1wgen0002.

   IF   RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF   AVAIL tt-erro  THEN
                 MESSAGE tt-erro.dscritic.
            ELSE
                 MESSAGE "Nao foi possivel listar as propostas de emprestimo.".

            LEAVE.
        END.

   FIND FIRST tt-dados-gerais NO-LOCK NO-ERROR.

   IF   AVAIL tt-dados-gerais   THEN
        ASSIGN aux_lscatbem = tt-dados-gerais.lscatbem
               aux_lscathip = tt-dados-gerais.lscathip
               aux_ddmesnov = tt-dados-gerais.ddmesnov
               aux_dtdpagto = tt-dados-gerais.dtdpagto
               aux_lsveibem = "ZERO KM,USADO".

   RUN fontes/proepr_1.p (INPUT par_nrdconta,
                          INPUT par_vltotemp,  
                          INPUT par_dsdidade,
                          INPUT TABLE tt-proposta-epr).

   IF   aux_flgsaida   THEN
        LEAVE.
  
END. /* Fim do DO WHILE TRUE */


/* .......................................................................... */

