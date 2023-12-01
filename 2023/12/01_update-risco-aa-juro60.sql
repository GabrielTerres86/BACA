BEGIN
  UPDATE gestaoderisco.tbrisco_crapris t
     SET t.innivris = 2
   WHERE t.cdcooper = 1
     AND t.nrdconta = 1929518
     AND t.nrctremp = 2562456
     AND t.dtrefere = to_date('30/11/2023', 'DD/MM/RRRR');

  UPDATE gestaoderisco.tbrisco_crapris t
     SET t.innivris = 8
   WHERE t.cdcooper = 1
     AND t.nrdconta = 6375510
     AND t.nrctremp = 5523893
     AND t.dtrefere = to_date('30/11/2023', 'DD/MM/RRRR');

  UPDATE gestaoderisco.tbrisco_crapris t
     SET t.innivris = 6
   WHERE t.cdcooper = 1
     AND t.nrdconta = 8344507
     AND t.nrctremp = 7107350
     AND t.dtrefere = to_date('30/11/2023', 'DD/MM/RRRR');
  
  COMMIT;
END;
