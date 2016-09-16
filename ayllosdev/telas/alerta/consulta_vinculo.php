<?php

	/**********************************************************************************
	  Fonte: consulta_vinculo.php                                               
	  Autor: Adriano                                                  
	  Data : Fevereiro/2013                       Última Alteração: 
	                                                                   
	  Objetivo  : Realiza consulta de vinculos para o cpf informado na tela ALERTA.             
	                                                                 
	  Alterações: 										   			  
	                                                                  
	***********************************************************************************/

	session_start();
	
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nrcpfcgc"]) ||
		!isset($_POST["nriniseq"]) || 
		!isset($_POST["nrregist"]) || 
		!isset($_POST["cddopcao"])) {
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos','',false);
		
	}	
	
	$nrcpfcgc = $_POST["nrcpfcgc"];
	$nrregist = (isset($_POST["nrregist"])) ? $_POST["nrregist"] : 30;
	$nriniseq = (isset($_POST["nriniseq"])) ? $_POST["nriniseq"] : 1;	
	$cddopcao = $_POST["cddopcao"];
	
	$xmlConsultaVinculo  = "";
	$xmlConsultaVinculo .= "<Root>";
	$xmlConsultaVinculo .= " <Cabecalho>";
	$xmlConsultaVinculo .= "    <Bo>b1wgen0117.p</Bo>";
	$xmlConsultaVinculo .= "    <Proc>consulta_vinculo</Proc>";
	$xmlConsultaVinculo .= " </Cabecalho>";
	$xmlConsultaVinculo .= " <Dados>";
	$xmlConsultaVinculo .= "	 <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlConsultaVinculo .= "	 <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlConsultaVinculo .= "	 <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlConsultaVinculo .= "	 <idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlConsultaVinculo .= "	 <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlConsultaVinculo .= "	 <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlConsultaVinculo .= "     <nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
	$xmlConsultaVinculo .= "	 <nrregist>".$nrregist."</nrregist>";
	$xmlConsultaVinculo .= "	 <nriniseq>".$nriniseq."</nriniseq>";
	$xmlConsultaVinculo .= " </Dados>";
	$xmlConsultaVinculo .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlConsultaVinculo);
		
	$xmlObjConsultaVinculo = getObjectXML($xmlResult);
		
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjConsultaVinculo->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjConsultaVinculo->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}   

	$registros = $xmlObjConsultaVinculo->roottag->tags[0]->tags;
	$qtregist = $xmlObjConsultaVinculo->roottag->tags[0]->attributes["QTREGIST"];		
	
	if($cddopcao == "C"){?>				
	
		<table id="tbVinculo"cellpadding="0" cellspacing="0" border="0" width="100%">
			<tr>
				<td align="center">		
					<table border="0" cellpadding="0" cellspacing="0" width="100%">
						<tr>
							<td>
								<table width="100%" border="0" cellspacing="0" cellpadding="0">
									<tr>
										<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
										<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">CONTAS VINCULADAS</td>
										<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina($('#divUsoGenerico'));$('#divUsoGenerico').html('');"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
										<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
									</tr>
								</table>     
							</td> 
						</tr>    
						<tr>
							<td class="tdConteudoTela" align="center">	
								<table width="100%" border="0" cellspacing="0" cellpadding="0">
									<tr>
										<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
											<div id="divConteudoOpcao">
																									
												<fieldset id="Informacoes">
												
													<legend><? if($qtregist > 0){echo "Registro(s) encontrado(s)";}else{echo "Registro(s) encontrado(s)";} ?></legend>
												
													<div class="divRegistros">
													  <table>
														<thead>
														   <tr>
															  <th>Cooperativa</th>
															  <th>Conta</th>
															  <th>Nome</th>
															  <th>Conta/Vinculo</th>
															  <th>CPF/CNPJ Vinculo</th>
															  <th>Nome/Vinculo</th>
															  <th>Tipo/Vinculo</th>
															</tr>
														</thead>
														<tbody>
															<? foreach( $registros as $result ) {     	?>
													
															   <tr>
																 <td><span><? echo getByTagName($result->tags,'nmrescop'); ?></span><? echo getByTagName($result->tags,'nmrescop'); ?> </td>
																 <td><span><? echo getByTagName($result->tags,'nrdconta'); ?></span><? echo formataContaDV(getByTagName($result->tags,'nrdconta')); ?> </td>
																 <td><span><? echo getByTagName($result->tags,'nmprimtl'); ?></span><? echo getByTagName($result->tags,'nmprimtl'); ?> </td>
																 <td><span><? echo getByTagName($result->tags,'nrctavin'); ?></span><? echo formataContaDV(getByTagName($result->tags,'nrctavin')); ?> </td>
																 <td><span><? echo getByTagName($result->tags,'nrcpfvin'); ?></span><? echo getByTagName($result->tags,'nrcpfvin'); ?> </td>
																 <td><span><? echo getByTagName($result->tags,'nmctavin'); ?></span><? echo getByTagName($result->tags,'nmctavin'); ?> </td>
																 <td><span><? echo getByTagName($result->tags,'tpdovinc'); ?></span><? echo getByTagName($result->tags,'tpdovinc'); ?> </td>
																	
															   </tr>
															<? } ?>
														 </tbody>
													  </table>
													</div>
													<div id="divRegistrosRodape" class="divRegistrosRodape">
														<table>	
															<tr>
																<td>
																	<? if (isset($nriniseq)) { ?>
																		   Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?>
																		<? } ?>
																</td>
															</tr>
														</table>
													</div>
												
												</fieldset>
												
												<div id="divBotoes" style="margin-top:5px; margin-bottom :10px; display:none; text-align: center;">
													<a href="#" class="botao" id="btVoltar"   onClick="fechaRotina($('#divUsoGenerico'));$('#divUsoGenerico').html('');" >Voltar</a>
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
			
			tabelaVinculo();
			$("#divBotoes","#divUsoGenerico").css("display","block");
			
			
		</script>
		
		
	<?}else{
	
		if($qtregist > 0){?>
		
			<script type="text/javascript">
			
				showError("inform","Este CPF/CNPJ possui v&iacute;nculo(s). Consulte a op&ccedil;&atilde;o \"V\" ou \"C\".","Alerta - Ayllos","$('#divUsoGenerico').css('visibility','hidden');$('#nrcpfcgc','#divDetalhes').focus();");
				
			</script>
			
		<?}else{?>
			
			<script type="text/javascript">
			
				showError("inform","Este CPF/CNPJ n&atilde;o possui v&iacute;nculo(s).","Alerta - Ayllos","$('#divUsoGenerico').css('visibility','hidden');$('#nrcpfcgc','#divDetalhes').focus();");
				
			</script>
		
		<?}
		
	}
		 			
				
			
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 		
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","estadoInicial();");';
		exit();
	}	
			 
?>



				

