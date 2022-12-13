
    DECLARE
      vr_nrseqdig craplot.nrseqdig%TYPE;
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
      vr_vlsldant craprac.vlsldant%TYPE;
      vr_dtsldant craprac.dtsldant%TYPE;
      vr_vllanmto craplac.vllanmto%TYPE;
      vr_new_dtaniver  craprac.dtaniver%TYPE;
      vr_dtaniver_util craprac.dtaniver%TYPE;
      vr_exc_saida EXCEPTION; 
      rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
      vr_dslog        VARCHAR2(4000) := '';
      vr_idprglog NUMBER;
    
    CURSOR cr_aplica IS
    select  16   cdcooper,  223697   nrdconta,  40   nraplica, 863.42 vllanmto from dual union all
    select  16   cdcooper,  344915   nrdconta,  91   nraplica, 232.06 vllanmto from dual union all
    select  16   cdcooper,  6015158   nrdconta,  53   nraplica, 901.17 vllanmto from dual union all    
    select  16   cdcooper,  404896   nrdconta,  47   nraplica, 1081.76 vllanmto from dual union all
    select  16   cdcooper,  348724   nrdconta,  48   nraplica, 476.04 vllanmto from dual union all    
    select  9   cdcooper,  250104   nrdconta,  3   nraplica, 1404.92 vllanmto from dual union all        
    select  9   cdcooper,  254703   nrdconta,  39   nraplica, 1389.29 vllanmto from dual union all
    select  9   cdcooper,  369560   nrdconta,  30   nraplica, 271.62 vllanmto from dual union all
    select  9   cdcooper,  379344   nrdconta,  19   nraplica, 270.05 vllanmto from dual union all
    select  9   cdcooper,  388629   nrdconta,  3   nraplica, 2825.58 vllanmto from dual union all
    select  9   cdcooper,  243310   nrdconta,  37   nraplica, 584.68 vllanmto from dual union all
    select  9   cdcooper,  353957   nrdconta,  28   nraplica, 972.79 vllanmto from dual union all    
    select  9  cdcooper,  37346  nrdconta,  136    nraplica, 4460.46 vllanmto from dual;
   rw_aplica cr_aplica%ROWTYPE;
   
  
   
   CURSOR cr_craprac(pr_cdcooper IN craprda.cdcooper%TYPE
                       ,pr_nrdconta IN craprda.nrdconta%TYPE
                       ,pr_nraplica IN craprda.nraplica%TYPE)IS

        SELECT rac.cdcooper
              ,rac.nrdconta
              ,rac.nraplica
              ,rac.vlsldatl
              ,rac.dtatlsld
              ,rac.vlsldant
              ,rac.dtsldant
              ,rac.dtaniver
          FROM craprac rac
         WHERE rac.cdcooper = pr_cdcooper
           AND rac.nrdconta = pr_nrdconta
           AND rac.nraplica = pr_nraplica
           AND rac.idsaqtot = 0;
        rw_craprac cr_craprac%ROWTYPE;
    
 BEGIN    
 
    OPEN btch0001.cr_crapdat(pr_cdcooper => 3);
    FETCH btch0001.cr_crapdat
     INTO rw_crapdat;
    IF btch0001.cr_crapdat%NOTFOUND THEN
      CLOSE btch0001.cr_crapdat;
      vr_dscritic := 1;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_saida;
    ELSE
      CLOSE btch0001.cr_crapdat;
    END IF;
    
    
    FOR rw_aplica IN cr_aplica LOOP           
       
      OPEN cr_craprac(pr_cdcooper => rw_aplica.cdcooper
                       ,pr_nrdconta => rw_aplica.nrdconta
                       ,pr_nraplica => rw_aplica.nraplica);

        FETCH cr_craprac INTO rw_craprac;

        IF cr_craprac%FOUND THEN
          CLOSE cr_craprac;          
        ELSE
          CLOSE cr_craprac;
          CONTINUE;
        END IF;

        vr_dslog := 'UPDATE cecred.crarac SET vlsldatl = '|| REPLACE(rw_craprac.vlsldatl,',','.') ||
                                       ', dtatlsld = '|| rw_craprac.dtatlsld || 
                                       ', vlsldant = '|| REPLACE(rw_craprac.vlsldant,',','.') ||    
                                       ', dtsldant = '|| rw_craprac.dtsldant ||  
                                       ', dtaniver = '|| rw_craprac.dtaniver ||                               
                ' WHERE CDCOOPER = '||rw_craprac.cdcooper ||
                  ' AND NRDCONTA = '||rw_craprac.nrdconta||
                  ' AND NRAPLICA = '||rw_craprac.nraplica||';';

     CECRED.pc_log_programa(pr_dstiplog      => 'O'
                           ,pr_tpocorrencia  => 4 
                           ,pr_cdcriticidade => 0 
                           ,pr_tpexecucao    => 3 
                           ,pr_dsmensagem    => vr_dslog
                           ,pr_cdmensagem    => 111
                           ,pr_cdprograma    => 'INC0235471'
                           ,pr_cdcooper      => 3 
                           ,pr_idprglog      => vr_idprglog);
        
        cecred.APLI0010.pc_processa_lote_aniv(pr_cdcooper => rw_aplica.cdcooper
                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                      ,pr_cdagenci => 1
                                      ,pr_cdbccxlt => 100
                                      ,pr_nrdolote => 85999
                                      ,pr_cdoperad => '1'
                                      ,pr_vllanmto => rw_aplica.vllanmto
                                      ,pr_vllanneg => 0
                                      ,pr_nrseqdig => vr_nrseqdig
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic);
        IF NVL(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
          vr_dscritic := 'Erro criando lote - ' || nvl(vr_dscritic,' ');
          RAISE vr_exc_saida;
        END IF;
     
          BEGIN
            INSERT INTO cecred.craplac(cdcooper
                                      ,dtmvtolt
                                      ,cdagenci
                                      ,cdbccxlt
                                      ,nrdolote
                                      ,nrdconta
                                      ,nraplica
                                      ,nrdocmto
                                      ,nrseqdig
                                      ,vllanmto
                                      ,cdhistor)
                               VALUES(rw_aplica.cdcooper
                                     ,rw_crapdat.dtmvtolt
                                     ,1 
                                     ,100 
                                     ,85999 
                                     ,rw_aplica.nrdconta
                                     ,rw_aplica.nraplica
                                     ,vr_nrseqdig
                                     ,vr_nrseqdig
                                     ,rw_aplica.vllanmto
                                     ,3328);
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir lancamentos(craplac). Detalhes: '||sqlerrm;
            RAISE vr_exc_saida;
          END;

          BEGIN
            UPDATE cecred.craprac 
               SET vlsldatl = vlsldatl +  rw_aplica.vllanmto
                  ,dtatlsld = rw_crapdat.dtmvtolt
                  ,vlsldant = rw_craprac.vlsldatl
                  ,dtsldant = rw_craprac.dtatlsld
                  ,dtaniver = to_date(extract(day from dtmvtolt) || to_char(dtaniver, 'MM/RRRR'),'DD/MM/RRRR')
             WHERE craprac.cdcooper = rw_aplica.cdcooper
               AND craprac.nrdconta = rw_aplica.nrdconta
               AND craprac.nraplica = rw_aplica.nraplica;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar aplicação(craprac). Detalhes: '||SQLERRM;
          RAISE vr_exc_saida;
          END;    
      
      END LOOP;      
   COMMIT;   
    EXCEPTION
      WHEN vr_exc_saida THEN
         vr_dscritic := nvl(vr_dscritic,' ') || 
                        ' - Cooper '|| rw_aplica.cdcooper || ' Conta ' || rw_aplica.nrdconta || ' Aplica ' || rw_aplica.nraplica;
          CECRED.pc_log_programa(pr_dstiplog      => 'O' 
                           ,pr_tpocorrencia  => 4 
                           ,pr_cdcriticidade => 0 
                           ,pr_tpexecucao    => 3 
                           ,pr_dsmensagem    => vr_dscritic
                           ,pr_cdmensagem    => 222
                           ,pr_cdprograma    => 'INC0235471'
                           ,pr_cdcooper      => 3 
                           ,pr_idprglog      => vr_idprglog);
          ROLLBACK;                        
      WHEN OTHERS THEN
         vr_dscritic := 'Erro nao especificado! ' ||
                        nvl(vr_dscritic,' ') || ' - Cooper '|| rw_aplica.cdcooper || ' Conta ' || rw_aplica.nrdconta || ' Aplica ' || rw_aplica.nraplica ||
                        SQLERRM;
         CECRED.pc_log_programa(pr_dstiplog      => 'O' 
                           ,pr_tpocorrencia  => 4 
                           ,pr_cdcriticidade => 0 
                           ,pr_tpexecucao    => 3 
                           ,pr_dsmensagem    => vr_dscritic
                           ,pr_cdmensagem    => 333
                           ,pr_cdprograma    => 'INC0235471'
                           ,pr_cdcooper      => 3 
                           ,pr_idprglog      => vr_idprglog);
          ROLLBACK;
    END;
