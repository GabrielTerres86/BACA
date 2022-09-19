begin
  update cecred.craptxi
  set dtcadast = dtcadast + 1
  where cddindex = 5
    and dtiniper = to_date('01/08/2022', 'DD/MM/YYYY');
  commit;
end;

