CREATE OR REPLACE PACKAGE CECRED.cobr0004 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : COBR0004
  --  Sistema  : Procedimentos para  gerais da cobranca
  --  Sigla    : CRED
  --  Autor    : Dionathan Henchel
  --  Data     : Abril/2015.                   Ultima atualizacao: 28/11/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas de comunicação com webservice para transferencia de arquivos de cobrança.
  --
  --  Alteracoes: 
  --  28/11/2018 -Foi adicionado a chamada da procedure   pc_processa_retorno na pc_ws_pg_upload, e foi relizado os tratamentos 
  --              de exceções na  pc_processa_retorno_servico (Bruno Cardoso Mout'S):PRB0040355:
  ---------------------------------------------------------------------------------------------------------------
  --Procedure para segurar execucao de programa por determinados segundos
  PROCEDURE pc_espera_segundo(pr_qtsegund number);
  --Abre conexão com o WebService e faz o upload do arquivo de remessa
  PROCEDURE pc_upload_webservice_pg(pr_nmarcnab IN VARCHAR2 -- Nome do arquivo CNAB de remessa
                                   ,pr_dscritic OUT VARCHAR2);

  --Abre conexão com o WebService e faz o download do arquivo de retorno
  PROCEDURE pc_download_webservice_pg(pr_dtjobini IN DATE -- Data de abertura do Job - Inicial
                                     ,pr_dtjobfim IN DATE -- Data de abertura do Job - Final
                                     ,pr_nmarqret OUT VARCHAR2 -- Nome do arquivo baixado do webservice
                                     ,pr_dscritic OUT VARCHAR2);
END cobr0004;
/
CREATE OR REPLACE PACKAGE BODY CECRED.cobr0004 IS

  vr_iso8601_format VARCHAR2(50) := 'YYYY-MM-DD"T"HH24:MI:SS'; -- Formato ISO8601
  vr_horaatua VARCHAR2(15); -- Data e hora atual para concatenar nos nomes dos arquivos
  
  procedure pc_espera_segundo(pr_qtsegund number) is
    /* .............................................................................

    Programa: pc_espera_segundo
    Sistema : Procedimentos para  gerais da cobranca
    Sigla   : CRED
    Autor   : Ademir José Fink
    Data    : 06/06/2017                        Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Gerar tempo de espera em segundos na execução de pl-sql

    Alteracoes:
    ............................................................................. */
  begin
    --
    sys.dbms_lock.sleep(nvl(pr_qtsegund,0));
    --
  end pc_espera_segundo;
  
  --Executa perl que chama o webservice enviando um arquivo no request
  --Parâmetro pr_nrservic:
  --|VLR| NOME                    | ENVIO     | RETORNO
  --|---|-------------------------|-----------|---------
  --| 1 | Authentication          | JSON      | JSON
  --| 2 | JobCreation             | JSON      | JSON
  --| 3 | Upload                  | Arquivo   |
  --| 4 | Download                |           | Arquivo
  --| 5 | Check Async Operation   | SessionId | JSON
  --| 6 | CorrectionAndDevolution | JSON      | JSON
  --| 7 | Logoff                  |           | JSON
  PROCEDURE pc_executa_webservice_pg(pr_arqenvio IN VARCHAR2 DEFAULT NULL
                                    ,pr_resource IN CLOB DEFAULT NULL
                                    ,pr_nrservic IN NUMBER
                                    ,pr_nrdtoken IN VARCHAR2 DEFAULT NULL
                                    ,pr_idsessao IN VARCHAR2 DEFAULT NULL
                                    ,pr_arqreceb OUT VARCHAR2
                                    ,pr_dscritic OUT VARCHAR2) IS
  
    vr_nmarqcmd  VARCHAR2(1000);
    vr_drsalvar  VARCHAR2(1000);
    vr_nmdirarq  VARCHAR2(1000);
    vr_dscomora  VARCHAR2(1000);
    vr_comando   VARCHAR2(4000);
    vr_typ_saida VARCHAR2(3);
    vr_arqenvio  VARCHAR2(1000);
    vr_dsservic  VARCHAR2(50);
  
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
  BEGIN
  
    --Diretório ROOT da Cecred
    vr_nmarqcmd := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                            ,pr_cdcooper => 3
                                            ,pr_cdacesso => 'ROOT_CECRED_BIN') ||
                   'SendJsonPG.pl';
  
    --Diretorio Salvar da Cecred
    vr_drsalvar := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                        ,pr_cdcooper => 3
                                        ,pr_nmsubdir => NULL) || '/salvar';
  
    -- Busca um nome para o serviço para concatenar no nome dos arquivos de remessa e retorno
    vr_dsservic := CASE pr_nrservic
                      WHEN 1 THEN 'AUTHENTICATION'
                      WHEN 2 THEN 'JOBCREATION'
                      WHEN 3 THEN 'UPLOAD'
                      WHEN 4 THEN 'DOWNLOAD'
                      WHEN 5 THEN 'CHECKASYNC'
                      WHEN 6 THEN 'CORRECTANDDEVOL'
                      WHEN 7 THEN 'LOGOFF'
                    END;
  
    --Caso for download é um arquivo .ret senão é um JSON
    IF pr_nrservic = 4 THEN
      pr_arqreceb := 'PG_CECRED_' || vr_horaatua || '.ret';
    ELSE
      --Nome do arquivo do retorno do WebService
      pr_arqreceb := 'PG_RET_' || vr_horaatua || '.' || vr_dsservic || '.json';
    END IF;
  
    --Concatena o diretório e nome do arquivo
    pr_arqreceb := vr_drsalvar || '/' || pr_arqreceb;
  
    --Se for uma requisição JSON cria um arquivo físico
    IF pr_resource IS NOT NULL THEN
    
      -- Nome do arquivo JSON à enviar
      vr_arqenvio := 'PG_ENV_' || vr_horaatua || '.' || vr_dsservic || '.json';
    
      gene0002.pc_clob_para_arquivo(pr_clob     => pr_resource
                                   ,pr_caminho  => vr_drsalvar
                                   ,pr_arquivo  => vr_arqenvio
                                   ,pr_des_erro => pr_dscritic);
    
      --Concatena o diretório e nome do arquivo
      vr_arqenvio := vr_drsalvar || '/' || vr_arqenvio;
    
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
    ELSE
      -- Senão passa o arquivo recebido por parâmetro
    
      -- Diretorio Arq
      vr_nmdirarq := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                          ,pr_cdcooper => 3
                                          ,pr_nmsubdir => 'arq');
    
      --Concatena o diretório e nome do arquivo
      vr_arqenvio := vr_nmdirarq || '/' || pr_arqenvio;
    END IF;
  
    --Buscar parametros 
    vr_dscomora := gene0001.fn_param_sistema('CRED', 3, 'SCRIPT_EXEC_SHELL');
  
    --Gera comando para chamar o WebService
    vr_comando := vr_dscomora || ' perl_remoto ' || vr_nmarqcmd;
    vr_comando := vr_comando || ' --servico=' || CHR(39) || pr_nrservic || CHR(39);
    vr_comando := vr_comando || ' --token=' || CHR(39) || pr_nrdtoken ||  CHR(39);
    vr_comando := vr_comando || ' --session=' || CHR(39) || pr_idsessao ||  CHR(39);
    vr_comando := vr_comando || ' --arquivo=' || CHR(39) || pr_arqenvio ||  CHR(39);
    vr_comando := vr_comando || ' < ' ||
                  REPLACE(vr_arqenvio, 'coopd', 'coop') || ' > ' ||
                  REPLACE(pr_arqreceb, 'coopd', 'coop');
    --[TODO] Remover os replaces do diretório COOPD
  
    --Executar o comando no unix
    gene0001.pc_oscommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_comando
                         ,pr_typ_saida   => vr_typ_saida
                         ,pr_des_saida   => pr_dscritic);
    IF pr_dscritic IS NOT NULL THEN
      --Caso for output do SSL ignora
      IF UPPER(pr_dscritic) LIKE '%SSL_CONNECT%' THEN
         pr_dscritic := NULL;
      ELSE
         RAISE vr_exc_saida;
      END IF;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro ao executar a requisição ao WS da PG: ' || pr_dscritic;
  END pc_executa_webservice_pg;

  --Processa o escopo externo da resposta e retorna o erro caso houver
  PROCEDURE pc_processa_retorno_servico(pr_arqreceb IN VARCHAR2 -- Arquivo recebido por parâmetro
                                       ,pr_resptipo OUT NUMBER -- Numérico com o tipo da resposta  (Parâmetro Type)
                                       ,pr_respdado OUT CLOB -- Dados nternos do retorno (Parametro Data)
                                       ,pr_idsessao OUT VARCHAR2 -- Id da Sessão no WS da PG  (Parâmetro SessionId)
                                       ,pr_dscritic OUT VARCHAR2 -- Mensagem de erro retornada no WS
                                        ) IS
    vr_response json;
    vr_clob     CLOB;
    vr_nmdireto VARCHAR2(1000);
    vr_nmarquiv VARCHAR2(1000);
  BEGIN
    --Separar arquivo do path
    gene0001.pc_separa_arquivo_path(pr_caminho => pr_arqreceb --Arquivo Recebimento
                                   ,pr_direto  => vr_nmdireto --Nome Diretorio
                                   ,pr_arquivo => vr_nmarquiv); --Nome Arquivo
  
    vr_clob := gene0002.fn_arq_para_clob(vr_nmdireto, vr_nmarquiv);
  
    vr_response := json(vr_clob);
    pr_resptipo := to_number(vr_response.get('Type').to_char);
    pr_idsessao := vr_response.get('SessionId').to_char;
  
    -- Mensagens com tipo negativo são de erro
    IF pr_resptipo < 0 THEN
      pr_dscritic := CASE pr_resptipo
                       WHEN -3 THEN
                        'ABORTED - Serviço abortado pelo cliente'
                       WHEN -2 THEN
                        'UNAUTHORIZED - O token passado é inválido'
                       ELSE
                        'ERROR - ' || vr_response.get('Data').to_char
                     END;
    
    ELSE
      pr_respdado := vr_response.get('Data').to_char;
    END IF;
	
	 EXCEPTION
    WHEN OTHERS THEN
      vr_erroconver := 'N';
      BEGIN
        pr_resptipo := to_number(substr(to_char(vr_clob), 19, 2));
      EXCEPTION
        WHEN OTHERS THEN
          vr_erroconver := 'S';
      END;
      IF NVL(pr_resptipo, -9999) < 0 THEN
        pr_dscritic := CASE pr_resptipo
                         WHEN -3 THEN
                          'ABORTED - Serviço abortado pelo cliente'
                         WHEN -2 THEN
                          'UNAUTHORIZED - O token passado é inválido'
                         ELSE
                          'ERROR - STATUS CODE'
                       END;
      ELSIF vr_erroconver = 'S' THEN
        pr_dscritic := 'ERRO CONTEUDO';
      END IF;
 
  END pc_processa_retorno_servico;

  --Autentica uma conexão com a PG
  PROCEDURE pc_ws_pg_autenticacao(pr_nrdtoken OUT VARCHAR2
                                 ,pr_dscritic OUT VARCHAR2) IS
  
    ---[TODO] COLOCAR EM PARÂMETROS
    vr_nmusuari VARCHAR2(255) := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                          ,pr_cdacesso => 'PAINELWEBPG_USUARIO_WS');
    vr_cdempres VARCHAR2(255) := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                          ,pr_cdacesso => 'PAINELWEBPG_EMPRESA_WS');
    vr_dsdsenha VARCHAR2(255) := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                          ,pr_cdacesso => 'PAINELWEBPG_SENHA_WS');
  
    vr_resource CLOB; -- JSON gerado
    vr_arqreceb VARCHAR(1000); --Arquivo de resposta recebido do Perl
  
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
  
    --Gera o json da requisição 
    PROCEDURE pc_gera_json(pr_username    IN VARCHAR2 -- Nome de usuario
                          ,pr_companycode IN VARCHAR2 -- Empresa
                          ,pr_password    IN VARCHAR2 -- Senha
                           ) IS
      vr_obj json := json();
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
    BEGIN
      vr_obj.put('Username', pr_username);
      vr_obj.put('CompanyCode', pr_companycode);
      vr_obj.put('Password', pr_password);
    
      dbms_lob.createtemporary(vr_resource, TRUE);
      vr_obj.to_clob(vr_resource, FALSE);
    
      vr_resource := '=' || utl_url.escape(vr_resource); --Encripta o conteudo do CLOB
    
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao gerar JSON: ' || SQLERRM;
    END pc_gera_json;
  
    --Processa retorno
    PROCEDURE pc_processa_retorno IS
    
      vr_resptipo NUMBER;
      vr_respdado CLOB;
      vr_idsessao VARCHAR2(100); -- Não existe ainda, serve apenas para receber o OUT da procedure
      vr_respjson json;
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
    
    BEGIN
    
      --Processa o escopo externo da resposta
      pc_processa_retorno_servico(pr_arqreceb => vr_arqreceb -- Arquivo recebido por parâmetro
                                 ,pr_resptipo => vr_resptipo -- Numérico com o tipo da resposta (Parâmetro Type)
                                 ,pr_respdado => vr_respdado -- Dados nternos do retorno (Parametro Data)
                                 ,pr_idsessao => vr_idsessao -- Id da Sessão no WS da PG  (Parâmetro SessionId)
                                 ,pr_dscritic => pr_dscritic -- Mensagem de erro retornada no WS
                                  );
    
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
    
      -- Verifica se possui dados no JSON
      IF vr_respdado IS NOT NULL THEN
      
        vr_respjson := json(vr_respdado); -- Converte CLOB para JSON
      
        pr_nrdtoken := vr_respjson.get('Token').to_char;
      END IF;
    
    EXCEPTION
      WHEN OTHERS THEN
        IF pr_dscritic IS NULL THEN
          pr_dscritic := 'Erro ao processar retorno: ' || SQLERRM;
        END IF;
    END pc_processa_retorno;
  
  BEGIN
    -- Gera o JSON
    pc_gera_json(pr_username    => vr_nmusuari
                ,pr_companycode => vr_cdempres
                ,pr_password    => vr_dsdsenha);
  
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  
    -- Chama o WebService
    pc_executa_webservice_pg(pr_nrservic => 1 -- Authentication
                            ,pr_resource => vr_resource
                            ,pr_arqreceb => vr_arqreceb
                            ,pr_dscritic => pr_dscritic);
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  
    -- Processa o retorno
    pc_processa_retorno;
  
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      --Se já possuir excessão das chamadas internas coloca
      --apenas o nome do método para nao ficar repetitivo
      IF pr_dscritic IS NOT NULL THEN
        pr_dscritic := 'Autenticação - ' || pr_dscritic;
      ELSE
        pr_dscritic := 'Erro ao autenticar: ' || SQLERRM;
      END IF;
      RETURN;
  END pc_ws_pg_autenticacao;

  -- Cria um Job e retorna uma SessionId para dar início ao upload
  PROCEDURE pc_ws_pg_cria_job(pr_nrdtoken IN VARCHAR2 -- Token de conexão com o WS da PG
                             ,pr_nmarcnab IN VARCHAR2 -- Nome do arquivo CNAB de remessa
                             ,pr_idsessao OUT VARCHAR2 -- Id da Sessão no WS da PG
                             ,pr_dscritic OUT VARCHAR2) IS
  
    vr_resource CLOB; -- JSON gerado
    vr_arqreceb VARCHAR(1000); --Arquivo de resposta recebido do Perl
  
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
  
    --Gera o json para abrir um job para envio de arquivos ao webservice da PG
    PROCEDURE pc_gera_json(pr_ccostid              IN VARCHAR2 -- ID do centro de custo
                          ,pr_estimatedrecordcount IN NUMBER -- Numero previsto de registros
                          ,pr_filename             IN VARCHAR2 -- Nome do arquivo de dados que sera enviado
                          ,pr_generationdate       IN DATE -- Data de Geração
                          ,pr_jobcycle             IN DATE -- Ciclo de fechamento
                          ,pr_jobowneros           IN VARCHAR2 -- Numero do chamado
                          ,pr_maximumrecordcount   IN NUMBER -- Numero maximo de registros do arquivo de dados
                           ) IS
    
      vr_obj     json := json();
      vr_obj_prm json_list := json_list(); -- Não necessario por enquanto
    
      --Funtion gerar os parametros do campo "JobParameter"
      FUNCTION pc_gera_parametro(prm_name  IN VARCHAR2
                                ,prm_value IN json_value) RETURN json_value IS
      
        vr_obj json := json();
      BEGIN
        vr_obj.put('Name', prm_name);
        vr_obj.put('Parameter', prm_value);
      
        RETURN vr_obj.to_json_value;
      END;
    BEGIN
    
      vr_obj.put('CcostID', pr_ccostid);
      vr_obj.put('EstimatedRecordCount', pr_estimatedrecordcount);
      -- vr_obj.put('ExpireDate', pr_expiredate);
      vr_obj.put('FileName', pr_filename);
      vr_obj.put('GenerationDate', to_char(pr_generationdate, vr_iso8601_format));
      vr_obj.put('JobCycle', to_char(pr_jobcycle, vr_iso8601_format));
      vr_obj.put('JobOwnerOS', pr_jobowneros);
    
      -------- LISTA DE PARAMETROS -------- (Caso necessario implementar)
      /*vr_obj_prm.append(pc_gera_parametro('Fundo', json_value('')));
      vr_obj_prm.append(pc_gera_parametro('Grafica', json_value('')));
      vr_obj_prm.append(pc_gera_parametro('Prorrogavel', json_value('')));
      vr_obj_prm.append(pc_gera_parametro('Ativo', json_value('0')));
      vr_obj_prm.append(pc_gera_parametro('Sim ou Não', json_value(0)));
      vr_obj_prm.append(pc_gera_parametro('Informe numero de registros',json_value(1)));
      vr_obj_prm.append(pc_gera_parametro('Peso da carta', json_value(1)));*/
      -------- LISTA DE PARAMETROS --------
    
      vr_obj.put('JobParameter', vr_obj_prm);
    
      -- vr_obj.put('LimitExpireDate', pr_limitexpiredate);
      vr_obj.put('Observations', '');
      vr_obj.put('PrePrintedID', 0);
      vr_obj.put('Template', 13017); -- codigo template 13017 definido em 22/06/15
      vr_obj.put('UpdateModel', FALSE);
      vr_obj.put('MaximumRecordCount', pr_maximumrecordcount);
    
      dbms_lob.createtemporary(vr_resource, TRUE);
      vr_obj.to_clob(vr_resource, FALSE);
    
      vr_obj.print;
    
      vr_resource := '=' || utl_url.escape(vr_resource); --Encripta o conteudo do CLOB
    
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao gerar JSON: ' || SQLERRM;
    END pc_gera_json;
  
    --Processa retorno
    PROCEDURE pc_processa_retorno IS
    
      vr_resptipo NUMBER;
      vr_respdado CLOB;
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
    
    BEGIN
    
      --Processa o escopo externo da resposta
      pc_processa_retorno_servico(pr_arqreceb => vr_arqreceb -- Arquivo recebido por parâmetro
                                 ,pr_resptipo => vr_resptipo -- Numérico com o tipo da resposta (Parâmetro Type)
                                 ,pr_respdado => vr_respdado -- Dados nternos do retorno (Parametro Data)
                                 ,pr_idsessao => pr_idsessao -- Id da Sessão no WS da PG  (Parâmetro SessionId)
                                 ,pr_dscritic => pr_dscritic -- Mensagem de erro retornada no WS
                                  );
    
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
    
    EXCEPTION
      WHEN OTHERS THEN
        IF pr_dscritic IS NULL THEN
          pr_dscritic := 'Erro ao processar retorno: ' || SQLERRM;
        END IF;
    END pc_processa_retorno;
  
  BEGIN
    -- Gera o JSON
    pc_gera_json(pr_ccostid              => 0 -- Esperar Homolagação para ver oque colocar
                ,pr_estimatedrecordcount => 1
                ,pr_filename             => pr_nmarcnab
                ,pr_generationdate       => SYSDATE
                ,pr_jobcycle             => SYSDATE
                ,pr_jobowneros           => 0
                ,pr_maximumrecordcount   => 0);
  
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  
    -- Chama o WebService
    pc_executa_webservice_pg(pr_nrservic => 2 -- JobCreation
                            ,pr_nrdtoken => pr_nrdtoken
                            ,pr_resource => vr_resource
                            ,pr_arqreceb => vr_arqreceb
                            ,pr_dscritic => pr_dscritic);
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  
    -- Processa o retorno
    pc_processa_retorno;
  
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      --Se já possuir excessão das chamadas internas coloca
      --apenas o nome do método para nao ficar repetitivo
      IF pr_dscritic IS NOT NULL THEN
        pr_dscritic := 'Criar Job - ' || pr_dscritic;
      ELSE
        pr_dscritic := 'Erro ao criar Job: ' || SQLERRM;
      END IF;
      RETURN;
  END pc_ws_pg_cria_job;

  -- Faz o upload do arquivo CNAB
  PROCEDURE pc_ws_pg_upload(pr_idsessao IN VARCHAR2 -- Id da Sessão no WS da PG
                           ,pr_nmarcnab IN VARCHAR2 -- Nome do arquivo CNAB de remessa
                           ,pr_finaliza OUT BOOLEAN --  Indicador se finalizou processo assíncrono (upload)
                           ,pr_dscritic OUT VARCHAR2) IS
  
    vr_arqreceb VARCHAR2(1000);
  
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    --Processa retorno
    PROCEDURE pc_processa_retorno IS
    
      vr_resptipo NUMBER;
      vr_respdado CLOB;
      vr_idsessao VARCHAR2(100);
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
    
    BEGIN
    
      --Processa o escopo externo da resposta
      pc_processa_retorno_servico(pr_arqreceb => vr_arqreceb -- Arquivo recebido por parâmetro
                                 ,pr_resptipo => vr_resptipo -- Numérico com o tipo da resposta (Parâmetro Type)
                                 ,pr_respdado => vr_respdado -- Dados nternos do retorno (Parametro Data)
                                 ,pr_idsessao => vr_idsessao -- Id da Sessão no WS da PG  (Parâmetro SessionId)
                                 ,pr_dscritic => pr_dscritic -- Mensagem de erro retornada no WS
                                  );
    
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
    
      -- Se for FINISH pode finalizar o processo
      IF vr_resptipo = 2 THEN
        pr_finaliza := TRUE;
      END IF;
    
    EXCEPTION
      WHEN OTHERS THEN
        IF pr_dscritic IS NULL THEN
          pr_dscritic := 'Erro ao processar retorno: ' || SQLERRM;
        END IF;
    END pc_processa_retorno;
  
  BEGIN
  
    -- Chama o WebService
    pc_executa_webservice_pg(pr_nrservic => 3 -- Upload
                            ,pr_arqenvio => pr_nmarcnab
                            ,pr_idsessao => pr_idsessao
                            ,pr_arqreceb => vr_arqreceb
                            ,pr_dscritic => pr_dscritic);
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
    pc_processa_retorno;
  EXCEPTION
    WHEN OTHERS THEN
      --Se já possuir excessão das chamadas internas coloca
      --apenas o nome do método para nao ficar repetitivo
      IF pr_dscritic IS NOT NULL THEN
        pr_dscritic := 'Upload - ' || pr_dscritic;
      ELSE
        pr_dscritic := 'Erro ao fazer Upload do Arquivo: ' || SQLERRM;
      END IF;
      RETURN;
  END pc_ws_pg_upload;

  -- Faz o upload do arquivo CNAB
  PROCEDURE pc_ws_pg_download(pr_idsessao IN VARCHAR2 -- Id da Sessão no WS da PG
                             ,pr_nmarqret OUT VARCHAR2 -- Nome do arquivo de retorno
                             ,pr_dscritic OUT VARCHAR2) IS
  
    vr_resource CLOB; -- JSON gerado
    vr_arqreceb VARCHAR2(1000); -- Arquivo recebido (nome e diretório)
    vr_dirreceb VARCHAR2(1000); -- Nome do diretorio do arquivo recebido
  
    vr_arqcopia VARCHAR2(1000); -- Arquivo copiado (nome e diretório)
    vr_dircopia VARCHAR2(1000); -- Diretório para copiar o arquivo após receber
  
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
  
  BEGIN
  
    --Cria um json vazio para o POST
    vr_resource := '={}';
  
    -- Chama o WebService
    pc_executa_webservice_pg(pr_nrservic => 4 -- Download
                            ,pr_resource => vr_resource
                            ,pr_idsessao => pr_idsessao
                            ,pr_arqreceb => vr_arqreceb
                            ,pr_dscritic => pr_dscritic);
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  
    BEGIN
    
      -- Diretório /arq para copiar o arquivo
      vr_dircopia := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                          ,pr_cdcooper => 3
                                          ,pr_nmsubdir => '/arq');
    
      --Separar arquivo do path
      gene0001.pc_separa_arquivo_path(pr_caminho => vr_arqreceb --Arquivo Recebimento
                                     ,pr_direto  => vr_dirreceb --Nome Diretorio
                                     ,pr_arquivo => pr_nmarqret); --Nome Arquivo
    
      -- O nome permanece do arquivo recebido, muda o path para a pasta /arq
      vr_arqcopia := vr_dircopia || '/' || pr_nmarqret;
    
      -- Executa o comando para copiar o arquivo de uma pasta para a outra
      gene0001.pc_oscommand_shell('cp ' || vr_arqreceb || ' ' || vr_arqcopia);
    
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao copiar o arquivo recebido para a pasta /arq: ' || SQLERRM;
        RAISE vr_exc_saida;
    END;
  
  EXCEPTION
    WHEN OTHERS THEN
      --Se já possuir excessão das chamadas internas coloca
      --apenas o nome do método para nao ficar repetitivo
      IF pr_dscritic IS NOT NULL THEN
        pr_dscritic := 'Download - ' || pr_dscritic;
      ELSE
        pr_dscritic := 'Erro ao fazer Download do Arquivo: ' || SQLERRM;
      END IF;
      RETURN;
  END pc_ws_pg_download;

  -- Checa o estado de uma operação assíncrona
  PROCEDURE pc_ws_pg_checar_assincrono(pr_idsessao IN VARCHAR2 -- Id da Sessão no WS da PG
                                      ,pr_nrrepete IN OUT NUMBER -- Número da repetição da chamada
                                      ,pr_finaliza OUT BOOLEAN -- Indicador se finalizou a operação
                                      ,pr_dscritic OUT VARCHAR2) IS
  
    vr_resource CLOB; -- JSON gerado
    vr_arqreceb VARCHAR(1000); --Arquivo de resposta recebido do Perl
  
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
  
    --Processa retorno
    PROCEDURE pc_processa_retorno IS
    
      vr_resptipo NUMBER;
      vr_respdado CLOB;
      vr_idsessao VARCHAR2(100);
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
    
    BEGIN
      pr_finaliza := FALSE;
    
      --Processa o escopo externo da resposta
      pc_processa_retorno_servico(pr_arqreceb => vr_arqreceb -- Arquivo recebido por parâmetro
                                 ,pr_resptipo => vr_resptipo -- Numérico com o tipo da resposta (Parâmetro Type)
                                 ,pr_respdado => vr_respdado -- Dados nternos do retorno (Parametro Data)
                                 ,pr_idsessao => vr_idsessao -- Id da Sessão no WS da PG  (Parâmetro SessionId)
                                 ,pr_dscritic => pr_dscritic -- Mensagem de erro retornada no WS
                                  );
    
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
    
      -- Se for do tipo SEND_PROGRESS, significa que um serviço assincrono
      -- está em andamento, então deve repetir a chamada até finalizar
      IF vr_resptipo = 9 THEN
        pr_nrrepete := NVL(pr_nrrepete, 1) + 1;
      ELSIF vr_resptipo = 2 THEN
        -- Se finalizou
        pr_finaliza := TRUE;
      END IF;
    
    EXCEPTION
      WHEN OTHERS THEN
        IF pr_dscritic IS NULL THEN
          pr_dscritic := 'Erro ao processar retorno: ' || SQLERRM;
        END IF;
    END pc_processa_retorno;
  
  BEGIN
  
    --Envia a sessionID no POST
    vr_resource := '=' || pr_idsessao;
  
    -- Chama o WebService
    -- Neste serviço não precisa passar nem JSON nem arquivo, pois o Perl
    -- passa o SessionId no post da requisição
    pc_executa_webservice_pg(pr_nrservic => 5 -- Check Async Operation
                            ,pr_resource => vr_resource
                            ,pr_idsessao => pr_idsessao
                            ,pr_arqreceb => vr_arqreceb
                            ,pr_dscritic => pr_dscritic);
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  
    -- Processa o retorno
    pc_processa_retorno;
  
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      --Se já possuir excessão das chamadas internas coloca
      --apenas o nome do método para nao ficar repetitivo
      IF pr_dscritic IS NOT NULL THEN
        pr_dscritic := 'Checar Operação Assíncrona - ' || pr_dscritic;
      ELSE
        pr_dscritic := 'Erro ao checar operação Assíncrona: ' || SQLERRM;
      END IF;
      RETURN;
  END pc_ws_pg_checar_assincrono;

  -- Executa logística reversa e higienização e prepara o arquivo de retorno para o método download
  PROCEDURE pc_ws_pg_corrige_devolve(pr_nrdtoken IN VARCHAR2 -- Token de conexão com o WS da PG
                                    ,pr_dtjobini IN DATE -- Data de abertura do Job - Inicial
                                    ,pr_dtjobfim IN DATE -- Data de abertura do Job - Final
                                    ,pr_idsessao OUT VARCHAR2 -- Id da Sessão no WS da PG
                                    ,pr_finaliza OUT BOOLEAN -- Indicador se pode iniciar o download
                                    ,pr_dscritic OUT VARCHAR2) IS
  
    vr_resource CLOB; -- JSON gerado
    vr_arqreceb VARCHAR(1000); --Arquivo de resposta recebido do Perl
  
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
  
    --Gera o json para abrir um job para envio de arquivos ao webservice da PG
    PROCEDURE pc_gera_json IS
      vr_obj json := json();
    
    BEGIN
    
      vr_obj.put('StartDate', to_char(pr_dtjobini, vr_iso8601_format));
      vr_obj.put('EndDate', to_char(pr_dtjobfim, vr_iso8601_format));
      vr_obj.put('DateFilterType', 0); -- Data de criação do Job
    
      dbms_lob.createtemporary(vr_resource, TRUE);
      vr_obj.to_clob(vr_resource, FALSE);
    
      vr_resource := '=' || utl_url.escape(vr_resource); --Encripta o conteudo do CLOB
    
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao gerar JSON: ' || SQLERRM;
    END pc_gera_json;
  
    --Processa retorno
    PROCEDURE pc_processa_retorno IS
    
      vr_resptipo NUMBER;
      vr_respdado CLOB;
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
    
    BEGIN
    
      --Processa o escopo externo da resposta
      pc_processa_retorno_servico(pr_arqreceb => vr_arqreceb -- Arquivo recebido por parâmetro
                                 ,pr_resptipo => vr_resptipo -- Numérico com o tipo da resposta (Parâmetro Type)
                                 ,pr_respdado => vr_respdado -- Dados nternos do retorno (Parametro Data)
                                 ,pr_idsessao => pr_idsessao -- Id da Sessão no WS da PG  (Parâmetro SessionId)
                                 ,pr_dscritic => pr_dscritic -- Mensagem de erro retornada no WS
                                  );
    
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      -- Se for FINISH pode finalizar o processo
      IF vr_resptipo = 10 THEN

        pr_finaliza := TRUE;
      END IF;
    
    EXCEPTION
      WHEN OTHERS THEN
        IF pr_dscritic IS NULL THEN
          pr_dscritic := 'Erro ao processar retorno: ' || SQLERRM;
        END IF;
    END pc_processa_retorno;
  
  BEGIN
    -- Gera o JSON
    pc_gera_json;
  
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  
    -- Chama o WebService
    pc_executa_webservice_pg(pr_nrservic => 6 -- CorrectionAndDevolution
                            ,pr_nrdtoken => pr_nrdtoken
                            ,pr_resource => vr_resource
                            ,pr_arqreceb => vr_arqreceb
                            ,pr_dscritic => pr_dscritic);
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  
    -- Processa o retorno
    pc_processa_retorno;
  
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      --Se já possuir excessão das chamadas internas coloca
      --apenas o nome do método para nao ficar repetitivo
      IF pr_dscritic IS NOT NULL THEN
        pr_dscritic := 'Corrige e Devolve - ' || pr_dscritic;
      ELSE
        pr_dscritic := 'Erro ao executar Corrige e Devolve: ' || SQLERRM;
      END IF;
      RETURN;
  END pc_ws_pg_corrige_devolve;

  --Encerra a conexão com a PG
  PROCEDURE pc_ws_pg_logoff(pr_nrdtoken IN VARCHAR2
                           ,pr_dscritic OUT VARCHAR2) IS
  
    vr_resource CLOB; -- JSON gerado
    vr_arqreceb VARCHAR(1000); --Arquivo de resposta recebido do Perl
  
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
  
    --Processa retorno
    PROCEDURE pc_processa_retorno IS
    
      vr_resptipo NUMBER;
      vr_respdado CLOB;
      vr_idsessao VARCHAR2(100); -- Serve apenas para receber o OUT da procedure
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
    
    BEGIN
    
      --Processa o escopo externo da resposta
      pc_processa_retorno_servico(pr_arqreceb => vr_arqreceb -- Arquivo recebido por parâmetro
                                 ,pr_resptipo => vr_resptipo -- Numérico com o tipo da resposta (Parâmetro Type)
                                 ,pr_respdado => vr_respdado -- Dados nternos do retorno (Parametro Data)
                                 ,pr_idsessao => vr_idsessao -- Id da Sessão no WS da PG  (Parâmetro SessionId)
                                 ,pr_dscritic => pr_dscritic -- Mensagem de erro retornada no WS
                                  );
    
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
    
    EXCEPTION
      WHEN OTHERS THEN
        IF pr_dscritic IS NULL THEN
          pr_dscritic := 'Erro ao processar retorno: ' || SQLERRM;
        END IF;
    END pc_processa_retorno;
  
  BEGIN
  
    --Cria um json vazio para o POST
    vr_resource := '={}';
  
    -- Chama o WebService
    pc_executa_webservice_pg(pr_nrservic => 7 -- Logoff
                            ,pr_nrdtoken => pr_nrdtoken
                            ,pr_resource => vr_resource
                            ,pr_arqreceb => vr_arqreceb
                            ,pr_dscritic => pr_dscritic);
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  
    -- Processa o retorno
    pc_processa_retorno;
  
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      --Se já possuir excessão das chamadas internas coloca
      --apenas o nome do método para nao ficar repetitivo
      IF pr_dscritic IS NOT NULL THEN
        pr_dscritic := 'Logoff - ' || pr_dscritic;
      ELSE
        pr_dscritic := 'Erro ao efetuar Logoff: ' || SQLERRM;
      END IF;
      RETURN;
  END pc_ws_pg_logoff;

  --Abre conexão com o WebService e faz o upload do arquivo de remessa
  PROCEDURE pc_upload_webservice_pg(pr_nmarcnab IN VARCHAR2 -- Nome do arquivo CNAB de remessa
                                   ,pr_dscritic OUT VARCHAR2) IS

    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_upload_webservice_pg
    --  Sistema  : Procedimentos para  gerais da cobranca
    --  Sigla    : CRED
    --  Autor    : Dionathan Henchel
    --  Data     : Abril/2015.                   Ultima atualizacao: 12/12/2017
    --
    --  Alteracoes: 06/06/2017 - Inclusão de espera de tempo em segundos entre cada
    --                           comando que acessa o WS da PG para evitar o erro
    --                           "Referência de objeto não definida para uma instância de um objeto."
    --                           (SD#813103 - AJFink)
    ---------------------------------------------------------------------------------------------------------------

    vr_nrdtoken VARCHAR2(100); -- Token de conexão com o WS da PG
    vr_idsessao VARCHAR2(100); -- Id da Sessão no WS da PG
  
    vr_nrrepete NUMBER(2) := 10; -- Número das tentativas para busca do status do upload no webservice
    vr_finaliza BOOLEAN := FALSE; -- Indicador se finalizou busca do status do upload no webservice
  
    vr_qtsegund number(2);

    vr_exc_saida EXCEPTION;
  BEGIN
    
    -- Busca a hora atual para concatenar no nome dos arquivos
    vr_horaatua := to_char(SYSDATE, 'yymmddhh24miss');
    
    vr_qtsegund := nvl(gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                ,pr_cdacesso => 'PAINELWEBPG_DELAY'),'0');

    -- Autenticação
    pc_ws_pg_autenticacao(pr_nrdtoken => vr_nrdtoken
                         ,pr_dscritic => pr_dscritic);
  
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  
    pc_espera_segundo(pr_qtsegund => vr_qtsegund);

    -- Cria Job
    pc_ws_pg_cria_job(pr_nrdtoken => vr_nrdtoken -- Token de conexão com o WS da PG
                     ,pr_nmarcnab => pr_nmarcnab -- Nome do arquivo CNAB de remessa
                     ,pr_idsessao => vr_idsessao -- Id da Sessão no WS da PG
                     ,pr_dscritic => pr_dscritic);
  
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  
    pc_espera_segundo(pr_qtsegund => vr_qtsegund);

    -- Upload do arquivo
    pc_ws_pg_upload(pr_idsessao => vr_idsessao -- Id da Sessão no WS da PG
                   ,pr_nmarcnab => pr_nmarcnab -- Nome do arquivo CNAB de remessa
                   ,pr_finaliza => vr_finaliza --  Indicador se finalizou processo assíncrono (upload)
                   ,pr_dscritic => pr_dscritic);
  
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  
    pc_espera_segundo(pr_qtsegund => vr_qtsegund);

    -- Caso o upload ja retornou FINISH não precisa executar esta etapa, pula direto para o logoff
    IF NOT vr_finaliza THEN
    
      -- Checar operação assincrona (Verifica se upload foi bem sucedido)
      -- Busca com intervalos de 15 segundos, quando tiver retorno FINISH zera a variavel dispara exception
      WHILE vr_nrrepete > 0 LOOP
        pc_ws_pg_checar_assincrono(pr_idsessao => vr_idsessao -- Id da Sessão no WS da PG
                                  ,pr_nrrepete => vr_nrrepete -- Número da repetição para busca do status do processo assíncrono (upload)
                                  ,pr_finaliza => vr_finaliza -- Indicador se finalizou processo assíncrono
                                  ,pr_dscritic => pr_dscritic);
      
        -- Se finalizou sai do loop
        IF vr_finaliza THEN
          EXIT;
        END IF;
      
        IF pr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
      
        pc_espera_segundo(pr_qtsegund => vr_qtsegund);

        IF vr_nrrepete = 0 THEN
          pr_dscritic := 'Limite de tentativas de checagem de operação assíncrona atingido.';
          RAISE vr_exc_saida;
        END IF;
      END LOOP;
    END IF;
  
    pc_espera_segundo(pr_qtsegund => vr_qtsegund);

    --Logoff
    pc_ws_pg_logoff(pr_nrdtoken => vr_nrdtoken -- Token de conexão com o WS da PG
                   ,pr_dscritic => pr_dscritic);
  
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Ocorreu um erro ao enviar arquivo CNAB à PG: ' ||
                     NVL(pr_dscritic, SQLERRM);
  END pc_upload_webservice_pg;

  --Abre conexão com o WebService e faz o download do arquivo de retorno
  PROCEDURE pc_download_webservice_pg(pr_dtjobini IN DATE -- Data de abertura do Job - Inicial
                                     ,pr_dtjobfim IN DATE -- Data de abertura do Job - Final
                                     ,pr_nmarqret OUT VARCHAR2 -- Nome do arquivo baixado do webservice
                                     ,pr_dscritic OUT VARCHAR2) IS

    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_download_webservice_pg
    --  Sistema  : Procedimentos para  gerais da cobranca
    --  Sigla    : CRED
    --  Autor    : Dionathan Henchel
    --  Data     : Abril/2015.                   Ultima atualizacao: 06/06/2017
    --
    --  Alteracoes: 06/06/2017 - Inclusão de espera de tempo em segundos entre cada
    --                           comando que acessa o WS da PG para evitar o erro
    --                           "Referência de objeto não definida para uma instância de um objeto."
    --                           (SD#685796 - AJFink)
    ---------------------------------------------------------------------------------------------------------------
  
    vr_nrdtoken VARCHAR2(100); -- Token de conexão com o WS da PG
    vr_idsessao VARCHAR2(100); -- Id da Sessão no WS da PG
  
    vr_nrrepete NUMBER(2) := 10; -- Número das tentativas para busca do status do arquivo para download no webservice
    vr_finaliza BOOLEAN := FALSE; -- Indicador se pode iniciar o download
    
    vr_qtsegund number(2);
    
    vr_exc_saida EXCEPTION;

  BEGIN
    
    -- Busca a hora atual para concatenar no nome dos arquivos
    vr_horaatua := to_char(SYSDATE, 'yymmddhh24miss');

    vr_qtsegund := nvl(gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                ,pr_cdacesso => 'PAINELWEBPG_DELAY'),'0');

    -- Autenticação
    pc_ws_pg_autenticacao(pr_nrdtoken => vr_nrdtoken
                         ,pr_dscritic => pr_dscritic);
  
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
    
    pc_espera_segundo(pr_qtsegund => vr_qtsegund);
    
    -- Gera o arquivo para download
    pc_ws_pg_corrige_devolve(pr_nrdtoken => vr_nrdtoken -- Token de conexão com o WS da PG
                            ,pr_dtjobini => pr_dtjobini -- Data de abertura do Job - Inicial
                            ,pr_dtjobfim => pr_dtjobfim -- Data de abertura do Job - Final
                            ,pr_idsessao => vr_idsessao -- Id da Sessão no WS da PG
                            ,pr_finaliza => vr_finaliza
                            ,pr_dscritic => pr_dscritic);
  
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  
    pc_espera_segundo(pr_qtsegund => vr_qtsegund);
  
    IF NOT vr_finaliza THEN
    
      -- Checar operação assincrona (Verifica se a geração do arquivo foi bem sucedida)
      -- Busca com intervalos de 15 segundos, quando tiver retorno FINISH zera a variavel dispara exception
      WHILE vr_nrrepete > 0 LOOP
        pc_ws_pg_checar_assincrono(pr_idsessao => vr_idsessao -- Id da Sessão no WS da PG
                                  ,pr_nrrepete => vr_nrrepete -- Número da repetição para busca do status do processo assíncrono (geração arquivo)
                                  ,pr_finaliza => vr_finaliza -- Indicador se finalizou processo assíncrono
                                  ,pr_dscritic => pr_dscritic);
      
        -- Se finalizou sai do loop
        IF vr_finaliza THEN
          EXIT;
        END IF;
      
        IF pr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
      
        pc_espera_segundo(pr_qtsegund => vr_qtsegund);

        IF vr_nrrepete = 0 THEN
          pr_dscritic := 'Limite de tentativas de checagem de operação assíncrona atingido.';
          RAISE vr_exc_saida;
        END IF;
      END LOOP;
    END IF;
  
    pc_espera_segundo(pr_qtsegund => vr_qtsegund);
  
    -- Download do arquivo
    pc_ws_pg_download(pr_idsessao => vr_idsessao -- Id da Sessão no WS da PG
                     ,pr_nmarqret => pr_nmarqret -- Nome do arquivo de retorno
                     ,pr_dscritic => pr_dscritic);
  
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  
    pc_espera_segundo(pr_qtsegund => vr_qtsegund);
  
    --Logoff
    pc_ws_pg_logoff(pr_nrdtoken => vr_nrdtoken -- Token de conexão com o WS da PG
                   ,pr_dscritic => pr_dscritic);
  
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Ocorreu um erro ao enviar arquivo CNAB à PG: ' ||
                     NVL(pr_dscritic, SQLERRM);
  END pc_download_webservice_pg;

END cobr0004;
/
