/* .............................................................................

   Programa: Fontes/datavale.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Maio/97                          Ultima Atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas.
   Objetivo  : Verificar se e' data valida.

   .......................................................................... */

DEF INPUT   PARAM   aux_dia   AS INT     NO-UNDO.
DEF INPUT   PARAM   aux_mes   AS INT     NO-UNDO.
DEF INPUT   PARAM   aux_ano   AS INT     NO-UNDO.
DEF OUTPUT  PARAM   aux_data  AS DATE    NO-UNDO.

IF   aux_ano < 1899 THEN
     aux_ano = aux_ano + 1900.

IF   aux_dia >  31 OR aux_dia = 0 OR aux_mes = 0 OR aux_mes > 12   THEN
     DO:
	 aux_data = ?.
	 RETURN.
     END.

IF   aux_dia = 31 AND NOT CAN-DO("01,03,05,07,08,10,12",STRING(aux_mes,"99"))
     THEN
     DO:
	 aux_data = ?.
	 RETURN.
     END.

IF   aux_dia > 28 AND aux_mes = 2 THEN
     DO:
	 IF   aux_dia = 30 THEN
	      DO:
		  aux_data = ?.
		  RETURN.
	      END.
	 ELSE
	      DO:
		  IF  aux_ano MOD 4 > 0 THEN
		      DO:
			  aux_data = ?.
			  RETURN.
		      END.
	      END.
     END.

aux_data = DATE(aux_mes,aux_dia,aux_ano).

/* .......................................................................... */
