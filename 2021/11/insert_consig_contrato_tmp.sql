BEGIN

insert into TBEPR_CONSIG_CONTRATO_TMP (CDCOOPER, NRDCONTA, NRCTREMP, DTMOVIMENTO, DTGRAVACAO, INCLIDESLIGADO, VLIOFEPR, VLIOFADIC, QTPRESTPAGAS, VLJURAMESATU, VLJURAMESANT, VLSDEV_EMPRATU_D0, VLSDEV_EMPRATU_D1, VLJURA60DIAS, INSTATUSCONTR, INSTATUSPROCES, DSERROPROCES)
values (2, 643017, 297340, to_date('04-11-2021', 'dd-mm-yyyy'), to_date('02-11-2021', 'dd-mm-yyyy'), 'N', 926.71, 134.40, 3, 0.00, 0.00, 36580.79, 36598.28, 3197.99, '1', null, null);

COMMIT;

END;