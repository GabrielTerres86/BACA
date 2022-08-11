DECLARE
  vr_ind_arq      utl_file.file_type;
  vr_linha        VARCHAR2(32767);
  vr_dscritic     VARCHAR2(2000);
  vr_nmdir        VARCHAR2(4000) := CECRED.gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/INC0197338';
  vr_nmarq        VARCHAR2(100)  := 'ROLLBACK_INC0197338.sql';
  vr_exc_saida    EXCEPTION;
  vcount          NUMBER;
  vr_saldodevedor NUMBER;
  vr_cdcritic     NUMBER;
  vr_apolice      VARCHAR2(20);
  vr_pgtosegu     NUMBER;
  vr_vlcapmor     NUMBER;
  vr_vlpremor     NUMBER;
  vr_vlpreinv     NUMBER;
  vr_vlpretot     NUMBER;
  vr_vlpreiof     NUMBER;
  vr_vlpreliq     NUMBER;
  vlpreperda      NUMBER;

  CURSOR cr_crawseg(pr_cdcooper CECRED.crawseg.cdcooper%TYPE,
                    pr_nrdconta CECRED.crawseg.nrdconta%TYPE,
                    pr_nrctrseg CECRED.crawseg.nrctrseg%TYPE) IS
    SELECT w.vlpremio
      FROM CECRED.crawseg w
     WHERE w.cdcooper = pr_cdcooper
       AND w.nrdconta = pr_nrdconta
       AND w.nrctrseg = pr_nrctrseg;

  CURSOR cr_crapseg(pr_cdcooper CECRED.crapseg.cdcooper%TYPE,
                    pr_nrdconta CECRED.crapseg.nrdconta%TYPE,
                    pr_nrctrseg CECRED.crapseg.nrctrseg%TYPE) IS
    SELECT p.vlpremio
      FROM CECRED.crapseg p
     WHERE p.cdcooper = pr_cdcooper
       AND p.nrdconta = pr_nrdconta
       AND p.tpseguro = 4
       AND p.nrctrseg = pr_nrctrseg;

  CURSOR cr_prestamista(pr_cdcooper CECRED.tbseg_prestamista.cdcooper%TYPE) IS
    SELECT p.cdcooper,
           p.nrdconta,
           p.nrctrseg,
           p.nrctremp,
           p.nrproposta,
           p.tpregist,
           p.dtnasctl,
           p.dtinivig,
           p.dtfimvig,
           p.vlprodut,
           p.vlsdeved,
           p.pemorte,
           p.peinvalidez,
           p.peiftttaxa,
           p.qtifttdias,
           p.vlpielimit,
           p.vlifttlimi,
           e.vlpreemp,
           e.qtpreemp,
           w.flggarad
      FROM crapepr e,
           crawseg w,
           tbseg_prestamista p
     WHERE p.cdcooper = pr_cdcooper
       AND p.cdcooper = w.cdcooper
       AND p.nrdconta = w.nrdconta
       AND p.nrctrseg = w.nrctrseg
       AND p.nrctremp = w.nrctrato
       AND p.cdcooper = e.cdcooper
       AND p.nrdconta = e.nrdconta
       AND p.nrctremp = e.nrctremp
       AND p.nrproposta IN ('770629438971',
                            '770629679472',
                            '770628811016');

  CURSOR cr_crapcop IS
    SELECT c.cdcooper
      FROM CECRED.crapcop c,
           CECRED.crapdat d
     WHERE c.flgativo = 1
       AND c.cdcooper <> 3
       AND c.cdcooper = d.cdcooper;

  BEGIN
    BEGIN
      CECRED.GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdir
                              ,pr_nmarquiv => vr_nmarq
                              ,pr_tipabert => 'W'
                              ,pr_utlfileh => vr_ind_arq
                              ,pr_des_erro => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
         vr_dscritic := vr_dscritic ||'  Não pode abrir arquivo '||vr_nmdir || vr_nmarq;
         RAISE vr_exc_saida;
      END IF;

      GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'BEGIN');

      FOR rw_crapcop IN cr_crapcop LOOP
        vcount := 0;
        vr_linha := '';

        FOR rw_prestamista IN cr_prestamista(pr_cdcooper => rw_crapcop.cdcooper) LOOP

          SEGU0003.pc_verifica_vlseguro_imp_contributario(pr_cdcooper => rw_prestamista.cdcooper
                                                   ,pr_nrdconta => rw_prestamista.nrdconta
                                                   ,pr_nrctremp => rw_prestamista.nrctremp
                                                   ,pr_vlseguro => vr_saldodevedor
                                                   ,pr_cdcritic => vr_cdcritic
                                                   ,pr_dscritic => vr_dscritic);
                                                   
          IF vr_saldodevedor = 0 THEN
            vr_saldodevedor := rw_prestamista.vlsdeved;
          END IF;

          SEGU0003.pc_retorna_valores_contributario(pr_cdcooper    => rw_prestamista.cdcooper                     
                                                   ,pr_nrdconta    => rw_prestamista.nrdconta                     
                                                   ,pr_nrctremp    => rw_prestamista.nrctremp                     
                                                   ,pr_nrctrseg    => rw_prestamista.nrctrseg                     
                                                   ,pr_dtnascsg    => rw_prestamista.dtnasctl                     
                                                   ,pr_vlpreemp    => rw_prestamista.vlpreemp                     
                                                   ,pr_qtpreemp    => rw_prestamista.qtpreemp                     
                                                   ,pr_flggarad    => rw_prestamista.flggarad                     
                                                   ,pr_dtinivig    => rw_prestamista.dtinivig                     
                                                   ,pr_dtfimvig    => rw_prestamista.dtfimvig                     
                                                   ,pr_totsimul    => vr_saldodevedor                             
                                                   ,pr_flefetivada => 'S'                                         
                                                   ,pr_pemorte     => rw_prestamista.pemorte                      
                                                   ,pr_peinvalidez => rw_prestamista.peinvalidez                  
                                                   ,pr_peiftttaxa  => rw_prestamista.peiftttaxa                   
                                                   ,pr_qtifttdias  => rw_prestamista.qtifttdias                   
                                                   ,pr_pielimit    => rw_prestamista.vlpielimit                   
                                                   ,pr_ifttlimi    => rw_prestamista.vlifttlimi                   
                                                   ,pr_apolice     => vr_apolice                                  
                                                   ,pr_pgtosegu    => vr_pgtosegu                                 
                                                   ,pr_vlsdeved    => vr_vlcapmor                                 
                                                   ,pr_vlpremor    => vr_vlpremor                                 
                                                   ,pr_vlpreinv    => vr_vlpreinv                                 
                                                   ,pr_preperda    => vlpreperda                                  
                                                   ,pr_vlpreliq    => vr_vlpreliq                                 
                                                   ,pr_vlpreiof    => vr_vlpreiof                                 
                                                   ,pr_vlpretot    => vr_vlpretot                                 
                                                   ,pr_cdcritic    => vr_cdcritic                                 
                                                   ,pr_dscritic    => vr_dscritic);          
          
          vr_linha :=   'UPDATE CECRED.tbseg_prestamista '
                      ||'   SET vlprodut = ''' || rw_prestamista.vlprodut || ''''
                      ||' WHERE cdcooper = ' || rw_crapcop.cdcooper
                      ||'   AND nrdconta = ' || rw_prestamista.nrdconta
                      ||'   AND nrctrseg = ' || rw_prestamista.nrctrseg ||' ; ';

          CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

          UPDATE CECRED.tbseg_prestamista p
             SET p.vlprodut = vr_vlpretot
           WHERE p.cdcooper = rw_crapcop.cdcooper
             AND p.nrdconta = rw_prestamista.nrdconta
             AND p.nrctrseg = rw_prestamista.nrctrseg;

          FOR rw_crawseg IN cr_crawseg(pr_cdcooper => rw_crapcop.cdcooper
                                      ,pr_nrdconta => rw_prestamista.nrdconta
                                      ,pr_nrctrseg => rw_prestamista.nrctrseg) LOOP

            vr_linha :=   'UPDATE CECRED.crawseg '
                        ||'   SET vlpremio = ''' || rw_crawseg.vlpremio || ''''
                        ||' WHERE cdcooper = ' || rw_crapcop.cdcooper
                        ||'   AND nrdconta = ' || rw_prestamista.nrdconta
                        ||'   AND nrctrseg = ' || rw_prestamista.nrctrseg ||' ; ';

            CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

            UPDATE CECRED.crawseg w
               SET w.vlpremio = vr_vlpretot
             WHERE w.cdcooper = rw_crapcop.cdcooper
               AND w.nrdconta = rw_prestamista.nrdconta
               AND w.nrctrseg = rw_prestamista.nrctrseg;
          END LOOP;

          FOR rw_crapseg IN cr_crapseg(pr_cdcooper => rw_crapcop.cdcooper
                                      ,pr_nrdconta => rw_prestamista.nrdconta
                                      ,pr_nrctrseg => rw_prestamista.nrctrseg) LOOP

          vr_linha :=   'UPDATE CECRED.crapseg '
                      ||'   SET vlpremio = ''' || rw_crapseg.vlpremio || ''''
                      ||' WHERE cdcooper = ' || rw_crapcop.cdcooper
                      ||'   AND nrdconta = ' || rw_prestamista.nrdconta
                      ||'   AND nrctrseg = ' || rw_prestamista.nrctrseg ||' ; ';

          CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

          UPDATE CECRED.crapseg p
             SET p.vlpremio = vr_vlpretot
           WHERE p.cdcooper = rw_crapcop.cdcooper
             AND p.nrdconta = rw_prestamista.nrdconta
             AND p.nrctrseg = rw_prestamista.nrctrseg;
          END LOOP;

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
END;
/
