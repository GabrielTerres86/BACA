-- Atualizacao da tbevento_pessoa_grupos enquanto o job de automacao não está em uso - 7
declare

  -- Busca cooperados sem grupo
  cursor cr_admissoes is
  SELECT c.cdcooper
      ,c.nrdconta
  FROM crapass         c
      ,crapcop         e
      ,tbcadast_pessoa f
      ,crapage         a
 WHERE c.cdcooper IN (1, 9, 13, 14)
   AND c.cdagenci = a.cdagenci
   AND c.dtdemiss IS NULL
   AND c.inpessoa <> 3
   AND e.cdcooper = c.cdcooper
   AND e.nrdocnpj <> c.nrcpfcgc
   AND f.nrcpfcgc = c.nrcpfcgc
   AND a.cdcooper = e.cdcooper
   AND NOT EXISTS (SELECT 1
          FROM tbevento_pessoa_grupos d
         WHERE d.cdcooper = c.cdcooper
           AND d.nrcpfcgc = c.nrcpfcgc); 

  -- Busca cooperados em agencias diferentes               
  cursor cr_agencias is
  select a.cdcooper
       , a.nrdconta
    from tbevento_pessoa_grupos a
       , crapass b
   where a.cdcooper in  (1,9,13,14)
     and b.cdcooper = a.cdcooper 
     and b.nrdconta = a.nrdconta
     and a.cdagenci <> b.cdagenci;
     
  -- Busca cooperados demitidos
  cursor cr_demitidos is
  select a.cdcooper
       , a.nrdconta
       , a.nrcpfcgc
    from tbevento_pessoa_grupos a
       , crapass b
   where a.cdcooper in  (1,9,13,14) 
     and b.cdcooper = a.cdcooper 
     and b.nrdconta = a.nrdconta 
     and b.dtdemiss is not null;
   
  -- Variaveis
  vr_exc_saida exception;
  vr_contador  number := 0;
  vr_idprglog  number := 0;
  vr_cdcritic  pls_integer;
  vr_dscritic  varchar2(4000);

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

  begin
    -- Burla xml e passa coop
    pr_retxml := xmltype(pr_auxiliar);
  exception
    when others then
      vr_dscritic := 'Erro ao atribuir xml: '||sqlerrm;
      raise vr_exc_saida;
  end;

  -- Busca cooperados sem grupo
  for rw_admissoes in cr_admissoes loop
    
    begin
      
      -- Limpeza de variaveis
      vr_cdcritic := null;
      vr_dscritic := null;
    
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
      if mod(vr_contador,5) = 0 then
        null;
        commit;
      end if;
      
      vr_contador := vr_contador + 1;
    
    exception
      
      when vr_exc_saida then
        -- Gera log de erro
        cecred.pc_log_programa(pr_dstiplog      => 'E' -- Erro
                              ,pr_cdprograma    => 'AGRP-ERRO-T-LOOP'
                              ,pr_cdcooper      => 0
                              ,pr_tpexecucao    => 0   -- Outros
                              ,pr_tpocorrencia  => 2   -- Erro nao tratado
                              ,pr_cdcriticidade => 3   -- Critica
                              ,pr_cdmensagem    => 0
                              ,pr_dsmensagem    => ' Module: AGRP0001 '||vr_dscritic||sqlerrm
                              ,pr_idprglog      => vr_idprglog);
      when others then
        -- Gera log de erro
        cecred.pc_log_programa(pr_dstiplog      => 'E' -- Erro
                              ,pr_cdprograma    => 'AGRP-ERRO-NT-LOOP'
                              ,pr_cdcooper      => 0
                              ,pr_tpexecucao    => 0   -- Outros
                              ,pr_tpocorrencia  => 2   -- Erro nao tratado
                              ,pr_cdcriticidade => 3   -- Critica
                              ,pr_cdmensagem    => 0
                              ,pr_dsmensagem    => ' Module: AGRP0001 '||vr_dscritic||sqlerrm
                              ,pr_idprglog      => vr_idprglog);
    
    end;
                              
  end loop;
  
  -- Busca cooperados em agencias diferentes
  for rw_agencias in cr_agencias loop
    
    begin
      
      -- Limpeza de variaveis
      vr_cdcritic := null;
      vr_dscritic := null;
    
      -- Rotina para de controle de admissoes
      agrp0001.pc_agencia_conta (pr_cdcooper => rw_agencias.cdcooper
                                ,pr_nrdconta => rw_agencias.nrdconta
                                ,pr_retxml   => pr_retxml
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);
                                
      -- Aborta em caso de critica                              
      if nvl(vr_cdcritic,0) > 0 or trim(vr_dscritic) is not null then
        raise vr_exc_saida;
      end if;
      
      -- Controle de commit
      if mod(vr_contador,5) = 0 then
        null;
        commit;
      end if;
      
      vr_contador := vr_contador + 1;
    
    exception
      
      when vr_exc_saida then
        -- Gera log de erro
        cecred.pc_log_programa(pr_dstiplog      => 'E' -- Erro
                              ,pr_cdprograma    => 'AGRP-ERRO-T-LOOP'
                              ,pr_cdcooper      => 0
                              ,pr_tpexecucao    => 0   -- Outros
                              ,pr_tpocorrencia  => 2   -- Erro nao tratado
                              ,pr_cdcriticidade => 3   -- Critica
                              ,pr_cdmensagem    => 0
                              ,pr_dsmensagem    => ' Module: AGRP0001 '||vr_dscritic||sqlerrm
                              ,pr_idprglog      => vr_idprglog);
      when others then
        -- Gera log de erro
        cecred.pc_log_programa(pr_dstiplog      => 'E' -- Erro
                              ,pr_cdprograma    => 'AGRP-ERRO-NT-LOOP'
                              ,pr_cdcooper      => 0
                              ,pr_tpexecucao    => 0   -- Outros
                              ,pr_tpocorrencia  => 2   -- Erro nao tratado
                              ,pr_cdcriticidade => 3   -- Critica
                              ,pr_cdmensagem    => 0
                              ,pr_dsmensagem    => ' Module: AGRP0001 '||vr_dscritic||sqlerrm
                              ,pr_idprglog      => vr_idprglog);
    
    end;
                              
  end loop;
  
  -- Busca cooperados demitidos
  for rw_demitidos in cr_demitidos loop
    
    begin
      
      -- Limpeza de variaveis
      vr_cdcritic := null;
      vr_dscritic := null;
    
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
      if mod(vr_contador,5) = 0 then
        null;
        commit;
      end if;
      
      vr_contador := vr_contador + 1;
    
    exception
      
      when vr_exc_saida then
        -- Gera log de erro
        cecred.pc_log_programa(pr_dstiplog      => 'E' -- Erro
                              ,pr_cdprograma    => 'AGRP-ERRO-T-LOOP'
                              ,pr_cdcooper      => 0
                              ,pr_tpexecucao    => 0   -- Outros
                              ,pr_tpocorrencia  => 2   -- Erro nao tratado
                              ,pr_cdcriticidade => 3   -- Critica
                              ,pr_cdmensagem    => 0
                              ,pr_dsmensagem    => ' Module: AGRP0001 '||vr_dscritic||sqlerrm
                              ,pr_idprglog      => vr_idprglog);
      when others then
        -- Gera log de erro
        cecred.pc_log_programa(pr_dstiplog      => 'E' -- Erro
                              ,pr_cdprograma    => 'AGRP-ERRO-NT-LOOP'
                              ,pr_cdcooper      => 0
                              ,pr_tpexecucao    => 0   -- Outros
                              ,pr_tpocorrencia  => 2   -- Erro nao tratado
                              ,pr_cdcriticidade => 3   -- Critica
                              ,pr_cdmensagem    => 0
                              ,pr_dsmensagem    => ' Module: AGRP0001 '||vr_dscritic||sqlerrm
                              ,pr_idprglog      => vr_idprglog);
    
    end;
                              
  end loop;
  
  commit;
  
  dbms_output.put_line('Sucesso: '||vr_contador);

exception
  
  when vr_exc_saida then
    dbms_output.put_line('Erro: '||vr_contador);
    -- Gera log de erro
    cecred.pc_log_programa(pr_dstiplog      => 'E' -- Erro
                          ,pr_cdprograma    => 'AGRP-ERRO-T'
                          ,pr_cdcooper      => 0
                          ,pr_tpexecucao    => 0   -- Outros
                          ,pr_tpocorrencia  => 2   -- Erro nao tratado
                          ,pr_cdcriticidade => 3   -- Critica
                          ,pr_cdmensagem    => 0
                          ,pr_dsmensagem    => ' Module: AGRP0001 '||vr_dscritic||sqlerrm
                          ,pr_idprglog      => vr_idprglog);
  when others then
    dbms_output.put_line('Erro: '||vr_contador);
    -- Gera log de erro
    cecred.pc_log_programa(pr_dstiplog      => 'E' -- Erro
                          ,pr_cdprograma    => 'AGRP-ERRO-G'
                          ,pr_cdcooper      => 0
                          ,pr_tpexecucao    => 0   -- Outros
                          ,pr_tpocorrencia  => 2   -- Erro nao tratado
                          ,pr_cdcriticidade => 3   -- Critica
                          ,pr_cdmensagem    => 0
                          ,pr_dsmensagem    => ' Module: AGRP0001 '||vr_dscritic||sqlerrm
                          ,pr_idprglog      => vr_idprglog);

end;
/