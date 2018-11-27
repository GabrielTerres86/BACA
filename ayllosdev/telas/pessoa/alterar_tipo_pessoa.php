<?php
/*!
 * FONTE        : alterar_tipo_pessoa.php                    Última alteração:  
 * CRIAÇÃO      : Jonata (Mouts)
 * DATA CRIAÇÃO : Setembro/2018
 * OBJETIVO     : Rotina para alterar o tipo de pessoa - PESSOA
 * --------------
 * ALTERAÇÕES   :  
 *
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

	$inpessoa = (isset($_POST["inpessoa"])) ? $_POST["inpessoa"] : 0;
	$nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : 0;
	
	validaDados();
  
	$xmlAlterar  = "";
	$xmlAlterar .= "<Root>";
	$xmlAlterar .= "   <Dados>";
	$xmlAlterar .= "	   <inpessoa>".$inpessoa."</inpessoa>";
	$xmlAlterar .= "	   <nrdconta>".$nrdconta."</nrdconta>";
	$xmlAlterar .= "   </Dados>";
	$xmlAlterar .= "</Root>";
		
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlAlterar, "TELA_PESSOA", "ALTERAR_TP_PESSOA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObjAlterar = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjAlterar->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro  = $xmlObjAlterar->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo = $xmlObjAlterar->roottag->tags[0]->attributes["NMDCAMPO"];	
		
		if(empty ($nmdcampo)){ 
			$nmdcampo = "inpessoa";
		}
				 
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','$(\'input, select\',\'#frmTipoPessoa\').removeClass(\'campoErro\');focaCampoErro(\''.$nmdcampo.'\',\'frmTipoPessoa\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);		
							
	}    

	exibirErro('inform','Altera&ccedil;&atilde;o efetuada com sucesso.','Alerta - Ayllos','fechaRotina($(\'#divRotina\'));buscarCooperado(\'1\',\'30\');',false);		
	
		
    function validaDados(){
		
		//Código da cooperativa selecionado
        if (  $GLOBALS["inpessoa"] == 0 ){
            exibirErro('error','Tipo de pessoa inv&aacute;lido.','Alerta - Ayllos','$(\'input, select\',\'#frmTipoPessoa\').removeClass(\'campoErro\');focaCampoErro(\'inpessoa\',\'frmTipoPessoa\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
        }
		
		//Número da conta
        if (  $GLOBALS["nrdconta"] == 0 ){
            exibirErro('error','Conta inv&aacute;lida.','Alerta - Ayllos','$(\'input, select\',\'#frmTipoPessoa\').removeClass(\'campoErro\');focaCampoErro(\'inpessoa\',\'frmTipoPessoa\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
        }
		
	}

 ?>
