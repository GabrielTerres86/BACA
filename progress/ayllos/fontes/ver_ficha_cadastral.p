/* .............................................................................

   Programa: Fontes/ver_ficha_cadastral.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Eduardo          
   Data    : Junho/2006                            Ultima alteracao: 03/04/2012

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de consulta da tela FICHA CADASTRAL.

   Alteracoes: 03/04/2012 - Adicionado verificacao de retorno. (Jorge)
............................................................................. */

{ includes/var_online.i } 
{ includes/var_contas.i }
{ includes/var_ficha_cadastral.i "NEW" }

DEF INPUT  PARAM par_tipconsu AS LOGICAL                               NO-UNDO.

ASSIGN glb_cdcritic = 0
       aux_nmarqimp = ""
       aux_tipconsu = par_tipconsu.
       
RUN fontes/impficha_cadastral.p.

IF RETURN-VALUE <> "OK" THEN
    RETURN "NOK".

IF  par_tipconsu THEN
    RUN fontes/visualiza_ficha_cadastral.p.

/* .......................................................................... */
