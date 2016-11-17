/* .............................................................................

   Programa: Fontes/lancsti.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Abril/2000.                       Ultima atualizacao: 27/07/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de inclusao da tela lancst.

   Alteracoes: 24/10/2000 - Desmembrar a critica 95 conforme a situacao do
                            titular (Eduardo).

               17/11/2000 - Alterar nrdolote p/6 posicoes (Magui/Planner).

               08/06/2001 - Verifica parametros de custodia para a
                            conta favorecida (Edson).
                              
               11/07/2001 - Alterado para adaptar o nome de campo (Edson).
               
               12/09/2001 - Tratar a inclusao por valores de cheque Credihering,
                            Maiores e Menores (Junior).                

               25/09/2001 - Alterado layout da tela para mostrar cheques por
                            tipo Credi, maiores e menores (Junior).

               28/12/2001 - Alterado para tratar a rotina ver_capital (Edson).

               21/05/2002 - Permitir custodia qualquer dia (Magui).

               18/12/2003 - Alterado para NAO permitir data de liberacao para
                            o dia 31/12 de qualquer ano (Edson).

               14/01/2004 - Nao permitir custdia para contas a serem transfe-
                            ridas (Edson.

               30/08/2004 - Colocar prazo minimo para entrada de cheques
                            (Deborah).

               07/01/2005 - Alterar o limite maximo para 360 dias a contar
                            da data do movimento, cfe solicitacao do Sr.
                            Tavares (Edson).

               16/05/2005 - Tratamento Conta Integracao(Mirtes)

               18/05/2005 - Prazo minimo para VIACREDI de 5 dias corridos
                            (Edson).

               04/07/2005 - Alimentado campo cdcooper das tabelas crapcst
                            e craplau (Diego).
                            
               09/12/2005 - Cheque salario nao existe mais (Magui).

               21/12/2005 - Ajuste na criacao do craplau para cheques da
                            Cooperativa (Edson).
                            
               30/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
               
               07/11/2006 - Corrigido o tratamento de critica quando vier do
                            programa ver_capital (Evandro).

               28/03/2007 - Tratamento para confirmar redesconto (David).
               
               24/09/2007 - Conversao de rotina ver_capital para BO 
                            (Sidnei/Precise)
               
               20/05/2009 - Impedir a inclusao de cheque TB tpcheque = 2 
                            (Fernando).
                            
               02/03/2010 - Critica para banco e agencia na leitura do CMC-7 
                            (Elton).             
                            
               12/04/2011 - Nao permitir a inclusao de um cheque na custodia se 
                            o mesmo se encontrar em deconto de cheque
                            (Adriano).
                            
              29/11/2011 -  Alterações para não permitir data de liberação 
                            para último dia útil do Ano (Lucas).
                            
              19/03/2012 -  Ajuste na data de liberacao (Ze).
              
              20/08/2012 - Tratamento para Migracao Viacredi para AltoVale
                            - Bloqueio de Data na ult. semana do ano (Ze).
                            
              23/10/2012 - Tratamento para Migracao Alto Vale - alterar data
                           de 25/12 a 31/12 para 28/12 a 31/12 (Ze).
                           
              27/12/2012 - Bloquear Alteracoes para Migracao AltoVale (Ze).
              
              02/01/2013 - Ignorar registro de cooperado migrado ALTO VALE.
                           (Fabricio).
                           
               13/09/2013 - Tratamento para Migracao Viacredi - bloquear 
                            liberacao de cheque entre 27/12 a 06/01 (Ze).
                            
             13/11/2013 - Ajuste no bloqueio para Mig. Viacredi (Ze).
             
             12/12/2013 - VALIDATE crapcst e craplau (Carlos)
             
             23/09/2014 - Ajuste no bloqueio de custódia ref ao projeto
                          198-Viacon (Concredi e Credimilsul) (Rafael).

             11/11/2014 - Adicionado validação para não permitir a inclusão 
                          de cheques para os bancos 356, 409 e 479.
                          (Douglas - Chamado 183704).

             09/12/2014 - Adicionado validação para não permitir a inclusão 
                          de cheques para o banco 353. (Jaison - SD: 231108)
                          
             12/03/2015 - #202833 Validação adicionada para não permitir a
                          inclusão de cheques para o banco 231 (Carlos)
                          
             28/04/2015 - #267196 Validação adicionada para não permitir a
                          inclusao de cheque para o banco 012 (Carlos)

             20/06/2016 - Adicionado validacao para nao permitir o recebimento 
                          de cheques de bancos que nao participam da COMPE
                          (Douglas - Chamado 417655)
                          
             27/07/2016 - Alterado validacao para nao permitir o recebimento 
                          de cheques de bancos que nao participam da COMPE
                          Utilizar apenas BANCO e FLAG ativo
                          (Douglas - Chamado 417655)
............................................................................. */

{ includes/var_online.i }

{ includes/var_lancst.i }

{ includes/proc_conta_integracao.i }

{ sistema/generico/includes/var_internet.i }

DEF VAR h-b1wgen0001 AS HANDLE                                        NO-UNDO.
DEF VAR h-b1wgen0044 AS HANDLE                                        NO-UNDO.

DEF VAR aux_dtminimo AS DATE                                          NO-UNDO.
DEF VAR aux_qtddmini AS INTEGER                                       NO-UNDO.

FORM
     SKIP(1)
     aux_confirma AT 4 LABEL "Deseja efetuar lancamento de redesconto?"
     WITH ROW 10 CENTERED SIZE 51 BY 5 SIDE-LABEL OVERLAY
     TITLE " Confirmar Redesconto " FRAME f_redescto.

FUNCTION cooperado-migrado RETURNS LOGICAL (INPUT par_nrctaant AS INT):

    FIND FIRST craptco WHERE craptco.cdcopant = glb_cdcooper  AND
                             craptco.nrctaant = par_nrctaant  AND
                             craptco.tpctatrf = 1             AND
                             craptco.flgativo = TRUE
                             NO-LOCK NO-ERROR.

    IF AVAIL craptco THEN
        RETURN TRUE.
    ELSE
        RETURN FALSE.

END FUNCTION.
 
ASSIGN tel_nmcustod = ""
       tel_dtlibera = ?
       tel_nrcustod = 0
       tel_cdcmpchq = 0
       tel_cdbanchq = 0
       tel_cdagechq = 0
       tel_nrddigc1 = 0
       tel_nrctachq = 0
       tel_nrddigc2 = 0
       tel_nrcheque = 0
       tel_nrddigc3 = 0
       tel_vlcheque = 0
       tel_nrseqdig = 1
       tel_reganter = ""
       tel_qtdifecc = 0
       tel_qtdifecs = 0
       tel_qtdifeci = 0
       tel_vldifecc = 0
       tel_vldifecs = 0
       tel_vldifeci = 0.

FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND 
                   craplot.dtmvtolt = tel_dtmvtolt   AND
                   craplot.cdagenci = tel_cdagenci   AND
                   craplot.cdbccxlt = tel_cdbccxlt   AND
                   craplot.nrdolote = tel_nrdolote   NO-LOCK NO-ERROR.
                   
IF   NOT AVAILABLE craplot   THEN
     RETURN.


ASSIGN aux_dtlibera = craplot.dtmvtopg
       tel_dtlibera = craplot.dtmvtopg.

DISPLAY tel_nmcustod tel_dtlibera WITH FRAME f_lancst.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0 THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic. 
               glb_cdcritic = 0.
           END.

      IF   aux_dtlibera = ?   THEN
           DO:
               UPDATE tel_nrcustod tel_dtlibera WITH FRAME f_lancst.
               
               ASSIGN aux_dtminimo = glb_dtmvtolt
                      aux_qtddmini = 0.
      
               DO WHILE TRUE:
                 
                  aux_dtminimo = aux_dtminimo + 1.
                                           
                  IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtminimo))) OR
                       CAN-FIND(crapfer WHERE crapfer.cdcooper = 
                                                   glb_cdcooper   AND 
                                              crapfer.dtferiad =
                                                   aux_dtminimo) THEN
                       NEXT.
                  ELSE 
                       aux_qtddmini = aux_qtddmini + 1.

                  IF   aux_qtddmini = 2 THEN
                       LEAVE.
                       
               END.  /*  Fim do DO WHILE TRUE  */

               IF   tel_dtlibera =  ?                     OR
                    tel_dtlibera <= aux_dtminimo          OR
                    tel_dtlibera >  (glb_dtmvtolt + 1095) THEN
                    DO:
                        glb_cdcritic = 13.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        NEXT-PROMPT tel_dtlibera WITH FRAME f_lancst.
                        NEXT.
                    END.

               /*  Tratamento especifico para Migracao Viacredi para Viacredi */
               IF   glb_cdcooper = 2           AND
                    tel_dtlibera >= 12/27/2013 AND
                    tel_dtlibera <= 01/06/2014 AND
                   (tel_cdagenci = 02          OR
                    tel_cdagenci = 04          OR
                    tel_cdagenci = 06          OR
                    tel_cdagenci = 07          OR
                    tel_cdagenci = 11)         THEN
                    DO:
                        MESSAGE "Data de Liberacao Errado. Data Reservada para Migracao.".
                        NEXT-PROMPT tel_dtlibera WITH FRAME f_lancst.
                        NEXT.
                    END.

               /*  Tratamento especifico para Incorporacao Concredi para Viacredi */
               IF   glb_cdcooper = 4           AND
                    tel_dtlibera >= 11/26/2014 AND
                    tel_dtlibera <= 12/04/2014 THEN
                    DO:
                        MESSAGE "Data de Liberacao Errada. Data Reservada para Incorporacao.".
                        NEXT-PROMPT tel_dtlibera WITH FRAME f_lancst.
                        NEXT.
                    END.

               /*  Tratamento especifico para Incorporacao Credimilsul para SCRCred */
               IF   glb_cdcooper = 15           AND
                    tel_dtlibera >= 11/26/2014 AND
                    tel_dtlibera <= 12/03/2014 THEN
                    DO:
                        MESSAGE "Data de Liberacao Errada. Data Reservada para Incorporacao.".
                        NEXT-PROMPT tel_dtlibera WITH FRAME f_lancst.
                        NEXT.
                    END.

                    
              /*  Nao permite data de liberacao para último dia útil do Ano.  */
              RUN sistema/generico/procedures/b1wgen0015.p 
              PERSISTENT SET h-b1wgen0015.

              ASSIGN aux_dtdialim = DATE(12,31,YEAR(tel_dtlibera)).
              RUN retorna-dia-util IN h-b1wgen0015 (INPUT glb_cdcooper,
                                                    INPUT FALSE,  /* Feriado */
                                                    INPUT TRUE, /** Anterior **/
                                                    INPUT-OUTPUT aux_dtdialim).

              DELETE PROCEDURE h-b1wgen0015.

              IF   aux_dtdialim = tel_dtlibera THEN 
                   DO:
                       glb_cdcritic = 13.
                       RUN fontes/critic.p.
                       BELL.
                       MESSAGE glb_dscritic. 
                       NEXT.
                   END.

           END.
      ELSE
           DO:
               DISPLAY tel_dtlibera WITH FRAME f_lancst.
               
               UPDATE tel_nrcustod WITH FRAME f_lancst.
           END.
      
      /*  Tratamento especifico para Migracao Viacredi para Viacredi */
      IF   glb_cdcooper = 2           AND
           tel_dtlibera >= 12/27/2013 AND
           tel_dtlibera <= 01/06/2014 AND
          (tel_cdagenci = 02          OR
           tel_cdagenci = 04          OR
           tel_cdagenci = 06          OR
           tel_cdagenci = 07          OR
           tel_cdagenci = 11)         THEN
           DO:
               MESSAGE "Data de Liberacao Errado. Data Reservada para Migracao.". 
               NEXT.
           END.      
           
      /*  Tratamento especifico para Migracao Viacredi para AltoVale */
      IF cooperado-migrado(INPUT tel_nrcustod) THEN
      DO:
          MESSAGE "Conta migrada.".
          NEXT.
      END.
      
      glb_nrcalcul = tel_nrcustod.
                                    
      RUN fontes/digfun.p.
                  
      IF   NOT glb_stsnrcal   THEN
           DO:
               glb_cdcritic = 8.
               tel_nmcustod = "".
               DISPLAY tel_nmcustod WITH FRAME f_lancst.
               NEXT-PROMPT tel_nrcustod WITH FRAME f_lancst.
               NEXT.
           END.

      DO WHILE TRUE:
      
         /*  Verifica se o associado esta cadastrado  */
      
         FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND 
                            crapass.nrdconta = tel_nrcustod NO-LOCK NO-ERROR.
      
         IF   NOT AVAILABLE crapass   THEN
              DO:
                  glb_cdcritic = 9.
                  tel_nmcustod = "".
                  DISPLAY tel_nmcustod WITH FRAME f_lancst.
                  NEXT-PROMPT tel_nrcustod WITH FRAME f_lancst.
                  LEAVE.
              END.
               
         IF   crapass.dtelimin <> ? THEN
              DO:
                  glb_cdcritic = 410.
                  NEXT-PROMPT tel_nrcustod WITH FRAME f_lancst.
                  LEAVE.
              END.
               
         IF   CAN-DO("5,6,7,8",STRING(crapass.cdsitdtl))   THEN
              DO:
                  glb_cdcritic = 695.
                  NEXT-PROMPT tel_nrcustod WITH FRAME f_lancst.
                  LEAVE.
              END.
         
         IF   CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl))   THEN
              DO:
                  FIND FIRST craptrf WHERE
                             craptrf.cdcooper = glb_cdcooper     AND 
                             craptrf.nrdconta = crapass.nrdconta AND
                             craptrf.tptransa = 1 USE-INDEX craptrf1
                             NO-LOCK NO-ERROR.

                  IF   NOT AVAILABLE craptrf THEN
                       DO:
                           glb_cdcritic = 95.
                           NEXT-PROMPT tel_nrcustod WITH FRAME f_lancst.
                           LEAVE.
                       END.
                  ELSE
                       DO:
                           glb_cdcritic = 156.
                           RUN fontes/critic.p.

                           MESSAGE glb_dscritic 
                                   STRING(tel_nrcustod,"zzzz,zzz,9")
                                   "para o numero" 
                                   STRING(craptrf.nrsconta,"zzzz,zzz,9").

                           ASSIGN tel_nrcustod = craptrf.nrsconta
                                  glb_cdcritic = 0.
                           
                           DISPLAY tel_nrcustod WITH FRAME f_lancst.
                           
                           NEXT.
                       END.
              END.


         RUN sistema/generico/procedures/b1wgen0001.p
         PERSISTENT SET h-b1wgen0001.
      
         IF   VALID-HANDLE(h-b1wgen0001)   THEN
         DO:
              RUN ver_capital IN h-b1wgen0001(INPUT  glb_cdcooper,
                                              INPUT  tel_nrcustod,
                                              INPUT  0, /* cod-agencia */
                                              INPUT  0, /* nro-caixa   */
                                              0,        /* vllanmto */
                                              INPUT  glb_dtmvtolt,
                                              INPUT  "lancsti",
                                              INPUT  1, /* AYLLOS */
                                              OUTPUT TABLE tt-erro).
              /* Verifica se houve erro */
              FIND FIRST tt-erro NO-LOCK NO-ERROR.

              IF   AVAILABLE tt-erro   THEN
              DO:
                   ASSIGN glb_cdcritic = tt-erro.cdcritic
                          glb_dscricpl = tt-erro.dscritic.
              END.
              DELETE PROCEDURE h-b1wgen0001.
         END.
         /************************************/
                     
         IF   glb_cdcritic > 0      OR
              glb_dscricpl <> ""    THEN   
              DO:
                  NEXT-PROMPT tel_nrcustod WITH FRAME f_lancst.
                  LEAVE.
              END.
                   
         /*  Verifica se a conta foi ou sera transferida .............  */
                              
         FIND FIRST craptrf WHERE craptrf.cdcooper = glb_cdcooper   AND 
                                  craptrf.nrdconta = tel_nrcustod   AND
                                  craptrf.tptransa = 1 NO-LOCK NO-ERROR.
                                        
         IF   AVAILABLE craptrf   THEN
              DO:
                  IF   craptrf.insittrs = 1   THEN
                       MESSAGE "Conta transferida para" 
                                   TRIM(STRING(craptrf.nrsconta,"zzzz,zzz,9")).
                  ELSE
                       MESSAGE "Conta a ser transferida para"
                               TRIM(STRING(craptrf.nrsconta,"zzzz,zzz,9")).
                  
                  glb_cdcritic = 999.
                  
                  LEAVE.
              END.
         
         LEAVE.
                   
      END.  /*  Fim do DO WHILE TRUE  */
               
      IF   glb_cdcritic > 0   THEN
           NEXT.

      tel_nmcustod = crapass.nmprimtl.
      
      DISPLAY tel_nmcustod WITH FRAME f_lancst.
      
      /*  Verifica parametros de custodia para a conta favorecida  */
      
      FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                         craptab.nmsistem = "CRED"       AND
                         craptab.tptabela = "CUSTOD"     AND
                         craptab.cdempres = 00           AND
                         craptab.cdacesso = STRING(tel_nrcustod,
                                                   "9999999999")   AND
                         craptab.tpregist = 0 NO-LOCK NO-ERROR.

      IF   NOT AVAILABLE craptab   THEN
           ASSIGN tab_intracst = 1          /*  Tratamento comp. CREDIHERING  */
                  tab_inchqcop = 1.
      ELSE
           ASSIGN tab_intracst = INT(SUBSTR(craptab.dstextab,01,01))
                  tab_inchqcop = INT(SUBSTR(craptab.dstextab,03,01)).

      CMC-7:

      /*  Pede o valor do cheque  */
                  
      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
         
         UPDATE tel_vlcheque WITH FRAME f_lancst
            
         EDITING:
 
            READKEY.
                        
            IF   LASTKEY =  KEYCODE(".")   THEN
                 APPLY 44.
            ELSE
                 APPLY LASTKEY.
                           
         END.  /*  Fim do EDITING  */
            
         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
            IF   glb_cdcritic > 0 THEN
                 DO:
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     ASSIGN glb_cdcritic = 0
                            tel_dsdocmc7 = "".
                 END.
      
            UPDATE tel_dsdocmc7 WITH FRAME f_lancst
         
            EDITING:
            
               READKEY.
       
               IF   NOT CAN-DO(aux_lsvalido,KEYLABEL(LASTKEY))   THEN
                    DO:
                        glb_cdcritic = 666.
                        NEXT.
                    END.

               IF   KEYLABEL(LASTKEY) = "G"   THEN
                    APPLY KEYCODE(":").
               ELSE
                    APPLY LASTKEY.
    
            END.  /*  Fim do EDITING  */
         
            HIDE MESSAGE NO-PAUSE.
            
            IF   TRIM(tel_dsdocmc7) <> ""   THEN
                 DO:
                     IF   LENGTH(tel_dsdocmc7) <> 34            OR
                          SUBSTRING(tel_dsdocmc7,01,1) <> "<"   OR
                          SUBSTRING(tel_dsdocmc7,10,1) <> "<"   OR
                          SUBSTRING(tel_dsdocmc7,21,1) <> ">"   OR
                          SUBSTRING(tel_dsdocmc7,34,1) <> ":"   THEN
                          DO:
                              glb_cdcritic = 666.
                              NEXT.
                          END.
        
                     RUN fontes/dig_cmc7.p (INPUT  tel_dsdocmc7,
                                            OUTPUT glb_nrcalcul,
                                            OUTPUT aux_lsdigctr).
                   
                     IF   glb_nrcalcul > 0   THEN
                          DO:
                              glb_cdcritic = 666.
                              NEXT.
                          END.

                     /* Não permitir a inclusão de cheques para os bancos 012, 231, 353, 356, 409 e 479 */
                     IF CAN-DO("012,231,353,356,409,479",SUBSTRING(tel_dsdocmc7,02,3)) THEN
                     DO:
                         /* Limpar os campos do cheque da tela, para que seja exibido a mensagem e não fique dados na tela */
                         ASSIGN tel_cdbanchq = 0
                                tel_cdagechq = 0
                                tel_cdcmpchq = 0
                                tel_nrcheque = 0
                                tel_nrctachq = 0
                                tel_nrddigc1 = 0
                                tel_nrddigc2 = 0
                                tel_nrddigc3 = 0.
                         
                         DISPLAY tel_cdcmpchq tel_cdbanchq tel_cdagechq 
                                 tel_nrddigc1 tel_nrctachq tel_nrddigc2 
                                 tel_nrcheque tel_nrddigc3 WITH FRAME f_lancst.

                         MESSAGE "Banco nao permitido para a operacao.".
                         NEXT.
                     END.

                     /* Buscar os dados da agencia do cheque */
                     FIND FIRST crapagb WHERE crapagb.cddbanco = INT(SUBSTRING(tel_dsdocmc7,2,3))
                                          AND crapagb.cdsitagb = "S"
                                        NO-LOCK NO-ERROR.
                     IF NOT AVAILABLE crapagb THEN
                     DO:
                         /* Se nao existir agencia com a flag ativa igual a "S" ela nao participa da COMPE
                            por isso rejeitamos o cheque */
                         ASSIGN glb_cdcritic = 956.
                         NEXT.
                     END.

                     RUN mostra_dados.
                   
                     IF   glb_cdcritic > 0   THEN
                          NEXT.
                 END.
            ELSE
                 DO:
                     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                  
                        RUN fontes/cmc7.p (OUTPUT tel_dsdocmc7).
                        
                        IF   LENGTH(tel_dsdocmc7) <> 34   THEN
                             LEAVE.
                         
                        DISPLAY tel_dsdocmc7 WITH FRAME f_lancst.
                     
                        /* Não permitir a inclusão de cheques para os bancos 012, 231, 353, 356, 409 e 479 */
                        IF CAN-DO("012,231,353,356,409,479",SUBSTRING(tel_dsdocmc7,02,3)) THEN
                        DO:
                            /* Limpar os campos do cheque da tela, para que seja exibido a mensagem e não fique dados na tela */
                            ASSIGN tel_cdbanchq = 0
                                   tel_cdagechq = 0
                                   tel_cdcmpchq = 0
                                   tel_nrcheque = 0
                                   tel_nrctachq = 0
                                   tel_nrddigc1 = 0
                                   tel_nrddigc2 = 0
                                   tel_nrddigc3 = 0.
                            
                            DISPLAY tel_cdcmpchq tel_cdbanchq tel_cdagechq 
                                    tel_nrddigc1 tel_nrctachq tel_nrddigc2 
                                    tel_nrcheque tel_nrddigc3 WITH FRAME f_lancst.

                            MESSAGE "Banco nao permitido para a operacao.".
                            NEXT.
                        END.
                        
                        /* Buscar os dados da agencia do cheque */
                        FIND FIRST crapagb WHERE crapagb.cddbanco = INT(SUBSTRING(tel_dsdocmc7,2,3))
                                             AND crapagb.cdsitagb = "S"
                                           NO-LOCK NO-ERROR.
                        IF NOT AVAILABLE crapagb THEN
                        DO:
                            /* Se nao existir agencia com a flag ativa igual a "S" ela nao participa da COMPE
                               por isso rejeitamos o cheque */
                            ASSIGN glb_cdcritic = 956.
                            NEXT.
                        END.

                        RUN mostra_dados.
                        
                        IF   glb_cdcritic > 0   THEN
                             NEXT.

                        LEAVE.
                   
                     END.  /*  Fim do DO WHILE TRUE  */
                  
                     IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     
                          NEXT.
                 END.

            RUN ver_cheque.

            IF   glb_cdcritic > 0   THEN
                 NEXT.

            /* Instanciar a BO que fara validacao do Banco e Agencia */
            RUN sistema/generico/procedures/b1wgen0044.p 
                                 PERSISTENT SET h-b1wgen0044.

            IF  VALID-HANDLE(h-b1wgen0044)  THEN
                DO:
                    RUN valida_banco_agencia IN h-b1wgen0044                 
                                     (INPUT  INT(SUBSTRING(tel_dsdocmc7,02,3)), 
                                      INPUT  INT(SUBSTRING(tel_dsdocmc7,05,4)), 
                                      OUTPUT TABLE tt-erro).

                    /* Verifica se houve erro */
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.

                    IF   AVAILABLE tt-erro   THEN
                         DO:
                             ASSIGN  glb_cdcritic = tt-erro.cdcritic
                                     glb_dscricpl = tt-erro.dscritic.
                         END.
              
                    /* Remover a instancia da b1wgen0044 da memoria */
                    DELETE PROCEDURE h-b1wgen0044.  
                END.     
            ELSE
                DO:
                    MESSAGE "Handle invalido para h-b1wgen0044.".
                    NEXT.
                END.

            IF  glb_cdcritic > 0   OR
                glb_dscricpl <> "" THEN
                NEXT.

            FIND crapfdc WHERE crapfdc.cdcooper = glb_cdcooper AND
                               crapfdc.cdbanchq = tel_cdbanchq AND
                               crapfdc.cdagechq = tel_cdagechq AND
                               crapfdc.nrctachq = tel_nrctachq AND
                               crapfdc.nrcheque = tel_nrcheque NO-LOCK 
                               NO-ERROR.

            IF   AVAILABLE crapfdc   THEN
                 IF   crapfdc.tpcheque = 2  THEN
                      DO:
                         MESSAGE "Nao e permitida a inclusao de cheque TB.".
                         NEXT.
                      END.
      
            IF   CAN-FIND(crapcst WHERE crapcst.cdcooper = glb_cdcooper   AND 
                                        crapcst.dtmvtolt = tel_dtmvtolt   AND
                                        crapcst.cdagenci = tel_cdagenci   AND
                                        crapcst.cdbccxlt = tel_cdbccxlt   AND
                                        crapcst.nrdolote = tel_nrdolote   AND
                                        crapcst.cdcmpchq = tel_cdcmpchq   AND
                                        crapcst.cdbanchq = tel_cdbanchq   AND
                                        crapcst.cdagechq = tel_cdagechq   AND
                                        crapcst.nrctachq = tel_nrctachq   AND
                                        crapcst.nrcheque = tel_nrcheque)  THEN
                 DO:
                     glb_cdcritic = 92.
                     NEXT.
                 END.

            RUN confirma_redesconto.

            IF   glb_cdcritic > 0   THEN
                 NEXT.

            LEAVE.
         
         END.  /*  Fim do DO WHILE TRUE  */
         
         IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     
              NEXT.
         
         DO TRANSACTION ON ERROR UNDO, LEAVE:
         
            DO WHILE TRUE:

               FIND craplot WHERE craplot.cdcooper = glb_cdcooper AND 
                                  craplot.dtmvtolt = tel_dtmvtolt AND
                                  craplot.cdagenci = tel_cdagenci AND
                                  craplot.cdbccxlt = tel_cdbccxlt AND
                                  craplot.nrdolote = tel_nrdolote
                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

               IF   NOT AVAILABLE craplot   THEN
                    IF   LOCKED craplot   THEN
                         DO:
                             PAUSE 1 NO-MESSAGE.
                             NEXT.
                         END.
                    ELSE
                         glb_cdcritic = 60.
               ELSE
                    DO:   
                        IF   craplot.tplotmov <> 19   THEN
                             glb_cdcritic = 100.
                    END.
                    
               LEAVE.
            
            END.   /*  Fim do DO WHILE TRUE  */
            
            IF   glb_cdcritic > 0   THEN
                 UNDO, NEXT CMC-7.


            FIND crapcdb WHERE crapcdb.cdcooper = glb_cdcooper AND
                               crapcdb.cdcmpchq = tel_cdcmpchq AND
                               crapcdb.cdbanchq = tel_cdbanchq AND
                               crapcdb.cdagechq = tel_cdagechq AND
                               crapcdb.nrctachq = tel_nrctachq AND
                               crapcdb.nrcheque = tel_nrcheque AND
                               crapcdb.dtdevolu = ?            AND
                              (crapcdb.insitchq = 0            OR
                               crapcdb.insitchq = 2)
                               NO-LOCK NO-ERROR.

            IF AVAIL crapcdb THEN
               DO:
                  PAUSE 2 NO-MESSAGE.
                  MESSAGE "Cheque em desconto.".
                  NEXT.

               END.

          
            CREATE crapcst.
            ASSIGN crapcst.cdagechq = tel_cdagechq
                   crapcst.cdagenci = tel_cdagenci
                   crapcst.cdbanchq = tel_cdbanchq
                   crapcst.cdbccxlt = tel_cdbccxlt
                   crapcst.cdcmpchq = tel_cdcmpchq
                   crapcst.cdopedev = ""
                   crapcst.cdoperad = glb_cdoperad
                   crapcst.dsdocmc7 = tel_dsdocmc7
                   crapcst.dtdevolu = ?
                   crapcst.dtlibera = tel_dtlibera
                   crapcst.dtmvtolt = tel_dtmvtolt
                   crapcst.insitchq = 0
                   crapcst.nrctachq = tel_nrctachq
                   crapcst.nrdconta = tel_nrcustod
                   crapcst.nrddigc1 = tel_nrddigc1
                   crapcst.nrddigc2 = tel_nrddigc2
                   crapcst.nrddigc3 = tel_nrddigc3
                   crapcst.nrcheque = tel_nrcheque
                   crapcst.nrdolote = tel_nrdolote
                   crapcst.nrseqdig = craplot.nrseqdig + 1
                   crapcst.vlcheque = tel_vlcheque
                   crapcst.cdcooper = glb_cdcooper
                   
                   crapcst.inchqcop = IF aux_nrdconta > 0 
                                         THEN 1
                                         ELSE 0
                   
                   craplot.qtcompln = craplot.qtcompln + 1
                   craplot.vlcompdb = craplot.vlcompdb + tel_vlcheque
                   craplot.vlcompcr = craplot.vlcompcr + tel_vlcheque
                   craplot.nrseqdig = crapcst.nrseqdig
                   
                   tel_qtinfoln = craplot.qtinfoln
                   tel_qtcompln = craplot.qtcompln
                   tel_vlinfodb = craplot.vlinfodb 
                   tel_vlcompdb = craplot.vlcompdb
                   tel_vlinfocr = craplot.vlinfocr  
                   tel_vlcompcr = craplot.vlcompcr
                   tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
                   tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
                   tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr

                   tel_qtinfocc = craplot.qtinfocc
                   tel_vlinfocc = craplot.vlinfocc
                   tel_qtcompcc = craplot.qtcompcc
                   tel_vlcompcc = craplot.vlcompcc
                   tel_qtdifecc = craplot.qtinfocc - craplot.qtcompcc
                   tel_vldifecc = craplot.vlinfocc - craplot.vlcompcc

                   tel_qtinfoci = craplot.qtinfoci
                   tel_vlinfoci = craplot.vlinfoci
                   tel_qtcompci = craplot.qtcompci
                   tel_vlcompci = craplot.vlcompci
                   tel_qtdifeci = craplot.qtinfoci - craplot.qtcompci
                   tel_vldifeci = craplot.vlinfoci - craplot.vlcompci
          
                   tel_qtinfocs = craplot.qtinfocs
                   tel_vlinfocs = craplot.vlinfocs
                   tel_qtcompcs = craplot.qtcompcs
                   tel_vlcompcs = craplot.vlcompcs
                   tel_qtdifecs = craplot.qtinfocs - craplot.qtcompcs
                   tel_vldifecs = craplot.vlinfocs - craplot.vlcompcs

                   aux_nrdocmto = INT(STRING(crapcst.nrcheque,"999999") +
                                      STRING(crapcst.nrddigc3,"9")).

            VALIDATE crapcst.

            /*  Le tabela com o valor dos cheques maiores  */

            FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND 
                               craptab.nmsistem = "CRED"         AND
                               craptab.tptabela = "USUARI"       AND
                               craptab.cdempres = 11             AND
                               craptab.cdacesso = "MAIORESCHQ"   AND
                               craptab.tpregist = 1 NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE craptab   THEN
                 tab_vlchqmai = 1.
            ELSE
                 tab_vlchqmai = DECIMAL(SUBSTRING(craptab.dstextab,01,15)).

            IF   crapcst.inchqcop = 1 THEN
                 ASSIGN craplot.qtcompcc = craplot.qtcompcc + 1
                        craplot.vlcompcc = craplot.vlcompcc + tel_vlcheque.
            ELSE
                   IF   tel_vlcheque < tab_vlchqmai THEN
                        ASSIGN craplot.qtcompci = craplot.qtcompci + 1
                               craplot.vlcompci = craplot.vlcompci +
                                                  tel_vlcheque.
                   ELSE
                        ASSIGN craplot.qtcompcs = craplot.qtcompcs + 1
                               craplot.vlcompcs = craplot.vlcompcs + 
                                                  tel_vlcheque.
            
            ASSIGN tel_qtdifecc = craplot.qtcompcc - craplot.qtinfocc
                   tel_vldifecc = craplot.vlcompcc - craplot.vlinfocc
                   tel_qtdifeci = craplot.qtcompci - craplot.qtinfoci
                   tel_vldifeci = craplot.vlcompci - craplot.vlinfoci
                   tel_qtdifecs = craplot.qtcompcs - craplot.qtinfocs
                   tel_vldifecs = craplot.vlcompcs - craplot.vlinfocs
                   tel_qtcompcc = craplot.qtcompcc
                   tel_vlcompcc = craplot.vlcompcc
                   tel_qtcompcs = craplot.qtcompcs
                   tel_vlcompcs = craplot.vlcompcs
                   tel_qtcompci = craplot.qtcompci
                   tel_vlcompci = craplot.vlcompci.

            IF   aux_nrdconta > 0   AND   
                 tab_inchqcop = 1   THEN              /*  Cheque CREDIHERING  */
                 DO:
                     CREATE craplau.

                     RUN fontes/digbbx.p (INPUT  crapcst.nrctachq,
                                          OUTPUT craplau.nrdctitg,
                                          OUTPUT glb_stsnrcal).

                     ASSIGN craplau.dtmvtolt = crapcst.dtmvtolt
                            craplau.cdagenci = crapcst.cdagenci
                            craplau.cdbccxlt = crapcst.cdbccxlt
                            craplau.nrdolote = crapcst.nrdolote
                            craplau.nrdconta = aux_nrdconta
                            craplau.nrdocmto = aux_nrdocmto
                            craplau.vllanaut = crapcst.vlcheque
                            craplau.cdhistor = 21
                            craplau.nrseqdig = crapcst.nrseqdig
                            craplau.nrdctabb = crapcst.nrctachq

                            craplau.cdbccxpg = 011
                            craplau.dtmvtopg = crapcst.dtlibera    
                            craplau.tpdvalor = 1
                            craplau.insitlau = 1
                            craplau.cdcritic = 0
                            craplau.nrcrcard = 0
                            craplau.nrseqlan = 0
                            craplau.dtdebito = ?
                            craplau.cdcooper = glb_cdcooper
                            craplau.cdseqtel = STRING(crapcst.dtmvtolt,
                                                      "99/99/9999") + " " +
                                               STRING(crapcst.cdagenci,
                                                      "999") + " " +
                                               STRING(crapcst.cdbccxlt,
                                                      "999") + " " +
                                               STRING(crapcst.nrdolote,
                                                     "999999") + " " +
                                               STRING(crapcst.cdcmpchq,
                                                      "999") + " " +
                                               STRING(crapcst.cdbanchq,
                                                      "999") + " " +
                                               STRING(crapcst.cdagechq,
                                                      "9999") + " " +
                                               STRING(crapcst.nrctachq,
                                                      "99999999") + " " +
                                               STRING(crapcst.nrcheque,
                                                      "999999").
                     VALIDATE craplau.

                 END.

         END.  /*  Fim da transacao  */
         
         IF   tel_qtdifecc = 0   AND
              tel_vldifecc = 0   AND
              tel_qtdifeci = 0   AND
              tel_vldifeci = 0   AND
              tel_qtdifecs = 0   AND
              tel_vldifecs = 0   THEN
              
              DO:
                  HIDE FRAME f_lancst NO-PAUSE. 
                  glb_nmdatela = "LOTE".
                  RETURN.                         /*  Volta ao lancst.p  */     
              END.                 

         ASSIGN tel_reganter[2] = tel_reganter[1]

                tel_reganter[1] = STRING(tel_cdcmpchq,"zz9") + " " +
                                  STRING(tel_cdbanchq,"zz9") + " " +
                                  STRING(tel_cdagechq,"zzz9") + "  " +
                                  STRING(tel_nrddigc1,"9") + " " +
                                  STRING(tel_nrctachq,"zzz,zzz,zzz,9") + "  " +
                                  STRING(tel_nrddigc2,"9") + " " +
                                  STRING(tel_nrcheque,"zzz,zz9") + "  " +
                                  STRING(tel_nrddigc3,"9") + "    " +
                                  STRING(tel_vlcheque,"zzz,zzz,zzz,zz9.99") +
                                  "   " +
                                  STRING(tel_nrseqdig,"zz,zz9")

                tel_dsdocmc7 = ""
                tel_cdcmpchq = 0
                tel_cdbanchq = 0 
                tel_cdagechq = 0
                tel_nrddigc1 = 0
                tel_nrctachq = 0
                tel_nrddigc2 = 0
                tel_nrcheque = 0
                tel_nrddigc3 = 0
                tel_vlcheque = 0
                tel_nrseqdig = crapcst.nrseqdig + 1.

         DISPLAY tel_qtinfocc tel_vlinfocc tel_qtcompcc
                 tel_vlcompcc tel_qtdifecc tel_vldifecc
                 tel_qtinfoci tel_vlinfoci tel_qtcompci
                 tel_vlcompci tel_qtdifeci tel_vldifeci
                 tel_qtinfocs tel_vlinfocs tel_qtcompcs
                 tel_vlcompcs tel_qtdifecs tel_vldifecs
                 tel_cdcmpchq tel_cdbanchq tel_cdagechq
                 tel_nrddigc1 tel_nrctachq tel_nrddigc2
                 tel_nrcheque tel_nrddigc3 tel_vlcheque
                 tel_nrseqdig
                 WITH FRAME f_lancst.

         
         HIDE FRAME f_lanctos.

         DISPLAY tel_reganter[1] tel_reganter[2] WITH FRAME f_regant.

      END.  /*  Fim do DO WHILE TRUE  */
      
      IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
           NEXT.

   END.  /*  Fim do DO WHILE TRUE  */
   
   LEAVE.

END.   /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

{ includes/proc_lancst.i }

/* .......................................................................... */

