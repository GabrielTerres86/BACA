<?php
/*!
 * FONTE        : bloqueia_libera_linha.php                    Última alteração: 
 * CRIAÇÃO      : Andrei (RKAM)
 * DATA CRIAÇÃO : Julho/2016 
 * OBJETIVO     : Rotina para bloquear/liberar uma linha de crédito
 * --------------
 * ALTERAÇÕES   :  
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
  
  $cdlcremp = (isset($_POST["cdlcremp"])) ? $_POST["cdlcremp"] : 0;

  validaDados();
  
  // Monta o xml de requisição		
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= "  <Dados>";
	$xml 	   .= "     <cdlcremp>".$cdlcremp."</cdlcremp>";
	$xml 	   .= "     <cddopcao>".$cddopcao."</cddopcao>";
	$xml 	   .= "  </Dados>";
	$xml 	   .= "</Root>";
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "TELA_LCREDI", "BLQLIBLINHA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'#btVoltar\',\'#divBotoesConsulta\').focus();',false);		
					
	}else {
     $operacao = ($cddopcao == 'B') ? 'bloqueada' : 'liberada';
     exibirErro('inform','Linha de cr&eacute;dito '.$operacao.' com sucesso.','Alerta - Ayllos','$(\'#btVoltar\',\'#divBotoesConsulta\').click();', false);      
  }
		
		
	function validaDados(){
			
		IF($GLOBALS["cdlcremp"] == 0 ){ 
			exibirErro('error','Linha de cr&eacute;dito inv&aacute;lida.','Alerta - Ayllos','$(\'#btVoltar\',\'#divBotoesConsulta\').focus();',false);
		}
   
				
	}	
  
 ?>
