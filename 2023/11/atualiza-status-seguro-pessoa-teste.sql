begin
   update cecred.crapseg
      set cdsitseg = 5
    where cdcooper = 16
      and nrdconta = 84364041
      and nrctrseg = 361734;
      
   update cecred.tbseg_prestamista
      set tpregist = 0,
          dtrecusa = to_date('19/11/2023','dd/mm/yyyy')
    where cdcooper = 16
      and nrdconta = 84364041
      and nrctrseg = 361734;
	  
   update cecred.crapseg
      set cdsitseg = 2
    where cdcooper = 16
      and nrdconta = 84364041
      and nrctrseg = 361736;
	  
commit;	  
end;