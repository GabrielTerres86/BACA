BEGIN
  -- Realiza o cancelamento da Portabilidade.
  UPDATE tbcc_portabilidade_recebe
     SET idsituacao         = 5 -- Cancelada
        , cdoperador        = 1
        , dtavaliacao       = to_date('31/03/2021', 'dd/mm/rrrr')
  WHERE nrnu_portabilidade = 201812210000078066701;
  -- 
  -- Eliminar o log do erro.
  DELETE tbcc_portabilidade_rcb_erros 
  WHERE nrnu_portabilidade = 201812210000078066701;
  --
  COMMIT;
  --
  DBMS_OUTPUT.PUT_LINE('Sucesso na atualização.');
  --
EXCEPTION
  WHEN OTHERS THEN
    --
    ROLLBACK;
    --
    RAISE_APPLICATION_ERROR(-20000, 'Erro ao executar script: ' || SQLERRM);
    --
END;
