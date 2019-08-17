declare 
  cursor cr_crapsim is
    select s.cdcooper
          ,s.nrdconta
          ,s.nrsimula
          ,s.qtparepr
          ,s.vlparepr
          ,s.dtdpagto
          ,s.rowid
      from crapsim s
     where not exists (select 1 
                         from tbepr_simulacao_parcela p
                        where p.cdcooper=s.cdcooper 
                          and p.nrdconta=s.nrdconta
                          and p.nrsimula=s.nrsimula);
  rw_crapsim cr_crapsim%rowtype;
  
  vr_contador integer;
  vr_registro integer;
  vr_dtvencto DATE;
begin

  FOR rw_crapsim in cr_crapsim LOOP

    update crapsim set tpemprst=1 where rowid=rw_crapsim.rowid;

    vr_contador := 1;
    FOR vr_registro in vr_contador..rw_crapsim.qtparepr LOOP

      IF vr_registro = 1 THEN
         vr_dtvencto := rw_crapsim.dtdpagto;
      ELSE  
        vr_dtvencto := ADD_MONTHS(rw_crapsim.dtdpagto, vr_contador-1);
      END IF;

      BEGIN
        INSERT INTO tbepr_simulacao_parcela
                   (cdcooper
                   ,nrdconta
                   ,nrsimula
                   ,nrparepr
                   ,vlparepr
                   ,dtvencto)
            VALUES (rw_crapsim.cdcooper
                   ,rw_crapsim.nrdconta
                   ,rw_crapsim.nrsimula
                   ,vr_registro
                   ,rw_crapsim.vlparepr
                   ,vr_dtvencto);
        vr_contador := vr_contador + 1;
        --dbms_output.put_line('tbepr_simulacao_parcela: ' ||  vr_registro || ' Mes ' || vr_dtvencto);        
        --rollback;
        commit;

      EXCEPTION
        WHEN OTHERS THEN
          null;
          --dbms_output.put_line('Erro ao inserir tbepr_simulacao_parcela: ' || SQLERRM);
          --dbms_output.put_line('Dados: ' || rw_crapsim.cdcooper || ' - ' || rw_crapsim.nrdconta || ' - ' || rw_crapsim.nrsimula || ' - ' || vr_registro);
      END;
    END LOOP;  
  END LOOP;
  
end;