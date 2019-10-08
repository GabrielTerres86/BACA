DECLARE  
  aux_nrseqaca number := null;  
BEGIN  
   begin 
     select c.nrseqaca
       into aux_nrseqaca
       from crapaca c
      where c.nrseqrdr = (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'ATENDA')
        and c.nmdeacao = 'VALIDA_DTPGTO_ANTECIP'
        and c.nmpackag = 'EMPR0020'
        and c.nmproced =  'pc_validar_dtpgto_antecipada';
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
           'VALIDA_DTPGTO_ANTECIP', 
           'EMPR0020', 
           'pc_validar_dtpgto_antecipada', 
           '', 
          (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'ATENDA'));
        commit;     
   end;  
END; 
/
