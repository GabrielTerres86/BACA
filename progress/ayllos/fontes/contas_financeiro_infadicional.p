/* .............................................................................
 
   Programa: fontes/contas_financeiro_infadicional.p
   Sitema  : Cooperados - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze
   Data    : Setembro/2006                              Atualizacao: 09/11/2011

   Dados referentes ao programa:

   Frequencia: Diario (On-Line).
   Objetivo  : Efetuar manutencao dos dados financeiros - INF. ADICIONAIS.

   Alteracoes: 22/12/2006 - Corrigido o HIDE do frame (Evandro).
   
               14/07/2009 - Alteracao CDOPERAD (Diego).

               26/08/2009 - Arrumar tratamento da crapjfn e nome
                            da rotina (Gabriel) 
                            
               18/11/2009 - Utilizar BO b1wgen0048.p (David).
               
               04/12/2009 - Alterado layout do form e incluido novos campos
                            (Elton).
                            
               12/04/2010 - Utilizar procedure para revisao cadastral e 
                            adaptar alteracao acima (04/12) para BO (David).
                            
               03/05/2010 - Complementar a utilizacao de BO (Jose Luis, DB1)
               
               01/03/2011 - Alteracao dos valores de INPUT na funcao
                            BuscaTopico. (Fabricio)
                            
               09/11/2011 - Realizado ajuste para que os campos citados abaixo,
                            sejam obrigatorios estarem zerados quando for a 
                            central.
                            - Patr. pessoal dos garant. ou socios livre de onus
                            - Percepcao geral com relacao a empresa
                            (Adriano).
                            
               
............................................................................. */
{ sistema/generico/includes/b1wgen0048tt.i }
{ sistema/generico/includes/b1wgen0059tt.i &BD-GEN=SIM }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }
{ includes/var_contas.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-DESKTOP=SIM }

DEF VAR tel_dsinfadi AS CHAR EXTENT 05                                 NO-UNDO.
DEF VAR tel_dsinfcad AS CHAR                                           NO-UNDO. 
DEF VAR tel_dsperger AS CHAR                                           NO-UNDO.
DEF VAR tel_dspatlvr AS CHAR                                           NO-UNDO.
DEF VAR tel_nrinfcad AS INTE                                           NO-UNDO. 
DEF VAR tel_nrperger AS INTE                                           NO-UNDO.
DEF VAR tel_nrpatlvr AS INTE                                           NO-UNDO.

DEF VAR aux_nrdcampo AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_flgerlog AS LOGI                                           NO-UNDO.

DEF VAR reg_dsdopcao AS CHAR INIT "Alterar"                            NO-UNDO.

DEF VAR h-b1wgen0048 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0059 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0060 AS HANDLE                                         NO-UNDO.

FORM "Informacoes Cadastrais  : " AT 02 
     tel_nrinfcad  FORMAT "zz9" 
         HELP "Informe Informacao Cadastral ou pressione 'F7' para listar"
     tel_dsinfcad  FORMAT "x(45)"
     SKIP
     "Patr. pessoal dos garant. ou socios livre de onus: " AT 02 
     tel_nrpatlvr  FORMAT "zz9" 
         HELP "Informe Patrimonio Pessoal dos Garantidores ou 'F7' para listar."
     tel_dspatlvr  FORMAT "x(20)"    
     SKIP
     "Percepcao geral com relacao a empresa: " AT 02 
     tel_nrperger  FORMAT "zz9" 
         HELP "Informe Percepcao Geral com Relacao a Empresa ou 'F7'." 
     tel_dsperger  FORMAT "x(32)"
     SKIP(1)
     tel_dsinfadi[1] AT 02 NO-LABEL FORMAT "x(74)"
                     HELP "Pressione <END> para cancelar"
     SKIP
     tel_dsinfadi[2] AT 02 NO-LABEL FORMAT "x(74)"
                     HELP "Pressione <END> para cancelar"
     SKIP
     tel_dsinfadi[3] AT 02 NO-LABEL FORMAT "x(74)"     
                     HELP "Pressione <END> para cancelar"
     SKIP
     tel_dsinfadi[4] AT 02 NO-LABEL FORMAT "x(74)"     
                     HELP "Pressione <END> para cancelar"
     SKIP
     tel_dsinfadi[5] AT 02 NO-LABEL FORMAT "x(74)"     
                     HELP "Pressione <END> para cancelar"
     SKIP(1)                           
     reg_dsdopcao AT 36 FORMAT "x(07)"      NO-LABEL
                  HELP "Pressione ENTER para selecionar / F4 ou END para sair"
     WITH WIDTH 80 CENTERED ROW 9 OVERLAY TITLE " INFORMACOES ADICIONAIS "
          SIDE-LABELS NO-LABELS FRAME f_financeiro_infadicional.

DEF QUERY craprad-q FOR tt-craprad.

DEF BROWSE craprad-b QUERY craprad-q
    DISPLAY nrseqite COLUMN-LABEL "Item"
            dsseqite COLUMN-LABEL "Descricao" WITH 4 DOWN OVERLAY.

DEF FRAME f_craprad
          craprad-b HELP "Use as SETAS para navegar e <F4> para sair"  SKIP
          WITH NO-BOX CENTERED OVERLAY ROW 12 .

ON RETURN OF craprad-b IN FRAME f_craprad DO:

    HIDE MESSAGE NO-PAUSE.

    IF  NOT AVAILABLE tt-craprad   THEN
        NEXT.

    /*** Informacoes Cadastrais ***/
    IF  aux_nrdcampo = 1  THEN
        ASSIGN tel_nrinfcad = tt-craprad.nrseqite
               tel_dsinfcad = tt-craprad.dsseqite.
    ELSE /*** Patrimonio Pessoal Livre ***/
    IF  aux_nrdcampo = 2  THEN
        ASSIGN tel_nrpatlvr = tt-craprad.nrseqite
               tel_dspatlvr = tt-craprad.dsseqite.
    ELSE /*** Percepcao Geral da Empresa ***/
    IF  aux_nrdcampo = 3  THEN
        ASSIGN tel_nrperger = tt-craprad.nrseqite
               tel_dsperger = tt-craprad.dsseqite.
    APPLY "GO".

END.
   
/*** Informacoes Cadastrais ***/
ON LEAVE OF tel_nrinfcad IN FRAME f_financeiro_infadicional DO: 

    HIDE MESSAGE NO-PAUSE.

    ASSIGN INPUT tel_nrinfcad.

    IF  NOT DYNAMIC-FUNCTION("BuscaTopico" IN h-b1wgen0060,
                             INPUT glb_cdcooper,
                             INPUT 3,
                             INPUT 3,
                             INPUT tel_nrinfcad,
                            OUTPUT tel_dsinfcad,
                            OUTPUT aux_dscritic) THEN
        DO:
            MESSAGE aux_dscritic.
            RETURN NO-APPLY.
        END.

    DISPLAY tel_dsinfcad WITH FRAME f_financeiro_infadicional.

END.

/*** Patrimonio Livre ***/
ON LEAVE OF tel_nrpatlvr IN FRAME f_financeiro_infadicional DO: 

    HIDE MESSAGE NO-PAUSE.

    ASSIGN INPUT tel_nrpatlvr.


    IF glb_cdcooper = 3   AND 
       tel_nrpatlvr <> 0  THEN
       DO:
          MESSAGE "375 - O campo deve ser zerado.".
          RETURN NO-APPLY.

       END.
    ELSE
       DO:
          IF  NOT DYNAMIC-FUNCTION("BuscaTopico" IN h-b1wgen0060,
                                    INPUT glb_cdcooper,
                                    INPUT 3,
                                    INPUT 9,
                                    INPUT tel_nrpatlvr,
                                    OUTPUT tel_dspatlvr,
                                    OUTPUT aux_dscritic) THEN
              DO:
                  MESSAGE aux_dscritic.
                  RETURN NO-APPLY.
              END.
       
       END.

    DISPLAY tel_dspatlvr WITH FRAME f_financeiro_infadicional.

END.

/*** Percepcao Geral ***/
ON LEAVE OF tel_nrperger IN FRAME f_financeiro_infadicional DO: 

    HIDE MESSAGE NO-PAUSE.

    ASSIGN INPUT tel_nrperger.

    IF glb_cdcooper = 3   AND
       tel_nrperger <> 0  THEN
       DO:
          MESSAGE "375 - O campo deve ser zerado.".
          RETURN NO-APPLY.

       END.
    ELSE
       DO:                                                       
          IF  NOT DYNAMIC-FUNCTION("BuscaTopico" IN h-b1wgen0060,
                                   INPUT glb_cdcooper,
                                   INPUT 3,
                                   INPUT 11,
                                   INPUT tel_nrperger,
                                  OUTPUT tel_dsperger,
                                  OUTPUT aux_dscritic) THEN
              DO:
                  MESSAGE aux_dscritic.
                  RETURN NO-APPLY.

              END.
       
       END.

    DISPLAY tel_dsperger  WITH FRAME f_financeiro_infadicional.

END.

ASSIGN aux_flgerlog = TRUE.

DO WHILE TRUE:

    IF  NOT VALID-HANDLE(h-b1wgen0059)  THEN
        RUN sistema/generico/procedures/b1wgen0059.p 
            PERSISTENT SET h-b1wgen0059.

    IF  NOT VALID-HANDLE(h-b1wgen0060)  THEN  
        RUN sistema/generico/procedures/b1wgen0060.p 
            PERSISTENT SET h-b1wgen0060.
    
    IF  NOT VALID-HANDLE(h-b1wgen0048)  THEN
        RUN sistema/generico/procedures/b1wgen0048.p 
            PERSISTENT SET h-b1wgen0048.

    RUN obtem-informacoes-adicionais IN h-b1wgen0048 
                                    (INPUT glb_cdcooper, 
                                     INPUT 0,            
                                     INPUT 0,            
                                     INPUT glb_cdoperad, 
                                     INPUT glb_nmdatela, 
                                     INPUT 1,            
                                     INPUT tel_nrdconta, 
                                     INPUT tel_idseqttl,            
                                     INPUT aux_flgerlog, 
                                    OUTPUT TABLE tt-inf-adicionais,
                                    OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAILABLE tt-erro  THEN
                DO:
                    BELL.
                    MESSAGE tt-erro.dscritic.
                END.

            LEAVE.
        END.

    IF  aux_flgerlog  THEN
        ASSIGN aux_flgerlog = FALSE.

    ASSIGN tel_dsinfadi[01] = ""
           tel_dsinfadi[02] = ""
           tel_dsinfadi[03] = ""
           tel_dsinfadi[04] = ""
           tel_dsinfadi[05] = ""
           tel_nrinfcad     = 0   
           tel_nrperger     = 0
           tel_nrpatlvr     = 0
           tel_dsinfcad     = ""
           tel_dsperger     = ""
           tel_dspatlvr     = "".

    FIND FIRST tt-inf-adicionais NO-LOCK NO-ERROR.

    IF  AVAILABLE tt-inf-adicionais  THEN
        ASSIGN tel_dsinfadi[01] = tt-inf-adicionais.dsinfadi[01]
               tel_dsinfadi[02] = tt-inf-adicionais.dsinfadi[02]
               tel_dsinfadi[03] = tt-inf-adicionais.dsinfadi[03]
               tel_dsinfadi[04] = tt-inf-adicionais.dsinfadi[04]
               tel_dsinfadi[05] = tt-inf-adicionais.dsinfadi[05]
               tel_nrinfcad     = tt-inf-adicionais.nrinfcad 
               tel_nrperger     = tt-inf-adicionais.nrperger
               tel_nrpatlvr     = tt-inf-adicionais.nrpatlvr
               tel_dsinfcad     = tt-inf-adicionais.dsinfcad
               tel_dsperger     = tt-inf-adicionais.dsperger
               tel_dspatlvr     = tt-inf-adicionais.dspatlvr.
               
    DISPLAY tel_nrinfcad tel_dsinfcad 
            tel_nrperger tel_dsperger 
            tel_nrpatlvr tel_dspatlvr  
            tel_dsinfadi reg_dsdopcao 
            WITH FRAME f_financeiro_infadicional.
 
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        CHOOSE FIELD reg_dsdopcao WITH FRAME f_financeiro_infadicional.
        LEAVE.

    END.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        LEAVE.

    HIDE MESSAGE NO-PAUSE.

    ASSIGN glb_nmrotina = "FINANCEIRO-INF.ADICIONAIS"
           glb_cddopcao = "A".           
   
    { includes/acesso.i }     

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE tel_nrinfcad 
               tel_nrpatlvr 
               tel_nrperger   
               tel_dsinfadi WITH FRAME f_financeiro_infadicional

        EDITING:
            
            READKEY.
            HIDE MESSAGE NO-PAUSE.
            
            IF  LASTKEY = KEYCODE("F7")  THEN
                DO:
                    IF  FRAME-FIELD = "tel_nrinfcad"  THEN
                        DO:
                            ASSIGN aux_nrdcampo = 1.

                            RUN lista_informacoes.
                    
                            DISPLAY  tel_nrinfcad
                                     tel_dsinfcad WITH FRAME
                                     f_financeiro_infadicional.
                        END.
                    ELSE
                    IF  FRAME-FIELD = "tel_nrpatlvr"  THEN
                        DO:
                            ASSIGN aux_nrdcampo = 2.

                            RUN lista_informacoes.
                            
                            DISPLAY  tel_nrpatlvr
                                     tel_dspatlvr WITH FRAME
                                     f_financeiro_infadicional.
                        END.
                    ELSE
                    IF  FRAME-FIELD = "tel_nrperger"  THEN
                        DO:
                            ASSIGN aux_nrdcampo = 3.

                            RUN lista_informacoes.
                    
                            DISPLAY  tel_nrperger
                                     tel_dsperger WITH FRAME
                                     f_financeiro_infadicional.
                        END.
                END.
            ELSE
                APPLY LASTKEY. 
                
        END. /** Fim do EDITING **/

        RUN validar-informacoes-adicionais IN h-b1wgen0048 
                                          (INPUT glb_cdcooper,
                                           INPUT 0,           
                                           INPUT 0,           
                                           INPUT glb_cdoperad,
                                           INPUT glb_nmdatela,
                                           INPUT 1,           
                                           INPUT tel_nrdconta,
                                           INPUT tel_idseqttl,           
                                           INPUT TRUE,
                                           INPUT tel_nrinfcad, 
                                           INPUT tel_nrperger, 
                                           INPUT tel_nrpatlvr,
                                          OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE = "NOK"  THEN 
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.

                IF  AVAILABLE tt-erro  THEN 
                    DO:
                        BELL.
                        MESSAGE tt-erro.dscritic.
                    END.

                NEXT.
            END.

        LEAVE.

    END. /** Fim do DO WHILE TRUE **/
    
    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        NEXT.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        ASSIGN aux_confirma = "N"
               glb_cdcritic = 78.
        RUN fontes/critic.p.
        ASSIGN glb_cdcritic = 0.

        BELL.
        MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.

        LEAVE.

    END. /** Fim do DO WHILE TRUE **/

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  OR
        aux_confirma <> "S"                 THEN
        DO:
            ASSIGN glb_cdcritic = 79.
            RUN fontes/critic.p.
            ASSIGN glb_cdcritic = 0.

            BELL.
            MESSAGE glb_dscritic.
            
            NEXT.
        END.
    
    IF  VALID-HANDLE(h-b1wgen0048)  THEN
        DELETE OBJECT h-b1wgen0048.

    RUN sistema/generico/procedures/b1wgen0048.p PERSISTENT SET h-b1wgen0048.

    RUN atualizar-informacoes-adicionais IN h-b1wgen0048 
        (INPUT glb_cdcooper,
         INPUT 0,           
         INPUT 0,           
         INPUT glb_cdoperad,
         INPUT glb_nmdatela,
         INPUT 1,           
         INPUT tel_nrdconta,
         INPUT tel_idseqttl,
         INPUT glb_dtmvtolt,
         INPUT tel_dsinfadi[1],
         INPUT tel_dsinfadi[2],
         INPUT tel_dsinfadi[3],
         INPUT tel_dsinfadi[4],
         INPUT tel_dsinfadi[5],
         INPUT tel_nrinfcad, 
         INPUT tel_nrperger, 
         INPUT tel_nrpatlvr,
         INPUT TRUE,
        OUTPUT aux_tpatlcad, 
        OUTPUT aux_msgatcad, 
        OUTPUT aux_chavealt, 
        OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN 
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAILABLE tt-erro  THEN 
                DO:
                    BELL.
                    MESSAGE tt-erro.dscritic.
                END.

            NEXT.
        END.

    RUN proc_altcad (INPUT "b1wgen0048.p").

    IF  VALID-HANDLE(h-b1wgen0048)  THEN
        DELETE OBJECT h-b1wgen0048.

    IF  RETURN-VALUE <> "OK" THEN
        NEXT.

    BELL.
    MESSAGE "Alteracao efetuada com sucesso!".
    PAUSE 2 NO-MESSAGE.
    HIDE MESSAGE NO-PAUSE.

    NEXT.
    
END. /** Fim do DO WHILE TRUE **/

HIDE MESSAGE NO-PAUSE.

HIDE FRAME f_financeiro_infadicional NO-PAUSE.

IF  VALID-HANDLE(h-b1wgen0048) THEN
    DELETE PROCEDURE h-b1wgen0048.

IF  VALID-HANDLE(h-b1wgen0059) THEN
    DELETE PROCEDURE h-b1wgen0059.

IF  VALID-HANDLE(h-b1wgen0060) THEN
    DELETE PROCEDURE h-b1wgen0060.

/*............................................................................*/

PROCEDURE lista_informacoes:

    DEF VAR aux_nrtopico AS INTE                                    NO-UNDO.
    DEF VAR aux_nritetop AS INTE                                    NO-UNDO.
    DEF VAR aux_nrseqite AS INTE                                    NO-UNDO.
    DEF VAR aux_dsseqite AS CHAR                                    NO-UNDO.
    DEF VAR aux_qtregist AS INTE                                    NO-UNDO.

    CASE aux_nrdcampo:
        WHEN 1 THEN ASSIGN aux_nrtopico = 3
                           aux_nritetop = 3.
        WHEN 2 THEN ASSIGN aux_nrtopico = 3 
                           aux_nritetop = 9.
        WHEN 3 THEN ASSIGN aux_nrtopico = 3
                           aux_nritetop = 11.
    END CASE.

    RUN busca-craprad IN h-b1wgen0059 (INPUT glb_cdcooper,
                                       INPUT aux_nrtopico,
                                       INPUT aux_nritetop,
                                       INPUT aux_nrseqite,
                                       INPUT aux_dsseqite,
                                       INPUT TRUE,
                                       INPUT 99999,
                                       INPUT 1,
                                      OUTPUT aux_qtregist,
                                      OUTPUT TABLE tt-craprad).

    OPEN QUERY craprad-q FOR EACH tt-craprad NO-LOCK.

    UPDATE craprad-b WITH FRAME f_craprad.

END PROCEDURE.

/*............................................................................*/
