BEGIN
  UPDATE CECRED.craptit tit
     SET tit.dhrecebimento_titulo = to_date('30-12-2023 15:24:51', 'dd-mm-yyyy hh24:mi:ss')
   WHERE tit.progress_recid = 209284925;

  UPDATE CECRED.craptit tit
     SET tit.dhrecebimento_titulo = to_date('31-12-2023 15:27:10', 'dd-mm-yyyy hh24:mi:ss')
   WHERE tit.progress_recid = 209284926;

  UPDATE CECRED.craptit tit
     SET tit.dhrecebimento_titulo = to_date('01-01-2024 15:28:49', 'dd-mm-yyyy hh24:mi:ss')
   WHERE tit.progress_recid = 209284927;

  UPDATE CECRED.craptit tit
     SET tit.dhrecebimento_titulo = to_date('04-01-2024 08:05:34', 'dd-mm-yyyy hh24:mi:ss')
   WHERE tit.progress_recid = 209284929;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna;
    ROLLBACK;
END;