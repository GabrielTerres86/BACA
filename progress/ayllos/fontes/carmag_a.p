/*.............................................................................

   Programa: Fontes/carmag_a.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Janeiro/99.                         Ultima atualizacao: 23/07/2015
     
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   
   Objetivo  : Rotina para alterar os dados do cartao magnetico solicitado.

   Alteracao:  28/12/2001 - Alterado para tratar a rotina ver_capital (Edson).
   
               30/07/2003 - Inclusao da rotina ver_cadastro (Julio).

               25/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando

               06/09/2006 - Excluidas opcoes "TAB" (Diego).

               10/09/2007 - Conversao de rotina ver_capital para BO 
                            (Sidnei/Precise)
                            
               05/03/2008 - Tratamentos para pessoa juridica (Guilherme).
               
               19/05/2009 - Alteracao para utilizacao de BOs - Temp-tables -
                            GATI - Eder
                            
               04/06/2009 - Novo parametro tpusucar, para permitir alteracao de
                            titular, na procedure alterar-cartao-magnetico 
                            (David).
                           
               23/07/2015 - Remover os campos Limite, Forma de Saque e Recido
                            de entrega. (James)            
............................................................................ */

{ sistema/generico/includes/b1wgen0032tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_carmag.i }

DEF  INPUT PARAM par_nrdconta AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrcartao AS DECI                                  NO-UNDO.

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
                              INPUT par_nrcartao,
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

        IF  tt-dados-carmag.tpcarcta = 9  THEN
            DO:
                DISPLAY tt-dados-carmag.dsusucar                        
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
            aux_confirma <> "S"                 THEN
            DO:
                glb_cdcritic = 79.
                RUN fontes/critic.p.
                glb_cdcritic = 0.
    
                BELL.
                MESSAGE glb_dscritic.
                
                LEAVE.
            END.
            
        RUN sistema/generico/procedures/b1wgen0032.p 
            PERSISTENT SET h_b1wgen0032.
        
        RUN alterar-cartao-magnetico IN h_b1wgen0032
                                    (INPUT glb_cdcooper,
                                     INPUT 0,
                                     INPUT 0,
                                     INPUT glb_cdoperad,   
                                     INPUT glb_nmdatela,
                                     INPUT 1,
                                     INPUT par_nrdconta,           
                                     INPUT 1, 
                                     INPUT glb_dtmvtolt,
                                     INPUT tt-dados-carmag.nrcartao,
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
                     END.
            
                NEXT.
            END.
                
        ASSIGN aux_flgalter = YES.  

        LEAVE.

    END. /* Fim do DO WHILE TRUE */
                         
    LEAVE.
   
END. /* Fim do DO WHILE TRUE */

HIDE FRAME f_cartao_magnetico  NO-PAUSE.
HIDE FRAME f_cartao_magnetico2 NO-PAUSE.

IF  aux_flgalter  THEN 
    RETURN "OK".
ELSE
    RETURN "NOK".

/* ......................................................................... */
