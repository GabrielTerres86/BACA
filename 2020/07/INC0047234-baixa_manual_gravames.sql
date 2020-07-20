/*INC0047234 - Baixa indevida do gravames.
Script para fazer a baixa manual para quem tiver crítica no retorno da baixa automatica com os códigos:
  - 58'Não existe ocorrência para este chassi na base do SNG'
  - 59'Não existe restrição financeira ativo cadastrado na base do sistema SNG'
*/
declare
  
  --Tipo de Dados para cursor data
  rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
  
  --Variaveis de Excecoes
  vr_exc_erro  EXCEPTION;
  
  -- Código do programa
  vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'BACA_GRVM';

  --Variaveis de Criticas
  vr_cdcritic INTEGER;
  vr_dscritic VARCHAR2(4000);
  vr_des_reto varchar2(4000);
  
  vr_cdcooper crapcop.cdcooper%TYPE;
  vr_nrdconta crapass.nrdconta%TYPE;
  vr_tpctrpro crapbpr.tpctrpro%type;
  vr_nrctrpro crapbpr.nrctrpro%type;
  vr_idseqbem crapbpr.idseqbem%type;
  
  vr_baixou number :=0;
  
  cursor cr_crapcop is
   select t.cdcooper cdcooper
     from crapprm t
     join crapcop c
       on t.cdcooper = c.cdcooper
    where t.nmsistem = 'CRED'
      and t.cdacesso = 'GRAVAM_TIPO_COMUNICACAO'
      and t.dsvlrprm = 'S'
      and c.flgativo = 1/*
      and c.cdcooper = DECODE(&pr_cdcooper,0,c.cdcooper,&pr_cdcooper)*/;
  
  cursor cr_crapbpr(vr_cdcooper in number) is  
    --pc_gravames_geracao_xml + crapgrv com a última critica de retorno in(58,59)
    SELECT bpr.rowid rowid_bpr,
           bpr.cdcooper,
           bpr.nrdconta,
           bpr.nrctrpro,
           bpr.tpctrpro,
           bpr.idseqbem,           
           --
           bpr.flblqjud,
           bpr.cdsitgrv,
           bpr.dsjstbxa,
           bpr.dtdbaixa,
           UPPER(TRIM(bpr.dschassi)) dschassi,
           bpr.tpchassi,
           upper(bpr.uflicenc) uflicenc,
           bpr.dscatbem,
           bpr.dstipbem,
           bpr.dsmarbem,
           bpr.dsbemfin,
           bpr.nrcpfbem,
           bpr.nranobem,
           bpr.nrmodbem,
           decode(bpr.ufplnovo, ' ', bpr.ufdplaca, bpr.ufplnovo) ufdplaca,
           decode(bpr.nrplnovo, ' ', bpr.nrdplaca, bpr.nrplnovo) nrdplaca,
           decode(bpr.nrrenovo, 0, bpr.nrrenava, bpr.nrrenovo) nrrenava          
      from crapass ass
          ,crawepr wpr
          ,craplcr lcr
          ,crapfin fin
          ,crapbpr bpr
      full outer 
      join crapepr epr on(epr.cdcooper = bpr.cdcooper 
                          and epr.nrdconta = bpr.nrdconta 
                          and epr.nrctremp = bpr.nrctrpro)
      join crapgrv g   on    (bpr.cdcooper = g.cdcooper 
                          and bpr.nrdconta = g.nrdconta 
                          and bpr.nrctrpro = g.nrctrpro 
                          and bpr.tpctrpro = g.tpctrpro
                          and bpr.idseqbem = g.idseqbem
                          and TRIM(UPPER(bpr.dschassi)) = TRIM(UPPER(g.dschassi))) 
      join craprto r on g.cdretgrv = r.cdretorn                                                   
    WHERE bpr.flgalien   = 1 -- Sim
      AND wpr.cdcooper   = bpr.cdcooper
      AND wpr.nrdconta   = bpr.nrdconta
      AND wpr.nrctremp   = bpr.nrctrpro
      AND wpr.insitapr IN(1,3) --Situação da Aprovação(0-em estudo/1-aprovado/2-nao aprovado/3-restricao/4-refazer/5-derivar/6-erro)
      AND wpr.cdcooper   = lcr.cdcooper
      AND wpr.cdlcremp   = lcr.cdlcremp
      AND wpr.cdcooper   = fin.cdcooper
      AND wpr.cdfinemp   = fin.cdfinemp
      AND ass.cdcooper   = bpr.cdcooper
      AND ass.nrdconta   = bpr.nrdconta
      -- 'BAIXA'
      AND  bpr.tpctrpro   in(90,99)  -- Tbm Para BENS excluidos na ADITIV
      AND  bpr.flgbaixa   = 1        -- BAIXA SOLICITADA
      AND  bpr.cdsitgrv   = 3        -- Crítica
      AND  bpr.tpdbaixa   = 'A'      -- Automatica
      AND  bpr.flblqjud  <> 1        -- Nao bloqueado judicial
      --filtro
      and bpr.cdcooper = DECODE(vr_cdcooper,0,bpr.cdcooper,vr_cdcooper)
      /*and bpr.nrdconta =  DECODE(&pr_nrdconta,0,bpr.nrdconta,&pr_nrdconta)
      and bpr.nrctrpro =  DECODE(&pr_nrctrpro,0,bpr.nrctrpro,&pr_nrctrpro)
      and (g.idseqbem = DECODE(&pr_idseqbem,0,g.idseqbem,&pr_idseqbem))
      AND (&pr_dschassi is NULL OR ','||&pr_dschassi||',' LIKE ('%,'||g.dschassi||',%'))*/
      -- RETORNO
      and r.cdprodut = 1  --Gravames
      and r.cdoperac = 'Q'--Baixa
      and g.nrseqlot = 0 --Envio online
      and r.nrtabela = 3  --Crít.Contrato - para o tipo de arquivo BAIXA
      and r.cdretorn in(58,59) --58'Não existe ocorrência para este chassi na base do SNG'
                               --59'Não existe restrição financeira ativo cadastrado na base do sistema SNG'  
      and g.dtenvgrv =(select max(grv.dtenvgrv) dtretgrv
                         from crapgrv grv
                        where grv.cdcooper = g.cdcooper
                          and grv.nrdconta = g.nrdconta
                          and grv.tpctrpro = g.tpctrpro
                          and grv.nrctrpro = g.nrctrpro
                          and grv.idseqbem = g.idseqbem
                          and TRIM(UPPER(grv.dschassi)) = TRIM(UPPER(g.dschassi))
                          and grv.cdretgrv is not null
                        group by grv.cdcooper,grv.nrdconta,grv.tpctrpro,grv.nrctrpro,grv.idseqbem,TRIM(UPPER(grv.dschassi))); 
     
begin  
  for rw_crapcop in cr_crapcop loop    
    -- Verifica se a data esta cadastrada
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF; 
    
    vr_cdcooper := rw_crapcop.cdcooper;    
                                          
    for rw_crapbpr in cr_crapbpr(vr_cdcooper) loop
      
      vr_nrdconta := rw_crapbpr.nrdconta;      
      vr_tpctrpro := rw_crapbpr.tpctrpro;
      vr_nrctrpro := rw_crapbpr.nrctrpro;
      vr_idseqbem := rw_crapbpr.idseqbem;
      vr_baixou   := 0;
                            
      -- Atualizar o contrato quando envio Manual
      BEGIN
        UPDATE crapbpr
           SET crapbpr.cdsitgrv = 4,
               crapbpr.flginclu = 0,
               crapbpr.dtdbaixa = rw_crapdat.dtmvtolt,
               crapbpr.dsjstbxa = 'Devido retorno da rotina da baixa automática apresentar critica, não existe pendencia na base do SNG( cod 58 e 59)', 
               crapbpr.tpdbaixa = 'M',
               crapbpr.dsjuscnc = NULL -- Limpar alguma justificativa de cancelamento manual anterior
         WHERE ROWID = rw_crapbpr.rowid_bpr;
         
         vr_baixou := 1;
         
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic:= 'Erro no update CRAPBPR: '||SQLERRM;
          --Gera log
          btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                    ,pr_ind_tipo_log => 1 -- Mensagem
                                    ,pr_nmarqlog     => 'gravam.log'
                                    ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                        ' - '||vr_cdprogra||' --> '||
                                                        'ALERTA: '|| vr_dscritic ||
                                                        ',Cdcooper:'||vr_cdcooper||',Nrdconta:'||vr_nrdconta||
                                                        ',Nrctrpro:'||vr_nrctrpro||',Tpctrpro:'||vr_tpctrpro||
                                                        ',Idseqbem:'||vr_idseqbem);
      END;
      
      IF nvl(vr_baixou,0) = 1 THEN
        -- Se baixa manual, gerar GRV com 300 
        BEGIN
          INSERT INTO crapgrv
                     (cdcooper
                     ,nrdconta
                     ,tpctrpro
                     ,nrctrpro
                     ,dschassi
                     ,idseqbem
                     ,nrseqlot
                     ,cdoperac
                     ,nrseqreg
                     ,cdretlot
                     ,cdretgrv
                     ,cdretctr
                     ,dtenvgrv
                     ,dtretgrv
                     ,dscatbem
                     ,dstipbem
                     ,dsmarbem
                     ,dsbemfin
                     ,nrcpfbem
                     ,tpchassi
                     ,uflicenc
                     ,nranobem
                     ,nrmodbem
                     ,ufdplaca
                     ,nrdplaca
                     ,nrrenava)
               VALUES(vr_cdcooper
                     ,vr_nrdconta
                     ,rw_crapbpr.tpctrpro        
                     ,rw_crapbpr.nrctrpro        
                     ,rw_crapbpr.dschassi
                     ,rw_crapbpr.idseqbem  
                     ,0        --nrseqlot
                     ,3        --cdoperac
                     ,0        --nrseqreg
                     ,0        --cdretlot
                     ,300      --cdretgrv
                     ,0        --cdretctr
                     ,SYSDATE  --dtenvgrv
                     ,SYSDATE  --dtretgrv
                     ,rw_crapbpr.dscatbem 
                     ,rw_crapbpr.dstipbem 
                     ,rw_crapbpr.dsmarbem 
                     ,rw_crapbpr.dsbemfin 
                     ,rw_crapbpr.nrcpfbem 
                     ,rw_crapbpr.tpchassi 
                     ,rw_crapbpr.uflicenc 
                     ,rw_crapbpr.nranobem 
                     ,rw_crapbpr.nrmodbem 
                     ,rw_crapbpr.ufdplaca 
                     ,rw_crapbpr.nrdplaca 
                     ,rw_crapbpr.nrrenava);
        EXCEPTION
          WHEN OTHERS THEN
            vr_baixou   := 0;
            vr_dscritic := 'Erro no insert CRAPGRV: '||SQLERRM;
            --Gera log
            btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                      ,pr_ind_tipo_log => 1 -- Mensagem
                                      ,pr_nmarqlog     => 'gravam.log'
                                      ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                          ' - '||vr_cdprogra||' --> '||
                                                          'ALERTA: '|| vr_dscritic ||
                                                          ',Cdcooper:'||vr_cdcooper||',Nrdconta:'||vr_nrdconta||
                                                          ',Nrctrpro:'||vr_nrctrpro||',Tpctrpro:'||vr_tpctrpro||
                                                          ',Idseqbem:'||vr_idseqbem);          
        END;
      END IF;
      
      --Gera log
      IF nvl(vr_baixou,0) = 1 THEN
        vr_dscritic := 'baixa manual do gravames ';
        btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                  ,pr_ind_tipo_log => 1 -- Mensagem
                                  ,pr_nmarqlog     => 'gravam.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' - '||vr_cdprogra||' --> '||
                                                      'SUCESSO: '|| vr_dscritic ||
                                                      ',Cdcooper:'||vr_cdcooper||',Nrdconta:'||vr_nrdconta||
                                                      ',Nrctrpro:'||vr_nrctrpro||',Tpctrpro:'||vr_tpctrpro||
                                                      ',Idseqbem:'||vr_idseqbem);
        --
        COMMIT;
        --
      ELSE
        -- Desfazer alterações
        ROLLBACK;  
      END IF;                         
    end loop;    
  end loop;
EXCEPTION
  WHEN vr_exc_erro THEN
    -- Desfazer alterações
    ROLLBACK;  
    --Erro
    vr_dscritic:= 'Erro no BACA para baixa do gravames manual --> '|| vr_dscritic;
    -- Gera log
    btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_nmarqlog     => 'gravam.log'
                              ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                  ' - '||vr_cdprogra||' --> '||
                                                  'ERRO: ' || vr_dscritic  ||',Cdoperad:'||1||
                                                  ',Cdcooper:'||vr_cdcooper||',Nrdconta:'||vr_nrdconta||
                                                  ',Nrctrpro:'||vr_nrctrpro||',Tpctrpro:'||vr_tpctrpro||
                                                  ',Idseqbem:'||vr_idseqbem);  
  WHEN OTHERS THEN
    -- Desfazer alterações
    ROLLBACK; 
    -- Erro
    vr_dscritic:= 'Erro no BACA para baixa do gravames manual --> '|| SQLERRM;
    -- Gera log
    btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_nmarqlog     => 'gravam.log'
                              ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                  ' - '||vr_cdprogra||' --> '||
                                                  'ERRO: ' || vr_dscritic  ||',Cdoperad:'||1||
                                                  ',Cdcooper:'||vr_cdcooper||',Nrdconta:'||vr_nrdconta||
                                                  ',Nrctrpro:'||vr_nrctrpro||',Tpctrpro:'||vr_tpctrpro||
                                                  ',Idseqbem:'||vr_idseqbem);
end;
