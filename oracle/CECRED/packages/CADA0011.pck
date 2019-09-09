CREATE OR REPLACE PACKAGE CECRED.CADA0011 is
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CADA0011
  --  Sistema  : Rotinas para ler tabelas Ayllos e Cadastrar Pessoas
  --  Sigla    : CADA
  --  Autor    : Andrino Carlos de Souza Junior (Mouts)
  --  Data     : Julho/2017.                   Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: OnLine
  -- Objetivo  : 
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Rotina para cadastro de pessoa com base na tabela CRAPASS
  PROCEDURE pc_insere_pessoa_crapass(pr_cdcooper crapass.cdcooper%TYPE -- Codigo da cooperativa
                                    ,pr_nrdconta crapass.nrdconta%TYPE -- Numero da conta
                                    ,pr_idseqttl crapttl.idseqttl%TYPE -- Sequencia do titular
                                    ,pr_cdoperad crapope.cdoperad%TYPE -- Codigo do operador que esta efetuando a operacao
                                    ,pr_cdcritic OUT INTEGER           -- Codigo de erro
                                    ,pr_dscritic OUT VARCHAR2);        -- Retorno de Erro
    
    
  PROCEDURE pc_trata_telefone(pr_nrtelefone_org IN VARCHAR2, -- Numero no telefone original
                              pr_nrramal_org    IN NUMBER,   -- Numero do ramal
                              pr_nrddd         OUT NUMBER,   -- Numero do DDD
                              pr_nrtelefone    OUT NUMBER,   -- Numero do telefone
                              pr_nrramal       OUT NUMBER,   -- Numero do ramal
                              pr_dscritic      OUT VARCHAR2); -- Erro de execucao

  -- Rotina para tratar pessoa de relacao
  PROCEDURE pc_trata_pessoa_relacao(pr_idpessoa  IN tbcadast_pessoa.idpessoa%TYPE, -- ID da pessoa origem
                                    pr_tprelacao IN tbcadast_pessoa_relacao.tprelacao%TYPE, -- Tipo de relacao
                                    pr_nmpessoa  IN tbcadast_pessoa.nmpessoa%TYPE, -- Nome da pessoa de relacionamento
                                    pr_cdoperad  IN tbcadast_pessoa.cdoperad_altera%TYPE,  -- Operador da inclusao
                                    pr_cdcritic OUT INTEGER,          -- Codigo de erro
                                    pr_dscritic OUT VARCHAR2);      -- Retorno de Erro    

  PROCEDURE pc_trata_representante(pr_dsproftl               IN crapavt.dsproftl%TYPE,
                                   pt_tpcargo_representante OUT tbcadast_pessoa_juridica_rep.tpcargo_representante%TYPE,
                                   pr_dscritic              OUT VARCHAR2);

  -- Rotina para validar se o token do usuario eh o mesmo que foi informado
  PROCEDURE pc_valida_token_usuario_web( pr_dstoken  IN  VARCHAR2              -- Token
                                        ,pr_xmllog   IN VARCHAR2 DEFAULT NULL  -- XML com informações de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER           -- Código da crítica
                                        ,pr_dscritic OUT VARCHAR2              -- Descrição da crítica
                                        ,pr_retxml   IN OUT NOCOPY XMLType     -- Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2              -- Nome do Campo
                                        ,pr_des_erro OUT VARCHAR2);            -- Saida OK/NOK
																				
  -- Rotina para atualizar as tabelas do Ayllos com base no cadastro de pessoa
  PROCEDURE pc_atualiza_ayllos(pr_dscritic OUT VARCHAR2);      -- Retorno de Erro

  -- Rotina para atualizar o indicador de tipo de cadastro
  PROCEDURE pc_atualiza_tipo_cadastro(pr_dscritic OUT VARCHAR2);  -- Retorno de Erro

  /*****************************************************************************/
  /**            Procedure para execucao do processo                          **/
  /*****************************************************************************/
  PROCEDURE pc_executa_processo(pr_nrdconta  IN crapass.nrdconta%TYPE -- Conta de inicio do restart
                               ,pr_cdcritic OUT INTEGER           -- Codigo de erro
                               ,pr_dscritic OUT VARCHAR2);        -- Retorno de Erro


  -- Rotina para inserir os dados do banco para pessoa juridica
  PROCEDURE pc_insere_juridico_bco(pr_crapjfn  crapjfn%ROWTYPE -- Registro com os dados do financeiro
                                  ,pr_idpessoa tbcadast_pessoa.idpessoa%TYPE -- Identificador de pessoa
                                  ,pr_cdoperad crapope.cdoperad%TYPE -- Codigo do operador que esta efetuando a operacao
                                  ,pr_cdcritic OUT INTEGER           -- Codigo de erro
                                  ,pr_dscritic OUT VARCHAR2);      -- Retorno de Erro

    
END CADA0011;
/
CREATE OR REPLACE PACKAGE BODY CECRED.CADA0011 IS

  PROCEDURE pc_trata_representante(pr_dsproftl               IN crapavt.dsproftl%TYPE,
                                   pt_tpcargo_representante OUT tbcadast_pessoa_juridica_rep.tpcargo_representante%TYPE,
                                   pr_dscritic              OUT VARCHAR2) IS
    -- Cursor para buscar a descricao
    CURSOR cr_dominio IS
      SELECT a.cddominio
        FROM tbcadast_dominio_campo a
       WHERE nmdominio = 'TPCARGO_REPRESENTANTE'
         AND dscodigo = pr_dsproftl;
  BEGIN
    -- Abre o cursor de dominio
    OPEN cr_dominio;
    FETCH cr_dominio INTO pt_tpcargo_representante;
    CLOSE cr_dominio;
    
    -- Se nao tiver, considera como ADMINISTRADOR
    IF pt_tpcargo_representante IS NULL THEN
      pt_tpcargo_representante := 1;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro nao tratado na pc_trata_representante: '||SQLERRM;
  END;                                   

 
  -- Rotina que recebe o telefone em um unico campo caracter e retorna em numerico
  -- quebrado por DDD e telefone
  PROCEDURE pc_trata_telefone(pr_nrtelefone_org IN VARCHAR2, -- Numero no telefone original
                              pr_nrramal_org    IN NUMBER,   -- Numero do ramal
                              pr_nrddd         OUT NUMBER,   -- Numero do DDD
                              pr_nrtelefone    OUT NUMBER,   -- Numero do telefone
                              pr_nrramal       OUT NUMBER,   -- Numero do ramal
                              pr_dscritic      OUT VARCHAR2) IS -- Erro de execucao
    vr_nrtelefone VARCHAR2(50);
  BEGIN
    -- Atualiza o telefone com o valor de origem
    vr_nrtelefone := pr_nrtelefone_org;
    
    -- Busca o DDD
    IF instr(pr_nrtelefone_org,'(') > 0 THEN -- Se possui parenteses
      BEGIN
        -- Retira os parenteses do DDD
        pr_nrddd := substr(pr_nrtelefone_org,instr(pr_nrtelefone_org,'(')+1,instr(pr_nrtelefone_org,')')-2);
        
        -- Retira o DDD do telefone
        vr_nrtelefone := substr(vr_nrtelefone,instr(pr_nrtelefone_org,')')+1);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      -- Se o DDD possuir mais de duas casas, entao eh um DDD invalido
      IF nvl(pr_nrramal_org,0) > 99 THEN
        pr_nrddd := 0;
      END IF;
    END IF;
    
    -- Atualiza o telefone de retorno
    BEGIN
       pr_nrtelefone := replace(replace(replace(replace(replace(replace(vr_nrtelefone,'e',''),'-',''),' ',''),'.',''),'(',''),')','');
    EXCEPTION
      WHEN OTHERS THEN
        -- efetua um loop sobre cada letra para retirar os textos
        FOR x IN 1..length(vr_nrtelefone) LOOP
          IF substr(vr_nrtelefone,x,1) IN ('1','2','3','4','5','6','7','8','9','0') THEN
            pr_nrtelefone := to_char(nvl(pr_nrtelefone,0))||substr(vr_nrtelefone,x,1);
          END IF;
        END LOOP;
    END;
    
    -- Retornar no maximo 15 posicoes
    pr_nrtelefone := substr(pr_nrtelefone,1,15);
    
    -- Atualiza o numero do ramal sem tratativas
    pr_nrramal := pr_nrramal_org;
  
	EXCEPTION
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_trata_telefone: ' ||SQLERRM;
  END;                              
  


  FUNCTION fn_cria_prospect(pr_nmpessoa IN tbcadast_pessoa.nmpessoa%TYPE, -- Nome da pessoa
                            pr_tppessoa IN tbcadast_pessoa.tppessoa%TYPE, -- Tipo de pessoa
                            pr_cdoperad IN tbcadast_pessoa.cdoperad_altera%TYPE,  -- Operador da inclusao
                            pr_cdcritic OUT INTEGER,          -- Codigo de erro
                            pr_dscritic OUT VARCHAR2)         -- Retorno de Erro
                     RETURN NUMBER IS -- retorna o ID da pessoa
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;

    -- Variaveis gerais
    vr_pessoa_juridica vwcadast_pessoa_juridica%ROWTYPE;
    vr_pessoa_fisica   vwcadast_pessoa_fisica%ROWTYPE;
    vr_idpessoa        tbcadast_pessoa.idpessoa%TYPE;
  BEGIN
    
    -- Se for pessoa fisica
    IF pr_tppessoa = 1 THEN
      vr_pessoa_fisica.nmpessoa := pr_nmpessoa;
      vr_pessoa_fisica.tppessoa := pr_tppessoa;
      vr_pessoa_fisica.tpcadastro := 1; -- Prospect
      vr_pessoa_fisica.cdoperad_altera := pr_cdoperad;
      cada0010.pc_cadast_pessoa_fisica(pr_pessoa_fisica => vr_pessoa_fisica,
                                       pr_cdcritic => vr_cdcritic,
                                       pr_dscritic => vr_dscritic);
      -- Busca o ID da pessoa que foi criado
      vr_idpessoa := vr_pessoa_fisica.idpessoa;
    ELSE -- Se for pessoa juridica
      vr_pessoa_juridica.nmpessoa := pr_nmpessoa;
      vr_pessoa_juridica.tppessoa := pr_tppessoa;
      vr_pessoa_juridica.cdoperad_altera := pr_cdoperad;
      vr_pessoa_juridica.tpcadastro := 1; -- Prospect
      cada0010.pc_cadast_pessoa_juridica(pr_pessoa_juridica => vr_pessoa_juridica,
                                         pr_cdcritic => vr_cdcritic,
                                         pr_dscritic => vr_dscritic);
      -- Busca o ID da pessoa que foi criado
      vr_idpessoa := vr_pessoa_juridica.idpessoa;
    END IF;
    
    -- Verifica se deu erro
    IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    RETURN vr_idpessoa;

	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
      RETURN NULL;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_cria_prospect: ' ||SQLERRM;
      RETURN NULL;
  END;  

  -- Rotina para validar se o token do usuario eh o mesmo que foi informado
  PROCEDURE pc_valida_token_usuario(pr_cdcooper IN  crapope.cdcooper%TYPE,
                                    pr_cdoperad IN  crapope.cdoperad%TYPE,
                                    pr_dstoken  IN  VARCHAR2,
                                    pr_dscritic OUT VARCHAR2) IS
    -- Cursor para buscar o token do operador
    CURSOR cr_crapope IS
      SELECT cddsenha
        FROM crapope
       WHERE cdcooper = pr_cdcooper
         AND upper(cdoperad) = upper(pr_cdoperad);
    rw_crapope cr_crapope%ROWTYPE;

    -- Tratamento de erros
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN
    -- Busca os dados do operador
    OPEN cr_crapope;
    FETCH cr_crapope INTO rw_crapope;
    IF cr_crapope%NOTFOUND THEN
      CLOSE cr_crapope;
      vr_dscritic := 'Operador informado inexistente';
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapope;
    
    -- Verifica se o toke informado difere do token do operador
    IF nvl(pr_dstoken,' ') <> rw_crapope.cddsenha THEN
      vr_dscritic := 'Token informado difere do existente para o operador!';
      RAISE vr_exc_erro;
    END IF;
    
	EXCEPTION
    WHEN vr_exc_erro THEN
      --Variavel de erro recebe erro ocorrido
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_valida_token_usuario: ' ||SQLERRM;
  END;                                    

  -- Rotina para validar se o token do usuario eh o mesmo que foi informado
  PROCEDURE pc_valida_token_usuario_web( pr_dstoken  IN  VARCHAR2              -- Token
                                        ,pr_xmllog   IN VARCHAR2 DEFAULT NULL  -- XML com informações de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER           -- Código da crítica
                                        ,pr_dscritic OUT VARCHAR2              -- Descrição da crítica
                                        ,pr_retxml   IN OUT NOCOPY XMLType     -- Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2              -- Nome do Campo
                                        ,pr_des_erro OUT VARCHAR2) IS          -- Saida OK/NOK
		--Variaveis de Criticas
		vr_cdcritic INTEGER;
		vr_dscritic VARCHAR2(4000);
		vr_des_reto VARCHAR2(3); 

		-- Variaveis de log
		vr_cdcooper crapcop.cdcooper%TYPE;
		vr_cdoperad VARCHAR2(100);
		vr_nmdatela VARCHAR2(100);
		vr_nmeacao  VARCHAR2(100);
		vr_cdagenci VARCHAR2(100);
		vr_nrdcaixa VARCHAR2(100);
		vr_idorigem VARCHAR2(100);
	  
		--Variaveis de Excecoes    
		vr_exc_erro  EXCEPTION;                                       

  BEGIN              
    --Inicializar Variaveis
    vr_cdcritic:= 0;                         
    vr_dscritic:= NULL;
    
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
    
		-- Chamar rotina para validação do token
		pc_valida_token_usuario(pr_cdcooper => vr_cdcooper
		                       ,pr_cdoperad => vr_cdoperad
													 ,pr_dstoken =>  pr_dstoken
													 ,pr_dscritic => vr_dscritic);
		
		-- Se retornou crítica
		IF trim(vr_dscritic) IS NOT NULL THEN
			-- Levanta exceção
			RAISE vr_exc_erro;
		END IF;
			
	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro:= 'NOK';
      
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
                                     
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';
      
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na CADA0011.pc_valida_token_usuario_web --> '|| SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
    END;                                    

  -- Rotina para tratar pessoa de relacao
  PROCEDURE pc_trata_pessoa_relacao(pr_idpessoa  IN tbcadast_pessoa.idpessoa%TYPE, -- ID da pessoa origem
                                    pr_tprelacao IN tbcadast_pessoa_relacao.tprelacao%TYPE, -- Tipo de relacao
                                    pr_nmpessoa  IN tbcadast_pessoa.nmpessoa%TYPE, -- Nome da pessoa de relacionamento
                                    pr_cdoperad  IN tbcadast_pessoa.cdoperad_altera%TYPE,  -- Operador da inclusao
                                    pr_cdcritic OUT INTEGER,          -- Codigo de erro
                                    pr_dscritic OUT VARCHAR2) IS      -- Retorno de Erro
    -- Cursor para verificar se a relacao existe
    CURSOR cr_relacao IS
      SELECT b.nmpessoa,
             a.nrseq_relacao
        FROM tbcadast_pessoa b,
             tbcadast_pessoa_relacao a
       WHERE a.idpessoa  = pr_idpessoa
         AND a.tprelacao = pr_tprelacao
         AND b.idpessoa  = a.idpessoa_relacao;
    rw_relacao cr_relacao%ROWTYPE;
    
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;

    -- Variaveis gerais
    vr_pessoa_relacao tbcadast_pessoa_relacao%ROWTYPE;
    
  BEGIN
    -- Verifica se a relacao existe
    OPEN cr_relacao;
    FETCH cr_relacao INTO rw_relacao;
    
    -- Se existe relacao
    IF cr_relacao%FOUND THEN
      -- Se o nome da pessoa de relacao for igual ao da pessoa que foi enviado
      IF rw_relacao.nmpessoa = pr_nmpessoa THEN
        CLOSE cr_relacao;
        RETURN; -- Nao faz nada, pois ja esta cadastrado
      ELSE
        -- Deve-se criar um prospect relacionando esta pessoa
        vr_pessoa_relacao.nrseq_relacao := rw_relacao.nrseq_relacao;
      END IF;
    END IF;
    CLOSE cr_relacao;
        
    -- Cria o prospect
    vr_pessoa_relacao.idpessoa_relacao := fn_cria_prospect(pr_nmpessoa => pr_nmpessoa,
                                                   pr_tppessoa => 1, -- Fisica
                                                   pr_cdoperad => pr_cdoperad,
                                                   pr_cdcritic => vr_cdcritic,
                                                   pr_dscritic => vr_dscritic);
    -- Verifica se deu erro
    IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Popula os dados da pessoa de relacao
    vr_pessoa_relacao.idpessoa        := pr_idpessoa;
    vr_pessoa_relacao.tprelacao       := pr_tprelacao;
    vr_pessoa_relacao.cdoperad_altera := pr_cdoperad;
    
    -- Efetua a associacao 
    cada0010.pc_cadast_pessoa_relacao(pr_pessoa_relacao => vr_pessoa_relacao,
                                      pr_cdcritic       => vr_cdcritic,
                                      pr_dscritic       => vr_dscritic);
    -- Verifica se deu erro
    IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_insere_pessoa_crapass: ' ||SQLERRM;
  END;                                    

  -- Rotina para inserir o email
  PROCEDURE pc_insere_email(pr_cdcooper crapcje.cdcooper%TYPE -- Codigo da cooperativa
                           ,pr_idpessoa tbcadast_pessoa.idpessoa%TYPE -- Identificador de pessoa
                           ,pr_nrdconta crapcje.nrdconta%TYPE -- Numero da conta
                           ,pr_idseqttl crapcje.idseqttl%TYPE -- Sequencia do titular
                           ,pr_cdoperad crapope.cdoperad%TYPE -- Codigo do operador que esta efetuando a operacao
                           ,pr_cdcritic OUT INTEGER           -- Codigo de erro
                           ,pr_dscritic OUT VARCHAR2) IS      -- Retorno de Erro

    -- Cursor sobre os emails
    CURSOR cr_crapcem IS
      SELECT a.dsdemail,
             a.nmpescto,
             a.secpscto,
             a.cddemail
        FROM crapcem a
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrdconta = pr_nrdconta
         AND a.idseqttl = pr_idseqttl;

    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
    
    -- Variaveis gerais
    vr_pessoa_email    tbcadast_pessoa_email%ROWTYPE;    -- Registro de email de pessoas
    
  BEGIN
    -- Loop sobre a tabela de emails
    FOR rw_crapcem IN cr_crapcem LOOP
      
      -- Popula os campos para inserir o registro
      vr_pessoa_email := NULL;
      vr_pessoa_email.nrseq_email := rw_crapcem.cddemail;
      vr_pessoa_email.idpessoa := pr_idpessoa;
      vr_pessoa_email.dsemail  := rw_crapcem.dsdemail;
      vr_pessoa_email.nmpessoa_contato := rw_crapcem.nmpescto;
      vr_pessoa_email.nmsetor_pessoa_contato := rw_crapcem.secpscto;
      vr_pessoa_email.cdoperad_altera := pr_cdoperad;
      
      -- Efetua a inclusao
      cada0010.pc_cadast_pessoa_email(pr_pessoa_email => vr_pessoa_email
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
    END LOOP; -- Fim do loop sobre o email
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_insere_email: ' ||SQLERRM;
  END;

  -- Rotina para inserir o bem
  PROCEDURE pc_insere_bem(pr_cdcooper crapcje.cdcooper%TYPE -- Codigo da cooperativa
                         ,pr_idpessoa tbcadast_pessoa.idpessoa%TYPE -- Identificador de pessoa
                         ,pr_nrdconta crapcje.nrdconta%TYPE -- Numero da conta
                         ,pr_idseqttl crapcje.idseqttl%TYPE -- Sequencia do titular
                         ,pr_cdoperad crapope.cdoperad%TYPE -- Codigo do operador que esta efetuando a operacao
                         ,pr_cdcritic OUT INTEGER           -- Codigo de erro
                         ,pr_dscritic OUT VARCHAR2) IS      -- Retorno de Erro

    -- Cursor sobre os bens
    CURSOR cr_crapbem IS
      SELECT a.dsrelbem,
             a.vlrdobem,
             a.persemon,
             a.qtprebem,
             a.vlprebem,
             a.dtaltbem,
             a.idseqbem
        FROM crapbem a
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrdconta = pr_nrdconta
         AND a.idseqttl = pr_idseqttl;

    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
    
    -- Variaveis gerais
    vr_pessoa_bem   tbcadast_pessoa_bem%ROWTYPE;    -- Registro de bem de pessoas
    
  BEGIN
    -- Loop sobre a tabela de emails
    FOR rw_crapbem IN cr_crapbem LOOP
      -- Popula os campos para inserir o registro
      vr_pessoa_bem := NULL;
      vr_pessoa_bem.idpessoa        := pr_idpessoa;
      vr_pessoa_bem.nrseq_bem       := rw_crapbem.idseqbem;
      vr_pessoa_bem.dsbem           := rw_crapbem.dsrelbem;
      vr_pessoa_bem.pebem           := greatest(rw_crapbem.persemon,0);
      vr_pessoa_bem.qtparcela_bem   := rw_crapbem.qtprebem;
      vr_pessoa_bem.vlbem           := rw_crapbem.vlrdobem;
      vr_pessoa_bem.vlparcela_bem   := rw_crapbem.vlprebem;
      vr_pessoa_bem.dtalteracao     := rw_crapbem.dtaltbem;
      vr_pessoa_bem.cdoperad_altera := pr_cdoperad;
      
      -- Efetua a inclusao
      cada0010.pc_cadast_pessoa_bem(pr_pessoa_bem => vr_pessoa_bem
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
    END LOOP; -- Fim do loop sobre o email
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_insere_bem: ' ||SQLERRM;
  END;

  -- Rotina para inserir os dados do banco para pessoa juridica
  PROCEDURE pc_insere_juridico_bco(pr_crapjfn  crapjfn%ROWTYPE -- Registro com os dados do financeiro
                                  ,pr_idpessoa tbcadast_pessoa.idpessoa%TYPE -- Identificador de pessoa
                                  ,pr_cdoperad crapope.cdoperad%TYPE -- Codigo do operador que esta efetuando a operacao
                                  ,pr_cdcritic OUT INTEGER           -- Codigo de erro
                                  ,pr_dscritic OUT VARCHAR2) IS      -- Retorno de Erro

    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
    
    -- Variaveis gerais
    vr_pessoa_banco   tbcadast_pessoa_juridica_bco%ROWTYPE;    -- Registro de banco do PJ

  BEGIN
   
    -- efetua loop sobre os registros
    FOR x IN 1..5 LOOP
      
      -- Inicializa a variavel
      vr_pessoa_banco := NULL;
      vr_pessoa_banco.idpessoa := pr_idpessoa;
      vr_pessoa_banco.cdoperad_altera := pr_cdoperad;
      vr_pessoa_banco.nrseq_banco := x;

      -- Verifica qual o banco devera ser utilizado
      IF x = 1 THEN
        vr_pessoa_banco.cdbanco      := pr_crapjfn.cddbanco##1;
        vr_pessoa_banco.dsoperacao   := pr_crapjfn.dstipope##1;
        vr_pessoa_banco.vloperacao   := pr_crapjfn.vlropera##1;
        vr_pessoa_banco.dsgarantia   := pr_crapjfn.garantia##1;
        -- Feito o processo abaixo, pois dentro do DSVENCTO pode vir escrito VARIOS
        BEGIN
          vr_pessoa_banco.dtvencimento := pr_crapjfn.dsvencto##1;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      ELSIF x = 2 THEN
        vr_pessoa_banco.cdbanco      := pr_crapjfn.cddbanco##2;
        vr_pessoa_banco.dsoperacao   := pr_crapjfn.dstipope##2;
        vr_pessoa_banco.vloperacao   := pr_crapjfn.vlropera##2;
        vr_pessoa_banco.dsgarantia   := pr_crapjfn.garantia##2;
        -- Feito o processo abaixo, pois dentro do DSVENCTO pode vir escrito VARIOS
        BEGIN
          vr_pessoa_banco.dtvencimento := pr_crapjfn.dsvencto##2;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      ELSIF x = 3 THEN
        vr_pessoa_banco.cdbanco      := pr_crapjfn.cddbanco##3;
        vr_pessoa_banco.dsoperacao   := pr_crapjfn.dstipope##3;
        vr_pessoa_banco.vloperacao   := pr_crapjfn.vlropera##3;
        vr_pessoa_banco.dsgarantia   := pr_crapjfn.garantia##3;
        -- Feito o processo abaixo, pois dentro do DSVENCTO pode vir escrito VARIOS
        BEGIN
          vr_pessoa_banco.dtvencimento := pr_crapjfn.dsvencto##3;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      ELSIF x = 4 THEN
        vr_pessoa_banco.cdbanco      := pr_crapjfn.cddbanco##4;
        vr_pessoa_banco.dsoperacao   := pr_crapjfn.dstipope##4;
        vr_pessoa_banco.vloperacao   := pr_crapjfn.vlropera##4;
        vr_pessoa_banco.dsgarantia   := pr_crapjfn.garantia##4;
        -- Feito o processo abaixo, pois dentro do DSVENCTO pode vir escrito VARIOS
        BEGIN
          vr_pessoa_banco.dtvencimento := pr_crapjfn.dsvencto##4;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      ELSE
        vr_pessoa_banco.cdbanco      := pr_crapjfn.cddbanco##5;
        vr_pessoa_banco.dsoperacao   := pr_crapjfn.dstipope##5;
        vr_pessoa_banco.vloperacao   := pr_crapjfn.vlropera##5;
        vr_pessoa_banco.dsgarantia   := pr_crapjfn.garantia##5;
        -- Feito o processo abaixo, pois dentro do DSVENCTO pode vir escrito VARIOS
        BEGIN
          vr_pessoa_banco.dtvencimento := pr_crapjfn.dsvencto##5;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      END IF;
      
      -- Verifica se existe informacao
      IF nvl(vr_pessoa_banco.cdbanco,0) <> 0 THEN
        -- Efetua a inclusao
        cada0010.pc_cadast_pessoa_juridica_bco(pr_pessoa_juridica_bco => vr_pessoa_banco
                                              ,pr_cdcritic => vr_cdcritic
                                              ,pr_dscritic => vr_dscritic);
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

      END IF;
      
    END LOOP;
        
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_insere_juridico_bco: ' ||SQLERRM;

  END;

  -- Rotina para inserir os dados do banco para pessoa juridica
  PROCEDURE pc_insere_juridico_fat(pr_crapjfn  crapjfn%ROWTYPE -- Registro com os dados do financeiro
                                  ,pr_idpessoa tbcadast_pessoa.idpessoa%TYPE -- Identificador de pessoa
                                  ,pr_cdoperad crapope.cdoperad%TYPE -- Codigo do operador que esta efetuando a operacao
                                  ,pr_cdcritic OUT INTEGER           -- Codigo de erro
                                  ,pr_dscritic OUT VARCHAR2) IS      -- Retorno de Erro

    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
    
    -- Variaveis gerais
    vr_pessoa_fat   tbcadast_pessoa_juridica_fat%ROWTYPE;    -- Registro de faturamento do PJ


  BEGIN

    -- efetua loop sobre os registros
    FOR x IN 1..12 LOOP
      
      -- Inicializa a variavel
      vr_pessoa_fat := NULL;
      vr_pessoa_fat.idpessoa := pr_idpessoa;
      vr_pessoa_fat.cdoperad_altera := pr_cdoperad;
      vr_pessoa_fat.nrseq_faturamento := x;

      -- Verifica qual o banco devera ser utilizado
      IF x = 1 THEN
        -- Feito o processo abaixo, pois pode gerar uma data invalida
        BEGIN
          vr_pessoa_fat.dtmes_referencia := to_date(to_char(pr_crapjfn.mesftbru##1,'fm00')||
                                                    pr_crapjfn.anoftbru##1,'MMYYYY'); 
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        vr_pessoa_fat.vlfaturamento_bruto := pr_crapjfn.vlrftbru##1;

      ELSIF x = 2 THEN
        -- Feito o processo abaixo, pois pode gerar uma data invalida
        BEGIN
          vr_pessoa_fat.dtmes_referencia := to_date(to_char(pr_crapjfn.mesftbru##2,'fm00')||
                                                    pr_crapjfn.anoftbru##2,'MMYYYY'); 
        EXCEPTION
          WHEN OTHERS THEN
            NULL;

        END;
        vr_pessoa_fat.vlfaturamento_bruto := pr_crapjfn.vlrftbru##2;

      ELSIF x = 3 THEN
        -- Feito o processo abaixo, pois pode gerar uma data invalida
        BEGIN
          vr_pessoa_fat.dtmes_referencia := to_date(to_char(pr_crapjfn.mesftbru##3,'fm00')||
                                                    pr_crapjfn.anoftbru##3,'MMYYYY'); 
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        vr_pessoa_fat.vlfaturamento_bruto := pr_crapjfn.vlrftbru##3;

      ELSIF x = 4 THEN
        -- Feito o processo abaixo, pois pode gerar uma data invalida
        BEGIN
          vr_pessoa_fat.dtmes_referencia := to_date(to_char(pr_crapjfn.mesftbru##4,'fm00')||
                                                    pr_crapjfn.anoftbru##4,'MMYYYY'); 
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        vr_pessoa_fat.vlfaturamento_bruto := pr_crapjfn.vlrftbru##4;

      ELSIF x = 5 THEN
        -- Feito o processo abaixo, pois pode gerar uma data invalida
        BEGIN
          vr_pessoa_fat.dtmes_referencia := to_date(to_char(pr_crapjfn.mesftbru##5,'fm00')||
                                                    pr_crapjfn.anoftbru##5,'MMYYYY'); 
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        vr_pessoa_fat.vlfaturamento_bruto := pr_crapjfn.vlrftbru##5;

      ELSIF x = 6 THEN
        -- Feito o processo abaixo, pois pode gerar uma data invalida
        BEGIN
          vr_pessoa_fat.dtmes_referencia := to_date(to_char(pr_crapjfn.mesftbru##6,'fm00')||
                                                    pr_crapjfn.anoftbru##6,'MMYYYY'); 
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        vr_pessoa_fat.vlfaturamento_bruto := pr_crapjfn.vlrftbru##6;

      ELSIF x = 7 THEN
        -- Feito o processo abaixo, pois pode gerar uma data invalida
        BEGIN
          vr_pessoa_fat.dtmes_referencia := to_date(to_char(pr_crapjfn.mesftbru##7,'fm00')||
                                                    pr_crapjfn.anoftbru##7,'MMYYYY'); 
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        vr_pessoa_fat.vlfaturamento_bruto := pr_crapjfn.vlrftbru##7;

      ELSIF x = 8 THEN
        -- Feito o processo abaixo, pois pode gerar uma data invalida
        BEGIN
          vr_pessoa_fat.dtmes_referencia := to_date(to_char(pr_crapjfn.mesftbru##8,'fm00')||
                                                    pr_crapjfn.anoftbru##8,'MMYYYY'); 
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        vr_pessoa_fat.vlfaturamento_bruto := pr_crapjfn.vlrftbru##8;

      ELSIF x = 9 THEN
        -- Feito o processo abaixo, pois pode gerar uma data invalida
        BEGIN
          vr_pessoa_fat.dtmes_referencia := to_date(to_char(pr_crapjfn.mesftbru##9,'fm00')||
                                                    pr_crapjfn.anoftbru##9,'MMYYYY'); 
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        vr_pessoa_fat.vlfaturamento_bruto := pr_crapjfn.vlrftbru##9;

      ELSIF x = 10 THEN
        -- Feito o processo abaixo, pois pode gerar uma data invalida
        BEGIN
          vr_pessoa_fat.dtmes_referencia := to_date(to_char(pr_crapjfn.mesftbru##10,'fm00')||
                                                    pr_crapjfn.anoftbru##10,'MMYYYY'); 
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        vr_pessoa_fat.vlfaturamento_bruto := pr_crapjfn.vlrftbru##10;

      ELSIF x = 11 THEN
        -- Feito o processo abaixo, pois pode gerar uma data invalida
        BEGIN
          vr_pessoa_fat.dtmes_referencia := to_date(to_char(pr_crapjfn.mesftbru##11,'fm00')||
                                                    pr_crapjfn.anoftbru##11,'MMYYYY'); 
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        vr_pessoa_fat.vlfaturamento_bruto := pr_crapjfn.vlrftbru##11;

      ELSE
        -- Feito o processo abaixo, pois pode gerar uma data invalida
        BEGIN
          vr_pessoa_fat.dtmes_referencia := to_date(to_char(pr_crapjfn.mesftbru##12,'fm00')||
                                                    pr_crapjfn.anoftbru##12,'MMYYYY'); 
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        vr_pessoa_fat.vlfaturamento_bruto := pr_crapjfn.vlrftbru##12;
      END IF;
    
      -- Verifica se existe informacao
      IF vr_pessoa_fat.dtmes_referencia IS NOT NULL THEN
        -- Efetua a inclusao
        cada0010.pc_cadast_pessoa_juridica_fat(pr_pessoa_juridica_fat => vr_pessoa_fat
                                              ,pr_cdcritic => vr_cdcritic
                                              ,pr_dscritic => vr_dscritic);
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;


      END IF;

      
    END LOOP;

        
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;


      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_insere_juridico_fat: ' ||SQLERRM;

  END;

  -- Rotina para inserir as empresas que a PJ possui participacao
  PROCEDURE pc_insere_juridico_ptp(pr_cdcooper crapcje.cdcooper%TYPE -- Codigo da cooperativa
                                  ,pr_idpessoa tbcadast_pessoa.idpessoa%TYPE -- Identificador de pessoa
                                  ,pr_nrdconta crapcje.nrdconta%TYPE -- Numero da conta
                                  ,pr_cdoperad crapope.cdoperad%TYPE -- Codigo do operador que esta efetuando a operacao
                                  ,pr_cdcritic OUT INTEGER           -- Codigo de erro
                                  ,pr_dscritic OUT VARCHAR2) IS      -- Retorno de Erro

    -- Cursor sobre os bens
    CURSOR cr_crapepa IS
      SELECT nrdocsoc, 
             nrctasoc, 
             nmfansia, 
             nrinsest, 
             natjurid, 
             dtiniatv, 
             qtfilial, 
             qtfuncio, 
             dsendweb, 
             cdseteco, 
             cdmodali, 
             cdrmativ, 
             vledvmto, 
             dtadmiss, 
             dtmvtolt, 
             persocio, 
             nmprimtl
        FROM crapepa a
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrdconta = pr_nrdconta;

    -- Busca os dados da conta do responsavel legal
    CURSOR cr_crapass(pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT nrcpfcgc
        FROM crapass
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    
    -- Verifica se o responsavel ja possui cadastro de pessoa
    CURSOR cr_pessoa(pr_nrcpfcgc tbcadast_pessoa.nrcpfcgc%TYPE) IS
      SELECT *
        FROM vwcadast_pessoa_juridica
       WHERE nrcnpj = pr_nrcpfcgc;
    rw_pessoa cr_pessoa%ROWTYPE;

    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
    
    -- Variaveis gerais
    vr_pessoa_ptp   tbcadast_pessoa_juridica_ptp%ROWTYPE;    -- Registro de participacoes da PJ em outras empresas
    vr_pessoa       vwcadast_pessoa_juridica%ROWTYPE;        -- Registro de pessoa juridica
    
  BEGIN
    -- Loop sobre a tabela de participacoes
    FOR rw_crapepa IN cr_crapepa LOOP
      -- Popula os campos para inserir o registro
      vr_pessoa_ptp := NULL;
      vr_pessoa_ptp.idpessoa        := pr_idpessoa;
      vr_pessoa_ptp.persocio        := rw_crapepa.persocio;
      vr_pessoa_ptp.dtadmissao      := rw_crapepa.dtadmiss;
      vr_pessoa_ptp.cdoperad_altera := pr_cdoperad;
      
      -- Se a empresa participante possui conta, busca os dados da conta dela
      IF rw_crapepa.nrctasoc > 0 THEN
        OPEN cr_crapass(pr_nrdconta => rw_crapepa.nrctasoc);
        FETCH cr_crapass INTO rw_crapass;
        IF cr_crapass%NOTFOUND THEN
          CLOSE cr_crapass;
          vr_dscritic := 'Nao encontrado a conta da empresa participante';
          RAISE vr_exc_erro;
        END IF;
        CLOSE cr_crapass;
        
        -- Verifica se esta empresa ja possui cadastro de pessoa
        OPEN cr_pessoa(pr_nrcpfcgc => rw_crapass.nrcpfcgc);
        FETCH cr_pessoa INTO rw_pessoa;
        -- Se nao existir pessoa cadastrada, deve-se efetuar o cadastro
        IF cr_pessoa%NOTFOUND THEN
          CLOSE cr_pessoa;
          -- Efetua a inclusao de pessoa
          cada0011.pc_insere_pessoa_crapass(pr_cdcooper => pr_cdcooper,
                                            pr_nrdconta => rw_crapepa.nrctasoc,
                                            pr_idseqttl => 1,
                                            pr_cdoperad => pr_cdoperad,
                                            pr_cdcritic => vr_cdcritic,
                                            pr_dscritic => vr_dscritic);
          -- Verifica se deu erro
          IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

          -- Busca a pessoa que foi cadastrada
          OPEN cr_pessoa(pr_nrcpfcgc => rw_crapass.nrcpfcgc);
          FETCH cr_pessoa INTO rw_pessoa;
          
        END IF;

        CLOSE cr_pessoa;
      ELSE -- Se nao possui conta

        rw_pessoa := NULL;
        -- Verifica se a empresa participante ja possui cadastro de pessoa
        OPEN cr_pessoa(pr_nrcpfcgc => rw_crapepa.nrdocsoc);
        FETCH cr_pessoa INTO rw_pessoa;
        -- Se nao existir pessoa cadastrada, deve-se efetuar o cadastro
        IF cr_pessoa%NOTFOUND OR nvl(rw_pessoa.tpcadastro,0) = 1 THEN
          CLOSE cr_pessoa;
          -- Efetua a inclusao de pessoa
          vr_pessoa := rw_pessoa;
          vr_pessoa.nrcnpj := rw_crapepa.nrdocsoc;
          vr_pessoa.cdoperad_altera     := pr_cdoperad;
          vr_pessoa.tpcadastro          := 1; -- Prospect
          vr_pessoa.tppessoa            := 2; -- Juridico
          vr_pessoa.nmfantasia           := rw_crapepa.nmfansia; 
          vr_pessoa.nrinscricao_estadual := rw_crapepa.nrinsest;
          IF nvl(rw_crapepa.natjurid,0) > 0 THEN
            vr_pessoa.cdnatureza_juridica  := rw_crapepa.natjurid;
          END IF;
          vr_pessoa.dtinicio_atividade   := rw_crapepa.dtiniatv;
          vr_pessoa.qtfilial             := rw_crapepa.qtfilial; 
          vr_pessoa.qtfuncionario        := rw_crapepa.qtfuncio; 
          vr_pessoa.dssite               := rw_crapepa.dsendweb; 
          vr_pessoa.cdsetor_economico    := rw_crapepa.cdseteco; 
          vr_pessoa.cdramo_atividade     := rw_crapepa.cdrmativ; 
          vr_pessoa.nmpessoa             := rw_crapepa.nmprimtl;

          -- Insere o Cadastro de pessoa juridica
          cada0010.pc_cadast_pessoa_juridica(pr_pessoa_juridica => vr_pessoa,
                                             pr_cdcritic        => vr_cdcritic,
                                             pr_dscritic        => vr_dscritic);
          IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

          -- Atualiza o IDPESSOA na variavel de uso
          rw_pessoa.idpessoa := vr_pessoa.idpessoa;
        ELSE
          CLOSE cr_pessoa;
        END IF; -- Fim da verificacao se a empresa de participacao ja possui cadastro como pessoa         

      END IF; -- Fim da verificacao se a empresa de participacao possui conta
      
      -- Atualiza o IDPESSOA da pessoa de participacao
      vr_pessoa_ptp.idpessoa_participacao := rw_pessoa.idpessoa;
      
      -- Efetua a inclusao
      cada0010.pc_cadast_pessoa_juridica_ptp(pr_pessoa_juridica_ptp => vr_pessoa_ptp
                                            ,pr_cdcritic            => vr_cdcritic
                                            ,pr_dscritic            => vr_dscritic);
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

    END LOOP; -- Fim do loop sobre as participacoes
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_insere_juridico_ptp: ' ||SQLERRM;

  END;

  -- Rotina para inserir os representantes da empresa PJ
  PROCEDURE pc_insere_juridico_rep(pr_cdcooper crapcje.cdcooper%TYPE -- Codigo da cooperativa
                                  ,pr_idpessoa tbcadast_pessoa.idpessoa%TYPE -- Identificador de pessoa
                                  ,pr_nrdconta crapcje.nrdconta%TYPE -- Numero da conta
                                  ,pr_cdoperad crapope.cdoperad%TYPE -- Codigo do operador que esta efetuando a operacao
                                  ,pr_cdcritic OUT INTEGER           -- Codigo de erro
                                  ,pr_dscritic OUT VARCHAR2) IS      -- Retorno de Erro

    -- Cursor sobre os representantes
    CURSOR cr_crapavt IS
      SELECT nrcpfcgc, 
             nmdavali, 
             nrcpfcjg, 
             tpdoccjg, 
             nrdoccjg, 
             tpdocava, 
             nrdocava, 
             dsendres##1, 
             nrfonres, 
             dsdemail, 
             tpctrato, 
             nrcepend, 
             nmcidade, 
             cdufresd, 
             dtmvtolt, 
             cdcooper, 
             nrendere, 
             complend, 
             nmbairro, 
             nrcxapst, 
             nrtelefo, 
             cddbanco, 
             cdagenci, 
             dsproftl, 
             nrdctato, 
             dtemddoc, 
             cdufddoc, 
             dtvalida, 
             nmmaecto, 
             nmpaicto, 
             dtnascto, 
             dsnatura, 
             cdsexcto, 
             cdestcvl, 
             dsrelbem##1, 
             dsrelbem##2, 
             dsrelbem##3, 
             dsrelbem##4, 
             dsrelbem##5, 
             dsrelbem##6, 
             persemon##1, 
             persemon##2, 
             persemon##3, 
             persemon##4, 
             persemon##5, 
             persemon##6, 
             qtprebem##1, 
             qtprebem##2, 
             qtprebem##3, 
             qtprebem##4, 
             qtprebem##5, 
             qtprebem##6, 
             vlprebem##1, 
             vlprebem##2, 
             vlprebem##3, 
             vlprebem##4, 
             vlprebem##5, 
             vlprebem##6, 
             vlrdobem##1, 
             vlrdobem##2, 
             vlrdobem##3, 
             vlrdobem##4, 
             vlrdobem##5, 
             vlrdobem##6, 
             vlrenmes, 
             vledvmto, 
             dtadmsoc, 
             persocio, 
             flgdepec, 
             vloutren, 
             dsoutren, 
             inhabmen, 
             dthabmen, 
             flgimpri, 
             progress_recid, 
             dtdrisco, 
             qtopescr, 
             qtifoper, 
             vltotsfn, 
             vlopescr, 
             vlprejuz, 
             idmsgvct, 
             cdnacion, 
             idorgexp
        FROM crapavt a
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrdconta = pr_nrdconta
         AND a.dsproftl <> 'PROCURADOR' -- Nao sera levado procuradores
         AND a.tpctrato = 6; -- Representante


    -- Busca os dados da conta do responsavel legal
    CURSOR cr_crapass(pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT nrcpfcgc
        FROM crapass
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta;

    rw_crapass cr_crapass%ROWTYPE;
    
    -- Verifica se o responsavel ja possui cadastro de pessoa
    CURSOR cr_pessoa(pr_nrcpfcgc tbcadast_pessoa.nrcpfcgc%TYPE) IS
      SELECT idpessoa
        FROM tbcadast_pessoa
       WHERE nrcpfcgc = pr_nrcpfcgc;

    rw_pessoa cr_pessoa%ROWTYPE;

    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
    
    -- Variaveis gerais
    vr_pessoa_rep   tbcadast_pessoa_juridica_rep%ROWTYPE;    -- Registro de participacoes da PJ em outras empresas
    vr_pessoa       vwcadast_pessoa_fisica%ROWTYPE;          -- Registro de pessoa fisica
    vr_pessoa_endereco tbcadast_pessoa_endereco%ROWTYPE;     -- Registro de endereco da pessoa
    vr_pessoa_bem      tbcadast_pessoa_bem%ROWTYPE;          -- Registro de bens da pessoa
  BEGIN
    -- Loop sobre a tabela de representantes
    FOR rw_crapavt IN cr_crapavt LOOP
      -- Popula os campos para inserir o registro
      vr_pessoa_rep := NULL;
      vr_pessoa_rep.idpessoa := pr_idpessoa;
      vr_pessoa_rep.persocio := rw_crapavt.persocio;
      pc_trata_representante(pr_dsproftl              => rw_crapavt.dsproftl,
                             pt_tpcargo_representante => vr_pessoa_rep.tpcargo_representante,
                             pr_dscritic              => vr_dscritic);
      vr_pessoa_rep.dtvigencia := rw_crapavt.dtvalida;
      vr_pessoa_rep.dtadmissao := rw_crapavt.dtadmsoc;
      vr_pessoa_rep.flgdependencia_economica := rw_crapavt.flgdepec;
      vr_pessoa_rep.cdoperad_altera := pr_cdoperad;
      
      -- Se a empresa participante possui conta, busca os dados da conta dela
      IF rw_crapavt.nrdctato > 0 THEN
        OPEN cr_crapass(pr_nrdconta => rw_crapavt.nrdctato);
        FETCH cr_crapass INTO rw_crapass;
        IF cr_crapass%NOTFOUND THEN
          CLOSE cr_crapass;
          vr_dscritic := 'Nao encontrado a conta do representante';
          RAISE vr_exc_erro;
        END IF;
        CLOSE cr_crapass;
        
        -- Verifica se esta empresa ja possui cadastro de pessoa
        OPEN cr_pessoa(pr_nrcpfcgc => rw_crapass.nrcpfcgc);
        FETCH cr_pessoa INTO rw_pessoa;
        -- Se nao existir pessoa cadastrada, deve-se efetuar o cadastro
        IF cr_pessoa%NOTFOUND THEN
          CLOSE cr_pessoa;
          -- Efetua a inclusao de pessoa
          cada0011.pc_insere_pessoa_crapass(pr_cdcooper => pr_cdcooper,
                                            pr_nrdconta => rw_crapavt.nrdctato,
                                            pr_idseqttl => 1,
                                            pr_cdoperad => pr_cdoperad,
                                            pr_cdcritic => vr_cdcritic,
                                            pr_dscritic => vr_dscritic);
          -- Verifica se deu erro
          IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

          -- Busca a pessoa que foi cadastrada
          OPEN cr_pessoa(pr_nrcpfcgc => rw_crapass.nrcpfcgc);
          FETCH cr_pessoa INTO rw_pessoa;
          
        END IF;

        CLOSE cr_pessoa;
      ELSE -- Se nao possui conta

        -- Verifica se a empresa participante ja possui cadastro de pessoa
        OPEN cr_pessoa(pr_nrcpfcgc => rw_crapavt.nrcpfcgc);
        FETCH cr_pessoa INTO rw_pessoa;
        -- Se nao existir pessoa cadastrada, deve-se efetuar o cadastro
        IF cr_pessoa%NOTFOUND THEN
          CLOSE cr_pessoa;
          
          -- Efetua a inclusao de pessoa
          vr_pessoa := NULL;
          vr_pessoa.nrcpf               := rw_crapavt.nrcpfcgc;
          vr_pessoa.cdoperad_altera     := pr_cdoperad;
          vr_pessoa.tpcadastro          := 2; -- Basico
          vr_pessoa.tppessoa            := 1; -- Fisica
          vr_pessoa.nmpessoa            := rw_crapavt.nmdavali;
          vr_pessoa.tpdocumento         := rw_crapavt.tpdocava;
          vr_pessoa.nrdocumento         := rw_crapavt.nrdocava;
          IF rw_crapavt.idorgexp <> 0 THEN
            vr_pessoa.idorgao_expedidor := rw_crapavt.idorgexp;
          END IF;
          vr_pessoa.dtemissao_documento := rw_crapavt.dtemddoc;
          vr_pessoa.cduf_orgao_expedidor:= trim(rw_crapavt.cdufddoc);
          vr_pessoa.dtnascimento        := rw_crapavt.dtnascto;
          vr_pessoa.tpsexo              := rw_crapavt.cdsexcto;
          IF nvl(rw_crapavt.cdestcvl,0) > 0 THEN
            vr_pessoa.cdestado_civil      := rw_crapavt.cdestcvl;
          END IF;
          vr_pessoa.inhabilitacao_menor := rw_crapavt.inhabmen;
          vr_pessoa.dthabilitacao_menor := rw_crapavt.dthabmen;
          IF nvl(rw_crapavt.cdnacion,0) <> 0 THEN
            vr_pessoa.cdnacionalidade  := rw_crapavt.cdnacion;
          END IF;
          
          -- Busca o municipio da naturalidade
          CADA0015.pc_trata_municipio(pr_dscidade => rw_crapavt.dsnatura,
                                      pr_cdestado => NULL,
                                      pr_idcidade => vr_pessoa.cdnaturalidade,
                                      pr_dscritic => vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

          -- Insere o Cadastro de pessoa fisica
          cada0010.pc_cadast_pessoa_fisica(pr_pessoa_fisica => vr_pessoa,
                                           pr_cdcritic      => vr_cdcritic,
                                           pr_dscritic      => vr_dscritic);
          IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          
          -- Atualiza o IDPESSOA na variavel de uso
          rw_pessoa.idpessoa := vr_pessoa.idpessoa;

          -- Efetua tratativa pai
          IF trim(rw_crapavt.nmpaicto) IS NOT NULL THEN
            pc_trata_pessoa_relacao(pr_idpessoa => vr_pessoa.idpessoa,
                                    pr_tprelacao=> 3, -- Pai
                                    pr_nmpessoa => rw_crapavt.nmpaicto,
                                    pr_cdoperad => pr_cdoperad,
                                    pr_cdcritic => vr_cdcritic,
                                    pr_dscritic => vr_dscritic);
            IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
          END IF;

          -- Efetua tratativa mae
          IF trim(rw_crapavt.nmmaecto) IS NOT NULL THEN
            pc_trata_pessoa_relacao(pr_idpessoa => vr_pessoa.idpessoa,
                                    pr_tprelacao=> 4, -- Mae
                                    pr_nmpessoa => rw_crapavt.nmmaecto,
                                    pr_cdoperad => pr_cdoperad,
                                    pr_cdcritic => vr_cdcritic,
                                    pr_dscritic => vr_dscritic);
            IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
          END IF;

          -- Efetua a tratativa de endereco
          vr_pessoa_endereco                 := NULL;
          vr_pessoa_endereco.idpessoa        := vr_pessoa.idpessoa;
          vr_pessoa_endereco.tpendereco      := 10; --Residencial
          vr_pessoa_endereco.nrcep           := rw_crapavt.nrcepend;
          vr_pessoa_endereco.nmlogradouro    := rw_crapavt.dsendres##1; 
          vr_pessoa_endereco.nrlogradouro    := rw_crapavt.nrendere; 
          vr_pessoa_endereco.dscomplemento   := rw_crapavt.complend; 
          vr_pessoa_endereco.nmbairro        := rw_crapavt.nmbairro; 
          vr_pessoa_endereco.cdoperad_altera := pr_cdoperad;
          -- Trata o municipio
          IF TRIM(rw_crapavt.nmcidade) IS NOT NULL THEN
            -- Busca o ID do municipio
            CADA0015.pc_trata_municipio(pr_dscidade => TRIM(rw_crapavt.nmcidade),
                               pr_cdestado => rw_crapavt.cdufresd,
                               pr_idcidade => vr_pessoa_endereco.idcidade,
                               pr_dscritic => vr_dscritic);
            IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
          END IF;
          -- Efetua a inclusao
          cada0010.pc_cadast_pessoa_endereco(pr_pessoa_endereco => vr_pessoa_endereco
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);
          IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

          -- Efetua a tratativa de bens
          -- Efetua loop sobre os bens
          FOR x IN 1..6 LOOP
            vr_pessoa_bem := NULL;
            vr_pessoa_bem.idpessoa        := vr_pessoa.idpessoa;
            vr_pessoa_bem.cdoperad_altera := pr_cdoperad;
            vr_pessoa_bem.dtalteracao     := rw_crapavt.dtmvtolt;

            IF x = 1 THEN
              -- Se nao tiver bem cadastrado
              IF TRIM(rw_crapavt.dsrelbem##1) IS NULL THEN
                continue;
              END IF;
              -- Popula os campos para inserir o registro
              vr_pessoa_bem.nrseq_bem       := 1;
              vr_pessoa_bem.dsbem           := rw_crapavt.dsrelbem##1;
              vr_pessoa_bem.pebem           := greatest(0,rw_crapavt.persemon##1);
              vr_pessoa_bem.qtparcela_bem   := rw_crapavt.qtprebem##1;
              vr_pessoa_bem.vlbem           := rw_crapavt.vlrdobem##1;
              vr_pessoa_bem.vlparcela_bem   := rw_crapavt.vlprebem##1;
            ELSIF x = 2 THEN
              -- Se nao tiver bem cadastrado
              IF TRIM(rw_crapavt.dsrelbem##2) IS NULL THEN
                continue;
              END IF;
              -- Popula os campos para inserir o registro
              vr_pessoa_bem.nrseq_bem       := 2;
              vr_pessoa_bem.dsbem           := rw_crapavt.dsrelbem##2;
              vr_pessoa_bem.pebem           := greatest(0,rw_crapavt.persemon##2);
              vr_pessoa_bem.qtparcela_bem   := rw_crapavt.qtprebem##2;
              vr_pessoa_bem.vlbem           := rw_crapavt.vlrdobem##2;
              vr_pessoa_bem.vlparcela_bem   := rw_crapavt.vlprebem##2;
            ELSIF x = 3 THEN
              -- Se nao tiver bem cadastrado
              IF TRIM(rw_crapavt.dsrelbem##3) IS NULL THEN
                continue;
              END IF;
              -- Popula os campos para inserir o registro
              vr_pessoa_bem.nrseq_bem       := 3;
              vr_pessoa_bem.dsbem           := rw_crapavt.dsrelbem##3;
              vr_pessoa_bem.pebem           := greatest(0,rw_crapavt.persemon##3);
              vr_pessoa_bem.qtparcela_bem   := rw_crapavt.qtprebem##3;
              vr_pessoa_bem.vlbem           := rw_crapavt.vlrdobem##3;
              vr_pessoa_bem.vlparcela_bem   := rw_crapavt.vlprebem##3;
            ELSIF x = 4 THEN
              -- Se nao tiver bem cadastrado
              IF TRIM(rw_crapavt.dsrelbem##4) IS NULL THEN
                continue;
              END IF;
              -- Popula os campos para inserir o registro
              vr_pessoa_bem.nrseq_bem       := 4;
              vr_pessoa_bem.dsbem           := rw_crapavt.dsrelbem##4;
              vr_pessoa_bem.pebem           := greatest(0,rw_crapavt.persemon##4);
              vr_pessoa_bem.qtparcela_bem   := rw_crapavt.qtprebem##4;
              vr_pessoa_bem.vlbem           := rw_crapavt.vlrdobem##4;
              vr_pessoa_bem.vlparcela_bem   := rw_crapavt.vlprebem##4;
            ELSIF x = 5 THEN
              -- Se nao tiver bem cadastrado
              IF TRIM(rw_crapavt.dsrelbem##5) IS NULL THEN
                continue;
              END IF;
              -- Popula os campos para inserir o registro
              vr_pessoa_bem.nrseq_bem       := 5;
              vr_pessoa_bem.dsbem           := rw_crapavt.dsrelbem##5;
              vr_pessoa_bem.pebem           := greatest(0,rw_crapavt.persemon##5);
              vr_pessoa_bem.qtparcela_bem   := rw_crapavt.qtprebem##5;
              vr_pessoa_bem.vlbem           := rw_crapavt.vlrdobem##5;
              vr_pessoa_bem.vlparcela_bem   := rw_crapavt.vlprebem##5;
            ELSE
              -- Se nao tiver bem cadastrado
              IF TRIM(rw_crapavt.dsrelbem##6) IS NULL THEN
                continue;
              END IF;
              -- Popula os campos para inserir o registro
              vr_pessoa_bem.nrseq_bem       := 6;
              vr_pessoa_bem.dsbem           := rw_crapavt.dsrelbem##6;
              vr_pessoa_bem.pebem           := greatest(0,rw_crapavt.persemon##6);
              vr_pessoa_bem.qtparcela_bem   := rw_crapavt.qtprebem##6;
              vr_pessoa_bem.vlbem           := rw_crapavt.vlrdobem##6;
              vr_pessoa_bem.vlparcela_bem   := rw_crapavt.vlprebem##6;
            END IF;
            -- Efetua a inclusao
            cada0010.pc_cadast_pessoa_bem(pr_pessoa_bem => vr_pessoa_bem
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
            IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
          END LOOP;
        ELSE
          CLOSE cr_pessoa;
        END IF; -- Fim da verificacao se o representante ja possui cadastro como pessoa

      END IF; -- Fim da verificacao se o representante possui conta
      
      -- Atualiza o IDPESSOA da pessoa do representante
      vr_pessoa_rep.idpessoa_representante := rw_pessoa.idpessoa;
      
      -- Efetua a inclusao
      cada0010.pc_cadast_pessoa_juridica_rep(pr_pessoa_juridica_rep => vr_pessoa_rep
                                            ,pr_cdcritic            => vr_cdcritic
                                            ,pr_dscritic            => vr_dscritic);
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

    END LOOP; -- Fim do loop sobre os representantes
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_insere_juridico_rep: ' ||SQLERRM;
  END;

  -- Rotina para inserir o procurador ou avalista
  -- Se alterar esta rotina, verificar para alterar tambem a pc_insere_juridico_rep
  PROCEDURE pc_insere_procurador_avalista(pr_rowid    ROWID                 -- Rowid da tabela CRAPAVT
                                         ,pr_cdoperad crapope.cdoperad%TYPE -- Codigo do operador que esta efetuando a operacao
                                         ,pr_cdcritic OUT INTEGER           -- Codigo de erro
                                         ,pr_dscritic OUT VARCHAR2) IS      -- Retorno de Erro

    -- Cursor sobre os representantes
    CURSOR cr_crapavt IS
      SELECT nrcpfcgc, 
             nmdavali, 
             nrcpfcjg, 
             tpdoccjg, 
             nrdoccjg, 
             tpdocava, 
             nrdocava, 
             dsendres##1, 
             nrfonres, 
             dsdemail, 
             tpctrato, 
             nrcepend, 
             nmcidade, 
             cdufresd, 
             dtmvtolt, 
             cdcooper, 
             nrendere, 
             complend, 
             nmbairro, 
             nrcxapst, 
             nrtelefo, 
             cddbanco, 
             cdagenci, 
             dsproftl, 
             nrdctato, 
             dtemddoc, 
             cdufddoc, 
             dtvalida, 
             nmmaecto, 
             nmpaicto, 
             dtnascto, 
             dsnatura, 
             cdsexcto, 
             cdestcvl, 
             dsrelbem##1, 
             dsrelbem##2, 
             dsrelbem##3, 
             dsrelbem##4, 
             dsrelbem##5, 
             dsrelbem##6, 
             persemon##1, 
             persemon##2, 
             persemon##3, 
             persemon##4, 
             persemon##5, 
             persemon##6, 
             qtprebem##1, 
             qtprebem##2, 
             qtprebem##3, 
             qtprebem##4, 
             qtprebem##5, 
             qtprebem##6, 
             vlprebem##1, 
             vlprebem##2, 
             vlprebem##3, 
             vlprebem##4, 
             vlprebem##5, 
             vlprebem##6, 
             vlrdobem##1, 
             vlrdobem##2, 
             vlrdobem##3, 
             vlrdobem##4, 
             vlrdobem##5, 
             vlrdobem##6, 
             vlrenmes, 
             vledvmto, 
             dtadmsoc, 
             persocio, 
             flgdepec, 
             vloutren, 
             dsoutren, 
             inhabmen, 
             dthabmen, 
             flgimpri, 
             progress_recid, 
             dtdrisco, 
             qtopescr, 
             qtifoper, 
             vltotsfn, 
             vlopescr, 
             vlprejuz, 
             idmsgvct, 
             cdnacion, 
             idorgexp
        FROM crapavt a
       WHERE ROWID = pr_rowid;
    rw_crapavt cr_crapavt%ROWTYPE;

    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
    
    -- Variaveis gerais
    vr_pessoa       vwcadast_pessoa_fisica%ROWTYPE;          -- Registro de pessoa fisica
    vr_pessoa_endereco tbcadast_pessoa_endereco%ROWTYPE;     -- Registro de endereco da pessoa
    vr_pessoa_bem      tbcadast_pessoa_bem%ROWTYPE;          -- Registro de bens da pessoa
  BEGIN
    -- Busca o procurador ou avalista
    OPEN cr_crapavt;
    FETCH cr_crapavt INTO rw_crapavt;
    CLOSE cr_crapavt;
      
    -- Efetua a inclusao de pessoa
    vr_pessoa := NULL;
    vr_pessoa.nrcpf               := rw_crapavt.nrcpfcgc;
    vr_pessoa.cdoperad_altera     := pr_cdoperad;
    vr_pessoa.tpcadastro          := 1; -- Prospect
    vr_pessoa.tppessoa            := 1; -- Fisica
    vr_pessoa.nmpessoa            := rw_crapavt.nmdavali;
    vr_pessoa.tpdocumento         := rw_crapavt.tpdocava;
    vr_pessoa.nrdocumento         := rw_crapavt.nrdocava;
    IF rw_crapavt.idorgexp <> 0 THEN
      vr_pessoa.idorgao_expedidor := rw_crapavt.idorgexp;
    END IF;
    vr_pessoa.dtemissao_documento := rw_crapavt.dtemddoc;
    IF TRIM(rw_crapavt.cdufddoc) IS NOT NULL THEN
      vr_pessoa.cduf_orgao_expedidor:= rw_crapavt.cdufddoc;
    END IF;
    vr_pessoa.dtnascimento        := rw_crapavt.dtnascto;
    vr_pessoa.tpsexo              := rw_crapavt.cdsexcto;
    IF nvl(rw_crapavt.cdestcvl,0) > 0 THEN
      vr_pessoa.cdestado_civil      := rw_crapavt.cdestcvl;
    END IF;
    vr_pessoa.inhabilitacao_menor := rw_crapavt.inhabmen;
    vr_pessoa.dthabilitacao_menor := rw_crapavt.dthabmen;
    IF nvl(rw_crapavt.cdnacion,0) <> 0 THEN
      vr_pessoa.cdnacionalidade  := rw_crapavt.cdnacion;
    END IF;
          
    -- Busca o municipio da naturalidade
    CADA0015.pc_trata_municipio(pr_dscidade => rw_crapavt.dsnatura,
                                pr_cdestado => NULL,
                                pr_idcidade => vr_pessoa.cdnaturalidade,
                                pr_dscritic => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Insere o Cadastro de pessoa fisica
    cada0010.pc_cadast_pessoa_fisica(pr_pessoa_fisica => vr_pessoa,
                                     pr_cdcritic      => vr_cdcritic,
                                     pr_dscritic      => vr_dscritic);
    IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
          
    -- Efetua tratativa pai
    IF trim(rw_crapavt.nmpaicto) IS NOT NULL THEN
      pc_trata_pessoa_relacao(pr_idpessoa => vr_pessoa.idpessoa,
                              pr_tprelacao=> 3, -- Pai
                              pr_nmpessoa => rw_crapavt.nmpaicto,
                              pr_cdoperad => pr_cdoperad,
                              pr_cdcritic => vr_cdcritic,
                              pr_dscritic => vr_dscritic);
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;

    -- Efetua tratativa mae
    IF trim(rw_crapavt.nmmaecto) IS NOT NULL THEN
      pc_trata_pessoa_relacao(pr_idpessoa => vr_pessoa.idpessoa,
                              pr_tprelacao=> 4, -- Mae
                              pr_nmpessoa => rw_crapavt.nmmaecto,
                              pr_cdoperad => pr_cdoperad,
                              pr_cdcritic => vr_cdcritic,
                              pr_dscritic => vr_dscritic);
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;

    -- Efetua a tratativa de endereco
    vr_pessoa_endereco                 := NULL;
    vr_pessoa_endereco.idpessoa        := vr_pessoa.idpessoa;
    vr_pessoa_endereco.tpendereco      := 10; --Residencial
    vr_pessoa_endereco.nrcep           := rw_crapavt.nrcepend;
    vr_pessoa_endereco.nmlogradouro    := rw_crapavt.dsendres##1; 
    vr_pessoa_endereco.nrlogradouro    := rw_crapavt.nrendere; 
    vr_pessoa_endereco.dscomplemento   := rw_crapavt.complend; 
    vr_pessoa_endereco.nmbairro        := rw_crapavt.nmbairro; 
    vr_pessoa_endereco.cdoperad_altera := pr_cdoperad;
    -- Trata o municipio
    IF TRIM(rw_crapavt.nmcidade) IS NOT NULL THEN
      -- Busca o ID do municipio
      CADA0015.pc_trata_municipio(pr_dscidade => TRIM(rw_crapavt.nmcidade),
                         pr_cdestado => rw_crapavt.cdufresd,
                         pr_idcidade => vr_pessoa_endereco.idcidade,
                         pr_dscritic => vr_dscritic);
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;
    -- Efetua a inclusao
    cada0010.pc_cadast_pessoa_endereco(pr_pessoa_endereco => vr_pessoa_endereco
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic);
    IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Efetua a tratativa de bens
    -- Efetua loop sobre os bens
    FOR x IN 1..6 LOOP
      vr_pessoa_bem := NULL;
      vr_pessoa_bem.idpessoa        := vr_pessoa.idpessoa;
      vr_pessoa_bem.cdoperad_altera := pr_cdoperad;
      vr_pessoa_bem.dtalteracao     := rw_crapavt.dtmvtolt;

      IF x = 1 THEN
        -- Se nao tiver bem cadastrado
        IF TRIM(rw_crapavt.dsrelbem##1) IS NULL THEN
          continue;
        END IF;
        -- Popula os campos para inserir o registro
        vr_pessoa_bem.nrseq_bem       := 1;
        vr_pessoa_bem.dsbem           := rw_crapavt.dsrelbem##1;
        vr_pessoa_bem.pebem           := greatest(0,rw_crapavt.persemon##1);
        vr_pessoa_bem.qtparcela_bem   := rw_crapavt.qtprebem##1;
        vr_pessoa_bem.vlbem           := rw_crapavt.vlrdobem##1;
        vr_pessoa_bem.vlparcela_bem   := rw_crapavt.vlprebem##1;
      ELSIF x = 2 THEN
        -- Se nao tiver bem cadastrado
        IF TRIM(rw_crapavt.dsrelbem##2) IS NULL THEN
          continue;
        END IF;
        -- Popula os campos para inserir o registro
        vr_pessoa_bem.nrseq_bem       := 2;
        vr_pessoa_bem.dsbem           := rw_crapavt.dsrelbem##2;
        vr_pessoa_bem.pebem           := greatest(0,rw_crapavt.persemon##2);
        vr_pessoa_bem.qtparcela_bem   := rw_crapavt.qtprebem##2;
        vr_pessoa_bem.vlbem           := rw_crapavt.vlrdobem##2;
        vr_pessoa_bem.vlparcela_bem   := rw_crapavt.vlprebem##2;
      ELSIF x = 3 THEN
        -- Se nao tiver bem cadastrado
        IF TRIM(rw_crapavt.dsrelbem##3) IS NULL THEN
          continue;
        END IF;
        -- Popula os campos para inserir o registro
        vr_pessoa_bem.nrseq_bem       := 3;
        vr_pessoa_bem.dsbem           := rw_crapavt.dsrelbem##3;
        vr_pessoa_bem.pebem           := greatest(0,rw_crapavt.persemon##3);
        vr_pessoa_bem.qtparcela_bem   := rw_crapavt.qtprebem##3;
        vr_pessoa_bem.vlbem           := rw_crapavt.vlrdobem##3;
        vr_pessoa_bem.vlparcela_bem   := rw_crapavt.vlprebem##3;
      ELSIF x = 4 THEN
        -- Se nao tiver bem cadastrado
        IF TRIM(rw_crapavt.dsrelbem##4) IS NULL THEN
          continue;
        END IF;
        -- Popula os campos para inserir o registro
        vr_pessoa_bem.nrseq_bem       := 4;
        vr_pessoa_bem.dsbem           := rw_crapavt.dsrelbem##4;
        vr_pessoa_bem.pebem           := greatest(0,rw_crapavt.persemon##4);
        vr_pessoa_bem.qtparcela_bem   := rw_crapavt.qtprebem##4;
        vr_pessoa_bem.vlbem           := rw_crapavt.vlrdobem##4;
        vr_pessoa_bem.vlparcela_bem   := rw_crapavt.vlprebem##4;
      ELSIF x = 5 THEN
        -- Se nao tiver bem cadastrado
        IF TRIM(rw_crapavt.dsrelbem##5) IS NULL THEN
          continue;
        END IF;
        -- Popula os campos para inserir o registro
        vr_pessoa_bem.nrseq_bem       := 5;
        vr_pessoa_bem.dsbem           := rw_crapavt.dsrelbem##5;
        vr_pessoa_bem.pebem           := greatest(0,rw_crapavt.persemon##5);
        vr_pessoa_bem.qtparcela_bem   := rw_crapavt.qtprebem##5;
        vr_pessoa_bem.vlbem           := rw_crapavt.vlrdobem##5;
        vr_pessoa_bem.vlparcela_bem   := rw_crapavt.vlprebem##5;
      ELSE
        -- Se nao tiver bem cadastrado
        IF TRIM(rw_crapavt.dsrelbem##6) IS NULL THEN
          continue;
        END IF;
        -- Popula os campos para inserir o registro
        vr_pessoa_bem.nrseq_bem       := 6;
        vr_pessoa_bem.dsbem           := rw_crapavt.dsrelbem##6;
        vr_pessoa_bem.pebem           := greatest(0,rw_crapavt.persemon##6);
        vr_pessoa_bem.qtparcela_bem   := rw_crapavt.qtprebem##6;
        vr_pessoa_bem.vlbem           := rw_crapavt.vlrdobem##6;
        vr_pessoa_bem.vlparcela_bem   := rw_crapavt.vlprebem##6;
      END IF;
      -- Efetua a inclusao
      cada0010.pc_cadast_pessoa_bem(pr_pessoa_bem => vr_pessoa_bem
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END LOOP;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_insere_procurador_avalista: ' ||SQLERRM;

  END;

  -- Rotina para inserir as pessoas de referencia
  PROCEDURE pc_insere_referencia(pr_cdcooper crapcje.cdcooper%TYPE -- Codigo da cooperativa
                                ,pr_idpessoa tbcadast_pessoa.idpessoa%TYPE -- Identificador de pessoa
                                ,pr_nrdconta crapcje.nrdconta%TYPE -- Numero da conta
                                ,pr_idseqttl crapcje.idseqttl%TYPE -- Sequencia do titular
                                ,pr_cdoperad crapope.cdoperad%TYPE -- Codigo do operador que esta efetuando a operacao
                                ,pr_cdcritic OUT INTEGER           -- Codigo de erro
                                ,pr_dscritic OUT VARCHAR2) IS      -- Retorno de Erro
 
    -- Cursor sobre as pessoas de referencia
    CURSOR cr_crapavt IS
      SELECT nrcpfcgc, 
             nrctremp, 
             nmdavali, 
             nrcpfcjg, 
             tpdoccjg, 
             nrdoccjg, 
             tpdocava, 
             nrdocava, 
             dsendres##1, 
             dsendres##2, 
             nrfonres, 
             dsdemail, 
             tpctrato, 
             nrcepend, 
             nmcidade, 
             cdufresd, 
             dtmvtolt, 
             cdcooper, 
             nrendere, 
             complend, 
             nmbairro, 
             nrcxapst, 
             nrtelefo, 
             cddbanco, 
             cdagenci, 
             dsproftl, 
             nrdctato, 
             dtemddoc, 
             cdufddoc, 
             dtvalida, 
             nmmaecto, 
             nmpaicto, 
             dtnascto, 
             dsnatura, 
             cdsexcto, 
             cdestcvl, 
             vlrenmes, 
             vledvmto, 
             dtadmsoc, 
             persocio, 
             flgdepec, 
             vloutren, 
             dsoutren, 
             inhabmen, 
             dthabmen, 
             flgimpri, 
             inpessoa, 
             dtdrisco, 
             qtopescr, 
             qtifoper, 
             vltotsfn, 
             vlopescr, 
             vlprejuz, 
             idmsgvct, 
             cdnacion, 
             idorgexp
        FROM crapavt a
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrdconta = pr_nrdconta
         AND a.tpctrato = 5 -- Pessoa de contato
         AND a.nrctremp = decode(pr_idseqttl, 0, a.nrctremp, pr_idseqttl);
         -- A linha acima eh necessario porque se for uma PF, o indicador de titular 
         -- eh gravado na NRCTREMP. Se for uma PJ, este numero eh apenas um sequencial
         -- ou seja, tem modos de gravar diferentes de PJ para PF 

    -- Busca os dados da conta do responsavel legal
    CURSOR cr_crapass(pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT nrcpfcgc
        FROM crapass
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta;

    rw_crapass cr_crapass%ROWTYPE;
    
    -- Verifica se o responsavel ja possui cadastro de pessoa
    CURSOR cr_pessoa(pr_nrcpfcgc tbcadast_pessoa.nrcpfcgc%TYPE) IS
      SELECT idpessoa
        FROM tbcadast_pessoa
       WHERE nrcpfcgc = pr_nrcpfcgc;

    rw_pessoa cr_pessoa%ROWTYPE;

    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
    
    -- Variaveis gerais
    vr_pessoa_ref   tbcadast_pessoa_referencia%ROWTYPE;      -- Registro de pessoas de referencia
    vr_pessoa       vwcadast_pessoa_fisica%ROWTYPE;          -- Registro de pessoa fisica
    vr_pessoa_endereco tbcadast_pessoa_endereco%ROWTYPE;     -- Registro de endereco da pessoa
    vr_pessoa_email    tbcadast_pessoa_email%ROWTYPE;        -- Registro de email de pessoas
    vr_pessoa_telefone tbcadast_pessoa_telefone%ROWTYPE;     -- Registro de telefone de pessoas

    vr_nrddd          tbcadast_pessoa_telefone.nrddd%TYPE; -- Numero do DDD
    vr_nrtelefone     tbcadast_pessoa_telefone.nrtelefone%TYPE; -- Numero do telefone
    vr_nrramal        tbcadast_pessoa_telefone.nrramal%TYPE; -- Numero do Ramal
    
  BEGIN
    -- Loop sobre a tabela de pessoas de referencia
    FOR rw_crapavt IN cr_crapavt LOOP
      -- Popula os campos para inserir o registro
      vr_pessoa_ref := NULL;
      vr_pessoa_ref.idpessoa := pr_idpessoa;
      vr_pessoa_ref.cdoperad_altera := pr_cdoperad;
      -- Sera necessario colocar a linha abaixo porque para a pessoa de referencia 
      -- nao eh gravado o CPF / CNPJ quando a mesma nao possui conta
      IF pr_idseqttl = 0 THEN -- Se for um PJ
        vr_pessoa_ref.nrseq_referencia := rw_crapavt.nrctremp; 
      ELSE
        vr_pessoa_ref.nrseq_referencia := rw_crapavt.nrcpfcgc; -- Para PF, o CPF/CGC eh o sequencial
      END IF;
      
      -- Se possui conta, busca os dados da conta dela
      IF rw_crapavt.nrdctato > 0 THEN
        OPEN cr_crapass(pr_nrdconta => rw_crapavt.nrdctato);
        FETCH cr_crapass INTO rw_crapass;
        IF cr_crapass%NOTFOUND THEN
          CLOSE cr_crapass;
          vr_dscritic := 'Nao encontrado a conta da pessoa de referencia';
          RAISE vr_exc_erro;
        END IF;
        CLOSE cr_crapass;
        
        -- Verifica se esta pessoa ja possui cadastro de pessoa
        OPEN cr_pessoa(pr_nrcpfcgc => rw_crapass.nrcpfcgc);
        FETCH cr_pessoa INTO rw_pessoa;
        -- Se nao existir pessoa cadastrada, deve-se efetuar o cadastro
        IF cr_pessoa%NOTFOUND THEN
          CLOSE cr_pessoa;
          -- Efetua a inclusao de pessoa
          cada0011.pc_insere_pessoa_crapass(pr_cdcooper => pr_cdcooper,
                                            pr_nrdconta => rw_crapavt.nrdctato,
                                            pr_idseqttl => 1,
                                            pr_cdoperad => pr_cdoperad,
                                            pr_cdcritic => vr_cdcritic,
                                            pr_dscritic => vr_dscritic);
          -- Verifica se deu erro
          IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

          -- Busca a pessoa que foi cadastrada
          OPEN cr_pessoa(pr_nrcpfcgc => rw_crapass.nrcpfcgc);
          FETCH cr_pessoa INTO rw_pessoa;
          
        END IF;

        CLOSE cr_pessoa;
      ELSE -- Se nao possui conta

        -- Efetua a inclusao de pessoa
        vr_pessoa := NULL;
        vr_pessoa.cdoperad_altera     := pr_cdoperad;
        vr_pessoa.tpcadastro          := 1; -- Prospect
        vr_pessoa.tppessoa            := 1; -- Fisico
        vr_pessoa.nmpessoa            := rw_crapavt.nmdavali;

        -- Insere o Cadastro de pessoa fisica
        cada0010.pc_cadast_pessoa_fisica(pr_pessoa_fisica => vr_pessoa,
                                         pr_cdcritic      => vr_cdcritic,
                                         pr_dscritic      => vr_dscritic);
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
          
        -- Atualiza o IDPESSOA na variavel de uso
        rw_pessoa.idpessoa := vr_pessoa.idpessoa;

        -- Se possui endereco cadastrado
        IF TRIM(rw_crapavt.dsendres##1) IS NOT NULL THEN
          -- Efetua a tratativa de endereco
          vr_pessoa_endereco                 := NULL;
          vr_pessoa_endereco.idpessoa        := vr_pessoa.idpessoa;
          vr_pessoa_endereco.tpendereco      := 10; --Residencial
          vr_pessoa_endereco.nrcep           := rw_crapavt.nrcepend;
          vr_pessoa_endereco.nmlogradouro    := rw_crapavt.dsendres##1; 
          vr_pessoa_endereco.nrlogradouro    := rw_crapavt.nrendere; 
          vr_pessoa_endereco.dscomplemento   := rw_crapavt.complend; 
          vr_pessoa_endereco.nmbairro        := rw_crapavt.nmbairro; 
          vr_pessoa_endereco.cdoperad_altera := pr_cdoperad;
          -- Trata o municipio
          IF TRIM(rw_crapavt.nmcidade) IS NOT NULL THEN
            -- Busca o ID do municipio
            CADA0015.pc_trata_municipio(pr_dscidade => TRIM(rw_crapavt.nmcidade),
                               pr_cdestado => rw_crapavt.cdufresd,
                               pr_idcidade => vr_pessoa_endereco.idcidade,
                               pr_dscritic => vr_dscritic);
            IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
          END IF;
            
          -- Efetua a inclusao
          cada0010.pc_cadast_pessoa_endereco(pr_pessoa_endereco => vr_pessoa_endereco
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);
          IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF; 
        END IF; -- Fim da verificacao se possui endereco
          
        -- Verifica se possui email
        IF TRIM(rw_crapavt.dsdemail) IS NOT NULL THEN
          vr_pessoa_email := NULL;
          vr_pessoa_email.idpessoa := vr_pessoa.idpessoa;
          vr_pessoa_email.dsemail  := rw_crapavt.dsdemail;
          vr_pessoa_email.cdoperad_altera := pr_cdoperad;
            
          -- Efetua a inclusao
          cada0010.pc_cadast_pessoa_email(pr_pessoa_email => vr_pessoa_email
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
          IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        END IF;
          
        -- Verifica se possui telefone
        IF TRIM(rw_crapavt.nrtelefo) IS NOT NULL THEN
          -- Inicializa o telefone
          vr_pessoa_telefone := NULL;

          -- Estrutura o telefone
          pc_trata_telefone(pr_nrtelefone_org => substr(rw_crapavt.nrtelefo,1,50),
                            pr_nrramal_org    => NULL, 
                            pr_nrddd          => vr_nrddd,
                            pr_nrtelefone     => vr_nrtelefone,
                            pr_nrramal        => vr_nrramal,
                            pr_dscritic       => vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
            
          -- Atualiza os dados do telefone
          vr_pessoa_telefone.idpessoa               := vr_pessoa.idpessoa;
          vr_pessoa_telefone.tptelefone             := 1; -- Residencial
          vr_pessoa_telefone.nrddd                  := vr_nrddd;
          vr_pessoa_telefone.nrtelefone             := vr_nrtelefone;
          vr_pessoa_telefone.cdoperad_altera        := pr_cdoperad;
            
          -- Efetua a inclusao
          cada0010.pc_cadast_pessoa_telefone(pr_pessoa_telefone => vr_pessoa_telefone
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);
          IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        END IF; -- Fim da verificacao se possui telefone

      END IF; -- Fim da verificacao se o representante possui conta
      
      -- Atualiza o IDPESSOA da pessoa do representante
      vr_pessoa_ref.idpessoa_referencia := rw_pessoa.idpessoa;
      
      -- Efetua a inclusao
      cada0010.pc_cadast_pessoa_referencia(pr_pessoa_referencia => vr_pessoa_ref
                                          ,pr_cdcritic          => vr_cdcritic
                                          ,pr_dscritic          => vr_dscritic);
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

    END LOOP; -- Fim do loop sobre os representantes
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;


      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_insere_referencia: ' ||SQLERRM;

  END;



  -- Rotina para inserir o responsavel legal
  PROCEDURE pc_insere_responsavel_legal(pr_cdcooper crapcje.cdcooper%TYPE -- Codigo da cooperativa
                                       ,pr_idpessoa tbcadast_pessoa.idpessoa%TYPE -- Identificador de pessoa
                                       ,pr_nrdconta crapcje.nrdconta%TYPE -- Numero da conta
                                       ,pr_idseqttl crapttl.idseqttl%TYPE -- Sequencia do titular
                                       ,pr_cdoperad crapope.cdoperad%TYPE -- Codigo do operador que esta efetuando a operacao
                                       ,pr_cdcritic OUT INTEGER           -- Codigo de erro
                                       ,pr_dscritic OUT VARCHAR2) IS      -- Retorno de Erro

    -- Cursor sobre os bens
    CURSOR cr_crapcrl IS
      SELECT cdcooper, 
             nrctamen, 
             nrcpfmen, 
             idseqmen, 
             nrdconta, 
             nrcpfcgc, 
             nmrespon, 
             cdufiden, 
             dtemiden, 
             dtnascin, 
             cddosexo, 
             cdestciv, 
             dsnatura, 
             cdcepres, 
             dsendres, 
             nrendres, 
             dscomres, 
             dsbaires, 
             nrcxpost, 
             dscidres, 
             dsdufres, 
             nmpairsp, 
             nmmaersp, 
             tpdeiden, 
             nridenti, 
             dtmvtolt, 
             flgimpri, 
             cdrlcrsp, 
             cdnacion, 
             idorgexp
        FROM crapcrl a
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrctamen = pr_nrdconta
         AND a.idseqmen = pr_idseqttl;

    -- Busca os dados da conta do responsavel legal
    CURSOR cr_crapass(pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT nrcpfcgc
        FROM crapass
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    
    -- Verifica se o responsavel ja possui cadastro de pessoa
    CURSOR cr_pessoa(pr_nrcpfcgc tbcadast_pessoa.nrcpfcgc%TYPE) IS
      SELECT idpessoa
        FROM tbcadast_pessoa
       WHERE nrcpfcgc = pr_nrcpfcgc;
    rw_pessoa cr_pessoa%ROWTYPE;
       
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
    
    -- Variaveis gerais
    vr_pessoa_responsavel   tbcadast_pessoa_fisica_resp%ROWTYPE;    -- Registro de bem de pessoas
    vr_pessoa               vwcadast_pessoa_fisica%ROWTYPE;    -- Registro de pessoa fisica
    vr_pessoa_endereco      tbcadast_pessoa_endereco%ROWTYPE;  -- Dados do endereco
    
  BEGIN
    -- Loop sobre a tabela de responsavel legal
    FOR rw_crapcrl IN cr_crapcrl LOOP
      -- Se o responsavel legal possui conta, busca os dados da conta dele
      IF rw_crapcrl.nrdconta > 0 THEN
        OPEN cr_crapass(pr_nrdconta => rw_crapcrl.nrdconta);
        FETCH cr_crapass INTO rw_crapass;
        IF cr_crapass%NOTFOUND THEN
          CLOSE cr_crapass;
          vr_dscritic := 'Nao encontrado a conta do responsavel legal';
          RAISE vr_exc_erro;
        END IF;
        CLOSE cr_crapass;
        
        -- Verifica se este responsavel ja possui cadastro de pessoa
        OPEN cr_pessoa(pr_nrcpfcgc => rw_crapass.nrcpfcgc);
        FETCH cr_pessoa INTO rw_pessoa;
        -- Se nao existir pessoa cadastrada, deve-se efetuar o cadastro
        IF cr_pessoa%NOTFOUND THEN
          CLOSE cr_pessoa;
          -- Efetua a inclusao de pessoa
          cada0011.pc_insere_pessoa_crapass(pr_cdcooper => pr_cdcooper,
                                            pr_nrdconta => rw_crapcrl.nrdconta,
                                            pr_idseqttl => 1,
                                            pr_cdoperad => pr_cdoperad,
                                            pr_cdcritic => vr_cdcritic,
                                            pr_dscritic => vr_dscritic);
          -- Verifica se deu erro
          IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          
          -- Busca a pessoa que foi cadastrada
          OPEN cr_pessoa(pr_nrcpfcgc => rw_crapass.nrcpfcgc);
          FETCH cr_pessoa INTO rw_pessoa;
          
        END IF;
        CLOSE cr_pessoa;
      ELSE -- Se nao possui conta
        -- Verifica se este responsavel ja possui cadastro de pessoa
        OPEN cr_pessoa(pr_nrcpfcgc => rw_crapcrl.nrcpfcgc);
        FETCH cr_pessoa INTO rw_pessoa;
        -- Se nao existir pessoa cadastrada, deve-se efetuar o cadastro
        IF cr_pessoa%NOTFOUND THEN
          CLOSE cr_pessoa;
          -- Efetua a inclusao de pessoa
          vr_pessoa := NULL;
          vr_pessoa.nrcpf := rw_crapcrl.nrcpfcgc;
          vr_pessoa.nmpessoa := rw_crapcrl.nmrespon;
          IF rw_crapcrl.idorgexp <> 0 THEN
            vr_pessoa.idorgao_expedidor := rw_crapcrl.idorgexp;
          END IF;
          vr_pessoa.cduf_orgao_expedidor := trim(rw_crapcrl.cdufiden);
          vr_pessoa.dtemissao_documento := rw_crapcrl.dtemiden;
          vr_pessoa.dtnascimento        := rw_crapcrl.dtnascin; 
          vr_pessoa.tpsexo              := rw_crapcrl.cddosexo; 
          IF nvl(rw_crapcrl.cdestciv,0) > 0 THEN
            vr_pessoa.cdestado_civil      := rw_crapcrl.cdestciv; 
          END IF;
          vr_pessoa.nrdocumento         := rw_crapcrl.nridenti; 
          vr_pessoa.tpdocumento         := rw_crapcrl.tpdeiden; 
          IF nvl(rw_crapcrl.cdnacion,0) > 0 THEN
            vr_pessoa.cdnacionalidade     := rw_crapcrl.cdnacion; 
          END IF;
          vr_pessoa.tppessoa            := 1; -- Fisica
          vr_pessoa.tpcadastro          := 2; -- Basico
          vr_pessoa.cdoperad_altera     := pr_cdoperad;

          -- Trata o municipio
          IF TRIM(rw_crapcrl.dsnatura) IS NOT NULL THEN
            -- Busca o ID do municipio
            CADA0015.pc_trata_municipio(pr_dscidade => TRIM(rw_crapcrl.dsnatura),
                               pr_cdestado => NULL,
                               pr_idcidade => vr_pessoa.cdnaturalidade,
                               pr_dscritic => vr_dscritic);
            IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
          END IF;
          
          -- Insere o Cadastro de pessoa fisica
          cada0010.pc_cadast_pessoa_fisica(pr_pessoa_fisica => vr_pessoa,
                                           pr_cdcritic      => vr_cdcritic,
                                           pr_dscritic      => vr_dscritic);
          IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          
          -- Atualiza o IDPESSOA na variavel de uso
          rw_pessoa.idpessoa := vr_pessoa.idpessoa;

          -- Efetua tratativa pai
          IF trim(rw_crapcrl.nmpairsp) IS NOT NULL THEN
            pc_trata_pessoa_relacao(pr_idpessoa => vr_pessoa.idpessoa,
                                    pr_tprelacao=> 3, -- Pai
                                    pr_nmpessoa => rw_crapcrl.nmpairsp,
                                    pr_cdoperad => pr_cdoperad,
                                    pr_cdcritic => vr_cdcritic,
                                    pr_dscritic => vr_dscritic);
            IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
          END IF;

          -- Efetua tratativa mae
          IF trim(rw_crapcrl.nmmaersp) IS NOT NULL THEN
            pc_trata_pessoa_relacao(pr_idpessoa => vr_pessoa.idpessoa,
                                    pr_tprelacao=> 4, -- Mae
                                    pr_nmpessoa => rw_crapcrl.nmmaersp,
                                    pr_cdoperad => pr_cdoperad,
                                    pr_cdcritic => vr_cdcritic,
                                    pr_dscritic => vr_dscritic);
            IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
          END IF;

          -- Efetua a tratativa de endereco
          vr_pessoa_endereco                 := NULL;
          vr_pessoa_endereco.idpessoa        := vr_pessoa.idpessoa;
          vr_pessoa_endereco.tpendereco      := 10; --Residencial
          vr_pessoa_endereco.nrcep           := rw_crapcrl.cdcepres; 
          vr_pessoa_endereco.nmlogradouro    := rw_crapcrl.dsendres; 
          vr_pessoa_endereco.nrlogradouro    := rw_crapcrl.nrendres; 
          vr_pessoa_endereco.dscomplemento   := rw_crapcrl.dscomres; 
          vr_pessoa_endereco.nmbairro        := rw_crapcrl.dsbaires; 
          vr_pessoa_endereco.cdoperad_altera := pr_cdoperad;

          -- Trata o municipio
          IF TRIM(rw_crapcrl.dscidres) IS NOT NULL THEN
            -- Busca o ID do municipio
            CADA0015.pc_trata_municipio(pr_dscidade => TRIM(rw_crapcrl.dscidres),
                               pr_cdestado => rw_crapcrl.dsdufres,
                               pr_idcidade => vr_pessoa_endereco.idcidade,
                               pr_dscritic => vr_dscritic);
            IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
          END IF;
          
          -- Efetua a inclusao
          cada0010.pc_cadast_pessoa_endereco(pr_pessoa_endereco => vr_pessoa_endereco
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);
          IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        ELSE
          CLOSE cr_pessoa;
        END IF; -- Fim da verificacao se o responsavel legal ja possui cadastro como pessoa         
        
        
      END IF; -- Fim da verificacao se o responsavel legal possui conta
        
      -- Popula os campos para inserir o registro
      vr_pessoa_responsavel := NULL;
      vr_pessoa_responsavel.idpessoa            := pr_idpessoa;
      vr_pessoa_responsavel.idpessoa_resp_legal := rw_pessoa.idpessoa;
      IF nvl(rw_crapcrl.cdrlcrsp,0) <> 0 THEN
        vr_pessoa_responsavel.cdrelacionamento    := rw_crapcrl.cdrlcrsp; 
      END IF;
      vr_pessoa_responsavel.cdoperad_altera     := pr_cdoperad;
      
      -- Efetua a inclusao
      cada0010.pc_cadast_pessoa_fisica_resp(pr_pessoa_fisica_resp => vr_pessoa_responsavel
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
    END LOOP; -- Fim do loop sobre o responsavel
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_insere_responsavel_legal: ' ||SQLERRM;
  END;

  -- Rotina para inserir o dependente da pessos fisica
  PROCEDURE pc_insere_dependente(pr_cdcooper crapcje.cdcooper%TYPE -- Codigo da cooperativa
                                ,pr_idpessoa tbcadast_pessoa.idpessoa%TYPE -- Identificador de pessoa
                                ,pr_nrdconta crapcje.nrdconta%TYPE -- Numero da conta
                                ,pr_idseqttl crapcje.idseqttl%TYPE -- Sequencia do titular
                                ,pr_cdoperad crapope.cdoperad%TYPE -- Codigo do operador que esta efetuando a operacao
                                ,pr_cdcritic OUT INTEGER           -- Codigo de erro
                                ,pr_dscritic OUT VARCHAR2) IS      -- Retorno de Erro

    -- Cursor sobre os bens
    CURSOR cr_crapdep IS
      SELECT a.nmdepend,
             a.dtnascto,
             a.tpdepend
        FROM crapdep a
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrdconta = pr_nrdconta
         AND a.idseqdep = pr_idseqttl;

    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
    
    -- Variaveis gerais
    vr_pessoa_fisica_dep   tbcadast_pessoa_fisica_dep%ROWTYPE;    -- Registro de dependentes da pessoas
    vr_pessoa              vwcadast_pessoa_fisica%ROWTYPE;          -- Registro de pessoa fisica
    
  BEGIN
    -- Loop sobre a tabela de dependentes
    FOR rw_crapdep IN cr_crapdep LOOP
      -- Popula os campos para inserir o registro
      vr_pessoa_fisica_dep := NULL;
      vr_pessoa_fisica_dep.idpessoa        := pr_idpessoa;
      vr_pessoa_fisica_dep.tpdependente    := rw_crapdep.tpdepend;
      vr_pessoa_fisica_dep.cdoperad_altera := pr_cdoperad;
      
      -- Cria o prospect de dependente
      vr_pessoa := NULL;
      vr_pessoa.cdoperad_altera     := pr_cdoperad;
      vr_pessoa.tpcadastro          := 1; -- Prospect
      vr_pessoa.tppessoa            := 1; -- Fisico
      vr_pessoa.nmpessoa            := rw_crapdep.nmdepend;
      vr_pessoa.dtnascimento        := rw_crapdep.dtnascto;

      -- Insere o Cadastro de pessoa fisica
      cada0010.pc_cadast_pessoa_fisica(pr_pessoa_fisica => vr_pessoa,
                                       pr_cdcritic      => vr_cdcritic,
                                       pr_dscritic      => vr_dscritic);
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- Atualiza a pessoa dependente
      vr_pessoa_fisica_dep.idpessoa_dependente := vr_pessoa.idpessoa;
      
      -- Efetua a inclusao
      cada0010.pc_cadast_pessoa_fisica_dep(pr_pessoa_fisica_dep => vr_pessoa_fisica_dep
                                          ,pr_cdcritic          => vr_cdcritic
                                          ,pr_dscritic          => vr_dscritic);
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
    END LOOP; -- Fim do loop sobre o dependente
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_insere_dependente: ' ||SQLERRM;
  END;

  -- Rotina de inclusao de pessoas politicamente expostas
  PROCEDURE pc_insere_politico_exposto(pr_cdcooper crapcje.cdcooper%TYPE -- Codigo da cooperativa
                                      ,pr_idpessoa tbcadast_pessoa.idpessoa%TYPE -- Identificador de pessoa
                                      ,pr_nrdconta crapcje.nrdconta%TYPE -- Numero da conta
                                      ,pr_idseqttl crapcje.idseqttl%TYPE -- Sequencia do titular
                                      ,pr_cdoperad crapope.cdoperad%TYPE -- Codigo do operador que esta efetuando a operacao
                                      ,pr_cdcritic OUT INTEGER           -- Codigo de erro
                                      ,pr_dscritic OUT VARCHAR2) IS      -- Retorno de Erro
 
     -- Cursor sobre as pessoas politicamente expostas
    CURSOR cr_polexp IS
      SELECT tpexposto, 
             dtinicio, 
             dttermino, 
             nmempresa, 
             nrcnpj_empresa, 
             nmpolitico, 
             cdocupacao, 
             cdrelacionamento, 
             nrcpf_politico
        FROM tbcadast_politico_exposto a
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrdconta = pr_nrdconta
         AND a.idseqttl = pr_idseqttl;
    rw_polexp cr_polexp%ROWTYPE;

    -- Verifica se o responsavel ja possui cadastro de pessoa
    CURSOR cr_pessoa(pr_nrcpfcgc tbcadast_pessoa.nrcpfcgc%TYPE) IS
      SELECT idpessoa
        FROM tbcadast_pessoa
       WHERE nrcpfcgc = pr_nrcpfcgc;
    rw_pessoa cr_pessoa%ROWTYPE;

    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
    
    -- Variaveis gerais
    vr_pessoa_polexp   tbcadast_pessoa_polexp%ROWTYPE;    -- Registro de pessoa politicamente exposta
    vr_pessoa_pj       vwcadast_pessoa_juridica%ROWTYPE;  -- Empresa da pessoa de relacionamento
    vr_pessoa_pf       vwcadast_pessoa_fisica%ROWTYPE;    -- Pessoa relacionada com o politico exposto
    
    vr_cria_pf         BOOLEAN; -- Indicador se deve criar a PF do politico exposto
    vr_cria_pj         BOOLEAN; -- Indicador se deve criar a PJ da empresa do politico exposto
  BEGIN
    
    -- Abre o cursor com os dados dos titulares
    OPEN cr_polexp;
    FETCH cr_polexp INTO rw_polexp;
    -- Se nao encontrar, encerra a rotina
    IF cr_polexp%NOTFOUND THEN
      CLOSE cr_polexp;
      RETURN;
    END IF;
    CLOSE cr_polexp;

    -- Inicializa a variavel
    vr_pessoa_polexp := NULL;
    vr_cria_pj       := FALSE;

    -- Popula os campos para inserir o registro
    vr_pessoa_polexp.idpessoa             := pr_idpessoa;
    vr_pessoa_polexp.cdoperad_altera      := pr_cdoperad; 
    vr_pessoa_polexp.tpexposto            := rw_polexp.tpexposto;
    vr_pessoa_polexp.dtinicio             := rw_polexp.dtinicio;
    vr_pessoa_polexp.dttermino            := rw_polexp.dttermino;
    vr_pessoa_polexp.cdocupacao           := rw_polexp.cdocupacao;
    vr_pessoa_polexp.tprelacao_polexp     := rw_polexp.cdrelacionamento;
    
    -- Se possuir empresa de relacionamento
    IF nvl(rw_polexp.nrcnpj_empresa,0) > 0 OR
       TRIM(rw_polexp.nmempresa) IS NOT NULL THEN
      -- Inicializa variavel
      vr_pessoa_pj := NULL;

      -- Se possuir CNPJ da empresa
      IF nvl(rw_polexp.nrcnpj_empresa,0) > 0 THEN
        -- Verifica se a empresa ja nao esta cadastrada como pessoa
        OPEN cr_pessoa(pr_nrcpfcgc => rw_polexp.nrcnpj_empresa);
        FETCH cr_pessoa INTO rw_pessoa;
        -- Se nao existir empresa cadastrada, deve-se efetuar o cadastro
        IF cr_pessoa%NOTFOUND THEN
          vr_cria_pj := TRUE;
          -- Atualiza o CNPJ com o que existe
          vr_pessoa_pj.nrcnpj := rw_polexp.nrcnpj_empresa;
        ELSE
          -- Atualiza a empresa de pessoa com o que ja existe
          vr_pessoa_polexp.idpessoa_empresa := rw_pessoa.idpessoa;
        END IF;
        CLOSE cr_pessoa;
      ELSE 
        -- Deve-se criar PJ
        vr_cria_pj := TRUE;
      END IF;
      
      IF vr_cria_pj THEN
        vr_pessoa_pj.nmpessoa := rw_polexp.nmempresa;
        vr_pessoa_pj.tppessoa             := 2; -- Juridica
        vr_pessoa_pj.tpcadastro           := 1; -- Prospect
        vr_pessoa_pj.cdoperad_altera      := pr_cdoperad;
          
        -- Cria a pessoa juridica
        cada0010.pc_cadast_pessoa_juridica(pr_pessoa_juridica => vr_pessoa_pj,
                                           pr_cdcritic      => vr_cdcritic,
                                           pr_dscritic      => vr_dscritic);
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
          
        -- Atualiza o ID da pesssoa juridica
        vr_pessoa_polexp.idpessoa_empresa := vr_pessoa_pj.idpessoa;
      END IF;
    END IF; -- Fim da verificacao se possui empresa do politico exposto
        

    -- Se possuir politico de relacionamento
    IF nvl(rw_polexp.nrcpf_politico,0) > 0 OR
       TRIM(rw_polexp.nmpolitico) IS NOT NULL THEN
      -- Inicializa variavel
      vr_pessoa_pf := NULL;

      -- Se possuir CPF do politico exposto
      IF nvl(rw_polexp.nrcpf_politico,0) > 0 THEN
        -- Verifica se o politico ja nao esta cadastrada como pessoa
        OPEN cr_pessoa(pr_nrcpfcgc => rw_polexp.nrcpf_politico);
        FETCH cr_pessoa INTO rw_pessoa;
        -- Se nao existir empresa cadastrada, deve-se efetuar o cadastro
        IF cr_pessoa%NOTFOUND THEN
          vr_cria_pf := TRUE;
          -- Atualiza o CPF da pessoa
          vr_pessoa_pf.nrcpf := rw_polexp.nrcpf_politico;
        ELSE
          -- Atualiza o politico de pessoa com o que ja existe
          vr_pessoa_polexp.idpessoa_politico := rw_pessoa.idpessoa;
        END IF;
        CLOSE cr_pessoa;
      ELSE 
        -- Deve-se criar PF
        vr_cria_pf := TRUE;
      END IF;
      
      IF vr_cria_pf THEN
        vr_pessoa_pf.nmpessoa := rw_polexp.nmpolitico;
        vr_pessoa_pf.tppessoa             := 1; -- Fisica
        vr_pessoa_pf.tpcadastro           := 1; -- Prospect
        vr_pessoa_pf.cdoperad_altera      := pr_cdoperad;
          
        -- Cria a pessoa juridica
        cada0010.pc_cadast_pessoa_fisica(pr_pessoa_fisica => vr_pessoa_pf,
                                           pr_cdcritic      => vr_cdcritic,
                                           pr_dscritic      => vr_dscritic);
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
          
        -- Atualiza o ID da pesssoa juridica
        vr_pessoa_polexp.idpessoa_politico := vr_pessoa_pf.idpessoa;
      END IF;
    END IF; -- Fim da verificacao se possui politico do politico exposto


    -- Efetua a inclusao
    cada0010.pc_cadast_pessoa_polexp(pr_pessoa_polexp => vr_pessoa_polexp
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);
    IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_insere_politico_exposto: ' ||SQLERRM;
  END;



  -- Rotina de inclusao de rendimento complementar
  PROCEDURE pc_insere_renda(pr_cdcooper crapcje.cdcooper%TYPE -- Codigo da cooperativa
                           ,pr_idpessoa tbcadast_pessoa.idpessoa%TYPE -- Identificador de pessoa
                           ,pr_nrdconta crapcje.nrdconta%TYPE -- Numero da conta
                           ,pr_idseqttl crapcje.idseqttl%TYPE -- Sequencia do titular
                           ,pr_cdoperad crapope.cdoperad%TYPE -- Codigo do operador que esta efetuando a operacao
                           ,pr_cdcritic OUT INTEGER           -- Codigo de erro
                           ,pr_dscritic OUT VARCHAR2) IS      -- Retorno de Erro

    -- Cursor sobre os bens
    CURSOR cr_crapttl IS
      SELECT a.tpcttrab,
             a.cdnvlcgo,
             a.dtadmemp,
             a.cdocpttl,
             a.nrcadast,
             a.vlsalari,
             a.cdturnos,
             a.nmextemp,
             a.nrcpfemp,
						 a.cdempres
        FROM crapttl a
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrdconta = pr_nrdconta
         AND a.idseqttl = pr_idseqttl;
    rw_crapttl cr_crapttl%ROWTYPE;

    -- Verifica se a empresa ja possui cadastro de pessoa
    CURSOR cr_pessoa(pr_nrcpfcgc tbcadast_pessoa.nrcpfcgc%TYPE) IS
      SELECT idpessoa
        FROM tbcadast_pessoa
       WHERE nrcpfcgc = pr_nrcpfcgc;
    rw_pessoa cr_pessoa%ROWTYPE;

    -- Cursor para verificar se a empresa do conjuge ja foi cadastrada
    CURSOR cr_empresa(pr_nmpessoa tbcadast_pessoa.nmpessoa%TYPE) IS
      SELECT c.idpessoa
        FROM tbcadast_pessoa c,
             tbcadast_pessoa_renda b
       WHERE b.idpessoa = pr_idpessoa
         AND c.idpessoa = b.idpessoa_fonte_renda
         AND c.nmpessoa = pr_nmpessoa;
    rw_empresa cr_empresa%ROWTYPE;


    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
    
    -- Variaveis gerais
    vr_pessoa_renda   tbcadast_pessoa_renda%ROWTYPE;    -- Registro de bem de pessoas
    vr_pessoa_pj      vwcadast_pessoa_juridica%ROWTYPE; -- Registro de pessoa juridica
    vr_pessoa_pf      vwcadast_pessoa_fisica%ROWTYPE;   -- Registro de pessoa fisica
    vr_cria_pj        BOOLEAN := FALSE; -- Indicador se deve criar a empresa de trabalho
    
  BEGIN
    
    -- Abre o cursor com os dados dos titulares
    OPEN cr_crapttl;
    FETCH cr_crapttl INTO rw_crapttl;
    -- Se nao encontrar, encerra a rotina
    IF cr_crapttl%NOTFOUND THEN
      CLOSE cr_crapttl;
      RETURN;
    END IF;
    CLOSE cr_crapttl;

    -- Inicializa a variavel
    vr_pessoa_renda := NULL;

    -- Popula os campos para inserir o registro
    vr_pessoa_renda.idpessoa             := pr_idpessoa;
    vr_pessoa_renda.nrseq_renda          := 1;
    vr_pessoa_renda.tpcontrato_trabalho  := rw_crapttl.tpcttrab;
    vr_pessoa_renda.cdturno              := rw_crapttl.cdturnos;
    vr_pessoa_renda.cdnivel_cargo        := rw_crapttl.cdnvlcgo;
    vr_pessoa_renda.dtadmissao           := rw_crapttl.dtadmemp;
    IF rw_crapttl.cdocpttl <> 0 THEN
      vr_pessoa_renda.cdocupacao           := rw_crapttl.cdocpttl;
    END IF;
    vr_pessoa_renda.nrcadastro           := rw_crapttl.nrcadast;
    vr_pessoa_renda.vlrenda              := rw_crapttl.vlsalari;
    vr_pessoa_renda.cdoperad_altera      := pr_cdoperad;
    
    -- Efetua a validacao da empresa
    -- Se tiver empresa de ligacao
    IF nvl(rw_crapttl.nrcpfemp,0) > 0 OR TRIM(rw_crapttl.nmextemp) IS NOT NULL THEN
      -- Se possui CNPJ
      IF nvl(rw_crapttl.nrcpfemp,0) > 0 THEN
        -- Verifica se a empresa ja nao esta cadastrada como pessoa
        OPEN cr_pessoa(pr_nrcpfcgc => rw_crapttl.nrcpfemp);
        FETCH cr_pessoa INTO rw_pessoa;
        -- Se nao existir empresa cadastrada, deve-se efetuar o cadastro
        IF cr_pessoa%NOTFOUND THEN
          -- Coloca o indicador para criar pessoa juridica
          vr_cria_pj := TRUE;
          -- Atualiza o CNPJ com o que sera criado
          vr_pessoa_pj.nrcnpj := rw_crapttl.nrcpfemp;
        ELSE
          -- Atualiza a empresa de pessoa com o que ja existe
          vr_pessoa_renda.idpessoa_fonte_renda := rw_pessoa.idpessoa;
        END IF;
        CLOSE cr_pessoa;
      ELSE 
        -- Apenas coloca o indicador para criar empresa juridica
        vr_cria_pj := TRUE;
      END IF; -- Verificacao se existe CNPJ da empresa
      
      -- Verifica se deve-se criar a PJ
      IF vr_cria_pj THEN
        -- Verifica se para esta pessoa ja foi criada a empresa,
        -- pois pode ser que tenha sido criado quando foi criado ela como conjuge
        -- em alguma outra conta
        OPEN cr_empresa(rw_crapttl.nmextemp);
        FETCH cr_empresa INTO rw_empresa;
        IF cr_empresa%FOUND THEN
          -- Coloca para nao criar novamente a empresa, pois ela ja existe
          vr_cria_pj := FALSE;
          -- Atualiza o ID da empresa de trabalho
          vr_pessoa_renda.idpessoa_fonte_renda := rw_empresa.idpessoa;
        END IF;
        CLOSE cr_empresa;
      END IF;
      
      -- Se necessitar criar PJ
      IF vr_cria_pj THEN
        
        -- Verifica se a empresa eh uma pessoa fisica ou juridica
        -- Se o código da empresa for 9998 então é PF
        IF rw_crapttl.cdempres = 9998 THEN
          -- Popula os dados para PF
          vr_pessoa_pf.nrcpf                := vr_pessoa_pj.nrcnpj;
          vr_pessoa_pf.nmpessoa             := rw_crapttl.nmextemp;
          vr_pessoa_pf.tppessoa             := 1; -- Fisica
          vr_pessoa_pf.tpcadastro           := 1; -- Prospect
          vr_pessoa_pf.cdoperad_altera      := pr_cdoperad;

          -- Cria a pessoa fisica
          cada0010.pc_cadast_pessoa_fisica(pr_pessoa_fisica => vr_pessoa_pf,
                                           pr_cdcritic      => vr_cdcritic,
                                           pr_dscritic      => vr_dscritic);
          IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          -- Atualiza o ID da pesssoa juridica
          vr_pessoa_renda.idpessoa_fonte_renda := vr_pessoa_pf.idpessoa;

        ELSE
          -- Popula os dados da PJ        
          vr_pessoa_pj.nmpessoa             := rw_crapttl.nmextemp;
          vr_pessoa_pj.tppessoa             := 2; -- Juridica
          vr_pessoa_pj.tpcadastro           := 1; -- Prospect
          vr_pessoa_pj.cdoperad_altera      := pr_cdoperad;

          -- Cria a pessoa juridica
          cada0010.pc_cadast_pessoa_juridica(pr_pessoa_juridica => vr_pessoa_pj,
                                             pr_cdcritic      => vr_cdcritic,
                                             pr_dscritic      => vr_dscritic);
          IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

          -- Atualiza o ID da pesssoa juridica
          vr_pessoa_renda.idpessoa_fonte_renda := vr_pessoa_pj.idpessoa;

        END IF;
      
      END IF; -- Fim da verificacao se deve criar empresa
    END IF; -- Verificacao se existe empresa de trabalho da pessoa
           
    -- Efetua a inclusao
    cada0010.pc_cadast_pessoa_renda(pr_pessoa_renda => vr_pessoa_renda
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
    IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_insere_rendimento_compl: ' ||SQLERRM;
  END;


  -- Rotina de inclusao de rendimento complementar
  PROCEDURE pc_insere_rendimento_compl(pr_cdcooper crapcje.cdcooper%TYPE -- Codigo da cooperativa
                                      ,pr_idpessoa tbcadast_pessoa.idpessoa%TYPE -- Identificador de pessoa
                                      ,pr_nrdconta crapcje.nrdconta%TYPE -- Numero da conta
                                      ,pr_idseqttl crapcje.idseqttl%TYPE -- Sequencia do titular
                                      ,pr_cdoperad crapope.cdoperad%TYPE -- Codigo do operador que esta efetuando a operacao
                                      ,pr_cdcritic OUT INTEGER           -- Codigo de erro
                                      ,pr_dscritic OUT VARCHAR2) IS      -- Retorno de Erro

    -- Cursor sobre os bens
    CURSOR cr_crapttl IS
      SELECT a.vldrendi##1,
             a.tpdrendi##1,
             a.vldrendi##2,
             a.tpdrendi##2,
             a.vldrendi##3,
             a.tpdrendi##3,
             a.vldrendi##4,
             a.tpdrendi##4,
             a.vldrendi##5,
             a.tpdrendi##5,
             a.vldrendi##6,
             a.tpdrendi##6
        FROM crapttl a
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrdconta = pr_nrdconta
         AND a.idseqttl = pr_idseqttl;
    rw_crapttl cr_crapttl%ROWTYPE;

    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
    
    -- Variaveis gerais
    vr_pessoa_renda_compl   tbcadast_pessoa_rendacompl%ROWTYPE;    -- Registro de bem de pessoas
    
  BEGIN
    
    -- Abre o cursor com os rendimentos
    OPEN cr_crapttl;
    FETCH cr_crapttl INTO rw_crapttl;
    -- Se nao encontrar, encerra a rotina
    IF cr_crapttl%NOTFOUND THEN
      CLOSE cr_crapttl;
      RETURN;
    END IF;
    CLOSE cr_crapttl;
    -- Loop sobre o total de rendimentos possiveis
    FOR x IN 1..6 LOOP
      
      -- Inicializa a variavel
      vr_pessoa_renda_compl := NULL;

      -- Verifica qual o rendimento devera ser utilizado
      IF x = 1 THEN
        vr_pessoa_renda_compl.tprenda := rw_crapttl.tpdrendi##1;
        vr_pessoa_renda_compl.vlrenda := rw_crapttl.vldrendi##1;
      ELSIF x = 2 THEN
        vr_pessoa_renda_compl.tprenda := rw_crapttl.tpdrendi##2;
        vr_pessoa_renda_compl.vlrenda := rw_crapttl.vldrendi##2;
      ELSIF x = 3 THEN
        vr_pessoa_renda_compl.tprenda := rw_crapttl.tpdrendi##3;
        vr_pessoa_renda_compl.vlrenda := rw_crapttl.vldrendi##3;
      ELSIF x = 4 THEN
        vr_pessoa_renda_compl.tprenda := rw_crapttl.tpdrendi##4;
        vr_pessoa_renda_compl.vlrenda := rw_crapttl.vldrendi##4;
      ELSIF x = 5 THEN
        vr_pessoa_renda_compl.tprenda := rw_crapttl.tpdrendi##5;
        vr_pessoa_renda_compl.vlrenda := rw_crapttl.vldrendi##5;
      ELSE
        vr_pessoa_renda_compl.tprenda := rw_crapttl.tpdrendi##6;
        vr_pessoa_renda_compl.vlrenda := rw_crapttl.vldrendi##6;
      END IF;
              
      -- somente efetua a inclusao se o valor for superior a zeros
      IF vr_pessoa_renda_compl.vlrenda > 0 THEN
        -- Popula os campos para inserir o registro
        vr_pessoa_renda_compl.idpessoa        := pr_idpessoa;
        vr_pessoa_renda_compl.nrseq_renda     := x;
        vr_pessoa_renda_compl.cdoperad_altera := pr_cdoperad;
        
        -- Efetua a inclusao
        cada0010.pc_cadast_pessoa_renda_compl(pr_pessoa_renda_compl => vr_pessoa_renda_compl
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;
      
    END LOOP; -- Fim do loop sobre o email
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_insere_rendimento_compl: ' ||SQLERRM;
  END;

  -- Rotina para inserir o bem
  PROCEDURE pc_insere_telefone(pr_cdcooper crapcje.cdcooper%TYPE -- Codigo da cooperativa
                              ,pr_idpessoa tbcadast_pessoa.idpessoa%TYPE -- Identificador de pessoa
                              ,pr_nrdconta crapcje.nrdconta%TYPE -- Numero da conta
                              ,pr_idseqttl crapcje.idseqttl%TYPE -- Sequencia do titular
                              ,pr_cdoperad crapope.cdoperad%TYPE -- Codigo do operador que esta efetuando a operacao
                              ,pr_cdcritic OUT INTEGER           -- Codigo de erro
                              ,pr_dscritic OUT VARCHAR2) IS      -- Retorno de Erro

    -- Cursor sobre os bens
    CURSOR cr_craptfc IS
      SELECT a.cdseqtfc,
             cdopetfn, 
             nrdddtfc, 
             tptelefo, 
             nmpescto, 
             prgqfalt, 
             nrtelefo, 
             nrdramal, 
             secpscto, 
             progress_recid, 
             idsittfc, 
             idorigem, 
             flgacsms
        FROM craptfc a
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrdconta = pr_nrdconta
         AND a.idseqttl = pr_idseqttl;

    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
    
    -- Variaveis gerais
    vr_pessoa_telefone tbcadast_pessoa_telefone%ROWTYPE;    -- Registro de telefone de pessoas
    vr_nrddd          tbcadast_pessoa_telefone.nrddd%TYPE; -- Numero do DDD
    vr_nrtelefone     tbcadast_pessoa_telefone.nrtelefone%TYPE; -- Numero do telefone
    vr_nrramal        tbcadast_pessoa_telefone.nrramal%TYPE; -- Numero do Ramal
    
  BEGIN
    -- Loop sobre a tabela de emails
    FOR rw_craptfc IN cr_craptfc LOOP

      -- Estrutura o telefone
      pc_trata_telefone(pr_nrtelefone_org => rw_craptfc.nrtelefo,
                        pr_nrramal_org    => rw_craptfc.nrdramal, 
                        pr_nrddd          => vr_nrddd,
                        pr_nrtelefone     => vr_nrtelefone,
                        pr_nrramal        => vr_nrramal,
                        pr_dscritic       => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
       

      -- Popula os campos para inserir o registro
      vr_pessoa_telefone := NULL;
      vr_pessoa_telefone.idpessoa               := pr_idpessoa;
      vr_pessoa_telefone.nrseq_telefone         := rw_craptfc.cdseqtfc;
      vr_pessoa_telefone.cdoperadora            := rw_craptfc.cdopetfn;
      vr_pessoa_telefone.tptelefone             := rw_craptfc.tptelefo;
      vr_pessoa_telefone.nmpessoa_contato       := rw_craptfc.nmpescto;
      vr_pessoa_telefone.nmsetor_pessoa_contato := rw_craptfc.secpscto;
      vr_pessoa_telefone.nrddd                  := rw_craptfc.nrdddtfc;
      vr_pessoa_telefone.nrtelefone             := vr_nrtelefone;
      vr_pessoa_telefone.nrramal                := rw_craptfc.nrdramal;
      vr_pessoa_telefone.insituacao             := rw_craptfc.idsittfc;
      vr_pessoa_telefone.tporigem_cadastro      := rw_craptfc.idorigem;
      vr_pessoa_telefone.flgaceita_sms          := rw_craptfc.flgacsms; 
      vr_pessoa_telefone.cdoperad_altera        := pr_cdoperad;
      
      -- Efetua a inclusao
      cada0010.pc_cadast_pessoa_telefone(pr_pessoa_telefone => vr_pessoa_telefone
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
    END LOOP; -- Fim do loop sobre o email
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_insere_telefone: ' ||SQLERRM;
  END;

  -- Rotina para inserir o bem
  PROCEDURE pc_insere_endereco(pr_cdcooper crapcje.cdcooper%TYPE -- Codigo da cooperativa
                              ,pr_idpessoa tbcadast_pessoa.idpessoa%TYPE -- Identificador de pessoa
                              ,pr_nrdconta crapcje.nrdconta%TYPE -- Numero da conta
                              ,pr_idseqttl crapcje.idseqttl%TYPE -- Sequencia do titular
                              ,pr_cdoperad crapope.cdoperad%TYPE -- Codigo do operador que esta efetuando a operacao
                              ,pr_cdcritic OUT INTEGER           -- Codigo de erro
                              ,pr_dscritic OUT VARCHAR2) IS      -- Retorno de Erro

    -- Cursor sobre os bens
    CURSOR cr_crapenc IS
      SELECT a.*
        FROM crapenc a
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrdconta = pr_nrdconta
         AND a.idseqttl = pr_idseqttl;

    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
       
  BEGIN
    -- Loop sobre a tabela de enderecos
    FOR rw_crapenc IN cr_crapenc LOOP
      -- Efetua a inclusao do endereco
      cada0015.pc_crapenc(pr_crapenc => rw_crapenc,
                          pr_tpoperacao => 1,
                          pr_idpessoa => pr_idpessoa,
                          pr_cdoperad => pr_cdoperad,
                          pr_dscritic => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
    END LOOP; -- Fim do loop sobre o email
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_insere_endereco: ' ||SQLERRM;
  END;

  
  -- Rotina para cadastro de pessoa com base na tabela CRAPCJE
  PROCEDURE pc_insere_pessoa_crapcje(pr_cdcooper crapcje.cdcooper%TYPE -- Codigo da cooperativa
                                    ,pr_idpessoa tbcadast_pessoa.idpessoa%TYPE -- Identificador de pessoa do titular (nao do conjuge)
                                    ,pr_nrdconta crapcje.nrdconta%TYPE -- Numero da conta
                                    ,pr_idseqttl crapcje.idseqttl%TYPE -- Sequencia do titular
                                    ,pr_cdoperad crapope.cdoperad%TYPE -- Codigo do operador que esta efetuando a operacao
                                    ,pr_cdcritic OUT INTEGER           -- Codigo de erro
                                    ,pr_dscritic OUT VARCHAR2) IS      -- Retorno de Erro
    -- Busca os dados do conjuge
    CURSOR cr_crapcje IS
      SELECT a.cdcooper, 
             a.nrdconta, 
             a.idseqttl, 
             a.nmconjug, 
             a.nrcpfcjg, 
             a.dtnasccj, 
             a.tpdoccje, 
             a.nrdoccje, 
             a.cdufdcje, 
             a.dtemdcje, 
             a.grescola, 
             a.cdfrmttl, 
             a.cdnatopc, 
             a.cdocpcje, 
             a.tpcttrab, 
             a.nmextemp, 
             a.dsproftl, 
             a.cdnvlcgo, 
             a.nrfonemp, 
             a.nrramemp, 
             a.cdturnos, 
             a.dtadmemp, 
             a.vlsalari, 
             a.nrdocnpj, 
             a.nrctacje, 
             a.dsendcom,
             b.nrcpfcgc,
             a.idorgexp
        FROM crapass b,
             crapcje a
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrdconta = pr_nrdconta
         AND a.idseqttl = pr_idseqttl
         AND b.cdcooper (+) = a.cdcooper
         AND b.nrdconta (+) = a.nrctacje;
    rw_crapcje cr_crapcje%ROWTYPE;
    
    -- Cursor para verificar se existe a pessoa
    CURSOR cr_pessoa(pr_nrcpf tbcadast_pessoa.nrcpfcgc%TYPE) IS
      SELECT *
        FROM vwcadast_pessoa_fisica
       WHERE nrcpf    = pr_nrcpf;
    rw_pessoa cr_pessoa%ROWTYPE;

    -- Cursor para verificar se ja existe relacionamento
    CURSOR cr_relacionamento IS
      SELECT a.nrseq_relacao,
             a.idpessoa_relacao,
             b.nmpessoa
        FROM tbcadast_pessoa b,
             tbcadast_pessoa_relacao a
       WHERE a.idpessoa = pr_idpessoa
         AND a.tprelacao = 1 -- Conjuge
         AND b.idpessoa = a.idpessoa_relacao;
    rw_relacionamento cr_relacionamento%ROWTYPE;

    -- Cursor para verificar se existe a pessoa juridica
    CURSOR cr_pessoa_juridica(pr_nrcnpj vwcadast_pessoa_juridica.nrcnpj%TYPE) IS
      SELECT *
        FROM vwcadast_pessoa_juridica
       WHERE nrcnpj   = pr_nrcnpj;
    rw_pessoa_juridica cr_pessoa_juridica%ROWTYPE;
    
    -- Cursor para verificar se existe telefone para o conjuge
    CURSOR cr_pessoa_telefone(pr_idpessoa   tbcadast_pessoa_telefone.idpessoa%TYPE,
                              pr_nrtelefone tbcadast_pessoa_telefone.nrtelefone%TYPE) IS
      SELECT *
        FROM tbcadast_pessoa_telefone
       WHERE idpessoa   = pr_idpessoa
         AND nrtelefone = pr_nrtelefone;
    rw_pessoa_telefone cr_pessoa_telefone%ROWTYPE;
    
    -- Cursor para verificar se a empresa do conjuge ja foi cadastrada
    CURSOR cr_empresa(pr_nmpessoa tbcadast_pessoa.nmpessoa%TYPE) IS
      SELECT c.idpessoa
        FROM tbcadast_pessoa c,
             tbcadast_pessoa_renda b,
             tbcadast_pessoa_relacao a
       WHERE a.idpessoa = pr_idpessoa
         AND a.tprelacao = 1 -- conjuge
         AND b.idpessoa = a.idpessoa_relacao
         AND c.idpessoa = b.idpessoa_fonte_renda
         AND c.nmpessoa = pr_nmpessoa;
    rw_empresa cr_empresa%ROWTYPE;
    
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
    
    -- variaveis gerais
    vr_pessoa_relacao tbcadast_pessoa_relacao%ROWTYPE;
    
    vr_flcria_pessoa  BOOLEAN := FALSE; -- Indicador se deve criar cadastro de pessoa
    vr_pessoa_fisica  vwcadast_pessoa_fisica%ROWTYPE;    -- Registro de pessoa fisica
    vr_pessoa_renda tbcadast_pessoa_renda%ROWTYPE; -- Registro com os dados da renda
    vr_flcria_empresa BOOLEAN := FALSE; -- Indicador se deve criar a empresa de trabalho do conjuge
    vr_nrddd          tbcadast_pessoa_telefone.nrddd%TYPE; -- Numero do DDD
    vr_nrtelefone     tbcadast_pessoa_telefone.nrtelefone%TYPE; -- Numero do telefone
    vr_nrramal        tbcadast_pessoa_telefone.nrramal%TYPE; -- Numero do Ramal

  BEGIN
    -- Abre o cursor de conjuge
    OPEN cr_crapcje;
    FETCH cr_crapcje INTO rw_crapcje;
    -- Se nao existe conjuge, finaliza a rotina
    IF cr_crapcje%NOTFOUND THEN
      CLOSE cr_crapcje;
      RETURN;
    END IF;
    CLOSE cr_crapcje;

    -- Se possuir conta, entao verifica se a conta ja esta cadastrada como pessoa
    IF rw_crapcje.nrctacje > 0 THEN
      -- Verifica se existe pessoa
      OPEN cr_pessoa(pr_nrcpf => rw_crapcje.nrcpfcgc);
      FETCH cr_pessoa INTO rw_pessoa;

      -- Se nao existe a conta, deve-se criar
      IF cr_pessoa%NOTFOUND THEN
        -- Fecha o cursor
        CLOSE cr_pessoa;

        -- Efetua a inclusao de pessoa
        cada0011.pc_insere_pessoa_crapass(pr_cdcooper => pr_cdcooper,
                                          pr_nrdconta => rw_crapcje.nrctacje,
                                          pr_idseqttl => 1,
                                          pr_cdoperad => pr_cdoperad,
                                          pr_cdcritic => vr_cdcritic,
                                          pr_dscritic => vr_dscritic);
        -- Verifica se deu erro
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
        -- Busca a pessoa que foi cadastrada
        OPEN cr_pessoa(pr_nrcpf => rw_crapcje.nrcpfcgc);
        FETCH cr_pessoa INTO rw_pessoa;
      END IF;
      
      -- Fecha o cursor
      CLOSE cr_pessoa;

      -- Busca o relacionamento se ja existir com a conta de conjuge
      OPEN cr_relacionamento;
      FETCH cr_relacionamento INTO rw_relacionamento;
      CLOSE cr_relacionamento;
        
      -- Se a pessoa da relacao for diferente do que esta cadastrado
      IF nvl(rw_relacionamento.idpessoa_relacao,0) <> rw_pessoa.idpessoa THEN
        -- Atualiza os dados da relacao
        vr_pessoa_relacao.idpessoa := pr_idpessoa;
        vr_pessoa_relacao.idpessoa_relacao := rw_pessoa.idpessoa;
        vr_pessoa_relacao.tprelacao := 1; -- Conjuge
        vr_pessoa_relacao.nrseq_relacao := rw_relacionamento.nrseq_relacao;
        vr_pessoa_relacao.cdoperad_altera := pr_cdoperad;
        -- Cria o relacionamento
        cada0010.pc_cadast_pessoa_relacao(pr_pessoa_relacao => vr_pessoa_relacao,
                                          pr_cdcritic       => vr_cdcritic,
                                          pr_dscritic       => vr_dscritic);
        -- Verifica se deu erro
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;

    ELSE -- Se nao tem conta
      -- Verifica se possui CPF
      IF nvl(rw_crapcje.nrcpfcjg,0) > 0 THEN
        -- Verifica se este CPF possui cadastro de pessoa
        OPEN cr_pessoa(pr_nrcpf => rw_crapcje.nrcpfcjg);
        FETCH cr_pessoa INTO rw_pessoa;
      
        -- Busca o relacionamento se ja existir com a conta de conjuge
        OPEN cr_relacionamento;
        FETCH cr_relacionamento INTO rw_relacionamento;
        CLOSE cr_relacionamento;

        -- Se ja possui cadastro de pessoa, entao apenas efetua o relacionamento
        IF cr_pessoa%FOUND THEN
          CLOSE cr_pessoa;
            
          -- Se a pessoa da relacao for diferente do que esta cadastrado
          IF nvl(rw_relacionamento.idpessoa_relacao,0) <> rw_pessoa.idpessoa THEN
            -- Atualiza os dados da relacao
            vr_pessoa_relacao.idpessoa := pr_idpessoa;
            vr_pessoa_relacao.idpessoa_relacao := rw_pessoa.idpessoa;
            vr_pessoa_relacao.tprelacao := 1; -- Conjuge
            vr_pessoa_relacao.nrseq_relacao := rw_relacionamento.nrseq_relacao;
            vr_pessoa_relacao.cdoperad_altera := pr_cdoperad;
            -- Cria o relacionamento
            cada0010.pc_cadast_pessoa_relacao(pr_pessoa_relacao => vr_pessoa_relacao,
                                              pr_cdcritic       => vr_cdcritic,
                                              pr_dscritic       => vr_dscritic);
            -- Verifica se deu erro
            IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
          END IF;
        ELSE -- Se nao possui cadastro de pessoa, deve-se criar
          CLOSE cr_pessoa;
          -- Atualiza flag de criar pessoa como SIM
          vr_flcria_pessoa := TRUE;
          vr_pessoa_relacao := NULL;
          vr_pessoa_relacao.nrseq_relacao := rw_relacionamento.nrseq_relacao;
          
        END IF;
      ELSE -- Se possui conjuge, mas o mesmo nao possui CPF
        -- Se o nome do conjuge tambem for vazio, ignora o registro
        IF trim(rw_crapcje.nmconjug) IS NULL THEN
          RETURN; -- Retorna para o programa de origem
        END IF;

        -- Verifica se para a pessoa já existe conjuge relacionado
        OPEN cr_relacionamento;
        FETCH cr_relacionamento INTO rw_relacionamento;
        CLOSE cr_relacionamento;
        
        -- Se o conjuge que estiver cadastrado for diferente do que o informado
        -- ou se o conjuge ainda nao estiver cadastrado na tabela de pessoa
        IF nvl(rw_relacionamento.nmpessoa,' ') <> trim(rw_crapcje.nmconjug) THEN
          -- Deve-se criar a pessoa
          vr_flcria_pessoa := TRUE;
          vr_pessoa_relacao := NULL;
          vr_pessoa_relacao.nrseq_relacao := rw_relacionamento.nrseq_relacao;
          
        ELSE -- Se o nome for igual, entao a pessoa ja existe e esta relacionada
          RETURN; -- Nao deve-se fazer nada
        END IF;
        
      END IF; -- Fim da verificacao se possui CPF ou nao
      
    END IF; -- Fim da verificacao se possui conta ou nao
    
    -- Se deve-se criar a pessoa
    IF vr_flcria_pessoa THEN
      IF nvl(rw_crapcje.nrcpfcjg,0) > 0 THEN
        rw_pessoa.nrcpf                := rw_crapcje.nrcpfcjg;
      END IF;
      rw_pessoa.nmpessoa             := rw_crapcje.nmconjug;
      rw_pessoa.tppessoa             := 1; -- Fisica
      rw_pessoa.tpcadastro           := 1; -- Prospect
      rw_pessoa.dtnascimento         := rw_crapcje.dtnasccj;
      rw_pessoa.tpdocumento          := rw_crapcje.tpdoccje;
      rw_pessoa.nrdocumento          := rw_crapcje.nrdoccje;
      IF rw_crapcje.idorgexp <> 0 THEN
        rw_pessoa.idorgao_expedidor    := rw_crapcje.idorgexp; 
      END IF;
      rw_pessoa.cduf_orgao_expedidor := trim(rw_crapcje.cdufdcje);
      rw_pessoa.dtemissao_documento  := rw_crapcje.dtemdcje;
      IF nvl(rw_crapcje.grescola,0) > 0 THEN
        rw_pessoa.cdgrau_escolaridade  := rw_crapcje.grescola; 
      END IF;
      rw_pessoa.cdcurso_superior     := rw_crapcje.cdfrmttl;
      IF rw_crapcje.cdnatopc <> 0 THEN
        rw_pessoa.cdnatureza_ocupacao  := rw_crapcje.cdnatopc;
      END IF;
      rw_pessoa.dsprofissao          := rw_crapcje.dsproftl;
      rw_pessoa.cdoperad_altera      := pr_cdoperad;

      -- Insere o Cadastro de pessoa fisica
      cada0010.pc_cadast_pessoa_fisica(pr_pessoa_fisica => rw_pessoa,
                                       pr_cdcritic      => vr_cdcritic,
                                       pr_dscritic      => vr_dscritic);
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Efetua o relacionamento
      vr_pessoa_relacao.idpessoa := pr_idpessoa;
      vr_pessoa_relacao.tprelacao := 1; -- Conjuge
      vr_pessoa_relacao.idpessoa_relacao := rw_pessoa.idpessoa;
      vr_pessoa_relacao.cdoperad_altera  := pr_cdoperad;
      -- Cria o relacionamento
      cada0010.pc_cadast_pessoa_relacao(pr_pessoa_relacao => vr_pessoa_relacao,
                                        pr_cdcritic       => vr_cdcritic,
                                        pr_dscritic       => vr_dscritic);
      -- Verifica se deu erro
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Verifica se possui informacoes da renda do conjuge
      IF nvl(rw_crapcje.tpcttrab,0) <> 0 OR
         nvl(rw_crapcje.cdnvlcgo,0) <> 0 OR
         nvl(rw_crapcje.cdturnos,0) <> 0 OR
         rw_crapcje.dtadmemp IS NOT NULL OR
         nvl(rw_crapcje.vlsalari,0) <> 0 OR
         nvl(rw_crapcje.nrdocnpj,0) <> 0 OR
         TRIM(rw_crapcje.nmextemp) IS NOT NULL THEN
             
        -- Inicia a gravacao da renda da pessoa
        -- Se possuir CNPJ, verifica se esta cadastrado
        IF nvl(rw_crapcje.nrdocnpj,0) > 0 THEN
           
          -- Verifica se existe PJ
          OPEN cr_pessoa_juridica(pr_nrcnpj => rw_crapcje.nrdocnpj);
          FETCH cr_pessoa_juridica INTO rw_pessoa_juridica;
          -- Se nao existir, tem que criar
          IF cr_pessoa_juridica%NOTFOUND THEN
            -- Atualiza o indicador para criar o CNPJ
            vr_flcria_empresa := TRUE;
            rw_pessoa_juridica.nrcnpj := rw_crapcje.nrdocnpj;
          ELSE -- Se encontrou a pessoa juridica
            -- Atualiza o ID da pessoa juridica
            vr_pessoa_renda.idpessoa_fonte_renda := rw_pessoa_juridica.idpessoa;
          END IF;
          CLOSE cr_pessoa_juridica;
          
        ELSIF trim(rw_crapcje.nmextemp) IS NOT NULL THEN -- Se tem nome de empresa informado
          -- Verifica se ja existe empresa para este conjuge
          OPEN cr_empresa(rw_crapcje.nmextemp);
          FETCH cr_empresa INTO rw_empresa;
          IF cr_empresa%FOUND THEN
            -- Atualiza o ID da pessoa juridica
            vr_pessoa_renda.idpessoa_fonte_renda := rw_empresa.idpessoa;
          ELSE
            -- Atualiza o indicador para criar o CNPJ
            vr_flcria_empresa := TRUE;
          END IF;
          CLOSE cr_empresa;
        END IF;

        -- Atualiza a tabela de renda
        vr_pessoa_renda.idpessoa := rw_pessoa.idpessoa;
        IF rw_crapcje.cdocpcje <> 0 THEN
          vr_pessoa_renda.cdocupacao := rw_crapcje.cdocpcje;
        END IF;
        vr_pessoa_renda.tpcontrato_trabalho := rw_crapcje.tpcttrab;
        vr_pessoa_renda.cdnivel_cargo := rw_crapcje.cdnvlcgo;
        vr_pessoa_renda.cdturno := rw_crapcje.cdturnos;
        vr_pessoa_renda.dtadmissao := rw_crapcje.dtadmemp;
        vr_pessoa_renda.vlrenda := rw_crapcje.vlsalari;
        vr_pessoa_renda.cdoperad_altera := pr_cdoperad;
            
        -- Se o indicador de criacao de empresa estiver ligado
        IF vr_flcria_empresa THEN
          -- Verifica se a empresa de trabalho eh um CPF ou CNPJ
          -- Se for um CPF
          IF nvl(rw_pessoa_juridica.nrcnpj,0) > 0 AND
             SUBSTR(rw_pessoa_juridica.nrcnpj,LENGTH(rw_pessoa_juridica.nrcnpj)-1) <> gene0005.fn_retorna_digito_cnpj(pr_nrcalcul => SUBSTR(rw_pessoa_juridica.nrcnpj,1,LENGTH(rw_pessoa_juridica.nrcnpj)-2)) THEN
            -- Popula os dados de pessoa fisica
            vr_pessoa_fisica.nrcpf                := rw_pessoa_juridica.nrcnpj;
            vr_pessoa_fisica.nmpessoa             := rw_crapcje.nmextemp;
            vr_pessoa_fisica.tppessoa             := 1; -- Fisica
            vr_pessoa_fisica.tpcadastro           := 1; -- Prospect
            vr_pessoa_fisica.cdoperad_altera      := pr_cdoperad;
            -- Cria a pessoa fisica
            cada0010.pc_cadast_pessoa_fisica(pr_pessoa_fisica => vr_pessoa_fisica,
                                             pr_cdcritic      => vr_cdcritic,
                                             pr_dscritic      => vr_dscritic);
            IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
            -- Atualiza com o ID pessoa que foi criado
            vr_pessoa_renda.idpessoa_fonte_renda := vr_pessoa_fisica.idpessoa;
          ELSE -- Se for PF
            -- Popula os dados de pessoa juridica
            rw_pessoa_juridica.nmpessoa             := rw_crapcje.nmextemp;
            rw_pessoa_juridica.tppessoa             := 2; -- Juridica
            rw_pessoa_juridica.tpcadastro           := 1; -- Prospect
            rw_pessoa_juridica.cdoperad_altera      := pr_cdoperad;
            -- Cria a pessoa juridica
            cada0010.pc_cadast_pessoa_juridica(pr_pessoa_juridica => rw_pessoa_juridica,
                                               pr_cdcritic      => vr_cdcritic,
                                               pr_dscritic      => vr_dscritic);
            IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
            -- Atualiza com o ID pessoa que foi criado
            vr_pessoa_renda.idpessoa_fonte_renda := rw_pessoa_juridica.idpessoa;
          END IF;            
        END IF;
            
        -- Cria o registro de renda
        cada0010.pc_cadast_pessoa_renda(pr_pessoa_renda => vr_pessoa_renda,
                                        pr_cdcritic      => vr_cdcritic,
                                        pr_dscritic      => vr_dscritic);
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
          
      END IF; -- Verificacao da renda do conjuge   
        
      -- Se possui telefone
      IF TRIM(rw_crapcje.nrfonemp) IS NOT NULL THEN
        -- Estrutura o telefone
        pc_trata_telefone(pr_nrtelefone_org => rw_crapcje.nrfonemp,
                          pr_nrramal_org => rw_crapcje.nrramemp, 
                          pr_nrddd => vr_nrddd,
                          pr_nrtelefone =>  vr_nrtelefone,
                          pr_nrramal => vr_nrramal,
                          pr_dscritic => vr_dscritic);
                            
        -- Verifica se este telefone ja nao existe para a pessoa
        OPEN cr_pessoa_telefone(pr_idpessoa => rw_pessoa.idpessoa,
                                pr_nrtelefone => vr_nrtelefone);
        FETCH cr_pessoa_telefone INTO rw_pessoa_telefone;
        -- Se nao encontrar, insere o telefone
        IF cr_pessoa_telefone%NOTFOUND THEN
          rw_pessoa_telefone.idpessoa := rw_pessoa.idpessoa;
          rw_pessoa_telefone.tptelefone := 3; -- Comercial
          rw_pessoa_telefone.nrddd := vr_nrddd;
          rw_pessoa_telefone.nrtelefone := vr_nrtelefone;
          rw_pessoa_telefone.nrramal := vr_nrramal;
          rw_pessoa_telefone.insituacao := 1; -- Ativo
          rw_pessoa_telefone.cdoperad_altera := pr_cdoperad;
          rw_pessoa_telefone.tporigem_cadastro := 2;
            
          -- Insere o telefone
          cada0010.pc_cadast_pessoa_telefone(pr_pessoa_telefone => rw_pessoa_telefone,
                                             pr_cdcritic      => vr_cdcritic,
                                             pr_dscritic      => vr_dscritic);
          IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            CLOSE cr_pessoa_telefone;
            RAISE vr_exc_erro;
          END IF;
        END IF;
        CLOSE cr_pessoa_telefone;
      END IF; -- Fim da verificacao se possui telefone da empresa
      
    END IF; -- Fim da verificacao se deve criar a pessoa para o conjuge
      

	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_insere_pessoa_crapass: ' ||SQLERRM;
  END;  
  
  -- Rotina para cadastro de pessoa com base na tabela CRAPASS
  PROCEDURE pc_insere_pessoa_crapass(pr_cdcooper crapass.cdcooper%TYPE -- Codigo da cooperativa
                                    ,pr_nrdconta crapass.nrdconta%TYPE -- Numero da conta
                                    ,pr_idseqttl crapttl.idseqttl%TYPE -- Sequencia do titular
                                    ,pr_cdoperad crapope.cdoperad%TYPE -- Codigo do operador que esta efetuando a operacao
                                    ,pr_cdcritic OUT INTEGER           -- Codigo de erro
                                    ,pr_dscritic OUT VARCHAR2) IS      -- Retorno de Erro

    -- Busca os dados da conta
    CURSOR cr_crapass IS
      SELECT nrcpfcgc
            ,nmprimtl
            ,inpessoa
            ,cdturnos
            ,dtcnsspc
            ,dtcnscpf
            ,cdsitcpf
            ,dtcnsscr
            ,cdclcnae
            ,nmttlrfb
            ,inconrfb
            ,idorgexp
        FROM crapass
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    
    -- Busca os dados do primeiro titular
    CURSOR cr_crapttl IS
      SELECT nrcpfcgc
            ,nmextttl
            ,dtnasttl
            ,dsproftl
            ,tpdocttl
            ,nrdocttl
            ,cdturnos
            ,cdestcvl
            ,cdufdttl
            ,inhabmen
            ,cdsexotl
            ,dtemdttl
            ,dtcnscpf
            ,cdsitcpf
            ,substr(nmpaittl,1,60) nmpaittl
            ,substr(nmmaettl,1,60) nmmaettl
            ,dsnatura
            ,grescola
            ,cdfrmttl
            ,cdnatopc
            ,cdocpttl
            ,tpcttrab
            ,cdempres
            ,dtadmemp
            ,cdnvlcgo
            ,vlsalari
            ,tpnacion
            ,dthabmen
            ,tpdrendi##1
            ,tpdrendi##2
            ,tpdrendi##3
            ,tpdrendi##4
            ,tpdrendi##5
            ,tpdrendi##6
            ,vldrendi##1
            ,vldrendi##2
            ,vldrendi##3
            ,vldrendi##4
            ,vldrendi##5
            ,vldrendi##6
            ,inpolexp
            ,dsjusren
            ,cdufnatu
            ,dtatutel
            ,idorgexp
            ,cdnacion
        FROM crapttl a
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND idseqttl = pr_idseqttl; 
    rw_crapttl cr_crapttl%ROWTYPE;
    
    -- Busca os dados para quando a conta for uma PJ
    CURSOR cr_crapjur IS
      SELECT a.nmextttl 
            ,a.dtatutel
            ,a.nmfansia
            ,a.nrinsest
            ,a.natjurid
            ,a.dtiniatv
            ,a.qtfilial
            ,a.qtfuncio
            ,a.vlcaprea
            ,a.dtregemp
            ,a.nrregemp
            ,a.orregemp
            ,a.dtinsnum
            ,a.nrcdnire
            ,a.flgrefis
            ,a.dsendweb
            ,a.nrinsmun
            ,a.cdseteco
            ,a.vlfatano
            ,a.cdrmativ
            ,a.nrlicamb
            ,a.dtvallic
        FROM crapjur a
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrdconta = pr_nrdconta;
    rw_crapjur cr_crapjur%ROWTYPE;
    
    -- Busca os dados da pessoa fisica
    CURSOR cr_pessoa_fisica IS
      SELECT *
        FROM vwcadast_pessoa_fisica
       WHERE nrcpf    = rw_crapttl.nrcpfcgc;
    
    -- Busca os dados da pessoa juridica
    CURSOR cr_pessoa_juridica IS
      SELECT *
        FROM vwcadast_pessoa_juridica
       WHERE nrcnpj   = rw_crapass.nrcpfcgc;

    -- Busca os dados financeiros da pessoa juridica
    CURSOR cr_crapjfn IS
      SELECT *
        FROM crapjfn
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta;
    rw_crapjfn cr_crapjfn%ROWTYPE;

    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;

    -- Variaveis de pessoa
    vr_idpessoa        tbcadast_pessoa.idpessoa%TYPE;    -- ID de pessoa
    vr_pessoa_fisica   vwcadast_pessoa_fisica%ROWTYPE;   -- Registro de pessoa fisica
    vr_pessoa_juridica vwcadast_pessoa_juridica%ROWTYPE; -- Registro de pessoa juridica

  BEGIN
    -- busca os dadoa da conta
    OPEN cr_crapass;
    FETCH cr_crapass INTO rw_crapass;
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;  
      vr_dscritic := 'Conta informada ('||pr_cdcooper||'-'||pr_nrdconta||') inexistente!';
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapass;  

    -- Se for PF, efetua tratativas para esta modalidade
    IF rw_crapass.inpessoa = 1 THEN
      -- Busca os dados da tabela de titulares
      OPEN cr_crapttl;
      FETCH cr_crapttl INTO rw_crapttl;
      IF cr_crapttl%NOTFOUND THEN
        CLOSE cr_crapttl;  
        vr_dscritic := 'Conta informada nao possui primeiro titular!';
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_crapttl;  

      -- Busca os dados da pessoa, caso ela exista, através do CPF
      LOOP
        OPEN cr_pessoa_fisica;
        FETCH cr_pessoa_fisica INTO vr_pessoa_fisica;
        IF cr_pessoa_fisica%NOTFOUND THEN
          -- Verifica se existe como pessoa juridica
          BEGIN
            UPDATE tbcadast_pessoa
               SET tppessoa = 1
             WHERE nrcpfcgc = rw_crapttl.nrcpfcgc;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao alterar o tipo de pessoa: '||SQLERRM;
              RAISE vr_exc_erro;
          END;
          -- Se encontrou, deve-se retornar ao inicio do loop
          IF SQL%ROWCOUNT > 0 THEN
            CLOSE cr_pessoa_fisica;
            CONTINUE;
          END IF;
        END IF;
        CLOSE cr_pessoa_fisica;
        EXIT;
      END LOOP;
      
      -- Se existir e ja possuir cadastro intermediario, deve-se encerrar o processo
      -- Pois podera ficar em loop, nos casos de conjuge, por exemplo
      IF nvl(vr_pessoa_fisica.tpcadastro,0) > 2 THEN
        RETURN;
      END IF;
      
      -- Se for uma naturalidade estrangeira, gera no campo de estrangeiros
      IF rw_crapttl.cdufnatu = 'EX' THEN
        vr_pessoa_fisica.dsnaturalidade := rw_crapttl.dsnatura; 
        vr_pessoa_fisica.cdpais         := rw_crapttl.cdnacion;
      ELSE
        -- Busca o municipio da naturalidade
        CADA0015.pc_trata_municipio(pr_dscidade => rw_crapttl.dsnatura,
                           pr_cdestado => trim(rw_crapttl.cdufnatu),
                           pr_idcidade => vr_pessoa_fisica.cdnaturalidade,
                           pr_dscritic => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;
    

      -- Atualiza os dados de pessoa fisica
      vr_pessoa_fisica.nrcpf                  := rw_crapttl.nrcpfcgc;
      vr_pessoa_fisica.nmpessoa               := rw_crapttl.nmextttl;
      vr_pessoa_fisica.tppessoa               := 1; -- Fisica
      vr_pessoa_fisica.dtconsulta_rfb         := rw_crapttl.dtcnscpf;
      vr_pessoa_fisica.cdsituacao_rfb         := rw_crapttl.cdsitcpf;
      vr_pessoa_fisica.dtatualiza_telefone    := rw_crapttl.dtatutel;
      vr_pessoa_fisica.tpcadastro             := 4; -- Cadastro completo
      vr_pessoa_fisica.cdoperad_altera        := pr_cdoperad;
      vr_pessoa_fisica.tpsexo                 := rw_crapttl.cdsexotl;
      IF nvl(rw_crapttl.cdestcvl,0) > 0 THEN
        vr_pessoa_fisica.cdestado_civil         := rw_crapttl.cdestcvl;
      END IF;
      vr_pessoa_fisica.dtnascimento           := rw_crapttl.dtnasttl;
      IF nvl(rw_crapttl.cdnacion,0) > 0 THEN
        vr_pessoa_fisica.cdnacionalidade        := rw_crapttl.cdnacion;
      END IF;
      vr_pessoa_fisica.tpnacionalidade        := rw_crapttl.tpnacion;
      vr_pessoa_fisica.tpdocumento            := rw_crapttl.tpdocttl;
      vr_pessoa_fisica.nrdocumento            := rw_crapttl.nrdocttl;
      vr_pessoa_fisica.dtemissao_documento    := rw_crapttl.dtemdttl;
      IF rw_crapttl.idorgexp <> 0 THEN
        vr_pessoa_fisica.idorgao_expedidor      := rw_crapttl.idorgexp; 
      END IF;
      vr_pessoa_fisica.cduf_orgao_expedidor   := TRIM(rw_crapttl.cdufdttl);
      vr_pessoa_fisica.inhabilitacao_menor    := rw_crapttl.inhabmen;
      vr_pessoa_fisica.dthabilitacao_menor    := rw_crapttl.dthabmen;
      IF nvl(rw_crapttl.grescola,0) > 0 THEN
        vr_pessoa_fisica.cdgrau_escolaridade    := rw_crapttl.grescola;
      END IF;
      vr_pessoa_fisica.cdcurso_superior       := rw_crapttl.cdfrmttl;
      IF rw_crapttl.cdnatopc <> 0 THEN
        vr_pessoa_fisica.cdnatureza_ocupacao    := rw_crapttl.cdnatopc;
      END IF;
      vr_pessoa_fisica.dsprofissao            := rw_crapttl.dsproftl;
      vr_pessoa_fisica.dsjustific_outros_rend := rw_crapttl.dsjusren;

      -- Os campos abaixo existem apenas na CRAPASS. Serao atualizados somente se
      -- for para o primeiro titular
      IF pr_idseqttl = 1 THEN
        vr_pessoa_fisica.dtconsulta_scr         := rw_crapass.dtcnsscr;
        vr_pessoa_fisica.dtconsulta_spc         := rw_crapass.dtcnsspc;
        vr_pessoa_fisica.nmpessoa_receita       := rw_crapass.nmttlrfb;
        IF rw_crapass.inconrfb = 0 THEN
          vr_pessoa_fisica.tpconsulta_rfb       := 2;
        ELSE
          vr_pessoa_fisica.tpconsulta_rfb       := 1;
        END IF;
      END IF;


      -- Insere o Cadastro de pessoa fisica
      cada0010.pc_cadast_pessoa_fisica(pr_pessoa_fisica => vr_pessoa_fisica,
                                       pr_cdcritic      => vr_cdcritic,
                                       pr_dscritic      => vr_dscritic);
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- Atualiza o ID PESSOA
      vr_idpessoa := vr_pessoa_fisica.idpessoa;

      -- Efetua tratativa pai
      IF trim(rw_crapttl.nmpaittl) IS NOT NULL THEN
        pc_trata_pessoa_relacao(pr_idpessoa => vr_pessoa_fisica.idpessoa,
                                pr_tprelacao=> 3, -- Pai
                                pr_nmpessoa => rw_crapttl.nmpaittl,
                                pr_cdoperad => pr_cdoperad,
                                pr_cdcritic => vr_cdcritic,
                                pr_dscritic => vr_dscritic);
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;

      -- Efetua tratativa mae
      IF trim(rw_crapttl.nmmaettl) IS NOT NULL THEN
        pc_trata_pessoa_relacao(pr_idpessoa => vr_pessoa_fisica.idpessoa,
                                pr_tprelacao=> 4, -- Mae
                                pr_nmpessoa => rw_crapttl.nmmaettl,
                                pr_cdoperad => pr_cdoperad,
                                pr_cdcritic => vr_cdcritic,
                                pr_dscritic => vr_dscritic);
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;

      -- Trata os casos de conjuge
      pc_insere_pessoa_crapcje(pr_cdcooper => pr_cdcooper
                              ,pr_idpessoa => vr_idpessoa
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
                          
      -- Insere o dependente
      pc_insere_dependente(pr_cdcooper => pr_cdcooper
                          ,pr_idpessoa => vr_idpessoa
                          ,pr_idseqttl => pr_idseqttl
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_cdcritic => vr_cdcritic
                          ,pr_dscritic => vr_dscritic);
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Insere o politico exposto
      pc_insere_politico_exposto(pr_cdcooper => pr_cdcooper
                                ,pr_idpessoa => vr_idpessoa
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_idseqttl => pr_idseqttl
                                ,pr_cdoperad => pr_cdoperad
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Efetua a inclusao de responsavel legal
      pc_insere_responsavel_legal(pr_cdcooper => pr_cdcooper
                                 ,pr_idpessoa => vr_idpessoa
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_idseqttl => pr_idseqttl
                                 ,pr_cdoperad => pr_cdoperad
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- Efetua a inclusao de pessoas de referencia
      pc_insere_referencia(pr_cdcooper => pr_cdcooper
                          ,pr_idpessoa => vr_idpessoa
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_idseqttl => pr_idseqttl
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_cdcritic => vr_cdcritic
                          ,pr_dscritic => vr_dscritic);
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      

                          
    ELSE -- Se for uma pessoa juridica
      -- Busca os dados da pessoa, caso ela exista
      OPEN cr_pessoa_juridica;
      FETCH cr_pessoa_juridica INTO vr_pessoa_juridica;
      CLOSE cr_pessoa_juridica;

      -- Busca os dados de pessoa juridica
      OPEN cr_crapjur;
      FETCH cr_crapjur INTO rw_crapjur;
      IF cr_crapjur%NOTFOUND THEN
        CLOSE cr_crapjur;  
        vr_dscritic := 'Conta informada nao possui cadastro juridico!';
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_crapjur;  
      
      vr_pessoa_juridica.nrcnpj                 := rw_crapass.nrcpfcgc;
      vr_pessoa_juridica.nmpessoa               := rw_crapjur.nmextttl;
      vr_pessoa_juridica.nmpessoa_receita       := rw_crapass.nmttlrfb;
      vr_pessoa_juridica.tppessoa               := 2; -- Pessoa Juridica
      vr_pessoa_juridica.dtconsulta_spc         := rw_crapass.dtcnsspc;
      vr_pessoa_juridica.dtconsulta_rfb         := rw_crapass.dtcnscpf;
      vr_pessoa_juridica.cdsituacao_rfb         := rw_crapass.cdsitcpf;
      IF rw_crapass.inconrfb = 0 THEN
        vr_pessoa_juridica.tpconsulta_rfb       := 2; -- Manual
      ELSE
        vr_pessoa_juridica.tpconsulta_rfb       := 1; -- Automatica
      END IF;
      vr_pessoa_juridica.dtatualiza_telefone    := rw_crapjur.dtatutel;
      vr_pessoa_juridica.dtconsulta_scr         := rw_crapass.dtcnsscr;
      vr_pessoa_juridica.tpcadastro             := 3; -- Cadastro Intermediario
      vr_pessoa_juridica.cdoperad_altera        := pr_cdoperad;
      IF rw_crapass.cdclcnae > 0 THEN
        vr_pessoa_juridica.cdcnae                 := rw_crapass.cdclcnae;
      END IF;
      vr_pessoa_juridica.nmfantasia             := rw_crapjur.nmfansia;
      vr_pessoa_juridica.nrinscricao_estadual   := rw_crapjur.nrinsest;
      IF nvl(rw_crapjur.natjurid,0) > 0 THEN
        vr_pessoa_juridica.cdnatureza_juridica    := rw_crapjur.natjurid;
      END IF;
      vr_pessoa_juridica.dtinicio_atividade     := rw_crapjur.dtiniatv;
      vr_pessoa_juridica.qtfilial               := rw_crapjur.qtfilial;
      vr_pessoa_juridica.qtfuncionario          := rw_crapjur.qtfuncio;
      vr_pessoa_juridica.vlcapital              := rw_crapjur.vlcaprea;
      vr_pessoa_juridica.dtregistro             := rw_crapjur.dtregemp;
      vr_pessoa_juridica.nrregistro             := rw_crapjur.nrregemp;
      vr_pessoa_juridica.dsorgao_registro       := rw_crapjur.orregemp; 
      vr_pessoa_juridica.dtinscricao_municipal  := rw_crapjur.dtinsnum;
      vr_pessoa_juridica.nrnire                 := rw_crapjur.nrcdnire;
      vr_pessoa_juridica.inrefis                := rw_crapjur.flgrefis;
      vr_pessoa_juridica.dssite                 := rw_crapjur.dsendweb;
      vr_pessoa_juridica.nrinscricao_municipal  := rw_crapjur.nrinsmun;
      vr_pessoa_juridica.cdsetor_economico      := rw_crapjur.cdseteco;
      vr_pessoa_juridica.vlfaturamento_anual    := rw_crapjur.vlfatano;
      vr_pessoa_juridica.cdramo_atividade       := rw_crapjur.cdrmativ;
      vr_pessoa_juridica.nrlicenca_ambiental    := rw_crapjur.nrlicamb;
      vr_pessoa_juridica.dtvalidade_licenca_amb := rw_crapjur.dtvallic;

      -- Busca os dados financeiros para PJ
      OPEN cr_crapjfn;
      FETCH cr_crapjfn INTO rw_crapjfn;
      IF cr_crapjfn%FOUND THEN
        vr_pessoa_juridica.peunico_cliente            := rw_crapjfn.perfatcl;
        vr_pessoa_juridica.vlreceita_bruta            := rw_crapjfn.vlrctbru;
        vr_pessoa_juridica.vlcusto_despesa_adm        := rw_crapjfn.vlctdpad;
        vr_pessoa_juridica.vldespesa_administrativa   := rw_crapjfn.vldspfin;
        vr_pessoa_juridica.qtdias_recebimento         := rw_crapjfn.ddprzrec;
        vr_pessoa_juridica.qtdias_pagamento           := rw_crapjfn.ddprzpag;
        vr_pessoa_juridica.vlativo_caixa_banco_apl    := rw_crapjfn.vlcxbcaf;
        vr_pessoa_juridica.vlativo_contas_receber     := rw_crapjfn.vlctarcb;
        vr_pessoa_juridica.vlativo_estoque            := rw_crapjfn.vlrestoq;
        vr_pessoa_juridica.vlativo_imobilizado        := rw_crapjfn.vlrimobi;
        vr_pessoa_juridica.vlativo_outros             := rw_crapjfn.vloutatv;
        vr_pessoa_juridica.vlpassivo_fornecedor       := rw_crapjfn.vlfornec;
        vr_pessoa_juridica.vlpassivo_divida_bancaria  := rw_crapjfn.vldivbco;
        vr_pessoa_juridica.vlpassivo_outros           := rw_crapjfn.vloutpas;
        IF rw_crapjfn.mesdbase BETWEEN 1 AND 12 AND
           rw_crapjfn.anodbase BETWEEN 1900 AND (to_char(SYSDATE,'YYYY')+1) THEN
          vr_pessoa_juridica.dtmes_base                 := to_date(to_char(rw_crapjfn.mesdbase,'fm00')||rw_crapjfn.anodbase,'MMYYYY'); 
        END IF;
      END IF;
      CLOSE cr_crapjfn;

      -- Insere o Cadastro de pessoa fisica
      cada0010.pc_cadast_pessoa_juridica(pr_pessoa_juridica => vr_pessoa_juridica,
                                         pr_cdcritic        => vr_cdcritic,
                                         pr_dscritic        => vr_dscritic);
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Atualiza o ID PESSOA
      vr_idpessoa := vr_pessoa_juridica.idpessoa;

      -- Efetua a tratativa de banco da pessoa juridica
      pc_insere_juridico_bco(pr_crapjfn  => rw_crapjfn
                            ,pr_idpessoa => vr_idpessoa
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Efetua a tratativa de faturamento da pessoa juridica
      pc_insere_juridico_fat(pr_crapjfn  => rw_crapjfn
                            ,pr_idpessoa => vr_idpessoa
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Efetua a tratativa de participacoes em outras empresas da pessoa juridica
      pc_insere_juridico_ptp(pr_cdcooper => pr_cdcooper
                            ,pr_idpessoa => vr_idpessoa
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Efetua a tratativa de representantes
      pc_insere_juridico_rep(pr_cdcooper => pr_cdcooper
                            ,pr_idpessoa => vr_idpessoa
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Efetua a inclusao de pessoas de referencia
      pc_insere_referencia(pr_cdcooper => pr_cdcooper
                          ,pr_idpessoa => vr_idpessoa
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_idseqttl => 0 -- Quando eh zero, deve-se levar todos
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_cdcritic => vr_cdcritic
                          ,pr_dscritic => vr_dscritic);
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      
    END IF; -- Fim da verificacao se eh pessoa fisica ou juridica

    -- Exclui todos os emails que ja haviam sido cadastrados, atraves de outros meios
    BEGIN
      DELETE tbcadast_pessoa_email
       WHERE idpessoa = vr_idpessoa;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro exclusao geral email: '||SQLERRM;
        RAISE vr_exc_erro;
    END;

    -- Efetua a tratativa de e-mails
    pc_insere_email(pr_cdcooper => pr_cdcooper
                   ,pr_idpessoa => vr_idpessoa
                   ,pr_nrdconta => pr_nrdconta
                   ,pr_idseqttl => pr_idseqttl
                   ,pr_cdoperad => pr_cdoperad
                   ,pr_cdcritic => vr_cdcritic
                   ,pr_dscritic => vr_dscritic);
    IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
      
    -- Efetua a inclusao dos bens
    pc_insere_bem(pr_cdcooper => pr_cdcooper
                 ,pr_idpessoa => vr_idpessoa
                 ,pr_nrdconta => pr_nrdconta
                 ,pr_idseqttl => pr_idseqttl
                 ,pr_cdoperad => pr_cdoperad
                 ,pr_cdcritic => vr_cdcritic
                 ,pr_dscritic => vr_dscritic);
    IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    -- Efetua a inclusao de renda
    pc_insere_renda(pr_cdcooper => pr_cdcooper
                   ,pr_idpessoa => vr_idpessoa
                   ,pr_nrdconta => pr_nrdconta
                   ,pr_idseqttl => pr_idseqttl
                   ,pr_cdoperad => pr_cdoperad
                   ,pr_cdcritic => vr_cdcritic
                   ,pr_dscritic => vr_dscritic);
    IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Efetua a inclusao de renda complementar
    pc_insere_rendimento_compl(pr_cdcooper => pr_cdcooper
                              ,pr_idpessoa => vr_idpessoa
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);
    IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Exclui todos os telefones que ja haviam sido cadastrados, atraves de outros meios
    BEGIN
      DELETE tbcadast_pessoa_telefone
       WHERE idpessoa = vr_idpessoa;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro exclusao geral telefone: '||SQLERRM;
        RAISE vr_exc_erro;
    END;

    -- Efetua a inclusao de telefone
    pc_insere_telefone(pr_cdcooper => pr_cdcooper
                      ,pr_idpessoa => vr_idpessoa
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_idseqttl => pr_idseqttl
                      ,pr_cdoperad => pr_cdoperad
                      ,pr_cdcritic => vr_cdcritic
                      ,pr_dscritic => vr_dscritic);
    IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    

    -- Exclui todos os enderecos que ja haviam sido cadastrados, atraves de outros meios
    BEGIN
      DELETE tbcadast_pessoa_endereco
       WHERE idpessoa = vr_idpessoa;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro exclusao geral endereco: '||SQLERRM;
        RAISE vr_exc_erro;
    END;

    -- Efetua a inclusao de endereco
    pc_insere_endereco(pr_cdcooper => pr_cdcooper
                      ,pr_idpessoa => vr_idpessoa
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_idseqttl => pr_idseqttl
                      ,pr_cdoperad => pr_cdoperad
                      ,pr_cdcritic => vr_cdcritic
                      ,pr_dscritic => vr_dscritic);
    IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_insere_pessoa_crapass: ' ||SQLERRM;
  END;  
  
  /*****************************************************************************/
  /**            Procedure para execucao do processo                          **/
  /*****************************************************************************/
  PROCEDURE pc_executa_processo(pr_nrdconta  IN crapass.nrdconta%TYPE -- Conta de inicio do restart
                               ,pr_cdcritic OUT INTEGER           -- Codigo de erro
                               ,pr_dscritic OUT VARCHAR2) IS      -- Retorno de Erro

    -- Cursor sobre as contas
    CURSOR cr_crapass IS
      SELECT cdcooper,
             nrdconta,
             idseqttl
       FROM (SELECT a.cdcooper,
                    a.nrdconta,
                    a.idseqttl,
                    a.nrcpfcgc
               FROM crapttl a
              WHERE nrdconta >= nvl(pr_nrdconta,0)
             UNION ALL
             SELECT cdcooper,
                    nrdconta,
                    1,
                    a.nrcpfcgc
               FROM crapass a
              WHERE inpessoa <> 1
                AND nrdconta >= nvl(pr_nrdconta,0)
                /* As contas abaixo foram incluidas porque eh um cadastro inativo e
                   esta incluida como PJ. Ja existe uma PF ativa com o mesmo CPF */
                AND NOT (cdcooper = 1 AND nrdconta IN (7282931,7461984))) x
   WHERE cdcooper NOT IN (4,15,17)
     ORDER BY nrdconta;
     
    -- Cursor sobre os procuradores e fiadores
    CURSOR cr_crapavt IS
      SELECT a.rowid,
             a.nrcpfcgc
        FROM crapass b,
             crapavt a
       WHERE a.tpctrato IN (1, 6) -- For fiador externo ou procurador
         AND a.cdcooper NOT IN (4,15,17)
--         AND a.nrcpfcgc = 42072280982
         AND a.nrcpfcgc > 0 -- Tiver CPF / CNPJ informado
         AND a.nrdctato = 0 -- Nao tiver conta informada
         AND b.cdcooper = a.cdcooper
         AND b.nrdconta = a.nrdconta
--         AND a.cdcooper = 20 -- Andrino
         AND ((a.tpctrato = 6
         AND   a.inpessoa <> 1 
         AND   a.dsproftl = 'PROCURADOR')
         OR   (a.tpctrato = 6
         AND   a.inpessoa = 1)
         OR   a.tpctrato = 1)
         AND NOT EXISTS (SELECT 1
                           FROM tbcadast_pessoa x
                          WHERE x.nrcpfcgc = a.nrcpfcgc);

    -- Tipo de registro de controle de execucao de CPF de procuradores e avalistas
    TYPE typ_execucao_pessoa IS
      TABLE OF BOOLEAN
      INDEX BY VARCHAR2(15);
    vr_execucao_pessoa typ_execucao_pessoa;

    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
    
    -- Variaveis gerais
    vr_ult_processo VARCHAR2(30);
    vr_contador NUMBER(10) := 0;
  BEGIN
    
    -- Loop sobre as conta
    FOR rw_crapass IN cr_crapass LOOP
      -- Atualiza a variavel de conta, caso ocorra erro
      vr_ult_processo := 'Conta: '||rw_crapass.nrdconta;
    
      IF rw_crapass.nrdconta = 78 THEN
        NULL;
      END IF;
      -- Incrementa o contador
      vr_contador := vr_contador + 1;
      
      -- Comitar a cada 5 mil registros
      IF MOD(vr_contador,5000) = 0 THEN
        COMMIT;
      END IF;

      -- Insere a pessoa
      pc_insere_pessoa_crapass(pr_cdcooper => rw_crapass.cdcooper,
                               pr_nrdconta => rw_crapass.nrdconta,
                               pr_idseqttl => rw_crapass.idseqttl,
                               pr_cdoperad => '1',
                               pr_cdcritic => vr_cdcritic,
                               pr_dscritic => vr_dscritic);
      -- Verifica se deu erro
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END LOOP;
    
    -- Loop sobre os procuradores e avalistas
    FOR rw_crapavt IN cr_crapavt LOOP
      vr_ult_processo := 'CPF: '||rw_crapavt.nrcpfcgc;
      -- Executar somente se o CPF nao tiver sido executado ainda
      IF NOT vr_execucao_pessoa.exists(lpad(rw_crapavt.nrcpfcgc,15,'0')) THEN

        -- Incrementa o contador
        vr_contador := vr_contador + 1;
        
        -- Comitar a cada 5 mil registros
        IF MOD(vr_contador,5000) = 0 THEN
          COMMIT;
        END IF;

        -- Insere o procurador ou avalista
        pc_insere_procurador_avalista(pr_rowid    => rw_crapavt.rowid,
                                      pr_cdoperad => '1',
                                      pr_cdcritic => vr_cdcritic,
                                      pr_dscritic => vr_dscritic);
        -- Verifica se deu erro
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- Coloca o CPF como ja executado
        vr_execucao_pessoa(lpad(rw_crapavt.nrcpfcgc,15,'0')) := TRUE;
      END IF;
    END LOOP;
    
    -- Grava os dados
    COMMIT;
    
    -- Atualiza as rotinas do Ayllos de acordo com o cadastrado na tabela de pessoa
    pc_atualiza_ayllos(pr_dscritic => vr_dscritic);
    -- Verifica se deu erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Grava os dados
    COMMIT;

    -- Atualiza o tipo de cadastro
    pc_atualiza_tipo_cadastro(pr_dscritic => vr_dscritic);
    -- Verifica se deu erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_ult_processo || '. '|| vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := vr_ult_processo || '. Erro não tratado na pc_insere_pessoa_crapass: ' ||SQLERRM;
  END;
  
  -- Rotina para atualizar as tabelas do Ayllos com base no cadastro de pessoa
  PROCEDURE pc_atualiza_ayllos(pr_dscritic OUT VARCHAR2) IS      -- Retorno de Erro

    TYPE typ_tab_rowid IS TABLE OF ROWID
         INDEX BY PLS_INTEGER;
         
    -- Tipo de registro
    TYPE typ_reg_pessoa IS
        RECORD (rowid_crapttl  typ_tab_rowid,
                rowid_crapepa  typ_tab_rowid,
                rowid_politico typ_tab_rowid);
    /* Definicao de tabela que compreende os registros acima declarados */
    TYPE typ_tab_pessoa IS
      TABLE OF typ_reg_pessoa
      INDEX BY VARCHAR2(15);
    /* Vetor com as informacoes das contas*/
    vr_pessoa typ_tab_pessoa;


    -- Cursor para buscar todas as pessoas que possuem CPF / CNPJ
    CURSOR cr_pessoa IS
      SELECT *
        FROM vwcadast_pessoa_juridica a
       WHERE a.nrcnpj IS NOT NULL;
    
    -- Busca as empresas de trabalho
    CURSOR cr_crapttl IS
     SELECT a.rowid,
            a.nrcpfemp
       FROM crapttl a
      WHERE nvl(a.nrcpfemp,0) > 0;
    
    -- Cursor para buscar todas as empresas que nao possuem CNPJ
    CURSOR cr_crapepa IS
      SELECT ROWID,
             a.nrdocsoc
        FROM crapepa a
       WHERE a.nrctasoc = 0;
       
    -- Cursor sobre o politico exposto
    CURSOR cr_politico IS
      SELECT ROWID,
             a.nrcnpj_empresa
        FROM tbcadast_politico_exposto a
       WHERE nvl(a.nrcnpj_empresa,0) > 0;

    -- Tratamento de erros
    vr_dscritic crapcri.dscritic%TYPE;
    vr_exc_erro EXCEPTION;
    vr_cont     NUMBER;

  BEGIN
    FOR rw_crapttl IN cr_crapttl LOOP
      IF vr_pessoa.exists(rw_crapttl.nrcpfemp) THEN
        vr_cont := vr_pessoa(rw_crapttl.nrcpfemp).rowid_crapttl.count() + 1;
      ELSE
        vr_cont := 1;
      END IF;
    
      vr_pessoa(rw_crapttl.nrcpfemp).rowid_crapttl(vr_cont):= rw_crapttl.rowid;
    END LOOP;
    
    FOR rw_crapepa IN cr_crapepa LOOP
      IF vr_pessoa.exists(rw_crapepa.nrdocsoc) THEN
        vr_cont := vr_pessoa(rw_crapepa.nrdocsoc).rowid_crapepa.count() + 1;
      ELSE
        vr_cont := 1;
      END IF;
      vr_pessoa(rw_crapepa.nrdocsoc).rowid_crapepa(vr_cont) := rw_crapepa.rowid;
    END LOOP;

    FOR rw_politico IN cr_politico LOOP  
    
      IF vr_pessoa.exists(rw_politico.nrcnpj_empresa) THEN
        vr_cont := vr_pessoa(rw_politico.nrcnpj_empresa).rowid_politico.count() + 1;
      ELSE
        vr_cont := 1;
      END IF;
      vr_pessoa(rw_politico.nrcnpj_empresa).rowid_politico(vr_cont) := rw_politico.rowid;
    END LOOP;
    
    FOR rw_pessoa IN cr_pessoa LOOP   
      -- Verifica se existe o cadastro de pessoa
      IF vr_pessoa.exists(rw_pessoa.nrcnpj) THEN
      
        -- Se existe empresa de trabalho
        IF vr_pessoa(rw_pessoa.nrcnpj).rowid_crapttl.count > 0 THEN
          FOR idx IN vr_pessoa(rw_pessoa.nrcnpj).rowid_crapttl.first..vr_pessoa(rw_pessoa.nrcnpj).rowid_crapttl.last LOOP
        
            -- Atualiza o nome da empresa
            BEGIN
              UPDATE crapttl
                 SET nmextemp = substr(rw_pessoa.nmpessoa,1,40)
               WHERE ROWID = vr_pessoa(rw_pessoa.nrcnpj).rowid_crapttl(idx);
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar CRAPTTL: '||SQLERRM;
                RAISE vr_exc_erro;
            END;
          END LOOP;
        END IF;

        -- Se existe empresa de participacao
        IF vr_pessoa(rw_pessoa.nrcnpj).rowid_crapepa.count > 0 THEN
        
          FOR idx IN vr_pessoa(rw_pessoa.nrcnpj).rowid_crapepa.first..vr_pessoa(rw_pessoa.nrcnpj).rowid_crapepa.last LOOP
             
            -- Atualiza o nome da empresa
            BEGIN
              UPDATE crapepa a
                 SET nmfansia = nvl(rw_pessoa.nmfantasia          ,nmfansia),
                     nrinsest = nvl(rw_pessoa.nrinscricao_estadual,nrinsest),
                     natjurid = nvl(rw_pessoa.cdnatureza_juridica ,natjurid),
                     dtiniatv = nvl(rw_pessoa.dtinicio_atividade  ,dtiniatv),
                     qtfilial = nvl(rw_pessoa.qtfilial            ,qtfilial),
                     qtfuncio = nvl(rw_pessoa.qtfuncionario       ,qtfuncio),
                     dsendweb = nvl(rw_pessoa.dssite              ,dsendweb),
                     cdseteco = nvl(rw_pessoa.cdsetor_economico   ,cdseteco),
                     cdrmativ = nvl(rw_pessoa.cdramo_atividade    ,cdrmativ),
                     nmprimtl = substr(nvl(rw_pessoa.nmpessoa            ,nmprimtl),1,40)
               WHERE ROWID = vr_pessoa(rw_pessoa.nrcnpj).rowid_crapepa(idx)
                 AND nrctasoc = 0;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar CRAPEPA: '||SQLERRM;
                RAISE vr_exc_erro;
            END;
          END LOOP;
        END IF;

        -- Se existe empresa do politico exposto
        IF vr_pessoa(rw_pessoa.nrcnpj).rowid_politico.count > 0 THEN
          
          FOR idx IN vr_pessoa(rw_pessoa.nrcnpj).rowid_politico.first..vr_pessoa(rw_pessoa.nrcnpj).rowid_politico.last LOOP
            
            -- Atualiza o nome da empresa do politico exposto
            BEGIN
              UPDATE tbcadast_politico_exposto a
                 SET a.nmempresa = substr(rw_pessoa.nmpessoa,1,35)
               WHERE ROWID = vr_pessoa(rw_pessoa.nrcnpj).rowid_politico(idx);
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar TBCADAST_POLITICO_EXPOSTO: '||SQLERRM;
                RAISE vr_exc_erro;
            END;
          END LOOP;
        END IF;
        

      END IF;
    
    END LOOP;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_atualiza_ayllos: ' ||SQLERRM;
  END;
    
  -- Rotina para atualizar o indicador de tipo de cadastro
  PROCEDURE pc_atualiza_tipo_cadastro(pr_dscritic OUT VARCHAR2) IS      -- Retorno de Erro
    -- Cursor sobre os PJ com rendimento superior a 360000
    CURSOR cr_pj_completo IS
      SELECT a.idpessoa
        FROM tbcadast_pessoa b,
             tbcadast_pessoa_juridica a
       WHERE nvl(a.vlfaturamento_anual,0) > 360000
         AND b.idpessoa = a.idpessoa
         AND b.tpcadastro = 3; -- Intermediario

    -- Cursor para atualizar os responsaveis legais como BASICO
    CURSOR cr_resp_legal IS    
      SELECT b.idpessoa
        FROM tbcadast_pessoa b,
             tbcadast_pessoa_fisica_resp a
       WHERE b.idpessoa = a.idpessoa_resp_legal
         and b.tpcadastro = 1; -- Prospect
         
    -- Cursor para atualizar os representantes legais como BASICO
    CURSOR cr_representante IS
      SELECT b.idpessoa
        FROM tbcadast_pessoa b,
             tbcadast_pessoa_juridica_rep a
       WHERE b.idpessoa = a.idpessoa_representante
         and b.tpcadastro = 1; -- Prospect
         
    -- Tratamento de erros
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;

  BEGIN
    -- Loop sobre os PJ com cadastro intermediario que devem ser alterados para completo
    FOR rw_pj_completo IN cr_pj_completo LOOP
      BEGIN
        UPDATE tbcadast_pessoa
           SET tpcadastro = 4 -- completo
          WHERE idpessoa = rw_pj_completo.idpessoa;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar TBCADAST_PESSOA: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
    END LOOP;

    -- Loop sobre os responsaveis legais com cadastro prospect que devem ser alterados para basico
    FOR rw_resp_legal IN cr_resp_legal LOOP
      BEGIN
        UPDATE tbcadast_pessoa
           SET tpcadastro = 2 -- Basico
          WHERE idpessoa = rw_resp_legal.idpessoa;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar TBCADAST_PESSOA-2: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
    END LOOP;

    -- Loop sobre os representantes com cadastro prospect que devem ser alterados para basico
    FOR rw_representante IN cr_representante LOOP
      BEGIN
        UPDATE tbcadast_pessoa
           SET tpcadastro = 2 -- Basico
          WHERE idpessoa = rw_representante.idpessoa;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar TBCADAST_PESSOA-3: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
    END LOOP;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_atualiza_tipo_cadastro: ' ||SQLERRM;    
  END;

END CADA0011;
/
