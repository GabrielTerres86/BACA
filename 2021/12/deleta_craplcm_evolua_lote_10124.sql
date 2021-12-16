BEGIN
DELETE FROM craplcm WHERE cdcooper = 14 and nrdolote = 10124 and dtmvtolt = to_date('15/12/2021', 'DD/MM/YYYY') AND cdhistor = 0;
EXCEPTION
WHEN OTHERS THEN
ROLLBACK;
END;
