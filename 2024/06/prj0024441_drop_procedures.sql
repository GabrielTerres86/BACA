BEGIN
  EXECUTE IMMEDIATE 'DROP PROCEDURE cecred.pc_crps538_carlos';
  EXECUTE IMMEDIATE 'DROP PROCEDURE cecred.pc_crps538_faba';
  EXECUTE IMMEDIATE 'DROP PROCEDURE cecred.pc_crps538_faba2';
  EXECUTE IMMEDIATE 'DROP PROCEDURE cecred.pc_crps538_faba3';
  EXECUTE IMMEDIATE 'DROP PROCEDURE cecred.pc_crps538_tiago';
  EXECUTE IMMEDIATE 'DROP PROCEDURE cecred.pc_crps538_versao';
  EXECUTE IMMEDIATE 'drop public synonym PC_CRPS538_TIAGO';
  EXECUTE IMMEDIATE 'drop public synonym PC_CRPS538_FABA2';
  EXECUTE IMMEDIATE 'drop public synonym PC_CRPS538_CARLOS';
  EXECUTE IMMEDIATE 'drop public synonym PC_CRPS538_FABA';
  EXECUTE IMMEDIATE 'drop public synonym PC_CRPS538_VERSAO';
  EXECUTE IMMEDIATE 'drop public synonym PC_CRPS538_FABA3';
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'Drop procedures pc_crps538_*');
END;