DECLARE


  vr_cdprogra VARCHAR2(50) := 'LimpezaCargaRisco';
  vr_dsplsql  VARCHAR2(4000);
  vr_jobname  VARCHAR2(4000);
  vr_dscritic VARCHAR2(4000);
   
  CURSOR cr_crapcop IS
    SELECT cop.cdcooper 
      FROM crapcop cop
     WHERE cop.flgativo = 1
     ORDER BY cop.cdcooper DESC;  
    
BEGIN
  
  FOR rw_crapcop IN cr_crapcop LOOP
    
  
    vr_jobname := 'LIMPARISCO' || to_char(rw_crapcop.cdcooper) || '_P';
    
    vr_dsplsql := 
    
'DECLARE

  vr_idprglog NUMBER;
  vr_cdcooper NUMBER;
  vr_dslog    varchar2(4000);

  CURSOR cr_carga IS 
    SELECT DISTINCT c.cdcooper, c.dtrefere
      FROM gestaoderisco.tbrisco_central_carga c
     WHERE c.dtrefere < to_date(''30/07/2023'',''DD/MM/RRRR'')
       AND c.dtrefere <> last_day(c.dtrefere)
       AND c.cdcooper = '||rw_crapcop.cdcooper||'
     ORDER BY c.dtrefere, c.cdcooper ;

  CURSOR cr_ope ( pr_dtrefere DATE, pr_cdcooper NUMBER )IS   
    SELECT x.rowid
      FROM gestaoderisco.tbrisco_carga_operacao x 
     WHERE x.idcentral_carga IN (SELECT t.idcentral_carga 
                                   FROM gestaoderisco.tbrisco_central_carga t 
                                  WHERE t.dtrefere = pr_dtrefere 
                                    AND t.cdcooper = pr_cdcooper);

  TYPE typ_ope IS TABLE OF cr_ope%ROWTYPE INDEX BY PLS_INTEGER;
  vr_tab_ope typ_ope;  
  PROCEDURE gerar_log(pr_dslog IN VARCHAR2, pr_dstiplog IN VARCHAR2 DEFAULT ''O'') IS
  BEGIN
    pc_log_programa(pr_dstiplog   => pr_dstiplog,
                    pr_cdprograma => ''LimpezaCargaRisco'',
                    pr_cdcooper   => '||rw_crapcop.cdcooper||',
                    pr_tpexecucao => 2,
                    pr_dsmensagem => pr_dslog,
                    pr_idprglog   => vr_idprglog);
  END;  

BEGIN  

  EXECUTE IMMEDIATE(''ALTER SESSION ENABLE PARALLEL DML'');

  gerar_log(pr_dslog => NULL, pr_dstiplog => ''I'');

  FOR rw_carga IN cr_carga LOOP
    vr_dslog := ''Limpar cargas: ''||rw_carga.cdcooper||''-''||rw_carga.dtrefere;

    DELETE /*+ PARALLEL(5) */ gestaoderisco.tbrisco_operacao_vencimento x 
     WHERE x.idcarga_operacao IN 
     (SELECT o.idcarga_operacao
        FROM gestaoderisco.tbrisco_central_carga t, gestaoderisco.tbrisco_carga_operacao o 
       WHERE t.idcentral_carga = o.idcentral_carga AND t.dtrefere = rw_carga.dtrefere AND t.cdcooper = rw_carga.cdcooper);
                            
    vr_dslog := vr_dslog||chr(13)||''tbrisco_operacao_vencimento: ''||SQL%ROWCOUNT;
    DELETE  /*+ PARALLEL(5) */ gestaoderisco.Tbrisco_Operacao_Limite x 
     WHERE x.idcarga_operacao IN
     (SELECT o.idcarga_operacao FROM gestaoderisco.tbrisco_central_carga t, gestaoderisco.tbrisco_carga_operacao o 
      WHERE t.idcentral_carga = o.idcentral_carga AND t.dtrefere = rw_carga.dtrefere AND t.cdcooper = rw_carga.cdcooper);
vr_dslog := vr_dslog||chr(13)||''Tbrisco_Operacao_Limite: ''||SQL%ROWCOUNT;

    DELETE /*+ PARALLEL(5) */ gestaoderisco.tbrisco_Operacao_Emprestimo x 
     WHERE x.idcarga_operacao IN (SELECT o.idcarga_operacao FROM gestaoderisco.tbrisco_central_carga t, gestaoderisco.tbrisco_carga_operacao o 
           WHERE t.idcentral_carga = o.idcentral_carga AND t.dtrefere = rw_carga.dtrefere AND t.cdcooper = rw_carga.cdcooper);
vr_dslog := vr_dslog||chr(13)||''tbrisco_Operacao_Emprestimo: ''||SQL%ROWCOUNT;

    DELETE /*+ PARALLEL(5) */  gestaoderisco.tbrisco_Operacao_Garantia x 
     WHERE x.idcarga_operacao IN 
     (SELECT o.idcarga_operacao FROM gestaoderisco.tbrisco_central_carga t, gestaoderisco.tbrisco_carga_operacao o 
       WHERE t.idcentral_carga = o.idcentral_carga AND t.dtrefere = rw_carga.dtrefere AND t.cdcooper = rw_carga.cdcooper);
vr_dslog := vr_dslog||chr(13)||''tbrisco_Operacao_Garantia: ''||SQL%ROWCOUNT;

    DELETE /*+ PARALLEL(5) */ gestaoderisco.tbrisco_info_adicional x 
     WHERE x.idcarga_operacao IN 
     (SELECT o.idcarga_operacao FROM gestaoderisco.tbrisco_central_carga t, gestaoderisco.tbrisco_carga_operacao o 
      WHERE t.idcentral_carga = o.idcentral_carga AND t.dtrefere = rw_carga.dtrefere AND t.cdcooper = rw_carga.cdcooper);
vr_dslog := vr_dslog||chr(13)||''tbrisco_info_adicional: ''||SQL%ROWCOUNT;

commit;
    gerar_log(vr_dslog);

  END LOOP;  

commit;  
  gerar_log(pr_dslog => NULL,
            pr_dstiplog => ''F'');
    
END;';

    vr_dscritic := NULL;
    cecred.gene0001.pc_submit_job(pr_cdcooper => rw_crapcop.cdcooper
                                 ,pr_cdprogra => vr_cdprogra        
                                 ,pr_dsplsql  => vr_dsplsql         
                                 ,pr_dthrexe  => SYSTIMESTAMP       
                                 ,pr_interva  => NULL               
                                 ,pr_jobname  => vr_jobname         
                                 ,pr_des_erro => vr_dscritic);
    IF vr_dscritic IS NOT null THEN
      vr_dscritic := vr_dscritic || ' - ' || vr_jobname;      
      dbms_output.put_line(rw_crapcop.cdcooper||' -> '||vr_dscritic);
    END IF;
  
  END LOOP;  
  
  COMMIT;
  
END;  
