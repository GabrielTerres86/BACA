-- Projeto: P687 - API E-COMMERCE
-- Objetivo: Criar produto COMPRAS - E-COMMERCE
--           Disponibilizar produto API de Compras E-COMMERCE para o AIMARO;
-- Autor: Rafael Cechet
-- Data: 18/11/2019
declare
  vr_cdproduto tbcc_produto.cdproduto%type;  
begin
  
  select nvl(max(cdproduto),0)+1 into vr_cdproduto from tbcc_produto;
  
  if nvl(vr_cdproduto,0) in (0,1) then 
    vr_cdproduto := 48;
  end if;
  
  insert into tbcc_produto (CDPRODUTO, DSPRODUTO, FLGITEM_SOA, FLGUTILIZA_INTERFACE_PADRAO, FLGENVIA_SMS, FLGCOBRA_TARIFA, IDFAIXA_VALOR, FLGPRODUTO_API)
	values (vr_cdproduto, 'COMPRAS - E-COMMERCE', 0, 0, 1, 0, 0, 1);
	
  insert into tbapi_produto_servico (IDSERVICO_API, CDPRODUTO, DSSERVICO_API, IDAPI_COOPERADO, DSPERMISSAO_API)
	values (2, vr_cdproduto, 'API DE COMPRAS E-COMMERCE', 1, 'api-pagamento-debitoautorizado');
	
end;