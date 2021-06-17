PL/SQL Developer Test script 3.0
356
DECLARE

  pr_nmdireto VARCHAR2(200) := '/micros/cecred/odirlei/arq';
  pr_nmarquiv VARCHAR2(200) := 'importacao_cyber.csv';

  vr_posicao_chave NUMBER(4) := 5;
  vr_qtdcar_chave  NUMBER(2) := 24;
  vr_nrdlinha      NUMBER(10) := 0;
  vr_des_erro      VARCHAR2(4000);

  -- Local variables here
  i             INTEGER;
  vr_input_file utl_file.file_type;
  vr_setlinha   VARCHAR2(2000);
  vr_sql        VARCHAR2(4000);

  -- Variáveis para armazenar as informações 
  vr_desclob CLOB;
  vr_descloberro CLOB;
  -- Variável para armazenar os dados antes de incluir no CLOB
  vr_txtcompl   VARCHAR2(32600);
  vr_dsdlinha   VARCHAR2(32600);
  vr_tab_campos gene0002.typ_split;

  vr_cdcooper      crapcyb.cdcooper%TYPE;
  vr_cdorigem      crapcyb.cdorigem%TYPE;
  vr_nrdconta      crapcyb.nrdconta%TYPE;
  vr_NRCTREMP      crapcyb.nrctremp%TYPE;
  vr_flgjudicatual VARCHAR2(10);
  vr_flextjudatual VARCHAR2(10);
  vr_flgehvipatual VARCHAR2(10);
  vr_flgjudicnovo  VARCHAR2(10);
  vr_flextjudnovo  VARCHAR2(10);
  vr_flgehvipnovo  VARCHAR2(10);
  vr_dsmsglog      VARCHAR2(1000);
  vr_rowid         VARCHAR2(100);
  vr_dsassessnovo  VARCHAR2(100);
  vr_cdassessnovo  NUMBER;
  vr_cdassessatual VARCHAR2(100);
  vr_exc_erro EXCEPTION;

  -- Subrotina para escrever texto na variável CLOB 
  PROCEDURE pc_escreve_linha(pr_dsdlinha IN VARCHAR2
                            ,pr_fechaarq IN BOOLEAN DEFAULT FALSE) IS
    vr_des_dados VARCHAR2(32000);
  BEGIN
    vr_des_dados := pr_dsdlinha;
    gene0002.pc_escreve_xml(vr_desclob,
                            vr_txtcompl,
                            vr_des_dados,
                            pr_fechaarq);
  END;
  
  PROCEDURE pc_escreve_linhaerro(pr_dsdlinha IN VARCHAR2
                            ,pr_fechaarq IN BOOLEAN DEFAULT FALSE) IS
    vr_des_dados VARCHAR2(32000);
  BEGIN
    vr_des_dados := pr_dsdlinha;
    gene0002.pc_escreve_xml(vr_descloberro,
                            vr_txtcompl,
                            vr_des_dados||chr(13),
                            pr_fechaarq);
  END;
  
  
  FUNCTION LIMPA_CAMPO(pr_texto IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN REPLACE(REPLACE(ltrim(rtrim(nvl(pr_texto, 'N'))), chr(10)),
                   chr(13));
  END;
  FUNCTION LIMPA_CAMPO2(pr_texto IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN REPLACE(REPLACE(ltrim(rtrim(pr_texto)), chr(10)),
                   chr(13));
  END;
BEGIN

  vr_nrdlinha := 0;
  -- Inicializar o CLOB
  vr_desclob := NULL;
  dbms_lob.createtemporary(vr_desclob, TRUE);
  dbms_lob.open(vr_desclob, dbms_lob.lob_readwrite);
  
  
  vr_descloberro := NULL;
  dbms_lob.createtemporary(vr_descloberro, TRUE);
  dbms_lob.open(vr_descloberro, dbms_lob.lob_readwrite);
  
  --Abrir o arquivo lido
  gene0001.pc_abre_arquivo(pr_nmdireto => pr_nmdireto --> Diretório do arquivo
                          ,
                           pr_nmarquiv => pr_nmarquiv --> Nome do arquivo
                          ,
                           pr_tipabert => 'R' --> Modo de abertura (R,W,A)
                          ,
                           pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                          ,
                           pr_des_erro => vr_des_erro); --> Erro

  IF vr_des_erro IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;
  i := 0;
  --dbms_output.put_line('COOPERATIVA;CONTA;CONTRATO;ORIGEM;ASSESS NOVA;');
  LOOP
    i := i + 1;
    --Verificar se o arquivo está aberto
    IF utl_file.IS_OPEN(vr_input_file) THEN
      BEGIN
      
        -- Le os dados do arquivo e coloca na variavel vr_setlinha
        gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                    ,
                                     pr_des_text => vr_setlinha); --> Texto lido
      
        IF i = 1 THEN        
          pc_escreve_linha(pr_dsdlinha => vr_setlinha, pr_fechaarq => TRUE);
          pc_escreve_linhaerro(pr_dsdlinha => vr_setlinha, pr_fechaarq => TRUE);
          CONTINUE;
        END IF;
        vr_tab_campos := gene0002.fn_quebra_string(pr_string  => vr_setlinha,
                                                   pr_delimit => ';');
        vr_cdcooper   := vr_tab_campos(6);
        vr_cdorigem   := vr_tab_campos(7);
        vr_nrdconta   := vr_tab_campos(8);
        vr_NRCTREMP   := LIMPA_CAMPO2(vr_tab_campos(9));
        vr_flgjudicnovo := LIMPA_CAMPO(vr_tab_campos(4));
        vr_flextjudnovo := LIMPA_CAMPO(vr_tab_campos(3));
        vr_flgehvipnovo := LIMPA_CAMPO(vr_tab_campos(5));
        vr_dsassessnovo := LIMPA_CAMPO2(vr_tab_campos(2));
        
        BEGIN
          SELECT CASE c.flgjudic WHEN 0 THEN 'N' ELSE 'S' END flgjudic 
                ,CASE c.flextjud WHEN 0 THEN 'N' ELSE 'S' END flextjud
                ,CASE c.flgehvip WHEN 0 THEN 'N' ELSE 'S' END flgehvip
            INTO vr_flgjudicatual
                ,vr_flextjudatual
                ,vr_flgehvipatual
            FROM crapcyb c
           WHERE c.nrdconta = vr_nRdconta
             AND c.cdcooper = vr_cdcooper
             AND c.nrctremp = vr_nrctremp
             AND c.cdorigem = vr_cdorigem;
        EXCEPTION
          WHEN no_data_found THEN
            IF vr_flgjudicnovo = 'S' OR
              vr_flextjudnovo = 'S' OR
              vr_flgehvipnovo = 'S' OR
              vr_dsassessnovo IS NOT NULL THEN
              pc_escreve_linhaerro(LIMPA_CAMPO2(vr_setlinha)||'; não encontrada na crapcyb;', TRUE);
            END IF;
            CONTINUE;
        END;
        
        BEGIN
          SELECT c.cdassess
            INTO vr_cdassessatual
            FROM crapcyc c
           WHERE c.nrdconta = vr_nRdconta
             AND c.cdcooper = vr_cdcooper
             AND c.nrctremp = vr_nrctremp
             AND c.cdorigem = vr_cdorigem;
        EXCEPTION
          WHEN no_data_found THEN
            vr_cdassessatual := 0;
        END;
        
        IF vr_dsassessnovo IS NULL THEN
          vr_cdassessnovo := 0;
        ELSE
          BEGIN
            --procura no depara
            SELECT to_number(nvl(t.dstexprm,0))
              INTO vr_cdassessnovo
              FROM crapprm t
             WHERE NMSISTEM = 'CRED'
               AND CDACESSO LIKE 'CYBER_CD_SIGLA%'
               AND t.dsvlrprm = vr_dsassessnovo;
          EXCEPTION
            WHEN no_data_found THEN
              pc_escreve_linhaerro(LIMPA_CAMPO2(vr_setlinha) ||
                                   '; não localizada acessoria; ' ||
                                   vr_dsassessnovo||';', TRUE);
              CONTINUE;
            WHEN OTHERS THEN
              pc_escreve_linhaerro(LIMPA_CAMPO2(vr_setlinha) ||
                                   '; erro localizada acessoria; ' ||
                                   SQLERRM||';', TRUE);
              CONTINUE;
          END;
        END IF;
        /*IF  vr_cdassessatual <> vr_cdassessnovo THEN
          dbms_output.put_line(vr_cdcooper||';'||vr_nRdconta||';'||vr_nrctremp||';'||vr_cdorigem||';'||vr_dsassessnovo||';');
        END IF;*/
        IF vr_flgjudicatual <> vr_flgjudicnovo OR
           vr_flextjudatual <> vr_flextjudnovo OR
           vr_flgehvipatual <> vr_flgehvipnovo OR
           vr_cdassessatual <> vr_cdassessnovo THEN
          /*
          --> Verificar se as informações serão alteradas,
            --> Se Sim
            --> update nas tabelas crapcyc e crapcyb
            --> sempre que alterar campo flgehvip gravar campos flvipant e cdmotant 
            --> toda alteração deve atualizar cdoperad = 1 dtaltera = dta atual
            
            */
        
          UPDATE crapcyb c
             SET c.flgjudic = CASE vr_flgjudicnovo
                                WHEN 'S' THEN
                                 1
                                ELSE
                                 0
                              END
                ,c.flextjud = CASE vr_flextjudnovo
                                WHEN 'S' THEN
                                 1
                                ELSE
                                 0
                              END
                ,c.flgehvip = CASE vr_flgehvipnovo
                                WHEN 'S' THEN
                                 1
                                ELSE
                                 0
                              END
           WHERE c.nrdconta = vr_nRdconta
             AND c.cdcooper = vr_cdcooper
             AND c.nrctremp = vr_nrctremp
             AND c.cdorigem = vr_cdorigem;
        
          IF vr_flgehvipatual <> vr_flgehvipnovo THEN
            UPDATE crapcyc c
               SET c.flvipant = c.flgehvip
                  ,c.cdmotant = c.cdmotcin
             WHERE c.nrdconta = vr_nRdconta
               AND c.cdcooper = vr_cdcooper
               AND c.nrctremp = vr_nrctremp
               AND c.cdorigem = vr_cdorigem;
          END IF;
        
          --> Se novo valor do flgehvip for 1, deve atribuir para o cdmotcin valor fixo 1 
          --> Se novo valor do flgehvip for 0, deve zerar campo
        
          UPDATE crapcyc c
             SET c.flgjudic = CASE vr_flgjudicnovo
                                WHEN 'S' THEN
                                 1
                                ELSE
                                 0
                              END
                ,c.flextjud = CASE vr_flextjudnovo
                                WHEN 'S' THEN
                                 1
                                ELSE
                                 0
                              END
                ,c.flgehvip = CASE vr_flgehvipnovo
                                WHEN 'S' THEN
                                 1
                                ELSE
                                 0
                              END
                ,c.cdmotcin = CASE vr_flgehvipnovo
                                WHEN 'S' THEN
                                 1
                                ELSE
                                 0
                              END
                ,c.cdassess = vr_cdassessnovo
           WHERE c.nrdconta = vr_nRdconta
             AND c.cdcooper = vr_cdcooper
             AND c.nrctremp = vr_nrctremp
             AND c.cdorigem = vr_cdorigem
          RETURNING ROWID INTO vr_rowid;
        
          --> Gerar log das alterações:
          vr_dsmsglog := 'Contrato: ' ||
                         TRIM(gene0002.fn_mask_contrato(vr_nrctremp)) ||
                         '. Jud.: ' || CASE vr_flgjudicnovo
                           WHEN 'S' THEN
                            'Sim'
                           ELSE
                            'Nao'
                         END || '. Extra Jud.: ' || CASE VR_flextjudNOVO
                           WHEN 'S' THEN
                            'Sim'
                           ELSE
                            'Nao'
                         END || '. CIN: ' || CASE VR_flgehvipNOVO
                           WHEN 'S' THEN
                            'Sim'
                           ELSE
                            'Nao'
                         END;
        
          gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                               pr_cdoperad => 1, --> 1
                               pr_dscritic => vr_dsmsglog,
                               pr_dsorigem => 7, --> 7
                               pr_dstransa => 'Alterar registros da tabela crapcyc.',
                               pr_dttransa => trunc(SYSDATE),
                               pr_flgtrans => 1,
                               pr_hrtransa => to_number(to_char(SYSDATE,
                                                                'SSSSS')),
                               pr_idseqttl => 1,
                               pr_nmdatela => 'CADCYC', --> CADCYC
                               pr_nrdconta => vr_nrdconta,
                               pr_nrdrowid => vr_rowid);
        
          --> armazenar linha do arquivo em clob
        
          pc_escreve_linha(pr_dsdlinha => vr_setlinha, pr_fechaarq => TRUE);
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          -- Fechar o arquivo
          GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
          --Fim do arquivo
          EXIT;
      END;
    END IF;
  END LOOP;
  DBMS_OUTPUT.put_line('LINHAS PROCESSADAS '||I);
  

  pc_escreve_linha(pr_dsdlinha => ' ', pr_fechaarq => TRUE);

  gene0002.pc_clob_para_arquivo(pr_clob     => vr_desclob,
                                pr_caminho  => pr_nmdireto,
                                pr_arquivo  => 'alterados_' || pr_nmarquiv,
                                pr_des_erro => vr_des_erro);

  pc_escreve_linhaerro(' ', TRUE);
  gene0002.pc_clob_para_arquivo(pr_clob     => vr_descloberro,
                                pr_caminho  => pr_nmdireto,
                                pr_arquivo  => 'erros_' || pr_nmarquiv,
                                pr_des_erro => vr_des_erro);
  IF dbms_lob.isopen(vr_desclob) <> 1 THEN
    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_desclob);
  END IF;
  IF dbms_lob.isopen(vr_descloberro) <> 1 THEN
    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_descloberro);
  END IF;
  COMMIT;
EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
    raise_application_error(-20501, vr_des_erro);
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20501, SQLERRM);
  
END;
0
12
vr_setlinha
vr_flgjudicnovo
vr_flgehvipatual
vr_flextjudnovo
vr_nrctremp
vr_cdcooper
vr_nRdconta
vr_cdorigem
vr_rowid
I
vr_cdassessatual
vr_dsassessnovo
