begin

update crapprm prm
   set prm.dsvlrprm = 'sippe-emi-ws01/api/v1/altaDeContaCartao'                                                                                      
 WHERE prm.nmsistem = 'CRED'
   AND prm.cdcooper = 0
   AND prm.cdacesso = 'URI_WEBSRV_BANCOOB_01';

commit;

end;