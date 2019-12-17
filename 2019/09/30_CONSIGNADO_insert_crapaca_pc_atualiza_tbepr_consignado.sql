DECLARE  
  aux_nrseqaca number := null;  
BEGIN  
   begin 
     select c.nrseqaca
       into aux_nrseqaca
       from crapaca c
      where c.nrseqrdr = (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_EMPRESTIMO')
        and c.nmdeacao = 'GRAVA_TBEPR_CONSIGNADO'
        and c.nmpackag = 'EMPR0020'
        and c.nmproced =  'pc_atualiza_tbepr_consignado';
   exception
     when no_data_found then       
        insert into cecred.crapaca
          (nrseqaca, 
           nmdeacao, 
           nmpackag, 
           nmproced, 
           lstparam, 
           nrseqrdr)
        values
          (SEQACA_NRSEQACA.NEXTVAL, 
           'GRAVA_TBEPR_CONSIGNADO', 
           'EMPR0020', 
           'pc_atualiza_tbepr_consignado', 
           'pr_nrdconta,pr_nrctremp,pr_pejuro_anual,pr_pecet_anual', 
          (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_EMPRESTIMO'));
        commit;     
   end;  
END; 
/