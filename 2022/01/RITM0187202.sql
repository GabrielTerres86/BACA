begin
  insert into tbgen_cnae
    (cdcnae, dscnae, flserasa)
  values
    (4541207, 'Comercio e Varejo de pecas e acessorios usados para motocicletas e motonetas', 1);


	update crapttl
	set nmextttl = 'TERESINHA ZEZULKA'
	where cdcooper = 6
	and nrdconta = 663
	and idseqttl = 2;	
	
  commit;
end;