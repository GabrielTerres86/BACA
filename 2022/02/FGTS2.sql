begin

update crapprm set crapprm.dsvlrprm = 'convenios@ailos.coop.br' WHERE crapprm.cdacesso like '%EMAIL_REPASSE_FGTS%';
COMMIT;

end;