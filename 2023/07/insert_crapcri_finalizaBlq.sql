BEGIN

insert into cecred.crapcri (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA)
values (10608, '10608 - A devolução não pode ser realizada pois a solicitação possui valores bloqueados não devolvidos', 1, 0);

insert into cecred.crapcri (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA)
values (10609, '10609 - O cancelamento não pode ser realizado pois a solicitação possui valores devolvidos', 1, 0);

COMMIT;
END;
