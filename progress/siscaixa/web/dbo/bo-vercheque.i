/*-----------------------------------------------------------------------------

    Arquivo           : bo-vercheque.i 
    
    Ultima Atualizacao: 17/12/2018
        
    Alteracoes:
                23/02/2006 - Unificacao dos bancos - SQLWorks - Eder
                
                16/02/2007 - Alteracao dos FINDs na crapfdc, crapcor (Evandro).

                22/12/2008 - Ajustes para unificacao dos bancos de dados
                             (Evandro).
                
                03/09/2009 - Incluido critica para sistema nao aceitar cheques
                             TB e cheques salario (Elton).
                             
                07/10/2009 - Adaptacoes projeto IF CECRED (Guilherme).
                
                24/11/2010 - Acerto na verificacao de cheque da cooperativa 
                            (Elton).
                
                09/09/2014 - #198254 Incorporacao concredi e credimilsul (Carlos)

                06/12/2016 - Incorporacao Transulcred (Guilherme/SUPERO)

                17/12/2018 - Alterada critica generica 999 por 95 na procedure ver_associado
                             INC0029153 (Tiago)
------------------------------------------------------------------------------*/

PROCEDURE ver_cheque:
    
    DEF BUFFER b-crapcop FOR crapcop.

    ASSIGN i-codigo-erro = 0
           aux_nrctcomp  = 0
           aux_nrctachq  = 0
           aux_nritgchq  = "" 
           aux_nrtalchq  = 0
           aux_tpcheque  = 0
           aux_nrdocchq  = INT(STRING(i-p-nro-cheque,"999999") +
                           STRING(i-p-nrddigc3,"9")).
 
    IF   (i-p-cdbanchq = 1                          AND
          CAN-DO("95,3420", STRING(i-p-cdagechq)))  OR
         (i-p-cdbanchq = 104                        AND 
          i-p-cdagechq = 411)
          /** Conta Integracao **/
                                                    OR
                                                    
         (aux_nrdctitg <> ""                        AND
          CAN-DO("3420", STRING(i-p-cdagechq)))     THEN 
         DO:
             IF   CAN-FIND(crapass WHERE crapass.cdcooper = crapcop.cdcooper  AND
                                         crapass.nrdctitg = aux_nrdctitg) THEN
                  DO: 
                     IF   CAN-DO(aux_lsconta1,STRING(i-p-nrctabdb)) 
                          /** Conta Integracao **/
                          OR  (aux_nrdctitg <> "" AND 
                               CAN-DO("3420",STRING(i-p-cdagechq)))   THEN 
                          DO:
                              /* Formata conta integracao */
                              RUN fontes/digbbx.p (INPUT  INT(i-p-nrctabdb),
                                                   OUTPUT glb_dsdctitg,
                                                   OUTPUT glb_stsnrcal).
                          
                              ASSIGN i_nro-docto  = aux_nrdocchq.
        
                              RUN dbo/pcrap01.p(INPUT-OUTPUT i_nro-docto, /* Nro Chq */
                                                INPUT-OUTPUT i_nro-talao, /*Nro Talao*/
                                                INPUT-OUTPUT i_posicao,  /* Posicao */
                                                INPUT-OUTPUT i_nro-folhas). /*Nro Flhs*/
                             
                              FIND crapfdc WHERE crapfdc.cdcooper = crapcop.cdcooper AND
                                                 crapfdc.cdbanchq = i-p-cdbanchq     AND
                                                 crapfdc.cdagechq = i-p-cdagechq     AND
                                                 crapfdc.nrctachq = i-p-nrctabdb     AND
                                                 crapfdc.nrcheque = i-p-nro-cheque
                                                 USE-INDEX crapfdc1 NO-LOCK NO-ERROR.
                                                 
                              IF   NOT AVAIL crapfdc   THEN 
                                   DO:
                                       ASSIGN i-codigo-erro = 108.
                                       RETURN.
                                   END.
                 
                              ASSIGN aux_nrctcomp = crapfdc.nrdconta
                                     aux_nrctachq = crapfdc.nrdctabb
                                     aux_nritgchq = crapfdc.nrdctitg
                                     aux_tpcheque = crapfdc.tpcheque.
                                     /*aux_nrtalchq = crapfdc.nrtalchq.*/
                                
                              IF   crapfdc.dtemschq = ?   THEN 
                                   DO:
                                       ASSIGN i-codigo-erro = 108.
                                       RETURN.
                                   END.
                        
                              IF   crapfdc.dtretchq = ?   THEN 
                                   DO:
                                       ASSIGN i-codigo-erro = 109.
                                       RETURN.
                                   END.
                                           
                              IF   crapfdc.tpcheque = 2 OR   /** Cheque TB **/
                                   crapfdc.tpcheque = 3 THEN /** Cheque Salario **/
                                   DO:
                                       ASSIGN i-codigo-erro = 646.
                                       RETURN.
                                   END.
                                   
                              IF   crapfdc.incheque <> 0   THEN 
                                   DO:
                                       IF   crapfdc.incheque = 1   THEN
                                            ASSIGN i-codigo-erro = 96.
                                       ELSE
                                            IF   crapfdc.incheque = 2   THEN
                                                 RUN conta_ordem (crapfdc.incheque).
                                            ELSE
                                                 IF   crapfdc.incheque = 5   THEN
                                                      ASSIGN i-codigo-erro = 97.
                                                 ELSE
                                                      IF   crapfdc.incheque = 8   THEN
                                                           ASSIGN i-codigo-erro = 320.
                                                      ELSE
                                                           ASSIGN i-codigo-erro = 100.
                                       RETURN.
                                   END.
                          END.
                  END. 
             ELSE
                  IF   CAN-DO(aux_lsconta2,STRING(i-p-nrctabdb))   THEN 
                       DO:
                           ASSIGN  i-codigo-erro = 646.  /*  CHEQUE TB  */
                           RETURN.
                       END.
                  ELSE
                       IF   CAN-DO(aux_lsconta3,STRING(i-p-nrctabdb))   THEN 
                            DO:
                            
                                /* Formata conta integracao */
                                RUN fontes/digbbx.p (INPUT  INT(i-p-nrctabdb),
                                                     OUTPUT glb_dsdctitg,
                                                     OUTPUT glb_stsnrcal).
                            
                                FIND crapfdc WHERE 
                                     crapfdc.cdcooper = crapcop.cdcooper   AND
                                     crapfdc.cdbanchq = i-p-cdbanchq       AND
                                     crapfdc.cdagechq = i-p-cdagechq       AND
                                     crapfdc.nrctachq = i-p-nrctabdb       AND
                                     crapfdc.nrcheque = i-p-nro-cheque
                                     USE-INDEX crapfdc1 NO-LOCK NO-ERROR.

                                IF   NOT AVAILABLE crapfdc   THEN 
                                     DO:
                                         ASSIGN  i-codigo-erro = 286.
                                         RETURN.
                                     END.

                                IF  crapfdc.tpcheque = 2 OR   /** Cheque TB **/
                                    crapfdc.tpcheque = 3 THEN /* Chq.Salario */
                                    DO:
                                        ASSIGN i-codigo-erro = 646.
                                        RETURN.
                                    END.
                                
                                IF   crapfdc.vlcheque = i-p-valor   THEN 
                                     DO:
                                         ASSIGN aux_nrctcomp = crapfdc.nrdconta
                                                aux_nrctachq = crapfdc.nrdctabb
                                                aux_nritgchq = crapfdc.nrdctitg.
                                
                                         IF   crapfdc.incheque <> 0   THEN 
                                              DO:
                                                  IF   crapfdc.incheque = 1 THEN
                                                      ASSIGN i-codigo-erro = 96.
                                                  ELSE
                                                  IF   crapfdc.incheque = 2 THEN
                                                       RUN conta_ordem 
                                                            (crapfdc.incheque).
                                                  ELSE
                                                  IF   crapfdc.incheque = 5 THEN
                                                      ASSIGN i-codigo-erro = 97.
                                                  ELSE
                                                  IF   crapfdc.incheque = 8 THEN
                                                     ASSIGN i-codigo-erro = 320.
                                                  ELSE
                                                     ASSIGN i-codigo-erro = 100.
                             
                                                  RETURN.
                                              END.
                                     END.
                                ELSE 
                                     DO:
                                         ASSIGN i-codigo-erro = 91.
                                         RETURN. 
                                     END.
                            END.
                       ELSE 
                           RETURN. /* Qquer outra conta da agencia 95 /3420 */
                           
                           
                  RUN ver_associado.
                  
             IF   i-codigo-erro > 0   THEN
                  RETURN.
         END.
    ELSE
         IF  (i-p-cdbanchq = 756            AND  
              i-p-cdagechq = aux_cdagebcb)  /* BANCOOB */      
             OR 
             /* Incorporacao CONCREDI */
             (i-p-cdbanchq     = 756        AND
              i-p-cdagechq     = 4415       AND
              crapcop.cdcooper = 1)
             OR 
             /* Incorporacao CREDIMILSUL */
             (i-p-cdbanchq     = 756        AND
              i-p-cdagechq     = 114        AND
              crapcop.cdcooper = 13)
             OR
             (i-p-cdbanchq = crapcop.cdbcoctl  AND  
              i-p-cdagechq = crapcop.cdagectl) /* Banco da CENTRAL */  
             OR 
             /* Incorporacao CONCREDI */
             (i-p-cdbanchq     = crapcop.cdbcoctl AND
              i-p-cdagechq     = 0103             AND
              crapcop.cdcooper = 1)
             OR 
             /* Incorporacao CREDIMILSUL */
             (i-p-cdbanchq     = crapcop.cdbcoctl AND
              i-p-cdagechq     = 0114             AND
              crapcop.cdcooper = 13)
             OR
             /* Incorporacao TRANSULCRED */
             (i-p-cdbanchq     = crapcop.cdbcoctl AND
              i-p-cdagechq     = 0116             AND
              crapcop.cdcooper =  9               AND
			  TODAY > 12/30/2016) THEN DO:

                  IF   CAN-DO(aux_lsconta3,STRING(i-p-nrctabdb))   THEN 
                       DO:
                           /* Formata conta integracao */
                           RUN fontes/digbbx.p (INPUT  INT(i-p-nrctabdb),
                                                OUTPUT glb_dsdctitg,
                                                OUTPUT glb_stsnrcal).
                      
                           FIND crapfdc WHERE 
                                        crapfdc.cdcooper = crapcop.cdcooper AND
                                        crapfdc.cdbanchq = i-p-cdbanchq     AND
                                        crapfdc.cdagechq = i-p-cdagechq     AND
                                        crapfdc.nrctachq = i-p-nrctabdb     AND
                                        crapfdc.nrcheque = i-p-nro-cheque
                                        USE-INDEX crapfdc1 NO-LOCK NO-ERROR.

                           IF   NOT AVAIL crapfdc   THEN  
                                DO:
                                    ASSIGN  i-codigo-erro = 286.
                                    RETURN.
                                END.

                           IF   crapfdc.tpcheque = 2 OR   /** Cheque TB **/
                                crapfdc.tpcheque = 3 THEN /** Cheque Salario **/
                                DO:
                                    ASSIGN i-codigo-erro = 646.
                                    RETURN.
                                END.
                           
                           IF   crapfdc.vlcheque = i-p-valor   THEN 
                                DO:
                                    ASSIGN aux_nrctcomp = crapfdc.nrdconta
                                           aux_nrctachq = crapfdc.nrdctabb
                                           aux_nritgchq = crapfdc.nrdctitg.
                                     
                                     RUN ver_associado.
                           
                                     IF   i-codigo-erro > 0   THEN
                                          RETURN.
                   
                                     IF   crapfdc.incheque <> 0   THEN 
                                          DO:
                                              IF   crapfdc.incheque = 1   THEN
                                                   ASSIGN i-codigo-erro = 96.
                                              ELSE
                                              IF   crapfdc.incheque = 2   THEN
                                              RUN conta_ordem(crapfdc.incheque).
                                              ELSE
                                              IF   crapfdc.incheque = 5   THEN
                                                   ASSIGN i-codigo-erro = 97.
                                              ELSE
                                              IF  crapfdc.incheque = 8   THEN
                                                  ASSIGN i-codigo-erro = 320.
                                              ELSE
                                                  ASSIGN i-codigo-erro = 100.
                                    
                                              RETURN. 
                                          END.
                                END.
                           ELSE 
                                DO:
                                    ASSIGN  i-codigo-erro = 91.
                                    RETURN. 
                                END.
      
                       END.
                  ELSE  
                       DO:   
                           
                           ASSIGN aux_nrctcomp = /*INT(de-nrctachq)*/ 
                                                 i-p-nrctabdb.
                           
                           /********* Tratamento Incorporacao *******/
                           FIND FIRST b-crapcop WHERE b-crapcop.cdagectl = i-p-cdagechq OR
                                                      b-crapcop.cdagebcb = i-p-cdagechq
                                                      NO-LOCK NO-ERROR.
                           
                           IF  AVAIL b-crapcop THEN
                               DO:
                                    FIND FIRST craptco
                                         WHERE craptco.cdcooper = crapcop.cdcooper
                                           AND craptco.nrctaant = i-p-nrctabdb
                                           AND craptco.cdcopant = b-crapcop.cdcooper
                                           AND craptco.flgativo = TRUE
                                                       NO-LOCK NO-ERROR.
                                    
                                    IF  AVAIL craptco THEN
                                        aux_nrctcomp = craptco.nrdconta.
                               END.
                           /************************/
                           
                           ASSIGN i_nro-docto  = aux_nrdocchq.

                           RUN dbo/pcrap01.p(INPUT-OUTPUT i_nro-docto, 
                                             /* Nro Chq */
                                             INPUT-OUTPUT i_nro-talao, 
                                             /*Nro Talao*/
                                             INPUT-OUTPUT i_posicao, 
                                             /* Posicao */
                                             INPUT-OUTPUT i_nro-folhas). 
                                             /*Folhas*/
                           
                           RUN ver_associado.
                    
                           IF   i-codigo-erro > 0   THEN
                                RETURN.
                     
                           ASSIGN de-nrctachq = aux_nrctcomp.
             
                           /* Formata conta integracao */
                           RUN fontes/digbbx.p (INPUT  aux_nrctcomp,
                                                OUTPUT glb_dsdctitg,
                                                OUTPUT glb_stsnrcal).

                           FIND crapfdc WHERE 
                                        crapfdc.cdcooper = crapcop.cdcooper AND
                                        crapfdc.cdbanchq = i-p-cdbanchq     AND
                                        crapfdc.cdagechq = i-p-cdagechq     AND
                                        crapfdc.nrctachq = i-p-nrctabdb     AND
                                        crapfdc.nrcheque = i-p-nro-cheque
                                        USE-INDEX crapfdc1 NO-LOCK NO-ERROR.

                           IF   NOT AVAIL crapfdc   THEN 
                                DO:
                                    ASSIGN i-codigo-erro = 108.
                                    RETURN.
                                END.
                           
                           IF   crapfdc.tpcheque = 2 OR   /** Cheque TB **/
                                crapfdc.tpcheque = 3 THEN /** Cheque Salario **/
                                DO: 
                                    ASSIGN i-codigo-erro = 646.
                                    RETURN.
                                END.
                            
                           ASSIGN aux_nrctachq = crapfdc.nrdctabb
                                  /*aux_nrtalchq = crapfdc.nrtalchq*/
                                  aux_tpcheque = crapfdc.tpcheque
                                  aux_nritgchq = crapfdc.nrdctitg.
             
                           IF   crapfdc.dtemschq = ?   THEN 
                                DO:
                                    ASSIGN i-codigo-erro = 108.
                                    RETURN.
                                END.

                           IF   crapfdc.dtretchq = ?   THEN 
                                DO:
                                    ASSIGN i-codigo-erro = 109.
                                    RETURN.
                                END.
                         
                           IF   crapfdc.incheque <> 0   THEN 
                                DO:
                                    IF   crapfdc.incheque = 1   THEN
                                         ASSIGN i-codigo-erro = 96.
                                    ELSE
                                    IF   crapfdc.incheque = 2   THEN
                                         RUN conta_ordem(crapfdc.incheque).
                                    ELSE
                                    IF   crapfdc.incheque = 5   THEN
                                         ASSIGN  i-codigo-erro = 97.
                                    ELSE
                                    IF  crapfdc.incheque = 8 THEN
                                        ASSIGN  i-codigo-erro = 320.
                                    ELSE
                                        ASSIGN  i-codigo-erro = 100.
                                    RETURN.
                                END. 
                       END.
              END.
     ELSE 
         RETURN.            /*  Qualquer outro banco  */

END PROCEDURE.

PROCEDURE ver_associado.

    IF   aux_nrctcomp > 0   THEN
         DO   WHILE TRUE:
              
              FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper    AND
                                 crapass.nrdconta = aux_nrctcomp 
                                 NO-LOCK NO-ERROR NO-WAIT.
                        
              IF   NOT AVAIL crapass  THEN 
                   DO:  
                       ASSIGN  i-codigo-erro = 9.
                       RETURN.
                   END.
 
              IF   CAN-DO("5,6,7,8",STRING(crapass.cdsitdtl))  THEN 
                   DO:
                       ASSIGN  i-codigo-erro = 695.
                       RETURN.
                   END.

              IF   CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl))   THEN 
                   DO:
                       FIND FIRST craptrf WHERE
                                  craptrf.cdcooper = crapcop.cdcooper   AND
                                  craptrf.nrdconta = crapass.nrdconta   AND
                                  craptrf.tptransa = 1 
                                  USE-INDEX craptrf1 NO-LOCK NO-ERROR.
                                  
                       IF   NOT AVAIL craptrf   THEN  
                            DO:
                                ASSIGN  i-codigo-erro = 95. /*095 - Titular da conta bloqueado.*/
                                RETURN.
                            END.

                       /* Transferencia de Conta */
                       ASSIGN i-p-transferencia-conta = 
                              "Conta transferida do Numero  " +    
                              STRING(craptrf.nrdconta,"zzzz,zzz,9") + 
                              " para o numero " + 
                              STRING(craptrf.nrsconta,"zzzz,zzz,9").           
                              ASSIGN aux_nrctcomp = craptrf.nrsconta.
                  
                       NEXT.
                   END.

              IF   crapass.dtelimin <> ?   THEN  
                   DO:
                       ASSIGN   i-codigo-erro = 410.
                       RETURN.
                   END.
               LEAVE.

         END.  /*  Fim do DO WHILE TRUE  */

END PROCEDURE.

PROCEDURE conta_ordem:

    DEF INPUT PARAMETER par_incheque AS INT                  NO-UNDO.  
    
    IF   par_incheque = 1   OR
         par_incheque = 2   THEN 
         DO:
             FIND crapcor WHERE crapcor.cdcooper = crapcop.cdcooper   AND
                                crapcor.cdbanchq = i-p-cdbanchq       AND
                                crapcor.cdagechq = i-p-cdagechq       AND
                                crapcor.nrctachq = aux_nrctcomp       AND
                                crapcor.nrcheque = aux_nrdocchq
                                NO-LOCK NO-ERROR.
                                
             IF   NOT AVAIL crapcor   THEN 
                  DO:
                      ASSIGN   i-codigo-erro = 101.
                      RETURN.
                  END.

             FIND craphis WHERE craphis.cdcooper = crapcop.cdcooper   AND
                                craphis.cdhistor = crapcor.cdhistor 
                                NO-LOCK NO-ERROR.
          
             ASSIGN i-p-aviso-cheque  = "Aviso de " +
                    STRING(crapcor.dtemscor,"99/99/9999").

             IF  AVAIL craphis  THEN
                 ASSIGN i-p-aviso-cheque = i-p-aviso-cheque +
                        " -->  " + craphis.dshistor. 
         END.

END PROCEDURE.
/* bo-vercheque.i */

/* .......................................................................... */


