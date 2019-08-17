declare

  /* Duas cooperativas em 1,747 */
  /* Todas as coopers  em 5,912 */
  /* Todas as coopers  em 5,273 */  

  cursor cr_crapcop is
  select cop.cdcooper 
    from crapcop cop
   order
      by cop.cdcooper;
   
  pr_tpmoefix02 number := 2;
  pr_tpmoefix12 number := 12;
  vr_idprglog   number := 0;
  vr_exc_saida  exception;
  vr_dscritic   varchar2(4000);  
  vr_cdprogra   varchar2(40) := 'SCRIPT-CRAPMFX';

begin
       
  -- Gera log no início da execução
  pc_log_programa(pr_dstiplog   => 'I'         
                 ,pr_cdprograma => vr_cdprogra 
                 ,pr_cdcooper   => 0
                 ,pr_tpexecucao => 0                    
                 ,pr_idprglog   => vr_idprglog);
  
  begin
    -- Realiza ajuste na altovale
    insert into crapmfx (dtmvtolt, tpmoefix, vlmoefix, cdcooper)
         values (to_date('12/02/2019','dd/mm/yyyy'),12,0.8287,16);
  exception
    when others then
      vr_dscritic := 'Erro ao ajustar altovale: '||sqlerrm;
      raise vr_exc_saida;
  end;

  -- Loop em todas as cooperativas
  for rw_crapcop in cr_crapcop loop
  
    begin
      -- Insere moeda 2
      insert into crapmfx (dtmvtolt, tpmoefix, vlmoefix, cdcooper)
      select contador.dtmvtolt dtmvtolt
           , pr_tpmoefix02     tpmoefix
           , 0.8287            vlmoefix
           , cop.cdcooper      cdcooper
        from crapcop cop
           , (select (to_date('28/02/2019','dd/mm/yyyy') + rownum) dtmvtolt 
                from craplcm
               where rownum < 10000) contador
       where cop.cdcooper = rw_crapcop.cdcooper
         and contador.dtmvtolt < to_char(add_months(trunc(sysdate)+1,12*10),'dd/mm/yyyy');
    exception
      when others then
        vr_dscritic := 'Erro ao inserir crapmfx(2): '||sqlerrm;
        raise vr_exc_saida;
    end;
    
    begin     
      -- Insere moeda 12     
      insert into crapmfx (dtmvtolt, tpmoefix, vlmoefix, cdcooper)
      select contador.dtmvtolt dtmvtolt
           , pr_tpmoefix12     tpmoefix
           , 0.8287            vlmoefix
           , cop.cdcooper      cdcooper
        from crapcop cop
           , (select (to_date('28/02/2019','dd/mm/yyyy') + rownum) dtmvtolt 
                from craplcm
               where rownum < 10000) contador
       where cop.cdcooper = rw_crapcop.cdcooper
         and contador.dtmvtolt < to_char(add_months(trunc(sysdate)+1,12*10),'dd/mm/yyyy');
    exception
      when others then
        vr_dscritic := 'Erro ao inserir crapmfx(12): '||sqlerrm;
        raise vr_exc_saida;
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

  commit;

exception
  
  when vr_exc_saida then
    
    rollback;
    
    -- Gera log no fim da execução
    pc_log_programa(pr_dstiplog   => 'F'         
                   ,pr_cdprograma => vr_cdprogra 
                   ,pr_cdcooper   => 0
                   ,pr_tpexecucao => 0    
                   ,pr_flgsucesso => 1             
                   ,pr_idprglog   => vr_idprglog);
                   
     -- Grava critica na tabela
     cecred.pc_log_programa(pr_dstiplog      => 'E' -- Erro
                           ,pr_cdprograma    => vr_cdprogra
                           ,pr_cdcooper      => 0
                           ,pr_tpexecucao    => 2   -- Job
                           ,pr_tpocorrencia  => 2   -- Erro nao tratado
                           ,pr_cdcriticidade => 3   -- Critica
                           ,pr_cdmensagem    => 0
                           ,pr_dsmensagem    => ' Module: Saida'||vr_dscritic
                           ,pr_idprglog      => vr_idprglog);
    
  when others then
    
    rollback;
    
    -- Gera log no fim da execução
    pc_log_programa(pr_dstiplog   => 'F'         
                   ,pr_cdprograma => vr_cdprogra 
                   ,pr_cdcooper   => 0
                   ,pr_tpexecucao => 0    
                   ,pr_flgsucesso => 1             
                   ,pr_idprglog   => vr_idprglog);
                   
     -- Grava critica na tabela
     cecred.pc_log_programa(pr_dstiplog      => 'E' -- Erro
                           ,pr_cdprograma    => vr_cdprogra
                           ,pr_cdcooper      => 0
                           ,pr_tpexecucao    => 2   -- Job
                           ,pr_tpocorrencia  => 2   -- Erro nao tratado
                           ,pr_cdcriticidade => 3   -- Critica
                           ,pr_cdmensagem    => 0
                           ,pr_dsmensagem    => ' Module: Nao Tratado '||vr_dscritic||sqlerrm
                           ,pr_idprglog      => vr_idprglog);

end;