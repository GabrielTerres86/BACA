BEGIN

insert into cecred.crapcri (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA)
values (10608, '10608 - A devolu��o n�o pode ser realizada pois a solicita��o possui valores bloqueados n�o devolvidos', 1, 0);

insert into cecred.crapcri (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA)
values (10609, '10609 - O cancelamento n�o pode ser realizado pois a solicita��o possui valores devolvidos', 1, 0);

COMMIT;
END;
