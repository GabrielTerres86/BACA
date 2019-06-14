<?
/*!
 * FONTE        : responsavel_legal.php
 * CRIAÇÃO      : Gabriel Capoia - DB1 Informatica
 * DATA CRIAÇÃO : 04/05/2010 
 * OBJETIVO     : Mostra rotina de Reponsavel Legal da tela de CONTAS
 *
 * ALTERACOES   : 20/12/2010 - Adicionado chamada validaPermissao (Gabriel - DB1). 
 *				  04/05/2012 - Realizado ajsutea para tranformar a rotina Responsavel Legal de forma generica.
 *							   Projeto GP - Sócios Menores(Adriano).
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
		
	include('../../../includes/responsavel_legal/responsavel_legal.php');
	
	
?>
	
	
