/*.............................................................................

   Programa: Fontes/sldccr_2vop.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Maio/2004                         Ultima atualizacao: 03/07/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para opcao de solicitar ou entregar um 2.a. Via de cartao

   Alteracoes: 18/06/2004 - Nao deixa entregar 2.via se nao tiver 
                            solicitado  (Julio) 

               21/10/2004 - Nao permitir solicitacao para cartao cancelado
                            (Julio)
               
               27/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
               
               19/06/2006 - Bloqueada opcao de 2via para Cartao BB (Diego).

               25/08/2008 - Opcao para gerar 2 via de senha (David).

               16/09/2008 - Se ja existe solicitacao para 2 via de senha, so 
                            permitir nova solicitacao 15 dias apos o ultimo
                            pedido (David).

               20/10/2008 - Nao permitir solicitacao de senha se cartao nao 
                            estiver em uso (David).

               26/12/2008 - Nao permitir solicitacao de 2via se o cartao nao
                            foi entregue ainda (David).

               09/02/2009 - Nao permitir solicitacao de 2via se situacao da
                            conta for encerrada -- cdsitdct <> 1 e 6 (David).
               
               17/02/2009 - Incluir log/sldccr.log (Gabriel).
               
               16/06/2009 - Alteracao para utilizacao de BOs - Temp-tables
                            (GATI - Eder)
                            
               12/08/2010 - Retorna foco para browser dos emprestimos quando 
                            solicita 2a.via de cartao ou de 2a.via de senha 
                            (Elton).
                            
               20/10/2010 - Alteracao para imprimir termo de pessoa jurica
                            (Gati - Daniel)
                            
               12/09/2011 - Incluir parametro para a chamada do 
                            fontes/sldccr_s2v.p (Ze/Fabricio).
                            
               05/12/2012 - Incluido parametro na verifica_acesso_2via
                            (David Kruger).
               
               29/05/2014 - Blooqueado opcao de 2 via de cartao, para cartoes
                            BANCOOB (Jean Michel).     
                            
               03/07/2014 - Alteração para impedir impressão quando cartão 
                            BANCOOB. (Lucas Lunelli)
.............................................................................*/

{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_sldccr.i }

DEF  INPUT PARAM par_nrctrcrd AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrcrcard AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_cdadmcrd AS INTE                                  NO-UNDO.

DEF VAR tel_dssolici AS CHAR INIT "Solicitar"   FORMAT "x(09)"         NO-UNDO.
DEF VAR tel_dsentreg AS CHAR INIT "Entregar"    FORMAT "x(08)"         NO-UNDO.
DEF VAR tel_dsdesfaz AS CHAR INIT "Desfazer"    FORMAT "x(08)"         NO-UNDO.
DEF VAR tel_2viadsnh AS CHAR INIT "2via Senha"  FORMAT "x(10)"         NO-UNDO.
DEF VAR tel_2viadcrd AS CHAR INIT "2via Cartao" FORMAT "x(11)"         NO-UNDO.

DEF VAR aux_flgsolic AS LOGI                                           NO-UNDO.
DEF VAR aux_flgdsfaz AS LOGI                                           NO-UNDO.

DEF VAR h_b1wgen0028 AS HANDLE                                         NO-UNDO.


DEF VAR aux_cpfrepre AS DEC EXTENT 3                                   NO-UNDO.
DEF VAR tel_repsolic AS CHAR FORMAT "x(40)"                            NO-UNDO.
DEF VAR aux_represen AS CHAR                                           NO-UNDO.
DEF VAR aux_indposi2 AS INTE INIT 1                                    NO-UNDO.

DEF   VAR aux_nmarqimp     AS CHAR                                   NO-UNDO.

DEF VAR aux_tipopess  AS INT                                         NO-UNDO.
DEFINE VARIABLE h_termos  AS HANDLE                                  NO-UNDO.

/***** Variaveis de impressao - utilizadas em impressao.i *****/
DEF   VAR aux_flgescra     AS LOGICAL                                NO-UNDO.
DEF   VAR par_flgfirst     AS LOGICAL INIT TRUE                      NO-UNDO.
DEF   VAR par_flgcance     AS LOGICAL                                NO-UNDO.
DEF   VAR aux_dscomand     AS CHAR                                   NO-UNDO.
DEF   VAR par_flgrodar     AS LOGICAL INIT TRUE                      NO-UNDO.
DEF   VAR aux_nmendter     AS CHAR FORMAT "x(20)"                    NO-UNDO.
DEF   VAR tel_dsimprim     AS CHAR FORMAT "x(8)" INIT "Imprimir"     NO-UNDO.
DEF   VAR tel_dscancel     AS CHAR FORMAT "x(8)" INIT "Cancelar"     NO-UNDO.


FORM SKIP(1)
     tel_dssolici AT  5
     HELP "Tecle <Entra> para confirmar ou <Fim> para retornar."
     tel_dsentreg AT 24
     HELP "Tecle <Entra> para confirmar ou <Fim> para retornar."
     tel_dsdesfaz AT 42
     HELP "Tecle <Entra> para confirmar ou <Fim> para retornar."
     SKIP(1)
     WITH ROW 14 COLUMN 8 OVERLAY CENTERED WIDTH 55
     NO-LABELS TITLE COLOR NORMAL " 2Via Cartao " FRAME f_opcao_cartao.
     
FORM SKIP(1)
     tel_dssolici AT  5
     HELP "Tecle <Entra> para confirmar ou <Fim> para retornar."
     tel_dsdesfaz AT 24
     HELP "Tecle <Entra> para confirmar ou <Fim> para retornar."
     SKIP(1)
     WITH ROW 14 COLUMN 8 OVERLAY CENTERED WIDTH 37
     NO-LABELS TITLE COLOR NORMAL " 2Via Senha " FRAME f_opcao_senha.     

FORM SKIP(1)
     tel_repsolic  LABEL "Representante Solicitante" FORMAT "x(30)" 
     HELP "Utilizar setas direita/esquerda para escolher Representante" SKIP (1)

     WITH SIDE-LABELS ROW 14
     OVERLAY CENTERED TITLE COLOR NORMAL " 2 Via " FRAME f_cartao_PJ.


FORM SKIP(1)
     tel_2viadsnh AT  5
     HELP "Tecle <Entra> para confirmar ou <Fim> para retornar."
     tel_2viadcrd AT 21
     HELP "Tecle <Entra> para confirmar ou <Fim> para retornar."
     SKIP(1)
     WITH ROW 14 COLUMN 8 OVERLAY CENTERED WIDTH 37 NO-LABELS 
     TITLE COLOR NORMAL " 2Via " FRAME f_2via_opcao.

RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h_b1wgen0028.

RUN verifica_acesso_2via IN h_b1wgen0028 (INPUT glb_cdcooper,
                                          INPUT 0, 
                                          INPUT 0, 
                                          INPUT glb_cdoperad,
                                          INPUT tel_nrdconta,
                                          INPUT par_nrctrcrd,
                                          INPUT glb_dtmvtolt,
                                          OUTPUT TABLE tt-erro).

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

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
    ASSIGN aux_flgsolic = FALSE
           aux_flgdsfaz = FALSE.
       
    DISPLAY tel_2viadsnh tel_2viadcrd WITH FRAME f_2via_opcao.
    
    CHOOSE FIELD tel_2viadsnh tel_2viadcrd WITH FRAME f_2via_opcao.

    HIDE MESSAGE NO-PAUSE.

    HIDE FRAME f_2via_opcao NO-PAUSE.
            
    IF  FRAME-VALUE = tel_2viadsnh  THEN /* 2a. via senha */
        DO:
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                DISPLAY tel_dssolici tel_dsdesfaz WITH FRAME f_opcao_senha.
               
                CHOOSE FIELD tel_dssolici tel_dsdesfaz
                             WITH FRAME f_opcao_senha.
               
                IF  FRAME-VALUE = tel_dssolici  THEN /* Solicitar */
                    DO:
                        IF   aux_tipopess = 2 THEN
                             DO:

                                 UPDATE tel_repsolic WITH FRAME f_cartao_PJ
                                 
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
                                         
                                                     DISPLAY tel_repsolic WITH FRAME f_cartao_PJ.
                                                 END.
                                     
                                            ELSE
                                            IF  KEYFUNCTION(LASTKEY) = "CURSOR-LEFT"  THEN
                                                DO:
                                                    aux_indposi2 = aux_indposi2 + 1.
                                         
                                                    IF  aux_indposi2 > NUM-ENTRIES(aux_represen)  THEN
                                                        aux_indposi2 = 1.
                                         
                                                    tel_repsolic =  TRIM(ENTRY(aux_indposi2,
                                                                               aux_represen)).
                                         
                                                    DISPLAY tel_repsolic WITH FRAME f_cartao_PJ.
                                                END.
                                            ELSE
                                            IF  LASTKEY =  KEYCODE(",")  THEN                         
                                                APPLY 46.                                             
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
                            END.

                        HIDE FRAME f_cartao_PJ NO-PAUSE.

                        RUN sistema/generico/procedures/b1wgen0028.p 
                            PERSISTENT SET h_b1wgen0028.

                        RUN efetua_solicitacao2via_senha IN h_b1wgen0028
                                          (INPUT glb_cdcooper,
                                           INPUT 0,
                                           INPUT 0,
                                           INPUT glb_cdoperad,
                                           INPUT tel_nrdconta,
                                           INPUT 1,
                                           INPUT 1,
                                           INPUT glb_nmdatela,
                                           INPUT glb_dtmvtolt,
                                           INPUT par_nrctrcrd,
                                           INPUT aux_cpfrepre[aux_indposi2],
                                           INPUT tel_repsolic,
                                          OUTPUT TABLE tt-erro).

                        DELETE PROCEDURE h_b1wgen0028.
               
                        IF  RETURN-VALUE = "NOK"  THEN
                            DO:
                                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                
                                IF  AVAIL tt-erro THEN
                                    DO:
                                        BELL.
                                        MESSAGE tt-erro.dscritic.
                                    END.

                                NEXT.
                            END.
               
                        MESSAGE "2.Via de senha solicitada.".

                        IF   aux_tipopess = 2 THEN
                             DO:
                                /* Se não for Bancoob */
                                IF  par_cdadmcrd < 10 OR
                                    par_cdadmcrd > 80 THEN
                                    DO:
                                    
                                        RUN fontes/termos_pj.p PERSISTENT SET h_termos.
                                            
                                        RUN segunda_via_senha_cartao IN h_termos (INPUT glb_cdcooper,
                                                                                  INPUT glb_cdoperad,
                                                                                  INPUT glb_nmdatela,
                                                                                  INPUT tel_nrdconta,
                                                                                  INPUT glb_dtmvtolt,
                                                                                  INPUT par_nrctrcrd).
        
                                        DELETE PROCEDURE h_termos.
                                    END.
                             END.
                    END. 
                ELSE
                IF  FRAME-VALUE = tel_dsdesfaz  THEN /* Desfazer */
                    DO:
                        RUN sistema/generico/procedures/b1wgen0028.p 
                            PERSISTENT SET h_b1wgen0028.
                        
                        RUN desfaz_solici2via_senha IN h_b1wgen0028
                                          (INPUT glb_cdcooper,
                                           INPUT 0,
                                           INPUT 0,
                                           INPUT glb_cdoperad,
                                           INPUT tel_nrdconta,
                                           INPUT 1,
                                           INPUT 1,
                                           INPUT glb_nmdatela,
                                           INPUT glb_dtmvtolt,
                                           INPUT par_nrctrcrd,
                                          OUTPUT TABLE tt-erro).
                         
                        DELETE PROCEDURE h_b1wgen0028.
               
                        IF  RETURN-VALUE = "NOK"  THEN
                            DO:
                                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                
                                IF  AVAIL tt-erro THEN
                                    DO:
                                        BELL.
                                        MESSAGE tt-erro.dscritic.
                                    END.

                                NEXT.
                            END.
                                                          
                        MESSAGE "Solicitacao de 2.Via de senha desfeita.".
                    END.    
               
                LEAVE. 

            END. /* Fim do DO WHILE TRUE */

            HIDE FRAME f_opcao_senha NO-PAUSE.
        END.
    ELSE
    IF  FRAME-VALUE = tel_2viadcrd  THEN /* 2a. via cartao */
        DO:
            IF par_cdadmcrd <= 80  AND
               par_cdadmcrd >= 10 THEN
                DO:
                    BELL.
                    MESSAGE "Opcao indisponivel para CARTOES BANCOOB".
                    NEXT.
                END.
            ELSE
                DO:

                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        
                        DISPLAY tel_dssolici tel_dsentreg tel_dsdesfaz 
                                WITH FRAME f_opcao_cartao.
            
                        CHOOSE FIELD tel_dssolici tel_dsentreg tel_dsdesfaz
                                     WITH FRAME f_opcao_cartao.
            
                        IF  FRAME-VALUE = tel_dssolici  THEN /* Solicitar */
                            DO:
                                HIDE FRAME f_opcao_cartao NO-PAUSE.
        
                                RUN fontes/sldccr_s2v.p (INPUT par_nrctrcrd,
                                                         INPUT par_nrcrcard,
                                                         INPUT par_cdadmcrd).
                                
                                IF  RETURN-VALUE = "NOK"  THEN
                                    NEXT.
                            END.
                        ELSE
                        IF  FRAME-VALUE = tel_dsentreg  THEN /* Entregar */
                            DO:
                                HIDE FRAME f_opcao_cartao NO-PAUSE.
        
                                RUN fontes/sldccr_2v.p (INPUT par_nrctrcrd,
                                                        INPUT par_cdadmcrd).
        
                                IF  RETURN-VALUE = "NOK"  THEN
                                    NEXT.
                            END.
                        ELSE
                        IF  FRAME-VALUE = tel_dsdesfaz  THEN /* Desfazer */
                            DO:
                                RUN sistema/generico/procedures/b1wgen0028.p 
                                    PERSISTENT SET h_b1wgen0028.
        
                                RUN desfaz_solici2via_cartao IN h_b1wgen0028
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
                            END.
                    
                        LEAVE.  
                        
                       
                    END. /* Fim do DO WHILE TRUE */
                    HIDE FRAME f_opcao_cartao NO-PAUSE.
                END.                                   
        END.
    RETURN "OK".
END. /* Fim do DO WHILE TRUE */

HIDE FRAME f_2via_opcao NO-PAUSE.

RETURN "OK".

/*...........................................................................*/
