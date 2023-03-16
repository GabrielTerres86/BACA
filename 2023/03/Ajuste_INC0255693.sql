begin
update cecred.tbseg_prestamista p set p.NRPROPOSTA = '202304235000' where p.NRPROPOSTA = '770350614753A01';
update cecred.crawseg p set p.NRPROPOSTA = '202304235000' where p.NRPROPOSTA = '770350614753A01';
update cecred.tbseg_prestamista p set p.NRPROPOSTA = '202304361869' where p.NRPROPOSTA = '770350561927';
update cecred.crawseg p set p.NRPROPOSTA = '202304361869' where p.NRPROPOSTA = '770350561927';
update cecred.tbseg_nrproposta p set p.dhseguro = sysdate where p.NRPROPOSTA = '202304235000';
Update cecred.craplau l  set l.CDSEQTEL =  '202212139953' where l.IDLANCTO = 76542309;
Update cecred.craplau l  set l.CDSEQTEL =  '202304400288' where l.IDLANCTO = 77292701;
Update cecred.craplau l  set l.CDSEQTEL =  '202304497133' where l.IDLANCTO = 77294282;
Update cecred.craplau l  set l.CDSEQTEL =  '202212152359' where l.IDLANCTO = 77293914;
Update cecred.craplau l  set l.CDSEQTEL =  '202304641974' where l.IDLANCTO = 77626140;
commit;
end;
