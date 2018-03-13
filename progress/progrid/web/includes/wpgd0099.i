/* ...................................................................................
Include: wpgd0099.i
Objetivo: Criar um vetor de PACs, contendo código da cooperativa, código do PAC e
          nome abreviado do PAC, para que seja usado no arquivo HTML.
          Esta include agrupa os PACs

Alterações: Agnaldo - 01/12/2005 - Acrecentado o parameto &tipo, Se &tipo = combo-box,
                                   gera a lista no formato list-item-pair do Progress

            Rafael  - 14/12/2005 - Inclusão de argumentos para diferenciar listagem
                                   que não contem ano da agenda                       
................................................................................... */

/* "99" para nao conflitar com outros fontes */
DEF VAR par_cdcooper99 AS INT             NO-UNDO.
DEF VAR aux_nmresage   AS CHAR            NO-UNDO.

DEF BUFFER crabage FOR crapage.
DEF BUFFER crabagp FOR crapagp.

IF   AVAILABLE gnapses   THEN
     DO:
         IF   INT(GET-VALUE("aux_cdcooper")) <> 0   THEN
              par_cdcooper99 = INT(GET-VALUE("aux_cdcooper")).
         ELSE
              par_cdcooper99 = gnapses.cdcooper.

         /* Visão somente do pac do usuário */
         IF   gnapses.nvoperad = 1   OR
              gnapses.nvoperad = 2   THEN
              DO:
                 FIND crapagp WHERE crapagp.idevento = 1 /* PROGRID */    AND
                                    crapagp.cdcooper = par_cdcooper99     AND
                                    crapagp.dtanoage = INT({1})           AND
                                    crapagp.cdagenci = gnapses.cdagenci
                                    NO-LOCK NO-ERROR.

                 IF   AVAILABLE crapagp   THEN
                      DO:
                          aux_nmresage = "".

                          /* Verifica agrupamentos */

                          /* Se é PAC agrupador */
                          IF   crapagp.cdagenci = crapagp.cdageagr   THEN
                               FOR EACH  crabagp WHERE crabagp.idevento = crapagp.idevento   AND
                                                       crabagp.cdcooper = crapagp.cdcooper   AND
                                                       crabagp.dtanoage = crapagp.dtanoage   AND
                                                       crabagp.cdageagr = crapagp.cdagenci   NO-LOCK,
                                   FIRST crapage WHERE crapage.cdcooper = crabagp.cdcooper   AND
                                                       crapage.cdagenci = crabagp.cdagenci   NO-LOCK
                                                       BY crapage.nmresage:

                                   /* PAC agrupador vai na frente dos demais */
                                   IF   crabagp.cdagenci = crabagp.cdageagr   THEN
                                        aux_nmresage = crapage.nmresage + "/" + aux_nmresage.
                                   ELSE
                                        aux_nmresage = aux_nmresage + crapage.nmresage + "/".
                               END.
                          ELSE
                          /* PAC agrupado */
                               FOR EACH  crabagp WHERE crabagp.idevento = crapagp.idevento   AND
                                                       crabagp.cdcooper = crapagp.cdcooper   AND
                                                       crabagp.dtanoage = crapagp.dtanoage   AND
                                                       crabagp.cdageagr = crapagp.cdageagr   NO-LOCK,
                                   FIRST crapage WHERE crapage.cdcooper = crabagp.cdcooper   AND
                                                       crapage.cdagenci = crabagp.cdagenci   NO-LOCK
                                                       BY crapage.nmresage:

                                   /* PAC agrupador vai na frente dos demais */
                                   IF   crabagp.cdagenci = crabagp.cdageagr   THEN
                                        aux_nmresage = crapage.nmresage + "/" + aux_nmresage.
                                   ELSE
                                        aux_nmresage = aux_nmresage + crapage.nmresage + "/".
                               END.
                          
                          /* Tira a ultima barra */
                          aux_nmresage = SUBSTRING(aux_nmresage,1,LENGTH(aux_nmresage) - 1).
                          
                          vetorpac = "~{" + "cdcooper:"    + "'" + TRIM(STRING(crapagp.cdcooper))
                                          + "',cdagenci:"  + "'" + TRIM(STRING(crapagp.cdageagr))
                                          + "',nmresage:"  + "'" + STRING(aux_nmresage) + "'~}".
                      END.
              END.
         ELSE
         /* Visão de todos os PACs */
         FOR EACH  crapagp WHERE crapagp.idevento = 1 /* PROGRID */    AND
                                 crapagp.cdcooper = par_cdcooper99     AND
                                 crapagp.dtanoage = INT({1})           NO-LOCK,
             FIRST crapage WHERE crapage.cdcooper = crapagp.cdcooper   AND
                                 crapage.cdagenci = crapagp.cdagenci   NO-LOCK
                                 BY crapage.nmresage:

             /* Verifica agrupamentos */
             aux_nmresage = "".
             FOR EACH  crabagp WHERE crabagp.idevento = crapagp.idevento   AND
                                     crabagp.cdcooper = crapagp.cdcooper   AND
                                     crabagp.dtanoage = crapagp.dtanoage   AND
                                     crabagp.cdageagr = crapagp.cdagenci   NO-LOCK,
                 FIRST crabage WHERE crabage.cdcooper = crabagp.cdcooper   AND
                                     crabage.cdagenci = crabagp.cdagenci   NO-LOCK
                                     BY crabage.nmresage:

                 /* PAC agrupador vai na frente dos demais */
                 IF   crabagp.cdagenci = crabagp.cdageagr   THEN
                      aux_nmresage = crapage.nmresage + "/" + aux_nmresage.
                 ELSE
                      aux_nmresage = aux_nmresage + crabage.nmresage + "/".
             END.
                          
             /* Tira a ultima barra */
             aux_nmresage = SUBSTRING(aux_nmresage,1,LENGTH(aux_nmresage) - 1).

             /* Se o nome do PAC estiver em branco é porque ja foi agrupado anteriormente */
             IF   aux_nmresage = ""   THEN
                  NEXT.

             IF   vetorpac = ""   THEN
                  vetorpac = "~{" + "cdcooper:"    + "'" + TRIM(STRING(crapagp.cdcooper))
                                  + "',cdagenci:"  + "'" + TRIM(STRING(crapagp.cdageagr))
                                  + "',nmresage:"  + "'" + STRING(aux_nmresage) + "'~}".
             ELSE
                  vetorpac = vetorpac + "," + 
                             "~{" + "cdcooper:"    + "'" + TRIM(STRING(crapagp.cdcooper))
                                  + "',cdagenci:"  + "'" + TRIM(STRING(crapagp.cdageagr))
                                  + "',nmresage:"  + "'" + STRING(aux_nmresage) + "'~}".
         END.
     END.

