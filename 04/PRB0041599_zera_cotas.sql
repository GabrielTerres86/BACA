declare

  -- Contas com problemas
  cursor c1 IS
    select 1 cdcooper, 1984640  nrdconta, 712.92  valor from dual union all
    select 1 cdcooper, 3127354  nrdconta, 1.00  valor from dual union all
    select 1 cdcooper, 6062733  nrdconta, 230.62  valor from dual union all
    select 1 cdcooper, 8176094  nrdconta, 1956.34  valor from dual union all
    select 1 cdcooper, 9511687  nrdconta, 258.94  valor from dual union all
    select 1 cdcooper, 80364926  nrdconta, 249.47  valor from dual union all
    select 2 cdcooper, 68861  nrdconta, 2.06  valor from dual union all
    select 2 cdcooper, 157210  nrdconta, 22.44  valor from dual union all
    select 2 cdcooper, 228516  nrdconta, 1.00  valor from dual union all
    select 2 cdcooper, 247570  nrdconta, 1.44  valor from dual union all
    select 2 cdcooper, 255190  nrdconta, 1.00  valor from dual union all
    select 2 cdcooper, 276090  nrdconta, 1.00  valor from dual union all
    select 2 cdcooper, 287466  nrdconta, 1.00  valor from dual union all
    select 2 cdcooper, 302953  nrdconta, 1.00  valor from dual union all
    select 2 cdcooper, 306231  nrdconta, 1.00  valor from dual union all
    select 2 cdcooper, 307815  nrdconta, 1.08  valor from dual union all
    select 2 cdcooper, 309990  nrdconta, 1.00  valor from dual union all
    select 2 cdcooper, 341215  nrdconta, 2.45  valor from dual union all
    select 2 cdcooper, 344648  nrdconta, 1.00  valor from dual union all
    select 2 cdcooper, 348961  nrdconta, 1.00  valor from dual union all
    select 2 cdcooper, 392960  nrdconta, 32.79  valor from dual union all
    select 2 cdcooper, 405965  nrdconta, 1.00  valor from dual union all
    select 2 cdcooper, 434604  nrdconta, 2.37  valor from dual union all
    select 2 cdcooper, 451460  nrdconta, 1.00  valor from dual union all
    select 2 cdcooper, 452300  nrdconta, 2.15  valor from dual union all
    select 5 cdcooper, 16926  nrdconta, 30.54  valor from dual union all
    select 5 cdcooper, 18643  nrdconta, 120.35  valor from dual union all
    select 5 cdcooper, 25348  nrdconta, 193.87  valor from dual union all
    select 5 cdcooper, 48810  nrdconta, 4.27  valor from dual union all
    select 5 cdcooper, 50210  nrdconta, 135.82  valor from dual union all
    select 5 cdcooper, 62537  nrdconta, 107.11  valor from dual union all
    select 5 cdcooper, 69574  nrdconta, 22.83  valor from dual union all
    select 5 cdcooper, 77224  nrdconta, 34.80  valor from dual union all
    select 5 cdcooper, 77682  nrdconta, 39.52  valor from dual union all
    select 5 cdcooper, 78999  nrdconta, 38.94  valor from dual union all
    select 5 cdcooper, 80209  nrdconta, 39.33  valor from dual union all
    select 5 cdcooper, 80594  nrdconta, 29.63  valor from dual union all
    select 5 cdcooper, 85570  nrdconta, 63.56  valor from dual union all
    select 5 cdcooper, 89621  nrdconta, 27.36  valor from dual union all
    select 5 cdcooper, 92525  nrdconta, 38.95  valor from dual union all
    select 5 cdcooper, 97764  nrdconta, 25.36  valor from dual union all
    select 5 cdcooper, 101117  nrdconta, 31.02  valor from dual union all
    select 5 cdcooper, 101435  nrdconta, 26.74  valor from dual union all
    select 5 cdcooper, 106011  nrdconta, 32.62  valor from dual union all
    select 5 cdcooper, 106160  nrdconta, 20.56  valor from dual union all
    select 5 cdcooper, 111740  nrdconta, 11.64  valor from dual union all
    select 5 cdcooper, 118001  nrdconta, 11.61  valor from dual union all
    select 5 cdcooper, 118460  nrdconta, 3.42  valor from dual union all
    select 5 cdcooper, 118516  nrdconta, 22.26  valor from dual union all
    select 5 cdcooper, 128368  nrdconta, 12.27  valor from dual union all
    select 5 cdcooper, 131652  nrdconta, 3.31  valor from dual union all
    select 5 cdcooper, 134864  nrdconta, 18.11  valor from dual union all
    select 5 cdcooper, 139122  nrdconta, 3.82  valor from dual union all
    select 5 cdcooper, 141542  nrdconta, 9.98  valor from dual union all
    select 5 cdcooper, 141968  nrdconta, 6.09  valor from dual union all
    select 5 cdcooper, 143286  nrdconta, 0.21  valor from dual union all
    select 5 cdcooper, 159450  nrdconta, 2.43  valor from dual union all
    select 7 cdcooper, 106666  nrdconta, 1.74  valor from dual union all
    select 7 cdcooper, 119318  nrdconta, 42.49  valor from dual union all
    select 7 cdcooper, 128678  nrdconta, 0.88  valor from dual union all
    select 7 cdcooper, 133183  nrdconta, 0.33  valor from dual union all
    select 7 cdcooper, 140066  nrdconta, 193.85  valor from dual union all
    select 7 cdcooper, 148660  nrdconta, 8.10  valor from dual union all
    select 7 cdcooper, 153877  nrdconta, 36.42  valor from dual union all
    select 7 cdcooper, 160962  nrdconta, 3.24  valor from dual union all
    select 7 cdcooper, 232084  nrdconta, 262.66  valor from dual union all
    select 7 cdcooper, 232351  nrdconta, 22.29  valor from dual union all
    select 7 cdcooper, 253596  nrdconta, 0.11  valor from dual union all
    select 7 cdcooper, 321885  nrdconta, 20.00  valor from dual union all
    select 8 cdcooper, 10685  nrdconta, 194.60  valor from dual union all
    select 8 cdcooper, 15156  nrdconta, 1.87  valor from dual union all
    select 8 cdcooper, 27421  nrdconta, 21.72  valor from dual union all
    select 9 cdcooper, 16977  nrdconta, 27.60  valor from dual union all
    select 9 cdcooper, 20532  nrdconta, 185.74  valor from dual union all
    select 9 cdcooper, 37079  nrdconta, 289.99  valor from dual union all
    select 9 cdcooper, 38598  nrdconta, 57.95  valor from dual union all
    select 9 cdcooper, 39020  nrdconta, 137.39  valor from dual union all
    select 9 cdcooper, 40843  nrdconta, 24.05  valor from dual union all
    select 9 cdcooper, 61395  nrdconta, 56.61  valor from dual union all
    select 9 cdcooper, 75213  nrdconta, 23.69  valor from dual union all
    select 9 cdcooper, 85847  nrdconta, 567.87  valor from dual union all
    select 9 cdcooper, 88056  nrdconta, 12.41  valor from dual union all
    select 9 cdcooper, 96229  nrdconta, 25.74  valor from dual union all
    select 9 cdcooper, 96946  nrdconta, 30.00  valor from dual union all
    select 9 cdcooper, 111813  nrdconta, 33.12  valor from dual union all
    select 9 cdcooper, 114650  nrdconta, 75.54  valor from dual union all
    select 9 cdcooper, 123870  nrdconta, 91.91  valor from dual union all
    select 9 cdcooper, 124478  nrdconta, 3.07  valor from dual union all
    select 9 cdcooper, 126420  nrdconta, 2.65  valor from dual union all
    select 9 cdcooper, 128287  nrdconta, 10.83  valor from dual union all
    select 9 cdcooper, 138258  nrdconta, 0.18  valor from dual union all
    select 9 cdcooper, 141720  nrdconta, 7.15  valor from dual union all
    select 9 cdcooper, 145181  nrdconta, 0.95  valor from dual union all
    select 9 cdcooper, 145491  nrdconta, 0.32  valor from dual union all
    select 9 cdcooper, 147745  nrdconta, 0.38  valor from dual union all
    select 9 cdcooper, 152170  nrdconta, 6.44  valor from dual union all
    select 9 cdcooper, 154091  nrdconta, 0.18  valor from dual union all
    select 9 cdcooper, 156612  nrdconta, 0.05  valor from dual union all
    select 9 cdcooper, 157490  nrdconta, 0.20  valor from dual union all
    select 9 cdcooper, 162000  nrdconta, 0.05  valor from dual union all
    select 9 cdcooper, 164534  nrdconta, 0.12  valor from dual union all
    select 9 cdcooper, 214256  nrdconta, 0.02  valor from dual union all
    select 10 cdcooper, 12491  nrdconta, 1.00  valor from dual union all
    select 10 cdcooper, 14362  nrdconta, 52.45  valor from dual union all
    select 10 cdcooper, 16268  nrdconta, 112.35  valor from dual union all
    select 10 cdcooper, 27600  nrdconta, 15.07  valor from dual union all
    select 10 cdcooper, 42420  nrdconta, 36.46  valor from dual union all
    select 10 cdcooper, 42919  nrdconta, 22.70  valor from dual union all
    select 10 cdcooper, 45250  nrdconta, 33.99  valor from dual union all
    select 10 cdcooper, 47228  nrdconta, 36.58  valor from dual union all
    select 10 cdcooper, 61557  nrdconta, 2.10  valor from dual union all
    select 10 cdcooper, 63428  nrdconta, 25.60  valor from dual union all
    select 10 cdcooper, 63665  nrdconta, 6.90  valor from dual union all
    select 10 cdcooper, 71552  nrdconta, 6.67  valor from dual union all
    select 10 cdcooper, 89168  nrdconta, 2.34  valor from dual union all
    select 12 cdcooper, 9750  nrdconta, 95.83  valor from dual union all
    select 12 cdcooper, 10952  nrdconta, 205.61  valor from dual union all
    select 12 cdcooper, 20796  nrdconta, 10.00  valor from dual union all
    select 12 cdcooper, 23957  nrdconta, 28.66  valor from dual union all
    select 12 cdcooper, 26913  nrdconta, 194.50  valor from dual union all
    select 12 cdcooper, 27677  nrdconta, 6.84  valor from dual union all
    select 12 cdcooper, 38407  nrdconta, 15.00  valor from dual union all
    select 12 cdcooper, 48607  nrdconta, 58.35  valor from dual union all
    select 12 cdcooper, 58513  nrdconta, 63.92  valor from dual union all
    select 12 cdcooper, 71196  nrdconta, 14.63  valor from dual union all
    select 12 cdcooper, 78131  nrdconta, 20.54  valor from dual union all
    select 12 cdcooper, 80365  nrdconta, 10.00  valor from dual union all
    select 12 cdcooper, 89982  nrdconta, 34.86  valor from dual union all
    select 12 cdcooper, 94226  nrdconta, 8.37  valor from dual union all
    select 13 cdcooper, 1821  nrdconta, 7.53  valor from dual union all
    select 13 cdcooper, 12408  nrdconta, 11.67  valor from dual union all
    select 13 cdcooper, 15636  nrdconta, 22.23  valor from dual union all
    select 13 cdcooper, 18066  nrdconta, 17.80  valor from dual union all
    select 13 cdcooper, 19348  nrdconta, 738.81  valor from dual union all
    select 13 cdcooper, 19356  nrdconta, 206.92  valor from dual union all
    select 13 cdcooper, 28223  nrdconta, 133.78  valor from dual union all
    select 13 cdcooper, 29777  nrdconta, 48.66  valor from dual union all
    select 13 cdcooper, 31585  nrdconta, 27.50  valor from dual union all
    select 13 cdcooper, 34940  nrdconta, 10.38  valor from dual union all
    select 13 cdcooper, 54534  nrdconta, 49.52  valor from dual union all
    select 13 cdcooper, 55689  nrdconta, 15.70  valor from dual union all
    select 13 cdcooper, 56820  nrdconta, 44.50  valor from dual union all
    select 13 cdcooper, 56936  nrdconta, 37.76  valor from dual union all
    select 13 cdcooper, 59099  nrdconta, 17.64  valor from dual union all
    select 13 cdcooper, 59153  nrdconta, 52.47  valor from dual union all
    select 13 cdcooper, 60577  nrdconta, 87.13  valor from dual union all
    select 13 cdcooper, 62545  nrdconta, 29.64  valor from dual union all
    select 13 cdcooper, 64343  nrdconta, 39.06  valor from dual union all
    select 13 cdcooper, 74870  nrdconta, 53.62  valor from dual union all
    select 13 cdcooper, 74993  nrdconta, 22.04  valor from dual union all
    select 13 cdcooper, 80071  nrdconta, 25.77  valor from dual union all
    select 13 cdcooper, 82317  nrdconta, 11.33  valor from dual union all
    select 13 cdcooper, 93734  nrdconta, 0.21  valor from dual union all
    select 13 cdcooper, 103080  nrdconta, 0.56  valor from dual union all
    select 13 cdcooper, 106950  nrdconta, 24.10  valor from dual union all
    select 13 cdcooper, 108430  nrdconta, 19.04  valor from dual union all
    select 13 cdcooper, 110590  nrdconta, 23.86  valor from dual union all
    select 13 cdcooper, 126241  nrdconta, 22.45  valor from dual union all
    select 13 cdcooper, 140481  nrdconta, 30.79  valor from dual union all
    select 13 cdcooper, 143286  nrdconta, 33.32  valor from dual union all
    select 13 cdcooper, 152510  nrdconta, 5.74  valor from dual union all
    select 13 cdcooper, 153621  nrdconta, 7.89  valor from dual union all
    select 13 cdcooper, 171646  nrdconta, 13.79  valor from dual union all
    select 13 cdcooper, 177601  nrdconta, 4.25  valor from dual union all
    select 13 cdcooper, 196975  nrdconta, 1.89  valor from dual union all
    select 13 cdcooper, 200310  nrdconta, 1.36  valor from dual union all
    select 13 cdcooper, 203955  nrdconta, 33.27  valor from dual union all
    select 13 cdcooper, 209520  nrdconta, 12.55  valor from dual union all
    select 13 cdcooper, 211745  nrdconta, 1.16  valor from dual union all
    select 13 cdcooper, 212024  nrdconta, 0.84  valor from dual union all
    select 13 cdcooper, 219282  nrdconta, 1.71  valor from dual union all
    select 13 cdcooper, 221112  nrdconta, 42.48  valor from dual union all
    select 13 cdcooper, 227404  nrdconta, 0.22  valor from dual union all
    select 13 cdcooper, 229652  nrdconta, 61.47  valor from dual union all
    select 13 cdcooper, 230375  nrdconta, 54.95  valor from dual union all
    select 13 cdcooper, 237655  nrdconta, 103.36  valor from dual union all
    select 13 cdcooper, 243280  nrdconta, 0.83  valor from dual union all
    select 13 cdcooper, 250007  nrdconta, 3.59  valor from dual union all
    select 13 cdcooper, 251232  nrdconta, 0.56  valor from dual union all
    select 13 cdcooper, 253243  nrdconta, 0.36  valor from dual union all
    select 13 cdcooper, 260207  nrdconta, 2.85  valor from dual union all
    select 13 cdcooper, 270938  nrdconta, 10.67  valor from dual union all
    select 13 cdcooper, 315532  nrdconta, 45.37  valor from dual union all
    select 13 cdcooper, 401730  nrdconta, 10.80  valor from dual union all
    select 13 cdcooper, 403458  nrdconta, 28.06  valor from dual union all
    select 13 cdcooper, 405264  nrdconta, 75.96  valor from dual union all
    select 13 cdcooper, 408930  nrdconta, 54.62  valor from dual union all
    select 13 cdcooper, 411485  nrdconta, 32.73  valor from dual union all
    select 13 cdcooper, 412341  nrdconta, 25.72  valor from dual union all
    select 13 cdcooper, 602248  nrdconta, 19.23  valor from dual union all
    select 14 cdcooper, 884  nrdconta, 410.39  valor from dual union all
    select 14 cdcooper, 1449  nrdconta, 1447.62  valor from dual union all
    select 14 cdcooper, 1775  nrdconta, 3943.31  valor from dual union all
    select 14 cdcooper, 3050  nrdconta, 327.42  valor from dual union all
    select 14 cdcooper, 3638  nrdconta, 269.61  valor from dual union all
    select 14 cdcooper, 7307  nrdconta, 475.61  valor from dual union all
    select 14 cdcooper, 7528  nrdconta, 1544.25  valor from dual union all
    select 14 cdcooper, 7803  nrdconta, 66.96  valor from dual union all
    select 14 cdcooper, 8133  nrdconta, 1271.55  valor from dual union all
    select 14 cdcooper, 8214  nrdconta, 1546.49  valor from dual union all
    select 14 cdcooper, 8460  nrdconta, 521.53  valor from dual union all
    select 14 cdcooper, 9938  nrdconta, 569.11  valor from dual union all
    select 14 cdcooper, 12971  nrdconta, 1204.41  valor from dual union all
    select 14 cdcooper, 14184  nrdconta, 154.41  valor from dual union all
    select 14 cdcooper, 14575  nrdconta, 103.33  valor from dual union all
    select 14 cdcooper, 19860  nrdconta, 950.98  valor from dual union all
    select 14 cdcooper, 26468  nrdconta, 3.97  valor from dual union all
    select 14 cdcooper, 31410  nrdconta, 112.43  valor from dual union all
    select 14 cdcooper, 35408  nrdconta, 327.32  valor from dual union all
    select 14 cdcooper, 35424  nrdconta, 10.12  valor from dual union all
    select 14 cdcooper, 35432  nrdconta, 67.24  valor from dual union all
    select 14 cdcooper, 40320  nrdconta, 153.07  valor from dual union all
    select 14 cdcooper, 43060  nrdconta, 7.73  valor from dual union all
    select 14 cdcooper, 54178  nrdconta, 26.80  valor from dual union all
    select 14 cdcooper, 54984  nrdconta, 34.00  valor from dual union all
    select 14 cdcooper, 56561  nrdconta, 33.64  valor from dual union all
    select 14 cdcooper, 57630  nrdconta, 571.27  valor from dual union all
    select 14 cdcooper, 57860  nrdconta, 8.76  valor from dual union all
    select 14 cdcooper, 58114  nrdconta, 57.54  valor from dual union all
    select 14 cdcooper, 58149  nrdconta, 86.67  valor from dual union all
    select 14 cdcooper, 58858  nrdconta, 30.48  valor from dual union all
    select 14 cdcooper, 60372  nrdconta, 8.82  valor from dual union all
    select 14 cdcooper, 70394  nrdconta, 12.27  valor from dual union all
    select 14 cdcooper, 78620  nrdconta, 10.13  valor from dual union all
    select 14 cdcooper, 79740  nrdconta, 22.93  valor from dual union all
    select 14 cdcooper, 92487  nrdconta, 0.02  valor from dual union all
    select 14 cdcooper, 92630  nrdconta, 0.02  valor from dual union all
    select 16 cdcooper, 528374  nrdconta, 8280.66  valor from dual union all
    select 16 cdcooper, 2320738  nrdconta, 1.00  valor from dual union all
    select 16 cdcooper, 2602741  nrdconta, 1.00  valor from dual union all
    select 16 cdcooper, 6029531  nrdconta, 1.00  valor from dual union all
    select 16 cdcooper, 6076467  nrdconta, 1.00  valor from dual;
  r1 c1%rowtype;

  -- Cursor sobre a tabela de lotes
  CURSOR cr_craplot(pr_cdcooper crapcop.cdcooper%TYPE,
                    pr_dtmvtolt craplot.dtmvtolt%TYPE,
                    pr_cdagenci craplot.cdagenci%TYPE,
                    pr_cdbccxlt craplot.cdbccxlt%TYPE,
                    pr_nrdolote craplot.nrdolote%TYPE) IS
    SELECT vlinfocr
          ,vlcompcr
          ,vlinfodb
          ,vlcompdb
          ,qtinfoln
          ,qtcompln
          ,nrseqdig
          ,rowid
      FROM craplot
     WHERE cdcooper = pr_cdcooper
       AND dtmvtolt = pr_dtmvtolt
       AND cdagenci = pr_cdagenci
       AND cdbccxlt = pr_cdbccxlt
       AND nrdolote = pr_nrdolote;
  rw_craplot cr_craplot%ROWTYPE;

  vr_cdcooper     crapcop.cdcooper%type; --(10)
  vr_cdcooper_ant crapcop.cdcooper%type; --(10)
  vr_nrdconta     crapass.nrdconta%type; --(10)

  --
  -- Constantes dos lotes de lançamentos em capital
  vr_cdagenci CONSTANT crapass.cdagenci%TYPE := 1;          -- Codigo da agencia
  vr_cdbccxlt CONSTANT craplot.cdbccxlt%TYPE := 100;        -- Codigo do banco / caixa
  vr_nrdolote CONSTANT craplot.nrdolote%TYPE := 10002;      -- Numero do lote
  vr_cdhistor CONSTANT craphis.cdhistor%TYPE := 61;         
  vr_rowid_alt rowid;
  v_nrseqdig number(9) := 0;
  v_valida_lote boolean;
  vr_valor craplct.vllanmto%type;
  --
  err_cooperado   exception;
  fim             exception;

begin

  for r1 in c1 loop

      vr_cdcooper := r1.cdcooper;
      vr_nrdconta := r1.nrdconta;
      vr_valor    := r1.valor;

      v_valida_lote := false;
      --Validar Cooperativa/Lote
      if vr_cdcooper_ant is null then
         vr_cdcooper_ant := vr_cdcooper;
         -- Valida existencia de lote para primeira cooperativa
         v_valida_lote := true;
      else
        if vr_cdcooper_ant != vr_cdcooper then
           vr_cdcooper_ant := vr_cdcooper;
           v_valida_lote := true;
        end if;
      end if;

      --Verifica se é necessário validar Lote
      if v_valida_lote then
           -- Valida existencia de lote quando inicia nova cooperativa
          OPEN cr_craplot(pr_cdcooper => vr_cdcooper,
                          pr_dtmvtolt => trunc(sysdate),
                          pr_cdagenci => vr_cdagenci,
                          pr_cdbccxlt => vr_cdbccxlt,
                          pr_nrdolote => vr_nrdolote);
          FETCH cr_craplot INTO rw_craplot;
          -- Em caso de Lote já existente, vamos atualizar o existente
          vr_rowid_alt := null;
          IF cr_craplot%FOUND THEN
            CLOSE cr_craplot;
            v_nrseqdig := rw_craplot.nrseqdig;
            vr_rowid_alt := rw_craplot.rowid;

          ELSE
            CLOSE cr_craplot;
            --Cria Lote
            v_nrseqdig := 0;
            BEGIN
              INSERT INTO craplot (dtmvtolt
                                  ,cdagenci
                                  ,cdbccxlt
                                  ,nrdolote
                                  ,tplotmov
                                  ,cdcooper
                                  ,vlinfocr
                                  ,vlcompcr
                                  ,vlinfodb
                                  ,vlcompdb
                                  ,qtinfoln
                                  ,qtcompln
                                  ,nrseqdig)
                           VALUES (trunc(sysdate)
                                  ,vr_cdagenci
                                  ,vr_cdbccxlt
                                  ,vr_nrdolote
                                  ,2
                                  ,vr_cdcooper
                                  ,0
                                  ,0
                                  ,0
                                  ,0
                                  ,0
                                  ,0
                                  ,0) returning rowid into vr_rowid_alt;
            EXCEPTION
              WHEN OTHERS THEN
                 CLOSE cr_craplot;
                 dbms_output.put_line('Erro ao inserir craplot lote: '||sqlerrm);
                 raise;
            END;
          END IF;
      end if;


    -- Gera lançamento craplct
    BEGIN
      --
      v_nrseqdig := v_nrseqdig+1;
      INSERT INTO craplct
        (dtmvtolt,
         cdagenci,
         cdbccxlt,
         nrdolote,
         nrdconta,
         nrdocmto,
         cdhistor,
         vllanmto,
         nrseqdig,
         cdcooper)
       VALUES
        (trunc(sysdate),
         vr_cdagenci,
         vr_cdbccxlt,
         vr_nrdolote,
         vr_nrdconta,
         v_nrseqdig,--vr_nrdocmto,
         vr_cdhistor,
         r1.valor,
         v_nrseqdig,
         vr_cdcooper);

         -- Atualiza o Lote
         begin
         Update craplot l
            set l.vlinfodb = l.vlinfodb+r1.valor,
                l.vlcompdb = l.vlcompdb+r1.valor,
                l.qtinfoln = l.qtinfoln+1,
                l.qtcompln = l.qtcompln+1,
                l.nrseqdig = l.nrseqdig+1
          where l.rowid=  vr_rowid_alt;
         exception
          when others then
           dbms_output.put_line('Erro ao atualizar lote: '||sqlerrm);
           raise;
         end;
    EXCEPTION
      WHEN OTHERS THEN
       dbms_output.put_line('Erro ao inserir craplct lote: '||sqlerrm);
       raise;
    END;

    --
    commit;
  end loop;

EXCEPTION
  when others then
    rollback;
    raise_application_error(-20001,'Erro: '||sqlerrm);
end;
