CREATE OR REPLACE PROCEDURE CECRED.
         pc_crps416 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
/* ..........................................................................

   Programa: pc_crps416 (Fontes/crps416.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Novembro/2004                   Ultima atualizacao: 19/12/2013

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 86.
               Gerar relatorio 376 - Acompanhamento de alienacoes fiduciarias.

   Alteracoes: 06/02/2006 - Acrescentada Listagem Alienacoes de Imoveis
                            (Diego).

               17/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               17/01/2013 - Tratamento no for crapepr onde tinha inliquid = 1
                            incluido crapepr.flliqmen (Lucas R.)

               28/03/2013 - Incluir YEAR(crapepr.dtultpag) na consulta de
                            alienacoes liquidadas (Lucas R.).

               09/09/2013 - Nova forma de chamar as agencias, de PAC agora
                            a escrita será PA (André Euzébio - Supero).

               19/12/2013 - Conversão Progress para PLSQL (Andrino/RKAM)

               12/12/2013 - Alterado label da variavel aux_nrcpfcgc do form
                            f_liquid de "CPF/CGC" para "CPF/CNPJ". (Reinert)

............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS416';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

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

      -- Busca das ALIENACOES FIDUCIARIAS / NOVAS ALIENACOES
      CURSOR cr_crapepr(pr_dtmvtolt IN DATE) IS
        SELECT crapepr.cdagenci,
               crapepr.nrdconta,
               crapass.nmprimtl,
               crapepr.nrctremp,
               crapepr.cdlcremp,
               crapepr.vlemprst,
               crapass.inpessoa,
               crapass.nrcpfcgc
          FROM crapass,
               crapepr
         WHERE crapepr.cdcooper = pr_cdcooper
           AND crapepr.dtmvtolt = pr_dtmvtolt
           -- Buscar somente as linhas de credito de alienacoes fiduciarias
           AND crapepr.cdlcremp IN (SELECT craplcr.cdlcremp -- busca o codigo da linha de credito
                                      FROM craplcr  -- Cadastro de linhas de credito
                                     WHERE craplcr.cdcooper = pr_cdcooper
                                       AND craplcr.tpctrato = 2) -- Tipo de contrato igual a 2
           AND crapepr.inliquid = 0 -- Nao liquidado
           AND crapass.cdcooper = crapepr.cdcooper
           AND crapass.nrdconta = crapepr.nrdconta
         ORDER BY crapepr.cdagenci,
                  crapepr.nrdconta,
                  crapepr.nrctremp;

      -- Busca das ALIENACOES FIDUCIARIAS / ALIENACOES LIQUIDADAS
      CURSOR cr_crapepr_liq(pr_dtmvtolt IN DATE) IS
        SELECT crapepr.cdagenci,
               crapepr.nrdconta,
               crapass.nmprimtl,
               crapepr.nrctremp,
               crapepr.cdlcremp,
               crapepr.vlemprst,
               crapass.inpessoa,
               crapass.nrcpfcgc
          FROM crapass,
               crapepr
         WHERE crapepr.cdcooper = pr_cdcooper
           -- Buscar somente as linhas de credito de alienacoes fiduciarias
           AND crapepr.cdlcremp IN (SELECT craplcr.cdlcremp -- busca o codigo da linha de credito
                                      FROM craplcr  -- Cadastro de linhas de credito
                                     WHERE craplcr.cdcooper = pr_cdcooper
                                       AND craplcr.tpctrato = 2) -- Tipo de contrato igual a 2
           AND crapepr.inliquid = 1 -- Ja liquidada
           AND crapass.cdcooper = crapepr.cdcooper
           AND crapass.nrdconta = crapepr.nrdconta
           AND (crapepr.dtultpag = pr_dtmvtolt
            OR (crapepr.flliqmen = 1 -- Emprestimo liquidado no mensal
            AND trunc(crapepr.dtultpag,'MM') = trunc(pr_dtmvtolt,'MM'))) -- O Trunc ira cortar o dia, ou seja, comparará somente o mes e ano das datas
         ORDER BY crapepr.cdagenci,
                  crapepr.nrdconta,
                  crapepr.nrctremp;


      -- Busca das ALIENACOES DE IMOVEIS / NOVAS ALIENACOES
      CURSOR cr_crapepr_imovel(pr_dtmvtolt IN DATE) IS
        SELECT crapepr.cdagenci,
               crapepr.nrdconta,
               crapass.nmprimtl,
               crapepr.nrctremp,
               crapepr.cdlcremp,
               crapepr.vlemprst,
               crapass.inpessoa,
               crapass.nrcpfcgc
          FROM crapass,
               crapepr
         WHERE crapepr.cdcooper = pr_cdcooper
           AND crapepr.dtmvtolt = pr_dtmvtolt
           -- Buscar somente as linhas de credito de imoveis
           AND crapepr.cdlcremp IN (392,  --HIPOTECA/ALIEN.BEM IMOVEL
                                    395,  --COTAS CAPITAL I /HIPOTEC/ALIEN
                                    396)  --COTAS CAPITAL/HIPOTECA/ALIENAC
           AND crapepr.inliquid = 0 -- Nao liquidado
           AND crapass.cdcooper = crapepr.cdcooper
           AND crapass.nrdconta = crapepr.nrdconta
         ORDER BY crapepr.cdagenci,
                  crapepr.nrdconta,
                  crapepr.nrctremp;


      -- Busca das ALIENACOES DE IMOVEIS / ALIENACOES LIQUIDADAS
      CURSOR cr_crapepr_imovel_liq(pr_dtmvtolt IN DATE) IS
        SELECT crapepr.cdagenci,
               crapepr.nrdconta,
               crapass.nmprimtl,
               crapepr.nrctremp,
               crapepr.cdlcremp,
               crapepr.vlemprst,
               crapass.inpessoa,
               crapass.nrcpfcgc
          FROM crapass,
               crapepr
         WHERE crapepr.cdcooper = pr_cdcooper
           AND crapepr.inliquid = 1 -- Ja liquidada
           -- Buscar somente as linhas de credito de imoveis
           AND crapepr.cdlcremp IN (392,  --HIPOTECA/ALIEN.BEM IMOVEL
                                    395,  --COTAS CAPITAL I /HIPOTEC/ALIEN
                                    396)  --COTAS CAPITAL/HIPOTECA/ALIENAC
           AND crapass.cdcooper = crapepr.cdcooper
           AND crapass.nrdconta = crapepr.nrdconta
           AND (crapepr.dtultpag = pr_dtmvtolt
            OR (crapepr.flliqmen = 1 -- Emprestimo liquidado no mensal
            AND trunc(crapepr.dtultpag,'MM') = trunc(pr_dtmvtolt,'MM'))) -- O Trunc ira cortar o dia, ou seja, comparará somente o mes e ano das datas
         ORDER BY crapepr.cdagenci,
                  crapepr.nrdconta,
                  crapepr.nrctremp;

      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

      ------------------------------- VARIAVEIS -------------------------------
      -- Variaveis acumuladoras
      vr_vlltotal crapepr.vlemprst%TYPE := 0;
      vr_flgdados VARCHAR2(01) := 'N';           -- Flag de existencia de informacoes

      -- Variável de Controle de XML
      vr_des_xml    CLOB;
      vr_path_arquivo VARCHAR2(200);

      --------------------------- SUBROTINAS INTERNAS --------------------------
	    --Procedure que escreve linha no arquivo CLOB
	    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
      BEGIN
        --Escrever no arquivo CLOB
        dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
      END;

    BEGIN -- Rotina principal

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

      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------

      -- Inicializar o CLOB
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

      -------------------------------------------
      -- Iniciando a geração do XML
      -------------------------------------------
      pc_escreve_xml('<?xml version="1.0" encoding="WINDOWS-1252"?>'||
                        '<crrl376>'||
                          '<grupo id="==>  ALIENACOES FIDUCIARIAS" tx="NOVAS ALIENACOES" tit="CPF/CNPJ">');

      -- busca as ALIENACOES FIDUCIARIAS / NOVAS ALIENACOES
      FOR rw_crapepr IN cr_crapepr(rw_crapdat.dtmvtolt) LOOP
        -- Escreve os detalhes das ALIENACOES FIDUCIARIAS / NOVAS ALIENACOES
        pc_escreve_xml('<detalhes>'||
                         '<cdagenci>'||rw_crapepr.cdagenci                                                ||'</cdagenci>'||
                         '<nrdconta>'||gene0002.fn_mask_conta(rw_crapepr.nrdconta)                        ||'</nrdconta>'||
                         '<nmprimtl>'||rw_crapepr.nmprimtl                                                ||'</nmprimtl>'||
                         '<nrcpfcgc>'||gene0002.fn_mask_cpf_cnpj(rw_crapepr.nrcpfcgc, rw_crapepr.inpessoa)||'</nrcpfcgc>'||
                         '<nrctremp>'||to_char(rw_crapepr.nrctremp,'999G999G990')                         ||'</nrctremp>'||
                         '<cdlcremp>'||rw_crapepr.cdlcremp                                                ||'</cdlcremp>'||
                         '<vlemprst>'||to_char(rw_crapepr.vlemprst,'999G999G990D00')                      ||'</vlemprst>'||
                       '</detalhes>');
        -- Acumula a variavel de total
        vr_vlltotal := vr_vlltotal + rw_crapepr.vlemprst;
        vr_flgdados := 'S';
      END LOOP;

      -- Imprime o total
      pc_escreve_xml(  '<total>'||trim(to_char(vr_vlltotal,'999G999G990D00'))||'</total>'||
                     '</grupo>'||
                     '<grupo id="" tx="ALIENACOES LIQUIDADAS" tit="CPF/CNPJ">');

      -- Zera o totalizador
      vr_vlltotal := 0;

      -- busca as ALIENACOES FIDUCIARIAS / ALIENACOES LIQUIDADAS
      FOR rw_crapepr IN cr_crapepr_liq(rw_crapdat.dtmvtolt) LOOP
        -- Escreve os detalhes das ALIENACOES FIDUCIARIAS / ALIENACOES LIQUIDADAS
        pc_escreve_xml('<detalhes>'||
                         '<cdagenci>'||rw_crapepr.cdagenci                                                ||'</cdagenci>'||
                         '<nrdconta>'||gene0002.fn_mask_conta(rw_crapepr.nrdconta)                        ||'</nrdconta>'||
                         '<nmprimtl>'||rw_crapepr.nmprimtl                                                ||'</nmprimtl>'||
                         '<nrcpfcgc>'||gene0002.fn_mask_cpf_cnpj(rw_crapepr.nrcpfcgc, rw_crapepr.inpessoa)||'</nrcpfcgc>'||
                         '<nrctremp>'||to_char(rw_crapepr.nrctremp,'999G999G990')                         ||'</nrctremp>'||
                         '<cdlcremp>'||rw_crapepr.cdlcremp                                                ||'</cdlcremp>'||
                         '<vlemprst>'||to_char(rw_crapepr.vlemprst,'999G999G990D00')                      ||'</vlemprst>'||
                       '</detalhes>');
        -- Acumula a variavel de total
        vr_vlltotal := vr_vlltotal + rw_crapepr.vlemprst;
        vr_flgdados := 'S';
      END LOOP;

      -- Imprime o total
      pc_escreve_xml(  '<total>'||trim(to_char(vr_vlltotal,'999G999G990D00'))||'</total>'||
                     '</grupo>'||
                     '<grupo id="==>  ALIENACOES DE IMOVEIS" tx="NOVAS ALIENACOES" tit="CPF/CNPJ">');

      -- Zera o totalizador
      vr_vlltotal := 0;


      -- busca as ALIENACOES DE IMOVEIS / NOVAS ALIENACOES
      FOR rw_crapepr IN cr_crapepr_imovel(rw_crapdat.dtmvtolt) LOOP
        -- Escreve os detalhes das ALIENACOES DE IMOVEIS / NOVAS ALIENACOES
        pc_escreve_xml('<detalhes>'||
                         '<cdagenci>'||rw_crapepr.cdagenci                                                ||'</cdagenci>'||
                         '<nrdconta>'||gene0002.fn_mask_conta(rw_crapepr.nrdconta)                        ||'</nrdconta>'||
                         '<nmprimtl>'||rw_crapepr.nmprimtl                                                ||'</nmprimtl>'||
                         '<nrcpfcgc>'||gene0002.fn_mask_cpf_cnpj(rw_crapepr.nrcpfcgc, rw_crapepr.inpessoa)||'</nrcpfcgc>'||
                         '<nrctremp>'||to_char(rw_crapepr.nrctremp,'999G999G990')                         ||'</nrctremp>'||
                         '<cdlcremp>'||rw_crapepr.cdlcremp                                                ||'</cdlcremp>'||
                         '<vlemprst>'||to_char(rw_crapepr.vlemprst,'999G999G990D00')                      ||'</vlemprst>'||
                       '</detalhes>');
        -- Acumula a variavel de total
        vr_vlltotal := vr_vlltotal + rw_crapepr.vlemprst;
        vr_flgdados := 'S';
      END LOOP;

      -- Imprime o total
      pc_escreve_xml(  '<total>'||trim(to_char(vr_vlltotal,'999G999G990D00'))||'</total>'||
                     '</grupo>'||
                     '<grupo id="" tx="ALIENACOES LIQUIDADAS" tit="CPF/CNPJ">');

      -- Zera o totalizador
      vr_vlltotal := 0;


      -- busca as ALIENACOES DE IMOVEIS / ALIENACOES LIQUIDADAS
      FOR rw_crapepr IN cr_crapepr_imovel_liq(rw_crapdat.dtmvtolt) LOOP
        -- Escreve os detalhes das ALIENACOES DE IMOVEIS / ALIENACOES LIQUIDADAS
        pc_escreve_xml('<detalhes>'||
                         '<cdagenci>'||rw_crapepr.cdagenci                                                ||'</cdagenci>'||
                         '<nrdconta>'||gene0002.fn_mask_conta(rw_crapepr.nrdconta)                        ||'</nrdconta>'||
                         '<nmprimtl>'||rw_crapepr.nmprimtl                                                ||'</nmprimtl>'||
                         '<nrcpfcgc>'||gene0002.fn_mask_cpf_cnpj(rw_crapepr.nrcpfcgc, rw_crapepr.inpessoa)||'</nrcpfcgc>'||
                         '<nrctremp>'||to_char(rw_crapepr.nrctremp,'999G999G990')                         ||'</nrctremp>'||
                         '<cdlcremp>'||rw_crapepr.cdlcremp                                                ||'</cdlcremp>'||
                         '<vlemprst>'||to_char(rw_crapepr.vlemprst,'999G999G990D00')                      ||'</vlemprst>'||
                       '</detalhes>');
        -- Acumula a variavel de total
        vr_vlltotal := vr_vlltotal + rw_crapepr.vlemprst;
        vr_flgdados := 'S';
      END LOOP;

      -- Imprime o total
      pc_escreve_xml(  '<total>'||trim(to_char(vr_vlltotal,'999G999G990D00'))||'</total>'||
                     '</grupo>'||
                     '</crrl376>');


      -- Busca do diretório base da cooperativa e a subpasta de relatórios
      vr_path_arquivo := gene0001.fn_diretorio( pr_tpdireto => 'C' -- /usr/coop
                                             ,pr_cdcooper => pr_cdcooper
                                             ,pr_nmsubdir => '/rl'); --> Gerado no diretorio /rl


      -- Chamada do iReport para gerar o arquivo de saida
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,                    --> Cooperativa conectada
                                  pr_cdprogra  => vr_cdprogra,                    --> Programa chamador
                                  pr_dtmvtolt  => rw_crapdat.dtmvtolt,            --> Data do movimento atual
                                  pr_dsxml     => vr_des_xml,                     --> Arquivo XML de dados (CLOB)
                                  pr_dsxmlnode => '/crrl376/grupo',               --> No base do XML para leitura dos dados
                                  pr_dsjasper  => 'crrl376.jasper',               --> Arquivo de layout do iReport
                                  pr_dsparams  => null,                           --> Nao enviar parametro
                                  pr_dsarqsaid => vr_path_arquivo||'/crrl376.lst', --> Arquivo final
                                  pr_flg_gerar => 'N',                            --> Não gerar o arquivo na hora
                                  pr_qtcoluna  => 132,                            --> Quantidade de colunas
                                  pr_nmformul  => '132col',                       --> Nome do formulario
                                  pr_sqcabrel  => 1,                              --> Sequencia do cabecalho
                                  pr_flg_impri => vr_flgdados,                    --> Chamar a impressão (Imprim.p)
                                  pr_nrcopias  => 1,                              --> Numero de copias
                                  pr_des_erro  => vr_dscritic);                   --> Saida com erro

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);

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

  END pc_crps416;
/

