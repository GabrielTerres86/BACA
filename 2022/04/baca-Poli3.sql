begin
UPDATE crapprm SET  crapprm.DSVLRPRM = 'S' WHERE crapprm.CDACESSO = 'COMPROVANTE_RFB' AND NMSISTEM='CRED';
commit;
end;