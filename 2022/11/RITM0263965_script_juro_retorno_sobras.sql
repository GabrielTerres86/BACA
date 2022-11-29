declare
  --
  vr_nrregistro number := 0;
  vr_registro_ok NUMBER; -- 0-não ok
  vr_nrdconta NUMBER(15);
  vr_cdcooper  NUMBER(8);

  vr_dsmensagem CLOB;

  
  ----
  
    -- Selecionar Moedas
  CURSOR cr_crapmfx (pr_cdcooper IN crapmfx.cdcooper%TYPE
                    ,pr_dtmvtolt IN crapmfx.dtmvtolt%TYPE
                    ,pr_tpmoefix IN crapmfx.tpmoefix%TYPE) IS
    SELECT crapmfx.cdcooper
          ,crapmfx.vlmoefix
      FROM crapmfx
     WHERE crapmfx.cdcooper = pr_cdcooper
       AND crapmfx.dtmvtolt = pr_dtmvtolt
       AND crapmfx.tpmoefix = pr_tpmoefix;
  rw_crapmfx cr_crapmfx%ROWTYPE;
  
BEGIN
  BEGIN
    vr_dsmensagem := null;
          --
    for r_cnt in (
        select cnt.contrato
              ,cnt.valor
        from
        (
select 4924277  contrato, 13453.95 valor from dual union all
select 4997509  contrato, 10828.64 valor from dual union all
select 4763764  contrato, 10853.81 valor from dual union all
select 366856 contrato, 9063.30  valor from dual union all
select 4829600  contrato, 7819.55  valor from dual union all
select 4953412  contrato, 10028.14 valor from dual union all
select 4876649  contrato, 17100.26 valor from dual union all
select 4988515  contrato, 22544.27 valor from dual union all
select 4950308  contrato, 16523.82 valor from dual union all
select 4680967  contrato, 10009.22 valor from dual union all
select 421162 contrato, 8279.66  valor from dual union all
select 5121637  contrato, 10611.45 valor from dual union all
select 427288 contrato, 4250.15  valor from dual union all
select 5256561  contrato, 8124.67  valor from dual union all
select 5168086  contrato, 7606.89  valor from dual union all
select 5232509  contrato, 8178.43  valor from dual union all
select 5256845  contrato, 10718.08 valor from dual union all
select 5324025  contrato, 17898.52 valor from dual union all
select 5174910  contrato, 3369.01  valor from dual union all
select 5175515  contrato, 12101.02 valor from dual union all
select 5250023  contrato, 16481.18 valor from dual union all
select 5199534  contrato, 8832.93  valor from dual union all
select 5194709  contrato, 5898.36  valor from dual union all
select 5248773  contrato, 6685.53  valor from dual union all
select 5222733  contrato, 9436.00  valor from dual union all
select 5188424  contrato, 6145.43  valor from dual union all
select 5202038  contrato, 3705.74  valor from dual union all
select 5378957  contrato, 7191.27  valor from dual union all
select 5214687  contrato, 9759.43  valor from dual union all
select 5217085  contrato, 1279.83  valor from dual union all
select 5223304  contrato, 13448.84 valor from dual union all
select 5248898  contrato, 5732.02  valor from dual union all
select 5042871  contrato, 4074.96  valor from dual union all
select 5220477  contrato, 6640.80  valor from dual union all
select 446227 contrato, 3613.19  valor from dual union all
select 5323088  contrato, 3860.61  valor from dual union all
select 5367487  contrato, 3741.47  valor from dual union all
select 5194766  contrato, 13404.86 valor from dual union all
select 5251718  contrato, 13430.42 valor from dual union all
select 5283222  contrato, 5624.04  valor from dual union all
select 429318 contrato, 6035.68  valor from dual union all
select 429471 contrato, 3942.61  valor from dual union all
select 5190131  contrato, 10959.06 valor from dual union all
select 5290168  contrato, 5447.71  valor from dual union all
select 5384375  contrato, 6936.34  valor from dual union all
select 451906 contrato, 4398.86  valor from dual union all
select 5238716  contrato, 5369.27  valor from dual union all
select 5311717  contrato, 14069.30 valor from dual union all
select 5254819  contrato, 3338.75  valor from dual union all
select 5285287  contrato, 9055.06  valor from dual union all
select 5256268  contrato, 2109.90  valor from dual union all
select 5226829  contrato, 4828.75  valor from dual union all
select 5299786  contrato, 13287.57 valor from dual union all
select 455508 contrato, 4079.03  valor from dual union all
select 5285429  contrato, 4728.54  valor from dual union all
select 5290956  contrato, 6994.05  valor from dual union all
select 5379957  contrato, 6686.21  valor from dual union all
select 5306042  contrato, 3761.19  valor from dual union all
select 5355069  contrato, 8059.12  valor from dual union all
select 5232869  contrato, 4166.38  valor from dual union all
select 5303768  contrato, 4497.38  valor from dual union all
select 5322577  contrato, 3832.97  valor from dual union all
select 5344909  contrato, 5949.49  valor from dual union all
select 5266989  contrato, 6740.69  valor from dual union all
select 5335534  contrato, 4840.56  valor from dual union all
select 5442908  contrato, 1839.12  valor from dual union all
select 428971 contrato, 12982.55 valor from dual union all
select 5321450  contrato, 10932.91 valor from dual union all
select 5326980  contrato, 6237.24  valor from dual union all
select 5325069  contrato, 1998.22  valor from dual union all
select 5384851  contrato, 5392.60  valor from dual union all
select 455021 contrato, 6619.02  valor from dual union all
select 5419912  contrato, 4985.61  valor from dual union all
select 5430760  contrato, 4334.71  valor from dual union all
select 5287899  contrato, 8593.68  valor from dual union all
select 5263432  contrato, 3423.62  valor from dual union all
select 5246540  contrato, 7763.20  valor from dual union all
select 5389453  contrato, 9392.24  valor from dual union all
select 5326820  contrato, 7234.92  valor from dual union all
select 451245 contrato, 2698.11  valor from dual union all
select 5355988  contrato, 6845.27  valor from dual union all
select 5298941  contrato, 5167.33  valor from dual union all
select 5351571  contrato, 4040.82  valor from dual union all
select 442089 contrato, 10758.64 valor from dual union all
select 5232566  contrato, 5819.35  valor from dual union all
select 450535 contrato, 4958.99  valor from dual union all
select 5544745  contrato, 7021.79  valor from dual union all
select 438732 contrato, 3443.99  valor from dual union all
select 5373344  contrato, 13846.28 valor from dual union all
select 5376031  contrato, 5938.09  valor from dual union all
select 5374600  contrato, 5254.49  valor from dual union all
select 5473308  contrato, 3264.81  valor from dual union all
select 5378133  contrato, 2694.63  valor from dual union all
select 5347355  contrato, 5524.00  valor from dual union all
select 5341719  contrato, 10769.61 valor from dual union all
select 5309516  contrato, 5103.61  valor from dual union all
select 5251378  contrato, 3147.19  valor from dual union all
select 470770 contrato, 7710.42  valor from dual union all
select 5449484  contrato, 7326.83  valor from dual union all
select 5370104  contrato, 7286.54  valor from dual union all
select 5367303  contrato, 7779.62  valor from dual union all
select 5235513  contrato, 16157.65 valor from dual union all
select 5298892  contrato, 6983.72  valor from dual union all
select 5382510  contrato, 4624.44  valor from dual union all
select 463498 contrato, 5159.60  valor from dual union all
select 5356590  contrato, 4432.28  valor from dual union all
select 5283623  contrato, 5545.58  valor from dual union all
select 5233903  contrato, 5388.06  valor from dual union all
select 5383631  contrato, 18742.64 valor from dual union all
select 5409870  contrato, 4270.51  valor from dual union all
select 5427200  contrato, 6984.93  valor from dual union all
select 5413494  contrato, 4429.95  valor from dual union all
select 5408836  contrato, 12439.88 valor from dual union all
select 466660 contrato, 6949.17  valor from dual union all
select 5382534  contrato, 1484.49  valor from dual union all
select 5265068  contrato, 5198.57  valor from dual union all
select 5164570  contrato, 2435.87  valor from dual union all
select 5334790  contrato, 5707.04  valor from dual union all
select 443168 contrato, 3031.25  valor from dual union all
select 5320090  contrato, 7084.35  valor from dual union all
select 5283617  contrato, 7510.14  valor from dual union all
select 5289996  contrato, 11193.25 valor from dual union all
select 5409441  contrato, 4121.41  valor from dual union all
select 5412586  contrato, 4367.62  valor from dual union all
select 5419273  contrato, 9074.48  valor from dual union all
select 5427492  contrato, 6355.82  valor from dual union all
select 5480783  contrato, 4318.41  valor from dual union all
select 5483342  contrato, 7943.41  valor from dual union all
select 5452071  contrato, 4285.00  valor from dual union all
select 5264308  contrato, 4443.43  valor from dual union all
select 5404218  contrato, 3646.72  valor from dual union all
select 458099 contrato, 5414.86  valor from dual union all
select 5503564  contrato, 5684.73  valor from dual union all
select 468396 contrato, 4073.00  valor from dual union all
select 5353059  contrato, 7952.97  valor from dual union all
select 5479785  contrato, 3433.21  valor from dual union all
select 5395249  contrato, 3439.31  valor from dual union all
select 5378365  contrato, 4572.58  valor from dual union all
select 5419048  contrato, 1316.96  valor from dual union all
select 5346386  contrato, 3474.95  valor from dual union all
select 5491504  contrato, 14804.94 valor from dual union all
select 5457973  contrato, 4224.00  valor from dual union all
select 5238554  contrato, 3162.53  valor from dual union all
select 5338360  contrato, 5994.01  valor from dual union all
select 5575671  contrato, 4831.84  valor from dual union all
select 5478641  contrato, 4653.01  valor from dual union all
select 5397355  contrato, 3542.19  valor from dual union all
select 5534269  contrato, 4298.47  valor from dual union all
select 5306818  contrato, 3842.87  valor from dual union all
select 5319760  contrato, 3319.04  valor from dual union all
select 5574002  contrato, 6788.22  valor from dual union all
select 5478304  contrato, 4285.72  valor from dual union all
select 5504016  contrato, 3646.86  valor from dual union all
select 5256189  contrato, 2238.92  valor from dual union all
select 474151 contrato, 13415.14 valor from dual union all
select 5467795  contrato, 4120.16  valor from dual union all
select 441571 contrato, 6431.63  valor from dual union all
select 5461851  contrato, 1069.76  valor from dual union all
select 5411293  contrato, 2001.28  valor from dual union all
select 5614067  contrato, 3372.75  valor from dual union all
select 5478745  contrato, 4836.53  valor from dual union all
select 5486661  contrato, 7722.98  valor from dual union all
select 5505701  contrato, 3217.91  valor from dual union all
select 5557449  contrato, 4636.46  valor from dual union all
select 5597505  contrato, 16121.52 valor from dual union all
select 5466996  contrato, 10622.61 valor from dual union all
select 5356515  contrato, 3811.04  valor from dual union all
select 5420102  contrato, 8691.23  valor from dual union all
select 478566 contrato, 8601.46  valor from dual union all
select 5300053  contrato, 8465.14  valor from dual union all
select 5253381  contrato, 3793.17  valor from dual union all
select 5381528  contrato, 4907.19  valor from dual union all
select 5518631  contrato, 5361.59  valor from dual union all
select 5370143  contrato, 1711.64  valor from dual union all
select 5606405  contrato, 5882.44  valor from dual union all
select 5518243  contrato, 3869.83  valor from dual union all
select 5384148  contrato, 4033.04  valor from dual union all
select 5522572  contrato, 3750.34  valor from dual union all
select 5457833  contrato, 3978.20  valor from dual union all
select 5480501  contrato, 1920.32  valor from dual union all
select 5614635  contrato, 4012.06  valor from dual union all
select 441027 contrato, 4064.11  valor from dual union all
select 5576137  contrato, 6018.73  valor from dual union all
select 5634904  contrato, 7800.46  valor from dual union all
select 5448119  contrato, 4824.13  valor from dual union all
select 5555534  contrato, 3668.23  valor from dual union all
select 462538 contrato, 6676.75  valor from dual union all
select 5622307  contrato, 5827.54  valor from dual union all
select 5494002  contrato, 10616.35 valor from dual union all
select 5498288  contrato, 2143.84  valor from dual union all
select 5501018  contrato, 3147.23  valor from dual union all
select 5392950  contrato, 1931.80  valor from dual union all
select 5520879  contrato, 1715.72  valor from dual union all
select 5563035  contrato, 3576.91  valor from dual union all
select 5606855  contrato, 2625.02  valor from dual union all
select 5587144  contrato, 3440.38  valor from dual union all
select 5520604  contrato, 3760.19  valor from dual union all
select 5597289  contrato, 3118.22  valor from dual union all
select 5535730  contrato, 5801.50  valor from dual union all
select 5567055  contrato, 4606.22  valor from dual union all
select 5447865  contrato, 2750.65  valor from dual union all
select 5520289  contrato, 3425.59  valor from dual union all
select 5631925  contrato, 1804.31  valor from dual union all
select 5625476  contrato, 7581.46  valor from dual union all
select 5612677  contrato, 2508.12  valor from dual union all
select 5535110  contrato, 1143.07  valor from dual union all
select 5656124  contrato, 2250.44  valor from dual union all
select 478498 contrato, 4608.12  valor from dual union all
select 5255962  contrato, 2366.46  valor from dual union all
select 5650783  contrato, 3925.97  valor from dual union all
select 492201 contrato, 5168.93  valor from dual union all
select 5457882  contrato, 2148.72  valor from dual union all
select 5483698  contrato, 2962.01  valor from dual union all
select 5622192  contrato, 2867.57  valor from dual union all
select 5490427  contrato, 5891.31  valor from dual union all
select 5665885  contrato, 2894.94  valor from dual union all
select 5535012  contrato, 2797.93  valor from dual union all
select 5575144  contrato, 2359.16  valor from dual union all
select 492585 contrato, 2296.64  valor from dual union all
select 5599317  contrato, 3776.48  valor from dual union all
select 492206 contrato, 916.62   valor from dual union all
select 5608744  contrato, 2979.29  valor from dual union all
select 5582049  contrato, 2819.03  valor from dual union all
select 5567195  contrato, 1902.93  valor from dual union all
select 5413205  contrato, 5009.99  valor from dual union all
select 5601632  contrato, 12710.80 valor from dual union all
select 485766 contrato, 5072.19  valor from dual union all
select 5622383  contrato, 4291.68  valor from dual union all
select 5299578  contrato, 1722.70  valor from dual union all
select 480901 contrato, 2152.33  valor from dual union all
select 5625256  contrato, 6132.33  valor from dual union all
select 5573999  contrato, 2721.32  valor from dual union all
select 5649793  contrato, 1541.60  valor from dual union all
select 5606047  contrato, 2575.02  valor from dual union all
select 5338434  contrato, 7526.96  valor from dual union all
select 5414742  contrato, 4739.58  valor from dual union all
select 446132 contrato, 2460.54  valor from dual union all
select 5524577  contrato, 2138.67  valor from dual union all
select 5568655  contrato, 5663.92  valor from dual union all
select 5622630  contrato, 3535.93  valor from dual union all
select 5619058  contrato, 4258.10  valor from dual union all
select 5586452  contrato, 1361.23  valor from dual union all
select 5400602  contrato, 4950.23  valor from dual union all
select 5538256  contrato, 5013.63  valor from dual union all
select 5438429  contrato, 1859.18  valor from dual union all
select 495406 contrato, 1188.85  valor from dual union all
select 482769 contrato, 1797.20  valor from dual union all
select 481125 contrato, 3082.68  valor from dual union all
select 5486830  contrato, 1624.57  valor from dual union all
select 5505539  contrato, 3548.29  valor from dual union all
select 481245 contrato, 2312.54  valor from dual union all
select 5503549  contrato, 2003.31  valor from dual union all
select 479450 contrato, 4578.08  valor from dual union all
select 5421589  contrato, 11300.71 valor from dual union all
select 5634203  contrato, 6425.61  valor from dual union all
select 5410675  contrato, 5775.88  valor from dual union all
select 487598 contrato, 1947.43  valor from dual union all
select 5443169  contrato, 1895.57  valor from dual union all
select 5642144  contrato, 3580.53  valor from dual union all
select 5647234  contrato, 2861.37  valor from dual union all
select 5652123  contrato, 3436.45  valor from dual union all
select 5674728  contrato, 5438.06  valor from dual union all
select 5683539  contrato, 1595.42  valor from dual union all
select 5685400  contrato, 4636.90  valor from dual union all
select 504732 contrato, 4587.39  valor from dual union all
select 5441436  contrato, 1400.62  valor from dual union all
select 5608325  contrato, 10299.59 valor from dual union all
select 5707348  contrato, 3525.95  valor from dual union all
select 465892 contrato, 1716.57  valor from dual union all
select 5614173  contrato, 2862.93  valor from dual union all
select 5499661  contrato, 4010.86  valor from dual union all
select 487604 contrato, 2387.24  valor from dual union all
select 5615745  contrato, 3577.55  valor from dual union all
select 5649681  contrato, 3261.86  valor from dual union all
select 5569303  contrato, 1759.57  valor from dual union all
select 5651762  contrato, 1223.45  valor from dual union all
select 5581005  contrato, 4060.72  valor from dual union all
select 484307 contrato, 2141.30  valor from dual union all
select 5625211  contrato, 3499.64  valor from dual union all
select 5692879  contrato, 2662.66  valor from dual union all
select 5391252  contrato, 836.63   valor from dual union all
select 5677667  contrato, 4833.56  valor from dual union all
select 5633684  contrato, 1182.26  valor from dual union all
select 5611124  contrato, 3397.94  valor from dual union all
select 5778088  contrato, 3148.61  valor from dual union all
select 5534514  contrato, 1407.34  valor from dual union all
select 5552313  contrato, 1159.52  valor from dual union all
select 449320 contrato, 752.73   valor from dual union all
select 5654003  contrato, 1352.77  valor from dual union all
select 5491741  contrato, 930.23   valor from dual union all
select 5656019  contrato, 2146.68  valor from dual union all
select 5481532  contrato, 1287.47  valor from dual union all
select 5498243  contrato, 1189.66  valor from dual union all
select 5592233  contrato, 1674.47  valor from dual union all
select 5406422  contrato, 858.95   valor from dual union all
select 5697072  contrato, 400.31   valor from dual union all
select 481031 contrato, 1229.37  valor from dual union all
select 5542443  contrato, 1517.89  valor from dual union all
select 5540463  contrato, 2505.96  valor from dual union all
select 5649194  contrato, 2719.68  valor from dual union all
select 5710661  contrato, 913.49   valor from dual union all
select 5634490  contrato, 1216.90  valor from dual union all
select 451199 contrato, 1269.47  valor from dual union all
select 5656317  contrato, 1145.25  valor from dual union all
select 5427135  contrato, 1097.49  valor from dual union all
select 5593375  contrato, 3090.60  valor from dual union all
select 5631977  contrato, 2122.19  valor from dual union all
select 5452357  contrato, 1638.52  valor from dual union all
select 5702814  contrato, 1080.23  valor from dual union all
select 5545962  contrato, 2146.17  valor from dual union all
select 5654443  contrato, 715.39   valor from dual union all
select 5679722  contrato, 1704.85  valor from dual union all
select 5514833  contrato, 3703.53  valor from dual union all
select 5637835  contrato, 2181.47  valor from dual union all
select 5524393  contrato, 3720.80  valor from dual union all
select 5581536  contrato, 1636.46  valor from dual union all
select 5542970  contrato, 3799.51  valor from dual union all
select 474776 contrato, 991.02   valor from dual union all
select 5674890  contrato, 1385.01  valor from dual union all
select 5743440  contrato, 1600.68  valor from dual union all
select 5597296  contrato, 1706.10  valor from dual union all
select 5633288  contrato, 894.18   valor from dual union all
select 512572 contrato, 936.14   valor from dual union all
select 5788482  contrato, 904.62   valor from dual union all
select 5545640  contrato, 1488.05  valor from dual union all
select 5443434  contrato, 1532.74  valor from dual union all
select 5742561  contrato, 774.28   valor from dual union all
select 5563046  contrato, 1789.01  valor from dual union all
select 5662306  contrato, 780.40   valor from dual union all
select 5751388  contrato, 1873.44  valor from dual union all
select 5781994  contrato, 1619.99  valor from dual union all
select 5651237  contrato, 3256.88  valor from dual union all
select 5837244  contrato, 2017.55  valor from dual union all
select 516019 contrato, 2044.73  valor from dual union all
select 5285081  contrato, 1341.97  valor from dual union all
select 5696078  contrato, 1248.58  valor from dual union all
select 5646929  contrato, 855.08   valor from dual union all
select 5887850  contrato, 2400.24  valor from dual union all
select 5789356  contrato, 2232.22  valor from dual union all
select 5753424  contrato, 1492.35  valor from dual union all
select 5902748  contrato, 1005.62  valor from dual union all
select 5845284  contrato, 1082.27  valor from dual union all
select 5438922  contrato, 1433.38  valor from dual union all
select 5808399  contrato, 1036.87  valor from dual union all
select 5648086  contrato, 1120.51  valor from dual union all
select 5805341  contrato, 2688.42  valor from dual union all
select 5591660  contrato, 1596.59  valor from dual union all
select 5826725  contrato, 1663.21  valor from dual union all
select 5641985  contrato, 3394.89  valor from dual union all
select 5474607  contrato, 1082.20  valor from dual union all
select 5613813  contrato, 2394.34  valor from dual union all
select 5595719  contrato, 1607.78  valor from dual union all
select 5838795  contrato, 1504.01  valor from dual union all
select 5399567  contrato, 941.02   valor from dual union all
select 5783036  contrato, 1598.47  valor from dual union all
select 461499 contrato, 3358.30  valor from dual union all
select 5654915  contrato, 1554.49  valor from dual 
   
        ) cnt
                       )
          loop
            --
            vr_nrregistro := vr_nrregistro + 1;
            vr_cdcooper := 0; 
            vr_nrdconta := 0;
            vr_registro_ok := 1;
            --
            begin
              --
              select imo.cdcooper,imo.nrdconta
                INTO  vr_cdcooper ,vr_nrdconta
              from credito.tbepr_contrato_imobiliario imo
              where imo.nrctremp = r_cnt.contrato;
              --
            exception
              when others then
                vr_dsmensagem :=  vr_dsmensagem||'Contrato nao encontrado: '||r_cnt.contrato||
                                             chr(13);
              vr_registro_ok:= 0;

            end;
            --

            if vr_registro_ok =1 then
              --
              -- Selecionar Valor Moeda
              OPEN cr_crapmfx (pr_cdcooper => vr_cdcooper
                              ,pr_dtmvtolt => '31/10/2022'--rw_crapdat.dtmvtolt
                              ,pr_tpmoefix => 2);
              FETCH cr_crapmfx INTO rw_crapmfx;
              --Se nao encontrou
              IF cr_crapmfx%NOTFOUND THEN

                  vr_dsmensagem :=  vr_dsmensagem|| gene0001.fn_busca_critica(pr_cdcritic => 140)||' da UFIR.'
                                             ||chr(13);
                vr_registro_ok:= 0;                                             
              END IF;
              CLOSE cr_crapmfx;

              IF NVL(r_cnt.valor,0) > 0 AND vr_registro_ok = 1 THEN
                BEGIN
                  UPDATE crapcot 
                     SET crapcot.qtjurmfx = NVL(crapcot.qtjurmfx,0) + ROUND(r_cnt.valor / rw_crapmfx.vlmoefix,4)
                   WHERE crapcot.cdcooper = vr_cdcooper
                     AND crapcot.nrdconta = vr_nrdconta;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dsmensagem := vr_dsmensagem||'Erro ao atualizar tabela crapcot. Coop: '||vr_cdcooper
                      ||' Conta: '||vr_nrdconta||' Contrato: '||r_cnt.contrato||' erro: '|| SQLERRM
                      ||chr(13);
                END;
              END IF;   
            END IF; -- do contrato  

          end loop;
          --
          IF vr_dsmensagem IS NOT NULL THEN
            dbms_output.put_line('Nenhum registro foi atualizado, pois foram encontrados Erros: '||vr_dsmensagem);                        
            ROLLBACK;
          ELSE
            COMMIT;
            dbms_output.put_line('Atualizado com sucesso! Nr. Registros: '||vr_nrregistro);                        
          END IF;


  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Erro: ' || vr_dsmensagem || ' SQLERRM: ' || SQLERRM);
      
      ROLLBACK;
  END;
end;
/
