begin
update crapprm set crapprm.dstexprm = '0' where cdacesso = 'SITUACAO_RFB_G0270';
update crapcon set crapcon.cdhistor = 3361, crapcon.tparrecd = 1, crapcon.flgacrfb = 0  where crapcon.cdempcon = 270 and crapcon.cdsegmto = 5

commit;

end;