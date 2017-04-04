CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS713(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Codigo Cooperativa
                                       ,pr_flgresta IN PLS_INTEGER             --> Flag padrão para utilização de restart
                                       ,pr_nmtelant IN VARCHAR2                --> Nome tela anterior
                                       ,pr_stprogra OUT PLS_INTEGER            --> Saida de termino da execucao
                                       ,pr_infimsol OUT PLS_INTEGER            --> Saida de termino da solicitacao
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Codigo da Critica
                                       ,pr_dscritic OUT VARCHAR2) IS           --> Descricao da Critica

  /* .............................................................................

   Programa: PC_CRPS713                      Antigo: 
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Renato Darosci
   Data    : Março/2017                   Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : processar os arquivos de devolução da ABBC.

   Alteracoes: 
 
  .............................................................................*/

  -- Selecionar os dados da Cooperativa
  CURSOR cr_crapcop (pr_cdcooper IN craptab.cdcooper%TYPE) IS
    SELECT cop.cdcooper
          ,cop.nmrescop
          ,cop.nrtelura
          ,cop.cdbcoctl
          ,cop.cdagectl
          ,cop.dsdircop
          ,cop.nrctactl
          ,cop.cdagedbb
          ,cop.cdageitg
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  -- Selecionar as informações na tabela gncpdvc
  CURSOR cr_gncpdvc(pr_dtmvtolt   gncpdvc.dtmvtolt%TYPE
                   ,pr_dscodbar   gncpdvc.dscodbar%TYPE) IS
    SELECT dvc.rowid dsrowid
         , dvc.*
      FROM gncpdvc dvc
     WHERE dvc.dtmvtolt = pr_dtmvtolt
       AND dvc.dscodbar = pr_dscodbar
       AND dvc.flgconci = 0;
  rw_gncpdvc     cr_gncpdvc%ROWTYPE;
 
  -- Registro do tipo calendario
  rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
  
  --Tabela para receber arquivos lidos no unix
  vr_tab_nmarqtel    GENE0002.typ_split;
  
  --Constantes
  vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS713';
  
  --Variaveis Locais
  vr_comando         VARCHAR2(1000);
  vr_typ_saida       VARCHAR2(1000);
  vr_flgbatch        INTEGER;
  vr_contador        INTEGER;
  vr_nmarquiv        VARCHAR2(100) := '29999%.DVS';
  vr_dtleiarq        VARCHAR2(10);
  vr_dstipcob        VARCHAR2(6);
  vr_dtleiaux        VARCHAR2(8);
  vr_setlinha        VARCHAR2(1000);
  vr_caminho_puro    VARCHAR2(1000);
  vr_caminho_integra VARCHAR2(1000);
  vr_caminho_salvar  VARCHAR2(1000);
  vr_listadir        VARCHAR2(4000);
  
  --Variaveis para retorno de erro
  vr_cdcritic     INTEGER := 0;
  vr_dscritic     VARCHAR2(4000);
  
  -- Variaveis de Excecao
  vr_exc_saida     EXCEPTION;
  vr_exc_fimprg    EXCEPTION;

  --Variaveis de Arquivo
  vr_input_file  utl_file.file_type;

  --Gerar Relatorio 574_2
  PROCEDURE pc_gera_relatorio_574_2(pr_cdcooper  IN crapdat.cdcooper%TYPE
                                   ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE
                                   ,pr_cdcritic OUT INTEGER
                                   ,pr_dscritic OUT VARCHAR2) IS
       
    ---------> CURSORES <---------
    --> Listar devoluoes da coop
    CURSOR cr_devolucao (pr_dtmvtolt crapdat.dtmvtolt%TYPE )IS
      SELECT cop.nmrescop
           , COUNT(dvc.cdcooper)       qtdevolu
           , NVL(SUM(dvc.vlliquid),0)  vldevolu
        FROM gncpdvc dvc
           , crapcop cop
       WHERE cop.cdcooper    = dvc.cdcooper(+)
         AND dvc.dtmvtolt(+) = pr_dtmvtolt 
         AND cop.flgativo    = 1
       GROUP BY cop.cdcooper,cop.nmrescop
       ORDER BY cop.cdcooper;
              
    ---------> VARIAVEIS <----------
    vr_nmarqimp        VARCHAR2(20);
    vr_des_xml         CLOB;
    vr_dstexto         VARCHAR2(32700);
    vr_caminho_rl      VARCHAR2(100);
       
    vr_tot_qtdevolu    NUMBER := 0;
    vr_tot_vldevolu    NUMBER := 0;
    
  BEGIN
       
    -- Nome do arquivo
    vr_nmarqimp := 'crrl574_2.lst';

    -- Inicializar o CLOB
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

    vr_dstexto:= NULL;
    
    -- Inicilizar as informacoes do XML
    gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<?xml version="1.0" encoding="utf-8"?><crrl574_2><dados dtmvtolt="'||to_char(rw_crapdat.dtmvtolt,'DD/MM/YYYY')||'">');
       
    --> Listar devoluoes da coop
    FOR rw_devolucao IN cr_devolucao(pr_dtmvtolt => pr_dtmvtolt) LOOP
  
      -- Escrever no Arquivo XML
      gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,
        '<dado> '||
             '<nmrescop>'|| rw_devolucao.nmrescop ||'</nmrescop>'||
             '<qtdevolu>'|| to_char(rw_devolucao.qtdevolu,'FM999G990') ||'</qtdevolu>'||
             '<vldevolu>'|| to_char(rw_devolucao.vldevolu,'FM999G999G999G990D00')  ||'</vldevolu>'||
        '</dado>');
      
      -- Totalizadores
      vr_tot_qtdevolu := vr_tot_qtdevolu + NVL(rw_devolucao.qtdevolu,0);
      vr_tot_vldevolu := vr_tot_vldevolu + NVL(rw_devolucao.vldevolu,0);
         
    END LOOP;
    
    -- Finalizar tag de dados e inicializar a de totalizadores
    gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</dados><total>',true);
    
    -- Escrever no Arquivo XML
    gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,
             '<qt_totdevolu>'|| to_char(vr_tot_qtdevolu,'FM999G990')  ||'</qt_totdevolu>'||
             '<vl_totdevolu>'|| to_char(vr_tot_vldevolu,'FM999G999G999G990D00')  ||'</vl_totdevolu>');

    -- Finalizar o XML
    gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</total></crrl574_2>',true);

    -- Busca o diretorio da cooperativa conectada
    vr_caminho_rl := gene0001.fn_diretorio(pr_tpdireto => 'C' --> usr/coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => 'rl');
    
    -- Efetuar solicitacao de geracao de relatorio crrl574 --
    gene0002.pc_solicita_relato (pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                ,pr_dtmvtolt  => pr_dtmvtolt         --> Data do movimento atual
                                ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                ,pr_dsxmlnode => '/crrl574_2/dados/dado' --> Nó base do XML para leitura dos dados
                                ,pr_dsjasper  => 'crrl574_2.jasper'  --> Arquivo de layout do iReport
                                ,pr_dsparams  => NULL                --> Titulo do relatório
                                ,pr_dsarqsaid => vr_caminho_rl||'/'||vr_nmarqimp --> Arquivo final
                                ,pr_qtcoluna  => 80                  --> 132 colunas
                                --,pr_sqcabrel  => 2                   --> Sequencia do Relatorio {includes/cabrel132_2.i}
                                ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                ,pr_nmformul  => NULL                --> Nome do formulário para impressão
                                ,pr_nrcopias  => 1                   --> Número de cópias
                                ,pr_flg_gerar => 'S'                 --> gerar PDF
                                --,pr_dspathcop => vr_caminho_rlnsv    --> Lista sep. por ';' de diretórios a copiar o relatório
                                ,pr_des_erro  => vr_dscritic);       --> Sa?da com erro
    -- Testar se houve erro
    IF vr_dscritic IS NOT NULL THEN
      -- Gerar excecao
      RAISE vr_exc_saida;
    END IF;
 
    -- Liberando a memoria alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);
        
  EXCEPTION
    --> apenas repassar as criticas
    WHEN vr_exc_saida THEN
      pr_dscritic := vr_dscritic;
      pr_cdcritic := vr_cdcritic;
    WHEN OTHERS THEN
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na rotina pc_CRPS538.pc_gera_relatorio_574. '||sqlerrm;
  END pc_gera_relatorio_574_2;

---------------------------------------
-- Inicio Bloco Principal PC_CRPS713
---------------------------------------
BEGIN

  -- Limpar parametros saida
  pr_cdcritic:= NULL;
  pr_dscritic:= NULL;

  -- Incluir nome do modulo logado
  GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                            ,pr_action => NULL);

  -- Verifica se a cooperativa esta cadastrada
  OPEN  cr_crapcop(pr_cdcooper => pr_cdcooper);
  FETCH cr_crapcop INTO rw_crapcop;
  -- Se nao encontrar
  IF cr_crapcop%NOTFOUND THEN
    -- Fechar o cursor pois havera raise
    CLOSE cr_crapcop;
    -- Montar mensagem de critica
    vr_cdcritic:= 651;
    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    RAISE vr_exc_saida;
  ELSE
    -- Apenas fechar o cursor
    CLOSE cr_crapcop;
  END IF;

  -- Verifica se a data esta cadastrada
  OPEN  BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
  FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
  -- Se nao encontrar
  IF BTCH0001.cr_crapdat%NOTFOUND THEN
    -- Fechar o cursor pois havera raise
    CLOSE BTCH0001.cr_crapdat;
    -- Montar mensagem de critica
    vr_cdcritic:= 1;
    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    RAISE vr_exc_saida;
  ELSE
    -- Apenas fechar o cursor
    CLOSE BTCH0001.cr_crapdat;
  END IF;

  -- Validacoes iniciais do programa
  BTCH0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                            ,pr_flgbatch => vr_flgbatch
                            ,pr_cdprogra => vr_cdprogra
                            ,pr_infimsol => pr_infimsol
                            ,pr_cdcritic => vr_cdcritic);

  -- Se retornou critica aborta programa
  IF vr_cdcritic <> 0 THEN
    -- Descricao do erro recebe mensagam da critica
    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    -- Envio centralizado de log de erro
    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                              ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                  || vr_cdprogra || ' --> '
                                                  || vr_dscritic );
    --Sair do programa
    RAISE vr_exc_saida;
  END IF;

  -- Buscar Diretorio Integracao da Cooperativa
  vr_caminho_puro := gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => NULL);
  vr_caminho_integra := vr_caminho_puro||'/integra';

  -- Buscar o diretorio padrao da cooperativa conectada
  vr_caminho_salvar := vr_caminho_puro||'/salvar';

  -- Tratamento COMPEFORA
  IF pr_nmtelant = 'COMPEFORA' THEN
    -- Data leitura arquivo
    vr_dtleiarq:= to_char(rw_crapdat.dtmvtoan,'YYYYMMDD');
  ELSE
   -- Data leitura arquivo
   vr_dtleiarq:= to_char(rw_crapdat.dtmvtolt,'YYYYMMDD');
  END IF;

  -- Listar arquivos no diretorio
  gene0001.pc_lista_arquivos (pr_path     => vr_caminho_integra
                             ,pr_pesq     => vr_nmarquiv
                             ,pr_listarq  => vr_listadir
                             ,pr_des_erro => vr_dscritic);
    
  -- Se ocorreu erro
  IF vr_dscritic IS NOT NULL THEN
    -- Levantar Excecao
    RAISE vr_exc_saida;
  END IF;

  -- Montar vetor com nomes dos arquivos
  vr_tab_nmarqtel := GENE0002.fn_quebra_string(pr_string => vr_listadir);

  -- Se nao encontrou arquivos
  IF vr_tab_nmarqtel.COUNT <= 0 THEN
    -- Montar mensagem de critica
    vr_cdcritic:= 182;
    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      
    -- Envio centralizado de log de erro
    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                              ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                               || vr_cdprogra || ' --> '||vr_dscritic
                                               || ' - Arquivo: integra/'||vr_nmarquiv );
    -- Levantar Excecao pois nao tem arquivo para processar
    RAISE vr_exc_saida;
  END IF;
  /*  Fim da verificacao se deve executar  */

  -- Se for execução pela COMPEFORA, deve criticar caso seja encontrado 
  -- mais de um arquivo para processamento, de forma a evitar que um arquivo 
  -- normal e um REPROC sejam reprocessados juntos  ( Renato Darosci - Supero)
  IF pr_nmtelant = 'COMPEFORA' THEN
    -- Se encontrou mais de um arquivos
    IF vr_tab_nmarqtel.COUNT > 1 THEN
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Mais de um arquivo encontrado para processamento.';
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                  || vr_cdprogra || ' --> '||vr_dscritic
                                                  || ' - Arquivo: integra/'||vr_nmarquiv );
      --Levantar excecao pois nesse caso deveria ter apenas um arquivo para processar
      RAISE vr_exc_saida;
    END IF;
  END IF;
         
  --Percorrer todos os arquivos
  FOR idx IN 1..vr_tab_nmarqtel.COUNT LOOP

    /* Verificar o Header */
    -- Comando para listar a primeira linha do arquivo
    vr_comando:= 'head -1 ' ||vr_caminho_integra||'/'||vr_tab_nmarqtel(idx);

    -- Executar o comando no unix
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_comando
                         ,pr_typ_saida   => vr_typ_saida
                         ,pr_des_saida   => vr_setlinha);
    -- Se ocorreu erro dar RAISE
    IF vr_typ_saida = 'ERR' THEN
      vr_dscritic:= 'Não foi possivel executar comando unix. '||vr_comando;
      RAISE vr_exc_saida;
    END IF;

    -- Montar Tipo Cobranca
    vr_dstipcob := SUBSTR(vr_setlinha,48,6);
    -- Montar Data Arquivo
    vr_dtleiaux := SUBSTR(vr_setlinha,66,8);

    /* Verifica a primeira linha do arquivo importado */
    IF SUBSTR(vr_setlinha,1,10) <> '0000000000'  THEN -- Verifica se é uma linha de header
      vr_cdcritic:= 468;
    ELSIF vr_dstipcob <> 'DVC605' THEN   -- Verifica o tipo do arquivo
      vr_cdcritic:= 181;
    ELSIF vr_dtleiaux <> vr_dtleiarq THEN  -- Data do arquivo
      
      -- Em caso de divergencia na data, deve mover o arquivo como erro para a pasta salvar
      vr_comando := 'mv '||vr_caminho_integra||'/'||vr_tab_nmarqtel(idx)||' '||vr_caminho_salvar||'/ERR_'||vr_tab_nmarqtel(idx)||' 2> /dev/null';
        
      -- Executar o comando no unix para mover o arquivo para a pasta Salvar
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_comando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);

      -- Se ocorreu erro
      IF vr_typ_saida = 'ERR' THEN
        -- montar mensagem de erro
        vr_dscritic:= 'Erro no comando unix, executar manualmente: '||vr_comando;
        -- Gerar um log
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic );
        -- Limpar variável de erro
        vr_dscritic := NULL;
      END IF;
    
      vr_cdcritic:= 789;
    END IF;

    -- Se ocorreu algum erro na validacao
    IF vr_cdcritic <> 0 THEN
      -- Buscar descricao da critica
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        
      -- Envio centralizado de log de erro
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')                                       
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '||vr_dscritic
                                                 || ' - Arquivo: integra/'||vr_tab_nmarqtel(idx) );
      -- Zerar variavel critica
      vr_cdcritic:= 0;
        
      -- Ir para proximo arquivo
      CONTINUE;
    END IF;

    -- Escrever mensagem de integracao no log
    vr_cdcritic:= 219;
    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    -- Envio centralizado de log de erro
    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')                                     
                              ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                  || vr_cdprogra || ' --> '||vr_dscritic
                                                  || ' - Arquivo: integra/'||vr_tab_nmarqtel(idx) );
    -- Zerar variavel critica
    vr_cdcritic:= 0;

    -- Zerar o contador de linhas do arquivo
    vr_contador := 0;

    /* Nao ocorreu erro nas validacoes, abrir o arquivo e processar as linhas */

    -- Abrir o arquivo de dados
    gene0001.pc_abre_arquivo(pr_nmdireto => vr_caminho_integra  --> Diretorio do arquivo
                            ,pr_nmarquiv => vr_tab_nmarqtel(idx) --> Nome do arquivo
                            ,pr_tipabert => 'R'            --> Modo de abertura (R,W,A)
                            ,pr_utlfileh => vr_input_file  --> Handle do arquivo aberto
                            ,pr_des_erro => vr_dscritic);  --> Erro
    IF vr_dscritic IS NOT NULL THEN
      -- Levantar Excecao
      RAISE vr_exc_saida;
    ELSE
      BEGIN
        -- Ler a primeira linha. A mesma deve ser ignorada
        gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                    ,pr_des_text => vr_setlinha); --> Texto lido
                                           
        -- Incrementa a quantidade de linhas
        vr_contador := vr_contador + 1;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          -- Chegou ao final arquivo, sair do loop
          EXIT;
        WHEN OTHERS THEN
          vr_dscritic:= 'Erro na leitura do arquivo. '||sqlerrm;
          RAISE vr_exc_saida;
      END;
    END IF;

    -- Percorrer todas as linhas do arquivo
    LOOP
      BEGIN
        -- Le os dados do arquivo e coloca na variavel vr_setlinha
        gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                    ,pr_des_text => vr_setlinha); --> Texto lido
               
        -- Incrementa a quantidade de linhas
        vr_contador := vr_contador + 1;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          --Chegou ao final arquivo, sair do loop
          EXIT;
        WHEN OTHERS THEN
          vr_dscritic:= 'Erro na leitura do arquivo. '||sqlerrm;
          RAISE vr_exc_saida;
      END;
             
      /* Trailer - Se encontrar essa seq., terminou o arquivo */
      IF SUBSTR(vr_setlinha,1,10) = '9999999999' THEN
        EXIT;
      END IF;
       
      -- Localizar cada registro lido na tabela gncpdvc 
      OPEN  cr_gncpdvc(rw_crapdat.dtmvtolt
                      ,SUBSTR(vr_setlinha,1,44) ); -- Código de barras
      FETCH cr_gncpdvc INTO rw_gncpdvc;
        
      -- Se encontrar o registro
      IF cr_gncpdvc%FOUND THEN
        -- Atualizar os campos da tabela
        BEGIN
          UPDATE gncpdvc t
             SET t.nmarquiv = vr_tab_nmarqtel(idx)
               , t.flgconci = 1
               , t.dslinarq = vr_setlinha
           WHERE ROWID = rw_gncpdvc.dsrowid;
        EXCEPTION 
          WHEN OTHERS THEN
            vr_dscritic:= 'Erro ao atualizar GNCPDVC: '||sqlerrm;
            RAISE vr_exc_saida;
        END;
      ELSE 
        -- Se o registro não for encontrado, gerar log
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> Devolução não encontrada'
                                                   || ' - Linha['||vr_contador||']: '||vr_setlinha );
          
      END IF; -- IF cr_gncpdvc%FOUND 
 
      -- Fechar o Cursor
      CLOSE cr_gncpdvc;

    END LOOP; --Fim Linhas Arquivo
       
    -- Fechar o arquivo lido
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
      
    -- Montar comando de Move
    vr_comando := 'mv '||vr_caminho_integra||'/'||vr_tab_nmarqtel(idx)||' '||vr_caminho_salvar||' 2> /dev/null';
      
    -- Executar o comando no unix para mover o arquivo para a pasta Salvar
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_comando
                         ,pr_typ_saida   => vr_typ_saida
                         ,pr_des_saida   => vr_dscritic);

    -- Se ocorreu erro
    IF vr_typ_saida = 'ERR' THEN
      -- montar mensagem de erro
      vr_dscritic:= 'Erro no comando unix, executar manualmente: '||vr_comando;
      -- Gerar um log
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic );
      -- Limpar variável de erro
      vr_dscritic := NULL;
    END IF;
    
    -- Escrever mensagem de integracao no log
    vr_cdcritic:= 190;
    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    -- Envio centralizado de log de erro
    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')                                     
                              ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                  || vr_cdprogra || ' --> '||vr_dscritic
                                                  || ' - Arquivo: integra/'||vr_tab_nmarqtel(idx) );
    -- Zerar variavel critica
    vr_cdcritic:= 0;
    
  END LOOP;  -- Fim do loop de arquivos
    
  -- Gerar o relatório com as informações 
  pc_gera_relatorio_574_2(pr_cdcooper => pr_cdcooper
                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);
  
  -- Se ocorreu erro
  IF vr_dscritic IS NOT NULL THEN
    -- Levantar Excecao
    RAISE vr_exc_saida;
  END IF;
         
  -- Processo OK, devemos chamar a fimprg
  btch0001.pc_valida_fimprg (pr_cdcooper => pr_cdcooper
                            ,pr_cdprogra => vr_cdprogra
                            ,pr_infimsol => pr_infimsol
                            ,pr_stprogra => pr_stprogra);

  --Salvar informacoes no banco de dados
  COMMIT;

EXCEPTION
  WHEN vr_exc_fimprg THEN
    -- Se foi retornado apenas codigo
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descricao da critica
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Se foi gerada critica para envio ao log
    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                  || vr_cdprogra || ' --> '
                                                  || vr_dscritic );
    END IF;
    -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);
    -- Limpar parametros
    pr_cdcritic:= 0;
    pr_dscritic:= NULL;
    -- Efetuar commit pois gravaremos o que foi processado ate entao
    COMMIT;

  WHEN vr_exc_saida THEN
    -- Se foi retornado apenas codigo
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descricao
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Devolvemos codigo e critica encontradas
    pr_cdcritic := NVL(vr_cdcritic,0);
    pr_dscritic := vr_dscritic;
    -- Efetuar rollback
    ROLLBACK;
  WHEN OTHERS THEN
    -- Efetuar retorno do erro nao tratado
    pr_cdcritic := 0;
    pr_dscritic := sqlerrm;
    -- Efetuar rollback
    ROLLBACK;
END PC_CRPS713;
/
