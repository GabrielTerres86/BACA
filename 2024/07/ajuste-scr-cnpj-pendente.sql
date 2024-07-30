DECLARE
  CURSOR cr_principal IS
    SELECT o.nrcpfcgc nrcpfcgc_origem
          ,a.nrcpfcgc nrcpfcgc_destino
      FROM cecred.crapopf o
          ,cecred.crapass a
     WHERE o.dtrefere >= to_date('30/03/2024', 'DD/MM/RRRR')
       AND a.nrcpfcnpj_base = SUBSTR(LPAD(o.nrcpfcgc, 14, '0'),1,8)
       AND a.inpessoa = o.inpessoa
       AND o.inpessoa = 2
       AND o.nrcpfcgc <> a.nrcpfcgc
       AND NOT EXISTS (SELECT 1 
                         FROM cecred.crapvop x 
                        WHERE x.nrcpfcgc = a.nrcpfcgc 
                          AND x.dtrefere = o.dtrefere);
  rw_principal cr_principal%ROWTYPE;
  
  CURSOR cr_crapvop(pr_nrcpfcgc IN cecred.crapvop.nrcpfcgc%TYPE
                   ,pr_dtrefere IN cecred.crapvop.dtrefere%TYPE) IS
    SELECT v.nrcpfcgc
          ,v.dtrefere
          ,v.cdvencto
          ,v.vlvencto
          ,v.cdmodali
          ,v.flgmoest
      FROM cecred.crapvop v
     WHERE v.nrcpfcgc = pr_nrcpfcgc
       AND v.dtrefere = pr_dtrefere;
  rw_crapvop cr_crapvop%ROWTYPE;
BEGIN
  
  FOR rw_principal IN cr_principal LOOP
    
    FOR rw_crapvop IN cr_crapvop(pr_nrcpfcgc => rw_principal.nrcpfcgc_origem
                                ,pr_dtrefere => rw_principal.dtrefere) LOOP
      BEGIN
        INSERT INTO cecred.crapvop(nrcpfcgc, dtrefere, cdvencto, vlvencto, cdmodali, flgmoest)
        VALUES (rw_crapvop.nrcpfcgc_destino, rw_crapvop.dtrefere, rw_crapvop.cdvencto, rw_crapvop.vlvencto, rw_crapvop.cdmodali, rw_crapvop.flgmoest);
      EXCEPTION
        WHEN OTHERS THEN
          dbms_output.put_line('Erro ao inserir crapvop - nrcpfcgc: ' || rw_principal.nrcpfcgc);
      END;
      
      COMMIT;
      
    END LOOP;
    
    COMMIT;
    
  END LOOP;
    
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/03/2024', 'DD/MM/RRRR'), 110, 102147.33, '0213', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/03/2024', 'DD/MM/RRRR'), 120, 222486.35, '0213', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/03/2024', 'DD/MM/RRRR'), 140, 211034.18, '0213', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/03/2024', 'DD/MM/RRRR'), 160, 448986.07, '0213', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/03/2024', 'DD/MM/RRRR'), 110, 13126.02, '0215', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/03/2024', 'DD/MM/RRRR'), 120, 2178720.92, '0215', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/03/2024', 'DD/MM/RRRR'), 130, 4140286.82, '0215', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/03/2024', 'DD/MM/RRRR'), 110, 1046174.19, '0216', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/03/2024', 'DD/MM/RRRR'), 120, 813573.33, '0216', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/03/2024', 'DD/MM/RRRR'), 130, 658463.86, '0216', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/03/2024', 'DD/MM/RRRR'), 140, 2206909.62, '0216', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/03/2024', 'DD/MM/RRRR'), 150, 4423072.79, '0216', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/03/2024', 'DD/MM/RRRR'), 160, 6534347.36, '0216', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/03/2024', 'DD/MM/RRRR'), 165, 5164359.93, '0216', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/03/2024', 'DD/MM/RRRR'), 170, 1388495.75, '0216', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/03/2024', 'DD/MM/RRRR'), 175, 44007.78, '0216', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/03/2024', 'DD/MM/RRRR'), 110, 185332.50, '0299', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/03/2024', 'DD/MM/RRRR'), 120, 185040.45, '0299', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/03/2024', 'DD/MM/RRRR'), 130, 183427.41, '0299', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/03/2024', 'DD/MM/RRRR'), 140, 300885.23, '0299', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/03/2024', 'DD/MM/RRRR'), 150, 428571.36, '0299', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/03/2024', 'DD/MM/RRRR'), 160, 857142.72, '0299', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/03/2024', 'DD/MM/RRRR'), 165, 761904.96, '0299', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/03/2024', 'DD/MM/RRRR'), 170, 166666.80, '0299', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/03/2024', 'DD/MM/RRRR'), 110, 13852.35, '0402', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/03/2024', 'DD/MM/RRRR'), 120, 13661.86, '0402', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/03/2024', 'DD/MM/RRRR'), 130, 12880.51, '0402', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/03/2024', 'DD/MM/RRRR'), 140, 37565.37, '0402', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/03/2024', 'DD/MM/RRRR'), 150, 58719.29, '0402', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/03/2024', 'DD/MM/RRRR'), 160, 98046.67, '0402', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/03/2024', 'DD/MM/RRRR'), 165, 66787.84, '0402', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/03/2024', 'DD/MM/RRRR'), 170, 13895.00, '0402', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/03/2024', 'DD/MM/RRRR'), 110, 278432.35, '0499', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/03/2024', 'DD/MM/RRRR'), 120, 199849.27, '0499', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/03/2024', 'DD/MM/RRRR'), 130, 127100.92, '0499', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/03/2024', 'DD/MM/RRRR'), 140, 537488.05, '0499', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/03/2024', 'DD/MM/RRRR'), 150, 922964.53, '0499', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/03/2024', 'DD/MM/RRRR'), 160, 1195961.83, '0499', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/03/2024', 'DD/MM/RRRR'), 165, 974094.19, '0499', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/03/2024', 'DD/MM/RRRR'), 170, 698785.03, '0499', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/03/2024', 'DD/MM/RRRR'), 175, 141142.94, '0499', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/03/2024', 'DD/MM/RRRR'), 180, 36522.89, '0499', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/03/2024', 'DD/MM/RRRR'), 20, 56357.77, '1902', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/03/2024', 'DD/MM/RRRR'), 20, 463676.99, '1904', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/04/2024', 'DD/MM/RRRR'), 110, 5616.90, '0213', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/04/2024', 'DD/MM/RRRR'), 130, 7411.20, '0213', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/04/2024', 'DD/MM/RRRR'), 160, 23455.53, '0213', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/04/2024', 'DD/MM/RRRR'), 110, 2231844.71, '0215', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/04/2024', 'DD/MM/RRRR'), 120, 4180248.14, '0215', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/04/2024', 'DD/MM/RRRR'), 110, 864649.49, '0216', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/04/2024', 'DD/MM/RRRR'), 120, 669449.67, '0216', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/04/2024', 'DD/MM/RRRR'), 130, 1013259.51, '0216', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/04/2024', 'DD/MM/RRRR'), 140, 2329627.41, '0216', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/04/2024', 'DD/MM/RRRR'), 150, 6121215.58, '0216', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/04/2024', 'DD/MM/RRRR'), 160, 10005533.55, '0216', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/04/2024', 'DD/MM/RRRR'), 165, 6596806.83, '0216', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/04/2024', 'DD/MM/RRRR'), 170, 1436093.14, '0216', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/04/2024', 'DD/MM/RRRR'), 175, 127124.02, '0216', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/04/2024', 'DD/MM/RRRR'), 180, 7925.85, '0216', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/04/2024', 'DD/MM/RRRR'), 110, 208423.34, '0299', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/04/2024', 'DD/MM/RRRR'), 120, 185109.18, '0299', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/04/2024', 'DD/MM/RRRR'), 130, 183495.17, '0299', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/04/2024', 'DD/MM/RRRR'), 140, 190476.16, '0299', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/04/2024', 'DD/MM/RRRR'), 150, 428571.36, '0299', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/04/2024', 'DD/MM/RRRR'), 160, 857142.72, '0299', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/04/2024', 'DD/MM/RRRR'), 165, 714285.92, '0299', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/04/2024', 'DD/MM/RRRR'), 170, 142857.28, '0299', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/04/2024', 'DD/MM/RRRR'), 110, 13849.33, '0402', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/04/2024', 'DD/MM/RRRR'), 120, 13059.67, '0402', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/04/2024', 'DD/MM/RRRR'), 130, 12877.55, '0402', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/04/2024', 'DD/MM/RRRR'), 140, 37552.44, '0402', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/04/2024', 'DD/MM/RRRR'), 150, 57339.98, '0402', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/04/2024', 'DD/MM/RRRR'), 160, 96345.22, '0402', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/04/2024', 'DD/MM/RRRR'), 165, 64459.05, '0402', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/04/2024', 'DD/MM/RRRR'), 170, 10499.63, '0402', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/04/2024', 'DD/MM/RRRR'), 110, 202295.98, '0499', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/04/2024', 'DD/MM/RRRR'), 120, 317942.12, '0499', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/04/2024', 'DD/MM/RRRR'), 130, 313222.07, '0499', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/04/2024', 'DD/MM/RRRR'), 140, 911926.76, '0499', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/04/2024', 'DD/MM/RRRR'), 150, 1422812.04, '0499', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/04/2024', 'DD/MM/RRRR'), 160, 2202239.41, '0499', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/04/2024', 'DD/MM/RRRR'), 165, 1912577.35, '0499', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/04/2024', 'DD/MM/RRRR'), 170, 1456303.05, '0499', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/04/2024', 'DD/MM/RRRR'), 175, 242741.96, '0499', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/04/2024', 'DD/MM/RRRR'), 180, 31602.70, '0499', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/04/2024', 'DD/MM/RRRR'), 140, 276805.39, '1502', 1);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/04/2024', 'DD/MM/RRRR'), 20, 966000.00, '1902', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('30/04/2024', 'DD/MM/RRRR'), 20, 471416.47, '1904', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/05/2024', 'DD/MM/RRRR'), 110, 0.30, '0101', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/05/2024', 'DD/MM/RRRR'), 120, 217939.26, '0213', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/05/2024', 'DD/MM/RRRR'), 165, 322276.15, '0213', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/05/2024', 'DD/MM/RRRR'), 110, 6485912.58, '0215', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/05/2024', 'DD/MM/RRRR'), 110, 765830.21, '0216', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/05/2024', 'DD/MM/RRRR'), 120, 1070352.59, '0216', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/05/2024', 'DD/MM/RRRR'), 130, 845410.13, '0216', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/05/2024', 'DD/MM/RRRR'), 140, 2534423.06, '0216', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/05/2024', 'DD/MM/RRRR'), 150, 6102331.42, '0216', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/05/2024', 'DD/MM/RRRR'), 160, 10009569.98, '0216', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/05/2024', 'DD/MM/RRRR'), 165, 6017112.36, '0216', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/05/2024', 'DD/MM/RRRR'), 170, 1235750.83, '0216', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/05/2024', 'DD/MM/RRRR'), 175, 94954.55, '0216', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/05/2024', 'DD/MM/RRRR'), 110, 208250.04, '0299', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/05/2024', 'DD/MM/RRRR'), 120, 185218.36, '0299', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/05/2024', 'DD/MM/RRRR'), 130, 71428.56, '0299', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/05/2024', 'DD/MM/RRRR'), 140, 190476.16, '0299', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/05/2024', 'DD/MM/RRRR'), 150, 428571.36, '0299', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/05/2024', 'DD/MM/RRRR'), 160, 857142.72, '0299', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/05/2024', 'DD/MM/RRRR'), 165, 666666.88, '0299', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/05/2024', 'DD/MM/RRRR'), 170, 119047.76, '0299', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/05/2024', 'DD/MM/RRRR'), 110, 13250.62, '0402', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/05/2024', 'DD/MM/RRRR'), 120, 13065.78, '0402', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/05/2024', 'DD/MM/RRRR'), 130, 12880.48, '0402', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/05/2024', 'DD/MM/RRRR'), 140, 36190.16, '0402', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/05/2024', 'DD/MM/RRRR'), 150, 57365.13, '0402', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/05/2024', 'DD/MM/RRRR'), 160, 94692.20, '0402', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/05/2024', 'DD/MM/RRRR'), 165, 62137.33, '0402', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/05/2024', 'DD/MM/RRRR'), 170, 7056.82, '0402', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/05/2024', 'DD/MM/RRRR'), 110, 436571.47, '0499', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/05/2024', 'DD/MM/RRRR'), 120, 316875.97, '0499', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/05/2024', 'DD/MM/RRRR'), 130, 312280.53, '0499', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/05/2024', 'DD/MM/RRRR'), 140, 909507.73, '0499', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/05/2024', 'DD/MM/RRRR'), 150, 1354224.35, '0499', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/05/2024', 'DD/MM/RRRR'), 160, 2200338.09, '0499', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/05/2024', 'DD/MM/RRRR'), 165, 1915241.55, '0499', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/05/2024', 'DD/MM/RRRR'), 170, 1417878.72, '0499', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/05/2024', 'DD/MM/RRRR'), 175, 168540.26, '0499', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/05/2024', 'DD/MM/RRRR'), 180, 26331.31, '0499', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/05/2024', 'DD/MM/RRRR'), 140, 280541.66, '1502', 1);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/05/2024', 'DD/MM/RRRR'), 20, 351659.15, '1902', 0);
  
  insert into cecred.crapvop (NRCPFCGC, DTREFERE, CDVENCTO, VLVENCTO, CDMODALI, FLGMOEST)
  values (76541317000288, to_date('31/05/2024', 'DD/MM/RRRR'), 20, 479155.85, '1904', 0);
  
  commit;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20000, SQLERRM || ' - ' || dbms_utility.format_error_backtrace);
END;
