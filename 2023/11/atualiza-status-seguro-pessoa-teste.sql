begin
   update cecred.crapseg
      set cdsitseg = 5
    where cdcooper = 16
      and nrdconta = 83223908
      and nrctrseg = 386062;
      
   update cecred.tbseg_prestamista
      set tpregist = 0,
          dtrecusa = to_date('19/11/2023','dd/mm/yyyy')
    where cdcooper = 16
      and nrdconta = 83223908
      and nrctrseg = 386062;
	  
   update cecred.crapseg
      set cdsitseg = 2
    where cdcooper = 16
      and nrdconta = 83223908
      and nrctrseg = 386064;
	  
commit;	  
end;