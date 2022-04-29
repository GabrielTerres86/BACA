begin
update crapcon con set con.tparrecd = 4 where con.cdempcon = 432 and con.nmextcon = 'RFB -DAED';
update crapcon con set con.tparrecd = 4 where con.cdempcon = 328 and con.nmextcon = 'DAS - SIMPLES NACIONAL';
update crapcon con set con.tparrecd = 4 where con.cdempcon = 64 and con.nmextcon = 'DARF 81 COOP COD BARRAS 0064';
update crapcon con set con.tparrecd = 4 where con.cdempcon = 385 and con.nmextcon = 'DARF BANCO COD BARRAS 0385';
update crapcon con set con.tparrecd = 4 where con.cdempcon = 153 and con.nmextcon = 'DARF 81 COOP COD BARRAS 0153';
update crapcon con set con.tparrecd = 4 where con.cdempcon = 270 and con.nmextcon = 'GUIA DA PREVIDENCIA SOCIAL';
update crapcon con set con.cdhistor = 3464 where con.tparrecd = 4;

commit;

end;