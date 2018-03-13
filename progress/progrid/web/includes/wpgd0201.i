/* ..............................................................................
Include: wpgd0201.i
Objetivo: Criar um vetor de PACs, código do PAC e nome abreviado do PAC, 
          para que seja usado no arquivo HTML. Nesta include os PACs 
          não são agrupados. (Lombardi)
          
  Alterações: 01/07/2016 - Ajuste não trazer a opção 'Selecione o PA'  quando 
                           não for super usuário (Vanessa).

              02/08/2016 - Inclusao insitage 3-Temporariamente Indisponivel.
                           (Jaison/Anderson)

  ............................................................................ */

/* "201" para nao conflitar com outros fontes */
DEF VAR par_cdcooper97 AS INT             NO-UNDO.

IF   AVAILABLE gnapses   THEN
     DO:
         IF   INT(GET-VALUE("aux_cdcooper")) <> 0   THEN
              par_cdcooper97 = INT(GET-VALUE("aux_cdcooper")).
         ELSE
              par_cdcooper97 = gnapses.cdcooper.

         /* Operador que vizualiza todos os PAC */
         IF   gnapses.nvoperad = 0   OR
              gnapses.nvoperad = 3   THEN
              FOR EACH crapage WHERE crapage.cdcooper = par_cdcooper97   AND
                                    (crapage.insitage = 1  OR       /* Ativo */
                                     crapage.insitage = 3) NO-LOCK  /* Temporariamente Indisponivel */
                                     BY crapage.nmresage:

                  /* Despreza PAC 90-INTERNET e PAC 91-TAA */
                  IF   crapage.cdagenci = 90   OR
                       crapage.cdagenci = 91   THEN
                       NEXT.
     
                  aux_cdagenci = aux_cdagenci + "," + crapage.nmresage + "," + TRIM(STRING(crapage.cdagenci)).
                  
              END. /* for each */
         ELSE
              DO:
                  aux_cdagenci = "--Selecione PA--,0".
                  
                  FIND crapage WHERE crapage.cdcooper = par_cdcooper97     AND
                                     crapage.cdagenci = gnapses.cdagenci   AND
                                    (crapage.insitage = 1  OR  /* Ativo */
                                     crapage.insitage = 3)     /* Temporariamente Indisponivel */
                                     NO-LOCK NO-ERROR.
                  IF   AVAILABLE crapage   THEN
                       aux_cdagenci = aux_cdagenci + "," + crapage.nmresage + "," + TRIM(STRING(crapage.cdagenci)).
                  ELSE
                       aux_cdagenci = "".
              END.
     END.
ELSE
     aux_cdagenci = "".
