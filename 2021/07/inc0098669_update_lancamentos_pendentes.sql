begin
	update tbcc_lancamentos_pendentes set idsituacao = 'M', dscritica = 'INC0098669' where nrdcmto = 20021158;
  commit;
end;
