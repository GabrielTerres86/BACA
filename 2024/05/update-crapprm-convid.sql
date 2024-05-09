BEGIN
  UPDATE cecred.crapprm p
     SET p.dsvlrprm = 12
   WHERE p.cdacesso IN ('COVID_QTDE_PARCELA_PAGAR')
     AND p.cdcooper = 9;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
