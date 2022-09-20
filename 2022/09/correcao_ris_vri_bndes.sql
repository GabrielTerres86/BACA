DECLARE

  vr_dtrefere cecred.crapdat.dtmvtolt%TYPE := to_date('31/08/2022', 'DD/MM/RRRR');

  vr_exc_erro   EXCEPTION;
  vr_cdcritic   NUMBER;
  vr_dscritic   VARCHAR2(4000);
  vr_cdprograma VARCHAR2(25) := 'atualiza_crapris_BNDES';
  
  vr_inrisco_atraso   cecred.tbrisco_central_ocr.inrisco_atraso%TYPE;
  vr_diasvenc     NUMBER;
  vr_cdvencto     NUMBER;
  
  TYPE typ_tab_vlparcel IS TABLE OF NUMBER
       INDEX BY PLS_INTEGER;
  vr_tab_vlavence typ_tab_vlparcel;
  
  TYPE typ_tab_ddparcel IS TABLE OF PLS_INTEGER
       INDEX BY PLS_INTEGER;
  vr_tab_ddavence typ_tab_ddparcel;
  
  CURSOR cr_crapcop(pr_cdcooper IN cecred.crapcop.cdcooper%TYPE) IS
    SELECT c.cdcooper
      FROM cecred.crapcop c
     WHERE c.flgativo = 1
       AND (c.cdcooper = pr_cdcooper OR pr_cdcooper = 0);
  rw_crapcop cr_crapcop%ROWTYPE;
  
  CURSOR cr_contratos_bndes(pr_cdcooper IN cecred.crapris.cdcooper%TYPE
                           ,pr_dtrefere IN cecred.crapris.dtrefere%TYPE) IS
    SELECT r.nrdconta
         , r.nrctremp
         , r.nrseqctr
         , r.inindris
         , e.vlsdeved
         , e.vlaat180
         , e.vlave360
         , e.vlasu360
         , e.vlveat60
         , e.vlvenc61
         , e.vlven181
         , e.vlvsu360
         , e.vlprej12
         , e.vlprej48
         , e.vlprac48
         , e.vlaven30
         , e.vlaven60
         , e.vlaven90
         , e.vlave180
         , e.vlave720
         , e.vlav1080
         , e.vlav1440
         , e.vlav1800
         , e.vlav5400
         , e.vlaa5400
         , e.vlvenc14
         , e.vlvenc30
         , e.vlvenc60
         , e.vlvenc90
         , e.vlven120
         , e.vlven150
         , e.vlven180
         , e.vlven240
         , e.vlven300
         , e.vlven360
         , e.vlven540
         , e.vlvac540
      FROM cecred.crapris r, cecred.crapebn e
     WHERE e.cdcooper = r.cdcooper
       AND e.nrdconta = r.nrdconta
       AND e.nrctremp = r.nrctremp
       AND r.cdcooper = pr_cdcooper
       AND r.dtrefere = pr_dtrefere
       AND r.dsinfaux = 'BNDES';
  rw_contratos_bndes cr_contratos_bndes%ROWTYPE;
  
BEGIN
  vr_tab_ddavence(1) := 30;
  vr_tab_ddavence(2) := 60;
  vr_tab_ddavence(3) := 90;
  vr_tab_ddavence(4) := 180;
  vr_tab_ddavence(5) := 360;
  vr_tab_ddavence(6) := 720;
  vr_tab_ddavence(7) := 1080;
  vr_tab_ddavence(8) := 1440;
  vr_tab_ddavence(9) := 1800;
  vr_tab_ddavence(10) := 5400;
  vr_tab_ddavence(11) := 9999;
  vr_tab_ddavence(11) := 5401;
  vr_tab_ddavence(12) := -14;
  vr_tab_ddavence(13) := -30;
  vr_tab_ddavence(14) := -60;
  vr_tab_ddavence(15) := -90;
  vr_tab_ddavence(16) := -120;
  vr_tab_ddavence(17) := -150;
  vr_tab_ddavence(18) := -180;
  vr_tab_ddavence(19) := -240;
  vr_tab_ddavence(20) := -300;
  vr_tab_ddavence(21) := -360;
  vr_tab_ddavence(22) := -540;
  vr_tab_ddavence(23) := -541;

  FOR rw_crapcop IN cr_crapcop(pr_cdcooper => 1) LOOP
    
    FOR rw_contratos_bndes IN cr_contratos_bndes(pr_cdcooper => rw_crapcop.cdcooper
                                                ,pr_dtrefere => vr_dtrefere) LOOP
      
      BEGIN
        UPDATE cecred.crapris
           SET vldivida = rw_contratos_bndes.vlsdeved
              ,vlvec180 = rw_contratos_bndes.vlaat180
              ,vlvec360 = rw_contratos_bndes.vlaat180 + rw_contratos_bndes.vlave360
              ,vlvec999 = rw_contratos_bndes.vlasu360
              ,vldiv060 = rw_contratos_bndes.vlveat60
              ,vldiv180 = rw_contratos_bndes.vlveat60 + rw_contratos_bndes.vlvenc61
              ,vldiv360 = rw_contratos_bndes.vlveat60 + rw_contratos_bndes.vlvenc61 + rw_contratos_bndes.vlven181
              ,vldiv999 = rw_contratos_bndes.vlvsu360
              ,vlprjano = rw_contratos_bndes.vlprej12
              ,vlprjaan = rw_contratos_bndes.vlprej48
              ,vlprjant = rw_contratos_bndes.vlprac48
         WHERE cdcooper = rw_crapcop.cdcooper
           AND nrdconta = rw_contratos_bndes.nrdconta
           AND nrctremp = rw_contratos_bndes.nrctremp
           AND dtrefere = vr_dtrefere;
      EXCEPTION
        WHEN OTHERS THEN
          dbms_output.put_line('Erro ao atualizar ris - Cooper: ' || rw_crapcop.cdcooper || ' Conta: ' || rw_contratos_bndes.nrdconta || ' Contrato: ' || rw_contratos_bndes.nrctremp || ' - ' || SQLERRM);
      END;
      
      vr_tab_vlavence(1) := rw_contratos_bndes.vlaven30;  
      vr_tab_vlavence(2) := rw_contratos_bndes.vlaven60;  
      vr_tab_vlavence(3) := rw_contratos_bndes.vlaven90;  
      vr_tab_vlavence(4) := rw_contratos_bndes.vlave180;  
      vr_tab_vlavence(5) := rw_contratos_bndes.vlave360;  
      vr_tab_vlavence(6) := rw_contratos_bndes.vlave720;   
      vr_tab_vlavence(7) := rw_contratos_bndes.vlav1080;  
      vr_tab_vlavence(8) := rw_contratos_bndes.vlav1440;  
      vr_tab_vlavence(9) := rw_contratos_bndes.vlav1800;  
      vr_tab_vlavence(10) := rw_contratos_bndes.vlav5400; 
      vr_tab_vlavence(11) := rw_contratos_bndes.vlaa5400; 
      vr_tab_vlavence(12) := rw_contratos_bndes.vlvenc14; 
      vr_tab_vlavence(13) := rw_contratos_bndes.vlvenc30; 
      vr_tab_vlavence(14) := rw_contratos_bndes.vlvenc60; 
      vr_tab_vlavence(15) := rw_contratos_bndes.vlvenc90; 
      vr_tab_vlavence(16) := rw_contratos_bndes.vlven120; 
      vr_tab_vlavence(17) := rw_contratos_bndes.vlven150;  
      vr_tab_vlavence(18) := rw_contratos_bndes.vlven180; 
      vr_tab_vlavence(19) := rw_contratos_bndes.vlven240; 
      vr_tab_vlavence(20) := rw_contratos_bndes.vlven300; 
      vr_tab_vlavence(21) := rw_contratos_bndes.vlven360; 
      vr_tab_vlavence(22) := rw_contratos_bndes.vlven540; 
      vr_tab_vlavence(23) := rw_contratos_bndes.vlvac540; 
      
      FOR vr_ind IN vr_tab_vlavence.FIRST..vr_tab_vlavence.LAST LOOP
        IF NOT vr_tab_vlavence.EXISTS(vr_ind) OR vr_tab_vlavence(vr_ind) = 0  THEN
          CONTINUE;
        END IF;
        vr_diasvenc := vr_tab_ddavence(vr_ind);
        vr_cdvencto := GESTAODERISCO.calcularCodigoVencimento(pr_diasvenc => vr_diasvenc);
        
        BEGIN
          INSERT INTO cecred.crapvri(cdcooper, nrdconta, dtrefere, innivris, 
                                     cdmodali, nrctremp, nrseqctr, cdvencto, vldivida)
          VALUES (rw_crapcop.cdcooper, rw_contratos_bndes.nrdconta, vr_dtrefere, rw_contratos_bndes.inindris,
                  0499, rw_contratos_bndes.nrctremp, rw_contratos_bndes.nrseqctr, vr_cdvencto, vr_tab_vlavence(vr_ind));
        EXCEPTION
          WHEN OTHERS THEN
            dbms_output.put_line('1 - Erro ao inserir vri - Cooper: ' || rw_crapcop.cdcooper || ' Conta: ' || rw_contratos_bndes.nrdconta || ' Contrato: ' || rw_contratos_bndes.nrctremp || ' Vencimento: ' || vr_cdvencto || ' - ' || SQLERRM);
        END;
      END LOOP;
      
      IF rw_contratos_bndes.vlprej12 <> 0 THEN
        BEGIN
          INSERT INTO cecred.crapvri(cdcooper, nrdconta, dtrefere, innivris, 
                                     cdmodali, nrctremp, nrseqctr, cdvencto, vldivida)
          VALUES (rw_crapcop.cdcooper, rw_contratos_bndes.nrdconta, vr_dtrefere, rw_contratos_bndes.inindris,
                  0499, rw_contratos_bndes.nrctremp, rw_contratos_bndes.nrseqctr, 310, rw_contratos_bndes.vlprej12);
        EXCEPTION
          WHEN OTHERS THEN
            dbms_output.put_line('2 - Erro ao inserir vri - Cooper: ' || rw_crapcop.cdcooper || ' Conta: ' || rw_contratos_bndes.nrdconta || ' Contrato: ' || rw_contratos_bndes.nrctremp || ' Vencimento: ' || vr_cdvencto || ' - ' || SQLERRM);
        END;
      END IF;
      
      IF rw_contratos_bndes.vlprej48 <> 0 THEN
        BEGIN
          INSERT INTO cecred.crapvri(cdcooper, nrdconta, dtrefere, innivris, 
                                     cdmodali, nrctremp, nrseqctr, cdvencto, vldivida)
          VALUES (rw_crapcop.cdcooper, rw_contratos_bndes.nrdconta, vr_dtrefere, rw_contratos_bndes.inindris,
                  0499, rw_contratos_bndes.nrctremp, rw_contratos_bndes.nrseqctr, 320, rw_contratos_bndes.vlprej48);
        EXCEPTION
          WHEN OTHERS THEN
            dbms_output.put_line('3 - Erro ao inserir vri - Cooper: ' || rw_crapcop.cdcooper || ' Conta: ' || rw_contratos_bndes.nrdconta || ' Contrato: ' || rw_contratos_bndes.nrctremp || ' Vencimento: ' || vr_cdvencto || ' - ' || SQLERRM);
        END;
      END IF;
      
      IF rw_contratos_bndes.vlprac48 <> 0 THEN
        BEGIN
          INSERT INTO cecred.crapvri(cdcooper, nrdconta, dtrefere, innivris, 
                                     cdmodali, nrctremp, nrseqctr, cdvencto, vldivida)
          VALUES (rw_crapcop.cdcooper, rw_contratos_bndes.nrdconta, vr_dtrefere, rw_contratos_bndes.inindris,
                  0499, rw_contratos_bndes.nrctremp, rw_contratos_bndes.nrseqctr, 330, rw_contratos_bndes.vlprac48);
        EXCEPTION
          WHEN OTHERS THEN
            dbms_output.put_line('4 - Erro ao inserir vri - Cooper: ' || rw_crapcop.cdcooper || ' Conta: ' || rw_contratos_bndes.nrdconta || ' Contrato: ' || rw_contratos_bndes.nrctremp || ' Vencimento: ' || vr_cdvencto || ' - ' || SQLERRM);
        END;
      END IF;
      
    END LOOP;
    
  END LOOP;
  
  COMMIT;
  
EXCEPTION 
  WHEN vr_exc_erro THEN
  
    IF nvl(vr_cdcritic,0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
      vr_dscritic := obterCritica(vr_cdcritic);
    END IF;
    
    ROLLBACK;
    
    sistema.Gravarlogprograma(pr_cdcooper      => 3,
                              pr_ind_tipo_log  => 3,
                              pr_des_log       => vr_cdprograma||' -> PROGRAMA COM ERRO ' || vr_dscritic,
                              pr_cdprograma    => vr_cdprograma,
                              pr_tpexecucao    => 1);      
  
  
  WHEN OTHERS THEN
    sistema.excecaoInterna(pr_cdcooper => 3, 
                           pr_compleme => SQLERRM);
                           
    ROLLBACK;
                               
    sistema.Gravarlogprograma(pr_cdcooper      => 3,
                              pr_ind_tipo_log  => 3,
                              pr_des_log       => vr_cdprograma||' -> PROGRAMA COM ERRO ' || SQLERRM,
                              pr_cdprograma    => vr_cdprograma,
                              pr_tpexecucao    => 1);    
        
END;