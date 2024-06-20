BEGIN
  EXECUTE IMMEDIATE 'DROP PROCEDURE cecred.pc_crps538_carlos';
  EXECUTE IMMEDIATE 'DROP PROCEDURE cecred.pc_crps538_faba';
  EXECUTE IMMEDIATE 'DROP PROCEDURE cecred.pc_crps538_faba2';
  EXECUTE IMMEDIATE 'DROP PROCEDURE cecred.pc_crps538_faba3';
  EXECUTE IMMEDIATE 'DROP PROCEDURE cecred.pc_crps538_tiago';
  EXECUTE IMMEDIATE 'DROP PROCEDURE cecred.pc_crps538_versao';
  commit;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'Drop procedures pc_crps538_*');
END;
