<?php 

	#---------------------------------------------------------------------------------------#
	#-- Script: tempo_requisicao_atenda.php                                               --#
	#-- Autor : David - TI/Cecred                                                         --#
	#-- Data  : Fevereiro/2014                               Última Alteração: 03/03/2015 --#
	#--                                                                                   --#
	#-- Objetivo: Efetuar requisição de carregamento de conta da tela ATENDA para validar --#	
	#--           o tempo de execução.                                                    --#
	#--                                                                                   --#
	#-- Alterações: 03/03/2015 - Utilizar parâmetro para receber o nome do server onde    --#
	#--                          será feita a requisição (David).                         --#
	#--                                                                                   --#
	#--             07/07/2016 - Correcao no garregamento da variavel server que eh       --#  
	#--                          opcional e remocao do comando que destroi a sessao       --#
	#--                          antes de inicializa-la.SD 479274. (Carlos R.)            --#      
	#--                                                                                   --#
	#--             29/11/2016 - P341-Automatização BACENJUD - Popular a variável global  --#
	#--							 cddepart com o código 20 que é equivalente ao            --#
	#--                          departamento fixado na global dsdepart (Renato Darosci)  --#
	#---------------------------------------------------------------------------------------#
	
	session_destroy();
	session_start();
	
	require_once("../includes/config.php");	
	
	$ServerMonitoracao = ( isset($_GET['server']) ) ? trim($_GET['server']) : '';
	
	// Criar SID de login para armazenamento de dados na SESSION
	$sidlogin = md5(time().uniqid());						
	
	// Armazena SID para utilizar no momento que a HOME é carregada
	$_SESSION["sidlogin"] = $sidlogin;				
	$_SESSION["hrdlogin"] = strtotime("now");
	
	// Armazena rotinas da tela ATENDA
	$rotinasTela[0]  = "CAPITAL";
	$rotinasTela[1]  = "EMPRESTIMOS";
	$rotinasTela[2]  = "PRESTACOES";
	$rotinasTela[3]  = "DEP. VISTA";
	$rotinasTela[4]  = "LIMITE CRED";
	$rotinasTela[5]  = "APLICACOES";
	$rotinasTela[6]  = "POUP. PROG";
	$rotinasTela[7]  = "CONTA INV";
	$rotinasTela[8]  = "DESCONTOS";
	$rotinasTela[9]  = "CARTAO CRED";
	$rotinasTela[10] = "SEGURO";
	$rotinasTela[11] = "LAUTOM";
	$rotinasTela[12] = "MAGNETICO";
	$rotinasTela[13] = "FOLHAS CHEQ";
	$rotinasTela[14] = "OCORRENCIAS";
	$rotinasTela[15] = "INTERNET";
	$rotinasTela[16] = "TELE ATEN";
	$rotinasTela[17] = "CONVENIOS";
	$rotinasTela[18] = "RELACIONAMENTO";
	$rotinasTela[19] = "COBRANCA";
	$rotinasTela[20] = "TELEFONE";
	$rotinasTela[21] = "FICHA CADASTRAL";
	$rotinasTela[22] = "CONSORCIO";
	
	// Cria array temporário com variáveis globais					
	$glbvars["cdcooper"] = 1;		
	$glbvars["nmcooper"] = "VIACREDI";	
	$glbvars["cdagenci"] = 0;
	$glbvars["nrdcaixa"] = 0;
	$glbvars["cdoperad"] = "1";							
	$glbvars["nmoperad"] = "SUPER-USUARIO";				
	$glbvars["dtmvtolt"] = date("d/m/Y");
	$glbvars["dtmvtopr"] = date("d/m/Y");
	$glbvars["dtmvtoan"] = date("d/m/Y");
	$glbvars["inproces"] = 1;
	$glbvars["idorigem"] = 5;
	$glbvars["idsistem"] = 1;
	$glbvars["stimeout"] = 3600;
	$glbvars["cddepart"] = 20;
	$glbvars["dsdepart"] = "TI";
	$glbvars["dsdircop"] = "viacredi";
	$glbvars["hraction"] = strtotime("now");
	$glbvars["flgdsenh"] = "no";
	$glbvars["sidlogin"] = $sidlogin;
	$glbvars["cdpactra"] = "1";
	$glbvars["flgperac"] = "no";
	$glbvars["nvoperad"] = 3;
	$glbvars["nmdatela"] = "ATENDA";
	$glbvars["nmrotina"] = "";
	$glbvars["rotinasTela"] = $rotinasTela;
	
	// Armazena os dados globais na session
	$_SESSION["glbvars"][$sidlogin] = $glbvars;	
			
	$url    = $UrlSite."telas/atenda/obtem_cabecalho.php";		
	$params = "sidlogin=".urlencode($sidlogin)."&nrdconta=329&nrdctitg=&ServerMonitoracao=".$ServerMonitoracao;
	$cookie = session_name().'='.session_id(); 
	
	session_write_close();	
	
	$hrinicio = gettimeofday(true);
	
	$ch = curl_init();
	
	curl_setopt($ch,CURLOPT_URL,$url);	
	curl_setopt($ch,CURLOPT_RETURNTRANSFER,TRUE);
	curl_setopt($ch,CURLOPT_POST,2);
	curl_setopt($ch,CURLOPT_POSTFIELDS,$params);
	curl_setopt($ch,CURLOPT_COOKIESESSION,TRUE); 
	curl_setopt($ch,CURLOPT_HEADER,0); 	
	curl_setopt($ch,CURLOPT_COOKIE,$cookie); 
	curl_setopt($ch,CURLOPT_FOLLOWLOCATION,1); 	
	
	$result = curl_exec($ch);
	
	curl_close($ch);
	
	$hrfinal = gettimeofday(true);	
	
	if (strpos($result,"flgAcessoRotina = true;")) {
		echo "0 - OK  - Tempo: ".number_format(($hrfinal - $hrinicio),2)." segundos";
	} else {
		echo "2 - NOK - Tempo: ".number_format(($hrfinal - $hrinicio),2)." segundos".$result;
	}
	
	session_destroy();	

?>
