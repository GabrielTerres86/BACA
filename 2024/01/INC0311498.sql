DECLARE
  vr_dscritic  cecred.crapcri.dscritic%TYPE;
  vr_diretorio VARCHAR2(200);
  vr_listarq   VARCHAR2(200);
  vr_dslinha   VARCHAR2(2000);
  vr_nmdominio cecred.tbepr_dominio_campo.nmdominio%TYPE := 'PRONAMPE_REJEICAOREG';
  vr_cddominio cecred.tbepr_dominio_campo.cddominio%TYPE;
  vr_dscodigo  cecred.tbepr_dominio_campo.dscodigo%TYPE;    
  vr_linha     cecred.gene0002.typ_split;
  vr_registro  cecred.gene0002.typ_split;
  vr_arquivo   utl_file.file_type;
  vr_exec_erro EXCEPTION;
BEGIN
  vr_diretorio := sistema.obterParametroSistema(pr_nmsistem => 'CRED'
                                               ,pr_cdacesso => 'ROOT_MICROS') || 'cpd/bacas/INC0311498';

  sistema.abrirArquivo(pr_nmdireto => vr_diretorio,
                       pr_nmarquiv => 'codigo.csv',
                       pr_tipabert => 'R',
                       pr_utlfileh => vr_arquivo,
                       pr_dscritic => vr_dscritic);
  IF vr_dscritic IS NOT NULL THEN
    vr_dscritic := 'Arquivo codigo.csv não encontrado.';
    RAISE vr_exec_erro;
  END IF;

  LOOP
    IF utl_file.IS_OPEN(vr_arquivo) THEN
      BEGIN
        sistema.leituraLinhaArquivo(pr_utlfileh => vr_arquivo
                                   ,pr_des_text => vr_dslinha);
      
        vr_linha := cecred.gene0002.fn_quebra_string(pr_string => vr_dslinha
                                                    ,pr_delimit => '|');
      
        IF vr_linha.count > 0 THEN
          vr_registro := cecred.gene0002.fn_quebra_string(pr_string  => vr_linha(1),
                                                          pr_delimit => ';');
        
          IF vr_registro.count > 0 THEN
            vr_cddominio := vr_registro(1);
            vr_dscodigo  := vr_registro(2);
          
            BEGIN
              INSERT INTO cecred.tbepr_dominio_campo
                (nmdominio
                ,cddominio
                ,dscodigo)
              VALUES
                (vr_nmdominio
                ,vr_cddominio
                ,vr_dscodigo);
            EXCEPTION
              WHEN dup_val_on_index THEN
                UPDATE cecred.tbepr_dominio_campo
                   SET dscodigo = vr_dscodigo
                 WHERE nmdominio = vr_nmdominio
                   AND cddominio = vr_cddominio;
            END;
          END IF;
        END IF;
      EXCEPTION
        WHEN no_data_found THEN
          sistema.fecharArquivo(pr_utlfileh => vr_arquivo);
          EXIT;
      END;
    END IF;
  END LOOP;

  COMMIT;
EXCEPTION
  WHEN vr_exec_erro THEN
    ROLLBACK;
    raise_application_error(-20500, vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
