begin
	update cecred.Tbtarif_Contas_Pacote tcp1 set tcp1.flgsituacao = 2 where exists (select tcp2.nrdconta from cecred.crapass ca
	inner join cecred.Tbtarif_Contas_Pacote tcp2 on tcp2.nrdconta = ca.nrdconta and tcp2.cdcooper = ca.cdcooper
	where ca.dtdemiss is not null
	and tcp2.flgsituacao = 1
	and tcp1.cdcooper = tcp2.cdcooper
	and tcp1.nrdconta = tcp2.nrdconta
	and tcp1.cdpacote = tcp2.cdpacote
	and tcp1.flgsituacao = tcp2.flgsituacao);
	commit;
end;