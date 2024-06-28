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
            o.inorigem_rating,
            o.cdoperad_rating,
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
       from tbrisco_operacoes o , squad_riscos.craplim l        
      WHERE o.cdcooper = 5
      AND l.cdcooper = o.cdcooper
      AND l.nrdconta = o.nrdconta
      AND l.nrctrlim = o.nrctremp
      AND l.TPCTRLIM = 1
      AND l.INSITLIM = 2
        AND o.nrdconta IN( 234478,16723260,17345855)
        AND o.tpctrato = 1;
    
    COMMIT;

END;