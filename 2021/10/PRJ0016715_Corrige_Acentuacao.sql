BEGIN
  UPDATE recuperacao.tbrecup_dominio_campo
     SET dscodigo = 'Renegociação'
   WHERE nmdominio = 'TIPO_MODELO_ACORDO'
     AND cddominio = '3';

  UPDATE recuperacao.tbrecup_dominio_campo
     SET dscodigo = 'Empréstimo'
   WHERE nmdominio = 'CDORIGEM_CONTRATO'
     AND cddominio = '2';

  UPDATE recuperacao.tbrecup_dominio_campo
     SET dscodigo = 'Empréstimo'
   WHERE nmdominio = 'CDORIGEM_CONTRATO'
     AND cddominio = '3';

  UPDATE recuperacao.tbrecup_dominio_campo
     SET dscodigo = 'Desconto de Título'
   WHERE nmdominio = 'CDORIGEM_CONTRATO'
     AND cddominio = '4';

  UPDATE recuperacao.tbrecup_dominio_campo
     SET dscodigo = 'Fatura Cartão'
   WHERE nmdominio = 'CDORIGEM_CONTRATO'
     AND cddominio = '5';
  COMMIT;
END;