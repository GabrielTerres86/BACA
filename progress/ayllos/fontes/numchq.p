/* .............................................................................

   Programa: Fontes/numchq.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Outubro/91.                         Ultima atualizacao: 10/08/93

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas.
   Objetivo  : Calcular o numero do cheque e seu digito a partir do numero
	       do talao e sua posicao dentro deste.

............................................................................. */

DEF SHARED VAR glb_nrcalcul AS DECIMAL FORMAT ">>>>>>>>>>>>>9"       NO-UNDO.
DEF SHARED VAR glb_stsnrcal AS LOGICAL                               NO-UNDO.
DEF SHARED VAR glb_nrtalchq AS INT                                   NO-UNDO.
DEF SHARED VAR glb_nrposchq AS INT     FORMAT "z9"                   NO-UNDO.
DEF SHARED VAR glb_nrfolhas AS INT                                   NO-UNDO.

IF   glb_nrfolhas = 0   THEN
     glb_nrfolhas = 20.

glb_nrcalcul = (((glb_nrtalchq - 1) * glb_nrfolhas) + glb_nrposchq) * 10.

RUN fontes/digfun.p.

/* .......................................................................... */
