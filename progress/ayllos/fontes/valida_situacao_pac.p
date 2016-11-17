/* .............................................................................

   Programa: Fontes/valida_situacao_pac.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Agosto/2005.                       Ultima atualizacao: 13/02/2006

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado.
   Objetivo  : Validar se o PAC esta ativo.

   Alteracoes 24/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando

              13/02/2006 - Inclusao do parametro cdcooper para a unificacao
                           dos bancos de dados - SQLWorks - Fernando.

............................................................................. */

DEF INPUT  PARAM par_cdcooper AS INT                              NO-UNDO.
DEF INPUT  PARAM par_cdagenci AS INT                              NO-UNDO.
DEF OUTPUT PARAM par_cdcritic AS INT                              NO-UNDO.

par_cdcritic = 0.

FIND crapage WHERE crapage.cdcooper = par_cdcooper AND
                   crapage.cdagenci = par_cdagenci NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapage   THEN
     par_cdcritic = 15.
ELSE     
IF   crapage.insitage <> 1   THEN
     par_cdcritic = 856.

/* .......................................................................... */

