-- Tela
delete craptel where craptel.cdcooper = 3 and craptel.nmdatela = 'MOVCMP';

commit;

insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL)
values ('MOVCMP', 3, 'M,P', 'Movimento dos documentos da compensação', 'Movimento dos documentos da compensação', 0, 1, ' ', 'MOVIMENTO,PROTOCOLO', 1, 3, 1, 0, 0, 0, null, 2);

commit;
