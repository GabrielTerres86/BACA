begin
  update cecred.crawseg p set p.NMBAIRRO = 'CENTRO' where p.nrproposta = '202412282210';
  update cecred.tbseg_prestamista p set p.NMBAIRRO = 'CENTRO' where p.nrproposta = '202412282210';

  update cecred.crawseg p SET P.NMBAIRRO = 'CENTRO HISTORICO', P.NRCEPEND = 83203200 where p.nrproposta = '202423538376';
  update cecred.tbseg_prestamista p SET P.NMBAIRRO = 'CENTRO HISTORICO', P.NRCEPEND = 83203200 where p.nrproposta = '202423538376';
  
  commit;
  
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 16 and p.nrdconta = 3120953 and p.nrctrseg = 54533;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 16 and p.nrdconta = 3120953 and p.nrctrseg = 54286;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 16 and p.nrdconta = 3120953 and p.nrctrseg = 54531;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 16 and p.nrdconta = 673838 and p.nrctrseg = 237393;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 16 and p.nrdconta = 673838 and p.nrctrseg = 235281;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 13 and p.nrdconta = 272 and p.nrctrseg = 142804;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 13 and p.nrdconta = 46051 and p.nrctrseg = 436861;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 13 and p.nrdconta = 655899 and p.nrctrseg = 489635;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 7 and p.nrdconta = 148059 and p.nrctrseg = 80912;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 2 and p.nrdconta = 606499 and p.nrctrseg = 116524;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 13 and p.nrdconta = 635715 and p.nrctrseg = 260965;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 2 and p.nrdconta = 1081438 and p.nrctrseg = 182810;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 13 and p.nrdconta = 76252 and p.nrctrseg = 252209;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 14 and p.nrdconta = 52035 and p.nrctrseg = 34539;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 14 and p.nrdconta = 264474 and p.nrctrseg = 39405;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 11 and p.nrdconta = 746827 and p.nrctrseg = 181258;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 13 and p.nrdconta = 86134 and p.nrctrseg = 379711;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 14 and p.nrdconta = 55794 and p.nrctrseg = 56937;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 2 and p.nrdconta = 15735630 and p.nrctrseg = 273493;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 2 and p.nrdconta = 740462 and p.nrctrseg = 266068;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 11 and p.nrdconta = 934658 and p.nrctrseg = 260312;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 2 and p.nrdconta = 523801 and p.nrctrseg = 266611;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 6 and p.nrdconta = 241148 and p.nrctrseg = 93575;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 6 and p.nrdconta = 147729 and p.nrctrseg = 97675;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 13 and p.nrdconta = 46051 and p.nrctrseg = 436871;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 14 and p.nrdconta = 16118324 and p.nrctrseg = 67416;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 9 and p.nrdconta = 323420 and p.nrctrseg = 51465;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 16 and p.nrdconta = 3540774 and p.nrctrseg = 363232;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 11 and p.nrdconta = 14456923 and p.nrctrseg = 317104;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 11 and p.nrdconta = 15685985 and p.nrctrseg = 310653;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 12 and p.nrdconta = 16876482 and p.nrctrseg = 67239;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 16 and p.nrdconta = 3611159 and p.nrctrseg = 336842;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 13 and p.nrdconta = 553018 and p.nrctrseg = 519586;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 11 and p.nrdconta = 460958 and p.nrctrseg = 335358;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 16 and p.nrdconta = 17654050 and p.nrctrseg = 359732;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 13 and p.nrdconta = 316032 and p.nrctrseg = 524275;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 11 and p.nrdconta = 577936 and p.nrctrseg = 358975;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 11 and p.nrdconta = 535338 and p.nrctrseg = 356125;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 11 and p.nrdconta = 15735265 and p.nrctrseg = 356580;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 11 and p.nrdconta = 535338 and p.nrctrseg = 356121;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 11 and p.nrdconta = 16337476 and p.nrctrseg = 357804;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 13 and p.nrdconta = 272469 and p.nrctrseg = 154643;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 2 and p.nrdconta = 15224384 and p.nrctrseg = 391539;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 5 and p.nrdconta = 297704 and p.nrctrseg = 139798;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 14 and p.nrdconta = 14493195 and p.nrctrseg = 65867;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 6 and p.nrdconta = 65552 and p.nrctrseg = 124993;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 11 and p.nrdconta = 585297 and p.nrctrseg = 423766;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 2 and p.nrdconta = 719951 and p.nrctrseg = 448423;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 13 and p.nrdconta = 73059 and p.nrctrseg = 611354;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 13 and p.nrdconta = 16385071 and p.nrctrseg = 526016;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 2 and p.nrdconta = 719951 and p.nrctrseg = 411202;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 14 and p.nrdconta = 16485386 and p.nrctrseg = 133344;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 12 and p.nrdconta = 59366 and p.nrctrseg = 92532;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 8 and p.nrdconta = 44210 and p.nrctrseg = 28808;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 16 and p.nrdconta = 742260 and p.nrctrseg = 455294;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 16 and p.nrdconta = 742260 and p.nrctrseg = 455295;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 11 and p.nrdconta = 1025350 and p.nrctrseg = 457243;
  update cecred.crapseg p  set p.DTCANCEL = to_date('01/10/2024','dd/mm/yyyy') where p.cdcooper = 16 and p.nrdconta = 6077030 and p.nrctrseg = 456377;
 
  commit; 
end;
