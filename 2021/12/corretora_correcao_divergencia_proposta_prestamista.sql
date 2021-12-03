DECLARE
  vr_nrproposta      VARCHAR2(30);
  vr_dscritic        VARCHAR2(1000);
  vr_exc_saida       EXCEPTION;  
  
  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros|| 'cpd/bacas/INC0110769';

  -- Arquivo de rollback
  vr_nmarqimp        VARCHAR2(100)  := 'INC0110769_ROLLBACK.txt';     
  vr_ind_arquiv      utl_file.file_type;
  
  CURSOR cr_crapop IS
    SELECT cop.cdcooper
      FROM crapcop cop
		 WHERE cop.flgativo = 1
       AND cop.cdcooper <> 3;
  
  CURSOR cr_prestamista(pr_cdcooper tbseg_prestamista.cdcooper%TYPE) IS
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
       
  CURSOR cr_crapseg(pr_cdcooper crapseg.cdcooper%TYPE
                   ,pr_nrdconta crapseg.nrdconta%TYPE
                   ,pr_nrctrseg crapseg.nrctrseg%TYPE) IS 
    SELECT c.*
      FROM crapseg c
     WHERE c.cdcooper = pr_cdcooper
       AND c.nrdconta = pr_nrdconta
       AND c.nrctrseg = pr_nrctrseg;
BEGIN
  --Criar arquivo de Roll Back
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp        --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv      --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
    RAISE vr_exc_saida;
  END IF;
  
  FOR rw_crapop IN cr_crapop LOOP
    FOR rw_prestamista IN cr_prestamista(pr_cdcooper => rw_crapop.cdcooper) LOOP                
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
           WHERE w.progress_recid = rw_prestamista.progress_recid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic:= 'Erro ao gravar numero de proposta 1: '||rw_prestamista.nrproposta || ' progress_recid: ' || rw_prestamista.progress_recid ||' - '||SQLERRM;
            RAISE vr_exc_saida;              
        END;
        COMMIT;   
    END LOOP;
  END LOOP;
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'COMMIT;');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
  vr_dscritic := 'Registro atualizado com sucesso!';
  dbms_output.put_line(vr_dscritic);
EXCEPTION
  WHEN vr_exc_saida THEN 
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
    vr_dscritic := 'ERRO ' || vr_dscritic;
    dbms_output.put_line(vr_dscritic);
    ROLLBACK;
END; 
/
