DECLARE
  --
  CURSOR cr_craplau(pr_dtantes     DATE
                    , pr_dtatual   DATE
                    --, pr_cdcooper  NUMBER
                    ) is
    SELECT cdcooper
      , nrdconta
      , idlancto
      , dtmvtopg
      , nrcrcard
      , insitlau
      , to_number( substr(nrcrcard, -6) )
      , rowid
    FROM CRAPLAU
    WHERE DTDEBITO IS NULL
      -- AND CDCOOPER =  pr_cdcooper
      AND DSORIGEM =  'CARTAOBB'
      -- dia útil anterior
      AND dtmvtopg >  pr_dtantes -- rg_crapcop.dtmvtoan
      -- data atual
      AND dtmvtopg <= pr_dtatual -- rw_crapdat.dtmvtolt
    ORDER BY cdcooper;
  --
  rg_craplau     cr_craplau%rowtype;
  --
  vr_datalcto    date;
  vr_dtantes     date;
  vr_qtd         number;
  vr_exception   exception;
  vr_msgerro     varchar2(1000);
  vr_clob        clob;
  vr_backup      varchar2(1000);
  vr_des_erro    varchar2(1000);
  --
BEGIN
  --
  -- Inicializar o CLOB
  vr_clob := NULL;
  dbms_lob.createtemporary(vr_clob, TRUE);
  dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
  --
  vr_dtantes  := to_date('08/01/2021', 'dd/mm/rrrr');
  vr_datalcto := to_date('11/01/2021', 'dd/mm/rrrr');
  --
  LOOP
    --
    --
    vr_datalcto := gene0005.fn_valida_dia_util( -- gene0005.fn_valida_dia_util(
      rg_craplau.cdcooper
      , vr_datalcto
    );
    --
    -- Varre as contas que precisam ser ajustadas na data atual, "vr_datalcto"
    -- OPEN cr_craplau(vr_dtantes, vr_datalcto, rg_crapcop.cdcooper);
    OPEN cr_craplau(vr_dtantes, vr_datalcto);
    --
    LOOP
      FETCH cr_craplau INTO rg_craplau;
      EXIT WHEN cr_craplau%NOTFOUND;
      --
      vr_backup := rg_craplau.rowid || ';' || rg_craplau.idlancto || ';' || vr_datalcto || ';' || rg_craplau.cdcooper || chr(10);
      --
      if vr_clob is null then
        vr_clob := vr_backup;
      else
        dbms_lob.writeappend(vr_clob, length(vr_backup), vr_backup);
      end if;
      --
      -- Atualizando os registros.
      BEGIN
        UPDATE craplau
           SET craplau.insitlau = 2, 
               craplau.dtdebito = vr_datalcto -- rw_crapdat.dtmvtolt
         WHERE craplau.cdcooper =  rg_craplau.cdcooper
           AND craplau.dtmvtopg >  vr_dtantes -- rw_crapdat.dtmvtoan
           AND craplau.dtmvtopg <= vr_datalcto -- rw_crapdat.dtmvtolt
           AND craplau.dtdebito IS NULL
           AND craplau.dsorigem = 'CARTAOBB'
           AND craplau.idlancto = rg_craplau.idlancto
           AND craplau.rowid    = rg_craplau.rowid;
         --
         IF SQL%ROWCOUNT <> 1 THEN
           --
           vr_msgerro := 'Quantidade de atualização diferente do esperado: ' || SQL%ROWCOUNT;
           RAISE vr_exception;
           --
         END IF;
         --
          COMMIT;
         --
      EXCEPTION
        WHEN OTHERS THEN
          --
          vr_msgerro := 'Não foi possivel alterar craplau CARTAOBB: '|| SQLERRM;
          RAISE vr_exception;
          --
      END;
      --
      -- Final do loop das contas que precisam ser ajustadas com base na data do loop anterior.
    END LOOP;
    --
    CLOSE cr_craplau;
    -- Armazenando o que será o dia útil anterior para a próxima operação.
    vr_dtantes := vr_datalcto;
    vr_datalcto := vr_datalcto + 1;
    exit when trunc(vr_datalcto) >= trunc(sysdate);
    --
  END LOOP;
  --
  -- Fecha o CLOB.
  vr_backup := 'final do arquivo';
  --
  dbms_lob.writeappend(vr_clob, length(vr_backup), vr_backup);
  --
  -- cria o clop e chamar a - usar como referência o rowid.
  -- caminho lab: '/progress/t0033567/usr/coop/cecred/log'
  -- caminho prd: '/usr/coop/cecred/log'
  gene0002.pc_clob_para_arquivo(pr_clob        => vr_clob
                                , pr_caminho   => '/usr/coop/cecred/log'
                                , pr_arquivo   => 'bkp_inc0078210.craplau'
                                , pr_des_erro  => vr_des_erro);
  --
EXCEPTION 
  WHEN vr_exception THEN
    --
    RAISE_APPLICATION_ERROR(-20000, vr_msgerro);
    --
  WHEN OTHERS THEN
    --
    RAISE_APPLICATION_ERROR(-20000, 'Erro ao executar o script: ' || SQLERRM);
    --
END;
