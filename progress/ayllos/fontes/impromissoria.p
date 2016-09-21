/* .............................................................................

   Programa: Fontes/impromissoria.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Julho/2001.                     Ultima atualizacao: 07/10/2010

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para imprimir a nota promissoria.

   Alteracoes: 04/12/2001 - Incluir titulo na promissoria (Margarete).

               19/07/2002 - Primeiro nome completo depois abrev (Margarete).
               
               20/01/2003 - Ajuste na nota promissoria para tratar os 
                            conjuges fiadores (Eduardo).
                            
               08/09/2003 - Se nao encontrar a tabela LOCALIDADE, deixar o nome
                            da cidade em branco (Fernando).
                            
               09/12/2003 - Buscar nome da cooperativa no crapcop (Junior).

               26/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
                 
               08/06/2006 - Modificados campos referente endereco para a 
                            estrutura crapenc (Diego).
                            
               15/01/2007 - Substituicao da localidade do PAC da craptab pela
                            localidade da crapage (Elton).
                            
               03/06/2009 - Alteracao para utilizacao de BOs - Temp-tables -
                            GATI - Eder
               
               18/02/2010 - Alinhando campo cidade e data na direita 
                           (Daniel steiner).
                           
               13/08/2010 - Eliminar possibilidade de parametro negativo
                            na funcao SUBSTR(aux_tracoope ...)Tarefa 34406
                            (Irlan)                           
                            
               07/10/2010 - Alteracao para gerar a impresao na BO 28
                            GATI - Sandro             
                            
............................................................................. */
{ sistema/generico/includes/b1wgen0028tt.i }
{ sistema/generico/includes/b1wgen0019tt.i }
{ includes/var_online.i}
{ includes/var_sldccr.i }
{ sistema/generico/includes/var_internet.i }

DEF INPUT PARAM TABLE FOR tt_dados_promissoria.

DEF NEW GLOBAL SHARED STREAM str_1.

DEF        VAR h_b1wgen0028 AS HANDLE                                NO-UNDO.


RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h_b1wgen0028.

RUN gera_impressao_promissoria IN h_b1wgen0028 (INPUT glb_cdcooper,
                                                INPUT  TABLE tt_dados_promissoria,
                                                OUTPUT TABLE tt-erro).

DELETE PROCEDURE h_b1wgen0028. 

/******************************************************************/

