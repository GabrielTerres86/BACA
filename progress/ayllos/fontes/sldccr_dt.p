/* ............................................................................

   Programa: Fontes/sldccr_dt.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : junho/2004.                        Ultima atualizacao: 30/05/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para alteracao da data de vencimento de cartoes 
               de credito.

   Alteracoes: 09/09/2004 - Correcao de um erro na hora de alterar a data com
                            seta para cima (Julio)

               04/11/2004 - Incluir campos para assinatura do associado e do
                            operador (Julio)

               28/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               27/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.

               17/08/2006 - Incluida critica para nao realizar operacao se for
                            administradora BB (Diego).
                            
               12/09/2006 - Excluida opcao "TAB" (Diego).
                            
               27/09/2006 - Alterado texto referente ao campo A/C (Elton).
               
               25/04/2008 - Alimetar data de alteracao dia do debito(Guilherme)

               13/02/2009 - Criado log da data de vcto em sldccr.log (Gabriel).
                
               20/03/2009 - Permitir alteracao do vencimento somentes 30 dias
                            apos a data de entrega ou da ultima alteracao
                            (David).

               18/05/2009 - Gerar log mesmo quando operador alterar para a
                            mesma data de vencimento (David).
                            
               16/06/2009 - Alteracao para utilizacao de BOs - Temp-tables
                           (GATI - Eder)
                           
               20/10/2010 - Alteracao para imprimir termo de pessoa jurica
                          (Gati - Daniel).
                          
               05/09/2011 - Incluido a chamada da procedure alerta_fraude
                            (Adriano).
                            
               01/04/2013 - Retirado a chamada da procedure alerta_fraude
                            (Adriano).             
                            
               30/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
                          
............................................................................ */

{ sistema/generico/includes/b1wgen0028tt.i }
{ sistema/generico/includes/b1wgen0019tt.i }
{ sistema/generico/includes/b1wgen9999tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }
{ includes/var_atenda.i }

DEF  INPUT PARAM par_nrctrcrd AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrcrcard AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_cdadmcrd AS INTE                                  NO-UNDO.

DEF STREAM str_1. /* Carta de Solicitacao de Alteracao de data */

DEF VAR tel_dddebito AS INTE FORMAT "z9"                               NO-UNDO.

DEF VAR tel_dsimprim AS CHAR FORMAT "x(8)" INIT "Imprimir"             NO-UNDO.
DEF VAR tel_dscancel AS CHAR FORMAT "x(8)" INIT "Cancelar"             NO-UNDO.

DEF VAR aux_flgescra AS LOGI                                           NO-UNDO.

DEF VAR aux_indposic AS INTE INITIAL 1                                 NO-UNDO.

DEF VAR aux_dscomand AS CHAR                                           NO-UNDO.
DEF VAR aux_confirma AS CHAR FORMAT "!"                                NO-UNDO.
DEF VAR aux_nmendter AS CHAR FORMAT "x(20)"                            NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                           NO-UNDO.
DEF VAR aux_dddebito AS CHAR                                           NO-UNDO.

DEF VAR par_flgcance AS LOGI                                           NO-UNDO.
DEF VAR par_flgfirst AS LOGI INIT TRUE                                 NO-UNDO.
DEF VAR par_flgrodar AS LOGI INIT TRUE                                 NO-UNDO.

DEF VAR h_b1wgen0028 AS HANDLE                                         NO-UNDO.
DEF VAR h_Termos     AS HANDLE                                         NO-UNDO.

DEF   VAR aux_nmprimtl       AS CHAR                      NO-UNDO.
DEF   VAR aux_nomesoli       AS CHAR FORMAT "x(40)"       NO-UNDO.
DEFINE VARIABLE aux_desclin1 AS CHARACTER FORMAT "x(133)" NO-UNDO.
DEFINE VARIABLE aux_desclin2 AS CHARACTER FORMAT "x(133)" NO-UNDO.

DEFINE VARIABLE aux_retor1   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
DEFINE VARIABLE aux_retor2   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
DEFINE VARIABLE aux_retor3   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
DEFINE VARIABLE aux_retor4   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
DEFINE VARIABLE aux_retor5   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
DEFINE VARIABLE aux_retor6   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
DEFINE VARIABLE aux_retor7   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
DEFINE VARIABLE aux_retor8   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
DEFINE VARIABLE aux_nrcrcard AS DECI FORMAT "9999,9999,9999,9999" NO-UNDO.
DEFINE VARIABLE aux_nrcpfcgc AS CHAR FORMAT "x(40)"         NO-UNDO.
DEF VAR aux_tipopess  AS INT                                NO-UNDO.

DEF VAR aux_cpfrepre AS DEC EXTENT 3                                   NO-UNDO.
DEF VAR tel_repsolic AS CHAR FORMAT "x(40)"                            NO-UNDO.
DEF VAR aux_represen AS CHAR                                           NO-UNDO.
DEF VAR aux_indposi2 AS INTE INIT 1                                    NO-UNDO.

FORM " Aguarde... Imprimindo carta para alteracao de data! "
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.
                                                                      
FORM SKIP(1)                                                          
     par_nrcrcard LABEL "Numero do cartao" COLON 25 
                  FORMAT "9999,9999,9999,9999"
     "   "
     SKIP(1)
     tel_dddebito LABEL "Dia do debito"  COLON 25
                  HELP "Use as setas para escolher o dia para Debito."
     WITH SIDE-LABELS ROW 9
     OVERLAY CENTERED TITLE COLOR NORMAL 
             " Alteracao de Data de Vencimento " FRAME f_novadata.

FORM SKIP(1)                                                          
     par_nrcrcard LABEL "Numero do cartao" COLON 26 
                  FORMAT "9999,9999,9999,9999"
     "   "
     SKIP(1)
     tel_repsolic FORMAT "x(40)" LABEL "Representante Solicitante"
     HELP "Utilizar setas direita/esquerda para escolher Representante" SKIP(1)
     tel_dddebito LABEL "Dia do debito"  COLON 26
                  HELP "Use as setas para escolher o dia para Debito."
     WITH SIDE-LABELS ROW 10
     OVERLAY CENTERED TITLE COLOR NORMAL 
             " Alteracao de Data de Vencimento " FRAME f_novadata_pj.


DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   
    RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h_b1wgen0028.

   
    RUN carrega_dados_dtvencimento_cartao IN h_b1wgen0028
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
    

    RUN verifica_associado IN h_b1wgen0028 (INPUT glb_cdcooper,
                                            INPUT tel_nrdconta,
                                            OUTPUT aux_tipopess).

    DELETE PROCEDURE h_b1wgen0028.

    RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h_b1wgen0028.

   
    RUN carrega_representante IN h_b1wgen0028(INPUT glb_cdcooper,
                                              INPUT tel_nrdconta,  
                                              OUTPUT aux_represen,
                                              OUTPUT aux_cpfrepre).
     
    DELETE PROCEDURE h_b1wgen0028.
    
   
    ASSIGN tel_repsolic = ENTRY(1,aux_represen). 

    
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
    
          
    ASSIGN aux_dddebito = ENTRY(2,tt-dtvencimento_cartao.diasdadm,";")
           tel_dddebito = tt-dtvencimento_cartao.dddebito.

    IF   aux_tipopess <> 2 THEN
         DO:
             DISPLAY par_nrcrcard WITH FRAME f_novadata.
              
             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
             
                 UPDATE tel_dddebito WITH FRAME f_novadata
              
                 EDITING:
                 
                     READKEY. 
                     IF  KEYFUNCTION(LASTKEY) = "CURSOR-UP"     OR
                         KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT"  THEN
                         DO:
                             IF  aux_indposic > NUM-ENTRIES(aux_dddebito)  THEN
                                 aux_indposic = NUM-ENTRIES(aux_dddebito).
             
                             aux_indposic = aux_indposic - 1.
             
                             IF  aux_indposic <= 0  THEN
                                 aux_indposic = NUM-ENTRIES(aux_dddebito).
             
                             tel_dddebito = INT(ENTRY(aux_indposic,aux_dddebito)).
             
                             DISPLAY tel_dddebito WITH FRAME f_novadata.
                         END.
                     ELSE
                     IF  KEYFUNCTION(LASTKEY) = "CURSOR-DOWN"  OR
                         KEYFUNCTION(LASTKEY) = "CURSOR-LEFT"  THEN
                         DO: 
                             aux_indposic = aux_indposic + 1.
             
                             IF  aux_indposic > NUM-ENTRIES(aux_dddebito)  THEN
                                 aux_indposic = 1.
             
                             tel_dddebito = INT(ENTRY(aux_indposic,aux_dddebito)).
             
                             DISPLAY tel_dddebito WITH FRAME f_novadata.
                         END.
                     ELSE
                     IF  (KEYFUNCTION(LASTKEY) = "RETURN"    OR
                         KEYFUNCTION(LASTKEY) = "BACK-TAB"   OR
                         KEYFUNCTION(LASTKEY) = "GO"         OR
                         KEYFUNCTION(LASTKEY) = "END-ERROR") THEN 
                        
                         APPLY LASTKEY.  
                 END. /* EDITING */
             
                 LEAVE.
             
             END. /* Fim do DO WHILE TRUE */
         END.

   ELSE DO:
       DISPLAY par_nrcrcard tel_repsolic WITH FRAME f_novadata_pj.
        
       DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       
           UPDATE tel_repsolic tel_dddebito WITH FRAME f_novadata_pj
        
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
                       
                                DISPLAY tel_repsolic WITH FRAME f_novadata_pj.
                            END.
                       
                       ELSE
                       IF  KEYFUNCTION(LASTKEY) = "CURSOR-LEFT"  THEN
                           DO:
                               aux_indposi2 = aux_indposi2 + 1.
             
                               IF  aux_indposi2 > NUM-ENTRIES(aux_represen)  THEN
                                   aux_indposi2 = 1.
             
                               tel_repsolic =  TRIM(ENTRY(aux_indposi2,
                                                          aux_represen)).
             
                               DISPLAY tel_repsolic WITH FRAME f_novadata_pj.
                           END.
                       ELSE
                       IF  LASTKEY =  KEYCODE(",")  THEN
                           APPLY 44.
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
               IF  FRAME-FIELD = "tel_dddebito"  THEN
                   DO:

                       IF  KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT"  THEN
                           DO:
                               IF  aux_indposic > NUM-ENTRIES(aux_dddebito)  THEN
                                   aux_indposic = NUM-ENTRIES(aux_dddebito).

                               aux_indposic = aux_indposic - 1.

                               IF  aux_indposic <= 0  THEN
                                   aux_indposic = NUM-ENTRIES(aux_dddebito).

                               tel_dddebito = INT(ENTRY(aux_indposic,aux_dddebito)).

                               DISPLAY tel_dddebito WITH FRAME f_novadata_pj.
                           END.
                       ELSE
                       IF  KEYFUNCTION(LASTKEY) = "CURSOR-LEFT"  THEN
                           DO: 
                               aux_indposic = aux_indposic + 1.

                               IF  aux_indposic > NUM-ENTRIES(aux_dddebito)  THEN
                                   aux_indposic = 1.

                               tel_dddebito = INT(ENTRY(aux_indposic,aux_dddebito)).

                               DISPLAY tel_dddebito WITH FRAME f_novadata_pj.
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
               
           END. /* EDITING */
       
           LEAVE.
       END.
    END. 
             
    IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
        DO:
            HIDE FRAME f_novadata NO-PAUSE.
            HIDE FRAME f_novadata_pj NO-PAUSE.
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
            HIDE FRAME f_novadata_pj NO-PAUSE.
               
            RETURN "NOK".
        END.
 
    RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h_b1wgen0028.
    
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

    LEAVE.

END. /* DO WHILE TRUE */

RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h_b1wgen0028.

HIDE FRAME f_novadata NO-PAUSE.
HIDE FRAME f_novadata_pj NO-PAUSE.


IF  aux_tipopess = 2 THEN
    DO:
        RUN fontes/termos_pj.p PERSISTENT SET h_termos.

        RUN imprime_Alt_data_PJ IN h_termos (INPUT glb_cdcooper,
                                             INPUT glb_cdoperad,
                                             INPUT glb_nmdatela,
                                             INPUT glb_dtmvtolt,
                                             INPUT par_nrctrcrd,
                                             INPUT tel_nrdconta).
                    
        DELETE PROCEDURE h_termos.
         
     END.
ELSE 
     DO:

        VIEW FRAME f_aguarde.
    
        INPUT THROUGH basename `tty` NO-ECHO.
        SET aux_nmendter WITH FRAME f_terminal.
        INPUT CLOSE.
        
        aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                              aux_nmendter.
        
        RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h_b1wgen0028.

        RUN imprime_Alt_data_PF IN  h_b1wgen0028 ( INPUT glb_cdcooper,
                                                   INPUT 1, /* par_idorigem */
                                                   INPUT glb_cdoperad, 
                                                   INPUT glb_nmdatela,
                                                   INPUT tel_nrdconta,
                                                   INPUT glb_dtmvtolt,
                                                   INPUT glb_dtmvtopr,
                                                   INPUT glb_inproces,
                                                   INPUT par_nrctrcrd,
                                                   INPUT aux_nmendter,
                                                  OUTPUT aux_nmarqimp,
                                                  OUTPUT aux_nmarqpdf,
                                                  OUTPUT TABLE tt-erro).
        DELETE PROCEDURE h_b1wgen0028.

        IF  RETURN-VALUE = "NOK" THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
                IF  AVAILABLE tt-erro THEN
                    DO:
                        BELL.
                        MESSAGE tt-erro.dscritic.
                        PAUSE 3 NO-MESSAGE.
                        HIDE MESSAGE NO-PAUSE.
                    END.
    
                HIDE FRAME f_aguarde NO-PAUSE.
    
                RETURN "NOK".
            END.
         
        HIDE FRAME f_aguarde NO-PAUSE.

        ASSIGN glb_nrdevias = 1
               par_flgrodar = TRUE.
    
        FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                           crapass.nrdconta = tel_nrdconta NO-LOCK.

        { includes/impressao.i }
    
END.

HIDE FRAME f_novadata NO-PAUSE.
HIDE FRAME f_novadata_pj NO-PAUSE.

RETURN "OK".

/* ......................................................................... */
