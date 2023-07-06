BEGIN
  INSERT INTO cecred.tbgen_dominio_campo
    (nmdominio
    ,cddominio
    ,dscodigo)
  VALUES
    ('CDMODELO_SCORE'
    ,'1'
    ,'Score de Crédito PJ');

  INSERT INTO cecred.tbgen_dominio_campo
    (nmdominio
    ,cddominio
    ,dscodigo)
  VALUES
    ('CDMODELO_SCORE'
    ,'2'
    ,'Score de Crédito PF Segmentando 12');

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
    ,'Score de Recuperação de Crédito');

  INSERT INTO cecred.tbgen_dominio_campo
    (nmdominio
    ,cddominio
    ,dscodigo)
  VALUES
    ('CDMODELO_SCORE'
    ,'5'
    ,'Score de Propensão de Cheque Especial');

  INSERT INTO cecred.tbgen_dominio_campo
    (nmdominio
    ,cddominio
    ,dscodigo)
  VALUES
    ('CDMODELO_SCORE'
    ,'6'
    ,'Score de Propensão de Depósito a Prazo');

  INSERT INTO cecred.tbgen_dominio_campo
    (nmdominio
    ,cddominio
    ,dscodigo)
  VALUES
    ('CDMODELO_SCORE'
    ,'7'
    ,'Score de Propensão de Pré-Inativação');

  INSERT INTO cecred.tbgen_dominio_campo
    (nmdominio
    ,cddominio
    ,dscodigo)
  VALUES
    ('CDMODELO_SCORE'
    ,'8'
    ,'Score de Propensão de Capital de Giro');

  INSERT INTO cecred.tbgen_dominio_campo
    (nmdominio
    ,cddominio
    ,dscodigo)
  VALUES
    ('CDMODELO_SCORE'
    ,'9'
    ,'Vinculação');

  INSERT INTO cecred.tbgen_dominio_campo
    (nmdominio
    ,cddominio
    ,dscodigo)
  VALUES
    ('CDMODELO_SCORE'
    ,'10'
    ,'Score de Recuperação de Crédito 31 a 60');
    
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
