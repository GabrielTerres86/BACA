BEGIN
  
insert into tbcc_produto (CDPRODUTO, DSPRODUTO, FLGITEM_SOA, FLGUTILIZA_INTERFACE_PADRAO, FLGENVIA_SMS, FLGCOBRA_TARIFA, IDFAIXA_VALOR, FLGPRODUTO_API)
values ((SELECT MAX(p.cdproduto) + 1 FROM tbcc_produto p), 'TARIFA PIX', 0, 0, 0, 0, 0, 1);
COMMIT;
EXCEPTION 
  WHEN OTHERS THEN
    NULL;
END;