DECLARE

  vr_dscritic VARCHAR2(1000);
  
BEGIN
  
  DELETE FROM tbgen_debitador_horario_proc WHERE cdprocesso IN ('PC_CRPS642','PC_CRPS642_PRIORI') AND idhora_processamento = 4;
  UPDATE crapprm SET crapprm.dsvlrprm = '3' WHERE crapprm.cdacesso IN ('QTD_EXEC_DEBSIC','QTD_EXEC_DEBSIC_PRIORI');
  
  tela_debitador_unico.pc_grava_historico(pr_cdoperador => '1'
                                        , pr_dscampo_alterado => 'idhora_processamento'
                                        , pr_dsvalor_anterior => '19:00'
                                        , pr_dsvalor_novo => NULL
                                        , pr_cdprocesso => 'PC_CRPS642'
                                        , pr_tpoperacao => 3
                                        , pr_tporigem => 1
                                        , pr_inexecuta_commit => 'N'
                                        , pr_dscritic => vr_dscritic);
                                         
  tela_debitador_unico.pc_grava_historico(pr_cdoperador => '1'
                                        , pr_dscampo_alterado => 'idhora_processamento'
                                        , pr_dsvalor_anterior => '19:00'
                                        , pr_dsvalor_novo => NULL
                                        , pr_cdprocesso => 'PC_CRPS642_PRIORI'
                                        , pr_tpoperacao => 3
                                        , pr_tporigem => 1
                                        , pr_inexecuta_commit => 'N'
                                        , pr_dscritic => vr_dscritic);                                         
  
  COMMIT;
  
END;
