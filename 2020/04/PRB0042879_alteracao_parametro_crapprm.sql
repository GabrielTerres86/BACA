begin
  update crapprm prm
     set prm.dsvlrprm = 15
   where prm.nmsistem = 'CRED'
     and prm.cdacesso = 'QTD_PARALE_CRPS750_DIA';
  commit;
end;
