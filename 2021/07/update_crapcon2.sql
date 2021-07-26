begin
UPDATE crapcon SET crapcon.cdhistor = 3361, crapcon.flgacbcb = 0, crapcon.tparrecd = 1
WHERE crapcon.cdempcon = 270 and crapcon.cdsegmto = 5;

commit;
end;