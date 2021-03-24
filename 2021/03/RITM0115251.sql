declare
  v_erro varchar2(2000);
begin
  update crappro p
     set p.dsprotoc = substr(p.dsprotoc, 1, 29)
   where p.cdcooper = 1
     and (   upper(p.dsprotoc) like '4026.1F3C.010B.0115.3752.1D11%'
          or upper(p.dsprotoc) like '482D.340C.010B.0115.3844.182B%'
          or upper(p.dsprotoc) like '4A27.5428.010B.0115.3838.0060%'
          or upper(p.dsprotoc) like '4A36.6014.010B.0115.375F.3623%'
          or upper(p.dsprotoc) like '4C1A.0C14.010B.0115.3908.0636%'
          or upper(p.dsprotoc) like '4E42.2660.010B.0115.3741.321D%'
          or upper(p.dsprotoc) like '4E61.082C.010B.0115.3727.263D%'
          or upper(p.dsprotoc) like '4F00.1738.010B.0115.3723.353F%'
          or upper(p.dsprotoc) like '4F17.0A3C.010B.0115.390B.5025%'
          or upper(p.dsprotoc) like '5017.044C.010B.0115.383E.115A%'
          or upper(p.dsprotoc) like '561F.4E54.010B.0115.3838.4745%'
          or upper(p.dsprotoc) like '5943.4104.010B.0115.390E.173D%');
  update crappro p
     set p.dsprotoc = substr(p.dsprotoc, 1, 29)
   where p.cdcooper = 5
     and (   upper(p.dsprotoc) like '2837.3E3C.050B.0115.3802.0B60%'
          or upper(p.dsprotoc) like '283A.1D1C.050B.0115.372D.1936%'
          or upper(p.dsprotoc) like '283F.2C5C.050B.0115.380B.150D%'
          or upper(p.dsprotoc) like '2843.1D48.050B.0115.381F.4A06%'
          or upper(p.dsprotoc) like '284C.5048.050B.0115.380B.1509%'
          or upper(p.dsprotoc) like '2859.3208.050B.0115.382C.3939%'
          or upper(p.dsprotoc) like '2901.4348.050B.0115.3747.4D14%'
          or upper(p.dsprotoc) like '2926.5D4C.050B.0115.3906.0362%');
  update crappro p
     set p.dsprotoc = substr(p.dsprotoc, 1, 29)
   where p.cdcooper = 7
     and (   upper(p.dsprotoc) like '283B.0440.070B.0115.3761.0553%'
          or upper(p.dsprotoc) like '283B.0510.070B.0115.3761.0F4F%'
          or upper(p.dsprotoc) like '283B.133C.070B.0115.3761.0F4C%'
          or upper(p.dsprotoc) like '283B.3254.070B.0115.3761.0548%'
          or upper(p.dsprotoc) like '2923.0850.070B.0115.3856.1709%');
  update crappro p
     set p.dsprotoc = substr(p.dsprotoc, 1, 29)
   where p.cdcooper = 9
     and (   upper(p.dsprotoc) like '283A.5108.090B.0115.3905.4A05%'
          or upper(p.dsprotoc) like '283C.4C54.090B.0115.3856.0D03%');
  update crappro p
     set p.dsprotoc = substr(p.dsprotoc, 1, 29)
   where p.cdcooper = 11
     and (   upper(p.dsprotoc) like '2921.6314.0B0B.0115.371E.624D%'
          or upper(p.dsprotoc) like '2A48.0E48.0B0B.0115.3748.4E2B%');
  update crappro p
     set p.dsprotoc = substr(p.dsprotoc, 1, 29)
   where p.cdcooper = 16
     and upper(p.dsprotoc) like '290E.3B34.100B.0115.385B.1C0E%';
  commit;
exception
  when others then
    v_erro := sqlerrm;
    rollback;
    raise_application_error(-20001, v_erro);
end;
