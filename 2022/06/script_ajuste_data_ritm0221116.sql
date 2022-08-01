BEGIN

  UPDATE credito.TBEPR_PARCELAS_CRED_IMOB p
     SET p.dtvencto = to_date('02/06/2022', 'dd/mm/RRRR')
   WHERE TRIM(p.dsnosnum) = '000000000000564'
     AND p.cdcooper = 1;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    raise_application_error(-20000, 'ERRO: ' || SQLERRM);
END;
