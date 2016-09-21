{ includes/var_batch.i "new" }  
{ includes/var_rdca2.i }

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0004tt.i }

DEF        VAR res_nraplica AS INTE                                    NO-UNDO.

DEF        VAR aux_vltotrda LIKE craprda.vlsdrdca                      NO-UNDO.
DEF        VAR aux_txaplica LIKE craplap.txaplica                      NO-UNDO.
DEF        VAR aux_txaplmes LIKE craplap.txaplmes                      NO-UNDO.
                                                                 
DEF        VAR h-b1wgen0004 AS HANDLE                                  NO-UNDO.

DEF VAR cap_txaplica AS DECIMAL DECIMALS 6                           NO-UNDO.

DEF VAR aux_vlirrdca LIKE craprda.vlsdrdca                           NO-UNDO.

DEF VAR aux_vlsldant AS DECI NO-UNDO.

def var aux_txaplica_dif as deci no-undo.
def var aux_vlrendim_dif as deci no-undo.
def var aux_vltotrda_dif as deci no-undo.
def var aux_vlirrdca_dif as deci no-undo.

def var tot_vlrendim_dif as deci no-undo.
def var tot_vlirrdca_dif as deci no-undo.

DEF BUFFER crablap FOR craplap.

DEF STREAM str_1.

FORM craprda.cdcooper column-label "Coop."
     craprda.nrdconta column-label "Conta/dv"
     craprda.nraplica column-label "Nr. Aplica"
     craplap.txaplica column-label "Tx Aplicada"
     cap_txaplica     column-label "Tx Faixa" format "zz9.999999"
     aux_txaplica_dif column-label "Dif. Tx" format "zz9.999999-"
     craplap.vllanmto column-label "Vlr. Rend. Calc."
     rd2_vlrentot     column-label "Vlr. Rend. Faixa"
     aux_vlrendim_dif column-label "Dif. Vlr. Rend." format "zzz,zzz,zz9.99-"
     craplap.dtrefere column-label "Dt. Refere."
     aux_vlsldant     column-label "Saldo Aplica"
     craplap.vlsdlsap column-label "Saldo Total Calc."
     aux_vltotrda     column-label "Saldo Total Faixa"
     aux_vltotrda_dif column-label "Dif. Saldo Total"
                                    format "zzz,zzz,zzz,zzz,zz9.99-"
     crablap.vllanmto column-label "Valor IR Calc."
     aux_vlirrdca     column-label "Valor IR Faixa"
     aux_vlirrdca_dif column-label "Dif. Valor IR" format "zzz,zzz,zz9.99-"
    WITH DOWN WIDTH 500 FRAME f_dados.
    
FORM SKIP(2)
     tot_vlrendim_dif label "DIFERENCA TOTAL RENDIMENTO (R$)" SKIP
     tot_vlirrdca_dif label "DIFERENCA TOTAL IR (R$)"
     WITH SIDE-LABELS FRAME f_total.


assign glb_dtmvtolt = 06/03/2014
       glb_dtmvtopr = 06/04/2014
       glb_cdprogra = "crps176".
       
FOR EACH crapcop WHERE crapcop.cdcooper = 16 NO-LOCK:

    assign glb_cdcooper = crapcop.cdcooper
           glb_cdcritic = 0
           glb_dscritic = "".
           
    assign tot_vlrendim_dif = 0
           tot_vlirrdca_dif = 0.
           
    { includes/var_faixas_ir.i "NEW" }
                
    OUTPUT STREAM str_1 
        TO VALUE("/micros/cecred/rodrigo/relacao_aplicacoes_" +                             UPPER(crapcop.nmrescop) + STRING(DAY(glb_dtmvtopr)) + 
             STRING(MONTH(glb_dtmvtopr)) + ".lst") PAGED PAGE-SIZE 84.

    PUT STREAM str_1 SKIP(2) 
                     "RELACAO APLICACOES - " AT 15
                     UPPER(crapcop.nmrescop) AT 36 FORMAT "x(12)"
                     " - REF. " AT 50
                     STRING(glb_dtmvtopr, "99/99/9999") AT 58 FORMAT "x(10)"
                     SKIP(2).

    TRANS_1:
    
    /*  Leitura das aplicacoes RDCA  */
    FOR EACH crapass WHERE crapass.cdcooper = crapcop.cdcooper NO-LOCK
                           TRANSACTION ON ERROR UNDO TRANS_1, RETURN:
     
        FIND FIRST craprda WHERE craprda.cdcooper  = crapcop.cdcooper       AND
                                 craprda.nrdconta  = crapass.nrdconta   AND
                            /*     craprda.dtiniper >= glb_dtmvtolt       AND
                                 craprda.dtiniper <= glb_dtmvtopr       AND*/ 
                                 craprda.dtiniper  = glb_dtmvtopr       AND
                            /*   craprda.incalmes  = 0                  AND */
                                 craprda.insaqtot  = 0                  AND
                                 craprda.tpaplica  = 5          
                                 USE-INDEX craprda3
                                 NO-LOCK NO-ERROR.
                                 
        IF   AVAILABLE craprda   THEN
             DO:
                 ASSIGN aux_vltotrda = 0.
        
                 RUN sistema/generico/procedures/b1wgen0004.p PERSISTENT 
                     SET h-b1wgen0004.
        
                 IF   NOT VALID-HANDLE(h-b1wgen0004)   THEN
                      DO:
                          UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                            " - " + glb_cdprogra + "' --> '" +
                                            "Handle invalido para BO b1wgen0004" + 
                                            " >> log/proc_batch.log").
                
                          UNDO TRANS_1, RETURN.
                      END.

                 RUN acumula_aplicacoes IN h-b1wgen0004 (INPUT crapcop.cdcooper,
                                                         INPUT glb_cdprogra,
                                                         INPUT crapass.nrdconta, 
                                                         INPUT 0, /** nrdocmto **/
                                                         INPUT 3, /** tpaplica **/                                               
                                                         INPUT 0, /** vllanmto **/         
                                                         INPUT 0, /** cdperapl **/ 
                                                        OUTPUT aux_vltotrda,
                                                        OUTPUT aux_txaplica,  
                                                        OUTPUT aux_txaplmes,
                                                        OUTPUT TABLE tt-erro,
                                                        OUTPUT TABLE tt-acumula).
                             
                 DELETE PROCEDURE h-b1wgen0004.

                 IF   RETURN-VALUE = "NOK"   THEN   
                      DO:  
                          FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                
                          IF   AVAILABLE tt-erro   THEN
                               glb_dscritic = tt-erro.dscritic.
                          ELSE
                               glb_dscritic = "Erro na procedure " +
                                              "acumula_aplicacoes (b1wgen0004).".
                    
                          UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                            " - " + glb_cdprogra + "' --> '" +
                                            glb_dscritic + 
                                            " >> log/proc_batch.log").
                
                          UNDO TRANS_1, RETURN.
                      END.
    
                 IF   aux_vltotrda < 0   THEN
                      aux_vltotrda = 0.
    
                 FOR EACH craprda WHERE craprda.cdcooper  = crapcop.cdcooper                                       AND craprda.nrdconta  = crapass.nrdconta 
                                 /*   AND craprda.dtiniper >= glb_dtmvtolt
                                    AND craprda.dtiniper <= glb_dtmvtopr */
                                    AND craprda.dtiniper  = glb_dtmvtopr 
                                    AND craprda.insaqtot  = 0                
                                    AND /*       craprda.incalmes  = 0 
                                    AND                               */
                                  craprda.tpaplica  = 5
                                  USE-INDEX craprda2:
                /*   message "aqui" view-as alert-box. */
                   /*  { includes/rdca2a.i } */  
                   /* Rotina de calculo do RDCA2                                                            */
                     { includes/include_aplicacoes_relat.i }

                 END.
                 /*    
                 DO WHILE TRUE:
    
                    FIND crapres WHERE crapres.cdcooper = glb_cdcooper  AND
                                       crapres.cdprogra = glb_cdprogra
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
                    IF   NOT AVAILABLE crapres   THEN
                         IF   LOCKED crapres   THEN
                              DO:
                                  PAUSE 1 NO-MESSAGE.
                                  NEXT.
                              END.
                         ELSE
                    DO:
                         glb_cdcritic = 151.
                         RUN fontes/critic.p.
                         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                           " - " + glb_cdprogra + "' --> '" +
                                           glb_dscritic + " >> log/proc_batch.log").
                         UNDO TRANS_1, RETURN.
                    END.
    
                    LEAVE.
    
                 END.  /*  Fim do DO WHILE TRUE  */
    
                 ASSIGN crapres.nrdconta = crapass.nrdconta.
                 */
             END. /* existe aplicacoes para o dia */
             
    END. /* Fim do FOR EACH crapass */
    
    IF   glb_cdcritic > 0   THEN
         DO:
             RUN fontes/critic.p.
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                               glb_cdprogra + "' --> '" + glb_dscritic +
                               " >> log/proc_batch.log").
             RETURN.
         END.
         
    DISPLAY STREAM str_1 tot_vlrendim_dif
                         tot_vlirrdca_dif
                         WITH FRAME f_total.

    OUTPUT STREAM str_1 CLOSE.
END. /* end for each crapcop */

/****************************************************************************/
