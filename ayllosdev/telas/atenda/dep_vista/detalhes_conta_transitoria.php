<?php
	/*!
	* FONTE        : detalhes_atraso.php
	* CRIAÇÃO      : Marcel Kohls (AMCom)
	* DATA CRIAÇÃO : 15/03/2018
	* OBJETIVO     : Exibe detalhes dos valores de atraso
	*/

	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');

	//Mensageria referente a data de inclusão de prejuízo
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "    <nrdconta>".$_POST["nrdconta"]."</nrdconta>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "TELA_ATENDA_DEPOSVIS", "BUSCA_DT_INCLUSAO_PREJU", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");		
	$xmlObjeto = getObjectXML($xmlResult);	

	$param = $xmlObjeto->roottag->tags[0]->tags[0];

	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos',"controlaOperacao('');",false); 
	}else{
		$datpreju = getByTagName($param->tags,'datpreju');	    
		$datatual = getByTagName($param->tags,'datatual');  		
	}

	//Recebe as datas da tela, quando informadas
	if(!empty($_POST['dtiniper'])){
		$datpreju = $_POST["dtiniper"];
	}
	if(!empty($_POST["dtfimper"])){
		$datatual = $_POST['dtfimper'];
	}

	//Mensageria referente a lançamentos da conta transitória
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "    <nrdconta>".$_POST["nrdconta"]."</nrdconta>";
	$xml .= "    <dtiniper>".$datpreju."</dtiniper>";
	$xml .= "    <dtfimper>".$datatual."</dtfimper>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "PREJ0004", "LISTA_LANCAMENTOS_CT", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");		
	$xmlObjeto = getObjectXML($xmlResult);	

	$lancamentos = '';

	if(strtoupper($xmlObjeto->roottag->tags[0]->name) != "ERRO") {  
		$lancamentos = $xmlObjeto->roottag->tags[0]->tags[4]->tags; 
	}

	//Mensageria referente a situação da conta e se já foi transferido para prejuízo
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "    <nrdconta>".$_POST["nrdconta"]."</nrdconta>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "PREJ0003", "BUSCA_SIT_BLOQ_PREJU", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");		
	$xmlObjeto = getObjectXML($xmlResult);	

	$param = $xmlObjeto->roottag->tags[0]->tags[0];

	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos',"controlaOperacao('');",false); 
	}else{
		$inprejuz = getByTagName($param->tags,'inprejuz');	    
		$ocopreju = getByTagName($param->tags,'ocopreju');	    
	}

?>

<table id="tdImp"cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">    
			<table border="0" cellpadding="0" cellspacing="0" width="650">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">Detalhes dos Valores Bloqueados por <?php echo utf8_decode('Prejuízo'); ?></td>
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
                    <form action="<?php echo $UrlSite; ?>telas/atenda/dep_vista/gerar_extrato_CT.php" name="frmDetalhesCT" id="frmDetalhesCT" method="post" class="formulario">
							
											<input type="hidden" name="iniregis" id="iniregis" value="<?php echo $iniregis; ?>">
                      						<input type="hidden" name="nrdconta" id="nrdconta" value="<?php echo $_POST["nrdconta"]; ?>">
                      						<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
                      		
											<label class="rotulo txtNormalBold" style="width: 235px;" for="dtiniper"><? echo utf8ToHtml('Período:') ?></label>
											<input name="dtiniper" class="campo FirstInputModal" id="dtiniper" style="width: 65px;" type="text" value="<?php echo $datpreju; ?>" autocomplete="no">
											
											<label class="rotulo-linha txtNormalBold" for="dtfimper"><? echo utf8ToHtml(' à ') ?></label>
											<input name="dtfimper" class="campo" id="dtfimper" style="width: 65px;" type="text" value="<?php echo $datatual; ?>" autocomplete="no">                      
											<input class="LastInputModal" type="image" src="<?php echo $UrlImagens; ?>botoes/pesquisar.gif" onclick="mostraDetalhesCT();return false;">											                    
										</form>
										<br/>
										<form action="" method="post" name="frmDadosDetalhesAtraso" id="frmDadosDetalhesAtraso" class="formulario" >
											<fieldset>
												<div id="divTabContraOrdens">
													<div class="divRegistros">
														<table>
															<thead>
																<tr>
																	<th><?php echo utf8ToHtml('Data');      ?></th>
																	<th><?php echo utf8ToHtml('Histórico'); ?></th>
																	<th><?php echo utf8ToHtml('Docmto');    ?></th>
																	<th><?php echo utf8ToHtml('D/C');       ?></th>
																	<th><?php echo utf8ToHtml('Valor');     ?></th>
																	<th><?php echo utf8ToHtml('Saldo');     ?></th>
																</tr>
															</thead>
															<tbody>
																<?php
																	foreach($lancamentos as $lancamento){                                    
																		echo "<tr>";
																		echo "<td>".getByTagName($lancamento->tags,'dtmvtolt')."</td>"; 
																		echo "<td>".getByTagName($lancamento->tags,'dsextrato')."</td>";
																		echo "<td>".getByTagName($lancamento->tags,'nrdocmto')."</td>";
																		echo "<td>".getByTagName($lancamento->tags,'indebcre')."</td>";
																		echo "<td>".getByTagName($lancamento->tags,'vllamnto')."</td>";
																		echo "<td>".getByTagName($lancamento->tags,'vlslddia')."</td>";
																		echo "</tr>";
																	}
																?>
															</tbody>
														</table>
													</div>
												</div>
											</fieldset>
										</form>
										<div id="divBotoes">
											<?php if($inprejuz == 1){ ?>
												<a href="#" class="botao" id="btDetVoltar" onClick="mostraPagamentoEmp();"><?php echo utf8_decode('Pagamento de Empréstimo'); ?></a>											  
												<a href="#" class="botao" id="btDetVoltar" onClick="mostraLiberacaoCC();"><?php echo utf8_decode('Liberação de Saque'); ?></a>
												<a href="#" class="botao" id="btDetVoltar" onClick="mostraPagamentoPrejuzCC();"><?php echo utf8_decode('Pagamento Prejuízo C/C'); ?></a>											  												
												<a href="#" class="botao" id="btDetVoltar" onClick="imprimeExtratoLancamentosCT();">Imprimir Extrato</a>
											<?php } ?>
											<?php if($inprejuz == 0 && $ocopreju == 'S'){ ?>
											   	<a href="#" class="botao" id="btDetVoltar" onClick="imprimeExtratoLancamentosCT();">Imprimir Extrato</a>
											<?php } ?>
											</br></br>
											<a href="#" class="botao" id="btDetVoltar" onClick="fechaRotina($('#divUsoGenerico'),divRotina);">Voltar</a>
										</div>
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
	// Formata layout
	formataLancamentosCT();
	
	// Controla Layout
	controlaLayout('frmDetalhesCT');

	// Esconde mensagem de aguardo
	hideMsgAguardo();

	// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
	blockBackground(parseInt($("#divRotina").css("z-index")));
</script>
