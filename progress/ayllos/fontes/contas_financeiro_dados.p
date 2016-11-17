/* .............................................................................

   Programa: fontes/contas_financeiro_dados.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo
   Data    : Junho/2006                         Ultima Atualizacao: 05/05/2010

   Dados referentes ao programa:
   
   Frequencia: Diario (on-line)
   Objetivo  : Efetuar manutencao dos dados financeiros do Associado.

   Alteracoes: 26/01/2006 - Unificacao dos Bancos - SQLWorks - Andre

               22/12/2006 - Corrigido o HIDE do frame (Evandro).
               
               16/07/2009 - Alteracao CDOPERAD (Diego).
               
               05/05/2010 - Adapatacao para uso de BO (Jose Luis, DB1)

..............................................................................*/
{ includes/var_online.i }
{ includes/var_contas.i }
{ sistema/generico/includes/b1wgen0066tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-DESKTOP=SIM }

DEF         VAR tel_vlcxbcaf LIKE crapjfn.vlcxbcaf                  NO-UNDO.
DEF         VAR tel_vlctarcb LIKE crapjfn.vlctarcb                  NO-UNDO.
DEF         VAR tel_vlrestoq LIKE crapjfn.vlrestoq                  NO-UNDO.
DEF         VAR tel_vloutatv LIKE crapjfn.vloutatv                  NO-UNDO.
DEF         VAR tel_vlrimobi LIKE crapjfn.vlrimobi                  NO-UNDO.
DEF         VAR tel_vlfornec LIKE crapjfn.vlfornec                  NO-UNDO.
DEF         VAR tel_vloutpas LIKE crapjfn.vloutpas                  NO-UNDO.
DEF         VAR tel_vldivbco LIKE crapjfn.vldivbco                  NO-UNDO.
DEF         VAR tel_dtaltjfn AS DATE FORMAT "99/99/9999"            NO-UNDO.
DEF         VAR tel_cdopejfn AS CHAR FORMAT "x(10)"                 NO-UNDO.
DEF         VAR tel_nmoperad AS CHAR FORMAT "x(11)"                 NO-UNDO.
DEF         VAR reg_dsdopcao AS CHAR FORMAT "x(07)" INIT "Alterar"  NO-UNDO.
DEF         VAR aux_flgsuces AS LOGICAL                             NO-UNDO.
DEF         VAR h-b1wgen0066 AS HANDLE                              NO-UNDO.
DEF         VAR tel_mesdbase AS INT FORMAT "99"                     NO-UNDO.
DEF         VAR tel_anodbase AS INT FORMAT "9999"                   NO-UNDO.

FORM SKIP
     "Data Base:"  AT 60   
     tel_mesdbase  AT 71   NO-LABEL
                           HELP "Informe o mes da data base"
                           VALIDATE(tel_mesdbase >= 1 AND tel_mesdbase <= 12,
                                    "013 - Data errada.")
     "/"           AT 73
     tel_anodbase  AT 74   NO-LABEL
                           HELP "Informe o ano da data base"
                           VALIDATE(tel_anodbase >= 1970 AND 
                                    tel_anodbase <= 2040,"013 - Data errada.")
     SKIP
"----------------------- Contas Ativas(Valores em R$) -------------------------"
     SKIP
     tel_vlcxbcaf  AT 01   LABEL "Caixa,Bancos,Aplicacoes"
                   HELP "Informe o valor do caixa, bancos e aplicacoes"
     tel_vlctarcb  AT 46   LABEL "Contas a Receber"
                   HELP "Informe o valor total de contas a receber"
     SKIP
     tel_vlrestoq  AT 16   LABEL "Estoques"
                   HELP "Informe o valor total dos estoques"
     tel_vloutatv  AT 49   LABEL "Outros Ativos"
                   HELP "Informe o valor total de outros ativos"
     SKIP
     tel_vlrimobi  AT 13   LABEL "Imobilizado"
                   HELP "Informe o valor total do imobilizado"
     SKIP
"---------------------- Contas Passivas(Valores em R$) ------------------------"
     SKIP
     tel_vlfornec  AT 12   LABEL "Fornecedores"
                  HELP "Informe o somatorio dos valores a pagar p/ fornecedores"
     tel_vloutpas  AT 47   LABEL "Outros Passivos"
                   HELP "Informe o valor total de outros passivos"
     SKIP
     tel_vldivbco  AT 02   LABEL "Endividamento Bancario"
                          HELP "Informe o valor total de endividamento bancario"
     SKIP(1)
     "Dados Ativas/Passivas =>"
     tel_dtaltjfn          LABEL "Alterado" 
     tel_cdopejfn          LABEL "Operador"    
     tel_nmoperad 
     SKIP(1)
     reg_dsdopcao  AT 35   NO-LABEL
                   HELP "Pressione ENTER para selecionar / F4 ou END para sair"
     WITH ROW 08 OVERLAY SIDE-LABELS NO-LABELS
          TITLE " ATIVO/PASSIVO " CENTERED FRAME f_dados_financeiro.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
   IF  NOT VALID-HANDLE(h-b1wgen0066) THEN
       RUN sistema/generico/procedures/b1wgen0066.p 
           PERSISTENT SET h-b1wgen0066.

   RUN Busca_Dados IN h-b1wgen0066
       ( INPUT glb_cdcooper, 
         INPUT 0,            
         INPUT 0,            
         INPUT glb_cdoperad, 
         INPUT glb_nmdatela, 
         INPUT 1,            
         INPUT tel_nrdconta, 
         INPUT tel_idseqttl, 
         INPUT YES,
        OUTPUT TABLE tt-atvpass,
        OUTPUT TABLE tt-erro) .

   IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
       DO:
          FIND FIRST tt-erro NO-ERROR.

          IF  AVAILABLE tt-erro THEN
              DO:
                 MESSAGE tt-erro.dscritic.
                 LEAVE.
              END.
       END.

   FIND FIRST tt-atvpass NO-ERROR.

   IF  AVAILABLE tt-atvpass THEN
       ASSIGN tel_mesdbase = tt-atvpass.mesdbase
              tel_anodbase = tt-atvpass.anodbase
              tel_vlcxbcaf = tt-atvpass.vlcxbcaf
              tel_vlctarcb = tt-atvpass.vlctarcb
              tel_vlrestoq = tt-atvpass.vlrestoq
              tel_vloutatv = tt-atvpass.vloutatv
              tel_vlrimobi = tt-atvpass.vlrimobi
              tel_vlfornec = tt-atvpass.vlfornec
              tel_vloutpas = tt-atvpass.vloutpas
              tel_vldivbco = tt-atvpass.vldivbco
              tel_dtaltjfn = tt-atvpass.dtaltjfn
              tel_cdopejfn = tt-atvpass.cdopejfn
              tel_nmoperad = tt-atvpass.nmoperad.
   
   DISPLAY   tel_mesdbase    tel_anodbase    tel_vlcxbcaf    
             tel_vlctarcb    tel_vlrestoq    tel_vloutatv    
             tel_vlrimobi    tel_vlfornec    tel_vloutpas    
             tel_vldivbco    tel_dtaltjfn    tel_cdopejfn    
             tel_nmoperad    reg_dsdopcao    WITH FRAME f_dados_financeiro.
             
   CHOOSE FIELD reg_dsdopcao WITH FRAME f_dados_financeiro.

   IF   FRAME-FIELD = "reg_dsdopcao"   THEN
        DO TRANSACTION:
        
           ASSIGN glb_nmrotina = "FINANCEIRO-ATIVO/PASSIVO"
                  glb_cddopcao = "A".
           
           { includes/acesso.i }
            
           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

              UPDATE  tel_mesdbase  tel_anodbase  tel_vlcxbcaf  
                      tel_vlctarcb  tel_vlrestoq  tel_vloutatv  
                      tel_vlrimobi  tel_vlfornec  tel_vloutpas  
                      tel_vldivbco  WITH FRAME f_dados_financeiro
              EDITING:
           
                  READKEY.
                  HIDE MESSAGE NO-PAUSE.
               
                  IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                       UNDO, LEAVE.
                  ELSE
                       APPLY LASTKEY.
              
              END.  /*  Fim do EDITING  */

              RUN Valida_Dados IN h-b1wgen0066
                  ( INPUT glb_cdcooper, 
                    INPUT 0,            
                    INPUT 0,            
                    INPUT glb_cdoperad, 
                    INPUT glb_nmdatela, 
                    INPUT 1,            
                    INPUT tel_nrdconta, 
                    INPUT tel_idseqttl, 
                    INPUT YES,
                    INPUT tel_mesdbase,
                    INPUT tel_anodbase,
                    INPUT glb_dtmvtolt,
                   OUTPUT TABLE tt-erro ) .

              IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
                  DO:
                     FIND FIRST tt-erro NO-ERROR.

                     IF  AVAILABLE tt-erro THEN
                         DO:
                            MESSAGE tt-erro.dscritic.
                            NEXT.
                         END.
                  END.

              LEAVE.
           END.   

           ASSIGN tel_cdopejfn = glb_cdoperad.

           DISPLAY tel_mesdbase    tel_anodbase    tel_vlcxbcaf    
                   tel_vlctarcb    tel_vlrestoq    tel_vloutatv    
                   tel_vlrimobi    tel_vlfornec    tel_vloutpas    
                   tel_vldivbco    tel_dtaltjfn    tel_cdopejfn    
                   tel_nmoperad    reg_dsdopcao   
                   WITH FRAME f_dados_financeiro.

           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

              ASSIGN aux_confirma = "N"
                     glb_cdcritic = 78.
              RUN fontes/critic.p.
              BELL.
              glb_cdcritic = 0.
              MESSAGE COLOR NORMAL glb_dscritic
              UPDATE aux_confirma.
              LEAVE.

           END.  /*  Fim do DO WHILE TRUE  */

           IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                aux_confirma <> "S"                  THEN
                DO:
                    glb_cdcritic = 79.
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    glb_cdcritic = 0.
                    PAUSE 2 NO-MESSAGE.
                    HIDE MESSAGE NO-PAUSE.
                    UNDO, NEXT.
                END.
           ELSE 
                DO:
                   IF  VALID-HANDLE(h-b1wgen0066) THEN
                       DELETE OBJECT h-b1wgen0066.

                   RUN sistema/generico/procedures/b1wgen0066.p 
                       PERSISTENT SET h-b1wgen0066.

                   RUN Grava_Dados IN h-b1wgen0066
                       ( INPUT glb_cdcooper, 
                         INPUT 0,            
                         INPUT 0,            
                         INPUT glb_cdoperad, 
                         INPUT glb_nmdatela, 
                         INPUT 1,            
                         INPUT tel_nrdconta, 
                         INPUT tel_idseqttl, 
                         INPUT TRUE,
                         INPUT glb_cddopcao,
                         INPUT glb_dtmvtolt,
                         INPUT tel_mesdbase,
                         INPUT tel_anodbase,
                         INPUT tel_vlcxbcaf,
                         INPUT tel_vlctarcb,
                         INPUT tel_vlrestoq,
                         INPUT tel_vloutatv,
                         INPUT tel_vlrimobi,
                         INPUT tel_vlfornec,
                         INPUT tel_vloutpas,
                         INPUT tel_vldivbco,
                         INPUT tel_cdopejfn,
                        OUTPUT aux_tpatlcad,
                        OUTPUT aux_msgatcad,
                        OUTPUT aux_chavealt,
                        OUTPUT TABLE tt-erro) .
    
                   IF  RETURN-VALUE <> "OK" OR 
                       TEMP-TABLE tt-erro:HAS-RECORDS THEN
                       DO:
                          FIND FIRST tt-erro NO-ERROR.
    
                          IF  AVAILABLE tt-erro THEN
                              DO:
                                 MESSAGE tt-erro.dscritic.
                                 NEXT.
                              END.
                       END.

                   /* verificar se é necessario registrar o crapalt */
                   RUN proc_altcad (INPUT "b1wgen0066.p").

                   IF  VALID-HANDLE(h-b1wgen0066) THEN
                       DELETE OBJECT h-b1wgen0066.

                   IF  RETURN-VALUE <> "OK" THEN
                       NEXT.
                END.
                
        END. /* Fim TRANSACTION */
        
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
        aux_confirma <> "S"                  THEN
        NEXT.
   ELSE
        DO:
            aux_flgsuces = YES.
            LEAVE.
        END.
        
END.

IF  VALID-HANDLE(h-b1wgen0066) THEN
    DELETE OBJECT h-b1wgen0066.

IF   aux_flgsuces   THEN
     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

         MESSAGE "Alteracao efetuada com sucesso!".
         PAUSE 2 NO-MESSAGE.
         HIDE MESSAGE NO-PAUSE.
         LEAVE.
     END.
        
HIDE MESSAGE NO-PAUSE.
HIDE FRAME f_dados_financeiro NO-PAUSE.

/* ......................................................................... */
