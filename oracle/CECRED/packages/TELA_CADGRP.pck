CREATE OR REPLACE PACKAGE CECRED.TELA_CADGRP IS

  procedure pc_fracao_mostra_param (pr_xmllog     in varchar2
                                   ,pr_cdcritic  out pls_integer
                                   ,pr_dscritic  out varchar2
                                   ,pr_retxml in out nocopy XMLType
                                   ,pr_nmdcampo  out varchar2    
                                   ,pr_des_erro  out varchar2);
  
  procedure pc_fracao_alterar_param (pr_frmaxima   in number
                                    ,pr_fraideal   in number
                                    ,pr_xmllog     in varchar2
                                    ,pr_cdcritic  out pls_integer
                                    ,pr_dscritic  out varchar2
                                    ,pr_retxml in out nocopy XMLType
                                    ,pr_nmdcampo  out varchar2    
                                    ,pr_des_erro  out varchar2);

  procedure pc_exercicio_mostra_param (pr_nrregist   in integer                            
                                      ,pr_nriniseq   in integer  
                                      ,pr_xmllog     in varchar2
                                      ,pr_cdcritic  out pls_integer
                                      ,pr_dscritic  out varchar2
                                      ,pr_retxml in out nocopy XMLType
                                      ,pr_nmdcampo  out varchar2    
                                      ,pr_des_erro  out varchar2);
                                      
  procedure pc_exercicio_inserir_edital (pr_nrano_exercicio     in varchar2
                                        ,pr_dtinicio_grupo      in varchar2
                                        ,pr_dtfim_grupo         in varchar2
                                        ,pr_xmllog              in varchar2
                                        ,pr_cdcritic           out pls_integer
                                        ,pr_dscritic           out varchar2
                                        ,pr_retxml          in out nocopy XMLType
                                        ,pr_nmdcampo           out varchar2    
                                        ,pr_des_erro           out varchar2);
                                        
  procedure pc_exercicio_alterar_edital (pr_rowid               in rowid
                                        ,pr_dtinicio_grupo      in varchar2
                                        ,pr_dtfim_grupo         in varchar2
                                        ,pr_xmllog              in varchar2
                                        ,pr_cdcritic           out pls_integer
                                        ,pr_dscritic           out varchar2
                                        ,pr_retxml          in out nocopy XMLType
                                        ,pr_nmdcampo           out varchar2    
                                        ,pr_des_erro           out varchar2);                                                                           
                                        
  procedure pc_exercicio_excluir_edital (pr_nrano_exercicio in varchar2
                                        ,pr_rowid           in rowid
                                        ,pr_xmllog          in varchar2
                                        ,pr_cdcritic       out pls_integer
                                        ,pr_dscritic       out varchar2
                                        ,pr_retxml      in out nocopy XMLType
                                        ,pr_nmdcampo       out varchar2    
                                        ,pr_des_erro       out varchar2);
                  
  procedure pc_exercicio_ativar_edital (pr_rowid           in rowid
                                       ,pr_xmllog          in varchar2
                                       ,pr_cdcritic       out pls_integer
                                       ,pr_dscritic       out varchar2
                                       ,pr_retxml      in out nocopy XMLType
                                       ,pr_nmdcampo       out varchar2    
                                       ,pr_des_erro       out varchar2);
          
  procedure pc_cursor_opcao_c (pr_cdagenci   in tbevento_pessoa_grupos.cdagenci%type
                              ,pr_nrdgrupo   in tbevento_pessoa_grupos.nrdgrupo%type
                              ,pr_nrregist   in integer                             
                              ,pr_nriniseq   in integer     
                              ,pr_xmllog     in varchar2
                              ,pr_cdcritic  out pls_integer
                              ,pr_dscritic  out varchar2
                              ,pr_retxml in out nocopy XMLType
                              ,pr_nmdcampo  out varchar2    
                              ,pr_des_erro  out varchar2);
                              
  procedure pc_grupo_disponivel(pr_nrdgrupo   in tbevento_pessoa_grupos.nrdgrupo%type
                               ,pr_cdagenci   in tbevento_pessoa_grupos.cdagenci%type
                               ,pr_nrregist   in integer                       
                               ,pr_nriniseq   in integer
                               ,pr_xmllog     in varchar2              
                               ,pr_cdcritic  out pls_integer         
                               ,pr_dscritic  out varchar2           
                               ,pr_retxml in out nocopy XMLType      
                               ,pr_nmdcampo  out varchar2              
                               ,pr_des_erro  out varchar2);
                                
  procedure pc_agencia_disponivel(pr_nrregist   in integer                                      
                                 ,pr_nriniseq   in integer               
                                 ,pr_xmllog     in varchar2          
                                 ,pr_cdcritic  out pls_integer          
                                 ,pr_dscritic  out varchar2           
                                 ,pr_retxml in out nocopy XMLType   
                                 ,pr_nmdcampo  out varchar2          
                                 ,pr_des_erro  out varchar2);
                                  
  procedure pc_cursor_opcao_b (pr_nrdconta   in crapass.nrdconta%type
                              ,pr_nrcpfcgc   in crapass.nrcpfcgc%type
                              ,pr_xmllog     in varchar2
                              ,pr_cdcritic  out pls_integer
                              ,pr_dscritic  out varchar2
                              ,pr_retxml in out nocopy XMLType
                              ,pr_nmdcampo  out varchar2    
                              ,pr_des_erro  out varchar2);
                              
  procedure pc_alterar_opcao_b (pr_nrdgrupo   in tbevento_pessoa_grupos.nrdgrupo%type
                               ,pr_rowid      in rowid
                               ,pr_xmllog     in varchar2
                               ,pr_cdcritic  out pls_integer
                               ,pr_dscritic  out varchar2
                               ,pr_retxml in out nocopy XMLType
                               ,pr_nmdcampo  out varchar2    
                               ,pr_des_erro  out varchar2);
                               
  procedure pc_cursor_opcao_g (pr_cdagenci   in varchar2
                              ,pr_xmllog     in varchar2
                              ,pr_cdcritic  out pls_integer
                              ,pr_dscritic  out varchar2
                              ,pr_retxml in out nocopy XMLType
                              ,pr_nmdcampo  out varchar2    
                              ,pr_des_erro  out varchar2);
                                                           
  procedure pc_agenci_opcao_g (pr_cdagenci   in crapass.cdagenci%type
                              ,pr_xmllog     in varchar2
                              ,pr_cdcritic  out pls_integer
                              ,pr_dscritic  out varchar2
                              ,pr_retxml in out nocopy XMLType
                              ,pr_nmdcampo  out varchar2    
                              ,pr_des_erro  out varchar2);

  procedure pc_btn_dstribui_g (pr_xmllog     in varchar2
                              ,pr_cdcritic  out pls_integer
                              ,pr_dscritic  out varchar2
                              ,pr_retxml in out nocopy XMLType
                              ,pr_nmdcampo  out varchar2    
                              ,pr_des_erro  out varchar2);

  procedure pc_analisar_param_grupo_web (pr_cdagenci   in varchar2 
                                        ,pr_qtdgrupo   in varchar2 
                                        ,pr_xmllog     in varchar2
                                        ,pr_cdcritic  out pls_integer
                                        ,pr_dscritic  out varchar2
                                        ,pr_retxml in out nocopy XMLType
                                        ,pr_nmdcampo  out varchar2    
                                        ,pr_des_erro  out varchar2);
                  
  procedure pc_distribui_conta_grupo_web (pr_cdagenci   in varchar2
                                         ,pr_qtdgrupo   in varchar2 
                                         ,pr_xmllog     in varchar2
                                         ,pr_cdcritic  out pls_integer
                                         ,pr_dscritic  out varchar2
                                         ,pr_retxml in out nocopy XMLType
                                         ,pr_nmdcampo  out varchar2    
                                         ,pr_des_erro  out varchar2);

END TELA_CADGRP;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_CADGRP IS

  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_CADGRP
  --  Sistema  : Ayllos Web
  --  Autor    : Gabriel Marcos
  --  Data     : Agosto/2018                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas a tela CADGRP
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

    -- Busca parametros cadastrados
    cursor cr_dsvlrprm (pr_cdcooper crapprm.cdcooper%type) is
    select prm.dsvlrprm
      from crapprm prm
     where prm.nmsistem = 'CRED'
       and prm.cdcooper = pr_cdcooper
       and prm.cdacesso = 'TELA_CADGRP_OPCAO_P'; 
               
    -- Variaveis padrao                            
    vr_nmdatela varchar2(100);                                  
    vr_nmeacao  varchar2(100);                                  
    vr_cdagenci varchar2(100);                                  
    vr_nrdcaixa varchar2(100);                                  
    vr_idorigem varchar2(100);                                  
    vr_cdoperad varchar2(100);  
    vr_dscritic varchar2(10000);  
    rw_dsvlrprm varchar2(100);                   
    
    vr_cdcooper integer;   
    vr_nrregist integer;
    vr_qtregist integer := 0; 
  
    vr_exc_saida exception; 
    
    vr_nrano_exercicio     date;
    vr_dtinicio_grupo      date;
    vr_dtfim_grupo         date;   

    vr_frmaxima number := 0;                                         
    vr_fraideal number := 0;      
    vr_intermin number := 0;
    vr_contador number := 0; 
    vr_cdcritic number;              

    -- Array para guardar o split dos dados contidos na dsvlrprm       
    vr_parametro  gene0002.typ_split; 
 
  procedure pc_fracao_mostra_param (pr_xmllog     in varchar2
                                   ,pr_cdcritic  out pls_integer
                                   ,pr_dscritic  out varchar2
                                   ,pr_retxml in out nocopy XMLType
                                   ,pr_nmdcampo  out varchar2    
                                   ,pr_des_erro  out varchar2) is
    
  ---------------------------------------------------------------------------
  --
  --  Programa : pc_fracao_mostra_param
  --  Sistema  : Ayllos Web
  --  Autor    : Gabriel Marcos
  --  Data     : Agosto/2018                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Rotina para mostrar parametros cadastrados para a 
  --             cooperativa na tabela crapprm (Opcao P).
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------
               
  begin
        
    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'CADGRP'
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
      raise vr_exc_saida;
    end if;

    -- Verifica parametros cadastrados em base
    open cr_dsvlrprm (vr_cdcooper);
    fetch cr_dsvlrprm into rw_dsvlrprm;
    close cr_dsvlrprm;
        
    vr_parametro := gene0002.fn_quebra_string(pr_string => rw_dsvlrprm
                                             ,pr_delimit => ';');
       
    -- Se encontrou popula variaveis                                          
    for i in 1..vr_parametro.count() loop
      case
        when i = 1 then vr_frmaxima := to_number(vr_parametro(i));
        when i = 2 then vr_fraideal := to_number(vr_parametro(i));
        when i = 3 then vr_intermin := to_number(vr_parametro(i));
        else null;
      end case;
    end loop;
   
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root',   pr_posicao => 0, pr_tag_nova => 'Dados',   pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'param',    pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'frmaxima', pr_tag_cont => to_char(nvl(vr_frmaxima,0),'fm9999999999','NLS_NUMERIC_CHARACTERS='',.'''), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'fraideal', pr_tag_cont => to_char(nvl(vr_fraideal,0),'fm9999999999','NLS_NUMERIC_CHARACTERS='',.'''), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'intermin', pr_tag_cont => to_char(nvl(vr_intermin,0),'fm9999999999','NLS_NUMERIC_CHARACTERS='',.'''), pr_des_erro => vr_dscritic);                           
                
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
      pr_dscritic := 'Erro geral na rotina da tela TELA_CADGRP.pc_fracao_mostra_param: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      rollback;
        
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper);

  end pc_fracao_mostra_param;

  procedure pc_fracao_alterar_param (pr_frmaxima   in number
                                    ,pr_fraideal   in number
                                    ,pr_xmllog     in varchar2
                                    ,pr_cdcritic  out pls_integer
                                    ,pr_dscritic  out varchar2
                                    ,pr_retxml in out nocopy XMLType
                                    ,pr_nmdcampo  out varchar2    
                                    ,pr_des_erro  out varchar2) is

  ---------------------------------------------------------------------------
  --
  --  Programa : pc_fracao_alterar_param
  --  Sistema  : Ayllos Web
  --  Autor    : Gabriel Marcos
  --  Data     : Agosto/2018                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Rotina para alterar valores de fracoes maximas
  --             e fracoes ideais dos grupos (Opcao P).
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

  begin

    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'CADGRP'
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
      raise vr_exc_saida;
    end if;
    
    -- Parametro deve ser informado
    if pr_frmaxima is null then
          
      vr_dscritic:= 'Fração máxima não informada.';
      pr_nmdcampo := 'frmmaxim';
      raise vr_exc_saida;  
        
    end if;

    -- Parametro deve ser informado
    if pr_fraideal is null then
          
      vr_dscritic:= 'Fração ideal não informada.';
      pr_nmdcampo := 'frmideal';
      raise vr_exc_saida;  
        
    end if;
        
    -- Verifica parametros cadastrados em base
    open cr_dsvlrprm (vr_cdcooper);
    fetch cr_dsvlrprm into rw_dsvlrprm;
    close cr_dsvlrprm;

    vr_parametro := gene0002.fn_quebra_string(pr_string => rw_dsvlrprm
                                             ,pr_delimit => ';');
         
    -- Se encontrou popula variaveis                                          
    for i in 1..vr_parametro.count loop
      case
        when i = 1 then vr_frmaxima := to_number(vr_parametro(i));
        when i = 2 then vr_fraideal := to_number(vr_parametro(i));
        when i = 3 then vr_intermin := to_number(vr_parametro(i));
        else null;
      end case;
    end loop;

    -- Compara o que quer se cadastrar com o que ja esta cadastrado
    if vr_fraideal = pr_fraideal and vr_frmaxima = pr_frmaxima then
      vr_dscritic := 'Parâmetros devem ser diferentes dos já registrados.';
      raise vr_exc_saida;
    end if;
    
    -- Fracao maxima deve ser 200 unidades maior que a ideal
    if pr_frmaxima < (pr_fraideal + vr_intermin) then
      vr_dscritic := 'A fracao máxima deve ter ' ||vr_intermin|| ' unidades ' ||
                     'de diferença para a ideal.';
      raise vr_exc_saida;      
    end if;

    begin

      update crapprm
         set dsvlrprm = pr_frmaxima||';'||pr_fraideal||';'||vr_intermin
       where nmsistem = 'CRED'
         and cdcooper = vr_cdcooper
         and cdacesso = 'TELA_CADGRP_OPCAO_P';
         

      -- Verifica operacoes realizadas acima
      if sql%rowcount = 0 then
        vr_dscritic := 'Operação não efetuada.';
        raise vr_exc_saida;
      end if;

      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'cadgrp.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| vr_cdoperad || ' - ' ||
                                                    'Efetuou a alteracao dos parametros de fracao de grupo.' || 
                                                    ' Fracao Ideal de ' || to_char(vr_fraideal,'fm9999999999') || ' para ' || to_char(pr_fraideal,'fm9999999999') ||
                                                    ' e Fracao Max.  de ' || to_char(vr_frmaxima,'fm9999999999') || ' para ' || to_char(pr_frmaxima,'fm9999999999') ||'.');

    exception
          
      when others then
            
        vr_dscritic := 'Erro ao atualizar parametros da Cooperativa.';
        raise vr_exc_saida;
            
    end;
                    
    --Realiza commit das alterações
    commit;
      
    pr_des_erro := 'OK';
      
  exception
      
    when vr_exc_saida then

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
      pr_dscritic := 'Erro geral na rotina da tela TELA_CADGRP.pc_fracao_alterar_param: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      rollback;
        
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper);
       
  end pc_fracao_alterar_param;
    
  procedure pc_exercicio_mostra_param (pr_nrregist   in integer                            
                                      ,pr_nriniseq   in integer 
                                      ,pr_xmllog     in varchar2
                                      ,pr_cdcritic  out pls_integer
                                      ,pr_dscritic  out varchar2
                                      ,pr_retxml in out nocopy XMLType
                                      ,pr_nmdcampo  out varchar2    
                                      ,pr_des_erro  out varchar2) is 
                                      
  ---------------------------------------------------------------------------
  --
  --  Programa : pc_exercicio_mostra_param
  --  Sistema  : Ayllos Web
  --  Autor    : Gabriel Marcos
  --  Data     : Agosto/2018                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Apresenta dados cadastrados na tabela de editais 
  --             da cooperativa (Opcao E).
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------
    
    -- Busca informacoes de editais na base
    cursor cr_cadast_edital (pr_cdcooper in tbevento_exercicio.cdcooper%type) is
    select edi.*
         , rowid
         , count(*) over (partition by edi.cdcooper) qtdregis
      from tbevento_exercicio edi
     where edi.cdcooper = pr_cdcooper
     ORDER by edi.nrano_exercicio desc;     
     
     vr_flgativo varchar(60);

  begin

    --Inicializar Variaveis
    vr_nrregist:= pr_nrregist;
      
    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'CADGRP'
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
      raise vr_exc_saida;
    end if;

    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="UTF-8"?><Root/>');
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root',  pr_posicao => 0, pr_tag_nova => 'dados',   pr_tag_cont => null, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dados', pr_posicao => 0, pr_tag_nova => 'editais', pr_tag_cont => null, pr_des_erro => vr_dscritic);   
           
    -- Busca editais cadastrados
    for rw_cadast_edital in cr_cadast_edital (vr_cdcooper) loop
          
      --Incrementar Quantidade Registros do Parametro
      vr_qtregist:= nvl(vr_qtregist,0) + 1;
              
      -- Controles da paginacao
      if (vr_qtregist < pr_nriniseq) or
         (vr_qtregist > (pr_nriniseq + pr_nrregist)) then
        continue;
      end if; 
      
      -- Apresenta registro ativo
      if rw_cadast_edital.flgativo = 1 then
        vr_flgativo := 'Ativo';
      else
        vr_flgativo := '';
      end if;
              
      --Numero Registros
      if vr_nrregist > 0 then 
            
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'editais', pr_posicao => 0, pr_tag_nova => 'edital', pr_tag_cont => null, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'edital',  pr_posicao => vr_contador, pr_tag_nova => 'rowid',               pr_tag_cont => rw_cadast_edital.rowid,                                     pr_des_erro => vr_dscritic); 
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'edital',  pr_posicao => vr_contador, pr_tag_nova => 'nrano_exercicio',     pr_tag_cont => to_char(rw_cadast_edital.nrano_exercicio,'RRRR'),           pr_des_erro => vr_dscritic); 
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'edital',  pr_posicao => vr_contador, pr_tag_nova => 'dtinicio_grupo',      pr_tag_cont => to_char(rw_cadast_edital.dtinicio_grupo,'DD/MM/RRRR'),      pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'edital',  pr_posicao => vr_contador, pr_tag_nova => 'dtfim_grupo',         pr_tag_cont => to_char(rw_cadast_edital.dtfim_grupo,'DD/MM/RRRR'),         pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'edital',  pr_posicao => vr_contador, pr_tag_nova => 'flgativo',            pr_tag_cont => vr_flgativo,                                                pr_des_erro => vr_dscritic);

        vr_contador:= vr_contador + 1;
            
      end if;
        
      --Diminuir registros
      vr_nrregist:= nvl(vr_nrregist,0) - 1;
        
    end loop;

    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml       
                             ,pr_tag   => 'dados'         
                             ,pr_atrib => 'qtregist'      
                             ,pr_atval => vr_qtregist     
                             ,pr_numva => 0               
                             ,pr_des_erro => vr_dscritic);
                                   
    -- Se ocorreu erro
    if trim(vr_dscritic) is not null then
      raise vr_exc_saida;
    end if;
                 
    pr_des_erro := 'OK';
      
  exception
    
    when vr_exc_saida then

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
      pr_dscritic := 'Erro geral na rotina da tela TELA_CADGRP.pc_exercicio_mostra_param: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      rollback;
        
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper);

  end pc_exercicio_mostra_param;

  procedure pc_exercicio_inserir_edital (pr_nrano_exercicio     in varchar2
                                        ,pr_dtinicio_grupo      in varchar2
                                        ,pr_dtfim_grupo         in varchar2
                                        ,pr_xmllog              in varchar2
                                        ,pr_cdcritic           out pls_integer
                                        ,pr_dscritic           out varchar2
                                        ,pr_retxml          in out nocopy XMLType
                                        ,pr_nmdcampo           out varchar2    
                                        ,pr_des_erro           out varchar2) is

  ---------------------------------------------------------------------------
  --
  --  Programa : pc_exercicio_inserir_edital
  --  Sistema  : Ayllos Web
  --  Autor    : Gabriel Marcos
  --  Data     : Agosto/2018                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Insere informacoes do edital para o ano de exercicio (Opcao E).
  --             
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

  begin
    
    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'CADGRP'
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
      raise vr_exc_saida;
    end if;
              
    begin
      
      --Pega a data do registro
      vr_nrano_exercicio := to_date(pr_nrano_exercicio,'RRRR');

    exception
      
      when others then

        --Monta mensagem de critica
        vr_dscritic := 'Data inválida.';
        pr_nmdcampo := 'nrano_exercicio';
        raise vr_exc_saida;
      
    end;
      
    begin
      
      --Pega a data do registro
      vr_dtinicio_grupo := to_date(pr_dtinicio_grupo,'DD/MM/RRRR');

    exception
      
      when others then

        --Monta mensagem de critica
        vr_dscritic := 'Data inválida.';
        pr_nmdcampo := 'dtinicio_grupo';
        raise vr_exc_saida;
      
    end;
      
    begin
      
      --Pega a data do registro
      vr_dtfim_grupo := to_date(pr_dtfim_grupo,'DD/MM/RRRR');

    exception
    
      when others then

        --Monta mensagem de critica
        vr_dscritic := 'Data inválida.';
        pr_nmdcampo := 'dtfim_grupo';
        raise vr_exc_saida;
      
    end;
    
    -- Validacoes com parametros recebidos
    if vr_nrano_exercicio     is null or
       vr_dtinicio_grupo      is null or
       vr_dtfim_grupo         is null then
         
      vr_dscritic := 'Todos os campos devem ser preenchidos.';
      raise vr_exc_saida;
        
    elsif vr_dtfim_grupo < vr_dtinicio_grupo THEN
        
      vr_dscritic := 'A data de inicio de travamento de grupos ' ||
                     'deve ser menor que a data final.';
      raise vr_exc_saida;
        
    end if;  
      
    begin

      insert into tbevento_exercicio (cdcooper
                                     ,nrano_exercicio 
                                     ,dtinicio_grupo   
                                     ,dtfim_grupo 
                                     ,cdoperad_altera
                                     ,dhalteracao
                                     ,flgativo)
                              values (vr_cdcooper
                                     ,trunc(vr_nrano_exercicio,'RRRR')
                                     ,vr_dtinicio_grupo   
                                     ,vr_dtfim_grupo 
                                     ,vr_cdoperad
                                     ,sysdate
                                     ,0);

      -- Verifica operacoes realizadas anteriormente
      if sql%rowcount = 0 then
        raise vr_exc_saida;
      end if;
                                              
    exception
      
      when dup_val_on_index then
        
        vr_dscritic := 'Não é permitido o cadastro de dois registros '    ||
                       'para o mesmo ano de exercício.'; --PK da tabela.
        raise vr_exc_saida;
          
      when others then

        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao atualizar período: ' || sqlerrm;
        raise vr_exc_saida;

    end;

    -- Gera log
    btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_nmarqlog     => 'cadgrp.log'
                              ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                  ' -->  Operador '|| vr_cdoperad || ' - ' ||
                                                  'Efetuou a inclusao do periodo de edital de assembleias.' || 
                                                  ' Exercicio: ' || to_char(vr_nrano_exercicio,'RRRR') ||
                                                  ', Travamento de grupos com inicio de: ' || to_char(vr_dtinicio_grupo,'DD/MM/RRRR') || 
                                                  ', Travamento de grupos com fim de: ' || to_char(vr_dtfim_grupo,'DD/MM/RRRR') ||  
                                                  '.');
                                                    
    --Realiza commit das alterações
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
      pr_dscritic := 'Erro geral na rotina da tela TELA_CADGRP.pc_exercicio_inserir_edital: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      rollback;
        
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper);  

  end pc_exercicio_inserir_edital;

  procedure pc_exercicio_alterar_edital (pr_rowid               in rowid
                                        ,pr_dtinicio_grupo      in varchar2
                                        ,pr_dtfim_grupo         in varchar2
                                        ,pr_xmllog              in varchar2
                                        ,pr_cdcritic           out pls_integer
                                        ,pr_dscritic           out varchar2
                                        ,pr_retxml          in out nocopy XMLType
                                        ,pr_nmdcampo           out varchar2    
                                        ,pr_des_erro           out varchar2) is

  ---------------------------------------------------------------------------
  --
  --  Programa : pc_exercicio_alterar_edital
  --  Sistema  : Ayllos Web
  --  Autor    : Gabriel Marcos
  --  Data     : Agosto/2018                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Altera informacoes do edital para o ano de exercicio (Opcao E).
  --             
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

    -- Buscar parametros do rowid
    cursor cr_busca_edital_rowid (pr_rowid in rowid) is
    select edi.nrano_exercicio
         , edi.dtinicio_grupo
         , edi.dtfim_grupo
      from tbevento_exercicio edi
     where edi.rowid = pr_rowid;
    rw_busca_edital_rowid cr_busca_edital_rowid%rowtype;

  begin
        
    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'CADGRP'
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
      raise vr_exc_saida;
    end if;
 
    begin
      
      --Pega a data do registro
      vr_dtinicio_grupo := to_date(pr_dtinicio_grupo,'DD/MM/RRRR');

    exception
      
      when others then

        --Monta mensagem de critica
        vr_dscritic := 'Data inválida.';
        pr_nmdcampo := 'dtinicio_grupo';
        raise vr_exc_saida;
      
    end;
      
    begin
      
      --Pega a data do registro
      vr_dtfim_grupo := to_date(pr_dtfim_grupo,'DD/MM/RRRR');

    exception
      
      when others then

        --Monta mensagem de critica
        vr_dscritic := 'Data inválida.';
        pr_nmdcampo := 'dtfim_grupo';
        raise vr_exc_saida;
      
    end;
    
    -- Validacoes dos parametros recebidos
    if vr_dtinicio_grupo      is null or
       vr_dtfim_grupo         is null then
      vr_dscritic := 'Todos os campos devem ser preenchidos.';
      raise vr_exc_saida;
    elsif vr_dtfim_grupo < vr_dtinicio_grupo then
      vr_dscritic := 'A data de inicio de travamento de grupos ' ||
                     'deve ser menor que a data final.';
      raise vr_exc_saida;
    end if;  
        
    -- Busca parametros e valida rowid
    open cr_busca_edital_rowid (pr_rowid);
    fetch cr_busca_edital_rowid into rw_busca_edital_rowid;

    -- Aborta caso nao retorne informacoes
    if cr_busca_edital_rowid%notfound then
      
      close cr_busca_edital_rowid;
      vr_dscritic := 'Registro não encontrado.';
      raise vr_exc_saida;

    end if;
   
    close cr_busca_edital_rowid;
        
    -- Compara o que quer se cadastrar com o que ja esta cadastrado
    if vr_dtinicio_grupo      = rw_busca_edital_rowid.dtinicio_grupo      and
       vr_dtfim_grupo         = rw_busca_edital_rowid.dtfim_grupo         then
      vr_dscritic := 'Parâmetros devem ser diferentes dos já registrados.';
      raise vr_exc_saida;
    end if;
   
    begin

     update tbevento_exercicio c
        set c.dtinicio_grupo      = vr_dtinicio_grupo
           ,c.dtfim_grupo         = vr_dtfim_grupo
           ,c.cdoperad_altera     = vr_cdoperad
           ,c.dhalteracao         = sysdate
      where c.cdcooper            = vr_cdcooper
        and c.rowid               = pr_rowid;

      -- Verifica operacoes realizadas anteriormente
      if sql%rowcount = 0 then
        raise vr_exc_saida;
      end if;
        
    exception
      
      when others then
        
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao atualizar período: ' || sqlerrm;
        raise vr_exc_saida;

    end;

    -- Gera log
    btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_nmarqlog     => 'cadgrp.log'
                              ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                  ' -->  Operador '|| vr_cdoperad || ' - ' ||
                                                  'Efetuou a alteracao do periodo de edital de assembleias.' || 
                                                  ' Exercicio: ' || to_char(rw_busca_edital_rowid.nrano_exercicio,'RRRR') ||
                                                  ', Travamento de grupos com inicio de ' || to_char(rw_busca_edital_rowid.dtinicio_grupo,'DD/MM/RRRR') || ' para ' || to_char(vr_dtinicio_grupo,'DD/MM/RRRR') || 
                                                  ', Travamento de grupos com fim de  ' || to_char(rw_busca_edital_rowid.dtfim_grupo,'DD/MM/RRRR') || ' para ' || to_char(vr_dtfim_grupo,'DD/MM/RRRR') ||  
                                                  '.');

    --Realiza commit das alterações
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
      pr_dscritic := 'Erro geral na rotina da tela TELA_CADGRP.pc_exercicio_alterar_edital: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      rollback;
        
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper);
       
  end pc_exercicio_alterar_edital;
      
  procedure pc_exercicio_excluir_edital (pr_nrano_exercicio in varchar2
                                        ,pr_rowid           in rowid
                                        ,pr_xmllog          in varchar2
                                        ,pr_cdcritic       out pls_integer
                                        ,pr_dscritic       out varchar2
                                        ,pr_retxml      in out nocopy XMLType
                                        ,pr_nmdcampo       out varchar2    
                                        ,pr_des_erro       out varchar2) is

  ---------------------------------------------------------------------------
  --
  --  Programa : pc_exercicio_excluir_edital
  --  Sistema  : Ayllos Web
  --  Autor    : Gabriel Marcos
  --  Data     : Agosto/2018                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Exclui informacoes do edital para o ano de exercicio (Opcao E).
  --             
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------
 
    -- Buscar dado para data de fim de vigencia
    cursor cr_crapdat (pr_cdcooper crapdat.cdcooper%type) is
    select to_char(dat.dtmvtolt,'RRRR') dtmvtolt
      from crapdat dat
     where dat.cdcooper = pr_cdcooper;
    rw_crapdat cr_crapdat%rowtype;
    
    -- Buscar parametros do rowid
    cursor cr_busca_edital_rowid (pr_rowid in rowid) is
    select edi.nrano_exercicio
         , edi.dtinicio_grupo
         , edi.dtfim_grupo
      from tbevento_exercicio edi
     where edi.rowid = pr_rowid;
    rw_busca_edital_rowid cr_busca_edital_rowid%rowtype;

  begin
      
    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'CADGRP'
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
      raise vr_exc_saida;
    end if;

    if trim(pr_nrano_exercicio) is null then

      --Monta mensagem de critica
      vr_dscritic := 'Exercício inválido.';
      raise vr_exc_saida;
            
    end if;
    
    -- Busca data de movimentacao
    open cr_crapdat (vr_cdcooper);
    fetch cr_crapdat into rw_crapdat;
    
    -- Aborta se nao encontrar
    if cr_crapdat%notfound then
      
      close cr_crapdat;
      vr_dscritic := 'Data da cooperativa não cadastrada.';
      raise vr_exc_saida;

    end if;
    
    close cr_crapdat;

    -- Valida o ano que esta sendo excluido
    if pr_nrano_exercicio = rw_crapdat.dtmvtolt then
      vr_dscritic := 'Não é permitido que o ano corrente fique sem ' ||
                     'um ano de exercício cadastrado.';
      raise vr_exc_saida;
    end if;
    
    -- Valida se rowid e valido
    open cr_busca_edital_rowid (pr_rowid);
    fetch cr_busca_edital_rowid into rw_busca_edital_rowid;
    
    -- Caso nao encontre aborta
    if cr_busca_edital_rowid%notfound then
     
      vr_dscritic := 'Registro não encontrado.';
      raise vr_exc_saida;
      close cr_busca_edital_rowid;
      
    end if;
    
    close cr_busca_edital_rowid;
      
    begin

       delete 
         from tbevento_exercicio c
        where c.cdcooper = vr_cdcooper
          and c.rowid    = pr_rowid;
          
      -- Valida operacoes anteriores
      if sql%rowcount = 0 then
        raise vr_exc_saida;
      end if;
           
    exception 
      
      when others then
        
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao excluir período: ' || sqlerrm;
        raise vr_exc_saida;

    end;

    -- Gera log
    btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_nmarqlog     => 'cadgrp.log'
                              ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                  ' -->  Operador '|| vr_cdoperad || ' - ' ||
                                                  'Efetuou a exclusao do periodo de edital de assembleias.' || 
                                                  ' Exercicio: ' || pr_nrano_exercicio ||'.');

    --Realiza commit das alterações
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
      pr_dscritic := 'Erro geral na rotina da tela TELA_CADGRP.pc_exercicio_excluir_edital: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      rollback;
        
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper);

  end pc_exercicio_excluir_edital;
      
  procedure pc_exercicio_ativar_edital (pr_rowid      in rowid
                                       ,pr_xmllog     in varchar2
                                       ,pr_cdcritic  out pls_integer
                                       ,pr_dscritic  out varchar2
                                       ,pr_retxml in out nocopy XMLType
                                       ,pr_nmdcampo  out varchar2    
                                       ,pr_des_erro  out varchar2) is

  ---------------------------------------------------------------------------
  --
  --  Programa : pc_exercicio_ativar_edital
  --  Sistema  : Ayllos Web
  --  Autor    : Gabriel Marcos
  --  Data     : Agosto/2018                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Ativar edital para o registro selecionado (Opcao E).
  --             
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

    -- Buscar parametros do rowid
    cursor cr_busca_edital_rowid (pr_rowid in rowid) is
    select edi.nrano_exercicio
         , edi.dtinicio_grupo
         , edi.dtfim_grupo
      from tbevento_exercicio edi
     where edi.rowid = pr_rowid;
    rw_busca_edital_rowid cr_busca_edital_rowid%rowtype;

  begin
      
    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'CADGRP'
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
      raise vr_exc_saida;
    end if;
    
    -- Valida se rowid e valido
    open cr_busca_edital_rowid (pr_rowid);
    fetch cr_busca_edital_rowid into rw_busca_edital_rowid;
    
    -- Caso nao encontre aborta
    if cr_busca_edital_rowid%notfound then
     
      vr_dscritic := 'Registro não encontrado.';
      raise vr_exc_saida;
      close cr_busca_edital_rowid;
      
    end if;
    
    close cr_busca_edital_rowid;
      
    begin
      
       update tbevento_exercicio c
          set c.flgativo = 0
        where c.cdcooper = vr_cdcooper
          and c.flgativo = 1;

       update tbevento_exercicio c
          set c.flgativo = 1
        where c.cdcooper = vr_cdcooper
          and c.rowid    = pr_rowid;
          
      -- Valida operacoes anteriores
      if sql%rowcount = 0 then
        raise vr_exc_saida;
      end if; 
          
    exception 
      
      when others then
        
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao ativar período: ' || sqlerrm;
        raise vr_exc_saida;

    end;

    -- Gera log
    btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_nmarqlog     => 'cadgrp.log'
                              ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                  ' -->  Operador '|| vr_cdoperad || ' - ' ||
                                                  'Efetuou a ativacao do periodo de edital de assembleias.' || 
                                                  ' Exercicio: ' || rw_busca_edital_rowid.nrano_exercicio ||'.');

    --Realiza commit das alterações
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
      pr_dscritic := 'Erro geral na rotina da tela TELA_CADGRP.pc_exercicio_ativar_edital: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      rollback;
        
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper);

  end pc_exercicio_ativar_edital;

  procedure pc_cursor_opcao_c (pr_cdagenci   in tbevento_pessoa_grupos.cdagenci%type
                              ,pr_nrdgrupo   in tbevento_pessoa_grupos.nrdgrupo%type
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
  --  Programa : pc_cursor_opcao_c
  --  Sistema  : Ayllos Web
  --  Autor    : Gabriel Marcos
  --  Data     : Agosto/2018                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Apresenta informacoes do grupo para a agencia (Opcao C).
  --             Tambem utilizado para exportar infos em csv
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------
        
    -- Buscar cooperados para apresentar na opcao c
    cursor cr_busca_cooperados (pr_cdcooper in tbevento_pessoa_grupos.cdcooper%type
                               ,pr_cdagenci in tbevento_pessoa_grupos.cdagenci%type
                               ,pr_nrdgrupo in tbevento_pessoa_grupos.nrdgrupo%type) is
    select distinct
           pes.dsfuncao
         , gru.nrdconta
         , gru.nrcpfcgc
         , gru.nrdgrupo
         , ass.nmprimtl
         , ass.inpessoa
         , case pes.cdfuncao when 'CD' then 6
                             when 'DT' then 5
                             when 'DS' then 4
                             when 'CL' then 3
                             when 'CS' then 2
                             when 'CM' then 1
                             else 0 end ordenado
      from tbevento_pessoa_grupos gru
         , crapass                ass
         , tbcadast_funcao_pessoa pes
     where gru.cdcooper = pr_cdcooper
       and gru.cdagenci = pr_cdagenci
       and gru.nrdgrupo = decode(pr_nrdgrupo,0,gru.nrdgrupo,pr_nrdgrupo)
       and ass.cdcooper = gru.cdcooper
       and ass.nrdconta = gru.nrdconta
       and pes.cdfuncao = decode(length(trim(ass.tpvincul)),2,ass.tpvincul,' ')
     order
        by ordenado desc
         --, gru.cdagenci
         , ass.nmprimtl;
           
  begin

    --Inicializar Variaveis
    vr_nrregist:= pr_nrregist;
      
    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'CADGRP'
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

    -- Retorna critica em caso de erro
    if trim(vr_dscritic) is not null then
      raise vr_exc_saida;
    end if;

    -- Verifica se foram passados parametros
    if nvl(pr_cdagenci,0) = 0 then
      vr_dscritic := 'Informe a Agência desejada.'; 
      pr_nmdcampo := 'cdagenci';
      raise vr_exc_saida;
    end if;
    
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root',  pr_posicao => 0, pr_tag_nova => 'Dados',  pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'listas', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
       
    -- Loop principal de retorno de dados
    for rw_busca_cooperados in cr_busca_cooperados(vr_cdcooper
                                                  ,pr_cdagenci
                                                  ,nvl(pr_nrdgrupo,0)) loop                                                  
       
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
          
        -- Popula as informacoes via XML
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'listas', pr_posicao => 0, pr_tag_nova => 'lista', pr_tag_cont => null, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'lista',  pr_posicao => vr_contador, pr_tag_nova => 'dsfuncao', pr_tag_cont => rw_busca_cooperados.dsfuncao, pr_des_erro => vr_dscritic); 
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'lista',  pr_posicao => vr_contador, pr_tag_nova => 'nrdconta', pr_tag_cont => TRIM(gene0002.fn_mask_conta(rw_busca_cooperados.nrdconta)), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'lista',  pr_posicao => vr_contador, pr_tag_nova => 'nrcpfcgc', pr_tag_cont => gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_busca_cooperados.nrcpfcgc,
                                                                                                                                                                           pr_inpessoa => rw_busca_cooperados.inpessoa), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'lista',  pr_posicao => vr_contador, pr_tag_nova => 'nmprimtl', pr_tag_cont => rw_busca_cooperados.nmprimtl, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'lista',  pr_posicao => vr_contador, pr_tag_nova => 'nrdgrupo', pr_tag_cont => rw_busca_cooperados.nrdgrupo, pr_des_erro => vr_dscritic);
        vr_contador := vr_contador + 1;
        
      end if;
        
    end loop; 
      
    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml 
                             ,pr_tag   => 'Dados'             
                             ,pr_atrib => 'qtregist'       
                             ,pr_atval => vr_qtregist        
                             ,pr_numva => 0                  
                             ,pr_des_erro => vr_dscritic);  
                                   
    --Se ocorreu erro
    if trim(vr_dscritic) is not null then
      raise vr_exc_saida;
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
      pr_dscritic := 'Erro geral na rotina da tela TELA_CADGRP.pc_cursor_opcao_c: ' || sqlerrm;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      rollback;
        
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper);

  end pc_cursor_opcao_c;

  procedure pc_cursor_opcao_b (pr_nrdconta   in crapass.nrdconta%type
                              ,pr_nrcpfcgc   in crapass.nrcpfcgc%type
                              ,pr_xmllog     in varchar2
                              ,pr_cdcritic  out pls_integer
                              ,pr_dscritic  out varchar2
                              ,pr_retxml in out nocopy XMLType
                              ,pr_nmdcampo  out varchar2    
                              ,pr_des_erro  out varchar2) is

  ---------------------------------------------------------------------------
  --
  --  Programa : pc_cursor_opcao_b
  --  Sistema  : Ayllos Web
  --  Autor    : Gabriel Marcos
  --  Data     : Agosto/2018                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Apresenta informacoes do cooperado (Opcao B).
  --            
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------
        
    -- Buscar cpf / cnpj do cooperado
    cursor cr_crapass_nrdconta (pr_cdcooper in crapass.cdcooper%type
                               ,pr_nrdconta in crapass.nrdconta%type) is
    select ass.cdagenci
         , ass.nrcpfcgc
         , ass.nrdconta
         , ass.dtelimin
         , ass.cdsitdct
         , ass.tpvincul
         , ass.inpessoa
      from crapass ass
     where ass.cdcooper = pr_cdcooper
       and ass.nrdconta = pr_nrdconta;
       
    -- Buscar cpf / cnpj do cooperado
    cursor cr_crapass_nrcpfcgc (pr_cdcooper in crapass.cdcooper%type
                               ,pr_nrcpfcgc in crapass.nrcpfcgc%type) is
    select ass.cdagenci
         , ass.nrcpfcgc
         , ass.nrdconta
         , ass.dtelimin
         , ass.cdsitdct
         , ass.tpvincul
         , ass.inpessoa
      from crapass ass
     where ass.cdcooper = pr_cdcooper
       and ass.nrcpfcgc = pr_nrcpfcgc
       and ass.dtdemiss is null;
    rw_crapass cr_crapass_nrdconta%rowtype;
         
    -- Busca dados do cooperado com conta ou cpf/cnpj.
    cursor cr_grupo_assembleia (pr_cdcooper in crapass.cdcooper%type
                               ,pr_nrcpfcgc in crapass.nrcpfcgc%type) is
    select distinct
           gru.cdagenci
         , gru.nrdgrupo
         , pes.dsfuncao
         , gru.nrdconta
         , gru.nrcpfcgc
         , ass.nmprimtl
         , gru.rowid
      from crapass ass
         , tbevento_pessoa_grupos gru
         , tbcadast_funcao_pessoa pes
     where gru.cdcooper = pr_cdcooper
       and gru.nrcpfcgc = pr_nrcpfcgc
       and ass.cdcooper = gru.cdcooper
       and ass.nrcpfcgc = gru.nrcpfcgc
       and pes.cdfuncao = ass.tpvincul;
    rw_grupo_assembleia cr_grupo_assembleia%rowtype;

    vr_nrcpfcgc crapass.nrcpfcgc%type;      
        
  begin
        
    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'CADGRP'
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

    -- Aborta se houver retorno de critica
    if trim(vr_dscritic) is not null then
      raise vr_exc_saida;
    end if;
        
    -- Verifica se foram passados parametros
    if nvl(pr_nrdconta,0) = 0 and nvl(pr_nrcpfcgc,0) = 0 then
      vr_dscritic := 'Informe a Conta e ou CPF / CPNJ do cooperado.';
      pr_nmdcampo := 'nrdconta';
      raise vr_exc_saida;
    end if;

    -- Faz validacoes com cpf / cnpj passado
    if nvl(pr_nrcpfcgc,0) <> 0 then

      -- Buscar cooperado
      open cr_crapass_nrcpfcgc (vr_cdcooper
                               ,pr_nrcpfcgc);                
      fetch cr_crapass_nrcpfcgc into rw_crapass;
          
      -- Se nao encontrou retorna critica
      if cr_crapass_nrcpfcgc%notfound THEN
        close cr_crapass_nrcpfcgc;
        vr_cdcritic := 9;
        pr_nmdcampo := 'nrcpfcgc';
        raise vr_exc_saida;
      end if;
        
      close cr_crapass_nrcpfcgc;      
       
      vr_nrcpfcgc := rw_crapass.nrcpfcgc;

    -- Faz validacoes com conta passada
    elsif nvl(pr_nrdconta,0) <> 0 then
        
      -- Buscar cooperado
      open cr_crapass_nrdconta (vr_cdcooper
                               ,pr_nrdconta);                   
      fetch cr_crapass_nrdconta into rw_crapass;
          
      -- Se nao encontrou retorna critica
      if cr_crapass_nrdconta%notfound THEN
        close cr_crapass_nrdconta;
        vr_cdcritic := 9;
        pr_nmdcampo := 'nrdconta';
        raise vr_exc_saida;
      end if;

      close cr_crapass_nrdconta;
          
      -- Verifica se conta esta ativa
      if rw_crapass.dtelimin is not null then
        vr_cdcritic := 410;
        pr_nmdcampo := 'nrdconta';
        raise vr_exc_saida;
      end if;      
          
      vr_nrcpfcgc := rw_crapass.nrcpfcgc;
      
    end if;

    -- Buscar cooperado com nrcpfcgc da rotina
    open cr_grupo_assembleia (vr_cdcooper
                             ,vr_nrcpfcgc);                       
    fetch cr_grupo_assembleia into rw_grupo_assembleia;
        
    -- Se nao encontrou retorna critica
    if cr_grupo_assembleia%notfound then
      close cr_grupo_assembleia;
      pr_nmdcampo := 'nrdconta';
      vr_dscritic := 'Cooperado não encontrado em nenhum dos grupos.';
      raise vr_exc_saida;
    end if;

    close cr_grupo_assembleia;

    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root', pr_posicao => 0, pr_tag_nova => 'Dados', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados',      pr_posicao => 0, pr_tag_nova => 'cooperado', pr_tag_cont => NULL,                pr_des_erro => vr_dscritic); 
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'cooperado',  pr_posicao => 0, pr_tag_nova => 'rowid',     pr_tag_cont => rw_grupo_assembleia.rowid,    pr_des_erro => vr_dscritic); 
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'cooperado',  pr_posicao => 0, pr_tag_nova => 'cdagenci',  pr_tag_cont => rw_grupo_assembleia.cdagenci, pr_des_erro => vr_dscritic); 
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'cooperado',  pr_posicao => 0, pr_tag_nova => 'nrdgrupo',  pr_tag_cont => rw_grupo_assembleia.nrdgrupo, pr_des_erro => vr_dscritic); 
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'cooperado',  pr_posicao => 0, pr_tag_nova => 'dsfuncao',  pr_tag_cont => rw_grupo_assembleia.dsfuncao, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'cooperado',  pr_posicao => 0, pr_tag_nova => 'nrdconta',  pr_tag_cont => trim(gene0002.fn_mask_conta(rw_grupo_assembleia.nrdconta)), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'cooperado',  pr_posicao => 0, pr_tag_nova => 'nrcpfcgc',  pr_tag_cont => gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapass.nrcpfcgc,
                                                                                                                                                                  pr_inpessoa => rw_crapass.inpessoa), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'cooperado',  pr_posicao => 0, pr_tag_nova => 'nmprimtl',  pr_tag_cont => rw_grupo_assembleia.nmprimtl, pr_des_erro => vr_dscritic);

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
      pr_dscritic := 'Erro geral na rotina da tela TELA_CADGRP.pc_cursor_opcao_b: ' || sqlerrm;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      rollback;
        
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper);

  end pc_cursor_opcao_b;

  procedure pc_alterar_opcao_b (pr_nrdgrupo   in tbevento_pessoa_grupos.nrdgrupo%type
                               ,pr_rowid      in rowid
                               ,pr_xmllog     in varchar2
                               ,pr_cdcritic  out pls_integer
                               ,pr_dscritic  out varchar2
                               ,pr_retxml in out nocopy XMLType
                               ,pr_nmdcampo  out varchar2    
                               ,pr_des_erro  out varchar2) is

  ---------------------------------------------------------------------------
  --
  --  Programa : pc_alterar_opcao_b
  --  Sistema  : Ayllos Web
  --  Autor    : Gabriel Marcos
  --  Data     : Agosto/2018                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Altera grupo do cooperado atraves (Opcao B).
  --            
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------
    
    -- Garante que delegados e comites estejam vinculados ao seu grupo
    cursor cr_verifica_cargo (pr_cdcooper in crapass.cdcooper%type
                             ,pr_nrcpfcgc in crapass.nrcpfcgc%type) is
    select sum(decode(vig.cdfuncao,'DT',1,'DS',1,0)) delegado
      from tbcadast_vig_funcao_pessoa vig
     where vig.cdcooper = pr_cdcooper
       and vig.nrcpfcgc = pr_nrcpfcgc
       and vig.dtfim_vigencia is null;
    rw_verifica_cargo cr_verifica_cargo%rowtype;

    -- Busca dados do cooperado com conta ou cpf/cnpj.
    cursor cr_grupo_assembleia (pr_rowid in rowid) is
    select gru.nrdgrupo
         , gru.cdagenci  
         , ass.nrdconta       
         , ass.nmprimtl
         , ass.nrcpfcgc
         , gru.idpessoa
      from crapass                ass
         , tbevento_pessoa_grupos gru
     where gru.rowid = pr_rowid
       and ass.cdcooper = gru.cdcooper
       and ass.nrcpfcgc = gru.nrcpfcgc;
    rw_grupo_assembleia cr_grupo_assembleia%rowtype;
      
    -- Buscar grupos
    cursor cr_buscar_grupos (pr_cdcooper in tbevento_pessoa_grupos.cdcooper%type
                            ,pr_cdagenci in tbevento_pessoa_grupos.cdagenci%type
                            ,pr_nrdgrupo in tbevento_pessoa_grupos.nrdgrupo%type) is
    select gru.nrdgrupo
      from tbevento_pessoa_grupos gru
     where gru.cdcooper = pr_cdcooper
       and gru.cdagenci = pr_cdagenci
       and gru.nrdgrupo = pr_nrdgrupo;    
    rw_buscar_grupos cr_buscar_grupos%rowtype;
      
    vr_nrdrowid rowid;
      
  begin

    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'CADGRP'
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
      raise vr_exc_saida;
    end if;
    
    -- Validacoes de parametros
    if nvl(pr_nrdgrupo,0) = 0 then
      vr_dscritic := 'Grupo inválido.';      
      raise vr_exc_saida;
    end if;

    -- Buscar cooperado validando rowid
    open cr_grupo_assembleia (pr_rowid);                    
    fetch cr_grupo_assembleia into rw_grupo_assembleia;
        
    -- Se nao encontrou retorna critica
    if cr_grupo_assembleia%notfound then
      close cr_grupo_assembleia;
      vr_dscritic := 'Cooperado não encontrado em nenhum dos grupos.';
      raise vr_exc_saida;
    end if;

    close cr_grupo_assembleia;

    -- Busca grupos disponiveis
    open cr_buscar_grupos (pr_cdcooper => vr_cdcooper
                          ,pr_cdagenci => rw_grupo_assembleia.cdagenci
                          ,pr_nrdgrupo => pr_nrdgrupo);                 
    fetch cr_buscar_grupos into rw_buscar_grupos;
      
    -- Se nao encontrar grupo do parametro
    -- aborta operacao de alteracao
    if cr_buscar_grupos%notfound then
      
      close cr_buscar_grupos;
      vr_dscritic := 'Grupo não disponível.';      
      raise vr_exc_saida;
      
    end if;
    
    close cr_buscar_grupos;

    -- Validacoes para o cargo de delegado
    open cr_verifica_cargo (vr_cdcooper
                           ,rw_grupo_assembleia.nrcpfcgc);                
    fetch cr_verifica_cargo into rw_verifica_cargo;
    close cr_verifica_cargo;
        
    -- Se cooperado for delegado deve abortar
    if rw_verifica_cargo.delegado > 0 THEN
        
      vr_dscritic := 'Cooperado não pode mudar de grupo com cargo ' ||
                     'de Delegado ativo.';     
      raise vr_exc_saida;
        
    end if;
       
    begin

      -- Altera grupo do cooperado
      update tbevento_pessoa_grupos c
         set c.nrdgrupo        = pr_nrdgrupo
           , c.cdoperad_altera = vr_cdoperad
           , c.dhalteracao     = sysdate
       where c.cdcooper        = vr_cdcooper
         and c.rowid           = pr_rowid;

      -- Diminui qtd membros do grupo antigo
      update tbevento_grupos
         set qtd_membros = qtd_membros - 1
       where cdcooper    = vr_cdcooper
         and cdagenci    = rw_grupo_assembleia.cdagenci
         and nrdgrupo    = rw_grupo_assembleia.nrdgrupo;
         
      -- Aumenta qtd membros do grupo novo
      update tbevento_grupos
         set qtd_membros = qtd_membros + 1
       where cdcooper    = vr_cdcooper
         and cdagenci    = rw_grupo_assembleia.cdagenci
         and nrdgrupo    = pr_nrdgrupo;
         
      -- Efetivar alteracoes anteriores mantendo somente ultima
      update tbhistor_pessoa_grupos
         set tpsituacao = 3
       where cdcooper   = vr_cdcooper
         and nrdconta   = rw_grupo_assembleia.nrdconta
         and tpsituacao = 0;
         
      -- Gerar informacao de alteracao ao SOA
      insert 
        into tbhistor_pessoa_grupos (cdcooper
                                    ,idpessoa
                                    ,nrdconta
                                    ,dhalteracao
                                    ,tpsituacao
                                    ,dhcomunicacao
                                    ,dserro
                                    ,qttentativa
                                    ,nrdgrupo)
      values                        (vr_cdcooper
                                    ,rw_grupo_assembleia.idpessoa
                                    ,rw_grupo_assembleia.nrdconta
                                    ,sysdate
                                    ,0
                                    ,null
                                    ,null
                                    ,null
                                    ,pr_nrdgrupo);
         
      if sql%rowcount = 0 then
        raise vr_exc_saida;
      end if;

    exception
        
      when others then
        
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao atualizar grupo: ' || sqlerrm;
        raise vr_exc_saida;

    end;

    gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                        ,pr_cdoperad => vr_cdoperad
                        ,pr_dscritic => null
                        ,pr_dsorigem => gene0001.vr_vet_des_origens(vr_idorigem)
                        ,pr_dstransa => 'Mudança de grupo - Antigo: '  ||
                                        rw_grupo_assembleia.nrdgrupo||
                                        ' Novo: '||pr_nrdgrupo
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1
                        ,pr_hrtransa => gene0002.fn_busca_time
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => 'CADGRP'
                        ,pr_nrdconta => rw_grupo_assembleia.nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);

    -- Gera log
    btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_nmarqlog     => 'cadgrp.log'
                              ,pr_des_log      => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss') ||
                                                  ' -->  Operador '|| vr_cdoperad || ' - ' ||
                                                  'Efetuou a alteracao de grupo para o cooperado' || 
                                                  ' Conta: ' || trim(gene0002.fn_mask_conta(rw_grupo_assembleia.nrdconta)) ||
                                                  ', Grupo de ' || to_char(rw_grupo_assembleia.nrdgrupo,'999') || ' para ' || to_char(pr_nrdgrupo,'999') ||
                                                  '.');

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
      pr_dscritic := 'Erro geral na rotina da tela TELA_CADGRP.pc_alterar_opcao_b: ' || sqlerrm;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      rollback;
        
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper);
       
  end pc_alterar_opcao_b;
      
  procedure pc_grupo_disponivel(pr_nrdgrupo   in tbevento_pessoa_grupos.nrdgrupo%type 
                               ,pr_cdagenci   in tbevento_pessoa_grupos.cdagenci%type 
                               ,pr_nrregist   in integer                                 
                               ,pr_nriniseq   in integer              
                               ,pr_xmllog     in varchar2             
                               ,pr_cdcritic  out pls_integer         
                               ,pr_dscritic  out varchar2            
                               ,pr_retxml in out nocopy XMLType   
                               ,pr_nmdcampo  out varchar2            
                               ,pr_des_erro  out varchar2) is
    
  /*---------------------------------------------------------------------------------------------------------------
  
  Programa : pc_grupo_disponivel                            antiga:  
  Sistema  : Conta-Corrente - Cooperativa de Credito
  Sigla    : CRED
  Autor    : Jonata
  Data     : Setembro/2018                           Ultima atualizacao:
      
  Dados referentes ao programa:
      
  Frequencia: -----
  Objetivo   : Pesquisa grupos disponiveis
      
  Alterações : 
  
  -------------------------------------------------------------------------------------------------------------*/     
                          
    -- Buscar grupos disponiveis
    cursor cr_buscar_grupos (pr_cdcooper in tbevento_pessoa_grupos.cdcooper%type
                            ,pr_nrdgrupo in tbevento_pessoa_grupos.nrdgrupo%type
                            ,pr_cdagenci in tbevento_pessoa_grupos.cdagenci%type) is
    select  gru.nrdgrupo
      from  tbevento_grupos gru
     where  gru.cdcooper = pr_cdcooper
       and  gru.cdagenci = pr_cdagenci
       and (pr_nrdgrupo = 0 
        or  gru.nrdgrupo = pr_nrdgrupo);  

  begin
        
    --Inicializar Variaveis
    vr_nrregist := pr_nrregist;
    vr_cdcritic := 0;
    vr_dscritic := null;
        
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
    if trim(vr_dscritic) is not null then
      raise vr_exc_saida;
    end if;   
      
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root', pr_posicao => 0, pr_tag_nova => 'grupos', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    -- Loop para alimentar XML
    for rw_buscar_grupos in cr_buscar_grupos(pr_cdcooper => vr_cdcooper
                                            ,pr_nrdgrupo => pr_nrdgrupo
                                            ,pr_cdagenci => pr_cdagenci) loop      
        
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
                      
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'grupos', pr_posicao => 0, pr_tag_nova => 'grupo', pr_tag_cont => NULL, pr_des_erro => vr_dscritic); 
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'grupo', pr_posicao => vr_contador, pr_tag_nova => 'nrdgrupo', pr_tag_cont => rw_buscar_grupos.nrdgrupo, pr_des_erro => vr_dscritic);
          
        vr_contador := vr_contador + 1;
          
      end if;
          
      --Diminuir registros
      vr_nrregist:= nvl(vr_nrregist,0) - 1; 
          
    end loop;       
                     
    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml     
                             ,pr_tag   => 'grupos'      
                             ,pr_atrib => 'qtregist'    
                             ,pr_atval => vr_qtregist   
                             ,pr_numva => 0             
                             ,pr_des_erro => vr_dscritic); 
                                 
    --Se ocorreu erro
    if trim(vr_dscritic) is not null then
      raise vr_exc_saida;
    end if;  
      
    -- Retorno  OK
    pr_des_erro:= 'OK';
      
  exception
  
    when vr_exc_saida then
      
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
                                         
    when others then
      
      -- Retorno não OK
      pr_des_erro:= 'NOK';
          
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na TELA_CADGRP.pc_grupo_disponivel --> '|| sqlerrm;
          
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');   
      
  end pc_grupo_disponivel;

  procedure pc_agencia_disponivel(pr_nrregist   in integer                                   
                                 ,pr_nriniseq   in integer             
                                 ,pr_xmllog     in varchar2            
                                 ,pr_cdcritic  out pls_integer         
                                 ,pr_dscritic  out varchar2            
                                 ,pr_retxml in out nocopy XMLType      
                                 ,pr_nmdcampo  out varchar2            
                                 ,pr_des_erro  out varchar2) is
    
  /*---------------------------------------------------------------------------------------------------------------
      
  Programa : pc_agencia_disponivel                            antiga:  
  Sistema  : Conta-Corrente - Cooperativa de Credito
  Sigla    : CRED
  Autor    : Jonata
  Data     : Setembro/2018                           Ultima atualizacao:
      
  Dados referentes ao programa:
      
  Frequencia: -----
  Objetivo   : Pesquisa agencias disponiveis
      
  Alterações : 
  
  -------------------------------------------------------------------------------------------------------------*/     
                          
    -- Buscar agencias disponiveis
    cursor cr_buscar_agencias (pr_cdcooper in crapass.cdcooper%type) is
    select distinct
           gru.cdagenci
         , count(*) over (partition by gru.cdcooper) qtdregis
      from tbevento_grupos gru
     where gru.cdcooper = pr_cdcooper
     order
        by gru.cdagenci;           
      
  begin
        
    --Inicializar Variaveis
    vr_nrregist := pr_nrregist;
    vr_cdcritic := 0;
    vr_dscritic := null;
        
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
    if trim(vr_dscritic) is not null then
      raise vr_exc_saida;
    end if;   
      
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root', pr_posicao => 0, pr_tag_nova => 'agencias', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
         
    -- Loop principal para alimentar XML
    for rw_buscar_agencias in cr_buscar_agencias (pr_cdcooper => vr_cdcooper) loop      
        
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
                      
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'agencias', pr_posicao => 0, pr_tag_nova => 'agencia', pr_tag_cont => NULL, pr_des_erro => vr_dscritic); 
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'agencia', pr_posicao => vr_contador, pr_tag_nova => 'cdagenci', pr_tag_cont => rw_buscar_agencias.cdagenci, pr_des_erro => vr_dscritic);
 
        vr_contador := vr_contador + 1;
          
      end if;
          
      --Diminuir registros
      vr_nrregist:= nvl(vr_nrregist,0) - 1; 
          
    end loop;       
                     
    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml
                             ,pr_tag   => 'agencias'            
                             ,pr_atrib => 'qtregist'         
                             ,pr_atval => vr_qtregist 
                             ,pr_numva => 0                   
                             ,pr_des_erro => vr_dscritic);    
                                 
    --Se ocorreu erro
    if trim(vr_dscritic) is not null then
      raise vr_exc_saida;
    end if;  
      
    -- Retorno  OK
    pr_des_erro:= 'OK';
      
  exception
    
    when vr_exc_saida then
              
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
          
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
                                         
    when others then
      
      -- Retorno não OK
      pr_des_erro:= 'NOK';
          
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na TELA_CADGRP.pc_agencia_disponivel --> '|| sqlerrm;
          
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');   
      
  end pc_agencia_disponivel;

  procedure pc_cursor_opcao_g (pr_cdagenci   in varchar2
                              ,pr_xmllog     in varchar2
                              ,pr_cdcritic  out pls_integer
                              ,pr_dscritic  out varchar2
                              ,pr_retxml in out nocopy XMLType
                              ,pr_nmdcampo  out varchar2    
                              ,pr_des_erro  out varchar2) is

  ---------------------------------------------------------------------------
  --
  --  Programa : pc_cursor_opcao_g
  --  Sistema  : Ayllos Web
  --  Autor    : Gabriel Marcos
  --  Data     : Agosto/2018                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Apresenta informacoes da cooperativa (Opcao G).
  --             Quando parametro cdagenci for zero apresenta
  --             todas as agencias. Opcao alterar chama esta mesma
  --             procedure porem passa apenas agencias desejadas
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

    -- Busca agencias para verificacao
    cursor cr_crapage (pr_cdcooper in crapage.cdcooper%type
                      ,pr_cdagenci in crapage.cdagenci%type) is
    select age.cdcooper
         , age.cdagenci
      from crapage age
     where age.cdcooper = pr_cdcooper
       and age.insitage = 1
       and age.cdagenci = decode(pr_cdagenci,0,age.cdagenci,pr_cdagenci)
     order
        by age.cdagenci;

    -- Busca agencias do loop principal
    cursor cr_verifica_agencias (pr_cdcooper in tbevento_pessoa_grupos.cdcooper%type
                                ,pr_cdagenci in tbevento_pessoa_grupos.cdagenci%type) is
    select sum(dsc.qtd_membros) contador
         , nvl(max(dsc.nrdgrupo),0) nrdgrupo
         , decode(dsc.flgsituacao,0,'Em Andamento',1,'Sucesso',2,'Crítica','Inválido') flgsituacao
      from tbevento_grupos dsc
     where dsc.cdcooper = pr_cdcooper
       and dsc.cdagenci = pr_cdagenci
     group
        by dsc.cdcooper
         , dsc.cdagenci
         , dsc.flgsituacao
     order
        by dsc.cdagenci;
    rw_verifica_agencias cr_verifica_agencias%rowtype;
      
    -- Contabiliza delegados e comites da agencia
    cursor cr_verifica_cargo (pr_cdcooper in crapass.cdcooper%type
                             ,pr_cdagenci in crapass.cdagenci%type) is
    select sum(decode(vig.cdfuncao,'DT',1,'DS',1,0))        delegado
         , sum(decode(vig.cdfuncao,'CL',1,'CS',1,'CM',1,0)) comitedu
      from tbevento_pessoa_grupos     grp
         , tbcadast_vig_funcao_pessoa vig
     where grp.cdcooper = pr_cdcooper
       and grp.cdagenci = pr_cdagenci
       and vig.cdcooper = grp.cdcooper
       and vig.nrcpfcgc = grp.nrcpfcgc
       and vig.cdfuncao in ('DT','DS','CL','CS','CM')
       and vig.dtfim_vigencia is null;
    rw_verifica_cargo cr_verifica_cargo%rowtype;

    -- Tabela de memoria
    type typ_param_agenci is record (cdagenci crapage.cdagenci%type);
    type typ_tab_agenci is table of typ_param_agenci index by binary_integer;
    vr_tab_dados_agenci typ_tab_agenci;
    vr_tab_cdagenci gene0002.typ_split;

    vr_qtdgrupo number;
    vr_frefetiv number;
    vr_flgsituacao varchar2(100);

  begin
        
    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'CADGRP'
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

    -- Verifica parametros cadastrados em base
    open cr_dsvlrprm (vr_cdcooper);
    fetch cr_dsvlrprm into rw_dsvlrprm;
    close cr_dsvlrprm;
            
    vr_parametro := gene0002.fn_quebra_string(pr_string => rw_dsvlrprm
                                             ,pr_delimit => ';');
        
    -- Se encontrou popula variaveis                                          
    for i in 1..vr_parametro.count() loop
      case
        when i = 1 then vr_frmaxima := to_number(vr_parametro(i));
        when i = 2 then vr_fraideal := to_number(vr_parametro(i));
        when i = 3 then vr_intermin := to_number(vr_parametro(i));
        else null;
      end case;
    end loop;

    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root',   pr_posicao => 0, pr_tag_nova => 'Dados',    pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados',  pr_posicao => 0, pr_tag_nova => 'agencias', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    -- Caso parametro seja nulo devemos abortar
    if pr_cdagenci is null then
      vr_dscritic := 'Agência não informada/selecionada.';
      raise vr_exc_saida;
    end if;

    vr_tab_cdagenci := gene0002.fn_quebra_string(pr_cdagenci,';');
 
    -- Vincula agencias a tabela de memoria
    for i in vr_tab_cdagenci.first..vr_tab_cdagenci.last loop
        
      -- Parametro recebido
      vr_tab_dados_agenci(i).cdagenci := vr_tab_cdagenci(i);

      -- Abre loop principal
      for rw_crapage in cr_crapage (vr_cdcooper
                                   ,vr_tab_dados_agenci(i).cdagenci) loop

        -- Busca parametros de cada agencia
        rw_verifica_agencias := null;
        vr_flgsituacao := null;
        open cr_verifica_agencias (rw_crapage.cdcooper
                                  ,rw_crapage.cdagenci);
        fetch cr_verifica_agencias into rw_verifica_agencias;

        if cr_verifica_agencias%found then
          
          -- Se PA possuir cooperados calcula sugestao de qtd grupos
          if rw_verifica_agencias.contador > 0 then
              
            vr_qtdgrupo := trunc(rw_verifica_agencias.contador/vr_fraideal);
            
            if vr_qtdgrupo > 0 then 
              vr_frefetiv := ceil(rw_verifica_agencias.contador/vr_qtdgrupo);
              if vr_frefetiv + vr_intermin > vr_frmaxima then
                vr_qtdgrupo := vr_qtdgrupo + 1;
              end if;
            else
              vr_qtdgrupo := 1;
            end if;

          else
            close cr_verifica_agencias;
            continue;
          end if;
          
          vr_flgsituacao := rw_verifica_agencias.flgsituacao;

        end if;
        
        close cr_verifica_agencias;

        -- Contador para cargos de delegado e comite do PA                                     
        open cr_verifica_cargo (rw_crapage.cdcooper
                               ,rw_crapage.cdagenci);
        fetch cr_verifica_cargo into rw_verifica_cargo;
        close cr_verifica_cargo;
        
        if vr_flgsituacao = 'Sucesso' then
          rw_verifica_cargo.delegado := nvl(rw_verifica_cargo.delegado,0);
          rw_verifica_cargo.comitedu := nvl(rw_verifica_cargo.comitedu,0);
        end if;

        -- Popula informacoes via XML
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'agencias', pr_posicao => 0, pr_tag_nova => 'agencia', pr_tag_cont => null, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'agencia',  pr_posicao => vr_contador, pr_tag_nova => 'cdagenci', pr_tag_cont => rw_crapage.cdagenci,           pr_des_erro => vr_dscritic); 
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'agencia',  pr_posicao => vr_contador, pr_tag_nova => 'nrdgrupo', pr_tag_cont => rw_verifica_agencias.nrdgrupo, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'agencia',  pr_posicao => vr_contador, pr_tag_nova => 'contador', pr_tag_cont => rw_verifica_agencias.contador, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'agencia',  pr_posicao => vr_contador, pr_tag_nova => 'delegado', pr_tag_cont => rw_verifica_cargo.delegado,    pr_des_erro => vr_dscritic);                                                                                                                                                    
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'agencia',  pr_posicao => vr_contador, pr_tag_nova => 'comitedu', pr_tag_cont => rw_verifica_cargo.comitedu,    pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'agencia',  pr_posicao => vr_contador, pr_tag_nova => 'status',   pr_tag_cont => vr_flgsituacao,                pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'agencia',  pr_posicao => vr_contador, pr_tag_nova => 'qtdgrupo', pr_tag_cont => vr_qtdgrupo,                   pr_des_erro => vr_dscritic);

        vr_contador := vr_contador + 1;

      end loop;
      
    end loop;
    
    pr_des_erro := 'OK';
      
  exception
      
    when vr_exc_saida then

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
      pr_dscritic := 'Erro geral na rotina da tela TELA_CADGRP.pc_cursor_opcao_g: ' || sqlerrm;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      rollback;
        
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper);

  end pc_cursor_opcao_g;
  
  procedure pc_agenci_opcao_g (pr_cdagenci   in crapass.cdagenci%type
                              ,pr_xmllog     in varchar2
                              ,pr_cdcritic  out pls_integer
                              ,pr_dscritic  out varchar2
                              ,pr_retxml in out nocopy XMLType
                              ,pr_nmdcampo  out varchar2    
                              ,pr_des_erro  out varchar2) is

  ---------------------------------------------------------------------------
  --
  --  Programa : pc_agenci_opcao_g
  --  Sistema  : Ayllos Web
  --  Autor    : Gabriel Marcos
  --  Data     : Agosto/2018                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Apresenta informacoes da agencia (Opcao G).
  --            
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

    -- Busca agencias do loop principal
    cursor cr_verifica_agencias (pr_cdcooper in tbevento_pessoa_grupos.cdcooper%type
                                ,pr_cdagenci in tbevento_pessoa_grupos.cdagenci%type) is
    select dsc.cdagenci
         , dsc.nrdgrupo
         , dsc.qtd_membros contador
      from tbevento_grupos dsc
     where dsc.cdcooper = pr_cdcooper
       and dsc.cdagenci = pr_cdagenci
     order
        by dsc.nrdgrupo;
    rw_verifica_agencias cr_verifica_agencias%rowtype;
    
    -- Busca agencias do loop principal
    cursor cr_verifica_cargos (pr_cdcooper in tbevento_pessoa_grupos.cdcooper%type
                              ,pr_cdagenci in tbevento_pessoa_grupos.cdagenci%type
                              ,pr_nrdgrupo in tbevento_pessoa_grupos.nrdgrupo%type) is
    select nvl(sum(decode(pes.cdfuncao,'DT',1,'DS',1,0)),0)        delegado
         , nvl(sum(decode(pes.cdfuncao,'CL',1,'CS',1,'CM',1,0)),0) comitedu  
      from tbevento_pessoa_grupos     grp
         , tbcadast_vig_funcao_pessoa pes
     where grp.cdcooper = pr_cdcooper
       and grp.cdagenci = pr_cdagenci
       and grp.nrdgrupo = pr_nrdgrupo
       and pes.cdcooper = grp.cdcooper
       and pes.nrcpfcgc = grp.nrcpfcgc
       and pes.dtfim_vigencia is null
     group
        by grp.cdagenci
         , grp.nrdgrupo;
     rw_verifica_cargos cr_verifica_cargos%rowtype;
 
  begin
        
    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'CADGRP'
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
      raise vr_exc_saida;
    end if;
 
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root',   pr_posicao => 0, pr_tag_nova => 'Dados',    pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados',  pr_posicao => 0, pr_tag_nova => 'agencias', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    -- Busca informacoes para o segundo grid
    for rw_verifica_agencias in cr_verifica_agencias (vr_cdcooper
                                                     ,pr_cdagenci) loop
                 
      -- Limpeza de variaveis
      rw_verifica_cargos := null; 
      
      -- Buscar cargos para popular XML
      open cr_verifica_cargos (vr_cdcooper
                              ,rw_verifica_agencias.cdagenci
                              ,rw_verifica_agencias.nrdgrupo);
      fetch cr_verifica_cargos into rw_verifica_cargos;
      close cr_verifica_cargos;

      -- Popula dados via XML                                    
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'agencias', pr_posicao => 0, pr_tag_nova => 'agencia', pr_tag_cont => null, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'agencia',  pr_posicao => vr_contador, pr_tag_nova => 'cdagenci', pr_tag_cont => rw_verifica_agencias.cdagenci,      pr_des_erro => vr_dscritic); 
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'agencia',  pr_posicao => vr_contador, pr_tag_nova => 'nrdgrupo', pr_tag_cont => rw_verifica_agencias.nrdgrupo,      pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'agencia',  pr_posicao => vr_contador, pr_tag_nova => 'contador', pr_tag_cont => rw_verifica_agencias.contador,      pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'agencia',  pr_posicao => vr_contador, pr_tag_nova => 'delegado', pr_tag_cont => nvl(rw_verifica_cargos.delegado,0), pr_des_erro => vr_dscritic);                                                                                                                                                    
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'agencia',  pr_posicao => vr_contador, pr_tag_nova => 'comitedu', pr_tag_cont => nvl(rw_verifica_cargos.comitedu,0), pr_des_erro => vr_dscritic);

      vr_contador := vr_contador + 1;

    end loop;

    pr_des_erro := 'OK';
      
  exception
      
    when vr_exc_saida then

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
      pr_dscritic := 'Erro geral na rotina da tela TELA_CADGRP.pc_agenci_opcao_g: ' || sqlerrm;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      rollback;
        
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper);

  end pc_agenci_opcao_g;

  procedure pc_btn_dstribui_g (pr_xmllog     in varchar2
                              ,pr_cdcritic  out pls_integer
                              ,pr_dscritic  out varchar2
                              ,pr_retxml in out nocopy XMLType
                              ,pr_nmdcampo  out varchar2    
                              ,pr_des_erro  out varchar2) is

  ---------------------------------------------------------------------------
  --
  --  Programa : pc_btn_dstribui_g
  --  Sistema  : Ayllos Web
  --  Autor    : Gabriel Marcos
  --  Data     : Agosto/2018                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Fazer distribuicao para todas as agencias da cooperativa
  --            
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------
 
  begin
        
    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'CADGRP'
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
      raise vr_exc_saida;
    end if;

    -- Chamada distribuicao
    agrp0001.pc_distribui_conta_grupo_auto (pr_cdcooper => vr_cdcooper
                                           ,pr_cdoperad => vr_cdoperad
                                           ,pr_dsretorn => vr_dscritic);
                                  
    -- Aborta em caso de critica
    if trim(vr_dscritic) is not null then
      raise vr_exc_saida;
    end if;

    pr_des_erro := 'OK';
      
  exception
      
    when vr_exc_saida then

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
      pr_dscritic := 'Erro geral na rotina da tela TELA_CADGRP.pc_btn_dstribui_g: ' || sqlerrm;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      rollback;
        
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper);

  end pc_btn_dstribui_g;

  procedure pc_analisar_param_grupo_web (pr_cdagenci   in varchar2 
                                        ,pr_qtdgrupo   in varchar2 
                                        ,pr_xmllog     in varchar2
                                        ,pr_cdcritic  out pls_integer
                                        ,pr_dscritic  out varchar2
                                        ,pr_retxml in out nocopy XMLType
                                        ,pr_nmdcampo  out varchar2    
                                        ,pr_des_erro  out varchar2) is

  ---------------------------------------------------------------------------
  --
  --  Programa : pc_analisar_param_grupo_web
  --  Sistema  : Ayllos Web
  --  Autor    : Gabriel Marcos
  --  Data     : Agosto/2018                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Recebe parametros da tela e faz verificacoes.
  --
  -- Alteracoes:
  --
  --------------------------------------------------------------------------  

    -- Tabela de memoria que recebe parametro de entrada
    type typ_param_grupo is record (cdagenci crapage.cdagenci%type
                                   ,qtdgrupo number);
    type typ_tab_grupo is table of typ_param_grupo index by binary_integer;
    vr_tab_dados_grupo typ_tab_grupo;
    vr_tab_cdagenci   gene0002.typ_split;
    vr_tab_qtdgrupo   gene0002.typ_split;
    
    -- Quantidade de cooperados para a agencia
    cursor cr_qtd_membros_agencia (pr_cdcooper in crapass.cdcooper%type
                                  ,pr_cdagenci in crapass.cdagenci%type) is
    select count(1) contador
      from crapass ass
         , crapcop cop
         , tbcadast_pessoa pes
     where cop.flgativo  = 1
       and cop.cdcooper  = pr_cdcooper
       and cop.nrdocnpj <> ass.nrcpfcgc
       and ass.cdcooper  = cop.cdcooper
       and ass.cdagenci  = pr_cdagenci
       and ass.dtdemiss is null
       and pes.nrcpfcgc  = ass.nrcpfcgc 
       and not exists (select 1
                         from crapass a
                        where a.cdcooper   = cop.cdcooper
                          and a.nrcpfcgc   = ass.nrcpfcgc
                          and a.nrdconta  <> ass.nrdconta
                          and a.dtdemiss  is null
                          and ((a.dtadmiss < ass.dtadmiss) or
                               (a.dtadmiss = ass.dtadmiss and
                                a.nrdconta < ass.nrdconta)));
    rw_qtd_membros_agencia cr_qtd_membros_agencia%rowtype;
    
    vr_frefetiv   number := 0;
    vr_idprglog   number := 0;

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
      raise vr_exc_saida;
    end if;
    
    vr_tab_cdagenci := gene0002.fn_quebra_string(pr_cdagenci,';');
    vr_tab_qtdgrupo := gene0002.fn_quebra_string(pr_qtdgrupo,';');
    
    -- Vincula agencias com quantidade de grupos
    for i in vr_tab_cdagenci.first..vr_tab_cdagenci.last loop
      vr_tab_dados_grupo(i).cdagenci := vr_tab_cdagenci(i);
      vr_tab_dados_grupo(i).qtdgrupo := vr_tab_qtdgrupo(i);
    end loop;

    -- Verifica parametros cadastrados em base
    open cr_dsvlrprm (vr_cdcooper);
    fetch cr_dsvlrprm into rw_dsvlrprm;
    close cr_dsvlrprm;
          
    vr_parametro := gene0002.fn_quebra_string(pr_string => rw_dsvlrprm
                                             ,pr_delimit => ';');
      
    -- Se encontrou popula variaveis                                          
    for i in 1..vr_parametro.count() loop
      case
        when i = 1 then vr_frmaxima := to_number(vr_parametro(i));
        when i = 2 then vr_fraideal := to_number(vr_parametro(i));
        when i = 3 then vr_intermin := to_number(vr_parametro(i));
        else null;
      end case;
    end loop;

    -- Analisa se parametros estao dentro da regra
    for i in vr_tab_dados_grupo.first..vr_tab_dados_grupo.last loop

      -- Limpeza de variaveis
      rw_qtd_membros_agencia := null;
      
      -- Validacao de agencia
      if vr_tab_dados_grupo(i).cdagenci is null then
        vr_dscritic := 'Código de agencia não informado.';
        raise vr_exc_saida;  
      end if;

      -- Quantidade de cooperados para o PA
      open cr_qtd_membros_agencia (vr_cdcooper
                                  ,vr_tab_dados_grupo(i).cdagenci);
      fetch cr_qtd_membros_agencia into rw_qtd_membros_agencia;  
      close cr_qtd_membros_agencia;

      -- Validacao de grupo
      if vr_tab_dados_grupo(i).qtdgrupo is null then

        vr_dscritic := 'A quantidade de grupos do PA '||vr_tab_dados_grupo(i).cdagenci||
                       ' deve ser informada.';
        raise vr_exc_saida;
      
      else

        -- Validacoes com fracoes da cooperativa
        vr_frefetiv := ceil(rw_qtd_membros_agencia.contador/vr_tab_dados_grupo(i).qtdgrupo);
          
        -- Regra principal
        if vr_frefetiv + vr_intermin > vr_frmaxima then
          vr_dscritic := 'A quantidade de membros por grupo da Agencia '||
                         vr_tab_dados_grupo(i).cdagenci||' é maior que '||
                         'a Fração Máxima somado com o Intervalo Mínimo.';
          raise vr_exc_saida;
        end if;
      
      end if;
    
    end loop;

  exception
    
    when vr_exc_saida then

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
      pr_dscritic := 'Erro geral na rotina da tela TELA_CADGRP.pc_analisar_param_grupo_web: ' || sqlerrm;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      rollback;
        
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper);

  end pc_analisar_param_grupo_web;

  procedure pc_distribui_conta_grupo_web (pr_cdagenci   in varchar2 
                                         ,pr_qtdgrupo   in varchar2 
                                         ,pr_xmllog     in varchar2
                                         ,pr_cdcritic  out pls_integer
                                         ,pr_dscritic  out varchar2
                                         ,pr_retxml in out nocopy XMLType
                                         ,pr_nmdcampo  out varchar2    
                                         ,pr_des_erro  out varchar2) is

  ---------------------------------------------------------------------------
  --
  --  Programa : pc_distribui_conta_grupo_web
  --  Sistema  : Ayllos Web
  --  Autor    : Gabriel Marcos
  --  Data     : Agosto/2018                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Recebe parametros da tela e faz um loop para distribuir
  --             grupos nas agencias recebidas
  --
  -- Alteracoes:
  --
  --------------------------------------------------------------------------  

    -- Variaveis da tabela de memoria
    type typ_param_grupo is record (cdagenci crapage.cdagenci%type
                                   ,qtdgrupo number);
    type typ_tab_grupo is table of typ_param_grupo index by binary_integer;
    vr_tab_dados_grupo typ_tab_grupo;

    vr_tab_cdagenci gene0002.typ_split;
    vr_tab_qtdgrupo gene0002.typ_split;

    vr_frefetiv   number := 0;
    vr_idprglog   number := 0;

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

    if trim(vr_dscritic) is not null then
      raise vr_exc_saida;
    end if;
    
    vr_tab_cdagenci := gene0002.fn_quebra_string(pr_cdagenci,';');
    vr_tab_qtdgrupo := gene0002.fn_quebra_string(pr_qtdgrupo,';');
    
    -- Vincula agencias com quantidade de grupos
    for i in vr_tab_cdagenci.first..vr_tab_cdagenci.last loop
      vr_tab_dados_grupo(i).cdagenci := vr_tab_cdagenci(i);
      vr_tab_dados_grupo(i).qtdgrupo := vr_tab_qtdgrupo(i);
    end loop;

    -- Faz a chamada da rotina principal
    for i in vr_tab_dados_grupo.first..vr_tab_dados_grupo.last loop

      -- Limpeza de variaveis
      vr_cdcritic := null;
      vr_dscritic := null;
      
      -- Procedure de distribuicao
      agrp0001.pc_distribui_conta_grupo (pr_cdcooper => vr_cdcooper
                                        ,pr_cdagenci => vr_tab_dados_grupo(i).cdagenci
                                        ,pr_cdoperad => vr_cdoperad
                                        ,pr_qtdgrupo => vr_tab_dados_grupo(i).qtdgrupo
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);
      
      -- Se retornou erro atualiza informacoes da agencia                                  
      if nvl(vr_cdcritic,0) > 0 or trim(vr_dscritic) is not null then

        begin
          
          update tbevento_grupos
             set flgsituacao = 2 -- Critica
           where cdcooper    = vr_cdcooper
             and cdagenci    = vr_tab_dados_grupo(i).cdagenci;
           
        exception
          
          when others then
            
            vr_dscritic := 'Erro ao atualizar Tabela de Resumo de Grupos (1).';
            raise vr_exc_saida;
            
        end;

        vr_idprglog := 0;
        
        -- Logar fim de execução sem sucesso
        cecred.pc_log_programa(pr_dstiplog      => 'E' -- Erro
                              ,pr_cdprograma    => 'TELA_CADGRP.pc_distribui_conta_grupo_web'
                              ,pr_cdcooper      => vr_cdcooper
                              ,pr_tpexecucao    => 3   -- Online
                              ,pr_tpocorrencia  => 2   -- Erro nao tratado
                              ,pr_cdcriticidade => 1   -- Media
                              ,pr_cdmensagem    => 0
                              ,pr_dsmensagem    => 'Agencia: ' || vr_tab_dados_grupo(i).cdagenci ||
                                                   ' Module: AGRP0001 '|| vr_dscritic
                              ,pr_idprglog      => vr_idprglog);
        
      else

        begin
          
          update tbevento_grupos
             set flgsituacao = 1 --Sucesso
           where cdcooper    = vr_cdcooper
             and cdagenci    = vr_tab_dados_grupo(i).cdagenci;
             
        exception
          
          when others then
          
            vr_dscritic := 'Erro ao atualizar Tabela de Resumo de Grupos (2).';
            raise vr_exc_saida;

        end;     
        
      end if;
                              
    end loop;
    
    commit;

  exception

    when others then

      rollback;
      
      pr_cdcritic := 0;
      pr_dscritic := 'Erro não tratado TELA_CADGRP.pc_distribui_conta_grupo_web: ' || sqlerrm;

      -- Logar fim de execução sem sucesso
      cecred.pc_log_programa(pr_dstiplog      => 'E' -- Erro
                            ,pr_cdprograma    => 'TELA_CADGRP.pc_distribui_conta_grupo_web'
                            ,pr_cdcooper      => vr_cdcooper
                            ,pr_tpexecucao    => 3   -- Online
                            ,pr_tpocorrencia  => 2   -- Erro nao tratado
                            ,pr_cdcriticidade => 3   -- Critico
                            ,pr_cdmensagem    => 0
                            ,pr_dsmensagem    => pr_dscritic
                            ,pr_idprglog      => vr_idprglog);

  end pc_distribui_conta_grupo_web;

end TELA_CADGRP;
/