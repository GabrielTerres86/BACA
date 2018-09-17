<?php 
	/*********************************************************************
	 Fonte: manter_rotina.php                                                 
	 Autor: Renato Darosci                                                   
	 Data : Mai/2015                Última Alteração: 12/05/2017
	                                                                  
	 Objetivo  : Tratar as requisicoes da tela PARFOL                                 
	                                                                  
	 Alterações: 21/10/2015 - Correcao para envio da cddopcao de alteracao
	                          na validaPermissao (Marcos-Supero)
							  
				 23/11/2015 - Desconsiderando a posicao 4 do array de acessos
				        	  (Andre Santos - SUPERO)	
							  
				 18/01/2017 - Validacao de horario de operacao do spb. (M342 - Kelvin)   
				
				 19/01/2017 - Adicionado novo limite de horario para pagamento no dia
							   para contas da cooperativa. (M342 - Kelvin)
				 
				 12/05/2017 - Segunda fase da melhoria 342 (Kelvin).
	**********************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");	
	
	$dsvlrprm1 = $_POST["dsvlrprm1"]; 
	$dsvlrprm2 = $_POST["dsvlrprm2"]; 
	$dsvlrprm3 = $_POST["dsvlrprm3"]; 
	$dsvlrprm4 = $_POST["dsvlrprm4"]; 
	$dsvlrprm5 = $_POST["dsvlrprm5"]; 
	$dsvlrprm6 = $_POST["dsvlrprm6"]; 
	$dsvlrprm7 = $_POST["dsvlrprm7"]; 
	$dsvlrprm8 = $_POST["dsvlrprm8"]; 
	$dsvlrprm9 = $_POST["dsvlrprm9"]; 
	$dsvlrprm10= $_POST["dsvlrprm10"]; 
	$dsvlrprm11= $_POST["dsvlrprm11"]; 
	$dsvlrprm12= $_POST["dsvlrprm12"]; 
	$dsvlrprm13= $_POST["dsvlrprm13"]; 
	$dsvlrprm14= $_POST["dsvlrprm14"]; 
	$dsvlrprm15= $_POST["dsvlrprm15"]; 
	$dsvlrprm16= $_POST["dsvlrprm16"];
	$dsvlrprm17= $_POST["dsvlrprm17"];
	$dsvlrprm18= $_POST["dsvlrprm18"]; 
	$dsvlrprm19= $_POST["dsvlrprm19"];
	$dsvlrprm20= $_POST["dsvlrprm20"];
	$dsvlrprm21= $_POST["dsvlrprm21"];
	$dsvlrprm22= $_POST["dsvlrprm22"];
	$dsvlrprm23= $_POST["dsvlrprm23"];
	$dsvlrprm24= $_POST["dsvlrprm24"];
	$dsvlrprm25= $_POST["dsvlrprm25"];
	
    // Verifica Permissão
	if (($msgError = validaPermissao($glbvars["nmdatela"],"","A")) <> "") {
		exibirErro('error',$msgError,'Alerta - Ayllos','voltar()',false);
	}	
	
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "    <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "    <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "    <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "    <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "    <idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xml .= "    <dsvlrprm1>".$dsvlrprm1."</dsvlrprm1>"; 
	$xml .= "    <dsvlrprm2>".$dsvlrprm2."</dsvlrprm2>"; 
	$xml .= "    <dsvlrprm3>".$dsvlrprm3."</dsvlrprm3>"; 
	$xml .= "    <dsvlrprm4>".$dsvlrprm4."</dsvlrprm4>"; 
	$xml .= "    <dsvlrprm5>".$dsvlrprm5."</dsvlrprm5>"; 
	$xml .= "    <dsvlrprm6>".$dsvlrprm6."</dsvlrprm6>"; 
	$xml .= "    <dsvlrprm7>".$dsvlrprm7."</dsvlrprm7>"; 
	$xml .= "    <dsvlrprm8>".$dsvlrprm8."</dsvlrprm8>"; 
	$xml .= "    <dsvlrprm9>".$dsvlrprm9."</dsvlrprm9>"; 
	$xml .= "    <dsvlrprm10>".$dsvlrprm10."</dsvlrprm10>"; 
	$xml .= "    <dsvlrprm11>".$dsvlrprm11."</dsvlrprm11>"; 
	$xml .= "    <dsvlrprm12>".$dsvlrprm12."</dsvlrprm12>"; 
	$xml .= "    <dsvlrprm13>".$dsvlrprm13."</dsvlrprm13>"; 
	$xml .= "    <dsvlrprm14>".$dsvlrprm14."</dsvlrprm14>"; 
	$xml .= "    <dsvlrprm15>".$dsvlrprm15."</dsvlrprm15>"; 
	$xml .= "    <dsvlrprm16>".$dsvlrprm16."</dsvlrprm16>"; 
	$xml .= "    <dsvlrprm17>".$dsvlrprm17."</dsvlrprm17>"; 
	$xml .= "    <dsvlrprm18>".$dsvlrprm18."</dsvlrprm18>"; 
	$xml .= "    <dsvlrprm19>".$dsvlrprm19."</dsvlrprm19>"; 
	$xml .= "    <dsvlrprm20>".$dsvlrprm20."</dsvlrprm20>"; 
	$xml .= "    <dsvlrprm21>".$dsvlrprm21."</dsvlrprm21>"; 
	$xml .= "    <dsvlrprm22>".$dsvlrprm22."</dsvlrprm22>"; 
	$xml .= "    <dsvlrprm23>".$dsvlrprm23."</dsvlrprm23>";
	$xml .= "    <dsvlrprm24>".$dsvlrprm24."</dsvlrprm24>";
	$xml .= "    <dsvlrprm25>".$dsvlrprm25."</dsvlrprm25>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";
		
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "PARFOL", "FOLHAIB_GRAVA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");	
	$xmlObjeto 	= getObjectXML($xmlResult);	
	
	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;	
		$cdCmpErr = $xmlObjeto->roottag->tags[0]->tags[0]->tags[3]->cdata;
		
		// Aqui estão todos os tratamentos de erro retornados pelo Oracle
		if ($cdCmpErr > 0) {
			switch ($cdCmpErr) {
				case 8:
					$dsComand = 'Cdsvlrprm8.focus();Cdsvlrprm8.addClass(\'campoErro\');';
					$msgErro  = 'Hora de Agendamento informada &eacute; inv&aacute;lida!';
					break;
				case 9:
					$dsComand = 'Cdsvlrprm9.focus();Cdsvlrprm9.addClass(\'campoErro\');';
					$msgErro  = 'Hora de Portabilidade (Pgto no dia) informada &eacute; inv&aacute;lida!';
					break;
				case 10:
					$dsComand = 'Cdsvlrprm10.focus();Cdsvlrprm10.addClass(\'campoErro\');';
					$msgErro  = 'Hora de Solicita&ccedil;&atilde;o Estouro Conta informada &eacute; inv&aacute;lida!';
					break;
				case 11:
					$dsComand = 'Cdsvlrprm11.focus();Cdsvlrprm11.addClass(\'campoErro\');';
					$msgErro  = 'Hora de An&aacute;lise Estouro Conta informada &eacute; inv&aacute;lida!';
					break;
				case 22:
					$dsComand = 'Cdsvlrprm22.focus();Cdsvlrprm22.addClass(\'campoErro\');';
					$msgErro  = 'Hora de Pagto no dia (contas cooperativa) informada &eacute; inv&aacute;lida!';
					break;
				case 24:
					$dsComand = 'Cdsvlrprm24.focus();Cdsvlrprm24.addClass(\'campoErro\');';
					$msgErro  = 'Hora de Limite (transf no dia) informada &eacute; inv&aacute;lida!';
					break;
				case 51:
					$dsComand = 'Cdsvlrprm5.focus();Cdsvlrprm5.addClass(\'campoErro\');';
					$msgErro  = 'Hist&oacute;rico Estorno Outras Empresas deve ser um hist&oacute;rico de cr&eacute;dito!';
					break;
				case 52:
					$dsComand = 'Cdsvlrprm6.focus();Cdsvlrprm6.addClass(\'campoErro\');';
					$msgErro  = 'Hist&oacute;rico Estorno para Cooperativas deve ser um hist&oacute;rico de cr&eacute;dito!';
					break;
				case 53:
					$dsComand = 'Cdsvlrprm13.focus();Cdsvlrprm13.addClass(\'campoErro\');';
					$msgErro  = 'Hist&oacute;rico Cr&eacute;dito TEC deve ser um hist&oacute;rico de cr&eacute;dito!';
					break;
				case 54:
					$dsComand = 'Cdsvlrprm14.focus();Cdsvlrprm14.addClass(\'campoErro\');';
					$msgErro  = 'Hist&oacute;rico D&eacute;bito TEC deve ser um hist&oacute;rico de d&eacute;bito!';
					break;
				case 55:
					$dsComand = 'Cdsvlrprm15.focus();Cdsvlrprm15.addClass(\'campoErro\');';
					$msgErro  = 'Hist&oacute;rico Recusa TEC deve ser um hist&oacute;rico de cr&eacute;dito!';
					break;
				case 56:
					$dsComand = 'Cdsvlrprm16.focus();Cdsvlrprm16.addClass(\'campoErro\');';
					$msgErro  = 'Hist&oacute;rico Devolu&ccedil;&atilde;o TEC deve ser um hist&oacute;rico de d&eacute;bito!';
					break;
				case 57:
					$dsComand = 'Cdsvlrprm17.focus();Cdsvlrprm17.addClass(\'campoErro\');';
					$msgErro  = 'Hist&oacute;rico Devolu&ccedil;&atilde;o Empresa deve ser um hist&oacute;rico de cr&eacute;dito!';
					break;
				case 58:
					$dsComand = 'Cdsvlrprm19.focus();Cdsvlrprm19.addClass(\'campoErro\');';
					$msgErro  = 'Hist&oacute;rico D&eacute;bito TRF  deve ser um hist&oacute;rico de d&eacute;bito!';
					break;
				case 59:
					$dsComand = 'Cdsvlrprm20.focus();Cdsvlrprm20.addClass(\'campoErro\');';
					$msgErro  = 'Hist&oacute;rico Cr&eacute;dito TRF deve ser um hist&oacute;rico de cr&eacute;dito!';
					break;
				case 61:
					$dsComand = 'Cdsvlrprm5.focus();Cdsvlrprm5.addClass(\'campoErro\');';
					$msgErro  = 'Hist&oacute;rico inexistente!';
					break;
				case 62:
					$dsComand = 'Cdsvlrprm6.focus();Cdsvlrprm6.addClass(\'campoErro\');';
					$msgErro  = 'Hist&oacute;rico inexistente!';
					break;
				case 63:
					$dsComand = 'Cdsvlrprm13.focus();Cdsvlrprm13.addClass(\'campoErro\');';
					$msgErro  = 'Hist&oacute;rico inexistente!';
					break;
				case 64:
					$dsComand = 'Cdsvlrprm14.focus();Cdsvlrprm14.addClass(\'campoErro\');';
					$msgErro  = 'Hist&oacute;rico inexistente!';
					break;
				case 65:
					$dsComand = 'Cdsvlrprm15.focus();Cdsvlrprm15.addClass(\'campoErro\');';
					$msgErro  = 'Hist&oacute;rico inexistente!';
					break;
				case 66:
					$dsComand = 'Cdsvlrprm16.focus();Cdsvlrprm16.addClass(\'campoErro\');';
					$msgErro  = 'Hist&oacute;rico inexistente!';
					break;
				case 67:
					$dsComand = 'Cdsvlrprm17.focus();Cdsvlrprm17.addClass(\'campoErro\');';
					$msgErro  = 'Hist&oacute;rico inexistente!';
					break;
				case 68:
					$dsComand = 'Cdsvlrprm19.focus();Cdsvlrprm19.addClass(\'campoErro\');';
					$msgErro  = 'Hist&oacute;rico inexistente!';
					break;
				case 69:
					$dsComand = 'Cdsvlrprm20.focus();Cdsvlrprm20.addClass(\'campoErro\');';
					$msgErro  = 'Hist&oacute;rico inexistente!';
					break;
				case 101:
					$dsComand = 'Cdsvlrprm11.focus();Cdsvlrprm11.addClass(\'campoErro\');';
					$msgErro  = 'O Hor&aacute;rio Limite de An&aacute;lise do Estouro deve ser superior ao Hor&aacute;rio Limite de Solicita&ccedil;&atilde;o de Estouro.';
					break;
				case 83:
					$dsComand = 'Cdsvlrprm8.focus();Cdsvlrprm8.addClass(\'campoErro\');';
					$msgErro  = 'Hor&aacute;rio informado deve estar dentro do hor&aacute;rio limite de transfer&ecirc;ncia para Internet.';
					break;
				case 93:
					$dsComand = 'Cdsvlrprm9.focus();Cdsvlrprm9.addClass(\'campoErro\');';
					$msgErro  = 'Hor&aacute;rio informado deve estar dentro do hor&aacute;rio limite de transfer&ecirc;ncia para Internet.';
					break;
				case 103:
					$dsComand = 'Cdsvlrprm10.focus();Cdsvlrprm10.addClass(\'campoErro\');';
					$msgErro  = 'Hor&aacute;rio informado deve estar dentro do hor&aacute;rio limite de transfer&ecirc;ncia para Internet.';
					break;
				case 113:
					$dsComand = 'Cdsvlrprm11.focus();Cdsvlrprm11.addClass(\'campoErro\');';
					$msgErro  = 'Hor&aacute;rio informado deve estar dentro do hor&aacute;rio limite de transfer&ecirc;ncia para Internet.';
					break;
				case 114:
					$dsComand = 'Cdsvlrprm9.focus();Cdsvlrprm9.addClass(\'campoErro\');';
					$msgErro  = 'Hor&aacute;rio informado deve estar dentro do hor&aacute;rio de opera&ccedil;&atilde;o do SPB.';
					break;
				case 115:
					$dsComand = 'Cdsvlrprm22.focus();Cdsvlrprm22.addClass(\'campoErro\');';
					$msgErro  = 'Hor&aacute;rio informado deve estar dentro do hor&aacute;rio limite de transfer&ecirc;ncia para Internet.';
					break;
				case 116:
					$dsComand = 'Cdsvlrprm24.focus();Cdsvlrprm24.addClass(\'campoErro\');';
					$msgErro  = 'Hor&aacute;rio informado deve estar dentro do hor&aacute;rio limite de transfer&ecirc;ncia para Internet.';
					break;
				default:
					$dsComand = '';
			}
		}
		
		exibirErro('error',$msgErro,'Alerta - Ayllos',$dsComand,false);
	} 
	
	
		
?>