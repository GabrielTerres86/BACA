declare
  vr_ind_arq  utl_file.file_type;
  vcount      NUMBER := 0;
  vr_texto    VARCHAR2(32767);
  vr_dscritic VARCHAR2(2000);
  vr_nmdir    VARCHAR2(4000) := CECRED.gene0001.fn_param_sistema('CRED',
                                                                 3,
                                                                 'ROOT_MICROS') ||
                                'cpd/bacas/RITM0350992';
  vr_nmarq    VARCHAR2(100) := 'ROLLBACK_RITM0350992.sql';
  vr_exc_saida EXCEPTION;

  CURSOR cr_principal IS
    select w.dtmvtolt,
           w.nrdconta,
           w.nrctrseg,
           w.tpseguro,
           w.nmdsegur,
           w.tpplaseg,
           w.nmbenefi,
           w.nrcadast,
           w.nmdsecao,
           w.dsendres,
           w.nrendres,
           w.nmbairro,
           w.nmcidade,
           w.cdufresd,
           w.nrcepend,
           w.dtinivig,
           w.dtfimvig,
           w.dsmarvei,
           w.dstipvei,
           w.nranovei,
           w.nrmodvei,
           w.qtpasvei,
           w.ppdbonus,
           w.flgdnovo,
           w.nrapoant,
           w.nmsegant,
           w.flgdutil,
           w.flgnotaf,
           w.flgapant,
           w.vlpreseg,
           w.vlseguro,
           w.vldfranq,
           w.vldcasco,
           w.vlverbae,
           w.flgassis,
           w.vldanmat,
           w.vldanpes,
           w.vldanmor,
           w.vlappmor,
           w.vlappinv,
           w.cdsegura,
           w.nmempres,
           w.dschassi,
           w.flgrenov,
           w.dtdebito,
           w.vlbenefi,
           w.cdcalcul,
           w.flgcurso,
           w.dtiniseg,
           w.nrdplaca,
           w.lsctrant,
           w.nrcpfcgc,
           w.nrctratu,
           w.nmcpveic,
           w.flgunica,
           w.nrctrato,
           w.flgvisto,
           w.cdapoant,
           w.dtprideb,
           w.vldifseg,
           w.dscobext##1,
           w.dscobext##2,
           w.dscobext##3,
           w.dscobext##4,
           w.dscobext##5,
           w.vlcobext##1,
           w.vlcobext##2,
           w.vlcobext##3,
           w.vlcobext##4,
           w.vlcobext##5,
           w.flgrepgr,
           w.vlfrqobr,
           w.tpsegvid,
           w.dtnascsg,
           w.cdsexosg,
           w.vlpremio,
           w.qtparcel,
           w.nrfonemp,
           w.nrfonres,
           w.dsoutgar,
           w.vloutgar,
           w.tpdpagto,
           w.cdcooper,
           w.flgconve,
           w.complend,
           w.progress_recid,
           w.nrproposta,
           w.flggarad,
           w.flgassum,
           w.tpcustei,
           w.tpmodali,
           w.flfinanciasegprestamista,
           w.flgsegma,          
           p.nrdconta                 as nrdconta_,
           p.nrctrseg                 as nrctrseg_,
           p.dtinivig                 as dtinivig_,
           p.dtfimvig                 as dtfimvig_,
           p.dtmvtolt                 as dtmvtolt_,
           p.cdagenci                 as cdagenci_,
           p.cdbccxlt                 as cdbccxlt_,
           p.cdsitseg                 as cdsitseg_,
           p.dtaltseg                 as dtaltseg_,
           p.dtcancel                 as dtcancel_,
           p.dtdebito                 as dtdebito_,
           p.dtiniseg                 as dtiniseg_,
           p.indebito                 as indebito_,
           p.nrdolote                 as nrdolote_,
           p.nrseqdig                 as nrseqdig_,
           p.qtprepag                 as qtprepag_,
           p.vlprepag                 as vlprepag_,
           p.vlpreseg                 as vlpreseg_,
           p.dtultpag                 as dtultpag_,
           p.tpseguro                 as tpseguro_,
           p.tpplaseg                 as tpplaseg_,
           p.qtprevig                 as qtprevig_,
           p.cdsegura                 as cdsegura_,
           p.lsctrant                 as lsctrant_,
           p.nrctratu                 as nrctratu_,
           p.flgunica                 as flgunica_,
           p.dtprideb                 as dtprideb_,
           p.vldifseg                 as vldifseg_,
           p.nmbenvid##1              as nmbenvid##1_,
           p.nmbenvid##2              as nmbenvid##2_,
           p.nmbenvid##3              as nmbenvid##3_,
           p.nmbenvid##4              as nmbenvid##4_,
           p.nmbenvid##5              as nmbenvid##5_,
           p.dsgraupr##1              as dsgraupr##1_,
           p.dsgraupr##2              as dsgraupr##2_,
           p.dsgraupr##3              as dsgraupr##3_,
           p.dsgraupr##4              as dsgraupr##4_,
           p.dsgraupr##5              as dsgraupr##5_,
           p.txpartic##1              as txpartic##1_,
           p.txpartic##2              as txpartic##2_,
           p.txpartic##3              as txpartic##3_,
           p.txpartic##4              as txpartic##4_,
           p.txpartic##5              as txpartic##5_,
           p.dtultalt                 as dtultalt_,
           p.cdoperad                 as cdoperad_,
           p.vlpremio                 as vlpremio_,
           p.qtparcel                 as qtparcel_,
           p.tpdpagto                 as tpdpagto_,
           p.cdcooper                 as cdcooper_,
           p.flgconve                 as flgconve_,
           p.flgclabe                 as flgclabe_,
           p.cdmotcan                 as cdmotcan_,
           p.tpendcor                 as tpendcor_,
           p.progress_recid           as progress_recid_,
           p.cdopecnl                 as cdopecnl_,
           p.dtrenova                 as dtrenova_,
           p.cdopeori                 as cdopeori_,
           p.cdageori                 as cdageori_,
           p.dtinsori                 as dtinsori_,
           p.cdopeexc                 as cdopeexc_,
           p.cdageexc                 as cdageexc_,
           p.dtinsexc                 as dtinsexc_,
           p.vlslddev                 as vlslddev_,
           p.idimpdps                 as idimpdps_
      from cecred.crawseg w, cecred.crapseg p, cecred.crawepr ep
     where p.CDCOOPER = w.CDCOOPER
       and p.NRDCONTA = w.NRDCONTA
       and p.NRCTRSEG = w.NRCTRSEG
       and p.CDCOOPER = ep.CDCOOPER(+)
       and p.NRDCONTA = ep.NRDCONTA(+)
       and w.NRCTrato = ep.NRCTREMP(+)
       and p.CDSITSEG = 1
       and p.DTCANCEL is null
       and p.TPSEGURO = 4    
       and not exists (select 0
              from tbseg_prestamista w
             where w.CDCOOPER = p.CDCOOPER
               and w.NRDCONTA = p.NRDCONTA
               and w.NRCTRSEG = p.NRCTRSEG)
     order by p.CDCOOPER, p.DTINIVIG desc, w.NRPROPOSTA;

  PROCEDURE pc_valida_direto(pr_nmdireto IN VARCHAR2,
                             pr_dscritic OUT CECRED.crapcri.dscritic%TYPE) IS
    vr_dscritic  CECRED.crapcri.dscritic%TYPE;
    vr_typ_saida VARCHAR2(3);
    vr_des_saida VARCHAR2(1000);
    vr_exc_erro EXCEPTION;
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
  pc_valida_direto(pr_nmdireto => vr_nmdir, pr_dscritic => vr_dscritic);

  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;

  CECRED.GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdir,
                                  pr_nmarquiv => vr_nmarq,
                                  pr_tipabert => 'W',
                                  pr_utlfileh => vr_ind_arq,
                                  pr_des_erro => vr_dscritic);

  IF vr_dscritic IS NOT NULL THEN
    vr_dscritic := vr_dscritic || '  Não pode abrir arquivo ' || vr_nmdir ||
                   vr_nmarq;
    RAISE vr_exc_saida;
  END IF;

  CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq, 'BEGIN');

  FOR rw_principal IN cr_principal LOOP
   
   vr_texto := ' insert into cecred.crapseg (NRDCONTA, NRCTRSEG, DTINIVIG, DTFIMVIG, DTMVTOLT, CDAGENCI, CDBCCXLT, CDSITSEG, DTALTSEG, DTCANCEL, ' ||
                '                            DTDEBITO, DTINISEG, INDEBITO, NRDOLOTE, NRSEQDIG, QTPREPAG, VLPREPAG, VLPRESEG, DTULTPAG, TPSEGURO, ' ||
                '                            TPPLASEG, QTPREVIG, CDSEGURA, LSCTRANT, NRCTRATU, FLGUNICA, DTPRIDEB, VLDIFSEG, NMBENVID##1, NMBENVID##2, ' ||
                '                            NMBENVID##3, NMBENVID##4, NMBENVID##5, DSGRAUPR##1, DSGRAUPR##2, DSGRAUPR##3, DSGRAUPR##4, DSGRAUPR##5, TXPARTIC##1, TXPARTIC##2, ' ||
                '                            TXPARTIC##3, TXPARTIC##4, TXPARTIC##5, DTULTALT, CDOPERAD, VLPREMIO, QTPARCEL, TPDPAGTO, CDCOOPER, FLGCONVE, ' ||
                '                            FLGCLABE, CDMOTCAN, TPENDCOR, PROGRESS_RECID, CDOPECNL, DTRENOVA, CDOPEORI, CDAGEORI, DTINSORI, CDOPEEXC, ' ||
                '                            CDAGEEXC, DTINSEXC, VLSLDDEV, IDIMPDPS) ' ||
                
                '                     values (' || rw_principal.NRDCONTA_ || ',' ||
                rw_principal.NRCTRSEG_ || ',to_date(''' || rw_principal.DTINIVIG_ ||
                ''',''dd/mm/yyyy''),to_date(''' || rw_principal.DTFIMVIG_ ||
                ''', ''dd/mm/yyyy''),to_date(''' || rw_principal.DTMVTOLT_ ||
                ''',''dd/mm/yyyy''),' || rw_principal.CDAGENCI_ || ',' ||
                rw_principal.CDBCCXLT_ || ',' || rw_principal.CDSITSEG_ ||
                ',to_date(''' || rw_principal.DTALTSEG_ ||
                ''', ''dd/mm/yyyy''),to_date(''' || rw_principal.DTCANCEL_ ||
                
                ''',''dd/mm/yyyy''),' || 'to_date(''' || rw_principal.DTDEBITO_ ||
                ''',''dd/mm/yyyy''),to_date(''' || rw_principal.DTINISEG_ ||
                ''',''dd/mm/yyyy''),' || rw_principal.INDEBITO_ || ',' ||
                rw_principal.NRDOLOTE_ || ',' || rw_principal.NRSEQDIG_ || ',' ||
                rw_principal.QTPREPAG_ || ',' || replace(rw_principal.VLPREPAG_,',','.') || ',' ||
                replace(rw_principal.VLPRESEG_,',','.') || ',to_date(''' || rw_principal.DTULTPAG_ ||
                ''',''dd/mm/yyyy''),' || rw_principal.TPSEGURO_ || ',' ||
                
                rw_principal.TPPLASEG_ || ',' || rw_principal.QTPREVIG_ || ',' ||
                rw_principal.CDSEGURA_ || ',''' || rw_principal.LSCTRANT_ || ''',' ||
                rw_principal.NRCTRATU_ || ',' || rw_principal.FLGUNICA_ ||
                ',to_date(''' || rw_principal.DTPRIDEB_ || ''',''dd/mm/yyyy''),' ||
                replace(rw_principal.VLDIFSEG_,',','.') || ',''' || rw_principal.NMBENVID##1_ || ''',''' ||
                rw_principal.NMBENVID##2_ || ''',''' ||
                
                 rw_principal.NMBENVID##3_ ||
                ''',''' || rw_principal.NMBENVID##4_ || ''',''' ||
                rw_principal.NMBENVID##5_ || ''',''' || rw_principal.DSGRAUPR##1_ ||
                ''',''' || rw_principal.DSGRAUPR##2_ || ''',''' ||
                rw_principal.DSGRAUPR##3_ || ''',''' || rw_principal.DSGRAUPR##4_ ||
                ''',''' || rw_principal.DSGRAUPR##5_ || ''',' ||
                rw_principal.TXPARTIC##1_ || ',' || rw_principal.TXPARTIC##2_ || ',' ||
                
                rw_principal.TXPARTIC##3_ || ',' || rw_principal.TXPARTIC##4_ || ',' ||
                rw_principal.TXPARTIC##5_ || ',to_date(''' || rw_principal.DTULTALT_ ||
                ''',''dd/mm/yyyy''),''' || rw_principal.CDOPERAD_ || ''',' ||
                replace(rw_principal.VLPREMIO_,',','.') || ',' || rw_principal.QTPARCEL_ || ',' ||
                rw_principal.TPDPAGTO_ || ',' || rw_principal.CDCOOPER_ || ',' ||
                rw_principal.FLGCONVE_ || ',' || 
               
                rw_principal.FLGCLABE_ || ',' ||
                rw_principal.CDMOTCAN_ || ',' || rw_principal.TPENDCOR_ || ',' || rw_principal.PROGRESS_RECID_  || ',''' ||               
                rw_principal.CDOPECNL_ || ''',to_date(''' || rw_principal.DTRENOVA_ ||
                ''',''dd/mm/yyyy''),''' || rw_principal.CDOPEORI_ || ''',''' ||
                rw_principal.CDAGEORI_ || ''', to_date(''' || rw_principal.DTINSORI_ ||
                ''',''dd/mm/yyyy hh24:mi:ss''),''' ||  rw_principal.CDOPEEXC_ || ''',''' ||               
               
                rw_principal.CDAGEEXC_ || ''',to_date(''' || 
                rw_principal.DTINSEXC_ || ''',''dd/mm/yyyy''),' ||
                replace(rw_principal.VLSLDDEV_,',','.') || ',' || rw_principal.IDIMPDPS_ || ');';
  
    CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq, vr_texto);
  
    vr_texto := ' insert into cecred.crawseg (DTMVTOLT, NRDCONTA, NRCTRSEG, TPSEGURO, NMDSEGUR, TPPLASEG, NMBENEFI, NRCADAST, NMDSECAO, ' ||
                '                             DSENDRES, NRENDRES, NMBAIRRO, NMCIDADE, CDUFRESD, NRCEPEND, DTINIVIG, DTFIMVIG, DSMARVEI, ' ||
                '                             DSTIPVEI, NRANOVEI, NRMODVEI, QTPASVEI, PPDBONUS, FLGDNOVO, NRAPOANT, NMSEGANT, FLGDUTIL, ' ||
                '                             FLGNOTAF, FLGAPANT, VLPRESEG, VLSEGURO, VLDFRANQ, VLDCASCO, VLVERBAE, FLGASSIS, VLDANMAT, ' ||
                '                             VLDANPES, VLDANMOR, VLAPPMOR, VLAPPINV, CDSEGURA, NMEMPRES, DSCHASSI, FLGRENOV, DTDEBITO, ' ||
                '                             VLBENEFI, CDCALCUL, FLGCURSO, DTINISEG, NRDPLACA, LSCTRANT, NRCPFCGC, NRCTRATU, NMCPVEIC, ' ||
                '                             FLGUNICA, NRCTRATO, FLGVISTO, CDAPOANT, DTPRIDEB, VLDIFSEG, DSCOBEXT##1, DSCOBEXT##2, DSCOBEXT##3, ' ||
                '                             DSCOBEXT##4, DSCOBEXT##5, VLCOBEXT##1, VLCOBEXT##2, VLCOBEXT##3, VLCOBEXT##4, VLCOBEXT##5, FLGREPGR, ' ||
                '                             VLFRQOBR, TPSEGVID, DTNASCSG, CDSEXOSG, VLPREMIO, QTPARCEL, NRFONEMP, NRFONRES, DSOUTGAR, VLOUTGAR, ' ||
                '                             TPDPAGTO, CDCOOPER, FLGCONVE, COMPLEND, PROGRESS_RECID, NRPROPOSTA, FLGGARAD, FLGASSUM, TPCUSTEI, ' ||
                '                             TPMODALI, FLFINANCIASEGPRESTAMISTA, FLGSEGMA) ' ||
              
                ' values (to_date(''' || rw_principal.DTMVTOLT ||
                ''', ''dd/mm/yyyy''),' || rw_principal.NRDCONTA || ',' ||
                rw_principal.NRCTRSEG || ',' || rw_principal.TPSEGURO || ',''' ||
                rw_principal.NMDSEGUR || ''' ,' || rw_principal.TPPLASEG || ',''' ||
                rw_principal.NMBENEFI || ''',' || rw_principal.NRCADAST || ',''' ||
                rw_principal.NMDSECAO || ''',''' ||
              
                rw_principal.DSENDRES || ''',' ||
                rw_principal.NRENDRES || ',''' || rw_principal.NMBAIRRO || ''',''' ||
                rw_principal.NMCIDADE || ''',''' || rw_principal.CDUFRESD || ''',' ||
                rw_principal.NRCEPEND || ',to_date(''' || rw_principal.DTINIVIG ||
                ''',''dd/mm/yyyy''),' || 'to_date(''' || rw_principal.DTFIMVIG ||
                ''',''dd/mm/yyyy''),''' || rw_principal.DSMARVEI || ''',''' ||
              
                rw_principal.DSTIPVEI || ''',' || rw_principal.NRANOVEI || ',' ||
                rw_principal.NRMODVEI || ',' || replace(rw_principal.QTPASVEI,',','.') || ',' ||
                replace(rw_principal.PPDBONUS,',','.') || ',' || rw_principal.FLGDNOVO || ',' ||
                rw_principal.NRAPOANT || ',''' || rw_principal.NMSEGANT || ''',' ||
                rw_principal.FLGDUTIL || ',' ||
              
                rw_principal.FLGNOTAF || ',' ||
                rw_principal.FLGAPANT || ',' || replace(rw_principal.VLPRESEG,',','.') || ',' ||
                replace(rw_principal.VLSEGURO,',','.') || ',' || replace(rw_principal.VLDFRANQ,',','.') || ',' ||
                replace(rw_principal.VLDCASCO,',','.') || ',' || replace(rw_principal.VLVERBAE,',','.') || ',' ||
                replace(rw_principal.FLGASSIS,',','.') || ',' || replace(rw_principal.VLDANMAT,',','.') || ',' ||
              
                replace(rw_principal.VLDANPES,',','.') || ',' || replace(rw_principal.VLDANMOR,',','.') || ',' || replace(rw_principal.VLAPPMOR,',','.') || ',' ||
                replace(rw_principal.VLAPPINV,',','.') || ',' || rw_principal.CDSEGURA || ',''' ||
                rw_principal.NMEMPRES || ''',''' || rw_principal.DSCHASSI || ''',' ||
                rw_principal.FLGRENOV || ',to_date(''' || rw_principal.DTDEBITO ||
                
                ''', ''dd/mm/yyyy''),' || replace(rw_principal.VLBENEFI,',','.') || ',' ||
                rw_principal.CDCALCUL || ',' || rw_principal.FLGCURSO ||
                ',to_date(''' || rw_principal.DTINISEG ||
                ''', ''dd/mm/yyyy''),''' || rw_principal.NRDPLACA || ''',''' ||
                rw_principal.LSCTRANT || ''',''' || rw_principal.NRCPFCGC || ''',' ||
                rw_principal.NRCTRATU || ',''' || rw_principal.NMCPVEIC || ''',' ||
                
                rw_principal.FLGUNICA || ',' || rw_principal.NRCTRATO || ',' ||
                rw_principal.FLGVISTO || ',''' || rw_principal.CDAPOANT ||
                ''', to_date(''' || rw_principal.DTPRIDEB ||
                ''', ''dd/mm/yyyy''),' || replace(rw_principal.VLDIFSEG,',','.') || ',''' ||
                rw_principal.DSCOBEXT##1 || ''',''' || rw_principal.DSCOBEXT##2 ||
                ''',''' || rw_principal.DSCOBEXT##3 || ''',''' ||
                
                rw_principal.DSCOBEXT##4 || ''',''' || rw_principal.DSCOBEXT##5 ||
                ''',' || replace(rw_principal.VLCOBEXT##1,',','.') || ',' || replace(rw_principal.VLCOBEXT##2,',','.') || ',' ||
                replace(rw_principal.VLCOBEXT##3,',','.') || ',' || replace(rw_principal.VLCOBEXT##4,',','.') || ',' ||
                replace(rw_principal.VLCOBEXT##5,',','.') || ',' || rw_principal.FLGREPGR || ',' ||
                
                replace(rw_principal.VLFRQOBR,',','.') || ',' || rw_principal.TPSEGVID ||
                ', to_date(''' || rw_principal.DTNASCSG ||
                ''', ''dd/mm/yyyy''),' || rw_principal.CDSEXOSG || ',' ||
                replace(rw_principal.VLPREMIO,',','.') || ',' || rw_principal.QTPARCEL || ',''' ||
                rw_principal.NRFONEMP || ''',''' || rw_principal.NRFONRES || ''',''' ||
                rw_principal.DSOUTGAR || ''',' || replace(rw_principal.VLOUTGAR,',','.') || ',' ||
                
                rw_principal.TPDPAGTO || ',' || rw_principal.CDCOOPER || ',' ||
                rw_principal.FLGCONVE || ',''' || rw_principal.COMPLEND || ''',' ||
                rw_principal.PROGRESS_RECID || ',''' || rw_principal.NRPROPOSTA ||
                ''',' || rw_principal.FLGGARAD || ',' || rw_principal.FLGASSUM || ',' ||
                rw_principal.TPCUSTEI || ',' ||
                
                rw_principal.TPMODALI || ',' ||
                rw_principal.FLFINANCIASEGPRESTAMISTA || ',' || rw_principal.FLGSEGMA || ');';
  
    CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq, vr_texto);
  
    BEGIN
    
     delete cecred.crapseg w
      where w.cdcooper = rw_principal.cdcooper_
        and w.nrdconta = rw_principal.nrdconta_
        and w.nrctrseg = rw_principal.nrctrseg_;
        
     delete cecred.crawseg w
      where w.cdcooper = rw_principal.cdcooper
        and w.nrdconta = rw_principal.nrdconta
        and w.nrctrseg = rw_principal.nrctrseg
        and w.nrctrato = rw_principal.nrctrato;
      null;
    
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        EXIT;
      WHEN OTHERS THEN
        CECRED.pc_internal_exception;
        vr_dscritic := 'Erro na leitura do arquivo. ' || sqlerrm;
        RAISE vr_exc_saida;
    END;
  
    IF vcount = 1000 THEN
      COMMIT;
    ELSE
      vcount := vcount + 1;
    END IF;
  END LOOP;  

  COMMIT;
  CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq, ' COMMIT;');
  CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq, ' END; ');
  CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq, '/ ');
  CECRED.GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arq);
EXCEPTION
  WHEN vr_exc_saida THEN
    vr_dscritic := vr_dscritic || ' ' || SQLERRM ||
                   DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
    dbms_output.put_line(vr_dscritic);
    CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq, vr_dscritic);
    ROLLBACK;
  WHEN OTHERS THEN
    vr_dscritic := vr_dscritic || ' ' || SQLERRM ||
                   DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
    dbms_output.put_line(vr_dscritic);
    CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq, vr_dscritic);
    ROLLBACK;
END;
