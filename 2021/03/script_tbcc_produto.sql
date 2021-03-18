DECLARE 
  vr_max_prod NUMBER(5);
BEGIN 
      SELECT MAX(cdproduto)+1 INTO vr_max_prod FROM tbcc_produto;
    
      INSERT INTO tbcc_produto
      SELECT NVL(vr_max_prod,56)    cdproduto,
             'LIMITE CREDITO PRE-APROVADO' dsproduto,
             a.flgitem_soa,
             a.flgutiliza_interface_padrao,
             a.flgenvia_sms,
             a.flgcobra_tarifa,
             a.idfaixa_valor,
             a.flgproduto_api
      FROM tbcc_produto a
      WHERE a.cdproduto = 25;
      

      INSERT INTO tbcc_operacoes_produto (CDPRODUTO, CDOPERAC_PRODUTO, DSOPERAC_PRODUTO, TPCONTROLE)
      VALUES  (NVL(vr_max_prod,56), 1, 'Limite Credito Pre-Aprovado Liberado', '2');

      COMMIT;

      
END;

