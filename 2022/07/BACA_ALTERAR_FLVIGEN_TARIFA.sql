BEGIN
UPDATE CECRED.CRAPFCO L SET L.FLGVIGEN = 1 WHERE L.CDFVLCOP IN (171737,171736,171735,171734,171733,171732,171731,171730,171729,171728,171727,171726,171725,171724,171723,171722,171721);
COMMIT;
END;