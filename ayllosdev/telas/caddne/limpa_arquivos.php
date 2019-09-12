<?php
/**************************************************************************************
	ATENÇÃO: SE ESTA TELA ALGUM DIA FOR LIBERADA PARA A PRODUÇÃO TEM QUE SER ALTERADA
			 PARA O NOVO LAYOUT DO AYLLOS WEB.
			 FALAR COM O GABRIEL OU DANIEL. 19/02/2013.
****************************************************************************************/

	/*************************************************************************
	  Fonte: limpa_arquivos.php                                               
	  Autor: Henrique - Jorge                                                 
	  Data : Agosto/2011                       Última Alteração: 30/07/2014
	                                                                   
	  Objetivo  : Limpar acentos e dividir em arquivos menores, arquivo do correio.              
	                                                                 
	  Alterações: 30/07/2014 - Alterar limite de linhas por arquivo de  
	                           15.000 para 5.000 (David).
	                                                                  
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
			
	$array1 = array("á","à","â","ã","ä","é","è","ê","ë","í","ì","î","ï","ó","ò","ô","õ","ö","ú","ù","û","ü","ç","ñ"
	               ,"Á","À","Â","Ã","Ä","É","È","Ê","Ë","Í","Ì","Î","Ï","Ó","Ò","Ô","Õ","Ö","Ú","Ù","Û","Ü","Ç","Ñ"
				   ,"&","¨","~","^","*","#","%","$","!","?",";",">","<","|","+","=","£","¢","¬","§","`","´","¹","²"
				   ,"³","ª","º","°","\"","'","\\");
	$array2 = array("a","a","a","a","a","e","e","e","e","i","i","i","i","o","o","o","o","o","u","u","u","u","c","n"
                   ,"A","A","A","A","A","E","E","E","E","I","I","I","I","O","O","O","O","O","U","U","U","U","C","N"
				   ," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "
				   ," "," "," "," "," "," "," ","/");
	
	$cduflogr = $_POST["cduflogr"];
	
	if ($cduflogr == "LOG_LOCALIDADE.TXT") {
		$nmarquiv = "/var/www/ayllos/telas/caddne/arquivos/LOG_LOCALIDADE.TXT";	
		$nmretorn = "/var/www/ayllos/telas/caddne/arquivos/LOCALIDADE.TXT";
	} elseif ($cduflogr == "LOG_BAIRRO.TXT") {
		$nmarquiv = "/var/www/ayllos/telas/caddne/arquivos/LOG_BAIRRO.TXT";	
		$nmretorn = "/var/www/ayllos/telas/caddne/arquivos/BAIRRO.TXT";			
	} elseif ($cduflogr == "UNID_OPER") {
		$nmarquiv = "/var/www/ayllos/telas/caddne/arquivos/LOG_UNID_OPER.TXT";
	} elseif ($cduflogr == "CPC") {
		$nmarquiv = "/var/www/ayllos/telas/caddne/arquivos/LOG_CPC.TXT";
	} elseif ($cduflogr == "GRANDE_USUARIO") {
		$nmarquiv = "/var/www/ayllos/telas/caddne/arquivos/LOG_GRANDE_USUARIO.TXT";			
	} else {
		$nmarquiv = "/var/www/ayllos/telas/caddne/arquivos/LOG_LOGRADOURO_".$cduflogr.".TXT";
	}

	// Caso não consiga encontrar o aquivo é cancelada a limpeza.
	if (!file_exists($nmarquiv)) {
		exit();
	}
	
	// Abre para leitura o arquivo original e cria um novo.
	$arquivo = fopen($nmarquiv,"r");

	$contLin  = 0;
	$contArq  = 0;
	$LinLimit = 5000;
	
	//Lê arquivo original e alimenta um novo com o texto formatado
	while (!feof($arquivo)) {
		$linha = trim(str_replace( $array1, $array2, fgets($arquivo)));
		
		if(strlen(trim($linha)) == 0){
			continue;
		}
		
		if(($contLin == 0 || $contLin == $LinLimit) && ($cduflogr != "LOG_LOCALIDADE.TXT") && ($cduflogr != "LOG_BAIRRO.TXT")){
			$contArq++;
			$nmretorn = "/var/www/ayllos/telas/caddne/arquivos/".$cduflogr."_".$contArq.".TXT";
			$retorno = fopen($nmretorn,"w");
		}else if(($contLin == 0) && (($cduflogr == "LOG_LOCALIDADE.TXT") || ($cduflogr == "LOG_BAIRRO.TXT"))){
			$retorno = fopen($nmretorn,"w");
		}
		
		$conteudo = explode("@", $linha);
		
		if ($cduflogr == "LOG_LOCALIDADE.TXT" ){
			
			$linha = $conteudo[0]."@".$conteudo[2]."@".$conteudo[7]."@";
			
			$cidade[$conteudo[0]] = $conteudo[2]."@".$conteudo[7];
		
		} elseif ($cduflogr == "LOG_BAIRRO.TXT") {
		
			$linha = $conteudo[0]."@".$conteudo[3]."@".$conteudo[4]."@";
			
			$bairro[$conteudo[0]] = $conteudo[3]."@".$conteudo[4]."@";
		
		} elseif ($cduflogr == "UNID_OPER") {
			/* Coloca na variavel o seguinte conteudo:
				CEP@UF@NOME RUA@RESUMIDO RUA@COMPLEMENTO@TIPO@BAIRRO@BAIRRO RESUMIDO@CIDADE@CIDADE RESUMIDO
			*/
		
			$linha = $conteudo[7]."@".$conteudo[1]."@".$conteudo[6]."@".$conteudo[9]."@".$conteudo[5]."@"." "."@";
			$bairro = (int) $conteudo[3];
			$cidade = (int) $conteudo[2];			
			
			$linha .= $glbvars["BAIRRO"][$bairro];
			
			$linha .= $glbvars["LOCALIDADE"][$cidade];
			
		} elseif ($cduflogr == "GRANDE_USUARIO") {
			/* Coloca na variavel o seguinte conteudo:
				CEP@UF@NOME RUA@RESUMIDO RUA@COMPLEMENTO@TIPO@BAIRRO@BAIRRO RESUMIDO@CIDADE@CIDADE RESUMIDO
			*/
			if (trim($conteudo[8]) == "") $aux_resumido = $conteudo[6]; else $aux_resumido = $conteudo[8];
			$linha = $conteudo[7]."@".$conteudo[1]."@".$conteudo[6]."@".$aux_resumido."@".$conteudo[5]."@"." "."@";
			$bairro = (int) $conteudo[3];
			$cidade = (int) $conteudo[2];			
			
			$linha .= $glbvars["BAIRRO"][$bairro];
			
			$linha .= $glbvars["LOCALIDADE"][$cidade];
		
		} elseif ($cduflogr == "CPC") {
			/* Coloca na variavel o seguinte conteudo:
				CEP@UF@NOME RUA@RESUMIDO RUA@COMPLEMENTO@TIPO@BAIRRO@BAIRRO RESUMIDO@CIDADE@CIDADE RESUMIDO
			*/			
			$linha = $conteudo[5]."@".$conteudo[1]."@".$conteudo[4]."@".$conteudo[3]."@".$conteudo[3]."@"." "."@";
			$cidade = (int) $conteudo[2];			
			
			//$linha .= $glbvars["BAIRRO"][$bairro];
			$linha .= " "."@"." "."@";
			
			$linha .= $glbvars["LOCALIDADE"][$cidade];		
		
		} else {			
			
			/* Coloca na variavel o seguinte conteudo:
				CEP@UF@NOME RUA@RESUMIDO RUA@COMPLEMENTO@TIPO@BAIRRO@BAIRRO RESUMIDO@CIDADE@CIDADE RESUMIDO
			*/
			$linha = $conteudo[7]."@".$conteudo[1]."@".$conteudo[5]."@".$conteudo[10]."@".$conteudo[6]."@".$conteudo[8]."@";
			$bairro = (int) $conteudo[3];
			$cidade = (int) $conteudo[2];			
			
			$linha .= $glbvars["BAIRRO"][$bairro];
			
			$linha .= $glbvars["LOCALIDADE"][$cidade];
		}
		fwrite($retorno, $linha."\n");
		$contLin++;
		
		// se for arquivo de um dos estados e chegar no limite de linhas estabelecido...
		// fecha o arquivo atual e começa outro.. 
		if((($contLin == $LinLimit)) && ($cduflogr != "LOG_LOCALIDADE.TXT") && ($cduflogr != "LOG_BAIRRO.TXT")){
			fclose($nmretorn);
			$contLin = 0;
		}
		
	}
	if($contLin != 0){
		fclose($nmretorn);
	}
	//Fecha o arquivo
	fclose($arquivo);
	
	//Deleta o arquivo original
	unlink($nmarquiv);	
	
	if ($cduflogr == "LOG_LOCALIDADE.TXT" ){
		setVarSession("LOCALIDADE", $cidade);
	} elseif ($cduflogr == "LOG_BAIRRO.TXT") {
		setVarSession("BAIRRO", $bairro);
	} 

?>