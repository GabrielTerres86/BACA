begin

update tbseg_prestamista p
set p.tpcustei = 0
where idseqtra in (SELECT p.idseqtra
FROM tbseg_prestamista p, crapepr c, crapass ass
WHERE p.cdcooper = 1
AND c.cdcooper = p.cdcooper
AND c.nrdconta = p.nrdconta
AND c.nrctremp = p.nrctremp
AND ass.cdcooper = c.cdcooper
AND ass.nrdconta = c.nrdconta
AND p.tpregist <> 0
and c.cdcooper = 1
and idseqtra > 409221);

INSERT INTO craplau (craplau.cdcooper
,craplau.nrdconta
,craplau.idseqttl
,craplau.dttransa
,craplau.hrtransa
,craplau.dtmvtolt
,craplau.cdagenci
,craplau.cdbccxlt
,craplau.nrdolote
,craplau.nrseqdig
,craplau.nrdocmto
,craplau.cdhistor
,craplau.dsorigem
,craplau.insitlau
,craplau.cdtiptra
,craplau.dscedent
,craplau.dscodbar
,craplau.dslindig
,craplau.dtmvtopg
,craplau.vllanaut
,craplau.dtvencto
,craplau.cddbanco
,craplau.cdageban
,craplau.nrctadst
,craplau.cdcoptfn
,craplau.cdagetfn
,craplau.nrterfin
,craplau.nrcpfope
,craplau.nrcpfpre
,craplau.nmprepos
,craplau.idtitdda
,craplau.tpdvalor)
select p.cdcooper
,p.nrdconta ---contadeb do cooperado.
,1
,SYSDATE
,gene0002.fn_busca_time
,p.dtfimvig
,1
,100
,11910
,CRAPLAU_seq.nextval
,p.nrctrseg+CRAPLAU_seq.nextval
,3651
,'SEGU0001'
,1
,5
,'SEGU0001'
,''
,' '
, c.dtmvtolt
, p.vldevatu
,''
, 0
, 0
,4112 -- 4112 --nrctadst - Numero da conta destino. ----craphis where cdhistor = 3651
,0
,0
,0
,0
,0
,' '
,0
,2
from tbseg_prestamista p, crapepr c, crapass ass
WHERE p.cdcooper = 1
AND c.cdcooper = p.cdcooper
AND c.nrdconta = p.nrdconta
AND c.nrctremp = p.nrctremp
AND ass.cdcooper = c.cdcooper
AND ass.nrdconta = c.nrdconta
AND p.tpregist <> 0
and c.cdcooper = 1
and idseqtra > 409221;

commit;

end;