create or replace trigger cecred.trg_craplim_historico
  after update of tprenova, dtrenova, vllimite
  on craplim
  for each row
declare
  vr_dscritic varchar2(1000) := ' ';
  err_insert  exception;

  procedure pc_insere_historico(pr_nmcampo          in varchar2
                               ,pr_dsvalor_anterior in varchar2
                               ,pr_dsvalor_novo     in varchar2) is
  begin
    insert into tblimcre_historico(cdcooper
                                  ,nrdconta
                                  ,tpctrlim
                                  ,nrctrlim
                                  ,nrsequencia
                                  ,dhalteracao
                                  ,tpoperacao
                                  ,nmcampo
                                  ,dsvalor_anterior
                                  ,dsvalor_novo
                                  ,cdoperad_altera)
                                  values
                                 (:new.cdcooper
                                 ,:new.nrdconta
                                 ,:new.tpctrlim
                                 ,:new.nrctrlim
                                 ,1
                                 ,sysdate
                                 ,2
                                 ,pr_nmcampo
                                 ,pr_dsvalor_anterior
                                 ,pr_dsvalor_novo
                                 ,gene0001.fn_OSuser);
  exception
    when others then
      vr_dscritic := 'Erro ao gerar historico - TABELA craplim - '||sqlerrm;
      raise err_insert;
  end pc_insere_historico;
begin
  if :new.tpctrlim = 1 then
    if nvl(:old.dtrenova,to_date('01/01/2099','DD/MM/RRRR')) 
          <> nvl(:new.dtrenova,to_date('01/01/2099','DD/MM/RRRR')) then
      pc_insere_historico('dtrenova',nvl(to_char(:old.dtrenova,'DD/MM/YYYY'),' '),nvl(to_char(:new.dtrenova,'DD/MM/YYYY'),' '));
      pc_insere_historico('tprenova',nvl(:old.tprenova,' '),nvl(:new.tprenova,' '));
    end if;

    if  nvl(:old.vllimite,0) <> nvl(:new.vllimite,0)
	and nvl(:new.insitlim,:old.insitlim) <> 1 then
      pc_insere_historico('vllimite',nvl(:old.vllimite,0),nvl(:new.vllimite,0));
    end if;
  end if;
exception
  when err_insert then
    raise_application_error(-20100,vr_dscritic);
  when others then
    raise_application_error(-20101,'Erro ao gerar historico - TABELA craplim - '||sqlerrm);
end trg_craplim_historico;
/
