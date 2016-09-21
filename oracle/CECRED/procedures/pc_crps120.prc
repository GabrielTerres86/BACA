CREATE OR REPLACE PROCEDURE CECRED.pc_crps120 (pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Cooperativa solicitada
                                              ,pr_cdoperad  IN crapope.cdoperad%type  --> Código do operador
                                              ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                              ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                              ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                              ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps120 (Fontes/crps120.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Deborah/Edson
       Data    : Junho/95.                     Ultima atualizacao: 23/05/2016

       Dados referentes ao programa:

       Frequencia: Diario (Batch).
       Objetivo  : Atender a solicitacao 062.
                   Processar as integracoes de credito de pagamento e efetuar os
                   debitos de cotas e emprestimos.
                   Emite relatorio 98, 99 e 114.

       Alteracoes: 17/11/95 - Alterado para tratar debito do convenio de DENTISTAS
                              para a CEVAL JARAGUA DO SUL (Edson).

                   18/11/96 - Alterado para marcar o indicador de integracao de
                              folha de pagto com feito (Edson).

                   12/02/97 - Tratar CPMF (Odair).

                   21/02/97 - Tratar convenio saude Bradesco (Odair).

                   21/05/97 - Alterado para tratar demais convenios (Edson).

                   05/06/97 - Criar tabela para descontar emprestimos e capital apos
                              a ultima folha da empresa (Odair).

                   25/06/97 - Alterado para eliminar a leitura da tabela de histori-
                              cos de dentistas (Deborah).

                   10/07/97 - Tratar historicos de saude bradesco cnv 14 (Odair)

                   13/11/97 - Tratar convenio 18 e 19 (Odair).

                   27/04/98 - Tratamento para milenio e troca para V8 (Margarete).

                   22/11/98 - Tratar atendimento noturno (Deborah).

                   26/02/99 - Tratar arquivos nao encontrados (Odair)

                 23/03/2003 - Incluir tratamento da Concredi (Margarete).

                 29/06/2005 - Alimentado campo cdcooper da tabela craptab (Diego).

                 16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

                 05/06/2006 - Criar crapfol zerado para quem tem aviso de debito de
                              emprestimo mas nao teve credito da folha (Julio)

                 30/08/2006 - Somente criar crapfol se for integracao de credito
                              de salario mensal (Julio)

                 20/12/2007 - Remover arquivo de folha para o salvar apenas apos
                              a solicitacao passar para status "processada" (Julio)

                 01/09/2008 - Alteracao CDEMPRES (Kbase).

                 01/10/2013 - Renomeado "aux_nmarqimp" (EXTENT) para "aux_nmarquiv",
                              pois aux_nmarqimp eh usado na impressao.i (Carlos)

                 25/10/2013 - Copia relatorio para o diretorio rlnsv (Carlos)

                 29/10/2013 - Incluida var aux_flarqden para saber se copia o
                              rel crrl114 para o dir rlnsv na sol062.p (Carlos)

                 16/12/2013 - Conversao Progress >> Oracle PLSQL (Odirlei-AMcom)
                 
                 30/05/2014 - Aumentado o tamanho da variavel vr_lshstden.
                              Inserido o update para atualizar cotas.
                              Tratamento para trocar TAB por espacos quando  
                              algum arquivo de integração vier diferente do padrao(espaço).
                              Zerar temp table de cotas a cada linha. (Tiago RKAM)
                              
                 06/06/2014 - Melhorias na estrutura do programa para que nas criticas
                              181,173,379 e de falta de arquivo, o processo na pare, mas
                              apenas critique no log e continue para o próximo arquivo
                              (Marcos-Supero)
                              
                 04/07/2014 - Melhoria para tratar o when-others para cada arquivo,
                              da forma atual, o processo está parando nestes casos
                              (Marcos-Supero)           
                              
                 06/08/2014 - Ajustes no calculo do proximo debito do plano de capital
                              quando a data atual eh vazia, usamos a data do processo
                              (Marcos-Supero)             

                 28/07/2015 - Separacao da procedure pc_debita_plano_capital 
                              do programa pc_crps120 para pc_crps120_2. (Jaison)

                 23/05/2016 - Ajuste para gravar tab EXECDEBEMP com crapemp.dtlimdeb caso
                              dia da dtintegr for anterior ao dia limite para debitos. 
                              (Jaison/Marcos - Supero)

    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS120';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);
      --Declarar e iniciar os  valores para usar as subrotinas
      vr_cdagenci   crapage.cdagenci%type := 1;
      vr_cdbccxlt   crapban.cdbccxlt%type := 100;
      vr_lshstden   VARCHAR2(500);

      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.nmextcop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Buscar as informações para restart e Rowid para atualização posterior
      CURSOR cr_crapres IS
        SELECT res.dsrestar
              ,res.rowid
          FROM crapres res
         WHERE res.cdcooper = pr_cdcooper
           AND res.cdprogra = vr_cdprogra;
      rw_crapres cr_crapres%ROWTYPE;

      /*  Historicos do convenio */
      CURSOR cr_crapcnv (pr_nrconven IN crapcnv.nrconven%type) IS
        SELECT lshistor
          FROM crapcnv
         WHERE crapcnv.cdcooper = pr_cdcooper
           AND crapcnv.nrconven = pr_nrconven;
      rw_crapcnv cr_crapcnv%rowtype;

      /*  Leitura das solicitacoes de integracao  */
      CURSOR cr_crapsol (pr_cdcooper crapsol.cdcooper%type,
                         pr_dtmvtolt crapsol.dtrefere%type) IS
        SELECT dsparame,
               nrdevias,
               cdempres,
               nrseqsol,
               rowid
          FROM crapsol
         WHERE crapsol.cdcooper = pr_cdcooper
           AND crapsol.dtrefere = pr_dtmvtolt
           AND crapsol.nrsolici = 62
           AND crapsol.insitsol = 1;

      -- Cadastro de empresas
      CURSOR cr_crapemp (pr_cdcooper crapemp.cdcooper%type,
                         pr_cdempres crapemp.cdempres%type)IS
        SELECT nmresemp,
               cdempfol,
               cdempres
              ,dtlimdeb
          FROM crapemp
         WHERE crapemp.cdcooper = pr_cdcooper
           AND crapemp.cdempres = pr_cdempres;
      rw_crapemp cr_crapemp%rowtype;

      -- Ler Cadastro dos avisos de debito em conta corrente.
      CURSOR cr_crapavs (pr_cdcooper crapavs.cdcooper%type,
                         pr_dtrefere crapavs.dtrefere%type) IS
        SELECT 1
          FROM crapavs
         WHERE crapavs.cdcooper = pr_cdcooper
           AND crapavs.dtrefere = pr_dtrefere
           AND crapavs.tpdaviso = 1
         ORDER BY crapavs.progress_recid desc;
      rw_crapavs cr_crapavs%rowtype;

      -- Ler Cadastro dos avisos de debito em conta corrente.
      CURSOR cr_crapavs2 (pr_cdcooper crapavs.cdcooper%type,
                          pr_cdempres crapavs.cdempres%type,
                          pr_dtrefere crapavs.dtrefere%type) IS
        SELECT nrdconta,
               cdempres,
               dtrefere
          FROM crapavs
         WHERE crapavs.cdcooper = pr_cdcooper
           AND crapavs.cdempres = pr_cdempres
           AND crapavs.dtrefere = pr_dtrefere
           AND crapavs.tpdaviso = 1
           AND crapavs.insitavs = 0
           AND crapavs.cdhistor = 108;

      -- Ler Cadastro de titulares da conta
      CURSOR cr_crapttl is
        SELECT cdempres,
               nrdconta,
               cdturnos
          FROM crapttl
         WHERE crapttl.cdcooper = pr_cdcooper
           AND crapttl.idseqttl = 1;

      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
      type typ_tab_reg_crapavs
                    is record(dtmvtolt crapavs.dtmvtolt%type,
                              nrdconta crapavs.nrdconta%type,
                              nrdocmto crapavs.nrdocmto%type,
                              vllanmto crapavs.vllanmto%type,
                              tpdaviso crapavs.tpdaviso%type,
                              cdhistor crapavs.cdhistor%type,
                              dtdebito crapavs.dtdebito%type,
                              cdsecext crapavs.cdsecext%type,
                              cdempres crapavs.cdempres%type,
                              nrseqdig crapavs.nrseqdig%type,
                              insitavs crapavs.insitavs%type,
                              dtrefere crapavs.dtrefere%type,
                              vldebito crapavs.vldebito%type,
                              vlestdif crapavs.vlestdif%type,
                              cdagenci crapavs.cdagenci%type,
                              vlestour crapavs.vlestour%type,
                              dtintegr crapavs.dtintegr%type,
                              cdempcnv crapavs.cdempcnv%type,
                              nrconven crapavs.nrconven%type,
                              flgproce crapavs.flgproce%type,
                              cdcooper crapavs.cdcooper%type,
                              nrparepr crapavs.nrparepr%type,
                              rowidavs rowid );

      type typ_tab_crapavs is table of typ_tab_reg_crapavs
                           index by varchar2(18); --idorderm(1)+his(5)+dtintegr(8)+cont(4)

      -- armazenar as empresas dos titulares
      type typ_tab_reg_crapttl
                    is record( cdempres crapttl.cdempres%type,
                               cdturnos crapttl.cdturnos%type);

      type typ_tab_crapttl is table of typ_tab_reg_crapttl
                           index by varchar2(10); --nrdconta
      vr_tab_crapttl typ_tab_crapttl;

      ------------------------------- VARIAVEIS -------------------------------

      -- Variáveis para controle de restart
      vr_nrctares crapass.nrdconta%TYPE;      --> Número da conta de restart
      vr_dsrestar VARCHAR2(4000);             --> String genérica com informações para restart
      vr_inrestar INTEGER;                    --> Indicador de Restart

      -- Variaveis de controle
      vr_qttarifa NUMBER := 0;
      vr_indmarca NUMBER := 0;
      vr_regexist BOOLEAN;
      vr_dtintegr DATE;
      vr_dstextab craptab.dstextab%type;
      vr_inusatab BOOLEAN;
      vr_flgfirst BOOLEAN;
      vr_flglotes BOOLEAN;
      vr_flgclote BOOLEAN;
      vr_flgestou BOOLEAN;
      vr_flgatual BOOLEAN;
      vr_flignore BOOLEAN;
      vr_dtexecde DATE;

      -- Variavel para armazenar o historio de convenio
      vr_lshstsau crapcnv.lshistor%type;
      vr_lshstdiv crapcnv.lshistor%type;
      vr_lshstfun crapcnv.lshistor%type;
      --Contador de arquivo
      vr_contador NUMBER:= 0;
      vr_cdempres crapsol.cdempres%TYPE;
      vr_nrdevias crapsol.nrdevias%TYPE;
      vr_cdempsol crapsol.cdempres%TYPE;

      --Controle de numero de lotes
      vr_nrlotfol NUMBER := 0;
      vr_nrlotcot NUMBER := 0;
      vr_nrlotemp NUMBER := 0;
      --Qtd de tarifas encontradas
      vr_rel_qttarifa NUMBER := 0;
      -- Nome do diretorio da cooperativa
      vr_nom_direto varchar2(500);
      --Sequencial de solicitação
      vr_nrseqsol VARCHAR2(4);

      --Arquivo a ser importado
      vr_nmarquiv VARCHAR2(500);
      --Nome dos relatorios a serem gerados
      vr_nmarqest VARCHAR2(500);
      vr_nmarqden VARCHAR2(500);
      vr_nmarqint VARCHAR2(500);

      vr_dtsegdeb DATE;
      vr_dtrefere DATE;
      vr_dsempres VARCHAR2(100);
      vr_cdempfol crapemp.cdempfol%type;

      -- Tipo de saída do comando Host
      vr_typ_said VARCHAR2(100);

      -- Type para armazenar totais de debito po conta
      type typ_tab_tot_vldebcta is table of number
                           index by varchar2(5); --cdhis(5)

      --------------------------- SUBROTINAS INTERNAS --------------------------

      --Buscar codigo da empresa da pessoa fisica ou juridica
      FUNCTION fn_trata_cdempres (pr_cdcooper IN crapcop.cdcooper%type,
                                  pr_inpessoa IN crapass.inpessoa%type,
                                  pr_nrdconta IN crapass.nrdconta%type)
                                   return NUMBER IS

        -- Ler Cadastro de pessoas juridicas.
        CURSOR cr_crapjur is
          SELECT cdempres
            FROM crapjur
           WHERE crapjur.cdcooper = pr_cdcooper
             AND crapjur.nrdconta = pr_nrdconta;
        rw_crapjur cr_crapjur%ROWTYPE;

      BEGIN
        -- Se for pessoa fisica
        IF pr_inpessoa = 1 THEN
          --verificar se o registro do titular existe
          IF vr_tab_crapttl.exists(lpad(pr_nrdconta,10,0)) THEN
            RETURN vr_tab_crapttl(lpad(pr_nrdconta,10,0)).cdempres;
          END IF;
        ELSE
          -- Ler Cadastro de pessoas juridicas.
          OPEN cr_crapjur;
          FETCH cr_crapjur
            INTO rw_crapjur;
          IF cr_crapjur%NOTFOUND THEN
            CLOSE cr_crapjur;
          ELSE
            CLOSE cr_crapjur;
            RETURN rw_crapjur.cdempres;
          END IF;
        END IF;

        RETURN 0;
      END fn_trata_cdempres;

      -- Gerar lotes e lançamentos dos funcionarios com transferencia
      PROCEDURE pc_trata_crapccs(pr_cdcooper IN crapcop.cdcooper%type,   --> codigo da cooperativa
                                 pr_cdoperad IN crapope.cdoperad%type,   --> Codigo do operador logado
                                 pr_nrseqint IN NUMBER,                  --> numero do documento
                                 pr_dtintegr IN DATE,                    --> data de integraçã
                                 pr_cdsitcta IN crapccs.cdsitcta%type,   --> codigo da situação da conta
                                 pr_dtcantrf IN crapccs.dtcantrf%type,   --> Data de cancelamento da transferencia.
                                 pr_nrlotccs IN OUT NUMBER,              --> numero do lote
                                 pr_flfirst2 IN OUT BOOLEAN,             --> flag para ocntrolar primeiro
                                 pr_vllanmto IN NUMBER,                  --> valor do lancamento
                                 pr_cdhistor IN craphis.cdhistor%type,   --> codigo do historico
                                 pr_nrdconta IN crapcop.nrdconta%type,   --> numero da conta
                                 pr_cdempsol IN NUMBER,                  --> codigo do emprestimo
                                 pr_rowidres IN ROWID,                   --> rowid da crapres para atualizar restart
                                 pr_cdcritic OUT crapcri.cdcritic%TYPE,  --> Critica encontrada
                                 pr_dscritic OUT VARCHAR2) IS

        vr_nrdocmto craplcs.nrdocmto%type;
        vr_rowidlot rowid;
        vr_nrdocmt2 craplcs.nrdocmto%type;

        -- Ler lancamentos dos funcionarios com transferencia
        CURSOR cr_craplcs (pr_cdcooper craplcs.cdcooper%type
                          ,pr_dtintegr craplcs.dtmvtolt%type
                          ,pr_nrdconta craplcs.nrdconta%type
                          ,pr_nrdocmto craplcs.nrdocmto%type)Is
          SELECT 1
            FROM craplcs
           WHERE craplcs.cdcooper = pr_cdcooper
             AND craplcs.dtmvtolt = pr_dtintegr
             AND craplcs.nrdconta = pr_nrdconta
             AND craplcs.cdhistor = 560 -- SAL. LIQUIDO
             AND craplcs.nrdocmto = pr_nrdocmto;
        rw_craplcs cr_craplcs%rowtype;

        -- Buscar lote
        CURSOR cr_craplot (pr_cdcooper craplcs.cdcooper%type
                          ,pr_dtintegr craplcs.dtmvtolt%type
                          ,pr_nrdolote craplot.nrdolote%type)Is
          SELECT rowid
            FROM craplot
           WHERE craplot.cdcooper = pr_cdcooper   AND
                 craplot.dtmvtolt = pr_dtintegr   AND
                 craplot.cdagenci = 1             AND
                 craplot.cdbccxlt = 100           AND
                 craplot.nrdolote = pr_nrdolote;

      BEGIN
        vr_nrdocmto := pr_nrseqint;

        -- Se a conta estiver inativa
        IF pr_cdsitcta = 2 THEN
          vr_cdcritic := 444;
        ELSIF pr_dtcantrf is not null THEN
          vr_cdcritic := 890;
        END IF;

        -- Se for o primeiro, setar numero do lote, senão usar o do parametro
        IF pr_flfirst2 THEN
          pr_nrlotccs := 10201;
        END IF;

        --Gravar lote
        LOOP 
          -- Tentar inserir, se não conseguir incrementa
          -- o numero de lote e tenta novamente
          OPEN cr_craplot (pr_cdcooper => pr_cdcooper
                          ,pr_dtintegr => pr_dtintegr
                          ,pr_nrdolote => pr_nrlotccs);
          FETCH cr_craplot
            INTO vr_rowidlot;

          -- caso não localizar, deve inserir
          IF cr_craplot%NOTFOUND THEN

            BEGIN
              INSERT INTO craplot
                         (  cdcooper
                           ,dtmvtolt
                           ,cdagenci
                           ,cdbccxlt
                           ,nrdolote
                           ,tplotmov)
                  VALUES (  pr_cdcooper -- cdcooper
                           ,pr_dtintegr -- dtmvtolt
                           ,1           -- cdagenci
                           ,100         -- cdbccxlt
                           ,pr_nrlotccs --nrdolote
                           ,32          -- tplotmov
                           )
                returning rowid into vr_rowidlot ;

              pr_flfirst2  := FALSE;
              close cr_craplot;
              Exit;--sair do loop pois ja conseguiu inserir
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Não foi possivel inserir lote'
                              ||' nrlotccs: '|| pr_nrlotccs ||' :'||SQLERRM;
                close cr_craplot;
                RAISE vr_exc_saida;
            END;

          -- se localizar deve verificar se deve procurar novamente
          ELSE
            close cr_craplot;
            -- Se estiver true, incrementa o numero de lote para tentar novamente
            IF pr_flfirst2 THEN
              pr_nrlotccs := pr_nrlotccs + 1;
            ELSE
              exit;--sair do loop e não tenta inserir novamente
            END IF;

          END IF;

        END LOOP;

        IF vr_cdcritic > 0   THEN
          --Gravar rejeitado
          BEGIN
            INSERT INTO craprej
                        (  dtmvtolt
                          ,cdagenci
                          ,cdbccxlt
                          ,nrdolote
                          ,tplotmov
                          ,nrdconta
                          ,cdempres
                          ,cdhistor
                          ,vllanmto
                          ,cdcritic
                          ,tpintegr
                          ,cdcooper)
                 VALUES (  pr_dtintegr   -- dtmvtolt
                          ,1             -- cdagenci
                          ,100           -- cdbccxlt
                          ,pr_nrlotccs   -- nrdolote
                          ,32            -- tplotmov
                          ,pr_nrdconta   -- nrdconta
                          ,pr_cdempsol   -- cdempres
                          ,pr_cdhistor   -- cdhistor
                          ,pr_vllanmto   -- vllanmto
                          ,vr_cdcritic   -- cdcritic
                          ,1             -- tpintegr
                          ,pr_cdcooper); -- cdcooper
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Não foi possivel inserir rejeitados(CRAPREJ)'
                             ||' CTA: '|| gene0002.fn_mask_conta(pr_nrdconta)
                             ||' cdcritic: '|| vr_cdcritic||' :'||SQLERRM;
              RAISE vr_exc_saida;
          END;

          --atualizar craplot
          BEGIN
            UPDATE craplot
               SET craplot.qtinfoln = nvl(craplot.qtinfoln,0) + 1,
                   craplot.vlinfocr = nvl(craplot.vlinfocr,0) + nvl(pr_vllanmto,0)
             WHERE rowid = vr_rowidlot;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Não foi possivel atualizar lote(CRAPLOT)'
                             ||' nrlotccs: '|| pr_nrlotccs ||' :'||SQLERRM;
              RAISE vr_exc_saida;
          END;

          vr_cdcritic := 0;

        ELSE
          vr_nrdocmt2 := vr_nrdocmto;

          --localizar um numero de documento disponivel
          LOOP
            OPEN cr_craplcs (pr_cdcooper => pr_cdcooper
                            ,pr_dtintegr => pr_dtintegr
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdocmto => vr_nrdocmt2);
            FETCH cr_craplcs
              INTO rw_craplcs;
            -- caso não houver nenhum documento ja criado com esse numero, sair do loop
            IF cr_craplcs%NOTFOUND THEN
              CLOSE cr_craplcs;
              EXIT; --SAIR DO LOOP
            ELSE -- se ja existir incrementar e buscar novamente
              vr_nrdocmt2 := (vr_nrdocmt2 + 1000000);
              CLOSE cr_craplcs;
            END IF;
          END LOOP;

          vr_nrdocmto := vr_nrdocmt2;

          -- Inserir lancamentos  de transf dos funcionarios
          BEGIN
            INSERT INTO craplcs
                        ( cdcooper
                         ,cdopecrd
                         ,dtmvtolt
                         ,nrdconta
                         ,nrdocmto
                         ,vllanmto
                         ,cdhistor
                         ,nrdolote
                         ,cdbccxlt
                         ,cdagenci
                         ,flgenvio
                         ,dttransf
                         ,hrtransf)
                 VALUES ( pr_cdcooper -- cdcooper
                         ,pr_cdoperad -- cdoperad
                         ,pr_dtintegr -- dtmvtolt
                         ,pr_nrdconta -- nrdconta
                         ,vr_nrdocmto -- nrdocmto
                         ,pr_vllanmto -- vllanmto
                         ,560         -- cdhistor
                         ,pr_nrlotccs -- nrdolote
                         ,100         -- cdbccxlt
                         ,1           -- cdagenci
                         ,0           -- falso flgenvio
                         ,null        -- dttransf
                         ,0 );        -- hrtransf
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Não foi possivel inserir lancamentos  de transf dos funcionarios(CRAPLCS)'
                               ||' CTA: '|| gene0002.fn_mask_conta(pr_nrdconta)
                               ||' nrdocmto: '|| vr_nrdocmto ||' :'||SQLERRM;
              RAISE vr_exc_saida;
          END;

          --atualizar craplot
          BEGIN
            UPDATE craplot
               SET craplot.qtinfoln = nvl(craplot.qtinfoln,0) + 1,
                   craplot.qtcompln = nvl(craplot.qtcompln,0) + 1,
                   craplot.vlinfocr = nvl(craplot.vlinfocr,0) + nvl(pr_vllanmto,0),
                   craplot.vlcompcr = nvl(craplot.vlcompcr,0) + nvl(pr_vllanmto,0),
                   craplot.nrseqdig = pr_nrseqint
             WHERE rowid = vr_rowidlot;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Não foi possivel atualizar lote(CRAPLOT)'
                             ||' nrlotccs: '|| pr_nrlotccs ||' :'||SQLERRM;
              RAISE vr_exc_saida;
          END;

        END IF;
        -- Atualizar a tabela de restart
        BEGIN
          UPDATE crapres res
             SET nrdconta = pr_nrseqint
           WHERE res.rowid = pr_rowidres;
        EXCEPTION
          WHEN OTHERS THEN
            -- Gerar erro e fazer rollback
            vr_dscritic := 'Erro ao atualizar a tabela de Restart (CRAPRES) - Conta:'||pr_nrseqint
                            ||'. Detalhes: '||sqlerrm;
            RAISE vr_exc_saida;
        END;

      EXCEPTION
        WHEN vr_exc_saida THEN
          -- Se foi retornado apenas código
          IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
            -- Buscar a descrição
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          END IF;
          -- Devolvemos código e critica encontradas das variaveis locais
          pr_cdcritic := NVL(vr_cdcritic,0);
          pr_dscritic := vr_dscritic;
        WHEN OTHERS THEN
          -- Efetuar retorno do erro não tratado
          pr_cdcritic := 0;
          pr_dscritic := sqlerrm;
      END pc_trata_crapccs;

      -- Gerar os relatorios de estouros.
      PROCEDURE pc_gera_rel_estouros(pr_cdcooper  IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                    ,pr_crapdat   IN btch0001.cr_crapdat%ROWTYPE  --> type contendo as informações da crapdat
                                    ,pr_cdempres  IN crapemp.cdempres%type   --> codigo da empresa
                                    ,pr_dsempres  IN VARCHAR2                --> Nome da empresa
                                    ,pr_nmarqest  IN VARCHAR2                --> nome do relatorio de resumo
                                    ,pr_nmarqden  IN VARCHAR2                --> Nome do relatorio detalhe
                                    ,pr_dtrefere  IN DATE                    --> data de referencia
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE   --> Critica encontrada
                                    ,pr_dscritic OUT VARCHAR2) IS            --> Descrição da critica

      /* .............................................................................

       Programa: pc_gera_rel_estouros (Fontes/crps120_e.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Deborah/Edson
       Data    : Junho/95.                     Ultima atualizacao: 24/12/2013

       Dados referentes ao programa:

       Frequencia: Diario (Batch).
       Objetivo  : Gerar relatorio de estouros (99 e 114)

       Alteracoes: 07/08/96 - Alterado para tratar varios convenios de dentistas
                              (Edson).

                   19/05/97 - Alterado para tratar outros convenios (Edson).

                   11/08/97 - Nao listar estouros de cotas e emprestimos (Odair)

                   22/10/97 - Alterar a ordem de classificacao do relatorio de
                              convenios (Odair)

                   20/03/2000 - Nao gerar pedido de impressao do relatorio 114
                                (Deborah).

                   16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

                   21/02/2008 - Mostrar turno da crapttl.cdturnos (Gabriel)

                   08/05/2008 - Ajuste comando FIND(craphis) utilizava FOR p/ acesso
                                (Sidnei - Precise)

                   01/09/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.

                   21/01/2013 - Removido o indice crapass4 (Daniele).

                   29/10/2013 - Verificacao se existem registros (aux_flarqden) para
                                saber se copia o relatorio crrl114 para o dir rlnsv
                                no crps120.p (Carlos)

                   24/12/2013 - - Conversao Progress >> Oracle PLSQL (Odirlei-AMcom)

      */

        -- Tratamento de erros
        vr_exc_saida  EXCEPTION;
        vr_cdcritic   PLS_INTEGER;
        vr_dscritic   VARCHAR2(4000);

        ------------------------------- CURSORES ---------------------------------
        --Ler associados
        CURSOR cr_crapass IS
          SELECT /*+ index (crapass crapass##crapass1) */
                 inpessoa,
                 nrdconta,
                 cdagenci
            FROM crapass
           WHERE crapass.cdcooper = pr_cdcooper
             AND crapass.dtelimin IS NULL
           ORDER BY crapass.cdagenci,
                    crapass.nrdconta;

        -- Buscar empresa juridica
        CURSOR cr_crapjur (pr_nrdconta crapass.nrdconta%type) IS
          SELECT cdempres
            FROM crapjur
           WHERE crapjur.cdcooper = pr_cdcooper
             AND crapjur.nrdconta = pr_nrdconta;
        rw_crapjur cr_crapjur%rowtype;

        -- Ler avisos de debito
        CURSOR cr_crapavs (pr_cdcooper crapavs.cdcooper%type,
                           pr_nrdconta crapass.nrdconta%type,
                           pr_dtrefere crapavs.dtrefere%type) IS
          SELECT vllanmto,
                 nrconven,
                 vldebito,
                 vlestdif,
                 cdhistor
            FROM crapavs
           WHERE crapavs.cdcooper = pr_cdcooper
             AND crapavs.nrdconta = pr_nrdconta
             AND crapavs.tpdaviso = 1
             AND crapavs.dtrefere = pr_dtrefere
             AND ((crapavs.cdhistor in (108,127)) OR
                   crapavs.nrconven > 0);

        -- ler agencias
        CURSOR cr_crapage IS
          SELECT a.cdagenci,
                 a.nmresage
            FROM crapage a
           WHERE a.cdcooper = pr_cdcooper;

        -- ler lista de historicos na craptab
        CURSOR cr_craptab IS
          SELECT tpregist,
                 dstextab
            FROM craptab
           WHERE craptab.cdcooper        = pr_cdcooper
             AND upper(craptab.nmsistem) = 'CRED'
             AND upper(craptab.tptabela) = 'GENERI'
             AND craptab.cdempres        = 0
             AND upper(craptab.cdacesso) = 'CONVFOLHAS';


        -- Ler avisos
        CURSOR cr_crapavs1 IS
          SELECT cdhistor,
                 cdcooper,
                 cdagenci,
                 vllanmto,
                 vldebito,
                 vlestdif,
                 nrdconta,
                 nrdocmto,
                 nrseqdig,
                 rownum,
                 row_number() over(partition by cdhistor
                                        order by cdhistor) reghist,
                 count(*) over(partition by cdhistor
                                   order by cdhistor) qtdhis,
                 row_number() over(partition by cdhistor, cdagenci, nrdconta
                                       order by cdhistor, cdagenci, nrdconta) regconta,
                 count(*) over(partition by nrdconta
                                   order by cdhistor, cdagenci, nrdconta) qtdconta
            FROM crapavs
           WHERE crapavs.cdcooper = pr_cdcooper
             AND crapavs.cdempres = pr_cdempres
             AND crapavs.tpdaviso = 1
             AND crapavs.dtrefere = pr_dtrefere
             AND gene0002.fn_existe_valor(vr_lshstden,crapavs.cdhistor,',') = 'S'
           ORDER BY crapavs.cdhistor, crapavs.cdagenci, crapavs.nrdconta;

        -- Ler historico
        CURSOR cr_craphis (pr_cdcooper craphis.cdcooper%type,
                           pr_cdhistor craphis.cdhistor%type)IS
          SELECT dshistor
            FROM craphis
           WHERE craphis.cdcooper = pr_cdcooper
             AND craphis.cdhistor = pr_cdhistor;
        rw_craphis cr_craphis%rowtype;

        -- Ler associado
        CURSOR cr_crapass1 (pr_cdcooper crapass.cdcooper%type,
                           pr_nrdconta crapass.nrdconta%type)IS
          SELECT nmprimtl,
                 nrdconta,
                 cdagenci,
                 nrramemp
            FROM crapass
           WHERE crapass.cdcooper = pr_cdcooper
             AND crapass.nrdconta = pr_nrdconta;
        rw_crapass1 cr_crapass1%rowtype;

        -- Ler convenio
        CURSOR cr_crapcnv (pr_cdcooper crapcnv.cdcooper%type,
                           pr_nrconven crapcnv.nrconven%type)IS
          SELECT dsconven,
                 nrconven
            FROM crapcnv
           WHERE crapcnv.cdcooper = pr_cdcooper
             AND crapcnv.nrconven = pr_nrconven;
        rw_crapcnv cr_crapcnv%rowtype;

        ------------------------------- VARIAVEIS -------------------------------

        -- Valores tratados para exibir no relatorio
        vr_avs_vlestdif NUMBER := 0;
        vr_ger_vlavsemp NUMBER := 0;
        vr_ger_vldebemp NUMBER := 0;
        vr_ger_vlantemp NUMBER := 0;
        vr_ger_vlavscot NUMBER := 0;
        vr_ger_vldebcot NUMBER := 0;
        vr_ger_vlantcot NUMBER := 0;
        vr_rel_vlestdif NUMBER := 0;
        vr_rel_dscritic VARCHAR2(80);
        vr_ass_vlestemp NUMBER := 0;
        vr_ass_vlestdif NUMBER := 0;
        vr_rel_dsconven VARCHAR2(100) := null;
        vr_ger_qtestcot NUMBER := 0;
        vr_ger_qtestemp NUMBER := 0;
        vr_ger_vlestcot NUMBER := 0;
        vr_ger_vlestemp NUMBER := 0;
        vr_rel_cdagenci NUMBER := 0;
        vr_tot_qtestden NUMBER := 0;
        vr_tot_vlestden NUMBER := 0;
        vr_ger_qtavsden NUMBER := 0;
        vr_ger_vlavsden NUMBER := 0;
        vr_ger_qtdebden NUMBER := 0;
        vr_ger_vldebden NUMBER := 0;
        vr_ger_qtestden NUMBER := 0;
        vr_ger_vlestden NUMBER := 0;
        vr_ger_vlantden NUMBER := 0;
        vr_ass_vlestden NUMBER := 0;
        vr_rel_dshistor craphis.dshistor%type;
        vr_cdturnos     crapttl.cdturnos%type;

        -- Variaveis de controle
        vr_aux_flgexist BOOLEAN ;
        vr_flgexist     NUMBER := 0;
        vr_est_flgsomar BOOLEAN;

        -- indice da tabela temporaria
        vr_idx          varchar2(10);


        -- Type para armazenar os totais por convenio
        type typ_regconv is record ( vlavscnv crapavs.vllanmto%type,
                                     qtavscnv NUMBER,
                                     vldebcnv crapavs.vllanmto%type,
                                     qtdebcnv NUMBER,
                                     vlestcnv crapavs.vllanmto%type,
                                     qtestcnv NUMBER);
        type typ_tab_regconv is table of typ_regconv
                           index by varchar2(10); --nrconven(10)
        vr_tab_regconv typ_tab_regconv;

        --Type para armazenar os totais por agencia
        type typ_reg_totagen is record (vlestemp crapavs.vllanmto%type,
                                        qtestemp NUMBER,
                                        vlestcot crapavs.vllanmto%type,
                                        qtestcot NUMBER,
                                        qtestden NUMBER,
                                        vlestden crapavs.vllanmto%type
                                        );
        type typ_tab_totagen is table of typ_reg_totagen
                           index by varchar2(5); --cdagenci(5)
        vr_tab_totagen typ_tab_totagen;

        -- Type para armazenar os nomes das agencias
        type typ_tab_dsagenci is table of varchar2(50)
                           index by varchar2(5); --cdagenci(5)
        vr_tab_dsagenci typ_tab_dsagenci;

        -- Type para armazenar as descrições dos historicos
        type typ_tab_dshstden is table of craptab.dstextab%TYPE
                           index by varchar2(5); --cdhistor(5)
        vr_dshstden typ_tab_dshstden;

        -- Variavel para armazenar as informacos em XML
        vr_des_xml       clob;

        --Escrever no arquivo CLOB
        PROCEDURE pc_escreve_xml(pr_des_dados IN CLOB) IS
        BEGIN
          --Escrever no arquivo XML
          vr_des_xml := vr_des_xml||pr_des_dados;
        END;

      BEGIN
      ------------------------------------
        /*  Leitura do cadastro de agencias  */
        FOR rw_crapage IN cr_crapage LOOP

          vr_tab_dsagenci(lpad(rw_crapage.cdagenci,5,'0')) := gene0002.fn_mask(rw_crapage.cdagenci,'999') ||' - '||
                                                              rw_crapage.nmresage;

        END LOOP;  /*  Fim do loop -- Leitura do cadastro de agencias  */


        -- ler os associados
        FOR rw_crapass IN cr_crapass LOOP
          vr_cdempres := 0;
          -- se for pessoa fisica
          IF rw_crapass.inpessoa = 1 THEN

            --verificar se o registro existe
            IF vr_tab_crapttl.exists(lpad(rw_crapass.nrdconta,10,0)) THEN
              vr_cdempres := vr_tab_crapttl(lpad(rw_crapass.nrdconta,10,0)).cdempres;
            END IF;

          ELSE--Senão é pessoa juridica
            --buscar empresa da pessoa juridica
            OPEN cr_crapjur(pr_nrdconta => rw_crapass.nrdconta);
            FETCH cr_crapjur
              INTO rw_crapjur;
            IF cr_crapjur%notfound THEN
              CLOSE cr_crapjur;
            ELSE
              vr_cdempres := rw_crapjur.cdempres;
              CLOSE cr_crapjur;
            END IF;
          END IF;

          -- somente carregar empresa iguais a do parametro
          IF vr_cdempres <> pr_cdempres THEN
            -- Ir para o proximo
            CONTINUE;
          END IF;

          vr_est_flgsomar := TRUE;
          -- Ler os associados
          FOR rw_crapavs IN cr_crapavs (pr_cdcooper => pr_cdcooper ,
                                        pr_nrdconta => rw_crapass.nrdconta,
                                        pr_dtrefere => pr_dtrefere) LOOP
            --Definir index
            vr_idx := lpad(rw_crapavs.nrconven,10,'0');
            -- se existir convenio, gerar temptable
            IF rw_crapavs.nrconven > 0   THEN
              -- Verificar se ja existe
              IF vr_tab_regconv.EXISTS(vr_idx) THEN
                vr_tab_regconv(vr_idx).vlavscnv := nvl(vr_tab_regconv(vr_idx).vlavscnv,0) + nvl(rw_crapavs.vllanmto,0);
                vr_tab_regconv(vr_idx).qtavscnv := nvl(vr_tab_regconv(vr_idx).qtavscnv,0) + 1;
              ELSE
                vr_tab_regconv(vr_idx).vlavscnv := rw_crapavs.vllanmto;
                vr_tab_regconv(vr_idx).qtavscnv := 1;
              END IF;
              -- Se existir valor de debito
              IF rw_crapavs.vldebito > 0   THEN
                vr_tab_regconv(vr_idx).vldebcnv := nvl(vr_tab_regconv(vr_idx).vldebcnv,0) + nvl(rw_crapavs.vldebito,0);
                vr_tab_regconv(vr_idx).qtdebcnv := nvl(vr_tab_regconv(vr_idx).qtdebcnv,0) + 1;
              ELSE /*  Estouro integral  */
                vr_tab_regconv(vr_idx).vlestcnv := nvl(vr_tab_regconv(vr_idx).vlestcnv,0) + nvl(rw_crapavs.vllanmto,0);
                vr_tab_regconv(vr_idx).qtestcnv := nvl(vr_tab_regconv(vr_idx).qtestcnv,0) + 1;
              END IF;

              CONTINUE;
            END IF;

            /*  Tratamento dos historicos 108 e 127  */
            IF rw_crapavs.vldebito = 0 AND
               rw_crapavs.vlestdif = 0 THEN
              vr_avs_vlestdif := rw_crapavs.vllanmto * -1;
            ELSE
              vr_avs_vlestdif := rw_crapavs.vlestdif;
            END IF;

            /*  Acumula total geral dos aviso  */
            IF rw_crapavs.cdhistor = 108   THEN
              vr_ger_vlavsemp := nvl(vr_ger_vlavsemp,0) + rw_crapavs.vllanmto;
              vr_ger_vldebemp := nvl(vr_ger_vldebemp,0) + rw_crapavs.vldebito;

              -- Se o valor de estouro ou diferença for maior que sero
              IF vr_avs_vlestdif > 0   THEN
                -- somar valor de abatimento de emprestimo
                vr_ger_vlantemp := nvl(vr_ger_vlantemp,0) + nvl(vr_avs_vlestdif,0);
              ELSIF vr_avs_vlestdif < 0   THEN
                -- somar valor de abatimento de emprestimo
                vr_ger_vlantemp := nvl(vr_ger_vlantemp,0) + (nvl(rw_crapavs.vllanmto,0) +
                                  nvl(vr_avs_vlestdif,0) - nvl(rw_crapavs.vldebito,0));
              END IF;
            ELSIF rw_crapavs.cdhistor = 127   THEN
              --- Somar valor total de aviso de cota
              vr_ger_vlavscot := nvl(vr_ger_vlavscot,0) + nvl(rw_crapavs.vllanmto,0);
              vr_ger_vldebcot := nvl(vr_ger_vldebcot,0) + nvl(rw_crapavs.vldebito,0);

              -- Calcular total de abatimento de cotas
              IF vr_avs_vlestdif > 0   THEN
                vr_ger_vlantcot := nvl(vr_ger_vlantcot,0) + nvl(vr_avs_vlestdif,0);
              ELSIF vr_avs_vlestdif < 0   THEN
                vr_ger_vlantcot := nvl(vr_ger_vlantcot,0) + (nvl(rw_crapavs.vllanmto,0) +
                                   nvl(vr_avs_vlestdif,0) - nvl(rw_crapavs.vldebito,0));
              END IF;
            END IF;

            -- Ir para proximo registro se o valor de debito for igual ao lançamento
            IF rw_crapavs.vldebito = rw_crapavs.vllanmto THEN
              continue;
            END IF;

            -- Definir descrição e valor da diferença
            IF nvl(vr_avs_vlestdif,0) > 0 THEN
              vr_rel_vlestdif := vr_avs_vlestdif;
              vr_rel_dscritic := 'DEBITO MENOR';
            ELSIF vr_avs_vlestdif < 0 THEN
              vr_rel_vlestdif := vr_avs_vlestdif * -1;
              vr_rel_dscritic := 'ESTOURO';

              vr_idx := lpad(rw_crapass.cdagenci,5,'0');
              IF rw_crapavs.cdhistor = 108  THEN
                -- verificar se ja existe reg na temp table
                IF vr_tab_totagen.exists(vr_idx) THEN
                  vr_tab_totagen(vr_idx).vlestemp := nvl(vr_tab_totagen(vr_idx).vlestemp,0) + nvl(vr_rel_vlestdif,0);
                ELSE
                  vr_tab_totagen(vr_idx).vlestemp := nvl(vr_rel_vlestdif,0);
                END IF;
                --verificar se deve somar
                IF vr_est_flgsomar THEN
                  vr_tab_totagen(vr_idx).qtestemp := nvl(vr_tab_totagen(vr_idx).qtestemp,0) + 1;
                END IF;

                vr_ass_vlestemp := vr_rel_vlestdif;
                vr_ass_vlestdif := nvl(vr_ass_vlestdif,0) + nvl(vr_rel_vlestdif,0);

                vr_est_flgsomar := FALSE;
              ELSIF rw_crapavs.cdhistor = 127   THEN
                -- verificar se ja existe reg na temp table
                IF vr_tab_totagen.exists(vr_idx) THEN
                  vr_tab_totagen(vr_idx).qtestcot := nvl(vr_tab_totagen(vr_idx).qtestcot,0) + 1;
                  vr_tab_totagen(vr_idx).vlestcot := nvl(vr_tab_totagen(vr_idx).vlestcot,0) +
                                                     nvl(vr_rel_vlestdif,0);
                ELSE

                  vr_tab_totagen(vr_idx).qtestcot := 1;
                  vr_tab_totagen(vr_idx).vlestcot := nvl(vr_rel_vlestdif,0);
                END IF;
              END IF;
            END IF;
          END LOOP;  /*  Fim do loop -- Leitura dos avisos  */

          vr_ass_vlestdif := 0;
          vr_ass_vlestemp := 0;

        END LOOP; /*  Fim do loop -- Leitura dos associados  */

        -- Inicializar o CLOB
        dbms_lob.createtemporary(vr_des_xml, true);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

        pc_escreve_xml('<resumo desresum="RESUMO GERAL"
                                dsconven="'||vr_rel_dsconven||'"
                                dsempres="'||pr_dsempres||'"
                                dtrefere="'||to_char(pr_dtrefere,'DD/MM/RRRR') ||'" >');

        -- varrer totais por agencia
        vr_idx := vr_tab_totagen.first;
        LOOP
          -- Sair qnd não existir mais indices
          EXIT WHEN vr_idx is null;

          --Somente apresentar no relatorio se as qtd não forem zero
          IF nvl(vr_tab_totagen(vr_idx).qtestcot,0) <> 0   OR
             nvl(vr_tab_totagen(vr_idx).qtestemp,0) <> 0   THEN

            -- totais gerais
            vr_ger_qtestcot := nvl(vr_ger_qtestcot,0) + nvl(vr_tab_totagen(vr_idx).qtestcot,0);
            vr_ger_qtestemp := nvl(vr_ger_qtestemp,0) + nvl(vr_tab_totagen(vr_idx).qtestemp,0);
            vr_ger_vlestcot := nvl(vr_ger_vlestcot,0) + nvl(vr_tab_totagen(vr_idx).vlestcot,0);
            vr_ger_vlestemp := nvl(vr_ger_vlestemp,0) + nvl(vr_tab_totagen(vr_idx).vlestemp,0);

            pc_escreve_xml('<agencia>
                               <dsagenci>'||vr_tab_dsagenci(lpad(vr_idx,5,'0'))||'</dsagenci>
                               <qtestcot>'||nvl(vr_tab_totagen(vr_idx).qtestcot,0)||'</qtestcot>
                               <vlestcot>'||nvl(vr_tab_totagen(vr_idx).vlestcot,0)||'</vlestcot>
                               <qtestemp>'||nvl(vr_tab_totagen(vr_idx).qtestemp,0)||'</qtestemp>
                               <vlestemp>'||nvl(vr_tab_totagen(vr_idx).vlestemp,0)||'</vlestemp>
                            </agencia>');

          END IF;

          --buscar o proximo
          vr_idx := vr_tab_totagen.next(vr_idx);
        END LOOP;

        -- Gerar totais
        pc_escreve_xml('<total>
                          <vlavscot>'||vr_ger_vlavscot ||'</vlavscot>
                          <vlavsemp>'||vr_ger_vlavsemp ||'</vlavsemp>
                          <vldebcot>'||vr_ger_vldebcot ||'</vldebcot>
                          <vldebemp>'||vr_ger_vldebemp ||'</vldebemp>
                          <vlantcot>'||vr_ger_vlantcot ||'</vlantcot>
                          <vlantemp>'||vr_ger_vlantemp ||'</vlantemp>
                        </total>');


      pc_escreve_xml('</resumo>');
      -- Inclir tags de definição do xml, e grupo inicial
      vr_des_xml := '<?xml version="1.0" encoding="utf-8"?><crrl099>'||vr_des_xml||'</crrl099>';

      -- Solicitar impressao
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                 ,pr_dtmvtolt  => pr_crapdat.dtmvtolt --> Data do movimento atual
                                 ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/crrl099/resumo'   --> No base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl099.jasper'    --> Arquivo de layout do iReport
                                 ,pr_dsparams  => null                --> Enviar como parametro apenas a agencia
                                 ,pr_dsarqsaid => pr_nmarqest         --> Arquivo final com codigo da agencia
                                 ,pr_sqcabrel  => 3                   --> Sequencial do relatorio
                                 ,pr_qtcoluna  => 132                 --> 132 colunas
                                 ,pr_flg_impri => 'S'                 --> Chamar a impress?o (Imprim.p)
                                 ,pr_nmformul  => '132dh'             --> Nome do formulario para impress?o
                                 ,pr_nrcopias  => 1                   --> Numero de copias
	                               ,pr_dspathcop => vr_nom_direto||'/rlnsv/' --> diretorio de copia do arquivo
                                 ,pr_des_erro  => vr_dscritic);       --> Saida com erro

      IF vr_dscritic IS NOT NULL THEN
        -- somente gera log
        -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra ||  ' --> relatorio:'||pr_nmarqest||' --> '
                                                     || vr_dscritic );
      END IF;

      -- Liberando a memoria alocada pro CLOB
      dbms_lob.freetemporary(vr_des_xml);


      /*  Trata estouro dos CONVENIOS ............................................. */

      /* Leitura dos historicos de convenio */
      FOR rw_craptab IN cr_craptab LOOP
        -- Gravar descrições dos historicos
        vr_dshstden(rw_craptab.tpregist) := rw_craptab.dstextab;

        -- Montar lista de codigos em uma string, para utilizar no select
        IF vr_lshstden IS NULL THEN
          vr_lshstden := rw_craptab.tpregist;
        ELSE
          vr_lshstden := vr_lshstden||','||rw_craptab.tpregist;
        END IF;

      END LOOP; /*  Fim do loop -- Leitura dos historicos de convenio  */

      -- Inicializar o CLOB
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

      -- ler avisos referente aos historicos
      FOR rw_crapavs IN cr_crapavs1 LOOP

        --Verificar se é o primeiro registro do historico(first-of)
        IF rw_crapavs.reghist = 1 THEN
          vr_rel_cdagenci := 0;
          vr_tot_qtestden := 0;
          vr_tot_vlestden := 0;
          vr_ger_qtavsden := 0;
          vr_ger_vlavsden := 0;
          vr_ger_qtdebden := 0;
          vr_ger_vldebden := 0;
          vr_ger_qtestden := 0;
          vr_ger_vlestden := 0;
          vr_ger_vlantden := 0;
          vr_ass_vlestdif := 0;
          vr_ass_vlestden := 0;
          vr_aux_flgexist := TRUE;
          vr_tab_totagen.delete;

          --Buscar descrição de historico
          IF vr_dshstden.exists(rw_crapavs.cdhistor) THEN
            vr_rel_dsconven := vr_dshstden(rw_crapavs.cdhistor);
          END IF;

          --Buscar descrição do historico
          OPEN cr_craphis (pr_cdcooper => rw_crapavs.cdcooper,
                           pr_cdhistor => rw_crapavs.cdhistor);
          FETCH cr_craphis
           INTO rw_craphis;
          IF cr_craphis%NOTFOUND THEN
            vr_rel_dshistor := 'N/CADASTRADO';
            CLOSE cr_craphis;
          ELSE
            CLOSE cr_craphis;
            vr_rel_dshistor := rw_craphis.dshistor;
          END IF;

          pc_escreve_xml('<histor desresum="GERAL"
                                  idhist="'||rw_crapavs.rownum||'"
                                  dsagenci=""
                                  dsconven="'||vr_rel_dsconven||'"
                                  dsempres="'||vr_dsempres||'"
                                  dtrefere="'||to_char(pr_dtrefere,'DD/MM/RRRR') ||'" >');

        END IF;

        IF rw_crapavs.vldebito = 0 AND
           rw_crapavs.vlestdif = 0 THEN
          vr_avs_vlestdif := rw_crapavs.vllanmto * -1;
        ELSE
          vr_avs_vlestdif := rw_crapavs.vlestdif;
        END IF;

        /*  Acumula total geral dos aviso  */
        vr_ger_vlavsden := nvl(vr_ger_vlavsden,0) + nvl(rw_crapavs.vllanmto,0);
        vr_ger_vldebden := nvl(vr_ger_vldebden,0) + nvl(rw_crapavs.vldebito,0);
        vr_ger_qtavsden := nvl(vr_ger_qtavsden,0) + 1;

        -- apenas contar se o valor for maior que zero
        IF rw_crapavs.vldebito > 0 THEN
          vr_ger_qtdebden := nvl(vr_ger_qtdebden,0) + 1;
        END IF;

        IF vr_avs_vlestdif > 0 THEN
          vr_ger_vlantden :=  nvl(vr_ger_vlantden,0) +  nvl(vr_avs_vlestdif,0);
        ELSIF vr_avs_vlestdif < 0 THEN
          vr_ger_vlantden :=  nvl(vr_ger_vlantden,0) +
                           (rw_crapavs.vllanmto +  nvl(vr_avs_vlestdif,0) - rw_crapavs.vldebito);
        END IF;

        -- se o valor de debito do aviso for diferente do lancamento
        IF rw_crapavs.vldebito <> rw_crapavs.vllanmto   THEN
          --definir valor e descrição da diferença para apresentar no relatorio
          IF vr_avs_vlestdif > 0 THEN
            vr_rel_vlestdif := vr_avs_vlestdif;
            vr_rel_dscritic := 'DEBITO MENOR';
          ELSIF vr_avs_vlestdif < 0   THEN
            vr_rel_vlestdif := vr_avs_vlestdif * -1;
            vr_rel_dscritic := 'ESTOURO';

            -- Se o registro ja existir incrementa, senão inicializa
            IF vr_tab_totagen.EXISTS(rw_crapavs.cdagenci) THEN
              vr_tab_totagen(rw_crapavs.cdagenci).qtestden :=
                          vr_tab_totagen(rw_crapavs.cdagenci).qtestden + 1;

              vr_tab_totagen(rw_crapavs.cdagenci).vlestden :=
                           vr_tab_totagen(rw_crapavs.cdagenci).vlestden + vr_rel_vlestdif;

            ELSE
              vr_tab_totagen(rw_crapavs.cdagenci).qtestden := 1;
              vr_tab_totagen(rw_crapavs.cdagenci).vlestden := vr_rel_vlestdif;
            END IF;
          END IF; --Fim vr_avs_vlestdif

          -- verificar se é o primeiro registro que aparece esta conta(FIRST-OF)
          IF rw_crapavs.regconta = 1 THEN

            -- Buscar associado
            OPEN cr_crapass1 (pr_cdcooper => pr_cdcooper,
                              pr_nrdconta => rw_crapavs.nrdconta);
            FETCH cr_crapass1
              INTO rw_crapass1;
            IF cr_crapass1%NOTFOUND THEN
              vr_dscritic := gene0001.fn_busca_critica(251);
              -- Envio centralizado de log de erro
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 2 -- Erro tratato
                                        ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                         || vr_cdprogra || ' --> '|| vr_dscritic
                                                         ||' Conta/dv '|| rw_crapavs.nrdconta);

              pc_escreve_xml('<conta nrdconta="'||rw_crapavs.nrdconta||'"
                                     nmprimtl="NAO CADASTRADO">');
              close cr_crapass1;
            ELSE

              --verificar se o registro do titular existe
              IF vr_tab_crapttl.exists(lpad(rw_crapavs.nrdconta,10,0)) THEN
                vr_cdturnos := vr_tab_crapttl(lpad(rw_crapavs.nrdconta,10,0)).cdturnos;
              END IF;

              pc_escreve_xml('<conta nrdconta="'||gene0002.fn_mask_conta(rw_crapavs.nrdconta)||'"
                                     nmprimtl="'||rw_crapass1.nmprimtl||'"
                                     cdagenci="'||rw_crapass1.cdagenci ||'"
                                     nrramemp="'||rw_crapass1.nrramemp||'"
                                     cdturnos="'||vr_cdturnos||'" >');

              close cr_crapass1;
            END IF;

            pc_escreve_xml('<aviso>
                               <dshistor>'||vr_rel_dshistor ||'</dshistor>
                               <nrdocmto>'||gene0002.fn_mask_contrato(rw_crapavs.nrdocmto) ||'</nrdocmto>
                               <nrseqdig>'||rw_crapavs.nrseqdig ||'</nrseqdig>
                               <vllanmto>'||rw_crapavs.vllanmto ||'</vllanmto>
                               <vldebito>'||rw_crapavs.vldebito ||'</vldebito>
                               <vlestdif>'||vr_rel_vlestdif ||'</vlestdif>
                               <dscritic>'||vr_rel_dscritic ||'</dscritic>
                            </aviso>');


            --fechar tag conta
            pc_escreve_xml('</conta>');

          END IF; --fim first-of conta
        END IF;

        -- verificar se é o ultimo registro desse hitorico(last-of)
        IF rw_crapavs.reghist = rw_crapavs.qtdhis THEN
          --fechar a tag de conta se for o ultimo

          pc_escreve_xml('<resumo desresum="RESUMO GERAL"
                                dsconven="'||vr_rel_dsconven||'"
                                dsempres="'||vr_dsempres||'"
                                dtrefere="'||to_char(pr_dtrefere,'DD/MM/RRRR') ||'" >');

          -- varrer totais por agencia
          vr_idx := vr_tab_totagen.first;
          LOOP

            EXIT WHEN vr_idx is null;
            --Somente apresentar no relatorio se as qtd não forem zero
            IF nvl(vr_tab_totagen(vr_idx).qtestden,0) <> 0 THEN

              -- totais gerais
              vr_ger_qtestden := nvl(vr_ger_qtestden,0) + nvl(vr_tab_totagen(vr_idx).qtestden,0);
              vr_ger_vlestden := nvl(vr_ger_vlestden,0) + nvl(vr_tab_totagen(vr_idx).vlestden,0);

              pc_escreve_xml('<agencia>
                                 <dsagenci>'||vr_tab_dsagenci(lpad(vr_idx,5,'0'))||'</dsagenci>
                                 <qtestden>'||vr_tab_totagen(vr_idx).qtestden||'</qtestden>
                                 <vlestden>'||vr_tab_totagen(vr_idx).vlestden||'</vlestden>
                              </agencia>');

            END IF;
            --buscar o proximo
            vr_idx := vr_tab_totagen.next(vr_idx);
          END LOOP;

          -- Gerar totais
          pc_escreve_xml('<total>
                            <qtestden>'||vr_ger_qtestden ||'</qtestden>
                            <vlestden>'||vr_ger_vlestden ||'</vlestden>
                            <qtavsden>'||vr_ger_qtavsden ||'</qtavsden>
                            <vlavsden>'||vr_ger_vlavsden ||'</vlavsden>
                            <qtdebden>'||vr_ger_qtdebden ||'</qtdebden>
                            <vldebden>'||vr_ger_vldebden ||'</vldebden>
                          </total>
                          ');


          pc_escreve_xml('</resumo>');
          pc_escreve_xml('</histor>');
        END IF;

      END LOOP; /*  Fim do loop  --  Leitura do crapavs  */

     /*  Emite resumo de outros convenios - Sindicatos, farmacias, etc  */
      pc_escreve_xml('<empresa dsempres="'||vr_dsempres||'">');
      vr_flgexist := 0;
      -- varrer totais por agencia
      vr_idx := vr_tab_regconv.first;
      LOOP
        EXIT WHEN vr_idx is null;
        --Somente apresentar no relatorio se as qtd não forem zero
        IF nvl(vr_tab_regconv(vr_idx).qtavscnv,0) <> 0 OR
           nvl(vr_tab_regconv(vr_idx).qtdebcnv,0) <> 0 OR
           nvl(vr_tab_regconv(vr_idx).qtestcnv,0) <> 0 THEN

          --buscar descrição do convenio
          OPEN cr_crapcnv( pr_cdcooper => pr_cdcooper,
                           pr_nrconven => vr_idx);
          FETCH cr_crapcnv
            INTO rw_crapcnv;
          IF cr_crapcnv%NOTFOUND THEN
            vr_rel_dsconven := lpad(to_number(vr_idx),3,'0')||' - NAO CADASTRADO.';
          ELSE
            vr_rel_dsconven := lpad(to_number(vr_idx),3,'0')|| ' - '|| rw_crapcnv.dsconven;
          END IF;
          CLOSE cr_crapcnv;

          pc_escreve_xml('<convenio>
                             <dsconven>'||vr_rel_dsconven||'</dsconven>
                             <qtavscnv>'||nvl(vr_tab_regconv(vr_idx).qtavscnv,0)||'</qtavscnv>
                             <vlavscnv>'||nvl(vr_tab_regconv(vr_idx).vlavscnv,0)||'</vlavscnv>
                             <qtdebcnv>'||nvl(vr_tab_regconv(vr_idx).qtdebcnv,0)||'</qtdebcnv>
                             <vldebcnv>'||nvl(vr_tab_regconv(vr_idx).vldebcnv,0)||'</vldebcnv>
                             <qtestcnv>'||nvl(vr_tab_regconv(vr_idx).qtestcnv,0)||'</qtestcnv>
                             <vlestcnv>'||nvl(vr_tab_regconv(vr_idx).vlestcnv,0)||'</vlestcnv>
                          </convenio>');

        END IF;
        vr_flgexist := 1;
        --buscar o proximo
        vr_idx := vr_tab_regconv.next(vr_idx);
      END LOOP;
      pc_escreve_xml('</empresa>');

      vr_des_xml    := '<?xml version="1.0" encoding="utf-8"?><crrl114>'||vr_des_xml||'</crrl114>';

      -- Solicitar impressao
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                 ,pr_dtmvtolt  => pr_crapdat.dtmvtolt --> Data do movimento atual
                                 ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/crrl114'          --> No base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl114.jasper'    --> Arquivo de layout do iReport
                                 ,pr_dsparams  => null                --> Enviar como parametro apenas a agencia
                                 ,pr_dsarqsaid => pr_nmarqden         --> Arquivo final com codigo da agencia
                                 ,pr_sqcabrel  => 4                   --> Sequencial do relatorio
                                 ,pr_qtcoluna  => 132                 --> 132 colunas
                                 ,pr_flg_impri => (case vr_flgexist
                                                     -- Se existe dados a serem gerados, deve chamar o imprim.p
                                                     when 1 then 'S'
                                                     else 'N'
                                                   end)               --> Chamar a impress?o (Imprim.p)
                                 ,pr_nmformul  => '132dh'             --> Nome do formulario para impress?o
                                 ,pr_nrcopias  => 2                   --> Numero de copias
                                 ,pr_dspathcop => (case vr_flgexist
                                                     -- Se existe dados a serem gerados, deve copiar para a pasta rlnsv
                                                     when 1 then vr_nom_direto||'/rlnsv/'
                                                     else NULL
                                                   end ) --> diretorio de copia do arquivo
                                 ,pr_des_erro  => vr_dscritic);       --> Saida com erro

      IF vr_dscritic IS NOT NULL THEN
        -- somente gera log
        -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra ||  ' --> relatorio:'||pr_nmarqden||' --> '
                                                     || vr_dscritic );
      END IF;

      -- Liberando a memoria alocada pro CLOB
      dbms_lob.freetemporary(vr_des_xml);

      -----------------------------------
      EXCEPTION
        WHEN vr_exc_saida THEN
          -- Se foi retornado apenas código
          IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
            -- Buscar a descrição
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          END IF;
          -- Devolvemos código e critica encontradas das variaveis locais
          pr_cdcritic := NVL(vr_cdcritic,0);
          pr_dscritic := vr_dscritic;
        WHEN OTHERS THEN
          -- Efetuar retorno do erro não tratado
          pr_cdcritic := 0;
          pr_dscritic := sqlerrm;
      END pc_gera_rel_estouros;

      -- Processar os debitos de emprestimos.
      PROCEDURE pc_debita_emprestimo(pr_cdcooper  IN crapcop.cdcooper%TYPE      --> Cooperativa solicitada
                                    ,pr_nrdconta  IN crapass.nrdconta%type      --> Número da conta do associado
                                    ,pr_cdempres  IN crapemp.cdempres%type      --> Codigo da empresa
                                    ,pr_tab_vldebcta IN typ_tab_tot_vldebcta    --> Temptable dos Valores por historico
                                    ,pr_nrlotfol  IN crapepr.nrdolote%type      --> Nr do lote do emprestimo
                                    ,pr_dtintegr  IN DATE                       --> Data da integração
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE      --> Critica encontrada
                                    ,pr_dscritic OUT VARCHAR2) IS

      /* .............................................................................

       Programa: pc_debita_emprestimo (Fontes/crps120_d.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Deborah/Edson
       Data    : Junho/95.                     Ultima atualizacao: 16/12/2013

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado pelo crps120.
       Objetivo  : Processar os debitos de emprestimos.

       Alteracoes: 04/06/97 - Alterado para fazer rotina de debito generica
                              (Deborah).

                   29/06/2005 - Alimentado campo cdcooper da tabela craplcm (Diego).

                   16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

                   29/10/2008 - Alteracao CDEMPRES (Diego).

                   19/10/2009 - Alteracao Codigo Historico (Kbase).

                   16/12/2013 - - Conversao Progress >> Oracle PLSQL (Odirlei-AMcom)

      */
        -- Tratamento de erros
        vr_exc_saida  EXCEPTION;
        vr_cdcritic   PLS_INTEGER;
        vr_dscritic   VARCHAR2(4000);

        ------------------------------- CURSORES ---------------------------------

        -- Ler tabela de lotes
        CURSOR cr_craplot IS
          SELECT dtmvtolt,
                 cdcooper,
                 cdagenci,
                 cdbccxlt,
                 nrdolote,
                 nrseqdig,
                 rowid
            FROM craplot
           WHERE craplot.cdcooper = pr_cdcooper
             AND craplot.dtmvtolt = pr_dtintegr
             AND craplot.cdagenci = vr_cdagenci
             AND craplot.cdbccxlt = vr_cdbccxlt
             AND craplot.nrdolote = pr_nrlotfol;
        rw_craplot cr_craplot%ROWTYPE;

        ------------------------------- VARIAVEIS -------------------------------

        vr_nrseqdig NUMBER := 0;
        vr_idx VARCHAR2(20)   ;

      BEGIN

        -- Buscar primeiro indice da temptable
        vr_idx := pr_tab_vldebcta.FIRST;

        LOOP
          -- Se não tiver mais indices, sair do loop
          EXIT WHEN vr_idx IS NULL;

          IF pr_tab_vldebcta(vr_idx) > 0 THEN
            -- Buscar lote
            OPEN cr_craplot;
            FETCH cr_craplot
              INTO rw_craplot;

            -- Se não localizar , gerar mensagem e sair do procedimento
            IF cr_craplot%NOTFOUND THEN
              vr_cdcritic := 60;
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
              -- Envio centralizado de log de erro
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 2 -- Erro tratato
                                        ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                         || vr_cdprogra || ' --> '|| vr_dscritic
                                                         || ' EMPRESA = '||gene0002.fn_mask(pr_cdempres,'99999')||
                                                               ' LOTE = '||gene0002.fn_mask(pr_nrlotfol,'9.999'));
              CLOSE cr_craplot;
              RAISE vr_exc_saida;
            ELSE
              CLOSE cr_craplot;
            END IF;

            BEGIN
              -- Inseir lançamento
              INSERT INTO craplcm
                          (  dtmvtolt
                            ,cdagenci
                            ,cdbccxlt
                            ,nrdolote
                            ,nrdconta
                            ,nrdctabb
                            ,nrdctitg
                            ,nrdocmto
                            ,cdhistor
                            ,vllanmto
                            ,nrseqdig
                            ,cdcooper)
                   VALUES (  rw_craplot.dtmvtolt -- dtmvtolt
                            ,rw_craplot.cdagenci -- cdagenci
                            ,rw_craplot.cdbccxlt -- cdbccxlt
                            ,rw_craplot.nrdolote -- nrdolote
                            ,pr_nrdconta         -- nrdconta
                            ,pr_nrdconta         -- nrdctabb
                            ,gene0002.fn_mask(pr_nrdconta,'99999999') -- nrdctitg
                            ,rw_craplot.nrseqdig + 1 -- nrdocmto
                            ,vr_idx                  -- cdhistor
                            ,pr_tab_vldebcta(vr_idx) -- vllanmto
                            ,rw_craplot.nrseqdig + 1 -- nrseqdig
                            ,pr_cdcooper)            -- cdcooper
                  RETURNING craplcm.nrseqdig  into vr_nrseqdig;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Não foi possivel atualizar lancamento (craplcm)'
                               ||' nrdconta: '|| pr_nrdconta
                               ||' nrdolote: '|| rw_craplot.nrdolote||' :'||SQLERRM;
                RAISE vr_exc_saida;
            END;

            BEGIN
              -- Atualizar Lote
              UPDATE craplot
                 SET craplot.qtinfoln = craplot.qtinfoln + 1,
                     craplot.qtcompln = craplot.qtcompln + 1,
                     craplot.vlinfodb = craplot.vlinfodb + pr_tab_vldebcta(vr_idx),
                     craplot.vlcompdb = craplot.vlcompdb + pr_tab_vldebcta(vr_idx),
                     craplot.nrseqdig = vr_nrseqdig
              WHERE ROWID = rw_craplot.rowid;

            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Não foi possivel atualizar lote (craplot)'
                               ||' nrdconta: '|| pr_nrdconta
                               ||' nrdolote: '|| rw_craplot.nrdolote||' :'||SQLERRM;
                RAISE vr_exc_saida;
            END;

          END IF;
          vr_idx := pr_tab_vldebcta.NEXT(vr_idx);
        END LOOP;


      EXCEPTION
        WHEN vr_exc_saida THEN
          -- Se foi retornado apenas código
          IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
            -- Buscar a descrição
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          END IF;
          -- Devolvemos código e critica encontradas das variaveis locais
          pr_cdcritic := NVL(vr_cdcritic,0);
          pr_dscritic := vr_dscritic;
        WHEN OTHERS THEN
          -- Efetuar retorno do erro não tratado
          pr_cdcritic := 0;
          pr_dscritic := sqlerrm;

      END pc_debita_emprestimo;

      -- Leitura e criacao dos lotes utilizados.
      PROCEDURE pc_carrega_lotes(pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Cooperativa solicitada
                                ,pr_cdempsol  IN craptab.tpregist%TYPE  --> Codigo da empresa solicitantre
                                ,pr_flgclote  IN OUT BOOLEAN            --> Identificador se deve gerar lote
                                ,pr_dtintegr  IN DATE                   --> Data da integraça~p
                                ,pr_cdagenci  IN crapage.cdagenci%type  --> Codigo da agencia
                                ,pr_cdbccxlt  IN crapban.cdbccxlt%type  --> codigo do banco
                                ,pr_nrlotfol OUT NUMBER                 --> Retorna numero de Lote do Credito Folha/Debito
                                ,pr_nrlotcot OUT NUMBER                 --> Retorna numero de Lote do Credito de COTAS
                                ,pr_nrlotemp OUT NUMBER                 --> Retorna numero de Lote do Credito de EMPRESTIMOS
                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                ,pr_dscritic OUT VARCHAR2) IS

      /* .............................................................................

       Programa: pc_carrega_lotes (includes/crps120_l.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Deborah/Edson
       Data    : Junho/95.                     Ultima atualizacao: 16/12/2013

       Dados referentes ao programa:

       Frequencia: Diario (Batch).
       Objetivo  : Leitura e criacao dos lotes utilizados.

       Alteracao : 24/02/97 - Quando criado crps120_3.p criada a variavel
                              aux_cdempres (Odair).

                   06/07/2005 - Alimentado campo cdcooper da tabela craplot (Diego).

                   16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

                   01/09/2008 - Alteracao cdempres (Kbase IT).

                   16/06/2009 - Efetuado acerto na atualizacao do campo
                                craptab.dstextab - NUMLOTEFOL, NUMLOTECOT, NUMLOTEEMP
                                (Diego).

                   16/12/2013 - - Conversao Progress >> Oracle PLSQL (Odirlei-AMcom)

                   05/12/2013 - Alteracao referente a integracao Progress X
                                Dataserver Oracle
                                Inclusao do VALIDATE ( André Euzébio / SUPERO)

      */
        -- Tratamento de erros
        vr_exc_saida  EXCEPTION;
        vr_exc_fimprg EXCEPTION;
        vr_cdcritic   PLS_INTEGER;
        vr_dscritic   VARCHAR2(4000);

        ------------------------------- CURSORES ---------------------------------
        -- Ler Planos de capitalizacao.
        CURSOR cr_craptab (pr_cdcooper crapcop.cdcooper%type,
                           pr_cdacesso craptab.cdacesso%type,
                           pr_tpregist  craptab.tpregist%type) IS
          SELECT dstextab,
                 rowid
            FROM craptab
           WHERE craptab.cdcooper = pr_cdcooper
             AND upper(craptab.nmsistem) = 'CRED'
             AND upper(craptab.tptabela) = 'GENERI'
             AND craptab.cdempres = 0
             AND upper(craptab.cdacesso) = pr_cdacesso
             AND craptab.tpregist = pr_tpregist;

        rw_craptab cr_craptab%rowtype;

        -- Busca dos dados de Linhas de Credito
        CURSOR cr_craplot (pr_cdcooper crapcop.cdcooper%type,
                           pr_dtintegr date,
                           pr_cdagenci crapage.cdagenci%type,
                           pr_cdbccxlt crapban.cdbccxlt%type,
                           pr_nrdolote crapepr.nrdolote%type) IS

        SELECT dtmvtolt,
               cdagenci,
               cdbccxlt,
               nrdolote,
               nrseqdig,
               qtinfoln,
               qtcompln,
               vlinfocr,
               vlcompcr,
               rowid
          FROM craplot
         WHERE craplot.cdcooper = pr_cdcooper
           AND craplot.dtmvtolt = pr_dtintegr
           AND craplot.cdagenci = pr_cdagenci
           AND craplot.cdbccxlt = pr_cdbccxlt
           AND craplot.nrdolote = pr_nrdolote;
        rw_craplot cr_craplot%rowtype;

        ------------------------------- VARIAVEIS -------------------------------


      BEGIN
        ------>>>> GERAR LOTE NUMLOTEFOL <<<<-------
        /*  Lote do Credito Folha/Debito  */

        -- Buscar numero do lote na craptab
        OPEN cr_craptab (pr_cdcooper => pr_cdcooper,
                         pr_cdacesso => 'NUMLOTEFOL',
                         pr_tpregist  => pr_cdempsol);
        FETCH cr_craptab
          INTO rw_craptab;

        IF cr_craptab%NOTFOUND THEN
          --se não encontrar, gravar log
          vr_dscritic := gene0001.fn_busca_critica(175);
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '|| vr_dscritic
                                                     ||' EMPRESA = '|| gene0002.fn_mask(pr_cdempsol,'99999'));
          CLOSE cr_craptab;
          --retonar para o programa chamador com erro para obortar
          raise vr_exc_saida;
        ELSE
          pr_nrlotfol := gene0002.fn_char_para_number(rw_craptab.dstextab);
          CLOSE cr_craptab;
        END IF;

        -- Verificar se deve gerar o lote
        IF pr_flgclote   THEN
          pr_nrlotfol := nvl(pr_nrlotfol,0) + 1;

          -- Buscar lote
          OPEN cr_craplot (pr_cdcooper => pr_cdcooper,
                           pr_dtintegr => pr_dtintegr,
                           pr_cdagenci => pr_cdagenci,
                           pr_cdbccxlt => pr_cdbccxlt,
                           pr_nrdolote => pr_nrlotfol);
          FETCH cr_craplot
            INTO rw_craplot;

          IF cr_craplot%NOTFOUND THEN
            --somente fechar cursor
            CLOSE cr_craplot;
          ELSE
            --  se encontrar gravar log
            vr_dscritic := gene0001.fn_busca_critica(59);
            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '|| vr_dscritic
                                                       ||' EMPRESA = '|| gene0002.fn_mask(pr_cdempsol,'99999')
                                                       ||' LOTE = '|| gene0002.fn_mask(pr_nrlotfol,'9.99999'));
            CLOSE cr_craplot;
            --retonar para o programa chamador com erro para obortar
            raise vr_exc_saida;
          END IF;

          -- Inserir lote
          BEGIN
            INSERT INTO CRAPLOT
                        ( dtmvtolt
                         ,cdagenci
                         ,cdbccxlt
                         ,nrdolote
                         ,tplotmov
                         ,cdcooper)
                  VALUES( pr_dtintegr -- dtmvtolt
                         ,pr_cdagenci -- cdagenci
                         ,pr_cdbccxlt -- cdbccxlt
                         ,pr_nrlotfol -- nrdolote
                         ,1           -- tplotmov
                         ,pr_cdcooper -- cdcooper
                         );

          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Não foi possivel inserir capa do lote(craplot)'
                             ||' cdcooper: '|| pr_cdcooper
                             ||' cdagenci: '|| pr_cdagenci
                             ||' cdbccxlt: '|| pr_cdbccxlt||' :'||SQLERRM;
              RAISE vr_exc_saida;
          END;

          -- Atualizar cadastro generico - NUMLOTEFOL
          BEGIN
            UPDATE craptab
               SET craptab.dstextab = '9'||GENE0002.fn_mask(SUBSTR(pr_nrlotfol,2),'99999')
             WHERE ROWID = rw_craptab.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Não foi possivel inserir Cadastro de tabelas genericas'
                             ||' cdacesso: NUMLOTEFOL'
                             ||' tpregist: '|| pr_cdempsol||' :'||SQLERRM;
              RAISE vr_exc_saida;
          END;


        END IF; --Fim pr_flgclote

        ------>>>> GERAR LOTE NUMLOTECOT <<<<-------
        /*  Lote do Credito de COTAS  */

        -- Buscar numero do lote na craptab
        OPEN cr_craptab (pr_cdcooper => pr_cdcooper,
                         pr_cdacesso => 'NUMLOTECOT',
                         pr_tpregist  => pr_cdempsol);
        FETCH cr_craptab
          INTO rw_craptab;

        IF cr_craptab%NOTFOUND THEN
          --se não encontrar, gravar log
          vr_dscritic := gene0001.fn_busca_critica(175);
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '|| vr_dscritic
                                                     ||' EMPRESA = '|| gene0002.fn_mask(pr_cdempsol,'99999'));
          CLOSE cr_craptab;
          --retonar para o programa chamador com erro para obortar
          raise vr_exc_saida;
        ELSE
          pr_nrlotcot := gene0002.fn_char_para_number(rw_craptab.dstextab);
          CLOSE cr_craptab;
        END IF;

        -- Verificar se deve gerar novo lote
        IF pr_flgclote   THEN
          pr_nrlotcot := nvl(pr_nrlotcot,0) + 1;

          -- Buscar lote
          OPEN cr_craplot (pr_cdcooper => pr_cdcooper,
                           pr_dtintegr => pr_dtintegr,
                           pr_cdagenci => pr_cdagenci,
                           pr_cdbccxlt => pr_cdbccxlt,
                           pr_nrdolote => pr_nrlotcot);
          FETCH cr_craplot
            INTO rw_craplot;

          IF cr_craplot%NOTFOUND THEN
            --somente fechar cursor
            CLOSE cr_craplot;
          ELSE
            --  se encontrar gravar log
            vr_dscritic := gene0001.fn_busca_critica(59);
            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '|| vr_dscritic
                                                       ||' EMPRESA = '|| gene0002.fn_mask(pr_cdempsol,'99999')
                                                       ||' LOTE = '|| gene0002.fn_mask(pr_nrlotcot,'9.99999'));
            CLOSE cr_craplot;
            --retonar para o programa chamador com erro para obortar
            raise vr_exc_saida;
          END IF;

          -- Inserir lote
          BEGIN
            INSERT INTO CRAPLOT
                        ( dtmvtolt
                         ,cdagenci
                         ,cdbccxlt
                         ,nrdolote
                         ,tplotmov
                         ,cdcooper)
                  VALUES( pr_dtintegr -- dtmvtolt
                         ,pr_cdagenci -- cdagenci
                         ,pr_cdbccxlt -- cdbccxlt
                         ,pr_nrlotcot -- nrdolote
                         ,3           -- tplotmov
                         ,pr_cdcooper -- cdcooper
                         );

          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Não foi possivel inserir capa do lote(craplot)'
                             ||' cdcooper: '|| pr_cdcooper
                             ||' cdagenci: '|| pr_cdagenci
                             ||' cdbccxlt: '|| pr_cdbccxlt||' :'||SQLERRM;
              RAISE vr_exc_saida;
          END;

          -- Atualizar cadastro generico - NUMLOTECOT
          BEGIN
            UPDATE craptab
               SET craptab.dstextab = '8'||GENE0002.fn_mask(SUBSTR(pr_nrlotcot,2),'99999')
             WHERE ROWID = rw_craptab.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Não foi possivel inserir Cadastro de tabelas genericas'
                             ||' cdacesso: NUMLOTECOT'
                             ||' tpregist: '|| pr_cdempsol||' :'||SQLERRM;
              RAISE vr_exc_saida;
          END;
        END IF; --Fim pr_flgclote

        ------>>>> GERAR LOTE NUMLOTEEMP <<<<-------
        /*  Lote do Credito de EMPRESTIMOS  */

        -- Buscar numero do lote na craptab
        OPEN cr_craptab (pr_cdcooper => pr_cdcooper,
                         pr_cdacesso => 'NUMLOTEEMP',
                         pr_tpregist => pr_cdempsol);
        FETCH cr_craptab
          INTO rw_craptab;

        IF cr_craptab%NOTFOUND THEN
          --se não encontrar, gravar log
          vr_dscritic := gene0001.fn_busca_critica(175);
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '|| vr_dscritic
                                                     ||' EMPRESA = '|| gene0002.fn_mask(pr_cdempsol,'99999'));
          CLOSE cr_craptab;
          --retonar para o programa chamador com erro para obortar
          raise vr_exc_saida;
        ELSE
          pr_nrlotemp := gene0002.fn_char_para_number(rw_craptab.dstextab);
          CLOSE cr_craptab;
        END IF;

        -- Verificar se deve gerar novo lote
        IF pr_flgclote   THEN
          pr_nrlotemp := nvl(pr_nrlotemp,0) + 1;

          -- Buscar lote
          OPEN cr_craplot (pr_cdcooper => pr_cdcooper,
                           pr_dtintegr => pr_dtintegr,
                           pr_cdagenci => pr_cdagenci,
                           pr_cdbccxlt => pr_cdbccxlt,
                           pr_nrdolote => pr_nrlotemp);
          FETCH cr_craplot
            INTO rw_craplot;

          IF cr_craplot%NOTFOUND THEN
            --somente fechar cursor
            CLOSE cr_craplot;
          ELSE
            --  se encontrar gravar log
            vr_dscritic := gene0001.fn_busca_critica(59);
            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '|| vr_dscritic
                                                       ||' EMPRESA = '|| gene0002.fn_mask(pr_cdempsol,'99999')
                                                       ||' LOTE = '|| gene0002.fn_mask(pr_nrlotemp,'9.99999'));
            CLOSE cr_craplot;
            --retonar para o programa chamador com erro para obortar
            raise vr_exc_saida;
          END IF;

          -- Inserir lote
          BEGIN
            INSERT INTO CRAPLOT
                        ( dtmvtolt
                         ,cdagenci
                         ,cdbccxlt
                         ,nrdolote
                         ,tplotmov
                         ,cdcooper)
                  VALUES( pr_dtintegr -- dtmvtolt
                         ,pr_cdagenci -- cdagenci
                         ,pr_cdbccxlt -- cdbccxlt
                         ,pr_nrlotemp -- nrdolote
                         ,5           -- tplotmov
                         ,pr_cdcooper -- cdcooper
                         );

          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Não foi possivel inserir capa do lote(craplot)'
                             ||' cdcooper: '|| pr_cdcooper
                             ||' cdagenci: '|| pr_cdagenci
                             ||' cdbccxlt: '|| pr_cdbccxlt||' :'||SQLERRM;
              RAISE vr_exc_saida;
          END;

          -- Atualizar cadastro generico - NUMLOTEEMP
          BEGIN
            UPDATE craptab
               SET craptab.dstextab = '5'||GENE0002.fn_mask(SUBSTR(pr_nrlotemp,2),'99999')
             WHERE ROWID = rw_craptab.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Não foi possivel inserir Cadastro de tabelas genericas'
                             ||' cdacesso: NUMLOTEEMP'
                             ||' tpregist: '|| pr_cdempsol||' :'||SQLERRM;
              RAISE vr_exc_saida;
          END;
        END IF; --Fim pr_flgclote

        pr_flgclote := FALSE;

      EXCEPTION
        WHEN vr_exc_saida THEN
          -- Se foi retornado apenas código
          IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
            -- Buscar a descrição
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          END IF;
          -- Devolvemos código e critica encontradas das variaveis locais
          pr_cdcritic := NVL(vr_cdcritic,0);
          pr_dscritic := vr_dscritic;
        WHEN OTHERS THEN
          -- Efetuar retorno do erro não tratado
          pr_cdcritic := 0;
          pr_dscritic := sqlerrm;

      END pc_carrega_lotes;


      -- Fazer leitura de avisos para atender aos programas
      PROCEDURE pc_leitura_avisos_debito(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                       ,pr_nrdconta IN crapass.nrdconta%type   --> Nr da conta do associado
                                       ,pr_dtrefere IN DATE                    --> Indicador de processo
                                       ,pr_lshstsau IN VARCHAR2                --> Lista de historicos de plano de saude
                                       ,pr_lshstfun IN VARCHAR2                --> lista de historicos de FUND - DEPEN BRADESCO
                                       ,pr_lshstdiv IN VARCHAR2                --> lista de historicos de diversos
                                       ,pr_tab_crapavs out typ_tab_crapavs) IS --> Retorna temp table com os avisos

      /* .............................................................................

       Programa: pc_leitura_avisos_debito     (Fontes/crps120_9.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Data    : Junho/97.                           Ultima atualizacao: 16/12/2013

       Dados referentes ao programa:

       Frequencia: Diario (Batch).
       Objetivo  : Fazer leitura de avisos para atender aos programas
                   crps120_3.p e crps129.p

       ATENCAO: SEMPRE QUE FOR ALTERADO COMPILE CRPS129 E CRPS120_3.

       Alteracoes: 22/09/97 - Alterado para passar o convenio 10 para peso 2 (Edson)

                   14/11/97 - Tratar convenios 18 e 19 peso 2 (Odair)

                   27/07/2001 - Tratar historico 341 - Seguro de Vida (Junior).

                   16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

                   16/12/2013 - - Conversao Progress >> Oracle PLSQL (Odirlei-AMcom)

      */

        -- Busca os avisos
        CURSOR cr_crapavs is
          SELECT crapavs.*,crapavs.rowid
            FROM crapavs
           WHERE crapavs.cdcooper = pr_cdcooper
             AND crapavs.nrdconta = pr_nrdconta
             AND crapavs.tpdaviso = 1
             AND crapavs.dtrefere = pr_dtrefere
             AND crapavs.insitavs = 0;

        vr_idx  varchar2(18);
        vr_cont number := 0;

      BEGIN
        -- Ler tabela de avisos
        FOR rw_crapavs in cr_crapavs LOOP
          vr_cont := vr_cont+1;

          --Definir ordenação conforme os historicos
          IF GENE0002.fn_existe_valor(pr_base      => pr_lshstsau         --> String que irá sofrer a busca
                                     ,pr_busca     => rw_crapavs.cdhistor --> String objeto de busca
                                     ,pr_delimite  => ',') = 'S' THEN     --> String que será o delimitador)
              vr_idx := '1';
          /*  Convenio 18 e 19  */
          ELSIF GENE0002.fn_existe_valor( pr_base      => pr_lshstfun         --> String que irá sofrer a busca
                                         ,pr_busca     => rw_crapavs.cdhistor --> String objeto de busca
                                         ,pr_delimite  => ',') = 'S' THEN     --> String que será o delimitador)
            vr_idx := '2';
          /*  Convenio 10 e 15  */
          ELSIF GENE0002.fn_existe_valor( pr_base      => pr_lshstdiv         --> String que irá sofrer a busca
                                         ,pr_busca     => rw_crapavs.cdhistor --> String objeto de busca
                                         ,pr_delimite  => ',') = 'S' THEN     --> String que será o delimitador)
            vr_idx := '3';
          ELSIF rw_crapavs.cdhistor = 108   THEN
             vr_idx := '4';
          ELSIF rw_crapavs.cdhistor = 127   THEN
             vr_idx := '7';
          ELSIF (rw_crapavs.cdhistor = 160   OR
                 rw_crapavs.cdhistor = 175   OR
                 rw_crapavs.cdhistor = 199   OR
                 rw_crapavs.cdhistor = 341)  THEN
            vr_idx := '8';
          ELSE
             vr_idx := '6';
          END IF;

          vr_idx := vr_idx||lpad(rw_crapavs.cdhistor,5,'0')
                          ||to_char(rw_crapavs.dtintegr,'RRRRMMDD')
                          ||lpad(vr_cont,4,'0');

          -- Inserir registro na temp table
          pr_tab_crapavs(vr_idx).dtmvtolt := rw_crapavs.dtmvtolt;
          pr_tab_crapavs(vr_idx).nrdconta := rw_crapavs.nrdconta;
          pr_tab_crapavs(vr_idx).nrdocmto := rw_crapavs.nrdocmto;
          pr_tab_crapavs(vr_idx).vllanmto := rw_crapavs.vllanmto;
          pr_tab_crapavs(vr_idx).tpdaviso := rw_crapavs.tpdaviso;
          pr_tab_crapavs(vr_idx).cdhistor := rw_crapavs.cdhistor;
          pr_tab_crapavs(vr_idx).dtdebito := rw_crapavs.dtdebito;
          pr_tab_crapavs(vr_idx).cdsecext := rw_crapavs.cdsecext;
          pr_tab_crapavs(vr_idx).cdempres := rw_crapavs.cdempres;
          pr_tab_crapavs(vr_idx).nrseqdig := rw_crapavs.nrseqdig;
          pr_tab_crapavs(vr_idx).insitavs := rw_crapavs.insitavs;
          pr_tab_crapavs(vr_idx).dtrefere := rw_crapavs.dtrefere;
          pr_tab_crapavs(vr_idx).vldebito := rw_crapavs.vldebito;
          pr_tab_crapavs(vr_idx).vlestdif := rw_crapavs.vlestdif;
          pr_tab_crapavs(vr_idx).cdagenci := rw_crapavs.cdagenci;
          pr_tab_crapavs(vr_idx).vlestour := rw_crapavs.vlestour;
          pr_tab_crapavs(vr_idx).dtintegr := rw_crapavs.dtintegr;
          pr_tab_crapavs(vr_idx).cdempcnv := rw_crapavs.cdempcnv;
          pr_tab_crapavs(vr_idx).nrconven := rw_crapavs.nrconven;
          pr_tab_crapavs(vr_idx).flgproce := rw_crapavs.flgproce;
          pr_tab_crapavs(vr_idx).cdcooper := rw_crapavs.cdcooper;
          pr_tab_crapavs(vr_idx).nrparepr := rw_crapavs.nrparepr;
          pr_tab_crapavs(vr_idx).rowidavs := rw_crapavs.rowid;
        END LOOP;

      END pc_leitura_avisos_debito;

      -- Processar os resumos da integracao.
      PROCEDURE pc_gera_resumo_integra(pr_cdcooper  IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                      ,pr_crapdat   IN BTCH0001.cr_crapdat%rowtype --> registos com os dados da crapdat
                                      ,pr_nmarquiv  IN varchar2                --> Nome do relatorio a ser gerado
                                      ,pr_lshstden  IN VARCHAR2                --> lista de historicos
                                      ,pr_cdempres  IN crapemp.cdempres%type   --> codigo do emprestimo
                                      ,pr_dsempres  IN varchar2                --> descrição do emprestimo
                                      ,pr_nrlotfol  IN craplot.nrdolote%type   --> numero de lote de integração de folha
                                      ,pr_nrlotemp  IN craplot.nrdolote%type   --> numero de lote de integração de emprestimo
                                      ,pr_nrlotcot  IN craplot.nrdolote%type   --> numero de lote de integração dos planos de capital
                                      ,pr_nrlotccs  IN craplot.nrdolote%type   --> numero de lote de integração Conta Salario
                                      ,pr_dtmvtolt  IN craplot.dtmvtolt%type   --> numero de lote de integração Conta Salario
                                      ,pr_dtintegr  IN DATE                    --> Data do movimento
                                      ,pr_qttarifa  IN NUMBER                  --> data de integração
                                      ,pr_qtdifeln OUT NUMBER                  --> Quantidade de rejeitados
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE   --> Critica encontrada
                                      ,pr_dscritic OUT VARCHAR2) IS            --> retorno da descrição da critica

      /* .............................................................................

       Programa: pc_gera_resumo_integra (Fontes/crps120_r.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Deborah/Edson
       Data    : Junho/95.                     Ultima atualizacao: 23/12/2013

       Dados referentes ao programa:

       Alteracoes: Frequencia: Sempre que for chamado pelo crps120.
       Objetivo  : Processar os resumos da integracao.

       Alteracao : 02/01/98  - Quando integrar arquivo zerado nao listar o anterior
                               (Odair)

                   16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

                   11/12/2006 - Verificar se eh Conta Salario - crapccs (Ze).

                   06/07/2011 - Zerar variavel glb_cdcritic apos segunda leitura
                                da tabela craprej (Diego).

                   01/10/2013 - Renomeado "aux_nmarqimp EXTENT" para "aux_nmarquiv",
                                pois aux_nmarqimp eh usado na impressao.i (Carlos)

                   23/12/2013 - - Conversao Progress >> Oracle PLSQL (Odirlei-AMcom)
      */

        -- Tratamento de erros
        vr_exc_saida  EXCEPTION;
        vr_cdcritic   PLS_INTEGER;
        vr_dscritic   VARCHAR2(4000);


        ------------------------------- CURSORES ---------------------------------
        -- Ler lotes
        CURSOR cr_craplot (pr_nrdolote craplot.nrdolote%type) IS
          SELECT qtcompln,
                 vlcompcr,
                 vlcompdb,
                 qtinfoln,
                 vlinfodb,
                 vlinfocr,
                 dtmvtolt,
                 cdagenci,
                 cdbccxlt,
                 nrdolote,
                 tplotmov
            FROM craplot
           WHERE craplot.cdcooper = pr_cdcooper
             AND craplot.dtmvtolt = pr_dtmvtolt
             AND craplot.cdagenci = vr_cdagenci
             AND craplot.cdbccxlt = vr_cdbccxlt
             AND craplot.nrdolote = pr_nrdolote;
        rw_craplot cr_craplot%rowtype;

        --Ler registos rejeitados
        CURSOR cr_craprej(pr_nrdolote craprej.nrdolote%type) IS
          SELECT  craprej.cdcritic
                 ,crapcri.dscritic
                 ,craprej.nrdconta
                 ,craprej.cdhistor
                 ,craprej.vllanmto
            FROM craprej,
                 crapcri
           WHERE craprej.cdcritic = crapcri.cdcritic
             AND craprej.cdcooper = pr_cdcooper
             AND craprej.dtmvtolt = pr_dtmvtolt
             AND craprej.cdagenci = vr_cdagenci
             AND craprej.cdbccxlt = vr_cdbccxlt
             AND craprej.nrdolote = pr_nrdolote
             AND craprej.cdempres = pr_cdempres
             AND craprej.tpintegr = 1
           ORDER BY craprej.dtmvtolt,
                    craprej.cdagenci,
                    craprej.cdbccxlt,
                    craprej.nrdolote,
                    craprej.cdempres,
                    craprej.tpintegr,
                    craprej.nrdconta;
        rw_craprej cr_craprej%rowtype;

        ------------------------------- VARIAVEIS -------------------------------
        -- Variaveis para exibição do relatorio
        vr_dsintegr VARCHAR2(500);
        vr_rel_qtdifeln NUMBER := 0;
        vr_rel_vldifedb NUMBER := 0;
        vr_rel_vldifecr NUMBER := 0;
        vr_rel_vltarifa NUMBER := 0;
        vr_rel_vlcobrar NUMBER := 0;

        -- Variavel para armazenar as informacos em XML
        vr_des_xml       clob;

        --Escrever no arquivo CLOB
        PROCEDURE pc_escreve_xml(pr_des_dados IN CLOB) IS
        BEGIN
          --Escrever no arquivo XML
          vr_des_xml := vr_des_xml||pr_des_dados;
        END;

      BEGIN
        ------------------------------------

        IF pr_lshstden is not null   THEN
          vr_dsintegr := 'CREDITO DE PAGAMENTO, DEBITO DE EMPRESTIMOS, CAPITAL E CONVENIOS';
        ELSE
          vr_dsintegr := 'CREDITO DE PAGAMENTO, DEBITO DE EMPRESTIMOS E CAPITAL';
        END IF;

        -- Inicializar o CLOB
        dbms_lob.createtemporary(vr_des_xml, true);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

        IF pr_nrlotfol = 0 THEN
          pc_escreve_xml('<integracao
                            dsintegr="'||vr_dsintegr||'"
                            dsempres="'||pr_dsempres||'"
                            dtmvtolt=""'||
                          ' cdagenci=""'||
                          ' cdbccxlt=""'||
                          ' nrdolote=""'||
                          ' tplotmov="" >');

          vr_rel_qtdifeln := 0;
          vr_rel_vldifedb := 0;
          vr_rel_vldifecr := 0;
        ELSE
          /*  Resumo da integracao da folha  */
          OPEN cr_craplot (pr_nrdolote => pr_nrlotfol);--Ler lote
          FETCH cr_craplot
            INTO rw_craplot;
          IF cr_craplot%NOTFOUND THEN
            vr_dscritic := gene0001.fn_busca_critica(60);
            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '|| vr_dscritic
                                                       ||' EMPRESA = '|| Pr_dsempres
                                                       ||' LOTE = '||gene0002.fn_mask(pr_nrlotfol,'9.999'));
            CLOSE cr_craplot;
            return; -- retornar para o programa chamador
          ELSE
            --apenas fechar o cursor
            CLOSE cr_craplot;
          END IF;

          vr_rel_qtdifeln := nvl(rw_craplot.qtcompln,0) - nvl(rw_craplot.qtinfoln,0);
          vr_rel_vldifedb := nvl(rw_craplot.vlcompdb,0) - nvl(rw_craplot.vlinfodb,0);
          vr_rel_vldifecr := nvl(rw_craplot.vlcompcr,0) - nvl(rw_craplot.vlinfocr,0);

          pc_escreve_xml('<integracao
                            dsintegr="'||vr_dsintegr||'"
                            dsempres="'||pr_dsempres||'"
                            dtmvtolt="'||to_char(rw_craplot.dtmvtolt,'DD/MM/RRRR')||'"
                            cdagenci="'||rw_craplot.cdagenci||'"
                            cdbccxlt="'||rw_craplot.cdbccxlt||'"
                            nrdolote="'||gene0002.fn_mask(rw_craplot.nrdolote,'zzz.zz9')||'"
                            tplotmov="'||lpad(rw_craplot.tplotmov,2,'0')||'"
                            idexbtar="S">');

        END IF;

        -- Buscar informacoes de valor de tarifa
        vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'USUARI'
                                                 ,pr_cdempres => pr_cdempres
                                                 ,pr_cdacesso => 'VLTARIF008'
                                                 ,pr_tpregist => 1);

        IF TRIM(vr_dstextab) is null THEN
           vr_rel_vltarifa := 0;
        ELSE
            vr_rel_vltarifa := to_number(TRIM(vr_dstextab));
        END IF;

        vr_rel_vlcobrar := pr_qttarifa * vr_rel_vltarifa;

        -- Ler os registros rejeitados
        FOR rw_craprej IN cr_craprej(pr_nrdolote => pr_nrlotfol) LOOP
          IF rw_craprej.cdcritic = 211 THEN
            rw_craprej.dscritic := rw_craprej.dscritic ||' URV do dia '||to_char(pr_dtintegr,'DD/MM/RRRR');
          END IF;

          -- Montar dados dos rejeitados
          pc_escreve_xml('<rejeitado>
                            <nrdconta>'||GENE0002.FN_MASK_CONTA(rw_craprej.nrdconta)||'</nrdconta>
                            <cdhistor>'||rw_craprej.cdhistor||'</cdhistor>
                            <vllanmto>'||rw_craprej.vllanmto||'</vllanmto>
                            <dscritic>'||rw_craprej.dscritic||'</dscritic>
                          </rejeitado>');

        END LOOP; /* Fim Loop cr_craprej --  Leitura dos rejeitados */

        IF pr_nrlotfol = 0 THEN
          --criar tag totalizadora em zerada, pois não tem numero de lote
          pc_escreve_xml('<total>
                             <qtinfoln>0</qtinfoln>
                             <vlinfodb>0</vlinfodb>
                             <vlinfocr>0</vlinfocr>
                             <qtcompln>0</qtcompln>
                             <vlcompdb>0</vlcompdb>
                             <vlcompcr>0</vlcompcr>
                             <qtdifeln>'||vr_rel_qtdifeln||'</qtdifeln>
                             <vldifedb>'||vr_rel_vldifedb||'</vldifedb>
                             <vldifecr>'||vr_rel_vldifecr||'</vldifecr>
                          </total>');
        ELSE
          -- criar tag totalizadora
          pc_escreve_xml('<total>
                             <qtinfoln>'||rw_craplot.qtinfoln||'</qtinfoln>
                             <vlinfodb>'||rw_craplot.vlinfodb||'</vlinfodb>
                             <vlinfocr>'||rw_craplot.vlinfocr||'</vlinfocr>
                             <qtcompln>'||rw_craplot.qtcompln||'</qtcompln>
                             <vlcompdb>'||rw_craplot.vlcompdb||'</vlcompdb>
                             <vlcompcr>'||rw_craplot.vlcompcr||'</vlcompcr>
                             <qtdifeln>'||vr_rel_qtdifeln||'</qtdifeln>
                             <vldifedb>'||vr_rel_vldifedb||'</vldifedb>
                             <vldifecr>'||vr_rel_vldifecr||'</vldifecr>
                          </total>');
        END IF;
        --Criar tag tarifa
        pc_escreve_xml('<tarifa>
                              <qttarifa>'||pr_qttarifa||'</qttarifa>
                              <vltarifa>'||vr_rel_vltarifa||'</vltarifa>
                              <vlcobrar>'||vr_rel_vlcobrar||'</vlcobrar>
                            </tarifa>');
        pc_escreve_xml('</integracao>');

        vr_cdcritic := 0;

        /*  Resumo da integra dos emprestimos  */
        OPEN cr_craplot (pr_nrdolote => pr_nrlotemp);--Ler lote
        FETCH cr_craplot
          INTO rw_craplot;
        IF cr_craplot%NOTFOUND THEN
          CLOSE cr_craplot;
        ELSE
          CLOSE cr_craplot;
          vr_rel_qtdifeln := nvl(rw_craplot.qtcompln,0) - nvl(rw_craplot.qtinfoln,0);
          vr_rel_vldifedb := nvl(rw_craplot.vlcompdb,0) - nvl(rw_craplot.vlinfodb,0);
          vr_rel_vldifecr := nvl(rw_craplot.vlcompcr,0) - nvl(rw_craplot.vlinfocr,0);

          vr_dsintegr := 'CREDITO DE EMPRESTIMOS';

          pc_escreve_xml('<integracao
                            dsintegr="'||vr_dsintegr||'"
                            dsempres="'||pr_dsempres||'"
                            dtmvtolt="'||to_char(rw_craplot.dtmvtolt,'DD/MM/RRRR')||'"
                            cdagenci="'||rw_craplot.cdagenci||'"
                            cdbccxlt="'||rw_craplot.cdbccxlt||'"
                            nrdolote="'||gene0002.fn_mask(rw_craplot.nrdolote,'zzz.zz9')||'"
                            tplotmov="'||lpad(rw_craplot.tplotmov,2,'0')||'"
                            idexbtar="N" >');

          -- criar tag totalizadora
          pc_escreve_xml('<total>
                            <qtinfoln>'||rw_craplot.qtinfoln||'</qtinfoln>
                            <vlinfodb>'||rw_craplot.vlinfodb||'</vlinfodb>
                            <vlinfocr>'||rw_craplot.vlinfocr||'</vlinfocr>
                            <qtcompln>'||rw_craplot.qtcompln||'</qtcompln>
                            <vlcompdb>'||rw_craplot.vlcompdb||'</vlcompdb>
                            <vlcompcr>'||rw_craplot.vlcompcr||'</vlcompcr>
                            <qtdifeln>'||vr_rel_qtdifeln||'</qtdifeln>
                            <vldifedb>'||vr_rel_vldifedb||'</vldifedb>
                            <vldifecr>'||vr_rel_vldifecr||'</vldifecr>
                          </total>');
          pc_escreve_xml('</integracao>');

        END IF;

        /*  Resumo da integra dos planos de capital  */
        OPEN cr_craplot (pr_nrdolote => pr_nrlotcot);--Ler lote
        FETCH cr_craplot
          INTO rw_craplot;
        IF cr_craplot%NOTFOUND THEN
          CLOSE cr_craplot;
        ELSE
          CLOSE cr_craplot;
          vr_rel_qtdifeln := nvl(rw_craplot.qtcompln,0) - nvl(rw_craplot.qtinfoln,0);
          vr_rel_vldifedb := nvl(rw_craplot.vlcompdb,0) - nvl(rw_craplot.vlinfodb,0);
          vr_rel_vldifecr := nvl(rw_craplot.vlcompcr,0) - nvl(rw_craplot.vlinfocr,0);

          vr_dsintegr := 'CREDITO DE CAPITAL';

          pc_escreve_xml('<integracao
                            dsintegr="'||vr_dsintegr||'"
                            dsempres="'||pr_dsempres||'"
                            dtmvtolt="'||to_char(rw_craplot.dtmvtolt,'DD/MM/RRRR')||'"
                            cdagenci="'||rw_craplot.cdagenci||'"
                            cdbccxlt="'||rw_craplot.cdbccxlt||'"
                            nrdolote="'||gene0002.fn_mask(rw_craplot.nrdolote,'zzz.zz9')||'"
                            tplotmov="'||lpad(rw_craplot.tplotmov,2,'0')||'"
                            idexbtar="N" >');

          -- criar tag totalizadora
          pc_escreve_xml('<total>
                            <qtinfoln>'||rw_craplot.qtinfoln||'</qtinfoln>
                            <vlinfodb>'||rw_craplot.vlinfodb||'</vlinfodb>
                            <vlinfocr>'||rw_craplot.vlinfocr||'</vlinfocr>
                            <qtcompln>'||rw_craplot.qtcompln||'</qtcompln>
                            <vlcompdb>'||rw_craplot.vlcompdb||'</vlcompdb>
                            <vlcompcr>'||rw_craplot.vlcompcr||'</vlcompcr>
                            <qtdifeln>'||vr_rel_qtdifeln||'</qtdifeln>
                            <vldifedb>'||vr_rel_vldifedb||'</vldifedb>
                            <vldifecr>'||vr_rel_vldifecr||'</vldifecr>
                          </total>');
          pc_escreve_xml('</integracao>');

        END IF;

        /*  Imprime Conta Salario  */
        OPEN cr_craplot (pr_nrdolote => pr_nrlotccs);--Ler lote
        FETCH cr_craplot
          INTO rw_craplot;
        IF cr_craplot%NOTFOUND THEN
          CLOSE cr_craplot;
        ELSE
          CLOSE cr_craplot;
          vr_rel_qtdifeln := nvl(rw_craplot.qtcompln,0) - nvl(rw_craplot.qtinfoln,0);
          vr_rel_vldifedb := nvl(rw_craplot.vlcompdb,0) - nvl(rw_craplot.vlinfodb,0);
          vr_rel_vldifecr := nvl(rw_craplot.vlcompcr,0) - nvl(rw_craplot.vlinfocr,0);

          vr_dsintegr := 'CREDITO DE CONTA SALARIO';

          pc_escreve_xml('<integracao
                            dsintegr="'||vr_dsintegr||'"
                            dsempres="'||pr_dsempres||'"
                            dtmvtolt="'||to_char(rw_craplot.dtmvtolt,'DD/MM/RRRR')||'"
                            cdagenci="'||rw_craplot.cdagenci||'"
                            cdbccxlt="'||rw_craplot.cdbccxlt||'"
                            nrdolote="'||gene0002.fn_mask(rw_craplot.nrdolote,'zzz.zz9')||'"
                            tplotmov="'||lpad(rw_craplot.tplotmov,2,'0')||'"
                            idexbtar="N" >');

          FOR rw_craprej IN cr_craprej(pr_nrdolote => pr_nrlotccs) LOOP

            pc_escreve_xml('<rejeitado>
                              <nrdconta>'||GENE0002.FN_MASK_CONTA(rw_craprej.nrdconta)||'</nrdconta>
                              <cdhistor>'||rw_craprej.cdhistor||'</cdhistor>
                              <vllanmto>'||rw_craprej.vllanmto||'</vllanmto>
                              <dscritic>'||rw_craprej.dscritic||'</dscritic>
                            </rejeitado>');

          END LOOP; /* Fim Loop cr_craprej --  Leitura dos rejeitados */

          -- criar tag totalizadora
          pc_escreve_xml('<total>
                            <qtinfoln>'||rw_craplot.qtinfoln||'</qtinfoln>
                            <vlinfodb>'||rw_craplot.vlinfodb||'</vlinfodb>
                            <vlinfocr>'||rw_craplot.vlinfocr||'</vlinfocr>
                            <qtcompln>'||rw_craplot.qtcompln||'</qtcompln>
                            <vlcompdb>'||rw_craplot.vlcompdb||'</vlcompdb>
                            <vlcompcr>'||rw_craplot.vlcompcr||'</vlcompcr>
                            <qtdifeln>'||vr_rel_qtdifeln||'</qtdifeln>
                            <vldifedb>'||vr_rel_vldifedb||'</vldifedb>
                            <vldifecr>'||vr_rel_vldifecr||'</vldifecr>
                          </total>');
          pc_escreve_xml('</integracao>');

        END IF;

        vr_des_xml    := '<?xml version="1.0" encoding="utf-8"?><crrl098>'||vr_des_xml||'</crrl098>';

        -- Solicitar impressao
        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                  ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                  ,pr_dtmvtolt  => pr_crapdat.dtmvtolt --> Data do movimento atual
                                  ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                  ,pr_dsxmlnode => '/crrl098/integracao'   --> No base do XML para leitura dos dados
                                  ,pr_dsjasper  => 'crrl098.jasper'    --> Arquivo de layout do iReport
                                  ,pr_dsparams  => null                --> Enviar como parametro apenas a agencia
                                  ,pr_dsarqsaid => pr_nmarquiv         --> Arquivo final com codigo da agencia
                                  ,pr_sqcabrel  => 1                   --> Sequencial do relatorio
                                  ,pr_qtcoluna  => 80                  --> 80 colunas
                                  ,pr_flg_impri => 'S'                 --> Chamar a impress?o (Imprim.p)
                                  ,pr_nmformul  => '80dh'              --> Nome do formulario para impress?o
                                  ,pr_nrcopias  => 1                   --> Numero de copias
                                  ,pr_dspathcop => vr_nom_direto||'/rlnsv/' --> diretorio de copia do arquivo
                                  ,pr_des_erro  => vr_dscritic);       --> Saida com erro

        IF vr_dscritic IS NOT NULL THEN
          -- somente gera log
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                      || vr_cdprogra || ' --> relatorio:'||pr_nmarquiv||' --> '
                                                      || vr_dscritic );
        END IF;

        -- Liberando a memoria alocada pro CLOB
        dbms_lob.freetemporary(vr_des_xml);

        -- Retornando quantidade de rejeitados
        pr_qtdifeln := vr_rel_qtdifeln;

        -----------------------------------
      EXCEPTION
        WHEN vr_exc_saida THEN
          -- Se foi retornado apenas código
          IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
            -- Buscar a descrição
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          END IF;
          -- Devolvemos código e critica encontradas das variaveis locais
          pr_cdcritic := NVL(vr_cdcritic,0);
          pr_dscritic := vr_dscritic;
        WHEN OTHERS THEN
          -- Efetuar retorno do erro não tratado
          pr_cdcritic := 0;
          pr_dscritic := sqlerrm;

      END pc_gera_resumo_integra;

      --Processar os debitos de emprestimos.
      PROCEDURE pc_integra_folha_pagto(pr_cdcooper   IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                      ,pr_cdoperad   IN crapope.cdoperad%TYPE   --> Codigo do operador
                                      ,pr_crapdat    IN btch0001.cr_crapdat%ROWTYPE --> rowtype com os dados ca crapdat
                                      ,pr_nmarquiv   IN VARCHAR2                --> nome do relatorio de criticas
                                      ,pr_nmarqint   IN VARCHAR2                --> arquivo a ser importado
                                      ,pr_inrestar   IN INTEGER                 --> Indicador de restart
                                      ,pr_dtrefere   IN DATE                    --> Data de referencia
                                      ,pr_inusatab   IN BOOLEAN                 --> Indicador se utiliza tabela de juros
                                      ,pr_cdempfol   IN NUMBER                  --> Codigo da empresa da folha
                                      ,pr_cdempsol   IN NUMBER                  --> Codigo da empresa solicitante
                                      ,pr_nrctares   IN NUMBER                  --> Numero de conta do restart
                                      ,pr_rowidres   IN ROWID                   --> Rowid do registro da tebela de restart
                                      ,pr_indmarca   IN INTEGER                 --> Indicador de marca do restart
                                      ,pr_dtintegr   IN DATE                    --> Data de integração
                                      ,pr_dsempres   IN VARCHAR2                --> Nome da empresa
                                      ,pr_flglotes IN OUT BOOLEAN               --> flag de controle de geração de lote
                                      ,pr_flgclote IN OUT BOOLEAN               --> flag se deve gerar lote
                                      ,pr_flgatual IN OUT BOOLEAN               --> Verificar se não é a viacredi
                                      ,pr_lshstsau IN crapcnv.lshistor%TYPE     --> Lista de historicos de plano de saude
                                      ,pr_lshstfun IN crapcnv.lshistor%TYPE     --> lista de historicos de FUND - DEPEN BRADESCO
                                      ,pr_lshstdiv IN crapcnv.lshistor%TYPE     --> Lista de historicos de diversos
                                      ,pr_qttarifa IN OUT NUMBER                --> Quantidade de tartifas
                                      ,pr_flignore OUT BOOLEAN                  --> Indicar se o arquivo deve ser ignorado
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE    --> Critica encontrada
                                      ,pr_dscritic OUT VARCHAR2) IS             --> Descriçao da critica

      /* .............................................................................

       Programa: pc_integra_folha_pagto (Fontes/crps120_3.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Deborah/Edson
       Data    : Maio/95.                        Ultima atualizacao: 06/0/2014

       Dados referentes ao programa:

       Frequencia: Diario (Batch).
       Objetivo  : Integrar folha de pagamento e debito de cotas e emprestimos.

       Alteracoes: 16/11/95 - Alterado para tratar debito do convenio DENTARIO para
                              a CEVAL JARAGUA DO SUL (Edson).

                   03/05/96 - Alterado para tratar debito da poupanca programada.

                   24/06/96 - Implementado o campo cdempfol (codigo da empresa no
                              sistema de folha das empresas) (Deborah).

                   07/08/96 - Alterado para tratar varios convenios de dentistas
                              (Edson).

                   18/11/96 - Alterado para excluir o crapfol correspondente ao
                              credito da folha do associado (Edson).

                   18/12/96 - Alterado para tratar aviso do debito de seguro de
                              casa (Edson).

                   14/01/97 - Alterado para tratar CPMF (Edson).

                   06/02/97 - Acertar tratamento da CPMF (Odair)

                   21/02/97 - Tratar seguro saude Bradesco e desmembrar a
                              includes/crps120.i para fontes/crps120_3.p para nao
                              estorar 63K (Odair).

                   18/03/97 - Dar pesos para data crapavs.dtintegr (Odair)

                   25/04/97 - Tratar historico do seguro AUTO (Edson).

                   19/05/97 - Alterar o peso do historico 127 para o mesmo peso
                              do historico 160 (Edson).

                   04/06/97 - Otimizacao da rotina de leitura do crapavs (Edson).

                   25/06/97 - Alterado para fazer includes na leitura do crapavs.
                              (Odair).

                   27/08/97 - Alterado para tratar crapavs.flgproce (Deborah).

                   06/10/97 - Nao lancar valor zerado (Odair).

                   16/02/98 - Alterar data final da CPMF (Odair)

                   27/04/98 - Tratamento para milenio e troca para V8 (Margarete).

                   09/11/98 - Tratar situacao em prejuizo (Deborah).

                   26/02/99 - Tratar associados empresa resima (Odair)

                   01/06/1999 - Tratar CPMF (Deborah).

                   23/10/2000 - Desmembrar a critica 95 conforme a situacao do
                                titular (Eduardo).

                   27/07/2001 - Tratar historico 341 - Seguro de Vida (Junior).

                   11/03/2003 - Tratar a seguinte situacao: primeiro debita em
                                c/c e depois debita via folha - o sistema fazia em
                                folha sempre o total, desconsiderando o que ja
                                tinha sido debitado em c/c - passou a considerar).

                   27/11/2003 - Tratamento para Cecrisa, para obter numero da conta
                                atraves do numero de cadastro(Mirtes)

                   08/04/2004 - Nao cobrava corretamente a prestacao quando
                                pagamento parcial (Margarete)
                                Alterado o formulario para 80col (Deborah).

                   07/05/2004 - Nao cobrava corretamente o emprestimo na conta
                                corrente quando pagamento parcial (Margarete).

                   07/07/2004 - Tratamento Contas Cecrisa (verificar se existem
                                Contas duplicadas e ATIVAS)(Mirtes)
                                Chamado 0800(Tarefa 1006)

                   29/06/2005 - Alimentado campo cdcooper das tabelas craprej
                                e craplcm (Diego).

                   16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

                   30/05/2006 - Criar crapfol quando for credito do salario (Julio)

                   30/08/2006 - Somente criar crapfol se for integracao de credito
                                de salario mensal (Julio)

                   11/12/2006 - Verificar se eh Conta Salario - crapccs (Ze).

                   20/12/2007 - Nao remover arquivo para o salvar antes de setar
                                a solicitacao como processada (Julio).

                   01/09/2008 - Alteracao CDEMPRES (Kbase).

                   22/07/2009 - Correcao no tratamento do campo cdempres (Diego).

                   10/08/2009 - Acerto na critica 775 (Diego).

                   29/02/2012 - Desprezado registros com valor zerado (Adriano).

                   28/08/2013 - Incluido a chamada da procedure "atualiza_desconto"
                                "atualiza_emprestimo" para os contratos que
                                nao ocorreram debito (James).

                   24/09/2013 - Retirada condicao para debito de cotas(127) devido
                                a mesma ja estar sendo feita dentro do programa
                                crps120_2 (Diego).

                   01/10/2013 - Possibilidade de imprimir o relatório direto da tela
                                SOL062, na hora da solicitacao (N) (Carlos)

                   09/10/2013 - Atribuido valor 0 no campo crapcyb.cdagenci (James)

                   14/11/2013 - Ajuste para nao atualizar as flag de judicial e
                                vip no cyber (James).

                   16/12/2013 - - Conversao Progress >> Oracle PLSQL (Odirlei-AMcom)

                   15/01/204 - Inclusao de VALIDDAE craprej, craplcm, crapfol,
                               craplot e craplcs (Carlos)

                   11/02/2014 - Remover a criacao do emprestimo no CYBER (James)

                   21/02/2014 - Replicação manutenção de 02/2014 (Odirlei-AMcom)
                   
                   06/06/2014 - Melhorias na estrutura do programa para que nas criticas
                              181,173,379 e de falta de arquivo, o processo na pare, mas
                              apenas critique no log e continue para o próximo arquivo
                              (Marcos-Supero)

      */
        -- Tratamento de erros
        vr_exc_saida  EXCEPTION;
        vr_exc_ignora EXCEPTION;
        vr_exc_fimprg EXCEPTION;
        vr_cdcritic   PLS_INTEGER;
        vr_cdcritic_l PLS_INTEGER;
        vr_dscritic   VARCHAR2(4000);

        ------------------------------- CURSORES ---------------------------------
        -- validar associados e titulares
        CURSOR cr_crapass1(pr_cdcooper crapcop.cdcooper%type,
                           pr_nrdconta crapass.nrdconta%type,
                           pr_cdempres crapttl.cdempres%type) IS
          SELECT crapass.nrdconta
            FROM crapass,
                 crapttl
           WHERE crapass.cdcooper = pr_cdcooper
             AND crapass.nrcadast = pr_nrdconta
             AND crapttl.cdcooper = pr_cdcooper
             AND crapttl.nrdconta = pr_nrdconta
             AND crapttl.nrdconta = crapass.nrdconta
             AND crapttl.cdcooper = crapass.cdcooper
             AND crapttl.idseqttl = 1
             AND crapttl.cdempres = pr_cdempres;
        rw_crapass1 cr_crapass1%rowtype;

        -- validar associados e titulares
        CURSOR cr_crapass2 (pr_cdcooper crapcop.cdcooper%type,
                            pr_nrdconta crapass.nrdconta%type,
                            pr_nrdconta_ass crapass.nrdconta%type,
                            pr_cdempres crapttl.cdempres%type) IS
          SELECT crapass.nrdconta
            FROM crapass,
                 crapttl
           WHERE crapass.cdcooper = pr_cdcooper
             AND crapass.nrcadast = pr_nrdconta
             AND crapass.nrdconta <> pr_nrdconta_ass
             AND crapass.cdsitdct <> 3
             AND crapttl.cdcooper = pr_cdcooper
             AND crapttl.nrdconta = pr_nrdconta_ass
             AND crapttl.cdcooper = crapass.cdcooper
             AND crapttl.idseqttl = 1
             AND crapttl.cdempres = pr_cdempres;
        rw_crapass2 cr_crapass2%rowtype;

        -- ler associados e titulares
        CURSOR cr_crapass(pr_cdcooper crapcop.cdcooper%type,
                          pr_nrdconta crapass.nrdconta%type) IS
          SELECT nrdconta,
                 inpessoa,
                 dtelimin,
                 cdsitdtl,
                 dtdemiss,
                 rowid
            FROM crapass
           WHERE crapass.cdcooper = pr_cdcooper
             AND crapass.nrdconta = pr_nrdconta;
        rw_crapass cr_crapass%rowtype;

        -- ler contas de funcionarios de empresas que optaram pela transferencia do salario
        -- para outra instituicao financeira.
        CURSOR cr_crapccs(pr_cdcooper crapcop.cdcooper%type,
                          pr_nrdconta crapass.nrdconta%type) IS
          SELECT nrdconta,
                 cdsitcta,
                 dtcantrf
            FROM crapccs
           WHERE crapccs.cdcooper = pr_cdcooper
             AND crapccs.nrdconta = pr_nrdconta;
        rw_crapccs cr_crapccs%rowtype;

        -- ler FIND FIRST da Transferencia e Duplicacao de Matricula
        CURSOR cr_craptrf (pr_cdcooper crapcop.cdcooper%type,
                           pr_nrdconta crapass.nrdconta%type) IS
          SELECT nrsconta
            FROM craptrf
           WHERE craptrf.cdcooper = pr_cdcooper
             AND craptrf.nrdconta = pr_nrdconta
             AND craptrf.tptransa = 1
             AND craptrf.insittrs = 2
           ORDER BY --USE-INDEX craptrf1
                    CDCOOPER,
                    NRDCONTA,
                    TPTRANSA,
                    NRSCONTA;
        rw_craptrf cr_craptrf%ROWTYPE;

        -- Buscar lote
        CURSOR cr_craplot (pr_cdcooper crapcop.cdcooper%type,
                           pr_dtintegr craplot.dtmvtolt%type,
                           pr_cdagenci crapage.cdagenci%type,
                           pr_cdbccxlt crapban.cdbccxlt%type,
                           pr_nrlotfol craplot.nrdolote%type
                           ) IS
          SELECT dtmvtolt,
                 cdagenci,
                 cdbccxlt,
                 nrdolote,
                 tplotmov,
                 qtinfoln,
                 vlinfocr,
                 nrseqdig,
                 rowid
            FROM craplot
           WHERE craplot.cdcooper = pr_cdcooper
             AND craplot.dtmvtolt = pr_dtintegr
             AND craplot.cdagenci = pr_cdagenci
             AND craplot.cdbccxlt = pr_cdbccxlt
             AND craplot.nrdolote = pr_nrlotfol
           ORDER BY-- USE-INDEX craplot1
                   CDCOOPER,
                   DTMVTOLT,
                   CDAGENCI,
                   CDBCCXLT,
                   NRDOLOTE;
        rw_craplot cr_craplot%rowtype;

        --Ler Lancamentos em depositos a vista
        CURSOR cr_craplcm (pr_cdcooper craplcm.cdcooper%type,
                           pr_nrdconta craplcm.nrdconta%type,
                           pr_dtmvtolt craplcm.dtmvtolt%type,
                           pr_cdhistor craplcm.cdhistor%type,
                           pr_nrdocmto craplcm.nrdocmto%type
                           ) IS
          SELECT nrdocmto
            FROM craplcm
           WHERE craplcm.cdcooper = pr_cdcooper
             AND craplcm.nrdconta = pr_nrdconta
             AND craplcm.dtmvtolt = pr_dtmvtolt
             AND craplcm.cdhistor = pr_cdhistor
             AND craplcm.nrdocmto = pr_nrdocmto;
        rw_craplcm cr_craplcm%rowtype;

        ------------------------------- VARIAVEIS -------------------------------
        --Datas de controle
        vr_dtinipmf	DATE;
        vr_dtfimpmf	DATE;
        vr_dtiniabo	date;
        vr_dtmvtoin DATE;

        --Valores de Taxas
        vr_txcpmfcc	number;
        vr_txrdcpmf	number;

        vr_indabono	number;

        vr_dirint   varchar2(500); -- Diretorio do arquivo de integracao
        vr_arqint   varchar2(500); -- Nome do arquivo de integracao

        vr_tpregist NUMBER;  -- Tipo de registro

        vr_cdempres crapsol.cdempres%type;
        vr_tpdebito NUMBER;
        vr_vldaurvs NUMBER;
        vr_nrseqint NUMBER;
        vr_vllanmto NUMBER;
        vr_nrlotfol NUMBER;
        vr_nrdoclot varchar2(10);
        vr_nrdocmto NUMBER;
        vr_cdhistor craphis.cdhistor%type;
        vr_nrdconta crapass.nrdconta%type;
        vr_nrcalcul crapass.nrdconta%type;
        vr_ant_nrdconta crapass.nrdconta%type;
        vr_cdempres_2   crapttl.cdempres%type;
        vr_nrseqdig     craplot.nrseqdig%type;
        vr_vlsalliq NUMBER;
        vr_vlpgempr NUMBER;
        vr_vldebtot NUMBER;
        vr_nrlotcot NUMBER;
        vr_nrlotemp NUMBER;
        vr_vldoipmf NUMBER;
        vr_vldebita NUMBER;
        vr_qtdifeln number;
        vr_nrlotccs craplot.nrdolote%type;


        --Handle do arquivo
        vr_utlfileh    UTL_FILE.file_type;
        vr_deslinha    VARCHAR2(4000);

        -- Variaveis de controle
        vr_flfirst2     boolean;
        vr_flgfirst     BOOLEAN := TRUE;
        vr_flgsomar     NUMBER;
        vr_flgctsal     BOOLEAN;
        vr_flgdente     BOOLEAN;

        --Temp table para leitura dos campos da linha do arquivo txt
        vr_tab_campos   gene0002.typ_split;

        --Variaveis para armazenar os totais
        vr_tot_vlsalliq NUMBER := 0;
        vr_tot_vldebemp NUMBER := 0;
        vr_tot_vldebsau NUMBER := 0;
        vr_tot_vldebcot NUMBER := 0;
        vr_tot_vldebden NUMBER := 0;
        vr_tot_vlhstsau NUMBER := 0;   /* Valor individual do historico */
        --Type contendo os registros da crapavs
        vr_tab_crapavs typ_tab_crapavs;
        vridx    VARCHAR2(18);

        --Temp table para agrupar os totais de debito de conta
        vr_tab_tot_vldebcta typ_tab_tot_vldebcta;
        -----------------------

      BEGIN
        ------------------------------------
        -- Procedimento padrão de busca de informações de CPMF
        gene0005.pc_busca_cpmf(pr_cdcooper  => pr_cdcooper
                              ,pr_dtmvtolt  => pr_crapdat.dtmvtolt
                              ,pr_dtinipmf  => vr_dtinipmf
                              ,pr_dtfimpmf  => vr_dtfimpmf
                              ,pr_txcpmfcc  => vr_txcpmfcc
                              ,pr_txrdcpmf  => vr_txrdcpmf
                              ,pr_indabono  => vr_indabono
                              ,pr_dtiniabo  => vr_dtiniabo
                              ,pr_cdcritic  => vr_cdcritic
                              ,pr_dscritic  => vr_dscritic);
        -- Se retornou erro
        IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
          -- Gerar raise
          vr_cdcritic := 0;
          RAISE vr_exc_saida;
        END IF;

        vr_flfirst2 := TRUE;

        -- Verificar se o arquivo existe
        IF NOT gene0001.fn_exis_arquivo(pr_caminho => pr_nmarqint) THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Arquivo '||pr_nmarqint||' não localizado!';
          RAISE vr_exc_ignora;
        END IF;

        --quebrar nome arquivo
        gene0001.pc_separa_arquivo_path(pr_caminho => pr_nmarqint,
                                        pr_direto  => vr_dirint,
                                        pr_arquivo => vr_arqint);


        /*  Leitura do arquivo com os liquidos de pagamento  */
        gene0001.pc_abre_arquivo(pr_nmdireto => vr_dirint  --> Diretorio do arquivo
                                ,pr_nmarquiv => vr_arqint --> Nome do arquivo
                                ,pr_tipabert => 'R'            --> Modo de abertura (R,W,A)
                                ,pr_utlfileh => vr_utlfileh    --> Handle do arquivo aberto
                                ,pr_des_erro => vr_dscritic);

        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_ignora;
        END IF;

        --iniciar leitura do arquivo
        LOOP
          BEGIN
            IF vr_flgfirst THEN
              IF pr_inrestar = 0   THEN

                vr_dscritic := gene0001.fn_busca_critica(219);
                -- Envio centralizado de log de erro
                btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                          ,pr_ind_tipo_log => 2 -- Erro tratato
                                          ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                           || vr_cdprogra || ' --> '
                                                           || vr_dscritic || ' --> '|| pr_nmarqint );
                vr_dscritic := 0;

                --ler linha
                gene0001.pc_le_linha_arquivo( pr_utlfileh => vr_utlfileh
                                            , pr_des_text => vr_deslinha);

                -- Retirar quebra de linha, para não gerar erros posteriormente ao qubrar a linha
                vr_deslinha := REPLACE(REPLACE(vr_deslinha,CHR(10)),CHR(13));

                -- tratar linha
                vr_tab_campos := gene0002.fn_quebra_string( pr_string  => vr_deslinha
                                                           ,pr_delimit => ' ');

                /*  Registro de controle  */
                IF vr_tab_campos.EXISTS(1) THEN
                  vr_tpregist := vr_tab_campos(1);
                END IF;
                IF vr_tab_campos.EXISTS(2) THEN
                  vr_dtmvtoin := TO_DATE(vr_tab_campos(2),'DDMMRRRR');
                END IF;
                IF vr_tab_campos.EXISTS(3) THEN
                  vr_cdempres := TRIM(REPLACE(vr_tab_campos(3),chr(09)));
                END IF;
                /*IF vr_tab_campos.EXISTS(4) THEN
                  vr_tpdebito := vr_tab_campos(4);
                END IF;*/
                IF vr_tab_campos.EXISTS(5) THEN
                  vr_vldaurvs := vr_tab_campos(5);
                END IF;

                /* Coloca sempre tipo de debito 1 (moeda corrente) */
                vr_tpdebito := 1;

                /* Validar arquivo */
                IF vr_tpregist <> 1 THEN
                  vr_cdcritic := 181;
                ELSIF vr_dtmvtoin <> pr_dtrefere OR vr_cdempres <> pr_cdempfol THEN
                  vr_cdcritic := 173;
                ELSIF vr_tpdebito NOT IN ('1','2') THEN
                  vr_cdcritic := 379;
                END IF;

                -- Se houve critica
                IF vr_cdcritic > 0 THEN
                  -- Ignorar o arquivo
                  raise vr_exc_ignora;
                END IF;
                
                -- Indica que não é mais o primeiro arquivo
                vr_flgfirst := FALSE;
                vr_cdempres := pr_cdempsol;

              ELSE /* pr_inrestar <> 0 */
                --ler linha
                gene0001.pc_le_linha_arquivo( pr_utlfileh => vr_utlfileh
                                            , pr_des_text => vr_deslinha);

                -- Retirar quebra de linha, para não gerar erros posteriormente ao qubrar a linha
                vr_deslinha := REPLACE(REPLACE(vr_deslinha,CHR(10)),CHR(13));

                --tratar linha
                vr_tab_campos := gene0002.fn_quebra_string( pr_string  => vr_deslinha
                                                           ,pr_delimit => ' ');

                /*  Registro de controle  */
                IF vr_tab_campos.EXISTS(1) THEN
                  vr_cdempres := vr_tab_campos(1);
                END IF;
                /*IF vr_tab_campos.EXISTS(2) THEN
                  vr_tpdebito := vr_tab_campos(2);
                END IF;*/
                IF vr_tab_campos.EXISTS(3) THEN
                  vr_vldaurvs := vr_tab_campos(3);
                END IF;

                vr_tpdebito := 1;

                -- Ler linhas até encontrar o registro do restart
                WHILE vr_nrseqint <> pr_nrctares LOOP
                  --Ler linha
                  gene0001.pc_le_linha_arquivo( pr_utlfileh => vr_utlfileh
                                                , pr_des_text => vr_deslinha);

                  -- Retirar quebra de linha, para não gerar erros posteriormente ao qubrar a linha
                  vr_deslinha := REPLACE(REPLACE(vr_deslinha,CHR(10)),CHR(13));

                  --tratar linha
                  vr_tab_campos := gene0002.fn_quebra_string( pr_string  => vr_deslinha
                                                             ,pr_delimit => ' ');
                  --Ler informações
                  IF vr_tab_campos.EXISTS(1) THEN
                    vr_tpregist := vr_tab_campos(1);
                  END IF;
                  IF vr_tab_campos.EXISTS(2) THEN
                    vr_nrseqint := vr_tab_campos(2);
                  END IF;
                  IF vr_tab_campos.EXISTS(3) THEN
                    vr_nrdconta := vr_tab_campos(3);
                  END IF;
                END LOOP; -- Fim loop restart(nrctares)

                IF vr_tpregist = 9 THEN
                  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_utlfileh);
                  EXIT;
                END IF;

                vr_flgfirst := FALSE;
                vr_cdempres := pr_cdempsol;

              END IF; --Fim pr_inrestar
            END IF; -- Fim vr_flgfirst

            --ler linha
            gene0001.pc_le_linha_arquivo( pr_utlfileh => vr_utlfileh
                                        , pr_des_text => vr_deslinha);

            -- Retirar quebra de linha, para não gerar erros posteriormente ao qubrar a linha
            vr_deslinha := REPLACE(REPLACE(REPLACE(vr_deslinha,CHR(09),CHR(32)),CHR(10)),CHR(13));

            --tratar linha
            vr_tab_campos := gene0002.fn_quebra_string( pr_string  => vr_deslinha
                                                       ,pr_delimit => ' ');

            --zerar tabela de cota
            vr_tab_tot_vldebcta.delete;  

            /*  Registro de informações  */
            IF vr_tab_campos.EXISTS(1) THEN
              vr_tpregist := vr_tab_campos(1);
            END IF;
            IF vr_tab_campos.EXISTS(2) THEN
              vr_nrseqint := vr_tab_campos(2);
            END IF;
            IF vr_tab_campos.EXISTS(3) THEN
              vr_nrdconta := vr_tab_campos(3);
            END IF;
            IF vr_tab_campos.EXISTS(4) THEN
              vr_vllanmto := vr_tab_campos(4);
            END IF;
            IF vr_tab_campos.EXISTS(5) THEN
              vr_cdhistor := vr_tab_campos(5);
            END IF;
            IF vr_tpregist = 9 OR
              vr_nrdconta = 99999999 THEN
              EXIT;
            END IF;

            IF vr_vllanmto = 0 THEN /*Ignora registro com valor zerado*/
              CONTINUE;
            END IF;

            /*  Verifica se deve somar o fator salarial  */
            IF vr_nrdconta = vr_ant_nrdconta THEN
              vr_flgsomar := 1; --TRUE
            ELSE
              vr_flgsomar := 0; --FALSE
              vr_ant_nrdconta := vr_nrdconta;
              pr_qttarifa := nvl(pr_qttarifa,0) + 1;
            END IF;

            /*--------------Alteracao Numero da Conta - Cecrisa ----*/
            IF pr_cdcooper = 5 THEN
              IF vr_cdempres in (1,2,3,5,6,7,8,15) THEN

                -- buscar associado
                OPEN cr_crapass1(pr_cdcooper => pr_cdcooper,
                                 pr_nrdconta => vr_nrdconta,
                                 pr_cdempres => vr_cdempres);
                FETCH cr_crapass1
                  INTO rw_crapass1;
                IF cr_crapass1%NOTFOUND THEN
                  -- 009 - Associado nao cadastrado.
                  vr_cdcritic := 9;
                  close cr_crapass1;
                ELSE
                  close cr_crapass1;
                  -- Verificar Mais de uma conta por Associado
                  OPEN cr_crapass2(pr_cdcooper => pr_cdcooper,
                                   pr_nrdconta => vr_nrdconta,
                                   pr_nrdconta_ass => rw_crapass1.nrdconta,
                                   pr_cdempres => vr_cdempres);
                  FETCH cr_crapass2
                    INTO rw_crapass2;
                  IF cr_crapass2%NOTFOUND THEN
                    close cr_crapass2;
                    vr_nrdconta := rw_crapass1.nrdconta;
                  ELSE
                    close cr_crapass2;
                    vr_cdcritic := 775; /*+ de 1 cont p/ass*/
                  END IF;
                END IF;

              END IF; --Fim vr_cdempres in (1,2,3,5,6,7,8,15)
            END IF;

            vr_flgctsal := FALSE;

            -- buscar associado
            OPEN cr_crapass( pr_cdcooper => pr_cdcooper,
                             pr_nrdconta => vr_nrdconta);
            FETCH cr_crapass
              INTO rw_crapass;
            --se não localizar procurar na crapccs
            IF cr_crapass%NOTFOUND THEN
              --conta funcionario, transferencia
              OPEN cr_crapccs( pr_cdcooper => pr_cdcooper,
                               pr_nrdconta => vr_nrdconta);
              FETCH cr_crapccs
                INTO rw_crapccs;
              IF cr_crapccs%NOTFOUND THEN

                vr_nrcalcul := vr_nrdconta;
                IF NOT GENE0005.fn_calc_digito(pr_nrcalcul => vr_nrcalcul) THEN
                  vr_cdcritic := 8;
                ELSE
                  vr_cdcritic := 9;
                END IF;
                CLOSE cr_crapccs;
              ELSE

                --Gerar lotes e lançamentos
                pc_trata_crapccs( pr_cdcooper => pr_cdcooper,   --> codigo da cooperativa
                                  pr_cdoperad => pr_cdoperad,   --> Codigo do operador logado
                                  pr_nrseqint => vr_nrseqint,   --> numero do documento
                                  pr_dtintegr => pr_dtintegr,   --> data de integraçã
                                  pr_cdsitcta => rw_crapccs.cdsitcta,   --> codigo da situação da conta
                                  pr_dtcantrf => rw_crapccs.dtcantrf,   --> Data de cancelamento da transferencia.
                                  pr_nrlotccs => vr_nrlotccs,   --> numero do lote
                                  pr_flfirst2 => vr_flfirst2,   --> flag para ocntrolar primeiro
                                  pr_vllanmto => vr_vllanmto,   --> valor do lancamento
                                  pr_cdhistor => vr_cdhistor,   --> codigo do historico
                                  pr_nrdconta => vr_nrdconta,   --> numero da conta
                                  pr_cdempsol => pr_cdempsol,   --> codigo do emprestimo
                                  pr_rowidres => pr_rowidres,   --> rowid da crapres para atualizar restart
                                  pr_cdcritic => vr_cdcritic,  --> Critica encontrada
                                  pr_dscritic => vr_dscritic);
                -- caso retornar alguma critica, gerar exception
                IF vr_dscritic IS NOT NULL OR
                   vr_cdcritic > 0  THEN
                  RAISE vr_exc_saida;
                END IF;

                vr_flgctsal := TRUE;
                close cr_crapccs;

              END IF;
              CLOSE cr_crapass;
            ELSE
              --Buscar codigo da empresa da pessoa fisica ou juridica
              vr_cdempres_2 := fn_trata_cdempres (pr_cdcooper => pr_cdcooper ,
                                                  pr_inpessoa => rw_crapass.inpessoa,
                                                  pr_nrdconta => rw_crapass.nrdconta);
                                                  
              -- Se o codigo da empresa do associado for diferente da empresa sa solicitação
              IF vr_cdempres_2 <> pr_cdempsol   THEN
                --verificar se a empresa do associado é 80-APOSENTADOS
                                                     -- 81-EMPRESAS DIVERSAS
                                                     -- 99-CIA HERING - ADMINISTRACAO
                -- ou se a empresa solicitante é 31 - COMERCIO E INDUSTRIA RESIMA S/A ou BLUMENAU FIOS
                IF NOT( LPAD(vr_cdempres_2,5,'0') in ('00080','00081','00099') AND pr_cdempsol in (31,90) )THEN
                   vr_cdcritic := 174; -- 174 - Associado nao eh desta empresa.
                END IF;
              ELSIF rw_crapass.dtelimin is not null THEN
                vr_cdcritic := 410; -- 410 - Associado excluido.
              ELSIF rw_crapass.cdsitdtl IN  (5,6,7,8)  THEN
                vr_cdcritic := 695; -- 695 - ATENCAO! Houve prejuizo nessa conta
              ELSIF rw_crapass.cdsitdtl IN (2,4,6,8)  THEN
                --Find first Transferencia e Duplicacao de Matricula
                OPEN cr_craptrf( pr_cdcooper => pr_cdcooper,
                                 pr_nrdconta => vr_nrdconta);
                FETCH cr_craptrf
                  INTO rw_craptrf;
                IF cr_craptrf%NOTFOUND THEN
                  CLOSE cr_craptrf;
                  vr_cdcritic := 95; -- 095 - Titular da conta bloqueado.
                ELSE
                  vr_nrdconta := rw_craptrf.nrsconta;
                  CLOSE cr_craptrf;
                END IF;
              END IF;
              CLOSE cr_crapass;
            END IF;

            IF vr_flgctsal THEN
              continue;
            END IF;
            
            -- Se ainda não foram criados os lotes
            IF pr_flglotes THEN
              -- Leitura e criacao dos lotes utilizados.
              pc_carrega_lotes(pr_cdcooper => pr_cdcooper  --> Cooperativa solicitada
                              ,pr_cdempsol => pr_cdempsol  --> codigo da empresa solicitante
                              ,pr_flgclote => pr_flgclote /*aux_flgclote se for 0 é true senão false*/
                              ,pr_dtintegr => pr_dtintegr  --> Data da integraça~p
                              ,pr_cdagenci => vr_cdagenci  --> Codigo da agencia
                              ,pr_cdbccxlt => vr_cdbccxlt  --> codigo do banco
                              ,pr_nrlotfol => vr_nrlotfol  --> Numero do lote da folha
                              ,pr_nrlotcot => vr_nrlotcot  --> Numero do lote da cota
                              ,pr_nrlotemp => vr_nrlotemp  --> Numero de lote de  emprestimo
                              ,pr_cdcritic => vr_cdcritic_l  --> Critica encontrada (usei outra var pra não perder o conteudo da anterior)
                              ,pr_dscritic => vr_dscritic);
              IF vr_cdcritic_l IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_saida;
              END IF;
              -- Indica que não é mais necessário criar os lotes
              pr_flglotes := FALSE;

            END IF;

            --Ler lote
            OPEN cr_craplot( pr_cdcooper => pr_cdcooper,
                             pr_dtintegr => pr_dtintegr,
                             pr_cdagenci => vr_cdagenci,
                             pr_cdbccxlt => vr_cdbccxlt,
                             pr_nrlotfol => vr_nrlotfol);
            FETCH cr_craplot
              INTO rw_craplot;
            IF cr_craplot%NOTFOUND THEN
              CLOSE cr_craplot;
              vr_cdcritic := 60;
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
              -- Envio centralizado de log de erro
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 2 -- Erro tratato
                                        ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                         || vr_cdprogra || ' --> '
                                                         || vr_dscritic ||' EMPRESA = '|| gene0002.fn_mask(pr_cdempsol,'99999')
                                                                        ||' LOTE = '|| gene0002.fn_mask(vr_nrlotfol,'9.999'));
              RAISE vr_exc_saida;
            ELSE
              CLOSE cr_craplot;
            END IF;

            vr_nrdoclot := SUBSTR(lpad(vr_nrlotfol,6,'0'),2,5);
            vr_nrdocmto := TO_NUMBER(vr_nrdoclot || lpad(vr_nrseqint,5,'0'));

            -- Ler lancamento avista
            OPEN cr_craplcm( pr_cdcooper => pr_cdcooper,
                             pr_nrdconta => vr_nrdconta,
                             pr_dtmvtolt => rw_craplot.dtmvtolt,
                             pr_cdhistor => vr_cdhistor,
                             pr_nrdocmto => vr_nrdocmto);
            FETCH cr_craplcm
              INTO rw_craplcm;
            IF cr_craplcm%NOTFOUND THEN
              --Somente fechar
              CLOSE cr_craplcm;
            ELSE
              -- se localizar algum registro.. gerar log
              vr_cdcritic := 285;
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
              -- Envio centralizado de log de erro
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 2 -- Erro tratato
                                        ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                         || vr_cdprogra || ' --> '
                                                         || vr_dscritic ||' EMPRESA = '|| gene0002.fn_mask(pr_cdempsol,'99999')
                                                                        ||' LOTE = '|| gene0002.fn_mask(vr_nrlotfol,'9.999'));
              CLOSE cr_craplcm;
            END IF;

            IF vr_cdcritic > 0   THEN
              --Gravar rejeitado
              BEGIN
                INSERT INTO craprej
                            (  dtmvtolt
                              ,cdagenci
                              ,cdbccxlt
                              ,nrdolote
                              ,tplotmov
                              ,nrdconta
                              ,cdempres
                              ,cdhistor
                              ,vllanmto
                              ,cdcritic
                              ,tpintegr
                              ,cdcooper)
                     VALUES (  pr_dtintegr         -- dtmvtolt
                              ,rw_craplot.cdagenci -- cdagenci
                              ,rw_craplot.cdbccxlt -- cdbccxlt
                              ,rw_craplot.nrdolote -- nrdolote
                              ,rw_craplot.tplotmov -- tplotmov
                              ,vr_nrdconta         -- nrdconta
                              ,pr_cdempsol         -- cdempres
                              ,vr_cdhistor         -- cdhistor
                              ,vr_vllanmto         -- vllanmto
                              ,vr_cdcritic         -- cdcritic
                              ,1                   -- tpintegr
                              ,pr_cdcooper);       -- cdcooper
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Não foi possivel inserir rejeitados(CRAPREJ)'
                                 ||' CTA: '|| gene0002.fn_mask_conta(vr_nrdconta)
                                 ||' cdcritic: '|| vr_cdcritic||' :'||SQLERRM;
                  RAISE vr_exc_saida;
              END;

              -- Atualizar lote
              BEGIN
                UPDATE craplot
                   SET craplot.qtinfoln = NVL(craplot.qtinfoln,0) + 1,
                       craplot.vlinfocr = craplot.vlinfocr + vr_vllanmto
                 WHERE rowid = rw_craplot.rowid;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Não foi possivel atualizar lote(CRAPLOT)'
                                 ||' nrdolote: '|| rw_craplot.nrdolote
                                 ||' dtmvtolt: '|| to_char(rw_craplot.dtmvtolt,'DD/MM/RRRR')||' :'||SQLERRM;
                  RAISE vr_exc_saida;
              END;

              vr_cdcritic := 0;
            ELSE
              IF vr_vllanmto > 0 THEN
                 /*  Credito do liquido de pagamento  */
                BEGIN
                  INSERT INTO craplcm
                              (   dtmvtolt
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,nrdolote
                                 ,nrdconta
                                 ,nrdctabb
                                 ,nrdctitg
                                 ,nrdocmto
                                 ,cdhistor
                                 ,vllanmto
                                 ,nrseqdig
                                 ,cdcooper)
                       VALUES (   rw_craplot.dtmvtolt -- dtmvtolt
                                 ,rw_craplot.cdagenci -- cdagenci
                                 ,rw_craplot.cdbccxlt -- cdbccxlt
                                 ,rw_craplot.nrdolote -- nrdolote
                                 ,vr_nrdconta         -- nrdconta
                                 ,vr_nrdconta         -- nrdctabb
                                 ,gene0002.fn_mask(vr_nrdconta,'99999999') -- nrdctitg
                                 ,vr_nrdocmto         -- nrdocmto
                                 ,vr_cdhistor         -- cdhistor
                                 ,vr_vllanmto         -- vllanmto
                                 ,rw_craplot.nrseqdig + 1 -- nrseqdig
                                 ,pr_cdcooper)        -- cdcooper
                        returning nrseqdig into vr_nrseqdig;
                        
                  folh0001.pc_inserir_lanaut(pr_cdcooper => pr_cdcooper
                                            ,pr_nrdconta => vr_nrdconta
                                            ,pr_dtmvtolt => rw_craplot.dtmvtolt
                                            ,pr_cdhistor => vr_cdhistor
                                            ,pr_vlrenda =>  vr_vllanmto
                                            ,pr_cdagenci => rw_craplot.cdagenci
                                            ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                            ,pr_nrdolote => rw_craplot.nrdolote
                                            ,pr_nrseqdig => vr_nrseqdig
                                            ,pr_dscritic => vr_dscritic);
                                            
                  IF vr_dscritic IS NOT NULL THEN 
                     vr_dscritic := 'Não foi possivel inserir lançamento(craplcm/tbfolha_lanaut)'
                                   ||' CTA: '|| gene0002.fn_mask_conta(vr_nrdconta)
                                   ||' cdhistor: '|| vr_cdhistor
                                   ||' nrdocmto: '|| vr_nrdocmto||' :'||SQLERRM;
                    RAISE vr_exc_saida;                  
                  END IF;                                               
                  
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Não foi possivel inserir lançamento(craplcm)'
                                   ||' CTA: '|| gene0002.fn_mask_conta(vr_nrdconta)
                                   ||' cdhistor: '|| vr_cdhistor
                                   ||' nrdocmto: '|| vr_nrdocmto||' :'||SQLERRM;
                    RAISE vr_exc_saida;
                END;

                -- Atualizar lote
                BEGIN
                  UPDATE craplot
                     SET craplot.qtinfoln = NVL(craplot.qtinfoln,0) + 1,
                         craplot.qtcompln = NVL(craplot.qtcompln,0) + 1,
                         craplot.vlinfocr = NVL(craplot.vlinfocr,0) + nvl(vr_vllanmto,0),
                         craplot.vlcompcr = NVL(craplot.vlcompcr,0) + nvl(vr_vllanmto,0),
                         craplot.nrseqdig = vr_nrseqdig
                   WHERE rowid = rw_craplot.rowid;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Não foi possivel atualizar lote(CRAPLOT)'
                                   ||' nrdolote: '|| rw_craplot.nrdolote
                                   ||' dtmvtolt: '|| to_char(rw_craplot.dtmvtolt,'DD/MM/RRRR')||' :'||SQLERRM;
                    RAISE vr_exc_saida;
                END;

              END IF;

              IF pr_dtrefere = pr_crapdat.dtultdma   OR /* Somente criar crapfol*/
                 pr_dtrefere = pr_crapdat.dtultdia   THEN /* se for folha mensal*/
                 -- Gravar Cadastro com os valores de credito de cheque salario.
                 BEGIN
                   INSERT INTO crapfol
                               (  cdcooper
                                 ,cdempres
                                 ,nrdconta
                                 ,dtrefere
                                 ,vllanmto)
                        VALUES (  pr_cdcooper -- cdcooper
                                 ,vr_cdempres -- cdempres
                                 ,vr_nrdconta -- nrdconta
                                 ,pr_dtrefere -- dtrefere
                                 ,vr_vllanmto -- vllanmto
                                 );
                 EXCEPTION
                   -- se já existir atualiar valor
                   WHEN DUP_VAL_ON_INDEX THEN
                     BEGIN
                       UPDATE crapfol
                          SET crapfol.vllanmto = vr_vllanmto
                        WHERE crapfol.cdcooper = pr_cdcooper
                          AND crapfol.cdempres = vr_cdempres
                          AND crapfol.nrdconta = vr_nrdconta
                          AND crapfol.dtrefere = pr_dtrefere;
                     EXCEPTION
                       WHEN OTHERS THEN
                         vr_dscritic := 'Não foi possivel atualizar crapfol'
                                   ||' cdempres: '|| vr_cdempres
                                   ||' nrdconta: '|| vr_nrdconta||' :'||SQLERRM;
                         RAISE vr_exc_saida;
                     END;
                   WHEN OTHERS THEN
                     vr_dscritic := 'Não foi possivel inserir crapfol'
                                   ||' cdempres: '|| vr_cdempres
                                   ||' nrdconta: '|| vr_nrdconta||' :'||SQLERRM;
                     RAISE vr_exc_saida;
                 END;
              END IF;

              vr_tot_vlsalliq := vr_vllanmto;
              vr_tot_vldebemp := 0;
              vr_tot_vldebsau := 0;
              vr_tot_vldebcot := 0;
              vr_tot_vldebden := 0;
              --vr_tot_vldebcta := 0;
              vr_tot_vlhstsau := 0;   /* Valor individual do historico */
              vr_flgdente := TRUE;

              /*  Atualiza o fator salarial  */
              IF pr_flgatual   THEN
                BEGIN
                  UPDATE crapass
                     SET crapass.dtedvmto = Pr_dtrefere,
                         crapass.vledvmto = (CASE vr_flgsomar
                                               -- verificar se deve somar ao valor ou somente atualizar
                                               WHEN  0 /* false */ THEN
                                                 apli0001.fn_round((vr_vllanmto * 1.15) * 0.30,2)
                                               ELSE
                                                 crapass.vledvmto + apli0001.fn_round((vr_vllanmto * 1.15) * 0.30,2)
                                             END)
                  WHERE ROWID = rw_crapass.rowid;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Não foi possivel atualizar associado(crapass)'
                                   ||' nrdconta: '|| rw_crapass.nrdconta||' :'||SQLERRM;
                    RAISE vr_exc_saida;
                END;
              END IF;

              IF vr_cdhistor = 8 THEN
                /*  Leitura dos avisos de debitos  */
                pc_leitura_avisos_debito(pr_cdcooper => pr_cdcooper  --> Cooperativa solicitada
                                        ,pr_nrdconta => vr_nrdconta  --> Nr da conta do associado
                                        ,pr_dtrefere => pr_dtrefere  --> Indicador de processo
                                        ,pr_lshstsau => pr_lshstsau
                                        ,pr_lshstfun => pr_lshstfun
                                        ,pr_lshstdiv => pr_lshstdiv
                                        ,pr_tab_crapavs => vr_tab_crapavs);
                IF vr_tab_crapavs.COUNT > 0 THEN
                  --Varrer cursor crapavs
                  vridx := vr_tab_crapavs.first;
                  LOOP
                    EXIT WHEN vridx IS NULL;

                      /*  Emprestimos  */
                      IF vr_tab_crapavs(vridx).cdhistor = 108 THEN
                        vr_vlsalliq := TRUNC(vr_txrdcpmf * vr_tot_vlsalliq,2);
                        vr_vlpgempr := vr_tab_crapavs(vridx).vllanmto - vr_tab_crapavs(vridx).vldebito;
                        vr_vldebtot := 0;

                        IF vr_vlsalliq > 0 THEN
                          pc_crps120_1 ( pr_cdcooper => pr_cdcooper  --> Cooperativa solicitada
                                        ,pr_cdprogra => vr_cdprogra  --Codigo do programa chamador
                                        ,pr_cdoperad => pr_cdoperad  --> codigo do operador
                                        ,pr_crapdat  => pr_crapdat   --> type contendo as informações da crapdat
                                        ,pr_nrdconta => vr_tab_crapavs(vridx).nrdconta   --> Nr da conta do associado
                                        ,pr_nrctremp => vr_tab_crapavs(vridx).nrdocmto   --> Nr do emprestimo
                                        ,pr_nrdolote => vr_nrlotemp   --> Nr do lote do emprestimo
                                        ,pr_inusatab => pr_inusatab   --> Indicador se deve utilizar a tabela de jutos
                                        ,pr_vldaviso => vr_vlpgempr   --> Valor de aviso
                                        ,pr_vlsalliq => vr_vlsalliq   --> Valor de saldo liquido
                                        ,pr_dtintegr => pr_dtintegr   --> Data de integração
                                        ,pr_cdhistor => 95            --> Cod do historico
                                        --OUT
                                        ,pr_insitavs => vr_tab_crapavs(vridx).insitavs --> Retorna situação do aviso
                                        ,pr_vldebito => vr_vldebtot                    --> Retorna do valor debito
                                        ,pr_vlestdif => vr_tab_crapavs(vridx).vlestdif --> Retorna valor de estouro ou diferença
                                        ,pr_flgproce => vr_tab_crapavs(vridx).flgproce --> Retorna indicativo de processamento
                                        ,pr_cdcritic => vr_cdcritic                    --> Critica encontrada
                                        ,pr_dscritic => vr_dscritic);                  --> Texto de erro/critica encontrada

                          -- Se retornar critica, deve abortar
                          IF vr_cdcritic > 0 OR
                             vr_dscritic IS NOT NULL THEN
                             RAISE vr_exc_saida;
                          END IF;

                          --Atualizar CRAPAVS
                          BEGIN
                            UPDATE crapavs
                               SET crapavs.insitavs = vr_tab_crapavs(vridx).insitavs,
                                   crapavs.vlestdif = vr_tab_crapavs(vridx).vlestdif,
                                   crapavs.flgproce = vr_tab_crapavs(vridx).flgproce,
                                   crapavs.vldebito = nvl(crapavs.vldebito,0) + nvl(vr_vldebtot,0)
                             WHERE rowid =  vr_tab_crapavs(vridx).rowidavs;
                          EXCEPTION
                            WHEN OTHERS THEN
                              vr_dscritic := 'Não foi possivel atualizar aviso de debito em conta corrente.(crapavs)'
                                             ||' nrdconta: '|| vr_tab_crapavs(vridx).nrdconta
                                             ||' nrdocmto: '|| vr_tab_crapavs(vridx).nrdocmto||' :'||SQLERRM;
                              RAISE vr_exc_saida;
                          END;

                          -- somar historico PREST.EMPREST
                          IF vr_tab_tot_vldebcta.exists('108') THEN
                            vr_tab_tot_vldebcta('108') := vr_tab_tot_vldebcta('108') + nvl(vr_vldebtot,0);
                          ELSE
                            vr_tab_tot_vldebcta('108') := nvl(vr_vldebtot,0);
                          END IF;

                          vr_tot_vlsalliq := nvl(vr_tot_vlsalliq,0) -
                                             TRUNC((1 + nvl(vr_txcpmfcc,0)) * nvl(vr_vldebtot,0),2);

                        END IF;

                      ELSIF vr_tab_crapavs(vridx).cdhistor = 127   THEN /*  Planos de capital  */
                        IF vr_tot_vlsalliq >= 0 THEN

                           --Processar os debitos dos planos de capital (Cotas).
                           pc_crps120_2(pr_cdcooper => pr_cdcooper                    --> Cooperativa solicitada
                                       ,pr_cdprogra => vr_cdprogra                    --> Codigo do programa chamador
                                       ,pr_crapdat  => pr_crapdat                     --> type contendo as informações da crapdat
                                       ,pr_nrdconta => vr_tab_crapavs(vridx).nrdconta --> Nr da conta do associado
                                       ,pr_nrdolote => vr_nrlotcot                    --> Nr do lote do emprestimo
                                       ,pr_vldaviso => vr_tab_crapavs(vridx).vllanmto --> Valor do aviso
                                       ,pr_vlsalliq => vr_tot_vlsalliq                --> Valor do saldo liquido
                                       ,pr_dtintegr => pr_dtintegr                    --> Data de integração
                                       ,pr_cdhistor => 75                             --> Cod do historico
                                       -- OUT
                                       ,pr_insitavs => vr_tab_crapavs(vridx).insitavs --> Retorna indicador do aviso
                                       ,pr_vldebito => vr_tab_crapavs(vridx).vldebito --> Retorno do valor debito
                                       ,pr_vlestdif => vr_tab_crapavs(vridx).vlestdif --> retorna valor de estorno ou diferença
                                       ,pr_vldoipmf => vr_vldoipmf                    -->
                                       ,pr_flgproce => vr_tab_crapavs(vridx).flgproce --> retonrno indicativo de processamento
                                       ,pr_cdcritic => vr_cdcritic                    --> Critica encontrada
                                       ,pr_dscritic => vr_dscritic);

                          -- Se retornar critica, deve abortar
                          IF vr_cdcritic > 0 OR
                             vr_dscritic IS NOT NULL THEN
                             RAISE vr_exc_saida;
                          END IF;
                          --Atualizar CRAPAVS
                          BEGIN
                            UPDATE crapavs
                               SET crapavs.insitavs = vr_tab_crapavs(vridx).insitavs,
                                   crapavs.vlestdif = vr_tab_crapavs(vridx).vlestdif,
                                   crapavs.flgproce = vr_tab_crapavs(vridx).flgproce,
                                   crapavs.vldebito = vr_tab_crapavs(vridx).vldebito
                             WHERE rowid =  vr_tab_crapavs(vridx).rowidavs;
                          EXCEPTION
                            WHEN OTHERS THEN
                              vr_dscritic := 'Não foi possivel atualizar aviso de debito em conta corrente.(crapavs)'
                                             ||' nrdconta: '|| vr_tab_crapavs(vridx).nrdconta
                                             ||' nrdocmto: '|| vr_tab_crapavs(vridx).nrdocmto||' :'||SQLERRM;
                              RAISE vr_exc_saida;
                          END;

                          /* Se efetuou o debito */
                          -- somar historico DB. COTAS
                          IF vr_tab_tot_vldebcta.exists('127') THEN
                            vr_tab_tot_vldebcta('127') := vr_tab_tot_vldebcta('127') + nvl( vr_tab_crapavs(vridx).vldebito,0);
                          ELSE
                            vr_tab_tot_vldebcta('127') := nvl( vr_tab_crapavs(vridx).vldebito,0);
                          END IF;
                          vr_tot_vlsalliq := vr_tot_vlsalliq - vr_tab_crapavs(vridx).vldebito + vr_vldoipmf;

                        END IF; -- vr_tot_vlsalliq >= 0

                      ELSIF  (vr_tab_crapavs(vridx).cdhistor = 160   OR   /*  P. Programada  */
                              vr_tab_crapavs(vridx).cdhistor = 175   OR   /*  Seguro Casa    */
                              vr_tab_crapavs(vridx).cdhistor = 199   OR   /*  Seguro Auto    */
                              vr_tab_crapavs(vridx).cdhistor = 341)  THEN /*  Seguro Vida    */

                        -- Atualizar aviso de debito
                        BEGIN
                          UPDATE crapavs
                                 SET crapavs.insitavs = 1,
                                     crapavs.vldebito = vr_tab_crapavs(vridx).vllanmto,
                                     crapavs.vlestdif = 0,
                                     crapavs.flgproce = 1 --TRUE
                               WHERE rowid =  vr_tab_crapavs(vridx).rowidavs;
                        EXCEPTION
                          WHEN OTHERS THEN
                            vr_dscritic := 'Não foi possivel atualizar aviso de debito em conta corrente.(crapavs)'
                                           ||' nrdconta: '|| vr_tab_crapavs(vridx).nrdconta
                                           ||' nrdocmto: '|| vr_tab_crapavs(vridx).nrdocmto||' :'||SQLERRM;
                            RAISE vr_exc_saida;
                        END;

                      ELSE/*  Demais historicos  */
                        vr_vldebita := nvl(vr_tab_crapavs(vridx).vllanmto,0) - nvl(vr_tab_crapavs(vridx).vldebito,0);

                        IF nvl(vr_tot_vlsalliq,0) >= TRUNC((1 + vr_txcpmfcc) * vr_vldebita,2) THEN                      
                          -- Atualizar aviso de debito
                          BEGIN
                            UPDATE crapavs
                                   SET crapavs.insitavs = 1,
                                       crapavs.vldebito = vr_tab_crapavs(vridx).vllanmto,
                                       crapavs.vlestdif = 0,
                                       crapavs.flgproce = 1 --TRUE
                                 WHERE rowid =  vr_tab_crapavs(vridx).rowidavs;
                          EXCEPTION
                            WHEN OTHERS THEN
                              vr_dscritic := 'Não foi possivel atualizar aviso de debito em conta corrente.(crapavs)'
                                             ||' nrdconta: '|| vr_tab_crapavs(vridx).nrdconta
                                             ||' nrdocmto: '|| vr_tab_crapavs(vridx).nrdocmto||' :'||SQLERRM;
                              RAISE vr_exc_saida;
                          END;

                          -- somar historico
                          IF vr_tab_tot_vldebcta.exists(vr_tab_crapavs(vridx).cdhistor) THEN
                            vr_tab_tot_vldebcta(vr_tab_crapavs(vridx).cdhistor) := vr_tab_tot_vldebcta(vr_tab_crapavs(vridx).cdhistor) + nvl( vr_vldebita,0);
                          ELSE
                            vr_tab_tot_vldebcta(vr_tab_crapavs(vridx).cdhistor) := nvl(vr_vldebita,0);
                          END IF;
                          vr_tot_vlsalliq := nvl(vr_tot_vlsalliq,0) - Trunc((1 + nvl(vr_txcpmfcc,0)) * nvl(vr_vldebita,0),2);
                        END IF; -- Fim cdhist
                      END IF;

                      IF vr_tab_crapavs(vridx).vldebito = 0   AND
                         vr_tab_crapavs(vridx).insitavs = 0   THEN
                        -- Atualizar valor de estouro/diferença aviso de debito
                        BEGIN
                          UPDATE crapavs
                                 SET crapavs.vlestdif = crapavs.vllanmto * -1
                               WHERE rowid =  vr_tab_crapavs(vridx).rowidavs;
                        EXCEPTION
                          WHEN OTHERS THEN
                            vr_dscritic := 'Não foi possivel atualizar aviso de debito em conta corrente.(crapavs)'
                                           ||' nrdconta: '|| vr_tab_crapavs(vridx).nrdconta
                                           ||' nrdocmto: '|| vr_tab_crapavs(vridx).nrdocmto||' :'||SQLERRM;
                            RAISE vr_exc_saida;
                        END;
                      END IF;

                    -- Buscar proximo registro
                    vridx := vr_tab_crapavs.next(vridx);
                  END LOOP; /*  Fim do loop -- Leitura dos avisos  */
                END IF; -- vr_tab_crapavs.COUNT > 0

                /*  Efetua os lancamentos de empréstimo  */
                pc_debita_emprestimo(pr_cdcooper     => pr_cdcooper    --> Cooperativa solicitada
                                    ,pr_nrdconta     => vr_nrdconta    --> Número da conta do associado
                                    ,pr_cdempres     => vr_cdempres    --> Codigo da empresa
                                    ,pr_tab_vldebcta => vr_tab_tot_vldebcta  --> Temptable dos Valores por historico
                                    ,pr_nrlotfol     => vr_nrlotfol    --> Nr do lote do emprestimo
                                    ,pr_dtintegr     => pr_dtintegr    --> Data da integração
                                    ,pr_cdcritic     => vr_cdcritic    --> Critica encontrada
                                    ,pr_dscritic     => vr_dscritic);
                IF vr_cdcritic > 0 or vr_dscritic is not null THEN
                  RAISE vr_exc_saida;
                END IF;

              END IF; --vr_cdhist = 8
            END IF;  --Fim vr_cdcritic > 0

            -- Atualizar a tabela de restart
            BEGIN
              UPDATE crapres res
                 SET res.nrdconta = vr_nrseqint             -- conta
                    ,res.dsrestar = lpad(pr_qttarifa,6,'0')||' '||lpad(pr_indmarca,1,'0')
               WHERE res.rowid = pr_rowidres;
            EXCEPTION
              WHEN OTHERS THEN
                -- Gerar erro e fazer rollback
                vr_dscritic := 'Erro ao atualizar a tabela de Restart (CRAPRES) - Conta:'||vr_nrseqint
                            ||' dsrestar:'||lpad(pr_qttarifa,6,'0')||' '||lpad(pr_indmarca,1,'0')||'. Detalhes: '||sqlerrm;
                RAISE vr_exc_saida;
            END;

          EXCEPTION
            WHEN vr_exc_ignora THEN
              -- Fechar o arquivo e levantar a exceção para o bloco superior
              IF utl_file.is_open(vr_utlfileh) THEN
                gene0001.pc_fecha_arquivo(pr_utlfileh => vr_utlfileh);
              END IF;  
              raise vr_exc_ignora;
            WHEN NO_DATA_FOUND THEN
              -- se apresentou erro de no_data_found é pq terminou as linhas do arquivo,
              -- somente fechar arquivo e sair do loop
              IF utl_file.is_open(vr_utlfileh) THEN
                gene0001.pc_fecha_arquivo(pr_utlfileh => vr_utlfileh);
              END IF;  
              EXIT;
            WHEN vr_exc_saida THEN
              -- Fechar o arquivo e levantar a exceção para o bloco superior
              IF utl_file.is_open(vr_utlfileh) THEN
                gene0001.pc_fecha_arquivo(pr_utlfileh => vr_utlfileh);
              END IF;  
              raise vr_exc_saida;
            WHEN OTHERS THEN
              -- Fechar o arquivo, montar exceção não tratada
              -- e levantar a exceção para o bloco superior
              IF utl_file.is_open(vr_utlfileh) THEN
                gene0001.pc_fecha_arquivo(pr_utlfileh => vr_utlfileh);
              END IF;  
              vr_dscritic := 'Erro não tratado no processoamento do arquivo: '||sqlerrm;
              raise vr_exc_ignora;   
          END;
        END LOOP;--Fim leitura do arquivo
        -- Se não houve nenhuma critica
        IF nvl(vr_cdcritic,0) = 0  THEN
          --Processar os resumos da integracao.
          pc_gera_resumo_integra(pr_cdcooper  => pr_cdcooper  --> Cooperativa solicitada
                                ,pr_crapdat   => pr_crapdat   --> registos com os dados da crapdat
                                ,pr_nmarquiv  => pr_nmarquiv  --> Nome do relatorio a ser gerado
                                ,pr_lshstden  => vr_lshstden  --> lista de historicos
                                ,pr_cdempres  => vr_cdempres  --> codigo do emprestimo
                                ,pr_dsempres  => pr_dsempres  --> descrição do emprestimo
                                ,pr_nrlotfol  => vr_nrlotfol  --> numero de lote de integração de folha
                                ,pr_nrlotemp  => vr_nrlotemp  --> numero de lote de integração de emprestimo
                                ,pr_nrlotcot  => vr_nrlotcot  --> numero de lote de integração dos planos de capital
                                ,pr_nrlotccs  => vr_nrlotccs  --> numero de lote de integração Conta Salario
                                ,pr_dtmvtolt  => pr_dtintegr  --> numero de lote de integração Conta Salario
                                ,pr_dtintegr  => pr_dtintegr  --> Data do movimento
                                ,pr_qttarifa  => pr_qttarifa  --> data de integração
                                ,pr_qtdifeln  => vr_qtdifeln  --> Rejeitados
                                ,pr_cdcritic  => vr_cdcritic  --> Critica encontrada
                                ,pr_dscritic  => pr_dscritic);--> retorno da descrição da critica
          IF vr_cdcritic > 0   THEN
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '|| vr_dscritic );            
            raise vr_exc_saida;
          END IF;

          IF vr_qtdifeln = 0 THEN
            vr_cdcritic := 190;
          ELSE
            vr_cdcritic := 191;
          END IF;

          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '|| vr_dscritic
                                                       ||' --> '|| pr_nmarqint);
          /*  Exclui rejeitados apos a impressao  */
          BEGIN
            DELETE craprej
             WHERE craprej.cdcooper = pr_cdcooper
               AND craprej.dtmvtolt = pr_dtintegr
               AND craprej.cdagenci = vr_cdagenci
               AND craprej.cdbccxlt = vr_cdbccxlt
               AND craprej.nrdolote = vr_nrlotfol
               AND craprej.cdempres = pr_cdempsol
               AND craprej.tpintegr = 1;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Não foi possivel eliminar rejeitados(craprej)'
                             ||' nrdconta: '|| vr_tab_crapavs(vridx).nrdconta
                             ||' nrdocmto: '|| vr_tab_crapavs(vridx).nrdocmto||' :'||SQLERRM;
              RAISE vr_exc_saida;
          END;

          -- Atualizar a tabela de restart
          BEGIN
            UPDATE crapres res
               SET res.nrdconta = 0    -- conta
                  ,res.dsrestar = ' '
             WHERE res.rowid = pr_rowidres;
          EXCEPTION
            WHEN OTHERS THEN
              -- Gerar erro e fazer rollback
              vr_dscritic := 'Erro ao atualizar a tabela de Restart (CRAPRES) - Conta:'||vr_nrseqint
                          ||' dsrestar:'||lpad(pr_qttarifa,6,'0')||' '||lpad(pr_indmarca,1,'0')||'. Detalhes: '||sqlerrm;
              RAISE vr_exc_saida;
          END;
          vr_cdcritic := 0;
        END IF; /*  Fim da impressao do relatorio  */

        -----------------------------------
      EXCEPTION
        WHEN vr_exc_ignora THEN
          -- Se foi enviada uma critica no código
          IF vr_cdcritic > 0 THEN
            -- Apenas escreve no log e ignora o arquivo
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          END IF;
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '|| vr_dscritic
                                                     ||' EMPRESA = '||gene0002.fn_mask(pr_cdempsol,'99999'))  ;
          -- Indicar que o arquivo foi ignorado
          pr_flignore := TRUE;
        WHEN vr_exc_saida THEN
          -- Se foi retornado apenas código
          IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
            -- Buscar a descrição
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          END IF;
          -- Devolvemos código e critica encontradas das variaveis locais
          pr_cdcritic := NVL(vr_cdcritic,0);
          pr_dscritic := vr_dscritic;
        WHEN OTHERS THEN
          -- Efetuar retorno do erro não tratado
          pr_cdcritic := 0;
          pr_dscritic := sqlerrm;
      END pc_integra_folha_pagto;

    BEGIN

      --------------- VALIDACOES INICIAIS -----------------

      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop;
      FETCH cr_crapcop
       INTO rw_crapcop;
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Validações iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);
      -- Se a variavel de erro é <> 0
      IF vr_cdcritic <> 0 THEN
        -- Envio centralizado de log de erro
        RAISE vr_exc_saida;
      END IF;

      -- Tratamento e retorno de valores de restart
      btch0001.pc_valida_restart(pr_cdcooper  => pr_cdcooper   --> Cooperativa conectada
                                ,pr_cdprogra  => vr_cdprogra   --> Código do programa
                                ,pr_flgresta  => pr_flgresta   --> Indicador de restart
                                ,pr_nrctares  => vr_nrctares   --> Número da conta de restart
                                ,pr_dsrestar  => vr_dsrestar   --> String genérica com informações para restart
                                ,pr_inrestar  => vr_inrestar   --> Indicador de Restart
                                ,pr_cdcritic  => vr_cdcritic   --> Código de erro
                                ,pr_des_erro  => vr_dscritic); --> Saída de erro
      -- Se encontrou erro, gerar exceção
      IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      -- Se houver indicador de restart, mas não veio conta
      IF vr_inrestar > 0 AND vr_nrctares = 0  THEN
        -- Remover o indicador
        vr_inrestar := 0;
        vr_qttarifa := 0;
        vr_indmarca := 0;
      ELSE
        vr_qttarifa := to_number(SUBSTR(vr_dsrestar,1,6));
        vr_indmarca := to_number(SUBSTR(vr_dsrestar,8,1));
      END IF;

      -- Somente se a flag de restart estiver ativa
      IF pr_flgresta = 1 THEN
        -- Buscar as informações para restart e Rowid para atualização posterior
        OPEN cr_crapres;
        FETCH cr_crapres
         INTO rw_crapres;
        -- Se não tiver encontrador
        IF cr_crapres%NOTFOUND THEN
          -- Fechar o cursor e gerar erro
          CLOSE cr_crapres;
          -- Montar mensagem de critica
          vr_cdcritic := 151;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          RAISE vr_exc_saida;
        ELSE
          -- Apenas fechar o cursor para continuar
          CLOSE cr_crapres;
        END IF;
      END IF;

      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
      
      vr_regexist := FALSE;
      IF rw_crapdat.inproces > 2 THEN
        vr_dtintegr := rw_crapdat.dtmvtopr;
      ELSIF rw_crapdat.inproces = 1 THEN
        vr_dtintegr := rw_crapdat.dtmvtolt;
      ELSE
        vr_dtintegr := NULL;
      END IF;

      -- Senão conseguiu gerar a data de integração deve abortar
      IF vr_dtintegr is null  THEN
        vr_cdcritic := 138;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '|| vr_dscritic );

        --retonar para o programa chamador
        RETURN;
      END IF;

      /*  Leitura do indicador de uso da tabela de taxa de juros  */
      vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'TAXATABELA'
                                               ,pr_tpregist => 0);

      IF vr_dstextab is null THEN
        vr_inusatab := FALSE;
      ELSE
        IF SUBSTR(vr_dstextab,1,1) = '0' THEN
          vr_inusatab := FALSE;
        ELSE
          vr_inusatab := TRUE;
        END IF;
      END IF;

      /*  Historicos do convenio 14 - Plano de saude Bradesco ..................... */
      OPEN cr_crapcnv (pr_nrconven => 14);
      FETCH cr_crapcnv
        INTO rw_crapcnv;
      IF cr_crapcnv%NOTFOUND THEN
        vr_lshstsau := NULL;
        CLOSE cr_crapcnv;
      ELSE
        vr_lshstsau := TRIM(rw_crapcnv.lshistor);
        CLOSE cr_crapcnv;
      END IF;

      /*  Historicos do convenio 10 Hering .................. */
      OPEN cr_crapcnv (pr_nrconven => 10);
      FETCH cr_crapcnv
        INTO rw_crapcnv;
      IF cr_crapcnv%NOTFOUND THEN
        vr_lshstdiv := NULL;
        CLOSE cr_crapcnv;
      ELSE
        vr_lshstdiv := TRIM(rw_crapcnv.lshistor);
        CLOSE cr_crapcnv;
      END IF;
      /*  Historicos do convenio 15 ADM diversos ............. */
      OPEN cr_crapcnv (pr_nrconven => 15);
      FETCH cr_crapcnv
        INTO rw_crapcnv;
      IF cr_crapcnv%NOTFOUND THEN
        CLOSE cr_crapcnv;
      ELSE
        IF TRIM(rw_crapcnv.lshistor) <> vr_lshstdiv   THEN
          vr_lshstdiv := vr_lshstdiv ||','|| TRIM(rw_crapcnv.lshistor);
        END IF;
        CLOSE cr_crapcnv;
      END IF;

      /*  Historicos do convenio 18 e 19 - FUND - DEPEN BRADESCO HERING .......... */
      OPEN cr_crapcnv (pr_nrconven => 18);
      FETCH cr_crapcnv
        INTO rw_crapcnv;
      IF cr_crapcnv%NOTFOUND THEN
        vr_lshstfun := NULL;
        CLOSE cr_crapcnv;
      ELSE
        vr_lshstfun := TRIM(rw_crapcnv.lshistor);
        CLOSE cr_crapcnv;
      END IF;
      
      /*  Historicos do convenio 19 - FUND - DEPEN BRADESCO ADM.......... */
      OPEN cr_crapcnv (pr_nrconven => 19);
      FETCH cr_crapcnv
        INTO rw_crapcnv;
      IF cr_crapcnv%NOTFOUND THEN
        CLOSE cr_crapcnv;
      ELSE
        IF TRIM(rw_crapcnv.lshistor) <> vr_lshstfun   THEN
          vr_lshstfun := vr_lshstfun ||','|| TRIM(rw_crapcnv.lshistor);
        END IF;
        CLOSE cr_crapcnv;
      END IF;

      -- Popular tabela temporaria com dos titulares
      FOR rw_crapttl IN cr_crapttl LOOP
        vr_tab_crapttl(lpad(rw_crapttl.nrdconta,10,0)).cdempres :=  rw_crapttl.cdempres;
        vr_tab_crapttl(lpad(rw_crapttl.nrdconta,10,0)).cdturnos :=  rw_crapttl.cdturnos;
      END LOOP;

      /*  Leitura das solicitacoes de integracao  */
      FOR rw_crapsol IN cr_crapsol(pr_cdcooper => pr_cdcooper,
                                   pr_dtmvtolt => rw_crapdat.dtmvtolt ) LOOP

        IF vr_inrestar = 0 THEN
          vr_qttarifa := 0;
        END IF;

        IF rw_crapdat.dtmvtolt = vr_dtintegr AND  /*   Testa integ. por fora */
           SUBSTR(rw_crapsol.dsparame,15,1) = '1' THEN
          CONTINUE;
        END IF;

        -- Inicializar variaveis
        vr_contador := 0;
        vr_cdcritic := 0;
        vr_cdempres := 11;
        vr_cdempsol := rw_crapsol.cdempres;

        vr_regexist := TRUE;
        vr_flgfirst := TRUE;
        vr_flglotes := TRUE;

        vr_nrlotfol := 0;
        vr_nrlotcot := 0;
        vr_nrlotemp := 0;

        IF vr_inrestar = 0 THEN
          vr_flgclote := TRUE;
        ELSE
          vr_flgclote := FALSE;
        END IF;

        IF SUBSTR(rw_crapsol.dsparame,17,1) = '1' THEN
          vr_flgestou := TRUE;
        ELSE
          vr_flgestou := FALSE;
        END IF;

        -- Busca do diretório base da cooperativa para a geração de relatórios
        vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                              ,pr_cdcooper => pr_cdcooper);

        vr_nrseqsol := SUBSTR(gene0002.fn_mask(rw_crapsol.nrseqsol,'9999'),3,2);
        vr_nmarquiv := vr_nom_direto||'/rl/crrl098_'|| vr_nrseqsol||'.lst';
        vr_nmarqest := vr_nom_direto||'/rl/crrl099_'|| vr_nrseqsol||'.lst';
        vr_nmarqden := vr_nom_direto||'/rl/crrl114_'|| vr_nrseqsol||'.lst';
        vr_nrdevias := rw_crapsol.nrdevias;
        -- Separa em bloco para tratar problemas com conversão para data
        BEGIN
          vr_dtrefere := to_date(SUBSTR(rw_crapsol.dsparame,1,10),'DD/MM/RRRR');
        EXCEPTION
          WHEN OTHERS THEN
            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> Problema na CRAPSOL, NRSEQSOL= '||rw_crapsol.nrseqsol
                                                       || ' --> Nao foi possivel converter '||SUBSTR(rw_crapsol.dsparame,1,10) 
                                                       || ' em uma data no formato DD/MM/YYYY');
            continue; 
        END;  
        -- Montar nome de arquivo a integrar
        vr_nmarqint := vr_nom_direto||'/integra/f'
                    ||LPAD(rw_crapsol.cdempres,5,'0')
                    ||to_char(vr_dtrefere,'DD')
                    ||to_char(vr_dtrefere,'MM')
                    ||to_char(vr_dtrefere,'RRRR')||'.'
                    ||SUBSTR(rw_crapsol.dsparame,12,2);

        --Ler cadastro de empresa
        OPEN cr_crapemp (pr_cdcooper => pr_cdcooper,
                         pr_cdempres => rw_crapsol.cdempres);
        FETCH cr_crapemp
          INTO rw_crapemp;
        IF cr_crapemp%NOTFOUND THEN
          vr_dsempres := LPAD(rw_crapsol.cdempres,5,'0')||' - '||'NAO CADASTRADA';
          vr_cdempfol := 0;
          close cr_crapemp;
        ELSE
          vr_dsempres := LPAD(rw_crapemp.cdempres,5,'0') ||' - '|| rw_crapemp.nmresemp;
          vr_cdempfol := rw_crapemp.cdempfol;
          close cr_crapemp;
        END IF;

        /*  Verifica se o arquivo a ser integrado existe em disco  */
        IF gene0001.fn_exis_arquivo(pr_caminho => vr_nmarqint) = false THEN
          --caso não localizar deve Alterar nome
          vr_nmarqint := vr_nom_direto||'/integra/f'||
                          LPAD(rw_crapsol.cdempres,2,'0')||
                          to_char(vr_dtrefere,'DD')||
                          to_char(vr_dtrefere,'MM')||
                          to_char(vr_dtrefere,'RRRR')||'.'||
                          SUBSTR(rw_crapsol.dsparame,12,2);

          -- Se mesmo assim não existir, gerar log e ir para o proximo
          IF gene0001.fn_exis_arquivo(pr_caminho => vr_nmarqint) = false THEN
            vr_cdcritic := 182;
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '|| vr_dscritic
                                                       || ' --> '|| vr_nmarqint );
            continue;
          END IF;
        END IF;

        /*  Inicializa flag de atualizacao do fator salarial  */
        OPEN cr_crapavs (pr_cdcooper => pr_cdcooper,
                         pr_dtrefere => vr_dtrefere);
        FETCH cr_crapavs
          INTO rw_crapavs;
        IF cr_crapavs%NOTFOUND THEN
          vr_flgatual := FALSE;
          close cr_crapavs;
        ELSE
          vr_flgatual := TRUE;
          close cr_crapavs;
        END IF;
        -- 11-COOPERATIVA CREDITO VALE DO ITAJAI
        -- 99-CIA HERING - ADMINISTRACAO
        IF rw_crapsol.cdempres in (11,99) THEN
          vr_flgatual := FALSE;
        END IF;

        -- Integrar a folha de pagamento do arquivo.
        pc_integra_folha_pagto(pr_cdcooper   => pr_cdcooper --> Cooperativa solicitada
                              ,pr_cdoperad   => pr_cdoperad --> Codigo do operaros
                              ,pr_crapdat    => rw_crapdat  --> rowtype com os dados da crapdat
                              ,pr_nmarquiv   => vr_nmarquiv --> nome do relatorio de criticas
                              ,pr_nmarqint   => vr_nmarqint --> arquivo a ser importado
                              ,pr_inrestar   => vr_inrestar --> Indicador de restart
                              ,pr_dtrefere   => vr_dtrefere --> Data de referencia
                              ,pr_inusatab   => vr_inusatab --> Indicador de utilização da tabela de juros
                              ,pr_cdempfol   => vr_cdempfol -- Codigo da empresa da folha
                              ,pr_cdempsol   => vr_cdempsol --> codigo da empresa solicitante
                              ,pr_nrctares   => 0           --> Numero de conta no controle de restart
                              ,pr_rowidres   => rw_crapres.ROWID --> Rowid na tabela de restart
                              ,pr_indmarca   => vr_indmarca --> Indicador de marca no restart
                              ,pr_dtintegr   => vr_dtintegr --> Data de integração
                              ,pr_dsempres   => vr_dsempres --> Nome da empresa
                              ,pr_lshstsau   => vr_lshstsau --> Lista de hist. de planos de saude
                              ,pr_lshstfun   => vr_lshstfun --> lista de hist.
                              ,pr_lshstdiv   => vr_lshstdiv --> Lista de hist. diveros
                              --out
                              ,pr_flglotes   => vr_flglotes --> Flg de controle de lote
                              ,pr_flgclote   => vr_flgclote --> Flg se deve gerar lote
                              ,pr_flgatual   => vr_flgatual --> flg de a empresa não é viacredi
                              ,pr_qttarifa   => vr_qttarifa --> quantidade de tarifa
                              ,pr_flignore   => vr_flignore --> Flag para ignorar o arquivo
                              ,pr_cdcritic   => vr_cdcritic --> codigo da critica
                              ,pr_dscritic   => vr_dscritic); --> descrição da critica
        -- Se houver criticas 
        IF vr_cdcritic > 0 or vr_dscritic is not null THEN
          RAISE vr_exc_saida;
        END IF;
        
        -- Se o arquivo gerou exceção para ignorá-lo
        IF vr_flignore THEN
          CONTINUE;
        END IF;

        -- Se houve estouro
        IF vr_flgestou   THEN
          -- Gerar os relatórios de estouro
          pc_gera_rel_estouros(pr_cdcooper  => pr_cdcooper        --> Cooperativa solicitada
                              ,pr_crapdat   => rw_crapdat         --> type contendo as informações da crapdat
                              ,pr_cdempres  => rw_crapsol.cdempres--> codigo da empresa
                              ,pr_dsempres  => vr_dsempres        --> Nome da empresa
                              ,pr_nmarqest  => vr_nmarqest        --> nome do relatorio de resumo
                              ,pr_nmarqden  => vr_nmarqden        --> Nome do relatorio detalhe
                              ,pr_dtrefere  => vr_dtrefere        --> data de referencia
                              ,pr_cdcritic  => vr_cdcritic        --> Critica encontrada
                              ,pr_dscritic  => vr_dscritic);
          IF vr_cdcritic > 0 or vr_dscritic is not null THEN
            RAISE vr_exc_saida;
          END IF;
        END IF;
          
        -- Limpeza dos controles de restart
        vr_nrctares := 0;
        vr_inrestar := 0;
        vr_rel_qttarifa := 0;
          
        -- Testar necessidade de atualização do dia do pagto na craptab
        IF vr_indmarca = 1 THEN
          BEGIN
            UPDATE craptab
               SET craptab.dstextab        = SUBSTR(craptab.dstextab, 1, 13) ||'1'
             WHERE craptab.cdcooper        = pr_cdcooper
               AND upper(craptab.nmsistem) = 'CRED'
               AND upper(craptab.tptabela) = 'GENERI'
               AND craptab.cdempres        = 0
               AND upper(craptab.cdacesso) = 'DIADOPAGTO'
               AND craptab.tpregist        = rw_crapsol.cdempres;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Não foi possivel atualizar craptab(DIADOPAGTO)'
                               ||' cdempres: '|| rw_crapsol.cdempres||' :'||SQLERRM;
                RAISE vr_exc_saida;
          END;
        END IF;

        /* Atualiza controle de convenios integrados na ultima folha  */
        IF vr_flgestou THEN
          IF vr_dtrefere = rw_crapdat.dtultdma   OR /*Somente criar crapfol*/
             vr_dtrefere = rw_crapdat.dtultdia   THEN /*se for folha mensal*/
            FOR rw_crapavs IN cr_crapavs2 (pr_cdcooper => pr_cdcooper,
                                           pr_cdempres => rw_crapemp.cdempres,
                                           pr_dtrefere => vr_dtrefere) LOOP
              BEGIN
                INSERT INTO crapfol
                            ( cdcooper
                             ,cdempres
                             ,dtrefere
                             ,nrdconta)
                     VALUES ( pr_cdcooper           -- cdcooper
                             ,rw_crapavs.cdempres   -- cdempres
                             ,rw_crapavs.dtrefere   -- dtrefere
                             ,rw_crapavs.nrdconta); -- nrdconta
        
              EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                  NULL; -- Se ja existe o registro não precisa fazer nd
                WHEN OTHERS THEN
                  vr_dscritic := 'Não foi possivel inserir crapfol'
                                ||' cdempres: '|| rw_crapavs.cdempres||' :'||SQLERRM;
                  RAISE vr_exc_saida;
              END;
            END LOOP; -- Fim loop rw_crapavs
          END IF;

          vr_dtexecde := vr_dtintegr + 1;

          -- Se o dia da dtintegr for anterior ao dia limite para debitos
          IF TO_CHAR(vr_dtexecde,'DD') <= rw_crapemp.dtlimdeb THEN
            vr_dtexecde := GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                      ,pr_dtmvtolt => TO_DATE(TO_CHAR(rw_crapemp.dtlimdeb,'fm00') || '/' || 
                                                                              TO_CHAR(vr_dtintegr,'MM/RRRR'), 
                                                                              'DD/MM/RRRR'));
          END IF;

          BEGIN
            -- Inserir registro de controle na craptab
            INSERT INTO craptab
                       (nmsistem
                       ,tptabela
                       ,cdempres
                       ,cdacesso
                       ,tpregist
                       ,cdcooper
                       ,dstextab)
                 VALUES('CRED'             -- nmsistem
                       ,'USUARI'           -- tptabela
                       ,rw_crapemp.cdempres-- cdempres
                       ,'EXECDEBEMP'       -- cdacesso
                       ,0                  -- tpregist
                       ,pr_cdcooper        -- cdcooper
                       ,to_char(vr_dtrefere,'DD/MM/RRRR') ||' '||to_char(vr_dtexecde,'DD/MM/RRRR')||' 0' ); -- dstextab
          EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
              -- Se ja existe deve alterar
              BEGIN
                UPDATE craptab
                   SET craptab.dstextab = to_char(vr_dtrefere,'DD/MM/RRRR') ||' '||
                                          to_char(vr_dtexecde,'DD/MM/RRRR')||' 0'
                 WHERE craptab.cdcooper        = pr_cdcooper
                   AND upper(craptab.nmsistem) = 'CRED'
                   AND upper(craptab.tptabela) = 'USUARI'
                   AND craptab.cdempres        = rw_crapemp.cdempres
                   AND upper(craptab.cdacesso) = 'EXECDEBEMP'
                   AND craptab.tpregist        = 0;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Não foi possivel atualizar craptab(EXECDEBEMP)' ||' cdempres: '|| rw_crapemp.cdempres||' :'||SQLERRM;
                  RAISE vr_exc_saida;
              END;
            WHEN OTHERS THEN
              vr_dscritic := 'Não foi possivel inserir craptab (EXECDEBEMP)' ||' cdempres: '|| rw_crapemp.cdempres||' :'||SQLERRM;
              RAISE vr_exc_saida;
          END;
          -- Gerar data do próximo débito
          vr_dtsegdeb := rw_crapdat.dtmvtopr;
          -- Buscar o proximo dia util
          IF rw_crapdat.inproces > 2   THEN
            vr_dtsegdeb := gene0005.fn_valida_dia_util( pr_cdcooper => pr_cdcooper,
                                                        pr_dtmvtolt => vr_dtsegdeb,
                                                        pr_tipo     => 'P',
                                                        pr_feriado  => TRUE);
          END IF;
          -- Atualizar Controle de convenio integrados por empresa.
          BEGIN
            UPDATE crapepc
               SET crapepc.incvfol1 = 2,
                   crapepc.dtcvfol1 = rw_crapdat.dtmvtolt,
                   crapepc.incvfol2 = 1,
                   crapepc.dtcvfol2 = vr_dtsegdeb
             WHERE crapepc.cdcooper = pr_cdcooper
               AND crapepc.cdempres = rw_crapsol.cdempres
               AND crapepc.dtrefere = vr_dtrefere
               AND crapepc.incvfol1 = 1;

          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Não foi possivel atualizar Controle de convenio integrados (crapepc)'
                          ||' cdempres: '|| rw_crapsol.cdempres||' :'||SQLERRM;
              RAISE vr_exc_saida;
          END;

        END IF;

        -- Marcar solicitação como processada
        BEGIN
          UPDATE crapsol
             SET crapsol.insitsol = 2
           WHERE crapsol.rowid = rw_crapsol.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Não foi possivel atualizar solicitação de processo (crapsol)'||' nrseqsol: '|| rw_crapsol.nrseqsol||' :'||SQLERRM;
            RAISE vr_exc_saida;
        END;

        /*  Move arquivo integrado para o diretorio salvar  */
        gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||vr_nmarqint||' '||vr_nom_direto||'/salvar'
                                   ,pr_typ_saida   => vr_typ_said
                                   ,pr_des_saida   => vr_dscritic);
        -- Testar erro
        IF vr_typ_said = 'ERR' THEN
          -- O comando shell executou com erro, gerar log e sair do processo
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao mover o arquivo '||vr_nmarqint||' para o diretório salvar: ' || vr_dscritic;
          RAISE vr_exc_saida;
        END IF;

        --commitar a cada arquivo integrado
        COMMIT;

      END LOOP; /*  Fim do Loop  -- Leitura das solicitacoes --  */

      IF NOT vr_regexist   THEN
        vr_cdcritic := 157;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '|| vr_dscritic
                                                   || ' - SOL062' );

        RAISE vr_exc_saida;
      END IF;

      ----------------- ENCERRAMENTO DO PROGRAMA -------------------

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      -- Salvar informações atualizadas
      COMMIT;

    EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic );
        -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);
        -- Efetuar commit
        COMMIT;
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos código e critica encontradas das variaveis locais
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
    END;

  END pc_crps120;
/
