<?php  
	/*********************************************************************
	 Fonte: monta_filtro.php                                                 
	 Autor: Jonata - Mouts
	 Data : Outubro/2018/2018                 Última Alteração: 
	                                                                  
	 Objetivo  : Mostrar o de filtro para pesquisa - hconve.                                  
	                                                                  
	 Alterações: 
	 
	 
	
	**********************************************************************/
	
?>
<?php
	
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}

	if($cddopcao == 'H'){
		
		include("apresentar_form_opcao_h.php"); 
			
	}if($cddopcao == 'F'){
		
		include("apresentar_form_opcao_f.php");
			
	}if($cddopcao == 'I'){
		
		include("importacao_arquivo.php");
			
	}if($cddopcao == 'A'){
		
		include("apresentar_form_opcao_a.php");
		
	}
	
	
?>
	









