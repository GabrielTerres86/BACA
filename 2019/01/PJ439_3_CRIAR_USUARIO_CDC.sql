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
      from crapass a
      join crapcdr c on (c.cdcooper=a.cdcooper and c.nrdconta=a.nrdconta)
      join tbsite_cooperado_cdc l on (l.cdcooper=c.cdcooper and l.nrdconta=c.nrdconta and l.idmatriz is null)
     where a.cdcooper=1 
       and a.nrdconta in (8022038, 7718284, 9424539);
     
  cursor cr_valida (pr_dslogin in tbepr_cdc_usuario.dslogin%type) is
    select *
      from tbepr_cdc_usuario u
     where u.dslogin = pr_dslogin;
     
  rw_usuario                   cr_usuario%rowtype;  
  rw_valida                    cr_valida%rowtype;  
  vr_idusuario                 tbepr_cdc_usuario.idusuario%type;
  vr_idvendedor                tbepr_cdc_vendedor.idvendedor%type;

begin
  
  for rw_usuario in cr_usuario loop
    --dbms_output.put_line ('Passei: ' || rw_usuario.idcooperado_cdc);
    -- criar controle para nao gerar mais de um login igual
    OPEN cr_valida  (rw_usuario.login);
    FETCH cr_valida INTO rw_valida;
    
    IF cr_valida%NOTFOUND THEN
    
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
    ELSE
      null;
      dbms_output.put_line ('Usuário já existe');
    END IF;
    CLOSE cr_valida;
  end loop;
  
end;
