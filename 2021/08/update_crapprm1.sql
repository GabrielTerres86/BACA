begin

update crapprm set
crapprm.dsvlrprm = '0'
where crapprm.cdacesso = 'DARF_SEM_BARRA_RFB';

commit;
end;