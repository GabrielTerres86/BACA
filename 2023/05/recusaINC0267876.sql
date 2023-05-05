begin
update cecred.tbseg_prestamista a set a.situacao=0, a.tpregist = 0, a.nrproposta='770350220607', a.cdmotrec= 143, a.tprecusa= 'ajustes INC0267876' where a.cdcooper=1 and a.nrdconta=518581 and a.nrctrseg = 1336532;
update cecred.tbseg_prestamista a set a.nrproposta='770350220607A02' where a.cdcooper=1 and a.nrdconta=518581 and a.nrctrseg = 704874;
update cecred.crawseg a set a.nrproposta='770350220607' where a.cdcooper=1 and a.nrdconta=518581 and a.nrctrseg = 1336532;
update cecred.crawseg a set a.nrproposta='770350220607A02' where a.cdcooper=1 and a.nrdconta=518581 and a.nrctrseg = 347250;
update cecred.crapseg a set a.cdsitseg=5, a.cdageexc= 1 , a.dtcancel= TO_DATE(sysdate, 'DD/MM/RRRR'), a.cdopecnl=1 where a.nrdconta=518581 and a.cdcooper=1 and a.nrctrseg=1336532;
commit;
end;
