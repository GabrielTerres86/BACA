BEGIN
  dbms_scheduler.disable ('CECRED.JBEPR_PAGAMENTOS_01');
  dbms_scheduler.disable ('CECRED.JBEPR_PAGAMENTOS_02');
  dbms_scheduler.disable ('CECRED.JBTARIF_DEBITA_TARIFA_PEND');
END;
/

COMMIT;

