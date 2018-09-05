<?php 
	/************************************************************************
	 Fonte: bordero_mesa_titulos.php                                        
	 Autor: Luis Fernando (GFT)
	 Data : 25/03/2018
	                                                                  
	 Objetivo  : Lista os títulos de um borderô passíveis de análise na mesa de checagem
     - 01/06/2018 | Vitor Shimada Assanuma (GFT): Inclusão de todos os titulos do borderô, mas com o campo de decisão bloqueado quando não tem crítica CNAE
     - 09/08/2018 | Vitor Shimada Assanuma (GFT): Esconder o campo de Sim/Não quando não possuir crítica CNAE
     - 14/08/2018 | Vitor Shimada Assanuma (GFT): Rename do botão para: "Ver Detalhes da An&aacute;lise"
	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php"); 
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	
	setVarSession("nmrotina","DSC TITS - BORDERO");

	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrborder"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrborder = $_POST["nrborder"];

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}

    $xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
    $xml .= "   <nrborder>".$nrborder."</nrborder>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml,"TELA_APRDES","VERIFICA_STATUS_BORDERO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getClassXML($xmlResult);
    $root = $xmlObj->roottag;
    if ($root->erro){
		exibeErro($root->erro->registro->dscritic);
    }
    $bordero = $root->dados->bordero;
    $checagem = true;
    if($bordero->insitapr!='1' && $bordero->insitapr!='2'){ // Diferente de Aguardando Checagem e Checagem
    	$checagem = false;
    }
    else{
    	/*Verifica se algum operador já assumiu essa checagem, se não atribui ao operador que abriu a tela*/
	    if($bordero->insitapr=='1'){
		    $xml = "<Root>";
		    $xml .= " <Dados>";
		    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
		    $xml .= "   <nrborder>".$nrborder."</nrborder>";
		    $xml .= " </Dados>";
		    $xml .= "</Root>";

		    $xmlResult = mensageria($xml,"TELA_APRDES","ATUALIZA_CHECAGEM_OPERADOR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		    $xmlObj = getClassXML($xmlResult);
		    $root = $xmlObj->roottag;
		    if ($root->erro){
				exibeErro($root->erro->registro->dscritic);
		    }
		    $bordero->nmoperad = $root->dados->operador->nmoperad;
	    }
	}


    $xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
    $xml .= "   <nrborder>".$nrborder."</nrborder>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml,"TELA_APRDES","BUSCAR_TITULO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getClassXML($xmlResult);
    $root = $xmlObj->roottag;
    if ($root->erro){
		exibeErro($root->erro->registro->dscritic);
    }
    $dados = $root->dados;
	// Função para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","");';
		echo '</script>';
		exit();
	}
?>
<div id="divListaTitulos">
	<table cellpadding="0" cellspacing="0" border="0" width="100%">
		<tr>
			<td align="center">		
				<table border="0" cellpadding="0" cellspacing="0" width="350">
					<tr>
						<td>
							<table width="100%" border="0" cellspacing="0" cellpadding="0">
								<tr>
									<td width="11"><img src="<?echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
									<td id="<?php echo $labelRot; ?>" id="tdTitRotina" class="txtBrancoBold ponteiroDrag SetWindow SetFoco" background="<?echo $UrlImagens; ?>background/tit_tela_fundo.gif">An&aacute;lise de Border&ocirc;</td>
									<td width="12" id="tdTitTela" background="<?echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a id="btSair" href="#" onClick="encerraRotina();return false;"><img src="<?echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
									<td width="8"><img src="<?echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
								</tr>
							</table>     
						</td> 
					</tr>    
					<tr>
						<td class="tdConteudoTela" align="center">	
							<table width="100%" border="0" cellspacing="0" cellpadding="0">
								<tr>
									<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
										<div id="divTitulosChecagem">
											<form id="formFinalizarChecagem" class="formulario">
												<input type="hidden" id="nrdconta" name="nrdconta" value="<? echo $nrdconta; ?>" />
												<input type="hidden" id="nrborder" name="nrborder" value="<? echo $nrborder; ?>" />
												<div id="divTitulos" class="formulario">
													<fieldset>
														<legend>Border&ocirc;</legend>
															<? if ($checagem) {?>
																<h3>Esse border&ocirc; est&aacute; sendo analisado por: <?=$bordero->nmoperad?>.</h3>
															<? }
															else{ ?>
																<h3>O processo de checagem desse border&ocirc; foi conclu&iacute;do e s&oacute; pode ser visualizado.</h3>
															<? } ?>
													</fieldset>
													<fieldset>
														<legend>Aprovar T&iacute;tulos</legend>
														<div class="divRegistrosTitulos divRegistros">
															<table class="tituloRegistros">
																<thead>
																	<tr>
																		<th>Pagador</th>
																		<th>Telefone</th>
																		<th>Nosso N&uacute;mero</th>
																		<th>Valor</th>
																		<th>Vencimento</th>
																		<th>Liquidez</th>
																		<th>Concentra&ccedil;&atilde;o</th>
																		<th>Cr&iacute;ticas</th>
																		<th>Aprovar</th>
																	</tr>			
																</thead>
																<tbody>
																	<? foreach($dados->find("inf") AS $t) {?>
																		<tr onclick="selecionaTitulo('<?= $t->cdbandoc; ?>;<?= $t->nrdctabb; ?>;<?= $t->nrcnvcob; ?>;<?= $t->nrdocmto; ?>');">
																			<td><?php if ($t->flgenvmc->cdata == 1){ ?>
							    												<input type='hidden' name='titulos[]' value='<?= $t->cdbandoc; ?>;<?= $t->nrdctabb; ?>;<?= $t->nrcnvcob; ?>;<?= $t->nrdocmto; ?>'/>
							    												<?php } ?>
																				<? echo $t->nmdsacad; ?>
																			</td>
																			<td><? echo $t->nrcelsac; ?></td>
																			<td><? echo $t->nrnosnum; ?></td>
																			<td><? echo formataMoeda($t->vltitulo); ?></td>
																			<td><? echo $t->dtvencto; ?></td>
																			<td><? echo formataMoeda($t->nrliqpag)."%"; ?></td>
																			<td><? echo formataMoeda($t->nrconcen)."%"; ?></td>
															                <?if($t->flgcritdb=='S'){ ?>
															                	<td>Sim</td>
															                <? } 
															                else if($t->flgcritdb=='N'){ ?>
															                	<td>N&atilde;o</td>
															                <? }
															                else{ ?>
															                	<td>N&atilde;o Analisado</td>
															                <? } ?>
																			<td style="text-align:center;">
																				<select name="insitmch" style="float:none;" <?=$checagem && $t->flgenvmc->cdata == 1?"":" hidden "?>>
																					<option value=""></option>
																					<option value="S" <?=$t->insitmch=='1'?'selected':''?>>Sim</option>
																					<option value="N" <?=$t->insitmch=='2'?'selected':''?>>N&atilde;o</option>
																				</select>
																			</td>
																		</tr>
																	<? } ?>
																</tbody>
															</table>
														</div>
													</fieldset>
												</div>
											</form>
											<?include('criticas_bordero.php');?>
											<div id="divBotoesTitulosLimite" style="margin-bottom:10px;">
												<input type="button" class="botao" value="Voltar"  onClick="encerraRotina();return false; " />
												<input type="button" class="botao" value="Ver Detalhes da An&aacute;lise" onClick="visualizarDetalhes();return false;"/>
												<input type="button" class="botao" value="Confirmar An&aacute;lise" onClick='showConfirmacao("Deseja finalizar a an&aacute;lise do bordero?","Confirma&ccedil;&atilde;o - Ayllos","concluirChecagem()","bloqueiaFundo(divRotina)","sim.gif","nao.gif");' style="<?=$checagem?"":" display:none; "?>"/>
											</div>
										</div>
										<div id="divDetalheTitulo" >
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
</div>
<script type="text/javascript">
	// Muda o título da tela
	$("#tdTitRotina").html("ANALISAR BORDER&OCIRC;");

	hideMsgAguardo();

	// Bloqueia conteúdo que está átras do div da rotina
	blockBackground(parseInt($("#divRotina").css("z-index")));
	
</script>
