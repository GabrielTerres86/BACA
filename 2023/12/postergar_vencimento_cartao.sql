BEGIN

  INSERT INTO cartao.tbcartao_validade_estendida
    (cdcooper
    ,dtvalidade
    ,dtestendida
    ,dtvigencia
    ,cdoperad
    ,dtinclusao)
  VALUES
    (3
    ,to_date('01-06-2016', 'dd-mm-yyyy')
    ,to_date('31-01-2030', 'dd-mm-yyyy')
    ,to_date('02-01-2021', 'dd-mm-yyyy')
    ,'1'
    ,to_date('08-06-2021 16:24:37', 'dd-mm-yyyy hh24:mi:ss'));

  COMMIT;

END;
