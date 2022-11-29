BEGIN

insert into CECRED.crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM )
values ('CRED', 0, 'COD_FOLHA_RENDA', 'Codigos da Folha de Pgto desconsiderados nas rendas', '1820,1821,1822,1829,1831,1833,1830,2104,2105,3398' );


COMMIT;

END;
