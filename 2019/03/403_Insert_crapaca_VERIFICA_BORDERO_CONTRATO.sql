-- Cássia de Oliveira (GFT) - 20/02/2019
-- Insert mensageria para verificar se há borderos diferentes da Liberado para o contrato a ser cancelado

INSERT 
  INTO crapaca(nmdeacao
  			  ,nmpackag
  			  ,nmproced
  			  ,lstparam
  			  ,nrseqrdr) 
       VALUES ('VERIFICA_BORDERO_CONTRATO'
              ,'DSCT0003'
              ,'pc_verifica_contrato_bodero'
              ,'pr_nrdconta, pr_nrctrlim'
              ,724);
COMMIT;