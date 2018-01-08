CREATE OR REPLACE PACKAGE CECRED.CADA0013 is
  /*---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CADA0013
  --  Sistema  : Rotinas para envio de cadastros para o CRM
  --  Sigla    : CADA
  --  Autor    : Odirlei Busana - AMcom
  --  Data     : Julho/2017.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para envio de cadastros para o CRM
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------*/

  ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

  --------->>>> PROCUDURES/FUNCTIONS <<<<----------

  /*****************************************************************************/
  /**     Procedure para enviar dados de natureza_juridica para o CRM         **/
  /*****************************************************************************/
  PROCEDURE pc_processa_natureza_juridica ( pr_rw_dados    IN gncdntj%ROWTYPE      --> Rowtipe contendo os dados dos Campos da tabela
                                           ,pr_tpoperacao  IN INTEGER              --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                           ,pr_dscritic   OUT VARCHAR2) ;          --> Retornar Critica

  /*****************************************************************************/
  /**     Procedure para enviar dados de cnae(tbgen_cnae) para o CRM          **/
  /*****************************************************************************/
  PROCEDURE pc_processa_cnae   (pr_rw_dados    IN tbgen_cnae%ROWTYPE   --> Rowtipe contendo os dados dos Campos da tabela
                               ,pr_tpoperacao  IN INTEGER              --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                               ,pr_dscritic   OUT VARCHAR2);           --> Retornar Critica

  /*****************************************************************************/
  /**     Procedure para enviar dados de nivel_cargo(gncdncg) para o CRM      **/
  /*****************************************************************************/
  PROCEDURE pc_processa_nivel_cargo ( pr_rw_dados    IN gncdncg%ROWTYPE   --> Rowtipe contendo os dados dos Campos da tabela
                                     ,pr_tpoperacao  IN INTEGER           --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                     ,pr_dscritic   OUT VARCHAR2);        --> Retornar Critica

  /*****************************************************************************/
  /**     Procedure para enviar dados de ocupacao(gncdocp) para o CRM         **/
  /*****************************************************************************/
  PROCEDURE pc_processa_ocupacao ( pr_rw_dados    IN gncdocp%ROWTYPE     --> Rowtipe contendo os dados dos Campos da tabela
                                  ,pr_tpoperacao  IN INTEGER             --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                  ,pr_dscritic   OUT VARCHAR2);          --> Retornar Critica

  /*****************************************************************************/
  /**     Procedure para enviar dados de estado_civil(gnetcvl) para o CRM     **/
  /*****************************************************************************/
  PROCEDURE pc_processa_estado_civil ( pr_rw_dados    IN gnetcvl%ROWTYPE    --> Rowtipe contendo os dados dos Campos da tabela
                                      ,pr_tpoperacao  IN INTEGER           --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                      ,pr_dscritic   OUT VARCHAR2);          --> Retornar Critica

  /*****************************************************************************/
  /**     Procedure para enviar dados de nacionalidade(crapnac) para o CRM    **/
  /*****************************************************************************/
  PROCEDURE pc_processa_orgao_expedidor ( pr_rw_dados    IN tbgen_orgao_expedidor%ROWTYPE   --> Rowtype contendo os dados dos Campos da tabela
                                         ,pr_tpoperacao  IN INTEGER           --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                         ,pr_dscritic   OUT VARCHAR2);        --> Retornar Critica


  /*****************************************************************************/
  /**     Procedure para enviar dados de nacionalidade(crapnac) para o CRM    **/
  /*****************************************************************************/
  PROCEDURE pc_processa_nacionalidade ( pr_rw_dados    IN crapnac%ROWTYPE   --> Rowtype contendo os dados dos Campos da tabela
                                       ,pr_tpoperacao  IN INTEGER           --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                       ,pr_dscritic   OUT VARCHAR2);        --> Retornar Critica

  /*****************************************************************************/
  /**     Procedure para enviar dados de uf(tbcadast_uf) para o CRM         **/
  /*****************************************************************************/
  PROCEDURE pc_processa_uf( pr_rw_dados    IN tbcadast_uf%ROWTYPE   --> Rowtype contendo os dados dos Campos da tabela
                           ,pr_tpoperacao  IN INTEGER               --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                           ,pr_dscritic   OUT VARCHAR2);            --> Retornar Critica

  /*****************************************************************************/
  /**  Procedure para enviar dados de grau_escolaridade(gngresc) para o CRM   **/
  /*****************************************************************************/
  PROCEDURE pc_processa_grau_escolaridade ( pr_rw_dados    IN gngresc%ROWTYPE   --> Rowtype contendo os dados dos Campos da tabela
                                           ,pr_tpoperacao  IN INTEGER           --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                           ,pr_dscritic   OUT VARCHAR2 );       --> Retornar Critica

  /*****************************************************************************/
  /**  Procedure para enviar dados de curso_superior(gncdfrm) para o CRM   **/
  /*****************************************************************************/
  PROCEDURE pc_processa_curso_superior( pr_rw_dados    IN gncdfrm%ROWTYPE   --> Rowtype contendo os dados dos Campos da tabela
                                       ,pr_tpoperacao  IN INTEGER           --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                       ,pr_dscritic   OUT VARCHAR2);        --> Retornar Critica

  /*****************************************************************************/
  /**  Procedure para enviar dados de natureza_ocupacao(gncdnto) para o CRM   **/
  /*****************************************************************************/
  PROCEDURE pc_processa_natureza_ocupacao ( pr_rw_dados    IN gncdnto%ROWTYPE   --> Rowtype contendo os dados dos Campos da tabela
                                           ,pr_tpoperacao  IN INTEGER           --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                           ,pr_dscritic   OUT VARCHAR2);        --> Retornar Critica

  /*****************************************************************************/
  /**        Procedure para enviar dados de pais(xxx) para o CRM              **/
  /*****************************************************************************/
  PROCEDURE pc_processa_pais( pr_rw_dados    IN gncdnto%ROWTYPE   --> Rowtype contendo os dados dos Campos da tabela
                             ,pr_tpoperacao  IN INTEGER           --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                             ,pr_dscritic   OUT VARCHAR2);        --> Retornar Critica

  /*****************************************************************************/
  /**  Procedure para enviar dados de mtv_saque_parcial(xxxx) para o CRM      **/
  /*****************************************************************************/
  PROCEDURE pc_processa_mtv_saque_parcial ( pr_rw_dados      IN tbcotas_motivo_saqueparcial%ROWTYPE   --> Rowtype contendo os dados dos Campos da tabela
                                           ,pr_rw_dados_ant  IN tbcotas_motivo_saqueparcial%ROWTYPE   --> Rowtype contendo os dados anteriores dos Campos da tabela
                                           ,pr_tpoperacao    IN INTEGER           --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                           ,pr_dscritic     OUT VARCHAR2);        --> Retornar Critica

  /*****************************************************************************/
  /**   Procedure para enviar dados de mtv_desligamento(tbcotas_motivo_desligamento) para o CRM     **/
  /*****************************************************************************/
  PROCEDURE pc_processa_mtv_desligamento ( pr_rw_dados      IN tbcotas_motivo_desligamento%ROWTYPE   --> Rowtype contendo os dados dos Campos da tabela
                                          ,pr_rw_dados_ant  IN tbcotas_motivo_desligamento%ROWTYPE   --> Rowtype contendo os dados anteriores dos Campos da tabela
                                          ,pr_tpoperacao    IN INTEGER           --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                          ,pr_dscritic     OUT VARCHAR2);        --> Retornar Critica


  /*****************************************************************************/
  /**  Procedure para enviar dados de operadora_telefone(craptab) para o CRM  **/
  /*****************************************************************************/
  PROCEDURE pc_processa_operadora_telefone( pr_rw_dados    IN craptab%ROWTYPE   --> Rowtype contendo os dados dos Campos da tabela
                                           ,pr_tpoperacao  IN INTEGER           --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                           ,pr_dscritic   OUT VARCHAR2);        --> Retornar Critica

  /*****************************************************************************/
  /**   Procedure para enviar dados de prazo_desligamento(craptab) para o CRM    **/
  /*****************************************************************************/
  PROCEDURE pc_processa_prazo_desligamento ( pr_rw_dados    IN craptab%ROWTYPE   --> Rowtype contendo os dados dos Campos da tabela
                                            ,pr_tpoperacao  IN INTEGER           --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                            ,pr_dscritic   OUT VARCHAR2);        --> Retornar Critica

  /*****************************************************************************/
  /**   Procedure para enviar dados de setor_economico(craptab) para o CRM    **/
  /*****************************************************************************/
  PROCEDURE pc_processa_setor_economico ( pr_rw_dados    IN craptab%ROWTYPE   --> Rowtype contendo os dados dos Campos da tabela
                                         ,pr_tpoperacao  IN INTEGER           --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                         ,pr_dscritic   OUT VARCHAR2);        --> Retornar Critica

  /*****************************************************************************/
  /**     Procedure para enviar dados de cidade(CRAPMUN) para o CRM           **/
  /*****************************************************************************/
  PROCEDURE pc_processa_cidade ( pr_rw_dados    IN crapmun%ROWTYPE   --> Rowtipe contendo os dados dos Campos da tabela
                                ,pr_tpoperacao  IN INTEGER           --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                ,pr_dscritic   OUT VARCHAR2);        --> Retornar Critica

    /*****************************************************************************/
  /**   Procedure para enviar dados de ramo_atividade(GNRATIV) para o CRM    **/
  /*****************************************************************************/
  PROCEDURE pc_processa_ramo_atividade( pr_rw_dados     IN GNRATIV%ROWTYPE   --> Rowtype contendo os dados dos Campos da tabela
                                       ,pr_rw_dados_ant IN GNRATIV%ROWTYPE   --> Rowtype contendo os dados anteriores
                                       ,pr_tpoperacao   IN INTEGER           --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                       ,pr_dscritic    OUT VARCHAR2 );       --> Retornar Critica

  /*****************************************************************************/
  /**     Procedure para enviar dados de banco(crapban) para o CRM            **/
  /*****************************************************************************/
  PROCEDURE pc_processa_banco( pr_rw_dados    IN crapban%ROWTYPE   --> Rowtipe contendo os dados dos Campos da tabela
                              ,pr_tpoperacao  IN INTEGER           --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                              ,pr_dscritic   OUT VARCHAR2);        --> Retornar Critica


  /*****************************************************************************/
  /**     Procedure para enviar dados de regional(crapreg) para o CRM         **/
  /*****************************************************************************/
  PROCEDURE pc_processa_regional (  pr_rw_dados    IN crapreg%ROWTYPE   --> Rowtype contendo os dados dos Campos da tabela
                                   ,pr_tpoperacao  IN INTEGER           --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                   ,pr_dscritic   OUT VARCHAR2 );       --> Retornar Critica
                                   
  --> Rotina para montar xml e enviar via webservice informaçoes para o CRM
  PROCEDURE pc_manterConteudoCRM (pr_tbcampos    IN NPCB0003.typ_tab_campos_soap --> tabela com as tags
                                 ,pr_dsobjeto    IN VARCHAR2                     --> descrição do objeto
                                 ,pr_dsobjagr    IN VARCHAR2 DEFAULT NULL        --> descrição do objeto agrupador
                                 ,pr_cddadagr    IN VARCHAR2 DEFAULT NULL        --> Codigo do dado agrupador
                                 ,pr_tpoperacao  IN INTEGER                      --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                 ,pr_dscritic   OUT VARCHAR2);                   --> Descricao erro


END CADA0013;
/
CREATE OR REPLACE PACKAGE BODY CECRED.CADA0013 IS
  /*---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CADA0013
  --  Sistema  : Rotinas para envio de cadastros para o CRM
  --  Sigla    : CADA
  --  Autor    : Odirlei Busana - AMcom
  --  Data     : Julho/2017.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para envio de cadastros para o CRM
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------*/

  --> Declaração geral de exception
  vr_exc_erro    EXCEPTION;


  /*
    -- pc_processa_natureza_juridica è gncdntj
    -- pc_processa_cnae è tbgen_cnae
    -- pc_processa_nivel_cargo è gncdncg
    -- pc_processa_ocupacao è gncdocp
    -- pc_processa_estado_civil è gnetcvl
    -- pc_processa_naturalidade è coloca o cabeçalho, porém deixe comentado com  o seguinte: sera enviado o município através da pc_processa_cidade
    -- pc_processa_nacionalidade è crapnac
    -- pc_processa_uf è tbcadast_uf
    -- pc_processa_grau_escolaridade è gngresc
    -- pc_processa_curso_superior è gncdfrm
    -- pc_processa_natureza_ocupacao è gncdnto
    -- pc_processa_pais è crie somente o cabeçalho. falta o julio criar a tabela.
    -- pc_processa_mtv_saque_parcial è crie somente o cabeçalho. a tabela será criada no futuro.
    -- pc_processa_operadora_telefone è craptab where cdcooper = 0 and upper(cdacesso) = 'opetelefon'
    -- pc_processa_setor_economico è craptab where cdcooper = 3 and upper(cdacesso) = 'setorecono'
    -- pc_processa_cidade è crapmun

    Os parâmetros serão o ROWTYPE de cada tabela juntamente com os campos INOPERACAO (1-Inclusao, 2-Alteração, 3-Exclusão) e o DSCRITIC.

  */


  /*****************************************************************************/
  /**     Procedure para enviar dados de natureza_juridica para o CRM         **/
  /*****************************************************************************/
  PROCEDURE pc_processa_natureza_juridica ( pr_rw_dados    IN gncdntj%ROWTYPE      --> Rowtipe contendo os dados dos Campos da tabela
                                           ,pr_tpoperacao  IN INTEGER              --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                           ,pr_dscritic   OUT VARCHAR2             --> Retornar Critica
                                          ) IS

  /* ..........................................................................
    --
    --  Programa : pc_processa_natureza_juridica
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para enviar dados de natureza_juridica(gncdntj) para o CRM
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------


    ---------------> VARIAVEIS <-----------------
    vr_dscritic VARCHAR2(1000);
    vr_des_erro VARCHAR2(1000);
    vr_exc_erro EXCEPTION;

    vr_tbcampos NPCB0003.typ_tab_campos_soap;

  BEGIN

    -- Limpa a tab de campos
    vr_tbcampos.DELETE();

    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'codigo';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados.cdnatjur;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'number';
    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'descricao';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados.dsnatjur;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';

    --> Rotina para montar xml e enviar via webservice informaçoes para o CRM
    pc_manterConteudoCRM (pr_tbcampos   => vr_tbcampos        --> tabela com as tags
                         ,pr_dsobjeto   => 'NaturezaJuridica' --> descrição do objeto
                         ,pr_tpoperacao => pr_tpoperacao      --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                         ,pr_dscritic   => vr_dscritic);      --> Descricao erro

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;


  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro nao tratado pc_processa_natureza_juridica: '||SQLERRM;
  END pc_processa_natureza_juridica;

  /*****************************************************************************/
  /**     Procedure para enviar dados de cnae(tbgen_cnae) para o CRM          **/
  /*****************************************************************************/
  PROCEDURE pc_processa_cnae   (pr_rw_dados    IN tbgen_cnae%ROWTYPE   --> Rowtipe contendo os dados dos Campos da tabela
                               ,pr_tpoperacao  IN INTEGER              --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                               ,pr_dscritic   OUT VARCHAR2             --> Retornar Critica
                                ) IS

  /* ..........................................................................
    --
    --  Programa : pc_processa_cnae
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para enviar dados de cnae(tbgen_cnae) para o CRM
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------


    ---------------> VARIAVEIS <-----------------
    vr_dscritic VARCHAR2(1000);
    vr_exc_erro EXCEPTION;

    vr_tbcampos NPCB0003.typ_tab_campos_soap;

  BEGIN

    -- Limpa a tab de campos
    vr_tbcampos.DELETE();

    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'codigo';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados.cdcnae;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'number';
    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'descricao';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados.dscnae;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';

    --> Rotina para montar xml e enviar via webservice informaçoes para o CRM
    pc_manterConteudoCRM (pr_tbcampos   => vr_tbcampos     --> tabela com as tags
                         ,pr_dsobjeto   => 'CNAE'          --> descrição do objeto
                         ,pr_tpoperacao => pr_tpoperacao   --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                         ,pr_dscritic   => vr_dscritic);   --> Descricao erro

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;


  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro nao tratado pc_processa_cnae: '||SQLERRM;
  END pc_processa_cnae;

  /*****************************************************************************/
  /**     Procedure para enviar dados de nivel_cargo(gncdncg) para o CRM      **/
  /*****************************************************************************/
  PROCEDURE pc_processa_nivel_cargo ( pr_rw_dados    IN gncdncg%ROWTYPE   --> Rowtipe contendo os dados dos Campos da tabela
                                     ,pr_tpoperacao  IN INTEGER           --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                     ,pr_dscritic   OUT VARCHAR2          --> Retornar Critica
                                    ) IS

  /* ..........................................................................
    --
    --  Programa : pc_processa_nivel_cargo
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para enviar dados de nivel_cargo(gncdncg) para o CRM
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------


    ---------------> VARIAVEIS <-----------------
    vr_dscritic VARCHAR2(1000);
    vr_exc_erro EXCEPTION;

    vr_tbcampos NPCB0003.typ_tab_campos_soap;

  BEGIN

    -- Limpa a tab de campos
    vr_tbcampos.DELETE();


    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'codigo';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados.cdnvlcgo;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'number';
    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'descricao';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados.dsnvlcgo;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';

    --> Rotina para montar xml e enviar via webservice informaçoes para o CRM
    pc_manterConteudoCRM (pr_tbcampos   => vr_tbcampos     --> tabela com as tags
                         ,pr_dsobjeto   => 'NivelCargo'    --> descrição do objeto
                         ,pr_tpoperacao => pr_tpoperacao   --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                         ,pr_dscritic   => vr_dscritic);   --> Descricao erro

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro nao tratado pc_processa_nivel_cargo: '||SQLERRM;
  END pc_processa_nivel_cargo;


  /*****************************************************************************/
  /**     Procedure para enviar dados de ocupacao(gncdocp) para o CRM         **/
  /*****************************************************************************/
  PROCEDURE pc_processa_ocupacao ( pr_rw_dados    IN gncdocp%ROWTYPE    --> Rowtipe contendo os dados dos Campos da tabela
                                   ,pr_tpoperacao  IN INTEGER           --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                   ,pr_dscritic   OUT VARCHAR2          --> Retornar Critica
                                  ) IS

  /* ..........................................................................
    --
    --  Programa : pc_processa_ocupacao
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para enviar dados de ocupacao(gncdocp) para o CRM
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------


    ---------------> VARIAVEIS <-----------------
    vr_dscritic VARCHAR2(1000);
    vr_exc_erro EXCEPTION;

    vr_tbcampos NPCB0003.typ_tab_campos_soap;

  BEGIN

    -- Limpa a tab de campos
    vr_tbcampos.DELETE();


    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'codigo';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados.cdocupa;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'number';
    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'descricao';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados.dsdocupa;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';


    --> Rotina para montar xml e enviar via webservice informaçoes para o CRM
    pc_manterConteudoCRM (pr_tbcampos   => vr_tbcampos     --> tabela com as tags
                         ,pr_dsobjeto   => 'Ocupacao'      --> descrição do objeto
                         ,pr_tpoperacao => pr_tpoperacao   --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                         ,pr_dscritic   => vr_dscritic);   --> Descricao erro

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro nao tratado pc_processa_ocupacao: '||SQLERRM;
  END pc_processa_ocupacao;

  /*****************************************************************************/
  /**     Procedure para enviar dados de estado_civil(gnetcvl) para o CRM         **/
  /*****************************************************************************/
  PROCEDURE pc_processa_estado_civil ( pr_rw_dados    IN gnetcvl%ROWTYPE    --> Rowtipe contendo os dados dos Campos da tabela
                                       ,pr_tpoperacao  IN INTEGER           --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                       ,pr_dscritic   OUT VARCHAR2          --> Retornar Critica
                                      ) IS

  /* ..........................................................................
    --
    --  Programa : pc_processa_estado_civil
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para enviar dados de estado_civil(gnetcvl) para o CRM
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------


    ---------------> VARIAVEIS <-----------------
    vr_dscritic VARCHAR2(1000);
    vr_exc_erro EXCEPTION;

    vr_tbcampos NPCB0003.typ_tab_campos_soap;

  BEGIN

    -- Limpa a tab de campos
    vr_tbcampos.DELETE();


    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'codigo';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados.cdestcvl;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'number';
    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'descricao';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados.dsestcvl;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';


    --> Rotina para montar xml e enviar via webservice informaçoes para o CRM
    pc_manterConteudoCRM (pr_tbcampos   => vr_tbcampos     --> tabela com as tags
                         ,pr_dsobjeto   => 'EstadoCivil'   --> descrição do objeto
                         ,pr_tpoperacao => pr_tpoperacao   --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                         ,pr_dscritic   => vr_dscritic);   --> Descricao erro

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro nao tratado pc_processa_estado_civil: '||SQLERRM;
  END pc_processa_estado_civil;



  /*****************************************************************************/
  /**     Procedure para enviar dados de nacionalidade(crapnac) para o CRM    **/
  /*****************************************************************************/
  PROCEDURE pc_processa_orgao_expedidor ( pr_rw_dados    IN tbgen_orgao_expedidor%ROWTYPE   --> Rowtype contendo os dados dos Campos da tabela
                                         ,pr_tpoperacao  IN INTEGER           --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                         ,pr_dscritic   OUT VARCHAR2          --> Retornar Critica
                                      ) IS

  /* ..........................................................................
    --
    --  Programa : pc_processa_orgao_expedidor
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para enviar dados de orgao expedidor para o CRM
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------


    ---------------> VARIAVEIS <-----------------
    vr_dscritic VARCHAR2(1000);
    vr_exc_erro EXCEPTION;

    vr_tbcampos NPCB0003.typ_tab_campos_soap;

  BEGIN

    -- Limpa a tab de campos
    vr_tbcampos.DELETE();


    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'codigo';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados.idorgao_expedidor;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'number';
    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'descricao';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados.nmorgao_expedidor;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';
    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'sigla';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados.cdorgao_expedidor;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';


    --> Rotina para montar xml e enviar via webservice informaçoes para o CRM
    pc_manterConteudoCRM (pr_tbcampos   => vr_tbcampos     --> tabela com as tags
                         ,pr_dsobjeto   => 'OrgaoExpedidor'   --> descrição do objeto
                         ,pr_tpoperacao => pr_tpoperacao   --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                         ,pr_dscritic   => vr_dscritic);   --> Descricao erro

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;


  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro nao tratado pc_processa_orgao_expedidor: '||SQLERRM;
  END pc_processa_orgao_expedidor;

  /*****************************************************************************/
  /**     Procedure para enviar dados de nacionalidade(crapnac) para o CRM    **/
  /*****************************************************************************/
  PROCEDURE pc_processa_nacionalidade ( pr_rw_dados    IN crapnac%ROWTYPE   --> Rowtype contendo os dados dos Campos da tabela
                                       ,pr_tpoperacao  IN INTEGER           --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                       ,pr_dscritic   OUT VARCHAR2          --> Retornar Critica
                                      ) IS

  /* ..........................................................................
    --
    --  Programa : pc_processa_nacionalidade
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para enviar dados de nacionalidade(crapnac) para o CRM
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------


    ---------------> VARIAVEIS <-----------------
    vr_dscritic VARCHAR2(1000);
    vr_exc_erro EXCEPTION;

    vr_tbcampos NPCB0003.typ_tab_campos_soap;

  BEGIN

    -- Limpa a tab de campos
    vr_tbcampos.DELETE();

    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'codigo';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados.cdnacion;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'number';
    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'descricao';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados.dsnacion;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';

    --> Rotina para montar xml e enviar via webservice informaçoes para o CRM
    pc_manterConteudoCRM (pr_tbcampos   => vr_tbcampos     --> tabela com as tags
                         ,pr_dsobjeto   => 'Nacionalidade' --> descrição do objeto
                         ,pr_tpoperacao => pr_tpoperacao   --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                         ,pr_dscritic   => vr_dscritic);   --> Descricao erro

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro nao tratado pc_processa_nacionalidade: '||SQLERRM;
  END pc_processa_nacionalidade;

  /*****************************************************************************/
  /**     Procedure para enviar dados de uf(tbcadast_uf) para o CRM         **/
  /*****************************************************************************/
  PROCEDURE pc_processa_uf( pr_rw_dados    IN tbcadast_uf%ROWTYPE   --> Rowtype contendo os dados dos Campos da tabela
                           ,pr_tpoperacao  IN INTEGER               --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                           ,pr_dscritic   OUT VARCHAR2              --> Retornar Critica
                          ) IS

  /* ..........................................................................
    --
    --  Programa : pc_processa_uf
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para enviar dados de uf(tbcadast_uf) para o CRM
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------


    ---------------> VARIAVEIS <-----------------
    vr_dscritic VARCHAR2(1000);
    vr_exc_erro EXCEPTION;

    vr_tbcampos NPCB0003.typ_tab_campos_soap;

  BEGIN

    -- Limpa a tab de campos
    vr_tbcampos.DELETE();


    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'codigo';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados.cduf;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'number';
    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'descricao';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados.nmuf;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';


    --> Rotina para montar xml e enviar via webservice informaçoes para o CRM
    pc_manterConteudoCRM (pr_tbcampos   => vr_tbcampos     --> tabela com as tags
                         ,pr_dsobjeto   => 'UF'            --> descrição do objeto
                         ,pr_tpoperacao => pr_tpoperacao   --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                         ,pr_dscritic   => vr_dscritic);   --> Descricao erro

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro nao tratado pc_processa_uf: '||SQLERRM;
  END pc_processa_uf;

  /*****************************************************************************/
  /**  Procedure para enviar dados de grau_escolaridade(gngresc) para o CRM   **/
  /*****************************************************************************/
  PROCEDURE pc_processa_grau_escolaridade ( pr_rw_dados    IN gngresc%ROWTYPE   --> Rowtype contendo os dados dos Campos da tabela
                                           ,pr_tpoperacao  IN INTEGER               --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                           ,pr_dscritic   OUT VARCHAR2              --> Retornar Critica
                                          ) IS

  /* ..........................................................................
    --
    --  Programa : pc_processa_grau_escolaridade
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para enviar dados de grau_escolaridade(gngresc) para o CRM
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------


    ---------------> VARIAVEIS <-----------------
    vr_dscritic VARCHAR2(1000);
    vr_exc_erro EXCEPTION;

    vr_tbcampos NPCB0003.typ_tab_campos_soap;

  BEGIN

    -- Limpa a tab de campos
    vr_tbcampos.DELETE();

    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'codigo';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados.grescola;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'number';
    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'descricao';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados.dsescola;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';

    --> Rotina para montar xml e enviar via webservice informaçoes para o CRM
    pc_manterConteudoCRM (pr_tbcampos   => vr_tbcampos        --> tabela com as tags
                         ,pr_dsobjeto   => 'GrauEscolaridade' --> descrição do objeto
                         ,pr_tpoperacao => pr_tpoperacao      --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                         ,pr_dscritic   => vr_dscritic);      --> Descricao erro

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro nao tratado pc_processa_grau_escolaridade: '||SQLERRM;
  END pc_processa_grau_escolaridade;

  /*****************************************************************************/
  /**  Procedure para enviar dados de curso_superior(gncdfrm) para o CRM   **/
  /*****************************************************************************/
  PROCEDURE pc_processa_curso_superior( pr_rw_dados    IN gncdfrm%ROWTYPE   --> Rowtype contendo os dados dos Campos da tabela
                                       ,pr_tpoperacao  IN INTEGER           --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                       ,pr_dscritic   OUT VARCHAR2          --> Retornar Critica
                                      ) IS

  /* ..........................................................................
    --
    --  Programa : pc_processa_curso_superior
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para enviar dados de curso_superior(gncdfrm) para o CRM
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------


    ---------------> VARIAVEIS <-----------------
    vr_dscritic VARCHAR2(1000);
    vr_exc_erro EXCEPTION;

    vr_tbcampos NPCB0003.typ_tab_campos_soap;

  BEGIN

    -- Limpa a tab de campos
    vr_tbcampos.DELETE();

    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'codigo';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados.cdfrmttl;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'number';
    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'descricao';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados.dsfrmttl;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';


    --> Rotina para montar xml e enviar via webservice informaçoes para o CRM
    pc_manterConteudoCRM (pr_tbcampos   => vr_tbcampos     --> tabela com as tags
                         ,pr_dsobjeto   => 'CursoSuperior' --> descrição do objeto
                         ,pr_tpoperacao => pr_tpoperacao   --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                         ,pr_dscritic   => vr_dscritic);   --> Descricao erro

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro nao tratado pc_processa_curso_superior: '||SQLERRM;
  END pc_processa_curso_superior;

  /*****************************************************************************/
  /**  Procedure para enviar dados de natureza_ocupacao(gncdnto) para o CRM   **/
  /*****************************************************************************/
  PROCEDURE pc_processa_natureza_ocupacao ( pr_rw_dados    IN gncdnto%ROWTYPE   --> Rowtype contendo os dados dos Campos da tabela
                                           ,pr_tpoperacao  IN INTEGER           --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                           ,pr_dscritic   OUT VARCHAR2          --> Retornar Critica
                                          ) IS

  /* ..........................................................................
    --
    --  Programa : pc_processa_natureza_ocupacao
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para enviar dados de natureza_ocupacao(gncdnto) para o CRM
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------


    ---------------> VARIAVEIS <-----------------
    vr_dscritic VARCHAR2(1000);
    vr_exc_erro EXCEPTION;

    vr_tbcampos NPCB0003.typ_tab_campos_soap;

  BEGIN

    -- Limpa a tab de campos
    vr_tbcampos.DELETE();

    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'codigo';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados.cdnatocp;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'number';
    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'descricao';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados.dsnatocp;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';


    --> Rotina para montar xml e enviar via webservice informaçoes para o CRM
    pc_manterConteudoCRM (pr_tbcampos   => vr_tbcampos        --> tabela com as tags
                         ,pr_dsobjeto   => 'NaturezaOcupacao' --> descrição do objeto
                         ,pr_tpoperacao => pr_tpoperacao      --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                         ,pr_dscritic   => vr_dscritic);      --> Descricao erro

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro nao tratado pc_processa_natureza_ocupacao: '||SQLERRM;
  END pc_processa_natureza_ocupacao;

  /*****************************************************************************/
  /**          Procedure para enviar dados de pais(xxx) para o CRM            **/
  /*****************************************************************************/
  PROCEDURE pc_processa_pais( pr_rw_dados    IN gncdnto%ROWTYPE   --> Rowtype contendo os dados dos Campos da tabela
                             ,pr_tpoperacao  IN INTEGER           --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                             ,pr_dscritic   OUT VARCHAR2          --> Retornar Critica
                            ) IS

  /* ..........................................................................
    --
    --  Programa : pc_processa_pais
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para enviar dados de pais(xxx) para o CRM
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------


    ---------------> VARIAVEIS <-----------------
    vr_dscritic VARCHAR2(1000);
    vr_exc_erro EXCEPTION;

    vr_tbcampos NPCB0003.typ_tab_campos_soap;

  BEGIN
  NULL;
 /*   -- Limpa a tab de campos
    vr_tbcampos.DELETE();

    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'id';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados.cdnatocp;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'number';
    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'codigo';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados.cdnatocp;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'number';
    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'descricao';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados.dsnatocp;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';
    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'objeto';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := 'NaturezaOcupacao';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';

    --> Rotina para montar xml e enviar via webservice informaçoes para o CRM
    pc_manterConteudoCRM (pr_tbcampos   => vr_tbcampos     --> tabela com as tags
                         ,pr_tpoperacao => pr_tpoperacao   --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                         ,pr_dscritic   => vr_dscritic);   --> Descricao erro

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;*/

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro nao tratado pc_processa_pais: '||SQLERRM;
  END pc_processa_pais;

  /*****************************************************************************/
  /**   Procedure para enviar dados de mtv_saque_parcial(tbcotas_motivo_saqueparcial) para o CRM     **/
  /*****************************************************************************/
  PROCEDURE pc_processa_mtv_saque_parcial ( pr_rw_dados      IN tbcotas_motivo_saqueparcial%ROWTYPE   --> Rowtype contendo os dados dos Campos da tabela
                                           ,pr_rw_dados_ant  IN tbcotas_motivo_saqueparcial%ROWTYPE   --> Rowtype contendo os dados anteriores dos Campos da tabela
                                           ,pr_tpoperacao    IN INTEGER           --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                           ,pr_dscritic     OUT VARCHAR2          --> Retornar Critica
                                          ) IS

  /* ..........................................................................
    --
    --  Programa : pc_processa_mtv_saque_parcial
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para enviar dados de mtv_saque_parcial(tbcotas_motivo_saqueparcial) para o CRM
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------


    ---------------> VARIAVEIS <-----------------
    vr_dscritic VARCHAR2(1000);
    vr_exc_erro EXCEPTION;

    vr_tbcampos NPCB0003.typ_tab_campos_soap;
    vr_dsobjeto VARCHAR2(100);
    vr_tpoperacao INTEGER;

  BEGIN

    vr_tpoperacao := pr_tpoperacao;


    --Se for operacao "Alteracao" deve excluir antigo antes de incluir novo
    IF vr_tpoperacao = 2 AND
        --> e foi alterado os tipos
       (pr_rw_dados_ant.flgpessoa_fisica <> pr_rw_dados.flgpessoa_fisica OR
        pr_rw_dados_ant.flgpessoa_juridica <> pr_rw_dados.flgpessoa_juridica )THEN

      FOR i IN 1..2 LOOP
        --> Montar objeto concatenando com o tipo de liberação
        vr_dsobjeto := 'MotivoSaqueParcial';

        --> Caso pessoa fisica estava marcado
        IF i = 1 AND pr_rw_dados_ant.flgpessoa_fisica = 1 THEN
          vr_dsobjeto := vr_dsobjeto ||i;
        ELSIF i = 2 AND pr_rw_dados_ant.flgpessoa_juridica = 1 THEN
          vr_dsobjeto := vr_dsobjeto ||i;
        ELSE
          CONTINUE; -- Vai para o proximo registro
        END IF;

        -- Limpa a tab de campos
        vr_tbcampos.DELETE();

        --
        vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'codigo';
        vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados_ant.cdmotivo;
        vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'number';
        --
        vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'descricao';
        vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados_ant.dsmotivo;
        vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';

        --> Rotina para montar xml e enviar via webservice informaçoes para o CRM
        pc_manterConteudoCRM (pr_tbcampos   => vr_tbcampos        --> tabela com as tags
                             ,pr_dsobjeto   => vr_dsobjeto        --> descrição do objeto
                             ,pr_tpoperacao => 3 /* exclusao */   --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                             ,pr_dscritic   => vr_dscritic);      --> Descricao erro

        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        --> alterar para inclusao
        vr_tpoperacao := 1;

      END LOOP;

    END IF;

    FOR i IN 1..2 LOOP
      --> Montar objeto concatenando com o tipo de liberação
      vr_dsobjeto := 'MotivoSaqueParcial';

      --> Caso pessoa fisica estava marcado
      IF i = 1 AND pr_rw_dados.flgpessoa_fisica = 1 THEN
        vr_dsobjeto := vr_dsobjeto ||i;
      ELSIF i = 2 AND pr_rw_dados.flgpessoa_juridica = 1 THEN
        vr_dsobjeto := vr_dsobjeto ||i;
      ELSE
        CONTINUE; -- Vai para o proximo registro
      END IF;

      -- Limpa a tab de campos
      vr_tbcampos.DELETE();

      --
      vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'codigo';
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados.cdmotivo;
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'number';
      --
      vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'descricao';
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados.dsmotivo;
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';

      --> Rotina para montar xml e enviar via webservice informaçoes para o CRM
      pc_manterConteudoCRM (pr_tbcampos   => vr_tbcampos        --> tabela com as tags
                           ,pr_dsobjeto   => vr_dsobjeto        --> descrição do objeto
                           ,pr_tpoperacao => vr_tpoperacao      --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                           ,pr_dscritic   => vr_dscritic);      --> Descricao erro

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

    END LOOP;


  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro nao tratado pc_processa_mtv_saque_parcial: '||SQLERRM;
  END pc_processa_mtv_saque_parcial;

  /*****************************************************************************/
  /**   Procedure para enviar dados de mtv_desligamento(tbcotas_motivo_desligamento) para o CRM     **/
  /*****************************************************************************/
  PROCEDURE pc_processa_mtv_desligamento ( pr_rw_dados      IN tbcotas_motivo_desligamento%ROWTYPE   --> Rowtype contendo os dados dos Campos da tabela
                                          ,pr_rw_dados_ant  IN tbcotas_motivo_desligamento%ROWTYPE   --> Rowtype contendo os dados anteriores dos Campos da tabela
                                          ,pr_tpoperacao    IN INTEGER           --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                          ,pr_dscritic     OUT VARCHAR2          --> Retornar Critica
                                          ) IS

  /* ..........................................................................
    --
    --  Programa : pc_processa_mtv_desligamento
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para enviar dados de mtv_desligamento(tbcotas_motivo_desligamento) para o CRM
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------


    ---------------> VARIAVEIS <-----------------
    vr_dscritic VARCHAR2(1000);
    vr_exc_erro EXCEPTION;

    vr_tbcampos NPCB0003.typ_tab_campos_soap;
    vr_dsobjeto VARCHAR2(100);
    vr_tpoperacao INTEGER;

  BEGIN
    vr_tpoperacao := pr_tpoperacao;


    --Se for operacao "Alteracao" deve excluir antigo antes de incluir novo
    IF vr_tpoperacao = 2 AND
        --> e foi alterado os tipos
       (pr_rw_dados_ant.flgpessoa_fisica <> pr_rw_dados.flgpessoa_fisica OR
        pr_rw_dados_ant.flgpessoa_juridica <> pr_rw_dados.flgpessoa_juridica )THEN

      FOR i IN 1..2 LOOP
      
        --> Montar objeto concatenando com o tipo de liberação
        vr_dsobjeto := 'MotivoDesligamento';
      
        --> Caso pessoa fisica estava marcado
        IF i = 1 AND pr_rw_dados_ant.flgpessoa_fisica = 1 THEN
          vr_dsobjeto := vr_dsobjeto ||i;
        ELSIF i = 2 AND pr_rw_dados_ant.flgpessoa_juridica = 1 THEN
          vr_dsobjeto := vr_dsobjeto ||i;
        ELSE
          continue;
        END IF;

        -- Limpa a tab de campos
        vr_tbcampos.DELETE();

        --
        vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'codigo';
        vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados_ant.cdmotivo;
        vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'number';
        --
        vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'descricao';
        vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados_ant.dsmotivo;
        vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';


        --> Rotina para montar xml e enviar via webservice informaçoes para o CRM
        pc_manterConteudoCRM (pr_tbcampos   => vr_tbcampos        --> tabela com as tags
                             ,pr_dsobjeto   => vr_dsobjeto        --> descrição do objeto
                             ,pr_tpoperacao => 3 /* exclusao */   --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                             ,pr_dscritic   => vr_dscritic);      --> Descricao erro

        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        --> alterar para inclusao
        vr_tpoperacao := 1;

      END LOOP;

    END IF;

    FOR i IN 1..2 LOOP
      --> Montar objeto concatenando com o tipo de liberação
      vr_dsobjeto := 'MotivoDesligamento';
    
      --> Caso pessoa fisica estava marcado
      IF i = 1 AND pr_rw_dados.flgpessoa_fisica = 1 THEN
        vr_dsobjeto := vr_dsobjeto ||i;
      ELSIF i = 2 AND pr_rw_dados.flgpessoa_juridica = 1 THEN
        vr_dsobjeto := vr_dsobjeto ||i;
      ELSE
        continue;
      END IF;

      -- Limpa a tab de campos
      vr_tbcampos.DELETE();

      --
      vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'codigo';
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados.cdmotivo;
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'number';
      --
      vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'descricao';
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados.dsmotivo;
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';

      --> Rotina para montar xml e enviar via webservice informaçoes para o CRM
      pc_manterConteudoCRM (pr_tbcampos   => vr_tbcampos        --> tabela com as tags
                           ,pr_dsobjeto   => vr_dsobjeto        --> descrição do objeto
                           ,pr_tpoperacao => vr_tpoperacao      --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                           ,pr_dscritic   => vr_dscritic);      --> Descricao erro

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

    END LOOP;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro nao tratado pc_processa_mtv_desligamento: '||SQLERRM;
  END pc_processa_mtv_desligamento;

  /*****************************************************************************/
  /**   Procedure para enviar dados de prazo_desligamento(craptab) para o CRM    **/
  /*****************************************************************************/
  PROCEDURE pc_processa_prazo_desligamento ( pr_rw_dados    IN craptab%ROWTYPE   --> Rowtype contendo os dados dos Campos da tabela
                                            ,pr_tpoperacao  IN INTEGER           --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                            ,pr_dscritic   OUT VARCHAR2          --> Retornar Critica
                                           ) IS

  /* ..........................................................................
    --
    --  Programa : pc_processa_prazo_desligamento
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para enviar dados de prazo_desligamento(craptab) para o CRM
    --               OBS: CRAPTAB UPPER(CDACESSO) = 'PRAZODESLIGAMENTO'
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------


    ---------------> VARIAVEIS <-----------------
    vr_dscritic VARCHAR2(1000);
    vr_exc_erro EXCEPTION;

    vr_tbcampos NPCB0003.typ_tab_campos_soap;

  BEGIN

    -- Limpa a tab de campos
    vr_tbcampos.DELETE();
    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'codigo';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados.cdcooper;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'number';
    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'descricao';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := trim(substr(pr_rw_dados.dstextab,1,5));  --everton
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';


    --> Rotina para montar xml e enviar via webservice informaçoes para o CRM
    pc_manterConteudoCRM (pr_tbcampos   => vr_tbcampos      --> tabela com as tags
                         ,pr_dsobjeto   => 'CreditoSobra'   --> descrição do objeto
                         ,pr_tpoperacao => pr_tpoperacao    --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                         ,pr_dscritic   => vr_dscritic);    --> Descricao erro

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro nao tratado pc_processa_prazo_desligamento: '||SQLERRM;
  END pc_processa_prazo_desligamento;



  /*****************************************************************************/
  /**  Procedure para enviar dados de operadora_telefone(craptab) para o CRM  **/
  /*****************************************************************************/
  PROCEDURE pc_processa_operadora_telefone( pr_rw_dados    IN craptab%ROWTYPE   --> Rowtype contendo os dados dos Campos da tabela
                                           ,pr_tpoperacao  IN INTEGER           --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                           ,pr_dscritic   OUT VARCHAR2          --> Retornar Critica
                                          ) IS

  /* ..........................................................................
    --
    --  Programa : pc_processa_operadora_telefone
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para enviar dados de operadora_telefone(craptab) para o CRM
    --               OBS: CRAPTAB COM CDCOOPER = 0 AND UPPER(CDACESSO) = 'OPETELEFON'
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------


    ---------------> VARIAVEIS <-----------------
    vr_dscritic VARCHAR2(1000);
    vr_exc_erro EXCEPTION;

    vr_tbcampos NPCB0003.typ_tab_campos_soap;

  BEGIN

    -- Limpa a tab de campos
    vr_tbcampos.DELETE();

    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'codigo';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados.tpregist;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'number';
    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'descricao';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados.dstextab;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';

    --> Rotina para montar xml e enviar via webservice informaçoes para o CRM
    pc_manterConteudoCRM (pr_tbcampos   => vr_tbcampos         --> tabela com as tags
                         ,pr_dsobjeto   => 'OperadoraTelefone' --> descrição do objeto
                         ,pr_tpoperacao => pr_tpoperacao       --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                         ,pr_dscritic   => vr_dscritic);       --> Descricao erro

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro nao tratado pc_processa_operadora_telefone: '||SQLERRM;
  END pc_processa_operadora_telefone;

  /*****************************************************************************/
  /**   Procedure para enviar dados de setor_economico(craptab) para o CRM    **/
  /*****************************************************************************/
  PROCEDURE pc_processa_setor_economico ( pr_rw_dados    IN craptab%ROWTYPE   --> Rowtype contendo os dados dos Campos da tabela
                                         ,pr_tpoperacao  IN INTEGER           --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                         ,pr_dscritic   OUT VARCHAR2          --> Retornar Critica
                                        ) IS

  /* ..........................................................................
    --
    --  Programa : pc_processa_setor_economico
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para enviar dados de setor_economico(craptab) para o CRM
    --               OBS: CRAPTAB COM CDCOOPER = 3 AND UPPER(CDACESSO) = 'SETORECONO'
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------


    ---------------> VARIAVEIS <-----------------
    vr_dscritic VARCHAR2(1000);
    vr_exc_erro EXCEPTION;

    vr_tbcampos NPCB0003.typ_tab_campos_soap;

  BEGIN

    -- Limpa a tab de campos
    vr_tbcampos.DELETE();

    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'codigo';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados.tpregist;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'number';
    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'descricao';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados.dstextab;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';


    --> Rotina para montar xml e enviar via webservice informaçoes para o CRM
    pc_manterConteudoCRM (pr_tbcampos   => vr_tbcampos      --> tabela com as tags
                         ,pr_dsobjeto   => 'SetorEconomico' --> descrição do objeto
                         ,pr_tpoperacao => pr_tpoperacao    --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                         ,pr_dscritic   => vr_dscritic);    --> Descricao erro

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro nao tratado pc_processa_setor_economico: '||SQLERRM;
  END pc_processa_setor_economico;


  /*****************************************************************************/
  /**   Procedure para enviar dados de ramo_atividade(GNRATIV) para o CRM    **/
  /*****************************************************************************/
  PROCEDURE pc_processa_ramo_atividade( pr_rw_dados     IN GNRATIV%ROWTYPE   --> Rowtype contendo os dados dos Campos da tabela
                                       ,pr_rw_dados_ant IN GNRATIV%ROWTYPE   --> Rowtype contendo os dados anteriores
                                       ,pr_tpoperacao   IN INTEGER           --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                       ,pr_dscritic    OUT VARCHAR2          --> Retornar Critica
                                        ) IS

  /* ..........................................................................
    --
    --  Programa : pc_processa_ramo_atividade
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para enviar dados de ramo_atividade(GNRATIV) para o CRM
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------


    ---------------> VARIAVEIS <-----------------
    vr_dscritic VARCHAR2(1000);
    vr_exc_erro EXCEPTION;

    vr_tbcampos NPCB0003.typ_tab_campos_soap;
    vr_dsobjeto VARCHAR2(100);

  BEGIN

    -- Limpa a tab de campos
    vr_tbcampos.DELETE();
    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'codigo';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados.cdrmativ;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'number';
    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'descricao';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados.nmrmativ;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';

    --> Montar objeto
    vr_dsobjeto := 'RamoAtividade';

    --> Rotina para montar xml e enviar via webservice informaçoes para o CRM
    pc_manterConteudoCRM (pr_tbcampos   => vr_tbcampos      --> tabela com as tags
                         ,pr_dsobjeto   => vr_dsobjeto      --> descrição do objeto
                         ,pr_dsobjagr   => 'CodigoSetorEconomico'     --> descrição do objeto agrupador
                         ,pr_cddadagr   => pr_rw_dados.cdseteco --> Codigo do dado agrupador
                         ,pr_tpoperacao => pr_tpoperacao    --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                         ,pr_dscritic   => vr_dscritic);    --> Descricao erro

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro nao tratado pc_processa_ramo_atividade: '||SQLERRM;
  END pc_processa_ramo_atividade;


  /*****************************************************************************/
  /**     Procedure para enviar dados de cidade(CRAPMUN) para o CRM         **/
  /*****************************************************************************/
  PROCEDURE pc_processa_cidade ( pr_rw_dados    IN crapmun%ROWTYPE   --> Rowtipe contendo os dados dos Campos da tabela
                                ,pr_tpoperacao  IN INTEGER           --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                ,pr_dscritic   OUT VARCHAR2          --> Retornar Critica
                               ) IS

  /* ..........................................................................
    --
    --  Programa : pc_processa_cidade
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para enviar dados de cidade(CRAPMUN) para o CRM
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------


    ---------------> VARIAVEIS <-----------------
    vr_dscritic VARCHAR2(1000);
    vr_exc_erro EXCEPTION;

    vr_tbcampos NPCB0003.typ_tab_campos_soap;

  BEGIN

    -- Limpa a tab de campos
    vr_tbcampos.DELETE();

    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'codigo';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados.idcidade;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'number';
    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'descricao';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados.dscidade;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';
    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'sigla';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados.cdestado;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';

    --> Rotina para montar xml e enviar via webservice informaçoes para o CRM
    pc_manterConteudoCRM (pr_tbcampos   => vr_tbcampos     --> tabela com as tags
                         ,pr_dsobjeto   => 'Cidade'        --> descrição do objeto
                         ,pr_tpoperacao => pr_tpoperacao   --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                         ,pr_dscritic   => vr_dscritic);   --> Descricao erro

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro nao tratado pc_processa_cidade: '||SQLERRM;
  END pc_processa_cidade;

  /*****************************************************************************/
  /**     Procedure para enviar dados de banco(crapban) para o CRM         **/
  /*****************************************************************************/
  PROCEDURE pc_processa_banco( pr_rw_dados    IN crapban%ROWTYPE   --> Rowtipe contendo os dados dos Campos da tabela
                              ,pr_tpoperacao  IN INTEGER           --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                              ,pr_dscritic   OUT VARCHAR2          --> Retornar Critica
                             ) IS

  /* ..........................................................................
    --
    --  Programa : pc_processa_banco
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para enviar dados de banco(crapban) para o CRM
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------


    ---------------> VARIAVEIS <-----------------
    vr_dscritic VARCHAR2(1000);
    vr_exc_erro EXCEPTION;



  vr_tbcampos NPCB0003.typ_tab_campos_soap;

  BEGIN

    -- Limpa a tab de campos
    vr_tbcampos.DELETE();


    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'codigo';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados.cdbccxlt;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'number';
    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'descricao';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados.nmextbcc;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';

    --> Rotina para montar xml e enviar via webservice informaçoes para o CRM
    pc_manterConteudoCRM (pr_tbcampos   => vr_tbcampos     --> tabela com as tags
                         ,pr_dsobjeto   => 'Banco'         --> descrição do objeto
                         ,pr_tpoperacao => pr_tpoperacao   --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                         ,pr_dscritic   => vr_dscritic);   --> Descricao erro

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro nao tratado pc_processa_banco: '||SQLERRM;
  END pc_processa_banco;
  
  /*****************************************************************************/
  /**     Procedure para enviar dados de regional(crapreg) para o CRM         **/
  /*****************************************************************************/
  PROCEDURE pc_processa_regional (  pr_rw_dados    IN crapreg%ROWTYPE   --> Rowtype contendo os dados dos Campos da tabela
                                   ,pr_tpoperacao  IN INTEGER           --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                   ,pr_dscritic   OUT VARCHAR2          --> Retornar Critica
                                ) IS

  /* ..........................................................................
    --
    --  Programa : pc_processa_regional
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para enviar dados de regional(crapreg) para o CRM  
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------


    ---------------> VARIAVEIS <-----------------
    vr_dscritic VARCHAR2(1000);
    vr_exc_erro EXCEPTION;

    vr_tbcampos NPCB0003.typ_tab_campos_soap;

  BEGIN

    -- Limpa a tab de campos
    vr_tbcampos.DELETE();


    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'codigo';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados.cddregio;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'number';    
    --
    vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'descricao';
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_rw_dados.dsdregio;
    vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';
    

    --> Rotina para montar xml e enviar via webservice informaçoes para o CRM
    pc_manterConteudoCRM (pr_tbcampos   => vr_tbcampos     --> tabela com as tags
                         ,pr_dsobjeto   => 'Regional'      --> descrição do objeto
                         ,pr_dsobjagr   => 'CodigoCooperativa'  --> descrição do objeto agrupador
                         ,pr_cddadagr   => pr_rw_dados.cdcooper --> Codigo do dado agrupador
                         ,pr_tpoperacao => pr_tpoperacao   --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                         ,pr_dscritic   => vr_dscritic);   --> Descricao erro

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;


  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro nao tratado pc_processa_regional: '||SQLERRM;
  END pc_processa_regional;

  /*****************************************************************************/
  /**     Procedure para enviar dados de banco(crapban) para o CRM         **/
  /*****************************************************************************/
  PROCEDURE pc_grava_inconsistencia_crm( pr_dsobjeto    IN VARCHAR2         --> descrição do objeto
                                        ,pr_dstpoper    IN VARCHAR2         --> descrição do tipo de operacao
                                        ,pr_dscritic    IN VARCHAR2         --> Critica
                                        ,pr_dsdetail    IN VARCHAR2         --> detalhe da critica
                                         ) IS

  /* ..........................................................................
    --
    --  Programa : pc_processa_banco
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para enviar dados de banco(crapban) para o CRM
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------


    ---------------> VARIAVEIS <-----------------
    vr_dscritic VARCHAR2(1000);
    vr_exc_erro EXCEPTION;
    vr_des_erro VARCHAR2(100);

    PRAGMA AUTONOMOUS_TRANSACTION;



  BEGIN

    -- Insere na inconsistencia
    gene0005.pc_gera_inconsistencia ( pr_cdcooper => 3
                                     ,pr_iddgrupo => 3 -- Erros de Script CRM
                                     ,pr_tpincons => 2
                                     ,pr_dsregist => 'Erro ao enviar dados ao CRM '||
                                                     'Objeto: '|| pr_dsobjeto ||
                                                     ', operacao: '||pr_dstpoper ||
                                                     ', critica: '||pr_dscritic
                                     ,pr_dsincons => substr(pr_dsdetail,1,500)
                                     ,pr_des_erro => vr_des_erro
                                     ,pr_dscritic => vr_dscritic);

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      COMMIT;
  END pc_grava_inconsistencia_crm;


  --> Rotina para montar xml e enviar via webservice informaçoes para o CRM
  PROCEDURE pc_manterConteudoCRM (pr_tbcampos    IN NPCB0003.typ_tab_campos_soap --> tabela com as tags
                                 ,pr_dsobjeto    IN VARCHAR2                     --> descrição do objeto
                                 ,pr_dsobjagr    IN VARCHAR2 DEFAULT NULL        --> descrição do objeto agrupador
                                 ,pr_cddadagr    IN VARCHAR2 DEFAULT NULL        --> Codigo do dado agrupador
                                 ,pr_tpoperacao  IN INTEGER                      --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                 ,pr_dscritic   OUT VARCHAR2) IS                 --> Descricao erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_manterConteudoCRM
    --  Sistema  : CRM
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana
    --  Data     : Outubro/2017.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  :  Rotina para montar xml e enviar via webservice informaçoes para o CRM
    --
    -- Alteracoes:
    --
    ---------------------------------------------------------------------------------------------------------------
    -- VARIÁVEIS
    vr_dscritic     VARCHAR2(2000);
    vr_dscritic_aux VARCHAR2(2000);
    vr_dsdetail     VARCHAR2(2000);
    vr_cdcritic     NUMBER;
    vr_des_erro     VARCHAR2(100);
    vr_xml          XMLType; --> XML de requisição
    vr_tbcampos     NPCB0003.typ_tab_campos_soap;
    vr_dstpoper     VARCHAR2(100);
    vr_cdmetodo     INTEGER;

  BEGIN

   --> Definir metodo conforme o tipo de operacao
   IF pr_tpoperacao = 3 THEN
     vr_cdmetodo := 2; --> excluirConteudoCRMRequest
   ELSE
     vr_cdmetodo := 1; --> manterConteudoCRMRequest
   END IF;

    -- Chama a rotina que monta a estrutura principal do SOAP
    SOAP0002.pc_xmlsoap_monta_estrutura( pr_cdservic => 1 --> ListaDominioInternoService
                                        ,pr_cdmetodo => vr_cdmetodo
                                        ,pr_xml      => vr_xml
                                        ,pr_des_erro => vr_des_erro
                                        ,pr_dscritic => vr_dscritic);

    -- Verifica se ocorreu erro
    IF vr_des_erro != 'OK' THEN
      RAISE vr_exc_erro;
    END IF;

    -- Incluir as tags no SOAP
    gene0007.pc_insere_tag(pr_xml      => vr_xml
                          ,pr_tag_pai  => SOAP0002.vr_wscip_services(1).tbmetodos(vr_cdmetodo)
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'v01:cadastramentoDominio'
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => vr_dscritic);

    -- Verifica se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    IF pr_tpoperacao = 1 THEN
      vr_dstpoper := 'insert';
    ELSIF pr_tpoperacao = 2 THEN
      vr_dstpoper := 'update';
    ELSIF pr_tpoperacao = 3 THEN
      vr_dstpoper := 'delete';
    END IF;

    -- Incluir as tags no SOAP
    gene0007.pc_insere_tag(pr_xml      => vr_xml
                          ,pr_tag_pai  => SOAP0002.vr_wscip_services(1).tbmetodos(vr_cdmetodo)
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'v01:tipoInteracao'
                          ,pr_tag_cont => vr_dstpoper
                          ,pr_des_erro => vr_dscritic);

    -- Verifica se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    vr_tbcampos := pr_tbcampos;

    -- Se foram passadas as tags para serem inclusas na requisição
    IF pr_tbcampos.COUNT() > 0 THEN
      
      --> Verificar se possui estrutura aagrupadora e incluir codigo agrupador
      IF pr_dsobjagr IS NOT NULL THEN
        
        -- Incluir as tags no SOAP
        gene0007.pc_insere_tag(pr_xml      => vr_xml
                              ,pr_tag_pai  => 'v01:cadastramentoDominio'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'v12:codigoAgrupador'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);

        -- Verifica se ocorreu erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
        -- Incluir as tags no SOAP
        gene0007.pc_insere_tag(pr_xml      => vr_xml
                              ,pr_tag_pai  => 'v12:codigoAgrupador'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'v13:codigo'
                              ,pr_tag_cont => pr_cddadagr
                              ,pr_des_erro => vr_dscritic);
        
      
      END IF;
      
      
      -- Incluir as tags no SOAP
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'v01:cadastramentoDominio'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'v12:dataAtualizacao'
                            ,pr_tag_cont => to_char(SYSDATE,'RRRR-MM-DD"T"HH24:MI:SS')
                            ,pr_des_erro => vr_dscritic);

      -- Verifica se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Incluir as tags no SOAP
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'v01:cadastramentoDominio'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'v12:funcional'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      -- Verifica se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;


      -- Incluir as tags no SOAP
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'v01:cadastramentoDominio'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'v12:objeto'
                            ,pr_tag_cont => pr_dsobjeto
                            ,pr_des_erro => vr_dscritic);

      -- Verifica se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      --> Verificar se possui estrutura aagrupadora e nome da estrutura
      IF pr_dsobjagr IS NOT NULL THEN
        -- Incluir as tags no SOAP
        gene0007.pc_insere_tag(pr_xml      => vr_xml
                              ,pr_tag_pai  => 'v01:cadastramentoDominio'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'v12:objetoAgrupador'
                              ,pr_tag_cont => pr_dsobjagr
                              ,pr_des_erro => vr_dscritic);

        -- Verifica se ocorreu erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;

      FOR ind IN pr_tbcampos.FIRST..pr_tbcampos.LAST LOOP
        -- Incluir as tags no SOAP
        gene0007.pc_insere_tag(pr_xml      => vr_xml
                              ,pr_tag_pai  => 'v12:funcional'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'v13:'||pr_tbcampos(ind).dsNomTag
                              ,pr_tag_cont => pr_tbcampos(ind).dsValTag
                              ,pr_des_erro => vr_dscritic);

        -- Verifica se ocorreu erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

      END LOOP;
    END IF;

    gene0002.pc_XML_para_arquivo(pr_XML => vr_xml,
    pr_caminho => '/microsh/cecred/andrino', pr_arquivo => 'teste.xml', pr_des_erro =>  vr_des_erro);

    --> Enviar requisição SOAP
    SOAP0002.pc_envia_requisicao (pr_cdservic  => 1 --> ListaDominioInternoService --> Chamve do Serviço requisitado
                                 ,pr_cdmetodo  => vr_cdmetodo                      --> Chave do Método requisitado
                                 ,pr_xml       => vr_xml                           --> Objeto do XML criado
                                 ,pr_cdcritic  => vr_cdcritic                      --> codigo do ero
                                 ,pr_dscritic  => vr_dscritic                      --> Descricao erro
                                 ,pr_dsdetail  => vr_dsdetail);                    --> Retornar os detalhes da critica

    -- Verifica se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_dscritic IS NULL AND
         vr_cdcritic > 0 THEN

        pr_dscritic := 'Erro ao manter conteudo CRM('||vr_cdcritic||').';
      ELSE
        pr_dscritic := vr_dscritic;
      END IF;

      -- Insere na inconsistencia
      pc_grava_inconsistencia_crm( pr_dsobjeto => pr_dsobjeto
                                  ,pr_dstpoper => vr_dstpoper
                                  ,pr_dscritic => vr_dscritic
                                  ,pr_dsdetail => vr_dsdetail);

    WHEN OTHERS THEN
      pr_dscritic := 'Erro na PC_XMLSOAP_MONTA_REQUISICAO: '||SQLERRM;
  END pc_manterConteudoCRM;


END CADA0013;
/
