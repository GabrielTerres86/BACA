<? 
/*!
 * FONTE        : carrega_tela_estorno_pagamento.php
 * CRIA��O      : James Prust Junior
 * DATA CRIA��O : 14/09/2015
 * OBJETIVO     : Rotina para carregar a tela de Estornar Pagamento
 * --------------
 * ALTERA��ES   : 
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
		case 'E':
			require_once("form_estorno_pagamento.php");
		break;
		
		case 'R':
			require_once("form_impressao_estorno.php");
		break;
	}	
?>
<script>
hideMsgAguardo();
formataCampos();
</script>