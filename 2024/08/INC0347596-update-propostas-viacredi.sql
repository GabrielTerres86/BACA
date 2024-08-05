DECLARE

  vr_nrctrseg cecred.crawseg.nrctrseg%TYPE;
  vr_nrsequen cecred.tbseg_prestamista.cdapolic%TYPE;

BEGIN

UPDATE cecred.crawseg w
   SET w.vlpremio = 0.01,
       w.dtfimvig = TO_DATE('27/01/2023','dd/mm/yyyy')
 WHERE cdcooper = 1
   AND nrdconta = 91189896
   AND nrctrseg = 782569
   AND nrctrato = 1968974
   AND tpseguro = 4;
   
UPDATE cecred.crapseg s
   SET s.vlpremio = 0.01,
       s.dtfimvig = TO_DATE('27/01/2023','dd/mm/yyyy')
 WHERE cdcooper = 1
   AND nrdconta = 91189896
   AND nrctrseg = 782569
   AND tpseguro = 4; 
   
UPDATE cecred.tbseg_prestamista p
   SET p.vlprodut = 0.01,
       p.vldevatu = 0.01,
       p.nrproposta = '770354540711',
       p.dtfimvig = TO_DATE('27/01/2023','dd/mm/yyyy')
 WHERE cdcooper = 1
   AND nrdconta = 91189896
   AND nrctrseg = 782569
   AND nrctremp = 1968974;  
   
COMMIT;

UPDATE cecred.crawseg w
   SET w.vlpremio = 0.01,
       w.dtinivig = TO_DATE('31/01/2022','dd/mm/yyyy'),
       w.dtfimvig = TO_DATE('22/04/2022','dd/mm/yyyy')
 WHERE cdcooper = 1
   AND nrdconta = 91189896
   AND nrctrseg = 748359
   AND nrctrato = 2189832
   AND tpseguro = 4;
   
UPDATE cecred.crapseg s
   SET s.vlpremio = 0.01,
       s.dtinivig = TO_DATE('31/01/2022','dd/mm/yyyy'),
       s.dtfimvig = TO_DATE('22/04/2022','dd/mm/yyyy'),
       s.dtcancel = TO_DATE('21/03/2022','dd/mm/yyyy')
 WHERE cdcooper = 1
   AND nrdconta = 91189896
   AND nrctrseg = 748359
   AND s.tpseguro = 4;
   
vr_nrsequen := cecred.fn_sequence('TBSEG_PRESTAMISTA', 'SEQCERTIFICADO', 0);   
   
insert into cecred.tbseg_prestamista (CDCOOPER, NRDCONTA, NRCTRSEG, NRCTREMP, TPREGIST, CDAPOLIC, NRCPFCGC, NMPRIMTL, DTNASCTL, CDSEXOTL, DSENDRES, DSDEMAIL, NMBAIRRO, NMCIDADE, CDUFRESD, NRCEPEND, NRTELEFO, DTDEVEND, DTINIVIG, CDCOBRAN, CDADMCOB, TPFRECOB, TPSEGURA, CDPRODUT, CDPLAPRO, VLPRODUT, TPCOBRAN, VLSDEVED, VLDEVATU, DTREFCOB, DTFIMVIG, DTDENVIO, NRPROPOSTA, TPRECUSA, CDMOTREC, DTRECUSA, SITUACAO, TPCUSTEI, PEMORTE, PEINVALIDEZ, PEIFTTTAXA, QTIFTTDIAS, NRAPOLICE, QTPARCEL, VLPIELIMIT, VLIFTTLIMI, DSPROTOCOLO, FLFINANCIASEGPRESTAMISTA)
values (1, 91189896, 748359, 2189832, 0, vr_nrsequen, 1644740990, 'ROBERTO DOS SANTOS', to_date('27-01-1977', 'dd-mm-yyyy'), 1, 'RUA CARLOS ALBERTO MAYER', 'betoosy@gmail.com', 'BARRA DO RIO', 'ITAJAI', 'SC', '88305580', '47999130651', to_date('31-01-2022', 'dd-mm-yyyy'), to_date('31-01-2022', 'dd-mm-yyyy'), 10, null, 'M', 'MI', 'BCV012', 1, 0.01, 'O', 41234.49, 0.01, to_date('28-02-2022', 'dd-mm-yyyy'), to_date('22-04-2022', 'dd-mm-yyyy'), to_date('31-01-2022', 'dd-mm-yyyy'), '770354540720', null, null, null, null, 1, null, null, null, null, '000000077001006', null, null, null, null, 0);
   
COMMIT;

cecred.pc_sequence_progress(pr_nmtabela => 'CRAPMAT'
                           ,pr_nmdcampo => 'NRCTRSEG'
                           ,pr_dsdchave => 1
                           ,pr_flgdecre => 'N'
                           ,pr_sequence => vr_nrctrseg);
   
insert into cecred.crawseg (DTMVTOLT, NRDCONTA, NRCTRSEG, TPSEGURO, NMDSEGUR, TPPLASEG, NMBENEFI, NRCADAST, NMDSECAO, DSENDRES, NRENDRES, NMBAIRRO, NMCIDADE, CDUFRESD, NRCEPEND, DTINIVIG, DTFIMVIG, DSMARVEI, DSTIPVEI, NRANOVEI, NRMODVEI, QTPASVEI, PPDBONUS, FLGDNOVO, NRAPOANT, NMSEGANT, FLGDUTIL, FLGNOTAF, FLGAPANT, VLPRESEG, VLSEGURO, VLDFRANQ, VLDCASCO, VLVERBAE, FLGASSIS, VLDANMAT, VLDANPES, VLDANMOR, VLAPPMOR, VLAPPINV, CDSEGURA, NMEMPRES, DSCHASSI, FLGRENOV, DTDEBITO, VLBENEFI, CDCALCUL, FLGCURSO, DTINISEG, NRDPLACA, LSCTRANT, NRCPFCGC, NRCTRATU, NMCPVEIC, FLGUNICA, NRCTRATO, FLGVISTO, CDAPOANT, DTPRIDEB, VLDIFSEG, DSCOBEXT##1, DSCOBEXT##2, DSCOBEXT##3, DSCOBEXT##4, DSCOBEXT##5, VLCOBEXT##1, VLCOBEXT##2, VLCOBEXT##3, VLCOBEXT##4, VLCOBEXT##5, FLGREPGR, VLFRQOBR, TPSEGVID, DTNASCSG, CDSEXOSG, VLPREMIO, QTPARCEL, NRFONEMP, NRFONRES, DSOUTGAR, VLOUTGAR, TPDPAGTO, CDCOOPER, FLGCONVE, COMPLEND, NRPROPOSTA, FLGGARAD, FLGASSUM, TPCUSTEI, TPMODALI, FLFINANCIASEGPRESTAMISTA, FLGSEGMA, NMSOCIAL_SEGURADO)
values (to_date('14-06-2021', 'dd-mm-yyyy'), 91189896, vr_nrctrseg, 4, 'ROBERTO DOS SANTOS', 1, null, 0, null, 'RUA CARLOS ALBERTO MAYER', 90, 'BARRA DO RIO', 'ITAJAI', 'SC', 88305000, to_date('14-06-2021', 'dd-mm-yyyy'), to_date('22-04-2022', 'dd-mm-yyyy'), null, null, 0, 0, 0, 0.00, 0, 0, null, 1, 0, 0, 0.00, 2743.59, 0.00, 0.00, 0.00, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 514, 'EMPRESAS DIVERSAS', null, 0, to_date('14-06-2021', 'dd-mm-yyyy'), 0.00, 0, 0, to_date('14-06-2021', 'dd-mm-yyyy'), null, null, '1644740990', 0, null, 0, 2189832, 0, null, to_date('14-06-2021', 'dd-mm-yyyy'), 0.00, null, null, null, null, null, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0.00, 1, to_date('26-08-1977', 'dd-mm-yyyy'), 1, 0.48, 0, null, null, null, 0.00, 0, 1, 0, 'PROXIMO DO SENAI', '770354142635', 0, 0, 1, 0, 0, 0, null);
 
insert into cecred.crapseg (NRDCONTA, NRCTRSEG, DTINIVIG, DTFIMVIG, DTMVTOLT, CDAGENCI, CDBCCXLT, CDSITSEG, DTALTSEG, DTCANCEL, DTDEBITO, DTINISEG, INDEBITO, NRDOLOTE, NRSEQDIG, QTPREPAG, VLPREPAG, VLPRESEG, DTULTPAG, TPSEGURO, TPPLASEG, QTPREVIG, CDSEGURA, LSCTRANT, NRCTRATU, FLGUNICA, DTPRIDEB, VLDIFSEG, NMBENVID##1, NMBENVID##2, NMBENVID##3, NMBENVID##4, NMBENVID##5, DSGRAUPR##1, DSGRAUPR##2, DSGRAUPR##3, DSGRAUPR##4, DSGRAUPR##5, TXPARTIC##1, TXPARTIC##2, TXPARTIC##3, TXPARTIC##4, TXPARTIC##5, DTULTALT, CDOPERAD, VLPREMIO, QTPARCEL, TPDPAGTO, CDCOOPER, FLGCONVE, FLGCLABE, CDMOTCAN, TPENDCOR, CDOPECNL, DTRENOVA, CDOPEORI, CDAGEORI, DTINSORI, CDOPEEXC, CDAGEEXC, DTINSEXC, VLSLDDEV, IDIMPDPS)
values (91189896, vr_nrctrseg, to_date('14-06-2021', 'dd-mm-yyyy'), to_date('22-04-2022', 'dd-mm-yyyy'), to_date('14-06-2021', 'dd-mm-yyyy'), 90, 0, 2, null, to_date('25-08-2021', 'dd-mm-yyyy'), to_date('14-06-2021', 'dd-mm-yyyy'), to_date('14-06-2021', 'dd-mm-yyyy'), 0, 0, vr_nrctrseg, 0, 0.00, 0.00, to_date('14-06-2021', 'dd-mm-yyyy'), 4, 1, 0, 514, null, 0, 0, to_date('14-06-2021', 'dd-mm-yyyy'), 0.00, ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 0.00, 0.00, 0.00, 0.00, 0.00, null, '1', 0.48, 0, 0, 1, 0, 0, 0, 1, ' ', null, '1', 90, to_date('14-06-2021 11:18:57', 'dd-mm-yyyy hh24:mi:ss'), ' ', 0, null, 2743.59, 0);
   
UPDATE cecred.tbseg_prestamista p
   SET p.vlprodut = 0.48,
       p.vldevatu = 0.01,
       p.vlsdeved = 2743.59,
       p.dtfimvig = TO_DATE('22/04/2022','dd/mm/yyyy'),
       p.nrctrseg = vr_nrctrseg
 WHERE cdcooper = 1
   AND nrdconta = 91189896
   AND nrctrseg = 748358
   AND nrctremp = 2189832;  
   
UPDATE cecred.crawseg w
   SET nrproposta = '770354142635'
 WHERE cdcooper = 1
   AND nrdconta = 91189896
   AND nrctrseg = vr_nrctrseg
   AND nrctrato = 2189832
   AND tpseguro = 4; 
          
COMMIT;
 
UPDATE cecred.crawseg w
   SET w.vlpremio = 5.47,
       w.vlseguro = 31500,
       w.dtfimvig = TO_DATE('15/06/2024','dd/mm/yyyy'),
       w.nrproposta = '770354142627'
 WHERE cdcooper = 1
   AND nrdconta = 91189896
   AND nrctrseg = 748358
   AND nrctrato = 4083633
   AND tpseguro = 4;
   
UPDATE cecred.crapseg s
   SET s.vlpremio = 5.47,
       s.vlslddev = 31500,
       s.dtfimvig = TO_DATE('15/06/2024','dd/mm/yyyy'),
       s.dtcancel = TO_DATE('25/08/2021','dd/mm/yyyy')
 WHERE cdcooper = 1
   AND nrdconta = 91189896
   AND nrctrseg = 748358
   AND tpseguro = 4; 
   
UPDATE cecred.tbseg_prestamista p
   SET p.vlprodut = 5.47,
       p.vldevatu = 31193.99,
       p.nrproposta = '770354142627',
       p.dtfimvig = TO_DATE('15/06/2024','dd/mm/yyyy')
 WHERE cdcooper = 1
   AND nrdconta = 91189896
   AND nrctrseg = 748358
   AND nrctremp = 4083633; 


COMMIT;
   
END;   
   

   
   
   
