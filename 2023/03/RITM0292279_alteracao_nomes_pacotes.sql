begin
	update cecred.craptar ct set ct.dstarifa = 'TARIFA DE PACOTE DE SERVICOS BASICO' where ct.cdtarifa = 355;
	update cecred.craptar ct set ct.dstarifa = 'TARIFA DE PACOTE DE SERVICOS CLASSICO' where ct.cdtarifa = 366;
	update cecred.craptar ct set ct.dstarifa = 'TARIFA DE PACOTE DE SERVICOS COMPLETO' where ct.cdtarifa = 357;
	update cecred.craptar ct set ct.dstarifa = 'TARIFA DE PACOTE DE SERVICOS SUPER' where ct.cdtarifa = 358;
	commit;
end;