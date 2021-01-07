-- Criar parametro com o código da finalidade de emprestimos para SAC(0800)
BEGIN
  FOR rw_crapcop IN (SELECT cdcooper FROM crapcop c WHERE c.flgativo = 1) LOOP   
    INSERT INTO crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    VALUES ('CRED', rw_crapcop.cdcooper, 'CDFINEMP_EMPR_SAC', 'Código da finalidade de emprestimo para contratações via SAC', '800');
  END LOOP;
  COMMIT;
  EXCEPTION 
    WHEN OTHERS THEN 
      ROLLBACK;
END;