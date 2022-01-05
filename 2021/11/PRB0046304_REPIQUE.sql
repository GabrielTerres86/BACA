begin

begin

/* Inserir saldo diário nas contas para REPIQUE */

update crapsda x
set x.vlsddisp = 
    (select fat.vlpendente
    FROM tbcrd_fatura fat
WHERE fat.cdcooper = 8
and fat.nrdconta = x.nrdconta
and fat.cdcooper = x.cdcooper
AND fat.insituacao <> 3
and fat.nrdconta in (47520,50105,49247,44890,53074)
AND (trunc(fat.dtvencimento) BETWEEN to_date('21/10/2021','dd/mm/yyyy') AND to_date('22/10/2021','dd/mm/yyyy'))
    )
where x.rowid in
      (select sda.rowid
FROM tbcrd_fatura fat, crapsda sda
WHERE fat.cdcooper = 8
and fat.nrdconta = sda.nrdconta
and fat.cdcooper = sda.cdcooper
and sda.dtmvtolt >= fat.dtvencimento
AND fat.insituacao <> 3
and fat.nrdconta in (47520,50105,49247,44890,53074)
AND (trunc(fat.dtvencimento) BETWEEN to_date('21/10/2021','dd/mm/yyyy') AND to_date('22/10/2021','dd/mm/yyyy'))
);

/* Atualizar o parâmetro contador da quantidade de execuções do dia para REPIQUE */

end;

begin

update crapdat dat
set	dat.dtmvtolt	= to_date('25/10/2021','dd/mm/yyyy'),
	dat.dtmvtoan	= to_date('22/10/2021','dd/mm/yyyy'),
	dat.dtmvtocd	= to_date('25/10/2021','dd/mm/yyyy')
WHERE  dat.cdcooper  = 8;

end;

commit;

end;