begin
UPDATE crapcrd SET crapcrd.cdcooper = 10
,crapcrd.nrdconta = 198676
,crapcrd.nrcpftit = 75357925968
,crapcrd.cdadmcrd = 15
WHERE crapcrd.nrcrcard = 5158940000199642;

UPDATE crawcrd SET crawcrd.cdcooper = 10
,crawcrd.nrdconta = 198676
,crawcrd.nrcpftit = 75357925968
,crawcrd.cdadmcrd = 15
WHERE crawcrd.nrcrcard = 5158940000199642;

COMMIT;

end;

