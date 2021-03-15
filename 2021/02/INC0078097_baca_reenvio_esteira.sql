BEGIN
  DBMS_OUTPUT.ENABLE(1000000);

  FOR rw_proposta IN (select w.cdcooper, 
                             w.cdagenci, 
                             w.cdoperad, 
                             w.cdorigem, 
                             coalesce((select a.cdagenci_acionamento
                                from tbgen_webservice_aciona a
                               where a.cdcooper = w.cdcooper
                                 and a.nrdconta = w.nrdconta
                                 and a.nrctrprp = w.nrctremp
                                 and a.tpacionamento = 1
                                 and a.dsuriservico like '%ibraflow%'
                                 and ROWNUM = 1 ), w.cdagenci) cdagenci_aciona,
                             w.nrdconta,
                             w.nrctremp 
                        from crawepr w
                       where w.insitapr = 5 -- DERIVAR
                         and w.insitest = 3 -- PROCESSADO PELO MOTOR
                         and w.dtenvest IS NULL -- Nao enviada a esteira
                         and w.dtmvtolt = '10/02/2021') LOOP
  
    dbms_output.put_line(
    'rw_proposta.cdcooper: ' ||  rw_proposta.cdcooper ||
    ', rw_proposta.cdagenci_aciona: '  ||  rw_proposta.cdagenci_aciona ||
    ', rw_proposta.cdoperad: '  || rw_proposta.cdoperad ||
    ', rw_proposta.cdorigem: '  || rw_proposta.cdorigem ||
    ', rw_proposta.nrdconta: '  || rw_proposta.nrdconta ||
    ', rw_proposta.nrctremp: '  || rw_proposta.nrctremp
    );  
    
    ESTE0001.pc_derivar_proposta_est(pr_cdcooper => rw_proposta.cdcooper
                                      ,pr_cdagenci => rw_proposta.cdagenci_aciona
                                      ,pr_cdoperad => rw_proposta.cdoperad
                                      ,pr_cdorigem => rw_proposta.cdorigem
                                      ,pr_nrdconta => rw_proposta.nrdconta
                                      ,pr_nrctremp => rw_proposta.nrctremp
                                      ,pr_dtmvtolt => to_date('11/02/2021','dd/mm/rrrr'));
  END LOOP; 
  
  commit;                                
END;
