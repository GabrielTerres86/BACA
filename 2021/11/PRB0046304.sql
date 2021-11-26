begin

begin

/* Atualizar o parâmetro para "S" */

update crapprm
set dsvlrprm = 'S'
WHERE cdcooper = 8
AND nmsistem = 'CRED'
AND cdacesso = 'FL_EXECUTADO_674';

end;

begin

/* Atualizar o parâmetro contador da quantidade de execuções do dia */

UPDATE	crapprm p
SET	p.DSVLRPRM	= '22/10/2021#0'
WHERE	p.CDACESSO	IN
	('CTRL_CRPS674_EXEC')
AND	p.cdcooper	= 8;

end;

begin

/* Inserir saldo diário nas contas */

insert into crapsda (nrdconta
          ,dtmvtolt
          ,vlsddisp
          ,vlsdchsl
          ,vlsdbloq
          ,vlsdblpr
          ,vlsdblfp
          ,vlsdindi
          ,vllimcre
          ,cdcooper
          ,vlsdeved
          ,vldeschq
          ,vllimutl
          ,vladdutl
          ,vlsdrdca
          ,vlsdrdpp
          ,vllimdsc
          ,vlprepla
          ,vlprerpp
          ,vlcrdsal
          ,qtchqliq
          ,qtchqass
          ,dtdsdclq
          ,vltotpar
          ,vlopcdia
          ,vlavaliz
          ,vlavlatr
          ,qtdevolu
          ,vltotren
          ,vldestit
          ,vllimtit
          ,vlsdempr
          ,vlsdfina
          ,vlsrdc30
          ,vlsrdc60
          ,vlsrdcpr
          ,vlsrdcpo
          ,vlsdcota)
SELECT sda.nrdconta
          ,to_date('21/10/2021','dd/mm/rrrr')
          ,sda.vlsddisp
          ,sda.vlsdchsl
          ,sda.vlsdbloq
          ,sda.vlsdblpr
          ,sda.vlsdblfp
          ,sda.vlsdindi
          ,sda.vllimcre
          ,sda.cdcooper
          ,sda.vlsdeved
          ,sda.vldeschq
          ,sda.vllimutl
          ,sda.vladdutl
          ,sda.vlsdrdca
          ,sda.vlsdrdpp
          ,sda.vllimdsc
          ,sda.vlprepla
          ,sda.vlprerpp
          ,sda.vlcrdsal
          ,sda.qtchqliq
          ,sda.qtchqass
          ,sda.dtdsdclq
          ,sda.vltotpar
          ,sda.vlopcdia
          ,sda.vlavaliz
          ,sda.vlavlatr
          ,sda.qtdevolu
          ,sda.vltotren
          ,sda.vldestit
          ,sda.vllimtit
          ,sda.vlsdempr
          ,sda.vlsdfina
          ,sda.vlsrdc30
          ,sda.vlsrdc60
          ,sda.vlsrdcpr
          ,sda.vlsrdcpo
          ,sda.vlsdcota
FROM tbcrd_fatura fat, crapsda sda
WHERE fat.cdcooper = 8
and fat.nrdconta = sda.nrdconta
and fat.cdcooper = sda.cdcooper
and sda.dtmvtolt = (select max(b.dtmvtolt) from crapsda b where b.nrdconta = fat.nrdconta and b.cdcooper = sda.cdcooper)
AND fat.insituacao = 1
AND (trunc(fat.dtvencimento) BETWEEN to_date('21/10/2021','dd/mm/yyyy') AND to_date('22/10/2021','dd/mm/yyyy'));

end;

commit;

end;