BEGIN
  UPDATE recuperacao.tbrecup_dominio_campo
     SET dscodigo = 'Renegocia��o'
   WHERE nmdominio = 'TIPO_MODELO_ACORDO'
     AND cddominio = '3';

  UPDATE recuperacao.tbrecup_dominio_campo
     SET dscodigo = 'Empr�stimo'
   WHERE nmdominio = 'CDORIGEM_CONTRATO'
     AND cddominio = '2';

  UPDATE recuperacao.tbrecup_dominio_campo
     SET dscodigo = 'Empr�stimo'
   WHERE nmdominio = 'CDORIGEM_CONTRATO'
     AND cddominio = '3';

  UPDATE recuperacao.tbrecup_dominio_campo
     SET dscodigo = 'Desconto de T�tulo'
   WHERE nmdominio = 'CDORIGEM_CONTRATO'
     AND cddominio = '4';

  UPDATE recuperacao.tbrecup_dominio_campo
     SET dscodigo = 'Fatura Cart�o'
   WHERE nmdominio = 'CDORIGEM_CONTRATO'
     AND cddominio = '5';
  COMMIT;
END;