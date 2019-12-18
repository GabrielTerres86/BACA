begin

  delete from tbevento_grupos where cdcooper in (13,14);
  delete from tbevento_pessoa_grupos where cdcooper in (13,14);
  
  commit;

end;  