<?php
/*!
 * FONTE        : processa_arquivo_retorno.php                14/07/2016
 * CRIAÇÃO      : Andrei (RKAM)
 * DATA CRIAÇÃO : Maio/2016 
 * OBJETIVO     : Rotina para processar arquivos de retorno
 * --------------
 * ALTERAÇÕES   : 14/07/2016-  Ajsute para corrigir a mensagem de retorno do processamento com sucesso
                               (Andrei - RKAM).
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
	$xml     .=	"     <dsdepart>".$glbvars["dsdepart"]."</dsdepart>";
	$xml 	   .= "  </Dados>";
	$xml 	   .= "</Root>";
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "TELA_GRAVAM", "PROCESSAARQRET", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos','formataFiltroArquivo();',false);		
					
	} 
		
	echo "showError('inform','Arquivo(s) de retorno foram integrado(s).','Notifica&ccedil;&atilde;o - Ayllos','formataFiltroArquivo();');";	
	
	function validaDados(){		
		
		IF($GLOBALS["cdcooper"] == ''){ 
			exibirErro('error','Cooperativa deve ser informada.','Alerta - Ayllos','$(\'input,select\',\'#frmFiltro\').habilitaCampo();focaCampoErro(\'cdcooper\',\'frmFiltro\');',false);
		}
			
		IF($GLOBALS["tparquiv"] != 'TODAS' && $GLOBALS["tparquiv"] != 'INCLUSAO' && $GLOBALS["tparquiv"] != 'BAIXA' && $GLOBALS["tparquiv"] != 'CANCELAMENTO'){ 
			exibirErro('error','Tipo do arquivo deve ser informado.','Alerta - Ayllos','$(\'input,select\',\'#frmFiltro\').habilitaCampo();focaCampoErro(\'tparquiv\',\'frmFiltro\');',false);
		}
		
	}	
  
 ?>
