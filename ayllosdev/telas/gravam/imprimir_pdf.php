<?
/*!
 * FONTE        : imprimir_pdf.php
 * CRIAÇÃO      : Andrei (RKAM)
 * DATA CRIAÇÃO : Maio/2016
 * OBJETIVO     : Carrega arquivo pdf
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */ 
?>

<? 
	session_cache_limiter("private");
	session_start();

	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");
	
	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	

	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");

	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$_POST['cddopcao'])) <> "") {
?><script language="javascript">
  alert('<?php echo $msgError; ?>');
</script>
    
 <?php
		exit();	
	}	

	// Verifica se parâmetros necessários foram informados
	if (!isset($_POST['nmarqpdf'])) {
		?><script language="javascript">alert('Par&acirc;metros incorretos.');</script><?php
		exit();
	}	
	
	// Recebe as variaveis
	$nmarqpdf 	= $_POST['nmarqpdf'];

	// Chama função para mostrar PDF do impresso gerado no browser
	visualizaPDF($nmarqpdf);
	

?>