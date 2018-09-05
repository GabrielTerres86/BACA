CREATE OR REPLACE PACKAGE CECRED.FIPE0001 IS

  --> Marca FIPE
  PROCEDURE pc_lista_marca_fipe(pr_tpveiculofipe  IN tbgen_fipe_marca.tpveiculofipe%type -- Tipo de veiculo FIPE
                               ,pr_dsmarcafipe    IN tbgen_fipe_marca.dsmarcafipe%type   -- Indicador de marca de veiculo FIPE
                               ,pr_retorno       OUT xmltype                             -- XML de retorno
                               ,pr_dscritic      OUT VARCHAR2);                          -- Retorno de Erro  

  --> Modelo FIPE
  PROCEDURE pc_lista_modelo_fipe(pr_inmarcafipe  IN tbgen_fipe_modelo.inmarcafipe%type -- Indicador de Tabela de veiculo FIPE
                                ,pr_retorno      OUT xmltype                             -- XML de retorno
                                ,pr_dscritic     OUT VARCHAR2);                          -- Retorno de Erro  

  --> Ano FIPE     
  PROCEDURE pc_lista_ano_fipe(pr_inmarcafipe      IN tbgen_fipe_ano.inmarcafipe%type     -- Indicador de marca de veiculo FIPE
                             ,pr_inmodelofipe     IN tbgen_fipe_ano.inmodelofipe%type    -- Indicador de modelode veiculo FIPE
                           --,pr_nranofipe        IN tbgen_fipe_ano.nranofipe%type       -- Ano do veiculo FIPE
                             ,pr_retorno    OUT xmltype                                  -- XML de retorno
                             ,pr_dscritic   OUT VARCHAR2);                               -- Retorno de Erro  

  --> Tabela FIPE
  PROCEDURE pc_lista_tabela_fipe(pr_inmarcafipe   IN tbgen_fipe_tabela.inmarcafipe%type   -- Indicador de marca de veiculo FIPE
                                ,pr_inmodelofipe  IN tbgen_fipe_tabela.inmodelofipe%type  -- Indicador de Tabelade veiculo FIPE
                                ,pr_nranofipe     IN tbgen_fipe_tabela.nranofipe%type     -- Ano do veiculo FIPE
                                ,pr_retorno      OUT xmltype                              -- XML de retorno
                                ,pr_dscritic     OUT VARCHAR2);                           -- Retorno de Erro  
                                                          
END FIPE0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.FIPE0001 IS

  --> Rotina para retorno das marcas FIPE (CDC)
  PROCEDURE pc_lista_marca_fipe(pr_tpveiculofipe IN tbgen_fipe_marca.tpveiculofipe%type -- Tipo de veiculo FIPE
                               ,pr_dsmarcafipe   IN tbgen_fipe_marca.dsmarcafipe%type   -- Indicador de marca de veiculo FIPE
                               ,pr_retorno      OUT xmltype                             -- XML de retorno
                               ,pr_dscritic     OUT VARCHAR2) IS                        -- Retorno de Erro
    -- Exceções
    vr_exc_erro EXCEPTION;
    -- Tratamento de erros

    -- Variaveis gerais
    vr_xml xmltype; -- XML que sera enviado
    vr_contador      NUMBER := 0;

    -- Cursor para buscar as marcas
    CURSOR cr_tabelas IS
      select m.inmarcafipe,
             m.tpveiculofipe,
             m.dsmarcafipe
        from tbgen_fipe_marca m
       where m.tpveiculofipe = nvl(pr_tpveiculofipe,0) 
         and upper(m.dsmarcafipe) like '%' || trim(upper(nvl(pr_dsmarcafipe,m.dsmarcafipe))) || '%'
       order by m.dsmarcafipe; 

  BEGIN
    -- Cria o cabecalho do xml de envio
    vr_xml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Marcas/>');

    -- Loop sobre a tabela de marcas
    FOR rw_tabelas IN cr_tabelas LOOP

      -- Insere o nó principal
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Marcas'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Marca'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => pr_dscritic);

      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Marca'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'inmarcafipe'
                            ,pr_tag_cont => rw_tabelas.inmarcafipe
                            ,pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Marca'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'tpveiculofipe'
                            ,pr_tag_cont => rw_tabelas.tpveiculofipe
                            ,pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Marca'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'dsmarcafipe'
                            ,pr_tag_cont => rw_tabelas.dsmarcafipe
                            ,pr_des_erro => pr_dscritic);

      vr_contador := vr_contador + 1;    
    END LOOP;
    
     -- Se não encontrou nenhum registro
    IF vr_contador = 0 THEN
      -- Gerar crítica
      pr_dscritic    := 'Marca não cadastrada';
      -- Levantar exceção
      RAISE vr_exc_erro;
    END IF;

    pr_retorno := vr_xml;

  EXCEPTION    
    WHEN vr_exc_erro THEN          
      -- Carregar XML padrao para variavel de retorno
      pr_retorno := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_lista_marca_fipe: ' ||
                     SQLERRM;
  END pc_lista_marca_fipe;


  --> Rotina para retorno dos modelos FIPE (CDC)
  PROCEDURE pc_lista_modelo_fipe(pr_inmarcafipe  IN tbgen_fipe_modelo.inmarcafipe%type  -- Indicador de Tabela de veiculo FIPE
                                ,pr_retorno      OUT xmltype                            -- XML de retorno
                                ,pr_dscritic     OUT VARCHAR2) IS                       -- Retorno de Erro
    -- Exceções
    vr_exc_erro EXCEPTION;
    -- Tratamento de erros

    -- Variaveis gerais
    vr_xml xmltype; -- XML que sera enviado
    vr_contador      NUMBER := 0;

    -- Cursor para buscar as marcas
    CURSOR cr_modelo IS
      select m.inmarcafipe
            ,m.inmodelofipe
            ,m.dsmodelofipe
        from tbgen_fipe_modelo m 
       where m.inmarcafipe = decode(nvl(pr_inmarcafipe,0),0,m.inmarcafipe,pr_inmarcafipe)
        --and rownum < 100
  --   and m.
       order by m.dsmodelofipe; 
    
    -- Variáveis para armazenar as informações em XML
    vr_des_xml         CLOB;
    vr_texto_completo  VARCHAR2(32600);
    ---------------------------> SUBROTINAS <--------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END; 
    
  BEGIN
  
    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    -- Inicilizar as informações do XML
    vr_texto_completo := NULL;

    pc_escreve_xml ('<?xml version="1.0" encoding="ISO-8859-1" ?><Modelos>');     

    -- Loop sobre a tabela de marcas
    FOR rw_modelo IN cr_modelo LOOP
    
      pc_escreve_xml ('<Modelo>'||
                         '<inmarcafipe>' || rw_modelo.inmarcafipe  ||'</inmarcafipe>'||
                         '<inmodelofipe>'|| rw_modelo.inmodelofipe ||'</inmodelofipe>'||
                         '<dsmodelofipe><![CDATA['|| rw_modelo.dsmodelofipe ||']]></dsmodelofipe>'||      
                      '</Modelo>');

      vr_contador := vr_contador + 1;
          
    END LOOP;
    
     -- Se não encontrou nenhum registro
    IF vr_contador = 0 THEN
      -- Gerar crítica
      pr_dscritic    := 'Modelo não cadastrado';
      -- Levantar exceção
      RAISE vr_exc_erro;
    END IF;
    
    pc_escreve_xml ('</Modelos>',TRUE);  
    pr_retorno := XMLType.createXML(vr_des_xml);
    
    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);

  EXCEPTION
    WHEN vr_exc_erro THEN          
      -- Carregar XML padrao para variavel de retorno
      pr_retorno := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_lista_modelo_fipe: ' || SQLERRM;
  END pc_lista_modelo_fipe;

  
  --> Rotina para retorno dos anos da FIPE (CDC)
  PROCEDURE pc_lista_ano_fipe(pr_inmarcafipe    IN tbgen_fipe_ano.inmarcafipe%type   -- Indicador de marca de veiculo FIPE
                             ,pr_inmodelofipe   IN tbgen_fipe_ano.inmodelofipe%type  -- Indicador de modelode veiculo FIPE
                           --,pr_nranofipe      IN tbgen_fipe_ano.nranofipe%type     -- Ano do veiculo FIPE
                             ,pr_retorno       OUT xmltype                           -- XML de retorno
                             ,pr_dscritic      OUT VARCHAR2)IS                       -- Retorno de Erro  
    -- Exceções
    vr_exc_erro EXCEPTION;
    -- Tratamento de erros

    -- Variaveis gerais
    vr_xml xmltype; -- XML que sera enviado
    vr_contador      NUMBER := 0;

    -- Cursor para buscar as marcas
    CURSOR cr_ano IS
      select a.inmarcafipe
            ,a.inmodelofipe
            ,a.nranofipe
            ,a.dsanofipe
            ,a.dsanocompletofipe 
        from tbgen_fipe_ano a
       where a.inmarcafipe = decode(pr_inmarcafipe,0,a.inmarcafipe,pr_inmarcafipe)
       and   a.inmodelofipe = decode(pr_inmodelofipe,0,a.inmodelofipe,pr_inmodelofipe);
     --and   a.nranofipe = decode(pr_nranofipe,0,a.nranofipe,pr_nranofipe);

  BEGIN
    -- Cria o cabecalho do xml de envio
    vr_xml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Anos/>');

    -- Loop sobre a tabela de marcas
    FOR rw_ano IN cr_ano LOOP

      -- Insere o nó principal
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Anos'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Ano'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => pr_dscritic);

      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Ano'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'inmarcafipe'
                            ,pr_tag_cont => rw_ano.inmarcafipe
                            ,pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Ano'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'inmodelofipe'
                            ,pr_tag_cont => rw_ano.inmodelofipe
                            ,pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Ano'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'nranofipe'
                            ,pr_tag_cont => rw_ano.nranofipe
                            ,pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Ano'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'dsanofipe'
                            ,pr_tag_cont => rw_ano.dsanofipe
                            ,pr_des_erro => pr_dscritic);                            
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Ano'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'dsanocompletofipe'
                            ,pr_tag_cont => rw_ano.dsanocompletofipe
                            ,pr_des_erro => pr_dscritic);    
                                             
      vr_contador := vr_contador + 1;   
    END LOOP;
    
    -- Se não encontrou nenhum registro
    IF vr_contador = 0 THEN
      -- Gerar crítica
      pr_dscritic    := 'Ano não cadastrado';
      -- Levantar exceção
      RAISE vr_exc_erro;
    END IF;

    pr_retorno := vr_xml;

  EXCEPTION
    WHEN vr_exc_erro THEN          
      -- Carregar XML padrao para variavel de retorno
      pr_retorno := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_lista_ano_fipe: ' || SQLERRM;
  END pc_lista_ano_fipe; 

  
  -- Rotina para retorno da Tabela FIPE (CDC)
  PROCEDURE pc_lista_tabela_fipe(pr_inmarcafipe   IN tbgen_fipe_tabela.inmarcafipe%type   -- Indicador de marca de veiculo FIPE
                                ,pr_inmodelofipe  IN tbgen_fipe_tabela.inmodelofipe%type  -- Indicador de Tabelade veiculo FIPE
                                ,pr_nranofipe     IN tbgen_fipe_tabela.nranofipe%type     -- Ano do veiculo FIPE
                                ,pr_retorno  OUT xmltype                                  -- XML de retorno
                                ,pr_dscritic OUT VARCHAR2)IS                              -- Retorno de Erro  
    -- Exceções
    vr_exc_erro EXCEPTION;
    -- Tratamento de erros

    -- Variaveis gerais
    vr_xml xmltype; -- XML que sera enviado
    vr_contador      NUMBER := 0;

    -- Cursor para buscar as marcas
    CURSOR cr_tabelas IS
      select t.inmarcafipe
            ,t.inmodelofipe
            ,t.nranofipe
            ,t.cdtabelafipe
            ,t.dsmarcafipe
            ,t.dscombustivel
            ,t.vltabelafipe
       from tbgen_fipe_tabela t    
      where t.inmarcafipe =  decode(pr_inmarcafipe,0,t.inmarcafipe,pr_inmarcafipe)
        and t.inmodelofipe =  decode(pr_inmodelofipe,0,t.inmodelofipe,pr_inmodelofipe)
        and t.nranofipe =  decode(pr_nranofipe,0,t.nranofipe,pr_nranofipe)
      order by 1,2,3,4;

  BEGIN
    -- Cria o cabecalho do xml de envio
    vr_xml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Tabelas/>');

    -- Loop sobre a tabela de marcas
    FOR rw_tabelas IN cr_tabelas LOOP

      -- Insere o nó principal
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Tabelas'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Tabela'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => pr_dscritic);

      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Tabela'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'inmarcafipe'
                            ,pr_tag_cont => rw_tabelas.inmarcafipe
                            ,pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Tabela'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'inmodelofipe'
                            ,pr_tag_cont => rw_tabelas.inmodelofipe
                            ,pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Tabela'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'nranofipe'
                            ,pr_tag_cont => rw_tabelas.nranofipe
                            ,pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Tabela'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'cdtabelafipe'
                            ,pr_tag_cont => rw_tabelas.cdtabelafipe
                            ,pr_des_erro => pr_dscritic);                            
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Tabela'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'dsmarcafipe'
                            ,pr_tag_cont => rw_tabelas.dsmarcafipe
                            ,pr_des_erro => pr_dscritic);    
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Tabela'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'dscombustivel'
                            ,pr_tag_cont => rw_tabelas.dscombustivel
                            ,pr_des_erro => pr_dscritic);    
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Tabela'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'vltabelafipe'
                            ,pr_tag_cont => rw_tabelas.vltabelafipe
                            ,pr_des_erro => pr_dscritic);                               
                                                        
      vr_contador := vr_contador + 1;    
    END LOOP;
    
    -- Se não encontrou nenhum registro
    IF vr_contador = 0 THEN
      -- Gerar crítica
      pr_dscritic    := 'Tabela não cadastrado';
      -- Levantar exceção
      RAISE vr_exc_erro;
    END IF;

    pr_retorno := vr_xml;

  EXCEPTION
    WHEN vr_exc_erro THEN          
      -- Carregar XML padrao para variavel de retorno
      pr_retorno := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_lista_Tabela_fipe: ' ||
                     SQLERRM;
  END pc_lista_tabela_fipe; 

END FIPE0001;
/
