BEGIN

  UPDATE CECRED.CRAWEPR
     SET DSOBSCMT = '1 - AJUSTAR PROPOSTA COM AS LINHAS QUE ESTAO DISPONIVEIS NO PAINEL DE CREDITO. ORIENTAMOS USO DA LC 25501 VISTO MEDIA PONDERADA DOS CTRS EM 2,79%, JA HAVENDO REDUCAO DE TAXA, SENDO QUE AINDA ESTAREMOS REFINANCIANDO LIMITE.AJUSTANDO LC, VIES FAVORAVEL AO REFIN DE CTRS + LIMITE, SEM SOBRAS E COM LIMITE SENDO CANCELADO PARA NAO HAVER LIBERACAO DE NOVOS RECURSOS VISTO QUE JA POSSUI REFIN COM BAIXA MATURACAO, ALEM DE SAQUE DE COTAS RECENTE. RISCO ATUAL EM D, COTAS OK.'
   WHERE PROGRESS_RECID = 11087763;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;