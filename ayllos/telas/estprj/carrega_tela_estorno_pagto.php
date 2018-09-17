<? 
/*!
 * FONTE        : carrega_tela_estorno_pagto.php
 * CRIAÇÃO      : Jean Calao
 * DATA CRIAÇÃO : 20/06/2017
 * OBJETIVO     : Rotina para carregar a tela de Estornar pagamentos
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

	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : 0;
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> ''){
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	switch ($cddopcao){
		
		case 'C':
		    require_once("form_estorno_pagto.php");
		break;
		
		case 'P':
			require_once("form_envio_emp_pagto.php");
		break;
			
	}	
?>
<script>
hideMsgAguardo();
formataCampos();
</script>