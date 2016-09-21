CREATE OR REPLACE PACKAGE CECRED.TELA_IMPCAR AS

  PROCEDURE pc_busca_arquivos(pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2          --> Nome do Campo
                             ,pr_des_erro OUT VARCHAR2);        --> Saida OK/NOK

  PROCEDURE pc_importa_arquivos(pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2          --> Nome do Campo
                               ,pr_des_erro OUT VARCHAR2);        --> Saida OK/NOK

END TELA_IMPCAR;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_IMPCAR AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: TELA_IMPCAR
  --    Autor   : James Prust Júnior
  --    Data    : Marco/2016                   Ultima Atualizacao: 
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : BO ref. a Mensageria da tela IMPCAR
  --
  --    Alteracoes:                              
  --    
  ---------------------------------------------------------------------------------------------------------------
  FUNCTION fn_retorna_bandeira(pr_nmarquiv IN VARCHAR2) RETURN VARCHAR2 IS
    -- Buscar o nome da bandeira
    CURSOR cr_tbcrd_bandeira(pr_idbandeira IN tbcrd_bandeira.idbandeira%TYPE) IS
      SELECT nmbandeira
        FROM tbcrd_bandeira
       WHERE idbandeira = pr_idbandeira;

    -- Variaveis auxiliares
    vr_nmbandeira  tbcrd_bandeira.nmbandeira%TYPE := ' ';
    vr_cdbandeira  tbcrd_bandeira.Idbandeira%TYPE;
    
    -- Variaveis leitura do arquivo
    vr_setlinha    VARCHAR2(4000);
    vr_input_file  UTL_FILE.FILE_TYPE; -- Handle para leitura de arquivo
    
    -- Variaveis critica
    vr_dscritic    crapcri.dscritic%TYPE;
  BEGIN
    -- Carrega arquivo
    gene0001.pc_abre_arquivo(pr_nmcaminh => pr_nmarquiv   --> Nome do arquivo
                            ,pr_tipabert => 'R'           --> Modo de abertura (R,W,A)
                            ,pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                            ,pr_des_erro => vr_dscritic); --> Descricao do erro

    IF vr_dscritic IS NOT NULL THEN
      RETURN vr_nmbandeira;
    END IF;

    -- Laco para leitura de linhas do arquivo
    LOOP
      -- Carrega handle do arquivo
      gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                  ,pr_des_text => vr_setlinha); --> Texto lido                                      
      vr_cdbandeira  := TO_NUMBER(SUBSTR(vr_setlinha,31,3)); -- Codigo da bandeira
      EXIT;
    END LOOP; /* END LOOP */
    
    OPEN cr_tbcrd_bandeira(pr_idbandeira => vr_cdbandeira);
    FETCH cr_tbcrd_bandeira INTO vr_nmbandeira;
    CLOSE cr_tbcrd_bandeira;
    
    RETURN vr_nmbandeira;
  END;
    
  PROCEDURE pc_busca_arquivos(pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2          --> Nome do Campo
                             ,pr_des_erro OUT VARCHAR2) IS      --> Saida OK/NOK
    /* .............................................................................
      Programa: pc_busca_arquivos
      Sistema : Conta-Corrente - Cooperativa de Credito
      Sigla   : CRED
      Autor   : James Prust Junior
      Data    : Marco/2016                       Ultima atualizacao: 
      
      Dados referentes ao programa:
      
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para buscar os arquivos que nao foram importados
      
      Alteracoes: 
    ............................................................................. */
    -- Busca as cooperativas
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT crapcop.cdagebcb
        FROM crapcop
       WHERE cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    
    CURSOR cr_crapscb IS
      SELECT dsdirarq
        FROM crapscb
       WHERE tparquiv = 9; -- CB117
    rw_crapscb cr_crapscb%ROWTYPE;
      
    --- VARIAVEIS ---
    vr_cdcritic       crapcri.cdcritic%TYPE;
    vr_dscritic       crapcri.dscritic%TYPE;
  
    --Variáveis auxiliares
    vr_listadir       VARCHAR2(4000);
    vr_nmrquivo       VARCHAR2(4000);
    vr_dssituacao     VARCHAR2(50);
    vr_indice         VARCHAR2(50);
    vr_dsprmris       crapprm.dsvlrprm%TYPE;
    vr_tipsplit       gene0002.typ_split;
    vr_vet_arquivos   gene0002.typ_split;
    vr_xml_temp       VARCHAR2(32726) := '';
    vr_clob           CLOB;
    
    -- Variaveis de log
    vr_cdcooper       crapcop.cdcooper%TYPE;
    vr_cdoperad       VARCHAR2(100);
    vr_nmdatela       VARCHAR2(100);
    vr_nmeacao        VARCHAR2(100);
    vr_cdagenci       VARCHAR2(100);
    vr_nrdcaixa       VARCHAR2(100);
    vr_idorigem       VARCHAR2(100);
    vr_nmarquiv       VARCHAR2(300);
      
    --Controle de erro
    vr_exc_erro       EXCEPTION;
  BEGIN
  
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
  
    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop(pr_cdcooper => vr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    -- Se nao encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois havera raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;
      
    -- buscar informações do arquivo a ser processado
    OPEN cr_crapscb;
    FETCH cr_crapscb INTO rw_crapscb;
    CLOSE cr_crapscb;
    
    -- Condicao para verificar se o arquivo contabil jah foi gerado
    vr_dsprmris := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                            ,pr_cdcooper => vr_cdcooper
                                            ,pr_cdacesso => 'RISCO_CARTAO_BACEN');
                                                       
    vr_tipsplit := gene0002.fn_quebra_string(pr_string => vr_dsprmris, pr_delimit => ';');
    
    -- Procedure responsavel por buscar os arquivos que serao importados
    RISC0002.pc_lista_arquivos(pr_cdagebcb => rw_crapcop.cdagebcb
                              ,pr_dsdirarq => rw_crapscb.dsdirarq
                              ,pr_nmrquivo => vr_nmrquivo
                              ,pr_listadir => vr_listadir
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);
    -- Condicao para verificar se houve erro
    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    -- Condicao para verificar se nesse momento estah sendo importado os arquivos
    IF vr_listadir IS NOT NULL AND vr_tipsplit(3) = 0 THEN     
      vr_dssituacao := 'Não Importado';    
    ELSIF vr_tipsplit(3) = 1 THEN
      vr_dssituacao := 'Importando';
    ELSE
      vr_dssituacao := 'Importado';
    END IF;
    
    -- Monta documento XML
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
    -- Criar cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?>
                                                    <Dados>
                                                      <Inf>
                                                        <situacao>'||vr_dssituacao||'</situacao>
                                                      </Inf>
                                                      <Arquivos>');
                          
    vr_vet_arquivos := gene0002.fn_quebra_string(pr_string => vr_listadir);
    -- Leitura da PL/Table e processamento dos arquivos
    vr_indice := vr_vet_arquivos.first;
    WHILE vr_indice IS NOT NULL LOOP
      -- Nome do arquivo
      vr_nmarquiv := rw_crapscb.dsdirarq || '/recebe/' || vr_vet_arquivos(vr_indice);
      -- Carrega os dados           
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Arquivo>'||
                                                      '<nmarquiv>' || vr_vet_arquivos(vr_indice)       || '</nmarquiv>'||
                                                      '<nmbandei>' || fn_retorna_bandeira(vr_nmarquiv) || '</nmbandei>'||
                                                   '</Arquivo>');
      -- Proximo arquivo
      vr_indice := vr_vet_arquivos.next(vr_indice);
    END LOOP;
    
    -- Cria a Tag com os Totais
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '  </Arquivos>'||
                                                 '</Dados>'
                           ,pr_fecha_xml      => TRUE);
    
    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clob);
    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);
    dbms_lob.freetemporary(vr_clob);
    
    pr_des_erro := 'OK';
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro := 'NOK';
      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_IMPCAR.PC_BUSCA_ARQUIVOS --> ' ||SQLERRM;      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||pr_dscritic || '</Erro></Root>');
    
  END pc_busca_arquivos;

  PROCEDURE pc_importa_arquivos(pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2          --> Nome do Campo
                               ,pr_des_erro OUT VARCHAR2) IS      --> Saida OK/NOK
    /* .............................................................................
      Programa: pc_importa_arquivos
      Sistema : Conta-Corrente - Cooperativa de Credito
      Sigla   : CRED
      Autor   : James Prust Junior
      Data    : Marco/2016                       Ultima atualizacao: 
      
      Dados referentes ao programa:
      
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para importar os arquivos do cartao de credito
      
      Alteracoes:
    ............................................................................. */
    -- Variaveis auxiliares
    vr_dsplsql  VARCHAR2(4000);
    vr_jobname  VARCHAR2(50);
    vr_dsprmris crapprm.dsvlrprm%TYPE;
    vr_tipsplit gene0002.typ_split;
    
    -- Variaveis de erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
      
    --Controle de erro
    vr_exc_erro EXCEPTION;
  
  BEGIN
  
    pr_des_erro := 'OK';
  
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
  
    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    -- Condicao para verificar se o arquivo contabil jah foi gerado
    vr_dsprmris := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                            ,pr_cdcooper => vr_cdcooper
                                            ,pr_cdacesso => 'RISCO_CARTAO_BACEN');
                                                       
    vr_tipsplit := gene0002.fn_quebra_string(pr_string => vr_dsprmris, pr_delimit => ';');
    -- Condicao para verificar se nesse momento estah sendo importado os arquivos
    IF vr_tipsplit(3) = 1 THEN
      vr_dscritic := 'Nao e possivel efetuar a importacao, importacao solicitada ou executando.';
      RAISE vr_exc_erro;
    END IF;
    
    -- Seta a flag para informar que estah sendo importado o arquivo CB117
    vr_tipsplit(3) := 1;         
    RISC0002.pc_atualiza_param_risco_cartao(pr_cdcooper => vr_cdcooper
                                           ,pr_tipsplit => vr_tipsplit
                                           ,pr_dscritic => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    -- Grava os dados no banco de dados
    COMMIT;
    
    -- Chamar o JOB
    -- Montar o bloco PLSQL que será executado
    -- Ou seja, executaremos a geração dos dados
    -- para a agência atual atraves de Job no banco
    vr_dsplsql := 'begin' ||chr(10) ||
                  '  RISC0002.pc_import_arq_risco_cartao_tel(pr_cdcooper => '|| vr_cdcooper ||');'|| chr(10) ||
                  'end;';
    -- Montar o prefixo do código do programa para o jobname
    vr_jobname := 'JOB_IMPCAR_' || vr_cdcooper || '$';
    -- Faz a chamada ao programa paralelo atraves de JOB
    GENE0001.pc_submit_job(pr_cdcooper  => vr_cdcooper  --> Código da cooperativa
                          ,pr_cdprogra  => 'IMPCAR'     --> Código do programa
                          ,pr_dsplsql   => vr_dsplsql   --> Bloco PLSQL a executar
                          ,pr_dthrexe   => SYSTIMESTAMP --> Executar nesta hora
                          ,pr_interva   => NULL         --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                          ,pr_jobname   => vr_jobname   --> Nome randomico criado
                          ,pr_des_erro  => vr_dscritic);
    -- Testar saida com erro
    IF vr_dscritic IS NOT NULL THEN
      -- Levantar exceçao
      RAISE vr_exc_erro;
    END IF;
        
    COMMIT;
      
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro := 'NOK';
      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||pr_dscritic || '</Erro></Root>');
    
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_IMPCAR.PC_IMPORTA_ARQUIVOS --> ' ||SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
  END pc_importa_arquivos;

END TELA_IMPCAR;
/
