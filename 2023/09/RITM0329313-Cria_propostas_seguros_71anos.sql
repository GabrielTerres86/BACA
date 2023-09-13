declare
  vr_nrctrseg   cecred.crawseg.nrctrseg%TYPE;
  vr_nrproposta cecred.crawseg.nrproposta%TYPE;
  vr_exc_saida  EXCEPTION;
  vr_nrseqdig   NUMERIC(15);
  vr_nrsequen   NUMBER(10);
  vr_nmdir      VARCHAR2(4000) := CECRED.gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/RITM0329313';
  vr_nmarq      VARCHAR2(100)  := 'ROLLBACK_RITM0329313.sql';
  vr_ind_arq    utl_file.file_type;
  vr_linha      VARCHAR2(32767);
  vr_dscritic   VARCHAR2(2000);

  CURSOR cr_crawseg IS
     SELECT w.cdcooper, s.dtcancel as dtmvtolt, w.nrdconta, w.nrctrseg, w.nrctrato,  w.nrproposta,w.tpcustei, w.tpseguro, w.nmdsegur, w.tpplaseg, w.nmbenefi, 
        w.nrcadast, w.nmdsecao, w.dsendres, w.nrendres, w.nmbairro, 
        w.nmcidade, w.cdufresd, w.nrcepend, S.DTCANCEL AS dtinivig, w.dtfimvig, w.dsmarvei, w.dstipvei, w.nranovei, w.nrmodvei, w.qtpasvei, w.ppdbonus, w.flgdnovo, 
        w.nrapoant, w.nmsegant, w.flgdutil, w.flgnotaf, w.flgapant, w.vlpreseg, w.vlseguro, w.vldfranq, w.vldcasco, w.vlverbae, w.flgassis, w.vldanmat, 
        w.vldanpes, w.vldanmor, w.vlappmor, w.vlappinv, w.cdsegura, w.nmempres, w.dschassi, w.flgrenov, s.dtcancel AS dtdebito, w.vlbenefi, w.cdcalcul, w.flgcurso,
        S.DTCANCEL AS dtiniseg, w.nrdplaca, w.lsctrant, w.nrcpfcgc, w.nrctratu, w.nmcpveic, w.flgunica,  w.flgvisto, w.cdapoant, w.dtprideb, w.vldifseg,
        w.dscobext##1, w.dscobext##2, w.dscobext##3, w.dscobext##4, w.dscobext##5, w.vlcobext##1, w.vlcobext##2, w.vlcobext##3, w.vlcobext##4, w.vlcobext##5,
        w.flgrepgr, w.vlfrqobr, w.tpsegvid, w.dtnascsg, w.cdsexosg, w.vlpremio, w.qtparcel, w.nrfonemp, w.nrfonres, w.dsoutgar, w.vloutgar, w.tpdpagto,
        w.flgconve, w.complend, w.progress_recid, w.flggarad, w.flgassum, w.tpmodali, w.flfinanciasegprestamista, w.flgsegma
      FROM CECRED.crawseg W, CECRED.CRAPSEG S
     WHERE W.CDCOOPER = S.CDCOOPER
       AND W.NRDCONTA = S.NRDCONTA
       AND W.NRCTRSEG = S.NRCTRSEG
       AND w.nrproposta IN (
               select d.nrproposta from 
                    (select p.cdcooper,
                     c.nmrescop,
                     s.cdagenci,
                     p.nrdconta,                    
                     (p.nrctrseg) nrctrseg,
                     (p.NRCTREMP) NRCTREMP,           
                     (p.nrproposta) nrproposta,
                     to_char((p.dtinivig), 'dd/mm/yyyy') dtinivig,
                     to_char((p.dtfimvig), 'dd/mm/yyyy') dtfimvig,                     
                     p.nrcpfcgc,
                     to_char(p.dtnasctl, 'dd/mm/yyyy') dtnasctl,
                     s.DTCANCEL
                from CECRED.crapseg s,
                     CECRED.tbseg_prestamista p,
                     cecred.crapcop c,
                     (select d.cdcooper, d.nrdconta, d.nrctremp, d.saldo_emp, d.saldo_cpf,
                        (case
                                 when d.saldo_cpf < 40000 and d.CDCOOPER = 1 then
                                  'N'
                                 when d.saldo_cpf < 10000 and d.CDCOOPER = 5 then
                                  'N'
                                 when d.saldo_cpf < 19999.99 and d.CDCOOPER = 16 then
                                  'N'
                                 else
                                  'S'
                               end) id_contrata
                          from (select r.cdcooper,
                                       r.nrdconta,
                                       NRCTREMP,
                                       SUM(r.vlsdeved) saldo_emp,
                                       (select SUM(r1.vlsdeved)
                                          from crapepr r1
                                         where r1.CDCOOPER = r.CDCOOPER
                                           and r1.NRDCONTA = r.NRDCONTA) as saldo_cpf
                                  from crapepr r
                                 where r.inliquid = 0
                                   and r.vlsdeved > 0
                                 group by r.cdcooper, r.nrdconta, r.NRCTREMP) d
                                 
                                 where d.saldo_emp > 0) saldo,
                      CECRED.crawseg w 
               where s.CDCOOPER = p.CDCOOPER
                 and s.NRDCONTA = p.NRDCONTA
                 and s.NRCTRSEG = p.NRCTRSEG
                 and p.cdcooper = c.cdcooper
                 
                 and p.cdcooper = saldo.cdcooper
                 and p.nrdconta = saldo.nrdconta
                 and p.NRCTREMP = saldo.nrctremp
                 
                 and s.cdcooper = w.cdcooper
                 and s.nrdconta = w.nrdconta
                 and s.nrctrseg = w.nrctrseg
                 
                 and saldo.cdcooper = w.cdcooper
                 AND saldo.nrdconta = w.nrdconta
                 AND saldo.nrctremp = w.nrctrato                 
                 and ((months_between(trunc(sysdate), p.dtnasctl)) / 12) >= 71
                 and p.dtfimvig >= trunc(sysdate)
                 and p.TPCUSTEI = 1
                 and s.cdsitseg = 2
                 and s.dtcancel is not null
                 AND SALDO.ID_CONTRATA = 'S'
                 and s.DTFIMVIG is not null
                 and p.NRPROPOSTA in ('770349015137','770349030594','770356292162','770356292170','770350037942','770349521520','770351464224','770351464313','770351464380','770349776766',
                                      '770350298274','770350322353','770349087782','770350446265','770349530864','770350063927','770358268218','770349526794','770351602112','770350757058',
                                      '770349784440','770349784459','770351902906','770349905779','770349905787','770351845600','770350439110','770350456449','770350425683','770349708558',
                                      '770351347066','770351911573','770349526840','770349506785','770349153912','770359399472','770350415840','770350185267','770349601044','770350117601',
                                      '770353428888','770350036997','770349799782','770349525070','770352654760','770349935562','770357783801','770353175823','770359493657','770349764121',
                                      '770349764130','770356329406','770356329414','770355175812','770349764172','770350056238','770350308571','770358640656','770356551001','770349518953',
                                      '770349518961','770350304045','770355208044','770355208052','770355282899','770352110620','770352110639','770350689621','770350689516','770573150902',
                                      '770573150910','770573150929','770573150937','770353074881','770352612677','770352612685','770352612669','770359631170','770351387637','770350214070',
                                      '770350503790','770350506195','770350511741','770350497048','770349525089','770350267042','770359233957','770352694380','770350518983','770349480204',
                                      '770350655824','770357181682','770349371073','770359098820','770355097706','770349693917','770349693925','770349693933','770349693941','770358395422',
                                      '770358057853','770352351008','770349544091','770356674014','770356674006','770349234050','770349912880','770350526382','770349043785','770358855881',
                                      '770350253319','770573156102','770350585788','770350106979','770349327791','770356900596','770353166611','770350032665','770358806678','770350132708',
                                      '770658116444','770358662498','770353934350','770353933949','770612971579','770349373246','770349223473','770350273905','770359384017','770359384025',
                                      '770359384033','770359384041','770359383991','770359384009','770353423010','770353127640','770352826731','770356016050','770353140264','770349200325',
                                      '770350524550','770658628453','770573767624','770356624475','770355930971','770353827723','770352115606','770352115614','770352041408','770358630065',
                                      '770350359532','770350386785','770613643796','770613315020','770358871879','770657934771','770613306978','770356348834','770573579020','770352847372',
                                      '770352494607','770349154358','770613212191','770658016709','770658301101','770613328050','770613565310','770613565329','770613327983','770613565450',
                                      '770656339730','770656339748','770358676677','770358141846','770613145559','770658185080','770658074539','770355454622','770349930994','770356681851',
                                      '770613463267','770658149334','770358926509','770353995804','770351054301','770349745542','770658517856','770359703651','770658561774','770658015877',
                                      '770657314943','770613021841','770573313402','770355321860','770357118620','770357288380','770613433309','770357042291','770349049996','770357020204',
                                      '770358633188','770655743855','770613226940','770658482297','770655769056','770356132726','770356132424','770350180761','770655764720','770658509152',
                                      '770358902650','770354222760','770353525344','770353354493','770573765486','770349230526','770357516382','770351428244','770612803820','770657768537',
                                      '770657768561','770657768570','770658452800','770658636197','770658251422','770658179306','770658179330','770658179349','770658571532','770657289647',
                                      '770657289680','770657289698','770657425940','770612889198','770354917742','770356945760','770356458206','770358860559','770353841661','770354300672',
                                      '770359960360','770359960379','770359960387','770359231415','770349752913','770354030721','770350933492','770657845914','770350935223','770658700154',
                                      '770656080191','770573045637','770356829832','770358334342','770350642382','770656129905','770658618350','770573550072','770356390857','770355349950',
                                      '770353162659','770657631434','770349504995','770658374397','770350194681','770656990015','770357815770','770356922433',
                                      '770656616695','770658864513','770355551644','770355580890','770351121505','770356354389','770356947045',
                                      '770356859294','770356859308','770350105204','770656995432','770656995440','770656932600','770656684160','770656684178','770656684186',
                                      '770657137243','770658022482','202213728564','202213728563','202213728565','202213728566','770655671633','770655671641','770656308842','770658369237',
                                      '770349077426','770354621843','770354850524','770358991254','770358991246','770354321084','770354321025','770359582730','770359960344','770353357557',
                                      '770351673788','770356166205','770358347355','770358347363','770358346502','770350383794','202213776522','202213710460','770657096580','770658725572',
                                      '770658726340','770656723831','770656723840','770656723793','770657096504','770349532182','770358084419','770573012046','770349385864','202213768276',
                                      '770656781343','770355432556','770350313214','770658142526','770655709100','202213712688','770573636112','770573635604','770350561900','770613311262',
                                      '770349353598','770358050654','770357157080','770658357344','770349219352','770350330674','770612803854','770356503716','770357108462','770658608940',
                                      '770658642103','770658298933','770658462962','770573116607','770573116615','770573116623','770573116585','770573116631','770359384068','770359289022',
                                      '770359384050','770656164395','770354997738','770657323721','770573458249','770573762860','770356607481','770657541613','770613740279','770349230739',
                                      '770349230747','202304287007','770658311387','202304322786','202304322748','770354906848','770355945723','770354569884','770356928750','770358320953',
                                      '770352398616','770359563396','770359563116','770352107891','770352107905','770352107913','770349896044','770349896060','770349896087','770350351671',
                                      '770350367314','770350548998','202304302081','770657053953','770657797197','770355969266','202304324184','770349328828','770349328836','770356205537',
                                      '770349221675','770349228700','770349228718','770354049406','770359096100','770349110385','770355947300','770658573012','202304244289','770350218505',
                                      '202304303028','202304303027','202304323886','770657055298','770657055280','770357417139','770656044403','770656336390', '770613393633','770572879356',
                                      '202304343246','770350729348','770657493201','770355128148','202304256301','202308516798','770351864265','770658510240','770357973562','770357166829',
                                      '770351629495','770350521380','770573632311','770349163411','770355121127','770355121135','770355121143','770355121119','202213829014','770656242426',
                                      '770656625694','770656672994','770656673001','770356384415','770354168065','770352319341','770352661430','770350108807','770358630219','770350045147',
                                      '770349523515','770356609530','770355028046','770351362804','770350349480','770613486917')                                       
                                          
                        ) d
                          )
   ORDER BY w.cdcooper, w.nrdconta, w.nrctrato;

  rw_crawseg cr_crawseg%ROWTYPE;

  CURSOR cr_crapseg(pr_cdcooper in cecred.crapseg.cdcooper%TYPE,
                    pr_nrdconta in cecred.crapseg.nrdconta%TYPE,
                    pr_nrctrseg in cecred.crapseg.nrctrseg%TYPE) IS
    SELECT S.NRDCONTA, S.NRCTRSEG, S.DTCANCEL AS DTINIVIG, S.DTFIMVIG, s.dtcancel as DTMVTOLT, S.CDAGENCI, S.CDBCCXLT, S.CDSITSEG, S.DTALTSEG, S.DTCANCEL, s.dtcancel as DTDEBITO, S.DTCANCEL AS DTINISEG,
       S.INDEBITO, S.NRDOLOTE, S.NRSEQDIG, S.QTPREPAG, S.VLPREPAG, S.VLPRESEG, s.dtcancel as DTULTPAG, S.TPSEGURO, S.TPPLASEG, S.QTPREVIG, S.CDSEGURA, S.LSCTRANT,
       S.NRCTRATU, S.FLGUNICA, S.DTPRIDEB, S.VLDIFSEG, S.NMBENVID##1, S.NMBENVID##2, S.NMBENVID##3, S.NMBENVID##4, S.NMBENVID##5, S.DSGRAUPR##1, S.DSGRAUPR##2,
       S.DSGRAUPR##3, S.DSGRAUPR##4, S.DSGRAUPR##5, S.TXPARTIC##1, S.TXPARTIC##2, S.TXPARTIC##3, S.TXPARTIC##4, S.TXPARTIC##5, S.DTULTALT, S.CDOPERAD,
       S.VLPREMIO, S.QTPARCEL, S.TPDPAGTO, S.CDCOOPER, S.FLGCONVE, S.FLGCLABE, S.CDMOTCAN, S.TPENDCOR, S.PROGRESS_RECID, S.CDOPECNL, S.DTRENOVA,
       S.CDOPEORI, S.CDAGEORI, sysdate as DTINSORI, S.CDOPEEXC, S.CDAGEEXC, S.DTINSEXC, S.VLSLDDEV, S.IDIMPDPS
      FROM CECRED.crapseg s
     WHERE s.cdcooper = pr_cdcooper
       AND s.nrdconta = pr_nrdconta
       AND s.nrctrseg = pr_nrctrseg;
  rw_crapseg cr_crapseg%ROWTYPE;

  CURSOR cr_tbseg_prestamista(pr_cdcooper in cecred.tbseg_prestamista.cdcooper%TYPE,
                              pr_nrdconta in cecred.tbseg_prestamista.nrdconta%TYPE,
                              pr_nrctremp in cecred.tbseg_prestamista.nrctremp%TYPE,
                              pr_nrctrseg in cecred.tbseg_prestamista.nrctrseg%TYPE) IS
    SELECT P.IDSEQTRA, P.CDCOOPER, P.NRDCONTA, P.NRCTRSEG, P.NRCTREMP, P.TPREGIST, P.CDAPOLIC, P.NRCPFCGC, P.NMPRIMTL, P.DTNASCTL, P.CDSEXOTL, P.DSENDRES,
        P.DSDEMAIL, P.NMBAIRRO, P.NMCIDADE, P.CDUFRESD, P.NRCEPEND, P.NRTELEFO, s.dtcancel as DTDEVEND, S.DTCANCEL AS DTINIVIG, P.CDCOBRAN, P.CDADMCOB, P.TPFRECOB, P.TPSEGURA,
        P.CDPRODUT, P.CDPLAPRO, P.VLPRODUT, P.TPCOBRAN, P.VLSDEVED, P.VLDEVATU, last_day(s.dtcancel) as DTREFCOB, P.DTFIMVIG, P.DTDENVIO, P.NRPROPOSTA, P.TPRECUSA, P.CDMOTREC,
        P.DTRECUSA, P.SITUACAO, P.TPCUSTEI, P.PEMORTE,  P.PEINVALIDEZ, P.PEIFTTTAXA, P.QTIFTTDIAS, P.NRAPOLICE, P.QTPARCEL, P.VLPIELIMIT, P.VLIFTTLIMI,
        P.DSPROTOCOLO, P.FLFINANCIASEGPRESTAMISTA
      FROM CECRED.tbseg_prestamista p, CECRED.CRAPSEG S
     WHERE P.CDCOOPER = S.CDCOOPER
       AND P.NRDCONTA = S.NRDCONTA
       AND P.NRCTRSEG = S.NRCTRSEG
       AND p.cdcooper = pr_cdcooper
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


  CURSOR cr_saldo(pr_cdcooper in cecred.crapris.cdcooper%TYPE,
                  pr_nrdconta in cecred.crapris.nrdconta%TYPE
                  ,pr_nrctremp in cecred.crapris.nrctremp%TYPE
                  ) IS
    SELECT SUM(j.vldivida) saldo
      FROM CECRED.crapris j,
           CECRED.crapepr e
     WHERE j.cdcooper = e.cdcooper
       AND j.nrdconta = e.nrdconta
       AND j.nrctremp = e.nrctremp
       AND j.inddocto = 1
       AND j.cdcooper = pr_cdcooper
       AND j.nrdconta = pr_nrdconta
       AND j.nrctremp = pr_nrctremp      
       and j.dtrefere = (select max(j1.dtrefere) 
                           from cecred.crapris j1
                          where j1.cdcooper = j.cdcooper
                            AND j1.nrdconta = j.nrdconta
                            AND j1.nrctremp = j.nrctremp
                            AND j1.inddocto = j.inddocto )  
       ;
  rw_saldo cr_saldo%ROWTYPE;

  CURSOR cr_crapris(pr_cdcooper in cecred.crapris.cdcooper%TYPE,
                    pr_nrdconta in cecred.crapris.nrdconta%TYPE                   
                    ) IS
    SELECT SUM(j.vldivida) saldo
      FROM cecred.crapris j,
           cecred.crapepr e
     WHERE j.cdcooper = e.cdcooper
       AND j.nrdconta = e.nrdconta
       AND j.nrctremp = e.nrctremp
       AND j.inddocto = 1       
       AND j.cdcooper = pr_cdcooper
       AND j.nrdconta = pr_nrdconta      
       AND j.dtrefere = (select max(j1.dtrefere) 
                           from cecred.crapris j1
                          where j1.cdcooper = j.cdcooper
                            AND j1.nrdconta = j.nrdconta
                            AND j1.nrctremp = j.nrctremp
                            AND j1.inddocto = j.inddocto )                              
     
       ;
  rw_crapris cr_crapris%ROWTYPE;

  PROCEDURE pc_valida_direto(pr_nmdireto IN  VARCHAR2,
                             pr_dscritic OUT CECRED.crapcri.dscritic%TYPE) IS
    vr_dscritic  CECRED.crapcri.dscritic%TYPE;
    vr_typ_saida VARCHAR2(3);
    vr_des_saida VARCHAR2(1000);
    vr_exc_erro  EXCEPTION;

  BEGIN
    IF NOT CECRED.gene0001.fn_exis_diretorio(pr_nmdireto) THEN

      CECRED.gene0001.pc_OSCommand_Shell(pr_des_comando => 'mkdir ' || pr_nmdireto || ' 1> /dev/null',
                                         pr_typ_saida   => vr_typ_saida,
                                         pr_des_saida   => vr_des_saida);

      IF vr_typ_saida = 'ERR' THEN
        vr_dscritic := 'CRIAR DIRETORIO ARQUIVO -> Nao foi possivel criar o diretorio para gerar os arquivos. ' || vr_des_saida;
        RAISE vr_exc_erro;
      END IF;

      CECRED.gene0001.pc_OSCommand_Shell(pr_des_comando => 'chmod 777 ' || pr_nmdireto || ' 1> /dev/null',
                                         pr_typ_saida   => vr_typ_saida,
                                         pr_des_saida   => vr_des_saida);

      IF vr_typ_saida = 'ERR' THEN
        vr_dscritic := 'PERMISSAO NO DIRETORIO -> Nao foi possivel adicionar permissao no diretorio dos arquivos. ' || vr_des_saida;
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

  CECRED.GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdir,
                                  pr_nmarquiv => vr_nmarq,
                                  pr_tipabert => 'W',
                                  pr_utlfileh => vr_ind_arq,
                                  pr_des_erro => vr_dscritic);

  IF vr_dscritic IS NOT NULL THEN
    vr_dscritic := vr_dscritic ||'  Não pode abrir arquivo '|| vr_nmdir || vr_nmarq;
    RAISE vr_exc_saida;
  END IF;

   CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'BEGIN');

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

     OPEN cr_saldo(pr_cdcooper => rw_crawseg.cdcooper,
                 pr_nrdconta => rw_crawseg.nrdconta
                 ,pr_nrctremp => rw_crawseg.nrctrato                 
                 );
   FETCH cr_saldo INTO rw_saldo;
   CLOSE cr_saldo;

   OPEN cr_crapris(pr_cdcooper => rw_crawseg.cdcooper,
                   pr_nrdconta => rw_crawseg.nrdconta                   
                   );
   FETCH cr_crapris INTO rw_crapris;
   CLOSE cr_crapris;

   INSERT INTO CECRED.crawseg(dtmvtolt,nrdconta,nrctrseg,tpseguro,nmdsegur,tpplaseg,nmbenefi,nrcadast,
                              nmdsecao,dsendres,nrendres,nmbairro,nmcidade,cdufresd,nrcepend,dtinivig,
                              dtfimvig,dsmarvei,dstipvei,nranovei,nrmodvei,qtpasvei,ppdbonus,flgdnovo,
                              nrapoant,nmsegant,flgdutil,flgnotaf,flgapant,vlpreseg,vlseguro,vldfranq,
                              vldcasco,vlverbae,flgassis,vldanmat,vldanpes,vldanmor,vlappmor,vlappinv,
                              cdsegura,nmempres,dschassi,flgrenov,dtdebito,vlbenefi,cdcalcul,flgcurso,
                              dtiniseg,nrdplaca,lsctrant,nrcpfcgc,nrctratu,nmcpveic,flgunica,nrctrato,
                              flgvisto,cdapoant,dtprideb,vldifseg,dscobext##1,dscobext##2,dscobext##3,dscobext##4,
                              dscobext##5,vlcobext##1,vlcobext##2,vlcobext##3,vlcobext##4,vlcobext##5,flgrepgr,vlfrqobr,
                              tpsegvid,dtnascsg,cdsexosg,vlpremio,qtparcel,nrfonemp,nrfonres,dsoutgar,
                              vloutgar,tpdpagto,cdcooper,flgconve,complend,nrproposta,flggarad,flgassum,
                              tpcustei,tpmodali,flfinanciasegprestamista,flgsegma)
                       values(rw_crawseg.dtmvtolt,rw_crawseg.nrdconta,vr_nrctrseg,rw_crawseg.tpseguro,
                              rw_crawseg.nmdsegur,rw_crawseg.tpplaseg,rw_crawseg.nmbenefi,rw_crawseg.nrcadast,
                              rw_crawseg.nmdsecao,rw_crawseg.dsendres,rw_crawseg.nrendres,rw_crawseg.nmbairro,
                              rw_crawseg.nmcidade,rw_crawseg.cdufresd,rw_crawseg.nrcepend,rw_crawseg.dtinivig,
                              rw_crappep.dtfimvig,rw_crawseg.dsmarvei,rw_crawseg.dstipvei,rw_crawseg.nranovei,
                              rw_crawseg.nrmodvei,rw_crawseg.qtpasvei,rw_crawseg.ppdbonus,rw_crawseg.flgdnovo,
                              rw_crawseg.nrapoant,rw_crawseg.nmsegant,rw_crawseg.flgdutil,rw_crawseg.flgnotaf,
                              rw_crawseg.flgapant,rw_crawseg.vlpreseg,nvl(rw_crapris.saldo,0),rw_crawseg.vldfranq,
                              rw_crawseg.vldcasco,rw_crawseg.vlverbae,rw_crawseg.flgassis,rw_crawseg.vldanmat,
                              rw_crawseg.vldanpes,rw_crawseg.vldanmor,rw_crawseg.vlappmor,rw_crawseg.vlappinv,
                              rw_crawseg.cdsegura,rw_crawseg.nmempres,rw_crawseg.dschassi,
                              rw_crawseg.flgrenov,rw_crawseg.dtdebito,rw_crawseg.vlbenefi,rw_crawseg.cdcalcul,
                              rw_crawseg.flgcurso,rw_crawseg.dtiniseg,rw_crawseg.nrdplaca,rw_crawseg.lsctrant,
                              rw_crawseg.nrcpfcgc,rw_crawseg.nrctratu,rw_crawseg.nmcpveic,rw_crawseg.flgunica,
                              rw_crawseg.nrctrato,rw_crawseg.flgvisto,rw_crawseg.cdapoant,rw_crawseg.dtprideb,
                              rw_crawseg.vldifseg,rw_crawseg.dscobext##1,rw_crawseg.dscobext##2,
                              rw_crawseg.dscobext##3,rw_crawseg.dscobext##4,rw_crawseg.dscobext##5,rw_crawseg.vlcobext##1,
                              rw_crawseg.vlcobext##2,rw_crawseg.vlcobext##3,rw_crawseg.vlcobext##4,rw_crawseg.vlcobext##5,
                              rw_crawseg.flgrepgr,rw_crawseg.vlfrqobr,rw_crawseg.tpsegvid,rw_crawseg.dtnascsg,
                              rw_crawseg.cdsexosg,rw_crawseg.vlpremio,rw_crawseg.qtparcel,rw_crawseg.nrfonemp,
                              rw_crawseg.nrfonres,rw_crawseg.dsoutgar,rw_crawseg.vloutgar,rw_crawseg.tpdpagto,
                              rw_crawseg.cdcooper,rw_crawseg.flgconve,rw_crawseg.complend,vr_nrproposta,
                              rw_crawseg.flggarad,rw_crawseg.flgassum,rw_crawseg.tpcustei,
                              rw_crawseg.tpmodali,rw_crawseg.flfinanciasegprestamista,rw_crawseg.flgsegma);

   COMMIT;

   vr_linha := 'DELETE CECRED.crawseg w WHERE w.cdcooper = ' || rw_crawseg.cdcooper || ' AND w.nrdconta = ' || rw_crawseg.nrdconta || ' AND w.nrctrseg = ' || vr_nrctrseg || ' AND w.tpseguro = 4;';

   CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);


   OPEN cr_crapseg(pr_cdcooper => rw_crawseg.cdcooper,
                   pr_nrdconta => rw_crawseg.nrdconta,
                   pr_nrctrseg => rw_crawseg.nrctrseg);
   FETCH cr_crapseg INTO rw_crapseg;

   IF cr_crapseg%FOUND THEN

 vr_nrseqdig := cecred.fn_sequence('CRAPLOT','NRSEQDIG',1||';'||rw_crapseg.cdagenci||';'||'900;'||rw_crapseg.nrdolote); 

     INSERT INTO CECRED.crapseg(nrdconta,nrctrseg,dtinivig,dtfimvig,
                                dtmvtolt,cdagenci,cdbccxlt,cdsitseg,
                                dtaltseg,dtcancel,dtdebito,dtiniseg,
                                indebito,nrdolote,nrseqdig,qtprepag,
                                vlprepag,vlpreseg,dtultpag,tpseguro,
                                tpplaseg,qtprevig,cdsegura,lsctrant,
                                nrctratu,flgunica,dtprideb,vldifseg,
                                nmbenvid##1,nmbenvid##2,nmbenvid##3,nmbenvid##4,
                                nmbenvid##5,dsgraupr##1,dsgraupr##2,dsgraupr##3,
                                dsgraupr##4,dsgraupr##5,txpartic##1,txpartic##2,
                                txpartic##3,txpartic##4,txpartic##5,dtultalt,
                                cdoperad,vlpremio,qtparcel,tpdpagto,
                                cdcooper,flgconve,flgclabe,cdmotcan,
                                tpendcor,cdopecnl,dtrenova,cdopeori,
                                cdageori,dtinsori,cdopeexc,cdageexc,
                                dtinsexc,vlslddev,idimpdps)
                         VALUES(rw_crapseg.nrdconta,vr_nrctrseg,rw_crapseg.dtinivig,rw_crappep.dtfimvig,
                                rw_crapseg.dtmvtolt,rw_crapseg.cdagenci,rw_crapseg.cdbccxlt,1,
                                rw_crapseg.dtaltseg,null,rw_crapseg.dtdebito,rw_crapseg.dtiniseg,
                                rw_crapseg.indebito,rw_crapseg.nrdolote,vr_nrseqdig,rw_crapseg.qtprepag,
                                rw_crapseg.vlprepag,rw_crapseg.vlpreseg,rw_crapseg.dtultpag,rw_crapseg.tpseguro,
                                rw_crapseg.tpplaseg,rw_crapseg.qtprevig,rw_crapseg.cdsegura,rw_crapseg.lsctrant,
                                rw_crapseg.nrctratu,rw_crapseg.flgunica,rw_crapseg.dtprideb,rw_crapseg.vldifseg,
                                rw_crapseg.nmbenvid##1,rw_crapseg.nmbenvid##2,rw_crapseg.nmbenvid##3,rw_crapseg.nmbenvid##4,
                                rw_crapseg.nmbenvid##5,rw_crapseg.dsgraupr##1,rw_crapseg.dsgraupr##2,rw_crapseg.dsgraupr##3,
                                rw_crapseg.dsgraupr##4,rw_crapseg.dsgraupr##5,rw_crapseg.txpartic##1,rw_crapseg.txpartic##2,
                                rw_crapseg.txpartic##3,rw_crapseg.txpartic##4,rw_crapseg.txpartic##5,rw_crapseg.dtultalt,
                                rw_crapseg.cdoperad,rw_crapseg.vlpremio,rw_crapseg.qtparcel,rw_crapseg.tpdpagto,
                                rw_crapseg.cdcooper,rw_crapseg.flgconve,rw_crapseg.flgclabe,null,
                                rw_crapseg.tpendcor,rw_crapseg.cdopecnl,rw_crapseg.dtrenova,rw_crapseg.cdopeori,
                                rw_crapseg.cdageori,rw_crapseg.dtinsori,rw_crapseg.cdopeexc,rw_crapseg.cdageexc,
                                rw_crapseg.dtinsexc,nvl(rw_crapris.saldo,0),rw_crapseg.idimpdps);
     COMMIT;

     vr_linha := 'DELETE CECRED.crapseg WHERE cdcooper = ' || rw_crapseg.cdcooper || ' AND nrdconta = ' || rw_crapseg.nrdconta || ' AND nrctrseg = ' || vr_nrctrseg || ' AND tpseguro = 4;';

     CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
   END IF;
   CLOSE cr_crapseg;

   OPEN cr_tbseg_prestamista(pr_cdcooper => rw_crawseg.cdcooper,
                             pr_nrdconta => rw_crawseg.nrdconta,
                             pr_nrctremp => rw_crawseg.nrctrato,
                             pr_nrctrseg => rw_crawseg.nrctrseg);

   FETCH cr_tbseg_prestamista INTO rw_tbseg_prestamista;

   IF cr_tbseg_prestamista%FOUND THEN
     vr_nrsequen := cecred.fn_sequence('TBSEG_PRESTAMISTA', 'SEQCERTIFICADO', 0);

     INSERT INTO CECRED.tbseg_prestamista(cdcooper,nrdconta,nrctrseg,nrctremp,
                                          tpregist,cdapolic,nrcpfcgc,nmprimtl,
                                          dtnasctl,cdsexotl,dsendres,dsdemail,
                                          nmbairro,nmcidade,cdufresd,nrcepend,
                                          nrtelefo,dtdevend,dtinivig,cdcobran,
                                          cdadmcob,tpfrecob,tpsegura,cdprodut,
                                          cdplapro,vlprodut,tpcobran,vlsdeved,
                                          vldevatu,dtrefcob,dtfimvig,dtdenvio,
                                          nrproposta,tprecusa,cdmotrec,dtrecusa,
                                          situacao,tpcustei,pemorte,peinvalidez,
                                          peiftttaxa,qtifttdias,nrapolice,qtparcel,
                                          vlpielimit,vlifttlimi,dsprotocolo,flfinanciasegprestamista)
                                   values(rw_tbseg_prestamista.cdcooper,rw_tbseg_prestamista.nrdconta,
                                          vr_nrctrseg,rw_tbseg_prestamista.nrctremp,
                                          1,vr_nrsequen,
                                          rw_tbseg_prestamista.nrcpfcgc,rw_tbseg_prestamista.nmprimtl,
                                          rw_tbseg_prestamista.dtnasctl,rw_tbseg_prestamista.cdsexotl,
                                          rw_tbseg_prestamista.dsendres,rw_tbseg_prestamista.dsdemail,
                                          rw_tbseg_prestamista.nmbairro,rw_tbseg_prestamista.nmcidade,
                                          rw_tbseg_prestamista.cdufresd,rw_tbseg_prestamista.nrcepend,
                                          rw_tbseg_prestamista.nrtelefo,rw_tbseg_prestamista.dtdevend,
                                          rw_tbseg_prestamista.dtinivig,rw_tbseg_prestamista.cdcobran,
                                          rw_tbseg_prestamista.cdadmcob,rw_tbseg_prestamista.tpfrecob,
                                          rw_tbseg_prestamista.tpsegura,rw_tbseg_prestamista.cdprodut,
                                          rw_tbseg_prestamista.cdplapro,rw_tbseg_prestamista.vlprodut,
                                          rw_tbseg_prestamista.tpcobran,nvl(rw_crapris.saldo,0),
                                          nvl(rw_saldo.saldo,0),rw_tbseg_prestamista.dtrefcob,
                                          rw_crappep.dtfimvig,rw_tbseg_prestamista.dtdenvio,
                                          vr_nrproposta,null,
                                          null,null,
                                          rw_tbseg_prestamista.situacao,rw_tbseg_prestamista.tpcustei,
                                          rw_tbseg_prestamista.pemorte,rw_tbseg_prestamista.peinvalidez,
                                          rw_tbseg_prestamista.peiftttaxa,rw_tbseg_prestamista.qtifttdias,
                                          rw_tbseg_prestamista.nrapolice,rw_tbseg_prestamista.qtparcel,
                                          rw_tbseg_prestamista.vlpielimit,rw_tbseg_prestamista.vlifttlimi,
                                          rw_tbseg_prestamista.dsprotocolo,rw_tbseg_prestamista.flfinanciasegprestamista
                                          );

     COMMIT;

     UPDATE cecred.crawseg
        SET nrproposta = vr_nrproposta,
            nrctrseg = vr_nrctrseg
      WHERE cdcooper = rw_crawseg.cdcooper
        AND nrdconta = rw_crawseg.nrdconta
        AND nrctrato = rw_crawseg.nrctrato
        AND nrctrseg = vr_nrctrseg;

    COMMIT;
    vr_linha := 'DELETE CECRED.tbseg_prestamista WHERE cdcooper = ' || rw_tbseg_prestamista.cdcooper || ' AND nrdconta = ' || rw_tbseg_prestamista.nrdconta || ' AND nrctrseg = ' || vr_nrctrseg || ' AND nrctremp = ' || rw_tbseg_prestamista.nrctremp || ';';

    CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

   END IF;
   CLOSE cr_tbseg_prestamista;
 END LOOP;

 CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' COMMIT;');
 CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' END; ');
 CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'/ ');
 CECRED.GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arq );

end;
/
