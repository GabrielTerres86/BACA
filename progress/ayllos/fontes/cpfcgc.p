/* .............................................................................

   Programa: Fontes/cpfcgc.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/91                         Ultima atualizacao: 01/10/2003

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas.
   Objetivo  : Identificar o numero informado, desviando conforme for CPF (para
               a rotina fontes/cpffun.p) ou CGC (para a rotina fontes/cgcfun.p).

   ATENCAO!!! - A documentacao da rotina enviada pela RECEITA FEDERAL esta na
             pasta da tela MATRIC.

   Alteracoes: Alterado para tratar melhor a identificacao de CPF/CNPJ (Edson).

............................................................................. */

DEF SHARED VAR glb_nrcalcul AS DECIMAL FORMAT ">>>>>>>>>>>>>9"       NO-UNDO.
DEF SHARED VAR glb_stsnrcal AS LOGICAL                               NO-UNDO.

DEF SHARED VAR shr_inpessoa AS INT                                   NO-UNDO.

ASSIGN glb_stsnrcal = FALSE
       shr_inpessoa = 1.

IF   glb_nrcalcul = 9571   THEN
     DO:
         ASSIGN glb_stsnrcal = FALSE
                shr_inpessoa = 1.               /*  Valor default  */
         RETURN.
     END.

IF   LENGTH(STRING(glb_nrcalcul)) > 11   THEN
     DO:
         shr_inpessoa = 2.
         RUN fontes/cgcfun.p.
     END.
ELSE
     DO:
         RUN fontes/cpffun.p.

         IF   NOT glb_stsnrcal   THEN
              DO:
                   RUN fontes/cgcfun.p.

                   IF   glb_stsnrcal THEN
                        shr_inpessoa = 2.
              END.
         ELSE
              shr_inpessoa = 1.
     END.
     
/* .......................................................................... */

