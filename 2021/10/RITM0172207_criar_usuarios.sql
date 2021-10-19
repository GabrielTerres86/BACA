declare
  TYPE t_usuario IS RECORD
     ( nrcpf        VARCHAR2(25)
      ,nmvendedor   VARCHAR2(200)
      ,dsemail      VARCHAR2(200)
      ,admin        VARCHAR2(15)
     );

  TYPE tp_usuario IS TABLE OF t_usuario INDEX BY PLS_INTEGER;

  CURSOR cr_loja IS
    SELECT  idcooperado_cdc
    FROM    tbsite_cooperado_cdc
    WHERE cdcooper = 6 -- Unilos
    AND   nrdconta = 243493 -- Lojas Colombo
    and   idmatriz is null;
  vr_idcooperado_cdc      number;

  -- Verificar login antivo existente
  CURSOR cr_usuario (pr_dslogin         IN tbepr_cdc_usuario.dslogin%type,
                                 pr_idcooperado_cdc IN tbepr_cdc_usuario_vinculo.idcooperado_cdc%TYPE) IS      
    SELECT u.idusuario
      FROM tbepr_cdc_usuario u,
           tbepr_cdc_usuario_vinculo v,
           tbsite_cooperado_cdc c
     WHERE u.idusuario = v.idusuario 
       AND v.idcooperado_cdc = c.idcooperado_cdc
       AND u.dslogin         = pr_dslogin
       AND v.idcooperado_cdc = pr_idcooperado_cdc; 
  rw_usuario    cr_usuario%ROWTYPE;
  -- Verificar login antivo existente

  CURSOR cr_usuario_ativo (pr_dslogin         IN tbepr_cdc_usuario.dslogin%type,
                                 pr_idcooperado_cdc IN tbepr_cdc_usuario_vinculo.idcooperado_cdc%TYPE) IS      
    SELECT v.idcooperado_cdc,
           c.nmfantasia
      FROM tbepr_cdc_usuario u,
           tbepr_cdc_usuario_vinculo v,
           tbsite_cooperado_cdc c
     WHERE u.idusuario = v.idusuario 
       AND v.idcooperado_cdc = c.idcooperado_cdc
       AND u.dslogin         = pr_dslogin         
       AND u.flgativo        = 1
       AND v.idcooperado_cdc <> pr_idcooperado_cdc; 
  rw_usuario_ativo cr_usuario_ativo%ROWTYPE;

  tb_usuario              tp_usuario;
  vr_nrcpf                VARCHAR2(200);
  vr_fladmin              NUMBER(01);
  vr_dscritic             VARCHAR2(200);

  vr_nmdireto             VARCHAR2(3000);
  vr_arqhandl             utl_file.file_type;
  vr_linha                VARCHAR2(5000);
begin
  vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'C', pr_cdcooper => 6, pr_nmsubdir => '/log');

  -- Abrir arquivo
  GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => 'lojas_colombro_criar_usuarios.log'
                          ,pr_tipabert => 'A'
                          ,pr_utlfileh => vr_arqhandl
                          ,pr_des_erro => vr_dscritic);

  IF vr_dscritic IS NOT NULL THEN
    RAISE_APPLICATION_ERROR(-20501, 'Erro ao abrir aquivo : ' || vr_dscritic);
  END IF;

  OPEN cr_loja;
  FETCH  cr_loja
  INTO   vr_idcooperado_cdc;
  CLOSE cr_loja;

  vr_linha := 'idcooperado_cdc Lojas Colombo=' || vr_idcooperado_cdc;
  GENE0001.pc_escr_linha_arquivo(vr_arqhandl,vr_linha);

tb_usuario( 1 ) := t_usuario('006.772.100-19', 'DEIVID CIEPIELEWSKI', 'deivid@colombo.com.br', 'Administrador');
tb_usuario( 2 ) := t_usuario('994.394.090-53', 'ROSANGELA DE OLIVEIRA', 'rosangela.oliveira@colombo.com.br', 'Administrador');
tb_usuario( 3 ) := t_usuario('962.572.880-53', 'VANDERLEIA MARQUES DAL VESCO', 'vanderleia.vesco@colombo.com.br', 'Administrador');
tb_usuario( 4 ) := t_usuario('030.680.340-27', 'ALANA LODI', 'alana.lodi@colombo.com.br', 'Administrador');
tb_usuario( 5 ) := t_usuario('029.014.640-25', 'BRUNA ZENI', 'brunaz@colombo.com.br', 'Administrador');
tb_usuario( 6 ) := t_usuario('012.789.920-06', 'JUCIANE BAREA', 'juciane@colombo.com.br', 'Administrador');
tb_usuario( 7 ) := t_usuario('028.341.290-96', 'JESSICA HORTENCIA VIEIRA', 'jessica.vieira@colombo.com.br', 'Administrador');
tb_usuario( 8 ) := t_usuario('038.911.400-61', 'LIVIA ALOMA LOPES', 'livia.lopes@colombo.com.br', 'Administrador');
tb_usuario( 9 ) := t_usuario('001.570.280-46', 'FABIANO MASIERO', 'fabianom@colombo.com.br', 'Administrador');
tb_usuario( 10  ) := t_usuario('012.685.070-40', 'KETLIN LUANDA ZINN', 'ketlin.zinn@colombo.com.br', 'Administrador');
tb_usuario( 11  ) := t_usuario('012.502.831.83', 'PAULO TAIRA', 'paulod@colombo.com.br', 'Administrador');
tb_usuario( 12  ) := t_usuario('034.760.750-01', 'DANIELE LIS GEHLEN', 'daniele@colombo.com.br', 'Administrador');
tb_usuario( 13  ) := t_usuario('832.421.550-68', 'MICHELI BORSATO', 'contasfornecedores@colombo.com.br', 'Administrador');
tb_usuario( 14  ) := t_usuario('921.271.939-20', 'ANDRÉ LUIZ DA SILVA', 'andre.silva@colombo.com.br', 'Administrador');

  for ind_usuario in 1..nvl(tb_usuario.last, 0) loop
    tb_usuario(ind_usuario).nrcpf := ltrim(translate(tb_usuario(ind_usuario).nrcpf, ' .-', ' '));
    vr_nrcpf := tb_usuario(ind_usuario).nrcpf;

    IF length(vr_nrcpf) <= 11 THEN
      vr_nrcpf := lpad(vr_nrcpf, 11, '0');
    ELSE
      vr_nrcpf := lpad(vr_nrcpf, 14, '0');
    END IF;

    IF substr(tb_usuario(ind_usuario).admin, 1, 1) = 'A' THEN
      vr_fladmin := 1;
    ELSE
      vr_fladmin := 0;
    END IF;


    OPEN cr_usuario(pr_dslogin         => vr_nrcpf,
                    pr_idcooperado_cdc => vr_idcooperado_cdc);        
    FETCH cr_usuario INTO rw_usuario;
      
    -- Se se encontrou o login
    IF cr_usuario%NOTFOUND THEN
      rw_usuario.idusuario := NULL;
    END IF;      
    CLOSE cr_usuario;


    OPEN cr_usuario_ativo( pr_dslogin         => vr_nrcpf,
                           pr_idcooperado_cdc => vr_idcooperado_cdc);          
    FETCH cr_usuario_ativo INTO rw_usuario_ativo;
      
    -- Se se encontrou o login
    IF cr_usuario_ativo%FOUND THEN
      CLOSE cr_usuario_ativo;
      -- Gerar crítica
      vr_linha := 'Login ' || vr_nrcpf || ' já associado ao lojista '||
                        rw_usuario_ativo.idcooperado_cdc||' - '|| rw_usuario_ativo.nmfantasia || '. ' || tb_usuario(ind_usuario).nmvendedor;       
      GENE0001.pc_escr_linha_arquivo(vr_arqhandl,vr_linha);
      CONTINUE;
    END IF;      
    CLOSE cr_usuario_ativo;

    EMPR0012.pc_cadastra_usuario(pr_idusuario        => rw_usuario.idusuario
                                ,pr_dslogin          => vr_nrcpf
                                ,pr_dssenha          => lower(RAWTOHEX(DBMS_OBFUSCATION_TOOLKIT.md5(input => UTL_RAW.cast_to_raw(vr_nrcpf))))
                                ,pr_dtinsori         => null
                                ,pr_flgativo         => 1
                                ,pr_fladmin          => vr_fladmin
                                ,pr_idcooperado_cdc  => vr_idcooperado_cdc
                                ,pr_nmvendedor       => tb_usuario(ind_usuario).nmvendedor
                                ,pr_nrcpf            => to_number(tb_usuario(ind_usuario).nrcpf)
                                ,pr_dsemail          => tb_usuario(ind_usuario).dsemail
                                ,pr_idcomissao       => null
                                ,pr_dscritic         => vr_dscritic
                                );
    IF vr_dscritic is not null THEN
      ROLLBACK;
      vr_linha := 'Erro no CPF ' || tb_usuario(ind_usuario).nrcpf || ' : ' || vr_dscritic;
      GENE0001.pc_escr_linha_arquivo(vr_arqhandl,vr_linha);
      CONTINUE;
    END IF;
    
    COMMIT;
  end loop;
  
  COMMIT;
  GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_arqhandl);
EXCEPTION
  WHEN others THEN
    RAISE_APPLICATION_ERROR(-20502, 'Erro: ' || SQLERRM);
end;
/
