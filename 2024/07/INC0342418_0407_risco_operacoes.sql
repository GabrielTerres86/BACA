BEGIN

    INSERT INTO tbrisco_operacoes a (cdcooper,
            nrdconta,
            nrctremp,
            tpctrato,
            inrisco_inclusao,
            inrisco_calculado,
            inrisco_melhora,
            dtrisco_melhora,
            cdcritica_melhora,
            dtrisco_rating_autom,
            inrisco_rating,
            inrisco_rating_autom,
            dtrisco_rating,
            insituacao_rating,
            inorigem_rating,
            cdoperad_rating,
            innivel_rating,
            nrcpfcnpj_base,
            inpontos_rating,
            insegmento_rating,
            inrisco_rat_inc,
            innivel_rat_inc,
            inpontos_rat_inc,
            insegmento_rat_inc,
            flintegrar_sas,
            flencerrado,
            dtvencto_rating,
            qtdiasvencto_rating,
            inpessoa,
            idrating,
            dsclasse_rating,
            qtparcelas_controle_riscomelhora,
            dhalteracao,
            dhtransmissao)
     select o.cdcooper,
            o.nrdconta,
            o.nrdconta nrctremp,
            11 tpctrato,
            o.inrisco_inclusao,
            o.inrisco_calculado,
            o.inrisco_melhora,
            o.dtrisco_melhora,
            o.cdcritica_melhora,
            o.dtrisco_rating_autom,
            o.inrisco_rating,
            o.inrisco_rating_autom,
            o.dtrisco_rating,
            o.insituacao_rating,
            5 inorigem_rating,
            1 cdoperad_rating,
            o.innivel_rating,
            o.nrcpfcnpj_base,
            o.inpontos_rating,
            o.insegmento_rating,
            o.inrisco_rat_inc,
            o.innivel_rat_inc,
            o.inpontos_rat_inc,
            o.insegmento_rat_inc,
            o.flintegrar_sas,
            o.flencerrado,
            o.dtvencto_rating,
            o.qtdiasvencto_rating,
            o.inpessoa,
            o.idrating,
            o.dsclasse_rating,
            o.qtparcelas_controle_riscomelhora,
            o.dhalteracao,
            NULL dhtransmissao
       from tbrisco_operacoes o , craplim l        
        WHERE  l.cdcooper = o.cdcooper
        AND l.nrdconta = o.nrdconta
        AND l.nrctrlim = o.nrctremp
        AND l.tpctrlim = 1
        AND l.insitlim = 2		
		AND o.tpctrato = 1        
        AND ((o.cdcooper = 2 AND o.nrdconta = 401528)
          OR (o.cdcooper = 5 AND o.nrdconta = 15641562));
		  
    COMMIT;

END;