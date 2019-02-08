create or replace package CECRED.INSS0004 is

  /*
  *   Procedure para realizar a consulta de margem consignável
  */
  PROCEDURE pc_margem_consignavel_inss(pr_cdcooper IN INTEGER             -- Codigo da Cooperativa        
                                          ,pr_nrdconta IN INTEGER         -- Numero da Conta          
                                          ,pr_cdorgins IN NUMBER          -- Codigo do Orgao Pagador  
                                          ,pr_nrbenefi IN NUMBER          -- Numero do Benefício      
                                          ,pr_cdcoptfn IN INTEGER         -- Cooperativa do TAA       
                                          ,pr_cdagetfn IN INTEGER         -- Agencia do TAA           
                                          ,pr_nrterfin IN INTEGER         -- Numero do TAA            
                                          ,pr_retorno OUT CLOB            -- XML da margem consignável
                                          ,pr_dsderror OUT VARCHAR2);     -- Mensagem de erro de saída

/*
*   Procedure para realizar a consulta de margem consignável
*/
PROCEDURE pc_extrato_emprestimo_inss(pr_cdcooper IN INTEGER             -- Codigo da Cooperativa
                                        ,pr_nrdconta IN INTEGER         -- Numero da Conta
                                        ,pr_cdorgins IN NUMBER          -- Codigo do Orgao Pagador
                                        ,pr_nrbenefi IN NUMBER          -- Numero do Benefício
                                        ,pr_cdcoptfn IN INTEGER         -- Cooperativa do TAA
                                        ,pr_cdagetfn IN INTEGER         -- Agencia do TAA
                                        ,pr_nrterfin IN INTEGER         -- Numero do TAA
                                        ,pr_retorno OUT CLOB            -- XML do extrato de emprestimo
                                        ,pr_dsderror OUT VARCHAR2);     -- Descrição do erro                                                

/* 
    *   Executar um comando no Host usando a interface com saída 
    */
PROCEDURE pc_OScommand_SHELL_INSS(pr_des_comando IN VARCHAR2
                                  ,pr_typ_saida  OUT VARCHAR2
                                  ,pr_des_saida  OUT VARCHAR2);
                                  
/*  
*   Realiza a requisição SOAP 
*/
PROCEDURE pc_envia_requisicao_soap (pr_xml_req IN VARCHAR2          -- Caminho do arquvio XML de requesição       
                                    ,pr_tpservico IN INTEGER        -- Tipo do servico          
                                    ,pr_xml_ret OUT XMLTYPE         -- XML de retorno da requisição
                                    ,pr_retorno OUT VARCHAR2        -- Saída OK/NOK
                                    ,pr_dsderror OUT VARCHAR2);   -- Mensagem de erro  
/*
*   Procedure para gerar os caminho dos arquivos XML da requisiçao (envio/retorno)
*/
PROCEDURE pc_gerar_caminho_arquivos_req(pr_cdcooper IN crapcop.cdcooper%type    -- Codigo Cooperativa
                                        ,pr_nrdconta IN VARCHAR2                -- Numero da Conta
                                        ,pr_tpservico IN INTEGER                -- Tipo do servico
                                        ,pr_msgenvio OUT VARCHAR2               -- Caminho absoluto do arquivo de envio
                                        ,pr_msgreceb OUT VARCHAR2               -- Caminho absoluto do arquivo de retorno
                                        ,pr_nmdireto OUT VARCHAR2               -- Caminho do diretório dos arquvios de envio e retorno    
                                        ,pr_retorno  OUT VARCHAR2);             -- Saída OK/NOK   
                                        
/* 
*   Gera o arquivo XML da requisicão 
*/
PROCEDURE pc_criar_arq_xml_requisicao(pr_caminho IN VARCHAR2             -- Diretório com o nome do arquivo que será salvo
                                     ,pr_nmmetodo IN VARCHAR2            -- Nome do método 
                                     ,pr_nmmetodo_in IN VARCHAR2         -- Nome do método In
                                     ,pr_canal IN VARCHAR2               -- Código do canal de atendimento
                                     ,pr_tpservico IN INTEGER             -- Tipo de servico
                                     ,pr_coop_origem IN NUMBER           -- Código da cooperativa que está realizando a consulta                                         
                                     ,pr_numero_beneficio IN NUMBER      -- Número do benificiário
                                     ,pr_orgao_pagador IN NUMBER         -- Número do orgão pagador
                                     ,pr_posto_origem IN NUMBER          -- Número do posto/UA que está realizando a consulta
                                     ,pr_usuario_origem IN VARCHAR2      -- Código do usuário que está realizando a consulta
                                     ,pr_retorno  OUT VARCHAR2           -- Saída OK/NOK
                                     ,pr_dsderror OUT VARCHAR2) ;        -- Mensagem de erro                                                             
                                     
/*
*   Procedure para gerar os caminho dos arquivos XML da requisiçao (envio/retorno)
*/
PROCEDURE pc_excluir_arq_xml_requisicao(pr_caminho IN VARCHAR2,      -- Diretório com o nome do arquivo que será salvo
                                        pr_retorno OUT VARCHAR2) ;  -- Saída OK/NOK                                     


/*
*   Procedure para pegar retorno xml
*/
PROCEDURE pc_pegar_retorno_xml(pr_orgao_pagador IN NUMBER          -- Código do orgão pagador
                              ,pr_xml_req IN XMLTYPE          -- XML de retorno da requisição
                              ,pr_dscritic OUT VARCHAR2       --Descricao da critica
                              ,pr_retorno OUT VARCHAR2);    -- Saída OK/NOK
                                
                                
end INSS0004;
/
create or replace package body cecred.INSS0004 is

    /*  
    *    Função para buscar a cooperativa de origem.
    */
    FUNCTION fn_get_coop_origem(pr_cdcoptfn IN NUMBER) RETURN NUMBER IS  -- Cooperativa do TAA
        vr_coop_origem NUMBER(10);
    BEGIN
        SELECT  a.cdagectl 
        INTO    vr_coop_origem
        FROM    crapcop a 
        WHERE   a.cdcooper = pr_cdcoptfn;

        RETURN vr_coop_origem;
    END fn_get_coop_origem;

    /*
    *   Monta a linha para ser adicionada ao XML
    */
    FUNCTION fn_adicionar_linha(pr_value IN VARCHAR2) RETURN VARCHAR2 IS    -- Monta linha para o XML
        vr_linha VARCHAR2(500);     
    BEGIN
        vr_linha := '<linha>' || RPAD(pr_value, 48,' ') || '</linha>';
        RETURN vr_linha;
    END fn_adicionar_linha;

    /*
    *   Adiciona linha com espacamento conforme tamanho do label
    */
    FUNCTION fn_adicionar_linha(pr_label IN VARCHAR2                        -- Descrição do valor
                                ,pr_value IN VARCHAR2) RETURN VARCHAR2 IS   -- Valor para ser adicionado
        vr_linha VARCHAR2(500);
        vr_espacamento INTEGER;
    BEGIN
        vr_espacamento := 48 - LENGTH(pr_label);

        vr_linha := '<linha>' || pr_label || LPAD(pr_value, vr_espacamento, ' ') || '</linha>';
        
        RETURN vr_linha;
    END fn_adicionar_linha;

    /*
    *   Retorna a data formatada em dd/mm/yyyy
    */
    FUNCTION fn_obter_data(pr_data IN VARCHAR2) RETURN VARCHAR2 IS  -- Valor a ser formatado
        vr_data VARCHAR2(10);
    BEGIN
        vr_data := to_char(TO_TIMESTAMP_TZ(pr_data, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM'), 'dd/mm/yyyy');
        RETURN vr_data;
    END fn_obter_data;

    /*
    *   Retorna a hora formatada em HH24:mi:ss
    */
    FUNCTION fn_obter_hora(pr_hora IN VARCHAR2) RETURN VARCHAR2 IS  -- Hora a ser formatada
        vr_hora VARCHAR2(8);
    BEGIN
        vr_hora := to_char(TO_TIMESTAMP_TZ(pr_hora, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM'), 'hh24:mi:ss');
        RETURN vr_hora;
    END fn_obter_hora;

    /* 
    *   Procedimento que serve de interface do Oracle para Java 
    */
    PROCEDURE pc_interface_OScommand_INSS(pr_des_script  IN VARCHAR2
                                        ,pr_typ_comando IN VARCHAR2
                                        ,pr_des_comando IN VARCHAR2)
        AS LANGUAGE JAVA NAME 'OSCommand.executeCommand(java.lang.String,java.lang.String,java.lang.String)';

    /* 
    *   Executar um comando no Host usando a interface com saída 
    */
    PROCEDURE pc_OScommand_SHELL_INSS(pr_des_comando IN VARCHAR2
                                    ,pr_typ_saida  OUT VARCHAR2
                                    ,pr_des_saida  OUT VARCHAR2) IS

        -- Busca da saída na DBMS_OUTPUT
        vr_dsout DBMS_OUTPUT.chararr;
        vr_qtlin INTEGER := 1000;
        
    BEGIN
    
        BEGIN
        -- Ativar a saida
        DBMS_OUTPUT.disable;
        DBMS_OUTPUT.enable(1000000);
        DBMS_JAVA.set_output(1000000);
        -- Efetuar a instrução passada diretamente no shell
        pc_interface_OScommand_INSS(gene0001.fn_param_sistema('CRED',0,'SCRIPT_EXEC_SHELL'),'shell',pr_des_comando);
        -- Armazenar o retorno
        DBMS_OUTPUT.get_lines(vr_dsout,vr_qtlin);
        -- Processar o retorno
        FOR vr_ind IN 1..vr_qtlin LOOP
            -- Na primeira interação
            IF vr_ind = 1 THEN
            -- Se o tamanho for superior a 3 bytes
            IF LENGTH(vr_dsout(vr_ind)) > 3 THEN
                -- Gerar erro
                pr_typ_saida := 'ERR';
                -- Incluir esta informação na saída
                pr_des_saida := pr_des_saida || vr_dsout(vr_ind) ||chr(10);
            ELSE
                -- Retorna o tipo da saída
                pr_typ_saida := vr_dsout(vr_ind);
            END IF;
            ELSE
            -- Adicionar na variável de retorno
            pr_des_saida := pr_des_saida || vr_dsout(vr_ind) ||chr(10);
            END IF;
        END LOOP;
        EXCEPTION
        WHEN OTHERS THEN
            pr_typ_saida := 'ERR';
            pr_des_saida := 'Erro geral INSS0004.pc_OScommand_SHELL_INSS: '||SQLERRM;
        END;

    END pc_OScommand_SHELL_INSS;

    /* 
    *   Procedure para obter o TOKEN para realização das requisições 
    */
    PROCEDURE pc_obter_token(pr_tpservico IN INTEGER        -- Tipo do servico          
                            ,pr_token OUT VARCHAR2          -- TOKEN para realização das requisições
                            ,pr_token_type OUT VARCHAR2     -- Tipo do TOKEN retornado
                            ,pr_retorno OUT VARCHAR2) IS    -- Saída OK/NOK
        vr_comando_curl     VARCHAR2(5000);

        vr_token            VARCHAR2(1000) := '';
        vr_token_type       VARCHAR2(50)   := ''; 

        vr_token_api        VARCHAR2(200);
        vr_cod_token_api    VARCHAR2(4000);
        vr_typ_saida        VARCHAR2(5000);
        vr_out              VARCHAR2(5000);
    BEGIN
        vr_cod_token_api := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                        pr_cdcooper => 0,
                                                      pr_cdacesso => 'COD_TOKEN_API_INSS');
        
        IF pr_tpservico = 1 THEN                                            
          vr_token_api := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                        pr_cdcooper => 0,
                                                        pr_cdacesso => 'TOKEN_API_ECO_INSS');
        ELSE
          vr_token_api := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                    pr_cdcooper => 0,
                                                    pr_cdacesso => 'TOKEN_API_REENV_CAD_INSS');
        END IF;

        vr_comando_curl := 'curl -k -X POST ' 
                            || '"'||vr_token_api||'"'
                            || ' -H "authorization: Basic eTFKZ05HYmNkcERmSzVMdXBxblY5c0l2aks4YTpFRUlIWGpfYnNmMEVMVk5CVjVuX0FrNVNmTThh"'
                            || ' -H "cache-control: no-cache"';
        
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                               ,pr_des_comando => vr_comando_curl
                               ,pr_typ_saida   => vr_typ_saida
                               ,pr_des_saida   => vr_out);                                    

        -- Extrai TOKEN do JSON de retorno
        vr_token := regexp_replace(json(vr_out).get('access_token').to_char,'^\"|\"$','');
        
        -- Extrai TOKEN do JSON de retorno
        vr_token_type := regexp_replace(json(vr_out).get('token_type').to_char,'^\"|\"$','');

        IF vr_token = '' THEN
            pr_retorno := 'NOK';
        END IF;   
        
        IF vr_token_type = '' THEN
            pr_retorno := 'NOK';
        END IF;

        pr_token := vr_token;
        pr_token_type := vr_token_type;
        pr_retorno := 'OK';
    END pc_obter_token;

    /* 
    *   Gera o arquivo XML da requisicão 
    */
    PROCEDURE pc_criar_arq_xml_requisicao(pr_caminho IN VARCHAR2             -- Diretório com o nome do arquivo que será salvo
                                         ,pr_nmmetodo IN VARCHAR2            -- Nome do método 
                                         ,pr_nmmetodo_in IN VARCHAR2         -- Nome do método In
                                         ,pr_canal IN VARCHAR2               -- Código do canal de atendimento
                                         ,pr_tpservico IN INTEGER             -- Tipo de servico
                                         ,pr_coop_origem IN NUMBER           -- Código da cooperativa que está realizando a consulta
                                         ,pr_numero_beneficio IN NUMBER      -- Número do benificiário
                                         ,pr_orgao_pagador IN NUMBER         -- Número do orgão pagador
                                         ,pr_posto_origem IN NUMBER          -- Número do posto/UA que está realizando a consulta
                                         ,pr_usuario_origem IN VARCHAR2      -- Código do usuário que está realizando a consulta
                                         ,pr_retorno  OUT VARCHAR2           -- Saída OK/NOK
                                         ,pr_dsderror OUT VARCHAR2) IS       -- Mensagem de erro
    vr_arquivo_saida    UTL_File.File_Type;
    vr_nmdireto         VARCHAR2(1000);
    vr_nmarquiv         VARCHAR2(1000);
    BEGIN
        --Separar o path do nome do arquivo de envio
        gene0001.pc_separa_arquivo_path(pr_caminho => pr_caminho
                                        ,pr_direto  => vr_nmdireto
                                        ,pr_arquivo => vr_nmarquiv);

        vr_arquivo_saida := UTL_File.Fopen(vr_nmdireto, vr_nmarquiv, 'w');
        
        IF pr_tpservico = 1 THEN
        UTL_File.Put_Line(vr_arquivo_saida, '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:eco="http://sicredi.com.br/inss/ws/v1/eco/">');
        UTL_File.Put_Line(vr_arquivo_saida, '<soapenv:Header/>');
        UTL_File.Put_Line(vr_arquivo_saida, '<soapenv:Body>');
        UTL_File.Put_Line(vr_arquivo_saida, '<eco:'||pr_nmmetodo||'>');
        UTL_File.Put_Line(vr_arquivo_saida, '<eco:'||pr_nmmetodo_in||'>');
        UTL_File.Put_Line(vr_arquivo_saida, '<canal>'||pr_canal||'</canal>');
        UTL_File.Put_Line(vr_arquivo_saida, '<coopOrigem>'||pr_coop_origem||'</coopOrigem>');
        UTL_File.Put_Line(vr_arquivo_saida, '<postoOrigem>'||pr_posto_origem||'</postoOrigem>');
        UTL_File.Put_Line(vr_arquivo_saida, '<usuarioOrigem>'||pr_usuario_origem||'</usuarioOrigem>');
        UTL_File.Put_Line(vr_arquivo_saida, '<numeroBeneficio>'||pr_numero_beneficio||'</numeroBeneficio>');
        UTL_File.Put_Line(vr_arquivo_saida, '<orgaoPagador>'||pr_orgao_pagador||'</orgaoPagador>');
        UTL_File.Put_Line(vr_arquivo_saida, '</eco:'||pr_nmmetodo_in||'>');
        UTL_File.Put_Line(vr_arquivo_saida, '</eco:'||pr_nmmetodo||'>');
        UTL_File.Put_Line(vr_arquivo_saida, '</soapenv:Body>');
        UTL_File.Put_Line(vr_arquivo_saida, '</soapenv:Envelope>');
        
        ELSE
          UTL_File.Put_Line(vr_arquivo_saida, '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ben="http://sicredi.com.br/convenios/cadastro/BeneficiarioINSS">');
          UTL_File.Put_Line(vr_arquivo_saida, '<soapenv:Header/>');
          UTL_File.Put_Line(vr_arquivo_saida, '<soapenv:Body>');      
          UTL_File.Put_Line(vr_arquivo_saida, '<ben:InReenviarCadastroBeneficiarioINSS>');
          UTL_File.Put_Line(vr_arquivo_saida, '<ben:orgaoPagador>' || pr_orgao_pagador ||'</ben:orgaoPagador>');
          UTL_File.Put_Line(vr_arquivo_saida, '<ben:codBeneficiario> ' || pr_numero_beneficio || '</ben:codBeneficiario>');
          UTL_File.Put_Line(vr_arquivo_saida, '</ben:InReenviarCadastroBeneficiarioINSS>'); 
          UTL_File.Put_Line(vr_arquivo_saida, '</soapenv:Body>');
          UTL_File.Put_Line(vr_arquivo_saida, '</soapenv:Envelope>');
          
        END IF;
        
        UTL_File.Fclose(vr_arquivo_saida);
        pr_retorno := 'OK';
    EXCEPTION
        WHEN UTL_FILE.INVALID_OPERATION THEN
                pr_dsderror := 'Operacao invalida no arquivo.';
                UTL_File.Fclose(vr_arquivo_saida);
                pr_retorno := 'NOK';
        WHEN UTL_FILE.WRITE_ERROR THEN
                pr_dsderror := 'Erro de gravacao no arquivo.';
                UTL_File.Fclose(vr_arquivo_saida);
                pr_retorno := 'NOK';
        WHEN UTL_FILE.INVALID_PATH THEN
                pr_dsderror := 'Diretorio invalido.';
                UTL_File.Fclose(vr_arquivo_saida);
                pr_retorno := 'NOK';
        WHEN UTL_FILE.INVALID_MODE THEN
                pr_dsderror := 'Modo de acesso invalido.';
                UTL_File.Fclose(vr_arquivo_saida);
                pr_retorno := 'NOK';
        WHEN OTHERS THEN
                pr_dsderror := 'Problemas na geracao do arquivo.';
                UTL_File.Fclose(vr_arquivo_saida);
                pr_retorno := 'NOK';
    END pc_criar_arq_xml_requisicao;

    /*
    *   Procedure para gerar os caminho dos arquivos XML da requisiçao (envio/retorno)
    */
    PROCEDURE pc_excluir_arq_xml_requisicao(pr_caminho IN VARCHAR2,      -- Diretório com o nome do arquivo que será salvo
                                            pr_retorno OUT VARCHAR2) IS  -- Saída OK/NOK
        vr_nmdireto         VARCHAR2(1000);
        vr_nmarquiv         VARCHAR2(1000);
    BEGIN 
        --Separar o path do nome do arquivo de envio
        gene0001.pc_separa_arquivo_path(pr_caminho => pr_caminho
                                        ,pr_direto  => vr_nmdireto
                                        ,pr_arquivo => vr_nmarquiv);

        UTL_FILE.FREMOVE(vr_nmdireto, vr_nmarquiv);

        pr_retorno := 'OK';
    EXCEPTION 
        WHEN OTHERS THEN
            Dbms_Output.Put_Line('Erro ao excluir arquivo XML da requisicao.');
            pr_retorno := 'NOK';
    END pc_excluir_arq_xml_requisicao;

    /*
    *   Procedure para gerar os caminho dos arquivos XML da requisiçao (envio/retorno)
    */
    PROCEDURE pc_gerar_caminho_arquivos_req(pr_cdcooper IN crapcop.cdcooper%type    -- Codigo Cooperativa
                                            ,pr_nrdconta IN VARCHAR2                -- Numero da Conta
                                            ,pr_tpservico IN INTEGER                -- Tipo do servico
                                            ,pr_msgenvio OUT VARCHAR2               -- Caminho absoluto do arquivo de envio
                                            ,pr_msgreceb OUT VARCHAR2               -- Caminho absoluto do arquivo de retorno
                                            ,pr_nmdireto OUT VARCHAR2               -- Caminho do diretório dos arquvios de envio e retorno    
                                            ,pr_retorno  OUT VARCHAR2) IS           -- Saída OK/NOK
    
    vr_nmdireto VARCHAR2(1000);
    vr_msgenvio VARCHAR2(32767);
    vr_msgreceb VARCHAR2(32767);
    vr_dtmvtolt VARCHAR2(100);
    vr_dstime   VARCHAR2(100);
    
    BEGIN
        -- Inicialização de variáveis
        vr_dtmvtolt := to_char(SYSDATE,'DDMMYYYYHHMISS');
        vr_dstime := lpad(gene0002.fn_busca_time,5,'0');

        -- Gera o caminho do diretório em que os arquivos ficaram armazenados
        vr_nmdireto:= gene0001.fn_diretorio (pr_tpdireto => 'C' --> Usr/Coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => null);
        
        
        IF pr_tpservico = 1 THEN
        -- Cria nome do arquivo de envio
        vr_msgenvio := vr_nmdireto 
                        || '/arq/INSS.SOAP.ERELAPG'
                        || vr_dtmvtolt
                        || vr_dstime
                        || pr_nrdconta; 

        --Determinar Nome do Arquivo de Recebimento    
        vr_msgreceb:= vr_nmdireto||'/arq/INSS.SOAP.RRELAPG'
                        || vr_dtmvtolt
                        || vr_dstime
                        || pr_nrdconta;
        ELSE
          -- Cria nome do arquivo de envio
          vr_msgenvio := vr_nmdireto 
                          || '/arq/INSS.SOAP.EREVCAD'
                          || vr_dtmvtolt
                          || vr_dstime
                          || pr_nrdconta; 

          --Determinar Nome do Arquivo de Recebimento    
          vr_msgreceb:= vr_nmdireto||'/arq/INSS.SOAP.RREVCAD'
                          || vr_dtmvtolt
                          || vr_dstime
                          || pr_nrdconta;
        
        END IF;
                          
        pr_msgenvio := vr_msgenvio;
        pr_msgreceb := vr_msgreceb;
        pr_nmdireto := vr_nmdireto;
        pr_retorno := 'OK';
        
    EXCEPTION 
        WHEN OTHERS THEN
            pr_retorno := 'NOK';
    END pc_gerar_caminho_arquivos_req;    


    /*  
    *   Realiza a requisição SOAP 
    */
    PROCEDURE pc_envia_requisicao_soap (pr_xml_req IN VARCHAR2          -- Caminho do arquvio XML de requesição           
                                        ,pr_tpservico IN INTEGER        -- Tipo do servico      
                                        ,pr_xml_ret OUT XMLTYPE         -- XML de retorno da requisição
                                        ,pr_retorno OUT VARCHAR2        -- Saída OK/NOK
                                        ,pr_dsderror OUT VARCHAR2) IS   -- Mensagem de erro 
        vr_comando_curl VARCHAR2(32000);
        vr_typ_saida    VARCHAR2(5000);
        vr_out          VARCHAR2(32000);
        vr_token        VARCHAR2(200);      -- Armazena o TOKEN para a requsição SOAP       
        vr_token_type   VARCHAR2(50);       -- Armazena o tipo do TOKEN para a requisição SOAP
        
        vr_link_api     VARCHAR2(200);

        vr_retorno      VARCHAR2(3);
        vr_exception    EXCEPTION;
    BEGIN    
        pc_obter_token(pr_tpservico => pr_tpservico
                        ,pr_token => vr_token
                        ,pr_token_type => vr_token_type
                        ,pr_retorno => vr_retorno);

        IF vr_retorno = 'NOK' THEN
            pr_dsderror := 'Erro ao obter TOKEN';
            RAISE vr_exception;
        END IF;

        IF pr_tpservico = 1 THEN
          
          vr_link_api := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                        pr_cdcooper => 0,
                                                        pr_cdacesso => 'LINK_API_ECO_INSS');
        ELSE
          vr_link_api := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                   pr_cdcooper => 0,
                                                   pr_cdacesso => 'LINK_API_REENV_CAD_INSS'); 
        END IF;

        IF vr_link_api = '' THEN
            pr_dsderror := 'Erro ao obter API do servico SOAP';
            RAISE vr_exception;
        END IF;

        vr_comando_curl := 'curl -k -X POST ' 
                            || '"'||vr_link_api||'"'
                            || ' -H "authorization: '||vr_token_type||' '|| vr_token ||'"'
                            || ' -H "cache-control: no-cache"'
                            || ' -H "content-type: text/xml"'
                            || ' -H "charset: UTF-8"'
                            || ' -d "@'|| pr_xml_req ||'"';
                            
        pc_OScommand_SHELL_INSS(pr_des_comando => vr_comando_curl
                               ,pr_typ_saida   => vr_typ_saida
                               ,pr_des_saida   => vr_out);                                    

        pr_xml_ret := XMLTYPE(vr_out);
        pr_retorno := 'OK';
    EXCEPTION 
        WHEN OTHERS THEN
            pr_retorno := 'NOK';
    END pc_envia_requisicao_soap;

    /*
  *   Procedure para pegar retorno xml
  */
  PROCEDURE pc_pegar_retorno_xml(pr_orgao_pagador IN NUMBER          -- Código do orgão pagador
                                ,pr_xml_req IN XMLTYPE          -- XML de retorno da requisição
                                ,pr_dscritic OUT VARCHAR2       --Descricao da critica
                                ,pr_retorno OUT VARCHAR2) IS    -- Saída OK/NOK
                                          
      -- Variável utilizada para montagem do XML
      vr_des_retorno      VARCHAR2(5000);
      -- Variaveis DOM
      vr_xmldoc           XMLDOM.DOMDocument;
      vr_lista_nodo       DBMS_XMLDOM.DOMNodelist;
      vr_nodo             xmldom.DOMNode;
      
      vr_dscritic VARCHAR2(32767);
      vr_cdderror VARCHAR2(32767);
      vr_dsderror VARCHAR2(32767);
      
      --Variável controle do xml
      vr_xmlparser  dbms_xmlparser.Parser;
      
      
  BEGIN
       
      -- Realizar o parse do arquivo XML
      vr_xmldoc := XMLDOM.newDOMDocument(pr_xml_req);

      --Lista de nodos
      vr_lista_nodo:= xmldom.getElementsByTagName(vr_xmldoc,'faultstring');
      
      -- Tratamento adicional para verificação se retornou falha, pois qnd retorna com sucesso
      -- o arquivo ultrapassa o limite de tamanho suportado pelo dbms_xmlparser.parse;       
      IF xmldom.getLength(vr_lista_nodo) > 0 THEN 
          
        --Buscar o item
        vr_nodo:= DBMS_XMLDOM.item(vr_lista_nodo,0);
          
        --Buscar o Filho
        vr_nodo:= xmldom.getFirstChild(vr_nodo);
          
        --Codigo do Erro
        vr_cdderror:= SUBSTR(dbms_xmldom.getnodevalue(vr_nodo),1,4);
          
        --Descricao do erro
        vr_dsderror:= dbms_xmldom.getnodevalue(vr_nodo);
                    
        --Se possui erro
        IF vr_dsderror IS NOT NULL THEN 
          pr_dscritic:= vr_dsderror;
        ELSE
          pr_dscritic:= NULL;
        END IF;           

        --Retorno Nao OK
        pr_retorno:= 'NOK';
           
      ELSE                 
        --Retorno OK  
        pr_retorno:= 'OK';    
      END IF;       
    
  EXCEPTION
      WHEN OTHERS THEN
          pr_retorno := 'NOK';

  END pc_pegar_retorno_xml;
  
    /*
    *   Procedure para montar o XML de retorno da consulta de margem consignável
    */
    PROCEDURE pc_gerar_xml_cons_marg_consig(pr_orgao_pagador IN NUMBER          -- Código do orgão pagador
                                                ,pr_xml_req IN XMLTYPE          -- XML de retorno da requisição
                                                ,pr_xml_ret OUT CLOB            -- XML gerado para
                                                ,pr_retorno OUT VARCHAR2) IS    -- Saída OK/NOK
        -- Variável utilizada para montagem do XML
        vr_des_retorno      VARCHAR2(5000);
        -- Variáveis utilizadas para ler o XML do request
        vr_node_name        VARCHAR2(100);
        vr_lenght           NUMBER;
        -- Variaveis DOM
        vr_xmldoc           XMLDOM.DOMDocument;
        vr_item_node        XMLDOM.DOMNode;
        vr_node_list        DBMS_XMLDOM.DOMNodelist;

        -- Variáveis para montagem do XML de retorno da consulta
        vr_data_hora                            VARCHAR2(50);
        vr_nome_beneficiario                    VARCHAR2(50);
        vr_numero_beneficio                     VARCHAR2(50);
        vr_especie                              VARCHAR2(50);
        vr_tipo_credito                         VARCHAR2(50);
        vr_situacao_beneficio                   VARCHAR2(50);
        vr_representante_legal                  VARCHAR2(50);
        vr_pensao_alimenticia                   VARCHAR2(50);
        vr_bloqueado_emprestimo                 VARCHAR2(50);
        vr_conta_beneficiario                   VARCHAR2(50);
        vr_agencia_beneficiario                 VARCHAR2(50);

        vr_margem_consi_disponi                 VARCHAR2(50);
        vr_margem_consi_disponi_cart            VARCHAR2(50);

    BEGIN
        -- Realizar o parse do arquivo XML
        vr_xmldoc := XMLDOM.newDOMDocument(pr_xml_req);

        -- Obtém todas as tags do arquivo XML   
        vr_node_list := XMLDOM.getElementsByTagName(vr_xmldoc, '*');
        vr_lenght := XMLDOM.getLength(vr_node_list);
        
        -- Faz a leitura do XML do request e já monta o XML da consulta                            
        FOR i IN 0..vr_lenght-1 LOOP
            -- Pega o item
            vr_item_node := xmldom.item(vr_node_list, i);

            -- Captura o nome do nodo
            vr_node_name := xmldom.getNodeName(vr_item_node);

            IF vr_node_name = 'dataHoraTransacao' THEN
                vr_data_hora := Dbms_Xmldom.Getnodevalue(dbms_xmldom.getFirstChild(vr_item_node));
            ELSIF vr_node_name = 'nomeBeneficiario' THEN
                vr_nome_beneficiario := Dbms_Xmldom.Getnodevalue(dbms_xmldom.getFirstChild(vr_item_node));
            ELSIF vr_node_name = 'numeroBeneficio' THEN
                vr_numero_beneficio := Dbms_Xmldom.Getnodevalue(dbms_xmldom.getFirstChild(vr_item_node));
            ELSIF vr_node_name = 'especie' THEN
                vr_especie :=  Dbms_Xmldom.Getnodevalue(dbms_xmldom.getFirstChild(vr_item_node));
            ELSIF vr_node_name = 'tipoCredito' THEN
                vr_tipo_credito := Dbms_Xmldom.Getnodevalue(dbms_xmldom.getFirstChild(vr_item_node));
            ELSIF vr_node_name = 'situacaoBeneficio' THEN
                vr_situacao_beneficio := Dbms_Xmldom.Getnodevalue(dbms_xmldom.getFirstChild(vr_item_node));
            ELSIF vr_node_name = 'representanteLegal' THEN
                vr_representante_legal := Dbms_Xmldom.Getnodevalue(dbms_xmldom.getFirstChild(vr_item_node));
            ELSIF vr_node_name = 'pensaoAlimenticia' THEN
                vr_pensao_alimenticia := Dbms_Xmldom.Getnodevalue(dbms_xmldom.getFirstChild(vr_item_node));
            ELSIF vr_node_name = 'bloqueadoEmprestimo' THEN
                vr_bloqueado_emprestimo := Dbms_Xmldom.Getnodevalue(dbms_xmldom.getFirstChild(vr_item_node));
            ELSIF vr_node_name = 'margemConsignavelDisponivel' THEN
                vr_margem_consi_disponi := Dbms_Xmldom.Getnodevalue(dbms_xmldom.getFirstChild(vr_item_node));
            ELSIF vr_node_name = 'margemConsignavelDisponivelCartao' THEN
                vr_margem_consi_disponi_cart := Dbms_Xmldom.Getnodevalue(dbms_xmldom.getFirstChild(vr_item_node));
            ELSIF vr_node_name = 'contaBeneficiarioAgencia' THEN
                vr_agencia_beneficiario := Dbms_Xmldom.Getnodevalue(dbms_xmldom.getFirstChild(vr_item_node));
            ELSIF vr_node_name = 'contaBeneficiarioNumConta' THEN
                vr_conta_beneficiario := Dbms_Xmldom.Getnodevalue(dbms_xmldom.getFirstChild(vr_item_node));    
            END IF;

        END LOOP;
        
        vr_des_retorno := '<Raiz>'
                        || '<comprovante>'
                        || fn_adicionar_linha('   BANCO: 748 - Banco Cooperativo Sicredi S.A.  ')
                        || fn_adicionar_linha(' Cooperativa: 9999 - SICREDI')    
                        || fn_adicionar_linha(' Orgao pagador: '||pr_orgao_pagador)
                        || fn_adicionar_linha(' Data:'||fn_obter_data(vr_data_hora)||'                  Hora:'||fn_obter_hora(vr_data_hora))
                        || fn_adicionar_linha('------------------------------------------------')
                        || fn_adicionar_linha('          CONSULTA MARGEM CONSIGNAVEL           ')
                        || fn_adicionar_linha(' FONTE PAGADORA: INST. NACIONAL DO SEGURO SOCIAL ')
                        || fn_adicionar_linha(' CNPJ: 29.979.036/0001-40                        ')
                        || fn_adicionar_linha('------------------------------------------------')
                        
                        || fn_adicionar_linha(' BENEFICIARIO: '|| vr_nome_beneficiario)
                        || fn_adicionar_linha(' NUMERO DO NB: '|| vr_numero_beneficio)
                        || fn_adicionar_linha(' ESPECIE: '|| UPPER(vr_especie))
                        || fn_adicionar_linha(' TIPO DE CREDITO: '|| UPPER(vr_tipo_credito))
                        || fn_adicionar_linha(' SITUACAO: '|| UPPER(vr_situacao_beneficio))
                        
                        || fn_adicionar_linha(' BANCO: 748  AGENCIA:'||vr_agencia_beneficiario||'  CONTA:'||vr_conta_beneficiario)
                        
                        || fn_adicionar_linha(' REPRESENTANTE LEGAL:', UPPER(vr_representante_legal))
                        || fn_adicionar_linha(' PENSAO ALIMENTICIA:', UPPER(vr_pensao_alimenticia))
                        || fn_adicionar_linha(' BLOQUEADO PARA EMPRESTIMO:', UPPER(vr_bloqueado_emprestimo))
                        || fn_adicionar_linha(' MARGEM CONSIGNAVEL - EMPRESTIMO:', TO_CHAR(TO_NUMBER(vr_margem_consi_disponi, '99999999999.99'), 'FM999G999G990D90'))
                        || fn_adicionar_linha(' MARGEM CONSIGNAVEL - CARTAO:', TO_CHAR(TO_NUMBER(vr_margem_consi_disponi_cart, '99999999999.99'), 'FM999G999G990D90'))
                        
                        || fn_adicionar_linha('------------------------------------------------')
                        || fn_adicionar_linha(' As informacoes foram fornecidas em '||fn_obter_data(vr_data_hora))
                        || fn_adicionar_linha(' e sao de responsabilidade do INSS. Havendo     ')
                        || fn_adicionar_linha(' duvidas quanto ao conteudo deste documento, ')
                        || fn_adicionar_linha(' entre em contato com a Previdencia Social pelo')
                        || fn_adicionar_linha(' telefone 135.')

                        || '</comprovante>'
                        || '</Raiz>';

        
        -- Gera XML de retorno
        pr_xml_ret := XMLTYPE(vr_des_retorno).getClobVal();
    
        pr_retorno := 'OK';
    EXCEPTION
        WHEN OTHERS THEN
            pr_retorno := 'NOK';

    END pc_gerar_xml_cons_marg_consig;

    /*
    *   Procedure para montar o XML de retorno da rotina de extrato emprestimos
    */
    PROCEDURE pc_gerar_xml_extr_empr(pr_orgao_pagador IN NUMBER     -- Código do orgão pagador
                                    ,pr_xml_req IN XMLTYPE          -- XML de retorno da requisição
                                    ,pr_xml_ret OUT CLOB            -- XML gerado para
                                    ,pr_retorno OUT VARCHAR2) IS    -- Saída OK/NOK 
        -- Variável utilizada para montagem do XML
        vr_des_retorno      VARCHAR2(32000);
        
        -- Variáveis utilizadas para ler o XML do request
        vr_node_name        VARCHAR2(100);
        vr_lenght           NUMBER;
        
        -- Variaveis DOM
        vr_xmldoc               XMLDOM.DOMDocument;
        vr_item_node            XMLDOM.DOMNode;
        
        vr_node_list            DBMS_XMLDOM.DOMNodelist;
        vr_lista_emprestimos    XMLDOM.DOMNodeList;
        vr_emprestimos          XMLDOM.DOMNodeList;
        vr_lista_cartoes        XMLDOM.DOMNodeList;
        vr_cartoes              XMLDOM.DOMNodeList;

        vr_elemento   XMLDOM.DOMElement;

        -- Comprovante banco
        vr_extrato_emprestimo VARCHAR2(7000) := NULL;
        vr_cartoes_consignados VARCHAR2(7000) := NULL;

        -- Variáveis para montagem do XML de retorno da consulta
        vr_data_hora                            VARCHAR2(50);
        vr_nome_beneficiario                    VARCHAR2(50);
        vr_numero_beneficio                     VARCHAR2(50);
        vr_especie                              VARCHAR2(50);
        vr_tipo_credito                         VARCHAR2(50);
        vr_situacao_beneficio                   VARCHAR2(50);
        vr_representante_legal                  VARCHAR2(50);
        vr_pensao_alimenticia                   VARCHAR2(50);
        vr_bloqueado_emprestimo                 VARCHAR2(50);
        vr_conta_beneficiario                   VARCHAR2(50);
        vr_agencia_beneficiario                 VARCHAR2(50);
        vr_margem_consi_disponi                 VARCHAR2(50);
        vr_margem_consi_disponi_cart            VARCHAR2(50);
    BEGIN

        -- Realizar o parse do arquivo XML
        vr_xmldoc := XMLDOM.newDOMDocument(pr_xml_req);

        --Lista de emprestimos
        vr_lista_emprestimos := xmldom.getElementsByTagName(vr_xmldoc,'listaEmprestimos');
        FOR i IN 0..(xmldom.getLength(vr_lista_emprestimos) -1) LOOP

            vr_item_node := xmldom.item(vr_lista_emprestimos, i);
            vr_elemento  := xmldom.makeElement(vr_item_node);
            vr_emprestimos := xmldom.getChildrenByTagName(vr_elemento,'emprestimo');  

            FOR j IN 0..(xmldom.getLength(vr_emprestimos) -1) LOOP
                --Buscar Nodo Corrente
                vr_item_node := xmldom.item(vr_emprestimos, j);
                vr_elemento  := xmldom.makeElement(vr_item_node);
                -- Obtém todas as tags do arquivo XML   
                vr_node_list := XMLDOM.getElementsByTagName(vr_elemento, '*');
                
                
                -- Acessa node BANCO
                vr_item_node := xmldom.item(vr_node_list, 0);
                
                vr_extrato_emprestimo := vr_extrato_emprestimo  
                                            || fn_adicionar_linha(' BANCO: ' 
                                                                || Dbms_Xmldom.Getnodevalue(dbms_xmldom.getFirstChild(xmldom.item(vr_node_list, 0)))
                                                                || ' '
                                                                || Dbms_Xmldom.Getnodevalue(dbms_xmldom.getFirstChild(xmldom.item(vr_node_list, 3))))
                
                                            || fn_adicionar_linha(' CONTRATO: ' 
                                                                || Dbms_Xmldom.Getnodevalue(dbms_xmldom.getFirstChild(xmldom.item(vr_node_list, 8))))
                                                                
                                            || fn_adicionar_linha(' DATA INICIO/FIM DESCONTO: '
                                                                    ||to_char(to_date(Dbms_Xmldom.Getnodevalue(dbms_xmldom.getFirstChild(xmldom.item(vr_node_list, 6))),  'yyyymm'), 'mm/yyyy')
                                                                    ||' - '
                                                                    ||to_char(to_date(Dbms_Xmldom.Getnodevalue(dbms_xmldom.getFirstChild(xmldom.item(vr_node_list, 5))),  'yyyymm'), 'mm/yyyy'))
                                            || fn_adicionar_linha(' DATA INCLUSAO: ' || fn_obter_data(Dbms_Xmldom.Getnodevalue(dbms_xmldom.getFirstChild(xmldom.item(vr_node_list, 1)))))
                                            || fn_adicionar_linha(' VALOR EMPRESTADO: ' || TO_CHAR(TO_NUMBER(Dbms_Xmldom.Getnodevalue(dbms_xmldom.getFirstChild(xmldom.item(vr_node_list, 10))), '9999999999999.99'), 'FM999G999G990D90'))
                                            || fn_adicionar_linha(' VALOR PARCELA: ' || TO_CHAR(TO_NUMBER(Dbms_Xmldom.Getnodevalue(dbms_xmldom.getFirstChild(xmldom.item(vr_node_list, 11))), '9999999999999.99'), 'FM999G999G990D90'))
                                            || fn_adicionar_linha(' PARCELA: ' || Dbms_Xmldom.Getnodevalue(dbms_xmldom.getFirstChild(xmldom.item(vr_node_list, 9))))
                                            || fn_adicionar_linha('------------------------------------------------');
                                            
                vr_node_name := xmldom.getNodeName(vr_item_node);
                
            END LOOP;
            
        END LOOP;

        --Lista de Cartões consignados
        vr_lista_cartoes := xmldom.getElementsByTagName(vr_xmldoc,'listaCartoes');
        FOR i IN 0..(xmldom.getLength(vr_lista_cartoes) -1) LOOP

            vr_item_node := xmldom.item(vr_lista_cartoes, i);
            vr_elemento  := xmldom.makeElement(vr_item_node);
            vr_cartoes := xmldom.getChildrenByTagName(vr_elemento,'cartao');  

            FOR j IN 0..(xmldom.getLength(vr_cartoes) -1) LOOP
                --Buscar Nodo Corrente
                vr_item_node := xmldom.item(vr_cartoes, j);
                vr_elemento  := xmldom.makeElement(vr_item_node);
                -- Obtém todas as tags do arquivo XML   
                vr_node_list := XMLDOM.getElementsByTagName(vr_elemento, '*');
                
                vr_cartoes_consignados := vr_cartoes_consignados
                                            || fn_adicionar_linha(' BANCO: ' 
                                                                || Dbms_Xmldom.Getnodevalue(dbms_xmldom.getFirstChild(xmldom.item(vr_node_list, 0)))
                                                                || ' '
                                                                || Dbms_Xmldom.Getnodevalue(dbms_xmldom.getFirstChild(xmldom.item(vr_node_list, 3))))
                
                                            || fn_adicionar_linha(' CONTRATO: ' 
                                                                || Dbms_Xmldom.Getnodevalue(dbms_xmldom.getFirstChild(xmldom.item(vr_node_list, 5))))
                                                                
                                            || fn_adicionar_linha(' INICIO CONTRATO: '|| fn_obter_data(Dbms_Xmldom.Getnodevalue(dbms_xmldom.getFirstChild(xmldom.item(vr_node_list, 2)))))
                                            || fn_adicionar_linha(' DATA INCLUSAO: '|| fn_obter_data(Dbms_Xmldom.Getnodevalue(dbms_xmldom.getFirstChild(xmldom.item(vr_node_list, 1)))))
                                            || fn_adicionar_linha(' SITUACAO: ' || Dbms_Xmldom.Getnodevalue(dbms_xmldom.getFirstChild(xmldom.item(vr_node_list, 4))))
                                            || fn_adicionar_linha(' VALOR RESERVADO: ' || TO_CHAR(TO_NUMBER(Dbms_Xmldom.Getnodevalue(dbms_xmldom.getFirstChild(xmldom.item(vr_node_list, 6))), '9999999999999.99'), 'FM999G999G990D90'))
                                            || fn_adicionar_linha('------------------------------------------------');
                
                vr_node_name := xmldom.getNodeName(vr_item_node);
                
            END LOOP;
            
        END LOOP;

        -- Obtém todas as tags do arquivo XML   
        vr_node_list := XMLDOM.getElementsByTagName(vr_xmldoc, '*');
        vr_lenght := XMLDOM.getLength(vr_node_list);
        
        -- Faz a leitura do XML do request e já monta o XML da consulta                            
        FOR i IN 0..vr_lenght-1 LOOP
            -- Pega o item
            vr_item_node := xmldom.item(vr_node_list, i);

            -- Captura o nome do nodo
            vr_node_name := xmldom.getNodeName(vr_item_node);

            IF vr_node_name = 'dataHoraTransacao' THEN
                vr_data_hora := Dbms_Xmldom.Getnodevalue(dbms_xmldom.getFirstChild(vr_item_node));
            ELSIF vr_node_name = 'nomeBeneficiario' THEN
                vr_nome_beneficiario := Dbms_Xmldom.Getnodevalue(dbms_xmldom.getFirstChild(vr_item_node));
            ELSIF vr_node_name = 'numeroBeneficio' THEN
                vr_numero_beneficio := Dbms_Xmldom.Getnodevalue(dbms_xmldom.getFirstChild(vr_item_node));
            ELSIF vr_node_name = 'especie' THEN
                vr_especie :=  Dbms_Xmldom.Getnodevalue(dbms_xmldom.getFirstChild(vr_item_node));
            ELSIF vr_node_name = 'tipoCredito' THEN
                vr_tipo_credito := Dbms_Xmldom.Getnodevalue(dbms_xmldom.getFirstChild(vr_item_node));
            ELSIF vr_node_name = 'situacaoBeneficio' THEN
                vr_situacao_beneficio := Dbms_Xmldom.Getnodevalue(dbms_xmldom.getFirstChild(vr_item_node));
            ELSIF vr_node_name = 'representanteLegal' THEN
                vr_representante_legal := Dbms_Xmldom.Getnodevalue(dbms_xmldom.getFirstChild(vr_item_node));
            ELSIF vr_node_name = 'pensaoAlimenticia' THEN
                vr_pensao_alimenticia := Dbms_Xmldom.Getnodevalue(dbms_xmldom.getFirstChild(vr_item_node));
            ELSIF vr_node_name = 'bloqueadoEmprestimo' THEN
                vr_bloqueado_emprestimo := Dbms_Xmldom.Getnodevalue(dbms_xmldom.getFirstChild(vr_item_node));
            ELSIF vr_node_name = 'margemConsignavelDisponivel' THEN
                vr_margem_consi_disponi := Dbms_Xmldom.Getnodevalue(dbms_xmldom.getFirstChild(vr_item_node));
            ELSIF vr_node_name = 'margemConsignavelDisponivelCartao' THEN
                vr_margem_consi_disponi_cart := Dbms_Xmldom.Getnodevalue(dbms_xmldom.getFirstChild(vr_item_node));
            ELSIF vr_node_name = 'contaBeneficiarioAgencia' THEN
                vr_agencia_beneficiario := Dbms_Xmldom.Getnodevalue(dbms_xmldom.getFirstChild(vr_item_node));
            ELSIF vr_node_name = 'contaBeneficiarioNumConta' THEN
                vr_conta_beneficiario := Dbms_Xmldom.Getnodevalue(dbms_xmldom.getFirstChild(vr_item_node));    
            END IF;

        END LOOP;

        vr_des_retorno := '<Raiz>'
                        || '<comprovante>'
                        || fn_adicionar_linha('   BANCO: 748 - Banco Cooperativo Sicredi S.A.  ')
                        || fn_adicionar_linha(' Cooperativa: 9999 - SICREDI')    
                        || fn_adicionar_linha(' Orgao pagador: '||pr_orgao_pagador)
                        || fn_adicionar_linha(' Data:'||fn_obter_data(vr_data_hora)||'                  Hora:'||fn_obter_hora(vr_data_hora))
                        || fn_adicionar_linha('------------------------------------------------')
                        || fn_adicionar_linha('            EXTRATO DE CONSIGNACAO              ')
                        || fn_adicionar_linha(' FONTE PAGADORA: INST. NACIONAL DO SEGURO SOCIAL ')
                        || fn_adicionar_linha(' CNPJ: 29.979.036/0001-40                        ')
                        || fn_adicionar_linha('------------------------------------------------')
                        
                        || fn_adicionar_linha(' BENEFICIARIO: '|| vr_nome_beneficiario)
                        || fn_adicionar_linha(' NUMERO DO NB: '|| vr_numero_beneficio)
                        || fn_adicionar_linha(' ESPECIE: '|| UPPER(vr_especie))
                        || fn_adicionar_linha(' TIPO DE CREDITO: '|| UPPER(vr_tipo_credito))
                        || fn_adicionar_linha(' SITUACAO: '|| UPPER(vr_situacao_beneficio))
                        
                        || fn_adicionar_linha(' BANCO: 748  AGENCIA:'||vr_agencia_beneficiario||'  CONTA:'||vr_conta_beneficiario)
                        
                        || fn_adicionar_linha(' REPRESENTANTE LEGAL:', UPPER(vr_representante_legal))
                        || fn_adicionar_linha(' PENSAO ALIMENTICIA:', UPPER(vr_pensao_alimenticia))
                        || fn_adicionar_linha(' BLOQUEADO PARA EMPRESTIMO:', UPPER(vr_bloqueado_emprestimo))
                        || fn_adicionar_linha(' MARGEM CONSIGNAVEL - EMPRESTIMO:', TO_CHAR(TO_NUMBER(vr_margem_consi_disponi, '9999999999999.99'), 'FM999G999G990D90'))
                        || fn_adicionar_linha(' MARGEM CONSIGNAVEL - CARTAO:', TO_CHAR(TO_NUMBER(vr_margem_consi_disponi_cart, '9999999999999.99'), 'FM999G999G990D90'));
                        
                        IF vr_extrato_emprestimo IS NOT NULL THEN
                            vr_des_retorno := vr_des_retorno 
                                                || fn_adicionar_linha('------------------------------------------------')
                                                || vr_extrato_emprestimo;     
                        END IF;

                        IF vr_cartoes_consignados IS NOT NULL THEN
                            IF vr_extrato_emprestimo IS NULL THEN 
                                vr_des_retorno := vr_des_retorno
                                                || fn_adicionar_linha('------------------------------------------------');
                            END IF;
                            vr_des_retorno := vr_des_retorno 
                                                || fn_adicionar_linha('               CARTAO CONSIGNADO                ')    
                                                || fn_adicionar_linha('------------------------------------------------')
                                                || vr_cartoes_consignados; 
                        END IF;
                        
                        IF vr_cartoes_consignados IS NULL AND vr_extrato_emprestimo IS NULL THEN
                            vr_des_retorno := vr_des_retorno 
                                                || fn_adicionar_linha('------------------------------------------------');
                        END IF; 

                        vr_des_retorno := vr_des_retorno
                        || fn_adicionar_linha(' As informacoes foram fornecidas em '||fn_obter_data(vr_data_hora))
                        || fn_adicionar_linha(' e sao de responsabilidade do INSS. Havendo     ')
                        || fn_adicionar_linha(' duvidas quanto ao conteudo deste documento, ')
                        || fn_adicionar_linha(' entre em contato com a Previdencia Social pelo')
                        || fn_adicionar_linha(' telefone 135.')

                        || '</comprovante>'
                        || '</Raiz>';

                        Dbms_Output.put(vr_des_retorno);
        -- Gera XML de retorno
        pr_xml_ret := XMLTYPE(vr_des_retorno).getClobVal();

        pr_retorno := 'OK';
    EXCEPTION
        WHEN OTHERS THEN
            pr_retorno := 'NOK';   
    END pc_gerar_xml_extr_empr;

    /*
    *   Procedure para realizar a consulta de margem consignável
    */
    PROCEDURE pc_margem_consignavel_inss(pr_cdcooper IN INTEGER             -- Codigo da Cooperativa        
                                            ,pr_nrdconta IN INTEGER         -- Numero da Conta          
                                            ,pr_cdorgins IN NUMBER          -- Codigo do Orgao Pagador  
                                            ,pr_nrbenefi IN NUMBER          -- Numero do Benefício      
                                            ,pr_cdcoptfn IN INTEGER         -- Cooperativa do TAA       
                                            ,pr_cdagetfn IN INTEGER         -- Agencia do TAA           
                                            ,pr_nrterfin IN INTEGER         -- Numero do TAA            
                                            ,pr_retorno OUT CLOB            -- XML da margem consignável
                                            ,pr_dsderror OUT VARCHAR2) IS    -- Mensagem de erro de saída
    vr_nmdireto         VARCHAR2(1000);
    vr_msgenvio         VARCHAR2(32767);
    vr_msgreceb         VARCHAR2(32767);
    vr_retorno          VARCHAR2(3) := NULL;
    vr_coop_origem      NUMBER(10);
    
    vr_exc_erro         EXCEPTION;
    vr_dsderror         VARCHAR2(1000):= NULL;
    
    vr_xml_soap         XMLTYPE;
    vr_xml_reto         CLOB;
    
    BEGIN
        -- Verifica se todos os parâmetros de entrada foram informados
        IF pr_cdcooper IS NULL THEN
           vr_dsderror := 'Codigo da cooperativa nao informado';
           RAISE vr_exc_erro; 
        END IF;

        IF pr_nrdconta IS NULL THEN
           vr_dsderror := 'Numero da conta nao informada';
           RAISE vr_exc_erro; 
        END IF;

        IF pr_cdorgins IS NULL THEN
           vr_dsderror := 'Codigo do orgao pagador nao informado';
           RAISE vr_exc_erro; 
        END IF;

        IF pr_nrbenefi IS NULL THEN
           vr_dsderror := 'Numero do beneficio nao informado';
           RAISE vr_exc_erro; 
        END IF;

        IF pr_cdcoptfn IS NULL THEN
           vr_dsderror := 'Codigo da cooperativa do TAA nao informada';
           RAISE vr_exc_erro; 
        END IF;

        IF pr_cdagetfn IS NULL THEN
           vr_dsderror := 'Codigo da agencia do TAA nao informada';
           RAISE vr_exc_erro; 
        END IF;

        IF pr_nrterfin IS NULL THEN
           vr_dsderror := 'Numero do TAA nao informado';
           RAISE vr_exc_erro; 
        END IF;

        -- verificar se a consulta ao ECO está habilitada
        IF GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                    ,pr_cdcooper => 0
                                    ,pr_cdacesso => 'HABILITAR_CONSULTA_ECO') = '0' THEN
                                    
          vr_dsderror := 'A CONSULTA AOS DADOS DE MARGEM CONSIGNAVEL ESTA DESATIVADA NO MOMENTO';
          RAISE vr_exc_erro;
        END IF;

        -- Inicialização de variáveis
        vr_msgenvio := NULL;
        
        -- Gera os caminhos dos arquivos XML de envio e retorno da requisição
        pc_gerar_caminho_arquivos_req(pr_cdcooper, 1, pr_nrdconta, vr_msgenvio, vr_msgreceb, vr_nmdireto, vr_retorno);

        -- Verifica se ocorreu erro durante a geração do caminho dos arquivos da requisição
        IF vr_retorno = 'NOK' THEN
            vr_dsderror := 'Erro ao gerar caminho dos arquivos da requisicao (INSS0004.pc_gerar_caminho_arquivos_req)';
            RAISE vr_exc_erro;
        END IF;
        
        -- Busca o código da cooperativa de origem
        vr_coop_origem := fn_get_coop_origem(pr_cdcoptfn);

        -- Cria arquivo XML que será utilizado na requisição
        pc_criar_arq_xml_requisicao(pr_caminho => vr_msgenvio                           -- Diretório com o nome do arquivo que será salvo
                                    ,pr_nmmetodo => 'consultaMargemConsignavel'         -- Nome do método 
                                    ,pr_nmmetodo_in => 'InConsultaMargemConsignavel'    -- Nome do método In
                                    ,pr_canal => 'ATM'                                  -- Código do canal de atendimento
                                    ,pr_tpservico => 1                                  -- Tipo de servico
                                    ,pr_coop_origem => vr_coop_origem                   -- Código da cooperativa que está realizando a consulta
                                    ,pr_numero_beneficio => pr_nrbenefi                 -- Número do benificiário
                                    ,pr_orgao_pagador => pr_cdorgins                    -- Número do orgão pagador
                                    ,pr_posto_origem => pr_cdagetfn                     -- Número do posto/UA que está realizando a consulta
                                    ,pr_usuario_origem => 'CECR'                        -- Código do usuário que está realizando a consulta
                                    ,pr_retorno => vr_retorno                           -- Saída OK/NOK
                                    ,pr_dsderror => vr_dsderror);                       -- Mensagem de erro
        
        -- Verifica se ocorreu erro durante a geração do arquivo XML de requisição
        IF vr_retorno = 'NOK' THEN
            vr_dsderror := 'Erro ao criar arquivos XML de requisicao (INSS0004.pc_criar_arq_xml_requisicao) - ' || vr_dsderror;
            RAISE vr_exc_erro;
        END IF;

        -- Faz o envio da requisição SOAP, passando o caminho do arquivo XML
        pc_envia_requisicao_soap(vr_msgenvio, 1, vr_xml_soap, vr_retorno, vr_dsderror);
        
        -- Verifica se ocorreu erro no envio da requisição SOAP
        IF vr_retorno = 'NOK' THEN
            vr_dsderror := 'Erro ao enviar requisicao SOAP (INSS0004.pc_envia_requisicao) - ' || vr_dsderror;
            RAISE vr_exc_erro;    
        END IF;

        -- Faz a leitura do XML de retorno da requisição e monta o XML de retorno da consulta de margem consignável
        pc_gerar_xml_cons_marg_consig(pr_cdorgins, vr_xml_soap, vr_xml_reto, vr_retorno);

        -- Verifica se ocorreu erro durante a construção do XML de retorno da consulta de margem consignável
        IF vr_retorno = 'NOK' THEN
            vr_dsderror := 'Erro ao gerar XML consulta de margem consignavel (INSS0004.pc_gerar_xml_cons_marg_consig)';
            RAISE vr_exc_erro;    
        END IF;

        -- Registra log da consulta de margem consignável
        INSS0003.pc_gera_reg_emp_consignado(pr_cdcooper => pr_cdcooper  --> Codigo da Cooperativa
                                      ,pr_nrdconta => pr_nrdconta       --> Numero da Conta
                                      ,pr_cdorgins => pr_cdorgins       --> Codigo do Orgao Pagador
                                      ,pr_nrbenefi => pr_nrbenefi       --> Numero do Benefício
                                      ,pr_tpoperac => 2                 --> Tipo de operacao: (1 - Historico de emprestimos ativos, 2 - Consulta de margem consignavel)
                                      ,pr_cdcoptfn => pr_cdcoptfn       --> Cooperativa do TAA
                                      ,pr_cdagetfn => pr_cdagetfn       --> Agencia do TAA
                                      ,pr_nrterfin => pr_nrterfin       --> Numero do TAA
                                      ,pr_nmdcanal => 'ATM'             --> Nome do Canal
                                      ,pr_nmusuari => 'CECR');          --> Nome do Usuário da consulta

        -- Faz a exclusão do arquivo de requisição
        pc_excluir_arq_xml_requisicao(vr_msgenvio, vr_retorno);

        -- Verifica se conseguiu excluir o arquivo de requisição
        IF vr_retorno = 'NOK' THEN
            pr_dsderror := 'Erro ao excluir arquivo XML da requisicao (INSS0004.pc_excluir_arq_xml_requisicao)';
            RAISE vr_exc_erro;    
        END IF;

        pr_retorno := vr_xml_reto;
    EXCEPTION 
        WHEN vr_exc_erro THEN
            pr_dsderror := vr_dsderror;
            
            -- Faz a exclusão do arquivo de requisição
            pc_excluir_arq_xml_requisicao(vr_msgenvio, vr_retorno);

        WHEN OTHERS THEN
            -- Faz a exclusão do arquivo de requisição
            pc_excluir_arq_xml_requisicao(vr_msgenvio, vr_retorno);
            pr_dsderror := 'Erro nat tratado na INNS0004.pc_consulta_margem_consignavel.';

    END pc_margem_consignavel_inss;


    /*
    *   Procedure para realizar a consulta de margem consignável
    */
    PROCEDURE pc_extrato_emprestimo_inss(pr_cdcooper IN INTEGER             -- Codigo da Cooperativa
                                            ,pr_nrdconta IN INTEGER         -- Numero da Conta
                                            ,pr_cdorgins IN NUMBER          -- Codigo do Orgao Pagador
                                            ,pr_nrbenefi IN NUMBER          -- Numero do Benefício
                                            ,pr_cdcoptfn IN INTEGER         -- Cooperativa do TAA
                                            ,pr_cdagetfn IN INTEGER         -- Agencia do TAA
                                            ,pr_nrterfin IN INTEGER         -- Numero do TAA
                                            ,pr_retorno OUT CLOB            -- XML do extrato de emprestimo
                                            ,pr_dsderror OUT VARCHAR2) IS   -- Descrição do erro  
    vr_nmdireto         VARCHAR2(1000);
    vr_msgenvio         VARCHAR2(32767);
    vr_msgreceb         VARCHAR2(32767);
    vr_retorno          VARCHAR2(3) := NULL;

    vr_coop_origem      NUMBER(10);
    
    vr_exc_erro         EXCEPTION;
    vr_dsderror         VARCHAR2(1000):= NULL;
    
    vr_xml_soap         XMLTYPE;
    vr_xml_reto         CLOB;
    
    BEGIN
        -- Verifica se todos os parâmetros de entrada foram informados
        IF pr_cdcooper IS NULL THEN
           vr_dsderror := 'Codigo da cooperativa nao informado';
           RAISE vr_exc_erro; 
        END IF;

        IF pr_nrdconta IS NULL THEN
           vr_dsderror := 'Numero da conta nao informada';
           RAISE vr_exc_erro; 
        END IF;

        IF pr_cdorgins IS NULL THEN
           vr_dsderror := 'Codigo do orgao pagador nao informado';
           RAISE vr_exc_erro; 
        END IF;

        IF pr_nrbenefi IS NULL THEN
           vr_dsderror := 'Numero do beneficio nao informado';
           RAISE vr_exc_erro; 
        END IF;

        IF pr_cdcoptfn IS NULL THEN
           vr_dsderror := 'Codigo da cooperativa do TAA nao informada';
           RAISE vr_exc_erro; 
        END IF;

        IF pr_cdagetfn IS NULL THEN
           vr_dsderror := 'Codigo da agencia do TAA nao informada';
           RAISE vr_exc_erro; 
        END IF;

        IF pr_nrterfin IS NULL THEN
           vr_dsderror := 'Numero do TAA nao informado';
           RAISE vr_exc_erro; 
        END IF;

        -- verificar se a consulta ao ECO está habilitada
        IF GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                    ,pr_cdcooper => 0
                                    ,pr_cdacesso => 'HABILITAR_CONSULTA_ECO') = '0' THEN
                                    
          vr_dsderror := 'A CONSULTA AOS DADOS DE EMPRESTIMO CONSIGNADO ESTA DESATIVADA NO MOMENTO';
          RAISE vr_exc_erro;
        END IF;

        -- Inicialização de variáveis
        vr_msgenvio := NULL;
        
        -- Gera os caminhos dos arquivos XML de envio e retorno da requisição
        pc_gerar_caminho_arquivos_req(pr_cdcooper, 1, pr_nrdconta, vr_msgenvio, vr_msgreceb, vr_nmdireto, vr_retorno);

        -- Verifica se ocorreu erro durante a geração do caminho dos arquivos da requisição
        IF vr_retorno = 'NOK' THEN
            vr_dsderror := 'Erro ao gerar caminho dos arquivos da requisicao (INSS0004.pc_gerar_caminho_arquivos_req)';
            RAISE vr_exc_erro;
        END IF;

        -- Busca o código da cooperativa de origem
        vr_coop_origem := fn_get_coop_origem(pr_cdcoptfn);
        
        -- Cria arquivo XML que será utilizado na requisição
        pc_criar_arq_xml_requisicao(pr_caminho => vr_msgenvio                           -- Diretório com o nome do arquivo que será salvo
                                    ,pr_nmmetodo => 'emiteExtratoEmprestimo'            -- Nome do método 
                                    ,pr_nmmetodo_in => 'InEmiteExtratoEmprestimo'       -- Nome do método In
                                    ,pr_canal => 'ATM'                                  -- Código do canal de atendimento
                                    ,pr_tpservico => 1                                  -- Tipo de servico
                                    ,pr_coop_origem => vr_coop_origem                   -- Código da cooperativa que está realizando a consulta
                                    ,pr_numero_beneficio => pr_nrbenefi                 -- Número do benificiário
                                    ,pr_orgao_pagador => pr_cdorgins                    -- Número do orgão pagador
                                    ,pr_posto_origem => pr_cdagetfn                     -- Número do posto/UA que está realizando a consulta
                                    ,pr_usuario_origem => 'CECR'                        -- Código do usuário que está realizando a consulta
                                    ,pr_retorno => vr_retorno                           -- Saída OK/NOK
                                    ,pr_dsderror => vr_dsderror);                       -- Mensagem de erro
        
        -- Verifica se ocorreu erro durante a geração do arquivo XML de requisição
        IF vr_retorno = 'NOK' THEN
            vr_dsderror := 'Erro ao criar arquivos XML de requisicao (INSS0004.pc_criar_arq_xml_requisicao) - ' || vr_dsderror;
            RAISE vr_exc_erro;
        END IF;

        -- Faz o envio da requisição SOAP, passando o caminho do arquivo XML
        pc_envia_requisicao_soap(vr_msgenvio, 1, vr_xml_soap, vr_retorno, vr_dsderror);
        
        -- Verifica se ocorreu erro no envio da requisição SOAP
        IF vr_retorno = 'NOK' THEN
            vr_dsderror := 'Erro ao enviar requisicao SOAP (INSS0004.pc_envia_requisicao) - ' || vr_dsderror;
            RAISE vr_exc_erro;    
        END IF;

        -- Faz a leitura do XML de retorno da requisição e monta o XML de retorno da consulta de margem consignável
        pc_gerar_xml_extr_empr(pr_cdorgins, vr_xml_soap, vr_xml_reto, vr_retorno);

        -- Verifica se ocorreu erro durante a construção do XML de retorno da consulta de margem consignável
        IF vr_retorno = 'NOK' THEN
            vr_dsderror := 'Erro ao gerar XML consulta de margem consignavel (INSS0004.pc_emite_extrato_emprestimo)';
            RAISE vr_exc_erro;    
        END IF;

        -- Registra log da consulta de extratos emprestimos
        INSS0003.pc_gera_reg_emp_consignado(pr_cdcooper => pr_cdcooper        --> Codigo da Cooperativa
                                            ,pr_nrdconta => pr_nrdconta       --> Numero da Conta
                                            ,pr_cdorgins => pr_cdorgins       --> Codigo do Orgao Pagador
                                            ,pr_nrbenefi => pr_nrbenefi       --> Numero do Benefício
                                            ,pr_tpoperac => 1                 --> Tipo de operacao: (1 - Historico de emprestimos ativos, 2 - Consulta de margem consignavel)
                                            ,pr_cdcoptfn => pr_cdcoptfn       --> Cooperativa do TAA
                                            ,pr_cdagetfn => pr_cdagetfn       --> Agencia do TAA
                                            ,pr_nrterfin => pr_nrterfin       --> Numero do TAA
                                            ,pr_nmdcanal => 'ATM'             --> Nome do Canal
                                            ,pr_nmusuari => 'CECR');          --> Nome do Usuário da consulta

        -- Faz a exclusão do arquivo de requisição
        pc_excluir_arq_xml_requisicao(vr_msgenvio, vr_retorno);

        -- Verifica se conseguiu excluir o arquivo de requisição
        IF vr_retorno = 'NOK' THEN
            vr_dsderror := 'Erro ao excluir arquivo XML da requisicao (INSS0004.pc_excluir_arq_xml_requisicao)';
            RAISE vr_exc_erro;    
        END IF;

        pr_retorno := vr_xml_reto;
    EXCEPTION 
        WHEN vr_exc_erro THEN
            -- Faz a exclusão do arquivo de requisição
            pc_excluir_arq_xml_requisicao(vr_msgenvio, vr_retorno);
            pr_dsderror := vr_dsderror;

        WHEN OTHERS THEN
            cecred.pc_internal_exception;

            -- Faz a exclusão do arquivo de requisição
            pc_excluir_arq_xml_requisicao(vr_msgenvio, vr_retorno);

            pr_dsderror := 'Erro nao tratado na INNS0004.pc_emite_extrato_emprestimo ';
    
    END pc_extrato_emprestimo_inss;

end INSS0004;
/
