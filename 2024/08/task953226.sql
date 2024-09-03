DECLARE
  vr_idprglog  tbgen_prglog.idprglog%TYPE := 0;

BEGIN

  insert into cecred.crapmpc (CDPRODUT, QTDIACAR, QTDIAPRZ, VLRFAIXA, VLPERREN, VLTXFIXA)
  values (1007, 30, 3600, 0.01, 86.000000, 0.000000);

  insert into cecred.crapmpc (CDPRODUT, QTDIACAR, QTDIAPRZ, VLRFAIXA, VLPERREN, VLTXFIXA)
  values (1007, 30, 3600, 0.01, 87.000000, 0.000000);

  insert into cecred.crapmpc (CDPRODUT, QTDIACAR, QTDIAPRZ, VLRFAIXA, VLPERREN, VLTXFIXA)
  values (1007, 30, 3600, 0.01, 89.000000, 0.000000);

  insert into cecred.crapmpc (CDPRODUT, QTDIACAR, QTDIAPRZ, VLRFAIXA, VLPERREN, VLTXFIXA)
  values (1007, 30, 3600, 0.01, 91.000000, 0.000000);

  insert into cecred.crapmpc (CDPRODUT, QTDIACAR, QTDIAPRZ, VLRFAIXA, VLPERREN, VLTXFIXA)
  values (1007, 30, 3600, 0.01, 93.000000, 0.000000);

  insert into cecred.crapmpc (CDPRODUT, QTDIACAR, QTDIAPRZ, VLRFAIXA, VLPERREN, VLTXFIXA)
  values (1007, 30, 3600, 0.01, 95.000000, 0.000000);

  insert into cecred.crapmpc (CDPRODUT, QTDIACAR, QTDIAPRZ, VLRFAIXA, VLPERREN, VLTXFIXA)
  values (1007, 30, 3600, 0.01, 96.000000, 0.000000);

  insert into cecred.crapmpc (CDPRODUT, QTDIACAR, QTDIAPRZ, VLRFAIXA, VLPERREN, VLTXFIXA)
  values (1007, 30, 3600, 0.01, 97.000000, 0.000000);

  insert into cecred.crapmpc (CDPRODUT, QTDIACAR, QTDIAPRZ, VLRFAIXA, VLPERREN, VLTXFIXA)
  values (1007, 30, 3600, 0.01, 98.000000, 0.000000);

  insert into cecred.crapmpc (CDPRODUT, QTDIACAR, QTDIAPRZ, VLRFAIXA, VLPERREN, VLTXFIXA)
  values (1007, 30, 3600, 0.01, 99.000000, 0.000000);
  
  COMMIT;
  
  EXCEPTION  
    WHEN OTHERS THEN
    
    ROLLBACK;
    
    CECRED.pc_log_programa(pr_dstiplog   => 'O',
                           pr_dsmensagem => SQLERRM,
                           pr_cdmensagem => 999,
                           pr_cdprograma => 'RITM0419066',
                           pr_cdcooper   => 3,
                           pr_idprglog   => vr_idprglog);
END;  
