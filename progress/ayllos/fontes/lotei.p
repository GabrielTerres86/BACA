/* .............................................................................

   Programa: Fontes/lotei.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/91.                    Ultima atualizacao: 04/08/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de inclusao da tela LOTE.

   Alteracoes: 08/06/94 - No tipo de lote 6 permitir que a data do debito seja
                          no maximo 60 dias a partir da data atual.

               23/08/94 - Alterado para nao deixar criar capa de lote com os
                          numeros 7200 e 8006 (Edson).

               28/10/94 - Alterado para nao permitir inclusao dos lotes 8451 e
                          8452 (Deborah).

               30/11/94 - Alterado para incluir tipo de lote 10 e 11 e nao per-
                          mitir a inclusao dos lotes 8380, 8381 e 8390 (Odair).

               23/03/95 - Alterado para nao permitir a inclusao do lote 8007
                          (reservado ao sistema) (Deborah).

               27/03/95 - Alterado para nao permitir a inclusao dos lote 8474 e
                          8382 - reservados para saque de RDCA (Deborah).

               29/05/95 - Alterado para tratar a data do debito somente no tipo
                          de lote 6 (Deborah).

               18/07/95 - Alterado para nao permitir lotes tipo 12 para data
                          superior a 30 dias (Deborah).

               15/12/95 - Incluir tratamento para tipo de lote 13, lancamento de
                          faturas no caixa (Odair).

               18/03/96 - Incluir tratamento de lotes 14 (Odair).

               16/08/96 - Alterado tratamento do tipo de lote 13 para total a
                          credito (Deborah).

               29/08/96 - Alterado para tratar a data de pagamento do tipo de
                          lote 13 (Odair).

               09/10/96 - Alterado para reservar lotes 6600 a 6609 para o siste-
                          ma (Odair).

               30/10/96 - Alterado para reservar lote 8453 (Odair).

               11/11/96 - Alterado para reservar lotes 8454 8455 8456 8457
                          (Odair).

               09/12/96 - Tratar tplotmov = 15 Seguros (Odair).

               17/01/97 - Reservar lote 8461 Abono CPMF (Odair).

               24/02/97 - Reservar lote 8458 Debito de plano de saude Bradesco
                          em conta corrente (Odair).

               13/03/97 - Impedir os lotes de RDC (tipo 9) (Deborah).

               14/03/97 - Tratar tplotmov = 16 Cartao de Credito (Odair).

               10/04/97 - Tratar tplotmov = 17 Debitos de cartao (Odair).

               07/05/97 - Tipo 17 somente aceitar historico 197 (Odair)

               22/05/97 - Alterado para permitir os numeros 4150 e 4152 como
                          lotes de seguro casa e auto respectivamente (Edson).

               26/05/97 - Alterado para reservar o lote 8462 para o sistema
                          (Deborah).

               28/05/97 - Alterado para reservar o lote 8475 para o sistema
                          (Edson).

               20/06/97 - Tratar cartao com data do debito (Odair)

               08/10/97 - Banco caixa 600 so pode ser tipo de lote 6 (Odair).

               24/11/97 - Incluir tplotmov 18 e inibir lote 8463 (Odair).

               02/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               29/06/98 - Alterado para reservar o lote 8476 para o sistema
                          (Edson).

               06/07/98 - Incluir historico 288 para lanfat (13) e aumentar
                          faixa para integracoes de convenios (Odair)

               25/08/98 - Incluir historico 30 para lanfat (Odair).

               03/09/98 - Alteracoes no tipo de lote 17 (Deborah).

               09/09/98 - Tratar historico 30 para data de vencimento (Odair)
               
               18/09/98 - Limitar tipo do lote 17 ate numero 6849 (Deborah).
               
               05/10/98 - Tratar historico 29 para tipo 13 (Odair).

               19/11/98 - Tratar alteracao de historicos para tipo 13 (Odair)
               
               02/12/98 - Reservar lotes para o sistema (Deborah).

               20/04/1999 - Testar agencia e banco/caixa na pesquisa dos
                            lotes antecipados. (Deborah).

               13/05/1999 - Desabilitar tplotmov = 7 limite de credito (Odair)
                            Exigir lote 4153 para tipo de lote 15 - seguro vida
                            (Deborah).

               02/08/1999 - Reservar o lote 4154 para o sistema (Deborah).
               
               21/09/1999 - Tratar historico 348 Casan Caixa (Odair)

               07/04/2000 - Tratar tipo de lote 19 - cheques em custodia 
                            (Edson).

               27/04/2000 - Tratar tipo de lote 20 - titulos compensaveis
                            (Edson).

               01/09/2000 - Quando o historico contabilizar por caixa testar 
                            se existe a conta no crapage (Deborah).

               05/01/2001 - Tratar tipo de lote 21 (Deborah).

               06/03/2001 - Incluir tratamento do boletim caixa (Margarete).

               12/03/2001 - Reservar tipo de lote 22 - Boletim de Caixa (Edson).

               30/03/2001 - Bloquear hist. 309 (TIM) pelas faturas. Este hist.
                            somente LANTIT. (Eduardo).
  
               05/04/2001 - Acrescentar o historico 374 (Embratel) na LANFAT.
                            (Ze Eduardo).

               24/04/2001 - Tratar tipo de lote 23 - CHEQUES ACOLHIDOS (Edson).
               
               18/06/2001 - Aumentar o prazo da custodia para 2 anos (Deborah).
               
               01/08/2001 - Nao permitir lote 8361 (Margarete).
               
               05/09/2001 - Incluir protocolo de custodia para tipo do 
                            lote = 19 (Junior).                     

               23/04/2002 - Permitir custodia em qualquer dia (Margarete).

               13/09/2002 - Incluir tipo de lote para DOC e TED (Margarete).
               
               14/10/2002 - Reservar o 4650 - Devolucao de Cheques (Ze Eduardo)
               
               23/03/2003 - Reservar faixa de 7020 a 7030 para Caixa Economica
                            - compensacao CONCREDI (Junior).

               24/03/2003 - Tratar a tela LANBDC - Tipo de lote 26 (Edson).

               25/04/2003 - Mostrar tela com os tipos de lote (Edson).

               18/12/2003 - Alterado para NAO permitir data de liberacao para
                            o dia 31/12 de qualquer ano na custodia e nos
                            debitos automaticos (Edson).

               09/01/2004 - Nao aceitar mais Embratel histor 374 (Margarete).
               
               12/01/2004 - Incluir a TIM como fatura (Ze Eduardo).

               14/01/2004 - Nao permitir lote de desconto de cheques com
                            conta transferida ou a ser transferida (Edson).

               10/02/2004 - Efetuado controle por PAC(tabelas horario 
                            compel/titulo) (Mirtes)

               17/06/2004 - Tratar prazo minimo de sociedade (ver_capital)
                            (Edson).

               30/08/2004 - Colocar prazo minimo para entrada da custodia 
                            (Deborah).

               17/09/2004 - Aceitar tplotmov29(CI).(Mirtes).
               
               09/02/2005 - Liberar a faixa de numeracao de lotes 
                            para a custodia de cheques (Edson).

               04/07/2005 - Alimentado campo cdcooper das tabelas craplot e
                            crapbdc (Diego).

               28/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
               
               23/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
               
               18/05/2007 - Incluido tipo de lote 9 "RDC" em substituicao ao
                            tipo de lote "APL" (Elton).
               
               07/08/2007 - Critica lancamentos PPR RDCA a partir de 2008
                            (Guilherme).
               
               24/09/2007 - Conversao de rotina ver_capital para BO 
                            (Sidnei/Precise)

               19/11/2007 - Comentada alteracao 2008 a pedido do Ivo (Magui).
               
               09/06/2008 - Incluído a chave de acesso (craphis.cdcooper =
                            glb_cdcooper) no "find" da tabela CRAPHIS. 
                            - Kbase IT Solutions - Eduardo Silva.
               
               24/06/2008 - Permitir custodia/debitos para 30/12/2008 (Magui).
               
               17/09/2008 - Alterada chave de acesso a tabela crapldc(Gabriel).
                          - Zoom de tipo de lote chamado por F7 (Guilherme).
                          - Alteracoes para desconto de titulos (Guilherme).
                          
               08/04/2010 - Incluir <F7> no campo do historico.
                            Retirar comentarios desnecessarios.
                            Retirar a inclusao do lote de seguro (Tipo 15)
                            (Gabriel).           
                            
               04/05/2010 - Retirar lote de poupança (Gabriel).   
               
               24/06/2010 - Nao permitir inclusao de nrdolote = 1537 , 
                            reservado para poupancas (Gabriel).          
                            
               16/11/2010 - Alteracao para atender ao Projeto de Truncagem (Ze)
               
               18/01/2011 - Limitar Qtd Chqs no lote - COMPE imagem (Guilherme)
               
               17/05/2011 - Nao permitir tipo de lote 23 LANCHQ (Magui).
               
               29/11/2011 - Alterações para não permitir data de liberação/pagamento 
                            para último dia útil do Ano, nos Tipos 12,17,19 (Lucas).
               
               17/10/2013 - Retirar crítica para lançamentos Tipo 18 sem valor de 
                            débtio informado (Rodrigo).
                            
               16/12/2013 - Inclusao de VALIDATE craplot e crapbdc (Carlos)
               
               24/03/2014 - Ajuste Oracle tratamento FIND LAST da tabela
                            crapbdc (Daniel).
                            
               11/12/2014 - Conversão da fn_sequence para procedure para não
                            gerar cursores abertos no Oracle. (Dionathan)
                            
               04/08/2016 - Remover condicao de cooperativa igual a Viacredi para 
                            validar os dois dias minimos para custodia de cheque
                            (Douglas - Chamado 457862)
                            
               20/09/2016 - Nao permitir tipos de lote 19, 26 e 27 LANCDC. Projeto 300 (Lombardi).
............................................................................. */

{ includes/var_online.i }

{ includes/var_lote.i }

{ sistema/generico/includes/var_internet.i }

{ sistema/generico/includes/var_oracle.i }

DEF VAR h-b1wgen0001 AS HANDLE                                       NO-UNDO.
DEF VAR h-b1wgen0015 AS HANDLE                                       NO-UNDO.


DEF    VAR     aux_dtdialim      AS DATE                             NO-UNDO.
DEF    VAR     cal_dtmvtopg      AS DATE                             NO-UNDO.
DEF    VAR     aux_dtminimo      AS DATE                             NO-UNDO.
DEF    VAR     aux_qtddmini      AS INTEGER                          NO-UNDO.
DEF    VAR     tab_qtrenova      AS DECIMAL                          NO-UNDO.

DEF    VAR     aux_nrsequen      AS INTE                             NO-UNDO.
           
/* Utilizada para calcular data de pagto de faturas do tplotmov 13 Odair */

IF   CAN-FIND(craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                            craplot.dtmvtolt = tel_dtmvtolt   AND
                            craplot.cdagenci = tel_cdagenci   AND
                            craplot.cdbccxlt = tel_cdbccxlt   AND
                            craplot.nrdolote = tel_nrdolote)  THEN
     DO:
         glb_cdcritic = 59.
         NEXT.
     END.

/* Lote reservado para a poupanca */
IF   tel_nrdolote = 1537   THEN
     DO:
         glb_cdcritic = 261.
         NEXT.
     END.

{includes/critica_numero_lote.i "tel_"}

IF   glb_cdcritic <> 0   THEN
     NEXT.

ASSIGN tel_qtcompln = 0  tel_vlcompdb = 0  tel_vlcompcr = 0
       tel_qtdifeln = 0  tel_vldifedb = 0  tel_vldifecr = 0
       tel_nmoperad = "" aux_qtinfocc = 0  aux_vlinfocc = 0  
       aux_qtinfoci = 0  aux_vlinfoci = 0  aux_qtinfocs = 0
       aux_vlinfocs = 0.       

DISPLAY tel_qtcompln   tel_qtdifeln   tel_vlcompdb   tel_vldifedb
        tel_vlcompcr   tel_vldifecr   tel_nmoperad   WITH FRAME f_lote.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
   IF   glb_cdcritic > 0   THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
        END.

   UPDATE tel_qtinfoln
          tel_vlinfodb
          tel_vlinfocr
          tel_tplotmov
          WITH FRAME f_lote

   EDITING:

      aux_stimeout = 0.

      DO WHILE TRUE:

         READKEY PAUSE 1.

         IF   LASTKEY = -1   THEN
              DO:
                  aux_stimeout = aux_stimeout + 1.

                  IF   aux_stimeout > glb_stimeout   THEN
                       QUIT.

                  NEXT.
              END.

         LEAVE.

      END.  /*  Fim do DO WHILE TRUE  */

      IF   FRAME-FIELD = "tel_vlinfodb"   OR
           FRAME-FIELD = "tel_vlinfocr"   THEN
           IF   LASTKEY =  KEYCODE(".")   THEN
                APPLY 44.
           ELSE
                APPLY LASTKEY.
      ELSE
      IF   FRAME-FIELD = "tel_tplotmov"   THEN
           IF   LASTKEY = KEYCODE("F7")   THEN
                DO:
                    RUN fontes/tplotmov.p (OUTPUT tel_tplotmov).
                    DISPLAY tel_tplotmov WITH FRAME f_lote.
                END.
           ELSE
                APPLY LASTKEY.
      ELSE
           APPLY LASTKEY.

   END.  /*  Fim do EDITING  */


   /* Lote de poupança agora é automatico pela ATENDA */
   IF   tel_tplotmov = 14   THEN
        DO:
            glb_cdcritic = 650.
            NEXT.
        END.

   IF  tel_tplotmov = 10          AND
       YEAR(glb_dtmvtolt) >= 2008 THEN
       DO:
           glb_cdcritic = 36.
           RUN fontes/critic.p.
           MESSAGE glb_dscritic.
           glb_cdcritic = 0.
           IF   CAPS(glb_nmdatela) = "LOTE"   THEN
                DO:
                    ASSIGN  tel_vlinfodb = 0
                            tel_vlinfocr = 0
                            tel_tplotmov = 0
                            tel_qtinfoln = 0.
                    RETURN.
                END.   
       END.


   IF   NOT CAN-DO("1,2,3,4,5,6,8,9,10,11,12,13," +        
                   "16,17,18,19,20,21,23,24,25,26,27,29,35",
        STRING(tel_tplotmov))   OR
        tel_tplotmov = 22       THEN     /*  Reservado para BOLETIM DE CAIXA  */
        DO:     
            glb_cdcritic = 62.
            NEXT-PROMPT tel_tplotmov WITH FRAME f_lote.
            NEXT.
        END.
   
   IF   tel_qtinfoln = 0 AND CAN-DO("13,15,16,17,18",STRING(tel_tplotmov)) THEN
        DO:
            glb_cdcritic = 26.
            NEXT-PROMPT tel_qtinfoln WITH FRAME f_lote.
            NEXT.
        END.

   IF   ((tel_cdbccxlt = 400)  AND (NOT CAN-DO("9,10,11",STRING(tel_tplotmov))))
                               OR
       ((tel_cdbccxlt <> 400) AND (CAN-DO("9,10,11",STRING(tel_tplotmov)))) THEN
        DO:       
            glb_cdcritic = 62.
            NEXT-PROMPT tel_tplotmov WITH FRAME f_lote.
            NEXT.
        END.
   
   /*  Comp. eletronica  */

   IF   ((tel_cdbccxlt = 500)  AND (NOT CAN-DO("23",STRING(tel_tplotmov)))) OR
        ((tel_cdbccxlt <> 500) AND (CAN-DO("23",STRING(tel_tplotmov)))) THEN
        DO:
            glb_cdcritic = 584.
            NEXT-PROMPT tel_tplotmov WITH FRAME f_lote.
            NEXT.
        END.

   /*  Custodia  */
   IF   ((tel_cdbccxlt = 600)  AND (NOT CAN-DO("6,19",STRING(tel_tplotmov))))
                               OR
        ((tel_cdbccxlt <> 600) AND (CAN-DO("6,19",STRING(tel_tplotmov)))) THEN
        DO:
            glb_cdcritic = 584.
            NEXT-PROMPT tel_tplotmov WITH FRAME f_lote.
            NEXT.
        END.
  
   /*  Descontos  */
   
   IF   ((tel_cdbccxlt = 700)  AND 
         (NOT CAN-DO("26,27,35",STRING(tel_tplotmov))))
                               OR
        ((tel_cdbccxlt <> 700) AND 
         (CAN-DO("26,27,35",STRING(tel_tplotmov)))) THEN
        DO:
            glb_cdcritic = 584.
            NEXT-PROMPT tel_tplotmov WITH FRAME f_lote.
            NEXT.
        END.

   IF   tel_cdbccxlt <> 11 AND tel_tplotmov = 21 THEN /* IPTU somente no dia */
        DO:
            glb_cdcritic = 584.
            NEXT-PROMPT tel_tplotmov WITH FRAME f_lote.
            NEXT.
        END.

   /* Valor da tarifa não é mais informado manualmente nos lançamentos de cobrança */
   IF   tel_tplotmov = 18 AND (tel_vlinfocr = 0 /*OR tel_vlinfodb = 0*/) THEN
        DO:
            glb_cdcritic = 61.
            IF   tel_vlinfocr = 0 THEN
                 NEXT-PROMPT tel_vlinfocr WITH FRAME f_lote.
            ELSE
                 NEXT-PROMPT tel_vlinfodb WITH FRAME f_lote.
            NEXT.
        END.

   /*  Lote utilizado para digitacao de cheques em custodia  */
 
   IF   tel_tplotmov = 19   THEN
        DO:
            IF   tel_vlinfocr > 0   AND   tel_vlinfodb > 0   THEN
                 DO:
                     IF   tel_vlinfocr <> tel_vlinfodb   THEN
                          DO:
                              glb_cdcritic = 665.
                              NEXT-PROMPT tel_vlinfodb 
                                          WITH FRAME f_lote.
                              NEXT.
                          END.
                 END.
            ELSE
                 DO:
                     glb_cdcritic = 269.
                     NEXT-PROMPT tel_vlinfodb WITH FRAME f_lote.
                     NEXT.
                 END.
          
        END.

   /*  Lote utilizado para digitacao de titulos compensaveis  */
   
   IF   tel_tplotmov = 20 OR tel_tplotmov = 21 THEN
        DO:
            IF   tel_nrdolote > 4600   AND   tel_nrdolote < 4700   THEN
                 DO:
                     IF   tel_vlinfocr = 0   THEN
                          DO:
                              glb_cdcritic = 269.
                              NEXT-PROMPT tel_vlinfocr WITH FRAME f_lote.
                              NEXT.
                          END.

                     tel_vlinfodb = 0.
                 END.
            ELSE
                 DO:
                     glb_cdcritic = 58.
                     NEXT-PROMPT tel_tplotmov WITH FRAME f_lote.
                     NEXT.
                 END.
        
            IF   tel_cdbccxlt = 11  AND tel_tplotmov = 20 THEN
                 DO:
                     /*  Tabela com o horario limite para digitacao  */

                     FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                                        craptab.nmsistem = "CRED"       AND
                                        craptab.tptabela = "GENERI"     AND
                                        craptab.cdempres = 0            AND
                                        craptab.cdacesso = "HRTRTITULO" AND
                                        craptab.tpregist = tel_cdagenci
                                        NO-LOCK NO-ERROR.

                     IF   NOT AVAILABLE craptab   THEN
                          DO:
                              glb_cdcritic = 676.
                              NEXT.
                          END.

                     IF   TIME >= INT(SUBSTRING(craptab.dstextab,3,5))   THEN
                          DO:
                              glb_cdcritic = 676.
                              NEXT.
                          END.

                     IF   INT(SUBSTRING(craptab.dstextab,1,1)) > 0   THEN
                          DO:
                              glb_cdcritic = 677.
                              NEXT.
                          END.
                 END.
        END.
        
   IF  (tel_nrdolote > 4600   AND   
        tel_nrdolote < 4700)  AND
        (tel_tplotmov <> 20 AND tel_tplotmov <> 21)  THEN
        DO:
            glb_cdcritic = 62.
            NEXT-PROMPT tel_nrdolote WITH FRAME f_lote.
            NEXT.
        END.

   IF  tel_tplotmov = 23  THEN
       DO:
           glb_cdcritic = 62.
           NEXT-PROMPT tel_tplotmov WITH FRAME f_lote.
           NEXT.
       END.
    
    IF tel_tplotmov = 19 OR /* Custodia de Cheque */
       tel_tplotmov = 26 OR /* Bordero Desconto Cheque */
       tel_tplotmov = 27 THEN /* Limite Desconto de Cheque */
       DO:
           glb_cdcritic = 62.
           NEXT-PROMPT tel_tplotmov WITH FRAME f_lote.
           NEXT.
       END.
     
    
   /*  Comp. eletronica  */
   
   IF   tel_tplotmov = 23   OR
        tel_tplotmov = 24   OR
        tel_tplotmov = 25   THEN
        DO:
            /*  Tabela com o horario limite para digitacao  */

            FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                               craptab.nmsistem = "CRED"         AND
                               craptab.tptabela = "GENERI"       AND
                               craptab.cdempres = 0              AND
                               craptab.cdacesso = "HRTRCOMPEL"   AND
                               craptab.tpregist = tel_cdagenci
                               NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE craptab   THEN
                 DO:
                     glb_cdcritic = 676.
                     NEXT.
                 END.

            IF   TIME >= INT(SUBSTRING(craptab.dstextab,3,5))   THEN
                 DO:
                     glb_cdcritic = 676.
                     NEXT.
                 END.

            IF   INT(SUBSTRING(craptab.dstextab,1,1)) > 0   THEN
                 DO:
                     FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                                        craptab.nmsistem = "CRED"         AND
                                        craptab.tptabela = "GENERI"       AND
                                        craptab.cdempres = 0              AND
                                        craptab.cdacesso = "EXETRUNCAGEM" AND
                                        craptab.tpregist = tel_cdagenci   
                                        NO-LOCK NO-ERROR.
                   
                     IF   NOT AVAILABLE craptab THEN
                          DO:
                              glb_cdcritic = 677.
                              NEXT.
                          END.
                     ELSE
                          IF   craptab.dstextab = "NAO" THEN
                               DO:
                                   glb_cdcritic = 677.
                                   NEXT.
                               END.
                 END.

            IF   tel_cdhistor = 23   AND
                (((tel_vlinfocr = 0 AND tel_vlinfodb = 0) OR
                 (tel_vlinfocr <> tel_vlinfodb)))         THEN
                  DO:                
                      glb_cdcritic = 61.
                      NEXT-PROMPT tel_vlinfodb WITH FRAME f_lote.
                      NEXT.
                  END.
        END.

   /*  Lote utilizado para digitacao de desconto de cheques */
   IF   tel_tplotmov = 26  THEN
        DO:
            IF   tel_vlinfocr > 0   AND   tel_vlinfodb > 0   THEN
                 DO:
                     IF   tel_vlinfocr <> tel_vlinfodb   THEN
                          DO:
                              glb_cdcritic = 665.
                              NEXT-PROMPT tel_vlinfodb WITH FRAME f_lote.
                              NEXT.
                          END.
                 END.
            ELSE
                 DO:
                     glb_cdcritic = 269.
                     NEXT-PROMPT tel_vlinfodb WITH FRAME f_lote.
                     NEXT.
                 END.
        END.
   
   /* Lote utilizado para digitacao de contrato de descontos(cheques titulos) */
   IF   tel_tplotmov = 27 OR tel_tplotmov = 35   THEN
        DO:
            IF   tel_vlinfocr = 0   THEN
                 IF   tel_vlinfodb > 0   THEN
                      tel_vlinfocr = tel_vlinfodb.
                 ELSE
                      DO:
                          glb_cdcritic = 269.
                          NEXT-PROMPT tel_vlinfocr WITH FRAME f_lote.
                          NEXT.
                      END.

            tel_vlinfodb = 0.
        END.

   IF   tel_vlinfodb =  0   AND
        tel_vlinfocr =  0   AND
        NOT CAN-DO("8,11",STRING(tel_tplotmov))   THEN
        DO:                
            glb_cdcritic = 61.
            NEXT-PROMPT tel_vlinfodb WITH FRAME f_lote.
            NEXT.
        END.

    /* Conta de Investimento */
    IF   tel_tplotmov = 29  AND
         (tel_cdbccxlt <> 100 AND tel_cdbccxlt <> 11)      THEN      DO:
            glb_cdcritic = 62.
            NEXT-PROMPT tel_tplotmov WITH FRAME f_lote.
            NEXT.
        END.

   IF   tel_tplotmov = 13  AND  (tel_cdbccxlt <> 31 AND tel_cdbccxlt <> 30) THEN
        DO:          
            glb_cdcritic = 62.
            NEXT-PROMPT tel_tplotmov WITH FRAME f_lote.
            NEXT.
        END.

   IF   tel_tplotmov = 13  AND (tel_nrdolote < 3100 OR tel_nrdolote > 3150) THEN
        DO:
            glb_cdcritic = 58.
            NEXT-PROMPT tel_nrdolote WITH FRAME f_lote.
            NEXT.
        END.

   IF   tel_tplotmov <> 13  AND (tel_cdbccxlt = 31 OR tel_cdbccxlt = 30) THEN
        DO:
            glb_cdcritic = 62.
            NEXT-PROMPT tel_tplotmov WITH FRAME f_lote.
            NEXT.
        END.

   IF  tel_tplotmov <> 13 AND (tel_nrdolote > 3099 AND tel_nrdolote < 3151) THEN
        DO:
            glb_cdcritic = 58.
            NEXT-PROMPT tel_nrdolote WITH FRAME f_lote.
            NEXT.
        END.

   IF   CAN-DO("4150,4152,4153",STRING(tel_nrdolote)) AND 
        tel_tplotmov <> 15 THEN
        DO:
            glb_cdcritic = 62.
            NEXT-PROMPT tel_nrdolote WITH FRAME f_lote.
            NEXT.
        END.

   IF   tel_tplotmov <> 6     AND  tel_tplotmov <> 12 AND tel_tplotmov <> 17 AND
        tel_nrdolote > 5999   AND
        tel_nrdolote < 7000   THEN
        DO:
            glb_cdcritic = 261.
            NEXT-PROMPT tel_tplotmov WITH FRAME f_lote.
            NEXT.
        END.

   IF   CAN-DO("4,6,11,12,17",STRING(tel_tplotmov)) THEN
        DO:
            IF   tel_vlinfocr > 0   THEN
                 DO: 
                     glb_cdcritic = 61.
                     NEXT-PROMPT tel_vlinfocr WITH FRAME f_lote.
                     NEXT.
                 END.
              
            IF   tel_tplotmov = 6   THEN
                 DO:
                    IF   tel_nrdolote < 6000   OR
                         tel_nrdolote > 6499   THEN
                         DO:
                             glb_cdcritic = 261.
                             NEXT-PROMPT tel_tplotmov WITH FRAME f_lote.
                             NEXT.
                         END.

                    FIND FIRST craplot WHERE 
                               craplot.cdcooper = glb_cdcooper  AND
                               craplot.dtmvtopg > tel_dtmvtolt  AND
                               craplot.dtmvtopg <> ?            AND
                               craplot.nrdolote = tel_nrdolote  
                               NO-LOCK NO-ERROR.

                    IF   AVAILABLE craplot   THEN
                         DO:
                            glb_cdcritic = 059.
                            NEXT-PROMPT tel_nrdolote WITH FRAME f_lote.
                            NEXT.
                         END.
                 END.

            IF   tel_tplotmov = 12   THEN
                 DO:
                    IF   tel_cdbccxlt <> 911   THEN
                         DO:
                             glb_cdcritic = 584.
                             NEXT-PROMPT tel_tplotmov WITH FRAME f_lote.
                             NEXT.
                         END.
                    
                    IF   tel_nrdolote < 6500   OR
                         tel_nrdolote > 6799   THEN
                         DO:   
                             glb_cdcritic = 62.
                             NEXT-PROMPT tel_tplotmov WITH FRAME f_lote.
                             NEXT.
                         END.                    
                 END.

            IF   tel_tplotmov = 17  AND
                 (tel_nrdolote < 6800 OR tel_nrdolote > 6849) THEN
                 DO:
                     glb_cdcritic = 58.
                     NEXT-PROMPT tel_nrdolote WITH FRAME f_lote.
                     NEXT.
                 END.
        END.
   ELSE
   IF   CAN-DO("3,7,9,10,13,16",STRING(tel_tplotmov)) THEN
        IF   tel_vlinfodb > 0   THEN
             DO:                       
                 glb_cdcritic = 61.
                 NEXT-PROMPT tel_vlinfodb WITH FRAME f_lote.
                 NEXT.
             END.
        ELSE
        IF   tel_vlinfocr = 0   THEN
             DO:                      
                 glb_cdcritic = 61.
                 NEXT-PROMPT tel_vlinfocr WITH FRAME f_lote.
                 NEXT.
             END.
        ELSE .
   ELSE
   IF   tel_tplotmov = 8   AND
        tel_vlinfodb > 0   THEN
        DO:
            glb_cdcritic = 61.
            NEXT-PROMPT tel_vlinfodb WITH FRAME f_lote.
            NEXT.
        END.

   tel_dtmvtopg = ?.

   IF   tel_tplotmov = 6 THEN
        DO:
           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

              UPDATE tel_dtmvtopg   WITH FRAME f_data.

              IF   tel_dtmvtopg = ?                   OR
                   tel_dtmvtopg > (glb_dtmvtolt + 60) OR
                   tel_dtmvtopg <= glb_dtmvtolt       OR
                   CAN-DO("1,7",STRING(WEEKDAY(tel_dtmvtopg))) THEN
                   glb_cdcritic = 013.
              ELSE
                   DO:
                       FIND crapfer WHERE crapfer.cdcooper = glb_cdcooper   AND
                                          crapfer.dtferiad = tel_dtmvtopg
                                          NO-LOCK NO-ERROR.

                            IF   AVAILABLE crapfer   THEN
                                 glb_cdcritic = 13.
                   END.

              IF   glb_cdcritic > 0 THEN
                   DO:
                       RUN fontes/critic.p.
                       BELL.
                       MESSAGE glb_dscritic.
                       NEXT-PROMPT tel_dtmvtopg WITH FRAME f_data.
                       glb_cdcritic = 0.
                   END.
              ELSE
                   LEAVE.

           END. /* Fim do DO WHILE TRUE */

           HIDE FRAME f_data NO-PAUSE.

           IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
                RETURN.
        END.

   IF   tel_tplotmov = 12 OR tel_tplotmov = 17 THEN
        DO:
           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

              IF   glb_cdcritic > 0 THEN
                   DO:
                       RUN fontes/critic.p.
                       BELL.
                       MESSAGE glb_dscritic.
                       glb_cdcritic = 0.
                   END.

              UPDATE tel_dtmvtopg  
                     tel_cdhistor
                     tel_cdbccxpg
                     WITH FRAME f_debito 

              EDITING:

                READKEY.

                IF   LASTKEY = KEYCODE("F7") THEN
                     DO:
                         IF   FRAME-FIELD = "tel_cdhistor"   THEN
                              DO:
                                  RUN fontes/zoom_historicos.p
                                                      (INPUT glb_cdcooper,
                                                       INPUT TRUE,
                                                       INPUT 0,
                                                       OUTPUT tel_cdhistor).

                                  DISPLAY tel_cdhistor
                                          WITH FRAME f_debito.
                              END. 
                         ELSE 
                              APPLY LASTKEY.
                     END.
                ELSE 
                     APPLY LASTKEY.

              END. /* Fim do EDITING */

              IF   tel_dtmvtopg > (glb_dtmvtolt + 30) THEN
                   DO:
                       glb_cdcritic = 13.
                       NEXT-PROMPT tel_dtmvtopg WITH FRAME f_debito.
                       NEXT.
                   END.

              IF   tel_tplotmov = 12 AND tel_dtmvtopg < glb_dtmvtolt THEN
                   DO:
                       glb_cdcritic = 013.
                       NEXT-PROMPT tel_dtmvtopg WITH FRAME f_debito.
                       NEXT.
                   END.

              IF   tel_dtmvtopg < glb_dtmvtoan AND tel_tplotmov = 17 THEN
                   DO:
                       glb_cdcritic = 013.
                       NEXT-PROMPT tel_dtmvtopg WITH FRAME f_debito.
                       NEXT.
                   END.
              
              /*  Nao permite data de pagamento para último dia útil do Ano.  */

              RUN sistema/generico/procedures/b1wgen0015.p 
              PERSISTENT SET h-b1wgen0015.

              ASSIGN aux_dtdialim = DATE(12,31,YEAR(tel_dtmvtopg)).

              RUN retorna-dia-util IN h-b1wgen0015 (INPUT glb_cdcooper,
                                                    INPUT FALSE,  /* Feriado */
                                                    INPUT TRUE, /** Anterior **/
                                                    INPUT-OUTPUT aux_dtdialim).
              DELETE PROCEDURE h-b1wgen0015.

              IF   aux_dtdialim = tel_dtmvtopg THEN 
                   DO:
                       glb_cdcritic = 13.
                       RUN fontes/critic.p.
                       BELL.
                       MESSAGE glb_dscritic. 
                       NEXT.
                   END.

              IF   tel_tplotmov = 17 THEN
                   DO:
                        FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                                           craptab.nmsistem = "CRED"         AND
                                           craptab.tptabela = "USUARI"       AND
                                           craptab.cdempres = 11             AND
                                           craptab.cdacesso = "HISTCARTAO"   AND
                                           craptab.tpregist = tel_cdhistor     
                                           NO-LOCK NO-ERROR.

                        IF   NOT AVAILABLE craptab THEN
                             DO:
                                 glb_cdcritic = 611.
                                 NEXT-PROMPT tel_cdhistor WITH FRAME f_debito.
                                 NEXT.
                             END.

                        FIND craptlc WHERE craptlc.cdcooper = glb_cdcooper AND
                                           craptlc.cdadmcrd = 
                                                 INTEGER(craptab.dstextab) AND
                                           craptlc.tpcartao = 0            AND
                                           craptlc.cdlimcrd = 0            AND
                                           craptlc.dddebito = DAY(tel_dtmvtopg)
                                           NO-LOCK NO-ERROR.

                        IF   NOT AVAILABLE craptlc THEN
                             DO:
                                 glb_cdcritic = 013.
                                 NEXT-PROMPT tel_dtmvtopg WITH FRAME f_debito.
                                 NEXT.
                             END.

                   END.
              ELSE
                   DO:                   
                       FIND craphis  WHERE 
                            craphis.cdcooper = glb_cdcooper AND
                            craphis.cdhistor = tel_cdhistor
                                           NO-LOCK NO-ERROR. 
                       
                       IF   NOT AVAILABLE craphis THEN
                            DO:
                                glb_cdcritic = 93.
                                NEXT-PROMPT tel_cdhistor WITH FRAME f_debito.
                                NEXT.
                            END.
                       ELSE
                            IF   craphis.tplotmov <>   1   OR
                                 craphis.inhistor <>  11   OR
                                 craphis.indebcre <> "D"   OR
                                 craphis.indebcta <>   1   THEN
                                 DO:             
                                     glb_cdcritic = 94.
                                     NEXT-PROMPT tel_cdhistor
                                                 WITH FRAME f_debito.
                                     NEXT.
                                 END.
                   END.

              LEAVE.

           END. /* Fim do DO WHILE TRUE */

           HIDE FRAME f_debito NO-PAUSE.

           IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
                RETURN.
        END.

   IF   tel_tplotmov = 13 THEN
        DO:
           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

              IF   glb_cdcritic > 0 THEN
                   DO:
                       RUN fontes/critic.p.
                       BELL.
                       MESSAGE glb_dscritic.
                       glb_cdcritic = 0.
                   END.

              tel_dtmvtopg = glb_dtmvtolt.
              DISPLAY tel_dtmvtopg WITH FRAME f_fatura.

              UPDATE tel_cdhistor 
                     WITH FRAME f_fatura

              EDITING:
                  
                READKEY.

                IF   LASTKEY = KEYCODE("F7")   THEN
                     DO:
                         IF   FRAME-FIELD = "tel_cdhistor" THEN
                              DO:
                                  RUN fontes/zoom_historicos.p
                                                      (INPUT glb_cdcooper,
                                                       INPUT TRUE,
                                                       INPUT 0,
                                                       OUTPUT tel_cdhistor).

                                  DISPLAY tel_cdhistor
                                          WITH FRAME f_fatura.
                             
                              END.
                         ELSE 
                              APPLY LASTKEY.
                     END.
                ELSE 
                     APPLY LASTKEY.

              END.

              cal_dtmvtopg = tel_dtmvtopg.

              FIND craphis  WHERE 
                   craphis.cdcooper = glb_cdcooper AND
                   craphis.cdhistor = tel_cdhistor
                                  NO-LOCK NO-ERROR.

              IF   NOT AVAILABLE craphis THEN
                   DO:
                      glb_cdcritic = 93.
                      NEXT-PROMPT tel_cdhistor WITH FRAME f_fatura.
                      NEXT.
                   END.
              ELSE
                   IF   craphis.cdhistor <> 306   AND
                        craphis.cdhistor <> 307   AND
                        craphis.cdhistor <> 308   AND
                        craphis.cdhistor <> 309   AND
                        craphis.cdhistor <> 348   AND
/* Embratel cancelada em 09/01/2004  craphis.cdhistor <> 374   AND */
                        craphis.cdhistor <> 396   AND
                        craphis.cdhistor <> 398   AND
                        craphis.cdhistor <> 748 THEN
                        DO: 
                            glb_cdcritic = 94.
                            NEXT-PROMPT tel_cdhistor WITH FRAME f_fatura.
                            NEXT.
                        END.
                        
               IF   CAN-DO("306,307,348",STRING(tel_cdhistor)) AND
                                         tel_cdbccxlt <> 30 THEN
                    DO:    
                        glb_cdcritic = 94.
                        NEXT-PROMPT tel_cdhistor WITH FRAME f_fatura.
                        NEXT.
                    END.
               /* Embratel cancelada em 09/01/2004 */
               IF   CAN-DO("308/*,374*/", STRING(tel_cdhistor)) AND
                     tel_cdbccxlt <> 31 THEN
                    DO:     
                        glb_cdcritic = 94.
                        NEXT-PROMPT tel_cdhistor WITH FRAME f_fatura.
                        NEXT.
                    END.

               IF   craphis.tpctbcxa = 2 THEN
                    DO:
                        FIND crapage WHERE crapage.cdcooper = glb_cdcooper   AND
                                           crapage.cdagenci = tel_cdagenci
                                           NO-LOCK NO-ERROR.
               
                        IF   NOT AVAILABLE crapage THEN
                             DO:
                                 glb_cdcritic = 134.
                                 NEXT-PROMPT tel_cdhistor WITH FRAME f_fatura.
                                 NEXT.
                             END.
                        ELSE
                             IF   crapage.cdcxaage = 0 THEN
                                  DO:
                                      glb_cdcritic = 134.
                                      NEXT-PROMPT tel_cdhistor 
                                                  WITH FRAME f_fatura.
                                      NEXT.
                                  END.
                    END.

               LEAVE.

           END. /* Fim do DO WHILE TRUE */

           HIDE FRAME f_fatura NO-PAUSE.

           IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
                RETURN.
        END.

   IF   tel_tplotmov = 19 THEN                       /*  Cheques em custodia  */
        DO:
           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

              UPDATE tel_dtmvtopg WITH FRAME f_data_custodia.

              ASSIGN aux_dtminimo = glb_dtmvtolt
                     aux_qtddmini = 0.
      
              DO WHILE TRUE:
             
                 aux_dtminimo = aux_dtminimo + 1.

                 IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtminimo))) OR
                      CAN-FIND(crapfer WHERE crapfer.cdcooper =
                               glb_cdcooper   
                                         AND crapfer.dtferiad =
                               aux_dtminimo) THEN
                      NEXT.
                 ELSE 
                      aux_qtddmini = aux_qtddmini + 1.

                 IF   aux_qtddmini = 2 THEN
                      LEAVE.
                   
              END.  /*  Fim do DO WHILE TRUE  */
                  
              IF   tel_dtmvtopg = ?                      OR
                   tel_dtmvtopg <= aux_dtminimo          OR
                   tel_dtmvtopg > (glb_dtmvtolt + 1095)   THEN
                   DO:
                       glb_cdcritic = 13.
                       RUN fontes/critic.p.
                       BELL.
                       MESSAGE glb_dscritic.
                       NEXT.
                   END.

              /*  Nao permite data de liberação para último dia útil do Ano.  */

              RUN sistema/generico/procedures/b1wgen0015.p 
              PERSISTENT SET h-b1wgen0015.

              ASSIGN aux_dtdialim = DATE(12,31,YEAR(tel_dtmvtopg)).
              RUN retorna-dia-util IN h-b1wgen0015 (INPUT glb_cdcooper,
                                                    INPUT FALSE,  /* Feriado */
                                                    INPUT TRUE, /** Anterior **/
                                                    INPUT-OUTPUT aux_dtdialim).
              DELETE PROCEDURE h-b1wgen0015.

              IF   aux_dtdialim = tel_dtmvtopg THEN 
                   DO:
                       glb_cdcritic = 13.
                       RUN fontes/critic.p.
                       BELL.
                       MESSAGE glb_dscritic. 
                       NEXT.
                   END.

             LEAVE.

           END. /* Fim do DO WHILE TRUE */

           HIDE FRAME f_data_custodia NO-PAUSE.

           IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
                RETURN.

           FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

           IF   NOT AVAILABLE crapcop   THEN
                DO:
                    glb_cdcritic = 651.
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    RETURN.
                END.

           aux_dschqcop = "Cheques " + STRING(crapcop.nmrescop,"x(11)") + ":".

           HIDE MESSAGE NO-PAUSE.
                          
           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

              DISPLAY aux_dschqcop WITH FRAME f_info.
              
              UPDATE  aux_qtinfocc
                      aux_vlinfocc
                      aux_qtinfoci
                      aux_vlinfoci
                      aux_qtinfocs
                      aux_vlinfocs WITH FRAME f_info

              EDITING:

                 READKEY.
                 
                 IF   FRAME-FIELD = "aux_vlinfocc"   OR
                      FRAME-FIELD = "aux_vlinfocs"   OR
                      FRAME-FIELD = "aux_vlinfoci"   THEN
                      IF   LASTKEY =  KEYCODE(".")   THEN
                           APPLY 44.
                      ELSE
                           APPLY LASTKEY.
                 ELSE
                      APPLY LASTKEY.

              END.   /* Fim do EDITING  */

              ASSIGN tot_qtcheque = aux_qtinfocc + aux_qtinfoci + aux_qtinfocs
                     tot_vlcheque = aux_vlinfocc + aux_vlinfoci + aux_vlinfocs.

              DISPLAY tot_qtcheque tot_vlcheque WITH FRAME f_info.
              
              IF   tot_qtcheque <> tel_qtinfoln THEN
                   glb_cdcritic = 26.
                       
              IF   tot_vlcheque <> tel_vlinfocr THEN
                   glb_cdcritic = 269.
                   
              IF   glb_cdcritic > 0 THEN
                   DO:
                       RUN fontes/critic.p.
                       BELL.
                       MESSAGE glb_dscritic.
                       glb_cdcritic = 0.
                       NEXT.
                   END.

              LEAVE.

           END. /* Fim do DO WHILE TRUE */

           HIDE FRAME f_info NO-PAUSE.

           IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
                RETURN.
        /* FIM */
        END.

   IF   tel_tplotmov = 20 THEN /*  Titulos Compensaveis  */
        DO:
           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

              UPDATE tel_dtmvtopg WITH FRAME f_data_custodia.

              IF   tel_dtmvtopg <> ?   THEN
                   DO:
                       IF   tel_dtmvtopg <= glb_dtmvtolt                OR
                            CAN-DO("1,7",STRING(WEEKDAY(tel_dtmvtopg))) OR
                            CAN-FIND(crapfer WHERE 
                                     crapfer.cdcooper = glb_cdcooper AND
                                     crapfer.dtferiad = tel_dtmvtopg)   THEN
                            glb_cdcritic = 13.
                       ELSE
                       IF   tel_cdbccxlt <> 100   THEN
                            glb_cdcritic = 13.
                       ELSE
                            DO:

                                FIND craplot WHERE
                                     craplot.cdcooper = glb_cdcooper     AND
                                     craplot.dtmvtopg = tel_dtmvtopg     AND
                                     craplot.cdagenci = tel_cdagenci     AND
                                     craplot.cdbccxlt = tel_cdbccxlt     AND
                                     craplot.nrdolote = tel_nrdolote
                                     NO-LOCK NO-ERROR.
                                     
                                IF   AVAILABLE craplot   THEN
                                     DO:
                                         glb_cdcritic = 59.
                                         RUN fontes/critic.p.
                                         BELL.
                                         MESSAGE glb_dscritic 
                                                 "em" STRING(craplot.dtmvtolt,
                                                             "99/99/9999")
                                                 "Tente outro numero de lote.".
                                         glb_cdcritic = 0.
                                         NEXT.
                                     END.
                            END.
                   END.
              ELSE
              IF   tel_cdbccxlt <> 11   THEN
                   glb_cdcritic = 584.

              IF   glb_cdcritic > 0 THEN
                   DO:
                       RUN fontes/critic.p.
                       BELL.
                       MESSAGE glb_dscritic.
                       glb_cdcritic = 0.
                       NEXT.
                   END.

              LEAVE.

           END. /* Fim do DO WHILE TRUE */

           HIDE FRAME f_data_custodia NO-PAUSE.

           IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
                RETURN.
        END.

   IF   tel_tplotmov = 26  THEN  /*  Descontos de cheques */
        DO:
            /*  Numero do bordero ........................................... */
   
            HIDE MESSAGE NO-PAUSE.
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
               IF   glb_cdcritic > 0 THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                    END.
               
               UPDATE tel_nrdconta WITH FRAME f_bordero.
               
               glb_nrcalcul = tel_nrdconta.
                                    
               RUN fontes/digfun.p.
                  
               IF   NOT glb_stsnrcal   THEN
                    DO:
                        glb_cdcritic = 8.
                        NEXT.
                    END.
 
               IF   NOT CAN-FIND(crapass WHERE
                                 crapass.cdcooper = glb_cdcooper    AND
                                 crapass.nrdconta = tel_nrdconta)   THEN
                    DO:
                        glb_cdcritic = 9.
                        NEXT.
                    END.
               
               RUN sistema/generico/procedures/b1wgen0001.p
                   PERSISTENT SET h-b1wgen0001.
      
               IF  VALID-HANDLE(h-b1wgen0001)   THEN
               DO:
                   RUN ver_capital IN h-b1wgen0001(INPUT  glb_cdcooper,
                                                   INPUT  tel_nrdconta,
                                                   INPUT  0, /* cod-agencia */
                                                   INPUT  0, /* nro-caixa   */
                                                   0,        /* vllanmto */
                                                   INPUT  glb_dtmvtolt,
                                                   INPUT  "lotei",
                                                   INPUT  1, /* AYLLOS */
                                                   OUTPUT TABLE tt-erro).
                   /* Verifica se houve erro */
                   FIND FIRST tt-erro NO-LOCK  NO-ERROR.
       
                   IF   AVAILABLE tt-erro   THEN
                   DO:
                        ASSIGN glb_cdcritic = tt-erro.cdcritic
                               glb_dscricpl = tt-erro.dscritic.
                   END.
                   DELETE PROCEDURE h-b1wgen0001.
               END.
               /************************************/
               IF   glb_cdcritic > 0   THEN
                    NEXT.
               
               FIND FIRST craplim WHERE craplim.cdcooper = glb_cdcooper   AND
                                        craplim.nrdconta = tel_nrdconta   AND
                                        craplim.tpctrlim = 2              AND
                                        craplim.insitlim = 2 
                                        NO-LOCK NO-ERROR.
                                        
               IF   NOT AVAILABLE craplim   THEN
                    DO:
                        MESSAGE "Nao ha contrato de limite de desconto ATIVO.".
                        NEXT.
                    END.
                    
               FIND craptab WHERE 
                    craptab.cdcooper = glb_cdcooper AND
                    craptab.nmsistem = "CRED"       AND
                    craptab.tptabela = "USUARI"     AND
                    craptab.cdempres = 11           AND
                    craptab.cdacesso = "LIMDESCONT" AND
                    craptab.tpregist = 0            NO-LOCK NO-ERROR.

               IF   NOT AVAILABLE craptab   THEN
                    DO:
                        MESSAGE "Registro de parametros de descto de cheques " +
                                "nao encontrado.".
                        NEXT.
                    END.
                    
               /* Quantidade maxima de renovacoes */
               tab_qtrenova = DECIMAL(SUBSTRING(craptab.dstextab,19,02)).

               IF glb_dtmvtolt >= craplim.dtinivig + 
                                  (craplim.qtdiavig * tab_qtrenova) THEN
                  DO:
                      MESSAGE "Contrato de limite esta vencido.".
                      NEXT.
                  END.                    

               FIND crapldc WHERE crapldc.cdcooper = glb_cdcooper     AND
                                  crapldc.cddlinha = craplim.cddlinha AND
                                  crapldc.tpdescto = 2
                                  NO-LOCK NO-ERROR.
            
               IF  NOT AVAILABLE crapldc   THEN
                   RETURN.

               IF   NOT crapldc.flgstlcr   THEN
                    DO:
                        MESSAGE "Linha de desconto" 
                                crapldc.cddlinha "bloqueada.".
                        NEXT.
                    END.

               /*  Verifica se a conta foi ou sera transferida .............  */
                              
               FIND FIRST craptrf WHERE craptrf.cdcooper = glb_cdcooper   AND
                                        craptrf.nrdconta = tel_nrdconta   AND
                                        craptrf.tptransa = 1 
                                        NO-LOCK NO-ERROR.
                                        
               IF   AVAILABLE craptrf   THEN
                    DO:
                        IF   craptrf.insittrs = 1   THEN
                             MESSAGE "Conta transferida para" 
                                   TRIM(STRING(craptrf.nrsconta,"zzzz,zzz,9")).
                        ELSE
                             MESSAGE "Conta a ser transferida para"
                                   TRIM(STRING(craptrf.nrsconta,"zzzz,zzz,9")).
                        NEXT.
                    END.
               
               LEAVE.
                                   
            END.  /*  Fim do DO WHILE TRUE  */

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN   /*   F4 OU FIM   */
                 RETURN.
        END.

   LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
     NEXT.

TRANS_I:

DO TRANSACTION ON ERROR UNDO TRANS_I, NEXT:

   CREATE craplot.
   ASSIGN craplot.dtmvtolt = tel_dtmvtolt
          craplot.cdagenci = tel_cdagenci
          craplot.cdbccxlt = tel_cdbccxlt
          craplot.nrdolote = tel_nrdolote
          craplot.qtinfoln = tel_qtinfoln
          craplot.vlinfocr = tel_vlinfocr
          craplot.vlinfodb = tel_vlinfodb
          craplot.tplotmov = tel_tplotmov
          craplot.dtmvtopg = tel_dtmvtopg
          craplot.cdoperad = glb_cdoperad
          craplot.cdhistor = tel_cdhistor
          craplot.cdbccxpg = tel_cdbccxpg
          craplot.cdcooper = glb_cdcooper

          glb_cdagenci     = tel_cdagenci
          glb_cdbccxlt     = tel_cdbccxlt
          glb_nrdolote     = tel_nrdolote

          craplot.qtinfocc = aux_qtinfocc
          craplot.vlinfocc = aux_vlinfocc
          craplot.qtinfoci = aux_qtinfoci
          craplot.vlinfoci = aux_vlinfoci
          craplot.qtinfocs = aux_qtinfocs
          craplot.vlinfocs = aux_vlinfocs.
   
   IF   CAN-DO("11,30,31,500",
               STRING(craplot.cdbccxlt)) THEN  /* boletim de caixa */
        ASSIGN craplot.nrdcaixa = tel_nrdcaixa
               craplot.cdopecxa = tel_cdopecxa.
        
   VALIDATE craplot.

   IF   craplot.tplotmov = 26   THEN           /*  Le com EXCLUSIVE para     */
        DO:                                    /*  garantir o ultimo numero  */
                                               /*  do bordero                */
           /* Alterado para utilizar sequence atraves do oracle */
            RUN STORED-PROCEDURE pc_sequence_progress
            aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPBDC"
                                                ,INPUT "NRBORDER"
                                                ,INPUT TRIM(STRING(glb_cdcooper))
                                                ,INPUT "N"
                                                ,"").
            
            CLOSE STORED-PROC pc_sequence_progress
            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                     
            ASSIGN aux_nrsequen = INTE(pc_sequence_progress.pr_sequence)
                                  WHEN pc_sequence_progress.pr_sequence <> ?.

            ASSIGN tel_nrborder = aux_nrsequen.
            
            craplot.cdhistor = tel_nrborder.

            CREATE crapbdc.
            ASSIGN crapbdc.dtmvtolt = craplot.dtmvtolt
                   crapbdc.cdagenci = craplot.cdagenci
                   crapbdc.cdbccxlt = craplot.cdbccxlt
                   crapbdc.nrdolote = craplot.nrdolote
                   crapbdc.nrborder = craplot.cdhistor
                   crapbdc.cdoperad = craplot.cdoperad
                   crapbdc.nrctrlim = craplim.nrctrlim
                   crapbdc.nrdconta = craplim.nrdconta
                   crapbdc.cddlinha = craplim.cddlinha
                   crapbdc.txmensal = crapldc.txmensal
                   crapbdc.txdiaria = crapldc.txdiaria
                   crapbdc.txjurmor = crapldc.txjurmor
                   crapbdc.insitbdc = 1
                   crapbdc.inoribdc = 1
                   crapbdc.hrtransa = TIME
                   crapbdc.cdcooper = glb_cdcooper. 

            VALIDATE crapbdc.

            FIND CURRENT crapbdc NO-LOCK NO-ERROR.
            RELEASE crapbdc.       
        END.

END.  /*  Fim da transacao  --  TRANS_I  */

ASSIGN glb_nmtelant = glb_nmdatela
       glb_nmdatela = aux_proxtela[tel_tplotmov]
       tel_qtinfoln = 0
       tel_vlinfodb = 0
       tel_vlinfocr = 0
       tel_tplotmov = 0
       tel_dtmvtopg = ?
       tel_cdbccxpg = 0
       tel_cdhistor = 0
       tel_nrdconta = 0
       tel_nrborder = 0.

HIDE FRAME f_lote.
HIDE FRAME f_moldura.

RETURN.

/* .......................................................................... */

