begin
	--INC0115263
	 update tbrisco_operacoes r
		set r.insituacao_rating = 4,
			r.dtrisco_rating    = r.dtrisco_rating_autom,
			r.inrisco_rating    = r.inrisco_rating_autom,
			r.flintegrar_sas    = 1
	  where r.cdcooper = 9
		and r.nrdconta = 450766
		and r.nrctremp = 113016
		and r.tpctrato = 1;

	 commit;
end;	