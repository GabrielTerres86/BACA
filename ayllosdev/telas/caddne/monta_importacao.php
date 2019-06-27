<?php
/**************************************************************************************
	ATENÇÃO: SE ESTA TELA ALGUM DIA FOR LIBERADA PARA A PRODUÇÃO TEM QUE SER ALTERADA
			 PARA O NOVO LAYOUT DO AYLLOS WEB.
			 FALAR COM O GABRIEL OU DANIEL. 19/02/2013.
****************************************************************************************/

	/*************************************************************************
	  Fonte: monta_importacao.php                                               
	  Autor: Jorge Issamu Hamaguchi                                             
	  Data : Dezembro/2011                       Última Alteração: 13/08/2015
	  
	  Objetivo  : Montar importacao de enderecos dos arquivos do correio.          
	  
	  Alterações: 13/08/2015 - Remover o caminho fixo. (James)
	  
	***********************************************************************/
	
	if( !ini_get('safe_mode') ){ 
		set_time_limit(300); 
	} 
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	$listauf  = $_POST["listauf"];
	$dirArqDne = dirname(__FILE__) ."/arquivos/";
	$controle  = "";	
	
	if($listauf == 'NADA'){
		$controle = "OK";
	}else{

		$arrayUF = explode(';', $listauf);
		
	// abre o diretório
	$diretorio = opendir($dirArqDne);
	while (($nome_item = readdir($diretorio)) !== false) {
			foreach ($arrayUF as $uf) {
				if (strpos(strtoupper('_'.$nome_item.'.'),'_'.$uf.'.') !== false) {					
			$controle = "OK";
			$filename = $nome_item;
			$nmarquiv = $dirArqDne.$filename;
			$Arq = $nmarquiv;
			
			//encriptacao e envio do arquivo
			require("../../includes/gnuclient_upload_file.php");			
		}
	}
		}	
	}
	
	if ($controle != "OK") {
		exibeErro("Arquivo de transi&ccedil;&atilde;o do arquivo n&atilde;o encontrado.");
	} else {		
		unlink($Arq);			 	
		
		if($listauf != 'NADA'){

			$flg_unid_oper = in_array('UNID_OPER', $arrayUF) ? 1 : 0;
			$flg_grande_usuario = in_array('CPC', $arrayUF) ? 1 : 0;
			$flg_cpc = in_array('GRANDE_USUARIO', $arrayUF) ? 1 : 0;

			if (($key = array_search('UNID_OPER', $arrayUF)) !== false) {
		    	unset($arrayUF[$key]);
			}

			if (($key = array_search('CPC', $arrayUF)) !== false) {
		    	unset($arrayUF[$key]);
			}

			if (($key = array_search('GRANDE_USUARIO', $arrayUF)) !== false) {
		    	unset($arrayUF[$key]);
			}

			$listauf = implode(';', $arrayUF);

		}
		
		$xml = new XmlMensageria();
		$xml->add('proc_arq_unid_oper',$flg_unid_oper);
    	$xml->add('proc_arq_grande_usuario',$flg_grande_usuario);
    	$xml->add('proc_arq_cpc',$flg_cpc);
    	$xml->add('proc_arq_sigla_estado',$listauf);

		$xmlResult = mensageria($xml, "TELA_CADDNE", 'EXECUTA_CARGA', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObj = simplexml_load_string($xmlResult);

		if(!is_null($xmlObj->Erro->Registro)){
			if ($xmlObj->Erro->Registro->dscritic != '') {
				$msgErro = utf8ToHtml($xmlObj->Erro->Registro->dscritic);
				exibeErro($msgErro);
			}
		}

		echo 'showError("inform","Importação agendada com sucesso!","Alerta - Ayllos","hideMsgAguardo()");';
	}
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 		
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","hideMsgAguardo()");';
		exit();
	}
	
?>