<?php 

	//************************************************************************//
	//*** Fonte: contas_cadastradas_detalhes.php      	               ***//
	//*** Autor: Lucas                                                     ***//
	//*** Data : Maio/2012                   Última Alteração: 	       ***//
	//***                                                                  ***//
	//*** Objetivo  : Mostrar detalhes das contas de tranf. cadastradas    ***//
	//***                                                                  ***//	 
	//***                                                                  ***//	 
	//*** Alterações: 27/04/2015 - Inclusão do campo ISPB SD271603         ***//
        //***                          FDR041 (Vanessa)                        ***//  													   ***//	 
	//***                                                                  ***//
	//***                                                                  ***//
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"H")) <> "") {
		exibeErro($msgError);		
	}
	
	// Verifica se o n&uacute;mero da conta foi informado
	if (!isset($_POST["nrdconta"]) || !isset($_POST["idseqttl"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$idseqttl = $_POST["idseqttl"];
	$intipdif = $_POST["intipdif"];
		
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlTpContas  = "";
	$xmlTpContas .= "<Root>";
	$xmlTpContas .= "	<Cabecalho>";
	$xmlTpContas .= "		<Bo>b1wgen0015.p</Bo>";
	$xmlTpContas .= "		<Proc>consulta-tipos-contas</Proc>";
	$xmlTpContas .= "	</Cabecalho>";
	$xmlTpContas .= "	<Dados>";
	$xmlTpContas .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlTpContas .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlTpContas .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlTpContas .= "	</Dados>";
	$xmlTpContas .= "</Root>"; 

	// Executa script para envio do XML
	$xmlResultTpContas = getDataXML($xmlTpContas);

	// Cria objeto para classe de tratamento de XML
	$xmlObjTpContas = getObjectXML($xmlResultTpContas);
	
	$tpcontas = $xmlObjTpContas->roottag->tags[0]->tags;

	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjTpContas->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjTpContas->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}

	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	} 
		
?>

<form name="frmDetalhesCoop" class="formulario" id="frmDetalhesCoop" method="post" style="display: none;" >
		<fieldset>
			<legend>Detalhes</legend>
			
			<div id="divDetalhes" style = "padding-left:15px;">
		
				<div style = "text-align:left;"><label>Dados do Favorecido:</label></div>
				<br/><br/>
				
				<div style = "padding-left:35px;">
					<label for="dsageban"><? echo utf8ToHtml('Cooperativa:') ?></label>
					<input style = "width:135px;" class="campo" name="dsageban" id="dsageban" />
				</div>
				
				<br/><br/>
				
				<div style = "padding-left:54px;">
					<label for="dsctatrf"><? echo utf8ToHtml('Conta/DV:') ?></label>
					<input style = "width:110px;" class="campo" name="dsctatrf" id="dsctatrf" />
				</div>
				
				<input type="hidden" name="nrctatrf" id="nrctatrf">
				<input type="hidden" name="inpessoa" id="inpessoa">
				<input type="hidden" name="cddbanco" id="cddbanco">
				<input type="hidden" name="cdageban" id="cdageban">
                <input type="hidden" name="cdispbif" id="cdispbif">
				<input type="hidden" name="intipdif" id="intipdif">
				
				<br/><br/>
			
				<div style = "padding-left:16px;">
					<label for="nmtitula"><? echo utf8ToHtml('Nome do Titular:') ?></label>
					<input style = "width:323px;" class="campo" name="nmtitula" id="nmtitula" />
				</div>
				
				<br/><br/>	
		
				<div id = "CPF" style = "display: none;"><label for="nrcpfcgc"><? echo utf8ToHtml('CPF do Titular:') ?></label></div>
				<div id = "CNPJ" style = "display: none;"><label for="nrcpfcgc"><? echo utf8ToHtml('CNPJ do Titular:') ?></label></div>
				<input class="campo" name="nrcpfcgc" id="nrcpfcgc" />
			
				<br/><br/>
				
				<div style = "padding-left:5px;">
					<label for="dstransa"><? echo utf8ToHtml('Data Pre-Cadastro:') ?></label>
					<input class="campo" name="dstransa" id="dstransa"/>
				</div>
			
				<br/><br/>
				
				<label for="dsoperad"><? echo utf8ToHtml('Operador Cadastro:') ?></label>
				<input class="campo" style = "width:323px;" name="dsoperad" id="dsoperad"/>
							
				<br/><br/>
			
				<div style = "padding-left:59px;">
					<label for="insitcta"><? echo utf8ToHtml('Situação:') ?></label>
					<select id="insitcta" class="campo" name="insitcta">
						<option value="2">Ativa</option> 
						<option value="3">Bloqueada</option>
					</select>
				</div>
			
				<br/><br/>
			
				<div  style = "padding-left:125px;">
					<input type="image" src="<? echo $UrlImagens; ?>botoes/voltar.gif" onClick="obtemCntsCad(<? echo $intipdif; ?>, 0, 50); return false;"/>
					<input type="image" id = "btAlterar"  src="<? echo $UrlImagens; ?>botoes/alterar.gif"  onClick = "habilitaAlterarDados('frmDetalhesCoop');return false;" />
					<input type="image" style="display: none;" id = "btConcluir" src="<? echo $UrlImagens; ?>botoes/concluir.gif" onClick = "validaDadosConta('frmDetalhesCoop');return false;" style="display: none;" />
				</div>
			</div>
		</fieldset>
</form>	

<form name="frmDetalhesOtr" class="formulario" id="frmDetalhesOtr" method="post" style="display: none;" >
		<fieldset>
			<legend>Detalhes</legend>
			
			<div id="divDetalhes" style = "padding-left:15px;">
		
				<div style = "text-align:left;"><label>Dados do Favorecido:</label></div>
				<input type="hidden" name="intipdif" id="intipdif">
			
				<br/><br/>
				
				<label for="cddbanco" style = "width:50px;"><? echo utf8ToHtml('Banco:') ?></label>
				<input style="width:50px" class="campo" name="cddbanco" id="cddbanco"/>

				<label for="cdispbif" style = "width:35px;"><? echo utf8ToHtml('ISPB:') ?></label>
				<input style="width:80px" class="campo" name="cdispbif" id="cdispbif"/>
                                
                 <label for="cdageban" style = "width:60px;"><? echo utf8ToHtml('Agência:') ?></label>
				<input style="width:40px" class="campo" name="cdageban" id="cdageban"/>
                                
				<label for="dsctatrf" style = "width:92px;"><? echo utf8ToHtml('Conta&nbsp;Corrente:') ?></label>
				<input style="width:90px" class="campo" name="dsctatrf" id="dsctatrf" />

				<input type="hidden" name="nrctatrf" id="nrctatrf">
							
				<br/><br/>
					
				<div style = "padding-left:15px;">
					<label for="nmtitula"><? echo utf8ToHtml('Nome do Titular:') ?></label>
					<input style = "width:331px;" class="campo" name="nmtitula" id="nmtitula" />
				</div>
				
				<br/><br/>		
			
				<div id = "CPF" style = "display: none;"><label for="nrcpfcgc"><? echo utf8ToHtml('CPF do Titular:') ?></label></div>
				<div id = "CNPJ" style = "display: none;"><label for="nrcpfcgc"><? echo utf8ToHtml('CNPJ do Titular:') ?></label></div>
					<input class="campo" name="nrcpfcgc" id="nrcpfcgc" />
			
				<br/><br/>
				
				<div style = "padding-left:18px;">
					<label for="inpessoa"><? echo utf8ToHtml('Tipo de Pessoa:') ?></label>
					<select id="inpessoa" class="campo" name="inpessoa">
						<option value="1">F&iacute;sica</option> 
						<option value="2">Jur&iacute;dica</option>
					</select>
				</div>
				
				<br/><br/>
				
				<div style = "padding-left:27px;">
					<label for="intipcta"><? echo utf8ToHtml('Tipo de Conta:') ?></label>
					<select id="intipcta" class="campo" name="intipcta" style = "width:150px;">
					<? foreach ( $tpcontas as $tiposcontas ) {
						echo '<option value="'.getByTagName($tiposcontas->tags,'intipcta').'">'.getByTagName($tiposcontas->tags,'nmtipcta').'</option> ';
					  }?>
					</select>
				</div>
				
				<br/><br/>
				
				<div style = "padding-left:5px;">
					<label for="dstransa"><? echo utf8ToHtml('Data Pre-Cadastro:') ?></label>
					<input class="campo" name="dstransa" id="dstransa"/>
				</div>
				
				<br/><br/>
			
				<label for="dsoperad"><? echo utf8ToHtml('Operador Cadastro:') ?></label>
				<input class="campo" style = "width:323px;" name="dsoperad" id="dsoperad"/>
			
			
				<br/><br/>
			
				<div style = "padding-left:60px;">
					<label for="insitcta"><? echo utf8ToHtml('Situação:') ?></label>
					<select id="insitcta" class="campo" name="insitcta">
						<option value="2">Ativa</option> 
						<option value="3">Bloqueada</option>
					</select>
				</div>
			
				<br/><br/>
			
				<div style = "padding-left:180px;">
					<input type="image" src="<? echo $UrlImagens; ?>botoes/voltar.gif" onClick="obtemCntsCad(<? echo $intipdif; ?>); return false;" />
					<input type="image" id = "btAlterar"  src="<? echo $UrlImagens; ?>botoes/alterar.gif"  onClick = "habilitaAlterarDados('frmDetalhesOtr');$('#nmtitula','#frmDetalhesOtr').focus();return false;" />
					<input type="image" style="display: none;" id = "btConcluir" src="<? echo $UrlImagens; ?>botoes/concluir.gif" onClick = "validaDadosConta('frmDetalhesOtr');return false;" />
				</div>
			</div>
		</fieldset>
</form>	

<script type="text/javascript">

// Aumenta tamanho do div onde o conte&uacute;do da op&ccedil;&atilde;o ser&aacute; visualizado
$("#divConteudoOpcao").css("width","545");
$("#divConteudoOpcao").css("height","<?php if ($intipdif == 1) echo "320"; else echo "340"; ?>");

$('#inpessoa','#frmDetalhesOtr').unbind('change').bind('change', function() {
		habilitaAlterarDados('frmDetalhesOtr');
		return false;
	});

// Esconde mensagem de aguardo
hideMsgAguardo();
blockBackground(parseInt($("#divRotina").css("z-index")));

</script> 