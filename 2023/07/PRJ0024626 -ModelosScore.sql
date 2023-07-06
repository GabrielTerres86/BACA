BEGIN
  INSERT INTO cecred.tbgen_dominio_campo
    (nmdominio
    ,cddominio
    ,dscodigo)
  VALUES
    ('CDMODELO_SCORE'
    ,'1'
    ,'Score de Cr�dito PJ');

  INSERT INTO cecred.tbgen_dominio_campo
    (nmdominio
    ,cddominio
    ,dscodigo)
  VALUES
    ('CDMODELO_SCORE'
    ,'2'
    ,'Score de Cr�dito PF Segmentando 12');

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
    ,'Score de Recupera��o de Cr�dito');

  INSERT INTO cecred.tbgen_dominio_campo
    (nmdominio
    ,cddominio
    ,dscodigo)
  VALUES
    ('CDMODELO_SCORE'
    ,'5'
    ,'Score de Propens�o de Cheque Especial');

  INSERT INTO cecred.tbgen_dominio_campo
    (nmdominio
    ,cddominio
    ,dscodigo)
  VALUES
    ('CDMODELO_SCORE'
    ,'6'
    ,'Score de Propens�o de Dep�sito a Prazo');

  INSERT INTO cecred.tbgen_dominio_campo
    (nmdominio
    ,cddominio
    ,dscodigo)
  VALUES
    ('CDMODELO_SCORE'
    ,'7'
    ,'Score de Propens�o de Pr�-Inativa��o');

  INSERT INTO cecred.tbgen_dominio_campo
    (nmdominio
    ,cddominio
    ,dscodigo)
  VALUES
    ('CDMODELO_SCORE'
    ,'8'
    ,'Score de Propens�o de Capital de Giro');

  INSERT INTO cecred.tbgen_dominio_campo
    (nmdominio
    ,cddominio
    ,dscodigo)
  VALUES
    ('CDMODELO_SCORE'
    ,'9'
    ,'Vincula��o');

  INSERT INTO cecred.tbgen_dominio_campo
    (nmdominio
    ,cddominio
    ,dscodigo)
  VALUES
    ('CDMODELO_SCORE'
    ,'10'
    ,'Score de Recupera��o de Cr�dito 31 a 60');
    
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
