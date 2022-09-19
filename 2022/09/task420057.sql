begin

update cecred.crapprm set DSVLRPRM = 9 where cdacesso = 'DATA_LIMITE_INTEGRA_IPCA';

commit;
end;
