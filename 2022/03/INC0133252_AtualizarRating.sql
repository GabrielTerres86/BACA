begin
  update tbrisco_operacoes
     set inrisco_rating = 2
   where cdcooper = 9
     and nrdconta = 230790
     and nrctremp = 48541;

  update tbrisco_central_ocr
     set inrisco_rating = 2
   where tbrisco_central_ocr.cdcooper = 9
     and tbrisco_central_ocr.nrdconta = 230790
     and tbrisco_central_ocr.nrctremp = 48541
     and tbrisco_central_ocr.dtrefere = to_date('30/03/2022', 'dd/mm/yyyy');
  commit;
end;
