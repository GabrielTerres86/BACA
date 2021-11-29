BEGIN

  INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) 
               VALUES ('CRED', 3, 'HR_INI_AGND_LMT_NTRN_TED', 'Horário inicial para limite de agendamento noturno, regulatório PRJ0023774', '20:00');
               
  INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) 
               VALUES ('CRED', 3, 'HR_FIM_AGND_LMT_NTRN_TED', 'Horário final para limite de agendamento noturno, regulatório PRJ0023774', '06:00');             

  COMMIT;
  
EXCEPTION
 WHEN OTHERS THEN
  NULL;
END;
