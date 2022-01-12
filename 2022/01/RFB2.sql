begin

UPDATE crapcon con SET con.cdhistor = 3464, con.tparrecd = 4, con.flgacrfb = 1 where con.cdempcon in (64,153,328,385,432,270) and con.cdsegmto = 5;
UPDATE crapcon con SET con.cdhistor = 3465, con.tparrecd = 4, con.flgacrfb = 1 where con.cdempcon = 0 and con.cdsegmto = 6;
UPDATE crapprm prm SET prm.DSVLRPRM = '1' WHERE prm.cdacesso like '%SITUACAO_RFB%';
UPDATE crapprm prm SET prm.DSVLRPRM = 'S' WHERE prm.cdacesso like '%COMPROVANTE_RFB%';


commit;

end;