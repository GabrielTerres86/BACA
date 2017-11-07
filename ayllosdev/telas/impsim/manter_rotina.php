<?
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Diogo Carlassara
 * DATA CRIAÇÃO : 14/09/2017
 * OBJETIVO     : Rotina para alteração cadastral da tela IMPSIM
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
	$nome_arquivo   = (isset($_POST['nome_arquivo'])) 	? $_POST['nome_arquivo']   : '';

	// Carrega permissões do operador
	require_once('../../includes/carrega_permissoes.php');

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	switch ($cddopcao) {
		case 'I':
			// Monta o xml de requisicao
			$xml  = "";
			$xml .= "<Root>";
			$xml .= " <Dados>";
			$xml .= "   <nome_arquivo>"   .utf8_decode($nome_arquivo) ."</nome_arquivo>";
			$xml .= "   <iddcarga>"		  .$iddcarga	   			  ."</iddcarga>";
			$xml .= " </Dados>";
			$xml .= "</Root>";

			$xmlResult = mensageria($xml, "TELA_IMPSIM", "IMPSIM_IMPORTA_ARQUIVO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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
            echo "estadoInicial();";
			break;

		case 'E':
			// Monta o xml de requisicao
			$xml  = "";
			$xml .= "<Root>";
			$xml .= " <Dados>";
            $xml .= "   <pr_arquivo></pr_arquivo>";
			$xml .= " </Dados>";
			$xml .= "</Root>";

			$xmlResult = mensageria($xml, "TELA_IMPSIM", "IMPSIM_EXPORTA_ARQUIVO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
			$xmlObjeto = getObjectXML($xmlResult);

			if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
				$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
				if ($msgErro == "") {
					$msgErro = $xmlObjeto->roottag->tags[0]->cdata;
				}
				exibirErro('error',htmlentities($msgErro),'Alerta - Ayllos',"",false);
			}
			//$dados = $xmlObjeto->roottag->tags[0]->cdata;

            ob_start();
            visualizaArquivo("exportacao-simples-nacional.csv","csv");
            $conteudo = ob_get_contents();
            ob_end_clean();

            if (stripos($conteudo, 'alert(') === FALSE){
                $conteudo = 'data:text/csv;base64,'.base64_encode($conteudo);
            }

            echo $conteudo;
            break;

        default:
            echo "Opcao invalida!";
	}
?>