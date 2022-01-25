begin
update crapprm set crapprm.dstexprm = '0' where cdacesso like 'SITUACAO_RFB%';
update crapcon set crapcon.cdhistor = 3361, crapcon.tparrecd = 1, crapcon.flgacrfb = 0  where crapcon.cdempcon = 0 and crapcon.cdsegmto = 6;
update crapcon set crapcon.cdhistor = 2515, crapcon.tparrecd = 1, crapcon.flgacrfb = 0  where crapcon.cdempcon in (64,153,328,385,432) and crapcon.cdsegmto = 5;

commit;

end;