CREATE OR REPLACE PACKAGE CECRED.AGRP0001 IS

  function md5 (valor varchar) return varchar2;

  procedure pc_distribui_conta_grupo_auto (pr_cdcooper  in crapass.cdcooper%type
                                          ,pr_cdoperad  in crapope.cdoperad%type
                                          ,pr_dsretorn out varchar2);
                                          
  procedure pc_distribui_conta_grupo (pr_cdcooper  in crapass.cdcooper%type 
                                     ,pr_cdagenci  in crapass.cdagenci%type
                                     ,pr_cdoperad  in crapope.cdoperad%type
                                     ,pr_qtdgrupo  in number
                                     ,pr_cdcritic out pls_integer
                                     ,pr_dscritic out varchar2);
                                
  procedure pc_atz_grp_agenci (pr_cdcooper  in crapass.cdcooper%type
                              ,pr_cdagenci  in crapass.cdagenci%type
                              ,pr_qtdgrupo  in number
                              ,pr_cdoperad  in crapope.cdoperad%type
                              ,pr_cdcritic out pls_integer
                              ,pr_dscritic out varchar2);
     
  procedure pc_agencia_conta (pr_cdcooper   in crapass.cdcooper%type
                             ,pr_nrdconta   in crapass.nrdconta%type
                             ,pr_retxml in out nocopy XMLType
                             ,pr_cdcritic  out varchar2
                             ,pr_dscritic  out varchar2);
                             
  procedure pc_demitir_conta (pr_cdcooper   in crapass.cdcooper%type
                             ,pr_nrdconta   in crapass.nrdconta%type
                             ,pr_retxml in out nocopy XMLType
                             ,pr_cdcritic  out varchar2
                             ,pr_dscritic  out varchar2);
                             

  procedure pc_admitir_conta (pr_cdcooper   in crapass.cdcooper%type
                             ,pr_nrdconta   in crapass.nrdconta%type
                             ,pr_retxml in out nocopy XMLType
                             ,pr_cdcritic  out varchar2
                             ,pr_dscritic  out varchar2);
                             
  procedure pc_obtem_nova_pessoa (pr_cdcooper   in crapass.cdcooper%type
                                 ,pr_idpessoa   in tbcadast_pessoa.idpessoa%type
                                 ,pr_retxml in out nocopy XMLType
                                 ,pr_cdcritic  out varchar2
                                 ,pr_dscritic  out varchar2);
                                 
  procedure pc_cartoes_conta_auto_job;
                                 
  procedure pc_cartoes_conta (pr_cdcooper   in crapass.cdcooper%type
                             ,pr_nrdconta   in tbcadast_pessoa.idpessoa%type
                             ,pr_nrcrcard   in crapcrd.nrcrcard%type
                             ,pr_dscritic  out varchar2);
  
END AGRP0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.AGRP0001 IS

  ---------------------------------------------------------------------------
  --
  --  Programa : AGRP0001
  --  Sistema  : Ayllos Web
  --  Autor    : Gabriel Marcos
  --  Data     : Setembro/2018                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas distruicao de grupos de assembleias
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

    vr_exc_erro  exception;
    vr_exc_saida exception; 
    vr_cdcritic  pls_integer;
    vr_dscritic  varchar2(10000); 

    rw_dsvlrprm  varchar2(100);     
    vr_frmaxima  number:=0;                                         
    vr_fraideal  number:=0;      
    vr_intermin  number:=0;

    -- Busca dados do conjuge
    cursor cr_crapcje (pr_cdcooper in crapass.cdcooper%type
                      ,pr_cdagenci in crapass.cdagenci%type
                      ,pr_nrcpfcgc in crapass.nrcpfcgc%type) is
    select ass.cdcooper
         , ass.cdagenci
         , ass.nrcpfcgc
         , ass.nrdconta
         , ass.inpessoa
         , ass.dtadmiss
         , pes.idpessoa
         , ass.tpvincul
      from crapass ass
         , crapcop cop
         , tbcadast_pessoa pes
         , tbcadast_pessoa c
         , tbcadast_pessoa_relacao d
         , tbcadast_pessoa e
         , tbcadast_dominio_campo f
     where c.nrcpfcgc    = pr_nrcpfcgc
       and d.idpessoa    = c.idpessoa
       and e.idpessoa    = d.idpessoa_relacao
       and f.cddominio   = d.tprelacao
       and f.nmdominio   = 'TPRELACAO'
       and f.cddominio   = 1
       and cop.flgativo  = 1
       and cop.cdcooper  = pr_cdcooper
       and cop.nrdocnpj <> ass.nrcpfcgc
       and ass.cdcooper  = cop.cdcooper
       and ass.cdagenci  = pr_cdagenci
       and ass.nrcpfcgc  = e.nrcpfcgc
       and ass.dtdemiss is null
       and pes.nrcpfcgc  = ass.nrcpfcgc
     order
        by ass.dtadmiss
         , ass.nrdconta;
    rw_crapcje cr_crapcje%rowtype;

    -- Array para guardar o split dos dados contidos na dsvlrprm       
    vr_parametro  gene0002.typ_split; 
    
    -- Busca parametros cadastrados
    cursor cr_dsvlrprm (pr_cdcooper crapprm.cdcooper%type) is
    select prm.dsvlrprm
      from crapprm prm
     where prm.nmsistem = 'CRED'
       and prm.cdcooper = pr_cdcooper
       and prm.cdacesso = 'TELA_CADGRP_OPCAO_P'; 
 
  -- Funcao para criptografar dados
  function md5 (valor varchar) return varchar2 is
    v_input varchar2(2000) := valor;
    hexkey  varchar(32)    := null;
  begin
    hexkey := rawtohex(dbms_obfuscation_toolkit.md5(input => UTL_RAW.cast_to_raw(v_input)));
    return nvl(hexkey,'');
  end;

  procedure pc_distribui_conta_grupo_auto (pr_cdcooper  in crapass.cdcooper%type
                                          ,pr_cdoperad  in crapope.cdoperad%type
                                          ,pr_dsretorn out varchar2)  is

  ---------------------------------------------------------------------------
  --
  --  Programa : pc_distribui_conta_grupo_auto
  --  Sistema  : Ayllos Web
  --  Autor    : Gabriel Marcos
  --  Data     : Agosto/2018                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Rotina que ira verificar a necessidade de redistribuicao
  --             dos grupos devido ao estouro da quantidade maxima de 
  --             cooperados por grupo
  --
  -- Alteracoes:
  --
  --------------------------------------------------------------------------  
    
    -- Busca agencias para verificacao
    cursor cr_crapcop (pr_cdcooper in crapcop.cdcooper%type) is
    select cop.cdcooper
         , age.cdagenci
         , cop.flgrupos
      from crapcop cop
         , crapage age
     where cop.cdcooper = decode(pr_cdcooper,0,cop.cdcooper,pr_cdcooper)
       and cop.flgativo = 1
       and age.cdcooper = cop.cdcooper
       and age.insitage = 1
     order
        by cop.flgrupos desc;
  
    -- Busca agencias do loop principal
    cursor cr_verifica_agencias (pr_cdcooper in tbevento_pessoa_grupos.cdcooper%type
                                ,pr_cdagenci in tbevento_pessoa_grupos.cdagenci%type) is
    select age.cdcooper
         , age.cdagenci
         , nvl(dsc.nrdgrupo,0)    nrdgrupo
         , nvl(dsc.qtd_membros,0) contador
         , nvl(max(dsc.nrdgrupo)over (partition by age.cdagenci),0) qtdregis
      from crapage         age
         , tbevento_grupos dsc
     where age.cdcooper = pr_cdcooper
       and age.cdagenci = pr_cdagenci
       and dsc.cdcooper (+) = age.cdcooper
       and dsc.cdagenci (+) = age.cdagenci
     group
        by age.cdcooper
         , age.cdagenci
         , dsc.nrdgrupo
         , dsc.qtd_membros
     order
        by contador desc;
    rw_verifica_agencias cr_verifica_agencias%rowtype;
    
    -- Quantidade de cooperados para a agencia
    cursor cr_qtd_membros_agencia (pr_cdcooper in crapass.cdcooper%type
                                  ,pr_cdagenci in crapass.cdagenci%type) is
    select count(1) contador
      from crapass ass
     where ass.cdcooper  = pr_cdcooper
       and ass.cdagenci  = pr_cdagenci
       and ass.dtdemiss  is null
       and not exists (select 1
                         from crapass a
                        where a.cdcooper  = ass.cdcooper 
                          and a.nrcpfcgc  = ass.nrcpfcgc
                          and a.nrdconta <> ass.nrdconta
                          and a.dtdemiss is null
                          and ((a.dtadmiss < ass.dtadmiss) or
                               (a.dtadmiss = ass.dtadmiss and
                                a.nrdconta < ass.nrdconta)));
    rw_qtd_membros_agencia cr_qtd_membros_agencia%rowtype;
    
    -- Periodo onde novos grupos nao podem ser criados
    cursor cr_busca_travamento_grupos (pr_cdcooper in tbevento_exercicio.cdcooper%type) is
    select exe.dtinicio_grupo
         , exe.dtfim_grupo
      from tbevento_exercicio exe
     where exe.cdcooper = pr_cdcooper
       and exe.flgativo = 1;
    rw_busca_travamento_grupos cr_busca_travamento_grupos%rowtype;
    
    -- Busca data de movimentacao da cooperativa
    cursor cr_crapdat (pr_cdcooper crapdat.cdcooper%type) is
    select dat.dtmvtolt
      from crapdat dat
     where dat.cdcooper = pr_cdcooper;
    rw_crapdat cr_crapdat%rowtype;
  
    vr_frefetiv number := 0;
    vr_qtdgrupo number := 0;
    vr_idprglog number := 0;
    vr_contador number := 0;
    vr_cdprogra varchar2(100) := 'DST_AUTO_GRUPOS';
    vr_cdcooper crapass.cdcooper%type := 0;

  begin

    vr_idprglog := 0;
      
    -- Gera log no início da execução
    pc_log_programa(pr_dstiplog   => 'I'         
                   ,pr_cdprograma => vr_cdprogra 
                   ,pr_cdcooper   => 0
                   ,pr_tpexecucao => 0     
                   ,pr_idprglog   => vr_idprglog);

    -- Loop em cooperativas e agencias
    for rw_crapcop in cr_crapcop (nvl(pr_cdcooper,0)) loop
      
      -- Verificacoes para a cooperativa e ou chamada web
      if pr_cdcooper is not null and rw_crapcop.flgrupos = 0 then
        pr_dsretorn := 'Cooperativa não possui produto assembleias ativo.';
        raise vr_exc_saida;
      elsif rw_crapcop.flgrupos = 0 then
        continue;
      end if;
      
      begin
      
        -- Validacoes iniciais para cada cooperativa
        if vr_cdcooper <> rw_crapcop.cdcooper then
          
          -- Limpeza de variaveis
          vr_cdcooper := rw_crapcop.cdcooper;
          vr_contador := 0;
          vr_frmaxima := 0;                                         
          vr_fraideal := 0;      
          vr_intermin := 0;
          vr_dscritic := null;
          
          -- Busca data da cooperativa
          open cr_crapdat (vr_cdcooper);
          fetch cr_crapdat into rw_crapdat;
          
          -- Se nao encontrar aborta
          if cr_crapdat%notfound then
            
            close cr_crapdat;
            vr_dscritic := 'Data da cooperativa não cadastrada.';
            raise vr_exc_erro;

          end if;
          
          close cr_crapdat;
          
          -- Validacoes de travamento de grupos
          open cr_busca_travamento_grupos (vr_cdcooper);
          fetch cr_busca_travamento_grupos into rw_busca_travamento_grupos;

          -- Condicoes de critica
          if cr_busca_travamento_grupos%notfound then
            close cr_busca_travamento_grupos;
            vr_dscritic := 'Edital de assembleia nao encontrado.';
            raise vr_exc_saida;
          elsif rw_busca_travamento_grupos.dtinicio_grupo < rw_crapdat.dtmvtolt and
                rw_busca_travamento_grupos.dtfim_grupo > rw_crapdat.dtmvtolt then
            close cr_busca_travamento_grupos;
            vr_dscritic := 'Período não permite criação de novos grupos.';
            raise vr_exc_saida;
          end if;
          
          close cr_busca_travamento_grupos;

          -- Verifica parametros cadastrados em base
          open cr_dsvlrprm (rw_crapcop.cdcooper);

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
          
          -- Se nao encontrou fracoes deve abortar cooperativa
          if nvl(vr_frmaxima,0) = 0 or nvl(vr_fraideal,0) = 0 or nvl(vr_intermin,0) = 0 then

            vr_dscritic := 'AGRP0001.pc_distribui_conta_grupo_auto: '||
                           'Fracoes de grupo nao encontradas. Coop: '|| vr_cdcooper;
            raise vr_exc_saida;
            
          end if;
  
        end if;
        
        -- Enquanto nao mudar de cooperativa
        -- deve abortar por causa da critica apresentada
        if vr_dscritic is not null then
          raise vr_exc_saida;
        end if;

        -- Analisa se parametros estao dentro da regra
        open cr_verifica_agencias (rw_crapcop.cdcooper
                                  ,rw_crapcop.cdagenci);
        fetch cr_verifica_agencias into rw_verifica_agencias;
        
        -- Analisa tabela de grupos
        if cr_verifica_agencias%found then
            
          -- Ou estourou qtd maxima ou agencia ainda nao foi locada
          if rw_verifica_agencias.contador > vr_frmaxima or 
             rw_verifica_agencias.contador = 0 then

            -- Busca quantidade de membros atualizada da ass
            open cr_qtd_membros_agencia (rw_verifica_agencias.cdcooper
                                        ,rw_verifica_agencias.cdagenci);
            fetch cr_qtd_membros_agencia into rw_qtd_membros_agencia;
            close cr_qtd_membros_agencia;
              
            -- Verificacao adicional de membros
            if rw_qtd_membros_agencia.contador > 0 then
               
              vr_qtdgrupo := trunc(rw_qtd_membros_agencia.contador/vr_fraideal);
                
              if vr_qtdgrupo > 0 then 
                vr_frefetiv := ceil(rw_qtd_membros_agencia.contador/vr_qtdgrupo);
                if vr_frefetiv + vr_intermin > vr_frmaxima then
                  vr_qtdgrupo := vr_qtdgrupo + 1;
                end if;
              else
                vr_qtdgrupo := 1;
              end if;

            -- Se nao possui membros no PA aborta
            else
              close cr_verifica_agencias;
              continue;
            end if;

            -- Limpeza de variaveis 
            vr_cdcritic := null;
            vr_dscritic := null;
              
            -- Apenas distribui se existir a necessidade de aumentar
            -- a quantidade de grupos inicialmente distribuida
            if vr_qtdgrupo > rw_verifica_agencias.qtdregis then

              -- Rotina de distribuicao de grupos
              pc_distribui_conta_grupo (pr_cdcooper => rw_verifica_agencias.cdcooper
                                       ,pr_cdagenci => rw_verifica_agencias.cdagenci
                                       ,pr_cdoperad => nvl(pr_cdoperad,1)
                                       ,pr_qtdgrupo => vr_qtdgrupo
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);
              
              -- Se retornar com critica fazer validacoes
              if nvl(vr_cdcritic,0) > 0 or trim(vr_dscritic) is not null then
               
                begin
                    
                  update tbevento_grupos
                     set flgsituacao = 2 -- Critica
                   where cdcooper    = rw_crapcop.cdcooper
                     and cdagenci    = rw_crapcop.cdagenci;
                     
                exception
                    
                  when others then
                    
                    vr_dscritic := 'Erro na atualizacao da tabela de grupos.';
                    raise vr_exc_saida;
                      
                end;   
                  
                vr_idprglog := 0;
                  
                -- Logar fim de execução sem sucesso
                cecred.pc_log_programa(pr_dstiplog      => 'E' -- Erro
                                      ,pr_cdprograma    => 'AGRP0001.pc_distribui_conta_grupo_auto'
                                      ,pr_cdcooper      => rw_crapcop.cdcooper
                                      ,pr_tpexecucao    => 2   -- Job
                                      ,pr_tpocorrencia  => 2   -- Erro nao tratado
                                      ,pr_cdcriticidade => 1   -- Media
                                      ,pr_cdmensagem    => 0
                                      ,pr_dsmensagem    => 'Agencia: '|| rw_crapcop.cdagenci  ||
                                                           ' Module: AGRP0001 '||
                                                           vr_dscritic
                                      ,pr_idprglog      => vr_idprglog);
                
                -- Limpeza de variaveis para proxima agencia
                vr_cdcritic := null;
                vr_dscritic := null;
                  
              else
                  
                begin
                    
                  -- Sem retorno de critica, deve atualizar
                  -- flag de sucesso na tabela de resumo de grupos
                  update tbevento_grupos
                     set flgsituacao = 1 -- Sucesso
                   where cdcooper    = rw_crapcop.cdcooper
                     and cdagenci    = rw_crapcop.cdagenci;
                    
                exception
                    
                  when others then
                      
                    vr_dscritic := 'Erro na atualizacao da tabela de grupos.';
                    raise vr_exc_saida;

                end;
     
              end if;
              
            end if;

          end if;
        
        end if;

        close cr_verifica_agencias;

      exception
        
        when vr_exc_saida then
          
          -- Retorno para tela cadgrp
		  pr_dsretorn := vr_dscritic;

          vr_idprglog := 0;  
        
          cecred.pc_log_programa(pr_dstiplog      => 'E' -- Erro
                                ,pr_cdprograma    => 'AGRP0001.pc_distribui_conta_grupo_auto'
                                ,pr_cdcooper      => rw_crapcop.cdcooper
                                ,pr_tpexecucao    => 2   -- Job
                                ,pr_tpocorrencia  => 2   -- Erro nao tratado
                                ,pr_cdcriticidade => 3   -- Critica
                                ,pr_cdmensagem    => 0
                                ,pr_dsmensagem    => ' Module: AGRP0001 '||vr_dscritic
                                ,pr_idprglog      => vr_idprglog);
      end;
    
      commit;

    end loop;
    
    -- Gera log no fim da execução
    pc_log_programa(pr_dstiplog   => 'F'         
                   ,pr_cdprograma => vr_cdprogra 
                   ,pr_cdcooper   => 0
                   ,pr_tpexecucao => 0    
                   ,pr_flgsucesso => 1
                   ,pr_idprglog   => vr_idprglog);

  exception
    
    when vr_exc_saida then
  
      rollback;
       
      -- Gera log no início da execução
      pc_log_programa(pr_dstiplog   => 'F'         
                     ,pr_cdprograma => vr_cdprogra 
                     ,pr_cdcooper   => 0
                     ,pr_tpexecucao => 0    
                     ,pr_flgsucesso => 0 
                     ,pr_idprglog   => vr_idprglog);

    when others then
      
      rollback;
       
      -- Gera log no início da execução
      pc_log_programa(pr_dstiplog   => 'F'         
                     ,pr_cdprograma => vr_cdprogra 
                     ,pr_cdcooper   => 0
                     ,pr_tpexecucao => 0    
                     ,pr_flgsucesso => 0 
                     ,pr_idprglog   => vr_idprglog);
       
      vr_cdcritic := 0;
      vr_dscritic := 'Erro não tratado AGRP0001.pc_distribui_conta_grupo_auto: '||SQLERRM;
      vr_idprglog := 0;
      pr_dsretorn := vr_dscritic;
      
      cecred.pc_log_programa(pr_dstiplog      => 'E' -- Erro
                            ,pr_cdprograma    => 'AGRP0001.pc_distribui_conta_grupo_auto'
                            ,pr_cdcooper      => vr_cdcooper
                            ,pr_tpexecucao    => 2   -- Job
                            ,pr_tpocorrencia  => 2   -- Erro nao tratado
                            ,pr_cdcriticidade => 3   -- Critica
                            ,pr_cdmensagem    => 0
                            ,pr_dsmensagem    => ' Module: AGRP0001 '||vr_dscritic
                            ,pr_idprglog      => vr_idprglog);
      
  end pc_distribui_conta_grupo_auto;

  procedure pc_distribui_conta_grupo (pr_cdcooper  in crapass.cdcooper%type 
                                     ,pr_cdagenci  in crapass.cdagenci%type
                                     ,pr_cdoperad  in crapope.cdoperad%type
                                     ,pr_qtdgrupo  in number
                                     ,pr_cdcritic out pls_integer
                                     ,pr_dscritic out varchar2) is

  ---------------------------------------------------------------------------
  --
  --  Programa : pc_distribui_conta_grupo
  --  Sistema  : Ayllos Web
  --  Autor    : Gabriel Marcos
  --  Data     : Agosto/2018                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Buscar cooperados aptos a serem distribuidos em grupos
  --
  -- Alteracoes:
  --
  --------------------------------------------------------------------------  

    -- Busca dados do cooperado
    cursor cr_crapass (pr_cdcooper in crapass.cdcooper%type
                      ,pr_cdagenci in crapass.cdagenci%type) is
    select ass.cdcooper
         , ass.cdagenci
         , ass.nrcpfcgc
         , ass.nrdconta
         , ass.inpessoa
         , ass.tpvincul
         , pes.idpessoa
         , case ass.tpvincul when 'CD' then 6
                             when 'DT' then 5
                             when 'DS' then 4
                             when 'CL' then 3
                             when 'CS' then 2
                             when 'CM' then 1
                             else 0 end ordenado
      from crapass ass
         , tbcadast_pessoa pes
     where ass.cdcooper  = pr_cdcooper
       and ass.cdagenci  = pr_cdagenci
       and ass.dtdemiss is null
       and pes.nrcpfcgc  = ass.nrcpfcgc
     order
        by ordenado desc;
        
    -- Busca dados da cooperativa
    cursor cr_crapcop (pr_cdcooper in crapass.cdcooper%type) is
    select cop.nrdocnpj
      from crapcop cop
     where cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%rowtype;

    -- Busca grupo do coperado
    cursor cr_participa_grupo (pr_cdcooper in tbevento_pessoa_grupos.cdcooper%type
                              ,pr_cdagenci in tbevento_pessoa_grupos.cdagenci%type
                              ,pr_nrcpfcgc in tbevento_pessoa_grupos.nrcpfcgc%type) is
    select grp.nrdgrupo
         , ass.nrcpfcgc
         , ass.tpvincul
      from tbevento_pessoa_grupos grp
         , crapass                ass
     where grp.cdcooper = pr_cdcooper
       and grp.cdagenci = pr_cdagenci
       and grp.nrcpfcgc = pr_nrcpfcgc
       and ass.cdcooper = grp.cdcooper
       and ass.cdagenci = grp.cdagenci
       and ass.nrdconta = grp.nrdconta;
    rw_participa_grupo cr_participa_grupo%rowtype;

    vr_nrdgrupo tbevento_pessoa_grupos.nrdgrupo%type := 1;
    vr_nrdconta crapass.nrdconta%type;
    vr_cdprogra varchar2(100) := 'DST_GRUPOS_';
    vr_idprglog number;
    
    -- Tabela de memoria que recebe dados para insert
    type typ_dados_insert is record (cdcooper crapass.cdcooper%type
                                    ,cdagenci crapass.cdagenci%type
                                    ,nrdconta crapass.nrdconta%type
                                    ,nrcpfcgc crapass.nrcpfcgc%type
                                    ,idpessoa tbcadast_pessoa.idpessoa%type
                                    ,nrdgrupo number
                                    ,tpvincul crapass.tpvincul%type);                       
    type typ_table_insert is table of typ_dados_insert index by varchar2(20);--binary_integer;  
    vr_table_insert typ_table_insert; 
    
    vr_idx varchar2(20);
    
    -- Tabela de memoria para controle de grupos
    type typ_dados_control is record (contador number);                       
    type typ_table_control is table of typ_dados_control index by binary_integer;  
    vr_table_control typ_table_control; 
    
    -- Tabela de memoria para controle de comites
    type typ_dados_comites is record (contador number);                       
    type typ_table_comites is table of typ_dados_comites index by binary_integer;  
    vr_table_comites typ_table_comites; 

    -- Retorna conta mais antiga ou de menor numero do cooperado
    procedure pc_buscar_conta (pr_cdcooper  in crapass.cdcooper%type
                              ,pr_nrcpfcgc  in crapass.nrcpfcgc%type
                              ,vr_nrdconta out crapass.nrdconta%type) is
                              
      -- Cursor para retornar conta mais antiga ou de menor
      -- numero para utilizar como comparacao no retorno
      cursor cr_crapass (pr_cdcooper crapass.cdcooper%type
                        ,pr_nrcpfcgc crapass.nrcpfcgc%type) is
      select ass.nrdconta
        from crapass ass
       where ass.cdcooper  = pr_cdcooper
         and ass.nrcpfcgc  = pr_nrcpfcgc
         and ass.dtdemiss is null
       order
          by ass.dtadmiss
           , ass.nrdconta;
      rw_crapass cr_crapass%rowtype;
    
    begin
      
      -- Buscar variavel de conta
      open cr_crapass (pr_cdcooper
                      ,pr_nrcpfcgc);
      fetch cr_crapass into rw_crapass;
      close cr_crapass;

      -- Atribuicao a variavel
      vr_nrdconta := rw_crapass.nrdconta;
    
    exception
      
      when others then
      
        null;
    
    end; 

  begin
    
    vr_idprglog := 0;
      
    -- Gera log no início da execução
    pc_log_programa(pr_dstiplog   => 'I'         
                   ,pr_cdprograma => vr_cdprogra||trim(to_char(pr_cdagenci,'000')) 
                   ,pr_cdcooper   => pr_cdcooper
                   ,pr_tpexecucao => 0     
                   ,pr_idprglog   => vr_idprglog);

    -- Regras para limpeza dos grupos
    pc_atz_grp_agenci (pr_cdcooper
                      ,pr_cdagenci
                      ,pr_qtdgrupo
                      ,pr_cdoperad
                      ,vr_cdcritic
                      ,vr_dscritic);

    -- Se retornou erro aborta
    if nvl(vr_cdcritic,0) > 0 or trim(vr_dscritic) is not null then
      raise vr_exc_saida;
    end if;
    
    -- Inicializacao de variaveis
    for i in 1..pr_qtdgrupo loop
      vr_table_control(i).contador := 0;
      vr_table_comites(i).contador := 0;
    end loop;
    
    -- Busca dados da cooperativa
    open cr_crapcop (pr_cdcooper);
    fetch cr_crapcop into rw_crapcop;
    close cr_crapcop;

    -- Loop nos cooperados aptos a estarem na assembleia
    for rw_crapass in cr_crapass (pr_cdcooper 
                                 ,pr_cdagenci) loop

      -- Nao analisa conta administrativa
      if rw_crapass.nrcpfcgc = rw_crapcop.nrdocnpj then
        continue;
      end if;

      -- Adicionado para melhoria de performance
      pc_buscar_conta (rw_crapass.cdcooper
                      ,rw_crapass.nrcpfcgc
                      ,vr_nrdconta);
                      
      -- Se conta retornada nao for a mais antiga e ou de
      -- menor numero, nao interessa e pula para proxima                
      if nvl(vr_nrdconta,0) <> rw_crapass.nrdconta then
        continue;
      end if;

      vr_nrdgrupo := 1;
      
      -- Determinacao do grupo com menor quantidade de membros
      if rw_crapass.tpvincul in ('CL','CS','CM') then
        -- Controle de populacao
        for i in 2..pr_qtdgrupo loop
          if vr_table_comites(i).contador < vr_table_comites(vr_nrdgrupo).contador then
            vr_nrdgrupo := i;
          end if;
        end loop;
      else
        -- Controle de populacao
        for i in 2..pr_qtdgrupo loop
          if vr_table_control(i).contador < vr_table_control(vr_nrdgrupo).contador then
            vr_nrdgrupo := i;
          end if;
        end loop;
      end if;

      -- Se for delegado, cooperado nao deve ser locado,
      -- por que ele nao foi deletado pela pc_atz_grp_agenci
      -- Se ele tiver conjuge, quando conjuge for analisado
      -- vai encontrar delegado e ir em direcao ao seu grupo
      if rw_crapass.tpvincul in ('CD','DT','DS') then
        continue;
      end if;
        
      -- Primeiro trata pessoa fisica
      if rw_crapass.inpessoa = 1 then

        begin

          -- Caso nao tenha sido locado na tabela de memoria
          if not vr_table_insert.exists(rw_crapass.nrcpfcgc) then

            -- Para insert na tabela de grupos
            vr_table_insert(rw_crapass.nrcpfcgc).cdcooper := rw_crapass.cdcooper;
            vr_table_insert(rw_crapass.nrcpfcgc).cdagenci := rw_crapass.cdagenci;
            vr_table_insert(rw_crapass.nrcpfcgc).nrdconta := rw_crapass.nrdconta;
            vr_table_insert(rw_crapass.nrcpfcgc).nrcpfcgc := rw_crapass.nrcpfcgc;
            vr_table_insert(rw_crapass.nrcpfcgc).idpessoa := rw_crapass.idpessoa;
            vr_table_insert(rw_crapass.nrcpfcgc).nrdgrupo := vr_nrdgrupo;
            vr_table_insert(rw_crapass.nrcpfcgc).tpvincul := rw_crapass.tpvincul;
              
            -- Para controle de populacao
            vr_table_control(vr_nrdgrupo).contador := vr_table_control(vr_nrdgrupo).contador + 1;
            
            -- Se for comite, cooperado sera locado,
            -- Se ele tiver conjuge, quando conjuge for analisado
            -- vai encontrar comite e ir em direcao ao seu grupo
            if rw_crapass.tpvincul in ('CL','CS','CM') then
              vr_table_comites(vr_nrdgrupo).contador := vr_table_comites(vr_nrdgrupo).contador + 1;
              continue;
            end if;

          end if;

        exception

          when others then
              
            vr_dscritic := 'Erro na AGRP0001.pc_distribui_conta_grupo (1) --> '|| sqlerrm;
            raise vr_exc_saida;
            
        end;
          
        -- Verifica conjuge do cooperado
        open cr_crapcje (rw_crapass.cdcooper
                        ,rw_crapass.cdagenci
                        ,rw_crapass.nrcpfcgc);
        fetch cr_crapcje into rw_crapcje;
        
        if cr_crapcje%found then

          -- Adicionado para melhoria de performance
          pc_buscar_conta (rw_crapcje.cdcooper
                          ,rw_crapcje.nrcpfcgc
                          ,vr_nrdconta);
          
          -- Se conta conjuge nao for a mais antiga e ou de
          -- menor numero, nao interessa e pula para proxima               
          if nvl(vr_nrdconta,0) <> rw_crapcje.nrdconta then
            close cr_crapcje;
            continue;
          end if;
          
          begin

            -- Se conjuge for delegado, conta da ass
            -- vai em direcao ao conjuge (procura na grupo_assembleia)
            if rw_crapcje.tpvincul in ('CD','DT','DS') then

              -- Busca grupo do coperado
              open cr_participa_grupo (rw_crapcje.cdcooper
                                      ,rw_crapcje.cdagenci 
                                      ,rw_crapcje.nrcpfcgc);
              fetch cr_participa_grupo into rw_participa_grupo;

              if cr_participa_grupo%found then

                vr_nrdgrupo := rw_participa_grupo.nrdgrupo;

                -- Garantia que ass esta em grupo (desnecessario)
                -- muda crapass de grupo
                if vr_table_insert.exists(rw_crapass.nrcpfcgc) then
                    
                  -- Para controle de populacao
                  vr_table_control(vr_table_insert(rw_crapass.nrcpfcgc).nrdgrupo).contador := vr_table_control(vr_table_insert(rw_crapass.nrcpfcgc).nrdgrupo).contador - 1;
                
                  -- Muda de grupo
                  vr_table_insert(rw_crapass.nrcpfcgc).nrdgrupo := vr_nrdgrupo;
                  
                  -- Para controle de populacao
                  vr_table_control(vr_nrdgrupo).contador := vr_table_control(vr_nrdgrupo).contador + 1;

                end if;

              end if;
                
              close cr_participa_grupo;
            
            -- Se conjuge for comite, conta da ass
            -- vai em direcao ao conjuge (procura na tab_memoria)
            elsif rw_crapcje.tpvincul in ('CL','CS','CM') then
              
              -- Necessario devido 'marido' e 'esposa' serem comites
              if vr_table_insert.exists(rw_crapcje.nrcpfcgc) then
                vr_nrdgrupo := vr_table_insert(rw_crapcje.nrcpfcgc).nrdgrupo;
              end if;
              
              -- Se conjuge nao foi locado e nao for nenhuma das funcoes
              -- de comite e delegado ele pode ser locado
              if vr_table_insert.exists(rw_crapass.nrcpfcgc) then
                    
                -- Para controle de populacao
                vr_table_control(vr_table_insert(rw_crapass.nrcpfcgc).nrdgrupo).contador := vr_table_control(vr_table_insert(rw_crapass.nrcpfcgc).nrdgrupo).contador - 1;
                
                -- Muda de grupo
                vr_table_insert(rw_crapass.nrcpfcgc).nrdgrupo := vr_nrdgrupo;
                  
                -- Para controle de populacao
                vr_table_control(vr_nrdgrupo).contador := vr_table_control(vr_nrdgrupo).contador + 1;

              end if;

            -- Se conjuge nao possui nenhuma funcao
            else

              -- Se conjuge nao foi locado e nao for nenhuma das funcoes
              -- de comite e delegado ele pode ser locado no grupo da ass
              if not vr_table_insert.exists(rw_crapcje.nrcpfcgc) then

                -- Para insert na tabela de grupos
                vr_table_insert(rw_crapcje.nrcpfcgc).cdcooper := rw_crapcje.cdcooper;
                vr_table_insert(rw_crapcje.nrcpfcgc).cdagenci := rw_crapcje.cdagenci;
                vr_table_insert(rw_crapcje.nrcpfcgc).nrdconta := rw_crapcje.nrdconta;
                vr_table_insert(rw_crapcje.nrcpfcgc).nrcpfcgc := rw_crapcje.nrcpfcgc;
                vr_table_insert(rw_crapcje.nrcpfcgc).idpessoa := rw_crapcje.idpessoa;
                vr_table_insert(rw_crapcje.nrcpfcgc).nrdgrupo := vr_nrdgrupo;
                vr_table_insert(rw_crapcje.nrcpfcgc).tpvincul := rw_crapcje.tpvincul;
                  
                -- Para controle de populacao
                vr_table_control(vr_nrdgrupo).contador := vr_table_control(vr_nrdgrupo).contador + 1;
                  
              -- Caso ja tenha sido locado
              -- ass vai em direcao ao cje
              else
                
                vr_nrdgrupo := vr_table_insert(rw_crapcje.nrcpfcgc).nrdgrupo;
                    
                -- Para controle de populacao
                vr_table_control(vr_table_insert(rw_crapass.nrcpfcgc).nrdgrupo).contador := vr_table_control(vr_table_insert(rw_crapass.nrcpfcgc).nrdgrupo).contador - 1;
                
                -- Muda de grupo
                vr_table_insert(rw_crapass.nrcpfcgc).nrdgrupo := vr_nrdgrupo;
                  
                -- Para controle de populacao
                vr_table_control(vr_nrdgrupo).contador := vr_table_control(vr_nrdgrupo).contador + 1;

              end if;
     
            end if;
            
          exception

            when others then
              
              vr_dscritic := 'Erro na AGRP0001.pc_distribui_conta_grupo (2) --> '|| sqlerrm;
              raise vr_exc_saida; 

          end;

        end if;

        close cr_crapcje;

      -- Posteriormente trata pessoa juridica
      -- no grupo com menor quantidade de pessoas
      elsif rw_crapass.inpessoa = 2 then

        begin

          -- Caso ainda nao tenha sido locado
          -- e colocado no grupo com menor qtd membros
          if not vr_table_insert.exists(rw_crapass.nrcpfcgc) then

            -- Para insert na tabela de grupos
            vr_table_insert(rw_crapass.nrcpfcgc).cdcooper := rw_crapass.cdcooper;
            vr_table_insert(rw_crapass.nrcpfcgc).cdagenci := rw_crapass.cdagenci;
            vr_table_insert(rw_crapass.nrcpfcgc).nrdconta := rw_crapass.nrdconta;
            vr_table_insert(rw_crapass.nrcpfcgc).nrcpfcgc := rw_crapass.nrcpfcgc;
            vr_table_insert(rw_crapass.nrcpfcgc).idpessoa := rw_crapass.idpessoa;
            vr_table_insert(rw_crapass.nrcpfcgc).nrdgrupo := vr_nrdgrupo;
            vr_table_insert(rw_crapass.nrcpfcgc).tpvincul := rw_crapass.tpvincul;
            
            -- Para controle de populacao
            vr_table_control(vr_nrdgrupo).contador := vr_table_control(vr_nrdgrupo).contador + 1;
            if rw_crapass.tpvincul in ('CL','CS','CM') then
              vr_table_comites(vr_nrdgrupo).contador := vr_table_comites(vr_nrdgrupo).contador + 1;
            end if;
            
          end if;
          
        exception

          when others then

            vr_dscritic := 'Erro na AGRP0001.pc_distribui_conta_grupo (3) --> '|| sqlerrm;
            raise vr_exc_saida;

        end;

      end if;

    end loop;

    -- Index de cpf / cnpj
    vr_idx := vr_table_insert.first;
    
    while vr_idx is not null
      
    loop

      begin
        
        -- Insere na tabela de grupos
        insert into tbevento_pessoa_grupos 
                    (cdcooper
                    ,cdagenci
                    ,nrdconta
                    ,nrcpfcgc
                    ,nrdgrupo
                    ,cdoperad_altera
                    ,dhalteracao
                    ,idpessoa)
             values (vr_table_insert(vr_idx).cdcooper
                    ,vr_table_insert(vr_idx).cdagenci
                    ,vr_table_insert(vr_idx).nrdconta
                    ,vr_table_insert(vr_idx).nrcpfcgc
                    ,vr_table_insert(vr_idx).nrdgrupo
                    ,pr_cdoperad
                    ,sysdate
                    ,vr_table_insert(vr_idx).idpessoa);
                    
        -- Atualiza tabela de resumo de grupos
        update tbevento_grupos
           set qtd_membros = qtd_membros + 1
         where cdcooper    = vr_table_insert(vr_idx).cdcooper
           and cdagenci    = vr_table_insert(vr_idx).cdagenci
           and nrdgrupo    = vr_table_insert(vr_idx).nrdgrupo;

      exception
        when dup_val_on_index then
          null;
        when others then
          vr_dscritic := 'Erro na AGRP0001.pc_distribui_conta_grupo (4) --> '|| sqlerrm;
          raise vr_exc_saida;
      end;
      
      begin
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
        values                        (vr_table_insert(vr_idx).cdcooper
                                      ,vr_table_insert(vr_idx).idpessoa
                                      ,vr_table_insert(vr_idx).nrdconta
                                      ,sysdate
                                      ,1 -- Primeira execucao sera como "Enviado"
                                      ,null
                                      ,null
                                      ,null
                                      ,vr_table_insert(vr_idx).nrdgrupo);                         
      exception
        when others then
          vr_dscritic := 'Erro na AGRP0001 - inserir registro na tbhistor_pessoa_grupos  --> '|| sqlerrm;
          raise vr_exc_saida;
      end;
        
      -- Avanca ao proximo cpf / cnpj
      vr_idx := vr_table_insert.next(vr_idx); 

    end loop;
    
    -- Gera log no início da execução
    pc_log_programa(pr_dstiplog   => 'F'         
                   ,pr_cdprograma => vr_cdprogra||trim(to_char(pr_cdagenci,'000')) 
                   ,pr_cdcooper   => pr_cdcooper
                   ,pr_tpexecucao => 0    
                   ,pr_flgsucesso => 1 
                   ,pr_idprglog   => vr_idprglog);

  exception
    
    when vr_exc_saida then
       
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
      
      -- Gera log no início da execução
      pc_log_programa(pr_dstiplog   => 'F'         
                     ,pr_cdprograma => vr_cdprogra||trim(to_char(pr_cdagenci,'000')) 
                     ,pr_cdcooper   => pr_cdcooper
                     ,pr_tpexecucao => 0     
                     ,pr_flgsucesso => 0
                     ,pr_idprglog   => vr_idprglog);

    when others then

      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na AGRP0001.pc_distribui_conta_grupo (5) --> '|| sqlerrm;
      
      -- Gera log no início da execução
      pc_log_programa(pr_dstiplog   => 'F'         
                     ,pr_cdprograma => vr_cdprogra||trim(to_char(pr_cdagenci,'000')) 
                     ,pr_cdcooper   => pr_cdcooper
                     ,pr_tpexecucao => 0    
                     ,pr_flgsucesso => 0 
                     ,pr_idprglog   => vr_idprglog);
      
  end pc_distribui_conta_grupo;
 
  procedure pc_atz_grp_agenci (pr_cdcooper  in crapass.cdcooper%type
                              ,pr_cdagenci  in crapass.cdagenci%type
                              ,pr_qtdgrupo  in number
                              ,pr_cdoperad  in crapope.cdoperad%type
                              ,pr_cdcritic out pls_integer
                              ,pr_dscritic out varchar2) is

  ---------------------------------------------------------------------------
  --
  --  Programa : pc_atz_grp_agenci
  --  Sistema  : Ayllos Web
  --  Autor    : Gabriel Marcos
  --  Data     : Agosto/2018                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Faz a limpeza dos grupos para redistribuicao
  --
  -- Alteracoes:
  --
  --------------------------------------------------------------------------  

    -- Loop principal para limpeza da tabela de grupos
    cursor cr_limpeza_grupos (pr_cdcooper in tbevento_pessoa_grupos.cdcooper%type
                             ,pr_cdagenci in tbevento_pessoa_grupos.cdagenci%type) is
    select grp.cdcooper
         , grp.cdagenci
         , grp.nrcpfcgc
         , grp.nrdgrupo
         , grp.nrdconta
         , grp.idpessoa
         , ass.tpvincul
      from tbevento_pessoa_grupos grp
         , crapass                ass
     where grp.cdcooper = pr_cdcooper
       and grp.cdagenci = pr_cdagenci
       and ass.cdcooper = grp.cdcooper
       and ass.cdagenci = grp.cdagenci
       and ass.nrdconta = grp.nrdconta
       and ass.nrcpfcgc = grp.nrcpfcgc;

    -- Verificacoes para membros que sao delegados
    cursor cr_atlz_grupos (pr_cdcooper in tbevento_pessoa_grupos.cdcooper%type
                          ,pr_cdagenci in tbevento_pessoa_grupos.cdagenci%type)is
    select grp.cdcooper
         , grp.cdagenci
         , grp.nrdgrupo
         , grp.nrcpfcgc
         , vig.cdfuncao
         , vig.dtinicio_vigencia
         , vig.rowid
         , max(grp.nrdgrupo) over (partition by grp.cdagenci) qtdregis
      from tbevento_pessoa_grupos     grp
         , tbcadast_vig_funcao_pessoa vig
     where grp.cdcooper = pr_cdcooper
       and grp.cdagenci = pr_cdagenci
       and vig.cdcooper = grp.cdcooper
       and vig.nrcpfcgc = grp.nrcpfcgc
       and vig.cdfuncao in ('DT','DS')
       and vig.dtfim_vigencia is null;
    rw_atlz_grupos cr_atlz_grupos%rowtype;
    
    -- Busca data de movimentacao da cooperativa
    cursor cr_crapdat (pr_cdcooper crapdat.cdcooper%type) is
    select dat.dtmvtolt
      from crapdat dat
     where dat.cdcooper = pr_cdcooper;
    rw_crapdat cr_crapdat%rowtype;
    
    -- Tabela de memoria que recebe dados para delete e update
    type typ_dados_grupos is record (cdcooper crapass.cdcooper%type
                                    ,cdagenci crapass.cdagenci%type
                                    ,nrcpfcgc crapass.nrcpfcgc%type
                                    ,nrdgrupo number);                       
    type typ_table_grupos is table of typ_dados_grupos index by varchar2(20);--binary_integer;  
    vr_table_grupos typ_table_grupos; 

    vr_idx varchar2(20);

    vr_cdcritic pls_integer;
    vr_dscritic varchar2(4000);
    vr_contador number := 0;
    vr_nmdgrupo varchar2(8);
    
  begin
    
    -- Busca data da cooperativa
    open cr_crapdat (pr_cdcooper);
    fetch cr_crapdat into rw_crapdat;
    
    -- Se nao encontrar aborta
    if cr_crapdat%notfound then
      
      close cr_crapdat;
      vr_dscritic := 'Data da cooperativa não cadastrada.';
      raise vr_exc_erro;

    end if;
    
    close cr_crapdat;

    -- Deleta todos exceto delegados
    for rw_limpeza_grupos in cr_limpeza_grupos (pr_cdcooper
                                               ,pr_cdagenci) loop
            
      -- Nao faz limpeza de delegados por que eles
      -- estao vinculados ao seu grupo
      if rw_limpeza_grupos.tpvincul in ('DT','DS','CD') then
        continue;
      end if;
      
      begin

        -- Armazena cooperados na tabela de memoria
        vr_table_grupos(rw_limpeza_grupos.nrcpfcgc).cdcooper := rw_limpeza_grupos.cdcooper;
        vr_table_grupos(rw_limpeza_grupos.nrcpfcgc).cdagenci := rw_limpeza_grupos.cdagenci;
        vr_table_grupos(rw_limpeza_grupos.nrcpfcgc).nrcpfcgc := rw_limpeza_grupos.nrcpfcgc;
        vr_table_grupos(rw_limpeza_grupos.nrcpfcgc).nrdgrupo := rw_limpeza_grupos.nrdgrupo;
        
      exception
        
        when others then
          
          vr_dscritic := 'Erro na AGRP0001.pc_atz_grp_agenci(1) --> '|| sqlerrm;
          raise vr_exc_saida;
          
      end;
 
    end loop;
    
    -- Index do cpf / cnpj
    vr_idx := vr_table_grupos.first;
    
    while vr_idx is not null
      
    loop

      begin
    
        -- Deleta cooperado
        delete
          from tbevento_pessoa_grupos
         where cdcooper = vr_table_grupos(vr_idx).cdcooper
           and cdagenci = vr_table_grupos(vr_idx).cdagenci
           and nrcpfcgc = vr_table_grupos(vr_idx).nrcpfcgc;
           
        -- Atualiza tabela de resumo de grupos
        update tbevento_grupos
           set flgsituacao = 0 -- Em andamento
             , qtd_membros = qtd_membros - 1
         where cdcooper    = vr_table_grupos(vr_idx).cdcooper
           and cdagenci    = vr_table_grupos(vr_idx).cdagenci
           and nrdgrupo    = vr_table_grupos(vr_idx).nrdgrupo;

      exception

        when others then
            
          vr_dscritic := 'Erro na AGRP0001.pc_atz_grp_agenci(2) --> '|| sqlerrm;
          raise vr_exc_saida;

      end;
      
      -- Avanca ao proximo cpf / cnpj
      vr_idx := vr_table_grupos.next(vr_idx); 

    end loop;

    -- Deleta grupo da tabela de descricao de grupos
    -- que for maior que o numero da nova redestribuicao
    -- tratamento para grupo desfeito
    begin 
      
      delete
        from tbevento_grupos
       where cdcooper = pr_cdcooper
         and cdagenci = pr_cdagenci
         and nrdgrupo > pr_qtdgrupo;
       
    exception
      
      when others then
        
        vr_dscritic := 'Erro na AGRP0001.pc_atz_grp_agenci(3) --> '|| sqlerrm;
        raise vr_exc_saida;
        
    end;

    -- Verifica se existe delegado em grupo
    open cr_atlz_grupos (pr_cdcooper
                        ,pr_cdagenci);
    fetch cr_atlz_grupos into rw_atlz_grupos;
    
    -- Se sim, faz verificacoes
    if cr_atlz_grupos%found then
      
      close cr_atlz_grupos;

      -- Tratamento para delegados e tabela de descricao de grupos
      for rw_atlz_grupos in cr_atlz_grupos (pr_cdcooper
                                           ,pr_cdagenci) loop
  
        -- Se o numero do maior grupo for igual ao numero de grupos
        -- da nova redistribuicao, aborta loop
        if    pr_qtdgrupo = rw_atlz_grupos.qtdregis then
          
          exit;
          
        -- Tratamento para grupo desfeito
        elsif pr_qtdgrupo < rw_atlz_grupos.qtdregis then
        
          -- Se grupo do delegado foi desfeito, atribui
          -- fim da vigencia para a funcao de delegado
          if rw_atlz_grupos.nrdgrupo > pr_qtdgrupo then

            -- Deleta delegado da tabela de grupos
            delete
              from tbevento_pessoa_grupos
             where cdcooper = rw_atlz_grupos.cdcooper
               and cdagenci = rw_atlz_grupos.cdagenci
               and nrcpfcgc = rw_atlz_grupos.nrcpfcgc;

            -- Inativa cargo de delegado
            tela_pessoa.pc_inativa_cargos (pr_cdcooper          => rw_atlz_grupos.cdcooper
                                          ,pr_nrcpfcgc          => rw_atlz_grupos.nrcpfcgc
                                          ,pr_cdfuncao          => rw_atlz_grupos.cdfuncao
                                          ,pr_dtinicio_vigencia => rw_atlz_grupos.dtinicio_vigencia
                                          ,pr_dtfim_vigencia    => rw_crapdat.dtmvtolt
                                          ,pr_nrdrowid          => rw_atlz_grupos.rowid
                                          ,pr_cdoperad          => pr_cdoperad
                                          ,pr_cdcritic          => vr_cdcritic
                                          ,pr_dscritic          => vr_dscritic);
                              
            if nvl(vr_cdcritic,0) > 0 or trim(vr_dscritic) is not null then
              raise vr_exc_erro;
            end if;

          end if;

        -- Tratamento para formacao de novo grupo
        elsif pr_qtdgrupo > rw_atlz_grupos.qtdregis then

          loop
            
            exit when (pr_qtdgrupo = vr_contador);
         
            vr_contador := vr_contador + 1;
            vr_nmdgrupo := 'PA'||trim(to_char(pr_cdagenci,'000'))||'-'||trim(to_char(vr_contador,'00'));
       
            begin
                
              insert
                into tbevento_grupos
              values (rw_atlz_grupos.cdcooper
                     ,rw_atlz_grupos.cdagenci
                     ,vr_contador
                     ,vr_nmdgrupo
                     ,pr_cdoperad
                     ,sysdate
                     ,0
                     ,0);
                     
            exception
                
              when dup_val_on_index then
                  
                  update tbevento_grupos
                     set flgsituacao = 0 -- Em andamento
                   where cdcooper    = rw_atlz_grupos.cdcooper
                     and cdagenci    = rw_atlz_grupos.cdagenci
                     and nrdgrupo    = vr_contador;
                  
              when others then
                
                -- Montar mensagem de critica
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao inserir grupo! (1) ' || SQLERRM;
                -- volta para o programa chamador
                raise vr_exc_erro;
                
            end;
              
          end loop;
                
          -- Sair do loop
          exit;

        end if;

      end loop;
    
    -- Se nao existe delegado na agencia
    -- todos os grupos devem ser recriados
    else
      
      close cr_atlz_grupos;
     
      loop
              
        exit when (pr_qtdgrupo = vr_contador);
                   
        vr_contador := vr_contador + 1;
        vr_nmdgrupo := 'PA'||trim(to_char(pr_cdagenci,'000'))||'-'||trim(to_char(vr_contador,'00'));
                    
        begin
                          
          insert
            into tbevento_grupos
          values (pr_cdcooper
                 ,pr_cdagenci
                 ,vr_contador
                 ,vr_nmdgrupo
                 ,pr_cdoperad
                 ,sysdate
                 ,0
                 ,0);
                               
        exception
                          
          when dup_val_on_index then
                            
            update tbevento_grupos
               set flgsituacao = 0 -- Em andamento
                 , qtd_membros = 0
             where cdcooper    = rw_atlz_grupos.cdcooper
               and cdagenci    = rw_atlz_grupos.cdagenci
               and nrdgrupo    = vr_contador;
                 
          when others then
                          
            -- Montar mensagem de critica
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao inserir grupo! (2) ' || SQLERRM;
            -- volta para o programa chamador
            raise vr_exc_erro;
                          
        end;
                        
      end loop;
     
    end if;
    
    --commit;

  exception
    
    when vr_exc_erro then
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'AGRP0001.pc_atz_grp_agenci: ' || vr_dscritic;
    
    when others then
      
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratado: AGRP0001.pc_atz_grp_agenci: '||sqlerrm;

  end pc_atz_grp_agenci;
  
  procedure pc_agencia_conta (pr_cdcooper   in crapass.cdcooper%type
                             ,pr_nrdconta   in crapass.nrdconta%type
                             ,pr_retxml in out nocopy XMLType
                             ,pr_cdcritic  out varchar2
                             ,pr_dscritic  out varchar2) is

  ---------------------------------------------------------------------------
  --
  --  Programa : pc_agencia_conta
  --  Sistema  : Ayllos Web
  --  Autor    : Gabriel Marcos
  --  Data     : Agosto/2018                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Alterar a agencia do cooperado e relocar em grupo
  --
  -- Alteracoes:
  --
  --------------------------------------------------------------------------  

    -- Busca cooperado na tabela de associados
    cursor cr_crapass (pr_cdcooper in crapass.cdcooper%type
                      ,pr_nrdconta in crapass.nrdconta%type) is
    select ass.cdcooper
         , ass.nrcpfcgc
         , ass.nrdconta
         , ass.cdagenci
         , pes.idpessoa
      from crapass         ass
         , tbcadast_pessoa pes
     where ass.cdcooper = pr_cdcooper
       and ass.nrdconta = pr_nrdconta
       and pes.nrcpfcgc = ass.nrcpfcgc;
    rw_crapass cr_crapass%rowtype;

    -- Verifica se conta analisada participa de grupo
    cursor cr_buscar_cooperado (pr_cdcooper in crapass.cdcooper%type
                               ,pr_nrcpfcgc in crapass.nrcpfcgc%type) is
    select grp.cdcooper
         , grp.cdagenci
         , grp.nrdconta
         , grp.nrcpfcgc
         , grp.nrdgrupo
         , grp.idpessoa
      from tbevento_pessoa_grupos grp
     where grp.cdcooper = pr_cdcooper
       and grp.nrcpfcgc = pr_nrcpfcgc;
    rw_buscar_cooperado cr_buscar_cooperado%rowtype;
    rw_buscar_conjuge   cr_buscar_cooperado%rowtype;
    
    -- Verifica se cooperado possui cargo de delegado
    cursor cr_busca_funcao (pr_cdcooper in tbevento_pessoa_grupos.cdcooper%type
                           ,pr_nrcpfcgc in tbevento_pessoa_grupos.nrcpfcgc%type) is
    select vig.cdcooper
         , vig.nrcpfcgc
         , vig.cdfuncao
         , vig.dtinicio_vigencia
         , vig.rowid
      from tbcadast_vig_funcao_pessoa vig
     where vig.cdcooper  = pr_cdcooper
       and vig.nrcpfcgc  = pr_nrcpfcgc
       and vig.cdfuncao in ('DT','DS')
       and vig.dtfim_vigencia is null;
    rw_busca_funcao cr_busca_funcao%rowtype;
    
    -- Analisa grupo com menor qtd membros
    cursor cr_busca_grupo_novo (pr_cdcooper in tbevento_grupos.cdcooper%type
                               ,pr_cdagenci in tbevento_grupos.cdagenci%type) is
    select dsc.nrdgrupo
      from tbevento_grupos dsc
     where dsc.cdcooper = pr_cdcooper
       and dsc.cdagenci = pr_cdagenci
     order
        by dsc.qtd_membros;
    rw_busca_grupo_novo cr_busca_grupo_novo%rowtype;
   
    -- Busca data de movimentacao
    cursor cr_crapdat (pr_cdcooper crapdat.cdcooper%type) is
    select dat.dtmvtolt
      from crapdat dat
     where dat.cdcooper = pr_cdcooper;
    rw_crapdat cr_crapdat%rowtype;
    
    vr_nrdgrupo number;
    vr_nrdrowid rowid;

  begin
    
    -- Analisa parametros de entrada
    if    pr_cdcooper is null then
      vr_dscritic := 'O número da cooperativa deve ser informado.';
      raise vr_exc_erro;
    elsif pr_nrdconta is null then
      vr_dscritic := 'O número da conta deve ser informado.';
      raise vr_exc_erro;
    end if;

    -- Busca cooperado na tabela de associados
    open cr_crapass (pr_cdcooper
                    ,pr_nrdconta);
    fetch cr_crapass into rw_crapass;

    -- Se nao encontrou aborta
    if cr_crapass%notfound then
      close cr_crapass;
      vr_dscritic := 'Cooperado não encontrado na tabela de associados.';
      raise vr_exc_erro;
    end if;
    
    close cr_crapass;
  
    -- Buscar cooperado na tabela de grupos
    open cr_buscar_cooperado (rw_crapass.cdcooper
                             ,rw_crapass.nrcpfcgc);
    fetch cr_buscar_cooperado into rw_buscar_cooperado;
    
    -- Aborta se nao encontrar
    if cr_buscar_cooperado%notfound then
      close cr_buscar_cooperado;
      vr_dscritic := 'Cooperado não encontrado na tabela de grupos.';
      raise vr_exc_erro;
    end if;
    
    close cr_buscar_cooperado;
    
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root',  pr_posicao => 0, pr_tag_nova => 'Dados', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'param', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    
    -- Se contas forem diferentes, a conta que mudou de PA
    -- nao estava locada em um grupo (nao era a mais antiga)
    if    rw_crapass.nrdconta <> rw_buscar_cooperado.nrdconta then
             
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'cdcooper', pr_tag_cont => rw_crapass.cdcooper,      pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'idpessoa', pr_tag_cont => rw_crapass.idpessoa,      pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'cdagenci', pr_tag_cont => rw_crapass.cdagenci,      pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'nrdconta', pr_tag_cont => rw_crapass.nrdconta,      pr_des_erro => vr_dscritic);                           
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'nrctamd5', pr_tag_cont => md5(rw_crapass.nrdconta), pr_des_erro => vr_dscritic); 
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'nrdgrupo', pr_tag_cont => null,                     pr_des_erro => vr_dscritic);                         
 
    -- Se contas forem iguais, a conta que mudou de PA
    -- estava locada em um grupo (era a mais antiga)
    elsif rw_crapass.nrdconta = rw_buscar_cooperado.nrdconta then

      -- Retira da tabela de grupos
      begin
        delete
          from tbevento_pessoa_grupos
         where cdcooper = rw_buscar_cooperado.cdcooper
           and nrdconta = rw_buscar_cooperado.nrdconta;
      exception
        when others then
          vr_dscritic := 'Erro ao excluir cooperado de grupo: '||sqlerrm;
          raise vr_exc_erro;
      end;
        
      -- Atualiza tabela de resumo de grupos
      begin
        update tbevento_grupos
           set qtd_membros = qtd_membros - 1
         where cdcooper = rw_buscar_cooperado.cdcooper
           and cdagenci = rw_buscar_cooperado.cdagenci
           and nrdgrupo = rw_buscar_cooperado.nrdgrupo;
      exception
        when others then
          vr_dscritic := 'Erro ao atualizar tabela de descricao de grupos(1): '||sqlerrm;
          raise vr_exc_erro;
      end;

      -- Se possuir funcao de delegado, deve inativa-la
      open cr_busca_funcao (rw_buscar_cooperado.cdcooper
                           ,rw_buscar_cooperado.nrcpfcgc);
      fetch cr_busca_funcao into rw_busca_funcao;

      if cr_busca_funcao%found then
          
        close cr_busca_funcao;

        -- Busca data da cooperativa
        open cr_crapdat (pr_cdcooper);
        fetch cr_crapdat into rw_crapdat;
          
        -- Se nao encontrar aborta
        if cr_crapdat%notfound then
          close cr_crapdat;
          vr_dscritic := 'Data da cooperativa não cadastrada.';
          raise vr_exc_erro;
        end if;
          
        close cr_crapdat;
          
        -- Inativa cargo de delegado
        tela_pessoa.pc_inativa_cargos (pr_cdcooper          => rw_busca_funcao.cdcooper
                                      ,pr_nrcpfcgc          => rw_busca_funcao.nrcpfcgc
                                      ,pr_cdfuncao          => rw_busca_funcao.cdfuncao
                                      ,pr_dtinicio_vigencia => rw_busca_funcao.dtinicio_vigencia
                                      ,pr_dtfim_vigencia    => rw_crapdat.dtmvtolt
                                      ,pr_nrdrowid          => rw_busca_funcao.rowid
                                      ,pr_cdoperad          => 1
                                      ,pr_cdcritic          => vr_cdcritic
                                      ,pr_dscritic          => vr_dscritic);
                                    
        if nvl(vr_cdcritic,0) > 0 or trim(vr_dscritic) is not null then
          raise vr_exc_erro;
        end if;
        
      end if;

      -- Busca conjuge na agencia nova
      open cr_crapcje (rw_crapass.cdcooper
                      ,rw_crapass.cdagenci -- Agencia nova
                      ,rw_crapass.nrcpfcgc);
      fetch cr_crapcje into rw_crapcje;
        
      -- Caso encontre conjuge
      if cr_crapcje%found then
        
        -- Busca grupo do conjuge
        open cr_buscar_cooperado (rw_crapcje.cdcooper
                                 ,rw_crapcje.nrcpfcgc);
        fetch cr_buscar_cooperado into rw_buscar_conjuge;
          
        -- Alocar no grupo do conjuge
        if rw_buscar_conjuge.cdagenci = rw_crapass.cdagenci then
          vr_nrdgrupo := rw_buscar_conjuge.nrdgrupo;
        end if;

        close cr_buscar_cooperado;

      end if;
        
      close cr_crapcje;
        
      -- Caso de alguma forma grupo nao tenha sido atribuido
      if vr_nrdgrupo is null then
              
        open cr_busca_grupo_novo (rw_crapass.cdcooper
                                 ,rw_crapass.cdagenci);
        fetch cr_busca_grupo_novo into rw_busca_grupo_novo;
          
        -- Significa que agencia nao possui grupos
        if cr_busca_grupo_novo%notfound then
          close cr_busca_grupo_novo;
          vr_dscritic := 'Agência não possui um grupo formado.';
          raise vr_exc_erro; 
        end if;
          
        close cr_busca_grupo_novo;
            
        vr_nrdgrupo := rw_busca_grupo_novo.nrdgrupo;
            
      end if;

      -- Inserir em novo grupo de novo PA
      begin
        insert into tbevento_pessoa_grupos
                    (cdcooper
                    ,cdagenci
                    ,nrdconta
                    ,nrcpfcgc
                    ,nrdgrupo
                    ,cdoperad_altera
                    ,dhalteracao
                    ,idpessoa)
             values (rw_crapass.cdcooper
                   , rw_crapass.cdagenci -- Agencia nova
                   , rw_crapass.nrdconta
                   , rw_crapass.nrcpfcgc
                   , vr_nrdgrupo
                   , 1
                   , sysdate
                   , rw_crapass.idpessoa);
      exception
        when others then
          vr_dscritic := 'Erro ao inserir em grupo: '||sqlerrm;
          raise vr_exc_erro;
      end;
        
      -- Atualiza tabela de resumo de grupos
      begin
        update tbevento_grupos
           set qtd_membros = qtd_membros + 1
         where cdcooper = rw_crapass.cdcooper
           and cdagenci = rw_crapass.cdagenci
           and nrdgrupo = vr_nrdgrupo;
      exception
        when others then
          vr_dscritic := 'Erro ao atualizar tabela de descricao de grupos(2): '||sqlerrm;
          raise vr_exc_erro;
      end;

      -- Gravar log de insercao de funcao
      gene0001.pc_gera_log(pr_cdcooper => rw_buscar_cooperado.cdcooper
                          ,pr_cdoperad => 1
                          ,pr_dscritic => null
                          ,pr_dsorigem => 'AIMARO WEB'
                          ,pr_dstransa => 'Agencia alterada.'||
                                          ' Grupo Antigo: '||rw_buscar_cooperado.cdagenci||'-'||rw_buscar_cooperado.nrdgrupo||
                                          ' Grupo Novo: '||rw_crapass.cdagenci||'-'||vr_nrdgrupo
                          ,pr_dttransa => trunc(sysdate)
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => gene0002.fn_busca_time
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'AGRP0001'
                          ,pr_nrdconta => rw_buscar_cooperado.nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
                          
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'cdcooper', pr_tag_cont => rw_crapass.cdcooper,      pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'idpessoa', pr_tag_cont => rw_crapass.idpessoa,      pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'cdagenci', pr_tag_cont => rw_crapass.cdagenci,      pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'nrdconta', pr_tag_cont => rw_crapass.nrdconta,      pr_des_erro => vr_dscritic);                           
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'nrctamd5', pr_tag_cont => md5(rw_crapass.nrdconta), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'nrdgrupo', pr_tag_cont => vr_nrdgrupo,              pr_des_erro => vr_dscritic);                            
                        
    end if;

    commit;
    
  exception
    
    when vr_exc_erro then
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'AGRP0001.pc_agencia_conta: ' || vr_dscritic;
    
    when others then
      
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratado: AGRP0001.pc_agencia_conta: '||sqlerrm;
      
  end pc_agencia_conta;
  
  procedure pc_demitir_conta (pr_cdcooper   in crapass.cdcooper%type
                             ,pr_nrdconta   in crapass.nrdconta%type
                             ,pr_retxml in out nocopy XMLType
                             ,pr_cdcritic  out varchar2
                             ,pr_dscritic  out varchar2) is

  ---------------------------------------------------------------------------
  --
  --  Programa : pc_demitir_conta
  --  Sistema  : Ayllos Web
  --  Autor    : Gabriel Marcos
  --  Data     : Agosto/2018                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Demitir cooperado e verificar necessidade de relocar em grupo
  --
  -- Alteracoes:
  --
  --------------------------------------------------------------------------  

    -- Busca cooperado na tabela de associados
    cursor cr_crapass (pr_cdcooper in crapass.cdcooper%type
                      ,pr_nrdconta in crapass.nrdconta%type) is
    select ass.cdcooper
         , ass.nrcpfcgc
         , ass.nrdconta
         , ass.cdagenci
         , pes.idpessoa
      from crapass         ass
         , tbcadast_pessoa pes
     where ass.cdcooper = pr_cdcooper
       and ass.nrdconta = pr_nrdconta
       and pes.nrcpfcgc = ass.nrcpfcgc;
    rw_crapass cr_crapass%rowtype;

    -- Verifica se conta analisada participa de grupo
    cursor cr_tabela_de_grupos (pr_cdcooper in crapass.cdcooper%type
                               ,pr_nrcpfcgc in crapass.nrcpfcgc%type) is
    select grp.cdcooper
         , grp.cdagenci
         , grp.nrdconta
         , grp.nrcpfcgc
         , grp.nrdgrupo
         , grp.idpessoa
      from tbevento_pessoa_grupos grp
     where grp.cdcooper = pr_cdcooper
       and grp.nrcpfcgc = pr_nrcpfcgc;
    rw_tabela_de_grupos cr_tabela_de_grupos%rowtype;
    rw_buscar_conjuge   cr_tabela_de_grupos%rowtype;
    
    -- Verifica se cooperado possui cargo de delegado
    cursor cr_busca_funcao (pr_cdcooper in tbevento_pessoa_grupos.cdcooper%type
                           ,pr_nrcpfcgc in tbevento_pessoa_grupos.nrcpfcgc%type) is
    select vig.cdcooper
         , vig.nrcpfcgc
         , vig.cdfuncao
         , vig.dtinicio_vigencia
         , vig.rowid
      from tbcadast_vig_funcao_pessoa vig
     where vig.cdcooper  = pr_cdcooper
       and vig.nrcpfcgc  = pr_nrcpfcgc
       and vig.cdfuncao in ('DT','DS')
       and vig.dtfim_vigencia is null;
    rw_busca_funcao cr_busca_funcao%rowtype;
    
    -- Analisar se cooperado possui outra conta ativa para relocacao
    cursor cr_buscar_conta_ativa (pr_cdcooper in crapass.cdcooper%type
                                 ,pr_nrdconta in crapass.nrdconta%type
                                 ,pr_nrcpfcgc in crapass.nrcpfcgc%type) is
    select ass.cdcooper
         , ass.cdagenci
         , ass.nrdconta
         , ass.nrcpfcgc
         , pes.idpessoa
      from crapass ass
         , tbcadast_pessoa pes
     where ass.cdcooper  = pr_cdcooper
       and ass.nrcpfcgc  = pr_nrcpfcgc
       and ass.nrdconta <> pr_nrdconta
       and ass.dtdemiss is null
       and pes.nrcpfcgc = ass.nrcpfcgc
     order
        by ass.dtadmiss
         , ass.nrdconta;
    rw_buscar_conta_ativa cr_buscar_conta_ativa%rowtype;

    -- Analisa grupo com menor qtd membros
    cursor cr_busca_grupo_novo (pr_cdcooper in tbevento_grupos.cdcooper%type
                               ,pr_cdagenci in tbevento_grupos.cdagenci%type) is
    select dsc.nrdgrupo
      from tbevento_grupos dsc
     where dsc.cdcooper = pr_cdcooper
       and dsc.cdagenci = pr_cdagenci
     order
        by dsc.qtd_membros;
    rw_busca_grupo_novo cr_busca_grupo_novo%rowtype;
   
    -- Busca data de movimentacao
    cursor cr_crapdat (pr_cdcooper crapdat.cdcooper%type) is
    select dat.dtmvtolt
      from crapdat dat
     where dat.cdcooper = pr_cdcooper;
    rw_crapdat cr_crapdat%rowtype;
    
    vr_nrdgrupo number;
    vr_nrdrowid rowid;
    
  begin
    
    -- Analisa parametros de entrada
    if    pr_cdcooper is null then
      vr_dscritic := 'O número da cooperativa deve ser informado.';
      raise vr_exc_erro;
    elsif pr_nrdconta is null then
      vr_dscritic := 'O número da conta deve ser informado.';
      raise vr_exc_erro;
    end if;

    -- Busca cooperado na tabela de associados
    open cr_crapass (pr_cdcooper
                    ,pr_nrdconta);
    fetch cr_crapass into rw_crapass;

    -- Se nao encontrou aborta
    if cr_crapass%notfound then
      close cr_crapass;
      vr_dscritic := 'Cooperado não encontrado na tabela de associados.';
      raise vr_exc_erro;
    end if;
    
    close cr_crapass;

    -- Buscar cooperado na tabela de grupos
    open cr_tabela_de_grupos (rw_crapass.cdcooper
                             ,rw_crapass.nrcpfcgc);
    fetch cr_tabela_de_grupos into rw_tabela_de_grupos;
    
    -- Aborta caso nao encontre cooperado
    if cr_tabela_de_grupos%notfound then
      close cr_tabela_de_grupos;
      vr_dscritic := 'Cooperado não encontrado na tabela de grupos.';
      raise vr_exc_erro;
    end if;
      
    close cr_tabela_de_grupos;

    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root',  pr_posicao => 0, pr_tag_nova => 'Dados', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'param', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    -- Conta demitida mas continua ativa na tabela de grupos
    if    rw_tabela_de_grupos.nrdconta <> rw_crapass.nrdconta then
       
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'cdcooper', pr_tag_cont => rw_crapass.cdcooper,          pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'idpessoa', pr_tag_cont => rw_tabela_de_grupos.idpessoa, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'cdagenci', pr_tag_cont => null,                         pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'nrdconta', pr_tag_cont => rw_crapass.nrdconta,          pr_des_erro => vr_dscritic);                           
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'nrctamd5', pr_tag_cont => md5(rw_crapass.nrdconta),     pr_des_erro => vr_dscritic);                           
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'nrdgrupo', pr_tag_cont => null,                         pr_des_erro => vr_dscritic);                           
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'cdstatus', pr_tag_cont => '1',                          pr_des_erro => vr_dscritic);                           
    
    -- Conta demitida era a conta que estava na tabela de grupos
    elsif rw_tabela_de_grupos.nrdconta  = rw_crapass.nrdconta then

      -- Retira da tabela de grupos
      begin
        delete
          from tbevento_pessoa_grupos
         where cdcooper = rw_tabela_de_grupos.cdcooper
           and nrdconta = rw_tabela_de_grupos.nrdconta;
      exception
        when others then
          vr_dscritic := 'Erro ao excluir cooperado de grupo: '||sqlerrm;
          raise vr_exc_erro;
      end;
        
      -- Atualiza tabela de resumo de grupos
      begin
        update tbevento_grupos
           set qtd_membros = qtd_membros - 1
         where cdcooper = rw_tabela_de_grupos.cdcooper
           and cdagenci = rw_tabela_de_grupos.cdagenci
           and nrdgrupo = rw_tabela_de_grupos.nrdgrupo;
      exception
        when others then
          vr_dscritic := 'Erro ao atualizar tabela de descricao de grupos(1): '||sqlerrm;
          raise vr_exc_erro;
      end;

      -- Gravar log de insercao de funcao
      gene0001.pc_gera_log(pr_cdcooper => rw_tabela_de_grupos.cdcooper
                          ,pr_cdoperad => 1
                          ,pr_dscritic => null
                          ,pr_dsorigem => 'AIMARO WEB'
                          ,pr_dstransa => 'Conta Demitida: removida de grupo.'
                          ,pr_dttransa => trunc(sysdate)
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => gene0002.fn_busca_time
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'AGRP0001'
                          ,pr_nrdconta => rw_tabela_de_grupos.nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);

      -- Analisar se cooperado possui outra conta ativa para relocacao
      open cr_buscar_conta_ativa (rw_tabela_de_grupos.cdcooper
                                 ,rw_tabela_de_grupos.nrdconta
                                 ,rw_tabela_de_grupos.nrcpfcgc);
      fetch cr_buscar_conta_ativa into rw_buscar_conta_ativa;

      if    cr_buscar_conta_ativa%notfound then

        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'cdcooper', pr_tag_cont => rw_tabela_de_grupos.cdcooper,      pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'idpessoa', pr_tag_cont => rw_tabela_de_grupos.idpessoa,      pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'cdagenci', pr_tag_cont => null,                              pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'nrdconta', pr_tag_cont => rw_tabela_de_grupos.nrdconta,      pr_des_erro => vr_dscritic);                           
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'nrctamd5', pr_tag_cont => md5(rw_tabela_de_grupos.nrdconta), pr_des_erro => vr_dscritic);                           
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'nrdgrupo', pr_tag_cont => null,                              pr_des_erro => vr_dscritic);                           
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'cdstatus', pr_tag_cont => '0',                               pr_des_erro => vr_dscritic);                           

      else

        if rw_buscar_conta_ativa.cdagenci <> rw_tabela_de_grupos.cdagenci then

          -- Se possuir funcao de delegado, deve inativa-la
          open cr_busca_funcao (rw_buscar_conta_ativa.cdcooper
                               ,rw_buscar_conta_ativa.nrcpfcgc);
          fetch cr_busca_funcao into rw_busca_funcao;

          -- Cooperado deve possuir funcao de delegado ativa, logica so ira inativar
          -- funcao se ele nao possuir a sua conta mais antiga dentro do mesmo PA
          if cr_busca_funcao%found then
              
            -- Busca data da cooperativa
            open cr_crapdat (pr_cdcooper);
            fetch cr_crapdat into rw_crapdat;
              
            -- Se nao encontrar aborta
            if cr_crapdat%notfound then
              close cr_crapdat;
              vr_dscritic := 'Data da cooperativa não cadastrada.';
              raise vr_exc_erro;
            end if;
              
            close cr_crapdat;
              
            -- Inativa cargo de delegado
            tela_pessoa.pc_inativa_cargos (pr_cdcooper          => rw_busca_funcao.cdcooper
                                          ,pr_nrcpfcgc          => rw_busca_funcao.nrcpfcgc
                                          ,pr_cdfuncao          => rw_busca_funcao.cdfuncao
                                          ,pr_dtinicio_vigencia => rw_busca_funcao.dtinicio_vigencia
                                          ,pr_dtfim_vigencia    => rw_crapdat.dtmvtolt
                                          ,pr_nrdrowid          => rw_busca_funcao.rowid
                                          ,pr_cdoperad          => 1
                                          ,pr_cdcritic          => vr_cdcritic
                                          ,pr_dscritic          => vr_dscritic);
                 
            -- Aborta em caso de critica                       
            if nvl(vr_cdcritic,0) > 0 or trim(vr_dscritic) is not null then
              raise vr_exc_erro;
            end if;

          end if;
          
          close cr_busca_funcao;

          -- Busca conjuge na agencia nova
          open cr_crapcje (rw_buscar_conta_ativa.cdcooper
                          ,rw_buscar_conta_ativa.cdagenci
                          ,rw_buscar_conta_ativa.nrcpfcgc);
          fetch cr_crapcje into rw_crapcje;
            
          -- Caso encontre conjuge
          if cr_crapcje%found then
            
            -- Busca grupo do conjuge
            open cr_tabela_de_grupos (rw_crapcje.cdcooper
                                     ,rw_crapcje.nrcpfcgc);
            fetch cr_tabela_de_grupos into rw_buscar_conjuge;
            -- Alocar no grupo do conjuge
            
            if cr_tabela_de_grupos%found then
              vr_nrdgrupo := rw_buscar_conjuge.nrdgrupo;
            end if;
            
            close cr_tabela_de_grupos;
            
          end if;
            
          close cr_crapcje;

        -- Se nao mudou de agencia mantem no mesmo grupo
        elsif rw_buscar_conta_ativa.cdagenci = rw_tabela_de_grupos.cdagenci then
        
          vr_nrdgrupo := rw_tabela_de_grupos.nrdgrupo;
          
        end if;
        
        -- Caso de alguma forma grupo nao tenha sido atribuido
        if vr_nrdgrupo is null then
              
          open cr_busca_grupo_novo (rw_buscar_conta_ativa.cdcooper
                                   ,rw_buscar_conta_ativa.cdagenci);
          fetch cr_busca_grupo_novo into rw_busca_grupo_novo;
          
          -- Significa que agencia nao possui grupos
          if cr_busca_grupo_novo%notfound then
            close cr_busca_grupo_novo;
            vr_dscritic := 'Agência não possui um grupo formado.';
            raise vr_exc_erro; 
          end if;
          
          close cr_busca_grupo_novo;
            
          vr_nrdgrupo := rw_busca_grupo_novo.nrdgrupo;
            
        end if;   

        -- Inserir em novo grupo de novo PA
        begin
          insert into tbevento_pessoa_grupos
                      (cdcooper
                     , cdagenci
                     , nrdconta
                     , nrcpfcgc
                     , nrdgrupo
                     , cdoperad_altera
                     , dhalteracao
                     , idpessoa)
               values (rw_buscar_conta_ativa.cdcooper
                     , rw_buscar_conta_ativa.cdagenci -- Agencia nova
                     , rw_buscar_conta_ativa.nrdconta
                     , rw_buscar_conta_ativa.nrcpfcgc
                     , vr_nrdgrupo
                     , 1
                     , sysdate
                     , rw_buscar_conta_ativa.idpessoa);
        exception
          when others then
            vr_dscritic := 'Erro ao inserir em grupo(1): '||sqlerrm;
            raise vr_exc_erro;
        end;
          
        -- Atualiza tabela de resumo de grupos
        begin
          update tbevento_grupos
             set qtd_membros = qtd_membros + 1
           where cdcooper = rw_buscar_conta_ativa.cdcooper
             and cdagenci = rw_buscar_conta_ativa.cdagenci
             and nrdgrupo = vr_nrdgrupo;
        exception
          when others then
            vr_dscritic := 'Erro ao atualizar tabela de descricao de grupos(2): '||sqlerrm;
            raise vr_exc_erro;
        end;
          
        -- Gravar log de insercao de funcao
        gene0001.pc_gera_log(pr_cdcooper => rw_buscar_conta_ativa.cdcooper
                            ,pr_cdoperad => 1
                            ,pr_dscritic => null
                            ,pr_dsorigem => 'AIMARO WEB'
                            ,pr_dstransa => 'Conta Demitida: cooperado relocado em grupo.'
                            ,pr_dttransa => trunc(sysdate)
                            ,pr_flgtrans => 1
                            ,pr_hrtransa => gene0002.fn_busca_time
                            ,pr_idseqttl => 1
                            ,pr_nmdatela => 'AGRP0001'
                            ,pr_nrdconta => rw_buscar_conta_ativa.nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);

        -- Conta removida de grupo e outra conta relocada em grupo        
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'cdcooper', pr_tag_cont => rw_buscar_conta_ativa.cdcooper,      pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'idpessoa', pr_tag_cont => rw_buscar_conta_ativa.idpessoa,      pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'cdagenci', pr_tag_cont => rw_buscar_conta_ativa.cdagenci,      pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'nrdconta', pr_tag_cont => rw_tabela_de_grupos.nrdconta,        pr_des_erro => vr_dscritic);                           
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'nrctamd5', pr_tag_cont => md5(rw_buscar_conta_ativa.nrdconta), pr_des_erro => vr_dscritic);                           
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'nrdgrupo', pr_tag_cont => vr_nrdgrupo,                         pr_des_erro => vr_dscritic);                           
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'cdstatus', pr_tag_cont => '1',                                 pr_des_erro => vr_dscritic);                           
     
      end if; --cr_buscar_conta_ativa;

    end if;
    
    commit;

  exception

    when vr_exc_erro then
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'AGRP0001.pc_demitir_conta: ' || vr_dscritic;
    
    when others then
      
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratado: AGRP0001.pc_demitir_conta: '||sqlerrm;
      
  end pc_demitir_conta;

  procedure pc_admitir_conta (pr_cdcooper   in crapass.cdcooper%type
                             ,pr_nrdconta   in crapass.nrdconta%type
                             ,pr_retxml in out nocopy XMLType
                             ,pr_cdcritic  out varchar2
                             ,pr_dscritic  out varchar2) is

  ---------------------------------------------------------------------------
  --
  --  Programa : pc_admitir_conta
  --  Sistema  : Ayllos Web
  --  Autor    : Gabriel Marcos
  --  Data     : Agosto/2018                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Admitir cooperados e verificar necessidade de relocar em grupo
  --
  -- Alteracoes:
  --
  --------------------------------------------------------------------------  

    -- Busca cooperado na tabela de associados
    cursor cr_crapass (pr_cdcooper in crapass.cdcooper%type
                      ,pr_nrdconta in crapass.nrdconta%type) is
    select ass.cdcooper
         , ass.nrcpfcgc
         , ass.nrdconta
         , pes.idpessoa
         , ass.cdagenci
         , ass.dtadmiss
      from crapass         ass
         , tbcadast_pessoa pes
     where ass.cdcooper = pr_cdcooper
       and ass.nrdconta = pr_nrdconta
       and pes.nrcpfcgc = ass.nrcpfcgc;
    rw_crapass cr_crapass%rowtype;

    -- Verifica se conta analisada participa de grupo
    cursor cr_tabela_de_grupos (pr_cdcooper in crapass.cdcooper%type
                               ,pr_nrcpfcgc in crapass.nrcpfcgc%type) is
    select grp.cdcooper
         , grp.cdagenci
         , grp.nrdconta
         , grp.nrcpfcgc
         , grp.nrdgrupo
         , grp.idpessoa
         , ass.tpvincul
      from tbevento_pessoa_grupos grp
         , crapass ass
     where grp.cdcooper = pr_cdcooper
       and grp.nrcpfcgc = pr_nrcpfcgc
       and ass.cdcooper = grp.cdcooper
       and ass.nrdconta = grp.nrdconta;
    rw_tabela_de_grupos cr_tabela_de_grupos%rowtype;
    rw_buscar_conjuge   cr_tabela_de_grupos%rowtype;

    -- Analisa grupo com menor qtd membros
    cursor cr_busca_grupo_novo (pr_cdcooper in tbevento_grupos.cdcooper%type
                               ,pr_cdagenci in tbevento_grupos.cdagenci%type) is
    select dsc.nrdgrupo
      from tbevento_grupos dsc
     where dsc.cdcooper = pr_cdcooper
       and dsc.cdagenci = pr_cdagenci
     order
        by dsc.qtd_membros;
    rw_busca_grupo_novo cr_busca_grupo_novo%rowtype;
    
    -- Cooperativas com eventos assembleares ativos
    cursor cr_crapcop (pr_cdcooper in crapcop.cdcooper%type) is
    select cop.flgrupos
      from crapcop cop
     where cop.cdcooper = pr_cdcooper
	   and cop.flgrupos = 1;  -- Evento assemblear ativo
    rw_crapcop cr_crapcop%rowtype;

    vr_nrdgrupo number;
    vr_nrdrowid rowid;
    
  begin
    
    -- Analisa parametros de entrada
    if    pr_cdcooper is null then
      vr_dscritic := 'O número da cooperativa deve ser informado.';
      raise vr_exc_erro;
    elsif pr_nrdconta is null then
      vr_dscritic := 'O número da conta deve ser informado.';
      raise vr_exc_erro;
    end if;
    
    -- Cooperativas ativas devem possuir o flag
    open cr_crapcop (pr_cdcooper);
    fetch cr_crapcop into rw_crapcop;
    
    -- Aborta caso nao encontre
    if cr_crapcop%notfound then
      close cr_crapcop;
      vr_dscritic := 'Cooperativa não está ativa para eventos assembleares.';
      raise vr_exc_erro;
    end if;
    
    close cr_crapcop;

    -- Buscar cooperado na tabela de associados
    open cr_crapass (pr_cdcooper
                    ,pr_nrdconta);
    fetch cr_crapass into rw_crapass;
    
    -- Aborta caso nao encontre
    if cr_crapass%notfound then
      close cr_crapass;
      vr_dscritic := 'Cooperado não encontrado na tabela de associados.';
      raise vr_exc_erro;
    end if;
    
    close cr_crapass;

    -- Buscar cooperado na tabela de grupos
    open cr_tabela_de_grupos (rw_crapass.cdcooper
                             ,rw_crapass.nrcpfcgc);
    fetch cr_tabela_de_grupos into rw_tabela_de_grupos;
    close cr_tabela_de_grupos;
  
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root',  pr_posicao => 0, pr_tag_nova => 'Dados', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'param', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    -- cr_buscar_cooperado%found
    -- Conta ja admitida e eh a conta mais antiga: retornar critica
    if    rw_tabela_de_grupos.nrdconta = rw_crapass.nrdconta then
      
      vr_dscritic := 'Conta já admitida anteriormente.';
      raise vr_exc_erro;
      
    -- cr_buscar_cooperado%found e conta mais antiga do cooperado 
    -- ja esta locada em um grupo
    elsif rw_tabela_de_grupos.nrdconta <> rw_crapass.nrdconta then

      -- Compatibilizar tpvincul das duas contas 
      begin
        update crapass
           set tpvincul = rw_tabela_de_grupos.tpvincul
         where cdcooper = rw_crapass.cdcooper
           and nrdconta = rw_crapass.nrdconta;
      exception
        when others then
          vr_dscritic := 'Erro ao atualizar tabela de associados: ' || sqlerrm;
          raise vr_exc_erro;
      end;

      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'cdcooper', pr_tag_cont => rw_crapass.cdcooper,      pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'idpessoa', pr_tag_cont => rw_crapass.idpessoa,      pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'cdagenci', pr_tag_cont => null,                     pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'nrdconta', pr_tag_cont => rw_crapass.nrdconta,      pr_des_erro => vr_dscritic);                           
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'nrctamd5', pr_tag_cont => md5(rw_crapass.nrdconta), pr_des_erro => vr_dscritic);                           
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'dtadmiss', pr_tag_cont => to_char(rw_crapass.dtadmiss,'dd/mm/yyyy'), pr_des_erro => vr_dscritic);                           
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'nrdgrupo', pr_tag_cont => null,                     pr_des_erro => vr_dscritic);                           

    -- cr_buscar_cooperado%notfound: pessoa nova deve ser locada em grupo
    else

      -- Busca conjuge na agencia nova
      open cr_crapcje (rw_crapass.cdcooper
                      ,rw_crapass.cdagenci
                      ,rw_crapass.nrcpfcgc);
      fetch cr_crapcje into rw_crapcje;
        
      -- Caso encontre conjuge
      if cr_crapcje%found then
        
        -- Busca grupo do conjuge
        open cr_tabela_de_grupos (rw_crapcje.cdcooper
                                 ,rw_crapcje.nrcpfcgc);
        fetch cr_tabela_de_grupos into rw_buscar_conjuge;
        close cr_tabela_de_grupos;
        
        -- Alocar no grupo do conjuge
        if rw_buscar_conjuge.cdagenci = rw_crapass.cdagenci then
          vr_nrdgrupo := rw_buscar_conjuge.nrdgrupo;
        end if;

      end if;
        
      close cr_crapcje;
        
      -- Caso de alguma forma grupo nao tenha sido atribuido
      if vr_nrdgrupo is null then
              
        open cr_busca_grupo_novo (rw_crapass.cdcooper
                                 ,rw_crapass.cdagenci);
        fetch cr_busca_grupo_novo into rw_busca_grupo_novo;
          
        -- Significa que agencia nao possui grupos
        if cr_busca_grupo_novo%notfound then
          close cr_busca_grupo_novo;
          vr_dscritic := 'Agência não possui um grupo formado.';
          raise vr_exc_erro; 
        end if;
          
        close cr_busca_grupo_novo;
            
        vr_nrdgrupo := rw_busca_grupo_novo.nrdgrupo;
            
      end if;

      -- Inserir em novo grupo de novo PA
      begin
        insert into tbevento_pessoa_grupos
                    (cdcooper
                   , cdagenci
                   , nrdconta
                   , nrcpfcgc
                   , nrdgrupo
                   , cdoperad_altera
                   , dhalteracao
                   , idpessoa)
             values (rw_crapass.cdcooper
                   , rw_crapass.cdagenci
                   , rw_crapass.nrdconta
                   , rw_crapass.nrcpfcgc
                   , vr_nrdgrupo
                   , 1
                   , sysdate
                   , rw_crapass.idpessoa);
      exception
        when others then
          vr_dscritic := 'Erro ao inserir em grupo: '||sqlerrm;
          raise vr_exc_erro;
      end;
        
      -- Atualiza tabela de resumo de grupos
      begin
        update tbevento_grupos
           set qtd_membros = qtd_membros + 1
         where cdcooper    = rw_crapass.cdcooper
           and cdagenci    = rw_crapass.cdagenci
           and nrdgrupo    = vr_nrdgrupo;
      exception
        when others then
          vr_dscritic := 'Erro ao atualizar tabela de descricao de grupos(2): '||sqlerrm;
          raise vr_exc_erro;
      end;

      -- Gravar log de insercao de funcao
      gene0001.pc_gera_log(pr_cdcooper => rw_crapass.cdcooper
                          ,pr_cdoperad => 1
                          ,pr_dscritic => null
                          ,pr_dsorigem => 'AIMARO WEB'
                          ,pr_dstransa => 'Conta Admitida: cooperado locado em grupo.'
                          ,pr_dttransa => trunc(sysdate)
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => gene0002.fn_busca_time
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'AGRP0001'
                          ,pr_nrdconta => rw_crapass.nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);

      -- Popular variaveis do XML
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'cdcooper', pr_tag_cont => rw_crapass.cdcooper,      pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'idpessoa', pr_tag_cont => rw_crapass.idpessoa,      pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'cdagenci', pr_tag_cont => rw_crapass.cdagenci,      pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'nrdconta', pr_tag_cont => rw_crapass.nrdconta,      pr_des_erro => vr_dscritic);                           
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'nrctamd5', pr_tag_cont => md5(rw_crapass.nrdconta), pr_des_erro => vr_dscritic);                           
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'dtadmiss', pr_tag_cont => to_char(rw_crapass.dtadmiss,'dd/mm/yyyy'),      pr_des_erro => vr_dscritic);                           
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'nrdgrupo', pr_tag_cont => vr_nrdgrupo,              pr_des_erro => vr_dscritic);                           

    end if;

    commit;

  exception

    when vr_exc_erro then
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'AGRP0001.pc_admitir_conta: ' || vr_dscritic;
    
    when others then
      
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratado: AGRP0001.pc_admitir_conta: '||sqlerrm;
      
  end pc_admitir_conta;

  procedure pc_obtem_nova_pessoa (pr_cdcooper   in crapass.cdcooper%type
                                 ,pr_idpessoa   in tbcadast_pessoa.idpessoa%type
                                 ,pr_retxml in out nocopy XMLType
                                 ,pr_cdcritic  out varchar2
                                 ,pr_dscritic  out varchar2) is

  ---------------------------------------------------------------------------
  --
  --  Programa : pc_obtem_nova_pessoa
  --  Sistema  : Ayllos Web
  --  Autor    : Gabriel Marcos
  --  Data     : Agosto/2018                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Retornar informacoes completas do cooperado via XML
  --
  -- Alteracoes:
  --
  --------------------------------------------------------------------------  

    -- Verifica se conta analisada participa de grupo
    cursor cr_buscar_cooperado (pr_cdcooper in crapass.cdcooper%type
                               ,pr_idpessoa in tbcadast_pessoa.idpessoa%type) is
    select ass.cdcooper
         , ass.cdagenci
         , ass.nrdconta
         , ass.nrcpfcgc
         , grp.nrdgrupo
         , grp.idpessoa
         , ass.dtadmiss
         , ass.inpessoa
         , ass.nmprimtl
         , ass.dtnasctl
         , decode(trim(ass.tpvincul),'',' ',ass.tpvincul) tpvincul
      from tbevento_pessoa_grupos grp
         , crapass                   ass
     where grp.cdcooper = pr_cdcooper
       and grp.idpessoa = pr_idpessoa
       and ass.cdcooper = grp.cdcooper
       and ass.nrdconta = grp.nrdconta;
    rw_buscar_cooperado cr_buscar_cooperado%rowtype;
    
    -- Verifica se conta analisada participa de grupo
    cursor cr_loop_ctas_ativas (pr_cdcooper in crapass.cdcooper%type
                               ,pr_nrdconta in crapass.nrdconta%type
                               ,pr_nrcpfcgc in crapass.nrcpfcgc%type) is
    select ass.cdagenci
         , ass.nrdconta
         , decode(ass.dtdemiss,'',1,0) cdstatus
      from crapass ass
     where ass.cdcooper  = pr_cdcooper
       and ass.nrdconta <> pr_nrdconta
       and ass.nrcpfcgc  = pr_nrcpfcgc;
    rw_loop_ctas_ativas cr_loop_ctas_ativas%rowtype;
    
    vr_contador integer := 0;

  begin
    
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root',  pr_posicao => 0, pr_tag_nova => 'Dados', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'param', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
 
    -- Buscar nrcpfcgc na tab de grupos
    -- se encontrou aborta
    open cr_buscar_cooperado (pr_cdcooper
                             ,pr_idpessoa);
    fetch cr_buscar_cooperado into rw_buscar_cooperado;

    -- Aborta caso nao retorne informacoes
    if cr_buscar_cooperado%notfound then
      close cr_buscar_cooperado;
      vr_dscritic := 'Cooperado não encontrado na tabela de associados.';
      raise vr_exc_erro;
    end if;
    
    -- Conta mais antiga do cooperado ja esta
    -- locada em um grupo
    close cr_buscar_cooperado;

    -- Popular XML
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'cdcooper', pr_tag_cont => rw_buscar_cooperado.cdcooper, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'idpessoa', pr_tag_cont => rw_buscar_cooperado.idpessoa, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'cdagenci', pr_tag_cont => rw_buscar_cooperado.cdagenci, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'nrdconta', pr_tag_cont => rw_buscar_cooperado.nrdconta, pr_des_erro => vr_dscritic);                           
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'nrctamd5', pr_tag_cont => md5(rw_buscar_cooperado.nrdconta), pr_des_erro => vr_dscritic);                           
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'dtadmiss', pr_tag_cont => to_char(rw_buscar_cooperado.dtadmiss,'dd/mm/yyyy'), pr_des_erro => vr_dscritic);                           
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'nrdgrupo', pr_tag_cont => rw_buscar_cooperado.nrdgrupo, pr_des_erro => vr_dscritic);                           
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'nrcpfcgc', pr_tag_cont => rw_buscar_cooperado.nrcpfcgc, pr_des_erro => vr_dscritic);                           
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'inpessoa', pr_tag_cont => rw_buscar_cooperado.inpessoa, pr_des_erro => vr_dscritic);                           
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'nmprimtl', pr_tag_cont => rw_buscar_cooperado.nmprimtl, pr_des_erro => vr_dscritic);                           
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'dtnasctl', pr_tag_cont => to_char(rw_buscar_cooperado.dtnasctl,'dd/mm/yyyy'), pr_des_erro => vr_dscritic);                           
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'tpvincul', pr_tag_cont => rw_buscar_cooperado.tpvincul, pr_des_erro => vr_dscritic);                           
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'param', pr_posicao => 0, pr_tag_nova => 'listaContas', pr_tag_cont => null,                      pr_des_erro => vr_dscritic);

    for rw_loop_ctas_ativas in cr_loop_ctas_ativas (pr_cdcooper
                                                   ,rw_buscar_cooperado.nrdconta
                                                   ,rw_buscar_cooperado.nrcpfcgc) loop
      
      -- Popula as informacoes via XML
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'listaContas', pr_posicao => 0,           pr_tag_nova => 'conta',    pr_tag_cont => null,                              pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'conta',       pr_posicao => vr_contador, pr_tag_nova => 'cdagenci', pr_tag_cont => rw_loop_ctas_ativas.cdagenci,      pr_des_erro => vr_dscritic); 
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'conta',       pr_posicao => vr_contador, pr_tag_nova => 'nrdconta', pr_tag_cont => rw_loop_ctas_ativas.nrdconta,      pr_des_erro => vr_dscritic); 
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'conta',       pr_posicao => vr_contador, pr_tag_nova => 'nrctamd5', pr_tag_cont => md5(rw_loop_ctas_ativas.nrdconta), pr_des_erro => vr_dscritic); 
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'conta',       pr_posicao => vr_contador, pr_tag_nova => 'cdstatus', pr_tag_cont => rw_loop_ctas_ativas.cdstatus,      pr_des_erro => vr_dscritic); 

      vr_contador := vr_contador + 1;

    end loop;   

    commit;                                              

  exception

    when vr_exc_erro then
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'AGRP0001.pc_obtem_nova_pessoa: ' || vr_dscritic;
    
    when others then
      
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratado: AGRP0001.pc_obtem_nova_pessoa: '||sqlerrm;
      
  end pc_obtem_nova_pessoa;

  procedure pc_cartoes_conta_auto_job is

  ---------------------------------------------------------------------------
  --
  --  Programa : pc_cartoes_conta_auto_job
  --  Sistema  : Ayllos Web
  --  Autor    : Gabriel Marcos
  --  Data     : Agosto/2018                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Rotina para popular tabela de cartoes analisada pelo soa
  --
  -- Alteracoes:
  --
  --------------------------------------------------------------------------  

    -- Busca agencias para verificacao
    cursor cr_crapcop is
    select cop.cdcooper
      from crapcop cop
     where cop.flgativo = 1  -- Cooperativa ativa
       and cop.flgrupos = 1; -- Evento assemblear ativo

    -- Busca data de movimentacao da cooperativa
    cursor cr_crapdat (pr_cdcooper crapdat.cdcooper%type) is
    select dat.dtmvtoan
      from crapdat dat
     where dat.cdcooper = pr_cdcooper;
    rw_crapdat cr_crapdat%rowtype;
    
    -- Cartoes inseridos e ou atualizados hoje
    cursor cr_cartoes_soa (pr_cdcooper in crawcrd.cdcooper%type
                          ,pr_dtrefatu in crawcrd.dtrefatu%type) is
    select crd.cdcooper
         , crd.nrdconta
         , crd.nrcrcard
      from crawcrd crd
     where crd.cdcooper = pr_cdcooper
       and crd.dtrefatu > pr_dtrefatu
       and nvl(crd.nrcrcard,0) > 0
       -- Evita reenviar um cartao que ja foi
       -- enviado anteriormente com sucesso
       and not exists (select 1
                         from tbhistor_cartoes_soa his
                        where his.cdcooper = crd.cdcooper
                          and his.nrdconta = crd.nrdconta
                          and his.nrcrcard = crd.nrcrcard
                          and his.tpsituacao = 1);

    vr_idprglog number := 0;
    vr_cdcooper crapass.cdcooper%type;
    vr_cdprogra varchar2(100) := 'JBAGRP_CONTA_CARTOES_SOA';

  begin

    vr_idprglog := 0;
      
    -- Gera log no início da execução
    pc_log_programa(pr_dstiplog   => 'I'         
                   ,pr_cdprograma => vr_cdprogra 
                   ,pr_cdcooper   => 0
                   ,pr_tpexecucao => 0     
                   ,pr_idprglog   => vr_idprglog);
    
    -- Loop dentro das cooperativas
    for rw_crapcop in cr_crapcop loop
    
      -- Grava cooperativa em variavel para exceptions
      if rw_crapcop.cdcooper <> nvl(vr_cdcooper,0) then
        
        vr_cdcooper := rw_crapcop.cdcooper;

        -- Busca data da cooperativa
        open cr_crapdat (vr_cdcooper);
        fetch cr_crapdat into rw_crapdat;
          
        -- Se nao encontrar aborta
        if cr_crapdat%notfound then
            
          close cr_crapdat;
          vr_dscritic := 'Data da cooperativa não cadastrada.';
          raise vr_exc_erro;

        end if;
          
        close cr_crapdat;
        
      end if;
      
      -- Loop nos registros criados e ou atualizados no dia
      for rw_cartoes_soa in cr_cartoes_soa (rw_crapcop.cdcooper
                                           ,rw_crapdat.dtmvtoan) loop
        
        -- Limpeza de variaveis
        vr_dscritic := null;
        
        -- Chamada da procedure
        pc_cartoes_conta (pr_cdcooper => rw_cartoes_soa.cdcooper
                         ,pr_nrdconta => rw_cartoes_soa.nrdconta
                         ,pr_nrcrcard => rw_cartoes_soa.nrcrcard
                         ,pr_dscritic => vr_dscritic);
                
        -- Aborta caso nao encontre         
        if trim(vr_dscritic) is not null then
          raise vr_exc_erro;
        end if;
                         
      end loop;
      
      commit;
    
    end loop;

    -- Gera log no fim da execução
    pc_log_programa(pr_dstiplog   => 'F'         
                   ,pr_cdprograma => vr_cdprogra 
                   ,pr_cdcooper   => 0
                   ,pr_tpexecucao => 0    
                   ,pr_flgsucesso => 1
                   ,pr_idprglog   => vr_idprglog);

  exception
    
    when vr_exc_erro then

      rollback;
       
      -- Gera log no início da execução
      pc_log_programa(pr_dstiplog   => 'F'         
                     ,pr_cdprograma => vr_cdprogra 
                     ,pr_cdcooper   => 0
                     ,pr_tpexecucao => 0    
                     ,pr_flgsucesso => 0 
                     ,pr_idprglog   => vr_idprglog);
       
      vr_cdcritic := 0;
      vr_idprglog := 0;
      
      cecred.pc_log_programa(pr_dstiplog      => 'E' -- Erro
                            ,pr_cdprograma    => 'AGRP0001.pc_cartoes_conta_auto_job'
                            ,pr_cdcooper      => vr_cdcooper
                            ,pr_tpexecucao    => 2   -- Job
                            ,pr_tpocorrencia  => 2   -- Erro nao tratado
                            ,pr_cdcriticidade => 3   -- Critica
                            ,pr_cdmensagem    => 0
                            ,pr_dsmensagem    => ' Module: AGRP0001 '||vr_dscritic
                            ,pr_idprglog      => vr_idprglog);

    when others then
      
      rollback;
       
      -- Gera log no início da execução
      pc_log_programa(pr_dstiplog   => 'F'         
                     ,pr_cdprograma => vr_cdprogra 
                     ,pr_cdcooper   => 0
                     ,pr_tpexecucao => 0    
                     ,pr_flgsucesso => 0 
                     ,pr_idprglog   => vr_idprglog);
       
      vr_cdcritic := 0;
      vr_dscritic := 'Erro não tratado AGRP0001.pc_cartoes_conta_auto_job: '||SQLERRM;
      vr_idprglog := 0;
      
      cecred.pc_log_programa(pr_dstiplog      => 'E' -- Erro
                            ,pr_cdprograma    => 'AGRP0001.pc_cartoes_conta_auto_job'
                            ,pr_cdcooper      => vr_cdcooper
                            ,pr_tpexecucao    => 2   -- Job
                            ,pr_tpocorrencia  => 2   -- Erro nao tratado
                            ,pr_cdcriticidade => 3   -- Critica
                            ,pr_cdmensagem    => 0
                            ,pr_dsmensagem    => ' Module: AGRP0001 '||vr_dscritic
                            ,pr_idprglog      => vr_idprglog);
      
  end pc_cartoes_conta_auto_job;

  procedure pc_cartoes_conta (pr_cdcooper   in crapass.cdcooper%type
                             ,pr_nrdconta   in tbcadast_pessoa.idpessoa%type
                             ,pr_nrcrcard   in crapcrd.nrcrcard%type
                             ,pr_dscritic  out varchar2) is

  ---------------------------------------------------------------------------
  --
  --  Programa : pc_cartoes_conta
  --  Sistema  : Ayllos Web
  --  Autor    : Gabriel Marcos
  --  Data     : Agosto/2018                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Fazer controle de cartoes para envio ao soa
  --
  -- Alteracoes:
  --
  --------------------------------------------------------------------------  

    -- Busca cooperado na tabela de associados
    cursor cr_crapass (pr_cdcooper in crapass.cdcooper%type
                      ,pr_nrdconta in crapass.nrdconta%type) is
    select ass.cdcooper
         , ass.nrcpfcgc
         , ass.nrdconta
         , ass.cdagenci
         , pes.idpessoa
      from crapass         ass
         , tbcadast_pessoa pes
     where ass.cdcooper = pr_cdcooper
       and ass.nrdconta = pr_nrdconta
       and pes.nrcpfcgc = ass.nrcpfcgc;
    rw_crapass cr_crapass%rowtype;
    
    vr_nrctamd5 tbhistor_cartoes_soa.nrctamd5%type := md5(pr_nrdconta);
    vr_nrcarmd5 tbhistor_cartoes_soa.nrcarmd5%type := md5(pr_nrcrcard);

  begin
    
    -- Controle de parametros de entrada
    if nvl(pr_cdcooper,0) = 0 then
      vr_dscritic := 'Cooperativa deve ser informada.';
      raise vr_exc_erro;
    elsif nvl(pr_nrdconta,0) = 0 then
      vr_dscritic := 'Conta deve ser informada.';
      raise vr_exc_erro;
    elsif nvl(pr_nrcrcard,0) = 0 then
      vr_dscritic := 'Número do cartão deve ser informado.';
      raise vr_exc_erro;
    end if;
    
    -- Busca dados do cooperado
    open cr_crapass (pr_cdcooper
                    ,pr_nrdconta);
    fetch cr_crapass into rw_crapass;
    
    -- Aborta operacao caso nao encontre
    if cr_crapass%notfound then
      close cr_crapass;
      vr_dscritic := 'Cooperado não encontrado na tabela de associados.';
      raise vr_exc_erro;
    end if;
    
    close cr_crapass;
    
    begin
      -- Inserir na tabela de monitoramento do soa
      insert 
        into tbhistor_cartoes_soa (cdcooper
                                  ,idpessoa
                                  ,dhalteracao
                                  ,tpsituacao
                                  ,dhcomunicacao
                                  ,dserro
                                  ,qttentativa
                                  ,nrdconta
                                  ,nrctamd5
                                  ,nrcrcard
                                  ,nrcarmd5)
      values                      (rw_crapass.cdcooper
                                  ,rw_crapass.idpessoa
                                  ,sysdate
                                  ,0
                                  ,null
                                  ,null
                                  ,null
                                  ,rw_crapass.nrdconta
                                  ,vr_nrctamd5
                                  ,pr_nrcrcard
                                  ,vr_nrcarmd5);
    exception
      when others then
        vr_dscritic := 'Erro ao inserir na tabela tbhistor_cartoes_soa: '||sqlerrm;
        raise vr_exc_erro;
    end;

  exception

    when vr_exc_erro then

      pr_dscritic := vr_dscritic;
    
    when others then

      pr_dscritic := 'Erro nao tratado: AGRP0001.pc_cartoes_conta: '||sqlerrm;
      
  end pc_cartoes_conta;

end AGRP0001;
/