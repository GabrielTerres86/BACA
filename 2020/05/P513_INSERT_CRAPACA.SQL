INSERT INTO crapaca( nrseqaca
                   , nmdeacao
                   , nmpackag 
                   , nmproced
                   , lstparam  
                   , nrseqrdr  )
            VALUES ( CECRED.SEQACA_NRSEQACA.NEXTVAL -- nrseqaca
                   ,'OBTERDEPVAR' -- nmdeacao
                   , null -- nmpackag
                   ,'contacorrente.obterDepositoVarejista' -- nmproced
                   ,'pr_cdcooper, pr_nrdconta' -- lstparam
                   ,71 -- nrseqrdr
                   );
COMMIT;

INSERT INTO crapaca( nrseqaca
                   , nmdeacao
                   , nmpackag 
                   , nmproced
                   , lstparam  
                   , nrseqrdr  )
            VALUES ( CECRED.SEQACA_NRSEQACA.NEXTVAL -- nrseqaca
                   ,'INCLUIRDEPVAR' -- nmdeacao
                   , null -- nmpackag
                   ,'contacorrente.incluirDepositoVarejista'
                   ,'pr_cdcooper, pr_nrdconta, pr_nrcontrato, pr_dtinicio_vigencia, pr_dtfim_vigencia, pr_cdoperad_inclusao' -- lstparam
                   ,71 -- nrseqrdr
                   );    
COMMIT;

INSERT INTO crapaca( nrseqaca
                   , nmdeacao
                   , nmpackag 
                   , nmproced
                   , lstparam  
                   , nrseqrdr  )
            VALUES ( CECRED.SEQACA_NRSEQACA.NEXTVAL -- nrseqaca
                   ,'CANCELARDEPVAR' -- nmdeacao
                   , null -- nmpackag
                   ,'contacorrente.cancelarDepositoVarejista' -- nmproced
                   ,'pr_cdcooper, pr_nrdconta, pr_idsequencia, pr_dtcancelamento, pr_cdoperad_cancela' -- lstparam
                   ,71 -- nrseqrdr
                   ); 
COMMIT;                      
                   
INSERT INTO crapaca( nrseqaca
                   , nmdeacao
                   , nmpackag 
                   , nmproced
                   , lstparam  
                   , nrseqrdr  )
            VALUES ( CECRED.SEQACA_NRSEQACA.NEXTVAL -- nrseqaca
                   ,'VALIDARDEPVAR' -- nmdeacao
                   , null -- nmpackag
                   ,'contacorrente.validarDepositoVarejista' -- nmproced
                   ,'pr_cdcooper, pr_nrdconta' -- lstparam
                   ,71 -- nrseqrdr
                   );                                      
COMMIT;
                 
INSERT INTO crapaca( nrseqaca
                   , nmdeacao
                   , nmpackag 
                   , nmproced
                   , lstparam  
                   , nrseqrdr  )
            VALUES ( CECRED.SEQACA_NRSEQACA.NEXTVAL -- nrseqaca
                   ,'ATUALIZARDEPVAR' -- nmdeacao
                   , null -- nmpackag
                   ,'contacorrente.atualizarDepositoVarejista' -- nmproced
                   ,'pr_cdcooper, pr_nrdconta, pr_idsequencia, pr_nrcontrato, pr_dtinicio_vigencia , pr_dtfim_vigencia' -- lstparam
                   ,71 -- nrseqrdr
                   );                                                         
COMMIT;
                   
