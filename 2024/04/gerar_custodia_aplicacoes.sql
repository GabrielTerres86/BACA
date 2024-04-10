declare 
  vr_idaplicacao  cecred.TBCAPT_CUSTODIA_APLICACAO.Idaplicacao%TYPE;
  vr_idlancamento cecred.tbcapt_custodia_lanctos.idlancamento%TYPE;
  countSuccess    INTEGER := 0;
  countErrors     INTEGER := 0;
  TYPE typ_errors IS TABLE OF VARCHAR2(4000) INDEX BY PLS_INTEGER;
  errors typ_errors;
  
  CURSOR cr_lctos_rda IS
    SELECT rda.rowid          rowid_apl,
           lap.rowid          rowid_lct,
           hst.tpaplicacao    tpaplrdc,
           lap.dtmvtolt,
           lap.cdhistor,
           lap.vllanmto,
           hst.idtipo_arquivo,
           hst.idtipo_lancto,
           hst.cdoperacao_b3,
           rda.nrdconta       nrdconta,
           rda.nraplica       nraplica,
           0                  cdprodut
      FROM cecred.craplap lap, cecred.craprda rda, cecred.crapdtc dtc, cecred.vw_capt_histor_operac hst
     WHERE rda.cdcooper = dtc.cdcooper
       AND rda.tpaplica = dtc.tpaplica
       AND lap.cdcooper = rda.cdcooper
       AND lap.nrdconta = rda.nrdconta
       AND lap.nraplica = rda.nraplica
       AND rda.TPAPLICA IN (7, 8)
       AND rda.INSAQTOT = 0
       AND hst.idtipo_arquivo = 1
       AND hst.tpaplicacao = dtc.tpaplrdc
       AND hst.cdhistorico = lap.cdhistor
       AND nvl(rda.idaplcus, 0) = 0
       AND nvl(lap.idlctcus, 0) = 0
       AND rda.dtmvtolt IN (to_date('25/11/2022', 'DD/MM/RRRR'), to_date('05/07/2023', 'DD/MM/RRRR'), to_date('14/09/2023', 'DD/MM/RRRR'), to_date('15/09/2023', 'DD/MM/RRRR'));
    
  CURSOR cr_lctos_rac IS
    SELECT rac.rowid rowid_apl,
           lac.rowid rowid_lct,
           hst.tpaplicacao,
           lac.dtmvtolt,
           lac.cdhistor,
           lac.vllanmto,
           hst.idtipo_arquivo,
           hst.idtipo_lancto,
           hst.cdoperacao_b3,
           rac.nrdconta       nrdconta,
           rac.nraplica       nraplica,
           rac.cdprodut       cdprodut
      FROM cecred.craplac lac, cecred.craprac rac, cecred.vw_capt_histor_operac hst
     WHERE rac.cdcooper = lac.cdcooper
       AND rac.nrdconta = lac.nrdconta
       AND rac.nraplica = lac.nraplica
       AND hst.idtipo_arquivo = 1
       AND hst.tpaplicacao IN (3, 4)
       AND hst.cdprodut = rac.cdprodut
       AND hst.cdhistorico = lac.cdhistor
       AND rac.CDPRODUT IN (1007, 1057)
       AND rac.IDSAQTOT = 0
       AND nvl(rac.idaplcus, 0) = 0
       AND nvl(lac.idlctcus, 0) = 0
       AND rac.dtmvtolt IN (to_date('25/11/2022', 'DD/MM/RRRR'), to_date('05/07/2023', 'DD/MM/RRRR'), to_date('14/09/2023', 'DD/MM/RRRR'), to_date('15/09/2023', 'DD/MM/RRRR'));
   
  PROCEDURE pc_exibir_relatorio_execucao IS
  BEGIN
    dbms_output.put_line('Registros gerados com sucesso: '||countSuccess);
    dbms_output.put_line('Registros com erros: '||countErrors);    
    IF errors.count > 0 THEN
      dbms_output.put_line('Detalhes dos erros: ');  
      FOR erroId IN errors.First..errors.Last LOOP
        dbms_output.put_line(errors(erroId));  
      END LOOP;
    END IF;
  END;
  
  PROCEDURE pc_gerar_custodia_aplicacao(pr_tpaplicacao      IN  cecred.TBCAPT_CUSTODIA_APLICACAO.Tpaplicacao%TYPE,
                                        pr_vlregistro       IN  cecred.TBCAPT_CUSTODIA_APLICACAO.Vlregistro%TYPE,                                        
                                        pr_idaplicacao      OUT cecred.TBCAPT_CUSTODIA_APLICACAO.idaplicacao%TYPE) IS
  BEGIN
    INSERT INTO cecred.TBCAPT_CUSTODIA_APLICACAO
      (idaplicacao,
       tpaplicacao,
       vlregistro,
       qtcotas,
       vlpreco_registro,
       vlpreco_unitario)
    VALUES
      (cecred.tbcapt_custodia_aplicacao_seq.nextval,
       pr_tpaplicacao,
       pr_vlregistro,
       pr_vlregistro * 0.01,
       0.01,
       0.01)
     RETURNING idaplicacao INTO pr_idaplicacao;
  END;
  
  PROCEDURE pc_gerar_custodia_lancamento(pr_idaplicacao      IN  cecred.Tbcapt_Custodia_Lanctos.idaplicacao%TYPE,
                                         pr_idtipo_arquivo   IN  cecred.Tbcapt_Custodia_Lanctos.idtipo_arquivo%TYPE,
                                         pr_idtipo_lancto    IN  cecred.Tbcapt_Custodia_Lanctos.idtipo_lancto%TYPE,
                                         pr_cdhistorico      IN  cecred.Tbcapt_Custodia_Lanctos.cdhistorico%TYPE,
                                         pr_cdoperacao_b3    IN  cecred.Tbcapt_Custodia_Lanctos.cdoperacao_b3%TYPE,                                         
                                         pr_dtregistro       IN  cecred.Tbcapt_Custodia_Lanctos.dtregistro%TYPE,
                                         pr_vlregistro       IN  cecred.Tbcapt_Custodia_Lanctos.Vlregistro%TYPE,                                         
                                         pr_idlancamento     OUT cecred.Tbcapt_Custodia_Lanctos.Idlancamento%TYPE) IS
  BEGIN
    INSERT INTO cecred.TBCAPT_CUSTODIA_LANCTOS
      (idlancamento,
       idaplicacao,
       idtipo_arquivo,
       idtipo_lancto,
       cdhistorico,
       cdoperacao_b3,
       vlregistro,
       qtcotas,
       vlpreco_unitario,
       idsituacao,
       dtregistro)
    VALUES
      (cecred.tbcapt_custodia_lanctos_seq.nextval,
       pr_idaplicacao,
       pr_idtipo_arquivo,
       pr_idtipo_lancto,
       pr_cdhistorico,
       pr_cdoperacao_b3,
       pr_vlregistro,
       pr_vlregistro * 0.01,
       0.01,
       0,
       pr_dtregistro)
    RETURNING idlancamento INTO pr_idlancamento;
  END;
  
BEGIN
  countSuccess := 0;
  countErrors  := 0;
  errors.delete;  

  FOR lcto_rda IN cr_lctos_rda LOOP        
    BEGIN
      vr_idaplicacao := NULL;
      vr_idlancamento := NULL;      
      
      pc_gerar_custodia_aplicacao(pr_tpaplicacao      => lcto_rda.tpaplrdc,
                                  pr_vlregistro       => lcto_rda.vllanmto,                                
                                  pr_idaplicacao      => vr_idaplicacao);
     
      pc_gerar_custodia_lancamento(pr_idaplicacao    => vr_idaplicacao,
                                   pr_idtipo_arquivo => lcto_rda.idtipo_arquivo,
                                   pr_idtipo_lancto  => lcto_rda.idtipo_lancto,
                                   pr_cdhistorico    => lcto_rda.cdhistor,
                                   pr_cdoperacao_b3  => lcto_rda.cdoperacao_b3,
                                   pr_vlregistro     => lcto_rda.vllanmto,
                                   pr_dtregistro     => lcto_rda.dtmvtolt,
                                   pr_idlancamento   => vr_idlancamento); 
              
       UPDATE cecred.craprda
          SET idaplcus = vr_idaplicacao
        WHERE ROWID = lcto_rda.rowid_apl;
        
       UPDATE cecred.craplap
          SET idlctcus = vr_idlancamento
        WHERE ROWID = lcto_rda.rowid_lct;
        
      COMMIT;
       
      countSuccess := countSuccess + 1;
    EXCEPTION WHEN OTHERS THEN
      countErrors := countErrors + 1;      
      errors(countErrors) := countErrors || ') RowId Apl/Lcto: '||lcto_rda.rowid_apl||'/'||lcto_rda.rowid_lct ||' - ' || SQLERRM;
    END;
  END LOOP;
  
  dbms_output.put_line('----------- RELATÓRIO CRAPRDA ---------');
  pc_exibir_relatorio_execucao;
  dbms_output.put_line('----------- ################## ---------');
 
  countSuccess := 0;
  countErrors  := 0;
  errors.delete;

  FOR lcto_rac IN cr_lctos_rac LOOP        
    BEGIN
      vr_idaplicacao := NULL;
      vr_idlancamento := NULL;      
      
      pc_gerar_custodia_aplicacao(pr_tpaplicacao      => lcto_rac.tpaplicacao,
                                  pr_vlregistro       => lcto_rac.vllanmto,                                
                                  pr_idaplicacao      => vr_idaplicacao);
     
      pc_gerar_custodia_lancamento(pr_idaplicacao    => vr_idaplicacao,
                                   pr_idtipo_arquivo => lcto_rac.idtipo_arquivo,
                                   pr_idtipo_lancto  => lcto_rac.idtipo_lancto,
                                   pr_cdhistorico    => lcto_rac.cdhistor,
                                   pr_cdoperacao_b3  => lcto_rac.cdoperacao_b3,
                                   pr_vlregistro     => lcto_rac.vllanmto,
                                   pr_dtregistro     => lcto_rac.dtmvtolt,
                                   pr_idlancamento   => vr_idlancamento); 
       
       UPDATE cecred.craprac
          SET idaplcus = vr_idaplicacao
        WHERE ROWID = lcto_rac.rowid_apl;
        
       UPDATE cecred.craplac
          SET idlctcus = vr_idlancamento
        WHERE ROWID = lcto_rac.rowid_lct;
        
      COMMIT;
       
      countSuccess := countSuccess + 1;
    EXCEPTION WHEN OTHERS THEN
      countErrors := countErrors + 1;      
      errors(countErrors) := countErrors || ') RowId Apl/Lcto: '||lcto_rac.rowid_apl||'/'||lcto_rac.rowid_lct ||' - ' || SQLERRM;
    END;
  END LOOP;

  dbms_output.put_line('----------- RELATÓRIO CRAPRAC ---------');
  pc_exibir_relatorio_execucao;
  dbms_output.put_line('----------- ################## ---------');
 
end;

