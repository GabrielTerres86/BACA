BEGIN
  INSERT INTO crapprm (crapprm.nmsistem, crapprm.cdcooper, crapprm.cdacesso, crapprm.dstexprm, crapprm.dsvlrprm)
               VALUES ('CRED', 0, 'FLG_DA_ULTDIANO_AILOS', 'Ailos - Flag para habilitar agendamento de d�bito autom�tico para �ltima dia �til do ano (fora da compensa��o).', 0);
                   
  INSERT INTO crapprm (crapprm.nmsistem, crapprm.cdcooper, crapprm.cdacesso, crapprm.dstexprm, crapprm.dsvlrprm)
               VALUES ('CRED', 0, 'FLG_DA_ULTDIANO_BANCOOB', 'Bancoob - Flag para habilitar agendamento de d�bito autom�tico para �ltima dia �til do ano (fora da compensa��o).', 0);  
               
  UPDATE crapaca
     SET crapaca.lstparam = 'pr_vrdupgto,pr_fgdupgto,pr_daultutilailos,pr_daultutilbancoob'
  WHERE crapaca.nmdeacao = 'ALTERA_PARAMETRO_PARHPG'; 
             
  COMMIT;  
END;            
