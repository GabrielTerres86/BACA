/* ..........................................................................

   Programa: Includes/crps294.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete/Planner
   Data    : Agosto/2000.                    Ultima atualizacao: 15/10/2008

   Dados referentes ao programa:

   Frequencia: Diario (Batch - Background).
   Objetivo  : Atende a solicitacao 4.
               Imprime funcionarios/conselheiros administrativos e ou fiscal
                       que possuem creditos.

   Alteracoes: 30/06/2004 - Incluidos os novos tipos de vinculos (Evandro).

               22/03/2007 - Incluido comite cooperativa (Magui).
               
               15/10/2008 - Incluido tratamento na quebra de pagina (Diego).
               
............................................................................. */

IF   NOT aux_comcredi THEN
     DO:
     
         IF   crapass.tpvincul = "CA" THEN
              ASSIGN aux_desvincu = "CONSELHO DE ADMINISTRACAO".
         ELSE
              IF   crapass.tpvincul = "CC"  THEN
                   ASSIGN aux_desvincu = "CONSELHO DA CENTRAL".
              ELSE
                   IF   crapass.tpvincul = "CF"  THEN
                        ASSIGN aux_desvincu = "CONSELHO FISCAL".
                   ELSE
                    IF  crapass.tpvincul = "CO"     THEN
                        ASSIGN aux_desvincu = "COMITE COOPERATIVA".
                    ELSE    
                        IF   crapass.tpvincul = "ET"  THEN
                             ASSIGN aux_desvincu = "ESTAGIARIO TERCEIRO".
                        ELSE
                             IF  crapass.tpvincul = "FC"  THEN
                                 ASSIGN aux_desvincu = "FUNCIONARIO DA CENTRAL".
                             ELSE
                                 IF   crapass.tpvincul = "FO" THEN
                                      ASSIGN aux_desvincu =
                                          "FUNCIONARIO DE OUTRAS COOP".
                                 ELSE
                                      ASSIGN aux_desvincu = 
                                                  "FUNCIONARIO DA COOPERATIVA".
                           
         IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1) - 6  THEN
              PAGE STREAM str_1.
         
         DISPLAY STREAM str_1 
                 crapass.nrdconta crapass.nmprimtl aux_desvincu
                 WITH FRAME  f_crapass.
         DOWN STREAM str_1 WITH FRAME f_crapass.
         
         IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
              PAGE STREAM str_1.

         ASSIGN aux_comcredi = yes
                aux_temcredi = yes.
     
     END.    
/* .......................................................................... */
