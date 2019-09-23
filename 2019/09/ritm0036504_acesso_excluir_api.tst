PL/SQL Developer Test script 3.0
89
DECLARE 
  
  CURSOR cr_libera IS
    SELECT DISTINCT a.nmdatela,
                a.cdoperad,
                c.cdcooper,
                a.nrmodulo,
                a.idevento,
                a.idambace,
                a.nmrotina
  FROM crapcop c, crapace a, crapope o
 WHERE c.cdcooper = a.cdcooper
   AND c.flgativo = 1
   AND o.cdcooper = a.cdcooper
   AND o.cdoperad = a.cdoperad
   AND o.cdsitope = 1
   AND a.idambace = 2
   AND a.nmdatela = 'ATENDA'
   AND a.cddopcao = '@'
   AND TRIM(a.nmrotina) = 'PLATAFORMA_API'
   AND NOT EXISTS (SELECT 1
          FROM crapace e
         WHERE e.cdcooper = c.cdcooper
           AND e.cddopcao = 'E'
           AND e.cdoperad = a.cdoperad
           AND e.nmdatela = 'ATENDA'
           AND e.nmrotina = 'PLATAFORMA_API');

  
  vr_cdopcao  VARCHAR2(1);
  vr_cont     INTEGER;
  vr_dscritic VARCHAR2(2000);
  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/RITM0036504';
  vr_nmarqimp        VARCHAR2(100)  := 'RITM0036504-rollback.sql';  
  vr_ind_arquiv      utl_file.file_type;
  vr_acerowid ROWID;

BEGIN

  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp        --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv      --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
    dbms_output.put_line('Erro ao criar arquivo');    
  END IF;

  vr_cont:= 0;
  FOR reg IN cr_libera LOOP 

    vr_cdopcao := 'E';    
        
    BEGIN
      -- Replicar todos os acessos da tela ATENDA.... para o item Portabilidade
      INSERT INTO CRAPACE (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
                   VALUES (reg.NMDATELA
                          ,vr_cdopcao      -- CDDOPCAO
                          ,reg.CDOPERAD
                          ,'PLATAFORMA_API' -- NMROTINA
                          ,reg.CDCOOPER
                          ,reg.NRMODULO
                          ,reg.IDEVENTO
                          ,reg.IDAMBACE) returning rowid into vr_acerowid; 
    EXCEPTION
      WHEN dup_val_on_index THEN
        NULL;
      WHEN OTHERS THEN
        raise_application_error(-20000,'Erro ao inserir permissões: '||SQLERRM); 
    END;
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'delete from crapace where rowid='''||vr_acerowid||''';'||chr(13));
    
    vr_cont:= vr_cont + 1;           
        
  END LOOP;

  -- escrever commit apos todas as linhas
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'commit;');  
  -- exibir quantos registros foram inclusos
  :vr_dscritic := 'Registros incluidos: '||vr_cont;
  -- Fechar arquivo aberto
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;    
  COMMIT;
  
END;
1
vr_dscritic
1
Registros incluidos: 7062
5
0
