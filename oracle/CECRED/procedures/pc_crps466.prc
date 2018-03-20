CREATE OR REPLACE PROCEDURE CECRED.pc_crps466 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps466 (Fontes/crps466.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Diego
       Data    : Julho/2006                     Ultima atualizacao: 31/07/2017

       Dados referentes ao programa:

       Frequencia: Mensal.
       Objetivo  : Atende a solicitacao 086.
                   Estatistica lancamentos Conta Integracao (relatorio 441) e
                   Relacao Contas Integracao sem Movimentacoes (relatorio 442).

       Alteracoes: 10/08/2006 - Alterado o periodo de contas sem movimentacao e
                                incluidos historicos 21,521,516 (Diego).

                   11/09/2006 - Retirada atribuicao para glb_dtmvtolt e efetuado
                                acerto nas datas utilizadas para periodo de 6 meses
                                (Diego).

                   02/01/2008 - Incluidas informacoes no relatorio 442 (Diego).

                   15/02/2008 - Incluida linha com total de contas ITG sem
                                movimentacao (Gabriel).

                   28/04/2008 - Nao listar contas que possuem cartoes BB(Guilherme).

                   30/05/2008 - Incluido qtdade contas c/cartao BB(Mirtes)
                                (Nao comparar qtd.com tela CCARBB, pois este rel.
                                lista contas ativas com cartao BB e a tela CCARBB
                                apenas a  quantidade de cartoes.
                                Uma conta pode ter mais de um cartao).

                   15/12/2008 - Substituir a tab "ContaConve" pela gnctace (Ze).

                   29/03/2010 - Incluir historico 444 e 584 para ITG s/ movimento
                               (Guilherme).

                   16/05/2011 - Alterado para que o programa passe a rodar no dia
                                25 de cada mes (Henrique).

                   26/05/2011 - Melhorar performance (Magui).

                   21/06/2011 - Ajuste de performance (Gabriel)

                   19/09/2011 - Listar contas ITG sem movimentacao nos ultimos
                                6 meses somente se, a data de abertura da conta
                                ITG for <= 6 meses (Adriano).

                   21/03/2012 - Ajuste para listar todas as contas abertas com
                                data menor a data atual no crrl441(Adriano).

                   27/12/2012 - Alteracao para nao imprimir em uma str_2
                                fechado (Ze).

                   13/02/2013 - Verificado se houve reativacao de conta na crapalt
                                para nao desprezar contas erroneamente (Tiago).

                   09/09/2013 - Nova forma de chamar as agências, de PAC agora
                                a escrita será PA (André Euzébio - Supero).

                   12/11/2013 - Alterado totalizador de PAs de 99 para 999.
                                (Reinert)

                   23/12/2013 - Ajuste para a impressao de todos os PAs para o
                                relatorio 441. (Reinert)

                   13/03/2014 - Conversão Progress >> Oracle PL/SQL (Tiago Castro - RKAM)
                   
                   27/05/2014 - Ajuste no sqcabrel = 2 para o relatorio crrl442(Odirlei-AMcom) 
                   
                   03/07/2014 - Ajuste do calculo da data para ano -1 (Tiago Castro - RKAM)
                                
                   31/07/2017 - Padronizar as mensagens - Chamado 721285
                                Tratar os exception others - Chamado 721285
                                Ajustada mensagem: Hoje não é segunda então não pode haver processamento - Chamado 721285
                                ( Belli - Envolti )                   
                   
                   01/08/2017 - Retirada gravação de log para mensagem de erro de data
                                (Ana - Envolti)                   
                   
                   06/03/2018 - Substituida verificacao "cdtipcta > 11" por tipo de conta possuir o indicador 
                                de conta corrente integração como Sim (tbcc_tipo_conta.indconta_itg = 1). 
                                PRJ366 (Lombardi).
    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS466';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);
      vr_dtinicio   DATE;
      vr_dttfinal   DATE;
      vr_yymvtolt   NUMBER;
      vr_mmmvtolt   NUMBER;
      vr_qtdeposi   NUMBER;
      vr_qtchdevo   NUMBER;
      vr_chproces   NUMBER;
      vr_chvlrbai   NUMBER;
      vr_qtvlraci   NUMBER;
      vr_valoraci   NUMBER;
      vr_qtsaqtaa   NUMBER;
      vr_nmarqim    VARCHAR2(25);
      v_gerar       BOOLEAN := FALSE;
      -- Variaveis para os XMLs e relatórios
      vr_clobxml     CLOB;   -- Clob para conter o XML de dados
      vr_nom_direto  VARCHAR2(200); -- Diretório para gravação do arquivo
      vr_diadopro DATE;
      vr_lscontas VARCHAR2(1000);
      -- variavel para validacao dos historicos de alteracao, devido a restricao do oracle no campo long
      vr_dsaltera_lob clob;
      vr_dtmvtolt DATE;
      vr_dataativ DATE;
      vr_rel_dtmvtolt DATE;
      vr_rel_dssitdct VARCHAR2(30);
      vr_qtchfora NUMBER;
      vr_qtchqarq NUMBER;
      vr_qtpdfora NUMBER;
      vr_qtrqfora NUMBER;
      vr_nmresage crapage.nmresage%TYPE;
      vr_cartaobb NUMBER;
      vr_contaitg NUMBER;
      
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

      CURSOR cr_craplcm1 IS
      -- Lancamentos em depositos a vista
        SELECT  nrdconta,
                nrdctabb,
                cdhistor,
                cdbccxlt,
                vllanmto
        FROM    craplcm
        WHERE   craplcm.cdcooper = pr_cdcooper
        AND     craplcm.dtmvtolt = vr_dtinicio
        AND     craplcm.cdhistor IN (50,56,59,169,170,191,314,614,646,651)
        AND     craplcm.nrdctabb <> 0
        ORDER   BY craplcm.cdhistor;

      CURSOR cr_craplcm2(pr_nrdconta IN crapass.nrdconta%TYPE)  IS
        -- Lancamentos em depositos a vista
        SELECT  nrdconta
        FROM    craplcm
        WHERE   craplcm.cdcooper = pr_cdcooper
        AND     craplcm.nrdconta = pr_nrdconta
        AND     craplcm.dtmvtolt >= vr_dtmvtolt
        AND     craplcm.cdhistor IN (646,314,651,169,170,614,658,613,661,50,59,290,662,21,516,521,444,584);
      rw_craplcm2 cr_craplcm2%ROWTYPE;

      CURSOR cr_craplcm3(pr_nrdconta IN crapass.nrdconta%TYPE)  IS
        -- Lancamentos em depositos a vista
        SELECT  MAX(dtmvtolt)
        FROM    craplcm
        WHERE   craplcm.cdcooper = pr_cdcooper
        AND     craplcm.nrdconta = pr_nrdconta
        AND     craplcm.dtmvtolt < vr_dtmvtolt
        AND     craplcm.cdhistor IN (646,314,651,169,170,614,658,613,661,50,59,290,662,21,516,521,444,584);


      CURSOR cr_crapass1 (pr_nrdconta IN craplcm.nrdconta%type) IS
        -- Cadastro de associados
        SELECT flgctitg,
               nrdconta
        FROM   crapass
        WHERE  crapass.cdcooper = pr_cdcooper
        AND    crapass.nrdconta = pr_nrdconta;
      rw_crapass1 cr_crapass1%ROWTYPE;

      CURSOR cr_crapass2 IS -- Cadastro de associados
        SELECT  nrdconta,
                dtabcitg,
                cdsitdct,
                nrdctitg,
                cdagenci,
                nmprimtl,
                dtdemiss
        FROM    crapass
        WHERE   crapass.cdcooper = pr_cdcooper
        AND     trim(crapass.nrdctitg) IS NOT NULL
        AND     crapass.flgctitg = 2
        AND     crapass.dtabcitg <= rw_crapdat.dtmvtolt
        ORDER BY crapass.cdagenci,
                 crapass.nrdconta;
      rw_crapass2 cr_crapass2%ROWTYPE;

      CURSOR cr_crawcrd2(pr_nrdconta IN crapass.nrdconta%TYPE)  IS
        -- Arquivo auxiliar de controle de cartoes de credito
        SELECT nrdconta
        FROM  crawcrd
        WHERE crawcrd.cdcooper  = pr_cdcooper
        AND   crawcrd.nrdconta  = pr_nrdconta
        AND   (crawcrd.insitcrd = 2
        OR     crawcrd.insitcrd = 1
        OR     crawcrd.insitcrd = 4)
        AND   (crawcrd.cdadmcrd >= 83
        AND    crawcrd.cdadmcrd <= 88);
      rw_crawcrd cr_crawcrd2%ROWTYPE;

      CURSOR cr_crawcrd3(pr_nrdconta IN crawcrd.nrdconta%TYPE) IS
        -- Arquivo auxiliar de controle de cartoes de credito
        SELECT  COUNT('*')
        FROM    crawcrd
        WHERE   crawcrd.cdcooper = pr_cdcooper
        AND     crawcrd.nrdconta = pr_nrdconta
        AND     crawcrd.insitcrd = 4
        AND     (crawcrd.cdadmcrd >= 83
        AND      crawcrd.cdadmcrd <= 88);

      CURSOR cr_crapalt (pr_nrdconta crapass.nrdconta%TYPE) IS
        -- Cadastro de Arquivo com o historico das alteracoes
        -- ocorridas no arquivo crapass para fins de recadastramento
        SELECT  dtaltera,
                dsaltera
        FROM    crapalt
        WHERE   crapalt.cdcooper = pr_cdcooper
        AND     crapalt.nrdconta = pr_nrdconta
        AND     crapalt.dtaltera >= vr_dtmvtolt
        ORDER   BY dtaltera DESC;
      rw_crapalt cr_crapalt%ROWTYPE;


      CURSOR cr_crapfdc(pr_nrdconta IN crapass.nrdconta%TYPE,
                        pr_nrdctitg IN crapass.nrdctitg%TYPE) IS
        -- Cadastro de folhas de cheques emitidos para o cooperado
        SELECT  dtretchq,
                dtliqchq,
                incheque,
                dtemschq
        FROM    crapfdc
        WHERE   crapfdc.cdcooper = pr_cdcooper
        AND     crapfdc.nrdconta = pr_nrdconta
        AND     crapfdc.nrdctitg = pr_nrdctitg;

      CURSOR cr_crapreq(pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT COUNT('*') --busca requisicao de talonarios
        FROM  crapreq         req
            , tbcc_tipo_conta tip
            , crapass         ass
        WHERE req.cdcooper  = pr_cdcooper
        AND   req.nrdconta  = pr_nrdconta
        AND   req.insitreq  IN (1,4,5)
        AND   req.cdtipcta = tip.cdtipo_conta
        AND   tip.indconta_itg = 1 -- Tipos de Conta com ITG habilitada
        AND   tip.inpessoa = ass.inpessoa
        AND   ass.cdcooper = req.cdcooper
        AND   ass.nrdconta = req.nrdconta
        AND   req.qtreqtal > 0
        HAVING COUNT('*') >0;

      CURSOR cr_crapage(p_cdagenci IN NUMBER) IS -- busca dados do PA
        SELECT nmresage
        FROM   crapage
        WHERE  crapage.cdcooper = pr_cdcooper
        AND    crapage.cdagenci = p_cdagenci;


      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

      TYPE typ_reg_tot_dat IS
        RECORD ( dtinicio DATE
                ,qtdeposi NUMBER
                ,qtchdevo NUMBER
                ,chproces NUMBER
                ,chvlrbai NUMBER
                ,qtvlraci NUMBER
                ,valoraci NUMBER
                ,qtsaqtaa NUMBER);
      TYPE typ_tab_tot_dat IS
        TABLE OF typ_reg_tot_dat
          INDEX BY VARCHAR2(20); --> 20 Dt Vigencia
      vr_tab_tot_dat typ_tab_tot_dat;
      vr_des_chave_dat  VARCHAR2(20);

      TYPE typ_reg_relato IS
        RECORD ( cdagenci crapass.cdagenci%TYPE
                ,nrdconta crapass.nrdconta%TYPE
                ,nmprintl crapass.nmprimtl%TYPE
                ,dssitdct VARCHAR2(30)
                ,nrdctitg crapass.nrdctitg%TYPE
                ,dtmvtolt crapdat.dtmvtolt%TYPE
                ,dtdemiss crapass.dtdemiss%TYPE
                ,qtchfora NUMBER
                ,qtchqarq NUMBER
                ,qtpdfora NUMBER
                ,qtrqfora NUMBER
                ,titulo   VARCHAR2(150)
                );
      TYPE typ_tab_relato IS
        TABLE OF typ_reg_relato
          INDEX BY VARCHAR2(15); --> 05 PA + 10 Conta
      vr_tab_relato typ_tab_relato;
      vr_des_chave  VARCHAR2(20);



      ------------------------------- VARIAVEIS -------------------------------


      --------------------------- SUBROTINAS INTERNAS --------------------------

      PROCEDURE pc_escreve_clob(pr_clobdado IN OUT NOCOPY CLOB
                               ,pr_desdados IN VARCHAR2) IS
      BEGIN
        dbms_lob.writeappend(pr_clobdado, length(pr_desdados),pr_desdados);
      END;


    --------------------------- 

    PROCEDURE pc_processar 
      IS
    BEGIN        
      --busca lista de contas centralizadoras
      vr_lscontas := gene0005.fn_busca_conta_centralizadora(pr_cdcooper => pr_cdcooper,
                                                            pr_tpregist => 1);
      --verifica se o mes é janeiro
      IF to_number(to_char(rw_crapdat.dtmvtolt,'mm')) = 1 THEN
        -- diminui 1 ano
        vr_yymvtolt := to_number(to_char(rw_crapdat.dtmvtolt,'yyyy')) - 1;
      ELSE
        -- pega o ano da data mov.
        vr_yymvtolt := to_number(to_char(rw_crapdat.dtmvtolt, 'yyyy'));
      END IF;
      --verficia se o mes é janeiro
      IF to_number(to_char(rw_crapdat.dtmvtolt, 'mm')) = 1 THEN
        --pega o mes dezembro
        vr_mmmvtolt := 12;
      ELSE
        -- diminui 1 mes da data mov.
        vr_mmmvtolt := to_number(to_char(add_months(rw_crapdat.dtmvtolt, - 1),'mm'));
      END IF;
      -- monta as datas entre 25 e 24 do mes mov.
      vr_dtinicio := to_date(to_char(vr_mmmvtolt,'fm00')||25||vr_yymvtolt, 'mmddyyyy');
      vr_dttfinal := to_date(to_char(rw_crapdat.dtmvtolt, 'mm')||24||to_char(rw_crapdat.dtmvtolt,'yyyy'),'mmddyyyy');
      
      WHILE vr_dtinicio <= vr_dttfinal -- enquanto data inicio for menor ou igual a data final
      LOOP
        /* Para os historicos da aux_lshistor */
        FOR rw_craplcm IN cr_craplcm1
        LOOP
          EXIT WHEN cr_craplcm1%NOTFOUND;
          OPEN cr_crapass1(rw_craplcm.nrdconta);
          FETCH cr_crapass1 INTO rw_crapass1;
          CLOSE cr_crapass1;
          /* Se for Conta Base */
          IF  gene0002.fn_existe_valor(pr_base      => vr_lscontas
                                       ,pr_busca    => rw_craplcm.nrdctabb
                                       ,pr_delimite => ',' ) = 'S'THEN
                                       
	          -- Incluir nome do módulo logado - Chamado 721285 31/07/2017
		        GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL); 
    
            continue;
          END IF;
                                                 
	        -- Incluir nome do módulo logado - Chamado 721285 31/07/2017
		      GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL); 
            
          /* Depositos Efetuados */
          IF  rw_craplcm.cdhistor = 646 OR
              rw_craplcm.cdhistor = 314 OR
              rw_craplcm.cdhistor = 651 OR
              rw_craplcm.cdhistor = 169 OR
              rw_craplcm.cdhistor = 170 THEN
              vr_qtdeposi := nvl(vr_qtdeposi,0) + 1;
          END IF;
          /* Cheques Devolvidos */
          IF rw_craplcm.cdbccxlt  = 100  AND
             rw_craplcm.cdhistor  = 191  THEN
             vr_qtchdevo := nvl(vr_qtchdevo,0) + 1;
          END IF;
          /* Cheques Processados */
          IF rw_craplcm.cdhistor = 50 OR
             rw_craplcm.cdhistor = 56 OR
             rw_craplcm.cdhistor = 59 THEN
             vr_chproces := nvl(vr_chproces,0) + 1;
          END IF;
          /* Cheques Baixo Valor */
          IF  rw_craplcm.vllanmto <= 40 AND
              (rw_craplcm.cdhistor = 50 OR
              rw_craplcm.cdhistor = 56  OR
              rw_craplcm.cdhistor = 59) THEN
              vr_chvlrbai := nvl(vr_chvlrbai,0) + 1;
          END IF;
          /* Cheques acima de 5.000,00 */
          IF  rw_craplcm.vllanmto >= 5000 AND
              (rw_craplcm.cdhistor = 50   OR
              rw_craplcm.cdhistor = 56    OR
              rw_craplcm.cdhistor = 59)   THEN
              vr_qtvlraci := nvl(vr_qtvlraci,0) + 1;
              vr_valoraci := nvl(vr_valoraci,0) + rw_craplcm.vllanmto;

          END IF;
          /* Saque TAA */
          IF  rw_craplcm.cdhistor = 614  THEN
              vr_qtsaqtaa := nvl(vr_qtsaqtaa,0) + 1;
          END IF;
          IF rw_crapass1.flgctitg = 2 THEN -- situacao conta itg - cadastrado
            vr_contaitg := nvl(vr_contaitg,0) +1;
            OPEN cr_crawcrd3(rw_crapass1.nrdconta);--verifica cartaobb
            FETCH cr_crawcrd3 INTO vr_cartaobb;
            CLOSE cr_crawcrd3;
          END IF;
        END LOOP;
        IF nvl(vr_qtdeposi,0) > 0 THEN -- se encontrou valores popula temp table
          vr_des_chave_dat := lpad(vr_dtinicio,20,'0');
          vr_tab_tot_dat(vr_des_chave_dat).dtinicio := vr_dtinicio;
          vr_tab_tot_dat(vr_des_chave_dat).qtdeposi := nvl(vr_qtdeposi,0);
          vr_tab_tot_dat(vr_des_chave_dat).qtchdevo := nvl(vr_qtchdevo,0);
          vr_tab_tot_dat(vr_des_chave_dat).chproces := nvl(vr_chproces,0);
          vr_tab_tot_dat(vr_des_chave_dat).chvlrbai := nvl(vr_chvlrbai,0);
          vr_tab_tot_dat(vr_des_chave_dat).qtvlraci := nvl(vr_qtvlraci,0);
          vr_tab_tot_dat(vr_des_chave_dat).valoraci := nvl(vr_valoraci,0);
          vr_tab_tot_dat(vr_des_chave_dat).qtsaqtaa := nvl(vr_qtsaqtaa,0);
        END IF;
        --zera variaveis
        vr_qtdeposi := 0;
        vr_qtchdevo := 0;
        vr_chproces := 0;
        vr_chvlrbai := 0;
        vr_qtvlraci := 0;
        vr_valoraci := 0;
        vr_qtsaqtaa := 0;
        vr_cartaobb := 0;
        vr_contaitg := 0;
        vr_dtinicio := vr_dtinicio + 1;
      END LOOP;
      -- Com a tabela do relatorio povoada, iremos varre-la para gerar o xml de base ao relatorio
      --busca primeiro registro da tabela
      vr_des_chave_dat := vr_tab_tot_dat.first;
      IF vr_des_chave_dat IS NOT NULL THEN
        --criar clob
        dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
        dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);
        pc_escreve_clob(vr_clobxml,'<?xml version="1.0" encoding="utf-8"?><raiz>');
        vr_nmarqim := '/crrl441.lst';
      ELSE
        dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
        dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);
        pc_escreve_clob(vr_clobxml,'<?xml version="1.0" encoding="utf-8"?><raiz></raiz>');
        vr_nmarqim := '/crrl441.lst';
      END IF;
      WHILE vr_des_chave_dat IS NOT NULL
      LOOP -- varre a tabela temporaria para montar xml
        pc_escreve_clob(vr_clobxml,'   <datas>'
                                 ||'    <data>'||to_char(vr_tab_tot_dat(vr_des_chave_dat).dtinicio,'dd/mm/yyyy')||'</data>'
                                 ||'    <depositos>'||vr_tab_tot_dat(vr_des_chave_dat).qtdeposi||'</depositos>'
                                 ||'    <chq_dev>'||vr_tab_tot_dat(vr_des_chave_dat).qtchdevo||'</chq_dev>'
                                 ||'    <chq_proc>'||vr_tab_tot_dat(vr_des_chave_dat).chproces||'</chq_proc>'
                                 ||'    <chq_bxvlr>'||vr_tab_tot_dat(vr_des_chave_dat).chvlrbai||'</chq_bxvlr>'
                                 ||'    <adicional>'||vr_tab_tot_dat(vr_des_chave_dat).qtvlraci||'</adicional>'
                                 ||'    <spb>'||vr_tab_tot_dat(vr_des_chave_dat).valoraci||'</spb>'
                                 ||'    <saque>'||vr_tab_tot_dat(vr_des_chave_dat).qtsaqtaa||'</saque>'
                                 ||'   </datas>') ;

        IF vr_des_chave_dat = vr_tab_tot_dat.last THEN
          pc_escreve_clob(vr_clobxml,'</raiz>');--fecha tag raiz
        END IF;
          -- Buscar o proximo
        vr_des_chave_dat := vr_tab_tot_dat.NEXT(vr_des_chave_dat);
      END LOOP;
      --busca diretorio padrao da cooperativa
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => 'rl');

      --gera relatorio crrl441
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                              --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                  --> Data do movimento atual
                                 ,pr_dsxml     => vr_clobxml                           --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/raiz'                              --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl441.jasper'                     --> Arquivo de layout do iReport
                                 ,pr_dsparams  => null                                 --> Sem parâmetros
                                 ,pr_dsarqsaid => vr_nom_direto||vr_nmarqim            --> Arquivo final com o path
                                 ,pr_qtcoluna  => 132                                  --> 132 colunas
                                 ,pr_flg_gerar => 'N'                                  --> Geraçao na hora
                                 ,pr_flg_impri => 'S'                                  --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => ''                                   --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 3                                    --> Número de cópias
                                 ,pr_sqcabrel  => 1                                    --> Qual a seq do cabrel
                                 ,pr_des_erro  => vr_dscritic);                       --> Saída com erro
                                       
	    -- Incluir nome do módulo logado - Chamado 721285 31/07/2017
		  GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL); 

      IF vr_dscritic IS NOT NULL THEN
        -- Gerar exceção
        RAISE vr_exc_saida;
      END IF;

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_clobxml);
      dbms_lob.freetemporary(vr_clobxml);
      v_gerar := FALSE;
      /* Contas sem movimentacao nos ultimos 6 meses */

      IF to_number(to_char(rw_crapdat.dtmvtolt, 'mm')) = 1  THEN       /* Se Janeiro */
        vr_dtmvtolt := to_date('07'||to_char(rw_crapdat.dtmvtolt,'dd')||to_number(to_char(rw_crapdat.dtmvtolt,'yyyy')-1) , 'mmddyyyy');
      ELSIF  to_number(to_char(rw_crapdat.dtmvtolt,'mm')) = 2  THEN /* Fevereiro */
        vr_dtmvtolt := to_date('08'||to_char(rw_crapdat.dtmvtolt,'dd')||to_number(to_char(rw_crapdat.dtmvtolt,'yyyy')-1) , 'mmddyyyy');
      ELSIF to_number(to_char(rw_crapdat.dtmvtolt,'mm')) = 3  THEN /* Marco */
        vr_dtmvtolt := to_date('09'||to_char(rw_crapdat.dtmvtolt,'dd')||to_number(to_char(rw_crapdat.dtmvtolt,'yyyy')-1) , 'mmddyyyy');
      ELSIF to_number(to_char(rw_crapdat.dtmvtolt,'mm')) = 4  THEN /* Abril */
        vr_dtmvtolt := to_date('10'||to_char(rw_crapdat.dtmvtolt,'dd')||to_number(to_char(rw_crapdat.dtmvtolt,'yyyy')-1) , 'mmddyyyy');
      ELSIF to_number(to_char(rw_crapdat.dtmvtolt,'mm')) = 5  THEN  /* Maio */
        vr_dtmvtolt := to_date('11'||to_char(rw_crapdat.dtmvtolt,'dd')||to_number(to_char(rw_crapdat.dtmvtolt,'yyyy')-1) , 'mmddyyyy');
      ELSIF to_number(to_char(rw_crapdat.dtmvtolt,'mm')) = 6  THEN /* Junho */
        vr_dtmvtolt := to_date('12'||to_char(rw_crapdat.dtmvtolt,'dd')||to_number(to_char(rw_crapdat.dtmvtolt,'yyyy')-1) , 'mmddyyyy');
      ELSE
        vr_dtmvtolt := add_months(rw_crapdat.dtmvtolt,-6); --diminui 6 meses a data mov.
      END IF;
      FOR rw_crapass2 IN cr_crapass2 --busca associados com conta itg cadastrados
      LOOP
        EXIT WHEN cr_crapass2%NOTFOUND;
        vr_dataativ := NULL;
        FOR rw_crapalt IN cr_crapalt(rw_crapass2.nrdconta)
        LOOP--busca alteracoes de recadastramento
          EXIT WHEN cr_crapalt%NOTFOUND;
          vr_dsaltera_lob := UPPER(rw_crapalt.dsaltera);
          -- veririca se teve alteracao de reativacao conta itg
          IF vr_dsaltera_lob like '%REATIVACAO CONTA-ITG%'THEN
            vr_dataativ := rw_crapalt.dtaltera; --utilizar data da atualizacao dos dados
            EXIT;
          END IF;
        END LOOP;
        --verifica se a data mov. é maior que a data ativacao
        IF nvl(vr_dataativ,rw_crapass2.dtabcitg) <= vr_dtmvtolt THEN
          OPEN cr_crawcrd2(rw_crapass2.nrdconta);--verificar cadastro de cartoes credito
          FETCH cr_crawcrd2 INTO rw_crawcrd;
          OPEN cr_craplcm2(rw_crapass2.nrdconta);--verificar lancamentos deposito
          FETCH cr_craplcm2 INTO rw_craplcm2;
          /* Se nao possuir lancamento e nao possuir cartao Multiplo BB */
          IF cr_crawcrd2%NOTFOUND AND
             cr_craplcm2%NOTFOUND THEN
             /* Para todos estes historicos */
             OPEN cr_craplcm3(rw_crapass2.nrdconta);--busca data de lancamento deposito
             FETCH cr_craplcm3 INTO vr_rel_dtmvtolt;
             CLOSE cr_craplcm3;

             --verificar situacao da conta
             IF rw_crapass2.cdsitdct = 1 THEN
                vr_rel_dssitdct := 'NORMAL';
             ELSIF rw_crapass2.cdsitdct = 2 THEN
                vr_rel_dssitdct := 'ENCERRADA P/ASSOCIADO';
             ELSIF rw_crapass2.cdsitdct = 3 THEN
                vr_rel_dssitdct := 'ENCERRADA P/COOP';
             ELSIF rw_crapass2.cdsitdct = 4 THEN
                vr_rel_dssitdct := 'ENCERRADA P/DEMISSAO';
             ELSIF rw_crapass2.cdsitdct = 5 THEN
                vr_rel_dssitdct := 'NAO APROVADA';
             ELSIF rw_crapass2.cdsitdct = 6 THEN
                vr_rel_dssitdct := 'NORMAL - SEM TALAO';
             ELSIF rw_crapass2.cdsitdct = 9 THEN
                vr_rel_dssitdct := 'ENCERRADA P/OUTRO MOTIVO';
             ELSE
                vr_rel_dssitdct := NULL;
             END IF;

             vr_qtchfora := NULL;
             vr_qtchqarq := NULL;
             vr_qtpdfora := NULL;
             vr_qtrqfora := NULL;
             --verificar cadastro de emissao de cheques
             FOR rw_crapfdc IN cr_crapfdc(rw_crapass2.nrdconta,
                                          rw_crapass2.nrdctitg)
             LOOP
                EXIT WHEN cr_crapfdc%NOTFOUND;
                /* Verifica se existe cheque fora */
                IF rw_crapfdc.dtretchq IS NOT NULL AND
                   rw_crapfdc.dtliqchq IS NULL AND
                   rw_crapfdc.incheque <> 1    THEN
                   vr_qtchfora := nvl(vr_qtchfora,0) + 1;
                END IF;
                /* Verifica se existe cheque em arquivo */
               IF rw_crapfdc.dtemschq IS NOT NULL AND
                  rw_crapfdc.dtretchq IS NULL  THEN
                  vr_qtchqarq := nvl(vr_qtchqarq,0) + 1;
               END IF;

               /* Verifica se existe pedido fora */
               IF rw_crapfdc.dtemschq IS NULL  THEN
                  vr_qtpdfora := nvl(vr_qtpdfora,0) + 1;
               END IF;
             END LOOP;
             /* Verifica se existe requisicao fora */
             OPEN cr_crapreq(rw_crapass2.nrdconta);
             FETCH cr_crapreq INTO vr_qtrqfora;
             CLOSE cr_crapreq;
             OPEN cr_crapage(rw_crapass2.cdagenci);--busca nome PA
             FETCH cr_crapage INTO vr_nmresage;
             CLOSE cr_crapage;
             --popula temp table
             vr_des_chave := lpad(rw_crapass2.cdagenci,5,'0')||lpad(rw_crapass2.nrdconta,10,'0');
             vr_tab_relato(vr_des_chave).titulo   := vr_nmresage||
                                                     ' - CONTAS INTEGRACAO SEM MOVIMENTOS NOS ULTIMOS 6 MESES - CONSIDERANDO ATE '||
                                                     to_char(rw_crapdat.dtmvtoan,'dd/mm/yy');

             vr_tab_relato(vr_des_chave).cdagenci := rw_crapass2.cdagenci;
             vr_tab_relato(vr_des_chave).nrdconta := rw_crapass2.nrdconta;
             vr_tab_relato(vr_des_chave).nmprintl := rw_crapass2.nmprimtl;
             vr_tab_relato(vr_des_chave).dssitdct := vr_rel_dssitdct;
             vr_tab_relato(vr_des_chave).nrdctitg := rw_crapass2.nrdctitg;
             vr_tab_relato(vr_des_chave).dtmvtolt := vr_rel_dtmvtolt;
             vr_tab_relato(vr_des_chave).dtdemiss := rw_crapass2.dtdemiss;
             vr_tab_relato(vr_des_chave).qtchfora := vr_qtchfora;
             vr_tab_relato(vr_des_chave).qtchqarq := vr_qtchqarq;
             vr_tab_relato(vr_des_chave).qtpdfora := vr_qtpdfora;
             vr_tab_relato(vr_des_chave).qtrqfora := vr_qtrqfora;
             v_gerar := TRUE;
          END IF;
          CLOSE cr_crawcrd2;
          CLOSE cr_craplcm2;
        END IF;
      END LOOP;

      IF v_gerar = TRUE THEN
        --primeiro registro
        vr_des_chave := vr_tab_relato.first;
        vr_nmarqim := 'crrl442_'||lpad(vr_tab_relato(vr_des_chave).cdagenci,3, '0')||'.lst';

        -- cria clob
        dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
        dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);
        pc_escreve_clob(vr_clobxml,'<?xml version="1.0" encoding="utf-8"?><raiz>');
        WHILE vr_des_chave IS NOT NULL --varrer temp table
        LOOP
          --primeiro registro ou mudar o PA
          IF vr_des_chave = vr_tab_relato.first OR vr_tab_relato(vr_des_chave).cdagenci <> vr_tab_relato(vr_tab_relato.PRIOR(vr_des_chave)).cdagenci THEN
            OPEN cr_crapage(vr_tab_relato(vr_des_chave).cdagenci);--busca nome PA
            FETCH cr_crapage INTO vr_nmresage;
            CLOSE cr_crapage;
            IF vr_nmresage IS NULL THEN
              vr_nmresage := '- PA NAO CADASTRADO.';
            END IF;
            vr_nmarqim := '/crrl442_'||lpad(vr_tab_relato(vr_des_chave).cdagenci,3, '0')||'.lst';
          END IF;

          --cria xml
          pc_escreve_clob(vr_clobxml, '<datas>'
                                    ||'  <titulo>'||vr_tab_relato(vr_des_chave).titulo||'</titulo>'
                                    ||'  <pa>'||vr_tab_relato(vr_des_chave).cdagenci||'</pa>'
                                    ||'  <conta>'||LTRIM(gene0002.fn_mask_conta(vr_tab_relato(vr_des_chave).nrdconta))||'</conta>'
                                    ||'  <titular>'||substr(vr_tab_relato(vr_des_chave).nmprintl,1,25)||'</titular>'
                                    ||'  <situacao>'||vr_tab_relato(vr_des_chave).dssitdct||'</situacao>'
                                    ||'  <cont_itg>'||LTRIM(gene0002.fn_mask_ctitg(vr_tab_relato(vr_des_chave).nrdctitg))||'</cont_itg>'
                                    ||'  <dt_lanc>'||to_char(vr_tab_relato(vr_des_chave).dtmvtolt,'dd/mm/yy')||'</dt_lanc>'
                                    ||'  <dt_demi>'||to_char(vr_tab_relato(vr_des_chave).dtdemiss,'dd/mm/yy')||'</dt_demi>'
                                    ||'  <chq_fora>'||vr_tab_relato(vr_des_chave).qtchfora||'</chq_fora>'
                                    ||'  <chq_arq>'||vr_tab_relato(vr_des_chave).qtchqarq||'</chq_arq>'
                                    ||'  <qt_fora>'||vr_tab_relato(vr_des_chave).qtpdfora||'</qt_fora>'
                                    ||'  <req_pend>'||vr_tab_relato(vr_des_chave).qtrqfora||'</req_pend>'
                                    ||'</datas>') ;
                                       
	        -- Incluir nome do módulo logado - Chamado 721285 31/07/2017
    		  GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL); 

          -- se for ultimo registro ou mudar o PA, fecha tag raiz
          IF vr_des_chave = vr_tab_relato.last OR
             vr_tab_relato(vr_des_chave).cdagenci <> vr_tab_relato(vr_tab_relato.NEXT(vr_des_chave)).cdagenci THEN
             pc_escreve_clob(vr_clobxml,'</raiz>');
                --busca diretorio padrao da cooperativa
             vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                                   ,pr_cdcooper => pr_cdcooper
                                                   ,pr_nmsubdir => 'rl');

             --solicita relatorio crrl442
             gene0002.pc_solicita_relato( pr_cdcooper  => pr_cdcooper                              --> Cooperativa conectada
                                         ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                                         ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                  --> Data do movimento atual
                                         ,pr_dsxml     => vr_clobxml                           --> Arquivo XML de dados
                                         ,pr_dsxmlnode => '/raiz/datas'                              --> Nó base do XML para leitura dos dados
                                         ,pr_dsjasper  => 'crrl442.jasper'                     --> Arquivo de layout do iReport
                                         ,pr_dsparams  => null                                 --> Sem parâmetros
                                         ,pr_dsarqsaid => vr_nom_direto||vr_nmarqim            --> Arquivo final com o path
                                         ,pr_qtcoluna  => 132                                  --> 132 colunas
                                         ,pr_flg_gerar => 'N'                                  --> Geraçao na hora
                                         ,pr_flg_impri => 'S'                                  --> Chamar a impressão (Imprim.p)
                                         ,pr_nmformul  => ''                                   --> Nome do formulário para impressão
                                         ,pr_nrcopias  => 3                                    --> Número de cópias
                                         ,pr_sqcabrel  => 2                                    --> Qual a seq do cabrel
                                         ,pr_des_erro  => vr_dscritic);                       --> Saída com erro
                                       
	           -- Incluir nome do módulo logado - Chamado 721285 31/07/2017
       		   GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL); 

             IF vr_dscritic IS NOT NULL THEN
             -- Gerar exceção
              RAISE vr_exc_saida;
             END IF;
             -- Liberando a memória alocada pro CLOB
             dbms_lob.close(vr_clobxml);
             dbms_lob.freetemporary(vr_clobxml);
             --cria novamente clob para proximo PA
             dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
             dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);
             pc_escreve_clob(vr_clobxml,'<?xml version="1.0" encoding="utf-8"?><raiz>');
           END IF;
             -- Buscar o proximo
          vr_des_chave := vr_tab_relato.NEXT(vr_des_chave);

        END LOOP;
        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_clobxml);
        dbms_lob.freetemporary(vr_clobxml);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 31/07/2017 - Chamado 721285        
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
        -- Efetuar retorno do erro não tratado
        vr_cdcritic := 0;
        vr_dscritic := sqlerrm;
        -- Gerar exceção
        RAISE vr_exc_saida;      
    END pc_processar;
      
    --------------- VALIDACOES INICIAIS -----------------

    BEGIN
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


      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
      --força data ser dia 25 do mes movimentacao
      vr_diadopro := to_date(to_char(rw_crapdat.dtmvtolt, 'mm')||'25'||to_char(rw_crapdat.dtmvtolt, 'yyyy'),'mmddyyyy');    

      --verifica se o se dia é util senao busca o proximo dia util
      vr_diadopro := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,pr_dtmvtolt => vr_diadopro);

      /* Rodar sempre no dia 25 ou proximo dia util */
      IF rw_crapdat.dtmvtolt =  vr_diadopro  THEN
        pc_processar;
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
      WHEN vr_exc_saida THEN
        -- Ajustada chamada para buscar a descrição da critica - 31/07/2017 - Chamado 721285
        -- Devolvemos código e critica encontradas das variaveis locais
        pr_cdcritic := nvl(vr_cdcritic,0);
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic, vr_dscritic);
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 31/07/2017 - Chamado 721285        
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
    END;

  END pc_crps466;
/
