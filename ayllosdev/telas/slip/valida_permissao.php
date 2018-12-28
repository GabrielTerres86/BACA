<?php
	/*!
    * FONTE        : valida_risco.php
	* CRIAÇÃO      : Alcemir Junior - Mout's
	* DATA CRIAÇÃO : 10/10/2018
	* OBJETIVO     : validar se já existe conta contabil tela SLIP
	* --------------
	* ALTERAÇÕES   :
	* --------------
	*/

	session_cache_limiter("private");
	session_start();

	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");
	require_once("../../class/xmlfile.php");
	isPostMethod();

	// Ler parametros passados via POST
	$cddotipo = (isset($_POST["cddotipo"])) ? $_POST["cddotipo"] : "";   // codigo de risco

	//Validar permissão do usuário
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$cddotipo,false)) <> "") {
	//	exibirErro("error",$msgError,"Alerta - Aimaro","",false);
		echo "showError('error','".$msgError."','Alerta - Aimaro','estadoInicial();')";
	}
?>