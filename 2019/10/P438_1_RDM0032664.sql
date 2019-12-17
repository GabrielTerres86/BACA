update crawepr w
   set w.dtulteml = to_date('31/12/2099','DD/MM/RRRR')
  where w.rowid in
       (SELECT epr.rowid
          FROM crawepr epr, crapope c
         WHERE epr.insitest = 3 -- Situacao Analise Finalizada
           AND epr.insitapr = 1 -- Decisao aprovada
           and epr.cdcooper = 1
           AND epr.dtaprova IS NOT NULL -- Ter data de 
           AND epr.cdcooper = c.cdcooper
           AND epr.cdopeste = c.cdoperad
           AND TRIM(c.dsdemail) is not null
           AND epr.dtaprova < to_date('01/09/2019','DD/MM/RRRR')
           AND NOT EXISTS ( SELECT 1
                              FROM crapepr epr2
                             WHERE epr2.cdcooper = epr.cdcooper
                               AND epr2.nrdconta = epr.nrdconta
                               AND epr2.nrctremp = epr.nrctremp));
							   
commit;							  