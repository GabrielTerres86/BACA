/* ...........................................................................

   Programa: Fontes/contas_corrente.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Junho/2006                   Ultima Atualizacao: 12/01/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Efetuar Alteracao nos dados da conta do associado.
                                                 
   Alteracoes: 17/11/2006 - Acerto na exclusao da Conta Integracao (Ze).

               22/12/2006 - Corrigido o HIDE do frame (Evandro).

               03/01/2007 - Permitir contas Bancoob/com conta ITG
                            (Mirtes/Evandro).
                            
               19/01/2007 - Correcao na criacao da crapalt (Evandro).

               12/02/2007 - Efetuada modificacao para nova estrutura crapneg
                            (Diego).
                            
               26/02/2007 - Criticar tipo de conta inexistente (Diego).
               
               23/03/2007 - Aumentado o campo crapass.dsdemail para 35
                            caracteres (Evandro).

               17/07/2007 - Efetuado acerto indnivel(Mirtes)
               
               31/07/2007 - Corrigida a verificacao do e-mail e aumentado para
                            40 caracteres.
                          - Incluido F7 para escolher o e-mail de cobranca
                            (Evandro).
                            
               20/11/2007 - Limpar os campos do segundo e terceiro titular na
                            opcao "Excluir Titulares" (Diego).

               11/01/2008 - Criticar situacao de conta inexistente (Julio).
               
               25/01/2008 - Efetuado acerto para nao permitir cooperado Menor
                            de idade sem Responsavel Legal cadastrado (Diego).
                            
               18/02/2008 - Quando for excluir os titulares, utilizar o buffer
                            crabttl ao inves da crapttl (Evandro).
               
               20/02/2008 - Somente criticar maioridade para pessoa fisica
                            (Evandro).

               01/04/2008 - Incluido campo Banco 001 e Agencias (3420-7)
                            (~Gabriel). 

               14/04/2008 - Nao encerrar conta itg se cartao aprovado(Mirtes)
               
               07/05/2008 - Verificar se a cooperativa possui convenio com o 
                            BANCOOB quando o tipo de conta for 8, 9, 10 ou 11
                            (Evandro).
                            
               18/07/2008 - Alterado para tratar se associado esta no CCF 
                            na hora de exclusao de titular (Gabriel).

               21/08/2008 - Nao permitir mudar tipo de conta para ITG quando
                            nao estiver cadastrada a agencia do BB na CADCOP
                            e para tipo de conta convenio quando nao estiver
                            cadastrada a agencia do BANCOOB (Gabriel).
          
               08/12/2008 - Possibiliar o encerramento e reativacao da conta
                            integracao. Pegar situacao da CI apartir
                            da includes/sititg.i (Gabriel)
                          - Nao considerar crapfdc.incheque para verificar
                            cheques FORA (Evandro).
                            
               13/04/2008 - Retirada dos campos Rec. Arq. Cobranca e Email (Ze)

               14/05/2009 - Corrigida descricao do LOG na alteracao do tipo de
                            conta ITG - procedure solicitar_itg (Diego).
                            
               02/07/2009 - Criar registro da crapalt para solicitacao da conta
                            ITG - procedure solicitar_itg (Fernando).
                            
               10/07/2009 - Incluidas restricoes para Tipo Extrato Conta
                            (Diego).

               05/08/2009 - Excluido o campo cdgraupr da tabela crapass.
                            Paulo - Precise.
                
               14/09/2009 - Deletar registros de contatos quando excluido os 
                            titulares (Gabriel).
                            
               28/09/2009 - Adaptacoes projeto IF CECRED (Guilherme).
               
               22/10/2009 - Alterado posicionamento  dos campos (Elton).
               
               16/12/2009 - Eliminado campo crapttl.cdmodali (Diego).
               
               28/05/2010 - Adaptado para uso de BO (Jose Luis, DB1)
               
               28/07/2010 - Incluir parametro dtmvtolt na Busca_Dados
                          - Bco Emis Chq - Fixo crapcop.cdbcoctl (Guilherme).
               
               22/09/2010 - Controle dos botões passado para a BO
                           (Gabriel, DB1).
                           
               13/02/2013 - Incluir campo flgrestr em tela (Lucas R.)
               
               12/06/2013 - Consorcio (Gabriel).
               
               29/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                        
               29/10/2013 - Bloquear o campo "Esta no SPC" para as cooperativas
                            "1,16,13" (James)
                            
               05/11/2013 - Remover a condicao para bloquear o campo 
                            "Esta no SPC" para as cooperativas "1,16,13"(James)
                            
               06/02/2014 - Alteração de descrição de campos (Lucas).
               
               28/05/2014 - Inclusao do campo Libera Credito Pre Aprovado 
                            'flgcrdpa' (Jaison) 
                            
               10/07/2014 - Alterações para criticar propostas de cart. cred. 
                            em aberto durante exclusão de titulares
                            (Lucas Lunelli - Projeto Bancoob).
               
               08/08/2014 - Retirar campos do SPC e Serasa (Jonata-RKAM).                                                                         
               
               14/08/2014 - Inclusao de mensagem caso o cooperado nao possua 
                            Credito Pre Aprovado no momento da alteracao da flg
                            'flgcrdpa' (Jaison) 
                    
               28/08/2014 - Incluir campo na tela tel_incadpos Projeto 
                            Cadastro Positivo (Lucas R./Thiago Rodrigues)

               11/11/2014 - Inclusao do parametro "nrcpfope" na chamada da
                            procedure "busca_dados" da "b1wgen0188". (Jaison)
                            
               11/08/2015 - Gravacao do novo campo indserma na tabela crapass
                            correspondente a tela CONTAS, OPCAO Conta Corrente                             
                            (Projeto 218 - Melhorias Tarifas (Carlos Rafael Tanholi)                            
                            
               12/01/2016 - Incluida leitura do campo de assinatura conjunta. (Jean Michel)
                              
               12/01/2016 - Remover manutencao do campo flgcrdpa. (Anderson).
.............................................................................*/

{ sistema/generico/includes/b1wgen0074tt.i }
{ sistema/generico/includes/b1wgen0059tt.i &BD-GEN=SIM }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/gera_erro.i }
{ includes/var_online.i }
{ includes/var_contas.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-DESKTOP=SIM }
{ includes/var_logcontas.i }

DEF VAR tel_cdagepac    LIKE crapass.cdagenci                       NO-UNDO.
DEF VAR tel_cdtipcta    LIKE crapass.cdtipcta                       NO-UNDO.
DEF VAR tel_cdsitdct    LIKE crapass.cdsitdct                       NO-UNDO.
DEF VAR tel_tpavsdeb    LIKE crapass.tpavsdeb                       NO-UNDO.
DEF VAR tel_tpextcta    LIKE crapass.tpextcta                       NO-UNDO.
DEF VAR tel_cdsecext    LIKE crapass.cdsecext                       NO-UNDO.
DEF VAR tel_nrdctitg    LIKE crapass.nrdctitg                       NO-UNDO.
DEF VAR tel_dssititg    AS CHAR                                     NO-UNDO.
DEF VAR tel_dtcnsspc    LIKE crapass.dtcnsspc                       NO-UNDO.
DEF VAR tel_dtcnsscr    LIKE crapass.dtcnsscr                       NO-UNDO.
DEF VAR tel_dtdsdspc    LIKE crapass.dtdsdspc                       NO-UNDO.
DEF VAR tel_dtmvtolt    LIKE crapass.dtmvtolt                       NO-UNDO.
DEF VAR tel_dtelimin    LIKE crapass.dtelimin                       NO-UNDO.
DEF VAR tel_dtabtcct    LIKE crapass.dtabtcct                       NO-UNDO.
DEF VAR tel_dtdemiss    LIKE crapass.dtdemiss                       NO-UNDO.
DEF VAR tel_dsextcta    AS CHAR    FORMAT "x(10)"                   NO-UNDO.
DEF VAR tel_dssecext    AS CHAR    FORMAT "x(20)"                   NO-UNDO.
DEF VAR tel_dsavsdeb    AS CHAR    FORMAT "x(10)"                   NO-UNDO.
DEF VAR tel_cdagedbb    AS INT     FORMAT "9999,9"                  NO-UNDO.
DEF VAR tel_cdbcoitg    AS INTE    FORMAT "999"  INIT 1             NO-UNDO.
DEF VAR tel_cdbcochq    AS INTE    FORMAT "999"                     NO-UNDO.
DEF VAR tel_flgrestr    LIKE crapass.flgrestr                       NO-UNDO.
DEF VAR tel_nrctacns    LIKE crapass.nrctacns                       NO-UNDO.

DEF VAR aux_cdbcochq    AS CHAR    FORMAT "x(3)"                    NO-UNDO.
DEF VAR aux_cdbcoctl    AS INTE                                     NO-UNDO.
DEF VAR aux_flgsuces    AS LOGICAL                                  NO-UNDO.
DEF VAR aux_flgderro    AS LOGICAL                                  NO-UNDO.
DEF VAR aux_flgtitul    AS LOGICAL                                  NO-UNDO.
DEF VAR aux_flgbrows    AS LOGICAL                                  NO-UNDO.
DEF VAR aux_flgcreca    AS LOGICAL                                  NO-UNDO.
DEF VAR aux_nmdcampo    AS CHARACTER                                NO-UNDO.
DEF VAR aux_flgctitg    AS INTEGER                                  NO-UNDO.
DEF VAR aux_inpessoa    AS INTEGER                                  NO-UNDO.
DEF VAR aux_msgalert    AS CHARACTER                                NO-UNDO.
DEF VAR aux_tipconfi    AS INTEGER                                  NO-UNDO.
DEF VAR aux_msgconfi    AS CHARACTER                                NO-UNDO.
DEF VAR aux_inadimpl    AS INTEGER                                  NO-UNDO.
DEF VAR aux_inlbacen    AS INTEGER                                  NO-UNDO.
DEF VAR aux_flgexclu    AS LOGICAL                                  NO-UNDO.
DEF VAR aux_indserma    AS LOGICAL                                  NO-UNDO.
DEF VAR aux_dtcalcul    AS DATE                                     NO-UNDO.
DEF VAR aux_diauteis    AS INTEGER                                  NO-UNDO.
DEF VAR aux_btaltera    AS LOGICAL                                  NO-UNDO.
DEF VAR aux_btencitg    AS LOGICAL                                  NO-UNDO.
DEF VAR aux_btexcttl    AS LOGICAL                                  NO-UNDO.
DEF VAR aux_btsolitg    AS LOGICAL                                  NO-UNDO.
DEF VAR aux_nrdctitg    LIKE crapass.nrdctitg                       NO-UNDO.
DEF VAR tel_incadpos    AS CHAR FORMAT "x(15)"                      NO-UNDO.

DEF VAR h-b1wgen0074    AS HANDLE                                   NO-UNDO.
DEF VAR h-b1wgen0060    AS HANDLE                                   NO-UNDO.

DEF   VAR  p_opcao       AS CHAR    EXTENT 5 INIT  
    ["Alterar","Enc. ITG","Excluir Titulares",
    "Solic./Reativar ITG","Gerar Conta Sicredi" ] NO-UNDO.

DEF BUFFER crabttl FOR crapttl.

DEF BUFFER crabass FOR crapass.

FORM tel_cdagepac     AT 08 LABEL "PA" AUTO-RETURN
                            HELP "Informe o numero do PA" "-"
     tel_dsagenci      NO-LABEL
     tel_cdsitdct     AT 36 LABEL "Situacao"
       HELP "1-Nor,2-Enc.Ass,3-Enc.COOP,4-Enc.Dem,5-Nao aprov,6-S/Tal,9-Outros"
     tel_dssitdct           NO-LABEL
     SKIP
     tel_cdtipcta     AT  1 LABEL "Tipo Conta"
                     HELP "Informe o tipo de conta ou pressione F7 para listar"
     tel_dstipcta           NO-LABEL
     tel_cdbcochq     AT 36 LABEL "Bco.Emis.Cheque"
     SKIP
     tel_nrdctitg     AT  2 LABEL "Conta/ITG"
     tel_dssititg           NO-LABEL
     tel_cdagedbb     AT 36 LABEL "Age ITG"
     tel_cdbcoitg     AT 57 LABEL "Bco ITG"
     tel_nrctacns     AT 05 LABEL "Conta Sicredi"              FORMAT "zzzz,zzz,9"
     SKIP
     tel_flgiddep     AT  1 LABEL "Identifica Deposito"        FORMAT "S/N"
                  HELP "(S)Sim para identificar ou (N)Nao para nao identificar"

     tel_tpavsdeb     AT 36 LABEL "Emitir Aviso"
                            VALIDATE (tel_tpavsdeb = 0 OR
                                      tel_tpavsdeb = 1,
                                      "014 - Opcao errada.")
            HELP "Informe o tipo de emissao dos avisos (0-nao emite, 1-emite)"
     tel_dsavsdeb           NO-LABEL
     SKIP
     tel_tpextcta     AT  2 LABEL "Tipo Extrato Conta"
               HELP "Informe tipo extrato (0-nao emite, 1-mensal, 2-quinzenal)"
     tel_dsextcta           NO-LABEL
     tel_cdsecext     AT 36 LABEL "Destino Extrato"
         HELP "Informe a secao p/ envio de extrato ou pressione F7 para listar"
     tel_dssecext           NO-LABEL
     SKIP
     tel_dtcnsscr     AT  1 LABEL "Consulta SCR"
                            FORMAT "99/99/9999"
                            HELP "Informe a data da consulta no SCR"
     tel_flgrestr AT 36 LABEL "Grau Acesso" 
                            HELP "Informe (R)RESTRITO ou (L)LIBERADO"
                            VALIDATE(CAN-DO("R,L",INPUT tel_flgrestr),
                                     '024 - Deve ser "R" ou "L".')
     tel_dslbacen     AT 72 LABEL "CCF"         FORMAT "!(1)"
                            HELP "Informe (S)SIM ou (N)NAO"
                            VALIDATE(CAN-DO("S,N",INPUT tel_dslbacen),
                                     '024 - Deve ser "S" ou "N".')
     SKIP
     tel_incadpos AT 1 LABEL "Cadastro Positivo"  
     SKIP
     "----------------------------------- Datas"
     "------------------------------------"
     "Como Cooperado =>"   AT  3
     tel_dtmvtolt     AT 21 LABEL "Abertura"
     tel_dtelimin     AT 50  LABEL "Demissao"
     SKIP
     "Como Correntista =>" AT  1
     tel_dtabtcct     AT 21 LABEL "Abertura"
     tel_dtdemiss     AT 46 LABEL "Encerramento"
     SKIP
     p_opcao[4]       AT  2 NO-LABEL FORMAT "x(19)"
                   HELP "Pressione ENTER para selecionar / F4 ou END para sair"
     p_opcao[1]       AT 23 NO-LABEL FORMAT "x(7)"
                   HELP "Pressione ENTER para selecionar / F4 ou END para sair"
     p_opcao[2]       AT 32 NO-LABEL FORMAT "x(8)"
                   HELP "Pressione ENTER para selecionar / F4 ou END para sair"
     p_opcao[5]       AT 42 NO-LABEL FORMAT "x(19)"
                   HELP "Pressione ENTER para selecionar / F4 ou END para sair"
     p_opcao[3]       AT 62 NO-LABEL FORMAT "x(17)"
                   HELP "Pressione ENTER para selecionar / F4 ou END para sair"
     WITH ROW 8 OVERLAY SIDE-LABELS TITLE " CONTA CORRENTE "
          CENTERED FRAME f_contas_corrente.

/* Eventos para atualizar as descricoes na tela */

ON LEAVE OF tel_cdagepac IN FRAME f_contas_corrente DO:

    /* PA */
    ASSIGN INPUT tel_cdagepac.

    DYNAMIC-FUNCTION("BuscaPac" IN h-b1wgen0060,
                     INPUT glb_cdcooper,
                     INPUT tel_cdagepac,
                     INPUT "nmextage",
                    OUTPUT tel_dsagenci,
                    OUTPUT glb_dscritic).

    DISPLAY tel_dsagenci WITH FRAME f_contas_corrente.

    IF  glb_dscritic <> "" THEN
        DO:
           MESSAGE glb_dscritic.
           RETURN NO-APPLY.
        END.
END.

ON LEAVE OF tel_cdtipcta IN FRAME f_contas_corrente DO:

    /* Tipo da Conta */
    ASSIGN INPUT tel_cdtipcta.
    
    DYNAMIC-FUNCTION("BuscaTipoConta" IN h-b1wgen0060,
                     INPUT glb_cdcooper,
                     INPUT tel_cdtipcta,
                    OUTPUT tel_dstipcta,
                    OUTPUT glb_dscritic).

    DISPLAY tel_dstipcta WITH FRAME f_contas_corrente.

    IF  glb_dscritic <> "" THEN
        DO:
           MESSAGE glb_dscritic.
           RETURN NO-APPLY.
        END.

    IF  CAN-DO("8,9,10,11",STRING(INPUT tel_cdtipcta))  THEN 
        DO:
            ASSIGN tel_cdbcochq = aux_cdbcoctl.
            DISPLAY tel_cdbcochq WITH FRAME f_contas_corrente.
        END.

    RUN Verifica_Exclusao_Titulares IN h-b1wgen0074 (INPUT glb_cdcooper,
                                                     INPUT 0,
                                                     INPUT 0,
                                                     INPUT glb_cdoperad,
                                                     INPUT glb_nmdatela,
                                                     INPUT 1,
                                                     INPUT tel_nrdconta,
                                                     INPUT tel_idseqttl,
                                                     INPUT INPUT tel_cdtipcta,
                                                     INPUT TRUE,
                                                    OUTPUT aux_tipconfi,
                                                    OUTPUT aux_msgconfi,
                                                    OUTPUT TABLE tt-critica-excl-titulares,
                                                    OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAILABLE tt-erro  THEN
                MESSAGE tt-erro.dscritic.

            APPLY "RECALL" TO tel_cdtipcta.
        END.
    ELSE
        DO:            
            ASSIGN aux_flgexclu = FALSE.

            FOR EACH tt-critica-excl-titulares NO-LOCK:

                MESSAGE tt-critica-excl-titulares.dscritic.
                WAIT-FOR ANY-KEY OF CURRENT-WINDOW.

            END.
            
            IF  aux_tipconfi = 1  THEN
                DO:
                    ASSIGN aux_confirma = "N".

                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        MESSAGE aux_msgconfi.
                        MESSAGE COLOR NORMAL "078 - Confirma a operacao? (S/N)"
                                UPDATE aux_confirma.
                        LEAVE.
                    END.

                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  OR
                        aux_confirma <>  "S"                THEN
                        ASSIGN aux_flgexclu = FALSE.
                    ELSE
                        ASSIGN aux_flgexclu = TRUE.
                END.
        END.
        
END.           

ON LEAVE OF tel_cdsitdct IN FRAME f_contas_corrente DO:

    ASSIGN INPUT tel_cdsitdct.

    /* Situacao da conta */
    DYNAMIC-FUNCTION("BuscaSituacaoConta" IN h-b1wgen0060,
                     INPUT tel_cdsitdct,
                     OUTPUT tel_dssitdct,
                     OUTPUT glb_dscritic).
        
   DISPLAY tel_dssitdct WITH FRAME f_contas_corrente.

   IF  glb_dscritic <> "" THEN
       DO:
          MESSAGE glb_dscritic.
          RETURN NO-APPLY.
       END.
END.

ON LEAVE OF tel_tpavsdeb IN FRAME f_contas_corrente DO:

   ASSIGN INPUT tel_tpavsdeb.

   /* Tipo Emissao de Aviso */
   DYNAMIC-FUNCTION("BuscaTipoAviso" IN h-b1wgen0060,
                    INPUT tel_tpavsdeb,
                    OUTPUT tel_dsavsdeb,
                    OUTPUT glb_dscritic).
        
   DISPLAY tel_dsavsdeb WITH FRAME f_contas_corrente.

   IF  glb_dscritic <> "" THEN
       DO:
          MESSAGE glb_dscritic.
          RETURN NO-APPLY.
       END.
END.   

ON LEAVE OF tel_tpextcta IN FRAME f_contas_corrente DO:

    ASSIGN INPUT tel_tpextcta.

   /* Tipo de extrato de conta */
    DYNAMIC-FUNCTION("BuscaTipoExtrato" IN h-b1wgen0060,
                     INPUT tel_tpextcta,
                     OUTPUT tel_dsextcta,
                     OUTPUT glb_dscritic).
        
   DISPLAY tel_dsextcta WITH FRAME f_contas_corrente.

   IF  glb_dscritic <> "" THEN
       DO:
          MESSAGE glb_dscritic.
          RETURN NO-APPLY.
       END.
END.   

ON LEAVE OF tel_cdsecext IN FRAME f_contas_corrente DO:

    ASSIGN INPUT tel_cdsecext.

    /* Destino de extrato */
    DYNAMIC-FUNCTION("BuscaDestExt" IN h-b1wgen0060,
                     INPUT glb_cdcooper,
                     INPUT tel_cdagepac,
                     INPUT tel_cdsecext,
                    OUTPUT tel_dssecext,
                    OUTPUT glb_dscritic).

   DISPLAY tel_dssecext WITH FRAME f_contas_corrente.

   IF  glb_dscritic <> "" THEN
       DO:
          MESSAGE glb_dscritic.
          RETURN NO-APPLY.
       END.
    END.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   IF  NOT VALID-HANDLE(h-b1wgen0074) THEN
       RUN sistema/generico/procedures/b1wgen0074.p 
           PERSISTENT SET h-b1wgen0074.

   IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
       RUN sistema/generico/procedures/b1wgen0060.p 
           PERSISTENT SET h-b1wgen0060.

   ASSIGN glb_cddopcao = "A".

   RUN Busca_Dados.

   IF  RETURN-VALUE <> "OK" THEN
       NEXT.

   RUN Atualiza_Tela.

   IF  RETURN-VALUE <> "OK" THEN
       NEXT.

   ASSIGN aux_flgsuces = FALSE.

   DISPLAY 
       tel_cdagepac     tel_dsagenci     tel_cdtipcta     tel_dstipcta
       tel_cdsitdct     tel_dssitdct     tel_nrdctitg     tel_cdagedbb 
       tel_cdbcoitg     tel_nrctacns     tel_flgiddep     
       tel_tpavsdeb     tel_dsavsdeb     tel_tpextcta     tel_dsextcta     
       tel_cdsecext     tel_dssecext     tel_dtcnsscr     tel_flgrestr     
       tel_dslbacen     tel_incadpos
       tel_dtmvtolt     tel_dtelimin     tel_dtabtcct     tel_dtdemiss     
       tel_dssititg     tel_cdbcochq     p_opcao[1]       p_opcao[2]       
       p_opcao[3]       p_opcao[4]       p_opcao[5]       
       WITH FRAME f_contas_corrente.
   
   /*Alteração: Controle dos botões passado para a BO (Gabriel, DB1).*/
   ASSIGN p_opcao[1]:HIDDEN = NOT aux_btaltera
          p_opcao[2]:HIDDEN = NOT aux_btencitg
          p_opcao[3]:HIDDEN = NOT aux_btexcttl
          p_opcao[4]:HIDDEN = NOT aux_btsolitg.
   
   IF  NOT aux_btaltera  AND
       NOT aux_btencitg  AND 
       NOT aux_btexcttl  AND
       NOT aux_btsolitg  THEN
       DO:
           p_opcao[5]:HIDDEN = TRUE.
           PAUSE.
       END.
   ELSE
   IF  aux_btaltera THEN
       DO:
          IF  aux_btencitg THEN
              DO:
                  IF  aux_btexcttl THEN
                      DO:
                          IF  aux_btsolitg THEN
                              CHOOSE FIELD p_opcao[1]
                                           p_opcao[2]
                                           p_opcao[3]
                                           p_opcao[4]
                                           p_opcao[5] 
                                  WITH FRAME f_contas_corrente.
                          ELSE
                              CHOOSE FIELD p_opcao[1] 
                                           p_opcao[2]
                                           p_opcao[3]
                                           p_opcao[5] 
                                  WITH FRAME f_contas_corrente.
                      END.
                  ELSE
                      DO:
                          IF  aux_btsolitg THEN
                              CHOOSE FIELD p_opcao[1]
                                           p_opcao[2]
                                           p_opcao[4]
                                           p_opcao[5] 
                                  WITH FRAME f_contas_corrente.
                          ELSE
                              CHOOSE FIELD p_opcao[1] 
                                           p_opcao[2]
                                           p_opcao[5] 
                                  WITH FRAME f_contas_corrente.
                      END.
              END.
          ELSE
              DO:
                 IF  aux_btexcttl THEN
                     DO:
                         IF  aux_btsolitg THEN
                             CHOOSE FIELD p_opcao[1]
                                          p_opcao[3]
                                          p_opcao[4]
                                          p_opcao[5]
                                 WITH FRAME f_contas_corrente.
                         ELSE
                             CHOOSE FIELD p_opcao[1] 
                                          p_opcao[3]
                                          p_opcao[5]
                                 WITH FRAME f_contas_corrente.
                     END.
                 ELSE
                     DO:
                        IF  aux_btsolitg THEN
                            CHOOSE FIELD p_opcao[1]
                                         p_opcao[4]
                                         p_opcao[5]
                                WITH FRAME f_contas_corrente.
                        ELSE
                            CHOOSE FIELD p_opcao[1]
                                         p_opcao[5]
                                WITH FRAME f_contas_corrente.
                     END.
              END.
       END.
   ELSE
       DO:
           IF  aux_btencitg THEN
               DO:
                   IF  aux_btexcttl THEN
                       DO:
                           IF  aux_btsolitg THEN
                               CHOOSE FIELD p_opcao[2]
                                            p_opcao[3]
                                            p_opcao[4]
                                            p_opcao[5]
                                   WITH FRAME f_contas_corrente.
                           ELSE
                               CHOOSE FIELD p_opcao[2]
                                            p_opcao[3]
                                            p_opcao[5]
                                   WITH FRAME f_contas_corrente.
                       END.
                   ELSE
                       DO:
                           IF  aux_btsolitg THEN
                               CHOOSE FIELD p_opcao[2]
                                            p_opcao[4]
                                            p_opcao[5]
                                   WITH FRAME f_contas_corrente.
                           ELSE
                               CHOOSE FIELD p_opcao[2]
                                            p_opcao[5]
                                   WITH FRAME f_contas_corrente.
                       END.
               END.
           ELSE
               DO:
                   IF  aux_btexcttl THEN
                       DO:
                           IF  aux_btsolitg THEN
                               CHOOSE FIELD p_opcao[3]
                                            p_opcao[4]
                                            p_opcao[5]
                                   WITH FRAME f_contas_corrente.
                           ELSE
                               CHOOSE FIELD p_opcao[3]
                                            p_opcao[5]
                                   WITH FRAME f_contas_corrente.
                       END.
                   ELSE
                       DO:
                           IF  aux_btsolitg THEN
                               CHOOSE FIELD p_opcao[4]
                                            p_opcao[5]
                                   WITH FRAME f_contas_corrente.
                       END.
               END.
       END.
   
   ASSIGN aux_flgsuces = FALSE
          aux_flgexclu = FALSE.

   HIDE MESSAGE NO-PAUSE.
   
   /* ALTERACAO */
   IF  FRAME-VALUE = p_opcao[1] THEN
       DO ON ENDKEY UNDO, LEAVE:

          ASSIGN glb_nmrotina = "CONTA CORRENTE"
                 glb_cddopcao = "A".
       
          { includes/acesso.i }
          
          DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

             /* busca de operador, se for gerente pode alterar o flgrestr */
             FIND crapope WHERE crapope.cdcooper = glb_cdcooper AND
                                crapope.cdoperad = glb_cdoperad NO-LOCK NO-ERROR.

              UPDATE tel_cdagepac 
                     tel_cdsitdct 
                     tel_cdtipcta 
                     /* tel_cdbcochq Fixo crapcop.cdbcoctl */
                     tel_flgiddep 
                     tel_tpavsdeb 
                     tel_tpextcta 
                     tel_cdsecext 
                     tel_dtcnsscr 
                     tel_flgrestr WHEN crapope.nvoperad = 3 
                     tel_dslbacen 
                     WITH FRAME f_contas_corrente
    
              EDITING:               

                 READKEY.
                 
                 HIDE MESSAGE NO-PAUSE.
                
                 IF  LASTKEY = KEYCODE("F7")  THEN
                     DO:
                        IF  FRAME-FIELD = "tel_cdtipcta"  THEN
                            DO:
                               shr_cdtipcta = INPUT tel_cdtipcta.
                               RUN fontes/zoom_tipo_conta.p (glb_cdcooper).
                     
                               IF  shr_cdtipcta <> 0 THEN
                                   DO:
                                       ASSIGN tel_cdtipcta = shr_cdtipcta
                                              tel_dstipcta = shr_dstipcta.
                                   
                                       DISPLAY tel_cdtipcta tel_dstipcta
                                             WITH FRAME f_contas_corrente.

                                       NEXT-PROMPT tel_cdtipcta
                                             WITH FRAME f_contas_corrente.
                                   END.
                            END.
                        ELSE
                        IF  FRAME-FIELD = "tel_cdsecext"  THEN
                            DO:
                               ASSIGN shr_cdsecext = INPUT tel_cdsecext
                                      aux_cdagenci = INPUT tel_cdagepac.

                               RUN fontes/zoom_destino_extrato.p 
                                   ( INPUT glb_cdcooper,
                                     INPUT aux_cdagenci).

                               IF  shr_cdsecext <> 0 THEN
                                   DO:
                                       ASSIGN tel_cdsecext = shr_cdsecext
                                              tel_dssecext = shr_nmsecext.

                                       DISPLAY tel_cdsecext tel_dssecext
                                             WITH FRAME f_contas_corrente.

                                       NEXT-PROMPT tel_cdsecext
                                             WITH FRAME f_contas_corrente.
                                   END.
                            END.
                     END.
                 ELSE
                     APPLY LASTKEY.

                 IF  GO-PENDING  THEN
                     DO:
                        ASSIGN INPUT tel_cdagepac
                               INPUT tel_cdsitdct
                               INPUT tel_cdtipcta
                               /*INPUT tel_cdbcochq Fixo crapcop.cdbcoctl*/
                               INPUT tel_flgiddep
                               INPUT tel_tpavsdeb
                               INPUT tel_tpextcta
                               INPUT tel_cdsecext
                               INPUT tel_dtcnsscr
                               INPUT tel_dslbacen.

                        ASSIGN aux_inadimpl = (IF tel_dsinadim = "N" 
                                               THEN 0 ELSE 1)
                               aux_inlbacen = (IF INPUT tel_dslbacen = "N" 
                                               THEN 0 ELSE 1).
                        
                        RUN Valida_Dados ( INPUT "A" ).

                        IF  RETURN-VALUE <> "OK" THEN
                            DO: 
                               { sistema/generico/includes/foco_campo.i 
                                   &VAR-GERAL=SIM
                                   &NOME-FRAME="f_contas_corrente"
                                   &NOME-CAMPO=aux_nmdcampo }
                            END.
                     END.
                     
              END. /* Fim EDITING */

              LEAVE. 

          END. 

          IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
              NEXT.

          ASSIGN aux_flgsuces = FALSE.
          
          RUN Grava_Dados ( INPUT "A" ).
                                   
          IF  RETURN-VALUE <> "OK" THEN
              NEXT.
          ELSE
              ASSIGN aux_flgsuces = TRUE.

          LEAVE.
       END.
   ELSE
   IF  FRAME-VALUE = p_opcao[2] THEN /* ENCERRAR ITG */
       DO:
           ASSIGN glb_nmrotina = "CONTA CORRENTE"
                  glb_cddopcao = "E".
       
           { includes/acesso.i }

           RUN Valida_Dados ( INPUT "E" ).

           IF  RETURN-VALUE <> "OK" THEN
               NEXT.

           HIDE MESSAGE NO-PAUSE.

           ASSIGN aux_flgsuces = FALSE.

           RUN Grava_Dados ( INPUT "E" ).

           IF  RETURN-VALUE <> "OK" THEN
               NEXT.
           ELSE
               ASSIGN aux_flgsuces = YES.

           LEAVE.
       END.
   ELSE
   IF  FRAME-VALUE = p_opcao[3] THEN /* EXCLUI TITULARES */
       DO:
           ASSIGN glb_nmrotina = "CONTA CORRENTE"
                  glb_cddopcao = "E".
       
           { includes/acesso.i }

           ASSIGN aux_flgbrows = TRUE.
                
           RUN Valida_Dados ( INPUT "X" ).

           IF  RETURN-VALUE <> "OK" THEN
               NEXT.

           HIDE MESSAGE NO-PAUSE.

           RUN Exclusao_Titulares.

           ASSIGN aux_flgsuces = FALSE.

           RUN Grava_Dados ( INPUT "X" ).

           IF  RETURN-VALUE <> "OK" THEN
               NEXT.
           ELSE
               ASSIGN aux_flgsuces = YES.

           LEAVE.
       END.
   ELSE
   IF  FRAME-VALUE = p_opcao[4] THEN /* SOLICITAR ITG */
       DO:
           ASSIGN glb_nmrotina = "CONTA CORRENTE"
                  glb_cddopcao = "S".
       
           { includes/acesso.i }

           RUN Valida_Dados ( INPUT "S" ).

           IF  RETURN-VALUE <> "OK" THEN
               NEXT.

           HIDE MESSAGE NO-PAUSE.

           ASSIGN aux_flgsuces = FALSE.

           RUN Grava_Dados ( INPUT "S" ).

           IF  RETURN-VALUE <> "OK" THEN
               NEXT.
           ELSE
               ASSIGN aux_flgsuces = YES.
           
           LEAVE.
       END.
   ELSE
   IF  FRAME-VALUE = p_opcao[5]   THEN /* Conta Consorcio */
       DO:
           ASSIGN glb_nmrotina = "CONTA CORRENTE"
                  glb_cddopcao = "G".
       
           { includes/acesso.i }

           ASSIGN aux_flgsuces = FALSE.

           RUN Gera_Conta_Consorcio.

           IF  RETURN-VALUE <> "OK" THEN
               NEXT.
           ELSE
               ASSIGN aux_flgsuces = YES.

           LEAVE.
       END.

   LEAVE.

END.  /* Fim do While True */

IF  VALID-HANDLE(h-b1wgen0074) THEN
    DELETE OBJECT h-b1wgen0074.

IF  VALID-HANDLE(h-b1wgen0060) THEN
    DELETE OBJECT h-b1wgen0060.

IF   aux_flgsuces   THEN
     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

         MESSAGE "Alteracao efetuada com sucesso!".
         PAUSE 2 NO-MESSAGE.
         LEAVE.
     END.

HIDE MESSAGE NO-PAUSE.

HIDE FRAME f_contas_corrente NO-PAUSE.
    
PROCEDURE Busca_Dados:

    RUN Busca_Dados IN h-b1wgen0074
        ( INPUT glb_cdcooper, 
          INPUT 0,            
          INPUT 0,            
          INPUT glb_cdoperad, 
          INPUT glb_nmdatela, 
          INPUT 1,            
          INPUT tel_nrdconta, 
          INPUT glb_dtmvtolt,
          INPUT tel_idseqttl, 
          INPUT YES,
          INPUT glb_cddopcao,
         OUTPUT TABLE tt-conta-corr,
         OUTPUT TABLE tt-erro ) NO-ERROR.

    IF  ERROR-STATUS:ERROR THEN
        DO:
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               MESSAGE tt-erro.dscritic.
                  
           RETURN "NOK".
        END.

    RETURN "OK".
END.

PROCEDURE Atualiza_Tela:

    FIND FIRST tt-conta-corr NO-ERROR.

    IF  AVAILABLE tt-conta-corr THEN
        DO:
           ASSIGN
               tel_cdagepac = tt-conta-corr.cdagepac    
               tel_dsagenci = tt-conta-corr.dsagepac
               tel_cdtipcta = tt-conta-corr.cdtipcta    
               tel_dstipcta = tt-conta-corr.dstipcta
               tel_cdsitdct = tt-conta-corr.cdsitdct    
               tel_dssitdct = tt-conta-corr.dssitdct    
               tel_nrdctitg = tt-conta-corr.nrdctitg    
               tel_flgiddep = tt-conta-corr.flgiddep    
               tel_tpavsdeb = tt-conta-corr.tpavsdeb    
               tel_dsavsdeb = tt-conta-corr.dsavsdeb    
               tel_tpextcta = tt-conta-corr.tpextcta
               tel_dsextcta = tt-conta-corr.dsextcta    
               tel_cdsecext = tt-conta-corr.cdsecext    
               tel_dssecext = tt-conta-corr.dssecext    
               tel_dtcnsscr = tt-conta-corr.dtcnsscr
               tel_dtcnsspc = tt-conta-corr.dtcnsspc    
               tel_dtdsdspc = tt-conta-corr.dtdsdspc    
               tel_dsinadim = (IF tt-conta-corr.inadimpl = 0 THEN "N" ELSE "S")
               tel_dslbacen = (IF tt-conta-corr.inlbacen = 0 THEN "N" ELSE "S")
               tel_dtmvtolt = tt-conta-corr.dtabtcoo    
               tel_dtelimin = tt-conta-corr.dtelimin    
               tel_dtabtcct = tt-conta-corr.dtabtcct        
               tel_dtdemiss = tt-conta-corr.dtdemiss
               tel_dssititg = tt-conta-corr.dssititg 
               tel_cdbcochq = tt-conta-corr.cdbcochq
               tel_cdagedbb = tt-conta-corr.cdagedbb
               aux_flgctitg = tt-conta-corr.flgctitg
               aux_flgtitul = tt-conta-corr.flgtitul
               aux_inpessoa = tt-conta-corr.inpessoa
               aux_inadimpl = tt-conta-corr.inadimpl
               aux_inlbacen = tt-conta-corr.inlbacen
               aux_cdbcoctl = tt-conta-corr.cdbcoctl
               aux_btaltera = tt-conta-corr.btaltera 
               aux_btencitg = tt-conta-corr.btencitg 
               aux_btexcttl = tt-conta-corr.btexcttl 
               aux_btsolitg = tt-conta-corr.btsolitg
               tel_flgrestr = tt-conta-corr.flgrestr
               tel_nrctacns = tt-conta-corr.nrctacns
               tel_incadpos = tt-conta-corr.dscadpos.

        END.
    ELSE
        ASSIGN
            tel_cdagepac = 0
            tel_dsagenci = ""
            tel_cdtipcta = 0
            tel_dstipcta = ""
            tel_cdsitdct = 0
            tel_dssitdct = ""
            tel_nrdctitg = ""
            tel_flgiddep = NO
            tel_tpavsdeb = 0
            tel_dsavsdeb = ""
            tel_tpextcta = 0
            tel_dsextcta = ""
            tel_cdsecext = 0
            tel_dssecext = ""
            tel_dtcnsscr = ?
            tel_dtcnsspc = ?
            tel_dtdsdspc = ?
            tel_dsinadim = "N"
            tel_dslbacen = "N"
            tel_dtmvtolt = ?
            tel_dtelimin = ?
            tel_dtabtcct = ?
            tel_dtdemiss = ?
            tel_dssititg = ""
            tel_cdbcochq = 0
            tel_nrctacns = 0
            tel_incadpos = "".

    RETURN "OK".
END.

PROCEDURE Valida_Dados:

    DEF  INPUT PARAM par_tpevento AS CHAR NO-UNDO.
    
    RUN Valida_Dados IN h-b1wgen0074
        ( INPUT glb_cdcooper, 
          INPUT 0,            
          INPUT 0,            
          INPUT glb_cdoperad, 
          INPUT glb_nmdatela, 
          INPUT 1,            
          INPUT tel_nrdconta, 
          INPUT tel_idseqttl, 
          INPUT TRUE,
          INPUT glb_dtmvtolt,
          INPUT par_tpevento,
          INPUT tel_cdtipcta,
          INPUT tel_cdbcochq,
          INPUT tel_tpextcta,
          INPUT tel_cdagepac,
          INPUT tel_cdsitdct,
          INPUT tel_cdsecext, 
          INPUT tel_tpavsdeb,
          INPUT aux_inadimpl,
          INPUT aux_inlbacen,
          INPUT tel_dtdsdspc,
          INPUT aux_flgexclu,
         OUTPUT aux_flgcreca,
         OUTPUT aux_tipconfi,
         OUTPUT aux_msgconfi,
         OUTPUT aux_nmdcampo,
         OUTPUT TABLE tt-erro ) NO-ERROR.

    IF  ERROR-STATUS:ERROR THEN
        DO:
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               MESSAGE tt-erro.dscritic.
                  
           RETURN "NOK".
        END.

    RETURN "OK".
END.

PROCEDURE Grava_Dados:

    DEF  INPUT PARAM par_tpevento AS CHAR NO-UNDO.
     
    aux_indserma = FALSE.

    /* retornou 1 ou 2 da validacao de dados */
    CASE aux_tipconfi:
        WHEN 0 THEN DO:
            IF  aux_msgconfi = ""  THEN 
                ASSIGN aux_msgconfi = "078 - Confirma a operacao? (S/N)".

            ASSIGN aux_confirma = "N".

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                MESSAGE COLOR NORMAL aux_msgconfi 
                        UPDATE aux_confirma.
                LEAVE.
            END.

            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                aux_confirma <>  "S"                 THEN
                DO:
                    MESSAGE "079 - Operacao nao efetuada.".
                    RETURN "NOK".
                END.
        END.
        WHEN 1 THEN DO:
            IF  aux_msgconfi <> "" THEN 
                DO:
                    ASSIGN aux_confirma = "N".

                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        MESSAGE aux_msgconfi.
                        MESSAGE COLOR NORMAL "078 - Confirma a operacao? (S/N)"
                            UPDATE aux_confirma.
                        LEAVE.
                    END.

                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  OR
                        aux_confirma <>  "S"                THEN
                        DO:
                            MESSAGE "079 - Operacao nao efetuada.". 
                            RETURN "NOK".
                        END.
                END.
        END.
        WHEN 2 THEN DO:
            ASSIGN aux_flgderro = NO.
            
            /* impressao das criticas */
            IF  aux_inpessoa = 1  THEN
                RUN fontes/critica_cadastro_fisica.p (INPUT tel_nrdconta,
                                                     OUTPUT aux_flgderro).
            ELSE
                RUN fontes/critica_cadastro_juridica.p (INPUT tel_nrdconta,
                                                       OUTPUT aux_flgderro).

            /* se encontrou erro deve abortar a operacao */
            IF  aux_flgderro THEN
                RETURN "NOK".
        END.
    END CASE.

    FOR FIRST crapass FIELDS(idastcjt) WHERE crapass.cdcooper = glb_cdcooper
                                         AND crapass.nrdconta = tel_nrdconta NO-LOCK. END.

    IF  VALID-HANDLE(h-b1wgen0074) THEN
        DELETE OBJECT h-b1wgen0074.

    RUN sistema/generico/procedures/b1wgen0074.p PERSISTENT SET h-b1wgen0074.

    RUN Grava_Dados IN h-b1wgen0074
        ( INPUT glb_cdcooper, 
          INPUT 0,            
          INPUT 0,            
          INPUT glb_cdoperad, 
          INPUT glb_nmdatela, 
          INPUT 1,            
          INPUT tel_nrdconta, 
          INPUT tel_idseqttl, 
          INPUT YES,
          INPUT ?,
          INPUT glb_dtmvtolt,
          INPUT glb_cddopcao,
          INPUT par_tpevento,
          INPUT aux_flgcreca,
          INPUT tel_cdtipcta,
          INPUT tel_cdsitdct,
          INPUT tel_cdsecext,
          INPUT tel_tpextcta,
          INPUT tel_cdagepac,
          INPUT tel_cdbcochq,
          INPUT tel_flgiddep,
          INPUT tel_tpavsdeb,
          INPUT tel_dtcnsscr,
          INPUT tel_dtcnsspc,
          INPUT tel_dtdsdspc,
          INPUT aux_inadimpl,
          INPUT aux_inlbacen,
          INPUT aux_flgexclu,
          INPUT tel_flgrestr,
          INPUT aux_indserma,
          INPUT crapass.idastcjt,
         OUTPUT aux_tpatlcad,
         OUTPUT aux_msgatcad,
         OUTPUT aux_chavealt,
         OUTPUT TABLE tt-erro ) NO-ERROR.

    IF  ERROR-STATUS:ERROR THEN
        DO:
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               MESSAGE tt-erro.dscritic.
               
           RETURN "NOK".
        END.

    /* verificar se é necessario registrar o crapalt */
    RUN proc_altcad (INPUT "b1wgen0074.p").

    DELETE OBJECT h-b1wgen0074.

    IF  RETURN-VALUE <> "OK" THEN
        NEXT.

    RETURN "OK".
END.

PROCEDURE Exclusao_Titulares:

  DEFINE VARIABLE aux_msgconfi AS CHARACTER   NO-UNDO.

  FORM "    "
       tt-titulares.idseqttl                     COLUMN-LABEL "Sequencia"
       tt-titulares.nmextttl FORMAT "x(40)"      COLUMN-LABEL "Nome do Titular"
       "    "
       WITH 3 DOWN ROW 13 CENTERED OVERLAY TITLE " TITULARES " 
            FRAME f_titulares.    

  RUN Busca_Titulares IN h-b1wgen0074
      ( INPUT glb_cdcooper,
        INPUT tel_nrdconta,
       OUTPUT TABLE tt-titulares ) NO-ERROR.

  IF  ERROR-STATUS:ERROR THEN
      DO:
         MESSAGE ERROR-STATUS:GET-MESSAGE(1).
         RETURN "NOK".
      END.

  FOR EACH tt-titulares:

      DISPLAY 
          tt-titulares.idseqttl  
          tt-titulares.nmextttl 
          WITH FRAME f_titulares.
      DOWN WITH FRAME f_titulares.

  END.
       
  RETURN "OK".
       
END PROCEDURE.  /*  Fim da Procedure  */

PROCEDURE Gera_Conta_Consorcio:

  RUN fontes/confirma.p (INPUT "",
                        OUTPUT aux_confirma).

  IF   aux_confirma <> "S"   THEN
       RETURN "NOK".

  RUN sistema/generico/procedures/b1wgen0074.p 
      PERSISTENT SET h-b1wgen0074.

  RUN Gera_Conta_Consorcio IN h-b1wgen0074 
                           (INPUT glb_cdcooper,
                            INPUT 0,
                            INPUT glb_dtmvtolt,
                            INPUT 0,
                            INPUT tel_nrdconta,
                            INPUT glb_cdoperad,
                           OUTPUT TABLE tt-erro,
                           OUTPUT tel_nrctacns).

  DELETE PROCEDURE h-b1wgen0074.

  IF   RETURN-VALUE <> "OK"   THEN
       DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF   AVAIL tt-erro   THEN
                MESSAGE tt-erro.dscritic.
           ELSE
                MESSAGE "Nao foi possivel concluir a operacao".

           RETURN "NOK".
       END.

  DISPLAY tel_nrctacns WITH FRAME f_contas_corrente.

  RETURN "OK".

END PROCEDURE.

/* ......................................................................... */



