CREATE OR REPLACE PROCEDURE CECRED.pc_crps047(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa solicitada
                                             ,pr_flgresta IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                             ,pr_stprogra OUT PLS_INTEGER           --> Saída de termino da execução
                                             ,pr_infimsol OUT PLS_INTEGER           --> Saída de termino da solicitação
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                             ,pr_dscritic OUT VARCHAR2) IS          --> Texto de erro/critica encontrada
BEGIN
  /* ..........................................................................

   Programa: pc_crps047                          
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Mateus Zimmermann (MoutS)
   Data    : Julho/2017.                       Ultima atualizacao: 31/07/2017

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende ao projeto 364.

               Valores para insitlau: 1  ==> a processar
                                      2  ==> processada
                                      3  ==> com erro

     Alteracoes: 

  ............................................................................................*/
  
  DECLARE

    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

    -- CÓDIGO DO PROGRAMA
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS047';

    -- TRATAMENTO DE ERROS
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;

    vr_cdcritic PLS_INTEGER := 0;
    vr_auxcdcri PLS_INTEGER := 0;

    vr_dscritic VARCHAR2(4000);
    vr_auxdscri VARCHAR2(4000);

    -- DIVERSAS
    vr_dsintegr VARCHAR2(50);
    vr_dsarquiv VARCHAR2(200) := '/rl/crrl101.lst';
    vr_nrdolot1 INTEGER;
    vr_nrdolot2 INTEGER;
    vr_nrdolote INTEGER;
    vr_cdcooper INTEGER;
    vr_cdcopmig INTEGER;
    vr_cdagenci INTEGER;
    vr_nrdconta INTEGER;
    vr_cdbccxlt INTEGER;
    vr_migracao INTEGER;
    vr_flagatr  INTEGER := 0;
    vr_craplot  INTEGER := 0;
    vr_ctamigra INTEGER := 0;
    vr_dsdmensg  VARCHAR2(1500);
    vr_nmconven  VARCHAR2(200);
    vr_flgentra INTEGER := 0;
    vr_glbcoop  INTEGER := pr_cdcooper;
    vr_busca VARCHAR2(100);
    vr_nrdocmto craplct.nrdocmto%TYPE;
    vr_nrseqdig craplot.nrseqdig%TYPE;

    vr_nrcrcard craplau.nrcrcard%TYPE;

    vr_stsnrcal NUMBER;
    vr_clobxml  CLOB;

    vr_dsparame crapsol.dsparame%type;
    vr_dsdctitg craprej.nrdctitg%TYPE;
    vr_gerandb NUMBER := 1; -- Gera crapndb

    vr_dsctajud crapprm.dsvlrprm%TYPE;

    --Chamado 709894
    vr_dsparam  varchar2(2000);
    vr_idprglog tbgen_prglog.idprglog%TYPE := 0;      

    ------------------------------- CURSORES ---------------------------------

    -- BUSCA DOS DADOS DA COOPERATIVA
    CURSOR cr_crapcop IS
      SELECT cop.nmrescop, cop.nmextcop, cop.cdagesic
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper; -- CODIGO DA COOPERATIVA
    rw_crapcop cr_crapcop%ROWTYPE;

    -- CURSOR GENÉRICO DE CALENDÁRIO
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    -- BUSCA LANCAMENTOS AUTOMATICOS
    CURSOR cr_craplau(pr_cdcooper IN crapcop.cdcooper%TYPE,
                      pr_dtmvtopr IN crapdat.dtmvtopr%TYPE) IS
      SELECT lau.cdagenci,
             lau.nrdconta,
             lau.cdbccxlt,
             lau.cdhistor,
             lau.nrcrcard,
             lau.nrdocmto,
             lau.dscodbar,
             lau.dtmvtopg,
             lau.vllanaut,
             lau.cdseqtel,
             lau.nrdctabb,
             lau.nrseqdig,
             lau.dtmvtolt,
             lau.nrdolote,
             lau.cdcritic,
             lau.cdempres,
             lau.rowid,
             lau.flgblqdb,
             lau.idlancto,            
             ROW_NUMBER() OVER(PARTITION BY lau.cdagenci,
                                            lau.cdbccxlt,
                                            lau.cdbccxpg,
                                            lau.cdhistor
                               ORDER BY lau.cdagenci,
                                        lau.cdbccxlt,
                                        lau.cdbccxpg,
                                        lau.cdhistor,
                                        lau.nrdocmto) AS seqlauto
        FROM craplau lau
       WHERE lau.cdcooper = pr_cdcooper -- CODIGO DA COOPERATIVA
         AND lau.dtmvtopg <= pr_dtmvtopr -- DATA DE PAGAMENTO
         AND lau.insitlau = 1 -- SITUACAO DO LANCAMENTO
         AND lau.dsorigem IN ('DEVOLUCAOCOTA') -- ORIGEM DA OPERACAO
         AND lau.cdhistor <> 1019 --> 1019 será processado pelo crps642
       ORDER BY lau.cdagenci
               ,lau.cdbccxlt
               ,lau.cdbccxpg
               ,lau.cdhistor
               ,lau.nrdocmto
               ,lau.progress_recid;
    rw_craplau cr_craplau%ROWTYPE;

    -- BUSCA ASSOCIADOS
    CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE,
                      pr_nrdconta IN crapass.nrdconta%TYPE) IS

      SELECT ass.dtelimin,
             ass.cdsitdtl,
             ass.dtdemiss,
             ass.cdsitdct,
             ass.nrdconta,
             ass.cdcooper,
             ass.nrctacns,
             ass.cdagenci,
             ass.vllimcre
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper  -- CODIGO DA COOPERATIVA
         AND ass.nrdconta = pr_nrdconta; -- NUMERO DA CONTA

    rw_crapass cr_crapass%ROWTYPE;

    -- BUSCA SALDOS DO ASSOCIADO EM DEPOSITOS A VISTA
    CURSOR cr_crapsld(pr_cdcooper IN crapcop.cdcooper%TYPE,
                      pr_nrdconta IN crapass.nrdconta%TYPE) IS

      SELECT sld.dtdsdclq, sld.qtddsdev, sld.vlsddisp
        FROM crapsld sld
       WHERE sld.cdcooper = pr_cdcooper  -- CODIGO DA COOPERATIVA
         AND sld.nrdconta = pr_nrdconta; -- NUMERO DA CONTA

    rw_crapsld cr_crapsld%ROWTYPE;

  BEGIN

    --------------- VALIDACOES INICIAIS -----------------

    -- INCLUIR NOME DO MÓDULO LOGADO
    GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra,
                               pr_action => NULL);

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
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                             ,pr_flgbatch => 1
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_cdcritic => vr_cdcritic);

    -- SE A VARIAVEL DE ERRO É <> 0
    IF vr_cdcritic <> 0 THEN
      -- ENVIO CENTRALIZADO DE LOG DE ERRO
      RAISE vr_exc_saida;
    END IF;

    vr_dsparame := NULL;

    -- VERIFICA SE DEVE RODAR OU NAO
    IF INSTR(UPPER(vr_dsparame), vr_cdprogra) = 0 THEN
      --SE O PROGRAMA NÃO ESTIVER NO PARAMETRO, DEVE FINALIZAR O PROGRMA SEM GERAR OS RELATORIOS
      RAISE vr_exc_fimprg;
    END IF;

    -- ARQUIVO P/ GERACAO DO RELATORIO
    vr_dsarquiv := gene0001.fn_diretorio(pr_tpdireto => 'C',
                                         pr_cdcooper => pr_cdcooper) || vr_dsarquiv;

    -- Lista de contas que nao podem debitar na conta corrente, devido a acao judicial
    vr_dsctajud := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                             pr_cdcooper => pr_cdcooper,
                                             pr_cdacesso => 'CONTAS_ACAO_JUDICIAL');

    -- ABRE O CURSOR REFERENTE AOS LANCAMENTOS AUTOMATICOS
    OPEN cr_craplau(pr_cdcooper => pr_cdcooper,          -- CODIGO DA COOPERATIVA
                    pr_dtmvtopr => rw_crapdat.dtmvtopr); -- DATA PROXIMO DIA UTIL

    LOOP
      FETCH cr_craplau
        INTO rw_craplau;

      -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS
      EXIT WHEN cr_craplau%NOTFOUND;

      vr_flgentra := 0;
      vr_ctamigra := 0;
      vr_cdcritic := 0;
      vr_auxcdcri := 0;
      vr_nrdolote := 600038;
      vr_cdcooper := pr_cdcooper;
      vr_cdagenci := rw_craplau.cdagenci;
      vr_nrdconta := rw_craplau.nrdconta; 
      
      vr_gerandb := 1;
      
      -- Busca os dados do associado origem
      OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                         ,pr_nrdconta => rw_craplau.nrdconta);
      
      FETCH cr_crapass INTO rw_crapass;
      
      -- Se nao encontrar o associado, encerra o programa com erro
      IF cr_crapass%NOTFOUND THEN
        
        CLOSE cr_crapass;
        vr_cdcritic := 09;
        RAISE vr_exc_saida;
        
      END IF;
      
      CLOSE cr_crapass;
      
      -- VERIFICA SE NAO OCORREU CRITICA E SE O COOPERADO FOI DEMITIDO
      IF vr_cdcritic = 0 AND rw_crapass.dtdemiss IS NOT NULL THEN

        vr_cdcritic := 454;                                                   -- COOPERADO FOI DEMITIDO
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); -- BUSCA DESCRICAO DA CRITICA
        vr_flgentra := 1;

      END IF;
      
      vr_busca := TRIM(to_char(vr_cdcooper)) || ';' ||
                TRIM(to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR')) || ';' ||
                TRIM(to_char(rw_crapass.cdagenci)) || ';' ||
                '100;' || --cdbccxlt
                vr_nrdolote || ';' || 
                TRIM(to_char(rw_crapass.nrdconta));
                 
      vr_nrdocmto := fn_sequence('CRAPLCT','NRDOCMTO', vr_busca);    
    
      vr_nrseqdig := fn_sequence('CRAPLOT','NRSEQDIG',''||vr_cdcooper||';'||
                                                            to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR')||';'||
                                                            rw_crapass.cdagenci||
                                                            ';100;'|| --cdbccxlt
                                                            vr_nrdolote);

      IF vr_flgentra = 1 AND vr_gerandb = 1 THEN

        BEGIN
          
              INSERT INTO craplct(dtmvtolt
                               ,cdagenci
                               ,cdbccxlt
                               ,nrdolote
                               ,nrdconta
                               ,nrdocmto
                               ,vllanmto
                               ,cdhistor
                               ,nrseqdig
                               ,cdcooper)
                        VALUES (rw_crapdat.dtmvtolt
                               ,1
                               ,100
                               ,vr_nrdolote
                               ,vr_nrdconta
                               ,vr_nrdocmto
                               ,rw_craplau.vllanaut
                               ,2136
                               ,vr_nrseqdig
                               ,vr_cdcooper);

             
             INSERT INTO craplcm(cdcooper
                               ,dtmvtolt
                               ,dtrefere
                               ,cdagenci
                               ,cdbccxlt
                               ,nrdolote
                               ,nrdconta
                               ,nrdctabb
                               ,nrdctitg
                               ,nrdocmto
                               ,cdhistor     
                               ,vllanmto
                               ,nrseqdig)
                        VALUES (vr_cdcooper
                               ,rw_crapdat.dtmvtolt
                               ,rw_crapdat.dtmvtolt
                               ,1
                               ,100
                               ,vr_nrdolote
                               ,vr_nrdconta
                               ,vr_nrdconta
                               ,TO_CHAR(gene0002.fn_mask(vr_nrdconta,'99999999'))
                               ,vr_nrdocmto
                               ,2137 -- CR. COTAS/CAP
                               ,rw_craplau.vllanaut
                               ,vr_nrseqdig);

          -- VERIFICA SE HOUVE PROBLEMA NA INCLUSÃO DO REGISTRO
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Problema ao inserir na tabela CRAPLCM: ' ||
                           sqlerrm;
            RAISE vr_exc_saida;
        END;

        -- VERIFICA SE CRITICA É REFERENTE A MIGRAÇÃO
        IF rw_craplau.cdcritic <> 951 THEN

          BEGIN

            UPDATE craplau
               SET craplau.cdcritic = NVL(vr_cdcritic, 0)
             WHERE craplau.rowid = rw_craplau.rowid;

            -- VERIFICA SE HOUVE PROBLEMA NA ATUALIZAÇÃO DO REGISTRO
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Problema ao atualizar registro na tabela CRAPLAU: ' ||
                             sqlerrm;
              RAISE vr_exc_saida;
          END;
        END IF;

        BEGIN

          -- ATUALIZA REGISTROS DE LANCAMENTOS AUTOMATICOS
          UPDATE craplau
             SET insitlau = 2
           WHERE craplau.rowid = rw_craplau.rowid;

          -- VERIFICA SE HOUVE PROBLEMA NA ATUALIZAÇÃO DO REGISTRO
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Problema ao atualizar registro na tabela CRAPLAU: ' || sqlerrm;
            RAISE vr_exc_saida;
        END;      
      END IF;   

    END LOOP; -- FIM DA LEITURA DOS LANCAMENTOS AUTOMATICOS

    -- Incluir nome do módulo logado - Chamado 709894
    GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action =>  null);

    ----------------- ENCERRAMENTO DO PROGRAMA -------------------

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
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- ERRO TRATATO
                                ,pr_cdprograma   => vr_cdprogra
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - '||vr_cdprogra||' --> '|| 
                                                    'ERRO: '|| vr_dscritic ||
                                                   '. Cdcooper=' || pr_cdcooper ||
                                                   ' ,Flgresta=' || pr_flgresta ||
                                                   ' ,Stprogra=' || pr_stprogra ||
                                                   ' ,Infimsol=' || pr_infimsol );


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
      pr_dscritic := vr_dscritic||vr_dsparam;

      --Geração de log de erro - Chamado 709894
      vr_dscritic := to_char(sysdate,'hh24:mi:ss')||' - ' || vr_cdprogra || 
                             ' --> ' || 'ERRO: ' ||vr_dscritic ||
                             '. Cdcooper=' || pr_cdcooper ||
                             ','||vr_dsparam;

      --Geração de log de erro - Chamado 709894
      cecred.pc_log_programa(pr_dstiplog      => 'E',          -- tbgen_prglog  DEFAULT 'O' --> Tipo do log: I - início; F - fim; O || E - ocorrência
                             pr_cdprograma    => vr_cdprogra,  -- tbgen_prglog
                             pr_cdcooper      => pr_cdcooper,  -- tbgen_prglog
                             pr_tpexecucao    => 1,            -- tbgen_prglog  DEFAULT 1 - Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                             pr_tpocorrencia  => 2,            -- tbgen_prglog_ocorrencia - 1 Erro TRATADO
                             pr_cdcriticidade => 0,            -- tbgen_prglog_ocorrencia DEFAULT 0 - Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                             pr_dsmensagem    => vr_dscritic,  -- tbgen_prglog_ocorrencia
                             pr_flgsucesso    => 1,            -- tbgen_prglog  DEFAULT 1 - Indicador de sucesso da execução
                             pr_nmarqlog      => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE'),
                             pr_idprglog      => vr_idprglog);

      -- EFETUAR ROLLBACK
      ROLLBACK;
    WHEN OTHERS THEN
      -- EFETUAR RETORNO DO ERRO NÃO TRATADO
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;

      --Geração de log de erro - Chamado 709894
      vr_dscritic := to_char(sysdate,'hh24:mi:ss')||' - ' || vr_cdprogra || 
                             ' --> ' || 'ERRO: ' ||pr_dscritic ||
                             '. Cdcooper=' || pr_cdcooper ||
                             ' ,Flgresta=' || pr_flgresta ||
                             ' ,Stprogra=' || pr_stprogra ||
                             ' ,Infimsol=' || pr_infimsol ;

      --Geração de log de erro - Chamado 709894
      cecred.pc_log_programa(pr_dstiplog      => 'E',          -- tbgen_prglog  DEFAULT 'O' --> Tipo do log: I - início; F - fim; O || E - ocorrência
                             pr_cdprograma    => vr_cdprogra,  -- tbgen_prglog
                             pr_cdcooper      => pr_cdcooper,  -- tbgen_prglog
                             pr_tpexecucao    => 1,            -- tbgen_prglog  DEFAULT 1 - Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                             pr_tpocorrencia  => 2,            -- tbgen_prglog_ocorrencia - 1 Erro TRATADO
                             pr_cdcriticidade => 0,            -- tbgen_prglog_ocorrencia DEFAULT 0 - Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                             pr_dsmensagem    => vr_dscritic,  -- tbgen_prglog_ocorrencia
                             pr_flgsucesso    => 1,            -- tbgen_prglog  DEFAULT 1 - Indicador de sucesso da execução
                             pr_nmarqlog      => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE'),
                             pr_idprglog      => vr_idprglog);

      --Inclusão na tabela de erros Oracle - Chamado 709894
      CECRED.pc_internal_exception( pr_cdcooper => pr_cdcooper
                                   ,pr_compleme => pr_dscritic );



      -- EFETUAR ROLLBACK
      ROLLBACK;
  END;

END pc_crps047;
/
