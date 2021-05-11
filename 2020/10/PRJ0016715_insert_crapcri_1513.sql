BEGIN
  INSERT INTO cecred.crapcri
    (cdcritic
    ,dscritic
    ,tpcritic)
  VALUES
    ('1513'
    ,'1513 - Sistema não permite acordos com mais de 1 operação'
    ,1);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20100,
                            'Erro na criacao no cadastro de critica (CECRED.CRAPCRI) - ' ||
                            SQLERRM);
END;
