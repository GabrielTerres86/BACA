PL/SQL Developer Test script 3.0
239
-- Created on 28/06/2019 by F0030367 
declare 
  vr_contador number;
  vr_dscritic varchar2(500);
  vr_cdcooper pls_integer;
  vr_nrseqdig pls_integer;
  vr_nrdocmto integer;
  vr_excsaida EXCEPTION;  
  vr_laprowid rowid;
  
  cursor cr_aplicacoes is
    select  7  cdcooper,  141445   nrdconta,  2  nraplica,  102  txaplica,  377.23   vlaplica from dual union all
    select  11   cdcooper,  228770   nrdconta,  35   nraplica,  104  txaplica,  15.16  vlaplica from dual union all
    select  1  cdcooper,  2477459  nrdconta,  6  nraplica,  98   txaplica,  14.56  vlaplica from dual union all
    select  5  cdcooper,  4979   nrdconta,  278  nraplica,  97   txaplica,  4.93   vlaplica from dual union all
    select  16   cdcooper,  216828   nrdconta,  1  nraplica,  97   txaplica,  4.5  vlaplica from dual union all
    select  1  cdcooper,  7331045  nrdconta,  23   nraplica,  95   txaplica,  2.94   vlaplica from dual union all
    select  1  cdcooper,  6598234  nrdconta,  6  nraplica,  94   txaplica,  2.53   vlaplica from dual union all
    select  1  cdcooper,  746614   nrdconta,  15   nraplica,  94   txaplica,  1.81   vlaplica from dual union all
    select  13   cdcooper,  179809   nrdconta,  1  nraplica,  95   txaplica,  1.43   vlaplica from dual union all
    select  1  cdcooper,  2848872  nrdconta,  22   nraplica,  94   txaplica,  0.9  vlaplica from dual union all
    select  1  cdcooper,  6450164  nrdconta,  69   nraplica,  94   txaplica,  0.72   vlaplica from dual union all
    select  1  cdcooper,  2632136  nrdconta,  5  nraplica,  94   txaplica,  0.42   vlaplica from dual union all
    select  16   cdcooper,  263788   nrdconta,  3  nraplica,  94   txaplica,  0.45   vlaplica from dual union all
    select  1  cdcooper,  3595110  nrdconta,  38   nraplica,  94   txaplica,  0.33   vlaplica from dual union all
    select  1  cdcooper,  2476304  nrdconta,  37   nraplica,  95   txaplica,  0.21   vlaplica from dual union all
    select  1  cdcooper,  9185070  nrdconta,  6  nraplica,  94   txaplica,  0.18   vlaplica from dual union all
    select  1  cdcooper,  3684202  nrdconta,  18   nraplica,  94   txaplica,  0.13   vlaplica from dual union all
    select  1  cdcooper,  6003850  nrdconta,  49   nraplica,  94   txaplica,  0.12   vlaplica from dual union all
    select  1  cdcooper,  7636610  nrdconta,  52   nraplica,  94   txaplica,  0.13   vlaplica from dual union all
    select  1  cdcooper,  9498877  nrdconta,  2  nraplica,  94   txaplica,  0.08   vlaplica from dual union all
    select  1  cdcooper,  9170472  nrdconta,  20   nraplica,  94   txaplica,  0.08   vlaplica from dual union all    
    select  1  cdcooper,  80578055   nrdconta,  37   nraplica,  94   txaplica,  0.03   vlaplica from dual union all
    select  16 cdcooper,  410357  nrdconta,   2   nraplica,  94   txaplica,  0.00   vlaplica from dual union all
    select  1  cdcooper,  6059325 nrdconta,   10  nraplica,  95   txaplica,  0.00   vlaplica from dual union all
    select  1  cdcooper,  2975971 nrdconta,   14  nraplica,  95   txaplica,  0.00   vlaplica from dual union all
    select  1  cdcooper,  8479917 nrdconta,   28  nraplica,  94   txaplica,  0.00   vlaplica from dual union all
    select  1  cdcooper,  2762277 nrdconta,   68  nraplica,  94   txaplica,  0.00   vlaplica from dual;
  rw_aplicacoes cr_aplicacoes%rowtype;
  
  cursor cr_craprda (pr_cdcooper  IN crapcop.cdcooper%TYPE
                    ,pr_nrdconta  IN craprda.nrdconta%TYPE
                    ,pr_nraplica  IN craprda.nraplica%TYPE) is
  select p.dtvencto,
         p.progress_recid
    from craprda p 
   where p.cdcooper = pr_cdcooper 
     and p.nrdconta = pr_nrdconta
     and p.nraplica = pr_nraplica;
  rw_craprda cr_craprda%rowtype;
  
  CURSOR cr_craplot (pr_cdcooper  IN crapcop.cdcooper%TYPE
                    ,pr_dtmvtolt  IN craplot.dtmvtolt%TYPE) IS
  SELECT lot.*, lot.rowid
    FROM craplot lot
   WHERE lot.cdcooper = pr_cdcooper
     AND lot.dtmvtolt = pr_dtmvtolt
     AND lot.cdagenci = 1
     AND lot.cdbccxlt = 100
     AND lot.nrdolote = 8480;
  rw_craplot cr_craplot%rowtype;   
  
begin
  
  vr_contador:=0;
  :vr_dscritic := '';
  
  FOR rw_aplicacoes IN cr_aplicacoes LOOP
    
    vr_contador:= vr_contador + 1;
    
    if nvl(vr_cdcooper,0) <> rw_aplicacoes.cdcooper then    
      SELECT max(nvl(nrseqdig,0)) vr_nrseqdig into vr_nrseqdig
        FROM craplap
       WHERE cdcooper = rw_aplicacoes.cdcooper
         and dtmvtolt = trunc(sysdate)
         and cdagenci = 1
         and cdbccxlt = 100
         and nrdolote = 8480;
    end if;
    
    -- Coop anterior
    vr_cdcooper:= rw_aplicacoes.cdcooper;
    
    OPEN cr_craprda(rw_aplicacoes.cdcooper, rw_aplicacoes.nrdconta, rw_aplicacoes.nraplica);    
    FETCH cr_craprda INTO rw_craprda;
    
    IF cr_craprda%NOTFOUND THEN
      vr_dscritic := 'craprda nao encontrada!'||
                     ' Cooper: '|| rw_aplicacoes.cdcooper || 
                     ' Conta: ' ||rw_aplicacoes.nrdconta || 
                     ' Aplica: '|| rw_aplicacoes.nraplica;
      RAISE vr_excsaida;
    END IF;

    IF cr_craprda%ISOPEN THEN
      CLOSE cr_craprda;
    END IF;
    
    if rw_aplicacoes.vlaplica > 0 then
    
        vr_nrseqdig := nvl(vr_nrseqdig,0) + 1;
        vr_nrdocmto := 655000 + vr_nrseqdig;    
        
         BEGIN
          insert into craplap (cdagenci, cdbccxlt, dtmvtolt, nrdolote, nrdconta, cdhistor, nraplica, nrdocmto, nrseqdig, vllanmto, txaplica, dtrefere, txaplmes, cdcooper, vlrendmm)
             values
            (1   --cdagenci
            ,100 --cdbccxlt
            ,trunc(sysdate)
            ,8480 --nrdolote 
            ,rw_aplicacoes.nrdconta
            ,529 -- RDC POS
            ,rw_aplicacoes.nraplica
            ,vr_nrdocmto
            ,vr_nrseqdig
            ,rw_aplicacoes.vlaplica
            ,rw_aplicacoes.txaplica
            ,rw_craprda.dtvencto -- dtrefere
            ,rw_aplicacoes.txaplica
            ,rw_aplicacoes.cdcooper
            ,rw_aplicacoes.vlaplica) returning rowid into vr_laprowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro inserindo craplap! '|| SQLERRM ||
                           ' - Cooper: '|| rw_aplicacoes.cdcooper || 
                           ' Conta: ' ||rw_aplicacoes.nrdconta || 
                           ' Aplica: '|| rw_aplicacoes.nraplica;
           RAISE vr_excsaida;
        END;
        
        dbms_output.put_line('delete from craplap where rowid = '''|| vr_laprowid ||''';');
        
        BEGIN
          UPDATE craprda
             SET vlsltxmx = vlsltxmx + rw_aplicacoes.vlaplica
                ,vlsltxmm = vlsltxmm + rw_aplicacoes.vlaplica
           WHERE progress_recid = rw_craprda.progress_recid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro alterando craprda! '|| SQLERRM ||
                           ' - Cooper: '|| rw_aplicacoes.cdcooper || 
                           ' Conta: ' ||rw_aplicacoes.nrdconta || 
                           ' Aplica: '|| rw_aplicacoes.nraplica;
            RAISE vr_excsaida;
        END;
        
        OPEN cr_craplot(pr_cdcooper => rw_aplicacoes.cdcooper
                       ,pr_dtmvtolt => trunc(sysdate));
        FETCH cr_craplot INTO rw_craplot;
        IF cr_craplot%NOTFOUND THEN
          CLOSE cr_craplot;
          
          BEGIN
            INSERT INTO craplot(cdcooper
                               ,dtmvtolt
                               ,cdagenci
                               ,cdbccxlt
                               ,nrdolote
                               ,tplotmov
                               ,vlinfodb
                               ,vlcompdb
                               ,qtinfoln
                               ,qtcompln
                               ,vlinfocr
                               ,vlcompcr)
                         VALUES(rw_aplicacoes.cdcooper
                               ,trunc(sysdate)
                               ,1
                               ,100
                               ,8480
                               ,9
                               ,0
                               ,0
                               ,0
                               ,0
                               ,0
                               ,0)
                       RETURNING cdagenci
                                ,cdbccxlt
                                ,nrdolote
                                ,tplotmov
                                ,nrseqdig
                                ,rowid
                            INTO rw_craplot.cdagenci
                                ,rw_craplot.cdbccxlt
                                ,rw_craplot.nrdolote
                                ,rw_craplot.tplotmov
                                ,rw_craplot.nrseqdig
                                ,rw_craplot.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              -- Gerar erro e fazer rollback
              vr_dscritic := 'Erro inserindo craplot! '|| SQLERRM;
              RAISE vr_excsaida;
          END;
        ELSE
          CLOSE cr_craplot;
        END IF;  
        
        BEGIN          
          UPDATE craplot ct
            SET ct.vlinfocr = NVL(ct.vlinfocr,0) + rw_aplicacoes.vlaplica
               ,ct.vlcompcr = NVL(ct.vlcompcr,0) + rw_aplicacoes.vlaplica
               ,ct.qtinfoln = NVL(ct.qtinfoln,0) + (vr_nrseqdig -  NVL(ct.nrseqdig,0))
               ,ct.qtcompln = NVL(ct.qtcompln,0) + (vr_nrseqdig -  NVL(ct.nrseqdig,0))
               ,ct.nrseqdig = NVL(ct.nrseqdig,0) + vr_nrseqdig
            WHERE ct.ROWID = rw_craplot.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro alterando craplot! '|| SQLERRM;
            RAISE vr_excsaida;
        END;
    end if;
    
    -- Atualizar taxas das aplicacoes
    BEGIN
      update craplap p
         set p.txaplica = rw_aplicacoes.txaplica
            ,p.txaplmes = rw_aplicacoes.txaplica
       WHERE p.cdcooper = rw_aplicacoes.cdcooper
         AND p.nrdconta = rw_aplicacoes.nrdconta
         AND p.nraplica = rw_aplicacoes.nraplica;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro alterando craplap! '|| SQLERRM;        
        RAISE vr_excsaida;
    END;
    
  END LOOP;
  
  commit;
  
  :vr_dscritic := 'SUCESSO -> Registros atualizados: '|| vr_contador;
EXCEPTION
  WHEN vr_excsaida then 
    :vr_dscritic := 'ERRO ' || vr_dscritic;
    rollback;
end;
1
vr_dscritic
1
SUCESSO -> Registros atualizados: 5
5
0
