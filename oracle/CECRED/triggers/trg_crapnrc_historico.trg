create or replace trigger cecred.trg_crapnrc_historico
  after insert or update of insitrat, dtmvtolt, nrnotrat, nrnotatl
  on crapnrc
  for each row
declare
  vr_cdcritic crapcri.cdcritic%type;
  vr_dscritic crapcri.dscritic%type;
  err_sequen  exception;
  err_insert  exception;
  vr_nrsequen number(3);
  vr_vlrating number;
  vr_insitrat number;
  vr_exc_erro exception;

  function fn_retorna_sequencia(pr_cdcooper in number
                               ,pr_nrdconta in number
                               ,pr_nrctrrat in number
                               ,pr_tpctrrat in number) return number is
    cursor c1 is
      select nvl(max(nrseqrat),0) + 1
        from tbrat_hist_nota_contrato
       where cdcooper = pr_cdcooper
         and nrdconta = pr_nrdconta
         and nrctrrat = pr_nrctrrat
         and tpctrrat = pr_tpctrrat;
    
    vr_sequen number(3);
  begin
    open c1;
    fetch c1 into vr_sequen;
    close c1;
    
    return vr_sequen;
  exception
    when others then
      vr_dscritic := 'Erro ao buscar sequencia - TABELA tbrat_hist_nota_contrato - '||sqlerrm;
      raise err_sequen;
  end fn_retorna_sequencia;
begin
  rati0001.pc_param_valor_rating(pr_cdcooper => :new.cdcooper --> Código da Cooperativa
                                ,pr_vlrating => vr_vlrating --> Valor parametrizado
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);

  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;

  if nvl(:new.vlutlrat,0) >= nvl(vr_vlrating,0) then
    vr_insitrat := 2;
  else
    vr_insitrat := 1;
  end if;

  if nvl(:old.dtmvtolt,to_date('01/01/2099','DD/MM/RRRR')) <> nvl(:new.dtmvtolt,to_date('01/01/2099','DD/MM/RRRR'))
  or nvl(:old.nrnotrat,0) <> nvl(:new.nrnotrat,0)
  or nvl(:old.nrnotatl,0) <> nvl(:new.nrnotatl,0) then
    begin
      vr_nrsequen := fn_retorna_sequencia(:new.cdcooper, :new.nrdconta, :new.nrctrrat, :new.tpctrrat);  
      
      insert into tbrat_hist_nota_contrato(cdcooper
                                          ,nrdconta
                                          ,nrctrrat
                                          ,tpctrrat
                                          ,nrseqrat
                                          ,indrisco
                                          ,insitrat
                                          ,nrnotrat
                                          ,vlutlrat
                                          ,dtmvtolt
                                          ,nrnotatl
                                          ,inrisctl) values (:new.cdcooper
                                                            ,:new.nrdconta
                                                            ,:new.nrctrrat
                                                            ,:new.tpctrrat
                                                            ,vr_nrsequen
                                                            ,:new.indrisco
                                                            ,vr_insitrat
                                                            ,:new.nrnotrat
                                                            ,:new.vlutlrat
                                                            ,:new.dtmvtolt
                                                            ,:new.nrnotatl
                                                            ,:new.inrisctl);
    exception
      when others then
        vr_dscritic := 'Erro ao inserir historico - TABELA tbrat_hist_nota_contrato - '||sqlerrm;
        raise err_insert;
    end;
  end if;
exception
  WHEN vr_exc_erro THEN
    IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    
    raise_application_error(-20103,vr_dscritic);
  when err_sequen then
    raise_application_error(-20100,vr_dscritic);
  when err_insert then
    raise_application_error(-20101,vr_dscritic);
  when others then
    raise_application_error(-20102,'Erro ao gerar historico - TABELA crapnrc - '||sqlerrm);
end trg_crapnrc_historico;
/
