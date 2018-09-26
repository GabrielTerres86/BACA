<?
/*!
 * FONTE        : procuradores.php
 * CRIAÇÃO      : Alexandre Scola - DB1 Informatica
 * DATA CRIAÇÃO : 09/03/2010 
 * OBJETIVO     : Mostra rotina de Representantes/Procuradores da tela de CONTAS
 *
 * ALTERACOES   : 20/12/2010 - Adicionado chamada validaPermissao (Gabriel - DB1). 
 *				  04/06/2012 - Ajustes referente ao projeto GP - Sócios Menores (Adriano).
 *                23/09/2015 - Reformulacao cadastral (Gabriel-RKAM).
 *                26/11/2015 - Ajuste na leitura das permissoes (Gabriel-RKAM)
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
	
				
	// Se parâmetros necessários não foram informados
	if (!isset($_POST['nmdatela']) || !isset($_POST['nmrotina'])) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro','');
	
	$flgcadas = $_POST['flgcadas'];		
			
	// Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($_POST['nmdatela'],$_POST['nmrotina'],'@',false)) <> '') {
		$metodo =  ($flgcadas == 'M') ? 'proximaRotina();' : 'encerraRotina(false);';
		exibirErro('error',$msgError,'Alerta - Aimaro',$metodo,true);
	}
	
	// Carrega permissões do operador
	include('../../../includes/carrega_permissoes.php');	
	
	setVarSession("opcoesTela",$opcoesTela);	

	include('../../../includes/procuradores/procuradores.php');
	
	
?>
	
	
