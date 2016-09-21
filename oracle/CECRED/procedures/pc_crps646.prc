CREATE OR REPLACE PROCEDURE CECRED.
         pc_crps646 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padr�o para utiliza��o de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Sa�da de termino da execu��o
                    ,pr_infimsol OUT PLS_INTEGER            --> Sa�da de termino da solicita��o
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps646 (Fontes/crps646.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Carlos Henrique Weinhold - CECRED
       Data    : JULHO/2013

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Listar os t�tulos a pagar e receber dos pr�ximos 7 dias corridos
               para o setor Financeiro, que ir� auxiliar na provisao de caixa
               necess�rio para realizar liquida�oes bi-laterais e
               multi-laterais.

  Altera�oes: 11/11/2013 - Nova forma de chamar as agencias, de PAC agora
                           a escrita ser� PA (Guilherme Gielow)

              16/12/2013 - Conversao Progress => PL/SQL (Andrino - RKAM).



............................................................................ */


    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- C�digo do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS646';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

      -- Vari�vel de Controle de XML
      vr_des_xml    CLOB;
      vr_path_arquivo VARCHAR2(200);

      -- Variaveis gerais
      vr_tt_pagar     ddda0001.typ_tab_tt_pagar;  -- Variavel de titulos a pagar
      vr_index        INTEGER;                    -- Variavel do indice da vr_tt_pagar
      vr_nmrescop_ant crapcop.nmrescop%TYPE := 0; -- Nome da cooperativa anterior
      vr_qtregist     INTEGER := 0;               -- Quantidade total de registros por cooperativa para as contas a pagar
      vr_tot_vltitulo crapcob.vltitulo%TYPE := 0; -- Valor total dos titulos por cooperativa para as contas a pagar
      vr_flgdados     BOOLEAN := FALSE;           -- Flag de existencia de informacoes
      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.nmextcop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      -- Cursor gen�rico de calend�rio
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Busca os titulos a receber
      CURSOR cr_crapcob (pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS
        SELECT crapcop.nmrescop
              ,crapcco.cdagenci
              ,crapcob.nrdconta
              ,crapcob.nrcnvcob
              ,crapcob.dtvencto
              ,crapcob.vltitulo
              ,ROW_NUMBER () OVER (PARTITION BY crapcop.nmrescop ORDER BY crapcop.nmrescop, crapcob.dtvencto, crapcob.nrdconta, crapcob.nrcnvcob, crapcob.vltitulo ) nrseq
              ,COUNT(1)      OVER (PARTITION BY crapcop.nmrescop ORDER BY crapcop.nmrescop) qtreg
              ,SUM(crapcob.vltitulo) OVER (PARTITION BY crapcop.nmrescop ORDER BY crapcop.nmrescop) tot_vltitulo
          FROM crapcob,
               crapceb,
               crapcco,
               crapcop
         WHERE crapcop.cdcooper <> 3
           AND crapcco.cdcooper = crapcop.cdcooper
           AND crapcco.cddbanco = 085
           AND crapcco.flgregis = 1
           AND crapceb.cdcooper = crapcco.cdcooper
           AND crapceb.nrconven = crapcco.nrconven
           AND crapcob.cdcooper = crapceb.cdcooper
           AND crapcob.nrdconta = crapceb.nrdconta
           AND crapcob.nrcnvcob = crapceb.nrconven
           AND crapcob.dtvencto >= pr_dtmvtolt
           AND crapcob.dtvencto <= pr_dtmvtolt + 7
           AND crapcob.incobran  = 0
           AND crapcob.vltitulo >= 250000;
      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

      ------------------------------- VARIAVEIS -------------------------------

      --------------------------- SUBROTINAS INTERNAS --------------------------
	    --Procedure que escreve linha no arquivo CLOB
	    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
      BEGIN
        --Escrever no arquivo CLOB
        dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
      END;

    BEGIN -- Inicio da rotina principal

      --------------- VALIDACOES INICIAIS -----------------

      -- Incluir nome do m�dulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop;
      FETCH cr_crapcop
       INTO rw_crapcop;
      -- Se n�o encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haver� raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Leitura do calend�rio da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat;
      -- Se n�o encontrar
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

      -- Valida��es iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);
      -- Se a variavel de erro � <> 0
      IF vr_cdcritic <> 0 THEN
        -- Envio centralizado de log de erro
        RAISE vr_exc_saida;
      END IF;

      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------

      -- Inicializar o CLOB
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

      -------------------------------------------
      -- Iniciando a gera��o do XML
      -------------------------------------------
      pc_escreve_xml('<?xml version="1.0" encoding="WINDOWS-1252"?>'||
                        '<crrl656>'||
                          '<data>'||to_char(rw_crapdat.dtmvtolt,'dd/mm/yyyy')||'</data>'||
                           '<receber>');

      -- busca os titulos a receber
      FOR rw_crapcob IN cr_crapcob(rw_crapdat.dtmvtolt) LOOP

        -- Se for o primeiro registro da cooperativa, insere o cabecalho
        IF rw_crapcob.nrseq = 1 THEN
          pc_escreve_xml('<cabecalho>'||
                           '<nmrescop>'||rw_crapcob.nmrescop||'</nmrescop>'||
                           '<detalhes>');
          -- Atualiza variavel informando que tem informacoes para gerar o arquivo
          vr_flgdados := TRUE;
        END IF;

        -- Insere os detalhes
        pc_escreve_xml('<detalhe>'||
                        '<cdagenci>'||rw_crapcob.cdagenci||'</cdagenci>'  ||
                        '<nrdconta>'||gene0002.fn_mask_conta(rw_crapcob.nrdconta)    ||'</nrdconta>' ||
                        '<nrcnvcob>'||to_char(rw_crapcob.nrcnvcob,'fm999G999G990')   ||'</nrcnvcob>' ||
                        '<dtvencto>'||to_char(rw_crapcob.dtvencto,'dd/mm/yyyy')      ||'</dtvencto>' ||
                        '<vltitulo>'||to_char(rw_crapcob.vltitulo,'fm999G999G990D00')||'</vltitulo>' ||
                       '</detalhe>');

        -- Se for o ultimo registro da cooperativa, insere o total
        IF rw_crapcob.nrseq = rw_crapcob.qtreg THEN
          pc_escreve_xml(  '<qtregist>'    ||to_char(rw_crapcob.qtreg,'fm999G990')              ||'</qtregist>'||
                           '<tot_vltitulo>'||to_char(rw_crapcob.tot_vltitulo,'fm999G999G990D00')||'</tot_vltitulo>'||
                           '</detalhes>'   ||
                         '</cabecalho>');
        END IF;

      END LOOP;


      -- busca os titulos a pagar
      pc_escreve_xml('</receber><pagar>');

      ddda0001.pc_titulos_a_pagar(pr_dtvcnini => rw_crapdat.dtmvtolt,
                                  pr_tt_pagar => vr_tt_pagar);

      -- Se existir registros
      vr_index := vr_tt_pagar.first;
      LOOP
        EXIT WHEN vr_index IS NULL;

        -- Se for o primeiro registro da cooperativa, insere o cabecalho
        IF vr_nmrescop_ant <> vr_tt_pagar(vr_index).nmrescop THEN
          pc_escreve_xml('<cabecalho>'||
                           '<nmrescop>'||vr_tt_pagar(vr_index).nmrescop||'</nmrescop>'||
                           '<detalhes>');

          -- Inicializa as variaveis iniciais
          vr_nmrescop_ant := vr_tt_pagar(vr_index).nmrescop;
          vr_qtregist     := 0;
          vr_tot_vltitulo := 0;
          -- Atualiza variavel informando que tem informacoes para gerar o arquivo
          vr_flgdados := TRUE;
        END IF;

        -- Insere os detalhes
        pc_escreve_xml('<detalhe>'||
                        '<cdagenci>'||vr_tt_pagar(vr_index).cdagenci||'</cdagenci>' ||
                        '<nrdconta>'||gene0002.fn_mask_conta(vr_tt_pagar(vr_index).nrdconta)    ||'</nrdconta>' ||
                        '<cdbarras>'||vr_tt_pagar(vr_index).cdbarras                            ||'</cdbarras>' ||
                        '<dtvencto>'||to_char(vr_tt_pagar(vr_index).dtvencto,'dd/mm/yyyy')      ||'</dtvencto>' ||
                        '<vltitulo>'||to_char(vr_tt_pagar(vr_index).vltitulo,'fm999G999G990D00')||'</vltitulo>' ||
                       '</detalhe>');

        vr_qtregist     := vr_qtregist     + 1;
        vr_tot_vltitulo := vr_tot_vltitulo + vr_tt_pagar(vr_index).vltitulo;
        -- Se for o ultimo registro da cooperativa, insere o total
        IF vr_tt_pagar.next(vr_index) IS NULL OR                                                   -- Se o proximo registro nao existir
           vr_tt_pagar(vr_index).nmrescop <> vr_tt_pagar(vr_tt_pagar.next(vr_index)).nmrescop THEN -- ou se a cooperativa for diferente da atual
          pc_escreve_xml(  '<qtregist>'    ||to_char(vr_qtregist,'fm999G990')           ||'</qtregist>'||
                           '<tot_vltitulo>'||to_char(vr_tot_vltitulo,'fm999G999G990D00')||'</tot_vltitulo>'||
                           '</detalhes>'   ||
                         '</cabecalho>');
        END IF;

        -- Incrementa o indice
        vr_index := vr_tt_pagar.next(vr_index);
      END LOOP;

      -- Finaliza o n� do XML
      pc_escreve_xml('</pagar></crrl656>');

      -- Vai imprimir somente se tiver dados para gerar
      IF vr_flgdados THEN
        -- Busca do diret�rio base da cooperativa e a subpasta de relat�rios
        vr_path_arquivo := gene0001.fn_diretorio( pr_tpdireto => 'C' -- /usr/coop
                                               ,pr_cdcooper => pr_cdcooper
                                               ,pr_nmsubdir => '/rl'); --> Gerado no diretorio /rl
        -- Chamada do iReport para gerar o arquivo de saida
        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,                    --> Cooperativa conectada
                                    pr_cdprogra  => vr_cdprogra,                    --> Programa chamador
                                    pr_dtmvtolt  => rw_crapdat.dtmvtolt,            --> Data do movimento atual
                                    pr_dsxml     => vr_des_xml,                     --> Arquivo XML de dados (CLOB)
                                    pr_dsxmlnode => '/crrl656',                     --> No base do XML para leitura dos dados
                                    pr_dsjasper  => 'crrl656.jasper',               --> Arquivo de layout do iReport
                                    pr_dsparams  => null,                           --> Nao enviar parametro
                                    pr_dsarqsaid => vr_path_arquivo||'/crrl656.lst', --> Arquivo final
                                    pr_flg_gerar => 'N',                            --> N�o gerar o arquivo na hora
                                    pr_qtcoluna  => 132,                            --> Quantidade de colunas
                                    pr_nmformul  => '132col',                       --> Nome do formulario
                                    pr_sqcabrel  => 1,                              --> Sequencia do cabecalho
                                    pr_flg_impri => 'S',                            --> Chamar a impress�o (Imprim.p)
                                    pr_nrcopias  => 1,                              --> Numero de copias
                                    pr_des_erro  => vr_dscritic);                   --> Saida com erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
      END IF;

      -- Liberando a mem�ria alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);

      ----------------- ENCERRAMENTO DO PROGRAMA -------------------

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      -- Salvar informa��es atualizadas
      COMMIT;

    EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas c�digo
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descri��o
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
        -- Se foi retornado apenas c�digo
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descri��o
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos c�digo e critica encontradas das variaveis locais
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro n�o tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
    END;

  END pc_crps646;
/

