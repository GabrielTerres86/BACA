BEGIN
  UPDATE crapprm
  SET  crapprm.dsvlrprm = '3373'
  WHERE crapprm.nmsistem = 'CRED' 
    and crapprm.cdcooper = 3 
    and crapprm.cdacesso = 'RECCEL_AGENCIA_REPASSE';
     
  UPDATE crapprm
  SET  crapprm.dsvlrprm = '07.259.917/0001-54'
  WHERE crapprm.nmsistem = 'CRED' 
    and crapprm.cdcooper = 3 
    and crapprm.cdacesso = 'RECCEL_CNPJ_REPASSE';

  UPDATE crapprm
  SET  crapprm.dsvlrprm = '3373'
  WHERE crapprm.nmsistem = 'CRED' 
    and crapprm.cdcooper = 3 
    and crapprm.cdacesso = 'RECCEL_CONTA_REPASSE';

  UPDATE crapprm
  SET  crapprm.dsvlrprm = '1450-8'
  WHERE crapprm.nmsistem = 'CRED' 
    and crapprm.cdcooper = 3 
    and crapprm.cdacesso = 'RECCEL_AGENCIA_REPASSE';

  UPDATE crapprm
  SET  crapprm.dsvlrprm = 'DBR DISTRIBUIDORA BRASILEIRA DE RECARGAS LTDA'
  WHERE crapprm.nmsistem = 'CRED' 
    and crapprm.cdcooper = 3 
    and crapprm.cdacesso = 'RECCEL_NOME_REPASSE';
  
  COMMIT;
END;