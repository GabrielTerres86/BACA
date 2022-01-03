begin

update crapprm set crapprm.dsvlrprm = 'A' WHERE crapprm.cdcooper in (7,9) AND crapprm.cdacesso = 'FLG_PAG_FGTS' AND crapprm.nmsistem = 'CRED';
update crapprm set crapprm.dsvlrprm = 'convenios@ailos.coop.br' WHERE crapprm.cdacesso like '%EMAIL_REPASSE_FGTS%';
COMMIT;

end;