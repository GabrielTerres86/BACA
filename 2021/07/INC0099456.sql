begin
	UPDATE TBCC_LANCAMENTOS_PENDENTES LCT SET LCT.IDSITUACAO = 'M', LCT.DSCRITICA = 'INC0099456'
	WHERE LCT.IDSITUACAO = 'E' AND LCT.CDPESQBB = 'TARPIX' AND LCT.CDPRODUTO = 57;
	COMMIT;
end;