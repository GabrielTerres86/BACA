CREATE OR REPLACE PROCEDURE CECRED.pc_crps715 (pr_cdcooper IN crapcop.cdcooper%TYPE ) IS   --> Cooperativa solicitada
  /* .............................................................................

     Programa: pc_crps715 (Fontes/crps715.p)
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Odirlei Busana - AMcom
     Data    : Março/2017                     Ultima atualizacao: 24/03/2017

     Dados referentes ao programa:

     Frequencia: Executado via Job
     Objetivo  : Realizar geração do arquivo contabil de emprestimo de
                 cessão de credito.

     Alteracoes: Ajustes nas contas contabeis geradas nos lancamentos e criacao
                 do lancamento gerencial 999 (SD 718024 Anderson).

  ............................................................................ */

  ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

  -- Código do programa
  vr_cdprogra   CONSTANT crapprg.cdprogra%TYPE := 'CRPS715';
  vr_cdcooper   NUMBER  := 3;

  -- Tratamento de erros
  vr_exc_saida  EXCEPTION;
  vr_exc_erro   EXCEPTION;  
  vr_cdcritic   PLS_INTEGER;
  vr_dscritic   VARCHAR2(4000);

  ------------------------------- CURSORES ---------------------------------

  -- Busca dos dados da cooperativa
  CURSOR cr_crapcop IS
    SELECT cop.nmrescop
          ,cop.cdcooper
      FROM crapcop cop
     WHERE cop.cdcooper = decode(pr_cdcooper,0,cop.cdcooper,pr_cdcooper)
       AND cop.cdcooper <> 3
       AND cop.flgativo = 1;
  rw_crapcop cr_crapcop%ROWTYPE;


  -- buscar nome do programa
  CURSOR cr_crapprg IS
    SELECT lower(crapprg.dsprogra##1) dsprogra##1
      FROM crapprg
     WHERE cdcooper = vr_cdcooper
       AND cdprogra = vr_cdprogra;
  rw_crapprg cr_crapprg%ROWTYPE;

  --> Buscar dados do cooperado
  CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE,
                    pr_nrdconta crapass.nrdconta%TYPE) IS
    SELECT ass.nrdconta,
           ass.nmprimtl
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;

  --> Buscar valore da central de risco
  CURSOR cr_crapris (pr_cdcooper crapass.cdcooper%TYPE,
                     pr_dtultdma crapdat.dtultdma%TYPE) IS
     SELECT ass.inpessoa,
            ris.cdagenci,
            SUM(vri.vldivida) vltotdiv,
            row_number() OVER (PARTITION BY ass.inpessoa ORDER BY ass.inpessoa ) seqdreg,
            COUNT(1) OVER (PARTITION BY ass.inpessoa ORDER BY ass.inpessoa ) qtddreg
       FROM crapvri vri,
            crapris ris,
            tbcrd_cessao_credito ces,
            crapass ass
      WHERE ces.cdcooper = ass.cdcooper
        AND ces.nrdconta = ass.nrdconta
        AND vri.cdcooper = ris.cdcooper
        AND vri.nrdconta = ris.nrdconta
        AND vri.dtrefere = ris.dtrefere
        AND vri.innivris = ris.innivris
        AND vri.cdmodali = ris.cdmodali
        AND vri.nrctremp = ris.nrctremp
        AND vri.nrseqctr = ris.nrseqctr 
        AND ces.cdcooper = ris.cdcooper
        AND ces.nrdconta = ris.nrdconta
        AND ces.nrctremp = ris.nrctremp
        AND vri.cdvencto BETWEEN 110 AND 290
        AND ces.cdcooper = pr_cdcooper
        AND ris.cdorigem = 3
        AND ris.dtrefere = pr_dtultdma
        --> Gerar linha com o somatorios
        GROUP BY ROLLUP  (ass.inpessoa, ris.cdagenci) 
        --> Ordenar para linha de somatorio ser apresentada primeiro
        ORDER BY ass.inpessoa, nvl(ris.cdagenci,0) ASC;
  
  
  --> Listar valore das cessoes por agencia, pessoa
  CURSOR cr_cessao (pr_cdcooper crapass.cdcooper%TYPE,
                    pr_dtultdma crapdat.dtultdma%TYPE) IS
    SELECT ass.cdagenci
          ,ass.inpessoa
          ,SUM(lem.vllanmto) vltotdiv
          ,row_number() OVER (PARTITION BY ass.inpessoa ORDER BY ass.inpessoa ) seqdreg
          ,COUNT(1) OVER (PARTITION BY ass.inpessoa ORDER BY ass.inpessoa ) qtddreg          
      FROM tbcrd_cessao_credito ces
      JOIN craplem lem
        ON lem.cdcooper = ces.cdcooper
       AND lem.nrdconta = ces.nrdconta
       AND lem.nrctremp = ces.nrctremp
      JOIN crapass ass
        ON ass.cdcooper = ces.cdcooper
       AND ass.nrdconta = ces.nrdconta
     WHERE ces.cdcooper = pr_cdcooper
       AND lem.dtmvtolt BETWEEN trunc(pr_dtultdma,'MM') AND pr_dtultdma  --mês do dtultdma
       AND lem.cdhistor IN (1038, 1037) --> Historicos de juros emprest. efinanc.
      --> Gerar linha com o somatorios
      GROUP BY ROLLUP  (ass.inpessoa, ass.cdagenci) 
      --> Ordenar para linha de somatorio ser apresentada primeiro
      ORDER BY ass.inpessoa, ass.cdagenci DESC; 
      
      
  -- Cursor genérico de calendário
  rw_crapdat btch0001.cr_crapdat%ROWTYPE; 
  
  ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

  ------------------------------- VARIAVEIS -------------------------------
  vr_qtmeslim     INTEGER := 0;
  vr_dtlimepr     DATE;
  vr_qtderros     NUMBER  := 0;
  vr_qtsucess     NUMBER  := 0;


  vr_comando      VARCHAR2(2000);
  vr_typ_saida    VARCHAR2(4000);

  -- Nome do diretorio da cooperativa
  vr_nmdireto     VARCHAR2(500);
  vr_dsdirarq     VARCHAR2(500);
  vr_nmarqdat     VARCHAR2(500);
  vr_dircopia     VARCHAR2(500);

  vr_cdfinali     crapepr.cdfinemp%TYPE;
  vr_cdlcremp     crapepr.cdlcremp%TYPE;
  vr_cdagebcb     crapcop.cdagebcb%TYPE;
  vr_nrdconta     crapass.nrdconta%TYPE;
  vr_vldevido     crapepr.vlemprst%TYPE;
  vr_nrcartao     NUMBER;
  vr_nrexiste     INTEGER;
  vr_dtvencto     DATE;
  vr_dtvencto_ori DATE;
  vr_cdadmcrd     crapcrd.cdadmcrd%TYPE;
  vr_nrctremp     crapepr.nrctremp%TYPE;
  vr_vltotali     crapris.vldivida%TYPE;

  -- Data do movimento no formato texto
  vr_dtultdma_util_yymmdd  varchar2(6);
  vr_dtultdma_util_ddmmyy  varchar2(6);
  vr_dtultdia_util_ddmmyy  varchar2(6);
    
  vr_lshistor     VARCHAR2(600);
  vr_dshistor     VARCHAR2(600);
  vr_lshistor_rev VARCHAR2(600);
  vr_dshistor_rev VARCHAR2(600);


  -- Variáveis para armazenar as informações 
  vr_desclob         CLOB;
  vr_desclob_rev     CLOB;
  -- Variável para armazenar os dados antes de incluir no CLOB
  vr_txtcompl        VARCHAR2(32600);
  vr_txtcompl_rev    VARCHAR2(32600);
  vr_dsdlinha        VARCHAR2(32600);
      

  --------------------------- SUBROTINAS INTERNAS --------------------------

  vr_nomdojob    VARCHAR2(40) := 'JBEPR_CONTABILIZA_CESSAO';
  vr_flgerlog    BOOLEAN := FALSE;

  --> Controla log proc_batch, para apenas exibir qnd realmente processar informação
  PROCEDURE pc_controla_log_batch(pr_cdcooper IN crapcop.cdcooper%TYPE,
                                  pr_dstiplog IN VARCHAR2, -- 'I' início; 'F' fim; 'E' erro
                                  pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
  BEGIN
    --> Controlar geração de log de execução dos jobs
    BTCH0001.pc_log_exec_job( pr_cdcooper  => pr_cdcooper    --> Cooperativa
                             ,pr_cdprogra  => vr_cdprogra    --> Codigo do programa
                             ,pr_nomdojob  => vr_nomdojob    --> Nome do job
                             ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                             ,pr_dscritic  => pr_dscritic    --> Critica a ser apresentada em caso de erro
                             ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim
  END pc_controla_log_batch;

  -- Subrotina para escrever texto na variável CLOB 
  PROCEDURE pc_escreve_linha(pr_dsdlinha IN VARCHAR2,
                             pr_flrevers IN BOOLEAN DEFAULT FALSE,
                             pr_fechaarq IN BOOLEAN DEFAULT FALSE) IS
    vr_des_dados VARCHAR2(32000);
  BEGIN
    vr_des_dados := pr_dsdlinha;
    IF pr_flrevers = FALSE THEN
      gene0002.pc_escreve_xml(vr_desclob, vr_txtcompl, vr_des_dados, pr_fechaarq);
    ELSE
      gene0002.pc_escreve_xml(vr_desclob_rev, vr_txtcompl_rev, vr_des_dados, pr_fechaarq);
    END IF;
  END;


BEGIN

  --------------- VALIDACOES INICIAIS -----------------
  
  -- Incluir nome do módulo logado
  GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                            ,pr_action => null);

  -- Buscar nome do programa
  OPEN cr_crapprg;
  FETCH cr_crapprg INTO rw_crapprg;
  CLOSE cr_crapprg;

  -- Verificar se é para rodar para todas as cooperativas
  IF pr_cdcooper = 0 THEN
    vr_cdcooper := 3;
  ELSE
    vr_cdcooper := pr_cdcooper;
  END IF;


  --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
  FOR rw_crapcop IN cr_crapcop LOOP
    BEGIN
      -- Log de fim da execução
      pc_controla_log_batch(pr_cdcooper => rw_crapcop.cdcooper,
                            pr_dstiplog => 'I');
    
      -- Inicializar o CLOB
      vr_desclob := NULL;
      dbms_lob.createtemporary(vr_desclob, TRUE);
      dbms_lob.open(vr_desclob, dbms_lob.lob_readwrite);
      
      vr_desclob_rev := NULL;
      dbms_lob.createtemporary(vr_desclob_rev, TRUE);
      dbms_lob.open(vr_desclob_rev, dbms_lob.lob_readwrite);
      
      -- Inicilizar as informações do XML
      vr_txtcompl_rev := NULL;
      vr_txtcompl     := NULL;
      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);

      FETCH btch0001.cr_crapdat INTO rw_crapdat;

      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN

        CLOSE btch0001.cr_crapdat;
        vr_cdcritic := 1;
        RAISE vr_exc_erro;
      ELSE
        CLOSE btch0001.cr_crapdat;
      END IF;
      
      -- Formata a data para criar o nome do arquivo
      vr_dtultdma_util_yymmdd  := to_char(gene0005.fn_valida_dia_util(pr_cdcooper,
                                                                      rw_crapdat.dtultdma,
                                                                      'A'), 'yymmdd');
      vr_dtultdma_util_ddmmyy  := to_char(to_date(vr_dtultdma_util_yymmdd, 'yymmdd'),'DDMMRR');
      vr_dtultdia_util_ddmmyy  := to_char(rw_crapdat.dtultdia, 'DDMMRR');
      --> Buscar valore da central de risco
      FOR rw_crapris IN cr_crapris (pr_cdcooper => rw_crapcop.cdcooper,
                                    pr_dtultdma => rw_crapdat.dtultdma) LOOP
      
        --> Total geral
        IF rw_crapris.cdagenci IS NULL AND 
           rw_crapris.inpessoa IS NULL THEN
          continue;
        --> se não contem cdagenci, é a linha totalizador 
        ELSIF rw_crapris.cdagenci IS NULL THEN
          
          IF rw_crapris.inpessoa = 1 THEN
            vr_lshistor := '1753,1664';
            vr_dshistor := '"(Cessao) SALDO CESSÃO CARTÃO PESSOA FISICA."';
            
            vr_lshistor_rev := '1664,1753';
            vr_dshistor_rev := '"(Cessao) REVERSÃO SALDO CESSÃO CARTÃO PESSOA FISICA."';
            
          ELSIF rw_crapris.inpessoa = 2 THEN
            vr_lshistor := '1754,1664';
            vr_dshistor := '"(Cessao) SALDO CESSÃO CARTÃO PESSOA JURIDICA."';
            
            vr_lshistor_rev := '1664,1754';
            vr_dshistor_rev := '"(Cessao) REVERSÃO SALDO CESSÃO CARTÃO PESSOA JURIDICA."';
            
          END IF;         
        
          --> gerar linha cabeçalho
          vr_dsdlinha := '99'||TRIM(vr_dtultdma_util_yymmdd)        ||','||
                         TRIM(vr_dtultdma_util_ddmmyy)              ||','||
                         vr_lshistor                                ||','||
                         to_char(rw_crapris.vltotdiv,'FM9999999999990D00','NLS_NUMERIC_CHARACTERS=''.,''') ||','||
                         '5210'                                     ||','||
                         vr_dshistor||
                         chr(10);
          --> Escrever no arquivo               
          pc_escreve_linha(pr_dsdlinha => vr_dsdlinha); 
          vr_dsdlinha := NULL;
          
          --> REVERSÃO gerar linha cabeçalho 
          vr_dsdlinha := '99'||TRIM(vr_dtultdma_util_yymmdd)        ||','||
                         TRIM(vr_dtultdia_util_ddmmyy)              ||','||
                         vr_lshistor_rev                            ||','||
                         to_char(rw_crapris.vltotdiv,'FM9999999999990D00','NLS_NUMERIC_CHARACTERS=''.,''') ||','||
                         '5210'                                     ||','||
                         vr_dshistor_rev                            ||
                         chr(10);
          --> Escrever no arquivo               
          pc_escreve_linha(pr_dsdlinha => vr_dsdlinha,
                           pr_flrevers => TRUE); 
          vr_dsdlinha := NULL;
          
          /* Armazena o total para o lançamento gerencial com PA 999 */
          vr_vltotali := rw_crapris.vltotdiv;
        ELSE
          --> Caso for a primeira linha detalhe, vamos escrever o lancamento gerencial PA999 da reversao.
          IF rw_crapris.seqdreg = 2 THEN            
            --> montar linhas detalhes
            vr_dsdlinha := '999,'|| 
                           to_char(vr_vltotali,'FM9999999999990D00','NLS_NUMERIC_CHARACTERS=''.,''')||
                         chr(10);

            --> inserir linha de reversao
            pc_escreve_linha(pr_dsdlinha => vr_dsdlinha,
                             pr_flrevers => TRUE);
        END IF;
        
          --> montar linhas detalhes
          vr_dsdlinha := to_char(rw_crapris.cdagenci,'fm000')||','|| 
                         to_char(rw_crapris.vltotdiv,'FM9999999999990D00','NLS_NUMERIC_CHARACTERS=''.,''')||
                         chr(10);
          
          --> Escreve lançamento normal
          pc_escreve_linha(pr_dsdlinha => vr_dsdlinha);          
          --> inserir linha de reversao
          pc_escreve_linha(pr_dsdlinha => vr_dsdlinha,
                           pr_flrevers => TRUE,
                           pr_fechaarq => (rw_crapris.seqdreg = rw_crapris.qtddreg)); --> descarrega buffer se for a ultima linha

          --> Caso for a ultima linha detalhe, vamos escrever o lancamento gerencial PA999.
          IF rw_crapris.seqdreg = rw_crapris.qtddreg THEN          
            --> montar linhas detalhes
            vr_dsdlinha := '999,'|| 
                           to_char(vr_vltotali,'FM9999999999990D00','NLS_NUMERIC_CHARACTERS=''.,''')||
                           chr(10);
          
            pc_escreve_linha(pr_dsdlinha => vr_dsdlinha,
                           pr_fechaarq => TRUE);  --> descarregar buffer
        END IF;
        END IF;
      
      END LOOP;
      
      --> Concatenar lançamentos 
      dbms_lob.append(vr_desclob,vr_desclob_rev);
      
      --> Listar valore das cessoes por agencia, pessoa
      FOR rw_cessao IN cr_cessao (pr_cdcooper => rw_crapcop.cdcooper,
                                  pr_dtultdma => rw_crapdat.dtultdma ) LOOP
                                  
                                  
        --> Total geral
        IF rw_cessao.cdagenci IS NULL AND 
           rw_cessao.inpessoa IS NULL THEN
          continue;
        --> se não contem cdagenci, é a linha totalizador 
        ELSIF rw_cessao.cdagenci IS NULL THEN
          
          IF rw_cessao.inpessoa = 1 THEN
            vr_lshistor := '7016,7537';
            vr_dshistor := '"(Cessao) AJUSTE RENDAS CONTRATO CESSAO CARTAO PESSOA FISICA."';
            
          ELSIF rw_cessao.inpessoa = 2 THEN          
            vr_lshistor := '7017,7538';
            vr_dshistor := '"(Cessao) AJUSTE RENDAS CONTRATO CESSAO CARTAO PESSOA JURIDICA."';            
          END IF;         
        
          --> gerar linha cabeçalho
          vr_dsdlinha := '99'||TRIM(vr_dtultdma_util_yymmdd)        ||','||
                         TRIM(vr_dtultdma_util_ddmmyy)              ||','||
                         vr_lshistor                                ||','||
                         to_char(rw_cessao.vltotdiv,'FM9999999999990D00','NLS_NUMERIC_CHARACTERS=''.,''') ||','||
                         '5210'                                     ||','||
                         vr_dshistor||
                         chr(10);
          --> Escrever no arquivo               
          pc_escreve_linha(pr_dsdlinha => vr_dsdlinha); 
          vr_dsdlinha := NULL;
          
        ELSE
          --> montar linhas delathes
          vr_dsdlinha := vr_dsdlinha ||
                         to_char(rw_cessao.cdagenci,'fm000')||','|| 
                         to_char(rw_cessao.vltotdiv,'FM9999999999990D00','NLS_NUMERIC_CHARACTERS=''.,''')||
                         chr(10);
        END IF;
        
        --> Caso for a ultima linha detalhe
        IF rw_cessao.seqdreg = rw_cessao.qtddreg THEN
          --Escreve no arquivo duplicando os detalhes
          vr_dsdlinha := vr_dsdlinha || vr_dsdlinha;
          pc_escreve_linha(pr_dsdlinha => vr_dsdlinha,
                           pr_fechaarq => TRUE);  --> descarregar buffer
          
        END IF;
      
      END LOOP;            
      
      -- Busca do diretório onde ficará o arquivo
      vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'C', -- /usr/coop
                                           pr_cdcooper => rw_crapcop.cdcooper,
                                           pr_nmsubdir => '/contab');
      -- Nome do arquivo a ser gerado
      vr_nmarqdat := vr_dtultdma_util_yymmdd||'_'||lpad(rw_crapcop.cdcooper,2,'0')||'_cessao.txt';
      
      --> Buscar diretorio de copia
      gene0001.pc_param_sistema(pr_nmsistem => 'CRED', 
                                pr_cdcooper => rw_crapcop.cdcooper, 
                                pr_cdacesso => 'DIR_ARQ_CONTAB_X', 
                                pr_dsvlrprm => vr_dircopia);
      
      
      gene0002.pc_solicita_relato_arquivo(pr_cdcooper  => rw_crapcop.cdcooper, 
                                          pr_cdprogra  => 'CRPS715', 
                                          pr_dtmvtolt  => rw_crapdat.dtmvtolt, 
                                          pr_dsxml     => vr_desclob, 
                                          pr_dsarqsaid => vr_nmdireto||'/'||vr_nmarqdat, 
                                          pr_cdrelato  => 0, 
                                          pr_dspathcop => vr_dircopia,
                                          pr_fldoscop  => 'S',  
                                          pr_flg_gerar => 'S',
                                          pr_des_erro  => vr_dscritic);
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      IF dbms_lob.isopen(vr_desclob) <> 1 THEN
        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_desclob);        
      END IF;
      
      dbms_lob.freetemporary(vr_desclob);
      
      IF dbms_lob.isopen(vr_desclob_rev) <> 0 THEN
        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_desclob_rev);      
      END IF;
      dbms_lob.freetemporary(vr_desclob_rev);  

      
      -- Log de fim da execução
      pc_controla_log_batch(pr_cdcooper => rw_crapcop.cdcooper,
                            pr_dstiplog =>'F');

      -- Salvar informações atualizadas
      COMMIT;
      
      
    EXCEPTION
    
      WHEN vr_exc_erro THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pc_controla_log_batch(pr_cdcooper => rw_crapcop.cdcooper,
                              pr_dstiplog => 'E',
                              pr_dscritic => vr_dscritic);
      
        vr_dscritic := NULL;  
        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_desclob);
        dbms_lob.freetemporary(vr_desclob);
        dbms_lob.close(vr_desclob_rev);
        dbms_lob.freetemporary(vr_desclob_rev);
                          
      
      WHEN OTHERS THEN
        vr_dscritic := 'Nao foi possivel gerar arquivo contabil: '||SQLERRM;
        pc_controla_log_batch(pr_cdcooper => rw_crapcop.cdcooper,
                              pr_dstiplog => 'E',
                              pr_dscritic => vr_dscritic);
        vr_dscritic := NULL;    
        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_desclob);
        dbms_lob.freetemporary(vr_desclob);   
        dbms_lob.close(vr_desclob_rev);
        dbms_lob.freetemporary(vr_desclob_rev);               
       
    END;
  END LOOP;  

  ----------------- ENCERRAMENTO DO PROGRAMA -------------------

  

EXCEPTION
  WHEN vr_exc_saida THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;

    pc_controla_log_batch('E', vr_dscritic);
    
    -- Efetuar rollback
    ROLLBACK;
  WHEN OTHERS THEN
    -- Efetuar retorno do erro não tratado
    vr_dscritic := sqlerrm;

    -- Envio centralizado de log de erro
    vr_flgerlog := TRUE;
    pc_controla_log_batch('E', vr_dscritic);
    -- Efetuar rollback
    ROLLBACK;

END pc_crps715;
/
