BEGIN

  UPDATE crapaca 
     SET lstparam = 'pr_nrdconta,pr_cdbccxlt,pr_idseqttl,pr_nrcpfemp,pr_nmextemp,pr_tppessoaemp'
   WHERE nmdeacao = 'SOLICITA_PORTABILIDADE';

  UPDATE crapaca 
     set lstparam = 'pr_nrdconta,pr_nrsolicitacao'
   where nmdeacao = 'BUSCA_DADOS_ENVIA';

  insert into crapaca(nrseqaca,
                      nmdeacao,
                      nmpackag,
                      nmproced,
                      lstparam,
                      nrseqrdr)
              values ((select max(nrseqaca)+1 from crapaca)
                     ,'BUSCA_SOLICITACOES_PORTABILIDADE'
                     ,'TELA_ATENDA_PORTAB'
                     ,'pc_busca_solicitacoes'
                     ,'pr_nrdconta'
                     ,71);
    
  COMMIT;
    
END;
