<?php
/* * ****************************************************************************
	 Fonte: obtem_cabecalho.php                                       
	 Autor: David                                                     
	 Data : Julho/2007                   Última Alteração: 01/12/2017
	                                                                  
	 Objetivo  : Capturar dados de cabecalho da tela ATENDA           
	                                                                  
	 Alterações: 12/09/2008 - Alimentar variável global inpessoa      
	                        - Ativar rotina de Magnéticos (David).    
	                        - Ativar rotina Descontos (Guilherme).    
	                                                                  
	             03/09/2009 - Incluir rotina Relacionamento(Guilherme)
	                                                                  
	             28/10/2010 - Alterar título da rotina Crédito Rota-  
	                          tivo para Limite Empresarial (David).   
																	  
				 07/12/2010 - Incluir rotina de Cobranca (Gabriel)   
																	  
				 14/01/2011 - Incluir rotina de Telefone (Gabriel)   
																	  
				 08/02/2011 - Incluir rotina de Emprestimos		  
							  (Gabriel/DB1)  						  
																	  
				 18/03/2011 - Ajuste nas anotacoes (David)           
	
				 01/09/2011 - Nova rotina Ficha cadastral (Gabriel)
	
				 01/11/2011 - Nova rotina Seguro (Marcelo Pereira - GATI)
	
				 12/07/2012 - Adicionado class classDisabled e
							  desabilidado os campos a seguir (Jorge).
	
				 31/05/2013 - Incluir chamada da b1wgen0147 para buscar
							  valores referentes ao BNDES (Lucas R.).
	
				 24/07/2013 - Incluir novo item CONSORCIO em tela.
							  Incluir Procedure indicativo_consorcio que
							  retorna o flgativo, consorcio ativo ou nao
							  (Lucas R.)
	
				 30/09/2013 - Incluir campo hdnFlgdig. (Jean Michel).
				 
				 08/11/2013 - Validação para senha Inativa (Cristian - Gati).
	
	             23/09/2014 - Incluido opção Pagto de Titulos
							  (André Santos - SUPERO)
	
				 05/12/2014 - Ajustado fonte para receber novo parâmetro 
	                          flgerlog via método POST (Daniel)	
	
	             03/03/2015 - Receber novo parâmetro 'ServerMonitoracao' 
	                          para utilização nas requisições de monitoração
                              (David).
	
				 20/07/2015 - Incluir novo item Limite Saque TAA. (James)
					
				 21/08/2015 - Ajuste para inclusão das novas telas "Atendimento,
							  Produtos"
				              (Gabriel - Rkam -> Projeto 217).
							 
				 24/08/2015 - Projeto Reformulacao cadastral		   
							 (Tiago Castro - RKAM)
							 
				 18/09/2015 - Ajustado para validar corretamente a restricao de 
                              usuario ao acesso a conta (Tiago/Rodrigo #327432)
							  
				 20/09/2015 - Ajuste para inclusão das novas telas "Atendimento,
						      Produtos"
				              (Gabriel - Rkam -> Projeto 217).		
                  
                 03/11/2015 - Alterada chamada da rotina "carrega_dados_atenda"
                              para utilização da rotina convertida para oracle
                              CADA0004.pc_carrega_dados_atenda
                              SD318820 (Odirlei/Busana)
							  
                 24/11/2015 - Inclusao CDCLCNAE para o PRJ Negativacao Serasa.
                              (Jaison/Andrino)

					  07/06/2016 - Melhoria 195 folha de pagamento (Tiago/Thiago)
	
				 09/08/2016 - Adicionado format na data das anotações conforme solicitado
							  no chamado 490482. (Kelvin)
	
         23/06/2016 - Alterado a formatação da opção SEGUROS para SIM/NÂO (Marcos-Supero)

         28/06/2016  - Incluido Case Cartao Assinatura - (Evandro)

         07/07/2016 - Correcao do erro apresentado no LOG sobre a utilizacao
			                da variavel $opeProdutos.SD 479874 (Carlos Rafael Tanholi)

					  11/07/2016 - Correcao do erro de indice indefinido para FLCONVEN e DSCRITIC. SD 479874 (Carlos Rafael Tanholi)

					  13/07/2016 - Correcao geral nos erros levantados no LOG do PHP .SD 479874 (Carlos Rafael Tanholi)

					  14/07/2016 - Correcao na forma de recuperacao de dados do XML. SD 479874 (Carlos Rafael Tanholi)

                      09/08/2016 - Adicionado format na data das anotações conforme solicitado
							  no chamado 490482. (Kelvin)

				18/08/2016  - adicionado parametro labelRot na chamada da rotina acessaRotina

                 26/04/2017 - Incluido a tag textarea para mostrar o conteudo da mensagem de alerta (Rafael Monteiro).
				 				 
                 23/06/2017 - Ajuste para inclusao do novo tipo de situacao da conta
  				              "Desligamento por determinação do BACEN" 
							  ( Jonata - RKAM P364).	

				 08/08/2017 - Implementacao da melhoria 438. Heitor (Mouts).

				 14/11/2014 - Ajuste para controlar acesso as rotinas quando cooperado desligado (Jonata - P364)

				 22/11/2017 - Ajuste para permitir apenas consulta, na rotina seguros, de acordo com a situação da conta (Jonata - RKAM p364).

				 01/12/2017 - Permitir acesso a produtos para contas demitidas (Joanta - RKAM P364).

 * ********************************************************************************** */

	session_start();	
	
	// Parâmetro utilizado na monitoração de performance e disponibilidade
	// A variável $ServerMonitoracao será utilizada na include config.php
if (isset($_POST['ServerMonitoracao']) && trim($_POST['ServerMonitoracao']) <> '')
    $ServerMonitoracao = $_POST['ServerMonitoracao'];
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");
	
	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");	
	
	// Verifica Permissão
if (($msgError = validaPermissao($glbvars["nmdatela"], "", "@")) <> "") {
		exibeErro($msgError);
	}
	
	// Pega opções em que o operador tem permissão
	if (isset($glbvars["rotinasTela"])) {
		$rotinasTela = $glbvars["rotinasTela"];
} else {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	// Se campos necessários para carregar dados não foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrdctitg"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	
	
$nrdconta = $_POST["nrdconta"] == "" ? 0 : $_POST["nrdconta"];
$nrdctitg = $_POST["nrdctitg"];
$flgProdutos = ( isset($_POST["flgProdutos"]) ) ? $_POST["flgProdutos"]: '';
	
//declara variavel
$opeProdutos = 0;
$vlemprst = 0;
$vlempbnd = 0;
$vlpresta = 0;
$vlrbndes = 0;

if ($nrdconta != "") {
		$nrdctitg = "";		
	}
	
	// Se conta informada não for um número inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}		
	
	$flgerlog = isset($_POST["flgerlog"]) ? $_POST["flgerlog"] : "no";
	
	// Monta o xml de requisição
$xmlGetDadosAtenda = "";
	$xmlGetDadosAtenda .= "<Root>";	
    $xmlGetDadosAtenda .= "	<Dados>";
$xmlGetDadosAtenda .= "		<nrdconta>" . $nrdconta . "</nrdconta>";
	$xmlGetDadosAtenda .= "		<idseqttl>1</idseqttl>";
$xmlGetDadosAtenda .= "		<nrdctitg>" . $nrdctitg . "</nrdctitg>";
$xmlGetDadosAtenda .= "		<dtmvtolt>" . $glbvars["dtmvtolt"] . "</dtmvtolt>";
$xmlGetDadosAtenda .= "		<dtmvtopr>" . $glbvars["dtmvtopr"] . "</dtmvtopr>";
$xmlGetDadosAtenda .= "		<dtmvtoan>" . $glbvars["dtmvtoan"] . "</dtmvtoan>";
$xmlGetDadosAtenda .= "		<dtiniper>" . date("d/m/Y") . "</dtiniper>";
$xmlGetDadosAtenda .= "		<dtfimper>" . date("d/m/Y") . "</dtfimper>";
$xmlGetDadosAtenda .= "		<nmdatela>" . $glbvars["nmdatela"] . "</nmdatela>";
$xmlGetDadosAtenda .= "		<idorigem>" . $glbvars["idorigem"] . "</idorigem>";
$xmlGetDadosAtenda .= "		<inproces>" . $glbvars["inproces"] . "</inproces>";
if ($flgerlog) {
        $xmlGetDadosAtenda .= "		<flgerlog>S</flgerlog>";
} else {
        $xmlGetDadosAtenda .= "		<flgerlog>N</flgerlog>";
    }
	$xmlGetDadosAtenda .= "	</Dados>";
	$xmlGetDadosAtenda .= "</Root>";
		
	// Executa script para envio do XML
    $xmlResult = mensageria($xmlGetDadosAtenda, "ATENDA", "CARREGA_DADOS_ATENDA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");     
    
	// Cria objeto para classe de tratamento de XML
	$xmlObjDadosAtenda = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra crítica	
	if (strtoupper($xmlObjDadosAtenda->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjDadosAtenda->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	function exibeErro($msgErro) {
		echo 'hideMsgAguardo();';
    echo 'showError("error","' . $msgErro . '","Alerta - Atenda","$(\'#nrdconta\',\'#frmCabAtenda\').focus()");';
		echo 'limparDadosCampos();';
		echo 'flgAcessoRotina = false;';
		exit();	
	}

$cabecalho = ( isset($xmlObjDadosAtenda->roottag->tags[0]->tags[0]->tags) ) ? $xmlObjDadosAtenda->roottag->tags[0]->tags[0]->tags : '';
$compCabecalho = ( isset($xmlObjDadosAtenda->roottag->tags[1]->tags[0]->tags) ) ? $xmlObjDadosAtenda->roottag->tags[1]->tags[0]->tags : '';
$valores = ( isset($xmlObjDadosAtenda->roottag->tags[2]->tags[0]->tags) ) ? $xmlObjDadosAtenda->roottag->tags[2]->tags[0]->tags : null;
$mensagens = ( isset($xmlObjDadosAtenda->roottag->tags[3]->tags) )  ? $xmlObjDadosAtenda->roottag->tags[3]->tags : array();
$anotacoes = ( isset($xmlObjDadosAtenda->roottag->tags[4]->tags) ) ? $xmlObjDadosAtenda->roottag->tags[4]->tags : array();
	
	// Carrega variavel para verificar se existe Pagto de Titulos por Arquivo
$flconven = (isset($xmlObjDadosAtenda->roottag->tags[4]->attributes['FLCONVEN'])) ? $xmlObjDadosAtenda->roottag->tags[4]->attributes['FLCONVEN'] : null;
$dscritic = (isset($xmlObjDadosAtenda->roottag->tags[4]->attributes['DSCRITIC'])) ? $xmlObjDadosAtenda->roottag->tags[4]->attributes['DSCRITIC'] : null;
	
	// Adicionar quantidade de titulares
	$html = "<input type='hidden' id='qttitula' name='qttitula'/>"; 
	// Adiciona ao HTML
echo '$("#frmCabAtenda").append("' . $html . '");';
	
	// Dados da Conta
if ( isset($cabecalho[0]->cdata) ) {
	echo '$("#nrmatric","#frmCabAtenda").val("' . $cabecalho[0]->cdata . '").formataDado("INTEGER","zzz.zzz","",false);';
}
if ( isset($cabecalho[1]->cdata) ) {
	echo '$("#cdagenci","#frmCabAtenda").val("' . $cabecalho[1]->cdata . '");';
}
if ( isset($cabecalho[2]->cdata) ) {
	echo '$("#dtadmiss","#frmCabAtenda").val("' . $cabecalho[2]->cdata . '");';
}
if ( isset($cabecalho[3]->cdata) ) {
	echo '$("#nrdctitg","#frmCabAtenda").val("' . $cabecalho[3]->cdata . '").formataDado("STRING","9.999.999-9",".-",false);';
}
if ( isset($cabecalho[4]->cdata) ) {
	echo '$("#nrctainv","#frmCabAtenda").val("' . $cabecalho[4]->cdata . '").formataDado("INTEGER","zz.zzz.zzz-z","",false);';
}
if ( isset($cabecalho[5]->cdata) ) {
	echo '$("#dtadmemp","#frmCabAtenda").val("' . $cabecalho[5]->cdata . '");';
}
if ( isset($cabecalho[6]->cdata) && isset($cabecalho[7]->cdata) ) {
	echo '$("#nmprimtl","#frmCabAtenda").val("' . $cabecalho[6]->cdata . (trim($cabecalho[7]->cdata) == "" ? "" : " " . $cabecalho[7]->cdata) . '");';
}
if ( isset($cabecalho[8]->cdata) ) {
	echo '$("#dtaltera","#frmCabAtenda").val("' . $cabecalho[8]->cdata . '");';
}
if ( isset($cabecalho[9]->cdata) ) {
	echo '$("#dsnatopc","#frmCabAtenda").val("' . $cabecalho[9]->cdata . '");';
}
if ( isset($cabecalho[10]->cdata) ) {
	echo '$("#nrramfon","#frmCabAtenda").val("' . $cabecalho[10]->cdata . '");';
}
if ( isset($cabecalho[11]->cdata) ) {
	echo '$("#dtdemiss","#frmCabAtenda").val("' . $cabecalho[11]->cdata . '");';
}
if ( isset($cabecalho[12]->cdata) ) {
	echo '$("#dsnatura","#frmCabAtenda").val("' . $cabecalho[12]->cdata . '");';
}
if ( isset($cabecalho[13]->cdata) ) {
	echo '$("#nrcpfcgc","#frmCabAtenda").val("' . $cabecalho[13]->cdata . '");';
}
if ( isset($cabecalho[14]->cdata) ) {
	echo '$("#cdsecext","#frmCabAtenda").val("' . $cabecalho[14]->cdata . '");';
}
if ( isset($cabecalho[15]->cdata) ) {
	echo '$("#indnivel","#frmCabAtenda").val("' . $cabecalho[15]->cdata . '");';
}
if ( isset($cabecalho[16]->cdata) ) {
	echo '$("#dstipcta","#frmCabAtenda").val("' . $cabecalho[16]->cdata . '");';
}
if ( isset($cabecalho[17]->cdata) ) {
	echo '$("#dssitdct","#frmCabAtenda").val("' . $cabecalho[17]->cdata . '");';
}
if ( isset($cabecalho[18]->cdata) ) {
	echo '$("#cdempres","#frmCabAtenda").val("' . $cabecalho[18]->cdata . '");';
}
if ( isset($cabecalho[19]->cdata) ) {
	echo '$("#cdturnos","#frmCabAtenda").val("' . $cabecalho[19]->cdata . '");';
}
if ( isset($cabecalho[20]->cdata) ) {
	echo '$("#cdtipsfx","#frmCabAtenda").val("' . $cabecalho[20]->cdata . '");';
}
if ( isset($cabecalho[21]->cdata) ) {
	echo '$("#nrdconta","#frmCabAtenda").val("' . $cabecalho[21]->cdata . '").formataDado("INTEGER","zzzz.zzz-z","",false);';
}
if ( isset($cabecalho[24]->cdata) ) {
	echo '$("#dssititg","#frmCabAtenda").val("' . $cabecalho[24]->cdata . '");';
}
if ( isset($cabecalho[25]->cdata) ) {
	echo '$("#qttitula","#frmCabAtenda").val("' . $cabecalho[25]->cdata . '");';
}
	if ( isset($cabecalho[27]->cdata) ) {
		$cdsitdct = $cabecalho[27]->cdata;
		echo 'sitaucaoDaContaCrm = "' . $cdsitdct . '";';
	}

	
	// Dados complementares da conta/dv	
if ( isset($compCabecalho[0]->cdata) ) {
	echo '$("#qtdevolu","#frmCabAtenda").val("' . $compCabecalho[0]->cdata . '");';
}
if ( isset($compCabecalho[1]->cdata) && isset( $compCabecalho[2]->cdata) ) {
	echo '$("#qtdddeve","#frmCabAtenda").val("' . $compCabecalho[1]->cdata . '/' . $compCabecalho[2]->cdata . ' dias");';
}
if ( isset($compCabecalho[3]->cdata) ) {
	echo '$("#dtabtcct","#frmCabAtenda").val("' . $compCabecalho[3]->cdata . '");';
}
if ( isset($compCabecalho[4]->cdata) ) {
	echo '$("#ftsalari","#frmCabAtenda").val("' . trim($compCabecalho[4]->cdata) . '");';
}
if ( isset($compCabecalho[5]->cdata) ) {
	echo '$("#vlprepla","#frmCabAtenda").val("' . number_format(str_replace(",", ".", $compCabecalho[5]->cdata), 2, ",", ".") . '");';
}
if ( isset($compCabecalho[6]->cdata) ) {
	echo '$("#qttalret","#frmCabAtenda").val("' . $compCabecalho[6]->cdata . '");';
}
if ( isset($compCabecalho[7]->cdata) ) {
	echo '$("#hdnFlgdig","#frmCabAtenda").val("' . $compCabecalho[7]->cdata . '");';
}
	
	// Monta o xml de requisi&ccedil;&atilde;o
$xml = "";
	$xml .= "<Root>";
	$xml .= "  <Cabecalho>";
	$xml .= "    <Bo>b1wgen0147.p</Bo>";
	$xml .= "    <Proc>dados_bndes</Proc>";
	$xml .= "  </Cabecalho>";
	$xml .= "  <Dados>";
$xml .= "    <cdcooper>" . $glbvars["cdcooper"] . "</cdcooper>";
$xml .= "    <nrdconta>" . $nrdconta . "</nrdconta>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";
			
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlGetBnd = getObjectXML($xmlResult);
	
	// soma valor do saldo de emprestimo com o valor do saldo BNDES
if ( isset($valores[1]->cdata) ) {
	$vlemprst = str_replace(",", ".", str_replace(".", "", $valores[1]->cdata));
}
if ( isset($xmlGetBnd->roottag->tags[0]->attributes['VLSALDOD'] ) ) {
	$vlempbnd = str_replace(",", ".", str_replace(".", "", $xmlGetBnd->roottag->tags[0]->attributes['VLSALDOD']));
}
	$vlemprst = $vlemprst + $vlempbnd;
	
	// soma valor da parcela de emprestimo com a parcela do BNDES
if ( isset($valores[13]->cdata) ) {
	$vlpresta = str_replace(",", ".", str_replace(".", "", $valores[13]->cdata));
}
if ( isset($xmlGetBnd->roottag->tags[0]->attributes['VLPAREPR']) ) {
	$vlrbndes = str_replace(",", ".", str_replace(".", "", $xmlGetBnd->roottag->tags[0]->attributes['VLPAREPR']));
}
$vlpresta = $vlpresta + $vlrbndes;
	
	
	// Monta o xml de requisi&ccedil;&atilde;o
$xmlConsorcio = "";
	$xmlConsorcio .= "<Root>";
	$xmlConsorcio .= "  <Cabecalho>";
	$xmlConsorcio .= "    <Bo>b1wgen0162.p</Bo>";
	$xmlConsorcio .= "    <Proc>indicativo_consorcio</Proc>";
	$xmlConsorcio .= "  </Cabecalho>";
	$xmlConsorcio .= "  <Dados>";
$xmlConsorcio .= "    <cdcooper>" . $glbvars["cdcooper"] . "</cdcooper>";
$xmlConsorcio .= "    <nrdconta>" . $nrdconta . "</nrdconta>";
	$xmlConsorcio .= "  </Dados>";
	$xmlConsorcio .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlConsorcio);
	
	// Cria objeto para classe de tratamento de XML
	$xmlGetConsorcio = getObjectXML($xmlResult);
	
	$flgativo = $xmlGetConsorcio->roottag->tags[0]->attributes['FLGATIVO'];
		
if (isset($cabecalho[23]->cdata) && $cabecalho[23]->cdata == "1") {
    // Monta o xml de requisição
    $xmlFolha = "";
    $xmlFolha .= "<Root>";
    $xmlFolha .= "	<Dados>";
    $xmlFolha .= "		<nrdconta>" . $nrdconta . "</nrdconta>";
    $xmlFolha .= "	</Dados>";
    $xmlFolha .= "</Root>";

    // Executa script para envio do XML
    $xmlResult = mensageria($xmlFolha, "ATENDA", "RECEBE_SALARIO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

    // Cria objeto para classe de tratamento de XML
    $xmlGetFolha = getObjectXML($xmlResult);
    $flgfolha = $xmlGetFolha->roottag->tags[0]->cdata;
}
		
	
		
	// Mostra resumo de dados das rotinas (saldos, situações, etc) ...
	$contRotina = 0;	
	for ($i = 0; $i < count($rotinasTela); $i++) {
	
		switch ($rotinasTela[$i]) {
					
			case "APLICACOES": {
				$nomeRotina = "Aplica&ccedil;&otilde;es"; 
                $urlRotina = "aplicacoes";
                $strValue = ( isset($valores[2]->cdata) ) ? number_format(str_replace(",", ".", $valores[2]->cdata), 2, ",", ".") : '';
				$telaPermitadaAcessoBacen = 1;
				break;
			}
			case "CAPITAL": {
				$nomeRotina = "Capital";
                $urlRotina = "capital";
                $strValue = ( isset($valores[0]->cdata) ) ? number_format(str_replace(",", ".", $valores[0]->cdata), 2, ",", ".") : '';
				$telaPermitadaAcessoBacen = 1;
				break;
			}
			case "CARTAO CRED": {
				$nomeRotina = "Cart&otilde;es de Cr&eacute;dito";  
                $urlRotina = "cartao_credito";
                $strValue = ( isset($valores[14]->cdata) ) ? number_format(str_replace(",", ".", $valores[14]->cdata), 2, ",", ".") : '';
				$telaPermitadaAcessoBacen = 1;
				break;
			}
			case "CONTA INV": {
				$nomeRotina = "Conta Investimento";  
                $urlRotina = "conta_investimento";
                $strValue = ( isset($valores[3]->cdata) ) ? number_format(str_replace(",", ".", $valores[3]->cdata), 2, ",", ".") : '';
				$telaPermitadaAcessoBacen = 0;
				break;
			}
			case "CONVENIOS": {
				$nomeRotina = "Conv&ecirc;nios";           
                $urlRotina = "convenios";
                $strValue = ( isset($valores[8]->cdata) ) ? formataNumericos("zzz.zzz", $valores[8]->cdata, ".") : '';
				$telaPermitadaAcessoBacen = 1;
				break;
			}
			case "DEP. VISTA": {
				$nomeRotina = "Dep&oacute;sitos &agrave; Vista";   
                $urlRotina = "dep_vista";
                $strValue = ( isset($valores[5]->cdata) ) ? number_format(str_replace(",", ".", $valores[5]->cdata), 2, ",", ".") : '';
				$telaPermitadaAcessoBacen = 1;
				break;
			}
			case "DESCONTOS": {
				$nomeRotina = "Descontos"; 
                $urlRotina = "descontos";
                $strValue = ( isset($valores[17]->cdata) ) ? number_format(str_replace(",", ".", $valores[17]->cdata), 2, ",", ".") : '';
				$telaPermitadaAcessoBacen = 0;
				break;
			}
			case "EMPRESTIMOS": {
				$nomeRotina = "Empr&eacute;stimos";         
                $urlRotina = "emprestimos";
                $strValue = number_format(str_replace(",", ".", $vlemprst), 2, ",", ".");
				$telaPermitadaAcessoBacen = 1;
				break;
			}
			case "FICHA CADASTRAL": {
				$nomeRotina = "Ficha Cadastral";
                $urlRotina = "ficha_cadastral";
                $strValue = "";
				$telaPermitadaAcessoBacen = 1;
                break;
            }
     case "CARTAO ASSINATURA": {
				$nomeRotina = "Cart&atilde;o Assinatura"; 
				$urlRotina  = "cartao_assinaturas";
        $strValue   = "";
				$telaPermitadaAcessoBacen = 1;
				break;
			}			
			case "FOLHAS CHEQ": {
				$nomeRotina = "Folhas de Cheque";    
                $urlRotina = "folhas_cheque";
                $strValue = ( isset($valores[7]->cdata) ) ? formataNumericos("zzz.zzz", $valores[7]->cdata, ".") : '';
				$telaPermitadaAcessoBacen = 1;
				break;
			}
			case "INTERNET": {
				$nomeRotina = "Internet";            
                $urlRotina = "internet";
                $strValue = ( isset($valores[12]->cdata) ) ? $valores[12]->cdata : '';
				$telaPermitadaAcessoBacen = 0;
				break;
			}
			case "LAUTOM": {
				$nomeRotina = "Lan&ccedil;amentos Futuros"; 
                $urlRotina = "lancamentos_futuros";
                $strValue = ( isset($valores[11]->cdata) ) ? number_format(str_replace(",", ".", $valores[11]->cdata), 2, ",", ".") : '';
				$telaPermitadaAcessoBacen = 1;
				break;
			}
			case "LIMITE CRED": {
                $nomeRotina = ( isset($cabecalho[23]->cdata) && $cabecalho[23]->cdata == 1 ) ? "Limite de Cr&eacute;dito" : "Limite Empresarial";
                $urlRotina = "limite_credito";
                $strValue = ( isset($valores[6]->cdata) ) ? number_format(str_replace(",", ".", $valores[6]->cdata), 2, ",", ".") : '';
				$telaPermitadaAcessoBacen = 1;
				break;		
			}	
			case "MAGNETICO": {
				$nomeRotina = "Cart&otilde;es Magn&eacute;ticos";  
                $urlRotina = "magneticos";
                $strValue = ( isset($valores[15]->cdata) ) ? $valores[15]->cdata : '';
				$telaPermitadaAcessoBacen = 0;
				break;	
			}
			case "OCORRENCIAS": {
				$nomeRotina = "Ocorr&ecirc;ncias";         
                $urlRotina = "ocorrencias";
                $strValue = ( isset($valores[9]->cdata) ) ? strtolower($valores[9]->cdata) == "yes" ? "SIM" : "NAO" : '';
				$telaPermitadaAcessoBacen = 1;
				break;	
			}
			case "POUP. PROG": {
				$nomeRotina = "Poupan&ccedil;a Programada"; 
                $urlRotina = "poupanca_programada";
                $strValue = ( isset($valores[4]->cdata) ) ? number_format(str_replace(",", ".", $valores[4]->cdata), 2, ",", ".") : '';
				$telaPermitadaAcessoBacen = 1;
				break;	
			}
			case "PRESTACOES": {
				$nomeRotina = "Presta&ccedil;&otilde;es";          
                $urlRotina = "prestacoes";
                $strValue = number_format(str_replace(",", ".", $vlpresta), 2, ",", ".");
				$telaPermitadaAcessoBacen = 1;
				break;	
			}
			case "RELACIONAMENTO": {
				$nomeRotina = "Relacionamento";              
                $urlRotina = "relacionamento";
                $strValue = "";
				$telaPermitadaAcessoBacen = 0;
				break;	
			}
			case "COBRANCA": {
				$nomeRotina = "Cobran&ccedil;a";
                $urlRotina = "cobranca";
                $strValue = strtolower(getByTagName($valores, "flgbloqt")) == "yes" ? "SIM" : "NAO";
				$telaPermitadaAcessoBacen = 0;
				break;
			}
			case "PAGTO POR ARQUIVO": {
				$nomeRotina = "Pagto por Arquivo";
                $urlRotina = "pagamento_titulo_arq";
                $strValue = ($flconven == 1) ? "SIM" : "NAO";
				$telaPermitadaAcessoBacen = 0;
				break;
			}
			case "SEGURO": {
				$nomeRotina = "Seguro";    
				$urlRotina  = "seguro";    
				$strValue   = strtolower(getByTagName ($valores,"flgsegur")) == "yes" ? "SIM" : "NAO"; 
				$telaPermitadaAcessoBacen = 1;
				break;	
			}			
			case "TELE ATEN": {
				$nomeRotina = "Tele Atendimento";    
                $urlRotina = "tele_atendimento";

				$strValue = 'INATIVA';

				if ( isset($valores[10]->cdata) ) {
					$strValue = $valores[10]->cdata;
                }
				
				$telaPermitadaAcessoBacen = 1;
				
				break;	
			}
			case "TELEFONE": {
				$nomeRotina = "Telefone";
                $urlRotina = "telefone";
                $strValue = "";
				$telaPermitadaAcessoBacen = 1;
				break;
			}
			case "CONSORCIO": {
				$nomeRotina = "Cons&oacute;rcio";
                $urlRotina = "consorcio";
                $strValue = strtolower($flgativo) == "yes" ? "SIM" : "NAO";
				$telaPermitadaAcessoBacen = 0;
				break;
			}
			case "LIMITE SAQUE TAA": {
				$nomeRotina = "Limite Saque TAA";
                $urlRotina = "limite_saque_taa";
                $strValue = ( isset($valores[19]->cdata) ) ? number_format(str_replace(",", ".", $valores[19]->cdata), 2, ",", ".") : '';
				$telaPermitadaAcessoBacen = 0;
                break;
            }
			case "SERVICOS COOPERATIVOS": {
				$nomeRotina = "Servi&ccedil;os Cooperativos";
				$urlRotina  = "pacote_tarifas";
				$strValue   = ( isset($valores[20]->cdata) ) ? strtolower($valores[20]->cdata) == 'yes' ? 'SIM' : 'NAO' : 'NAO'; 
				$telaPermitadaAcessoBacen = 0;
				break;
			}
			case "DDA": {
				$nomeRotina = "DDA";
                $urlRotina = "dda";
                $strValue = "";
				$telaPermitadaAcessoBacen = 0;
				break;
			}
			case "CONVENIO CDC": {
				
				$nomeRotina = "Conv&ecirc;nio CDC";
                $urlRotina = "convenio_cdc";
                $strValue = "";
				$telaPermitadaAcessoBacen = 0;
				break;
			}
			case "ATENDIMENTO": {
			
				$nomeRotina = "Atendimento";
                $urlRotina = "atendimento";
                $strValue = "";
				$telaPermitadaAcessoBacen = 1;
				break;
			}		
			case "PRODUTOS": {
					
				$nomeRotina = "Produtos";
                $urlRotina = "produtos";
                $strValue = "";
				$opeProdutos = 1;				
				$telaPermitadaAcessoBacen = 0;				
				break;
			}
        case "RECEBE SALARIO": {
                if (isset($cabecalho[23]->cdata) && $cabecalho[23]->cdata == "1") {
                    $nomeRotina = "Recebe Salario";
                    $urlRotina = "";
                    $strValue = $flgfolha;
                } else {
                    $nomeRotina = " ";
                    $urlRotina = "";
                    $strValue = "";
                }  

				$telaPermitadaAcessoBacen = 1; 

                break;
            }
			case "DESABILITAR OPERACOES": {
			
				$nomeRotina = "Desabilitar Operacoes";
                $urlRotina = "liberar_bloquear";
                $strValue = "";	
				$telaPermitadaAcessoBacen = 0;
				break;
			}	
			case "VALORES A DEVOLVER": {
				$nomeRotina = "Valores a Devolver";  
                $urlRotina = "valores_a_devolver";
                $strValue = ( isset($valores[21]->cdata) ) ? number_format(str_replace(",", ".", $valores[21]->cdata), 2, ",", ".") : '';
				$telaPermitadaAcessoBacen = 1;
				break;
			}
			default: {
				$nomeRotina = "";    
                $urlRotina = "";
                $strValue = "";
				break;
			}
		}	
		
		// Caso o xml retornou uma rotina que não deve ser mostrada no Ayllos Web
		if ($nomeRotina == "") {
			continue;
		}
		
    echo '$("#labelRot' . $contRotina . '").html("' . $nomeRotina . '");';
    echo '$("#valueRot' . $contRotina . '").html("' . $strValue . '");';
		
		if (trim($urlRotina) <> "") {
			
			/*Projeto crm: Não deve permitir a contratação de produtos quando a conta estiver com uma 
			  das situações 4, 7, 8 ou 9. Os produtos que não podem ser contrato quando a conta
			  estiver com uma das situações citada estão identificadas com telaPermitadaAcessoBacen = 0, conforme
			  solicitado pela equipe de negócio. Qualquer alteração na lógica abaixo ou com a inclusão de novo produtos
			  na tela ATENDA, deverá ser verificado junto a área de negócio.
			  A validação abaixo será liberada em Janeiro/2018.
			if(($cdsitdct == '4' || 
			    $cdsitdct == '7' || 
				$cdsitdct == '8') && 
				$telaPermitadaAcessoBacen == 0 ){
				
			    echo '$("#labelRot'.$contRotina.'").unbind("click");';
				echo '$("#labelRot'.$contRotina.'").bind("click",function() { showError("inform", "Cooperado est&aacute; em processo de demiss&atilde;o.", "Alerta - Ayllos", ""); });';
				echo '$("#valueRot'.$contRotina.'").unbind("click");';
				echo '$("#valueRot'.$contRotina.'").bind("click",function() { showError("inform", "Cooperado est&aacute; em processo de demiss&atilde;o.", "Alerta - Ayllos", ""); });';	
				
			}else{
			*/
				echo '$("#labelRot'.$contRotina.'").unbind("click");';
				echo '$("#labelRot'.$contRotina.'").bind("click",function() { acessaRotina("#labelRot'.$contRotina.'","'.$rotinasTela[$i].'","'.$nomeRotina.'","'.$urlRotina.'","'.$opeProdutos.'"); nmrotina = "'.$nomeRotina.'"; });';
				echo '$("#valueRot'.$contRotina.'").unbind("click");';
				echo '$("#valueRot'.$contRotina.'").bind("click",function() { acessaRotina("#labelRot'.$contRotina.'","'.$rotinasTela[$i].'","'.$nomeRotina.'","'.$urlRotina.'","'.$opeProdutos.'"); nmrotina = "'.$nomeRotina.'"; });';		
				
			/*}
			*/

		}
		
		$contRotina++;
	}	
	

	// Flag para acesso a rotinas
	echo 'flgAcessoRotina = true;';
	
	// Variáveis globais
$vr_nrdconta = ( isset($cabecalho[21]->cdata) ) ? $cabecalho[21]->cdata : 0;
echo 'nrdconta = "' . $vr_nrdconta . '";';

$vr_nrdctitg = ( isset($cabecalho[3]->cdata)   ) ? $cabecalho[3]->cdata : 0;
echo 'nrdctitg =	"' . $vr_nrdctitg . '";';

$vr_inpessoa =  ( isset($cabecalho[23]->cdata) ) ? $cabecalho[23]->cdata : 0;
echo 'inpessoa = "' . $vr_inpessoa . '";';

$vr_cdclcnae = ( isset($cabecalho[26]->cdata) ) ? $cabecalho[26]->cdata : 0;
echo 'cdclcnae = "' . $vr_cdclcnae  . '";';
	
	// Variável que indica se deve mostrado div de mensagens ou anotações
	$flgMsgAnota = false;
	
	if ($glbvars["nmrotina"] == "") {
		// Monta HTML para mostrar mensagens de alerta
		if (count($mensagens) > 0 && $flgProdutos != 'true') {	
			$flgMsgAnota = true;
			
			echo 'var strHTML = \'<table width="445" border="0" cellpadding="1" cellspacing="2">\';';
			
			$style = "";
		
			for ($i = 0; $i < count($mensagens); $i++) {		
				if ($style == "") {
					$style = ' style="background-color: #FFFFFF;"';
				} else {
					$style = "";
				}	
																																			
            echo 'strHTML += \'<tr' . $style . '>\';';
			$vr_txtmsg = ( isset($mensagens[$i]->tags[1]->cdata) ) ? addslashes($mensagens[$i]->tags[1]->cdata) : '';
            echo 'strHTML += \'<td class="txtNormal"><textarea style="width: 455px; height: 40px; resize: none" readonly>' . removeCaracteresInvalidos(retiraAcentos($vr_txtmsg)) . '</textarea></td>\';';
				echo 'strHTML += \'</tr>\';';															
			}
		
			echo 'strHTML += \'</table>\';';
			
			// Coloca conteúdo HTML no div
			echo '$("#divListaMsgsAlerta").html(strHTML);';
		
			// Mostra div 
			echo '$("#divMsgsAlerta").css("visibility","visible");';
			
			// Esconde mensagem de aguardo
			echo 'hideMsgAguardo();';	
			
			// Bloqueia conteúdo que está átras do div de mensagens
			echo 'blockBackground(parseInt($("#divMsgsAlerta").css("z-index")));';
		} 
		
		// Mostra anotações da conta
		if (count($anotacoes) > 0 && $flgProdutos != 'true') { 
        // valida a existencia do node
		$vr_nrdanot = ( isset($cabecalho[21]->cdata) ) ? formataNumericos("zzz.zzz.zz9-9", $cabecalho[21]->cdata, ".-")  : '';
			// Aqui mostrar conteúdo das anotações
        echo '$("#nroconta","#frmAnotacoes").val("' . $vr_nrdanot . '");';
		//valida a existencia do node
		$vr_nmprim = ( isset($cabecalho[6]->cdata)   ) ? $cabecalho[6]->cdata : '';
        echo '$("#nmprimtl","#frmAnotacoes").val("' . $vr_nmprim . '");';
			
			// Monta HTML para mostrar mensagens de alerta
			echo 'var strHTML = "";';			
			echo 'strHTML += \'<table cellpadding="0" cellspacing="0" border="0">\';';
			
        for ($i = 0; $i < count($anotacoes); $i++) {
            if ($i != 0) {
					echo 'strHTML += \'	<tr>\';';
					echo 'strHTML += \'	  <td height="5></td>\';';
					echo 'strHTML += \'	</tr>\';';
					echo 'strHTML += \'	<tr>\';';
					echo 'strHTML += \'		<td height="1" style="background-color: #666666;"></td>\';';
					echo 'strHTML += \'	</tr>\';';
					echo 'strHTML += \'	<tr>\';';
					echo 'strHTML += \'	  <td height="5"></td>\';';
					echo 'strHTML += \'	</tr>\';';
				} 
				
			$vr_dtmvtolt = ( isset($anotacoes[$i]->tags[1]->cdata) )   ? $anotacoes[$i]->tags[1]->cdata : '';
			$vr_hrtransa = ( isset($anotacoes[$i]->tags[10]->cdata) ) ? $anotacoes[$i]->tags[10]->cdata : '';
			$vr_dsopera = ( isset($anotacoes[$i]->tags[11]->cdata) ) ? $anotacoes[$i]->tags[11]->cdata : '';

				echo 'strHTML += \'	<tr>\';';
				echo 'strHTML += \'		<td>\';';
				echo 'strHTML += \'			<table cellpadding="0" cellspacing="0" border="0">\';';
				echo 'strHTML += \'				<tr>\';';
				echo 'strHTML += \'					<td width="25" height="25" class="txtNormalBold">Em&nbsp;</td>\';';
				echo 'strHTML += \'					<td width="67"><input name="dtmvtolt" type="text" class="campoTelaSemBorda classDisabled" id="dtmvtolt" value="'.date_format(date_create($anotacoes[$i]->tags[1]->cdata),'d/m/Y').'" style="width: 67px; text-align: center;"></td>\';';
				echo 'strHTML += \'					<td width="30" align="center" class="txtNormalBold">&agrave;s&nbsp;</td>\';';
            echo 'strHTML += \'					<td width="67"><input name="hrtransa" type="text" class="campoTelaSemBorda classDisabled" id="hrtransa" value="' . $vr_hrtransa . '" style="width: 67px; text-align: center"></td>\';';
				echo 'strHTML += \'					<td width="35" align="center" class="txtNormalBold">por&nbsp;</td>\';';
            echo 'strHTML += \'					<td><input name="dsoperad" type="text" class="campoTelaSemBorda classDisabled" id="dsoperad" value="' . $vr_dsopera . '" style="width: 230px;"></td>\';';
				echo 'strHTML += \'				</tr>\';';
				echo 'strHTML += \'			</table>\';';
				echo 'strHTML += \'		</td>\';';
				echo 'strHTML += \'</tr>\';';
				
            if ( isset($anotacoes[$i]->tags[5]->cdata) && $anotacoes[$i]->tags[5]->cdata == "yes")  {
					echo 'strHTML += \'	<tr>\';';
					echo 'strHTML += \'		<td>\';';
					echo 'strHTML += \'			<table cellpadding="0" cellspacing="0" border="0">\';';
					echo 'strHTML += \'				<tr>\';';
					echo 'strHTML += \'					<td height="25" class="txtNormalBold">** MENSAGEM PRIORIT&Aacute;RIA **</td>\';';
					echo 'strHTML += \'				</tr>\';';
					echo 'strHTML += \'			</table>\';';
					echo 'strHTML += \'		</td>\';';
					echo 'strHTML += \'	</tr>\';';
				}
				
			$vr_dsanotas = ( isset($anotacoes[$i]->tags[6]->cdata) ) ? str_replace("\n", "\\n", addslashes($anotacoes[$i]->tags[6]->cdata)) : '';

				echo 'strHTML += \'	<tr>\';';
				echo 'strHTML += \'		<td>\';';
				echo 'strHTML += \'			<table cellpadding="0" cellspacing="0" border="0">\';';		
				echo 'strHTML += \'				<tr>\';';
            echo 'strHTML += \'					<td><textarea name="dsanotas" style="width: 455px; height: 152px;" readonly>' . $vr_dsanotas . '</textarea></td>\';';
				echo 'strHTML += \'				</tr>\';';
				echo 'strHTML += \'			</table>\';';
				echo 'strHTML += \'		</td>\';';
				echo 'strHTML += \'	</tr>\';';
			} // Fim do for
			 
			echo 'strHTML += \'</table>\';';
			
			// Coloca conteúdo HTML no div
			echo '$("#divListaAnotacoes").html(strHTML);';
			
			echo '$("input, select", "#frmAnotacoes").desabilitaCampo();';
			echo '$("input, select", ".classDisabled").desabilitaCampo();';
						
			if ($flgMsgAnota) {
				// Variável javascript que indica se deve ser mostrada anotações logo após as mensagens
				echo 'flgMostraAnota = true;';
			} else {
				$flgMsgAnota = true;
				
				// Mostra div 
				echo '$("#divAnotacoes").css("visibility","visible");';
				
				echo '$("#btnAnotaSair").focus();'; 
				
				// Esconde mensagem de aguardo
				echo 'hideMsgAguardo();';	
				
				// Bloqueia conteúdo que está átras do div de anotações
				echo 'blockBackground(parseInt($("#divAnotacoes").css("z-index")));';		
			}
		}
	} else {
		// Limpa o nome da rotina para uso do F2		
    setVarSession("nmrotina", "");
	}
	
	if (!$flgMsgAnota) {	
		// Esconde mensagem de aguardo
		echo 'hideMsgAguardo();';	
	}
?>