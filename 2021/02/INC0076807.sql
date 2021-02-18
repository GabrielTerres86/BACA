/* INC0076620 - Atualizar o retorno da CIP para o boleto*/

BEGIN


	UPDATE tbcadast_pessoa_atualiza
	SET INSIT_ATUALIZA = 1
	where cdcooper = 11
	and nrdconta = 722324
	AND INSIT_ATUALIZA = 3;
	
	update tbgen_inconsist_email_grp
	set dsendereco_email = 'luis.feltrin@ailos.coop.br; ramon.silva@ailos.coop.br'
	where idinconsist_grp = 3	
  
  COMMIT;
END;  
