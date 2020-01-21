declare 

  cursor cr_usuario is
    select v.idcooperado_cdc
          ,vv.nrcpf
      from tbepr_cdc_usuario u
      join tbepr_cdc_usuario_vinculo v on (v.idusuario=u.idusuario)
      join tbepr_cdc_vendedor vv on (vv.idvendedor=v.idvendedor)
     where u.flgadmin=1;

  rw_usuario            cr_usuario%rowtype;
  vr_dslogin            tbepr_cdc_usuario.dslogin%TYPE;
  vr_dssenha            tbepr_cdc_usuario.dssenha%TYPE;
  vr_nmvendedor         tbepr_cdc_vendedor.nmvendedor%TYPE := 'AILOS MOBILE';
  vr_cdcritic           crapcri.cdcritic%TYPE;
  vr_dscritic           crapcri.dscritic%TYPE;

begin
  
  FOR rw_usuario in cr_usuario LOOP

    vr_dslogin := 'APP_COOPERADO';
    vr_dssenha := lower(RAWTOHEX(DBMS_OBFUSCATION_TOOLKIT.md5(input => UTL_RAW.cast_to_raw(vr_dslogin))));

    TELA_ATENDA_CVNCDC.pc_manter_usuario_cdc(pr_cddopcao        => 'I'             --> Opção da Tela
                                            ,pr_cdusuario       => NULL            --> Id. Usuario
                                            ,pr_senha           => vr_dssenha                --> Senha Usuario
                                            ,pr_tipo            => 0 -- ADMIN      --> Admin ou Vend
                                            ,pr_vinculo         => NULL            --> Id do Vinculo
                                            ,pr_ativo           => 1               --> Ativo
                                            ,pr_bloqueio        => 0               --> Boqueado
                                            ,pr_dslogin         => vr_dslogin                --> Login
                                            ,pr_idcooperado_cdc => rw_usuario.idcooperado_cdc --> Id do cooperado CDC 
                                            ,pr_nmvendedor      => vr_nmvendedor       --> Nome do vendedor
                                            ,pr_nrcpf           => rw_usuario.nrcpf --> Numero do CPF                                     
                                            ,pr_cdcritic        => vr_cdcritic     --> Codigo da critica
                                            ,pr_dscritic        => vr_dscritic);   --> Descricao da critica

    IF vr_cdcritic >0 OR vr_dscritic IS NOT NULL THEN
      dbms_output.put_line('Erro: ' || vr_dscritic);
      null;
    END IF;

  END LOOP;
  
  commit;
end;
