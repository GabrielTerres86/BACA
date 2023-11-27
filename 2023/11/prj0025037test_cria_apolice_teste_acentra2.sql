begin 
  insert into cecred.tbseg_param_prst_cap_seg (IDSEQPAR, IDADEMIN, IDADEMAX, CAPITMIN, CAPITMAX)
  values (1000, 0, 999, 10000.00, 500000.00);
  
  insert into cecred.tbseg_param_prst_tax_cob (IDSEQPAR, GBIDAMIN, GBIDAMAX, GBSEGMIN, GBSEGMAX)
  values (1000, 0, 999, 0.01956083, 0.00131917);
    
  commit; 
end; 
