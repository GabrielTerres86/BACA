CREATE OR REPLACE PROCEDURE CECRED.
         pc_crps401 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
/* ............................................................................

   Programa: pc_crps401 (Fontes/crps401.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo.
   Data    : Novembro/2004.                     Ultima atualizacao: 19/12/2013

   Dados referentes ao programa:

   Frequencia : Mensal.
   Objetivo   : Atende a solicitacao 4.
                Listar os cheques devolvidos durante os 3 ultimos mes -
                Auditoria.
                Emite relatorio 360.

   Alteracoes: 07/10/2005 - Alterado para ler tbm na tabela crapali o codigo
                            da cooperativa (Diego).

               15/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

               16/08/2013 - Nova forma de chamar as agencias, de PAC agora
                            a escrita será PA (André Euzébio - Supero).

               19/12/2013 - Conversão Progress para PLSQL (Andrino/RKAM)

............................................................................. */


    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS401';

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

      -- Cursor sobre os cheques devolvidos
      CURSOR cr_crapneg (pr_dtinicio DATE,
                         pr_dttermin DATE) IS
        SELECT crapass.nrdconta,
               lpad(crapass.cdagenci,3,' ') || ' - ' || crapage.nmresage cdagenci,
               crapass.nmprimtl,
               crapneg.dtiniest,
               crapneg.nrdocmto,
               crapneg.vlestour,
               crapneg.cdobserv,
               ROW_NUMBER () OVER (PARTITION BY crapass.cdagenci ORDER BY crapass.cdagenci) nrseq,
               COUNT(1)      OVER (PARTITION BY crapass.cdagenci ORDER BY crapass.cdagenci) qtreg,
               SUM(crapneg.vlestour) OVER (PARTITION BY crapass.cdagenci ORDER BY crapass.cdagenci) tot_vlestour
          FROM crapage,
               crapass,
               crapneg
         WHERE crapneg.cdcooper = pr_cdcooper
           AND crapneg.nrdctabb > 0
           AND crapneg.dtiniest >= pr_dtinicio
           AND crapneg.dtiniest <= pr_dttermin
           AND crapass.cdcooper = crapneg.cdcooper
           AND crapass.nrdconta = crapneg.nrdconta
           AND crapage.cdcooper = crapass.cdcooper
           AND crapage.cdagenci = crapass.cdagenci
         ORDER BY crapass.cdagenci,
                  crapneg.dtiniest,
                  crapneg.nrdconta,
                  crapneg.progress_recid DESC;


      -- cursor de observacoes Aliena
      CURSOR cr_crapali IS
        SELECT crapali.cdalinea,
               crapali.dsalinea
          FROM crapali;

      ---------------------------- TEMP TABLES ---------------------
      -- Registro para a observacao alinea
      TYPE typ_reg_crapali IS
        RECORD(dsalinea crapali.dsalinea%TYPE);
      -- Definicao do tipo da tabela de observacao alinea
      TYPE typ_tab_crapali IS
        TABLE OF typ_reg_crapali
          INDEX BY BINARY_INTEGER;
      -- Vetor para armazenar os dados de resumo
      vr_tab_crapali typ_tab_crapali;

      ------------------------------- VARIAVEIS -------------------------------

      -- Variável de Controle de XML
      vr_des_xml      CLOB;
      vr_path_arquivo VARCHAR2(200);
      vr_dsobserv     VARCHAR2(500);

      -- Variaveis acumuladoras do relatorio
      vr_tot_geral    crapneg.vlestour%TYPE := 0;
      vr_qtd_geral    PLS_INTEGER := 0;

      --------------------------- SUBROTINAS INTERNAS --------------------------
	    --Procedure que escreve linha no arquivo CLOB
	    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
      BEGIN
        --Escrever no arquivo CLOB
        dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
      END;

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

      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------

      -- Popula a pl_table de alinea
      FOR rw_crapali IN cr_crapali LOOP
        vr_tab_crapali(rw_crapali.cdalinea).dsalinea := rw_crapali.dsalinea;
      END LOOP;

      -- Inicializar o CLOB
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

      -------------------------------------------
      -- Iniciando a geração do XML
      -------------------------------------------
      pc_escreve_xml('<?xml version="1.0" encoding="WINDOWS-1252"?>'||
                        '<crrl360>');

      -- Retornar os cheques devolvidos com data entre o primeiro dia três meses antes e o último dia do mês anterior.
      FOR rw_crapneg IN cr_crapneg(pr_dtinicio => trunc(add_months(rw_crapdat.dtmvtolt,-3),'MM'),
                                   pr_dttermin => last_day(add_months(rw_crapdat.dtmvtolt,-1))) LOOP

        -- Se for o primeiro registro da agencia, insere os dados do cabecalho
        IF rw_crapneg.nrseq = 1 THEN
          pc_escreve_xml('<agencia>' ||
                          '<cdagenci>'|| rw_crapneg.cdagenci||'</cdagenci>');
        END IF;

        -- Tratamento para a observacao. Se existir alinea, busca a descricao da aliena
        IF vr_tab_crapali.exists(rw_crapneg.cdobserv) THEN
          vr_dsobserv := to_char(rw_crapneg.cdobserv, '000') || ' - ' || substr(vr_tab_crapali(rw_crapneg.cdobserv).dsalinea,1,23);
        ELSE
          vr_dsobserv := to_char(rw_crapneg.cdobserv, '000') || ' - EXCLUIDO';
        END IF;

        -- Escreve os dados do detalhe
        pc_escreve_xml('<detalhe>'   ||
                         '<nrdconta>'|| gene0002.fn_mask_conta(rw_crapneg.nrdconta)     ||'</nrdconta>' ||
                         '<nmprimtl>'|| substr(rw_crapneg.nmprimtl,1,40)                ||'</nmprimtl>' ||
                         '<dtiniest>'|| to_char(rw_crapneg.dtiniest,'dd/mm/yyyy')       ||'</dtiniest>' ||
                         '<nrdocmto>'|| to_char(rw_crapneg.nrdocmto,'fm999G999G9')    ||'</nrdocmto>' ||
                         '<vlestour>'|| to_char(rw_crapneg.vlestour,'fm999G999G990D00') ||'</vlestour>' ||
                         '<dsobserv>'|| vr_dsobserv                                     ||'</dsobserv>' ||
                       '</detalhe>');

        -- Se for o ultimo registro da agencia, insere os totais e fecha o nos
        IF rw_crapneg.nrseq = rw_crapneg.qtreg THEN
          pc_escreve_xml(  '<tot_agencia>'|| to_char(rw_crapneg.tot_vlestour,'fm999G999G990D00')||'</tot_agencia>'||
                           '<qtd_agencia>'|| to_char(rw_crapneg.qtreg,'999G990')               ||'</qtd_agencia>'||
                         '</agencia>');

          -- Acumula o total da agencia no total geral
          vr_tot_geral := vr_tot_geral + rw_crapneg.tot_vlestour;
          vr_qtd_geral := vr_qtd_geral + rw_crapneg.qtreg;
        END IF;

      END LOOP;

      -- Escreve o total geral e fecha o no
      pc_escreve_xml(  '<tot_geral>'|| to_char(vr_tot_geral,'fm999G999G990D00')||'</tot_geral>'||
                       '<qtd_geral>'|| to_char(vr_qtd_geral,'999G990')               ||'</qtd_geral>'||
                     '</crrl360>');

      -- Busca do diretório base da cooperativa e a subpasta de relatórios
      vr_path_arquivo := gene0001.fn_diretorio( pr_tpdireto => 'C' -- /usr/coop
                                             ,pr_cdcooper => pr_cdcooper
                                             ,pr_nmsubdir => '/rl'); --> Gerado no diretorio /rl

      -- Imprimir somente se possuir registros
      IF vr_qtd_geral > 0 THEN
        -- Chamada do iReport para gerar o arquivo de saida
        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,                    --> Cooperativa conectada
                                    pr_cdprogra  => vr_cdprogra,                    --> Programa chamador
                                    pr_dtmvtolt  => rw_crapdat.dtmvtolt,            --> Data do movimento atual
                                    pr_dsxml     => vr_des_xml,                     --> Arquivo XML de dados (CLOB)
                                    pr_dsxmlnode => '/crrl360/agencia/detalhe',     --> No base do XML para leitura dos dados
                                    pr_dsjasper  => 'crrl360.jasper',               --> Arquivo de layout do iReport
                                    pr_dsparams  => null,                           --> Nao enviar parametro
                                    pr_dsarqsaid => vr_path_arquivo||'/crrl360.lst', --> Arquivo final
                                    pr_flg_gerar => 'N',                            --> Não gerar o arquivo na hora
                                    pr_qtcoluna  => 132,                            --> Quantidade de colunas
                                    pr_nmformul  => '132col',                       --> Nome do formulario
                                    pr_sqcabrel  => 1,                              --> Sequencia do cabecalho
                                    pr_nrcopias  => 1,                              --> Numero de copias
                                    pr_des_erro  => vr_dscritic);                   --> Saida com erro

        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
      END IF;

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

  END pc_crps401;
/

