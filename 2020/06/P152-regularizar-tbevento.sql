declare

  -- Busca cooperados com cpf divergente
  -- Mudou de cpf/cnpj (1)
  cursor cr_matric_j is
  select d.cdcooper 
       , d.nrcpfcgc
       , d.nrdconta
    from tbevento_pessoa_grupos d
   where d.cdcooper  in (1,9)
     and not exists (select 1
                       from crapass b
                      where b.cdcooper = d.cdcooper
                        and b.nrcpfcgc = d.nrcpfcgc); 
                 
  -- Conta nao e mais antiga     
  -- Delegado que mudou de agencia (1)
  cursor cr_regularizar_conta is
  select ass.cdcooper 
       , ass.nrcpfcgc
       , ass.nrdconta
    from crapass ass
       , crapcop cop
       , tbcadast_pessoa aaa
   where ass.cdcooper in (1,9)
     and cop.cdcooper = ass.cdcooper
     and cop.nrdocnpj <> ass.nrcpfcgc
     and aaa.nrcpfcgc = ass.nrcpfcgc
     and ass.inpessoa < 3
     and ass.dtdemiss  is null
     and exists (  select 1
                     from tbevento_pessoa_grupos z
                    where z.cdcooper = ass.cdcooper
                      and z.nrcpfcgc = ass.nrcpfcgc
                      and (z.cdagenci <> ass.cdagenci or z.nrdconta <> ass.nrdconta)
                )
     and not exists (select 1
                       from crapass a
                      where a.cdcooper  = cop.cdcooper
                        and a.nrcpfcgc  = ass.nrcpfcgc
                        and a.nrdconta <> ass.nrdconta
                        and a.dtdemiss  is null
                        and ((a.dtadmiss < ass.dtadmiss) or
                             (a.dtadmiss = ass.dtadmiss and
                              a.nrdconta < ass.nrdconta)));

  -- Busca cooperados sem grupo
  -- Agencias novas e problemas no crm (448)
  cursor cr_admissoes is
  select c.cdcooper
       , c.nrdconta
       , c.cdagenci
       , c.dtmvtolt
    from crapass c
       , crapcop e
       , tbcadast_pessoa f
       , crapdat z
   where c.cdcooper in (1,9)
     and c.dtdemiss is null
     and c.inpessoa <> 3
     and z.cdcooper = c.cdcooper
     and c.dtmvtolt <> z.dtmvtolt
     and e.cdcooper  = c.cdcooper
     and e.nrdocnpj <> c.nrcpfcgc
     and f.nrcpfcgc  = c.nrcpfcgc 
     and not exists (select 1
                       from tbevento_pessoa_grupos d
                      where d.cdcooper = c.cdcooper
                        and d.nrcpfcgc = c.nrcpfcgc)
     and not exists (select 1
                       from crapass a
                      where a.cdcooper  = e.cdcooper
                        and a.nrcpfcgc  = c.nrcpfcgc
                        and a.nrdconta <> c.nrdconta
                        and a.dtdemiss  is null
                        and ((a.dtadmiss < c.dtadmiss) or
                             (a.dtadmiss = c.dtadmiss and
                              a.nrdconta < c.nrdconta)));

  -- Busca cooperados demitidos
  -- SOA nao chamou proc de demissao (1)
  cursor cr_demitidos is
  select a.cdcooper
       , a.nrdconta
       , a.nrcpfcgc
       , b.dtdemiss
    from tbevento_pessoa_grupos a
       , crapass b
       , crapdat c
   where a.cdcooper in (1,9)
     and b.cdcooper = a.cdcooper 
     and b.nrdconta = a.nrdconta 
     and c.cdcooper = a.cdcooper
     and c.dtmvtolt <> b.dtdemiss
     and b.dtdemiss is not null;

  -- Variaveis
  vr_exc_saida exception;
  vr_contador  number := 0;
  vr_idprglog  number := 0;
  vr_cdcritic  pls_integer;
  vr_dscritic  varchar2(4000);
  vr_cdprogra  varchar2(40) := 'AGRP0001-SCRIPT-REGULARIZA';

  -- Auxiliar para popular xml da rotina
  pr_retxml   xmltype;
  pr_auxiliar clob := '<Root>'                         ||
                      '<params>'                       ||
                      '<cdcooper>1</cdcooper>'         ||
                      '<nmprogra>AGRP0001</nmprogra>' ||
                      '<nmeacao>UNDEFINED</nmeacao>'   ||
                      '<cdagenci>1</cdagenci>'         ||
                      '<nrdcaixa>1</nrdcaixa>'         ||
                      '<idorigem>1</idorigem>'         ||
                      '<cdoperad>1</cdoperad>'         ||
                      '</params></Root>'; 

begin

  -- Gera log no início da execução
  pc_log_programa(pr_dstiplog   => 'I'         
                 ,pr_cdprograma => vr_cdprogra 
                 ,pr_cdcooper   => 0
                 ,pr_tpexecucao => 0     
                 ,pr_idprglog   => vr_idprglog);

  begin
    -- Burla xml e passa coop
    pr_retxml := xmltype(pr_auxiliar);
  exception
    when others then
      vr_dscritic := 'Erro ao atribuir xml: '||sqlerrm;
      raise vr_exc_saida;
  end;
  
  -- Busca cooperados com cpf divergente
  for rw_matric_j in cr_matric_j loop
    
    begin

      delete
        from tbevento_pessoa_grupos c
       where c.cdcooper = rw_matric_j.cdcooper
         and c.nrcpfcgc = rw_matric_j.nrcpfcgc;
      
      -- Controle de commit
      if mod(vr_contador,100) = 0 then
        commit;
      end if;
      
      vr_contador := vr_contador + 1;
    
    exception
      when others then
        vr_dscritic := 'Erro ao manipular tbevento_pessoa_grupos (1) --> '||sqlerrm;
        -- Logar fim de execução sem sucesso
        cecred.pc_log_programa(pr_dstiplog      => 'E'
                              ,pr_cdprograma    => vr_cdprogra
                              ,pr_cdcooper      => 0
                              ,pr_tpexecucao    => 0   
                              ,pr_tpocorrencia  => 2 
                              ,pr_cdcriticidade => 1 
                              ,pr_cdmensagem    => 0
                              ,pr_dsmensagem    => 'Module: AGRP0001 '||vr_dscritic
                              ,pr_idprglog      => vr_idprglog);
    end;
                              
  end loop;
 
  -- Busca cooperados com cpf divergente
  for rw_regularizar_conta in cr_regularizar_conta loop
    
    begin

      delete
        from tbevento_pessoa_grupos c
       where c.cdcooper = rw_regularizar_conta.cdcooper
         and c.nrcpfcgc = rw_regularizar_conta.nrcpfcgc;
      
      -- Controle de commit
      if mod(vr_contador,100) = 0 then
        commit;
      end if;
      
      vr_contador := vr_contador + 1;
    
    exception
      when others then
        vr_dscritic := 'Erro ao manipular tbevento_pessoa_grupos (2) --> '||sqlerrm;
        -- Logar fim de execução sem sucesso
        cecred.pc_log_programa(pr_dstiplog      => 'E'
                              ,pr_cdprograma    => vr_cdprogra
                              ,pr_cdcooper      => 0
                              ,pr_tpexecucao    => 0   
                              ,pr_tpocorrencia  => 2 
                              ,pr_cdcriticidade => 1 
                              ,pr_cdmensagem    => 0
                              ,pr_dsmensagem    => 'Module: AGRP0001 '||vr_dscritic
                              ,pr_idprglog      => vr_idprglog);
    end;
                              
  end loop;
  
  -- Busca cooperados sem grupo
  for rw_admissoes in cr_admissoes loop
    
    begin

      -- Rotina para de controle de admissoes
      agrp0001.pc_admitir_conta (pr_cdcooper => rw_admissoes.cdcooper
                                ,pr_nrdconta => rw_admissoes.nrdconta
                                ,pr_retxml   => pr_retxml
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);
                                
      -- Aborta em caso de critica                              
      if nvl(vr_cdcritic,0) > 0 or trim(vr_dscritic) is not null then
        raise vr_exc_saida;
      end if;
      
      -- Controle de commit
      if mod(vr_contador,100) = 0 then
        commit;
      end if;
      
      vr_contador := vr_contador + 1;
    
    exception
      when others then
        vr_dscritic := 'Erro ao manipular tbevento_pessoa_grupos (3) --> '||vr_dscritic||' '||sqlerrm;
        -- Logar fim de execução sem sucesso
        cecred.pc_log_programa(pr_dstiplog      => 'E'
                              ,pr_cdprograma    => vr_cdprogra
                              ,pr_cdcooper      => 0
                              ,pr_tpexecucao    => 0   
                              ,pr_tpocorrencia  => 2 
                              ,pr_cdcriticidade => 1 
                              ,pr_cdmensagem    => 0
                              ,pr_dsmensagem    => 'Module: AGRP0001 '||vr_dscritic
                              ,pr_idprglog      => vr_idprglog);
    end;
                              
  end loop;
  
  -- Busca cooperados demitidos
  for rw_demitidos in cr_demitidos loop
    
    begin

      -- Rotina para de controle de admissoes
      agrp0001.pc_demitir_conta (pr_cdcooper => rw_demitidos.cdcooper
                                ,pr_nrdconta => rw_demitidos.nrdconta
                                ,pr_retxml   => pr_retxml
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);
                                
      -- Aborta em caso de critica                              
      if nvl(vr_cdcritic,0) > 0 or trim(vr_dscritic) is not null then
        raise vr_exc_saida;
      end if;
      
      -- Controle de commit
      if mod(vr_contador,100) = 0 then
        commit;
      end if;
      
      vr_contador := vr_contador + 1;
    
    exception
      when others then
        vr_dscritic := 'Erro ao manipular tbevento_pessoa_grupos (5) --> '||sqlerrm;
        -- Logar fim de execução sem sucesso
        cecred.pc_log_programa(pr_dstiplog      => 'E'
                              ,pr_cdprograma    => vr_cdprogra
                              ,pr_cdcooper      => 0
                              ,pr_tpexecucao    => 0   
                              ,pr_tpocorrencia  => 2 
                              ,pr_cdcriticidade => 1 
                              ,pr_cdmensagem    => 0
                              ,pr_dsmensagem    => 'Module: AGRP0001 '||vr_dscritic
                              ,pr_idprglog      => vr_idprglog);
    end;
                              
  end loop;
  
  begin
    
    delete
      from tbevento_grupos grp
     where grp.cdcooper in (1,9)
       and not exists (select 1
                         from tbevento_pessoa_grupos c
                        where c.cdcooper = grp.cdcooper
                          and c.cdagenci = grp.cdagenci
                          and c.nrdgrupo = grp.nrdgrupo);
                          
    vr_contador := vr_contador + sql%rowcount;

    -- Controle de commit
    if mod(vr_contador,100) = 0 then
      commit;
    end if;

  exception
    when others then
      vr_dscritic := 'Erro ao manipular tbevento_pessoa_grupos (6) --> '||sqlerrm;
      -- Logar fim de execução sem sucesso
      cecred.pc_log_programa(pr_dstiplog      => 'E'
                            ,pr_cdprograma    => vr_cdprogra
                            ,pr_cdcooper      => 0
                            ,pr_tpexecucao    => 0   
                            ,pr_tpocorrencia  => 2 
                            ,pr_cdcriticidade => 1 
                            ,pr_cdmensagem    => 0
                            ,pr_dsmensagem    => 'Module: AGRP0001 '||vr_dscritic
                            ,pr_idprglog      => vr_idprglog);
  end;
      
  -- Gera log no fim da execução
  pc_log_programa(pr_dstiplog   => 'F'         
                 ,pr_cdprograma => vr_cdprogra 
                 ,pr_cdcooper   => 0
                 ,pr_tpexecucao => 0    
                 ,pr_flgsucesso => 1
                 ,pr_idprglog   => vr_idprglog);

  commit;
  
  dbms_output.put_line('Sucesso: '||vr_contador);

exception
  
  when vr_exc_saida then
  
    rollback;
  
    -- Gera log no fim da execução
    pc_log_programa(pr_dstiplog   => 'F'         
                   ,pr_cdprograma => vr_cdprogra 
                   ,pr_cdcooper   => 0
                   ,pr_tpexecucao => 0    
                   ,pr_flgsucesso => 0
                   ,pr_idprglog   => vr_idprglog);

    -- Gera log de erro
    cecred.pc_log_programa(pr_dstiplog      => 'E' -- Erro
                          ,pr_cdprograma    => vr_cdprogra
                          ,pr_cdcooper      => 0
                          ,pr_tpexecucao    => 0   -- Outros
                          ,pr_tpocorrencia  => 2   -- Erro nao tratado
                          ,pr_cdcriticidade => 3   -- Critica
                          ,pr_cdmensagem    => 0
                          ,pr_dsmensagem    => ' Module: AGRP0001 '||vr_dscritic||sqlerrm
                          ,pr_idprglog      => vr_idprglog);
         
    dbms_output.put_line('Erro: '||vr_dscritic||' '||sqlerrm);
                    
  when others then
  
    rollback;
  
    -- Gera log no fim da execução
    pc_log_programa(pr_dstiplog   => 'F'         
                   ,pr_cdprograma => vr_cdprogra 
                   ,pr_cdcooper   => 0
                   ,pr_tpexecucao => 0    
                   ,pr_flgsucesso => 0
                   ,pr_idprglog   => vr_idprglog);
                   
    vr_dscritic := 'Erro ao geral (1) --> '||sqlerrm;
    dbms_output.put_line(vr_dscritic);
    
    -- Logar fim de execução sem sucesso
    cecred.pc_log_programa(pr_dstiplog      => 'E'
                          ,pr_cdprograma    => vr_cdprogra
                          ,pr_cdcooper      => 0
                          ,pr_tpexecucao    => 0   
                          ,pr_tpocorrencia  => 2 
                          ,pr_cdcriticidade => 1 
                          ,pr_cdmensagem    => 0
                          ,pr_dsmensagem    => 'Module: AGRP0001 '||vr_dscritic
                          ,pr_idprglog      => vr_idprglog);

end;