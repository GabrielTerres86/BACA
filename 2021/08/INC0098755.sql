Begin 

UPDATE Tbcc_Limite_Preposto lp
SET FLGMASTER = 0
WHERE CDCOOPER = 1 and NRDCONTA = 1857517 and NRCPF = '38194961904';

commit;
end;