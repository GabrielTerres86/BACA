/*
  Heitor (Mouts)
  Script para recomposicao de saldo de cooperado

  Esse script pode ser executado diretamente na PROD através do usuário analista, pois não executa comandos DML
  e nem chamada de rotinas

  Instrucoes: 1 - Preencher as variaveis de pesquisa vr_cdcooper, vr_nrdconta, vr_dtiniper, vr_dtfimper;
              2 - Definir quais informações devem ser impressas no DBMS_OUTPUT, parametros vr_imprime_...;
              3 - O saldo da data definida em vr_dtiniper será considerado como correto e será utilizado como ponto de partida;
              4 - Para todas as demais SDAs do período, serão recalculados os valores, considerando os lancamentos da LCM
                  e os desbloqueios de saldo da DPB;
              5 - Para os dias com diferenças, serão gerados comandos update para correção, bem como updates para backup, retornando
                  a situação se necessário;
              6 - Se o último dia do período informado for igual ao MAX(dtmvtolt) da tabela SDA, será gerado também update para a SLD;
              7 - O resultado do script será apresentado no dbms_output;
              8 - Sempre validar os updates antes em ambiente de dev e com homologação de usuário;
              9 - Caso sejam encaminhados para aplicação em PROD, setar a variável vr_imprime_backup e guardar os updates de backup;
              
              
  Alterações:
  
     23/05/2019 - Utilizado REPLACE para substituir vírgula por ponto na saída do update de correção e de backup              
*/

DECLARE
  --Setar as variaveis para pesquisa
  vr_cdcooper NUMBER := 1;
  vr_nrdconta NUMBER := 1501976;
  vr_dtiniper DATE   := to_date('10/12/2018','DD/MM/RRRR');
  vr_dtfimper DATE   := to_date('09/01/2019','DD/MM/RRRR');
  
  --Define impressoes
  vr_imprime_saldos      NUMBER(1) := 1;
  vr_imprime_lancamentos NUMBER(1) := 1;
  vr_imprime_diferencas  NUMBER(1) := 1;
  vr_imprime_update      NUMBER(1) := 1;
  vr_imprime_backup      NUMBER(1) := 1;

  --Variaveis para armazenar as diferencas
  vr_dif_vlsddisp NUMBER;
  vr_dif_vlsdchsl NUMBER;
  vr_dif_vlsdbloq NUMBER;
  vr_dif_vlsdblpr NUMBER;
  vr_dif_vlsdblfp NUMBER;

  vr_index VARCHAR2(10);

  --Variaveis para armazenar informacoes de saldo do dia anterior
  vr_vlsddisp_anterior NUMBER(25,2) := 0;
  vr_vlsdchsl_anterior NUMBER(25,2) := 0;
  vr_vlsdbloq_anterior NUMBER(25,2) := 0;
  vr_vlsdblpr_anterior NUMBER(25,2) := 0;
  vr_vlsdblfp_anterior NUMBER(25,2) := 0;
  vr_dtmvtolt_anterior DATE         := to_date('22/04/1500','DD/MM/RRRR');

  TYPE vr_rec_update IS RECORD (dsupdate VARCHAR2(4000)
                               ,dsbackup VARCHAR2(4000));
  TYPE typ_tab_update IS TABLE OF vr_rec_update INDEX BY VARCHAR2(10);
  vr_tab_update typ_tab_update;

  --Variaveis dos updates
  vr_update_correcao VARCHAR2(4000);
  vr_update_backup   VARCHAR2(4000);
  vr_virgula         NUMBER(1);
  vr_dtultsda        DATE;
  
  CURSOR cr_sda_max IS
    SELECT MAX(sda.dtmvtolt) dtmvtolt
      FROM crapsda sda
     WHERE sda.cdcooper = vr_cdcooper
       AND sda.nrdconta = vr_nrdconta;

  --Busca das informacoes da SDA
  CURSOR cr_sda IS
    SELECT sda.cdcooper
         , sda.nrdconta
         , sda.dtmvtolt
         , sda.vlsddisp
         , sda.vlsdchsl
         , sda.vlsdbloq
         , sda.vlsdblpr
         , sda.vlsdblfp
         , sda.rowid
         , Row_Number() OVER (PARTITION BY cdcooper, nrdconta
                                   ORDER BY dtmvtolt) nrseqreg
         , COUNT(*) OVER () AS qtdreg
      FROM crapsda sda
     WHERE sda.cdcooper = vr_cdcooper
       AND sda.nrdconta = vr_nrdconta
       AND sda.dtmvtolt BETWEEN vr_dtiniper AND vr_dtfimper
     ORDER
        BY sda.cdcooper
         , sda.nrdconta
         , sda.dtmvtolt;

  --Busca das informacoes da LCM, quebradas por INHISTOR
  CURSOR cr_lcm(pr_cdcooper IN craplcm.cdcooper%TYPE
               ,pr_nrdconta IN craplcm.nrdconta%TYPE
               ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE) IS
    SELECT NVL(SUM(DECODE(his.inhistor,1,lcm.vllanmto,11,lcm.vllanmto*-1,0)),0) vlsddisp
         , NVL(SUM(DECODE(his.inhistor,2,lcm.vllanmto,12,lcm.vllanmto*-1,0)),0) vlsdchsl
         , NVL(SUM(DECODE(his.inhistor,3,lcm.vllanmto,13,lcm.vllanmto*-1,0)),0) vlsdbloq
         , NVL(SUM(DECODE(his.inhistor,4,lcm.vllanmto,14,lcm.vllanmto*-1,0)),0) vlsdblpr
         , NVL(SUM(DECODE(his.inhistor,5,lcm.vllanmto,15,lcm.vllanmto*-1,0)),0) vlsdblfp
      FROM craphis his
         , craplcm lcm
     WHERE his.cdcooper = lcm.cdcooper
       AND his.cdhistor = lcm.cdhistor
       AND lcm.cdcooper = pr_cdcooper
       AND lcm.nrdconta = pr_nrdconta
       AND lcm.dtmvtolt = pr_dtmvtolt;

  rw_lcm cr_lcm%ROWTYPE;

  --Busca das informacoes da DPB, quebradas por INHISTOR
  CURSOR cr_dpb(pr_cdcooper IN craplcm.cdcooper%TYPE
               ,pr_nrdconta IN craplcm.nrdconta%TYPE
               ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE) IS
    SELECT NVL(SUM(DECODE(his.indebcre,'D',dpb.vllanmto*-1,dpb.vllanmto)),0) vlsddisp
         , NVL(SUM(DECODE(his.inhistor,2,dpb.vllanmto,12,dpb.vllanmto*-1,0)),0) vlsdchsl
         , NVL(SUM(DECODE(his.inhistor,3,dpb.vllanmto,13,dpb.vllanmto*-1,0)),0) vlsdbloq
         , NVL(SUM(DECODE(his.inhistor,4,dpb.vllanmto,14,dpb.vllanmto*-1,0)),0) vlsdblpr
         , NVL(SUM(DECODE(his.inhistor,5,dpb.vllanmto,15,dpb.vllanmto*-1,0)),0) vlsdblfp
      FROM craphis his
         , crapdpb dpb
     WHERE his.cdcooper = dpb.cdcooper
       AND his.cdhistor = dpb.cdhistor
       AND dpb.cdcooper = pr_cdcooper
       AND dpb.nrdconta = pr_nrdconta
       AND dpb.dtliblan = pr_dtmvtolt
       AND dpb.inlibera = 1;

  rw_dpb cr_dpb%ROWTYPE;

  FUNCTION fn_gera_update(pr_rowid IN ROWID
                         ,pr_tipo  IN VARCHAR2) RETURN vr_rec_update IS
    vr_rec vr_rec_update;

    vr_update_correcao VARCHAR2(4000);
    vr_update_backup   VARCHAR2(4000);
  BEGIN
    IF pr_tipo = 'SDA' THEN
      vr_update_correcao := 'update crapsda c'||CHR(13)
                          ||'   set ';
    ELSIF pr_tipo = 'SLD' THEN
      vr_update_correcao := 'update crapsld c'||CHR(13)
                          ||'   set ';
    END IF;

    vr_update_backup := vr_update_correcao;
    vr_virgula       := 0;

    --vlsddisp
    IF vr_dif_vlsddisp <> 0 THEN
      vr_virgula := 1;

      IF vr_dif_vlsddisp < 0 THEN
        vr_update_correcao := vr_update_correcao||'c.vlsddisp = c.vlsddisp - '||REPLACE(ABS(vr_dif_vlsddisp),',','.')||CHR(13);
        vr_update_backup   := vr_update_backup  ||'c.vlsddisp = c.vlsddisp + '||REPLACE(ABS(vr_dif_vlsddisp),',','.')||CHR(13);
      ELSE
        vr_update_correcao := vr_update_correcao||'c.vlsddisp = c.vlsddisp + '||REPLACE(ABS(vr_dif_vlsddisp),',','.')||CHR(13);
        vr_update_backup   := vr_update_backup  ||'c.vlsddisp = c.vlsddisp - '||REPLACE(ABS(vr_dif_vlsddisp),',','.')||CHR(13);
      END IF;
    END IF;

    --vlsdchsl
    IF vr_dif_vlsdchsl <> 0 THEN
      IF vr_virgula = 1 THEN
        vr_update_correcao := vr_update_correcao||'     , ';
        vr_update_backup   := vr_update_backup  ||'     , ';
      END IF;

      vr_virgula := 1;

      IF vr_dif_vlsdchsl < 0 THEN
        vr_update_correcao := vr_update_correcao||'c.vlsdchsl = c.vlsdchsl - '||REPLACE(ABS(vr_dif_vlsdchsl),',','.')||CHR(13);
        vr_update_backup   := vr_update_backup  ||'c.vlsdchsl = c.vlsdchsl + '||REPLACE(ABS(vr_dif_vlsdchsl),',','.')||CHR(13);
      ELSE
        vr_update_correcao := vr_update_correcao||'c.vlsdchsl = c.vlsdchsl + '||REPLACE(ABS(vr_dif_vlsdchsl),',','.')||CHR(13);
        vr_update_backup   := vr_update_backup  ||'c.vlsdchsl = c.vlsdchsl - '||REPLACE(ABS(vr_dif_vlsdchsl),',','.')||CHR(13);
      END IF;
    END IF;

    --vlsdbloq
    IF vr_dif_vlsdbloq <> 0 THEN
      IF vr_virgula = 1 THEN
        vr_update_correcao := vr_update_correcao||'     , ';
        vr_update_backup   := vr_update_backup  ||'     , ';
      END IF;

      vr_virgula := 1;

      IF vr_dif_vlsdbloq < 0 THEN
        vr_update_correcao := vr_update_correcao||'c.vlsdbloq = c.vlsdbloq - '||REPLACE(ABS(vr_dif_vlsdbloq),',','.')||CHR(13);
        vr_update_backup   := vr_update_backup  ||'c.vlsdbloq = c.vlsdbloq + '||REPLACE(ABS(vr_dif_vlsdbloq),',','.')||CHR(13);
      ELSE
        vr_update_correcao := vr_update_correcao||'c.vlsdbloq = c.vlsdbloq + '||REPLACE(ABS(vr_dif_vlsdbloq),',','.')||CHR(13);
        vr_update_backup   := vr_update_backup  ||'c.vlsdbloq = c.vlsdbloq - '||REPLACE(ABS(vr_dif_vlsdbloq),',','.')||CHR(13);
      END IF;
    END IF;

    --vlsdblpr
    IF vr_dif_vlsdblpr <> 0 THEN
      IF vr_virgula = 1 THEN
        vr_update_correcao := vr_update_correcao||'     , ';
        vr_update_backup   := vr_update_backup  ||'     , ';
      END IF;
      
      vr_virgula := 1;

      IF vr_dif_vlsdblpr < 0 THEN
        vr_update_correcao := vr_update_correcao||'c.vlsdblpr = c.vlsdblpr - '||REPLACE(ABS(vr_dif_vlsdblpr),',','.')||CHR(13);
        vr_update_backup   := vr_update_backup  ||'c.vlsdblpr = c.vlsdblpr + '||REPLACE(ABS(vr_dif_vlsdblpr),',','.')||CHR(13);
      ELSE
        vr_update_correcao := vr_update_correcao||'c.vlsdblpr = c.vlsdblpr + '||REPLACE(ABS(vr_dif_vlsdblpr),',','.')||CHR(13);
        vr_update_backup   := vr_update_backup  ||'c.vlsdblpr = c.vlsdblpr - '||REPLACE(ABS(vr_dif_vlsdblpr),',','.')||CHR(13);
      END IF;
    END IF;

    --vlsdblfp
    IF vr_dif_vlsdblfp <> 0 THEN
      IF vr_virgula = 1 THEN
        vr_update_correcao := vr_update_correcao||'     , ';
        vr_update_backup   := vr_update_backup  ||'     , ';
      END IF;

      vr_virgula := 1;

      IF vr_dif_vlsdblfp < 0 THEN
        vr_update_correcao := vr_update_correcao||'c.vlsdblfp = c.vlsdblfp - '||REPLACE(ABS(vr_dif_vlsdblfp),',','.')||CHR(13);
        vr_update_backup   := vr_update_backup  ||'c.vlsdblfp = c.vlsdblfp + '||REPLACE(ABS(vr_dif_vlsdblfp),',','.')||CHR(13);
      ELSE
        vr_update_correcao := vr_update_correcao||'c.vlsdblfp = c.vlsdblfp + '||REPLACE(ABS(vr_dif_vlsdblfp),',','.')||CHR(13);
        vr_update_backup   := vr_update_backup  ||'c.vlsdblfp = c.vlsdblfp - '||REPLACE(ABS(vr_dif_vlsdblfp),',','.')||CHR(13);
      END IF;
    END IF;

    IF pr_tipo = 'SDA' THEN
      vr_update_correcao := vr_update_correcao||' where c.rowid = '''||pr_rowid||''';';
      vr_update_backup   := vr_update_backup  ||' where c.rowid = '''||pr_rowid||''';';
    ELSIF pr_tipo = 'SLD' THEN
      vr_update_correcao := vr_update_correcao||' where c.cdcooper = '||vr_cdcooper||CHR(13)||
                                                '   and c.nrdconta = '||vr_nrdconta||';';
      vr_update_backup   := vr_update_backup  ||' where c.cdcooper = '||vr_cdcooper||CHR(13)||
                                                '   and c.nrdconta = '||vr_nrdconta||';';
    END IF;

    vr_rec.dsupdate := vr_update_correcao;
    vr_rec.dsbackup := vr_update_backup;

    RETURN vr_rec;
  END;
BEGIN
  dbms_output.enable(1000000000000);

  --Loop registros SDA
  FOR rw_sda IN cr_sda LOOP
    vr_dif_vlsddisp := 0;
    vr_dif_vlsdchsl := 0;
    vr_dif_vlsdbloq := 0;
    vr_dif_vlsdblpr := 0;
    vr_dif_vlsdblfp := 0;

    --Imprime cabecalho, coop, conta e data
    dbms_output.put_line('Cop: '||rw_sda.cdcooper||'  '
                       ||'Cta: '||rw_sda.nrdconta||'  '
                       ||'Dat: '||to_char(rw_sda.dtmvtolt,'DD/MM/RRRR'));

    --Imprime saldos anteriores e lancamentos caso nao seja o primeiro dia do periodo
    IF rw_sda.dtmvtolt <> vr_dtiniper THEN
      IF vr_imprime_saldos = 1 THEN
        dbms_output.put_line('SALDO ANTERIOR '||to_char(vr_dtmvtolt_anterior,'DD/MM/RRRR')||': '
                           ||'Vlsddisp: '||vr_vlsddisp_anterior||'  '
                           ||'Vlsdchsl: '||vr_vlsdchsl_anterior||'  '
                           ||'Vlsdbloq: '||vr_vlsdbloq_anterior||'  '
                           ||'Vlsdblpr: '||vr_vlsdblpr_anterior||'  '
                           ||'Vlsdblfp: '||vr_vlsdblfp_anterior);
      END IF;

      --Busca somatorio dos lancamentos do dia
      OPEN cr_lcm(rw_sda.cdcooper, rw_sda.nrdconta, rw_sda.dtmvtolt);
      FETCH cr_lcm INTO rw_lcm;
      CLOSE cr_lcm;

      --Verifica os lancamentos desbloqueados no dia
      OPEN cr_dpb(rw_sda.cdcooper, rw_sda.nrdconta, rw_sda.dtmvtolt);
      FETCH cr_dpb INTO rw_dpb;
      CLOSE cr_dpb;

      --Impressao dos lancamentos
      IF vr_imprime_lancamentos = 1 THEN
        dbms_output.put_line('LANÇAMENTOS '||to_char(rw_sda.dtmvtolt,'DD/MM/RRRR'||': ')
                           ||'Vlsddisp: '||(rw_lcm.vlsddisp + rw_dpb.vlsddisp)||'  '
                           ||'Vlsdchsl: '||(rw_lcm.vlsdchsl - rw_dpb.vlsdchsl)||'  '
                           ||'Vlsdbloq: '||(rw_lcm.vlsdbloq - rw_dpb.vlsdbloq)||'  '
                           ||'Vlsdblpr: '||(rw_lcm.vlsdblpr - rw_dpb.vlsdblpr)||'  '
                           ||'Vlsdblfp: '||(rw_lcm.vlsdblfp - rw_dpb.vlsdblfp));
      END IF;
    END IF;  

    --Imprime os saldos da SDA
    IF vr_imprime_saldos = 1 THEN
      dbms_output.put_line('SALDO '||to_char(rw_sda.dtmvtolt,'DD/MM/RRRR')||': '
                         ||'Vlsddisp: '||rw_sda.vlsddisp||'  '
                         ||'Vlsdchsl: '||rw_sda.vlsdchsl||'  '
                         ||'Vlsdbloq: '||rw_sda.vlsdbloq||'  '
                         ||'Vlsdblpr: '||rw_sda.vlsdblpr||'  '
                         ||'Vlsdblfp: '||rw_sda.vlsdblfp);
    END IF;
    
    --Calcula saldo correto caso nao seja o primeiro dia do periodo
    IF rw_sda.dtmvtolt <> vr_dtiniper THEN
      IF vr_imprime_saldos = 1 THEN
        dbms_output.put_line('SALDO CORRETO '||to_char(rw_sda.dtmvtolt,'DD/MM/RRRR')||': '
                           ||'Vlsddisp: '||(vr_vlsddisp_anterior + rw_lcm.vlsddisp + rw_dpb.vlsddisp)||'  '
                           ||'Vlsdchsl: '||(vr_vlsdchsl_anterior + rw_lcm.vlsdchsl - rw_dpb.vlsdchsl)||'  '
                           ||'Vlsdbloq: '||(vr_vlsdbloq_anterior + rw_lcm.vlsdbloq - rw_dpb.vlsdbloq)||'  '
                           ||'Vlsdblpr: '||(vr_vlsdblpr_anterior + rw_lcm.vlsdblpr - rw_dpb.vlsdblpr)||'  '
                           ||'Vlsdblfp: '||(vr_vlsdblfp_anterior + rw_lcm.vlsdblfp - rw_dpb.vlsdblfp));
      END IF;

      --Atribuicao das diferencas
      vr_dif_vlsddisp := (vr_vlsddisp_anterior + rw_lcm.vlsddisp + rw_dpb.vlsddisp) - rw_sda.vlsddisp;
      vr_dif_vlsdchsl := (vr_vlsdchsl_anterior + rw_lcm.vlsdchsl - rw_dpb.vlsdchsl) - rw_sda.vlsdchsl;
      vr_dif_vlsdbloq := (vr_vlsdbloq_anterior + rw_lcm.vlsdbloq - rw_dpb.vlsdbloq) - rw_sda.vlsdbloq;
      vr_dif_vlsdblpr := (vr_vlsdblpr_anterior + rw_lcm.vlsdblpr - rw_dpb.vlsdblpr) - rw_sda.vlsdblpr;
      vr_dif_vlsdblfp := (vr_vlsdblfp_anterior + rw_lcm.vlsdblfp - rw_dpb.vlsdblfp) - rw_sda.vlsdblfp;

      --Caso exista alguma diferenca, imprime e gerar updates de correcao e de retorno
      IF vr_dif_vlsddisp <> 0 
      OR vr_dif_vlsdchsl <> 0
      OR vr_dif_vlsdbloq <> 0
      OR vr_dif_vlsdblpr <> 0
      OR vr_dif_vlsdblfp <> 0 THEN
        IF vr_imprime_diferencas = 1 THEN
          dbms_output.put_line('DIFERENÇAS: '||to_char(rw_sda.dtmvtolt,'DD/MM/RRRR')||': '
                             ||'Vlsddisp: '||vr_dif_vlsddisp||'  '
                             ||'Vlsdchsl: '||vr_dif_vlsdchsl||'  '
                             ||'Vlsdbloq: '||vr_dif_vlsdbloq||'  '
                             ||'Vlsdblpr: '||vr_dif_vlsdblpr||'  '
                             ||'Vlsdblfp: '||vr_dif_vlsdblfp);
        END IF;
        
        vr_tab_update(to_char(rw_sda.dtmvtolt,'DD/MM/RRRR')) := fn_gera_update(rw_sda.rowid, 'SDA');
        
        --Último registro, checa se o último registro do período é também o máximo da SDA
        --Em caso positivo, iremos gerar um update também para a SLD.
        IF rw_sda.qtdreg = rw_sda.nrseqreg THEN
          OPEN cr_sda_max;
          FETCH cr_sda_max INTO vr_dtultsda;
          CLOSE cr_sda_max;
          
          IF NVL(vr_dtultsda,to_date('01/01/1500','DD/MM/RRRR')) = rw_sda.dtmvtolt THEN
            vr_tab_update('CRAPSLD') := fn_gera_update(rw_sda.rowid, 'SLD');
          END IF;
        END IF;
      END IF;
    END IF;

    --Armazena informacoes de saldo anterior
    IF rw_sda.dtmvtolt <> vr_dtiniper THEN
      vr_vlsddisp_anterior := vr_vlsddisp_anterior + rw_lcm.vlsddisp + rw_dpb.vlsddisp;
      vr_vlsdchsl_anterior := vr_vlsdchsl_anterior + rw_lcm.vlsdchsl - rw_dpb.vlsdchsl;
      vr_vlsdbloq_anterior := vr_vlsdbloq_anterior + rw_lcm.vlsdbloq - rw_dpb.vlsdbloq;
      vr_vlsdblpr_anterior := vr_vlsdblpr_anterior + rw_lcm.vlsdblpr - rw_dpb.vlsdblpr;
      vr_vlsdblfp_anterior := vr_vlsdblfp_anterior + rw_lcm.vlsdblfp - rw_dpb.vlsdblfp;
      vr_dtmvtolt_anterior := rw_sda.dtmvtolt;
    ELSE
      vr_vlsddisp_anterior := rw_sda.vlsddisp;
      vr_vlsdchsl_anterior := rw_sda.vlsdchsl;
      vr_vlsdbloq_anterior := rw_sda.vlsdbloq;
      vr_vlsdblpr_anterior := rw_sda.vlsdblpr;
      vr_vlsdblfp_anterior := rw_sda.vlsdblfp;
      vr_dtmvtolt_anterior := rw_sda.dtmvtolt;
    END IF;

    dbms_output.put_line('');
    dbms_output.put_line('----------------------------------------------------------------------------------');
    dbms_output.put_line('');
  END LOOP;
  
  IF vr_tab_update.count > 0 THEN
    --Imprime lista de updates
    IF vr_imprime_update = 1 THEN
      dbms_output.put_line('LISTAGEM DE UPDATES PARA CORRECAO DE SALDO');
      vr_index := vr_tab_update.first;

      WHILE vr_index IS NOT NULL LOOP
        dbms_output.put_line('--'||vr_index);
        dbms_output.put_line(vr_tab_update(vr_index).dsupdate);
        dbms_output.put_line('');
        vr_index := vr_tab_update.next(vr_index);
      END LOOP;
    END IF;

    --Imprime lista de backups
    IF vr_imprime_backup = 1 THEN
      dbms_output.put_line('');
      dbms_output.put_line('');
      dbms_output.put_line('LISTAGEM DE UPDATES PARA BACKUP DE SALDO');
      vr_index := vr_tab_update.first;

      WHILE vr_index IS NOT NULL LOOP
        dbms_output.put_line('--'||vr_index);
        dbms_output.put_line(vr_tab_update(vr_index).dsbackup);
        dbms_output.put_line('');
        vr_index := vr_tab_update.next(vr_index);
      END LOOP;
    END IF;
  END IF;
END;
