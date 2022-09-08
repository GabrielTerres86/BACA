DECLARE
  vr_ind_arq        utl_file.file_type;
  vr_linha          VARCHAR2(32767);
  vr_cdcritic       NUMBER;
  vr_dscritic       VARCHAR2(2000);
  vr_nmdir          VARCHAR2(4000) := CECRED.gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/INC0211988';
  vr_nmarq          VARCHAR2(100)  := 'ROLLBACK_INC0211988.sql';
  vr_exc_saida      EXCEPTION;
  vcount            NUMBER;

  CURSOR cr_principal(pr_cdcooper CECRED.crapseg.cdcooper%TYPE) IS
    SELECT p.dtinivig
          ,p.cdcooper
          ,3651 cdhistor
          ,p.nrdconta
          ,p.nrctremp
          ,p.vlprodut
          ,p.nrproposta
      FROM crawseg w,
           tbseg_prestamista p
     WHERE p.cdcooper = pr_cdcooper
       AND w.cdcooper = p.cdcooper
       AND w.nrdconta = p.nrdconta
       AND w.nrctrseg = p.nrctrseg
       AND w.flgassum = 1
       AND w.flfinanciasegprestamista = 0
       AND w.tpcustei = 0
       AND p.tpregist IN (1,3)
       AND NOT EXISTS (SELECT 1
                         FROM crapseg s
                        WHERE s.cdcooper = p.cdcooper
                          AND s.nrdconta = p.nrdconta
                          AND s.nrctrseg = p.nrctrseg
                          AND s.tpseguro = 4
                          AND s.cdsitseg = 2
                          AND ROWNUM = 1)
       AND NOT EXISTS (SELECT 1
                         FROM craplau u
                        WHERE p.cdcooper = u.cdcooper
                          AND p.nrdconta = u.nrdconta
                          AND p.nrctremp = u.nrctremp
                          AND p.nrproposta = u.cdseqtel
                          AND u.cdhistor = 3651);

  CURSOR cr_crplau(pr_cdcooper   craplau.cdcooper%TYPE,
                   pr_nrdconta   craplau.nrdconta%TYPE,
                   pr_nrctremp   craplau.nrctremp%TYPE,
                   pr_nrproposta craplau.cdseqtel%TYPE) IS
    SELECT u.idlancto
      FROM CECRED.craplau u
     WHERE u.cdcooper = pr_cdcooper
       AND u.nrdconta = pr_nrdconta
       AND u.nrctremp = pr_nrctremp
       AND u.cdseqtel = pr_nrproposta
       AND u.cdhistor = 3651;
  rw_crplau cr_crplau%ROWTYPE;
  
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
        vcount := 0;
        vr_linha := '';

        FOR rw_principal IN cr_principal(pr_cdcooper => rw_crapcop.cdcooper) LOOP
          segu0001.pc_agenda_pgto_prest_contrib(pr_dtmvtolt   => rw_principal.dtinivig,
                                                pr_cdcooper   => rw_principal.cdcooper,
                                                pr_cdhistor   => rw_principal.cdhistor,
                                                pr_nrdconta   => rw_principal.nrdconta,
                                                pr_nrctremp   => rw_principal.nrctremp,
                                                pr_nrproposta => rw_principal.nrproposta,
                                                pr_vlslddev   => rw_principal.vlprodut,
                                                pr_cdcritic   => vr_cdcritic,
                                                pr_dscritic   => vr_dscritic);
          
          OPEN cr_crplau(pr_cdcooper   => rw_principal.cdcooper,
                         pr_nrdconta   => rw_principal.nrdconta,
                         pr_nrctremp   => rw_principal.nrctremp,
                         pr_nrproposta => rw_principal.nrproposta);
            FETCH cr_crplau INTO rw_crplau;
            
            IF cr_crplau%FOUND THEN
              vr_linha :=   'DELETE CECRED.craplau '
                          ||' WHERE idlancto = ' || rw_crplau.idlancto ||' ; ';

              CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
            END IF;
          CLOSE cr_crplau;
          
          IF vcount = 1000 THEN
            COMMIT;
          ELSE
            vcount := vcount + 1;
          END IF;
        END LOOP;

        COMMIT;
      END LOOP;

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
