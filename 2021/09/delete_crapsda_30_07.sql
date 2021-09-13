BEGIN
  delete crapsda s
  WHERE s.dtmvtolt = to_date('30/07/2021','DD/MM/YYYY')
    and s.cdcooper = 14;
commit;
END;
