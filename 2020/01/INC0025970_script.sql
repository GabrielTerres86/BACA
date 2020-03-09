declare

begin
  begin
    update crawcrd c 
	   set c.nrcrcard = 6393500011748838, 
		   c.dddebito = 32, c.insitcrd = 4,
		   c.dtpropos = '11/04/2016',
		   c.dtsolici = '11/04/2016',
		   c.dtentreg = '10/05/2016', c.dtvalida = '30/04/2021', c.cdadmcrd = 16, c.vllimcrd = 0
	 where c.cdcooper = 1
	   and c.nrdconta = 3609707
	   and c.nrcrcard = 0
	   and c.nrctrcrd = 885694;
  exception
    when OTHERS then
	  dbms_output.put_line('Erro update crawcrd final 8838. '||sqlerrm);
  end;
  
  begin
	update crawcrd c 
	   set c.dddebito = 32, c.cdgraupr = 5,
		   c.dtvalida = '30/04/2025', c.cdadmcrd = 16, c.vllimcrd = 0
	 where c.cdcooper = 1
	   and c.nrdconta = 3609707
	   and c.nrcrcard = 6393500105759261
	   and c.nrctrcrd = 1542687;
  exception
    when OTHERS then
	  dbms_output.put_line('Erro update crawcrd final 9261. '||sqlerrm);
  end;

  begin
    update crapcrd c 
	   set c.dddebito = 32, 
		   c.dtvalida = '30/04/2025', c.cdadmcrd = 16, c.inacetaa = 1
	 where c.cdcooper = 1
	   and c.nrdconta = 3609707
	   and c.nrcrcard = 6393500105759261
	   and c.nrctrcrd = 1542687;
  exception
    when OTHERS then
	  dbms_output.put_line('Erro update crapcrd final 9261. '||sqlerrm);
  end;
  
  commit;
  dbms_output.put_line('Script executado com sucesso.');
  
end;