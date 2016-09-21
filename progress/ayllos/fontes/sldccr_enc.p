/* ............................................................................

   Programa: Fontes/sldccr_enc.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Isara - RKAM
   Data    : Fevereiro/11.                          Ultima atualizacao: 21/02/2011

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para encerramento de cartoes de credito.

   Alteracoes: 
............................................................................ */

{ sistema/generico/includes/b1wgen0028tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_sldccr.i }

DEF  INPUT PARAM par_nrctrcrd AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrcrcard AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_cdadmcrd AS INTE                                  NO-UNDO.

DEF VAR tel_dsencerr AS CHAR INIT "Encerrar"                           NO-UNDO.
DEF VAR tel_dsdesfaz AS CHAR INIT "Desfazer" FORMAT "x(11)"            NO-UNDO.
DEF VAR tel_dsmotivo AS CHAR FORMAT "x(21)"                            NO-UNDO.

DEF VAR aux_confirma AS CHAR FORMAT "!"                                NO-UNDO.
DEF VAR aux_cdmotivo AS CHAR INIT "3,4,6"                              NO-UNDO.
DEF VAR aux_dsmotivo AS CHAR INIT "Pelo socio,Pela COOP,Por fraude"    NO-UNDO.
DEF VAR aux_msgalert AS CHAR                                           NO-UNDO.
DEF VAR aux_indposic AS INTE INIT 1                                    NO-UNDO.

DEF VAR aux_flgadmbb AS LOG                                            NO-UNDO.
                                                                     
DEF VAR h_b1wgen0028 AS HANDLE                                         NO-UNDO.
DEF VAR h_Termos     AS HANDLE                                         NO-UNDO.

DEF VAR aux_cpfrepre AS DEC EXTENT 3                                   NO-UNDO.
DEF VAR tel_repsolic AS CHAR FORMAT "x(40)"                            NO-UNDO.
DEF VAR aux_represen AS CHAR                                           NO-UNDO.
DEF VAR aux_indposi2 AS INTE INIT 1                                    NO-UNDO.


DEF VAR aux_tipopess AS INT                                            NO-UNDO.

/***** Variaveis de impressao - utilizadas em impressao.i *****/
DEF   VAR aux_flgescra     AS LOGICAL                                NO-UNDO.
DEF   VAR par_flgfirst     AS LOGICAL INIT TRUE                      NO-UNDO.
DEF   VAR par_flgcance     AS LOGICAL                                NO-UNDO.
DEF   VAR aux_dscomand     AS CHAR                                   NO-UNDO.
DEF   VAR par_flgrodar     AS LOGICAL INIT TRUE                      NO-UNDO.
DEF   VAR aux_nmendter     AS CHAR FORMAT "x(20)"                    NO-UNDO.
DEF   VAR tel_dsimprim     AS CHAR FORMAT "x(8)" INIT "Imprimir"     NO-UNDO.
DEF   VAR aux_nmarqimp     AS CHAR                                   NO-UNDO.

FORM SKIP(1)
     tel_dsencerr AT  5
     HELP "Tecle <Entra> para confirmar ou <Fim> para retornar."
     tel_dsdesfaz AT 26
     HELP "Tecle <Entra> para confirmar ou <Fim> para retornar."
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY CENTERED  WIDTH 40
     NO-LABELS TITLE COLOR NORMAL " Encerramento " FRAME f_tit.

FORM SKIP(1)
     par_nrcrcard  LABEL "Numero do cartao" FORMAT "9999,9999,9999,9999"
     HELP "Entre com o numero do cartao"           AT 10 "   "
     SKIP(1)
     tel_dsmotivo  LABEL "Motivo do encerramento"  AT 4
     HELP "Use as setas para escolher o motivo do encerramento"
     SKIP(1)
     WITH SIDE-LABELS ROW 11 OVERLAY CENTERED 
     TITLE COLOR NORMAL " Encerramento " FRAME f_enc.

FORM SKIP(1)
     tel_repsolic FORMAT "x(40)" LABEL "Representante Solicitante" AT 2 
     HELP "Utilizar setas direita/esquerda para escolher Representante" SKIP (1)
     par_nrcrcard  LABEL "Numero do cartao" FORMAT "9999,9999,9999,9999"
     HELP "Entre com o numero do cartao"           AT 11 "   "
     SKIP(1)
     tel_dsmotivo  LABEL "Motivo do encerramento"  AT 5
     HELP "Use as setas para escolher o motivo do encerramento"
     SKIP(1)
     WITH SIDE-LABELS ROW 11 OVERLAY CENTERED 
     TITLE COLOR NORMAL " Encerramento " FRAME f_enc_pj.


DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

    RUN sistema/generico/procedures/b1wgen0028.p 
        PERSISTENT SET h_b1wgen0028.
    
    RUN verifica_acesso_enc IN h_b1wgen0028 (INPUT glb_cdcooper,
                                             INPUT 0, 
                                             INPUT 0, 
                                             INPUT glb_cdoperad,
                                             INPUT tel_nrdconta,
                                             INPUT par_nrctrcrd,
                                            OUTPUT aux_flgadmbb,
                                            OUTPUT TABLE tt-erro).

    /* Verifica Tipo de Pessoa (PF ou PJ) */
    RUN verifica_associado IN h_b1wgen0028 (INPUT glb_cdcooper,
                                            INPUT tel_nrdconta,
                                            OUTPUT aux_tipopess).
                 
    RUN carrega_representante IN h_b1wgen0028(INPUT glb_cdcooper,
                                              INPUT tel_nrdconta,  
                                              OUTPUT aux_represen,
                                              OUTPUT aux_cpfrepre).
     
    DELETE PROCEDURE h_b1wgen0028.
    
    ASSIGN tel_repsolic = ENTRY(1,aux_represen). 

    IF  RETURN-VALUE = "NOK"   THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  AVAILABLE tt-erro  THEN
                DO:
                    BELL.
                    MESSAGE tt-erro.dscritic.
                END.

            RETURN "NOK".
        END.

    IF  aux_flgadmbb  THEN
        ASSIGN tel_dsencerr                       = "Encerrar"
               tel_dsdesfaz                       = "Desfazer"
               tel_dsmotivo:LABEL IN FRAME f_enc = "Motivo do Encerramento"
               tel_dsmotivo:LABEL IN FRAME f_enc_pj = "Motivo do Encerramento".
    
    DISPLAY tel_dsencerr tel_dsdesfaz WITH FRAME f_tit.
    
    CHOOSE FIELD tel_dsencerr tel_dsdesfaz WITH FRAME f_tit.

    HIDE MESSAGE NO-PAUSE.     
         
    IF  FRAME-VALUE = tel_dsencerr  THEN
        DO:
            HIDE FRAME f_tit NO-PAUSE.

            RUN sistema/generico/procedures/b1wgen0028.p 
                PERSISTENT SET h_b1wgen0028.
            
            RUN verifica_enc_cartao IN h_b1wgen0028 (INPUT glb_cdcooper,
                                                     INPUT 0, 
                                                     INPUT 0, 
                                                     INPUT glb_cdoperad,
                                                     INPUT tel_nrdconta,
                                                     INPUT par_nrctrcrd,
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


            IF   aux_tipopess = 2 THEN  
                DISPLAY tel_repsolic par_nrcrcard WITH FRAME f_enc_pj.
            ELSE
                DISPLAY par_nrcrcard WITH FRAME f_enc.
            
            tel_dsmotivo = ENTRY(aux_indposic,aux_dsmotivo).

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                IF   aux_tipopess = 2 THEN 
                     DO:
                        UPDATE tel_repsolic tel_dsmotivo WITH FRAME f_enc_pj
        
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
                         
                                            DISPLAY tel_repsolic WITH FRAME f_enc_pj.
                                        END.
            
                                    ELSE
                                    IF  KEYFUNCTION(LASTKEY) = "CURSOR-LEFT"  THEN
                                        DO:
                                            aux_indposi2 = aux_indposi2 + 1.
                         
                                            IF  aux_indposi2 > NUM-ENTRIES(aux_represen)  THEN
                                                aux_indposi2 = 1.
                         
                                            tel_repsolic =  TRIM(ENTRY(aux_indposi2,
                                                                       aux_represen)).
                         
                                            DISPLAY tel_repsolic WITH FRAME f_enc_pj.
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
                            ELSE
                            IF  FRAME-FIELD = "tel_dsmotivo"  THEN
                                DO:
                                    IF  KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT"  THEN
                                        DO:
                                            aux_indposic = aux_indposic - 1.
            
                                            IF  aux_indposic = 0  THEN
                                                aux_indposic = 
                                                    NUM-ENTRIES(aux_dsmotivo).
          
                                            tel_dsmotivo = 
                                                ENTRY(aux_indposic,aux_dsmotivo).
          
                                            DISPLAY tel_dsmotivo WITH FRAME f_enc_pj.
                                        END.
                                    ELSE
                                    IF  KEYFUNCTION(LASTKEY) = "CURSOR-LEFT"  THEN
                                        DO:
                                            aux_indposic = aux_indposic + 1.
                                            
                                            IF  aux_indposic > 
                                                    NUM-ENTRIES(aux_dsmotivo)  THEN
                                                aux_indposic = 1.
                                            
                                            tel_dsmotivo =
                                                TRIM(ENTRY(aux_indposic,aux_dsmotivo)).
                                            
                                            DISPLAY tel_dsmotivo WITH FRAME f_enc_pj.
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
                    UPDATE tel_dsmotivo WITH FRAME f_enc

                    EDITING:
                    
                        READKEY.
                        
                        IF  FRAME-FIELD = "tel_dsmotivo"  THEN
                            DO:
                                IF  (KEYFUNCTION(LASTKEY) = "CURSOR-UP"     OR
                                     KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT")  THEN
                                    DO:
                                        aux_indposic = aux_indposic - 1.
                    
                                        IF  aux_indposic = 0  THEN
                                            aux_indposic = 
                                                NUM-ENTRIES(aux_dsmotivo).
                    
                                        tel_dsmotivo = 
                                            ENTRY(aux_indposic,aux_dsmotivo).
                    
                                        DISPLAY tel_dsmotivo WITH FRAME f_enc.
                                    END.
                                ELSE
                                IF  KEYFUNCTION(LASTKEY) = "CURSOR-DOWN"  OR
                                    KEYFUNCTION(LASTKEY) = "CURSOR-LEFT"  THEN
                                    DO:
                                        aux_indposic = aux_indposic + 1.
                    
                                        IF  aux_indposic > 
                                                NUM-ENTRIES(aux_dsmotivo)  THEN
                                            aux_indposic = 1.
                    
                                        tel_dsmotivo =
                                            TRIM(ENTRY(aux_indposic,aux_dsmotivo)).
                    
                                        DISPLAY tel_dsmotivo WITH FRAME f_enc.
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
                LEAVE.

            END. /* FIM do DO WHILE TRUE */

            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                DO:
                    HIDE FRAME f_enc NO-PAUSE.
                    HIDE FRAME f_enc_pj NO-PAUSE.
                    NEXT.
                END.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                ASSIGN aux_confirma = "N"
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
                     
                    HIDE FRAME f_enc NO-PAUSE.
                    HIDE FRAME f_enc_pj NO-PAUSE.

                    NEXT.
                END.

            RUN sistema/generico/procedures/b1wgen0028.p 
                PERSISTENT SET h_b1wgen0028.

            /*carrega_representante*/
            
            RUN encerra_cartao IN h_b1wgen0028 (INPUT glb_cdcooper,
                                                INPUT 0, 
                                                INPUT 0, 
                                                INPUT glb_cdoperad,
                                                INPUT tel_nrdconta,
                                                INPUT par_nrctrcrd,
                                                INPUT aux_indposic,
                                                INPUT glb_dtmvtolt,
                                                INPUT 1, 
                                                INPUT 1, 
                                                INPUT glb_nmdatela,
                                                INPUT tel_repsolic,
                                                INPUT aux_cpfrepre[aux_indposi2],
                                               OUTPUT TABLE tt-erro).

            DELETE PROCEDURE h_b1wgen0028.

            HIDE FRAME f_enc NO-PAUSE.
            HIDE FRAME f_enc_pj NO-PAUSE.

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

            IF   aux_tipopess = 1 THEN 
                RUN fontes/encerracrd.p (INPUT par_nrctrcrd,
                                        INPUT par_nrcrcard,
                                        INPUT par_cdadmcrd).


            IF   aux_tipopess = 2 THEN
                 DO:
                        
                     RUN fontes/termos_pj.p PERSISTENT SET h_termos.

                     RUN termo_encerra_cartao IN h_termos ( INPUT glb_cdcooper,
                                                            INPUT glb_cdoperad,
                                                            INPUT glb_nmdatela,
                                                            INPUT tel_nrdconta,
                                                            INPUT glb_dtmvtolt,
                                                            INPUT par_nrctrcrd).
                    
                     DELETE PROCEDURE h_termos.
                 END.

        END.
    ELSE
    IF  FRAME-VALUE = tel_dsdesfaz  THEN
        DO:  
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                ASSIGN aux_confirma = "N"
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
                    
                    NEXT.
                END.

            RUN sistema/generico/procedures/b1wgen0028.p 
                PERSISTENT SET h_b1wgen0028.
            
            RUN desfaz_enc_cartao IN h_b1wgen0028 (INPUT glb_cdcooper,
                                                   INPUT 0,
                                                   INPUT 0,
                                                   INPUT glb_cdoperad,
                                                   INPUT tel_nrdconta,
                                                   INPUT par_nrctrcrd,
                                                   INPUT 0, /* par_indposic (nao utilizado) */
                                                   INPUT glb_dtmvtolt,
                                                   INPUT 1,
                                                   INPUT 1,
                                                   INPUT glb_nmdatela,
                                                   INPUT aux_cpfrepre[aux_indposi2],
                                                  OUTPUT aux_msgalert,
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

            IF  aux_msgalert <> ""  THEN
                DO:
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        MESSAGE aux_msgalert.
                        PAUSE.
                        LEAVE.
                    END.

                    HIDE MESSAGE NO-PAUSE.
                END.
        END. 
    LEAVE.
END. /* Fim do DO WHILE TRUE */

HIDE FRAME f_tit  NO-PAUSE.

RETURN "OK".

/* ......................................................................... */
