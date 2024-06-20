BEGIN
  drop procedure cecred.pc_crps538_carlos;
  drop procedure cecred.pc_crps538_faba;
  drop procedure cecred.pc_crps538_faba2;
  drop procedure cecred.pc_crps538_faba3;
  drop procedure cecred.pc_crps538_tiago;
  drop procedure cecred.pc_crps538_versao;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'Drop procedures pc_crps538_*');
END;
