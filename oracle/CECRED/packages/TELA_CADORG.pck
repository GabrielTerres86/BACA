CREATE OR REPLACE PACKAGE CECRED.TELA_CADORG AS

   /*
   Programa: TELA_CADORG                          antigo:
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED

   Autor   : Adriano - CECRED
   Data    : Junho/2017                       Ultima atualizacao: 

   Dados referentes ao programa:

   Frequencia: Diario (on-line).
   Objetivo  : Mostrar a tela CADORG para permitir o gerenciamento de orgão expedidor

   Alteracoes: 

   */  
   
  --Busca orgão expedidor cadastrado no sistema
  PROCEDURE pc_consulta_orgao_expedidor(pr_cdorgao_expedidor IN tbgen_orgao_expedidor.cdorgao_expedidor%TYPE --> Código orgão expedidor
                                       ,pr_nmorgao_expedidor IN tbgen_orgao_expedidor.nmorgao_expedidor%TYPE --> Descrição orgão expedidor
                                       ,pr_nrregist IN INTEGER               -- Quantidade de registros                            
                                       ,pr_nriniseq IN INTEGER               -- Qunatidade inicial
                                       ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
                                     
  --Inclui orgão expedidor
  PROCEDURE pc_incluir_orgao_expedidor(pr_cdorgao_expedidor IN tbgen_orgao_expedidor.cdorgao_expedidor%TYPE --> Código orgão expedidor
                                      ,pr_nmorgao_expedidor IN tbgen_orgao_expedidor.nmorgao_expedidor%TYPE --> Descrição orgão expedidor
                                      ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
                                 
  --Exclui orgão expedidor
  PROCEDURE pc_excluir_orgao_expedidor(pr_cdorgao_expedidor IN tbgen_orgao_expedidor.cdorgao_expedidor%TYPE --> Identificador do orgão expedidor
                                      ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
                                    
  --Altear orgão expedidor
  PROCEDURE pc_alterar_orgao_expedidor(pr_idorgao_expedidor IN tbgen_orgao_expedidor.idorgao_expedidor%TYPE --> Identificador do orgão expedidor
                                      ,pr_cdorgao_expedidor IN tbgen_orgao_expedidor.cdorgao_expedidor%TYPE --> Código orgão expedidor
                                      ,pr_nmorgao_expedidor IN tbgen_orgao_expedidor.nmorgao_expedidor%TYPE --> Descrição orgão expedidor
                                      ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2);           --> Erros do processo                                    
                                                                                     
END TELA_CADORG;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_CADORG AS

/*---------------------------------------------------------------------------------------------------------------
   Programa: TELA_CADORG                          antigo: 
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED

   Autor   : Adriano - CECRED
   Data    : Junho/2017                       Ultima atualizacao: 

   Dados referentes ao programa:

   Frequencia: Diario (on-line).
   Objetivo  : Mostrar a tela CADORG para permitir o gerenciamento de orgão expedidor

   Alteracoes: 
			              
  ---------------------------------------------------------------------------------------------------------------*/
  PROCEDURE pc_gera_log(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_idorgao_expedidor IN tbgen_orgao_expedidor.idorgao_expedidor%TYPE
                       ,pr_cdoperad IN crapope.cdoperad%TYPE
                       ,pr_dsdcampo IN VARCHAR2
                       ,pr_vlrcampo IN VARCHAR2
                       ,pr_vlcampo2 IN VARCHAR2
                       ,pr_des_erro OUT VARCHAR2) IS

  /*---------------------------------------------------------------------------------------------------------------

    Programa : pc_gera_log                            antiga:
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Adriano - CECRED
    Data     : Junho/2017                           Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: -----
    Objetivo   : Procedure para gerar log

    Alterações :
    -------------------------------------------------------------------------------------------------------------*/

   BEGIN

     IF pr_vlrcampo <> pr_vlcampo2 THEN

       -- Gera log
       btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                 ,pr_ind_tipo_log => 2 -- Erro tratato
                                 ,pr_nmarqlog     => 'cadorg.log'
                                 ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                     ' -->  Operador '|| pr_cdoperad || ' - ' ||
                                                     'Efetuou a alteracao do orgao expedidor - ' ||
                                                     'Identificador: ' || gene0002.fn_mask(pr_idorgao_expedidor,'z.zzz.zz9') ||
                                                     ', ' || pr_dsdcampo || ' de ' || pr_vlrcampo ||
                                                     ' para ' || pr_vlcampo2 || '.');

     END IF;

     pr_des_erro := 'OK';

   EXCEPTION
     WHEN OTHERS THEN
       pr_des_erro := 'NOK';
   END pc_gera_log;
  
  
  --Consulta orgão expedidor cadastrado no sistema
  PROCEDURE pc_consulta_orgao_expedidor(pr_cdorgao_expedidor IN tbgen_orgao_expedidor.cdorgao_expedidor%TYPE --> Código orgão expedidor
                                       ,pr_nmorgao_expedidor IN tbgen_orgao_expedidor.nmorgao_expedidor%TYPE --> Descrição orgão expedidor
                                       ,pr_nrregist IN INTEGER               -- Quantidade de registros                            
                                       ,pr_nriniseq IN INTEGER               -- Qunatidade inicial
                                       ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  /* .............................................................................
   Programa: pc_consulta_orgao_expedidor
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Adriano - CECRED
   Data    : Junho/2017                        Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Rotina para buscar orgão expedidor

   Alteracoes: 
                
    ............................................................................. */                                    
    CURSOR cr_tbgen_orgao_expedidor (pr_cdorgao_expedidor IN tbgen_orgao_expedidor.cdorgao_expedidor%TYPE
                                    ,pr_nmorgao_expedidor IN tbgen_orgao_expedidor.nmorgao_expedidor%TYPE) IS
    SELECT org.cdorgao_expedidor 
          ,org.nmorgao_expedidor
          ,org.idorgao_expedidor
      FROM tbgen_orgao_expedidor org
     WHERE (pr_cdorgao_expedidor IS NULL
        OR upper(org.cdorgao_expedidor) = pr_cdorgao_expedidor)
       AND UPPER(org.nmorgao_expedidor) LIKE '%' || pr_nmorgao_expedidor || '%';
    
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
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    
    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Root',pr_posicao => 0,pr_tag_nova => 'orgaos',pr_tag_cont => NULL,pr_des_erro => vr_dscritic); 
        
    --Loop nas nacionalidades   
    FOR rw_tbgen_orgao_expedidor IN cr_tbgen_orgao_expedidor(pr_cdorgao_expedidor => TRIM(upper(pr_cdorgao_expedidor))
                                                            ,pr_nmorgao_expedidor => upper(pr_nmorgao_expedidor)) LOOP
      
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
      
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'orgaos',pr_posicao => 0,pr_tag_nova => 'orgao',pr_tag_cont => NULL,pr_des_erro => vr_dscritic); 
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'orgao',pr_posicao => vr_auxconta, pr_tag_nova => 'idorgao_expedidor', pr_tag_cont => rw_tbgen_orgao_expedidor.idorgao_expedidor, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'orgao',pr_posicao => vr_auxconta, pr_tag_nova => 'cdorgao_expedidor', pr_tag_cont => rw_tbgen_orgao_expedidor.cdorgao_expedidor, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'orgao',pr_posicao => vr_auxconta, pr_tag_nova => 'nmorgao_expedidor', pr_tag_cont => rw_tbgen_orgao_expedidor.nmorgao_expedidor, pr_des_erro => vr_dscritic);
       
        -- Incrementa contador p/ posicao no XML
        vr_auxconta := nvl(vr_auxconta,0) + 1;  
              
      END IF;
        
      --Diminuir registros
      vr_nrregist:= nvl(vr_nrregist,0) - 1; 
      
    END LOOP;
    
    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'orgaos'            --> Nome da TAG XML
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
      pr_dscritic := 'Erro geral (TELA_CADORG.pc_consulta_orgao_expedidor).';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
      
      ROLLBACK;   
  
  END pc_consulta_orgao_expedidor;

  --Inclui orgão expedidor
  PROCEDURE pc_incluir_orgao_expedidor(pr_cdorgao_expedidor IN tbgen_orgao_expedidor.cdorgao_expedidor%TYPE --> Código orgão expedidor
                                      ,pr_nmorgao_expedidor IN tbgen_orgao_expedidor.nmorgao_expedidor%TYPE --> Descrição orgão expedidor
                                      ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  /* .............................................................................
   Programa: pc_incluir_orgao_expedidor
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Adriano - CECRED
   Data    : Junho/2017                       Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Rotina para incluir orgão expedidor

   Alteracoes: 
                
    ............................................................................. */                                    
    CURSOR cr_tbgen_orgao_expedidor (pr_cdorgao_expedidor IN tbgen_orgao_expedidor.cdorgao_expedidor%TYPE
                                    ,pr_nmorgao_expedidor IN tbgen_orgao_expedidor.nmorgao_expedidor%TYPE) IS
    SELECT 1
      FROM tbgen_orgao_expedidor org
     WHERE ((UPPER(org.cdorgao_expedidor) = pr_cdorgao_expedidor
       AND   UPPER(org.nmorgao_expedidor) = pr_nmorgao_expedidor))
        OR  (UPPER(org.cdorgao_expedidor) = pr_cdorgao_expedidor);    
    rw_tbgen_orgao_expedidor cr_tbgen_orgao_expedidor%ROWTYPE;
    
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
    GENE0001.pc_informa_acesso(pr_module => 'CADORG'
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
    
    OPEN cr_tbgen_orgao_expedidor(pr_cdorgao_expedidor => trim(upper(pr_cdorgao_expedidor))
                                 ,pr_nmorgao_expedidor => trim(upper(pr_nmorgao_expedidor)));
    
    FETCH cr_tbgen_orgao_expedidor INTO rw_tbgen_orgao_expedidor;
      
    IF cr_tbgen_orgao_expedidor%FOUND THEN
      
      CLOSE cr_tbgen_orgao_expedidor;
      
      vr_dscritic := 'Orgão expedidor já existe.';
      RAISE vr_exc_saida;
      
    END IF;  
    
    CLOSE cr_tbgen_orgao_expedidor;
    
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><orgaoexpedidor/>');    
    
    BEGIN 
      --Inclui a nacionalidade
      INSERT INTO tbgen_orgao_expedidor(cdorgao_expedidor
                                       ,nmorgao_expedidor) 
                                VALUES(TRIM(UPPER(pr_cdorgao_expedidor))
                                      ,TRIM(UPPER(pr_nmorgao_expedidor)));

    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Nao foi possivel incluir o orgão expedidor.';
        RAISE vr_exc_saida;          
        
    END;
    
    -- Gera log
    btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_nmarqlog     => 'cadorg.log'
                              ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                  ' -->  Operador '|| vr_cdoperad || ' - ' ||
                                                  'Efetuou a inclusao do orgao pagador ' ||
                                                  'Codigo: ' || pr_cdorgao_expedidor || 
                                                  ', Descricao: ' || pr_nmorgao_expedidor || '.');
                                                     
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
      pr_dscritic := 'Erro geral (TELA_CADORG.pc_incluir_orgao_expedidor).';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
      
      ROLLBACK;   
  
  END pc_incluir_orgao_expedidor;  
  
  --Exclui orgão expedidor
  PROCEDURE pc_excluir_orgao_expedidor(pr_cdorgao_expedidor IN tbgen_orgao_expedidor.cdorgao_expedidor%TYPE --> Identificador do orgão expedidor
                                      ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  /* .............................................................................
   Programa: pc_excluir_orgao_expedidor
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Adriano - CECRED
   Data    : Junho/2017                        Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Rotina para excluir orgão expedidor

   Alteracoes: 
                
    ............................................................................. */                                    
    CURSOR cr_tbgen_orgao_expedidor (pr_cdorgao_expedidor IN tbgen_orgao_expedidor.cdorgao_expedidor%TYPE) IS
    SELECT *
      FROM tbgen_orgao_expedidor org
     WHERE upper(org.cdorgao_expedidor) = pr_cdorgao_expedidor;    
    rw_tbgen_orgao_expedidor cr_tbgen_orgao_expedidor%ROWTYPE;
    
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
    GENE0001.pc_informa_acesso(pr_module => 'CADORG'
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
    
    OPEN cr_tbgen_orgao_expedidor(trim(upper(pr_cdorgao_expedidor)));

    FETCH cr_tbgen_orgao_expedidor INTO rw_tbgen_orgao_expedidor;
      
    IF cr_tbgen_orgao_expedidor%NOTFOUND THEN
      
      CLOSE cr_tbgen_orgao_expedidor;
      
      vr_dscritic := 'Orgão expedidor não cadastrado.';
      RAISE vr_exc_saida;
      
    END IF;  
    
    CLOSE cr_tbgen_orgao_expedidor;
    
    BEGIN 
      --Excluir a nacionalidade
      DELETE FROM tbgen_orgao_expedidor
            WHERE UPPER(tbgen_orgao_expedidor.cdorgao_expedidor) = TRIM(UPPER(pr_cdorgao_expedidor));

    EXCEPTION 
      WHEN OTHERS THEN 
        vr_dscritic := 'Não foi possível excluir o orgão expedidor.';
        RAISE vr_exc_saida;
                
    END;
    
    -- Gera log
    btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_nmarqlog     => 'cadorg.log'
                              ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                  ' -->  Operador '|| vr_cdoperad || ' - ' ||
                                                  'Efetuou a exclusao do orgao expedidor '   ||
                                                  ' Identificador: ' || rw_tbgen_orgao_expedidor.idorgao_expedidor || 
                                                  ' Codigo: ' || rw_tbgen_orgao_expedidor.cdorgao_expedidor ||                                                   
                                                  ', Descricao: ' || rw_tbgen_orgao_expedidor.nmorgao_expedidor || '.');
                                                  
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
      pr_dscritic := 'Erro geral (TELA_CADORG.pc_excluir_orgao_expedidor).';
      
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;   
  
  END pc_excluir_orgao_expedidor;  
  
  --Altear orgão expedidor
  PROCEDURE pc_alterar_orgao_expedidor(pr_idorgao_expedidor IN tbgen_orgao_expedidor.idorgao_expedidor%TYPE --> Identificador do orgão expedidor
                                      ,pr_cdorgao_expedidor IN tbgen_orgao_expedidor.cdorgao_expedidor%TYPE --> Código orgão expedidor
                                      ,pr_nmorgao_expedidor IN tbgen_orgao_expedidor.nmorgao_expedidor%TYPE --> Descrição orgão expedidor
                                      ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  /* .............................................................................
   Programa: pc_alterar_orgao_expedidor
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Adriano - CECRED
   Data    : Junho/2017                        Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Rotina para alterar orgão expedidor

   Alteracoes: 
                
    ............................................................................. */                                    
    CURSOR cr_tbgen_orgao_expedidor (pr_idorgao_expedidor IN tbgen_orgao_expedidor.idorgao_expedidor%TYPE) IS
    SELECT *
      FROM tbgen_orgao_expedidor org
     WHERE org.idorgao_expedidor = pr_idorgao_expedidor;
    rw_tbgen_orgao_expedidor cr_tbgen_orgao_expedidor%ROWTYPE;
    
    CURSOR cr_orgao (pr_idorgao_expedidor IN tbgen_orgao_expedidor.idorgao_expedidor%TYPE 
                    ,pr_cdorgao_expedidor IN tbgen_orgao_expedidor.cdorgao_expedidor%TYPE 
                    ,pr_nmorgao_expedidor IN tbgen_orgao_expedidor.nmorgao_expedidor%TYPE) IS
    SELECT org.idorgao_expedidor
      FROM tbgen_orgao_expedidor org
     WHERE org.idorgao_expedidor <> pr_idorgao_expedidor
       AND (UPPER(org.cdorgao_expedidor) = pr_cdorgao_expedidor
        OR  UPPER(org.nmorgao_expedidor) = pr_nmorgao_expedidor);
    rw_orgao cr_orgao%ROWTYPE;
    
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
    vr_des_erro VARCHAR2(10);
  
  BEGIN
    
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CADORG'
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
    
    OPEN cr_tbgen_orgao_expedidor(pr_idorgao_expedidor);

    FETCH cr_tbgen_orgao_expedidor INTO rw_tbgen_orgao_expedidor;
      
    IF cr_tbgen_orgao_expedidor%NOTFOUND THEN
      
      CLOSE cr_tbgen_orgao_expedidor;
      
      vr_dscritic := 'Orgão expedidor não encontrado.';
      RAISE vr_exc_saida;
      
    END IF;  
    
    CLOSE cr_tbgen_orgao_expedidor;
    
    OPEN cr_orgao(pr_idorgao_expedidor => pr_idorgao_expedidor
                 ,pr_cdorgao_expedidor => trim(upper(pr_cdorgao_expedidor))
                 ,pr_nmorgao_expedidor => trim(upper(pr_nmorgao_expedidor)));

    FETCH cr_orgao INTO rw_orgao;
      
    IF cr_orgao%FOUND THEN
      
      CLOSE cr_orgao;
      
      vr_dscritic := 'Orgão expedidor já cadastrado.';
      RAISE vr_exc_saida;
      
    END IF;  
    
    CLOSE cr_orgao;
    
    BEGIN 
      --Alterar a nacionalidade
      UPDATE tbgen_orgao_expedidor
         SET tbgen_orgao_expedidor.cdorgao_expedidor = trim(UPPER(pr_cdorgao_expedidor))
            ,tbgen_orgao_expedidor.nmorgao_expedidor = trim(UPPER(pr_nmorgao_expedidor))
       WHERE tbgen_orgao_expedidor.idorgao_expedidor = pr_idorgao_expedidor;

    EXCEPTION 
      WHEN OTHERS THEN 
        vr_dscritic := 'Nao foi possível alterar o orgao expedidor.';
        RAISE vr_exc_saida;
                
    END;
    
    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
               ,pr_idorgao_expedidor => rw_tbgen_orgao_expedidor.idorgao_expedidor --Código do produto
               ,pr_cdoperad => vr_cdoperad -- Operador
               ,pr_dsdcampo => 'Codigo'  --Descrição do campo
               ,pr_vlrcampo => trim(UPPER(rw_tbgen_orgao_expedidor.cdorgao_expedidor)) --Valor antigo
               ,pr_vlcampo2 => trim(UPPER(pr_cdorgao_expedidor)) --Valor atual
               ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;
    
    pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
               ,pr_idorgao_expedidor => rw_tbgen_orgao_expedidor.idorgao_expedidor --Código do produto
               ,pr_cdoperad => vr_cdoperad -- Operador
               ,pr_dsdcampo => 'Descricao'  --Descrição do campo
               ,pr_vlrcampo => trim(UPPER(rw_tbgen_orgao_expedidor.nmorgao_expedidor)) --Valor antigo
               ,pr_vlcampo2 => trim(UPPER(pr_nmorgao_expedidor)) --Valor atual
               ,pr_des_erro => vr_des_erro); --Erro

    IF vr_des_erro <> 'OK' THEN

      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao registar no log.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;

    END IF;
    
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
      pr_dscritic := 'Erro geral (TELA_CADORG.pc_alterar_orgao_expedidor).';
      
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;   
  
  END pc_alterar_orgao_expedidor;  
  
  
END TELA_CADORG;
/
