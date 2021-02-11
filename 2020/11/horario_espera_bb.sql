INSERT
  INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
        VALUES('CRED', 1, 'HORLIMPROC_JOB', 'Horarios de espera do arquivo do bb, HORARIO da TAB;HORARIO do FIM do MES e PRIMEIRO dia util','16200;7200');
        
INSERT
  INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
        VALUES( 'CRED'
              , 1
              , 'LST_EMAIL_HORLIMPROC'
              , 'Lista de emails para recebimento a atualização do parametro de horario da espera dos arquivos bb'
              , 'plantonistas@ailos.coop.br, jhonatan.moraes@ailos.coop.br, ederson@ailos.coop.br');

COMMIT;
