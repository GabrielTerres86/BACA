declare

  /*
  PRB0042288 - Script para iniciar a sequence e atualizar para o próximo valor.
  -- Paulo Martins 
  */

  vr_aux   TBEPR_MITRA_PAGAMENTO.IDANTECIPACAO%TYPE;
  
begin
  
    --Gera informação da sequence
    vr_aux :=  fn_sequence(pr_nmtabela => 'TBEPR_MITRA_PAGAMENTO'
                          ,pr_nmdcampo => 'IDANTECIPACAO'
                          ,pr_dsdchave => '0');  
    --seleciona o proximo
    select max(IDANTECIPACAO)+1
      into vr_aux
      from TBEPR_MITRA_PAGAMENTO;
    
    --atualiza como valor atual                           
      update crapsqu squ
         set squ.nrseqatu = vr_aux
       where UPPER(squ.nmtabela)  = 'TBEPR_MITRA_PAGAMENTO'
         and UPPER(squ.nmdcampo)  = 'IDANTECIPACAO'
         and UPPER(squ.dsdchave)  = '0';                               
      commit;
exception
  when others then
    dbms_output.put_line('Erro: '||sqlerrm);

end;
   
