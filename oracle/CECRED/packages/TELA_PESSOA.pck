CREATE OR REPLACE PACKAGE CECRED.TELA_PESSOA IS

  procedure pc_buscar_cooperado (pr_nrdconta   in crapass.nrdconta%type
                                ,pr_nrregist   in integer                             
                                ,pr_nriniseq   in integer      
                                ,pr_xmllog     in varchar2
                                ,pr_cdcritic  out pls_integer
                                ,pr_dscritic  out varchar2
                                ,pr_retxml in out nocopy XMLType
                                ,pr_nmdcampo  out varchar2    
                                ,pr_des_erro  out varchar2);
                                
  procedure pc_mostra_cargos (pr_xmllog     in varchar2              
                             ,pr_cdcritic  out pls_integer          
                             ,pr_dscritic  out varchar2             
                             ,pr_retxml in out nocopy xmltype    
                             ,pr_nmdcampo  out varchar2             
                             ,pr_des_erro  out varchar2);           
                             
  procedure pc_inserir_cargos_web (pr_nrcpfcgc          in crapass.nrcpfcgc%type
                                  ,pr_cdfuncao          in crapass.tpvincul%type
                                  ,pr_dtinicio_vigencia in varchar2
                                  ,pr_xmllog            in varchar2
                                  ,pr_cdcritic         out pls_integer
                                  ,pr_dscritic         out varchar2
                                  ,pr_retxml        in out nocopy XMLType
                                  ,pr_nmdcampo         out varchar2    
                                  ,pr_des_erro         out varchar2);
                             
  procedure pc_inserir_cargos (pr_cdcooper          in crapass.cdcooper%type
                              ,pr_nrcpfcgc          in crapass.nrcpfcgc%type
                              ,pr_cdfuncao          in crapass.tpvincul%type
                              ,pr_dtinicio_vigencia in varchar2
                              ,pr_cdoperad          in crapope.cdoperad%type
                              ,pr_cdcritic         out pls_integer
                              ,pr_dscritic         out varchar2);
             
  procedure pc_excluir_cargos_web (pr_nrcpfcgc   in crapass.nrcpfcgc%type
                                  ,pr_cdfuncao   in crapass.tpvincul%type
                                  ,pr_nrdrowid   in rowid
                                  ,pr_xmllog     in varchar2
                                  ,pr_cdcritic  out pls_integer
                                  ,pr_dscritic  out varchar2
                                  ,pr_retxml in out nocopy XMLType
                                  ,pr_nmdcampo  out varchar2    
                                  ,pr_des_erro  out varchar2);
                   
  procedure pc_excluir_cargos (pr_cdcooper   in crapass.cdcooper%type
                              ,pr_nrcpfcgc   in crapass.nrcpfcgc%type
                              ,pr_cdfuncao   in crapass.tpvincul%type
                              ,pr_nrdrowid   in rowid
                              ,pr_cdoperad   in crapope.cdoperad%type
                              ,pr_cdcritic  out pls_integer
                              ,pr_dscritic  out varchar2);
                
  procedure pc_inativa_cargos_web (pr_nrcpfcgc          in crapass.nrcpfcgc%type
                                  ,pr_dtinicio_vigencia in varchar2
                                  ,pr_dtfim_vigencia    in varchar2
                                  ,pr_cdfuncao          in crapass.tpvincul%type
                                  ,pr_nrdrowid          in rowid
                                  ,pr_xmllog            in varchar2
                                  ,pr_cdcritic         out pls_integer
                                  ,pr_dscritic         out varchar2
                                  ,pr_retxml        in out nocopy XMLType
                                  ,pr_nmdcampo         out varchar2    
                                  ,pr_des_erro         out varchar2);

  procedure pc_inativa_cargos (pr_cdcooper          in crapass.cdcooper%type
                              ,pr_nrcpfcgc          in crapass.nrcpfcgc%type
                              ,pr_cdfuncao          in crapass.tpvincul%type
                              ,pr_dtinicio_vigencia in date
                              ,pr_dtfim_vigencia    in date
                              ,pr_nrdrowid          in rowid
                              ,pr_cdoperad          in crapope.cdoperad%type
                              ,pr_cdcritic         out pls_integer
                              ,pr_dscritic         out varchar2);
                              
  procedure pc_pessoa_progress (pr_cdcooper  in crapass.cdcooper%type
                               ,pr_nrdconta  in crapass.nrdconta%type
                               ,pr_cdfuncao  in crapass.tpvincul%type
                               ,pr_cdoperad  in crapope.cdoperad%type
                               ,pr_cdcritic out pls_integer
                               ,pr_dscritic out varchar2);             
                              
  procedure pc_alterar_pessoa (pr_nrdconta   in crapass.nrdconta%type
                              ,pr_inpessoa   in crapass.inpessoa%type
                              ,pr_xmllog     in varchar2
                              ,pr_cdcritic  out pls_integer
                              ,pr_dscritic  out varchar2
                              ,pr_retxml in out nocopy XMLType
                              ,pr_nmdcampo  out varchar2    
                              ,pr_des_erro  out varchar2);   
                              

  procedure pc_historico_tpvinculo (pr_cdcooper  in crapass.nrdconta%type
                                   ,pr_nrcpfcgc  in crapass.nrcpfcgc%type
                                   ,pr_tpvincul  in crapass.tpvincul%type
                                   ,pr_dscritic out varchar2);
                                                                      
END TELA_PESSOA;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_PESSOA IS

  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_PESSOA
  --  Sistema  : Ayllos Web
  --  Autor    : Gabriel Marcos
  --  Data     : Agosto/2018                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas a tela PESSOA
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

  -- Verifica permissoes do operador
  cursor cr_cdoperad (pr_cdcooper in crapope.cdcooper%type
                     ,pr_cdoperad in crapope.cdoperad%type) is
  select ope.cddepart
    from crapope ope
       , crapace ace
   where ope.cdcooper = pr_cdcooper
     and ope.cdoperad = pr_cdoperad
     and ope.cdsitope = 1  --Ativo
     and ace.cdcooper = ope.cdcooper
     and ace.cdoperad = ope.cdoperad
     and ace.nmdatela = 'PESSOA'
     and ace.cddopcao = 'A';
  rw_cdoperad cr_cdoperad%rowtype;

  -- Busca contas do cooperado para gravar log
  cursor cr_busca_cooperado (pr_cdcooper in crapass.cdcooper%type
                            ,pr_nrcpfcgc in crapass.nrcpfcgc%type) is
  select ass.cdcooper
       , ass.nrdconta
    from crapass ass
   where ass.cdcooper = pr_cdcooper
     and ass.nrcpfcgc = pr_nrcpfcgc
     and ass.dtdemiss is null;
  
  -- Variaveis padrao
  vr_cdcooper integer;                               
  vr_nmdatela varchar2(100);                                  
  vr_nmeacao  varchar2(100);                                  
  vr_cdagenci varchar2(100);                                  
  vr_nrdcaixa varchar2(100);                                  
  vr_idorigem varchar2(100);                                  
  vr_cdoperad varchar2(100);                    
  vr_cdcritic number;
  vr_dscritic varchar2(10000);                                
  vr_contador number  := 0;   
  vr_qtregist integer := 0; 
  vr_nrregist integer;
  vr_exc_erro exception;
  vr_nrdrowid rowid;
  vr_tpsituacao number := 0;

  procedure pc_buscar_cooperado (pr_nrdconta          in crapass.nrdconta%type
                                ,pr_nrregist          in integer                              
                                ,pr_nriniseq          in integer    
                                ,pr_xmllog            in varchar2
                                ,pr_cdcritic         out pls_integer
                                ,pr_dscritic         out varchar2
                                ,pr_retxml in out nocopy XMLType
                                ,pr_nmdcampo         out varchar2    
                                ,pr_des_erro         out varchar2) is

  ---------------------------------------------------------------------------
  --
  --  Programa : pc_buscar_cooperado
  --  Sistema  : Ayllos Web
  --  Autor    : Gabriel Marcos
  --  Data     : Agosto/2018                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Rotina para buscar informacoes para tela pessoa web.
  --
  -- Alteracoes:
  --
  --------------------------------------------------------------------------  

    -- Busca dados do cooperado.
    cursor cr_crapass (pr_cdcooper in crapass.cdcooper%type
                      ,pr_nrdconta in crapass.nrdconta%type) is
    select ass.nrcpfcgc
         , ass.nrdconta
         , ass.nmprimtl
         , ass.nrdctitg
         , ass.flgctitg
         , ass.inpessoa
         , ass.tpvincul
         , ass.cdsitdct
      from crapass ass
     where ass.cdcooper = pr_cdcooper
       and ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%rowtype;
      
    -- Busca segundo titular da conta
    cursor cr_crapttl (pr_cdcooper in crapass.cdcooper%type
                      ,pr_nrdconta in crapass.nrdconta%type) is
    select ttl.nmextttl
      from crapttl ttl
     where ttl.cdcooper = pr_cdcooper
       and ttl.nrdconta = pr_nrdconta
       and ttl.idseqttl = 2;

    -- Busca cargos do cooperado
    cursor cr_busca_cargos (pr_cdcooper in crapass.cdcooper%type
                           ,pr_nrcpfcgc in crapass.nrcpfcgc%type) is
    select vig.nrcpfcgc
         , fun.dsfuncao
         , fun.cdfuncao
         , vig.dtinicio_vigencia
         , vig.dtfim_vigencia
         , fun.flgvigencia
         , vig.rowid
         , count(*) over (partition by vig.cdcooper) qtdregis
      from tbcadast_vig_funcao_pessoa vig
         , tbcadast_funcao_pessoa     fun
     where vig.cdcooper = pr_cdcooper
       and vig.nrcpfcgc = pr_nrcpfcgc
       and vig.cdfuncao = fun.cdfuncao
     order
        by vig.dtfim_vigencia desc; -- Cargos em aberto primeiro.
    
    -- Buscar cnpj da cooperativa
    cursor cr_crapcop (pr_cdcooper crapcop.cdcooper%type) is
    select cop.nrdocnpj
      from crapcop cop
     where cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%rowtype;
      
    -- Verifica se cooperado possui cargo (tratamento para atribuicoes antigas)
    cursor cr_dsfuncao (pr_cdfuncao in tbcadast_funcao_pessoa.cdfuncao%type) is
    select fun.dsfuncao 
      from tbcadast_funcao_pessoa fun
     where fun.cdfuncao = decode(length(trim(pr_cdfuncao)),2,pr_cdfuncao,' ');

    -- Variaveis padrao
    vr_inpessoa varchar2(100);
    vr_nrdctitg varchar2(100);   
    vr_nmextttl varchar2(60);
    vr_dsfuncao varchar2(60);    
    vr_flpessoa varchar2(1) := 0;

  begin
      
    --Inicializar Variaveis
    vr_nrregist := pr_nrregist;
      
    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'PESSOA'
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
      raise vr_exc_erro;
    end if;

    -- Verifica se foram passados parametros
    if nvl(pr_nrdconta,0) = 0 then
      vr_dscritic := 'Informe a Conta/DV do cooperado.';
      pr_nmdcampo := 'nrdconta';
      raise vr_exc_erro;
    end if;

    -- Buscar cooperado
    open cr_crapass (vr_cdcooper
                    ,pr_nrdconta);
    fetch cr_crapass into rw_crapass;
      
    -- Se nao encontrou retorna critica
    if cr_crapass%notfound then
      close cr_crapass;
      vr_cdcritic := 9;
      raise vr_exc_erro;
    end if;

    close cr_crapass;

    -- Verifica se existe segundo titular
    if rw_crapass.inpessoa = 1 then

      open cr_crapttl (vr_cdcooper
                      ,rw_crapass.nrdconta);
      fetch cr_crapttl into vr_nmextttl;
      close cr_crapttl;
        
      if vr_nmextttl is null then
        vr_nmextttl := ' ';
      end if;

    end if;

    -- Concatena informacoes do tipo da pessoa
    if  rw_crapass.inpessoa = 1 then
      vr_inpessoa := rw_crapass.inpessoa || ' - Pessoa Fisica';
    elsif rw_crapass.inpessoa = 2 THEN
      vr_inpessoa := rw_crapass.inpessoa || ' - Pessoa Juridica';
    elsif rw_crapass.inpessoa = 3 THEN
      vr_inpessoa := rw_crapass.inpessoa || ' - Cheque Administrativo';
    end if;

    -- Concatena informacoes da conta integracao
    if  rw_crapass.flgctitg = 2 then
      vr_nrdctitg := gene0002.fn_mask_conta(nvl(trim(replace(rw_crapass.nrdctitg,'X',0)),0)) || ' - Ativa';
    elsif rw_crapass.flgctitg = 3 then
      vr_nrdctitg := gene0002.fn_mask_conta(nvl(trim(replace(rw_crapass.nrdctitg,'X',0)),0)) || ' - Inativa';
    elsif rw_crapass.nrdctitg is not null then
      vr_nrdctitg := gene0002.fn_mask_conta(nvl(trim(replace(rw_crapass.nrdctitg,'X',0)),0)) || ' - Em Proc';
    end if;

    -- Busca cnpj da cooperativa
    open cr_crapcop (vr_cdcooper);
    fetch cr_crapcop into rw_crapcop;
    close cr_crapcop;

    -- Cnpj da conta for igual da coop permite alterar inpessoa
    if rw_crapass.nrcpfcgc = rw_crapcop.nrdocnpj then
      vr_flpessoa := 1;
    end if;
      
    -- Verifica se cooperado possui cargo (tratamento para atribuicoes antigas)
    open cr_dsfuncao (rw_crapass.tpvincul);
    fetch cr_dsfuncao into vr_dsfuncao;

    -- Tratamento em caso de erro
    if cr_dsfuncao%notfound then
      vr_dsfuncao :=  'Função Inválida';
    end if;
    
    close cr_dsfuncao;

    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      
    -- Popula XML com informacoes
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root',   pr_posicao => 0, pr_tag_nova => 'Dados',    pr_tag_cont => NULL,                pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados',  pr_posicao => 0, pr_tag_nova => 'associ',   pr_tag_cont => NULL,                pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'associ', pr_posicao => 0, pr_tag_nova => 'nrdconta', pr_tag_cont => rw_crapass.nrdconta, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'associ', pr_posicao => 0, pr_tag_nova => 'nmprimtl', pr_tag_cont => rw_crapass.nmprimtl, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'associ', pr_posicao => 0, pr_tag_nova => 'nmextttl', pr_tag_cont => vr_nmextttl,         pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'associ', pr_posicao => 0, pr_tag_nova => 'nrdctitg', pr_tag_cont => vr_nrdctitg,         pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'associ', pr_posicao => 0, pr_tag_nova => 'tpvincul', pr_tag_cont => vr_dsfuncao,         pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'associ', pr_posicao => 0, pr_tag_nova => 'inpessoa', pr_tag_cont => rw_crapass.inpessoa, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'associ', pr_posicao => 0, pr_tag_nova => 'dspessoa', pr_tag_cont => vr_inpessoa,         pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'associ', pr_posicao => 0, pr_tag_nova => 'flpessoa', pr_tag_cont => vr_flpessoa,         pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'associ', pr_posicao => 0, pr_tag_nova => 'nrcpfcgc', pr_tag_cont => rw_crapass.nrcpfcgc, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados',  pr_posicao => 0, pr_tag_nova => 'cargos',   pr_tag_cont => NULL,                pr_des_erro => vr_dscritic);
    
    -- Loop no historico de cargos do cooperado
    for rw_busca_cargos in cr_busca_cargos (vr_cdcooper
                                           ,rw_crapass.nrcpfcgc) loop

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
      
        -- Popula XML com informacoes
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'cargos', pr_posicao => 0, pr_tag_nova => 'cargo', pr_tag_cont => null, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'cargo', pr_posicao => vr_contador, pr_tag_nova => 'flgvigencia',       pr_tag_cont => rw_busca_cargos.flgvigencia,                                   pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'cargo', pr_posicao => vr_contador, pr_tag_nova => 'rowid',             pr_tag_cont => rw_busca_cargos.rowid,                                         pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'cargo', pr_posicao => vr_contador, pr_tag_nova => 'nrcpfcgc',          pr_tag_cont => gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_busca_cargos.nrcpfcgc,
                                                                                                                                                                                   pr_inpessoa => rw_crapass.inpessoa), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'cargo', pr_posicao => vr_contador, pr_tag_nova => 'dsfuncao',          pr_tag_cont => rw_busca_cargos.dsfuncao,                                      pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'cargo', pr_posicao => vr_contador, pr_tag_nova => 'cdfuncao',          pr_tag_cont => rw_busca_cargos.cdfuncao,                                      pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'cargo', pr_posicao => vr_contador, pr_tag_nova => 'dtinicio_vigencia', pr_tag_cont => to_char(rw_busca_cargos.dtinicio_vigencia,'DD/MM/RRRR'),       pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'cargo', pr_posicao => vr_contador, pr_tag_nova => 'dtfim_vigencia',    pr_tag_cont => to_char(rw_busca_cargos.dtfim_vigencia,'DD/MM/RRRR'),          pr_des_erro => vr_dscritic);
        
        vr_contador:= vr_contador + 1;
          
      end if;
      
      --Diminuir registros
      vr_nrregist:= nvl(vr_nrregist,0) - 1;
      
    end loop;

    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           
                             ,pr_tag   => 'cargos'            
                             ,pr_atrib => 'qtregist'          
                             ,pr_atval => vr_qtregist         
                             ,pr_numva => 0                   
                             ,pr_des_erro => vr_dscritic);    
                                 
    --Se ocorreu erro
    if trim(vr_dscritic) is not null then
      raise vr_exc_erro;
    end if;

    pr_des_erro := 'OK';
    
  exception
    
    when vr_exc_erro then

      if vr_cdcritic <> 0 then
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
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
      pr_dscritic := 'Erro geral na rotina da tela TELA_PESSOA.pc_buscar_cooperado: ' || sqlerrm;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      rollback;
      
      CECRED.pc_internal_exception(pr_cdcooper => vr_cdcooper);
      
  end pc_buscar_cooperado;
    
  procedure pc_mostra_cargos (pr_xmllog       in varchar2       
                             ,pr_cdcritic    out pls_integer    
                             ,pr_dscritic    out varchar2       
                             ,pr_retxml   in out nocopy xmltype 
                             ,pr_nmdcampo    out varchar2       
                             ,pr_des_erro    out varchar2) is   

  ---------------------------------------------------------------------------
  --
  --  Programa : pc_mostra_cargos
  --  Sistema  : Ayllos Web
  --  Autor    : Gabriel Marcos
  --  Data     : Agosto/2018                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Rotina para apresentar codigos e funcoes disponiveis 
  --             no menu da opcao alterar e habilitar campo inicio vigencia.
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------
  
    -- Busca cargos e funcoes
    cursor cr_mostra_cargos is
    select fun.cdfuncao
         , fun.dsfuncao
         , fun.flgvigencia
      from tbcadast_funcao_pessoa fun
     where fun.cdfuncao in ('DT','DS','CL','CS','CM') -- Nao apresenta cooperado e acumulo 
     order
        by fun.dsfuncao;

  begin
  
    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'TELA_PESSOA'
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
                            ,pr_dscritic => pr_dscritic);

    -- Se retornou alguma crítica
    if trim(pr_dscritic) is not null then
      raise vr_exc_erro;
    end if;       
    
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root', pr_posicao => 0, pr_tag_nova => 'Dados', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    -- Loop principal para popular XML
    for rw_mostra_cargos in cr_mostra_cargos loop

      -- Popula XML com informacoes
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados',  pr_posicao => 0,           pr_tag_nova => 'cargos',      pr_tag_cont => NULL,                         pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'cargos', pr_posicao => vr_contador, pr_tag_nova => 'cdfuncao',    pr_tag_cont => rw_mostra_cargos.cdfuncao,    pr_des_erro => vr_dscritic);                       
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'cargos', pr_posicao => vr_contador, pr_tag_nova => 'dsfuncao',    pr_tag_cont => rw_mostra_cargos.dsfuncao,    pr_des_erro => vr_dscritic);                       
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'cargos', pr_posicao => vr_contador, pr_tag_nova => 'flgvigencia', pr_tag_cont => rw_mostra_cargos.flgvigencia, pr_des_erro => vr_dscritic);  
      
      vr_contador := vr_contador + 1;
          
    end loop;

    pr_des_erro := 'OK';
      
  exception
    
    when vr_exc_erro then
          
      pr_des_erro := 'NOK';

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
                                       
    when others then
      
      pr_cdcritic := 0;
      pr_des_erro := 'NOK';
      pr_dscritic := 'Erro geral em TELA_PESSOA.pc_mostra_cargos: ' || sqlerrm;
          
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper);
      
  end pc_mostra_cargos;
  
  procedure pc_inserir_cargos_web (pr_nrcpfcgc          in crapass.nrcpfcgc%type
                                  ,pr_cdfuncao          in crapass.tpvincul%type
                                  ,pr_dtinicio_vigencia in varchar2
                                  ,pr_xmllog            in varchar2
                                  ,pr_cdcritic         out pls_integer
                                  ,pr_dscritic         out varchar2
                                  ,pr_retxml        in out nocopy XMLType
                                  ,pr_nmdcampo         out varchar2    
                                  ,pr_des_erro         out varchar2) is
                              
  ---------------------------------------------------------------------------
  --
  --  Programa : pc_inserir_cargos_web
  --  Sistema  : Ayllos Web
  --  Autor    : Gabriel Marcos
  --  Data     : Agosto/2018                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Chamada web da rotina de insert
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------
      
  begin

    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'TELA_PESSOA'
                              ,pr_action => null);
           
    -- Busca codigo da cooperativa
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    if trim(vr_dscritic) is not null then
      raise vr_exc_erro;
    end if;
    
    -- Chamar rotina de insercao
    pc_inserir_cargos (pr_cdcooper          => vr_cdcooper
                      ,pr_nrcpfcgc          => pr_nrcpfcgc
                      ,pr_cdfuncao          => pr_cdfuncao
                      ,pr_dtinicio_vigencia => pr_dtinicio_vigencia
                      ,pr_cdoperad          => vr_cdoperad
                      ,pr_cdcritic          => vr_cdcritic
                      ,pr_dscritic          => vr_dscritic);
                      
    -- Se retornou alguma crítica
    if nvl(vr_cdcritic,0) > 0 or trim(vr_dscritic) is not null then
      raise vr_exc_erro;
    end if;
    
    commit;
    
    pr_des_erro := 'OK';
                                            
  exception
    
    when vr_exc_erro then

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
      pr_dscritic := 'Erro geral na rotina da tela TELA_PESSOA.pc_inserir_cargos_web: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      rollback;
      
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper);

  end pc_inserir_cargos_web;

  procedure pc_inserir_cargos (pr_cdcooper          in crapass.cdcooper%type
                              ,pr_nrcpfcgc          in crapass.nrcpfcgc%type
                              ,pr_cdfuncao          in crapass.tpvincul%type
                              ,pr_dtinicio_vigencia in varchar2
                              ,pr_cdoperad          in crapope.cdoperad%type
                              ,pr_cdcritic         out pls_integer
                              ,pr_dscritic         out varchar2) is
                              
  ---------------------------------------------------------------------------
  --
  --  Programa : pc_inserir_cargos
  --  Sistema  : Ayllos Web
  --  Autor    : Gabriel Marcos
  --  Data     : Agosto/2018                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Rotina para inserir cargo para o cooperado.
  --
  -- Alteracoes: 13/08/2019 - Nova forma de buscar cargos. Tratamento super-usuario.
  --                          Projeto 484.2 - Gabriel Marcos (Mouts).   
  --
  ---------------------------------------------------------------------------
    
    -- Verifica funcoes que se acumulam
    cursor cr_acumula_cargos (pr_cdcooper in crapass.cdcooper%type
                             ,pr_nrcpfcgc in crapass.nrcpfcgc%type) is
    select (select vig.cdfuncao
              from tbcadast_vig_funcao_pessoa vig
             where vig.cdcooper = pr_cdcooper
               and vig.nrcpfcgc = pr_nrcpfcgc
               and vig.cdfuncao in ('DT','DS')
               and vig.dtfim_vigencia is null) delegado
         , (select vig.cdfuncao
              from tbcadast_vig_funcao_pessoa vig
             where vig.cdcooper = pr_cdcooper
               and vig.nrcpfcgc = pr_nrcpfcgc
               and vig.cdfuncao in ('CL','CS','CM')
               and vig.dtfim_vigencia is null) comitedu
         , (select vig.cdfuncao
              from tbcadast_vig_funcao_pessoa vig
             where vig.cdcooper = pr_cdcooper
               and vig.nrcpfcgc = pr_nrcpfcgc
               and vig.cdfuncao not in ('DT','DS','CL','CS','CM')
               and vig.dtfim_vigencia is null) outrafun
      from dual;
    rw_acumula_cargos cr_acumula_cargos%rowtype;
    
    -- Valida funcao recebida por parametro  
    cursor cr_funcao (pr_cdfuncao in tbcadast_funcao_pessoa.cdfuncao%type) is
    select fun.cdfuncao
         , fun.dsfuncao
         , fun.flgvigencia
         , nvl(fun.flgvinculo,0) flgvinculo
      from tbcadast_funcao_pessoa fun
     where fun.cdfuncao = pr_cdfuncao;
    rw_funcao cr_funcao%rowtype;
      
    -- Valida cpf / cnpj recebido por parametro
    cursor cr_crapass (pr_cdcooper in crapass.cdcooper%type
                      ,pr_nrcpfcgc in crapass.nrcpfcgc%type) is
    select ass.inpessoa
          ,ass.nrcpfcgc
      from crapass ass
     where ass.cdcooper = pr_cdcooper
       and ass.nrcpfcgc = pr_nrcpfcgc;
    rw_crapass cr_crapass%rowtype;
    
    -- Cooperado deve ter grupo para receber funcao
    cursor cr_grupo_assembleia (pr_cdcooper in crapass.cdcooper%type
                               ,pr_nrcpfcgc in crapass.nrcpfcgc%type) is
    select grp.cdcooper 
         , grp.nrcpfcgc
      from tbevento_pessoa_grupos grp
         , crapcop                cop
     where grp.cdcooper  = pr_cdcooper
       and grp.nrcpfcgc  = pr_nrcpfcgc
       and cop.cdcooper  = grp.cdcooper
       and cop.nrdocnpj <> grp.nrcpfcgc;
    rw_grupo_assembleia cr_grupo_assembleia%rowtype;
    
    -- Busca delegado no grupo do cooperado
    cursor cr_busca_del_grupo (pr_cdcooper in crapass.cdcooper%type
                              ,pr_nrcpfcgc in crapass.nrcpfcgc%type
                              ,pr_cdfuncao in crapass.tpvincul%type) is
    select pes.dsfuncao
      from tbevento_pessoa_grupos     grp
         , tbevento_pessoa_grupos     xxx
         , tbcadast_vig_funcao_pessoa vig
         , tbcadast_funcao_pessoa     pes
     where grp.cdcooper = pr_cdcooper
       and grp.nrcpfcgc = pr_nrcpfcgc
       and xxx.cdcooper = grp.cdcooper
       and xxx.cdagenci = grp.cdagenci
       and xxx.nrdgrupo = grp.nrdgrupo
       and vig.cdcooper = xxx.cdcooper
       and vig.nrcpfcgc = xxx.nrcpfcgc
       and vig.cdfuncao = pr_cdfuncao
       and vig.cdfuncao in ('DT','DS')
       and vig.dtfim_vigencia is null
       and pes.cdfuncao = vig.cdfuncao;
    rw_busca_del_grupo cr_busca_del_grupo%rowtype;
      
    -- Buscar dado para data de fim de vigencia
    cursor cr_crapdat (pr_cdcooper crapdat.cdcooper%type) is
    select dat.dtmvtolt
      from crapdat dat
     where dat.cdcooper = pr_cdcooper;
    rw_crapdat cr_crapdat%rowtype;

    vr_dtinicio_vigencia date;
    vr_cdfuncao varchar2(2) := ' ';
    
  begin

    begin
      --Pega a data do registro
      vr_dtinicio_vigencia := to_date(pr_dtinicio_vigencia,'DD/MM/RRRR');
    exception
      when others then
        --Monta mensagem de critica
        vr_dscritic := 'Data de vigência inválida.';
        raise vr_exc_erro;
    end;
    
    -- Valida cpf / cnpj do cooperado
    if nvl(pr_nrcpfcgc,0) = 0 then
      --Monta mensagem de critica
      vr_dscritic := 'CPF/CNPJ inválido.';
      raise vr_exc_erro; 
    end if;
    
    -- Valida cdfuncao do parametro
    if trim(pr_cdfuncao) is null then
      --Monta mensagem de critica
      vr_dscritic := 'Cargo/Função inválida.';
      raise vr_exc_erro; 
    end if;       
      
    -- Busca cooperado na base
    open cr_crapass (pr_cdcooper => pr_cdcooper
                    ,pr_nrcpfcgc => pr_nrcpfcgc);        
    fetch cr_crapass into rw_crapass;
      
    -- Se nao encontrou retorna crítica
    if cr_crapass%notfound then
      close cr_crapass;
      vr_cdcritic := 9;
      raise vr_exc_erro;
    end if;
      
    close cr_crapass;
      
    -- Busca funcao na base
    open cr_funcao(pr_cdfuncao => pr_cdfuncao);
    fetch cr_funcao into rw_funcao;
      
    -- Se nao encontrou retorna crítica
    if cr_funcao%notfound then
      close cr_funcao;
      vr_dscritic := 'Função não encontrada.';
      raise vr_exc_erro; 
    end if;
      
    close cr_funcao;

    -- Busca data de movimentacao
    -- para fazer validacao do fim de vigencia
    open cr_crapdat (pr_cdcooper);
    fetch cr_crapdat into rw_crapdat;
    
    -- Aborta se nao encontrar
    if cr_crapdat%notfound then
      
      close cr_crapdat;
      vr_dscritic := 'Data da cooperativa não cadastrada.';
      raise vr_exc_erro;

    end if;

    close cr_crapdat;
      
    -- Cargos que exigem data de inicio de vigencia
    if rw_funcao.flgvigencia = 1 and vr_dtinicio_vigencia is null then
      vr_dscritic := 'Data de inicio de vigência não preenchida.';
      raise vr_exc_erro;
    elsif rw_funcao.flgvigencia = 0 then
      vr_dtinicio_vigencia := null;
    elsif vr_dtinicio_vigencia > rw_crapdat.dtmvtolt then
      vr_dscritic := 'Data de inicio de vigência não pode ser maior que a data de referência.';
      raise vr_exc_erro;
    end if;
    
    -- Verifica se operador foi informado
    if trim(pr_cdoperad) is null then
      vr_dscritic := 'Operador deve ser informado.';
      raise vr_exc_erro;
    end if;

    -- Analisa permissoes do operador
    open cr_cdoperad (pr_cdcooper
                     ,pr_cdoperad);
    fetch cr_cdoperad into rw_cdoperad;

    -- Caso nao tenha permissao retorna critica
    if cr_cdoperad%notfound and pr_cdoperad <> '1' then
      close cr_cdoperad;
      vr_dscritic := 'Operador sem permissão para inserir cargos.';
      raise vr_exc_erro;
    end if;
      
    close cr_cdoperad;  

    /*-- Apenas contabilidade usam cargos antigos
    if pr_cdfuncao not in ('DT','DS','CL','CS','CM') and
       rw_cdoperad.cddepart <> 6 then
      vr_dscritic := 'Cargo de uso restrito da contabilidade.';
      raise vr_exc_erro;
    end if;*/

    -- Analisa acumulo de cargos do cpf / cnpj
    open cr_acumula_cargos (pr_cdcooper
                           ,pr_nrcpfcgc);                     
    fetch cr_acumula_cargos into rw_acumula_cargos;
    close cr_acumula_cargos;
      
    -- Evita de inserir delegado se ja e delegado
    if pr_cdfuncao in ('DT','DS') and rw_acumula_cargos.delegado is not null then
      vr_dscritic := 'Cooperado já possui cargo de Delegado ativo.';
      raise vr_exc_erro;
    -- Evita de inserir comite se ja e comite
    elsif pr_cdfuncao in ('CL','CS','CM') and rw_acumula_cargos.comitedu is not null then
      vr_dscritic := 'Cooperado já possui cargo de Comite Educativo ativo.';
      raise vr_exc_erro;
    -- Tratamento para acumulo entre delegado e comite
    elsif pr_cdfuncao in ('DT','DS') and rw_acumula_cargos.comitedu is not null or
          pr_cdfuncao in ('CL','CS','CM') and rw_acumula_cargos.delegado is not null then
      --vr_cdfuncao := 'CD'; -- Para atualizar crapass
      null;
    -- Tratamento para evitar acumulo entre quaisquer outras funcoes
    elsif rw_acumula_cargos.outrafun is not null and 
          pr_cdfuncao not in ('DT','DS','CL','CS','CM') then
      vr_dscritic := 'Cooperado já possui cargo ativo.';
      raise vr_exc_erro;
    end if;
    
    if rw_acumula_cargos.outrafun is not null then
      vr_cdfuncao := rw_acumula_cargos.outrafun;
    elsif pr_cdfuncao not in ('DT','DS','CL','CS','CM') then
      vr_cdfuncao := pr_cdfuncao;
    end if;

    -- Funcoes de grupo exigem que cooperado
    -- esteja locado em um grupo
    if pr_cdfuncao in ('DT','DS') then
    
      -- Busca grupo do cooperado
      open cr_grupo_assembleia (pr_cdcooper
                               ,pr_nrcpfcgc);
      fetch cr_grupo_assembleia into rw_grupo_assembleia;
      
      -- Se nao encontrou aborta
      if cr_grupo_assembleia%notfound then
        vr_dscritic := 'Cooperado precisa estar em um grupo.';
        raise vr_exc_erro;
        close cr_grupo_assembleia;
      end if;
      
      close cr_grupo_assembleia;
    
    end if;
    
    -- Analise de acumulo dentro do grupo
    open cr_busca_del_grupo (pr_cdcooper
                            ,pr_nrcpfcgc
                            ,pr_cdfuncao);
    fetch cr_busca_del_grupo into rw_busca_del_grupo;
    
    -- Se ja existe delegado no grupo aborta
    if cr_busca_del_grupo%found then
      close cr_busca_del_grupo;
      vr_dscritic := 'O grupo já possui um '||rw_busca_del_grupo.dsfuncao||' ativo.';
      raise vr_exc_erro;
    end if;
    
    close cr_busca_del_grupo;

    begin
        
      -- Insere funcao ao cooperado
      insert into tbcadast_vig_funcao_pessoa (cdcooper
                                             ,nrcpfcgc
                                             ,cdfuncao
                                             ,dtinicio_vigencia
                                             ,dtfim_vigencia
                                             ,cdoperad_altera
                                             ,dhalteracao)
                                      values (pr_cdcooper
                                             ,pr_nrcpfcgc
                                             ,pr_cdfuncao
                                             ,vr_dtinicio_vigencia
                                             ,null
                                             ,pr_cdoperad
                                             ,sysdate);

    exception
      when dup_val_on_index then
        vr_dscritic := 'Não é permitido que o mesmo cargo '    ||
                       'possua dois registros com mesma data ' ||
                       'de inicio de vigência.';
        raise vr_exc_erro;
      when others then
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao inserir cargo/função: ' || sqlerrm;
        raise vr_exc_erro;
    end;
    -- P484.2 - atualizar a necessidade ou nao do vinculo de grupo da pessoa,
    -- atualizar a tabela que vincula pessoa a um grupo
    BEGIN
      UPDATE tbevento_pessoa_grupos tbe
         SET tbe.flgvinculo = rw_funcao.flgvinculo
       WHERE tbe.cdcooper = pr_cdcooper
         AND tbe.nrcpfcgc = pr_nrcpfcgc;
    EXCEPTION 
      WHEN OTHERS THEN
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Falha ao atualizar vinculo de pessoa / grupo: ' || sqlerrm;
      raise vr_exc_erro;          
    END;
    
    -- Controle de historico de vinculos
    pc_historico_tpvinculo (pr_cdcooper => pr_cdcooper
                           ,pr_nrcpfcgc => pr_nrcpfcgc
                           ,pr_tpvincul => vr_cdfuncao
                           ,pr_dscritic => vr_dscritic);
                     
    -- Aborta em caso de erro
    if trim(vr_dscritic) is not null then
      raise vr_exc_erro;
    end if;
    
    -- Busca contas do cooperado para gerar log
    for rw_busca_cooperado in cr_busca_cooperado (pr_cdcooper
                                                 ,pr_nrcpfcgc) loop
      
      -- Gravar log de insercao de funcao
      gene0001.pc_gera_log(pr_cdcooper => rw_busca_cooperado.cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => null
                          ,pr_dsorigem => gene0001.vr_vet_des_origens(5)
                          ,pr_dstransa => 'Inserido funcao: '||rw_funcao.dsfuncao
                          ,pr_dttransa => trunc(sysdate)
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => gene0002.fn_busca_time
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'PESSOA'
                          ,pr_nrdconta => rw_busca_cooperado.nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
    
    end loop;

    -- Gera log
    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_nmarqlog     => 'pessoa.log'
                              ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                  ' --> Operador '|| pr_cdoperad || ' - ' ||
                                                  'Inseriu o cargo/funcao ' || rw_funcao.cdfuncao || ' - ' || rw_funcao.dsfuncao ||
                                                  ' para o cooperado CPF/CNPJ ' || gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapass.nrcpfcgc,
                                                                                                             pr_inpessoa => rw_crapass.inpessoa) ||
                                                  ' com data de vigencia para ' || to_char(vr_dtinicio_vigencia,'DD/MM/RRRR') ||
                                                  '.');
        
    commit;

  exception
    
    when vr_exc_erro then

      if vr_cdcritic <> 0 then
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      else
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      end if;

    when others then

      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := 'Erro geral na rotina da tela TELA_PESSOA.pc_inserir_cargos: ' || SQLERRM;

  end pc_inserir_cargos;

  procedure pc_excluir_cargos_web (pr_nrcpfcgc   in crapass.nrcpfcgc%type
                                  ,pr_cdfuncao   in crapass.tpvincul%type
                                  ,pr_nrdrowid   in rowid
                                  ,pr_xmllog     in varchar2
                                  ,pr_cdcritic  out pls_integer
                                  ,pr_dscritic  out varchar2
                                  ,pr_retxml in out nocopy XMLType
                                  ,pr_nmdcampo  out varchar2    
                                  ,pr_des_erro  out varchar2) is

  begin
          
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
    
    -- Aborta em caso de critica
    if trim(vr_dscritic) is not null then
      raise vr_exc_erro;
    end if;
    
    pc_excluir_cargos (pr_cdcooper => vr_cdcooper
                      ,pr_nrcpfcgc => pr_nrcpfcgc
                      ,pr_cdfuncao => pr_cdfuncao
                      ,pr_nrdrowid => pr_nrdrowid
                      ,pr_cdoperad => vr_cdoperad
                      ,pr_cdcritic => vr_cdcritic
                      ,pr_dscritic => vr_dscritic);
                      
    -- Aborta em caso de critica
    if trim(vr_dscritic) is not null or nvl(vr_cdcritic,0) > 0 then
      raise vr_exc_erro;
    end if;
    
    commit;

    pr_des_erro := 'OK';

  exception
    
    when vr_exc_erro then

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
      pr_dscritic := 'Erro geral na rotina da tela TELA_PESSOA.pc_excluir_cargos_web: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      rollback;
      
      cecred.pc_internal_exception (pr_cdcooper => vr_cdcooper);

  end;
    
  procedure pc_excluir_cargos (pr_cdcooper   in crapass.cdcooper%type
                              ,pr_nrcpfcgc   in crapass.nrcpfcgc%type
                              ,pr_cdfuncao   in crapass.tpvincul%type
                              ,pr_nrdrowid   in rowid
                              ,pr_cdoperad   in crapope.cdoperad%type
                              ,pr_cdcritic  out pls_integer
                              ,pr_dscritic  out varchar2) is
                              
  ---------------------------------------------------------------------------
  --
  --  Programa : pc_excluir_cargos
  --  Sistema  : Ayllos Web
  --  Autor    : Gabriel Marcos
  --  Data     : Agosto/2018                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Rotina para excluir cargos do cooperado.
  --
  -- Alteracoes: 13/08/2019 - Nova forma de buscar cargos. Tratamento super-usuario.
  --                          Projeto 484.2 - Gabriel Marcos (Mouts).   
  --
  ---------------------------------------------------------------------------
 
    -- Verifica funcoes que se acumulam
    cursor cr_tratamento_ass (pr_cdcooper in tbcadast_vig_funcao_pessoa.cdcooper%type
                             ,pr_nrcpfcgc in tbcadast_vig_funcao_pessoa.nrcpfcgc%type
                             ,pr_cdfuncao in tbcadast_vig_funcao_pessoa.cdfuncao%type) is
    select vig.cdfuncao
      from tbcadast_vig_funcao_pessoa vig
     where vig.cdcooper  = pr_cdcooper
       and vig.nrcpfcgc  = pr_nrcpfcgc
       and vig.cdfuncao <> pr_cdfuncao
       and vig.cdfuncao in ('DT','DS','CL','CS','CM')
       and vig.dtfim_vigencia is null;
    rw_tratamento_ass cr_tratamento_ass%rowtype;
    
    -- Verifica funcoes que se acumulam
    cursor cr_acumula_cargos (pr_cdcooper in crapass.cdcooper%type
                             ,pr_nrcpfcgc in crapass.nrcpfcgc%type
                             ,pr_cdfuncao in tbcadast_vig_funcao_pessoa.cdfuncao%type) is
    select (select vig.cdfuncao
              from tbcadast_vig_funcao_pessoa vig
             where vig.cdcooper = pr_cdcooper
               and vig.nrcpfcgc = pr_nrcpfcgc
               and vig.cdfuncao in ('DT','DS')
               and vig.dtfim_vigencia is null) delegado
         , (select vig.cdfuncao
              from tbcadast_vig_funcao_pessoa vig
             where vig.cdcooper = pr_cdcooper
               and vig.nrcpfcgc = pr_nrcpfcgc
               and vig.cdfuncao in ('CL','CS','CM')
               and vig.dtfim_vigencia is null) comitedu
         , (select vig.cdfuncao
              from tbcadast_vig_funcao_pessoa vig
             where vig.cdcooper = pr_cdcooper
               and vig.nrcpfcgc = pr_nrcpfcgc
               and vig.cdfuncao not in ('DT','DS','CL','CS','CM',pr_cdfuncao)
               and vig.dtfim_vigencia is null) outrafun
      from dual;
    rw_acumula_cargos cr_acumula_cargos%rowtype;
    
    -- Validar funcao passado por rowid
    cursor cr_busca_cargos (pr_nrdrowid in rowid) is
    select fun.dsfuncao
         , fun.cdfuncao
         , vig.dtfim_vigencia
      from tbcadast_vig_funcao_pessoa vig
         , tbcadast_funcao_pessoa     fun
     where vig.rowid    = pr_nrdrowid
       and fun.cdfuncao = vig.cdfuncao;
    rw_busca_cargos cr_busca_cargos%rowtype;
    
    -- Validar cpf / cnpj passado por parametro
    cursor cr_crapass (pr_cdcooper in crapass.cdcooper%type
                      ,pr_nrcpfcgc in crapass.nrcpfcgc%type) is
    select ass.inpessoa
          ,ass.nrcpfcgc
      from crapass ass
     where ass.cdcooper = pr_cdcooper
       and ass.nrcpfcgc = pr_nrcpfcgc;
    rw_crapass cr_crapass%rowtype;
    
    -- Valida funcao recebida por parametro  
    cursor cr_funcao (pr_cdfuncao in tbcadast_funcao_pessoa.cdfuncao%type) is
    select fun.cdfuncao
         , fun.dsfuncao
         , fun.flgvigencia
      from tbcadast_funcao_pessoa fun
     where fun.cdfuncao = pr_cdfuncao;
    rw_funcao cr_funcao%rowtype;

    vr_cdfuncao varchar2(2) := ' ';
      
  begin

    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'PESSOA'
                              ,pr_action => null); 

    -- Analisa permissoes do operador
    open cr_cdoperad (pr_cdcooper
                     ,pr_cdoperad);
    fetch cr_cdoperad into rw_cdoperad;

    -- Caso nao tenha permissao retorna critica
    if cr_cdoperad%notfound and pr_cdoperad <> '1' then
      close cr_cdoperad;
      vr_dscritic := 'Operador sem permissão para excluir cargos.';
      raise vr_exc_erro;
    end if;

    close cr_cdoperad;  

    /*-- Apenas contabilidade usam cargos antigos
    if pr_cdfuncao not in ('DT','DS','CL','CS','CM') and
       rw_cdoperad.cddepart <> 6 then
      vr_dscritic := 'Cargo de uso restrito da contabilidade.';
      raise vr_exc_erro;
    end if;*/

    -- Busca funcao na base
    open cr_funcao (pr_cdfuncao => pr_cdfuncao);
    fetch cr_funcao into rw_funcao;
      
    -- Se nao encontrou retorna crítica
    if cr_funcao%notfound then
      
      close cr_funcao;
      vr_dscritic := 'Função não encontrada.';
      raise vr_exc_erro; 
      
    end if;
    
    close cr_funcao;

    -- Busca cooperado na base
    open cr_crapass (pr_cdcooper => pr_cdcooper
                    ,pr_nrcpfcgc => pr_nrcpfcgc);        
    fetch cr_crapass into rw_crapass;
    
    -- Se nao encontrou retorna crítica
    if cr_crapass%notfound then

      close cr_crapass;
      vr_cdcritic := 9;
      raise vr_exc_erro;
        
    end if;
    
    close cr_crapass;
    
    -- Analisa acumulo de cargos do cpf / cnpj
    open cr_acumula_cargos (pr_cdcooper
                           ,pr_nrcpfcgc
                           ,pr_cdfuncao);                     
    fetch cr_acumula_cargos into rw_acumula_cargos;
    close cr_acumula_cargos;

    if rw_acumula_cargos.outrafun is not null then
      vr_cdfuncao := rw_acumula_cargos.outrafun;
    end if;
    
    -- Busca registro que sera inativado
    open cr_busca_cargos(pr_nrdrowid => pr_nrdrowid);
    fetch cr_busca_cargos into rw_busca_cargos;
    
    -- Se nao encontrou aborta
    if cr_busca_cargos%notfound then
      
      close cr_busca_cargos;
      vr_dscritic := 'Cargo/Função não encontrado.';
      raise vr_exc_erro; 
    
    else
      
      close cr_busca_cargos;

      begin

        delete
          from tbcadast_vig_funcao_pessoa vig
         where vig.cdcooper = pr_cdcooper
           and vig.rowid    = pr_nrdrowid;
             
      exception
        
        when others then
          
          -- Montar mensagem de critica
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao excluir cargo/função: ' || sqlerrm;
          raise vr_exc_erro;

      end;
      
    if rw_busca_cargos.dtfim_vigencia is null then
        
        -- Controle de historico de vinculos
        pc_historico_tpvinculo (pr_cdcooper => pr_cdcooper
                               ,pr_nrcpfcgc => pr_nrcpfcgc
                               ,pr_tpvincul => vr_cdfuncao
                               ,pr_dscritic => vr_dscritic);
                     
        -- Aborta em caso de erro
        if trim(vr_dscritic) is not null then
          raise vr_exc_erro;
        end if;

      end if;
        
    end if;  

    -- Busca contas do cooperado para gerar log
    for rw_busca_cooperado in cr_busca_cooperado (pr_cdcooper
                                                 ,pr_nrcpfcgc) loop
      
      -- Gravar log de insercao de funcao
      gene0001.pc_gera_log(pr_cdcooper => rw_busca_cooperado.cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => null
                          ,pr_dsorigem => gene0001.vr_vet_des_origens(5)
                          ,pr_dstransa => 'Excluido funcao: '||rw_funcao.dsfuncao
                          ,pr_dttransa => trunc(sysdate)
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => gene0002.fn_busca_time
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'PESSOA'
                          ,pr_nrdconta => rw_busca_cooperado.nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
    
    end loop;

    -- Gera log
    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_nmarqlog     => 'pessoa.log'
                              ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                  ' --> Operador '|| pr_cdoperad || ' - ' ||
                                                  'Excluiu do CNPJ ' || gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapass.nrcpfcgc,
                                                                                                  pr_inpessoa => rw_crapass.inpessoa) ||
                                                  ' o cargo/funcao ' || rw_busca_cargos.dsfuncao ||                                                 
                                                  '.');

    commit;

  exception
    
    when vr_exc_erro then

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
    when others then

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela TELA_PESSOA.pc_excluir_cargos: ' || SQLERRM;
      
  end pc_excluir_cargos;
  
  procedure pc_inativa_cargos_web (pr_nrcpfcgc          in crapass.nrcpfcgc%type
                                  ,pr_dtinicio_vigencia in varchar2
                                  ,pr_dtfim_vigencia    in varchar2
                                  ,pr_cdfuncao          in crapass.tpvincul%type
                                  ,pr_nrdrowid          in rowid
                                  ,pr_xmllog            in varchar2
                                  ,pr_cdcritic         out pls_integer
                                  ,pr_dscritic         out varchar2
                                  ,pr_retxml        in out nocopy XMLType
                                  ,pr_nmdcampo         out varchar2    
                                  ,pr_des_erro         out varchar2) is

  ---------------------------------------------------------------------------
  --             
  --  Programa : pc_inativa_cargos_web
  --  Sistema  : Ayllos Web
  --  Autor    : Gabriel Marcos
  --  Data     : Agosto/2018                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Rotina para receber chamada web para inativar cargos.
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

    vr_dtinicio_vigencia date;
    vr_dtfim_vigencia    date;

  begin
  
    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'PESSOA'
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
    
    -- Aborta em caso de critica 
    if trim(vr_dscritic) is not null then
      raise vr_exc_erro;
    end if;

    begin
      
      --Pega a data do registro
      vr_dtinicio_vigencia := to_date(pr_dtinicio_vigencia,'DD/MM/RRRR');

    exception
      
      when others then

        --Monta mensagem de critica
        vr_dscritic := 'Data de inicio de vigência inválida ou não preenchida.';
        pr_nmdcampo := 'dtinicio_vigencia';
        raise vr_exc_erro;
      
    end;
    
    begin
        
      --Pega a data do registro
      vr_dtfim_vigencia := to_date(pr_dtfim_vigencia,'DD/MM/RRRR');

    exception
        
      when others then

        --Monta mensagem de critica
        vr_dscritic := 'Data de fim de vigência inválida ou não preenchida.';
        pr_nmdcampo := 'dtfim_vigencia';
        raise vr_exc_erro;
        
    end;

    -- Chamar rotina que inativa cargos
    pc_inativa_cargos (pr_cdcooper          => vr_cdcooper
                      ,pr_nrcpfcgc          => pr_nrcpfcgc
                      ,pr_cdfuncao          => pr_cdfuncao
                      ,pr_dtinicio_vigencia => vr_dtinicio_vigencia
                      ,pr_dtfim_vigencia    => vr_dtfim_vigencia
                      ,pr_nrdrowid          => pr_nrdrowid
                      ,pr_cdoperad          => vr_cdoperad
                      ,pr_cdcritic          => vr_cdcritic
                      ,pr_dscritic          => vr_dscritic);

    -- Aborta em caso de critica
    if nvl(vr_cdcritic,0) > 0 or trim(vr_dscritic) is not null then
      raise vr_exc_erro;
    end if;
    
    commit;

    pr_des_erro := 'OK'; 

  exception
    
    when vr_exc_erro then

      if vr_cdcritic <> 0 then
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
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
      pr_dscritic := 'Erro geral na rotina da tela TELA_PESSOA.pc_inativa_cargos_web: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      
      rollback;
      
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper);

  end pc_inativa_cargos_web;

  procedure pc_inativa_cargos (pr_cdcooper          in crapass.cdcooper%type
                              ,pr_nrcpfcgc          in crapass.nrcpfcgc%type
                              ,pr_cdfuncao          in crapass.tpvincul%type
                              ,pr_dtinicio_vigencia in date
                              ,pr_dtfim_vigencia    in date
                              ,pr_nrdrowid          in rowid
                              ,pr_cdoperad          in crapope.cdoperad%type
                              ,pr_cdcritic         out pls_integer
                              ,pr_dscritic         out varchar2) is

  ---------------------------------------------------------------------------
  --             
  --  Programa : pc_inativa_cargos
  --  Sistema  : Ayllos Web
  --  Autor    : Gabriel Marcos
  --  Data     : Agosto/2018                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Rotina para inativar cargos do cooperado.
  --
  -- Alteracoes: 13/08/2019 - Nova forma de buscar cargos. Tratamento super-usuario.
  --                          Projeto 484.2 - Gabriel Marcos (Mouts).   
  --
  ---------------------------------------------------------------------------
 
    -- Analisa necessidade de vigencia do cargo
    cursor cr_vig_funcao (pr_cdfuncao in tbcadast_funcao_pessoa.cdfuncao%type) is
    select fun.flgvigencia
         , fun.dsfuncao
      from tbcadast_funcao_pessoa fun
     where fun.cdfuncao = pr_cdfuncao;
    rw_vig_funcao cr_vig_funcao%rowtype;
     
    -- Verifica funcoes que se acumulam
    cursor cr_acumula_cargos (pr_cdcooper in crapass.cdcooper%type
                             ,pr_nrcpfcgc in crapass.nrcpfcgc%type
                             ,pr_cdfuncao in tbcadast_vig_funcao_pessoa.cdfuncao%type) is
    select (select vig.cdfuncao
              from tbcadast_vig_funcao_pessoa vig
             where vig.cdcooper = pr_cdcooper
               and vig.nrcpfcgc = pr_nrcpfcgc
               and vig.cdfuncao in ('DT','DS')
               and vig.dtfim_vigencia is null) delegado
         , (select vig.cdfuncao
              from tbcadast_vig_funcao_pessoa vig
             where vig.cdcooper = pr_cdcooper
               and vig.nrcpfcgc = pr_nrcpfcgc
               and vig.cdfuncao in ('CL','CS','CM')
               and vig.dtfim_vigencia is null) comitedu
         , (select vig.cdfuncao
              from tbcadast_vig_funcao_pessoa vig
             where vig.cdcooper = pr_cdcooper
               and vig.nrcpfcgc = pr_nrcpfcgc
               and vig.cdfuncao not in ('DT','DS','CL','CS','CM',pr_cdfuncao)
               and vig.dtfim_vigencia is null) outrafun
      from dual;
    rw_acumula_cargos cr_acumula_cargos%rowtype; 
     
    -- Busca cargos do cooperado
    cursor cr_busca_cargos (pr_nrdrowid in rowid) is
    select fun.dsfuncao
         , fun.cdfuncao
         , vig.dtinicio_vigencia
         , vig.dtfim_vigencia
      from tbcadast_vig_funcao_pessoa vig
         , tbcadast_funcao_pessoa     fun
     where vig.rowid    = pr_nrdrowid
       and fun.cdfuncao = vig.cdfuncao;
    rw_busca_cargos cr_busca_cargos%rowtype;
    
    -- Validar cpf / cnpj passado por parametro
    cursor cr_crapass (pr_cdcooper in crapass.cdcooper%type
                      ,pr_nrcpfcgc in crapass.nrcpfcgc%type) is
    select ass.inpessoa
         , ass.nrcpfcgc
      from crapass ass
     where ass.cdcooper = pr_cdcooper
       and ass.nrcpfcgc = pr_nrcpfcgc;
    rw_crapass cr_crapass%rowtype;
    
    -- Buscar dado para data de fim de vigencia
    cursor cr_crapdat (pr_cdcooper crapdat.cdcooper%type) is
    select dat.dtmvtolt
      from crapdat dat
     where dat.cdcooper = pr_cdcooper;
    rw_crapdat cr_crapdat%rowtype;
    
    vr_cdfuncao varchar2(2) := ' ';
      
  begin

    -- Verifica necessidade de data de vigencia
    -- Valida se codigo da funcao eh valido
    open cr_vig_funcao (pr_cdfuncao);
    fetch cr_vig_funcao into rw_vig_funcao;
    
    -- Aborta em caso de parametro invalido
    if cr_vig_funcao%notfound then
      
      close cr_vig_funcao;
      vr_dscritic := 'Cargo não encontrado.';
      raise vr_exc_erro;
      
    end if;
      
    close cr_vig_funcao;

    -- Analise dos parametros recebidos
    if rw_vig_funcao.flgvigencia = 0 then
      vr_dscritic := 'Cargo nao possui controle de vigência.';
      raise vr_exc_erro;
    end if;

    -- Valida parametro cpf / cnpj passado via XML
    open cr_crapass (pr_cdcooper => pr_cdcooper
                    ,pr_nrcpfcgc => pr_nrcpfcgc);
    fetch cr_crapass into rw_crapass;
      
    -- Caso nao encontre cooperado aborta operacao
    if cr_crapass%notfound then
        
      close cr_crapass;
      vr_cdcritic := 9;
      raise vr_exc_erro;
        
    end if;
    
    close cr_crapass;
    
    -- Busca data de movimentacao
    -- para fazer validacao do fim de vigencia
    open cr_crapdat (pr_cdcooper);
    fetch cr_crapdat into rw_crapdat;
    
    -- Aborta se nao encontrar
    if cr_crapdat%notfound then
      
      close cr_crapdat;
      vr_dscritic := 'Data da cooperativa não cadastrada.';
      raise vr_exc_erro;

    end if;
    
    close cr_crapdat;

    -- Cargos que exigem data de inicio de vigencia
    if pr_dtinicio_vigencia is null then
      vr_dscritic := 'Data de inicio de vigência não preenchida.';
      raise vr_exc_erro;
    elsif pr_dtfim_vigencia is null then
      vr_dscritic := 'Data de fim de vigência não preenchida.';
      raise vr_exc_erro;
    elsif to_char(pr_dtfim_vigencia,'dd/mm/rrrr') <> to_char(rw_crapdat.dtmvtolt,'dd/mm/yyyy') then
      vr_dscritic := 'Data de fim de vigência deve ser igual a data de movimentação.';
      raise vr_exc_erro;
    elsif pr_dtinicio_vigencia > pr_dtfim_vigencia then
      vr_dscritic := 'Data de fim de vigência deve ser maior que a data de início.';
      raise vr_exc_erro;
    end if;

    -- Analisa permissoes do operador
    open cr_cdoperad (pr_cdcooper
                     ,pr_cdoperad);
    fetch cr_cdoperad into rw_cdoperad;

    -- Caso nao tenha permissao retorna critica
    -- Autorizar rotinas automaticas que utilizam operador 1
    if cr_cdoperad%notfound and pr_cdoperad <> '1' then
      close cr_cdoperad;
      vr_dscritic := 'Operador sem permissão para alterar cargos.';
      raise vr_exc_erro;
    end if;
      
    close cr_cdoperad;  

    -- Apenas contabilidade usam cargos antigos
    if pr_cdfuncao not in ('DT','DS','CL','CS','CM') and
       rw_cdoperad.cddepart <> 6 then
      vr_dscritic := 'Cargo de uso restrito da contabilidade.';
      raise vr_exc_erro;
    end if;

    -- Valida rowid do parametro
    open cr_busca_cargos (pr_nrdrowid => pr_nrdrowid);
    fetch cr_busca_cargos into rw_busca_cargos;
    
    -- Aborda operacao se nao encontrar
    if cr_busca_cargos%notfound then
      
      close cr_busca_cargos;
      vr_dscritic := 'Cargo/Função não encontrado.';
      raise vr_exc_erro; 
    
    end if;
    
    close cr_busca_cargos;

    -- Analisa acumulo de cargos do cpf / cnpj
    open cr_acumula_cargos (pr_cdcooper
                           ,pr_nrcpfcgc
                           ,pr_cdfuncao);                     
    fetch cr_acumula_cargos into rw_acumula_cargos;
    close cr_acumula_cargos;

    if rw_acumula_cargos.outrafun is not null then
      vr_cdfuncao := rw_acumula_cargos.outrafun;
    end if;

    -- Evita que cargo inativo tenha sua data de
    -- fim de vigencia atualizada
    if rw_busca_cargos.dtfim_vigencia is not null then
      vr_dscritic := 'Cargo/Função já está inativa.';
      raise vr_exc_erro; 
    end if;
      
    begin

      update tbcadast_vig_funcao_pessoa vig
         set vig.dtfim_vigencia    = pr_dtfim_vigencia   
       where vig.cdcooper = pr_cdcooper
         and vig.rowid    = pr_nrdrowid;
             
    exception

      when others then
        
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao inativar cargo/função: ' || sqlerrm;
        raise vr_exc_erro;

    end;
    
    -- Controle de historico de vinculos
    pc_historico_tpvinculo (pr_cdcooper => pr_cdcooper
                           ,pr_nrcpfcgc => pr_nrcpfcgc
                           ,pr_tpvincul => vr_cdfuncao
                           ,pr_dscritic => vr_dscritic);
                     
    -- Aborta em caso de erro
    if trim(vr_dscritic) is not null then
      raise vr_exc_erro;
    end if;
    
    -- Busca contas do cooperado para gerar log
    for rw_busca_cooperado in cr_busca_cooperado (pr_cdcooper
                                                 ,pr_nrcpfcgc) loop
      
      -- Gravar log de insercao de funcao
      gene0001.pc_gera_log(pr_cdcooper => rw_busca_cooperado.cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => null
                          ,pr_dsorigem => gene0001.vr_vet_des_origens(5)
                          ,pr_dstransa => 'Inativado funcao: '||rw_vig_funcao.dsfuncao
                          ,pr_dttransa => trunc(sysdate)
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => gene0002.fn_busca_time
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'PESSOA'
                          ,pr_nrdconta => rw_busca_cooperado.nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
    
    end loop;
     
    -- Gera log
    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_nmarqlog     => 'pessoa.log'
                              ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                  ' --> Operador '|| pr_cdoperad || ' - ' ||
                                                  'Inativou o cargo com a data de fim de vigencia para ' || 
                                                  to_char(pr_dtfim_vigencia,'DD/MM/RRRR') ||
                                                  ', cargo/funcao ' || rw_busca_cargos.dsfuncao ||
                                                  ' para o CNPJ ' || gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapass.nrcpfcgc,
                                                                                               pr_inpessoa => rw_crapass.inpessoa) ||         
                                                  '.');
   
    commit;

  exception
    
    when vr_exc_erro then

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
      pr_dscritic := 'Erro geral na rotina da tela TELA_PESSOA.pc_inativa_cargos: ' || SQLERRM;
      
      rollback;
      
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper);

  end pc_inativa_cargos;

  procedure pc_pessoa_progress (pr_cdcooper  in crapass.cdcooper%type
                               ,pr_nrdconta  in crapass.nrdconta%type
                               ,pr_cdfuncao  in crapass.tpvincul%type
                               ,pr_cdoperad  in crapope.cdoperad%type
                               ,pr_cdcritic out pls_integer
                               ,pr_dscritic out varchar2) is

  ---------------------------------------------------------------------------
  --             
  --  Programa : pc_pessoa_progress
  --  Sistema  : Ayllos Web
  --  Autor    : Gabriel Marcos
  --  Data     : Outubro/2018                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Rotina para fazer tratamento da rotina (tela) progress.
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------
      
  -- Buscar dado para data de fim de vigencia
  cursor cr_crapdat (pr_cdcooper crapdat.cdcooper%type) is
  select dat.dtmvtolt
    from crapdat dat
   where dat.cdcooper = pr_cdcooper;
  rw_crapdat cr_crapdat%rowtype;
  
  -- Buscar conta do cooperado
  cursor cr_crapass (pr_cdcooper in crapass.cdcooper%type
                    ,pr_nrdconta in crapass.nrdconta%type) is
  select ass.cdcooper
       , ass.nrdconta
       , ass.nrcpfcgc
    from crapass ass
   where ass.cdcooper = pr_cdcooper
     and ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%rowtype;
  
  -- Busca funcao do cooperado
  cursor cr_cdfunca (pr_cdcooper in crapass.tpvincul%type
                    ,pr_nrcpfcgc in crapass.nrcpfcgc%type) is
  select distinct
         vig.cdcooper
       , vig.nrcpfcgc
       , vig.cdfuncao
       , vig.dtinicio_vigencia
       , vig.rowid
       , pes.flgvigencia
    from tbcadast_vig_funcao_pessoa vig
       , tbcadast_funcao_pessoa     pes
   where vig.cdcooper = pr_cdcooper
     and vig.nrcpfcgc = pr_nrcpfcgc
     and vig.dtfim_vigencia is null
     and pes.cdfuncao = vig.cdfuncao;
  
  begin
  
    -- Buscar conta do cooperado
    open cr_crapass (pr_cdcooper
                    ,pr_nrdconta);
    fetch cr_crapass into rw_crapass;
    
    -- Caso tenha encontrado
    if cr_crapass%notfound then
      close cr_crapass;
      vr_dscritic := 'Cooperado não cadastrado no sistema.';
      raise vr_exc_erro;
    end if;
    
    close cr_crapass;

    -- Busca data de movimentacao
    -- para fazer validacao do fim de vigencia
    open cr_crapdat (pr_cdcooper);
    fetch cr_crapdat into rw_crapdat;
    
    -- Aborta se nao encontrar
    if cr_crapdat%notfound then
      
      close cr_crapdat;
      vr_dscritic := 'Data da cooperativa não cadastrada.';
      raise vr_exc_erro;

    end if;
    
    close cr_crapdat;
    
    if trim(pr_cdoperad) is null then
      vr_dscritic := 'Código do operador não informado.';
      raise vr_exc_erro;
    end if;
    
    -- Verifica se existem funcao ativa
    -- Como tela pessoa so manipula funcoes antigas
    -- Deve inativar TODAS as funcoes ativas
    -- Por que funcoes antigas nao podem se acumular
    for rw_cdfunca in cr_cdfunca (rw_crapass.cdcooper
                                 ,rw_crapass.nrcpfcgc) loop

      if rw_cdfunca.flgvigencia = 1 then

        -- Inativar cargos do cooperado
        pc_inativa_cargos (pr_cdcooper          => rw_cdfunca.cdcooper
                          ,pr_nrcpfcgc          => rw_cdfunca.nrcpfcgc
                          ,pr_cdfuncao          => rw_cdfunca.cdfuncao
                          ,pr_dtinicio_vigencia => rw_cdfunca.dtinicio_vigencia
                          ,pr_dtfim_vigencia    => rw_crapdat.dtmvtolt
                          ,pr_nrdrowid          => rw_cdfunca.rowid
                          ,pr_cdoperad          => pr_cdoperad
                          ,pr_cdcritic          => vr_cdcritic
                          ,pr_dscritic          => vr_dscritic);
                 
      else
            
        -- Excluir cargo caso nao tenha controle de vigencia 
        pc_excluir_cargos (pr_cdcooper => rw_cdfunca.cdcooper
                          ,pr_nrcpfcgc => rw_cdfunca.nrcpfcgc
                          ,pr_cdfuncao => rw_cdfunca.cdfuncao
                          ,pr_nrdrowid => rw_cdfunca.rowid
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_cdcritic => vr_cdcritic
                          ,pr_dscritic => vr_dscritic);

      end if;

      -- Aborta operacao se retornar critica 
      if nvl(vr_cdcritic,0) > 0 or trim(vr_dscritic) is not null then
        raise vr_exc_erro;
      end if;
                                     
    end loop;    
      
    -- Cooperado eh repassado como null
    -- nao precisa ser inserido
    if trim(pr_cdfuncao) is not null then
    
      -- Inserir novo cargo ao cooperado
      pc_inserir_cargos (pr_cdcooper          => pr_cdcooper
                        ,pr_nrcpfcgc          => rw_crapass.nrcpfcgc
                        ,pr_cdfuncao          => pr_cdfuncao
                        ,pr_dtinicio_vigencia => to_char(rw_crapdat.dtmvtolt,'dd/mm/yyyy')
                        ,pr_cdoperad          => pr_cdoperad
                        ,pr_cdcritic          => vr_cdcritic
                        ,pr_dscritic          => vr_dscritic);
                        
    end if;
                      
    -- Aborta operacao se retornar critica 
    if nvl(vr_cdcritic,0) > 0 or trim(vr_dscritic) is not null then
      raise vr_exc_erro;
    end if;

    -- Gera log
    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_nmarqlog     => 'pessoa.log'
                              ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                  ' --> Operador '|| pr_cdoperad || ' - ' ||
                                                  'Utilizou Tela Pessoa (Progress) para fazer manutencao '||
                                                  'de cargos do cooperado: '||pr_nrdconta);
    
    commit;

  exception
    
    when vr_exc_erro then

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

    when others then

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela TELA_PESSOA.pc_pessoa_progress: ' || sqlerrm;

  end pc_pessoa_progress;

  procedure pc_alterar_pessoa (pr_nrdconta   in crapass.nrdconta%type
                              ,pr_inpessoa   in crapass.inpessoa%type
                              ,pr_xmllog     in varchar2
                              ,pr_cdcritic  out pls_integer
                              ,pr_dscritic  out varchar2
                              ,pr_retxml in out nocopy XMLType
                              ,pr_nmdcampo  out varchar2    
                              ,pr_des_erro  out varchar2) is
 
  ---------------------------------------------------------------------------
  --
  --  Programa : pc_alterar_pessoa
  --  Sistema  : Ayllos Web
  --  Autor    : Gabriel Marcos
  --  Data     : Agosto/2018                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Rotina para alterar pessoa do cooperado.
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------
  
    -- Encontra cooperado
    cursor cr_crapass (pr_cdcooper in crapass.cdcooper%type
                      ,pr_nrdconta in crapass.nrdconta%type) is
    select ass.nrdconta
          ,ass.inpessoa
          ,decode(ass.inpessoa,1,'Pessoa Fisica',2,'Pessoa Juridica',3,'Conta Administrativa','Invalido') dspessoa
          ,ass.rowid
      from crapass ass
     where ass.cdcooper = pr_cdcooper
       and ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%rowtype;
    
    -- Verifica se CNPJ e de cooperativa
    cursor cr_associado (pr_cdcooper in crapass.cdcooper%type
                        ,pr_nrdconta in crapass.nrdconta%type) is
    select cop.nrdocnpj
      from crapass ass
         , crapcop cop
     where ass.cdcooper = pr_cdcooper
       and ass.nrdconta = pr_nrdconta
       and cop.cdcooper = ass.cdcooper
       and cop.nrdocnpj = ass.nrcpfcgc;
    rw_associado cr_associado%rowtype;
    
    vr_inpessoa varchar(100) := '';
    vr_nrdrowid rowid;
      
  begin
    
    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'PESSOA'
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
      raise vr_exc_erro;
    end if;
    
    -- Contas com cnpj igual ao da cooperativa
    -- por regra terao o tipo de pessoa setado 
    -- para o valor 2 ou 3. Caso seja recebido
    -- por parametro algo diferente, rotina sera abortada                       
    if nvl(pr_inpessoa,0) not in (2,3) then
      vr_dscritic := 'Tipo de pessoa não permitido.';
      raise vr_exc_erro;
    end if;
    
    -- Verifica se foram passados parametros
    if nvl(pr_nrdconta,0) = 0 then
      vr_dscritic := 'Informe a Conta/DV do cooperado.';
      raise vr_exc_erro;
    end if;

    -- Analisa permissoes do operador
    open cr_cdoperad (vr_cdcooper
                     ,vr_cdoperad);
    fetch cr_cdoperad into rw_cdoperad;

    -- Caso nao tenha permissao retorna critica
    if cr_cdoperad%notfound then
      close cr_cdoperad;
      vr_dscritic := 'Operador sem permissão para alterar pessoa.';
      raise vr_exc_erro;
    end if;
      
    close cr_cdoperad; 

    -- Apenas contabilidade usam cargos antigos
    if rw_cdoperad.cddepart <> 6 then
      vr_dscritic := 'Opção de uso restrito da contabilidade.';
      raise vr_exc_erro;
    end if;

    -- Busca dados do cooperado
    open cr_crapass (vr_cdcooper
                    ,pr_nrdconta);         
    fetch cr_crapass into rw_crapass;
    
    -- Realiza operacoes caso encontre
    if cr_crapass%found then
      
      close cr_crapass;
      
      -- Evita atualizacao desnecessaria
      if rw_crapass.inpessoa = pr_inpessoa then
        vr_dscritic := 'Tipo de pessoa deve ser diferente do já cadastrado.';
        raise vr_exc_erro;
      end if;
      
      -- Compara cpf / cnpj com info da cooperativa
      open cr_associado (vr_cdcooper
                        ,pr_nrdconta);
      fetch cr_associado into rw_associado;
      
      -- Se valores forem diferentes
      -- a operacao nao e permitida
      if cr_associado%notfound then
       
        close cr_associado;
        vr_dscritic := 'Somente permitido alteração de pessoa que tenha ' ||
                       'mesmo CNPJ da Cooperativa.';
        raise vr_exc_erro;
      
      end if;
      
      close cr_associado;
      
      begin

        update crapass c
           set c.inpessoa = pr_inpessoa
         where c.rowid = rw_crapass.rowid
         returning decode(c.inpessoa,1,'Pessoa Fisica',2,'Pessoa Juridica',3,'Conta Administrativa','Invalido') into vr_inpessoa;
           
      exception
        
        when others then
          
          -- Montar mensagem de critica
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao atualizar tipo de pessoa: ' || sqlerrm;
          raise vr_exc_erro;

      end;
      
      -- Gravar log de insercao de funcao
      gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => null
                          ,pr_dsorigem => gene0001.vr_vet_des_origens(vr_idorigem)
                          ,pr_dstransa => 'Tipo de pessoa alterado de '||
                                          rw_crapass.dspessoa||' para '|| trim(vr_inpessoa)
                          ,pr_dttransa => trunc(sysdate)
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => gene0002.fn_busca_time
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'PESSOA'
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'pessoa.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' --> Operador '|| vr_cdoperad || ' - ' ||
                                                    'Alterou o tipo de pessoa da conta ' || 
                                                    TRIM(gene0002.fn_mask_conta(rw_crapass.nrdconta)) ||
                                                    ' de ' || rw_crapass.inpessoa || ' para ' || trim(vr_inpessoa) ||
                                                    '.');
                                                    
    else
      
      close cr_crapass;
      vr_cdcritic := 9;      
      raise vr_exc_erro;
      
    end if;      

    commit;
    
    pr_des_erro := 'OK';
    
  exception
    
    when vr_exc_erro then

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
      pr_dscritic := 'Erro geral na rotina da tela TELA_PESSOA.pc_buscar_cooperado: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      rollback;
      
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper);

  end pc_alterar_pessoa;

  procedure pc_historico_tpvinculo (pr_cdcooper  in crapass.nrdconta%type
                                   ,pr_nrcpfcgc  in crapass.nrcpfcgc%type
                                   ,pr_tpvincul  in crapass.tpvincul%type
                                   ,pr_dscritic out varchar2) is
 
  ---------------------------------------------------------------------------
  --
  --  Programa : pc_historico_tpvinculo
  --  Sistema  : Ayllos Web
  --  Autor    : Gabriel Marcos
  --  Data     : Agosto/2018                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Fazer controle de historico de vinculos
  --
  -- Alteracoes: 13/08/2019 - Adicionado flag de integracao com brc.
  --                          Projeto 484.2 - Gabriel Marcos (Mouts).   
  --
  ---------------------------------------------------------------------------

    -- Buscar conta do cooperado
    cursor cr_crapass (pr_cdcooper in crapass.cdcooper%type
                      ,pr_nrcpfcgc in crapass.nrcpfcgc%type) is
    select ass.cdcooper
         , pes.idpessoa
      from crapass         ass
         , tbcadast_pessoa pes
     where ass.cdcooper = pr_cdcooper
       and ass.nrcpfcgc = pr_nrcpfcgc
       and pes.nrcpfcgc = ass.nrcpfcgc;
    rw_crapass cr_crapass%rowtype;
    
    -- Cooperativas com eventos assembleares ativos
    cursor cr_crapcop (pr_cdcooper in crapcop.cdcooper%type) is
    select cop.flgrupos
      from crapcop cop
     where cop.cdcooper = pr_cdcooper
     and cop.flgrupos = 1; -- Evento assemblear ativo
    rw_crapcop cr_crapcop%rowtype;

    -- Limpeza de registros nao enviados
    cursor cr_limpeza_registros (pr_cdcooper in crapass.cdcooper%type
                                ,pr_idpessoa in tbcadast_pessoa.idpessoa%type) is
    select rowid
      from tbhistor_vinculo_coop vin
     where vin.cdcooper   = pr_cdcooper
       and vin.idpessoa   = pr_idpessoa
       and vin.tpsituacao = 0;
    rw_limpeza_registros cr_limpeza_registros%rowtype;

    vr_exc_saida            exception;    
    vr_retorno              xmltype;
    vr_nrmatric             tbhistor_vinculo_coop.nrmatric%type;
    vr_tpvincul             crapass.tpvincul%type := pr_tpvincul;
    vr_tpsituacao_matricula tbhistor_vinculo_coop.tpsituacao_matricula%type;
      
  begin
    
    -- Aborta caso alguma variavel nao seja informada
    if nvl(pr_cdcooper,0) = 0 then
      vr_dscritic := 'Cooperativa nao informada.';
      raise vr_exc_erro;
    elsif nvl(pr_nrcpfcgc,0) = 0 then
      vr_dscritic := 'CPF / CNPJ nao informado.';
      raise vr_exc_erro;
    -- Raise nao aplicavel por que a sigla
    -- de cooperado eh um vazio ' '
    elsif trim(pr_tpvincul) is null then
      vr_tpvincul := ' ';
    end if;
  
    -- Busca dados do cooperado
    open cr_crapass (pr_cdcooper
                    ,pr_nrcpfcgc);
    fetch cr_crapass into rw_crapass;
    
    -- Aborta caso nao encontre
    if cr_crapass%notfound then 
      close cr_crapass;  
      vr_dscritic := 'Cooperado não encontrado na tabela de associados';
      raise vr_exc_erro;
    end if;
    
    close cr_crapass;
  
    -- Cooperativas ativas devem possuir o flag
    open cr_crapcop (pr_cdcooper);
    fetch cr_crapcop into rw_crapcop;
    
    -- Aborta caso nao encontre
    if cr_crapcop%notfound then
      close cr_crapcop;
      vr_dscritic := 'Cooperativa não está ativa para eventos assembleares.';
      raise vr_exc_saida;
    end if;
    
    close cr_crapcop;

    -- Rotina para retorno dos dados da matricula do cooperado
    cada0012.pc_retorna_matricula(pr_cdcooper => rw_crapass.cdcooper
                                 ,pr_idpessoa => rw_crapass.idpessoa
                                 ,pr_retorno  => vr_retorno
                                 ,pr_dscritic => vr_dscritic);
    
    -- Aborta em caso de erro                             
    if trim(vr_dscritic) is not null then
      raise vr_exc_erro;
    end if;
    
    begin
    
      vr_nrmatric := TRIM(vr_retorno.extract('/Matriculas/Matricula/nrmatric/text()').getstringval());
      vr_tpsituacao_matricula  := TRIM(vr_retorno.extract('/Matriculas/Matricula/tpsituacao_matricula/text()').getstringval());

    exception
      when others then
        vr_dscritic := 'Erro ao receber variaveis de matricula: '||sqlerrm;
        raise vr_exc_erro;
    end;
    
    -- Busca registros nao enviados
    open cr_limpeza_registros (rw_crapass.cdcooper
                              ,rw_crapass.idpessoa);
    fetch cr_limpeza_registros into rw_limpeza_registros;
    
    -- Deleta caso encontre
    if cr_limpeza_registros%found then
      begin
        delete 
          from tbhistor_vinculo_coop vin
         where vin.rowid = rw_limpeza_registros.rowid;                   
      exception
        when others then
          close cr_limpeza_registros;
          vr_dscritic := 'Erro ao inserir dadosna tabela tbhistor_vinculo_coop: '||sqlerrm;
          raise vr_exc_erro;
      end;
    end if;
    
    close cr_limpeza_registros;

    -- Verifica parametros cadastrados em base
    -- Default zero, em periodos de implantacao
    -- o parametro pode ser alterado para 1
    -- para que o sistema nao seja sobrecarregado
    begin
      select nvl(c.flag_integra,0)
        into vr_tpsituacao
        from tbevento_param c
       where c.cdcooper = pr_cdcooper;
    exception
      when others then
        vr_dscritic := 'Erro ao manipular tbevento_param: '||sqlerrm;
        raise vr_exc_saida;
    end;  
    
    begin
        
      insert
        into tbhistor_vinculo_coop (cdcooper
                                   ,idpessoa
                                   ,nrdconta
                                   ,dhalteracao
                                   ,tpsituacao
                                   ,dhcomunicacao
                                   ,dserro
                                   ,qttentativa
                                   ,tpvincul
                                   ,nrmatric
                                   ,tpsituacao_matricula)
      values                       (rw_crapass.cdcooper
                                   ,rw_crapass.idpessoa
                                   ,0
                                   ,sysdate
                                   ,vr_tpsituacao
                                   ,null
                                   ,null
                                   ,null
                                   ,vr_tpvincul
                                   ,vr_nrmatric
                                   ,vr_tpsituacao_matricula);
                                   
    exception
      when others then
        vr_dscritic := 'Erro ao inserir dadosna tabela tbhistor_vinculo_coop: '||sqlerrm;
        raise vr_exc_erro;
    end;

  exception
    
    when vr_exc_saida then
      
      -- Nao deve fazer nada pois o objetivo da 
      -- exception eh apenas nao inserir na tabela
      null;

    when others then
      
      pr_dscritic := vr_dscritic;  
      
  end pc_historico_tpvinculo;

end TELA_PESSOA;
/