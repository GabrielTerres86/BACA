CREATE OR REPLACE PROCEDURE CECRED.pc_crps646 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                              ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                              ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                              ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                              ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps646 (Fontes/crps646.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Carlos Henrique Weinhold - CECRED
       Data    : JULHO/2013                               Ultima atualizacao: 19/02/2018

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Listar os títulos a pagar e receber dos próximos 7 dias corridos
               para o setor Financeiro, que irá auxiliar na provisao de caixa
               necessário para realizar liquidaçoes bi-laterais e
               multi-laterais.

  Alteraçoes: 11/11/2013 - Nova forma de chamar as agencias, de PAC agora
                           a escrita será PA (Guilherme Gielow)

              16/12/2013 - Conversao Progress => PL/SQL (Andrino - RKAM).

              19/02/2018 - Mehora da query principal da tabela cob
                         - Ajustando nome do módulo logado
                         - No caso de erro de programa gravar tabela especifica de log 
                         - Ajuste mensagem de erro para inicio e fim de programa
                           (Belli - Envolti - Chamado 769624)
                         - Inclusão log nas exceptions

............................................................................ */


    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS646';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      -- Excluida rotina condição de execeção vr_exc_fimprg - Chamado 769624 - 19/02/2018 
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

      -- Variável de Controle de XML
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
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Mehora da query principal da tabela cob - Chamado 769624 - 19/02/2018
      -- Busca os titulos a receber
      CURSOR cr_crapcob (pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS
        SELECT /*+index CRAPCOB##CRAPCOB9(crapcob) */
               crapcop.nmrescop
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
         WHERE crapcop.cdcooper IN 
                         ( SELECT t.cdcooper FROM crapcop t 
                           WHERE  t.flgativo = 1 
                           AND    t.cdcooper <> 3 ) 
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

    -- Inclusao do log padrão - Chamado 769624 - 19/02/2018
    -- Controla Controla log em banco de dados
    PROCEDURE pc_controla_log_programa(pr_dstiplog      IN VARCHAR2, -- Tipo de Log
                                       pr_tpocorrencia  IN NUMBER,   -- Tipo de ocorrencia
                                       pr_dscritic      IN VARCHAR2, -- Descrição do Log
                                       pr_cdcritic      IN NUMBER,   -- Codigo da crítica
                                       pr_cdcriticidade IN VARCHAR2)
    IS
      vr_idprglog           tbgen_prglog.idprglog%TYPE := 0;
    BEGIN         
      --> Controlar geração de log de execução dos jobs                                
      CECRED.pc_log_programa(pr_dstiplog      => pr_dstiplog, 
                             pr_cdprograma    => vr_cdprogra, 
                             pr_cdcooper      => pr_cdcooper, 
                             pr_tpexecucao    => 1, --1-Batch
                             pr_tpocorrencia  => pr_tpocorrencia,
                             pr_cdcriticidade => 0, --baixa
                             pr_dsmensagem    => pr_dscritic,
                             pr_cdmensagem    => pr_cdcritic,
                             pr_idprglog      => vr_idprglog);
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log  
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);                                                             
    END pc_controla_log_programa;
    
	    --Procedure que escreve linha no arquivo CLOB
	    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
      BEGIN
        --Escrever no arquivo CLOB
        dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
      END;

    BEGIN -- Inicio da rotina principal

      --------------- VALIDACOES INICIAIS -----------------

      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);                                      

      --Programa iniciado - Chamado 769624 - 19/02/2018
      pc_controla_log_programa('I', NULL, NULL, 0, NULL);

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
                                  
      -- Retorna nome do módulo logado - Chamado 769624 - 19/02/2018
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);  

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

      -- Finaliza o nó do XML
      pc_escreve_xml('</pagar></crrl656>');

      -- Vai imprimir somente se tiver dados para gerar
      IF vr_flgdados THEN
        -- Busca do diretório base da cooperativa e a subpasta de relatórios
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
                                    pr_flg_gerar => 'N',                            --> Não gerar o arquivo na hora
                                    pr_qtcoluna  => 132,                            --> Quantidade de colunas
                                    pr_nmformul  => '132col',                       --> Nome do formulario
                                    pr_sqcabrel  => 1,                              --> Sequencia do cabecalho
                                    pr_flg_impri => 'S',                            --> Chamar a impressão (Imprim.p)
                                    pr_nrcopias  => 1,                              --> Numero de copias
                                    pr_des_erro  => vr_dscritic);                   --> Saida com erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        -- Retorna nome do módulo logado - Chamado 769624 - 19/02/2018
        GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                  ,pr_action => null);  
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

      --Programa finalizado - Chamado 769624 - 19/02/2018
      pc_controla_log_programa('F', NULL, NULL, 0, NULL);

      -- Salvar informações atualizadas
      COMMIT;

    EXCEPTION
      -- Excluida rotina condição de execeção vr_exc_fimprg - Chamado 769624 - 19/02/2018      
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos código e critica encontradas das variaveis locais
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;

        --Grava erro na tabela de logs
        pc_controla_log_programa('O', 1, pr_dscritic, pr_cdcritic, 1);

        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - Chamado 769624 - 19/02/2018 
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
        -- Efetuar retorno do erro não tratado
        -- Ajuste mensagem de erro - Chamado 769624 - 19/02/2018
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                       ', crps646 erro:' ||sqlerrm; 


        --Grava erro na tabela de logs
        pc_controla_log_programa('O', 2, pr_dscritic, pr_cdcritic, 2);

        -- Efetuar rollback
        ROLLBACK;
    END;

  END pc_crps646;
