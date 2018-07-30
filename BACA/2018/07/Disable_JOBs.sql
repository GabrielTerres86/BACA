BEGIN
  dbms_scheduler.disable ('CECRED.JBEPR_PAGAMENTOS_01');
  dbms_scheduler.disable ('CECRED.JBEPR_PAGAMENTOS_02');
  dbms_scheduler.disable ('CECRED.JBCRD_DEBITA_FATURA'); 
  dbms_scheduler.disable ('CECRED.JBEPR_MULT_JUR_TR');  
END;
/
commit;