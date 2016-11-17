/* ............................................................................

   Programa: Fontes/sldccr_s2v.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Maio/2004                           Ultima atualizacao: 01/04/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para opcao de solicitacao de 2.a. Via do cartao

   Alteracoes: 27/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane. 

               12/09/2006 - Excluida opcao "TAB" (Diego).

               25/08/2008 - Esconder frames ao encerrar o programa (David).
               
               17/02/2009 - Logar em log/sldccr.log (Gabriel).
               
               19/06/2009 - Alteracao para utilizacao de BOs - Temp-tables
                            (GATI - Eder)
                            
               20/10/2010 - Alteracao para imprimir termo de pessoa jurica
                           (Gati - Daniel).
                           
               12/09/2011 - Incluir tratamento para Sol. 2via para Cartoes
                            Bradesco - Dt. Vencimento (Ze).
                            
               10/07/2012 - Alterado label para "Nome no Plastico do Cartao"
                            quando for solicitação de 2.a Via com motivo
                            "Mudança de nome" (Guilherme Maba).   
                            
               01/04/2013 - Retirado a chamada da procedure alerta_fraude
                            (Adriano).             
                                                     
............................................................................ */

{ sistema/generico/includes/b1wgen0028tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }
{ includes/var_atenda.i }


DEF  INPUT PARAM par_nrctrcrd AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrcrcard AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_cdadmcrd AS INTE                                  NO-UNDO.

DEF VAR tel_dsmotivo AS CHAR FORMAT "x(21)"                            NO-UNDO.
DEF VAR tel_nmtitcrd AS CHAR FORMAT "x(30)"                            NO-UNDO.

DEF VAR aux_indposic AS INTE INIT 1                                    NO-UNDO.
DEF VAR aux_indposi2 AS INTE INIT 1                                    NO-UNDO.
DEF VAR aux_dsmotivo AS CHAR                                           NO-UNDO.
DEF VAR aux_cdmotivo AS CHAR                                           NO-UNDO.

DEF VAR h_b1wgen0028 AS HANDLE                                         NO-UNDO.

DEF VAR aux_cpfrepre AS DEC EXTENT 3                                   NO-UNDO.
DEF VAR tel_repsolic AS CHAR FORMAT "x(40)"                            NO-UNDO.


DEF VAR aux_nmarqimp  AS CHAR                                        NO-UNDO.
DEF VAR aux_tipopess  AS INT                                         NO-UNDO.
DEF VAR aux_represen  AS CHAR                                        NO-UNDO.
DEFINE VARIABLE h_termos  AS HANDLE      NO-UNDO.

/***** Variaveis de impressao - utilizadas em impressao.i *****/
DEF   VAR aux_flgescra     AS LOGICAL                                NO-UNDO.
DEF   VAR par_flgfirst     AS LOGICAL INIT TRUE                      NO-UNDO.
DEF   VAR par_flgcance     AS LOGICAL                                NO-UNDO.
DEF   VAR aux_dscomand     AS CHAR                                   NO-UNDO.
DEF   VAR par_flgrodar     AS LOGICAL INIT TRUE                      NO-UNDO.
DEF   VAR aux_nmendter     AS CHAR FORMAT "x(20)"                    NO-UNDO.
DEF   VAR tel_dsimprim     AS CHAR FORMAT "x(8)" INIT "Imprimir"     NO-UNDO.
DEF   VAR tel_dscancel     AS CHAR FORMAT "x(8)" INIT "Cancelar"     NO-UNDO.
DEF   VAR tel_dddebito     AS INTE FORMAT "z9"                       NO-UNDO.
DEF   VAR aux_dddebito     AS CHAR                                   NO-UNDO.
DEF   VAR aux_confirma     AS CHAR FORMAT "!"                        NO-UNDO.



FORM SKIP(1)
     tel_dsmotivo  LABEL "Motivo da substituicao"  AT 4
     HELP "Use as setas para escolher o motivo da substituicao"
     SKIP(1)
     WITH SIDE-LABELS ROW 14
     OVERLAY CENTERED TITLE COLOR NORMAL " 2 via " FRAME f_2via.


FORM SKIP(1)
     tel_repsolic FORMAT "x(40)" LABEL "Representante Solicitante" AT 2
     HELP "Utilizar setas direita/esquerda para escolher Representante" SKIP (1)
     tel_dsmotivo  LABEL "Motivo da substituicao"  AT 5
     HELP "Use as setas para escolher o motivo da substituicao"
     SKIP(1)
     WITH SIDE-LABELS ROW 13
     OVERLAY CENTERED TITLE COLOR NORMAL " 2 via " FRAME f_2via_pj.


FORM SKIP(1)
     tel_nmtitcrd  LABEL "Nome no Plastico do Cartao"  AT 4
     HELP "Digite o novo nome do titular do cartao."
     SKIP(1)
     WITH SIDE-LABELS ROW 14
     OVERLAY CENTERED TITLE COLOR NORMAL " 2 via " FRAME f_nome2via.
     

FORM SKIP(1)
     par_nrcrcard LABEL "Numero do cartao" COLON 25 
                 FORMAT "9999,9999,9999,9999"
     "   "
     SKIP(1)
     tel_dddebito LABEL "Dia do debito"  COLON 25
                  HELP "Use as setas para escolher o dia para Debito."
     WITH SIDE-LABELS ROW 9
     OVERLAY CENTERED TITLE COLOR NORMAL 
             " Alteracao de Data de Vencimento - 2 via " FRAME f_novadata.



RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h_b1wgen0028.

RUN carrega_dados_solicitacao2via_cartao IN h_b1wgen0028
                             (INPUT glb_cdcooper,
                              INPUT 0, 
                              INPUT 0, 
                              INPUT glb_cdoperad,
                              INPUT tel_nrdconta,
                              INPUT par_nrctrcrd,
                              INPUT glb_dtmvtolt,
                             OUTPUT TABLE tt-erro,
                             OUTPUT TABLE tt-motivos_2via).

RUN verifica_associado IN h_b1wgen0028 (INPUT glb_cdcooper,
                                        INPUT tel_nrdconta,
                                        OUTPUT aux_tipopess).

DELETE PROCEDURE h_b1wgen0028.
     
IF  RETURN-VALUE = "NOK"  THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
        
        IF  AVAIL tt-erro  THEN
            DO:
                BELL.
                MESSAGE tt-erro.dscritic.
            END.

        RETURN "NOK".
    END.

ASSIGN aux_cdmotivo = ""
       aux_dsmotivo = "".

FOR EACH tt-motivos_2via BY tt-motivos_2via.cdmotivo:

    IF  aux_cdmotivo = ""  THEN
        ASSIGN aux_cdmotivo = STRING(tt-motivos_2via.cdmotivo).
    ELSE
        ASSIGN aux_cdmotivo = aux_cdmotivo + "," +
                              STRING(tt-motivos_2via.cdmotivo).
                                
    IF  aux_dsmotivo = ""  THEN
        ASSIGN aux_dsmotivo = tt-motivos_2via.dsmotivo.
    ELSE
        ASSIGN aux_dsmotivo = aux_dsmotivo + "," + 
                              tt-motivos_2via.dsmotivo.

END.

RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h_b1wgen0028.
                 
RUN carrega_representante IN h_b1wgen0028(INPUT glb_cdcooper,
                                          INPUT tel_nrdconta,  
                                          OUTPUT aux_represen,
                                          OUTPUT aux_cpfrepre).
 
DELETE PROCEDURE h_b1wgen0028.


          
IF  aux_cdmotivo = "" OR aux_dsmotivo = ""  THEN
    RETURN "NOK".
     
ASSIGN tel_dsmotivo = ENTRY(1,aux_dsmotivo).  
ASSIGN tel_repsolic = ENTRY(1,aux_represen). 


DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

    IF   aux_tipopess = 2 THEN
         DO:

             UPDATE tel_repsolic tel_dsmotivo WITH FRAME f_2via_pj
             
             EDITING:
                 READKEY.
             
                 IF  FRAME-FIELD = "tel_repsolic"  THEN
                     DO:

                         IF  KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT"  THEN
                             DO:
                                 aux_indposi2 = aux_indposi2 - 1.
             
                                 IF  aux_indposi2 = 0  THEN
                                     aux_indposi2 = NUM-ENTRIES(aux_represen).
             
                                 tel_repsolic = ENTRY(aux_indposi2,aux_represen).
             
                                 DISPLAY tel_repsolic WITH FRAME f_2via_pj.
                             END.

                         ELSE
                         IF  KEYFUNCTION(LASTKEY) = "CURSOR-LEFT"  THEN
                             DO:
                                 aux_indposi2 = aux_indposi2 + 1.
             
                                 IF  aux_indposi2 > NUM-ENTRIES(aux_represen)  THEN
                                     aux_indposi2 = 1.
             
                                 tel_repsolic =  TRIM(ENTRY(aux_indposi2,
                                                            aux_represen)).
             
                                 DISPLAY tel_repsolic WITH FRAME f_2via_pj.
                             END.
                         ELSE
                         IF  KEYFUNCTION(LASTKEY) = "RETURN"     OR
                             KEYFUNCTION(LASTKEY) = "BACK-TAB"   OR
                             KEYFUNCTION(LASTKEY) = "GO"         OR
                             KEYFUNCTION(LASTKEY) = "CURSOR-UP"  OR
                             KEYFUNCTION(LASTKEY) = "CURSOR-DOWN"  OR
                             KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                             APPLY LASTKEY.
                          
                     END. 
                 ELSE            
                 IF  FRAME-FIELD = "tel_dsmotivo"  THEN
                     DO:
                         IF  KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT"  THEN
                             DO:
                                 aux_indposic = aux_indposic - 1.
             
                                 IF  aux_indposic = 0  THEN
                                     aux_indposic = NUM-ENTRIES(aux_dsmotivo).
             
                                 tel_dsmotivo = ENTRY(aux_indposic,aux_dsmotivo).
             
                                 DISPLAY tel_dsmotivo WITH FRAME f_2via_pj.
                             END.
                         ELSE
                         IF  KEYFUNCTION(LASTKEY) = "CURSOR-LEFT"  THEN
                             DO:
                                 aux_indposic = aux_indposic + 1.
             
                                 IF  aux_indposic > NUM-ENTRIES(aux_dsmotivo)  THEN
                                     aux_indposic = 1.
             
                                 tel_dsmotivo = TRIM(ENTRY(aux_indposic,
                                                           aux_dsmotivo)).
             
                                 DISPLAY tel_dsmotivo WITH FRAME f_2via_pj.
                             END.
                         ELSE
                         IF  KEYFUNCTION(LASTKEY) = "RETURN"      OR
                             KEYFUNCTION(LASTKEY) = "BACK-TAB"    OR
                             KEYFUNCTION(LASTKEY) = "GO"          OR
                             KEYFUNCTION(LASTKEY) = "CURSOR-UP"   OR
                             KEYFUNCTION(LASTKEY) = "CURSOR-DOWN" OR
                             KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                             APPLY LASTKEY.
                     END. 
                   
             END. /* Fim do EDITING */   
        END.
    ELSE DO:
        UPDATE tel_dsmotivo WITH FRAME f_2via
        
        EDITING:
            READKEY.
            
            IF  FRAME-FIELD = "tel_dsmotivo"  THEN
                DO:
                    IF  KEYFUNCTION(LASTKEY) = "CURSOR-UP"     OR
                        KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT"  THEN
                        DO:
                            aux_indposic = aux_indposic - 1.
        
                            IF  aux_indposic = 0  THEN
                                aux_indposic = NUM-ENTRIES(aux_dsmotivo).
        
                            tel_dsmotivo = ENTRY(aux_indposic,aux_dsmotivo).
        
                            DISPLAY tel_dsmotivo WITH FRAME f_2via.
                        END.
                    ELSE
                    IF  KEYFUNCTION(LASTKEY) = "CURSOR-DOWN"  OR
                        KEYFUNCTION(LASTKEY) = "CURSOR-LEFT"  THEN
                        DO:
                            aux_indposic = aux_indposic + 1.
        
                            IF  aux_indposic > NUM-ENTRIES(aux_dsmotivo)  THEN
                                aux_indposic = 1.
        
                            tel_dsmotivo = TRIM(ENTRY(aux_indposic,
                                                      aux_dsmotivo)).
        
                            DISPLAY tel_dsmotivo WITH FRAME f_2via.
                        END.
                    ELSE
                    IF  KEYFUNCTION(LASTKEY) = "RETURN"     OR
                        KEYFUNCTION(LASTKEY) = "BACK-TAB"   OR
                        KEYFUNCTION(LASTKEY) = "GO"         OR
                        KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                        APPLY LASTKEY.
                END. 
            ELSE
                APPLY LASTKEY.
              
        END. /* Fim do EDITING */
    END.

    
    CASE INTE(TRIM(ENTRY(aux_indposic,aux_cdmotivo))):
        
      WHEN 5 THEN 
             DO:
                 HIDE FRAME f_2via NO-PAUSE.
                 HIDE FRAME f_2via_pj NO-PAUSE.

                 DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    UPDATE tel_nmtitcrd WITH FRAME f_nome2via.

                    RUN efetua_solicitacao.

                    IF  RETURN-VALUE = "NOK"  THEN
                        NEXT.

                    LEAVE.

                 END.

                 IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                     DO:
                         HIDE FRAME f_nome2via NO-PAUSE.
                         NEXT.
                     END.
                
             END.

      WHEN 7 THEN 
             DO:
                 HIDE FRAME f_2via NO-PAUSE.
                 HIDE FRAME f_2via_pj NO-PAUSE.

                 DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    RUN sistema/generico/procedures/b1wgen0028.p 
                        PERSISTENT SET h_b1wgen0028.
   
                    RUN carrega_dados_dtvencimento_cartao_2via IN h_b1wgen0028
                          (INPUT glb_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT glb_cdoperad,
                           INPUT tel_nrdconta,
                           INPUT glb_dtmvtolt,
                           INPUT 1,
                           INPUT 1,
                           INPUT glb_nmdatela,
                           INPUT par_nrctrcrd,
                           INPUT par_cdadmcrd,
                          OUTPUT TABLE tt-erro,
                          OUTPUT TABLE tt-dtvencimento_cartao).
    
                    DELETE PROCEDURE h_b1wgen0028.

                    IF  RETURN-VALUE = "NOK"  THEN
                        DO:
                            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
                            IF  AVAIL tt-erro  THEN
                                DO:
                                    BELL.
                                    MESSAGE tt-erro.dscritic.
                                END.

                            RETURN "NOK".
                        END.

                    FIND tt-dtvencimento_cartao NO-ERROR.
    
                    IF  NOT AVAIL tt-dtvencimento_cartao  THEN 
                        RETURN "NOK".
    
                    ASSIGN aux_dddebito = 
                             ENTRY(2,tt-dtvencimento_cartao.diasdadm,";")
                           tel_dddebito = tt-dtvencimento_cartao.dddebito.

                    DISPLAY par_nrcrcard WITH FRAME f_novadata.

                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
             
                       UPDATE tel_dddebito WITH FRAME f_novadata
              
                       EDITING:
                 
                         READKEY. 
                     
                         IF  KEYFUNCTION(LASTKEY) = "CURSOR-UP"     OR
                             KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT"  THEN
                             DO:
                                 IF   aux_indposic > 
                                      NUM-ENTRIES(aux_dddebito)  THEN
                                      aux_indposic = NUM-ENTRIES(aux_dddebito).
             
                                 aux_indposic = aux_indposic - 1.
             
                                 IF   aux_indposic <= 0  THEN
                                      aux_indposic = NUM-ENTRIES(aux_dddebito).
             
                                 tel_dddebito =
                                      INT(ENTRY(aux_indposic,aux_dddebito)).
             
                                 DISPLAY tel_dddebito WITH FRAME f_novadata.
                             END.
                         ELSE
                             IF  KEYFUNCTION(LASTKEY) = "CURSOR-DOWN"  OR
                                 KEYFUNCTION(LASTKEY) = "CURSOR-LEFT"  THEN
                                 DO: 
                                     aux_indposic = aux_indposic + 1.
            
                                     IF  aux_indposic >
                                         NUM-ENTRIES(aux_dddebito)  THEN
                                         aux_indposic = 1.
             
                                     tel_dddebito = 
                                         INT(ENTRY(aux_indposic,aux_dddebito)).
             
                                     DISPLAY tel_dddebito WITH FRAME f_novadata.
                                 END.
                             ELSE
                                 IF  (KEYFUNCTION(LASTKEY) = "RETURN"     OR
                                      KEYFUNCTION(LASTKEY) = "BACK-TAB"   OR
                                      KEYFUNCTION(LASTKEY) = "GO"         OR
                                      KEYFUNCTION(LASTKEY) = "END-ERROR") THEN 
                                      APPLY LASTKEY.
                       END. /* EDITING */
             
                       LEAVE.
             
                    END. /* Fim do DO WHILE TRUE */

                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                        DO:
                            HIDE FRAME f_novadata NO-PAUSE.
                            RETURN "NOK".
                        END.
 
                    aux_confirma = "N".
    
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
 
                       glb_cdcritic = 78.
                       RUN fontes/critic.p.
                       glb_cdcritic = 0.
        
                       BELL.
                       MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
           
                       LEAVE.
    
                    END. /* Fim do DO WHILE TRUE */
 
                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  OR
                        aux_confirma <> "S"                 THEN
                        DO:
                            glb_cdcritic = 79.
                            RUN fontes/critic.p.
                            glb_cdcritic = 0.

                            BELL.
                            MESSAGE glb_dscritic.

                            HIDE FRAME f_novadata NO-PAUSE.
               
                            RETURN "NOK".
                        END.
 
                    RUN sistema/generico/procedures/b1wgen0028.p 
                        PERSISTENT SET h_b1wgen0028.
    
                    RUN altera_dtvencimento_cartao IN h_b1wgen0028
                            (INPUT glb_cdcooper,
                             INPUT 0,
                             INPUT 0,
                             INPUT glb_cdoperad,
                             INPUT tel_nrdconta,
                             INPUT glb_dtmvtolt,
                             INPUT 1,
                             INPUT 1,
                             INPUT glb_nmdatela,
                             INPUT par_nrctrcrd,
                             INPUT tel_dddebito,
                             INPUT aux_cpfrepre[aux_indposi2],
                             INPUT tel_repsolic,
                            OUTPUT TABLE tt-erro).

                    DELETE PROCEDURE h_b1wgen0028.
     
                    IF  RETURN-VALUE = "NOK"  THEN
                        DO:
                            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
                            IF  AVAIL tt-erro  THEN
                                DO:
                                    BELL.
                                    MESSAGE tt-erro.dscritic.
                                END.

                            NEXT.
                        END.

                    IF  aux_tipopess = 2 THEN
                        DO:
                            RUN fontes/termos_pj.p PERSISTENT SET h_termos.
                                    
                            RUN segunda_via_cartao IN h_termos 
                                                (INPUT glb_cdcooper,
                                                 INPUT glb_cdoperad,
                                                 INPUT glb_nmdatela,
                                                 INPUT tel_nrdconta,
                                                 INPUT glb_dtmvtolt,
                                                 INPUT par_nrctrcrd).

                            DELETE PROCEDURE h_termos.
                        END.

                    LEAVE.

                 END. /* DO WHILE TRUE */
             END.

      OTHERWISE
             DO:    
                 RUN efetua_solicitacao.

                 IF  RETURN-VALUE = "NOK"  THEN
                     NEXT.
             END.        
    END CASE.
          
    LEAVE.
     
END. /* Fim do DO WHILE TRUE */

HIDE FRAME f_2via     NO-PAUSE.
HIDE FRAME f_2via_pj  NO-PAUSE.
HIDE FRAME f_nome2via NO-PAUSE.
HIDE FRAME f_novadata NO-PAUSE.


IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
    RETURN "NOK".

IF   aux_tipopess = 1 THEN
     RUN fontes/imp2viacrd.p (INPUT par_nrctrcrd).

RETURN "OK".

PROCEDURE efetua_solicitacao:

    RUN sistema/generico/procedures/b1wgen0028.p 
        PERSISTENT SET h_b1wgen0028. 

    RUN efetua_solicitacao2via_cartao IN h_b1wgen0028
                       (INPUT glb_cdcooper,
                        INPUT 0,
                        INPUT 0,
                        INPUT glb_cdoperad,
                        INPUT tel_nrdconta,
                        INPUT par_nrctrcrd,
                        INPUT glb_dtmvtolt,
                        INPUT 1,
                        INPUT 1,
                        INPUT glb_nmdatela,
                        INPUT par_cdadmcrd,
                        INPUT INT(TRIM(ENTRY(aux_indposic,aux_cdmotivo))),
                        INPUT tel_nmtitcrd,
                        INPUT aux_cpfrepre[aux_indposi2],
                        INPUT tel_repsolic,
                        OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h_b1wgen0028.

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  AVAIL tt-erro  THEN
                DO:
                    BELL.
                    MESSAGE tt-erro.dscritic.
                END.

            RETURN "NOK".
        END.

    RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h_b1wgen0028.
   
    IF   aux_tipopess = 2 THEN
         DO:
             RUN fontes/termos_pj.p PERSISTENT SET h_termos.
                                    
             RUN segunda_via_cartao IN h_termos (INPUT glb_cdcooper,
                                                 INPUT glb_cdoperad,
                                                 INPUT glb_nmdatela,
                                                 INPUT tel_nrdconta,
                                                 INPUT glb_dtmvtolt,
                                                 INPUT par_nrctrcrd).

             DELETE PROCEDURE h_termos.
         END.
         
    DELETE PROCEDURE h_b1wgen0028.

    RETURN "OK".

END PROCEDURE.

/*...........................................................................*/
