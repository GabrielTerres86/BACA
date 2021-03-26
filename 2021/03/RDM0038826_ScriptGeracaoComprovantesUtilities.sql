declare
  v_erro varchar2(2000);
begin
  update crappro p
     set p.dsprotoc = substr(p.dsprotoc, 1, 29)
   where p.cdcooper = 1
     and (   upper(p.dsprotoc) like '4532.3238.0118.0315.195B.2857%'
          or upper(p.dsprotoc) like '5401.3414.0118.0315.1A1A.5438%'
          or upper(p.dsprotoc) like '5212.2560.0118.0315.1A19.0E2A%'
          or upper(p.dsprotoc) like '5213.122C.0118.0315.1A19.0E2B%'
          or upper(p.dsprotoc) like '590A.5448.0118.0315.1A19.0E2C%'
          or upper(p.dsprotoc) like '5012.1D58.0118.0315.1A1A.5436%'
          or upper(p.dsprotoc) like '5313.375C.0118.0315.1A1A.5437%'
          or upper(p.dsprotoc) like '540F.0930.0118.0315.1F4C.613A%'
          or upper(p.dsprotoc) like '4A10.134C.0118.0315.1F3E.1606%'
          or upper(p.dsprotoc) like '570F.3E20.0118.0315.202C.5C4B%'
          or upper(p.dsprotoc) like '4B15.0E44.0118.0315.231F.4E0D%'
          or upper(p.dsprotoc) like '4422.0B2C.0118.0315.2662.3916%'
          or upper(p.dsprotoc) like '5348.1254.0118.0315.2701.121A%'
          or upper(p.dsprotoc) like '461D.273C.0118.0315.2758.2F2C%'
          or upper(p.dsprotoc) like '495F.2918.0118.0315.283A.1602%'
          or upper(p.dsprotoc) like '4427.1814.0118.0315.2930.3F09%'
          or upper(p.dsprotoc) like '4427.1914.0118.0315.2931.030E%'
          or upper(p.dsprotoc) like '5152.4B24.0118.0315.2A10.200E%'
          or upper(p.dsprotoc) like '5663.5F5C.0118.0315.2A17.552B%'
          or upper(p.dsprotoc) like '5920.3608.0118.0315.2A52.3516%'
          or upper(p.dsprotoc) like '3712.4F50.0118.0315.2C34.5817%');
  update crappro p
     set p.dsprotoc = substr(p.dsprotoc, 1, 29)
   where p.cdcooper = 2
     and (   upper(p.dsprotoc) like '2B22.1B0C.0218.0315.1921.5D43%'
          or upper(p.dsprotoc) like '2B33.2200.0218.0315.1921.5D45%'
          or upper(p.dsprotoc) like '2B33.5A24.0218.0315.1921.5D47%'
          or upper(p.dsprotoc) like '2B10.1A3C.0218.0315.1E3B.4C4F%'
          or upper(p.dsprotoc) like '2B34.0F54.0218.0315.2221.3423%');
  update crappro p
     set p.dsprotoc = substr(p.dsprotoc, 1, 29)
   where p.cdcooper = 5
     and (   upper(p.dsprotoc) like '2837.2454.0518.0315.191B.4420%'
          or upper(p.dsprotoc) like '2913.0C10.0518.0315.191B.4425%'
          or upper(p.dsprotoc) like '285E.3740.0518.0315.191B.4423%'
          or upper(p.dsprotoc) like '290C.1744.0518.0315.1E4A.013B%'
          or upper(p.dsprotoc) like '283C.375C.0518.0315.204C.600E%'
          or upper(p.dsprotoc) like '280F.0920.0518.0315.2303.543B%'
          or upper(p.dsprotoc) like '2903.0B30.0518.0315.2661.4C5D%'
          or upper(p.dsprotoc) like '290B.1D28.0518.0315.2703.593C%'
          or upper(p.dsprotoc) like '2905.4358.0518.0315.2A5B.113F%'
          or upper(p.dsprotoc) like '2851.600C.0518.0315.2B10.251C%'
          or upper(p.dsprotoc) like '2836.1C48.0518.0315.2C2D.2D29%');
  update crappro p
     set p.dsprotoc = substr(p.dsprotoc, 1, 29)
   where p.cdcooper = 6
     and upper(p.dsprotoc) like '285A.3E10.0618.0315.191C.323F%';
  update crappro p
     set p.dsprotoc = substr(p.dsprotoc, 1, 29)
   where p.cdcooper = 7
     and (   upper(p.dsprotoc) like '2802.1E0C.0718.0315.233F.5160%'
          or upper(p.dsprotoc) like '2808.4554.0718.0315.2441.275F%'
          or upper(p.dsprotoc) like '2808.2C40.0718.0315.2446.5209%'
          or upper(p.dsprotoc) like '282F.5228.0718.0315.244D.2D19%'
          or upper(p.dsprotoc) like '2808.3118.0718.0315.2502.6053%'
          or upper(p.dsprotoc) like '2808.2F34.0718.0315.245B.5221%'
          or upper(p.dsprotoc) like '2808.3254.0718.0315.2512.4046%'
          or upper(p.dsprotoc) like '2A16.611C.0718.0315.2509.3C4C%'
          or upper(p.dsprotoc) like '2808.3934.0718.0315.2601.4950%'
          or upper(p.dsprotoc) like '2836.493C.0718.0315.284A.4F15%'
          or upper(p.dsprotoc) like '2836.4C48.0718.0315.284A.4F02%');
  update crappro p
     set p.dsprotoc = substr(p.dsprotoc, 1, 29)
   where p.cdcooper = 9
     and (   upper(p.dsprotoc) like '2860.4A60.0918.0315.2126.1652%'
          or upper(p.dsprotoc) like '285A.2204.0918.0315.2447.201D%'
          or upper(p.dsprotoc) like '2937.3220.0918.0315.2504.4E1B%');
  update crappro p
     set p.dsprotoc = substr(p.dsprotoc, 1, 29)
   where p.cdcooper = 11
     and (   upper(p.dsprotoc) like '2957.1520.0B18.0315.1631.5A57%'
          or upper(p.dsprotoc) like '2957.152C.0B18.0315.1643.3332%'
          or upper(p.dsprotoc) like '2B0D.541C.0B18.0315.1922.5E11%'
          or upper(p.dsprotoc) like '2938.0750.0B18.0315.1923.4B21%'
          or upper(p.dsprotoc) like '2938.2414.0B18.0315.1923.4B23%'
          or upper(p.dsprotoc) like '2938.2420.0B18.0315.1923.4B24%'
          or upper(p.dsprotoc) like '2860.5E3C.0B18.0315.230A.6130%'
          or upper(p.dsprotoc) like '294D.1028.0B18.0315.2703.0932%'
          or upper(p.dsprotoc) like '2A61.4648.0B18.0315.2731.1313%'
          or upper(p.dsprotoc) like '2861.0C28.0B18.0315.281B.6158%');
  update crappro p
     set p.dsprotoc = substr(p.dsprotoc, 1, 29)
   where p.cdcooper = 12
     and (   upper(p.dsprotoc) like '283F.145C.0C18.0315.191B.393B%'
          or upper(p.dsprotoc) like '283E.134C.0C18.0315.191B.393C%'
          or upper(p.dsprotoc) like '280B.1628.0C18.0315.2447.4846%'
          or upper(p.dsprotoc) like '2845.4228.0C18.0315.2811.2031%'
          or upper(p.dsprotoc) like '2842.3750.0C18.0315.2811.3441%'
          or upper(p.dsprotoc) like '2845.4240.0C18.0315.2811.3444%'
          or upper(p.dsprotoc) like '2841.2404.0C18.0315.2811.4845%'
          or upper(p.dsprotoc) like '283F.3124.0C18.0315.2854.5D3B%'
          or upper(p.dsprotoc) like '2833.314C.0C18.0315.285A.4C33%');
  update crappro p
     set p.dsprotoc = substr(p.dsprotoc, 1, 29)
   where p.cdcooper = 14
     and upper(p.dsprotoc) like '285A.5804.0E18.0315.2223.0C63%';
  commit;
exception
  when others then
    v_erro := sqlerrm;
    rollback;
    raise_application_error(-20001, v_erro);
end;
