/* ...........................................................................

   Programa: Fontes/landpve.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Outubro/91.                     Ultima atualizacao: 24/10/2017

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de exclusao da tela LANDPV.

   Alteracoes: 13/06/94 - Alterado para ler a tabela com as contas convenio do
                          Banco do Brasil (Edson).

               29/09/94 - Alterado layout de tela e inclusao no campo Alinea
                          (Deborah/Edson).

               25/10/94 - Alterado para tratar o historico 78, do mesmo modo que
                          o 47 (Deborah).

               27/10/94 - Alterado para automatizar a devolucao dos cheques com
                          contra-ordem (Deborah).

               16/05/95 - Alterado para incluir o parametro aux_cdalinea para
                          a rotina geradev (Edson).

               26/06/95 - Alterado para tratar exclusao do crapavs (Edson).

               24/01/97 - Alterado para tratar o historico 191 da mesma forma
                          que o 47 (Deborah).

               12/01/98 - Alterado para gerar registro especial do nao debitados
                          no layout Febraban (Deborah).

               15/01/98 - Alterado para fazer a mesma alteracao para a Casan
                          (Deborah).

               12/08/98 - Alterado para tratar SAMAE (Odair)

               17/08/98 - Tratar cdseqtel do LAU (Odair)

               14/09/98 - Incluir tratamento de convenios atraves da rotina
                          gerandb.i (Odair)

               23/09/99 - Tratar parametros do geradev (Odair).

               18/08/1999 - Tratar incheque = 6 (Deborah).
               
               13/12/1999 - Tratar exclusao de lancamentos historicos 31,288
                            para cdrefere = craplau.nrcrcard (Odair)

               01/11/2000 - Ajustar a glb_cdcritic para todos os historicos
                            (Eduardo).

               29/01/2001 - Incluir historico 371 (Margarete/Planner).

               02/04/2001 - Alterado para ler o craplau pelo numero do 
                            documento no craplcm (Edson).

               08/05/2001 - Tratamento da Compensacao Eletronica (Margarete).

               27/08/2001 - Identificar depositos da cooperativa (Margarete).
               
               19/09/2001 - Eliminar histor 21 quando 386 (Margarete).

               23/01/2002 - Eliminar histor vinculados 354,275,127 (Margarete).

               27/03/2002 - Eliminar historico 353 quando 428 (Margarete).

               23/04/2002 - Corrigir rotina do estorno de deposito bloqueado
                            (Edson).

               08/07/2002 - Eliminar historico 393 quando 394 (Edson).

               26/08/2002 - Alterado para tratar a agencia 3420 do
                            Banco do Brasil (Edson).

               13/09/2002 - Alterado para tratar boletim de caixa (Edson).

               04/12/2002 - Tratar historico 521 da mesma forma que o 21 
                            (Edson)

               04/12/2002 - Tratar historico 526 da mesma forma que o 26 
                            (Edson)

               13/02/2003 - Tratar historico 621 da mesma forma que o 21 
                            (Edson)

               19/03/2003 - Incluir tratamento para a Concredi (Margarete).
               
               09/07/2003 - Verificar se saldo do capital > valor lancamento na
                            exclusao do historico 127/354 (Junior).

               06/08/2003 - Tatamento historido 156 (Julio).

               08/08/2003 - Incluir geracao do controle de movimentacao em
                            especie (Margarete).

               10/02/2004 - Efetuado controle por PA(tabelas horario 
                            compel/titulo) (Mirtes)

               19/05/2004 - Eliminar historico 402 quando 451 (Edson).

               09/06/2004 - Eliminar historico 88 quando 317 (Edson).

               09/06/2004 - Acessar Banco Generico(Mirtes).
  
               30/07/2004 - Passado parametro quantidade prestacoes
                            calculadas(Mirtes)

               09/08/2004 - Se histor 88, atualizar crapepr.dtdpagto,
                            crapepr.indpagto (Margarete).

               25/08/2004 - Tratamento conta integracao (Margarete).
               
               15/09/2004 - Para excluir historicos 481 e 483 (Evandro).

               30/09/2004 - Eliminar historico 349 quando 350 (Edson).
               
               06/05/2005 - Logar exclusao de lancamentos (Edson).

               07/07/2005 - Alimentado campo cdcooper da tabela crapsli (Diego).

               03/10/2005 - Alteracao de crapchq p/ crapfdc 
                            (SQLWorks - Andre/Edson).

               23/12/2005 - Ajustes na exclusao de lancamentos que afetam o
                            crapfdc (Edson).
                            
               27/01/2006 - Unificacao dos Bancos - SQLWorks - Andre
               
               08/02/2006 - Inclusao de EXCLUSIVE-LOCK no FIND craplci (linha
                            14790 - SQLWorks - Eder

               13/02/2006 - Inclusao do parametro glb_cdcooper para as 
                            cahamadas dos programas fontes/pedesenha.p 
                            e fontes/testa_boletim.p - SQLWorks - Fernando.
                            
               30/05/2006 - Atualizar o crapavs para o caso de exclusao de 
                            lancamentos pertinentes a emprestimo vinculado 
                            a folha (Julio).
                            
               30/08/2006 - Inclusao de USE-INDEX para o craplcm (Diego)
                            Atualizacao do crapavs para o caso de pagamento
                            de emprestimo. Verificar se a folha referente ao 
                            mes atual ja entrou. (Julio)

               08/12/2006 - Melhorias para a chamada da rotina "gerandb"(Julio)
               
               21/12/2006 - Incluido data atual no arquivo de log (Elton).

               13/02/2007 - Alterar consultas com indice crapfdc1 (David).
                            
               01/03/2007 - Ajustes para o Bancoob (Magui).

               19/04/2007 - Alteracao no tratamento para atualizacao do crapavs
                            para o caso de emprestimo vinculado a folha (Julio)

               25/05/2007 - Histor 506 para reverter o 428 (Magui).             

               31/05/2007 - Tratamento historico 506 (Julio)

               22/08/2007 - Tratamento para exclusao de lancamentos, para 
                            emprestimos vinculados a conta. Atualizacao do
                            crapepr.dtdpagto (Julio)
                            
               03/09/2007 - Utilizado contador de tempo para nao ocorrer de
                            usuario ficar esperando infinitamente a tabela
                            craplot ser desalocada (Elton).           
                                
               10/10/2007 - Alterado o calculo para a data de pagamento do
                            emprestimo (Julio)
                 
               23/10/2007 - Nao permitir exclusao de tplotmov = 0. Que
                            sao gerados pelo sistema. Critica 650 (Magui).
                            
               29/10/2007 - Substituir tplotmov = 0 por uma lista de historicos
                            nao permitidos. Existem lotes criados pelo sistema
                            que precisam ser excluidos mesmo tendo tplotmov =
                            zero (Magui).

               31/10/2007 - Substituicao de procedure p_atualiza_dtdpagto para
                            includes/atualiza_epr.i (Julio)

               27/05/2008 - Quando qtmesdec menor zeros nao atualizar a data
                            de pagamento (Magui).
                            
               09/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "find" da tabela CRAPHIS.   
                          - Kbase IT Solutions - Eduardo Silva.
                          
               12/08/2008 - Unificacao dos bancos, incluido cdcooper na busca da
                            tabela crabhis(Guilherme).

               21/07/2009 - Trocar criacao de log da craplog para landpv.log
                            (David).

               28/07/2009 - Quando histor 127(deb.cotas) gerado pelo crps120,
                            credito de folha eliminar somente CRAPLCM. O
                            CRAPLCT, deve ser eliminado na tela LANPLA (Magui).

               30/09/2009 - Nao permite a exclusao de lancamentos do historico
                            586 - Seguro Auto;
                          - Incluido o numero da conta no log de exclusao de
                            lancamentos (Elton).

               23/11/2009 - Alteracao Codigo Historico (Kbase).            

               15/04/2010 - Pedir senha quando historico do lançamento
                            tiver flgsenha 'SIM' (Gabriel).

               19/05/2010 - Desativar Rating quando liquidado o Emprestimo
                            (Gabriel).             

               30/08/2010 - Removido campo crapass.cdempres (Diego).              

               22/12/2010 - Inclusao de Transferencia de PA quando coop 2
                            (Guilherme/Supero)

               26/01/2011 - Inclusao de tratamento na TCO quando banco 001
                            Conta ITG (Guilherme/Supero)
                            
               10/03/2011 - Tratamento de exclusao do historico 931 (Vitor). 
               
               27/05/2011 - Email para controle de movimentacao (Gabriel)            
               
               21/12/2011 - Corrigido warnings (Tiago).
               
               01/03/2012 - Incluido chamada pra funcao valida_historico da 
                            b1wgen0134.p (Tiago).
                            
               13/03/2012 - Corrigido o parametro passado para funcao
                            valida_historico da b1wgen0134.p (Tiago).             
                            
               18/06/2012 - Alteracao na leitura da craptco (David Kruger).
               
               06/08/2012 - Adicionado parametro "codigo do programa" a chamada
                            da funcao geradev. (Fabricio)
                            
               18/10/2012 - Tratamento para exclusao da craplct (Tiago). 
               
               24/04/2013 - Incluir verificacao de historico na crapfvl (Lucas R)
               
               12/06/2013 - Novo form para inserir Nr.Docmto com mais de 14 
                            digitos (Lucas).
                            
               13/08/2013 - Exclusao da alinea 29. (Fabricio)
                            
               23/01/2014 - Substituir ( IF craphis.inautori = 1 OR 
                            craplcm.cdhistor = 505 THEN ) pela condicao dos
                            historicos de consorcios 1230,1231,1232,1233,1234.
                          - Logo apos a critica 597 substituir 
                            IF NOT aux_flgerros THEN por ( IF NOT aux_flgerros   
                            AND craphis.inautori = 1  THEN ) ( Lucas R. )
                            
               05/08/2014 - Alteração da Nomeclatura para PA (Vanessa).
               
               03/11/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
                           
               03/12/2014 - Removido display do campo tel_nrseqdig no frame 
                            f_landpv.
                            Motivo: Foi necessario voltar o tamanho do campo
                            de valor (tel_vllanmto) para o seu tamanho original.
                            (Chamado 175752) - (Fabricio)
                            
               22/01/2015 - Ajustes Projeto BNDS (Daniel).
               
               18/03/2015 - Alterar situação de lançamento automático (craplau) para
                            3 em caso de estorno (Lunelli SD 252101)
                            
               27/03/2015 - Inclusa leitura da tabela crapass quando exclusão de 
                            lançamento for de convênios e consórcios (Lunelli SD 270465).
                            
               16/06/2015 - #281178 Para separar os lançamentos manuais ref. a 
                            cheque compensado e não integrado dos demais 
                            lançamentos, foi criado o historico 1873 com base 
                            no 521. Tratamento p hist 1873 igual ao tratamento 
                            do hist 521 (Carlos)
                            
               24/06/2015 - #298239 Melhoria/padronizacao do log (Carlos)
               
               22/07/2015 - Validar horario SICREDI para o historico 1019
                            (Lucas Ranghetti #300858)
                            
               07/12/2015 - #367740 Criado o tratamento para o historico 1874 
                            assim como eh feito com o historico 1873 (Carlos)

               22/12/2015 - Adicionado parametro glb_dscritic na chamada da 
                            geradev.p (Douglas - Melhoria 100)

               07/06/2016 - Melhoria 195 folha pagamento (Tiago/Thiago).
                            
               04/07/2016 - Deletar crappro e crapaut dos lancamentos de 
                            debito automatico.
                            PRJ320 - Oferta debito automatico (Odirlei-AMcom)
                            
               22/09/2016 - Incluido tratamento para verificacao de contrato de 
                            acordo, Prj. 302 (Jean Michel).

               14/02/2017 - Alteracao para chamar pc_verifica_situacao_acordo. 
                            (Jaison/James - PRJ302)

			         29/03/2017 - Ajutes para utilizar rotina a rotina pc_gerandb
							              (Jonata RKAM M311)
                            
               18/04/2017 - Incluir chamada da rotina do Oracle pc_gerandb ao inves
                            de chamar a include do PROGRESS (Lucas Ranghetti #652806)
                            
               29/05/2017 - Alterar chamada da procedure pc_gerandb por pc_gerandb_car
                            (Lucas Ranghetti #681579)
                            
               17/07/2017 - Ajustes para permitir o agendamento de lancamentos da mesma
                            conta e referencia no mesmo dia(dtmvtolt) porem com valores
                            diferentes (Lucas Ranghetti #684123)    
                            
               24/10/2017 - Tratamento para buscar o nrcrcard "referencia original" caso 
                            tenha valor no campo somente para consorcios (Lucas Ranghetti #739738)
                            
               19/10/2018 - PRJ450 - Regulatorios de Credito - centralizacao de 
                            estorno de lançamentos na conta corrente              
                            pc_estorna_lancto_prog (Fabio Adriano - AMcom).             
............................................................................. */

{ includes/var_online.i }
{ includes/var_landpv.i }

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i }
{ sistema/generico/includes/b1wgen0200tt.i }

/* Variáveis de uso da BO 200 */
DEF VAR h-b1wgen0200         AS HANDLE                              NO-UNDO.
DEF VAR aux_incrineg         AS INT                                 NO-UNDO.

DEF VAR aux_cdcritic        AS INTE                                NO-UNDO.
DEF VAR aux_dscritic        AS CHAR                                NO-UNDO.

DEF VAR aux_cdhistorc        AS INTE                                 NO-UNDO.
DEF VAR aux_cdagencic        AS CHAR FORMAT "x(04)"                  NO-UNDO.
DEF VAR aux_cdcooperativa    AS CHAR FORMAT "x(04)"                  NO-UNDO.
DEF VAR aux_nrdcontac        AS CHAR FORMAT "x(14)"                  NO-UNDO.
DEF VAR aux_qtprecal_retorno LIKE crapepr.qtprecal                   NO-UNDO.
DEF VAR aux_dtrefere         AS DATE                                 NO-UNDO.
DEF VAR aux_cdhstnex         AS CHAR                                 NO-UNDO.
DEF VAR aux_flexclcm         AS LOG                                  NO-UNDO.
DEF VAR aux_cdempres         AS INT                                  NO-UNDO.
DEF VAR aux_flctatco         AS LOG                                  NO-UNDO.
DEF VAR ant_cdcooper         AS INT                                  NO-UNDO.
DEF VAR aux_cdcoptco         AS INT                                  NO-UNDO.
DEF VAR aux_nrctatco         AS INT                                  NO-UNDO.
DEF VAR aux_sldesblo         AS DECI                                 NO-UNDO.
DEF VAR aux_flgretativo      AS INT                                  NO-UNDO.
DEF VAR aux_flgretquitado    AS INT                                  NO-UNDO.
DEF VAR aux_cdrefere         LIKE crapatr.cdrefere                   NO-UNDO.
DEF BUFFER crabdev FOR crapdev.

DEF VAR par_nsenhaok         AS LOGI INIT FALSE                      NO-UNDO.
DEF VAR par_cdoperad         AS CHAR                                 NO-UNDO.
DEF VAR par_nrdrowid         AS ROWID                                NO-UNDO.

DEF VAR h-b1wgen0014         AS HANDLE                               NO-UNDO.
DEF VAR h-b1wgen0043         AS HANDLE                               NO-UNDO.
DEF VAR h-b1wgen9998         AS HANDLE                               NO-UNDO.
DEF VAR h-b1wgen0134         AS HANDLE                               NO-UNDO.

DEF VAR aux_dadosusr AS CHAR                                         NO-UNDO.
DEF VAR par_loginusr AS CHAR                                         NO-UNDO.
DEF VAR par_nmusuari AS CHAR                                         NO-UNDO.
DEF VAR par_dsdevice AS CHAR                                         NO-UNDO.
DEF VAR par_dtconnec AS CHAR                                         NO-UNDO.
DEF VAR par_numipusr AS CHAR                                         NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                       NO-UNDO.

{includes/gg0000.i}   /* Para conexao Banco Generico */
{includes/atualiza_epr.i} /* Procedure p_atualiza_dtdpagto */


IF   tel_nrdolote = 10001   OR
     tel_nrdolote = 10002   OR
     tel_nrdolote = 10003   THEN
     DO:
         MESSAGE "Nao e' possivel excluir lancamentos deste lote".
         NEXT.
     END.

/*** Magui em 13/09/2002 noa permitir excluir lotes gerados pelo caixa ***/
IF   tel_nrdolote >= 11000   AND
     tel_nrdolote <= 21999   THEN
     DO:
         MESSAGE "Nao e' possivel excluir lancamentos deste lote".
         NEXT.
     END.

/*** Historicos que nao podem ser excluidos ***/
ASSIGN aux_cdhstnex = "106,107,114,160,177,324,325,387,388,472,478,497,499," +
                      "527,530,864,586".     
                      
EXCLUSAO:
DO WHILE TRUE:

   RUN fontes/inicia.p.
    
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
      ASSIGN tel_nrdocmto  = aux_nrdocmto.

      UPDATE tel_nrdctabb tel_nrdocmto WITH FRAME f_landpv_e.

      ASSIGN glb_nrcalcul = tel_nrdctabb
             aux_nrdctabb = tel_nrdctabb
             aux_nrdocmto = tel_nrdocmto
             glb_cdcritic = 0
             aux_ctpsqitg = tel_nrdctabb
             par_cdoperad = "".

      ASSIGN tel_nrdocmto = DECI(SUBSTRING(STRING(tel_nrdocmto), 1, 14)).

      DISPLAY tel_nrdctabb tel_nrdocmto WITH FRAME f_landpv.

      PAUSE(0).

      RUN existe_conta_integracao.
      
      RUN fontes/digbbx.p (INPUT  tel_nrdctabb,    /*  Formata conta integr.  */
                           OUTPUT glb_dsdctitg,
                           OUTPUT glb_stsnrcal).

      RUN fontes/digfun.p.
      
      /*** Magui = alterada conta itg do cooperado para outro numero de 
                   conta itg ***/
      IF   glb_cdcooper = 1      and
           tel_nrdctabb = 414484 and
           aux_nrdocmto = 2771 then
           assign aux_nrdctitg = "00414488".
      /********************************************/     
               
      IF   NOT glb_stsnrcal   THEN
           DO:
               glb_cdcritic = 8.
               NEXT-PROMPT tel_nrdctabb WITH FRAME f_landpv_e.
           END.
      ELSE
           IF   tel_nrdocmto = 0   THEN
                DO:
                    glb_cdcritic = 22.
                    NEXT-PROMPT tel_nrdocmto WITH FRAME f_landpv_e.
                END.
           ELSE
                DO:
                    IF   NOT CAN-DO(aux_lscontas,STRING(tel_nrdctabb))  AND
                         aux_nrdctitg = ""  THEN
                         DO:
                             FIND crapass WHERE 
                                  crapass.cdcooper = glb_cdcooper AND
                                  crapass.nrdconta = tel_nrdctabb 
                                  NO-LOCK NO-ERROR.

                             IF   NOT AVAILABLE crapass   THEN
                                  DO:
                                      glb_cdcritic = 9.
                                      NEXT-PROMPT tel_nrdctabb
                                                  WITH FRAME f_landpv_e.
                                  END.
                         END.
                END.

      IF   glb_cdcritic > 0 THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               CLEAR FRAME f_landpv.
               PAUSE(0).

               ASSIGN glb_cddopcao = aux_cddopcao
                      tel_dtmvtolt = aux_dtmvtolt
                      tel_cdagenci = aux_cdagenci
                      tel_cdbccxlt = aux_cdbccxlt
                      tel_nrdolote = aux_nrdolote
                      tel_nrdctabb = aux_nrdctabb.

               DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci
                       tel_cdbccxlt tel_nrdolote tel_nrdctabb
                       tel_nrdocmto WITH FRAME f_landpv.
               PAUSE(0).

               MESSAGE glb_dscritic.

               NEXT.
           END.

      LEAVE.

   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        RETURN.  /* Volta pedir a opcao para o operador */

   DO TRANSACTION:
      
      DO aux_contador = 1 TO 10: 

         ASSIGN aux_flgerros = FALSE
                aux_indevchq = 0
                aux_cdalinea = 0.
         
         FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                            craplot.dtmvtolt = tel_dtmvtolt   AND
                            craplot.cdagenci = tel_cdagenci   AND
                            craplot.cdbccxlt = tel_cdbccxlt   AND
                            craplot.nrdolote = tel_nrdolote
                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

         IF   NOT AVAILABLE craplot   THEN
              IF   LOCKED craplot   THEN
                   DO:                        
                       ASSIGN glb_cdcritic = 84
                              aux_flgerros = TRUE.
                       PAUSE 1 NO-MESSAGE.     
                       NEXT.
                   END.
              ELSE
                   DO:
                       ASSIGN glb_cdcritic = 60.
                              aux_flgerros = TRUE.
                       LEAVE.
                   END.
         ELSE
            ASSIGN glb_cdcritic = 0
                   aux_flgerros = FALSE.
         
         LEAVE.
      END.
          
      IF   NOT aux_flgerros THEN
           IF   craplot.tplotmov <> 1   THEN
                glb_cdcritic = 100.
          
      IF   NOT aux_flgerros   THEN
           DO:
               IF   craplot.nrdcaixa > 0   THEN
                    DO:
                        RUN fontes/testa_boletim.p
                                                   (INPUT  glb_cdcooper,     
                                                    INPUT  craplot.dtmvtolt,
                                                    INPUT  craplot.cdagenci,
                                                    INPUT  craplot.cdbccxlt,
                                                    INPUT  craplot.nrdolote,
                                                    INPUT  craplot.nrdcaixa,
                                                    INPUT  craplot.cdopecxa,
                                                    OUTPUT glb_cdcritic).
                                                    
                        IF   glb_cdcritic > 0   THEN
                             aux_flgerros = TRUE.
                    END.
           END.
 
      IF   glb_cdcritic > 0 THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               CLEAR FRAME f_landpv.
               PAUSE(0).
               ASSIGN glb_cddopcao = aux_cddopcao
                      tel_dtmvtolt = aux_dtmvtolt
                      tel_cdagenci = aux_cdagenci
                      tel_cdbccxlt = aux_cdbccxlt
                      tel_nrdolote = aux_nrdolote
                      tel_nrdctabb = aux_nrdctabb.

               DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci
                       tel_cdbccxlt tel_nrdolote tel_nrdctabb
                       tel_nrdocmto WITH FRAME f_landpv.
               PAUSE(0).

               MESSAGE glb_dscritic.
           
               NEXT.
           END.

      ASSIGN tel_qtinfoln = craplot.qtinfoln   tel_qtcompln = craplot.qtcompln
             tel_vlinfodb = craplot.vlinfodb   tel_vlcompdb = craplot.vlcompdb
             tel_vlinfocr = craplot.vlinfocr   tel_vlcompcr = craplot.vlcompcr
             tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
             tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
             tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr.

      DO  aux_contador = 1 TO 10:

          glb_cdcritic = 0.

          FIND craplcm WHERE craplcm.cdcooper = glb_cdcooper   AND
                             craplcm.dtmvtolt = tel_dtmvtolt   AND
                             craplcm.cdagenci = tel_cdagenci   AND
                             craplcm.cdbccxlt = tel_cdbccxlt   AND
                             craplcm.nrdolote = tel_nrdolote   AND
                             craplcm.nrdctabb = tel_nrdctabb   AND
                             craplcm.nrdocmto = aux_nrdocmto   EXCLUSIVE-LOCK
                             USE-INDEX craplcm1 NO-ERROR NO-WAIT.

          IF   NOT AVAILABLE craplcm   THEN
               IF   LOCKED craplcm   THEN
                    DO:
                        glb_cdcritic = 114.
                        PAUSE 2 NO-MESSAGE.
                        NEXT.
                    END.
               ELSE
                    DO: 
                        glb_cdcritic = 90.
                        LEAVE.
                    END.
          ELSE
               DO:
                   aux_contador = 0.
                   LEAVE.
               END.
      END.
      
      IF   glb_cdcritic = 0   THEN
           DO:
               FIND craphis WHERE craphis.cdcooper = glb_cdcooper    AND
                                  craphis.cdhistor = craplcm.cdhistor
                                  NO-LOCK NO-ERROR.

               IF   NOT AVAILABLE craphis   THEN
                    glb_cdcritic = 83.
           END.
                    
      IF  glb_cdcritic     = 0  AND 
          craplcm.cdhistor = 1019 THEN
          DO:
              FIND FIRST crapope WHERE 
                         crapope.cdcooper = glb_cdcooper AND 
                         crapope.cdoperad = glb_cdoperad 
                         NO-LOCK NO-ERROR.

              /* Validar horario SICREDI, caso o operador tente cancelar o lancamento
                 apos o horario estipulado, sera exibido a mensagem a seguir */
              FIND FIRST craptab WHERE craptab.cdcooper = glb_cdcooper AND
                                       craptab.nmsistem = "CRED"       AND
                                       craptab.tptabela = "GENERI"     AND
                                       craptab.cdempres = 0            AND
                                       craptab.cdacesso = "HRPGSICRED" AND
                                       craptab.tpregist = crapope.cdpactra
                                       NO-LOCK NO-ERROR.

              IF  TIME < INT(ENTRY(1,craptab.dstextab," ")) OR
                  TIME > INT(ENTRY(2,craptab.dstextab," ")) THEN
                  DO:
                      MESSAGE "Horario p/ exclusao SICREDI esta " +
                              "fora do estabelecido na tela CADPAC".
                      NEXT.
                  END.
          END.

      /*** Tratamento da Compensacao Eletronica ***/
      IF   glb_cdcritic     = 0   AND 
          (craplcm.cdhistor = 3   OR
           craplcm.cdhistor = 4   OR
           craplcm.cdhistor = 372) THEN 
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
           END.


      IF   glb_cdcritic = 0   THEN
           DO:

               RUN sistema/generico/procedures/b1wgen0134.p 
                                   PERSISTENT SET h-b1wgen0134.
               RUN valida_historico IN h-b1wgen0134(INPUT craplcm.cdhistor).
               DELETE PROCEDURE h-b1wgen0134.

           IF   CAN-DO(aux_cdhstnex, STRING(craphis.cdhistor)) OR
                RETURN-VALUE = "OK"  THEN
                    glb_cdcritic = 650.
               ELSE     
                    DO:
                        IF   CAN-DO("3,4,5",STRING(craphis.inhistor))   THEN
                             DO:
                                 DO WHILE TRUE:

                                    aux_flgerros = FALSE.

                                    FIND crapdpb WHERE
                                         crapdpb.cdcooper = glb_cdcooper     AND
                                         crapdpb.dtmvtolt = tel_dtmvtolt     AND
                                         crapdpb.cdagenci = tel_cdagenci     AND
                                         crapdpb.cdbccxlt = tel_cdbccxlt     AND
                                         crapdpb.nrdolote = tel_nrdolote     AND
                                         crapdpb.nrdconta = craplcm.nrdconta AND
                                         crapdpb.nrdocmto = aux_nrdocmto
                                         USE-INDEX crapdpb1 EXCLUSIVE-LOCK
                                         NO-ERROR NO-WAIT.

                                    IF   NOT AVAILABLE crapdpb   THEN
                                         IF   LOCKED crapdpb   THEN
                                              DO:
                                                  PAUSE 1 NO-MESSAGE.
                                                  NEXT.
                                              END.
                                         ELSE
                                              glb_cdcritic = 82.
                                    ELSE
                                         IF   crapdpb.inlibera = 2   THEN
                                              glb_cdcritic = 220.

                                    LEAVE.

                                 END.  /*  Fim do DO WHILE TRUE  */

                                 IF   glb_cdcritic = 0 THEN
                                      tel_dtliblan = crapdpb.dtliblan.

                             END.
                        ELSE
                        IF   CAN-DO("13,14,15",STRING(craphis.inhistor))   THEN
                             DO:
                                 DO WHILE TRUE:

                                    FIND FIRST crapdpb WHERE
                                         crapdpb.cdcooper = glb_cdcooper     AND
                                         crapdpb.nrdconta = craplcm.nrdconta AND
                                         crapdpb.nrdocmto = aux_nrdocmto     AND
                                         crapdpb.dtliblan > glb_dtmvtolt
                                         USE-INDEX crapdpb2
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                                    IF   NOT AVAILABLE crapdpb   THEN
                                         IF   LOCKED crapdpb   THEN
                                              DO:
                                                  PAUSE 1 NO-MESSAGE.
                                                  NEXT.
                                              END.
                                         ELSE
                                              glb_cdcritic = 82.
                                    ELSE
                                         IF   crapdpb.inlibera = 1   THEN
                                              glb_cdcritic = 238.

                                    LEAVE.

                                 END.  /*  Fim do DO WHILE TRUE  */

                                 tel_dtliblan = ?.
                             END.
                        ELSE
                             tel_dtliblan = ?.
                    END.
           END.
     
      IF   glb_cdcritic = 0 AND
          (CAN-FIND(FIRST crapfvl WHERE crapfvl.cdhistor = tel_cdhistor 
                                  NO-LOCK) OR
           CAN-FIND(FIRST crapfvl WHERE crapfvl.cdhisest = tel_cdhistor 
                                  NO-LOCK)) THEN
           glb_cdcritic = 94.

      IF   glb_cdcritic > 0 THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               CLEAR FRAME f_landpv.
               PAUSE(0).
                        
               ASSIGN glb_cddopcao = aux_cddopcao
                      tel_dtmvtolt = aux_dtmvtolt
                      tel_cdagenci = aux_cdagenci
                      tel_cdbccxlt = aux_cdbccxlt
                      tel_nrdolote = aux_nrdolote
                      tel_nrdctabb = aux_nrdctabb.
               
               DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci
                       tel_cdbccxlt tel_nrdolote tel_nrdctabb
                       tel_nrdocmto WITH FRAME f_landpv.
               PAUSE(0).
               
               MESSAGE glb_dscritic.
               NEXT.
           END.

      ASSIGN tel_cdhistor = craplcm.cdhistor
             tel_vllanmto = craplcm.vllanmto
             tel_cdalinea = IF (craplcm.cdhistor = 47  OR
                                craplcm.cdhistor = 78  OR
                                craplcm.cdhistor = 156 OR
                                craplcm.cdhistor = 191)
                               THEN INTEGER(craplcm.cdpesqbb)
                               ELSE 0.
        
      DISPLAY tel_qtinfoln tel_vlinfodb tel_vlinfocr
              tel_qtcompln tel_vlcompdb tel_vlcompcr
              tel_qtdifeln tel_vldifedb tel_vldifecr
              tel_cdhistor tel_nrdctabb tel_nrdocmto
              tel_vllanmto tel_dtliblan tel_cdalinea
              WITH FRAME f_landpv.
      PAUSE(0).

      /* Pedir senha do supervisor */ 
      IF   craphis.flgsenha  THEN
           DO: 
               RUN fontes/pedesenha.p (INPUT glb_cdcooper,
                                       INPUT 2, /* Supervisor*/
                                       OUTPUT par_nsenhaok,
                                       OUTPUT par_cdoperad).
               
               IF   NOT par_nsenhaok THEN
                    NEXT.
           END.

      /* Confirmar operaçao */
      RUN fontes/confirma.p (INPUT "",
                             OUTPUT aux_confirma).

      IF   aux_confirma <> "S" THEN
           NEXT.
      
      glb_cdcritic = 0.

      IF   craplcm.cdhistor = 21   OR
           craplcm.cdhistor = 47   OR
           craplcm.cdhistor = 49   OR
           craplcm.cdhistor = 156  OR
           craplcm.cdhistor = 191  OR
           craplcm.cdhistor = 521  OR
           craplcm.cdhistor = 621  OR 
           craplcm.cdhistor = 1873 OR
           craplcm.cdhistor = 1874 THEN
           DO:
               ASSIGN glb_nrchqsdv = INT(SUBSTR(STRING(aux_nrdocmto,
                                                "9999999"),1,6))
                      glb_nrchqcdv = aux_nrdocmto.

               DO WHILE TRUE:

                  aux_flgerros = FALSE.
             
                  FIND crapfdc WHERE crapfdc.cdcooper = glb_cdcooper      AND
                                     crapfdc.cdbanchq = craplcm.cdbanchq  AND
                                     crapfdc.cdagechq = craplcm.cdagechq  AND
                                     crapfdc.nrctachq = craplcm.nrctachq  AND
                                     crapfdc.nrcheque = glb_nrchqsdv
                                     USE-INDEX crapfdc1 EXCLUSIVE-LOCK 
                                     NO-ERROR NO-WAIT.

                  IF   NOT AVAILABLE crapfdc   THEN
                       IF   LOCKED crapfdc   THEN
                            DO:
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                       ELSE
                            DO:
                                /* TCO valido para Banco 756 e 85 */
                                FIND craptco WHERE 
                                     craptco.cdcooper = glb_cdcooper     AND
                                     craptco.nrdconta = craplcm.nrdconta AND
                                     craptco.tpctatrf = 1                AND
                                     craptco.flgativo = TRUE
                                     NO-LOCK NO-ERROR.

                                IF  AVAILABLE craptco THEN
                                    DO:
                                        FIND crapfdc WHERE 
                                         crapfdc.cdcooper = craptco.cdcopant AND
                                         crapfdc.cdbanchq = craplcm.cdbanchq AND
                                         crapfdc.cdagechq = craplcm.cdagechq AND
                                         crapfdc.nrctachq = craplcm.nrctachq AND
                                         crapfdc.nrcheque = glb_nrchqsdv
                                         USE-INDEX crapfdc1 EXCLUSIVE-LOCK 
                                         NO-ERROR NO-WAIT.

                                        IF   AVAILABLE crapfdc THEN
                                             ASSIGN aux_flctatco = YES.
                                        ELSE
                                             DO:
                                                 ASSIGN glb_cdcritic = 108
                                                        aux_flgerros = TRUE.
                                                 LEAVE.
                                             END.    
                                     END.             
                                ELSE
                                     DO:
                                         /* Verifica Cta.ITG - TCO */
                                         
                                         FIND craptco WHERE
                                            craptco.cdcooper = glb_cdcooper     AND
                                            craptco.nrdctitg = craplcm.nrdctitg AND
                                            craptco.tpctatrf = 1                AND
                                            craptco.flgativo = TRUE
                                            NO-LOCK NO-ERROR.

                                         IF  AVAILABLE craptco THEN
                                             DO:
                                                 FIND crapfdc WHERE 
                                                      crapfdc.cdcooper = craptco.cdcopant AND
                                                      crapfdc.cdbanchq = craplcm.cdbanchq AND
                                                      crapfdc.cdagechq = craplcm.cdagechq AND
                                                      crapfdc.nrctachq = craplcm.nrctachq AND
                                                      crapfdc.nrcheque = glb_nrchqsdv
                                                 USE-INDEX crapfdc1 
                                                 EXCLUSIVE-LOCK 
                                                 NO-ERROR NO-WAIT.

                                                 IF  AVAILABLE crapfdc THEN
                                                     ASSIGN aux_flctatco = YES.
                                                 ELSE
                                                     DO:
                                                         glb_cdcritic = 108.
                                                         aux_flgerros = TRUE.
                                                         LEAVE.
                                                     END.    
                                             END. 
                                         ELSE
                                             DO:
                                                 ASSIGN glb_cdcritic = 108
                                                        aux_flgerros = TRUE.
                                                 LEAVE.
                                             END.
                                     END.    
                            END.
                  LEAVE.
               END.

               IF   aux_flgerros   THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        NEXT-PROMPT tel_nrdocmto WITH FRAME f_landpv_e.
                        NEXT.
                    END.

               IF   craplcm.cdhistor = 21   OR
                    craplcm.cdhistor = 521  OR
                    craplcm.cdhistor = 621  OR
                    craplcm.cdhistor = 1873 OR
                    craplcm.cdhistor = 1874 THEN
                    DO:
                        IF   CAN-DO("0,1,2",STRING(crapfdc.incheque))   THEN
                             DO:
                                 glb_cdcritic = 99.
                                 RUN fontes/critic.p.
                                 MESSAGE glb_dscritic.
                                 glb_cdcritic = 79.
                                 RUN fontes/critic.p.
                                 MESSAGE glb_dscritic.
                                 BELL.
                                 NEXT.
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
                        IF   CAN-DO("5,6,7",STRING(crapfdc.incheque))   THEN
                             DO:
                                 glb_cdcritic = 97.
                                 RUN fontes/critic.p.
                                 MESSAGE glb_dscritic.
                                 glb_cdcritic = 79.
                                 RUN fontes/critic.p.
                                 MESSAGE glb_dscritic.
                                 BELL.
                                 NEXT.
                             END.

                        ASSIGN crapfdc.incheque = crapfdc.incheque + 5
                               crapfdc.dtliqchq = glb_dtmvtolt.

                        IF   tel_cdhistor = 47    OR
                             tel_cdhistor = 156   OR
                             tel_cdhistor = 191   THEN
                             ASSIGN aux_indevchq     = 6
                                    aux_cdalinea     = tel_cdalinea
                                    crapfdc.vlcheque = craplcm.vllanmto.
                    END.
      END.
      ELSE
      IF   craplcm.cdhistor = 59  OR
           craplcm.cdhistor = 77  OR
           craplcm.cdhistor = 78  THEN
           DO:
               IF   NOT CAN-DO(aux_lsconta2,STRING(craplcm.nrdctabb))   THEN
                    DO:
                        glb_cdcritic = 127.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        NEXT-PROMPT tel_nrdctabb WITH FRAME f_landpv_e.
                        NEXT.
                    END.

               ASSIGN glb_nrchqsdv = INT(SUBSTR(STRING(aux_nrdocmto,
                                                       "9999999"),1,6))
                      glb_nrchqcdv = aux_nrdocmto.
 
               DO WHILE TRUE:

                  aux_flgerros = FALSE.

                  FIND crapfdc WHERE crapfdc.cdcooper = glb_cdcooper      AND
                                     crapfdc.cdbanchq = craplcm.cdbanchq  AND
                                     crapfdc.cdagechq = craplcm.cdagechq  AND
                                     crapfdc.nrctachq = craplcm.nrctachq  AND
                                     crapfdc.nrcheque = glb_nrchqsdv
                                     USE-INDEX crapfdc1 EXCLUSIVE-LOCK 
                                     NO-ERROR NO-WAIT.

                  IF   NOT AVAILABLE crapfdc   THEN
                       IF   LOCKED crapfdc   THEN
                            DO:
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                       ELSE
                            DO:
                                ASSIGN glb_cdcritic = 108
                                       aux_flgerros = TRUE.
                                LEAVE.
                            END.
                  LEAVE.
               END.

               IF   aux_flgerros   THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        NEXT-PROMPT tel_nrdocmto WITH FRAME f_landpv_e.
                        NEXT.
                    END.

               IF   craplcm.cdhistor = 59   THEN
                    DO:
                        IF   CAN-DO("0,1,2",STRING(crapfdc.incheque))   THEN
                             DO:
                                 glb_cdcritic = 99.
                                 RUN fontes/critic.p.
                                 MESSAGE glb_dscritic.
                                 glb_cdcritic = 79.
                                 RUN fontes/critic.p.
                                 MESSAGE glb_dscritic.
                                 BELL.
                                 NEXT.
                             END.

                        ASSIGN crapfdc.incheque = crapfdc.incheque - 5
                               crapfdc.dtliqchq = ?
                               crapfdc.vlcheque = 0
                               crapfdc.vldoipmf = 0.

                        IF   crapfdc.incheque = 1   THEN
                             aux_indevchq = 7.
                    END.
               ELSE
                    DO:
                        IF   CAN-DO("5,6,7",STRING(crapfdc.incheque)) THEN
                             DO:
                                 glb_cdcritic = 97.
                                 RUN fontes/critic.p.
                                 MESSAGE glb_dscritic.
                                 glb_cdcritic = 79.
                                 RUN fontes/critic.p.
                                 MESSAGE glb_dscritic.
                                 BELL.
                                 NEXT.
                             END.

                        ASSIGN crapfdc.incheque = crapfdc.incheque + 5
                               crapfdc.dtliqchq = glb_dtmvtolt.

                        IF   tel_cdhistor = 78   THEN
                             ASSIGN aux_indevchq = 8
                                    aux_cdalinea = tel_cdalinea.
                    END.
           END.
      ELSE
      IF  (craplcm.cdhistor = 26   OR
           craplcm.cdhistor = 526) AND
           CAN-DO(aux_lsconta3,STRING(craplcm.nrdctabb))   THEN
           DO:
               DO WHILE TRUE:

                  aux_flgerros = FALSE.

                  ASSIGN glb_nrchqsdv = INT(SUBSTR(STRING(aux_nrdocmto,
                                                   "9999999"),1,6))
                         glb_nrchqcdv = aux_nrdocmto.
 
                  FIND crapfdc WHERE crapfdc.cdcooper = glb_cdcooper      AND
                                     crapfdc.cdbanchq = craplcm.cdbanchq  AND
                                     crapfdc.cdagechq = craplcm.cdagechq  AND
                                     crapfdc.nrctachq = craplcm.nrctachq  AND
                                     crapfdc.nrcheque = glb_nrchqsdv
                                     USE-INDEX crapfdc1 EXCLUSIVE-LOCK 
                                     NO-ERROR NO-WAIT.

                  IF   NOT AVAILABLE crapfdc   THEN
                       IF   LOCKED crapfdc   THEN
                            DO:
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                       ELSE
                            DO:
                                ASSIGN glb_cdcritic = 286
                                       aux_flgerros = TRUE.
                                LEAVE.
                            END.
                  LEAVE.

               END.

               IF   NOT aux_flgerros   THEN
                    IF   CAN-FIND(craplcm WHERE
                                  craplcm.cdcooper = glb_cdcooper       AND
                                  craplcm.nrdconta = crapfdc.nrdconta   AND
                                  craplcm.dtmvtolt = glb_dtmvtolt       AND
                                  craplcm.cdhistor = 101                AND
                                  craplcm.nrdocmto = aux_nrdocmto
                                  USE-INDEX craplcm2)                   THEN
                         ASSIGN glb_cdcritic = 343
                                aux_flgerros = TRUE.

               IF   aux_flgerros   THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        NEXT-PROMPT tel_nrdocmto WITH FRAME f_landpv_e.
                        NEXT.
                    END.

               crapfdc.dtliqchq = ?.
               
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
                        glb_cdcritic = 99.
                        RUN fontes/critic.p.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 79.
                        RUN fontes/critic.p.
                        MESSAGE glb_dscritic.
                        BELL.
                        NEXT.
                    END.
           END.
      ELSE
      IF   CAN-DO("3,4,5",STRING(craphis.inhistor))   THEN
           DELETE crapdpb.
      ELSE
      IF   CAN-DO("13,14,15",STRING(craphis.inhistor))   THEN
           crapdpb.inlibera = 1.
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
                   ASSIGN aux_flgerros = TRUE
                          glb_cdcritic = 651.
               
               FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                                  crapass.nrdconta = craplcm.nrdconta 
                                  NO-LOCK NO-ERROR.
                           
               IF  NOT AVAILABLE crapass   THEN
                   DO:
                       ASSIGN  aux_flgerros = TRUE.
                               glb_cdcritic = 9.
                   END.

               FIND FIRST craplau WHERE craplau.cdcooper = glb_cdcooper     AND
                                        craplau.nrdconta = craplcm.nrdconta AND
                                        craplau.cdhistor = craplcm.cdhistor AND
                                        craplau.dtdebito = craplcm.dtmvtolt AND
                                        craplau.nrdocmto = craplcm.nrdocmto
                                        NO-LOCK NO-ERROR.

               IF   NOT AVAILABLE craplau THEN
                    ASSIGN aux_flgerros = TRUE
                           glb_cdcritic = 597.

               IF   NOT aux_flgerros  AND
                    craphis.inautori = 1 THEN
                    DO:
                       FIND crapatr WHERE 
                            crapatr.cdcooper = glb_cdcooper        AND
                            crapatr.nrdconta = craplcm.nrdconta    AND 
                            crapatr.cdhistor = craplcm.cdhistor    AND
                            crapatr.cdrefere = craplau.nrcrcard
                            NO-LOCK NO-ERROR.
                            
                       
                       IF   NOT AVAILABLE crapatr   THEN
                            FIND crapatr WHERE 
                                 crapatr.cdcooper = glb_cdcooper       AND
                                 crapatr.nrdconta = craplcm.nrdconta   AND
                                 crapatr.cdhistor = craplcm.cdhistor   AND
                                 crapatr.cdrefere = craplau.nrdocmto
                                 NO-LOCK NO-ERROR.

                       IF   NOT AVAILABLE crapatr THEN
                            ASSIGN aux_flgerros = TRUE
                                    glb_cdcritic = 598.

					             ASSIGN aux_cdrefere = crapatr.cdrefere WHEN AVAIL crapatr.

                    END.
               ELSE 
                    DO:
                        IF  craplcm.cdhistor = 1230 OR  
                            craplcm.cdhistor = 1231 OR
                            craplcm.cdhistor = 1232 OR
                            craplcm.cdhistor = 1233 OR
                            craplcm.cdhistor = 1234 THEN                             
                            DO:
                               IF  craplau.nrcrcard <> 0 THEN
                                   ASSIGN aux_cdrefere = craplau.nrcrcard.
                               ELSE 
                            ASSIGN aux_cdrefere = craplau.nrdocmto.
                               
                            END.
                    END.

               IF   aux_flgerros  THEN
                    DO:  
                        RUN fontes/critic.p.
                        MESSAGE glb_dscritic.
                        BELL.
                        NEXT.
                    END.

                /* Verifica se possui contrato de acordo */
              { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }              

                /* Verifica se ha contratos de acordo */
              RUN STORED-PROCEDURE pc_gerandb_car
                aux_handproc = PROC-HANDLE NO-ERROR (INPUT glb_cdcooper
                                                    ,INPUT craplau.cdhistor
                                                    ,INPUT craplcm.nrdconta
                                                    ,INPUT STRING(aux_cdrefere)
                                                    ,INPUT craplau.vllanaut                                                    
                                                    ,INPUT craplau.cdseqtel
                                                    ,INPUT STRING(aux_cdrefere)
                                                    ,INPUT crapcop.cdagesic
                                                    ,INPUT crapass.nrctacns
												                          	,INPUT crapass.cdagenci
                                                    ,INPUT craplau.cdempres
											                          		,INPUT craplau.idlancto
                                                    ,INPUT glb_cdcritic
                                                    ,OUTPUT 0
                                                    ,OUTPUT "").

              CLOSE STORED-PROC pc_gerandb_car
                aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

              { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
              
              ASSIGN glb_cdcritic = 0
                     glb_dscritic = ""
                     glb_cdcritic = INT(pc_gerandb_car.pr_cdcritic) WHEN pc_gerandb_car.pr_cdcritic <> ?
                     glb_dscritic = TRIM(pc_gerandb_car.pr_dscritic) WHEN pc_gerandb_car.pr_dscritic <> ?.
               
                IF glb_cdcritic > 0 THEN
                    DO:
                        RUN fontes/critic.p.
                        MESSAGE glb_dscritic.
                        BELL.
                        glb_cdcritic = 0.
                        NEXT.
                    END.
                ELSE IF glb_dscritic <> ? AND glb_dscritic <> "" THEN
                   DO:
                      MESSAGE glb_dscritic.
                      BELL.
                      glb_cdcritic = 0.
                      NEXT.
                   END. 
               
           END.
      
      IF   craphis.indebcre = "D"   THEN
           craplot.vlcompdb = craplot.vlcompdb - tel_vllanmto.
      ELSE
           IF   craphis.indebcre = "C"   THEN
                craplot.vlcompcr = craplot.vlcompcr - tel_vllanmto.

      craplot.qtcompln = craplot.qtcompln - 1.

      ASSIGN tel_qtinfoln = craplot.qtinfoln   tel_qtcompln = craplot.qtcompln
             tel_vlinfodb = craplot.vlinfodb   tel_vlcompdb = craplot.vlcompdb
             tel_vlinfocr = craplot.vlinfocr   tel_vlcompcr = craplot.vlcompcr
             tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
             tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
             tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr.

      aux_nrdconta = craplcm.nrdconta.

      IF   glb_cdcritic = 0   AND
           aux_indevchq > 0   THEN
           DO:
               IF   aux_flctatco = YES THEN
                    DO:
                        RUN pi_cria_dev (INPUT craptco.cdcopant, /* Coop */
                                         INPUT glb_dtmvtolt,
                                         INPUT crapfdc.cdbanchq,
                                         INPUT aux_indevchq,     /* 5 ou 6 */
                                         INPUT craptco.nrctaant, /* Cta Coop 2*/
                                         INPUT aux_nrdocmto,
                                         INPUT IF   crapfdc.nrdctitg <> "" THEN
                                                    glb_dsdctitg
                                               ELSE "",
                                         INPUT tel_vllanmto,
                                         INPUT aux_cdalinea,
                                         INPUT IF  (aux_indevchq = 5  OR
                                                    aux_indevchq = 6) THEN 
                                                    47
                                               ELSE 78,
                                         INPUT glb_cdoperad,
                                         INPUT crapfdc.cdagechq,
                                         INPUT crapfdc.nrctachq,
                                        OUTPUT glb_cdcritic).
                    END.                    
               ELSE
                    DO:
                        ASSIGN glb_dscritic = "".

                        RUN fontes/geradev.p (INPUT glb_cdcooper,
                                              INPUT glb_dtmvtolt, 
                                              INPUT crapfdc.cdbanchq, 
                                              INPUT aux_indevchq,
                                              INPUT aux_nrdconta,
                                              INPUT aux_nrdocmto, 
                                              INPUT IF crapfdc.nrdctitg <> ""
                                                       THEN glb_dsdctitg
                                                       ELSE "",
                                              INPUT tel_vllanmto,
                                              INPUT aux_cdalinea,
                                              INPUT IF  (aux_indevchq = 5  OR 
                                                         aux_indevchq = 6) THEN
                                                         47
                                                    ELSE 78,
                                              INPUT glb_cdoperad,
                                              INPUT crapfdc.cdagechq,
                                              INPUT crapfdc.nrctachq,
                                              INPUT "landpve",
                                             OUTPUT glb_cdcritic,
                                             OUTPUT glb_dscritic).

                        IF   glb_dscritic <> "" THEN
                        DO:
                            MESSAGE glb_dscritic.
                            BELL.
                            ASSIGN glb_dscritic = "".
                            UNDO, NEXT.
                        END.

                    END.
           END.
                    
      IF   glb_cdcritic     = 0   AND
           craphis.inavisar = 1   THEN
           DO:

               FIND crapass WHERE crapass.cdcooper = glb_cdcooper     AND
                                  crapass.nrdconta = craplcm.nrdconta 
                                  NO-LOCK NO-ERROR.

               IF   NOT AVAILABLE crapass   THEN
                    glb_cdcritic = 9.
               ELSE
                    DO WHILE TRUE:

                       FIND crapavs WHERE
                            crapavs.cdcooper = glb_cdcooper       AND
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
                                 IF  (craplcm.nrdolote > 6499    AND
                                      craplcm.nrdolote < 7000)   OR
                                      CAN-DO("147,165,166,167,192,193,194,195" +
                                             ",254",
                                             STRING(craplcm.cdhistor))  THEN
                                      glb_cdcritic = 0.
                                 ELSE
                                      glb_cdcritic = 448.
                       ELSE
                            DELETE crapavs.

                       LEAVE.

                    END.  /*  Fim do DO WHILE TRUE  */
           END.

      IF   glb_cdcritic > 0 THEN
           DO:
               RUN fontes/critic.p.
               MESSAGE glb_dscritic.
               BELL.
               UNDO, NEXT.
           END.

      /*** Magui alterado em 24/01/2002 ***/
      IF   craplcm.cdhistor = 354   OR    /* credito cotas */
           craplcm.cdhistor = 451   OR    /* credito de estorno de cotas */
           craplcm.cdhistor = 275   OR    /* pagto emprestimo */
           craplcm.cdhistor = 394   OR    /* pagto de emprestimo pelo aval */
           craplcm.cdhistor = 428   OR    /* pagto empr. c/cap */
           craplcm.cdhistor = 506   OR    /* estorno do 428 */
           craplcm.cdhistor = 127   OR    /* debito cotas */
           craplcm.cdhistor = 104   OR    /* trf. valores isento */
           craplcm.cdhistor = 317   OR    /* Estorno de pagto de emprestimo */
           craplcm.cdhistor = 3501  OR    /* Transf. para prejuizo  */
           craplcm.cdhistor = 302   OR    /* trf. valores nao isento */
           craplcm.cdhistor = 1806  OR    /* PAGAMENTO PARCELA FINAME */
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
               ELSE
               IF   craplcm.cdhistor = 1806   THEN
                    ASSIGN his_cdhistor = 1807
                           his_nrdolote = 10003.
                    
               FIND crabhis WHERE crabhis.cdcooper = glb_cdcooper AND
                                  crabhis.cdhistor = his_cdhistor
                                  NO-LOCK NO-ERROR.
               IF   NOT AVAILABLE crabhis   THEN
                    DO:
                        glb_cdcritic = 93.
                        RUN fontes/critic.p.
                        MESSAGE glb_dscritic.
                        BELL.
                        UNDO, NEXT.
                    END.
                    
               DO WHILE TRUE:
                  FIND crablot WHERE crablot.cdcooper = glb_cdcooper   AND
                                     crablot.dtmvtolt = tel_dtmvtolt   AND
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
                        RUN fontes/critic.p.
                        MESSAGE glb_dscritic.
                        BELL.
                        UNDO, NEXT.
                    END.
               
               IF   craplcm.cdhistor = 104   OR
                    craplcm.cdhistor = 302   OR 
                    craplcm.cdhistor = 1806  THEN
                    DO: 
                        FIND crablcm WHERE 
                             crablcm.cdcooper = glb_cdcooper            AND
                             crablcm.dtmvtolt = tel_dtmvtolt            AND
                             crablcm.cdagenci = 1                       AND
                             crablcm.cdbccxlt = 100                     AND
                             crablcm.nrdolote = his_nrdolote            AND
                             crablcm.nrdctabb = INT(craplcm.cdpesqbb)   AND
                             crablcm.nrdocmto = craplcm.nrdocmto
                             USE-INDEX craplcm1
                             EXCLUSIVE-LOCK NO-ERROR.
                      
                        IF   NOT AVAILABLE crablcm   THEN
                             DO:
                                 glb_cdcritic = 81.
                                 RUN fontes/critic.p.
                                 MESSAGE glb_dscritic.
                                 BELL.
                                 UNDO, NEXT.
                             END.
                    
                        UNIX SILENT VALUE("echo " + 
                                          STRING(glb_dtmvtolt,"99/99/9999") +
                                          " - " +
                                          STRING(TIME,"HH:MM:SS") +
                                          " - EXCLUSAO TRF. VAL." + "' --> '"  +
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
                        
                        DELETE crablcm.
                    END.
               ELSE
               IF   craplcm.cdhistor = 354   OR
                    craplcm.cdhistor = 451   OR
                    craplcm.cdhistor = 127   THEN
                    DO: 
                        ASSIGN aux_flexclcm = NO.
                        FIND craplct WHERE craplct.cdcooper = glb_cdcooper  AND
                                           craplct.dtmvtolt = tel_dtmvtolt  AND
                                           craplct.cdagenci = 1             AND
                                           craplct.cdbccxlt = 100           AND
                                           craplct.nrdolote = his_nrdolote  AND
                                           craplct.nrdconta = tel_nrdctabb  AND
                                           craplct.nrdocmto = aux_nrdocmto   
                                           EXCLUSIVE-LOCK NO-ERROR.
                                         
                        IF   NOT AVAILABLE craplct   THEN
                             DO:
                                 IF  crapass.inpessoa = 1   THEN 
                                     DO:
                                         FIND crapttl WHERE 
                                              crapttl.cdcooper = 
                                                      glb_cdcooper      AND
                                              crapttl.nrdconta = 
                                                      crapass.nrdconta  AND
                                              crapttl.idseqttl = 1 
                                              NO-LOCK NO-ERROR.
    
                                         IF  AVAIL crapttl  THEN
                                             ASSIGN aux_cdempres = 
                                                        crapttl.cdempres.
                                     END.
                                 ELSE
                                     DO:
                                         FIND crapjur WHERE 
                                              crapjur.cdcooper = 
                                                      glb_cdcooper  AND
                                              crapjur.nrdconta = 
                                                      crapass.nrdconta
                                              NO-LOCK NO-ERROR.
                               
                                         IF  AVAIL crapjur  THEN
                                             ASSIGN aux_cdempres = 
                                                        crapjur.cdempres.
                                     END.     
                            
                                  /*** Magui - verificar se e lote de folha, se
                                  sim, eliminar so craplcm, o craplct e elimi-
                                  nado pela tela LANPLA ***/
                                 FIND craptab 
                                WHERE craptab.cdcooper = glb_cdcooper    AND
                                       craptab.nmsistem = "CRED"         AND
                                       craptab.tptabela = "GENERI"       AND
                                       craptab.cdempres = 0              AND
                                       craptab.cdacesso = "NUMLOTEFOL"   AND
                                       craptab.tpregist = aux_cdempres
                                 USE-INDEX craptab1 NO-LOCK NO-ERROR.
                                 IF   AVAILABLE craptab   THEN
                                      DO:
                                       IF INTE(SUBSTR(STRING(craptab.dstextab,
                                               "999999"),1,1)) = 
                                          INTE(SUBSTR(STRING(craplcm.nrdolote,
                      "999999"),6 - LENGTH(STRING(craplcm.nrdolote)) + 1,1))
                                          THEN DO:
                                              ASSIGN aux_flexclcm = YES.
                                          END.
                                      END.
                                 ELSE
                                      DO:
                                          glb_cdcritic = 81.
                                          RUN fontes/critic.p.
                                          MESSAGE glb_dscritic.
                                          BELL.
                                          UNDO, NEXT.
                                      END.
                             END.
                        IF   NOT aux_flexclcm   THEN DO: 

                        FIND crapcot WHERE crapcot.cdcooper = glb_cdcooper AND
                                           crapcot.nrdconta = craplct.nrdconta
                                           EXCLUSIVE-LOCK NO-ERROR.
                        
                        IF   NOT AVAILABLE crapcot   THEN
                             DO:
                                 glb_cdcritic = 169.
                                 RUN fontes/critic.p.
                                 MESSAGE glb_dscritic.
                                 BELL.
                                 UNDO, NEXT.
                             END.
                        
                        IF   crabhis.inhistor = 6   THEN
                             DO:
                                 IF   crapcot.vldcotas >= tel_vllanmto THEN
                                      crapcot.vldcotas = crapcot.vldcotas -
                                                         tel_vllanmto.
                                 ELSE
                                      DO:
                                          glb_cdcritic = 203.
                                          RUN fontes/critic.p.
                                          MESSAGE glb_dscritic.
                                          BELL.
                                          UNDO, NEXT.
                                      END.
                             END.
                        ELSE
                        IF   crabhis.inhistor = 16   THEN
                             crapcot.vldcotas = crapcot.vldcotas + tel_vllanmto.

                        DELETE craplct.
                        END.
                    END.
               ELSE 
                    IF  craplcm.cdhistor = 931 THEN 
                        DO:   
                           FIND craplct WHERE craplct.cdcooper = glb_cdcooper  AND
                                              craplct.dtmvtolt = tel_dtmvtolt  AND
                                              craplct.cdagenci = 1             AND
                                              craplct.cdbccxlt = 100           AND
                                              craplct.nrdolote = his_nrdolote  AND
                                              craplct.nrdconta = tel_nrdctabb  AND
                                              craplct.nrdocmto = aux_nrdocmto   
                                              EXCLUSIVE-LOCK NO-ERROR.
                       
                           IF  NOT AVAIL craplct THEN
                               IF  LOCKED craplct   THEN             
                                   DO:                               
                                    RUN sistema/generico/procedures/b1wgen9999.p
                                    PERSISTENT SET h-b1wgen9999.
                                    
                                    RUN acha-lock IN h-b1wgen9999 (INPUT RECID(craplct),
                                                                             INPUT "banco",
                                                                             INPUT "craplct",
                                                                             OUTPUT par_loginusr,
                                                                             OUTPUT par_nmusuari,
                                                                             OUTPUT par_dsdevice,
                                                                             OUTPUT par_dtconnec,
                                                                             OUTPUT par_numipusr).
                                    
                                    DELETE PROCEDURE h-b1wgen9999.
                                    
                                    ASSIGN aux_dadosusr = 
                                    "077 - Tabela sendo alterada p/ outro terminal.".
                                    
                                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                    MESSAGE aux_dadosusr.
                                    PAUSE 3 NO-MESSAGE.
                                    LEAVE.
                                    END.
                                    
                                    ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                                                              " - " + par_nmusuari + ".".
                                    
                                    HIDE MESSAGE NO-PAUSE.
                                    
                                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                    MESSAGE aux_dadosusr.
                                    PAUSE 5 NO-MESSAGE.
                                    LEAVE.
                                    END.
                                    
         
                                       NEXT.                         
                                   END.                              
                               ELSE
                                   DO:
                                       glb_cdcritic = 81.
                                       RUN fontes/critic.p.
                                       MESSAGE glb_dscritic.
                                       BELL.
                                       UNDO, NEXT.
                                   END.
                       
                           DO aux_contador = 1 TO 10 :                    
                                                                  
                              FIND crapcot WHERE                          
                                   crapcot.cdcooper = glb_cdcooper     AND
                                   crapcot.nrdconta = craplcm.nrdconta    
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.       
                                                                          
                              IF   NOT AVAILABLE crapcot   THEN           
                                   IF   LOCKED crapcot   THEN             
                                        DO:                               
                                            RUN sistema/generico/procedures/b1wgen9999.p
                                            PERSISTENT SET h-b1wgen9999.
                                            
                                            RUN acha-lock IN h-b1wgen9999 (INPUT RECID(crapcot),
                                                                                     INPUT "banco",
                                                                                     INPUT "crapcot",
                                                                                     OUTPUT par_loginusr,
                                                                                     OUTPUT par_nmusuari,
                                                                                     OUTPUT par_dsdevice,
                                                                                     OUTPUT par_dtconnec,
                                                                                     OUTPUT par_numipusr).
                                            
                                            DELETE PROCEDURE h-b1wgen9999.
                                            
                                            ASSIGN aux_dadosusr = 
                                            "077 - Tabela sendo alterada p/ outro terminal.".
                                            
                                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                            MESSAGE aux_dadosusr.
                                            PAUSE 3 NO-MESSAGE.
                                            LEAVE.
                                            END.
                                            
                                            ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                                                                      " - " + par_nmusuari + ".".
                                            
                                            HIDE MESSAGE NO-PAUSE.
                                            
                                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                            MESSAGE aux_dadosusr.
                                            PAUSE 5 NO-MESSAGE.
                                            LEAVE.
                                            END.
                                            
        
                                            NEXT.                         
                                        END.                              
                                    ELSE                                  
                                    DO:                                      
                                       ASSIGN glb_cdcritic = 55.          
                                       LEAVE.                             
                                    END.                                  
                              ELSE                                        
                                  ASSIGN glb_cdcritic = 0.                
                                                                          
                              LEAVE.                                      
                                                                       
                           END.  /*  Fim do DO WHILE TRUE   */  
                       
                           IF   glb_cdcritic > 0   THEN
                                UNDO, NEXT. 

                           IF   tel_vllanmto <> craplct.vllanmto   THEN
                                 DO: 
                                      glb_cdcritic = 203.
                                      RUN fontes/critic.p.
                                      MESSAGE glb_dscritic.
                                      BELL.
                                      UNDO, NEXT.
                                 END.
                       
                       
                           ASSIGN crapcot.vldcotas = crapcot.vldcotas + 
                                                     craplct.vllanmto.

                           DELETE craplct. 

                    END.  
               ELSE     /*  Hst 275, 394, 428, 350 e 317 e 506  */
                    DO:
                      
                      /* Verifica se possui contrato de acordo */
                      { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                      /* Verifica se ha contratos de acordo */
                      RUN STORED-PROCEDURE pc_verifica_situacao_acordo
                        aux_handproc = PROC-HANDLE NO-ERROR (INPUT glb_cdcooper
                                                            ,INPUT craplcm.nrdconta
                                                            ,INPUT INT(ENTRY(1,craplcm.cdpesqbb, ";"))
															,INPUT 3
                                                            ,OUTPUT 0 /* pr_flgretativo */
                                                            ,OUTPUT 0 /* pr_flgretquitado */
                                                            ,OUTPUT 0 /* pr_flgretcancelado */
                                                            ,OUTPUT 0
                                                            ,OUTPUT "").

                      CLOSE STORED-PROC pc_verifica_situacao_acordo
                        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                      { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                      
                      ASSIGN glb_cdcritic      = 0
                             glb_dscritic      = ""
                             glb_cdcritic      = INT(pc_verifica_situacao_acordo.pr_cdcritic) WHEN pc_verifica_situacao_acordo.pr_cdcritic <> ?
                             glb_dscritic      = TRIM(pc_verifica_situacao_acordo.pr_dscritic) WHEN pc_verifica_situacao_acordo.pr_dscritic <> ?
                             aux_flgretativo   = INT(pc_verifica_situacao_acordo.pr_flgretativo)
                             aux_flgretquitado = INT(pc_verifica_situacao_acordo.pr_flgretquitado).
                      
                      IF glb_cdcritic > 0 THEN
                        DO:
                           RUN fontes/critic.p.
                           MESSAGE glb_dscritic.
                           BELL.
                           UNDO, NEXT.
                        END.
                      ELSE IF glb_dscritic <> ? AND glb_dscritic <> "" THEN
                        DO:
                          MESSAGE glb_dscritic.
                          BELL.
                          UNDO, NEXT.
                        END.
                        
                      /* Se estiver ATIVO */
                      IF aux_flgretativo = 1 THEN
                        DO:
                          MESSAGE "Lancamento nao permitido, emprestimo em acordo.".
                          PAUSE 3 NO-MESSAGE.
                          UNDO, NEXT.
                        END.
                        
                      /* Se estiver QUITADO */
                      IF aux_flgretquitado = 1 THEN
                        DO:
                          MESSAGE "Lancamento nao permitido, contrato liquidado atraves de acordo.".
                          PAUSE 3 NO-MESSAGE.
                          UNDO, NEXT.
                        END.

                      /* Fim verifica se possui contrato de acordo */              
                    
                        RUN fontes/saldo_epr.p 
                                   (INPUT  craplcm.nrdconta,
                                    INPUT  INT(ENTRY(1, craplcm.cdpesqbb, ";")),
                                    OUTPUT his_vlsdeved,
                                    OUTPUT aux_qtprecal_retorno).
 
                        IF   glb_cdcritic > 0   THEN
                             DO:
                                 RUN fontes/critic.p.
                                 MESSAGE glb_dscritic.
                                 BELL.
                                 UNDO, NEXT.
                             END.                       
                    
                        FIND crapepr WHERE
                             crapepr.cdcooper = glb_cdcooper           AND
                             crapepr.nrdconta = tel_nrdctabb           AND
                             crapepr.nrctremp = INT(ENTRY(1, 
                                                        craplcm.cdpesqbb, ";"))
                             EXCLUSIVE-LOCK NO-ERROR.
                        
                        IF   NOT AVAILABLE crapepr   THEN
                             DO:
                                 ASSIGN glb_cdcritic = 356.
                                 RUN fontes/critic.p.
                                 MESSAGE glb_dscritic.
                                 BELL.
                                 UNDO,NEXT.
                             END.
                       
                        IF   crapepr.flgpagto   THEN
                             RUN p_atualiza_avs.
                        ELSE 
                             IF   crapepr.qtmesdec > 0   THEN
                                  RUN p_atualiza_dtdpagto(INPUT FALSE,
                                                          INPUT tel_vllanmto).
                                  
                        FIND craplem WHERE craplem.cdcooper = glb_cdcooper  AND
                                           craplem.dtmvtolt = tel_dtmvtolt  AND
                                           craplem.cdagenci = 1             AND
                                           craplem.cdbccxlt = 100           AND
                                           craplem.nrdolote = his_nrdolote  AND
                                           craplem.nrdconta = tel_nrdctabb  AND
                                           craplem.nrdocmto = aux_nrdocmto
                                           EXCLUSIVE-LOCK NO-ERROR.
                        
                        IF   NOT AVAILABLE craplem   THEN
                             DO:
                                 glb_cdcritic = 81.
                                 RUN fontes/critic.p.
                                 MESSAGE glb_dscritic.
                                 BELL.
                                 UNDO, NEXT.
                             END.

                        IF   craplem.cdhistor = 88   OR 
                             craplem.cdhistor = 507  THEN 
                             ASSIGN  crapepr.inliquid = 
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

                        RUN verifica_contrato_rating IN h-b1wgen0043
                                                (INPUT glb_cdcooper,
                                                 INPUT 0,
                                                 INPUT 0,
                                                 INPUT glb_cdoperad,
                                                 INPUT glb_dtmvtolt,
                                                 INPUT glb_dtmvtopr,
                                                 INPUT crapepr.nrdconta,
                                                 INPUT 90, /* Emprestimo*/
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

                                 UNDO , NEXT EXCLUSAO.
                             END.
                                                        
                        DELETE craplem.
                        
                        ASSIGN aux_dtultpag = crapepr.dtmvtolt.

                        FOR EACH crablem WHERE
                                 crablem.cdcooper = glb_cdcooper       AND
                                 crablem.nrdconta = crapepr.nrdconta   AND
                                 crablem.nrctremp = crapepr.nrctremp   NO-LOCK:

                           FIND crabhis2 OF crablem NO-LOCK NO-ERROR.

                           IF   NOT AVAILABLE crabhis2   THEN
                                NEXT.

                           IF   crabhis2.indebcre = "C"   THEN
                                ASSIGN aux_dtultpag = crablem.dtmvtolt.

                        END.  /*  Fim do FOR EACH  -- 
                                  Pesquisa do ultimo pagamento  */

                        ASSIGN crapepr.dtultpag = aux_dtultpag.
                        
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
                           
      END. /* END do IF Magui */
      

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
                        
                        UNDO, NEXT.
                    END.                          

               DELETE crapcme.

           END.
          

      /*** Tratamento da Compensacao Eletronica ***/
      IF   craplcm.cdhistor = 3   OR
           craplcm.cdhistor = 4   OR
           craplcm.cdhistor = 372 OR
           craplcm.cdhistor = 386 THEN 
           DO:
               /*  Busca dados da cooperativa  */
                    
               FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper 
                                  NO-LOCK NO-ERROR.

               IF   NOT AVAILABLE crapcop THEN
                    DO:
                        glb_cdcritic = 651.
                        RUN fontes/critic.p.
                        MESSAGE glb_dscritic.
                        BELL.
                        UNDO, NEXT.
                    END.
                      
               FOR EACH crapchd WHERE crapchd.cdcooper = glb_cdcooper       AND
                                      crapchd.dtmvtolt = craplcm.dtmvtolt   AND
                                      crapchd.cdagenci = craplcm.cdagenci   AND
                                      crapchd.cdbccxlt = craplcm.cdbccxlt   AND
                                      crapchd.nrdolote = craplcm.nrdolote   AND
                                      crapchd.nrseqdig = craplcm.nrseqdig
                                      USE-INDEX crapchd3 EXCLUSIVE-LOCK:
                   
                   IF   craplcm.cdhistor = 386   THEN 
                        DO:
                            FIND crabfdc WHERE
                                 crabfdc.cdcooper = glb_cdcooper      AND
                                 crabfdc.cdbanchq = crapchd.cdbanchq  AND
                                 crabfdc.cdagechq = crapchd.cdagechq  AND
                                 crabfdc.nrctachq = crapchd.nrctachq  AND
                                 crabfdc.nrcheque = crapchd.nrcheque
                                 USE-INDEX crapfdc1 EXCLUSIVE-LOCK NO-ERROR.
                               
                            IF   NOT AVAILABLE crabfdc   THEN
                                 DO:
                                     glb_cdcritic = 108.
                                     RETURN.
                                 END.
                            
                            ASSIGN crabfdc.incheque = crabfdc.incheque - 5
                                   crabfdc.dtliqchq = ?
                                   crabfdc.vlcheque = 0
                                   crabfdc.vldoipmf = 0
                                   crabfdc.cdbandep = 0
                                   crabfdc.cdagedep = 0
                                   crabfdc.nrctadep = 0
                                   
                                   glb_nrcalcul = 
                                       INT(STRING(crapchd.nrcheque,"999999") +
                                           STRING(crapchd.nrddigc3,"9")).
                             
                            FIND crablcm WHERE 
                                 crablcm.cdcooper = glb_cdcooper           AND
                                 crablcm.dtmvtolt = craplcm.dtmvtolt       AND
                                 crablcm.cdagenci = craplcm.cdagenci       AND
                                 crablcm.cdbccxlt = craplcm.cdbccxlt       AND
                                 crablcm.nrdolote = craplcm.nrdolote       AND
                                 crablcm.nrdctabb = inte(crapchd.nrctachq) AND
                                 crablcm.nrdocmto = glb_nrcalcul           
                                 USE-INDEX craplcm1
                                 EXCLUSIVE-LOCK NO-ERROR.

                            IF   AVAILABLE crablcm   THEN
                                 DO:
                                     ASSIGN craplot.qtcompln = 
                                                    craplot.qtcompln - 1
                                            craplot.qtinfoln =
                                                    craplot.qtinfoln - 1
                                            craplot.vlcompdb = 
                                                    craplot.vlcompdb -
                                                            crablcm.vllanmto
                                            craplot.vlinfodb =
                                                    craplot.vlinfodb -
                                                            crablcm.vllanmto.
               
                                     DELETE crablcm.
                                 END.
                        END.               
                   
                   DELETE crapchd. 
               END.
      END. /* END do IF compens. Eletronica */
      /********************************************/
      
      IF   tel_cdhistor = 481   OR   tel_cdhistor = 483   THEN
           DO:
               IF   tel_cdhistor = 481   THEN
                    DO:
                        FIND crapsli WHERE 
                             crapsli.cdcooper  = glb_cdcooper           AND
                             crapsli.nrdconta  = tel_nrdctabb           AND
                       MONTH(crapsli.dtrefere) = MONTH(glb_dtmvtolt)    AND
                        YEAR(crapsli.dtrefere) =  YEAR(glb_dtmvtolt)   
                             NO-LOCK NO-ERROR.

                        IF   (NOT AVAILABLE crapsli)                   OR
                             (crapsli.vlsddisp - tel_vllanmto < 0)     THEN
                             DO:
                
                                 MESSAGE "ATENCAO! O saldo da CONTA DE"
                                         "INVESTIMENTO ficara NEGATIVO!"
                                         VIEW-AS ALERT-BOX.
                                  
                                 RUN fontes/pedesenha.p (INPUT glb_cdcooper,
                                                         INPUT 2, 
                                                         OUTPUT aut_flgsenha,
                                                         OUTPUT aut_cdoperad).
                                                                              
                                 IF   aut_flgsenha    THEN
                                      DO:
                                          UNIX SILENT VALUE("echo " +
                                                      STRING(glb_dtmvtolt,
                                                             "99/99/9999") +
                                                      " - " +
                                                      STRING(TIME,"HH:MM:SS") +
                                                      " - AUTORIZACAO - CONTA "
                                                      + "DE INVESTIMENTO" + 
                                                      "' --> '" +
                                                      " Operador: " +
                                                      aut_cdoperad +
                                                      " Conta: " +
                                                      STRING(tel_nrdctabb,
                                                             "zzzz,zzz,9") +
                                                      " Valor: " +
                                                      STRING(tel_vllanmto,
                                                           "zzz,zzz,zzz,zz9.99")
                                                      + " >> log/landpv.log").
                                      END.
                                 ELSE
                                      NEXT.
                             END.
                    END.

               RUN elimina_lancamentos_craplci.
           END.

      UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " - " +
                        STRING(TIME,"HH:MM:SS") + 
                        " - EXCLUSAO DE LANCAMENTO " + "'-->'" +
                        " Operador: " + glb_cdoperad +
                        " PA:          " + STRING(tel_cdagenci,"999") +
                        " Banco/Caixa: " + STRING(tel_cdbccxlt,"999") +
                        " Lote: " + TRIM(STRING(craplcm.nrdolote,"zzz,zz9")) + 

                        " Hst: " + STRING(craplcm.cdhistor) +
                        " Conta: " + TRIM(STRING(craplcm.nrdconta,
                                                 "zz,zzz,zzz,z")) + 
                        " Bco: " + STRING(tel_cdbaninf,"999") + 
                        " Age: " + STRING(tel_cdageinf,"999") + 
                        " Doc: " + STRING(craplcm.nrdocmto)   +
                        " Valor: " + TRIM(STRING(craplcm.vllanmto,
                                                 "zzzzzz,zzz,zz9.99")) +

                        " Contrato: " + craplcm.cdpesqbb +
                        " >> log/landpv.log").
    
      /* Trazer nome do supervisor */
      FIND crapope WHERE crapope.cdcooper = glb_cdcooper   AND
                         crapope.cdoperad = par_cdoperad    
                         NO-LOCK NO-ERROR.

      IF   AVAIL crapope   THEN
           par_cdoperad = par_cdoperad + " - " + crapope.nmoperad.                               

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
                                    INPUT tel_nrdctabb,
                                    OUTPUT par_nrdrowid).

      /* Logar valor do lançamento */
      RUN gera_log_item IN h-b1wgen0014 (INPUT par_nrdrowid,
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
      /* Logar PA*/
      RUN gera_log_item IN h-b1wgen0014 (INPUT par_nrdrowid,
                                         INPUT "PA",
                                         INPUT "",
                                         INPUT STRING(craplcm.cdagenci)).
      /* Logar Banco/Caixa */
      RUN gera_log_item IN h-b1wgen0014 (INPUT par_nrdrowid,
                                         INPUT "Banco/Caixa",
                                         INPUT "",
                                         INPUT STRING(craplcm.cdbccxlt)).
      DELETE PROCEDURE h-b1wgen0014.
      
      /* No caso de Débito Automático é necessario deletar 
        autenticacao e protocolo */
      IF  AVAILABLE craplau THEN
      DO:
          /*Buscar autenticaçao do lançamento */
          FIND FIRST crapaut 
               WHERE crapaut.cdcooper = craplcm.cdcooper
                 AND crapaut.cdagenci = craplcm.cdagenci
                 AND crapaut.nrdcaixa = 900
                 AND crapaut.nrdocmto = craplcm.nrdocmto
                 AND crapaut.nrsequen = craplcm.nrautdoc
                 EXCLUSIVE-LOCK NO-ERROR.
                 
          IF AVAILABLE crapaut THEN        
          DO:
            /* buscar protocolo do lancamento*/
            FIND FIRST crappro 
                 WHERE crappro.cdcooper = craplcm.cdcooper
                   AND crappro.dsprotoc = crapaut.dsprotoc
                   EXCLUSIVE-LOCK NO-ERROR.
            IF AVAILABLE crappro THEN       
            DO:
              /* deletar autenticacao e protocolo*/ 
              DELETE crappro.
              DELETE crapaut.
            END.
            
          END.
      END. 

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


      IF  glb_dscritic <> "" THEN
		  DO:
			MESSAGE "Erro na exclusao do lancamento.".
                      
            PAUSE 2 NO-MESSAGE.
                        
            UNDO, NEXT.
          END.

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
      
      IF  VALID-HANDLE(h-b1wgen0200) THEN
          DELETE PROCEDURE h-b1wgen0200.

      /* Altera situação de lançamento automático para Rejeitado no caso Débito Automático */
      IF  AVAILABLE craplau THEN
          DO:
              FIND CURRENT craplau EXCLUSIVE-LOCK.
              ASSIGN craplau.insitlau = 3
                     craplau.cdcritic = 739.
          END.

   END.   /*  Fim da transacao.  */

   RELEASE crapfdc.

   IF   tel_qtdifeln = 0  AND  tel_vldifedb = 0  AND  tel_vldifecr = 0   THEN
        DO:
            RUN fontes/landpvr.p. /* Resumo do cheques acolhidos */
            
            glb_nmdatela = "LOTE".
            RETURN.                        /* Volta ao landpv.p */
        END.

   ASSIGN tel_cdhistor = 0  tel_nrdctabb = 0  tel_nrdocmto = 0
          tel_vllanmto = 0  tel_dtliblan = ?  tel_cdalinea = 0
          aux_nrdocmto = 0.

   DISPLAY tel_qtinfoln tel_vlinfodb tel_vlinfocr
           tel_qtcompln tel_vlcompdb tel_vlcompcr
           tel_qtdifeln tel_vldifedb tel_vldifecr
           tel_cdhistor tel_nrdctabb tel_nrdocmto
           tel_vllanmto tel_dtliblan tel_cdalinea
           WITH FRAME f_landpv.
   PAUSE(0).


END.  /*  Fim do DO WHILE TRUE  */

{ includes/proc_conta_integracao.i }

/* .......................................................................... */

PROCEDURE elimina_lancamentos_craplci.

   /* Eliminar os lancamentos CI */

   FIND craplci WHERE craplci.cdcooper = glb_cdcooper AND
                      craplci.dtmvtolt = tel_dtmvtolt AND
                      craplci.cdagenci = tel_cdagenci AND
                      craplci.cdbccxlt = 100          AND
                      craplci.nrdolote = 10006        AND
                      craplci.nrdconta = aux_nrdconta AND
                      craplci.nrdocmto = aux_nrdocmto EXCLUSIVE-LOCK NO-ERROR. 
                               
   /* Verificar Conta Investimento */
   
   FIND crapsli WHERE crapsli.cdcooper  = glb_cdcooper            AND 
                      crapsli.nrdconta  = craplci.nrdconta        AND
                MONTH(crapsli.dtrefere) = MONTH(craplci.dtmvtolt) AND
                 YEAR(crapsli.dtrefere) = YEAR(craplci.dtmvtolt)  
                      EXCLUSIVE-LOCK NO-ERROR.
   
   IF  NOT AVAIL crapsli THEN
       DO:
           ASSIGN aux_dtrefere = 
           ((DATE(MONTH(craplci.dtmvtolt),28,YEAR(craplci.dtmvtolt)) + 4) -
              DAY(DATE(MONTH(craplci.dtmvtolt),28,
              YEAR(craplci.dtmvtolt)) + 4)).
           
           CREATE crapsli.
           ASSIGN crapsli.dtrefere = craplci.dtmvtolt
                  crapsli.nrdconta = craplci.nrdconta
                  crapsli.cdcooper = glb_cdcooper.
       END.

   FIND craplot WHERE craplot.cdcooper = glb_cdcooper  AND
                      craplot.dtmvtolt = tel_dtmvtolt  AND
                      craplot.cdagenci = tel_cdagenci  AND
                      craplot.cdbccxlt = 100           AND
                      craplot.nrdolote = 10006         AND
                      craplot.tplotmov = 29            EXCLUSIVE-LOCK NO-ERROR.
                  
   ASSIGN craplot.qtcompln = craplot.qtcompln - 1
          craplot.qtinfoln = craplot.qtinfoln - 1.
   
   IF   tel_cdhistor = 481   THEN
        ASSIGN craplot.vlcompcr = craplot.vlcompcr - craplci.vllanmto
               craplot.vlinfocr = craplot.vlinfocr - craplci.vllanmto
               crapsli.vlsddisp = crapsli.vlsddisp - craplci.vllanmto.
   ELSE
   IF   tel_cdhistor = 483   THEN
        ASSIGN craplot.vlcompdb = craplot.vlcompdb - craplci.vllanmto
               craplot.vlinfodb = craplot.vlinfodb - craplci.vllanmto        
               crapsli.vlsddisp = crapsli.vlsddisp + craplci.vllanmto.
               
   IF   craplot.qtcompln = 0   AND   craplot.qtinfoln = 0   AND
        craplot.vlcompdb = 0   AND   craplot.vlinfodb = 0   AND
        craplot.vlcompcr = 0   AND   craplot.vlinfocr = 0   THEN
        DELETE craplot.               
        
   DELETE craplci.

   RELEASE crapsli.
   RELEASE craplci.
   RELEASE craplot.
     
END PROCEDURE.

/* .......................................................................... */

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
                          crapavs.vlestdif = crapavs.vldebito - crapavs.vllanmto.
                    
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

       END. /* IF pro_vllanmto .... */
       
END. /* p_atualiza_avs */

/* .......................................................................... */

PROCEDURE pi_cria_dev:

DEF INPUT  PARAM par_cdcooper AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_dtmvtolt AS DATE                                NO-UNDO.
DEF INPUT  PARAM par_cdbccxlt AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_inchqdev AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_nrdconta AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_nrdocmto AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_nrdctitg AS CHAR                                NO-UNDO.
DEF INPUT  PARAM par_vllanmto AS DECIMAL                             NO-UNDO.
DEF INPUT  PARAM par_cdalinea AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_cdhistor AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_cdoperad AS CHAR                                NO-UNDO.
DEF INPUT  PARAM par_cdagechq LIKE crapfdc.cdagechq                  NO-UNDO.
DEF INPUT  PARAM par_nrctachq LIKE crapfdc.nrctachq                  NO-UNDO.
DEF OUTPUT PARAM par_cdcritic AS INT                                 NO-UNDO.


  IF  par_inchqdev = 5   THEN
     DO WHILE TRUE:

        FIND crabdev WHERE crabdev.cdcooper = par_cdcooper     AND
                           crabdev.cdbanchq = crapfdc.cdbanchq AND
                           crabdev.cdagechq = par_cdagechq     AND
                           crabdev.nrctachq = par_nrctachq     AND
                           crabdev.nrcheque = par_nrdocmto     AND
                           crabdev.cdhistor = par_cdhistor
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
        IF   NOT AVAILABLE crabdev   THEN
             IF   LOCKED crabdev   THEN
                  DO:
                      PAUSE 2 NO-MESSAGE.
                      NEXT.
                  END.
             ELSE
                  DO:
                      par_cdcritic = 416.
                      RETURN.
                  END.

        IF   (crabdev.cdalinea > 40 AND crabdev.cdalinea < 50) OR
             (crabdev.cdalinea = 20)                           OR
             (crabdev.cdalinea = 28)                           OR
             (crabdev.cdalinea = 30)                           OR
             (crabdev.cdalinea = 32)                           OR
             (crabdev.cdalinea = 35)                           OR
             (crabdev.cdalinea = 72)                           THEN
              .
        ELSE
             DO:

                 FIND crapdev WHERE crapdev.cdcooper = par_cdcooper     AND
                                    crapdev.cdbanchq = crapfdc.cdbanchq AND
                                    crapdev.cdagechq = par_cdagechq     AND
                                    crapdev.nrctachq = par_nrctachq     AND
                                    crapdev.nrcheque = par_nrdocmto     AND
                                    crapdev.cdhistor = 46
                                    EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                 IF   NOT AVAILABLE crapdev   THEN
                      IF   LOCKED crapdev   THEN
                           DO:
                               PAUSE 2 NO-MESSAGE.
                               NEXT.
                           END.
                      ELSE
                           DO:
                               par_cdcritic = 416.
                               RETURN.
                           END.
               
                 DELETE crapdev.

             END.

        DELETE crabdev.

        LEAVE.

     END.  /*  Fim do DO WHILE TRUE  */

  IF  par_inchqdev = 6   OR
      par_inchqdev = 8   THEN
     DO WHILE TRUE:
          
        FIND crabdev WHERE crabdev.cdcooper = par_cdcooper     AND
                           crabdev.cdbanchq = crapfdc.cdbanchq AND
                           crabdev.cdagechq = par_cdagechq     AND
                           crabdev.nrctachq = par_nrctachq     AND
                           crabdev.nrcheque = par_nrdocmto     AND
                           crabdev.cdhistor = par_cdhistor
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
        IF   NOT AVAILABLE crabdev   THEN
             IF   LOCKED crabdev   THEN
                  DO:
                      PAUSE 2 NO-MESSAGE.
                      NEXT.
                  END.
             ELSE
                  DO:
                      par_cdcritic = 416.
                      RETURN.
                  END.

        IF   (crabdev.cdalinea > 40 AND crabdev.cdalinea < 50) OR
             (crabdev.cdalinea = 20)                       OR
             (crabdev.cdalinea = 28)                       OR
             (crabdev.cdalinea = 30)                       OR
             (crabdev.cdalinea = 32)                       OR
             (crabdev.cdalinea = 35)                       OR
             (crabdev.cdalinea = 72)                       THEN
             .
        ELSE
             DO:   

                 FIND crapdev WHERE crapdev.cdcooper = par_cdcooper     AND
                                    crapdev.cdbanchq = crapfdc.cdbanchq AND
                                    crapdev.cdagechq = par_cdagechq     AND
                                    crapdev.nrctachq = par_nrctachq     AND
                                    crapdev.nrcheque = par_nrdocmto     AND
                                    crapdev.cdhistor = 46
                                    EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                 IF   NOT AVAILABLE crapdev   THEN
                      IF   LOCKED crapdev   THEN
                           DO:
                              PAUSE 2 NO-MESSAGE.
                              NEXT.
                           END.
                      ELSE
                           DO:
                               par_cdcritic = 416.
                               RETURN.
                           END.

                 DELETE crapdev.
             END.

        DELETE crabdev.

        LEAVE.

     END.  /*  Fim do DO WHILE TRUE  */


END PROCEDURE.

/* .......................................................................... */
