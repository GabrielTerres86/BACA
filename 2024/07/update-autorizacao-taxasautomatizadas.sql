begin
  
update CECRED.CRAPPRM
set    dsvlrprm = 'Basic dGF4YXNfYXV0b21hdGl6YWRhczpQYSQkcDBydDRMLjIwMTg='
where  cdacesso IN ('AUTHORIZATION_TAXA_SOA');

commit;
end;
