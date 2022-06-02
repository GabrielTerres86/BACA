begin

UPDATE crapprm p
SET p.dsvlrprm = 'filetransfer.icatuseguros.com.brTESTE'
WHERE p.cdacesso = 'PRST_FTP_ENDERECO';

commit;

end;