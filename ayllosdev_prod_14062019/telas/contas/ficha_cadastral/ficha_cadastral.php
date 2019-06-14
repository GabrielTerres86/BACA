<?
/*!
 * FONTE        : ficha_cadastral.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 08/04/2010 
 * OBJETIVO     : Mostra rotina de Impressão da Ficha Cadastral da tela de CONTAS
 *
 * ALTERACOES   : 20/12/2010 - Adicionado chamada validaPermissao (Gabriel - DB1). 
 * 
 * 				  21/06/2012 - Adicionado confirmacao de impressao. (Jorge)
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
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") exibirErro('error',$msgError,'Alerta - Aimaro','');
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nmdatela"]) || !isset($_POST["nmrotina"])) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro','');
	
	// Carrega permissões do operador
	include('../../../includes/carrega_permissoes.php');
	
	setVarSession("opcoesTela",$opcoesTela);

	// Carregas as opções da Rotina de Bens
	$flgAcesso = (in_array("@", $glbvars["opcoesTela"]));	

	if ($flgAcesso == "") exibirErro('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de acesso a impress&atilde;o da Ficha Cadastral.','Alerta - Aimaro','');
?>

<script type="text/javascript">
	showConfirmacao('Deseja visualizar a impress&atilde;o?','Confirma&ccedil;&atilde;o - Aimaro','imprimeFichaCadastral();','hideMsgAguardo();','sim.gif','nao.gif');
</script>