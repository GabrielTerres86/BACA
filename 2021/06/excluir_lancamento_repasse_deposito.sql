begin

delete
  FROM craplcm
 WHERE cdcooper = 3
   AND dtmvtolt = to_date('29/10/2021', 'dd/mm/yyyy')
   AND nrdconta IN (51, 86)
   AND nrdolote = 7104;

commit;

end;