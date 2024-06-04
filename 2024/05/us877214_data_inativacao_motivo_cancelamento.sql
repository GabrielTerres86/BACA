BEGIN
  UPDATE pagamento.tbpagto_motivo_cancelamento_baixa tmcb
     SET tmcb.dhinativacao = SYSDATE
   WHERE tmcb.cdmotivo_cancelamento_baixa IN (40, 52, 53, 63, 69, 71, 75, 83, 85)
     AND tmcb.dhinativacao IS NULL;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    cecred.pc_internal_exception(pr_cdcooper => 3,pr_compleme => 'Script inativacao motivo cancelamento');
    ROLLBACK;
    RAISE;
END;