begin
  update cecred.crapprm set dsvlrprm=1 where cdacesso = 'ANALISE_DICT_BLQ_CAUT';
  commit;
end;