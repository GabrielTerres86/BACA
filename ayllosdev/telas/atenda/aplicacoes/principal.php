<?php 

	/************************************************************************
	 Fonte: principal.php                                             
	 Autor: David                                                     
	 Data : Setembro/2009                Última Alteração: 01/12/2017 
	                                                                  
	 Objetivo  : Mostrar opcao Principal da rotina de Aplicações da   
	             tela ATENDA                                          
	                                                                  	 
	 Alterações: 04/10/2010 - Adaptação para novas opções Incluir,    
	                          Alterar e Excluir (David).              
																	   
	             01/12/2010 - Alterado a chamda da BO b1wgen0004.p    
	                          para a BO b1wgen0081.p (Adriano).       
    																   
                 01/09/2012 - Inclusao do principal_imprimir.php      
	                          (Guilherme/Supero).                     
																	   
                 04/06/2013 - Incluir ajustes bloqueio judicial       
	                          (Lucas R).  

				 30/04/2014 - Ajustes referente ao projeto captação 
							 (Adriano).

			     24/07/2014 - Ajustes referente ao projeto captação, inclusao
							  de novas condicoes para verificar se é produto
							  novo ou antigo (Jean Michel).
							  
				 26/12/2014 - Ajuste para corrigir o problema de permitir 
                              o cadastro de aplicações com data de    
                              vencimento errada (SD - 237402)		
  						     (Adriano).	

				 21/07/2016 - Inicializei a varivale $xml, tratei o retorno do XML "ERRO"
							  consisti os indices do XML retornados. SD 479874 (Carlos R.)
							  
			     01/12/2017 - Não permitir acesso a opção de incluir quando conta demitida (Jonata - RKAM P364).
		    
				 27/11/2017 - Inclusao do valor de bloqueio em garantia.
                              PRJ404 - Garantia(Odirlei-AMcom)              
		    
	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se número da conta foi informado
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$sitaucaoDaContaCrm = (isset($_POST['sitaucaoDaContaCrm']) ? $_POST['sitaucaoDaContaCrm']:'');
	$nrdconta = $_POST["nrdconta"];

	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Montar o xml de Requisicao
	$xml = '';
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <idseqttl>1</idseqttl>";
	$xml .= "   <nraplica>0</nraplica>";
    $xml .= "   <cdprodut>0</cdprodut>";
    $xml .= "   <idconsul>6</idconsul>";	
	$xml .= "   <idgerlog>1</idgerlog>";	
	$xml .= " </Dados>";
	$xml .= "</Root>";
		
	$xmlResult = mensageria($xml, "ATENDA", "LISAPLI", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	//$xmlObjAplicacoes = getObjectXML($xmlResult);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjAplicacoes = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (isset($xmlObjAplicacoes->roottag->tags[0]->name) && strtoupper($xmlObjAplicacoes->roottag->tags[0]->name) == "ERRO") {
		
		$msgErro = ( isset($xmlObjAplicacoes->roottag->tags[0]->cdata) ) ? $xmlObjAplicacoes->roottag->tags[0]->cdata : '';
		if($msgErro == null || $msgErro == ''){
			$msgErro = ( isset($xmlObjAplicacoes->roottag->tags[0]->tags[0]->tags[4]->cdata) ) ? $xmlObjAplicacoes->roottag->tags[0]->tags[0]->tags[4]->cdata : '';
		}
		
		exibeErro($msgErro);		
	} 
	
	//$aplicacoes   = $xmlObjAplicacoes->roottag->tags[0]->tags;	
	$aplicacoes   = $xmlObjAplicacoes->roottag->tags;	
	$qtAplicacoes = count($aplicacoes);
	
	// Procura indíce da opção "@"
	$idPrincipal = array_search("@",$glbvars["opcoesTela"]);
	
	if ($idPrincipal === false) {
		$idPrincipal = 0;
	}		
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","encerraRotina(true); blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}

		// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0155.p</Bo>";
	$xml .= "		<Proc>retorna-valor-blqjud</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<nrcpfcgc>0</nrcpfcgc>";
	$xml .= "		<cdtipmov>0</cdtipmov>";
	$xml .= "		<cdmodali>2</cdmodali>";
	$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
		// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjBlqJud = getObjectXML($xmlResult);
	
	$vlbloque = $xmlObjBlqJud->roottag->tags[0]->attributes['VLBLOQUE']; 
  
  // Montar o xml de Requisicao
	$xml = '';
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0155.p</Bo>";
	$xml .= "		<Proc>retorna-sld-conta-invt</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= " <Dados>";
	$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjSldContInesvest = getObjectXML($xmlResult);
	
	$vlsldinv = $xmlObjSldContInesvest->roottag->tags[0]->attributes['VLRESBLQ'];
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjBlqJud->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjBlqJud->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 	
	
    
	$xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "  <nrdconta>".$nrdconta."</nrdconta>";    
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "BLOQ0001", "CALC_BLOQ_GARANTIA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        if ($msgErro == "") {
            $msgErro = $xmlObj->roottag->tags[0]->cdata;
        }

        exibeErro($msgErro);
        exit();
    }

    $registros = $xmlObj->roottag->tags[0]->tags;
    $vlblqapl  = getByTagName($registros, 'vlblqapl');   
    
    
	include('principal_tabela.php');
	include('principal_dados.php');
	include('principal_resgate.php');
	include('principal_resgatar_varias.php');
	include('principal_acumula.php');
	include('principal_imprimir.php');
	include('principal_opcoes.php');	
	
?>

<script type="text/javascript">
	
	controlaLayout();
			
	// Aumenta tamanho do div onde o conteúdo da opção será visualizado
	$("#divConteudoOpcao").css("height","280px");

	$("#btnVoltar").unbind("click");
	$("#btnVoltar").bind("click",function() {
		if (flgoprgt) {
			acessaOpcaoAba(<?php echo count($glbvars["opcoesTela"]); ?>,<?php echo $idPrincipal; ?>,'<?php echo $glbvars["opcoesTela"][$idPrincipal]; ?>');		
		} else {
			voltarDivPrincipal();
		}
		
		return false;
	});

	$("#btnVoltar2").unbind("click");
	$("#btnVoltar2").bind("click",function() {
		if (flgoprgt) {
			acessaOpcaoAba(<?php echo count($glbvars["opcoesTela"]); ?>,<?php echo $idPrincipal; ?>,'<?php echo $glbvars["opcoesTela"][$idPrincipal]; ?>');		
		} else {
			voltarDivPrincipal();
		}
		
		return false;
	}); 

	$("#tpaplica","#frmDadosAplicacao").unbind("blur");
	$("#tpaplica","#frmDadosAplicacao").bind("blur",function(event,fnc) {	
		verificaTipoAplicacao(fnc);		
	});
	
	$("#tpaplica","#frmDadosAplicacao").bind("change blur",function() {	
		
		cdperapl = 0;
		str = $(this).val();		
		var strValorApl = new Array();
		strValorApl = str.split(',',3);
		codProduto = strValorApl[0];
		tipoAplica = strValorApl[1];
		tipoProdut = strValorApl[2];
		
		if (tipoProdut == 'N'){
			cFlgrecnoPos.show();
			rFlgrecnoPos.show();
			$("#divConteudoOpcao").css("height","310px");
			$('#frmDadosAplicacaoPre').css('display','none');
			$('#frmDadosAplicacaoPos').css('display','block');
			$("#qtdiaapl","#frmDadosAplicacaoPos").val("0");
			$("#dtresgat","#frmDadosAplicacaoPos").val("");
			$("#qtdiacar","#frmDadosAplicacaoPos").val("0");
			$("#dtcarenc","#frmDadosAplicacaoPos").val("");
			$("#vllanmto","#frmDadosAplicacaoPos").val("0");			
			$("#txaplica","#frmDadosAplicacaoPos").val("000,00000000");
			$("#dsaplica","#frmDadosAplicacaoPos").val("");
		}else if(tipoProdut == 'A'){
			cFlgrecnoPos.hide();
			rFlgrecnoPos.hide();
			$("#divConteudoOpcao").css("height","290px");
		/*RDCPRE*/
			if(codProduto == 7){
				$('#frmDadosAplicacaoPos').css('display','none');
				$('#frmDadosAplicacaoPre').css('display','block');
				$("#qtdiaapl","#frmDadosAplicacaoPre").val("0");
				$("#dtresgat","#frmDadosAplicacaoPre").val("");
				$("#qtdiacar","#frmDadosAplicacaoPre").val("0");
				$("#vllanmto","#frmDadosAplicacaoPre").val("0");
				$("#txaplica","#frmDadosAplicacaoPre").val("000,00000000");			
			}else{
				$('#frmDadosAplicacaoPre').css('display','none');
				$('#frmDadosAplicacaoPos').css('display','block');
				$("#qtdiaapl","#frmDadosAplicacaoPos").val("0");
				$("#dtresgat","#frmDadosAplicacaoPos").val("");
				$("#qtdiacar","#frmDadosAplicacaoPos").val("0");
				$("#dtcarenc","#frmDadosAplicacaoPos").val("");
				$("#vllanmto","#frmDadosAplicacaoPos").val("0");			
				$("#txaplica","#frmDadosAplicacaoPos").val("000,00000000");
				$("#dsaplica","#frmDadosAplicacaoPos").val("");
			}
		}
	});	
	
	/*RDCPOS*/
	$("#vllanmto","#frmDadosAplicacaoPos").unbind("blur");
	$("#vllanmto","#frmDadosAplicacaoPos").unbind("keydown");
	$("#vllanmto","#frmDadosAplicacaoPos").unbind("keyup");
	$("#vllanmto","#frmDadosAplicacaoPos").bind("blur",function() {
		if (parseFloat($(this).val().replace(/\./,"").replace(",",".")) <= 0) {
			//$("#vllanmto","#frmDadosAplicacaoPos").focus();
			return true;
		}
		
		if (!($(this).setMaskOnBlur("DECIMAL","zz.zzz.zz9,99","","divRotina"))) {
			return false;
		}	 
		
		if (!flgDigitValor) {
			return true;
		}
		
		return carregaCarenciaAplicacao();
					
	});
	
	$("#vllanmto","#frmDadosAplicacaoPos").bind("keydown",function(e) { 
		if (getKeyValue(e) != 9) {
			flgDigitValor = true;
		}
		return $(this).setMaskOnKeyDown("DECIMAL","zz.zzz.zz9,99","",e); 
	});
	$("#vllanmto","#frmDadosAplicacaoPos").bind("keyup",function(e) { 		
		return $(this).setMaskOnKeyUp("DECIMAL","zz.zzz.zz9,99","",e); 
	});

	$("#qtdiacar","#frmDadosAplicacaoPos").setMask("INTEGER","zz9","","");
	
	$("#dtresgat","#frmDadosAplicacaoPos").unbind("keydown");
	$("#dtresgat","#frmDadosAplicacaoPos").unbind("keyup");
	
	$("#dtresgat","#frmDadosAplicacaoPos").bind("change",function() {	
		calculaDataResgate($(this).attr("id"),$(this).val());			
	});
	
	$("#dtresgat","#frmDadosAplicacaoPos").bind("blur",function() {
		calculaDataResgate($(this).attr("id"),$(this).val());					
	});
	
	$("#dtresgat","#frmDadosAplicacaoPos").setMask("DATE","","","");
		
	$("#dtresgat","#frmDadosAplicacaoPos").bind("keydown",function(e) { 
		if (getKeyValue(e) != 9) {
			flgDigitVencto = true;
		}
		aux_qtdiaapl = 0;
		//valdtresg = true;
	});
	
	$("#dtresgat","#frmDadosAplicacaoPos").bind("keyup",function(e) { 		
		aux_qtdiaapl = 0;
		
	});
	
	/*RDCPRE*/
	$("#qtdiaapl","#frmDadosAplicacaoPre").unbind("blur");
	$("#qtdiaapl","#frmDadosAplicacaoPre").unbind("keydown");
	$("#qtdiaapl","#frmDadosAplicacaoPre").unbind("keyup");
	$("#qtdiaapl","#frmDadosAplicacaoPre").bind("blur",function() {		
		if ($(this).val() == "" || parseInt($(this).val(),10) <= 0) {
			$("#dtresgat","#frmDadosAplicacaoPre").val("");
		}
		
		if (!($(this).setMaskOnBlur("INTEGER","zzz9","","divRotina"))) {
			return false;
		}
		
		aux_qtdiaapl = $(this).val();
		aux_qtdiacar = 0;	
		
		return calculaDataResgate($(this).attr("id"));			
	});
		
	$("#qtdiaapl","#frmDadosAplicacaoPre").bind("keydown",function(e) { 
		if (getKeyValue(e) != 9) {
			flgDigitVencto = true;
		}
		return $(this).setMaskOnKeyDown("INTEGER","zzz9","",e); 
	});
	$("#qtdiaapl","#frmDadosAplicacaoPre").bind("keyup",function(e) { 		
		return $(this).setMaskOnKeyUp("INTEGER","zzz9","",e); 
	});

	$("#dtresgat","#frmDadosAplicacaoPre").unbind("blur");
	$("#dtresgat","#frmDadosAplicacaoPre").unbind("keydown");
	$("#dtresgat","#frmDadosAplicacaoPre").unbind("keyup");
	$("#dtresgat","#frmDadosAplicacaoPre").bind("blur",function() {	
			
		if ($(this).val() == "") {
			$("#qtdiaapl","#frmDadosAplicacaoPre").val("0");
		}
		
		if (!($(this).setMaskOnBlur("DATE","","","divRotina"))) {
			return false;
		}		 
		
		aux_qtdiaapl = $("#qtdiaapl","#frmDadosAplicacaoPre").val();
		aux_qtdiacar = 0;	
		flgcaren = true;
		
		return calculaDataResgate($(this).attr("id"),$(this).val());			
	});
	
	$("#dtresgat","#frmDadosAplicacaoPre").bind("keydown",function(e) { 
		if (getKeyValue(e) != 9) {
			flgDigitVencto = true;
		}
		return $(this).setMaskOnKeyDown("DATE","","",e); 
	});
	$("#dtresgat","#frmDadosAplicacaoPre").bind("keyup",function(e) { 		
		return $(this).setMaskOnKeyUp("DATE","","",e); 
	});
	
	$("#vllanmto","#frmDadosAplicacaoPre").unbind("blur");
	$("#vllanmto","#frmDadosAplicacaoPre").unbind("keydown");
	$("#vllanmto","#frmDadosAplicacaoPre").unbind("keyup");
	
	$("#vllanmto","#frmDadosAplicacaoPre").bind("blur",function() {
		if (parseFloat($(this).val().replace(/\./,"").replace(",",".")) <= 0) {
			return true;
		}
		
		if (!($(this).setMaskOnBlur("DECIMAL","zz.zzz.zz9,99","","divRotina"))) {
			return false;
		}		 
		
		return obtemTaxaAplicacao();
		
	});
	
	$("#vllanmto","#frmDadosAplicacaoPre").bind("keydown",function(e) { 
		if (getKeyValue(e) != 9) {
			flgDigitValor = true;
		}		
		return $(this).setMaskOnKeyDown("DECIMAL","zz.zzz.zz9,99","",e); 
	});
	$("#vllanmto","#frmDadosAplicacaoPre").bind("keyup",function(e) { 		
		return $(this).setMaskOnKeyUp("DECIMAL","zz.zzz.zz9,99","",e); 
	});

	//Ocultar e Exibir campos de Periodo - Tela Impressão
	var src = $("#tpmodelo","#frmImpressao").val();
	$("#tpmodelo","#frmImpressao").change(function() {
		var src   = $(this).val();
		
		if (src == '1') {
			$("#divImpPeriodo").css("display","block");
			$("#dtiniper","#frmImpressao").focus();
		}
		else {$("#divImpPeriodo").css("display","none");}

	});

	//Ocultar e Exibir campos de Periodo - Tela Impressão
	var src = $("#tprelato","#frmImpressao").val();
	
	$("#tprelato","#frmImpressao").change(function() {
		var src   = $(this).val();
		
		if (src == '1') {
			$("#tpaplic2","#frmImpressao").val(nraplica);
			$("#tpaplic2","#frmImpressao").prop('disabled', false);
			$("#tpaplic2","#frmImpressao").focus();
		}
		else {
			$("#tpaplic2","#frmImpressao").val('0');
			$("#tpaplic2","#frmImpressao").prop('disabled', true);
		}

	});

	$("#divResgate").css("display","none");
	$("#divResgatarVarias").css("display","none");
	$("#divOpcoes").css("display","none");
	$("#divAcumula").css("display","none");
	$("#divImprimir").css("display","none");
	$("#divDadosAplicacao").css("display","none");
	$("#divAplicacoesPrincipal").css("display","block");
		
	var auxApl = "<?php echo (isset($aplicacoes[0]->tags[1]->cdata)) ? $aplicacoes[0]->tags[1]->cdata : ''; ?>";
	
	if (idLinha > 0) {
		selecionaAplicacao(idLinha,<?php echo $qtAplicacoes; ?>,nraplica,'<?php echo ( isset($aplicacoes[0]->tags[16]->cdata) ) ? $aplicacoes[0]->tags[16]->cdata : ''; ?>');	
	} else {
		
		if(auxApl != ""){
			selecionaAplicacao(0,<?php echo $qtAplicacoes; ?>,'<?php echo ( isset($aplicacoes[0]->tags[1]->cdata) ) ? $aplicacoes[0]->tags[1]->cdata : ''; ?>','<?php echo ( isset($aplicacoes[0]->tags[16]->cdata) ) ? $aplicacoes[0]->tags[16]->cdata : ''; ?>');				
		}else{
			selecionaAplicacao(idLinha,<?php echo $qtAplicacoes; ?>,nraplica,'<?php echo ( isset($aplicacoes[0]->tags[16]->cdata) ) ? $aplicacoes[0]->tags[16]->cdata : ''; ?>');	
		}
	}
	
	// Esconde mensagem de aguardo
	hideMsgAguardo();

	// Bloqueia conteúdo que está átras do div da rotina
	blockBackground(parseInt($("#divRotina").css("z-index")));	
</script>
