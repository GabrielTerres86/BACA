CREATE OR REPLACE PACKAGE CECRED.TELA_HCONVE IS

  type typ_dados_futuros is record (cdcooper craplau.cdcooper%type
                                   ,nrdocmto craplau.nrdocmto%type
                                   ,nrdconta craplau.nrdconta%type
                                   ,vllanaut craplau.vllanaut%type);
  type typ_tab_futuros is table of typ_dados_futuros index by binary_integer;

  
  procedure pc_conv_homologa_faturas_web (pr_cdconven   in gnconve.cdconven%type
                                         ,pr_xmllog     in varchar2
                                         ,pr_cdcritic  out pls_integer
                                         ,pr_dscritic  out varchar2
                                         ,pr_retxml in out nocopy XMLType
                                         ,pr_nmdcampo  out varchar2    
                                         ,pr_des_erro  out varchar2);
                                         
  procedure pc_conv_homologa_faturas (pr_cdcooper  in craplft.cdcooper%type
                                     ,pr_cdconven  in gnconve.cdconven%type
                                     ,pr_dtmvtolt  in crapdat.dtmvtolt%type
                                     ,pr_cdhiscxa  in gnconve.cdhiscxa%type
                                     ,pr_flgcvuni  in gnconve.flgcvuni%type
                                     ,pr_cdcritic out pls_integer
                                     ,pr_dscritic out varchar);
                                     
  procedure pc_limpar_homologa_faturas (pr_cdconven   in gnconve.cdconven%type
                                       ,pr_xmllog     in varchar2
                                       ,pr_cdcritic  out pls_integer
                                       ,pr_dscritic  out varchar2
                                       ,pr_retxml in out nocopy XMLType
                                       ,pr_nmdcampo  out varchar2    
                                       ,pr_des_erro  out varchar2);

  procedure pc_conv_autori_de_debito_web (pr_cdconven   in gnconve.cdconven%type
                                         ,pr_xmllog     in varchar2
                                         ,pr_cdcritic  out pls_integer
                                         ,pr_dscritic  out varchar2
                                         ,pr_retxml in out nocopy XMLType
                                         ,pr_nmdcampo  out varchar2    
                                         ,pr_des_erro  out varchar2);
                                         

  procedure pc_conv_autori_de_debito (pr_cdcooper  in crapatr.cdcooper%type
                                     ,pr_cdconven  in gnconve.cdconven%type
                                     ,pr_dtmvtolt  in crapdat.dtmvtolt%type
                                     ,pr_cdcritic out pls_integer
                                     ,pr_dscritic out varchar);
                                     
  procedure pc_limpar_autori_de_debito (pr_cdconven   in gnconve.cdconven%type
                                       ,pr_xmllog     in varchar2
                                       ,pr_cdcritic  out pls_integer
                                       ,pr_dscritic  out varchar2
                                       ,pr_retxml in out nocopy XMLType
                                       ,pr_nmdcampo  out varchar2    
                                       ,pr_des_erro  out varchar2);        
                                     
  procedure pc_conv_importa_arquivos_web (pr_dsarquiv   IN VARCHAR2            
                                         ,pr_dsdireto   IN VARCHAR2            
                                         ,pr_xmllog     in varchar2
                                         ,pr_cdcritic  out pls_integer
                                         ,pr_dscritic  out varchar2
                                         ,pr_retxml in out nocopy XMLType
                                         ,pr_nmdcampo  out varchar2    
                                         ,pr_des_erro  out varchar2);
                                         
  procedure pc_conv_importa_arquivos (pr_cdcooper   in crapatr.cdcooper%type
                                     ,pr_dsarquiv   IN VARCHAR2            --> Informações do arquivo
                                     ,pr_dsdireto   IN VARCHAR2            --> Informações do diretório do arquivo
                                     ,pr_cdhisdeb   in gnconve.cdhisdeb%type
                                     ,pr_cdconven   in gnconve.cdconven%type
                                     ,pr_flgcvuni   in gnconve.flgcvuni%type
                                     ,pr_dtmvtolt   in crapdat.dtmvtolt%type
                                     ,pr_dtmvtopr   in crapdat.dtmvtopr%type
                                     ,pr_dtmvtoan   in crapdat.dtmvtoan%type
                                     ,pr_retxml in out nocopy XMLType
                                     ,pr_cdcritic  out pls_integer
                                     ,pr_dscritic  out varchar);

  procedure pc_unifica_arq_449 (pr_cdcooper   in gnconve.cdcooper%type
                               ,pr_cdconven   in gnconve.cdconven%type
                               ,pr_dtmvtolt   in crapdat.dtmvtolt%type
                               ,pr_tpdcontr   in gncvuni.tpdcontr%type
                               ,pr_nmarquiv  out varchar2
                               ,pr_cdcritic  out pls_integer
                               ,pr_dscritic  out varchar2);
                            
  procedure pc_popular_opcao_h (pr_xmllog     in varchar2
                               ,pr_cdcritic  out pls_integer
                               ,pr_dscritic  out varchar2
                               ,pr_retxml in out nocopy XMLType
                               ,pr_nmdcampo  out varchar2    
                               ,pr_des_erro  out varchar2);
 
  procedure pc_hist_lupa_opcao_h (pr_cdhistor   IN craphis.cdhistor%TYPE
                                 ,pr_dsexthst   IN craphis.dsexthst%TYPE
                                 ,pr_nrregist   in integer                                 
                                 ,pr_nriniseq   in integer      
                                 ,pr_xmllog     in varchar2
                                 ,pr_cdcritic  out pls_integer
                                 ,pr_dscritic  out varchar2
                                 ,pr_retxml in out nocopy XMLType
                                 ,pr_nmdcampo  out varchar2    
                                 ,pr_des_erro  out varchar2);                     

  procedure pc_criar_historico_web (pr_hisconv1   in craphis.cdhistor%type
                                   ,pr_hisrefe1   in craphis.cdhistor%type
                                   ,pr_nmabrev1   in craphis.dshistor%type
                                   ,pr_nmexten1   in craphis.dsexthst%type 
                                   ,pr_hisconv2   in craphis.cdhistor%type
                                   ,pr_hisrefe2   in craphis.cdhistor%type
                                   ,pr_nmabrev2   in craphis.dshistor%type
                                   ,pr_nmexten2   in craphis.dsexthst%type
                                   ,pr_xmllog     in varchar2
                                   ,pr_cdcritic  out pls_integer
                                   ,pr_dscritic  out varchar2
                                   ,pr_retxml in out nocopy XMLType
                                   ,pr_nmdcampo  out varchar2    
                                   ,pr_des_erro  out varchar2);

  procedure pc_criar_historico (pr_cdhisnov  in craphis.cdhistor%type
                               ,pr_cdhisref  in craphis.cdhistor%type
                               ,pr_nomabrev  in craphis.dshistor%type
                               ,pr_nmextens  in craphis.dsexthst%type 
                               ,pr_cdcritic out pls_integer
                               ,pr_dscritic out varchar2);
                               
  procedure pc_verifica_layout (pr_cdcooper   in craphis.cdcooper%type
                               ,pr_nmarquiv   in varchar2
                               ,pr_flgcvuni   in gnconve.flgcvuni%type
                               ,pr_retxml in out nocopy XMLType
                               ,pr_cdcritic  out pls_integer
                               ,pr_dscritic  out varchar2);

  procedure pc_trata_arq_exec (pr_cdcooper       in crapcop.cdcooper%type
                              ,pr_nmarquiv       in varchar2
                              ,pr_dtmvtolt       in crapdat.dtmvtolt%type
                              ,pr_dtmvtopr       in crapdat.dtmvtopr%type
                              ,pr_dtmvtoan       in crapdat.dtmvtoan%type
                              ,pr_dados_futuros out typ_tab_futuros                              
                              ,pr_cdcritic      out pls_integer
                              ,pr_dscritic      out varchar2);
                              
  PROCEDURE pc_busca_convenio (pr_cdconven   IN gnconve.cdconven%TYPE
                              ,pr_nmempres   IN gnconve.nmempres%TYPE
                              ,pr_nrregist   IN INTEGER                            
                              ,pr_nriniseq   IN INTEGER              
                              ,pr_xmllog     IN VARCHAR2             
                              ,pr_cdcritic  OUT PLS_INTEGER          
                              ,pr_dscritic  OUT VARCHAR2             
                              ,pr_retxml IN OUT NOCOPY XMLType       
                              ,pr_nmdcampo  OUT VARCHAR2             
                              ,pr_des_erro  OUT VARCHAR2) ;              

END TELA_HCONVE;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_HCONVE IS

  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_HCONVE
  --  Sistema  : Ayllos Web
  --  Autor    : Gabriel Marcos
  --  Data     : Outubro/2018                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas a tela HCONVE
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

  procedure pc_conv_homologa_faturas_web (pr_cdconven   in gnconve.cdconven%type
                                         ,pr_xmllog     in varchar2
                                         ,pr_cdcritic  out pls_integer
                                         ,pr_dscritic  out varchar2
                                         ,pr_retxml in out nocopy XMLType
                                         ,pr_nmdcampo  out varchar2    
                                         ,pr_des_erro  out varchar2) is

    ---------------------------------------------------------------------------
    --
    --  Programa : pc_conv_homologa_faturas_web
    --  Sistema  : Ayllos Web
    --  Autor    : Gabriel Marcos
    --  Data     : Outubro/2018                Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Objetivo  : Chamada web de homologacao de faturas
    --             
    --
    -- Alteracoes:
    --
    ---------------------------------------------------------------------------
    
    -- Busca parametros de saida da rotina
    cursor cr_crapprm (pr_cdcooper in crapprm.cdcooper%type) is
    select prm.dsvlrprm
      from crapprm prm
     where prm.cdcooper = pr_cdcooper
       and prm.cdacesso = 'PRM_HCONVE_CRPS385_OUT';
    rw_crapprm cr_crapprm%ROWTYPE;
    
    -- Busca registro na tabela de autorizacao de debito
    cursor cr_gnconve (pr_cdconven in gnconve.cdconven%type) is
    select gnc.cdhiscxa
         , gnc.cdconven
         , gnc.flgcvuni
      from gnconve gnc
     where gnc.cdconven = pr_cdconven;
    rw_gnconve cr_gnconve%rowtype; 

    -- Buscar data de movimentacao da cooperativa
    cursor cr_crapdat (pr_cdcooper in crapcop.cdcooper%type) is
    select dat.dtmvtolt
      from crapdat dat
     where dat.cdcooper = pr_cdcooper;
    rw_crapdat cr_crapdat%rowtype;
    
    -- Variaveis padrao                            
    vr_nmdatela  varchar2(100);                                  
    vr_nmeacao   varchar2(100);                                  
    vr_cdagenci  varchar2(100);                                  
    vr_nrdcaixa  varchar2(100);                                  
    vr_idorigem  varchar2(100);                                  
    vr_cdoperad  varchar2(100);  
    vr_dscritic  varchar2(10000);  
    vr_cdcritic  pls_integer;
    vr_cdcooper  crapcop.cdcooper%TYPE;  
    vr_nmarquiv  VARCHAR2(4000);
    vr_exc_saida exception;
    vr_des_reto VARCHAR2(3);
    --Tabelas de Memoria
    vr_tab_erro    gene0001.typ_tab_erro;
    
  begin

    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'HCONVE'
                              ,pr_action => null); 

    -- Extrai cooperativa do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Aborta em caso de erro
    if trim(vr_dscritic) is not null then
      raise vr_exc_saida;
    end if;

    -- Tratamento dos parametros informados
    if trim(pr_cdconven) is null then
      vr_dscritic := 'O código do convênio deve ser informado.';
      raise vr_exc_saida;
    end if;

    -- Busca codigo do historico
    open cr_gnconve (pr_cdconven);
    fetch cr_gnconve into rw_gnconve;
    
    -- Aborta se nao encontrar
    if cr_gnconve%notfound then
      close cr_gnconve;
      vr_dscritic := 'Convênio não encontrado.';
      raise vr_exc_saida;
    end if;
    
    close cr_gnconve;

    -- Busca variaveis de data
    open cr_crapdat (vr_cdcooper);
    fetch cr_crapdat into rw_crapdat;

    -- Aborta se nao encontrar
    if cr_crapdat%notfound then
      close cr_crapdat;
      vr_dscritic := 'Data da cooperativa não cadastrada.';
      raise vr_exc_saida;
    end if;
    
    close cr_crapdat;

    -- Chama procedure de homologacao
    pc_conv_homologa_faturas (pr_cdcooper => vr_cdcooper
                             ,pr_cdconven => pr_cdconven
                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                             ,pr_cdhiscxa => rw_gnconve.cdhiscxa
                             ,pr_flgcvuni => rw_gnconve.flgcvuni
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic); 
 
    -- Aborta em caso de erro
    if trim(vr_dscritic) is not null or nvl(vr_cdcritic,0) > 0 then
      raise vr_exc_saida;
    end if;

    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

    -- Convenio sem unificacao gera arquivo nas cooperativas
    if rw_gnconve.flgcvuni = 0 then
     
      -- Busca parametros de retorno da execucao do 387
      open cr_crapprm (vr_cdcooper);
      fetch cr_crapprm into rw_crapprm;
      
      -- Deve retornar critica se nao retornar
      -- o nome do arquivo
      if cr_crapprm%notfound then
        close cr_crapprm;
        vr_dscritic := 'Rotina não retornou nome do arquivo';
        raise vr_exc_saida;
      end if;

      close cr_crapprm;
    
      --Efetuar Copia do PDF
      gene0002.pc_efetua_copia_pdf (pr_cdcooper => vr_cdcooper     --> Cooperativa conectada
                                   ,pr_cdagenci => vr_cdagenci     --> Codigo da agencia para erros
                                   ,pr_nrdcaixa => vr_nrdcaixa     --> Codigo do caixa para erros
                                   ,pr_nmarqpdf => rw_crapprm.dsvlrprm     --> Arquivo PDF  a ser gerado                                 
                                   ,pr_des_reto => vr_des_reto     --> Saída com erro
                                   ,pr_tab_erro => vr_tab_erro);   --> tabela de erros 
                                   
      --Se ocorreu erro
      IF vr_des_reto <> 'OK' THEN
        
        --Se possui erro
        IF vr_tab_erro.COUNT > 0 THEN
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          vr_cdcritic:= 0;
          vr_dscritic:= 'Não foi possível efetuar a copia do arquivo para Intranet.';
        END IF;
        
        --Levantar Excecao  
        RAISE vr_exc_saida;
        
      END IF;  
      
      vr_nmarquiv:= SUBSTR(rw_crapprm.dsvlrprm,instr(rw_crapprm.dsvlrprm,'/',-1)+1);
      
      -- Insere as tags dos campos da PLTABLE de aplicações
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'flgvcuni', pr_tag_cont => rw_gnconve.flgcvuni, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'nmarqpdf', pr_tag_cont => vr_nmarquiv, pr_des_erro => vr_dscritic);
	    
    -- Central busca convenios com registros pendentes
    -- e gera arquivo unificado 
    elsif vr_cdcooper = 3 then

      -- Rotina que faz a unificacao dos arquivos
      pc_unifica_arq_449 (pr_cdcooper => vr_cdcooper
                         ,pr_cdconven => pr_cdconven
                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                         ,pr_tpdcontr => 1
                         ,pr_nmarquiv => vr_nmarquiv
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);
    
      -- Aborta em caso de erro
      if trim(vr_dscritic) is not null or nvl(vr_cdcritic,0) > 0 then
        raise vr_exc_saida;
      end if;
      
      -- Aborta se retorno e nulo
      if trim(vr_nmarquiv) is null then
        vr_dscritic := 'Erro ao unificar arquivo: nome vazio.';
        raise vr_exc_saida;
      end if;

      --Efetuar Copia do PDF
      gene0002.pc_efetua_copia_pdf (pr_cdcooper => vr_cdcooper     --> Cooperativa conectada
                                   ,pr_cdagenci => vr_cdagenci     --> Codigo da agencia para erros
                                   ,pr_nrdcaixa => vr_nrdcaixa     --> Codigo do caixa para erros
                                   ,pr_nmarqpdf => vr_nmarquiv     --> Arquivo PDF  a ser gerado                                 
                                   ,pr_des_reto => vr_des_reto     --> Saída com erro
                                   ,pr_tab_erro => vr_tab_erro);   --> tabela de erros 
                                   
      --Se ocorreu erro
      IF vr_des_reto <> 'OK' THEN
        
        --Se possui erro
        IF vr_tab_erro.COUNT > 0 THEN
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          vr_cdcritic:= 0;
          vr_dscritic:= 'Não foi possível efetuar a copia do arquivo para Intranet.';
        END IF;
        
        --Levantar Excecao  
        RAISE vr_exc_saida;
        
      END IF;  
      
      vr_nmarquiv:= SUBSTR(vr_nmarquiv,instr(vr_nmarquiv,'/',-1)+1);
      
      -- Insere as tags dos campos da PLTABLE de aplicações
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'flgvcuni', pr_tag_cont => rw_gnconve.flgcvuni, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'nmarqpdf', pr_tag_cont => vr_nmarquiv, pr_des_erro => vr_dscritic);

    end if;
    
    begin
      delete
        from crapprm prm
       where prm.nmsistem = 'CRED'
         and prm.cdacesso = 'PRM_HCONVE_CRPS385_OUT';
    exception
      when others then    
        -- Gerando a critica
        vr_dscritic := 'Erro ao deletar dados da tabela crapprm: '||sqlerrm;
        raise vr_exc_saida;        
    end;
    
    commit;
    
    pr_des_erro := 'OK';
    
  exception
  
    when vr_exc_saida then

      if vr_cdcritic <> 0 then
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      else
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      end if;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      rollback;
      
    when others then

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela TELA_HCONVE.pc_conv_homologa_faturas_web: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      rollback;
        
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper);

  end pc_conv_homologa_faturas_web;

  procedure pc_conv_homologa_faturas (pr_cdcooper  in craplft.cdcooper%type
                                     ,pr_cdconven  in gnconve.cdconven%type
                                     ,pr_dtmvtolt  in crapdat.dtmvtolt%type
                                     ,pr_cdhiscxa  in gnconve.cdhiscxa%type
                                     ,pr_flgcvuni  in gnconve.flgcvuni%type
                                     ,pr_cdcritic out pls_integer
                                     ,pr_dscritic out varchar) is

    ---------------------------------------------------------------------------
    --
    --  Programa : pc_conv_homologa_faturas
    --  Sistema  : Ayllos Web
    --  Autor    : Gabriel Marcos
    --  Data     : Outubro/2018                Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Objetivo  : Homologacao de faturas - rotina 385 - tabela craplft
    --             
    --
    -- Alteracoes:
    --
    ---------------------------------------------------------------------------
    
    -- Busca fatura na tabela especifica
    cursor cr_craplft (pr_cdcooper craplft.cdcooper%type
                      ,pr_cdhistor craplft.cdhistor%type
                      ,pr_dtmvtolt craplft.dtmvtolt%type) is
    select lft.dtmvtolt
         , lft.cdhistor
         , lft.insitfat
         , lft.rowid
      from craplft lft
     where lft.cdcooper        = pr_cdcooper
       and lft.cdhistor        = pr_cdhistor
       and lft.dtvencto        = pr_dtmvtolt
     order
        by lft.insitfat;
    rw_craplft cr_craplft%rowtype;
    
    -- Buscar lancamentos a serem unificados
    cursor cr_gncvuni (pr_cdconven gncvuni.cdconven%type) is
    select gnc.flgproce
      from gncvuni gnc
     where gnc.cdconven = pr_cdconven
     order
        by gnc.flgproce;
    rw_gncvuni cr_gncvuni%rowtype;
    
    -- Declaracao padrao de variaveis
    vr_dscritic  varchar2(1000);
    vr_database  varchar2(100);
    vr_exc_saida exception;
    vr_flgresta  pls_integer;
    vr_stprogra  pls_integer;
    vr_infimsol  pls_integer;
    vr_cdcritic  pls_integer;

  begin
    
    -- Busca ambiente conectado
    vr_database := GENE0001.fn_database_name;

    -- Nao permitido em ambiente de producao
    if instr(upper(vr_database),'P',1) > 0 then
      vr_dscritic := 'Ambiente não permite esta operação.';
      raise vr_exc_saida;
    end if;
    
    -- Gerar faturas a serem processadas
    if pr_cdcooper <> 3 then

      -- Busca fatura na tabela especifica
      open cr_craplft (pr_cdcooper
                      ,pr_cdhiscxa
                      ,pr_dtmvtolt);
      fetch cr_craplft into rw_craplft;
      
      -- Aborta se nao encontrar
      if cr_craplft%notfound then
        close cr_craplft;
        vr_dscritic := 'Nenhuma fatura foi encontrada no sistema.';
        raise vr_exc_saida;
      elsif rw_craplft.insitfat <> 1 then
       close cr_craplft;
        vr_dscritic := 'Este convênio não possui faturas a serem processadas.';
        raise vr_exc_saida;
      end if;
          
      close cr_craplft;
      
      -- Limpeza de variaveis para chamada da rotina
      begin        
        update craplft lft
           set lft.insitfat  = 2
         where lft.cdhistor <> rw_craplft.cdhistor
           and lft.dtmvtolt between (pr_dtmvtolt - 5) and pr_dtmvtolt;  
      exception        
        when others then
          -- Gerando a critica
          pr_dscritic := 'Erro ao atualizar dados da tabela craplft: '||sqlerrm;
          raise vr_exc_saida;
      end;

      -- Registra parametros para uso interno da rotina
      begin         
        insert 
          into crapprm (nmsistem
                       ,cdcooper
                       ,cdacesso
                       ,dstexprm
                       ,dsvlrprm)
        values        ('CRED'
                       ,pr_cdcooper
                       ,'PRM_HCONVE_CRPS385_IN'
                       ,'Parametro de entrada do Crps385, auxilia na homologacao dos convenios.'
                       ,pr_cdconven);
      exception
        when dup_val_on_index then
          update crapprm prm
             set prm.dsvlrprm = pr_cdconven
           where prm.cdcooper = pr_cdcooper
             and prm.cdacesso = 'PRM_HCONVE_CRPS385_IN';
        when others then          
          -- gerando a critica
          pr_dscritic := 'Erro ao inserir dados na tabela crapprm: '||sqlerrm;        
          raise vr_exc_saida;        
      end;

      -- Limpeza dos parametros de entrada
      begin
        delete
          from crapprm prm
         where prm.nmsistem = 'CRED'
           and prm.cdacesso = 'PRM_HCONVE_CRPS385_OUT';
      exception
        when others then    
          -- Gerando a critica
          vr_dscritic := 'Erro ao deletar dados da tabela crapprm: '||sqlerrm;
          raise vr_exc_saida;        
      end;

      -- Limpeza de variaveis para chamada da rotina
      begin           
        delete
          from gncvuni gnc
         where gnc.cdcooper = pr_cdcooper
           and gnc.cdconven = pr_cdconven
           and gnc.tpdcontr = 1
           and (gnc.dtmvtolt = pr_dtmvtolt or
                gnc.flgproce = 0);     
      exception            
        when others then
          -- Gerando a critica
          pr_dscritic := 'Erro ao deletar dados da tabela gncvuni: '||sqlerrm;
          raise vr_exc_saida;   
      end;

      -- Call the procedure
      pc_crps385(pr_cdcooper => pr_cdcooper
                ,pr_flgresta => vr_flgresta
                ,pr_stprogra => vr_stprogra
                ,pr_infimsol => vr_infimsol
                ,pr_cdcritic => vr_cdcritic
                ,pr_dscritic => vr_dscritic);
                       
      -- Aborta em caso de retorno com critica
      if nvl(vr_cdcritic,0) > 0 or trim(vr_dscritic) is not null then
        raise vr_exc_saida;
      end if;
      
      -- Limpeza dos parametros de entrada
      begin
        delete
          from crapprm prm
         where prm.cdcooper = pr_cdcooper
           and prm.nmsistem = 'CRED'
           and prm.cdacesso = 'PRM_HCONVE_CRPS385_IN';
      exception
        when others then    
          -- Gerando a critica
          vr_dscritic := 'Erro ao deletar dados da tabela crapprm: '||sqlerrm;
          raise vr_exc_saida;        
      end;
    
    -- Gera arquivo unificado
    else 

      -- Verifica se existem registros a processar
      open cr_gncvuni (pr_cdconven);
      fetch cr_gncvuni into rw_gncvuni;

      -- Aborta se nao encontrar
      if cr_gncvuni%notfound then
        close cr_gncvuni;
        vr_dscritic := 'Não foram encontrados lançamentos a serem unificados.';
        raise vr_exc_saida;
      elsif rw_gncvuni.flgproce = 1 then
        close cr_gncvuni;
        vr_dscritic := 'Não existem lançamentos pendentes a serem unificados.';
        raise vr_exc_saida;
      end if;

      close cr_gncvuni;
      
    end if;
    
    commit;
    
  exception
  
    when vr_exc_saida then

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

    when others then 
    
      pr_cdcritic := 0;
      pr_dscritic := 'Erro não tratado na TELA_HCONVE.pc_conv_homologa_faturas: '||sqlerrm;

  end pc_conv_homologa_faturas;

  procedure pc_limpar_homologa_faturas (pr_cdconven   in gnconve.cdconven%type
                                       ,pr_xmllog     in varchar2
                                       ,pr_cdcritic  out pls_integer
                                       ,pr_dscritic  out varchar2
                                       ,pr_retxml in out nocopy XMLType
                                       ,pr_nmdcampo  out varchar2    
                                       ,pr_des_erro  out varchar2) is
                                       
  ---------------------------------------------------------------------------
  --
  --  Programa : pc_limpar_homologa_faturas
  --  Sistema  : Ayllos Web
  --  Autor    : Gabriel Marcos
  --  Data     : Novembro/2018                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Chamada web do botao de limpeza das faturas
  --             
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

    -- Buscar data de movimentacao da cooperativa
    cursor cr_crapdat (pr_cdcooper in crapcop.cdcooper%type) is
    select dat.dtmvtolt
         , dat.dtmvtopr
      from crapdat dat
     where dat.cdcooper = pr_cdcooper;
    rw_crapdat cr_crapdat%rowtype;
      
    -- Busca registro na tabela de autorizacao de debito
    cursor cr_gnconve (pr_cdconven in gnconve.cdconven%type) is
    select gnc.cdhiscxa
         , gnc.cdconven
      from gnconve gnc
     where gnc.cdconven = pr_cdconven;
    rw_gnconve cr_gnconve%rowtype;   

    -- Variaveis padrao                            
    vr_nmdatela  varchar2(100);                                  
    vr_nmeacao   varchar2(100);                                  
    vr_cdagenci  varchar2(100);                                  
    vr_nrdcaixa  varchar2(100);                                  
    vr_idorigem  varchar2(100);                                  
    vr_cdoperad  varchar2(100);  
    vr_cdcooper  integer;
    vr_dscritic  varchar2(10000);  
    vr_cdcritic  pls_integer;
    vr_exc_saida exception;

  begin
    
    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'HCONVE'
                              ,pr_action => null); 

    -- Extrai cooperativa do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Aborta em caso de erro
    if trim(vr_dscritic) is not null then
      raise vr_exc_saida;
    end if;

    -- Busca variaveis de data
    open cr_crapdat (vr_cdcooper);
    fetch cr_crapdat into rw_crapdat;

    -- Aborta se nao encontrar
    if cr_crapdat%notfound then
      close cr_crapdat;
      vr_dscritic := 'Data da cooperativa não cadastrada.';
      raise vr_exc_saida;
    end if;
    
    close cr_crapdat;
    
    -- Buscar codigo de historico
    open cr_gnconve (pr_cdconven);
    fetch cr_gnconve into rw_gnconve;

    -- Aborta se nao encontrar
    if cr_gnconve%notfound then
      close cr_gnconve;
      vr_dscritic := 'Convênio não encontrado.';
      raise vr_exc_saida;
    end if;
    
    close cr_gnconve;

    -- Central faz limpeza de todas as cooperativas
    if vr_cdcooper = 3 then
    
      begin
        delete
          from craplft lft
         where lft.cdhistor = rw_gnconve.cdhiscxa
           and (lft.dtmvtolt = rw_crapdat.dtmvtolt or 
                lft.dtvencto = rw_crapdat.dtmvtolt);
      exception
        when others then
          vr_dscritic := 'Erro ao fazer limpeza de faturas: '||sqlerrm;
          raise vr_exc_saida;
      end;

    else

      begin
        -- Limpeza de registros da cooperativa
        delete
          from craplft lft
         where lft.cdcooper = vr_cdcooper
           and lft.cdhistor = rw_gnconve.cdhiscxa
           and (lft.dtmvtolt = rw_crapdat.dtmvtolt or 
                lft.dtvencto = rw_crapdat.dtmvtolt);
      exception
        when others then
          vr_dscritic := 'Erro ao fazer limpeza de faturas: '||sqlerrm;
          raise vr_exc_saida;
      end;

    end if;

    commit;
    
    pr_des_erro := 'OK';
  
  exception
  
    when vr_exc_saida then

      if vr_cdcritic <> 0 then
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      else
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      end if;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      rollback;
      
    when others then

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela TELA_HCONVE.pc_limpar_homologa_faturas: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      rollback;
        
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper);

  end pc_limpar_homologa_faturas;

  procedure pc_conv_autori_de_debito_web (pr_cdconven   in gnconve.cdconven%type
                                         ,pr_xmllog     in varchar2
                                         ,pr_cdcritic  out pls_integer
                                         ,pr_dscritic  out varchar2
                                         ,pr_retxml in out nocopy XMLType
                                         ,pr_nmdcampo  out varchar2    
                                         ,pr_des_erro  out varchar2) is

    ---------------------------------------------------------------------------
    --
    --  Programa : pc_conv_autori_de_debito_web
    --  Sistema  : Ayllos Web
    --  Autor    : Gabriel Marcos
    --  Data     : Outubro/2018                Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Objetivo  : Chamada web de autorizacao de debitos
    --             
    --
    -- Alteracoes:
    --
    ---------------------------------------------------------------------------
    
    -- Busca parametros de saida da rotina
    cursor cr_crapprm (pr_cdcooper in crapprm.cdcooper%type) is
    select prm.dsvlrprm
      from crapprm prm
     where prm.cdcooper = pr_cdcooper
       and prm.cdacesso = 'PRM_HCONVE_CRPS386_OUT';
    rw_crapprm cr_crapprm%ROWTYPE;
    
    -- Busca registro na tabela de autorizacao de debito
    cursor cr_gnconve (pr_cdconven in gnconve.cdconven%type) is
    select gnc.flgcvuni
      from gnconve gnc
     where gnc.cdconven = pr_cdconven;
    rw_gnconve cr_gnconve%rowtype; 
    
    -- Buscar data de movimentacao da cooperativa
    cursor cr_crapdat (pr_cdcooper in crapcop.cdcooper%type) is
    select dat.dtmvtolt
      from crapdat dat
     where dat.cdcooper = pr_cdcooper;
    rw_crapdat cr_crapdat%rowtype;
    
    -- Variaveis padrao                            
    vr_nmdatela  varchar2(100);                                  
    vr_nmeacao   varchar2(100);                                  
    vr_cdagenci  varchar2(100);                                  
    vr_nrdcaixa  varchar2(100);                                  
    vr_idorigem  varchar2(100);                                  
    vr_cdoperad  varchar2(100);  
    vr_dscritic  varchar2(10000);  
    vr_cdcritic  pls_integer;
    vr_cdcooper  integer;  
    vr_nmarquiv  VARCHAR2(4000);
    vr_exc_saida exception;
    
    vr_des_reto VARCHAR2(3);
    --Tabelas de Memoria
    vr_tab_erro    gene0001.typ_tab_erro;
    
  begin

    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'HCONVE'
                              ,pr_action => null); 

    -- Extrai cooperativa do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Aborta em caso de erro
    if trim(vr_dscritic) is not null then
      raise vr_exc_saida;
    end if;

    -- Tratamento dos parametros informados
    if trim(pr_cdconven) is null then
      vr_dscritic := 'O número do convênio deve ser informado.';
      raise vr_exc_saida;
    end if;

    -- Busca codigo do historico
    open cr_gnconve (pr_cdconven);
    fetch cr_gnconve into rw_gnconve;
    
    -- Aborta se nao encontrar
    if cr_gnconve%notfound then
      close cr_gnconve;
      vr_dscritic := 'Convênio não encontrado.';
      raise vr_exc_saida;
    end if;
    
    close cr_gnconve;
    
    -- Busca variaveis de data
    open cr_crapdat (vr_cdcooper);
    fetch cr_crapdat into rw_crapdat;

    -- Aborta se nao encontrar
    if cr_crapdat%notfound then
      close cr_crapdat;
      vr_dscritic := 'Data da cooperativa não cadastrada.';
      raise vr_exc_saida;
    end if;
    
    close cr_crapdat;

    -- Fazer chamada de rotina
    pc_conv_autori_de_debito (pr_cdcooper => vr_cdcooper
                             ,pr_cdconven => pr_cdconven
                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
 
    -- Aborta em caso de erro
    if trim(vr_dscritic) is not null or nvl(vr_cdcritic,0) > 0 then
      raise vr_exc_saida;
    end if;

    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

    -- Convenios sem unificacao geram arquivos
    -- em qualquer cooperativa
    if rw_gnconve.flgcvuni = 0 then
           
      -- Busca parametros de retorno da execucao do 386
      open cr_crapprm (vr_cdcooper);
      fetch cr_crapprm into rw_crapprm;

      -- Deve retornar critica se nao retornar
      -- o nome do arquivo
      if cr_crapprm%notfound then
        close cr_crapprm;
        vr_dscritic := 'Rotina não retornou nome do arquivo';
        raise vr_exc_saida;
      end if;

      close cr_crapprm;

      --Efetuar Copia do PDF
      gene0002.pc_efetua_copia_pdf (pr_cdcooper => vr_cdcooper     --> Cooperativa conectada
                                   ,pr_cdagenci => vr_cdagenci     --> Codigo da agencia para erros
                                   ,pr_nrdcaixa => vr_nrdcaixa     --> Codigo do caixa para erros
                                   ,pr_nmarqpdf => rw_crapprm.dsvlrprm     --> Arquivo PDF  a ser gerado                                 
                                   ,pr_des_reto => vr_des_reto     --> Saída com erro
                                   ,pr_tab_erro => vr_tab_erro);   --> tabela de erros 
                                   
      --Se ocorreu erro
      IF vr_des_reto <> 'OK' THEN
        
        --Se possui erro
        IF vr_tab_erro.COUNT > 0 THEN
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          vr_cdcritic:= 0;
          vr_dscritic:= 'Não foi possível efetuar a copia do arquivo para Intranet.';
        END IF;
        
        --Levantar Excecao  
        RAISE vr_exc_saida;
        
      END IF;  
      
      vr_nmarquiv:= SUBSTR(rw_crapprm.dsvlrprm,instr(rw_crapprm.dsvlrprm,'/',-1)+1);

      -- Insere as tags dos campos da PLTABLE de aplicações
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'flgcvuni', pr_tag_cont => rw_gnconve.flgcvuni, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'nmarqpdf', pr_tag_cont => vr_nmarquiv, pr_des_erro => vr_dscritic);
      
    elsif vr_cdcooper = 3 then
      
      -- Rotina que faz a unificacao dos arquivos
      pc_unifica_arq_449 (pr_cdcooper => vr_cdcooper
                         ,pr_cdconven => pr_cdconven
                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                         ,pr_tpdcontr => 3
                         ,pr_nmarquiv => vr_nmarquiv
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);
         
      -- Aborta em caso de erro
      if trim(vr_dscritic) is not null or nvl(vr_cdcritic,0) > 0 then
        raise vr_exc_saida;
      end if;
      
      if trim(vr_nmarquiv) is null then
        vr_dscritic := 'Erro ao unificar arquivo: nome vazio.';
        raise vr_exc_saida;
      end if;

      --Efetuar Copia do PDF
      gene0002.pc_efetua_copia_pdf (pr_cdcooper => vr_cdcooper     --> Cooperativa conectada
                                   ,pr_cdagenci => vr_cdagenci     --> Codigo da agencia para erros
                                   ,pr_nrdcaixa => vr_nrdcaixa     --> Codigo do caixa para erros
                                   ,pr_nmarqpdf => vr_nmarquiv     --> Arquivo PDF  a ser gerado                                 
                                   ,pr_des_reto => vr_des_reto     --> Saída com erro
                                   ,pr_tab_erro => vr_tab_erro);   --> tabela de erros 
                                   
      --Se ocorreu erro
      IF vr_des_reto <> 'OK' THEN
        
        --Se possui erro
        IF vr_tab_erro.COUNT > 0 THEN
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          vr_cdcritic:= 0;
          vr_dscritic:= 'Não foi possível efetuar a copia do arquivo para Intranet.';
        END IF;
        
        --Levantar Excecao  
        RAISE vr_exc_saida;
        
      END IF;  
      
      vr_nmarquiv:= SUBSTR(vr_nmarquiv,instr(vr_nmarquiv,'/',-1)+1);

      -- Insere as tags dos campos da PLTABLE de aplicações
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'flgcvuni', pr_tag_cont => rw_gnconve.flgcvuni, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'nmarqpdf', pr_tag_cont => vr_nmarquiv, pr_des_erro => vr_dscritic);

    end if;

    begin
      delete
        from crapprm prm
       where prm.nmsistem = 'CRED'
         and prm.cdacesso = 'PRM_HCONVE_CRPS386_OUT';
    exception
      when others then    
        -- Gerando a critica
        vr_dscritic := 'Erro ao deletar dados da tabela crapprm: '||sqlerrm;
        raise vr_exc_saida;        
    end;

    commit;
    
    pr_des_erro := 'OK';
    
  exception
  
    when vr_exc_saida then

      if vr_cdcritic <> 0 then
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      else
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      end if;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      rollback;
      
    when others then

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela TELA_HCONVE.pc_conv_autori_de_debito_web: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      rollback;
        
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper);

  end pc_conv_autori_de_debito_web;

  procedure pc_conv_autori_de_debito (pr_cdcooper  in crapatr.cdcooper%type
                                     ,pr_cdconven  in gnconve.cdconven%type
                                     ,pr_dtmvtolt  in crapdat.dtmvtolt%type
                                     ,pr_cdcritic out pls_integer
                                     ,pr_dscritic out varchar) is

    ---------------------------------------------------------------------------
    --
    --  Programa : pc_conv_autori_de_debito
    --  Sistema  : Ayllos Web
    --  Autor    : Gabriel Marcos
    --  Data     : Outubro/2018                Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Objetivo  : Homologacao de aut. de debito  - rotina 386 - tabela crapatr
    --             
    --
    -- Alteracoes:
    --
    ---------------------------------------------------------------------------
      
    -- Busca registro na tabela de autorizacao de debito
    cursor cr_crapatr (pr_cdcooper in crapatr.cdcooper%type
                      ,pr_cdconven in gnconve.cdconven%type
                      ,pr_dtmvtolt in crapatr.dtiniatr%type
                      ,pr_dtmovini in crapatr.dtiniatr%type) is
    select 1
      from crapatr atr
         , gnconve gnc
     where atr.cdcooper = decode(pr_cdcooper,3,atr.cdcooper,pr_cdcooper)
       and (atr.dtiniatr = pr_dtmvtolt or
            atr.dtfimatr = pr_dtmvtolt or
            atr.dtinisus = pr_dtmvtolt or
            atr.dtfimsus between pr_dtmovini AND pr_dtmvtolt)
       and gnc.cdconven = pr_cdconven
       and atr.cdhistor = gnc.cdhisdeb;
    rw_crapatr cr_crapatr%rowtype;   
    
    -- Cursor principal do crps386
    cursor cr_cdconven (pr_cdcooper in gnconve.cdcooper%type
                       ,pr_cdconven in gnconve.cdconven%type) is
    select 1
      from craphis,
           crapcop,
           gnconve,
           gncvcop
     where gncvcop.cdcooper = pr_cdcooper 
       and gnconve.cdconven = pr_cdconven
       and gnconve.cdconven = gncvcop.cdconven
       and gnconve.flgativo = 1
       and gnconve.cdhisdeb > 0 -- Somente arq.integracao
       and gnconve.nmarqatu <> ' '
       and crapcop.cdcooper = gnconve.cdcooper
       and craphis.cdcooper = gncvcop.cdcooper
       and craphis.cdhistor = gnconve.cdhisdeb;
    rw_cdconven cr_cdconven%rowtype;
    
    -- Buscar lancamentos a serem unificados
    cursor cr_gncvuni (pr_cdconven gncvuni.cdconven%type) is
    select gnc.flgproce
      from gncvuni gnc
     where gnc.cdconven = pr_cdconven;
    rw_gncvuni cr_gncvuni%rowtype;

    -- Declaracao padrao de variaveis
    vr_dscritic  varchar2(1000);
    vr_database  varchar2(100);
    vr_exc_saida exception;
    vr_flgresta  pls_integer;
    vr_stprogra  pls_integer;
    vr_infimsol  pls_integer;
    vr_cdcritic  pls_integer;
    vr_dtmovini  date;
    
  begin

    -- Busca ambiente conectado
    vr_database := GENE0001.fn_database_name;

    -- Nao permitido em ambiente de producao
    if instr(upper(vr_database),'P',1) > 0 then 
      vr_dscritic := 'Ambiente não permite esta operação.';
      raise vr_exc_saida;
    end if;

    -- Antecipa verificacao principal do crps
    open cr_cdconven (pr_cdcooper
                     ,pr_cdconven);
    fetch cr_cdconven into rw_cdconven;
    
    -- Caso nao encontre retorna critica
    if cr_cdconven%notfound then
      close cr_cdconven;
      vr_dscritic := 'Este convênio não está ativo para este produto.';
      raise vr_exc_saida;
    end if;
    
    close cr_cdconven;

    -- Rotinas das cooperativas
    if pr_cdcooper <> 3 then

      -- Data anterior util
      vr_dtmovini := gene0005.fn_valida_dia_util(pr_cdcooper
                                                ,(pr_dtmvtolt - 1)
                                                ,'A'    
                                                ,TRUE   
                                                ,FALSE);
                                                
      -- Adiciona mais um 1 dia na data inicial, para pegar finais de semana e feriados
      vr_dtmovini := vr_dtmovini + 1;

      -- Busca autorizacao de debito
      open cr_crapatr (pr_cdcooper
                      ,pr_cdconven
                      ,pr_dtmvtolt
                      ,vr_dtmovini);
      fetch cr_crapatr into rw_crapatr;
    
      -- Aborta se nao encontrar
      if cr_crapatr%notfound then
        close cr_crapatr;  
        vr_dscritic := 'Autorização de débito nao encontrada.';
        raise vr_exc_saida;
      end if;
      
      close cr_crapatr;
    
      -- Disponibiliza variaveis para uso interno
      begin            
        insert
          into crapprm (nmsistem
                       ,cdcooper
                       ,cdacesso
                       ,dstexprm
                       ,dsvlrprm)
        values        ('CRED'
                       ,pr_cdcooper
                       ,'PRM_HCONVE_CRPS386_IN'
                       ,'Parametro de entrada do Crps386, auxilia na homologacao dos convenios.'
                       ,pr_cdconven);
      exception
        when dup_val_on_index then
          update crapprm prm
             set prm.dsvlrprm = pr_cdconven
           where prm.cdcooper = pr_cdcooper
             and prm.cdacesso = 'PRM_HCONVE_CRPS386_IN';         
        when others then     
          -- Gerando a critica
          vr_dscritic := 'Erro ao inserir dados na tabela crapprm: '||sqlerrm;
          raise vr_exc_saida;
      end;
      
      -- Limpeza dos parametros de entrada
      begin    
        delete 
          from crapprm prm
         where prm.cdcooper = pr_cdcooper
           and prm.nmsistem = 'CRED'
           and prm.cdacesso = 'PRM_HCONVE_CRPS386_OUT';
      exception      
        when others then             
          -- Gerando a critica
          vr_dscritic := 'Erro ao deletar dados da tabela crapprm: '||sqlerrm;
          raise vr_exc_saida;
      end;

      -- Limpeza de variaveis para chamada da rotina
      begin           
        delete
          from gncvuni gnc
         where gnc.cdcooper = pr_cdcooper
           and gnc.cdconven = pr_cdconven
           and gnc.tpdcontr = 3
           and gnc.dtmvtolt = pr_dtmvtolt;     
      exception            
        when others then
          -- Gerando a critica
          pr_dscritic := 'Erro ao deletar dados da tabela gncvuni: '||sqlerrm;
          raise vr_exc_saida;   
      end;
      
      -- Call the procedure
      pc_crps386(pr_cdcooper => pr_cdcooper
                ,pr_flgresta => vr_flgresta
                ,pr_stprogra => vr_stprogra
                ,pr_infimsol => vr_infimsol
                ,pr_cdcritic => vr_cdcritic
                ,pr_dscritic => vr_dscritic);
                        
      -- Aborta em caso de critica
      if trim(vr_dscritic) is not null then
        -- As criticas abaixo podem acabar retornando do programa
        -- porem nao significam erro na execucao do programa
        if vr_cdcritic in (657,696,748,905,982) then
          vr_cdcritic := 0;
          elsif instr(lower(trim(vr_dscritic)),'gncvuni',1,1) > 1 then
            vr_dscritic :=  'Erro nos registros de unificação, faça a limpeza através do Botão.';
        end if;
        raise vr_exc_saida;
      elsif vr_cdcritic not in (657,696,748,905,982) then
        raise vr_exc_saida;
      end if;

      -- Limpeza dos parametros de entrada
      begin    
        delete 
          from crapprm prm
         where prm.cdcooper = pr_cdcooper
           and prm.nmsistem = 'CRED'
           and prm.cdacesso = 'PRM_HCONVE_CRPS386_IN';
      exception      
        when others then             
          -- Gerando a critica
          vr_dscritic := 'Erro ao deletar dados da tabela crapprm: '||sqlerrm;
          raise vr_exc_saida;         
      end;

    else

      -- Busca convenios para unificar
      open cr_gncvuni (pr_cdconven);
      fetch cr_gncvuni into rw_gncvuni;

      -- Aborta se nao encontrar
      if cr_gncvuni%notfound then
        close cr_gncvuni;
        vr_dscritic := 'Não foram encontrados lançamentos a serem unificados.';
        raise vr_exc_saida;
      elsif rw_gncvuni.flgproce = 1 then
        close cr_gncvuni;
        vr_dscritic := 'Não existem lançamentos pendentes a serem unificados.';
        raise vr_exc_saida;
      end if;

      close cr_gncvuni;
      
    end if;

    commit;

  exception
  
    when vr_exc_saida then

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

    when others then 
        
      pr_cdcritic := 0;
      pr_dscritic := 'Erro não tratado na TELA_HCONVE.pc_conv_autori_de_debito: '||sqlerrm;

  end pc_conv_autori_de_debito;

  procedure pc_limpar_autori_de_debito (pr_cdconven   in gnconve.cdconven%type
                                       ,pr_xmllog     in varchar2
                                       ,pr_cdcritic  out pls_integer
                                       ,pr_dscritic  out varchar2
                                       ,pr_retxml in out nocopy XMLType
                                       ,pr_nmdcampo  out varchar2    
                                       ,pr_des_erro  out varchar2) is
                                       
  ---------------------------------------------------------------------------
  --
  --  Programa : pc_limpar_autori_de_debito
  --  Sistema  : Ayllos Web
  --  Autor    : Gabriel Marcos
  --  Data     : Outubro/2018                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Chamada web do botao de limpeza das autorizacoes de debito
  --             
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

    -- Buscar data de movimentacao da cooperativa
    cursor cr_crapdat (pr_cdcooper in crapcop.cdcooper%type) is
    select dat.dtmvtolt
         , dat.dtmvtopr
      from crapdat dat
     where dat.cdcooper = pr_cdcooper;
    rw_crapdat cr_crapdat%rowtype;
      
    -- Busca registro na tabela de autorizacao de debito
    cursor cr_gnconve (pr_cdconven in gnconve.cdconven%type) is
    select gnc.cdhisdeb
         , gnc.cdconven
      from gnconve gnc
     where gnc.cdconven = pr_cdconven;
    rw_gnconve cr_gnconve%rowtype;  

    -- Variaveis padrao                            
    vr_nmdatela  varchar2(100);                                  
    vr_nmeacao   varchar2(100);                                  
    vr_cdagenci  varchar2(100);                                  
    vr_nrdcaixa  varchar2(100);                                  
    vr_idorigem  varchar2(100);                                  
    vr_cdoperad  varchar2(100);  
    vr_cdcooper  integer;
    vr_dscritic  varchar2(10000);  
    vr_cdcritic  pls_integer;
    vr_exc_saida exception;
    vr_dtmovini  date;

  begin
    
    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'HCONVE'
                              ,pr_action => null); 

    -- Extrai cooperativa do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Aborta em caso de erro
    if trim(vr_dscritic) is not null then
      raise vr_exc_saida;
    end if;

    -- Busca variaveis de data
    open cr_crapdat (vr_cdcooper);
    fetch cr_crapdat into rw_crapdat;

    -- Aborta se nao encontrar
    if cr_crapdat%notfound then
      close cr_crapdat;
      vr_dscritic := 'Data da cooperativa não cadastrada.';
      raise vr_exc_saida;
    end if;
      
    close cr_crapdat;
      
    -- Buscar codigo de historico
    open cr_gnconve (pr_cdconven);
    fetch cr_gnconve into rw_gnconve;

    -- Aborta se nao encontrar
    if cr_gnconve%notfound then
      close cr_gnconve;
      vr_dscritic := 'Convênio não encontrado.';
      raise vr_exc_saida;
    end if;
      
    close cr_gnconve;
      
    -- Data anterior util
    vr_dtmovini := gene0005.fn_valida_dia_util(vr_cdcooper
                                              ,(rw_crapdat.dtmvtolt - 1)
                                              ,'A'    
                                              ,TRUE   
                                              ,FALSE);
    -- Adiciona mais um 1 dia na data inicial, para pegar finais de semana e feriados
    vr_dtmovini := vr_dtmovini + 1;

    -- Central faz limpeza de todas as cooperativas
    if vr_cdcooper = 3 then
      
      begin
        delete
          from crapatr atr
         where atr.cdhistor = rw_gnconve.cdhisdeb
           and (atr.dtiniatr = rw_crapdat.dtmvtolt or
                atr.dtfimatr = rw_crapdat.dtmvtolt or
                atr.dtinisus = rw_crapdat.dtmvtolt or
                atr.dtfimsus between vr_dtmovini AND 
                                     rw_crapdat.dtmvtolt);
      exception
        when others then
          vr_dscritic := 'Erro ao fazer limpeza de autorizações de débito: '||sqlerrm;
          raise vr_exc_saida;
      end;
      
    -- Cooperativas deletam apenas seus registros
    else
              
      begin
        delete
          from crapatr atr
         where atr.cdhistor = rw_gnconve.cdhisdeb
           and atr.cdcooper = vr_cdcooper
           and (atr.dtiniatr = rw_crapdat.dtmvtolt or
                atr.dtfimatr = rw_crapdat.dtmvtolt or
                atr.dtinisus = rw_crapdat.dtmvtolt or
                atr.dtfimsus between vr_dtmovini AND 
                                     rw_crapdat.dtmvtolt);
      exception
        when others then
          vr_dscritic := 'Erro ao fazer limpeza de autorizações de débito: '||sqlerrm;
          raise vr_exc_saida;
      end;

    end if;
    
    commit;
    
    pr_des_erro := 'OK';
  
  exception
  
    when vr_exc_saida then

      if vr_cdcritic <> 0 then
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      else
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      end if;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      rollback;
      
    when others then

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela TELA_HCONVE.pc_limpar_autori_de_debito: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      rollback;
        
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper);

  end pc_limpar_autori_de_debito;

  procedure pc_conv_importa_arquivos_web (pr_dsarquiv   IN VARCHAR2            --> Informações do arquivo
                                         ,pr_dsdireto   IN VARCHAR2            --> Informações do diretório do arquivo
                                         ,pr_xmllog     in varchar2
                                         ,pr_cdcritic  out pls_integer
                                         ,pr_dscritic  out varchar2
                                         ,pr_retxml in out nocopy XMLType
                                         ,pr_nmdcampo  out varchar2    
                                         ,pr_des_erro  out varchar2) is

    ---------------------------------------------------------------------------
    --
    --  Programa : pc_conv_importa_arquivos_web
    --  Sistema  : Ayllos Web
    --  Autor    : Gabriel Marcos
    --  Data     : Outubro/2018                Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Objetivo  : Chamada web da rotina pc_conv_importa_arquivos
    --             
    --
    -- Alteracoes:
    --
    ---------------------------------------------------------------------------
 
    -- Buscar data de movimentacao da cooperativa
    cursor cr_crapdat (pr_cdcooper in crapcop.cdcooper%type) is
    select dat.dtmvtolt
         , dat.dtmvtopr
         , dat.dtmvtoan
      from crapdat dat
     where dat.cdcooper = pr_cdcooper;
    rw_crapdat cr_crapdat%rowtype;

    -- Busca parametros de saida da rotina
    cursor cr_crapprm (pr_cdcooper in crapprm.cdcooper%type) is
    select prm.dsvlrprm
      from crapprm prm
     where prm.cdcooper = pr_cdcooper
       and prm.cdacesso = 'PRM_HCONVE_CRPS388_OUT';
    rw_crapprm cr_crapprm%ROWTYPE;
    
    -- Busca codigo do convenio
    cursor cr_cdconve (pr_nmarquiv in varchar2) is
    select gnc.cdconven
         , gnc.flgcvuni
         , gnc.cdhisdeb
      from gnconve gnc
     where upper(gnc.nmarqint) = upper(pr_nmarquiv);
    rw_cdconve cr_cdconve%rowtype;
    
    -- Variaveis padrao                            
    vr_nmdatela  varchar2(100);                                  
    vr_nmeacao   varchar2(100);                                  
    vr_cdagenci  varchar2(100);                                  
    vr_nrdcaixa  varchar2(100);                                  
    vr_idorigem  varchar2(100);                                  
    vr_cdoperad  varchar2(100);  
    vr_cdcooper  integer;
    vr_dscritic  varchar2(10000);  
    vr_cdcritic  pls_integer;
    vr_exc_saida exception;
    vr_exc_layout exception;
    vr_des_reto VARCHAR2(3);
    vr_nmarquiv  VARCHAR2(4000);
    --Tabelas de Memoria
    vr_tab_erro    gene0001.typ_tab_erro;

  begin

    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'HCONVE'
                              ,pr_action => null); 

    -- Extrai cooperativa do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Aborta em caso de erro
    if trim(vr_dscritic) is not null then
      raise vr_exc_saida;
    end if;

    -- Busca flag de unificacao
    open cr_cdconve (substr(pr_dsarquiv,7,6));
    fetch cr_cdconve into rw_cdconve;
    
    -- Aborta caso nao retorne dados
    if cr_cdconve%notfound then
      close cr_cdconve;
      vr_dscritic := 'Nome do arquivo está errado ou não foi criado.';
      raise vr_exc_saida;
    end if;
    
    close cr_cdconve;

    -- Busca variaveis de data
    open cr_crapdat (vr_cdcooper);
    fetch cr_crapdat into rw_crapdat;

    -- Aborta se nao encontrar
    if cr_crapdat%notfound then
      close cr_crapdat;
      vr_dscritic := 'Data da cooperativa não cadastrada.';
      raise vr_exc_saida;
    end if;
    
    close cr_crapdat;
    
    -- Call the procedure
    pc_conv_importa_arquivos (pr_cdcooper => vr_cdcooper
                             ,pr_dsarquiv => pr_dsarquiv
                             ,pr_dsdireto => pr_dsdireto
                             ,pr_cdhisdeb => rw_cdconve.cdhisdeb
                             ,pr_cdconven => rw_cdconve.cdconven
                             ,pr_flgcvuni => rw_cdconve.flgcvuni
                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                             ,pr_dtmvtopr => rw_crapdat.dtmvtopr
                             ,pr_dtmvtoan => rw_crapdat.dtmvtoan
                             ,pr_retxml   => pr_retxml
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
                               
    -- Aborta em caso de erro
    if trim(vr_dscritic) is not null then
      raise vr_exc_saida;
    end if;

    -- Retorna xml caso encontre problema em alguma linha do arquivo
    if pr_retxml is not null then
      raise vr_exc_layout;
    end if;

    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

    -- Convenios sem unificacao ja retornam arquivo
    if rw_cdconve.flgcvuni = 0 then

      -- Busca parametros de retorno da execucao do 388
      open cr_crapprm (vr_cdcooper);
      fetch cr_crapprm into rw_crapprm;

      -- Deve retornar critica se nao retornar
      -- o nome do arquivo
      if cr_crapprm%notfound then
        close cr_crapprm;
        vr_dscritic := 'Rotina não retornou nome do arquivo';
        raise vr_exc_saida;
      end if;

      close cr_crapprm;

      --Efetuar Copia do PDF
      gene0002.pc_efetua_copia_pdf (pr_cdcooper => vr_cdcooper     --> Cooperativa conectada
                                   ,pr_cdagenci => vr_cdagenci     --> Codigo da agencia para erros
                                   ,pr_nrdcaixa => vr_nrdcaixa     --> Codigo do caixa para erros
                                   ,pr_nmarqpdf => rw_crapprm.dsvlrprm     --> Arquivo PDF  a ser gerado                                 
                                   ,pr_des_reto => vr_des_reto     --> Saída com erro
                                   ,pr_tab_erro => vr_tab_erro);   --> tabela de erros 
                                   
      --Se ocorreu erro
      IF vr_des_reto <> 'OK' THEN
        
        --Se possui erro
        IF vr_tab_erro.COUNT > 0 THEN
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          vr_cdcritic:= 0;
          vr_dscritic:= 'Não foi possível efetuar a copia do arquivo para Intranet.';
        END IF;
        
        --Levantar Excecao  
        RAISE vr_exc_saida;
        
      END IF;  
      
      vr_nmarquiv:= SUBSTR(rw_crapprm.dsvlrprm,instr(rw_crapprm.dsvlrprm,'/',-1)+1);
      
      -- Insere as tags dos campos da PLTABLE de aplicações
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'flgcvuni', pr_tag_cont => rw_cdconve.flgcvuni, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'nmarqpdf', pr_tag_cont => vr_nmarquiv, pr_des_erro => vr_dscritic);

    elsif vr_cdcooper = 3 then

      pc_unifica_arq_449 (pr_cdcooper => vr_cdcooper
                         ,pr_cdconven => rw_cdconve.cdconven
                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                         ,pr_tpdcontr => 2
                         ,pr_nmarquiv => vr_nmarquiv
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);

      -- Aborta em caso de erro
      if trim(vr_dscritic) is not null or nvl(vr_cdcritic,0) > 0 then
        raise vr_exc_saida;
      end if;
      
      if trim(vr_nmarquiv) is null then
        vr_dscritic := 'Erro ao unificar arquivo: nome vazio.';
        raise vr_exc_saida;
      end if;

      --Efetuar Copia do PDF
      gene0002.pc_efetua_copia_pdf (pr_cdcooper => vr_cdcooper     --> Cooperativa conectada
                                   ,pr_cdagenci => vr_cdagenci     --> Codigo da agencia para erros
                                   ,pr_nrdcaixa => vr_nrdcaixa     --> Codigo do caixa para erros
                                   ,pr_nmarqpdf => vr_nmarquiv     --> Arquivo PDF  a ser gerado                                 
                                   ,pr_des_reto => vr_des_reto     --> Saída com erro
                                   ,pr_tab_erro => vr_tab_erro);   --> tabela de erros 
                                   
      --Se ocorreu erro
      IF vr_des_reto <> 'OK' THEN
        
        --Se possui erro
        IF vr_tab_erro.COUNT > 0 THEN
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          vr_cdcritic:= 0;
          vr_dscritic:= 'Não foi possível efetuar a copia do arquivo para Intranet.';
        END IF;
        
        --Levantar Excecao  
        RAISE vr_exc_saida;
        
      END IF;  
      
      vr_nmarquiv:= SUBSTR(vr_nmarquiv,instr(vr_nmarquiv,'/',-1)+1);

      -- Insere as tags dos campos da PLTABLE de aplicações
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'flgcvuni', pr_tag_cont => rw_cdconve.flgcvuni, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'nmarqpdf', pr_tag_cont => vr_nmarquiv, pr_des_erro => vr_dscritic);

    else
      
      -- Insere as tags dos campos da PLTABLE de aplicações
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'flgcvuni', pr_tag_cont => null, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'nmarqpdf', pr_tag_cont => null, pr_des_erro => vr_dscritic);

    end if;   

    commit;

    pr_des_erro := 'OK';
      
  exception
   
    when vr_exc_saida then

      if vr_cdcritic <> 0 then
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      else
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      end if;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      rollback;

    WHEN vr_exc_layout THEN
       
       pr_des_erro := 'OK';
       
    when others then

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela TELA_HCONVE.pc_conv_importa_arquivos_web: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      rollback;
        
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper);

  end pc_conv_importa_arquivos_web;

  procedure pc_conv_importa_arquivos (pr_cdcooper   in crapatr.cdcooper%type
                                     ,pr_dsarquiv   IN VARCHAR2            --> Informações do arquivo
                                     ,pr_dsdireto   IN VARCHAR2            --> Informações do diretório do arquivo
                                     ,pr_cdhisdeb   in gnconve.cdhisdeb%type
                                     ,pr_cdconven   in gnconve.cdconven%type
                                     ,pr_flgcvuni   in gnconve.flgcvuni%type
                                     ,pr_dtmvtolt   in crapdat.dtmvtolt%type
                                     ,pr_dtmvtopr   in crapdat.dtmvtopr%type
                                     ,pr_dtmvtoan   in crapdat.dtmvtoan%type
                                     ,pr_retxml in out nocopy XMLType
                                     ,pr_cdcritic  out pls_integer
                                     ,pr_dscritic  out varchar) is 

    ---------------------------------------------------------------------------
    --
    --  Programa : pc_conv_importa_arquivos
    --  Sistema  : Ayllos Web
    --  Autor    : Gabriel Marcos
    --  Data     : Outubro/2018                Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Objetivo  : Homologacao de importacao de arquivos
    --             
    --
    -- Alteracoes:
    --
    ---------------------------------------------------------------------------

    -- Busca parametros de saida da rotina
    cursor cr_crapprm (pr_cdcooper in crapprm.cdcooper%type) is
    select prm.dsvlrprm
      from crapprm prm
     where prm.cdcooper = pr_cdcooper
       and prm.cdacesso = 'PRM_HCONVE_CRPS387_OUT';
    rw_crapprm cr_crapprm%rowtype;    
    
    -- Loop nas cooperativas
    cursor cr_crapcop is
    select cop.cdcooper
      from crapcop cop;

    -- Declaracao padrao de variaveis
    vr_dscritic  varchar2(1000);
    vr_database  varchar2(100);
    vr_exc_saida exception;
    vr_exc_layout exception;
    vr_flgresta  pls_integer;
    vr_stprogra  pls_integer;
    vr_infimsol  pls_integer;
    vr_cdcritic  pls_integer;
    vr_nrsequen  pls_integer;
    vr_nrdrowid  rowid;
    vr_dsupload  VARCHAR2(100);
    vr_dirarqui  VARCHAR2(100);
    vr_typ_said  VARCHAR2(50); -- Critica
    vr_des_erro  VARCHAR2(500); -- Critica
    vr_typ_saida    VARCHAR2(100);
    vr_des_saida    VARCHAR2(2000);
    
    vr_contador  number := 0;
    vr_flgarqui boolean := false;
    vr_dados_futuros typ_tab_futuros;

  begin

    -- Busca ambiente conectado
    vr_database := GENE0001.fn_database_name;

    -- Nao permitido em ambiente de producao
    if instr(upper(vr_database),'P',1) > 0 then 
      vr_dscritic := 'Ambiente não permite esta operação.';
      raise vr_exc_saida;
    end if;
    
    -- Busca o diretório do upload do arquivo
    vr_dsupload := GENE0001.fn_diretorio(pr_tpdireto => 'C'
                                        ,pr_cdcooper => pr_cdcooper
                                        ,pr_nmsubdir => 'upload');
                                        
    -- Busca o diretório do upload do arquivo
    vr_dirarqui := GENE0001.fn_diretorio(pr_tpdireto => 'C'
                                        ,pr_cdcooper => pr_cdcooper
                                        ,pr_nmsubdir => 'arq');

    while not vr_flgarqui loop

      -- Realizar a cópia do arquivo
      GENE0001.pc_OScommand_Shell(gene0001.fn_param_sistema('CRED',0,'SCRIPT_RECEBE_ARQUIVOS')||' '||pr_dsdireto||pr_dsarquiv||' S'
                                 ,pr_typ_saida   => vr_typ_said
                                 ,pr_des_saida   => vr_des_erro);

      -- Testar erro
      IF vr_typ_said = 'ERR' THEN
        -- O comando shell executou com erro, gerar log e sair do processo
        vr_dscritic := 'Erro realizar o upload do arquivo: ' || vr_des_erro;
        RAISE vr_exc_saida;
      END IF;

      -- Verifica se o arquivo existe
      IF GENE0001.fn_exis_arquivo(pr_caminho => vr_dsupload||'/'||pr_dsarquiv) THEN
        vr_flgarqui := true;
      -- Tenta criar copia dez vezes
      ELSIF vr_contador = 10 THEN
        vr_flgarqui := true;
      END IF;
      
      vr_contador := vr_contador + 1;
    
    end loop;
    
    vr_contador := 0;

    -- Verifica se o arquivo existe
    IF NOT GENE0001.fn_exis_arquivo(pr_caminho => vr_dsupload||'/'||pr_dsarquiv) THEN
      -- Retorno de erro
      vr_dscritic := 'Arquivo não encontrado no diretório: '||REPLACE(vr_dsupload,'/','-')||'-'||pr_dsarquiv;
      RAISE vr_exc_saida;
    END IF;
    
    /* Move o arquivo lido para o diretório salvar */
    gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||vr_dsupload||'/'||pr_dsarquiv||' '||vr_dirarqui||'/'||substr(pr_dsarquiv,7)||' 2> /dev/null'
                               ,pr_typ_saida   => vr_typ_saida
                               ,pr_des_saida   => vr_des_saida);

    -- Se retornar uma indicação de erro
    IF NVL(vr_typ_saida,' ') = 'ERR' THEN
      vr_cdcritic := 1054; -- Erro pc_OScommand_Shell                       
      raise vr_exc_saida;
    END IF;
    
    -- Faz validacoes basicas no conteudo do arquivo
    pc_verifica_layout (pr_cdcooper => pr_cdcooper
                       ,pr_nmarquiv => substr(pr_dsarquiv,7)
                       ,pr_flgcvuni => pr_flgcvuni
                       ,pr_retxml   => pr_retxml
                       ,pr_cdcritic => vr_cdcritic
                       ,pr_dscritic => vr_dscritic); 

    -- Retorna inconsistencias caso encontradas
    if nvl(vr_cdcritic,0) > 0 or trim(vr_dscritic) is not null then
      raise vr_exc_saida;
    end if;

    -- Retorna xml caso encontre problema em alguma linha do arquivo
    if pr_retxml is not null THEN      
      raise vr_exc_layout;
    end if;

    -- Faz tratamentos para execucao do crps387
    pc_trata_arq_exec (pr_cdcooper      => pr_cdcooper
                      ,pr_nmarquiv      => pr_dsarquiv
                      ,pr_dtmvtolt      => pr_dtmvtolt
                      ,pr_dtmvtopr      => pr_dtmvtopr
                      ,pr_dtmvtoan      => pr_dtmvtoan
                      ,pr_dados_futuros => vr_dados_futuros
                      ,pr_cdcritic      => vr_cdcritic 
                      ,pr_dscritic      => vr_dscritic);

    -- Aborta em caso de critica
    if nvl(vr_cdcritic,0) > 0 or trim(vr_dscritic) is not null then
      raise vr_exc_saida;
    end if;

    -- Programa que faz lancamentos na craplau
    pc_crps387 (pr_cdcooper => pr_cdcooper
               ,pr_flgresta => vr_flgresta
               ,pr_stprogra => vr_stprogra
               ,pr_infimsol => vr_infimsol
               ,pr_cdcritic => vr_cdcritic
               ,pr_dscritic => vr_dscritic);

    -- Aborta em caso de critica
    if nvl(vr_cdcritic,0) > 0 or trim(vr_dscritic) is not null then
      raise vr_exc_saida;
    end if;

    -- Busca parametros de retorno da execucao do 387
    open cr_crapprm (pr_cdcooper);
    fetch cr_crapprm into rw_crapprm;

    if cr_crapprm%found then
      -- Atualizacao de registros da tab. de lanc. futuros
      for i in 1 .. vr_dados_futuros.count loop
        begin
          update craplau lau
             set lau.dtmvtopg = pr_dtmvtolt
               , lau.dtdebito = null
           where lau.cdcooper = vr_dados_futuros(i).cdcooper
             and lau.nrdconta = vr_dados_futuros(i).nrdconta
             and lau.insitlau = 1
             and lau.vllanaut = vr_dados_futuros(i).vllanaut;
        exception
          when others then
            vr_dscritic := 'Erro ao parametrizar dados futuros(1): '||sqlerrm;
            raise vr_exc_saida;
        end;
      end loop;
    end if;
    
    close cr_crapprm;
    
    begin
      update crapndb ndb
         set ndb.dtmvtolt = pr_dtmvtolt
       where ndb.cdcooper = pr_cdcooper
         and ndb.cdhistor = pr_cdhisdeb
         and ndb.dtmvtolt = pr_dtmvtopr;
    exception
      when others then
        vr_dscritic := 'Ao atualizar dados da tabela crapndb: '||sqlerrm;
        raise vr_exc_saida;
    end;
    
    begin
      update gnconve nve
         set nve.nrseqint = nve.nrseqint + 1
       where nve.cdconven = pr_cdconven;
    exception
      when others then
        vr_dscritic := 'Ao atualizar dados da tabela gnconve: '||sqlerrm;
        raise vr_exc_saida;
    end;

    -- Lancamentos de debito
    pc_crps509 (pr_cdcooper => pr_cdcooper
               ,pr_flgresta => vr_flgresta
               ,pr_cdagenci => 1
               ,pr_idparale => 0
               ,pr_stprogra => vr_stprogra
               ,pr_infimsol => vr_infimsol
               ,pr_cdcritic => vr_cdcritic
               ,pr_dscritic => vr_dscritic
               ,pr_inpriori => 'N');
    
    -- Aborta em caso de critica      
    if nvl(vr_cdcritic,0) > 0 or trim(vr_dscritic) is not null then
      raise vr_exc_saida;
    end if;
 
    -- Arquivos de retorno
    pc_crps388(pr_cdcooper => pr_cdcooper
              ,pr_flgresta => vr_flgresta
              ,pr_stprogra => vr_stprogra
              ,pr_infimsol => vr_infimsol
              ,pr_cdcritic => vr_cdcritic
              ,pr_dscritic => vr_dscritic);
          
    -- Aborta em caso de critica                 
    if nvl(vr_cdcritic,0) > 0 or trim(vr_dscritic) is not null then
      raise vr_exc_saida;
    end if;
    
    -- Busca parametros de retorno da execucao do 387
    open cr_crapprm (pr_cdcooper);
    fetch cr_crapprm into rw_crapprm;
    
    if cr_crapprm%found then
      -- Atualizacao de registros da tab. de lanc. futuros
      for i in 1 .. vr_dados_futuros.count loop
        begin
          update craplau lau
             set lau.dtmvtopg = pr_dtmvtopr
               , lau.dtdebito = null
           where lau.cdcooper = vr_dados_futuros(i).cdcooper
             and lau.nrdconta = vr_dados_futuros(i).nrdconta
             and lau.vllanaut = vr_dados_futuros(i).vllanaut;
        exception
          when others then
            vr_dscritic := 'Erro ao parametrizar dados futuros(1): '||sqlerrm;
            raise vr_exc_saida;
        end;
      end loop;
    end if;
    
    close cr_crapprm;
   
    begin
      delete
        from crapprm prm
       where prm.cdacesso in ('PRM_HCONVE_CRPS387_IN','PRM_HCONVE_CRPS388_IN');
    exception
      when others then
        vr_dscritic := 'Erro ao deletar dados da crapprm: '||sqlerrm;
        raise vr_exc_saida;
    end;

    commit;

  exception
  
    when vr_exc_saida then

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

    WHEN vr_exc_layout THEN
      
      NULL;
      
    when others then 
        
      pr_cdcritic := 0;
      pr_dscritic := 'Erro não tratado na TELA_HCONVE.pc_conv_importa_arquivos: '||sqlerrm;

  end pc_conv_importa_arquivos;

  procedure pc_unifica_arq_449 (pr_cdcooper   in gnconve.cdcooper%type
                               ,pr_cdconven   in gnconve.cdconven%type
                               ,pr_dtmvtolt   in crapdat.dtmvtolt%type
                               ,pr_tpdcontr   in gncvuni.tpdcontr%type
                               ,pr_nmarquiv  out varchar2
                               ,pr_cdcritic  out pls_integer
                               ,pr_dscritic  out varchar2) is

    ---------------------------------------------------------------------------
    --
    --  Programa : pc_unifica_arq_449
    --  Sistema  : Ayllos Web
    --  Autor    : Gabriel Marcos
    --  Data     : Dezembro/2018                Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Objetivo  : Chamada web para unificacao
    --             
    --
    -- Alteracoes:
    --
    ---------------------------------------------------------------------------
    
    -- Busca faturas a serem unificadas
    cursor cr_gncvuni (pr_cdconven in gnconve.cdconven%type
                      ,pr_tpdcontr in gncvuni.tpdcontr%type) is
    select gnc.rowid
         , gnc.*
      from gncvuni gnc
     where gnc.cdconven = pr_cdconven
       and gnc.tpdcontr = pr_tpdcontr
       and gnc.flgproce = 0;
    rw_gncvuni cr_gncvuni%rowtype;
    
    -- Busca dados do convenio
    cursor cr_gnconve (pr_cdconven in gnconve.cdconven%type) is
    select gnc.*
      from gnconve gnc
     where gnc.cdconven = pr_cdconven;
    rw_gnconve cr_gnconve%rowtype;
    
    -- Busca dados para nomear arquivo
    cursor cr_gncontr (pr_cdconven in gnconve.cdconven%type
                      ,pr_tpdcontr in gncontr.tpdcontr%type
                      ,pr_dtmvtolt in crapdat.dtmvtolt%type) is
    select ctr.*
      from gncontr ctr
     where ctr.cdcooper = 3                    
       and ctr.tpdcontr = pr_tpdcontr
       and ctr.cdconven = pr_cdconven
       and ctr.dtmvtolt = pr_dtmvtolt;
    rw_gncontr cr_gncontr%rowtype;        
    
    -- Busca dados da cooperativa
    cursor cr_crapcop (pr_cdcooper in crapcop.cdcooper%type) is
    select cop.*
      from crapcop cop
     where cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%rowtype;
    
    vr_dscritic  varchar2(10000);  
    vr_cdcritic  pls_integer;
    vr_exc_saida exception;
    
    vr_nmdbanco crapcop.nmrescop%type;
    vr_nrdbanco gnconve.cddbanco%type;
    vr_nrconven gnconve.nrcnvfbr%type;
    vr_nmempcov gnconve.nmempres%type;
    
    vr_utlfile   utl_file.file_type;
    vr_nmdireto  varchar2(100);
    vr_nrseqarq  varchar2(100);
    vr_nmarqdat  varchar2(200);
    vr_nmarquiv  varchar2(200);
    vr_texto     varchar2(4000);
    vr_nrseqdig  number := 0;
    vr_vlfatura  number := 0;
    
    vr_des_reto VARCHAR2(3);
    --Tabelas de Memoria
    vr_tab_erro    gene0001.typ_tab_erro;
    
    -- Atualiza sequencia do nome do arquivo
    procedure obtem_atualiza_sequencia (pr_cdconven  in gnconve.cdconven%type
                                       ,pr_tpdcontr  in gncvuni.tpdcontr%type
                                       ,pr_dtmvtolt  in crapdat.dtmvtolt%type
                                       ,vr_nrseqarq out gnconve.nrseqatu%type
                                       ,vr_dscritic out varchar2) is
      
      -- Busca dados do convenio
      cursor cr_gnconve (pr_cdconven in gnconve.cdconven%type) is
      select gnc.nrseqcxa
           , gnc.nrseqatu
           , gnc.rowid
        from gnconve gnc
       where gnc.cdconven = pr_cdconven;
      rw_gnconve cr_gnconve%rowtype;
      
      vr_exc_saida exception;
    
    begin
      
      -- Busca sequencias do convenio
      open cr_gnconve (pr_cdconven);
      fetch cr_gnconve into rw_gnconve;
      close cr_gnconve;

      -- Verificar arquivo controle - se existir nao somar seq.
      if pr_tpdcontr = 1 then

        vr_nrseqarq := rw_gnconve.nrseqcxa;
          
        begin
          -- Incrementar sequencia
          update gnconve gnc
             set gnc.nrseqcxa = vr_nrseqarq + 1
           where gnc.rowid = rw_gnconve.rowid;
        exception
          when others then
            vr_dscritic := 'Erro ao atualizar tabela gnconve: '||sqlerrm;
            raise vr_exc_saida;
        end;
          
        begin
          -- Insere nova sequencia arquivo
          insert
            into  gncontr
                 (cdcooper
                 ,tpdcontr
                 ,cdconven
                 ,dtmvtolt
                 ,nrsequen)
          values (3
                 ,1
                 ,pr_cdconven
                 ,pr_dtmvtolt
                 ,vr_nrseqarq);
        exception
          when others then
            vr_dscritic := 'Erro ao inserir na tabela gncontr: '||sqlerrm;
            raise vr_exc_saida;
        end;

      elsif pr_tpdcontr = 2 then
               
        vr_nrseqarq := rw_gnconve.nrseqatu;
          
        begin
          -- Incrementar sequencia
          update gnconve gnc
             set gnc.nrseqatu = vr_nrseqarq + 1
           where gnc.rowid = rw_gnconve.rowid;
        exception
          when others then
            vr_dscritic := 'Erro ao atualizar tabela gnconve: '||sqlerrm;
            raise vr_exc_saida;
        end;

        begin
          -- Insere nova sequencia arquivo
          insert
            into  gncontr
                 (cdcooper
                 ,tpdcontr
                 ,cdconven
                 ,dtmvtolt
                 ,nrsequen)
          values (3
                 ,4
                 ,pr_cdconven
                 ,pr_dtmvtolt
                 ,vr_nrseqarq);
        exception
          when others then
            vr_dscritic := 'Erro ao inserir na tabela gncontr: '||sqlerrm;
            raise vr_exc_saida;
        end;

      elsif pr_tpdcontr = 3 then
          
        vr_nrseqarq := rw_gnconve.nrseqatu;
          
        begin
          -- Incrementar sequencia
          update gnconve gnc
             set gnc.nrseqatu = vr_nrseqarq + 1
           where gnc.rowid = rw_gnconve.rowid;
        exception
          when others then
            vr_dscritic := 'Erro ao atualizar tabela gnconve: '||sqlerrm;
            raise vr_exc_saida;
        end;

        begin
          -- Insere nova sequencia arquivo
          insert
            into  gncontr
                 (cdcooper
                 ,tpdcontr
                 ,cdconven
                 ,dtmvtolt
                 ,nrsequen)
          values (3
                 ,2
                 ,pr_cdconven
                 ,pr_dtmvtolt
                 ,vr_nrseqarq);
        exception
          when others then
            vr_dscritic := 'Erro ao inserir na tabela gncontr: '||sqlerrm;
            raise vr_exc_saida;
        end;

      end if;
          
    exception
      
      when others then
        
        vr_dscritic := vr_dscritic||' - '||sqlerrm;

    end obtem_atualiza_sequencia;
    
  begin

    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'HCONVE'
                              ,pr_action => null); 
    
    -- Aborta caso nao seja central
    if pr_cdcooper <> 3 then
      vr_dscritic := 'Apenas a central pode unificar arquivos.';
      raise vr_exc_saida;
    end if;
    
    -- Busca dados da cooperativa
    open cr_crapcop (pr_cdcooper);
    fetch cr_crapcop into rw_crapcop;
    
    -- Aborta caso nao retorne registros
    if cr_crapcop%notfound then
      close cr_crapcop;
      vr_dscritic := 'Cooperativa não encontrada.';
      raise vr_exc_saida;
    end if;
    
    close cr_crapcop;

    -- Busca do diretorio base da cooperativa
    vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                        ,pr_cdcooper => pr_cdcooper);

    -- Buscar faturas para unificar
    open cr_gncvuni (pr_cdconven
                    ,pr_tpdcontr);
    fetch cr_gncvuni into rw_gncvuni;
    
    -- Abortar caso nao retorne registros
    if cr_gncvuni%notfound then
      close cr_gncvuni;
      vr_dscritic := 'Não existem arquivos a serem unificados.';
      raise vr_exc_saida;
    end if;
    
    close cr_gncvuni;
    
    -- Busca dados do convenio
    open cr_gnconve (pr_cdconven);
    fetch cr_gnconve into rw_gnconve;
    
    -- Abortar caso nao retorne registros
    if cr_gnconve%notfound then
      close cr_gnconve;
      vr_dscritic := 'Convênio não encontrado.';
      raise vr_exc_saida;
    end if;
    
    close cr_gnconve;
    
    if rw_gncvuni.tpdcontr = 1 then

      -- Nome para o tipo de contrato
      vr_nmarquiv := rw_gnconve.nmarqcxa;
      
      -- Busca sequencia do arquivo
      open cr_gncontr (pr_cdconven
                      ,1
                      ,pr_dtmvtolt);
      fetch cr_gncontr into rw_gncontr;
          
      -- Regra do programa
      if cr_gncontr%found then
        vr_nrseqarq := rw_gncontr.nrsequen;
      else 
        --Chama rotina
        obtem_atualiza_sequencia (pr_cdconven
                                 ,rw_gncvuni.tpdcontr
                                 ,pr_dtmvtolt
                                 ,vr_nrseqarq
                                 ,vr_dscritic);
        -- Aborta em caso de critica     
        if trim(vr_dscritic) is not null then
          raise vr_exc_saida;
        end if;
      end if;
          
      close cr_gncontr;

    elsif rw_gncvuni.tpdcontr = 2 then
        
      -- Nome para o tipo de contrato
      vr_nmarquiv := rw_gnconve.nmarqdeb;

      -- Busca sequencia do arquivo
      open cr_gncontr (pr_cdconven
                      ,4
                      ,pr_dtmvtolt);
      fetch cr_gncontr into rw_gncontr;
        
      -- Regra do programa
      if cr_gncontr%found then
        vr_nrseqarq := rw_gncontr.nrsequen;
      else 
        --Chama rotina
        obtem_atualiza_sequencia (pr_cdconven
                                 ,rw_gncvuni.tpdcontr
                                 ,pr_dtmvtolt
                                 ,vr_nrseqarq
                                 ,vr_dscritic);
        -- Aborta em caso de critica     
        if trim(vr_dscritic) is not null then
          raise vr_exc_saida;
        end if;
      end if;
        
      close cr_gncontr;

    elsif rw_gncvuni.tpdcontr = 3 then
                                 
      -- Nome para o tipo de contrato
      vr_nmarquiv := rw_gnconve.nmarqatu;
        
      -- Busca sequencia do arquivo
      open cr_gncontr (pr_cdconven
                      ,2
                      ,pr_dtmvtolt);
      fetch cr_gncontr into rw_gncontr;

      -- Regra do programa
      if cr_gncontr%found then
        vr_nrseqarq := rw_gncontr.nrsequen;
      else 
        --Chama rotina
        obtem_atualiza_sequencia (pr_cdconven
                                 ,rw_gncvuni.tpdcontr
                                 ,pr_dtmvtolt
                                 ,vr_nrseqarq
                                 ,vr_dscritic);
        -- Aborta em caso de critica     
        if trim(vr_dscritic) is not null then
          raise vr_exc_saida;
        end if;
      end if;
        
      close cr_gncontr;
      
    end if;

    vr_nmdbanco := rw_crapcop.nmrescop;
    vr_nrdbanco := rw_gnconve.cddbanco;
    vr_nrconven := rw_gnconve.nrcnvfbr;
    vr_nmempcov := rw_gnconve.nmempres;
          
    vr_nrseqarq := lpad(trim(vr_nrseqarq),6,'0');

    vr_nmarqdat := trim(substr(vr_nmarquiv,1,4))        ||
                   to_char(pr_dtmvtolt,'mmdd') || '.' ||
                   substr(vr_nrseqarq,4,3);

    if  substr(vr_nmarquiv,5,2)  = 'MM'  and
        substr(vr_nmarquiv,7,2)  = 'DD'  and
        substr(vr_nmarquiv,10,3) = 'TXT' then 
      vr_nmarqdat := trim(substr(vr_nmarquiv,1,4))||
                     to_char(pr_dtmvtolt,'mmdd')||'.txt';
    end if;
   
    if  substr(vr_nmarquiv,5,2)  = 'DD'  and
        substr(vr_nmarquiv,7,2)  = 'MM'  and
        substr(vr_nmarquiv,10,3) = 'RET' then
      vr_nmarqdat := trim(substr(vr_nmarquiv,1,4)) +
                     to_char(pr_dtmvtolt,'ddmm')||'.ret';
    end if;
 
    if  substr(vr_nmarquiv,5,2)  = 'CP'  and  
        substr(vr_nmarquiv,7,2)  = 'MM'  and
        substr(vr_nmarquiv,9,2)  = 'DD'  and
        substr(vr_nmarquiv,12,3) = 'SEQ' then
      vr_nmarqdat := trim(substr(vr_nmarquiv,1,4))||
                     lpad(pr_cdcooper,2,'0')||
                     to_char(pr_dtmvtolt,'mmdd')||
                     '.'||substr(vr_nrseqarq,3,3);
    end if;
                   
    if  substr(vr_nmarquiv,4,1)  = 'C'    and
        substr(vr_nmarquiv,5,4)  = 'SEQU' and
        substr(vr_nmarquiv,10,3) = 'RET'  then 
      vr_nmarqdat := trim(substr(vr_nmarquiv,1,3))||
                     substr(pr_cdcooper,1,1)||
                     substr(vr_nrseqarq,3,3)||'.ret';
    end if;
 
    -- Cria arquivo para edicao
    gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto||'/salvar'
                            ,pr_nmarquiv => vr_nmarqdat
                            ,pr_tipabert => 'W'
                            ,pr_utlfileh => vr_utlfile
                            ,pr_des_erro => vr_dscritic);
              
    if    rw_gncvuni.tpdcontr = 1 then
      vr_texto := 'A2'||rpad(vr_nrconven,8,' ')||'            '||
                  rpad(vr_nmempcov,20,' ')||
                  rpad(vr_nrdbanco,3,' ')||
                  rpad(vr_nmdbanco,20,' ')||
                  to_char(pr_dtmvtolt,'yyyymmdd')||
                  rpad(vr_nrseqarq,6,' ')||
                  lpad(rw_gnconve.nrlayout,2,'0')||
                  'ARRECADACAO CAIXA'||
                  '                              '||
                  '                      ';
      gene0001.pc_escr_linha_arquivo(vr_utlfile,vr_texto);
    elsif rw_gncvuni.tpdcontr = 2 then
      vr_texto := 'A2'||rpad(vr_nrconven,8,' ')||'            '||
                  rpad(vr_nmempcov,20,' ')||
                  rpad(vr_nrdbanco,3,' ')||
                  rpad(vr_nmdbanco,20,' ')||
                  to_char(pr_dtmvtolt,'yyyymmdd')||
                  rpad(vr_nrseqarq,6,' ')||
                  lpad(rw_gnconve.nrlayout,2,'0')||
                  'DEBITO AUTOMATICO'||
                  '                              '||
                  '                      ';
      gene0001.pc_escr_linha_arquivo(vr_utlfile,vr_texto);
    elsif rw_gncvuni.tpdcontr = 3 then
      vr_texto := 'A2'||rpad(vr_nrconven,8,' ')||'            '||
                  rpad(vr_nmempcov,20,' ')||
                  rpad(vr_nrdbanco,3,' ')||
                  rpad(vr_nmdbanco,20,' ')||
                  to_char(pr_dtmvtolt,'yyyymmdd')||
                  rpad(vr_nrseqarq,6,' ')||
                  lpad(rw_gnconve.nrlayout,2,'0')||
                  'DEBITO AUTOMATICO'||
                  '                              '||
                  '                      ';
      gene0001.pc_escr_linha_arquivo(vr_utlfile,vr_texto);
    end if;

    -- Loop populando com as informacoes
    for rw_gncvuni in cr_gncvuni (pr_cdconven
                                 ,pr_tpdcontr) loop
      
      vr_nrseqdig := vr_nrseqdig + 1;
      vr_vlfatura := vr_vlfatura + nvl(trim(substr(rw_gncvuni.dsmovtos,53,15)),0);
      vr_texto := rw_gncvuni.dsmovtos;
      gene0001.pc_escr_linha_arquivo(vr_utlfile,vr_texto);
          
      begin
        -- Incrementar sequencia
        update gncvuni uni
           set uni.flgproce = 1
         where uni.rowid = rw_gncvuni.rowid;
      exception
        when others then
          vr_dscritic := 'Erro ao atualizar tabela gnconve: '||sqlerrm;
          raise vr_exc_saida;
      end;
      
    end loop;
    
    vr_texto := 'Z'||lpad(vr_nrseqdig + 2,6,'0')||lpad(vr_vlfatura,17,'0')||
                '                                        '||
                '                                        '||
                '                                              ';
                
    gene0001.pc_escr_linha_arquivo(vr_utlfile,vr_texto);
          
    gene0001.pc_fecha_arquivo(vr_utlfile);

    pr_nmarquiv := vr_nmdireto||'/salvar/'||vr_nmarqdat;

    commit;

  exception
  
    when vr_exc_saida then

      if vr_cdcritic <> 0 then
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      else
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      end if;

      rollback;
      
    when others then

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela TELA_HCONVE.pc_unifica_arq_449: ' || SQLERRM;
      
      rollback;
        
      cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper);

  end pc_unifica_arq_449;

  procedure pc_verifica_layout (pr_cdcooper   in craphis.cdcooper%type
                               ,pr_nmarquiv   in varchar2
                               ,pr_flgcvuni   in gnconve.flgcvuni%type
                               ,pr_retxml in out nocopy XMLType
                               ,pr_cdcritic  out pls_integer
                               ,pr_dscritic  out varchar2) is

    ---------------------------------------------------------------------------
    --
    --  Programa : pc_verifica_layout
    --  Sistema  : Ayllos Web
    --  Autor    : Gabriel Marcos
    --  Data     : Outubro/2018                Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Objetivo  : Verifica layout do arquivo de importacao
    --             
    --
    -- Alteracoes:
    --
    ---------------------------------------------------------------------------

    -- Busca codigo do convenio
    cursor cr_cdconve (pr_nmarquiv in varchar2) is
    select gnc.cdconven
         , gnc.nrcnvfbr
         , gnc.cddbanco
         , gnc.nrlayout
      from gnconve gnc
     where upper(gnc.nmarqint) = upper(pr_nmarquiv);
    rw_cdconve cr_cdconve%rowtype;
    
    -- Busca codigo da cooperativa via arquivo
    cursor cr_crapcop (pr_cdagectl in crapage.cdagectl%type) is
    select cop.cdcooper
      from crapcop cop
     where cop.cdagectl = pr_cdagectl;
    rw_crapcop cr_crapcop%rowtype;

    -- Declaracao de variaveis
    vr_dtmvtolt  date;
    vr_nrnumber  number;
    vr_aposicao  NUMBER := 0;
    vr_contador  number := 0;
    vr_qtregist  number := 0;
    vr_vldebito  number := 0;
    vr_exc_saida exception;
    vr_cdcritic  pls_integer;
    vr_destexto  varchar2(100);
    vr_nmdireto  varchar2(100);
    vr_linhaxml  varchar2(100);
    vr_texto1    varchar2(4000);
    vr_dscritic  varchar2(1000);
    vr_utlfile   utl_file.file_type;
    vr_nrdconta  crapass.nrdconta%type;

  begin

    -- Busca convenio pelo nome do arquivo
    open cr_cdconve (substr(pr_nmarquiv,1,6));
    fetch cr_cdconve into rw_cdconve;
    
    -- Aborta se nao encontrar
    if cr_cdconve%notfound then
      close cr_cdconve;
      vr_dscritic := 'Nome inválido ou convênio não existe.';
      raise vr_exc_saida;
    end if;
    
    close cr_cdconve;

    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root', pr_posicao => 0, pr_tag_nova => 'Dados', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados',  pr_posicao => 0, pr_tag_nova => 'tabela', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    -- Busca do diretorio base da cooperativa
    vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                        ,pr_cdcooper => pr_cdcooper);
    
    -- Abre arquivo original
    gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto||'/arq',
                             pr_nmarquiv => pr_nmarquiv,
                             pr_tipabert => 'R',
                             pr_utlfileh => vr_utlfile,
                             pr_des_erro => vr_dscritic);
  
    begin
      
      loop

        -- Varre linhas do arquivo
        gene0001.pc_le_linha_arquivo(vr_utlfile,vr_texto1);
        
        if trim(replace(replace(vr_texto1,chr(13),''),CHR(13),'')) is null then
          gene0001.pc_fecha_arquivo(vr_utlfile);
          vr_dscritic := 'Arquivo possui linhas vazias.';
          raise vr_exc_saida;
        end if;
        
        vr_qtregist := vr_qtregist + vr_aposicao;
        
        -- Para popular xml em caso de erro
        vr_aposicao := 0;
        vr_contador := vr_contador + 1;
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'tabela', pr_posicao => 0, pr_tag_nova => 'linha'||vr_contador, pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

        -- Verifica posicoes de data do arquivo
        if trim(substr(vr_texto1,1,1)) = 'A' then
          begin
            vr_destexto := length(replace(vr_texto1,chr(13),''));
            if vr_destexto <> 150 then
              vr_linhaxml := 'Número de caracteres incorretos: '||vr_destexto;
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'linha'||vr_contador, pr_posicao => 0, pr_tag_nova => 'erro'||vr_aposicao, pr_tag_cont => vr_linhaxml, pr_des_erro => vr_dscritic);
              vr_aposicao := vr_aposicao + 1;
            end if;
          exception
            when others then
              vr_linhaxml := 'Número de caracteres incorretos.';
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'linha'||vr_contador, pr_posicao => 0, pr_tag_nova => 'erro'||vr_aposicao, pr_tag_cont => vr_linhaxml, pr_des_erro => vr_dscritic);
              vr_aposicao := vr_aposicao + 1;
          end;
          begin
            vr_nrnumber := to_number(trim(substr(vr_texto1,2,1)));
            if nvl(vr_nrnumber,0) <> 1 then
              vr_linhaxml := 'Código da remessa inválido(1).';
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'linha'||vr_contador, pr_posicao => 0, pr_tag_nova => 'erro'||vr_aposicao, pr_tag_cont => vr_linhaxml, pr_des_erro => vr_dscritic);
              vr_aposicao := vr_aposicao + 1;
            end if;
          exception
            when others then
              vr_linhaxml := 'Código da remessa inválido(2).';
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'linha'||vr_contador, pr_posicao => 0, pr_tag_nova => 'erro'||vr_aposicao, pr_tag_cont => vr_linhaxml, pr_des_erro => vr_dscritic);
              vr_aposicao := vr_aposicao + 1;
          end;
          begin
            vr_nrnumber := to_number(trim(substr(vr_texto1,3,20)));
            if vr_nrnumber <> rw_cdconve.nrcnvfbr then
              vr_linhaxml := 'Código do convênio definido em contrado inválido(1).';
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'linha'||vr_contador, pr_posicao => 0, pr_tag_nova => 'erro'||vr_aposicao, pr_tag_cont => vr_linhaxml, pr_des_erro => vr_dscritic);
              vr_aposicao := vr_aposicao + 1;
            end if;
          exception
            when others then
              vr_linhaxml := 'Código do convênio definido em contrado inválido(2).';
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'linha'||vr_contador, pr_posicao => 0, pr_tag_nova => 'erro'||vr_aposicao, pr_tag_cont => vr_linhaxml, pr_des_erro => vr_dscritic);
              vr_aposicao := vr_aposicao + 1;
          end;
          begin
            vr_nrnumber := to_number(trim(substr(vr_texto1,43,3)));
            if vr_nrnumber <> rw_cdconve.cddbanco then
              vr_linhaxml := 'Código Febraban do banco inválido(1).';
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'linha'||vr_contador, pr_posicao => 0, pr_tag_nova => 'erro'||vr_aposicao, pr_tag_cont => vr_linhaxml, pr_des_erro => vr_dscritic);
              vr_aposicao := vr_aposicao + 1;
            end if;
          exception
            when others then
              vr_linhaxml := 'Código Febraban do banco inválido(2).';
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'linha'||vr_contador, pr_posicao => 0, pr_tag_nova => 'erro'||vr_aposicao, pr_tag_cont => vr_linhaxml, pr_des_erro => vr_dscritic);
              vr_aposicao := vr_aposicao + 1;
          end;
          begin
            vr_dtmvtolt := to_date(trim(substr(vr_texto1,66,8)),'yyyymmdd');
          exception
            when others then
              vr_linhaxml := 'Data de geração inválida.';
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'linha'||vr_contador, pr_posicao => 0, pr_tag_nova => 'erro'||vr_aposicao, pr_tag_cont => vr_linhaxml, pr_des_erro => vr_dscritic);
              vr_aposicao := vr_aposicao + 1;
          end;
          begin
            vr_nrnumber := to_number(trim(substr(vr_texto1,74,6)));
            /*if vr_nrnumber <> to_number(substr(pr_nmarquiv,8)) then
              vr_linhaxml := 'O sequencial interno ('||vr_nrnumber||') é diferente do nomeado no arquivo '||to_number(substr(pr_nmarquiv,8))||'.';
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'linha'||vr_contador, pr_posicao => 0, pr_tag_nova => 'erro'||vr_aposicao, pr_tag_cont => vr_linhaxml, pr_des_erro => vr_dscritic);
              vr_aposicao := vr_aposicao + 1;
            end if;*/
          exception
            when others then
              vr_linhaxml := 'Número sequencial do arquivo inválido.';
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'linha'||vr_contador, pr_posicao => 0, pr_tag_nova => 'erro'||vr_aposicao, pr_tag_cont => vr_linhaxml, pr_des_erro => vr_dscritic);
              vr_aposicao := vr_aposicao + 1;
          end;
          -- Insere parametros para 387 buscar internamente
          begin
            insert
              into crapprm (nmsistem
                           ,cdcooper
                           ,cdacesso
                           ,dstexprm
                           ,dsvlrprm)
            values        ('CRED'
                           ,pr_cdcooper
                           ,'PRM_HCONVE_CRPS387_IN'
                           ,'Parametro de entrada do Crps387, auxilia na homologacao dos convenios.'
                           ,vr_nrnumber||';'||rw_cdconve.cdconven);
          exception          
            when dup_val_on_index then
              update crapprm prm
                 set prm.dsvlrprm = vr_nrnumber||';'||rw_cdconve.cdconven
               where prm.cdcooper = pr_cdcooper
                 and prm.cdacesso = 'PRM_HCONVE_CRPS387_IN';
            when others then           
              -- Gerando a critica
              vr_dscritic := 'Erro ao inserir dados na tabela crapprm: '||sqlerrm;
              raise vr_exc_saida;  
          end;
          begin
            vr_nrnumber := to_number(trim(substr(vr_texto1,80,2)));
            if vr_nrnumber <> rw_cdconve.nrlayout then
              vr_linhaxml := 'Número do layout do arquivo inválido(1).';
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'linha'||vr_contador, pr_posicao => 0, pr_tag_nova => 'erro'||vr_aposicao, pr_tag_cont => vr_linhaxml, pr_des_erro => vr_dscritic);
              vr_aposicao := vr_aposicao + 1;
            end if;
          exception
            when others then
              vr_linhaxml := 'Número do layout do arquivo inválido(2).';
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'linha'||vr_contador, pr_posicao => 0, pr_tag_nova => 'erro'||vr_aposicao, pr_tag_cont => vr_linhaxml, pr_des_erro => vr_dscritic);
              vr_aposicao := vr_aposicao + 1;
          end;
          begin
            vr_destexto := trim(substr(vr_texto1,82,17));
            if vr_destexto <> 'DEBITO AUTOMATICO' then
              vr_linhaxml := 'Identificação do serviço inválida(1).';
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'linha'||vr_contador, pr_posicao => 0, pr_tag_nova => 'erro'||vr_aposicao, pr_tag_cont => vr_linhaxml, pr_des_erro => vr_dscritic);
              vr_aposicao := vr_aposicao + 1;
            end if;
          exception
            when others then
              vr_linhaxml := 'Identificação do serviço inválida(2).';
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'linha'||vr_contador, pr_posicao => 0, pr_tag_nova => 'erro'||vr_aposicao, pr_tag_cont => vr_linhaxml, pr_des_erro => vr_dscritic);
              vr_aposicao := vr_aposicao + 1;
          end;
        elsif substr(vr_texto1,1,1) = 'B' then
          begin
            vr_destexto := length(replace(vr_texto1,chr(13),''));
            if vr_destexto <> 150 then
              vr_linhaxml := 'Número de caracteres incorretos: '||vr_destexto;
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'linha'||vr_contador, pr_posicao => 0, pr_tag_nova => 'erro'||vr_aposicao, pr_tag_cont => vr_linhaxml, pr_des_erro => vr_dscritic);
              vr_aposicao := vr_aposicao + 1;
            end if;
          exception
            when others then
              vr_linhaxml := 'Número de caracteres incorretos.';
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'linha'||vr_contador, pr_posicao => 0, pr_tag_nova => 'erro'||vr_aposicao, pr_tag_cont => vr_linhaxml, pr_des_erro => vr_dscritic);
              vr_aposicao := vr_aposicao + 1;
          end;          begin
            vr_nrnumber := to_number(trim(substr(vr_texto1,2,25)));
          exception
            when others then
              vr_linhaxml := 'Código de referência inválido.';
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'linha'||vr_contador, pr_posicao => 0, pr_tag_nova => 'erro'||vr_aposicao, pr_tag_cont => vr_linhaxml, pr_des_erro => vr_dscritic);
              vr_aposicao := vr_aposicao + 1;
          end;
          begin
            vr_nrnumber := to_number(trim(substr(vr_texto1,27,4)));
            if pr_cdcooper <> 3 then
              open cr_crapcop (vr_nrnumber);
              fetch cr_crapcop into rw_crapcop;
              if cr_crapcop%notfound then
                vr_linhaxml := 'Apenas Cecred pode gerar crítica de cooperativa inválida.';
                gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'linha'||vr_contador, pr_posicao => 0, pr_tag_nova => 'erro'||vr_aposicao, pr_tag_cont => vr_linhaxml, pr_des_erro => vr_dscritic);
                vr_aposicao := vr_aposicao + 1;
              end if;
              close cr_crapcop;
            end if;
          exception
            when others then
              vr_linhaxml := 'Cooperativa não encontrada no sistema(2).';
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'linha'||vr_contador, pr_posicao => 0, pr_tag_nova => 'erro'||vr_aposicao, pr_tag_cont => vr_linhaxml, pr_des_erro => vr_dscritic);
              vr_aposicao := vr_aposicao + 1;
          end;
          begin
            vr_nrdconta := to_number(trim(substr(vr_texto1,31,14)));
          exception
            when others then
              vr_linhaxml := 'Número da conta inválido.';
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'linha'||vr_contador, pr_posicao => 0, pr_tag_nova => 'erro'||vr_aposicao, pr_tag_cont => vr_linhaxml, pr_des_erro => vr_dscritic);
              vr_aposicao := vr_aposicao + 1;
          end;
          begin
            vr_dtmvtolt := to_date(trim(substr(vr_texto1,45,8)),'yyyymmdd');
          exception
            when others then
              vr_linhaxml := 'Data de opção (inclusão/exclusão) inválida.';
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'linha'||vr_contador, pr_posicao => 0, pr_tag_nova => 'erro'||vr_aposicao, pr_tag_cont => vr_linhaxml, pr_des_erro => vr_dscritic);
              vr_aposicao := vr_aposicao + 1;
          end;
          begin
            vr_nrnumber := trim(substr(vr_texto1,150,1));
            if vr_nrnumber not in (1,2) then
              vr_linhaxml := 'Código do movimento inválido(1).';
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'linha'||vr_contador, pr_posicao => 0, pr_tag_nova => 'erro'||vr_aposicao, pr_tag_cont => vr_linhaxml, pr_des_erro => vr_dscritic);
              vr_aposicao := vr_aposicao + 1;
            end if;
          exception
            when others then
              vr_linhaxml := 'Código do movimento inválido(2).';
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'linha'||vr_contador, pr_posicao => 0, pr_tag_nova => 'erro'||vr_aposicao, pr_tag_cont => vr_linhaxml, pr_des_erro => vr_dscritic);
              vr_aposicao := vr_aposicao + 1;
          end;
        elsif substr(vr_texto1,1,1) = 'E' then
          begin
            vr_destexto := length(replace(vr_texto1,chr(13),''));
            if vr_destexto <> 150 then
              vr_linhaxml := 'Número de caracteres incorretos: '||vr_destexto;
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'linha'||vr_contador, pr_posicao => 0, pr_tag_nova => 'erro'||vr_aposicao, pr_tag_cont => vr_linhaxml, pr_des_erro => vr_dscritic);
              vr_aposicao := vr_aposicao + 1;
            end if;
          exception
            when others then
              vr_linhaxml := 'Número de caracteres incorretos.';
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'linha'||vr_contador, pr_posicao => 0, pr_tag_nova => 'erro'||vr_aposicao, pr_tag_cont => vr_linhaxml, pr_des_erro => vr_dscritic);
              vr_aposicao := vr_aposicao + 1;
          end;
          begin
            vr_nrnumber := to_number(trim(substr(vr_texto1,2,25)));
            if vr_nrnumber is null then
              vr_linhaxml := 'Número do documento vazio.';
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'linha'||vr_contador, pr_posicao => 0, pr_tag_nova => 'erro'||vr_aposicao, pr_tag_cont => vr_linhaxml, pr_des_erro => vr_dscritic);
              vr_aposicao := vr_aposicao + 1;
            end if;
          exception
            when others then
              vr_linhaxml := 'Código de referência inválido.';
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'linha'||vr_contador, pr_posicao => 0, pr_tag_nova => 'erro'||vr_aposicao, pr_tag_cont => vr_linhaxml, pr_des_erro => vr_dscritic);
              vr_aposicao := vr_aposicao + 1;
          end;
          begin
            vr_nrnumber := to_number(trim(substr(vr_texto1,27,4)));
            if pr_cdcooper <> 3 and pr_flgcvuni = 0 then
              open cr_crapcop (vr_nrnumber);
              fetch cr_crapcop into rw_crapcop;
              if cr_crapcop%notfound then
                vr_linhaxml := 'Apenas Cecred pode gerar crítica de cooperativa inválida.';
                gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'linha'||vr_contador, pr_posicao => 0, pr_tag_nova => 'erro'||vr_aposicao, pr_tag_cont => vr_linhaxml, pr_des_erro => vr_dscritic);
                vr_aposicao := vr_aposicao + 1;
              end if;
              close cr_crapcop;
            end if;
          exception
            when others then
              vr_linhaxml := 'Código de cooperativa inválido.';
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'linha'||vr_contador, pr_posicao => 0, pr_tag_nova => 'erro'||vr_aposicao, pr_tag_cont => vr_linhaxml, pr_des_erro => vr_dscritic);
              vr_aposicao := vr_aposicao + 1;
          end;
          begin
            vr_nrdconta := to_number(trim(substr(vr_texto1,31,14)));
          exception
            when others then
              vr_linhaxml := 'Número da conta inválido.';
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'linha'||vr_contador, pr_posicao => 0, pr_tag_nova => 'erro'||vr_aposicao, pr_tag_cont => vr_linhaxml, pr_des_erro => vr_dscritic);
              vr_aposicao := vr_aposicao + 1;
          end;
          begin
            vr_dtmvtolt := to_date(trim(substr(vr_texto1,45,8)),'yyyymmdd');
          exception
            when others then
              vr_linhaxml := 'Data de opção (inclusão/exclusão) inválida.';
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'linha'||vr_contador, pr_posicao => 0, pr_tag_nova => 'erro'||vr_aposicao, pr_tag_cont => vr_linhaxml, pr_des_erro => vr_dscritic);
              vr_aposicao := vr_aposicao + 1;
          end;
          begin
            vr_nrnumber := to_number(trim(substr(vr_texto1,53,15)));
            vr_vldebito := vr_vldebito + vr_nrnumber;
          exception
            when others then
              vr_linhaxml := 'Valor do débito inválido.';
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'linha'||vr_contador, pr_posicao => 0, pr_tag_nova => 'erro'||vr_aposicao, pr_tag_cont => vr_linhaxml, pr_des_erro => vr_dscritic);
              vr_aposicao := vr_aposicao + 1;
          end;
          begin
  	        vr_nrnumber := to_number(trim(substr(vr_texto1,68,2)));
            if vr_nrnumber <> 3 then
              vr_linhaxml := 'Código da moeda inválido(1).';
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'linha'||vr_contador, pr_posicao => 0, pr_tag_nova => 'erro'||vr_aposicao, pr_tag_cont => vr_linhaxml, pr_des_erro => vr_dscritic);
              vr_aposicao := vr_aposicao + 1;
            end if;
          exception
            when others then
              vr_linhaxml := 'Código da moeda inválido(2).';
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'linha'||vr_contador, pr_posicao => 0, pr_tag_nova => 'erro'||vr_aposicao, pr_tag_cont => vr_linhaxml, pr_des_erro => vr_dscritic);
              vr_aposicao := vr_aposicao + 1;
          end;
          begin
  	        vr_nrnumber := to_number(trim(substr(vr_texto1,150,1)));
            if vr_nrnumber not in (0,1) then
              vr_linhaxml := 'Código do movimento inválido(1).';
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'linha'||vr_contador, pr_posicao => 0, pr_tag_nova => 'erro'||vr_aposicao, pr_tag_cont => vr_linhaxml, pr_des_erro => vr_dscritic);
              vr_aposicao := vr_aposicao + 1;
            end if;
          exception
            when others then
              vr_linhaxml := 'Código do movimento inválido(2).';
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'linha'||vr_contador, pr_posicao => 0, pr_tag_nova => 'erro'||vr_aposicao, pr_tag_cont => vr_linhaxml, pr_des_erro => vr_dscritic);
              vr_aposicao := vr_aposicao + 1;
          end;
        elsif substr(vr_texto1,1,1) = 'Z' then
          begin
            vr_destexto := length(replace(vr_texto1,chr(13),''));
            if vr_destexto <> 150 then
              vr_linhaxml := 'Número de caracteres incorretos: '||vr_destexto;
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'linha'||vr_contador, pr_posicao => 0, pr_tag_nova => 'erro'||vr_aposicao, pr_tag_cont => vr_linhaxml, pr_des_erro => vr_dscritic);
              vr_aposicao := vr_aposicao + 1;
            end if;
          exception
            when others then
              vr_linhaxml := 'Número de caracteres incorretos.';
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'linha'||vr_contador, pr_posicao => 0, pr_tag_nova => 'erro'||vr_aposicao, pr_tag_cont => vr_linhaxml, pr_des_erro => vr_dscritic);
              vr_aposicao := vr_aposicao + 1;
          end;
          begin
  	        vr_nrnumber := to_number(trim(substr(vr_texto1,2,6)));
            if vr_nrnumber <> vr_contador then
              vr_linhaxml := 'Quantidade de registros inválidas(1).';
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'linha'||vr_contador, pr_posicao => 0, pr_tag_nova => 'erro'||vr_aposicao, pr_tag_cont => vr_linhaxml, pr_des_erro => vr_dscritic);
              vr_aposicao := vr_aposicao + 1;
            end if;
          exception
            when others then
              vr_linhaxml := 'Quantidade de registros inválidas(2).';
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'linha'||vr_contador, pr_posicao => 0, pr_tag_nova => 'erro'||vr_aposicao, pr_tag_cont => vr_linhaxml, pr_des_erro => vr_dscritic);
              vr_aposicao := vr_aposicao + 1;
          end;
          begin
  	        vr_nrnumber := to_number(trim(substr(vr_texto1,8,17)));
            if vr_nrnumber <> vr_vldebito then
              vr_linhaxml := 'Valor total de débitos inválido(1).';
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'linha'||vr_contador, pr_posicao => 0, pr_tag_nova => 'erro'||vr_aposicao, pr_tag_cont => vr_linhaxml, pr_des_erro => vr_dscritic);
              vr_aposicao := vr_aposicao + 1;
            end if;
          exception
            when others then
              vr_linhaxml := 'Valor total de débitos inválido(2).';
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'linha'||vr_contador, pr_posicao => 0, pr_tag_nova => 'erro'||vr_aposicao, pr_tag_cont => vr_linhaxml, pr_des_erro => vr_dscritic);
              vr_aposicao := vr_aposicao + 1;
          end;
        else
          begin
            vr_destexto := length(replace(vr_texto1,chr(13),''));
            if vr_destexto <> 150 then
              vr_linhaxml := 'Número de caracteres incorretos: '||vr_destexto;
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'linha'||vr_contador, pr_posicao => 0, pr_tag_nova => 'erro'||vr_aposicao, pr_tag_cont => vr_linhaxml, pr_des_erro => vr_dscritic);
              vr_aposicao := vr_aposicao + 1;
            end if;
          exception
            when others then
              vr_linhaxml := 'Número de caracteres incorretos.';
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'linha'||vr_contador, pr_posicao => 0, pr_tag_nova => 'erro'||vr_aposicao, pr_tag_cont => vr_linhaxml, pr_des_erro => vr_dscritic);
              vr_aposicao := vr_aposicao + 1;
          end;
          begin
  	        vr_destexto := nvl(trim(substr(vr_texto1,1,1)),'Nulo');
            vr_linhaxml := 'Layout inválido(1): Registro '||vr_destexto;
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'linha'||vr_contador, pr_posicao => 0, pr_tag_nova => 'erro'||vr_aposicao, pr_tag_cont => vr_linhaxml, pr_des_erro => vr_dscritic);
            vr_aposicao := vr_aposicao + 1;
          exception
            when others then
              vr_linhaxml := 'Layout inválido(2): Registro '||vr_destexto;
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'linha'||vr_contador, pr_posicao => 0, pr_tag_nova => 'erro'||vr_aposicao, pr_tag_cont => vr_linhaxml, pr_des_erro => vr_dscritic);
              vr_aposicao := vr_aposicao + 1;
          end;
        end if; 
      end loop;
    exception
      -- Caso chegue ao fim do arquivo
      -- ou esteja vazio, fecha o mesmo
      when no_data_found then
        gene0001.pc_fecha_arquivo(vr_utlfile);
      -- Acontecimento mais comum
      when vr_exc_saida then
        raise vr_exc_saida;
      when others then
        if substr(sqlcode,2,5) = 29282 then
          vr_dscritic := 'Arquivo não encontrado ou com nomes incompatíveis: '||sqlerrm;
        else
          vr_dscritic := 'Erro ao verificar layout: '||sqlerrm;
        end if;
        raise vr_exc_saida;
    end;
 
    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml          --> XML que irá receber o novo atributo
                             ,pr_tag   => 'Dados'             --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'          --> Nome do atributo
                             ,pr_atval => vr_qtregist         --> Valor do atributo
                             ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                               
    --Se ocorreu erro
    if vr_dscritic is not null then
      raise vr_exc_saida;
    end if;  

    -- Limpa o xml caso nao contenha erros
    if instr(xmltype.getClobVal(pr_retxml),'<erro0>') = 0 then
      pr_retxml := null;
    end if;
    
  exception

    when vr_exc_saida then
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

    when others then

      pr_cdcritic := 0;
      pr_dscritic := 'Erro não tratado na rotina TELA_HCONVE.pc_verifica_layout: '||sqlerrm;
      
  end pc_verifica_layout;

  procedure pc_trata_arq_exec (pr_cdcooper       in crapcop.cdcooper%type
                              ,pr_nmarquiv       in varchar2
                              ,pr_dtmvtolt       in crapdat.dtmvtolt%type
                              ,pr_dtmvtopr       in crapdat.dtmvtopr%type
                              ,pr_dtmvtoan       in crapdat.dtmvtoan%type
                              ,pr_dados_futuros out typ_tab_futuros                              
                              ,pr_cdcritic      out pls_integer
                              ,pr_dscritic      out varchar2) is

    ---------------------------------------------------------------------------
    --
    --  Programa : pc_trata_arq_exec
    --  Sistema  : Ayllos Web
    --  Autor    : Gabriel Marcos
    --  Data     : Outubro/2018                Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Objetivo  : Faz o tratamento do arquivo e validacoes para homologacao
    --             
    --
    -- Alteracoes:
    --
    ---------------------------------------------------------------------------

    -- Busca codigo do convenio
    cursor cr_cdconve (pr_nmarquiv in varchar2) is
    select gnc.cdconven
         , gnc.nrcnvfbr
         , gnc.cddbanco
         , gnc.nrlayout
         , gnc.cdhisdeb
         , gnc.nrseqint
      from gnconve gnc
     where upper(gnc.nmarqint) = upper(pr_nmarquiv);
    rw_cdconve cr_cdconve%rowtype;
    
    -- Loop nas cooperativas
    cursor cr_crapcop is
    select cop.cdcooper
      from crapcop cop;
    
    -- Busca sequencial para atualizar gnconve
    cursor cr_gncontr (pr_cdcooper in gncontr.cdcooper%type
                      ,pr_cdconven in gncontr.cdconven%type
                      ,pr_dtmvtolt in gncontr.dtmvtolt%type) is
    select ntr.nrsequen
         , ntr.rowid
      from gncontr ntr
     where ntr.cdcooper = decode(pr_cdcooper,0,ntr.cdcooper,pr_cdcooper)
       and ntr.cdconven = pr_cdconven
       and ntr.dtmvtolt = pr_dtmvtolt
       and ntr.tpdcontr = 3
     order
        by ntr.nrsequen desc;
    rw_gncontr cr_gncontr%rowtype; 
    
    -- Buscar lancamento futuro e fazer limpeza
    cursor cr_craplau (pr_cdcooper in craplau.cdcooper%type
                      ,pr_nrdconta in craplau.nrdconta%type
                      ,pr_nrdocmto in craplau.nrdocmto%type) is
    select lau.idlancto
         , rowid
      from craplau lau
     where lau.cdcooper = pr_cdcooper
       and lau.nrdconta = pr_nrdconta
       and lau.nrdocmto in (pr_nrdocmto,trim(pr_nrdocmto)*10);

    -- Declaracao de variaveis
    vr_index     integer := 0;
    vr_dscritic  varchar2(1000);
    vr_linhaxml  varchar2(100);
    vr_exc_saida exception;
    vr_cdcritic  pls_integer;
    vr_utlfile_alterado utl_file.file_type;
    vr_utlfile          utl_file.file_type;
    vr_nmdireto         varchar2(100);
    vr_texto1           varchar2(4000);
    vr_texto2           varchar2(4000);
    vr_dtmvtolt         date;
    vr_nrdrowid  rowid;
    vr_nrsequen  pls_integer;

  begin

    -- Busca convenio pelo nome do arquivo
    open cr_cdconve (substr(pr_nmarquiv,7,6));
    fetch cr_cdconve into rw_cdconve;
    
    -- Aborta se nao encontrar
    if cr_cdconve%notfound then
      close cr_cdconve;
      vr_dscritic := 'Nome inválido ou convênio não existe.';
      raise vr_exc_saida;
    end if;
    
    close cr_cdconve;

    -- Busca do diretorio base da cooperativa
    vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                        ,pr_cdcooper => pr_cdcooper);
    
    -- Abre arquivo original
    gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto||'/arq',
                             pr_nmarquiv => substr(pr_nmarquiv,7),
                             pr_tipabert => 'R',
                             pr_utlfileh => vr_utlfile,
                             pr_des_erro => vr_dscritic);

    -- Cria arquivo para edicao
    gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto||'/arq',
                             pr_nmarquiv => substr(pr_nmarquiv,7)||'_alterado',
                             pr_tipabert => 'W',
                             pr_utlfileh => vr_utlfile_alterado,
                             pr_des_erro => vr_dscritic);

    begin
      loop
        -- Reescreve arquivo compatibilizando com data do sistema
        gene0001.pc_le_linha_arquivo(vr_utlfile,vr_texto1);
        -- Verifica posicoes de data do arquivo
        if    substr(vr_texto1,1,1) = 'A' then 
          -- Escreve data para pagamento (sistema)
          vr_texto2 := substr(vr_texto1,1,65)||to_char(pr_dtmvtopr,'yyyymmdd')||substr(vr_texto1,74);--vr_texto1;-- substr(vr_texto1,1,65)||to_char(pr_dtmvtopr,'yyyymmdd')||substr(vr_texto1,74);
          gene0001.pc_escr_linha_arquivo(vr_utlfile_alterado,vr_texto2);
        elsif substr(vr_texto1,1,1) = 'E' then
          -- Escreve data para pagamento (sistema)
          vr_texto2 := substr(vr_texto1,1,44)||to_char(pr_dtmvtopr,'yyyymmdd')||substr(vr_texto1,53);--vr_texto1; --substr(vr_texto1,1,44)||to_char(pr_dtmvtopr,'yyyymmdd')||substr(vr_texto1,53);
          gene0001.pc_escr_linha_arquivo(vr_utlfile_alterado,vr_texto2);
          begin
            vr_index := pr_dados_futuros.count + 1;
            -- Popula tabela de memoria
            pr_dados_futuros(vr_index).cdcooper := pr_cdcooper;
            pr_dados_futuros(vr_index).nrdocmto := nvl(to_number(trim(substr(vr_texto1,2,17))),0);
            pr_dados_futuros(vr_index).nrdconta := nvl(to_number(trim(substr(vr_texto1,31,14))),0);
            pr_dados_futuros(vr_index).vllanaut := nvl(to_number(trim(substr(vr_texto1,53,15)))/100,0);
          exception
            when others then
              vr_dscritic := 'Erro ao armazenar pagamentos do arquivo.';
              raise vr_exc_saida;
          end;
        else
          -- Apenas reescreve (tipo nao tratado)
          gene0001.pc_escr_linha_arquivo(vr_utlfile_alterado,vr_texto1);
        end if;
      end loop;
    exception
      -- Caso chegue ao fim do arquivo
      -- ou esteja vazio, fecha o mesmo
      when no_data_found then
        gene0001.pc_fecha_arquivo(vr_utlfile);
        gene0001.pc_fecha_arquivo(vr_utlfile_alterado);
      -- Acontecimento mais comum
      when others then
        if substr(sqlcode,2,5) = 29282 then
          vr_dscritic := 'Nome do arquivo incompatível com sequencial interno: '||sqlerrm;
        else
          vr_dscritic := vr_dscritic||' Erro não tratado na leitura do arquivo: '||sqlerrm;
        end if;
        raise vr_exc_saida;
    end;

    -- Move o arquivo alterado para integra
    -- retirando nomenclatura "_alterado"
    gene0001.pc_oscommand_shell(pr_des_comando => 'mv '||vr_nmdireto||'/arq'||'/'||substr(pr_nmarquiv,7)||'_alterado'|| ' ' ||vr_nmdireto||'/integra'||'/'||substr(pr_nmarquiv,7));

    begin 
      update craplau lau
         set lau.insitlau = 3
       where lau.cdcooper = pr_cdcooper
         and lau.cdhistor = rw_cdconve.cdhisdeb
         and lau.dtmvtopg = pr_dtmvtolt;
    exception
      when others then
        vr_dscritic := 'Erro ao fazer limpeza de lançamentos futuros(3): '||sqlerrm;
        raise vr_exc_saida;
    end;
        
    -- Insere parametros para 388 buscar internamente
    begin
      insert
        into crapprm (nmsistem
                     ,cdcooper
                     ,cdacesso
                     ,dstexprm
                     ,dsvlrprm)
      values        ('CRED'
                     ,pr_cdcooper
                     ,'PRM_HCONVE_CRPS388_IN'
                     ,'Parametro de entrada do Crps388, auxilia na homologacao dos convenios.'
                     ,rw_cdconve.cdconven);
    exception          
      when dup_val_on_index then
        update crapprm prm
           set prm.dsvlrprm = rw_cdconve.cdconven
         where prm.cdcooper = pr_cdcooper
           and prm.cdacesso = 'PRM_HCONVE_CRPS388_IN';
      when others then           
        -- Gerando a critica
        vr_dscritic := 'Erro ao inserir dados na tabela crapprm: '||sqlerrm;
        raise vr_exc_saida;  
    end;
    
    -- Deleta parametros de saida anteriores
    begin
      delete
        from crapprm prm
       where prm.cdcooper = pr_cdcooper
         and prm.nmsistem = 'CRED'
         and prm.cdacesso in ('PRM_HCONVE_CRPS388_OUT',
                              'PRM_HCONVE_CRPS387_OUT',
                              'PRM_HCONVE_CRPS449_OUT');
    exception            
      when others then           
        -- Gerando a critica
        vr_dscritic := 'Erro ao deletar dados da tabela crapprm(2): '||sqlerrm;
        raise vr_exc_saida;
    end;

    -- Faz limpeza na tabela de lancamentos
    begin
      delete
        from craplcm lcm
       where lcm.cdcooper = pr_cdcooper 
         and lcm.cdhistor = rw_cdconve.cdhisdeb
         and lcm.dtmvtolt = pr_dtmvtolt;
    exception
      when others then
        -- Gerando a critica
        vr_dscritic := 'Erro ao deletar dados da tabela craplcm: '||sqlerrm;
        raise vr_exc_saida;
    end;
 
    begin
      -- Fazer limpeza dos registros pendentes
      delete 
        from gncvuni uni
       where uni.cdcooper = pr_cdcooper
         and uni.tpdcontr = 2
         and (uni.flgproce = 0 or
              uni.dtmvtolt = pr_dtmvtolt);  
    exception
      when others then
        vr_dscritic := 'Ao atualizar dados da tabela gncvuni: '||sqlerrm;
        raise vr_exc_saida;
    end; 
    
    begin
      -- Fazer limpeza dos registros pendentes
      delete
        from crapndb ndb
       where ndb.cdcooper = pr_cdcooper
         and ndb.dtmvtolt = pr_dtmvtolt
         and ndb.cdhistor = rw_cdconve.cdhisdeb;
    exception
      when others then
        vr_dscritic := 'Ao atualizar dados da tabela crapndb: '||sqlerrm;
        raise vr_exc_saida;
    end; 

    begin
      -- Fazer limpeza dos registros pendentes
      update crapprm prm
         set prm.dsvlrprm = substr(prm.dsvlrprm,1,length(prm.dsvlrprm)-1)||'3'
       where prm.cdacesso = 'CTRL_DEBNET_EXEC';
    exception
      when others then
        vr_dscritic := 'Ao atualizar dados da tabela crapprm: '||sqlerrm;
        raise vr_exc_saida;
    end; 
    
    -- Busca sequencial para atualizar gnconve
    open cr_gncontr (pr_cdcooper
                    ,rw_cdconve.cdconven
                    ,pr_dtmvtolt);
    fetch cr_gncontr into rw_gncontr;
    
    if cr_gncontr%found then
      begin
        update gncontr ntr
           set ntr.nrsequen = rw_cdconve.nrseqint - 1
         where ntr.rowid    = rw_gncontr.rowid;
      exception
        when others then
          vr_dscritic := 'Ao atualizar dados da tabela gnconve: '||sqlerrm;
          raise vr_exc_saida;
      end;
    else
      begin
        vr_nrsequen := rw_cdconve.nrseqint - 1;
        insert into gncontr
          (cdcooper,
           tpdcontr,
           cdconven,
           dtmvtolt,
           nrsequen,
           flgmigra,
           qtdoctos,
           vldoctos,
           dtcredit,
           nmarquiv,
           vltarifa,
           vlapagar)
         VALUES
          (pr_cdcooper,
           3,
           rw_cdconve.cdconven,
           pr_dtmvtolt,
           vr_nrsequen,
           1,
           0,
           0,
           pr_dtmvtolt,
           pr_nmarquiv,
           0,
           0);
      exception
        when others then
          vr_dscritic := 'Erro ao atualizar gncontr: '||sqlerrm;
          raise vr_exc_saida;
      end;
    end if;
    
    close cr_gncontr;
    
    commit;

  exception

    when vr_exc_saida then
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

    when others then

      pr_cdcritic := 0;
      pr_dscritic := 'Erro não tratado na rotina TELA_HCONVE.pc_trata_arq_exec: '||sqlerrm;
      
  end pc_trata_arq_exec;

  procedure pc_popular_opcao_h (pr_xmllog     in varchar2
                               ,pr_cdcritic  out pls_integer
                               ,pr_dscritic  out varchar2
                               ,pr_retxml in out nocopy XMLType
                               ,pr_nmdcampo  out varchar2    
                               ,pr_des_erro  out varchar2) is

    ---------------------------------------------------------------------------
    --
    --  Programa : pc_popular_opcao_h
    --  Sistema  : Ayllos Web
    --  Autor    : Gabriel Marcos
    --  Data     : Outubro/2018                Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Objetivo  : Popular campos de consulta da Opcao H
    --             
    --
    -- Alteracoes:
    --
    ---------------------------------------------------------------------------
      
    -- Loop na tabela de historicos   
    cursor cr_craphis (pr_cdhistor in craphis.cdhistor%type) is
    select 1
      from craphis his
     where his.cdhistor = pr_cdhistor;
    rw_craphis cr_craphis%rowtype;
    
    -- Loop na tabela de historicos   
    cursor cr_crapthi (pr_cdhistor in crapthi.cdhistor%type) is
    select 1
                         from crapthi thi
     where thi.cdhistor = pr_cdhistor;
    rw_crapthi cr_crapthi%rowtype;
        
    -- Loop na tabela de convenios   
    cursor cr_gnconve IS
    select MAX(gnc.cdconven) cdconven
      from gnconve gnc;
    rw_gnconve cr_gnconve%rowtype;
    
    -- Declaracao de variaveis
    vr_contador number := 0;
    vr_flgfinal boolean := true;
    vr_cdhisto1 number;
    vr_cdhisto2 number;
    vr_cdconven number;
    i           integer := 1;
    
    -- Variaveis padrao                            
    vr_nmdatela  varchar2(100);                                  
    vr_nmeacao   varchar2(100);                                  
    vr_cdagenci  varchar2(100);                                  
    vr_nrdcaixa  varchar2(100);                                  
    vr_idorigem  varchar2(100);                                  
    vr_cdoperad  varchar2(100);  
    vr_dscritic  varchar2(10000);  
    vr_cdcritic  pls_integer;
    vr_cdcooper  integer;  
    vr_exc_saida exception;
    vr_cdhistor  craphis.cdhistor%TYPE;

  begin
    
    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'HCONVE'
                              ,pr_action => null); 

    -- Extrai cooperativa do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Aborta em caso de erro
    if trim(vr_dscritic) is not null then
      raise vr_exc_saida;
    end if;

    -- Telas que utilizarao os historicos
    -- so permitem 4 digitos nos campos de historicos
    for i in 1 .. 9999 loop

    -- Busca historico na tabela craphis
      open cr_craphis (i);
    fetch cr_craphis into rw_craphis;
      
    if cr_craphis%notfound then
      
        -- Buscar historico
        open cr_crapthi (i);
        fetch cr_crapthi into rw_crapthi;
          
        -- Caso nao encontre popula
        if cr_crapthi%notfound then
          if vr_cdhisto1 is not null then
            vr_cdhisto2 := i;
            close cr_crapthi;
            close cr_craphis;
            exit;
    end if;
          vr_cdhisto1 := i;
        end if;

        close cr_crapthi;

      end if;
      
      close cr_craphis;
    
    end loop;
    
    -- Busca historico na tabela craphis
    open cr_gnconve;
    fetch cr_gnconve into rw_gnconve;
      
    -- Caso nao encontre o historico esta disponivel
    if cr_gnconve%notfound then
      close cr_gnconve;
      vr_dscritic := 'Erro ao buscar convênio disponível.';
      raise vr_exc_saida;
    end if;
      
    vr_cdconven := rw_gnconve.cdconven + 1;
    close cr_gnconve;
   
    -- Aborta caso loop nao retorne dados
    if vr_cdhisto1 is null or vr_cdhisto2 is null then
      vr_dscritic := 'Erro ao buscar históricos disponíveis.';
      raise vr_exc_saida;
    end if;
    
    -- Aborta caso loop nao retorne dados
    if vr_cdconven is null then
      vr_dscritic := 'Erro ao buscar convênios disponíveis.';
      raise vr_exc_saida;
    end if;

    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root',  pr_posicao => 0, pr_tag_nova => 'Dados',    pr_tag_cont => NULL,        pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'param',    pr_tag_cont => NULL,        pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'cdhisto1', pr_tag_cont => vr_cdhisto1, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'cdhisto2', pr_tag_cont => vr_cdhisto2, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'cdconven', pr_tag_cont => vr_cdconven, pr_des_erro => vr_dscritic);                           

    pr_des_erro := 'OK';

  exception

    when vr_exc_saida then

      if vr_cdcritic <> 0 then
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      else
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      end if;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      rollback;
        
    when others then

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela TELA_HCONVE.pc_popular_opcao_h: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      rollback;
        
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper);

  end pc_popular_opcao_h;

  procedure pc_hist_lupa_opcao_h (pr_cdhistor   IN craphis.cdhistor%TYPE
                                 ,pr_dsexthst   IN craphis.dsexthst%TYPE
                                 ,pr_nrregist   in integer                                 
                                 ,pr_nriniseq   in integer      
                                 ,pr_xmllog     in varchar2
                                 ,pr_cdcritic  out pls_integer
                                 ,pr_dscritic  out varchar2
                                 ,pr_retxml in out nocopy XMLType
                                 ,pr_nmdcampo  out varchar2    
                                 ,pr_des_erro  out varchar2) is
 
    ---------------------------------------------------------------------------
    --
    --  Programa : pc_hist_lupa_opcao_h
    --  Sistema  : Ayllos Web
    --  Autor    : Gabriel Marcos
    --  Data     : Outubro/2018                Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Objetivo  : Popular pop-up (lupa) de historicos
    --             
    --
    -- Alteracoes:
    --
    ---------------------------------------------------------------------------
      
    -- Loop na tabela de historicos   
    cursor cr_craphis (pr_cdcooper in craphis.cdcooper%TYPE 
                      ,pr_cdhistor IN craphis.cdhistor%TYPE
                      ,pr_dsexthst IN craphis.dsexthst%TYPE) is
    select his.cdhistor
         , his.dshistor
         , his.dsexthst
      from craphis his
     where his.cdcooper = pr_cdcooper
       and his.nmestrut in ('CRAPLCM','CRAPLFT')
       and his.indebcre = 'D'
       AND his.cdhistor = decode(nvl(pr_cdhistor,0),0,his.cdhistor,pr_cdhistor)
       AND (TRIM(pr_dsexthst) IS NULL
        OR upper(his.dsexthst) LIKE '%'|| upper(pr_dsexthst) ||'%')
     order
        by his.cdhistor;
    rw_craphis cr_craphis%rowtype;

    -- Declaracao de variaveis
    vr_contador number := 0;

    -- Variaveis padrao                            
    vr_nmdatela  varchar2(100);                                  
    vr_nmeacao   varchar2(100);                                  
    vr_cdagenci  varchar2(100);                                  
    vr_nrdcaixa  varchar2(100);                                  
    vr_idorigem  varchar2(100);                                  
    vr_cdoperad  varchar2(100);  
    vr_flsucess  boolean := false;
    vr_dscritic  varchar2(10000);  
    vr_cdcritic  pls_integer;
    vr_cdcooper  integer;  
    vr_exc_saida exception;
    
    vr_nrregist INTEGER := nvl(pr_nrregist,9999);
    vr_qtregist integer := 0; 

  begin

    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'HCONVE'
                              ,pr_action => null); 

    -- Extrai cooperativa do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Aborta em caso de erro
    if trim(vr_dscritic) is not null then
      raise vr_exc_saida;
    end if;

    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root',  pr_posicao => 0, pr_tag_nova => 'Dados',    pr_tag_cont => NULL,        pr_des_erro => vr_dscritic);

    -- Varre historicos existentes
    for rw_craphis in cr_craphis (pr_cdcooper => vr_cdcooper
                                 ,pr_cdhistor => pr_cdhistor
                                 ,pr_dsexthst => pr_dsexthst) loop
      
      vr_flsucess := true;
    
      --Incrementar Quantidade Registros do Parametro
      vr_qtregist:= nvl(vr_qtregist,0) + 1;
              
      -- Controles da paginacao
      if (vr_qtregist < pr_nriniseq) or
         (vr_qtregist > (pr_nriniseq + pr_nrregist)) then
        --Proximo Titular
        continue;
      end if; 
      
            --Numero Registros
      if vr_nrregist > 0 then

        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'param', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => vr_contador, pr_tag_nova => 'cdhistor', pr_tag_cont => rw_craphis.cdhistor, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => vr_contador, pr_tag_nova => 'dshistor', pr_tag_cont => rw_craphis.dshistor, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => vr_contador, pr_tag_nova => 'dsexthst', pr_tag_cont => rw_craphis.dsexthst, pr_des_erro => vr_dscritic);
        
        vr_contador := vr_contador + 1;
        
      end if;
      
    end loop;
    
    -- Aborta caso não encontre um histórico
    if not vr_flsucess then
      vr_dscritic := 'Histórico não encontrado.';
      raise vr_exc_saida;
    end if;
    
    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml 
                             ,pr_tag   => 'Dados'             
                             ,pr_atrib => 'qtregist'       
                             ,pr_atval => vr_qtregist        
                             ,pr_numva => 0                  
                             ,pr_des_erro => vr_dscritic);  

    pr_des_erro := 'OK';

  exception

    when vr_exc_saida then

      if vr_cdcritic <> 0 then
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      else
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      end if;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      rollback;
        
    when others then

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela TELA_HCONVE.pc_hist_lupa_opcao_h: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      rollback;
        
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper);

  end pc_hist_lupa_opcao_h;

  procedure pc_criar_historico_web (pr_hisconv1   in craphis.cdhistor%type
                                   ,pr_hisrefe1   in craphis.cdhistor%type
                                   ,pr_nmabrev1   in craphis.dshistor%type
                                   ,pr_nmexten1   in craphis.dsexthst%type 
                                   ,pr_hisconv2   in craphis.cdhistor%type
                                   ,pr_hisrefe2   in craphis.cdhistor%type
                                   ,pr_nmabrev2   in craphis.dshistor%type
                                   ,pr_nmexten2   in craphis.dsexthst%type
                                   ,pr_xmllog     in varchar2
                                   ,pr_cdcritic  out pls_integer
                                   ,pr_dscritic  out varchar2
                                   ,pr_retxml in out nocopy XMLType
                                   ,pr_nmdcampo  out varchar2    
                                   ,pr_des_erro  out varchar2) is

    ---------------------------------------------------------------------------
    --
    --  Programa : pc_criar_historico_web
    --  Sistema  : Ayllos Web
    --  Autor    : Gabriel Marcos
    --  Data     : Outubro/2018                Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Objetivo  : Fazer verificacoes de variaveis para criacao de historico
    --             
    --
    -- Alteracoes:
    --
    ---------------------------------------------------------------------------

    -- Analisa se historico de refencia existe
    cursor cr_craphis (pr_cdhistor in craphis.cdhistor%type) is
    select 1
      from craphis his
     where his.nmestrut in ('CRAPLCM','CRAPLFT')
       and his.indebcre = 'D'
       and his.cdhistor = pr_cdhistor;
        
    rw_craphis cr_craphis%rowtype;

    -- Declaracao de variaveis
    vr_database  varchar2(100);
    vr_nmabrev1 varchar2(100) := trim(upper(pr_nmabrev1));
    vr_nmexten1 varchar2(100) := trim(upper(pr_nmexten1));
    vr_nmabrev2 varchar2(100) := trim(upper(pr_nmabrev2));
    vr_nmexten2 varchar2(100) := trim(upper(pr_nmexten2));
    
    -- Variaveis padrao                            
    vr_nmdatela  varchar2(100);                                  
    vr_nmeacao   varchar2(100);                                  
    vr_cdagenci  varchar2(100);                                  
    vr_nrdcaixa  varchar2(100);                                  
    vr_idorigem  varchar2(100);                                  
    vr_cdoperad  varchar2(100);  
    vr_dscritic  varchar2(10000);  
    vr_cdcritic  pls_integer;
    vr_cdcooper  integer;  
    vr_exc_saida exception;

  begin

    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'HCONVE'
                              ,pr_action => null); 

    -- Extrai cooperativa do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Aborta em caso de erro
    if trim(vr_dscritic) is not null then
      raise vr_exc_saida;
    end if;

    -- Busca ambiente conectado
    vr_database := GENE0001.fn_database_name;
    
    -- Somente d2 e d3 sao permitidos
    if vr_database not in ('AILOSD2','AILOSD3','AYLLOSL') then
      vr_dscritic := 'Ambiente não permite esta operação.';
      raise vr_exc_saida;
    end if;
    
    if nvl(pr_hisconv1,0) = 0 and
       nvl(pr_hisconv2,0) = 0 then
      vr_dscritic := 'Histórico sugerido deve ser informado.';
      pr_nmdcampo := 'cdhistsug1';
      raise vr_exc_saida;
    elsif nvl(pr_hisconv1,0) > 0    and
          nvl(pr_hisconv2,0) > 0    and
          pr_hisconv1 = pr_hisconv2 then
      vr_dscritic := 'Histórico devem ser diferentes.';
      pr_nmdcampo := 'cdhistsug1';
      raise vr_exc_saida;
    end if;
      
    -- Tratamento de variaveis de debito convencional
    -- Se algum dos parametros passados estiver
    -- preenchido, todos os outros devem ser informados
    if nvl(pr_hisconv1,0) <> 0 or
       nvl(pr_hisrefe1,0) <> 0 or
       vr_nmabrev1 is not null or
       vr_nmexten1 is not null then
    
      -- Aborta se alguma variavel for nula 
      if    nvl(pr_hisconv1,0) = 0 then
        vr_dscritic := 'Arrecadação: histórico sugerido deve ser informado.';
        pr_nmdcampo := 'cdhistsug1';
        raise vr_exc_saida;
      elsif nvl(pr_hisrefe1,0) = 0 then
        vr_dscritic := 'Arrecadação: histórico de referência deve ser informado.';
        pr_nmdcampo := 'cdhistor1';
        raise vr_exc_saida;
      elsif vr_nmabrev1 is null then
        vr_dscritic := 'Arrecadação: nome abreviado deve ser informado.';
        pr_nmdcampo := 'nmabrevia1';
        raise vr_exc_saida;
      elsif vr_nmexten1 is null then
        vr_dscritic := 'Arrecadação: nome por extenso deve ser informado.';
        pr_nmdcampo := 'nmextenso1';
        raise vr_exc_saida;
      end if;
      
      -- Verifica se historico de ref. existe
      open cr_craphis (pr_hisrefe1);
      fetch cr_craphis into rw_craphis;
      
      -- Aborta se nao encontrar
      if cr_craphis%notfound then
        close cr_craphis;
        vr_dscritic := 'Arrecadação: histórico de referência não existe.';
        pr_nmdcampo := 'cdhistor1';
        raise vr_exc_saida;
      end if;
      
      close cr_craphis;
      
      -- Criar historico para o debito convencional
      pc_criar_historico (pr_cdhisnov => pr_hisconv1
                         ,pr_cdhisref => pr_hisrefe1
                         ,pr_nomabrev => vr_nmabrev1
                         ,pr_nmextens => vr_nmexten1
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);
                         
      if nvl(vr_cdcritic,0) > 0 or trim(vr_dscritic) is not null then
        raise vr_exc_saida;
      end if;
      
    end if;

    -- Tratamento de variaveis de debito automatico
    -- Se algum dos parametros passados estiver
    -- preenchido, todos os outros devem ser informados
    if nvl(pr_hisconv2,0) <> 0 or
       nvl(pr_hisrefe2,0) <> 0 or
       vr_nmabrev2 is not null or
       vr_nmexten2 is not null then
    
      -- Aborta se alguma variavel for nula 
      if nvl(pr_hisconv2,0) = 0 then
        vr_dscritic := 'Débito automático: histórico sugerido deve ser informado.';
        pr_nmdcampo := 'cdhistsug2';
        raise vr_exc_saida;
      elsif nvl(pr_hisrefe2,0) = 0 then
        vr_dscritic := 'Débito automático: histórico de referência deve ser informado.';
        pr_nmdcampo := 'cdhistor2';
        raise vr_exc_saida;
      elsif vr_nmabrev2 is null then
        vr_dscritic := 'Débito automático: nome abreviado deve ser informado.';
        pr_nmdcampo := 'nmabrevia2';
        raise vr_exc_saida;
      elsif vr_nmexten2 is null then
        vr_dscritic := 'Débito automático: nome por extenso deve ser informado.';
        pr_nmdcampo := 'nmextenso2';
        raise vr_exc_saida;
      end if;
      
      -- Verifica se historico de ref. existe
      open cr_craphis (pr_hisrefe2);
      fetch cr_craphis into rw_craphis;
      
      -- Aborta se nao encontrar
      if cr_craphis%notfound then
        close cr_craphis;
        vr_dscritic := 'Débito automático: histórico de referência não existe.';
        pr_nmdcampo := 'cdhistor2';
        raise vr_exc_saida;
      end if;
      
      close cr_craphis;
      
      -- Criar historico para o debito convencional
      pc_criar_historico (pr_cdhisnov => pr_hisconv2
                         ,pr_cdhisref => pr_hisrefe2
                         ,pr_nomabrev => vr_nmabrev2
                         ,pr_nmextens => vr_nmexten2
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);
                         
      if nvl(vr_cdcritic,0) > 0 or trim(vr_dscritic) is not null then
        raise vr_exc_saida;
      end if;
      
    end if;

    pr_des_erro := 'OK';

  exception

    when vr_exc_saida then

      if vr_cdcritic <> 0 then
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      else
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      end if;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      rollback;
        
    when others then

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela TELA_HCONVE.pc_criar_historico_web: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      rollback;
        
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper);

  end pc_criar_historico_web;

  procedure pc_criar_historico (pr_cdhisnov  in craphis.cdhistor%type
                               ,pr_cdhisref  in craphis.cdhistor%type
                               ,pr_nomabrev  in craphis.dshistor%type
                               ,pr_nmextens  in craphis.dsexthst%type 
                               ,pr_cdcritic out pls_integer
                               ,pr_dscritic out varchar2) is

    ---------------------------------------------------------------------------
    --
    --  Programa : pc_criar_historico
    --  Sistema  : Ayllos Web
    --  Autor    : Gabriel Marcos
    --  Data     : Outubro/2018                Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Objetivo  : Receber chamada web do botao criar da opcao h
    --             
    --
    -- Alteracoes:
    --
    ---------------------------------------------------------------------------
        
    -- Busca dados das cooperativas ativas
    cursor cr_crapcop is
    select cop.cdcooper
      from crapcop cop
     where cop.flgativo = 1
     order
        by cop.cdcooper;

    -- Busca dados da tabela de tarifas
    cursor cr_crapthi (pr_cdcooper in crapthi.cdcooper%type
                      ,pr_cdhistor in crapthi.cdhistor%type) is
    select thi.dsorigem
         , thi.vltarifa
         , thi.cdcooper
         , thi.cdhistor
         , count(*) over (partition by thi.cdcooper) qtdregis
      from crapthi thi
     where thi.cdcooper = pr_cdcooper
       and thi.cdhistor = pr_cdhistor;
    rw_crapthi cr_crapthi%rowtype;
    
    -- Buscar parametros para base de novo registro
    cursor cr_craphis (pr_cdcooper in craphis.cdcooper%type
                      ,pr_cdhistor in craphis.cdhistor%type) is
    select his.*
      from craphis his
     where his.cdcooper = pr_cdcooper
       and his.cdhistor = pr_cdhistor;
    rw_craphis cr_craphis%rowtype;
       
    -- Declaracao de variaveis
    vr_flgparam  boolean;
    vr_dscritic  varchar2(1000);
    vr_cdcritic  pls_integer;
    vr_exc_saida exception;

  begin

    -- Loop nas cooperativas ativas
    for rw_crapcop in cr_crapcop loop
    
      -- Limpeza de variaveis 
      vr_flgparam := null;
    
      -- Busca historicos na tabela de tarifas
      for rw_crapthi in cr_crapthi (rw_crapcop.cdcooper
                                   ,pr_cdhisref) loop
      
        -- Analisa resultados encontrados
        if rw_crapthi.qtdregis <> 4 then
          vr_dscritic := 'Erro ao buscar dados do histórico escolhido como referência(1): hist '||pr_cdhisref||' - ori '||rw_crapthi.dsorigem||' - '||sqlerrm;
          raise vr_exc_saida;
        elsif vr_flgparam is null and rw_crapthi.qtdregis = 4 then
          vr_flgparam := true;  
        end if;
        
        begin
          -- Insere dados para o novo historico parametrizado
          insert 
            into crapthi thi (cdhistor, dsorigem, vltarifa, cdcooper)
          values (pr_cdhisnov, rw_crapthi.dsorigem, rw_crapthi.vltarifa, rw_crapthi.cdcooper);
        exception
          when dup_val_on_index then
            vr_dscritic := 'Registros duplicados não são permitidos, histórico '||pr_cdhisnov||' já existe.';
            raise vr_exc_saida;
          when others then
            vr_dscritic := 'Erro ao inserir dados na tabela de tarifas: hist'||pr_cdhisnov||' - ori '||rw_crapthi.dsorigem||' - '||sqlerrm;
            raise vr_exc_saida;
        end;
        
      end loop;
      
      -- Aborta caso nao respeite a regra do loop
      if vr_flgparam is null then
        vr_dscritic := 'Erro ao buscar dados do histórico escolhido como referência(1): '||sqlerrm;
        raise vr_exc_saida;
      end if;
      
      -- Busca parametros de base para criar novo historico
      open cr_craphis (rw_crapcop.cdcooper
                      ,pr_cdhisref);
      fetch cr_craphis into rw_craphis;
      
      -- Aborta caso nao encontre
      if cr_craphis%notfound then
        vr_dscritic := 'Histórico de referência não encontrado na tabela de históricos.';
        raise vr_exc_saida;
      end if;
      
      begin
        -- Insere dados para o novo historico parametrizado   
        insert 
          into craphis (cdhistor               --00
                      , dshistor
                      , inhistor
                      , indebcre
                      , tplotmov
                      , indoipmf
                      , txdoipmf
                      , inautori
                      , inavisar
                      , indebcta               --10
                      , indebfol               
                      , inclasse               
                      , dsexthst               
                      , cdhstctb               
                      , nrctadeb               
                      , nrctacrd               
                      , tpctbccu               
                      , tpctbcxa               
                      , nmestrut               --20
                      , incremes               
                      , nrctatrd               
                      , nrctatrc               
                      , indcompl               
                      , ingerdeb               
                      , ingercre               
                      , cdcooper               
                      , flgsenha               
                      , cdprodut               --30
                      , cdagrupa               
                      , dsextrat               
                      , cdhisest               
                      , indcalem               
                      , indcalcc               
                      , cdtrscyb               
                      , inmonpld               
                      , cdgrphis               
                      , inestoura_conta        --40
                      , idmonpld
                      , indutblq
                      , inperdes
                      , indebprj
                      , intransf_cred_prejuizo 
                      , indcalds)              --46
               values ( pr_cdhisnov                        --00
                      , pr_nmextens                        
                      , rw_craphis.inhistor                
                      , rw_craphis.indebcre                
                      , rw_craphis.tplotmov                
                      , rw_craphis.indoipmf                
                      , rw_craphis.txdoipmf                
                      , rw_craphis.inautori                
                      , rw_craphis.inavisar                
                      , rw_craphis.indebcta                --10
                      , rw_craphis.indebfol                
                      , rw_craphis.inclasse                
                      , pr_nmextens                     
                      , rw_craphis.cdhstctb                
                      , rw_craphis.nrctadeb                
                      , rw_craphis.nrctacrd                
                      , rw_craphis.tpctbccu                
                      , rw_craphis.tpctbcxa                
                      , rw_craphis.nmestrut                --20
                      , rw_craphis.incremes                
                      , rw_craphis.nrctatrd                
                      , rw_craphis.nrctatrc                
                      , rw_craphis.indcompl                
                      , rw_craphis.ingerdeb                
                      , rw_craphis.ingercre                
                      , rw_craphis.cdcooper                
                      , rw_craphis.flgsenha                
                      , rw_craphis.cdprodut                --30
                      , rw_craphis.cdagrupa                
                      , pr_nomabrev                
                      , rw_craphis.cdhisest                
                      , rw_craphis.indcalem                
                      , rw_craphis.indcalcc                
                      , rw_craphis.cdtrscyb                
                      , rw_craphis.inmonpld                
                      , rw_craphis.cdgrphis                
                      , rw_craphis.inestoura_conta         --40
                      , rw_craphis.idmonpld                
                      , rw_craphis.indutblq                
                      , rw_craphis.inperdes                
                      , rw_craphis.indebprj                
                      , rw_craphis.intransf_cred_prejuizo  
                      , rw_craphis.indcalds);              --46
      exception
        when dup_val_on_index then
          vr_dscritic := 'Registros duplicados não são permitidos(2): hist '||rw_crapthi.cdhistor||' - ori '||rw_crapthi.dsorigem||' - '||sqlerrm;
          raise vr_exc_saida;
        when others then
          vr_dscritic := 'Erro ao inserir dados na tabela de históricos: hist'||pr_cdhisnov||' - '||sqlerrm;
          raise vr_exc_saida;
      end;
      
      close cr_craphis;

    end loop;

  exception

    when vr_exc_saida then

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

    when others then

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela TELA_HCONVE.pc_criar_historico: hist '||pr_cdhisref||' - '||sqlerrm;

  end pc_criar_historico;
  
  PROCEDURE pc_busca_convenio (pr_cdconven   IN gnconve.cdconven%TYPE -- Codigo do convenio
                              ,pr_nmempres   IN gnconve.nmempres%TYPE -- Nome da empresa do convenio
                              ,pr_nrregist   IN INTEGER               -- Quantidade de registros                            
                              ,pr_nriniseq   IN INTEGER               -- Qunatidade inicial
                              ,pr_xmllog     IN VARCHAR2              -- XML com informacoes de LOG
                              ,pr_cdcritic  OUT PLS_INTEGER           -- Codigo da critica
                              ,pr_dscritic  OUT VARCHAR2              -- Descricao da critica
                              ,pr_retxml IN OUT NOCOPY XMLType        -- Arquivo de retorno do XML
                              ,pr_nmdcampo  OUT VARCHAR2              -- Nome do Campo
                              ,pr_des_erro  OUT VARCHAR2) IS          -- Saida OK/NOK

  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_convenio
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Jonata - Mouts
    Data     : Novembro/2018                          Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo  : Pesquisa de convenios.
    
    Alteracoes: 
    -------------------------------------------------------------------------------------------------------------*/

    -- Buscar convenios Bancoob
    CURSOR cr_convenio( pr_cdcooper  IN gnconve.cdcooper%TYPE
                       ,pr_cdconven  IN gnconve.cdconven%TYPE
                       ,pr_nmempres  IN gnconve.nmempres%TYPE) IS
      SELECT b.cdconven
            ,b.nmempres
            ,b.flgcvuni
        FROM gnconve b              
       WHERE b.cdcooper in (3,pr_cdcooper)
         AND ( pr_nmempres IS NULL OR 
               upper(b.nmempres) LIKE '%'||upper(pr_nmempres)||'%'
             )
         AND (nvl(pr_cdconven,'0') = '0' OR  
              b.cdconven = pr_cdconven
              )
       ORDER BY b.cdconven;

    -- Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    -- Variaveis Locais
    vr_qtregist INTEGER := 0;   
    vr_clob     CLOB;   
    vr_xml_temp VARCHAR2(32726) := '';
    vr_nrregist INTEGER := nvl(pr_nrregist,1);
        
    -- Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;      
  
  
  BEGIN
    -- Incluir nome do modulo logado
    GENE0001.pc_informa_acesso(pr_module => 'pc_busca_convenio'
                              ,pr_action => NULL);
                              
    -- Inicializar Variaveis
    vr_cdcritic := 0;                         
    vr_dscritic := NULL;
      
    -- Extrai dados do XML
    GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
                            
    -- Se houve erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    -- Monta documento XML de ERRO
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);                                          
      
    -- Criar cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><convenios>');
      
    
    -- Buscar convenios
    FOR rw_convenio IN  cr_convenio(  pr_cdcooper  => vr_cdcooper
                                     ,pr_cdconven  => pr_cdconven
                                     ,pr_nmempres  => pr_nmempres) LOOP

      vr_qtregist := nvl(vr_qtregist,0) + 1;

      -- controles da paginacao
      IF (vr_qtregist < pr_nriniseq) OR
         (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
         -- Proximo
         CONTINUE;
      END IF;

      -- Numero Registros
      IF vr_nrregist > 0 THEN
        
        -- Carrega os dados           
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<convenio>'||
                                                       '<cdconven>'||  rw_convenio.cdconven ||'</cdconven>'||
                                                       '<nmempres>'||  rw_convenio.nmempres ||'</nmempres>'||
                                                       '<flgcvuni>'||  rw_convenio.flgcvuni ||'</flgcvuni>'||
                                                     '</convenio>');
      END IF;

      -- Diminuir registros
      vr_nrregist:= nvl(vr_nrregist,0) - 1;

    END LOOP;
      
    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</convenios></Root>'
                           ,pr_fecha_xml      => TRUE);

    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clob);

    -- Insere atributo na tag banco com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml        --> XML que ira receber o novo atributo
                             ,pr_tag   => 'convenios'      --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'       --> Nome do atributo
                             ,pr_atval => vr_qtregist      --> Valor do atributo
                             ,pr_numva => 0                --> Numero da localizacao da TAG na arvore XML
                             ,pr_des_erro => vr_dscritic); --> Descricao de erros

    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);  

    -- Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF; 

    -- Retorno
    pr_des_erro := 'OK'; 

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno nao OK          
      pr_des_erro := 'NOK';
        
      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
        
      -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                                                            
    WHEN OTHERS THEN
      -- Retorno nao OK
      pr_des_erro := 'NOK';
        
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na pc_busca_convenio --> '|| SQLERRM;
        
      -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
  
  END pc_busca_convenio;   

END TELA_HCONVE;
/