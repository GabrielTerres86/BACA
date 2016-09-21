/* .............................................................................

   Programa: Fontes/idade_rotina_nova.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Setembro/97.                        Ultima Atualizacao: 26/04/2005

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas.
   Objetivo  : Calcular a idade do associado em anos e meses.

   Alteracoes: 25/03/98 - Tratamento para milenio e troca para V8 (Margarete).

               26/04/2005 - Novo calculo de idade (Edson).

............................................................................. */

DEF INPUT  PARAMETER par_dtnasctl AS DATE FORMAT "99/99/9999"        NO-UNDO.
DEF INPUT  PARAMETER par_dtmvtolt AS DATE FORMAT "99/99/9999"        NO-UNDO.
DEF OUTPUT PARAMETER par_nrdeanos AS INT                             NO-UNDO.
DEF OUTPUT PARAMETER par_nrdmeses AS INT                             NO-UNDO.
DEF OUTPUT PARAMETER par_dsdidade AS CHAR                            NO-UNDO.

DEF VAR aux_nrdedias AS INT                                          NO-UNDO.
DEF VAR aux_dtcalcul AS DATE                                         NO-UNDO.

DEF VAR aux_contadia AS INT                                          NO-UNDO.
DEF VAR aux_nrmesant AS INT                                          NO-UNDO.

DEF VAR aux_qtdedias AS INT                                          NO-UNDO.

IF   par_dtmvtolt < par_dtnasctl   THEN
     DO:
         ASSIGN par_dsdidade = "NAO E POSSIVEL CALCULAR A IDADE."
                par_nrdeanos = 0
                par_nrdmeses = 0.
         RETURN.
     END.

IF   MONTH(par_dtnasctl) = 2   AND
       DAY(par_dtnasctl) = 29  THEN
     par_dtnasctl = par_dtnasctl - 1.

aux_nrdedias = par_dtmvtolt - par_dtnasctl.
aux_dtcalcul = par_dtnasctl.

DO aux_contadia = 1 TO aux_nrdedias:

   aux_dtcalcul = aux_dtcalcul + 1.
   
   IF   DAY(aux_dtcalcul) = DAY(par_dtnasctl)   AND
        MONTH(aux_dtcalcul) = MONTH(par_dtnasctl)   THEN
        ASSIGN par_nrdeanos = par_nrdeanos + 1
               par_nrdmeses = 0
               aux_qtdedias = 0.
   ELSE
   IF   MONTH(aux_dtcalcul) <> aux_nrmesant   THEN
        ASSIGN par_nrdmeses = par_nrdmeses + 1
               aux_nrmesant = month(aux_dtcalcul)
               aux_qtdedias = 0.
   ELSE
        aux_qtdedias = aux_qtdedias + 1.

END.  /*  Fim do DO .. TO  */

par_dsdidade = STRING(par_nrdeanos) + " anos" +
                  (IF par_nrdmeses > 0
                      THEN ", " + STRING(par_nrdmeses) + 
                           (IF par_nrdmeses > 1
                               THEN " meses"
                               ELSE " mes") 
                      ELSE "") +
                  (IF aux_qtdedias > 0
                      THEN " e " +
                           STRING(aux_qtdedias) +
                           (IF aux_qtdedias > 1
                               THEN " dias"
                               ELSE " dia")
                      ELSE "").

/*

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
*/
/* .......................................................................... */
