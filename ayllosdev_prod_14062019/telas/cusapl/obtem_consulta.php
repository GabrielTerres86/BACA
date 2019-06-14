<?php
//*********************************************************************************************//
//*** Fonte: obtem_consulta   .php                                    						          ***//
//*** Autor: Rafael B. Arins - Envolti                                           						***//
//*** Data : Abril/2018                  Última Alteração: --/--/----  					            ***//
//***                                                                  						          ***//
//*** Objetivo  : Busca Informações da tela CUSAPL                   						            ***//
//***                                                                  						          ***//
//*** Alterações: 																			                                    ***//
//*********************************************************************************************//

	session_start();
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");
	require_once("../../class/xmlfile.php");
  isPostMethod();

			$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
			$cdcooper = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : '';

		if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
			exibirErro('error',$msgError,'Alerta - Ayllos','',false);
		}

	if ($cddopcao == 'G') {
				//'G – Configuração Geral da Custódia de Aplicações
        // Montar o xml de Requisicao
        $xml  = "";
        $xml .= "<Root>";
        $xml .= " <Dados/>";
        $xml .= "</Root>";

        // Requisicao dos dados de parametrizacao da conta sysphera
				$xmlResult = mensageria($xml
					,"TELA_CUSAPL"
					,"CUSAPL_BUSCA_PARAMS"
					,$glbvars["cdcooper"]
					,$glbvars["cdagenci"]
					,$glbvars["nrdcaixa"]
					,$glbvars["idorigem"]
					,$glbvars["cdoperad"], "</Root>");
				$xmlObject = getObjectXML($xmlResult);

				if ( strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO' ) {
						exibirErro('error',$xmlObject->roottag->tags[0]->cdata,'Alerta - Ayllos','',false);
				}

        $xmlRegist = $xmlObject->roottag->tags[0];

        include('form_g.php');

    } else if ($cddopcao == 'E') {
				//E - Solicitar Envio dos Arquivos Pendentes
				// Montar o xml de Requisicao
				$xmlCarregaDados = "";
				$xmlCarregaDados .= "<Root>";
				$xmlCarregaDados .= " <Dados/>";
				$xmlCarregaDados .= "</Root>";

				$xmlResult = mensageria($xmlCarregaDados
					,"TELA_CUSAPL"
					,"CUSAPL_EXEC_ENVIO"
					,$glbvars["cdcooper"]
					,$glbvars["cdagenci"]
					,$glbvars["nrdcaixa"]
					,$glbvars["idorigem"]
					,$glbvars["cdoperad"]
					,"</Root>");
				$xmlObject = getObjectXML($xmlResult);

				//echo 'hideMsgAguardo();';

				// Em caso de erro
				if (strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO') {

					$msgErro = $xmlObject->roottag->tags[0]->cdata;

					if ($msgErro == '') {
						$msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
					}
					exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
				} else {
						// Se houver aviso
					if (strtoupper($xmlObject->roottag->tags[0]->name) == "AVISO") {
						$msgAviso = $xmlObject->roottag->tags[0]->cdata;

						echo '
					  <style>
					  	.corpo{height:24em; background-color: #f4f3f0;    text-align: center; padding:1em;}
					  </style>
					  <div class="txtBrancoBold ponteiroDrag" style="padding: 0.5em 0.5em 1.0em 0.5em;text-transform: uppercase;background-color: #6f7a86;">
					  	<span class="tituloJanelaPesquisa"><b>Retorno da Execu&ccedil;&atilde;o</b></span>
					  	<a href="#" class="botao" style="position:absolute; right: 0;" onClick="fechaModal();buscaLogOperacoes();return false;"><b>X</b></a>
					  </div>

					  <div class="tableLogsDeArquivo corpo">
					  <textarea readonly="readonly" style="width:100%; height:80%;" autofocus>',$msgAviso,'</textarea><br /><br /><br />
					  <a href="#" class="botao" id="btVoltar" name="btVoltar" onClick="fechaModal();buscaLogOperacoes();return false;">Ok</a>
					  </div>';

						//exibirErro('error', $msgAviso,'Alerta - Ayllos','',false);
					}
				}

				$xmlRegist = $xmlObject->roottag->tags[0];

    } else if ($cddopcao == 'R') {
			//R - Solicitar Retorno dos Arquivos Pendentes
			// Montar o xml de Requisicao
			$xmlCarregaDados = "";
			$xmlCarregaDados .= "<Root>";
			$xmlCarregaDados .= " <Dados/>";
			$xmlCarregaDados .= "</Root>";

			$xmlResult = mensageria($xmlCarregaDados
				,"TELA_CUSAPL"
				,"CUSAPL_EXEC_RETORNO"
				,$glbvars["cdcooper"]
				,$glbvars["cdagenci"]
				,$glbvars["nrdcaixa"]
				,$glbvars["idorigem"]
				,$glbvars["cdoperad"]
				,"</Root>");

			$xmlObject = getObjectXML($xmlResult);

			//echo 'hideMsgAguardo();';

			// Em caso de erro
			if (strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO') {
				$msgErro = $xmlObject->roottag->tags[0]->cdata;
				if ($msgErro == '') {
					$msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
				}

				exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
			} else {
				// Se houver aviso
				if (strtoupper($xmlObject->roottag->tags[0]->name) == "AVISO") {
					$msgAviso = $xmlObject->roottag->tags[0]->cdata;

					echo '
				  <style>
				  	.corpo{height:24em; background-color: #f4f3f0;    text-align: center; padding:1em;}
				  </style>
				  <div class="txtBrancoBold ponteiroDrag" style="padding: 0.5em 0.5em 1.0em 0.5em;text-transform: uppercase;background-color: #6f7a86;">
				  	<span class="tituloJanelaPesquisa"><b>Retorno da Execu&ccedil;&atilde;o</b></span>
				  	<a href="#" class="botao" style="position:absolute; right: 0;" onClick="fechaModal();buscaLogOperacoes();return false;"><b>X</b></a>
				  </div>

				  <div class="tableLogsDeArquivo corpo">
				  <textarea readonly="readonly" style="width:100%; height:80%;" autofocus>',$msgAviso,'</textarea><br /><br /><br />
				  <a href="#" class="botao" id="btVoltar" name="btVoltar" onClick="fechaModal();buscaLogOperacoes();return false;">Ok</a>
				  </div>';

					//exibirErro('error', $msgAviso, 'Alerta - Ayllos','',false);
				}
			}
    } else if ($cddopcao == 'A') {

			//A - Log dos Arquivos de Custódia
      include('form_a.php');

		} else if ($cddopcao == 'O') {
			//O - Log das Operações de Custódia Pendentes
			include('form_o.php');
		}  else if ($cddopcao == 'C') {
			// Montar o xml de Requisicao
			$xml  = "";
			$xml .= "<Root>";
			$xml .= " <Dados>";
			$xml .= " <tlcdcooper>".$cdcooper."</tlcdcooper>";
			$xml .= " </Dados>";
			$xml .= "</Root>";

			// Requisicao dos dados de parametrizacao da conta sysphera
			$xmlResult = mensageria($xml
				,"TELA_CUSAPL"
				,"CUSAPL_BUSCA_PARAMS_COOP"
				,$glbvars["cdcooper"]
				,$glbvars["cdagenci"]
				,$glbvars["nrdcaixa"]
				,$glbvars["idorigem"]
				,$glbvars["cdoperad"]
				,"</Root>");

			$xmlObject = getObjectXML($xmlResult);

			$xmlRegist = $xmlObject->roottag->tags[0];

			if ( strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO' ) {
					exibirErro('error',$xmlObject->roottag->tags[0]->cdata,'Alerta - Ayllos','',false);
			}

			$xmlRegist = $xmlObject->roottag->tags[0];

			include('form_c.php');
		}
?>
