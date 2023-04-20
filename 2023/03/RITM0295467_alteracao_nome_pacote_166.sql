begin
	update cecred.TBTARIF_PACOTES pct set pct.dspacote = 'PACOTE DE SERVICOS PJ COMPLETA' where pct.cdpacote = 166;
	update cecred.TBTARIF_PACOTES pct set pct.dspacote = 'PACOTE DE SERVICOS BASICO PF' where pct.cdpacote = 187;
	update cecred.TBTARIF_PACOTES pct set pct.dspacote = 'PACOTE DE SERVICOS ESSENCIAL PF' where pct.cdpacote = 188;
	update cecred.TBTARIF_PACOTES pct set pct.dspacote = 'PACOTE DE SERVICOS COMPLETO PF' where pct.cdpacote = 189;
	update cecred.TBTARIF_PACOTES pct set pct.dspacote = 'PACOTE DE SERVICOS EMPREENDEDOR PJ MEI' where pct.cdpacote = 190;
	update cecred.TBTARIF_PACOTES pct set pct.dspacote = 'PACOTE DE SERVICOS BASICO PJ' where pct.cdpacote = 191;
	update cecred.TBTARIF_PACOTES pct set pct.dspacote = 'PACOTE DE SERVICOS ESSENCIAL PJ' where pct.cdpacote = 192;
	update cecred.TBTARIF_PACOTES pct set pct.dspacote = 'PACOTE DE SERVICOS COMPLETO PJ' where pct.cdpacote = 193;
	
	update cecred.craptar ct set ct.dstarifa = 'TARIFA PACOTE DE SERVICOS BASICO PF' where ct.cdtarifa = 536;
	update cecred.craptar ct set ct.dstarifa = 'TARIFA PACOTE DE SERVICOS ESSENCIAL PF' where ct.cdtarifa = 537;
	update cecred.craptar ct set ct.dstarifa = 'TARIFA PACOTE DE SERVICOS COMPLETO PF' where ct.cdtarifa = 538;
	update cecred.craptar ct set ct.dstarifa = 'TARIFA PACOTE DE SERVICOS EMPREENDEDOR PJ MEI' where ct.cdtarifa = 539;
	update cecred.craptar ct set ct.dstarifa = 'TARIFA PACOTE DE SERVICOS BASICO PJ' where ct.cdtarifa = 540;
	update cecred.craptar ct set ct.dstarifa = 'TARIFA PACOTE DE SERVICOS ESSENCIAL PJ' where ct.cdtarifa = 541;
	update cecred.craptar ct set ct.dstarifa = 'TARIFA PACOTE DE SERVICOS COMPLETO PJ' where ct.cdtarifa = 542;
	commit;
end;