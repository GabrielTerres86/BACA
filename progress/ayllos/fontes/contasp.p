
/* ............................................................................

   Programa: Fontes/contasp.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Fevereiro/2006                   Ultima Atualizacao: 25/01/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Efetuar Cadastramento de pessoa FISICA
                                                 
   Alteracoes: 19/03/2007 - Incluida opcao INFORMATIVOS (Diego).
               
               29/08/2007 - Permitido a todos os titulares da conta, acessar a
                            opcao "Cliente Financeiro" e nao passar parametros
                            na chamada desta opcao (Elton).

               30/01/2009 - Retirada variavel tel_inarqcbr 'Recebe Arq.Cobranca'
                            e email (Gabriel).
                          - Verificar registro crapttl no caso de erro na 
                            inclusao de novo titular (David).
                          
               19/06/2009 - Incluido ITEM bens (Gabriel).
               
               03/12/2009 - Incluido Item "INF. ADICIONAL" (Elton). 
               
               15/03/2010 - Adaptado para uso de BO (Jose Luis, DB1)
               
               25/09/2010 - Procuradores p/ pessoa fisica (Jose Luis, DB1)
               
               11/10/2010 - Verifica vigência dos procuradores (Gabriel, DB1)
               
               07/12/2010 - Retirado verifição da vigência dos procuradores.
                            Passada para BO 31. (Gabriel, DB1)
                            
               23/03/2011 - Incluir rotina de DDA (Gabriel).             
               
               16/04/2012 - Ajuste referente ao projeto GP - Socios Menores
                           (Adriano).
                            
               22/02/2013 - Incluido a chamada para a procedure 
                            bloqueio_prova_vida na procedure Atualiza-Tela
                            (Adriano).
                            
               24/07/2014 - Projeto Automatização de Consultas em Propostas 
                            de Crédito (Jonata-RKAM).
                            
               30/12/2014 - Incluir item novo "Liberar/Bloquear". (James)
               
               02/03/2015 - Incluido de opcao Convenio CDC - Pessoa Fisica
                            (Andre Santos - SUPERO)
                            
               27/07/2015 - Reformulacao cadastral (Gabriel-RKAM).     
               
               01/09/2015 - Reformulacao cadastral (Tiago Castro-RKAM).
               
               25/01/2016 - #383108 Ajuste das opcoes da tela pois nao estavam
                            aparecendo as opcoes BENS e INF. ADICIONAIS
                            corretamente (Carlos)
.............................................................................*/

{ includes/var_online.i }
{ includes/var_contas.i }
{ sistema/generico/includes/b1wgen0031tt.i}
{ sistema/generico/includes/b1wgen0051tt.i}
{ sistema/generico/includes/b1wgen0072tt.i}
{ sistema/generico/includes/var_internet.i}
{ sistema/generico/includes/gera_log.i}
{ sistema/generico/includes/gera_erro.i}



DEFINE VARIABLE aux_nrmatric AS INTE        NO-UNDO.
DEFINE VARIABLE aux_cdagepac AS INTE        NO-UNDO.
DEFINE VARIABLE aux_permalte AS LOG         NO-UNDO.

ON LEAVE OF tel_nrdconta IN FRAME f_conta DO:

    ASSIGN INPUT tel_nrdconta.

    RUN Busca-Associado.

    IF  RETURN-VALUE <> "OK" THEN 
        DO:
           DISPLAY "" @ tel_nrdconta WITH FRAME f_conta.
           RETURN NO-APPLY.
        END.

    /* Carrega a matricula e o PAC */
    FIND tt-crapass WHERE tt-crapass.cdcooper = glb_cdcooper AND
                          tt-crapass.nrdconta = tel_nrdconta   
                          NO-LOCK NO-ERROR.

    IF NOT AVAILABLE tt-crapass THEN
       NEXT.

    ASSIGN tel_dsagenci = tt-crapass.dsagenci.

    DISPLAY tt-crapass.cdagenci @ crapass.cdagenci  tel_dsagenci 
            tt-crapass.nrmatric @ crapass.nrmatric  
            WITH FRAME f_conta.

   /* Nao pedir titular para chamar tela de pessoa juridica */
   IF tt-crapass.inpessoa <> 1   THEN
      APPLY "GO".

END.

DO WHILE TRUE:

   ASSIGN tel_idseqttl = 1
          glb_cdcritic = 0
          glb_cddopcao = "C".

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
      COLOR DISPLAY NORMAL tel_dsdopcao[01]  tel_dsdopcao[02]  tel_dsdopcao[03]
                           tel_dsdopcao[04]  tel_dsdopcao[05]  tel_dsdopcao[06]
                           tel_dsdopcao[07]  tel_dsdopcao[08]  tel_dsdopcao[09]
                           tel_dsdopcao[10]  tel_dsdopcao[11]  tel_dsdopcao[12]
                           tel_dsdopcao[13]  tel_dsdopcao[14]  tel_dsdopcao[16]  
                           tel_dsdopcao[17]  tel_dsdopcao[19]  tel_dsdopcao[21]  
                           WITH FRAME f_conta.
                           
      CLEAR FRAME f_conta NO-PAUSE.

      UPDATE tel_nrdconta
             tel_idseqttl 
             WITH FRAME f_conta
          
      EDITING:
      
         READKEY.

         HIDE MESSAGE NO-PAUSE.

         IF LASTKEY = KEYCODE("F7") THEN
            DO:
                IF FRAME-FIELD = "tel_nrdconta" THEN
                   DO:
                       RUN fontes/zoom_associados.p (INPUT  glb_cdcooper,
                                                     OUTPUT tel_nrdconta).

                       IF tel_nrdconta > 0   THEN
                          DO:
                               DISPLAY tel_nrdconta WITH FRAME f_conta.
                   
                               PAUSE 0.
                          END.

                   END.
                   
                IF FRAME-FIELD = "tel_idseqttl" THEN
                   DO:
                       IF INPUT FRAME f_conta tel_nrdconta = 0   THEN
                          DO:
                              glb_cdcritic = 127.
                              RUN fontes/critic.p.
                              BELL.
                              MESSAGE glb_dscritic.
                              glb_cdcritic = 0.
                              NEXT.
                          END.

                       ASSIGN shr_nrdconta = INPUT FRAME f_conta
                                                   tel_nrdconta
                              shr_idseqttl = INPUT FRAME f_conta
                                                   tel_idseqttl.

                       RUN fontes/zoom_seq_titulares.p (glb_cdcooper).

                       IF shr_idseqttl <> 0 THEN
                          DO:
                              ASSIGN tel_idseqttl = shr_idseqttl.
                              DISPLAY tel_idseqttl WITH FRAME f_conta.
                              NEXT-PROMPT tel_idseqttl
                                          WITH FRAME f_conta.
                          END.
                   END.

                IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                   NEXT.
            END.

         APPLY LASTKEY.
          
      END. /* Fim do EDITING*/

      { includes/acesso.i }
      
      RUN Atualiza-Tela.
      
      IF  RETURN-VALUE <> "OK" THEN
          RETURN NO-APPLY.

      LEAVE.
   END.

   IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
      DO:   
          RUN fontes/novatela.p.
          IF CAPS(glb_nmdatela) <> "CONTAS"   THEN
             DO:
                 HIDE FRAME f_conta.
                 RETURN.
             END.
          ELSE     
             NEXT.
      END.
         
   /* Carrega a matricula e o PAC */
   FIND tt-crapass WHERE tt-crapass.cdcooper = glb_cdcooper AND
                         tt-crapass.nrdconta = tel_nrdconta   
                         NO-LOCK NO-ERROR.

   IF NOT AVAILABLE tt-crapass   THEN
      LEAVE.

   IF tt-crapass.inpessoa <> 1   THEN
      DO:
          /* Tela de cadastro de pessoa juridica */
          RUN fontes/contas_j.p.
          NEXT.
      END.
   
   FIND tt-crapttl WHERE tt-crapttl.cdcooper = glb_cdcooper AND
                         tt-crapttl.nrdconta = tel_nrdconta AND
                         tt-crapttl.idseqttl = tel_idseqttl 
                         NO-LOCK NO-ERROR.

   IF NOT AVAILABLE tt-crapttl   THEN
      DO:
          /* Verifica o sequencial de titular */
          FIND LAST tt-crapttl WHERE tt-crapttl.cdcooper = glb_cdcooper AND
                                     tt-crapttl.nrdconta = tel_nrdconta
                                     NO-LOCK NO-ERROR.
                                  
          /* Nao eh o proximo nro de titularidade */
          IF tt-crapttl.idseqttl <> tel_idseqttl - 1   THEN
             DO:
                 glb_cdcritic = 822.
                 RUN fontes/critic.p.
                 BELL.
                 MESSAGE glb_dscritic.
                 glb_cdcritic = 0.
                 NEXT.
             END.
      
          /* Chama a tela de IDENTIFICACAO para possibilitar o cadastramento,
             do titular informado */
          ASSIGN glb_cddopcao = "I"
                 glb_nmrotina = "IDENTIFICACAO".
                 
          MESSAGE "Inclusao de titular...".
          { includes/acesso.i }
                   
          RUN fontes/contas_dados.p.
          
          IF glb_cdcritic <> 0 THEN
             DO:
                 glb_cdcritic = 0.
                 NEXT.
             END.

          /* recarregar os dados da conta */
          RUN Busca-Associado.

          /* Carrega a matricula e o PAC */
          FIND tt-crapass WHERE tt-crapass.cdcooper = glb_cdcooper AND
                                tt-crapass.nrdconta = tel_nrdconta   
                                NO-LOCK NO-ERROR.

          IF NOT AVAILABLE tt-crapass   THEN
             NEXT.

          IF KEYFUNCTION(LASTKEY) <> "END-ERROR"   THEN
             DO:
                FIND tt-crapttl WHERE 
                                tt-crapttl.cdcooper = glb_cdcooper   AND
                                tt-crapttl.nrdconta = tel_nrdconta   AND
                                tt-crapttl.idseqttl = tel_idseqttl   
                                NO-LOCK NO-ERROR.

                IF NOT AVAILABLE tt-crapttl   THEN                   
                   NEXT.
             END.                       
          ELSE
             NEXT.
      END.

   ASSIGN tel_dsdopcao[01] = "IDENTIFICACAO"
          tel_dsdopcao[02] = "FILIACAO"
          tel_dsdopcao[03] = "ENDERECO"
          tel_dsdopcao[04] = "COMERCIAL"
          tel_dsdopcao[05] = "BENS"
          tel_dsdopcao[06] = "TELEFONES"
          tel_dsdopcao[07] = "E_MAILS"
          tel_dsdopcao[08] = "CONJUGE"
          tel_dsdopcao[09] = "DEPENDENTES"
          tel_dsdopcao[10] = "CONTATOS"
          tel_dsdopcao[11] = "PROCURADORES"
          tel_dsdopcao[12] = "RESPONSAVEL LEGAL"
          tel_dsdopcao[13] = "CONTA CORRENTE"
          tel_dsdopcao[14] = "ORGAOS PROT. AO CREDITO"
          tel_dsdopcao[16] = "CLIENTE FINANCEIRO"
          tel_dsdopcao[17] = "IMPRESSOES"
          tel_dsdopcao[18] = "FICHA CADASTRAL"
          tel_dsdopcao[19] = "INFORMATIVOS"         
          tel_dsdopcao[20] = "INF. ADICIONAL"
          tel_dsdopcao[21] = "DESABILITAR OPERACOES".              

   DISPLAY tel_dsagenci       
           tel_nrdconta       
           tel_dspessoa       
           tel_nrcpfcgc       
           tel_idseqttl
           tel_cdsexotl       
           tel_dsestcvl       
           tel_dstipcta       
           tel_dssitdct       
           tt-crapttl.nmextttl @ crapttl.nmextttl   
           tt-crapttl.cdestcvl @ crapttl.cdestcvl
           tt-crapass.cdagenci @ crapass.cdagenci
           tt-crapass.inpessoa @ crapass.inpessoa   
           tt-crapass.cdtipcta @ crapass.cdtipcta
           tt-crapass.nrdctitg @ crapass.nrdctitg   
           tt-crapass.cdsitdct @ crapass.cdsitdct   
           tel_dsdopcao[01]
           tel_dsdopcao[02]   tel_dsdopcao[03]   tel_dsdopcao[04]
           tel_dsdopcao[05]   tel_dsdopcao[06]   tel_dsdopcao[07]
           tel_dsdopcao[08]   tel_dsdopcao[09]   tel_dsdopcao[10]
           tel_dsdopcao[11]   tel_dsdopcao[12]   tel_dsdopcao[13]
           tel_dsdopcao[14]   tel_dsdopcao[16]   tel_dsdopcao[17]
           tel_dsdopcao[18]   tel_dsdopcao[19]   tel_dsdopcao[20]   
           tel_dsdopcao[21]   
           WITH FRAME f_conta.  

   RUN exibe-mensagens-alerta.
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      CHOOSE FIELD tel_dsdopcao[01]   tel_dsdopcao[02]   tel_dsdopcao[03]
                   tel_dsdopcao[04]   tel_dsdopcao[05]   tel_dsdopcao[06]
                   tel_dsdopcao[07]   tel_dsdopcao[08]   tel_dsdopcao[09]
                   tel_dsdopcao[10]   tel_dsdopcao[11]   tel_dsdopcao[12]
                   tel_dsdopcao[13]   tel_dsdopcao[14]   tel_dsdopcao[16]   
                   tel_dsdopcao[17]   tel_dsdopcao[18]   tel_dsdopcao[19]
                   tel_dsdopcao[20]   tel_dsdopcao[21]
             PAUSE 60 WITH FRAME f_conta.
   
      IF LASTKEY = -1   THEN
         LEAVE.

      HIDE MESSAGE NO-PAUSE.
      
      IF FRAME-VALUE = tel_dsdopcao[1]   THEN
         DO:
            ASSIGN glb_cddopcao = "@"
                   glb_nmrotina = "IDENTIFICACAO".
                   
            { includes/acesso.i }
             
            RUN fontes/contas_dados.p.

            /* recarregar os dados da conta */
            RUN Busca-Associado.

            FIND tt-crapttl WHERE tt-crapttl.cdcooper = glb_cdcooper AND
                                  tt-crapttl.nrdconta = tel_nrdconta AND
                                  tt-crapttl.idseqttl = tel_idseqttl 
                                  NO-LOCK NO-ERROR.
         END.    
      ELSE
      IF FRAME-VALUE = tel_dsdopcao[2]   THEN
         DO:
            ASSIGN glb_cddopcao = "@"
                   glb_nmrotina = "FILIACAO".
                   
            { includes/acesso.i }

            RUN fontes/contas_filiacao.p.
         END.    
      ELSE
      IF FRAME-VALUE = tel_dsdopcao[3]   THEN
         DO:
            ASSIGN glb_cddopcao = "@"
                   glb_nmrotina = "ENDERECO".
                   
            { includes/acesso.i }
            RUN fontes/contas_endereco.p.
         END.   
      ELSE
      IF FRAME-VALUE = tel_dsdopcao[4]   THEN
         DO:
            ASSIGN glb_cddopcao = "@"
                   glb_nmrotina = "COMERCIAL".
                   
            { includes/acesso.i }

            RUN fontes/contas_comercial.p.
         END.   
      ELSE
      IF FRAME-VALUE = tel_dsdopcao[5]   THEN
         DO:
            ASSIGN glb_cddopcao = "@"
                   glb_nmrotina = "BENS".
                   
            { includes/acesso.i }

            RUN fontes/contas_bens.p.
         END.
      ELSE
      IF FRAME-VALUE = tel_dsdopcao[6]   THEN
         DO:
            ASSIGN glb_cddopcao = "@"
                   glb_nmrotina = "TELEFONES".
                   
            { includes/acesso.i }

            RUN fontes/contas_telefones.p.
         END.   
      ELSE
      IF FRAME-VALUE = tel_dsdopcao[7]   THEN
         DO:
            ASSIGN glb_cddopcao = "@"
                   glb_nmrotina = "E_MAILS".
                   
            { includes/acesso.i }

            RUN fontes/contas_emails.p.
         END.   
      ELSE  
      IF FRAME-VALUE = tel_dsdopcao[8]   THEN
         DO:
            ASSIGN glb_cddopcao = "@"
                   glb_nmrotina = "CONJUGE".
                   
            { includes/acesso.i }

            IF tt-crapttl.cdestcvl <> 1 AND       /*SOLTEIRO*/
               tt-crapttl.cdestcvl <> 5 AND       /*VIUVO*/
               tt-crapttl.cdestcvl <> 6 AND       /*SEPARADO*/
               tt-crapttl.cdestcvl <> 7 THEN     /*DIVORCIADO*/
               RUN fontes/contas_conjuge.p.
            ELSE
               DO:
                  MESSAGE "Estado civil do associado nao permite conjuge.".
                  PAUSE 3 NO-MESSAGE.  
               END.                    
         END.    
      ELSE
      IF FRAME-VALUE = tel_dsdopcao[9]   THEN
         DO:
            ASSIGN glb_cddopcao = "@"
                   glb_nmrotina = "DEPENDENTES".
                   
            { includes/acesso.i }

            RUN fontes/contas_dependentes.p.
         END.   
      ELSE
      IF FRAME-VALUE = tel_dsdopcao[10]   THEN
         DO:
            ASSIGN glb_cddopcao = "@"
                   glb_nmrotina = "CONTATOS".
                   
            { includes/acesso.i }

            RUN fontes/contas_contatos.p.
         END.   
      ELSE
      IF FRAME-VALUE = tel_dsdopcao[11]   THEN
         DO:
            ASSIGN glb_cddopcao = "@"
                   glb_nmrotina = "PROCURADORES".

            { includes/acesso.i }
                                
            RUN fontes/contas_procuradores_fisica.p.
         END.   
      ELSE
      IF FRAME-VALUE = tel_dsdopcao[12]   THEN
         DO:
            ASSIGN glb_cddopcao = "@"
                   glb_nmrotina = "RESPONSAVEL LEGAL".
                   
            { includes/acesso.i }

            FIND tt-crapttl WHERE tt-crapttl.cdcooper = glb_cdcooper AND
                                  tt-crapttl.nrdconta = tel_nrdconta AND
                                  tt-crapttl.idseqttl = tel_idseqttl 
                                  NO-LOCK NO-ERROR.

            RUN fontes/contas_responsavel.p (INPUT glb_nmrotina,
                                             INPUT tt-crapttl.nrdconta,
                                             INPUT tt-crapttl.idseqttl,
                                             INPUT tt-crapttl.nrcpfcgc,
                                             INPUT tt-crapttl.dtnasttl,
                                             INPUT tt-crapttl.inhabmen,
                                             OUTPUT aux_permalte,
                                             INPUT-OUTPUT TABLE tt-resp).
         END.   
      ELSE  
      IF FRAME-VALUE = tel_dsdopcao[13]   THEN
         DO:
            ASSIGN glb_cddopcao = "@"
                   glb_nmrotina = "CONTA CORRENTE".
                   
            { includes/acesso.i }

            RUN fontes/contas_corrente.p.

         END. 
            ELSE
      IF FRAME-VALUE = tel_dsdopcao[14]   THEN
         DO:
             ASSIGN glb_cddopcao = "@" 
                    glb_nmrotina = "ORGAOS PROT. AO CREDITO".

             { includes/acesso.i }

             RUN fontes/protecao_credito.p (INPUT tt-crapass.inpessoa).
         END.
      ELSE
      IF   FRAME-VALUE = tel_dsdopcao[16]   THEN
           DO:
              ASSIGN glb_cddopcao = "@"
                     glb_nmrotina = "CLIENTE FINANCEIRO".
                     
              { includes/acesso.i }
                     
              RUN fontes/conta_sfn.p.
           END.
      ELSE
      IF FRAME-VALUE = tel_dsdopcao[17]   THEN
         DO:
            ASSIGN glb_cddopcao = "@"
                   glb_nmrotina = "IMPRESSOES".
                   
            { includes/acesso.i }

            RUN fontes/impressoes.p.
         END.   
      ELSE
      IF FRAME-VALUE = tel_dsdopcao[18]   THEN
         DO:
            ASSIGN glb_cddopcao = "@"
                   glb_nmrotina = "FICHA CADASTRAL".
                   
            { includes/acesso.i }

            RUN fontes/ver_ficha_cadastral.p (TRUE).
         END.
      ELSE
      IF FRAME-VALUE = tel_dsdopcao[19]   THEN
         DO:
            ASSIGN glb_cddopcao = "@"
                   glb_nmrotina = "INFORMATIVOS".
                   
            { includes/acesso.i }

            RUN fontes/contas_informativos.p.
         END.
      ELSE
      IF FRAME-VALUE = tel_dsdopcao[20]   THEN
         DO:
            ASSIGN glb_cddopcao = "@"
                   glb_nmrotina = "FINANCEIRO-INF.ADICIONAIS".
                                     
            { includes/acesso.i }
            
            RUN fontes/contas_infadicional.p.
            
         END.
      ELSE
      IF FRAME-VALUE = tel_dsdopcao[21]   THEN
         DO:
            ASSIGN glb_cddopcao = "@"
                   glb_nmrotina = "DESABILITAR OPERACOES".
                                     
            { includes/acesso.i }
            
            RUN fontes/contas_liberar_bloquear.p.
         END.

      glb_nmrotina = "".
      
   END. /* Fim da escolha */
  
END.

/*..........................................................................*/
 
PROCEDURE Busca-Associado:

    DEFINE VARIABLE h-b1wgen0051 AS HANDLE      NO-UNDO.
    
    IF  NOT VALID-HANDLE(h-b1wgen0051) THEN
        RUN sistema/generico/procedures/b1wgen0051.p
            PERSISTENT SET h-b1wgen0051.
    
    ASSIGN glb_dscritic = ""
           glb_cdcritic = 0.

    RUN Busca-Associado IN h-b1wgen0051
        ( INPUT glb_cdcooper,
          INPUT glb_cdagenci,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT tel_nrdconta,
          INPUT 1,
          INPUT glb_nmdatela,
          INPUT tel_idseqttl,
          INPUT glb_dtmvtolt,
         OUTPUT TABLE tt-mensagens-contas,
         OUTPUT TABLE tt-crapass,
         OUTPUT TABLE tt-crapttl,
         OUTPUT TABLE tt-erro ).


    IF  RETURN-VALUE <> "OK" THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               DO:
                  MESSAGE tt-erro.dscritic.

                  IF VALID-HANDLE(h-b1wgen0051) THEN
                     DELETE OBJECT h-b1wgen0051.

                  RETURN "NOK".

               END.

        END.

    IF VALID-HANDLE(h-b1wgen0051) THEN
       DELETE OBJECT h-b1wgen0051.
    
   RETURN "OK".

END PROCEDURE.

PROCEDURE Atualiza-Tela:

    DEF VAR h-b1wgen0031 AS HANDLE                              NO-UNDO.
    
    /* Carrega a matricula e o PAC */
    FIND tt-crapass WHERE tt-crapass.cdcooper = glb_cdcooper AND
                          tt-crapass.nrdconta = tel_nrdconta   
                          NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE tt-crapass THEN
        RETURN "NOK".

    FIND tt-crapttl WHERE tt-crapttl.cdcooper = glb_cdcooper AND
                          tt-crapttl.nrdconta = tel_nrdconta AND
                          tt-crapttl.idseqttl = tel_idseqttl 
                          NO-LOCK NO-ERROR.

    IF AVAILABLE tt-crapttl THEN
       DO:
          ASSIGN tel_dsagenci = tt-crapass.dsagenci
                 tel_nrcpfcgc = STRING(STRING(tt-crapttl.nrcpfcgc,"99999999999"),
                                "xxx.xxx.xxx-xx")
                 tel_dstipcta = CAPS(tt-crapass.dstipcta)
                 tel_dssitdct = tt-crapass.dssitdct
                 tel_dsgraupr = tt-crapttl.dsgraupr
                 tel_nrcpfstl = STRING(tt-crapass.nrcpfstl,"999,999,999,99")
                 tel_dspessoa = "FISICA"
                 tel_dsestcvl = tt-crapttl.dsestcvl
                 tel_idseqttl = tel_idseqttl
                 tel_cdsexotl = IF tt-crapttl.cdsexotl = 1 THEN "M" ELSE "F".

          IF NOT VALID-HANDLE(h-b1wgen0031) THEN
             RUN sistema/generico/procedures/b1wgen0031.p 
                 PERSISTENT SET h-b1wgen0031.
       
          RUN bloqueio_prova_vida IN h-b1wgen0031
                                 (INPUT glb_cdcooper,
                                  INPUT glb_cdagenci,
                                  INPUT 0, /*nrdcaixa*/
                                  INPUT glb_cdoperad,
                                  INPUT glb_nmdatela,
                                  INPUT 1, /*ayllos*/
                                  INPUT glb_dtmvtolt,
                                  INPUT tt-crapttl.nrdconta,
                                  INPUT tt-crapttl.idseqttl,
                                  INPUT-OUTPUT TABLE tt-mensagens-contas,
                                  OUTPUT TABLE tt-erro).

          IF RETURN-VALUE <> "OK" THEN
             DO:
                IF VALID-HANDLE(h-b1wgen0031) THEN
                    DELETE OBJECT h-b1wgen0031.
                RETURN "NOK".
        
             END.
          
          IF VALID-HANDLE(h-b1wgen0031) THEN
            DELETE OBJECT h-b1wgen0031.

       END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE exibe-mensagens-alerta:
    
    FOR EACH tt-mensagens-contas BY tt-mensagens-contas.nrsequen:

        MESSAGE tt-mensagens-contas.dsmensag.

        READKEY.

        IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
            NEXT.

    END.

    HIDE MESSAGE NO-PAUSE.

    RETURN "OK".

END PROCEDURE.


