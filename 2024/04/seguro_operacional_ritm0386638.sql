DECLARE
  vr_ind_arq        utl_file.file_type;
  vr_linha          VARCHAR2(32767);
  vr_dscritic       VARCHAR2(2000);
  vr_nmdir          VARCHAR2(4000) := CECRED.gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/RITM0386638';
  vr_nmarq          VARCHAR2(100)  := 'ROLLBACK_RITM0386638.sql';
  vr_exc_saida      EXCEPTION;
  vr_nrdconta       CECRED.tbseg_prestamista.nrdconta%TYPE := 0;
  vr_nrctremp       CECRED.tbseg_prestamista.nrctremp%TYPE := 0;
  vr_nrctrseg       CECRED.tbseg_prestamista.nrctrseg%TYPE := 0;

  CURSOR cr_crapcop IS
    SELECT c.cdcooper
          ,d.dtmvtolt
      FROM CECRED.crapcop c,
           CECRED.crapdat d
     WHERE c.flgativo = 1
       AND c.cdcooper <> 3
       AND c.cdcooper = d.cdcooper;

  CURSOR cr_principal(pr_cdcooper CECRED.crapseg.cdcooper%TYPE) IS
    SELECT p.cdcooper,
           p.nrdconta,
           p.nrproposta,
           p.nrctrseg,
           p.nrctremp,
           p.idseqtra,
           s.progress_recid crapseg_progress_recid,
           w.progress_recid crawseg_progress_recid
      FROM CECRED.crawseg w,
           CECRED.tbseg_prestamista p,
           CECRED.crapseg s
     WHERE p.cdcooper = s.cdcooper      
       AND p.nrdconta = s.nrdconta      
       AND p.nrctrseg = s.nrctrseg 
       AND p.cdcooper = w.cdcooper      
       AND p.nrdconta = w.nrdconta      
       AND p.nrctrseg = w.nrctrseg     
       AND s.cdsitseg = 1      
       AND p.tpcustei = 1      
       AND (SELECT COUNT(*)        
              FROM tbseg_prestamista p1        
             WHERE p1.cdcooper = p.cdcooper              
               AND p1.nrdconta = p.nrdconta              
               AND p1.nrctremp = p.nrctremp              
               AND p1.tpcustei = p.tpcustei              
               AND p1.tpregist = p.tpregist              
               AND p1.tpregist = 1) > 1
     ORDER BY p.cdcooper, p.nrctremp, p.nrctrseg;

  CURSOR cr_prestamista(pr_idseqtra IN tbseg_prestamista.idseqtra%TYPE) IS
    SELECT *
      FROM CECRED.tbseg_prestamista s
     WHERE s.idseqtra = pr_idseqtra;

  CURSOR cr_crapseg(pr_progress_recid IN crapseg.progress_recid%TYPE) IS
    SELECT *
      FROM CECRED.crapseg s
     WHERE s.progress_recid = pr_progress_recid;

  CURSOR cr_crawseg(pr_progress_recid IN crawseg.progress_recid%TYPE) IS
    SELECT *
      FROM CECRED.crawseg s
     WHERE s.progress_recid = pr_progress_recid;

  PROCEDURE pc_valida_direto(pr_nmdireto IN  VARCHAR2,
                             pr_dscritic OUT CECRED.crapcri.dscritic%TYPE) IS
    vr_dscritic  CECRED.crapcri.dscritic%TYPE;
    vr_typ_saida VARCHAR2(3);
    vr_des_saida VARCHAR2(1000);
    vr_exc_erro  EXCEPTION;
    BEGIN
      IF NOT CECRED.gene0001.fn_exis_diretorio(pr_nmdireto) THEN

        CECRED.gene0001.pc_OSCommand_Shell(pr_des_comando => 'mkdir ' ||
                                                             pr_nmdireto ||
                                                             ' 1> /dev/null',
                                    pr_typ_saida   => vr_typ_saida,
                                    pr_des_saida   => vr_des_saida);

        IF vr_typ_saida = 'ERR' THEN
          vr_dscritic := 'CRIAR DIRETORIO ARQUIVO -> Nao foi possivel criar o diretorio para gerar os arquivos. ' ||
                         vr_des_saida;
          RAISE vr_exc_erro;
        END IF;

        CECRED.gene0001.pc_OSCommand_Shell(pr_des_comando => 'chmod 777 ' ||
                                                             pr_nmdireto ||
                                                             ' 1> /dev/null',
                                    pr_typ_saida   => vr_typ_saida,
                                    pr_des_saida   => vr_des_saida);

        IF vr_typ_saida = 'ERR' THEN
          vr_dscritic := 'PERMISSAO NO DIRETORIO -> Nao foi possivel adicionar permissao no diretorio dos arquivos. ' ||
                         vr_des_saida;
          RAISE vr_exc_erro;
        END IF;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
    END;

  BEGIN

      pc_valida_direto(pr_nmdireto => vr_nmdir,
                       pr_dscritic => vr_dscritic);

      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      CECRED.GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdir
                                     ,pr_nmarquiv => vr_nmarq
                                     ,pr_tipabert => 'W'
                                     ,pr_utlfileh => vr_ind_arq
                                     ,pr_des_erro => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
         vr_dscritic := vr_dscritic ||'  N�o pode abrir arquivo '|| vr_nmdir || vr_nmarq;
         RAISE vr_exc_saida;
      END IF;

      CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'BEGIN');
      
      FOR rw_crapcop IN cr_crapcop LOOP        
        vr_linha := '';

        FOR rw_principal IN cr_principal(pr_cdcooper => rw_crapcop.cdcooper) LOOP
          IF vr_nrdconta <> rw_principal.nrdconta THEN
             vr_nrdconta := rw_principal.nrdconta;
             vr_nrctremp := rw_principal.nrctremp;
             vr_nrctrseg := rw_principal.nrctrseg;
             CONTINUE;
          ELSIF vr_nrctremp <> rw_principal.nrctremp THEN
             vr_nrctremp := rw_principal.nrctremp;
             vr_nrctrseg := rw_principal.nrctrseg;
             CONTINUE;
          ELSIF vr_nrctrseg < rw_principal.nrctrseg THEN          
          
            FOR rw_prestamista IN cr_prestamista(pr_idseqtra => rw_principal.idseqtra) LOOP
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
                                                                flfinanciasegprestamista,
                                                                flcancelado_mobile)
                          VALUES( '''|| rw_prestamista.idseqtra                                   ||''',' ||
                                 ''''|| rw_prestamista.cdcooper                                   ||''',' ||
                                 ''''|| rw_prestamista.nrdconta                                   ||''',' ||
                                 ''''|| rw_prestamista.nrctrseg                                   ||''',' ||
                                 ''''|| rw_prestamista.nrctremp                                   ||''',' ||
                                 ''''|| rw_prestamista.tpregist                                   ||''',' ||
                                 ''''|| rw_prestamista.cdapolic                                   ||''',' ||
                                 ''''|| rw_prestamista.nrcpfcgc                                   ||''',' ||
                                 ''''|| rw_prestamista.nmprimtl                                   ||''',' ||
                                 'TO_DATE(''' || rw_prestamista.dtnasctl || ''',''DD/MM/RRRR''),' ||
                                 ''''|| rw_prestamista.cdsexotl                                   ||''',' ||
                                 ''''|| rw_prestamista.dsendres                                   ||''',' ||
                                 ''''|| rw_prestamista.dsdemail                                   ||''',' ||
                                 ''''|| rw_prestamista.nmbairro                                   ||''',' ||
                                 ''''|| rw_prestamista.nmcidade                                   ||''',' ||
                                 ''''|| rw_prestamista.cdufresd                                   ||''',' ||
                                 ''''|| rw_prestamista.nrcepend                                   ||''',' ||
                                 ''''|| rw_prestamista.nrtelefo                                   ||''',' ||
                                 'TO_DATE(''' || rw_prestamista.dtdevend || ''',''DD/MM/RRRR''),' ||
                                 'TO_DATE(''' || rw_prestamista.dtinivig || ''',''DD/MM/RRRR''),' ||
                                 ''''|| rw_prestamista.cdcobran                                   ||''',' ||
                                 ''''|| rw_prestamista.cdadmcob                                   ||''',' ||
                                 ''''|| rw_prestamista.tpfrecob                                   ||''',' ||
                                 ''''|| rw_prestamista.tpsegura                                   ||''',' ||
                                 ''''|| rw_prestamista.cdprodut                                   ||''',' ||
                                 ''''|| rw_prestamista.cdplapro                                   ||''',' ||
                                 ''''|| rw_prestamista.vlprodut                                   ||''',' ||
                                 ''''|| rw_prestamista.tpcobran                                   ||''',' ||
                                 ''''|| rw_prestamista.vlsdeved                                   ||''',' ||
                                 ''''|| rw_prestamista.vldevatu                                   ||''',' ||
                                 'TO_DATE(''' || rw_prestamista.dtrefcob || ''',''DD/MM/RRRR''),' ||
                                 'TO_DATE(''' || rw_prestamista.dtfimvig || ''',''DD/MM/RRRR''),' ||
                                 'TO_DATE(''' || rw_prestamista.dtdenvio || ''',''DD/MM/RRRR''),' ||
                                 ''''|| rw_prestamista.nrproposta                                 ||''',' ||
                                 ''''|| rw_prestamista.tprecusa                                   ||''',' ||
                                 ''''|| rw_prestamista.cdmotrec                                   ||''',' ||
                                 'TO_DATE(''' || rw_prestamista.dtrecusa || ''',''DD/MM/RRRR''),' ||
                                 ''''|| rw_prestamista.situacao                                   ||''',' ||
                                 ''''|| rw_prestamista.tpcustei                                   ||''',' ||
                                 ''''|| rw_prestamista.pemorte                                    ||''',' ||
                                 ''''|| rw_prestamista.peinvalidez                                ||''',' ||
                                 ''''|| rw_prestamista.peiftttaxa                                 ||''',' ||
                                 ''''|| rw_prestamista.qtifttdias                                 ||''',' ||
                                 ''''|| rw_prestamista.nrapolice                                  ||''',' ||
                                 ''''|| rw_prestamista.qtparcel                                   ||''',' ||
                                 ''''|| rw_prestamista.vlpielimit                                 ||''',' ||
                                 ''''|| rw_prestamista.vlifttlimi                                 ||''',' ||
                                 ''''|| rw_prestamista.dsprotocolo                                ||''',' ||
                                 ''''|| rw_prestamista.flfinanciasegprestamista                   ||''',' ||
                                 ''''|| rw_prestamista.flcancelado_mobile                         ||''');';

              CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

              DELETE CECRED.tbseg_prestamista p
               WHERE p.idseqtra = rw_prestamista.idseqtra;
            END LOOP;

            FOR rw_crapseg IN cr_crapseg(pr_progress_recid => rw_principal.crapseg_progress_recid) LOOP
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
                VALUES( ''' || rw_crapseg.nrdconta                                  ||''',' ||
                       '''' || rw_crapseg.nrctrseg                                  ||''',' ||
                       'TO_DATE(''' || rw_crapseg.dtinivig || ''',''DD/MM/RRRR''),' ||
                       'TO_DATE(''' || rw_crapseg.dtfimvig || ''',''DD/MM/RRRR''),' ||
                       'TO_DATE(''' || rw_crapseg.dtmvtolt || ''',''DD/MM/RRRR''),' ||
                       '''' || rw_crapseg.cdagenci                                  ||''',' ||
                       '''' || rw_crapseg.cdbccxlt                                  ||''',' ||
                       '''' || rw_crapseg.cdsitseg                                  ||''',' ||
                       'TO_DATE(''' || rw_crapseg.dtaltseg || ''',''DD/MM/RRRR''),' ||
                       'TO_DATE(''' || rw_crapseg.dtcancel || ''',''DD/MM/RRRR''),' ||
                       'TO_DATE(''' || rw_crapseg.dtdebito || ''',''DD/MM/RRRR''),' ||
                       'TO_DATE(''' || rw_crapseg.dtiniseg || ''',''DD/MM/RRRR''),' ||
                       '''' || rw_crapseg.indebito                                  ||''',' ||
                       '''' || rw_crapseg.nrdolote                                  ||''',' ||
                       '''' || rw_crapseg.nrseqdig                                  ||''',' ||
                       '''' || rw_crapseg.qtprepag                                  ||''',' ||
                       '''' || rw_crapseg.vlprepag                                  ||''',' ||
                       '''' || rw_crapseg.vlpreseg                                  ||''',' ||
                       'TO_DATE(''' || rw_crapseg.dtultpag || ''',''DD/MM/RRRR''),' ||
                       '''' || rw_crapseg.tpseguro                                  ||''',' ||
                       '''' || rw_crapseg.tpplaseg                                  ||''',' ||
                       '''' || rw_crapseg.qtprevig                                  ||''',' ||
                       '''' || rw_crapseg.cdsegura                                  ||''',' ||
                       '''' || rw_crapseg.lsctrant                                  ||''',' ||
                       '''' || rw_crapseg.nrctratu                                  ||''',' ||
                       '''' || rw_crapseg.flgunica                                  ||''',' ||
                       'TO_DATE(''' || rw_crapseg.dtprideb || ''',''DD/MM/RRRR''),' ||
                       '''' || rw_crapseg.vldifseg                                  ||''',' ||
                       '''' || rw_crapseg.nmbenvid##1                               ||''',' ||
                       '''' || rw_crapseg.nmbenvid##2                               ||''',' ||
                       '''' || rw_crapseg.nmbenvid##3                               ||''',' ||
                       '''' || rw_crapseg.nmbenvid##4                               ||''',' ||
                       '''' || rw_crapseg.nmbenvid##5                               ||''',' ||
                       '''' || rw_crapseg.dsgraupr##1                               ||''',' ||
                       '''' || rw_crapseg.dsgraupr##2                               ||''',' ||
                       '''' || rw_crapseg.dsgraupr##3                               ||''',' ||
                       '''' || rw_crapseg.dsgraupr##4                               ||''',' ||
                       '''' || rw_crapseg.dsgraupr##5                               ||''',' ||
                       '''' || rw_crapseg.txpartic##1                               ||''',' ||
                       '''' || rw_crapseg.txpartic##2                               ||''',' ||
                       '''' || rw_crapseg.txpartic##3                               ||''',' ||
                       '''' || rw_crapseg.txpartic##4                               ||''',' ||
                       '''' || rw_crapseg.txpartic##5                               ||''',' ||
                       'TO_DATE(''' || rw_crapseg.dtultalt || ''',''DD/MM/RRRR''),' ||
                       '''' || rw_crapseg.cdoperad                                  ||''',' ||
                       '''' || rw_crapseg.vlpremio                                  ||''',' ||
                       '''' || rw_crapseg.qtparcel                                  ||''',' ||
                       '''' || rw_crapseg.tpdpagto                                  ||''',' ||
                       '''' || rw_crapseg.cdcooper                                  ||''',' ||
                       '''' || rw_crapseg.flgconve                                  ||''',' ||
                       '''' || rw_crapseg.flgclabe                                  ||''',' ||
                       '''' || rw_crapseg.cdmotcan                                  ||''',' ||
                       '''' || rw_crapseg.tpendcor                                  ||''',' ||
                       '''' || rw_crapseg.progress_recid                            ||''',' ||
                       '''' || rw_crapseg.cdopecnl                                  ||''',' ||
                       'TO_DATE(''' || rw_crapseg.dtrenova || ''',''DD/MM/RRRR''),' ||
                       '''' || rw_crapseg.cdopeori                                  ||''',' ||
                       '''' || rw_crapseg.cdageori                                  ||''',' ||
                       'TO_DATE(''' || rw_crapseg.dtinsori || ''',''DD/MM/RRRR''),' ||
                       '''' || rw_crapseg.cdopeexc                                  ||''',' ||
                       '''' || rw_crapseg.cdageexc                                  ||''',' ||
                       'TO_DATE(''' || rw_crapseg.dtinsexc || ''',''DD/MM/RRRR''),' ||
                       '''' || rw_crapseg.vlslddev                                  ||''',' ||
                       '''' || rw_crapseg.idimpdps                                  ||''');';

              CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

              DELETE CECRED.crapseg p
               WHERE p.progress_recid = rw_crapseg.progress_recid;
            END LOOP;

            FOR rw_crawseg IN cr_crawseg(pr_progress_recid => rw_principal.crawseg_progress_recid) LOOP
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
                  VALUES ( TO_DATE(''' || rw_crawseg.dtmvtolt || ''',''DD/MM/RRRR''),' ||
                          '''' || rw_crawseg.nrdconta                         || ''',' ||
                          '''' || rw_crawseg.nrctrseg                         || ''',' ||
                          '''' || rw_crawseg.tpseguro                         || ''',' ||
                          '''' || rw_crawseg.nmdsegur                         || ''',' ||
                          '''' || rw_crawseg.tpplaseg                         || ''',' ||
                          '''' || rw_crawseg.nmbenefi                         || ''',' ||
                          '''' || rw_crawseg.nrcadast                         || ''',' ||
                          '''' || rw_crawseg.nmdsecao                         || ''',' ||
                          '''' || rw_crawseg.dsendres                         || ''',' ||
                          '''' || rw_crawseg.nrendres                         || ''',' ||
                          '''' || rw_crawseg.nmbairro                         || ''',' ||
                          '''' || rw_crawseg.nmcidade                         || ''',' ||
                          '''' || rw_crawseg.cdufresd                         || ''',' ||
                          '''' || rw_crawseg.nrcepend                         || ''',' ||
                          'TO_DATE(''' || rw_crawseg.dtinivig || ''',''DD/MM/RRRR''),' ||
                          'TO_DATE(''' || rw_crawseg.dtfimvig || ''',''DD/MM/RRRR''),' ||
                          '''' || rw_crawseg.dsmarvei                         || ''',' ||
                          '''' || rw_crawseg.dstipvei                         || ''',' ||
                          '''' || rw_crawseg.nranovei                         || ''',' ||
                          '''' || rw_crawseg.nrmodvei                         || ''',' ||
                          '''' || rw_crawseg.qtpasvei                         || ''',' ||
                          '''' || rw_crawseg.ppdbonus                         || ''',' ||
                          '''' || rw_crawseg.flgdnovo                         || ''',' ||
                          '''' || rw_crawseg.nrapoant                         || ''',' ||
                          '''' || rw_crawseg.nmsegant                         || ''',' ||
                          '''' || rw_crawseg.flgdutil                         || ''',' ||
                          '''' || rw_crawseg.flgnotaf                         || ''',' ||
                          '''' || rw_crawseg.flgapant                         || ''',' ||
                          '''' || rw_crawseg.vlpreseg                         || ''',' ||
                          '''' || rw_crawseg.vlseguro                         || ''',' ||
                          '''' || rw_crawseg.vldfranq                         || ''',' ||
                          '''' || rw_crawseg.vldcasco                         || ''',' ||
                          '''' || rw_crawseg.vlverbae                         || ''',' ||
                          '''' || rw_crawseg.flgassis                         || ''',' ||
                          '''' || rw_crawseg.vldanmat                         || ''',' ||
                          '''' || rw_crawseg.vldanpes                         || ''',' ||
                          '''' || rw_crawseg.vldanmor                         || ''',' ||
                          '''' || rw_crawseg.vlappmor                         || ''',' ||
                          '''' || rw_crawseg.vlappinv                         || ''',' ||
                          '''' || rw_crawseg.cdsegura                         || ''',' ||
                          '''' || rw_crawseg.nmempres                         || ''',' ||
                          '''' || rw_crawseg.dschassi                         || ''',' ||
                          '''' || rw_crawseg.flgrenov                         || ''',' ||
                          'TO_DATE(''' || rw_crawseg.dtdebito || ''',''DD/MM/RRRR''),' ||
                          '''' || rw_crawseg.vlbenefi                         || ''',' ||
                          '''' || rw_crawseg.cdcalcul                         || ''',' ||
                          '''' || rw_crawseg.flgcurso                         || ''',' ||
                          'TO_DATE(''' || rw_crawseg.dtiniseg || ''',''DD/MM/RRRR''),' ||
                          '''' || rw_crawseg.nrdplaca                         || ''',' ||
                          '''' || rw_crawseg.lsctrant                         || ''',' ||
                          '''' || rw_crawseg.nrcpfcgc                         || ''',' ||
                          '''' || rw_crawseg.nrctratu                         || ''',' ||
                          '''' || rw_crawseg.nmcpveic                         || ''',' ||
                          '''' || rw_crawseg.flgunica                         || ''',' ||
                          '''' || rw_crawseg.nrctrato                         || ''',' ||
                          '''' || rw_crawseg.flgvisto                         || ''',' ||
                          '''' || rw_crawseg.cdapoant                         || ''',' ||
                          'TO_DATE(''' || rw_crawseg.dtprideb || ''',''DD/MM/RRRR''),' ||
                          '''' || rw_crawseg.vldifseg                         || ''',' ||
                          '''' || rw_crawseg.dscobext##1                      || ''',' ||
                          '''' || rw_crawseg.dscobext##2                      || ''',' ||
                          '''' || rw_crawseg.dscobext##3                      || ''',' ||
                          '''' || rw_crawseg.dscobext##4                      || ''',' ||
                          '''' || rw_crawseg.dscobext##5                      || ''',' ||
                          '''' || rw_crawseg.vlcobext##1                      || ''',' ||
                          '''' || rw_crawseg.vlcobext##2                      || ''',' ||
                          '''' || rw_crawseg.vlcobext##3                      || ''',' ||
                          '''' || rw_crawseg.vlcobext##4                      || ''',' ||
                          '''' || rw_crawseg.vlcobext##5                      || ''',' ||
                          '''' || rw_crawseg.flgrepgr                         || ''',' ||
                          '''' || rw_crawseg.vlfrqobr                         || ''',' ||
                          '''' || rw_crawseg.tpsegvid                         || ''',' ||
                          'TO_DATE(''' || rw_crawseg.dtnascsg || ''',''DD/MM/RRRR''),' ||
                          '''' || rw_crawseg.cdsexosg                         || ''',' ||
                          '''' || rw_crawseg.vlpremio                         || ''',' ||
                          '''' || rw_crawseg.qtparcel                         || ''',' ||
                          '''' || rw_crawseg.nrfonemp                         || ''',' ||
                          '''' || rw_crawseg.nrfonres                         || ''',' ||
                          '''' || rw_crawseg.dsoutgar                         || ''',' ||
                          '''' || rw_crawseg.vloutgar                         || ''',' ||
                          '''' || rw_crawseg.tpdpagto                         || ''',' ||
                          '''' || rw_crawseg.cdcooper                         || ''',' ||
                          '''' || rw_crawseg.flgconve                         || ''',' ||
                          '''' || rw_crawseg.complend                         || ''',' ||
                          '''' || rw_crawseg.progress_recid                   || ''',' ||
                          '''' || rw_crawseg.nrproposta                       || ''',' ||
                          '''' || rw_crawseg.flggarad                         || ''',' ||
                          '''' || rw_crawseg.flgassum                         || ''',' ||
                          '''' || rw_crawseg.tpcustei                         || ''',' ||
                          '''' || rw_crawseg.tpmodali                         || ''',' ||
                          '''' || rw_crawseg.flfinanciasegprestamista         || ''',' ||
                          '''' || rw_crawseg.flgsegma                         ||''');';

                CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

                vr_linha := 'UPDATE CECRED.crawseg SET nrproposta = ''' || rw_crawseg.nrproposta || ''' WHERE progress_recid = ' || rw_crawseg.progress_recid || ';';

                CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

                DELETE CECRED.crawseg w
                 WHERE w.progress_recid = rw_crawseg.progress_recid;

              END LOOP;            

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
