CREATE OR REPLACE PROCEDURE CECRED."PC_CRPS032" (pr_cdcooper IN crapcop.cdcooper%TYPE
                                      ,pr_flgresta  IN PLS_INTEGER            --> Indicador para utilização de restart
                                      ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                      ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                      ,pr_dscritic OUT VARCHAR2) IS
  BEGIN

/* ..........................................................................

   Programa: pc_crps032                            (Antigo Fontes/crps032.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Agosto/92.                          Ultima atualizacao: 28/07/2015

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Atende a solicitacao 018.
               Calculo mensal da correcao monetaria do capital.

   Alteracoes: 13/05/95 - Alterado para incluir nova rotina de correcao mone-
                          taria trimestral (Edson).

               22/04/98 - Tratamento para milenio e troca para V8 (Margarete).

             14/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

             14/01/2008 - Alimentar novo campo: crpcot.vlcapfdm (Edson).

             30/06/2008 - Incluida a chave de acesso (craphis.cdcooper =
                          glb_cdcooper) no "for each".
                        - Kbase IT Solutons - Paulo Ricardo Maciel.

             19/10/2009 - Alteracao Codigo Historico (Kbase).

             08/03/2010 - Alteracao Historico (Gati)

             18/11/2010 - Alteracao para desprezar contas com o vldcotas
                          negativo e gerar mensagem no log do processo
                          (Adriano).

             09/05/2013 - Conversão Progress -> Oracle - Alisson (AMcom)

             09/08/2013 - Remoção da flag de restart pois não há controle (Marcos-Supero)
             
             28/07/2015 - Alterado lo/proc_batch para log/proc_message.log SD 306561 
                         (Kelvin)

     ............................................................................. */

     DECLARE

       /* Tipos e registros da pc_crps032 */
       TYPE typ_reg_crapcot IS
         RECORD (nrdconta      crapcot.nrdconta%TYPE
                ,vlcapfdm      crapcot.vlcapfdm%TYPE
                ,vlcmmcot      crapcot.vlcmmcot%TYPE
                ,qtcotmfx      crapcot.qtcotmfx%TYPE
                ,vlcmecot      crapcot.vlcmecot%TYPE
                ,vlcapmes##1   crapcot.vlcapmes##1%TYPE
                ,vlcapmes##2   crapcot.vlcapmes##2%TYPE
                ,vlcapmes##3   crapcot.vlcapmes##3%TYPE
                ,vlcapmes##4   crapcot.vlcapmes##4%TYPE
                ,vlcapmes##5   crapcot.vlcapmes##5%TYPE
                ,vlcapmes##6   crapcot.vlcapmes##6%TYPE
                ,vlcapmes##7   crapcot.vlcapmes##7%TYPE
                ,vlcapmes##8   crapcot.vlcapmes##8%TYPE
                ,vlcapmes##9   crapcot.vlcapmes##9%TYPE
                ,vlcapmes##10  crapcot.vlcapmes##10%TYPE
                ,vlcapmes##11  crapcot.vlcapmes##11%TYPE
                ,vlcapmes##12  crapcot.vlcapmes##12%TYPE);

       TYPE typ_reg_craplct IS
         RECORD (vr_rowid ROWID
                ,qtlanmfx NUMBER);

       --Definicao do tipo de registro para tabela detalhes
        TYPE typ_tab_vlmoefix IS VARRAY(3) OF NUMBER;
        TYPE typ_tab_vlcapmes IS VARRAY(12) OF NUMBER;


       --Definicao dos tipos de tabelas de memoria
       TYPE typ_tab_craphis IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
       TYPE typ_tab_crapmfx IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
       TYPE typ_tab_crapcot IS TABLE OF typ_reg_crapcot INDEX BY PLS_INTEGER;
       TYPE typ_tab_craplct IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
       TYPE typ_tab_craplct2 IS TABLE OF typ_reg_craplct INDEX BY PLS_INTEGER;


       vr_tab_vlmoefix typ_tab_vlmoefix:= typ_tab_vlmoefix(0,0,0);
       vr_tab_vlcmdmes typ_tab_vlmoefix:= typ_tab_vlmoefix(0,0,0);
       vr_tab_vlcapmes typ_tab_vlcapmes:= typ_tab_vlcapmes(0,0,0,0,0,0,0,0,0,0,0,0);
       vr_tb1_vlmoefix typ_tab_crapmfx;
       vr_tb2_vlmoefix typ_tab_crapmfx;
       vr_tb3_vlmoefix typ_tab_crapmfx;
       vr_tab_crapcot  typ_tab_crapcot;

       --Definicao das tabelas de memoria
       vr_tab_craphis typ_tab_craphis;
       vr_tab_craplct typ_tab_crapmfx;
       vr_tab_craplct2 typ_tab_craplct2;

       --Cursores da rotina crps032

       -- Selecionar os dados da Cooperativa
       CURSOR cr_crapcop (pr_cdcooper IN craptab.cdcooper%TYPE) IS
         SELECT cop.cdcooper
               ,cop.nmrescop
               ,cop.nrtelura
               ,cop.cdbcoctl
               ,cop.cdagectl
               ,cop.dsdircop
               ,cop.nrctactl
         FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
       rw_crapcop cr_crapcop%ROWTYPE;
       --Registro do tipo calendario
       rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

       --Selecionar informacoes dos historicos
       CURSOR cr_craphis (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
         SELECT craphis.cdhistor
               ,craphis.inhistor
         FROM craphis craphis
         WHERE craphis.cdcooper = pr_cdcooper
         AND   craphis.tplotmov IN (0,2,3);

       --Selecionar inforamcoes das moedas fixas
       CURSOR cr_crapmfx (pr_cdcooper IN crapcop.cdcooper%TYPE
                         ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                         ,pr_dtmvtopr IN crapdat.dtmvtolt%TYPE) IS
         SELECT crapmfx.vlmoefix
               ,crapmfx.dtmvtolt
         FROM crapmfx crapmfx
         WHERE crapmfx.cdcooper  = pr_cdcooper
         AND   crapmfx.dtmvtolt  >= pr_dtmvtolt
         AND   crapmfx.dtmvtolt  <= pr_dtmvtopr
         AND   crapmfx.tpmoefix  = 12;

       --Selecionar informacoes dos lotes
       CURSOR cr_craplot (pr_cdcooper IN crapcop.cdcooper%TYPE
                         ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                         ,pr_cdagenci IN craplot.cdagenci%TYPE
                         ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                         ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
         SELECT craplot.dtmvtolt
               ,craplot.cdagenci
               ,craplot.cdbccxlt
               ,craplot.nrdolote
               ,craplot.tplotmov
               ,craplot.cdcooper
               ,craplot.nrseqdig
               ,craplot.qtinfoln
               ,craplot.qtcompln
               ,craplot.vlinfocr
               ,craplot.vlcompcr
               ,craplot.ROWID
         FROM  craplot craplot
         WHERE craplot.cdcooper = pr_cdcooper
         AND   craplot.dtmvtolt = pr_dtmvtolt
         AND   craplot.cdagenci = pr_cdagenci
         AND   craplot.cdbccxlt = pr_cdbccxlt
         AND   craplot.nrdolote = pr_nrdolote;
       rw_craplot cr_craplot%ROWTYPE;

       --Selecionar informacoes das cotas dos associados
       CURSOR cr_crapcot (pr_cdcooper IN crapcot.cdcooper%TYPE) IS
         SELECT  crapcot.nrdconta
                ,crapcot.vldcotas
                ,crapcot.vlcapfdm
                ,crapcot.qtcotmfx
                ,crapcot.vlcmmcot
                ,crapcot.qtantmfx
                ,crapcot.vlcapmes##1
                ,crapcot.vlcapmes##2
                ,crapcot.vlcapmes##3
                ,crapcot.vlcapmes##4
                ,crapcot.vlcapmes##5
                ,crapcot.vlcapmes##6
                ,crapcot.vlcapmes##7
                ,crapcot.vlcapmes##8
                ,crapcot.vlcapmes##9
                ,crapcot.vlcapmes##10
                ,crapcot.vlcapmes##11
                ,crapcot.vlcapmes##12
                ,crapcot.rowid
         FROM  crapcot crapcot
         WHERE crapcot.cdcooper = pr_cdcooper;
       rw_crapcot cr_crapcot%ROWTYPE;

       --Selecionar as contas com lancamento no periodo
       CURSOR cr_craplct_conta (pr_cdcooper  IN craplct.cdcooper%TYPE
                               ,pr_dtinicial IN craplct.dtmvtolt%TYPE
                               ,pr_dtfinal   IN craplct.dtmvtolt%TYPE) IS
         SELECT craplct.nrdconta
         FROM  craplct craplct
         WHERE craplct.cdcooper = pr_cdcooper
         AND   craplct.dtmvtolt > pr_dtinicial
         AND   craplct.dtmvtolt < pr_dtfinal;

       --Selecionar informacoes dos lancamentos de cotas
       CURSOR cr_craplct (pr_cdcooper IN craplct.cdcooper%TYPE
                         ,pr_nrdconta IN craplct.nrdconta%TYPE
                         ,pr_dtliminf IN craplct.dtmvtolt%TYPE
                         ,pr_dtlimsup IN craplct.dtmvtolt%TYPE) IS
           SELECT craplct.vllanmto
                 ,craplct.cdhistor
                 ,craplct.qtlanmfx
                 ,craplct.dtmvtolt
                 ,craplct.nrdconta
                 ,craplct.ROWID
           FROM   craplct craplct
           WHERE  craplct.cdcooper = pr_cdcooper
           AND    craplct.nrdconta = pr_nrdconta
           AND    craplct.dtmvtolt > pr_dtliminf
           AND    craplct.dtmvtolt < pr_dtlimsup;
         rw_craplct cr_craplct%ROWTYPE;


       --Variaveis Locais

       vr_des_erro       VARCHAR2(4000);
       vr_compl_erro     VARCHAR2(4000);
       vr_cdprogra       VARCHAR2(10);
       vr_diataxa        INTEGER;
       vr_qtdiaute       INTEGER;
       vr_cdcritic       INTEGER;
       vr_nummes         INTEGER;
       vr_flgtrime       BOOLEAN;
       vr_dtprimes       DATE;
       vr_dtsegmes       DATE;
       vr_dttermes       DATE;
       vr_dtmvtolt       DATE;
       vr_dtmvtopr       DATE;
       vr_dtmvtoan       DATE;
       vr_dtultdia       DATE;
       vr_dtfalhou       DATE;

       --Constantes Utilizadas na craplot
       vr_cdagenci CONSTANT INTEGER:= 1;
       vr_cdbccxlt CONSTANT INTEGER:= 100;
       vr_nrdolote CONSTANT INTEGER:= 8003;
       vr_tplotmov CONSTANT INTEGER:= 2;

       --Variavel usada para montar o indice da tabela de memoria
       vr_index_crapcot  INTEGER:= 0;
       vr_index_craplct  INTEGER:= 0;

       --Variaveis de Excecao
       vr_exc_fimprg EXCEPTION;
       vr_exc_saida  EXCEPTION;
       vr_exc_pula   EXCEPTION;

       --Procedure para limpar os dados das tabelas de memoria
       PROCEDURE pc_limpa_tabela IS
       BEGIN
         vr_tab_craphis.DELETE;
         vr_tb1_vlmoefix.DELETE;
         vr_tb2_vlmoefix.DELETE;
         vr_tb3_vlmoefix.DELETE;
         vr_tab_craplct.DELETE;
         vr_tab_crapcot.DELETE;
         vr_tab_craplct2.DELETE;
       EXCEPTION
         WHEN OTHERS THEN
           --Variavel de erro recebe erro ocorrido
           vr_des_erro:= 'Erro ao limpar tabelas de memória. Rotina pc_crps032.pc_limpa_tabela. '||sqlerrm;
           --Sair do programa
           RAISE vr_exc_saida;
       END;

       --Procedure para calcular Correcao Monetária Trimestral
       PROCEDURE pc_calc_cm_trimestral (pr_nrdconta IN crapcot.nrdconta%TYPE
                                       ,pr_qtantmfx IN crapcot.qtantmfx%TYPE
                                       ,pr_qtcotmfx IN OUT crapcot.qtcotmfx%TYPE
                                       ,pr_des_erro OUT varchar2) IS

         vr_qtcotmfx NUMBER(30,4):= 0;
         vr_qtlanmfx NUMBER;
         vr_vlcaptal NUMBER:= 0;
         vr_vlmoefix NUMBER(30,6):= 0;
         vr_vlcmmcot NUMBER:= 0;
         vr_nrmescal INTEGER:= 0;
         vr_cdhistor INTEGER:= 0;
         vr_dtliminf DATE;
         vr_dtlimsup DATE;
         vr_dtusada  DATE;
         rw_craplct  cr_craplct%ROWTYPE;

       BEGIN

         --Inicializar variavel erro
         pr_des_erro:= NULL;

         --Quantidade cotas recebe quantidade anterior ou cotas
         IF To_Number(To_Char(vr_dtmvtolt,'MM')) = 3 THEN
           vr_qtcotmfx:= Nvl(pr_qtantmfx,0);
         ELSE
           vr_qtcotmfx:= Nvl(pr_qtcotmfx,0);
         END IF;

         --Percorrer os 3 meses
         FOR idx IN 1..3 LOOP

           CASE idx
             WHEN  1 THEN
               --Limite inferior recebe ultimo dia mes anterior
               vr_dtliminf:= Last_Day(Add_Months(vr_dtprimes,-1));
               --Limite superior recebe dia segundo mes
               vr_dtlimsup:= vr_dtsegmes;
               --Numero do mes calculado recebe mes do primeiro mes
               vr_nrmescal:= To_Number(To_Char(vr_dtprimes,'MM'));
               --Valor capital recebe o valor do capital no mes calculado
               vr_vlcaptal:= vr_tab_vlcapmes(vr_nrmescal);
             WHEN 2 THEN
               --Limite inferior recebe ultimo dia mes anterior
               vr_dtliminf:= Last_Day(Add_Months(vr_dtsegmes,-1));
               --Limite superior recebe dia terceiro mes
               vr_dtlimsup:= vr_dttermes;
               --Numero do mes calculado recebe mes do primeiro mes
               vr_nrmescal:= To_Number(To_Char(vr_dtsegmes,'MM'));
               --Valor capital recebe o valor do capital no mes calculado
               vr_vlcaptal:= vr_tab_vlcapmes(vr_nrmescal);
             WHEN 3 THEN
               --Limite inferior recebe ultimo dia mes anterior
               vr_dtliminf:= Last_Day(Add_Months(vr_dttermes,-1));
               --Limite superior recebe dia segundo mes
               vr_dtlimsup:= vr_dtmvtopr;
               --Numero do mes calculado recebe mes do primeiro mes
               vr_nrmescal:= To_Number(To_Char(vr_dttermes,'MM'));
               --Valor capital recebe o valor do capital no mes calculado
               vr_vlcaptal:= vr_tab_vlcapmes(vr_nrmescal);
           END CASE;

           IF vr_tab_craplct.EXISTS(pr_nrdconta) THEN

             --Percorrer os lancamentos de cotas da conta
             FOR rw_craplct IN cr_craplct (pr_cdcooper => pr_cdcooper
                                          ,pr_nrdconta => pr_nrdconta
                                          ,pr_dtliminf => vr_dtliminf
                                          ,pr_dtlimsup => vr_dtlimsup) LOOP

                 --Atribuir o dia da taxa
                 vr_diataxa:= To_Number(To_Char(rw_craplct.dtmvtolt,'DD'));

                 --Atribuir valor moeda de acordo com o mes
                 CASE idx
                   WHEN 1 THEN
                     vr_vlmoefix:= vr_tb1_vlmoefix(vr_diataxa);
                   WHEN 2 THEN
                     vr_vlmoefix:= vr_tb2_vlmoefix(vr_diataxa);
                   WHEN 3 THEN
                     vr_vlmoefix:= vr_tb3_vlmoefix(vr_diataxa);
                 END CASE;

                 --Calcular quantidade em moeda fixa
                 vr_qtlanmfx:= TRUNC(rw_craplct.vllanmto / vr_vlmoefix,4);

                 --Incrementar Indice para inserir na tabela
                 vr_index_craplct:= Nvl(vr_index_craplct,0) + 1;
                 --Atualizar inforamcoes da tabela
                 vr_tab_craplct2(vr_index_craplct).vr_rowid:= rw_craplct.ROWID;
                 vr_tab_craplct2(vr_index_craplct).qtlanmfx:= vr_qtlanmfx;

                 --Verificar se o historico existe
                 IF vr_tab_craphis.EXISTS(rw_craplct.cdhistor) THEN
                   IF vr_tab_craphis(rw_craplct.cdhistor) = 6 THEN
                     --Somar quantidade cotas
                     vr_qtcotmfx:= Nvl(vr_qtcotmfx,0) + Nvl(vr_qtlanmfx,0);
                   ELSIF vr_tab_craphis(rw_craplct.cdhistor) = 16 THEN
                     --Diminuir quantidade cotas
                     vr_qtcotmfx:= Nvl(vr_qtcotmfx,0) - Nvl(vr_qtlanmfx,0);
                   END IF;
                 END IF;
             END LOOP; --while
           END IF;

           --Atribuir zero para correcao monetaria
           vr_vlcmmcot:= 0;  /*** Magui nao existe C.M. ***/
           --Atribuir zero para C.M no trimestre
           vr_tab_vlcmdmes(idx):= vr_vlcmmcot;
         END LOOP; --1..3

         --Se a quantidade de cotas for negativa
         IF vr_qtcotmfx < 0 THEN
           vr_qtcotmfx:= 0;
         END IF;

         --Atualizar saldo cotas via parametro retorno
         pr_qtcotmfx:= vr_qtcotmfx;

         /*  Gera os lancamentos de C.M. para cada mes do trimestre  */
         FOR idx IN 1..3 LOOP
           --Ignorar se C.M do trimestre for zero
           IF vr_tab_vlcmdmes(idx) <> 0 THEN

             --Selecionar a capa do lote
             OPEN cr_craplot (pr_cdcooper => pr_cdcooper
                             ,pr_dtmvtolt => vr_dtmvtolt
                             ,pr_cdagenci => vr_cdagenci
                             ,pr_cdbccxlt => vr_cdbccxlt
                             ,pr_nrdolote => vr_nrdolote);
             --Posicionar no primeiro registro
             FETCH cr_craplot INTO rw_craplot;
             --Se nao encontrou o lote
             IF cr_craplot%NOTFOUND THEN
               --Inserir lote
               BEGIN
                 INSERT INTO craplot (craplot.dtmvtolt
                                     ,craplot.cdagenci
                                     ,craplot.cdbccxlt
                                     ,craplot.nrdolote
                                     ,craplot.tplotmov
                                     ,craplot.cdcooper
                                     ,craplot.nrseqdig
                                     ,craplot.qtinfoln
                                     ,craplot.qtcompln
                                     ,craplot.vlinfocr
                                     ,craplot.vlcompcr )
                 VALUES              (vr_dtmvtolt
                                     ,vr_cdagenci
                                     ,vr_cdbccxlt
                                     ,vr_nrdolote
                                     ,vr_tplotmov
                                     ,pr_cdcooper
                                     ,0,0,0,0,0)
                 RETURNING craplot.dtmvtolt
                          ,craplot.cdagenci
                          ,craplot.cdbccxlt
                          ,craplot.nrdolote
                          ,craplot.tplotmov
                          ,craplot.cdcooper
                          ,craplot.nrseqdig
                          ,craplot.qtinfoln
                          ,craplot.qtcompln
                          ,craplot.vlinfocr
                          ,craplot.vlcompcr
                          ,craplot.rowid
                 INTO     rw_craplot.dtmvtolt
                          ,rw_craplot.cdagenci
                          ,rw_craplot.cdbccxlt
                          ,rw_craplot.nrdolote
                          ,rw_craplot.tplotmov
                          ,rw_craplot.cdcooper
                          ,rw_craplot.nrseqdig
                          ,rw_craplot.qtinfoln
                          ,rw_craplot.qtcompln
                          ,rw_craplot.vlinfocr
                          ,rw_craplot.vlcompcr
                          ,rw_craplot.rowid;
               EXCEPTION
                 WHEN OTHERS THEN
                   vr_des_erro:= 'Erro ao inserir na tabela craplot. '||SQLERRM;
                   RAISE vr_exc_saida;
               END;
             END IF;

             --Determinar o historico
             CASE idx
               WHEN 1 THEN vr_cdhistor:= 65;
               WHEN 2 THEN vr_cdhistor:= 70;
               WHEN 3 THEN vr_cdhistor:= 71;
             END CASE;

             --Inserir tabela lancamento cotas
             BEGIN
               INSERT INTO craplct (craplct.dtmvtolt
                                   ,craplct.cdagenci
                                   ,craplct.cdbccxlt
                                   ,craplct.nrdolote
                                   ,craplct.nrdconta
                                   ,craplct.nrdocmto
                                   ,craplct.vllanmto
                                   ,craplct.cdhistor
                                   ,craplct.nrseqdig
                                   ,craplct.cdcooper)
               VALUES              (rw_craplot.dtmvtolt
                                   ,rw_craplot.cdagenci
                                   ,rw_craplot.cdbccxlt
                                   ,rw_craplot.nrdolote
                                   ,pr_nrdconta
                                   ,Nvl(rw_craplot.nrseqdig,0) + 1
                                   ,vr_tab_vlcmdmes(idx)
                                   ,vr_cdhistor
                                   ,Nvl(rw_craplot.nrseqdig,0) + 1
                                   ,pr_cdcooper)
               RETURNING           craplct.vllanmto
               INTO                rw_craplct.vllanmto;
             EXCEPTION
               WHEN OTHERS THEN
                 vr_des_erro:= 'Erro ao atualizar tabela craplot. '||SQLERRM;
                 RAISE vr_exc_saida;
             END;

             --Atualizar lote
             BEGIN
               UPDATE craplot SET craplot.nrseqdig = rw_craplot.nrseqdig + 1
                                 ,craplot.qtinfoln = rw_craplot.qtinfoln + 1
                                 ,craplot.qtcompln = rw_craplot.qtcompln + 1
                                 ,craplot.vlinfocr = rw_craplot.vlinfocr + rw_craplct.vllanmto
                                 ,craplot.vlcompcr = rw_craplot.vlcompcr + rw_craplct.vllanmto
               WHERE craplot.ROWID = rw_craplot.ROWID;
             EXCEPTION
               WHEN OTHERS THEN
                 vr_des_erro:= 'Erro ao atualizar tabela craplot. '||SQLERRM;
                 RAISE vr_exc_saida;
             END;

           END IF;
         END LOOP;

       EXCEPTION
         WHEN OTHERS THEN
           --Variavel de erro recebe erro ocorrido
           vr_des_erro:= 'Erro ao calcular C.M. Trimestral. Rotina pc_crps032.pc_calc_trimestral_cm. '||sqlerrm;
           --Sair do programa
           RAISE vr_exc_saida;
       END;

     ---------------------------------------
     -- Inicio Bloco Principal pc_crps032
     ---------------------------------------
     BEGIN

       --Atribuir o nome do programa que está executando
       vr_cdprogra:= 'CRPS032';

       -- Incluir nome do módulo logado
       GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS032'
                                 ,pr_action => NULL);

       -- Verifica se a cooperativa esta cadastrada
       OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
       FETCH cr_crapcop INTO rw_crapcop;
       -- Se não encontrar
       IF cr_crapcop%NOTFOUND THEN
         -- Fechar o cursor pois haverá raise
         CLOSE cr_crapcop;
         -- Montar mensagem de critica
         vr_des_erro := gene0001.fn_busca_critica(pr_cdcritic => 651);
         RAISE vr_exc_saida;
       ELSE
         -- Apenas fechar o cursor
         CLOSE cr_crapcop;
       END IF;

       -- Verifica se a cooperativa esta cadastrada
       OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
       FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
       -- Se não encontrar
       IF BTCH0001.cr_crapdat%NOTFOUND THEN
         -- Fechar o cursor pois haverá raise
         CLOSE BTCH0001.cr_crapdat;
         -- Montar mensagem de critica
         vr_des_erro := gene0001.fn_busca_critica(pr_cdcritic => 1);
         RAISE vr_exc_saida;
       ELSE
         -- Apenas fechar o cursor
         CLOSE BTCH0001.cr_crapdat;
         --Atribuir a data do movimento
         vr_dtmvtolt:= rw_crapdat.dtmvtolt;
         --Atribuir a proxima data do movimento
         vr_dtmvtopr:= rw_crapdat.dtmvtopr;
         --Atribuir a data do movimento anterior
         vr_dtmvtoan:= rw_crapdat.dtmvtoan;
         --Atribuir a quantidade de dias uteis
         vr_qtdiaute:= rw_crapdat.qtdiaute;
         --Ultimo dia do mes anterior
         vr_dtultdia:= rw_crapdat.dtultdma;
       END IF;

       -- Validações iniciais do programa
       BTCH0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                                 ,pr_flgbatch => 1
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_cdcritic => vr_cdcritic);
       --Se retornou critica aborta programa
       IF vr_cdcritic <> 0 THEN
         --Sair do programa
         RAISE vr_exc_saida;
       END IF;

       --Zerar tabelas de memoria auxiliar
       pc_limpa_tabela;

       --Determinar o numero do mes com base na data do movimento
       vr_nummes:= To_Number(To_Char(vr_dtmvtolt,'MM'));

       --Se for marco, junho, setembro ou dezembro
       IF vr_nummes IN (3,6,9,12) THEN

         --Carregar tabela de memoria de historicos
         FOR rw_craphis IN cr_craphis (pr_cdcooper => pr_cdcooper) LOOP
           vr_tab_craphis(rw_craphis.cdhistor):= rw_craphis.inhistor;
         END LOOP;

         --Atribuir true para flag trimestre
         vr_flgtrime:= TRUE;

         /*  Monta as datas limites  */
         CASE vr_nummes
           WHEN 3 THEN
             vr_dtprimes:= TO_DATE('0101'||To_Char(vr_dtmvtolt,'YYYY'),'DDMMYYYY');
             vr_dtsegmes:= TO_DATE('0102'||To_Char(vr_dtmvtolt,'YYYY'),'DDMMYYYY');
             vr_dttermes:= TO_DATE('0103'||To_Char(vr_dtmvtolt,'YYYY'),'DDMMYYYY');
           WHEN 6 THEN
             vr_dtprimes:= TO_DATE('0104'||To_Char(vr_dtmvtolt,'YYYY'),'DDMMYYYY');
             vr_dtsegmes:= TO_DATE('0105'||To_Char(vr_dtmvtolt,'YYYY'),'DDMMYYYY');
             vr_dttermes:= TO_DATE('0106'||To_Char(vr_dtmvtolt,'YYYY'),'DDMMYYYY');
           WHEN 9 THEN
             vr_dtprimes:= TO_DATE('0107'||To_Char(vr_dtmvtolt,'YYYY'),'DDMMYYYY');
             vr_dtsegmes:= TO_DATE('0108'||To_Char(vr_dtmvtolt,'YYYY'),'DDMMYYYY');
             vr_dttermes:= TO_DATE('0109'||To_Char(vr_dtmvtolt,'YYYY'),'DDMMYYYY');
           WHEN 12 THEN
             vr_dtprimes:= TO_DATE('0110'||To_Char(vr_dtmvtolt,'YYYY'),'DDMMYYYY');
             vr_dtsegmes:= TO_DATE('0111'||To_Char(vr_dtmvtolt,'YYYY'),'DDMMYYYY');
             vr_dttermes:= TO_DATE('0112'||To_Char(vr_dtmvtolt,'YYYY'),'DDMMYYYY');
         END CASE;


         /*  Encontrar o primeiro dia util de cada mes  */

         vr_dtprimes:= gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper   --> Cooperativa conectada
                                                  ,pr_dtmvtolt => vr_dtprimes   --> Data Movimento
                                                  ,pr_tipo     => 'P');         --> Tipo de busca (P = próximo, A = anterior)
         vr_dtsegmes:= gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper   --> Cooperativa conectada
                                                  ,pr_dtmvtolt => vr_dtsegmes   --> Data Movimento
                                                  ,pr_tipo     => 'P');         --> Tipo de busca (P = próximo, A = anterior)
         vr_dttermes:= gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper   --> Cooperativa conectada
                                                  ,pr_dtmvtolt => vr_dttermes   --> Data Movimento
                                                  ,pr_tipo     => 'P');         --> Tipo de busca (P = próximo, A = anterior)

         --Carregar tabela de memoria de contas com lancamentos em cotas
         FOR rw_craplct IN cr_craplct_conta (pr_cdcooper  => pr_cdcooper
                                            ,pr_dtinicial => vr_dtmvtopr - 120
                                            ,pr_dtfinal   => vr_dtmvtopr) LOOP
           vr_tab_craplct(rw_craplct.nrdconta):= 0;
         END LOOP;

         /*  Carrega tabelas das moedas fixas utilizadas no trimestre  */
         FOR rw_crapmfx IN cr_crapmfx (pr_cdcooper => pr_cdcooper
                                      ,pr_dtmvtolt => Last_Day(Add_Months(vr_dtprimes,-1))
                                      ,pr_dtmvtopr => vr_dtmvtopr) LOOP
           --Atribuir o dia da taxa
           vr_diataxa:= To_Number(To_Char(rw_crapmfx.dtmvtolt,'DD'));

           --Se o mes da taxa for o mesmo do movimento
           CASE To_Number(To_Char(rw_crapmfx.dtmvtolt,'MM'))
             WHEN  To_Number(To_Char(vr_dtprimes,'MM')) THEN
               vr_tb1_vlmoefix(vr_diataxa):= rw_crapmfx.vlmoefix;
             WHEN To_Number(To_Char(vr_dtsegmes,'MM')) THEN
               vr_tb2_vlmoefix(vr_diataxa):= rw_crapmfx.vlmoefix;
             WHEN To_Number(To_Char(vr_dttermes,'MM')) THEN
               vr_tb3_vlmoefix(vr_diataxa):= rw_crapmfx.vlmoefix;
             ELSE NULL;
           END CASE;

           --Determinar valor moeda para a primeira data
           IF rw_crapmfx.dtmvtolt = vr_dtsegmes THEN
             vr_tab_vlmoefix(1):= rw_crapmfx.vlmoefix;
           END IF;
           --Determinar valor moeda para a segunda data
           IF rw_crapmfx.dtmvtolt = vr_dttermes THEN
             vr_tab_vlmoefix(2):= rw_crapmfx.vlmoefix;
           END IF;
           --Determinar valor moeda para a terceira data
           IF rw_crapmfx.dtmvtolt = vr_dtmvtopr THEN
             vr_tab_vlmoefix(3):= rw_crapmfx.vlmoefix;
           END IF;
         END LOOP;  --rw_crapmfx


         --Se nao encontrou valor para alguma data principal
         IF vr_tab_vlmoefix(1) = 0 OR vr_tab_vlmoefix(2) = 0 OR vr_tab_vlmoefix(3) = 0 THEN
           IF vr_tab_vlmoefix(1) = 0 THEN
             --Atribuir a data com problema
             vr_dtfalhou:= vr_dtsegmes;
           ELSIF vr_tab_vlmoefix(2) = 0 THEN
             --Atribuir a data com problema
             vr_dtfalhou:= vr_dttermes;
           ELSIF vr_tab_vlmoefix(3) = 0 THEN
             --Atribuir a data com problema
             vr_dtfalhou:= vr_dtmvtopr;
           END IF;
           --Descricao do erro recebe mensagam da critica
           vr_des_erro := gene0001.fn_busca_critica(pr_cdcritic => 140);
           vr_compl_erro:= ' UFIR CM do dia '||To_Char(vr_dtfalhou,'DD/MM/YYYY');
           vr_des_erro := vr_des_erro || ' - '||vr_compl_erro;
           --Levantar Excecao
           RAISE vr_exc_saida;
         END IF;
       ELSE
         --Atribuir false para flag trimestre
         vr_flgtrime:= FALSE;
       END IF;

       /*  Leitura do capital do associado  */
       --Selecionar todas as cotas
       FOR rw_crapcot IN cr_crapcot (pr_cdcooper => pr_cdcooper) LOOP
         BEGIN
           --Se o valor das cotas for negativa
           IF rw_crapcot.vldcotas < 0 THEN
             --Montar mensagem de erro
             vr_des_erro:= ' A conta '||rw_crapcot.nrdconta||' de RS: '||rw_crapcot.vldcotas||' esta negativa.';
             btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                       ,pr_ind_tipo_log => 2 -- Erro tratato
                                       ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                       ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                           || vr_cdprogra || ' --> '
                                                           || vr_des_erro);
             --Pular para proximo registro
             RAISE vr_exc_pula;
           END IF;

           --Limpar vetor de valor de capital por mes
           FOR idx IN 1..12 LOOP

             CASE idx
               WHEN 1 THEN vr_tab_vlcapmes(idx):= rw_crapcot.vlcapmes##1;
               WHEN 2 THEN vr_tab_vlcapmes(idx):= rw_crapcot.vlcapmes##2;
               WHEN 3 THEN vr_tab_vlcapmes(idx):= rw_crapcot.vlcapmes##3;
               WHEN 4 THEN vr_tab_vlcapmes(idx):= rw_crapcot.vlcapmes##4;
               WHEN 5 THEN vr_tab_vlcapmes(idx):= rw_crapcot.vlcapmes##5;
               WHEN 6 THEN vr_tab_vlcapmes(idx):= rw_crapcot.vlcapmes##6;
               WHEN 7 THEN vr_tab_vlcapmes(idx):= rw_crapcot.vlcapmes##7;
               WHEN 8 THEN vr_tab_vlcapmes(idx):= rw_crapcot.vlcapmes##8;
               WHEN 9 THEN vr_tab_vlcapmes(idx):= rw_crapcot.vlcapmes##9;
               WHEN 10 THEN vr_tab_vlcapmes(idx):= rw_crapcot.vlcapmes##10;
               WHEN 11 THEN vr_tab_vlcapmes(idx):= rw_crapcot.vlcapmes##11;
               WHEN 12 THEN vr_tab_vlcapmes(idx):= rw_crapcot.vlcapmes##12;
             END CASE;
             --Se for trimestre
             IF idx = to_Number(To_Char(vr_dtmvtolt,'MM')) THEN
               vr_tab_vlcapmes(idx):= rw_crapcot.vldcotas;
             END IF;
           END LOOP;


           --Valor do capital recebe valor das cotas
           rw_crapcot.vlcapfdm:= rw_crapcot.vldcotas;
           --Zerar valor correcao monetaria das cotas
           rw_crapcot.vlcmmcot:= 0;

           --Se a quantidade de cotas em moeda fixa for negativa
           IF rw_crapcot.qtcotmfx < 0 THEN
             --Zerar quantidade cotas em moeda fixa
             rw_crapcot.qtcotmfx:= 0;
           END IF;

           --Se for trimestre
           IF vr_flgtrime THEN
             /*  Rotina de calculo da C.M. { includes/crps032.i } */
             pc_calc_cm_trimestral (pr_nrdconta => rw_crapcot.nrdconta
                                   ,pr_qtantmfx => rw_crapcot.qtantmfx
                                   ,pr_qtcotmfx => rw_crapcot.qtcotmfx
                                   ,pr_des_erro => vr_des_erro);
             --Se ocorreu erro
             IF vr_des_erro IS NOT NULL THEN
               --Levantar Excecao
               RAISE vr_exc_saida;
             END IF;
           END IF;

           --Atualizar tabela cotas
           vr_index_crapcot:= Nvl(vr_index_crapcot,0) + 1;
           vr_tab_crapcot(vr_index_crapcot).nrdconta := rw_crapcot.nrdconta;
           vr_tab_crapcot(vr_index_crapcot).vlcapfdm:= rw_crapcot.vlcapfdm;
           vr_tab_crapcot(vr_index_crapcot).vlcmmcot:= rw_crapcot.vlcmmcot;
           vr_tab_crapcot(vr_index_crapcot).qtcotmfx:= rw_crapcot.qtcotmfx;
           vr_tab_crapcot(vr_index_crapcot).vlcmecot:= 0;
           vr_tab_crapcot(vr_index_crapcot).vlcapmes##1:=  vr_tab_vlcapmes(1);
           vr_tab_crapcot(vr_index_crapcot).vlcapmes##2:=  vr_tab_vlcapmes(2);
           vr_tab_crapcot(vr_index_crapcot).vlcapmes##3:=  vr_tab_vlcapmes(3);
           vr_tab_crapcot(vr_index_crapcot).vlcapmes##4:=  vr_tab_vlcapmes(4);
           vr_tab_crapcot(vr_index_crapcot).vlcapmes##5:=  vr_tab_vlcapmes(5);
           vr_tab_crapcot(vr_index_crapcot).vlcapmes##6:=  vr_tab_vlcapmes(6);
           vr_tab_crapcot(vr_index_crapcot).vlcapmes##7:=  vr_tab_vlcapmes(7);
           vr_tab_crapcot(vr_index_crapcot).vlcapmes##8:=  vr_tab_vlcapmes(8);
           vr_tab_crapcot(vr_index_crapcot).vlcapmes##9:=  vr_tab_vlcapmes(9);
           vr_tab_crapcot(vr_index_crapcot).vlcapmes##10:= vr_tab_vlcapmes(10);
           vr_tab_crapcot(vr_index_crapcot).vlcapmes##11:= vr_tab_vlcapmes(11);
           vr_tab_crapcot(vr_index_crapcot).vlcapmes##12:= vr_tab_vlcapmes(12);

         EXCEPTION
           WHEN vr_exc_pula THEN
             NULL;
           WHEN vr_exc_saida THEN
             RAISE vr_exc_saida;
           WHEN OTHERS THEN
             vr_des_erro:= 'Erro ao processar cotas na rotina crps032. '||SQLERRM;
         END;
       END LOOP;

       BEGIN
         --Atualizar tabela cotas
         FORALL idx IN vr_tab_crapcot.FIRST..vr_tab_crapcot.LAST SAVE EXCEPTIONS
           UPDATE crapcot SET  vlcapfdm = vr_tab_crapcot(idx).vlcapfdm
                              ,vlcmmcot = vr_tab_crapcot(idx).vlcmmcot
                              ,qtcotmfx = vr_tab_crapcot(idx).qtcotmfx
                              ,vlcmecot = vr_tab_crapcot(idx).vlcmecot
                              ,vlcapmes##1 = vr_tab_crapcot(idx).vlcapmes##1
                              ,vlcapmes##2 = vr_tab_crapcot(idx).vlcapmes##2
                              ,vlcapmes##3 = vr_tab_crapcot(idx).vlcapmes##3
                              ,vlcapmes##4 = vr_tab_crapcot(idx).vlcapmes##4
                              ,vlcapmes##5 = vr_tab_crapcot(idx).vlcapmes##5
                              ,vlcapmes##6 = vr_tab_crapcot(idx).vlcapmes##6
                              ,vlcapmes##7 = vr_tab_crapcot(idx).vlcapmes##7
                              ,vlcapmes##8 = vr_tab_crapcot(idx).vlcapmes##8
                              ,vlcapmes##9 = vr_tab_crapcot(idx).vlcapmes##9
                              ,vlcapmes##10 = vr_tab_crapcot(idx).vlcapmes##10
                              ,vlcapmes##11 = vr_tab_crapcot(idx).vlcapmes##11
                              ,vlcapmes##12 = vr_tab_crapcot(idx).vlcapmes##12
           WHERE crapcot.cdcooper = pr_cdcooper
           AND   crapcot.nrdconta = vr_tab_crapcot(idx).nrdconta;
       EXCEPTION
         WHEN OTHERS THEN
           -- Gerar erro
           vr_des_erro := 'Erro ao inserir na tabela crapsda. '||
                          SQLERRM(-(SQL%BULK_EXCEPTIONS(1).ERROR_CODE));
           RAISE vr_exc_saida;
       END;


       BEGIN
         --Atualizar tabela lancamentos das cotas
         FORALL idx IN vr_tab_craplct2.FIRST..vr_tab_craplct2.LAST SAVE EXCEPTIONS
           UPDATE craplct SET craplct.qtlanmfx = vr_tab_craplct2(idx).qtlanmfx
           WHERE craplct.ROWID = vr_tab_craplct2(idx).vr_rowid;
       EXCEPTION
         WHEN OTHERS THEN
           -- Gerar erro
           vr_des_erro := 'Erro ao inserir na tabela crapsda. '||
                          SQLERRM(-(SQL%BULK_EXCEPTIONS(1).ERROR_CODE));
           RAISE vr_exc_saida;
       END;

       --Zerar tabelas de memoria auxiliar
       pc_limpa_tabela;

       -- Processo OK, devemos chamar a fimprg
       btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                ,pr_cdprogra => vr_cdprogra
                                ,pr_infimsol => pr_infimsol
                                ,pr_stprogra => pr_stprogra);
       --Salvar informacoes no banco de dados
       COMMIT;


     EXCEPTION
       WHEN vr_exc_fimprg THEN
         -- Se foi retornado apenas código
         IF vr_cdcritic > 0 AND vr_des_erro IS NULL THEN
           -- Buscar a descrição
           vr_des_erro := gene0001.fn_busca_critica(vr_cdcritic);
         END IF;
         -- Envio centralizado de log de erro
         btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                   ,pr_ind_tipo_log => 2 -- Erro tratato
                                   ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                    || vr_cdprogra || ' --> '
                                                    || vr_des_erro );
         -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
         btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                  ,pr_cdprogra => vr_cdprogra
                                  ,pr_infimsol => pr_infimsol
                                  ,pr_stprogra => pr_stprogra);
         -- Efetuar commit
         COMMIT;
       WHEN vr_exc_saida THEN
         -- Se foi retornado apenas código
         IF vr_cdcritic > 0 AND vr_des_erro IS NULL THEN
           -- Buscar a descrição
           vr_des_erro := gene0001.fn_busca_critica(vr_cdcritic);
         END IF;
         -- Devolvemos código e critica encontradas
         pr_cdcritic := NVL(vr_cdcritic,0);
         pr_dscritic := vr_des_erro;
         -- Efetuar rollback
         ROLLBACK;
       WHEN OTHERS THEN
         -- Efetuar retorno do erro não tratado
         pr_cdcritic := 0;
         pr_dscritic := sqlerrm;
         -- Efetuar rollback
         ROLLBACK;
     END;
   END pc_crps032;
/

