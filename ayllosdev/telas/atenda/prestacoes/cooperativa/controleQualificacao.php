<?php

/*
 * FONTE        : controleQualificacao.php
 * CRIAÇÃO       : Diego Simas (AMcom)
 * DATA CRIAÇÃO : 17/01/2018
 * OBJETIVO     : Mostra a tela com parâmetros para controle da Qualificação da Operação
 */	
	
	session_start();
	require_once('../../../../includes/config.php');
	require_once('../../../../includes/funcoes.php');
	require_once('../../../../includes/controla_secao.php');
	require_once('../../../../class/xmlfile.php');

	$nrdconta = $_POST['nrdconta'] == '' ? 0 : $_POST['nrdconta'];
	$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : 0;
	$idquaprc =  (isset($_POST['idquaprc'])) ? $_POST['idquaprc'] : 0;
	$idquapro =  (isset($_POST['idquapro'])) ? $_POST['idquapro'] : 0;
	$operacao = $_POST['operacao'] == '' ? 0 : $_POST['operacao'];

	// Monta o xml de requisição
	if($operacao == "CON_QUALIFICA"){
		$xml  = "";
		$xml .= "<Root>";
		$xml .= "  <Dados>";
		$xml .= "    <nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "    <nrctremp>".$nrctremp."</nrctremp>";
		$xml .= "  </Dados>";
		$xml .= "</Root>";

		$xmlResult = mensageria($xml, "TELA_ATENDA_PRESTACOES", "CONSULTAR_CONTROLE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");		
		$xmlObjeto = getObjectXML($xmlResult);	
		
		$param = $xmlObjeto->roottag->tags[0]->tags[0];

		$idquapro = getByTagName($param->tags,'idquapro');
		$idquaprc = getByTagName($param->tags,'idquaprc');
		
		if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
			exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos',"controlaOperacao('');",false); 
		}			

	}else{				

		if($idquaprc > 5){
			echo "<script>";
			echo "showError('inform','Opera&ccedil;&atilde;o inexistente! Favor informar uma opera&ccedil;&atilde;o v&aacute;lida.','Notifica&ccedil;&atilde;o - Ayllos','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\',5000)));fechaRotina($(\'#divUsoGenerico\'),divRotina);');";		
			echo "</script>";
		}else{
			$xml  = "";
			$xml .= "<Root>";
			$xml .= "  <Dados>";
			$xml .= "    <nrdconta>".$nrdconta."</nrdconta>";
			$xml .= "    <nrctremp>".$nrctremp."</nrctremp>";
			$xml .= "    <idquaprc>".$idquaprc."</idquaprc>";
			$xml .= "  </Dados>";
			$xml .= "</Root>";

			$xmlResult = mensageria($xml,"TELA_ATENDA_PRESTACOES", "ALTERAR_CONTROLE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
			$xmlObj = getObjectXML($xmlResult);

			if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
				exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos',"controlaOperacao('');",false); 
			}

			echo "<script>";
			echo "showError('inform','Qualifica&ccedil;&atilde;o da Opera&ccedil;&atilde;o alterada com sucesso.','Notifica&ccedil;&atilde;o - Ayllos','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));fechaRotina($(\'#divUsoGenerico\'),divRotina);');";		
			echo "</script>";
		}				
	}

		$dsquapro = obtemDescricaoQualificacao($idquapro);
		$dsquaprc = obtemDescricaoQualificacao($idquaprc);

?>

	<table id="tdImp"cellpadding="0" cellspacing="0" border="0" width="100%">
		<tr>
			<td align="center">		
				<table border="0" cellpadding="0" cellspacing="0" width="400">
					<tr>
						<td>
							<table width="100%" border="0" cellspacing="0" cellpadding="0">
								<tr>
									<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
									<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">Qualificação - Controle</td>
									<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina($('#divUsoGenerico'),divRotina);"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
									<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
								</tr>
							</table>     
						</td> 
					</tr>    
					<tr>
						<td class="tdConteudoTela" align="center">	
							<table width="100%" border="0" cellspacing="0" cellpadding="0">
								<tr>
									<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px 2px 8px;">
										<div id="divConteudoOpcao">

											<form name="frmControleQual" id="frmControleQual" class="formulario condensado">	

												<input id="nrctremp" name="nrctremp" type="hidden" value="" />
		
												<fieldset>
													<legend><? echo utf8ToHtml('Alterar Qualifica&ccedil;&atilde;o da Opera&ccedil;&atilde;o') ?></legend>
													
													<label for="idquapro" style="width:180px">Qualifica&ccedil;&atilde;o Op.:</label>
													<input name="idquapro" id="idquapro" style="width:30px" type="text" value="<?=$idquapro?>" readonly="true" />
													<input name="dsquapro" id="dsquapro" style="width:140px" type="text" value="<?=$dsquapro?>" readonly="true" />
													<br/>
													
													<label for="idquaprc" style="width:180px">Qualifica&ccedil;&atilde;o Op. Contr.:</label>
													<input name="idquaprc" id="idquaprc" style="width:30px" type="text" value="<?=$idquaprc?>" maxlength="1" />
													<a id="lupaControle" name="lupaControle"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
													<input name="dsquaprc" id="dsquaprc" style="width:120px" type="text" value="<?=$dsquaprc?>" readonly="true"/>
													<br/>
												</fieldset>
												<div id="divBotoes">
													<a href="#" class="botao" style="width:58px;" id="btAlterar" onClick="controlaOperacao('ALT_QUALIFICA');">Alterar</a>
													<a href="#" class="botao" style="width:65px;" id="btVoltar" onClick="fechaRotina($('#divUsoGenerico'),divRotina);">Voltar</a>                                                
												</div>
											</form>
										</div>
									</td>
								</tr>
							</table>			    
						</td> 
					</tr>
				</table>
			</td>
		</tr>
	</table>


<script type="text/javascript">
	// Esconde mensagem de aguardo
	hideMsgAguardo();	

	// Bloqueia conteÃºdo que estÃ¡ Ã¡tras do div da rotina
	blockBackground(parseInt($("#divRotina").css("z-index")));

	// Evento onKeyDown no campo idquaprc	
	$("#idquaprc", "#frmControleQual").unbind('keydown').bind('keydown', function(e) {			
		// Se Ã© a tecla ENTER, 
		if (( e.keyCode == 13 ) || (e.keyCode == 9)){
			var vIdQuaPrc = $("#idquaprc", "#frmControleQual").val();
			$("#dsquaprc", "#frmControleQual").val(obtemDescricaoQualificacao(vIdQuaPrc));
			$("#btAlterar", "#frmControleQual").focus();
		}
	});

	var controleMascara = $('#idquaprc','#frmControleQual');
	controleMascara.setMask('INTEGER','9','.','');
	
	var lupa = $('#lupaControle', '#frmControleQual');	
	lupa.css('cursor', 'pointer');
	lupa.css('display', 'block');	

	$("#lupaControle").bind('click', function () {	
		pck = 'zoom0001';
        acao = 'BUSCAQUAOPEC';
		titulo = 'Qualifica&ccedil;&atilde;o da Opera&ccedil;&atilde;o';
		qtReg = '4';		
		filtros = 'C&oacutedigo;idquaprc;30px;N;0|Quali. Oper.;dsquaprc;200px;N;';
		colunas = 'C&oacutedigo;idquaprc;15%;left|Descri&ccedil&atildeo;dsquaprc;85%;left';			
		mostraPesquisa(pck, acao, titulo, qtReg, filtros, colunas);	
		var telaPrincipal = $('#divPesquisa');	
		telaPrincipal.css('zIndex', 4000);		
		return false;
	});

	function obtemDescricaoQualificacao(idQuaOpe){
		var dsquaprc = "";
		switch (idQuaOpe) {
			case '1':
				var dsquaprc = "Operação Normal";
				break;
			case '2':
				var dsquaprc = "Renovação Crédito";
				break;
			case '3':
				var dsquaprc = "Renegociação Crédito";
				break;
			case '4':
				var dsquaprc = "Composição Dívida";				
				break;
			case '5':
				var dsquaprc = "Cessão de Cartão";				
				break;			
			default:
				var dsquaprc = "Operação Inexistente";				
				break;
		}
		return dsquaprc;
	}

</script>

<?php
	//Função para opções da Qualificação da Operação
	function obtemDescricaoQualificacao($idQuaOpe){
		$dsquaprc = "";
		switch ($idQuaOpe) {
			case 1:
				$dsquaprc = "Operação Normal";
				break;
			case 2:
				$dsquaprc = "Renovação Crédito";
				break;
			case 3:
				$dsquaprc = "Renegociação Crédito";
				break;
			case 4:
				$dsquaprc = "Composição Dívida";				
				break;
			case 5:
				$dsquaprc = "Cessão de Cartão";				
				break;
			default:
				$dsquaprc = "Operação Inexistente";				;
				break;
		}
		return $dsquaprc;
	}
?>