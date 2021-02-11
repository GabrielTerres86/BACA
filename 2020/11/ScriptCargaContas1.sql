declare

 cursor c1 is
 select nmsistem,
        cdcooper,
        cdacesso,
        dstexprm,
        dsvlrprm
   from crapprm p
  where p.cdacesso = 'CTA_CTR_ACAO_JUDICIAL'
    and p.nmsistem = 'CRED';

 vr_pos number;
 vr_pos2 number;
 
 vr_vet_dados gene0002.typ_split;
 vr_vet_dados2 gene0002.typ_split;

begin
 for r1 in c1 loop
  vr_vet_dados := gene0002.fn_quebra_string(pr_string  => trim(r1.dsvlrprm)
                                           ,pr_delimit => '),(');
  IF vr_vet_dados.COUNT > 2 THEN
    FOR vr_pos IN 1..vr_vet_dados.COUNT LOOP
      vr_vet_dados2 := gene0002.fn_quebra_string(pr_string  => replace(replace(vr_vet_dados(vr_pos),'('),')')
                                                ,pr_delimit => ',');
      FOR vr_pos2 IN 1..vr_vet_dados2.COUNT LOOP                                          
        dbms_output.put_line('Conta   >>'||vr_vet_dados2(1));
        dbms_output.put_line('Contrato>>'||vr_vet_dados2(2));
        BEGIN     
         INSERT INTO CREDITO.tbblqj_contrato_bloqueado
            (cdcooper
            ,nrdconta
            ,nrctremp
            ,dtbloqueio
            ,cdoperador_bloqueio
            ,dtdesbloqueio
            ,cdoperador_desbloqueio
            ,dsobservacao)
          VALUES
            (R1.cdcooper
            ,vr_vet_dados2(1) -- Conta
            ,vr_vet_dados2(2) -- Contrato
            ,Sysdate
            ,'1'
            ,NULL
            ,NULL
            ,'Bloqueio via Script.');       
        EXCEPTION
          WHEN OTHERS THEN
            dbms_output.put_line('Erro ao Inserir: '||sqlerrm);
        END;      
      END LOOP;             
    END LOOP;
  ELSE
    vr_vet_dados2 := gene0002.fn_quebra_string(pr_string  => replace(replace(trim(r1.dsvlrprm),'('),')')
                                              ,pr_delimit => ',');
    FOR vr_pos2 IN 1..vr_vet_dados2.COUNT LOOP                                          
      dbms_output.put_line('Conta   >>'||vr_vet_dados2(1));
      dbms_output.put_line('Contrato>>'||vr_vet_dados2(2));      
      BEGIN     
       INSERT INTO CREDITO.tbblqj_contrato_bloqueado
          (cdcooper
          ,nrdconta
          ,nrctremp
          ,dtbloqueio
          ,cdoperador_bloqueio
          ,dtdesbloqueio
          ,cdoperador_desbloqueio
          ,dsobservacao)
        VALUES
          (R1.cdcooper
          ,vr_vet_dados2(1) -- Conta
          ,vr_vet_dados2(2) -- Contrato
          ,Sysdate
          ,'1'
          ,NULL
          ,NULL
          ,'Bloqueio via Script.');       
      EXCEPTION
        WHEN OTHERS THEN
          dbms_output.put_line('Erro 2 ao Inserir: '||sqlerrm);
      END;        
    END LOOP;    
  END IF;  
 end loop;  
 COMMIT;
exception
 when others then
  dbms_output.put_line('Erro: '||sqlerrm);
end;
