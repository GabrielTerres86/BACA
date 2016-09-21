/* .............................................................................

   Programa: fontes/contas_dados_completo_juridica.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Maio/2006                       Ultima Atualizacao: 30/04/2010

   Dados referentes ao programa:
   
   Frequencia: Diario (on-line)
   Objetivo  : Efetuar manutencao dos dados referentes ao registro do
               Associado.

   Alteracoes: 14/12/2006 - Tirada obrigacao da inscricao municipal. Altera-
                            cao aprovada pelo Ivo (Magui)
                            
               22/12/2006 - Corrigido o HIDE do frame (Evandro).

               31/07/2009 - Adicionar campo crapjfn.perfatcl - "Concentracao
                            faturamento unico cliente" (Fernando).
                            
               30/04/2010 - Adaptacao para uso de BO (Jose Luis, DB1)
..............................................................................*/
{ sistema/generico/includes/b1wgen0065tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ includes/var_online.i }
{ includes/var_contas.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-DESKTOP=SIM }

DEF VAR reg_dsdopcao  AS CHAR        FORMAT "x(07)"  INIT "Alterar"   NO-UNDO.

DEF VAR tel_vlfatano LIKE crapjur.vlfatano                            NO-UNDO.
DEF VAR tel_vlcaprea LIKE crapjur.vlcaprea                            NO-UNDO.
DEF VAR tel_dtregemp LIKE crapjur.dtregemp                            NO-UNDO.
DEF VAR tel_nrregemp LIKE crapjur.nrregemp                            NO-UNDO.
DEF VAR tel_orregemp LIKE crapjur.orregemp                            NO-UNDO.
DEF VAR tel_dtinsnum LIKE crapjur.dtinsnum                            NO-UNDO.
DEF VAR tel_nrinsmun LIKE crapjur.nrinsmun                            NO-UNDO.
DEF VAR tel_nrinsest LIKE crapjur.nrinsest                            NO-UNDO.
DEF VAR tel_flgrefis LIKE crapjur.flgrefis                            NO-UNDO.
DEF VAR tel_nrcdnire LIKE crapjur.nrcdnire                            NO-UNDO.
DEF VAR tel_perfatcl LIKE crapjfn.perfatcl                            NO-UNDO.

DEF VAR aux_flgsuces  AS LOGICAL                                      NO-UNDO.
DEF VAR h-b1wgen0065  AS HANDLE                                       NO-UNDO.

FORM SKIP(1)
     tel_vlfatano AT  1  LABEL "Faturamento Ano" AUTO-RETURN
                  FORMAT "zzz,zzz,zzz,zz9.99"
                  HELP "Informe o faturamento anual."
                  VALIDATE(INPUT tel_vlfatano > 0,
                           "375 - O campo deve ser preenchido.")

     tel_vlcaprea AT 42  LABEL  "Capital Realizado" AUTO-RETURN
                  FORMAT "zzz,zzz,zzz,zz9.99"
                  HELP "Informe o capital realizado da empresa."
                  VALIDATE(tel_vlcaprea > 0,
                           "375 - O campo deve ser preenchido.")
                             
     SKIP
     tel_dtregemp AT  1  LABEL "Registro - Data" AUTO-RETURN
                  HELP "Informe a data de registro da empresa."
                  VALIDATE(tel_dtregemp <> ?,"013 - Data errada.")
                         

     tel_nrregemp AT 29  LABEL "Numero" AUTO-RETURN
                  HELP "Informe o numero de registro da empresa."
                  VALIDATE(tel_nrregemp > 0,
                           "375 - O campo deve ser preenchido.")
     
     tel_orregemp AT 61  LABEL "Orgao"     FORMAT "x(11)"  AUTO-RETURN
                  HELP "Informe o orgao onde a empresa foi registrada."
                  VALIDATE(tel_orregemp <> "",
                           "375 - O campo deve ser preenchido.")
     SKIP
     tel_dtinsnum AT  1  LABEL "Inscricao Municipal - Data" AUTO-RETURN
                  HELP "Informe a data da inscricao municipal"

     tel_nrinsmun AT 45  LABEL "Numero" AUTO-RETURN
                  HELP "Informe o numero da inscricao municipal"
     
     SKIP
     tel_nrinsest AT  1  LABEL "Inscricao Estadual" 
                  FORMAT "999,999,999,999"
                  HELP "Informe o numero da Inscricao Estadual"
     tel_flgrefis AT 46  LABEL "Optante REFIS"
                  HELP "Informe se a empresa e optante do REFIS."
     SKIP
     tel_perfatcl AT  1  LABEL "Concentracao faturamento unico cliente"
                  VALIDATE (tel_perfatcl > 0 AND tel_perfatcl <= 100,
                            "269 - Valor errado.")
            
                  HELP "Informe o percentual de faturamento do maior cliente."
     tel_nrcdnire AT  48 LABEL "Numero NIRE"
                  HELP "Informe o numero do NIRE."
     SKIP(1)
     reg_dsdopcao AT 36 NO-LABEL
                  HELP "Pressione ENTER para selecionar / F4 ou END para sair"
     WITH ROW 12 OVERLAY SIDE-LABELS TITLE " REGISTRO " CENTERED
          WIDTH 80 FRAME f_complemento.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   IF  NOT VALID-HANDLE(h-b1wgen0065) THEN
       RUN sistema/generico/procedures/b1wgen0065.p 
           PERSISTENT SET h-b1wgen0065.

   RUN Busca_Dados IN h-b1wgen0065
       ( INPUT glb_cdcooper, 
         INPUT 0,            
         INPUT 0,            
         INPUT glb_cdoperad, 
         INPUT glb_nmdatela, 
         INPUT 1,            
         INPUT tel_nrdconta, 
         INPUT tel_idseqttl, 
         INPUT YES,
        OUTPUT TABLE tt-registro,
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

   FIND FIRST tt-registro NO-ERROR.

   IF  NOT AVAILABLE tt-registro THEN
       DO:
          MESSAGE "Nao foi possivel obter os dados das REGISTRO do associado".
          LEAVE.
       END.
                      
   aux_flgsuces = NO.
          
   ASSIGN tel_vlfatano = tt-registro.vlfatano 
          tel_vlcaprea = tt-registro.vlcaprea 
          tel_dtregemp = tt-registro.dtregemp 
          tel_nrregemp = tt-registro.nrregemp 
          tel_orregemp = tt-registro.orregemp 
          tel_dtinsnum = tt-registro.dtinsnum 
          tel_nrinsmun = tt-registro.nrinsmun 
          tel_nrinsest = tt-registro.nrinsest 
          tel_flgrefis = tt-registro.flgrefis 
          tel_nrcdnire = tt-registro.nrcdnire
          tel_perfatcl = tt-registro.perfatcl.
   
   DISPLAY tel_vlfatano    tel_vlcaprea    tel_dtregemp
           tel_nrregemp    tel_orregemp    tel_dtinsnum
           tel_nrinsmun    tel_nrinsest    tel_flgrefis
           tel_nrcdnire    reg_dsdopcao    tel_perfatcl
           WITH FRAME f_complemento.
           
   CHOOSE FIELD reg_dsdopcao WITH FRAME f_complemento.
   
   IF   FRAME-FIELD = "reg_dsdopcao"   THEN
        DO:    
            ASSIGN glb_nmrotina = "REGISTRO"
                   glb_cddopcao = "A".
               
            { includes/acesso.i }

            DO WHILE TRUE:
                
               UPDATE tel_vlfatano    tel_vlcaprea    tel_dtregemp
                      tel_nrregemp    tel_orregemp    tel_dtinsnum
                      tel_nrinsmun    tel_nrinsest    tel_flgrefis
                      tel_perfatcl    tel_nrcdnire    WITH FRAME f_complemento.
    
               RUN Valida_Dados IN h-b1wgen0065
                   ( INPUT glb_cdcooper, 
                     INPUT 0,            
                     INPUT 0,            
                     INPUT glb_cdoperad, 
                     INPUT glb_nmdatela, 
                     INPUT 1,            
                     INPUT tel_nrdconta, 
                     INPUT tel_idseqttl, 
                     INPUT YES,
                     INPUT tel_vlfatano,
                     INPUT tel_vlcaprea,
                     INPUT tel_dtregemp,
                     INPUT tel_nrregemp,
                     INPUT tel_orregemp,
                     INPUT tel_perfatcl,
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
                       IF  VALID-HANDLE(h-b1wgen0065) THEN
                           DELETE OBJECT h-b1wgen0065.
    
                       RUN sistema/generico/procedures/b1wgen0065.p 
                           PERSISTENT SET h-b1wgen0065.
    
                       RUN Grava_Dados IN h-b1wgen0065
                           ( INPUT glb_cdcooper, 
                             INPUT 0,            
                             INPUT 0,            
                             INPUT glb_cdoperad, 
                             INPUT glb_nmdatela, 
                             INPUT 1,            
                             INPUT tel_nrdconta, 
                             INPUT tel_idseqttl, 
                             INPUT YES,
                             INPUT "A",
                             INPUT glb_dtmvtolt,
                             INPUT tel_vlfatano,
                             INPUT tel_vlcaprea,
                             INPUT tel_dtregemp,
                             INPUT tel_nrregemp,
                             INPUT tel_orregemp,
                             INPUT tel_dtinsnum,
                             INPUT tel_nrinsmun,
                             INPUT tel_nrinsest,
                             INPUT tel_flgrefis,
                             INPUT tel_nrcdnire,
                             INPUT tel_perfatcl,
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
                        RUN proc_altcad (INPUT "b1wgen0065.p").
    
                        DELETE OBJECT h-b1wgen0065.
    
                        IF  RETURN-VALUE <> "OK" THEN
                            NEXT.
                    END.
                    
               LEAVE.
                    
            END. /* Fim DO TRANSACTION */
        END.
        
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
        aux_confirma <> "S"                  THEN
        NEXT.
   ELSE
        DO:
            aux_flgsuces = YES.
            LEAVE.
        END.    
END.

IF   aux_flgsuces   THEN
     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

         MESSAGE "Alteracao efetuada com sucesso!".
         PAUSE 2 NO-MESSAGE.
         HIDE MESSAGE NO-PAUSE.
         LEAVE.
     END.

HIDE FRAME f_complemento NO-PAUSE.

IF  VALID-HANDLE(h-b1wgen0065) THEN
    DELETE OBJECT h-b1wgen0065.

/*...........................................................................*/
