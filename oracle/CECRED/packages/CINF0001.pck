CREATE OR REPLACE PACKAGE CECRED.CINF0001 IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CINF0001
  --  Sistema  : Tranformacao BO tela CONINF.
  --  Sigla    : CRED
  --  Autor    : Carlos Henrique Weinhold
  --  Data     : Março/2016.                   Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Tranformacao BO tela CONINF.

  -- Public type declarations

  
  -- Public constant declarations


  -- Public variable declarations
  TYPE typ_reg_crapcop IS RECORD(cdcooper crapcop.cdcooper%TYPE 
                                ,nmrescop crapcop.nmrescop%TYPE);
                                
  TYPE typ_tab_crapcop IS
    TABLE OF typ_reg_crapcop
      INDEX BY PLS_INTEGER;

  PROCEDURE pc_carrega_cooperativas (pr_nmcooper     OUT VARCHAR2,
                                     pr_tab_crapcop  OUT VARCHAR2,
                                     pr_xml_dsmsgerr OUT VARCHAR2,
                                     pr_dsretorn     OUT VARCHAR2);

END CINF0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.CINF0001 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CINF0001
  --  Sistema  : Procedimentos para agendamentos na Internet (sistema/generico/procedures/b1wgen0142.p)
  --  Sigla    : CRED
  --  Autor    : Gabriel Capoia (DB1)
  --  Data     : Novembro/2012                     Ultima atualizacao: 30/05/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Tranformacao BO tela CONINF.
  -- Alteracoes: 05/08/2014 - Alteração da Nomeclatura para PA (Vanessa).
  --  
  --             02/09/2014 - Carregar somente cooperativas ativas na procedure
  --                          pi_carrega_cooperativas (David).
  --
  --		         30/05/2016 - Ajuste para formatar a informação cdagectl com 4 zeros 
  --                          (Adriano - M117)
  --
  --             11/04/2017 - Alteração do nome da cooperativa VIACREDI AV (Dionathan)
  ---------------------------------------------------------------------------------------------------------------                             

  PROCEDURE pc_carrega_cooperativas (pr_nmcooper     OUT VARCHAR2,
                                     pr_tab_crapcop  OUT VARCHAR2,
                                     pr_xml_dsmsgerr OUT VARCHAR2,
                                     pr_dsretorn     OUT VARCHAR2) IS   --> Descricao do erro
  BEGIN
    DECLARE
    
      CURSOR cr_crapcop IS
        SELECT cdcooper
              ,DECODE(cdcooper,16,'VIACREDI ALTO VALE', nmrescop) nmrescop
              ,cdagectl
          FROM crapcop 
         WHERE cdcooper <> 3 
           AND flgativo = 1
         ORDER BY cdagectl;
      rw_crapcop cr_crapcop%ROWTYPE;  
      
    BEGIN
      
      pr_nmcooper    := 'TODAS,0';
      pr_tab_crapcop := '<COOPERATIVAS_DESTINO>';
      
      FOR rw_crapcop IN cr_crapcop LOOP

        pr_nmcooper := pr_nmcooper                      || ',' || 
                       trim(upper(rw_crapcop.nmrescop)) || ',' ||
                       trim(to_char(rw_crapcop.cdcooper));
                       
        pr_tab_crapcop := pr_tab_crapcop || 
        '<DADOS>' || 
        '<cdagectl>' || trim(to_char(rw_crapcop.cdagectl,'fm0000')) || '</cdagectl>' ||
        '<nmrescop>' || trim(rw_crapcop.nmrescop) || '</nmrescop>' ||
        '</DADOS>';

      END LOOP;
      
      pr_tab_crapcop := pr_tab_crapcop || '</COOPERATIVAS_DESTINO>';
      
    EXCEPTION
      WHEN OTHERS THEN
        -- definir retorno
        pr_xml_dsmsgerr := '<dsmsgerr>Erro inesperado. Nao foi possivel consultar as cooperativas. Tente novamente ou contacte seu PA</dsmsgerr>';
        pr_dsretorn := 'NOK';
    END;
  END pc_carrega_cooperativas;

END CINF0001;
/
