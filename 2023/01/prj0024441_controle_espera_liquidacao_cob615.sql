BEGIN
  INSERT INTO crapprm
    (NMSISTEM
    ,CDCOOPER
    ,CDACESSO
    ,DSTEXPRM
    ,DSVLRPRM)
  VALUES
    ('CRED'
    ,0
    ,'CTRL_LQD_COB615'
    ,'Quantidade de tempo em segundos para esperar validação do controle de liquidação do COB615'
    ,'10');

  INSERT INTO COBRANCA.tbcobran_controle_diario_liquidacao
   (dtreferencia
   ,tpmarco
   ,dsobservacao)
 VALUES
   (to_date('26/05/2023', 'DD/MM/RRRR')
   ,1
   ,'Implantacao MLC');

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_compleme => 'PRJ0024441');
    ROLLBACK;
END;
