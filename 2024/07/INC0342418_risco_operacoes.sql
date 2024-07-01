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
       from tbrisco_operacoes o , craplim l        
        WHERE  l.cdcooper = o.cdcooper
        AND l.nrdconta = o.nrdconta
        AND l.nrctrlim = o.nrctremp
        AND l.tpctrlim = 1
        AND l.insitlim = 2		
		AND o.tpctrato = 1        
        AND ((o.cdcooper = 14 AND o.nrdconta = 17638160)
          OR (o.cdcooper = 14 AND o.nrdconta = 396257)
          OR (o.cdcooper = 14 AND o.nrdconta = 395390)
          OR (o.cdcooper = 14 AND o.nrdconta = 18105637)
          OR (o.cdcooper = 14 AND o.nrdconta = 157953)
          OR (o.cdcooper = 14 AND o.nrdconta = 16116330)
          OR (o.cdcooper = 14 AND o.nrdconta = 274674)
          OR (o.cdcooper = 14 AND o.nrdconta = 261521)
          OR (o.cdcooper = 14 AND o.nrdconta = 15779203)
          OR (o.cdcooper = 14 AND o.nrdconta = 63762 )
          OR (o.cdcooper = 14 AND o.nrdconta = 244597)
          OR (o.cdcooper = 14 AND o.nrdconta = 237361)
          OR (o.cdcooper = 14 AND o.nrdconta = 197505)
          OR (o.cdcooper = 14 AND o.nrdconta = 17531071)
          OR (o.cdcooper = 14 AND o.nrdconta = 52108 )
          OR (o.cdcooper = 14 AND o.nrdconta = 172987)
          OR (o.cdcooper = 14 AND o.nrdconta = 15786838)
          OR (o.cdcooper = 14 AND o.nrdconta = 343242)
          OR (o.cdcooper = 14 AND o.nrdconta = 18443206)
          OR (o.cdcooper = 14 AND o.nrdconta = 15598993)
          OR (o.cdcooper = 14 AND o.nrdconta = 16827015)
          OR (o.cdcooper = 14 AND o.nrdconta = 353310)
          OR (o.cdcooper = 14 AND o.nrdconta = 48917 )
          OR (o.cdcooper = 14 AND o.nrdconta = 213454)
          OR (o.cdcooper = 14 AND o.nrdconta = 17422450)
          OR (o.cdcooper = 14 AND o.nrdconta = 170186)
          OR (o.cdcooper = 14 AND o.nrdconta = 366668)
          OR (o.cdcooper = 14 AND o.nrdconta = 17874548)
          OR (o.cdcooper = 14 AND o.nrdconta = 126977)
          OR (o.cdcooper = 14 AND o.nrdconta = 229318)
          OR (o.cdcooper = 14 AND o.nrdconta = 18132081)
          OR (o.cdcooper = 14 AND o.nrdconta = 116211)
          OR (o.cdcooper = 14 AND o.nrdconta = 17657849)
          OR (o.cdcooper = 14 AND o.nrdconta = 14560143)
          OR (o.cdcooper = 14 AND o.nrdconta = 18352430)
          OR (o.cdcooper = 14 AND o.nrdconta = 18238831)
          OR (o.cdcooper = 14 AND o.nrdconta = 286770)
          OR (o.cdcooper = 14 AND o.nrdconta = 15344967)
          OR (o.cdcooper = 14 AND o.nrdconta = 231142)
          OR (o.cdcooper = 14 AND o.nrdconta = 18094198)
          OR (o.cdcooper = 14 AND o.nrdconta = 369438)
          OR (o.cdcooper = 14 AND o.nrdconta = 17717132)
          OR (o.cdcooper = 14 AND o.nrdconta = 255726)
          OR (o.cdcooper = 14 AND o.nrdconta = 18487165)
          OR (o.cdcooper = 14 AND o.nrdconta = 230294)
          OR (o.cdcooper = 14 AND o.nrdconta = 15630340)
          OR (o.cdcooper = 14 AND o.nrdconta = 389617)
          OR (o.cdcooper = 14 AND o.nrdconta = 308455)
          OR (o.cdcooper = 14 AND o.nrdconta = 15804020)
          OR (o.cdcooper = 14 AND o.nrdconta = 17956790)
          OR (o.cdcooper = 14 AND o.nrdconta = 15948730)
          OR (o.cdcooper = 14 AND o.nrdconta = 17371163)
          OR (o.cdcooper = 14 AND o.nrdconta = 16728785)
          OR (o.cdcooper = 14 AND o.nrdconta = 147460)
          OR (o.cdcooper = 14 AND o.nrdconta = 158267)
          OR (o.cdcooper = 14 AND o.nrdconta = 257826)
          OR (o.cdcooper = 14 AND o.nrdconta = 406058)
          OR (o.cdcooper = 14 AND o.nrdconta = 101826)
          OR (o.cdcooper = 14 AND o.nrdconta = 17709407)
          OR (o.cdcooper = 14 AND o.nrdconta = 17934796)
          OR (o.cdcooper = 14 AND o.nrdconta = 242411)
          OR (o.cdcooper = 14 AND o.nrdconta = 14496496)
          OR (o.cdcooper = 14 AND o.nrdconta = 138770)
          OR (o.cdcooper = 14 AND o.nrdconta = 321761)
          OR (o.cdcooper = 14 AND o.nrdconta = 18533701)
          OR (o.cdcooper = 14 AND o.nrdconta = 44644 )
          OR (o.cdcooper = 14 AND o.nrdconta = 290050)
          OR (o.cdcooper = 14 AND o.nrdconta = 16716272)
          OR (o.cdcooper = 14 AND o.nrdconta = 132870)
          OR (o.cdcooper = 14 AND o.nrdconta = 14799510)
          OR (o.cdcooper = 14 AND o.nrdconta = 188662)
          OR (o.cdcooper = 14 AND o.nrdconta = 376558)
          OR (o.cdcooper = 14 AND o.nrdconta = 16360338)
          OR (o.cdcooper = 14 AND o.nrdconta = 18507360)
          OR (o.cdcooper = 14 AND o.nrdconta = 16357620)
          OR (o.cdcooper = 14 AND o.nrdconta = 15481832)
          OR (o.cdcooper = 14 AND o.nrdconta = 15869199)
          OR (o.cdcooper = 14 AND o.nrdconta = 216313)
          OR (o.cdcooper = 14 AND o.nrdconta = 15213021)
          OR (o.cdcooper = 14 AND o.nrdconta = 14724413)
          OR (o.cdcooper = 14 AND o.nrdconta = 18066623)
          OR (o.cdcooper = 14 AND o.nrdconta = 175323)
          OR (o.cdcooper = 14 AND o.nrdconta = 14875420)
          OR (o.cdcooper = 14 AND o.nrdconta = 17363993)
          OR (o.cdcooper = 14 AND o.nrdconta = 14531410)
          OR (o.cdcooper = 14 AND o.nrdconta = 17330335)
          OR (o.cdcooper = 14 AND o.nrdconta = 17674573)
          OR (o.cdcooper = 14 AND o.nrdconta = 17476160)
          OR (o.cdcooper = 14 AND o.nrdconta = 17138760)
          OR (o.cdcooper = 14 AND o.nrdconta = 16064437)
          OR (o.cdcooper = 14 AND o.nrdconta = 18641717)
          OR (o.cdcooper = 14 AND o.nrdconta = 16592336)
          OR (o.cdcooper = 14 AND o.nrdconta = 15629490)
          OR (o.cdcooper = 14 AND o.nrdconta = 382434)
          OR (o.cdcooper = 14 AND o.nrdconta = 16869532)
          OR (o.cdcooper = 14 AND o.nrdconta = 15199053)
          OR (o.cdcooper = 14 AND o.nrdconta = 16651502)
          OR (o.cdcooper = 14 AND o.nrdconta = 18506836)
          OR (o.cdcooper = 14 AND o.nrdconta = 17507448)
          OR (o.cdcooper = 5 AND o.nrdconta = 15641562 )
          OR (o.cdcooper = 5 AND o.nrdconta = 14859653 )
          OR (o.cdcooper = 5 AND o.nrdconta = 18510205 )
          OR (o.cdcooper = 5 AND o.nrdconta = 362441)
          OR (o.cdcooper = 5 AND o.nrdconta = 355860)
          OR (o.cdcooper = 5 AND o.nrdconta = 14579367)
          OR (o.cdcooper = 5 AND o.nrdconta = 381829)
          OR (o.cdcooper = 5 AND o.nrdconta = 145203)
          OR (o.cdcooper = 5 AND o.nrdconta = 17606535)
          OR (o.cdcooper = 5 AND o.nrdconta = 17075955)
          OR (o.cdcooper = 5 AND o.nrdconta = 17549108)
          OR (o.cdcooper = 5 AND o.nrdconta = 18256040)
          OR (o.cdcooper = 14 AND o.nrdconta = 401528));
    
    COMMIT;

END;