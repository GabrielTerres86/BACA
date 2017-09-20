CREATE OR REPLACE PROCEDURE CECRED.pc_crps249_2(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa solicitada
                                        ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data do movimento
                                        ,pr_nmestrut  IN craphis.nmestrut%TYPE --> Nome da tabela
                                        ,pr_cdhistor  IN craphis.cdhistor%TYPE --> Código do histórico
                                        ,pr_tpctbcxa  IN craphis.tpctbcxa%TYPE --> Tipo de conta
                                        ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                        ,pr_dscritic OUT VARCHAR2) IS          --> Texto de erro/critica encontrada is

/* ..........................................................................

   Programa: pc_crps249_2 (antigo Fontes/crps249_2.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Novembro/98                         Ultima atualizacao: 20/09/20017

   Dados referentes ao programa:

   Frequencia: Diario. Exclusivo.
   Objetivo  : Atende a solicitacao .
               Gerar arquivo para contabilidade.
               Ordem do programa na solicitacao .

   Alteracoes: 13/06/2000 - Tratar quantidade dos lancamentos (Odair)

               25/04/2001 - Tratar pac ate 99 (Edson).

               30/06/2005 - Alimentado campo cdcooper da tabela craprej (Diego).

               15/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               22/02/2013 - Conversão Progress >> Oracle PL/Sql (Daniel - Supero)
               
               20/09/2017 - Ajustar para contabilizar a tarifa dos convenios proprios 
                            no PA do cooperado ou se for TAA no PA do TAA (Lucas Ranghetti #689991)
............................................................................. */
  -- Variável para armazenar o nome do programa
  vr_cdprogra      crapprg.cdprogra%type;
  -- Variáveis para criação de cursor dinâmico
  vr_num_cursor    number;
  vr_num_retor     number;
  vr_cursor        varchar2(32000);
  -- Variáveis para retorno do cursor dinâmico
  vr_cdagenci      craprej.cdagenci%type;
  vr_vllanmto      craprej.vllanmto%type;
  vr_qtlanmto      craprej.nrseqdig%type;
  
  CURSOR cr_craplft IS 
    SELECT DECODE(lft.cdagenci,
                  90, NVL(ass.cdagenci, lft.cdagenci),
                  91, NVL(DECODE(lft.cdagetfn,0,NULL,lft.cdagetfn), ass.cdagenci),
                  lft.cdagenci) cdagenci_fatura,
           lft.cdagenci,
       SUM(lft.vllanmto) vllanmto,
       COUNT(lft.vllanmto) qtlanmto
  FROM craplft lft,
       crapass ass
 WHERE lft.cdcooper = pr_cdcooper
   AND lft.dtmvtolt = pr_dtmvtolt
   AND lft.cdhistor = pr_cdhistor
   AND ass.cdcooper = lft.cdcooper
   AND ass.nrdconta = lft.nrdconta
   GROUP BY DECODE(lft.cdagenci,
                  90, NVL(ass.cdagenci, lft.cdagenci),
                  91, NVL(DECODE(lft.cdagetfn,0,NULL,lft.cdagetfn), ass.cdagenci),
                  lft.cdagenci),
            lft.cdagenci
   ORDER BY 1;
 
begin
  vr_cdprogra := 'CRPS249';  /* igual ao origem */
  -- Definição da query do cursor dinâmico
  -- Faz a leitura das informações já agrupadas, evitando processamento duplicado
  if pr_tpctbcxa in (2, 3) then
    /* Detalhamento por agencia */
    
    FOR rw_craplft IN cr_craplft LOOP
        
      BEGIN
          INSERT INTO craprej
            (cdpesqbb,
             cdagenci,
             cdhistor,
             dtmvtolt,
             vllanmto,
             nrseqdig,
             dtrefere,
             cdcooper,
             nrdocmto)
          VALUES
            (vr_cdprogra,
             rw_craplft.cdagenci_fatura, -- Agencia da conta/Terminal
             pr_cdhistor,
             pr_dtmvtolt,
             rw_craplft.vllanmto,
             rw_craplft.qtlanmto,
             pr_nmestrut,
             pr_cdcooper,
             rw_craplft.cdagenci); -- Agencia Orignal
        EXCEPTION
          WHEN OTHERS THEN 
            pr_cdcritic := 0;
            pr_dscritic := 'Erro ao criar CRAPREJ para agência '||rw_craplft.cdagenci_fatura||': '||sqlerrm;
            ROLLBACK;
            RETURN;
        END;
    
    END LOOP;   
  else
    /* Total geral (utilizar agência = 0 ao gravar as informações) */
    vr_cursor := 'select 0,'||
                       ' sum(vllanmto),'||
                       ' count(vllanmto)'||
                  ' from '||pr_nmestrut||
                 ' where cdcooper = '||pr_cdcooper||
                   ' and dtmvtolt = to_date('''||to_char(pr_dtmvtolt, 'ddmmyyyy')||''', ''ddmmyyyy'')'||
                   ' and cdhistor = '||pr_cdhistor;
                   
    -- Cria cursor dinâmico
    vr_num_cursor := dbms_sql.open_cursor;
    -- Comando Parse
    dbms_sql.parse(vr_num_cursor, vr_cursor, 1);
    -- Definindo Colunas de retorno
    dbms_sql.define_column(vr_num_cursor, 1, vr_cdagenci);
    dbms_sql.define_column(vr_num_cursor, 2, vr_vllanmto);
    dbms_sql.define_column(vr_num_cursor, 3, vr_qtlanmto);
    -- Execução do select dinamico
    vr_num_retor := dbms_sql.execute(vr_num_cursor);
    -- Abre o cursor e começa a processar os registros
    loop
      -- Verifica se há alguma linha de retorno do cursor
      vr_num_retor := dbms_sql.fetch_rows(vr_num_cursor);
      if vr_num_retor = 0 THEN
        -- Se o cursor dinamico está aberto
        IF dbms_sql.is_open(vr_num_cursor) THEN
          -- Fecha o mesmo
          dbms_sql.close_cursor(vr_num_cursor);
        END if;
        exit;
      else
        -- Carrega variáveis com o retorno do cursor
        dbms_sql.column_value(vr_num_cursor, 1, vr_cdagenci);
        dbms_sql.column_value(vr_num_cursor, 2, vr_vllanmto);
        dbms_sql.column_value(vr_num_cursor, 3, vr_qtlanmto);
        -- Inclui as informações na tabela de rejeitados
        BEGIN
          insert into craprej (cdpesqbb,
                               cdagenci,
                               cdhistor,
                               dtmvtolt,
                               vllanmto,
                               nrseqdig,
                               dtrefere,
                               cdcooper)
          values (vr_cdprogra,
                  vr_cdagenci,
                  pr_cdhistor,
                  pr_dtmvtolt,
                  vr_vllanmto,
                  vr_qtlanmto,
                  pr_nmestrut,
                  pr_cdcooper);
        exception
          when others then
            pr_cdcritic := 0;
            pr_dscritic := 'Erro ao criar CRAPREJ para agência '||vr_cdagenci||': '||sqlerrm;
            rollback;
            return;
        end;
      end if;
    end loop;

    -- Se o cursor dinamico está aberto
    IF dbms_sql.is_open(vr_num_cursor) THEN
      -- Fecha o mesmo
      dbms_sql.close_cursor(vr_num_cursor);
    END if;
  end if;
  

exception
  when others then
    pr_dscritic := 'Erro PC_CRPS249_2: '||SQLERRM;
end;
/
