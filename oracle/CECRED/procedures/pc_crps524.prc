CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS524 (pr_cdcooper IN crapcop.cdcooper%type   --> Codigo da cooperativa
                                              ,pr_flgresta IN PLS_INTEGER             --> Flag padrão para utilização de restart
                                              ,pr_cdagenci IN PLS_INTEGER             --> Codigo do PA
                                              ,pr_cdoperad IN VARCHAR2                --> Codigo do operador
                                              ,pr_nmdatela IN VARCHAR2                --> Nome da tela
                                              ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                              ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                              ,pr_cdcritic OUT crapcri.cdcritic%type  --> Codigo de critica
                                              ,pr_dscritic OUT VARCHAR2)              --> Descricao de critica
AS 
    /* ............................................................................
      
    Programa: PC_CRPS524 (Antigo Fontes/crps524.p)
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Paulo
    Data    : Junho/2009                         Ultima alteracao: 24/07/2015
    
    Dados referentes ao programa:
    
    Frequencia: Mensal 
    Objetivo  : Gerar base informacoes gerenciais dos produtos
    
    Alteracoes:
               23/09/2009 - Precise - Paulo - criados campos novos de
                            beneficios, seguros, e cartoes
    
               06/10/2009 - Precise Guilherme - Tratar dados REDECARD(444)
    
               27/10/2009 - Alterado para utilizar a BO b1wgen0045.p que sera
                            agrupadora das funcoes compartilhadas com o CRPS524
                            Guilherme - Precise
    
               18/02/2010 - Alterar nome do handle (Magui).
               
               09/04/2010 - Incluido valores para os campos novos da tabela 
                            crapgpr (Elton).
               
               11/05/2010 - Incluido valores para o novo campo
                            crapgpr.qtassrda (Irlan).
                            
               13/05/2010 - Incluido novo parametro na procedure 
                            valor-convenios (Elton).
               
               19/05/2010 - Incluido novos campos na tabela crapgpr
                            (qtasunet e qtasucxa)
                            (Irlan)
                
               17/06/2010 - Incluido novos campos(Desc.Cheque, Desc. Titulo,
                            Pagamentos TAA).(Irlan) 
               
               15/07/2010 - alterado forma de consulta dos campos qtassoci e
                            qtasscot. Buscar informação da CRAPGER.(Irlan)
                            
               19/08/2010 - Incluido os campos de Depositos no TAA 
                            qtdepcxa e vldepcxa (Irlan).
                            
               31/08/2010 - Incluido novo campo em Participações: qtchcomp 
                            Quantidade de Cheques Compensados
                            (Irlan).
                            
               01/09/2010 - Incluido informações de Caixa On-line
                            qttiponl e qtchconl (Irlan).
                            
               18/10/2010 - Alterado forma de busca dos dados partindo da 
                            tabela crapass;
                          - Acertado informações de cobrança trazendo dados
                            para cada PAC;
                          - Incluido indice na Temp-Table tt-participacao 
                            (Elton).
                            
               28/10/2010 - Inclusão do historico 918(Saque) devido ao 
                            TAA compartilhado (Henrique).
                            
               15/03/2011 - Inclusao das variaveis ret_vlcancel e 
                            ret_qtcancel na chamada da procedure 
                            limite-cartao-credito (Vitor)
    
               23/05/2011 - Inclusao historico 376-Transferencia TAA(Mirtes)
               
               13/09/2011 - Incluido Cobranca Registrada e DDA (Adriano).
               
               18/10/2011 - Movido rotina carrega-dda para b1wgen0087 (Rafael).
               
               10/11/2011 - Ajuste no for each do crapcob (Gabriel).
               
               17/01/2012 - Separar leitura de titulos por emissao dos
                            titulos pagos. (Rafael)
                            
               14/02/2012 - Separar leitura de acessos unicos à internet e
                            extratos emitidos. (Rafael)
                            
               20/03/2012 - Subistituido o parametro aux_qtassaut pela table
                            crawass na chamada da procedure valor-convenios
                            (Adriano).
                           
               25/04/2012 - Incluido novo parametro na chamada da  procedure
                            limite-cartao-credito.(David Kruger).
                            
               12/06/2012 - Implementação de melhorias.(David Kruger).
               
               14/08/2012 - Remoção do historico 920, e inclusão do historico 555
                            para uso na internet, incluido somatoria de TED
                            (Lucas R.).
                            
               21/02/2013 - Alteração nos parametros da procedure de seguros
                            (David Kruger).
    
               25/03/2013 - Armazenar valores sobre a transferencia 
                            intercooperativa (Gabriel). 
                            
               09/04/2013 - Ajuste de desempenho (Gabriel).             
               
               09/05/2013 - Ajuste de totalização da cobranca BB. (Rafael)
               
               27/11/2013 - Ajustes para migracao da Acredicoop e tratamento
                            para considerar movimentacoes de contas demitidas
                            (Evandro).
                            
               09/12/2013 - Ajustar posicao da flag flg_qtasscob (David).

               24/10/2013 - Conversao Progress => PL/SQL (Douglas Pagel / Andrino Souza-RKAM).
							 
							 22/09/2014 - Alterado cursor cr_craprda para cr_aplica e adicionado
							              leitura da tabela craprac no mesmo. (Reinert)
                            
               24/07/2015 - Ajustado para ler o limite de saque da conta da nova tabela 
                            TBTAA_LIMITE_SAQUE. (James)
    ............................................................................ */
      -- Identificacao do programa
      vr_cdprogra crapprg.cdprogra%type := 'CRPS524';
      
      -- Cursor para validação da cooperativa
      cursor cr_crapcop is
        SELECT nmrescop
          FROM crapcop
         WHERE cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%rowtype;
      
      -- Rowtype para validacao da data
      rw_crapdat btch0001.cr_crapdat%rowtype;
      
      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);
      
      -- Cursor para associados
      CURSOR cr_crapass IS
        SELECT crapass.dtdemiss,
               crapass.nrdconta,
               crapass.cdagenci,
               crapass.inpessoa
          FROM crapass   
         WHERE crapass.cdcooper = pr_cdcooper
         ORDER BY crapass.inpessoa,
                  crapass.cdagenci,
                  crapass.nrdconta;
      rw_crapass cr_crapass%rowtype;  
      
      -- Cursor para cartao magnetico ativo
      CURSOR cr_crapcrm_ativos IS
        SELECT crapass.cdagenci,
               crapass.inpessoa,
               count(1) qt_registros
          FROM crapass,
               crapcrm
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapcrm.cdcooper = crapass.cdcooper
           AND crapcrm.nrdconta = crapass.nrdconta
           AND crapcrm.cdsitcar = 2 -- Cartoes Ativos.
      GROUP BY crapass.cdagenci,
               crapass.inpessoa;
               
      -- Cursor para buscar o limite de saque
      CURSOR cr_tbtaa_limite_saque IS
        SELECT crapass.cdagenci,
               crapass.inpessoa,
               NVL(SUM(tbtaa_limite_saque.vllimite_saque),0) vllimite_saque
          FROM tbtaa_limite_saque,
               crapass
         WHERE tbtaa_limite_saque.cdcooper = pr_cdcooper
           AND crapass.cdcooper = tbtaa_limite_saque.cdcooper
           AND crapass.nrdconta = tbtaa_limite_saque.nrdconta
      GROUP BY crapass.cdagenci,
               crapass.inpessoa;
               
      -- Cursor para cartao magnetico          
      CURSOR cr_crapcrm (pr_dataini DATE
                        ,pr_datafim DATE) IS
        SELECT crapass.cdagenci,
               crapass.inpessoa,
               COUNT(*) qt_registros
          FROM crapass,
               crapcrm
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapcrm.cdcooper = crapass.cdcooper
           AND crapcrm.nrdconta = crapass.nrdconta
           AND crapcrm.dtentcrm >= pr_dataini
           AND crapcrm.dtentcrm <= pr_datafim
         GROUP BY crapass.cdagenci,
               crapass.inpessoa;
      
      -- Cursor para lancamentos em dep. a vista
      CURSOR cr_craplcm (pr_dataini DATE
                        ,pr_datafim DATE) IS
        SELECT crapass.inpessoa
              ,crapass.cdagenci
              ,count(DISTINCT DECODE(craplcm.cdhistor,614,craplcm.nrdconta, NULL)) qtassqbb
              ,count(DECODE(craplcm.cdhistor,614,1,                         NULL)) qtdsaqbb
              ,count(DISTINCT DECODE(craplcm.cdhistor,614,craplcm.nrdconta, 
                                             668,craplcm.nrdconta, NULL))          qtasqtbb
              ,SUM(DECODE(craplcm.cdhistor,614,craplcm.vllanmto,0))                vlrsaqbb
              ,count(DISTINCT DECODE(craplcm.cdhistor,668,craplcm.nrdconta, NULL)) qtasstbb
              ,count(DECODE(craplcm.cdhistor,668,1,                         NULL)) qtdtrsbb
              ,SUM(DECODE(craplcm.cdhistor,668,craplcm.vllanmto,0))                vlrtrsbb
              ,count(DECODE(craplcm.cdhistor,613,1,                         NULL)) qtddebbb
              ,SUM(DECODE(craplcm.cdhistor,613,craplcm.vllanmto,0))                vlrdebbb
              ,count(DECODE(craplcm.cdhistor,658,1,                         NULL)) qtdcrebb
              ,SUM(DECODE(craplcm.cdhistor,658,craplcm.vllanmto,0))                vlrcrebb
              ,count(DISTINCT DECODE(craplcm.cdhistor,300,craplcm.nrdconta, NULL)) qtassqcv
              ,count(DECODE(craplcm.cdhistor,300,1,                         NULL)) qtdsaqcv
              ,SUM(DECODE(craplcm.cdhistor,300,craplcm.vllanmto,0))                vlrsaqcv
              ,count(DECODE(craplcm.cdhistor,293,1,                         NULL)) qtdcrecv
              ,SUM(DECODE(craplcm.cdhistor,293,craplcm.vllanmto,0))                vlrcrecv
              ,count(DECODE(craplcm.cdhistor,298,1,                         NULL)) qtdanucv
              ,SUM(DECODE(craplcm.cdhistor,298,craplcm.vllanmto,0))                vlranucv
              ,count(DECODE(craplcm.cdhistor,267,1,                         NULL)) qttrfcob
              ,SUM(DECODE(craplcm.cdhistor,267,craplcm.vllanmto,0))                vltrfcob
              ,count(DISTINCT DECODE(craplcm.cdhistor,316,craplcm.nrdconta, 
                                                      918,craplcm.nrdconta, 
                                                      375,craplcm.nrdconta, 
                                                      376,craplcm.nrdconta, 
                                                      856,craplcm.nrdconta, NULL)) qtasscxa
              ,count(DECODE(craplcm.cdhistor,316,1,918,1,                   NULL)) qtsaqcxa
              ,SUM(DECODE(craplcm.cdhistor,316,craplcm.vllanmto,
                                           918,craplcm.vllanmto, 0))               vlsaqcxa
              ,COUNT(DECODE(craplcm.cdhistor,316,
                       DECODE(greatest(nvl(craplcm.nrterfin,0),0),0,NULL,1),
                   918,DECODE(greatest(nvl(craplcm.nrterfin,0),0),0,NULL,1),
                       NULL))                                                      qtsaqtaa
              ,SUM(DECODE(craplcm.cdhistor,316,
                       DECODE(greatest(nvl(craplcm.nrterfin,0),0),0,0,craplcm.vllanmto),
                   918,DECODE(greatest(nvl(craplcm.nrterfin,0),0),0,0,craplcm.vllanmto),
                       NULL))                                                      vlsaqtaa
              ,count(DECODE(craplcm.cdhistor,375,1,376,1,                   NULL)) qttrscxa
              ,SUM(DECODE(craplcm.cdhistor,375,craplcm.vllanmto,
                                           376,craplcm.vllanmto, 0))               vltrscxa
              ,COUNT(DECODE(craplcm.cdhistor,375,
                       DECODE(greatest(nvl(craplcm.nrterfin,0),0),0,NULL,1),
                   376,DECODE(greatest(nvl(craplcm.nrterfin,0),0),0,NULL,1),
                       NULL))                                                      qttrstaa
              ,SUM(DECODE(craplcm.cdhistor,375,
                       DECODE(greatest(nvl(craplcm.nrterfin,0),0),0,0,craplcm.vllanmto),
                   376,DECODE(greatest(nvl(craplcm.nrterfin,0),0),0,0,craplcm.vllanmto),
                       NULL))                                                      vltrstaa
              ,count(DECODE(craplcm.cdhistor,856,1,                         NULL)) qtpagcxa
              ,SUM(DECODE(craplcm.cdhistor,856,craplcm.vllanmto,0))                vlpagcxa
              ,count(DISTINCT DECODE(craplcm.cdhistor,584,craplcm.nrdconta, NULL)) qtassvsn
              ,count(DECODE(craplcm.cdhistor,584,1,                         NULL)) qtlanvsn
              ,SUM(DECODE(craplcm.cdhistor,584,craplcm.vllanmto,0))                vllanvsn
              ,count(DISTINCT DECODE(craplcm.cdhistor,444,craplcm.nrdconta, NULL)) qtassrcd
              ,count(DECODE(craplcm.cdhistor,444,1,                         NULL)) qtlanrcd
              ,SUM(DECODE(craplcm.cdhistor,444,craplcm.vllanmto,0))                vllanrcd
              ,count(DECODE(craplcm.cdhistor, 21,1,                         NULL)) qtchconl              
              ,count(DECODE(craplcm.cdhistor,508,1,                         NULL)) qtpagnet
              ,SUM(DECODE(craplcm.cdhistor,508,craplcm.vllanmto,0))                vlpagnet
              ,count(DECODE(craplcm.cdhistor,537,1,
                                             538,1,                         NULL)) qttrsnet
              ,SUM(DECODE(craplcm.cdhistor,537,craplcm.vllanmto,
                                           538,craplcm.vllanmto,0))                vltrsnet
              ,count(DECODE(craplcm.cdhistor,555,
                       DECODE(craplcm.cdagenci,90,1,NULL),
                       NULL))                                                      qttednet
              ,SUM(DECODE(craplcm.cdhistor,555,
                       DECODE(craplcm.cdagenci,90,craplcm.vllanmto),
                       0))                                                         vltednet
              ,count(DECODE(craplcm.cdhistor,1009,
                       DECODE(craplcm.cdagenci,90,1,NULL),
                       NULL))                                                      qttrinet
              ,SUM(DECODE(craplcm.cdhistor,1009,
                       DECODE(craplcm.cdagenci,90,craplcm.vllanmto),
                       0))                                                         vltrinet
              ,count(DECODE(craplcm.cdhistor,1009,
                       DECODE(craplcm.cdagenci,91,1,NULL),
                       NULL))                                                      qttritaa
              ,SUM(DECODE(craplcm.cdhistor,1009,
                       DECODE(craplcm.cdagenci,91,craplcm.vllanmto),
                       0))                                                         vltritaa
              ,count(DECODE(craplcm.cdhistor,1009,
                       DECODE(craplcm.cdagenci,90,NULL,
                                               91,NULL,
                                                  1),
                       NULL))                                                      qttricxa
              ,SUM(DECODE(craplcm.cdhistor,1009,
                       DECODE(craplcm.cdagenci,90,0,
                                               91,0,
                                                  craplcm.vllanmto),
                       0))                                                         vltricxa
          FROM crapass,
               craplcm
         WHERE crapass.cdcooper = pr_cdcooper
           AND craplcm.cdcooper = crapass.cdcooper
           AND craplcm.nrdconta = crapass.nrdconta
           AND craplcm.dtmvtolt >= pr_dataini
           AND craplcm.dtmvtolt <= pr_datafim
           AND craplcm.cdhistor IN (  21  --  CHEQUE
                                    ,267  --  TRFA COBRANCA
                                    ,293  --   DEBITO VISA
                                    ,298  --  ANUIDADE VISA
                                    ,300  --  SAQUE VISA
                                    ,316  --  SAQUE CARTAO
                                    ,375  --  TRANSF CARTAO
                                    ,376  --  TRF.CARTAO I.
                                    ,444  --  CRED.REDECARD
                                    ,508  --  PG.P/INTERNET
                                    ,537  --  TR.INTERNET
                                    ,538  --  TR.INTERNET I
                                    ,555  --  DEB. TED
                                    ,584  --  CRED. CIELO
                                    ,613  --  CARTAO DB. BB
                                    ,614  --  SAQ.CARTAO BB
                                    ,658  --  PGT.CARTAO BB
                                    ,668  --  TRF.CARTAO BB
                                    ,856  --  PGTO P/ TAA
                                    ,918  --  SAQUE TAA
                                    ,1009)--  TRANSF.INTERC
         GROUP BY crapass.inpessoa
                 ,crapass.cdagenci;
      
      -- Cursor para busca de historicos e datas especificas
      CURSOR cr_craplcm_bb (pr_nrdconta craplcm.nrdconta%type
                           ,pr_dataini  DATE
                           ,pr_datafim  DATE) IS
        SELECT nvl(COUNT(decode(greatest(craplcm.cdhistor, 973),973,1,NULL)),0)                qtbtbb,
               nvl(SUM(decode(greatest(craplcm.cdhistor,   973),973,craplcm.vllanmto,0)),0) vlbtbb,
               nvl(COUNT(decode(least(craplcm.cdhistor,    974),974,1,NULL)),0)                qtbtce,
               nvl(SUM(decode(least(craplcm.cdhistor,      974),974,craplcm.vllanmto,0)),0) vlbtce
          FROM craplcm
         WHERE craplcm.cdcooper = pr_cdcooper
           AND craplcm.nrdconta = pr_nrdconta
           AND craplcm.dtmvtolt BETWEEN pr_dataini AND pr_datafim
           AND craplcm.cdhistor NOT IN (971, 977)
           AND craplcm.cdhistor BETWEEN  967 AND 986;
      rw_craplcm_bb cr_craplcm_bb%rowtype;
      -- Cursor para URA
      CURSOR cr_crapura (pr_dataini DATE
                        ,pr_datafim DATE) IS
        SELECT crapass.cdagenci,
               crapass.inpessoa,
               count(DISTINCT crapass.nrdconta) qtassura,
               COUNT(1)          qtconura
          FROM crapass,
               crapura
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapura.cdcooper = crapass.cdcooper
           AND crapura.dtconsul >= pr_dataini
           AND crapura.dtconsul <= pr_datafim
           AND crapura.nrdconta = crapass.nrdconta
         GROUP BY crapass.cdagenci,
               crapass.inpessoa;
      
      --Cursor para LOG de acesso ao INTERNETBANK
      CURSOR cr_craplgm_acesso ( pr_dataini DATE
                                ,pr_datafim DATE) IS
          WITH tit AS
          (SELECT nrdconta,
                  COUNT(*) qt_registros
             FROM crapttl
            WHERE cdcooper = pr_cdcooper
            GROUP BY nrdconta)
          SELECT crapass.cdagenci,
                 crapass.inpessoa,
                 COUNT(DISTINCT decode(instr(craplgm.dstransa,'Efetuado login de acesso'),0,NULL,crapass.nrdconta)) qtassnet,
                 COUNT(decode(instr(upper(craplgm.dstransa),'EXTRAT'),0,null,1)) qtextnet, 
                 COUNT(DISTINCT decode(craplgm.dsorigem,'INTERNET',crapass.nrdconta,NULL)) qtasunet
            FROM tit,
                 crapass,
                 craplgm
           WHERE crapass.cdcooper  = pr_cdcooper
             AND craplgm.cdcooper  = crapass.cdcooper
             AND craplgm.nrdconta  = crapass.nrdconta
             AND tit.nrdconta (+)  = crapass.nrdconta
             AND craplgm.idseqttl <= NVL(tit.qt_registros,1)
             AND craplgm.dttransa >= pr_dataini
             AND craplgm.dttransa <= pr_datafim
             AND craplgm.nmdatela = 'INTERNETBANK'
           GROUP BY crapass.cdagenci,
                 crapass.inpessoa;
      
      
     
      -- Cursor para emissao de boletos do BB
      CURSOR cr_cobrancaBB (pr_dataini DATE
                           ,pr_datafim DATE) IS
        SELECT crapass.cdagenci,
               crapass.inpessoa, 
               COUNT(DISTINCT crapass.nrdconta)                          qtasscob,
               count(decode(crapcob.indpagto,0,1,NULL))                  qtdcobbb,
               nvl(SUM(decode(crapcob.indpagto,0,crapcob.vldpagto,0)),0) vlrcobbb,
               count(decode(crapcob.indpagto,0,NULL,1))                  qtcobonl,
               nvl(SUM(decode(crapcob.indpagto,0,0,crapcob.vldpagto)),0) vlcobonl
          FROM crapass, -- Cadastro de associados
               crapceb, -- Cadastro de Emissao de Bloquetos
               crapcob, -- Cadastro de bloquetos de cobranca
               crapcco  -- Contem  parametros do cadastro de cobranca
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapceb.cdcooper = crapass.cdcooper
           AND crapceb.nrdconta = crapass.nrdconta
           AND crapcob.cdcooper = crapceb.cdcooper
           AND crapcob.nrdconta = crapceb.nrdconta
           AND crapcob.nrcnvcob = crapceb.nrconven
           AND crapcob.dtdpagto >= pr_dataini
           AND crapcob.dtdpagto <= pr_datafim
           AND crapcob.incobran = 5
           AND crapcob.vldpagto > 0
           AND crapcob.flgregis = 0
           AND crapcco.cdcooper = crapcob.cdcooper
           AND crapcco.nrconven = crapcob.nrcnvcob
           AND crapcco.cddbanco = 001
           AND crapcco.flgregis = 0
         GROUP BY crapass.cdagenci,
                crapass.inpessoa;
    
      -- Cursor para emissao de boletos
      CURSOR cr_cobranca_boleto (pr_dataini DATE
                           ,pr_datafim DATE) IS
        SELECT crapass.cdagenci,
               crapass.inpessoa,
               COUNT(1) qt_registros,
               nvl(sum(crapcob.vltitulo),0) vltitulo
          FROM crapass, -- Cadastro de associados
               crapceb, -- Cadastro de Emissao de Bloquetos
               crapcob, -- Cadastro de bloquetos de cobranca
               crapcco  -- Contem  parametros do cadastro de cobranca
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapceb.cdcooper = crapass.cdcooper
           AND crapceb.nrdconta = crapass.nrdconta
           AND crapcob.cdcooper = crapceb.cdcooper
           AND crapcob.nrdconta = crapceb.nrdconta
           AND crapcob.nrcnvcob = crapceb.nrconven
           AND crapcob.dtmvtolt >= pr_dataini
           AND crapcob.dtmvtolt <= pr_datafim
           AND crapcco.cdcooper = crapcob.cdcooper
           AND crapcco.nrconven = crapcob.nrcnvcob
           AND crapcco.dsorgarq = 'INTERNET'
           AND crapcob.flgregis <> 1
         GROUP BY crapass.cdagenci,
               crapass.inpessoa;
      
      -- Cursor para cadastro de emissao de bloquetos
      CURSOR cr_crapceb (pr_nrdconta crapass.nrdconta%type) IS
        SELECT crapceb.progress_recid
          FROM crapceb  -- Cadastro de Emissao de Bloquetos
         WHERE crapceb.cdcooper = pr_cdcooper
           AND crapceb.nrdconta = pr_nrdconta;
      rw_crapceb cr_crapceb%rowtype;
      
      -- Cursor para titulos por emissao
      CURSOR cr_titulos(pr_nrdconta crapass.nrdconta%type
                       ,pr_dataini DATE
                       ,pr_datafim DATE) IS
        SELECT crapcob.indpagto,
               crapcob.flgregis,
               crapceb.nrconven,
               crapcob.nrcnvcob,
               crapcob.vltitulo,
               crapcob.cdbandoc
          FROM crapceb, -- Cadastro de Emissao de Bloquetos
               crapcob, -- Cadastro de bloquetos de cobranca
               crapcco  -- Contem  parametros do cadastro de cobranca
         WHERE crapceb.cdcooper = pr_cdcooper
           AND crapceb.nrdconta = pr_nrdconta
           AND crapcob.cdcooper = crapceb.cdcooper
           AND crapcob.nrdconta = crapceb.nrdconta
           AND crapcob.nrcnvcob = crapceb.nrconven
           AND crapcob.dtmvtolt BETWEEN pr_dataini AND pr_datafim
           AND crapcob.flgregis = 1
           AND crapcco.cdcooper = crapcob.cdcooper
           AND crapcco.nrconven = crapcob.nrcnvcob
           AND crapcco.flgregis = 1
           AND crapcco.dsorgarq = 'INTERNET';
      rw_titulos cr_titulos%rowtype;
      
      -- Cursor para titulos pagos
       CURSOR cr_titulos_pagos(pr_nrdconta crapass.nrdconta%type
                              ,pr_dataini DATE
                              ,pr_datafim DATE) IS
        SELECT crapcob.indpagto,
               crapcob.flgregis,
               crapceb.nrconven,
               crapcob.nrcnvcob,
               crapcob.vltitulo,
               crapcob.cdbandoc,
               crapcob.incobran,
               crapcob.vldpagto,
               crapcob.flgcbdda
          FROM crapceb, -- Cadastro de Emissao de Bloquetos
               crapcob, -- Cadastro de bloquetos de cobranca
               crapcco  -- Contem  parametros do cadastro de cobranca
         WHERE crapceb.cdcooper = pr_cdcooper
           AND crapceb.nrdconta = pr_nrdconta
           AND crapcob.cdcooper = crapceb.cdcooper
           AND crapcob.nrdconta = crapceb.nrdconta
           AND crapcob.nrcnvcob = crapceb.nrconven
           AND crapcob.dtdpagto +0 BETWEEN pr_dataini AND pr_datafim
           AND crapcco.cdcooper = crapcob.cdcooper
           AND crapcco.nrconven = crapcob.nrcnvcob
           AND crapcco.flgregis = 1;
      rw_titulos_pagos cr_titulos_pagos%rowtype;
      
      -- Cursor para auxiliar de cartoes de credito BB
      CURSOR cr_crawcrd_bb (pr_inpessoa crapass.inpessoa%type,
                            pr_cdagenci crapass.cdagenci%type,
                            pr_dtultdia crawcrd.dtmvtolt%TYPE) IS
        SELECT nvl(COUNT(*),0)
          FROM crawcrd,
               crapass
         WHERE crawcrd.cdcooper = pr_cdcooper
           AND crawcrd.cdadmcrd > 82
           AND crawcrd.cdadmcrd < 89
           AND crawcrd.insitcrd = 4
           AND crapass.cdcooper = crawcrd.cdcooper
           AND crapass.nrdconta = crawcrd.nrdconta
           AND crapass.inpessoa = pr_inpessoa
           AND crapass.cdagenci = pr_cdagenci
           AND crawcrd.dtmvtolt <= pr_dtultdia;
      
      -- Cursor para auxiliar de cartoes de credito Bradesco
      CURSOR cr_crawcrd_bradesco (pr_inpessoa crapass.inpessoa%type,
                                  pr_cdagenci crapass.cdagenci%type,
                                  pr_dtultdia crawcrd.dtmvtolt%TYPE) IS
        SELECT nvl(COUNT(*),0)
          FROM crawcrd,
               crapass
         WHERE crawcrd.cdcooper = pr_cdcooper
           AND crawcrd.cdadmcrd = 3
           AND crawcrd.insitcrd = 4
           AND crapass.cdcooper = crawcrd.cdcooper
           AND crapass.nrdconta = crawcrd.nrdconta
           AND crapass.inpessoa = pr_inpessoa
           AND crapass.cdagenci = pr_cdagenci
           AND crawcrd.dtmvtolt <= pr_dtultdia;

      -- Cursor sobre
      CURSOR cr_craptco(pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT nrdconta
          FROM craptco
         WHERE craptco.cdcopant = pr_cdcooper
           AND craptco.nrctaant = pr_nrdconta
           AND craptco.cdageant IN (2,4,6,7,11)
           AND craptco.cdcooper = 1
           AND craptco.tpctatrf = 1;
      rw_craptco cr_craptco%ROWTYPE;

      -- Criacao da variavel para a tabela CRAPGPR
      TYPE typ_tab_crapgpr IS TABLE OF crapgpr%ROWTYPE INDEX BY PLS_INTEGER;
      vr_tab_crapgpr typ_tab_crapgpr;
      vr_indice  PLS_INTEGER;
            
      -- VARIAVEIS LOCAIS --
      vr_dataini DATE; -- Data inicial do periodo
      vr_datafim DATE; -- Data final do periodo
      vr_ultdiau DATE; -- Ultimo dia util do mes da data final do periodo
      vr_qtasscob PLS_INTEGER := 0;
      vr_qtassati PLS_INTEGER := 0;
      vr_aux_cdagenci PLS_INTEGER := 0;
      vr_aux_inpessoa PLS_INTEGER := 0;
        
      /* Cobranca Registrada */
      vr_qtcpfcbr PLS_INTEGER := 0;
      vr_qtbpfcbb PLS_INTEGER := 0; 
      vr_qtbpfcec PLS_INTEGER := 0;
      vr_qtbpftbb PLS_INTEGER := 0;
      vr_qtbpflcm PLS_INTEGER := 0;
      vr_qtbpflco PLS_INTEGER := 0;
      vr_qtcpjcbr PLS_INTEGER := 0;
      vr_qtcpjcbb PLS_INTEGER := 0;
      vr_qtbpjcec PLS_INTEGER := 0;
      vr_qtbpjtbb PLS_INTEGER := 0;
      vr_qtbpjtce PLS_INTEGER := 0;  
      vr_qtbpjlcm PLS_INTEGER := 0;
      vr_qtbpjlco PLS_INTEGER := 0;
      vr_vlbpjlco NUMBER(25,2) := 0;
      vr_vlbpjdda NUMBER(25,2) := 0;
      vr_vlbpftbb NUMBER(25,2) := 0;
      vr_qtbpftce NUMBER(25,2) := 0;
      vr_vlbpftce NUMBER(25,2) := 0;
      vr_vlbpflcm NUMBER(25,2) := 0;
      vr_vlbpflco NUMBER(25,2) := 0;
      vr_vlbpfdda NUMBER(25,2) := 0;
      vr_vlbpjtbb NUMBER(25,2) := 0;
      vr_vlbpjtce NUMBER(25,2) := 0;
      vr_vlbpjlcm NUMBER(25,2) := 0;
      vr_flgcobra BOOLEAN := FALSE;
                
      /* CARTOES BB */
      vr_qtdatibb PLS_INTEGER := 0; 
      vr_vllimcbb NUMBER(25,2) := 0;
      vr_vllimdbb NUMBER(25,2) := 0;
      vr_saquebb BOOLEAN := FALSE;  -- Indicador de saque no bb do associado
      vr_transbb BOOLEAN := FALSE;  -- Indicador de transferencia no bb do associado

      /* CARTOES CECRED VISA */
      vr_qtdaticv PLS_INTEGER := 0;
      vr_saquevi BOOLEAN := FALSE;  -- Indicador de saque com cartao visa do associado
        
        

       
      /* INTERNET */
      vr_vlbltnet NUMBER(25,2) := 0;
      vr_qtbltnet PLS_INTEGER := 0;
        
      vr_credici BOOLEAN := FALSE;  -- Indicador de uso do credito visa do associado
      vr_credire BOOLEAN := FALSE;  -- Indicador de uso do credito redecard do associado
      vr_flagura BOOLEAN := FALSE;  -- Indicador de uso da URA
        
      vr_flg_qtasscob BOOLEAN := FALSE;  -- Indicador de uso de cobranca
      
      /* cartao multiplo e cartao cecred visa - novos */
      vr_vlusobbd NUMBER(25,2) := 0;
      vr_vlusobbc NUMBER(25,2) := 0;
      vr_vllimcon NUMBER(25,2) := 0;
      
      -- SEGUROS --
      vr_vlrdecom1 NUMBER(25,2) := 0;
      vr_vlrdecom2 NUMBER(25,2) := 0;
      vr_vlrdecom3 NUMBER(25,2) := 0;
      vr_vlrdeiof1 NUMBER(25,2) := 0;
      vr_vlrdeiof2 NUMBER(25,2) := 0;
      vr_vlrdeiof3 NUMBER(25,2) := 0;
      vr_vlrapoli  NUMBER(25,2) := 0;

      vr_recid1 ROWID;
      vr_recid2 ROWID;
      vr_recid3 ROWID;
        
      -- PROCEDIMENTOS --
      -- Procedimento para retornar os indicadores onde existem participacoes dos associados
      PROCEDURE pc_mostra_participacao IS
          
          -- CURSOR para limites de descontos
          CURSOR cr_craplim IS
            SELECT crapass.cdagenci,
                   crapass.inpessoa,
                   COUNT(DISTINCT DECODE(craplim.tpctrlim,1, crapass.nrdconta,NULL)) qtassesp,
                   SUM(DECODE(craplim.tpctrlim,1,crapass.vllimcre,0))                vltotesp,
                   COUNT(DISTINCT DECODE(craplim.tpctrlim,2,
                          DECODE(craplim.insitlim,2,crapass.nrdconta,NULL),NULL))    qtassdch,
                   COUNT(DISTINCT DECODE(craplim.tpctrlim,2,
                          DECODE(craplim.insitlim,3,crapass.nrdconta,NULL),NULL))    qtassdti
              FROM crapass,
                   craplim
             WHERE crapass.cdcooper = pr_cdcooper
               AND craplim.cdcooper = crapass.cdcooper 
               AND craplim.nrdconta = crapass.nrdconta
               AND ((craplim.tpctrlim = 1
                 AND craplim.insitlim = 2)  -- Para cheque especial
                OR  (craplim.tpctrlim = 2
                 AND craplim.insitlim = 2)  -- com contrato de Desconto de Cheque
                OR  (craplim.tpctrlim = 2
                 AND craplim.insitlim = 3))  -- com contrato de Desconto de Titulo
              GROUP BY crapass.cdagenci,
                   crapass.inpessoa;
                   
            
          -- CURSOR para cheques
          CURSOR cr_crapcdb (pr_datini crapcdb.dtlibera%type
                            ,pr_datfim crapcdb.dtlibera%type) IS
            SELECT crapass.cdagenci,
                   crapass.inpessoa,
                   COUNT(*) qt_registros,
                   nvl(sum(crapcdb.vlcheque),0) vlcheque
              FROM crapass,
                   crapcdb
             WHERE crapass.cdcooper = pr_cdcooper
               AND crapcdb.cdcooper = crapass.cdcooper
               AND crapcdb.nrdconta = crapass.nrdconta   
               AND crapcdb.insitchq = 2
               AND crapcdb.dtlibera >= pr_datini        
               AND crapcdb.dtlibera <= pr_datfim
             GROUP BY crapass.cdagenci,
                   crapass.inpessoa;
            
          --CURSOR para titulos compensados
          CURSOR cr_craptdb (pr_datini craptdb.dtvencto%type
                            ,pr_datfim craptdb.dtvencto%type) IS
            SELECT crapass.cdagenci,
                   crapass.inpessoa,
                   nvl(count(*),0) qt_registros,
                   nvl(sum(craptdb.vltitulo),0) vltitulo
              FROM crapass,
                   craptdb
             WHERE crapass.cdcooper   = pr_cdcooper
               AND ((craptdb.cdcooper = crapass.cdcooper
               AND   craptdb.nrdconta = crapass.nrdconta 
               AND   craptdb.insittit = 4                
               AND   craptdb.dtvencto >= pr_datini       
               AND   craptdb.dtvencto <= pr_datfim)
                OR  (craptdb.cdcooper = crapass.cdcooper
               AND   craptdb.nrdconta = crapass.nrdconta 
               AND   craptdb.insittit = 2
               AND   craptdb.dtdpagto >= pr_datini))
             GROUP BY crapass.cdagenci,
                   crapass.inpessoa;        
          rw_craptdb cr_craptdb%rowtype;
            
          -- CURSOR para uso do caixa eletronico
          CURSOR cr_crapltr(pr_dataini DATE
                           ,pr_datafim DATE) IS
            SELECT crapass.cdagenci,
                   crapass.inpessoa,
                   COUNT(DISTINCT crapass.nrdconta) qt_registros
              FROM crapass,
                   crapltr
             WHERE crapass.cdcooper = pr_cdcooper
               AND crapltr.cdcooper = crapass.cdcooper
               AND crapltr.nrdconta = crapass.nrdconta
               AND crapltr.dttransa >= pr_dataini
               AND crapltr.dttransa <= pr_datafim
             GROUP BY crapass.cdagenci,
                   crapass.inpessoa;
           
         -- CURSOR para aplicacoes
         CURSOR cr_aplica (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
          SELECT aplicacoes.cdagenci,
								 aplicacoes.inpessoa,
								 COUNT(DISTINCT aplicacoes.nrdconta) qt_registros
					  FROM(/* Aplicações RDA */
					       SELECT crapass.cdagenci cdagenci,
												crapass.inpessoa inpessoa,
												crapass.nrdconta nrdconta							
									 FROM crapass,
												craprda
									WHERE crapass.cdcooper = pr_cdcooper                                 
										AND craprda.cdcooper = crapass.cdcooper
										AND craprda.nrdconta = crapass.nrdconta						 
										AND craprda.insaqtot = 0
								 UNION
								 /* Aplicações de captação */
								 SELECT crapass.cdagenci cdagenci,
												crapass.inpessoa inpessoa,
												crapass.nrdconta nrdconta
									 FROM crapass,                 
												craprac
									WHERE crapass.cdcooper = pr_cdcooper
										AND craprac.cdcooper = crapass.cdcooper
										AND craprac.nrdconta = crapass.nrdconta
										AND craprac.idsaqtot = 0) aplicacoes
					 GROUP BY aplicacoes.cdagenci,
										aplicacoes.inpessoa;
          
          -- CURSOR para autorizacoes de debito
          CURSOR cr_crapatr IS
            SELECT crapass.cdagenci,
                   crapass.inpessoa,
                   COUNT(DISTINCT crapass.nrdconta) qt_registros
              FROM crapass,
                   crapatr
             WHERE crapass.cdcooper = pr_cdcooper
               AND crapatr.cdcooper = crapass.cdcooper
               AND crapatr.nrdconta = crapass.nrdconta
               AND crapatr.dtfimatr IS NULL
             GROUP BY crapass.cdagenci,
                   crapass.inpessoa;
          rw_crapatr cr_crapatr%rowtype;

          -- CURSOR para poupanca programada
          CURSOR cr_craprpp IS
            SELECT crapass.cdagenci,
                   crapass.inpessoa,
                   count(DISTINCT crapass.nrdconta) qt_registros
              FROM crapass,
                   craprpp
             WHERE crapass.cdcooper = pr_cdcooper
               AND craprpp.cdcooper = crapass.cdcooper
               AND craprpp.nrdconta = crapass.nrdconta
               AND craprpp.cdsitrpp = 1
             GROUP BY crapass.cdagenci,
                   crapass.inpessoa;
          rw_craprpp cr_craprpp%rowtype;
            
          -- CURSOR para emprestimos
          CURSOR cr_crapepr IS
            SELECT crapass.cdagenci,
                   crapass.inpessoa,
                   COUNT(DISTINCT crapass.nrdconta)  qt_registros,
                   SUM(crapepr.vlemprst)             vlemprst
              FROM crapass,
                   crapepr
             WHERE crapass.cdcooper = pr_cdcooper
               AND crapepr.cdcooper = crapass.cdcooper
               AND crapepr.nrdconta = crapass.nrdconta
               AND crapepr.inliquid = 0
               GROUP BY crapass.cdagenci,
                   crapass.inpessoa;
            
          -- CURSOR para depositos em TAA
          CURSOR cr_crapenl(pr_dataini DATE
                           ,pr_datafim DATE) IS
            SELECT crapass.cdagenci,
                   crapass.inpessoa,
                   COUNT(*) qt_registros,
                   SUM(crapenl.vlchqcmp + crapenl.vldincmp) vldepcxa
              FROM crapass,
                   crapenl
             WHERE crapass.cdcooper = pr_cdcooper
               AND crapenl.cdcooper = crapass.cdcooper
               AND crapenl.nrdconta = crapass.nrdconta
               AND crapenl.dtmvtolt >= pr_dataini
               AND crapenl.dtmvtolt <= pr_datafim
               AND crapenl.cdsitenv = 1
             GROUP BY crapass.cdagenci,
                   crapass.inpessoa;
          rw_crapenl cr_crapenl%rowtype;
            
          -- CURSOR para cheques compensados
          CURSOR cr_crapfdc(pr_dataini DATE
                           ,pr_datafim DATE) IS
            SELECT crapass.cdagenci,
                   crapass.inpessoa,
                   COUNT(*) qt_registros
              FROM crapass,
                   crapfdc
             WHERE crapass.cdcooper = pr_cdcooper
               AND crapfdc.cdcooper = crapass.cdcooper
               AND crapfdc.nrdconta = crapass.nrdconta
               AND crapfdc.incheque = 5
               AND crapfdc.dtliqchq >= pr_dataini
               AND crapfdc.dtliqchq <= pr_datafim
               AND crapfdc.dtemschq IS NOT NULL
               AND crapfdc.dtretchq IS NOT NULL
             GROUP BY crapass.cdagenci,
                   crapass.inpessoa;
         rw_crapfdc cr_crapfdc%rowtype;
                        
        BEGIN
          /** Emprestimos **/
          FOR rw_crapepr IN cr_crapepr LOOP
            -- Atualiza a pl/table vr_tab_crapgpr para no final do processo atualizar a tabela CRAPGPR
            vr_indice := lpad(rw_crapepr.cdagenci,5,'0')||lpad(rw_crapepr.inpessoa,5,'0');
            vr_tab_crapgpr(vr_indice).cdcooper := pr_cdcooper;             
            vr_tab_crapgpr(vr_indice).inpessoa := rw_crapepr.inpessoa;             
            vr_tab_crapgpr(vr_indice).cdagenci := rw_crapepr.cdagenci;             
            vr_tab_crapgpr(vr_indice).dtrefere := vr_datafim;             
            vr_tab_crapgpr(vr_indice).qtassepr := rw_crapepr.qt_registros;
            vr_tab_crapgpr(vr_indice).vltotepr := rw_crapepr.vlemprst;
          END LOOP;


          /** Planos de Poupanca Programada **/
          FOR rw_craprpp IN cr_craprpp LOOP
            -- Atualiza a pl/table vr_tab_crapgpr para no final do processo atualizar a tabela CRAPGPR
            vr_indice := lpad(rw_craprpp.cdagenci,5,'0')||lpad(rw_craprpp.inpessoa,5,'0');
            vr_tab_crapgpr(vr_indice).cdcooper := pr_cdcooper;             
            vr_tab_crapgpr(vr_indice).inpessoa := rw_craprpp.inpessoa;             
            vr_tab_crapgpr(vr_indice).cdagenci := rw_craprpp.cdagenci;             
            vr_tab_crapgpr(vr_indice).dtrefere := vr_datafim;             
            vr_tab_crapgpr(vr_indice).qtassrpp := rw_craprpp.qt_registros;
          END LOOP;

          /** Aut. Debitos **/
          FOR rw_crapatr IN cr_crapatr LOOP
            -- Atualiza a pl/table vr_tab_crapgpr para no final do processo atualizar a tabela CRAPGPR
            vr_indice := lpad(rw_crapatr.cdagenci,5,'0')||lpad(rw_crapatr.inpessoa,5,'0');
            vr_tab_crapgpr(vr_indice).cdcooper := pr_cdcooper;             
            vr_tab_crapgpr(vr_indice).inpessoa := rw_crapatr.inpessoa;             
            vr_tab_crapgpr(vr_indice).cdagenci := rw_crapatr.cdagenci;             
            vr_tab_crapgpr(vr_indice).dtrefere := vr_datafim;             
            vr_tab_crapgpr(vr_indice).qtassdeb := rw_crapatr.qt_registros;
          END LOOP;
        
          /** Qtd e Valor de títulos compensados no mês **/
          FOR rw_craptdb IN cr_craptdb(vr_dataini, vr_datafim) LOOP
            -- Atualiza a pl/table vr_tab_crapgpr para no final do processo atualizar a tabela CRAPGPR
            vr_indice := lpad(rw_craptdb.cdagenci,5,'0')||lpad(rw_craptdb.inpessoa,5,'0');
            vr_tab_crapgpr(vr_indice).cdcooper := pr_cdcooper;             
            vr_tab_crapgpr(vr_indice).inpessoa := rw_craptdb.inpessoa;             
            vr_tab_crapgpr(vr_indice).cdagenci := rw_craptdb.cdagenci;             
            vr_tab_crapgpr(vr_indice).dtrefere := vr_datafim;             
            vr_tab_crapgpr(vr_indice).qtdescti := rw_craptdb.qt_registros;
            vr_tab_crapgpr(vr_indice).vldescti := rw_craptdb.vltitulo;
          END LOOP;
        
          /** Aplicacoes **/
          FOR rw_aplica IN cr_aplica (pr_cdcooper => pr_cdcooper) LOOP
            -- Atualiza a pl/table vr_tab_crapgpr para no final do processo atualizar a tabela CRAPGPR
            vr_indice := lpad(rw_aplica.cdagenci,5,'0')||lpad(rw_aplica.inpessoa,5,'0');
            vr_tab_crapgpr(vr_indice).cdcooper := pr_cdcooper;             
            vr_tab_crapgpr(vr_indice).inpessoa := rw_aplica.inpessoa;             
            vr_tab_crapgpr(vr_indice).cdagenci := rw_aplica.cdagenci;             
            vr_tab_crapgpr(vr_indice).dtrefere := vr_datafim;             
            vr_tab_crapgpr(vr_indice).qtassrda := rw_aplica.qt_registros;
          END LOOP;
					
           /** Depositos em TAA **/
          FOR rw_crapenl IN cr_crapenl(vr_dataini, vr_datafim) LOOP
            -- Atualiza a pl/table vr_tab_crapgpr para no final do processo atualizar a tabela CRAPGPR
            vr_indice := lpad(rw_crapenl.cdagenci,5,'0')||lpad(rw_crapenl.inpessoa,5,'0');
            vr_tab_crapgpr(vr_indice).cdcooper := pr_cdcooper;             
            vr_tab_crapgpr(vr_indice).inpessoa := rw_crapenl.inpessoa;             
            vr_tab_crapgpr(vr_indice).cdagenci := rw_crapenl.cdagenci;             
            vr_tab_crapgpr(vr_indice).dtrefere := vr_datafim;             
            vr_tab_crapgpr(vr_indice).qtdepcxa := rw_crapenl.qt_registros;
            vr_tab_crapgpr(vr_indice).vldepcxa := rw_crapenl.vldepcxa;
          END LOOP;

          /** limite de credito **/
          FOR rw_craplim IN cr_craplim LOOP
            -- Atualiza a pl/table vr_tab_crapgpr para no final do processo atualizar a tabela CRAPGPR
            vr_indice := lpad(rw_craplim.cdagenci,5,'0')||lpad(rw_craplim.inpessoa,5,'0');
            vr_tab_crapgpr(vr_indice).cdcooper := pr_cdcooper;             
            vr_tab_crapgpr(vr_indice).inpessoa := rw_craplim.inpessoa;             
            vr_tab_crapgpr(vr_indice).cdagenci := rw_craplim.cdagenci;             
            vr_tab_crapgpr(vr_indice).dtrefere := vr_datafim;             
            vr_tab_crapgpr(vr_indice).qtassdch := rw_craplim.qtassdch;
            vr_tab_crapgpr(vr_indice).qtassdti := rw_craplim.qtassdti;
            vr_tab_crapgpr(vr_indice).qtassesp := rw_craplim.qtassesp;
            vr_tab_crapgpr(vr_indice).vltotesp := rw_craplim.vltotesp;
          END LOOP;

          /** Qtd Coop. que utilizaram Caixa Eletronico**/
          FOR rw_crapltr IN cr_crapltr(vr_dataini, vr_datafim) LOOP
            -- Atualiza a pl/table vr_tab_crapgpr para no final do processo atualizar a tabela CRAPGPR
            vr_indice := lpad(rw_crapltr.cdagenci,5,'0')||lpad(rw_crapltr.inpessoa,5,'0');
            vr_tab_crapgpr(vr_indice).cdcooper := pr_cdcooper;             
            vr_tab_crapgpr(vr_indice).inpessoa := rw_crapltr.inpessoa;             
            vr_tab_crapgpr(vr_indice).cdagenci := rw_crapltr.cdagenci;             
            vr_tab_crapgpr(vr_indice).dtrefere := vr_datafim;             
            vr_tab_crapgpr(vr_indice).qtasucxa := rw_crapltr.qt_registros;
          END LOOP;
            
          /** Cheques Descontados **/
          FOR rw_crapcdb IN cr_crapcdb(vr_dataini, vr_datafim) LOOP
            -- Atualiza a pl/table vr_tab_crapgpr para no final do processo atualizar a tabela CRAPGPR
            vr_indice := lpad(rw_crapcdb.cdagenci,5,'0')||lpad(rw_crapcdb.inpessoa,5,'0');
            vr_tab_crapgpr(vr_indice).cdcooper := pr_cdcooper;             
            vr_tab_crapgpr(vr_indice).inpessoa := rw_crapcdb.inpessoa;             
            vr_tab_crapgpr(vr_indice).cdagenci := rw_crapcdb.cdagenci;             
            vr_tab_crapgpr(vr_indice).dtrefere := vr_datafim;             
            vr_tab_crapgpr(vr_indice).qtdescch := rw_crapcdb.qt_registros;
            vr_tab_crapgpr(vr_indice).vldescch := rw_crapcdb.vlcheque;
          END LOOP;

          
          /** Cheques compensados **/
          FOR rw_crapfdc IN cr_crapfdc(vr_dataini, vr_datafim) LOOP
            -- Atualiza a pl/table vr_tab_crapgpr para no final do processo atualizar a tabela CRAPGPR
            vr_indice := lpad(rw_crapfdc.cdagenci,5,'0')||lpad(rw_crapfdc.inpessoa,5,'0');
            vr_tab_crapgpr(vr_indice).cdcooper := pr_cdcooper;             
            vr_tab_crapgpr(vr_indice).inpessoa := rw_crapfdc.inpessoa;             
            vr_tab_crapgpr(vr_indice).cdagenci := rw_crapfdc.cdagenci;             
            vr_tab_crapgpr(vr_indice).dtrefere := vr_datafim;             
            vr_tab_crapgpr(vr_indice).qtchcomp := rw_crapfdc.qt_registros;
          END LOOP;


        EXCEPTION
          WHEN vr_exc_saida THEN
            RAISE vr_exc_saida; 
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro no procedimento pc_mostra_participacao. '||SQLERRM;
            RAISE vr_exc_saida;
      END; -- pc_mostra_participacao
      
      -- Procedimento para retornar os valores dos convenios existentes  
      PROCEDURE pc_roda_convenio IS
        vr_tab_convenio CONV0001.typ_tab_convenio;
        vr_tab_crawass CONV0001.typ_tab_crawass;
        vr_chave varchar2(10); -- Auxilio no Loop da Pltable
      BEGIN
        -- Valida a cooperativa
        open cr_crapcop;
        fetch cr_crapcop
          into rw_crapcop;
        if cr_crapcop%notfound then
          vr_cdcritic := 057;
          close cr_crapcop;
          raise vr_exc_fimprg;
        end if;
        close cr_crapcop;
          
        -- Alimenta tabelas de memoria para convenios
        CONV0001.pc_valor_convenios(pr_cdcooper => pr_cdcooper 
                                   ,pr_dataini => vr_dataini
                                   ,pr_datafim => vr_datafim
                                   ,pr_tab_convenio => vr_tab_convenio
                                   ,pr_tab_crawass => vr_tab_crawass
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
                                     
        IF vr_dscritic IS NOT NULL THEN
          vr_dscritic := 'CONV0001: '||vr_dscritic;
          RAISE vr_exc_saida;
        END IF;
        
        -- Loop para leitura da PlTable de convenio e update/insert na crapgpr
        vr_chave := vr_tab_convenio.FIRST;
          
        LOOP
          EXIT WHEN vr_chave IS NULL; 
          -- Atualiza a pl/table vr_tab_crapgpr para no final do processo atualizar a tabela CRAPGPR
          vr_indice := lpad(vr_tab_convenio(vr_chave).cdagenci,5,'0')||'00001';
          vr_tab_crapgpr(vr_indice).cdcooper := pr_cdcooper;
          vr_tab_crapgpr(vr_indice).dtrefere := vr_datafim;
          vr_tab_crapgpr(vr_indice).cdagenci := vr_tab_convenio(vr_chave).cdagenci;
          vr_tab_crapgpr(vr_indice).inpessoa := 1;
          vr_tab_crapgpr(vr_indice).qtfatcnv := nvl(vr_tab_crapgpr(vr_indice).qtfatcnv,0) + NVL(vr_tab_convenio(vr_chave).qtfatura, 0);
          vr_tab_crapgpr(vr_indice).vlfatcnv := nvl(vr_tab_crapgpr(vr_indice).vlfatcnv,0) + NVL(vr_tab_convenio(vr_chave).vltarifa, 0);
          vr_tab_crapgpr(vr_indice).qtdebcnv := nvl(vr_tab_crapgpr(vr_indice).qtdebcnv,0) + NVL(vr_tab_convenio(vr_chave).qtdebito, 0);
          vr_tab_crapgpr(vr_indice).vldebcnv := nvl(vr_tab_crapgpr(vr_indice).vldebcnv,0) + NVL(vr_tab_convenio(vr_chave).vltardeb, 0);
           
          vr_chave := vr_tab_convenio.NEXT(vr_chave);
        END LOOP; -- FIM PlTable de Convenio
        
      EXCEPTION
        WHEN vr_exc_saida THEN
          RAISE vr_exc_saida; 
        WHEN OTHERS THEN
          vr_dscritic := 'Erro na pc_roda_convenio: '||SQLERRM;
          RAISE vr_exc_saida;
      END; -- pc_roda_convenio
      
      -- Procedimento para retornar os valores dos seguros de vida, residencia e de automoveis
      PROCEDURE pc_roda_seguro IS
      BEGIN
        DECLARE
          vr_aux_listahis     VARCHAR2(4000) := '';
          vr_tab_seguro SEGU0001.typ_tab_seguro;
          vr_des_reto varchar2(4000);
          vr_tab_info_seguros SEGU0001.typ_tab_info_seguros;
          vr_chave VARCHAR2(14); -- auxiliar para chave a pltable de info seguros
          vr_trocapa BOOLEAN := FALSE; -- auxiliar para troca do PA

        BEGIN
          -- Executa rotina para buscar os valores de parametros para a busca de seguros
          SEGU0001.pc_busca_dados_seg(pr_cdcooper => pr_cdcooper
                                     ,pr_vlrdecom1 => vr_vlrdecom1
                                     ,pr_vlrdecom2 => vr_vlrdecom2
                                     ,pr_vlrdecom3 => vr_vlrdecom3
                                     ,pr_vlrdeiof1 => vr_vlrdeiof1
                                     ,pr_vlrdeiof2 => vr_vlrdeiof2
                                     ,pr_vlrdeiof3 => vr_vlrdeiof3
                                     ,pr_recid1 => vr_recid1
                                     ,pr_recid2 => vr_recid2
                                     ,pr_recid3 => vr_recid3
                                     ,pr_vlrapoli => vr_vlrapoli
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
          
          -- Se encontrou erros, cancela a execucao
          IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;-- Sai da procedure
          END IF;                    
      
          -- Limpa PlTable de seguros
          segu0001.vr_tab_seguro.delete;
          
          -- Historicos que serao usados para lista seguros de Vida e Residencia
          vr_aux_listahis := '#341#175#460#511#';
          
          -- Busca dados dos seguros de Vida e Residencia
          segu0001.pc_seguros_resid_vida(pr_cdcooper => pr_cdcooper
          	                            ,pr_dataini => vr_dataini
                                        ,pr_datafim => vr_datafim
                                        ,pr_cdagenci => 0
                                        ,pr_listahis => vr_aux_listahis
                                        ,pr_tab_seguro => vr_tab_seguro
                                        ,pr_des_reto   => vr_des_reto);
          
                                                  
          -- Passa os seguros que retornaram para a tabela global 
          -- que sera usada pela procedure de seguros auto para 
          -- alimentar a tabela de informacoes de seguros
          segu0001.vr_tab_seguro := vr_tab_seguro;
          
          -- Limpa tabela de info seguros
          vr_tab_info_seguros.delete;
          
          -- Busca dados de seguros auto
          segu0001.pc_seguros_auto(pr_cdcooper => pr_cdcooper 
                                  ,pr_dataini => vr_dataini
                                  ,pr_datafim => vr_datafim
                                  ,pr_cdagenci => 0
                                  ,pr_tpseguro => 2 -- AUTO
                                  ,pr_cdsitseg => 4
                                  ,pr_vlrapoli => vr_vlrapoli
                                  ,pr_vlrdecom1 => vr_vlrdecom1
                                  ,pr_vlrdeiof1 => vr_vlrdeiof1
                                  ,pr_vlrdecom2 => vr_vlrdecom2
                                  ,pr_vlrdeiof2 => vr_vlrdeiof2
                                  ,pr_vlrdecom3 => vr_vlrdecom3
                                  ,pr_vlrdeiof3 => vr_vlrdeiof3
                                  ,pr_tab_seguro => vr_tab_seguro
                                  ,pr_tab_info_seguros => vr_tab_info_seguros
                                  ,pr_des_reto => vr_des_reto);
          -- Leitura da PlTable de info seguros para inserir na crapgpr
          vr_chave := vr_tab_info_seguros.FIRST;
          LOOP
            EXIT WHEN vr_chave IS NULL;
            vr_trocapa := FALSE;

            -- Se o proximo registro existe
            IF vr_tab_info_seguros.next(vr_chave) IS NOT NULL THEN
              -- e o pa é diferente do proximo
              IF vr_tab_info_seguros(vr_chave).cdagenci <> vr_tab_info_seguros(vr_tab_info_seguros.next(vr_chave)).cdagenci OR
                 vr_tab_info_seguros(vr_chave).inpessoa <> vr_tab_info_seguros(vr_tab_info_seguros.next(vr_chave)).inpessoa THEN
                vr_trocapa := TRUE;
              END IF;
            ELSE -- proximo registro nao existe
              vr_trocapa := TRUE;
            END IF;
            
            -- Se trocou o PA, insere dados dos seguros na crapgpr
            IF vr_trocapa THEN
              
              -- Atualiza a pl/table vr_tab_crapgpr para no final do processo atualizar a tabela CRAPGPR
              vr_indice := lpad(vr_tab_info_seguros(vr_chave).cdagenci,5,'0')||lpad(vr_tab_info_seguros(vr_chave).inpessoa,5,'0');
              vr_tab_crapgpr(vr_indice).cdcooper := pr_cdcooper;
              vr_tab_crapgpr(vr_indice).inpessoa := vr_tab_info_seguros(vr_chave).inpessoa;
              vr_tab_crapgpr(vr_indice).cdagenci := vr_tab_info_seguros(vr_chave).cdagenci;
              vr_tab_crapgpr(vr_indice).dtrefere := vr_datafim;

              IF vr_tab_info_seguros(vr_chave).tpseguro = 2 THEN -- auto
                vr_tab_crapgpr(vr_indice).qtsegaut := vr_tab_info_seguros(vr_chave).qtsegaut;
                vr_tab_crapgpr(vr_indice).vlsegaut := vr_tab_info_seguros(vr_chave).vlsegaut;
                vr_tab_crapgpr(vr_indice).vlrecaut := vr_tab_info_seguros(vr_chave).vlrecaut;
                vr_tab_crapgpr(vr_indice).vlrepaut := vr_tab_info_seguros(vr_chave).vlrepaut;  
              END IF;     

              IF vr_tab_info_seguros(vr_chave).tpseguro = 3 THEN -- vida
                vr_tab_crapgpr(vr_indice).qtsegvid := vr_tab_info_seguros(vr_chave).qtsegvid;
                vr_tab_crapgpr(vr_indice).vlsegvid := vr_tab_info_seguros(vr_chave).vlsegvid;
                vr_tab_crapgpr(vr_indice).vlrecvid := vr_tab_info_seguros(vr_chave).vlrecvid;
                vr_tab_crapgpr(vr_indice).vlrepvid := vr_tab_info_seguros(vr_chave).vlrepvid;
                vr_tab_crapgpr(vr_indice).qtincvid := vr_tab_info_seguros(vr_chave).qtincvid;
                vr_tab_crapgpr(vr_indice).qtexcvid := vr_tab_info_seguros(vr_chave).qtexcvid;
              END IF;

              IF vr_tab_info_seguros(vr_chave).tpseguro = 1 OR 
                 vr_tab_info_seguros(vr_chave).tpseguro = 11 THEN -- residencia
                vr_tab_crapgpr(vr_indice).qtsegres := vr_tab_info_seguros(vr_chave).qtsegres;
                vr_tab_crapgpr(vr_indice).vlsegres := vr_tab_info_seguros(vr_chave).vlsegres;
                vr_tab_crapgpr(vr_indice).vlrecres := vr_tab_info_seguros(vr_chave).vlrecres;
                vr_tab_crapgpr(vr_indice).vlrepres := vr_tab_info_seguros(vr_chave).vlrepres;
                vr_tab_crapgpr(vr_indice).qtincres := vr_tab_info_seguros(vr_chave).qtincres;
                vr_tab_crapgpr(vr_indice).qtexcres := vr_tab_info_seguros(vr_chave).qtexcres;
              END IF;

            END IF; -- Troca do PA

            -- Vai para o proximo registro
            vr_chave := vr_tab_info_seguros.NEXT(vr_chave);
          END LOOP; -- FIM da leitura da crapgpr 
                                                            
        EXCEPTION
          WHEN vr_exc_saida THEN
            RAISE vr_exc_saida; 
          WHEN OTHERS THEN 
            vr_dscritic := 'Erro na pc_roda_seguro: '||SQLERRM;
            RAISE vr_exc_saida; 
        END;
      END; -- pc_roda_seguro
      
      -- Procedimento para retorno dos limites dos cartoes de credito.
      PROCEDURE pc_carrega_limites IS
      BEGIN
        DECLARE
          vr_ret_vlcreuso   NUMERIC(25,2) := 0;
          vr_ret_vlsaquso   NUMERIC(25,2) := 0;
          vr_ret_vlcresol   NUMERIC(25,2) := 0;
          vr_ret_vlsaqsol   NUMERIC(25,2) := 0;
          vr_ret_valorcre   NUMERIC(25,2) := 0;
          vr_ret_valordeb   NUMERIC(25,2) := 0;
          vr_ret_vlcancel   NUMERIC(25,2) := 0;
          vr_ret_vltotsaq   NUMERIC(25,2) := 0;
          vr_ret_qtdemuso   PLS_INTEGER := 0;
          vr_ret_qtdsolic   PLS_INTEGER := 0;
          vr_ret_qtcartao   PLS_INTEGER := 0;
          vr_ret_qtcancel   PLS_INTEGER := 0;
          vr_tab_limites    ccrd0001.typ_tab_limites;
          
        BEGIN
         -- Rotina para busca do valor de limite do cartao de credito
         CCRD0001.pc_limite_cartao_credito(pr_cdcooper => pr_cdcooper
                                          ,pr_bradesbb => 0
                                          ,pr_cddopcao => 'C'
                                          ,pr_cdageini => 0
                                          ,pr_cdagefim => 999
                                          ,pr_vllimcon => vr_vllimcon
                                          ,pr_vlcreuso => vr_ret_vlcreuso
                                          ,pr_vlsaquso => vr_ret_vlsaquso
                                          ,pr_vlcresol => vr_ret_vlcresol
                                          ,pr_vlsaqsol => vr_ret_vlsaqsol
                                          ,pr_valorcre => vr_ret_valorcre
                                          ,pr_valordeb => vr_ret_valordeb
                                          ,pr_vlcancel => vr_ret_vlcancel
                                          ,pr_vltotsaq => vr_ret_vltotsaq 
                                          ,pr_qtdemuso => vr_ret_qtdemuso
                                          ,pr_qtdsolic => vr_ret_qtdsolic
                                          ,pr_qtcartao => vr_ret_qtcartao
                                          ,pr_qtcancel => vr_ret_qtcancel
                                          ,pr_tab_limites => vr_tab_limites);   
        
          -- Processa retorno da procedure
          vr_vllimcbb := vr_ret_valorcre;
          vr_vllimdbb := vr_ret_valordeb;
          vr_vlusobbc := vr_ret_vlcreuso;
          vr_vlusobbd := vr_ret_vlsaquso;                                  
          
        EXCEPTION
          WHEN vr_exc_saida THEN
            RAISE vr_exc_saida; 
          WHEN OTHERS THEN 
            vr_dscritic := 'Erro na procedure pc_carrega_limites: ' || sqlerrm;
            raise vr_exc_saida;  
        END;
      END; -- pc_carrega_limites       
     
      -- Retorna os valores referente aos produtos com beneficio de INSS
      PROCEDURE pc_beneficio_inss IS
        vr_tab_result_inss inss0001.typ_tab_result_inss;
        vr_geralcre NUMBER;
        vr_quantger PLS_INTEGER;
        vr_geraldcc NUMBER;
        vr_quantge2 PLS_INTEGER;
        vr_valorger NUMBER;
        vr_geralpa  PLS_INTEGER;
        vr_arqvazio PLS_INTEGER; 
        vr_chave_inss varchar2(6); 
      BEGIN
        -- Busca os valores de inss
        inss0001.pc_beneficios_inss(pr_cdcooper => pr_cdcooper
                                   ,pr_cdageini => 0
                                   ,pr_cdagefim => 999
                                   ,pr_dataini  => vr_dataini
                                   ,pr_datafim  => vr_datafim
                                   ,pr_geralcre => vr_geralcre
                                   ,pr_quantger => vr_quantger
                                   ,pr_geraldcc => vr_geraldcc
                                   ,pr_quantge2 => vr_quantge2
                                   ,pr_valorger => vr_valorger
                                   ,pr_geralpa  => vr_geralpa
                                   ,pr_arqvazio => vr_arqvazio
                                   ,pr_tab_result_inss => vr_tab_result_inss
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
                                   
        IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;-- Sai da procedure
        END IF;                    

        -- Lista a PlTable vr_tab_result_inss
        vr_chave_inss := vr_tab_result_inss.FIRST;
        -- atualiza dados na crapgpr
        LOOP
          EXIT WHEN vr_chave_inss IS NULL;
          
          -- Atualiza a pl/table vr_tab_crapgpr para no final do processo atualizar a tabela CRAPGPR
          vr_indice := lpad(vr_tab_result_inss(vr_chave_inss).cdagenci,5,'0')||'00001';
          vr_tab_crapgpr(vr_indice).cdcooper := vr_tab_result_inss(vr_chave_inss).cdcooper;
          vr_tab_crapgpr(vr_indice).inpessoa := 1;
          vr_tab_crapgpr(vr_indice).cdagenci := vr_tab_result_inss(vr_chave_inss).cdagenci;
          vr_tab_crapgpr(vr_indice).dtrefere := vr_datafim;
          vr_tab_crapgpr(vr_indice).vlnassbe := nvl(vr_tab_crapgpr(vr_indice).vlnassbe,0) + NVL(vr_tab_result_inss(vr_chave_inss).totalcre, 0);
          vr_tab_crapgpr(vr_indice).qtnassbe := nvl(vr_tab_crapgpr(vr_indice).qtnassbe,0) + NVL(vr_tab_result_inss(vr_chave_inss).quantida, 0);
          vr_tab_crapgpr(vr_indice).vlasscbe := nvl(vr_tab_crapgpr(vr_indice).vlasscbe,0) + NVL(vr_tab_result_inss(vr_chave_inss).totaldcc, 0);
          vr_tab_crapgpr(vr_indice).qtasscbe := nvl(vr_tab_crapgpr(vr_indice).qtasscbe,0) + NVL(vr_tab_result_inss(vr_chave_inss).quantid2, 0);

          vr_chave_inss := vr_tab_result_inss.NEXT(vr_chave_inss);
        END LOOP; -- FIM atualiza dados na crapgpr                                     
      EXCEPTION
        WHEN vr_exc_saida THEN
          RAISE vr_exc_saida; 
        
        WHEN OTHERS THEN
          vr_dscritic := 'Erro na procedure pc_beneficios_inss: ' || sqlerrm;
          raise vr_exc_saida; 
      END;  -- FIm pc_beneficio_inss
      
      -- busca os tipos de associados
      PROCEDURE pc_mostra_quantassoci IS
        -- Cursor para agencias dos associados por tipo de pessoa
        CURSOR cr_crapass IS
          SELECT DISTINCT(CRAPASS.CDAGENCI)
                ,CDCOOPER
                ,INPESSOA  
            FROM CRAPASS 
           WHERE CDCOOPER = pr_cdcooper
           --  AND dtdemiss IS NULL -- Retirado na ultima liberacao do CRPS524
           ORDER BY cdagenci, inpessoa;
        rw_crapass cr_crapass%rowtype;
        
        -- CURSOR para consulta de associados na crapger
        CURSOR cr_crapger (pr_cdagenci crapger.cdagenci%type)IS
          SELECT crapger.qtassoci,
                 crapger.qtplanos
            FROM crapger
           WHERE crapger.cdcooper = pr_cdcooper
             AND crapger.dtrefere = vr_datafim
             AND crapger.cdempres = 0
             AND crapger.cdagenci = pr_cdagenci;
        rw_crapger cr_crapger%rowtype;
        
        vr_qtassoci PLS_INTEGER := 0;
        vr_qtasscot PLS_INTEGER := 0;
             
      BEGIN
        -- Lista as agencias e tipos de pessoa dos associados
        OPEN cr_crapass;
        LOOP
          FETCH cr_crapass INTO rw_crapass;
          EXIT WHEN cr_crapass%NOTFOUND;

          -- Busca quantidade de associados na crapger
          OPEN cr_crapger(rw_crapass.cdagenci);
          FETCH cr_crapger
            INTO rw_crapger;
          IF cr_crapger%NOTFOUND THEN
            vr_qtassoci := 0;
            vr_qtasscot := 0;
          ELSE
            vr_qtassoci := rw_crapger.qtassoci;
            vr_qtasscot := rw_crapger.qtplanos;  
          END IF; 
          CLOSE cr_crapger;

          -- Atualiza a pl/table vr_tab_crapgpr para no final do processo atualizar a tabela CRAPGPR
          vr_indice := lpad(rw_crapass.cdagenci,5,'0')||'00000';
          vr_tab_crapgpr(vr_indice).cdcooper := pr_cdcooper;
          vr_tab_crapgpr(vr_indice).inpessoa := 0;
          vr_tab_crapgpr(vr_indice).cdagenci := rw_crapass.cdagenci;
          vr_tab_crapgpr(vr_indice).dtrefere := vr_datafim;
          vr_tab_crapgpr(vr_indice).qtassoci := vr_qtassoci;
          vr_tab_crapgpr(vr_indice).qtasscot := vr_qtasscot;

                              
        END LOOP;
        CLOSE cr_crapass;
      EXCEPTION
        WHEN vr_exc_saida THEN
          RAISE vr_exc_saida;  
        WHEN OTHERS THEN
          vr_dscritic := 'Erro na procedure pc_mostra_quantassoci: ' || sqlerrm;
          raise vr_exc_saida;
      END; -- FIM pc_mostra_quantassoci
      
      -- Procedimento para retorno da quantidade de titulos pagos pela Caixa On-line
      PROCEDURE pc_carrega_titulos_cxonline IS
        -- CURSOR para titulos pagos pelo Caixa On-Line por agencia
        CURSOR cr_craptit IS
          SELECT COUNT(*)as conta, cdagenci
            FROM CRAPTIT
            WHERE  craptit.cdcooper  = pr_cdcooper AND
                   craptit.dtdpagto >= vr_dataini   AND
                   craptit.dtdpagto <= vr_datafim   AND
                   craptit.tpdocmto  = 20           AND
                   craptit.nrdolote >= 16000        AND
                   craptit.nrdolote <= 16999        AND
                   craptit.cdagenci <> 90           AND
                   craptit.cdagenci <> 91           AND
                  (craptit.insittit = 0 OR
                   craptit.insittit = 2 OR
                   craptit.insittit = 4)
             GROUP BY cdagenci 
             ORDER BY cdagenci ;
        rw_craptit cr_craptit%rowtype;
        
      BEGIN
        OPEN cr_craptit;
        -- Lista a quantidade de titulos pagos por agencia
        LOOP
          FETCH cr_craptit INTO rw_craptit;
          EXIT WHEN cr_craptit%NOTFOUND;

          -- Atualiza a pl/table vr_tab_crapgpr para no final do processo atualizar a tabela CRAPGPR
          vr_indice := lpad(rw_craptit.cdagenci,5,'0')||'00000';
          vr_tab_crapgpr(vr_indice).cdcooper := pr_cdcooper;
          vr_tab_crapgpr(vr_indice).inpessoa := 0;
          vr_tab_crapgpr(vr_indice).cdagenci := rw_craptit.cdagenci;
          vr_tab_crapgpr(vr_indice).dtrefere := vr_datafim;
          vr_tab_crapgpr(vr_indice).qttiponl := rw_craptit.conta;
          
        END LOOP;
        CLOSE cr_craptit;
      EXCEPTION
        WHEN vr_exc_saida THEN
          RAISE vr_exc_saida;  
        WHEN OTHERS THEN
          vr_dscritic := 'Erro na procedure pc_carrega_titulos_cxonline: ' || sqlerrm;
          raise vr_exc_saida;
        
      END; -- FIM pc_carrega_titulos_cxonline
      
      -- Procedimento para retorno da quantidade de titulos DDA
      PROCEDURE pc_carrega_dda IS
        
      BEGIN
        -- Busca os dados de DDA e atualiza na CRAPGPR
        DDDA0001.pc_grava_congpr_dda(pr_cdcooper,
                                     vr_dataini,
                                     vr_datafim,
                                     rw_crapdat.dtmvtolt,
                                     vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          vr_dscritic := 'DDDA0001: ' || vr_dscritic;
          RAISE vr_exc_saida;
        END IF;
      END; -- FIM pc_carrega_dda;
      
      -- FIM PROCEDIMENTOS --
                                     
    BEGIN
      -- Informa acesso
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);

      -- Valida a cooperativa
      open cr_crapcop;
      fetch cr_crapcop into rw_crapcop;
      if cr_crapcop%notfound then
        vr_cdcritic := 651;
        close cr_crapcop;
        raise vr_exc_saida;
      end if;
      close cr_crapcop;

      -- Valida a data do programa
      open btch0001.cr_crapdat(pr_cdcooper);
      fetch btch0001.cr_crapdat into rw_crapdat;
      if btch0001.cr_crapdat%notfound then
        vr_cdcritic := 1;
        close btch0001.cr_crapdat;
        raise vr_exc_saida;
      end if;
      close btch0001.cr_crapdat;

      -- Validações iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);
      -- Se a variavel de erro é <> 0
      IF vr_cdcritic <> 0 THEN
        -- Envio centralizado de log de erro
        RAISE vr_exc_saida;
      END IF; 
      
      -- Inicio regra de negocio
      
      -- Monta data
      -- Ultimo dia do mes
      vr_datafim := rw_crapdat.dtultdma;
      -- Primeiro dia do mes
      vr_dataini := trunc(vr_datafim,'mm');
      
      -- Apaga registro da crapgpr
      BEGIN
        DELETE 
          FROM crapgpr
         WHERE crapgpr.cdcooper = pr_cdcooper
           AND crapgpr.dtrefere >= vr_dataini
           AND crapgpr.dtrefere <= vr_datafim;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao apagar registros da crapgpr: ' || SQLERRM;
          raise vr_exc_saida;
      END; -- FIM apaga registros da crapgpr
      
      -- Inicia Loop com cadastro de associados da cooperativa
      OPEN cr_crapass;
      LOOP
        FETCH cr_crapass INTO rw_crapass;
        
        -- Se mudou agencia ou é o ultimo associado do cursor
        -- Faz os tratamentos do LAST OF crapass.cdagenci do progress
        IF (rw_crapass.cdagenci <> vr_aux_cdagenci AND
           vr_aux_cdagenci <> 0) OR
           cr_crapass%NOTFOUND THEN
          
          vr_ultdiau := GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper, --> Cooperativa conectada
                                                      pr_dtmvtolt => vr_datafim, --> Data do movimento
                                                      pr_tipo => 'A',       --> Tipo de busca (P = proximo, A = anterior)
                                                      pr_feriado => TRUE     --> Considerar feriados
                                                      );
            
          -- Conta cartões do BB
          OPEN cr_crawcrd_bb(vr_aux_inpessoa, vr_aux_cdagenci, vr_ultdiau);
          FETCH cr_crawcrd_bb INTO vr_qtdatibb;
          CLOSE cr_crawcrd_bb;
          
          -- Conta cartoes Bradesco
          OPEN cr_crawcrd_bradesco(vr_aux_inpessoa, vr_aux_cdagenci, vr_ultdiau);
          FETCH cr_crawcrd_bradesco INTO vr_qtdaticv;
          CLOSE cr_crawcrd_bradesco;
          
          -- Atualiza a pl/table vr_tab_crapgpr para no final do processo atualizar a tabela CRAPGPR
          vr_indice := lpad(vr_aux_cdagenci,5,'0')||lpad(vr_aux_inpessoa,5,'0');
          vr_tab_crapgpr(vr_indice).cdcooper := pr_cdcooper;
          vr_tab_crapgpr(vr_indice).inpessoa := vr_aux_inpessoa;
          vr_tab_crapgpr(vr_indice).cdagenci := vr_aux_cdagenci;
          vr_tab_crapgpr(vr_indice).dtrefere := vr_datafim;
          vr_tab_crapgpr(vr_indice).qtdatibb := vr_qtdatibb;
          vr_tab_crapgpr(vr_indice).qtdaticv := vr_qtdaticv;
          vr_tab_crapgpr(vr_indice).qtasscob := vr_qtasscob;
          vr_tab_crapgpr(vr_indice).qtbltnet := vr_qtbltnet ;
          vr_tab_crapgpr(vr_indice).vlbltnet := vr_vlbltnet;
          vr_tab_crapgpr(vr_indice).qtcpfcbr := vr_qtcpfcbr;
          vr_tab_crapgpr(vr_indice).qtbpfcbb := vr_qtbpfcbb;
          vr_tab_crapgpr(vr_indice).qtbpfcec := vr_qtbpfcec;
          vr_tab_crapgpr(vr_indice).qtbpftbb := vr_qtbpftbb;
          vr_tab_crapgpr(vr_indice).vlbpftbb := vr_vlbpftbb;
          vr_tab_crapgpr(vr_indice).qtbpftce := vr_qtbpftce;
          vr_tab_crapgpr(vr_indice).vlbpftce := vr_vlbpftce;
          vr_tab_crapgpr(vr_indice).qtbpflcm := vr_qtbpflcm;
          vr_tab_crapgpr(vr_indice).vlbpflcm := vr_vlbpflcm;
          vr_tab_crapgpr(vr_indice).qtbpflco := vr_qtbpflco;
          vr_tab_crapgpr(vr_indice).vlbpflco := vr_vlbpflco;
          vr_tab_crapgpr(vr_indice).vlbpfdda := vr_vlbpfdda;
          vr_tab_crapgpr(vr_indice).qtcpjcbr := vr_qtcpjcbr;
          vr_tab_crapgpr(vr_indice).qtcpjcbb := vr_qtcpjcbb;
          vr_tab_crapgpr(vr_indice).qtbpjcec := vr_qtbpjcec;
          vr_tab_crapgpr(vr_indice).qtbpjtbb := vr_qtbpjtbb;
          vr_tab_crapgpr(vr_indice).vlbpjtbb := vr_vlbpjtbb ;
          vr_tab_crapgpr(vr_indice).qtbpjtce := vr_qtbpjtce;
          vr_tab_crapgpr(vr_indice).vlbpjtce := vr_vlbpjtce;
          vr_tab_crapgpr(vr_indice).qtbpjlcm := vr_qtbpjlcm;
          vr_tab_crapgpr(vr_indice).vlbpjlcm := vr_vlbpjlcm;
          vr_tab_crapgpr(vr_indice).qtbpjlco := vr_qtbpjlco;
          vr_tab_crapgpr(vr_indice).vlbpjlco := vr_vlbpjlco ;
          vr_tab_crapgpr(vr_indice).vlbpjdda := vr_vlbpjdda;
          vr_tab_crapgpr(vr_indice).qtassati := vr_qtassati  ;
          
          
          -- Zera variaveis para proximo associado
          /* cartao bb */
          vr_qtdatibb  := 0;
          vr_qtdaticv  := 0;
          /***boletos ***/
          vr_qtbltnet  := 0; 
          vr_vlbltnet  := 0;
          /** Internet **/
          vr_qtasscob  := 0; 
          /** Cobranca Registrada **/
          vr_qtcpfcbr  := 0;
          vr_qtbpfcbb  := 0;
          vr_qtbpfcec  := 0;
          vr_qtbpftbb  := 0;
          vr_vlbpftbb  := 0;
          vr_qtbpftce  := 0;
          vr_vlbpftce  := 0;
          vr_qtbpflcm  := 0;
          vr_vlbpflcm  := 0;
          vr_qtbpflco  := 0;
          vr_vlbpflco  := 0;
          vr_vlbpfdda  := 0;
          vr_qtcpjcbr  := 0;
          vr_qtcpjcbb  := 0;
          vr_qtbpjcec  := 0;
          vr_qtbpjtbb  := 0;
          vr_vlbpjtbb  := 0;
          vr_qtbpjtce  := 0;
          vr_vlbpjtce  := 0;
          vr_qtbpjlcm  := 0;
          vr_vlbpjlcm  := 0;
          vr_qtbpjlco  := 0;
          vr_vlbpjlco  := 0;
          vr_vlbpjdda  := 0;
          /* CARTAO MAGNETICO */                 
          vr_qtassati  := 0;
          
          -- Sai quando nao houver mais registros
          EXIT WHEN cr_crapass%NOTFOUND;
        END IF;
        
        -- Soma se associado estiver ativo
        if rw_crapass.dtdemiss is null then
          vr_qtassati := vr_qtassati + 1;
        ELSIF pr_cdcooper = 2 THEN
          OPEN cr_craptco(rw_crapass.nrdconta);
          FETCH cr_craptco INTO rw_craptco;
          IF cr_craptco%FOUND THEN
            vr_qtassati := vr_qtassati + 1;
          END IF;
          CLOSE cr_craptco;
        END IF;
      
        vr_flg_qtasscob := TRUE;
        
        -- Zera variaveis para proximo associado
        vr_saquebb := FALSE;
        vr_transbb := FALSE;
        vr_saquevi := FALSE;
        vr_credici := FALSE;
        vr_credire := FALSE;
        
        -- Zera controle da URA para proximo associado
        vr_flagura := FALSE;
        
        -- Verifica se o associado tem algum cadastro de Emissao de Bloquetos
        OPEN cr_crapceb(rw_crapass.nrdconta);
        FETCH cr_crapceb
          INTO rw_crapceb;
        IF cr_crapceb%FOUND THEN  -- Se encontrou algum bloqueto cadastrado
          vr_flgcobra := FALSE;
          -- Faz um for para data de movimento do cursor de titulos para indice
          OPEN cr_titulos(rw_crapass.nrdconta, vr_dataini, vr_datafim);
          LOOP -- Busca titulos por emissao
            FETCH cr_titulos
              INTO rw_titulos;
            EXIT WHEN cr_titulos%NOTFOUND;
             
            IF NOT vr_flgcobra THEN
              vr_flgcobra := TRUE;
            END IF;
              
            -- Verifica se associado eh pessoa fisica
            IF rw_crapass.inpessoa = 1 THEN
              IF rw_titulos.cdbandoc = 1 THEN
                vr_qtbpfcbb := vr_qtbpfcbb + 1;
              ELSIF rw_titulos.cdbandoc = 85 THEN
                vr_qtbpfcec := vr_qtbpfcec + 1;
              END IF;
            ELSE -- Eh pessoa juridica
              IF rw_titulos.cdbandoc = 1 THEN
                vr_qtcpjcbb := vr_qtcpjcbb + 1;
              ELSIF rw_titulos.cdbandoc = 85 THEN
                vr_qtbpjcec := vr_qtbpjcec + 1;
              END IF;
            END IF; -- FIM tipo de pessoa 
          END LOOP; -- FIM busca de titulos por emissao
          CLOSE cr_titulos;
            
          -- Busca titulos pagos
          OPEN cr_titulos_pagos(rw_crapass.nrdconta, vr_dataini, vr_datafim);
          LOOP
            FETCH cr_titulos_pagos
              INTO rw_titulos_pagos;
            EXIT WHEN cr_titulos_pagos%NOTFOUND;
              
            IF rw_titulos_pagos.flgregis = 0 THEN
              CONTINUE;
            END IF;
              
            IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
              IF rw_titulos_pagos.incobran = 5 THEN
                IF rw_titulos_pagos.indpagto = 0 THEN
                  vr_qtbpflcm := vr_qtbpflcm + 1;
                  vr_vlbpflcm := vr_vlbpflcm + rw_titulos_pagos.vldpagto;
                ELSE
                  vr_qtbpflco := vr_qtbpflco + 1;
                  vr_vlbpflco := vr_vlbpflco + rw_titulos_pagos.vldpagto;
                END IF;
                  
                IF rw_titulos_pagos.flgcbdda = 1 THEN
                  vr_vlbpfdda := vr_vlbpfdda + 1;
                END IF;
              END IF; 
            ELSE  -- Pessoa juridica
              IF rw_titulos_pagos.incobran = 5 THEN
                IF rw_titulos_pagos.indpagto = 0 THEN
                  vr_qtbpjlcm := vr_qtbpjlcm + 1;
                  vr_vlbpjlcm := vr_vlbpjlcm + rw_titulos_pagos.vldpagto;
                ELSE
                  vr_qtbpjlco := vr_qtbpjlco + 1;
                  vr_vlbpjlco := vr_vlbpjlco + rw_titulos_pagos.vldpagto;
                END IF;
                  
                IF rw_titulos_pagos.flgcbdda = 1 THEN
                  vr_vlbpjdda := vr_vlbpjdda + 1;
                END IF;
              END IF;
            END IF; -- Fim tipo pessoa
              
          END LOOP; -- FIM busca titulos pagos
          CLOSE cr_titulos_pagos;
            
          -- Busca tarifas de boletos do BB  
          OPEN cr_craplcm_bb(rw_crapass.nrdconta, vr_dataini, vr_datafim);
          FETCH cr_craplcm_bb INTO rw_craplcm_bb;
          CLOSE cr_craplcm_bb;

          -- Busca tarifas de boletos do BB  
          IF rw_crapass.inpessoa = 1 THEN -- Pessoa Fisica
            vr_qtbpftbb := vr_qtbpftbb + rw_craplcm_bb.qtbtbb;
            vr_vlbpftbb := vr_vlbpftbb + rw_craplcm_bb.vlbtbb;
            vr_qtbpftce := vr_qtbpftce + rw_craplcm_bb.qtbtce;
            vr_vlbpftce := vr_vlbpftce + rw_craplcm_bb.vlbtce;
          ELSE
            vr_qtbpjtbb := vr_qtbpjtbb + rw_craplcm_bb.qtbtbb;
            vr_vlbpjtbb := vr_vlbpjtbb + rw_craplcm_bb.vlbtbb;
            vr_qtbpjtce := vr_qtbpjtce + rw_craplcm_bb.qtbtce;
            vr_vlbpjtce := vr_vlbpjtce + rw_craplcm_bb.vlbtce;
          END IF;
            
          
          IF vr_flgcobra THEN
            IF rw_crapass.inpessoa = 1 THEN
              vr_qtcpfcbr := vr_qtcpfcbr + 1;
            ELSE
              vr_qtcpjcbr := vr_qtcpjcbr + 1;
            END IF;
          END IF;
          
        END IF;
        CLOSE cr_crapceb;
      
        -- Passa agencia e inpessoa do associado para variavel de controle
        vr_aux_cdagenci := rw_crapass.cdagenci;
        vr_aux_inpessoa := rw_crapass.inpessoa;
      END LOOP; -- Fim do Loop de associados da cooperativa
      CLOSE cr_crapass;
      
      
      -- Loop para atualizar a quantidade de acessos na net
      FOR rw_craplgm_acesso IN cr_craplgm_acesso(vr_dataini, vr_datafim) LOOP
        -- Atualiza a pl/table vr_tab_crapgpr para no final do processo atualizar a tabela CRAPGPR
        vr_indice := lpad(rw_craplgm_acesso.cdagenci,5,'0')||lpad(rw_craplgm_acesso.inpessoa,5,'0');
        vr_tab_crapgpr(vr_indice).cdcooper := pr_cdcooper;
        vr_tab_crapgpr(vr_indice).inpessoa := rw_craplgm_acesso.inpessoa;
        vr_tab_crapgpr(vr_indice).cdagenci := rw_craplgm_acesso.cdagenci;
        vr_tab_crapgpr(vr_indice).dtrefere := vr_datafim;
        vr_tab_crapgpr(vr_indice).qtassnet := rw_craplgm_acesso.qtassnet;
        vr_tab_crapgpr(vr_indice).qtextnet := rw_craplgm_acesso.qtextnet;
        vr_tab_crapgpr(vr_indice).qtasunet := rw_craplgm_acesso.qtasunet;
      END LOOP;

      -- Soma quantidade de cartoes magneticos do associado independente da situacao 
      FOR rw_crapcrm IN cr_crapcrm(vr_dataini, vr_datafim) LOOP
        -- Atualiza a pl/table vr_tab_crapgpr para no final do processo atualizar a tabela CRAPGPR
        vr_indice := lpad(rw_crapcrm.cdagenci,5,'0')||lpad(rw_crapcrm.inpessoa,5,'0');
        vr_tab_crapgpr(vr_indice).cdcooper := pr_cdcooper;
        vr_tab_crapgpr(vr_indice).inpessoa := rw_crapcrm.inpessoa;
        vr_tab_crapgpr(vr_indice).cdagenci := rw_crapcrm.cdagenci;
        vr_tab_crapgpr(vr_indice).dtrefere := vr_datafim;
        vr_tab_crapgpr(vr_indice).qtentcrm := rw_crapcrm.qt_registros;
      END LOOP;

      -- Soma cartoes magneticos ativos e valor max. de saque do associado
      FOR rw_crapcrm_ativos IN cr_crapcrm_ativos LOOP
        -- Atualiza a pl/table vr_tab_crapgpr para no final do processo atualizar a tabela CRAPGPR
        vr_indice := lpad(rw_crapcrm_ativos.cdagenci,5,'0')||lpad(rw_crapcrm_ativos.inpessoa,5,'0');
        vr_tab_crapgpr(vr_indice).cdcooper := pr_cdcooper;
        vr_tab_crapgpr(vr_indice).inpessoa := rw_crapcrm_ativos.inpessoa;
        vr_tab_crapgpr(vr_indice).cdagenci := rw_crapcrm_ativos.cdagenci;
        vr_tab_crapgpr(vr_indice).dtrefere := vr_datafim;
        vr_tab_crapgpr(vr_indice).qttotcrm := rw_crapcrm_ativos.qt_registros;
      END LOOP;
      
      -- Soma o limite de saque no TAA
      FOR rw_tbtaa_limite_saque IN cr_tbtaa_limite_saque LOOP
        -- Atualiza a pl/table vr_tab_crapgpr para no final do processo atualizar a tabela CRAPGPR
        vr_indice := lpad(rw_tbtaa_limite_saque.cdagenci,5,'0')||lpad(rw_tbtaa_limite_saque.inpessoa,5,'0');
        vr_tab_crapgpr(vr_indice).cdcooper := pr_cdcooper;
        vr_tab_crapgpr(vr_indice).inpessoa := rw_tbtaa_limite_saque.inpessoa;
        vr_tab_crapgpr(vr_indice).cdagenci := rw_tbtaa_limite_saque.cdagenci;
        vr_tab_crapgpr(vr_indice).dtrefere := vr_datafim;
        vr_tab_crapgpr(vr_indice).vllimcrm := rw_tbtaa_limite_saque.vllimite_saque;
      END LOOP;

      -- Loop para buscar o valores de boleto
      FOR rw_cobranca_boleto IN cr_cobranca_boleto(vr_dataini, vr_datafim) LOOP
        -- Atualiza a pl/table vr_tab_crapgpr para no final do processo atualizar a tabela CRAPGPR
        vr_indice := lpad(rw_cobranca_boleto.cdagenci,5,'0')||lpad(rw_cobranca_boleto.inpessoa,5,'0');
        vr_tab_crapgpr(vr_indice).cdcooper := pr_cdcooper;
        vr_tab_crapgpr(vr_indice).inpessoa := rw_cobranca_boleto.inpessoa;
        vr_tab_crapgpr(vr_indice).cdagenci := rw_cobranca_boleto.cdagenci;
        vr_tab_crapgpr(vr_indice).dtrefere := vr_datafim;
        vr_tab_crapgpr(vr_indice).qtbltnet := rw_cobranca_boleto.qt_registros;
        vr_tab_crapgpr(vr_indice).vlbltnet := rw_cobranca_boleto.vltitulo;
      END LOOP;
     
      -- Busca dados da URA
      FOR rw_crapura IN cr_crapura(vr_dataini, vr_datafim) LOOP
        -- Atualiza a pl/table vr_tab_crapgpr para no final do processo atualizar a tabela CRAPGPR
        vr_indice := lpad(rw_crapura.cdagenci,5,'0')||lpad(rw_crapura.inpessoa,5,'0');
        vr_tab_crapgpr(vr_indice).cdcooper := pr_cdcooper;
        vr_tab_crapgpr(vr_indice).inpessoa := rw_crapura.inpessoa;
        vr_tab_crapgpr(vr_indice).cdagenci := rw_crapura.cdagenci;
        vr_tab_crapgpr(vr_indice).dtrefere := vr_datafim;
        vr_tab_crapgpr(vr_indice).qtassura := rw_crapura.qtassura;
        vr_tab_crapgpr(vr_indice).qtconura := rw_crapura.qtconura;
      END LOOP;

      -- Busca boletos pago do BB - Sem registro
      FOR rw_cobrancaBB IN cr_cobrancaBB(vr_dataini, vr_datafim) LOOP
        vr_indice := lpad(rw_cobrancaBB.cdagenci,5,'0')||lpad(rw_cobrancaBB.inpessoa,5,'0');
        vr_tab_crapgpr(vr_indice).cdcooper := pr_cdcooper;
        vr_tab_crapgpr(vr_indice).inpessoa := rw_cobrancaBB.inpessoa;
        vr_tab_crapgpr(vr_indice).cdagenci := rw_cobrancaBB.cdagenci;
        vr_tab_crapgpr(vr_indice).dtrefere := vr_datafim;
        vr_tab_crapgpr(vr_indice).qtdcobbb := rw_cobrancaBB.qtdcobbb;
        vr_tab_crapgpr(vr_indice).vlrcobbb := rw_cobrancaBB.vlrcobbb;
        vr_tab_crapgpr(vr_indice).qtcobonl := rw_cobrancaBB.qtcobonl;
        vr_tab_crapgpr(vr_indice).vlcobonl := rw_cobrancaBB.vlcobonl;
        vr_tab_crapgpr(vr_indice).qtasscob := rw_cobrancaBB.qtasscob;
      END LOOP;

        -- Busca lancamentos de convenios do associado
      FOR rw_craplcm IN cr_craplcm(vr_dataini, vr_datafim) LOOP
        vr_indice := lpad(rw_craplcm.cdagenci,5,'0')||lpad(rw_craplcm.inpessoa,5,'0');
        vr_tab_crapgpr(vr_indice).cdcooper := pr_cdcooper;
        vr_tab_crapgpr(vr_indice).inpessoa := rw_craplcm.inpessoa;
        vr_tab_crapgpr(vr_indice).cdagenci := rw_craplcm.cdagenci;
        vr_tab_crapgpr(vr_indice).dtrefere := vr_datafim;
        vr_tab_crapgpr(vr_indice).qtassqbb := rw_craplcm.qtassqbb;
        vr_tab_crapgpr(vr_indice).qtdsaqbb := rw_craplcm.qtdsaqbb;
        vr_tab_crapgpr(vr_indice).qtasqtbb := rw_craplcm.qtasqtbb;
        vr_tab_crapgpr(vr_indice).vlrsaqbb := rw_craplcm.vlrsaqbb;
        vr_tab_crapgpr(vr_indice).qtasstbb := rw_craplcm.qtasstbb;
        vr_tab_crapgpr(vr_indice).qtdtrsbb := rw_craplcm.qtdtrsbb;
        vr_tab_crapgpr(vr_indice).vlrtrsbb := rw_craplcm.vlrtrsbb;
        vr_tab_crapgpr(vr_indice).qtddebbb := rw_craplcm.qtddebbb;
        vr_tab_crapgpr(vr_indice).vlrdebbb := rw_craplcm.vlrdebbb;
        vr_tab_crapgpr(vr_indice).qtdcrebb := rw_craplcm.qtdcrebb;
        vr_tab_crapgpr(vr_indice).vlrcrebb := rw_craplcm.vlrcrebb;
        vr_tab_crapgpr(vr_indice).qtassqcv := rw_craplcm.qtassqcv;
        vr_tab_crapgpr(vr_indice).qtdsaqcv := rw_craplcm.qtdsaqcv;
        vr_tab_crapgpr(vr_indice).vlrsaqcv := rw_craplcm.vlrsaqcv;
        vr_tab_crapgpr(vr_indice).qtdcrecv := rw_craplcm.qtdcrecv;
        vr_tab_crapgpr(vr_indice).vlrcrecv := rw_craplcm.vlrcrecv;
        vr_tab_crapgpr(vr_indice).qtdanucv := rw_craplcm.qtdanucv;
        vr_tab_crapgpr(vr_indice).vlranucv := rw_craplcm.vlranucv;
        vr_tab_crapgpr(vr_indice).qttrfcob := rw_craplcm.qttrfcob;
        vr_tab_crapgpr(vr_indice).vltrfcob := rw_craplcm.vltrfcob;
        vr_tab_crapgpr(vr_indice).qtasscxa := rw_craplcm.qtasscxa;
        vr_tab_crapgpr(vr_indice).qtsaqcxa := rw_craplcm.qtsaqcxa;
        vr_tab_crapgpr(vr_indice).vlsaqcxa := rw_craplcm.vlsaqcxa;
        vr_tab_crapgpr(vr_indice).qtsaqtaa := rw_craplcm.qtsaqtaa;
        vr_tab_crapgpr(vr_indice).vlsaqtaa := rw_craplcm.vlsaqtaa;
        vr_tab_crapgpr(vr_indice).qttrscxa := rw_craplcm.qttrscxa;
        vr_tab_crapgpr(vr_indice).vltrscxa := rw_craplcm.vltrscxa;
        vr_tab_crapgpr(vr_indice).qttrstaa := rw_craplcm.qttrstaa;
        vr_tab_crapgpr(vr_indice).vltrstaa := rw_craplcm.vltrstaa;
        vr_tab_crapgpr(vr_indice).qtpagcxa := rw_craplcm.qtpagcxa;
        vr_tab_crapgpr(vr_indice).vlpagcxa := rw_craplcm.vlpagcxa;
        vr_tab_crapgpr(vr_indice).qtassvsn := rw_craplcm.qtassvsn;
        vr_tab_crapgpr(vr_indice).qtlanvsn := rw_craplcm.qtlanvsn;
        vr_tab_crapgpr(vr_indice).vllanvsn := rw_craplcm.vllanvsn;
        vr_tab_crapgpr(vr_indice).qtassrcd := rw_craplcm.qtassrcd;
        vr_tab_crapgpr(vr_indice).qtlanrcd := rw_craplcm.qtlanrcd;
        vr_tab_crapgpr(vr_indice).vllanrcd := rw_craplcm.vllanrcd;
        vr_tab_crapgpr(vr_indice).qtchconl := rw_craplcm.qtchconl;
        vr_tab_crapgpr(vr_indice).qtpagnet := rw_craplcm.qtpagnet;
        vr_tab_crapgpr(vr_indice).vlpagnet := rw_craplcm.vlpagnet;
        vr_tab_crapgpr(vr_indice).qttrsnet := rw_craplcm.qttrsnet;
        vr_tab_crapgpr(vr_indice).vltrsnet := rw_craplcm.vltrsnet;
        vr_tab_crapgpr(vr_indice).qttednet := rw_craplcm.qttednet;
        vr_tab_crapgpr(vr_indice).vltednet := rw_craplcm.vltednet;
        vr_tab_crapgpr(vr_indice).qttrinet := rw_craplcm.qttrinet;
        vr_tab_crapgpr(vr_indice).vltrinet := rw_craplcm.vltrinet;
        vr_tab_crapgpr(vr_indice).qttritaa := rw_craplcm.qttritaa;
        vr_tab_crapgpr(vr_indice).vltritaa := rw_craplcm.vltritaa;
        vr_tab_crapgpr(vr_indice).qttricxa := rw_craplcm.qttricxa;
        vr_tab_crapgpr(vr_indice).vltricxa := rw_craplcm.vltricxa;
      END LOOP;
      
      -- Atualiza crapgpr com dados de participacao dos associados
      pc_mostra_participacao;
      
      -- Atualiza crapgpr com dados de convenios dos associados   
      pc_roda_convenio;
      
      -- Atualiza crapgpr com dados de seguros dos associados
      pc_roda_seguro; 
      
      -- Atualiza crapgpr com dados de limites de credito      
      pc_carrega_limites; 
      
      -- Atualiza crapgpr com dados de beneficiarios do inss
      pc_beneficio_inss;  
      
      -- Atualiza crapgpr com dados de quaqntidade de associados por agencia
      pc_mostra_quantassoci;
      
      -- Atualiza crapgpr com dados de quantidade de titulos pagos no caixa online por PA
      pc_carrega_titulos_cxonline;
      
      -- Atualiza crapgpr com dados de DDA.      
      pc_carrega_dda;
    
      -- Atualiza a tabela CRAPGPR com base pl/table vr_tab_crapgpr
      BEGIN
        FORALL idx IN INDICES OF vr_tab_crapgpr SAVE EXCEPTIONS
           INSERT INTO CRAPGPR
             (CDCOOPER,
              INPESSOA,
              DTREFERE,
              CDAGENCI,
              QTDSAQBB,
              QTDTRSBB,
              QTDDEBBB,
              QTDCREBB,
              VLRSAQBB,
              VLRTRSBB,
              VLRDEBBB,
              VLRCREBB,
              QTDATIBB,
              VLLIMCBB,
              VLLIMDBB,
              QTASSQBB,
              QTASSTBB,
              QTASQTBB,
              QTASSQCV,
              QTDSAQCV,
              QTDCRECV,
              QTDANUCV,
              VLRSAQCV,
              VLRCRECV,
              VLRANUCV,
              QTDATICV,
              VLLIMCCV,
              VLLIMDCV,
              QTASSCOB,
              QTDCOBBB,
              VLRCOBBB,
              QTCOBONL,
              VLCOBONL,
              QTTRFCOB,
              VLTRFCOB,
              QTASSCXA,
              QTSAQCXA,
              VLSAQCXA,
              QTTRSCXA,
              VLTRSCXA,
              QTASSURA,
              QTCONURA,
              QTEXTNET,
              QTBLTNET,
              VLBLTNET,
              QTPAGNET,
              VLPAGNET,
              QTTRSNET,
              VLTRSNET,
              QTASSNET,
              QTASSVSN,
              QTLANVSN,
              VLLANVSN,
              QTFATCNV,
              VLFATCNV,
              QTDEBCNV,
              VLDEBCNV,
              QTSEGAUT,
              VLSEGAUT,
              VLRECAUT,
              VLREPAUT,
              QTSEGVID,
              VLSEGVID,
              VLRECVID,
              VLREPVID,
              QTINCVID,
              QTEXCVID,
              QTSEGRES,
              VLSEGRES,
              VLRECRES,
              VLREPRES,
              QTINCRES,
              QTEXCRES,
              QTASSOCI,
              VLUSOCBB,
              VLUSODBB,
              QTASSCBE,
              VLASSCBE,
              QTNASSBE,
              VLNASSBE,
              QTASSRCD,
              QTLANRCD,
              VLLANRCD,
              QTASSCOT,
              QTASSDEB,
              QTASSRPP,
              QTASSEPR,
              VLTOTEPR,
              QTASSESP,
              VLTOTESP,
              QTASSRDA,
              QTASUCXA,
              QTASUNET,
              QTASSDCH,
              QTASSDTI,
              QTDESCCH,
              QTDESCTI,
              VLDESCCH,
              VLDESCTI,
              QTPAGCXA,
              VLPAGCXA,
              QTTIPONL,
              QTCHCONL,
              QTCHCOMP,
              QTDEPCXA,
              VLDEPCXA,
              QTCPFCBR,
              QTBPFCBB,
              QTBPFCEC,
              QTBPFTBB,
              VLBPFTBB,
              QTBPFTCE,
              VLBPFTCE,
              VLBPFLCM,
              QTBPFLCO,
              VLBPFLCO,
              VLBPFDDA,
              QTCPJCBR,
              QTCPJCBB,
              QTBPJCEC,
              QTBPJTBB,
              VLBPJTBB,
              QTCOODDA,
              QTBPGDDA,
              VLBPGDDA,
              QTBPFLCM,
              QTBPJTCE,
              VLBPJTCE,
              QTBPJLCM,
              VLBPJLCM,
              QTBPJLCO,
              VLBPJDDA,
              VLBPJLCO,
              QTASSATI,
              QTTOTCRM,
              QTENTCRM,
              VLLIMCRM,
              QTSAQTAA,
              VLSAQTAA,
              QTTRSTAA,
              VLTRSTAA,
              QTTEDNET,
              VLTEDNET,
              QTTRINET,
              VLTRINET,
              QTTRITAA,
              VLTRITAA,
              QTTRICXA,
              VLTRICXA)
           VALUES
             (vr_tab_crapgpr(idx).CDCOOPER,
              vr_tab_crapgpr(idx).INPESSOA,
              vr_tab_crapgpr(idx).DTREFERE,
              vr_tab_crapgpr(idx).CDAGENCI,
              nvl(vr_tab_crapgpr(idx).QTDSAQBB,0),
              nvl(vr_tab_crapgpr(idx).QTDTRSBB,0),
              nvl(vr_tab_crapgpr(idx).QTDDEBBB,0),
              nvl(vr_tab_crapgpr(idx).QTDCREBB,0),
              nvl(vr_tab_crapgpr(idx).VLRSAQBB,0),
              nvl(vr_tab_crapgpr(idx).VLRTRSBB,0),
              nvl(vr_tab_crapgpr(idx).VLRDEBBB,0),
              nvl(vr_tab_crapgpr(idx).VLRCREBB,0),
              nvl(vr_tab_crapgpr(idx).QTDATIBB,0),
              nvl(decode(vr_tab_crapgpr(idx).INPESSOA,0,0,vr_vllimcbb),0),
              nvl(decode(vr_tab_crapgpr(idx).INPESSOA,0,0,vr_vllimdbb),0),
              nvl(vr_tab_crapgpr(idx).QTASSQBB,0),
              nvl(vr_tab_crapgpr(idx).QTASSTBB,0),
              nvl(vr_tab_crapgpr(idx).QTASQTBB,0),
              nvl(vr_tab_crapgpr(idx).QTASSQCV,0),
              nvl(vr_tab_crapgpr(idx).QTDSAQCV,0),
              nvl(vr_tab_crapgpr(idx).QTDCRECV,0),
              nvl(vr_tab_crapgpr(idx).QTDANUCV,0),
              nvl(vr_tab_crapgpr(idx).VLRSAQCV,0),
              nvl(vr_tab_crapgpr(idx).VLRCRECV,0),
              nvl(vr_tab_crapgpr(idx).VLRANUCV,0),
              nvl(vr_tab_crapgpr(idx).QTDATICV,0),
              nvl(decode(vr_tab_crapgpr(idx).INPESSOA,0,0,vr_vllimcon),0),
              nvl(vr_tab_crapgpr(idx).VLLIMDCV,0),
              nvl(vr_tab_crapgpr(idx).QTASSCOB,0),
              nvl(vr_tab_crapgpr(idx).QTDCOBBB,0),
              nvl(vr_tab_crapgpr(idx).VLRCOBBB,0),
              nvl(vr_tab_crapgpr(idx).QTCOBONL,0),
              nvl(vr_tab_crapgpr(idx).VLCOBONL,0),
              nvl(vr_tab_crapgpr(idx).QTTRFCOB,0),
              nvl(vr_tab_crapgpr(idx).VLTRFCOB,0),
              nvl(vr_tab_crapgpr(idx).QTASSCXA,0),
              nvl(vr_tab_crapgpr(idx).QTSAQCXA,0),
              nvl(vr_tab_crapgpr(idx).VLSAQCXA,0),
              nvl(vr_tab_crapgpr(idx).QTTRSCXA,0),
              nvl(vr_tab_crapgpr(idx).VLTRSCXA,0),
              nvl(vr_tab_crapgpr(idx).QTASSURA,0),
              nvl(vr_tab_crapgpr(idx).QTCONURA,0),
              nvl(vr_tab_crapgpr(idx).QTEXTNET,0),
              nvl(vr_tab_crapgpr(idx).QTBLTNET,0),
              nvl(vr_tab_crapgpr(idx).VLBLTNET,0),
              nvl(vr_tab_crapgpr(idx).QTPAGNET,0),
              nvl(vr_tab_crapgpr(idx).VLPAGNET,0),
              nvl(vr_tab_crapgpr(idx).QTTRSNET,0),
              nvl(vr_tab_crapgpr(idx).VLTRSNET,0),
              nvl(vr_tab_crapgpr(idx).QTASSNET,0),
              nvl(vr_tab_crapgpr(idx).QTASSVSN,0),
              nvl(vr_tab_crapgpr(idx).QTLANVSN,0),
              nvl(vr_tab_crapgpr(idx).VLLANVSN,0),
              nvl(vr_tab_crapgpr(idx).QTFATCNV,0),
              nvl(vr_tab_crapgpr(idx).VLFATCNV,0),
              nvl(vr_tab_crapgpr(idx).QTDEBCNV,0),
              nvl(vr_tab_crapgpr(idx).VLDEBCNV,0),
              nvl(vr_tab_crapgpr(idx).QTSEGAUT,0),
              nvl(vr_tab_crapgpr(idx).VLSEGAUT,0),
              nvl(vr_tab_crapgpr(idx).VLRECAUT,0),
              nvl(vr_tab_crapgpr(idx).VLREPAUT,0),
              nvl(vr_tab_crapgpr(idx).QTSEGVID,0),
              nvl(vr_tab_crapgpr(idx).VLSEGVID,0),
              nvl(vr_tab_crapgpr(idx).VLRECVID,0),
              nvl(vr_tab_crapgpr(idx).VLREPVID,0),
              nvl(vr_tab_crapgpr(idx).QTINCVID,0),
              nvl(vr_tab_crapgpr(idx).QTEXCVID,0),
              nvl(vr_tab_crapgpr(idx).QTSEGRES,0),
              nvl(vr_tab_crapgpr(idx).VLSEGRES,0),
              nvl(vr_tab_crapgpr(idx).VLRECRES,0),
              nvl(vr_tab_crapgpr(idx).VLREPRES,0),
              nvl(vr_tab_crapgpr(idx).QTINCRES,0),
              nvl(vr_tab_crapgpr(idx).QTEXCRES,0),
              nvl(vr_tab_crapgpr(idx).QTASSOCI,0),
              nvl(decode(vr_tab_crapgpr(idx).INPESSOA,0,0,vr_vlusobbc),0),
              nvl(decode(vr_tab_crapgpr(idx).INPESSOA,0,0,vr_vlusobbd),0),
              nvl(vr_tab_crapgpr(idx).QTASSCBE,0),
              nvl(vr_tab_crapgpr(idx).VLASSCBE,0),
              nvl(vr_tab_crapgpr(idx).QTNASSBE,0),
              nvl(vr_tab_crapgpr(idx).VLNASSBE,0),
              nvl(vr_tab_crapgpr(idx).QTASSRCD,0),
              nvl(vr_tab_crapgpr(idx).QTLANRCD,0),
              nvl(vr_tab_crapgpr(idx).VLLANRCD,0),
              nvl(vr_tab_crapgpr(idx).QTASSCOT,0),
              nvl(vr_tab_crapgpr(idx).QTASSDEB,0),
              nvl(vr_tab_crapgpr(idx).QTASSRPP,0),
              nvl(vr_tab_crapgpr(idx).QTASSEPR,0),
              nvl(vr_tab_crapgpr(idx).VLTOTEPR,0),
              nvl(vr_tab_crapgpr(idx).QTASSESP,0),
              nvl(vr_tab_crapgpr(idx).VLTOTESP,0),
              nvl(vr_tab_crapgpr(idx).QTASSRDA,0),
              nvl(vr_tab_crapgpr(idx).QTASUCXA,0),
              nvl(vr_tab_crapgpr(idx).QTASUNET,0),
              nvl(vr_tab_crapgpr(idx).QTASSDCH,0),
              nvl(vr_tab_crapgpr(idx).QTASSDTI,0),
              nvl(vr_tab_crapgpr(idx).QTDESCCH,0),
              nvl(vr_tab_crapgpr(idx).QTDESCTI,0),
              nvl(vr_tab_crapgpr(idx).VLDESCCH,0),
              nvl(vr_tab_crapgpr(idx).VLDESCTI,0),
              nvl(vr_tab_crapgpr(idx).QTPAGCXA,0),
              nvl(vr_tab_crapgpr(idx).VLPAGCXA,0),
              nvl(vr_tab_crapgpr(idx).QTTIPONL,0),
              nvl(vr_tab_crapgpr(idx).QTCHCONL,0),
              nvl(vr_tab_crapgpr(idx).QTCHCOMP,0),
              nvl(vr_tab_crapgpr(idx).QTDEPCXA,0),
              nvl(vr_tab_crapgpr(idx).VLDEPCXA,0),
              nvl(vr_tab_crapgpr(idx).QTCPFCBR,0),
              nvl(vr_tab_crapgpr(idx).QTBPFCBB,0),
              nvl(vr_tab_crapgpr(idx).QTBPFCEC,0),
              nvl(vr_tab_crapgpr(idx).QTBPFTBB,0),
              nvl(vr_tab_crapgpr(idx).VLBPFTBB,0),
              nvl(vr_tab_crapgpr(idx).QTBPFTCE,0),
              nvl(vr_tab_crapgpr(idx).VLBPFTCE,0),
              nvl(vr_tab_crapgpr(idx).VLBPFLCM,0),
              nvl(vr_tab_crapgpr(idx).QTBPFLCO,0),
              nvl(vr_tab_crapgpr(idx).VLBPFLCO,0),
              nvl(vr_tab_crapgpr(idx).VLBPFDDA,0),
              nvl(vr_tab_crapgpr(idx).QTCPJCBR,0),
              nvl(vr_tab_crapgpr(idx).QTCPJCBB,0),
              nvl(vr_tab_crapgpr(idx).QTBPJCEC,0),
              nvl(vr_tab_crapgpr(idx).QTBPJTBB,0),
              nvl(vr_tab_crapgpr(idx).VLBPJTBB,0),
              nvl(vr_tab_crapgpr(idx).QTCOODDA,0),
              nvl(vr_tab_crapgpr(idx).QTBPGDDA,0),
              nvl(vr_tab_crapgpr(idx).VLBPGDDA,0),
              nvl(vr_tab_crapgpr(idx).QTBPFLCM,0),
              nvl(vr_tab_crapgpr(idx).QTBPJTCE,0),
              nvl(vr_tab_crapgpr(idx).VLBPJTCE,0),
              nvl(vr_tab_crapgpr(idx).QTBPJLCM,0),
              nvl(vr_tab_crapgpr(idx).VLBPJLCM,0),
              nvl(vr_tab_crapgpr(idx).QTBPJLCO,0),
              nvl(vr_tab_crapgpr(idx).VLBPJDDA,0),
              nvl(vr_tab_crapgpr(idx).VLBPJLCO,0),
              nvl(vr_tab_crapgpr(idx).QTASSATI,0),
              nvl(vr_tab_crapgpr(idx).QTTOTCRM,0),
              nvl(vr_tab_crapgpr(idx).QTENTCRM,0),
              nvl(vr_tab_crapgpr(idx).VLLIMCRM,0),
              nvl(vr_tab_crapgpr(idx).QTSAQTAA,0),
              nvl(vr_tab_crapgpr(idx).VLSAQTAA,0),
              nvl(vr_tab_crapgpr(idx).QTTRSTAA,0),
              nvl(vr_tab_crapgpr(idx).VLTRSTAA,0),
              nvl(vr_tab_crapgpr(idx).QTTEDNET,0),
              nvl(vr_tab_crapgpr(idx).VLTEDNET,0),
              nvl(vr_tab_crapgpr(idx).QTTRINET,0),
              nvl(vr_tab_crapgpr(idx).VLTRINET,0),
              nvl(vr_tab_crapgpr(idx).QTTRITAA,0),
              nvl(vr_tab_crapgpr(idx).VLTRITAA,0),
              nvl(vr_tab_crapgpr(idx).QTTRICXA,0),
              nvl(vr_tab_crapgpr(idx).VLTRICXA,0));
       EXCEPTION
         WHEN OTHERS THEN
           -- Gerar erro
           vr_dscritic := 'Erro ao inserir na tabela crapgpr. '||
                          SQLERRM(-(SQL%BULK_EXCEPTIONS(1).ERROR_CODE));
           RAISE vr_exc_saida;
       END;
      
      -- Fim regra de negocio
      -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);
                                 
      COMMIT;                                 
    EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_dscritic );
        END IF;
        -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);
        -- Efetuar commit
        COMMIT;

      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos código e critica encontradas
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;

     WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
  END PC_CRPS524;
/

