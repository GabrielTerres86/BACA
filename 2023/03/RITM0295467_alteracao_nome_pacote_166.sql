begin
	update cecred.TBTARIF_PACOTES pct set pct.dspacote = 'PACOTE DE SERVICOS PJ COMPLETA' where pct.cdpacote = 166;
	commit;
end;