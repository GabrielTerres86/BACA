PL/SQL Developer Test script 3.0
226
Declare

  cursor cr_lem is
    SELECT h.cdcooper,       
           h.cdhistor,       
           h.nmestrut, -- CRAPLEM       
           h.dshistor,
           h.nrctacrd,
           h.nrctadeb,
           h.ingercre,
           h.ingerdeb,
           h.tpctbccu,
           h.tpctbcxa,
           h.rowid
      FROM craphis h,
           crapcop c
     WHERE h.cdhistor IN (1047,1076,1077,1078,1540,1618,
                          1619,1620,1708,1711,1717,1720,
                          2701,2702 --> prejuizo
                          )
       AND h.cdcooper = c.cdcooper
       AND c.flgativo = 1                   
     ORDER BY h.cdhistor
             ,h.cdcooper;

 rw_lem  cr_lem%rowtype;
 
 --> buscar dados do historico
 CURSOR cr_craphis (pr_cdcooper craphis.cdcooper%TYPE,
                    pr_cdhistor craphis.cdhistor%TYPE) IS
   SELECT his.*,
          his.rowid
     FROM craphis his
    WHERE his.cdcooper = pr_cdcooper
      AND his.cdhistor = pr_cdhistor;
 rw_craphis cr_craphis%ROWTYPE;      

 vr_cdhistor_lcm craphis.cdhistor%TYPE; 
 vr_dscritic     VARCHAR2(5000);
 vr_hora         VARCHAR2(100);
 vr_teste        NUMBER;
 vr_dsdireto     VARCHAR2(1000);

BEGIN

  vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'M', pr_cdcooper => 3, pr_nmsubdir => 'odirlei/arq' );
  --vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C', pr_cdcooper => 3, pr_nmsubdir => 'rl' );
  vr_hora := to_char(SYSDATE,'hh24mi');

  vr_teste := exporta_tabela_para_csv (p_query => 'SELECT h.cdcooper, h.cdhistor,h.nmestrut,h.dshistor,h.cdhstctb,h.nrctacrd,h.nrctadeb,
                                                          h.ingercre,h.ingerdeb,h.cdhisest,h.tpctbccu,h.tpctbcxa,h.rowid FROM craphis h
                                                   WHERE h.nmestrut = ''CRAPLEM'' order by cdhistor,cdcooper',
                                       p_dir => vr_dsdireto,
                                       p_arquivo => 'craphis_LEM_antes_'||vr_hora);


  vr_teste := exporta_tabela_para_csv (p_query => 'SELECT h.cdcooper, h.cdhistor,h.nmestrut,h.dshistor,h.cdhstctb,h.nrctacrd,h.nrctadeb,
                                                          h.ingercre,h.ingerdeb,h.cdhisest,h.tpctbccu,h.tpctbcxa,h.rowid FROM craphis h
                                                   WHERE h.nmestrut = ''CRAPLCM'' order by cdhistor,cdcooper',
                                       p_dir => vr_dsdireto,
                                       p_arquivo => 'craphis_LCM_antes_'||vr_hora);

  
  BEGIN
    UPDATE craphis his
       SET his.nmestrut = 'CRAPLEM'
     WHERE his.cdhistor IN (2701,2702);  
  EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic := 'Erro ao atualizar registro 2701: '||SQLERRM;
      raise_application_error(-20500,vr_dscritic);     
  END; 
  
  FOR rw_lem IN cr_lem LOOP
  
    CASE rw_lem.cdhistor
      WHEN 1047 THEN vr_cdhistor_lcm := 1060;
      WHEN 1076 THEN vr_cdhistor_lcm := 1070 ;
      WHEN 1077 THEN vr_cdhistor_lcm := 1071; 
      WHEN 1078 THEN vr_cdhistor_lcm := 1072;
      WHEN 1540 THEN vr_cdhistor_lcm := 1541;
      WHEN 1618 THEN vr_cdhistor_lcm := 1542;
      WHEN 1619 THEN vr_cdhistor_lcm := 1543; 
      WHEN 1620 THEN vr_cdhistor_lcm := 1544;
      WHEN 1708 THEN vr_cdhistor_lcm := 1709;
      WHEN 1711 THEN vr_cdhistor_lcm := 1712;
      WHEN 1717 THEN vr_cdhistor_lcm := 1718;
      WHEN 1720 THEN vr_cdhistor_lcm := 1721;
      WHEN 2701 THEN vr_cdhistor_lcm := 2386;
      WHEN 2702 THEN vr_cdhistor_lcm := 2387;
      
      ELSE raise_application_error(-20500,'Historico invalido');
    END CASE;  
    
    
    OPEN cr_craphis(pr_cdcooper => rw_lem.cdcooper,
                    pr_cdhistor => vr_cdhistor_lcm );
    FETCH cr_craphis INTO rw_craphis;
    IF cr_craphis%NOTFOUND THEN
      CLOSE cr_craphis;
      raise_application_error(-20500,'Historico '||rw_lem.cdcooper||'-'||vr_cdhistor_lcm||' nao encontrado');
    ELSE
      CLOSE cr_craphis;
    END IF;
    
    --> Copiar dados da estrutura da CRAPLCM para a CRAPLEM     
    BEGIN
      UPDATE craphis his
         SET his.nrctadeb = rw_craphis.nrctadeb,
             his.nrctacrd = rw_craphis.nrctacrd,
             his.cdhstctb = rw_craphis.cdhstctb,
             his.ingerdeb = rw_craphis.ingerdeb,
             his.ingercre = rw_craphis.ingercre,
             his.tpctbccu = rw_craphis.tpctbccu,
             his.tpctbcxa = rw_craphis.tpctbcxa
       WHERE his.rowid = rw_lem.rowid;  
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar registro '||rw_lem.rowid||': '||SQLERRM;
        raise_application_error(-20500,vr_dscritic);     
    END; 
    
    --> Zerar informações na estrutura da CRAPLCM
    BEGIN
      UPDATE craphis his
         SET his.nrctadeb = 0,
             his.nrctacrd = 0,
             his.cdhstctb = 0,
             his.ingerdeb = 1,
             his.ingercre = 1
       WHERE his.rowid = rw_craphis.rowid;  
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar registro '||rw_lem.rowid||': '||SQLERRM;
        raise_application_error(-20500,vr_dscritic);     
    END; 
     
  
  END LOOP;
  
  
  --> Zerar informações na estrutura da CRAPLCM
  BEGIN
    UPDATE craphis his
       SET his.nrctadeb = 0,
           his.nrctacrd = 0,
           his.cdhstctb = 0,
           his.ingerdeb = 1,
           his.ingercre = 1
     WHERE his.cdhistor IN (1710,1719,1713,1722);  
  EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic := 'Erro ao atualizar registro 1710: '||SQLERRM;
      raise_application_error(-20500,vr_dscritic);     
  END; 
  
  --> Marcar para contabilizar a partir dos historicos da LEM
  BEGIN
    UPDATE craphis his
       SET his.cdhstctb = 5210           
     WHERE his.cdhistor IN (2784,2785,2786,2787);  
  EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic := 'Erro ao atualizar registro 2784: '||SQLERRM;
      raise_application_error(-20500,vr_dscritic);     
  END;
  
  --> Atualizar his 1076 - MULTA
  BEGIN
    UPDATE craphis his
       SET his.cdhisest = 2784
     WHERE his.cdhistor = 1076 ;
  EXCEPTION  
    WHEN OTHERS THEN
      raise_application_error(-20500,'Erro ao atualizar historico de estorno no his. 1076: '||SQLERRM);
  END;

  --> Atualizar his 1618 - MULTA AVAL
  BEGIN
    UPDATE craphis his
       SET his.cdhisest = 2785
     WHERE his.cdhistor = 1618; 
  EXCEPTION  
    WHEN OTHERS THEN
      raise_application_error(-20500,'Erro ao atualizar historico de estorno no his. 1618: '||SQLERRM);
  END;

  --> Atualizar his 1078 - JUROS DE MORA
  BEGIN
    UPDATE craphis his
       SET his.cdhisest = 2786
     WHERE his.cdhistor = 1078; 
  EXCEPTION  
    WHEN OTHERS THEN
      raise_application_error(-20500,'Erro ao atualizar historico de estorno no his. 1078: '||SQLERRM);
  END;

  --> Atualizar his 1620 - MORA AVAL
  BEGIN
    UPDATE craphis his
       SET his.cdhisest = 2787
     WHERE his.cdhistor = 1620; 
  EXCEPTION  
    WHEN OTHERS THEN
      raise_application_error(-20500,'Erro ao atualizar historico de estorno no his. 1620: '||SQLERRM);
  END;
  
  
  vr_teste := exporta_tabela_para_csv (p_query => 'SELECT h.cdcooper, h.cdhistor,h.nmestrut,h.dshistor,h.cdhstctb,h.nrctacrd,h.nrctadeb,
                                                          h.ingercre,h.ingerdeb,h.cdhisest,h.tpctbccu,h.tpctbcxa,h.rowid FROM craphis h
                                                   WHERE h.nmestrut = ''CRAPLEM'' order by cdhistor,cdcooper',
                                       p_dir => vr_dsdireto,
                                       p_arquivo => 'craphis_LEM_depois_'||vr_hora);


  vr_teste := exporta_tabela_para_csv (p_query => 'SELECT h.cdcooper, h.cdhistor,h.nmestrut,h.dshistor,h.cdhstctb,h.nrctacrd,h.nrctadeb,
                                                          h.ingercre,h.ingerdeb,h.cdhisest,h.tpctbccu,h.tpctbcxa,h.rowid FROM craphis h
                                                   WHERE h.nmestrut = ''CRAPLCM'' order by cdhistor,cdcooper',
                                       p_dir => vr_dsdireto,
                                       p_arquivo => 'craphis_LCM_depois_'||vr_hora);

  
  
  
  COMMIT;
End;
0
0
