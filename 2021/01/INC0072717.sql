BEGIN
  -- Atualizar apenas um registro
  -- Realiza o cancelamento da Portabilidade.
  UPDATE tbcc_portabilidade_recebe
     SET idsituacao         = 5
        , cdoperador        = 1
        , dtavaliacao       = to_date('11/11/2020', 'dd/mm/rrrr')
        , dsdominio_motivo  = 'MOTVREPRVCPORTDDCTSALR'
        , cdmotivo          = '7' -- Conta informada não permite transferência
  WHERE nrnu_portabilidade = 202011110000168137528;
  -- 
  -- Eliminar apenas um registro.
  -- Eliminar o log do erro.
  DELETE tbcc_portabilidade_rcb_erros 
  WHERE nrnu_portabilidade = 202011110000168137528;
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
