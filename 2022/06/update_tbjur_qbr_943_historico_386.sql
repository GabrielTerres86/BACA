DECLARE
  CURSOR cr_craplcm IS
    SELECT * 
      FROM craplcm 
     WHERE cdhistor IN (386) 
       AND progress_recid IN (SELECT nrseqlcm 
                                FROM tbjur_qbr_sig_extrato 
                               WHERE nrseq_quebra_sigilo= 943 
                                 AND nrcpfcgc IS NULL);
  rw_craplcm cr_craplcm%ROWTYPE;  
  
  -- Buscar os dados do cheque na DATA
  CURSOR cr_all_cheques_data (pr_cdcooper IN INTEGER
                             ,pr_nrdconta IN INTEGER
                             ,pr_nrdocmto IN INTEGER
                             ,pr_dtmvtolt IN DATE) IS
    SELECT chd.nrctachq,
           chd.cdagechq,
           chd.cdbanchq,
           chd.vlcheque,
           chd.nrdocmto,
           chd.dsdocmc7
      FROM crapchd chd
     WHERE chd.cdcooper = pr_cdcooper
       AND chd.nrdconta = pr_nrdconta
       AND chd.nrdocmto = pr_nrdocmto
       AND chd.dtmvtolt = pr_dtmvtolt;
  rw_all_cheques_data cr_all_cheques_data%ROWTYPE;
  
    CURSOR cr_cooperativa(pr_cdagectl IN crapcop.cdagectl%TYPE) IS
      SELECT crapcop.cdcooper
        FROM crapcop
       WHERE crapcop.cdagectl = pr_cdagectl;
    rw_cooperativa cr_cooperativa%ROWTYPE;
    
    CURSOR cr_cooperado(pr_cdcooper IN INTEGER
               ,pr_nrdconta IN INTEGER) IS
      SELECT crapass.nmprimtl
           , crapass.nrcpfcgc 
           , crapass.nrdctitg
           , crapass.inpessoa
        FROM crapass 
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_cooperado cr_cooperado%ROWTYPE;
    
    vr_nrcpfcgc NUMBER(25);
    vr_nmprimtl VARCHAR2(50); 
    
    vr_exc_saida  EXCEPTION;   
    
BEGIN
  FOR rw_craplcm IN cr_craplcm LOOP
                                                  
    OPEN cr_all_cheques_data(pr_cdcooper => rw_craplcm.cdcooper
                             ,pr_nrdconta => rw_craplcm.nrdconta
                             ,pr_nrdocmto => rw_craplcm.nrdocmto+10
                             ,pr_dtmvtolt => rw_craplcm.dtmvtolt);
    FETCH cr_all_cheques_data INTO rw_all_cheques_data;
     
    IF cr_all_cheques_data%FOUND THEN
      OPEN cr_cooperativa(pr_cdagectl => rw_all_cheques_data.cdagechq);
        FETCH cr_cooperativa INTO rw_cooperativa;
        IF cr_cooperativa%FOUND THEN
          OPEN  cr_cooperado(pr_cdcooper => rw_cooperativa.cdcooper,
                             pr_nrdconta => rw_all_cheques_data.nrctachq);
            FETCH cr_cooperado INTO rw_cooperado;
            IF cr_cooperado%FOUND THEN
              vr_nrcpfcgc := rw_cooperado.nrcpfcgc;
              vr_nmprimtl := rw_cooperado.nmprimtl;
            END IF;
          CLOSE cr_cooperado;
        END IF;
      CLOSE cr_cooperativa;      
      UPDATE tbjur_qbr_sig_extrato qbr
        SET qbr.nrdocmto = rw_all_cheques_data.nrdocmto
           ,qbr.cdbandep = rw_all_cheques_data.cdbanchq
           ,qbr.cdagedep = rw_all_cheques_data.cdagechq
           ,qbr.nrctadep = rw_all_cheques_data.nrctachq
           ,qbr.tpdconta = ''
           ,qbr.inpessoa = ''
           ,qbr.nrcpfcgc = rw_cooperado.nrcpfcgc
           ,qbr.nmprimtl = rw_cooperado.nmprimtl
           ,qbr.tpdocttl = ''
           ,qbr.nrdocttl = ''
           ,qbr.dscodbar = ''
           ,qbr.nmendoss = ''
           ,qbr.docendos = ''
           ,qbr.idsitide = '0'
           ,qbr.dsobserv = ''
           ,qbr.idsitqbr = 1          
           ,qbr.dsobsqbr = ''  
      WHERE qbr.nrseqlcm = rw_craplcm.progress_recid; 
       
       CLOSE cr_all_cheques_data;    
    ELSE
      RAISE vr_exc_saida;
      CLOSE cr_all_cheques_data; 
    END IF;                                                 
  END LOOP;
  
  COMMIT;
EXCEPTION
  WHEN vr_exc_saida THEN
    ROLLBACK;
  
  WHEN OTHERS THEN    
    ROLLBACK;
END;
