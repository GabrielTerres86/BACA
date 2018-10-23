/* .............................................................................

   Programa: Fontes/lotee_1.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Outubro/91.                         Ultima atualizacao: 29/03/2017

   Dados referentes ao programa:

   Frequencia: Sempre que chamado pela rotina de exclusao de lotes (on-line).
   Objetivo  : Procurar os lancamentos do lote (tipos 1, 2 e 5) a ser excluido
               e elimina-los.

   Alteracoes: 27/10/94 - Alterado para automatizar a devolucao dos cheques com
                          contra-ordem (Deborah).

               16/05/95 - Alterado para incluir o parametro aux_cdalinea para
                          a rotina geradev (Edson).

               26/06/95 - Alterado para tratar exclusao no crapavs (Edson).

               24/01/97 - Alterado para tratar historico 191 no lugar do
                          47 (Deborah).

               12/01/98 - Alterado para tratar a exclusao do historico 31
                          (Deborah).

               15/01/98 - Alterado para tratar a exclusao do historico 48
                          (Deborah).

               06/07/98 - Antigo fontes/exclote125.p - Alterado para permitir
                          o porte para a v8 (Edson).
                          
               12/08/98 - Alterado para tratar exclusao do historico 29 
                          (Odair).

               17/08/98 - Tratar cdseqtel pelo LAU (Odair)
               
               24/06/99 - Tratar novos historicos 313,340 (Odair)

               17/08/1999 - Tratar incheque = 6 (Deborah).

               18/10/1999 - Tratar exclusao de historico 288 tim celul (odair)
               
               31/10/2000 - Ajustar o programa para que trabalhem por
                            parametros para o historico 30 (Eduardo).

               26/01/2001 - Ajustar o programa para que trabalhem por
                            parametros para o histrico 29 (Eduardo).

               31/01/2001 - Incluir historico 371 (Margarete/Planner).

               04/09/2001 - Indentificar depositos da cooperativa (Margarete).
               
               20/09/2001 - Eliminar histor 21 quando 386 (Margarete).
 
               25/01/2002 - Vincular historicos aos lancamentos (Margarete).

               27/03/2002 - Eliminar histor 353 quando 428 (Margarete).

               08/07/2002 - Eliminar histor 393 quando 394 (Edson).

               26/08/2002 - Alterado para tratar a agencia 3420 do
                            Banco do Brasil (Edson).

               04/12/2002 - Tratar historico 521 da mesma forma que o 21 
                            (Edson)

               04/12/2002 - Tratar historico 526 da mesma forma que o 26 
                            (Edson)

               13/02/2003 - Tratar historico 621 da mesma forma que o 21 
                            (Edson)

               19/03/2003 - Incluir tratamento da Concredi (Margarete).
               
               15/07/2003 - Substituido o Nro de conta fixo do Banco do Brasil
                            pelas variaveis aux_lsconta2 e aux_lsconta3 (Julio).
                 
               06/08/2003 - Tratamento historico (156)

               08/08/2003 - Incluir geracao do controle de movimentacao
                            em especie (Margarete).

               18/05/2004 - Eliminar historico 402 quando 451 (Edson).

               09/06/2004 - Eliminar historico 88 quando 317 (Edson).

               09/06/2004 - Acessar banco generico(Mirtes).
 
               30/07/2004 - Passado parametro quantidade prestacoes
                            calculadas(Mirtes)

               17/09/2004 - Prever exclusao Lancamentos Conta Inv.(Mirtes).
                            LANDPV(Historicos 481-482 / 483-484)
                            
               30/09/2004 - Eliminar historico 349 quando 350 (Edson).

               04/07/2005 - Alimentado campo cdcooper da tabela crapndb (Diego).

               10/10/2005 - Alteracao de crapchq p/ crapfdc (SQLWorks - Andre).
               
               30/11/2005 - Ajustes na conversao crapchq/crapfdc (Edson).
               
               23/12/2005 - Gerar log na exclusao dos lancamentos e
                            ajuste nos parametros passados para a rotina
                            geradev.p (Edson).

               30/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.

               31/05/2006 - Atualizar crapavs para lancamentos referentes
                            a emprestimo vinculado a folha (Julio)
                            
               30/08/2006 - Inclusao de USE-INDEX para o craplcm (Diego)
                            Atualizacao do crapavs para o caso de pagamento
                            de emprestimo. Verificar se a folha referente ao 
                            mes atual ja entrou. (Julio)
               
               04/12/2006 - Substituicao de  "CREATE crapndb" por
                            {includes/gerandb.i} (Elton).
                            
               21/12/2006 - Incluido data de exclusao no arquivo de log (Elton).

               19/04/2007 - Alteracao no tratamento para atualizacao do crapavs
                            para o caso de emprestimo vinculado a folha (Julio)
                            
               31/05/2007 - Tratamento para historico 506/507 (Julio)

               22/08/2007 - Tratamento para exclusao de lancamentos, para 
                            emprestimos vinculados a conta. Atualizacao do
                            crapepr.dtdpagto (Julio)

               10/10/2007 - Alterado o calculo para a data de pagamento do
                            emprestimo (Julio)

               31/10/2007 - Substituicao de procedure p_atualiza_dtdpagto para
                            includes/atualiza_epr.i (Julio)
                            
               09/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "find" da tabela CRAPHIS.   
                          - Kbase IT Solutions - Eduardo Silva.
                          
               12/08/2008 - Unificacao dos bancos, incluido cdcooper na busca da
                            tabela crabhis(Guilherme).
                            
               22/04/2010 - Log dos lancamentos excluidos, VERLOG (Gabriel). 
               
               19/05/2010 - Desativar Rating quando liquidado o Emprestimo
                            (Gabriel). 
                           
               17/06/2010 - Remocao da conferencia da agencia 95 (Vitor).
               
               15/07/2010 - Incluir historicos 524 e 572 (Guilherme).
               
               10/03/2011 - Tratamento do historico 931 (Vitor).
               
               27/05/2011 - Email para controle de movimentacao (Gabriel).
               
               15/05/2012 - substituição do FIND craptab para os registros 
                            CONTACONVE pela chamada do fontes ver_ctace.p
                            (Lucas R.)
                            
               06/08/2012 - Adicionado parametro "codigo do programa" a chamada
                            da funcao geradev. (Fabricio)
                            
               23/01/2014 - Incluir chamada para crapcop logo apos 
                            aux_flgerros = FALSE.
                          - Substituir ( IF craphis.inautori = 1 OR 
                            craplcm.cdhistor = 505 THEN ) pela condicao dos
                            historicos de consorcios 1230,1231,1232,1233,1234.
                          - Logo apos a critica 598 substituir 
                            IF NOT aux_flgerros THEN por ( IF NOT aux_flgerros   
                            AND craphis.inautori = 1  THEN ) ( Lucas R. )
                            
               24/08/2015 - #281178 Para separar os lançamentos manuais ref. a 
                            cheque compensado e não integrado dos demais 
                            lançamentos, foi criado o historico 1873 com base 
                            no 521. Tratamento p hist 1873 igual ao tratamento 
                            do hist 521 (Carlos)
                            
               26/11/2015 - Incluir crapepr.qtmesdec > 0 antes da chamada da procedure 
                            p_atualiza_dtdpagto (Lucas Ranghetti #353659)
                            
               07/12/2015 - #367740 Criado o tratamento para o historico 1874 
                            assim como eh feito com o historico 1873 (Carlos)

			   07/06/2016 - Melhoria 195 folha pagamento (Tiago/Thiago).

               03/10/2016 - Incluido verificacao de acordos de contratos, Prj. 302
                            (Jean Michel).

               14/02/2017 - Alteracao para chamar pc_verifica_situacao_acordo. 
                            (Jaison/James - PRJ302)

			   29/03/2017 - Ajutes para utilizar rotina a rotina pc_gerandb
							(Jonata RKAM M311)
              
              18/10/2018 - PJ450 Regulatório de Credito - Substituído o delete na craplcm e crablcm pela chamada 
                            da rotina h-b1wgen0200.estorna_lancamento_conta. (Heckmann - AMcom)

............................................................................. */

{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i }


DEF  INPUT PARAM par_cdagenci AS INTE                                     NO-UNDO.
DEF  INPUT PARAM par_cdbccxlt AS INTE                                     NO-UNDO.
DEF  INPUT PARAM par_nrdolote AS INTE                                     NO-UNDO.
DEF  INPUT PARAM par_lsconta1 AS CHAR                                     NO-UNDO.
DEF  INPUT PARAM par_lsconta3 AS CHAR                                     NO-UNDO.
DEF  INPUT PARAM par_cdoperad AS CHAR                                     NO-UNDO.                                                                          

DEF OUTPUT PARAM par_situacao AS LOGI                                     NO-UNDO.
DEF OUTPUT PARAM par_qtexclln AS INTE FORMAT "zzzz9"              INIT 0  NO-UNDO.
DEF OUTPUT PARAM par_vlexcldb AS DECI FORMAT "zzz,zzz,zzz,zz9.99" INIT 0  NO-UNDO.
DEF OUTPUT PARAM par_vlexclcr AS DECI FORMAT "zzz,zzz,zzz,zz9.99" INIT 0  NO-UNDO.

DEF VAR aux_cdhistor          AS INTE                                     NO-UNDO.
DEF VAR aux_cdagenci          AS INTE                                     NO-UNDO.
DEF VAR aux_cdcooperativa     AS CHAR FORMAT "x(04)"                      NO-UNDO.
DEF VAR aux_qtprecal_retorno  LIKE crapepr.qtprecal                       NO-UNDO.


DEF BUFFER crablcm FOR craplcm.
DEF BUFFER crabfdc FOR crapfdc.
DEF BUFFER crabhis FOR craphis.
DEF BUFFER crablot FOR craplot.
                                                                          
DEF VAR aux_nrdocmto          AS DECI                                     NO-UNDO.
DEF VAR aux_contador          AS INTE FORMAT "z9"                         NO-UNDO.
DEF VAR aux_flgerros          AS LOGI                                     NO-UNDO.
DEF VAR aux_indevchq          AS INTE                                     NO-UNDO.
DEF VAR aux_cdalinea          AS INTE INIT 0                              NO-UNDO.
DEF VAR aux_nrdconta          AS CHAR FORMAT "x(14)"                      NO-UNDO.
                                                                          
DEF VAR his_txdoipmf          AS DECI FORMAT "zzz,zz9.9999"               NO-UNDO.
DEF VAR his_cdhistor          AS INT                                      NO-UNDO.
DEF VAR his_nrdolote          AS INT                                      NO-UNDO.
DEF VAR his_tplotmov          AS INT                                      NO-UNDO.
DEF VAR his_inliquid          AS INT                                      NO-UNDO.
DEF VAR his_nrctremp          LIKE crapepr.nrctremp                       NO-UNDO.
DEF VAR his_vlsdeved          AS DECI                                     NO-UNDO.
                                                                          
DEF VAR aux_lsconta2          AS CHAR                                     NO-UNDO.
DEF VAR aux_lsconta3          AS CHAR                                     NO-UNDO.
                                                                          
DEF VAR aux_cdhistorc         AS INTE                                     NO-UNDO.
DEF VAR aux_cdagencic         AS CHAR FORMAT "x(04)"                      NO-UNDO.
DEF VAR aux_nrdcontac         AS CHAR FORMAT "x(14)"                      NO-UNDO.
                                                                           
DEF VAR par_nrdrowid          AS ROWID                                    NO-UNDO.

DEF VAR h-b1wgen0014          AS HANDLE                                   NO-UNDO.
DEF VAR h-b1wgen0043          AS HANDLE                                   NO-UNDO.
DEF VAR h-b1wgen9998          AS HANDLE                                   NO-UNDO.

DEF VAR aux_flgretativo       AS INTEGER                                  NO-UNDO.
DEF VAR aux_flgretquitado     AS INTEGER                                  NO-UNDO.
DEF VAR aux_cdrefere          LIKE crapatr.cdrefere                       NO-UNDO.

DEF VAR aux_cdcritic          AS INTEGER                                  NO-UNDO.        
DEF VAR aux_dscritic          AS CHAR                                     NO-UNDO.
DEF VAR h-b1wgen0200          AS HANDLE                                   NO-UNDO.

/*   Leitura da tabela de parametros para indentificar o Nro. da conta do
     tipo de registro 2   */

{includes/gg0000.i}   /* Para conexao Banco Generico */

{includes/atualiza_epr.i} /* Procedure p_atualiza_dtdpagto */

PROCEDURE p_atualiza_avs:

  DEFINE VARIABLE pro_dtrefavs AS DATE           NO-UNDO.
  DEFINE VARIABLE pro_vllanmto AS DECIMAL        NO-UNDO.
  
  ASSIGN pro_vllanmto = DECIMAL(ENTRY(2, craplcm.cdpesqbb, ";"))
         glb_cdcritic = 0.

   IF   CAN-FIND(crapfol WHERE crapfol.cdcooper = glb_cdcooper           AND
                               crapfol.nrdconta = crapepr.nrdconta       AND
                               crapfol.dtrefere = glb_dtultdia NO-LOCK)  THEN
        ASSIGN pro_dtrefavs = glb_dtultdia.
   ELSE
        ASSIGN pro_dtrefavs = glb_dtultdma.

  IF   pro_vllanmto > 0   THEN
       DO:
          IF   craplcm.cdhistor = 317   THEN
               FOR EACH crapavs WHERE crapavs.cdcooper =  glb_cdcooper     AND
                                      crapavs.dtrefere >= pro_dtrefavs     AND
                                      crapavs.nrdconta =  crapepr.nrdconta AND
                                      crapavs.nrdocmto =  crapepr.nrctremp AND
                                      crapavs.cdhistor =  108              AND
                                      crapavs.tpdaviso =  1                AND
                                      crapavs.insitavs =  0
                                      EXCLUSIVE-LOCK BY crapavs.dtrefere:

                   ASSIGN crapavs.vldebito = crapavs.vldebito + pro_vllanmto
                          crapavs.vlestdif = crapavs.vldebito -           
                                                            crapavs.vllanmto.
                    
                   IF   crapavs.vllanmto > crapavs.vldebito  THEN 
                        ASSIGN crapavs.insitavs = 0.
                   ELSE
                        ASSIGN crapavs.insitavs = 1.

                   LEAVE.
                   
               END. /* FOR EACH crapavs ...*/
          ELSE
               FOR EACH crapavs WHERE crapavs.cdcooper =  glb_cdcooper     AND
                                      crapavs.dtrefere >= pro_dtrefavs     AND
                                      crapavs.nrdconta =  crapepr.nrdconta AND
                                      crapavs.nrdocmto =  crapepr.nrctremp AND
                                      crapavs.cdhistor =  108              AND
                                      crapavs.tpdaviso =  1                AND
                                      crapavs.vldebito >  0            
                                      EXCLUSIVE-LOCK BY crapavs.dtrefere 
                                      DESCENDING:

                   ASSIGN crapavs.vldebito = crapavs.vldebito - pro_vllanmto.
                    
                   IF   crapavs.vldebito < 0   THEN
                        ASSIGN crapavs.vldebito = 0.
                            
                   ASSIGN crapavs.vlestdif = crapavs.vldebito - 
                                                            crapavs.vllanmto.
                    
                  IF   crapavs.vllanmto > crapavs.vldebito  THEN 
                       ASSIGN crapavs.insitavs = 0.
                  ELSE
                       ASSIGN crapavs.insitavs = 1.

                  LEAVE.
                  
               END. /* FOR EACH crapavs... */

          RELEASE crapavs. /* Nao tirar este RELEASE */
          
       END. /* IF pro_vllanmto .... */
       
END. /* p_atualiza_avs */

RUN fontes/ver_ctace.p(INPUT glb_cdcooper,
                       INPUT 2,
                       OUTPUT aux_lsconta2).
                   
/*   Leitura da tabela de parametros para indentificar o Nro. da conta do
     tipo de registro 3   */

RUN fontes/ver_ctace.p(INPUT glb_cdcooper,
                       INPUT 3,
                       OUTPUT aux_lsconta3).
                   

/*   FIM DA LEITURA DA TABELA DE PARAMETROS   */

DO WHILE TRUE:

   DO  aux_contador = 1 TO 20:

       FIND FIRST craplcm WHERE craplcm.cdcooper = glb_cdcooper   AND
                                craplcm.dtmvtolt = glb_dtmvtolt   AND
                                craplcm.cdagenci = par_cdagenci   AND
                                craplcm.cdbccxlt = par_cdbccxlt   AND
                                craplcm.nrdolote = par_nrdolote
                                USE-INDEX craplcm3
                                EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

       IF   NOT AVAILABLE craplcm   THEN
            IF   LOCKED craplcm  THEN
                 DO:
                     ASSIGN glb_cdcritic = 85
                            par_situacao = FALSE.
                     PAUSE 1 NO-MESSAGE.
                     NEXT.
                 END.
            ELSE
                 DO:
                     par_situacao = TRUE.
                     RETURN.  /* Retorna quando nao ha mais lanctos */
                 END.

       ASSIGN aux_nrdocmto = craplcm.nrdocmto
              aux_indevchq = 0
              aux_cdalinea = 0.

       FIND craphis WHERE
            craphis.cdcooper = glb_cdcooper AND
            craphis.cdhistor = craplcm.cdhistor
                          NO-LOCK NO-ERROR.
       
       IF   NOT AVAILABLE craphis   THEN
            DO:
                glb_cdcritic = 80.
                par_situacao = FALSE.
                LEAVE.
            END.          
       IF   craphis.inavisar = 1   THEN
            DO:
                FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                                   crapass.nrdconta = craplcm.nrdconta
                                   NO-LOCK NO-ERROR.
                                    
                IF   NOT AVAILABLE crapass   THEN
                     DO:
                         ASSIGN glb_cdcritic = 9
                                par_situacao = FALSE.
                         LEAVE.
                     END.

                DO WHILE TRUE:

                   FIND crapavs WHERE crapavs.cdcooper = glb_cdcooper       AND
                                      crapavs.dtmvtolt = craplcm.dtmvtolt   AND
                                      crapavs.cdempres = 0                  AND
                                      crapavs.cdagenci = crapass.cdagenci   AND
                                      crapavs.cdsecext = crapass.cdsecext   AND
                                      crapavs.nrdconta = craplcm.nrdconta   AND
                                      crapavs.dtdebito = craplcm.dtmvtolt   AND
                                      crapavs.cdhistor = craplcm.cdhistor   AND
                                      crapavs.nrdocmto = craplcm.nrdocmto
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                   IF   NOT AVAILABLE crapavs   THEN
                        IF   LOCKED crapavs   THEN
                             DO:
                                 PAUSE 2 NO-MESSAGE.
                                 NEXT.
                             END.
                        ELSE
                        IF   craplcm.nrdolote > 6499   AND
                             craplcm.nrdolote < 7000   THEN
                             glb_cdcritic = 0.
                        ELSE
                             glb_cdcritic = 448.

                   LEAVE.

                END.  /*  Fim do DO WHILE TRUE  */

                IF   glb_cdcritic > 0   THEN
                     DO:
                          par_situacao = FALSE.
                         LEAVE.
                     END.
            END.
       
       IF   craplcm.cdhistor = 354   OR    /* credito cotas */
            craplcm.cdhistor = 451   OR    /* credito de estorno de cotas */
            craplcm.cdhistor = 275   OR    /* pagto emprestimo */
            craplcm.cdhistor = 394   OR    /* pagto emprestimo pelo aval  */
            craplcm.cdhistor = 428   OR    /* pagto empr c/cap */
            craplcm.cdhistor = 506   OR    /* estorno pagto empr c/cap */
            craplcm.cdhistor = 127   OR    /* debito cotas */
            craplcm.cdhistor = 104   OR    /* trf. val. isenta  */
            craplcm.cdhistor = 317   OR    /* Estorno pagto emprestimo */
            craplcm.cdhistor = 3501  OR    /* Transf. para prejuizo  */
            craplcm.cdhistor = 302   OR    /* trf. val. nao isenta  */
            craplcm.cdhistor = 931   THEN  /* credito cotas proc */
            DO:
                IF   craplcm.cdhistor = 354   THEN
                     ASSIGN his_cdhistor = 81
                            his_nrdolote = 10002.
                ELSE
                IF   craplcm.cdhistor = 451   THEN
                     ASSIGN his_cdhistor = 402
                            his_nrdolote = 10002.
                ELSE
                IF   craplcm.cdhistor = 275   THEN
                     ASSIGN his_cdhistor = 91
                            his_nrdolote = 10001.
                ELSE     
                IF   craplcm.cdhistor = 394   THEN
                     ASSIGN his_cdhistor = 393
                            his_nrdolote = 10001.
                ELSE     
                IF   craplcm.cdhistor = 428   THEN
                     ASSIGN his_cdhistor = 353
                            his_nrdolote = 10001.
                ELSE
                IF   craplcm.cdhistor = 506   THEN
                     ASSIGN his_cdhistor = 507
                            his_nrdolote = 10001.
                ELSE
                IF   craplcm.cdhistor = 317   THEN
                     ASSIGN his_cdhistor = 88
                            his_nrdolote = 10001.
                ELSE
                IF   craplcm.cdhistor = 350   THEN
                     ASSIGN his_cdhistor = 349
                            his_nrdolote = 10001.
                ELSE
                IF   craplcm.cdhistor = 127   THEN
                     ASSIGN his_cdhistor = 61
                            his_nrdolote = 10002.
                ELSE
                IF   craplcm.cdhistor = 104   OR
                     craplcm.cdhistor = 302   THEN
                     ASSIGN his_cdhistor = 303
                            his_nrdolote = 10003.
                ELSE
                IF   craplcm.cdhistor = 931   THEN
                     ASSIGN his_cdhistor = 932
                            his_nrdolote = 10002.
                
                FIND crabhis WHERE crabhis.cdcooper = glb_cdcooper AND
                                   crabhis.cdhistor = his_cdhistor
                                   NO-LOCK NO-ERROR.

                IF   NOT AVAILABLE crabhis   THEN
                     DO:
                         glb_cdcritic = 93.
                         par_situacao = FALSE.
                         LEAVE.
                     END.
                    
                DO WHILE TRUE:
                
                   FIND crablot WHERE crablot.cdcooper = glb_cdcooper   AND
                                      crablot.dtmvtolt = glb_dtmvtolt   AND
                                      crablot.cdagenci = 1              AND
                                      crablot.cdbccxlt = 100            AND
                                      crablot.nrdolote = his_nrdolote
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                    
                   IF   NOT AVAILABLE crablot   THEN
                        IF   LOCKED crablot   THEN
                             DO:
                                 PAUSE 2 NO-MESSAGE.
                                 NEXT.
                             END.
                        ELSE
                        DO:
                             LEAVE.
                        END.
                  
                   LEAVE.
                END.

                IF   NOT AVAILABLE crablot   THEN
                     DO:
                         glb_cdcritic = 60.
                         par_situacao = FALSE.
                         LEAVE.
                     END.

                IF   craplcm.cdhistor = 104   OR
                     craplcm.cdhistor = 302   THEN
                     DO: 
                   
                         FIND crablcm WHERE
                              crablcm.cdcooper = glb_cdcooper            AND
                              crablcm.dtmvtolt = glb_dtmvtolt            AND
                              crablcm.cdagenci = 1                       AND
                              crablcm.cdbccxlt = 100                     AND
                              crablcm.nrdolote = his_nrdolote            AND
                              crablcm.nrdctabb = INT(craplcm.cdpesqbb)   AND
                              crablcm.nrdocmto = craplcm.nrdocmto  
                              USE-INDEX craplcm1 EXCLUSIVE-LOCK NO-ERROR.
                        
                         IF   NOT AVAILABLE crablcm   THEN
                              DO:
                                  glb_cdcritic = 81.
                                  par_situacao = FALSE.
                                  LEAVE.
                              END.
                    
                         UNIX SILENT VALUE("echo " + 
                                           STRING(glb_dtmvtolt, "99/99/9999") +
                                           " - "   +
                                           STRING(TIME,"HH:MM:SS") +
                                           " - EXCLUSAO TRF. VAL." + "' --> '" +
                                           " Operador: " + glb_cdoperad +
                                           " Hst: " +
                                           STRING(craplcm.cdhistor,"zzz9") +
                                           " De: " + 
                                           STRING(craplcm.nrdconta,
                                                  "zzzz,zzz,9") +
                                           " Para: " + 
                                           STRING(crablcm.nrdconta,
                                                  "zzzz,zzz,9") +
                                           " Docmto: " + 
                                           STRING(craplcm.nrdocmto,
                                                  "zzz,zzz,zz9") +
                                           " Valor: " + 
                                           STRING(craplcm.vllanmto,
                                                  "zzz,zzz,zzz,zz9.99") +
                                           " >> log/landpv.log").
                        
                         /*DELETE crablcm.*/
                         IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
                             RUN sistema/generico/procedures/b1wgen0200.p PERSISTENT SET h-b1wgen0200.
                                           
                         RUN estorna_lancamento_conta IN h-b1wgen0200 
                             (INPUT crablcm.cdcooper               /* par_cdcooper */
                             ,INPUT crablcm.dtmvtolt               /* par_dtmvtolt */
                             ,INPUT crablcm.cdagenci               /* par_cdagenci*/
                             ,INPUT crablcm.cdbccxlt               /* par_cdbccxlt */
                             ,INPUT crablcm.nrdolote               /* par_nrdolote */
                             ,INPUT crablcm.nrdctabb               /* par_nrdctabb */
                             ,INPUT crablcm.nrdocmto               /* par_nrdocmto */
                             ,INPUT crablcm.cdhistor               /* par_cdhistor */           
                             ,INPUT crablcm.nrctachq               /* par_nrctachq */
                             ,INPUT crablcm.nrdconta               /* par_nrdconta */
                             ,INPUT crablcm.cdpesqbb               /* par_cdpesqbb */
                             ,OUTPUT aux_cdcritic                  /* Codigo da critica                             */
                             ,OUTPUT aux_dscritic).                /* Descricao da critica                          */
                                             
                         IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
                             DO: 
                                 /* Tratamento de erros conforme anteriores */                           
                                 glb_cdcritic = aux_cdcritic.
                                 aux_flgerros = TRUE.
                                 par_situacao = FALSE.
                                 LEAVE.
                             END.
                                   
                         IF  VALID-HANDLE(h-b1wgen0200) THEN
                             DELETE PROCEDURE h-b1wgen0200.
                         /* Fim do DELETE */
                     END.
                ELSE
                IF   craplcm.cdhistor = 354   OR
                     craplcm.cdhistor = 451   OR
                     craplcm.cdhistor = 127   THEN
                     DO:   
                         FIND  craplct WHERE
                               craplct.cdcooper =glb_cdcooper      AND
                               craplct.dtmvtolt = glb_dtmvtolt     AND
                               craplct.cdagenci = 1                AND
                               craplct.cdbccxlt = 100              AND
                               craplct.nrdolote = his_nrdolote     AND
                               craplct.nrdconta = craplcm.nrdctabb AND
                               craplct.nrdocmto = craplcm.nrdocmto   
                               EXCLUSIVE-LOCK NO-ERROR.
                       
                         IF   NOT AVAILABLE craplct   THEN
                              DO:                
                                  glb_cdcritic = 81.
                                  par_situacao = FALSE.
                                  LEAVE.           
                              END.
                    
                         FIND crapcot WHERE 
                              crapcot.cdcooper = glb_cdcooper  AND
                              crapcot.nrdconta = craplct.nrdconta
                              EXCLUSIVE-LOCK NO-ERROR.

                         IF   NOT AVAILABLE crapcot   THEN
                              DO:
                                  glb_cdcritic = 169.
                                  par_situacao = FALSE.
                                  LEAVE.
                              END.
         
                         IF   crabhis.inhistor = 6   THEN
                              crapcot.vldcotas = crapcot.vldcotas - 
                                                         craplcm.vllanmto.
                         ELSE
                         IF   crabhis.inhistor = 16   THEN
                              crapcot.vldcotas = crapcot.vldcotas + 
                                                         craplcm.vllanmto.
 
                         DELETE craplct. 
                     END.
                ELSE 
                    IF  craplcm.cdhistor = 931 THEN 
                        DO: 
                           FIND  craplct WHERE
                                 craplct.cdcooper = glb_cdcooper     AND
                                 craplct.dtmvtolt = glb_dtmvtolt     AND
                                 craplct.cdagenci = 1                AND
                                 craplct.cdbccxlt = 100              AND
                                 craplct.nrdolote = his_nrdolote     AND
                                 craplct.nrdconta = craplcm.nrdctabb AND
                                 craplct.nrdocmto = craplcm.nrdocmto   
                                 EXCLUSIVE-LOCK NO-ERROR.
                       
                           IF   NOT AVAILABLE craplct   THEN
                                DO:                
                                    glb_cdcritic = 81.
                                    par_situacao = FALSE.
                                    LEAVE.           
                                END.
                    
                           FIND crapcot WHERE 
                                crapcot.cdcooper = glb_cdcooper  AND
                                crapcot.nrdconta = craplct.nrdconta
                                EXCLUSIVE-LOCK NO-ERROR.
                           
                           IF   NOT AVAILABLE crapcot   THEN
                                DO:
                                    glb_cdcritic = 169.
                                    par_situacao = FALSE.
                                    LEAVE.
                                END.
                           
                           
                           ASSIGN crapcot.vldcotas = crapcot.vldcotas + 
                                                     craplct.vllanmto.
                           
                           DELETE craplct. 

                           FIND FIRST craplct WHERE
                                      craplct.cdcooper = glb_cdcooper     AND
                                      craplct.nrdconta = craplcm.nrdctabb AND
                                      craplct.cdhistor = 930              AND
                                      craplct.dtlibera <> ?               AND
                                      craplct.dtcrdcta <> ?
                                      EXCLUSIVE-LOCK NO-ERROR.

                           IF AVAIL craplct THEN
                               ASSIGN craplct.dtcrdcta = ?.

                        END.
                ELSE           /*  Hst 275, 394, 428, 349, 317 e 506  */
                     DO:
                         RUN fontes/saldo_epr.p 
                                    (INPUT  craplcm.nrdconta,
                                     INPUT  INT(ENTRY(1,craplcm.cdpesqbb,";")),
                                     OUTPUT his_vlsdeved,
                                     OUTPUT aux_qtprecal_retorno).
            
                          IF   glb_cdcritic > 0   THEN
                              DO:
                                  par_situacao = FALSE.
                                  LEAVE.
                              END.
                    
                         FIND crapepr WHERE
                              crapepr.cdcooper = glb_cdcooper     AND  
                              crapepr.nrdconta = craplcm.nrdconta AND
                              crapepr.nrctremp = INT(ENTRY(1,
                                                     craplcm.cdpesqbb,";"))
                              EXCLUSIVE-LOCK NO-ERROR.
                         
                         IF   NOT AVAILABLE crapepr   THEN
                              DO:
                                  glb_cdcritic = 356.
                                  par_situacao = FALSE.
                                  LEAVE.
                              END.
                         
                         IF    crapepr.flgpagto    THEN
                               RUN p_atualiza_avs.
                         ELSE
                               IF  crapepr.qtmesdec > 0 THEN
                                   RUN p_atualiza_dtdpagto(INPUT FALSE,
                                                           INPUT craplcm.vllanmto).
                               
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

                         FIND  craplem WHERE
                               craplem.cdcooper = glb_cdcooper       AND 
                               craplem.dtmvtolt = glb_dtmvtolt       AND
                               craplem.cdagenci = 1                  AND
                               craplem.cdbccxlt = 100                AND
                               craplem.nrdolote = his_nrdolote       AND
                               craplem.nrdconta = craplcm.nrdctabb   AND
                               craplem.nrdocmto = craplcm.nrdocmto
                               EXCLUSIVE-LOCK NO-ERROR.
                         
                         IF   NOT AVAILABLE craplem   THEN
                              DO:
                                  glb_cdcritic = 81.
                                  par_situacao = FALSE.
                                  LEAVE.
                              END.

                         IF   craplem.cdhistor = 88   OR
                              craplem.cdhistor = 507  THEN
                              crapepr.inliquid = 
                                      IF (his_vlsdeved - craplem.vllanmto) > 0
                                          THEN 0
                                          ELSE 1.
                         ELSE
                              crapepr.inliquid = 
                                      IF (his_vlsdeved + craplem.vllanmto) > 0
                                          THEN 0
                                          ELSE 1.
                         
                         RUN sistema/generico/procedures/b1wgen0043.p
                                             PERSISTENT SET h-b1wgen0043.
    
                         /* Verifica se tem q ativar/desativar Rating */
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
                                       
                                  UNDO , RETURN "NOK".
                                              
                         END.
            
                         DELETE craplem.
                        
                     END.           
                    
                ASSIGN crablot.qtcompln = crablot.qtcompln - 1
                       crablot.qtinfoln = crablot.qtinfoln - 1.
               
                IF   crabhis.indebcre = "D"   THEN
                     ASSIGN crablot.vlcompdb = 
                                    crablot.vlcompdb - craplcm.vllanmto
                            crablot.vlinfodb = 
                                    crablot.vlinfodb - craplcm.vllanmto.
                ELSE
                IF   crabhis.indebcre = "C"   THEN
                     ASSIGN crablot.vlcompcr = 
                                    crablot.vlcompcr - craplcm.vllanmto
                            crablot.vlinfocr = 
                                    crablot.vlinfocr - craplcm.vllanmto.
               
                IF   crablot.qtcompln = 0 AND
                     crablot.qtinfoln = 0 AND
                     crablot.vlcompdb = 0 AND
                     crablot.vlinfodb = 0 AND
                     crablot.vlcompcr = 0 AND
                     crablot.vlinfocr = 0 THEN       
                     DELETE crablot.
                            
            END.
       ELSE
       IF   CAN-DO("21,47,49,50,156,191,313,340,521,524,572,621,1873,1874",
                   STRING(craplcm.cdhistor))  THEN
            DO:
                glb_nrchqsdv = INT(SUBSTR(STRING(craplcm.nrdocmto,
                                                 "9999999"),1,6)).

                DO WHILE TRUE:

                   aux_flgerros = FALSE.

                   FIND crapfdc WHERE crapfdc.cdcooper = glb_cdcooper       AND
                                      crapfdc.nrdctitg = craplcm.nrdctitg   AND
                                      crapfdc.nrcheque = glb_nrchqsdv
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                     
                   IF   NOT AVAILABLE crapfdc   THEN
                        IF   LOCKED crapfdc   THEN
                             DO:
                                 PAUSE 1 NO-MESSAGE.
                                 NEXT.
                             END.
                        ELSE
                             DO:
                                 ASSIGN glb_cdcritic = 22
                                        par_situacao = FALSE
                                        aux_flgerros = TRUE
                                        aux_contador = 1.
                                 LEAVE.
                             END.
                   LEAVE.
                END.

                IF   aux_flgerros   THEN
                     LEAVE.

                IF   craplcm.cdhistor = 21   OR
                     craplcm.cdhistor = 50   OR
                     craplcm.cdhistor = 313  OR
                     craplcm.cdhistor = 524  OR
                     craplcm.cdhistor = 572  OR
                     craplcm.cdhistor = 521  OR
                     craplcm.cdhistor = 621  OR 
                     craplcm.cdhistor = 1873 OR
                     craplcm.cdhistor = 1874 THEN
                     DO:
                         IF   CAN-DO("0,1,2",STRING(crapfdc.incheque)) THEN
                              DO:
                                  ASSIGN glb_cdcritic = 99
                                         par_situacao = FALSE
                                         aux_contador = 1.
                                  LEAVE.
                              END.

                         ASSIGN crapfdc.incheque = crapfdc.incheque - 5
                                crapfdc.dtliqchq = ?
                                crapfdc.vlcheque = 0
                                crapfdc.vldoipmf = 0.

                         IF   crapfdc.incheque = 1 THEN
                              aux_indevchq = 5.
                     END.
                ELSE
                     DO:
                         IF   CAN-DO("5,6,7",STRING(crapfdc.incheque)) THEN
                              DO:
                                  ASSIGN glb_cdcritic = 97
                                         par_situacao = FALSE
                                         aux_contador = 1.
                                  LEAVE.
                              END.

                         ASSIGN crapfdc.incheque = crapfdc.incheque + 5
                                crapfdc.dtliqchq = glb_dtmvtolt
                                crapfdc.vlcheque = craplcm.vllanmto.

                         IF   craplcm.cdhistor = 47  OR
                              craplcm.cdhistor = 156 OR
                              craplcm.cdhistor = 191 OR
                              craplcm.cdhistor = 340 THEN
                              ASSIGN aux_indevchq = 6
                                     aux_cdalinea = INTEGER(craplcm.cdpesqbb).
                     END.
            END.
       ELSE
       IF   CAN-DO(aux_lsconta2, STRING(craplcm.nrdctabb))   THEN
            DO:
                ASSIGN glb_nrchqsdv = INT(SUBSTR(STRING(craplcm.nrdocmto,
                                                        "9999999"),1,6)).

                DO WHILE TRUE:

                   aux_flgerros = FALSE.

                   FIND crapfdc WHERE  crapfdc.cdcooper = glb_cdcooper      AND
                                       crapfdc.nrdctitg = craplcm.nrdctitg  AND
                                       crapfdc.nrcheque = glb_nrchqsdv
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                   IF   NOT AVAILABLE crapfdc   THEN
                        IF   LOCKED crapfdc   THEN
                             DO:
                                 PAUSE 1 NO-MESSAGE.
                                 NEXT.
                             END.
                        ELSE
                             DO:
                                 ASSIGN glb_cdcritic = 22
                                        par_situacao = FALSE
                                        aux_flgerros = TRUE
                                        aux_contador = 1.
                                 LEAVE.
                             END.
                   LEAVE.

                END.  /*  Fim do DO WHILE TRUE  */

                IF   aux_flgerros   THEN
                     LEAVE.

                IF   crapfdc.tpcheque <> 2   THEN      /*  DEVE SER CHQ TB  */
                     DO:
                         ASSIGN glb_cdcritic = 999
                                par_situacao = FALSE
                                aux_contador = 1.
                         LEAVE.
                     END.
                                
                IF   craplcm.cdhistor = 59 THEN
                     DO:
                         IF   CAN-DO("0,1,2",STRING(crapfdc.incheque))  THEN
                              DO:
                                  ASSIGN glb_cdcritic = 99
                                         par_situacao = FALSE
                                         aux_contador = 1.
                                  LEAVE.
                              END.

                         ASSIGN crapfdc.incheque = crapfdc.incheque - 5
                                crapfdc.dtliqchq = ?
                                crapfdc.vlcheque = 0
                                crapfdc.vldoipmf = 0.

                         IF   crapfdc.incheque = 1 THEN
                              aux_indevchq = 7.
                     END.
                ELSE
                     DO:
                         IF   CAN-DO("5,6,7",STRING(crapfdc.incheque))  THEN
                              DO:
                                  ASSIGN glb_cdcritic = 97
                                         par_situacao = FALSE
                                         aux_contador = 1.
                                  LEAVE.
                              END.

                         ASSIGN crapfdc.incheque = crapfdc.incheque + 5
                                crapfdc.dtliqchq = glb_dtmvtolt
                                crapfdc.vlcheque = craplcm.vllanmto.

                         IF   craplcm.cdhistor = 78 THEN
                              ASSIGN aux_indevchq = 8
                                     aux_cdalinea = INTEGER(craplcm.cdpesqbb).
                     END.
            END.
       ELSE
       IF   CAN-DO(aux_lsconta3, STRING(craplcm.nrdctabb))   THEN
            DO:
                DO WHILE TRUE:

                   ASSIGN glb_nrchqsdv = INT(SUBSTR(STRING(craplcm.nrdocmto,
                                                           "9999999"),1,6))
                          aux_flgerros = FALSE.
                                     
                   FIND crapfdc WHERE crapfdc.cdcooper = glb_cdcooper       AND
                                      crapfdc.nrdctitg = craplcm.nrdctitg   AND
                                      crapfdc.nrcheque = glb_nrchqsdv
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                   
                   IF   NOT AVAILABLE crapfdc   THEN
                        IF   LOCKED crapfdc   THEN
                             DO:
                                 PAUSE 1 NO-MESSAGE.
                                 NEXT.
                             END.
                        ELSE
                             DO:
                                 ASSIGN glb_cdcritic = 22
                                        par_situacao = FALSE
                                        aux_flgerros = TRUE
                                        aux_contador = 1.
                                 LEAVE.
                             END.
                   LEAVE.
                END.

                IF   crapfdc.tpcheque <> 3   THEN   /* DEVE SER CHQ. SAL  */
                     DO:
                         ASSIGN glb_cdcritic = 999
                                par_situacao = FALSE
                                aux_flgerros = TRUE
                                aux_contador = 1.
                         LEAVE.
                     END.

                IF   NOT aux_flgerros   AND   
                    (craplcm.cdhistor = 26   OR
                     craplcm.cdhistor = 526) THEN
                     IF   CAN-FIND(craplcm WHERE
                                   craplcm.cdcooper = glb_cdcooper       AND
                                   craplcm.nrdconta = crapfdc.nrdconta   AND
                                   craplcm.dtmvtolt = glb_dtmvtolt       AND
                                   craplcm.cdhistor = 101                AND
                                   craplcm.nrdocmto = aux_nrdocmto
                                   USE-INDEX craplcm2)                   THEN
                          ASSIGN glb_cdcritic = 343
                                 par_situacao = FALSE
                                 aux_flgerros = TRUE
                                 aux_contador = 1.

                IF   aux_flgerros   THEN
                     LEAVE.

                ASSIGN crapfdc.dtliqchq = ?
                       crapfdc.vlcheque = 0
                       crapfdc.vldoipmf = 0.

                IF   crapfdc.incheque = 5   THEN
                     crapfdc.incheque = 0.
                ELSE
                IF   crapfdc.incheque = 6   THEN
                     crapfdc.incheque = 1.
                ELSE
                IF   crapfdc.incheque = 7   THEN
                     crapfdc.incheque = 2.
                ELSE
                     DO:
                         ASSIGN glb_cdcritic = 99
                                par_situacao = FALSE
                                aux_contador = 1.
                         LEAVE.
                     END.
            END.
       ELSE
       IF   CAN-DO("3,4,5",STRING(craphis.inhistor))   THEN
            DO:
                DO WHILE TRUE:

                   aux_flgerros = FALSE.

                   FIND crapdpb WHERE crapdpb.cdcooper = glb_cdcooper       AND
                                      crapdpb.dtmvtolt = craplcm.dtmvtolt   AND
                                      crapdpb.cdagenci = craplcm.cdagenci   AND
                                      crapdpb.cdbccxlt = craplcm.cdbccxlt   AND
                                      crapdpb.nrdolote = craplcm.nrdolote   AND
                                      crapdpb.nrdconta = craplcm.nrdconta   AND
                                      crapdpb.nrdocmto = craplcm.nrdocmto
                                      USE-INDEX crapdpb1 
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                   IF   NOT AVAILABLE crapdpb   THEN
                        IF   LOCKED crapdpb   THEN
                             DO:
                                 PAUSE 1 NO-MESSAGE.
                                 NEXT.
                             END.
                        ELSE
                             ASSIGN glb_cdcritic = 82
                                    par_situacao = FALSE
                                    aux_flgerros = TRUE
                                    aux_contador = 1.
                   ELSE
                        IF   crapdpb.inlibera = 2   THEN
                             ASSIGN glb_cdcritic = 220
                                    par_situacao = FALSE
                                    aux_flgerros = TRUE
                                    aux_contador = 1.

                   LEAVE.

                END.  /*  Fim do DO WHILE TRUE  */

                IF   aux_flgerros   THEN
                     LEAVE.

                DELETE crapdpb.
            END.
       ELSE
       IF   CAN-DO("13,14,15",STRING(craphis.inhistor))   THEN
            DO:
                DO WHILE TRUE:

                   FIND FIRST crapdpb WHERE
                              crapdpb.cdcooper = glb_cdcooper      AND
                              crapdpb.nrdconta = craplcm.nrdconta  AND
                              crapdpb.nrdocmto = craplcm.nrdocmto
                              USE-INDEX crapdpb2
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                   IF   NOT AVAILABLE crapdpb   THEN
                        IF   LOCKED crapdpb   THEN
                             DO:
                                 PAUSE 1 NO-MESSAGE.
                                 NEXT.
                             END.
                        ELSE
                             ASSIGN glb_cdcritic = 82
                                    par_situacao = FALSE
                                    aux_flgerros = TRUE
                                    aux_contador = 1.
                   ELSE
                        IF   crapdpb.inlibera = 1   THEN
                             ASSIGN glb_cdcritic = 238
                                    par_situacao = FALSE
                                    aux_flgerros = TRUE
                                    aux_contador = 1.

                   LEAVE.

                END.  /*  Fim do DO WHILE TRUE  */

                IF   aux_flgerros   THEN
                     LEAVE.

                crapdpb.inlibera = 1.
            END.
       ELSE
       IF   craphis.inautori = 1    OR
           (craplcm.cdhistor = 1230 OR  
            craplcm.cdhistor = 1231 OR
            craplcm.cdhistor = 1232 OR
            craplcm.cdhistor = 1233 OR
            craplcm.cdhistor = 1234) THEN /* historicos de consorcios */
            DO:
               
               ASSIGN aux_flgerros = FALSE
			          aux_cdrefere = 0.

               FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper 
                                  NO-LOCK NO-ERROR.

               IF  NOT AVAIL crapcop THEN
                   DO:
                       ASSIGN aux_flgerros = TRUE
                              par_situacao = FALSE
                              glb_cdcritic = 651.
                       LEAVE.
                   END.
                   

               FIND FIRST craplau WHERE craplau.cdcooper = glb_cdcooper  
                                    AND craplau.nrdconta = craplcm.nrdconta
                                    AND craplau.cdhistor = craplcm.cdhistor
                                    AND craplau.dtdebito = craplcm.dtmvtolt
                                    AND craplau.nrdocmto = craplcm.nrdocmto
                                    NO-LOCK NO-ERROR.

               IF   NOT AVAILABLE craplau THEN
                    ASSIGN aux_flgerros = TRUE
                           par_situacao = FALSE
                           glb_cdcritic = 597.

               IF   NOT aux_flgerros AND
                    craphis.inautori = 1 THEN
                    DO:

                        FIND crapatr WHERE
                             crapatr.cdcooper = glb_cdcooper        AND
                             crapatr.nrdconta = craplcm.nrdconta    AND
                             crapatr.cdhistor = craplcm.cdhistor    AND
                             crapatr.cdrefere = craplau.nrcrcard    
                             NO-LOCK NO-ERROR.

                        IF   NOT AVAILABLE  crapatr   THEN
                             FIND crapatr WHERE
                                  crapatr.cdcooper = glb_cdcooper        AND
                                  crapatr.nrdconta = craplcm.nrdconta    AND
                                  crapatr.cdhistor = craplcm.cdhistor    AND
                                  crapatr.cdrefere = craplau.nrdocmto
                                  NO-LOCK NO-ERROR.

                         IF   NOT AVAILABLE crapatr THEN
                              ASSIGN aux_flgerros = TRUE
                                     par_situacao = FALSE
                                     glb_cdcritic = 598.

					     ASSIGN aux_cdrefere = crapatr.cdrefere WHEN AVAIL crapatr.

                    END.
               
               IF  aux_flgerros  THEN
                   LEAVE.

               
               /* Verifica se possui contrato de acordo */
                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                /* Verifica se ha contratos de acordo */
                RUN STORED-PROCEDURE pc_gerandb
                aux_handproc = PROC-HANDLE NO-ERROR (INPUT glb_cdcooper
			                                        ,INPUT craplau.cdhistor
                                                    ,INPUT craplcm.nrdconta
													,INPUT aux_cdrefere
													,INPUT craplau.vllanaut
													,INPUT craplau.cdseqtel
													,INPUT craplau.nrdocmto
													,INPUT crapcop.cdagesic
													,INPUT crapass.nrctacns
													,INPUT crapass.cdagenci
													,INPUT craplau.cdempres
													,INPUT craplau.idlancto
													,INPUT glb_cdcritic
                                                    ,OUTPUT 0
                                                    ,OUTPUT "").

                CLOSE STORED-PROC pc_gerandb
                aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                      
                ASSIGN glb_cdcritic = 0
                       glb_dscritic = ""
                       glb_cdcritic = INT(pc_gerandb.pr_cdcritic) WHEN pc_gerandb.pr_cdcritic <> ?
                       glb_dscritic = TRIM(pc_gerandb.pr_dscritic) WHEN pc_gerandb.pr_dscritic <> ?.
                      
                IF glb_cdcritic > 0 THEN
				   DO:
						RUN fontes/critic.p.
						BELL.
						MESSAGE glb_dscritic.
						ASSIGN  glb_cdcritic = 0
						        aux_flgerros = TRUE
								par_situacao = FALSE.
						LEAVE.
				   END.
				ELSE IF glb_dscritic <> ? AND glb_dscritic <> "" THEN
                   DO:
					       MESSAGE glb_dscritic.
					       ASSIGN  glb_cdcritic = 0
						           aux_flgerros = TRUE
                               par_situacao = FALSE.
                        LEAVE.
                   END.                               
                   
                   
            END.

       
       ASSIGN par_qtexclln = par_qtexclln + 1
              aux_contador = 0.

       IF   craphis.indebcre = "D"   THEN
            par_vlexcldb = par_vlexcldb + craplcm.vllanmto.
       ELSE
            par_vlexclcr = par_vlexcldb + craplcm.vllanmto.

       IF   glb_cdcritic = 0 AND
            aux_indevchq > 0 THEN
            DO:
                RUN fontes/geradev.p
                    (INPUT  glb_cdcooper,
                     INPUT  glb_dtmvtolt, 
                     INPUT  IF  (craplcm.nrdconta = craplcm.nrdctabb) 
                                THEN 756
                                ELSE 1,
                     INPUT  aux_indevchq,     
                     INPUT  craplcm.nrdconta,
                     INPUT  craplcm.nrdocmto, 
                     INPUT  craplcm.nrdctitg,
                     INPUT  craplcm.vllanmto, 
                     INPUT  aux_cdalinea,
                     INPUT  IF  (aux_indevchq = 5 OR aux_indevchq = 6)
                                THEN 47
                                ELSE 78,
                     INPUT  glb_cdoperad,
                     INPUT  "lotee_1",
                     OUTPUT glb_cdcritic).

                IF   glb_cdcritic > 0 THEN
                     ASSIGN par_situacao = FALSE
                            aux_contador = glb_cdcritic.

            END.
       /*** Controle de movimentacao em especie ***/

       FIND crapcme WHERE crapcme.cdcooper = glb_cdcooper       AND
                          crapcme.dtmvtolt = craplcm.dtmvtolt   AND
                          crapcme.cdagenci = craplcm.cdagenci   AND
                          crapcme.cdbccxlt = craplcm.cdbccxlt   AND
                          crapcme.nrdolote = craplcm.nrdolote   AND
                          crapcme.nrdctabb = craplcm.nrdctabb   AND
                          crapcme.nrdocmto = craplcm.nrdocmto   
                          EXCLUSIVE-LOCK NO-ERROR.
    
       IF   AVAILABLE crapcme   THEN 
            DO:
                RUN sistema/generico/procedures/b1wgen9998.p 
                    PERSISTENT SET h-b1wgen9998.
                
                RUN email-controle-movimentacao IN h-b1wgen9998
                                               (INPUT glb_cdcooper,
                                                INPUT 0,
                                                INPUT 0,
                                                INPUT glb_cdoperad,
                                                INPUT glb_nmdatela,
                                                INPUT 1, /* Ayllos*/
                                                INPUT crapcme.nrdconta,
                                                INPUT 1, /* Tit*/
                                                INPUT 3, /* Exclusao*/
                                                INPUT ROWID(crapcme),
                                                INPUT TRUE, /* Envia */
                                                INPUT glb_dtmvtolt,
                                                INPUT FALSE,
                                               OUTPUT TABLE tt-erro).

                DELETE PROCEDURE h-b1wgen9998.

                IF   RETURN-VALUE <> "OK"   THEN
                     DO:
                         FIND FIRST tt-erro NO-LOCK NO-ERROR.
                         
                         IF   AVAIL tt-erro   THEN
                              MESSAGE tt-erro.dscritic.
                         ELSE
                              MESSAGE "Erro no envio do e-mail.".
                            
                         PAUSE 2 NO-MESSAGE.
                         
                         UNDO, RETURN "NOK".
                    END.

                DELETE crapcme.
            END.
       
       IF  craphis.cdhistor = 481 OR
           craphis.cdhistor = 483 THEN 
           DO:
              RUN elimina_lancamentos_craplci_ted.
           END.
       
       /*** Tratamento do Compensacao Eletronica ***/
       IF   craphis.cdhistor = 3   OR
            craphis.cdhistor = 4   OR
            craphis.cdhistor = 372 OR
            craphis.cdhistor = 386 OR 
            craphis.tplotmov = 23  THEN
            DO:
                /*  Busca dados da cooperativa  */
                FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper
                                   NO-LOCK NO-ERROR.
       
                IF   NOT AVAILABLE crapcop THEN
                     DO:
                         ASSIGN glb_cdcritic = 651
                                aux_flgerros = TRUE
                                par_situacao = FALSE.
                         LEAVE.
                     END.
 
                FOR EACH crapchd WHERE crapchd.cdcooper = glb_cdcooper      AND
                                       crapchd.dtmvtolt = craplcm.dtmvtolt  AND
                                       crapchd.cdagenci = craplcm.cdagenci  AND
                                       crapchd.cdbccxlt = craplcm.cdbccxlt  AND
                                       crapchd.nrdolote = craplcm.nrdolote  AND
                                       crapchd.nrseqdig = craplcm.nrseqdig
                                       EXCLUSIVE-LOCK USE-INDEX crapchd3:
                    
                    IF   craplcm.cdhistor = 386   THEN 
                         DO:
                            ASSIGN glb_nrcalcul = 
                                       INT(STRING(crapchd.nrcheque,"999999") +
                                           STRING(crapchd.nrddigc3,"9")).
 
                            IF   (crapchd.cdbanchq = 1   AND 
                                  crapchd.cdagechq = 3420) OR
                                 (crapchd.cdbanchq = 104   AND   
                                 /**** Magui testes Concredi 
                                 crapchd.cdagechq = crapcop.cdagebcb *****/
                                 crapchd.cdagechq = 411)   THEN
                                  DO:
                                     IF   CAN-DO(par_lsconta1,
                                              STRING(crapchd.nrctachq))
                                          THEN DO:
                
                                              glb_nrcalcul =                   
                                                 INT(SUBSTR(STRING(glb_nrcalcul,
                                                     "9999999"),1,6)).
                                                    
                                              FIND crabfdc WHERE               
                                                   crabfdc.cdcooper = 
                                                           glb_cdcooper AND
                                                   crabfdc.nrdctitg = 
                                                    STRING(crapchd.nrctachq) AND
                                                   crabfdc.nrcheque = 
                                                           INT(glb_nrcalcul)
                                                   USE-INDEX crapfdc1 
                                                   EXCLUSIVE-LOCK NO-ERROR.
                                              
                                              IF   NOT AVAILABLE crabfdc   THEN
                                                   DO:
                                                      ASSIGN 
                                                        glb_cdcritic = 108
                                                        aux_flgerros = TRUE
                                                        par_situacao = FALSE.
                                                      LEAVE.
                                                   END.
                                              ASSIGN crabfdc.incheque = 0
                                                     crabfdc.dtliqchq = ?
                                                     crabfdc.vlcheque = 0
                                                     crabfdc.vldoipmf = 0.
                                          END.
                                     ELSE     
                                          IF  CAN-DO(par_lsconta3,
                                                STRING(crapchd.nrctachq)) THEN
                                              DO:
                                                 glb_nrcalcul =
                                                    INT(SUBSTR(STRING(
                                                        crapchd.nrdocmto,
                                                        "9999999"),1,6)).

                                                 FIND crabfdc WHERE
                                                      crabfdc.cdcooper =
                                                              glb_cdcooper AND
                                                      crabfdc.nrdctitg =
                                                    STRING(crapchd.nrctachq) AND
                                                      crabfdc.nrcheque =
                                                             INT(glb_nrcalcul)
                                                      USE-INDEX crapfdc1
                                                      EXCLUSIVE-LOCK NO-ERROR.
                                                  
                                                  IF NOT AVAILABLE crabfdc THEN
                                                     DO:
                                                         ASSIGN 
                                                           glb_cdcritic = 286
                                                           aux_flgerros = TRUE
                                                           par_situacao = FALSE.
                                                         LEAVE.
                                                     END.

                                                  ASSIGN crabfdc.incheque = 0
                                                         crabfdc.dtliqchq = ?
                                                         crabfdc.vlcheque = 0
                                                         crabfdc.vldoipmf = 0.
                                              END.
                                 END.
                            ELSE
                                 IF   (crapchd.cdbanchq = 756 AND
                                       crapchd.cdagechq = crapcop.cdagebcb)  
                                      THEN DO:
                                          IF  CAN-DO(par_lsconta3,
                                                 STRING(crapchd.nrctachq)) THEN
                                              DO:
                                                  glb_nrcalcul =
                                                       INT(SUBSTR(STRING(
                                                              crapchd.nrdocmto,
                                                              "9999999"),1,6)).

                                                  FIND crabfdc WHERE
                                                       crabfdc.cdcooper =
                                                              glb_cdcooper AND
                                                       crabfdc.nrdctitg =
                                                    STRING(crapchd.nrctachq) AND
                                                       crabfdc.nrcheque =
                                                             INT(glb_nrcalcul)
                                                       USE-INDEX crapfdc1
                                                       EXCLUSIVE-LOCK NO-ERROR.
                                                  
                                                  IF NOT AVAILABLE crabfdc THEN
                                                     DO:
                                                         ASSIGN
                                                           glb_cdcritic = 286
                                                           aux_flgerros = TRUE
                                                           par_situacao = FALSE.
                                                         LEAVE.
                                                     END.

                                                  ASSIGN crabfdc.incheque = 0
                                                         crabfdc.dtliqchq = ?
                                                         crabfdc.vlcheque = 0
                                                         crabfdc.vldoipmf = 0.
                                              END.
                                          ELSE 
                                              DO:
                                                  glb_nrcalcul =
                                                        INT(SUBSTR(STRING(
                                                            crapchd.nrdocmto,
                                                            "9999999"),1,6)).

                                                  FIND crabfdc WHERE
                                                       crabfdc.cdcooper =
                                                              glb_cdcooper AND
                                                       crabfdc.nrdctitg =
                                                    STRING(crapchd.nrctachq) AND
                                                       crabfdc.nrcheque =
                                                            INT(glb_nrcalcul)
                                                       USE-INDEX crapfdc1
                                                       EXCLUSIVE-LOCK NO-ERROR.
                                                  
                                                  IF NOT AVAILABLE crabfdc THEN
                                                     DO:
                                                         ASSIGN
                                                          glb_cdcritic = 108
                                                          aux_flgerros = TRUE
                                                          par_situacao = FALSE.
                                                         LEAVE.
                                                     END.
                                                  ASSIGN crabfdc.incheque = 0
                                                         crabfdc.dtliqchq = ?
                                                         crabfdc.vlcheque = 0
                                                         crabfdc.vldoipmf = 0.
                                              END.
                                      END.             
                     
                            FIND crablcm WHERE
                                 crablcm.cdcooper = glb_cdcooper           AND
                                 crablcm.dtmvtolt = craplcm.dtmvtolt       AND
                                 crablcm.cdagenci = craplcm.cdagenci       AND
                                 crablcm.cdbccxlt = craplcm.cdbccxlt       AND
                                 crablcm.nrdolote = craplcm.nrdolote       AND
                                 crablcm.nrdctabb = INT(crapchd.nrctachq)  AND
                                 crablcm.nrdocmto = glb_nrcalcul
                                 USE-INDEX craplcm1 EXCLUSIVE-LOCK NO-ERROR.
                            IF   AVAILABLE crablcm   THEN
                                DO:
                                    /*DELETE crablcm.*/
                                    IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
                                        RUN sistema/generico/procedures/b1wgen0200.p PERSISTENT SET h-b1wgen0200.
                                                      
                                    RUN estorna_lancamento_conta IN h-b1wgen0200 
                                        (INPUT crablcm.cdcooper               /* par_cdcooper */
                                        ,INPUT crablcm.dtmvtolt               /* par_dtmvtolt */
                                        ,INPUT crablcm.cdagenci               /* par_cdagenci*/
                                        ,INPUT crablcm.cdbccxlt               /* par_cdbccxlt */
                                        ,INPUT crablcm.nrdolote               /* par_nrdolote */
                                        ,INPUT crablcm.nrdctabb               /* par_nrdctabb */
                                        ,INPUT crablcm.nrdocmto               /* par_nrdocmto */
                                        ,INPUT crablcm.cdhistor               /* par_cdhistor */           
                                        ,INPUT crablcm.nrctachq               /* par_nrctachq */
                                        ,INPUT crablcm.nrdconta               /* par_nrdconta */
                                        ,INPUT crablcm.cdpesqbb               /* par_cdpesqbb */
                                        ,OUTPUT aux_cdcritic                  /* Codigo da critica                             */
                                        ,OUTPUT aux_dscritic).                /* Descricao da critica                          */
                                                        
                                    IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
                                        DO: 
                                            /* Tratamento de erros conforme anteriores */                           
                                            glb_cdcritic = aux_cdcritic.
                                            aux_flgerros = TRUE.
                                            par_situacao = FALSE.
                                            LEAVE.
                                        END.   
                                              
                                        IF  VALID-HANDLE(h-b1wgen0200) THEN
                                            DELETE PROCEDURE h-b1wgen0200.
                                    /* Fim do DELETE */
                                END. 
                        END.   
                    
                    DELETE crapchd.
                END.
            END.    
       
            
       IF   glb_cdcritic = 0 THEN
            DO:

             	{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

				/* verifica e eh um dos historicos de folha ou beneficio e deleta tbfolha_lanaut
				   caso nao for um dos historicos parametrizados deixa seguir o processo normalmente */
				RUN STORED-PROCEDURE pc_excluir_lanaut
				aux_handproc = PROC-HANDLE NO-ERROR (INPUT craplcm.cdcooper
													,INPUT craplcm.dtmvtolt
													,INPUT craplcm.cdagenci
													,INPUT craplcm.nrdconta
													,INPUT craplcm.cdhistor
													,INPUT craplcm.cdbccxlt
													,INPUT craplcm.nrdolote
													,INPUT craplcm.nrseqdig
													,"").

				CLOSE STORED-PROC pc_excluir_lanaut
				aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

				{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                  
				ASSIGN glb_dscritic = ""
				       glb_dscritic = pc_excluir_lanaut.pr_dscritic
									WHEN pc_excluir_lanaut.pr_dscritic <> ?.


        IF  glb_dscritic = "" OR glb_dscritic = ? THEN
				    DO:

						/* Buscar nome do supervisor */
						FIND crapope WHERE crapope.cdcooper = glb_cdcooper   AND
										   crapope.cdoperad = par_cdoperad 
										   NO-LOCK NO-ERROR.

						IF   AVAIL crapope   THEN
							 par_cdoperad = par_cdoperad + " - " + crapope.nmoperad.

						/* Gravar log por lançamento */
						RUN sistema/generico/procedures/b1wgen0014.p 
											 PERSISTENT SET h-b1wgen0014.

						RUN gera_log IN h-b1wgen0014 (INPUT glb_cdcooper,
													  INPUT glb_cdoperad,
													  INPUT "",
													  INPUT "AYLLOS",
													  INPUT "Exclusao de lancamento",
													  INPUT glb_dtmvtolt,
													  INPUT TRUE,
													  INPUT TIME,
													  INPUT 1,
													  INPUT glb_nmdatela,
													  INPUT craplcm.nrdconta,
													  OUTPUT par_nrdrowid).
                                              
						/* Logar valor do lançamento */
						RUN gera_log_item IN h-b1wgen0014 
												(INPUT par_nrdrowid,
												 INPUT "Valor",
												 INPUT "",
												 INPUT TRIM(
							  STRING(craplcm.vllanmto,"z,zzz,zz9.99"))).

								  /* Logar historico de lançamento */
						RUN gera_log_item IN h-b1wgen0014 (INPUT par_nrdrowid,
														   INPUT "Historico",
														   INPUT "",
														   INPUT STRING(craplcm.cdhistor)).
             
						/* Logar que Coordenador liberou a exclusao */
						RUN gera_log_item IN h-b1wgen0014 (INPUT par_nrdrowid,
														   INPUT "Supervisor",
														   INPUT "",
														   INPUT par_cdoperad).                                            
						/* Logar lote */
						RUN gera_log_item IN h-b1wgen0014 (INPUT par_nrdrowid,
														   INPUT "Lote",
														   INPUT "",
														   INPUT STRING(craplcm.nrdolote)).
						/* Logar PAC*/
						RUN gera_log_item IN h-b1wgen0014 (INPUT par_nrdrowid,
														   INPUT "Pac",
														   INPUT "",
														   INPUT STRING(craplcm.cdagenci)).
						/* Logar Banco/Caixa */
						RUN gera_log_item IN h-b1wgen0014 (INPUT par_nrdrowid,
														   INPUT "Banco/Caixa",
														   INPUT "",
														   INPUT STRING(craplcm.cdbccxlt)).
             
						DELETE PROCEDURE h-b1wgen0014.
                
						/*DELETE craplcm.*/
            IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
                    RUN sistema/generico/procedures/b1wgen0200.p PERSISTENT SET h-b1wgen0200.
                                  
            RUN estorna_lancamento_conta IN h-b1wgen0200 
                (INPUT craplcm.cdcooper               /* par_cdcooper */
                ,INPUT craplcm.dtmvtolt               /* par_dtmvtolt */
                ,INPUT craplcm.cdagenci               /* par_cdagenci*/
                ,INPUT craplcm.cdbccxlt               /* par_cdbccxlt */
                ,INPUT craplcm.nrdolote               /* par_nrdolote */
                ,INPUT craplcm.nrdctabb               /* par_nrdctabb */
                ,INPUT craplcm.nrdocmto               /* par_nrdocmto */
                ,INPUT craplcm.cdhistor               /* par_cdhistor */           
                ,INPUT craplcm.nrctachq               /* par_nrctachq */
                ,INPUT craplcm.nrdconta               /* par_nrdconta */
                ,INPUT craplcm.cdpesqbb               /* par_cdpesqbb */
                ,OUTPUT aux_cdcritic                  /* Codigo da critica                             */
                ,OUTPUT aux_dscritic).                /* Descricao da critica                          */
                                
            IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
                DO: 
                    /* Tratamento de erros conforme anteriores */                           
                    glb_cdcritic = aux_cdcritic.
                    aux_flgerros = TRUE.
                    par_situacao = FALSE.
                    LEAVE.
                END.   
                      
            IF  VALID-HANDLE(h-b1wgen0200) THEN
                DELETE PROCEDURE h-b1wgen0200.
            /* Fim do DELETE */
            
				  END.

       END.

       IF   AVAILABLE crapavs   THEN
            DELETE crapavs.

       LEAVE.

   END.  /*  Fim do DO .. TO  */

   IF   aux_contador <> 0   THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            RETURN.
        END.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

PROCEDURE elimina_lancamentos_craplci_ted:
   
    FIND crablot WHERE
         crablot.cdcooper = glb_cdcooper       AND
         crablot.dtmvtolt = craplcm.dtmvtolt   AND
         crablot.cdagenci = 1                  AND
         crablot.cdbccxlt = 100                AND
         crablot.nrdolote = 10006              AND
         crablot.tplotmov = 29                 EXCLUSIVE-LOCK NO-ERROR.
         
    /* Eliminar os lancamentos CI */
    FOR EACH craplci WHERE
             craplci.cdcooper = glb_cdcooper      AND
             craplci.dtmvtolt = craplcm.dtmvtolt  AND
             craplci.cdagenci = 1                 AND
             craplci.cdbccxlt = 100               AND
             craplci.nrdolote = 10006             AND
             craplci.nrdconta = craplcm.nrdconta  AND
             craplci.nrdocmto = craplcm.nrdocmto  EXCLUSIVE-LOCK:  
        FIND crapsli WHERE
             crapsli.cdcooper        = glb_cdcooper             AND
             crapsli.nrdconta        = craplci.nrdconta         AND
             MONTH(crapsli.dtrefere) = MONTH(craplcm.dtmvtolt)  AND
             YEAR(crapsli.dtrefere)  = YEAR(craplcm.dtmvtolt)  
             EXCLUSIVE-LOCK NO-ERROR.
    
        IF   craplci.cdhistor = 482   THEN
             ASSIGN crablot.vlcompcr = crablot.vlcompcr - craplci.vllanmto
                    crablot.vlinfocr = crablot.vlinfocr - craplci.vllanmto
                    crapsli.vlsddisp = crapsli.vlsddisp - craplci.vllanmto.
        ELSE
        IF   craplci.cdhistor = 484   THEN
             ASSIGN crablot.vlcompdb = crablot.vlcompdb - craplci.vllanmto
                    crablot.vlinfodb = crablot.vlinfodb - craplci.vllanmto
                    crapsli.vlsddisp = crapsli.vlsddisp + craplci.vllanmto.
               
        DELETE craplci.
   END.
        
   IF   crablot.qtcompln = 0   AND   crablot.qtinfoln = 0   AND
        crablot.vlcompdb = 0   AND   crablot.vlinfodb = 0   AND
        crablot.vlcompcr = 0   AND   crablot.vlinfocr = 0   THEN
        DELETE crablot.               
   
   RELEASE crapsli.
   RELEASE craplci.
   RELEASE crablot.

END PROCEDURE.

/* .......................................................................... */

