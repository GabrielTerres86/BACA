begin
    delete from tbepr_cdc_usuario_vinculo where idcooperado_cdc in (select idcooperado_cdc from tbsite_cooperado_cdc where cdcooper = 1 and nrdconta = 92426590);
    delete from tbepr_cdc_vendedor where idcooperado_cdc in (select idcooperado_cdc from tbsite_cooperado_cdc where cdcooper = 1 and nrdconta = 92426590);
    delete from tbepr_cdc_usuario where idusuario in (142453, 142454);
    delete from tbsite_cooperado_cdc where cdcooper = 1 and nrdconta = 92426590;
    delete from crapcdr where cdcooper = 1 and nrdconta = 92426590;
  COMMIT;

end;