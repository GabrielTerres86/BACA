/* .............................................................................

   Programa: Fontes/manccf.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo
   Data    : Dezembro/01.                      Ultima atualizacao: 05/08/2014
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela MANCCF - Consulta e Manutencao de cheques no CCF.
   
   Observacoes: Para o tratamento do CCF para a conta integracao, o comporta-
                mento da flag "flgctitg" consiste em:

                1- INCLUSAO CCF - A flag comeca com 0 (Nao Enviado), quando o
                                  usuario selecionar o cheque, a flag passa a
                valer 5 (Enviar Inclusao), o programa que gera o arquivo para o
                BB passa a flag para 1 (Enviada) e o programa de retorno passa
                para 2 (OK) ou 4 (Reenviar) em caso de erro;
                
                2- EXCLUSAO CCF - A flag deve estar como 0 (Nao Enviado) ou
                                  valendo 2 (OK - Inclusao no CCF), se a flag
                estiver como 2, passa a valer 6 (Enviar Exclusao) senao
                continua a valer 0 e nao envia nada ao BB;
                
                3- CANCELAMENTO EXCLUSAO - A flag deve estar valendo 6 (Enviar
                                           Exclusao) porque ainda nao foi ao
                BB, senao ela estara como 2 (OK - Exclusao do CCF) e o usuario
                devera mandar uma nova inclusao no CCF (para isso a flag
                passara a valer 0 (Nao Enviada)).

   Alteracoes: 08/05/2003 - Alteracao do nome do Banco - Concredi (Ze Eduardo).
   
               09/12/2003 - Buscar o nome da cidade no crapcop (Junior).

               20/07/2004 - Mostrar todos os registros (Deborah). 
               
               07/06/2005 - Tratamento para Conta Integracao (Evandro).

               28/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
               18/11/2005 - Efetuar leitura crapneg com codigo cooperativa.
                            Conta Integracao(Mirtes)
                            
               02/12/2005 - Conta = 0, listar somente cheques que sejam da 
                            conta integracao (Evandro).
                            
               26/12/2005 - Correcao no tratamento do cancelamento do CCF
                            (Evandro).
                            
               26/01/2006 - Desativada a opcao de escolha de quem sera incluso
                            no CCF, a inclusao serah feita automaticamente no
                            programa crps447.p (Evandro).

               10/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               15/02/2006 - Fazer selecao de cheques para imprimir a carta
                            mesmo que nao tenha sido regularizado (Evandro).
                            
               21/02/2006 - Correcao na alteracao do campo 'crapneg.flgctitg'
                            para a conta integracao (Evandro).
                            
               11/09/2006 - Alterado numero de vias ref. carta assinada pelo
                            cooperado, e cancelada emissao de carta ao B.B 
                            (Diego).

               17/01/2007 - Incluida a coluna "SIT" no browse para informar a
                            situacao do registro e impressao da carta para o BB
                            e BANCOOB (Evandro).
                            
               15/02/2007 - Efetuada modififcacao na carta de regularizacao CCF
                            (Diego).
               
               26/02/2007 - Incluida a coluna "Banco" referente ao codigo do
                            Banco no browser (Elton).
                            
               06/03/2007 - Permitir controle de envio dos registros tambem
                            para os cheques do BANCOOB (Evandro).

               09/03/2007 - Incluida coluna "Conta Chq." no browser (Diego).
                            
               19/04/2007 - Enviar exclusao CCF para contas antigas Bancoob
                            (flgctitg = 3)(Mirtes)
                           
               12/06/2007 - Permite escolher o titular responsavel pelos 
                            cheques e mostra no browser (Elton).
                                         
               12/07/2007 - Alterado impressao de carta para mostrar titular
                            responsavel por cada cheque e campo para a
                            assinatura de todos os cooperados (Elton).
                            
               07/08/2007 - Bancoob nao possue retorno(Flag = 1)(Mirtes)       
                    
               30/01/2008 - Inclusao da autorizacao do debito na carta 
                            (Guilherme).

               10/12/2008 - Contemplar o encerramento e reativacao da conta 
                            integracao (Gabriel).

               06/02/2009 - Verificar se conta integracao esta ativa somente se
                            crapneg.nrdctabb = crapass.nrdctitg (David).
               
               20/03/2009 - Inclusao da procedure proc_crialog (Fernando).
               
               15/05/2009 - Adicionado numero e descricao do Operador no rodape 
                            da impressao de cartas (Fernando).

               04/09/2009 - Ajustado erro no valor total mostrado na impressao 
                            da carta de exclusao de CCF, o mesmo estava 
                            duplicando a cada impressao (Fernando).
                            
               16/03/2010 - Adaptacao projeto IF CECRED (Guilherme).
               
               07/07/2010 - Tratar retorno do SERASA para IF 085 (Guilherme).
               
               15/07/2010 - Atualizar Data de Impressao da Carta (dtimpreg)
                            para os cheques selecionados quando usuario 
                            selecionar opcao "Imprimir Carta" (GATI - Eder)
                            
               02/08/2010 - Atualizar Usuario de Impressao da Carta (cdopeimp)
                            para os cheques selecionados quando usuario 
                            selecionar opcao "Imprimir Carta" (GATI - Eder)
                            
               02/08/2010 - Inclusao da procedure proc_crialog_2 para alteração 
                            de titular (Vitor).
                            
               23/05/2011 - Usar nrdconta com 8 posicoes (Guilherme).
               
               02/08/2012 - Inclusão da funcao NOW junto com nome do terminal 
                            quando nome do arquivo é gerado. (Lucas R.)
                            
               11/10/2012 - Nova chamada da procedure valida_operador_migrado
                            da b1wgen9998 para controle de contas e operadores
                            migrados (David Kruger).
               
               23/10/2013 - Incluida parametro cdprogra nas procedures da
                            b1wgen0153 que carregam dados da tarifa(Tiago). 
                            
               29/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
                            
               05/08/2014 - Alteração da Nomeclatura para PA (Vanessa).
..............................................................................*/


{ includes/var_online.i }
{ includes/var_manccf.i }
{ sistema/generico/includes/var_internet.i }
   

DEF STREAM str_1.
DEF STREAM str_2.
DEF STREAM str_3.
DEF STREAM str_4.
                          
DEF VAR aux_opmigrad AS LOG          NO-UNDO.

/* para a conta integracao */
DEF TEMP-TABLE crawneg           NO-UNDO
    FIELD nrdconta LIKE crapneg.nrdconta
    FIELD nrseqdig LIKE crapneg.nrseqdig
    FIELD dtiniest LIKE crapneg.dtiniest
    FIELD dtfimest LIKE crapneg.dtfimest
    FIELD vlestour LIKE crapneg.vlestour
    FIELD nrdocmto LIKE crapneg.nrdocmto
    FIELD dsflgcti AS CHAR
    FIELD flgenvio AS LOGICAL FORMAT "*/".

FUNCTION f_ver_contaitg RETURN INTEGER (INPUT par_nrdctitg AS CHAR):
       
    IF  par_nrdctitg = "" THEN
        RETURN 0.
    ELSE
        DO:
            IF  CAN-DO("1,2,3,4,5,6,7,8,9,0",
                       SUBSTR(par_nrdctitg,LENGTH(par_nrdctitg),1)) THEN
                RETURN INTE(STRING(par_nrdctitg,"99999999")).
            ELSE
                RETURN INTE(SUBSTR(STRING(par_nrdctitg,"99999999"),
                                   1,LENGTH(par_nrdctitg) - 1) + "0").
        END.
       
END.
  
ON  RETURN OF b_titular DO:
    
    FIND crapneg WHERE crapneg.cdcooper = glb_cdcooper      AND
                       crapneg.nrdconta = crapass.nrdconta  AND
                       crapneg.cdhisest = 1                 AND
                       crapneg.nrseqdig = cratneg.nrseqdig  AND
                       CAN-DO("12,13", STRING(crapneg.cdobserv)) 
                       USE-INDEX crapneg1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

    IF  AVAIL crapneg THEN 
        DO:
           RUN proc_crialog_2(INPUT crapneg.nrdconta,
                              INPUT crapneg.idseqttl,
                              INPUT cratttl.idseqttl,
                              INPUT crapneg.nrdocmto).

           ASSIGN crapneg.idseqttl = cratttl.idseqttl.
        END.
            
    RUN atualiza_browser.
            
    CLOSE QUERY q_titular. 
           
    APPLY "GO".
   
END.


VIEW FRAME f_moldura.

PAUSE(0).

ASSIGN glb_cdcritic = 0
       glb_nmrotina = "".

DO WHILE TRUE:

   IF   glb_cdcritic <> 0 THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            PAUSE 3 NO-MESSAGE.
        END.

   ASSIGN tel_nrdconta = 0
          tel_cdagenci = 0
          aux_qtchqsel = 0.
          
   CLEAR FRAME f_conta.

   RUN fontes/inicia.p.

   FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapcop THEN
        DO:
            glb_cdcritic = 651.
            NEXT.
        END.


   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      HIDE tel_cdagenci IN FRAME f_conta.
      
      UPDATE tel_nrdconta WITH FRAME f_conta.
      LEAVE.
      
   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "MANCCF"   THEN
                 DO:
                     HIDE FRAME f_conta.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.
   
   RUN sistema/generico/procedures/b1wgen9998.p
       PERSISTENT SET h-b1wgen9998.

    /* Validacao de operado e conta migrada */
   RUN valida_operador_migrado IN h-b1wgen9998 (INPUT glb_cdoperad,
                                                INPUT tel_nrdconta,
                                                INPUT glb_cdcooper,
                                                INPUT tel_cdagenci,
                                                OUTPUT aux_opmigrad,
                                                OUTPUT TABLE tt-erro).
   
   DELETE PROCEDURE h-b1wgen9998.

   IF RETURN-VALUE <> "OK" THEN
      DO:
          FIND FIRST tt-erro NO-LOCK NO-ERROR.
   
          IF AVAIL tt-erro THEN
             DO:
                BELL.
                MESSAGE tt-erro.dscritic.
                PAUSE 3 NO-MESSAGE.
                HIDE MESSAGE.
                NEXT.
             END.

      END.
   
   FIND crapass WHERE crapass.cdcooper = glb_cdcooper  AND
                      crapass.nrdconta = tel_nrdconta  NO-LOCK
                      USE-INDEX crapass1 NO-ERROR.

   IF   NOT AVAILABLE crapass THEN
        DO:
            glb_cdcritic = 009.
            NEXT.
        END.
   
   tel_nmprimtl = crapass.nmprimtl.
   
   DISPLAY tel_nmprimtl WITH FRAME f_conta.


   RUN atualiza_browser.


   IF   NOT AVAILABLE cratneg THEN
        DO:
            glb_cdcritic = 530.
            NEXT.
        END.    
   
   ON CHOOSE OF btn_titular
      RUN p_titular.
   
   ON CHOOSE OF btn_regular
      RUN p_regulariza.
   
   ON CHOOSE OF btn_imprcar
      RUN p_imprimecarta_selecionados.

   
   ON CHOOSE OF btn_sair
      APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.   

   ON RETURN OF b_manccf
      RUN p_regulariza.
      
   /* marcar cheques para imprimir a carta para a VIACREDI */
   ON ANY-KEY OF b_manccf DO:
   
      /* Barra de espaco */
      IF   KEY-FUNCTION(LASTKEY) = ""   AND
          (aux_qtchqsel < 20            OR
          (aux_qtchqsel = 20  AND 
           cratneg.flgselec = TRUE))    THEN
           DO:
               ASSIGN cratneg.flgselec = NOT cratneg.flgselec
                      aux_nrdrowid = ROWID(cratneg)
                      aux_qtchqsel = IF   cratneg.flgselec   THEN
                                          aux_qtchqsel + 1
                                     ELSE
                                          aux_qtchqsel - 1.
                                          
               MESSAGE aux_qtchqsel "cheque(s) selecionado(s) - Maximo 20.".
               
               OPEN QUERY q_manccf FOR EACH cratneg SHARE-LOCK.
               REPOSITION q_manccf TO ROWID(aux_nrdrowid).
           END.
      
   END.
   
   ENABLE ALL WITH FRAME f_manccf.
 
   WAIT-FOR WINDOW-CLOSE OF DEFAULT-WINDOW.
   
END.  /*  Fim do DO WHILE TRUE  */

/*****************************  R E G U L A R I Z A  *************************/

PROCEDURE p_regulariza:

   HIDE MESSAGE NO-PAUSE.

   ASSIGN glb_cddopcao = "R".

   { includes/acesso.i }

   IF   glb_cdcritic > 0   THEN
        RETURN.
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      ASSIGN glb_cdcritic = 078                  
             aux_confirma = "N".
         
      RUN fontes/critic.p.
      BELL.
      glb_cdcritic = 0.
      MESSAGE glb_dscritic UPDATE aux_confirma.
      LEAVE.
                  
   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR" OR 
        aux_confirma <> "S" THEN
        DO:
            glb_cdcritic = 79.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            PAUSE 5 NO-MESSAGE.
            LEAVE.
        END.

   DO TRANSACTION:
   
      DO WHILE TRUE:
      
         FIND crapneg WHERE crapneg.cdcooper = glb_cdcooper     AND
                            crapneg.nrdconta = tel_nrdconta     AND
                            crapneg.nrseqdig = cratneg.nrseqdig
                            USE-INDEX crapneg1
                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
   
         IF   NOT AVAILABLE crapneg   THEN
              IF   LOCKED crapneg   THEN
                   DO:
                       PAUSE 1 NO-MESSAGE.
                       NEXT. 
                   END.
              ELSE
                   glb_cdcritic = 419. /* Registro no crapneg nao encontrado */

         LEAVE.

      END.  /*  Fim do DO WHILE TRUE  */

      IF   glb_cdcritic > 0   THEN
           NEXT.
    
      /* Se Conta Integracao e nao ativa */
      IF   crapneg.cdbanchq = 1                                 AND
           crapneg.nrdctabb = f_ver_contaitg(crapass.nrdctitg)  THEN           
           DO:                  
               IF  NOT(crapass.flgctitg = 2 AND crapass.nrdctitg <> "")  THEN
                   DO:
                       MESSAGE "A conta integracao deve estar ativa para"
                               "efetuar a regularizacao.".
                       PAUSE 3 NO-MESSAGE.
                       NEXT.
                   END.
           END.
           
      aux_flgzerar = FALSE.
      
      IF   crapneg.dtfimest = ?   THEN
           DO:
              /* Deixa regularizar o cheque se a inclusao ja foi processada
                 pelo banco de compensacao/serasa ou se nem foi enviada */                          
              IF  crapneg.flgctitg <> 2   AND
                  crapneg.flgctitg <> 0   THEN
                  DO:
                     IF (crapneg.flgctitg = 3   AND
                         crapneg.cdbanchq = 756 AND
                         crapneg.dtiniest < 01/01/2007) OR  
                        (crapneg.flgctitg = 1 AND  /*Bancoob nao tem retorno*/
                         crapneg.cdbanchq = 756)  THEN
                        .
                     ELSE
                        DO:
                           IF  crapneg.cdbanchq <> crapcop.cdbcoctl  THEN
                           DO:
                               MESSAGE
                                   "A Inclusao no CCF ainda nao foi processada"
                                   "pelo banco".
                               MESSAGE
                                   "de compensacao. Impossivel Regularizar!".
                               NEXT.
                           END.
                           ELSE
                           DO:
                               MESSAGE
                                   "A Inclusao no CCF ainda nao foi processada"
                                   "pelo SERASA.".
                               MESSAGE
                                   "Impossivel Regularizar!".
                               NEXT.
                           END.

                        END.
                  END.
              
              ASSIGN crapneg.cdoperad = glb_cdoperad
                     crapneg.dtfimest = glb_dtmvtolt
                     crapneg.flgctitg = IF crapneg.flgctitg = 2 OR 
                                           crapneg.flgctitg = 3 OR
                                           crapneg.flgctitg = 1 THEN
                                           6   /* enviar exclusao no CCF */
                                        ELSE
                                           crapneg.flgctitg.

              IF   crapneg.flgctitg <>  0   THEN
                   RUN proc_crialog (INPUT "envio", INPUT crapneg.nrdocmto).
              ELSE
                   RUN proc_crialog (INPUT "exclusao", INPUT crapneg.nrdocmto).
           END.
      ELSE
           DO:
               IF   crapneg.dtfimest = glb_dtmvtolt THEN
                    DO:
                        /* Deixa cancelar a regularizacao se a propria regula-
                           rizacao ainda nao foi enviada ao banco de compensa-
                           cao/serasa ou se a inclusao foi bem sussedida */
                        IF  crapneg.flgctitg <> 6   AND
                            crapneg.flgctitg <> 2   AND
                            crapneg.flgctitg <> 0   AND      
                            crapneg.flgctitg <> 1   AND
                            crapneg.cdbanchq <> 756 THEN                                                     
                            DO:   
                            IF  crapneg.cdbanchq <> crapcop.cdbcoctl  THEN
                            DO:
                                MESSAGE "A Regularizacao no CCF ainda nao foi"
                                        "processada pelo banco".
                                MESSAGE "de compensacao. Impossivel Cancelar!".
                                NEXT.
                            END.
                            ELSE
                            DO:
                                MESSAGE "A Regularizacao no CCF ainda nao foi"
                                        "processada pelo SERASA.".
                                MESSAGE "Impossivel Cancelar!".
                                NEXT.
                            END.
                            END.
                            
                        IF   crapneg.flgctitg = 2   THEN
                             MESSAGE "ATENCAO! Voce deve enviar a"
                                     "INCLUSAO NO CCF!!!".
                            
                        ASSIGN crapneg.cdoperad = ""
                               crapneg.dtfimest = ?
                               aux_flgzerar     = TRUE
                               crapneg.flgctitg = IF   crapneg.dtectitg <> ?
                                                       THEN 2  /*Inclusao OK*/
                                                       ELSE 0. /*Nao enviada*/
                        
                        IF   crapneg.flgctitg <> 0   THEN   
                             RUN proc_crialog(INPUT "cancelamento - envio", 
                                              INPUT crapneg.nrdocmto).
                        ELSE
                             RUN proc_crialog(INPUT "cancelamento - exclusao",
                                              INPUT crapneg.nrdocmto).
                    END.
           END.
   
   END.   /*    Fim do Transaction   */

   IF   aux_flgzerar THEN
        ASSIGN cratneg.nmoperad = ""
               cratneg.dtfimest = ?
               cratneg.flgctitg = crapneg.flgctitg.
   ELSE
        DO:
            IF   crapneg.dtfimest = glb_dtmvtolt THEN
                 DO:
                     FIND crapope WHERE crapope.cdcooper = glb_cdcooper AND
                                        crapope.cdoperad = crapneg.cdoperad
                                        NO-LOCK NO-ERROR.

                     IF   AVAILABLE crapope THEN
                          aux_nmoperad = STRING(ENTRY(1, crapope.nmoperad," "),
                                         "x(11)").
                     ELSE                        
                          aux_nmoperad = "INEXISTENTE".
   
                     ASSIGN cratneg.nmoperad = aux_nmoperad
                            cratneg.dtfimest = glb_dtmvtolt
                            cratneg.flgctitg = crapneg.flgctitg.
                 END.
            ELSE 
                 DO:
                     glb_cdcritic = 520.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     glb_cdcritic = 0.
                     PAUSE 5 NO-MESSAGE.
                 END. 
        END.
   
   IF   CURRENT-RESULT-ROW("q_manccf") > 1 THEN
        REPOSITION q_manccf TO ROWID(ROWID(cratneg)).
   ELSE
        OPEN QUERY q_manccf FOR EACH cratneg SHARE-LOCK.

END PROCEDURE.   /*   fim da procedure p_regulariza   */



PROCEDURE p_imprimecarta_selecionados:

   DEF VAR aux_cdtarifa AS CHAR                                    NO-UNDO.
   DEF VAR aux_cdhistor AS INTE                                    NO-UNDO.
   DEF VAR aux_cdhisest AS INTE                                    NO-UNDO.
   DEF VAR aux_dtdivulg AS DATE                                    NO-UNDO.
   DEF VAR aux_dtvigenc AS DATE                                    NO-UNDO.
   DEF VAR aux_cdfvlcop AS INTE                                    NO-UNDO.
   DEF VAR h-b1wgen0153 AS HANDLE                                  NO-UNDO.

   HIDE MESSAGE NO-PAUSE.
   
   IF   aux_qtchqsel = 0   THEN
        DO:
            MESSAGE "Nao ha cheques selecionados. Utilize a BARRA DE ESPACO"
                    "para selecionar.".
            RETURN.
        END.
   
   ASSIGN glb_cddopcao = "I".
   
   { includes/acesso.i }

   IF   glb_cdcritic > 0   THEN
        RETURN.
    
   /* Busca dados da cooperativa */

   FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapcop   THEN
        DO:
            glb_cdcritic = 651.
            BELL. 
            RUN fontes/critic.p.
            MESSAGE glb_dscritic.
            RETURN.
        END.

   ASSIGN rel_nmcidade[1] = TRIM(crapcop.nmcidade).
   
   /*   Busca o nome da cooperativa e divide o campo de duas variaveis  */

   ASSIGN aux_qtpalavr = NUM-ENTRIES(TRIM(crapcop.nmextcop)," ") / 2
          rel_nmrescop = "".

   DO aux_qtcontpa = 1 TO NUM-ENTRIES(TRIM(crapcop.nmextcop)," "):
      IF   aux_qtcontpa <= aux_qtpalavr   THEN
           rel_nmrescop[1] = rel_nmrescop[1] +  (IF TRIM(rel_nmrescop[1]) = ""
                                                    THEN "" ELSE " ") +
                                      ENTRY(aux_qtcontpa,crapcop.nmextcop," ").
      ELSE
           rel_nmrescop[2] = rel_nmrescop[2] + (IF TRIM(rel_nmrescop[2]) = ""
                                                THEN "" ELSE " ") +
                                      ENTRY(aux_qtcontpa,crapcop.nmextcop," ").
   END.  /*  Fim DO .. TO  */ 

   ASSIGN rel_nmrescop[1] = FILL(" ",20 - INT(LENGTH(rel_nmrescop[1]) / 2)) +
                                          rel_nmrescop[1]
          rel_nmrescop[2] = FILL(" ",20 - INT(LENGTH(rel_nmrescop[2]) / 2)) +
                                          rel_nmrescop[2].

   rel_nmrescop[1] = TRIM(rel_nmrescop[1]," ").
   rel_nmrescop[2] = TRIM(rel_nmrescop[2]," ").

   /*  Fim da Rotina  */
   
   FIND crapope WHERE crapope.cdcooper = glb_cdcooper  AND
                      crapope.cdoperad = glb_cdoperad NO-LOCK NO-ERROR.
                      
   IF   NOT AVAILABLE crapope THEN
        DO:
            glb_cdcritic = 67.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            NEXT.
        END.
   
   FIND crapass WHERE crapass.cdcooper = glb_cdcooper  AND
                      crapass.nrdconta = tel_nrdconta
                      USE-INDEX crapass1               NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapass THEN
        DO:
            glb_cdcritic = 009.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            NEXT.
        END.

      /* Pega o nome do terminal */
   INPUT THROUGH basename `tty` NO-ECHO.
   SET aux_nmendter WITH FRAME f_terminal.
   INPUT CLOSE.
   
   aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                         aux_nmendter.

   ASSIGN  aux_flgfirst_bob = TRUE
           aux_flgfirst_bra = TRUE
           aux_flgfirst_cec = TRUE
           aux_nmarqtp1 = "arq/bancoob" + aux_nmendter + STRING(TIME) + 
                           /* para evitar duplicidade devido paralelismo */
                           SUBSTRING(STRING(NOW),21,3) + ".ex" 

           aux_nmarqtp2 = "arq/bbrasil" + aux_nmendter + STRING(TIME) + 
                          /* para evitar duplicidade devido paralelismo */
                           SUBSTRING(STRING(NOW),21,3) + ".ex"

           aux_nmarqtp3 = "arq/bcecred" + aux_nmendter + STRING(TIME) + 
                         /* para evitar duplicidade devido paralelismo */
                         SUBSTRING(STRING(NOW),21,3) + ".ex"

           rel_dtdiamov = DAY(glb_dtmvtolt)
           rel_dtanomov = YEAR(glb_dtmvtolt)
           rel_nmmesref = TRIM(aux_nmmesref[MONTH(glb_dtmvtolt)]).
           
   IF   crapass.inpessoa = 1 THEN
        ASSIGN rel_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999")
               rel_nrcpfcgc = STRING(rel_nrcpfcgc,"xxx.xxx.xxx-xx").
   ELSE
        ASSIGN rel_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999999")
               rel_nrcpfcgc = STRING(rel_nrcpfcgc,"xx.xxx.xxx/xxxx-xx").
   
   FOR EACH cratneg WHERE cratneg.flgselec = YES NO-LOCK,
       EACH crapneg WHERE crapneg.cdcooper = glb_cdcooper     AND
                          crapneg.nrdconta = tel_nrdconta     AND
                          crapneg.nrseqdig = cratneg.nrseqdig
                          USE-INDEX crapneg1 EXCLUSIVE-LOCK
                          BY crapneg.nrdctabb
                          BY crapneg.nrdocmto:

       ASSIGN crapneg.dtimpreg = glb_dtmvtolt 
              crapneg.cdopeimp = glb_cdoperad.
                           
       IF   crapneg.nrdconta = crapneg.nrdctabb   THEN
            DO:
                /* Bancoob */
                IF  crapneg.cdbanchq = 756  THEN
                DO:
                    IF   aux_flgfirst_bob  THEN
                         DO:
                             OUTPUT STREAM str_2 TO VALUE(aux_nmarqtp1).
                             aux_flgfirst_bob = FALSE.
                         END.

                    PUT STREAM str_2 crapneg.nrdconta  FORMAT "zzzz,zzz,9 "
                                     crapneg.cdbanchq  FORMAT "zzz9 "
                                     crapneg.cdagechq  FORMAT "zzz9 "
                                     crapneg.nrdocmto  FORMAT "zzz,zzz,9 "
                                     crapneg.nrctachq  FORMAT "zzzz,zzz,9 "
                                     crapneg.vlestour  FORMAT "zzzzzzz.99"
                                     crapneg.idseqttl  FORMAT "z9" 
                                     SKIP.            


                END.
                ELSE /* CECRED */
                DO:
                    IF   aux_flgfirst_cec  THEN
                         DO:
                             OUTPUT STREAM str_4 TO VALUE(aux_nmarqtp3).
                             aux_flgfirst_cec = FALSE.
                         END.
                    
                    PUT STREAM str_4 crapneg.nrdconta  FORMAT "zzzz,zzz,9 "
                                     crapneg.cdbanchq  FORMAT "zzz9 "
                                     crapneg.cdagechq  FORMAT "zzz9 "
                                     crapneg.nrdocmto  FORMAT "zzz,zzz,9 "
                                     crapneg.nrctachq  FORMAT "zzzz,zzz,9 "
                                     crapneg.vlestour  FORMAT "zzzzzzz.99"
                                     crapneg.idseqttl  FORMAT "z9" 
                                     SKIP.            

                END.

                ASSIGN aux_contchq = aux_contchq + 1.                 
            END.
       ELSE
       /* Banco do Brasil */
            DO:
                IF   aux_flgfirst_bra THEN
                     DO:
                         OUTPUT STREAM str_3 TO VALUE(aux_nmarqtp2).
                         aux_flgfirst_bra = FALSE.
                     END.

                PUT STREAM str_3 crapneg.nrdconta  FORMAT "zzzz,zzz,9 "
                                 crapneg.cdbanchq  FORMAT "zzz9 "
                                 crapneg.cdagechq  FORMAT "zzz9 "
                                 crapneg.nrdocmto  FORMAT "zzz,zzz,9 "
                                 crapneg.nrctachq  FORMAT "zzzz,zzz,9 "
                                 crapneg.vlestour  FORMAT "zzzzzzz.99"
                                 crapneg.idseqttl   FORMAT "z9" 
                                 SKIP.
                                 
                ASSIGN aux_contchq = aux_contchq + 1.                 
            END.

   END.    /*  Fim do for each crapneg  */
    
   IF  crapass.inpessoa = 1  THEN
       ASSIGN aux_cdtarifa = "EXCLUCCFPF".
   ELSE
       ASSIGN aux_cdtarifa = "EXCLUCCFPJ".
           
   IF  NOT VALID-HANDLE(h-b1wgen0153) THEN
       RUN sistema/generico/procedures/b1wgen0153.p PERSISTENT SET h-b1wgen0153.

   RUN carrega_dados_tarifa_vigente IN h-b1wgen0153
                                   (INPUT glb_cdcooper,
                                    INPUT aux_cdtarifa,
                                    INPUT 1, 
                                    INPUT "", /*cdprogra*/
                                   OUTPUT aux_cdhistor,
                                   OUTPUT aux_cdhisest,
                                   OUTPUT aux_vlregccf,
                                   OUTPUT aux_dtdivulg,
                                   OUTPUT aux_dtvigenc,
                                   OUTPUT aux_cdfvlcop,
                                   OUTPUT TABLE tt-erro).

   DELETE PROCEDURE h-b1wgen0153.

   IF  RETURN-VALUE <> "OK"  THEN
       DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  AVAIL tt-erro  THEN
               ASSIGN glb_dscritic = tt-erro.dscritic.
           ELSE
               ASSIGN glb_dscritic = "Erro na tarifa de CCF.".

           BELL.
           MESSAGE glb_dscritic.
           NEXT.
       END.

   ASSIGN aux_vltotccf = aux_vlregccf * aux_contchq.

   IF   NOT aux_flgfirst_bob   THEN
        OUTPUT STREAM str_2 CLOSE.

   IF   NOT aux_flgfirst_bra   THEN
        OUTPUT STREAM str_3 CLOSE.
   
   IF   NOT aux_flgfirst_cec   THEN
        OUTPUT STREAM str_4 CLOSE.

   ASSIGN aux_contador = 1
          glb_cdprogra = "MANCCF"
          glb_flgbatch = FALSE
          glb_cdempres = 11
          par_flgrodar = TRUE
          aux_flgbanco = TRUE
          aux_flgbncob = TRUE
          aux_arquivaz = TRUE.
   
   /* remove arquivos temporarios do usuario */
   UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").

   /* Para nao alterar toda estrutura da tela foi adaptado para IF CECRED 
    da seguinte forma: 
    aux_flgbanco = TRUE  = Banco do Brasil 
    aux_flgbncob = TRUE  = BANCOOB
    aux_flgbncob = FALSE = CECRED */
   DO aux_contador = 1 TO 3:
   
      ASSIGN aux_arquivaz = TRUE.  

      /* Banco do Brasil */
      IF   aux_flgbanco THEN
           ASSIGN aux_nmarqimp = "rl/" + aux_nmendter + STRING(TIME) + 
                                 /* para evitar duplicidade devido paralelismo */
                                 SUBSTRING(STRING(NOW),21,3) + "_1.ex"
                  glb_nrdevias = 2.   
      ELSE
      DO:
           IF  aux_flgbncob  THEN /* Bancoob */
           ASSIGN aux_nmarqimp = "rl/" + aux_nmendter + STRING(TIME) + 
                                 /* para evitar duplicidade devido paralelismo */
                                 SUBSTRING(STRING(NOW),21,3) + "_2.ex"
                  glb_nrdevias = 2.  
           ELSE
           ASSIGN aux_nmarqimp = "rl/" + aux_nmendter + STRING(TIME) + 
                                 /* para evitar duplicidade devido paralelismo */
                                 SUBSTRING(STRING(NOW),21,3) + "_3.ex"
                  glb_nrdevias = 2.  

      END.
      OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

      /*  Configura a impressora para 1/8"  */
      PUT STREAM str_1 CONTROL "\022\024\033\120\0330\033x0" NULL.

      /* Banco do Brasil */
      IF   aux_flgbanco  THEN
           DO:
              IF   SEARCH(aux_nmarqtp2) <> ?   THEN
                   DO:
                       INPUT STREAM str_3 FROM VALUE(aux_nmarqtp2) NO-ECHO.

                       aux_flgfirst = TRUE.
                       
                       DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                          
                          SET STREAM str_3 rel_nrdconta rel_cdbanchq
                                           rel_cdagechq rel_nrdocmto
                                           rel_nrdctabb rel_vlestour
                                           rel_idseqttl 
                                           WITH WIDTH 100. 
                     
                          IF   rel_nrdconta = 0 THEN
                               LEAVE.
            
                          IF   aux_flgfirst   THEN
                               DO:
                                   DISPLAY STREAM str_1 
                                           rel_dtdiamov  rel_nmmesref
                                           rel_dtanomov  crapcop.nmextcop
                                           rel_nmcidade[1]
                                           WITH FRAME f_cabec_bancoob.
                                   
                                   
                                   /*** Pessoa Juridica ***/
                                   IF  crapass.inpessoa <> 1 THEN
                                       DO:
                                            ASSIGN tel_nmextttl = tel_nmprimtl.

                                       END.
                                   ELSE 
                                       FOR EACH crapttl WHERE  
                                                crapttl.cdcooper = 
                                                               glb_cdcooper AND
                                                crapttl.nrdconta = tel_nrdconta
                                                NO-LOCK :
                                            
                                            ASSIGN tel_nmextttl =
                                                              crapttl.nmextttl.
                                       END.
                                   
                                   
                                   DISPLAY STREAM str_1
                                           crapcop.nmextcop   
                                           WITH FRAME f_escop_bancoob.
            
                                   DISPLAY STREAM str_1 
                                           WITH FRAME f_titulo_bcobrasil.

                                   aux_flgfirst = FALSE.
                               END.

                          RUN fontes/extenso.p (INPUT  rel_vlestour, 
                                                INPUT  62, 
                                                INPUT  16,
                                                INPUT  "M",              
                                                OUTPUT rel_dsexten1,
                                                OUTPUT rel_dsexten2).
  
                          RUN Tira_asterisco (INPUT  rel_dsexten1, 
                                              OUTPUT rel_dsexten1).
                                          
                          RUN Tira_asterisco (INPUT  rel_dsexten2, 
                                              OUTPUT rel_dsexten2).
                                            
                          IF   TRIM(rel_dsexten2," ") <> "" THEN
                               DO:
                                  ASSIGN rel_dsexten1 = "(" + rel_dsexten1.
                                         rel_dsexten2 = rel_dsexten2 + ")".
                 
                                  DISP STREAM str_1 rel_cdbanchq rel_cdagechq
                                                    rel_nrdctabb rel_nrdocmto
                                                    rel_vlestour rel_dsexten1
                                                    rel_dsexten2
                                                    rel_idseqttl 
                                                WITH FRAME f_relacao_bcobrasil2.
       
                                  DOWN STREAM str_1 
                                       WITH FRAME f_relacao_bcobrasil2.
                               END.
                          ELSE     
                               DO:
                                  ASSIGN rel_dsexten1 = 
                                         "(" + rel_dsexten1 + ")".
                                       
                                  DISP STREAM str_1 rel_cdbanchq rel_cdagechq
                                                    rel_nrdctabb rel_nrdocmto
                                                    rel_vlestour rel_dsexten1
                                                    rel_idseqttl 
                                                WITH FRAME f_relacao_bcobrasil.
       
                                  DOWN STREAM str_1 
                                              WITH FRAME f_relacao_bcobrasil.
                               END.

                          IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                               PAGE STREAM str_1.
     
                       END.    /*  Fim do While True  */
        
                       DISPLAY STREAM str_1 aux_vltotccf WITH FRAME f_rodape.                        
                       /*** Pessoa Juridica ***/
                       IF crapass.inpessoa <> 1 THEN
                          DO:
                                ASSIGN tel_nmextttl = tel_nmprimtl
                                       tel_nrcpfcgc = crapass.nrcpfcgc.
                                
                                DISPLAY STREAM str_1 tel_nmextttl
                                                     tel_nrcpfcgc
                                                     rel_nrdconta
                                                     crapope.cdoperad
                                                     crapope.nmoperad
                                                     WITH FRAME f_rodape2.
                          END.
                       ELSE 
                          FOR EACH crapttl WHERE  
                                           crapttl.cdcooper = glb_cdcooper AND
                                           crapttl.nrdconta = tel_nrdconta
                                           NO-LOCK :
                                    
                                   ASSIGN tel_nmextttl = crapttl.nmextttl
                                          tel_nrcpfcgc = crapttl.nrcpfcgc.   
                                  
                                   IF  crapttl.idseqttl = 1 OR 
                                       crapttl.idseqttl = 3 THEN
                                       DO:
                                           DISPLAY STREAM str_1 
                                                          tel_nmextttl
                                                          tel_nrcpfcgc
                                                          rel_nrdconta
                                                          crapope.cdoperad
                                                          crapope.nmoperad
                                                          WITH FRAME f_rodape2.
                                       END.
                                  
                                   IF  crapttl.idseqttl = 2 OR 
                                       crapttl.idseqttl = 4 THEN
                                       DO:    
                                           ASSIGN 
                                              tel_nmextttl2 = crapttl.nmextttl
                                              tel_nrcpfcgc2 = crapttl.nrcpfcgc
                                              rel_nrdconta2 = crapttl.nrdconta.
                                          
                                           DISPLAY STREAM str_1 
                                                          aux_dsdlinha
                                                          tel_nmextttl2
                                                          aux_dscpfcgc
                                                          tel_nrcpfcgc2
                                                          aux_nrdconta
                                                          rel_nrdconta2
                                                          crapope.cdoperad
                                                          crapope.nmoperad
                                                          WITH FRAME f_rodape2.
                                       END.       
                                  
                                   IF  crapttl.idseqttl = 2 THEN         
                                       DOWN STREAM str_1 WITH FRAME f_rodape2.
                         
                          END.
                      
                       PAGE STREAM str_1. 
                      
                      
                       ASSIGN aux_arquivaz = FALSE.
        
                       INPUT STREAM str_3 CLOSE.
                      
                   END.  /*  Fim  do  If  Search   */

              ASSIGN aux_flgbanco = FALSE.
              
           END.   /*   Fim do Banco do Brasil */
      ELSE
      /* Bancoob e CECRED */
           DO:
              /* BANCOOB */
              IF  aux_flgbncob  THEN
              DO:
              IF   SEARCH(aux_nmarqtp1) <> ?   THEN
                   DO:
                       INPUT STREAM str_3 FROM VALUE(aux_nmarqtp1) NO-ECHO.

                       aux_flgfirst = TRUE.
            
                       DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                       
                          SET STREAM str_3 rel_nrdconta rel_cdbanchq
                                           rel_cdagechq rel_nrdocmto
                                           rel_nrdctabb rel_vlestour
                                           rel_idseqttl 
                                           WITH WIDTH 100.
        
                          IF   rel_nrdconta = 0 THEN
                               LEAVE.
            
                          IF   aux_flgfirst   THEN
                               DO:
                                   DISPLAY STREAM str_1 
                                           rel_dtdiamov rel_nmmesref
                                           rel_dtanomov crapcop.nmextcop
                                           rel_nmcidade[1]
                                           WITH FRAME f_cabec_bancoob.

                                   
                                   /*** Pessoa Juridica ***/
                                   IF  crapass.inpessoa <> 1 THEN
                                       DO:
                                           ASSIGN tel_nmextttl = tel_nmprimtl.

                                       END.
                                   ELSE  /*** Pessoa Fisica ***/
                                       FOR EACH crapttl WHERE  
                                                crapttl.cdcooper = 
                                                               glb_cdcooper AND
                                                crapttl.nrdconta = tel_nrdconta
                                                NO-LOCK :
                                            
                                           ASSIGN tel_nmextttl =
                                                              crapttl.nmextttl.
                                       END.
                                   
                                   DISPLAY STREAM str_1
                                           crapcop.nmextcop   
                                           WITH FRAME f_escop_bancoob.
            
                                   DISPLAY STREAM str_1 
                                           WITH FRAME f_titulo_bcobrasil.

                                   aux_flgfirst = FALSE.
                               END.

                          RUN fontes/extenso.p (INPUT  rel_vlestour, 
                                                INPUT  62, 
                                                INPUT  16,
                                                INPUT  "M",              
                                                OUTPUT rel_dsexten1,
                                                OUTPUT rel_dsexten2).
  
                          RUN Tira_asterisco (INPUT  rel_dsexten1, 
                                              OUTPUT rel_dsexten1).
                                          
                          RUN Tira_asterisco (INPUT  rel_dsexten2, 
                                              OUTPUT rel_dsexten2).
                                            
                          IF   TRIM(rel_dsexten2," ") <> "" THEN
                               DO:
                                  ASSIGN rel_dsexten1 = "(" + rel_dsexten1.
                                         rel_dsexten2 = rel_dsexten2 + ")".
                 
                                  DISP STREAM str_1 rel_cdbanchq rel_cdagechq
                                                    rel_nrdctabb rel_nrdocmto
                                                    rel_vlestour rel_dsexten1
                                                    rel_dsexten2
                                                    rel_idseqttl 
                                                WITH FRAME f_relacao_bcobrasil2.
       
                                  DOWN STREAM str_1 
                                       WITH FRAME f_relacao_bcobrasil2.
                               END.
                          ELSE     
                               DO:
                                  ASSIGN rel_dsexten1 = 
                                         "(" + rel_dsexten1 + ")".
                                       
                                  DISP STREAM str_1 rel_cdbanchq rel_cdagechq
                                                    rel_nrdctabb rel_nrdocmto
                                                    rel_vlestour rel_dsexten1
                                                    rel_idseqttl 
                                                WITH FRAME f_relacao_bcobrasil.
       
                                  DOWN STREAM str_1 
                                              WITH FRAME f_relacao_bcobrasil.
                               END.

                          IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                               PAGE STREAM str_1.
     
                       END.    /*  Fim do While True  */

                       DISPLAY STREAM str_1 aux_vltotccf WITH FRAME f_rodape.
                      
                       /*** Pessoa Juridica ***/
                       IF  crapass.inpessoa <> 1 THEN
                           DO:
                               ASSIGN tel_nmextttl = tel_nmprimtl
                                      tel_nrcpfcgc = crapass.nrcpfcgc.
                               
                               DISPLAY STREAM str_1  tel_nmextttl
                                                     tel_nrcpfcgc
                                                     rel_nrdconta
                                                     crapope.cdoperad
                                                     crapope.nmoperad
                                                     WITH FRAME f_rodape2.
                           END.
                       ELSE   /*** Pessoa Fisica ***/ 
                          FOR EACH crapttl WHERE  
                                           crapttl.cdcooper = glb_cdcooper AND
                                           crapttl.nrdconta = tel_nrdconta
                                           NO-LOCK :
                                    
                                   ASSIGN tel_nmextttl = crapttl.nmextttl
                                          tel_nrcpfcgc = crapttl.nrcpfcgc.
                                             
                                   IF  crapttl.idseqttl = 1 OR 
                                       crapttl.idseqttl = 3 THEN
                                       DO:
                                           DISPLAY STREAM str_1 
                                                          tel_nmextttl
                                                          tel_nrcpfcgc 
                                                          rel_nrdconta
                                                          crapope.cdoperad
                                                          crapope.nmoperad
                                                          WITH FRAME f_rodape2.
                                       END.
                                  
                                   IF  crapttl.idseqttl = 2 OR 
                                       crapttl.idseqttl = 4 THEN
                                       DO:    
                                           ASSIGN 
                                               tel_nmextttl2 = crapttl.nmextttl
                                               tel_nrcpfcgc2 = crapttl.nrcpfcgc
                                               rel_nrdconta2 = crapttl.nrdconta.
                                             
                                           DISPLAY STREAM str_1 
                                                          aux_dsdlinha
                                                          aux_dscpfcgc
                                                          tel_nmextttl2
                                                          tel_nrcpfcgc2
                                                          aux_nrdconta
                                                          rel_nrdconta2
                                                          crapope.cdoperad
                                                          crapope.nmoperad
                                                          WITH FRAME f_rodape2.
                                       END.       
                                  
                                   IF  crapttl.idseqttl = 2 THEN         
                                       DOWN STREAM str_1 WITH FRAME f_rodape2.
                          END.
                      
                      PAGE STREAM str_1. 
                      
                      
                      ASSIGN aux_arquivaz = FALSE.
        
                      INPUT  STREAM str_3 CLOSE.
                      
                   END.  /*  Fim  do  If  Search Bancoob  */
              
              ASSIGN aux_flgbncob = FALSE. /* Seta para no proximo loop passar
                                              pelo banco CECRED */

              END. /* FIM BANCOOB */
              ELSE /* CECRED */
              DO:
              IF   SEARCH(aux_nmarqtp3) <> ?   THEN
                   DO:
                       INPUT STREAM str_4 FROM VALUE(aux_nmarqtp3) NO-ECHO.

                       aux_flgfirst = TRUE.

                       DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                          SET STREAM str_4 rel_nrdconta rel_cdbanchq
                                           rel_cdagechq rel_nrdocmto
                                           rel_nrdctabb rel_vlestour
                                           rel_idseqttl 
                                           WITH WIDTH 100.

                          IF   rel_nrdconta = 0 THEN
                               LEAVE.

                          IF   aux_flgfirst   THEN
                               DO:
                                   DISPLAY STREAM str_1 
                                           rel_dtdiamov rel_nmmesref
                                           rel_dtanomov crapcop.nmextcop
                                           rel_nmcidade[1]
                                           WITH FRAME f_cabec_bancoob.


                                   /*** Pessoa Juridica ***/
                                   IF  crapass.inpessoa <> 1 THEN
                                       DO:
                                           ASSIGN tel_nmextttl = tel_nmprimtl.

                                       END.
                                   ELSE  /*** Pessoa Fisica ***/
                                       FOR EACH crapttl WHERE  
                                                crapttl.cdcooper = 
                                                               glb_cdcooper AND
                                                crapttl.nrdconta = tel_nrdconta
                                                NO-LOCK :

                                           ASSIGN tel_nmextttl =
                                                              crapttl.nmextttl.
                                       END.

                                   DISPLAY STREAM str_1
                                           crapcop.nmextcop   
                                           WITH FRAME f_escop_bancoob.

                                   DISPLAY STREAM str_1 
                                           WITH FRAME f_titulo_bcobrasil.

                                   aux_flgfirst = FALSE.
                               END.

                          RUN fontes/extenso.p (INPUT  rel_vlestour, 
                                                INPUT  62, 
                                                INPUT  16,
                                                INPUT  "M",              
                                                OUTPUT rel_dsexten1,
                                                OUTPUT rel_dsexten2).

                          RUN Tira_asterisco (INPUT  rel_dsexten1, 
                                              OUTPUT rel_dsexten1).

                          RUN Tira_asterisco (INPUT  rel_dsexten2, 
                                              OUTPUT rel_dsexten2).

                          IF   TRIM(rel_dsexten2," ") <> "" THEN
                               DO:
                                  ASSIGN rel_dsexten1 = "(" + rel_dsexten1.
                                         rel_dsexten2 = rel_dsexten2 + ")".

                                  DISP STREAM str_1 rel_cdbanchq rel_cdagechq
                                                    rel_nrdctabb rel_nrdocmto
                                                    rel_vlestour rel_dsexten1
                                                    rel_dsexten2
                                                    rel_idseqttl 
                                                WITH FRAME f_relacao_bcobrasil2.

                                  DOWN STREAM str_1 
                                       WITH FRAME f_relacao_bcobrasil2.
                               END.
                          ELSE     
                               DO:
                                  ASSIGN rel_dsexten1 = 
                                         "(" + rel_dsexten1 + ")".

                                  DISP STREAM str_1 rel_cdbanchq rel_cdagechq
                                                    rel_nrdctabb rel_nrdocmto
                                                    rel_vlestour rel_dsexten1
                                                    rel_idseqttl 
                                                WITH FRAME f_relacao_bcobrasil.

                                  DOWN STREAM str_1 
                                              WITH FRAME f_relacao_bcobrasil.
                               END.

                          IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                               PAGE STREAM str_1.

                       END.    /*  Fim do While True  */

                       DISPLAY STREAM str_1 aux_vltotccf WITH FRAME f_rodape.

                       /*** Pessoa Juridica ***/
                       IF  crapass.inpessoa <> 1 THEN
                           DO:
                               ASSIGN tel_nmextttl = tel_nmprimtl
                                      tel_nrcpfcgc = crapass.nrcpfcgc.

                               DISPLAY STREAM str_1  tel_nmextttl
                                                     tel_nrcpfcgc
                                                     rel_nrdconta
                                                     crapope.cdoperad
                                                     crapope.nmoperad
                                                     WITH FRAME f_rodape2.
                           END.
                       ELSE   /*** Pessoa Fisica ***/ 
                          FOR EACH crapttl WHERE  
                                           crapttl.cdcooper = glb_cdcooper AND
                                           crapttl.nrdconta = tel_nrdconta
                                           NO-LOCK :

                                   ASSIGN tel_nmextttl = crapttl.nmextttl
                                          tel_nrcpfcgc = crapttl.nrcpfcgc.

                                   IF  crapttl.idseqttl = 1 OR 
                                       crapttl.idseqttl = 3 THEN
                                       DO:
                                           DISPLAY STREAM str_1 
                                                          tel_nmextttl
                                                          tel_nrcpfcgc 
                                                          rel_nrdconta
                                                          crapope.cdoperad
                                                          crapope.nmoperad
                                                          WITH FRAME f_rodape2.
                                       END.

                                   IF  crapttl.idseqttl = 2 OR 
                                       crapttl.idseqttl = 4 THEN
                                       DO:    
                                           ASSIGN 
                                               tel_nmextttl2 = crapttl.nmextttl
                                               tel_nrcpfcgc2 = crapttl.nrcpfcgc
                                               rel_nrdconta2 = crapttl.nrdconta.

                                           DISPLAY STREAM str_1 
                                                          aux_dsdlinha
                                                          aux_dscpfcgc
                                                          tel_nmextttl2
                                                          tel_nrcpfcgc2
                                                          aux_nrdconta
                                                          rel_nrdconta2
                                                          crapope.cdoperad
                                                          crapope.nmoperad
                                                          WITH FRAME f_rodape2.
                                       END.       

                                   IF  crapttl.idseqttl = 2 THEN         
                                       DOWN STREAM str_1 WITH FRAME f_rodape2.
                          END.

                      PAGE STREAM str_1. 

                      ASSIGN aux_arquivaz = FALSE.

                      INPUT  STREAM str_4 CLOSE.

                   END.  /*  Fim  do  If  Search CECRED  */
              END. /* FIM CECRED */
           END.   /*  Fim  */
       
      /* Impressao de cada relatorio - BB, BANCOOB e CECRED */
      IF   glb_cdcritic = 0  AND aux_arquivaz = FALSE THEN
           DO:
               OUTPUT STREAM str_1 CLOSE.
 
               /*** nao necessario ao programa somente para nao dar erro 
                    de compilacao na rotina de impressao ****/
   
               FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper
                                        NO-LOCK NO-ERROR.

               { includes/impressao.i }
               
               HIDE MESSAGE NO-PAUSE.
           END.
      ELSE
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
           END.
   END. /* Fim do DO..TO.. */

   ASSIGN aux_contchq = 0.

   /* Remove os arquivos temporarios */
   IF   SEARCH(aux_nmarqtp1) <> ?   THEN
        UNIX SILENT VALUE("rm " + aux_nmarqtp1 + " 2> /dev/null").

   IF   SEARCH(aux_nmarqtp2) <> ?   THEN
        UNIX SILENT VALUE("rm " + aux_nmarqtp2 + " 2> /dev/null").

   IF   SEARCH(aux_nmarqtp3) <> ?   THEN
        UNIX SILENT VALUE("rm " + aux_nmarqtp3 + " 2> /dev/null").


END PROCEDURE.   /*   fim da procedure p_imprimecarta_selecionados   */


PROCEDURE Tira_asterisco:

   DEFINE INPUT  PARAMETER aux_dsstring AS CHAR      NO-UNDO.
   DEFINE OUTPUT PARAMETER aux_dsreturn AS CHAR      NO-UNDO.

   DEFINE VAR    aux_conta AS INTEGER                NO-UNDO.

   aux_conta = 1.

   DO WHILE aux_conta <= LENGTH(aux_dsstring):

      IF   SUBSTR(aux_dsstring, aux_conta, 1) = "*" THEN
           LEAVE.
      ELSE
           aux_conta = aux_conta + 1.
   END.

   IF   (aux_conta = LENGTH(aux_dsstring)) OR
        (aux_conta = 0)   THEN
        aux_dsreturn = "".
   ELSE
        aux_dsreturn = SUBSTR(aux_dsstring, 1, aux_conta - 1).

END PROCEDURE.

PROCEDURE p_conta_integracao:

    DEF VAR aux_ultlinha   AS INT                                   NO-UNDO.
    
    DEF QUERY q_crawneg FOR crawneg.
    
    DEF BROWSE b_crawneg QUERY q_crawneg
        DISPLAY crawneg.nrdconta COLUMN-LABEL "CONTA/DV"
                crawneg.dtiniest COLUMN-LABEL "INI.ESTOURO"
                crawneg.vlestour COLUMN-LABEL "VALOR" 
                crawneg.nrdocmto COLUMN-LABEL "DOCUMENTO"   FORMAT "999,999,9"
                crawneg.dsflgcti COLUMN-LABEL "SITUACAO"    FORMAT "x(13)"
                crawneg.flgenvio NO-LABEL
                WITH 10 DOWN TITLE aux_tldatela.

    FORM b_crawneg HELP "Pressione ENTER para incluir no CCF / F4 para sair"
         WITH NO-BOX OVERLAY ROW 6 CENTERED FRAME f_inclusao_itg.

    ON RETURN OF b_crawneg DO:

       IF   NOT AVAILABLE crawneg   THEN
            RETURN.
                
       ASSIGN crawneg.flgenvio = NOT crawneg.flgenvio
              aux_ultlinha = CURRENT-RESULT-ROW ("q_crawneg").
                
       OPEN QUERY q_crawneg FOR EACH crawneg BY crawneg.nrdconta 
                                               BY crawneg.dtiniest.

       REPOSITION q_crawneg TO ROW aux_ultlinha.

    END.
    
    /* Titulo da tela */
    aux_tldatela = " INCLUSAO NO CCF - CONTAS DE INTEGRACAO".
    
    IF   tel_cdagenci = 0   THEN
         aux_tldatela = aux_tldatela + " - TODOS OS PA'S ".
    ELSE
         aux_tldatela = aux_tldatela + " - PA " + STRING(tel_cdagenci,"zz9") +
                        " ".
    
    EMPTY TEMP-TABLE crawneg.
    
    /* carrega a tabela temporaria ate 10 dias atras */
    FOR EACH crapneg WHERE crapneg.cdcooper = glb_cdcooper           AND
                           crapneg.cdhisest = 1                      AND
                           crapneg.dtfimest = ?                      AND
                           crapneg.dtiniest <= (glb_dtmvtolt - 10)   AND
                          (crapneg.cdobserv = 12                     OR
                           crapneg.cdobserv = 13)                    AND
                          /* 0-Nao enviada | 4-Reenviar | 5-Enviar Inclusao */
                          (crapneg.flgctitg = 0                      OR
                           crapneg.flgctitg = 4                      OR
                           crapneg.flgctitg = 5)                     NO-LOCK
                           USE-INDEX crapneg6,
        EACH crapass WHERE crapass.cdcooper = glb_cdcooper           AND
                           crapass.nrdconta = crapneg.nrdconta       AND
                           crapass.flgctitg = 2                      AND
                           crapass.nrdctitg <> ""                    AND
                          (crapass.cdagenci = tel_cdagenci           OR
                           tel_cdagenci     = 0)                     NO-LOCK:

        IF   SUBSTRING(STRING(crapass.nrdctitg,"xxxxxxxx"),1,7) =
             SUBSTRING(STRING(crapneg.nrdctabb,"99999999"),1,7)     THEN
             DO:
                CREATE crawneg.
                ASSIGN crawneg.nrdconta = crapneg.nrdconta
                       crawneg.nrseqdig = crapneg.nrseqdig
                       crawneg.dtiniest = crapneg.dtiniest
                       crawneg.dtfimest = crapneg.dtfimest
                       crawneg.vlestour = crapneg.vlestour
                       crawneg.nrdocmto = crapneg.nrdocmto
                       crawneg.dsflgcti = IF crapneg.flgctitg = 0 THEN  
                                             "0-NAO ENVIADA"
                                          ELSE
                                          IF crapneg.flgctitg = 4 THEN
                                             "4-REENVIAR"
                                          ELSE
                                             "5-ENVIAR INC."
                       crawneg.flgenvio = IF crapneg.flgctitg = 5 THEN
                                             TRUE
                                          ELSE
                                             FALSE.
             END.
    END.                           

    OPEN QUERY q_crawneg FOR EACH crawneg BY crawneg.nrdconta 
                                            BY crawneg.dtiniest.
    
    HIDE MESSAGE NO-PAUSE.
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       UPDATE b_crawneg WITH FRAME f_inclusao_itg.
       LEAVE.
    END.
    
    /* pede confirmacao */
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

       ASSIGN aux_confirma = "N"
              glb_cdcritic = 78.

       RUN fontes/critic.p.
       BELL.
       MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
       glb_cdcritic = 0.
       LEAVE.
    END.
                             
    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
         aux_confirma <> "S" THEN
         DO:
            glb_cdcritic = 79.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            RETURN.
         END.
        
    /* atualiza as flag's (flgctitg) para incluir no CCF ou calcelar envio */
    FOR EACH crawneg NO-LOCK:
            
        DO aux_contador = 1 TO 10:

           FIND crapneg WHERE crapneg.cdcooper = glb_cdcooper       AND
                              crapneg.nrdconta = crawneg.nrdconta   AND
                              crapneg.nrseqdig = crawneg.nrseqdig
                              USE-INDEX crapneg1
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                  
           IF   NOT AVAILABLE crapneg   THEN
                IF   LOCKED crapneg   THEN
                     DO:
                        IF   aux_contador = 10   THEN
                             DO:
                                glb_cdcritic = 77.
                                RUN fontes/critic.p.
                                MESSAGE glb_dscritic.
                                glb_cdcritic = 0.
                                RETURN.
                             END.
                                 
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                     END.
                ELSE
                     DO:
                        glb_cdcritic = 419.
                        RUN fontes/critic.p.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        RETURN.
                     END.
               
           crapneg.flgctitg = IF crawneg.flgenvio = TRUE THEN
                                 5 /* enviar como inclusao no CCF */
                              ELSE
                              IF crapneg.flgctitg = 5     AND
                                 crawneg.flgenvio = FALSE THEN
                                 0 /* cancelar envio */
                              ELSE
                                 crapneg.flgctitg. /* nao muda */
            
        END. /* fim DO .. TO .. */
    END. /* fim FOR EACH */

END PROCEDURE.


PROCEDURE atualiza_browser:

   EMPTY TEMP-TABLE cratneg.
   
   FOR EACH crapneg WHERE crapneg.cdcooper = glb_cdcooper      AND
                          crapneg.nrdconta = crapass.nrdconta  AND
                          crapneg.cdhisest = 1                 AND
                          CAN-DO("12,13", STRING(crapneg.cdobserv)) 
                          USE-INDEX crapneg1 NO-LOCK: 

       FIND crapope WHERE crapope.cdcooper = glb_cdcooper AND
                          crapope.cdoperad = crapneg.cdoperad
                          NO-LOCK NO-ERROR.

       IF   AVAILABLE crapope THEN
            aux_nmoperad = STRING(ENTRY(1, crapope.nmoperad," "),"x(11)").
       ELSE                        
            aux_nmoperad = "".
    
       CREATE cratneg.
       ASSIGN cratneg.nrseqdig = crapneg.nrseqdig
              cratneg.dtiniest = crapneg.dtiniest
              cratneg.cdbanchq = crapneg.cdbanchq
              cratneg.nrctachq = crapneg.nrctachq
              cratneg.cdobserv = crapneg.cdobserv
              cratneg.nrdocmto = crapneg.nrdocmto
              cratneg.vlestour = crapneg.vlestour
              cratneg.dtfimest = crapneg.dtfimest
              cratneg.nmoperad = aux_nmoperad
              cratneg.flgselec = FALSE
              cratneg.flgctitg = crapneg.flgctitg
              cratneg.idseqttl = crapneg.idseqttl.  
                 
   END.    /*   Fim do for each crapneg   */
   
   OPEN QUERY q_manccf FOR EACH cratneg SHARE-LOCK.
   
END.         
         
         
PROCEDURE p_titular:

    EMPTY TEMP-TABLE cratttl.
    ASSIGN aux_qtdtitul = 0.

     
    IF crapass.inpessoa = 2 THEN
       DO:
            CREATE cratttl.
            ASSIGN cratttl.idseqttl = 1 
                   cratttl.nmextttl = crapass.nmprimtl.
                   aux_qtdtitul = aux_qtdtitul + 1.
       END.
    
    FOR EACH crapttl WHERE crapttl.cdcooper = glb_cdcooper AND
                           crapttl.nrdconta = tel_nrdconta 
                           NO-LOCK:
    
             CREATE cratttl.
             ASSIGN cratttl.idseqttl = crapttl.idseqttl
                    cratttl.nmextttl = crapttl.nmextttl
                    aux_qtdtitul = aux_qtdtitul + 1.          

    END.

    IF  aux_qtdtitul > 1 THEN
        DO:
            CREATE  cratttl.
            ASSIGN  cratttl.idseqttl = 9 
                    cratttl.nmextttl = "TODOS".
        END.

    OPEN QUERY q_titular FOR EACH cratttl.
    
    UPDATE b_titular WITH FRAME f_titular.

END PROCEDURE.

PROCEDURE proc_crialog:

DEF   INPUT PARAMETER   aux_opcreg   AS CHAR                        NO-UNDO.
DEF   INPUT PARAMETER   aux_nrdocmto AS DECI                        NO-UNDO.

     UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "  +
                      STRING(TIME,"HH:MM:SS") + "' --> '"                 +
                      " Operador "  + glb_cdoperad                        +
                      " solicitou " + aux_opcreg                          + 
                      " na solicitacao de regularizacao "                 +
                      "do cheque "  + STRING(aux_nrdocmto,"zzz,zzz,9")    +
                      " na conta "  + STRING(tel_nrdconta,"zzzz,zzz,9")   +
                      " >> log/manccf.log").

END PROCEDURE.

PROCEDURE proc_crialog_2:

DEF   INPUT PARAMETER aux_nrdconta   AS INTE                        NO-UNDO.
DEF   INPUT PARAMETER aux_idseqttl   AS INTE                        NO-UNDO.
DEF   INPUT PARAMETER aux_idseqttl_2 AS INTE                        NO-UNDO.
DEF   INPUT PARAMETER aux_nrdocmto   AS DECI                        NO-UNDO.


     UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "  +
                      STRING(TIME,"HH:MM:SS") + "' --> '"                 +
                      " Operador "  + glb_cdoperad                        +
                      " alterou a titularidade"                           +
                      " da conta"     + STRING(aux_nrdconta,"zzzz,zzz,9") +
                      " - referente ao cheque "   
                                      + STRING(aux_nrdocmto,"zzz,zzz,9")  +
                      " -"                                                +
                      " de "          + STRING(aux_idseqttl,"9")          + 
                      " para "        + STRING(aux_idseqttl_2,"9")        +
                      " >> log/manccf.log").

END PROCEDURE.
/* ........................................................................ */

