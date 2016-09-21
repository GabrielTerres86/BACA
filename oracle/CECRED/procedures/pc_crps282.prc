CREATE OR REPLACE PROCEDURE CECRED.
         pc_crps282 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps282 (Fontes/crps282.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Deborah 
       Data    : Marco/2000                        Ultima atualizacao: 21/05/2014

       Dados referentes ao programa:

       Frequencia: Diario,
       Objetivo  : Atende a solicitacao 002.
                   Listar os cartos magneticos entregues.       
                   Emite relatorio 229.

       Alteracoes: Unificacao dos Bancos - SQLWorks - Fernando.  
                   
                   03/07/2006 - Alterado para gerar arquivo a cada PA, e
                                incluido relatorio geral (Diego).
                   
                   09/09/2013 - Nova forma de chamar as agencias, de PAC agora 
                                a escrita será PA (André Euzébio - Supero). 
                                
                   29/10/2013 - Alterado totalizador de 99 para 999. (Reinert)

                   21/05/2014 - Conversão Progress >> Oracle (Edison - AMcom)
                   
    ............................................................................. */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS282';

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
 
      --seleciona todos os cartoes magneticos dos associados
      --onde o tipo do cartao seja diferente de 9
      CURSOR cr_crapcrm( pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_dtmvtolt IN DATE) IS
        SELECT crapcrm.cdcooper
              ,crapcrm.nrdconta
              ,crapcrm.nmtitcrd
              ,crapcrm.nrcartao
              ,crapass.cdagenci
              ,COUNT(1) OVER (PARTITION BY crapass.cdagenci) totreg
              ,ROW_NUMBER() OVER (PARTITION BY crapass.cdagenci 
                                  ORDER BY     crapass.cdagenci
                                              ,crapcrm.nrdconta
                                              ,crapcrm.nrcartao ) nrseq
        FROM  crapcrm
             ,crapass
        WHERE crapcrm.cdcooper  = pr_cdcooper   
        AND   crapcrm.dtentcrm  = pr_dtmvtolt   
        AND   crapcrm.tpcarcta <> 9 
        AND   crapass.cdcooper = crapcrm.cdcooper 
        AND   crapass.nrdconta = crapcrm.nrdconta;

      --seleciona todas as agencias da cooperativa conectada
      CURSOR cr_crapage( pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT crapage.cdagenci
              ,crapage.nmresage
        FROM   crapage 
        WHERE  crapage.cdcooper = pr_cdcooper;

      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
      --Estrutura de registro para armazenar os dados de agencias
      TYPE typ_reg_crapage IS
        RECORD( nmresage crapage.nmresage%TYPE);
      --tipo de registro para armazenar dados de agencias
      TYPE typ_tab_crapage IS TABLE OF typ_reg_crapage INDEX BY  PLS_INTEGER;
      --Tabela temporaria de agencias      
      vr_tab_crapage typ_tab_crapage;    
      
      ------------------------------- VARIAVEIS -------------------------------
      vr_nmarqimp         VARCHAR2(100);
      vr_nmarqger         VARCHAR2(100);
      vr_rel_dtrefere     DATE;
      vr_rel_qtcartao     INTEGER;
      vr_rel_dsagenci     VARCHAR2(100);
      vr_tot_qtcartao     INTEGER;
      vr_dsdircop         VARCHAR2(500);
      
      -- Variaveis de controle xml
      vr_xml              CLOB;
      vr_xml_2            CLOB;
      vr_texto_completo   VARCHAR2(32767);
      vr_texto_completo_2 VARCHAR2(32767);

      --------------------------- SUBROTINAS INTERNAS --------------------------

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
      --limpando a tabela  temaporaria
      vr_tab_crapage.delete;
      --carregando as agencias na tabela de memoria
      FOR rw_crapage IN cr_crapage( pr_cdcooper => pr_cdcooper) 
      LOOP
        vr_tab_crapage(rw_crapage.cdagenci).nmresage := rw_crapage.nmresage;
      END LOOP;  
      
      --inicializando as variaveis
      vr_rel_dtrefere := rw_crapdat.dtmvtolt;
      --nome do relatorio resumo geral
      vr_nmarqger     := 'crrl229_'||gene0001.fn_param_sistema('CRED',pr_cdcooper,'SUFIXO_RELATO_TOTAL')||'.lst';
      --busca a pasta da cooperativa conectada
      vr_dsdircop := gene0001.fn_diretorio(pr_tpdireto => 'C' 
                                         ,pr_cdcooper => pr_cdcooper
                                         ,pr_nmsubdir => ''); 

      -- Inicializar CLOB
      dbms_lob.createtemporary(vr_xml_2, TRUE);
      dbms_lob.open(vr_xml_2, dbms_lob.lob_readwrite);

      --Inicializa o xml
      gene0002.pc_escreve_xml(vr_xml_2,
                              vr_texto_completo_2,
                             '<?xml version="1.0" encoding="utf-8"?>'||
                             '<root dtrefere="'||TO_CHAR(vr_rel_dtrefere,'DD/MM/YYYY')||'">'||chr(13)); 

      --seleciona todos os cartoes magneticos doa associados 
      --do tipo diferente de 9 
      FOR rw_crapcrm IN cr_crapcrm( pr_cdcooper => pr_cdcooper
                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt) 
      LOOP
          
        /* abre um arquivo para cada PA */
        --se for o primeiro registro da quebra (first-of)
        IF rw_crapcrm.nrseq = 1 THEN
          --nomeando o arquivo
          vr_nmarqimp := 'crrl229_' || LPAD(rw_crapcrm.cdagenci,3,'0')||'.lst'; 

          --busca o nome da agencia                
          IF vr_tab_crapage.exists(rw_crapcrm.cdagenci) THEN
            vr_rel_dsagenci := rw_crapcrm.cdagenci ||' - '||
                               vr_tab_crapage(rw_crapcrm.cdagenci).nmresage;
          ELSE
            vr_rel_dsagenci := ' - ';
          END IF;

          -- Inicializar CLOB
          dbms_lob.createtemporary(vr_xml, TRUE);
          dbms_lob.open(vr_xml, dbms_lob.lob_readwrite);

          --cria o atributo da agencia no relatorio por agencia
          gene0002.pc_escreve_xml(vr_xml,
                                  vr_texto_completo,
                                 '<?xml version="1.0" encoding="utf-8"?>'||
                                 '<agencia cdagenci="'||vr_rel_dsagenci||'" '||
                                          'dtrefere="'||TO_CHAR(vr_rel_dtrefere,'DD/MM/YYYY')||'">'||chr(13)); 

          --cria o atributo da agencia no relatorio resumo geral
          gene0002.pc_escreve_xml(vr_xml_2,
                                  vr_texto_completo_2,
                                  '<agencia cdagenci="'||rw_crapcrm.cdagenci||'">'||chr(13)); 

        END IF;

        --escreve informacoes do cartao 
        gene0002.pc_escreve_xml(vr_xml,
                                vr_texto_completo,
                                '<cartao nrcartao="'||TO_CHAR(rw_crapcrm.nrcartao,'fm9999G9999G9999G9999')||'">'|| 
                                '<nrdconta>'||gene0002.fn_mask_conta(rw_crapcrm.nrdconta)||'</nrdconta>'||
                                '<nmtitcrd>'||rw_crapcrm.nmtitcrd||'</nmtitcrd></cartao>'||chr(13)); 

        --escreve informacoes do cartao
        gene0002.pc_escreve_xml(vr_xml_2,
                                vr_texto_completo_2,
                                '<cartao nrcartao="'||TO_CHAR(rw_crapcrm.nrcartao,'fm9999G9999G9999G9999')||'">'|| 
                                '<nrdconta>'||gene0002.fn_mask_conta(rw_crapcrm.nrdconta)||'</nrdconta>'||
                                '<nmtitcrd>'||rw_crapcrm.nmtitcrd||'</nmtitcrd></cartao>'||chr(13)); 

        --acumula o total de cartoes emitidos por agencia
        vr_rel_qtcartao := nvl(vr_rel_qtcartao,0) + 1;
        vr_tot_qtcartao := nvl(vr_tot_qtcartao,0) + 1;

        /* fecha o arquivo de cada PA */
        --se for o ultimo registro da quebra por agencia
        IF rw_crapcrm.nrseq = rw_crapcrm.totreg THEN
          
          --se tem cartoes
          IF vr_rel_qtcartao > 0 THEN
            --Inicializa o xml
            gene0002.pc_escreve_xml(vr_xml,
                                    vr_texto_completo,
                                    '<total>'||vr_rel_qtcartao||'</total></agencia>'||chr(13),
                                    TRUE); 

            -- Gerando o relatório 
            gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                                       ,pr_cdprogra  => vr_cdprogra
                                       ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                       ,pr_dsxml     => vr_xml
                                       ,pr_dsxmlnode => '/agencia/cartao'
                                       ,pr_dsjasper  => 'crrl229.jasper'
                                       ,pr_dsparams  => ''
                                       ,pr_dsarqsaid => vr_dsdircop||'/rl/'||vr_nmarqimp
                                       ,pr_flg_gerar => 'N'
                                       ,pr_qtcoluna  => 80
                                       ,pr_sqcabrel  => 1
                                       ,pr_flg_impri => 'S'
                                       ,pr_nmformul  => '80col'
                                       ,pr_nrcopias  => 1
                                       ,pr_des_erro  => vr_dscritic);

            -- Liberando a memória alocada pro CLOB
            dbms_lob.close(vr_xml);
            dbms_lob.freetemporary(vr_xml);

            --Escreve o total no relatorio crrl229_999
            gene0002.pc_escreve_xml(vr_xml_2,
                                    vr_texto_completo_2,
                                    '<total>'||vr_rel_qtcartao||'</total></agencia>'||chr(13)); 

            vr_rel_qtcartao := 0;
          ELSE
            --Inicializa o xml
            gene0002.pc_escreve_xml(vr_xml,
                                    vr_texto_completo,
                                    '<total>NAO FOI ENTREGUE NENHUM CARTAO NESTA DATA</total>'||chr(13),
                                    TRUE); 
          END IF;
        END IF;
      END LOOP;  
      
      IF vr_tot_qtcartao > 0 THEN
        --Inicializa o xml
        gene0002.pc_escreve_xml(vr_xml_2,
                                vr_texto_completo_2,
                                '<geral>'||vr_tot_qtcartao||'</geral></root>'||chr(13),
                                TRUE); 
       
      
        -- Gerando o relatório 
        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                                   ,pr_cdprogra  => vr_cdprogra
                                   ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                   ,pr_dsxml     => vr_xml_2
                                   ,pr_dsxmlnode => '/root/agencia/cartao'
                                   ,pr_dsjasper  => 'crrl229_999.jasper'
                                   ,pr_dsparams  => ''
                                   ,pr_dsarqsaid => vr_dsdircop||'/rl/'||vr_nmarqger
                                   ,pr_flg_gerar => 'N'
                                   ,pr_qtcoluna  => 80
                                   ,pr_sqcabrel  => 2
                                   ,pr_flg_impri => 'S'
                                   ,pr_nmformul  => '80col'
                                   ,pr_nrcopias  => 1
                                   ,pr_des_erro  => vr_dscritic);

      END IF;

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_xml_2);
      dbms_lob.freetemporary(vr_xml_2);

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

  END pc_crps282;
/

