BEGIN
 delete from crapsda where cdcooper=5 and dtmvtolt >=  to_date('01/07/2024','dd/mm/yyyy');
COMMIT;
END;