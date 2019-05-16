CREATE OR REPLACE PACKAGE CECRED.GENE_F8N AS

/* Inclusão de log com retorno do rowid */
  PROCEDURE pc_gera_log_f8n(pr_cdcooper IN craplgm.cdcooper%TYPE
                       ,pr_cdoperad IN craplgm.cdoperad%TYPE
                       ,pr_dscritic IN craplgm.dscritic%TYPE
                       ,pr_dsorigem IN craplgm.dsorigem%TYPE
                       ,pr_dstransa IN craplgm.dstransa%TYPE
                       ,pr_dttransa IN craplgm.dttransa%TYPE
                       ,pr_flgtrans IN craplgm.flgtrans%TYPE
                       ,pr_hrtransa IN craplgm.hrtransa%TYPE
                       ,pr_idseqttl IN craplgm.idseqttl%TYPE
                       ,pr_nmdatela IN craplgm.nmdatela%TYPE
                       ,pr_nrdconta IN craplgm.nrdconta%TYPE
                       ,pr_nrdrowid OUT ROWID);

/* Inclusão de log a nível de item  */
  PROCEDURE pc_gera_log_item_f8n(pr_nrdrowid IN ROWID
                            ,pr_nmdcampo IN craplgi.nmdcampo%TYPE
                            ,pr_dsdadant IN craplgi.dsdadant%TYPE
                            ,pr_dsdadatu IN craplgi.dsdadatu%TYPE);

END GENE_F8N;
/
CREATE OR REPLACE PACKAGE BODY CECRED.GENE_F8N AS

/* Inclusão de log com retorno do rowid */
  PROCEDURE pc_gera_log_f8n(pr_cdcooper IN craplgm.cdcooper%TYPE
                       ,pr_cdoperad IN craplgm.cdoperad%TYPE
                       ,pr_dscritic IN craplgm.dscritic%TYPE
                       ,pr_dsorigem IN craplgm.dsorigem%TYPE
                       ,pr_dstransa IN craplgm.dstransa%TYPE
                       ,pr_dttransa IN craplgm.dttransa%TYPE
                       ,pr_flgtrans IN craplgm.flgtrans%TYPE
                       ,pr_hrtransa IN craplgm.hrtransa%TYPE
                       ,pr_idseqttl IN craplgm.idseqttl%TYPE
                       ,pr_nmdatela IN craplgm.nmdatela%TYPE
                       ,pr_nrdconta IN craplgm.nrdconta%TYPE
                       ,pr_nrdrowid OUT ROWID) IS
   BEGIN
	CECRED.GENE0001.pc_gera_log(pr_cdcooper, pr_cdoperad, pr_dscritic, pr_dsorigem, pr_dstransa, pr_dttransa, pr_flgtrans, pr_hrtransa, pr_idseqttl, pr_nmdatela, pr_nrdconta, pr_nrdrowid);
   END pc_gera_log_f8n;


   /* Inclusão de log a nível de item  */
  PROCEDURE pc_gera_log_item_f8n(pr_nrdrowid IN ROWID
                            ,pr_nmdcampo IN craplgi.nmdcampo%TYPE
                            ,pr_dsdadant IN craplgi.dsdadant%TYPE
                            ,pr_dsdadatu IN craplgi.dsdadatu%TYPE) IS
	BEGIN
		CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid, pr_nmdcampo, pr_dsdadant, pr_dsdadatu);
	END pc_gera_log_item_f8n;

END GENE_F8N;
/
