CREATE OR REPLACE PACKAGE CECRED.TELA_CADCNA AS

   /*
   Programa: TELA_CADCNA                          antigo:
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED

   Autor   : Adriano - CECRED
   Data    : Julho/2017                       Ultima atualizacao: 04/08/2017

   Dados referentes ao programa:

   Frequencia: Diario (on-line).
   Objetivo  : Mostrar a tela CADCNA para permitir o gerenciamento de CNAE

   Alteracoes: 04/08/2017 - Ajuste para inclusao do parametros flserasa (Adriano).

   */  
   
  --Busca CNAE cadastrado no sistema
  PROCEDURE pc_busca_cnae(pr_cdcnae IN tbgen_cnae.cdcnae%TYPE  --> Código do CNAE
                         ,pr_dscnae IN tbgen_cnae.dscnae%TYPE  --> Descrição do CNAE
                         ,pr_flserasa IN PLS_INTEGER DEFAULT 2  --> 0=Nao negativa, 1=Negativa, 2=Todos
                         ,pr_nriniseq IN INTEGER               -- Qunatidade inicial
                         ,pr_nrregist IN INTEGER               -- Quantidade de registros                            
                         ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                         ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                         ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                         ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                         ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                         ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
                                     
  --Inclui CNAE requerido pelo usuario
  PROCEDURE pc_incluir_cnae(pr_dscnae   IN tbgen_cnae.dscnae%TYPE --> Descrição do CNAE
                           ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
                                 
  --Exclui CNAE requerida pelo usuario
  PROCEDURE pc_excluir_cnae(pr_cdcnae IN tbgen_cnae.cdcnae%TYPE  --> Código do CNAE
                           ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
                                    
  --Altear CNAE requerido pelo usuario
  PROCEDURE pc_alterar_cnae(pr_cdcnae IN tbgen_cnae.cdcnae%TYPE  --> Código do CNAE
                           ,pr_dscnae IN tbgen_cnae.dscnae%TYPE  --> Descrição do CNAE
                           ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);           --> Erros do processo         
                           
  --Validar se CNAE está cadastrado                         
  PROCEDURE pc_valida_cnae(pr_cdcnae IN tbgen_cnae.cdcnae%TYPE  --> Código do CNAE
                          ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                          ,pr_dscritic OUT VARCHAR2);                                                    
                                                                                     
END TELA_CADCNA;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_CADCNA AS

/*---------------------------------------------------------------------------------------------------------------
   Programa: TELA_CADCNA                          antigo: 
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED

   Autor   : Adriano - CECRED
   Data    : Julho/2017                       Ultima atualizacao: 04/08/2017

   Dados referentes ao programa:

   Frequencia: Diario (on-line).
   Objetivo  : Mostrar a tela CADCNA para permitir o gerenciamento de CNAE

   Alteracoes: 04/08/2017 - Ajuste para inclusao do parametros flserasa (Adriano).
			              
  ---------------------------------------------------------------------------------------------------------------*/
  
  --Busca CNAE cadastrado no sistema
  PROCEDURE pc_busca_cnae(pr_cdcnae IN tbgen_cnae.cdcnae%TYPE  --> Código do CNAE
                         ,pr_dscnae IN tbgen_cnae.dscnae%TYPE  --> Descrição do CNAE
                         ,pr_flserasa IN PLS_INTEGER DEFAULT 2  --> 0=Nao negativa, 1=Negativa, 2=Todos
                         ,pr_nriniseq IN INTEGER               -- Qunatidade inicial
                         ,pr_nrregist IN INTEGER               -- Quantidade de registros                            
                         ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                         ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                         ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                         ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                         ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                         ,pr_des_erro OUT VARCHAR2)IS          --> Erros do processo
                         
  /* .............................................................................
   Programa: pc_busca_cnae
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Adriano - CECRED
   Data    : Julho/2017                        Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Rotina para buscar o CNAE

   Alteracoes: 
                
    ............................................................................. */                                    
    CURSOR cr_cnae (pr_cdcnae IN tbgen_cnae.cdcnae%TYPE
                   ,pr_dscnae IN tbgen_cnae.dscnae%TYPE) IS
    SELECT cnae.cdcnae
          ,gene0007.fn_caract_acento(dscnae) dscnae
      FROM tbgen_cnae cnae
     WHERE cdcnae = decode(nvl(pr_cdcnae,0),0,cdcnae, pr_cdcnae)
       AND (trim(pr_dscnae) IS NULL
        OR  UPPER(dscnae) LIKE '%'||UPPER(pr_dscnae)||'%')
       AND flserasa = decode(nvl(pr_flserasa,2),2,flserasa, pr_flserasa)
     ORDER BY cdcnae;
     
    -- Variaveis de log
    vr_cdcooper NUMBER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_auxconta PLS_INTEGER := 0;
    
    --Variaveis de erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;         
    vr_exc_saida EXCEPTION;
    
    --Variaveis de controle
    vr_nrregist INTEGER := nvl(pr_nrregist,9999);
    vr_qtregist INTEGER;
  
  BEGIN
    
    --Inicializar Variaveis
    vr_qtregist:= 0;
    
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CADCNA'
                              ,pr_action => null);
      
    -- Extrai os dados dos dados que vieram do php
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);  
                            
    -- Verifica se houve erro                      
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;                         
    
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    
    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Dados',pr_posicao => 0,pr_tag_nova => 'CNAE',pr_tag_cont => NULL,pr_des_erro => vr_dscritic); 
        
    --Loop para buscar registros de CNAE  
    FOR rw_cnae IN cr_cnae(pr_cdcnae => nvl(pr_cdcnae,0)
                          ,pr_dscnae => upper(pr_dscnae)) LOOP
      
      --Incrementar Quantidade Registros do Parametro
      vr_qtregist:= nvl(vr_qtregist,0) + 1;
    
      /* controles da paginacao */
      IF (vr_qtregist < pr_nriniseq) OR
         (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
         --Proximo Titular
        CONTINUE;
      END IF; 
          
      --Numero Registros
      IF vr_nrregist > 0 THEN 
      
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'CNAE',pr_posicao => 0,pr_tag_nova => 'inf',pr_tag_cont => NULL,pr_des_erro => vr_dscritic); 
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'inf',pr_posicao => vr_auxconta, pr_tag_nova => 'cdcnae', pr_tag_cont => rw_cnae.cdcnae, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'inf',pr_posicao => vr_auxconta, pr_tag_nova => 'dscnae', pr_tag_cont => rw_cnae.dscnae, pr_des_erro => vr_dscritic);
       
        -- Incrementa contador p/ posicao no XML
        vr_auxconta := nvl(vr_auxconta,0) + 1;  
              
      END IF;
        
      --Diminuir registros
      vr_nrregist:= nvl(vr_nrregist,0) - 1; 
      
    END LOOP;
    
    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'CNAE'              --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'          --> Nome do atributo
                             ,pr_atval => vr_qtregist         --> Valor do atributo
                             ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                               
    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
    
    pr_des_erro := 'OK';
  
  EXCEPTION
    WHEN vr_exc_saida THEN
      
      IF TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic:= GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); 
      END IF;
      
      pr_cdcritic := pr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
      
    WHEN OTHERS THEN
      
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral (TELA_CADCNA.pc_busca_cnae).';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
      
      ROLLBACK;   
  
  END pc_busca_cnae;

  --Inclui CNAE requerido pelo usuario
  PROCEDURE pc_incluir_cnae(pr_dscnae   IN tbgen_cnae.dscnae%TYPE --> Descrição do CNAE
                           ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2)IS          --> Erros do processo
  /* .............................................................................
   Programa: pc_incluir_nacionalidade
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Adriano - CECRED
   Data    : Julho/2017                       Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Rotina para incluir CNAE

   Alteracoes: 
                
    ............................................................................. */                                    
    CURSOR cr_cnae (pr_dscnae IN tbgen_cnae.dscnae%TYPE) IS
    SELECT cnae.dscnae
      FROM tbgen_cnae cnae
     WHERE UPPER(cnae.dscnae) = UPPER(pr_dscnae);    
    rw_cnae cr_cnae%ROWTYPE;
    
    -- Variaveis de log
    vr_cdcooper NUMBER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_auxconta PLS_INTEGER := 0;
    
    --Variaveis de erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;         
    vr_exc_saida EXCEPTION;
  
  BEGIN
    
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CADCNA'
                              ,pr_action => null);
    
    -- Extrai os dados dos dados que vieram do php
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);  
                            
    -- Verifica se houve erro                      
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;                         
    
    OPEN cr_cnae(pr_dscnae);
    
    FETCH cr_cnae INTO rw_cnae;
      
    IF cr_cnae%FOUND THEN
      
      CLOSE cr_cnae;
      
      vr_dscritic := 'CNAE já cadastrado.';
      RAISE vr_exc_saida;
      
    END IF;  
    
    CLOSE cr_cnae;
    
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><cnae/>');    
    
    BEGIN 
      --Inclui CNAE
      INSERT INTO tbgen_cnae(dscnae) VALUES(UPPER(pr_dscnae));

    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Não foi possível incluir CNAE.';
        RAISE vr_exc_saida;          
        
    END;
    
    -- Gera log
    btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_nmarqlog     => 'cadcna.log'
                              ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                  ' -->  Operador '|| vr_cdoperad || ' - ' ||
                                                  'Efetuou a inclusao do CNAE ' ||
                                                  pr_dscnae || '.');
                                                     
    pr_des_erro := 'OK';
    
    COMMIT;
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      
      IF TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic:= GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); 
      END IF;
      
      pr_cdcritic := pr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
      
      ROLLBACK;
      
    WHEN OTHERS THEN
      
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral (TELA_CADCNA.pc_incluir_cnae).';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
      
      ROLLBACK;   
  
  END pc_incluir_cnae;  
  
  --Exclui nacionalidade requerida pelo usuario
  --Exclui CNAE requerida pelo usuario
  PROCEDURE pc_excluir_cnae(pr_cdcnae IN tbgen_cnae.cdcnae%TYPE  --> Código do CNAE
                           ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2)IS          --> Erros do processo
  /* .............................................................................
   Programa: pc_excluir_nacionalidades
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Adriano - CECRED
   Data    : Julho/2017                        Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Rotina para excluir CNAE

   Alteracoes: 
                
    ............................................................................. */                                    
    CURSOR cr_cnae (pr_cdcnae IN crapnac.dsnacion%TYPE) IS
    SELECT cnae.cdcnae
          ,cnae.dscnae
      FROM tbgen_cnae cnae
     WHERE cnae.cdcnae = pr_cdcnae;    
    rw_cnae cr_cnae%ROWTYPE;
    
    -- Variaveis de log
    vr_cdcooper NUMBER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_auxconta PLS_INTEGER := 0;
    
    --Variaveis de erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;         
    vr_exc_saida EXCEPTION;
  
  BEGIN
    
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CADCNA'
                              ,pr_action => null);
                              
    -- Extrai os dados dos dados que vieram do php
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);  
                            
    -- Verifica se houve erro                      
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;                         
    
    OPEN cr_cnae(pr_cdcnae);

    FETCH cr_cnae INTO rw_cnae;
      
    IF cr_cnae%NOTFOUND THEN
      
      CLOSE cr_cnae;
      
      vr_dscritic := 'CNAE não cadastrado.';
      RAISE vr_exc_saida;
      
    END IF;  
    
    CLOSE cr_cnae;
    
    BEGIN 
      --Excluir CNAE
      DELETE FROM tbgen_cnae
            WHERE tbgen_cnae.cdcnae = pr_cdcnae;

    EXCEPTION 
      WHEN OTHERS THEN 
        vr_dscritic := 'Não foi possível excluir CNAE.';
        RAISE vr_exc_saida;
                
    END;
    
    -- Gera log
    btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_nmarqlog     => 'cadcna.log'
                              ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                  ' -->  Operador '|| vr_cdoperad || ' - ' ||
                                                  'Efetuou a exclusao do CNAE '   ||
                                                  ' Codigo: ' || rw_cnae.cdcnae       || 
                                                  ', Descricao: '                          || 
                                                  rw_cnae.dscnae || '.');
                                                  
    pr_des_erro := 'OK';
    
    COMMIT;
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      
      IF TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic:= GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); 
      END IF;
      
      pr_cdcritic := pr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
      
    WHEN OTHERS THEN
      
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral (TELA_CADCNA.pc_excluir_cnae).';
      
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;   
  
  END pc_excluir_cnae;  
  
  --Altear CNAE requerido pelo usuario
  PROCEDURE pc_alterar_cnae(pr_cdcnae IN tbgen_cnae.cdcnae%TYPE  --> Código do CNAE
                           ,pr_dscnae IN tbgen_cnae.dscnae%TYPE  --> Descrição do CNAE
                           ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2)IS          --> Erros do processo 
  /* .............................................................................
   Programa: pc_alterar_cnae
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Adriano - CECRED
   Data    : Julho/2017                        Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Rotina para alterar o CNAE

   Alteracoes: 
                
    ............................................................................. */                                    
    CURSOR cr_tbgen_cnae (pr_cdcnae IN tbgen_cnae.cdcnae%TYPE) IS
    SELECT cnae.cdcnae
          ,cnae.dscnae
      FROM tbgen_cnae cnae
     WHERE cnae.cdcnae = pr_cdcnae;
    rw_tbgen_cnae cr_tbgen_cnae%ROWTYPE;
    
    CURSOR cr_cnae (pr_cdcnae IN tbgen_cnae.cdcnae%TYPE 
                   ,pr_dscnae IN tbgen_cnae.dscnae%TYPE) IS
    SELECT cnae.dscnae
      FROM tbgen_cnae cnae
     WHERE cnae.cdcnae <> pr_cdcnae
       AND UPPER(cnae.dscnae) = UPPER(pr_dscnae);
    rw_cnae cr_cnae%ROWTYPE;
    
    -- Variaveis de log
    vr_cdcooper NUMBER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_auxconta PLS_INTEGER := 0;
    
    --Variaveis de erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;         
    vr_exc_saida EXCEPTION;
  
  BEGIN
  
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CADCNA'
                              ,pr_action => null);
                              
    -- Extrai os dados dos dados que vieram do php
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);  
                            
    -- Verifica se houve erro                      
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;                         
    
    OPEN cr_tbgen_cnae(pr_cdcnae);

    FETCH cr_tbgen_cnae INTO rw_tbgen_cnae;
      
    IF cr_tbgen_cnae%NOTFOUND THEN
      
      CLOSE cr_tbgen_cnae;
      
      vr_dscritic := 'CNAE não cadastrado.';
      RAISE vr_exc_saida;
      
    END IF;  
    
    CLOSE cr_tbgen_cnae;
    
    OPEN cr_cnae(pr_cdcnae => pr_cdcnae
                ,pr_dscnae => pr_dscnae);

    FETCH cr_cnae INTO rw_cnae;
      
    IF cr_cnae%FOUND THEN
      
      CLOSE cr_cnae;
      
      vr_dscritic := 'CNAE já cadastrado.';
      RAISE vr_exc_saida;
      
    END IF;  
    
    CLOSE cr_cnae;
    
    BEGIN 
      --Alterar a nacionalidade
      UPDATE tbgen_cnae
         SET tbgen_cnae.dscnae = UPPER(pr_dscnae)
       WHERE tbgen_cnae.cdcnae = pr_cdcnae;

    EXCEPTION 
      WHEN OTHERS THEN 
        vr_dscritic := 'Não foi possível alterar CNAE.';
        RAISE vr_exc_saida;
                
    END;
    
    -- Gera log
    btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_nmarqlog     => 'cadcna.log'
                              ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                  ' -->  Operador '|| vr_cdoperad || ' - ' ||
                                                  'Efetuou a alteracao CNAE ' || 
                                                  rw_tbgen_cnae.cdcnae || ' - de ' ||
                                                  rw_tbgen_cnae.dscnae || ' para ' || 
                                                  pr_dscnae || '.');
                                                  
    pr_des_erro := 'OK';
    
    COMMIT;
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      
      IF TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic:= GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); 
      END IF;
      
      pr_cdcritic := pr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
      
    WHEN OTHERS THEN
      
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral (TELA_CADCNA.pc_alterar_cnae).';
      
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;   
  
  END pc_alterar_cnae;  
  
  --Valida se CNAE está cadastrado no sistema
  PROCEDURE pc_valida_cnae(pr_cdcnae IN tbgen_cnae.cdcnae%TYPE  --> Código do CNAE
                          ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                          ,pr_dscritic OUT VARCHAR2) IS         --> Descrição da crítica
                         
  /* .............................................................................
   Programa: pc_valida_cnae
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David - AILOS
   Data    : Agosto/2019                        Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Rotina para validar se o CNAE está cadastrado

   Alteracoes: 
                
    ............................................................................. */                                    
    CURSOR cr_cnae (pr_cdcnae IN tbgen_cnae.cdcnae%TYPE) IS
    SELECT cnae.cdcnae          
      FROM tbgen_cnae cnae
     WHERE cdcnae = nvl(pr_cdcnae,0);     
    rw_cnae cr_cnae%ROWTYPE;
    
    --Variaveis de erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;         
    vr_exc_saida EXCEPTION;    
  
  BEGIN
          
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CADCNA'
                              ,pr_action => null);
              
    OPEN cr_cnae(pr_cdcnae);
    FETCH cr_cnae INTO rw_cnae;      
    
    IF cr_cnae%NOTFOUND THEN      
      CLOSE cr_cnae;      
      vr_cdcritic := 1501;
      RAISE vr_exc_saida;      
    END IF;  
    
    CLOSE cr_cnae;        
  
  EXCEPTION
    WHEN vr_exc_saida THEN
      
      vr_dscritic:= GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); 
            
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
    WHEN OTHERS THEN
      
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral (TELA_CADCNA.pc_valida_cnae).';
        
  END pc_valida_cnae;  
  
  
END TELA_CADCNA;
/
