declare 

 cursor cr_usuario is
   select decode(a.inpessoa,1,lpad(a.nrcpfcgc,11,'0'),lpad(a.nrcpfcgc,14,'0')) login
         ,lower(RAWTOHEX(DBMS_OBFUSCATION_TOOLKIT.md5(input => UTL_RAW.cast_to_raw(decode(a.inpessoa,1,lpad(a.nrcpfcgc,11,'0'),lpad(a.nrcpfcgc,14,'0')))))) as senha
         ,l.idcooperado_cdc
         ,c.cdcooper
         ,c.nrdconta
         ,a.inpessoa
         ,l.nmfantasia
         ,l.dsemail
      from tbsite_cooperado_cdc l
      join crapass a on (a.cdcooper=l.cdcooper and a.nrdconta=l.nrdconta)
      join crapcdr c on (a.cdcooper=c.cdcooper and a.nrdconta=c.nrdconta and c.flgconve=1)
      where l.idmatriz is null
      and not exists (select 1 
                        from tbepr_cdc_usuario_vinculo v
                        join tbepr_cdc_usuario u on (u.idusuario=v.idusuario and u.flgadmin=1)
                       where v.idcooperado_cdc=l.idcooperado_cdc)
      order by c.cdcooper,c.nrdconta;

  rw_usuario                   cr_usuario%rowtype;  
  vr_idusuario                 tbepr_cdc_usuario.idusuario%type;
  vr_idvendedor                tbepr_cdc_vendedor.idvendedor%type;

begin
  
  for rw_usuario in cr_usuario loop
    --dbms_output.put_line ('Passei: ' || rw_usuario.idcooperado_cdc);
    -- criar controle para nao gerar mais de um login igual
    begin
      insert into tbepr_cdc_usuario (dslogin, dssenha, flgadmin)
      values (rw_usuario.login, rw_usuario.senha, 1)
      returning idusuario into vr_idusuario;
      
      insert into tbepr_cdc_vendedor (nmvendedor, nrcpf, dsemail, idcooperado_cdc)
      values (rw_usuario.nmfantasia, rw_usuario.login, rw_usuario.dsemail, rw_usuario.idcooperado_cdc)
      returning idvendedor into vr_idvendedor;
      
      insert into tbepr_cdc_usuario_vinculo (idusuario,idcooperado_cdc,idvendedor )
      values (vr_idusuario, rw_usuario.idcooperado_cdc, vr_idvendedor);
	  
	  commit;
      
    exception
      when others then
        dbms_output.put_line ('EROO: ' || SQLERRM);
        null;
    end;
  end loop;
  
end;