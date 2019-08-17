PL/SQL Developer Test script 3.0
270
declare 
  vr_contador number; -- Contador
  vr_dscritic varchar2(500);
  vr_cdcooper pls_integer;
  vr_nrseqdig pls_integer;
  vr_nrdocmto integer;
  vr_excsaida EXCEPTION;  
  vr_laprowid rowid;
  
  cursor cr_aplicacoes is
  select  11  cdcooper, 228770  nrdconta, 45  nraplica, 104 txaplica, 6.59  vlaplica from dual union all
  select  1 cdcooper, 3686400 nrdconta, 229 nraplica, 108   txaplica, 5.04  vlaplica from dual union all
  select  1 cdcooper, 2559650 nrdconta, 21  nraplica, 97    txaplica, 1.33  vlaplica from dual union all
  select  16  cdcooper, 2130750 nrdconta, 21  nraplica, 99  txaplica, 0.54  vlaplica from dual union all
  select  1 cdcooper, 9615997 nrdconta, 37  nraplica, 96    txaplica, 0.51  vlaplica from dual union all
  select  1 cdcooper, 8351279 nrdconta, 70  nraplica, 96    txaplica, 0.47  vlaplica from dual union all
  select  16  cdcooper, 293202  nrdconta, 11  nraplica, 94  txaplica, 0.43  vlaplica from dual union all
  select  1 cdcooper, 4081005 nrdconta, 37  nraplica, 99    txaplica, 0.32  vlaplica from dual union all
  select  1 cdcooper, 3553450 nrdconta, 64  nraplica, 97    txaplica, 0.27  vlaplica from dual union all
  select  16  cdcooper, 2230330 nrdconta, 23  nraplica, 100 txaplica, 0.25  vlaplica from dual union all
  select  1 cdcooper, 10181725  nrdconta, 9 nraplica, 96    txaplica, 0.24  vlaplica from dual union all
  select  1 cdcooper, 820113  nrdconta, 317 nraplica, 103   txaplica, 0.21  vlaplica from dual union all
  select  1 cdcooper, 6013724 nrdconta, 63  nraplica, 101   txaplica, 0.15  vlaplica from dual union all
  select  16  cdcooper, 2473542 nrdconta, 27  nraplica, 94  txaplica, 0.14  vlaplica from dual union all
  select  1 cdcooper, 6176470 nrdconta, 95  nraplica, 97    txaplica, 0.12  vlaplica from dual union all
  select  1 cdcooper, 3553450 nrdconta, 65  nraplica, 97    txaplica, 0.10  vlaplica from dual union all
  select  1 cdcooper, 4014162 nrdconta, 48  nraplica, 101   txaplica, 0.08  vlaplica from dual union all
  select  1 cdcooper, 2960427 nrdconta, 24  nraplica, 97    txaplica, 0.08  vlaplica from dual union all
  select  1 cdcooper, 80470084  nrdconta, 17  nraplica, 94  txaplica, 0.08  vlaplica from dual union all
  select  16  cdcooper, 88803 nrdconta, 62  nraplica, 94    txaplica, 0.06  vlaplica from dual union all
  select  1 cdcooper, 2295300 nrdconta, 123 nraplica, 96    txaplica, 0.05  vlaplica from dual union all
  select  1 cdcooper, 8115109 nrdconta, 46  nraplica, 97    txaplica, 0.04  vlaplica from dual union all
  select  1 cdcooper, 7545401 nrdconta, 66  nraplica, 95    txaplica, 0.04  vlaplica from dual union all
  select  1 cdcooper, 1504576 nrdconta, 35  nraplica, 95    txaplica, 0.04  vlaplica from dual union all
  select  1 cdcooper, 3830870 nrdconta, 27  nraplica, 96    txaplica, 0.03  vlaplica from dual union all
  select  1 cdcooper, 6300960 nrdconta, 71  nraplica, 94    txaplica, 0.03  vlaplica from dual union all
  select  1 cdcooper, 7167504 nrdconta, 170 nraplica, 95    txaplica, 0.03  vlaplica from dual union all
  select  16  cdcooper, 242241  nrdconta, 13  nraplica, 97  txaplica, 0.03  vlaplica from dual union all
  select  1 cdcooper, 9237542 nrdconta, 10  nraplica, 94    txaplica, 0.02  vlaplica from dual union all
  select  1 cdcooper, 6156053 nrdconta, 18  nraplica, 94    txaplica, 0.02  vlaplica from dual union all
  select  1 cdcooper, 9195769 nrdconta, 33  nraplica, 94    txaplica, 0.01  vlaplica from dual union all
  select  1 cdcooper, 9069771 nrdconta, 18  nraplica, 94    txaplica, 0.01  vlaplica from dual union all
  select  1 cdcooper, 2566044 nrdconta, 50  nraplica, 94    txaplica, 0.01  vlaplica from dual union all
  select  1 cdcooper, 8572119 nrdconta, 154 nraplica, 95    txaplica, 0.01  vlaplica from dual union all
  select  1 cdcooper, 9662227 nrdconta, 67  nraplica, 94    txaplica, 0.01  vlaplica from dual union all
  select  16  cdcooper, 6734154 nrdconta, 27  nraplica, 94  txaplica, 0.01  vlaplica from dual union all
  select  16  cdcooper, 139351  nrdconta, 11  nraplica, 94  txaplica, 0.01  vlaplica from dual union all
  select  1 cdcooper, 6372457 nrdconta, 12  nraplica, 94    txaplica, 0.00  vlaplica from dual union all
  select  1 cdcooper, 8483540 nrdconta, 53  nraplica, 94    txaplica, 0.00  vlaplica from dual union all
  select  1 cdcooper, 8532710 nrdconta, 10  nraplica, 94    txaplica, 0.00  vlaplica from dual union all
  select  1 cdcooper, 7970137 nrdconta, 8 nraplica, 94      txaplica, 0.00  vlaplica from dual union all
  select  1 cdcooper, 2909502 nrdconta, 44  nraplica, 94    txaplica, 0.00  vlaplica from dual union all
  select  1 cdcooper, 6950191 nrdconta, 15  nraplica, 94    txaplica, 0.00  vlaplica from dual union all
  select  1 cdcooper, 9902619 nrdconta, 21  nraplica, 94    txaplica, 0.00  vlaplica from dual union all
  select  1 cdcooper, 9075801 nrdconta, 13  nraplica, 94    txaplica, 0.00  vlaplica from dual union all
  select  1 cdcooper, 3894886 nrdconta, 9 nraplica, 94      txaplica, 0.00  vlaplica from dual union all
  select  1 cdcooper, 2051001 nrdconta, 4 nraplica, 94      txaplica, 0.00  vlaplica from dual union all
  select  1 cdcooper, 9333940 nrdconta, 22  nraplica, 97    txaplica, 0.00  vlaplica from dual union all
  select  1 cdcooper, 3663051 nrdconta, 133 nraplica, 96    txaplica, 0.00  vlaplica from dual union all
  select  1 cdcooper, 80369740  nrdconta, 10  nraplica, 94  txaplica, 0.00  vlaplica from dual union all
  select  1 cdcooper, 6298362 nrdconta, 53  nraplica, 95    txaplica, 0.00  vlaplica from dual union all
  select  1 cdcooper, 876070  nrdconta, 96  nraplica, 94    txaplica, 0.00  vlaplica from dual union all
  select  1 cdcooper, 6293980 nrdconta, 95  nraplica, 95    txaplica, 0.00  vlaplica from dual union all
  select  1 cdcooper, 9437975 nrdconta, 18  nraplica, 94    txaplica, 0.00  vlaplica from dual union all
  select  1 cdcooper, 3829766 nrdconta, 80  nraplica, 94    txaplica, 0.00  vlaplica from dual union all
  select  16  cdcooper, 385212  nrdconta, 14  nraplica, 94  txaplica, 0.00  vlaplica from dual union all
  select  16  cdcooper, 40894 nrdconta, 53  nraplica, 94    txaplica, 0.00  vlaplica from dual;
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
      close cr_craprda;
      vr_dscritic := 'craprda nao encontrada!'||
                     ' Cooper: '|| rw_aplicacoes.cdcooper || 
                     ' Conta: ' ||rw_aplicacoes.nrdconta || 
                     ' Aplica: '|| rw_aplicacoes.nraplica;
      dbms_output.put_line(vr_dscritic);
      continue;
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
SUCESSO -> Registros atualizados: 57
5
0
