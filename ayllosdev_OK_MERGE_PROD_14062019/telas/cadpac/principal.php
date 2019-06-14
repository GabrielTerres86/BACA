<?php
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Jaison
 * DATA CRIAÇÃO : 05/07/2016
 * OBJETIVO     : Rotina para os dados
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	// Recebe a operação que está sendo realizada
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : ''; 	
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	require_once("form_cadpac.php");
?>
<script type="text/javascript">		
    formataCamposTela('<?php echo $cddopcao; ?>');    
</script>