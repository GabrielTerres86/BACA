/* .............................................................................

   Programa: Fontes/lanbdci.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Marco/2003.                       Ultima atualizacao: 24/04/2017

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de inclusao da tela LANBDC.

   Alteracoes: 18/12/2003 - Alterado para NAO permitir data de liberacao para
                            o dia 31/12 de qualquer ano (Edson).

               01/03/2004 - Alterado para NAO permitir a inclusao de novos
                            cheques quando o boletim ja estiver liberado 
                            (Edson).

               11/06/2004 - Reativar restricao de prazo minimo/maximo (Edson).

               08/07/2004 - Nao atualizar os campos de cheques superiores e
                            inferiores (Magui).
               
               28/07/2004 - Critica 759 para segundo e terceiro titular(Mirtes)
               
               24/09/2004 - Ajuste no controle do bordero liberado (Edson).
               
               02/12/2004 - Nao permitir desconto de cheques para associados
                            demitidos (Edson).

               13/12/2004 - Sera solicitado nro cheque qdo cmc7 for digitado
                            (Mirtes)

               16/05/2005 - Tratamento Conta Integracao(Mirtes)

               04/07/2005 - Alimentado campo cdcooper das tabelas crapcec,
                            crapcdb e craplau (Diego).

               09/12/2005 - Cheque salario nao existe mais (Magui).

               21/12/2005 - Ajuste na criacao do craplau para cheques da
                            Cooperativa (Edson).
    
               27/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando

               28/03/2007 - Tratamento para confirmar redesconto (David).
               
               24/09/2007 - Conversao de rotina ver_capital para BO 
                            (Sidnei/Precise)
                         
               20/05/2009 - Impedir a inclusao de cheque TB tpcheque = 2
                           (Fernando).
                           
               05/07/2010 - Comentada critica(759) referente segundo, terceiro
                            titular de pessoa juridica (Diego).
                            
               11/08/2010 - Inclusão de mensagem para a crítica 456 (já 
                            existe lançamento em outro lote), informando conta,
                            bordero, data de liberação, data do lcto. PAC e 
                            lote (Vitor).

               19/11/2010 - Tratamento para nao lancar cheques que ja estao 
                            em custodia (Henrique).
                            
               29/11/2011 - Alterações para não permitir data de liberação 
                            para último dia útil do Ano (Lucas).
                            
               19/03/2012 - Ajuste na data de liberacao (Ze).
               
               09/05/2012 - Cheques ja descontados e/ou processados nao podem
                            ser descontados novamente (Rafael).
                            
               06/06/2012 - Ajustes no redesconto de cheques (Rafael).
                              
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
               
               11/12/2013 - Inclusao de VALIDATE crapcec, crapcdb e craplau 
                                                                     (Carlos)
                                                                     
               10/01/2014 - Alterado de Agencia para PA. (Reinert)                                                                     
               
               23/09/2014 - Ajuste no bloqueio de desconto ref ao projeto
                            198-Viacon (Concredi e Credimilsul) (Rafael).

               11/11/2014 - Adicionado validação para não permitir a inclusão 
                            de cheques para os bancos 356, 409 e 479.
                            (Douglas - Chamado 183704).

               09/12/2014 - Adicionado validação para não permitir a inclusão 
                            de cheques para o banco 353. (Jaison - SD: 231108)
                            
               12/03/2015 - #202833 Validação adicionada para não permitir a
                            inclusao de cheque para o banco 231 (Carlos)
                            
               28/04/2015 - #267196 Validação adicionada para não permitir a
                            inclusao de cheque para o banco 012 (Carlos)
                            
               24/08/2015 - Incluir chamada da procedure verifica_fraude_chq_extern
                            Melhoria 217 (Lucas Ranghetti #320543)
                            
               09/09/2015 - Incrementado o numero do bordero e o numero de conta
                            na critica 811. SD 318503 (Kelvin).
                            
               20/06/2016 - Adicionado validacao para nao permitir o recebimento 
                            de cheques de bancos que nao participam da COMPE
                            (Douglas - Chamado 417655)
                            
               27/07/2016 - Alterado validacao para nao permitir o recebimento 
                            de cheques de bancos que nao participam da COMPE
                            Utilizar apenas BANCO e FLAG ativo
                            (Douglas - Chamado 417655)

			   19/12/2016 - Tratamento para Migracao Transulcred - bloquear 
                            liberacao de cheque (Daniel).

               29/12/2016 - Ajuste para utilizar leitura com find ao inves
						    de can-find
							(Adriano - SD 585728).

			   24/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
							(Adriano - P339).

............................................................................. */

{ includes/var_online.i }

{ includes/var_lanbdc.i }

{ includes/proc_conta_integracao.i }

{ sistema/generico/includes/var_internet.i }

DEF VAR h-b1wgen0001 AS HANDLE                                      NO-UNDO.

DEF BUFFER crabass FOR crapass.

DEF VAR tel_nro_cheque AS INTE FORMAT "zzz,zz9"                     NO-UNDO.
DEF VAR aux_nrctachq   AS DEC                                       NO-UNDO.

DEF VAR aux_dtminimo   AS DATE                                      NO-UNDO.
DEF VAR aux_qtddmini   AS INTEGER                                   NO-UNDO.
DEF VAR aux_nrcpfcgc1  LIKE crapttl.nrcpfcgc                        NO-UNDO.
DEF VAR aux_nrcpfcgc2  LIKE crapttl.nrcpfcgc                        NO-UNDO.

FORM
     SKIP(1)
     aux_confirma AT 4 LABEL "Deseja efetuar lancamento de redesconto?"
     WITH ROW 10 CENTERED SIZE 51 BY 5 SIDE-LABEL OVERLAY
     TITLE " Confirmar Redesconto " FRAME f_redescto.
     
FORM SKIP(1)
     tel_nro_cheque AT  10
     HELP "Entre com o nro cheque(Sem o Digito)."
     VALIDATE(tel_nro_cheque > 0,
              "380 - Numero errado.")
     SKIP(1)
     WITH ROW 14 CENTERED NO-LABEL
          OVERLAY TITLE "  Digite Nro do Cheque " FRAME f_lanchq.

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
       tel_vldifeci = 0

       tab_intracst = 1        /*  Tratamento comp. CREDIHERING  */
       tab_inchqcop = 1.
       
/*  Tabela de limite de desconto de cheques  */

FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND 
                   craptab.nmsistem = "CRED"        AND
                   craptab.tptabela = "USUARI"      AND
                   craptab.cdempres = 11            AND
                   craptab.cdacesso = "LIMDESCONT"  AND
                   craptab.tpregist = 0             NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     DO:
         glb_cdcritic = 55.
         RUN fontes/critic.p.
         BELL.
         glb_cdcritic = 0.
         MESSAGE glb_dscritic. 
         RETURN.
     END.

ASSIGN tab_qtrenova = INTEGER(SUBSTRING(craptab.dstextab,19,02))
       tab_qtdiamin = INTEGER(SUBSTRING(craptab.dstextab,22,03))
       tab_qtdiamax = INTEGER(SUBSTRING(craptab.dstextab,26,03)).

/*  Capa de lote  */

FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND 
                   craplot.dtmvtolt = tel_dtmvtolt   AND
                   craplot.cdagenci = tel_cdagenci   AND
                   craplot.cdbccxlt = tel_cdbccxlt   AND
                   craplot.nrdolote = tel_nrdolote   NO-LOCK NO-ERROR.
                   
IF   NOT AVAILABLE craplot   THEN
     RETURN.

IF   craplot.tplotmov <> 26   THEN
     RETURN.

ASSIGN aux_dtlibera = craplot.dtmvtopg
       tel_dtlibera = craplot.dtmvtopg.

FIND crapbdc WHERE crapbdc.cdcooper = glb_cdcooper     AND 
                   crapbdc.nrborder = craplot.cdhistor NO-LOCK NO-ERROR.
      
IF   NOT AVAILABLE crapbdc   THEN
     RETURN.
 
IF   crapbdc.insitbdc > 2   THEN 
     DO:
         MESSAGE "Boletim ja LIBERADO.".
         RETURN.
     END.

/*FIND crapass OF crapbdc NO-LOCK NO-ERROR.*/
FIND crapass WHERE crapass.cdcooper = glb_cdcooper     AND 
                   crapass.nrdconta = crapbdc.nrdconta NO-LOCK NO-ERROR.
                   
ASSIGN tel_nrcustod = crapass.nrdconta
       tel_nmcustod = crapass.nmprimtl
       tel_nrborder = craplot.cdhistor
       fav_nrcpfcgc = crapass.nrcpfcgc
       fav_inpessoa = crapass.inpessoa
       fav_nrdconta = crapass.nrdconta.

IF   crapass.dtdemiss <> ?   THEN
     DO:
         MESSAGE "Associado DEMITIDO, desconto nao permitido.".
         RETURN.
     END.

/*  Verifica se ha contrato de limite de desconto ativo  */
      
FIND FIRST craplim WHERE craplim.cdcooper = glb_cdcooper   AND 
                         craplim.nrdconta = tel_nrcustod   AND
                         craplim.tpctrlim = 2              AND
                         craplim.insitlim = 2              NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craplim   THEN
     DO:
         MESSAGE "Nao ha limite de desconto de cheques ATIVO.".
         RETURN.
     END.

DISPLAY tel_nrcustod tel_nmcustod tel_nrborder tel_dtlibera WITH FRAME f_lanbdc.

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
               UPDATE tel_dtlibera WITH FRAME f_lanbdc.
                
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

                  IF   aux_qtddmini = tab_qtdiamin THEN
                       LEAVE.
                       
               END.  /*  Fim do DO WHILE TRUE  */

               IF   tel_dtlibera <= aux_dtminimo THEN
                    DO:
                        MESSAGE "Prazo minimo excedido -" 
                                STRING(tab_qtdiamin) + " dias.".
                        NEXT.
                    END.

               IF   tel_dtlibera = ? THEN
                    DO:
                        glb_cdcritic = 13.
                        NEXT-PROMPT tel_dtlibera WITH FRAME f_lanbdc.
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
                        NEXT-PROMPT tel_dtlibera WITH FRAME f_lanbdc.
                        NEXT.
                    END.

               /*  Tratamento especifico para Incorporacao Concredi para Viacredi */
               IF   glb_cdcooper = 4           AND
                    tel_dtlibera >= 11/26/2014 AND
                    tel_dtlibera <= 12/04/2014 THEN
                    DO:
                        MESSAGE "Data de Liberacao Errada. Data Reservada para Incorporacao.".
                        NEXT-PROMPT tel_dtlibera WITH FRAME f_lanbdc.
                        NEXT.
                    END.

               /*  Tratamento especifico para Incorporacao Credimilsul para SCRCred */
               IF   glb_cdcooper = 15           AND
                    tel_dtlibera >= 11/26/2014 AND
                    tel_dtlibera <= 12/03/2014 THEN
                    DO:
                        MESSAGE "Data de Liberacao Errada. Data Reservada para Incorporacao.".
                        NEXT-PROMPT tel_dtlibera WITH FRAME f_lanbdc.
                        NEXT.
                    END.

			   /*  Tratamento especifico para Incorporacao Transulcred para Transpocred */
               IF   glb_cdcooper = 17          AND
                    tel_dtlibera >= 11/25/2016 AND
                    tel_dtlibera <= 12/30/2016 THEN
                    DO:
                        MESSAGE "Data de Liberacao Errado. Data Reservada para Incorporacao.".
                        NEXT-PROMPT tel_dtlibera WITH FRAME f_lanbdc.
                        NEXT.
                    END. 	


                    
               IF   tel_dtlibera >= (glb_dtmvtolt + tab_qtdiamax)   THEN
                    DO:
                        MESSAGE "Prazo maximo excedido -" 
                                STRING(tab_qtdiamax) + " dias.".
                        NEXT.
                    END.
                    
               IF   tel_dtlibera >= (craplim.dtinivig +
                                    (craplim.qtdiavig * tab_qtrenova))   THEN
                    DO:
                        MESSAGE "Prazo excede a vigencia maxima do contrato.".
                        NEXT.
                    END.
                    
              /*  Nao permite data de pagamento para último dia útil do Ano.  */

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
                       NEXT.
                   END.
               
               /*  Permite que o ultimo mes (do ano seguinte) do desconto seja
                   igual ao mes de origem  */
               
               aux_dtmvtolt = (glb_dtmvtolt + 365) - DAY(glb_dtmvtolt + 365).
           
               IF   tel_dtlibera > aux_dtmvtolt   THEN
                    DO:
                        glb_cdcritic = 13.
                        NEXT-PROMPT tel_dtlibera WITH FRAME f_lanbdc.
                        NEXT.
                    END.         
           END.
      ELSE
           DO:
               DISPLAY tel_dtlibera WITH FRAME f_lanbdc.
               
               UPDATE tel_nrcustod WITH FRAME f_lanbdc.
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
               DISPLAY tel_nmcustod WITH FRAME f_lanbdc.
               NEXT-PROMPT tel_nrcustod WITH FRAME f_lanbdc.
               NEXT.
           END.

      DO WHILE TRUE:
               
         /*  Verifica se o associado esta cadastrado  */
      
         FIND crapass WHERE  crapass.cdcooper = glb_cdcooper AND 
                             crapass.nrdconta = tel_nrcustod NO-LOCK NO-ERROR.
      
         IF   NOT AVAILABLE crapass   THEN
              DO:
                  glb_cdcritic = 9.
                  tel_nmcustod = "".
                  DISPLAY tel_nmcustod WITH FRAME f_lanbdc.
                  NEXT-PROMPT tel_nrcustod WITH FRAME f_lanbdc.
                  LEAVE.
              END.
               
         IF   crapass.dtelimin <> ? THEN
              DO:
                  glb_cdcritic = 410.
                  NEXT-PROMPT tel_nrcustod WITH FRAME f_lanbdc.
                  LEAVE.
              END.
               
         IF   CAN-DO("5,6,7,8",STRING(crapass.cdsitdtl))   THEN
              DO:
                  glb_cdcritic = 695.
                  NEXT-PROMPT tel_nrcustod WITH FRAME f_lanbdc.
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
                           NEXT-PROMPT tel_nrcustod WITH FRAME f_lanbdc.
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
                           
                           DISPLAY tel_nrcustod WITH FRAME f_lanbdc.
                           
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
                                              INPUT  "lanbdci",
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
    
         IF   glb_cdcritic > 0   THEN
              DO:
                  NEXT-PROMPT tel_nrcustod WITH FRAME f_lanbdc.
                  NEXT.
              END.
                   
         LEAVE.
                   
      END.  /*  Fim do DO WHILE TRUE  */
               
      IF   glb_cdcritic > 0   THEN
           NEXT.

      tel_nmcustod = crapass.nmprimtl.
      
      DISPLAY tel_nmcustod WITH FRAME f_lanbdc.
      
      CMC-7:

      /*  Pede o valor do cheque  */
                  
      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
         
         UPDATE tel_vlcheque WITH FRAME f_lanbdc
            
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
                     IF  glb_cdcritic = 456 THEN  
                        DO:
                            FIND crapcdb WHERE crapcdb.cdcooper = glb_cdcooper 
                                           AND crapcdb.cdcmpchq = tel_cdcmpchq 
                                           AND crapcdb.cdbanchq = tel_cdbanchq 
                                           AND crapcdb.cdagechq = tel_cdagechq 
                                           AND crapcdb.nrctachq = tel_nrctachq 
                                           AND crapcdb.nrcheque = tel_nrcheque 
                                           AND crapcdb.dtdevolu = ?
                                           NO-LOCK NO-ERROR.

                            IF AVAIL crapcdb THEN
                                MESSAGE "Conta:"              crapcdb.nrdconta SKIP
                                        "Bordero:"            crapcdb.nrborder SKIP
                                        "Data de Liberacao:"  crapcdb.dtlibera SKIP
                                        "Data de Lancamento:" crapcdb.dtmvtolt SKIP
                                        "PA:"                 crapcdb.cdagenci SKIP
                                        "Nr. Lote:"           crapcdb.nrdolote VIEW-AS ALERT-BOX.

                        END.   
                     ASSIGN glb_cdcritic = 0
                            tel_dsdocmc7 = "".
                 END.
      
            UPDATE tel_dsdocmc7 WITH FRAME f_lanbdc
         
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
                                 tel_nrcheque tel_nrddigc3 WITH FRAME f_lanbdc.
    
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
                          
                     /* Verificar se cheque está com fraude */
                     RUN verifica_fraude_chq_extern(INPUT glb_cdcooper,
                                                    INPUT glb_cdprogra,
                                                    INPUT tel_cdbanchq,
                                                    INPUT tel_nrcheque,
                                                    INPUT tel_nrctachq,
                                                    INPUT glb_cdoperad,
                                                    INPUT tel_cdagechq,
                                                   OUTPUT glb_dscritic).
                     IF  glb_dscritic <> "" THEN
                         DO:
                             MESSAGE glb_dscritic.
                             NEXT.
                         END.                             
                     
                 END.
            ELSE
                 DO:                  
                     ASSIGN tel_nro_cheque = 0.
                     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        
                        RUN fontes/cmc7.p (OUTPUT tel_dsdocmc7).
                        
                        IF   LENGTH(tel_dsdocmc7) <> 34   THEN
                             LEAVE.
                         
                        tel_nrcheque = 
                             INT(SUBSTRING(tel_dsdocmc7,14,06)) NO-ERROR.
    
                        UPDATE tel_nro_cheque WITH FRAME f_lanchq.
                        
                        HIDE FRAME f_lanchq.
                        
                        IF  tel_nro_cheque <> 
                            tel_nrcheque THEN
                            DO:
                              glb_cdcritic = 129.
                              RUN fontes/critic.p.
                              BELL.
                              MESSAGE glb_dscritic.
                              glb_cdcritic = 0.
                              NEXT.
                            END.           

                        DISPLAY tel_dsdocmc7 WITH FRAME f_lanbdc.
                     
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
                                    tel_nrcheque tel_nrddigc3 WITH FRAME f_lanbdc.

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
                            
                        /* Verificar se cheque está com fraude */
                       RUN verifica_fraude_chq_extern(INPUT glb_cdcooper,
                                                      INPUT glb_cdprogra,
                                                      INPUT tel_cdbanchq,
                                                      INPUT tel_nrcheque,
                                                      INPUT tel_nrctachq,
                                                      INPUT glb_cdoperad,
                                                      INPUT tel_cdagechq,
                                                     OUTPUT glb_dscritic).
                       IF  glb_dscritic <> "" THEN
                           DO:
                               MESSAGE glb_dscritic.
                               NEXT.
                           END.                             
                            
                        LEAVE.
                   
                     END.  /*  Fim do DO WHILE TRUE  */
                  
                     IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     
                          NEXT.
                 END.
            
            RUN ver_cheque.

            IF   glb_cdcritic > 0   THEN
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
            
            IF   CAN-FIND(crapcdb WHERE crapcdb.cdcooper = glb_cdcooper   AND 
                                        crapcdb.dtmvtolt = tel_dtmvtolt   AND
                                        crapcdb.cdagenci = tel_cdagenci   AND
                                        crapcdb.cdbccxlt = tel_cdbccxlt   AND
                                        crapcdb.nrdolote = tel_nrdolote   AND
                                        crapcdb.cdcmpchq = tel_cdcmpchq   AND
                                        crapcdb.cdbanchq = tel_cdbanchq   AND
                                        crapcdb.cdagechq = tel_cdagechq   AND
                                        crapcdb.nrctachq = tel_nrctachq   AND
                                        crapcdb.nrcheque = tel_nrcheque   AND
                                        crapcdb.dtdevolu = ?) THEN
                 DO:
                     glb_cdcritic = 92.
                     NEXT.
                 END.

		    FIND crapcdb WHERE crapcdb.cdcooper = glb_cdcooper   AND  
                                        crapcdb.cdagenci = tel_cdagenci   AND
                                        crapcdb.cdbccxlt = tel_cdbccxlt   AND
                                        crapcdb.cdcmpchq = tel_cdcmpchq   AND
                                        crapcdb.cdbanchq = tel_cdbanchq   AND
                                        crapcdb.cdagechq = tel_cdagechq   AND
                                        crapcdb.nrctachq = tel_nrctachq   AND
                                        crapcdb.nrcheque = tel_nrcheque   AND
                                        crapcdb.dtdevolu = ?              AND
                               crapcdb.insitchq = 0
							   NO-LOCK NO-ERROR.

            IF AVAIL crapcdb THEN
                 DO:
                     /* cheque para desconto */
                     MESSAGE "811 - cheque para desconto no bordero " + 
                         STRING(crapcdb.nrborder) + " da conta " + STRING(crapcdb.nrdconta).
                    /*glb_cdcritic = 811.*/
                     NEXT.
                 END.

            /*IF   CAN-FIND(crapcdb WHERE crapcdb.cdcooper = glb_cdcooper   AND 
                                        crapcdb.cdagenci = tel_cdagenci   AND
                                        crapcdb.cdbccxlt = tel_cdbccxlt   AND
                                        crapcdb.cdcmpchq = tel_cdcmpchq   AND
                                        crapcdb.cdbanchq = tel_cdbanchq   AND
                                        crapcdb.cdagechq = tel_cdagechq   AND
                                        crapcdb.nrctachq = tel_nrctachq   AND
                                        crapcdb.nrcheque = tel_nrcheque   AND
                                        crapcdb.dtdevolu = ?              AND
                              CAN-DO("2,3,4", STRING(crapcdb.insitchq)))  THEN
                DO:
                     /* cheque/documento ja processado */
                     glb_cdcritic = 670.
                     NEXT.
                END.*/

            RUN confirma_redesconto.

            IF   glb_cdcritic > 0   THEN
                 NEXT.

            IF   aux_nrdconta = 0   THEN
                 DO:
                     FIND crapcec WHERE crapcec.cdcooper = glb_cdcooper   AND 
                                        crapcec.cdcmpchq = tel_cdcmpchq   AND
                                        crapcec.cdbanchq = tel_cdbanchq   AND
                                        crapcec.cdagechq = tel_cdagechq   AND
                                        crapcec.nrctachq = tel_nrctachq   AND
                                        crapcec.nrdconta = 0 NO-LOCK NO-ERROR.
                                        
                     
                     IF   NOT AVAILABLE crapcec   THEN
                          DO:
                              RUN pede_dados.
                              
                              IF   glb_cdcritic > 0   THEN
                                   NEXT.
                          END.
                 END.
            ELSE
                 DO:
                     FIND crapcec WHERE crapcec.cdcooper = glb_cdcooper   AND 
                                        crapcec.cdcmpchq = tel_cdcmpchq   AND
                                        crapcec.cdbanchq = tel_cdbanchq   AND
                                        crapcec.cdagechq = tel_cdagechq   AND
                                        crapcec.nrctachq = tel_nrctachq   AND
                                        crapcec.nrdconta = aux_nrdconta
                                        NO-LOCK NO-ERROR.

                     IF   NOT AVAILABLE crapcec   THEN
                          DO TRANSACTION ON ERROR UNDO, RETURN:

                             CREATE crapcec.
                             ASSIGN crapcec.cdagechq = tel_cdagechq
                                    crapcec.cdbanchq = tel_cdbanchq
                                    crapcec.cdcmpchq = tel_cdcmpchq
                                    crapcec.nmcheque = aux_nmprimtl
                                    crapcec.nrcpfcgc = aux_nrcpfcgc
                                    crapcec.nrctachq = tel_nrctachq
                                    crapcec.nrdconta = aux_nrdconta
                                    crapcec.cdcooper = glb_cdcooper.
    
                             VALIDATE crapcec.

                          END.  /*  Fim da transacao  */
                 END.
                 
            IF   fav_nrcpfcgc = crapcec.nrcpfcgc   THEN
                 DO:
                     glb_cdcritic = 759.
                     NEXT.
                 END.
            
            IF   fav_inpessoa > 1   THEN
                 IF   SUBSTR(STRING(fav_nrcpfcgc,"99999999999999"),1,8) =
                      SUBSTR(STRING(crapcec.nrcpfcgc,"99999999999999"),1,8) THEN
                      DO:
                          glb_cdcritic = 759.
                          NEXT.
                      END.

			ASSIGN aux_nrcpfcgc1 = 0
			       aux_nrcpfcgc2 = 0.

            /* Verificar Segundo e Terceiro Titular */
            FIND crabass WHERE crabass.cdcooper = glb_cdcooper AND 
                               crabass.nrdconta = fav_nrdconta NO-LOCK NO-ERROR.

            IF  AVAIL crabass THEN
                DO:
				   FOR FIRST crapttl FIELDS(nrcpfcgc)
									 WHERE crapttl.cdcooper = crabass.cdcooper AND
									       crapttl.nrdconta = crabass.nrdconta AND
										   crapttl.idseqttl = 2
										   NO-LOCK:

					  ASSIGN aux_nrcpfcgc1 = crapttl.nrcpfcgc.

                END.

				   FOR FIRST crapttl FIELDS(nrcpfcgc)
									 WHERE crapttl.cdcooper = crabass.cdcooper AND
									       crapttl.nrdconta = crabass.nrdconta AND
										   crapttl.idseqttl = 3
										   NO-LOCK:

					  ASSIGN aux_nrcpfcgc2 = crapttl.nrcpfcgc.

                      END.

				   IF (aux_nrcpfcgc1 = crapcec.nrcpfcgc  OR
					   aux_nrcpfcgc2 = crapcec.nrcpfcgc) THEN 
					   DO:
						  glb_cdcritic = 759.
						  NEXT.
                 END.

				END. 


            /*-----------------------------*/
            
            LEAVE.
         
         END.  /*  Fim do DO WHILE TRUE  */
         
         IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     
              NEXT.

         DO TRANSACTION ON ERROR UNDO, LEAVE:
         
            DO WHILE TRUE:

               FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND 
                                  craplot.dtmvtolt = tel_dtmvtolt   AND
                                  craplot.cdagenci = tel_cdagenci   AND
                                  craplot.cdbccxlt = tel_cdbccxlt   AND
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
                        IF   craplot.tplotmov <> 26   THEN
                             glb_cdcritic = 100.
                    END.
                    
               LEAVE.
            
            END.   /*  Fim do DO WHILE TRUE  */
            
            IF   glb_cdcritic > 0   THEN
                 UNDO, NEXT CMC-7.

            IF tel_cdbanchq = 1  AND aux_nrdconta = 0 THEN
               ASSIGN aux_nrctachq = DECIMAL(SUBSTRING(tel_dsdocmc7,25,08)).
            ELSE 
               ASSIGN aux_nrctachq = tel_nrctachq.
            FIND crapcst WHERE crapcst.cdcooper = glb_cdcooper
                           AND crapcst.cdcmpchq = tel_cdcmpchq
                           AND crapcst.cdbanchq = tel_cdbanchq
                           AND crapcst.cdagechq = tel_cdagechq
                           AND crapcst.nrctachq = aux_nrctachq
                           AND crapcst.nrcheque = tel_nrcheque
                           AND crapcst.dtdevolu = ? NO-LOCK NO-ERROR.
                           
            IF AVAILABLE crapcst THEN
               DO:
                 glb_cdcritic = 757.
                 UNDO, NEXT CMC-7.
               END.
            
            DO WHILE TRUE:
                 
               FIND crapbdc WHERE crapbdc.cdcooper = glb_cdcooper AND 
                                  crapbdc.nrborder = craplot.cdhistor
                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      
               IF   NOT AVAILABLE crapbdc   THEN
                    IF   LOCKED crapbdc   THEN
                         DO:
                             PAUSE 2 NO-MESSAGE.
                             NEXT.
                         END.
                    ELSE
                         UNDO, RETURN.
               
               LEAVE.
                                  
            END.  /*  Fim do DO WHILE TRUE  */
                                  
            IF   crapbdc.insitbdc > 2   THEN                    /*  Liberado  */
                 DO:
                     MESSAGE "Boletim ja LIBERADO.".
                     RETURN.
                 END.
            ELSE
            IF   crapbdc.insitbdc = 2   THEN                   /*  Analisado  */
                 crapbdc.insitbdc = 1.                         /*  Em estudo  */
            
            CREATE crapcdb.
            ASSIGN crapcdb.cdagechq = tel_cdagechq
                   crapcdb.cdagenci = tel_cdagenci
                   crapcdb.cdbanchq = tel_cdbanchq
                   crapcdb.cdbccxlt = tel_cdbccxlt
                   crapcdb.cdcmpchq = tel_cdcmpchq
                   crapcdb.cdopedev = ""
                   crapcdb.cdoperad = glb_cdoperad
                   crapcdb.dsdocmc7 = tel_dsdocmc7
                   crapcdb.dtdevolu = ?
                   crapcdb.dtlibera = tel_dtlibera
                   crapcdb.dtmvtolt = tel_dtmvtolt
                   crapcdb.insitchq = 0
                   crapcdb.nrctrlim = craplim.nrctrlim
                   crapcdb.nrborder = crapbdc.nrborder
                   crapcdb.nrctachq = tel_nrctachq
                   crapcdb.nrdconta = tel_nrcustod
                   crapcdb.nrddigc1 = tel_nrddigc1
                   crapcdb.nrddigc2 = tel_nrddigc2
                   crapcdb.nrddigc3 = tel_nrddigc3
                   crapcdb.nrcheque = tel_nrcheque
                   crapcdb.nrdolote = tel_nrdolote
                   crapcdb.nrseqdig = craplot.nrseqdig + 1
                   crapcdb.vlcheque = tel_vlcheque
                   crapcdb.cdcooper = glb_cdcooper

                   crapcdb.nrcpfcgc = crapcec.nrcpfcgc
                   
                   crapcdb.inchqcop = IF aux_nrdconta > 0 
                                         THEN 1
                                         ELSE 0
                   
                   craplot.qtcompln = craplot.qtcompln + 1
                   craplot.vlcompdb = craplot.vlcompdb + tel_vlcheque
                   craplot.vlcompcr = craplot.vlcompcr + tel_vlcheque
                   craplot.nrseqdig = crapcdb.nrseqdig
                   
                   tel_qtinfoln = craplot.qtinfoln
                   tel_qtcompln = craplot.qtcompln
                   tel_vlinfodb = craplot.vlinfodb 
                   tel_vlcompdb = craplot.vlcompdb
                   tel_vlinfocr = craplot.vlinfocr  
                   tel_vlcompcr = craplot.vlcompcr
                   tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
                   tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
                   tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr

                   aux_nrdocmto = INT(STRING(crapcdb.nrcheque,"999999") +
                                      STRING(crapcdb.nrddigc3,"9")).

            VALIDATE crapcdb.

            IF   aux_nrdconta > 0   AND   
                 tab_inchqcop = 1   THEN              /*  Cheque CREDIHERING  */
                 DO:
                     CREATE craplau.

                     RUN fontes/digbbx.p (INPUT  crapcdb.nrctachq,
                                          OUTPUT craplau.nrdctitg,
                                          OUTPUT glb_stsnrcal).

                     ASSIGN craplau.dtmvtolt = crapcdb.dtmvtolt
                            craplau.cdagenci = crapcdb.cdagenci
                            craplau.cdbccxlt = crapcdb.cdbccxlt
                            craplau.nrdolote = crapcdb.nrdolote
                            craplau.nrdconta = aux_nrdconta
                            craplau.nrdocmto = aux_nrdocmto
                            craplau.vllanaut = crapcdb.vlcheque
                            craplau.cdhistor = 521
                            craplau.nrseqdig = crapcdb.nrseqdig
                            craplau.nrdctabb = crapcdb.nrctachq
                            craplau.cdbccxpg = 011
                            craplau.dtmvtopg = crapcdb.dtlibera    
                            craplau.tpdvalor = 1
                            craplau.insitlau = 1
                            craplau.cdcritic = 0
                            craplau.nrcrcard = 0
                            craplau.nrseqlan = 0
                            craplau.dtdebito = ?
                            craplau.cdcooper = glb_cdcooper
                            craplau.cdseqtel = STRING(crapcdb.dtmvtolt,
                                                      "99/99/9999") + " " +
                                               STRING(crapcdb.cdagenci,
                                                      "999") + " " +
                                               STRING(crapcdb.cdbccxlt,
                                                      "999") + " " +
                                               STRING(crapcdb.nrdolote,
                                                     "999999") + " " +
                                               STRING(crapcdb.cdcmpchq,
                                                      "999") + " " +
                                               STRING(crapcdb.cdbanchq,
                                                      "999") + " " +
                                               STRING(crapcdb.cdagechq,
                                                      "9999") + " " +
                                               STRING(crapcdb.nrctachq,
                                                      "99999999") + " " +
                                               STRING(crapcdb.nrcheque,
                                                      "999999").
                     VALIDATE craplau.

                 END.

         END.  /*  Fim da transacao  */
         
         IF   tel_qtdifeln = 0   AND
              tel_vldifecr = 0   AND
              tel_vldifedb = 0   THEN
              
              DO:
                  HIDE FRAME f_lanbdc NO-PAUSE. 
                  glb_nmdatela = "LOTE".
                  RETURN.                         /*  Volta ao lanbdc.p  */     
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
                tel_nrseqdig = crapcdb.nrseqdig + 1.
         
         DISPLAY tel_qtinfoln tel_qtcompln tel_vlinfodb
                 tel_vlcompdb tel_vlinfocr tel_vlcompcr
                 tel_qtdifeln tel_vldifedb tel_vldifecr
                 tel_cdcmpchq tel_cdbanchq tel_cdagechq 
                 tel_nrddigc1 tel_nrctachq tel_nrddigc2
                 tel_nrcheque tel_nrddigc3 tel_vlcheque 
                 tel_nrseqdig
                 WITH FRAME f_lanbdc.
         
         HIDE FRAME f_lanctos.

         DISPLAY tel_reganter[1] tel_reganter[2] WITH FRAME f_regant.

         /*  Forca pedir a data do cheque - Edson  */
         
         tel_dtlibera = ? . 
         
         RELEASE crapbdc.
           
         LEAVE.
      
      END.  /*  Fim do DO WHILE TRUE  */
      
      IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
           NEXT.

   END.  /*  Fim do DO WHILE TRUE  */
   
   LEAVE.

END.   /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

{ includes/proc_lanbdc.i }

/* .......................................................................... */

