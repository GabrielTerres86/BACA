begin

update cecred.crapseg
   set cdsitseg = 1,
       dtcancel = null
 where cdcooper = 6
   and nrdconta = 57770
   and nrctrseg = 102075
   and tpseguro = 4;
   
update cecred.tbseg_prestamista
   set tpregist = 3,
       dtrecusa = null,
       cdmotrec = null,
       tprecusa = null
 where cdcooper = 6
   and nrdconta = 57770
   and nrctrseg = 102075
   and nrctremp = 271200;
   
update cecred.crawseg set vlpremio = 1988.16 where cdcooper = 8 and nrdconta = 17574 and nrctrseg = 22885 and nrctrato = 15126 and tpseguro = 4;
update cecred.crapseg set vlpremio = 1988.16 where cdcooper = 8 and nrdconta = 17574 and nrctrseg = 22885 and tpseguro = 4;
update cecred.tbseg_prestamista set vlprodut = 1988.16 where cdcooper = 8 and nrdconta = 17574 and nrctrseg = 22885 and nrctremp = 15126;

update cecred.crawseg set vlpremio = 69.30 where cdcooper = 13 and nrdconta = 236063 and nrctrseg = 471403 and nrctrato = 289256 and tpseguro = 4;
update cecred.crapseg set vlpremio = 69.30 where cdcooper = 13 and nrdconta = 236063 and nrctrseg = 471403 and tpseguro = 4;
update cecred.tbseg_prestamista set vlprodut = 69.30 where cdcooper = 13 and nrdconta = 236063 and nrctrseg = 471403 and nrctremp = 289256;

update cecred.crawseg set vlpremio = 91.21 where cdcooper = 13 and nrdconta = 615200 and nrctrseg = 468524 and nrctrato = 287467 and tpseguro = 4;
update cecred.crapseg set vlpremio = 91.21 where cdcooper = 13 and nrdconta = 615200 and nrctrseg = 468524 and tpseguro = 4;
update cecred.tbseg_prestamista set vlprodut = 91.21 where cdcooper = 13 and nrdconta = 615200 and nrctrseg = 468524 and nrctremp = 287467;

update cecred.crawseg set vlpremio = 56.33 where cdcooper = 14 and nrdconta = 16109899 and nrctrseg = 73198 and nrctrato = 106995 and tpseguro = 4;
update cecred.crapseg set vlpremio = 56.33 where cdcooper = 14 and nrdconta = 16109899 and nrctrseg = 73198 and tpseguro = 4;
update cecred.tbseg_prestamista set vlprodut = 56.33 where cdcooper = 14 and nrdconta = 16109899 and nrctrseg = 73198 and nrctremp = 106995;

update cecred.crawseg set vlpremio = 1094.03 where cdcooper = 14 and nrdconta = 267465 and nrctrseg = 74795 and nrctrato = 109726 and tpseguro = 4;
update cecred.crapseg set vlpremio = 1094.03 where cdcooper = 14 and nrdconta = 267465 and nrctrseg = 74795 and tpseguro = 4;
update cecred.tbseg_prestamista set vlprodut = 1094.03 where cdcooper = 14 and nrdconta = 267465 and nrctrseg = 74795 and nrctremp = 109726;

update cecred.crawseg set vlpremio = 11.91 where cdcooper = 14 and nrdconta = 249653 and nrctrseg = 74245 and nrctrato = 108650 and tpseguro = 4;
update cecred.crapseg set vlpremio = 11.91 where cdcooper = 14 and nrdconta = 249653 and nrctrseg = 74245 and tpseguro = 4;
update cecred.tbseg_prestamista set vlprodut = 11.91 where cdcooper = 14 and nrdconta = 249653 and nrctrseg = 74245 and nrctremp = 108650;

update cecred.crawseg set vlpremio = 8.26 where cdcooper = 14 and nrdconta = 323497 and nrctrseg = 72747 and nrctrato = 106250 and tpseguro = 4;
update cecred.crapseg set vlpremio = 8.26 where cdcooper = 14 and nrdconta = 323497 and nrctrseg = 72747 and tpseguro = 4;
update cecred.tbseg_prestamista set vlprodut = 8.26 where cdcooper = 14 and nrdconta = 323497 and nrctrseg = 72747 and nrctremp = 106250;

update cecred.crawseg set vlpremio = 1268.03 where cdcooper = 14 and nrdconta = 15140520 and nrctrseg = 74521 and nrctrato = 109241 and tpseguro = 4;
update cecred.crapseg set vlpremio = 1268.03 where cdcooper = 14 and nrdconta = 15140520 and nrctrseg = 74521 and tpseguro = 4;
update cecred.tbseg_prestamista set vlprodut = 1268.03 where cdcooper = 14 and nrdconta = 15140520 and nrctrseg = 74521 and nrctremp = 109241;

update cecred.crawseg set vlpremio = 697.52 where cdcooper = 14 and nrdconta = 353841 and nrctrseg = 74952 and nrctrato = 110079 and tpseguro = 4;
update cecred.crapseg set vlpremio = 697.52 where cdcooper = 14 and nrdconta = 353841 and nrctrseg = 74952 and tpseguro = 4;
update cecred.tbseg_prestamista set vlprodut = 697.52 where cdcooper = 14 and nrdconta = 353841 and nrctrseg = 74952 and nrctremp = 110079;

update cecred.crawseg set vlpremio = 1377.98 where cdcooper = 14 and nrdconta = 16315499 and nrctrseg = 73224 and nrctrato = 105814 and tpseguro = 4;
update cecred.crapseg set vlpremio = 1377.98 where cdcooper = 14 and nrdconta = 16315499 and nrctrseg = 73224 and tpseguro = 4;
update cecred.tbseg_prestamista set vlprodut = 1377.98 where cdcooper = 14 and nrdconta = 16315499 and nrctrseg = 73224 and nrctremp = 105814;

update cecred.crawseg set vlpremio = 290.53 where cdcooper = 14 and nrdconta = 14435 and nrctrseg = 73122 and nrctrato = 106776 and tpseguro = 4;
update cecred.crapseg set vlpremio = 290.53 where cdcooper = 14 and nrdconta = 14435 and nrctrseg = 73122 and tpseguro = 4;
update cecred.tbseg_prestamista set vlprodut = 290.53 where cdcooper = 14 and nrdconta = 14435 and nrctrseg = 73122 and nrctremp = 106776;

update cecred.crawseg set vlpremio = 853.96 where cdcooper = 14 and nrdconta = 311880 and nrctrseg = 74261 and nrctrato = 107795 and tpseguro = 4;
update cecred.crapseg set vlpremio = 853.96 where cdcooper = 14 and nrdconta = 311880 and nrctrseg = 74261 and tpseguro = 4;
update cecred.tbseg_prestamista set vlprodut = 853.96 where cdcooper = 14 and nrdconta = 311880 and nrctrseg = 74261 and nrctremp = 107795;

update cecred.crawseg set vlpremio = 382.31 where cdcooper = 14 and nrdconta = 14095 and nrctrseg = 74658 and nrctrato = 109450 and tpseguro = 4;
update cecred.crapseg set vlpremio = 382.31 where cdcooper = 14 and nrdconta = 14095 and nrctrseg = 74658 and tpseguro = 4;
update cecred.tbseg_prestamista set vlprodut = 382.31 where cdcooper = 14 and nrdconta = 14095 and nrctrseg = 74658 and nrctremp = 109450;

update cecred.crawseg set vlpremio = 36.44 where cdcooper = 14 and nrdconta = 334073 and nrctrseg = 73174 and nrctrato = 106835 and tpseguro = 4;
update cecred.crapseg set vlpremio = 36.44 where cdcooper = 14 and nrdconta = 334073 and nrctrseg = 73174 and tpseguro = 4;
update cecred.tbseg_prestamista set vlprodut = 36.44 where cdcooper = 14 and nrdconta = 334073 and nrctrseg = 73174 and nrctremp = 106835;

update cecred.crawseg set vlpremio = 750.56 where cdcooper = 14 and nrdconta = 201227 and nrctrseg = 74802 and nrctrato = 109735 and tpseguro = 4;
update cecred.crapseg set vlpremio = 750.56 where cdcooper = 14 and nrdconta = 201227 and nrctrseg = 74802 and tpseguro = 4;
update cecred.tbseg_prestamista set vlprodut = 750.56 where cdcooper = 14 and nrdconta = 201227 and nrctrseg = 74802 and nrctremp = 109735;

update cecred.crawseg set vlpremio = 168.13 where cdcooper = 14 and nrdconta = 16137469 and nrctrseg = 73658 and nrctrato = 107662 and tpseguro = 4;
update cecred.crapseg set vlpremio = 168.13 where cdcooper = 14 and nrdconta = 16137469 and nrctrseg = 73658 and tpseguro = 4;
update cecred.tbseg_prestamista set vlprodut = 168.13 where cdcooper = 14 and nrdconta = 16137469 and nrctrseg = 73658 and nrctremp = 107662;

update cecred.crawseg set vlpremio = 115.63 where cdcooper = 14 and nrdconta = 14451 and nrctrseg = 74543 and nrctrato = 107662 and tpseguro = 4;
update cecred.crapseg set vlpremio = 115.63 where cdcooper = 14 and nrdconta = 14451 and nrctrseg = 74543 and tpseguro = 4;
update cecred.tbseg_prestamista set vlprodut = 115.63 where cdcooper = 14 and nrdconta = 14451 and nrctrseg = 74543 and nrctremp = 107662;   

commit;
end;