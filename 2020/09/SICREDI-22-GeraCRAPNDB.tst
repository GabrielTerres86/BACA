PL/SQL Developer Test script 3.0
474
-- Created on 22/09/2020 by T0032500 
    DECLARE
      --Variaveis de Erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);

      -- Variaveis para verificao termino ciclo de pagamentos
      vr_dtultexec     DATE;

      -- Envio de email
      vr_texto_email     varchar2(4000);
      vr_endereco_email  crapprm.dsvlrprm%TYPE;

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      CURSOR cr_crapcop  IS
        SELECT crapcop.cdcooper
              ,crapcop.nmrescop
              ,crapcop.cdagesic
          FROM crapcop
          WHERE crapcop.cdcooper <> 3;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Cursor de lançamentos automáticos
      CURSOR cr_craplau ( pr_cdcooper IN craplau.cdcooper%TYPE) IS
        SELECT craplau.cdcooper
               ,craplau.cdagenci
               ,craplau.dtmvtopg
               ,craplau.cdtiptra
               ,craplau.vllanaut
               ,craplau.dttransa
               ,craplau.nrdocmto
               ,craplau.dslindig
               ,craplau.dsorigem
               ,craplau.idseqttl
               ,craplau.nrdconta
               ,craplau.dscedent
               ,craplau.hrtransa
               ,craplau.cdhistor
               ,craplau.cdseqtel
               ,craphis.cdhistor||'-'||craphis.dshistor dshistor
               ,craplau.nrseqagp
               ,craplau.dtmvtolt
               ,craplau.nrseqdig
               ,craplau.ROWID
               ,craplau.progress_recid
               ,craplau.nrcrcard
               ,craplau.dscodbar
               ,craplau.cdempres
               ,craplau.idlancto
               ,crapass.nrctacns
               ,crapass.cdagenci cdagenci_ass
        FROM   craplau,
               craphis,
               crapass
        WHERE craplau.cdcooper = craphis.cdcooper
          AND craplau.cdhistor = craphis.cdhistor
          AND crapass.cdcooper = craplau.cdcooper
          AND crapass.nrdconta = craplau.nrdconta
          AND craplau.cdcooper = pr_cdcooper
          AND craplau.dtmvtopg >= '25/09/2020'
          AND craplau.insitlau = 1
          AND craplau.cdhistor = 1019;
          rw_craplau cr_craplau%ROWTYPE;

/**************************************************/

         /* Consulta de convênios */
         PROCEDURE gerandb (pr_cdcooper IN crapcop.cdcooper%TYPE  -- Código da Cooperativa
                              ,pr_cdhistor IN craphis.cdhistor%TYPE  -- Código do Histórico
                              ,pr_nrdconta IN crapass.nrdconta%TYPE  -- Numero da Conta
                              ,pr_cdrefere IN crapatr.cdrefere%TYPE  -- Código de Referência
                              ,pr_vllanaut IN craplau.vllanaut%TYPE  -- Valor Lancamento
                              ,pr_cdseqtel IN craplau.cdseqtel%TYPE  -- Código Sequencial
                              ,pr_nrdocmto IN craplau.nrdocmto%TYPE  -- Número do Documento
                              ,pr_cdagesic IN crapcop.cdagesic%TYPE  -- Agência Sicredi
                              ,pr_nrctacns IN crapass.nrctacns%TYPE  -- Conta do Consórcio
                              ,pr_cdagenci IN crapass.cdagenci%TYPE  -- Codigo do PA
                              ,pr_cdempres IN craplau.cdempres%TYPE  -- Empresa sicredi
                              ,pr_idlancto IN craplau.idlancto%TYPE  -- Código lancamento                      
                              ,pr_codcriti IN INTEGER                -- Código do erro
                              ,pr_cdcritic OUT INTEGER               -- Código do erro
                              ,pr_dscritic OUT VARCHAR2) IS          -- Descricao do erro
         BEGIN
           DECLARE
       
             -- VARIAVEIS DE ERRO
             vr_cdcritic crapcri.cdcritic%TYPE := 0;
             vr_dscritic VARCHAR2(4000);
       
             -- VARIAVEIS DE EXCECAO
             vr_exc_erro EXCEPTION;
       
             -- DIVERSAS
             vr_cdcooper crapcop.cdcooper%TYPE;
             vr_cdagenci crapass.cdagenci%TYPE;
             vr_cdhistor craplau.cdhistor%TYPE;
             vr_nrdconta VARCHAR2(50);
             vr_dstexarq VARCHAR2(160) := 'F';
             vr_auxcdcri VARCHAR2(50);
             vr_dtmvtolt craplau.dtmvtolt%TYPE;
             vr_flgsicre INTEGER := 0;
             vr_cdseqtel VARCHAR2(60);
             vr_cdrefere VARCHAR2(25);
             vr_qtdigito INTEGER;      
             vr_cdempres varchar2(10);
       
             -- VARIAVEIS PARA CAULCULO DE DIGITOS A COMPLETAR COM ZEROS OU ESPAÇOS
             vr_resultado VARCHAR2(25);
       
             -- CURSOR GENÉRICO DE CALENDÁRIO
             rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
       
             /* Tributos do convenio sicredi */
             CURSOR cr_crapscn IS
               SELECT scn.cdempres,
                      scn.qtdigito,
                      scn.tppreenc
                 FROM crapscn scn
                WHERE scn.cdempres = pr_cdempres;
              rw_crapscn cr_crapscn%ROWTYPE;
       
              CURSOR cr_tbconv_det_agendamento(pr_idlancto IN craplau.idlancto%TYPE) IS
              SELECT t.cdlayout
                    ,t.tppessoa_dest
                    ,t.nrcpfcgc_dest
               FROM tbconv_det_agendamento t
              WHERE t.idlancto = pr_idlancto;
              rw_tbconv_det_agendamento cr_tbconv_det_agendamento%ROWTYPE;  
              
              --PJ565.2
              CURSOR cr_crapatr (pr_cdcooper  IN crapatr.cdcooper%TYPE,
                                 pr_cdhistor  IN crapatr.cdhistor%TYPE,
                                 pr_nrdconta  IN crapatr.nrdconta%TYPE,
                                 pr_cdrefere  IN crapatr.cdrefere%TYPE) IS
              SELECT nvl(trim(a.cdseqtel),a.cdrefere) cdseqtel -- seqtel preenchido é o mesmo cdrefere
                FROM crapatr a                           -- porém com a formatacação correta passada 
               WHERE a.cdcooper = pr_cdcooper            -- pelo convenio
                 AND a.cdhistor = pr_cdhistor
                 AND a.nrdconta = pr_nrdconta
                 AND a.cdrefere = pr_cdrefere;
               rw_crapatr  cr_crapatr%rowtype;
       
             /*PROCEDIMENTOS E FUNCOES INTERNAS*/
             FUNCTION fn_verifica_ult_dia(pr_cdcooper crapcop.cdcooper%TYPE, pr_dtrefere  IN DATE) RETURN DATE IS
             BEGIN
               DECLARE
                 CURSOR cr_ultdia(pr_cdcooper crapcop.cdcooper%TYPE) IS
                   SELECT TRUNC(add_months(dat.dtmvtolt,12),'RRRR')-1 AS ultimdia
                     FROM crapdat dat
                    WHERE dat.cdcooper = pr_cdcooper;
       
                 rw_ultdia cr_ultdia%ROWTYPE;
       
               BEGIN
                 IF pr_dtrefere IS NOT NULL THEN
       
                    OPEN cr_ultdia(pr_cdcooper => pr_cdcooper);
       
                    FETCH cr_ultdia INTO rw_ultdia;
       
                    IF cr_ultdia%FOUND THEN
                      CLOSE cr_ultdia;
       
                      IF pr_dtrefere = rw_ultdia.ultimdia THEN
                         rw_ultdia.ultimdia := rw_ultdia.ultimdia + 1;
                         RETURN gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper, pr_dtmvtolt => rw_ultdia.ultimdia);
                      END IF;
                    ELSE
                      CLOSE cr_ultdia;
                      RETURN pr_dtrefere;
                    END IF;
                 END IF;
       
                 RETURN pr_dtrefere;
               END;
             END fn_verifica_ult_dia;
       
           BEGIN
             -- LEITURA DO CALENDÁRIO DA COOPERATIVA
             OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
             FETCH btch0001.cr_crapdat
               INTO rw_crapdat;
             -- SE NÃO ENCONTRAR
             IF btch0001.cr_crapdat%NOTFOUND THEN
               -- FECHAR O CURSOR POIS EFETUAREMOS RAISE
               CLOSE btch0001.cr_crapdat;
               -- MONTAR MENSAGEM DE CRITICA
               vr_cdcritic := 1;
               RAISE vr_exc_erro;
             ELSE
               -- APENAS FECHAR O CURSOR
               CLOSE btch0001.cr_crapdat;
             END IF;
       
             -- CODIGO DE HISTORICO
             vr_cdhistor := pr_cdhistor;
       
             -- CODIGO DE ERRO
             vr_cdcritic := pr_codcriti;
                       
             IF pr_cdhistor IN(1019) THEN
               vr_flgsicre := 1; -- HISTORICOS DO CONSORCIO SICREDI E DEB. AUTOMATICO
             
             ELSE
               -- LEITURA PARA ENCONTRAR DETALHE DO AGENDAMENTO
               OPEN cr_tbconv_det_agendamento(pr_idlancto => pr_idlancto);
               
               FETCH cr_tbconv_det_agendamento INTO rw_tbconv_det_agendamento;
               
               -- SE NÃO ENCONTRAR
               IF cr_tbconv_det_agendamento%NOTFOUND THEN
                 -- FECHAR O CURSOR POIS EFETUAREMOS RAISE
                 CLOSE cr_tbconv_det_agendamento;
                 -- MONTAR MENSAGEM DE CRITICA
                 vr_cdcritic := 597;
                 RAISE vr_exc_erro;
               ELSE
                 -- APENAS FECHAR O CURSOR
                 CLOSE cr_tbconv_det_agendamento;
               END IF;
               
             END IF;
       
             vr_auxcdcri := vr_cdcritic;
             -- CONSULTA DE CONVENIOS
             conv0001.pc_lotee_1a(pr_cdcooper => pr_cdcooper   -- Código da Cooperativa
                                 ,pr_cdhistor => vr_cdhistor   -- Código do Histórico
                                 ,pr_cdagenci => vr_cdagenci   -- Código da Agência
                                 ,pr_codcoope => vr_cdcooper   -- Código da Cooperativa
                                 ,pr_cdcritic => vr_cdcritic   -- Código do erro
                                 ,pr_dscritic => vr_dscritic); -- Descricao do erro
       
             -- VERIFICA SE HOUVE ERRO NA CONSULTA DE CONVENIOS
             IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
               RAISE vr_exc_erro;
             END IF;
       
             vr_cdcritic := vr_auxcdcri;
       
             -- VERIFICA CODIGO DA COOPERATIVA
             IF vr_cdcooper = 8888 AND vr_flgsicre = 0 THEN
               vr_cdcritic := 472; -- FALTA TABELA DE CONVENIO
             ELSE
               -- VERIFICA HISTORICO
               IF pr_cdhistor = 48 THEN -- RECEBIMENTO CASAN AUTOMATICO
                 -- CODIGO DA AGENCIA
                 vr_cdagenci := 1294;
               END IF;
       
               -- VERIFICA SE COOPERATIVA É NULA
               IF vr_cdcooper IS NULL THEN
                 vr_nrdconta := gene0002.fn_mask(pr_nrdconta, '99999999');
               ELSE
                 vr_nrdconta := gene0002.fn_mask(vr_cdcooper, '9999') || gene0002.fn_mask(pr_nrdconta, '99999999');
               END IF;
       
             /*  -- Buscar referencia formatada 
               pc_retorna_referencia_conv(pr_cdconven => 0, 
                                          pr_cdhistor => pr_cdhistor, 
                                          pr_cdrefere => pr_cdrefere, 
                                          pr_nrrefere => vr_cdrefere, 
                                          pr_qtdigito => vr_qtdigito, 
                                          pr_cdcritic => vr_cdcritic, 
                                          pr_dscritic => vr_dscritic);*/
                                          
               OPEN cr_crapatr(pr_cdcooper,pr_cdhistor,pr_nrdconta,pr_cdrefere);
               FETCH cr_crapatr INTO rw_crapatr;
               
               IF cr_crapatr%NOTFOUND THEN
                 vr_cdrefere := pr_cdrefere;
               ELSE
                 vr_cdrefere := rw_crapatr.cdseqtel;
               END IF;
       
               CLOSE cr_crapatr;   
       
               -- VERIFICAÇÃO DE HISTÓRICOS
                 vr_dstexarq := vr_dstexarq || RPAD(vr_cdrefere,25,' ');
       
               -- VERIFICACAO DE CRITICA
                 vr_auxcdcri := '99';
       
               -- Verificação de data se for chamado via tela ou pelo processo
               IF rw_crapdat.inproces = 1 THEN
                 vr_dtmvtolt := rw_crapdat.dtmvtolt;
               ELSE
                 vr_dtmvtolt := rw_crapdat.dtmvtopr;
               END IF;
       
               /* Pega proximo dia util se for ultimo dia do ano ou devolve
                  a propria data passada como referencia */
               vr_dtmvtolt := fn_verifica_ult_dia(pr_cdcooper, vr_dtmvtolt);
       
               IF vr_flgsicre = 1 THEN -- CONSORCIO SICREDI / DEB. AUTOMATICO
                 -- tributos do convenio SICREDI
                 OPEN cr_crapscn;
                 FETCH cr_crapscn INTO rw_crapscn;
                 -- SE NAO ENCONTRAR
                 IF cr_crapscn%NOTFOUND THEN
                   --APENAS FECHAR O CURSOR
                   CLOSE cr_crapscn;
                 END IF;
       
                 -- fazer o calculo de quantos digitos devera completar com espacos ou zeros
                 -- Atribuir resultado com a quantidade de digitos da base
                 IF rw_crapscn.tppreenc = 1 THEN
                   IF rw_crapscn.qtdigito <> 0 THEN
                     vr_resultado := LPAD(pr_nrdocmto,rw_crapscn.qtdigito,'0') ;
                   ELSE
                     vr_resultado := LPAD(pr_nrdocmto,25,'0') ;
                   END IF;
                 ELSIF rw_crapscn.tppreenc = 2 THEN
                   IF rw_crapscn.qtdigito <> 0 THEN
                     vr_resultado := RPAD(pr_nrdocmto,rw_crapscn.qtdigito,'0') ;
                   ELSE
                     vr_resultado := RPAD(pr_nrdocmto,25,'0') ;
                   END IF;
                 ELSE
                   IF rw_crapscn.qtdigito <> 0 THEN
                     vr_resultado :=  RPAD(pr_nrdocmto,rw_crapscn.qtdigito,' ');
                   ELSE
                     vr_resultado := RPAD(pr_nrdocmto,25,' ') ;
                   END IF;
                 END IF;
       
                 IF length(vr_resultado) < 25 THEN
                   -- completar com 25 espaços se resultado for inferior a 25 poscoes
                   vr_resultado := RPAD(vr_resultado,25,' ');
                 END IF;
       
                 /* Se for o convenio 045 - 14 BRT CELULAR - FEBRABAN e tiver 11 posicoes, devemos 
                    adicionar um hifen para completar 12 posicoes ex:(40151016407-) chamado 453337 */
                 IF pr_cdempres = '045' AND LENGTH(pr_nrdocmto) = 11 THEN
                   vr_resultado := RPAD(pr_nrdocmto,12,'-') || RPAD(' ',13,' ');
                 END IF; 
               
                 -- Se existir cdseqtel irá gravar na variavel
                 IF trim(pr_cdseqtel) IS NOT NULL THEN
                   vr_cdseqtel := RPAD(pr_cdseqtel,60);
                 ELSE
                   vr_cdseqtel := RPAD(' ',60);
                 END IF;
       
                 vr_cdagenci :=  SUBSTR(gene0002.fn_mask(pr_cdagenci,'999'),2,2);
       
                 IF rw_crapscn.cdempres IN('RQ','5Y') THEN
                   vr_cdempres:= 'RL';
                 ELSE
                   vr_cdempres:= rw_crapscn.cdempres;
                 END IF;
       
                 vr_dstexarq := 'F' || vr_resultado ||
                                gene0002.fn_mask(pr_cdagesic,'9999') ||
                                gene0002.fn_mask(pr_nrctacns,'999999') ||
                                gene0002.fn_mask('','zzzzzzzz') ||
                                TO_CHAR(vr_dtmvtolt,'yyyy') || TO_CHAR(vr_dtmvtolt,'mm') ||
                                TO_CHAR(vr_dtmvtolt,'dd') ||
                                gene0002.fn_mask(to_char(pr_vllanaut*100),'999999999999999') ||
                                vr_auxcdcri || vr_cdseqtel ||
                                RPAD(' ',16) || gene0002.fn_mask(vr_cdagenci,'99') ||
                                TRIM(vr_cdempres) ||
                                RPAD(' ',10 - length(TRIM(vr_cdempres))) || '0';
                                
               ELSIF rw_tbconv_det_agendamento.cdlayout = 5 THEN
                 
                 vr_dstexarq := vr_dstexarq ||
                                gene0002.fn_mask(vr_cdagenci,'9999') ||
                                vr_nrdconta ||
                                RPAD(' ', 14 - LENGTH(vr_nrdconta), ' ') ||
                                TO_CHAR(vr_dtmvtolt,'yyyy') ||
                                TO_CHAR(vr_dtmvtolt,'mm') ||
                                TO_CHAR(vr_dtmvtolt,'dd') ||
                                gene0002.fn_mask((pr_vllanaut * 100),'999999999999999') ||
                                vr_auxcdcri ||                          
                                RPAD(pr_cdseqtel,60) ||
                                nvl(to_char(rw_tbconv_det_agendamento.tppessoa_dest,'fm0'),' ') ||
                                nvl(to_char(rw_tbconv_det_agendamento.nrcpfcgc_dest,'fm000000000000000'),'               ') ||
                                RPAD(' ',4)                         
                                || '0';
                                                           
               ELSE
       
                 vr_dstexarq := vr_dstexarq ||
                                gene0002.fn_mask(vr_cdagenci,'9999') ||
                                vr_nrdconta ||
                                RPAD(' ', 14 - LENGTH(vr_nrdconta), ' ') ||
                                TO_CHAR(vr_dtmvtolt,'yyyy') ||
                                TO_CHAR(vr_dtmvtolt,'mm') ||
                                TO_CHAR(vr_dtmvtolt,'dd') ||
                                gene0002.fn_mask((pr_vllanaut * 100),'999999999999999') ||
                                vr_auxcdcri || RPAD(pr_cdseqtel,80) || '0';
               END IF;
       
               BEGIN
                 -- INSERE REGISTRO NA TABELA DE REGISTROS DE DEBITO EM CONTA NAO EFETUADOS
                 INSERT INTO
                   crapndb(
                     dtmvtolt,
                     nrdconta,
                     cdhistor,
                     flgproce,
                     cdcooper,
                     dstexarq
                   )VALUES(
                     vr_dtmvtolt,
                     pr_nrdconta,
                     pr_cdhistor,
                     0,
                     pr_cdcooper,
                     vr_dstexarq
                   );
       
               -- VERIFICA SE HOUVE PROBLEMA NA INCLUSÃO DO REGISTRO
               EXCEPTION
                 WHEN OTHERS THEN
                   vr_dscritic := 'Problema ao inserir na tabela CRAPNDB: ' || sqlerrm;
                   RAISE vr_exc_erro;
               END;
       
             END IF;
       
           -- VERIFICA SE HOUVE EXCECAO
           EXCEPTION
             WHEN vr_exc_erro THEN
                pr_cdcritic:= vr_cdcritic;
                pr_dscritic:= vr_dscritic;
              WHEN OTHERS THEN
                pr_cdcritic:= 0;
                pr_dscritic:= 'Erro na rotina gerandb. ' || sqlerrm;
           END;
         END gerandb;

/********************************************************/
    BEGIN

      FOR rw_crapcop IN cr_crapcop LOOP

         dbms_output.put_line('gera crapndb: -> '||rw_crapcop.cdcooper);


          FOR rw_craplau IN cr_craplau ( pr_cdcooper => rw_crapcop.cdcooper) LOOP

              
              gerandb(pr_cdcooper => rw_craplau.cdcooper -- CÓDIGO DA COOPERATIVA
                     ,pr_cdhistor => rw_craplau.cdhistor -- CÓDIGO DO HISTÓRICO
                     ,pr_nrdconta => rw_craplau.nrdconta -- NUMERO DA CONTA
                     ,pr_cdrefere => rw_craplau.nrdocmto -- CÓDIGO DE REFERÊNCIA
                     ,pr_vllanaut => rw_craplau.vllanaut -- VALOR LANCAMENTO
                     ,pr_cdseqtel => rw_craplau.cdseqtel -- CÓDIGO SEQUENCIAL
                     ,pr_nrdocmto => rw_craplau.nrdocmto         -- NÚMERO DO DOCUMENTO
                     ,pr_cdagesic => rw_crapcop.cdagesic -- AGÊNCIA SICREDI
                     ,pr_nrctacns => rw_craplau.nrctacns -- CONTA DO CONSÓRCIO
                     ,pr_cdagenci => rw_craplau.cdagenci_ass -- CODIGO DO PA
                     ,pr_cdempres => rw_craplau.cdempres -- CODIGO EMPRESA SICREDI
                     ,pr_idlancto => rw_craplau.idlancto -- CÓDIGO DO LANCAMENTO
                     ,pr_codcriti => 739 -- CÓDIGO DO ERRO INSUFICIENCIA DE SALDO
                     ,pr_cdcritic => vr_cdcritic -- CÓDIGO DO ERRO
                     ,pr_dscritic => vr_dscritic); -- DESCRICAO DO ERRO


          END LOOP; -- Craplau
          commit;
      END LOOP; -- Crapcop

    EXCEPTION
      WHEN vr_exc_erro THEN
        dbms_output.put_line('Erro na execução : vr_exc_erro '||SQLERRM);
      WHEN OTHERS THEN
        -- Erro
        dbms_output.put_line('Erro na execução : '||SQLERRM);

   END;
0
0
