DECLARE

  CURSOR cr_crapseg IS
    SELECT s.*, t.nrproposta, t.nrtelefo, t.cdsexotl, t.dtnasctl, t.nrctremp, t.nrcpfcgc, t.nrcepend, t.cdufresd, t.nmcidade, t.nmbairro, t.dsendres, t.nmprimtl, t.vlprodut
      FROM cecred.crapseg s,
           cecred.tbseg_prestamista t
     WHERE s.cdcooper = t.cdcooper
       AND s.nrdconta = t.nrdconta
       AND s.nrctrseg = t.nrctrseg
       AND t.cdcooper = 1
       AND t.nrdconta = 96064560
       AND t.nrctrseg = 699675
       AND t.nrctremp = 1199933;      
  rw_crapseg cr_crapseg%ROWTYPE;
   
BEGIN
  
  OPEN cr_crapseg;
  FETCH cr_crapseg INTO rw_crapseg;
  IF cr_crapseg%FOUND THEN
    
    INSERT INTO cecred.crawseg(dtmvtolt,
                               nrdconta,
                               nrctrseg,
                               tpseguro,
                               nmdsegur,
                               tpplaseg,
                               nrcadast,
                               dsendres,
                               nmbairro,
                               nmcidade,
                               cdufresd,
                               nrcepend,
                               dtinivig,
                               dtfimvig,
                               flgdutil,
                               vlpreseg,
                               vlseguro,
                               cdsegura,
                               nmempres,
                               dtdebito,
                               dtiniseg,
                               lsctrant,
                               nrcpfcgc,
                               nrctratu,
                               flgunica,
                               nrctrato,
                               dtprideb,
                               vldifseg,
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
                       VALUES (rw_crapseg.dtmvtolt,
                               rw_crapseg.nrdconta,
                               rw_crapseg.nrctrseg,
                               rw_crapseg.tpseguro,
                               rw_crapseg.nmprimtl,
                               rw_crapseg.tpplaseg,
                               rw_crapseg.nrdconta,
                               rw_crapseg.dsendres,
                               rw_crapseg.nmbairro,
                               rw_crapseg.nmcidade,
                               rw_crapseg.cdufresd,
                               rw_crapseg.nrcepend,
                               rw_crapseg.dtinivig,
                               rw_crapseg.dtfimvig,
                               1,
                               rw_crapseg.vlpreseg,
                               rw_crapseg.vlslddev,
                               rw_crapseg.cdsegura,
                               'EMPRESAS DIVERSAS',
                               rw_crapseg.dtdebito,
                               rw_crapseg.dtiniseg,
                               rw_crapseg.lsctrant,
                               rw_crapseg.nrcpfcgc,
                               rw_crapseg.nrctratu,
                               rw_crapseg.flgunica,
                               rw_crapseg.nrctremp,
                               rw_crapseg.dtprideb,
                               rw_crapseg.vldifseg,
                               0,
                               0,
                               1,
                               rw_crapseg.dtnasctl,
                               rw_crapseg.cdsexotl,
                               rw_crapseg.vlprodut,
                               rw_crapseg.qtparcel,
                               rw_crapseg.nrtelefo,
                               null,
                               null,
                               0,
                               rw_crapseg.tpdpagto,
                               rw_crapseg.cdcooper,
                               rw_crapseg.flgconve,
                               null,
                               rw_crapseg.nrproposta,
                               0,
                               0,
                               1,
                               0,
                               0,
                               0);
     
  COMMIT;   
  
  UPDATE cecred.crawseg w
     SET w.nrproposta = rw_crapseg.nrproposta
   WHERE cdcooper = rw_crapseg.cdcooper
     AND nrdconta = rw_crapseg.nrdconta
     AND nrctrseg = rw_crapseg.nrctrseg
     AND nrctrato = rw_crapseg.nrctremp;
  
  UPDATE cecred.crapseg s
     SET s.vlpremio = rw_crapseg.vlprodut
   WHERE cdcooper = rw_crapseg.cdcooper
     AND nrdconta = rw_crapseg.nrdconta
     AND nrctrseg = rw_crapseg.nrctrseg;
     
  
  COMMIT;
  END IF;
  CLOSE cr_crapseg;

END;
