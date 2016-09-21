CREATE OR REPLACE PROCEDURE CECRED.pc_crps297(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                      ,pr_flgresta IN PLS_INTEGER             --> Flag padrão para utilização de restart
                                      ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                      ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                      ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
BEGIN

  /* .............................................................................

     Programa: pc_crps297                                       (Fontes/crps297.p)
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Margarete/Planner
     Data    : Outubro/2000.                       Ultima atualizacao: 13/15/2014

     Dados referentes ao programa:

     Frequencia: Diario (Batch - Background).
     Objetivo  : Atende a solicitacao 001.
                 Fazer a cobertura do saldo devedor das contas de cheque
                 administrativo e de outras contas especiais.

     Alteracoes: 26/05/2004 - Adicionar mais 2 vias para viacredi (Ze Eduardo).

                 30/06/2005 - Alimentado campo cdcooper das tabelas craplot
                              e craplcm (Diego).

                 16/08/2005 - Utilizar o historico 612 quando a cooperativa for
                              VIACREDI e a conta for 83.000-3 (Edson).

                 12/09/2005 - Utilizar o historico 612 quando a cooperativa for
                              VIACREDI e a conta for 85.000-4 (Edson).

                 16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

                 31/03/2006 - Concertada clausula OR do FOR EACH, pondo entre
                              parenteses (Diego).

                 31/08/2007 - Alterado para 1 via Viacredi(Mirtes)

                 09/06/2008 - Incluído o mecanismo de pesquisa no "find" na
                              tabela CRAPHIS para buscar primeiro pela chave de
                              acesso (craphis.cdcooper = glb_cdcooper).
                            - Kbase IT Solutions - Paulo Ricardo Maciel.

                 19/10/2009 - Alteracao Codigo Historico (Kbase).

                 15/08/2013 - Nova forma de chamar as agências, de PAC agora
                              a escrita será PA (André Euzébio - Supero).

                 11/12/2013 - Conversão Progress >> PLSQL (Jean Michel).
                 
                 17/03/2014 - Correção de problemas de mensagem (Marcos-Supero)

                 13/05/2014 - Ajuste no loop da craplcm, estava efetuando a soma
                              de forma errada (Jean Michel)

  ............................................................................ */

  DECLARE

    -- CÓDIGO DO PROGRAMA
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS297';

    -- TRATAMENTO DE ERROS
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_cdcritic PLS_INTEGER;
    vr_dscritic VARCHAR2(4000);

    -- DIVERSAS
    vr_nrdctatb       VARCHAR2(100);
    vr_vlsldtot       DECIMAL(20, 5);
    vr_cdhistor       INTEGER := 0;
    vr_inhistor       INTEGER := 0;
    vr_lcm_cdhistor   INTEGER := 0;
    vr_progress_recid INTEGER := 0;
    vr_seminf         INTEGER := 0;
    vr_dsarqsaid      VARCHAR2(100);

    -- VARIAVEL PARA RELATORIOS E XML
    vr_clobxml CLOB;

    ------------------------------- CURSORES ---------------------------------

    -- BUSCA DOS DADOS DA COOPERATIVA
    CURSOR cr_crapcop IS
      SELECT cop.nmrescop, cop.nmextcop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;

    rw_crapcop cr_crapcop%ROWTYPE;

    -- BUSCA O NUMERO DAS CONTAS ESPECIAIS
    CURSOR cr_craptab(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT tab.dstextab
        FROM craptab tab
       WHERE tab.cdcooper = pr_cdcooper
         AND tab.nmsistem = 'CRED'
         AND tab.tptabela = 'USUARI'
         AND tab.cdacesso = 'CRDEVDIVRS'
         AND tab.tpregist = 1
         AND tab.cdempres = 11;

    rw_craptab cr_craptab%ROWTYPE;

    -- BUSCA COOPERADOS

    CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE,
                      pr_nrdctatb IN VARCHAR2) IS
      SELECT ass.nrdconta, ass.vllimcre, ass.cdagenci, ass.nmprimtl
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND (ass.inpessoa = 3 OR 'S' = gene0002.fn_existe_valor(pr_base => pr_nrdctatb, pr_busca => ass.nrdconta, pr_delimite => ','));

    rw_crapass cr_crapass%ROWTYPE;

    -- CURSOR GENÉRICO DE CALENDÁRIO
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    -- BUSCA SALDOS
    CURSOR cr_crapsld(pr_cdcooper IN crapcop.cdcooper%TYPE,
                      pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT sld.vlsdblfp, sld.vlsdbloq, sld.vlsdblpr, sld.vlsddisp
        FROM crapsld sld
       WHERE sld.cdcooper = pr_cdcooper
         AND sld.nrdconta = pr_nrdconta;

    rw_crapsld cr_crapsld%ROWTYPE;

    -- BUSCA LANCAMENTOS
    CURSOR cr_craplcm(pr_cdcooper IN crapcop.cdcooper%TYPE,
                      pr_nrdconta IN crapass.nrdconta%TYPE,
                      pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
      SELECT lcm.cdhistor, lcm.vllanmto
        FROM craplcm lcm
       WHERE lcm.cdcooper = pr_cdcooper
         AND lcm.nrdconta = pr_nrdconta
         AND lcm.dtmvtolt = pr_dtmvtolt
         AND lcm.cdhistor <> 289 -- BASE CPMF CSD
       ORDER BY lcm.cdcooper,
                lcm.nrdconta,
                lcm.dtmvtolt,
                lcm.cdhistor,
                lcm.nrdocmto;

    rw_craplcm cr_craplcm%ROWTYPE;

    -- BUSCA HISTORICOS
    CURSOR cr_craphis(pr_cdcooper IN crapcop.cdcooper%TYPE,
                      pr_cdhistor IN craphis.cdhistor%TYPE) IS
      SELECT his.cdhistor, his.inhistor
        FROM craphis his
       WHERE his.cdcooper = pr_cdcooper
         AND his.cdhistor = pr_cdhistor
       ORDER BY his.cdcooper, his.cdhistor;

    rw_craphis cr_craphis%ROWTYPE;

    -- BUSCA LOTES
    CURSOR cr_craplot(pr_cdcooper IN crapcop.cdcooper%TYPE,
                      pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
      SELECT lot.cdagenci,
             lot.cdbccxlt,
             lot.nrdolote,
             lot.nrseqdig,
             lot.qtcompln,
             lot.vlcompcr,
             lot.progress_recid
        FROM craplot lot
       WHERE lot.cdcooper = pr_cdcooper
         AND lot.dtmvtolt = pr_dtmvtolt
         AND lot.cdagenci = 1
         AND lot.cdbccxlt = 100
         AND lot.nrdolote = 8452;

    rw_craplot cr_craplot%ROWTYPE;

    -- SUBROTINA PARA PARA ESCREVBR TEXTO NA VARIAVEL CLOB DO XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
    BEGIN
      dbms_lob.writeappend(vr_clobxml, length(pr_des_dados), pr_des_dados);
    END;

  BEGIN

    -- INCLUIR NOME DO MÓDULO LOGADO
    GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra,
                               pr_action => null);
    -- VERIFICA SE A COOPERATIVA ESTA CADASTRADA
    OPEN cr_crapcop;
    FETCH cr_crapcop
      INTO rw_crapcop;
    -- SE NÃO ENCONTRAR
    IF cr_crapcop%NOTFOUND THEN
      -- FECHAR O CURSOR POIS HAVERÁ RAISE
      CLOSE cr_crapcop;
      -- MONTAR MENSAGEM DE CRITICA
      vr_cdcritic := 651;
      RAISE vr_exc_saida;
    ELSE
      -- APENAS FECHAR O CURSOR
      CLOSE cr_crapcop;
    END IF;

    -- LEITURA DO CALENDÁRIO DA COOPERATIVA
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat
      INTO rw_crapdat;
    -- SE NÃO ENCONTRAR
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- FECHAR O CURSOR POIS EFETUAREMOS RAISE
      CLOSE btch0001.cr_crapdat;
      -- MONTAR MENSAGEM DE CRITICA
      vr_cdcritic := 1;
      RAISE vr_exc_saida;
    ELSE
      -- APENAS FECHAR O CURSOR
      CLOSE btch0001.cr_crapdat;
    END IF;

    -- VALIDAÇÕES INICIAIS DO PROGRAMA
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper,
                              pr_flgbatch => 1,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_cdcritic => vr_cdcritic);
    -- Se a variavel de erro é <> 0
    IF vr_cdcritic <> 0 THEN
      -- Envio centralizado de log de erro
      RAISE vr_exc_saida;
    END IF;

    -- BUSCA AS CONTAS "ESPECIAIS" DE CADA COOPERATIVA
    -- ESSAS CONTAS SAO CONTAS DA PROPRIA COOPERATIVA NELA MESMA, O INPESSOA DESTA CONTA NA CRAPASS É 3
    OPEN cr_craptab(pr_cdcooper => pr_cdcooper);
    FETCH cr_craptab
      INTO rw_craptab;

    -- SE NÃO ENCONTRAR
    IF cr_craptab%NOTFOUND THEN
      -- FECHAR O CURSOR POIS EFETUAREMOS RAISE
      CLOSE cr_craptab;
    ELSE
      -- APENAS FECHAR O CURSOR
      CLOSE cr_craptab;
      vr_nrdctatb := rw_craptab.dstextab;
    END IF;

    -- INICIALIZAR O CLOB (XML)
    dbms_lob.createtemporary(vr_clobxml, TRUE);
    dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);

    -- INICIO DO ARQUIVO XML
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz>');

    -- CURSOR REFERENTE AOS COOPERADOS
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper, pr_nrdctatb => vr_nrdctatb);
    LOOP
      FETCH cr_crapass
        INTO rw_crapass;

      -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS
      EXIT WHEN cr_crapass%NOTFOUND;

      -- CONSULTA SALDOS
      OPEN cr_crapsld(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => rw_crapass.nrdconta);
      FETCH cr_crapsld
        INTO rw_crapsld;

      -- SE NÃO ENCONTRAR
      IF cr_crapsld%NOTFOUND THEN
        -- FECHAR O CURSOR POIS HAVERÁ RAISE
        CLOSE cr_crapsld;

        -- MONTAR MENSAGEM DE CRITICA
        vr_cdcritic := 10;

        -- ENVIO CENTRALIZADO DE LOG DE ERRO
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 2, -- Erro tratato
                                   pr_des_log      => to_char(sysdate,
                                                              'hh24:mi:ss') ||
                                                      ' - ' || vr_cdprogra ||
                                                      ' --> ' || vr_cdcritic ||
                                                      ' - ' || vr_dscritic);
        RAISE vr_exc_saida;
      ELSE
        -- APENAS FECHAR O CURSOR
        CLOSE cr_crapsld;

        -- CALCULO DE SALDO TOTAL
        vr_vlsldtot := rw_crapsld.vlsdblfp + rw_crapsld.vlsdbloq +
                       rw_crapsld.vlsdblpr + rw_crapsld.vlsddisp +
                       rw_crapass.vllimcre;
      END IF;

      -- CONSULTA LANCAMENTOS
      OPEN cr_craplcm(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => rw_crapass.nrdconta,
                      pr_dtmvtolt => rw_crapdat.dtmvtolt);
      LOOP
        FETCH cr_craplcm
          INTO rw_craplcm;

        -- SAI DO LOOP QUANDO CHEGAR AO FIM DO ARQUIVO
        EXIT WHEN cr_craplcm%NOTFOUND;

        IF vr_cdhistor <> rw_craplcm.cdhistor THEN

          -- CONSULTA HISTORICO
          OPEN cr_craphis(pr_cdcooper => pr_cdcooper,
                          pr_cdhistor => rw_craplcm.cdhistor);
          FETCH cr_craphis
            INTO rw_craphis;

          -- SE NÃO ENCONTRAR
          IF cr_craphis%NOTFOUND THEN
            -- FECHAR O CURSOR POIS HAVERÁ RAISE
            CLOSE cr_craphis;

            vr_cdhistor := rw_craplcm.cdhistor;
            vr_inhistor := 0;

            -- MONTAR MENSAGEM DE CRITICA
            vr_cdcritic := 83;
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

            -- ENVIO CENTRALIZADO DE LOG DE ERRO
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                       pr_ind_tipo_log => 2, -- Erro tratato
                                       pr_des_log      => to_char(sysdate,
                                                                  'hh24:mi:ss') ||
                                                          ' - ' ||
                                                          vr_cdprogra ||
                                                          ' --> ' ||
                                                          vr_cdcritic ||
                                                          ' - ' ||
                                                          vr_dscritic);
            -- Limpeza
            vr_cdcritic := 0;
            vr_dscritic := null;
                                                          

          ELSE
            -- APENAS FECHAR O CURSOR
            CLOSE cr_craphis;

            vr_cdhistor := rw_craphis.cdhistor; -- CODIGO DO HISTÓRICO
            vr_inhistor := rw_craphis.inhistor; -- INDICE DO HISTÓRICO
          END IF;

        END IF;
        
        -- VERIFICA SE INDICE DO HISTORICO ATENDE AS CONDICOES
        -- 1 - CREDITO NO VLSDDISP / 3 - CREDITO NO VLSDBLOQ / 4 - CREDITO NO VLSDBLPR / 5 - CREDITO NO VLSDBLFP
        IF vr_inhistor IN (1, 3, 4, 5) THEN
          vr_vlsldtot := vr_vlsldtot + rw_craplcm.vllanmto;
        END IF;

        -- VERIFICA SE INDICE DO HISTORICO ATENDE AS CONDICOES
        -- 11 - DEBITO NO VLSDDISP / 13 - EBITO NO VLSDBLOQ / 14 - DEBITO NO VLSDBLPR / 15 - DEBITO NO VLSDBLFP
        IF vr_inhistor IN (11, 13, 14, 15) THEN
          vr_vlsldtot := vr_vlsldtot - rw_craplcm.vllanmto;
        END IF;

      END LOOP; -- LOOP LCM

      CLOSE cr_craplcm;

      -- VERIFICA SE O SALDO TOTAL É MENOR QUE ZERO
      IF vr_vlsldtot < 0 THEN

        -- CONSULTA DE LOTES
        OPEN cr_craplot(pr_cdcooper => pr_cdcooper,
                        pr_dtmvtolt => rw_crapdat.dtmvtolt);
        FETCH cr_craplot
          INTO rw_craplot;

        -- SE NÃO ENCONTRAR
        IF cr_craplot%NOTFOUND THEN

          -- FECHAR O CURSOR POIS HAVERÁ RAISE
          CLOSE cr_craplot;

          BEGIN

            -- INCLUSAO DE REGISTRO NA CRAPLOT
            INSERT INTO craplot
              (dtmvtolt,
               cdagenci,
               cdbccxlt,
               nrdolote,
               tplotmov,
               nrseqdig,
               vlcompcr,
               vlinfocr,
               cdhistor,
               cdoperad,
               dtmvtopg,
               cdcooper)
            VALUES
              (rw_crapdat.dtmvtolt,
               1,
               100,
               8452,
               1,
               0,
               0,
               0,
               0,
               '1',
               NULL,
               pr_cdcooper)
            RETURNING progress_recid INTO vr_progress_recid; -- RETORNA O COD DE PROGRESS_RECID DO REGISTRO QUE FOI INSERIDO

            -- VERIFICA SE HOUVE PROBLEMA NA INCLUSÃO DO REGISTRO
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Problema ao inserir na tabela CRAPLOT: ' || sqlerrm;
              RAISE vr_exc_saida;
          END;
        ELSE
          -- APENAS FECHAR O CURSOR
          CLOSE cr_craplot;
          vr_progress_recid := rw_craplot.progress_recid;
        END IF;

        vr_lcm_cdhistor := 366; -- TRANSFERENCIA PARA DEVEDORES DIVERSOS

        -- VERIFICA SE A COOPERATIVA É A VIACREDI E A CONTA ESPECIAL DA MESMA
        IF pr_cdcooper = 1 AND
           ('S' = gene0002.fn_existe_valor(pr_base => gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                                                             ,pr_cdcooper => pr_cdcooper
                                                                                             ,pr_cdacesso => 'CONTAS_VIACREDI')
                                    ,pr_busca => rw_crapass.nrdconta
                                    ,pr_delimite => ','))THEN

          vr_lcm_cdhistor := 612; -- ADIANTAMENTO A FORNECEDORES

        END IF;

        vr_vlsldtot := - (vr_vlsldtot); -- ALTERA SINAL DO VALOR DEVEDOR P/ CRIAR UM LANCAMENTO P/ ZERAR O SALDO

        BEGIN
          -- ATUALIZACAO DE REGISTRO NA CRAPLOT
          UPDATE craplot
             SET craplot.nrseqdig = rw_craplot.nrseqdig + 1,
                 craplot.qtcompln = rw_craplot.qtcompln + 1,
                 craplot.qtinfoln = rw_craplot.qtcompln + 1,
                 craplot.vlcompcr = rw_craplot.vlcompcr + vr_vlsldtot,
                 craplot.vlinfocr = rw_craplot.vlcompcr + vr_vlsldtot
           WHERE progress_recid = vr_progress_recid;

          -- INCLUSAO DE REGISTRO NA CRAPLCM
          INSERT INTO craplcm
            (cdagenci,
             cdbccxlt,
             cdhistor,
             dtmvtolt,
             cdpesqbb,
             nrdconta,
             nrdctabb,
             nrdctitg,
             nrdocmto,
             nrdolote,
             nrseqdig,
             vllanmto,
             cdcooper)
          VALUES
            (rw_craplot.cdagenci,
             rw_craplot.cdbccxlt,
             vr_lcm_cdhistor,
             rw_crapdat.dtmvtolt,
             ' ',
             rw_crapass.nrdconta,
             rw_crapass.nrdconta,
             gene0002.fn_mask(rw_crapass.nrdconta, '99999999'),
             rw_craplot.nrseqdig + 1,
             rw_craplot.nrdolote,
             rw_craplot.nrseqdig + 1,
             vr_vlsldtot,
             pr_cdcooper);

          -- VERIFICA SE HOUVE ERRO NA INCLUSAO DO REGISTRO
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Problema ao inserir na tabela CRAPLCM: ' || sqlerrm;
            RAISE vr_exc_saida;
        END;

        -- FLAG INDICA QUE HÁ INFORMAÇÕES NO RELATÓRIO
        vr_seminf := 1;

        -- MONTA XML
        pc_escreve_xml('<nrdconta id="' ||
                       gene0002.fn_mask_conta(rw_crapass.nrdconta) || '">' ||
                       '<cdcooper>' || pr_cdcooper || '</cdcooper>' ||
                       '<cdagenci>' || rw_crapass.cdagenci ||
                       '</cdagenci>' || '<nmprimtl>' ||
                       SUBSTR(rw_crapass.nmprimtl,0,35) || '</nmprimtl>' ||
                       '<vlsldtot>' ||
                       TO_CHAR(vr_vlsldtot, '9G999G990D00') ||
                       '</vlsldtot>' ||
                       '<dtacerto>____/____/______</dtacerto>' ||
                       '</nrdconta>');

      END IF;

    END LOOP; -- LOOP CRAPASS

    -- VERIFICA SE HÁ INFORMAÇÕE SNO RELATÓRIO, CASO NÃO TENHA, GERA TAGS EM BRANCO
    IF vr_seminf = 0 THEN
      pc_escreve_xml('<nrdconta id="">' || '<cdcooper></cdcooper>' ||
                     '<cdagenci></cdagenci>' || '<nmprimtl></nmprimtl>' ||
                     '<vlsldtot></vlsldtot>' || '<dtacerto></dtacerto>' ||
                     '</nrdconta>');
    END IF;

    -- FECHA TAG PAI DO XML
    pc_escreve_xml('</raiz>');

    -- DIRETORIO QUE SERA GERADO O ARQUIVO FINAL
    vr_dsarqsaid := gene0001.fn_diretorio(pr_tpdireto => 'C',
                                          pr_cdcooper => pr_cdcooper,
                                          pr_nmsubdir => 'rl') ||
                    '/crrl249.lst';
    -- SOLICITACAO DO RELATORIO
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,         --> Cooperativa
                                pr_cdprogra  => vr_cdprogra,         --> Programa chamador
                                pr_dtmvtolt  => rw_crapdat.dtmvtolt, --> Data do movimento atual
                                pr_dsxml     => vr_clobxml,          --> Arquivo XML de dados
                                pr_dsxmlnode => '/raiz/nrdconta',    --> Nó do XML para iteração
                                pr_dsjasper  => 'crrl249.jasper',    --> Arquivo de layout do iReport
                                pr_dsparams  => '',                  --> Array de parametros diversos
                                pr_dsarqsaid => vr_dsarqsaid,        --> Path/Nome do arquivo PDF gerado
                                pr_flg_gerar => 'N',                 --> Gerar o arquivo na hora*
                                pr_qtcoluna  => 80,                  --> Qtd colunas do relatório (80,132,234)
                                pr_flg_impri => 'S',                 --> Chamar a impressão (Imprim.p)*
                                pr_nmformul  => '80col',             --> Nome do formulário para impressão
                                pr_nrcopias  => 1,                   --> Qtd de cópias
                                pr_des_erro  => vr_dscritic);        --> Saída com erro

    -- VERIFICA SE OCORREU UMA CRITICA
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    -- LIBERA A MEMORIA ALOCADA P/ VARIAVE CLOB
    dbms_lob.close(vr_clobxml);
    dbms_lob.freetemporary(vr_clobxml);

    -- PROCESSO OK, DEVEMOS CHAMAR A FIMPRG
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_stprogra => pr_stprogra);

    -- SALVAR INFORMAÇÕES ATUALIZADAS
    COMMIT;
  EXCEPTION
    WHEN vr_exc_fimprg THEN

      -- SE FOI RETORNADO APENAS CÓDIGO
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- BUSCAR A DESCRIÇÃO
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- ENVIO CENTRALIZADO DE LOG DE ERRO
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro tratato
                                 pr_des_log      => to_char(sysdate,
                                                            'hh24:mi:ss') ||
                                                    ' - ' || vr_cdprogra ||
                                                    ' --> ' || vr_dscritic);

      -- CHAMAMOS A FIMPRG PARA ENCERRARMOS O PROCESSO SEM PARAR A CADEIA
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                                pr_cdprogra => vr_cdprogra,
                                pr_infimsol => pr_infimsol,
                                pr_stprogra => pr_stprogra);
      -- EFETUAR COMMIT
      COMMIT;
    WHEN vr_exc_saida THEN

      -- SE FOI RETORNADO APENAS CÓDIGO
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- BUSCAR A DESCRIÇÃO
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- DEVOLVEMOS CÓDIGO E CRITICA ENCONTRADAS DAS VARIAVEIS LOCAIS
      pr_cdcritic := NVL(vr_cdcritic, 0);
      pr_dscritic := vr_dscritic;

      -- EFETUAR ROLLBACK
      ROLLBACK;

    WHEN OTHERS THEN
      -- EFETUAR RETORNO DO ERRO NÃO TRATADO
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- EFETUAR ROLLBACK
      ROLLBACK;

  END;

END pc_crps297;
/

