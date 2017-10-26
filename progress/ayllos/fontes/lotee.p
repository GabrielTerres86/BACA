/* .............................................................................

   Programa: Fontes/lotee.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Outubro/91.                         Ultima atualizacao: 26/10/2017

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de exclusao da tela LOTE.

   Alteracoes: 22/06/94 - Alterado para permitir utilizar a taxa do mes na li-
                          quidacao do emprestimo (Edson).

               07/11/94 - Alterado para tratar crapneg na exclusao do lote de
                          limite de credito, tplotmov = 7 (Deborah).

               16/11/94 - Alterado para incluir o campo dtfimest na gravacao do
                          crapneg (valor inicial ?) (Odair).

               05/12/94 - Incluida a rotina de exclusao do lote tipo 10 e 11
                          (Deborah).

               29/05/95 - Alterado para nao mostrar a data do debito (Deborah).

               19/06/95 - Alterado para tratar exclusao de lote tipo 12 (Odair).

               15/12/95 - Alterado para tratar exclusao de lote tipo 13 (Odair).

               19/03/96 - Alterado para tratar exclusao de lote 14 (Odair).

               12/08/96 - Alterado para tratar historico com debito na folha
                          de pagamento (Edson).

               27/08/96 - Alterado para tratar data dos aviso dos historicos
                          para debito em folha - tipo de lote 12 (Deborah).

               09/12/96 - Tratar tplotmov = 15 (Odair).

               17/03/97 - Tratar tplotmov = 16 Cartao de Credito (Odair).

               10/04/97 - Tratar tplotmov = 17 Lancamentos Credicard (Odair)

               17/07/97 - Exclusao lote 12 tratar emp.tpconven (Odair)

               15/08/97 - Estouro de 63 K (Odair).

               02/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               06/07/98 - Substituida a rotina fontes/exclote125.p por
                          fontes/lotee_1.p (Edson).

               19/11/98 - Tratar craplft.vlfatura para vllanmto (Odair)

               07/04/2000 - Tratar exclusao do tipo de lote 19 - Cheques em
                            Custodia (Edson).

               03/05/2000 - Tratar exclusao do tipo de lote 20 - Titulos   
                            compensaveis (Edson).

               05/01/2001 - Tratar tipo de lote 21 (Deborah).
               
               22/01/2001 - Acerto na rotina de exclusao do tipo 15. (Eduardo).
               
               08/05/2001 - Tratamento da Compensacao Eletronica (Margarete).

               24/01/2002 - Nao excluir os lotes 10001 e 10002 (Margarete).
               
               16/05/2002 - Tratar novos historicos do prejuizo (Margarete).
               
               13/09/2002 - Incluir tipo de lote para DOC e TED (Margarete).

               19/03/2003 - Incluir tratamento da Concredi (Margarete).

               24/01/2002 - Nao excluir o lote 10003 (Edson).
 
               22/09/2003 - Nao deixa excluir lote associado (Margarete).

               10/02/2004 - Efetuado controle por PAC(tabelas horario 
                            compel/titulo) (Mirtes)
                            
               01/03/2004 - Alterado para NAO pertimir a exclusao de lotes de
                            desconto de cheques quando o bordero estiver 
                            liberado (Edson).

               05/04/2004 - Tratar exclusao do tipo de lote 26 - Desconto de
                            Cheques (Edson).
                            
               29/06/2004 - Ler crapavl com tpdcontr = 1 (Emprestimo) e Prever
                            Nro Conta Avalista Zerada(Mirtes)           
                 
               17/09/2004 - Prever exclusao tplotmov 29(Conta Inv.)(Mirtes) 
                            Nao permitir excluir lotes 10004/10005/10006
                            10104/10105/10106                            

               03/02/2005 - Permitir transferencia entre Contas de Invest.
                            (Mirtes/Evandro).

               04/07/2005 - Alimentado campo cdcooper da tabela crapsli (Diego).

               30/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
               
               13/10/2006 - Criado arquivo de log quando excluido um lote
                            (Elton).

               02/02/2007 - Exclusao do lote tipo 18, nao estava excluindo
                            lancamento de cobranca quando havia mais de um
                            crapcob com mesmo numero de documento (Julio).
                            
               17/07/2007 - Exclusao do lote tipo 9 nao estava excluindo
                            lancamento de aplicacoes RDC (David).
                            
               13/05/2008 - Ajuste comando FIND(craphis) utilizava FOR p/ acesso
                            (Sidnei - Precise)
                            
               01/09/2008 - Alteracao CDEMPRES (Kbase).
               
               12/09/2008 - Alterado campo crapcob.cdbccxlt -> crapcob.cdbandoc
                            (Diego).
                            
               15/01/2009 - Alteracao cdempres (Diego).
               
               20/05/2009 - Alteracao CDOPERAD (Kbase).
               
               18/02/2010 - Voltar atras os Ratings quando excluido o lote
                            tipo 4 (Emprestimo) (Gabriel).
                            
               08/04/2010 - Nao permitir excluir lotes de seguro (Gabriel).    
               
               16/04/2010 - Pedir senha quando o lote a ser excluido tiver
                            um lancamento com historico flgsenha.
                            Desabilitar exclusao dos lotes de poupanca,
                            pois elas sao criadas automaticamente a partir
                            de agora (Gabriel).      
                            
               19/05/2010 - Desativar Rating quando liquidado o emprestimo
                            (Gabriel).                
                            
               17/08/2011 - Criado condicao para nao permitir a exclusao do lote
                            7999 (Adriano).             
                            
               30/11/2011 - Tratamento exclusao de lotes ref.
                            Deposito/Transferencia Intercooperativa  (Diego).
                            
               05/06/2013 - Adicionados valores de multa e juros ao valor total
                            das faturas, para DARFs (Lucas).
               
               14/08/2013 - Nova forma de chamar as agencias, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               16/12/2013 - Inclusao de VALIDATE crapsli (Carlos)
               
               18/06/2014 - Exclusao da chamada da lotee_7 que sera excluida.
                            (Tiago Castro - Tiago RKAM)
                            
               04/02/2015 - Ajuste na exclusao do lote para o contrato em 
                            prejuizo do tipo PP. (Oscar/James)
                            
               30/04/2015 - Incluir a crapavl ja na proposta. Aqui nao e'
                            mais necessario deletar.             

               12/04/2016 - Adicionado tratamento para nao excluir o lote 7050 e 6400
                            exclusivo do sistema para debito automatico de 
                            convenios (Douglas - Chamado 379146)

               27/06/2016 - Se o departamento nao for TI ou SUPORTE, nao deixar
			                deletar tipo de lote 26 (Tiago/Elton SD438123).

               28/07/2016 - Permitido exclusao a todos operadores (Tiago/Elton).
               
               16/08/2016 - Corrigir problema na exclusao do lote, pois nao pode ser 
                            alterado o INLIQUID quando o lote é excluído.
                          + Controlar o preenchimento da data de pagamento do prejuízo,
                            voltando o prejuizo antes da liquidaçao. (Renato Darosci - M176)
                          
               23/09/2016 - Inclusao de validacao de contratos de acordos, Prj. 302 (Jean Michel).             
                          
               05/12/2016 - Alterado campo dsdepart para cddepart.
                            PRJ341 - BANCENJUD (Odirlei-AMcom) 
               
               07/02/2017 - Incluir LEAVE TRANS_E para a critica 650 da leitura crablem pois mesmo 
                            com critica estava atualizando o lote (Lucas Ranghetti #570922)
                          
               14/02/2017 - Alteracao para chamar pc_verifica_situacao_acordo. 
                            (Jaison/James - PRJ302)
			   
			   26/10/2017 - Remocao do IF que nao permitia passar o inliquid para 0 dos contratos
							removidos de prejuizo através da tela LOTE, conforme solicitado no
							chamado 745969. (Kelvin)
............................................................................. */

DEF BUFFER crabseg FOR crapseg.
DEF BUFFER crablot FOR craplot.

DEF    VAR aux_dtmvtolt AS DATE                                         NO-UNDO.
DEF    VAR aux_nrdocmto AS INT                                          NO-UNDO.
DEF    VAR aux_nrctrseg AS INT                                          NO-UNDO.
DEF    VAR aux_flgcompe AS LOG                                          NO-UNDO.
DEF    VAR aux_dtrefere AS DATE                                         NO-UNDO.
DEF    VAR aux_cdempres AS INT                                          NO-UNDO.
DEF    VAR aux_flgsenha AS LOGI                                         NO-UNDO.

DEF    VAR aux_nrdcont2 AS INTE                                         NO-UNDO.
DEF    VAR aux_nrctrem2 AS INTE                                         NO-UNDO.

DEF    VAR par_nsenhaok AS LOGI                                         NO-UNDO.
DEF    VAR par_cdoperad AS CHAR                                         NO-UNDO.
DEF    VAR par_nrdrowid AS ROWID                                        NO-UNDO.

DEF    VAR h-b1wgen0030 AS HANDLE                                       NO-UNDO.
DEF    VAR h-b1wgen0043 AS HANDLE                                       NO-UNDO.

DEF    VAR aux_vlrsaldo AS DEC                                          NO-UNDO.
DEF    VAR aux_vlrabono AS DEC                                          NO-UNDO.
DEF    VAR aux_vlpgsmmo AS DEC                                          NO-UNDO.
DEF    VAR aux_sldmulta AS DEC                                          NO-UNDO.
DEF    VAR aux_sldjmora AS DEC                                          NO-UNDO.
DEF    VAR aux_vlrpagos AS DECIMAL                                      NO-UNDO.

DEF    VAR aux_flgretativo   AS INTEGER                                 NO-UNDO.
DEF    VAR aux_flgretquitado AS INTEGER                                 NO-UNDO.

{ includes/var_online.i } 
{ sistema/generico/includes/var_oracle.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_lote.i }

ASSIGN par_situacao = FALSE
       par_qtexclln = 0
       par_vlexcldb = 0
       par_vlexclcr = 0.
                               
IF   tel_nrdolote > 7099   AND     /* Transf. de cheque salario para vala */
     tel_nrdolote < 7200   THEN
     DO:
         glb_cdcritic = 261.
         CLEAR FRAME f_lote NO-PAUSE.
         NEXT.
     END.

IF   tel_nrdolote = 4500   OR                 /*  Lote de custodia / titulos  */
     tel_nrdolote = 8477   THEN               /*  Lote de desconto de chqs    */
     DO:
         glb_cdcritic = 650.
         CLEAR FRAME f_lote NO-PAUSE.         /*  NAO PODE SER EXCLUIDO  */
         NEXT.
     END.

IF   tel_nrdolote = 10001   OR
     tel_nrdolote = 10002   OR
     tel_nrdolote = 10003   OR
   
     tel_nrdolote = 10004   OR       /* Incluido em 17/09/2004 - Contas inv.*/
     tel_nrdolote = 10005   OR
     tel_nrdolote = 10006   OR
     tel_nrdolote = 10104   OR
     tel_nrdolote = 10105   OR
     tel_nrdolote = 10106 THEN  
     DO:
         ASSIGN glb_cdcritic = 650.
         CLEAR FRAME f_lote NO-PAUSE.
         NEXT.
     END.

/*** Nao permitir excluir lotes gerados pelo caixa ***/
IF   tel_nrdolote >= 11000   AND
     tel_nrdolote <= 29999   THEN
     DO:
         ASSIGN glb_cdcritic = 650.
         CLEAR FRAME f_lote NO-PAUSE.
         NEXT.
     END.

/*** Nao permitir a exclusao do lote utilizado para tarifacao de DOC/TED ***/
IF tel_nrdolote = 7999 THEN
   DO:
      ASSIGN glb_cdcritic = 650.
      CLEAR FRAME f_lote NO-PAUSE.
      NEXT.
    
   END.

IF   tel_nrdolote = 10115 OR  /*TED/TEC*/ 
     tel_nrdolote = 10118 OR  /*Credito Dep. Intercoop*/
     tel_nrdolote = 10119 OR  /*Deb. Tarfia Trf. Intercoop*/
     tel_nrdolote = 10120 THEN  /*Credito Trf. Intercoop.*/
     DO:
         ASSIGN glb_cdcritic = 650.
         CLEAR FRAME f_lote NO-PAUSE.
         NEXT.
     END.


/*  Nao permite a exclusao de lotes vinculados a folha de pagamento  */

IF  (tel_nrdolote >  9010   AND     /*  Folha de pagamento  */
     tel_nrdolote <= 9999)  OR
    (tel_nrdolote >  8010   AND     /*  Cotas  */
     tel_nrdolote <= 8999)  OR
    (tel_nrdolote >  5010   AND     /*  Emprestimos  */
     tel_nrdolote <= 5999)  THEN
     DO:
         IF   glb_cddepart = 20 /* TI */  THEN
              DO:
                  aux_confirma = "N".
                  BELL.
                  
                  MESSAGE "ESTE LOTE E' DE VINCULADO A FOLHA DE PAGAMENTO!".
                  MESSAGE "CONFIRMA A OPERACAO (S/N)?" UPDATE aux_confirma.
                  
                  IF   aux_confirma <> "S"   THEN
                       DO:
                           HIDE MESSAGE NO-PAUSE.
                           MESSAGE "Operacao nao efetuada!".
                           NEXT.
                       END.
              END.
         ELSE
              DO:
                  glb_cdcritic = 650.
                  CLEAR FRAME f_lote NO-PAUSE.
                  NEXT.
              END.
     END.
     
IF   tel_nrdolote = 7050 OR   /*  Lote Debito Automatico de Convenios CECRED  */
     tel_nrdolote = 6400 THEN /*  Lote Debito Automatico de Convenios SICREDI */
     DO:
         glb_cdcritic = 650.
         CLEAR FRAME f_lote NO-PAUSE. /*  NAO PODE SER EXCLUIDO  */
         NEXT.
     END.
     
     
TRANS_E:

DO TRANSACTION ON ERROR UNDO TRANS_E, NEXT:

   DO aux_contador = 1 TO 10:

      FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                         craplot.dtmvtolt = tel_dtmvtolt   AND
                         craplot.cdagenci = tel_cdagenci   AND
                         craplot.cdbccxlt = tel_cdbccxlt   AND
                         craplot.nrdolote = tel_nrdolote
                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

      IF   NOT AVAILABLE craplot   THEN
           IF   LOCKED craplot   THEN
                DO:
                    glb_cdcritic = 84.
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                END.
           ELSE
                DO:
                    glb_cdcritic = 60.
                    CLEAR FRAME f_lote.
                END.
      ELSE
      IF   craplot.tplotmov = 15   THEN /* Lote de seguro (antiga LANSEG) */
           glb_cdcritic = 650.
      ELSE
      IF   craplot.tplotmov = 14   THEN
           glb_cdcritic = 650.         /* Lote de poupanca (antiga LANPPR) */
      ELSE
           glb_cdcritic = 0.

      LEAVE.

   END.  /*  Fim do DO .. TO  */

   IF   glb_cdcritic > 0   THEN
        NEXT.

   ASSIGN tel_qtinfoln = craplot.qtinfoln
          tel_vlinfodb = craplot.vlinfodb
          tel_vlinfocr = craplot.vlinfocr
          tel_qtcompln = craplot.qtcompln
          tel_vlcompdb = craplot.vlcompdb
          tel_vlcompcr = craplot.vlcompcr
          tel_tplotmov = craplot.tplotmov
          tel_dtmvtopg = craplot.dtmvtopg

          tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
          tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
          tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr.

   DISPLAY tel_dtmvtolt tel_qtinfoln tel_qtcompln tel_qtdifeln
           tel_vlinfodb tel_vlcompdb tel_vldifedb tel_vlinfocr
           tel_vlcompcr tel_vldifecr tel_tplotmov
           WITH FRAME f_lote.

   PAUSE 0.
   
   IF   craplot.tplotmov = 19   OR
       (craplot.tplotmov = 20  AND  craplot.dtmvtopg <> ?)   THEN
        DISPLAY tel_dtmvtopg WITH FRAME f_data_custodia.
   
   /** Nao deixar excluir lote associado **/
   IF   craplot.cdopecxa <> ""   AND  
        craplot.nrautdoc <> 0    THEN
        DO:
            ASSIGN glb_cdcritic = 750.
            NEXT.
        END.

   IF   tel_tplotmov = 26   THEN                     /*  Desconto de cheques  */
        DO:
            FIND crapbdc WHERE crapbdc.cdcooper = glb_cdcooper AND
                               crapbdc.nrborder = craplot.cdhistor 
                               NO-LOCK NO-ERROR.
      
            IF   NOT AVAILABLE crapbdc   THEN
            DO:
                MESSAGE "Boletim nao encontrado.".
                 RETURN.
            END.
 
            IF   crapbdc.insitbdc > 2   THEN 
                 DO:
                     MESSAGE "Boletim ja LIBERADO.".
                     glb_cdcritic = 79.
                     NEXT.
                 END.
        END.
   
   /*  Verifica de pode excluir o lote de titulos compensaveis do dia  */
   
   IF   craplot.cdbccxlt = 11   AND   craplot.tplotmov = 20   THEN
        DO:
            /*  Verifica a hora somente para a arrecadacao caixa  */

            /*  Tabela com o horario limite para digitacao  */

            FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                               craptab.nmsistem = "CRED"        AND
                               craptab.tptabela = "GENERI"      AND
                               craptab.cdempres = 0             AND
                               craptab.cdacesso = "HRTRTITULO"  AND
                               craptab.tpregist = tel_cdagenci 
                               NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE craptab   THEN
                 DO:
                     glb_cdcritic = 55.
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

   /*** Tratamento da Compensacao Eletronica  e Senha Historico ***/
   ASSIGN aux_flgcompe = NO
          aux_flgsenha = NO.       

   IF   craplot.tplotmov = 1   THEN
        DO:
            FOR EACH craplcm WHERE craplcm.cdcooper = glb_cdcooper       AND
                                   craplcm.dtmvtolt = glb_dtmvtolt       AND
                                   craplcm.cdagenci = craplot.cdagenci   AND
                                   craplcm.cdbccxlt = craplot.cdbccxlt   AND
                                   craplcm.nrdolote = craplot.nrdolote
                                   USE-INDEX craplcm1 NO-LOCK,

                FIRST craphis WHERE craphis.cdcooper = craplcm.cdcooper  AND
                                    craphis.cdhistor = craplcm.cdhistor  NO-LOCK:
                                   
                IF    aux_flgsenha   AND
                      aux_flgcompe   THEN
                      LEAVE.

                IF   craplcm.cdhistor = 3   OR
                     craplcm.cdhistor = 4   OR
                     craplcm.cdhistor = 372 THEN
                     ASSIGN aux_flgcompe = YES.
                     
                IF   craphis.flgsenha      THEN
                     ASSIGN aux_flgsenha = YES.

            END.

        END.

   IF   craplot.tplotmov = 23   OR
        craplot.tplotmov = 24   OR
        craplot.tplotmov = 25   OR
        aux_flgcompe            THEN
        DO:
            /*  Verifica o horario de corte  */

            FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                               craptab.nmsistem = "CRED"         AND
                               craptab.tptabela = "GENERI"       AND
                               craptab.cdempres = 0              AND
                               craptab.cdacesso = "HRTRCOMPEL"   AND
                               craptab.tpregist = tel_cdagenci
                               NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE craptab   THEN
                 ASSIGN glb_cdcritic = 676.
            ELSE
                 IF   INT(SUBSTR(craptab.dstextab,1,1)) <> 0   THEN
                      ASSIGN glb_cdcritic = 677.
                 ELSE                 
                      IF   INT(SUBSTR(craptab.dstextab,3,5)) <= TIME   THEN
                           ASSIGN glb_cdcritic = 676.

            IF   glb_cdcritic <> 0   THEN
                 NEXT.
        END. 
               
   /* Confirmaçao dos dados */
   RUN fontes/confirma.p (INPUT "",
                          OUTPUT aux_confirma).

   IF   aux_confirma <> "S"   THEN
        NEXT.

    /* Precisa de senha do supervisor */
   IF   aux_flgsenha   THEN
        DO:
             RUN fontes/pedesenha.p (INPUT glb_cdcooper,
                                     INPUT 2, /* Nivel operador */
                                     OUTPUT par_nsenhaok,
                                     OUTPUT par_cdoperad).

             IF   NOT par_nsenhaok   THEN
                  NEXT.

        END.

   ASSIGN par_situacao = FALSE
          glb_cdcritic = 0.

   IF   craplot.tplotmov = 1   THEN
        DO:
            /* Enviar o Supervisor que autorizou ( par_cdoperad ) */
            RUN fontes/lotee_1.p (INPUT craplot.cdagenci,
                                  INPUT craplot.cdbccxlt,
                                  INPUT craplot.nrdolote,
                                  INPUT aux_lsconta1,
                                  INPUT aux_lsconta3,
                                  INPUT par_cdoperad,
                                  OUTPUT par_situacao, OUTPUT par_qtexclln,
                                  OUTPUT par_vlexcldb, OUTPUT par_vlexclcr).

            IF   RETURN-VALUE = "NOK"   THEN
                 UNDO TRANS_E, LEAVE.

        END.
   ELSE
   IF   craplot.tplotmov = 2   THEN
        DO:
            DO WHILE TRUE:

               DO  aux_contador = 1 TO 20:

                   FIND FIRST craplct WHERE
                              craplct.cdcooper = glb_cdcooper       AND
                              craplct.dtmvtolt = glb_dtmvtolt       AND
                              craplct.cdagenci = craplot.cdagenci   AND
                              craplct.cdbccxlt = craplot.cdbccxlt   AND
                              craplct.nrdolote = craplot.nrdolote
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                   IF   NOT AVAILABLE craplct   THEN
                        IF   LOCKED craplct   THEN
                             DO:
                                 ASSIGN glb_cdcritic = 85
                                        par_situacao = FALSE.
                                 PAUSE 1 NO-MESSAGE.
                                 NEXT.
                             END.
                        ELSE
                             DO:
                                 par_situacao = TRUE.
                                 LEAVE. /* Sai quando nao ha mais lancamentos */
                             END.

                   FIND crapcot WHERE crapcot.cdcooper = glb_cdcooper AND
                                      crapcot.nrdconta = craplct.nrdconta
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                   IF   NOT AVAILABLE crapcot   THEN
                        IF   LOCKED crapcot   THEN
                             DO:
                                 ASSIGN glb_cdcritic = 85
                                        par_situacao = FALSE.
                                 PAUSE 1 NO-MESSAGE.
                                 NEXT.
                             END.
                        ELSE
                             DO:
                                 ASSIGN glb_cdcritic = 169
                                        par_situacao = FALSE.
                                 LEAVE.
                             END.

                   FIND craphis WHERE craphis.cdhistor = craplct.cdhistor AND
                                      craphis.cdcooper = craplct.cdcooper
                                      NO-LOCK NO-ERROR.

                   IF   NOT AVAILABLE craphis   THEN
                        DO:
                            ASSIGN glb_cdcritic = 83
                                   par_situacao = FALSE.
                            LEAVE.
                        END.

                   IF   craphis.inhistor = 6   THEN
                        IF  (crapcot.vldcotas - craplct.vllanmto) < 0   THEN
                             DO:
                                 ASSIGN glb_cdcritic = 203
                                        par_situacao = FALSE.
                                 LEAVE.
                             END.
                        ELSE
                             crapcot.vldcotas = crapcot.vldcotas -
                                                        craplct.vllanmto.
                   ELSE
                   IF   craphis.inhistor = 16   THEN
                        crapcot.vldcotas = crapcot.vldcotas + craplct.vllanmto.
                   ELSE
                   IF   NOT CAN-DO("7,8,17,18",STRING(craphis.inhistor))   THEN
                        DO:
                            ASSIGN glb_cdcritic = 214
                                   par_situacao = FALSE.
                            LEAVE.
                        END.

                   ASSIGN par_qtexclln = par_qtexclln + 1
                          par_vlexclcr = par_vlexclcr + craplct.vllanmto

                          aux_contador = 0.

                   DELETE craplct.
                   LEAVE.

               END.  /*  Fim do DO .. TO  */

               IF   par_situacao   THEN
                    LEAVE.

               IF   aux_contador <> 0   THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        LEAVE.
                    END.

            END.  /*  Fim do DO WHILE TRUE  */
        END.
   ELSE
   IF   craplot.tplotmov = 3   THEN
        DO:
            DO WHILE TRUE:

               DO  aux_contador = 1 TO 20:

                   FIND FIRST craplct WHERE
                              craplct.cdcooper = glb_cdcooper       AND
                              craplct.dtmvtolt = glb_dtmvtolt       AND
                              craplct.cdagenci = craplot.cdagenci   AND
                              craplct.cdbccxlt = craplot.cdbccxlt   AND
                              craplct.nrdolote = craplot.nrdolote
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                   IF   NOT AVAILABLE craplct   THEN
                        IF   LOCKED craplct   THEN
                             DO:
                                 ASSIGN glb_cdcritic = 85
                                        par_situacao = FALSE.
                                 PAUSE 1 NO-MESSAGE.
                                 NEXT.
                             END.
                        ELSE
                             DO:
                                 par_situacao = TRUE.
                                 LEAVE. /* Sai quando nao ha mais lancamentos */
                             END.

                   FIND crapcot WHERE crapcot.cdcooper = glb_cdcooper      AND
                                      crapcot.nrdconta = craplct.nrdconta
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                   IF   NOT AVAILABLE crapcot   THEN
                        IF   LOCKED crapcot   THEN
                             DO:
                                 ASSIGN glb_cdcritic = 85
                                        par_situacao = FALSE.
                                 PAUSE 1 NO-MESSAGE.
                                 NEXT.
                             END.
                        ELSE
                             DO:
                                 ASSIGN glb_cdcritic = 169
                                        par_situacao = FALSE.
                                 LEAVE.
                             END.

                   FIND FIRST crappla WHERE
                              crappla.cdcooper = glb_cdcooper       AND
                              crappla.nrdconta = craplct.nrdconta   AND
                              crappla.tpdplano = 1                  AND
                              crappla.cdsitpla = 1
                              USE-INDEX crappla3
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                   IF   NOT AVAILABLE crappla   THEN
                        IF   LOCKED crappla   THEN
                             DO:
                                 ASSIGN glb_cdcritic = 85
                                        par_situacao = FALSE.
                                 PAUSE 1 NO-MESSAGE.
                                 NEXT.
                             END.
                        ELSE
                             DO:
                                 ASSIGN glb_cdcritic = 200
                                        par_situacao = FALSE.
                                 LEAVE.
                             END.
                   ELSE
                        IF   crappla.vlprepla <> craplct.vllanmto   OR
                             crappla.vlpagmes <  craplct.vllanmto   THEN
                             DO:
                                 ASSIGN glb_cdcritic = 91
                                        par_situacao = FALSE.
                                 LEAVE.
                             END.

                   IF  (crapcot.vldcotas - craplct.vllanmto) < 0   THEN
                        DO:
                            ASSIGN glb_cdcritic = 203
                                   par_situacao = FALSE.
                            LEAVE.
                        END.
                   ELSE
                        ASSIGN crapcot.vldcotas = crapcot.vldcotas -
                                                  craplct.vllanmto
                               crapcot.qtprpgpl = crapcot.qtprpgpl - 1.

                   ASSIGN crappla.qtprepag = crappla.qtprepag - 1
                          crappla.vlprepag = crappla.vlprepag - craplct.vllanmto
                          crappla.vlpagmes = crappla.vlpagmes - craplct.vllanmto
                          crappla.dtultpag = 01/01/0001

                          par_qtexclln     = par_qtexclln + 1
                          par_vlexclcr     = par_vlexclcr + craplct.vllanmto

                          aux_contador     = 0.

                   DELETE craplct.
                   LEAVE.
               END.

               IF   par_situacao   THEN
                    LEAVE.

               IF   aux_contador <> 0   THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        LEAVE.
                    END.
            END.
        END.
   ELSE
   IF   craplot.tplotmov = 4   THEN
        DO:
            DO WHILE TRUE:

               DO aux_contador = 1 TO 20:

                  FIND FIRST crapepr WHERE crapepr.cdcooper = glb_cdcooper   AND
                                           crapepr.dtmvtolt = tel_dtmvtolt   AND
                                           crapepr.cdagenci = tel_cdagenci   AND
                                           crapepr.cdbccxlt = tel_cdbccxlt   AND
                                           crapepr.nrdolote = tel_nrdolote
                                           USE-INDEX crapepr1
                                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.


                  IF   NOT AVAILABLE crapepr   THEN
                       IF   LOCKED crapepr   THEN
                            DO:
                                ASSIGN glb_cdcritic = 85
                                       par_situacao = FALSE.
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                       ELSE
                            DO:
                                par_situacao = TRUE.
                                LEAVE.           /*  Nao ha mais lancamentos  */
                            END.

               END.  /*  Fim do DO .. TO  */

               IF   par_situacao   THEN
                    LEAVE.

               IF   glb_cdcritic > 0   THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        LEAVE.
                    END.

               FIND FIRST craplem WHERE craplem.cdcooper = glb_cdcooper      AND
                                        craplem.nrdconta = crapepr.nrdconta  AND
                                        craplem.nrctremp = crapepr.nrctremp  AND
                                        craplem.dtmvtolt = crapepr.dtmvtolt  AND
                                        craplem.cdhistor <> 99
                                        NO-LOCK NO-ERROR.

               IF   AVAILABLE craplem   THEN
                    DO:
                        ASSIGN glb_cdcritic = 368
                               par_situacao = FALSE.

                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        LEAVE.
                    END.

               /*  Le registro do lancamento do contrato  */

               DO aux_contador = 1 TO 20:

                  FIND craplem WHERE craplem.cdcooper = glb_cdcooper       AND
                                     craplem.dtmvtolt = crapepr.dtmvtolt   AND
                                     craplem.cdagenci = crapepr.cdagenci   AND
                                     craplem.cdbccxlt = crapepr.cdbccxlt   AND
                                     craplem.nrdolote = crapepr.nrdolote   AND
                                     craplem.nrdconta = crapepr.nrdconta   AND
                                     craplem.nrdocmto = crapepr.nrctremp   AND
                                     craplem.cdhistor = 99
                                     USE-INDEX craplem1
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                  IF   NOT AVAILABLE craplem   THEN
                       IF   LOCKED craplem   THEN
                            DO:
                                ASSIGN glb_cdcritic = 85
                                       par_situacao = FALSE.
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                       ELSE .
                  ELSE
                       DO:
                           DELETE craplem.
                           glb_cdcritic = 0.
                       END.

                  LEAVE.

               END.  /*  Fim do DO .. TO  */

               IF   glb_cdcritic > 0   THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        LEAVE.
                    END.

               ASSIGN aux_contador = 0
                      par_qtexclln = par_qtexclln + 1
                      par_vlexcldb = par_vlexcldb + crapepr.vlemprst.
  
               ASSIGN aux_nrdcont2 = crapepr.nrdconta
                      aux_nrctrem2 = crapepr.nrctremp.
               
               DELETE crapepr.

               RUN sistema/generico/procedures/b1wgen0043.p
                           PERSISTENT SET h-b1wgen0043.

               RUN volta-atras-rating IN h-b1wgen0043 
                                         (INPUT glb_cdcooper,
                                          INPUT 0,
                                          INPUT 0,
                                          INPUT glb_cdoperad,
                                          INPUT glb_dtmvtolt,
                                          INPUT glb_dtmvtopr,
                                          INPUT aux_nrdcont2,
                                          INPUT 90, /* Emprestimo*/
                                          INPUT aux_nrctrem2,
                                          INPUT 1,
                                          INPUT 1,
                                          INPUT glb_nmdatela,
                                          INPUT glb_inproces,
                                          INPUT FALSE,
                                          OUTPUT TABLE tt-erro).

               DELETE PROCEDURE h-b1wgen0043.

               IF   RETURN-VALUE <> "OK"   THEN
                    DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.

                        IF   AVAIL tt-erro   THEN
                             DO:
                                 MESSAGE tt-erro.dscritic.
                                 LEAVE.
                             END.                               
                    END.
                                   
            END.  /*  Fim do DO WHILE TRUE  */
        END.
   ELSE
   IF   craplot.tplotmov = 5   THEN
        DO:
            DO WHILE TRUE:
  
               DO  aux_contador = 1 TO 20:

                   FIND FIRST crablem WHERE
                              crablem.cdcooper = glb_cdcooper       AND
                              crablem.dtmvtolt = glb_dtmvtolt       AND
                              crablem.cdagenci = craplot.cdagenci   AND
                              crablem.cdbccxlt = craplot.cdbccxlt   AND
                              crablem.nrdolote = craplot.nrdolote
                              USE-INDEX craplem1
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                   IF   NOT AVAILABLE crablem   THEN
                        IF   LOCKED crablem   THEN
                             DO:
                                 ASSIGN glb_cdcritic = 85
                                        par_situacao = FALSE.
                                 PAUSE 1 NO-MESSAGE.
                                 NEXT.
                             END.
                        ELSE
                             DO:
                                 par_situacao = TRUE.
                                 LEAVE. /* Sai quando nao ha mais lancamentos */
                             END.

                   FIND craphis NO-LOCK WHERE 
                                craphis.cdcooper = crablem.cdcooper AND 
                                craphis.cdhistor = crablem.cdhistor NO-ERROR.
   
                   IF   NOT AVAILABLE craphis   THEN
                        DO:
                            glb_cdcritic = 80.
                            par_situacao = FALSE.
                            LEAVE.
                        END.

                   DO WHILE TRUE:

                      FIND crapepr WHERE crapepr.cdcooper = glb_cdcooper     AND
                                         crapepr.nrdconta = crablem.nrdconta AND
                                         crapepr.nrctremp = crablem.nrctremp
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                      IF   NOT AVAILABLE crapepr   THEN
                           IF   LOCKED crapepr   THEN
                                DO:
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                           ELSE
                                glb_cdcritic = 356.

                      LEAVE.

                   END.  /*  Fim do DO WHILE TRUE  */

                   IF   glb_cdcritic > 0   THEN
                        DO:
                            par_situacao = FALSE.
                            LEAVE.
                        END.
                  
                   /* Verifica se ha contratos de acordo */            
                  { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                  
                  RUN STORED-PROCEDURE pc_verifica_situacao_acordo
                    aux_handproc = PROC-HANDLE NO-ERROR (INPUT glb_cdcooper    
                                                        ,INPUT crapepr.nrdconta
                                                        ,INPUT crapepr.nrctremp
														,INPUT 3
                                                        ,0 /* pr_flgretativo */
                                                        ,0 /* pr_flgretquitado */
                                                        ,0 /* pr_flgretcancelado */
                                                        ,0
                                                        ,"").

                  CLOSE STORED-PROC pc_verifica_situacao_acordo
                            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                  { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                  ASSIGN glb_cdcritic      = 0
                         glb_dscritic      = ""
                         glb_cdcritic      = pc_verifica_situacao_acordo.pr_cdcritic WHEN pc_verifica_situacao_acordo.pr_cdcritic <> ?
                         glb_dscritic      = pc_verifica_situacao_acordo.pr_dscritic WHEN pc_verifica_situacao_acordo.pr_dscritic <> ?
                         aux_flgretativo   = INT(pc_verifica_situacao_acordo.pr_flgretativo)
                         aux_flgretquitado = INT(pc_verifica_situacao_acordo.pr_flgretquitado).
                  
                  IF glb_cdcritic > 0 THEN
                    DO:
						RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        ASSIGN glb_cdcritic = 0
                            par_situacao = FALSE.
                            LEAVE.
                        END.
                  ELSE IF glb_dscritic <> ? AND glb_dscritic <> "" THEN
                    DO:
					  MESSAGE glb_dscritic.
                      ASSIGN glb_cdcritic = 0
                            par_situacao = FALSE.
                            LEAVE.
                        END.
                    
                  /* Se estiver ATIVO ou QUITADO */
                  IF aux_flgretativo = 1 OR aux_flgretquitado = 1 THEN
                    DO:
					  ASSIGN par_situacao = FALSE.
                      MESSAGE "Nao e possivel excluir o lote, contem lancamentos de emprestimo em acordo.".
                      PAUSE 3 NO-MESSAGE.
                      LEAVE.
                    END.            

                  /* Fim verifica se ha contratos de acordo */   

                   FIND crapass WHERE crapass.cdcooper = glb_cdcooper       AND
                                      crapass.nrdconta = crapepr.nrdconta
                                      NO-LOCK NO-ERROR.
                   
                   IF  AVAILABLE crapass   THEN
                       DO:
                           IF  crapass.inpessoa = 1   THEN 
                               DO:
                                   FIND crapttl WHERE 
                                        crapttl.cdcooper = glb_cdcooper     AND
                                        crapttl.nrdconta = crapass.nrdconta AND
                                        crapttl.idseqttl = 1 NO-LOCK NO-ERROR.
                                        
                                   IF   AVAIL crapttl  THEN
                                        ASSIGN aux_cdempres = crapttl.cdempres.
                               END.
                           ELSE
                               DO:
                                   FIND crapjur WHERE 
                                        crapjur.cdcooper = glb_cdcooper  AND
                                        crapjur.nrdconta = crapass.nrdconta
                                        NO-LOCK NO-ERROR.
                            
                                   IF   AVAIL crapjur  THEN
                                        ASSIGN aux_cdempres = crapjur.cdempres.
                               END.
                       END.

                   IF   NOT AVAILABLE crapass   THEN
                        DO:
                            glb_cdcritic = 251.
                            par_situacao = FALSE.
                            LEAVE.
                        END.

                   /*  Leitura do dia do pagamento da empresa  */

                   FIND craptab WHERE craptab.cdcooper = glb_cdcooper      AND
                                      craptab.nmsistem = "CRED"            AND
                                      craptab.tptabela = "GENERI"          AND
                                      craptab.cdempres = 00                AND
                                      craptab.cdacesso = "DIADOPAGTO"      AND
                                      craptab.tpregist = aux_cdempres
                                      NO-LOCK NO-ERROR.

                   IF   NOT AVAILABLE craptab   THEN
                        DO:
                            glb_cdcritic = 55.
                            RUN fontes/critic.p.
                            BELL.
                            MESSAGE glb_dscritic "DIA DO PAGTO DA EMPRESA"
                                    aux_cdempres.
                            glb_cdcritic = 0.
                            par_situacao = FALSE.
                            LEAVE.
                        END.

                   IF   CAN-DO("1,3,4",STRING(crapass.cdtipsfx))   THEN
                        tab_diapagto = INTEGER(SUBSTRING(craptab.dstextab,4,2)).
                   ELSE
                        tab_diapagto = INTEGER(SUBSTRING(craptab.dstextab,7,2)).

                   /*  Verifica se a data do pagamento da
                       empresa cai num dia util  */

                   tab_dtcalcul = DATE(MONTH(glb_dtmvtolt),tab_diapagto,
                                        YEAR(glb_dtmvtolt)).

                   DO WHILE TRUE:

                      IF   WEEKDAY(tab_dtcalcul) = 1   OR
                           WEEKDAY(tab_dtcalcul) = 7   THEN
                           DO:
                               tab_dtcalcul = tab_dtcalcul + 1.
                               NEXT.
                           END.

                      FIND crapfer WHERE crapfer.cdcooper = glb_cdcooper  AND
                                         crapfer.dtferiad = tab_dtcalcul
                                         NO-LOCK NO-ERROR.

                      IF   AVAILABLE crapfer   THEN
                           DO:
                               tab_dtcalcul = tab_dtcalcul + 1.
                               NEXT.
                           END.

                      tab_diapagto = DAY(tab_dtcalcul).

                      LEAVE.

                   END.  /*  Fim do DO WHILE TRUE  */

                   IF   tab_inusatab           AND
                        crapepr.inliquid = 0   THEN
                        DO:
                            FIND craplcr WHERE                                                                
                                 craplcr.cdcooper = glb_cdcooper        AND
                                 craplcr.cdlcremp = crapepr.cdlcremp
                                 NO-LOCK NO-ERROR.

                            IF   NOT AVAILABLE craplcr   THEN
                                 DO:
                                     glb_cdcritic = 363.
                                     NEXT.
                                 END.
                            ELSE
                                 aux_txdjuros = craplcr.txdiaria.
                        END.
                   ELSE
                        aux_txdjuros = crapepr.txjuremp.

                   ASSIGN aux_nrdconta = crapepr.nrdconta
                          aux_nrctremp = crapepr.nrctremp
                          aux_vlsdeved = crapepr.vlsdeved
                          aux_vljuracu = crapepr.vljuracu
                          aux_inliquid = crapepr.inliquid

                          aux_dtcalcul = ?

                          aux_dtultdia = ((DATE(MONTH(glb_dtmvtolt),28,
                                             YEAR(glb_dtmvtolt)) +
                                             4) - DAY(DATE(MONTH(glb_dtmvtolt),
                                             28,YEAR(glb_dtmvtolt)) + 4)).

                   { includes/lelem.i }  /* Rotina para calc do sld.devedor */

                   IF   craphis.indebcre = "D"   THEN DO:
                        ASSIGN par_qtexclln = par_qtexclln + 1
                               par_vlexcldb = par_vlexcldb + crablem.vllanmto
                               aux_contador = 0.

                        /*Renato Darosci - Inclusao do IF - 16/08/2016 
                          26/10/2017 - Remocao do IF (Kelvin/Ademir SD 745969)   
						  IF crapepr.inprejuz = 0 THEN */
                               crapepr.inliquid = IF (aux_vlsdeved -
                                                      crablem.vllanmto) > 0
                                                      THEN 0
                                                      ELSE 1.
                                                      
                      END.
                   ELSE
                   IF   craphis.indebcre = "C"   THEN DO:
                        ASSIGN par_qtexclln = par_qtexclln + 1
                               par_vlexclcr = par_vlexclcr + crablem.vllanmto
                               aux_contador = 0.

                        /*Renato Darosci - Inclusao do IF - 16/08/2016 */
                        /*26/10/2017 - Remocao do IF (Kelvin/Ademir SD 745969)   
						  IF crapepr.inprejuz = 0 THEN*/
                               crapepr.inliquid = IF (aux_vlsdeved +
                                                      crablem.vllanmto) > 0
                                                      THEN 0
                                                      ELSE 1.
                      END.
                   
                   /* Voltar a situaçao antes de ter pago o prejuizo - Renato Darosci - 16/08/2016 */
                   IF crapepr.dtliqprj <> ? THEN
                      ASSIGN crapepr.dtliqprj = ?.

                   IF   crablem.cdhistor = 349   THEN 
                        ASSIGN crapepr.vlprejuz = crapepr.vlprejuz - 
                                                          crablem.vllanmto
                               crapepr.vlsdprej = crapepr.vlsdprej - 
                                                          crablem.vllanmto
                               crapepr.inprejuz = 0
                               crapepr.dtprejuz = ?. 
                   
                   RUN sistema/generico/procedures/b1wgen0043.p
                                       PERSISTENT SET h-b1wgen0043.

                   /* Verificar se tem que ativar/desativar o Rating */
                   RUN verifica_contrato_rating IN h-b1wgen0043 
                                            (INPUT glb_cdcooper,
                                             INPUT 0,
                                             INPUT 0,
                                             INPUT glb_cdoperad,
                                             INPUT glb_dtmvtolt,
                                             INPUT glb_dtmvtopr,
                                             INPUT crapepr.nrdconta,
                                             INPUT 90, /* Emprestimo */
                                             INPUT crapepr.nrctremp,
                                             INPUT 1,
                                             INPUT 1,
                                             INPUT glb_nmdatela,
                                             INPUT glb_inproces,
                                             INPUT FALSE,
                                             OUTPUT TABLE tt-erro).

                   DELETE PROCEDURE h-b1wgen0043.

                   IF   RETURN-VALUE <> "OK"   THEN
                        DO:
                            FIND FIRST tt-erro NO-LOCK NO-ERROR.

                            IF   AVAIL tt-erro   THEN
                                 MESSAGE tt-erro.dscritic.

                            UNDO TRANS_E , LEAVE.
                        END.
                    
                   IF  crablem.cdhistor = 382   THEN
                       DO:
                           ASSIGN aux_flgpg391 = NO.
                           FOR EACH crab2lem 
                              WHERE crab2lem.cdcooper = glb_cdcooper       AND 
                                    crab2lem.nrdconta = crablem.nrdconta   AND
                                    crab2lem.nrctremp = crablem.nrctremp   AND
                                    crab2lem.cdhistor = 391  NO-LOCK:
                               IF   crab2lem.nrdolote <> crablem.nrdolote  OR
                                    crab2lem.cdagenci <> crablem.cdagenci  OR
                                    crab2lem.cdbccxlt <> crablem.cdbccxlt  THEN
                                   DO:
                                       ASSIGN aux_flgpg391 = YES.
                                       LEAVE.
                                   END.
                           END.
                           IF   aux_flgpg391  THEN 
                                DO:
                                    ASSIGN glb_cdcritic = 650
                                           par_situacao = FALSE.
                                    LEAVE.
                                END.                     
                       END.

                       
                   IF  crablem.cdhistor = 382 /*pag.prej.orig*/          OR
                       crablem.cdhistor = 383 /*abono prejuizo*/         OR
                       crablem.cdhistor = 390 /*acrescimos*/             OR
                       crablem.cdhistor = 391   THEN /*pag.prejuizo*/
                       DO:
                           IF craphis.indebcre = "C" THEN
                              DO:
                                  IF crapepr.tpemprst = 1 AND 
                                     CAN-DO("382,383",STRING(crablem.cdhistor)) THEN
                                     DO:
                                         ASSIGN aux_vlrabono = 0
                                                aux_vlpgsmmo = 0
                                                aux_sldmulta = 0
                                                aux_sldjmora = 0
                                                aux_vlrpagos = 0.
                        
                                         FOR EACH crab2lem  WHERE 
                                                 (crab2lem.cdcooper = glb_cdcooper       AND
                                                  crab2lem.nrdconta = crapepr.nrdconta   AND
                                                  crab2lem.nrctremp = crapepr.nrctremp   AND
                                                  crab2lem.cdhistor = 382)               OR
            
                                                 (crab2lem.cdcooper = glb_cdcooper       AND
                                                  crab2lem.nrdconta = crapepr.nrdconta   AND
                                                  crab2lem.nrctremp = crapepr.nrctremp   AND
                                                  crab2lem.cdhistor = 383)
                                                  NO-LOCK:
                                                 
                                             IF crab2lem.cdhistor = 382 THEN
                                                ASSIGN aux_vlrpagos = aux_vlrpagos +
                                                                      crab2lem.vllanmto.
                                             ELSE
                                             IF crab2lem.cdhistor = 383 THEN
                                                ASSIGN aux_vlrabono = aux_vlrabono +
                                                                      crab2lem.vllanmto.
            
                                         END. /* END FOR EACH crablem */
                        
                                         ASSIGN /* Valor a ser desfeito */
                                                 aux_vlrsaldo = crablem.vllanmto
                                                 /* Pago da multa */
                                                 aux_sldmulta = crapepr.vlpgmupr
                                                 /* Pago do juros de mora */
                                                 aux_sldjmora = crapepr.vlpgjmpr
                                                 /* Calcular o valor pago do prejuizo original 
                                                    sem multa e juros de mora */   
                                                 aux_vlpgsmmo = (aux_vlrpagos + aux_vlrabono) - 
                                                                (aux_sldmulta + aux_sldjmora).
                                         
                                         /* 1 Desfazer primeiro o valor pago do prejuizo original */
                                         IF aux_vlpgsmmo > 0 THEN
                                            DO:
                                               IF ((aux_vlpgsmmo - aux_vlrsaldo) <= 0) THEN
                                                  ASSIGN crapepr.vlsdprej = crapepr.vlsdprej + aux_vlpgsmmo
                                                         aux_vlrsaldo     = aux_vlrsaldo - aux_vlpgsmmo
                                                         aux_vlpgsmmo     = 0.
                                               ELSE
                                                  ASSIGN crapepr.vlsdprej = crapepr.vlsdprej + aux_vlrsaldo
                                                         aux_vlpgsmmo     = aux_vlpgsmmo - aux_vlrsaldo
                                                         aux_vlrsaldo     = 0.
            
                                            END. /* END IF aux_vlpgsmmo > 0 THEN */
                        
                                         /* 2 Desfazer o valor pago de multa */
                                         IF aux_vlrsaldo > 0 AND aux_sldmulta > 0 THEN
                                            DO:
                                               IF ((aux_sldmulta - aux_vlrsaldo) <= 0) THEN
                                                  ASSIGN crapepr.vlpgmupr = crapepr.vlpgmupr - aux_sldmulta
                                                         aux_vlrsaldo     = aux_vlrsaldo - aux_sldmulta
                                                         aux_sldmulta     = 0.
                                               ELSE     
                                                  ASSIGN crapepr.vlpgmupr = crapepr.vlpgmupr - aux_vlrsaldo
                                                         aux_sldmulta     = aux_sldmulta - aux_vlrsaldo
                                                         aux_vlrsaldo     = 0.
                                            END.
                        
                                         /* 3 Desfazer o valor pago de juros de mora */
                                         IF (aux_vlrsaldo > 0) AND (aux_sldjmora > 0) THEN
                                            DO:
                                                IF ((aux_sldjmora - aux_vlrsaldo) <= 0) THEN
                                                   ASSIGN crapepr.vlpgjmpr = crapepr.vlpgjmpr - aux_sldjmora
                                                          aux_vlrsaldo     = aux_vlrsaldo - aux_sldjmora
                                                          aux_sldjmora     = 0.
                                                ELSE     
                                                   ASSIGN crapepr.vlpgjmpr = crapepr.vlpgjmpr - aux_vlrsaldo
                                                          aux_sldjmora     = aux_sldjmora - aux_vlrsaldo
                                                          aux_vlrsaldo     = 0.
                                            END.

                                     END. /* END IF crapepr.tpemprst = 1 */
                                  ELSE
                                     ASSIGN crapepr.vlsdprej = crapepr.vlsdprej + 
                                                               crablem.vllanmto.

                              END. /* END IF IF craphis.indebcre = "C" THEN */
                           ELSE
                              IF craphis.indebcre = "D"   THEN
                                 ASSIGN crapepr.vlsdprej =
                                                crapepr.vlsdprej -
                                                        crablem.vllanmto.
                       END.
                   
                   DELETE crablem.

                   aux_dtultpag = crapepr.dtmvtolt.

                   FOR EACH craplem WHERE
                            craplem.cdcooper = glb_cdcooper       AND
                            craplem.nrdconta = crapepr.nrdconta   AND
                            craplem.nrctremp = crapepr.nrctremp   NO-LOCK:

                       FIND craphis NO-LOCK WHERE 
                               craphis.cdcooper = craplem.cdcooper AND 
                               craphis.cdhistor = craplem.cdhistor NO-ERROR.

                       IF   NOT AVAILABLE craphis   THEN
                            NEXT.

                       IF   craphis.indebcre = "C"   THEN
                            aux_dtultpag = craplem.dtmvtolt.

                   END.  /*  Fim do FOR EACH  --  Pesquisa do ultimo pgto  */

                   crapepr.dtultpag = aux_dtultpag.

                   LEAVE.

               END.

               IF   par_situacao   THEN
                    LEAVE.

               IF   glb_cdcritic > 0   THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        LEAVE TRANS_E.
                    END.
            END.
        END.
   ELSE
   IF   craplot.tplotmov =  6   OR   craplot.tplotmov = 12 OR
        craplot.tplotmov = 17   THEN
        DO:
            DO WHILE TRUE:

               DO  aux_contador = 1 TO 20:

                   FIND FIRST craplau WHERE
                              craplau.cdcooper = glb_cdcooper       AND
                              craplau.dtmvtolt = glb_dtmvtolt       AND
                              craplau.cdagenci = craplot.cdagenci   AND
                              craplau.cdbccxlt = craplot.cdbccxlt   AND
                              craplau.nrdolote = craplot.nrdolote
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                   IF   NOT AVAILABLE craplau   THEN
                        IF   LOCKED craplau   THEN
                             DO:
                                 ASSIGN glb_cdcritic = 85
                                        par_situacao = FALSE.
                                 PAUSE 1 NO-MESSAGE.
                                 NEXT.
                             END.
                        ELSE
                             DO:
                                 par_situacao = TRUE.
                                 LEAVE. /* Sai quando nao ha mais lancamentos */
                             END.

                   FIND craphis NO-LOCK WHERE 
                               craphis.cdcooper = craplau.cdcooper AND 
                               craphis.cdhistor = craplau.cdhistor NO-ERROR.

                   IF   NOT AVAILABLE craphis   THEN
                        DO:
                            ASSIGN glb_cdcritic = 83
                                   par_situacao = FALSE.
                            LEAVE.
                        END.

                   IF   craphis.inavisar = 1  AND  craplot.tplotmov = 12   THEN
                        DO:
                            FIND crapass WHERE 
                                 crapass.cdcooper = glb_cdcooper      AND
                                 crapass.nrdconta = craplau.nrdconta
                                 NO-LOCK NO-ERROR.
                            
                            IF   NOT AVAILABLE crapass   THEN
                                 DO:
                                     ASSIGN glb_cdcritic = 9
                                            par_situacao = FALSE.
                                     LEAVE.
                                 END.
                                 
                            IF  crapass.inpessoa = 1   THEN 
                                DO:
                                   FIND crapttl WHERE 
                                        crapttl.cdcooper = glb_cdcooper     AND
                                        crapttl.nrdconta = crapass.nrdconta AND
                                        crapttl.idseqttl = 1 NO-LOCK NO-ERROR.
                                        
                                   IF   AVAIL crapttl  THEN
                                        ASSIGN aux_cdempres = crapttl.cdempres.
                                END.
                            ELSE
                                DO:
                                   FIND crapjur WHERE 
                                        crapjur.cdcooper = glb_cdcooper  AND
                                        crapjur.nrdconta = crapass.nrdconta
                                        NO-LOCK NO-ERROR.
                            
                                   IF   AVAIL crapjur  THEN
                                        ASSIGN aux_cdempres = crapjur.cdempres.
                                END.

                            FIND crapemp WHERE 
                                 crapemp.cdcooper = glb_cdcooper     AND
                                 crapemp.cdempres = aux_cdempres 
                                 NO-LOCK NO-ERROR.

                            IF   NOT AVAILABLE crapemp   THEN
                                 DO:
                                     ASSIGN glb_cdcritic = 40
                                            par_situacao = FALSE.
                                     LEAVE.
                                 END.

                            aux_dtmvtolt = ((DATE(MONTH(glb_dtmvtolt),28,
                                                  YEAR(glb_dtmvtolt)) + 4) -
                                            DAY(DATE(MONTH(glb_dtmvtolt),28,
                                                  YEAR(glb_dtmvtolt)) + 4)).

                            DO WHILE TRUE:

                              aux_dtmvtolt = aux_dtmvtolt + 1.

                              IF  CAN-DO("1,7",STRING(WEEKDAY(aux_dtmvtolt))) OR
                                  CAN-FIND(crapfer WHERE
                                           crapfer.cdcooper = glb_cdcooper  AND
                                           crapfer.dtferiad = aux_dtmvtolt) THEN
                                  NEXT.

                              LEAVE.

                            END.  /* DO WHILE TRUE */

                            DO WHILE TRUE:

                               IF   craphis.indebfol = 1   THEN
                                    FIND crapavs WHERE
                                         crapavs.cdcooper = glb_cdcooper     AND
                                         crapavs.dtmvtolt =
                                              (IF crapemp.tpconven = 1
                                                  THEN crapemp.dtavsemp
                                                  ELSE aux_dtmvtolt )        AND
                                         crapavs.cdempres = aux_cdempres     AND
                                         crapavs.cdagenci = crapass.cdagenci AND
                                         crapavs.cdsecext = crapass.cdsecext AND
                                         crapavs.nrdconta = craplau.nrdconta AND
                                         crapavs.dtdebito = ?                AND
                                         crapavs.cdhistor = craplau.cdhistor AND
                                         crapavs.nrdocmto = craplau.nrdocmto
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                              
                               ELSE
                               
                                    FIND crapavs WHERE
                                         crapavs.cdcooper = glb_cdcooper     AND
                                         crapavs.dtmvtolt = craplau.dtmvtolt AND
                                         crapavs.cdempres = 0                AND
                                         crapavs.cdagenci = crapass.cdagenci AND
                                         crapavs.cdsecext = crapass.cdsecext AND
                                         crapavs.nrdconta = craplau.nrdconta AND
                                         crapavs.dtdebito = craplau.dtmvtopg AND
                                         crapavs.cdhistor = craplau.cdhistor AND
                                         crapavs.nrdocmto = craplau.nrdocmto
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                               IF   NOT AVAILABLE crapavs   THEN
                                    IF   LOCKED crapavs   THEN
                                         DO:
                                             PAUSE 2 NO-MESSAGE.
                                             NEXT.
                                         END.
                                    ELSE
                                         glb_cdcritic = 448.
                               ELSE
                                    DELETE crapavs.

                               LEAVE.

                            END.  /*  Fim do DO WHILE TRUE  */

                            IF   glb_cdcritic > 0   THEN
                                 DO:
                                     par_situacao = FALSE.
                                     LEAVE.
                                 END.
                        END.

                   ASSIGN par_qtexclln = par_qtexclln + 1
                          aux_contador = 0.

                   IF   craphis.indebcre = "D"   THEN
                        par_vlexcldb = par_vlexcldb + craplau.vllanaut.
                   ELSE
                   IF   craphis.indebcre = "C"   THEN
                        par_vlexclcr = par_vlexclcr + craplau.vllanaut.

                   DELETE craplau.
                   LEAVE.

               END.  /*  Fim do DO .. TO  */

               IF   par_situacao   THEN
                    LEAVE.

               IF   aux_contador <> 0   THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        LEAVE.
                    END.

            END.  /*  Fim do DO WHILE TRUE  */
        END.
   ELSE   
   IF   craplot.tplotmov = 9   THEN
        DO:
            DO WHILE TRUE:

               DO  aux_contador = 1 TO 20:

                   FIND FIRST craplap USE-INDEX craplap3 WHERE
                              craplap.cdcooper = glb_cdcooper       AND
                              craplap.dtmvtolt = glb_dtmvtolt       AND
                              craplap.cdagenci = craplot.cdagenci   AND
                              craplap.cdbccxlt = craplot.cdbccxlt   AND
                              craplap.nrdolote = craplot.nrdolote
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                   IF   NOT AVAILABLE craplap   THEN
                        IF   LOCKED craplap   THEN
                             DO:
                                 ASSIGN glb_cdcritic = 85
                                        par_situacao = FALSE.
                                 PAUSE 1 NO-MESSAGE.
                                 NEXT.
                             END.
                        ELSE
                             DO:
                                 par_situacao = TRUE.
                                 LEAVE. /* Sai quando nao ha mais lancamentos */
                             END.
                   ELSE
                        glb_cdcritic = 0.

                   DO WHILE TRUE:

                      FIND craprda WHERE
                           craprda.cdcooper = glb_cdcooper       AND
                           craprda.dtmvtolt = craplap.dtmvtolt   AND
                           craprda.cdagenci = craplap.cdagenci   AND
                           craprda.cdbccxlt = craplap.cdbccxlt   AND
                           craprda.nrdolote = craplap.nrdolote   AND
                           craprda.nrdconta = craplap.nrdconta   AND
                      DECI(craprda.nraplica) = craplap.nrdocmto
                           USE-INDEX craprda1 
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                      IF   NOT AVAILABLE craprda   THEN
                           IF   LOCKED craprda   THEN
                                DO:
                                    ASSIGN glb_cdcritic = 85
                                           par_situacao = FALSE.
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                           ELSE
                                DO:
                                    par_situacao = TRUE.
                                    LEAVE.
                                END.

                      glb_cdcritic = 0.

                      LEAVE.

                   END.  /*  Fim do DO WHILE TRUE  */

                   IF   par_situacao   THEN
                        LEAVE.

                   IF   glb_cdcritic > 0   THEN
                        DO:
                            RUN fontes/critic.p.
                            BELL.
                            MESSAGE glb_dscritic.
                            glb_cdcritic = 0.
                            LEAVE.
                        END.

                   ASSIGN par_qtexclln = par_qtexclln + 1
                          par_vlexclcr = par_vlexclcr + craplap.vllanmto

                          aux_contador = 0.

                   DELETE craprda.
                   DELETE craplap.
                   LEAVE.

               END.  /*  Fim do DO .. TO  */

               IF   par_situacao   THEN
                    LEAVE.

               IF   aux_contador <> 0   THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        LEAVE.
                    END.

            END.  /*  Fim do DO WHILE TRUE  */
        END.
   ELSE
   IF   craplot.tplotmov = 10   THEN
        DO:
            DO WHILE TRUE:

               DO  aux_contador = 1 TO 20:

                   FIND FIRST craplap USE-INDEX craplap3 WHERE
                              craplap.cdcooper = glb_cdcooper       AND
                              craplap.dtmvtolt = glb_dtmvtolt       AND
                              craplap.cdagenci = craplot.cdagenci   AND
                              craplap.cdbccxlt = craplot.cdbccxlt   AND
                              craplap.nrdolote = craplot.nrdolote
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                   IF   NOT AVAILABLE craplap   THEN
                        IF   LOCKED craplap   THEN
                             DO:
                                 ASSIGN glb_cdcritic = 85
                                        par_situacao = FALSE.
                                 PAUSE 1 NO-MESSAGE.
                                 NEXT.
                             END.
                        ELSE
                             DO:
                                 par_situacao = TRUE.
                                 LEAVE. /* Sai quando nao ha mais lancamentos */
                             END.
                   ELSE
                        glb_cdcritic = 0.

                   DO WHILE TRUE:

                      FIND craprda WHERE
                           craprda.cdcooper = glb_cdcooper       AND
                           craprda.dtmvtolt = craplap.dtmvtolt   AND
                           craprda.cdagenci = craplap.cdagenci   AND
                           craprda.cdbccxlt = craplap.cdbccxlt   AND
                           craprda.nrdolote = craplap.nrdolote   AND
                           craprda.nrdconta = craplap.nrdconta   AND
                      DECI(craprda.nraplica) = craplap.nrdocmto
                           USE-INDEX craprda1 
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                      IF   NOT AVAILABLE craprda   THEN
                           IF   LOCKED craprda   THEN
                                DO:
                                    ASSIGN glb_cdcritic = 85
                                           par_situacao = FALSE.
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                           ELSE
                                DO:
                                    par_situacao = TRUE.
                                    LEAVE.
                                END.

                      glb_cdcritic = 0.

                      LEAVE.

                   END.  /*  Fim do DO WHILE TRUE  */

                   IF   par_situacao   THEN
                        LEAVE.

                   IF   glb_cdcritic > 0   THEN
                        DO:
                            RUN fontes/critic.p.
                            BELL.
                            MESSAGE glb_dscritic.
                            glb_cdcritic = 0.
                            LEAVE.
                        END.

                   ASSIGN par_qtexclln = par_qtexclln + 1
                          par_vlexclcr = par_vlexclcr + craplap.vllanmto

                          aux_contador = 0.

                   DELETE craprda.
                   DELETE craplap.
                   LEAVE.

               END.  /*  Fim do DO .. TO  */

               IF   par_situacao   THEN
                    LEAVE.

               IF   aux_contador <> 0   THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        LEAVE.
                    END.

            END.  /*  Fim do DO WHILE TRUE  */
        END.
   ELSE
   IF   craplot.tplotmov = 11   THEN
        DO:
            DO WHILE TRUE:

               DO  aux_contador = 1 TO 20:

                   FIND FIRST craplrg WHERE
                              craplrg.cdcooper = glb_cdcooper       AND
                              craplrg.dtmvtolt = glb_dtmvtolt       AND
                              craplrg.cdagenci = craplot.cdagenci   AND
                              craplrg.cdbccxlt = craplot.cdbccxlt   AND
                              craplrg.nrdolote = craplot.nrdolote
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                   IF   NOT AVAILABLE craplrg   THEN
                        IF   LOCKED craplrg   THEN
                             DO:
                                 ASSIGN glb_cdcritic = 85
                                        par_situacao = FALSE.
                                 PAUSE 1 NO-MESSAGE.
                                 NEXT.
                             END.
                        ELSE
                             DO:
                                 par_situacao = TRUE.
                                 LEAVE. /* Sai quando nao ha mais lancamentos */
                             END.

                   ASSIGN par_qtexclln = par_qtexclln + 1
                          par_vlexcldb = par_vlexcldb + craplrg.vllanmto

                          aux_contador = 0.

                   DELETE craplrg.
                   LEAVE.

               END.  /*  Fim do DO .. TO  */

               IF   par_situacao   THEN
                    LEAVE.

               IF   aux_contador <> 0   THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        LEAVE.
                    END.

            END.  /*  Fim do DO WHILE TRUE  */
        END.
   ELSE
   IF   craplot.tplotmov = 13   THEN
        DO:
            DO WHILE TRUE:

               DO  aux_contador = 1 TO 20:

                   FIND FIRST craplft WHERE
                              craplft.cdcooper = glb_cdcooper       AND
                              craplft.dtmvtolt = glb_dtmvtolt       AND
                              craplft.cdagenci = craplot.cdagenci   AND
                              craplft.cdbccxlt = craplot.cdbccxlt   AND
                              craplft.nrdolote = craplot.nrdolote
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                   IF   NOT AVAILABLE craplft   THEN
                        IF   LOCKED craplft   THEN
                             DO:
                                 ASSIGN glb_cdcritic = 85
                                        par_situacao = FALSE.
                                 PAUSE 1 NO-MESSAGE.
                                 NEXT.
                             END.
                        ELSE
                             DO:
                                 par_situacao = TRUE.
                                 LEAVE. /* Sai quando nao ha mais lancamentos */
                             END.

                   ASSIGN par_qtexclln = par_qtexclln + 1
                          par_vlexcldb = par_vlexcldb + (craplft.vllanmto + craplft.vlrmulta + craplft.vlrjuros)
                          aux_contador = 0.

                   DELETE craplft.

                   LEAVE.

               END.  /*  Fim do DO .. TO  */

               IF   par_situacao   THEN
                    LEAVE.

               IF   aux_contador <> 0   THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        LEAVE.
                    END.

            END.  /*  Fim do DO WHILE TRUE  */
        END.
   ELSE
   IF   craplot.tplotmov = 16   THEN
        DO:
            DO WHILE TRUE:

               DO  aux_contador = 1 TO 20:

                   FIND FIRST crawcrd WHERE
                              crawcrd.cdcooper = glb_cdcooper       AND
                              crawcrd.dtmvtolt = glb_dtmvtolt       AND
                              crawcrd.cdagenci = craplot.cdagenci   AND
                              crawcrd.cdbccxlt = craplot.cdbccxlt   AND
                              crawcrd.nrdolote = craplot.nrdolote
                              USE-INDEX crawcrd3
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                   IF   NOT AVAILABLE crawcrd   THEN        
                        IF   LOCKED crawcrd   THEN            
                             DO:
                                 ASSIGN glb_cdcritic = 85
                                        par_situacao = FALSE.
                                 PAUSE 1 NO-MESSAGE.
                                 NEXT.
                             END.
                        ELSE
                             DO:
                                 par_situacao = TRUE.
                                 LEAVE. /* Sai quando nao ha mais lancamentos */
                             END.

                   ASSIGN par_qtexclln = par_qtexclln + 1
                          aux_contador = 0

                          crawcrd.dtmvtolt = ?
                          crawcrd.cdagenci = 0
                          crawcrd.cdbccxlt = 0
                          crawcrd.nrdolote = 0
                          crawcrd.nrseqdig = 0
                          crawcrd.insitcrd = 0.

                   LEAVE.

               END.  /*  Fim do DO .. TO  */

               IF   par_situacao   THEN
                    LEAVE.

               IF   aux_contador <> 0   THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        LEAVE.
                    END.

            END.  /*  Fim do DO WHILE TRUE  */
        END.
   ELSE
   IF   craplot.tplotmov = 18   THEN
        DO:
            DO WHILE TRUE:

               DO  aux_contador = 1 TO 20:

                   FIND FIRST craplcb WHERE
                              craplcb.cdcooper = glb_cdcooper       AND
                              craplcb.dtmvtolt = glb_dtmvtolt       AND
                              craplcb.cdagenci = craplot.cdagenci   AND
                              craplcb.cdbccxlt = craplot.cdbccxlt   AND
                              craplcb.nrdolote = craplot.nrdolote
                              USE-INDEX craplcb3
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                   IF   NOT AVAILABLE craplcb   THEN
                        IF   LOCKED craplcb   THEN
                             DO:
                                 ASSIGN glb_cdcritic = 85
                                        par_situacao = FALSE.
                                 PAUSE 1 NO-MESSAGE.
                                 NEXT.
                             END.
                        ELSE
                             DO:
                                 par_situacao = TRUE.
                                 LEAVE. /* Sai quando nao ha mais lancamentos */
                             END.

                   DO WHILE TRUE:

                      FIND crapcob WHERE
                           crapcob.cdcooper = glb_cdcooper       AND 
                           crapcob.cdbandoc = craplcb.cdbancob   AND
                           crapcob.nrdctabb = craplcb.nrdctabb   AND
                           crapcob.nrcnvcob = craplcb.nrcnvcob   AND
                           crapcob.nrdconta = craplcb.nrdconta   AND
                           crapcob.nrdocmto = craplcb.nrdocmto
                           USE-INDEX crapcob1 
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                      IF   NOT AVAILABLE crapcob   THEN
                           IF   LOCKED crapcob   THEN
                                DO:
                                    ASSIGN glb_cdcritic = 85
                                           par_situacao = FALSE.
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                           ELSE
                                DO:
                                    par_situacao = TRUE.
                                    LEAVE.
                                END.

                      glb_cdcritic = 0.

                      LEAVE.

                   END.  /*  Fim do DO WHILE TRUE  */

                   IF   par_situacao   THEN
                        LEAVE.

                   IF   glb_cdcritic > 0   THEN
                        DO:
                            RUN fontes/critic.p.
                            BELL.
                            MESSAGE glb_dscritic.
                            glb_cdcritic = 0.
                            LEAVE.
                        END.

                   ASSIGN par_qtexclln = par_qtexclln + 1
                          par_vlexclcr = par_vlexclcr + craplcb.vllanmto
                          par_vlexcldb = par_vlexcldb + craplcb.vltarifa
                          aux_contador = 0.

                   DELETE craplcb.
                   ASSIGN crapcob.incobran = 0
                          crapcob.dtdpagto = ?
                          crapcob.vldpagto = 0
                          crapcob.indpagto = 0.

                   LEAVE.

               END.  /*  Fim do DO .. TO  */

               IF   par_situacao   THEN
                    LEAVE.

               IF   aux_contador <> 0   THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        LEAVE.
                    END.

            END.  /*  Fim do DO WHILE TRUE  */
        END.
   ELSE
   IF   craplot.tplotmov = 19   THEN        /*  Cheques em custodia  */
        DO:
            DO WHILE TRUE:

               DO  aux_contador = 1 TO 20:

                   FIND FIRST crapcst WHERE
                              crapcst.cdcooper = glb_cdcooper       AND
                              crapcst.dtmvtolt = glb_dtmvtolt       AND
                              crapcst.cdagenci = craplot.cdagenci   AND
                              crapcst.cdbccxlt = craplot.cdbccxlt   AND
                              crapcst.nrdolote = craplot.nrdolote
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                   IF   NOT AVAILABLE crapcst   THEN
                        IF   LOCKED crapcst   THEN
                             DO:
                                 ASSIGN glb_cdcritic = 85
                                        par_situacao = FALSE.
                                 PAUSE 1 NO-MESSAGE.
                                 NEXT.
                             END.
                        ELSE
                             DO:
                                 par_situacao = TRUE.
                                 LEAVE. /* Sai quando nao ha mais lancamentos */
                             END.

                   ASSIGN par_qtexclln = par_qtexclln + 1
                          par_vlexclcr = par_vlexclcr + crapcst.vlcheque
                          par_vlexcldb = par_vlexcldb + crapcst.vlcheque
                          aux_contador = 0

                          aux_nrdocmto = INT(STRING(crapcst.nrcheque,"999999") +
                                             STRING(crapcst.nrddigc3,"9")).

                   DO WHILE TRUE:

                      FIND craplau WHERE
                           craplau.cdcooper = glb_cdcooper       AND
                           craplau.dtmvtolt = crapcst.dtmvtolt   AND
                           craplau.cdagenci = crapcst.cdagenci   AND
                           craplau.cdbccxlt = crapcst.cdbccxlt   AND
                           craplau.nrdolote = crapcst.nrdolote   AND
                  DECIMAL(craplau.nrdctabb) = crapcst.nrctachq   AND
                           craplau.nrdocmto = aux_nrdocmto
                           USE-INDEX craplau1 EXCLUSIVE-LOCK 
                           NO-ERROR NO-WAIT.

                      IF   NOT AVAILABLE craplau   THEN
                           IF   LOCKED craplau   THEN
                                DO:
                                    PAUSE 2 NO-MESSAGE.
                                    NEXT.
                                END.
                      
                      LEAVE.

                   END.  /*  Fim do DO WHILE TRUE  */
        
                   IF   AVAILABLE craplau   THEN
                        DELETE craplau.

                   DELETE crapcst.

                   LEAVE.

               END.  /*  Fim do DO .. TO  */

               IF   par_situacao   THEN
                    LEAVE.

               IF   aux_contador <> 0   THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        LEAVE.
                    END.

            END.  /*  Fim do DO WHILE TRUE  */
        END.
   ELSE
   IF   craplot.tplotmov = 20 OR craplot.tplotmov = 21 THEN /*  Titulos */
        DO:
            DO WHILE TRUE:

               DO  aux_contador = 1 TO 20:

                   FIND FIRST craptit WHERE
                              craptit.cdcooper = glb_cdcooper       AND  
                              craptit.dtmvtolt = glb_dtmvtolt       AND
                              craptit.cdagenci = craplot.cdagenci   AND
                              craptit.cdbccxlt = craplot.cdbccxlt   AND
                              craptit.nrdolote = craplot.nrdolote
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                   IF   NOT AVAILABLE craptit   THEN
                        IF   LOCKED craptit   THEN
                             DO:
                                 ASSIGN glb_cdcritic = 85
                                        par_situacao = FALSE.
                                 PAUSE 1 NO-MESSAGE.
                                 NEXT.
                             END.
                        ELSE
                             DO:
                                 par_situacao = TRUE.
                                 LEAVE. /* Sai quando nao ha mais lancamentos */
                             END.

                   ASSIGN par_qtexclln = par_qtexclln + 1
                          par_vlexclcr = par_vlexclcr + craptit.vldpagto
                          aux_contador = 0.

                   DO WHILE TRUE:

                      FIND craplau WHERE
                           craplau.cdcooper = glb_cdcooper       AND
                           craplau.dtmvtolt = craptit.dtmvtolt   AND
                           craplau.cdagenci = craptit.cdagenci   AND
                           craplau.cdbccxlt = craptit.cdbccxlt   AND
                           craplau.nrdolote = craptit.nrdolote   AND
                           craplau.nrdctabb = craptit.nrdconta   AND
                           craplau.nrdocmto = craptit.nrdocmto
                           USE-INDEX craplau1 EXCLUSIVE-LOCK 
                           NO-ERROR NO-WAIT.
 
                      IF   NOT AVAILABLE craplau   THEN
                           IF   LOCKED craplau   THEN
                                DO:
                                    PAUSE 2 NO-MESSAGE.
                                    NEXT.
                                END.
                    
                      LEAVE.

                   END.  /*  Fim do DO WHILE TRUE  */
        
                   IF   AVAILABLE craplau   THEN
                        DELETE craplau.
                        
                   DELETE craptit.

                   LEAVE.

               END.  /*  Fim do DO .. TO  */

               IF   par_situacao   THEN
                    LEAVE.

               IF   aux_contador <> 0   THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        LEAVE.
                    END.

            END.  /*  Fim do DO WHILE TRUE  */
        END.
   ELSE
   /*** Tratamento da Compensacao Eletronica ***/
   IF   craplot.tplotmov = 23 THEN /*  Cheques */
        DO:
            DO WHILE TRUE:

               DO  aux_contador = 1 TO 20:

                   FIND FIRST crapchd WHERE
                              crapchd.cdcooper = glb_cdcooper       AND
                              crapchd.dtmvtolt = glb_dtmvtolt       AND
                              crapchd.cdagenci = craplot.cdagenci   AND
                              crapchd.cdbccxlt = craplot.cdbccxlt   AND
                              crapchd.nrdolote = craplot.nrdolote
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                   IF   NOT AVAILABLE crapchd   THEN
                        IF   LOCKED crapchd   THEN
                             DO:
                                 ASSIGN glb_cdcritic = 85
                                        par_situacao = FALSE.
                                 PAUSE 1 NO-MESSAGE.
                                 NEXT.
                             END.
                        ELSE
                             DO:
                                 par_situacao = TRUE.
                                 LEAVE. /* Sai quando nao ha mais lancamentos */
                             END.

                   ASSIGN par_qtexclln = par_qtexclln + 1
                          par_vlexclcr = par_vlexclcr + crapchd.vlcheque
                          par_vlexcldb = par_vlexcldb + crapchd.vlcheque
                          aux_contador = 0.

                   DELETE crapchd.

                   LEAVE.

               END.  /*  Fim do DO .. TO  */

               IF   par_situacao   THEN
                    LEAVE.

               IF   aux_contador <> 0   THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        LEAVE.
                    END.

            END.  /*  Fim do DO WHILE TRUE  */
        END.
   ELSE
   IF   craplot.tplotmov = 24   OR    /* lotes de DOCS */
        craplot.tplotmov = 25   THEN  /* lotes de TEDS */
        DO:
            DO WHILE TRUE:

               DO  aux_contador = 1 TO 20:

                   FIND FIRST craptvl WHERE
                              craptvl.cdcooper = glb_cdcooper       AND
                              craptvl.dtmvtolt = glb_dtmvtolt       AND
                              craptvl.cdagenci = craplot.cdagenci   AND
                              craptvl.cdbccxlt = craplot.cdbccxlt   AND
                              craptvl.nrdolote = craplot.nrdolote
                              USE-INDEX craptvl2
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                   IF   NOT AVAILABLE craptvl   THEN
                        IF   LOCKED craptvl   THEN
                             DO:
                                 ASSIGN glb_cdcritic = 85
                                        par_situacao = FALSE.
                                 PAUSE 1 NO-MESSAGE.
                                 NEXT.
                             END.
                        ELSE
                             DO:
                                 par_situacao = TRUE.
                                 LEAVE. /* Sai quando nao ha mais lancamentos */
                             END.

                   ASSIGN par_qtexclln = par_qtexclln + 1
                          par_vlexclcr = par_vlexclcr + craptvl.vldocrcb
                          aux_contador = 0.

                   DELETE craptvl.

                   LEAVE.

               END.  /*  Fim do DO .. TO  */

               IF   par_situacao   THEN
                    LEAVE.

               IF   aux_contador <> 0   THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        LEAVE.
                    END.

            END.  /*  Fim do DO WHILE TRUE  */
        END.
   ELSE  /* --- Tratamento lancamentos Conta de Investimento ---*/               
   IF   craplot.tplotmov = 29   THEN    /* Lote Conta Investimento */
        DO:
           RUN elimina_lancamentos_craplci.
           CLEAR FRAME f_lote.
           ASSIGN tel_cdagenci = 0
                  tel_cdbccxlt = 0
                  tel_nrdolote = 0.
           NEXT.
        END.
   ELSE
   IF   craplot.tplotmov = 26   THEN       /*  Exclusao do Bordero de cheque  */
        DO:
            RUN fontes/lotee_26.p (INPUT craplot.cdhistor).  /* => # bordero */
        
            IF   glb_cdcritic > 0   THEN
                 par_situacao = FALSE.
            ELSE
                 par_situacao = TRUE.
        END.
   ELSE
   IF   craplot.qtcompln > 0 THEN
        DO:
            /********
             Se algum diar for tirada esta criticar,
             tem que ser tratada a volta-atras do Rating
             caso seja um lote de desconto de cheque/titulo ..
             (volta-atras-rating in b1wgen0043) (Gabriel)
            *********/

            glb_cdcritic = 999.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            NEXT.
        END.
   ELSE
        par_situacao = TRUE.

   IF   glb_cdcritic > 0 THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            UNDO TRANS_E, LEAVE.
        END.

   IF   par_situacao    THEN
        DO:
            FIND crapope WHERE crapope.cdcooper = glb_cdcooper   AND
                               crapope.cdoperad = glb_cdoperad
                               NO-LOCK NO-ERROR.

            UNIX SILENT VALUE("echo " + "EXCLUSAO DE LOTE - "                +
                              STRING(glb_dtmvtolt,"99/99/9999")              +
                              " " + STRING(TIME,"HH:MM:SS")                  +
                              " Operador: " + glb_cdoperad                   + 
                              " - "     +  crapope.nmoperad                  +
                              " PA: "  + STRING(tel_cdagenci, "zz9")        + 
                              " Banco/Caixa: " + STRING(tel_cdbccxlt, "zz9") + 
                              " Tipo: " + STRING(tel_tplotmov, "z9")         +
                              " Lote: " + STRING(tel_nrdolote,"zzz,zz9")     +
                              " Vlr Inf. Cred.: "                            + 
                              STRING(tel_vlinfocr,"zzz,zzz,zzz,zz9.99")      +
                              " Vlr Inf. Deb.: "                             + 
                              STRING(tel_vlinfodb,"zzz,zzz,zzz,zz9.99")      +    
                              " >> log/lote.log").
            DELETE craplot.
                                                           
            HIDE FRAME f_data_custodia NO-PAUSE.
            CLEAR FRAME f_lote.

            ASSIGN tel_cdagenci = 0
                   tel_cdbccxlt = 0
                   tel_nrdolote = 0
                   tel_qtinfoln = 0
                   tel_vlinfodb = 0
                   tel_vlinfocr = 0
                   tel_tplotmov = 0
                   tel_dtmvtopg = ?.
        END.
   ELSE
        DO:
            ASSIGN craplot.qtcompln = craplot.qtcompln - par_qtexclln
                   craplot.vlcompdb = craplot.vlcompdb - par_vlexcldb
                   craplot.vlcompcr = craplot.vlcompcr - par_vlexclcr

                   tel_qtinfoln = craplot.qtinfoln
                   tel_vlinfodb = craplot.vlinfodb
                   tel_vlinfocr = craplot.vlinfocr
                   tel_qtcompln = craplot.qtcompln
                   tel_vlcompdb = craplot.vlcompdb
                   tel_vlcompcr = craplot.vlcompcr
                   tel_tplotmov = craplot.tplotmov
                   tel_dtmvtopg = craplot.dtmvtopg

                   tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
                   tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
                   tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr.

            DISPLAY tel_dtmvtolt tel_qtinfoln tel_qtcompln tel_qtdifeln
                    tel_vlinfodb tel_vlcompdb tel_vldifedb tel_vlinfocr
                    tel_vlcompcr tel_vldifecr tel_tplotmov 
                    WITH FRAME f_lote.
        END.

END.   /* Fim da transacao  --  TRANS_E  */


PROCEDURE elimina_lancamentos_craplci.


   /* busca o lote */
   FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                      craplot.dtmvtolt = glb_dtmvtolt   AND
                      craplot.cdagenci = tel_cdagenci   AND 
                      craplot.cdbccxlt = tel_cdbccxlt   AND 
                      craplot.nrdolote = tel_nrdolote   AND
                      craplot.tplotmov = 29 
                      EXCLUSIVE-LOCK NO-ERROR.

   IF   NOT AVAILABLE craplot   THEN
        DO: 
            glb_cdcritic = 60. 
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            NEXT.
        END.
        
   FOR EACH craplci WHERE craplci.cdcooper = glb_cdcooper        AND
                          craplci.dtmvtolt = glb_dtmvtolt        AND
                          craplci.cdagenci = craplot.cdagenci    AND
                          craplci.cdbccxlt = craplot.cdbccxlt    AND
                          craplci.nrdolote = craplot.nrdolote
                          EXCLUSIVE-LOCK:
       
       /*--- Atualizar Saldo Conta Investimento */

       FIND crapsli WHERE crapsli.cdcooper = glb_cdcooper           AND
                          crapsli.nrdconta = craplci.nrdconta       AND
                    MONTH(crapsli.dtrefere) = MONTH(glb_dtmvtolt)    AND
                     YEAR(crapsli.dtrefere) = YEAR(glb_dtmvtolt) 
                          EXCLUSIVE-LOCK NO-ERROR.

       IF  NOT AVAIL crapsli THEN
           DO:
               ASSIGN aux_dtrefere = 
                      ((DATE(MONTH(glb_dtmvtolt),28,YEAR(glb_dtmvtolt)) + 4) -
                      DAY(DATE(MONTH(glb_dtmvtolt),28,
                      YEAR(glb_dtmvtolt)) + 4)).
           
               CREATE crapsli.
               ASSIGN crapsli.dtrefere = aux_dtrefere
                      crapsli.nrdconta = craplci.nrdconta
                      crapsli.cdcooper = glb_cdcooper.
               VALIDATE crapsli.
           END.
          
       IF   craplci.cdhistor = 485   THEN
            ASSIGN craplot.qtinfoln = craplot.qtinfoln - 1
                   craplot.qtcompln = craplot.qtcompln - 1
                   craplot.nrseqdig = craplot.nrseqdig - 1
                   craplot.vlcompcr = craplot.vlcompcr - craplci.vllanmto
                   craplot.vlinfocr = craplot.vlinfocr - craplci.vllanmto
                   crapsli.vlsddisp = crapsli.vlsddisp - craplci.vllanmto.
       ELSE
       IF   craplci.cdhistor = 486   THEN
            ASSIGN craplot.qtinfoln = craplot.qtinfoln - 1
                   craplot.qtcompln = craplot.qtcompln - 1
                   craplot.nrseqdig = craplot.nrseqdig - 1
                   craplot.vlcompdb = craplot.vlcompdb - craplci.vllanmto
                   craplot.vlinfodb = craplot.vlinfodb - craplci.vllanmto
                   crapsli.vlsddisp = crapsli.vlsddisp + craplci.vllanmto.
       ELSE
       IF   craplci.cdhistor = 487   THEN
            DO:
                ASSIGN craplot.qtinfoln = craplot.qtinfoln - 1
                       craplot.qtcompln = craplot.qtcompln - 1
                       craplot.nrseqdig = craplot.nrseqdig - 1
                       craplot.vlcompcr = craplot.vlcompcr - craplci.vllanmto
                       craplot.vlinfocr = craplot.vlinfocr - craplci.vllanmto
                       crapsli.vlsddisp = crapsli.vlsddisp - craplci.vllanmto.
                
                FOR EACH crapchd WHERE
                         crapchd.cdcooper = glb_cdcooper       AND
                         crapchd.dtmvtolt = craplci.dtmvtolt   AND
                         crapchd.cdagenci = craplci.cdagenci   AND             
                         crapchd.cdbccxlt = craplci.cdbccxlt    AND
                         crapchd.nrdolote = craplci.nrdolote   AND
                         crapchd.nrdconta = craplci.nrdconta   AND
                         crapchd.nrdocmto = craplci.nrdocmto    
                         EXCLUSIVE-LOCK USE-INDEX crapchd3:

                    DELETE crapchd.                                   
                END.
            END.
       ELSE
       IF   craplci.cdhistor = 647   THEN
            DO:
               FIND crapsli WHERE crapsli.cdcooper = glb_cdcooper          AND  
                                  crapsli.nrdconta = craplci.nrdconta      AND
                            MONTH(crapsli.dtrefere)= MONTH(glb_dtmvtolt)   AND
                             YEAR(crapsli.dtrefere)= YEAR(glb_dtmvtolt)  
                                  EXCLUSIVE-LOCK NO-ERROR.
                            
               ASSIGN crapsli.vlsddisp = crapsli.vlsddisp + craplci.vllanmto.
            END.
       ELSE
       IF   craplci.cdhistor = 648   THEN
            DO:

               FIND crapsli WHERE crapsli.cdcooper = glb_cdcooper         AND
                                  crapsli.nrdconta = craplci.nrdconta     AND
                            MONTH(crapsli.dtrefere) = MONTH(glb_dtmvtolt) AND
                             YEAR(crapsli.dtrefere)  = YEAR(glb_dtmvtolt)  
                                  EXCLUSIVE-LOCK NO-ERROR.
                            
               ASSIGN crapsli.vlsddisp = crapsli.vlsddisp - craplci.vllanmto.
            END.

       DELETE craplci.
   END.

   UNIX SILENT VALUE("echo " + "EXCLUSAO DE LOTE - "                +
                     STRING(TODAY)                                  +
                     " " + STRING(TIME,"HH:MM:SS")                  +
                     " Operador: " + glb_cdoperad                   + 
                     " PA: "  + STRING(tel_cdagenci, "zz9")        + 
                     " Banco/Caixa: " + STRING(tel_cdbccxlt, "zz9") + 
                     " Tipo: " + STRING(tel_tplotmov, "z9")         +
                     " Lote: " + STRING(tel_nrdolote,"zzz,zz9")     +
                     " Vlr Inf. Cred.: "                            + 
                     STRING(tel_vlinfocr,"zzz,zzz,zzz,zz9.99")      +
                     " Vlr Inf. Deb.: "                             + 
                     STRING(tel_vlinfodb,"zzz,zzz,zzz,zz9.99")      +   
                     " >> log/lote.log").
            
   DELETE craplot.

   RELEASE crapsli.                                        
   RELEASE craplci.
   
END PROCEDURE.

/* .......................................................................... */


