<?php
/*!
 * FONTE        : solicita_process_arq_ret.php                 
 * CRIAÇÃO      : Adriano Marchi
 * DATA CRIAÇÃO : Agosto/2016 
 * OBJETIVO     : Rotina para solicitar o processamento de arquivos de retorno enviado pela CETIP
 * --------------
 * ALTERAÇÕES   : 02/12/2016 - P341-Automatização BACENJUD - Alterar a passagem da descrição do 
 *                             departamento como parametros e passar o o código (Renato Darosci)
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
	
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}
	
	$cdcooper = (isset($_POST["cdcooper"])) ? $_POST["cdcooper"] : 0;
	$tparquiv = (isset($_POST["tparquiv"])) ? $_POST["tparquiv"] : 0;

	validaDados();
	
    // Monta o xml de requisição		
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= "  <Dados>";
	$xml 	   .= "     <cdcoptel>".$cdcooper."</cdcoptel>";
	$xml 	   .= "     <tparquiv>".$tparquiv."</tparquiv>";	
	$xml 	   .= "     <cddopcao>".$cddopcao."</cddopcao>";
	$xml       .= "     <cddepart>".$glbvars["cddepart"]."</cddepart>";
	$xml 	   .= "  </Dados>";
	$xml 	   .= "</Root>";
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "TELA_GRAVAM", "SOLICPROCESSARQRET", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Aimaro','formataFiltroArquivo();',false);		
					
	} 
		
	echo "showError('inform','Solicita&ccedil;&atilde;o efetuada com sucesso.','Notifica&ccedil;&atilde;o - Aimaro','formataFiltroArquivo();');";	
	
	function validaDados(){		
		
		IF($GLOBALS["cdcooper"] == ''){ 
			exibirErro('error','Cooperativa deve ser informada.','Alerta - Aimaro','$(\'input,select\',\'#frmFiltro\').habilitaCampo();focaCampoErro(\'cdcooper\',\'frmFiltro\');',false);
		}
			
		IF($GLOBALS["tparquiv"] != 'TODAS' && $GLOBALS["tparquiv"] != 'INCLUSAO' && $GLOBALS["tparquiv"] != 'BAIXA' && $GLOBALS["tparquiv"] != 'CANCELAMENTO'){ 
			exibirErro('error','Tipo do arquivo deve ser informado.','Alerta - Aimaro','$(\'input,select\',\'#frmFiltro\').habilitaCampo();focaCampoErro(\'tparquiv\',\'frmFiltro\');',false);
		}
		
	}	
  
 ?>
