/* .............................................................................

   Programa: Fontes/crps610.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Gabriel
   Data    : Outubro/2011                          Ultima alteracao: 10/07/2013

   Dados referentes ao programa:

   Frequencia: Diario. Solicitacao 82. Ordem 88. Cadeia Exclusiva.
   
   Objetivo  : Ira rodar DIARIAMENTE na CENTRAL. 
               Efetuar acerto financeiro na conta corrente das filiadas, 
               referente a movimentação total das operações entre cooperativas: 
               depósito, transferência e transferência de TEC salário.
                              
   Alteracoes: 10/07/2013 - Ignorar transferencias estornadas (David).
   
............................................................................ */


{ includes/var_batch.i }
{ sistema/generico/includes/var_internet.i }
         

DEF VAR aux_vllanmto AS DECI                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.


DEF VAR h-b1wgen0118 AS HANDLE                                      NO-UNDO.
         

ASSIGN glb_cdprogra = "crps610".

RUN fontes/iniprg.p.

IF   glb_cdcritic  > 0   THEN
     RETURN.


Acerto: DO TRANSACTION ON ERROR UNDO, RETURN:

    RUN sistema/generico/procedures/b1wgen0118.p PERSISTENT SET h-b1wgen0118.

     /* Busca dados da cooperativa */
    FOR EACH crapcop WHERE crapcop.cdcooper <> 3 NO-LOCK:
            
        /* Lancamentos do dia , Agencias Diferentes */
        FOR EACH crapldt WHERE crapldt.cdcooper  = crapcop.cdcooper AND   
                               crapldt.cdagerem <> crapldt.cdagedst AND
                               crapldt.dttransa  = glb_dtmvtolt     AND 
                               crapldt.flgestor  = FALSE            NO-LOCK
                               BREAK BY crapldt.tpoperac
                                        BY crapldt.cdagedst:

            ASSIGN aux_vllanmto = aux_vllanmto + crapldt.vllanmto.

            IF   LAST-OF (crapldt.cdagedst)   AND 
                 aux_vllanmto <> 0            THEN  
                 DO:
                      RUN acerto-financeiro IN h-b1wgen0118 
                                    (INPUT crapcop.cdcooper,
                                     INPUT 0,
                                     INPUT 0,
                                     INPUT glb_cdoperad,
                                     INPUT glb_cdprogra,
                                     INPUT 1, /* Ayllos */
                                     INPUT crapldt.tpoperac,
                                     INPUT crapldt.cdagedst,
                                     INPUT aux_vllanmto,
                                     INPUT glb_dtmvtolt,
                                     INPUT FALSE,
                                    OUTPUT TABLE tt-erro).  

                      IF   RETURN-VALUE <> "OK"   THEN
                           DO:
                               FIND FIRST tt-erro NO-LOCK NO-ERROR.
                            
                               IF   AVAIL tt-erro   THEN
                                    ASSIGN aux_dscritic = 
                                            tt-erro.dscritic.
                               ELSE
                                    ASSIGN aux_dscritic = 
                              "Erro no acerto financeiro das operacoes.".

                               UNIX SILENT VALUE ("echo "       +
                                  STRING(TIME,"HH:MM:SS")   + " - " +
                                  glb_cdprogra  + "' --> '" + 
                                  aux_dscritic  + " >> log/proc_batch.log").
                                                               
                               DELETE PROCEDURE h-b1wgen0118.

                               UNDO, LEAVE Acerto.
                           END. 
                    
                      ASSIGN aux_vllanmto = 0.  
                 END.
        END.

    END.

    DELETE PROCEDURE h-b1wgen0118.

END.


RUN fontes/fimprg.p.


/*...........................................................................*/
