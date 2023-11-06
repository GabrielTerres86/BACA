DECLARE 
  
  CURSOR cr_carga IS 
    SELECT DISTINCT c.cdcooper, c.dtrefere
      FROM gestaoderisco.tbrisco_central_carga c
     WHERE c.dtrefere < to_date('30/03/2023','DD/MM/RRRR')
       AND c.dtrefere <> last_day(c.dtrefere)
       AND c.cdcooper IN (1)
     ORDER BY c.dtrefere, c.cdcooper ;
     
  CURSOR cr_ope ( pr_dtrefere DATE,
                  pr_cdcooper NUMBER )IS   
    SELECT x.rowid
      FROM gestaoderisco.tbrisco_carga_operacao x 
     WHERE x.idcentral_carga IN (SELECT t.idcentral_carga 
                                   FROM gestaoderisco.tbrisco_central_carga t 
                                  WHERE t.dtrefere = pr_dtrefere 
                                    AND t.cdcooper = pr_cdcooper);

  TYPE typ_ope IS TABLE OF cr_ope%ROWTYPE INDEX BY PLS_INTEGER;
  vr_tab_ope typ_ope;
                                      

  PROCEDURE gerar_log(pr_dslog IN VARCHAR2) IS
  BEGIN
    dbms_output.put_line(to_char(SYSDATE,'DD/MM/RRRR HH24:MI:SS')||' -> '||pr_dslog);
  END;  
       
BEGIN  
  
  EXECUTE IMMEDIATE('ALTER SESSION ENABLE PARALLEL DML');
  dbms_output.enable(NULL);
  
  FOR rw_carga IN cr_carga LOOP
    gerar_log('');
    gerar_log('Limpar cargas: '||rw_carga.cdcooper||'-'||rw_carga.dtrefere);
    
    DELETE /*+ PARALLEL(15) */ gestaoderisco.tbrisco_operacao_vencimento x 
     WHERE x.idcarga_operacao IN (SELECT o.idcarga_operacao
                                    FROM gestaoderisco.tbrisco_central_carga t,
                                         gestaoderisco.tbrisco_carga_operacao o 
                                   WHERE t.idcentral_carga = o.idcentral_carga 
                                     AND t.dtrefere = rw_carga.dtrefere
                                     AND t.cdcooper = rw_carga.cdcooper);
                                     
    gerar_log('tbrisco_operacao_vencimento: '||SQL%ROWCOUNT);
    DELETE  /*+ PARALLEL(10) */ gestaoderisco.Tbrisco_Operacao_Limite x 
     WHERE x.idcarga_operacao IN (SELECT o.idcarga_operacao
                                    FROM gestaoderisco.tbrisco_central_carga t,
                                         gestaoderisco.tbrisco_carga_operacao o 
                                   WHERE t.idcentral_carga = o.idcentral_carga 
                                     AND t.dtrefere = rw_carga.dtrefere
                                     AND t.cdcooper = rw_carga.cdcooper);
    gerar_log('Tbrisco_Operacao_Limite: '||SQL%ROWCOUNT);
    
    DELETE /*+ PARALLEL(15) */ gestaoderisco.tbrisco_Operacao_Emprestimo x 
     WHERE x.idcarga_operacao IN (SELECT o.idcarga_operacao
                                    FROM gestaoderisco.tbrisco_central_carga t,
                                         gestaoderisco.tbrisco_carga_operacao o 
                                   WHERE t.idcentral_carga = o.idcentral_carga 
                                     AND t.dtrefere = rw_carga.dtrefere
                                     AND t.cdcooper = rw_carga.cdcooper);
    gerar_log('tbrisco_Operacao_Emprestimo: '||SQL%ROWCOUNT);
    
    DELETE /*+ PARALLEL(10) */  gestaoderisco.tbrisco_Operacao_Garantia x 
     WHERE x.idcarga_operacao IN (SELECT o.idcarga_operacao
                                    FROM gestaoderisco.tbrisco_central_carga t,
                                         gestaoderisco.tbrisco_carga_operacao o 
                                   WHERE t.idcentral_carga = o.idcentral_carga 
                                     AND t.dtrefere = rw_carga.dtrefere
                                     AND t.cdcooper = rw_carga.cdcooper);
    gerar_log('tbrisco_Operacao_Garantia: '||SQL%ROWCOUNT);
    
    DELETE /*+ PARALLEL(10) */ gestaoderisco.tbrisco_info_adicional x 
     WHERE x.idcarga_operacao IN (SELECT o.idcarga_operacao
                                    FROM gestaoderisco.tbrisco_central_carga t,
                                         gestaoderisco.tbrisco_carga_operacao o 
                                   WHERE t.idcentral_carga = o.idcentral_carga 
                                     AND t.dtrefere = rw_carga.dtrefere
                                     AND t.cdcooper = rw_carga.cdcooper);
    gerar_log('tbrisco_info_adicional: '||SQL%ROWCOUNT);    
    
    COMMIT;
    
    gerar_log('Fim cargas: '||rw_carga.cdcooper||'-'||rw_carga.dtrefere);    
    
  END LOOP;  
  
  COMMIT;
  gerar_log('Concluido');
  
END;
