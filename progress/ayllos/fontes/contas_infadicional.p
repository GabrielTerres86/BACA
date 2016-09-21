/* .............................................................................
 
   Programa: fontes/contas_infadicional.p
   Sitema  : Cooperados - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Elton
   Data    : Dezembro/2009                              Atualizacao: 01/03/2011

   Dados referentes ao programa:

   Frequencia: Diario (On-Line).
   Objetivo  : Efetuar manutencao das Informacoes Adicionais.

   Alteracoes: 04/05/2010 - Adaptacao para uso de BO (Jose Luis, DB1)
   
               23/07/2010 - Incluir campo de observacao (Gabriel).
                
               01/03/2011 - "BuscaTopico" IN h-b1wgen0060, INPUT glb_cdcooper,
                            INPUT 3, INPUT 2 substituir por INPUT 1, INPUT 8.
                            Na PROCEDURE lista_informacoes substituir WHEN 2
                            THEN ASSIGN aux_nrtopico = 3 aux_nritetop = 2
                            por aux_nrtopico = 1 aux_nritetop = 8. (Fabricio)
               
............................................................................. */

{ sistema/generico/includes/b1wgen0048tt.i }
{ sistema/generico/includes/b1wgen0059tt.i &BD-GEN=SIM }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }
{ includes/var_contas.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-DESKTOP=SIM }

DEF VAR tel_nrinfcad AS INTE FORMAT "zz9"                              NO-UNDO.
DEF VAR tel_nrpatlvr AS INTE FORMAT "zz9"                              NO-UNDO.
DEF VAR tel_dsinfcad AS CHAR FORMAT "x(50)"                            NO-UNDO.
DEF VAR tel_dspatlvr AS CHAR FORMAT "x(25)"                            NO-UNDO.                                                                  
DEF VAR tel_dsinfadi AS CHAR FORMAT "x(74)" EXTENT 5                   NO-UNDO.

DEF VAR reg_dsdopcao AS CHAR FORMAT "x(07)" INIT "Alterar"             NO-UNDO.
                                                                    
DEF VAR aux_nrdcampo AS INTE                                           NO-UNDO. 
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
                                                                    
DEF VAR h-b1wgen0048 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0059 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0060 AS HANDLE                                         NO-UNDO.

FORM SKIP(1)
     "Informacoes cadastrais:" 
     tel_nrinfcad 
         HELP "Informe Informacao Cadastral ou pressione 'F7' para listar." 
     tel_dsinfcad                         
                                     
     "Patr. pessoal livre em relacao ao endividamento:" 
     tel_nrpatlvr  
         HELP "Informe patr. pessoal livre em relacao ao endividamento ou 'F7'."
     tel_dspatlvr
     SKIP(1)       
     tel_dsinfadi[1] AT 02 NO-LABEL FORMAT "x(74)"
         HELP "Pressione <END> para cancelar"
     tel_dsinfadi[2] AT 02 NO-LABEL FORMAT "x(74)"
          HELP "Pressione <END> para cancelar"
     tel_dsinfadi[3] AT 02 NO-LABEL FORMAT "x(74)"
          HELP "Pressione <END> para cancelar"
     tel_dsinfadi[4] AT 02 NO-LABEL FORMAT "x(74)"
          HELP "Pressione <END> para cancelar"
     tel_dsinfadi[5] AT 02 NO-LABEL FORMAT "x(74)"
          HELP "Pressione <END> para cancelar"
     SKIP(1)                              
     reg_dsdopcao AT 37 NO-LABEL
         HELP "Pressione ENTER para selecionar ou F4/END para sair"
     WITH NO-LABEL TITLE " INFORMACOES ADICIONAIS " ROW 9 WIDTH 80  
             OVERLAY CENTERED FRAME f_infadicional.
        
DEF QUERY craprad-q FOR tt-craprad.
                    
DEF BROWSE craprad-b QUERY craprad-q
    DISPLAY nrseqite COLUMN-LABEL "Item"
            dsseqite COLUMN-LABEL "Descricao" WITH 4 DOWN OVERLAY.
           
DEF FRAME f_craprad
          craprad-b HELP "Use as SETAS para navegar e <F4> para sair"  SKIP
          WITH NO-BOX CENTERED OVERLAY ROW 12 .
             
ON RETURN OF craprad-b IN FRAME f_craprad DO:

    HIDE MESSAGE NO-PAUSE.

    IF  NOT AVAILABLE tt-craprad  THEN
        NEXT.

    /*** Informacoes Cadastrais ***/
    IF  aux_nrdcampo = 1  THEN
        ASSIGN tel_nrinfcad = tt-craprad.nrseqite 
               tel_dsinfcad = tt-craprad.dsseqite.
    ELSE /*** Patrimonio Pessoal Livre ***/
    IF  aux_nrdcampo = 2  THEN
        ASSIGN tel_nrpatlvr = tt-craprad.nrseqite
               tel_dspatlvr = tt-craprad.dsseqite.
  
    APPLY "GO".           
              
END.           

/*** Informacoes Cadastrais ***/
ON LEAVE OF tel_nrinfcad IN FRAME f_infadicional DO: 

    HIDE MESSAGE NO-PAUSE.                           
    
    ASSIGN INPUT tel_nrinfcad.

    IF  NOT DYNAMIC-FUNCTION ("BuscaTopico" IN h-b1wgen0060,
                              INPUT glb_cdcooper,
                              INPUT 1,
                              INPUT 4,
                              INPUT tel_nrinfcad,
                             OUTPUT tel_dsinfcad,
                             OUTPUT aux_dscritic) THEN
        DO:
            MESSAGE aux_dscritic.
            RETURN NO-APPLY.
        END.
   
    DISPLAY tel_dsinfcad WITH FRAME f_infadicional.

END.

/*** Patrimonio Livre ***/
ON RETURN OF tel_nrpatlvr IN FRAME f_infadicional DO:

    HIDE MESSAGE NO-PAUSE.
   
    ASSIGN INPUT tel_nrpatlvr.

    IF  NOT DYNAMIC-FUNCTION ("BuscaTopico" IN h-b1wgen0060,
                              INPUT glb_cdcooper,
                              INPUT 1,
                              INPUT 8,
                              INPUT tel_nrpatlvr,
                             OUTPUT tel_dspatlvr,
                             OUTPUT aux_dscritic) THEN
        DO:
            MESSAGE aux_dscritic.
            RETURN NO-APPLY.
        END.

    DISPLAY tel_dspatlvr WITH FRAME f_infadicional.    
 
END.
 

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
                                     INPUT TRUE, 
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
   
    ASSIGN tel_nrinfcad = 0
           tel_dsinfcad = ""
           tel_nrpatlvr = 0
           tel_dspatlvr = ""
           tel_dsinfadi = "".

    FIND FIRST tt-inf-adicionais NO-LOCK NO-ERROR.
    
    IF  AVAILABLE tt-inf-adicionais  THEN
        ASSIGN tel_nrinfcad = tt-inf-adicionais.nrinfcad
               tel_dsinfcad = tt-inf-adicionais.dsinfcad
               tel_nrpatlvr = tt-inf-adicionais.nrpatlvr
               tel_dspatlvr = tt-inf-adicionais.dspatlvr
               tel_dsinfadi[1] = tt-inf-adicionais.dsinfadi[1]
               tel_dsinfadi[2] = tt-inf-adicionais.dsinfadi[2]
               tel_dsinfadi[3] = tt-inf-adicionais.dsinfadi[3]
               tel_dsinfadi[4] = tt-inf-adicionais.dsinfadi[4]
               tel_dsinfadi[5] = tt-inf-adicionais.dsinfadi[5].
                   
    DISPLAY tel_nrinfcad tel_dsinfcad 
            tel_nrpatlvr tel_dspatlvr  
            reg_dsdopcao tel_dsinfadi 
            WITH FRAME f_infadicional NO-ERROR.
   
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        CHOOSE FIELD reg_dsdopcao WITH FRAME f_infadicional.
        LEAVE.

    END.
    
    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        LEAVE.
            
    ASSIGN glb_nmrotina = "FINANCEIRO-INF.ADICIONAIS"
           glb_cddopcao = "A".
                                       
    { includes/acesso.i }

    HIDE MESSAGE NO-PAUSE.
                                       
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                   
        UPDATE tel_nrinfcad   
               tel_nrpatlvr 
               tel_dsinfadi WITH FRAME f_infadicional  
        
        EDITING:

            READKEY. 
            HIDE MESSAGE NO-PAUSE.
         
            IF  LASTKEY = KEYCODE("F7")  THEN 
                DO:
                    IF  FRAME-FIELD = "tel_nrinfcad"  THEN
                        DO:    
                            ASSIGN aux_nrdcampo = 1. 
                            
                            RUN lista_informacoes.
                                                   
                            DISPLAY tel_nrinfcad 
                                    tel_dsinfcad WITH FRAME f_infadicional.
                        END.
                    ELSE
                    IF  FRAME-FIELD = "tel_nrpatlvr"  THEN
                        DO:
                            ASSIGN aux_nrdcampo = 2. 
                        
                            RUN lista_informacoes.
                        
                            DISPLAY tel_nrpatlvr 
                                    tel_dspatlvr
                                    WITH FRAME f_infadicional.
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
                                           INPUT tel_nrinfcad, 
                                           INPUT 0, 
                                           INPUT tel_nrpatlvr,
                                           INPUT TRUE,
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
    
    END.  /** DO WHILE TRUE **/  

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        NEXT.

    RUN fontes/confirma.p (INPUT "",
                           OUTPUT aux_confirma).
    
    IF  aux_confirma <> "S"  THEN
        NEXT.        
    
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
                                             INPUT 0, 
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
    
END. /** Fim DO WHILE TRUE **/
                       
HIDE MESSAGE NO-PAUSE.

HIDE FRAME f_infadicional NO-PAUSE.

IF  VALID-HANDLE(h-b1wgen0048) THEN
    DELETE PROCEDURE h-b1wgen0048.

IF  VALID-HANDLE(h-b1wgen0059) THEN
    DELETE PROCEDURE h-b1wgen0059.

IF  VALID-HANDLE(h-b1wgen0060) THEN
    DELETE PROCEDURE h-b1wgen0060.

/*............................................................................*/

PROCEDURE lista_informacoes.

    DEF VAR aux_nrtopico AS INTE                                    NO-UNDO.
    DEF VAR aux_nritetop AS INTE                                    NO-UNDO.
    DEF VAR aux_nrseqite AS INTE                                    NO-UNDO.
    DEF VAR aux_dsseqite AS CHAR                                    NO-UNDO.
    DEF VAR aux_qtregist AS INTE                                    NO-UNDO.

    CASE aux_nrdcampo:
        WHEN 1 THEN ASSIGN aux_nrtopico = 1
                           aux_nritetop = 4.
        WHEN 2 THEN ASSIGN aux_nrtopico = 1 
                           aux_nritetop = 8.
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


