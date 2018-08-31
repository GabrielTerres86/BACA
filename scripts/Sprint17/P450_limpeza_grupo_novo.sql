DECLARE

  PROCEDURE pc_transf_integrantes_grupo(pr_cdcooper IN INTEGER,
                                        pr_idgrupo INTEGER DEFAULT 0) IS

    vr_idx      PLS_INTEGER;
    
    TYPE typ_rec_novoc 
         IS RECORD (cdcooper INTEGER,
                    nrdconta NUMBER,
                    idgrupo  NUMBER);
    TYPE typ_tab_novo_int IS TABLE OF typ_rec_novoc
         INDEX BY PLS_INTEGER;
         
         
    TYPE typ_tab_nivel IS TABLE OF typ_tab_novo_int   
    INDEX BY PLS_INTEGER;
                          
    vr_tab_novos_int typ_tab_nivel;
    
    
    --> Listar grupos ativos
    CURSOR cr_grupo IS
      SELECT g.*,
             (SELECT nvl(MAX('A'),'M')
                FROM tbcc_grupo_economico_integ i
               WHERE g.cdcooper = i.cdcooper
                 AND g.idgrupo  = i.idgrupo
                 AND i.tpcarga IN (1,2)) tpgrupo
        FROM tbcc_grupo_economico g
       WHERE g.cdcooper = pr_cdcooper
         AND g.idgrupo = decode(pr_idgrupo,0,g.idgrupo,pr_idgrupo) 
       AND EXISTS ( SELECT 1
                      FROM tbcc_grupo_economico_integ i
                     WHERE g.cdcooper = i.cdcooper
                       AND g.idgrupo  = i.idgrupo
                       AND i.dtexclusao IS NULL)
       ORDER BY g.idgrupo ;

    
    --> Verificar se conta é uma conta formadora em outro grupo
    CURSOR cr_grupo_1 (pr_cdcooper tbcc_grupo_economico.cdcooper%TYPE,
                       pr_idgrupo  tbcc_grupo_economico.idgrupo%TYPE,
                       pr_nrdconta tbcc_grupo_economico.nrdconta%TYPE
                       )IS
      SELECT g.idgrupo
        FROM tbcc_grupo_economico g
       WHERE g.cdcooper = pr_cdcooper
         AND g.idgrupo <> pr_idgrupo
         AND g.nrdconta = pr_nrdconta
       -- que possua algum integrante ativo
        AND EXISTS ( SELECT 1
                    FROM tbcc_grupo_economico_integ i
                   WHERE g.cdcooper = i.cdcooper
                     AND g.idgrupo  = i.idgrupo
                     AND i.dtexclusao IS NULL);
    
    --> Listar integrantes do grupo
    CURSOR cr_grupo_int (pr_cdcooper tbcc_grupo_economico.cdcooper%TYPE,
                         pr_idgrupo  tbcc_grupo_economico.idgrupo%TYPE)IS
      SELECT *
        FROM tbcc_grupo_economico_integ g
       WHERE g.cdcooper = pr_cdcooper
         AND g.idgrupo  = pr_idgrupo
         AND g.dtexclusao IS NULL
       ORDER BY g.idintegrante;

    --> Verificar se conta é um integrante em outro grupo
    CURSOR cr_grupo_int_1 (pr_cdcooper tbcc_grupo_economico.cdcooper%TYPE,
                           pr_idgrupo  tbcc_grupo_economico.idgrupo%TYPE,
                           pr_nrdconta tbcc_grupo_economico.nrdconta%TYPE
                           )IS
      SELECT g.idgrupo,
             g.idintegrante,
             g.rowid
        FROM tbcc_grupo_economico_integ g
       WHERE g.cdcooper = pr_cdcooper
         AND g.idgrupo <> pr_idgrupo
         AND g.nrdconta = pr_nrdconta
         AND g.dtexclusao IS NULL
         ORDER BY g.idgrupo;

    
    --> INCORPORAR GRUPO
    PROCEDURE pc_incorpora_grupo(pr_cdcooper     tbcc_grupo_economico.cdcooper%TYPE,
                                 pr_idgrupo_ori  tbcc_grupo_economico.idgrupo%TYPE,
                                 pr_idgrupo_dst  tbcc_grupo_economico.idgrupo%TYPE,
                                 pr_nivel        IN INTEGER,
                                 pr_tpgrupo_ini  VARCHAR2)IS

      --> Buscar dados do grupo para incorpora-lo a outro
      CURSOR cr_grupo_old (pr_cdcooper     tbcc_grupo_economico.cdcooper%TYPE,
                           pr_idgrupo_ori  tbcc_grupo_economico.idgrupo%TYPE,
                           pr_idgrupo_dst  tbcc_grupo_economico.idgrupo%TYPE
                          )IS
        SELECT g.*,
               ass.nrcpfcgc,
               ass.nmprimtl,
               ass.inpessoa
          FROM tbcc_grupo_economico g,
               crapass ass
         WHERE g.cdcooper = ass.cdcooper
           AND g.nrdconta = ass.nrdconta
           AND g.cdcooper = pr_cdcooper
           AND g.idgrupo  = pr_idgrupo_ori
           --> incorporar todos os integrantes que ainda não estejam
           AND NOT EXISTS(  SELECT *
                              FROM tbcc_grupo_economico_integ g2
                             WHERE g2.cdcooper = g.cdcooper
                               AND g2.nrdconta = g.nrdconta
                               AND g2.idgrupo  = pr_idgrupo_dst
                               AND g2.dtexclusao IS NULL)

           --> e se não for já o principal
           AND NOT EXISTS(  SELECT *
                              FROM tbcc_grupo_economico g2
                             WHERE g2.cdcooper = g.cdcooper
                               AND g2.nrdconta = g.nrdconta
                               AND g2.idgrupo  = pr_idgrupo_dst);

      --> Buscar Dados dos Integrantes para incorpora-los 
      CURSOR cr_grupo_int_old (pr_cdcooper     tbcc_grupo_economico.cdcooper%TYPE,
                               pr_idgrupo_ori  tbcc_grupo_economico.idgrupo%TYPE,
                               pr_idgrupo_dst  tbcc_grupo_economico.idgrupo%TYPE
                             )IS
        SELECT g.*,
               g.rowid
          FROM tbcc_grupo_economico_integ g
         WHERE g.cdcooper = pr_cdcooper
           AND g.idgrupo  = pr_idgrupo_ori
           AND g.dtexclusao IS NULL;
                               
      CURSOR cr_grupo_int_old_2 (pr_cdcooper     tbcc_grupo_economico.cdcooper%TYPE,
                                 pr_idgrupo_ori  tbcc_grupo_economico.idgrupo%TYPE,
                                 pr_idgrupo_dst  tbcc_grupo_economico.idgrupo%TYPE,
                                 pr_nrdconta     crapass.nrdconta%TYPE
                                )IS
        SELECT g.*,
               g.rowid
          FROM tbcc_grupo_economico_integ g
         WHERE g.cdcooper = pr_cdcooper
           AND g.idgrupo  = pr_idgrupo_ori
           AND g.nrdconta = pr_nrdconta
           AND g.dtexclusao IS NULL
           --> incorporar todos os integrantes que ainda não estejam
           AND NOT EXISTS(  SELECT *
                              FROM tbcc_grupo_economico_integ g2
                             WHERE g2.cdcooper = g.cdcooper
                               AND g2.nrdconta = g.nrdconta
                               AND g2.idgrupo  = pr_idgrupo_dst
                               AND g2.dtexclusao IS NULL)

           --> e se não for já o principal
           AND NOT EXISTS(  SELECT *
                              FROM tbcc_grupo_economico g2
                             WHERE g2.cdcooper = g.cdcooper
                               AND g2.nrdconta = g.nrdconta
                               AND g2.idgrupo  = pr_idgrupo_dst);  
      rw_grupo_int_old_2 cr_grupo_int_old_2%ROWTYPE;    
      
      vr_flggrupo BOOLEAN;                                              

    BEGIN

      --> Incorporar formador
      FOR rw_grupo_old IN cr_grupo_old (pr_cdcooper     => pr_cdcooper,
                                        pr_idgrupo_ori  => pr_idgrupo_ori,
                                        pr_idgrupo_dst  => pr_idgrupo_dst) LOOP
        
        
        BEGIN
          INSERT INTO tbcc_grupo_economico_integ
                      ( idintegrante,
                        idgrupo,
                        nrcpfcgc,
                        cdcooper,
                        nrdconta,
                        tppessoa,
                        tpcarga,
                        tpvinculo,
                        peparticipacao,
                        dtinclusao,
                        cdoperad_inclusao,
                        dtexclusao,
                        cdoperad_exclusao,
                        nmintegrante)
              VALUES  ( NULL,                        --> idintegrante,
                        pr_idgrupo_dst,              --> idgrupo,
                        rw_grupo_old.nrcpfcgc,       --> nrcpfcgc,
                        rw_grupo_old.cdcooper,       --> cdcooper,
                        rw_grupo_old.nrdconta,       --> nrdconta,
                        rw_grupo_old.inpessoa,       --> tppessoa,
                        2,                           --> tpcarga,
                        7,                           --> tpvinculo,
                        0,                           --> peparticipacao,
                        trunc(SYSDATE),              --> dtinclusao,
                        1,                           --> cdoperad_inclusao,
                        NULL,                        --> dtexclusao,
                        NULL,                        --> cdoperad_exclusao,
                        rw_grupo_old.nmprimtl);      --> nmintegrante)

        EXCEPTION
          WHEN OTHERS THEN
            raise_application_error(-20500,'Erro ao incluir integrante:'||SQLERRM);
        END;
        
        --> Armazenar contas que foram incorporadas
        IF  vr_tab_novos_int.exists(pr_nivel) THEN        
          vr_idx := vr_tab_novos_int(pr_nivel).count + 1;
        ELSE
          vr_idx := 1;
        END IF;
        vr_tab_novos_int(pr_nivel)(vr_idx).cdcooper := rw_grupo_old.cdcooper;
        vr_tab_novos_int(pr_nivel)(vr_idx).nrdconta := rw_grupo_old.nrdconta;
        vr_tab_novos_int(pr_nivel)(vr_idx).idgrupo  := rw_grupo_old.idgrupo;

      END LOOP;

      --> Incorporar integrantes
      FOR rw_grupo_old IN cr_grupo_int_old (pr_cdcooper     => pr_cdcooper,
                                            pr_idgrupo_ori  => pr_idgrupo_ori,
                                            pr_idgrupo_dst  => pr_idgrupo_dst) LOOP
        
        OPEN cr_grupo_int_old_2 (pr_cdcooper     => pr_cdcooper,
                                 pr_idgrupo_ori  => pr_idgrupo_ori,
                                 pr_idgrupo_dst  => pr_idgrupo_dst,
                                 pr_nrdconta     => rw_grupo_old.nrdconta);
        FETCH  cr_grupo_int_old_2 INTO rw_grupo_int_old_2;
        vr_flggrupo := cr_grupo_int_old_2%NOTFOUND;
        CLOSE cr_grupo_int_old_2;
        
        IF vr_flggrupo = FALSE THEN
        
          BEGIN
            INSERT INTO tbcc_grupo_economico_integ
                        ( idintegrante,
                          idgrupo,
                          nrcpfcgc,
                          cdcooper,
                          nrdconta,
                          tppessoa,
                          tpcarga,
                          tpvinculo,
                          peparticipacao,
                          dtinclusao,
                          cdoperad_inclusao,
                          dtexclusao,
                          cdoperad_exclusao,
                          nmintegrante)
                VALUES  ( rw_grupo_old.idintegrante,        --> idintegrante,
                          pr_idgrupo_dst,                   --> idgrupo,
                          rw_grupo_old.nrcpfcgc,            --> nrcpfcgc,
                          rw_grupo_old.cdcooper,            --> cdcooper,
                          rw_grupo_old.nrdconta,            --> nrdconta,
                          rw_grupo_old.tppessoa,            --> tppessoa,
                          2, --manutençao                   --> tpcarga,
                          rw_grupo_old.tpvinculo,           --> tpvinculo,
                          rw_grupo_old.peparticipacao,      --> peparticipacao,
                          rw_grupo_old.dtinclusao,          --> dtinclusao,
                          rw_grupo_old.cdoperad_inclusao,   --> cdoperad_inclusao,
                          rw_grupo_old.dtexclusao,          --> dtexclusao,
                          rw_grupo_old.cdoperad_exclusao,   --> cdoperad_exclusao,
                          rw_grupo_old.nmintegrante);       --> nmintegrante)

          EXCEPTION
            WHEN OTHERS THEN
              raise_application_error(-20500,'Erro ao incluir integrante:'||SQLERRM);
          END;
        END IF;
        BEGIN
          UPDATE tbcc_grupo_economico_integ grp
             SET grp.dtexclusao = trunc(SYSDATE),
                 grp.cdoperad_exclusao = 1
           WHERE grp.rowid = rw_grupo_old.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            raise_application_error(-20500,'Erro ao marcar como excluido o integrante:'||SQLERRM);
        END;
        
        --> Armazenar contas que foram incorporadas
        IF  vr_tab_novos_int.exists(pr_nivel) THEN
          vr_idx := vr_tab_novos_int(pr_nivel).count + 1;
        ELSE
          vr_idx := 1;        
        END IF;
        
        vr_tab_novos_int(pr_nivel)(vr_idx).cdcooper := rw_grupo_old.cdcooper;
        vr_tab_novos_int(pr_nivel)(vr_idx).nrdconta := rw_grupo_old.nrdconta;
        vr_tab_novos_int(pr_nivel)(vr_idx).idgrupo  := rw_grupo_old.idgrupo;
        
      END LOOP;


    END pc_incorpora_grupo;
    
    PROCEDURE pc_tratar_conta ( pr_cdcooper IN crapcop.cdcooper%TYPE,  
                                pr_idgrupo_destino IN tbcc_grupo_economico.idgrupo%TYPE,
                                pr_idgrupo  IN tbcc_grupo_economico.idgrupo%TYPE,
                                pr_nrdconta IN crapass.nrdconta%TYPE,
                                pr_nivel    IN INTEGER,
                                pr_tpgrupo_ini IN VARCHAR2) IS 
    
    CURSOR cr_crapass (pr_cdcooper IN INTEGER,
                       pr_nrdconta IN NUMBER)IS
      SELECT ass.nrcpfcnpj_base,ass.nrcpfcgc,nvl(ass2.nrdconta,ass.nrdconta) nrdconta 
        FROM crapass ass,
             crapass ass2
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta
         AND ass.cdcooper = ass2.cdcooper
         AND ass.nrcpfcnpj_base = ass2.nrcpfcnpj_base
         --AND ass2.dtdemiss IS NULL
         ;
  
    BEGIN
  
    FOR rw_crapass IN cr_crapass ( pr_cdcooper => pr_cdcooper,
                                   pr_nrdconta => pr_nrdconta) LOOP
    
    
      --> Verificar se a conta é um formador em outro grupo
      FOR rw_grupo_1 IN  cr_grupo_1 (pr_cdcooper => pr_cdcooper,
                                     pr_idgrupo  => pr_idgrupo,
                                     pr_nrdconta => rw_crapass.nrdconta) LOOP
                                     
        IF rw_grupo_1.idgrupo <= pr_idgrupo_destino THEN
          continue;
        END IF;
        
        IF pr_tpgrupo_ini = 'A' THEN
          --> Transferir integrante
          pc_incorpora_grupo( pr_cdcooper     => pr_cdcooper,
                              pr_idgrupo_ori  => rw_grupo_1.idgrupo,
                              pr_idgrupo_dst  => pr_idgrupo_destino,
                              pr_nivel        => pr_nivel,
                              pr_tpgrupo_ini  => pr_tpgrupo_ini);
                                
        ELSIF pr_tpgrupo_ini = 'M' THEN
          --> Caso o grupo destino for Manual, deve excluir todos os integrantes
          BEGIN
            UPDATE tbcc_grupo_economico_integ grp
               SET grp.dtexclusao = trunc(SYSDATE),
                   grp.cdoperad_exclusao = 1
             WHERE grp.idgrupo = rw_grupo_1.idgrupo
               AND grp.dtexclusao IS NULL;
          EXCEPTION
            WHEN OTHERS THEN
              raise_application_error(-20500,'Erro ao marcar como excluido o integrante:'||SQLERRM);
          END;  
        END IF;                             
                                     
      END LOOP;                               
      
      --> Identificar se integrante esta em outro grupo
      FOR rw_grupo_int_1 IN cr_grupo_int_1 (pr_cdcooper => pr_cdcooper,
                                            pr_idgrupo  => pr_idgrupo,
                                            pr_nrdconta => rw_crapass.nrdconta) LOOP

        IF rw_grupo_int_1.idgrupo <= pr_idgrupo_destino THEN
          continue;
        END IF;
        
        IF pr_tpgrupo_ini = 'A' THEN
          --> Transferir integrante
          pc_incorpora_grupo( pr_cdcooper     => pr_cdcooper,
                              pr_idgrupo_ori  => rw_grupo_int_1.idgrupo,
                              pr_idgrupo_dst  => pr_idgrupo_destino,
                              pr_nivel        => pr_nivel,
                              pr_tpgrupo_ini  => pr_tpgrupo_ini);
                                
        ELSIF pr_tpgrupo_ini = 'M' THEN

          BEGIN
            UPDATE tbcc_grupo_economico_integ grp
               SET grp.dtexclusao = trunc(SYSDATE),
                   grp.cdoperad_exclusao = 1
             WHERE grp.rowid = rw_grupo_int_1.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              raise_application_error(-20500,'Erro ao marcar como excluido o integrante:'||SQLERRM);
          END;


        END IF;

      END LOOP;
    END LOOP; --> Fim crapass
      
      --Identificar novos integrantes e buscar se os mesmos se encontram em outros grupos
      IF vr_tab_novos_int.count() > 0 AND vr_tab_novos_int.exists(pr_nivel) THEN
          
        IF vr_tab_novos_int(pr_nivel).count() > 0 THEN
          FOR idx IN vr_tab_novos_int(pr_nivel).first..vr_tab_novos_int(pr_nivel).last LOOP
            
            pc_tratar_conta ( pr_cdcooper => vr_tab_novos_int(pr_nivel)(idx).cdcooper,
                              pr_idgrupo_destino => pr_idgrupo_destino,
                              pr_idgrupo  => vr_tab_novos_int(pr_nivel)(idx).idgrupo,
                              pr_nrdconta => vr_tab_novos_int(pr_nivel)(idx).nrdconta,
                              pr_nivel    => pr_nivel + 1 ,
                              pr_tpgrupo_ini => pr_tpgrupo_ini);
          END LOOP;                  
            
          vr_tab_novos_int(pr_nivel).delete;
        END IF;
      END IF; 
    
    
    END pc_tratar_conta;
    

  BEGIN 

    --> Buscar todos os grupos
    FOR rw_grupo IN cr_grupo LOOP

      /* nao existe casos
      FOR rw_grupo_1 IN cr_grupo_1( pr_cdcooper => rw_grupo.cdcooper,
                                    pr_idgrupo  => rw_grupo.idgrupo,
                                    pr_nrdconta => rw_grupo.nrdconta) LOOP

        --> grupos errados, mover grupo para grupo x.
        NULL;

      END LOOP; */
      
      --> Marcar como excluido caso exista um integrante com o mesma conta do formador
      BEGIN
        UPDATE tbcc_grupo_economico_integ grp
           SET grp.dtexclusao = trunc(SYSDATE),
               grp.cdoperad_exclusao = 1
         WHERE grp.cdcooper = rw_grupo.cdcooper
           AND grp.idgrupo  = rw_grupo.idgrupo
           AND grp.nrdconta = rw_grupo.nrdconta
           AND grp.dtexclusao IS NULL;
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20500,'Erro ao marcar como excluido o integrante:'||SQLERRM);
      END;

      vr_tab_novos_int.delete;
      
      pc_tratar_conta ( pr_cdcooper => rw_grupo.cdcooper,
                        pr_idgrupo_destino => rw_grupo.idgrupo,
                        pr_idgrupo  => rw_grupo.idgrupo,
                        pr_nrdconta => rw_grupo.nrdconta,
                        pr_nivel    => 1,
                        pr_tpgrupo_ini => rw_grupo.tpgrupo);
      
      vr_tab_novos_int.delete;
      
      
      --> buscar integrantes do grupo
      FOR rw_grupo_int IN cr_grupo_int ( pr_cdcooper => rw_grupo.cdcooper,
                                         pr_idgrupo  => rw_grupo.idgrupo) LOOP
        
        
        --> Marcar como excluido integrantes duplicados no mesmo grupo
        BEGIN
          UPDATE tbcc_grupo_economico_integ grp
             SET grp.dtexclusao = trunc(SYSDATE),
                 grp.cdoperad_exclusao = 1
           WHERE grp.cdcooper = rw_grupo_int.cdcooper
             AND grp.idgrupo  = rw_grupo_int.idgrupo
             AND grp.nrdconta = rw_grupo_int.nrdconta
             AND grp.idintegrante <> rw_grupo_int.idintegrante
             AND grp.dtexclusao IS NULL;
        EXCEPTION
          WHEN OTHERS THEN
            raise_application_error(-20500,'Erro ao marcar como excluido o integrante:'||SQLERRM);
        END;
        
        vr_tab_novos_int.delete;
        
        pc_tratar_conta ( pr_cdcooper => rw_grupo.cdcooper,
                          pr_idgrupo_destino => rw_grupo.idgrupo,
                          pr_idgrupo  => rw_grupo.idgrupo,
                          pr_nrdconta => rw_grupo_int.nrdconta,
                          pr_nivel    => 1,
                          pr_tpgrupo_ini => rw_grupo.tpgrupo);
                                
      
      END LOOP;
    END LOOP;

  END pc_transf_integrantes_grupo;


BEGIN

  --> Buscar cooperativas ativas
  FOR rw_crapcop IN (SELECT * 
                       FROM crapcop cop
                      WHERE cop.flgativo = 1
                        AND cop.cdcooper <> 3   
                      ORDER BY cop.cdcooper ) LOOP
                        
                        
    -- Call the procedure
    pc_transf_integrantes_grupo(pr_cdcooper => rw_crapcop.cdcooper);   
    
    COMMIT;
                       
  END LOOP;                        


END;
