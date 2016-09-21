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
	$xmlRegistro .= "	<Cabecalho>";
	$xmlRegistro .= "		<Bo>b1wgen0155.p</Bo>";
	$xmlRegistro .= "		<Proc>busca-contas-cooperado</Proc>";
	$xmlRegistro .= "	</Cabecalho>";
	$xmlRegistro .= "	<Dados>";
    $xmlRegistro .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlRegistro .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlRegistro .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlRegistro .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlRegistro .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlRegistro .= "		<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";
	$xmlRegistro .= "		<dtmvtoan>".$glbvars["dtmvtoan"]."</dtmvtoan>";	
	$xmlRegistro .= "		<dtiniper>".date("d/m/Y")."</dtiniper>";
	$xmlRegistro .= "		<dtfimper>".date("d/m/Y")."</dtfimper>";
	$xmlRegistro .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlRegistro .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlRegistro .= "		<idseqttl>1</idseqttl>";
	$xmlRegistro .= "		<inproces>".$glbvars["inproces"]."</inproces>";

	$xmlRegistro .= "		<cooperad>".$cooperad."</cooperad>";
	$xmlRegistro .= "	</Dados>";
	$xmlRegistro .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlRegistro);
		
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
		$tabela .=			"<tr>";
		$tabela .=				"<th align=\'CENTER\'>CONTA/DV</th>";
		$tabela .=				"<th colspan=\'" . $cdtppesq . "\' align=\'CENTER\'>MODALIDADES</th>";
		$tabela .=			"</tr>";
        $tabela .=			"<tr>";
        $tabela .=				"<td>&nbsp;</td>";
		if ($cdtppesq == 1) { $tabela .=				"<th align=\'CENTER\'>Capital</th>";}
		if ($cdtppesq == 4) { $tabela .=				"<th align=\'CENTER\'>Aplica&ccedil;&atilde;o</th>";
                              $tabela .=				"<th align=\'CENTER\'>Conta Corrente</th>";
                              $tabela .=				"<th align=\'CENTER\'>Poupan&ccedil;a Programada</th>";
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