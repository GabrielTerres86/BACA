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
            /*
                Funcionamento da importação:
                    - PHP envia arquivo para ayllos/upload_files
                    - Oracle lê este arquivo e joga para /microsd/coop/upload
                    - Oracle processa o arquivo
            */
            $arquivo  = (isset($_FILES['nome_arquivo']))  ? $_FILES['nome_arquivo']   : ''  ;
            //Diretório de upload do arquivo no WWW
            $nmupload = "../../upload_files/";
            //Código da cooperativa - só para CECRED
            $nomeArquivo = '003.0.';

            if (!$arquivo){
                showErrorsImportacao('error','Arquivo não informado!');
            }

            //Move arquivo para servidor WWW
            
            //$nomeArquivo .= $arquivo["name"];
            $nomeArquivo .= 'importacao_impsim_'.date('Y-m-d').'.csv';
            if (!move_uploaded_file($arquivo["tmp_name"], $nmupload.$nomeArquivo)) {
                showErrorsImportacao('error','Arquivo "'.$nomeArquivo.'" não pode ser enviado! '.getcwd());
            }

            // Caminho que deve ser enviado ao Mensageria / para ORACLE fazer exec do CURL
            $caminhoCompleto = $_SERVER['SERVER_NAME'].'/upload_files/';

			// Monta o xml de requisicao
            $xml  = "<Root>";
            $xml .= "	<Dados>";
            $xml .= "		<dsarquivo>".$nomeArquivo."</dsarquivo>";
            $xml .= "       <dsdireto>".$caminhoCompleto."</dsdireto>";
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
                showErrorsImportacao('error', htmlentities($msgErro), 'estadoInicial();');
            }
            else{
                showErrorsImportacao("inform", "Opera&ccedil;&atilde;o executada com sucesso!", "estadoInicial();");
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

			if (isset($xmlObjeto->roottag->tags[0]->name) && strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO")  {
				$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
				if ($msgErro == "") {
					$msgErro = $xmlObjeto->roottag->tags[0]->cdata;
				}
				exibirErro('error',htmlentities($msgErro),'Alerta - Ayllos',"",false);
			}

            $dirArquivo = ($_SERVER['HTTPS'] ? 'https://' : 'http://').$_SERVER['SERVER_NAME'].'/upload_files/'.$xmlObjeto->roottag->tags[0]->cdata;
            exibirErro('inform',"Arquivo gerado com sucesso!",'Alerta - Ayllos',"forceDownload('".$dirArquivo."')",false);
            break;

        default:
            exibirErro('error',"Op&ccedil;&atilde;o inv&aacute;lida!",'Alerta - Ayllos','estadoInicial();', false);
	}

    function showErrorsImportacao($tipo, $mensagem, $callback){
        echo "<script>parent.framePrincipal.hideMsgAguardo();parent.framePrincipal.showError('".$tipo."','".$mensagem."','Alerta - Ayllos','".$callback."', true);</script>";
        exit();  
    }    
?>