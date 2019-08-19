DECLARE

BEGIN

  /*
  Regime Tributária Aimaro e SOA
  1-Simples Nacional
  2-Lucro Real
  3-Lucro Presumido
  4-MEI
  */

  DELETE FROM tbcadast_dominio_campo
   WHERE NMDOMINIO = 'TPREGIME_TRIBUTACAO';

  INSERT INTO tbcadast_dominio_campo
    (NMDOMINIO,
     CDDOMINIO,
     DSCODIGO)
  VALUES
    ('TPREGIME_TRIBUTACAO',
     '1',
     'Simples Nacional');

  INSERT INTO tbcadast_dominio_campo
    (NMDOMINIO,
     CDDOMINIO,
     DSCODIGO)
  VALUES
    ('TPREGIME_TRIBUTACAO',
     '2',
     'Lucro Real');

  INSERT INTO tbcadast_dominio_campo
    (NMDOMINIO,
     CDDOMINIO,
     DSCODIGO)
  VALUES
    ('TPREGIME_TRIBUTACAO',
     '3',
     'Lucro Presumido');

  INSERT INTO tbcadast_dominio_campo
    (NMDOMINIO,
     CDDOMINIO,
     DSCODIGO)
  VALUES
    ('TPREGIME_TRIBUTACAO',
     '4',
     'MEI');

  COMMIT;

END;
