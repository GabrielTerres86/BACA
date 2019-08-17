BEGIN

  insert into CRAPPRM (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
       values ('CRED', 0, 'MANUAL_UTILIZACAO_API', 'Manual de utilização dos serviços de API Ailos', '/usr/coop/cecred/manualAPI/Manual - API de Cobranca v1.0.pdf');

  commit;

END;