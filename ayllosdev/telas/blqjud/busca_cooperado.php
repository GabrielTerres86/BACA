<?php 
	
	//************************************************************************//
	//*** Fonte: busca_cooperado.php                                       ***//
	//*** Autor: Guilherme/Supero                                          ***//
	//*** Data : Abril/2013                   Última Alteração: 10/12/2014 ***//
	//***                                                                  ***//
	//*** Objetivo  : Buscar a(s) conta(s) e nome do cooperado com base    ***//
	//***             no numero de uma conta ou CPF/CGC.                   ***// 
	//***                                                                  ***//
	//*** Alterações: 19/12/2013 - Alterada mensagem de erro ao nao		   ***// 
	//***						   encontrar cooperado, de "CPF/CGC"	   ***//
	//***						   para "CPF/CNPJ". (Reinert)			   ***//
	//***                          								           ***//
	//***            08/12/2014 - Ajustado divContas pois com versoes do ie **//
	//***                          10 ou superior nao funcionava           ***//
	//***						   (Lucas R. #229878)                      ***//
	//***                          								           ***//
	//***            10/12/2014 - Adicionado vreificacao do valor, caso venha*//
	//***                         com valor 0, desabilita o checkbox       ***//
	//***						   (Jorge/Rosangela) - SD 228463           ***//
	//***                                                                  ***//
	//***            26/07/2016 - Subtrair os valores bloqueados           ***//
	//***						  do valor total apresentado para bloqueio ***//
	//***						  judicial. Chamado 491832 (Heitor - RKAM) ***//
	//***					                                               ***//
	//***			 31/10/2016 - Realizar a chamada da rotina busca-contas-**//
	//***					      cooperado diretamente do oracle via      ***//
	//***					      mensageria (Renato Darosci - Supero)     ***//
	//***					    - Alterado html de retorno, para que o     ***//
	//***					      mesmo apresente cores nas linhas e um    ***//
	//***					      cabeçalho destacado (Renato Darosci)     ***//
	//***					                                               ***//
	//***			 04/11/2016 - Retirar os parametros fixos e as datas   ***//
	//***					      que deverão ser lidas da crapdat na      ***//
	//***					      rotina (Renato Darosci - Supero)         ***//
	//***					                                               ***//
	//***			 27/08/2018 - Incluido opção de utilizar saldo bloqueado***//
	//***					      prejuizo para bloqueio judicial          ***//
	//***					      PRJ450 - (Odirlei - AMcom)               ***//
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");
	
	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	
	$cooperad = $_POST["nrdconta"];
    $cdtppesq = $_POST["cdtppesq"];
	$cddopcao = $_POST["cddopcao"];

	// Monta o xml de requisição
	$xmlRegistro  = "";
	$xmlRegistro .= "<Root>";
	$xmlRegistro .= "	<Dados>";
    $xmlRegistro .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlRegistro .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlRegistro .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlRegistro .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlRegistro .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlRegistro .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlRegistro .= "		<inproces>".$glbvars["inproces"]."</inproces>";
	$xmlRegistro .= "		<cooperad>".$cooperad."</cooperad>";
	$xmlRegistro .= "	</Dados>";
	$xmlRegistro .= "</Root>";
	
	$xmlResult = mensageria($xmlRegistro, "BLQJUD", "CONTAS_COOPERADO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

	// Cria objeto para classe de tratamento de XML
	$xmlObjRegistro = getObjectXML($xmlResult);
		
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjRegistro->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjRegistro->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
	
    $registros = $xmlObjRegistro->roottag->tags[0]->tags;
    $qtRegistros = count($registros);

	$nmprimtl = $xmlObjRegistro->roottag->tags[0]->attributes["NMPRIMTL"];
	
	echo 'cNmprimtl.val("'. $nmprimtl.'");';

    if ($qtRegistros > 0) {
    
       
		$tabela =	"<div class=\'divContas\'  ";
        $tabela .=	"<form id=\'frmContas\' name=\'frmContas\' class=\'formulario\'  onsubmit=\'return false;\' >";
        $tabela .= "<fieldset>";
        $tabela .= "<legend>Contas do Associado</legend>";
		$tabela .= "<br />";
		$tabela .=  "<label for=\'vlsaldo\'>".utf8ToHtml('Saldo a Bloquear/Transferir:')."</label>";
        $tabela .=  "<input id=\'vlsaldo\' name=\'vlsaldo\' type=\'text\' maxlength=\'12\' disabled /> <br /><br />";
		$tabela .= 	"<table WIDTH=\'100%\'>";
		$tabela .=		"<thead>";
		$tabela .=			"<tr style=\'background-color:#f7d3ce;\'>";
		$tabela .=				"<th rowspan=\'2\' align=\'CENTER\'>CONTA/DV</th>";
		$tabela .=				"<th colspan=\'" . $cdtppesq . "\' align=\'CENTER\'>MODALIDADES</th>";
		$tabela .=			"</tr>";
        $tabela .=			"<tr style=\'background-color:#f7d3ce;\'>";
        //$tabela .=				"<td>&nbsp;</td>";
		if ($cdtppesq == 1) { $tabela .=				"<th align=\'CENTER\'>Capital</th>";}
		if ($cdtppesq == 4) { $tabela .=				"<th align=\'CENTER\'>Aplica&ccedil;&atilde;o</th>";
                              $tabela .=				"<th align=\'CENTER\'>Conta Corrente</th>";
                              $tabela .=				"<th align=\'CENTER\'>Aplica&ccedil;&atilde;o Programada</th>";
                              $tabela .=				"<th align=\'CENTER\'>Bloqueado Preju&iacute;zo</th>";
                            }
		$tabela .=			"</tr>";
		$tabela .=		"</thead>";
		$tabela .=		"<tbody>";
        for ($i = 0; $i < $qtRegistros; $i++) {
			$cdcooper = getByTagName($registros[$i]->tags,'cdcooper');
            $nrdconta = getByTagName($registros[$i]->tags,'nrdconta');
            $nrcpfcgc = getByTagName($registros[$i]->tags,'nrcpfcgc');
			
			// Buscar os valores bloqueados para subtrair do valor total
			// Monta o xml de requisição
			$xmlGetDepVista  = "";
			$xmlGetDepVista .= "<Root>";
			$xmlGetDepVista .= "	<Cabecalho>";
			$xmlGetDepVista .= "		<Bo>b1wgen0001.p</Bo>";
			$xmlGetDepVista .= "		<Proc>obtem-saldos-anteriores</Proc>";
			$xmlGetDepVista .= "	</Cabecalho>";
			$xmlGetDepVista .= "	<Dados>";
			$xmlGetDepVista .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
			$xmlGetDepVista .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
			$xmlGetDepVista .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
			$xmlGetDepVista .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
			$xmlGetDepVista .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
			$xmlGetDepVista .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
			$xmlGetDepVista .= "		<nrdconta>".$nrdconta."</nrdconta>";
			$xmlGetDepVista .= "		<idseqttl>1</idseqttl>";
			$xmlGetDepVista .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";	
			$xmlGetDepVista .= "		<dtmvtolt>".$glbvars["dtmvtoan"]."</dtmvtolt>";	
			$xmlGetDepVista .= "		<dtrefere>".$glbvars["dtmvtoan"]."</dtrefere>";
			$xmlGetDepVista .= "	</Dados>";
			$xmlGetDepVista .= "</Root>";
			
			// Executa script para envio do XML
			$xmlResult = getDataXML($xmlGetDepVista);

			// Cria objeto para classe de tratamento de XML
			$xmlGetDepVista = getObjectXML($xmlResult);

			// Se ocorrer um erro, mostra crítica
			if (strtoupper($xmlGetDepVista->roottag->tags[0]->name) == "ERRO") {
				exibeErro($xmlGetDepVista->roottag->tags[0]->tags[0]->tags[4]->cdata);
			}
			
			$depvista = $xmlGetDepVista->roottag->tags[0]->tags[0]->tags;
			
			$vlsdbloq = str_replace(",",".",getByTagName($depvista,'vlsdbloq'));
			$vlsdblpr = str_replace(",",".",getByTagName($depvista,'vlsdblpr'));
			$vlsdblfp = str_replace(",",".",getByTagName($depvista,'vlsdblfp'));
			// Fim Buscar os valores bloqueados para subtrair do valor total
			
            $vlaplica = str_replace(",",".",getByTagName($registros[$i]->tags,'vlsldapl'));
			$vlcapita = str_replace(",",".",getByTagName($registros[$i]->tags,'vlsldcap'));
			$vlctacor = max(str_replace(",",".",getByTagName($registros[$i]->tags,'vlstotal')) - $vlsdbloq - $vlsdblpr - $vlsdblfp,0);
			$vlpoupan = str_replace(",",".",getByTagName($registros[$i]->tags,'vlsldppr'));
                                                                                             
            
            //Busca Saldo atual da conta transitória
            $xml  = "";
            $xml .= "<Root>";
            $xml .= "  <Dados>";
            $xml .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
            $xml .= "    <nrdconta>".$nrdconta."</nrdconta>";	
            $xml .= "  </Dados>";
            $xml .= "</Root>";

            $xmlResult = mensageria($xml, "PREJ0003", "CONSULTAR_SLDPRJ", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
            $xmlObjeto = getObjectXML($xmlResult);

            $param = $xmlObjeto->roottag->tags[0]->tags[0];

            if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
                exibeErro($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
                //('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',"controlaOperacao('');",false);
            }else{
                // Buscar saldo bloqueado prejuizo
                $vlblqprj = getByTagName($param->tags,'saldo');		
            }
                                                                                             
            $idchkbox = 'chk-cta';
            $nmchkbox = $cdcooper. '-'. $nrdconta. '-'. $nrcpfcgc;
        
            $tabela .=		"<tr>";
            $tabela .=			"<td align=\'center\'>";
            $tabela .=				 formataContaDV($nrdconta);
            $tabela .=			"</td>";
       
        if ($cdtppesq == 1) { 
            $tabela .=			"<td align=\'center\'>";
            $tabela .=				 "R$ ". formataMoeda($vlcapita);
            $tabela .=			"</td>";
        }
        if ($cdtppesq == 4) { 
            $tabela .=			"<td align=\'center\'>";
            $tabela .=				 "R$ ". formataMoeda($vlaplica);
            $tabela .=			"</td>";
            $tabela .=			"<td align=\'center\'>";
            $tabela .=				 "R$ ". formataMoeda($vlctacor);
            $tabela .=			"</td>";
            $tabela .=			"<td align=\'center\'>";
            $tabela .=				 "R$ ". formataMoeda($vlpoupan);
            $tabela .=			"</td>";
            //Bloqueado Prejuizo
            $tabela .=			"<td align=\'center\'>";
            $tabela .=				 "R$ ". formataMoeda($vlblqprj);
            $tabela .=			"</td>";
        }
            $tabela .=		"</tr>";
            $tabela .=		"<tr>";
            $tabela .=			"<td>&nbsp;";
            $tabela .=			"</td>";
        if ($cdtppesq == 1) {    
            $tabela .=			"<td style=\'text-align:center;\'>";
            $tabela .=			    "<input type=\'checkbox\' style=\'float:none;\' id=\'" . $idchkbox . "\' name=\'4-" . $nmchkbox . "\' value=\'" . $vlcapita ."\' onClick=\'atualizaSaldo(this);\' />";
            $tabela .=			"</td>";
        }
        if ($cdtppesq == 4) { 
            $tabela .=			"<td style=\'text-align:center;\'>";
            $tabela .=			    "<input type=\'checkbox\' style=\'float:none;\' id=\'" . $idchkbox . "\' name=\'2-" . $nmchkbox . "\' value=\'" . $vlaplica ."\' onClick=\'atualizaSaldo(this);\' />";
            $tabela .=			"</td>";
            $tabela .=			"<td style=\'text-align:center;\'>";
            $tabela .=			    "<input type=\'checkbox\' style=\'float:none;\' id=\'" . $idchkbox . "\' name=\'1-" . $nmchkbox . "\' value=\'" . $vlctacor ."\' onClick=\'atualizaSaldo(this);\' />";
            $tabela .=			"</td>";
            $tabela .=			"<td style=\'text-align:center;\'>";
            $tabela .=			    "<input type=\'checkbox\' style=\'float:none;\' id=\'" . $idchkbox . "\' name=\'3-" . $nmchkbox . "\' value=\'" . $vlpoupan ."\' onClick=\'atualizaSaldo(this);\' />";
            $tabela .=			"</td>";
            //Bloqueado Prejuizo
            $tabela .=			"<td style=\'text-align:center;\'>";
            $tabela .=			    "<input type=\'checkbox\' style=\'float:none;\' id=\'" . $idchkbox . "\' name=\'5-" . $nmchkbox . "\' value=\'" . $vlblqprj ."\' onClick=\'atualizaSaldo(this);\' />";
            $tabela .=			"</td>";
            
        }
            $tabela .=		"</tr>";
            
        }
		$tabela .=		"</tbody>";
		$tabela .=	"</table>";
        $tabela .=	"</form>";
		$tabela .=	"</div>";
        $tabela .= "</fieldset>";

        echo "$('#divResultado').html('".$tabela."');"; 
		
        //monta layout da tabela
		if ($cddopcao == 'T') {
			echo "$('#divResultado').hide();";
			echo "controlaBotoes(3);";
			echo "hideMsgAguardo();";
		} else {
			// mostra o div com a tabela
			echo "$('#divResultado').show();";
			echo "$('#divBotoes').css({'display':'block'});";
			echo "$('#nrdconta','#frmAssociado').desabilitaCampo();";
			echo "$('label[for=\\\"vlsaldo\\\"]' ,'#frmContas').addClass('rotulo').css({'width':'165px'});";
			echo "$('#vlsaldo','#frmContas').val($('#vlbloque','#frmAcaojud').val());";
			echo "$('#vlsaldo','#frmContas').addClass('campoTelaSemBorda').addClass('monetario').addClass('descricao').css({'width':'100px','text-align':'right'});";
			echo "controlaBotoes(3);";
			echo "arrBloquear.length = 0;";
			echo "hideMsgAguardo();";
		}
    }
    else {
        echo "$('#divResultado').html('');";
        echo 'cNmprimtl.val("");';
        
        $msgerr = substr($nmprimtl, 0, 5);

        $nmprimtl = str_replace($msgerr . ' - ','', $nmprimtl);
        if ( $msgerr == 'RSPLG') {        
            echo "showError('error','" . $nmprimtl. "','Alerta - BLQJUD','focaCampoErro(\'nrdconta\',\'frmInclusao\');focaCampoErro(\'nrdconta\',\'frmAssociado\');hideMsgAguardo();');";
        }
        else {
            echo "showError('error','Conta/dv ou CPF/CNPJ não encontrado .','Alerta - BLQJUD','focaCampoErro(\'nrdconta\',\'frmInclusao\');focaCampoErro(\'nrdconta\',\'frmAssociado\');hideMsgAguardo();');";            
        }
    }
     
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos");';
		exit();
	}
	
?>