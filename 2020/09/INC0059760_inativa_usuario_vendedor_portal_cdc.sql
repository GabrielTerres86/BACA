update   tbepr_cdc_usuario
set FLGATIVO=0
where DSLOGIN='15687976000151';

update   tbepr_cdc_usuario u
set FLGATIVO=0
where DSLOGIN='APP_COOPERADO'
and   idusuario = (select  i.idusuario
                   from    tbepr_cdc_vendedor v
                          ,tbepr_cdc_usuario_vinculo i
                   where v.nrcpf         = 15687976000151
                   AND   v.idvendedor    = i.idvendedor
                   AND i.idusuario     = u.idusuario
                  );

commit;
