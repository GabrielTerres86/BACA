begin
update craplau set craplau.dtmvtolt = '10/09/2021', craplau.dtmvtopg = '13/09/2021' where craplau.progress_recid in (54086634, 54086636);
commit;
end;