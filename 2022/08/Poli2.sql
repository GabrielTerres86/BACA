begin
update cecred.tbconv_deb_nao_efetiv set cecred.tbconv_deb_nao_efetiv.dtmvtolt=to_date('24/08/2022','DD/MM/YYYY') where cecred.tbconv_deb_nao_efetiv.dtmvtolt = to_date('16/08/2022','DD/MM/YYYY') and cecred.tbconv_deb_nao_efetiv.cdcooper=14 and cecred.tbconv_deb_nao_efetiv.nrdconta in(218545,52230);   
commit;
end;