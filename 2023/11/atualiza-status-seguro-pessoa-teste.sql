begin
   update cecred.crapseg
      set cdsitseg = 5
    where cdcooper = 16
      and nrdconta = 99663635
      and nrctrseg = 361582;
      
   update cecred.tbseg_prestamista
      set tpregist = 0,
          dtrecusa = to_date('19/11/2023','dd/mm/yyyy')
    where cdcooper = 16
      and nrdconta = 99663635
      and nrctrseg = 361582;
	  
commit;	  
end;