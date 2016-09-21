/* .............................................................................

   Programa: Fontes/intdec.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Junho/96.                           Ultima atualizacao:   /  /

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas.
   Objetivo  : Devolver a parte inteira e decimal de um valor.

............................................................................. */

DEF INPUT  PARAM par_vlcalcul AS DECIMAL DECIMALS 4                 NO-UNDO.
DEF OUTPUT PARAM par_vlintcal AS INTEGER                            NO-UNDO.
DEF OUTPUT PARAM par_vldeccal AS DECIMAL DECIMALS 4                 NO-UNDO.

ASSIGN par_vlintcal = INTEGER(SUBSTRING(STRING(par_vlcalcul,
					"9999999999.9999-"),1,10))

       par_vldeccal = DECIMAL(SUBSTRING(STRING(par_vlcalcul,
					"9999999999.9999-"),12,5)) / 10000.

IF   par_vlcalcul < 0    THEN
     par_vlintcal = par_vlintcal * -1.

/* .......................................................................... */
