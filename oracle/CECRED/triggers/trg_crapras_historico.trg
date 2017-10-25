create or replace trigger cecred.trg_crapras_historico
  after insert or update
  on crapras
  for each row
declare
  vr_dscritic crapcri.dscritic%type;
  err_sequen  exception;
  err_insert  exception;
  vr_nrsequen number(3);

  function fn_retorna_sequencia(pr_cdcooper in number
                               ,pr_nrdconta in number
                               ,pr_nrctrrat in number
                               ,pr_tpctrrat in number
							                 ,pr_nrtopico in number
              							   ,pr_nritetop in number) return number is
    cursor c1 is
      select nvl(max(nrseqrat),0) + 1
        from tbrat_hist_cooperado
       where cdcooper = pr_cdcooper
         and nrdconta = pr_nrdconta
         and nrctrrat = pr_nrctrrat
         and tpctrrat = pr_tpctrrat
		     and nrtopico = pr_nrtopico
    		 and nritetop = pr_nritetop;
    
    vr_sequen number(3);
  begin
    open c1;
    fetch c1 into vr_sequen;
    close c1;
    
    return vr_sequen;
  exception
    when others then
      vr_dscritic := 'Erro ao buscar sequencia - TABELA tbrat_hist_cooperado - '||sqlerrm;
      raise err_sequen;
  end fn_retorna_sequencia;
begin
  begin
    vr_nrsequen := fn_retorna_sequencia(:new.cdcooper, :new.nrdconta, :new.nrctrrat, :new.tpctrrat, :new.nrtopico, :new.nritetop);  
    
    insert into tbrat_hist_cooperado(cdcooper
                                    ,nrdconta
                                    ,nrctrrat
                                    ,tpctrrat
                                    ,nrseqrat
                                    ,nrtopico
                                    ,nritetop
                                    ,nrseqite
                                    ,dsvalite
                                    ,dtmvtolt) values (:new.cdcooper
                                                      ,:new.nrdconta
                                                      ,:new.nrctrrat
                                                      ,:new.tpctrrat
                                                      ,vr_nrsequen
                                                      ,:new.nrtopico
                                                      ,:new.nritetop
                                                      ,:new.nrseqite
                                                      ,:new.dsvalite
                                                      ,sysdate);
  exception
    when others then
      vr_dscritic := 'Erro ao inserir historico - TABELA tbrat_hist_cooperado - '||sqlerrm;
      raise err_insert;
  end;
exception
  when err_sequen then
    raise_application_error(-20100,vr_dscritic);
  when err_insert then
    raise_application_error(-20101,vr_dscritic);
  when others then
    raise_application_error(-20102,'Erro ao gerar historico - TABELA crapras - '||sqlerrm);
end trg_crapras_historico;
/
