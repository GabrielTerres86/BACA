BEGIN
  EXECUTE IMMEDIATE 'DROP PROCEDURE cecred.pc_crps538_carlos';
  EXECUTE IMMEDIATE 'DROP PROCEDURE cecred.pc_crps538_faba';
  EXECUTE IMMEDIATE 'DROP PROCEDURE cecred.pc_crps538_faba2';
  EXECUTE IMMEDIATE 'DROP PROCEDURE cecred.pc_crps538_faba3';
  EXECUTE IMMEDIATE 'DROP PROCEDURE cecred.pc_crps538_tiago';
  EXECUTE IMMEDIATE 'DROP PROCEDURE cecred.pc_crps538_versao';
  drop public synonym PC_CRPS538_TIAGO;
  drop public synonym PC_CRPS538_FABA2;
  drop public synonym PC_CRPS538_CARLOS;
  drop public synonym PC_CRPS538_FABA;
  drop public synonym PC_CRPS538_VERSAO;
  drop public synonym PC_CRPS538_FABA3;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'Drop procedures pc_crps538_*');
END;
