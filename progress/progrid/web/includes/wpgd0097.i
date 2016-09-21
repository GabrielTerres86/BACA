/* ..............................................................................
Include: wpgd0097.i
Objetivo: Criar um vetor de PACs, contendo c�digo da cooperativa, c�digo do PAC e
          nome abreviado do PAC, para que seja usado no arquivo HTML.
          Nesta include os PACs n�o s�o agrupados
          
          14/06/2010 - Tratamento para PAC 91 - TAA (Elton).
          
.............................................................................. */

/* "97" para nao conflitar com outros fontes */
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
                                     crapage.insitage = 1 /* Ativo */    NO-LOCK
                                     BY crapage.nmresage:

                  /* Despreza PAC 90-INTERNET e PAC 91-TAA */
                  IF   crapage.cdagenci = 90   OR
                       crapage.cdagenci = 91   THEN
                       NEXT.
     
                  IF   vetorpac = ""   THEN
                       vetorpac = "~{" + "cdcooper:"   + "'" + TRIM(STRING(crapage.cdcooper))
                                       + "',cdagenci:" + "'" + TRIM(STRING(crapage.cdagenci))
                                       + "',nmresage:" + "'" + crapage.nmresage + "'~}".
                  ELSE
                       vetorpac = vetorpac + "," + 
                                  "~{" + "cdcooper:"   + "'" + TRIM(string(crapage.cdcooper)) 
                                       + "',cdagenci:" + "'" + TRIM(string(crapage.cdagenci))
                                       + "',nmresage:" + "'" + crapage.nmresage + "'~}".
              END. /* for each */
         ELSE
              DO:
                  FIND crapage WHERE crapage.cdcooper = par_cdcooper97     AND
                                     crapage.cdagenci = gnapses.cdagenci   AND
                                     crapage.insitage = 1 /* Ativo */                    
                                     NO-LOCK NO-ERROR.
                  IF   AVAILABLE crapage   THEN
                       vetorpac = "~{" + "cdcooper:"   + "'" + TRIM(STRING(crapage.cdcooper))
                                       + "',cdagenci:" + "'" + TRIM(STRING(crapage.cdagenci))
                                       + "',nmresage:" + "'" + crapage.nmresage + "'~}".
                  ELSE
                       vetorpac = "".
              END.
     END.
ELSE
     vetorpac = "".
