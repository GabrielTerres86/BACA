/* .............................................................................

   Programa: Fontes/idade.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Setembro/97.                        Ultima Atualizacao: 25/03/98

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas.
   Objetivo  : Calcular a idade do associado em anos e meses.

   Alteracoes: 25/03/98 - Tratamento para milenio e troca para V8 (Margarete).

............................................................................. */

DEF INPUT  PARAMETER par_dtnasctl AS DATE FORMAT "99/99/9999"        NO-UNDO.
DEF INPUT  PARAMETER par_dtmvtolt AS DATE FORMAT "99/99/9999"        NO-UNDO.
DEF OUTPUT PARAMETER par_nrdeanos AS INT                             NO-UNDO.
DEF OUTPUT PARAMETER par_nrdmeses AS INT                             NO-UNDO.
DEF OUTPUT PARAMETER par_dsdidade AS CHAR                            NO-UNDO.

IF   par_dtmvtolt < par_dtnasctl   THEN
     DO:
	 ASSIGN par_dsdidade = "NAO E POSSIVEL CALCULAR A IDADE."
		par_nrdeanos = 0
		par_nrdmeses = 0.
	 RETURN.
     END.

ASSIGN par_nrdeanos = TRUNC((par_dtmvtolt - par_dtnasctl) / 365,0)
       par_nrdmeses = TRUNC(((par_dtmvtolt - par_dtnasctl) MOD 365) / 30,0)

       par_dsdidade = STRING(par_nrdeanos) + " anos" +
		      IF par_nrdmeses > 0
			 THEN " e " + STRING(par_nrdmeses) + " meses"
			 ELSE "".

/* .......................................................................... */
