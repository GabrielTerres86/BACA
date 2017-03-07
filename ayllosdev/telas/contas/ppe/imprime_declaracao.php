<?php 
 	
	//******************************************************************************************//
	//*** Fonte: imprime_declaracao.php                                            			 ***//
	//*** Autor: Carlos Henrique                                              				 ***//
	//*** Data : Dezembro/2015             Última Alteração: 21/02/2017 				     ***//
	//***                                                                   				 ***//
	//*** Objetivo  : Imprimir declaracao de pessoa exposta politicamente.     				 ***//	
	//***             							                               				 ***//	 
	//*** Alterações: 21/02/2017 - Ajuste para enviar campos sem formatação                  ***//
	//***                          (Adriano - SD 614408).                               	 ***//	
	//***             			   										     				 ***//
	//***                          									         				 ***//
	//******************************************************************************************//
	
	session_cache_limiter("private");
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");		
	
	$tpexposto        = (isset($_POST['tpexposto'])) ?        $_POST['tpexposto']        : '';
	$cdocpttl         = (isset($_POST['cdocpttl'])) ?         $_POST['cdocpttl']         : '';	
	$cdrelacionamento = (isset($_POST['cdrelacionamento'])) ? $_POST['cdrelacionamento'] : '';
	$dtinicio         = (isset($_POST['dtinicio'])) ?         $_POST['dtinicio']         : '';
	$dttermino        = (isset($_POST['dttermino'])) ?        $_POST['dttermino']        : '';
	$nmempresa        = (isset($_POST['nmempresa'])) ?        $_POST['nmempresa']        : '';
	$nrcnpj_empresa   = (isset($_POST['nrcnpj_empresa'])) ?   $_POST['nrcnpj_empresa']   : '';
	$nmpolitico       = (isset($_POST['nmpolitico'])) ?       $_POST['nmpolitico']       : '';
	$nrcpf_politico   = (isset($_POST['nrcpf_politico'])) ?   $_POST['nrcpf_politico']   : '';
	$nmextttl         = (isset($_POST['nmextttl'])) ?         $_POST['nmextttl']         : '';
	$rsdocupa         = (isset($_POST['rsocupa'])) ?          $_POST['rsocupa']          : '';
	$nrcpfcgc         = (isset($_POST['nrcpfcgc'])) ?         $_POST['nrcpfcgc']         : '';
	$dsrelacionamento = (isset($_POST['dsrelacionamento'])) ? $_POST['dsrelacionamento'] : '';
	$inpolexp         = (isset($_POST['inpolexp'])) ?         $_POST['inpolexp']         : '';
	
	$nrdconta         = (isset($_POST['nrdconta'])) ?         $_POST['nrdconta'] : '';
	$cidade           = (isset($_POST['cidade'])) ?           $_POST['cidade'] : '';
	
	if ($inpolexp == 0) { 
		$tpexposto = 0; 
	}
	
	$arrayRetirada = array('.','-','/');                                                        
	$nrcnpj_empresa = str_replace($arrayRetirada,'',$nrcnpj_empresa);
	$nrcpf_politico = str_replace($arrayRetirada,'',$nrcpf_politico);
	$nrcpfcgc = str_replace($arrayRetirada,'',$nrcpfcgc);

	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "  <tpexposto>"        .$tpexposto                                           ."</tpexposto>";
	$xml .= "  <cdocpttl>"         .$cdocpttl                                            ."</cdocpttl>";
	$xml .= "  <cdrelacionamento>" .$cdrelacionamento                                    ."</cdrelacionamento>";
	$xml .= "  <dtinicio>"         .$dtinicio                                            ."</dtinicio>";
	$xml .= "  <dttermino>"        .$dttermino                                           ."</dttermino>";	
	$xml .= "  <nmempresa>"        .retiraAcentos(removeCaracteresInvalidos($nmempresa)) ."</nmempresa>";
	$xml .= "  <nrcnpj_empresa>"   .$nrcnpj_empresa                                      ."</nrcnpj_empresa>";
	$xml .= "  <nmpolitico>"       .retiraAcentos(removeCaracteresInvalidos($nmpolitico))."</nmpolitico>";
	$xml .= "  <nrcpf_politico>"   .$nrcpf_politico                                      ."</nrcpf_politico>";
	$xml .= "  <nmextttl>"         .$nmextttl                                            ."</nmextttl>";
	$xml .= "  <rsocupa>"          .$rsdocupa                                            ."</rsocupa>";
	$xml .= "  <nrcpfcgc>"         .$nrcpfcgc                                            ."</nrcpfcgc>";
	$xml .= "  <dsrelacionamento>" .$dsrelacionamento                                    ."</dsrelacionamento>";
	$xml .= "  <nrdconta>"         .formataContaDVsimples($nrdconta)                     ."</nrdconta>";
	$xml .= "  <cidade>"           .$cidade                                              ."</cidade>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	//pr_tpexposto,pr_cdocpttl,pr_cdrelacionamento,pr_dtinicio,pr_dttermino,pr_nmempresa,pr_nrcnpj_empresa,
	//pr_nmpolitico,pr_nrcpf_politico,pr_nmextttl,pr_rsocupa,pr_nrcpfcgc,pr_dsrelacionamento
	//								    crapaca (craprdr seq 242)
	$xmlResult = mensageria($xml, $glbvars["nmdatela"], "IMP_DEC_PEP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);

	if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		if ($msgErro == null || $msgErro == '') {
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}?>
		<script language="javascript">alert('<?php echo $msgErro; ?>');</script><?			
		exit();
	}	

	//Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
	$nmarqpdf = $xmlObj->roottag->cdata;

	//Chama função para mostrar PDF do impresso gerado no browser	 
	visualizaPDF($nmarqpdf);
?>