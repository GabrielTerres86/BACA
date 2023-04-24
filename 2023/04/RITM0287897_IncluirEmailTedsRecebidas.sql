BEGIN
  UPDATE cecred.tbcobran_param_protesto tpp
     SET tpp.dsemail_cobranca = tpp.dsemail_cobranca || ';' || 'contabilidade01@ailos.coop.br',
         tpp.dsemail_ieptb    = tpp.dsemail_ieptb || ';' || 'conciliacao@cartoriosdeprotesto.br';
  COMMIT;         
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    SISTEMA.excecaoInterna (pr_cdcooper => 3);
END;
