begin

	UPDATE tbgrv_registro_contrato x SET dsc_identificador = 20200010100001 WHERE  x.cdcooper = 8 AND x.nrdconta = 4715 AND x.NRCTRPRO = 8858 AND x.idseqbem = 19;

	commit;

end;