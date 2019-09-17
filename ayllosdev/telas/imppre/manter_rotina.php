<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Lucas Lombardi
 * DATA CRIAÇÃO : 20/07/2016
 * OBJETIVO     : Rotina para alteração cadastral da tela IMPPRE
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
	
	
	$cddopcao 		= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
	
	$descricao      = (isset($_POST['descricao'])) 		? $_POST['descricao'] 	   : '';
	$final_vigencia = (isset($_POST['final_vigencia'])) ? $_POST['final_vigencia'] : '';
	$indeterminada  = (isset($_POST['indeterminada']))  ? $_POST['indeterminada']  :  0;
	$mensagem       = (isset($_POST['mensagem'])) 		? $_POST['mensagem'] 	   : '';
	$nome_arquivo   = (isset($_POST['nome_arquivo'])) 	? $_POST['nome_arquivo']   : '';
	$iddcarga		= (isset($_POST['iddcarga'])) 		? $_POST['iddcarga']   	   :  0;
	
	// Carrega permissões do operador
	require_once('../../includes/carrega_permissoes.php');
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	switch ($cddopcao) {
		case 'I': 
		case 'A': 
			// Monta o xml de requisicao
			$xml  = "";
			$xml .= "<Root>";
			$xml .= " <Dados>";
			$xml .= "   <descricao>"      .utf8_decode($descricao)    ."</descricao>";
			$xml .= "   <final_vigencia>" .$final_vigencia			  ."</final_vigencia>";
			$xml .= "   <indeterminado>"  .$indeterminada  			  ."</indeterminado>";
			$xml .= "   <mensagem>"       .utf8_decode($mensagem)     ."</mensagem>";
			$xml .= "   <nome_arquivo>"   .utf8_decode($nome_arquivo) ."</nome_arquivo>";
			$xml .= "   <iddcarga>"		  .$iddcarga	   			  ."</iddcarga>";
			$xml .= " </Dados>";
			$xml .= "</Root>";

			$xmlResult = mensageria($xml, "TELA_IMPPRE", "IMPPRE_INCLUI", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
			$xmlObjeto = getObjectXML($xmlResult);
			
			if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
				$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
				if ($msgErro == "") {
					$msgErro = $xmlObjeto->roottag->tags[0]->cdata;
				}
				exibirErro('error',htmlentities($msgErro),'Alerta - Ayllos',"",false);
			}
			$dados = $xmlObjeto->roottag->tags[0]->cdata;
			echo "showError(\"inform\",\"".htmlentities($dados)."\",\"Alerta - Ayllos\",\"\");";
			if ($cddopcao == 'A') 
				echo "acessa_rotina();";
			else
				echo "estadoInicial();";
			break;
		case 'B':
		case 'L':
		case 'E': 
			// Monta o xml de requisicao
			$xml  = "";
			$xml .= "<Root>";
			$xml .= " <Dados>";
			$xml .= "   <cddopcao>".$cddopcao."</cddopcao>";
			$xml .= "   <iddcarga>".$iddcarga."</iddcarga>";
			$xml .= " </Dados>";
			$xml .= "</Root>";

			$xmlResult = mensageria($xml, "TELA_IMPPRE", "IMPPRE_MANTEM", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
			$xmlObjeto = getObjectXML($xmlResult);
			
			if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
				$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
				if ($msgErro == "") {
					$msgErro = $xmlObjeto->roottag->tags[0]->cdata;
				}
				exibirErro('error',htmlentities($msgErro),'Alerta - Ayllos',"",false);
			}
			$dados = $xmlObjeto->roottag->tags[0]->cdata;
			echo "showError(\"inform\",\"".htmlentities($dados)."\",\"Alerta - Ayllos\",\"\");";
		
			echo "acessaManterCarga(1,20);";
			break;
	}
?>