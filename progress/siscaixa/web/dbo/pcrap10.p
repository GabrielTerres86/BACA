/*--------------------------------------------------------------------------
pcrap10.p - Rotina criar reg. de devolucao/taxa de cheques.               
Objetivo  : Rotina criar reg. de devolucao/taxa de cheque.              
            (Antigo fontes/geradev.p)                                   
                                                                        
Alteracoes: 02/03/2006 - Unificacao dos Bancos - SQLWorks - Fernando    
                                                                        
            27/02/2007 - Alimentar os campos "cdbanchq", "cdagechq" e   
                         "nrctachq" na crapdev (Evandro).               
                                                                        
            20/03/2013 - Incluir tratamento para o par_cdalinea seguir  
                         o mesmo padrao do programa geradev.p (Lucas R.)
                         
            13/08/2013 - Exclusao da alinea 29. (Fabricio)
            
            17/12/2013 - Adicionado validate para tabela crapdev (Tiago).
            
            23/12/2015 - Ajustar validacoes de alinea, conforme revisao de 
                         alineas e processo de devolucao de cheque 
                         (Douglas - Melhoria 100)
----------------------------------------------------------------------------*/

DEF INPUT  PARAM p-cooper     AS CHAR                                NO-UNDO.
DEF INPUT  PARAM par_dtmvtolt AS DATE                                NO-UNDO.
DEF INPUT  PARAM par_cdbccxlt AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_inchqdev AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_nrdconta AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_nrcheque AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_nrdctabb AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_vllanmto AS DECIMAL                             NO-UNDO.
DEF INPUT  PARAM par_cdalinea AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_cdhistor AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_cdoperad AS CHAR                                NO-UNDO.
DEF INPUT  PARAM par_cdbanchq AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_cdagechq AS INT                                 NO-UNDO.
DEF OUTPUT PARAM par_cdcritic AS INT                                 NO-UNDO.

DEF BUFFER crabdev FOR crapdev.

par_cdcritic = 0.

FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.

IF   par_inchqdev = 1   THEN  /* cheque normal */
     DO:
         IF   CAN-FIND(crapdev WHERE crapdev.cdcooper = crapcop.cdcooper  AND
                                     crapdev.dtmvtolt = par_dtmvtolt      AND
                                     crapdev.nrdconta = par_nrdconta      AND
                                     crapdev.nrdctabb = par_nrdctabb      AND
                                     crapdev.nrcheque = par_nrcheque      AND
                                     crapdev.cdhistor = 46)               OR
              CAN-FIND(crapdev WHERE crapdev.cdcooper = crapcop.cdcooper  AND
                                     crapdev.dtmvtolt = par_dtmvtolt      AND
                                     crapdev.nrdconta = par_nrdconta      AND
                                     crapdev.nrdctabb = par_nrdctabb      AND
                                     crapdev.nrcheque = par_nrcheque      AND
                                     crapdev.cdhistor = par_cdhistor)     THEN
              DO:
                  par_cdcritic = 415.
                  RETURN.
              END.

        IF   (par_cdalinea >= 40 AND par_cdalinea < 45) OR
             (par_cdalinea >  45 AND par_cdalinea < 50) OR
             (par_cdalinea = 20)                        OR
             (par_cdalinea = 25)                        OR
             (par_cdalinea = 26)                        OR
             (par_cdalinea = 27)                        OR
             (par_cdalinea = 28)                        OR
             (par_cdalinea = 30)                        OR
             (par_cdalinea = 32)                        OR
             (par_cdalinea = 33)                        OR
             (par_cdalinea = 34)                        OR
             (par_cdalinea = 35)                        OR
             (par_cdalinea = 37)                        OR
             (par_cdalinea = 38)                        OR
             (par_cdalinea = 39)                        OR
             (par_cdalinea = 59)                        OR
             (par_cdalinea = 61)                        OR
             (par_cdalinea = 64)                        OR
             (par_cdalinea = 71)                        OR
             (par_cdalinea = 72)                        THEN
              .
         ELSE
              DO:
                  CREATE crapdev.
                  ASSIGN crapdev.cdcooper = crapcop.cdcooper
                         crapdev.dtmvtolt = par_dtmvtolt
                         crapdev.cdbccxlt = par_cdbccxlt
                         crapdev.nrdconta = par_nrdconta
                         crapdev.nrdctabb = par_nrdctabb
                         crapdev.nrcheque = par_nrcheque
                         crapdev.vllanmto = par_vllanmto
                         crapdev.cdalinea = par_cdalinea
                         crapdev.cdoperad = par_cdoperad
                         crapdev.cdhistor = 46
                         crapdev.insitdev = 0
                         crapdev.cdbanchq = par_cdbanchq
                         crapdev.cdagechq = par_cdagechq
                         crapdev.nrctachq = par_nrdctabb.
                  VALIDATE crapdev.
              END.

         CREATE crapdev.
         ASSIGN crapdev.cdcooper = crapcop.cdcooper
                crapdev.dtmvtolt = par_dtmvtolt
                crapdev.cdbccxlt = par_cdbccxlt
                crapdev.nrdconta = par_nrdconta
                crapdev.nrdctabb = par_nrdctabb
                crapdev.nrcheque = par_nrcheque
                crapdev.vllanmto = par_vllanmto
                crapdev.cdalinea = par_cdalinea
                crapdev.cdoperad = par_cdoperad
                crapdev.cdhistor = par_cdhistor
                crapdev.insitdev = 0
                crapdev.cdbanchq = par_cdbanchq
                crapdev.cdagechq = par_cdagechq
                crapdev.nrctachq = par_nrdctabb.
         VALIDATE crapdev.
     END.
ELSE
IF   par_inchqdev = 2   OR
     par_inchqdev = 4   THEN   
     DO:
         IF   CAN-FIND(crapdev WHERE crapdev.cdcooper = crapcop.cdcooper  AND
                                     crapdev.dtmvtolt = par_dtmvtolt      AND
                                     crapdev.nrdconta = par_nrdconta      AND
                                     crapdev.nrdctabb = par_nrdctabb      AND
                                     crapdev.nrcheque = par_nrcheque      AND
                                     crapdev.cdhistor = 46)               THEN
              DO:
                  par_cdcritic = 415.
                  RETURN.
              END.

         IF   (par_cdalinea >= 40 AND par_cdalinea < 45) OR
              (par_cdalinea >  45 AND par_cdalinea < 50) OR
              (par_cdalinea = 20)                        OR
              (par_cdalinea = 25)                        OR
              (par_cdalinea = 26)                        OR
              (par_cdalinea = 27)                        OR
              (par_cdalinea = 28)                        OR
              (par_cdalinea = 30)                        OR
              (par_cdalinea = 32)                        OR
              (par_cdalinea = 33)                        OR
              (par_cdalinea = 34)                        OR
              (par_cdalinea = 35)                        OR
              (par_cdalinea = 37)                        OR
              (par_cdalinea = 38)                        OR
              (par_cdalinea = 39)                        OR
              (par_cdalinea = 59)                        OR
              (par_cdalinea = 61)                        OR
              (par_cdalinea = 64)                        OR
              (par_cdalinea = 71)                        OR
              (par_cdalinea = 72)                        THEN
                .
         ELSE
              DO:
                  CREATE crapdev.
                  ASSIGN crapdev.cdcooper = crapcop.cdcooper
                         crapdev.dtmvtolt = par_dtmvtolt
                         crapdev.cdbccxlt = par_cdbccxlt
                         crapdev.nrdconta = par_nrdconta
                         crapdev.nrdctabb = par_nrdctabb
                         crapdev.nrcheque = par_nrcheque
                         crapdev.vllanmto = par_vllanmto
                         crapdev.cdalinea = par_cdalinea
                         crapdev.cdoperad = par_cdoperad
                         crapdev.cdhistor = 46
                         crapdev.insitdev = 0
                         crapdev.cdbanchq = par_cdbanchq
                         crapdev.cdagechq = par_cdagechq
                         crapdev.nrctachq = par_nrdctabb.
                  VALIDATE crapdev.
              END.
     END.
ELSE
IF   par_inchqdev = 3   THEN     /* Transferencia */
     DO:
         IF   CAN-FIND(crapdev WHERE crapdev.cdcooper = crapcop.cdcooper  AND
                                     crapdev.dtmvtolt = par_dtmvtolt      AND
                                     crapdev.nrdconta = par_nrdconta      AND
                                     crapdev.nrdctabb = par_nrdctabb      AND
                                     crapdev.nrcheque = par_nrcheque      AND
                                     crapdev.cdhistor = 46)               OR   
              CAN-FIND(crapdev WHERE crapdev.cdcooper = crapcop.cdcooper  AND
                                     crapdev.dtmvtolt = par_dtmvtolt      AND
                                     crapdev.nrdconta = par_nrdconta      AND
                                     crapdev.nrdctabb = par_nrdctabb      AND
                                     crapdev.nrcheque = par_nrcheque      AND
                                     crapdev.cdhistor = par_cdhistor /*78*/ ) 
                                     THEN
              DO:
                  par_cdcritic = 415.
                  RETURN.
              END.

         IF   (par_cdalinea >= 40 AND par_cdalinea < 45) OR
              (par_cdalinea >  45 AND par_cdalinea < 50) OR
              (par_cdalinea = 20)                        OR
              (par_cdalinea = 25)                        OR
              (par_cdalinea = 26)                        OR
              (par_cdalinea = 27)                        OR
              (par_cdalinea = 28)                        OR
              (par_cdalinea = 30)                        OR
              (par_cdalinea = 32)                        OR
              (par_cdalinea = 33)                        OR
              (par_cdalinea = 34)                        OR
              (par_cdalinea = 35)                        OR
              (par_cdalinea = 37)                        OR
              (par_cdalinea = 38)                        OR
              (par_cdalinea = 39)                        OR
              (par_cdalinea = 59)                        OR
              (par_cdalinea = 61)                        OR
              (par_cdalinea = 64)                        OR
              (par_cdalinea = 71)                        OR
              (par_cdalinea = 72)                        THEN
              .
         ELSE
              DO:
                  CREATE crapdev.
                  ASSIGN crapdev.cdcooper = crapcop.cdcooper
                         crapdev.dtmvtolt = par_dtmvtolt
                         crapdev.cdbccxlt = par_cdbccxlt
                         crapdev.nrdconta = par_nrdconta
                         crapdev.nrdctabb = par_nrdctabb
                         crapdev.nrcheque = par_nrcheque
                         crapdev.vllanmto = par_vllanmto
                         crapdev.cdalinea = par_cdalinea
                         crapdev.cdoperad = par_cdoperad
                         crapdev.cdhistor = 46
                         crapdev.insitdev = 0
                         crapdev.cdbanchq = par_cdbanchq
                         crapdev.cdagechq = par_cdagechq
                         crapdev.nrctachq = par_nrdctabb.
                  VALIDATE crapdev.
              END.

         CREATE crapdev.
         ASSIGN crapdev.cdcooper = crapcop.cdcooper
                crapdev.dtmvtolt = par_dtmvtolt
                crapdev.cdbccxlt = par_cdbccxlt
                crapdev.nrdconta = par_nrdconta
                crapdev.nrdctabb = par_nrdctabb
                crapdev.nrcheque = par_nrcheque
                crapdev.vllanmto = par_vllanmto
                crapdev.cdalinea = par_cdalinea
                crapdev.cdoperad = par_cdoperad
                crapdev.cdhistor = par_cdhistor /* 78 */
                crapdev.insitdev = 0
                crapdev.cdbanchq = par_cdbanchq
                crapdev.cdagechq = par_cdagechq
                crapdev.nrctachq = par_nrdctabb.
         VALIDATE crapdev.
                
     END.
ELSE
IF   par_inchqdev = 5   THEN
     DO WHILE TRUE:

        FIND crabdev WHERE crabdev.cdcooper = crapcop.cdcooper  AND 
                           crabdev.dtmvtolt = par_dtmvtolt      AND
                           crabdev.nrdconta = par_nrdconta      AND
                           crabdev.nrdctabb = par_nrdctabb      AND
                           crabdev.nrcheque = par_nrcheque      AND
                           crabdev.cdhistor = par_cdhistor /* 47  191 */
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF   NOT AVAILABLE crabdev   THEN
             IF   LOCKED crabdev   THEN
                  DO:
                      PAUSE 2 NO-MESSAGE.
                      NEXT.
                  END.
             ELSE
                  DO:
                      par_cdcritic = 416.
                      RETURN.
                  END.

       IF   (crabdev.cdalinea >= 40 AND crabdev.cdalinea < 45) OR
            (crabdev.cdalinea >  45 AND crabdev.cdalinea < 50) OR
            (crabdev.cdalinea = 20)                        OR
            (crabdev.cdalinea = 25)                        OR
            (crabdev.cdalinea = 26)                        OR
            (crabdev.cdalinea = 27)                        OR
            (crabdev.cdalinea = 28)                        OR
            (crabdev.cdalinea = 30)                        OR
            (crabdev.cdalinea = 32)                        OR
            (crabdev.cdalinea = 33)                        OR
            (crabdev.cdalinea = 34)                        OR
            (crabdev.cdalinea = 35)                        OR
            (crabdev.cdalinea = 37)                        OR
            (crabdev.cdalinea = 38)                        OR
            (crabdev.cdalinea = 39)                        OR
            (crabdev.cdalinea = 59)                        OR
            (crabdev.cdalinea = 61)                        OR
            (crabdev.cdalinea = 64)                        OR
            (crabdev.cdalinea = 71)                        OR
            (crabdev.cdalinea = 72)                        THEN
            .
       ELSE
             DO:
                 FIND crapdev WHERE crapdev.cdcooper = crapcop.cdcooper  AND
                                    crapdev.dtmvtolt = par_dtmvtolt      AND
                                    crapdev.nrdconta = par_nrdconta      AND
                                    crapdev.nrdctabb = par_nrdctabb      AND
                                    crapdev.nrcheque = par_nrcheque      AND
                                    crapdev.cdhistor = 46
                                    EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                 IF   NOT AVAILABLE crapdev   THEN
                      IF   LOCKED crapdev   THEN
                           DO:
                               PAUSE 2 NO-MESSAGE.
                               NEXT.
                           END.
                      ELSE
                           DO:
                               par_cdcritic = 416.
                               RETURN.
                           END.

                 DELETE crapdev.

             END.

        DELETE crabdev.

        LEAVE.

     END.  /*  Fim do DO WHILE TRUE  */
ELSE
IF   par_inchqdev = 6   OR
     par_inchqdev = 8   THEN
     DO WHILE TRUE:

        FIND crabdev WHERE crabdev.cdcooper = crapcop.cdcooper  AND
                           crabdev.dtmvtolt = par_dtmvtolt      AND
                           crabdev.nrdconta = par_nrdconta      AND
                           crabdev.nrdctabb = par_nrdctabb      AND
                           crabdev.nrcheque = par_nrcheque      AND
                           crabdev.cdhistor = par_cdhistor /* 47  191 */
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF   NOT AVAILABLE crabdev   THEN
             IF   LOCKED crabdev   THEN
                  DO:
                      PAUSE 2 NO-MESSAGE.
                      NEXT.
                  END.
             ELSE
                  DO:
                      par_cdcritic = 416.
                      RETURN.
                  END.

        IF   (crabdev.cdalinea >= 40 AND crabdev.cdalinea < 45) OR
             (crabdev.cdalinea >  45 AND crabdev.cdalinea < 50) OR
             (crabdev.cdalinea = 20)                        OR
             (crabdev.cdalinea = 25)                        OR
             (crabdev.cdalinea = 26)                        OR
             (crabdev.cdalinea = 27)                        OR
             (crabdev.cdalinea = 28)                        OR
             (crabdev.cdalinea = 30)                        OR
             (crabdev.cdalinea = 32)                        OR
             (crabdev.cdalinea = 33)                        OR
             (crabdev.cdalinea = 34)                        OR
             (crabdev.cdalinea = 35)                        OR
             (crabdev.cdalinea = 37)                        OR
             (crabdev.cdalinea = 38)                        OR
             (crabdev.cdalinea = 39)                        OR
             (crabdev.cdalinea = 59)                        OR
             (crabdev.cdalinea = 61)                        OR
             (crabdev.cdalinea = 64)                        OR
             (crabdev.cdalinea = 71)                        OR
             (crabdev.cdalinea = 72)                        THEN
             .
        ELSE
             DO:
                 FIND crapdev WHERE crapdev.cdcooper = crapcop.cdcooper  AND
                                    crapdev.dtmvtolt = par_dtmvtolt      AND
                                    crapdev.nrdconta = par_nrdconta      AND
                                    crapdev.nrdctabb = par_nrdctabb      AND
                                    crapdev.nrcheque = par_nrcheque      AND
                                    crapdev.cdhistor = 46
                                    EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                 IF   NOT AVAILABLE crapdev   THEN
                      IF   LOCKED crapdev   THEN
                           DO:
                              PAUSE 2 NO-MESSAGE.
                              NEXT.
                           END.
                      ELSE
                           DO:
                               par_cdcritic = 416.
                               RETURN.
                           END.

                 DELETE crapdev.
             END.

        DELETE crabdev.

        LEAVE.

     END.  /*  Fim do DO WHILE TRUE  */
ELSE
IF   par_inchqdev = 7   THEN
     DO WHILE TRUE:

        FIND crabdev WHERE crabdev.cdcooper = crapcop.cdcooper  AND
                           crabdev.dtmvtolt = par_dtmvtolt      AND
                           crabdev.nrdconta = par_nrdconta      AND
                           crabdev.nrdctabb = par_nrdctabb      AND
                           crabdev.nrcheque = par_nrcheque      AND
                           crabdev.cdhistor = par_cdhistor /* 47  191 */
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF   NOT AVAILABLE crabdev   THEN
             IF   LOCKED crabdev   THEN
                  DO:
                      PAUSE 2 NO-MESSAGE.
                      NEXT.
                  END.
             ELSE
                  DO:
                      par_cdcritic = 416.
                      RETURN.
                  END.

        IF   (crabdev.cdalinea >= 40 AND crabdev.cdalinea < 45) OR
             (crabdev.cdalinea >  45 AND crabdev.cdalinea < 50) OR
             (crabdev.cdalinea = 20)                        OR
             (crabdev.cdalinea = 25)                        OR
             (crabdev.cdalinea = 26)                        OR
             (crabdev.cdalinea = 27)                        OR
             (crabdev.cdalinea = 28)                        OR
             (crabdev.cdalinea = 30)                        OR
             (crabdev.cdalinea = 32)                        OR
             (crabdev.cdalinea = 33)                        OR
             (crabdev.cdalinea = 34)                        OR
             (crabdev.cdalinea = 35)                        OR
             (crabdev.cdalinea = 37)                        OR
             (crabdev.cdalinea = 38)                        OR
             (crabdev.cdalinea = 39)                        OR
             (crabdev.cdalinea = 59)                        OR
             (crabdev.cdalinea = 61)                        OR
             (crabdev.cdalinea = 64)                        OR
             (crabdev.cdalinea = 71)                        OR
             (crabdev.cdalinea = 72)                        THEN
            .
        ELSE
             DO:
                 FIND crapdev WHERE crapdev.cdcooper = crapcop.cdcooper  AND
                                    crapdev.dtmvtolt = par_dtmvtolt      AND
                                    crapdev.nrdconta = par_nrdconta      AND
                                    crapdev.nrdctabb = par_nrdctabb      AND
                                    crapdev.nrcheque = par_nrcheque      AND
                                    crapdev.cdhistor = 46
                                    EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                 IF   NOT AVAILABLE crapdev   THEN
                      IF   LOCKED crapdev   THEN
                           DO:
                               PAUSE 2 NO-MESSAGE.
                               NEXT.
                           END.
                      ELSE
                           DO:
                               par_cdcritic = 416.
                               RETURN.
                           END.

                 DELETE crapdev.

             END.

        DELETE crabdev.

        LEAVE.

     END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */