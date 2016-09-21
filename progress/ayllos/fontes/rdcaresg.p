/* .............................................................................

   Programa: Fontes/rdcaresg.p               
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Eduardo           
   Data    : Julho/2001.                     Ultima atualizacao: 29/06/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para montar o saldo das aplicacoes financeiras, mostrar
               o extrato das mesmas para a tela ATENDA com a opcao de RESGATE.

   Alteracoes: 03/04/2002 - Tratamento do resgate on_line (Margarete).

               06/01/2004 - Mostrar saldos negativos (Margarete).
 
               02/09/2004 - Incluido Flag Conta Investimento(Mirtes).
               
               08/11/2004 - Aumentado tamanho do campo do numero da aplicacao
                            para 7 posicoes, na leitura da tabela (Evandro).
                            
               10/12/2004 - Ajustes para tratar das novas aliquotas de 
                           IRRF (Margarete).

               06/05/2005 - Resgate total(dia), listar aplicacao , para poder 
                            efetuar o cancelamento do resgate(Mirtes)

               31/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando 
               
               19/09/2006 - Permitir o uso do F2-AJUDA (Evandro).
               
               17/05/2007 - Atender aos novos tipos de aplicacao (David).

               26/10/2007 - Incluida opcao "Acumula" (Elton).

               29/11/2007 - Aumentado formato dos campos valor aplicado e
                            saldo para resgate (Magui).
                            
               28/04/2010 - Utilizar a includes includes/var_rdcapp2.i 
                            (Gabriel).
                            
               29/07/2010 - Alteração da descrição do campo "RDCPOS" para
                            "RDC9999" (Vitor).
                            
               24/08/2010 - Incluidas as opcoes "Inclusao", "Alteracao" e 
                            "Exclusao" e modificacao da chamada da "LEITURA"
                            p/ procedure leitura-dados-tabela (Vitor).
                            
               06/10/2010 - Incluidas as chamadas das procedures validar-tipo-
                            aplicacao, valida-numero-aplicacao, calcula-venci-
                            mento-aplicacao, calcula-vencimento-rdcpre e
                            calcula-debito-credito (Vitor).
                          - Ajuste na alteracao acima para Ayllos WEB (David).
                          
               29/11/2010 - Utilizar BO b1wgen0081.p (Adriano).
                                                    
               08/12/2010 - Incluido parametro na chamada da funcao de resgate
                            (Henrique).

               18/09/2012 - Novos parametros DATA na chamada da procedure
                            obtem-dados-aplicacoes (Guilherme/Supero).
                            
               03/06/2013 - Busca Saldo Bloqueio Judicial
                            (Andre Santos - SUPERO)        
               
               28/08/2013 - Alterações produtos RDCPOS (Lucas).
               
               25/04/2014 - Ajustes referente ao projeto de captacao
                            (Adriano).
                            
               23/07/2014 - Ajustes referente ao projeto de captacao, inclusao
                            de opcoes de produtos (Jean Michel).
               
               08/12/2014 - Ajustes referente a data de vencimento de aplicacoes
                            (Jean Michel). 
                            
               11/03/2015 - Inclusao de tratamento da tecla "F1" para os campos
                            tel_flgrecno, tel_vllanmto (Jean Michel).

			   28/04/2015 - Adicionado novo campo de data de carencia, e removido 
                            o campo descricao de historico. SD 266191 (Kelvin/Gielow)                            
               
			   29/04/2015 - Colocado DO TRANSACTION na insercao de aplicacoes
                            (Jean Michel).

               29/06/2015 - Ajustado a busca do saldo do dia chamando a 
                           pc_obtem_saldo_dia_prog
                           (Douglas - Chamado 285228 - obtem-saldo-dia)
............................................................................ */

{ includes/var_online.i }
{ includes/var_atenda.i }
{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/b1wgen0001tt.i }
{ sistema/generico/includes/b1wgen0003tt.i }
{ sistema/generico/includes/b1wgen0004tt.i }
{ sistema/generico/includes/b1wgen0020tt.i }
{ sistema/generico/includes/b1wgen0081tt.i }
{ sistema/generico/includes/var_oracle.i }

DEF VAR reg_cddopcao AS CHAR EXTENT 4 INIT ["I","E","R","A"]            NO-UNDO.
DEF VAR reg_dsdopcao AS CHAR EXTENT 4 INIT ["Aplicacao","Excluir",
                                            "Resgate","Acumula"]        NO-UNDO.

DEF VAR reg_contador AS INTE INIT 1                                     NO-UNDO.

DEF VAR tel_tpaplica AS INTE                                            NO-UNDO.
DEF VAR tel_qtdiacar AS INTE                                            NO-UNDO.
DEF VAR tel_qtdiaapl AS INTE                                            NO-UNDO.

DEF VAR tel_dtvencto AS DATE                                            NO-UNDO.
DEF VAR tel_dtresgat AS DATE                                            NO-UNDO.
DEF VAR tel_dtcarenc AS DATE                                            NO-UNDO.

DEF VAR tel_flgdebci AS LOGI                                            NO-UNDO.

DEF VAR tel_vllanmto AS DECI                                            NO-UNDO.

DEF VAR tel_cddresga AS CHAR                                            NO-UNDO.
DEF VAR tel_dssitapl AS CHAR                                            NO-UNDO.
DEF VAR tel_txaplmax AS CHAR                                            NO-UNDO. 
DEF VAR tel_txaplmin AS CHAR                                            NO-UNDO. 
DEF VAR tel_nrdocmto AS CHAR                                            NO-UNDO.
DEF VAR tel_dsaplica AS CHAR                                            NO-UNDO.
DEF VAR tel_nmprdcom AS CHAR                                            NO-UNDO.

DEF VAR tel_txaplica LIKE craplap.txaplica                              NO-UNDO.

DEF VAR aux_nraplica AS INTE                                            NO-UNDO.
DEF VAR aux_nrdlinha AS INTE                                            NO-UNDO.
DEF VAR aux_cdperapl AS INTE                                            NO-UNDO.
DEF VAR aux_tpaplrdc AS INTE                                            NO-UNDO.
DEF VAR aux_dtvencto AS DATE                                            NO-UNDO.
DEF VAR aux_qtdiaapl AS INTE                                            NO-UNDO.
DEF VAR aux_tpaplica AS INTE INIT 0                                     NO-UNDO.
DEF VAR aux_idtipapl AS CHAR                                            NO-UNDO.

DEF VAR aux_flgerlog AS LOGI                                            NO-UNDO.
DEF VAR aux_flgsenha AS LOGI                                            NO-UNDO.
DEF VAR tel_flgrecno AS LOGI                                            NO-UNDO.

DEF VAR aux_confirma AS CHAR FORMAT "!(1)"                              NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                            NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                            NO-UNDO.
DEF VAR aux_desdhelp AS CHAR                                            NO-UNDO.
DEF VAR aux_titframe AS CHAR                                            NO-UNDO.
DEF VAR aux_nrdocmto AS DEC                                             NO-UNDO.
DEF VAR aux_txaplmes LIKE craplap.txaplmes                              NO-UNDO.

DEF VAR aux_qtdiacar  LIKE crapmpc.qtdiacar                             NO-UNDO. 
DEF VAR aux_qtdiaprz  LIKE crapmpc.qtdiaprz                             NO-UNDO. 
DEF VAR aux_cdprodut  LIKE crapcpc.cdprodut                             NO-UNDO.

DEF VAR tel_vlblqjud AS DECI FORMAT "zzz,zzz,zz9.99"                    NO-UNDO.
DEF VAR aux_vlblqjud AS DECI FORMAT "zzz,zzz,zz9.99"                    NO-UNDO.
DEF VAR aux_vlresblq AS DECI FORMAT "zzz,zzz,zz9.99"                    NO-UNDO.

DEF VAR aux_cdcritic AS INTEGER                                         NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                            NO-UNDO.

DEF VAR h-b1wgen0155 AS HANDLE                                          NO-UNDO.
DEF VAR h-b1wgen0001 AS HANDLE                                          NO-UNDO.
DEF VAR h-b1wgen0003 AS HANDLE                                          NO-UNDO.
DEF VAR h-b1wgen0081 AS HANDLE                                          NO-UNDO.
DEF VAR h-b1wgen0020 AS HANDLE                                          NO-UNDO.

/* Variaveis para o XML */ 
DEF VAR xDoc          AS HANDLE   NO-UNDO.   
DEF VAR xRoot         AS HANDLE   NO-UNDO.  
DEF VAR xRoot2        AS HANDLE   NO-UNDO.  
DEF VAR xField        AS HANDLE   NO-UNDO. 
DEF VAR xText         AS HANDLE   NO-UNDO. 
DEF VAR aux_cont_raiz AS INTEGER  NO-UNDO. 
DEF VAR aux_cont      AS INTEGER  NO-UNDO. 
DEF VAR ponteiro_xml  AS MEMPTR   NO-UNDO. 
DEF VAR xml_req       AS LONGCHAR NO-UNDO.

DEF QUERY q_aplicacoes      FOR tt-saldo-rdca.
DEF QUERY q_periodos        FOR tt-carencia-aplicacao.
DEF QUERY q_periodos_novo   FOR tt-carencia-aplicacao-novo.

DEF BROWSE b_aplicacoes QUERY q_aplicacoes
    DISP tt-saldo-rdca.dtmvtolt LABEL "Data"         FORMAT "99/99/99"
         tt-saldo-rdca.dshistor LABEL "Historico"    FORMAT "x(12)"
         tt-saldo-rdca.qtdiauti LABEL "Car."         FORMAT "9999"
         tt-saldo-rdca.vlaplica LABEL "Valor"        FORMAT "zzzzz,zz9.99"
         tt-saldo-rdca.dtvencto LABEL "Vencto"       FORMAT "99/99/99"    
         tt-saldo-rdca.vllanmto LABEL "Saldo"        FORMAT "zzzzz,zz9.99"
         tt-saldo-rdca.sldresga LABEL "Saldo p/Resg" FORMAT "zzzzz,zz9.99"
         WITH 4 DOWN NO-BOX.

DEF BROWSE b_periodos QUERY q_periodos
   DISP tt-carencia-aplicacao.cdperapl LABEL "Periodo"  FORMAT "z9"   
        tt-carencia-aplicacao.qtdiaini LABEL "Inicio"   FORMAT "zzz9" 
        tt-carencia-aplicacao.qtdiafim LABEL "Fim"      FORMAT "zzz9" 
        tt-carencia-aplicacao.qtdiacar LABEL "Carencia" FORMAT "zzz9"  
        WITH NO-LABEL NO-BOX OVERLAY 3 DOWN.

DEF BROWSE b_periodos_novo QUERY q_periodos_novo
   DISP tt-carencia-aplicacao-novo.qtdiacar LABEL "Carencia"   FORMAT "zzz9" 
        tt-carencia-aplicacao-novo.qtdiaprz LABEL "Prazo"      FORMAT "zzz9"  
        WITH NO-LABEL NO-BOX OVERLAY 3 DOWN.

FORM SKIP(10)
     reg_dsdopcao[1] AT 20 FORMAT "x(9)"
     reg_dsdopcao[2] AT 32 FORMAT "x(7)"
     reg_dsdopcao[3] AT 42 FORMAT "x(7)"
     reg_dsdopcao[4] AT 52 FORMAT "x(7)"
     WITH ROW 9 WIDTH 80 OVERLAY NO-LABEL TITLE " Escolha a Aplicacao " 
          FRAME f_regua. 

FORM b_aplicacoes HELP "Pressione ENTER para selecionar ou F4/END para sair."
     SKIP
     "----------------------------------------------------------------" AT 03
     SPACE(0)
     "----------"
     SKIP
     SPACE(1)
     tel_dssitapl LABEL "Sit"     FORMAT "x(1)"
     SPACE(1)
     tel_txaplmax LABEL "Tx.Ctr"  FORMAT "x(12)"
     tel_txaplmin LABEL "Tx.Min"  FORMAT "x(12)"
     SPACE(2)
     tel_cddresga LABEL "Resg"    FORMAT "x(1)"
     tel_dtresgat LABEL "Dt.Resg" FORMAT "99/99/9999"
     SKIP
     SPACE(1)
     tel_vlblqjud LABEL "Valor Bloq. Judicial"
     tel_nrdocmto LABEL "Numero da Aplicacao" FORMAT "x(6)" AT 45
     "----------------------------------------------------------------" AT 03
     SPACE(0)
     "----------"
     WITH ROW 10 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_browse.

FORM b_periodos
     HELP "Use as SETAS para navegar e <F4> para sair" 
     WITH CENTERED OVERLAY ROW 15 FRAME f_periodos TITLE "Periodos".

FORM b_periodos_novo
     HELP "Use as SETAS para navegar e <F4> para sair" 
     WITH CENTERED OVERLAY ROW 15 FRAME f_periodos_novo TITLE "Periodos".

FORM SKIP(11)
      WITH ROW 9 WIDTH 50 CENTERED OVERLAY SIDE-LABELS 
           FRAME f_opcao TITLE aux_titframe.

FORM SKIP(1)
     tel_dsaplica AT 4 LABEL "Tipo de Aplicacao"   FORMAT "X(20)"
        HELP "Pressione F7 para listar os tipos de aplicacao."
     WITH ROW 10 WIDTH 45 CENTERED OVERLAY NO-BOX SIDE-LABELS 
          FRAME f_tipo_aplic.

FORM tel_vllanmto AT 16 LABEL "Valor"               FORMAT "zzzzz,zz9.99"
         HELP "Entre com o valor da aplicacao."
     SKIP
     tel_qtdiacar AT 13 LABEL "Carencia"            FORMAT "9999"
         HELP "Pressione <F7> para selecionar a carencia"
     SKIP
     tel_dtcarenc AT 8 LABEL "Data Carencia"       FORMAT "99/99/9999"
     SKIP
     tel_flgdebci AT 3  LABEL "Conta Investimento" FORMAT "SIM/NAO"
         HELP "Debitar Conta Investimento (S/N)"
     SKIP
     
     tel_txaplica AT 6 LABEL "Percentual/Taxa"     FORMAT "zz9.99999999" 
     SKIP

     tel_flgrecno AT 09 LABEL "Recurso Novo"       FORMAT "SIM/NAO"
        HELP "Recurso Novo (S/N)"
     SKIP

     tel_nmprdcom AT 19 NO-LABEL                    FORMAT "X(20)" 
     SKIP(1)
     tel_dtvencto AT 11 LABEL "Vencimento"          FORMAT "99/99/9999"
         HELP "Entre com a data do vencimento"
     WITH ROW 12 WIDTH 45 CENTERED OVERLAY SIDE-LABELS NO-BOX 
          FRAME f_aplic_pos.

FORM tel_qtdiaapl AT 17 LABEL "Dias"                FORMAT "9999"
         HELP "Informe o periodo da aplicacao."
     SKIP   
     tel_dtvencto AT 11 LABEL "Vencimento"          FORMAT "99/99/9999"
         HELP "Entre com a data do vencimento"
     SKIP
     tel_qtdiacar AT 13 LABEL "Carencia"            FORMAT "999"
         HELP "Pressione <F7> para selecionar a carencia"
     SKIP
     tel_flgdebci AT 03  LABEL "Conta Investimento" FORMAT "SIM/NAO"
         HELP "Debitar Conta Investimento (S/N)"
     SKIP
     tel_vllanmto AT 16 LABEL "Valor"               FORMAT "zzzzz,zz9.99"
         HELP "Entre com o valor da aplicacao."
     SKIP
     tel_txaplica AT 06 LABEL "Percentual/Taxa"     FORMAT "zz9.99999999"
     SKIP
     tel_dsaplica AT 17 NO-LABEL                    FORMAT "X(12)"
     WITH ROW 12 WIDTH 45 CENTERED OVERLAY SIDE-LABELS NO-BOX 
          FRAME f_aplic_pre.

ON LEAVE OF tel_dsaplica IN FRAME f_tipo_aplic DO:
    
   HIDE MESSAGE NO-PAUSE.
    
   IF NOT VALID-HANDLE(h-b1wgen0081) THEN
     RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT SET h-b1wgen0081.

   RUN validar-tipo-aplicacao IN h-b1wgen0081 (INPUT glb_cdcooper,
                                               INPUT 0,
                                               INPUT 0,
                                               INPUT glb_cdoperad,
                                               INPUT glb_nmdatela,
                                               INPUT 1,
                                               INPUT tel_nrdconta,
                                               INPUT 1,
                                               INPUT aux_tpaplica,
                                               INPUT TRUE,
                                              OUTPUT aux_tpaplrdc,
                                              OUTPUT TABLE tt-erro).

   IF VALID-HANDLE(h-b1wgen0081) THEN
     DELETE PROCEDURE h-b1wgen0081. 
       
   IF RETURN-VALUE = "NOK"  THEN
      DO:
          FIND FIRST tt-erro NO-LOCK NO-ERROR.

          IF AVAIL tt-erro  THEN
             DO:
                 BELL.
                 MESSAGE tt-erro.dscritic.
             END.

          RETURN NO-APPLY.

      END.

   IF aux_tpaplrdc = 1  THEN  /** RDCPRE **/
      DO:    
        
          ASSIGN tel_qtdiaapl = 0.
          DISPLAY "" @ tel_qtdiaapl 
                  tel_flgdebci
                  WITH FRAME f_aplic_pre.

          ENABLE tel_vllanmto
                 tel_qtdiaapl
                 WITH FRAME f_aplic_pre.
      END.
   ELSE  /** RDCPOS **/
      DO:
        
          DISPLAY tel_qtdiacar WITH FRAME f_aplic_pos.
          
          DISPLAY "" @ tel_qtdiacar 
                   tel_flgdebci
                   WITH FRAME f_aplic_pos.
          
          ENABLE tel_vllanmto
                 tel_dtvencto
                 WITH FRAME f_aplic_pos.
          
      END.
    
END.

ON F1 OF tel_flgrecno, tel_vllanmto  IN FRAME f_aplic_pos DO:
    APPLY "RETURN" TO tel_dtvencto IN FRAME f_aplic_pos.
END.

ON RETURN OF tel_dtvencto IN FRAME f_aplic_pos DO:
    
   DO WITH FRAME f_aplic_pos.
        
      ASSIGN tel_dtvencto = INPUT tel_dtvencto
             aux_dtvencto = tel_dtvencto NO-ERROR.
      
   END.

   IF ERROR-STATUS:ERROR   THEN
      RETURN NO-APPLY.
   
   HIDE MESSAGE NO-PAUSE.
           
   IF aux_idtipapl = "A" THEN
       DO:
           ASSIGN aux_qtdiaapl = 0.

           IF NOT VALID-HANDLE(h-b1wgen0081) THEN
              RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT SET h-b1wgen0081.
           
           RUN calcula-permanencia-resgate IN h-b1wgen0081
                                          (INPUT glb_cdcooper,
                                           INPUT 0, /*cdagenci*/
                                           INPUT 0, /*nrdcaixa*/
                                           INPUT glb_cdoperad,   
                                           INPUT glb_nmdatela,
                                           INPUT 1, /*idorigem - ayllos*/
                                           INPUT tel_nrdconta,
                                           INPUT 1, /*idseqttl*/
                                           INPUT aux_tpaplica,
                                           INPUT glb_dtmvtolt,
                                           INPUT TRUE, /*flgerlog*/
                                           INPUT tel_qtdiacar, 
                                           INPUT-OUTPUT aux_qtdiaapl,
                                           INPUT-OUTPUT tel_dtvencto,
                                          OUTPUT TABLE tt-erro).
                                          
           IF VALID-HANDLE(h-b1wgen0081) THEN
              DELETE PROCEDURE h-b1wgen0081. 
        
           IF RETURN-VALUE = "NOK"  THEN
              DO: 
                 ASSIGN tel_dtvencto = aux_dtvencto.
        
                 DISPLAY tel_dtvencto WITH FRAME f_aplic_pos.
        
                 FIND FIRST tt-erro NO-LOCK NO-ERROR.
                 
                 IF AVAIL tt-erro  THEN
                    DO: 
                        BELL.
                        MESSAGE tt-erro.dscritic.
                    END.
             
                 RETURN NO-APPLY.
        
              END.

           ASSIGN tel_dtvencto = aux_dtvencto.
        
           DISPLAY tel_dtvencto
                   WITH FRAME f_aplic_pos.
            
       END.
   ELSE
       DO:
       
           ASSIGN glb_cdcritic = ?
                  glb_dscritic = ?.

           MESSAGE "Validando data de vencimento. Aguarde ...".
           
           { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} } 
           
           /* Efetuar a chamada a rotina Oracle */ 
           RUN STORED-PROCEDURE pc_calcula_prazo_aplicacao
                aux_handproc = PROC-HANDLE NO-ERROR(INPUT glb_cdcooper,
                                                    INPUT tel_dtcarenc,
                                                    INPUT tel_dtvencto,
                                                    INPUT aux_qtdiaprz,
                                                    OUTPUT 0,
                                                    OUTPUT 0,
                                                    OUTPUT "").
           
           /* Fechar o procedimento para buscarmos o resultado */ 
           CLOSE STORED-PROC pc_calcula_prazo_aplicacao
                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
         
           { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} } 
           
           /* Busca possíveis erros */ 
           ASSIGN glb_cdcritic = pc_calcula_prazo_aplicacao.pr_cdcritic.
           ASSIGN glb_dscritic = pc_calcula_prazo_aplicacao.pr_dscritic.
           
           ASSIGN aux_qtdiaapl = pc_calcula_prazo_aplicacao.pr_qtdiaapl 
              WHEN pc_calcula_prazo_aplicacao.pr_qtdiaapl <> ?.
           
           ASSIGN tel_qtdiaapl = aux_qtdiaapl.
           
           HIDE MESSAGE NO-PAUSE.
            
           IF glb_dscritic <> ?  THEN
            DO: 
                BELL.
                MESSAGE glb_dscritic.
                PAUSE 3 NO-MESSAGE.
                HIDE MESSAGE NO-PAUSE.
                ASSIGN tel_dtvencto = ?.
                DISPLAY tel_dtvencto 
                   WITH FRAME f_aplic_pos.
                RETURN NO-APPLY.
            END.
           
           DISPLAY tel_dtvencto 
                   WITH FRAME f_aplic_pos.
         /**/
       END. 
END.
                         
ON RETURN, TAB OF tel_vllanmto IN FRAME f_aplic_pos DO:
   
   HIDE MESSAGE NO-PAUSE.
   
   IF aux_idtipapl = "A" THEN
        DO:
           
           RUN zoom_carencia.

           IF RETURN-VALUE = "NOK" THEN
              RETURN NO-APPLY.
        
           DO WITH FRAME f_aplic_pos:
               
              ASSIGN tel_vllanmto.
        
           END.    
        
           IF NOT VALID-HANDLE(h-b1wgen0081) THEN
              RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT SET h-b1wgen0081.
                                                 
           MESSAGE "Validando taxa. Aguarde ...".
           
           RUN obtem-taxa-aplicacao IN h-b1wgen0081 (INPUT glb_cdcooper,
                                                     INPUT 0,
                                                     INPUT 0,
                                                     INPUT glb_cdoperad,
                                                     INPUT glb_nmdatela,
                                                     INPUT 1,
                                                     INPUT tel_nrdconta,
                                                     INPUT 1,
                                                     INPUT aux_tpaplica,
                                                     INPUT aux_cdperapl,
                                                     INPUT tel_vllanmto,
                                                     INPUT TRUE,
                                                    OUTPUT tel_txaplica,
                                                    OUTPUT aux_txaplmes,
                                                    OUTPUT tel_nmprdcom,
                                                    OUTPUT TABLE tt-erro).
        
           HIDE MESSAGE NO-PAUSE.
        
           IF VALID-HANDLE(h-b1wgen0081) THEN
              DELETE PROCEDURE h-b1wgen0081.
           
           IF RETURN-VALUE = "NOK"  THEN
              DO:
                 FIND FIRST tt-erro NO-LOCK NO-ERROR.
        
                 IF AVAILABLE tt-erro  THEN
                    DO:
                        BELL.
                        MESSAGE tt-erro.dscritic.
                    END.
        
                 RETURN NO-APPLY.
        
              END.
           
           DISPLAY tel_txaplica 
                   tel_nmprdcom
                   WITH FRAME f_aplic_pos.
                           
           IF NOT VALID-HANDLE(h-b1wgen0081) THEN
              RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT SET h-b1wgen0081.
        
           MESSAGE "Calculando data para de vencimento. Aguarde ...".
           
           RUN calcula-permanencia-resgate IN h-b1wgen0081
                                          (INPUT glb_cdcooper,
                                           INPUT 0, /*cdagenci*/
                                           INPUT 0, /*nrdcaixa*/
                                           INPUT glb_cdoperad,   
                                           INPUT glb_nmdatela,
                                           INPUT 1, /*idorigem - ayllos*/
                                           INPUT tel_nrdconta,
                                           INPUT 1, /*idseqttl*/
                                           INPUT aux_tpaplica,
                                           INPUT glb_dtmvtolt,
                                           INPUT TRUE, /*flggerlog*/
                                           INPUT tel_qtdiacar, 
                                           INPUT-OUTPUT aux_qtdiaapl, 
                                           INPUT-OUTPUT tel_dtvencto,
                                          OUTPUT TABLE tt-erro).
        
           HIDE MESSAGE NO-PAUSE.
        
           IF VALID-HANDLE(h-b1wgen0081) THEN
              DELETE PROCEDURE h-b1wgen0081.                        
        
           IF RETURN-VALUE = "NOK"  THEN
              DO:
                 FIND FIRST tt-erro NO-LOCK NO-ERROR.
                 
                 IF AVAIL tt-erro  THEN
                    DO:
                        BELL.
                        MESSAGE tt-erro.dscritic.
                    END.
             
                 RETURN NO-APPLY.
        
              END.
           
           ASSIGN aux_dtvencto = tel_dtvencto
                  tel_flgdebci = FALSE.
        
           DISP tel_dtvencto tel_flgdebci
                WITH FRAME f_aplic_pos.

            
       END.
    ELSE
       DO:
            
           RUN zoom_carencia_captacao.
           
           IF RETURN-VALUE = "NOK"  THEN
             RETURN NO-APPLY.
           
           DO WITH FRAME f_aplic_pos:
             ASSIGN tel_vllanmto.
           END.
           
           ASSIGN aux_dtvencto = tel_dtvencto.
           
       END.
  
END.                          


ON LEAVE OF tel_qtdiaapl IN FRAME f_aplic_pre DO:
       
   HIDE MESSAGE NO-PAUSE.

   DO WITH FRAME f_aplic_pre:

       ASSIGN tel_qtdiaapl 
              tel_dtvencto.

   END.
   
   IF tel_qtdiaapl > 0 OR tel_dtvencto <> ?  THEN
      DO:
          IF NOT VALID-HANDLE(h-b1wgen0081) THEN
             RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT 
                 SET h-b1wgen0081.
   
          RUN calcula-permanencia-resgate IN h-b1wgen0081
                                 (INPUT glb_cdcooper,
                                  INPUT 0, /*cdagenci*/
                                  INPUT 0, /*nrdcaixa*/
                                  INPUT glb_cdoperad,   
                                  INPUT glb_nmdatela,
                                  INPUT 1, /*idorigem - ayllos*/
                                  INPUT tel_nrdconta,
                                  INPUT 1, /*idseqttl*/
                                  INPUT aux_tpaplica,
                                  INPUT glb_dtmvtolt,
                                  INPUT TRUE, /*flggerlog*/
                                  INPUT tel_qtdiacar, 
                                  INPUT-OUTPUT tel_qtdiaapl, 
                                  INPUT-OUTPUT tel_dtvencto,
                                  OUTPUT TABLE tt-erro).
                                         
          IF VALID-HANDLE(h-b1wgen0081) THEN
             DELETE PROCEDURE h-b1wgen0081. 
         
          IF RETURN-VALUE = "NOK"  THEN
             DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                
                IF AVAIL tt-erro  THEN
                   DO:
                       BELL.
                       MESSAGE tt-erro.dscritic.
                   END.
            
                RETURN NO-APPLY.

             END.
          
          ASSIGN tel_flgdebci = FALSE.

          DISPLAY tel_qtdiaapl 
                  tel_flgdebci
                  tel_dtvencto 
                  WITH FRAME f_aplic_pre.

      END.
        
END.

ON LEAVE OF tel_dtvencto IN FRAME f_aplic_pre DO:

   DO WITH FRAME f_aplic_pre.

      ASSIGN tel_qtdiaapl 
             tel_dtvencto 
             tel_qtdiacar NO-ERROR.

   END.

   IF  ERROR-STATUS:ERROR THEN
       RETURN NO-APPLY.
   
   HIDE MESSAGE NO-PAUSE.
           
   IF NOT VALID-HANDLE(h-b1wgen0081) THEN
      RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT SET h-b1wgen0081.

   RUN calcula-permanencia-resgate IN h-b1wgen0081
                                  (INPUT glb_cdcooper,
                                   INPUT 0, /*cdagenci*/
                                   INPUT 0, /*nrdcaixa*/
                                   INPUT glb_cdoperad,   
                                   INPUT glb_nmdatela,
                                   INPUT 1, /*idorigem - ayllos*/
                                   INPUT tel_nrdconta,
                                   INPUT 1, /*idseqttl*/
                                   INPUT aux_tpaplica,
                                   INPUT glb_dtmvtolt,
                                   INPUT TRUE, /*flgerlog*/
                                   INPUT tel_qtdiacar, 
                                   INPUT-OUTPUT tel_qtdiaapl,
                                   INPUT-OUTPUT tel_dtvencto,
                                   OUTPUT TABLE tt-erro).

   IF VALID-HANDLE(h-b1wgen0081) THEN                              
      DELETE PROCEDURE h-b1wgen0081. 
   
   IF RETURN-VALUE = "NOK"  THEN
      DO:
          FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
          IF AVAIL tt-erro  THEN
             DO:
                 BELL.
                 MESSAGE tt-erro.dscritic.
             END.
     
          RETURN NO-APPLY.

      END.
   
   DISPLAY tel_qtdiaapl 
           tel_dtvencto 
           WITH FRAME f_aplic_pre.

   IF tel_qtdiaapl <> tt-dados-aplicacao.qtdiaapl  THEN 
      DO:
          
          RUN zoom_carencia.

          IF RETURN-VALUE = "NOK"  THEN
             RETURN NO-APPLY.

      END.
   
END.

ON RETURN OF tel_vllanmto IN FRAME f_aplic_pre DO:

   HIDE MESSAGE NO-PAUSE.
                   
   DO WITH FRAME f_aplic_pre:
       
       ASSIGN tel_vllanmto.

   END.    
                     
   IF NOT VALID-HANDLE(h-b1wgen0081) THEN
      RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT SET h-b1wgen0081.

   MESSAGE "Validando taxa. Aguarde ...".
   
   RUN obtem-taxa-aplicacao IN h-b1wgen0081 (INPUT glb_cdcooper,
                                             INPUT 0,
                                             INPUT 0,
                                             INPUT glb_cdoperad,
                                             INPUT glb_nmdatela,
                                             INPUT 1,
                                             INPUT tel_nrdconta,
                                             INPUT 1,
                                             INPUT aux_tpaplica,
                                             INPUT aux_cdperapl,
                                             INPUT tel_vllanmto,
                                             INPUT TRUE,
                                            OUTPUT tel_txaplica,
                                            OUTPUT aux_txaplmes,
                                            OUTPUT tel_nmprdcom,
                                            OUTPUT TABLE tt-erro).

   HIDE MESSAGE NO-PAUSE.

   IF VALID-HANDLE(h-b1wgen0081) THEN
      DELETE PROCEDURE h-b1wgen0081.

   IF RETURN-VALUE = "NOK"  THEN
      DO:
         FIND FIRST tt-erro NO-LOCK NO-ERROR.

         IF AVAILABLE tt-erro  THEN
            DO:
                BELL.
                MESSAGE tt-erro.dscritic.
            END.

         RETURN NO-APPLY.

      END.
   
   DISPLAY tel_txaplica 
           tel_dsaplica 
           WITH FRAME f_aplic_pre.

END.     

ON RETURN OF b_periodos IN FRAME f_periodos DO:   
   
   ASSIGN tel_qtdiacar = tt-carencia-aplicacao.qtdiacar
          tel_dtcarenc = tt-carencia-aplicacao.dtcarenc
          aux_cdperapl = tt-carencia-aplicacao.cdperapl
          aux_qtdiaapl = tt-carencia-aplicacao.qtdiafim.
   
   DISPLAY tel_qtdiacar 
           tel_dtcarenc 
           WITH FRAME f_aplic_pos.
     
   APPLY "GO".

END.  

ON RETURN OF b_periodos_novo IN FRAME f_periodos_novo DO:   
    
   DO WITH FRAME f_aplic_pos:
     ASSIGN tel_vllanmto.   
   END.
   
   ASSIGN tel_qtdiacar = tt-carencia-aplicacao-novo.qtdiacar
          aux_qtdiaprz = tt-carencia-aplicacao-novo.qtdiaprz.
   
   MESSAGE "Consultando taxa. Aguarde ...".
   
   { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} } 
       
   /* Efetuar a chamada a rotina Oracle */ 
   RUN STORED-PROCEDURE pc_obtem_taxa_modalidade_car
        aux_handproc = PROC-HANDLE NO-ERROR(INPUT glb_cdcooper,
                                            INPUT tel_nrdconta,
                                            INPUT aux_tpaplica,
                                            INPUT tel_vllanmto,
                                            INPUT tel_qtdiacar,
                                            INPUT aux_qtdiaprz, 
                                            OUTPUT 0,
                                            OUTPUT "",  
                                            OUTPUT ?,
                                            OUTPUT ?,
                                            OUTPUT 0,
                                            OUTPUT "").

   /* Fechar o procedimento para buscarmos o resultado */ 
   CLOSE STORED-PROC pc_obtem_taxa_modalidade_car
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
 
   { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} } 
   
   HIDE MESSAGE NO-PAUSE.
    
   /* Busca possíveis erros */ 
   ASSIGN glb_cdcritic = pc_obtem_taxa_modalidade_car.pr_cdcritic.
   ASSIGN glb_dscritic = pc_obtem_taxa_modalidade_car.pr_dscritic.
   
   /* Verifica se ocorreu alguma critica no processo de consulta de taxas */
   IF glb_dscritic <> ? THEN
    DO:         
        BELL.
        MESSAGE glb_dscritic.
        PAUSE 3 NO-MESSAGE.
        HIDE MESSAGE NO-PAUSE.
        RETURN NO-APPLY.
    END.
   ELSE
    DO:
        
       /*Atribuicao de variaveis de retorno*/
       ASSIGN tel_txaplica = pc_obtem_taxa_modalidade_car.pr_txaplica 
          WHEN pc_obtem_taxa_modalidade_car.pr_txaplica <> ?.
    
       ASSIGN tel_nmprdcom = pc_obtem_taxa_modalidade_car.pr_nmprodut 
          WHEN pc_obtem_taxa_modalidade_car.pr_nmprodut <> ?.
    
       ASSIGN tel_dtvencto = pc_obtem_taxa_modalidade_car.pr_dtvencim 
          WHEN pc_obtem_taxa_modalidade_car.pr_dtvencim <> ?.
    
       ASSIGN tel_dtcarenc = pc_obtem_taxa_modalidade_car.pr_caraplic 
          WHEN pc_obtem_taxa_modalidade_car.pr_caraplic <> ?.
       
       ASSIGN aux_qtdiacar = tel_qtdiacar.
       
       HIDE MESSAGE NO-PAUSE.
    
       DISPLAY tel_txaplica tel_nmprdcom tel_qtdiacar tel_dtvencto tel_dtcarenc WITH FRAME f_aplic_pos.
   
   END.
    
   APPLY "GO".

END. 

ON VALUE-CHANGED, ENTRY OF b_aplicacoes IN FRAME f_browse DO:

   ASSIGN aux_vlblqjud = 0
          aux_vlresblq = 0.

   /*** Busca Saldo Bloqueio Judicial ***/
   IF NOT VALID-HANDLE(h-b1wgen0155) THEN
      RUN sistema/generico/procedures/b1wgen0155.p 
          PERSISTENT SET h-b1wgen0155.

   RUN retorna-valor-blqjud IN h-b1wgen0155(INPUT glb_cdcooper,
                                            INPUT tel_nrdconta,
                                            INPUT 0, /* fixo - nrcpfcgc */
                                            INPUT 1, /* Bloqueio        */
                                            INPUT 2, /* 2 - Aplicacao   */
                                            INPUT glb_dtmvtolt,
                                            OUTPUT aux_vlblqjud,
                                            OUTPUT aux_vlresblq).

   ASSIGN tel_vlblqjud = aux_vlblqjud.

   IF VALID-HANDLE(h-b1wgen0155) THEN
      DELETE PROCEDURE h-b1wgen0155.
   /*** Fim Busca Saldo Bloqueado Judicial ***/

   IF AVAILABLE tt-saldo-rdca  THEN
   DO:
   
      ASSIGN tel_dssitapl = tt-saldo-rdca.indebcre
             tel_cddresga = tt-saldo-rdca.cddresga
             tel_txaplmax = tt-saldo-rdca.txaplmax
             tel_txaplmin = tt-saldo-rdca.txaplmin
             tel_nrdocmto = STRING(INT(tt-saldo-rdca.nrdocmto),"zzzzz9")
             tel_dtresgat = tt-saldo-rdca.dtresgat WHEN STRING(tt-saldo-rdca.dtresgat) <> "01/01/1900"
             aux_cdprodut = tt-saldo-rdca.cdprodut.
      
   END.
   ELSE
      ASSIGN tel_dssitapl = ""
             tel_cddresga = ""
             tel_dtresgat = ?
             tel_txaplmax = ""
             tel_txaplmin = ""
             tel_nrdocmto = "".

   DISPLAY tel_dssitapl 
           tel_txaplmax 
           tel_txaplmin 
           tel_cddresga 
           tel_dtresgat 
           tel_vlblqjud
           tel_nrdocmto
           WITH FRAME f_browse.

END.

ON ANY-KEY OF b_aplicacoes IN FRAME f_browse DO:

   HIDE MESSAGE NO-PAUSE.

   IF  KEY-FUNCTION(LASTKEY) = "CURSOR-RIGHT"  THEN
       DO:
           ASSIGN reg_contador = reg_contador + 1.
 
           IF  reg_contador > 4  THEN
               ASSIGN reg_contador = 1.
                
           ASSIGN glb_cddopcao = reg_cddopcao[reg_contador].
       END.
   ELSE        
   IF  KEY-FUNCTION(LASTKEY) = "CURSOR-LEFT"  THEN
       DO:
           ASSIGN reg_contador = reg_contador - 1.
 
           IF  reg_contador < 1  THEN
               ASSIGN reg_contador = 4.
                
           ASSIGN glb_cddopcao = reg_cddopcao[reg_contador].
       END.
   ELSE
   IF  KEY-FUNCTION(LASTKEY) = "HELP"  THEN
       APPLY LASTKEY.
   ELSE
   IF  KEY-FUNCTION(LASTKEY) = "RETURN"  THEN
       DO:
           IF  glb_cddopcao = "I"  THEN
               ASSIGN aux_nraplica = 0
                      aux_nrdlinha = 0.
           ELSE
               DO:
                   IF  NOT AVAILABLE tt-saldo-rdca  THEN
                       RETURN.

                   ASSIGN aux_nraplica = tt-saldo-rdca.nraplica
                          aux_nrdlinha = CURRENT-RESULT-ROW("q_aplicacoes")
                          aux_idtipapl = tt-saldo-rdca.idtipapl.
                   
                   b_aplicacoes:DESELECT-ROWS().
               END.
                       
           APPLY "GO".
       END.
   ELSE
       RETURN.
           
   CHOOSE FIELD reg_dsdopcao[reg_contador] PAUSE 0 WITH FRAME f_regua.

   VIEW FRAME f_browse.

END.
    
ASSIGN aux_flgerlog = TRUE.

DO WHILE TRUE:
    
   ASSIGN glb_nmrotina = "APLICACOES"
          glb_cddopcao = reg_cddopcao[reg_contador]
          aux_tpaplica = 0
          tel_vllanmto = 0
          tel_qtdiacar = 0
          tel_dtcarenc = ?
          tel_flgdebci = FALSE
          tel_txaplica = 0
          tel_dsaplica = ""
          tel_dtvencto = ?
          tel_qtdiaapl = 0
          tel_dtvencto = ?
          tel_qtdiacar = 0
          tel_flgdebci = FALSE
          tel_vllanmto = 0
          tel_txaplica = 0
          tel_nmprdcom = "".
   
   DISPLAY reg_dsdopcao 
           WITH FRAME f_regua.

   CHOOSE FIELD reg_dsdopcao[reg_contador] PAUSE 0 WITH FRAME f_regua.
   
   /* Inicializando objetos para leitura do XML */ 
   CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
   CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
   CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */ 
   CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
   CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 
                  
   { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} } 

   /* Efetuar a chamada a rotina Oracle */ 
   RUN STORED-PROCEDURE pc_lista_aplicacoes_car
       aux_handproc = PROC-HANDLE NO-ERROR (INPUT glb_cdcooper,      /* Código da Cooperativa */
                                            INPUT glb_cdoperad,      /* Código do Operador */
                                            INPUT glb_nmdatela,      /* Nome da Tela */
                                            INPUT 1,                 /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */
                                            INPUT 1,                 /* Numero do Caixa */
                                            INPUT tel_nrdconta,      /* Número da Conta */
                                            INPUT 1,                 /* Titular da Conta */
                                            INPUT 1,                 /* Codigo da Agencia */
                                            INPUT glb_nmdatela,      /* Codigo do Programa */
                                            INPUT 0,                 /* Número da Aplicação - Parâmetro Opcional */
                                            INPUT 0,                 /* Código do Produto – Parâmetro Opcional */ 
                                            INPUT glb_dtmvtolt,      /* Data de Movimento */
                                            INPUT 6,                 /* Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas) */
                                            INPUT INT(aux_flgerlog), /* Identificador de Log (0 – Não / 1 – Sim) */ 																 
                                           OUTPUT ?,                 /* XML com informações de LOG */
                                           OUTPUT 0,                 /* Código da crítica */
                                           OUTPUT "").               /* Descrição da crítica */

    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_lista_aplicacoes_car
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} } 

    /* Busca possíveis erros */ 
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_lista_aplicacoes_car.pr_cdcritic 
                          WHEN pc_lista_aplicacoes_car.pr_cdcritic <> ?
           aux_dscritic = pc_lista_aplicacoes_car.pr_dscritic 
                          WHEN pc_lista_aplicacoes_car.pr_dscritic <> ?.

    IF aux_cdcritic <> 0 OR
      aux_dscritic <> "" THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.cdcritic = aux_cdcritic
                   tt-erro.dscritic = aux_dscritic.
        
            BELL.
            MESSAGE tt-erro.dscritic.
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                PAUSE 3 NO-MESSAGE.
                LEAVE.
            END.
            HIDE MESSAGE NO-PAUSE.
        
            RETURN "NOK".
            
        END.

    EMPTY TEMP-TABLE tt-saldo-rdca.
    ASSIGN aux_vltotrda = 0.

    /*Leitura do XML de retorno da proc e criacao dos registros na tt-saldo-rdca
    para visualizacao dos registros na tela */
    
    /* Buscar o XML na tabela de retorno da procedure Progress */ 
    ASSIGN xml_req = pc_lista_aplicacoes_car.pr_clobxmlc. 
    
    /* Efetuar a leitura do XML*/ 
    SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
    PUT-STRING(ponteiro_xml,1) = xml_req. 
       
    IF ponteiro_xml <> ? THEN
        DO:
            xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
            xDoc:GET-DOCUMENT-ELEMENT(xRoot).
        
            DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 
        
                xRoot:GET-CHILD(xRoot2,aux_cont_raiz).
        
                IF xRoot2:SUBTYPE <> "ELEMENT" THEN 
                 NEXT. 
        
                IF xRoot2:NUM-CHILDREN > 0 THEN
                  CREATE tt-saldo-rdca.
        
                DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
                    
                    xRoot2:GET-CHILD(xField,aux_cont).
                        
                    IF xField:SUBTYPE <> "ELEMENT" THEN 
                        NEXT. 
                    
                    xField:GET-CHILD(xText,1).
                    
                    ASSIGN tt-saldo-rdca.nraplica = INT (xText:NODE-VALUE) WHEN xField:NAME = "nraplica".
                    ASSIGN tt-saldo-rdca.qtdiauti = INT (xText:NODE-VALUE) WHEN xField:NAME = "qtdiauti".
                    ASSIGN tt-saldo-rdca.vlaplica = DEC (xText:NODE-VALUE) WHEN xField:NAME = "vlaplica".
                    ASSIGN tt-saldo-rdca.nrdocmto =      xText:NODE-VALUE  WHEN xField:NAME = "nrdocmto".
                    ASSIGN tt-saldo-rdca.indebcre =      xText:NODE-VALUE  WHEN xField:NAME = "indebcre".
                    ASSIGN tt-saldo-rdca.vllanmto = DEC (xText:NODE-VALUE) WHEN xField:NAME = "vllanmto".
                    ASSIGN tt-saldo-rdca.sldresga = DEC (xText:NODE-VALUE) WHEN xField:NAME = "sldresga".
                    ASSIGN aux_vltotrda           = aux_vltotrda + DEC (xText:NODE-VALUE) WHEN xField:NAME = "sldresga".
                    ASSIGN tt-saldo-rdca.cddresga =      xText:NODE-VALUE  WHEN xField:NAME = "cddresga".
                    ASSIGN tt-saldo-rdca.txaplmax =      xText:NODE-VALUE  WHEN xField:NAME = "txaplmax".
                    ASSIGN tt-saldo-rdca.txaplmin =      xText:NODE-VALUE  WHEN xField:NAME = "txaplmin".
                    ASSIGN tt-saldo-rdca.dshistor =      xText:NODE-VALUE  WHEN xField:NAME = "dshistor".
                    ASSIGN tt-saldo-rdca.dssitapl =      xText:NODE-VALUE  WHEN xField:NAME = "dssitapl".
                    ASSIGN tt-saldo-rdca.idtipapl =      xText:NODE-VALUE  WHEN xField:NAME = "idtipapl".
                    ASSIGN tt-saldo-rdca.dtmvtolt = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtmvtolt".
                    ASSIGN tt-saldo-rdca.dtvencto = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtvencto" AND xText:NODE-VALUE <> "01/01/1900".
                    ASSIGN tt-saldo-rdca.dtresgat = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtresgat".
                    ASSIGN tt-saldo-rdca.cdprodut = INT (xText:NODE-VALUE) WHEN xField:NAME = "cdprodut".
                    
                END. 
                
            END.
        
            SET-SIZE(ponteiro_xml) = 0. 
        END.
    
    DELETE OBJECT xDoc. 
    DELETE OBJECT xRoot. 
    DELETE OBJECT xRoot2. 
    DELETE OBJECT xField. 
    DELETE OBJECT xText.

       IF aux_flgerlog THEN
          ASSIGN aux_flgerlog = FALSE.
       ELSE
          DO:
              CLOSE QUERY q_aplicacoes.

              TRANSACAO:
              DO TRANSACTION ON ERROR UNDO TRANSACAO, LEAVE TRANSACAO:

                  { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    
                   /* Utilizar o tipo de busca A, para carregar do dia anterior
                    (U=Nao usa data, I=usa dtrefere, A=Usa dtrefere-1, P=Usa dtrefere+1) */ 
                  RUN STORED-PROCEDURE pc_obtem_saldo_dia_prog
                      aux_handproc = PROC-HANDLE NO-ERROR (INPUT glb_cdcooper,
                                                           INPUT 0, /* cdagenci */
                                                           INPUT 0, /* nrdcaixa */
                                                           INPUT glb_cdoperad,
                                                           INPUT tel_nrdconta,
                                                           INPUT glb_dtmvtolt,
                                                           INPUT "A", /* Tipo Busca */
                                                           OUTPUT 0,
                                                           OUTPUT "").
    
                   CLOSE STORED-PROC pc_obtem_saldo_dia_prog
                       aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
                   { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
                   ASSIGN aux_cdcritic = 0
                          aux_dscritic = ""
                          aux_cdcritic = pc_obtem_saldo_dia_prog.pr_cdcritic 
                                             WHEN pc_obtem_saldo_dia_prog.pr_cdcritic <> ?
                          aux_dscritic = pc_obtem_saldo_dia_prog.pr_dscritic
                                             WHEN pc_obtem_saldo_dia_prog.pr_dscritic <> ?. 

                   FIND FIRST wt_saldos NO-LOCK NO-ERROR.
                   IF AVAILABLE wt_saldos THEN
                   DO:
                       ASSIGN tel_vlstotal = wt_saldos.vlsdchsl + 
                                             wt_saldos.vlsdblfp + 
                                             wt_saldos.vlsdblpr + 
                                             wt_saldos.vlsdbloq + 
                                             wt_saldos.vlsddisp.
                   END.
              END. /** Fim do DO TRANSACTION - TRANSACAO **/

              IF NOT VALID-HANDLE(h-b1wgen0003) THEN
                 RUN sistema/generico/procedures/b1wgen0003.p PERSISTENT 
                     SET h-b1wgen0003.
       
              RUN consulta-lancamento IN h-b1wgen0003 
                                     (INPUT glb_cdcooper,
                                      INPUT 0,
                                      INPUT 0,
                                      INPUT glb_cdoperad,
                                      INPUT tel_nrdconta,
                                      INPUT 1,
                                      INPUT 1,
                                      INPUT glb_nmdatela,
                                      INPUT FALSE, /* Nao Logar */
                                     OUTPUT TABLE tt-totais-futuros,
                                     OUTPUT TABLE tt-erro,
                                     OUTPUT TABLE tt-lancamento_futuro).
              
              IF VALID-HANDLE(h-b1wgen0003) THEN
                 DELETE PROCEDURE h-b1wgen0003.
              
              IF RETURN-VALUE = "OK"  THEN
                 DO:
                     FIND FIRST tt-totais-futuros NO-LOCK NO-ERROR.
    
                     IF  AVAIL tt-totais-futuros  THEN
                         ASSIGN aux_vllautom = tel_vlstotal + 
                                               tt-totais-futuros.vllautom.
                 END.
              
              IF NOT VALID-HANDLE(h-b1wgen0020) THEN
                 RUN sistema/generico/procedures/b1wgen0020.p PERSISTENT 
                     SET h-b1wgen0020.
       
              RUN obtem-saldo-investimento IN h-b1wgen0020 
                                          (INPUT glb_cdcooper,
                                           INPUT 0,
                                           INPUT 0,
                                           INPUT glb_cdoperad,
                                           INPUT glb_nmdatela,
                                           INPUT 1,
                                           INPUT tel_nrdconta,
                                           INPUT 1,
                                           INPUT glb_dtmvtolt,
                                          OUTPUT TABLE tt-saldo-investimento).
    
              IF VALID-HANDLE(h-b1wgen0020) THEN
                 DELETE PROCEDURE h-b1wgen0020.
              
              FIND FIRST tt-saldo-investimento NO-LOCK NO-ERROR.
    
              IF AVAILABLE tt-saldo-investimento  THEN
                 ASSIGN aux_saldo_ci = tt-saldo-investimento.vlsldinv.
              
              /** Atualiza saldo na tela principal da ATENDA **/
              ASSIGN tel_dsdopcao[04] = " DEP. VISTA:" +
                                        STRING(tel_vlstotal,"zzz,zzz,zz9.99-")
                     tel_dsdopcao[06] = " APLICACOES:" +    
                                        STRING(aux_vltotrda,"zzz,zzz,zz9.99-")
                     tel_dsdopcao[08] = "  CONTA INV:" + 
                                        STRING(aux_saldo_ci,"zzz,zzz,zz9.99-")
                     tel_dsdopcao[12] = "     LAUTOM:" +
                                        STRING(aux_vllautom,"zz,zzz,zz9.99-").
          END.
   
    OPEN QUERY q_aplicacoes PRESELECT EACH tt-saldo-rdca NO-LOCK.

    IF aux_nrdlinha > 0  THEN
      DO: 
          IF  aux_nrdlinha > NUM-RESULTS("q_aplicacoes")  THEN
              ASSIGN aux_nrdlinha = NUM-RESULTS("q_aplicacoes").
    
          REPOSITION q_aplicacoes TO ROW(aux_nrdlinha).
      END.
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
      UPDATE b_aplicacoes WITH FRAME f_browse.
      LEAVE.

   END. /** Fim do DO WHILE TRUE **/
   
   IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
      LEAVE.

   { includes/acesso.i }

   HIDE MESSAGE NO-PAUSE.

   HIDE FRAME f_opcao NO-PAUSE.
   HIDE FRAME f_tipo_aplic NO-PAUSE.
   HIDE FRAME f_aplic_pre NO-PAUSE.
   HIDE FRAME f_aplic_pos NO-PAUSE.

   CLEAR FRAME f_opcao.
   CLEAR FRAME f_tipo_aplic.
   CLEAR FRAME f_aplic_pos.
   CLEAR FRAME f_aplic_pre.

   IF CAN-DO("I,E",glb_cddopcao)  THEN
      DO:        
         ASSIGN aux_titframe = IF  glb_cddopcao = "E"  THEN
                                   " Excluir Aplicacao Nr. " +
                                   TRIM(STRING(aux_nraplica,"zzz,zz9")) + " "
                               ELSE
                                   " Incluir Aplicacao ".

         IF NOT VALID-HANDLE(h-b1wgen0081) THEN
            RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT 
                SET h-b1wgen0081.
         
         RUN buscar-dados-aplicacao IN h-b1wgen0081 
                                   (INPUT glb_cdcooper,
                                    INPUT 0,
                                    INPUT 0,
                                    INPUT glb_cdoperad,
                                    INPUT glb_nmdatela,
                                    INPUT 1,
                                    INPUT tel_nrdconta,
                                    INPUT 1,
                                    INPUT glb_cddopcao,
                                    INPUT glb_dtmvtolt,
                                    INPUT aux_nraplica,
                                    INPUT TRUE,
                                   OUTPUT TABLE tt-tipo-aplicacao,
                                   OUTPUT TABLE tt-dados-aplicacao,
                                   OUTPUT TABLE tt-erro).
         
         IF VALID-HANDLE(h-b1wgen0081) THEN
            DELETE PROCEDURE h-b1wgen0081.
      
         IF RETURN-VALUE = "NOK"  THEN
            DO: 
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
                IF  AVAILABLE tt-erro  THEN
                    DO:
                        BELL.
                        MESSAGE tt-erro.dscritic.
                    END.
                
                NEXT.
            END.
         
         IF  glb_cddopcao = "E"  THEN /*aux_idtipapl*/
             DO:
                ASSIGN aux_desdhelp = "".

                 FOR EACH tt-tipo-aplicacao NO-LOCK:
        
                     IF  aux_desdhelp = ""  THEN
                         ASSIGN aux_desdhelp = "Informe o tipo da aplicacao: " +
                                               STRING(tt-tipo-aplicacao.tpaplica) + 
                                               "-" + tt-tipo-aplicacao.dsaplica.
                     ELSE
                         ASSIGN aux_desdhelp = aux_desdhelp + "," + 
                                               STRING(tt-tipo-aplicacao.tpaplica) + 
                                               "-" + tt-tipo-aplicacao.dsaplica.
        
                 END. /** Fim do FOR EACH tt-tipo-aplicacao **/
        
                 ASSIGN tel_dsaplica:HELP = aux_desdhelp.
             END.
         
         
         FIND FIRST tt-dados-aplicacao NO-LOCK NO-ERROR.

         IF NOT AVAILABLE tt-dados-aplicacao THEN
            DO:
                BELL.
                MESSAGE "Registro de aplicacao nao encontrado.".
                
                NEXT.
            END.
         
         ASSIGN aux_tpaplrdc = tt-dados-aplicacao.tpaplrdc
                aux_cdperapl = tt-dados-aplicacao.cdperapl
                aux_tpaplica = tt-dados-aplicacao.tpaplica
                aux_qtdiaapl = tt-dados-aplicacao.qtdiaapl
                tel_qtdiaapl = tt-dados-aplicacao.qtdiaapl
                tel_dtcarenc = tt-dados-aplicacao.dtcarenc
                tel_dtvencto = tt-dados-aplicacao.dtresgat
                tel_qtdiacar = tt-dados-aplicacao.qtdiacar 
                tel_flgdebci = tt-dados-aplicacao.flgdebci
                tel_vllanmto = tt-dados-aplicacao.vllanmto
                tel_txaplica = tt-dados-aplicacao.txaplica
                tel_dsaplica = tt-dados-aplicacao.dsaplica
                tel_nmprdcom = tt-dados-aplicacao.nmprdcom
                tel_flgrecno = tt-dados-aplicacao.flgrecno.
          
      END.

   
   IF glb_cddopcao = "I"  THEN  /** INCLUIR **/
      DO: 
         
         DO TRANSACTION:
             InclusaoAplic: DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
                ASSIGN aux_tpaplica = 0
                       tel_vllanmto = 0
                       tel_qtdiacar = 0
                       tel_dtcarenc = ?
                       tel_flgdebci = FALSE
                       tel_txaplica = 0
                       tel_dsaplica = ""
                       tel_dtvencto = ?
                       tel_qtdiaapl = 0
                       tel_dtvencto = ?
                       tel_qtdiacar = 0
                       tel_flgdebci = FALSE
                       tel_vllanmto = 0
                       tel_txaplica = 0
                       tel_nmprdcom = "".
                
                HIDE FRAME f_tipo_aplic NO-PAUSE.
                HIDE FRAME f_aplic_pre  NO-PAUSE.
                HIDE FRAME f_aplic_pos  NO-PAUSE.
    
                CLEAR FRAME f_tipo_aplic NO-PAUSE.
                CLEAR FRAME f_aplic_pre  NO-PAUSE.
                CLEAR FRAME f_aplic_pos  NO-PAUSE.
                
                VIEW FRAME f_opcao.
                PAUSE(0).
               
                VIEW FRAME f_aplic_pos.
                PAUSE(0).
                
                /*Ajuste feito para produtos de captacao*/
                UPDATE tel_dsaplica WITH FRAME f_tipo_aplic
               
                EDITING:
                
                  DO WHILE TRUE:
    
                    READKEY PAUSE 1.
               
                    IF LASTKEY = KEYCODE("F7") THEN
                      DO:
                           
                        RUN fontes/zoom_tipo_captacao.p (INPUT glb_cdcooper,
                                                        OUTPUT aux_tpaplica,
                                                        OUTPUT tel_dsaplica,
                                                        OUTPUT aux_tpaplrdc,
                                                        OUTPUT aux_idtipapl,
                                                        OUTPUT tel_nmprdcom).
                        
                        IF aux_tpaplica > 0   THEN
                          DO:
                            DISPLAY tel_dsaplica WITH FRAME f_tipo_aplic.
                            PAUSE 0.
                            APPLY "RETURN".
                          END.
                        
                      END.
                    ELSE
                      IF LASTKEY = KEYCODE("F4") OR LASTKEY = KEYCODE("END") OR LASTKEY = KEYCODE("ENTER") THEN
                        DO:
                          IF LASTKEY = KEYCODE("F4") OR LASTKEY = KEYCODE("END") THEN
                            DO:
                              IF tel_dsaplica <> ? AND tel_dsaplica <> "" THEN
                                DO:
                                  ASSIGN tel_dsaplica = "".
                                  DISPLAY tel_dsaplica WITH FRAME f_tipo_aplic.
                                  NEXT.
                                END.
                              ELSE
                                DO:
                                  APPLY LASTKEY.
                                  LEAVE.
                                END.
                            END.
                          ELSE
                            DO:
                              IF tel_dsaplica <> ? AND tel_dsaplica <> "" then
                                DO:
                                  APPLY LASTKEY.
                                  LEAVE.
                                END.
                              ELSE
                                DO:
                                  NEXT.  
                                END.
                            END.
                        END.
    
                  END. /*FIM EDITING*/
    
                END.
                
                IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
                   DO:
                      HIDE FRAME f_opcao NO-PAUSE.
                      LEAVE.
                   END.
                    
                /* Novo Produto */
                IF aux_idtipapl = "N" THEN
                  DO:
                     VIEW tel_flgrecno.   
                     
                     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                       
                       UPDATE tel_vllanmto
                              tel_flgrecno
                              tel_dtvencto 
                              WITH FRAME f_aplic_pos
                      
                       EDITING:
                         ASSIGN tel_flgrecno = NO.    
                         READKEY.
                      
                         HIDE MESSAGE NO-PAUSE.
                      
                         IF FRAME-FIELD = "tel_vllanmto" OR 
                            FRAME-FIELD = "tel_flgrecno" OR
                            FRAME-FIELD = "tel_dtvencto" THEN
                           DO:
                      
                             IF LASTKEY = KEYCODE(".")  THEN
                                APPLY 44.
                             ELSE
                                IF LASTKEY = KEYCODE("F4") OR LASTKEY = KEYCODE("END") THEN
                                  NEXT InclusaoAplic.
                                ELSE
                                  APPLY LASTKEY.
                           END.
                         ELSE  
                             DO:
                                IF LASTKEY = KEYCODE("F4") OR LASTKEY = KEYCODE("END") OR LASTKEY = KEYCODE("F1") THEN
                                  LEAVE InclusaoAplic.
                                ELSE
                                  LEAVE.
                             END.
                         
                       END. /** Fim do EDITING **/
                       
                       HIDE MESSAGE NO-PAUSE.
                       
                       LEAVE.
                      
                     END. /** Fim do DO WHILE TRUE **/
                     
                     DO WHILE TRUE:
                        
                        RUN validar-aplicacao-novo.
                     
                        IF RETURN-VALUE = "NOK" THEN
                          UPDATE tel_vllanmto
                                 tel_flgrecno
                                 tel_dtvencto 
                                 WITH FRAME f_aplic_pos.
                        ELSE
                          LEAVE.
                     END.
                     
                     RUN confirma.
    
                     IF RETURN-VALUE = "NOK"  THEN
                        NEXT.
                     ELSE
                       DO:
                         
                         /* Inclusao */
                         RUN cadastra-aplicacao-novo.
                       
                         IF RETURN-VALUE = "NOK" THEN
                           DO:
                             LEAVE.
                           END.
                         ELSE
                           DO:
                             BELL.
                             MESSAGE "Aplicacao Nr. " + TRIM(STRING(aux_nraplica)) + ", no valor de R$ " + TRIM(STRING(tel_vllanmto,"zzzzz,zz9.99")) + " cadastrada com sucesso.".
                             PAUSE 3 NO-MESSAGE.
                             LEAVE.
                           END.
                           
                       END.
                     
                     IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                       DO:
                         HIDE FRAME f_aplic_pos NO-PAUSE.
                         NEXT.
                       END.
                   
                   END. /* Fim Novo Produto */
                ELSE
                    DO:
                        
                        /*RDCPRE*/
                        IF aux_tpaplica = 7 THEN
                           DO:
                              
                              HIDE FRAME f_aplic_pos NO-PAUSE.
                        
                              DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                  
                                 UPDATE tel_qtdiaapl
                                        tel_dtvencto
                                        tel_vllanmto
                                        WITH FRAME f_aplic_pre
                              
                                  EDITING:
                                      
                                    READKEY.
                              
                                    HIDE MESSAGE NO-PAUSE.
                                    
                                    IF FRAME-FIELD = "tel_vllanmto"  THEN
                                      DO:
                                        IF  LASTKEY = KEYCODE(".")  THEN
                                          APPLY 44.
                                        ELSE
                                          APPLY LASTKEY.
                                        END.
                                    ELSE    
                                      APPLY LASTKEY.
                              
                                    IF GO-PENDING  THEN
                                      DO: 
                                        
                                        RUN validar-aplicacao.
                              
                                        IF RETURN-VALUE = "NOK"  THEN
                                          DO:
                                            { sistema/generico/includes/foco_campo.i 
                                            &VAR-GERAL=SIM 
                                            &NOME-FRAME="f_aplic_pre"
                                            &NOME-CAMPO=aux_nmdcampo }
                                          END.
                                      END.
                              
                                  END. /** Fim do EDITING **/
                              
                                  IF NOT VALID-HANDLE(h-b1wgen0081) THEN
                                    RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT
                                     SET h-b1wgen0081.
                              
                                  MESSAGE "Efetuando aplicacao. Aguarde ...".
                                  
                                  RUN incluir-nova-aplicacao IN h-b1wgen0081 
                                                           (INPUT glb_cdcooper,
                                                            INPUT 0, /*cdagenci*/
                                                            INPUT 0, /*nrdcaixa*/
                                                            INPUT glb_cdoperad,
                                                            INPUT glb_nmdatela,
                                                            INPUT 1, /*idorigem*/
                                                            INPUT glb_inproces,
                                                            INPUT tel_nrdconta,
                                                            INPUT 1, /*idseqttl*/
                                                            INPUT glb_dtmvtolt,
                                                            INPUT glb_dtmvtopr,
                                                            INPUT aux_tpaplica,
                                                            INPUT tel_qtdiaapl, 
                                                            INPUT tel_dtvencto,
                                                            INPUT tel_qtdiacar, 
                                                            INPUT aux_cdperapl,
                                                            INPUT tel_flgdebci,
                                                            INPUT tel_vllanmto,
                                                            INPUT TRUE,
                                                            OUTPUT aux_nrdocmto,
                                                            OUTPUT TABLE tt-msg-confirma,
                                                            OUTPUT TABLE tt-erro).
                                     
                                  IF VALID-HANDLE(h-b1wgen0081) THEN
                                    DELETE PROCEDURE h-b1wgen0081.
                                     
                                  HIDE MESSAGE NO-PAUSE.
                              
                                  IF RETURN-VALUE = "NOK"  THEN
                                    DO:
                                      FIND FIRST tt-erro NO-LOCK NO-ERROR.
                              
                                      IF AVAILABLE tt-erro  THEN
                                        DO:
                                          BELL.
                                          MESSAGE tt-erro.dscritic.
                                        END.
                              
                                      NEXT.
                                    END.
                              
                                  FOR EACH tt-msg-confirma 
                                    WHERE tt-msg-confirma.inconfir <> 2 
                                          NO-LOCK BY tt-msg-confirma.inconfir:
                              
                                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                      BELL.
                                      MESSAGE tt-msg-confirma.dsmensag.
                                      PAUSE 3 NO-MESSAGE.
                                      LEAVE.
                              
                                    END. /** Fim do DO WHILE TRUE **/
                              
                                  END. /** Fim do FOR EACH tt-msg-confirma **/
                              
                                  HIDE MESSAGE NO-PAUSE.
                              
                                  LEAVE.
                              
                              END. /** Fim do DO WHILE TRUE **/
                              
                              IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                                 DO:
                                    HIDE FRAME f_aplic_pre NO-PAUSE.
                                    NEXT.
                                 END.
                              
                           END.
                        ELSE /*RDCPOS*/
                           DO:
                             
                             HIDE tel_flgrecno.
    
                             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                               
                               UPDATE tel_vllanmto 
                                      tel_dtvencto 
                                      WITH FRAME f_aplic_pos
                              
                               EDITING:
                                     
                                 READKEY.
                              
                                 HIDE MESSAGE NO-PAUSE.
                              
                                 IF FRAME-FIELD = "tel_vllanmto" THEN
                                   DO:
                                     IF LASTKEY = KEYCODE(".")  THEN
                                       APPLY 44.
                                     ELSE
                                       APPLY LASTKEY.
                                   END.
                                 ELSE    
                                   APPLY LASTKEY.
                                 
                                 IF GO-PENDING THEN
                                   DO: 
                                     
                                     RUN validar-aplicacao.
                              
                                     IF RETURN-VALUE = "NOK"  THEN
                                       DO:
                                         { sistema/generico/includes/foco_campo.i 
                                         &NOME-FRAME="f_aplic_pos"
                                         &NOME-CAMPO=aux_nmdcampo }
                                       END.
                                   END.
                              
                               END. /** Fim do EDITING **/
                              
                               IF NOT VALID-HANDLE(h-b1wgen0081) THEN
                                 RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT
                                   SET h-b1wgen0081.
                              
                               MESSAGE "Efetuando aplicacao. Aguarde ...".
                               
                               RUN incluir-nova-aplicacao IN h-b1wgen0081 
                                                           (INPUT glb_cdcooper,
                                                            INPUT 0, /*cdagenci*/
                                                            INPUT 0, /*nrdcaixa*/
                                                            INPUT glb_cdoperad,
                                                            INPUT glb_nmdatela,
                                                            INPUT 1, /*idorigem*/
                                                            INPUT glb_inproces,
                                                            INPUT tel_nrdconta,
                                                            INPUT 1, /*idseqttl*/
                                                            INPUT glb_dtmvtolt,
                                                            INPUT glb_dtmvtopr,
                                                            INPUT aux_tpaplica,
                                                            INPUT aux_qtdiaapl, 
                                                            INPUT tel_dtvencto,
                                                            INPUT tel_qtdiacar, 
                                                            INPUT aux_cdperapl,
                                                            INPUT tel_flgdebci,
                                                            INPUT tel_vllanmto,
                                                            INPUT TRUE,
                                                            OUTPUT aux_nrdocmto,
                                                            OUTPUT TABLE tt-msg-confirma,
                                                            OUTPUT TABLE tt-erro).
                                     
                               IF VALID-HANDLE(h-b1wgen0081) THEN
                                 DELETE PROCEDURE h-b1wgen0081.
                                     
                               HIDE MESSAGE NO-PAUSE.
                              
                               IF RETURN-VALUE = "NOK" THEN
                                 DO:
                                   FIND FIRST tt-erro NO-LOCK NO-ERROR.
                              
                                   IF AVAILABLE tt-erro THEN
                                     DO:
                                       BELL.
                                       MESSAGE tt-erro.dscritic.
                                     END.
                              
                                   NEXT.
                                 END.
                              
                               FOR EACH tt-msg-confirma 
                                 WHERE tt-msg-confirma.inconfir <> 2 
                                  NO-LOCK BY tt-msg-confirma.inconfir:
                              
                                 DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                              
                                   BELL.
                                   MESSAGE tt-msg-confirma.dsmensag.
                                   PAUSE 3 NO-MESSAGE.
                                   LEAVE.
                              
                                 END. /** Fim do DO WHILE TRUE **/
                              
                               END. /** Fim do FOR EACH tt-msg-confirma **/
                              
                               HIDE MESSAGE NO-PAUSE.
                              
                               LEAVE.
                              
                             END. /** Fim do DO WHILE TRUE **/
                             
                             IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                               DO:
                                 HIDE FRAME f_aplic_pos NO-PAUSE.
                                 NEXT.
                               END.
                              
                           END. /* Fim POS*/
    
                    END.
    
                LEAVE.
    
             END.
        END.

        IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
            NEXT.
          
      END.                      
   ELSE                          
   IF glb_cddopcao = "E"  THEN  /** EXCLUIR **/
      DO: 
         
         VIEW FRAME f_opcao.

         PAUSE(0).

         VIEW FRAME f_tipo_aplic.

         PAUSE(0).

         DISP tel_dsaplica
              WITH FRAME f_tipo_aplic.

         PAUSE(0).

         IF aux_tpaplrdc = 1 THEN
            DO:
               DISPLAY tel_qtdiaapl
                       tel_dtvencto
                       tel_flgdebci  
                       tel_vllanmto  
                       tel_txaplica   
                       tel_dsaplica
                       WITH FRAME f_aplic_pre.
                  
            END.
         ELSE
            DO: 
              DISPLAY tel_vllanmto  
                      tel_qtdiacar
                      tel_dtcarenc 
                      tel_flgdebci  
                      tel_txaplica  
                      tel_dtvencto
                      tel_flgrecno
                      tel_nmprdcom
                      WITH FRAME f_aplic_pos.
              
              IF aux_idtipapl = "A" THEN
                HIDE tel_flgrecno.

            END. 
         
         RUN confirma.

         IF RETURN-VALUE = "NOK"  THEN
            NEXT.

         IF NOT VALID-HANDLE(h-b1wgen0081) THEN
            RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT SET h-b1wgen0081.
    
         RUN excluir-nova-aplicacao IN h-b1wgen0081 (INPUT glb_cdcooper,
                                                     INPUT 0, /*cdagenci*/
                                                     INPUT 0, /*nrdcaixa*/
                                                     INPUT glb_cdoperad,
                                                     INPUT glb_nmdatela,
                                                     INPUT 1, /*idorigem*/
                                                     INPUT glb_inproces,
                                                     INPUT tel_nrdconta,
                                                     INPUT 1, /*idseqttl*/
                                                     INPUT glb_dtmvtolt,
                                                     INPUT glb_dtmvtopr,
                                                     INPUT aux_nraplica,
                                                     INPUT TRUE,
                                                    OUTPUT TABLE tt-erro).
             
         IF VALID-HANDLE(h-b1wgen0081) THEN
            DELETE PROCEDURE h-b1wgen0081.
             
         IF RETURN-VALUE = "NOK"  THEN
            DO:
               FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
               IF AVAILABLE tt-erro  THEN
                  DO:
                      BELL.
                      MESSAGE tt-erro.dscritic.
                  END.
      
               NEXT.

            END.
     END.
     
   ELSE IF glb_cddopcao = "R"  THEN  /** RESGATE **/
    RUN fontes/rdcaresg2.p (INPUT tel_nrdconta,
                              INPUT aux_nraplica,
                              INPUT tt-saldo-rdca.sldresga,
                              INPUT aux_cdprodut,  
                              INPUT aux_idtipapl).
       
   ELSE IF glb_cddopcao = "A"  THEN  /** ACUMULA **/
      RUN fontes/rdcacumu.p (INPUT tel_nrdconta,
                            INPUT aux_nraplica,
                            INPUT aux_idtipapl).
  
END. /** Fim do DO WHILE TRUE **/

HIDE FRAME f_regua  NO-PAUSE.
HIDE FRAME f_browse NO-PAUSE.
                 
/*............................................................................*/

PROCEDURE zoom_carencia:
   

   IF NOT VALID-HANDLE(h-b1wgen0081) THEN
      RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT SET h-b1wgen0081.
   
   RUN obtem-dias-carencia IN h-b1wgen0081
                          (INPUT glb_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT glb_cdoperad,
                           INPUT glb_nmdatela,
                           INPUT 1,
                           INPUT glb_dtmvtolt,
                           INPUT tel_nrdconta,
                           INPUT 1,
                           INPUT aux_tpaplica,
                           INPUT 0, /*qtdiaapl*/
                           INPUT 0, /*qtdiacar*/
                           INPUT FALSE, /** Somente validacao **/
                           INPUT FALSE, /** Nao gera LOG      **/
                          OUTPUT TABLE tt-carencia-aplicacao,
                          OUTPUT TABLE tt-erro).

   IF VALID-HANDLE(h-b1wgen0081) THEN
      DELETE PROCEDURE h-b1wgen0081.

   IF RETURN-VALUE = "NOK"  THEN
      DO:
         FIND FIRST tt-erro NO-LOCK NO-ERROR.

         IF AVAILABLE tt-erro  THEN
            DO:
                BELL.
                MESSAGE tt-erro.dscritic.
            END.
         
         RETURN "NOK".
     END.  
                        
   OPEN QUERY q_periodos FOR EACH tt-carencia-aplicacao NO-LOCK.
                        
   GET FIRST q_periodos NO-LOCK.

   /*RDCPRE*/
   IF aux_tpaplrdc = 1 THEN
      DO: 
         ASSIGN tel_qtdiacar = tt-carencia-aplicacao.qtdiacar
                aux_cdperapl = tt-carencia-aplicacao.cdperapl
                tel_dtcarenc = tt-carencia-aplicacao.dtcarenc
                aux_qtdiaapl = tt-carencia-aplicacao.qtdiaini.

         RETURN "OK".

      END.

   ASSIGN tel_qtdiacar = tt-carencia-aplicacao.qtdiacar
          aux_cdperapl = tt-carencia-aplicacao.cdperapl.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      PAUSE(0).
      UPDATE b_periodos WITH FRAME f_periodos.
      LEAVE.

   END. /** Fim do DO WHILE TRUE **/
           
   HIDE FRAME f_periodos NO-PAUSE.

   RETURN "OK".

END PROCEDURE.  

PROCEDURE zoom_carencia_captacao:

    DEF VAR aux_contador AS INTE     NO-UNDO INIT 0.
    
    DEF VAR aux_qtdiacar  LIKE crapmpc.qtdiacar NO-UNDO. 
    DEF VAR aux_qtdiaprz  LIKE crapmpc.qtdiaprz NO-UNDO. 

    /* Variaveis para o XML */ 
    DEF VAR xDoc          AS HANDLE   NO-UNDO.   
    DEF VAR xRoot         AS HANDLE   NO-UNDO.  
    DEF VAR xRoot2        AS HANDLE   NO-UNDO.  
    DEF VAR xField        AS HANDLE   NO-UNDO. 
    DEF VAR xText         AS HANDLE   NO-UNDO. 
    DEF VAR aux_cont_raiz AS INTEGER  NO-UNDO. 
    DEF VAR aux_cont      AS INTEGER  NO-UNDO. 
    DEF VAR ponteiro_xml  AS MEMPTR   NO-UNDO. 
    DEF VAR xml_req       AS LONGCHAR NO-UNDO. 
    
    /*Limpar registros da tabela temporaria*/
    EMPTY TEMP-TABLE tt-carencia-aplicacao-novo.
    
    /* Inicializando objetos para leitura do XML */ 
    CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
    CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
    CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */ 
    CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
    CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 
    
    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} } 
    
    /* Efetuar a chamada a rotina Oracle */ 
    RUN STORED-PROCEDURE pc_obtem_carencias_car
        aux_handproc = PROC-HANDLE NO-ERROR 
        (INPUT  glb_cdcooper, 
         INPUT  aux_tpaplica, 
         OUTPUT "",
         OUTPUT 0,  
         OUTPUT ""). 

    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_obtem_carencias_car
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
 
    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} } 

    /* Busca possíveis erros */ 
    ASSIGN glb_dscritic = pc_obtem_carencias_car.pr_dscritic.   
 
    IF glb_dscritic <> "" AND glb_dscritic <> ? THEN
      DO:
         BELL.
         MESSAGE glb_dscritic.
         
         RETURN "NOK".
     END.

    /* Buscar o XML na tabela de retorno da procedure Progress */ 
    ASSIGN xml_req = pc_obtem_carencias_car.pr_clobxmlc. 
                                          
    /* Efetuar a leitura do XML*/ 
    SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
    PUT-STRING(ponteiro_xml,1) = xml_req. 
     
    xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
    xDoc:GET-DOCUMENT-ELEMENT(xRoot).

    DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 
 
        xRoot:GET-CHILD(xRoot2,aux_cont_raiz). 
        IF   xRoot2:SUBTYPE <> "ELEMENT"   THEN 
             NEXT. 
        
        /* Limpar variaveis  */ 
        ASSIGN aux_qtdiacar = 0 
               aux_qtdiaprz = 0.
        
        DO aux_cont = 1 TO xRoot2:NUM-CHILDREN: 
            
            xRoot2:GET-CHILD(xField,aux_cont). 
                
            IF xField:SUBTYPE <> "ELEMENT" THEN 
                NEXT. 
           
            xField:GET-CHILD(xText,1). 
            
            ASSIGN aux_qtdiacar = INT(xText:NODE-VALUE) WHEN xField:NAME = "qtdiacar".
            ASSIGN aux_qtdiaprz = INT(xText:NODE-VALUE) WHEN xField:NAME = "qtdiaprz".
            
        END. 
        
        CREATE tt-carencia-aplicacao-novo.
        ASSIGN tt-carencia-aplicacao-novo.qtdiacar = aux_qtdiacar
               tt-carencia-aplicacao-novo.qtdiaprz = aux_qtdiaprz. 

    END.

    SET-SIZE(ponteiro_xml) = 0. 
     
    DELETE OBJECT xDoc. 
    DELETE OBJECT xRoot. 
    DELETE OBJECT xRoot2. 
    DELETE OBJECT xField. 
    DELETE OBJECT xText.
    
    IF NOT TEMP-TABLE tt-carencia-aplicacao-novo:HAS-RECORDS THEN
        DO:
            BELL.
            PAUSE.
            HIDE MESSAGE.
            RETURN "NOK".
        END.
    ELSE
        DO:
            CLEAR FRAME f_periodos_novo.

            OPEN QUERY q_periodos_novo FOR EACH tt-carencia-aplicacao-novo NO-LOCK.
                            
            GET FIRST q_periodos_novo NO-LOCK.
       
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
              PAUSE(0).
              UPDATE b_periodos_novo WITH FRAME f_periodos_novo.
              LEAVE.
            
            END. /** Fim do DO WHILE TRUE **/
               
            HIDE FRAME f_periodos_novo NO-PAUSE.
        
        END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE confirma:

   ASSIGN aux_confirma = "N".

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF glb_cddopcao = "I" THEN
        MESSAGE COLOR NORMAL "Confirma a inclusao da aplicacao " + tel_nmprdcom + "? (S/N):" UPDATE aux_confirma.
      ELSE
      IF glb_cddopcao = "E" THEN
          IF tel_nmprdcom <> ? THEN
            MESSAGE COLOR NORMAL "Confirma a exclusao da aplicacao " + tel_nmprdcom + "? (S/N):" UPDATE aux_confirma.
          ELSE
            MESSAGE COLOR NORMAL "Confirma a exclusao da aplicacao " + tel_dsaplica + "? (S/N):" UPDATE aux_confirma.
      
      LEAVE.

   END. /** Fim do DO WHILE TRUE **/

   IF KEYFUNCTION(LASTKEY) = "END-ERROR"  OR 
      aux_confirma <> "S"                 THEN
      DO:
          ASSIGN glb_cdcritic = 79.
          RUN fontes/critic.p.
          ASSIGN glb_cdcritic = 0.
          BELL.
          MESSAGE glb_dscritic.
          RETURN "NOK".
      END.

   RETURN "OK".

END PROCEDURE.

PROCEDURE validar-aplicacao:
    
  DO WITH FRAME f_aplic_pos:
           
       ASSIGN tel_dtvencto
              tel_qtdiacar  
              tel_flgdebci
              tel_vllanmto.

   END.
  
   IF NOT VALID-HANDLE(h-b1wgen0081) THEN
      RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT SET h-b1wgen0081.

   MESSAGE "Validando aplicacao. Aguarde ...".
    
   RUN validar-nova-aplicacao IN h-b1wgen0081 (INPUT glb_cdcooper,
                                               INPUT 0, /*cdagenci*/
                                               INPUT 0, /*cdoperad*/
                                               INPUT glb_cdoperad,
                                               INPUT glb_nmdatela,
                                               INPUT 1, /*idorigem*/
                                               INPUT glb_inproces,
                                               INPUT tel_nrdconta,
                                               INPUT 1, /*idseqttl*/
                                               INPUT glb_dtmvtolt,
                                               INPUT glb_dtmvtopr,
                                               INPUT glb_cddopcao,
                                               INPUT aux_tpaplica,
                                               INPUT aux_nraplica,
                                               INPUT aux_qtdiaapl, 
                                               INPUT tel_dtvencto,
                                               INPUT tel_qtdiacar, 
                                               INPUT aux_cdperapl,
                                               INPUT tel_flgdebci,
                                               INPUT tel_vllanmto,
                                               INPUT TRUE,
                                              OUTPUT aux_nmdcampo,
                                              OUTPUT TABLE tt-msg-confirma,
                                              OUTPUT TABLE tt-erro).
       
   IF VALID-HANDLE(h-b1wgen0081) THEN
      DELETE PROCEDURE h-b1wgen0081.
       
   HIDE MESSAGE NO-PAUSE.

   IF RETURN-VALUE = "NOK"  THEN
      DO:
         FIND FIRST tt-erro NO-LOCK NO-ERROR.

         IF AVAILABLE tt-erro  THEN
            DO:
                BELL.
                MESSAGE tt-erro.dscritic.
            END.

         RETURN "NOK".
      END.

   IF NOT CAN-FIND(FIRST tt-msg-confirma)  THEN
      DO:
         
         RUN confirma.

         IF RETURN-VALUE = "NOK"  THEN
            RETURN "NOK".
      END.

   FOR EACH tt-msg-confirma NO-LOCK:

       IF tt-msg-confirma.inconfir = 2  THEN
          DO:
             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
                BELL.
                MESSAGE tt-msg-confirma.dsmensag.
                MESSAGE "Peca a liberacao ao Coordenador/Gerente ...".
                PAUSE.
                LEAVE.
   
             END. /** Fim do DO WHILE TRUE **/
                             
             RUN fontes/pedesenha.p (INPUT glb_cdcooper,  
                                     INPUT 2, 
                                    OUTPUT aux_flgsenha,
                                    OUTPUT aux_cdoperad).
           
             IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                RETURN "NOK".
          END.
       ELSE
          DO:
             MESSAGE tt-msg-confirma.dsmensag.
             
             RUN confirma.

             IF  RETURN-VALUE = "NOK"  THEN
                 RETURN "NOK".
          END.

   END. /** Fim do FOR EACH tt-msg-confirma **/

   RETURN "OK".

END PROCEDURE.

PROCEDURE validar-aplicacao-novo:
   
   MESSAGE "Validando dados...Aguarde.".
   
   { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} } 

   /* Efetuar a chamada a rotina Oracle */ 
   RUN STORED-PROCEDURE pc_valida_cad_aplic
        aux_handproc = PROC-HANDLE NO-ERROR(INPUT glb_cdcooper, /* Código da Cooperativa */
                                            INPUT glb_cdoperad, /* Código do Operador */
                                            INPUT glb_nmdatela, /* Nome da Tela */
                                            INPUT 1,            /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */       
                                            INPUT tel_nrdconta, /* Número da Conta */
                                            INPUT 1,            /* Titular da Conta */
                                            INPUT glb_dtmvtolt, /* Data de Movimento */
                                            INPUT aux_tpaplica, /* Código do Produto */
                                            INPUT tel_qtdiaapl, /* Dias da Aplicação */
                                            INPUT tel_dtvencto, /* Data de Vencimento da Aplicação */
                                            INPUT tel_qtdiacar, /* Carência da Aplicação */
                                            INPUT aux_qtdiaprz, /* Prazo da Aplicação (Prazo selecionado na tela) */
                                            INPUT tel_vllanmto, /* Valor da Aplicação (Valor informado em tela) */
                                            INPUT INT(tel_flgdebci), /* Identificador de Débito na Conta Investimento (Identificador informado em tela) */
                                            INPUT INT(tel_flgrecno), /*IF tel_flgrecno = "S" THEN 1 ELSE 0,  Identificador de Origem do Recurso (Identificador informado em tela) */
                                            INPUT 1, /* Identificador de Log (Fixo no código, 0 – Não / 1 - Sim) */
                                            OUTPUT 0,
                                            OUTPUT "").

   /* Fechar o procedimento para buscarmos o resultado */ 
   CLOSE STORED-PROC pc_valida_cad_aplic
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
 
   { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

   /* Busca possíveis erros */ 
   ASSIGN glb_cdcritic = pc_valida_cad_aplic.pr_cdcritic.
   ASSIGN glb_dscritic = pc_valida_cad_aplic.pr_dscritic.
   
   HIDE MESSAGE NO-PAUSE.
    
   IF glb_dscritic <> ?  THEN
    DO: 
        BELL.
        MESSAGE glb_dscritic.
        PAUSE 3 NO-MESSAGE.
        HIDE MESSAGE NO-PAUSE.
        RETURN "NOK".
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE cadastra-aplicacao-novo:
   
   MESSAGE "Incluindo aplicacao...Aguarde.".
   
   { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} } 
  
   /* Efetuar a chamada a rotina Oracle */ 
   RUN STORED-PROCEDURE pc_cadastra_aplic
        aux_handproc = PROC-HANDLE NO-ERROR(INPUT glb_cdcooper, /* Código da Cooperativa */
                                            INPUT glb_cdoperad, /* Código do Operador */
                                            INPUT glb_nmdatela, /* Nome da Tela */
                                            INPUT 1,            /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */
                                            INPUT tel_nrdconta, /* Número da Conta */
                                            INPUT 1,            /* Titular da Conta */
                                            input 1,            /* Numero do caixa */
                                            INPUT glb_dtmvtolt, /* Data de Movimento */
                                            INPUT aux_tpaplica, /* Código do Produto */
                                            INPUT tel_qtdiaapl, /* Dias da Aplicação */
                                            INPUT tel_dtvencto, /* Data de Vencimento da Aplicação */
                                            INPUT tel_qtdiacar, /* Carência da Aplicação */
                                            INPUT aux_qtdiaprz, /* Prazo da Aplicação (Prazo selecionado na tela) */
                                            INPUT tel_vllanmto, /* Valor da Aplicação (Valor informado em tela) */
                                            INPUT INT(tel_flgdebci), /* Identificador de Débito na Conta Investimento (Identificador informado em tela) */
                                            INPUT INT(tel_flgrecno), /*IF tel_flgrecno = "S" THEN 1 ELSE 0,  Identificador de Origem do Recurso (Identificador informado em tela) */
                                            INPUT 1, /* Identificador de Log (Fixo no código, 0 – Não / 1 - Sim) */
                                            OUTPUT 0, /* Numero da aplicacao cadastrado*/
                                            OUTPUT 0,
                                            OUTPUT "").
   
   /* Fechar o procedimento para buscarmos o resultado */ 
   CLOSE STORED-PROC pc_cadastra_aplic
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
 
   { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
   
   /* Busca possíveis erros */ 
   ASSIGN glb_cdcritic = pc_cadastra_aplic.pr_cdcritic.
   ASSIGN glb_dscritic = pc_cadastra_aplic.pr_dscritic.
   
   HIDE MESSAGE NO-PAUSE.
    
   IF glb_dscritic <> ?  THEN
    DO: 
        BELL.
        MESSAGE glb_dscritic.
        PAUSE 3 NO-MESSAGE.
        HIDE MESSAGE NO-PAUSE.
        RETURN "NOK".
    END.

    ASSIGN aux_nraplica = pc_cadastra_aplic.pr_nraplica.
    
    HIDE MESSAGE NO-PAUSE.
    

    RETURN "OK".
END.

/*............................................................................*/
