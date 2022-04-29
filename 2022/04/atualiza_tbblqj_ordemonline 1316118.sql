BEGIN
  update tbblqj_ordem_online set dslog_erro = 'TESTE' where idordem in (1316118);
  COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;  
END;
