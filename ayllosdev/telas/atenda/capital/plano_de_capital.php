<?php 

	/************************************************************************
	 Fonte: plano_de_capital.php                                      
	 Autor: David                                                     
	 Data : Outubro/2007                 Ultima Alteracao: 14/11/2017 
	                                                                  
	 Objetivo  : Mostrar opcao Plano de Capital o da rotina de        
	             Capital da tela ATENDA                               
	                                                                   
	 Alteracoes: 04/09/2009 - Tratar tamanho do div (David).          
	                                                                   
	 			       18/05/2012 - Retirado attr. target="_blank" de form  
							              frmTermoCancela.      				   
                            
			     	  09/07/2012 - Retirado campo "redirect" popup.(Jorge) 
              
	            10/09/2013 - Alterado para sempre mostrar os botoes  
	                          'Imprimir Plano', 'Cancelar Plano Atual'
	                          e 'Cadastrar Novo Plano'. (Fabricio)    
                            
	            26/02/2014 - Adicionado campo                        
	                          'Atualizacao Automatica' e tratado para 
	                          adicionar botao 'Alterar Plano' quando  
	                          da existencia de um plano ativo.        
	                          (Fabricio)            
                            
	            17/06/2016 - M181 - Alterar o CDAGENCI para          
                           passar o CDPACTRA (Rafael Maciel - RKAM) 
                           
                22/03/2017 - Ajuste para solicitar a senha do cooperado e não gerar o termo
                             para coleta da assinatura 
                            (Jonata - RKAM / M294).   

			   14/11/2017 - Ajuste permitir não permitir acesso a opção de integralização quando (Jonata - RKAM P364).
                          
	***********************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"P")) <> "") {
		exibeErro($msgError);		
	}		
	
	// Verifica se o n&uacute;mero da conta foi informado
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$sitaucaoDaContaCrm = $_POST["sitaucaoDaContaCrm"];
	
	// Verifica se o n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlGetPlano  = "";
	$xmlGetPlano .= "<Root>";
	$xmlGetPlano .= "	<Cabecalho>";
	$xmlGetPlano .= "		<Bo>b1wgen0021.p</Bo>";
	$xmlGetPlano .= "		<Proc>obtem-novo-plano</Proc>";
	$xmlGetPlano .= "	</Cabecalho>";
	$xmlGetPlano .= "	<Dados>";
	$xmlGetPlano .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetPlano .= "		<cdagenci>".$glbvars["cdpactra"]."</cdagenci>";
	$xmlGetPlano .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetPlano .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetPlano .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetPlano .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlGetPlano .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetPlano .= "		<idseqttl>1</idseqttl>";
	$xmlGetPlano .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlGetPlano .= "	</Dados>";
	$xmlGetPlano .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetPlano);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjPlano = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjPlano->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjPlano->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$plano = $xmlObjPlano->roottag->tags[0]->tags[0]->tags;
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>
<script type="text/javascript">var metodoBlock = "blockBackground(parseInt($('#divRotina').css('z-index')))";</script>

<form action="" name="frmNovoPlano" id="frmNovoPlano" method="post" class="formulario">

	<label for="vlprepla">Valor do Plano:</label>
	<input name="vlprepla" id="vlprepla" type="text" value="<?php echo number_format(str_replace(",",".",$plano[1]->cdata),2,",","."); ?>" autocomplete="no" class="campo"/>
	<br />
	
	<label for="cdtipcor"><? echo utf8ToHtml('Atualização Automática:') ?></label>
	<select name="cdtipcor" id="cdtipcor" onChange="habilitaValor()">
		<option value="0" <?php if ($plano[8]->cdata == "0") { echo "selected"; } ?>><? echo utf8ToHtml('Sem Atualização Cadastrada') ?></option>
		<option value="1" <?php if ($plano[8]->cdata == "1") { echo "selected"; } ?>><? echo utf8ToHtml('Correção por Índice de Inflação') ?></option>
		<option value="2" <?php if ($plano[8]->cdata == "2") { echo "selected"; } ?>><? echo utf8ToHtml('Correção por Valor Fixo') ?></option>
	</select>
	
	<div id="divValorCorrecao">
		<label for="vlcorfix">Valor:</label>
		<input name="vlcorfix" id="vlcorfix" type="text" value="<?php echo number_format(str_replace(",",".",$plano[11]->cdata),2,",","."); ?>" autocomplete="no" class="campo"/>
	</div>
	<br />
	
	<label for="flgpagto">Debitar Em:</label>
	<select name="flgpagto" id="flgpagto" >
	<?php
		$opcoesPagto = explode(",",$plano[0]->cdata);
	?>	
		<option value="no"<?php if ($opcoesPagto[2] == "Conta") { echo " selected"; } ?>>Conta</option>
	<?php
		if (trim($opcoesPagto[0]) <> "") {
			?><option value="yes"<?php if ($opcoesPagto[2] == "Folha") { echo " selected"; } ?>>Folha</option>
		<?php
		} 
		?>
	</select> 
	<br />
	
	<label for="qtpremax"><? echo utf8ToHtml('Quantidade de Prestações:') ?></label>
	<input type="text" name="qtpremax" id="qtpremax" value="<?php echo $plano[2]->cdata; ?>" autocomplete="no" echo class="campo"></td>
	<br />
	
	<label for="dtdpagto"><? echo utf8ToHtml('Data de Início:') ?></label>
	<input type="text" name="dtdpagto" id="dtdpagto" value="<?php echo $plano[3]->cdata; ?>" autocomplete="no" echo class="campo"></td>
	
	<label for="dtultatu"><? echo utf8ToHtml('Data da Última Atualização:') ?></label>
	<input type="text" name="dtultatu" id="dtultatu" value="<?php echo $plano[9]->cdata; ?>" autocomplete="no" echo class="campo"></td>
	
	<label for="dtproatu"><? echo utf8ToHtml('Data da Próxima Atualização:') ?></label>
	<input type="text" name="dtproatu" id="dtproatu" value="<?php echo $plano[10]->cdata; ?>" autocomplete="no" echo class="campo"></td>
		
  <label for="tpautori"><? echo utf8ToHtml('Tipo de Autorização:') ?></label>														
	<input type="radio" name="tpautori" onClick="controlaBotoes('1');" id="senha" checked value="1" class="radio" /> 
	<label for="senha" class="radio">Senha</label> 														
	<input type="radio" name="tpautori" onClick="controlaBotoes('2');" id="autorizacao" value="2" class="radio" /> 
	<label for="autorizacao" class="radio">Assinatura</label>	
    
</form>

<div id="divBotoesAutorizacao" style="display:none;">
	
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/cancelar_plano_atual.gif" onClick="showConfirmacao('Deseja cancelar o plano de capital atual?','Confirma&ccedil;&atilde;o - Ayllos','excluirPlano()',metodoBlock,'sim.gif','nao.gif');return false;">
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/cadastrar_novo_plano.gif" onClick="validaNovoPlano(false,false);return false;">
	<input type="image" id="btImprimir" src="<?php echo $UrlImagens; ?>botoes/imprimir_plano.gif" onClick="imprimeNovoPlano();return false;">
		
</div>


<div id="divBotoesSenha" style="display:none;">
  <input type="image" src="<?php echo $UrlImagens; ?>botoes/cancelar_plano_atual.gif" onClick='showConfirmacao("Deseja cancelar o plano de capital atual?","Confirma&ccedil;&atilde;o - Ayllos","solicitaSenhaMagnetico(\'cancelarPlanoAtual()\','.$nrdconta.')","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))","sim.gif","nao.gif");return false;'>
  <input type="image" src="<?php echo $UrlImagens; ?>botoes/cadastrar_novo_plano.gif" onClick="validaNovoPlano(false,true);return false;">
  <input type="image" id="btImprimir" src=""<?php echo $UrlImagens; ?>botoes/imprimir_plano.gif" onClick="imprimeNovoPlano();return false;">
</div>

<form action="<?php echo $UrlSite; ?>telas/atenda/capital/termo_cancelamento.php" name="frmTermoCancela" id="frmTermoCancela" method="post">
	<input type="hidden" name="nrdconta" id="nrdconta" value="">
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
	</form>
	<form action="<?php echo $UrlSite; ?>telas/atenda/capital/termo_autorizacao.php" name="frmTermoAutoriza" id="frmTermoAutoriza" method="post">
	<input type="hidden" name="nrdconta" id="nrdconta" value="">
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
</form>	

<script type="text/javascript"> 

	// Configura propriedades do campo "flgpagto" conforme tipo de d&eacute;bito
	$("#dtdpagto","#frmNovoPlano").unbind("keydown");
	$("#dtdpagto","#frmNovoPlano").unbind("keyup");
	$("#dtdpagto","#frmNovoPlano").unbind("blur");
	$("#flgpagto","#frmNovoPlano").unbind("change");

	$("#flgpagto","#frmNovoPlano").bind("change",function() {
		if ($(this).val() == "no") { // Se for d&eacute;bito em Conta
			$("#dtdpagto","#frmNovoPlano").removeProp("disabled").removeClass("campoTelaSemBorda").attr("class","campo");; 
			$("#dtdpagto","#frmNovoPlano").val("<?php echo $glbvars["dtmvtolt"]; ?>");
			$("#dtdpagto","#frmNovoPlano").bind("keydown",function(e) { return $(this).setMaskOnKeyDown("DATE","","",e); });
			$("#dtdpagto","#frmNovoPlano").bind("keyup",function(e) { return $(this).setMaskOnKeyUp("DATE","","",e); });
			$("#dtdpagto","#frmNovoPlano").bind("blur",function() { return $(this).setMaskOnBlur("DATE","","","divRotina"); });
		} else { // Se for d&eacute;bito em Folha
			$("#dtdpagto","#frmNovoPlano").prop("disabled",true).removeClass("campo").attr("class","campoTelaSemBorda");
			$("#dtdpagto","#frmNovoPlano").val("<?php echo $plano[7]->cdata; ?>");
			$("#dtdpagto","#frmNovoPlano").unbind("keydown");
			$("#dtdpagto","#frmNovoPlano").unbind("keyup");
			$("#dtdpagto","#frmNovoPlano").unbind("blur");
		}
	});

	// Aciona evento "change" ao campo flgpagto
	$("#flgpagto","#frmNovoPlano").trigger("change");

	// Seta m&aacute;scara aos campos vlprepla, vlcorfix e qtpremax
	$("#vlprepla","#frmNovoPlano").setMask("DECIMAL","zzz.zzz.zz9,99","","");
	$("#vlcorfix","#frmNovoPlano").setMask("DECIMAL","zzz.zzz.zz9,99","","");
	$("#qtpremax","#frmNovoPlano").setMask("INTEGER","zzz","","");

	// Aumenta tamanho do div onde o conte&uacute;do da op&ccedil;&atilde;o ser&aacute; visualizado
	$("#divConteudoOpcao").css("height","145px");

	controlaLayout('PLANO_CAPITAL');

	var aux_flcancel = "<?php echo $plano[4]->cdata; ?>";

	var cTodos       = $('select,input','#frmNovoPlano');

	$('#divBotoesSenha','#divConteudoOpcao').html("");
	$('#divBotoesAutorizacao','#divConteudoOpcao').html("");

	$('#divBotoesSenha','#divConteudoOpcao').append('<input type="image" src="<?php echo $UrlImagens; ?>botoes/cancelar_plano_atual.gif" onClick="showConfirmacao(\'Deseja cancelar o plano de capital atual?\',\'Confirma&ccedil;&atilde;o - Ayllos\',\'solicitaSenhaMagnetico(\\\'cancelarPlanoAtual()\\\',\\\'<?php echo $nrdconta ?>\\\')\',metodoBlock,\'sim.gif\',\'nao.gif\');return false;">');
	$('#divBotoesAutorizacao','#divConteudoOpcao').append('<input type="image" src="<?php echo $UrlImagens; ?>botoes/cancelar_plano_atual.gif" onClick="showConfirmacao(\'Deseja cancelar o plano de capital atual?\',\'Confirma&ccedil;&atilde;o - Ayllos\',\'excluirPlano()\',metodoBlock,\'sim.gif\',\'nao.gif\');return false;">');

	if (aux_flcancel == "yes") {
		$('#divBotoesSenha','#divConteudoOpcao').append('<input type="image" src="<?php echo $UrlImagens; ?>botoes/alterar_plano.gif" style="margin-left:5px;" onClick="validaNovoPlano(true,true);return false;">');
		  $('#divBotoesAutorizacao','#divConteudoOpcao').append('<input type="image" src="<?php echo $UrlImagens; ?>botoes/alterar_plano.gif" style="margin-left:5px;" onClick="validaNovoPlano(true,false);return false;">');
		
		cTodos.desabilitaCampo();
		
		$('#vlprepla','#frmNovoPlano').habilitaCampo();
		$('#cdtipcor','#frmNovoPlano').habilitaCampo();
		$('#vlcorfix','#frmNovoPlano').habilitaCampo();
		$('#senha','#frmNovoPlano').habilitaCampo();
		$('#autorizacao','#frmNovoPlano').habilitaCampo();
		
	} else {
		  $('#divBotoesSenha','#divConteudoOpcao').append('<input type="image" src="<?php echo $UrlImagens; ?>botoes/cadastrar_novo_plano.gif" style="margin-left:5px;" onClick="validaNovoPlano(false,true);return false;">');
		  $('#divBotoesAutorizacao','#divConteudoOpcao').append('<input type="image" src="<?php echo $UrlImagens; ?>botoes/cadastrar_novo_plano.gif" style="margin-left:5px;" onClick="validaNovoPlano(false,false);return false;">');
		
		
		$('#dtultatu','#frmNovoPlano').desabilitaCampo();
		$('#dtproatu','#frmNovoPlano').desabilitaCampo();
		$('#senha','#frmNovoPlano').habilitaCampo();
		$('#autorizacao','#frmNovoPlano').habilitaCampo();
	}
			
	$('#divBotoesSenha','#divConteudoOpcao').append('<input type="image" id="btImprimir" src="<?php echo $UrlImagens; ?>botoes/imprimir_plano.gif" style="margin-left:5px;" onClick="imprimeNovoPlano();return false;">');
	$('#divBotoesAutorizacao','#divConteudoOpcao').append('<input type="image" id="btImprimir" src="<?php echo $UrlImagens; ?>botoes/imprimir_plano.gif" style="margin-left:5px;" onClick="imprimeNovoPlano();return false;">');

	habilitaValor();

	// Esconde mensagem de aguardo
	hideMsgAguardo();

	// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
	blockBackground(parseInt($("#divRotina").css("z-index")));

	$("#vlprepla","#frmNovoPlano").focus();
	
	
	<?php if($sitaucaoDaContaCrm == '2' || 
			 $sitaucaoDaContaCrm == '3' || 
			 $sitaucaoDaContaCrm == '4' || 
			 $sitaucaoDaContaCrm == '5' || 
			 $sitaucaoDaContaCrm == '7' || 
			 $sitaucaoDaContaCrm == '8' || 
			 $sitaucaoDaContaCrm == '9' ){?>
		
		cTodos.desabilitaCampo();
		$('#divBotoesSenha','#divConteudoOpcao').html("");
		$('#divBotoesAutorizacao','#divConteudoOpcao').html("");
		
	<?}?>
	
</script>