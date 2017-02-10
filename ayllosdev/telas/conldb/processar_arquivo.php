<?php
/*
 * FONTE        : processar_arquivo.php
 * CRIAÇÃO      : Carlos Henrique Weinhold
 * DATA CRIAÇÃO : 09/02/2017
 * OBJETIVO     : Executa o job CCRD0004.pc_efetua_processo;
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');

// Verifica se tela foi chamada pelo método POST
isPostMethod();

$xml = new XmlMensageria();

mensageria($xml, "CONLDB", "PROCESSA_ARQUIVO_DOMICILIO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
echo 'showError("inform",
			"Processo inicializado. Este processo pode levar alguns minutos. Verifique os arquivos processados.",
			"Notifica&ccedil;&atilde;o - Ayllos",
			"hideMsgAguardo();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';
?>