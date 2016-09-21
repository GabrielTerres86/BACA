/* .............................................................................

   Programa: Fontes/datfun.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Junho/96.                           Ultima atualizacao:   /  /

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas.
   Objetivo  : Efetuar operacoes com datas.

............................................................................. */

DEF INPUT-OUTPUT PARAM par_dtcalcul AS DATE                          NO-UNDO.
DEF INPUT        PARAM par_qtdmeses AS INT                           NO-UNDO.

DEF        VAR aux_dtultdia AS DATE                                  NO-UNDO.

DEF        VAR aux_contador AS INT                                   NO-UNDO.

DEF        VAR aux_ddcalcul AS INT                                   NO-UNDO.
DEF        VAR aux_mmcalcul AS INT                                   NO-UNDO.
DEF        VAR aux_aacalcul AS INT                                   NO-UNDO.

IF   par_qtdmeses > 0   THEN
     DO:
	 ASSIGN aux_ddcalcul = DAY(par_dtcalcul)
		aux_mmcalcul = MONTH(par_dtcalcul)
		aux_aacalcul = YEAR(par_dtcalcul).

	 DO aux_contador = 1 TO par_qtdmeses:

	    IF   aux_mmcalcul = 12   THEN
		 ASSIGN aux_mmcalcul = 1
			aux_aacalcul = aux_aacalcul + 1.
	    ELSE
		 aux_mmcalcul = aux_mmcalcul + 1.

	 END.   /*  Fim do DO .. TO  */

	 ASSIGN par_dtcalcul = DATE(aux_mmcalcul,01,aux_aacalcul)

		aux_dtultdia = ((DATE(MONTH(par_dtcalcul),28,
				       YEAR(par_dtcalcul)) + 4) -
					DAY(DATE(MONTH(par_dtcalcul),28,
						  YEAR(par_dtcalcul)) + 4)).

	 IF   aux_ddcalcul > DAY(aux_dtultdia)   THEN
	      par_dtcalcul = DATE(aux_mmcalcul,DAY(aux_dtultdia),aux_aacalcul).
	 ELSE
	      par_dtcalcul = DATE(aux_mmcalcul,aux_ddcalcul,aux_aacalcul).
     END.
ELSE
IF   par_qtdmeses < 0   THEN
     DO:
	 ASSIGN par_dtcalcul = par_dtcalcul

		aux_ddcalcul = DAY(par_dtcalcul)
		aux_mmcalcul = MONTH(par_dtcalcul)
		aux_aacalcul = YEAR(par_dtcalcul).

	 DO aux_contador = 1 TO (par_qtdmeses * -1):

	    IF   aux_mmcalcul = 1   THEN
		 ASSIGN aux_mmcalcul = 12
			aux_aacalcul = aux_aacalcul - 1.
	    ELSE
		 aux_mmcalcul = aux_mmcalcul - 1.

	 END.   /*  Fim do DO .. TO  */

	 ASSIGN par_dtcalcul = DATE(aux_mmcalcul,01,aux_aacalcul)

		aux_dtultdia = ((DATE(MONTH(par_dtcalcul),28,
				       YEAR(par_dtcalcul)) + 4) -
					DAY(DATE(MONTH(par_dtcalcul),28,
						 YEAR(par_dtcalcul)) + 4)).

	 IF   aux_ddcalcul > DAY(aux_dtultdia)   THEN
	      par_dtcalcul = DATE(aux_mmcalcul,DAY(aux_dtultdia),aux_aacalcul).
	 ELSE
	      par_dtcalcul = DATE(aux_mmcalcul,aux_ddcalcul,aux_aacalcul).
     END.

/* .......................................................................... */
