BEGIN
  INSERT INTO cecred.tbgen_dominio_campo
    (nmdominio
    ,cddominio
    ,dscodigo)
  VALUES
    ('CDMODELO_SCORE'
    ,'1'
    ,'Score de Credito PJ');

  INSERT INTO cecred.tbgen_dominio_campo
    (nmdominio
    ,cddominio
    ,dscodigo)
  VALUES
    ('CDMODELO_SCORE'
    ,'2'
    ,'Score de Credito PF Segmentando 12');

  INSERT INTO cecred.tbgen_dominio_campo
    (nmdominio
    ,cddominio
    ,dscodigo)
  VALUES
    ('CDMODELO_SCORE'
    ,'3'
    ,'Score Comportamental');

  INSERT INTO cecred.tbgen_dominio_campo
    (nmdominio
    ,cddominio
    ,dscodigo)
  VALUES
    ('CDMODELO_SCORE'
    ,'4'
    ,'Score de Recuperacao de Credito');

  INSERT INTO cecred.tbgen_dominio_campo
    (nmdominio
    ,cddominio
    ,dscodigo)
  VALUES
    ('CDMODELO_SCORE'
    ,'5'
    ,'Score de Propensao de Cheque Especial');

  INSERT INTO cecred.tbgen_dominio_campo
    (nmdominio
    ,cddominio
    ,dscodigo)
  VALUES
    ('CDMODELO_SCORE'
    ,'6'
    ,'Score de Propensao de Deposito a Prazo');

  INSERT INTO cecred.tbgen_dominio_campo
    (nmdominio
    ,cddominio
    ,dscodigo)
  VALUES
    ('CDMODELO_SCORE'
    ,'7'
    ,'Score de Propensao de Pre-Inativacao');

  INSERT INTO cecred.tbgen_dominio_campo
    (nmdominio
    ,cddominio
    ,dscodigo)
  VALUES
    ('CDMODELO_SCORE'
    ,'8'
    ,'Score de Propensao de Capital de Giro');

  INSERT INTO cecred.tbgen_dominio_campo
    (nmdominio
    ,cddominio
    ,dscodigo)
  VALUES
    ('CDMODELO_SCORE'
    ,'9'
    ,'Vinculacao');

  INSERT INTO cecred.tbgen_dominio_campo
    (nmdominio
    ,cddominio
    ,dscodigo)
  VALUES
    ('CDMODELO_SCORE'
    ,'10'
    ,'Score de Recuperacao de Credito 31 a 60');
    
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
