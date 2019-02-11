CREATE OR REPLACE PACKAGE CECRED.json0001 IS

  TYPE typ_http_get_parameters IS TABLE OF VARCHAR2(4000) INDEX BY VARCHAR2(255);

  TYPE typ_http_headers IS TABLE OF VARCHAR2(4000) INDEX BY VARCHAR2(255);
  
  TYPE typ_http_request IS RECORD(service_uri VARCHAR2(1000) -- Diretório do Servidor. Ex: http://mobilebankhml.cecred.coop.br/apí
                                 ,api_route   VARCHAR2(255) -- Rota completa da Api. Ex: conta/cooperativas
                                 ,method      VARCHAR2(10) -- Método da requisição HTTP, Ex: GET
                                 ,timeout     NUMBER DEFAULT 1000 -- Tempo máximo para espera de uma resposta da requisição HTTP
                                 ,headers     typ_http_headers -- Lista de propriedades do header da requisição HTTP
                                 ,content     CLOB -- Content da requisição HTTP
                                 ,parameters  typ_http_get_parameters -- Lista de parâmetros GET (na URL) da requisição HTTP
                                 ,useproxy    BOOLEAN -- Utiliza proxy
                                 );
  
  TYPE typ_http_response IS RECORD(status_code    NUMBER -- Código do status da resposta do servidor
                                  ,status_message VARCHAR2(4000) -- Mensagem da resposta do servidor
                                  ,headers        CLOB DEFAULT NULL -- Headers da resposta do servidor
                                  ,content        CLOB DEFAULT NULL -- Content da resposta do servidor
                                  );

  PROCEDURE pc_executa_ws_json(pr_request           IN typ_http_request -- Conteúdo da requisição
                              ,pr_response          OUT typ_http_response -- Conteúdo da resposta do servidor
                              ,pr_diretorio_log     IN VARCHAR2 -- Diretório para guarda dos arquivos (Arquivos enviados e recebidos)
                              ,pr_formato_nmarquivo IN VARCHAR2 DEFAULT 'YYYYMMDDHH24MISSFF3".[api]"' -- Formato da nomenclatura dos arquivos (Formato de Data). Utilizar formatação de data. Variáveis possíveis: [method], [api]
                              ,pr_dscritic          OUT VARCHAR2 -- Mensagem de erro
                               );

END json0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.json0001 IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : JSON0001
  --  Sistema  : Procedimentos e funcoes para comunicacao com webservice.
  --  Sigla    : CRED
  --  Autor    : Dionathan Henchel
  --  Data     : Março/2016
  --
  -- Objetivo  : Cliente para webservice JSON ou demais.
  --
  -- Alterações: 15/03/2016 - Inclusao do parametro para informar se comunicacao exige proxy (Odirlei-AMcom)
  --
  --             09/06/2017 - P337 - Leitura e armazenagem dos headers da resposta (Marcos-Supero)
  ---------------------------------------------------------------------------------------------------------------
  PROCEDURE pc_executa_ws_json(pr_request           IN typ_http_request -- Conteúdo da requisição
                              ,pr_response          OUT typ_http_response -- Conteúdo da resposta do servidor
                              ,pr_diretorio_log     IN VARCHAR2 -- Diretório para guarda dos arquivos (Arquivos enviados e recebidos)
                              ,pr_formato_nmarquivo IN VARCHAR2 DEFAULT 'YYYYMMDDHH24MISSFF3".[api]"' -- Formato da nomenclatura dos arquivos (Formato de Data). Utilizar formatação de data. Variáveis possíveis: [method], [api]
                              ,pr_dscritic          OUT VARCHAR2 -- Mensagem de erro
                               ) IS
    
    vr_comando   VARCHAR2(4000);
    vr_dscomora  VARCHAR2(1000);
    
    -- Variáveis de exceção
    vr_exc_saida EXCEPTION;
    vr_typ_saida VARCHAR2(3);
    vr_dscritic  VARCHAR(4000);
    
    -- Variáveis de diretórios e arquivos
    vr_nmarqcmd VARCHAR2(1000);
    vr_file_request VARCHAR2(1000);
    vr_file_response VARCHAR2(1000);
    
    -- Variáveis auxiliares para trabalhar com objetos JSON
    vr_json_request json := json();
    vr_json_response json := json();
    vr_json_headers json_list := json_list();
    vr_json_parameters json_list := json_list();
    vr_index_header VARCHAR2(255);
    vr_index_parameter VARCHAR2(255);
    
    -- Variáveis CLOB para guardar os conteúdos dos JSON
    vr_clob_request CLOB;
    vr_clob_response CLOB;
  
    -- Cursor para obter o nome do arquivo
    -- Este cursor converte as variáveis em valor, qualquer variavel nova deve ser adicionada aqui
    CURSOR cr_nmarquivo IS
      SELECT LOWER(REPLACE(REPLACE(
                   LOWER(to_char(systimestamp,pr_formato_nmarquivo))
                                             ,'[api]',regexp_replace(pr_request.api_route, '\W', '_'))
                                             ,'[method]',regexp_replace(pr_request.method, '\W', '_')
                           )) nmarquivo
        FROM dual;
  
      --Funtion gerar os parametros para as listas de JSON
    FUNCTION pc_gera_parametro(prm_name  IN VARCHAR2
                                ,prm_value IN VARCHAR2) RETURN json_value IS

        vr_obj json := json();
      BEGIN
        vr_obj.put('Name', prm_name);
        vr_obj.put('Value', prm_value);

        RETURN vr_obj.to_json_value;
      END;
  
  BEGIN
  
    -- Gera o nome do arquivo
    BEGIN
      
      OPEN cr_nmarquivo;
      FETCH cr_nmarquivo
        INTO vr_file_request;
      CLOSE cr_nmarquivo;
    
    EXCEPTION
      WHEN OTHERS THEN
           vr_dscritic := 'Erro ao gerar o nome do arquivo, verifique o formato passado por parâmetro';
           RAISE vr_exc_saida;
    END;
    
    --Obtem o arquivo perl no diretório ROOT da Cecred
    vr_nmarqcmd := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                            ,pr_cdcooper => 3
                                            ,pr_cdacesso => 'ROOT_CECRED_BIN') ||
                   'GenericJsonWSClient.pl';
        
    -- Gera dois arquivos, com o conteúdo do request (IN) e do response (OUT)
    vr_file_response := vr_file_request;
    vr_file_request  := vr_file_request  || '_in.json';
    vr_file_response := vr_file_response || '_out.json';
    
    -- Constrói o JSON de request
    vr_json_request.put('Service', pr_request.service_uri);
    vr_json_request.put('Api', pr_request.api_route);
    vr_json_request.put('Method', pr_request.method);
    vr_json_request.put('Timeout', pr_request.timeout);
    
    -- Verificar se usa proxy
    IF pr_request.useproxy THEN
      vr_json_request.put('UseProxy',1);
    ELSE
      vr_json_request.put('UseProxy',0);
    END IF;   
      
    
    
    -- Gera lista de Headers em JSON
    vr_index_header := pr_request.headers.FIRST;
    WHILE (vr_index_header IS NOT NULL)
    LOOP
      vr_json_headers.append(pc_gera_parametro(vr_index_header, pr_request.headers(vr_index_header)));
      vr_index_header := pr_request.headers.NEXT(vr_index_header);
    END LOOP;
    
    -- Gera lista de Parâmetros em JSON
    vr_index_parameter := pr_request.parameters.FIRST;
    WHILE (vr_index_parameter IS NOT NULL)
    LOOP
      vr_json_parameters.append(pc_gera_parametro(vr_index_parameter, pr_request.parameters(vr_index_parameter)));
      vr_index_parameter := pr_request.parameters.NEXT(vr_index_parameter);
    END LOOP;
    
    -- Adiciona as listas de Headers e Parameters no JSON principal
    vr_json_request.put('Headers', vr_json_headers);
    vr_json_request.put('Parameters', vr_json_parameters);
    
    -- Popula o content, caso for um JSON popula como JSON, caso contrário como string
    BEGIN
       vr_json_request.put('Content', json(pr_request.content));
    EXCEPTION
      WHEN OTHERS THEN
       vr_json_request.put('Content', pr_request.content);
    END;
    
    --vr_json_request.print();
    
    -- Salva o JSON em CLOB
    dbms_lob.createtemporary(vr_clob_request, TRUE);
    vr_json_request.to_clob(vr_clob_request, FALSE);
    
    -- Salva o CLOB em arquivo no diretório recebido por parâmetro
    gene0002.pc_clob_para_arquivo(pr_clob     => vr_clob_request
                                 ,pr_caminho  => pr_diretorio_log
                                 ,pr_arquivo  => vr_file_request
                                 ,pr_des_erro => vr_dscritic);
                             
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
    
    -- Gera comando para executar script Perl
    vr_dscomora := gene0001.fn_param_sistema('CRED', 3, 'SCRIPT_EXEC_SHELL');
  
    vr_comando := vr_dscomora || ' perl_remoto ' || vr_nmarqcmd;
    vr_comando := vr_comando || ' < ' ||
                  REPLACE(pr_diretorio_log ||'/'||vr_file_request, 'coopd', 'coop') || ' > ' ||
                  REPLACE(pr_diretorio_log ||'/'||vr_file_response, 'coopd', 'coop');
    
    -- Executa o comando no unix
    gene0001.pc_oscommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_comando
                         ,pr_typ_saida   => vr_typ_saida
                         ,pr_des_saida   => vr_dscritic);
  
    IF vr_dscritic IS NOT NULL THEN
       RAISE vr_exc_saida;
    END IF;
    -- SCTASK0038225
    -- Alterado para utilizar a rotina genérica
    -- Obtem o arquivo com o JSON de resposta e popula um CLOB
    vr_clob_response := GENE0002.fn_arq_para_clob(pr_caminho => pr_diretorio_log
                                                      ,pr_arquivo => vr_file_response);
/*  vr_clob_response := DBMS_XSLPROCESSOR.read2clob(pr_diretorio_log, vr_file_response, 0);*/
    -- Fim SCTASK38225

    -- Converte CLOB para JSON
    vr_json_response := json(vr_clob_response);
    
    -- Obtém os dados do JSON para dentro do objeto de response
    pr_response.status_code := to_number(regexp_replace(vr_json_response.get('StatusCode').to_char,'^\"|\"$','')); -- Regex para remover aspas duplas nas duas pontas
    pr_response.status_message := regexp_replace(vr_json_response.get('StatusMessage').to_char,'^\"|\"$',''); -- Regex para remover aspas duplas nas duas pontas
    
    dbms_lob.createtemporary(pr_response.content, TRUE);
    vr_json_response.get('Content').to_clob(pr_response.content);
    
    dbms_lob.createtemporary(pr_response.headers, TRUE);
    vr_json_response.get('Headers').to_clob(pr_response.headers);    
    
  
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_dscritic := vr_dscritic;
      ROLLBACK;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro ao tentar chamar o WebService: ' || SQLERRM;
  END pc_executa_ws_json;

END json0001;
/
