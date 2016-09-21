/* .............................................................................

   Programa: Fontes/gera_log.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Maio/2005.                          Ultima atualizacao: 05/12/2013

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado.
   Objetivo  : Gerar log da transacao - DEVE HAVER UMA TRANSACAO DECLARADA NO
               PROGRAMA QUE FEZ A CHAMADA.

   Alteracoes: 05/12/2013 - Inclusao de VALIDATE craplog (Carlos)

............................................................................. */

DEF INPUT  PARAM par_cdcooper AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_nrdconta AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_cdoperad AS CHAR                                NO-UNDO.
DEF INPUT  PARAM par_dstransa AS CHAR                                NO-UNDO.
DEF INPUT  PARAM par_cdprogra AS CHAR                                NO-UNDO.

DEF VAR aux_nrdotime AS INT                                          NO-UNDO.

DO WHILE TRUE:

   aux_nrdotime = TIME.

   IF   CAN-FIND(craplog WHERE craplog.cdcooper = par_cdcooper   AND
                               craplog.dttransa = TODAY          AND
                               craplog.hrtransa = aux_nrdotime   AND
                               craplog.cdoperad = par_cdoperad)  THEN
        NEXT.

   LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

CREATE craplog.
ASSIGN craplog.dttransa = TODAY
       craplog.hrtransa = TIME
       craplog.cdoperad = par_cdoperad
       craplog.cdcooper = par_cdcooper
       craplog.dstransa = par_dstransa
       craplog.nrdconta = par_nrdconta
       craplog.cdprogra = par_cdprogra.
     
VALIDATE craplog.

/* .......................................................................... */
