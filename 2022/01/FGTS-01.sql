begin
update crapprm set crapprm.dsvlrprm = 'A' WHERE crapprm.cdcooper = 1 AND crapprm.cdacesso = 'FLG_PAG_FGTS' AND crapprm.nmsistem = 'CRED';
COMMIT;
end;