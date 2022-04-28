begin
UPDATE crapcon con SET con.cdhistor = 2515, con.tparrecd = 1, con.flgacrfb = 0 where con.cdempcon in (64,153,328,385) and con.cdsegmto = 5;
UPDATE crapcon con SET con.cdhistor = 2515, con.tparrecd = 2, con.flgacrfb = 0 where con.cdempcon in (432) and con.cdsegmto = 5;
UPDATE crapcon con SET con.cdhistor = 3361, con.tparrecd = 1, con.flgacrfb = 0 where con.cdempcon in (270) and con.cdsegmto = 5;
UPDATE crapprm prm SET prm.DSVLRPRM = '0' WHERE prm.cdacesso like '%SITUACAO_RFB%';
UPDATE crapprm prm SET prm.DSVLRPRM = '0' WHERE prm.cdacesso like '%DARF_SEM_BARRA_RFB%';

commit;

end;






