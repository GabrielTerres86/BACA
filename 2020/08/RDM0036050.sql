UPDATE crapass
SET nrdocptl = '931.738.184'
WHERE cdcooper = 1
AND nrdconta = 9853243 ;

UPDATE crapttl
SET nrdocttl = '931.738.184'
WHERE cdcooper = 1
AND nrdconta = 9853243 ;


UPDATE tbcadast_pessoa_fisica
SET nrdocumento = '931.738.184'
WHERE idpessoa = ( SELECT idpessoa FROM tbcadast_pessoa WHERE nrcpfcgc = 48634735915 );

commit;
