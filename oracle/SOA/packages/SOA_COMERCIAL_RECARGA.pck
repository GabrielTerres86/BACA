CREATE OR REPLACE PACKAGE SOA.SOA_COMERCIAL_RECARGA IS
  ---------------------------------------------------------------------------
  --
  --  Programa : SOA_COMERCIAL_RECARGA
  --  Sistema  : Rotinas para Recarga de celular
  --  Sigla    : SOA_COMERCIAL_RECARGA
  --  Autor    : Lucas Reinert
  --  Data     : Março/2017.                   Ultima atualizacao: 
  --
  -- Frequencia: Sempre que for chamado
  -- Objetivo  : Centralizar rotinas para utilização dos serviços de Recarga
	--             de Celular no Aymaru
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------  
	
	PROCEDURE pc_atualiza_produtos_recarga(pr_xmlrequi IN xmltype
																				,pr_cdcritic IN OUT NUMBER
																				,pr_dscritic IN OUT VARCHAR2
																				,pr_dsdetcri IN OUT VARCHAR2);
  
END SOA_COMERCIAL_RECARGA;
/
CREATE OR REPLACE PACKAGE BODY SOA.SOA_COMERCIAL_RECARGA IS
  ---------------------------------------------------------------------------
  --
  --  Programa : SOA_COMERCIAL_RECARGA
  --  Sistema  : Rotinas para Recarga de celular
  --  Sigla    : SOA_COMERCIAL_RECARGA
  --  Autor    : Lucas Reinert
  --  Data     : Março/2017.                   Ultima atualizacao: 
  --
  -- Frequencia: Sempre que for chamado
  -- Objetivo  : Centralizar rotinas para utilização dos serviços de Recarga
	--             de Celular no Aymaru
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------
	
	PROCEDURE pc_atualiza_produtos_recarga(pr_xmlrequi IN xmltype
																				,pr_cdcritic IN OUT NUMBER
																				,pr_dscritic IN OUT VARCHAR2
																				,pr_dsdetcri IN OUT VARCHAR2) IS
  BEGIN																				
		-- Chamar a procedure para atualizar os produtos de recarga
		CECRED.RCEL0001.pc_atualiza_produtos_recarga(pr_xmlrequi => pr_xmlrequi
																							 ,pr_cdcritic => pr_cdcritic
																							 ,pr_dscritic => pr_dscritic
																							 ,pr_dsdetcri => pr_dsdetcri);
	END pc_atualiza_produtos_recarga;
END SOA_COMERCIAL_RECARGA;
/
