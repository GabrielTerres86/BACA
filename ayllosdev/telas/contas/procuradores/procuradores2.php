<?
/*!
 * FONTE        : procuradores.php
 * CRIAÇÃO      : ADRIANO
 * DATA CRIAÇÃO : 04/06/2012
 * OBJETIVO     : Mostra rotina de Representantes/Procuradores da tela de CONTAS
 *
 *
 */	
?>

<?
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');		
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();	
	
	// Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],'@')) <> "") exibirErro('error',$msgError,'Alerta - Aimaro','');
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST['nmdatela']) || !isset($_POST['nmrotina'])) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro','');
	
	// Carrega permissões do operador
	include('../../../includes/carrega_permissoes.php');	
	
	setVarSession("opcoesTela",$opcoesTela);		
		
	include('../../../includes/procuradores/procuradores2.php');
	
	
?>
	
	
