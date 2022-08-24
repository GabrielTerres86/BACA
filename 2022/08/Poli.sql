begin
delete from cecred.tbconv_deb_nao_efetiv where cecred.tbconv_deb_nao_efetiv.dtmvtolt = to_date('16/08/2022','DD/MM/YYYY');
commit;
end;