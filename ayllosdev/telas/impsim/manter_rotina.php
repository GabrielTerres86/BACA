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
            $nomeArquivo = (isset($_POST['nome_arquivo'])) ? $_POST['nome_arquivo'] : '';

            $xml  = "<Root>";
            $xml .= "	<Dados>";
            $xml .= "		<arquivo>".$nomeArquivo."</arquivo>";
            $xml .= "	</Dados>";
            $xml .= "</Root>";

            $tempoExecucaoAtual = ini_get('max_execution_time');
            ini_set('max_execution_time', 0);

            $xmlResult = mensageria($xml, "IMPSIM", "IMPSIM_IMPORTA_ARQUIVO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
            $xmlObj = getObjectXML($xmlResult);
            ini_set('max_execution_time', $tempoExecucaoAtual);

            if (isset($xmlObj->roottag->tags[0]->name) && strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO"){
                $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;

                if ($msgErro == "") {
                    $msgErro = $xmlObj->roottag->tags[0]->cdata;
                }
                exibirErro('error',htmlentities($msgErro),'Alerta - Ayllos','estadoInicial();', false);
            }
            else{
                exibirErro("inform","Opera&ccedil;&atilde;o executada com sucesso!","Alerta - Ayllos","estadoInicial();", false);
            }
			break;

		case 'E':
			// Monta o xml de requisicao
            $xml  = "<Root>";
            $xml .= "	<Dados>";
            $xml .= "		<arquivo>exportacao-simples-nacional.csv</arquivo>";
            $xml .= "	</Dados>";
            $xml .= "</Root>";

			$xmlResult = mensageria($xml, "IMPSIM", "IMPSIM_EXPORTA_ARQUIVO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
			$xmlObjeto = getObjectXML($xmlResult);

			if (isset($xmlObj->roottag->tags[0]->name) && strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO")  {
				$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
				if ($msgErro == "") {
					$msgErro = $xmlObjeto->roottag->tags[0]->cdata;
				}
				exibirErro('error',htmlentities($msgErro),'Alerta - Ayllos',"",false);
			}

            exibirErro('inform',"Arquivo gerado com sucesso!",'Alerta - Ayllos',"",false);
            break;

        default:
            exibirErro('error',"Op&ccedil;&atilde;o inv&aacute;lida!",'Alerta - Ayllos','estadoInicial();', false);
	}
?>