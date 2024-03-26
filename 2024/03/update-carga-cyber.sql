BEGIN
  UPDATE cecred.crapprm a
     SET a.dsvlrprm = '25/03/2024#1'
   WHERE a.cdacesso = 'CTRL_CRPS652_A_EXEC';
  COMMIT;

  UPDATE cecred.crapcyb a
     SET a.dtdbaixa = NULL
   WHERE a.dtdbaixa = to_date('25/03/2024', 'dd/mm/rrrr');
  COMMIT;
END;
