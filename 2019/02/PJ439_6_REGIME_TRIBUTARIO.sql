declare 

begin
  
  /*
  Regime Tributária Aimaro e SOA
  1-Simples Nacional
  2-Lucro Real
  3-Lucro Presumido
  4-MEI
  */

  delete from tbcadast_dominio_campo where NMDOMINIO='TPREGIME_TRIBUTACAO';
  
  insert into tbcadast_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('TPREGIME_TRIBUTACAO', '1', 'Simples Nacional');

  insert into tbcadast_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('TPREGIME_TRIBUTACAO', '2', 'Lucro Real');

  insert into tbcadast_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('TPREGIME_TRIBUTACAO', '3', 'Lucro Presumido');

  insert into tbcadast_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('TPREGIME_TRIBUTACAO', '4', 'MEI');
  
  commit;
  
end;