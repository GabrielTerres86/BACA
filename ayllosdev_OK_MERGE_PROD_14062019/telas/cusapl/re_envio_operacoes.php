<?
//*********************************************************************************************//
//*** Fonte: re_envio_operacoes.php                                    						          ***//
//*** Autor: Rafael B. Arins - Envolti                                           						***//
//*** Data : Abril/2018                  Última Alteração: --/--/----  					            ***//
//***                                                                  						          ***//
//*** Objetivo  : Busca CUSAPL_SOLIC_REENVIO                        						            ***//
//***                                                                  						          ***//
//*** Alterações: 																			                                    ***//
//*********************************************************************************************//

 session_start();
 require_once('../../includes/config.php');
 require_once('../../includes/funcoes.php');
 require_once('../../includes/controla_secao.php');
 require_once('../../class/xmlfile.php');
 isPostMethod();

 // Guardo os parâmetos do POST em variáveis
 $listIds  = (isset($_POST['listids']))  ? $_POST['listids'] : '';

 // Montar o xml de Requisicao
$xmlCarregaDados = "";
$xmlCarregaDados .= "<Root>";
$xmlCarregaDados .= " <Dados>";
$xmlCarregaDados .= " <dsdlista>".$listIds."</dsdlista>";
$xmlCarregaDados .= " </Dados>";
$xmlCarregaDados .= "</Root>";
$xmlResult = mensageria($xmlCarregaDados
 ,"TELA_CUSAPL"
 ,"CUSAPL_SOLIC_REENVIO"
 ,$glbvars["cdcooper"]
 ,$glbvars["cdagenci"]
 ,$glbvars["nrdcaixa"]
 ,$glbvars["idorigem"]
 ,$glbvars["cdoperad"]
 ,"</Root>");
$xmlObject = getObjectXML($xmlResult);


// Em caso de erro
if (strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO') {
  $msgErro = $xmlObject->roottag->tags[0]->cdata;
  if ($msgErro == '') {
    $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
  }
  echo 'showError',$msgErro;
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
 <textarea readonly="readonly" style="width:100%; height:80%;" autofocus>',json_encode($msgAviso),'</textarea><br /><br /><br />
 <a href="#" class="botao" id="btVoltar" name="btVoltar" onClick="fechaModal();buscaLogOperacoes();return false;">Ok</a>
 </div>
 ';
 }
}

?>
