begin
  -- Adição do Pârametro da FGCOOP na tela CADCOP
  update CRAPACA
   set LSTPARAM = LSTPARAM || ',pr_vlfgcoop'
  where NMDEACAO = 'ALTCOOP'
   and NMPACKAG = 'TELA_CADCOP';  

  -- Atualiza a tabela da Cooperativa com o valor 250000,
  -- definido ate este momento para o calculo das Contas de Compensacao
  -- (valor excedente da soma dos depositos a vista + a prazo)
  update CRAPCOP
     set VLFGCOOP = 250000;	 
	 
  COMMIT;
      
end;  
