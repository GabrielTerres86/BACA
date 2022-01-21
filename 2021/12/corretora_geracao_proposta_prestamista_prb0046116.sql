DECLARE
  vr_nmarqbkp       VARCHAR2(100);
  vr_nmdireto       VARCHAR2(4000);
  vr_rootmicros     VARCHAR2(5000);
  vr_cdcritic       NUMBER;
  vr_dscritic       crapcri.dscritic%TYPE;
  vr_exc_erro       EXCEPTION;
  vr_ind_arquiv     utl_file.file_type;
  vr_qntd_reg       NUMBER;
---------------------------------------------------------
-- Realizar por cooperativas ativas
  CURSOR cr_crapop IS
    SELECT cop.cdcooper
      FROM crapcop cop
     WHERE cop.flgativo = 1
       AND cop.cdcooper <> 3;
---------------------------------------------------------
-- Criar crawseg e crapseg de seguro prestamista ativo
  CURSOR cr_registros1(pr_cdcooper IN tbseg_prestamista.cdcooper%TYPE) IS
    SELECT p.nrdconta
          ,p.nrctremp
          ,p.nrctrseg
          ,s.cdagenci
      FROM crapass s
          ,tbseg_prestamista p
     WHERE p.cdcooper = pr_cdcooper
       AND p.cdcooper = s.cdcooper
       AND p.nrdconta = s.nrdconta
       AND p.tpregist = 3
       AND NOT EXISTS (SELECT 'X'
                        FROM crawseg w, crapseg s
                       WHERE w.cdcooper = p.cdcooper
                         AND w.nrdconta = p.nrdconta
                         AND w.nrctrseg = p.nrctrseg
                         AND w.nrctrato = p.nrctremp
                         AND w.cdcooper = s.cdcooper
                         AND w.nrdconta = s.nrdconta
                         AND w.nrctrseg = s.nrctrseg
                         AND w.tpseguro = 4);
  rw_registro1 cr_registros1%ROWTYPE;
  
  CURSOR cr_nrctrseg(pr_cdcooper crawseg.cdcooper%TYPE,
                     pr_nrdconta crawseg.nrdconta%TYPE,
                     pr_nrctrato crawseg.nrctrato%TYPE) IS
    SELECT w.nrctrseg
      FROM crawseg w
     WHERE w.cdcooper = pr_cdcooper
       AND w.nrdconta = pr_nrdconta
       AND w.nrctrato = pr_nrctrato;
    rw_nrctrseg cr_nrctrseg%ROWTYPE;
---------------------------------------------------------
-- Registros que estão na crapseg e não estão na tbseg_prestamista
  CURSOR cr_registros2(pr_cdcooper IN tbseg_prestamista.cdcooper%TYPE) IS
    SELECT p.*
      FROM crapseg p
      LEFT JOIN tbseg_prestamista s
           ON p.nrdconta = s.nrdconta
       AND p.cdcooper = s.cdcooper
       AND p.nrctrseg = s.nrctrseg
     WHERE p.cdcooper = pr_cdcooper
       AND s.idseqtra is null
       AND p.tpseguro = 4
       AND p.cdsitseg = 1;
     rw_registro2 cr_registros2%ROWTYPE;
---------------------------------------------------------
-- Verifica se possui na crawseg
  CURSOR cr_registros3(pr_cdcooper crawseg.cdcooper%TYPE,
                       pr_nrdconta crawseg.nrdconta%TYPE,
                       pr_nrctrseg crawseg.nrctrseg%TYPE) IS
     SELECT *
       FROM crawseg w
      WHERE w.cdcooper = pr_cdcooper
        AND w.nrdconta = pr_nrdconta
        AND w.nrctrseg = pr_nrctrseg;
      rw_registro3 cr_registros3%ROWTYPE;
---------------------------------------------------------
-- Verifica divergencia entre tbseg_prestamista e crawseg
  CURSOR cr_registro4(pr_cdcooper tbseg_prestamista.cdcooper%TYPE) IS
    SELECT p.dtinivig,
           p.cdcooper,
           p.nrdconta,
           p.nrctrseg,
           p.nrctremp,
           p.nrproposta,
           w.nrproposta nrproposta_crawseg,
           w.progress_recid
      FROM crawseg w, tbseg_prestamista p, crapseg s
     WHERE p.cdcooper = pr_cdcooper
       AND p.cdcooper = w.cdcooper
       AND p.nrdconta = w.nrdconta
       AND p.nrctrseg = w.nrctrseg
       AND p.nrctremp = w.nrctrato
       AND w.tpseguro = 4
       AND s.cdcooper = w.cdcooper
       AND s.nrdconta = w.nrdconta
       AND s.nrctrseg = w.nrctrseg
       AND s.cdsitseg = 1
       AND p.nrproposta <> w.nrproposta
       AND p.tpregist NOT IN (0, 2);
---------------------------------------------------------
-- Busca dados crawseg
  CURSOR cr_crawseg(pr_cdcooper crawseg.cdcooper%TYPE
                   ,pr_nrdconta crawseg.nrdconta%TYPE
                   ,pr_nrctrseg crawseg.nrctrseg%TYPE
                   ,pr_nrctrato crawseg.nrctrato%TYPE) IS
    SELECT c.*
      FROM crawseg c
     WHERE c.cdcooper = pr_cdcooper
       AND c.nrdconta = pr_nrdconta
       AND c.nrctrseg <> pr_nrctrseg
       AND c.nrctrato = pr_nrctrato;
---------------------------------------------------------
-- Busca dados crapseg
  CURSOR cr_crapseg(pr_cdcooper crapseg.cdcooper%TYPE
                   ,pr_nrdconta crapseg.nrdconta%TYPE
                   ,pr_nrctrseg crapseg.nrctrseg%TYPE) IS
    SELECT c.*
      FROM crapseg c
     WHERE c.cdcooper = pr_cdcooper
       AND c.nrdconta = pr_nrdconta
       AND c.nrctrseg = pr_nrctrseg;
---------------------------------------------------------
  -- Validacao de diretorio
  PROCEDURE pc_valida_direto(pr_nmdireto IN VARCHAR2,
                             pr_dscritic OUT crapcri.dscritic%TYPE) IS
  BEGIN
    DECLARE
      vr_dscritic  crapcri.dscritic%TYPE;
      vr_typ_saida VARCHAR2(3);
      vr_des_saida VARCHAR2(1000);
    BEGIN
      -- Primeiro garantimos que o diretorio exista
      IF NOT gene0001.fn_exis_diretorio(pr_nmdireto) THEN
        -- Efetuar a criação do mesmo
        gene0001.pc_OSCommand_Shell(pr_des_comando => 'mkdir ' ||
                                                      pr_nmdireto ||
                                                      ' 1> /dev/null',
                                    pr_typ_saida   => vr_typ_saida,
                                    pr_des_saida   => vr_des_saida);
        --Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
          vr_dscritic := 'CRIAR DIRETORIO ARQUIVO --> Nao foi possivel criar o diretorio para gerar os arquivos. ' ||
                         vr_des_saida;
          RAISE vr_exc_erro;
        END IF;
        -- Adicionar permissão total na pasta
        gene0001.pc_OSCommand_Shell(pr_des_comando => 'chmod 777 ' ||
                                                      pr_nmdireto ||
                                                      ' 1> /dev/null',
                                    pr_typ_saida   => vr_typ_saida,
                                    pr_des_saida   => vr_des_saida);
        --Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
          vr_dscritic := 'PERMISSAO NO DIRETORIO --> Nao foi possivel adicionar permissao no diretorio dos arquivos. ' ||
                         vr_des_saida;
          RAISE vr_exc_erro;
        END IF;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
    END;
  END;

BEGIN
  vr_rootmicros     := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto       := vr_rootmicros|| 'cpd/bacas/PRB0046116';

  --vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'C', pr_cdcooper => 3);
  pc_valida_direto(pr_nmdireto => vr_nmdireto,
                   pr_dscritic => vr_dscritic);

  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;

  vr_nmarqbkp := 'ROLLBACK_PRB0046116' || to_char(sysdate, 'hh24miss') || '.sql';

  --Criar arquivo de Roll Back
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqbkp        --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv      --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;
  ----------------------------------------------------------------------
  FOR rw_crapop IN cr_crapop LOOP
    FOR rw_registro1 IN cr_registros1(pr_cdcooper => rw_crapop.cdcooper) LOOP
      OPEN cr_nrctrseg(pr_cdcooper => rw_crapop.cdcooper,
                       pr_nrdconta => rw_registro1.nrdconta,
                       pr_nrctrato => rw_registro1.nrctremp);
        FETCH cr_nrctrseg INTO rw_nrctrseg;
        IF cr_nrctrseg%FOUND THEN
          IF rw_nrctrseg.nrctrseg <> rw_registro1.nrctrseg THEN
            -- Gera rollback
            -- Corrige o número da apólice
            gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'UPDATE tbseg_prestamista p 
                                                             SET p.nrctrseg = ' || rw_registro1.nrctrseg ||
                                                          'WHERE p.cdcooper = ' || rw_crapop.cdcooper    ||
                                                          '  AND p.nrdconta = ' || rw_registro1.nrdconta ||
                                                          '  AND p.nrctremp = ' || rw_registro1.nrctremp || ';');
           UPDATE tbseg_prestamista p 
              SET p.nrctrseg = rw_nrctrseg.nrctrseg
            WHERE p.cdcooper = rw_crapop.cdcooper
              AND p.nrdconta = rw_registro1.nrdconta
              AND p.nrctremp = rw_registro1.nrctremp;
          END IF;
        ELSE
          -- crapseg
          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'DELETE crapseg p WHERE p.cdcooper = ' || rw_crapop.cdcooper   ||
                                                                         ' AND p.nrdconta = ' || rw_registro1.nrdconta ||
                                                                         ' AND p.nrctrseg = ' || rw_registro1.nrctrseg || ';');

          -- crawseg
          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'DELETE crawseg p WHERE p.cdcooper = ' || rw_crapop.cdcooper   ||
                                                                         ' AND p.nrdconta = ' || rw_registro1.nrdconta ||
                                                                         ' AND p.nrctrseg = ' || rw_registro1.nrctrseg ||
                                                                         ' AND p.tpseguro = 4;');
        END IF;
      CLOSE cr_nrctrseg;
      vr_qntd_reg := 0;

      -- Gera crawseg e crapseg
      SEGU0003.pc_efetiva_proposta_sp(pr_cdcooper => rw_crapop.cdcooper
                                     ,pr_nrdconta => rw_registro1.nrdconta
                                     ,pr_nrctrato => rw_registro1.nrctremp
                                     ,pr_cdagenci => rw_registro1.cdagenci
                                     ,pr_nrdcaixa => 0
                                     ,pr_cdoperad => 1
                                     ,pr_nmdatela => 'SCP_PRST'
                                     ,pr_idorigem => 7
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
      IF vr_qntd_reg = 500 THEN
        vr_qntd_reg := 0;
        COMMIT;
      ELSE
        vr_qntd_reg := vr_qntd_reg + 1;
      END IF;
    END LOOP;
    COMMIT;
    ------------------------------------------------------------------------------------------------------------------------------
    FOR rw_registro2 IN cr_registros2(pr_cdcooper => rw_crapop.cdcooper) LOOP
      vr_qntd_reg := 0;
      -- Gera rollback
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,
                'INSERT INTO crapseg (nrdconta, nrctrseg, dtinivig, dtfimvig, dtmvtolt, cdagenci, cdbccxlt, cdsitseg, dtaltseg, dtcancel, dtdebito, dtiniseg, indebito, nrdolote, nrseqdig, qtprepag, vlprepag, vlpreseg, dtultpag, tpseguro, tpplaseg, qtprevig, cdsegura, lsctrant, nrctratu, flgunica, dtprideb, vldifseg, nmbenvid##1, nmbenvid##2, nmbenvid##3, nmbenvid##4, nmbenvid##5, dsgraupr##1, dsgraupr##2, dsgraupr##3, dsgraupr##4, dsgraupr##5, txpartic##1, txpartic##2, txpartic##3, txpartic##4, txpartic##5, dtultalt, cdoperad, vlpremio, qtparcel, tpdpagto, cdcooper, flgconve, flgclabe, cdmotcan, tpendcor, progress_recid, cdopecnl, dtrenova, cdopeori, cdageori, dtinsori, cdopeexc, cdageexc, dtinsexc, vlslddev, idimpdps) VALUES(''' ||
                rw_registro2.nrdconta     || ''',''' ||--7485301,
                rw_registro2.nrctrseg     || --72948,
                 ''',TO_DATE(''' || rw_registro2.dtinivig || ''', ''DD-MM-YYYY'')' || --TO_DATE('08-01-2015', 'DD-MM-YYYY'),
                 ',TO_DATE(''' || rw_registro2.dtfimvig || ''', ''DD-MM-YYYY'')' || --TO_DATE('19-10-2016', 'DD-MM-YYYY'),
                 ',TO_DATE(''' || rw_registro2.dtmvtolt || ''', ''DD-MM-YYYY''),''' ||--TO_DATE('08-01-2015', 'DD-MM-YYYY'),
                rw_registro2.cdagenci     || ''','''  ||--35,
                rw_registro2.cdbccxlt     || ''','''  ||--0,
                rw_registro2.cdsitseg     || --2,
                ''',TO_DATE('''|| rw_registro2.dtaltseg || ''', ''DD-MM-YYYY'')' ||--TO_DATE('08-01-2015', 'DD-MM-YYYY'),
                ',TO_DATE('''  || rw_registro2.dtcancel || ''', ''DD-MM-YYYY'')' ||--TO_DATE('19-10-2016', 'DD-MM-YYYY'),
                ',TO_DATE('''  || rw_registro2.dtdebito || ''', ''DD-MM-YYYY'')' ||--TO_DATE('08-11-2016', 'DD-MM-YYYY'),
                ',TO_DATE('''  || rw_registro2.dtiniseg || ''', ''DD-MM-YYYY''),''' ||--TO_DATE('08-01-2015', 'DD-MM-YYYY'),
                rw_registro2.indebito     || ''','''  ||--1,
                rw_registro2.nrdolote     || ''','''  ||--0,
                rw_registro2.nrseqdig     || ''','''  ||--72948,
                rw_registro2.qtprepag     || ''','''  ||--22,
                rw_registro2.vlprepag     || ''','''  ||--91.16,
                rw_registro2.vlpreseg     || --5.36,
                ''',TO_DATE('''|| rw_registro2.dtultpag || ''', ''DD-MM-YYYY''),''' ||--TO_DATE('10-10-2016', 'DD-MM-YYYY'),
                rw_registro2.tpseguro     || ''','''  ||--3,
                rw_registro2.tpplaseg     || ''','''  ||--11,
                rw_registro2.qtprevig     || ''','''  ||--22,
                rw_registro2.cdsegura     || ''','''  ||--5011,
                rw_registro2.lsctrant     || ''','''  ||--' ',
                rw_registro2.nrctratu     || ''','''  ||--0,
                rw_registro2.flgunica     || ''','''  ||--0,
                rw_registro2.dtprideb       || ''','''  ||--null,
                rw_registro2.vldifseg       || ''','''  ||--0.00,
                rw_registro2.nmbenvid##1    || ''','''  ||--'JURACI TEREZINHA DE FANTE',
                rw_registro2.nmbenvid##2    || ''','''  ||--' ',
                rw_registro2.nmbenvid##3    || ''','''  ||--' ',
                rw_registro2.nmbenvid##4    || ''','''  ||--' ',
                rw_registro2.nmbenvid##5    || ''','''  ||--' ',
                rw_registro2.dsgraupr##1    || ''','''  ||--'MAE',
                rw_registro2.dsgraupr##2    || ''','''  ||--' ',
                rw_registro2.dsgraupr##3    || ''','''  ||--' ',
                rw_registro2.dsgraupr##4    || ''','''  ||--' ',
                rw_registro2.dsgraupr##5    || ''','''  ||--' ',
                rw_registro2.txpartic##1    || ''','''  ||--100.00,
                rw_registro2.txpartic##2    || ''','''  ||--0.00,
                rw_registro2.txpartic##3    || ''','''  ||--0.00,
                rw_registro2.txpartic##4    || ''','''  ||--0.00,
                rw_registro2.txpartic##5    || ''','''  ||--0.00,
                rw_registro2.dtultalt       || ''','''  ||
                rw_registro2.cdoperad       || ''','''  ||
                rw_registro2.vlpremio       || ''','''  ||
                rw_registro2.qtparcel       || ''','''  ||
                rw_registro2.tpdpagto       || ''','''  ||
                rw_registro2.cdcooper       || ''','''  ||
                rw_registro2.flgconve       || ''','''  ||
                rw_registro2.flgclabe       || ''','''  ||
                rw_registro2.cdmotcan       || ''','''  ||
                rw_registro2.tpendcor       || ''','''  ||
                rw_registro2.progress_recid || ''','''  ||
                rw_registro2.cdopecnl       || ''','''  ||
                rw_registro2.dtrenova       || ''','''  ||
                rw_registro2.cdopeori       || ''','''  ||
                rw_registro2.cdageori       || ''','''  ||
                rw_registro2.dtinsori       || ''','''  ||
                rw_registro2.cdopeexc       || ''','''  ||
                rw_registro2.cdageexc       || ''','''  ||
                rw_registro2.dtinsexc       || ''','''  ||
                rw_registro2.vlslddev       || ''','''  ||
                rw_registro2.idimpdps       || ''');');

      OPEN cr_registros3 (pr_cdcooper => rw_registro2.cdcooper,
                          pr_nrdconta => rw_registro2.nrdconta,
                          pr_nrctrseg => rw_registro2.nrctrseg);
        FETCH cr_registros3 INTO rw_registro3;

        DELETE FROM crapseg WHERE PROGRESS_RECID = rw_registro2.PROGRESS_RECID;

        -- Gera rollback
        gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,
                   'INSERT INTO crawseg  (dtmvtolt,   nrdconta,   nrctrseg,   tpseguro,   nmdsegur,   tpplaseg,   nmbenefi,   nrcadast,   nmdsecao,   dsendres,   nrendres,   nmbairro,   nmcidade,   cdufresd,   nrcepend,   dtinivig,   dtfimvig,   dsmarvei,   dstipvei,   nranovei,   nrmodvei,   qtpasvei,   ppdbonus,   flgdnovo,   nrapoant,   nmsegant,   flgdutil,   flgnotaf,   flgapant,   vlpreseg,   vlseguro,   vldfranq,   vldcasco,   vlverbae,   flgassis,   vldanmat,   vldanpes,   vldanmor,   vlappmor,   vlappinv,   cdsegura,   nmempres,   dschassi,   flgrenov,   dtdebito,   vlbenefi,   cdcalcul,   flgcurso,   dtiniseg,   nrdplaca,   lsctrant,   nrcpfcgc,   nrctratu,   nmcpveic,   flgunica,   nrctrato,   flgvisto,   cdapoant,   dtprideb,   vldifseg,   dscobext##1,   dscobext##2,   dscobext##3,   dscobext##4,   dscobext##5,   vlcobext##1,   vlcobext##2,   vlcobext##3,   vlcobext##4,   vlcobext##5,   flgrepgr,   vlfrqobr,   tpsegvid,   dtnascsg,   cdsexosg,   vlpremio,   qtparcel,   nrfonemp,   nrfonres,   dsoutgar,   vloutgar,   tpdpagto,   cdcooper,   flgconve,   complend,   progress_recid,   nrproposta ) VALUES (' ||
                   'TO_DATE(''' ||  rw_registro3.DTMVTOLT  || ''', ''DD-MM-YYYY''),''' ||
                    rw_registro3.nrdconta   || ''',''' ||
                    rw_registro3.nrctrseg   || ''',''' ||
                    rw_registro3.tpseguro   || ''',''' ||
                    rw_registro3.nmdsegur   || ''',''' ||
                    rw_registro3.tpplaseg   || ''',''' ||
                    rw_registro3.nmbenefi   || ''',''' ||
                    rw_registro3.nrcadast   || ''',''' ||
                    rw_registro3.nmdsecao   || ''',''' ||
                    rw_registro3.dsendres   || ''',''' ||
                    rw_registro3.nrendres   || ''',''' ||
                    rw_registro3.nmbairro   || ''',''' ||
                    rw_registro3.nmcidade   || ''',''' ||
                    rw_registro3.cdufresd   || ''',''' ||
                    rw_registro3.nrcepend   ||
                    ''',TO_DATE(''' || rw_registro3.dtinivig   || ''', ''DD-MM-YYYY'')' ||
                    ',TO_DATE(''' ||rw_registro3.dtfimvig    || ''', ''DD-MM-YYYY''),''' ||
                    rw_registro3.dsmarvei   || ''',''' ||
                    rw_registro3.dstipvei   || ''',''' ||
                    rw_registro3.nranovei   || ''',''' ||
                    rw_registro3.nrmodvei   || ''',''' ||
                    rw_registro3.qtpasvei   || ''',''' ||
                    rw_registro3.ppdbonus   || ''',''' ||
                    rw_registro3.flgdnovo   || ''',''' ||
                    rw_registro3.nrapoant   || ''',''' ||
                    rw_registro3.nmsegant   || ''',''' ||
                    rw_registro3.flgdutil   || ''',''' ||
                    rw_registro3.flgnotaf   || ''',''' ||
                    rw_registro3.flgapant   || ''',''' ||
                    rw_registro3.vlpreseg   || ''',''' ||
                    rw_registro3.vlseguro   || ''',''' ||
                    rw_registro3.vldfranq   || ''',''' ||
                    rw_registro3.vldcasco   || ''',''' ||
                    rw_registro3.vlverbae   || ''',''' ||
                    rw_registro3.flgassis   || ''',''' ||
                    rw_registro3.vldanmat   || ''',''' ||
                    rw_registro3.vldanpes   || ''',''' ||
                    rw_registro3.vldanmor   || ''',''' ||
                    rw_registro3.vlappmor   || ''',''' ||
                    rw_registro3.vlappinv   || ''',''' ||
                    rw_registro3.cdsegura   || ''',''' ||
                    rw_registro3.nmempres   || ''',''' ||
                    rw_registro3.dschassi   || ''',''' ||
                    rw_registro3.flgrenov   ||
                    ''',TO_DATE(''' ||rw_registro3.dtdebito || ''', ''DD-MM-YYYY''),''' ||
                    rw_registro3.vlbenefi   || ''',''' ||
                    rw_registro3.cdcalcul   || ''',''' ||
                    rw_registro3.flgcurso   ||
                    ''',TO_DATE(''' ||rw_registro3.dtiniseg|| ''', ''DD-MM-YYYY''),''' ||
                    rw_registro3.nrdplaca   || ''',''' ||
                    rw_registro3.lsctrant   || ''',''' ||
                    rw_registro3.nrcpfcgc   || ''',''' ||
                    rw_registro3.nrctratu   || ''',''' ||
                    rw_registro3.nmcpveic   || ''',''' ||
                    rw_registro3.flgunica   || ''',''' ||
                    rw_registro3.nrctrato   || ''',''' ||
                    rw_registro3.flgvisto   || ''',''' ||
                    rw_registro3.cdapoant   ||
                    ''',TO_DATE(''' ||rw_registro3.dtprideb|| ''', ''DD-MM-YYYY''),''' ||
                    rw_registro3.vldifseg   || ''',''' ||
                    rw_registro3.dscobext##1  || ''',''' ||
                    rw_registro3.dscobext##2  || ''',''' ||
                    rw_registro3.dscobext##3  || ''',''' ||
                    rw_registro3.dscobext##4  || ''',''' ||
                    rw_registro3.dscobext##5  || ''',''' ||
                    rw_registro3.vlcobext##1  || ''',''' ||
                    rw_registro3.vlcobext##2  || ''',''' ||
                    rw_registro3.vlcobext##3  || ''',''' ||
                    rw_registro3.vlcobext##4  || ''',''' ||
                    rw_registro3.vlcobext##5  || ''',''' ||
                    rw_registro3.flgrepgr   || ''',''' ||
                    rw_registro3.vlfrqobr   || ''',''' ||
                    rw_registro3.tpsegvid   ||
                    ''',TO_DATE(''' ||rw_registro3.dtnascsg|| ''', ''DD-MM-YYYY''),''' ||
                    rw_registro3.cdsexosg   || ''',''' ||
                    rw_registro3.vlpremio   || ''',''' ||
                    rw_registro3.qtparcel   || ''',''' ||
                    rw_registro3.nrfonemp   || ''',''' ||
                    rw_registro3.nrfonres   || ''',''' ||
                    rw_registro3.dsoutgar   || ''',''' ||
                    rw_registro3.vloutgar   || ''',''' ||
                    rw_registro3.tpdpagto   || ''',''' ||
                    rw_registro3.cdcooper   || ''',''' ||
                    rw_registro3.flgconve   || ''',''' ||
                    rw_registro3.complend   || ''',''' ||
                    rw_registro3.progress_recid || ''',''' ||
                    rw_registro3.nrproposta     || ''');');

        DELETE FROM crawseg WHERE nrdconta = rw_registro3.nrdconta AND cdcooper = rw_registro3.cdcooper AND nrctrseg = rw_registro3.nrctrseg;
      CLOSE cr_registros3;
      IF vr_qntd_reg = 500 THEN
        vr_qntd_reg := 0;
        COMMIT;
      ELSE
        vr_qntd_reg := vr_qntd_reg + 1;
      END IF;
    END LOOP;
    COMMIT;
    ------------------------------------------------------------------------------------------------------------------------------
    FOR rw_prestamista IN cr_registro4(pr_cdcooper => rw_crapop.cdcooper) LOOP
      vr_qntd_reg := 0;      
      FOR rw_crawseg IN cr_crawseg(pr_cdcooper => rw_prestamista.cdcooper
                                  ,pr_nrdconta => rw_prestamista.nrdconta
                                  ,pr_nrctrseg => rw_prestamista.nrctrseg
                                  ,pr_nrctrato => rw_prestamista.nrctremp) LOOP
        FOR rw_crapseg IN cr_crapseg(pr_cdcooper => rw_crawseg.cdcooper
                                    ,pr_nrdconta => rw_crawseg.nrdconta
                                    ,pr_nrctrseg => rw_crawseg.nrctrseg) LOOP
          -- Deletando crapseg
          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,
                    'INSERT INTO crapseg (NRDCONTA, NRCTRSEG, DTINIVIG, DTFIMVIG, DTMVTOLT, CDAGENCI, CDBCCXLT, CDSITSEG, DTALTSEG, DTCANCEL, DTDEBITO, DTINISEG, INDEBITO, NRDOLOTE, NRSEQDIG, QTPREPAG, VLPREPAG, VLPRESEG, DTULTPAG, TPSEGURO, TPPLASEG, QTPREVIG, CDSEGURA, LSCTRANT, NRCTRATU, FLGUNICA, DTPRIDEB, VLDIFSEG, NMBENVID##1, NMBENVID##2, NMBENVID##3, NMBENVID##4, NMBENVID##5, DSGRAUPR##1, DSGRAUPR##2, DSGRAUPR##3, DSGRAUPR##4, DSGRAUPR##5, TXPARTIC##1, TXPARTIC##2, TXPARTIC##3, TXPARTIC##4, TXPARTIC##5, DTULTALT, CDOPERAD, VLPREMIO, QTPARCEL, TPDPAGTO, CDCOOPER, FLGCONVE, FLGCLABE, CDMOTCAN, TPENDCOR, PROGRESS_RECID, CDOPECNL, DTRENOVA, CDOPEORI, CDAGEORI, DTINSORI, CDOPEEXC, CDAGEEXC, DTINSEXC, VLSLDDEV, IDIMPDPS) VALUES(''' ||
                    rw_crapseg.nrdconta     || ''',''' ||--7485301,
                    rw_crapseg.nrctrseg     || --72948,
                     ''',TO_DATE(''' || rw_crapseg.dtinivig || ''', ''DD-MM-YYYY'')' || --to_date('08-01-2015', 'dd-mm-yyyy'),
                     ',TO_DATE(''' || rw_crapseg.dtfimvig || ''', ''DD-MM-YYYY'')' || --to_date('19-10-2016', 'dd-mm-yyyy'),
                     ',TO_DATE(''' || rw_crapseg.dtmvtolt || ''', ''DD-MM-YYYY''),''' ||--to_date('08-01-2015', 'dd-mm-yyyy'),
                    rw_crapseg.CDAGENCI     || ''','''  ||--35,
                    rw_crapseg.CDBCCXLT     || ''','''  ||--0,
                    rw_crapseg.CDSITSEG     || --2,
                    ''',TO_DATE('''|| rw_crapseg.dtaltseg || ''', ''DD-MM-YYYY'')' ||--to_date('08-01-2015', 'dd-mm-yyyy'),
                    ',TO_DATE('''  || rw_crapseg.dtcancel || ''', ''DD-MM-YYYY'')' ||--to_date('19-10-2016', 'dd-mm-yyyy'),
                    ',TO_DATE('''  || rw_crapseg.dtdebito || ''', ''DD-MM-YYYY'')' ||--to_date('08-11-2016', 'dd-mm-yyyy'),
                    ',TO_DATE('''  || rw_crapseg.dtiniseg || ''', ''DD-MM-YYYY''),''' ||--to_date('08-01-2015', 'dd-mm-yyyy'),
                    rw_crapseg.indebito     || ''','''  ||--1,
                    rw_crapseg.nrdolote     || ''','''  ||--0,
                    rw_crapseg.nrseqdig     || ''','''  ||--72948,
                    rw_crapseg.qtprepag     || ''','''  ||--22,
                    rw_crapseg.vlprepag     || ''','''  ||--91.16,
                    rw_crapseg.vlpreseg     || --5.36,
                    ''',TO_DATE('''|| rw_crapseg.dtultpag || ''', ''DD-MM-YYYY''),''' ||--to_date('10-10-2016', 'dd-mm-yyyy'),
                    rw_crapseg.tpseguro     || ''','''  ||--3,
                    rw_crapseg.tpplaseg     || ''','''  ||--11,
                    rw_crapseg.qtprevig     || ''','''  ||--22,
                    rw_crapseg.cdsegura     || ''','''  ||--5011,
                    rw_crapseg.lsctrant     || ''','''  ||--' ',
                    rw_crapseg.nrctratu     || ''','''  ||--0,
                    rw_crapseg.flgunica     || ''','''  ||--0,
                    rw_crapseg.dtprideb       || ''','''  ||--null,
                    rw_crapseg.vldifseg       || ''','''  ||--0.00,
                    rw_crapseg.nmbenvid##1    || ''','''  ||--'JURACI TEREZINHA DE FANTE',
                    rw_crapseg.nmbenvid##2    || ''','''  ||--' ',
                    rw_crapseg.nmbenvid##3    || ''','''  ||--' ',
                    rw_crapseg.nmbenvid##4    || ''','''  ||--' ',
                    rw_crapseg.nmbenvid##5    || ''','''  ||--' ',
                    rw_crapseg.dsgraupr##1    || ''','''  ||--'MAE',
                    rw_crapseg.dsgraupr##2    || ''','''  ||--' ',
                    rw_crapseg.dsgraupr##3    || ''','''  ||--' ',
                    rw_crapseg.dsgraupr##4    || ''','''  ||--' ',
                    rw_crapseg.dsgraupr##5    || ''','''  ||--' ',
                    rw_crapseg.txpartic##1    || ''','''  ||--100.00,
                    rw_crapseg.txpartic##2    || ''','''  ||--0.00,
                    rw_crapseg.txpartic##3    || ''','''  ||--0.00,
                    rw_crapseg.txpartic##4    || ''','''  ||--0.00,
                    rw_crapseg.txpartic##5    || ''','''  ||--0.00,
                    rw_crapseg.dtultalt       || ''','''  ||
                    rw_crapseg.cdoperad       || ''','''  ||
                    rw_crapseg.vlpremio       || ''','''  ||
                    rw_crapseg.qtparcel       || ''','''  ||
                    rw_crapseg.tpdpagto       || ''','''  ||
                    rw_crapseg.cdcooper       || ''','''  ||
                    rw_crapseg.flgconve       || ''','''  ||
                    rw_crapseg.flgclabe       || ''','''  ||
                    rw_crapseg.cdmotcan       || ''','''  ||
                    rw_crapseg.tpendcor       || ''','''  ||
                    rw_crapseg.progress_recid || ''','''  ||
                    rw_crapseg.cdopecnl       || ''','''  ||
                    rw_crapseg.dtrenova       || ''','''  ||
                    rw_crapseg.cdopeori       || ''','''  ||
                    rw_crapseg.cdageori       || ''','''  ||
                    rw_crapseg.dtinsori       || ''','''  ||
                    rw_crapseg.cdopeexc       || ''','''  ||
                    rw_crapseg.cdageexc       || ''','''  ||
                    rw_crapseg.dtinsexc       || ''','''  ||
                    rw_crapseg.vlslddev       || ''','''  ||
                    rw_crapseg.idimpdps       || ''');');
          DELETE
            FROM crapseg
           WHERE progress_recid = rw_crapseg.progress_recid;
        END LOOP;

        -- Deletando crawseg
        gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,
                   'INSERT INTO crawseg  (DTMVTOLT,   NRDCONTA,   NRCTRSEG,   TPSEGURO,   NMDSEGUR,   TPPLASEG,   NMBENEFI,   NRCADAST,   NMDSECAO,   DSENDRES,   NRENDRES,   NMBAIRRO,   NMCIDADE,   CDUFRESD,   NRCEPEND,   DTINIVIG,   DTFIMVIG,   DSMARVEI,   DSTIPVEI,   NRANOVEI,   NRMODVEI,   QTPASVEI,   PPDBONUS,   FLGDNOVO,   NRAPOANT,   NMSEGANT,   FLGDUTIL,   FLGNOTAF,   FLGAPANT,   VLPRESEG,   VLSEGURO,   VLDFRANQ,   VLDCASCO,   VLVERBAE,   FLGASSIS,   VLDANMAT,   VLDANPES,   VLDANMOR,   VLAPPMOR,   VLAPPINV,   CDSEGURA,   NMEMPRES,   DSCHASSI,   FLGRENOV,   DTDEBITO,   VLBENEFI,   CDCALCUL,   FLGCURSO,   DTINISEG,   NRDPLACA,   LSCTRANT,   NRCPFCGC,   NRCTRATU,   NMCPVEIC,   FLGUNICA,   NRCTRATO,   FLGVISTO,   CDAPOANT,   DTPRIDEB,   VLDIFSEG,   DSCOBEXT##1,   DSCOBEXT##2,   DSCOBEXT##3,   DSCOBEXT##4,   DSCOBEXT##5,   VLCOBEXT##1,   VLCOBEXT##2,   VLCOBEXT##3,   VLCOBEXT##4,   VLCOBEXT##5,   FLGREPGR,   VLFRQOBR,   TPSEGVID,   DTNASCSG,   CDSEXOSG,   VLPREMIO,   QTPARCEL,   NRFONEMP,   NRFONRES,   DSOUTGAR,   VLOUTGAR,   TPDPAGTO,   CDCOOPER,   FLGCONVE,   COMPLEND,   PROGRESS_RECID,   NRPROPOSTA ) VALUES (' ||
                   'TO_DATE(''' ||  rw_crawseg.DTMVTOLT  || ''', ''DD-MM-YYYY''),''' ||
                    rw_crawseg.nrdconta   || ''',''' ||
                    rw_crawseg.nrctrseg   || ''',''' ||
                    rw_crawseg.tpseguro   || ''',''' ||
                    rw_crawseg.nmdsegur   || ''',''' ||
                    rw_crawseg.tpplaseg   || ''',''' ||
                    rw_crawseg.nmbenefi   || ''',''' ||
                    rw_crawseg.nrcadast   || ''',''' ||
                    rw_crawseg.nmdsecao   || ''',''' ||
                    rw_crawseg.dsendres   || ''',''' ||
                    rw_crawseg.nrendres   || ''',''' ||
                    rw_crawseg.nmbairro   || ''',''' ||
                    rw_crawseg.nmcidade   || ''',''' ||
                    rw_crawseg.cdufresd   || ''',''' ||
                    rw_crawseg.nrcepend   ||
                    ''',TO_DATE(''' || rw_crawseg.dtinivig   || ''', ''DD-MM-YYYY'')' ||
                    ',TO_DATE(''' ||rw_crawseg.dtfimvig    || ''', ''DD-MM-YYYY''),''' ||
                    rw_crawseg.dsmarvei   || ''',''' ||
                    rw_crawseg.dstipvei   || ''',''' ||
                    rw_crawseg.nranovei   || ''',''' ||
                    rw_crawseg.nrmodvei   || ''',''' ||
                    rw_crawseg.qtpasvei   || ''',''' ||
                    rw_crawseg.ppdbonus   || ''',''' ||
                    rw_crawseg.flgdnovo   || ''',''' ||
                    rw_crawseg.nrapoant   || ''',''' ||
                    rw_crawseg.nmsegant   || ''',''' ||
                    rw_crawseg.flgdutil   || ''',''' ||
                    rw_crawseg.flgnotaf   || ''',''' ||
                    rw_crawseg.flgapant   || ''',''' ||
                    rw_crawseg.vlpreseg   || ''',''' ||
                    rw_crawseg.vlseguro   || ''',''' ||
                    rw_crawseg.vldfranq   || ''',''' ||
                    rw_crawseg.vldcasco   || ''',''' ||
                    rw_crawseg.vlverbae   || ''',''' ||
                    rw_crawseg.flgassis   || ''',''' ||
                    rw_crawseg.vldanmat   || ''',''' ||
                    rw_crawseg.vldanpes   || ''',''' ||
                    rw_crawseg.vldanmor   || ''',''' ||
                    rw_crawseg.vlappmor   || ''',''' ||
                    rw_crawseg.vlappinv   || ''',''' ||
                    rw_crawseg.cdsegura   || ''',''' ||
                    rw_crawseg.nmempres   || ''',''' ||
                    rw_crawseg.dschassi   || ''',''' ||
                    rw_crawseg.flgrenov   ||
                    ''',TO_DATE(''' ||rw_crawseg.dtdebito || ''', ''DD-MM-YYYY''),''' ||
                    rw_crawseg.vlbenefi   || ''',''' ||
                    rw_crawseg.cdcalcul   || ''',''' ||
                    rw_crawseg.flgcurso   ||
                    ''',TO_DATE(''' ||rw_crawseg.dtiniseg|| ''', ''DD-MM-YYYY''),''' ||
                    rw_crawseg.nrdplaca   || ''',''' ||
                    rw_crawseg.lsctrant   || ''',''' ||
                    rw_crawseg.nrcpfcgc   || ''',''' ||
                    rw_crawseg.nrctratu   || ''',''' ||
                    rw_crawseg.nmcpveic   || ''',''' ||
                    rw_crawseg.flgunica   || ''',''' ||
                    rw_crawseg.nrctrato   || ''',''' ||
                    rw_crawseg.flgvisto   || ''',''' ||
                    rw_crawseg.cdapoant   ||
                    ''',TO_DATE(''' ||rw_crawseg.dtprideb|| ''', ''DD-MM-YYYY''),''' ||
                    rw_crawseg.vldifseg   || ''',''' ||
                    rw_crawseg.dscobext##1  || ''',''' ||
                    rw_crawseg.dscobext##2  || ''',''' ||
                    rw_crawseg.dscobext##3  || ''',''' ||
                    rw_crawseg.dscobext##4  || ''',''' ||
                    rw_crawseg.dscobext##5  || ''',''' ||
                    rw_crawseg.vlcobext##1  || ''',''' ||
                    rw_crawseg.vlcobext##2  || ''',''' ||
                    rw_crawseg.vlcobext##3  || ''',''' ||
                    rw_crawseg.vlcobext##4  || ''',''' ||
                    rw_crawseg.vlcobext##5  || ''',''' ||
                    rw_crawseg.flgrepgr   || ''',''' ||
                    rw_crawseg.vlfrqobr   || ''',''' ||
                    rw_crawseg.tpsegvid   ||
                    ''',TO_DATE(''' ||rw_crawseg.dtnascsg|| ''', ''DD-MM-YYYY''),''' ||
                    rw_crawseg.cdsexosg   || ''',''' ||
                    rw_crawseg.vlpremio   || ''',''' ||
                    rw_crawseg.qtparcel   || ''',''' ||
                    rw_crawseg.nrfonemp   || ''',''' ||
                    rw_crawseg.nrfonres   || ''',''' ||
                    rw_crawseg.dsoutgar   || ''',''' ||
                    rw_crawseg.vloutgar   || ''',''' ||
                    rw_crawseg.tpdpagto   || ''',''' ||
                    rw_crawseg.cdcooper   || ''',''' ||
                    rw_crawseg.flgconve   || ''',''' ||
                    rw_crawseg.complend   || ''',''' ||
                    rw_crawseg.progress_recid || ''',''' ||
                    rw_crawseg.nrproposta     || ''');');

         DELETE
           FROM crawseg
          WHERE progress_recid = rw_crawseg.progress_recid;
      END LOOP;
        -- ROLLBACK Prestamista
        gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'UPDATE crawseg SET nrproposta = '||rw_prestamista.nrproposta_crawseg
                                                     ||' WHERE progress_recid = '||rw_prestamista.progress_recid||';');

        BEGIN
          UPDATE crawseg w
             SET w.nrproposta = rw_prestamista.nrproposta
           WHERE w.cdcooper = rw_prestamista.cdcooper
             AND w.nrdconta = rw_prestamista.nrdconta
             AND w.nrctrseg = rw_prestamista.nrctrseg;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic:= 'Erro ao gravar numero de proposta 1: '||rw_prestamista.nrproposta || ' progress_recid: ' || rw_prestamista.progress_recid ||' - '||SQLERRM;
            RAISE vr_exc_erro;
        END;
        IF vr_qntd_reg = 500 THEN
          vr_qntd_reg := 0;
          COMMIT;
        ELSE
          vr_qntd_reg := vr_qntd_reg + 1;
        END IF;
    END LOOP;
    COMMIT;
  END LOOP;
  ---------------------------------------------------------------
  -- Adiciona TAG de commit
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'COMMIT;');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;
  vr_dscritic := 'Registro atualizado com sucesso!';
  dbms_output.put_line(vr_dscritic);

  -- Efetuamos a transação
  COMMIT;
  EXCEPTION
    WHEN vr_exc_erro THEN
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;
      vr_dscritic := 'ERRO ' || vr_dscritic;
      dbms_output.put_line(vr_dscritic);
      ROLLBACK;
END;
/
