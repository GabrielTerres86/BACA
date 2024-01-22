DECLARE
  vr_dtrefere DATE := to_date('31/12/2023', 'DD/MM/RRRR');
  
  CURSOR cr_crapris IS
    SELECT r.dtrefere, r.cdcooper, r.nrdconta, r.nrctremp,
           r.cdmodali, r.inddocto, r.cdorigem, r.vldivida,
           r.inpessoa, r.dtdrisco, r.nrcpfcgc, r.innivris,
           r.nrdgrupo, r.nracordo, r.innivori, r.dtinictr,
           r.qtdiaatr, r.dtprxpar, r.vlprxpar, r.qtparcel
      FROM cecred.crapris r
     WHERE r.dtrefere = vr_dtrefere
       AND r.cdmodali = 1513 
       AND r.inddocto = 4 
       AND r.cdorigem = 6
       AND (
           (r.cdcooper = 1 AND r.nrdconta IN (17977100, 17978920, 17982251, 17983371, 17983576) AND r.nrctremp IN (3239103380, 3239104092, 3239103733, 3239105946, 3239103693)) OR
           (r.cdcooper = 2 AND r.nrdconta IN (1243438, 1243454, 17984866) AND r.nrctremp IN (3265097376, 3265097407, 3265097411)) OR
           (r.cdcooper = 8 AND r.nrdconta IN (17972191) AND r.nrctremp IN (4435005443)) OR
           (r.cdcooper = 11 AND r.nrdconta IN (1031155) AND r.nrctremp IN (4438121536)) OR
           (r.cdcooper = 14 AND r.nrdconta IN (484300) AND r.nrctremp IN (4468063248)) OR
           (r.cdcooper = 16 AND r.nrdconta IN (17977363) AND r.nrctremp IN (4420130239))
           );
  rw_crapris cr_crapris%ROWTYPE;
  
  CURSOR cr_crapvri IS
    SELECT v.cdcooper, v.nrdconta, v.nrctremp, v.dtrefere,
           v.nrseqctr, v.cdvencto, v.vldivida, v.cdmodali
      FROM cecred.crapvri v
     WHERE dtrefere = vr_dtrefere
       AND (
           (v.cdcooper = 1 AND v.nrdconta IN (17977100, 17978920, 17982251, 17983371, 17983576) AND v.nrctremp IN (3239103380, 3239104092, 3239103733, 3239105946, 3239103693)) OR
           (v.cdcooper = 2 AND v.nrdconta IN (1243438, 1243454, 17984866) AND v.nrctremp IN (3265097376, 3265097407, 3265097411)) OR
           (v.cdcooper = 8 AND v.nrdconta IN (17972191) AND v.nrctremp IN (4435005443)) OR
           (v.cdcooper = 11 AND v.nrdconta IN (1031155) AND v.nrctremp IN (4438121536)) OR
           (v.cdcooper = 14 AND v.nrdconta IN (484300) AND v.nrctremp IN (4468063248)) OR
           (v.cdcooper = 16 AND v.nrdconta IN (17977363) AND v.nrctremp IN (4420130239))
           );
  rw_crapvri cr_crapvri%ROWTYPE;
BEGIN
  
  FOR rw_crapris IN cr_crapris LOOP
    BEGIN
      INSERT INTO gestaoderisco.tbrisco_crapris(dtrefere, cdcooper, nrdconta, nrctremp,
                                                cdmodali, inddocto, cdorigem, vldivida,
                                                inpessoa, dtdrisco, nrcpfcgc, innivris,
                                                nrdgrupo, nracordo, innivori, dtinictr,
                                                qtdiaatr, dtprxpar, vlprxpar, qtparcel,
                                                nrseqctr, cdmodalidade_bacen)
      VALUES (rw_crapris.dtrefere, rw_crapris.cdcooper, rw_crapris.nrdconta, rw_crapris.nrctremp,
              rw_crapris.cdmodali, rw_crapris.inddocto, rw_crapris.cdorigem, rw_crapris.vldivida,
              rw_crapris.inpessoa, rw_crapris.dtdrisco, rw_crapris.nrcpfcgc, rw_crapris.innivris,
              rw_crapris.nrdgrupo, rw_crapris.nracordo, rw_crapris.innivori, rw_crapris.dtinictr,
              rw_crapris.qtdiaatr, rw_crapris.dtprxpar, rw_crapris.vlprxpar, rw_crapris.qtparcel,
              97, 1513);
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20000, 'Erro ao inserir crapris - ' || SQLERRM);
    END;
  END LOOP;
  
  COMMIT;
  
  FOR rw_crapvri IN cr_crapvri LOOP
    BEGIN
      INSERT INTO gestaoderisco.tbrisco_crapvri(cdcooper, nrdconta, nrctremp, dtrefere,
                                                nrseqctr, cdvencto, vldivida, cdmodali)
      VALUES (rw_crapvri.cdcooper, rw_crapvri.nrdconta, rw_crapvri.nrctremp, rw_crapvri.dtrefere,
              97,                  rw_crapvri.cdvencto, rw_crapvri.vldivida, rw_crapvri.cdmodali);
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20000, 'Erro ao inserir crapvri - ' || SQLERRM);
    END;
  END LOOP;
  
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20000, SQLERRM);
END;
