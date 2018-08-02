PL/SQL Developer Test script 3.0
108
-- Created on 26/07/2018 by T0031670 
declare 


/**
PREPARAR PARA SALVAR OS ERROS NO ARQUIVO EM ALGUM LUGAR DO /MICROS/CECRED/
**/


  -- Local variables here
  vr_retorno BOOLEAN;
  vr_dsretor VARCHAR2(3);
  vr_contador PLS_INTEGER;
  --Seleciona os cooperados
  CURSOR cr_cop IS
    SELECT c.cdcooper
      FROM crapcop c
     WHERE c.flgativo = 1
       AND c.cdcooper <> 3
       --AND c.cdcooper = 9
   ORDER BY cdcooper       
       ;

  CURSOR cr_grupos (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT *
      FROM (SELECT 2 tipo, i.idgrupo nrdgrupo
                 , i.nrdconta, i.nrcpfcgc, DECODE(i.tppessoa,1,'PF','PJ') inpessoa
                 , DECODE(i.tppessoa,1,i.nrcpfcgc,to_number(SUBSTR(to_char(i.nrcpfcgc,'FM00000000000000'),1,8) ) ) CPF_BASE
                 , x.inrisco_grupo innivrge
                 ,x.nrdconta CTA_PAI
                 ,i.rowid
              FROM tbcc_grupo_economico_integ i,  tbcc_grupo_economico x
             WHERE i.cdcooper = pr_cdcooper
               AND i.dtexclusao IS NULL
               AND i.idgrupo  = x.idgrupo
    ) tmp
    ORDER BY CPF_BASE, nrcpfcgc, nrdconta
    ;
  rw_grupos cr_grupos%ROWTYPE;
  
begin
  dbms_output.put_line('INICIO: ' || to_char(SYSDATE,'hh24:mi:ss'));  
  FOR rw_cop IN cr_cop LOOP
    dbms_output.put_line('COOP: ' || rw_cop.cdcooper );
    vr_contador := 0;
    FOR rw_grupos IN cr_grupos (rw_cop.cdcooper) LOOP
      
    
       IF rw_grupos.inpessoa = 'PF' THEN
         GENE0005.pc_valida_cpf(pr_nrcalcul => rw_grupos.nrcpfcgc
                               ,pr_stsnrcal => vr_retorno);
         IF NOT vr_retorno THEN
           vr_contador := vr_contador + 1;

           -- Validar se pode ser um CNPJ
           GENE0005.pc_valida_cnpj(pr_nrcalcul => rw_grupos.nrcpfcgc
                                  ,pr_stsnrcal => vr_retorno);
           IF vr_retorno THEN
             dbms_output.put_line(' Este CPF deve ser um CNPJ! '
                               || ' Conta PAI: ' || rw_grupos.CTA_PAI
                               || ' - CPF/CNPJ:' || rw_grupos.nrcpfcgc 
                               || ' - Tipo Cadastrado:' || rw_grupos.inpessoa
                               || ' - contador: ' || vr_contador);
             UPDATE tbcc_grupo_economico_integ
                SET tppessoa = 2
              WHERE ROWID = rw_grupos.rowid;
           ELSE
             dbms_output.put_line(' CPF INVALIDO! '
                               || ' Conta PAI: ' || rw_grupos.CTA_PAI
                               || ' - CPF/CNPJ:' || rw_grupos.nrcpfcgc 
                               || ' - Tipo Cadastrado:' || rw_grupos.inpessoa
                               || ' - contador: ' || vr_contador);
           END IF;
         END IF;
       ELSE -- Tratamento do CPNJ
         GENE0005.pc_valida_cnpj(pr_nrcalcul => rw_grupos.nrcpfcgc
                                ,pr_stsnrcal => vr_retorno);
         IF NOT vr_retorno THEN
           vr_contador := vr_contador + 1;

           -- Validar se pode ser um CPF
           GENE0005.pc_valida_cpf(pr_nrcalcul => rw_grupos.nrcpfcgc
                               ,pr_stsnrcal => vr_retorno);
           IF vr_retorno THEN
             dbms_output.put_line(' Este CNPJ deve ser um CPF! '
                               || ' Conta PAI: ' || rw_grupos.CTA_PAI
                               || ' - CPF/CNPJ:' || rw_grupos.nrcpfcgc 
                               || ' - Tipo Cadastrado:' || rw_grupos.inpessoa
                               || ' - contador: ' || vr_contador);
             UPDATE tbcc_grupo_economico_integ
                SET tppessoa = 1
              WHERE ROWID = rw_grupos.rowid;
           ELSE
             dbms_output.put_line(' CNPJ INVALIDO! '
                               || ' Conta PAI: ' || rw_grupos.CTA_PAI
                               || ' - CPF/CNPJ:' || rw_grupos.nrcpfcgc 
                               || ' - Tipo Cadastrado:' || rw_grupos.inpessoa
                               || ' - contador: ' || vr_contador);
           END IF;
         END IF;
       END IF;
       
       IF vr_retorno THEN
         vr_dsretor := 'SIM';
       ELSE
         vr_dsretor  := 'NAO';

       END IF;

    END LOOP;
    COMMIT;
  END LOOP;
  dbms_output.put_line('FIM: ' || to_char(SYSDATE,'hh24:mi:ss'));  
  
end;
0
0
