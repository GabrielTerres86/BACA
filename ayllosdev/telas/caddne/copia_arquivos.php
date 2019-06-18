<?php
/**************************************************************************************
	ATENÇÃO: SE ESTA TELA ALGUM DIA FOR LIBERADA PARA A PRODUÇÃO TEM QUE SER ALTERADA
			 PARA O NOVO LAYOUT DO AYLLOS WEB.
			 FALAR COM O GABRIEL OU DANIEL. 19/02/2013.
****************************************************************************************/

	/*************************************************************************
	  Fonte: grava_endereco.php                                               
	  Autor: Henrique                                                  
	  Data : Agosto/2011                       Última Alteração: 08/05/2019
	                                                                   
	  Objetivo  : Gravar os dados da tela CADDNE.              
	                                                                 
	  Alterações: 13/08/2015 - Remover o caminho fixo. (James)	  

	              08/05/2019 - Alterado a forma de como busca as siglas dos estados
	                           no nome do arquivo (Mateus Z - Mouts)									   			  
	                                                                  
	***********************************************************************/

	session_start();
	
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'T')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Apaga os arquivos que estao na pasta
	array_map("unlink",glob("/var/www/ayllos/telas/caddne/arquivos/*"));
		
	$xmlCarregaDados  = "";
	$xmlCarregaDados .= "<Root>";
	$xmlCarregaDados .= " <Cabecalho>";
	$xmlCarregaDados .= "    <Bo>b1wgen0038.p</Bo>";
	$xmlCarregaDados .= "    <Proc>copia_arquivos_correios</Proc>";
	$xmlCarregaDados .= " </Cabecalho>";
	$xmlCarregaDados .= " <Dados>";
	$xmlCarregaDados .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlCarregaDados .= "    <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlCarregaDados .= "    <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlCarregaDados .= "    <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlCarregaDados .= " </Dados>";
	$xmlCarregaDados .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlCarregaDados);
	
	$xmlObjCarregaDados = getObjectXML($xmlResult);
	
	// Esconder a mensagem que carrega contratos 
	echo 'hideMsgAguardo();';
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjCarregaDados->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjCarregaDados->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 	
	
	$dados = $xmlObjCarregaDados->roottag->tags[0];
	
	foreach ($dados->tags as $arquivos) {
	    
		if ($arquivos->tags[0]->cdata == "LOG_BAIRRO.TXT" ||
		    $arquivos->tags[0]->cdata == "LOG_LOCALIDADE.TXT") {
				continue;
		}
		
		if($arquivos->tags[0]->cdata == "LOG_UNID_OPER.TXT"){
			echo '$("#UNID_OPER","#frmImportacao").prop("checked",true);';
			echo '$("#UNID_OPER","#frmImportacao").prop("disabled",false);';
		} elseif ($arquivos->tags[0]->cdata == "LOG_CPC.TXT"){
			echo '$("#CPC","#frmImportacao").prop("checked",true);';
			echo '$("#CPC","#frmImportacao").prop("disabled",false);';
		} elseif ($arquivos->tags[0]->cdata == "LOG_GRANDE_USUARIO.TXT"){
			echo '$("#GRANDE_USUARIO","#frmImportacao").prop("checked",true);';
			echo '$("#GRANDE_USUARIO","#frmImportacao").prop("disabled",false);';
		} else {
		
			$arrayEstados = array( "AC", "AL", "AM", "AP", "BA", "CE", "DF", "ES", "GO", "MA", "MT", "MS", "MG", "PA", "PB", "PR", "PE", "PI", "RJ", "RN", "RO", "RS", "RR", "SC", "SE", "SP", "TO" );

			$startIndex = min(strrpos($arquivos->tags[0]->cdata,"_"), strrpos($arquivos->tags[0]->cdata,"."));
			$length = abs(strrpos($arquivos->tags[0]->cdata,"_") - strrpos($arquivos->tags[0]->cdata,"."));

			$entrada = substr($arquivos->tags[0]->cdata, $startIndex + 1, $length - 1);
			
			if(in_array($entrada, $arrayEstados)){
			echo '$("#'.$entrada.'","#frmImportacao").prop("checked",true);';
			echo '$("#'.$entrada.'","#frmImportacao").prop("disabled",false);';
			$estados .= $entrada.",";
			}
		}
	}
	echo '$("#estados","#frmImportacao").val("'.$estados.'");';
	
	?>
	showMsgAguardo("Aguarde, verificando arquivo de bairros ...");
	setTimeout(function(){ limpa_acentos("LOG_BAIRRO.TXT","showMsgAguardo('Aguarde, verificando arquivo de cidades ...');setTimeout(function(){ limpa_acentos('LOG_LOCALIDADE.TXT','hideMsgAguardo();'); },100);"); },100);
	<?php
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","");';
		exit();
	}
	
?>