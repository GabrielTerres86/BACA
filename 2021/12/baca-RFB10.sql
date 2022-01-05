begin
update crapprm set
 crapprm.dsvlrprm = '' where crapprm.cdacesso like '%EMAIL_REPASSE_FGTS%';
commit;

end;