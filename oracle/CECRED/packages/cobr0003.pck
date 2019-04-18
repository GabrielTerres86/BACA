CREATE OR REPLACE PACKAGE CECRED.cobr0003 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : cobr0003
  --  Sistema  : Procedimentos para cadastros gerais da cobranca
  --  Sigla    : CRED
  --  Autor    : Andrino Carlos de Souza Junior (RKAM)
  --  Data     : Junho/2014.                   Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas genericas para telas do AyllosWeb
  --
  --  Alteracoes: 18/08/2014 - Inclusão do contador de registros nas rotinas de consulta
  --                            (Andrino-RKAM)
  --
  --              18/04/2019 - Inclusao de job para automatizacao de limpeza de cheques sinistrados internos
  --                           da cooperativa que tenham mais de 180 dias de idade.
  --                           Chamado RITM0012001 - Gabriel Marcos (Mouts).
  --
  ---------------------------------------------------------------------------------------------------------------

  TYPE typ_reg_chqfora IS
    RECORD(cdbanco    NUMBER
          ,cdagectl   NUMBER
          ,nrcontachq NUMBER
          ,nrcheque   NUMBER);

  TYPE typ_tab_chqfora IS
    TABLE OF typ_reg_chqfora
    INDEX BY BINARY_INTEGER;

  -- Procedure para consulta na tela CBRFRA
  PROCEDURE pc_consulta_cbrfra( pr_cdcooper IN crapcop.cdcooper%type     -- Codigo da cooperativa
                               ,pr_tpfraude IN crapcbf.tpfraude%type     -- Tipo de fraude
                               ,pr_dsfraude IN crapcbf.dsfraude%type     -- Codigo de barras/cpf/cnpj
                               ,pr_dtperini IN VARCHAR2                  -- Data de inicio do periodo
                               ,pr_dtfimper IN VARCHAR2                  -- Data de fim do periodo
                               ,pr_nriniseq IN PLS_INTEGER               -- Numero inicial do registro para enviar
                               ,pr_nrregist IN PLS_INTEGER               -- Numero de registros que deverao ser retornados
                               ,pr_xmllog   IN VARCHAR2                  -- XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER              -- Código da crítica
                               ,pr_dscritic OUT VARCHAR2                 -- Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType        -- Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2                 -- Nome do campo com erro                      
                               ,pr_des_erro OUT VARCHAR2);               -- Erros do processo                                            

  -- rotina para inserir na tabela CRAPCBF
  PROCEDURE pc_insere_cbrfra( pr_cdcooper IN crapcop.cdcooper%type     -- Codigo da cooperativa
                             ,pr_tpfraude IN crapcbf.tpfraude%type     -- Tipo de fraude
                             ,pr_dsfraude IN crapcbf.dsfraude%type     -- Codigo de barras/cpf/cnpj
                             ,pr_dtsolici IN VARCHAR2                  -- Data de inicio do periodo
                             ,pr_xmllog   IN VARCHAR2                  -- XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER              -- Código da crítica
                             ,pr_dscritic OUT VARCHAR2                 -- Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType        -- Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2                 -- Nome do campo com erro                      
                             ,pr_des_erro OUT VARCHAR2);               -- Erros do processo                                            

  -- rotina para excluir na tabela CRAPCBF
  PROCEDURE pc_exclui_cbrfra( pr_cdcooper IN crapcop.cdcooper%type     -- Codigo da cooperativa
                             ,pr_tpfraude IN crapcbf.tpfraude%type     -- Tipo de fraude
                             ,pr_dsfraude IN crapcbf.dsfraude%type     -- Codigo de barras/cpf/cnpj
                             ,pr_xmllog   IN VARCHAR2                  -- XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER              -- Código da crítica
                             ,pr_dscritic OUT VARCHAR2                 -- Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType        -- Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2                 -- Nome do campo com erro                      
                             ,pr_des_erro OUT VARCHAR2);               -- Erros do processo                                            

  -- Procedure para consulta na tela CHQSIN
  PROCEDURE pc_consulta_chqsin( pr_cdbccxlt IN crapsch.cdbccxlt%TYPE     -- Codigo do banco que ocorreu o sinistro
                               ,pr_cdagectl IN crapsch.cdagectl%TYPE     -- Numero da agencia da Central
                               ,pr_nrctachq IN crapsch.nrctachq%TYPE     -- Numero da conta do cheque sinistrado.
                               ,pr_dtperini IN VARCHAR2                  -- Data de inicio do periodo
                               ,pr_dtfimper IN VARCHAR2                  -- Data de fim do periodo
                               ,pr_nriniseq IN PLS_INTEGER               -- Numero inicial do registro para enviar
                               ,pr_nrregist IN PLS_INTEGER               -- Numero final do registro para enviar
                               ,pr_xmllog   IN VARCHAR2                  -- XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER              -- Código da crítica
                               ,pr_dscritic OUT VARCHAR2                 -- Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType        -- Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2                 -- Nome do campo com erro                      
                               ,pr_des_erro OUT VARCHAR2);               -- Erros do processo                                            

  PROCEDURE pc_insere_chqsin( pr_dtmvtolt IN VARCHAR2                 -- data da ocorrencia do sinistro. 
                             ,pr_cdbccxlt IN crapsch.cdbccxlt%TYPE    -- codigo do banco que ocorreu o sinistro. 
                             ,pr_cdagectl IN crapsch.cdagectl%TYPE    -- numero da agencia da central. 
                             ,pr_nrctachq IN crapsch.nrctachq%TYPE    -- numero da conta do cheque sinistrado. 
                             ,pr_dsmotivo IN crapsch.dsmotivo%TYPE    -- motivo do sinistro. 
                             ,pr_cdoperad IN crapsch.cdoperad%TYPE    -- codigo do operador que efetuou o cadastro. 
                             ,pr_xmllog   IN VARCHAR2                 -- XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER             -- Código da crítica
                             ,pr_dscritic OUT VARCHAR2                -- Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType       -- Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2                -- Nome do campo com erro                      
                             ,pr_des_erro OUT VARCHAR2);              -- Erros do processo                                            

  PROCEDURE pc_exclui_chqsin( pr_dtmvtolt IN VARCHAR2                  -- data da ocorrencia do sinistro. 
                             ,pr_cdbccxlt IN crapsch.cdbccxlt%TYPE     -- codigo do banco que ocorreu o sinistro.
                             ,pr_cdagectl IN crapsch.cdagectl%TYPE     -- numero da agencia da central. 
                             ,pr_nrctachq IN crapsch.nrctachq%TYPE     -- numero da conta do cheque sinistrado. 
                             ,pr_xmllog   IN VARCHAR2                  -- XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER              -- Código da crítica
                             ,pr_dscritic OUT VARCHAR2                 -- Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType        -- Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2                 -- Nome do campo com erro                      
                             ,pr_des_erro OUT VARCHAR2);               -- Erros do processo                                            

  PROCEDURE pc_consulta_campo_chqsin( pr_nmcamp   IN VARCHAR2                  -- Nome do campo que esta sendo consultado
                                     ,pr_dspesq   IN VARCHAR2                  -- Chave de pesquisa
                                     ,pr_xmllog   IN VARCHAR2                  -- XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER              -- Código da crítica
                                     ,pr_dscritic OUT VARCHAR2                 -- Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType        -- Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2                 -- Nome do campo com erro                      
                                     ,pr_des_erro OUT VARCHAR2);               -- Erros do processo                                            

  -- Consultar os cheques sinistrados fora
  PROCEDURE pc_consulta_chqsin_fora(pr_cdbccxlt IN NUMBER                -- Codigo do banco que ocorreu o sinistro
                                   ,pr_cdagectl IN NUMBER               -- Numero da agencia da Central
                                   ,pr_nrctachq IN NUMBER               -- Numero da conta do cheque sinistrado.
                                   ,pr_dtperini IN VARCHAR2             -- Data de inicio do periodo
                                   ,pr_dtfimper IN VARCHAR2             -- Data de fim do periodo
                                   ,pr_nrcheque IN NUMBER               -- Numero do cheque
                                   ,pr_nriniseq IN PLS_INTEGER          -- Numero inicial do registro para enviar
                                   ,pr_nrregist IN PLS_INTEGER          -- Numero de registros que deverao ser retornados
                                   ,pr_xmllog   IN VARCHAR2             -- XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER         -- Código da crítica
                                   ,pr_dscritic OUT VARCHAR2            -- Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType   -- Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2            -- Nome do campo com erro                      
                                   ,pr_des_erro OUT VARCHAR2);
  
  -- Rotina para inserir os cheques sinistrados fora
  PROCEDURE pc_insere_chqsin_fora(pr_cdbccxlt IN NUMBER             -- codigo do banco que ocorreu o sinistro. 
                                 ,pr_cdagectl IN NUMBER             -- numero da agencia da central. 
                                 ,pr_nrctachq IN VARCHAR2           -- numero da conta do cheque sinistrado. 
                                 ,pr_nrchqini IN NUMBER             -- numero cheque inicial 
                                 ,pr_nrchqfim IN NUMBER             -- numero cheque final
                                 ,pr_cdoperad IN varchar2           -- codigo do operador que efetuou o cadastro. 
                                 ,pr_xmllog   IN VARCHAR2                 -- XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER             -- Código da crítica
                                 ,pr_dscritic OUT VARCHAR2                -- Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType       -- Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2                -- Nome do campo com erro                      
                                 ,pr_des_erro OUT VARCHAR2);
  
  -- Rotina para excluir os cheques sinistrados fora
  PROCEDURE pc_exclui_chqsin_fora(pr_xmllog   IN VARCHAR2                  -- XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER              -- Código da crítica
                                 ,pr_dscritic OUT VARCHAR2                 -- Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType        -- Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2                 -- Nome do campo com erro                      
                                 ,pr_des_erro OUT VARCHAR2);                                  

  -- Job para realizar limpeza automatica de cheques
  procedure pc_job_limpeza_chqsin;

END cobr0003;
/
CREATE OR REPLACE PACKAGE BODY CECRED.cobr0003 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : cobr0003
  --  Sistema  : Procedimentos para cadastros gerais da cobranca
  --  Sigla    : CRED
  --  Autor    : Andrino Carlos de Souza Junior (RKAM)
  --  Data     : Junho/2014.                   Ultima atualizacao: 11/01/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas genericas para telas do AyllosWeb
  --
  --  Alteracoes: 18/08/2014 - Inclusão do contador de registros nas rotinas de consulta
  --                           (Andrino-RKAM)
  --
  --              16/10/2015 - Incluir novas procedures pc_consulta_chqsin_fora, pc_insere_chqsin_fora e 
  --                           pc_exclui_chqsin_fora, projeto melhoria 217(Lucas Ranghetti #326872)
  --
  --              04/01/2016 - Ajuste na leitura da tabela crapcbf para utilizar UPPER nos campos VARCHAR
  --                           pois será incluido o UPPER no indice desta tabela - SD 375854
  --                           (Adriano).  
  --
  --              11/01/2016 - Ajuste na leitura da tabela crapcbf para utilizar UPPER nos campos VARCHAR
  --                           pois será incluido o UPPER no indice desta tabela - SD 375854
  --                           (Adriano).  
  --
  --              30/06/2016 - Ajuste na rotina pc_consulta_chqsin_fora que por falta de formato nas datas,
  --                           era gerado erros de mês invalidos, coforme relatado no chamado 474385. (Kelvin)
  --
  --              29/08/2016 - #456682 Alterações nas rotinas pc_consulta_cbrfra, pc_insere_cbrfra e 
  --                           pc_excluir_cbrfra para atender a tela CBRFRA com controle de fraudes em TEDs (Carlos)
  --                             
  --              18/04/2019 - Inclusao de job para automatizacao de limpeza de cheques sinistrados internos
  --                           da cooperativa que tenham mais de 180 dias de idade.
  --                           Chamado RITM0012001 - Gabriel Marcos (Mouts).
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Procedure para consulta na tela CBRFRA
  PROCEDURE pc_consulta_cbrfra( pr_cdcooper IN crapcop.cdcooper%type     -- Codigo da cooperativa
                               ,pr_tpfraude IN crapcbf.tpfraude%type     -- Tipo de fraude
                               ,pr_dsfraude IN crapcbf.dsfraude%type     -- Codigo de barras/cpf/cnpj
                               ,pr_dtperini IN VARCHAR2                  -- Data de inicio do periodo
                               ,pr_dtfimper IN VARCHAR2                  -- Data de fim do periodo
                               ,pr_nriniseq IN PLS_INTEGER               -- Numero inicial do registro para enviar
                               ,pr_nrregist IN PLS_INTEGER               -- Numero de registros que deverao ser retornados
                               ,pr_xmllog   IN VARCHAR2                  -- XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER              -- Código da crítica
                               ,pr_dscritic OUT VARCHAR2                 -- Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType        -- Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2                 -- Nome do campo com erro                      
                               ,pr_des_erro OUT VARCHAR2) IS             -- Erros do processo                                            

 
      -- Selecionar os codigos de barras fraudulentos
      CURSOR cr_crapcbf IS
        SELECT tpfraude, 
               dsfraude,
               to_char(dtsolici,'dd/mm/yyyy') dtsolici,
               count(1) over() retorno
          FROM crapcbf
         WHERE cdcooper = pr_cdcooper
           AND tpfraude = pr_tpfraude
           AND UPPER(dsfraude) = nvl(UPPER(pr_dsfraude),UPPER(dsfraude))
           AND dtsolici BETWEEN nvl(to_date(pr_dtperini,'dd/mm/yyyy'),dtsolici) 
                            AND nvl(to_date(pr_dtfimper,'dd/mm/yyyy'),dtsolici)
         ORDER BY dtsolici;
          
      vr_posreg        PLS_INTEGER := 0;    

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
      vr_contador      PLS_INTEGER := 0;    
    BEGIN

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    
      -- Loop sobre os codigos de barras fraudulentos
      FOR rw_crapcbf IN cr_crapcbf LOOP
        -- Incrementa o contador de registros
        vr_posreg := vr_posreg + 1;
        
        -- Se for o primeiro registro, insere uma tag com o total de registros existentes no filtro
        IF vr_posreg = 1 THEN
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados' , pr_posicao => 0          , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf'   , pr_posicao => 0          , pr_tag_nova => 'qtregist', pr_tag_cont => rw_crapcbf.retorno, pr_des_erro => vr_dscritic);
        END IF;
          
        -- Enviar somente se a linha for superior a linha inicial
        IF nvl(pr_nriniseq,0) <= vr_posreg THEN
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

          gene0007.pc_insere_tag(pr_xml => pr_retxml, 
                                 pr_tag_pai => 'inf', 
                                 pr_posicao => vr_contador, 
                                 pr_tag_nova => 'tpfraude', 
                                 pr_tag_cont => rw_crapcbf.tpfraude,
                                 pr_des_erro => vr_dscritic);

          gene0007.pc_insere_tag(pr_xml => pr_retxml, 
                                 pr_tag_pai => 'inf', 
                                 pr_posicao => vr_contador, 
                                 pr_tag_nova => 'dsfraude', 
                                 pr_tag_cont => rw_crapcbf.dsfraude,
                                 pr_des_erro => vr_dscritic);

          gene0007.pc_insere_tag(pr_xml => pr_retxml, 
                                 pr_tag_pai => 'inf', 
                                 pr_posicao => vr_contador, 
                                 pr_tag_nova => 'dtsolici', 
                                 pr_tag_cont => rw_crapcbf.dtsolici, 
                                 pr_des_erro => vr_dscritic);

          vr_contador := vr_contador + 1;                                
        END IF;
          
        -- Deve-se sair se o total de registros superar o total solicitado
        EXIT WHEN vr_contador > nvl(pr_nrregist,99999);

      END LOOP;     

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em CBRFRA: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || vr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END pc_consulta_cbrfra;
    
  -- rotina para inserir na tabela CRAPCBF
  PROCEDURE pc_insere_cbrfra( pr_cdcooper IN crapcop.cdcooper%type     -- Codigo da cooperativa
                             ,pr_tpfraude IN crapcbf.tpfraude%type     -- Tipo de fraude
                             ,pr_dsfraude IN crapcbf.dsfraude%type     -- Codigo de barras/cpf/cnpj
                             ,pr_dtsolici IN VARCHAR2                  -- Data de inicio do periodo
                             ,pr_xmllog   IN VARCHAR2                  -- XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER              -- Código da crítica
                             ,pr_dscritic OUT VARCHAR2                 -- Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType        -- Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2                 -- Nome do campo com erro                      
                             ,pr_des_erro OUT VARCHAR2) IS             -- Erros do processo                                            

 
      -- Selecionar os codigos de barras fraudulentos
      CURSOR cr_crapcbf IS
        SELECT dsfraude
          FROM crapcbf
         WHERE cdcooper = pr_cdcooper
           AND tpfraude = pr_tpfraude
           AND UPPER(dsfraude) = UPPER(pr_dsfraude);
      rw_crapcbf cr_crapcbf%ROWTYPE;
      
      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
      vr_contador      PLS_INTEGER := 0;    
    BEGIN

      -- Verifica se o codigo de barras fraudulento ja existe
      OPEN cr_crapcbf;
      FETCH cr_crapcbf INTO rw_crapcbf;
      IF cr_crapcbf%FOUND THEN
        CLOSE cr_crapcbf;
        vr_dscritic := 'Registro de suspeita de fraude ja existente!';
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_crapcbf;
      
      BEGIN
        INSERT INTO crapcbf
          (cdcooper, 
           tpfraude,
           dsfraude, 
           dtsolici)
         VALUES
          (pr_cdcooper,
           pr_tpfraude,
           pr_dsfraude,
           to_date(pr_dtsolici,'dd/mm/yyyy'));
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir na CRAPCBF: ' ||SQLERRM;
          RAISE vr_exc_saida;
      END;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || vr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em CBRFRA: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END pc_insere_cbrfra;

  -- rotina para excluir na tabela CRAPCBF
  PROCEDURE pc_exclui_cbrfra( pr_cdcooper IN crapcop.cdcooper%type     -- Codigo da cooperativa
                             ,pr_tpfraude IN crapcbf.tpfraude%type     -- Tipo de fraude
                             ,pr_dsfraude IN crapcbf.dsfraude%type     -- Codigo de barras
                             ,pr_xmllog   IN VARCHAR2                  -- XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER              -- Código da crítica
                             ,pr_dscritic OUT VARCHAR2                 -- Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType        -- Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2                 -- Nome do campo com erro                      
                             ,pr_des_erro OUT VARCHAR2) IS             -- Erros do processo                                            
 
      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
      vr_contador      PLS_INTEGER := 0;    
    BEGIN

      -- Efetua a exclusao do codigo de barras fraudulento
      BEGIN
        DELETE crapcbf
         WHERE cdcooper = pr_cdcooper
           AND tpfraude = pr_tpfraude
           AND UPPER(dsfraude) = UPPER(pr_dsfraude);
      EXCEPTION
        WHEN OTHERS THEN
          
          btch0001.pc_log_internal_exception(pr_cdcooper);  

          vr_dscritic := 'Erro ao excluir a CRAPCBF: ' ||SQLERRM;
          RAISE vr_exc_saida;
      END;
      
      -- Verifica se excluiu algo
      IF SQL%ROWCOUNT = 0 THEN
        vr_dscritic := 'Registro de suspeita de fraude inexistente!';
        RAISE vr_exc_saida;
      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || vr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN
        
        btch0001.pc_log_internal_exception(pr_cdcooper);
      
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em CBRFRA: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END pc_exclui_cbrfra;


  -- Procedure para consulta na tela CHQSIN
  PROCEDURE pc_consulta_chqsin( pr_cdbccxlt IN crapsch.cdbccxlt%TYPE     -- Codigo do banco que ocorreu o sinistro
                               ,pr_cdagectl IN crapsch.cdagectl%TYPE     -- Numero da agencia da Central
                               ,pr_nrctachq IN crapsch.nrctachq%TYPE     -- Numero da conta do cheque sinistrado.
                               ,pr_dtperini IN VARCHAR2                  -- Data de inicio do periodo
                               ,pr_dtfimper IN VARCHAR2                  -- Data de fim do periodo
                               ,pr_nriniseq IN PLS_INTEGER               -- Numero inicial do registro para enviar
                               ,pr_nrregist IN PLS_INTEGER               -- Numero de registros que deverao ser retornados
                               ,pr_xmllog   IN VARCHAR2                  -- XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER              -- Código da crítica
                               ,pr_dscritic OUT VARCHAR2                 -- Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType        -- Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2                 -- Nome do campo com erro                      
                               ,pr_des_erro OUT VARCHAR2) IS             -- Erros do processo                                            

 
      -- Selecionar os codigos de barras fraudulentos
      CURSOR cr_crapsch IS
        SELECT to_char(a.dtmvtolt,'dd/mm/yyyy') dtmvtolt,
               a.cdbccxlt,
               b.nmextbcc,
               a.cdagectl,
               c.nmrescop,
               a.nrctachq,
               d.nmprimtl,
               a.dsmotivo,
               count(1) over() retorno
          FROM crapass d,
               crapcop c,
               crapban b,
               crapsch a
         WHERE a.dtmvtolt BETWEEN nvl(to_date(pr_dtperini,'dd/mm/yyyy'),a.dtmvtolt) 
                              AND nvl(to_date(pr_dtfimper,'dd/mm/yyyy'),a.dtmvtolt)
           AND a.cdbccxlt = decode(pr_cdbccxlt,NULL,a.cdbccxlt,pr_cdbccxlt)
           AND a.cdagectl = decode(pr_cdagectl,NULL,a.cdagectl,pr_cdagectl)
           AND a.nrctachq = decode(pr_nrctachq,NULL,a.nrctachq,pr_nrctachq)
           AND b.cdbccxlt = a.cdbccxlt
           AND c.cdagectl = a.cdagectl
           AND d.cdcooper = c.cdcooper
           AND d.nrdconta = a.nrctachq
         ORDER BY a.dtmvtolt, a.cdbccxlt, a.cdagectl, a.nrctachq;
          
      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
      vr_contador      PLS_INTEGER := 1;    
      vr_posreg        PLS_INTEGER := 0;    
    BEGIN

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    
      -- Loop sobre os codigos de barras fraudulentos
      FOR rw_crapsch IN cr_crapsch LOOP
        -- Incrementa o contador de registros
        vr_posreg := vr_posreg + 1;

        -- Se for o primeiro registro, insere uma tag com o total de registros existentes no filtro
        IF vr_posreg = 1 THEN
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0          , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf'   , pr_posicao => 0          , pr_tag_nova => 'qtregist', pr_tag_cont => rw_crapsch.retorno, pr_des_erro => vr_dscritic);
        END IF;
          
        -- Enviar somente se a linha for superior a linha inicial
        IF nvl(pr_nriniseq,0) <= vr_posreg THEN
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0          , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtmvtolt', pr_tag_cont => rw_crapsch.dtmvtolt, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdbccxlt', pr_tag_cont => rw_crapsch.cdbccxlt, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmextbcc', pr_tag_cont => rw_crapsch.nmextbcc, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdagectl', pr_tag_cont => rw_crapsch.cdagectl, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmrescop', pr_tag_cont => rw_crapsch.nmrescop, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrctachq', pr_tag_cont => rw_crapsch.nrctachq, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmprimtl', pr_tag_cont => rw_crapsch.nmprimtl, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsmotivo', pr_tag_cont => rw_crapsch.dsmotivo, pr_des_erro => vr_dscritic);
          vr_contador := vr_contador + 1;                                
        END IF;
        
        -- Deve-se sair se o total de registros superar o total solicitado
        EXIT WHEN vr_contador > nvl(pr_nrregist,99999);
          
      END LOOP;     

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || vr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em CHQSIN: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END pc_consulta_chqsin;


  -- rotina para inserir na tabela CRAPSCH
  PROCEDURE pc_insere_chqsin( pr_dtmvtolt IN VARCHAR2                 -- data da ocorrencia do sinistro. 
                             ,pr_cdbccxlt IN crapsch.cdbccxlt%TYPE    -- codigo do banco que ocorreu o sinistro. 
                             ,pr_cdagectl IN crapsch.cdagectl%TYPE    -- numero da agencia da central. 
                             ,pr_nrctachq IN crapsch.nrctachq%TYPE    -- numero da conta do cheque sinistrado. 
                             ,pr_dsmotivo IN crapsch.dsmotivo%TYPE    -- motivo do sinistro. 
                             ,pr_cdoperad IN crapsch.cdoperad%TYPE    -- codigo do operador que efetuou o cadastro. 
                             ,pr_xmllog   IN VARCHAR2                 -- XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER             -- Código da crítica
                             ,pr_dscritic OUT VARCHAR2                -- Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType       -- Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2                -- Nome do campo com erro                      
                             ,pr_des_erro OUT VARCHAR2) IS            -- Erros do processo                                            

      -- Verificacao de existencia de banco
      CURSOR cr_crapban IS
        SELECT a.nmextbcc
          FROM crapban a
         WHERE cdbccxlt = pr_cdbccxlt;
      rw_crapban cr_crapban%ROWTYPE;

      -- Verificacao de existencia de agencia
      CURSOR cr_crapcop IS
        SELECT cdcooper
          FROM crapcop 
         WHERE cdagectl = pr_cdagectl;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Verificacao de existencia de conta
      CURSOR cr_crapass IS
        SELECT cdcooper
          FROM crapass
         WHERE cdcooper = rw_crapcop.cdcooper
           AND nrdconta = pr_nrctachq;
      rw_crapass cr_crapass%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
    BEGIN

      -- Verifica a existencia de banco
      OPEN cr_crapban;
      FETCH cr_crapban INTO rw_crapban;
      IF cr_crapban%NOTFOUND THEN
        CLOSE cr_crapban;
        vr_dscritic := 'Banco inexistente. Favor verificar!';
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_crapban;

      -- Verifica a existencia de agencia
      OPEN cr_crapcop;
      FETCH cr_crapcop INTO rw_crapcop;
      IF cr_crapcop%NOTFOUND THEN
        CLOSE cr_crapcop;
        vr_dscritic := 'Agencia inexistente. Favor verificar!';
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_crapcop;

      -- Verifica a existencia da conta
      OPEN cr_crapass;
      FETCH cr_crapass INTO rw_crapass;
      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;
        vr_dscritic := 'Conta inexistente. Favor verificar!';
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_crapass;

      BEGIN
        INSERT INTO crapsch
          (dtmvtolt,
           cdbccxlt,
           cdagectl,
           nrctachq,
           dsmotivo,
           cdoperad)
         VALUES
          (to_date(pr_dtmvtolt,'dd/mm/yyyy'),
           pr_cdbccxlt,
           pr_cdagectl,
           pr_nrctachq,
           pr_dsmotivo,
           pr_cdoperad);
      EXCEPTION
        WHEN dup_val_on_index THEN
          vr_dscritic := 'Extravio ja foi informado. Favor verificar!';
          RAISE vr_exc_saida;
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir na CRAPSCH: ' ||SQLERRM;
          RAISE vr_exc_saida;
      END;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || vr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em CHQSIN: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END pc_insere_chqsin;
  
  -- rotina para excluir na tabela CRAPSCH
  PROCEDURE pc_exclui_chqsin( pr_dtmvtolt IN VARCHAR2                  -- data da ocorrencia do sinistro. 
                             ,pr_cdbccxlt IN crapsch.cdbccxlt%TYPE     -- codigo do banco que ocorreu o sinistro.
                             ,pr_cdagectl IN crapsch.cdagectl%TYPE     -- numero da agencia da central. 
                             ,pr_nrctachq IN crapsch.nrctachq%TYPE     -- numero da conta do cheque sinistrado. 
                             ,pr_xmllog   IN VARCHAR2                  -- XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER              -- Código da crítica
                             ,pr_dscritic OUT VARCHAR2                 -- Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType        -- Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2                 -- Nome do campo com erro                      
                             ,pr_des_erro OUT VARCHAR2) IS             -- Erros do processo                                            
 
      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
      vr_contador      PLS_INTEGER := 0;    
    BEGIN

      -- Efetua a exclusao do sinistro de cheques da conta
      BEGIN
        DELETE crapsch
         WHERE dtmvtolt = to_date(pr_dtmvtolt,'dd/mm/yyyy')
           AND cdbccxlt = pr_cdbccxlt
           AND cdagectl = pr_cdagectl
           AND nrctachq = pr_nrctachq;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao excluir a CRAPSCH: ' ||SQLERRM;
          RAISE vr_exc_saida;
      END;
      
      -- Verifica se excluiu algo
      IF SQL%ROWCOUNT = 0 THEN
        vr_dscritic := 'Extravio de cheques inexistente!';
        RAISE vr_exc_saida;
      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || vr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em CHQSIN: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END pc_exclui_chqsin;

  -- Procedure para consulta na tela CHQSIN
  PROCEDURE pc_consulta_campo_chqsin( pr_nmcamp   IN VARCHAR2                  -- Nome do campo que esta sendo consultado
                                     ,pr_dspesq   IN VARCHAR2                  -- Chave de pesquisa
                                     ,pr_xmllog   IN VARCHAR2                  -- XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER              -- Código da crítica
                                     ,pr_dscritic OUT VARCHAR2                 -- Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType        -- Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2                 -- Nome do campo com erro                      
                                     ,pr_des_erro OUT VARCHAR2) IS             -- Erros do processo                                            

      -- Consulta o nome do banco
      CURSOR cr_crapban(pr_cdbccxlt crapban.cdbccxlt%TYPE) IS
        SELECT nmextbcc
          FROM crapban
         WHERE cdbccxlt = pr_cdbccxlt;
      rw_crapban cr_crapban%ROWTYPE;

      -- Consulta o nome da agencia
      CURSOR cr_crapcop(pr_cdagectl crapcop.cdagectl%TYPE) IS
        SELECT nmrescop
          FROM crapcop
         WHERE cdagectl = pr_cdagectl;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Busca o nome do associado
      CURSOR cr_crapass(pr_cdagectl crapcop.cdagectl%TYPE,
                        pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT b.nmprimtl
          FROM crapass b,
               crapcop a
         WHERE a.cdagectl = pr_cdagectl
           AND b.cdcooper = a.cdcooper
           AND b.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
         
      -- Buscar agencia do banco
      CURSOR cr_crapagb (pr_cdbccxlt IN crapagb.cddbanco%TYPE
                        ,pr_cdagectl IN crapagb.cdageban%TYPE) IS
      SELECT agb.nmageban
        FROM crapagb agb 
       WHERE agb.cddbanco = pr_cdbccxlt AND
            agb.cdageban = pr_cdagectl;
       rw_crapagb cr_crapagb%ROWTYPE;
      
      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);
      
      -- Variaveis gerais
      vr_nmcampo_ret   VARCHAR2(08);
      vr_retorno       VARCHAR2(100);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
      vr_contador      PLS_INTEGER := 0;    
    BEGIN

      -- Verifica o tipo de campo que se deseja consultar
      IF upper(pr_nmcamp) = 'CDBCCXLT' THEN -- Codigo do banco
        OPEN cr_crapban(pr_dspesq);
        FETCH cr_crapban INTO rw_crapban;
        IF cr_crapban%NOTFOUND THEN
          CLOSE cr_crapban;
          vr_dscritic := 'Banco inexistente. Favor verificar!';
          RAISE vr_exc_saida;
        END IF;
        CLOSE cr_crapban;
        vr_nmcampo_ret := 'nmextbcc';
        vr_retorno     := rw_crapban.nmextbcc;
        
      ELSIF upper(pr_nmcamp) = 'CDAGECTL' THEN -- Codigo da agencia
        OPEN cr_crapcop(pr_dspesq);
        FETCH cr_crapcop INTO rw_crapcop;
        IF cr_crapcop%NOTFOUND THEN
          CLOSE cr_crapcop;
          vr_dscritic := 'Agencia inexistente. Favor verificar!';
          RAISE vr_exc_saida;
        END IF;
        CLOSE cr_crapcop;
        vr_nmcampo_ret := 'nmrescop';
        vr_retorno     := rw_crapcop.nmrescop;
      
      ELSIF upper(pr_nmcamp) = 'NRCTACHQ' THEN -- Numero da conta
        OPEN cr_crapass(SUBSTR(pr_dspesq,1,instr(pr_dspesq,';')-1), --Numero da agencia
                        SUBSTR(pr_dspesq,instr(pr_dspesq,';')+1));  --Numero da conta
        FETCH cr_crapass INTO rw_crapass;
        IF cr_crapass%NOTFOUND THEN
          CLOSE cr_crapass;
          vr_dscritic := 'Conta inexistente. Favor verificar!';
          RAISE vr_exc_saida;
        END IF;
        CLOSE cr_crapass;
        vr_nmcampo_ret := 'nmprimtl';
        vr_retorno     := rw_crapass.nmprimtl;
      
      ELSIF upper(pr_nmcamp) = 'CDAGEBAN' THEN
        OPEN cr_crapagb(pr_cdbccxlt => SUBSTR(pr_dspesq,1,instr(pr_dspesq,';')-1) -- Codigo banco 
                       ,pr_cdagectl => SUBSTR(pr_dspesq,instr(pr_dspesq,';')+1)); -- Codigo agencia
          FETCH cr_crapagb INTO rw_crapagb;
          
          IF cr_crapagb%NOTFOUND THEN
            CLOSE cr_crapagb;
            vr_dscritic := 'Agencia inexistente. Favor verificar!';
            RAISE vr_exc_saida;
          END IF;
        CLOSE cr_crapagb; 
        vr_nmcampo_ret := 'nmrescop';
        vr_retorno     := rw_crapagb.nmageban;
        
      ELSE -- Se o parametro nao existe
        vr_dscritic := 'Campo informado na busca nao previsto!';
        RAISE vr_exc_saida;
      END IF;
      
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0          , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => vr_nmcampo_ret, pr_tag_cont => vr_retorno, pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || vr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em CHQSIN: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END pc_consulta_campo_chqsin;
  
    -- Procedure para consulta dos cheques sinistrados fora
    PROCEDURE pc_consulta_chqsin_fora(pr_cdbccxlt IN NUMBER               -- Codigo do banco que ocorreu o sinistro
                                     ,pr_cdagectl IN NUMBER               -- Numero da agencia da Central
                                     ,pr_nrctachq IN NUMBER               -- Numero da conta do cheque sinistrado.
                                     ,pr_dtperini IN VARCHAR2             -- Data de inicio do periodo
                                     ,pr_dtfimper IN VARCHAR2             -- Data de fim do periodo
                                     ,pr_nrcheque IN NUMBER               -- Numero do cheque
                                     ,pr_nriniseq IN PLS_INTEGER          -- Numero inicial do registro para enviar
                                     ,pr_nrregist IN PLS_INTEGER          -- Numero de registros que deverao ser retornados
                                     ,pr_xmllog   IN VARCHAR2             -- XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER         -- Código da crítica
                                     ,pr_dscritic OUT VARCHAR2            -- Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType   -- Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2            -- Nome do campo com erro                      
                                     ,pr_des_erro OUT VARCHAR2) IS  
                              
      -- Consultar cheques sinistrados fora
      CURSOR cr_tbchq IS
      SELECT tbchq.cdbanco,
             tbchq.cdagencia,
             tbchq.nrcontachq,
             tbchq.nrcheque,
             tbchq.dhinclusao,
             tbchq.cdoperad,                
             count(1) over() retorno
        FROM tbchq_sinistro_outrasif tbchq
       WHERE to_date(tbchq.dhinclusao) 
             BETWEEN nvl(to_date(pr_dtperini,'dd/mm/rrrr'),to_date(tbchq.dhinclusao))
             AND nvl(to_date(pr_dtfimper,'dd/mm/rrrr'),to_date(tbchq.dhinclusao))
       AND tbchq.cdbanco    = decode(pr_cdbccxlt,NULL,tbchq.cdbanco,pr_cdbccxlt)
       AND tbchq.cdagencia  = decode(pr_cdagectl,NULL,tbchq.cdagencia,pr_cdagectl)
       AND tbchq.nrcontachq = to_char(decode(pr_nrctachq,NULL,tbchq.nrcontachq,pr_nrctachq))
       AND tbchq.nrcheque   = decode(pr_nrcheque,NULL,tbchq.nrcheque,pr_nrcheque);
       rw_tbchq cr_tbchq%ROWTYPE;
          
       -- Buscar agencia do banco
       CURSOR cr_crapagb (pr_cdbccxlt IN crapagb.cddbanco%TYPE
                         ,pr_cdagectl IN crapagb.cdageban%TYPE) IS
       SELECT agb.nmageban
         FROM crapagb agb 
        WHERE agb.cddbanco = pr_cdbccxlt AND
              agb.cdageban = pr_cdagectl;
        rw_crapagb cr_crapagb%ROWTYPE;
       
       -- Buscar nome do associado
       CURSOR cr_crapass(pr_nrdconta IN crapass.nrdconta%TYPE) IS
       SELECT ass.nmprimtl
         FROM crapass ass
        WHERE ass.nrdconta = pr_nrdconta;
        rw_crapass cr_crapass%ROWTYPE;
       
       CURSOR cr_crapban(pr_cdbccxlt IN crapban.cdbccxlt%TYPE) IS
       SELECT ban.nmextbcc
         FROM crapban ban
        WHERE ban.cdbccxlt = pr_cdbccxlt;
        rw_crapban cr_crapban%ROWTYPE;
       
       -- Variável de críticas
       vr_cdcritic      crapcri.cdcritic%TYPE;
       vr_dscritic      VARCHAR2(1000);
            
       -- Tratamento de erros
       vr_exc_saida     EXCEPTION;
       vr_contador      PLS_INTEGER := 1;    
       vr_posreg        PLS_INTEGER := 0;  
           
     BEGIN
     
        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
            
        -- Loop sobre cheques sinistrados fora
        FOR rw_tbchq IN cr_tbchq LOOP
        
          -- Buscar agencia do banco
          OPEN cr_crapagb(pr_cdbccxlt => rw_tbchq.cdbanco
                         ,pr_cdagectl => rw_tbchq.cdagencia);
          FETCH cr_crapagb INTO rw_crapagb;
          
          IF cr_crapagb%NOTFOUND THEN
            CLOSE cr_crapagb;
            vr_dscritic := 'Agencia nao cadastrada - ' || TO_CHAR(rw_crapagb.nmageban);
            RAISE vr_exc_saida;
          END IF;

          CLOSE cr_crapagb;                        
          
          -- Buscar nome do banco
          OPEN cr_crapban(pr_cdbccxlt => rw_tbchq.cdbanco);
          FETCH cr_crapban INTO rw_crapban;
          
          IF cr_crapban%NOTFOUND THEN
            CLOSE cr_crapban;
            vr_dscritic := 'Banco nao encontrado!';
            RAISE vr_exc_saida;
          END IF;

          CLOSE cr_crapban;
          
          -- Incrementa o contador de registros
          vr_posreg := vr_posreg + 1;

          -- Se for o primeiro registro, insere uma tag com o total de registros existentes no filtro
          IF vr_posreg = 1 THEN
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0          , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf'   , pr_posicao => 0          , pr_tag_nova => 'qtregist', pr_tag_cont => rw_tbchq.retorno, pr_des_erro => vr_dscritic);
          END IF;
                  
          -- Enviar somente se a linha for superior a linha inicial
          IF nvl(pr_nriniseq,0) <= vr_posreg THEN
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0          , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtmvtolt', pr_tag_cont => to_char(rw_tbchq.dhinclusao,'dd/mm/yyyy'), pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdbccxlt', pr_tag_cont => rw_tbchq.cdbanco, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmextbcc', pr_tag_cont => rw_crapban.nmextbcc, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdagectl', pr_tag_cont => rw_tbchq.cdagencia, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmrescop', pr_tag_cont => rw_crapagb.nmageban, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrctachq', pr_tag_cont => rw_tbchq.nrcontachq, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmprimtl', pr_tag_cont => '', pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrcheque', pr_tag_cont => rw_tbchq.nrcheque, pr_des_erro => vr_dscritic);
            vr_contador := vr_contador + 1;                                
          END IF;
                
          -- Deve-se sair se o total de registros superar o total solicitado
          EXIT WHEN vr_contador > nvl(pr_nrregist,99999);
                  
        END LOOP;      
      EXCEPTION
        WHEN vr_exc_saida THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;

          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || 
                       vr_dscritic || '</Erro></Root>');

        WHEN OTHERS THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := 'Erro geral em pc_consulta_chqsin_fora: ' || SQLERRM;

          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || 
                       pr_dscritic || '</Erro></Root>');
                                 
     END pc_consulta_chqsin_fora;
     
  -- Rotina para inserir os cheques sinistrados fora
  PROCEDURE pc_insere_chqsin_fora(pr_cdbccxlt IN NUMBER             -- codigo do banco que ocorreu o sinistro. 
                                 ,pr_cdagectl IN NUMBER             -- numero da agencia da central. 
                                 ,pr_nrctachq IN VARCHAR2           -- numero da conta do cheque sinistrado. 
                                 ,pr_nrchqini IN NUMBER             -- numero cheque inicial 
                                 ,pr_nrchqfim IN NUMBER             -- numero cheque final
                                 ,pr_cdoperad IN varchar2           -- codigo do operador que efetuou o cadastro. 
                                 ,pr_xmllog   IN VARCHAR2                 -- XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER             -- Código da crítica
                                 ,pr_dscritic OUT VARCHAR2                -- Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType       -- Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2                -- Nome do campo com erro                      
                                 ,pr_des_erro OUT VARCHAR2) IS            -- Erros do processo                                            

      -- Verificacao de existencia de banco
      CURSOR cr_crapban IS
        SELECT a.nmextbcc
          FROM crapban a
         WHERE cdbccxlt = pr_cdbccxlt;
      rw_crapban cr_crapban%ROWTYPE;

     -- Buscar agencia do banco
     CURSOR cr_crapagb (pr_cdbccxlt IN crapagb.cddbanco%TYPE
                       ,pr_cdagectl IN crapagb.cdageban%TYPE) IS
     SELECT agb.nmageban
       FROM crapagb agb 
      WHERE agb.cddbanco = pr_cdbccxlt AND
            agb.cdageban = pr_cdagectl;
      rw_crapagb cr_crapagb%ROWTYPE;     

      vr_nrcheque      NUMBER;
      
      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
    BEGIN

      -- Verifica a existencia de banco
      OPEN cr_crapban;
      FETCH cr_crapban INTO rw_crapban;
      IF cr_crapban%NOTFOUND THEN
        CLOSE cr_crapban;
        vr_dscritic := 'Banco inexistente. Favor verificar!';
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_crapban;
      
      -- Buscar agencia do banco
      OPEN cr_crapagb(pr_cdbccxlt => pr_cdbccxlt
                     ,pr_cdagectl => pr_cdagectl);
      FETCH cr_crapagb INTO rw_crapagb;
          
      IF cr_crapagb%NOTFOUND THEN
        CLOSE cr_crapagb;
        vr_dscritic := 'Agencia nao cadastrada - ' || TO_CHAR(rw_crapagb.nmageban);
        RAISE vr_exc_saida;
      END IF;

      CLOSE cr_crapagb;       

      FOR vr_nrcheque IN pr_nrchqini..pr_nrchqfim LOOP
        BEGIN
          INSERT INTO tbchq_sinistro_outrasif
            (cdbanco, 
             cdagencia, 
             nrcontachq, 
             nrcheque, 
             dhinclusao, 
             cdoperad)       
           VALUES
            (pr_cdbccxlt,
             pr_cdagectl,
             pr_nrctachq,
             vr_nrcheque,
             SYSDATE,
             pr_cdoperad);
        EXCEPTION
          WHEN dup_val_on_index THEN
            vr_dscritic := 'Cheque ' || to_char(vr_nrcheque) || ' ja foi inserido. Favor verificar!';
            RAISE vr_exc_saida;
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir na pc_insere_chqsin_fora: ' ||SQLERRM;
            RAISE vr_exc_saida;
        END;
      END LOOP;

      COMMIT;
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || vr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em CHQSIN: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END pc_insere_chqsin_fora;
  
  -- Rotina para excluir os cheques sinistrados fora
  PROCEDURE pc_exclui_chqsin_fora(pr_xmllog   IN VARCHAR2                  -- XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER              -- Código da crítica
                                 ,pr_dscritic OUT VARCHAR2                 -- Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType        -- Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2                 -- Nome do campo com erro                      
                                 ,pr_des_erro OUT VARCHAR2) IS             -- Erros do processo                                            
 
      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
      vr_contador      PLS_INTEGER := 0;    
  
      -- Variáveis para tratamento do XML
      vr_node_list xmldom.DOMNodeList;
      vr_parser xmlparser.Parser;
      vr_doc xmldom.DOMDocument;
      vr_lenght NUMBER;
      vr_node_name VARCHAR2(100);
      vr_item_node xmldom.DOMNode;
      -- Arq XML
      vr_xmltype sys.xmltype;
  
      vr_tab_chqfora typ_tab_chqfora;
      
      -- VARIÁVEIS
      vr_cdcooper    NUMBER;
      vr_nmdatela    varchar2(25);
      vr_nmeacao     varchar2(25);
      vr_cdagenci    varchar2(25);
      vr_nrdcaixa    varchar2(25);
      vr_idorigem    varchar2(25);
      vr_cdoperad    varchar2(25);
      
      vr_id_acesso PLS_INTEGER           := 0;
      
      vr_teste VARCHAR2(10000);
      
      -- Retornar o valor do nodo tratando casos nulos
      FUNCTION fn_extract(pr_nodo  VARCHAR2) RETURN VARCHAR2 IS
        
      BEGIN
        -- Extrai e retorna o valor... retornando null em caso de erro ao ler
        RETURN pr_retxml.extract(pr_nodo).getstringval();
      EXCEPTION
        WHEN OTHERS THEN
          RETURN NULL;
      END;
      
    BEGIN

      -- Inicioando Varredura do XML.
      BEGIN

          -- Inicializa variavel
          vr_id_acesso := 0;

          vr_xmltype := pr_retxml;

          -- Faz o parse do XMLTYPE para o XMLDOM e libera o parser ao fim
          vr_parser := xmlparser.newParser;
          xmlparser.parseClob(vr_parser,vr_xmltype.getClobVal());
          vr_doc := xmlparser.getDocument(vr_parser);
          xmlparser.freeParser(vr_parser);

          -- Faz o get de toda a lista de elementos
          vr_node_list := xmldom.getElementsByTagName(vr_doc, '*');
          vr_lenght := xmldom.getLength(vr_node_list);
          
          -- Percorrer os elementos
          FOR i IN 0..vr_lenght LOOP
             -- Pega o item
             vr_item_node := xmldom.item(vr_node_list, i);            
             
             -- Captura o nome do nodo
             vr_node_name := xmldom.getNodeName(vr_item_node);
             -- Verifica qual nodo esta sendo lido
             IF vr_node_name IN ('Root') THEN
                CONTINUE; -- Descer para o próximo filho
             ELSIF vr_node_name IN ('Dados') THEN
                CONTINUE; -- Descer para o próximo filho
             ELSIF vr_node_name IN ('ChequesFora') THEN
                CONTINUE; -- Descer para o próximo filho
             ELSIF vr_node_name IN ('Itens') THEN
                CONTINUE; -- Descer para o próximo filho
             ELSIF vr_node_name = 'cddbanco' THEN                
                vr_id_acesso := vr_id_acesso + 1;
                vr_tab_chqfora(vr_id_acesso).cdbanco := TRIM(xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node)));
                CONTINUE;
             ELSIF vr_node_name = 'cdagenci' THEN
                IF TRIM(xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node))) = 0 THEN
                   CONTINUE;
                END IF;                
                vr_tab_chqfora(vr_id_acesso).cdagectl := TRIM(xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node)));
                CONTINUE;
             ELSIF vr_node_name = 'nrctachq' THEN
                vr_tab_chqfora(vr_id_acesso).nrcontachq := TRIM(xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node)));
                CONTINUE;
             ELSIF vr_node_name = 'nrcheque' THEN
                vr_tab_chqfora(vr_id_acesso).nrcheque := TRIM(xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node)));
                CONTINUE;             
             ELSE
                CONTINUE; -- Descer para o próximo filho
             END IF;         
          END LOOP;
      EXCEPTION
         WHEN OTHERS THEN
            pr_cdcritic := 0;
            pr_dscritic := ' Erro na leitura do XML. Rotina pc_exclui_chqsin_fora: '||SQLERRM;
            RAISE vr_exc_saida;
      END;      
     
      -- Criando os acessos para o perfil informado
      vr_id_acesso := vr_tab_chqfora.FIRST(); -- Posiciona no primeiro registro

      WHILE vr_id_acesso IS NOT NULL LOOP

        -- Efetua a exclusao dos cheques sinistrados fora
        BEGIN
          DELETE tbchq_sinistro_outrasif tbchq
           WHERE tbchq.cdbanco    = vr_tab_chqfora(vr_id_acesso).cdbanco
             AND tbchq.cdagencia  = vr_tab_chqfora(vr_id_acesso).cdagectl 
             AND tbchq.nrcontachq = vr_tab_chqfora(vr_id_acesso).nrcontachq
             AND tbchq.nrcheque   = vr_tab_chqfora(vr_id_acesso).nrcheque;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao excluir a tbchq_sinistro_outrasif: ' ||SQLERRM;
            RAISE vr_exc_saida;
        END;     
       
        -- Proximo registro
        vr_id_acesso:= vr_tab_chqfora.NEXT(vr_id_acesso); 
      END LOOP;
            
      COMMIT; 
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || vr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em CHQSIN: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END pc_exclui_chqsin_fora;
  
  -- Job para realizar limpeza automatica de cheques
  procedure pc_job_limpeza_chqsin is
 
    -- Cursor para limpeza dos registros
    cursor cr_limpeza_chqsin is
    select sch.rowid
         , 'Registro de sinistro de cheque deletado. --->' ||
           ' dtmvtolt: ' || to_char(sch.dtmvtolt,'dd/mm/yyyy') ||
           ' cdbccxlt: ' || sch.cdbccxlt ||
           ' cdagectl: ' || sch.cdagectl ||
           ' nrctachq: ' || sch.nrctachq ||
           ' dsmotivo: ' || sch.dsmotivo ||
           ' cdoperad: ' || sch.cdoperad descricao_log
      from crapsch sch
         , crapcop cop
         , crapass ass
         , crapdat dat
         , crapprm prm
     where prm.cdacesso = 'JOB_LIMPEZA_CHQSIN'
       and dat.cdcooper = cop.cdcooper
       -- Registros com mais de 180 dias (antigos)
       -- Alteracao de regra pode ser feito por um update       
       and prm.dsvlrprm < (dat.dtmvtolt - sch.dtmvtolt) 
       and cop.cdagectl = sch.cdagectl
       and ass.cdcooper = cop.cdcooper
       and ass.nrdconta = sch.nrctachq;     

    -- Variável de críticas
    vr_cdcritic      crapcri.cdcritic%type;
    vr_dscritic      varchar2(4000);

    -- Tratamento de erros
    vr_exc_saida     exception;
    
    -- Variaveis gerais
    vr_nmprogra tbgen_prglog.cdprograma%type := 'JBCOBR_LIMPEZA_CHQSIN';
    vr_idprglog tbgen_prglog.idprglog%type := 0; 
      
  begin
    
    -- Gera log no início da execução
    pc_log_programa(pr_dstiplog   => 'I'         
                   ,pr_cdprograma => vr_nmprogra 
                   ,pr_cdcooper   => 0
                   ,pr_tpexecucao => 2
                   ,pr_idprglog   => vr_idprglog);  

    -- Loop para limpeza dos registros    
    for rw_limpeza_chqsin in cr_limpeza_chqsin loop
      
      -- Deletar registros
      begin
        delete
          from crapsch sch
         where sch.rowid = rw_limpeza_chqsin.rowid;
      exception
        when others then
          vr_dscritic := 'Erro ao deletar crapsch: '||
                         rw_limpeza_chqsin.rowid||' ---> '||sqlerrm;
          raise vr_exc_saida;
      end;

      -- Gravar backup do registro deletado
      cecred.pc_log_programa(pr_dstiplog      => 'O'
                            ,pr_cdprograma    => vr_nmprogra
                            ,pr_cdcooper      => 0
                            ,pr_tpexecucao    => 2 
                            ,pr_tpocorrencia  => 4
                            ,pr_cdcriticidade => 0
                            ,pr_cdmensagem    => 0
                            ,pr_dsmensagem    => rw_limpeza_chqsin.descricao_log
                            ,pr_idprglog      => vr_idprglog);      
							
      commit;							
                            
    end loop;
    
    -- Gera log no início da execução
    pc_log_programa(pr_dstiplog   => 'F'         
                   ,pr_cdprograma => vr_nmprogra 
                   ,pr_cdcooper   => 0
                   ,pr_tpexecucao => 2    
                   ,pr_flgsucesso => 1
                   ,pr_idprglog   => vr_idprglog);      
      
    commit;
      
  exception
    
    when vr_exc_saida then

      -- Registrar erro de execucao
      cecred.pc_log_programa(pr_dstiplog      => 'E' 
                            ,pr_cdprograma    => vr_nmprogra
                            ,pr_cdcooper      => 0
                            ,pr_tpexecucao    => 2
                            ,pr_tpocorrencia  => 2   
                            ,pr_cdcriticidade => 3   
                            ,pr_cdmensagem    => 0
                            ,pr_dsmensagem    => vr_dscritic
                            ,pr_idprglog      => vr_idprglog);
                            
      rollback;                            

    when others then
      
      -- Erro nao tratado
      vr_dscritic := vr_nmprogra||': erro geral não tratado ---> '||sqlerrm;
    
      -- Registrar erro de execucao
      cecred.pc_log_programa(pr_dstiplog      => 'E' 
                            ,pr_cdprograma    => vr_nmprogra
                            ,pr_cdcooper      => 0
                            ,pr_tpexecucao    => 2
                            ,pr_tpocorrencia  => 2   
                            ,pr_cdcriticidade => 3   
                            ,pr_cdmensagem    => 0
                            ,pr_dsmensagem    => vr_dscritic
                            ,pr_idprglog      => vr_idprglog);
                            
      rollback;     
      
  end pc_job_limpeza_chqsin; 

END cobr0003;
/
