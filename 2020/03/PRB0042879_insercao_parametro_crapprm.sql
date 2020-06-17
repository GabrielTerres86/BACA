declare
  cursor cr_crapprm is
    select prm.nmsistem
          ,prm.cdcooper
          ,'QTD_PARALE_CRPS750_DIA' cdacesso
          ,'Quantidade de PAs rodando em paralelo no CRPS750 nas execucoes ao longo do dia' dstexprm
          ,'5' dsvlrprm
      from crapprm prm
     where prm.nmsistem = 'CRED'
       and prm.cdacesso = 'QTD_PARALE_CRPS750';
begin
  for rw_crapprm in cr_crapprm loop
    insert into crapprm(nmsistem
                       ,cdcooper
                       ,cdacesso
                       ,dstexprm
                       ,dsvlrprm
                       )
                 values(rw_crapprm.nmsistem
                       ,rw_crapprm.cdcooper
                       ,rw_crapprm.cdacesso
                       ,rw_crapprm.dstexprm
                       ,rw_crapprm.dsvlrprm
                       );
    commit;
  end loop;
end;
