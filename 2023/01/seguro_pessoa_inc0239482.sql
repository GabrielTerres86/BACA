DECLARE
  vr_ind_arq        utl_file.file_type;
  vr_linha          VARCHAR2(32767);
  vr_dscritic       VARCHAR2(2000);
  vr_nmdir          VARCHAR2(4000) := CECRED.gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/INC0239482';
  vr_nmarq          VARCHAR2(100)  := 'ROLLBACK_INC0239482.sql';
  vr_exc_saida      EXCEPTION;
  vr_cdcritic       PLS_INTEGER;
  vr_count          PLS_INTEGER := 0;
  
  CURSOR cr_prestamista(pr_cdcooper IN craplau.cdcooper%TYPE) IS
    SELECT p.cdcooper
          ,p.nrdconta
          ,p.nrctrseg
          ,p.nrctremp
          ,p.nrproposta
          ,p.vlprodut
      FROM CECRED.tbseg_prestamista p
     WHERE p.cdcooper = pr_cdcooper
       AND p.nrproposta IN ('770629723404',
                            '202210507448',
                            '202210507201',
                            '770629549358',
                            '770629614443',
                            '202210507227',
                            '202210507585',
                            '202210507451',
                            '202212793686',
                            '770629163026',
                            '202212148285',
                            '770628774161',
                            '202212178563',
                            '202210749023',
                            '202210507413',
                            '202210494567',
                            '202210493967',
                            '770629361243',
                            '202210153786',
                            '770629300015',
                            '770629110046',
                            '770629363297');
  
  CURSOR cr_crapcop IS
    SELECT c.cdcooper
          ,d.dtmvtolt
      FROM CECRED.crapcop c,
           CECRED.crapdat d
     WHERE c.flgativo = 1
       AND c.cdcooper <> 3
       AND c.cdcooper = d.cdcooper;  
  
BEGIN
  
  CECRED.GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdir
                                 ,pr_nmarquiv => vr_nmarq
                                 ,pr_tipabert => 'W'
                                 ,pr_utlfileh => vr_ind_arq
                                 ,pr_des_erro => vr_dscritic);

  IF vr_dscritic IS NOT NULL THEN
     vr_dscritic := vr_dscritic ||'  Não pode abrir arquivo '|| vr_nmdir || vr_nmarq;
     RAISE vr_exc_saida;
  END IF;

  CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'BEGIN');

  FOR rw_crapcop IN cr_crapcop LOOP
    FOR rw_prestamista IN cr_prestamista(pr_cdcooper => rw_crapcop.cdcooper) LOOP
      CECRED.segu0003.pc_efetuar_estorno(pr_cdcooper   => rw_prestamista.cdcooper,
                                         pr_nrdconta   => rw_prestamista.nrdconta,
                                         pr_nrctrseg   => rw_prestamista.nrctrseg,
                                         pr_nrctremp   => rw_prestamista.nrctremp,
                                         pr_nrproposta => rw_prestamista.nrproposta,
                                         pr_dtmvtolt   => rw_crapcop.dtmvtolt,
                                         pr_cdhistor   => 4060,
                                         pr_cdcritic   => vr_cdcritic,
                                         pr_dscritic   => vr_dscritic);
                  
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      BEGIN
        SELECT COUNT(1)
          INTO vr_count
          FROM CECRED.craplcm l
         WHERE l.cdcooper = rw_prestamista.cdcooper
           AND l.nrdconta = rw_prestamista.nrdconta
           AND l.cdhistor = 4060 
           AND l.dtmvtolt >= rw_crapcop.dtmvtolt;
      EXCEPTION WHEN OTHERS THEN
        vr_count := 0;
      END;
      
      IF vr_count > 0 THEN
        vr_linha := 'DELETE CECRED.craplcm l '  ||
                    ' WHERE l.cdcooper = ' || rw_prestamista.cdcooper  ||
                    '   AND l.nrdconta = ' || rw_prestamista.nrdconta  ||
                    '   AND l.cdhistor = 4060 
                        AND l.dtmvtolt >= TO_DATE(''' || rw_crapcop.dtmvtolt || ''',''DD/MM/RRRR'');';

        CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
      END IF;
    END LOOP;
  END LOOP;
  COMMIT;
  
  CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' COMMIT;');
  CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' END; ');
  CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'/ ');
  CECRED.GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arq );
EXCEPTION
   WHEN vr_exc_saida THEN
        vr_dscritic := vr_dscritic || SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
        dbms_output.put_line(vr_dscritic);
        ROLLBACK;
   WHEN OTHERS THEN
        vr_dscritic := vr_dscritic || SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
        dbms_output.put_line(vr_dscritic);
        ROLLBACK;
END;
/
