-- Ajustar a situação de eventos que estão na situação 6 e deveriam estar na 5.
update crapagp ca 
set ca.idstagen = 5
where ca.idstagen = 6 
and ca.dtanoage = 2019
and ca.cdcooper = 8;

COMMIT;
