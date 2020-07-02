declare 
 -- Local variables here 
  vr_dserro   VARCHAR2(100); 
  vr_dscritic VARCHAR2(4000); 
  vr_cdcritic INTEGER:=0;
  vr_nrremret crapcre.nrremret%type;
  vr_nrseqreg INTEGER;
  vr_nrretcoo INTEGER;
  vr_dtcretit DATE;
 
 
  CURSOR cr_crapcob IS  
   SELECT c.*, c.rowid
  FROM crapcob c
 WHERE (c.cdcooper = 5
   AND  c.nrdconta = 158828
   AND  c.nrdocmto = 8235
   AND  c.incobran = 0) 
    OR (c.cdcooper = 13
   AND  c.nrdconta = 61352
   AND  c.nrdocmto = 356
   AND  c.incobran = 0) 
    OR (c.cdcooper = 7
   AND  c.nrdconta = 243760
   AND  c.nrdocmto = 2
   AND  c.incobran = 0) 
    OR (c.cdcooper = 12
   AND  c.nrdconta = 136719
   AND  c.nrdocmto = 8
   AND  c.incobran = 0 ) 
    OR (c.cdcooper = 9
   AND  c.nrdconta = 139971
   AND  c.nrdocmto = 9683101
   AND  c.incobran = 0) 
    OR (c.cdcooper = 9
   AND  c.nrdconta = 269468
   AND  c.nrdocmto = 16
   AND  c.incobran = 0) 
    OR (c.cdcooper = 1
   AND  c.nrdconta = 2976277
   AND  c.nrdocmto = 9613
   AND  c.incobran = 0) 
    OR (c.cdcooper = 1
   AND  c.nrdconta = 7368500
   AND  c.nrdocmto = 1187
   AND  c.incobran = 0 ) 
    OR (c.cdcooper = 1
   AND  c.nrdconta = 7368500
   AND  c.nrdocmto = 1175
   AND  c.incobran = 0   ) 
    OR (c.cdcooper = 1
   AND  c.nrdconta = 9781773
   AND  c.nrdocmto = 5524
   AND  c.incobran = 0   ) 
    OR (c.cdcooper = 1
   AND  c.nrdconta = 7918330
   AND  c.nrdocmto = 347
   AND  c.incobran = 0   ) 
   ORDER BY c.CDCOOPER, c.NRDCONTA, c.DSDOCCOP, c.NRDOCMTO; 
   
  CURSOR cr_crapcob_sem_situacao IS  
   SELECT c.*, c.rowid
  FROM crapcob c
 WHERE (c.cdcooper = 5
   AND  c.nrdconta = 158828
   AND  c.nrdocmto = 8235)
    OR (c.cdcooper = 13
   AND  c.nrdconta = 61352
   AND  c.nrdocmto = 356)
    OR (c.cdcooper = 7
   AND  c.nrdconta = 243760
   AND  c.nrdocmto = 2)
    OR (c.cdcooper = 12
   AND  c.nrdconta = 136719
   AND  c.nrdocmto = 8)  
    OR (c.cdcooper = 9
   AND  c.nrdconta = 139971
   AND  c.nrdocmto = 9683101)
    OR (c.cdcooper = 9
   AND  c.nrdconta = 269468
   AND  c.nrdocmto = 16)
    OR (c.cdcooper = 1
   AND  c.nrdconta = 2976277
   AND  c.nrdocmto = 9613)
    OR (c.cdcooper = 1
   AND  c.nrdconta = 7368500
   AND  c.nrdocmto = 1187)
    OR (c.cdcooper = 1
   AND  c.nrdconta = 7368500
   AND  c.nrdocmto = 1175)
    OR (c.cdcooper = 1
   AND  c.nrdconta = 9781773
   AND  c.nrdocmto = 5524)
    OR (c.cdcooper = 1
   AND  c.nrdconta = 7918330
   AND  c.nrdocmto = 347)
   ORDER BY c.CDCOOPER, c.NRDCONTA, c.DSDOCCOP, c.NRDOCMTO;    
  
  CURSOR cr_crapcre (pr_cdcooper in integer 
                    ,pr_nrcnvcob in integer 
                    ,pr_dtmvtolt in date) is 
  select cre.nrremret
  from crapcre cre
  where cre.cdcooper = pr_cdcooper
  and   cre.nrcnvcob = pr_nrcnvcob
  and   cre.dtmvtolt = pr_dtmvtolt
  and   cre.intipmvt = 2;

   -- Seleciona os dados da Cooperativa
   CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
   SELECT crapcop.cdagectl
     FROM crapcop crapcop
    WHERE crapcop.cdcooper = pr_cdcooper;
   rw_crapcop cr_crapcop%ROWTYPE;


   PROCEDURE pc_atualiza_cob(pr_cdcooper   IN crapcob.cdcooper%TYPE, --> Identificador da analise
                             pr_nrdconta   IN crapcob.nrdconta%TYPE,                                     --> Tempo em segundos que irá aguardar na fila
                             pr_nrcnvcob   IN crapcob.nrcnvcob%TYPE,
                             pr_nrdocmto   IN crapcob.nrdocmto%TYPE ) IS
    
     vr_vldpagto crapcob.vldpagto%TYPE;
   BEGIN
     
     vr_vldpagto := 0;
     
     IF   pr_cdcooper = 5 
      AND pr_nrdconta = 158828
      AND pr_nrdocmto = 8235 THEN
      vr_vldpagto := 1598;
     END IF;
   
     IF   pr_cdcooper = 13 
      AND pr_nrdconta = 61352
      AND pr_nrdocmto = 356 THEN
      vr_vldpagto := 193.33;
     END IF;

     IF   pr_cdcooper = 7 
      AND pr_nrdconta = 243760
      AND pr_nrdocmto = 2 THEN
      vr_vldpagto := 524.39;
     END IF;
   
     IF   pr_cdcooper = 12
      AND pr_nrdconta = 136719
      AND pr_nrdocmto = 8 THEN
      vr_vldpagto := 8500;
     END IF;
     
     IF   pr_cdcooper = 9
      AND pr_nrdconta = 139971
      AND pr_nrdocmto = 9683101 THEN
      vr_vldpagto := 906.66;
     END IF;
     
     IF   pr_cdcooper = 9
      AND pr_nrdconta = 269468
      AND pr_nrdocmto = 16 THEN
      vr_vldpagto := 6500;
     END IF;
   
     IF   pr_cdcooper = 1
      AND pr_nrdconta = 2976277
      AND pr_nrdocmto = 9613 THEN
      vr_vldpagto := 1508.21;
     END IF;
     
     IF   pr_cdcooper = 1
      AND pr_nrdconta = 7368500
      AND pr_nrdocmto = 1187 THEN
      vr_vldpagto := 459.68;
     END IF;
     
     IF   pr_cdcooper = 1
      AND pr_nrdconta = 7368500
      AND pr_nrdocmto = 1175 THEN
      vr_vldpagto := 407.55;
     END IF;
     
     IF   pr_cdcooper = 1
      AND pr_nrdconta = 9781773
      AND pr_nrdocmto = 5524 THEN
      vr_vldpagto := 724.35;
     END IF;
     
     IF   pr_cdcooper = 1
      AND pr_nrdconta = 7918330
      AND pr_nrdocmto = 347 THEN
      vr_vldpagto := 246.26;
     END IF;
     
     UPDATE crapcob 
        SET incobran = 5, 
            dtdpagto = vr_dtcretit,
            vldpagto = vr_vldpagto,
      cdbanpag = 85,
      cdagepag = 103      
      WHERE cdcooper = pr_cdcooper 
        AND nrdconta = pr_nrdconta 
        AND nrcnvcob = pr_nrcnvcob 
        AND nrdocmto = pr_nrdocmto;     
   EXCEPTION
     WHEN OTHERS THEN
       ROLLBACK;
   END pc_atualiza_cob;

   
BEGIN 

 dbms_output.put_line('Situacao (0=A, 3=B, 5=L) - Cooperativa - Conta - Convenio - Boleto - Documento'); 

 vr_dtcretit:= to_date('21/01/2020','dd/mm/rrrr');
 -- Test statements here 
 FOR rw IN cr_crapcob LOOP 

   dbms_output.put_line(rw.incobran || ' - ' || 
   rw.cdcooper || ' - ' || 
   rw.nrdconta || ' - ' || 
   rw.nrcnvcob || ' - ' || 
   rw.nrdocmto || ' - ' || 
   rw.dsdoccop || ' - ' || 
   rw.nrnosnum ); 

   /* Atualiza situação na cobrança para liquidadeo*/
   pc_atualiza_cob(pr_cdcooper => rw.cdcooper,
                   pr_nrdconta => rw.nrdconta,
                   pr_nrcnvcob => rw.nrcnvcob,
                   pr_nrdocmto => rw.nrdocmto ); 
 
   /* Gera o log Liquidacao em cartório*/
   paga0001.pc_cria_log_cobranca(pr_idtabcob => rw.rowid 
                               , pr_cdoperad => '1' 
                               , pr_dtmvtolt => trunc(SYSDATE) 
                               , pr_dsmensag => 'Liquidacao - Em Cartorio' 
                               , pr_des_erro => vr_dserro 
                               , pr_dscritic => vr_dscritic ); 
                 
   /* Cria registro na dda pra atualizar status na cip*/   
   paga0001.pc_solicita_crapdda(rw.cdcooper, trunc(SYSDATE) , rw.rowid , vr_dscritic);
   
   /* Retirar o boleto da conciliação na tela manprt */    
   update tbcobran_retorno_ieptb set dtconciliacao = trunc(sysdate)
   where cdcooper = rw.cdcooper
   and nrdconta = rw.nrdconta
   and nrcnvcob = rw.nrcnvcob
   and nrdocmto = rw.nrdocmto
   and tpocorre = '1';
   
   /*Busca numero da remessa*/
   vr_nrremret:= 0;
   open cr_crapcre(rw.cdcooper, rw.nrcnvcob, vr_dtcretit);
   fetch cr_crapcre into vr_nrremret;
   close cr_crapcre;  
   --
   vr_nrseqreg:= 0;
   select nvl(max(ret.nrseqreg),0) + 1 into vr_nrseqreg
   from crapret ret
   where ret.cdcooper = rw.cdcooper
   and   ret.nrcnvcob = rw.nrcnvcob
   and    ret.nrremret = vr_nrremret;    
   --
   open cr_crapcop (rw.cdcooper);
   fetch cr_crapcop into rw_crapcop;
   close cr_crapcop;
   --
   paga0001.pc_prep_retorno_cooperado (pr_idregcob => rw.rowid--ROWID da cobranca
                                      ,pr_cdocorre => 6       --Codigo Ocorrencia
                                      ,pr_dsmotivo => '08'    --Descricao Motivo
                                      ,pr_dtmvtolt => vr_dtcretit --Data Movimento
                                      ,pr_cdoperad => '1'--Codigo Operador
                                      ,pr_nrremret => vr_nrretcoo --Numero Remessa
                                      ,pr_cdcritic => vr_cdcritic --Codigo Critica
                                      ,pr_dscritic => vr_dscritic);

   --  
   paga0001.pc_grava_retorno (pr_cdcooper=> rw.cdcooper  --Codigo Cooperativa
                             ,pr_nrcnvcob=> rw.nrcnvcob  --Numero Convenio Cobranca
                             ,pr_nrdconta=> rw.nrdconta --Numero da Conta
                             ,pr_nrdocmto=> rw.nrdocmto --Numero documento
                             ,pr_nrnosnum=> rw.nrnosnum --Nosso Numero
                             ,pr_cdocorre=> 6           --Codigo Ocorrencia
                             ,pr_dsmotivo=> '08'        --Descricao Motivo
                             ,pr_nrremret=> vr_nrremret --Numero remessa retorno
                             ,pr_nrseqreg=> vr_nrseqreg --pr_nrseqreg --Sequencial do registro ????
                             ,pr_nrispbrc=> rw.nrispbrc --Numero ISPB do recebedor
                             ,pr_cdbcorec=> 85          --Codigo banco recebedor ????
                             ,pr_cdagerec=> rw_crapcop.cdagectl --Codigo Agencia recebedora ????
                             ,pr_cdbcocor=> 0            --Codigo Banco ????
                             ,pr_nrretcoo=> vr_nrretcoo  --Numero retorno cooperativa
                             ,pr_dtcredit=> vr_dtcretit --Data Credito     ????
                             ,pr_flcredit=> true           --Flag Creditado
                             ,pr_vlabatim=> rw.vlabatim --Valor abatimentos
                             ,pr_vldescto=> rw.vldescto --Valor descontos
                             ,pr_vljurmul=> 0           --Valor Juros ????
                             ,pr_vloutcre=> rw.vloutcre --Valor saida credito
                             ,pr_vloutdes=> rw.vloutdeb --pr_vloutdes --Valor saida debito ????
                             ,pr_vlrliqui=> rw.vldpagto --Valor liquidacao ????
                             ,pr_vlrpagto=> rw.vldpagto --pr_vlrpagto --Valor Pagamento ????
                             ,pr_vltarifa=> rw.vltarifa --Valor tarifa
                             ,pr_vltitulo=> rw.vltitulo --Valor titulo
                             ,pr_cdoperad=> '1'           --Codigo operador
                             ,pr_dtmvtolt=> vr_dtcretit --Data Movimento ????
                             ,pr_dtocorre=> vr_dtcretit --Data Ocorrencia ????
                             ,pr_inestcri=> 0           --Estado crise
                             ,pr_cdcritic=> vr_cdcritic
                             ,pr_dscritic=> vr_dscritic);

   dbms_output.put_line(vr_dscritic);                             

   COMMIT; 

 END LOOP; 

  /* Retirar os Teds da conciliação na tela manprt*/
  UPDATE tbfin_recursos_movimento t
  SET t.dtconciliacao = (SELECT dtmvtolt FROM crapdat WHERE cdcooper = 3)
  WHERE
  idlancto = 22385 OR
  idlancto = 23871 OR
  idlancto = 22580;
   
 dbms_output.put_line(' '); 
 dbms_output.put_line('Apos atualizacao'); 

 FOR rw IN cr_crapcob_sem_situacao LOOP 

   dbms_output.put_line(rw.incobran || ' - ' || 
   rw.cdcooper || ' - ' || 
   rw.nrdconta || ' - ' || 
   rw.nrcnvcob || ' - ' || 
   rw.nrdocmto || ' - ' || 
   rw.dsdoccop || ' - ' || 
   rw.nrnosnum); 

 END LOOP; 

 COMMIT; 

EXCEPTION 
 WHEN OTHERS THEN 
   ROLLBACK; 
   RAISE; 
END;
