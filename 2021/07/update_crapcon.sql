begin
UPDATE crapcon SET crapcon.cdhistor = 2515, crapcon.flgacbcb = 1, crapcon.tparrecd = 2
WHERE crapcon.cdempcon = 270 and crapcon.cdsegmto = 5;

UPDATE crapprm SET crapprm.dsvlrprm = '0'
WHERE crapprm.cdacesso = 'SITUACAO_RFB_G0270';

commit;
end;