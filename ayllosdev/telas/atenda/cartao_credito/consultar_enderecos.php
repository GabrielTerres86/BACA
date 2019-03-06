<?php 

	//************************************************************************//
	//*** Fonte: consultar_enderecos.php                                   ***//
	//*** Autor: Lucas Schneider (Supero                                   ***//
	//*** Data : Janeiro/2019                 Última Alteração: 18/01/2019 ***//
	//***                                                                  ***//
	//*** Objetivo  : Mostrar tela para identificação/definição do         ***//
	//***             endereço para o envio do cartão.                     ***//
	//***                                                                  ***//	 
	//*** Alterações: 18/01/2019 - Criação da tela						   ***//  
	//************************************************************************//			
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	// Verifica permissão
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"C")) <> "") {
		exibeErro($msgError);		
	}			
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	
	$cdcooper = $glbvars['cdcooper'];
	$nrdconta = $_POST["nrdconta"];	
	$tipoacao = $_POST["tipoacao"];	
	 
	        
	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}

	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
	// Montar o xml de Requisicao para buscar o tipo de conta do associado e termo para conta salario
	$xml = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdcooper>".$cdcooper."</cdcooper>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "ATENDA_CRD", "BUSCA_ENDERECOS_CRD", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);
		
	// Se ocorrer um erro, mostra cr?tica
	if ($xmlObjeto->roottag->tags[0]->name == "ERRO") {
		exibeErro($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
	 
	$dominios = $xmlObjeto->roottag->tags[0]->tags;  
	$enderecoPa = $xmlObjeto->roottag->tags[1]->tags[0]->cdata;  
	//print_r($xmlObjeto->roottag->tags[1]);exit;
	$agenciasPermitidas = $xmlObjeto->roottag->tags[2]->tags;  
	
	// Montar o xml de Requisicao para buscar o tipo de conta do associado e termo para conta salario
	$xml = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "ATENDA_CRD", "ENVIO_CARTAO_COOP_PA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	$coop_envia_cartao = getByTagName($xmlObjeto->roottag->tags,"COOP_ENVIO_CARTAO");
	$pa_envia_cartao = getByTagName($xmlObjeto->roottag->tags,"PA_ENVIO_CARTAO");

	$novo_fluxo_envio = false;
	$pa_envia_cartao = false;

	if ($coop_envia_cartao && !$pa_envia_cartao) {
		echo "<script>showError('error', 'Nenhuma op&ccedil;&atilde;o de envio definida para o PA, por favor, entre em contato com a SEDE para que seja realizada a parametriza&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina);') </script>";
	}
?>
<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td>
			<table border="0" cellpadding="0" cellspacing="0" width="700">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">ENDERE&Ccedil;OS</td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="exibeRotina($('#divRotina'));fechaRotina($('#divUsoGenerico'),$('#divRotina'));"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
								<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
							</tr>
						</table>     
					</td> 
				</tr>    
				<tr>
					<td class="tdConteudoTela">	
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td>
									<table border="0" cellspacing="0" cellpadding="0">
										<tr>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq0"></td>
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" class="txtNormalBold">Principal</a></td>
																																					
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
											<td width="1"></td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<div id="divConteudoOpcao">
										<form action="" method="post" name="frmListaEnderecos" id="frmListaEnderecos">
										
											<fieldset style="padding-left: 10px;text-align:center">
												<legend><? echo utf8ToHtml('Lista de Endereços') ?></legend> 
																
												<div>
												<? 
												foreach($dominios as $dominio){					
												?>
													<fieldset style="padding-left: 10px; display: inline-block; width: 190px; height: 100px;" onclick="selectRadio(this);">
														<legend><? echo utf8ToHtml(getByTagName($dominio->tags, 'dscodigo')) ?></legend>	
														<? if (trim(getByTagName($dominio->tags, 'dsendereco')) !== '') { ?>
														<input type="radio" name="endereco" id="opt_<? echo utf8ToHtml(getByTagName($dominio->tags, 'cddominio')) ?>"  class='optradio' value="<? echo utf8ToHtml(getByTagName($dominio->tags, 'cddominio')) ?>" /> 
														</br>
														<label style="text-align: left; line-height: 14px; width: 190px" > 
															<? echo utf8ToHtml(nl2br(getByTagName($dominio->tags, 'dsendereco'))) ?> 
														</label>  
														<? } else {?> 		
														</br>					
														<label style="line-height: 14px; width: 190px; font-size: 15px; color: #a9a9a9!important; text-align: center; margin-top: 20px" > 
															<? echo utf8ToHtml('Não Informado') ?> 
														</label>  
														<? } ?> 
													</fieldset>
												<? } ?> 
												
													<fieldset style="padding-left: 10px; display: inline-block; width: 190px; height: 100px" onclick="selectRadio(this);">
														<legend><? echo utf8ToHtml('Endereço PA') ?></legend>	
														<input type="radio" name="endereco" id="enderecopa"  class='optradio' value="" /> 
														</br> 
														<label style="text-align: left; line-height: 14px; width: 190px" > 
															<? echo nl2br($enderecoPa) ?> 
														</label> 
													</fieldset>
													
													<fieldset style="padding-left: 10px; display: inline-block; width: 190px; height: 100px;" onclick="selectRadio(this);">
														<legend><? echo utf8ToHtml('Outro PA') ?></legend>		
														<? if (count($agenciasPermitidas) !== 0) { ?>
															<input type="radio" name="endereco" id="outropa"  class='optradio' /> 
															</br>
															<select class="Campo" id="outropasel" style="width: 70px; margin-top: 20px; margin-left: 40px">						
															<? 
															foreach($agenciasPermitidas as $agencia){
															?>
															<option data-endereco="<?php echo nl2br($agencia->cdata); ?>" value="<?php echo $agencia->name; ?>"><?php echo $agencia->name; ?></option> 
															<? } ?> 
															</br> 
															</select>
														<? } else {?> 		
														</br>					
														<label style="line-height: 14px; width: 190px; font-size: 15px; color: #a9a9a9!important; text-align: center; margin-top: 20px" > 
															<? echo utf8ToHtml('Não Informado') ?> 
														</label>  
														<? } ?> 
														
													</fieldset>					
												</div>	

												<input type="button" class="botao" id="btatualizardados" onClick="setaParametros('CONTAS','',nrdconta,'CA');$('#nmtelant','#frmMenu').val('CARTAO');direcionaTela('CONTAS','no');return false;" value="Atualizar Dados Cadastrais"/>
											</fieldset>
												
										</form>
									</div>
									<div id="ValidaSenha"></div>
									<div id="divBotoes"> 
										<a href="#" class="botao" id="btvoltar" onclick="exibeRotina($('#divRotina'));fechaRotina($('#divUsoGenerico'),$('#divRotina'));return false;">Voltar</a>
										<?php if ($coop_envia_cartao && !$pa_envia_cartao) { ?>
										<a href="#" class="botao botaoDesativado" id="brprosseguir" onClick="return false;">Prosseguir</a> 
										<?php } else { ?>
										<a href="#" class="botao" id="brprosseguir" onClick="confirmaEndereco('<?php echo $tipoacao; ?>');return false;">Prosseguir</a> 
										<?php } ?>
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
 
	function selectRadio(elem){  
		$(elem).find('input:radio').attr('checked', true); 
		console.log(elem); 
	};

	$("#divOpcoesDaOpcao1").css("display","block");
	$("#divConteudoCartoes").css("display","none");
	if($("#dssituac").val() == "Em estudo" || $("#dssituac").val() =="Estudo" ){
		
		verificaAutorizacoes();
		
	}else{
		$(".imprimeTermoBTN").show();
		hideMsgAguardo();
		bloqueiaFundo(divRotina);				
	}
	controlaLayout('frmListaEnderecos');

</script>
