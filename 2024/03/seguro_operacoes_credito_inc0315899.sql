DECLARE
  vr_ind_arq        utl_file.file_type;
  vr_linha          VARCHAR2(32767);
  vr_dscritic       VARCHAR2(2000);
  vr_nmdir          VARCHAR2(4000) := CECRED.gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/INC0315899';
  vr_nmarq          VARCHAR2(100)  := 'ROLLBACK_INC0315899.sql';
  vr_exc_saida      EXCEPTION;

  CURSOR cr_crapcop IS
    SELECT c.cdcooper
          ,d.dtmvtolt
      FROM CECRED.crapcop c,
           CECRED.crapdat d
     WHERE c.flgativo = 1
       AND c.cdcooper <> 3
       AND c.cdcooper = d.cdcooper;

  CURSOR cr_crawseg(pr_cdcooper CECRED.crapseg.cdcooper%TYPE) IS
    SELECT w.*
      FROM crawseg w
     WHERE w.cdcooper = pr_cdcooper
       AND w.tpcustei = 1 
       AND w.vlpremio = 0
       AND w.vlseguro = 0   
       AND w.tpseguro = 4
       AND (SELECT e.inliquid
              FROM crapepr e
             WHERE e.cdcooper = w.cdcooper
               AND e.nrdconta = w.nrdconta
               AND e.nrctremp = w.nrctrato) = 0
       AND NOT EXISTS (SELECT 'X'
                         FROM crapseg p
                        WHERE w.cdcooper = p.cdcooper
                          AND w.nrdconta = p.nrdconta
                          AND w.nrctrseg = p.nrctrseg)
       AND NOT EXISTS (SELECT 'X'
                         FROM tbseg_prestamista p
                        WHERE w.cdcooper = p.cdcooper
                          AND w.nrdconta = p.nrdconta
                          AND w.nrctrseg = p.nrctrseg);

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
         vr_dscritic := vr_dscritic ||'  Não pode abrir arquivo '|| vr_nmdir || vr_nmarq;
         RAISE vr_exc_saida;
      END IF;

      CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'BEGIN');

      FOR rw_crapcop IN cr_crapcop LOOP
        vr_linha := '';

        FOR rw_crawseg IN cr_crawseg(pr_cdcooper => rw_crapcop.cdcooper) LOOP
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
