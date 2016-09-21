<?
/*!
 * FONTE        : responsavel_legal2.php
 * CRIAÇÃO      : adRIANO
 * DATA CRIAÇÃO : 04/05/2012 
 * OBJETIVO     : Mostra rotina de Reponsavel Legal da tela de CONTAS
 *
 * ALTERACOES   : 29/09/2015 - Reformulacao cadastral (Gabriel-RKAM)
 */	
?>
 
<?
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');		
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();	
	
	$flgcadas = $_POST['flgcadas'];
	
	$glbvars["nmrotina"] = (isset($_POST['nmrotina'])) ? $_POST['nmrotina'] : $glbvars["nmrotina"];
	
	// Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$op,false)) <> '') {
		$metodo =  ($flgcadas == 'M') ? 'proximaRotina();' : 'encerraRotina(false);';
		exibirErro('error',$msgError,'Alerta - Ayllos',$metodo,false);
	}
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST['nmdatela']) || !isset($_POST['nmrotina'])) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos','');
	
	// Carrega permissões do operador
	include('../../../includes/carrega_permissoes.php');	
	
	setVarSession("opcoesTela",$opcoesTela);		
		
	include('../../../includes/responsavel_legal/responsavel_legal2.php');
	
	
?>
	
	
