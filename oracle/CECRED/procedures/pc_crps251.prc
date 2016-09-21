CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS251(pr_cdcooper  IN crapcop.cdcooper%TYPE
                    ,pr_flgresta  IN PLS_INTEGER
                    ,pr_stprogra OUT PLS_INTEGER
                    ,pr_infimsol OUT PLS_INTEGER
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                    ,pr_dscritic OUT VARCHAR2)  AS
/* ..........................................................................

   Programa: PC_CRPS251                              Antigo: Fontes/crps251.p
   Sistema : Emprestimos - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Novembro/98.                        Ultima atualizacao: 22/11/2013

   Dados referentes ao programa:

   Frequencia: Mensal (Batch - Background).
   Objetivo  : Atende a solicitacao 004 (mensal - relatorios)
               Emite: relatorio de notas promissorias emitidas no mes (202).

   Alteracoes: 29/12/1999 - Nao gerar mais pedido de impressao (Edson).

               11/02/2000 - Gerar pedido de impressao (Deborah).

               03/11/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

               07/06/2005 - Nao gerar mais pedido de impressao para a VIACREDI
                            - chamado 8492 (Edson).

               16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               25/05/2007 - Retirado vinculacao da execucao do imprim.p
                            ao codigo da cooperativa. (Guilherme).

               18/09/2013 - Ajuste para evitar erro nas montagens das datas
                            e na ordenacao do SELECT da crapepr para igualar
                            ao Progress (Gabriel).

               18/09/2013 - Conversao Progess -> Oracle (Gabriel)

               10/10/2013 - Ajuste para controle de critias (Gabriel).

               22/11/2013 - Correção na chamada a vr_exc_fimprg, a mesma só deve
                            ser acionada em caso de saída para continuação da cadeia,
                            e não em caso de problemas na execução (Marcos-Supero)

............................................................................ */

  -- Variaveis de uso no programa
  vr_cdprogra crapprg.cdprogra%TYPE := 'CRPS251';  -- Codigo do presente programa
  vr_dtmvtolt crapdat.dtmvtolt%TYPE;               -- Data para referencia de leitura dos emprestimo
  vr_crapcop          NUMBER(1);                   -- Verificador de registro na crapcop
  vr_dsrefere         VARCHAR2(100);               -- Mes de referencia
  vr_nrdmeses         NUMBER(10);                  -- Proporção entre qt de parcelas e promissorias
  vr_contames         NUMBER(10);                  -- Contador de meses
  vr_ddmvtolt         NUMBER(2);                   -- Dia de vencimento
  vr_aamvtolt         NUMBER(4);                   -- Ano de vencimento
  vr_dsdconta         VARCHAR2(20);                -- Conta
  vr_dsarquiv         VARCHAR2(100);               -- Descricao arquivp
  vr_vlpreemp         NUMBER(14,2);                -- Valor prestacao
  vr_nmdaval1         VARCHAR2(100);               -- Nome 1ero. aval
  vr_nmdaval2         VARCHAR2(100);               -- Nome 2.do aval
  vr_contador         NUMBER(10);                  -- Contador de promissorias
  vr_dsdireto         VARCHAR2(100);               -- Diretorio rl/ da cooperativa
  vr_cdcritic         crapcri.cdcritic%TYPE;       -- Codigo da critica
  vr_dscritic         VARCHAR2(2000);              -- Descricao da critica
  vr_dsxmldad         CLOB;                        -- Dados para o XML
  vr_exc_saida        EXCEPTION;                   -- Tratamento de excecao para parar a cadeia
  vr_exc_fimprg       EXCEPTION;                   -- Tratamento de excecao sem parar a cadeia

  -- Cursor da cooperativa logada
  CURSOR cr_crapcop (pr_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT 1
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;

  -- Cursor contendo os emprestimos e o seu cooperado
  CURSOR cr_empr (pr_cdcooper crapcop.cdcooper%TYPE
                 ,pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS
    SELECT pepr.dtmvtolt
          ,pepr.cdagenci
          ,pepr.cdbccxlt
          ,pepr.nrdolote
          ,wepr.qtpreemp
          ,wepr.qtpromis
          ,wepr.dtvencto
          ,wepr.vlpreemp
          ,wepr.nmdaval1
          ,wepr.nrctaav1
          ,wepr.nmdaval2
          ,wepr.nrctaav2
          ,wepr.nrctremp
          ,ass.nrdconta
          ,ass.nmprimtl
      FROM crapepr pepr
          ,crawepr wepr
          ,crapass ass
     WHERE pepr.cdcooper = pr_cdcooper
       AND pepr.dtmvtolt > pr_dtmvtolt
       AND wepr.flgimpnp = 1
       AND pepr.cdcooper = wepr.cdcooper
       AND pepr.nrdconta = wepr.nrdconta
       AND pepr.nrctremp = wepr.nrctremp

       AND pepr.cdcooper = ass.cdcooper
       AND pepr.nrdconta = ass.nrdconta
     ORDER BY pepr.dtmvtolt
             ,pepr.nrdconta
             ,pepr.nrctremp;

  -- Dados dos emprestimos e do cooperado
  rw_empr cr_empr%ROWTYPE;

  -- Dados da data da cooperativa logada
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;

  -- Subrotina para escrever texto na variável CLOB do XML
  PROCEDURE pc_escreve_clob(pr_des_dados IN VARCHAR2) IS
  BEGIN
    dbms_lob.writeappend(vr_dsxmldad,length(pr_des_dados),pr_des_dados);
  END;

BEGIN

  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra
                            ,pr_action => NULL);

  -- Obter os dados da cooperativa logada
  OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);

  FETCH cr_crapcop INTO vr_crapcop;

  -- Se cooperativa nao encontrada, gera critica para o log
  IF  cr_crapcop%notfound   THEN

    vr_cdcritic := 651;

    CLOSE cr_crapcop;

    RAISE vr_exc_saida;

  END IF;

  CLOSE cr_crapcop;

  -- Obter dados da data da cooperativa
  OPEN btch0001.cr_crapdat (pr_cdcooper => pr_cdcooper);

  FETCH btch0001.cr_crapdat INTO rw_crapdat;

  -- Se nao exisitir a data da cooperativa, obter critica e jogar para o log
  IF  btch0001.cr_crapdat%notfound  THEN

    vr_cdcritic := 1;

    CLOSE btch0001.cr_crapdat;

    RAISE vr_exc_saida;

  END IF;

  CLOSE btch0001.cr_crapdat;

  -- Realizar as validacoes do iniprg
  btch0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper,
                             pr_flgbatch => 1,
                             pr_cdprogra => vr_cdprogra,
                             pr_infimsol => pr_infimsol,
                             pr_cdcritic => vr_cdcritic);

  -- Se possui critica, buscar a descricao e jogar ao log
  IF  vr_cdcritic <> 0  THEN

    RAISE vr_exc_saida;

  END IF;

  -- Obter o ultimo dia do mes passado
  vr_dtmvtolt := rw_crapdat.dtmvtolt - to_char(rw_crapdat.dtmvtolt,'dd');
  vr_dsrefere := gene0001.vr_vet_nmmesano(to_char(rw_crapdat.dtmvtolt,'mm')) || '/' || to_char(rw_crapdat.dtmvtolt,'yyyy');

  -- Inicializar o CLOB (XML)
  dbms_lob.createtemporary(vr_dsxmldad, TRUE);
  dbms_lob.open(vr_dsxmldad, dbms_lob.lob_readwrite);

  -- Inicio
  pc_escreve_clob('<?xml version="1.0" encoding="utf-8"?><raiz>');

  -- Percorre os emprestimos com o seus cooperados
  FOR rw_empr IN cr_empr (pr_cdcooper => pr_cdcooper
                         ,pr_dtmvtolt => vr_dtmvtolt) LOOP

    -- Prepara dados da nota promissoria impressa
    vr_nrdmeses := rw_empr.qtpreemp / rw_empr.qtpromis;
    vr_contames := to_number(to_char(rw_empr.dtvencto,'mm')) + vr_nrdmeses - 1;
    vr_ddmvtolt := to_number(to_char(rw_empr.dtvencto,'dd'));
    vr_aamvtolt := to_number(to_char(rw_empr.dtvencto,'yyyy'));
    vr_dsdconta := trim(gene0002.fn_mask_conta(rw_empr.nrdconta));
    vr_dsarquiv := to_char(rw_empr.dtmvtolt,'dd/mm/yyyy')
         || '-' || ltrim(to_char(rw_empr.cdagenci,'000'))
         || '-' || ltrim(to_char(rw_empr.cdbccxlt,'000'))
         || '-' || ltrim(to_char(rw_empr.nrdolote,'000000'));

    -- Valor da prestacao do emprestimo
    IF  rw_empr.qtpreemp = rw_empr.qtpromis  THEN
      vr_vlpreemp := rw_empr.vlpreemp;
    ELSE
      vr_vlpreemp := ROUND(( rw_empr.vlpreemp * rw_empr.qtpreemp) / rw_empr.qtpromis,2);
    END IF;

    -- Nome do availista 1.ero
    vr_nmdaval1 := rw_empr.nmdaval1;

    -- Se avalista cooperado, concatenar a conta/dv
    IF  rw_empr.nrctaav1 > 0  THEN
      vr_nmdaval1 := vr_nmdaval1 || ' (' || trim(gene0002.fn_mask_conta(rw_empr.nrctaav1)) || ')';
    END IF;

    -- Nome do avalista 2.do
    vr_nmdaval2 := rw_empr.nmdaval2;

    -- Se avalista cooperado, concatenar a conta/dv
    IF  rw_empr.nrctaav2 > 0  THEN
      vr_nmdaval2 := vr_nmdaval2 || ' (' || trim(gene0002.fn_mask_conta(rw_empr.nrctaav2)) || ')';
    END IF;

    -- Escrever a TAG com o devedor
    pc_escreve_clob( '<devedor>'
                      || '<dsrefere>' || vr_dsrefere                   || '</dsrefere>'
                      || '<dsarquiv>' || substr(vr_dsarquiv,1,25)      || '</dsarquiv>'
                      || '<dsdconta>' || substr(vr_dsdconta,1,10)      || '</dsdconta>'
                      || '<nmprimtl>' || substr(rw_empr.nmprimtl,1,40) || '</nmprimtl>'
                      || '<nmdaval1>' || substr(vr_nmdaval1,1,55)      || '</nmdaval1>'
                      || '<nmdaval2>' || substr(vr_nmdaval2,1,55)      || '</nmdaval2>');

    -- Aumentar a quantidade do ano a cada 12 meses
    LOOP

      EXIT WHEN vr_contames <= 12;

      vr_contames := vr_contames - 12;
      vr_aamvtolt := vr_aamvtolt + 1;

    END LOOP;

    DECLARE

      vr_dsctremp VARCHAR2(50);  -- Contrato do emprestimo
      vr_dtvencto DATE;          -- Data de vencimento

    BEGIN

      vr_contador := 1; -- Inicializar o contador

      -- Loop das quantidades de promissorias
      LOOP

        EXIT WHEN vr_contador > rw_empr.qtpromis;

        BEGIN

          -- Numero do contrato e sequencia
          vr_dsctremp := gene0002.fn_mask_contrato(pr_nrcontrato => rw_empr.nrctremp) || '/' || ltrim(to_char(vr_contador,'000'));
          -- Data do vencimento
          vr_dtvencto := to_date(to_char(vr_ddmvtolt,'00') || '/' || to_char(vr_contames,'00') || '/' || to_char(vr_aamvtolt,'0000'),'dd/mm/yyyy');

        -- Se der erro na montagem da data, ir para o proximo
        EXCEPTION
          WHEN OTHERS THEN
            -- Aumentar o contador
            vr_contador := vr_contador + 1;
            CONTINUE;
        END;

        -- Aumentar o contador
        vr_contador := vr_contador + 1;

        -- Escrever a TAG da promissoria
        pc_escreve_clob('<promissoria>'
                        || '<dtvencto>' || to_char(vr_dtvencto,'DD/MM/RRRR') || '</dtvencto>'
                        || '<dsctremp>' || vr_dsctremp      || '</dsctremp>'
                        || '<vlpreemp>' || vr_vlpreemp      || '</vlpreemp>'
                      ||'</promissoria>');

        vr_contames := vr_contames + vr_nrdmeses;

        -- Aumentar o ano a cada 12 meses
        LOOP

          EXIT WHEN vr_contames <= 12;

          vr_contames := vr_contames - 12;
          vr_aamvtolt := vr_aamvtolt + 1;

        END LOOP;

      END LOOP;

    END;

   -- Fechar a tag do Devedor
   pc_escreve_clob('</devedor>');

  END LOOP;

  -- Se nao houve nenhum registro, criar as tags padrao
  IF  vr_contador IS NULL  THEN
    pc_escreve_clob('<devedor> <promissoria> </promissoria>  </devedor>');
  END IF;

  -- ao fina do loop, prcisamos encerrar a raiz
  pc_escreve_clob('</raiz>');

  -- Obter diretorio rl da cooperativa logada
  vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                      ,pr_cdcooper => pr_cdcooper
                                      ,pr_nmsubdir => 'rl');

  -- Solicitar relatorio crrl202.lst
  gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                        --> Cooperativa conectada
                             ,pr_cdprogra  => vr_cdprogra                        --> Programa chamador
                             ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                --> Data do movimento atual
                             ,pr_dsxml     => vr_dsxmldad                        --> Arquivo XML de dados
                             ,pr_dsxmlnode => '/raiz'                            --> Nó do XML para iteração
                             ,pr_dsjasper  => 'crrl202.jasper'                   --> Arquivo de layout do iReport
                             ,pr_dsparams  => NULL                               --> Array de parametros diversos
                             ,pr_dsarqsaid => vr_dsdireto || '/crrl202.lst'      --> Path/Nome do arquivo PDF gerado
                             ,pr_flg_gerar => 'N'                                --> Gerar o arquivo na hora
                             ,pr_qtcoluna  => 132                                --> Qtd colunas do relatório (80,132,234)
                             ,pr_sqcabrel  => 1                                  --> Sequencia do relatorio (cabrel 1..5)
                             ,pr_flg_impri => 'S'                                --> Chamar a impressão (Imprim.p)
                             ,pr_nmformul  => '132col'                           --> Nome do formulário para impressão
                             ,pr_nrcopias  => 1                                  --> Número de cópias para impressão
                             ,pr_parser    => 'D'                                --> Novo metodo de parse XML
                             ,pr_des_erro  => vr_dscritic);

  -- Liberando a memória alocada pro CLOB
  dbms_lob.close(vr_dsxmldad);
  dbms_lob.freetemporary(vr_dsxmldad);

  -- Testar se houve erro
  IF  vr_dscritic IS NOT NULL  THEN
    -- Gerar exceção
    RAISE vr_exc_saida;
  END IF;

  -- Processo OK, devemos chamar a fimprg
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_stprogra => pr_stprogra);
  COMMIT;

EXCEPTION
  WHEN vr_exc_fimprg THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Se foi gerada critica para envio ao log
    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic );
    END IF;
    -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);
    -- Efetuar commit pois gravaremos o que foi processo até então
    COMMIT;
  WHEN vr_exc_saida THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Devolvemos código e critica encontradas
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

END PC_CRPS251;
/

