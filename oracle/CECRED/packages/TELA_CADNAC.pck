CREATE OR REPLACE PACKAGE CECRED.TELA_CADNAC AS

   /*
   Programa: TELA_CADNAC                          antigo:
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED

   Autor   : Adriano - CECRED
   Data    : Junho/2017                       Ultima atualizacao: 10/04/2018

   Dados referentes ao programa:

   Frequencia: Diario (on-line).
   Objetivo  : Mostrar a tela CADNAC para permitir o gerenciamento de nacionalidades

   Alteracoes: 10/04/2018 - Projeto 414 - Regulatório FATCA/CRS
                            (Marcelo Telles Coelho - Mouts).

   */  
   
  --Busca as nacionalidades cadastradas no sistema
  PROCEDURE pc_busca_nacionalidades(pr_cdnacion IN crapnac.cdnacion%TYPE -->Código da nacionalidade
                                   ,pr_dsnacion IN crapnac.dsnacion%TYPE --> Descrição da nacionalidade
                                   ,pr_nrregist IN INTEGER               --> Quantidade de registros
                                   ,pr_nriniseq IN INTEGER               --> Qunatidade inicial
                                   ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
                                     
  --Inclui nacionalidade requerida pelo usuario
  PROCEDURE pc_incluir_nacionalidade(pr_dsnacion IN crapnac.dsnacion%TYPE --> Descrição da nacionalidade
                                    ,pr_cdpais   IN crapnac.cdpais%TYPE   --> Código do pais no FATCA/CRS
                                    -- Projeto 414 - Marcelo Telles Coelho - Mouts
                                    ,pr_nmpais   IN crapnac.nmpais%TYPE   --> Nome do país
                                    ,pr_inacordo IN crapnac.inacordo%TYPE --> Tipo de acordo (FATCA, CRS)
                                    ,pr_dtinicio IN VARCHAR2              --> Data de início (dd/mm/yyyy)
                                    ,pr_dtfinal  IN VARCHAR2              --> Data final (dd/mm/yyyy)
                                    -- Projeto 414 - Marcelo Telles Coelho - Mouts
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
                                 
  --Exclui nacionalidade requerida pelo usuario
  PROCEDURE pc_excluir_nacionalidade(pr_cdnacion IN crapnac.dsnacion%TYPE --> Descrição da nacionalidade
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
                                    
  --Altear nacionalidade requerida pelo usuario
  PROCEDURE pc_alterar_nacionalidade(pr_cdnacion IN crapnac.cdnacion%TYPE --> Código da nacionalidade
                                    ,pr_dsnacion IN crapnac.dsnacion%TYPE --> Descrição da nacionalidade
                                    ,pr_cdpais   IN crapnac.cdpais%TYPE   --> Código do pais no FATCA/CRS
                                    ,pr_nmpais   IN crapnac.nmpais%TYPE   --> Nome do país
                                    -- Projeto 414 - Marcelo Telles Coelho - Mouts
                                    ,pr_inacordo IN crapnac.inacordo%TYPE --> Tipo de acordo (FATCA, CRS)
                                    ,pr_dtinicio IN VARCHAR2              --> Data de início (dd/mm/yyyy)
                                    ,pr_dtfinal  IN VARCHAR2              --> Data final (dd/mm/yyyy)
                                    -- Projeto 414 - Marcelo Telles Coelho - Mouts
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);           --> Erros do processo                                    
                                                                                     
END TELA_CADNAC;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_CADNAC AS

/*---------------------------------------------------------------------------------------------------------------
   Programa: TELA_CADNAC                          antigo: 
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED

   Autor   : Adriano - CECRED
   Data    : Junho/2017                       Ultima atualizacao: 10/04/2018

   Dados referentes ao programa:

   Frequencia: Diario (on-line).
   Objetivo  : Mostrar a tela CADNAC para permitir o gerenciamento de nacionalidades

   Alteracoes: 10/04/2018 - Projeto 414 - Regulatório FATCA/CRS
                            (Marcelo Telles Coelho - Mouts).
			              
  ---------------------------------------------------------------------------------------------------------------*/
  
  --Busca as nacionalidades cadastradas no sistema
  PROCEDURE pc_busca_nacionalidades(pr_cdnacion IN crapnac.cdnacion%TYPE -->Código da nacionalidade
                                   ,pr_dsnacion IN crapnac.dsnacion%TYPE --> Descrição da nacionalidade
                                   ,pr_nrregist IN INTEGER               -- Quantidade de registros                            
                                   ,pr_nriniseq IN INTEGER               -- Qunatidade inicial
                                   ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  /* .............................................................................
   Programa: pc_busca_nacionalidades
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Adriano - CECRED
   Data    : Junho/2017                        Ultima atualizacao: 10/04/2018

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Rotina para buscar as nacionalidades

   Alteracoes: 10/04/2018 - Projeto 414 - Regulatório FATCA/CRS
                            (Marcelo Telles Coelho - Mouts).
                
    ............................................................................. */                                    
    CURSOR cr_crapnac (pr_cdnacion IN crapnac.cdnacion%TYPE
                      ,pr_dsnacion IN crapnac.dsnacion%TYPE) IS
    SELECT nac.dsnacion 
          ,nac.cdnacion
          ,nac.cdpais
          ,nac.nmpais
          ,nac.inacordo                                -- Projeto 414 - Marcelo Telles Coelho - Mouts
          ,TO_CHAR(nac.dtinicio,'dd/mm/yyyy') dtinicio -- Projeto 414 - Marcelo Telles Coelho - Mouts
          ,TO_CHAR(nac.dtfinal,'dd/mm/yyyy') dtfinal   -- Projeto 414 - Marcelo Telles Coelho - Mouts
      FROM crapnac nac
     WHERE (pr_cdnacion = 0 
        OR nac.cdnacion = pr_cdnacion)
       AND UPPER(nac.dsnacion) LIKE '%' || pr_dsnacion || '%'
     ORDER BY nac.dsnacion;
    
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
    GENE0001.pc_informa_acesso(pr_module => 'CADNAC'
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
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    
    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Root',pr_posicao => 0,pr_tag_nova => 'crapnac',pr_tag_cont => NULL,pr_des_erro => vr_dscritic); 
        
    --Loop nas nacionalidades   
    FOR rw_crapnac IN cr_crapnac(pr_cdnacion => nvl(pr_cdnacion,0)
                                ,pr_dsnacion => upper(pr_dsnacion)) LOOP
      
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
      
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'crapnac',pr_posicao => 0,pr_tag_nova => 'nacionalidades',pr_tag_cont => NULL,pr_des_erro => vr_dscritic); 
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'nacionalidades',pr_posicao => vr_auxconta, pr_tag_nova => 'cdnacion', pr_tag_cont => rw_crapnac.cdnacion, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'nacionalidades',pr_posicao => vr_auxconta, pr_tag_nova => 'dsnacion', pr_tag_cont => rw_crapnac.dsnacion, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'nacionalidades',pr_posicao => vr_auxconta, pr_tag_nova => 'cdpais', pr_tag_cont => rw_crapnac.cdpais, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'nacionalidades',pr_posicao => vr_auxconta, pr_tag_nova => 'nmpais', pr_tag_cont => rw_crapnac.nmpais, pr_des_erro => vr_dscritic);
        -- Projeto 414 - Marcelo Telles Coelho - Mouts
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'nacionalidades',pr_posicao => vr_auxconta, pr_tag_nova => 'inacordo', pr_tag_cont => rw_crapnac.inacordo, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'nacionalidades',pr_posicao => vr_auxconta, pr_tag_nova => 'dtinicio', pr_tag_cont => rw_crapnac.dtinicio, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'nacionalidades',pr_posicao => vr_auxconta, pr_tag_nova => 'dtfinal', pr_tag_cont => rw_crapnac.dtfinal, pr_des_erro => vr_dscritic);
        -- Incrementa contador p/ posicao no XML
        vr_auxconta := nvl(vr_auxconta,0) + 1;  
              
      END IF;
        
      --Diminuir registros
      vr_nrregist:= nvl(vr_nrregist,0) - 1; 
      
    END LOOP;
    
    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'crapnac'           --> Nome da TAG XML
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
      pr_dscritic := 'Erro geral (TELA_CADNAC.pc_buscar_nacionalidades).';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
      
      ROLLBACK;   
  
  END pc_busca_nacionalidades;

  --Inclui nacionalidade requerida pelo usuario
  PROCEDURE pc_incluir_nacionalidade(pr_dsnacion IN crapnac.dsnacion%TYPE --> Descrição da nacionalidade
                                    ,pr_cdpais   IN crapnac.cdpais%TYPE   --> Código do pais no FATCA/CRS
                                    ,pr_nmpais   IN crapnac.nmpais%TYPE   --> Nome do país
                                    ,pr_inacordo IN crapnac.inacordo%TYPE --> Tipo de acordo (FATCA, CRS)
                                    ,pr_dtinicio IN VARCHAR2              --> Data de início (dd/mm/yyyy)
                                    ,pr_dtfinal  IN VARCHAR2              --> Data final (dd/mm/yyyy)
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  /* .............................................................................
   Programa: pc_incluir_nacionalidade
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Adriano - CECRED
   Data    : Junho/2017                       Ultima atualizacao: 10/04/2018

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Rotina para incluir as nacionalidades

   Alteracoes: 10/04/2018 - Projeto 414 - Regulatório FATCA/CRS
                            (Marcelo Telles Coelho - Mouts).
                
    ............................................................................. */                                    
    CURSOR cr_crapnac (pr_dsnacion IN crapnac.dsnacion%TYPE) IS
    SELECT nac.dsnacion 
      FROM crapnac nac
     WHERE UPPER(nac.dsnacion) = UPPER(pr_dsnacion);    
    rw_crapnac cr_crapnac%ROWTYPE;
    
    CURSOR cr_cdpais_uk (pr_cdpais IN crapnac.cdpais%TYPE) IS
    SELECT nac.cdnacion
      FROM crapnac nac
     WHERE UPPER(nac.cdpais) = UPPER(pr_cdpais);
    rw_cdpais_uk cr_cdpais_uk%ROWTYPE;

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
  
    --Variaveis de trabalho
    vr_dtinicio crapnac.dtinicio%TYPE; -- Projeto 414 - Marcelo Telles Coelho - Mouts
    vr_dtfinal  crapnac.dtfinal%TYPE;  -- Projeto 414 - Marcelo Telles Coelho - Mouts

  BEGIN
    
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CADNAC'
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

    vr_dtinicio := TO_DATE(pr_dtinicio,'dd/mm/yyyy'); -- Projeto 414 - Marcelo Telles Coelho - Mouts
    vr_dtfinal  := TO_DATE(pr_dtfinal,'dd/mm/yyyy');  -- Projeto 414 - Marcelo Telles Coelho - Mouts

    -- Projeto 414 - Marcelo Telles Coelho - Mouts
    IF vr_dtinicio < TRUNC(SYSDATE) THEN
      vr_dscritic := 'Data início deve ser maior ou igual ao dia de hoje!';
      RAISE vr_exc_saida;
    END IF;

    -- Projeto 414 - Marcelo Telles Coelho - Mouts
    IF vr_dtfinal IS NOT NULL THEN
      IF vr_dtfinal < vr_dtinicio THEN
        vr_dscritic := 'Data final deve ser maios ou igual a Data inicio!';
        RAISE vr_exc_saida;
      END IF;
    END IF;                         
    
    OPEN cr_crapnac(pr_dsnacion);
    
    FETCH cr_crapnac INTO rw_crapnac;
      
    IF cr_crapnac%FOUND THEN
      
      CLOSE cr_crapnac;
      
      vr_dscritic := 'Nacionalidade já existe.';
      RAISE vr_exc_saida;
      
    END IF;  
    
    CLOSE cr_crapnac;
    
    -- Ver UK CDPAIS

    IF pr_cdpais IS NOT NULL THEN
      OPEN cr_cdpais_uk(pr_cdpais);

      FETCH cr_cdpais_uk INTO rw_cdpais_uk;

      IF cr_cdpais_uk%FOUND THEN

        CLOSE cr_cdpais_uk;

        vr_dscritic := 'País já cadastrado na nacionalidade '||rw_cdpais_uk.cdnacion||'.';
        RAISE vr_exc_saida;

      END IF;

      CLOSE cr_cdpais_uk;
    END IF;

    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><nacionalidades/>');    
    
    BEGIN 
      --Inclui a nacionalidade
      INSERT INTO crapnac(dsnacion
                         ,cdpais
                         ,nmpais
                         -- Projeto 414 - Marcelo Telles Coelho - Mouts
                         ,inacordo
                         ,dtinicio
                         ,dtfinal)
                   VALUES(UPPER(pr_dsnacion)
                         ,UPPER(pr_cdpais)
                         ,UPPER(pr_nmpais)
                         -- Projeto 414 - Marcelo Telles Coelho - Mouts
                         ,UPPER(pr_inacordo)
                         ,vr_dtinicio
                         ,vr_dtfinal);
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Não foi possível incluir a nacionalidade.';
        RAISE vr_exc_saida;          
        
    END;
    
    -- Gera log
    btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_nmarqlog     => 'cadnac.log'
                              ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                  ' -->  Operador '|| vr_cdoperad || ' - ' ||
                                                  'Efetuou a inclusao da nacionalidade ' ||
                                                  pr_dsnacion || '.');
                                                     
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
      pr_dscritic := 'Erro geral (TELA_CADNAC.pc_incluir_nacionalidade).';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
      
      ROLLBACK;   
  
  END pc_incluir_nacionalidade;  
  
  --Exclui nacionalidade requerida pelo usuario
  PROCEDURE pc_excluir_nacionalidade(pr_cdnacion IN crapnac.dsnacion%TYPE --> Descrição da nacionalidade
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  /* .............................................................................
   Programa: pc_excluir_nacionalidades
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Adriano - CECRED
   Data    : Junho/2017                        Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Rotina para excluir as nacionalidades

   Alteracoes: 
                
    ............................................................................. */                                    
    CURSOR cr_crapnac (pr_cdnacion IN crapnac.dsnacion%TYPE) IS
    SELECT nac.dsnacion 
          ,nac.cdnacion
      FROM crapnac nac
     WHERE nac.cdnacion = pr_cdnacion;    
    rw_crapnac cr_crapnac%ROWTYPE;
    
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
    GENE0001.pc_informa_acesso(pr_module => 'CADNAC'
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
    
    OPEN cr_crapnac(pr_cdnacion);

    FETCH cr_crapnac INTO rw_crapnac;
      
    IF cr_crapnac%NOTFOUND THEN
      
      CLOSE cr_crapnac;
      
      vr_dscritic := 'Nacionalidade não cadastrada.';
      RAISE vr_exc_saida;
      
    END IF;  
    
    CLOSE cr_crapnac;
    
    BEGIN 
      --Excluir a nacionalidade
      DELETE FROM crapnac
            WHERE crapnac.cdnacion = pr_cdnacion;

    EXCEPTION 
      WHEN OTHERS THEN 
        vr_dscritic := 'Não foi possível excluir a nacionalidade.';
        RAISE vr_exc_saida;
                
    END;
    
    -- Gera log
    btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_nmarqlog     => 'cadnac.log'
                              ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                  ' -->  Operador '|| vr_cdoperad || ' - ' ||
                                                  'Efetuou a exclusao da nacionalidade '   ||
                                                  ' Codigo: ' || rw_crapnac.cdnacion       || 
                                                  ', Descricao: '                          || 
                                                  rw_crapnac.dsnacion || '.');
                                                  
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
      pr_dscritic := 'Erro geral (TELA_CADNAC.pc_excluir_nacionalidades).';
      
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;   
  
  END pc_excluir_nacionalidade;  
  
  --Altear nacionalidade requerida pelo usuario
  PROCEDURE pc_alterar_nacionalidade(pr_cdnacion IN crapnac.cdnacion%TYPE --> Código da nacionalidade
                                    ,pr_dsnacion IN crapnac.dsnacion%TYPE --> Descrição da nacionalidade
                                    ,pr_cdpais   IN crapnac.cdpais%TYPE   --> Código do pais no FATCA/CRS
                                    ,pr_nmpais   IN crapnac.nmpais%TYPE   --> Nome do país
                                    ,pr_inacordo IN crapnac.inacordo%TYPE --> Tipo de acordo (FATCA, CRS)
                                    ,pr_dtinicio IN VARCHAR2              --> Data de início (dd/mm/yyyy)
                                    ,pr_dtfinal  IN VARCHAR2              --> Data final (dd/mm/yyyy)
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  /* .............................................................................
   Programa: pc_alterar_nacionalidades
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Adriano - CECRED
   Data    : Junho/2017                        Ultima atualizacao: 10/04/2018

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Rotina para alterar as nacionalidade

   Alteracoes: 10/04/2018 - Projeto 414 - Regulatório FATCA/CRS
                            (Marcelo Telles Coelho - Mouts).
                
    ............................................................................. */                                    
    CURSOR cr_crapnac (pr_cdnacion IN crapnac.cdnacion%TYPE) IS
    SELECT nac.dsnacion 
          ,nac.cdnacion
      FROM crapnac nac
     WHERE nac.cdnacion = pr_cdnacion;
    rw_crapnac cr_crapnac%ROWTYPE;
    
    CURSOR cr_nacionalidade (pr_cdnacion IN crapnac.cdnacion%TYPE 
                            ,pr_dsnacion IN crapnac.dsnacion%TYPE) IS
    SELECT nac.dsnacion 
      FROM crapnac nac
     WHERE nac.cdnacion <> pr_cdnacion 
       AND UPPER(nac.dsnacion) = UPPER(pr_dsnacion);
    rw_nacionalidade cr_nacionalidade%ROWTYPE;
    
    CURSOR cr_cdpais_uk (pr_cdnacion IN crapnac.cdnacion%TYPE
                        ,pr_cdpais IN crapnac.cdpais%TYPE) IS
    SELECT nac.cdnacion
      FROM crapnac nac
     WHERE nac.cdnacion <> pr_cdnacion
       AND UPPER(nac.cdpais) = UPPER(pr_cdpais);
    rw_cdpais_uk cr_cdpais_uk%ROWTYPE;

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
  
    --Variaveis de trabalho
    vr_dtinicio crapnac.dtinicio%TYPE; -- Projeto 414 - Marcelo Telles Coelho - Mouts
    vr_dtfinal  crapnac.dtfinal%TYPE;  -- Projeto 414 - Marcelo Telles Coelho - Mouts

  BEGIN
  
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CADNAC'
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

    vr_dtinicio := TO_DATE(pr_dtinicio,'dd/mm/yyyy'); -- Projeto 414 - Marcelo Telles Coelho - Mouts
    vr_dtfinal  := TO_DATE(pr_dtfinal,'dd/mm/yyyy');  -- Projeto 414 - Marcelo Telles Coelho - Mouts

    -- Projeto 414 - Marcelo Telles Coelho - Mouts
    IF vr_dtfinal IS NOT NULL THEN
      IF vr_dtinicio IS NULL THEN
        vr_dscritic := 'Data inicio deve ser informada!';
        RAISE vr_exc_saida;
      END IF;
      IF vr_dtfinal < vr_dtinicio THEN
        vr_dscritic := 'Data final deve ser maios ou igual a Data inicio!';
        RAISE vr_exc_saida;
      END IF;
    END IF;

    -- Projeto 414 - Marcelo Telles Coelho - Mouts
    IF vr_dtinicio IS NOT NULL THEN
      IF pr_inacordo IS NULL THEN
        vr_dscritic := 'Pais nao faz parte de acordo, Datas nao devem ser informadas!';
        RAISE vr_exc_saida;
      END IF;
    END IF;                         
    
    OPEN cr_crapnac(pr_cdnacion);

    FETCH cr_crapnac INTO rw_crapnac;
      
    IF cr_crapnac%NOTFOUND THEN
      
      CLOSE cr_crapnac;
      
      vr_dscritic := 'Nacionalidade não cadastrada.';
      RAISE vr_exc_saida;
      
    END IF;  
    
    CLOSE cr_crapnac;
    
    OPEN cr_nacionalidade(pr_cdnacion => pr_cdnacion
                         ,pr_dsnacion => pr_dsnacion);

    FETCH cr_nacionalidade INTO rw_nacionalidade;
      
    IF cr_nacionalidade%FOUND THEN
      
      CLOSE cr_nacionalidade;
      
      vr_dscritic := 'Nacionalidade já cadastrada.';
      RAISE vr_exc_saida;
      
    END IF;  
    
    CLOSE cr_nacionalidade;
    
    -- Ver UK CDPAIS

    IF pr_cdpais IS NOT NULL THEN
      OPEN cr_cdpais_uk(pr_cdnacion
                       ,pr_cdpais);

      FETCH cr_cdpais_uk INTO rw_cdpais_uk;

      IF cr_cdpais_uk%FOUND THEN

        CLOSE cr_cdpais_uk;

        vr_dscritic := 'País já cadastrado na nacionalidade '||rw_cdpais_uk.cdnacion||'.';
        RAISE vr_exc_saida;

      END IF;

      CLOSE cr_cdpais_uk;
    END IF;

    BEGIN 
      --Alterar a nacionalidade
      UPDATE crapnac
         SET crapnac.dsnacion = UPPER(pr_dsnacion)
            -- Projeto 414 - Marcelo Telles Coelho - Mouts
            ,crapnac.cdpais   = UPPER(pr_cdpais)
            ,crapnac.nmpais   = UPPER(pr_nmpais)
            ,crapnac.inacordo = UPPER(pr_inacordo)
            ,crapnac.dtinicio = vr_dtinicio
            ,crapnac.dtfinal  = vr_dtfinal
       WHERE crapnac.cdnacion = pr_cdnacion;

    EXCEPTION 
      WHEN OTHERS THEN 
        vr_dscritic := 'Não foi possível alterar a nacionalidade.';
        RAISE vr_exc_saida;
                
    END;
    
    -- Gera log
    btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_nmarqlog     => 'cadnac.log'
                              ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                  ' -->  Operador '|| vr_cdoperad || ' - ' ||
                                                  'Efetuou a alteracao da nacionalidade ' || 
                                                  rw_crapnac.cdnacion || ' - de ' ||
                                                  rw_crapnac.dsnacion || ' para ' || 
                                                  pr_dsnacion || '.');
                                                  
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
      pr_dscritic := 'Erro geral (TELA_CADNAC.pc_alterar_nacionalidades).';
      
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;   
  
  END pc_alterar_nacionalidade;  
  
  
END TELA_CADNAC;
/
