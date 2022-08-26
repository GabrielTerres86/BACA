
begin
  update cecred.tbconv_deb_nao_efetiv set cecred.tbconv_deb_nao_efetiv.dtmvtolt=to_date('25/08/2022','DD/MM/YYYY') 
   where dtmvtolt = to_date('16/08/2022','DD/MM/YYYY') 
     and cdcooper in (14,13,11,7,1)
     and nrdconta in(218545,52230,126209,530875,185850,7686439,11489430,8132267,2236990,12338877,2640899,
                     9932992,11226137,11882115,10974636,10250778,14732009,3682595,1323873,9916709,9916709);
  commit;
end;