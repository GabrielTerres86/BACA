/* ........................................................................... 

   Programa: Fontes/carmag_i.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Janeiro/99.                     Ultima atualizacao: 23/07/2015
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para inclusao de solicitacao de cartoes magneticos
               de C/C (Edson)    

   Alteracoes: 23/10/2000 - Desmembrar a critica 95 conforme a situacao do
                            titular (Eduardo).

               28/12/2001 - Alterado para tratar a rotina ver_capital (Edson).
               
               30/01/2003 - Alterar opcao de emitir recibo de saque para TRUE
                            (Junior).

               30/07/2003 - Inclusao da rotina ver_cadastro (Julio) 

               01/09/2003 - Tratamento para Segundo titular "corrige_segntl" 
                            (Julio). 

               02/02/2004 - Chamar a rotina ver_cadastro somente para os tipos
                            de cartao igual a 1 (Edson).
               
               06/04/2005 - Permitir solicitacao de cartao apenas para as
                            cooperativas que tem cash dispenser (Edson).

               27/06/2005 - Alimentado campo cdcooper da tabela crapcrm (Diego)

               26/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando

               06/09/2006 - Exluidas opcoes "TAB" (Diego).
               
               22/12/2006 - Incluido campo flgcrmag para consulta da utilizacao
                            de cartao magnetico pela cooperativa (Elton).
                            
               28/03/2007 - Alterar prazo de vencimento para 5 anos (David).

               10/09/2007 - Conversao de rotina ver_capital para BO 
                            (Sidnei/Precise)

               10/10/2007 - Nrsencar para 2000000. Alterado para conseguirmos
                            diferenciar os cartoes solicitados pela tela
                            dos solicitados pelo sistema para cobranca de
                            tarifa de 2 via (Magui).
                            
               05/03/2008 - Tratamentos para pessoa juridica 
                          - Colocado em comentario a ATUALIZACAO do preposto
                            temporariamente. (Guilherme).

               09/06/2008 - Verificacao de tipo de pessoa a partir do 
                            par_inpessoa (Guilherme).
                            
               19/05/2009 - Alteracao para utilizacao de BOs - Temp-tables -
                            GATI - Eder             
                            
               23/07/2015 - Remover os campos Limite, Forma de Saque e Recido
                            de entrega. (James)
............................................................................ */

{ sistema/generico/includes/b1wgen0032tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_carmag.i }
{ includes/gg0000.i }

DEF  INPUT PARAM par_nrdconta AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_tptitcar AS INTE                                  NO-UNDO.

DEF VAR aux_flgalter AS LOGI INIT FALSE                                NO-UNDO.

DO WHILE TRUE:

    RUN sistema/generico/procedures/b1wgen0032.p PERSISTENT SET h_b1wgen0032.
   
    RUN obtem-permissao-solicitacao IN h_b1wgen0032
                                (INPUT glb_cdcooper,
                                 INPUT 0,
                                 INPUT 0,
                                 INPUT glb_cdoperad,   
                                 INPUT glb_nmdatela,
                                 INPUT 1,
                                 INPUT par_nrdconta,
                                 INPUT 1,
                                 INPUT glb_dtmvtolt,
                                 INPUT 0,
                                 INPUT YES,
                                OUTPUT TABLE tt-erro,
                                OUTPUT TABLE tt-dados-carmag,
                                OUTPUT TABLE tt-titular-magnetico).

    DELETE PROCEDURE h_b1wgen0032.                              
                                         
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  AVAIL tt-erro  THEN
                DO:
                    BELL.
                    MESSAGE tt-erro.dscritic.
                END.

            LEAVE.
        END.
             
    FIND FIRST tt-dados-carmag NO-ERROR.
    
    IF  NOT AVAIL tt-dados-carmag  THEN
        LEAVE.
        
    IF  tt-dados-carmag.inpessoa > 1  THEN 
        DO:
            RUN sistema/generico/procedures/b1wgen0032.p 
                PERSISTENT SET h_b1wgen0032.
            
            RUN obtem-prepostos IN h_b1wgen0032
                                      (INPUT glb_cdcooper,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT glb_cdoperad,   
                                       INPUT glb_nmdatela,
                                       INPUT 1,
                                       INPUT par_nrdconta,
                                       INPUT 1,
                                       INPUT YES, 
                                      OUTPUT TABLE tt-erro,
                                      OUTPUT TABLE tt-preposto-carmag).
            
            DELETE PROCEDURE h_b1wgen0032.
            
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                    
                    IF  AVAIL tt-erro  THEN
                        DO:
                            BELL.
                            MESSAGE tt-erro.dscritic.
                        END.

                    LEAVE.
                END.

            FIND tt-preposto-carmag WHERE
                 tt-preposto-carmag.flgatual NO-ERROR.

            ASSIGN tel_nmdavali = IF  AVAILABLE tt-preposto-carmag  THEN
                                      tt-preposto-carmag.nmdavali
                                  ELSE
                                      ""
                   tel_nmdavanv = "".
                               
            OPEN QUERY q_procuradores FOR EACH tt-preposto-carmag NO-LOCK.
            
            IF  NUM-RESULTS("q_procuradores") = 0  THEN 
                DO:
                    glb_cdcritic = 911.
                    RUN fontes/critic.p.
                    MESSAGE glb_dscritic.
                    glb_cdcritic = 0.
                    NEXT.
                END.
                    
            DISPLAY tel_nmdavali tel_nmdavanv WITH FRAME f_procurad.
                      
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
                UPDATE b_procuradores WITH FRAME f_procurad.
                LEAVE.
                
            END.
             
            HIDE FRAME f_procurad NO-PAUSE.
            
            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  OR
                aux_confirma <> "S"                 THEN
                DO:
                    ASSIGN glb_cdcritic = 79.
                    RUN fontes/critic.p.
                    ASSIGN glb_cdcritic = 0.

                    BELL.
                    MESSAGE glb_dscritic.
                
                    LEAVE.
                END.
                                           
            HIDE MESSAGE NO-PAUSE.
               
        END. 
        
    FIND tt-titular-magnetico WHERE tt-titular-magnetico.tpusucar = 1 NO-ERROR.
    
    IF  AVAIL tt-titular-magnetico  THEN
        ASSIGN tt-dados-carmag.tpusucar = tt-titular-magnetico.tpusucar
               tt-dados-carmag.dsusucar = tt-titular-magnetico.dsusucar
               tt-dados-carmag.nmtitcrd = tt-titular-magnetico.nmtitcrd.
        
    IF  tt-dados-carmag.inpessoa = 1  THEN
        DISP tt-dados-carmag.dsusucar   tt-dados-carmag.nmtitcrd
             tt-dados-carmag.nrcartao   tt-dados-carmag.nrseqcar            
             tt-dados-carmag.dtemscar   tt-dados-carmag.dscarcta   
             tt-dados-carmag.dtvalcar   tt-dados-carmag.dssitcar   
             tt-dados-carmag.dtentcrm   tt-dados-carmag.dtcancel   
             tt-dados-carmag.dttransa   tt-dados-carmag.hrtransa   
             tt-dados-carmag.nmoperad
             WITH FRAME f_cartao_magnetico.
    ELSE
        DISP tt-dados-carmag.nmtitcrd
             tt-dados-carmag.nrcartao   tt-dados-carmag.nrseqcar
             tt-dados-carmag.dtemscar   tt-dados-carmag.dscarcta   
             tt-dados-carmag.dtvalcar   tt-dados-carmag.dssitcar   
             tt-dados-carmag.dtentcrm   tt-dados-carmag.dtcancel   
             tt-dados-carmag.dttransa   tt-dados-carmag.hrtransa   
             tt-dados-carmag.nmoperad
             WITH FRAME f_cartao_magnetico2.
        
    ASSIGN aux_inposusu = tt-dados-carmag.tpusucar.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
        IF  par_tptitcar = 9  THEN
            DO:
                DISPLAY tt-dados-carmag.dsusucar
                        tt-dados-carmag.dtentcrm
                        WITH FRAME f_cartao_magnetico.

                UPDATE tt-dados-carmag.nmtitcrd WITH FRAME f_cartao_magnetico.
            END.
        ELSE
        IF  tt-dados-carmag.inpessoa = 1  THEN
            DO:
                UPDATE tt-dados-carmag.dsusucar   tt-dados-carmag.nmtitcrd                      
                       WITH FRAME f_cartao_magnetico

                EDITING:

                    READKEY.
                        
                    IF  FRAME-FIELD = "dsusucar"  THEN
                        DO: 
                            IF  KEYFUNCTION(LASTKEY) = "CURSOR-UP"     OR
                                KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT"  OR
                                KEYFUNCTION(LASTKEY) = "CURSOR-DOWN"   OR
                                KEYFUNCTION(LASTKEY) = "CURSOR-LEFT"   THEN
                                DO:  
                                    IF  aux_inposusu = 1  THEN
                                        aux_inposusu = 2.
                                    ELSE
                                        aux_inposusu = 1.
                                                   
                                    FIND tt-titular-magnetico WHERE
                                         tt-titular-magnetico.tpusucar =
                                                        aux_inposusu NO-ERROR.
                                
                                    IF  AVAIL tt-titular-magnetico  THEN
                                        ASSIGN tt-dados-carmag.tpusucar =
                                                 tt-titular-magnetico.tpusucar
                                               tt-dados-carmag.dsusucar = 
                                                 tt-titular-magnetico.dsusucar
                                               tt-dados-carmag.nmtitcrd =
                                                 tt-titular-magnetico.nmtitcrd.
 
                                    DISPLAY tt-dados-carmag.dsusucar
                                            tt-dados-carmag.nmtitcrd
                                            WITH FRAME f_cartao_magnetico.
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
        ELSE
            DO:
                DISPLAY tt-dados-carmag.nmtitcrd
                        WITH FRAME f_cartao_magnetico2.
            END. 
        
        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
     
            ASSIGN aux_confirma = "N"
                   glb_cdcritic = 78.
            RUN fontes/critic.p.
            glb_cdcritic = 0.
            
            BELL.
            MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
   
            LEAVE.
          
        END.
      
        IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  OR
            aux_confirma        <> "S"          THEN
            DO:
                glb_cdcritic = 79.
                RUN fontes/critic.p.
                glb_cdcritic = 0.

                BELL.
                MESSAGE glb_dscritic.
                
                LEAVE.
            END.
           
        ASSIGN tt-dados-carmag.tpusucar = IF tt-dados-carmag.tpusucar > 0 THEN
                                             tt-dados-carmag.tpusucar
                                          ELSE 
                                             1.
   
        RUN sistema/generico/procedures/b1wgen0032.p 
            PERSISTENT SET h_b1wgen0032.
      
        RUN incluir-cartao-magnetico IN h_b1wgen0032
                                (INPUT glb_cdcooper,
                                 INPUT 0,
                                 INPUT 0,
                                 INPUT glb_cdoperad,   
                                 INPUT glb_nmdatela,
                                 INPUT 1,
                                 INPUT par_nrdconta,
                                 INPUT 1,
                                 INPUT glb_dtmvtolt,
                                 INPUT par_tptitcar, 
                                 INPUT tt-dados-carmag.tpusucar,
                                 INPUT tt-dados-carmag.nmtitcrd,                                 
                                 INPUT YES,
                                OUTPUT TABLE tt-erro).
      
        DELETE PROCEDURE h_b1wgen0032.
   
        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                
                IF  AVAIL tt-erro  THEN
                    DO:
                        BELL.
                        MESSAGE tt-erro.dscritic.
                        NEXT.
                    END.
            END.
   
        ASSIGN aux_flgalter = YES.
   
        LEAVE.
      
    END. /* DO WHILE TRUE */     
   
    LEAVE.

END. /* DO WHILE TRUE */

HIDE FRAME f_cartao_magnetico  NO-PAUSE.
HIDE FRAME f_cartao_magnetico2 NO-PAUSE.

IF  NOT aux_flgalter  THEN    
    RETURN "NOK".

/* imprime o termo de responsabilidade para pessoa juridica */
IF  tt-dados-carmag.inpessoa <> 1  THEN 
    RUN fontes/carmag_j.p (INPUT par_nrdconta).
     
IF  aux_flgalter  THEN 
    RETURN "OK".
ELSE
    RETURN "NOK".

/* ......................................................................... */
