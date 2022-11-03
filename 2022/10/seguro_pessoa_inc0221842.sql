DECLARE
  vr_ind_arq        utl_file.file_type;
  vr_linha          VARCHAR2(32767);
  vr_dscritic       VARCHAR2(2000);
  vr_nmdir          VARCHAR2(4000) := CECRED.gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/INC0221842';
  vr_nmarq          VARCHAR2(100)  := 'ROLLBACK_INC0221842.sql';
  vr_exc_saida      EXCEPTION;
  vcount            NUMBER;

  CURSOR cr_crawseg(pr_cdcooper CECRED.crawseg.cdcooper%TYPE
                   ,pr_nrdconta CECRED.crawseg.nrdconta%TYPE
                   ,pr_nrctrseg CECRED.crawseg.nrctrseg%TYPE) IS
    SELECT p.*
      FROM CECRED.crawseg p
     WHERE p.cdcooper = pr_cdcooper
       AND p.nrdconta = pr_nrdconta
       AND p.nrctrseg = pr_nrctrseg;

  CURSOR cr_crapseg(pr_cdcooper CECRED.crapseg.cdcooper%TYPE
                   ,pr_nrdconta CECRED.crapseg.nrdconta%TYPE
                   ,pr_nrctrseg CECRED.crapseg.nrctrseg%TYPE) IS
    SELECT p.*
      FROM CECRED.crapseg p
     WHERE p.cdcooper = pr_cdcooper
       AND p.nrdconta = pr_nrdconta
       AND p.nrctrseg = pr_nrctrseg
       AND p.tpseguro = 4;

  CURSOR cr_prestamista(pr_cdcooper CECRED.tbseg_prestamista.cdcooper%TYPE
                       ,pr_nrdconta CECRED.tbseg_prestamista.nrdconta%TYPE
                       ,pr_nrctremp CECRED.tbseg_prestamista.nrctremp%TYPE) IS
    SELECT e.inliquid,
           e.dtliquid,
           s.cdsitseg,
           p.*
      FROM CECRED.crapseg s,
           CECRED.crapepr e,
           CECRED.tbseg_prestamista p
     WHERE p.cdcooper = e.cdcooper
       AND p.nrdconta = e.nrdconta
       AND p.nrctremp = e.nrctremp
       AND p.cdcooper = s.cdcooper
       AND p.nrdconta = s.nrdconta
       AND p.nrctrseg = s.nrctrseg
       AND p.cdcooper = pr_cdcooper
       AND p.nrdconta = pr_nrdconta
       AND p.nrctremp = pr_nrctremp
       AND p.tpcustei = 0
    ORDER BY p.idseqtra;

  CURSOR cr_principal(pr_cdcooper CECRED.crapseg.cdcooper%TYPE) IS
    SELECT p.cdcooper,
           p.nrdconta,
           p.nrctremp,
           MIN(p.idseqtra) idseqtra
      FROM CECRED.tbseg_prestamista p
     WHERE p.cdcooper = pr_cdcooper
       AND p.tpcustei = 0
     GROUP BY p.cdcooper, p.nrdconta, p.nrctremp
    HAVING COUNT(1) > 1;

  CURSOR cr_crapcop IS
    SELECT c.cdcooper
          ,d.dtmvtolt
      FROM CECRED.crapcop c,
           CECRED.crapdat d
     WHERE c.flgativo = 1
       AND c.cdcooper IN (11,13)
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
        vr_dscritic := vr_dscritic ||'  Não pode abrir arquivo '|| vr_nmdir || vr_nmarq;
        RAISE vr_exc_saida;
      END IF;

      CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'BEGIN');

      FOR rw_crapcop IN cr_crapcop LOOP
        vcount := 0;
        vr_linha := '';

        FOR rw_principal IN cr_principal(pr_cdcooper => rw_crapcop.cdcooper) LOOP
          FOR rw_prestamista IN cr_prestamista(pr_cdcooper => rw_principal.cdcooper
                                              ,pr_nrdconta => rw_principal.nrdconta
                                              ,pr_nrctremp => rw_principal.nrctremp) LOOP
            IF rw_principal.idseqtra = rw_prestamista.idseqtra THEN
              IF rw_prestamista.inliquid = 0 AND
                 rw_prestamista.tpregist <> 2 AND
                 rw_prestamista.cdsitseg <> 5  THEN

                IF rw_prestamista.tpregist <> 3 THEN
                  vr_linha := 'UPDATE CECRED.tbseg_prestamista p
                                  SET p.tpregist = ' || rw_prestamista.tpregist || '
                                WHERE p.idseqtra = ' || rw_prestamista.idseqtra || ';';

                  CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

                  UPDATE CECRED.tbseg_prestamista p
                     SET p.tpregist = 3
                   WHERE p.idseqtra = rw_prestamista.idseqtra;
                END IF;

                IF rw_prestamista.cdsitseg <> 1 THEN
                  FOR rw_crapseg IN cr_crapseg(pr_cdcooper => rw_prestamista.cdcooper
                                              ,pr_nrdconta => rw_prestamista.nrdconta
                                              ,pr_nrctrseg => rw_prestamista.nrctrseg) LOOP
                                              
                    IF rw_crapseg.cdmotcan IS NULL THEN
                      vr_linha := 'UPDATE CECRED.crapseg p
                                      SET p.cdsitseg = ' || rw_crapseg.cdsitseg || '
                                         ,p.dtcancel = TO_DATE(''' || rw_crapseg.dtcancel || ''',''DD/MM/RRRR'')
                                         ,p.dtfimvig = TO_DATE(''' || rw_crapseg.dtfimvig || ''',''DD/MM/RRRR'')
                                    WHERE p.progress_recid = ' || rw_crapseg.progress_recid || ';';

                    ELSE
                      vr_linha := 'UPDATE CECRED.crapseg p
                                      SET p.cdsitseg = ' || rw_crapseg.cdsitseg || '
                                         ,p.dtcancel = TO_DATE(''' || rw_crapseg.dtcancel || ''',''DD/MM/RRRR'')
                                         ,p.cdmotcan = ' || rw_crapseg.cdmotcan || '
                                         ,p.dtfimvig = TO_DATE(''' || rw_crapseg.dtfimvig || ''',''DD/MM/RRRR'')
                                    WHERE p.progress_recid = ' || rw_crapseg.progress_recid || ';';
                    END IF;
                    CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

                    UPDATE CECRED.crapseg p
                       SET p.cdsitseg = 1
                          ,p.dtcancel = NULL
                          ,p.cdmotcan = NULL
                          ,p.dtfimvig = rw_prestamista.dtfimvig
                     WHERE p.progress_recid = rw_crapseg.progress_recid;
                  END LOOP;
                END IF;
              END IF;
            ELSE
              IF TO_DATE(rw_prestamista.dtinivig,'DD/MM/YYYY') = TO_DATE('26/09/2022','DD/MM/YYYY')
                 OR rw_prestamista.nrproposta IN ('202208458813','770629153446') THEN
                vr_linha := 'INSERT INTO CECRED.tbseg_prestamista(idseqtra,
                                                                  cdcooper,
                                                                  nrdconta,
                                                                  nrctrseg,
                                                                  nrctremp,
                                                                  tpregist,
                                                                  cdapolic,
                                                                  nrcpfcgc,
                                                                  nmprimtl,
                                                                  dtnasctl,
                                                                  cdsexotl,
                                                                  dsendres,
                                                                  dsdemail,
                                                                  nmbairro,
                                                                  nmcidade,
                                                                  cdufresd,
                                                                  nrcepend,
                                                                  nrtelefo,
                                                                  dtdevend,
                                                                  dtinivig,
                                                                  cdcobran,
                                                                  cdadmcob,
                                                                  tpfrecob,
                                                                  tpsegura,
                                                                  cdprodut,
                                                                  cdplapro,
                                                                  vlprodut,
                                                                  tpcobran,
                                                                  vlsdeved,
                                                                  vldevatu,
                                                                  dtrefcob,
                                                                  dtfimvig,
                                                                  dtdenvio,
                                                                  nrproposta,
                                                                  tprecusa,
                                                                  cdmotrec,
                                                                  dtrecusa,
                                                                  situacao,
                                                                  tpcustei,
                                                                  pemorte,
                                                                  peinvalidez,
                                                                  peiftttaxa,
                                                                  qtifttdias,
                                                                  nrapolice,
                                                                  qtparcel,
                                                                  vlpielimit,
                                                                  vlifttlimi,
                                                                  dsprotocolo,
                                                                  flfinanciasegprestamista)
                   VALUES (     ''' || rw_prestamista.idseqtra                  || ''','
                            || '''' || rw_prestamista.cdcooper                  || ''','
                            || '''' || rw_prestamista.nrdconta                  || ''','
                            || '''' || rw_prestamista.nrctrseg                  || ''','
                            || '''' || rw_prestamista.nrctremp                  || ''','
                            || '''' || rw_prestamista.tpregist                  || ''','
                            || '''' || rw_prestamista.cdapolic                  || ''','
                            || '''' || rw_prestamista.nrcpfcgc                  || ''','
                            || '''' || rw_prestamista.nmprimtl                  || ''','
                            || 'TO_DATE(''' || rw_prestamista.dtnasctl       || ''',''DD/MM/RRRR''),'
                            || '''' || rw_prestamista.cdsexotl                  || ''','
                            || '''' || rw_prestamista.dsendres                  || ''','
                            || '''' || rw_prestamista.dsdemail                  || ''','
                            || '''' || rw_prestamista.nmbairro                  || ''','
                            || '''' || rw_prestamista.nmcidade                  || ''','
                            || '''' || rw_prestamista.cdufresd                  || ''','
                            || '''' || rw_prestamista.nrcepend                  || ''','
                            || '''' || rw_prestamista.nrtelefo                  || ''','
                            || 'TO_DATE(''' || rw_prestamista.dtdevend       || ''',''DD/MM/RRRR''),'
                            || 'TO_DATE(''' || rw_prestamista.dtinivig       || ''',''DD/MM/RRRR''),'
                            || '''' || rw_prestamista.cdcobran                  || ''','
                            || '''' || rw_prestamista.cdadmcob                  || ''','
                            || '''' || rw_prestamista.tpfrecob                  || ''','
                            || '''' || rw_prestamista.tpsegura                  || ''','
                            || '''' || rw_prestamista.cdprodut                  || ''','
                            || '''' || rw_prestamista.cdplapro                  || ''','
                            || '''' || rw_prestamista.vlprodut                  || ''','
                            || '''' || rw_prestamista.tpcobran                  || ''','
                            || '''' || rw_prestamista.vlsdeved                  || ''','
                            || '''' || rw_prestamista.vldevatu                  || ''','
                            || 'TO_DATE(''' || rw_prestamista.dtrefcob       || ''',''DD/MM/RRRR''),'
                            || 'TO_DATE(''' || rw_prestamista.dtfimvig       || ''',''DD/MM/RRRR''),'
                            || 'TO_DATE(''' || rw_prestamista.dtdenvio       || ''',''DD/MM/RRRR''),'
                            || '''' || rw_prestamista.nrproposta                || ''','
                            || '''' || rw_prestamista.tprecusa                  || ''','
                            || '''' || rw_prestamista.cdmotrec                  || ''','
                            || 'TO_DATE(''' || rw_prestamista.dtrecusa       || ''',''DD/MM/RRRR''),'
                            || '''' || rw_prestamista.situacao                  || ''','
                            || '''' || rw_prestamista.tpcustei                  || ''','
                            || '''' || rw_prestamista.pemorte                   || ''','
                            || '''' || rw_prestamista.peinvalidez               || ''','
                            || '''' || rw_prestamista.peiftttaxa                || ''','
                            || '''' || rw_prestamista.qtifttdias                || ''','
                            || '''' || rw_prestamista.nrapolice                 || ''','
                            || '''' || rw_prestamista.qtparcel                  || ''','
                            || '''' || rw_prestamista.vlpielimit                || ''','
                            || '''' || rw_prestamista.vlifttlimi                || ''','
                            || '''' || rw_prestamista.dsprotocolo               || ''','
                            || '''' || rw_prestamista.flfinanciasegprestamista  || ''');';

                CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

                DELETE CECRED.tbseg_prestamista p
                 WHERE p.idseqtra = rw_prestamista.idseqtra;

                FOR rw_crapseg IN cr_crapseg(pr_cdcooper => rw_prestamista.cdcooper
                                            ,pr_nrdconta => rw_prestamista.nrdconta
                                            ,pr_nrctrseg => rw_prestamista.nrctrseg) LOOP

                  vr_linha := 'INSERT INTO CECRED.crapseg(nrdconta,
                                                          nrctrseg,
                                                          dtinivig,
                                                          dtfimvig,
                                                          dtmvtolt,
                                                          cdagenci,
                                                          cdbccxlt,
                                                          cdsitseg,
                                                          dtaltseg,
                                                          dtcancel,
                                                          dtdebito,
                                                          dtiniseg,
                                                          indebito,
                                                          nrdolote,
                                                          nrseqdig,
                                                          qtprepag,
                                                          vlprepag,
                                                          vlpreseg,
                                                          dtultpag,
                                                          tpseguro,
                                                          tpplaseg,
                                                          qtprevig,
                                                          cdsegura,
                                                          lsctrant,
                                                          nrctratu,
                                                          flgunica,
                                                          dtprideb,
                                                          vldifseg,
                                                          nmbenvid##1,
                                                          nmbenvid##2,
                                                          nmbenvid##3,
                                                          nmbenvid##4,
                                                          nmbenvid##5,
                                                          dsgraupr##1,
                                                          dsgraupr##2,
                                                          dsgraupr##3,
                                                          dsgraupr##4,
                                                          dsgraupr##5,
                                                          txpartic##1,
                                                          txpartic##2,
                                                          txpartic##3,
                                                          txpartic##4,
                                                          txpartic##5,
                                                          dtultalt,
                                                          cdoperad,
                                                          vlpremio,
                                                          qtparcel,
                                                          tpdpagto,
                                                          cdcooper,
                                                          flgconve,
                                                          flgclabe,
                                                          cdmotcan,
                                                          tpendcor,
                                                          progress_recid,
                                                          cdopecnl,
                                                          dtrenova,
                                                          cdopeori,
                                                          cdageori,
                                                          dtinsori,
                                                          cdopeexc,
                                                          cdageexc,
                                                          dtinsexc,
                                                          vlslddev,
                                                          idimpdps)
                              VALUES (    ''' || rw_crapseg.nrdconta       || ''','
                                      || '''' || rw_crapseg.nrctrseg       || ''','
                                      || 'TO_DATE(''' || rw_crapseg.dtinivig       || ''',''DD/MM/RRRR''),'
                                      || 'TO_DATE(''' || rw_crapseg.dtfimvig       || ''',''DD/MM/RRRR''),'
                                      || 'TO_DATE(''' || rw_crapseg.dtmvtolt       || ''',''DD/MM/RRRR''),'
                                      || '''' || rw_crapseg.cdagenci       || ''','
                                      || '''' || rw_crapseg.cdbccxlt       || ''','
                                      || '''' || rw_crapseg.cdsitseg       || ''','
                                      || 'TO_DATE(''' || rw_crapseg.dtaltseg       || ''',''DD/MM/RRRR''),'
                                      || 'TO_DATE(''' || rw_crapseg.dtcancel       || ''',''DD/MM/RRRR''),'
                                      || 'TO_DATE(''' || rw_crapseg.dtdebito       || ''',''DD/MM/RRRR''),'
                                      || 'TO_DATE(''' || rw_crapseg.dtiniseg       || ''',''DD/MM/RRRR''),'
                                      || '''' || rw_crapseg.indebito       || ''','
                                      || '''' || rw_crapseg.nrdolote       || ''','
                                      || '''' || rw_crapseg.nrseqdig       || ''','
                                      || '''' || rw_crapseg.qtprepag       || ''','
                                      || '''' || rw_crapseg.vlprepag       || ''','
                                      || '''' || rw_crapseg.vlpreseg       || ''','
                                      || 'TO_DATE(''' || rw_crapseg.dtultpag       || ''',''DD/MM/RRRR''),'
                                      || '''' || rw_crapseg.tpseguro       || ''','
                                      || '''' || rw_crapseg.tpplaseg       || ''','
                                      || '''' || rw_crapseg.qtprevig       || ''','
                                      || '''' || rw_crapseg.cdsegura       || ''','
                                      || '''' || rw_crapseg.lsctrant       || ''','
                                      || '''' || rw_crapseg.nrctratu       || ''','
                                      || '''' || rw_crapseg.flgunica       || ''','
                                      || 'TO_DATE(''' || rw_crapseg.dtprideb       || ''',''DD/MM/RRRR''),'
                                      || '''' || rw_crapseg.vldifseg       || ''','
                                      || '''' || rw_crapseg.nmbenvid##1    || ''','
                                      || '''' || rw_crapseg.nmbenvid##2    || ''','
                                      || '''' || rw_crapseg.nmbenvid##3    || ''','
                                      || '''' || rw_crapseg.nmbenvid##4    || ''','
                                      || '''' || rw_crapseg.nmbenvid##5    || ''','
                                      || '''' || rw_crapseg.dsgraupr##1    || ''','
                                      || '''' || rw_crapseg.dsgraupr##2    || ''','
                                      || '''' || rw_crapseg.dsgraupr##3    || ''','
                                      || '''' || rw_crapseg.dsgraupr##4    || ''','
                                      || '''' || rw_crapseg.dsgraupr##5    || ''','
                                      || '''' || rw_crapseg.txpartic##1    || ''','
                                      || '''' || rw_crapseg.txpartic##2    || ''','
                                      || '''' || rw_crapseg.txpartic##3    || ''','
                                      || '''' || rw_crapseg.txpartic##4    || ''','
                                      || '''' || rw_crapseg.txpartic##5    || ''','
                                      || 'TO_DATE(''' || rw_crapseg.dtultalt       || ''',''DD/MM/RRRR''),'
                                      || '''' || rw_crapseg.cdoperad       || ''','
                                      || '''' || rw_crapseg.vlpremio       || ''','
                                      || '''' || rw_crapseg.qtparcel       || ''','
                                      || '''' || rw_crapseg.tpdpagto       || ''','
                                      || '''' || rw_crapseg.cdcooper       || ''','
                                      || '''' || rw_crapseg.flgconve       || ''','
                                      || '''' || rw_crapseg.flgclabe       || ''','
                                      || '''' || rw_crapseg.cdmotcan       || ''','
                                      || '''' || rw_crapseg.tpendcor       || ''','
                                      || '''' || rw_crapseg.progress_recid || ''','
                                      || '''' || rw_crapseg.cdopecnl       || ''','
                                      || 'TO_DATE(''' || rw_crapseg.dtrenova       || ''',''DD/MM/RRRR''),'
                                      || '''' || rw_crapseg.cdopeori       || ''','
                                      || '''' || rw_crapseg.cdageori       || ''','
                                      || 'TO_DATE(''' || rw_crapseg.dtinsori       || ''',''DD/MM/RRRR''),'
                                      || '''' || rw_crapseg.cdopeexc       || ''','
                                      || '''' || rw_crapseg.cdageexc       || ''','
                                      || 'TO_DATE(''' || rw_crapseg.dtinsexc       || ''',''DD/MM/RRRR''),'
                                      || '''' || rw_crapseg.vlslddev       || ''','
                                      || '''' || rw_crapseg.idimpdps       || ''');';

                  CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

                  DELETE CECRED.crapseg p
                   WHERE p.progress_recid = rw_crapseg.progress_recid;
                END LOOP;
                
                FOR rw_crawseg IN cr_crawseg(pr_cdcooper => rw_prestamista.cdcooper
                                            ,pr_nrdconta => rw_prestamista.nrdconta
                                            ,pr_nrctrseg => rw_prestamista.nrctrseg) LOOP

                  vr_linha := 'INSERT INTO CECRED.crawseg(dtmvtolt,
                                                  nrdconta,
                                                  nrctrseg,
                                                  tpseguro,
                                                  nmdsegur,
                                                  tpplaseg,
                                                  nmbenefi,
                                                  nrcadast,
                                                  nmdsecao,
                                                  dsendres,
                                                  nrendres,
                                                  nmbairro,
                                                  nmcidade,
                                                  cdufresd,
                                                  nrcepend,
                                                  dtinivig,
                                                  dtfimvig,
                                                  dsmarvei,
                                                  dstipvei,
                                                  nranovei,
                                                  nrmodvei,
                                                  qtpasvei,
                                                  ppdbonus,
                                                  flgdnovo,
                                                  nrapoant,
                                                  nmsegant,
                                                  flgdutil,
                                                  flgnotaf,
                                                  flgapant,
                                                  vlpreseg,
                                                  vlseguro,
                                                  vldfranq,
                                                  vldcasco,
                                                  vlverbae,
                                                  flgassis,
                                                  vldanmat,
                                                  vldanpes,
                                                  vldanmor,
                                                  vlappmor,
                                                  vlappinv,
                                                  cdsegura,
                                                  nmempres,
                                                  dschassi,
                                                  flgrenov,
                                                  dtdebito,
                                                  vlbenefi,
                                                  cdcalcul,
                                                  flgcurso,
                                                  dtiniseg,
                                                  nrdplaca,
                                                  lsctrant,
                                                  nrcpfcgc,
                                                  nrctratu,
                                                  nmcpveic,
                                                  flgunica,
                                                  nrctrato,
                                                  flgvisto,
                                                  cdapoant,
                                                  dtprideb,
                                                  vldifseg,
                                                  dscobext##1,
                                                  dscobext##2,
                                                  dscobext##3,
                                                  dscobext##4,
                                                  dscobext##5,
                                                  vlcobext##1,
                                                  vlcobext##2,
                                                  vlcobext##3,
                                                  vlcobext##4,
                                                  vlcobext##5,
                                                  flgrepgr,
                                                  vlfrqobr,
                                                  tpsegvid,
                                                  dtnascsg,
                                                  cdsexosg,
                                                  vlpremio,
                                                  qtparcel,
                                                  nrfonemp,
                                                  nrfonres,
                                                  dsoutgar,
                                                  vloutgar,
                                                  tpdpagto,
                                                  cdcooper,
                                                  flgconve,
                                                  complend,
                                                  progress_recid,
                                                  nrproposta,
                                                  flggarad,
                                                  flgassum,
                                                  tpcustei,
                                                  tpmodali,
                                                  flfinanciasegprestamista,
                                                  flgsegma) 
                       VALUES     (   TO_DATE(''' || rw_crawseg.dtmvtolt         || ''',''DD/MM/RRRR''),'
                                      || '''' || rw_crawseg.nrdconta                 || ''','
                                      || '''' || rw_crawseg.nrctrseg                 || ''','
                                      || '''' || rw_crawseg.tpseguro                 || ''','
                                      || '''' || rw_crawseg.nmdsegur                 || ''','
                                      || '''' || rw_crawseg.tpplaseg                 || ''','
                                      || '''' || rw_crawseg.nmbenefi                 || ''','
                                      || '''' || rw_crawseg.nrcadast                 || ''','
                                      || '''' || rw_crawseg.nmdsecao                 || ''','
                                      || '''' || rw_crawseg.dsendres                 || ''','
                                      || '''' || rw_crawseg.nrendres                 || ''','
                                      || '''' || rw_crawseg.nmbairro                 || ''','
                                      || '''' || rw_crawseg.nmcidade                 || ''','
                                      || '''' || rw_crawseg.cdufresd                 || ''','
                                      || '''' || rw_crawseg.nrcepend                 || ''','
                                      || 'TO_DATE(''' || rw_crawseg.dtinivig         || ''',''DD/MM/RRRR''),'
                                      || 'TO_DATE(''' || rw_crawseg.dtfimvig         || ''',''DD/MM/RRRR''),'
                                      || '''' || rw_crawseg.dsmarvei                 || ''','
                                      || '''' || rw_crawseg.dstipvei                 || ''','
                                      || '''' || rw_crawseg.nranovei                 || ''','
                                      || '''' || rw_crawseg.nrmodvei                 || ''','
                                      || '''' || rw_crawseg.qtpasvei                 || ''','
                                      || '''' || rw_crawseg.ppdbonus                 || ''','
                                      || '''' || rw_crawseg.flgdnovo                 || ''','
                                      || '''' || rw_crawseg.nrapoant                 || ''','
                                      || '''' || rw_crawseg.nmsegant                 || ''','
                                      || '''' || rw_crawseg.flgdutil                 || ''','
                                      || '''' || rw_crawseg.flgnotaf                 || ''','
                                      || '''' || rw_crawseg.flgapant                 || ''','
                                      || '''' || rw_crawseg.vlpreseg                 || ''','
                                      || '''' || rw_crawseg.vlseguro                 || ''','
                                      || '''' || rw_crawseg.vldfranq                 || ''','
                                      || '''' || rw_crawseg.vldcasco                 || ''','
                                      || '''' || rw_crawseg.vlverbae                 || ''','
                                      || '''' || rw_crawseg.flgassis                 || ''','
                                      || '''' || rw_crawseg.vldanmat                 || ''','
                                      || '''' || rw_crawseg.vldanpes                 || ''','
                                      || '''' || rw_crawseg.vldanmor                 || ''','
                                      || '''' || rw_crawseg.vlappmor                 || ''','
                                      || '''' || rw_crawseg.vlappinv                 || ''','
                                      || '''' || rw_crawseg.cdsegura                 || ''','
                                      || '''' || rw_crawseg.nmempres                 || ''','
                                      || '''' || rw_crawseg.dschassi                 || ''','
                                      || '''' || rw_crawseg.flgrenov                 || ''','
                                      || 'TO_DATE(''' || rw_crawseg.dtdebito         || ''',''DD/MM/RRRR''),'
                                      || '''' || rw_crawseg.vlbenefi                 || ''','
                                      || '''' || rw_crawseg.cdcalcul                 || ''','
                                      || '''' || rw_crawseg.flgcurso                 || ''','
                                      || 'TO_DATE(''' || rw_crawseg.dtiniseg         || ''',''DD/MM/RRRR''),'
                                      || '''' || rw_crawseg.nrdplaca                 || ''','
                                      || '''' || rw_crawseg.lsctrant                 || ''','
                                      || '''' || rw_crawseg.nrcpfcgc                 || ''','
                                      || '''' || rw_crawseg.nrctratu                 || ''','
                                      || '''' || rw_crawseg.nmcpveic                 || ''','
                                      || '''' || rw_crawseg.flgunica                 || ''','
                                      || '''' || rw_crawseg.nrctrato                 || ''','
                                      || '''' || rw_crawseg.flgvisto                 || ''','
                                      || '''' || rw_crawseg.cdapoant                 || ''','
                                      || 'TO_DATE(''' || rw_crawseg.dtprideb         || ''',''DD/MM/RRRR''),'
                                      || '''' || rw_crawseg.vldifseg                 || ''','
                                      || '''' || rw_crawseg.dscobext##1              || ''','
                                      || '''' || rw_crawseg.dscobext##2              || ''','
                                      || '''' || rw_crawseg.dscobext##3              || ''','
                                      || '''' || rw_crawseg.dscobext##4              || ''','
                                      || '''' || rw_crawseg.dscobext##5              || ''','
                                      || '''' || rw_crawseg.vlcobext##1              || ''','
                                      || '''' || rw_crawseg.vlcobext##2              || ''','
                                      || '''' || rw_crawseg.vlcobext##3              || ''','
                                      || '''' || rw_crawseg.vlcobext##4              || ''','
                                      || '''' || rw_crawseg.vlcobext##5              || ''','
                                      || '''' || rw_crawseg.flgrepgr                 || ''','
                                      || '''' || rw_crawseg.vlfrqobr                 || ''','
                                      || '''' || rw_crawseg.tpsegvid                 || ''','
                                      || 'TO_DATE(''' || rw_crawseg.dtnascsg         || ''',''DD/MM/RRRR''),'
                                      || '''' || rw_crawseg.cdsexosg                 || ''','
                                      || '''' || rw_crawseg.vlpremio                 || ''','
                                      || '''' || rw_crawseg.qtparcel                 || ''','
                                      || '''' || rw_crawseg.nrfonemp                 || ''','
                                      || '''' || rw_crawseg.nrfonres                 || ''','
                                      || '''' || rw_crawseg.dsoutgar                 || ''','
                                      || '''' || rw_crawseg.vloutgar                 || ''','
                                      || '''' || rw_crawseg.tpdpagto                 || ''','
                                      || '''' || rw_crawseg.cdcooper                 || ''','
                                      || '''' || rw_crawseg.flgconve                 || ''','
                                      || '''' || rw_crawseg.complend                 || ''','
                                      || '''' || rw_crawseg.progress_recid           || ''','
                                      || '''' || rw_crawseg.nrproposta               || ''','
                                      || '''' || rw_crawseg.flggarad                 || ''','
                                      || '''' || rw_crawseg.flgassum                 || ''','
                                      || '''' || rw_crawseg.tpcustei                 || ''','
                                      || '''' || rw_crawseg.tpmodali                 || ''','
                                      || '''' || rw_crawseg.flfinanciasegprestamista || ''','
                                      || '''' || rw_crawseg.flgsegma                 || ''');';

                  CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

                  DELETE CECRED.crawseg p
                   WHERE p.progress_recid = rw_crawseg.progress_recid;
                END LOOP;
              END IF;
            END IF;

            IF vcount = 1000 THEN
                COMMIT;
            ELSE
                vcount := vcount + 1;
            END IF;
          END LOOP;
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
END;
/
