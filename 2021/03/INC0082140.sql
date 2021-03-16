BEGIN


delete from  CRAPCEM
WHERE CDCOOPER = 1
AND NRDCONTA = 7268203
AND CDDEMAIL = 1;



update tbcadast_pessoa_email
set dsemail = 'aliatan.matheusg@gmail.com'
where idpessoa = 2276290
and nrseq_email = 1;

 
 COMMIT;
 
END;