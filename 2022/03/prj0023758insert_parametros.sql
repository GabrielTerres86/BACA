BEGIN
  INSERT INTO crapprm
    (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES
    ('CRED',
     3,
     'PINPAD_MIGRA_PA',
     'Habilitar / Desabilitar as cooperativas e os PAs para utilizar o pinpad em outros navegadores',
     '0');
  COMMIT;
  
  insert into crapaca (nmdeacao, nmpackag,nmproced,lstparam,nrseqrdr ) 
	values ('OBTER_SCRIPT_PINPAD','TELA_ATENDA_CARTAOCREDITO','pc_obter_param_cartao',
	'pr_cdcooper,pr_cdagenci',(SELECT a.nrseqrdr
	FROM craprdr a 
	WHERE a.nmprogra = 'ATENDA_CRD'
	AND ROWNUM = 1));

   COMMIT;
END;

