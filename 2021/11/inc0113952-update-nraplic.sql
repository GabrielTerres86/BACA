
DECLARE
    
    vr_excsaida   EXCEPTION;
    vr_dscritic   VARCHAR2(5000) := ' ';
    vr_nraplica craprac.nraplica%TYPE;
    vr_nmarqimp1       VARCHAR2(100)  := 'backup.txt';
    vr_ind_arquiv1     utl_file.file_type;
    vr_nmcidade crapage.nmcidade%TYPE;
    vr_nrdolote craplot.nrdolote%TYPE;
    vr_nrdocmto crappro.nrdocmto%TYPE;
    
    vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
    vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/inc0113952'; 
    
  
    
  CURSOR cr_crapage(pr_cdcooper IN crapage.cdcooper%TYPE
                   ,pr_cdagenci IN crapage.cdagenci%TYPE) IS
  SELECT age.nmcidade
    FROM crapage age
   WHERE age.cdcooper = pr_cdcooper 
     AND age.cdagenci = pr_cdagenci;
    
   CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
   SELECT crapcop.cdcooper
         ,crapcop.dsdircop
         ,crapcop.cdbcoctl
         ,crapcop.cdagectl
         ,crapcop.nmrescop
         ,crapcop.vlinimon
         ,crapcop.vllmonip
         ,crapcop.nmextcop
         ,crapcop.nrdocnpj
         ,crapcop.nrtelura
    FROM crapcop crapcop
   WHERE crapcop.cdcooper = pr_cdcooper;
   rw_crapcop cr_crapcop%ROWTYPE;         
         
   CURSOR cr_craplrg(pr_cdcooper IN craplrg.cdcooper%TYPE
                    ,pr_nrdconta IN craplrg.nrdconta%TYPE
                    ,pr_nraplica IN craplrg.nraplica%TYPE) IS
                       
         SELECT lrg.nrdocmto, 
                lrg.vllanmto,
                lrg.dtmvtolt    
           FROM craplrg lrg
          WHERE lrg.cdcooper = pr_cdcooper
            AND lrg.nrdconta = pr_nrdconta
            AND lrg.nraplica = pr_nraplica;
       rw_craplrg cr_craplrg%ROWTYPE;      
         
   CURSOR cr_craplapaplic(pr_cdcooper IN craplap.cdcooper%TYPE
                         ,pr_nrdconta IN craplap.nrdconta%TYPE
                         ,pr_nraplica IN craplap.nraplica%TYPE) IS
                       
        SELECT lap.dtmvtolt,
               lap.cdcooper,
               lap.nrdconta,
               lap.nraplica,
               lap.nrdocmto,
               lap.txaplica,
               lap.txaplmes
          FROM craplap lap
         WHERE lap.cdcooper = pr_cdcooper
           AND lap.nrdconta = pr_nrdconta
           AND lap.nraplica = pr_nraplica
           AND lap.cdhistor = 528;
       rw_craplapaplic cr_craplapaplic%ROWTYPE;              
         
   CURSOR cr_craprda(pr_cdcooper IN craprda.cdcooper%TYPE
                    ,pr_nrdconta IN craprda.nrdconta%TYPE
                    ,pr_nraplica IN craprda.nraplica%TYPE)IS

        SELECT rda.cdcooper
              ,rda.nrdconta
              ,rda.nraplica
              ,rda.dtmvtolt
              ,rda.dtfimper
              ,rda.qtdiauti
          FROM craprda rda
         WHERE rda.cdcooper = pr_cdcooper
           AND rda.nrdconta = pr_nrdconta
           AND rda.nraplica = pr_nraplica;

      rw_craprda cr_craprda%ROWTYPE;
                       
   CURSOR cr_aplica IS
     SELECT rda.cdcooper,
            rda.nrdconta,
            rda.nraplica,
            rda.cdagenci,
            rda.dtfimper,
            rda.qtdiauti
       FROM craprda rda, 
            craprac rac
      WHERE rda.cdcooper = rac.cdcooper
        AND rda.nrdconta = rac.nrdconta
        AND rda.nraplica = rac.nraplica 
        AND rac.cdprodut <> 1007;
   
   rw_aplica cr_aplica%ROWTYPE;
   
   procedure backup (pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv1, pr_msg);
  END; 
  
  PROCEDURE fecha_arquivos IS
  BEGIN
     gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv1); 
  END; 
  
BEGIN
   --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp1       --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv1     --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;  
  FOR rw_aplica IN cr_aplica LOOP
    
    -- Busca cooperativa
    OPEN cr_crapcop(pr_cdcooper => rw_aplica.cdcooper);
      
    FETCH cr_crapcop INTO rw_crapcop;
    
    --Se nao encontrou
    IF cr_crapcop%NOTFOUND THEN
      
      --Fechar Cursor
      CLOSE cr_crapcop;
      

      vr_dscritic:= 'Cooperativa nao encontrado!'||rw_aplica.cdcooper;
      
      -- Gera exce??o
      RAISE vr_excsaida;
      
    END IF;
      
    --Fechar Cursor
    CLOSE cr_crapcop;
    
    -- Busca a cidade do PA do associado
    OPEN cr_crapage(pr_cdcooper => rw_aplica.cdcooper
                   ,pr_cdagenci => rw_aplica.cdagenci);
                           
    FETCH cr_crapage INTO vr_nmcidade;
            
    IF cr_crapage%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapage;
                

      vr_dscritic:= 'Agencia nao encontrada!'||rw_aplica.cdagenci;
                
      -- Gera exce??o
      RAISE vr_excsaida;
    ELSE
      -- Fechar o cursor
      CLOSE cr_crapage;
              
    END IF; 
    
    vr_nraplica := 0;
    LOOP
      -- Verifica o valor da sequence        
      vr_nraplica := fn_sequence(pr_nmtabela => 'CRAPRAC'
                                ,pr_nmdcampo => 'NRAPLICA'
                                ,pr_dsdchave => rw_aplica.cdcooper || ';' || rw_aplica.nrdconta
                                ,pr_flgdecre => 'N');
      /* Consulta CRAPRDA para nao existir aplicacoes com o mesmo numero mesmo
      sendo produto antigo e novo */

      OPEN cr_craprda(pr_cdcooper => rw_aplica.cdcooper
                     ,pr_nrdconta => rw_aplica.nrdconta
                     ,pr_nraplica => vr_nraplica);

      FETCH cr_craprda INTO rw_craprda;

      IF cr_craprda%FOUND THEN
        CLOSE cr_craprda;
        CONTINUE;
      ELSE
        CLOSE cr_craprda;
        EXIT;
      END IF;

    END LOOP;
      
    --atualizar comprovante aplicacao
    OPEN cr_craplapaplic(pr_cdcooper => rw_aplica.cdcooper
                        ,pr_nrdconta => rw_aplica.nrdconta
                        ,pr_nraplica => rw_aplica.nraplica);

    FETCH cr_craplapaplic INTO rw_craplapaplic;

    IF cr_craplapaplic%FOUND THEN
      vr_nrdolote := 8470;
      vr_nrdocmto := TO_NUMBER(SUBSTR(gene0002.fn_mask(TO_CHAR(vr_nrdolote),'9999'),1,2) || gene0002.fn_mask(TO_CHAR(rw_aplica.nraplica), '999999'));      
      
      UPDATE crappro pro
         SET pro.dsinform##3 =  'Data da Aplicacao: '   || TO_CHAR(rw_craplapaplic.dtmvtolt,'dd/mm/yyyy')              || '#' ||
                                'Numero da Aplicacao: ' || TO_CHAR(vr_nraplica,'9G999G990')       || '#' ||
                                'Taxa Contratada: '     || TO_CHAR(NVL(rw_craplapaplic.txaplica, '0'), 'fm990D00') || '% DO CDI ' || '#' ||
                                'Taxa Minima: '         || TO_CHAR(NVL(rw_craplapaplic.txaplmes, '0'), 'fm990D00') || '% DO CDI ' || '#' ||
                                'Vencimento: '          || TO_CHAR(rw_aplica.dtfimper,'dd/mm/yyyy')               || '#' ||
                                'Carencia: '            || TO_CHAR(rw_aplica.qtdiauti,'99990') || ' DIA(S)'       || '#' ||
                                'Data da Carencia: '    || TO_CHAR(rw_craplapaplic.dtmvtolt + rw_aplica.qtdiauti,'dd/mm/yyyy') || '#' ||
                                'Cooperativa: '         || UPPER(rw_crapcop.nmextcop) || '#' || 
                                'CNPJ: '                || TO_CHAR(gene0002.fn_mask_cpf_cnpj(rw_crapcop.nrdocnpj,2)) || '#' ||
                                UPPER(TRIM(vr_nmcidade)) || ', ' || TO_CHAR(rw_craplapaplic.dtmvtolt,'dd') || ' DE ' || GENE0001.vr_vet_nmmesano(TO_CHAR(rw_craplapaplic.dtmvtolt,'mm')) || ' DE ' || TO_CHAR(rw_craplapaplic.dtmvtolt,'RRRR') || '.'                           
      WHERE pro.cdcooper = rw_aplica.cdcooper
        AND pro.nrdconta = rw_aplica.nrdconta
        AND pro.dtmvtolt = rw_craplapaplic.dtmvtolt
        AND pro.nrdocmto = vr_nrdocmto;
      
      CLOSE cr_craplapaplic;
    ELSE
      CLOSE cr_craplapaplic;
    END IF;      
         
                  
     FOR rw_craplrg IN cr_craplrg(pr_cdcooper => rw_aplica.cdcooper
                                  ,pr_nrdconta => rw_aplica.nrdconta
                                  ,pr_nraplica => rw_aplica.nraplica) LOOP

      UPDATE crappro pro
         SET pro.dsinform##3 = 'Data do Resgate: '   || TO_CHAR(rw_craplrg.dtmvtolt,'dd/mm/yyyy')           || '#' ||
                               'Numero da Aplicacao: ' || TO_CHAR(vr_nraplica,'9G999G990')    || '#' ||
                               'IRRF (Imposto de Renda Retido na Fonte): ' || TO_CHAR(NVL('', '0'),'999G999G990D00') || '#' ||
                               'Aliquota IRRF: '       || TO_CHAR(NVL('', '0'), 'fm990D00') || '%' || '#'  ||                            
                               'Valor Bruto: '         || TO_CHAR((rw_craplrg.vllanmto ),'999G999G990D00') || '#'  ||                                 
                               'Cooperativa: '         || UPPER(rw_crapcop.nmextcop) || '#' || 
                               'CNPJ: '                || TO_CHAR(gene0002.fn_mask_cpf_cnpj(rw_crapcop.nrdocnpj,2)) || '#' || 
                               UPPER(TRIM(vr_nmcidade)) || ', ' || TO_CHAR(rw_craplrg.dtmvtolt,'dd') || ' DE ' || 
                               GENE0001.vr_vet_nmmesano(TO_CHAR(rw_craplrg.dtmvtolt,'mm')) || ' DE ' || TO_CHAR(rw_craplrg.dtmvtolt,'RRRR') || '.'  
       WHERE pro.cdcooper = rw_aplica.cdcooper
         AND pro.nrdconta = rw_aplica.nrdconta
         AND pro.dtmvtolt = rw_craplrg.dtmvtolt
         AND pro.nrdocmto = rw_craplrg.nrdocmto ;  

    END LOOP;                
      
   
      
      backup('update craprda set nraplica = '||rw_aplica.nraplica||' where cdcooper = '|| rw_aplica.cdcooper ||'and nrdconta = '||rw_aplica.nrdconta||' and nraplica = '||vr_nraplica||';');
      backup('update craplap set nraplica = '||rw_aplica.nraplica||' where cdcooper = '|| rw_aplica.cdcooper ||'and nrdconta = '||rw_aplica.nrdconta||' and nraplica = '||vr_nraplica||';');
      
      UPDATE craprda rda
         SET rda.nraplica = vr_nraplica
       WHERE rda.cdcooper = rw_aplica.cdcooper
         AND rda.nrdconta = rw_aplica.nrdconta
         AND rda.nraplica = rw_aplica.nraplica;
         
      UPDATE craplap lap
         SET lap.nraplica = vr_nraplica
       WHERE lap.cdcooper = rw_aplica.cdcooper
         AND lap.nrdconta = rw_aplica.nrdconta
         AND lap.nraplica = rw_aplica.nraplica;
         
                  
         
  END LOOP;      

  COMMIT;   
  fecha_arquivos; 
    EXCEPTION 
       WHEN vr_excsaida then  
       backup('ERRO ' || vr_dscritic);  
       fecha_arquivos;  
       ROLLBACK;    
      WHEN OTHERS then
       vr_dscritic :=  sqlerrm;
       backup('ERRO ' || vr_dscritic); 
       fecha_arquivos; 
       ROLLBACK;       
END;
