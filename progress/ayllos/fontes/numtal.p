/* .............................................................................

   Programa: Fontes/numtal.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/91.                        Ultima atualizacao: 10/08/93

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas.
   Objetivo  : Calcular a partir do numero do cheque o numero do talao e a
	       posicao do cheque dentro do mesmo.

............................................................................. */

DEF SHARED VAR glb_nrcalcul AS DECIMAL FORMAT ">>>>>>>>>>>>>9"       NO-UNDO.
DEF SHARED VAR glb_nrtalchq AS INT                                   NO-UNDO.
DEF SHARED VAR glb_nrposchq AS INT     FORMAT "z9"                   NO-UNDO.
DEF SHARED VAR glb_nrfolhas AS INT                                   NO-UNDO.

DEF        VAR aux_calculo  AS INT                                   NO-UNDO.
DEF        VAR aux_resto    AS INT                                   NO-UNDO.

IF   glb_nrfolhas = 0   THEN
     glb_nrfolhas = 20.

ASSIGN aux_calculo  = TRUNCATE(INTEGER(SUBSTRING(STRING(glb_nrcalcul,
				       "zzzzzzz9"),1,7)) / glb_nrfolhas,0)

       aux_resto    = INTEGER(SUBSTRING(STRING(glb_nrcalcul,
					"zzzzzzz9"),1,7)) MOD glb_nrfolhas

       glb_nrtalchq = IF aux_resto = 0 THEN aux_calculo  ELSE aux_calculo + 1

       glb_nrposchq = IF aux_resto = 0 THEN glb_nrfolhas ELSE aux_resto

       glb_nrfolhas = 0.

/* .......................................................................... */
