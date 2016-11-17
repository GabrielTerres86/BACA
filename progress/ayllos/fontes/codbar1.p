/* .............................................................................

   Programa: Fontes/codbar1.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Dezembro/95                        Ultima atualizacao: 20/10/92

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas.
   Objetivo  : Calcular o digito verificador pelo modulo dez do codigo de barras


............................................................................. */

DEF INPUT-OUTPUT  PARAMETER par_cdbar AS char   NO-UNDO.

DEF        VAR aux_digito   AS INT     INIT 0                        NO-UNDO.
DEF        VAR aux_posicao  AS INT     INIT 0                        NO-UNDO.
DEF        VAR aux_peso     AS INT     INIT 2                        NO-UNDO.
DEF        VAR aux_calculo  AS INT     INIT 0  EXTENT 99             NO-UNDO.
DEF        VAR aux_resto    AS INT     INIT 0                        NO-UNDO.
DEF        VAR valor        AS INT     INIT 0                        NO-UNDO.


aux_resto =  LENGTH(STRING(par_cdbar)) MODULO 2.

IF   aux_resto = 0 THEN
     aux_peso = 1.
ELSE aux_peso = 2.

DO  aux_posicao = 1 TO LENGTH(STRING(par_cdbar)):

    aux_calculo[aux_posicao] = (INTEGER(SUBSTRING(STRING(par_cdbar),
					    aux_posicao,1)) * aux_peso).

    IF   aux_peso = 2   THEN
	 aux_peso = 1.
    ELSE
	 aux_peso = 2.

END.  /*  Fim do DO .. TO  */

DO  aux_posicao = 1 TO LENGTH(STRING(par_cdbar)):

    IF  aux_calculo[aux_posicao] > 9 THEN
	valor = valor + INTEGER(SUBSTR(STRING(aux_calculo[aux_posicao]),1,1)) +
			INTEGER(SUBSTR(STRING(aux_calculo[aux_posicao]),2,1)).
    ELSE
	valor = valor + aux_calculo[aux_posicao].

END.  /*  Fim do DO .. TO  */

aux_resto = valor MODULO 10.

IF   aux_resto = 0 THEN
     aux_digito = 0.
ELSE
     aux_digito = 10 - aux_resto.

par_cdbar = par_cdbar + STRING(aux_digito).

/* .......................................................................... */
