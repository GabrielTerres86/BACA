CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS588(pr_cdcooper  IN NUMBER         --> Código da cooperativa
                                      ,pr_flgresta  IN PLS_INTEGER    --> Indicador para utilização de restart
                                      ,pr_stprogra  OUT PLS_INTEGER   --> Saída de termino da execução
                                      ,pr_infimsol  OUT PLS_INTEGER   --> Saída de termino da solicitação
                                      ,pr_cdcritic  OUT NUMBER        --> Código crítica
                                      ,pr_dscritic  OUT VARCHAR2) IS  --> Descrição crítica
/*..............................................................................

   Programa: PC_CRPS588       (Antigo fontes/crps588.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Janeiro/2011                       Ultima atualizacao: 02/01/2018

   Dados referentes ao programa:
   Frequencia: Diario.
   Objetivo  : Gerar arquivos CUS605 - Custodia de Cheques imagem p/ ABBC
                                       Tambem consisera Desconto de Cheque

   Alteracoes: 23/02/2011 - Tratamento para cheques do BB - Grupo Setec
                            (Guilherme/Ze).

               03/03/2011 - Tratamento para DV e D+2 (Ze).

               10/03/2011 - Ajuste no trailer dos arquivos gerados (Ze).

               19/04/2011 - Possibilitar a geracao dos arquivos mais de uma vez
                            ao dia (Ze).

               13/05/2011 - Retirar a data 24/01/11 - Data Mutirao (Ze).

               26/05/2011 - Selecionar somente os cheques com a data de
                            liberacao maior que a data atual (Ze).

               31/05/2011 - Selecionando somente os cheques para os proximos
                            7 dias (Ze).

               16/06/2011 - Acerto para incluir no arquivo C*.002 os cheques
                            com data de liberacao nos finais de semana e feriado
                            (Elton).

               20/06/2011 - Alterado data de vencimento dos cheques de final
                            de semana e feriado para o proximo dia util, no
                            arquivo C*.002 (Elton).

               29/12/2011 - Consistir para que o C*.002 nao gere inf. com
                            cheques com lib. para o ultimo dia util do ano (Ze).

               23/10/2012 - Tratamento para tipificacao de conta - CEL604 (Ze).

               30/12/2013 - Incluido First no Find da tabela crapage (Elton).

               01/04/2013 - Conversão Progress >> PLSQL (Petter-Supero)

               03/01/2014 - Trocar critica 15 Agencia nao cadastrada por
                            962 PA nao cadastrado (Reinert)

               15/01/2014 - Aplicar correções do mês de janeiro (Petter-Supero)

               08/01/2015 - Ajustar calculo de proximo dia util, estava ignorando
                           os liberados no dia 01/01 SD239720 (Odirlei-AMcom)

               06/06/2016 - Adicionado campo de codigo identificador no layout do BB
                            nos arquivos C*.001 e C*.002 (Douglas - Chamado 445731)

               04/11/2016 - Ajustado cursor para enviar cheques custodiados, somente
                            os que não foram descontados (nrborder = 0) 
                            (Projeto 300 - Rafael)

               23/01/2017 - Realizado merge com PROD ref ao projeto 300 (Rafael)

               24/11/2017 - Retirado (nrborder = 0) e feita validacao para verificar
                            se o cheque esta em bordero de desconto efetivado
                            antes de prosseguir com a custodia(Tiago/Adriano #766582)

               02/01/2018 - Foi ajustado a função do cálculo do dia útil (fn_calc_prox_dia_útil) 
                            para gerar os arquivos de compensação para a ABBC referente aos cheques 
                            que compensam nos dias 29/12, 30/12, 31/12 e 01/01/18. 
                            Esse fato está ocorrendo sempre no último dia do ano.
                            (Douglas - Chamado 822733)
..............................................................................*/
BEGIN
  DECLARE
    /* Definição das PL Tables*/
    -- Definição do tipo da PL Table para a tabela CRAPAGE
    TYPE typ_reg_crapage IS RECORD(cdcomchq crapage.cdcomchq%TYPE);
    TYPE typ_tab_crapage IS TABLE OF typ_reg_crapage INDEX BY VARCHAR2(5);

    -- Definição do tipo da PL Table para a tabela CRAPFER
    TYPE typ_reg_crapfer IS
      RECORD(registro PLS_INTEGER);
    TYPE typ_tab_crapfer IS TABLE OF typ_reg_crapfer INDEX BY VARCHAR2(11);


    /* Definição das variáveis*/
    vr_totvalor    NUMBER(20,2);                 --> Total de valor 1
    vr_totvalo2    NUMBER(20,2);                 --> Total de valor 2
    vr_mes         VARCHAR2(50);                 --> Nome do mês
    vr_nrseqarq    PLS_INTEGER;                  --> Sequencia de arquivo 1
    vr_nrseqar2    PLS_INTEGER;                  --> Sequencia de arquivo 2
    vr_nmarqdat    VARCHAR2(100);                --> Nome do arquivo 1
    vr_nmarqda2    VARCHAR2(100);                --> Nome do arquivo 2
    vr_ctrproce    VARCHAR2(50);                 --> Controle de processo
    vr_nmarqlog    VARCHAR2(40 );                --> Nome arquivo log
    vr_dirlog      VARCHAR2(400);                --> Diretório do arquivo de log
    vr_nrdigdv1    VARCHAR2(50);                 --> Dígito 1
    vr_nrdigdv2    VARCHAR2(50);                 --> Dígito 2
    vr_nrdigdv3    VARCHAR2(50);                 --> Dígito 3
    vr_nrctachq    NUMBER(20,2);                 --> Número conta cheque
    vr_dtlimite    DATE;                         --> Data de limite
    vr_dtlibera    DATE;                         --> Data de liberação
    vr_dtultdia    DATE;                         --> Data do ultimo dia
    vr_vlchqmai    NUMBER(20,2);                 --> Valor de cheque
    vr_exc_erro    EXCEPTION;                    --> Controle de exceção personalizado
    vr_cdprogra    VARCHAR2(30);                 --> Nome do programa
    rw_crapdat     btch0001.cr_crapdat%ROWTYPE;  --> Cursor para datas
    vr_tab_crapage typ_tab_crapage;              --> PL Table de valores da tabela CRAPAGE
    vr_tab_crapfer typ_tab_crapfer;              --> PL Table de valores da tabela CRAPFER
    vr_buffer_1    VARCHAR2(32767);              --> Buffer para gravação do XML 1
    vr_buffer_2    VARCHAR2(32767);              --> Buffer para gravação do XML 2
    vr_clob_1      CLOB;                         --> CLOB do arquivo 1
    vr_clob_2      CLOB;                         --> CLOB do arquivo 1
    vr_arqlog      utl_file.file_type;           --> Handle para arquivo de LOG
    vr_ret_log     BOOLEAN;                      --> Controle de gravação de LOG de processo

    /* Definição dos cursores */
    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS   --> Código da cooperativa
      SELECT cop.nmrescop
            ,cop.nrtelura
            ,cop.dsdircop
            ,cop.cdagectl
            ,cop.cdcooper
            ,cop.cdbcoctl
            ,cop.nrdivctl
      FROM crapcop cop
      WHERE cop.cdcooper = pr_cdcooper
        OR cop.cdcooper <> DECODE(pr_cdcooper, NULL, 3);
    rw_crapcop cr_crapcop%ROWTYPE;

    -- Busca dados de taxas
    CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE        --> Código cooperativa
                     ,pr_nmsistem IN craptab.nmsistem%TYPE        --> Nome sistema
                     ,pr_tptabela IN craptab.tptabela%TYPE        --> Tipo tabela
                     ,pr_cdempres IN craptab.cdempres%TYPE        --> código empresa
                     ,pr_cdacesso IN craptab.cdacesso%TYPE        --> Código acesso
                     ,pr_tpregist IN craptab.tpregist%TYPE) IS    --> Tipo de registro
      SELECT cb.dstextab
      FROM craptab cb
      WHERE cb.cdcooper = pr_cdcooper
        AND cb.nmsistem = pr_nmsistem
        AND cb.tptabela = pr_tptabela
        AND cb.cdempres = pr_cdempres
        AND cb.cdacesso = pr_cdacesso
        AND cb.tpregist = pr_tpregist;
    rw_craptab cr_craptab%rowtype;

    -- Busca dados das agências
    CURSOR cr_crapage IS
      SELECT cg.cdcomchq
            ,cg.cdcooper
      FROM crapage cg
      WHERE cg.flgdsede = 1;

    -- Buscar dados da custódia de cheques
    CURSOR cr_crapcst(pr_cdcooper IN crapcst.cdcooper%TYPE      --> código da cooperativa
                     ,pr_dtmvtolt IN crapcst.dtlibera%TYPE      --> Data do movimento
                     ,pr_dtlimite IN crapcst.dtlibera%TYPE) IS  --> Data do limite de movimento
      SELECT ct.inchqcop
            ,ct.cdbanchq
            ,ct.nrctachq
            ,ct.dsdocmc7
            ,ct.insitprv
            ,ct.vlcheque
            ,ct.cdcmpchq
            ,ct.cdagechq
            ,ct.nrdconta
            ,ct.dtlibera
            ,ct.nrcheque
            ,ct.cdcooper
            ,ct.nrborder
      FROM crapcst ct
      WHERE ct.dtlibera  > pr_dtmvtolt
        AND ct.dtlibera <= pr_dtlimite
        AND (ct.insitchq  = 0 OR ct.insitchq  = 2)
        AND ct.insitprv <= 3
        AND ct.cdcooper = pr_cdcooper;
    
    CURSOR cr_cdbcst(pr_cdcooper  IN crapcdb.cdcooper%TYPE
                    ,pr_nrdconta  IN crapcdb.nrdconta%TYPE
                    ,pr_dtlibera  IN crapcdb.dtlibera%TYPE
                    ,pr_cdcmpchq  IN crapcdb.cdcmpchq%TYPE
                    ,pr_cdbanchq  IN crapcdb.cdbanchq%TYPE
                    ,pr_cdagechq  IN crapcdb.cdagechq%TYPE
                    ,pr_nrctachq  IN crapcdb.nrctachq%TYPE
                    ,pr_nrcheque  IN crapcdb.nrcheque%TYPE
                    ,pr_nrborder  IN crapcdb.nrborder%TYPE) IS
      SELECT 1 
        FROM crapcdb
       WHERE crapcdb.cdcooper = pr_cdcooper
         AND crapcdb.nrdconta = pr_nrdconta
         AND crapcdb.dtlibera = pr_dtlibera
         AND crapcdb.dtlibbdc IS NOT NULL
         AND crapcdb.cdcmpchq = pr_cdcmpchq
         AND crapcdb.cdbanchq = pr_cdbanchq
         AND crapcdb.cdagechq = pr_cdagechq
         AND crapcdb.nrctachq = pr_nrctachq
         AND crapcdb.nrcheque = pr_nrcheque
         AND crapcdb.dtdevolu IS NULL
         AND crapcdb.nrborder = pr_nrborder;
    rw_cdbcst cr_cdbcst%ROWTYPE;   
        

    -- Buscar dados do bordero de desconto de cheques
    CURSOR cr_crapcdb(pr_cdcooper IN crapcdb.cdcooper%TYPE     --> Código da cooperativa
                     ,pr_dtmvtolt IN crapcst.dtlibera%TYPE      --> Data do movimento
                     ,pr_dtlimite IN crapcst.dtlibera%TYPE) IS  --> Data do limite de movimento
      SELECT cb.inchqcop
            ,cb.cdbanchq
            ,cb.dsdocmc7
            ,cb.nrctachq
            ,cb.insitprv
            ,cb.vlcheque
            ,cb.cdcmpchq
            ,cb.cdagechq
            ,cb.nrcheque
            ,cb.nrdconta
            ,cb.dtlibera
      FROM crapcdb cb
      WHERE cb.dtlibera  > pr_dtmvtolt
        AND cb.dtlibera <= pr_dtlimite
        AND (cb.insitchq  = 0 OR cb.insitchq  = 2)
        AND cb.dtlibbdc IS NOT NULL
        AND cb.insitprv <= 3
        AND cb.cdcooper = pr_cdcooper;

    -- Buscar dados dos feriados
    CURSOR cr_crapfer IS
      SELECT to_char(cf.dtferiad, 'DDMMRRRR') || LPAD(cf.cdcooper, 3, '0') idx
      FROM crapfer cf;


    /* Declaração de funções e procedures */
    /* Busca o próximo dia útil considerando a situação da ultima data corrente */
    FUNCTION fn_calc_prox_dia_util(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa
                                  ,pr_data     IN DATE                  --> Data para cálculo do próximo dia útil
                                  ,pr_datautl  IN DATE) RETURN DATE IS  --> Data para comparação da situação atual
    BEGIN
      DECLARE
        tmp_dtrefere   DATE := pr_data + 1;       --> Ultimo dia util antes de ontem

      BEGIN
        LOOP
          -- Verifica se a data selecionada é segunda-feira ou domingo
          IF to_char(tmp_dtrefere, 'D') = 7 OR to_char(tmp_dtrefere, 'D') = 1 THEN
            tmp_dtrefere := tmp_dtrefere + 1;
            continue;
          END IF;

          -- Verifica se a data existe na tabela de feriados
          IF vr_tab_crapfer.exists(to_char(tmp_dtrefere, 'DDMMRRRR') || lpad(pr_cdcooper, 3, '0')) THEN
            tmp_dtrefere := tmp_dtrefere + 1;
            continue;
          END IF;

          -- Compara datas de atuação
          IF tmp_dtrefere = pr_datautl THEN
            tmp_dtrefere := tmp_dtrefere + 1;
            -- Ajuste chamado 822733
            continue;
          END IF;

          -- Condição de saída do LOOP
          EXIT;
        END LOOP;

        RETURN tmp_dtrefere;
      END;
    END fn_calc_prox_dia_util;

    /* Função para gravar LOG operacional do processo */
    FUNCTION fn_grava_log(pr_nmdireto IN VARCHAR2                    --> Path do arquivo
                         ,pr_nmarquiv IN VARCHAR2                    --> Nome do arquivo
                         ,pr_linha    IN VARCHAR2) RETURN BOOLEAN IS --> Linha que será escrita no arquivo
    BEGIN
      DECLARE
        vr_desc_erro   VARCHAR2(4000);    --> Erros do processo
        vr_r_erro      EXCEPTION;         --> Controle de erros

      BEGIN
        -- Abrir arquivo em modo de adição
        gene0001.pc_abre_arquivo(pr_nmdireto => pr_nmdireto
                                ,pr_nmarquiv => pr_nmarquiv
                                ,pr_tipabert => 'A'
                                ,pr_utlfileh => vr_arqlog
                                ,pr_des_erro => vr_desc_erro);

        -- Verifica se ocorreram erros
        IF vr_desc_erro IS NOT NULL THEN
          RAISE vr_r_erro;
        END IF;

        -- Gravar linha no arquivo
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_arqlog
                                      ,pr_des_text => pr_linha);

        -- Fechar arquivo
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_arqlog);

        -- Finalizado com sucesso
        RETURN TRUE;
      EXCEPTION
        WHEN vr_r_erro THEN
          RETURN FALSE;
        WHEN OTHERS THEN
          RETURN FALSE;
      END;
    END fn_grava_log;

  BEGIN
    -- Atribuição de valores iniciais da procedure
    vr_cdprogra := 'CRPS588';

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra, pr_action => NULL);

    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;

    -- Se não encontrar registros montar mensagem de critica
    IF cr_crapcop%NOTFOUND THEN
      CLOSE cr_crapcop;

      pr_cdcritic := 651;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 651);
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapcop;
    END IF;

    -- Validações iniciais do programa
    btch0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                              ,pr_flgbatch => 1
                              ,pr_cdprogra => vr_cdprogra
                              ,pr_infimsol => pr_infimsol
                              ,pr_cdcritic => pr_cdcritic);

    -- Caso retorno crítica busca a descrição
    IF pr_cdcritic <> 0 THEN
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      RAISE vr_exc_erro;
    END IF;

    --Selecionar informacoes das datas
    OPEN btch0001.cr_crapdat (pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;

    -- Verifica o mês para gravar string de controle
    IF to_number(to_char(rw_crapdat.dtmvtolt, 'MM')) > 9 THEN
      CASE to_number(to_char(rw_crapdat.dtmvtolt, 'MM'))
        WHEN 10 THEN
          vr_mes := 'O';
        WHEN 11 THEN
          vr_mes := 'N';
        WHEN 12 THEN
          vr_mes := 'D';
      END CASE;
    ELSE
      vr_mes := to_number(to_char(rw_crapdat.dtmvtolt, 'MM'));
    END IF;

    -- Atribuir valores para as variáveis
    vr_dtlimite := rw_crapdat.dtmvtolt + 7;
    vr_nmarqlog := 'prcctl_' || to_char(rw_crapdat.dtmvtolt, 'RRRR') || to_char(rw_crapdat.dtmvtolt,'MM') || to_char(rw_crapdat.dtmvtolt,'DD') || '.log';
    vr_dirlog := gene0001.fn_diretorio(pr_tpdireto => 'C',pr_cdcooper => 3,pr_nmsubdir => '/log');
    vr_dtultdia := to_date('31/12/' || to_char(rw_crapdat.dtmvtolt, 'RRRR'), 'DD/MM/RRRR');

    -- Buscar dia útil
    vr_dtultdia := gene0005.fn_valida_dia_util(pr_cdcooper
                                              ,pr_dtmvtolt => vr_dtultdia
                                              ,pr_tipo     => 'A'
                                              ,pr_feriado  => FALSE);

    -- Buscar dados das taxas
    OPEN cr_craptab(pr_cdcooper, 'CRED', 'USUARI', 11, 'MAIORESCHQ', 1);
    FETCH cr_craptab INTO rw_craptab;

    -- Verifica se a tupla retornou resultados
    IF cr_craptab%NOTFOUND THEN
      vr_vlchqmai := 0;
    ELSE
      vr_vlchqmai := SUBSTR(rw_craptab.dstextab, 1, 15);
    END IF;

    -- Carregar PL Table para tabela CRPAGE
    FOR registro IN cr_crapage LOOP
      vr_tab_crapage(lpad(registro.cdcooper, 5, '0')).cdcomchq := registro.cdcomchq;
    END LOOP;

    -- Carregar PL Table para a tabela CRAPFER
    FOR registro IN cr_crapfer LOOP
      vr_tab_crapfer(registro.idx).registro := 1;
    END LOOP;

    -- Verificar registros no cadastro da cooperativa.
    -- C    - Fixo (Custodia e Dsc Chq)
    -- agen - Cod Agen Central crapcop.cdagectl
    -- M    - Mes Movim.(1-9 = Jan-Set) O=Out N=Nov D=Dez
    -- 001  - Carga Total ou 002  - Compe d + 2
    FOR registro IN cr_crapcop(NULL) LOOP
      -- Inicializar XML
      dbms_lob.createtemporary(vr_clob_1, TRUE);
      dbms_lob.open(vr_clob_1, dbms_lob.lob_readwrite);
      dbms_lob.createtemporary(vr_clob_2, TRUE);
      dbms_lob.open(vr_clob_2, dbms_lob.lob_readwrite);

      -- Atribuir valores para as variáveis
      vr_nrseqarq := 1;
      vr_nrseqar2 := 1;
      vr_nmarqdat := 'C' || lpad(registro.cdagectl, 4, '0') || vr_mes || to_char(rw_crapdat.dtmvtolt,'DD') || '.001';
      vr_nmarqda2 := 'C' || lpad(registro.cdagectl, 4, '0') || vr_mes || to_char(rw_crapdat.dtmvtolt,'DD') || '.002';

      -- Verificar se existem dados de agencia para a cooperativa
      IF NOT vr_tab_crapage.exists(lpad(registro.cdcooper, 5 , '0')) THEN
        vr_ret_log := fn_grava_log(pr_nmdireto => vr_dirlog
                                  ,pr_nmarquiv => vr_nmarqlog
                                  ,pr_linha    => to_char(SYSDATE,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> Coop: ' || registro.nmrescop ||
                                                  ' 962 - PA nao cadastrado.');

        -- Verificar se ocorreram erros
        IF vr_ret_log = FALSE THEN
          pr_dscritic := 'Erro ao gerar arquivo de LOG do processo.';
          RAISE vr_exc_erro;
        END IF;

        continue;
      END IF;

      -- Verifica se o arquivo existe
      IF gene0001.fn_exis_arquivo(pr_caminho => gene0001.fn_diretorio(pr_tpdireto => 'C',pr_cdcooper => registro.cdcooper,pr_nmsubdir => '/arq') || '/' || vr_nmarqdat) OR
         gene0001.fn_exis_arquivo(pr_caminho => gene0001.fn_diretorio(pr_tpdireto => 'M',pr_cdcooper => registro.cdcooper,pr_nmsubdir => '/abbc') || '/' || vr_nmarqdat) OR
         gene0001.fn_exis_arquivo(pr_caminho => gene0001.fn_diretorio(pr_tpdireto => 'C',pr_cdcooper => registro.cdcooper,pr_nmsubdir => '/arq') || '/' || vr_nmarqda2) OR
         gene0001.fn_exis_arquivo(pr_caminho => gene0001.fn_diretorio(pr_tpdireto => 'M',pr_cdcooper => registro.cdcooper,pr_nmsubdir => '/abbc') || '/' || vr_nmarqda2) THEN
        pr_cdcritic := 459;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);

        vr_ret_log := fn_grava_log(pr_nmdireto => vr_dirlog
                                  ,pr_nmarquiv => vr_nmarqlog
                                  ,pr_linha    => to_char(SYSDATE,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> '  || pr_dscritic || '. ' || vr_nmarqdat);

        -- Verificar se ocorreram erros
        IF vr_ret_log = FALSE THEN
          pr_dscritic := 'Erro ao gerar arquivo de LOG do processo.';
          RAISE vr_exc_erro;
        END IF;

        continue;
      END IF;

      -- Gerar cabeçalho do arquivo XML 1
      vr_buffer_1 := lpad('0', 47, '0')
                     || 'CUS605'
                     || lpad(vr_tab_crapage(lpad(registro.cdcooper, 5 , '0')).cdcomchq, 3, '0')
                     || '0001'
                     || lpad(registro.cdbcoctl, 3, '0')
                     || lpad(registro.nrdivctl, 1, '0')
                     || '2'
                     || to_char(rw_crapdat.dtmvtolt, 'RRRR')
                     || to_char(rw_crapdat.dtmvtolt, 'MM')
                     || to_char(rw_crapdat.dtmvtolt, 'DD')
                     || lpad(' ', 77, ' ')
                     || lpad(vr_nrseqarq, 10, '0') || chr(10);
      gene0002.pc_clob_buffer(pr_dados => vr_buffer_1, pr_gravfim => FALSE, pr_clob => vr_clob_1);

      -- Gerar cabeçalho do arquivo XML 2
      vr_buffer_2 := lpad('0', 47, '0')
                     || 'CUS605'
                     || lpad(vr_tab_crapage(lpad(registro.cdcooper, 5 , '0')).cdcomchq, 3, '0')
                     || '0001'
                     || lpad(registro.cdbcoctl, 3, '0')
                     || lpad(registro.nrdivctl, 1, '0')
                     || '2'
                     || to_char(rw_crapdat.dtmvtolt, 'RRRR')
                     || to_char(rw_crapdat.dtmvtolt, 'MM')
                     || to_char(rw_crapdat.dtmvtolt, 'DD')
                     || lpad(' ', 77, ' ')
                     || lpad(vr_nrseqar2, 10, '0') || chr(10);
      gene0002.pc_clob_buffer(pr_dados => vr_buffer_2, pr_gravfim => FALSE, pr_clob => vr_clob_2);

      -- Limpar variáveis
      vr_totvalor := 0;
      vr_totvalo2 := 0;
      vr_dtlibera := NULL;

      -- Iterado para coletar os registros da PL Table pelo índice formado
      FOR rw_crapcst IN cr_crapcst(registro.cdcooper, rw_crapdat.dtmvtolt, vr_dtlimite) LOOP
      
        IF rw_crapcst.nrborder <> 0 THEN
          /*Se estiver em um bordero de descto efetivado nao 
              considerar para a custodia*/
          OPEN cr_cdbcst(pr_cdcooper => rw_crapcst.cdcooper
                        ,pr_nrdconta => rw_crapcst.nrdconta
                        ,pr_dtlibera => rw_crapcst.dtlibera
                        ,pr_cdcmpchq => rw_crapcst.cdcmpchq
                        ,pr_cdbanchq => rw_crapcst.cdbanchq
                        ,pr_cdagechq => rw_crapcst.cdagechq
                        ,pr_nrctachq => rw_crapcst.nrctachq
                        ,pr_nrcheque => rw_crapcst.nrcheque
                        ,pr_nrborder => rw_crapcst.nrborder);
          FETCH cr_cdbcst INTO rw_cdbcst;
          
          IF cr_cdbcst%FOUND THEN
             CLOSE cr_cdbcst;
             CONTINUE;
          END IF;            
          
          CLOSE cr_cdbcst;        
        END IF;
      
        -- Verifica tipo do cheque
        IF rw_crapcst.inchqcop = 1 THEN
          vr_ctrproce := 'PG_CX';
        ELSE
          vr_ctrproce := '      ';
        END IF;

        -- tratamento para o grupo SETEC
        IF rw_crapcst.cdbanchq = 1 THEN
          vr_nrctachq := substr(rw_crapcst.dsdocmc7, 23, 10);
        ELSE
          vr_nrctachq := rw_crapcst.nrctachq;
        END IF;

        -- Atribuir valores para as variáveis
        vr_nrdigdv2 := substr(rw_crapcst.dsdocmc7, 9, 1);
        vr_nrdigdv1 := substr(rw_crapcst.dsdocmc7, 22, 1);
        vr_nrdigdv3 := substr(rw_crapcst.dsdocmc7, 33, 1);

        -- Validar situação
        IF rw_crapcst.insitprv <= 2 THEN
          -- Sumarizar valores
          vr_nrseqarq := vr_nrseqarq + 1;
          vr_totvalor := vr_totvalor + rw_crapcst.vlcheque;

          -- Gerar XML
          vr_buffer_1 := vr_buffer_1 || lpad(rw_crapcst.cdcmpchq, 3, '0')
                                     || lpad(rw_crapcst.cdbanchq, 3, '0')
                                     || lpad(rw_crapcst.cdagechq, 4, '0')
                                     || lpad(vr_nrdigdv2, 1, '0')
                                     || lpad(vr_nrctachq, 12, '0')
                                     || lpad(vr_nrdigdv1, 1, '0')
                                     || lpad(rw_crapcst.nrcheque, 6, '0')
                                     || lpad(vr_nrdigdv3, 1, '0')
                                     || '  '
                                     || lpad((rw_crapcst.vlcheque * 100), 17, '0')
                                     || substr(rw_crapcst.dsdocmc7, 20, 1)
                                     || '1100'
                                     || lpad(registro.cdbcoctl, 3, '0')
                                     || lpad(registro.cdagectl, 4, '0')
                                     || lpad(registro.cdagectl, 4, '0')
                                     || lpad(rw_crapcst.nrdconta, 12, '0')
                                     || lpad(vr_tab_crapage(lpad(registro.cdcooper, 5 , '0')).cdcomchq, 3, '0')
                                     || to_char(rw_crapcst.dtlibera, 'RRRR')
                                     || to_char(rw_crapcst.dtlibera, 'MM')
                                     || to_char(rw_crapcst.dtlibera, 'DD')
                                     || lpad('0', 10, '0')
                                     || rpad(vr_ctrproce, 6, ' ')
                                     -- Adicionado o CODIGO IDENTIFICADOR, sempre "1" preenchido com "0"
                                     || lpad('1', 25, '0')
                                     || lpad(' ', 17, ' ');

          IF rw_crapcst.vlcheque >= vr_vlchqmai THEN
            vr_buffer_1 := vr_buffer_1 || '030';
          ELSE
            vr_buffer_1 := vr_buffer_1 || '034';
          END IF;

          vr_buffer_1 := vr_buffer_1 || lpad(vr_nrseqarq, 10, '0') || chr(10);
          gene0002.pc_clob_buffer(pr_dados => vr_buffer_1, pr_gravfim => FALSE, pr_clob => vr_clob_1);
        END IF;

        -- Buscar próximo dia útil
        vr_dtlibera := fn_calc_prox_dia_util(pr_cdcooper => registro.cdcooper
                                            ,pr_data     => rw_crapcst.dtlibera - 1
                                            ,pr_datautl  => vr_dtultdia);

        -- Compara datas uteís para gerar XML 2
        IF vr_dtlibera = fn_calc_prox_dia_util(pr_cdcooper => registro.cdcooper
                                              ,pr_data     => rw_crapdat.dtmvtopr
                                              ,pr_datautl  => vr_dtultdia) THEN
          -- Sumarizar valores
          vr_nrseqar2 := vr_nrseqar2 + 1;
          vr_totvalo2 := vr_totvalo2 + rw_crapcst.vlcheque;

          -- Gerar XML
          vr_buffer_2 := vr_buffer_2 || lpad(rw_crapcst.cdcmpchq, 3, '0')
                                     || lpad(rw_crapcst.cdbanchq, 3, '0')
                                     || lpad(rw_crapcst.cdagechq, 4, '0')
                                     || lpad(vr_nrdigdv2, 1, '0')
                                     || lpad(vr_nrctachq, 12, '0')
                                     || lpad(vr_nrdigdv1, 1, '0')
                                     || lpad(rw_crapcst.nrcheque, 6, '0')
                                     || lpad(vr_nrdigdv3, 1, '0')
                                     || '  '
                                     || lpad((rw_crapcst.vlcheque * 100), 17, '0')
                                     || substr(rw_crapcst.dsdocmc7, 20, 1)
                                     || '1300'
                                     || lpad(registro.cdbcoctl, 3, '0')
                                     || lpad(registro.cdagectl, 4, '0')
                                     || lpad(registro.cdagectl, 4, '0')
                                     || lpad(rw_crapcst.nrdconta, 12, '0')
                                     || lpad(vr_tab_crapage(lpad(registro.cdcooper, 5 , '0')).cdcomchq, 3, '0')
                                     || to_char(vr_dtlibera, 'RRRR')
                                     || to_char(vr_dtlibera, 'MM')
                                     || to_char(vr_dtlibera, 'DD')
                                     || lpad('0', 10, '0')
                                     || rpad(vr_ctrproce, 6, ' ')
                                     -- Adicionado o CODIGO IDENTIFICADOR, sempre "1" preenchido com "0"
                                     || lpad('1', 25, '0')
                                     || lpad(' ', 17, ' ');

          IF rw_crapcst.vlcheque >= vr_vlchqmai THEN
            vr_buffer_2 := vr_buffer_2 || '030';
          ELSE
            vr_buffer_2 := vr_buffer_2 || '034';
          END IF;

          vr_buffer_2 := vr_buffer_2 || lpad(vr_nrseqar2, 10, '0') || chr(10);
          gene0002.pc_clob_buffer(pr_dados => vr_buffer_2, pr_gravfim => FALSE, pr_clob => vr_clob_2);
        END IF;
      END LOOP;

      -- Iterado para coletar os registros da PL Table pelo índice formado
      FOR rw_crapcdb IN cr_crapcdb(registro.cdcooper, rw_crapdat.dtmvtolt, vr_dtlimite) LOOP
        -- Verifica tipo do cheque
        IF rw_crapcdb.inchqcop = 1 THEN
          vr_ctrproce := 'PG_CX';
        ELSE
          vr_ctrproce := '      ';
        END IF;

        -- tratamento para o grupo SETEC
        IF rw_crapcdb.cdbanchq = 1 THEN
          vr_nrctachq := substr(rw_crapcdb.dsdocmc7, 23, 10);
        ELSE
          vr_nrctachq := rw_crapcdb.nrctachq;
        END IF;

        -- Atribuir valores para as variáveis
        vr_nrdigdv2 := substr(rw_crapcdb.dsdocmc7, 9, 1);
        vr_nrdigdv1 := substr(rw_crapcdb.dsdocmc7, 22, 1);
        vr_nrdigdv3 := substr(rw_crapcdb.dsdocmc7, 33, 1);

        -- Validar situação
        IF rw_crapcdb.insitprv <= 2 THEN
          -- Sumarizar valores
          vr_nrseqarq := vr_nrseqarq + 1;
          vr_totvalor := vr_totvalor + rw_crapcdb.vlcheque;

          -- Gerar XML
          vr_buffer_1 := vr_buffer_1 || lpad(rw_crapcdb.cdcmpchq, 3, '0')
                                     || lpad(rw_crapcdb.cdbanchq, 3, '0')
                                     || lpad(rw_crapcdb.cdagechq, 4, '0')
                                     || lpad(vr_nrdigdv2, 1, '0')
                                     || lpad(vr_nrctachq, 12, '0')
                                     || lpad(vr_nrdigdv1, 1, '0')
                                     || lpad(rw_crapcdb.nrcheque, 6, '0')
                                     || lpad(vr_nrdigdv3, 1, '0')
                                     || '  '
                                     || lpad((rw_crapcdb.vlcheque * 100), 17, '0')
                                     || substr(rw_crapcdb.dsdocmc7, 20, 1)
                                     || '1100'
                                     || lpad(registro.cdbcoctl, 3, '0')
                                     || lpad(registro.cdagectl, 4, '0')
                                     || lpad(registro.cdagectl, 4, '0')
                                     || lpad(rw_crapcdb.nrdconta, 12, '0')
                                     || lpad(vr_tab_crapage(lpad(registro.cdcooper, 5 , '0')).cdcomchq, 3, '0')
                                     || to_char(rw_crapcdb.dtlibera, 'RRRR')
                                     || to_char(rw_crapcdb.dtlibera, 'MM')
                                     || to_char(rw_crapcdb.dtlibera, 'DD')
                                     || lpad('0', 10, '0')
                                     || rpad(vr_ctrproce, 6, ' ')
                                     -- Adicionado o CODIGO IDENTIFICADOR, sempre "1" preenchido com "0"
                                     || lpad('1', 25, '0')
                                     || lpad(' ', 17, ' ');

          IF rw_crapcdb.vlcheque >= vr_vlchqmai THEN
            vr_buffer_1 := vr_buffer_1 || '030';
          ELSE
            vr_buffer_1 := vr_buffer_1 || '034';
          END IF;

          vr_buffer_1 := vr_buffer_1 || lpad(vr_nrseqarq, 10, '0') || chr(10);
          gene0002.pc_clob_buffer(pr_dados => vr_buffer_1, pr_gravfim => FALSE, pr_clob => vr_clob_1);
        END IF;

        -- Buscar próximo dia útil
        vr_dtlibera := fn_calc_prox_dia_util(pr_cdcooper => registro.cdcooper
                                            ,pr_data     => rw_crapcdb.dtlibera - 1
                                            ,pr_datautl  => vr_dtultdia);

        -- Compara datas uteís para gerar XML 2
        IF vr_dtlibera = fn_calc_prox_dia_util(pr_cdcooper => registro.cdcooper
                                              ,pr_data     => rw_crapdat.dtmvtopr
                                              ,pr_datautl  => vr_dtultdia) THEN

          -- Sumarizar valores
          vr_nrseqar2 := vr_nrseqar2 + 1;
          vr_totvalo2 := vr_totvalo2 + rw_crapcdb.vlcheque;

          -- Gerar XML
          vr_buffer_2 := vr_buffer_2 || lpad(rw_crapcdb.cdcmpchq, 3, '0')
                                     || lpad(rw_crapcdb.cdbanchq, 3, '0')
                                     || lpad(rw_crapcdb.cdagechq, 4, '0')
                                     || lpad(vr_nrdigdv2, 1, '0')
                                     || lpad(vr_nrctachq, 12, '0')
                                     || lpad(vr_nrdigdv1, 1, '0')
                                     || lpad(rw_crapcdb.nrcheque, 6, '0')
                                     || lpad(vr_nrdigdv3, 1, '0')
                                     || '  '
                                     || lpad((rw_crapcdb.vlcheque * 100), 17, '0')
                                     || substr(rw_crapcdb.dsdocmc7, 20, 1)
                                     || '1300'
                                     || lpad(registro.cdbcoctl, 3, '0')
                                     || lpad(registro.cdagectl, 4, '0')
                                     || lpad(registro.cdagectl, 4, '0')
                                     || lpad(rw_crapcdb.nrdconta, 12, '0')
                                     || lpad(vr_tab_crapage(lpad(registro.cdcooper, 5 , '0')).cdcomchq, 3, '0')
                                     || to_char(vr_dtlibera, 'RRRR')
                                     || to_char(vr_dtlibera, 'MM')
                                     || to_char(vr_dtlibera, 'DD')
                                     || lpad('0', 10, '0')
                                     || rpad(vr_ctrproce, 6, ' ')
                                     -- Adicionado o CODIGO IDENTIFICADOR, sempre "1" preenchido com "0"
                                     || lpad('1', 25, '0')
                                     || lpad(' ', 17, ' ');

          IF rw_crapcdb.vlcheque >= vr_vlchqmai THEN
            vr_buffer_2 := vr_buffer_2 || '030';
          ELSE
            vr_buffer_2 := vr_buffer_2 || '034';
          END IF;

          vr_buffer_2 := vr_buffer_2 || lpad(vr_nrseqar2, 10, '0') || chr(10);
          gene0002.pc_clob_buffer(pr_dados => vr_buffer_2, pr_gravfim => FALSE, pr_clob => vr_clob_2);
        END IF;
      END LOOP;

      -- Atribuir valores das variáveis
      vr_nrseqarq := vr_nrseqarq + 1;
      vr_nrseqar2 := vr_nrseqar2 + 1;

      -- Gerar registros final do XML 1
      vr_buffer_1 := vr_buffer_1 || lpad('9', 47, '99')
                                 || 'CUS605'
                                 || lpad(vr_tab_crapage(lpad(registro.cdcooper, 5 , '0')).cdcomchq, 3, '0')
                                 || '0001'
                                 || lpad(registro.cdbcoctl, 3, '0')
                                 || lpad(registro.nrdivctl, 1, '0')
                                 || '1'
                                 || to_char(rw_crapdat.dtmvtolt, 'RRRR')
                                 || to_char(rw_crapdat.dtmvtolt, 'MM')
                                 || to_char(rw_crapdat.dtmvtolt, 'DD')
                                 || lpad((vr_totvalor * 100), 17, '0')
                                 || lpad(' ', 60, ' ')
                                 || lpad(vr_nrseqarq, 10, '0') || chr(10);
      gene0002.pc_clob_buffer(pr_dados => vr_buffer_1, pr_gravfim => FALSE, pr_clob => vr_clob_1);

      -- Gerar registros final do XML 2
      vr_buffer_2 := vr_buffer_2 || lpad('9', 47, '99')
                                 || 'CUS605'
                                 || lpad(vr_tab_crapage(lpad(registro.cdcooper, 5 , '0')).cdcomchq, 3, '0')
                                 || '0001'
                                 || lpad(registro.cdbcoctl, 3, '0')
                                 || lpad(registro.nrdivctl, 1, '0')
                                 || '1'
                                 || to_char(rw_crapdat.dtmvtolt, 'RRRR')
                                 || to_char(rw_crapdat.dtmvtolt, 'MM')
                                 || to_char(rw_crapdat.dtmvtolt, 'DD')
                                 || lpad((vr_totvalo2 * 100), 17, '0')
                                 || lpad(' ', 60, ' ')
                                 || lpad(vr_nrseqar2, 10, '0') || chr(10);
      gene0002.pc_clob_buffer(pr_dados => vr_buffer_2, pr_gravfim => FALSE, pr_clob => vr_clob_2);

      -- Mensagens de finalização do processo e arquivo 1
      IF vr_nrseqarq <= 2 THEN
        vr_ret_log := fn_grava_log(pr_nmdireto => vr_dirlog
                                  ,pr_nmarquiv => vr_nmarqlog
                                  ,pr_linha    => to_char(SYSDATE,'hh24:mi:ss') || ' - Coop: ' || to_char(registro.cdcooper, 'FM00') ||
                                                  ' - Processar: Custodia/Desconto Chq a compensar - IMG. O arquivo' || vr_nmarqdat ||
                                                  ' estava sem registros e foi removido.');

        -- Verificar se ocorreram erros
        IF vr_ret_log = FALSE THEN
          pr_dscritic := 'Erro ao gerar arquivo de LOG do processo.';
          RAISE vr_exc_erro;
        END IF;

      ELSE
        -- Finalizar arquivo
        gene0002.pc_clob_buffer(pr_dados => vr_buffer_1, pr_gravfim => TRUE, pr_clob => vr_clob_1);
        -- Gravar na pasta arq
        gene0002.pc_clob_para_arquivo(pr_clob    => vr_clob_1
                                     ,pr_caminho => gene0001.fn_diretorio(pr_tpdireto => 'C',pr_cdcooper => registro.cdcooper,pr_nmsubdir => '/arq')
                                     ,pr_arquivo => vr_nmarqdat
                                     ,pr_des_erro => pr_dscritic);
        -- Se houve erro
        IF pr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- Convertê-lo para DOS na pasta micros
        gene0001.pc_OScommand_Shell('ux2dos ' || gene0001.fn_diretorio(pr_tpdireto => 'C',pr_cdcooper => registro.cdcooper,pr_nmsubdir => '/arq') ||'/'|| vr_nmarqdat  || ' | tr -d "\032" > '
                                  || gene0001.fn_diretorio(pr_tpdireto => 'M',pr_cdcooper => registro.cdcooper, pr_nmsubdir => '/abbc') || '/' || vr_nmarqdat
                                  || ' 2>/dev/null');
        -- Mover da pasta arq para a salvar
        gene0001.pc_OScommand_Shell('mv ' || gene0001.fn_diretorio(pr_tpdireto => 'C',pr_cdcooper => registro.cdcooper,pr_nmsubdir => '/arq') || '/' || vr_nmarqdat  || ' '
                                          || gene0001.fn_diretorio(pr_tpdireto => 'C',pr_cdcooper => registro.cdcooper,pr_nmsubdir => '/salvar') || '/' || vr_nmarqdat || '_'
                                          || gene0002.fn_busca_time|| ' 2>/dev/null');

        -- Gerar entrada no LOG
        vr_ret_log := fn_grava_log(pr_nmdireto => vr_dirlog
                                  ,pr_nmarquiv => vr_nmarqlog
                                  ,pr_linha    => to_char(SYSDATE,'hh24:mi:ss') || ' - Coop:' || to_char(registro.cdcooper, 'FM00') ||
                                                  ' - Processar: Custodia/Desconto Chq a compensar - IMG - Arquivo salvar/' || vr_nmarqdat ||
                                                  ' processado com sucesso !');

        -- Verificar se ocorreram erros
        IF vr_ret_log = FALSE THEN
          pr_dscritic := 'Erro ao gerar arquivo de LOG do processo.';
          RAISE vr_exc_erro;
        END IF;
      END IF;

      -- Mensagens de finalização do processo e arquivo 2
      IF vr_nrseqar2 <= 2 THEN
        -- Gerar entrada no LOG
        vr_ret_log := fn_grava_log(pr_nmdireto => vr_dirlog
                                  ,pr_nmarquiv => vr_nmarqlog
                                  ,pr_linha    => to_char(SYSDATE,'hh24:mi:ss') || ' - Coop:' || to_char(registro.cdcooper, 'FM00') ||
                                                  ' - Processar: Custodia/Desconto Chq a compensar - IMG. O arquivo' || vr_nmarqda2 ||
                                                  ' estava sem registros e foi removido.');

        -- Verificar se ocorreram erros
        IF vr_ret_log = FALSE THEN
          pr_dscritic := 'Erro ao gerar arquivo de LOG do processo.';
          RAISE vr_exc_erro;
        END IF;

      ELSE
        -- Finalizar arquivo
        gene0002.pc_clob_buffer(pr_dados => vr_buffer_2, pr_gravfim => TRUE, pr_clob => vr_clob_2);
        -- Gravar na pasta arq
        gene0002.pc_clob_para_arquivo(pr_clob     => vr_clob_2
                                     ,pr_caminho  => gene0001.fn_diretorio(pr_tpdireto => 'C',pr_cdcooper => registro.cdcooper,pr_nmsubdir => '/arq')
                                     ,pr_arquivo  => vr_nmarqda2
                                     ,pr_des_erro => pr_dscritic);
        -- Se houve erro
        IF pr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- Convertê-lo para DOS na pasta micros
        gene0001.pc_OScommand_Shell('ux2dos ' || gene0001.fn_diretorio(pr_tpdireto => 'C',pr_cdcooper => registro.cdcooper,pr_nmsubdir => '/arq') ||'/'|| vr_nmarqda2  || ' | tr -d "\032" > '
                                  || gene0001.fn_diretorio(pr_tpdireto => 'M',pr_cdcooper => registro.cdcooper, pr_nmsubdir => '/abbc') || '/' || vr_nmarqda2
                                  || ' 2>/dev/null');
        -- Mover da pasta arq para a salvar
        gene0001.pc_OScommand_Shell('mv ' || gene0001.fn_diretorio(pr_tpdireto => 'C',pr_cdcooper => registro.cdcooper,pr_nmsubdir => '/arq') || '/' || vr_nmarqda2  || ' '
                                          || gene0001.fn_diretorio(pr_tpdireto => 'C',pr_cdcooper => registro.cdcooper,pr_nmsubdir => '/salvar') || '/' || vr_nmarqda2 || '_'
                                          || gene0002.fn_busca_time|| ' 2>/dev/null');
        -- Gerar entrada no LOG
        vr_ret_log := fn_grava_log(pr_nmdireto => vr_dirlog
                                  ,pr_nmarquiv => vr_nmarqlog
                                  ,pr_linha    => to_char(SYSDATE,'hh24:mi:ss') || ' - Coop:' || to_char(registro.cdcooper, 'FM00') ||
                                                  ' - Processar: Custodia/Desconto Chq a compensar - IMG - Arquivo salvar/' || vr_nmarqda2 ||
                                                  ' processado com sucesso !');

        -- Verificar se ocorreram erros
        IF vr_ret_log = FALSE THEN
          pr_dscritic := 'Erro ao gerar arquivo de LOG do processo.';
          RAISE vr_exc_erro;
        END IF;
      END IF;

      -- Liberar dados do CLOB da memória
      dbms_lob.close(vr_clob_1);
      dbms_lob.freetemporary(vr_clob_1);
      dbms_lob.close(vr_clob_2);
      dbms_lob.freetemporary(vr_clob_2);
    END LOOP;

    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);
    COMMIT;

  EXCEPTION
  WHEN vr_exc_erro THEN
    -- Se foi retornado apenas código
    IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
      -- Buscar a descrição
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
    END IF;
    -- Efetuar rollback
    ROLLBACK;
  WHEN OTHERS THEN
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := sqlerrm;
    -- Efetuar rollback
    ROLLBACK;
  END;
END PC_CRPS588;
/
