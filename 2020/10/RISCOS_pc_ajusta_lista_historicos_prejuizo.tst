PL/SQL Developer Test script 3.0
48
declare 
  
  TYPE typ_tab_hstexc IS TABLE OF NUMBER
    INDEX BY PLS_INTEGER;
  
  vr_tab_lsthis   gene0002.typ_split;
  vr_tab_hstexc   typ_tab_hstexc;
  vr_dslsthis     VARCHAR2(4000);
  
  vr_tab_lst_nova gene0002.typ_split;

begin
  vr_tab_lst_nova := gene0002.fn_quebra_string(pr_string  => '2321;2681;2685;2670;2386;2317', 
                                               pr_delimit => ';');

   -- Carrega lista dos históricos de débito que não devem incrementar o prejuízo 
  vr_dslsthis := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                             pr_cdcooper => 0, 
                                             pr_cdacesso => 'HISTOR_PREJ_N_SALDO');
                                             
  vr_tab_lsthis := gene0002.fn_quebra_string(pr_string  => vr_dslsthis, 
                                             pr_delimit => ';');
                                            
  IF vr_tab_lsthis.count > 0 THEN
    FOR i IN vr_tab_lsthis.first..vr_tab_lsthis.last LOOP
      vr_tab_hstexc(vr_tab_lsthis(i)) := vr_tab_lsthis(i);
    END LOOP;
  END IF;

  FOR i IN vr_tab_lst_nova.first..vr_tab_lst_nova.last LOOP
    -- De todos os historicos novos, verificar se ja existe na lista
    -- Se ja existe, ignora
    IF vr_tab_hstexc.exists(vr_tab_lst_nova(i)) THEN
      CONTINUE; -- Ignora o lançamento
    ELSE
      dbms_output.put_line('Valor: ' || i || ' - ' || vr_tab_lst_nova(i) ||
                           ' UPDATE: ' || ';' || vr_tab_lst_nova(i));
      UPDATE crapprm prm
         SET prm.dsvlrprm = prm.dsvlrprm || ';' || vr_tab_lst_nova(i)
       WHERE prm.nmsistem = 'CRED'
         AND prm.cdcooper = 0 --> Busca tanto da passada, quanto da geral (se existir)
         AND prm.cdacesso = 'HISTOR_PREJ_N_SALDO';
    END IF;
  END LOOP; 

  COMMIT;
  
end;
0
1
i
