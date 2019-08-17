declare 

  cursor cr_vendedor is
    select a.cdcooper
          ,a.nrdconta
          ,a.nmprimtl
          ,j.nmfansia
          ,c.nmfantasia
          ,v.nmvendedor
          ,v.idvendedor
      from tbsite_cooperado_cdc c 
      join crapass a on (a.cdcooper=c.cdcooper and a.nrdconta=c.nrdconta)
      left join tbepr_cdc_vendedor v on (v.idcooperado_cdc=c.idcooperado_cdc and v.nrcpf=a.nrcpfcgc)
      left join crapjur j on (j.cdcooper=c.cdcooper and j.nrdconta=c.nrdconta)
     where c.cdcooper=1 
       and c.nrdconta=3614948;
       
  cursor cr_valida (pr_vendedor in tbepr_cdc_vendedor.idvendedor%type) is
    select v.idvendedor 
      from tbepr_cdc_usuario_vinculo v
      join tbepr_cdc_usuario u on (u.idusuario=v.idusuario and u.flgadmin=1)
     where v.idvendedor=pr_vendedor;
     
  rw_vendedor                  cr_vendedor%rowtype;  
  rw_valida                    cr_valida%rowtype;  
  vr_idvendedor                tbepr_cdc_vendedor.idvendedor%type;

begin
  
  for rw_vendedor in cr_vendedor loop

    OPEN cr_valida  (rw_vendedor.idvendedor);
    FETCH cr_valida INTO rw_valida;
    
    -- se for ADM entao atualiza
    IF cr_valida%FOUND THEN
    
      begin
        
        update tbepr_cdc_vendedor v
           set nmvendedor = rw_vendedor.nmfantasia
         where v.idvendedor = rw_valida.idvendedor;
        --dbms_output.put_line ('Atualizei o nome: ' || rw_vendedor.nmfantasia);

        commit;
        
      exception
        when others then
          dbms_output.put_line ('EROO: ' || SQLERRM);
          null;
      end;
    ELSE
      null;
      dbms_output.put_line ('Usuário não é ADM então não atualizou o nome');
    END IF;
    CLOSE cr_valida;
  end loop;

  UPDATE tbepr_cdc_vendedor a
     SET a.nmvendedor = REPLACE(a.nmvendedor, '&', 'E')
   WHERE a.idvendedor = 848; 
   
   commit;

end;
