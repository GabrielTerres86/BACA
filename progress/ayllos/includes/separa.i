/* .............................................................................
   Programa: includes/separa.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson/Odair
   Data    : Agosto/95

   Dados referentes ao programa:

   Frequencia: Sempre que chamado pelo programa fontes/extenso.p
   Objetivo  : Separa em linhas o literal do extenso.
............................................................................. */

aux_dsvsobra = aux_vlextens.

IF   LENGTH(aux_vlextens)              <= aux_qtlinhas[aux_inlinhas] THEN
     ASSIGN aux_dslinhas[aux_inlinhas]  = aux_vlextens
	    aux_dsvsobra                = "".
ELSE
     DO:
	 ASSIGN aux_dslinhas[aux_inlinhas] = SUBSTR(aux_vlextens,1,
						    aux_qtlinha1 + 1) + "."
		aux_vlposatu = R-INDEX(aux_dslinhas[aux_inlinhas]," ")
		aux_vlposant = R-INDEX(aux_dslinhas[aux_inlinhas],"-").

	 IF   aux_vlposatu  > aux_qtlinhas[aux_inlinhas] THEN
	      aux_vlposant = 0.

	 IF   aux_vlposatu > aux_vlposant  THEN
	      aux_caracter = aux_vlposatu.
	 ELSE
	      aux_caracter = aux_vlposant.

	 ASSIGN aux_dslinhas[aux_inlinhas] = SUBSTR(aux_vlextens,1,aux_caracter)
		aux_dsvsobra = SUBSTR(aux_vlextens,aux_caracter + 1).
     END.

ASSIGN aux_dslinhas[aux_inlinhas] = TRIM(aux_dslinhas[aux_inlinhas])
       aux_contador = 1.

DO  WHILE aux_contador < LENGTH(aux_dslinhas[aux_inlinhas]) :

    IF  SUBSTR(aux_dslinhas[aux_inlinhas],aux_contador,1) = ","    AND
	SUBSTR(aux_dslinhas[aux_inlinhas],aux_contador + 2, 5) = "REAIS" THEN

       DO:
	   hlp_dsextens = SUBSTR(aux_dslinhas[aux_inlinhas],aux_contador + 1,
			  LENGTH(aux_dslinhas[aux_inlinhas]) - aux_contador).
	   IF   SUBSTR(aux_dslinhas[aux_inlinhas],aux_contador - 1,1) = "L"
	   THEN
		aux_dslinhas[aux_inlinhas] = SUBSTR(aux_dslinhas[aux_inlinhas],
			     1,aux_contador - 1) + hlp_dsextens.
	   ELSE
		aux_dslinhas[aux_inlinhas] = SUBSTR(aux_dslinhas[aux_inlinhas],
			     1,aux_contador - 1) + " DE" + hlp_dsextens.

	   LEAVE.

       END.

    aux_contador = aux_contador + 1.

END.

ASSIGN flg_doisbran = FALSE
       aux_contador = 1.

DO WHILE LENGTH(aux_dslinhas[aux_inlinhas]) < aux_qtlinhas[aux_inlinhas] AND
	 NOT flg_doisbran AND LENGTH(aux_dsvsobra) > 0:

   DO  WHILE aux_contador < LENGTH(aux_dslinhas[aux_inlinhas]) :

       IF   SUBSTR(aux_dslinhas[aux_inlinhas],aux_contador,1) = " "       AND
	    SUBSTR(aux_dslinhas[aux_inlinhas],aux_contador - 1,2) <> "  " THEN

	    DO:
		ASSIGN  hlp_dsextens = SUBSTR(aux_dslinhas[aux_inlinhas],
			       aux_contador,LENGTH(aux_dslinhas[aux_inlinhas]) -
			       aux_contador + 1)
			aux_dslinhas[aux_inlinhas] =
			     SUBSTR(aux_dslinhas[aux_inlinhas],1,aux_contador) +
			     hlp_dsextens
			aux_contador = aux_contador + 2.

		LEAVE.

	    END.
       ELSE
       IF   SUBSTR(aux_dslinhas[aux_inlinhas],aux_contador,1) = " " AND
	    SUBSTR(aux_dslinhas[aux_inlinhas],aux_contador - 1,1) = " " THEN
	    aux_contador = aux_contador + 2.

       aux_contador = aux_contador + 1.

   END.

   IF  aux_contador >=  LENGTH(aux_dslinhas[aux_inlinhas]) THEN
       flg_doisbran  = TRUE.

END.

IF   aux_tpextens = "M" AND
     LENGTH(aux_dslinhas[aux_inlinhas]) <> aux_qtlinhas[aux_inlinhas] THEN
     aux_dslinhas[aux_inlinhas] = aux_dslinhas[aux_inlinhas] +
     FILL("*",aux_qtlinhas[aux_inlinhas] - LENGTH(aux_dslinhas[aux_inlinhas])).
