<?
/*!
 * FONTE        : ficha_cadastral.php
 * CRIAÇÃO      : Gabriel
 * DATA CRIAÇÃO : 05/08/2010 
 * OBJETIVO     : Mostra rotina de Impressão da Ficha Cadastral da tela de ATENDA (Igual a CONTAS)
 *
 * ALTERACOES   : 
 *				  13/03/2012 - Adicionado hideMsgAguardo() (Jorge)
 * 
 *				  05/06/2012 - Adicionado confirmação de impressão (Jorge)
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
	
	var qttitular = $("#qttitula","#frmCabAtenda").val();
	//confirmação para gerar impressao
	showConfirmacao("Deseja visualizar a impress&atilde;o?","Confirma&ccedil;&atilde;o - Aimaro","hideMsgAguardo();imprimeFichaCadastral(qttitular);","hideMsgAguardo();","sim.gif","nao.gif");
	
</script>
