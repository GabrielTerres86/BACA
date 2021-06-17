update crapcyb x
set x.flgpreju = 0, x.dtatufin = '01/01/2021'
where x.nrdconta = 709204 and x.nrctremp in (145431,145404) and x.cdorigem = 3;
/
update crapcyb x
set x.flgpreju = 0, x.dtatufin = '01/01/2021'
where x.nrdconta = 709131 and x.nrctremp in (145402,145428,145508) and x.cdorigem = 3;
/
update crapcyb x
set x.flgpreju = 0, x.dtatufin = '01/01/2021'
where x.nrdconta = 710415 and x.nrctremp in (145437) and x.cdorigem = 3;
/
commit;
