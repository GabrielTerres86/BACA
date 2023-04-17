declare

  vr_nrctrseg   cecred.crawseg.nrctrseg%TYPE;
  vr_nrproposta cecred.crawseg.nrproposta%TYPE;
  vr_exc_saida  EXCEPTION;
  vr_nrseqdig   NUMERIC(15);
  vr_nrsequen   NUMBER(10);

  CURSOR cr_crawseg IS
    SELECT * 
      FROM CECRED.crawseg W
     WHERE (w.cdcooper,w.nrdconta,w.nrctrato,w.nrctrseg) IN ((1,9417389,2047137,1146656),
                                                             (1,9417389,2506563,1146657));
  rw_crawseg cr_crawseg%ROWTYPE;
  
  CURSOR cr_crapseg(pr_cdcooper in cecred.crapseg.cdcooper%TYPE,
                    pr_nrdconta in cecred.crapseg.nrdconta%TYPE,
                    pr_nrctrseg in cecred.crapseg.nrctrseg%TYPE) IS
    SELECT * 
      FROM CECRED.crapseg s
     WHERE s.cdcooper = pr_cdcooper
       AND s.nrdconta = pr_nrdconta
       AND s.nrctrseg = pr_nrctrseg;
  rw_crapseg cr_crapseg%ROWTYPE;
  
  CURSOR cr_tbseg_prestamista(pr_cdcooper in cecred.tbseg_prestamista.cdcooper%TYPE,
                              pr_nrdconta in cecred.tbseg_prestamista.nrdconta%TYPE,
                              pr_nrctremp in cecred.tbseg_prestamista.nrctremp%TYPE,
                              pr_nrctrseg in cecred.tbseg_prestamista.nrctrseg%TYPE) IS
    SELECT * 
      FROM CECRED.tbseg_prestamista p
     WHERE p.cdcooper = pr_cdcooper
       AND p.nrdconta = pr_nrdconta
       AND p.nrctremp = pr_nrctremp
       AND p.nrctrseg = pr_nrctrseg;
  rw_tbseg_prestamista cr_tbseg_prestamista%ROWTYPE; 
  
  CURSOR cr_crappep(pr_cdcooper in cecred.crappep.cdcooper%TYPE,
                    pr_nrdconta in cecred.crappep.nrdconta%TYPE,
                    pr_nrctremp in cecred.crappep.nrctremp%TYPE) IS
                     
    SELECT MAX(dtvencto) dtfimvig 
      FROM cecred.crappep 
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta 
       AND nrctremp = pr_nrctremp;   
  rw_crappep cr_crappep%ROWTYPE;   
  
  CURSOR cr_crapris IS
    SELECT SUM(j.vldivida) saldo
      FROM CECRED.crapris j
     WHERE j.cdcooper = 1
       AND j.nrdconta = 9417389
       AND j.nrctremp IN (2047137,2506563)
       AND j.dtrefere = TO_DATE('31/01/2023','DD/MM/RRRR');
  rw_crapris cr_crapris%ROWTYPE; 
  
  
  CURSOR cr_saldo(pr_cdcooper in cecred.crapris.cdcooper%TYPE,
                  pr_nrdconta in cecred.crapris.nrdconta%TYPE,
                  pr_nrctremp in cecred.crapris.nrctremp%TYPE) IS
    SELECT SUM(j.vldivida) saldo
      FROM CECRED.crapris j
     WHERE j.cdcooper = pr_cdcooper
       AND j.nrdconta = pr_nrdconta
       AND j.nrctremp = pr_nrctremp
       AND j.dtrefere = TO_DATE('31/01/2023','DD/MM/RRRR');
  rw_saldo cr_saldo%ROWTYPE;        
 
BEGIN           
 
 FOR rw_crawseg IN cr_crawseg LOOP
 
   
   vr_nrproposta := CECRED.SEGU0003.FN_NRPROPOSTA(pr_tpcustei => rw_crawseg.tpcustei,
                                                  pr_cdcooper => rw_crawseg.cdcooper,
                                                  pr_nrdconta => rw_crawseg.nrdconta,
                                                  pr_nrctrseg => rw_crawseg.nrctrseg);
 
   
   cecred.pc_sequence_progress(pr_nmtabela => 'CRAPMAT'
                              ,pr_nmdcampo => 'NRCTRSEG'
                              ,pr_dsdchave => 1
                              ,pr_flgdecre => 'N'
                              ,pr_sequence => vr_nrctrseg);
                              
   OPEN cr_crappep(pr_cdcooper => rw_crawseg.cdcooper,
                   pr_nrdconta => rw_crawseg.nrdconta,
                   pr_nrctremp => rw_crawseg.nrctrato);
   FETCH cr_crappep INTO rw_crappep;
   CLOSE cr_crappep;
   
   OPEN cr_crapris;
   FETCH cr_crapris INTO rw_crapris;
   CLOSE cr_crapris;
   
   OPEN cr_saldo(pr_cdcooper => rw_crawseg.cdcooper,
                 pr_nrdconta => rw_crawseg.nrdconta,
                 pr_nrctremp => rw_crawseg.nrctrato);
   FETCH cr_saldo INTO rw_saldo;
   CLOSE cr_saldo;
   
   INSERT INTO CECRED.crawseg(dtmvtolt,
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
                              nrproposta,
                              flggarad,
                              flgassum,
                              tpcustei,
                              tpmodali,
                              flfinanciasegprestamista,
                              flgsegma)
                       values(to_date('01/09/2022','dd/mm/yyyy'),
                              rw_crawseg.nrdconta,
                              vr_nrctrseg,
                              rw_crawseg.tpseguro,
                              rw_crawseg.nmdsegur,
                              rw_crawseg.tpplaseg,
                              rw_crawseg.nmbenefi,
                              rw_crawseg.nrcadast,
                              rw_crawseg.nmdsecao,
                              rw_crawseg.dsendres,
                              rw_crawseg.nrendres,
                              rw_crawseg.nmbairro,
                              rw_crawseg.nmcidade,
                              rw_crawseg.cdufresd,
                              rw_crawseg.nrcepend,
                              to_date('01/09/2022','dd/mm/yyyy'),
                              rw_crappep.dtfimvig,
                              rw_crawseg.dsmarvei,
                              rw_crawseg.dstipvei,
                              rw_crawseg.nranovei,
                              rw_crawseg.nrmodvei,
                              rw_crawseg.qtpasvei,
                              rw_crawseg.ppdbonus,
                              rw_crawseg.flgdnovo,
                              rw_crawseg.nrapoant,
                              rw_crawseg.nmsegant,
                              rw_crawseg.flgdutil,
                              rw_crawseg.flgnotaf,
                              rw_crawseg.flgapant,
                              rw_crawseg.vlpreseg,
                              rw_crapris.saldo,
                              rw_crawseg.vldfranq,
                              rw_crawseg.vldcasco,
                              rw_crawseg.vlverbae,
                              rw_crawseg.flgassis,
                              rw_crawseg.vldanmat,
                              rw_crawseg.vldanpes,
                              rw_crawseg.vldanmor,
                              rw_crawseg.vlappmor,
                              rw_crawseg.vlappinv,
                              rw_crawseg.cdsegura,
                              rw_crawseg.nmempres,
                              rw_crawseg.dschassi,
                              rw_crawseg.flgrenov,
                              to_date('01/09/2022','dd/mm/yyyy'),
                              rw_crawseg.vlbenefi,
                              rw_crawseg.cdcalcul,
                              rw_crawseg.flgcurso,
                              to_date('01/09/2022','dd/mm/yyyy'),
                              rw_crawseg.nrdplaca,
                              rw_crawseg.lsctrant,
                              rw_crawseg.nrcpfcgc,
                              rw_crawseg.nrctratu,
                              rw_crawseg.nmcpveic,
                              rw_crawseg.flgunica,
                              rw_crawseg.nrctrato,
                              rw_crawseg.flgvisto,
                              rw_crawseg.cdapoant,
                              to_date('01/09/2022','dd/mm/yyyy'),
                              rw_crawseg.vldifseg,
                              rw_crawseg.dscobext##1,
                              rw_crawseg.dscobext##2,
                              rw_crawseg.dscobext##3,
                              rw_crawseg.dscobext##4,
                              rw_crawseg.dscobext##5,
                              rw_crawseg.vlcobext##1,
                              rw_crawseg.vlcobext##2,
                              rw_crawseg.vlcobext##3,
                              rw_crawseg.vlcobext##4,
                              rw_crawseg.vlcobext##5,
                              rw_crawseg.flgrepgr,
                              rw_crawseg.vlfrqobr,
                              rw_crawseg.tpsegvid,
                              rw_crawseg.dtnascsg,
                              rw_crawseg.cdsexosg,
                              rw_crawseg.vlpremio,
                              rw_crawseg.qtparcel,
                              rw_crawseg.nrfonemp,
                              rw_crawseg.nrfonres,
                              rw_crawseg.dsoutgar,
                              rw_crawseg.vloutgar,
                              rw_crawseg.tpdpagto,
                              rw_crawseg.cdcooper,
                              rw_crawseg.flgconve,
                              rw_crawseg.complend,
                              vr_nrproposta,
                              rw_crawseg.flggarad,
                              rw_crawseg.flgassum,
                              rw_crawseg.tpcustei,
                              rw_crawseg.tpmodali,
                              rw_crawseg.flfinanciasegprestamista,
                              rw_crawseg.flgsegma);
    
   COMMIT;
  
   OPEN cr_crapseg(pr_cdcooper => rw_crawseg.cdcooper,
                   pr_nrdconta => rw_crawseg.nrdconta,
                   pr_nrctrseg => rw_crawseg.nrctrseg);
   FETCH cr_crapseg INTO rw_crapseg;
   
   IF cr_crapseg%FOUND THEN
   
     vr_nrseqdig := cecred.fn_sequence('CRAPLOT'
                                      ,'NRSEQDIG'
                                      ,1||';'||rw_crapseg.cdagenci||';'||'900;'||rw_crapseg.nrdolote); 
   
     INSERT INTO CECRED.crapseg(nrdconta,
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
                         VALUES(rw_crapseg.nrdconta,
                                vr_nrctrseg,
                                to_date('01/09/2022','dd/mm/yyyy'),
                                rw_crappep.dtfimvig,
                                to_date('01/09/2022','dd/mm/yyyy'),
                                rw_crapseg.cdagenci,
                                rw_crapseg.cdbccxlt,
                                1,
                                rw_crapseg.dtaltseg,
                                null,
                                to_date('01/09/2022','dd/mm/yyyy'),
                                to_date('01/09/2022','dd/mm/yyyy'),
                                rw_crapseg.indebito,
                                rw_crapseg.nrdolote,
                                vr_nrseqdig,
                                rw_crapseg.qtprepag,
                                rw_crapseg.vlprepag,
                                rw_crapseg.vlpreseg,
                                to_date('01/09/2022','dd/mm/yyyy'),
                                rw_crapseg.tpseguro,
                                rw_crapseg.tpplaseg,
                                rw_crapseg.qtprevig,
                                rw_crapseg.cdsegura,
                                rw_crapseg.lsctrant,
                                rw_crapseg.nrctratu,
                                rw_crapseg.flgunica,
                                to_date('01/09/2022','dd/mm/yyyy'),
                                rw_crapseg.vldifseg,
                                rw_crapseg.nmbenvid##1,
                                rw_crapseg.nmbenvid##2,
                                rw_crapseg.nmbenvid##3,
                                rw_crapseg.nmbenvid##4,
                                rw_crapseg.nmbenvid##5,
                                rw_crapseg.dsgraupr##1,
                                rw_crapseg.dsgraupr##2,
                                rw_crapseg.dsgraupr##3,
                                rw_crapseg.dsgraupr##4,
                                rw_crapseg.dsgraupr##5,
                                rw_crapseg.txpartic##1,
                                rw_crapseg.txpartic##2,
                                rw_crapseg.txpartic##3,
                                rw_crapseg.txpartic##4,
                                rw_crapseg.txpartic##5,
                                to_date('01/09/2022','dd/mm/yyyy'),
                                rw_crapseg.cdoperad,
                                rw_crapseg.vlpremio,
                                rw_crapseg.qtparcel,
                                rw_crapseg.tpdpagto,
                                rw_crapseg.cdcooper,
                                rw_crapseg.flgconve,
                                rw_crapseg.flgclabe,
                                null,
                                rw_crapseg.tpendcor,
                                rw_crapseg.cdopecnl,
                                rw_crapseg.dtrenova,
                                rw_crapseg.cdopeori,
                                rw_crapseg.cdageori,
                                to_date('01/09/2022','dd/mm/yyyy'),
                                rw_crapseg.cdopeexc,
                                rw_crapseg.cdageexc,
                                rw_crapseg.dtinsexc,
                                rw_crapris.saldo,
                                rw_crapseg.idimpdps);
     COMMIT;
   END IF;
   CLOSE cr_crapseg;
   
   OPEN cr_tbseg_prestamista(pr_cdcooper => rw_crawseg.cdcooper,
                             pr_nrdconta => rw_crawseg.nrdconta,
                             pr_nrctremp => rw_crawseg.nrctrato,
                             pr_nrctrseg => rw_crawseg.nrctrseg);
                             
   FETCH cr_tbseg_prestamista INTO rw_tbseg_prestamista;
   
   IF cr_tbseg_prestamista%FOUND THEN
     vr_nrsequen := cecred.fn_sequence('TBSEG_PRESTAMISTA', 'SEQCERTIFICADO', 0);
     
     INSERT INTO CECRED.tbseg_prestamista(cdcooper,
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
                                   values(rw_tbseg_prestamista.cdcooper,
                                          rw_tbseg_prestamista.nrdconta,
                                          vr_nrctrseg,
                                          rw_tbseg_prestamista.nrctremp,
                                          1,
                                          vr_nrsequen,
                                          rw_tbseg_prestamista.nrcpfcgc,
                                          rw_tbseg_prestamista.nmprimtl,
                                          rw_tbseg_prestamista.dtnasctl,
                                          rw_tbseg_prestamista.cdsexotl,
                                          rw_tbseg_prestamista.dsendres,
                                          rw_tbseg_prestamista.dsdemail,
                                          rw_tbseg_prestamista.nmbairro,
                                          rw_tbseg_prestamista.nmcidade,
                                          rw_tbseg_prestamista.cdufresd,
                                          rw_tbseg_prestamista.nrcepend,
                                          rw_tbseg_prestamista.nrtelefo,
                                          rw_tbseg_prestamista.dtdevend,
                                          to_date('01/09/2022','dd/mm/yyyy'),
                                          rw_tbseg_prestamista.cdcobran,
                                          rw_tbseg_prestamista.cdadmcob,
                                          rw_tbseg_prestamista.tpfrecob,
                                          rw_tbseg_prestamista.tpsegura,
                                          rw_tbseg_prestamista.cdprodut,
                                          rw_tbseg_prestamista.cdplapro,
                                          rw_tbseg_prestamista.vlprodut,
                                          rw_tbseg_prestamista.tpcobran,
                                          rw_tbseg_prestamista.vlsdeved,
                                          rw_saldo.saldo,
                                          to_date('01/09/2022','dd/mm/yyyy'),
                                          rw_crappep.dtfimvig,
                                          to_date('01/09/2022','dd/mm/yyyy'),
                                          vr_nrproposta,
                                          null,
                                          null,
                                          null,
                                          rw_tbseg_prestamista.situacao,
                                          rw_tbseg_prestamista.tpcustei,
                                          rw_tbseg_prestamista.pemorte,
                                          rw_tbseg_prestamista.peinvalidez,
                                          rw_tbseg_prestamista.peiftttaxa,
                                          rw_tbseg_prestamista.qtifttdias,
                                          rw_tbseg_prestamista.nrapolice,
                                          rw_tbseg_prestamista.qtparcel,
                                          rw_tbseg_prestamista.vlpielimit,
                                          rw_tbseg_prestamista.vlifttlimi,
                                          rw_tbseg_prestamista.dsprotocolo,
                                          rw_tbseg_prestamista.flfinanciasegprestamista);
   
     COMMIT;
     
     UPDATE cecred.crawseg
        SET nrproposta = vr_nrproposta
      WHERE cdcooper = rw_crawseg.cdcooper
        AND nrdconta = rw_crawseg.nrdconta
        AND nrctrato = rw_crawseg.nrctrato
        AND nrctrseg = vr_nrctrseg;
     
    COMMIT; 
   END IF;
   CLOSE cr_tbseg_prestamista;
 END LOOP;
  
end;
/
