declare
  pr_cdcritic PLS_INTEGER;
  pr_dscritic VARCHAR2(500);
  pr_retxml   XMLType;
  pr_nmdcampo VARCHAR2(500);
  pr_des_erro VARCHAR2(500);

begin
  for i in (SELECT p.idseqtra
              ,p.cdcooper
              ,p.nrdconta
              ,ass.cdagenci
              ,p.nrctrseg
              ,p.nrcpfcgc
              ,p.nmprimtl
              ,p.dtinivig
              ,p.nrctremp
              ,p.vlprodut
              ,p.dtrefcob
              ,p.vlsdeved
              ,p.vldevatu
              ,p.dtfimvig
              ,c.dtmvtolt data_emp
              ,p.nrproposta
              ,lpad(decode(p.cdcooper , 5,1, 7,2, 10,3, 11,4, 14,5, 9,6, 16,7, 2,8, 8,9, 6,10, 12,11, 13,12, 1,13 ) ,6,'0') cdcooperativa
              ,ADD_MONTHS(c.dtmvtolt, c.qtpreemp) dtfimctr
              ,DECODE(ass.inpessoa,1,'FISICA',2,'JURIDICA') dspessoa
              ,c.vlpreemp
              ,p.tpcustei
         FROM tbseg_prestamista p, crapepr c, crapass ass, craplau x
         WHERE p.cdcooper = 1    
           AND c.cdcooper = p.cdcooper
           AND c.nrdconta = p.nrdconta
           AND c.nrctremp = p.nrctremp             
           AND ass.cdcooper = c.cdcooper
           AND ass.nrdconta = c.nrdconta             
           AND p.tpcustei = 0
           AND p.tpregist <> 0
           AND p.nrdconta = x.nrdconta
           AND x.cdcooper = p.cdcooper
           AND x.nrctremp = p.nrctremp
           AND x.cdseqtel = p.nrproposta
           AND x.insitlau in (1,3)
           AND x.cdhistor = 3651) loop
  
    tela_atenda_seguro. pc_atualiza_dados_prest(i.cdcooper,
                                                i.nrdconta,
                                                i.nrctremp,
                                                i.flggarad,
                                                i.flgassum,
                                                0,
                                                null,
                                                pr_cdcritic,
                                                pr_dscritic,
                                                pr_retxml,
                                                pr_nmdcampo,
                                                pr_des_erro);
  
    for s in (select w.vlseguro, w.vlpremio
                from crawseg w
               where w.progress_recid = i.progress_recid) loop
      update tbseg_prestamista p
         set p.vlprodut = s.vlpremio,
             p.vlsdeved = s.vlseguro,
             p.vldevatu = s.vlseguro
       where p.idseqtra = i.idseqtra;
      commit;
    end loop;
  end loop;
end;
/
