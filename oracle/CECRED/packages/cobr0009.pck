CREATE OR REPLACE PACKAGE CECRED.COBR0009 IS

  PROCEDURE pc_busca_config_nome_blt(pr_cdcooper IN crapass.cdcooper%TYPE -- Cód. cooperativa
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE -- nr da conta
                                    ,pr_clobxmlc OUT CLOB                 -- XML com informações     
                                    ,pr_des_erro OUT VARCHAR2             -- Indicador erro OK/NOK
                                    ,pr_dscritic OUT VARCHAR2);           -- Descrição da crítica  IS
                                    
  PROCEDURE pc_grava_config_nome_blt(pr_cdcooper       IN crapass.cdcooper%TYPE                      -- Cód. cooperativa
                                    ,pr_nrdconta       IN crapass.nrdconta%TYPE                      -- nr da conta
																		,pr_tpnome_emissao IN tbcobran_config_boleto.tpnome_emissao%TYPE -- Nome na Emissao do Boleto (1-Nome Razao/ 2-Nome Fantasia)
                                    ,pr_des_erro       OUT VARCHAR2                                  -- Indicador erro OK/NOK
																 	  ,pr_dscritic       OUT VARCHAR2);    

  PROCEDURE pc_busca_nome_imp_blt(pr_cdcooper IN crapass.cdcooper%TYPE -- Cód. cooperativa
                                 ,pr_nrdconta IN crapass.nrdconta%TYPE -- Nr da conta
                                 ,pr_idseqttl IN crapttl.idseqttl%TYPE -- Seq do Titular
                                 ,pr_nmprimtl OUT VARCHAR2             -- Nome do cooperado será impresso no boleto
                                 ,pr_des_erro OUT VARCHAR2             -- Indicador erro OK/NOK
                                 ,pr_dscritic OUT VARCHAR2);           -- Descrição da crí
                                 
  PROCEDURE pc_busca_emails_pagador (pr_cdcooper  IN  tbcobran_email_pagador.cdcooper%TYPE
                                    ,pr_nrdconta  IN  tbcobran_email_pagador.nrdconta%TYPE                                    
                                    ,pr_nrinssac  IN  tbcobran_email_pagador.nrinssac%TYPE
                                    ,pr_dsdemail  OUT VARCHAR2
                                    ,pr_des_erro  OUT VARCHAR2
                                    ,pr_dscritic  OUT VARCHAR2);
                                    
  PROCEDURE pc_grava_email_pagador(pr_cdcooper   IN  tbcobran_email_pagador.cdcooper%TYPE
                                  ,pr_nrdconta  IN  tbcobran_email_pagador.nrdconta%TYPE                                    
                                  ,pr_nrinssac  IN  tbcobran_email_pagador.nrinssac%TYPE
                                  ,pr_dsdemail  IN  tbcobran_email_pagador.dsdemail%TYPE
                                  ,pr_des_erro  OUT VARCHAR2
                                  ,pr_dscritic  OUT VARCHAR2);
                                  
  PROCEDURE pc_atualiza_email_pagador(pr_cdcooper   IN  tbcobran_email_pagador.cdcooper%TYPE
                                     ,pr_nrdconta   IN  tbcobran_email_pagador.nrdconta%TYPE                                    
                                     ,pr_nrinssac   IN  tbcobran_email_pagador.nrinssac%TYPE
                                     ,pr_dsdemail   IN VARCHAR2
                                     ,pr_des_erro  OUT VARCHAR2
                                     ,pr_dscritic  OUT VARCHAR2);                                                                   

END COBR0009;
/
CREATE OR REPLACE PACKAGE BODY CECRED.COBR0009 is
/*---------------------------------------------------------------------------------------------------------------
  
    Programa : COBR0009
    Sigla    : CRED
    Autor    : Kelvin Souza Ott
    Data     : Setembro/2016.                   Ultima atualizacao: 23/12/2016
  
   Dados referentes ao programa:
  
   Frequencia: -----
   Objetivo  : Englobar procedures referente configurações para emissão de boleto.
   
   Alteração : Ajuste realizado para melhorar o desempenho na busca da configuracao
               e na busca do nome do beneficiario, conforme solicitado no chamado 573538
               (Kelvin).
  ---------------------------------------------------------------------------------------------------------------*/
         
  PROCEDURE pc_busca_config_nome_blt(pr_cdcooper IN crapass.cdcooper%TYPE -- Cód. cooperativa
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE -- nr da conta
                                    ,pr_clobxmlc OUT CLOB                 -- XML com informações     
                                    ,pr_des_erro OUT VARCHAR2             -- Indicador erro OK/NOK
																 	  ,pr_dscritic OUT VARCHAR2) IS         -- Descrição da crítica  
  /* ..........................................................................
	
	  Programa : pc_busca_config_nome_blt
	  Sistema  : Conta-Corrente - Cooperativa de Credito
	  Sigla    : CRED
	  Autor    : Kelvin Souza Ott 
	  Data     : Setembro/2016.                   Ultima atualizacao: --/--/----
	
	  Dados referentes ao programa:
	
	  Frequencia: Sempre que for chamado
	  Objetivo  : Procedure para buscar configuração da emissão do boleto
	
	  Alteração :
	
	...........................................................................*/
    
    --Busca o tipo de emissão configurada para o cooperado
    CURSOR cr_config(p_cdcooper IN crapass.cdcooper%TYPE     -- Cód. cooperativa
                    ,p_nrdconta IN crapass.nrdconta%TYPE) IS -- Nr da conta  
                    
      SELECT tpnome_emissao 
        FROM tbcobran_config_boleto cob
       WHERE cob.cdcooper = p_cdcooper
         AND cob.nrdconta = p_nrdconta;     
    rw_config cr_config%ROWTYPE;
    
    --Busca informações do associado 
    CURSOR cr_crapjur (p_cdcooper IN crapass.cdcooper%TYPE     -- Cód. cooperativa
                      ,p_nrdconta IN crapass.nrdconta%TYPE) IS -- Nr da conta  
      SELECT DECODE(TRIM(jur.nmfansia),NULL,1,2) tpfansia
            ,jur.nmfansia
        FROM crapjur jur
       WHERE jur.cdcooper = p_cdcooper
         AND jur.nrdconta = p_nrdconta;     
    rw_crapjur cr_crapjur%ROWTYPE;  
    
    --Variaveis
    vr_tpnome_emissao tbcobran_config_boleto.tpnome_emissao%TYPE;
    
    --Variaveis de erro
    vr_dscritic  VARCHAR2(1000);
    vr_exc_saida EXCEPTION;
    
    -- Variaveis de XML 
    vr_xml_temp VARCHAR2(32767);
    
  BEGIN
    --Inicializar variáveis
    vr_tpnome_emissao := NULL;  
      
    --Buscando informacao do associado
    OPEN cr_crapjur(pr_cdcooper
                   ,pr_nrdconta);
      FETCH cr_crapjur
       INTO rw_crapjur;
      
      IF cr_crapjur%NOTFOUND THEN
        CLOSE cr_crapjur;
        vr_dscritic := 'Cooperado não encontrado.';
        RAISE vr_exc_saida;
      END IF;
    CLOSE cr_crapjur;
    
    --Buscando as configurações do cooperado
    OPEN cr_config(pr_cdcooper
                  ,pr_nrdconta);
      FETCH cr_config
       INTO rw_config;
      
      --Caso não encontre, cria configuração com padrão "1"
      IF cr_config%NOTFOUND THEN
        BEGIN
          
          vr_tpnome_emissao := 1;  
         
          --Insere a configuração  
          INSERT INTO tbcobran_config_boleto
            (cdcooper
            ,nrdconta
            ,tpnome_emissao)
          VALUES
            (pr_cdcooper
            ,pr_nrdconta
            ,1);--Nome Razao
         
         CLOSE cr_config;
         
        EXCEPTION
          WHEN OTHERS THEN
            CLOSE cr_config;
            vr_dscritic := 'Erro ao inserir na tabela tbcobran_config_boleto: ' || SQLERRM; 
            RAISE vr_exc_saida;
        END;
      ELSE
        vr_tpnome_emissao := rw_config.tpnome_emissao;    
      END IF;

    /*Caso esteja com configuração para Nome fantasia,
      porém o nome não esta cadastrado, seta para tipo 1*/
    IF vr_tpnome_emissao = 2 AND
       rw_crapjur.tpfansia = 1 /*Nome fantasia está vazio*/THEN
      BEGIN  
        
        vr_tpnome_emissao := 1;
      
        UPDATE tbcobran_config_boleto con
           SET con.tpnome_emissao = 1 
         WHERE con.cdcooper = pr_cdcooper
           AND con.nrdconta = pr_nrdconta;
          
      EXCEPTION
        WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar a tabela tbcobran_config_boleto: ' || SQLERRM;
        RAISE vr_exc_saida;     
      END;
    
    
    END IF;
    
    -- Criar documento XML
    dbms_lob.createtemporary(pr_clobxmlc, TRUE); 
    dbms_lob.open(pr_clobxmlc, dbms_lob.lob_readwrite);               
    
    -- Insere o cabeçalho do XML 
    gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                           ,pr_texto_completo => vr_xml_temp 
                           ,pr_texto_novo     => '<cabecalho>');
    
    gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                           ,pr_texto_completo => vr_xml_temp 
                           ,pr_texto_novo     => '<tpnome_emissao>' || vr_tpnome_emissao || '</tpnome_emissao>');
                           
    gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                           ,pr_texto_completo => vr_xml_temp 
                           ,pr_texto_novo     => '<tpfansia>' || rw_crapjur.tpfansia || '</tpfansia>');
    
    gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                           ,pr_texto_completo => vr_xml_temp 
                           ,pr_texto_novo     => '<nmfansia>' || rw_crapjur.nmfansia || '</nmfansia>');
    
    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                           ,pr_texto_completo => vr_xml_temp 
                           ,pr_texto_novo     => '</cabecalho>' 
                           ,pr_fecha_xml      => TRUE);
    
    --Se tudo deu certo retorna OK  
    pr_des_erro := 'OK';
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_des_erro := 'NOK';
      pr_dscritic := vr_dscritic;      

    WHEN OTHERS THEN
      pr_des_erro := 'NOK';
      pr_dscritic := 'Erro nao tratado na procedure COBR0009.pc_busca_config_nome_blt: ' || SQLERRM;
    
  END pc_busca_config_nome_blt;

  
  /* ..........................................................................
	
	  Programa : pc_grava_config_nome_blt
	  Sistema  : Conta-Corrente - Cooperativa de Credito
	  Sigla    : CRED
	  Autor    : Kelvin Souza Ott 
	  Data     : Setembro/2016.                   Ultima atualizacao: --/--/----
	
	  Dados referentes ao programa:
	
	  Frequencia: Sempre que for chamado
	  Objetivo  : Procedure para gravar a configuração da emissão do boleto
	
	  Alteração :
	
	...........................................................................*/
  
  PROCEDURE pc_grava_config_nome_blt(pr_cdcooper       IN crapass.cdcooper%TYPE                      -- Cód. cooperativa
                                    ,pr_nrdconta       IN crapass.nrdconta%TYPE                      -- nr da conta
																		,pr_tpnome_emissao IN tbcobran_config_boleto.tpnome_emissao%TYPE -- Nome na Emissao do Boleto (1-Nome Razao/ 2-Nome Fantasia)
                                    ,pr_des_erro       OUT VARCHAR2                                  -- Indicador erro OK/NOK
																 	  ,pr_dscritic       OUT VARCHAR2) IS                              -- Descrição da crítica  
    --Busca o tipo de emissão configurada para o cooperado
    CURSOR cr_config(p_cdcooper IN crapass.cdcooper%TYPE     -- Cód. cooperativa
                    ,p_nrdconta IN crapass.nrdconta%TYPE) IS -- Nr da conta  
                    
      SELECT tpnome_emissao 
        FROM tbcobran_config_boleto cob
       WHERE cob.cdcooper = p_cdcooper
         AND cob.nrdconta = p_nrdconta;     
         
    rw_config cr_config%ROWTYPE;                                
    
    --Busca informações da cooperativa
    CURSOR cr_crapcop (p_cdcooper IN crapcop.cdcooper%TYPE) IS -- Cód. cooperativa
      SELECT cop.cdcooper
            ,cop.nmextcop
        FROM crapcop cop
       WHERE cop.cdcooper = p_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    
    --Busca informações do associado 
    CURSOR cr_crapass (p_cdcooper IN crapass.cdcooper%TYPE     -- Cód. cooperativa
                      ,p_nrdconta IN crapass.nrdconta%TYPE) IS -- Nr da conta  
      SELECT ass.cdcooper
            ,ass.nrdconta
            ,ass.nmprimtl
        FROM crapass ass
       WHERE ass.cdcooper = p_cdcooper
         AND ass.nrdconta = p_nrdconta;     
    rw_crapass cr_crapass%ROWTYPE;  
    
    --Variaveis de erro
    vr_dscritic  VARCHAR2(1000);
    vr_exc_saida EXCEPTION; 
  
  BEGIN            
    --Validando se a cooperativa existe
    OPEN cr_crapcop(pr_cdcooper);
      FETCH cr_crapcop
       INTO rw_crapcop;
      
      IF cr_crapcop%NOTFOUND THEN
        CLOSE cr_crapcop;
        vr_dscritic := 'Cooperativa não encontrada.';
        RAISE vr_exc_saida;
      END IF;
    CLOSE cr_crapcop;  
    
    --Validando se o cooperado existe
    OPEN cr_crapass(pr_cdcooper
                   ,pr_nrdconta);
      FETCH cr_crapass
       INTO rw_crapass;
      
      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;
        vr_dscritic := 'Cooperado não encontrado.';
        RAISE vr_exc_saida;
      END IF;
    CLOSE cr_crapass;
    
    --Buscando as configurações do cooperado
    OPEN cr_config(pr_cdcooper
                  ,pr_nrdconta);
      FETCH cr_config
       INTO rw_config;
      
      IF cr_config%NOTFOUND THEN        
        BEGIN 
          --Insere a configuração  
          INSERT INTO tbcobran_config_boleto
            (cdcooper
            ,nrdconta
            ,tpnome_emissao)
          VALUES
            (pr_cdcooper
            ,pr_nrdconta
            ,pr_tpnome_emissao);

         CLOSE cr_config;
         
        EXCEPTION
          WHEN OTHERS THEN
            CLOSE cr_config;
            vr_dscritic := 'Erro ao inserir na tabela tbcobran_config_boleto: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
      ELSE
        
        BEGIN  
          --Caso já exista configuração, apenas faz update
          UPDATE tbcobran_config_boleto con
             SET con.tpnome_emissao = pr_tpnome_emissao
           WHERE con.cdcooper = pr_cdcooper
             AND con.nrdconta = pr_nrdconta;
          
          CLOSE cr_config;
          
        EXCEPTION
          WHEN OTHERS THEN
            CLOSE cr_config;
            vr_dscritic := 'Erro ao atualizar a tabela tbcobran_config_boleto: ' || SQLERRM;
            RAISE vr_exc_saida;     
        END;
           
      END IF;
    --Se tudo deu certo retorna OK  
    pr_des_erro := 'OK';
   
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_des_erro := 'NOK';
      pr_dscritic := vr_dscritic;      
      
    WHEN OTHERS THEN
      pr_des_erro := 'NOK';
      pr_dscritic := 'Erro nao tratado na procedure COBR0009.pc_grava_config_nome_blt: ' || SQLERRM;
      
  END pc_grava_config_nome_blt;
  
  /* ..........................................................................
	
	  Programa : pc_busca_nome_imp_blt
	  Sistema  : Conta-Corrente - Cooperativa de Credito
	  Sigla    : CRED
	  Autor    : Kelvin Souza Ott 
	  Data     : Setembro/2016.                   Ultima atualizacao: 26/01/2017
	
	  Dados referentes ao programa:
	
	  Frequencia: Sempre que for chamado
	  Objetivo  : Procedure para busca o nome que irá aparecer no boleto/carnê
	
	  Alteração : 26/01/2017 - Ajustar where do cursor que carrega o nome, deve ser na tabela 
                               crapass, ao inves de crapjur (Douglas - Chamado 601478)
	
                  30/03/2017 - Adicionado parametro pr_idseqttl, para buscar o nome do 
                               titular, para imprimir como beneficiário do boleto
                               (Douglas - Chamado 637660)
	...........................................................................*/
  
  PROCEDURE pc_busca_nome_imp_blt(pr_cdcooper       IN crapass.cdcooper%TYPE   -- Cód. cooperativa
                                 ,pr_nrdconta       IN crapass.nrdconta%TYPE   -- Nr da conta
                                 ,pr_idseqttl       IN crapttl.idseqttl%TYPE   -- Seq do Titular
                                 ,pr_nmprimtl       OUT VARCHAR2               -- XML com informações     
                                 ,pr_des_erro       OUT VARCHAR2               -- Indicador erro OK/NOK
                                 ,pr_dscritic       OUT VARCHAR2) IS           -- Descrição da crítica  
  
    CURSOR cr_config(p_cdcooper IN tbcobran_config_boleto.cdcooper%TYPE     -- Cód. cooperativa
                    ,p_nrdconta IN tbcobran_config_boleto.nrdconta%TYPE) IS
      SELECT con.tpnome_emissao
        FROM tbcobran_config_boleto con
       WHERE con.cdcooper = p_cdcooper
         AND con.nrdconta = p_nrdconta;
    rw_config cr_config%ROWTYPE;
  
    CURSOR cr_nome_benef(p_cdcooper IN crapass.cdcooper%TYPE     -- Cód. cooperativa
                        ,p_nrdconta IN crapass.nrdconta%TYPE) IS -- Nr da conta        
      SELECT ass.nmprimtl
            ,ass.inpessoa
            ,jur.nmfansia
            ,jur.nmextttl
        FROM crapass ass 
        LEFT JOIN crapjur jur
          ON jur.cdcooper = ass.cdcooper
         AND jur.nrdconta = ass.nrdconta
       WHERE ass.cdcooper = p_cdcooper
         AND ass.nrdconta = p_nrdconta ;
    rw_nome_benef cr_nome_benef%ROWTYPE;

    CURSOR cr_nome_titular(p_cdcooper IN crapttl.cdcooper%TYPE     -- Cód. cooperativa
                          ,p_nrdconta IN crapttl.nrdconta%TYPE     -- Nr da conta 
                          ,p_idseqttl IN crapttl.idseqttl%TYPE) IS -- Seq. Titular da Conta
      SELECT ttl.nmextttl
        FROM crapttl ttl 
       WHERE ttl.cdcooper = p_cdcooper
         AND ttl.nrdconta = p_nrdconta
         AND ttl.idseqttl = p_idseqttl;
    rw_nome_titular cr_nome_titular%ROWTYPE;
    
    --Variaveis de erro
    vr_dscritic  VARCHAR2(1000);
    vr_exc_saida EXCEPTION; 
    
    --Variaveis
    vr_nmvistit VARCHAR(150);
    vr_tpnome_emissao tbcobran_config_boleto.tpnome_emissao%TYPE;
    
  BEGIN
    --Inicializando variaveis
    vr_tpnome_emissao := NULL;
    vr_nmvistit := NULL;
    vr_dscritic := NULL;
                
    --Buscando as configurações do cooperado
    OPEN cr_config(pr_cdcooper
                  ,pr_nrdconta);
      FETCH cr_config
       INTO rw_config;
      
      --Caso não encontre, cria configuração com padrão "1"
      IF cr_config%NOTFOUND THEN
        BEGIN
          
          vr_tpnome_emissao := 1;  
         
          --Insere a configuração  
          INSERT INTO tbcobran_config_boleto
            (cdcooper
            ,nrdconta
            ,tpnome_emissao)
          VALUES
            (pr_cdcooper
            ,pr_nrdconta
            ,1);--Nome Razao
         
         CLOSE cr_config;
         
        EXCEPTION
          WHEN OTHERS THEN
            CLOSE cr_config;
            vr_dscritic := 'Erro ao inserir na tabela tbcobran_config_boleto: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
      ELSE
        vr_tpnome_emissao := rw_config.tpnome_emissao;    
      END IF;
      
      OPEN cr_nome_benef(pr_cdcooper
                        ,pr_nrdconta);
        FETCH cr_nome_benef
         INTO rw_nome_benef;
      CLOSE cr_nome_benef;
    
      --Pessoa física
      IF rw_nome_benef.inpessoa = 1 THEN
        -- Quando o boleto é de pessoa física, buscar o nome do titular que gerou o boleto
        OPEN cr_nome_titular(p_cdcooper => pr_cdcooper
                            ,p_nrdconta => pr_nrdconta
                            ,p_idseqttl => pr_idseqttl);
        FETCH cr_nome_titular INTO rw_nome_titular;
        -- Verificar se encontrou o titular
        IF cr_nome_titular%FOUND THEN
          -- Retornar o nome do titular da conta de acordo com a Seq do Titular
          vr_nmvistit := rw_nome_titular.nmextttl;
        ELSE 
          -- Se não encontrou, retorna o nome do titular da conta da ASS
          vr_nmvistit := rw_nome_benef.nmprimtl;
        END IF;
        
        CLOSE cr_nome_titular;
      --Pessoa juridica
      ELSE
        --Nome razao social
        IF vr_tpnome_emissao = 1 THEN
          vr_nmvistit := rw_nome_benef.nmextttl;
        --Nome fantasia
        ELSE
          vr_nmvistit := rw_nome_benef.nmfansia;
        END IF;
      END IF;

    --Se esta configurado para nome fantasia mas o mesmo nao esta cadastrado
    IF TRIM(vr_nmvistit) IS NULL AND      
      vr_tpnome_emissao = 2 THEN --Nome fantasia
       
      BEGIN  
        
        vr_tpnome_emissao := 1;
               
        UPDATE tbcobran_config_boleto con
           SET con.tpnome_emissao = 1 
         WHERE con.cdcooper = pr_cdcooper
           AND con.nrdconta = pr_nrdconta;
          
      EXCEPTION
        WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar a tabela tbcobran_config_boleto: ' || SQLERRM; 
        RAISE vr_exc_saida;     
      END; 
       
      vr_nmvistit := rw_nome_benef.nmextttl;
      
    END IF;
                          
    pr_nmprimtl := vr_nmvistit;
    
    pr_des_erro := 'OK';
    
 EXCEPTION
   WHEN vr_exc_saida THEN
     pr_des_erro := 'NOK';
     pr_dscritic := vr_dscritic;

   WHEN OTHERS THEN
     pr_des_erro := 'NOK';
     pr_dscritic := 'Erro nao tratado na procedure COBR0009.pc_grava_config_nome_blt: ' || SQLERRM;
                            
  END pc_busca_nome_imp_blt;    
  
  /* ..........................................................................
	
	  Programa : pc_busca_emails_pagador
	  Sistema  : Conta-Corrente - Cooperativa de Credito
	  Sigla    : CRED
	  Autor    : Kelvin Souza Ott 
	  Data     : Outubro/2016.                   Ultima atualizacao: --/--/----
	
	  Dados referentes ao programa:
	
	  Frequencia: Sempre que for chamado
	  Objetivo  : Procedure para retornar os e-mails dos pagadores
	
	  Alteração :
	
	...........................................................................*/
 
  PROCEDURE pc_busca_emails_pagador (pr_cdcooper  IN  tbcobran_email_pagador.cdcooper%TYPE
                                    ,pr_nrdconta  IN  tbcobran_email_pagador.nrdconta%TYPE                                    
                                    ,pr_nrinssac  IN  tbcobran_email_pagador.nrinssac%TYPE
                                    ,pr_dsdemail  OUT VARCHAR2
                                    ,pr_des_erro  OUT VARCHAR2
                                    ,pr_dscritic  OUT VARCHAR2) IS
  
    CURSOR cr_tbcobran_email_pagador(p_cdcooper IN tbcobran_email_pagador.cdcooper%TYPE
                                    ,p_nrdconta IN tbcobran_email_pagador.nrdconta%TYPE
                                    ,p_nrinssac IN tbcobran_email_pagador.nrinssac%TYPE) IS    
      SELECT ema.cdcooper
            ,ema.nrdconta
            ,ema.nrinssac
            ,ema.idemail
            ,ema.dsdemail
        FROM tbcobran_email_pagador ema
       WHERE ema.cdcooper = p_cdcooper
         AND ema.nrdconta = p_nrdconta
         AND ema.nrinssac = p_nrinssac;

    --Variaveis
    vr_dsdemail VARCHAR2(5000); 
    
  BEGIN
    
    --Busca emails do pagador
    FOR rw_tbcobran_email_pagador IN cr_tbcobran_email_pagador(pr_cdcooper
                                                              ,pr_nrdconta
	                                                            ,pr_nrinssac) LOOP  
      --Validação para variável de e-mail não estourar
      IF LENGTH(vr_dsdemail || ';' || rw_tbcobran_email_pagador.dsdemail) <= 5000 THEN
        --Concatena as informações do pagador com ponto e virgula ";"
        IF TRIM(vr_dsdemail) IS NULL THEN
          vr_dsdemail := rw_tbcobran_email_pagador.dsdemail;
        ELSE
          vr_dsdemail := vr_dsdemail || ';' || rw_tbcobran_email_pagador.dsdemail;
        END IF;
      END IF;    
    END LOOP;    
    
    --Retorna os e-mail concatenados
    pr_dsdemail := vr_dsdemail;
    
    --Retorna OK para a procedure
    pr_des_erro := 'OK';
    
  EXCEPTION   
     WHEN OTHERS THEN       
       pr_des_erro := 'NOK';
       
       pr_dscritic := 'Erro nao tratado na procedure COBR0009.pc_busca_emails_pagador: ' || SQLERRM;
       
       --Caso de erro, retorna emails vazio
       pr_dsdemail := '';

       btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                 ,pr_ind_tipo_log => 2 
                                 ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                 ,pr_des_log      => to_char(SYSDATE,
                                                    'hh24:mi:ss') ||
                                                    ' - ' || 'COBR0009' ||
                                                    ' --> ' || pr_dscritic);
    
  END pc_busca_emails_pagador;
  
  /* ..........................................................................
	
	  Programa : pc_insere_email_pagador
	  Sistema  : Conta-Corrente - Cooperativa de Credito
	  Sigla    : CRED
	  Autor    : Kelvin Souza Ott 
	  Data     : Outubro/2016.                   Ultima atualizacao: 07/04/2017
	
	  Dados referentes ao programa:
	
	  Frequencia: Sempre que for chamado
	  Objetivo  : Procedure para inserir emai-l do pagador
	
	  Alteração : 07/04/2017 - Remover os caracteres especiais e os espaços em 
                               branco do e-mail (Douglas - Chamado 638939)
	
	...........................................................................*/    
  PROCEDURE pc_grava_email_pagador(pr_cdcooper  IN  tbcobran_email_pagador.cdcooper%TYPE
                                  ,pr_nrdconta  IN  tbcobran_email_pagador.nrdconta%TYPE                                    
                                  ,pr_nrinssac  IN  tbcobran_email_pagador.nrinssac%TYPE
                                  ,pr_dsdemail  IN  tbcobran_email_pagador.dsdemail%TYPE
                                  ,pr_des_erro  OUT VARCHAR2
                                  ,pr_dscritic  OUT VARCHAR2) IS
    
    CURSOR cr_tbcobran_email_pagador(p_cdcooper IN tbcobran_email_pagador.cdcooper%TYPE
                                    ,p_nrdconta IN tbcobran_email_pagador.nrdconta%TYPE
                                    ,p_nrinssac IN tbcobran_email_pagador.nrinssac%TYPE
                                    ,p_dsdemail IN tbcobran_email_pagador.dsdemail%TYPE) IS    
      SELECT ema.cdcooper
            ,ema.nrdconta
            ,ema.nrinssac
            ,ema.idemail
            ,ema.dsdemail
        FROM tbcobran_email_pagador ema
       WHERE ema.cdcooper = p_cdcooper
         AND ema.nrdconta = p_nrdconta
         AND ema.nrinssac = p_nrinssac
         AND ema.dsdemail = p_dsdemail;
    rw_tbcobran_email_pagador cr_tbcobran_email_pagador%ROWTYPE;
      
    --Variaveis de erro
    vr_dscritic  VARCHAR2(1000);
    vr_exc_saida EXCEPTION;
    
    -- Email
    vr_dsdemail tbcobran_email_pagador.dsdemail%TYPE;
    
  BEGIN
    
    vr_dsdemail := pr_dsdemail;
    -- Remover os caracteres acentuados
    vr_dsdemail := GENE0007.fn_caract_acento(pr_texto    => vr_dsdemail
                                            ,pr_insubsti => 1
                                            ,pr_dssubsin => '#$&%¹²³ªº°*!?<>/\|'
                                            ,pr_dssubout => '                  ');
    -- Remover os espaços em branco
    vr_dsdemail := REPLACE (vr_dsdemail, ' ', NULL);

    OPEN cr_tbcobran_email_pagador(pr_cdcooper
                                  ,pr_nrdconta
                                  ,pr_nrinssac
                                  ,vr_dsdemail);
      FETCH cr_tbcobran_email_pagador 
       INTO rw_tbcobran_email_pagador;     
    
    --Verifica se o e-mail já existe
    IF cr_tbcobran_email_pagador%NOTFOUND THEN
      BEGIN
        IF gene0003.fn_valida_email(pr_dsdemail => vr_dsdemail) = 1 THEN
          --Se não existe insere
          INSERT INTO tbcobran_email_pagador
            (cdcooper
            ,nrdconta
            ,nrinssac
            ,idemail
            ,dsdemail)
          VALUES 
            (pr_cdcooper
            ,pr_nrdconta
            ,pr_nrinssac
            ,(SELECT NVL(MAX(pag.idemail),0) + 1 
                FROM tbcobran_email_pagador pag
               WHERE pag.cdcooper = pr_cdcooper
                 AND pag.nrdconta = pr_nrdconta
                 AND pag.nrinssac = pr_nrinssac) 
            ,pr_dsdemail);
        END IF;
        
      EXCEPTION
        WHEN OTHERS THEN
          CLOSE cr_tbcobran_email_pagador;
          vr_dscritic := 'Erro ao inserir na tabela tbcobran_email_pagador: ' || SQLERRM;
          RAISE vr_exc_saida;  
      END;
    
    END IF;

    pr_des_erro := 'OK';
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_des_erro := 'NOK';
      pr_dscritic := vr_dscritic;
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 
                                ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                ,pr_des_log      => to_char(SYSDATE,
                                                   'hh24:mi:ss') ||
                                                   ' - ' || 'COBR0009' ||
                                                   ' --> ' || pr_dscritic);                                       
                                                         
    WHEN OTHERS THEN     
      pr_des_erro := 'NOK';       
      pr_dscritic := 'Erro nao tratado na procedure COBR0009.pc_insere_email_pagador: ' || SQLERRM;
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 
                                ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                ,pr_des_log      => to_char(SYSDATE,
                                                   'hh24:mi:ss') ||
                                                   ' - ' || 'COBR0009' ||
                                                   ' --> ' || pr_dscritic); 
      
                                       
  END pc_grava_email_pagador;
  
  PROCEDURE pc_atualiza_email_pagador(pr_cdcooper  IN  tbcobran_email_pagador.cdcooper%TYPE
                                     ,pr_nrdconta  IN  tbcobran_email_pagador.nrdconta%TYPE                                    
                                     ,pr_nrinssac  IN  tbcobran_email_pagador.nrinssac%TYPE
                                     ,pr_dsdemail  IN VARCHAR2
                                     ,pr_des_erro  OUT VARCHAR2
                                     ,pr_dscritic  OUT VARCHAR2) IS
    --Passa a string de e-mails concatenadas por ponto e virgula e retorna
    --cada email em uma linha 
    CURSOR cr_dsdemail(p_dsdemail IN VARCHAR2) IS    
      SELECT DISTINCT regexp_substr(p_dsdemail, '[^;]+', 1, LEVEL) dsdemail
        FROM dual
      CONNECT BY LEVEL <= regexp_count(p_dsdemail, '[^;]+')
        ORDER BY dsdemail;
      
    --Variaveis de erro
    vr_dscritic  VARCHAR2(1000);    
    vr_exc_saida EXCEPTION;
    
    -- Email
    vr_dsdemail tbcobran_email_pagador.dsdemail%TYPE;
    
  BEGIN
    BEGIN
      --Se passou algum email
      IF TRIM(pr_dsdemail) IS NOT NULL THEN
        --Deleta todos e-mail desse cooperado
        DELETE 
          FROM tbcobran_email_pagador pag
         WHERE pag.cdcooper = pr_cdcooper
           AND pag.nrdconta = pr_nrdconta
           AND pag.nrinssac = pr_nrinssac;
        
        --Percorre os e-mails passados por ele  
        FOR rw_dsdemail IN cr_dsdemail(pr_dsdemail) LOOP          
          
          vr_dsdemail := rw_dsdemail.dsdemail;
          -- Remover os caracteres acentuados
          vr_dsdemail := GENE0007.fn_caract_acento(pr_texto    => vr_dsdemail
                                                  ,pr_insubsti => 1
                                                  ,pr_dssubsin => '#$&%¹²³ªº°*!?<>/\|'
                                                  ,pr_dssubout => '                  ');
          -- Remover os espaços em branco
          vr_dsdemail := REPLACE (vr_dsdemail, ' ', NULL);    
        
          IF gene0003.fn_valida_email(pr_dsdemail => vr_dsdemail) = 1 THEN
          
            --Insere cada e-mail passado separados por ponto e virgula
            INSERT INTO tbcobran_email_pagador
              (cdcooper
              ,nrdconta
              ,nrinssac
              ,idemail
              ,dsdemail)
            VALUES 
              (pr_cdcooper
              ,pr_nrdconta
              ,pr_nrinssac
              ,(SELECT NVL(MAX(pag.idemail),0) + 1 
                  FROM tbcobran_email_pagador pag
                 WHERE pag.cdcooper = pr_cdcooper
                   AND pag.nrdconta = pr_nrdconta
                   AND pag.nrinssac = pr_nrinssac) 
              ,vr_dsdemail);  
          END IF;
        END LOOP;
        
      ELSE
        --Caso não passou nada, deleta todos os emails
        DELETE 
          FROM tbcobran_email_pagador pag
         WHERE pag.cdcooper = pr_cdcooper
           AND pag.nrdconta = pr_nrdconta
           AND pag.nrinssac = pr_nrinssac;  
      END IF;
      
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar na tabela tbcobran_email_pagador: ' || SQLERRM; 
        RAISE vr_exc_saida;  
    END; 
    pr_des_erro := 'OK';
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_des_erro := 'NOK';
      pr_dscritic := vr_dscritic;
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 
                                ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                ,pr_des_log      => to_char(SYSDATE,
                                                   'hh24:mi:ss') ||
                                                   ' - ' || 'COBR0009' ||
                                                   ' --> ' || pr_dscritic);                                       
    WHEN OTHERS THEN
      pr_des_erro := 'NOK';       
      pr_dscritic := 'Erro nao tratado na procedure COBR0009.pc_insere_email_pagador: ' || SQLERRM;
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 
                                ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                ,pr_des_log      => to_char(SYSDATE,
                                                   'hh24:mi:ss') ||
                                                   ' - ' || 'COBR0009' ||
                                                   ' --> ' || pr_dscritic);                                  
  END pc_atualiza_email_pagador;  
  
END COBR0009;
/
