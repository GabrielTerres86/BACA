<?
/************************************************************************
	 Fonte: produtos.php                                              
	 Autor: Gabriel - Rkam                                                    
	 Data : Setembro/2015                   Última alteraçÃo: 
	                                                                  
	 Objetivo  : Mostrar rotina de Produtos da tela ATENDA            
	                                                                  	 
	 Alterações: 
	
	************************************************************************/
?>

<?

	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	// Se parâmetros necessários não foram passados
	if (!isset($_POST["nmdatela"]) || !isset($_POST["nmrotina"]) || !isset($_POST["opeProdutos"]) ) {

		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro');
	
	}	

	// Carrega permiss�es do operador
	include("../../../includes/carrega_permissoes.php");	
	
	setVarSession("opcoesTela",$opcoesTela);

	include('../../../includes/produtos/produtos.php');
	
	
?>
	
	
