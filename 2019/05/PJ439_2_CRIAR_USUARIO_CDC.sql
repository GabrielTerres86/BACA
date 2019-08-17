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
     where 
        (a.cdcooper=11 
       and a.nrdconta=59005)
       OR
       (a.cdcooper=12
       and a.nrdconta in (57398,88960))
       OR
       (a.cdcooper=16
       and a.nrdconta in (80225,3063887))
       OR
       (a.cdcooper=1
       and a.nrdconta in (9257276,
                          9259066,
                          9512993,
                          7124678,
                          9223924,
                          9114580,
                          8017034,
                          8994315,
                          8931976,
                          8855188,
                          8758239,
                          8731047,
                          8657505,
                          8648611,
                          8173451,
                          8057788,
                          7650140,
                          8063923,
                          7330006,
                          8012423,
                          7748035,
                          6417574,
                          6751016,
                          7747047,
                          7613334,
                          6819869,
                          6298320,
                          6538789,
                          3700569,
                          7430302,
                          7311591,
                          7112866,
                          7112874,
                          2378710,
                          7208987,
                          2812371,
                          6657745,
                          867900,
                          3596770,
                          6237479,
                          2318431,
                          6677169,
                          6738249,
                          6578500,
                          2029545,
                          6186556,
                          3846636,
                          7215436,
                          2258862,
                          7800100,
                          2471310,
                          2205076,
                          3607690,
                          1529234,
                          2297132,
                          2528673,
                          1948695,
                          843083,
                          2199947
                          ))
       ;

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
