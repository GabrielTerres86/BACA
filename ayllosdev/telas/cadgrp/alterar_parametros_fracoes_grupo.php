<?php
/*!
 * FONTE        : alterar_parametros_fracoes_grupo.php
 * CRIAÇÃO      : Jonata (Mouts)
 * DATA CRIAÇÃO : Setembro/2018 
 * OBJETIVO     : Rotina para alterar os parametros da opção P
 * --------------
 * ALTERAÇÕES   : 05/07/2019 - Vincular cooperado a grupo - P484.2 (Gabriel Marcos - Mouts).
 */
?> 

<?php	
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	// Carrega permissões do operador
	require_once('../../includes/carrega_permissoes.php');		
	
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	$frmideal = (isset($_POST["frmideal"])) ? $_POST["frmideal"] : 0;
	$frmmaxim = (isset($_POST["frmmaxim"])) ? $_POST["frmmaxim"] : 0;
	
	$antecedencia_envnot = (isset($_POST["antecedencia_envnot"])) ? $_POST["antecedencia_envnot"] : 0;
	$hrenvio_mensagem = (isset($_POST["hrenvio_mensagem"])) ? $_POST["hrenvio_mensagem"] : 0;
	$dstitulo_banner = (isset($_POST["dstitulo_banner"])) ? $_POST["dstitulo_banner"] : 0;
	$dtexibir_de = (isset($_POST["dtexibir_de"])) ? $_POST["dtexibir_de"] : 0;
	
	$flgemail = (isset($_POST["flgemail"])) ? $_POST["flgemail"] : 0;
	$dstitulo_email = (isset($_POST["dstitulo_email"])) ? $_POST["dstitulo_email"] : 0;
	$lstemail = (isset($_POST["lstemail"])) ? $_POST["lstemail"] : 0;

	// Monta o xml de requisição		
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= " <Dados>";
	
	$xml 	   .= "     <frmmaxim>".$frmmaxim."</frmmaxim>";		
	$xml 	   .= "     <frmideal>".$frmideal."</frmideal>";
	
	$xml 	   .= "     <antecedencia_envnot>".$antecedencia_envnot."</antecedencia_envnot>";		
	$xml 	   .= "     <hrenvio_mensagem>".$hrenvio_mensagem."</hrenvio_mensagem>";
	$xml 	   .= "     <dstitulo_banner>".$dstitulo_banner."</dstitulo_banner>";		
	$xml 	   .= "     <dtexibir_de>".$dtexibir_de."</dtexibir_de>";
	
	$xml 	   .= "     <flgemail>".$flgemail."</flgemail>";
	$xml 	   .= "     <dstitulo_email>".$dstitulo_email."</dstitulo_email>";	
	$xml 	   .= "     <lstemail>".$lstemail."</lstemail>";	
	
	$xml 	   .= " </Dados>";
	$xml 	   .= "</Root>";

	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "TELA_CADGRP", "ALTERAR_PRM_FRACOES_GRP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjParametros = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjParametros->roottag->tags[0]->name) == "ERRO") {
		
		$msgErro = $xmlObjParametros->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo = $xmlObjParametros->roottag->tags[0]->attributes["NMDCAMPO"];
		
		if(empty ($nmdcampo)){ 
			$nmdcampo = "frmideal";
		}
		
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','controlaFormOpcaoP();focaCampoErro(\''.$nmdcampo.'\',\'frmOpcaoP\');',false);		
					
	}
	
	exibirErro('inform','Atualiza&ccedil;&atilde;o efetuada com sucesso.','Alerta - Ayllos','consultaParametrosFracoesGrupo();', false);

	

 ?>
