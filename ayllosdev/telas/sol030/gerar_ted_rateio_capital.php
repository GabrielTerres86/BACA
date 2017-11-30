<?php
/*!
 * FONTE        : gerar_ted_rateio_capital.php                    Última alteração:
 * CRIAÇÃO      : Jonata (RKAM)
 * DATA CRIAÇÃO : Agosto/2017
 * OBJETIVO     : Responsável por enviar as TED`s referente ao reteio de capital
 * --------------
 * ALTERAÇÕES   :  
 *
 */
?>

<?php

    session_start();
    require_once('../../includes/config.php');
    require_once('../../includes/funcoes.php');
    require_once('../../includes/controla_secao.php');
    require_once('../../class/xmlfile.php');
    isPostMethod();

    // Carrega permissões do operador
    require_once('../../includes/carrega_permissoes.php');

    $cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';

    if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {

        exibirErro('error',$msgError,'Alerta - Ayllos','');
    }

	$xml  = "";
	$xml .= "<Root>";
	$xml .= "   <Dados>";
	$xml .= "	   <cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "   </Dados>";
	$xml .= "</Root>";
		
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "TELA_SOL030", "GERAR_TED_RETEIO_CAPITAL", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObj = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro  = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
			 
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','estadoInicial();',false);		
							
	}
	
	$registros = $xmlObj->roottag->tags[0]->tags;
	$vlrtotal  = $xmlObj->roottag->attributes["VLRTOTAL"];
	
	if(count($registros) == 0){
		
		exibirErro('inform','Opera&ccedil;&atilde;o efetuada com sucesso.','Alerta - Ayllos','estadoInicial();');		
		
	}else{?>

		<table cellpadding="0" cellspacing="0" border="0" width="100%">
			<tr>
				<td align="center">		
					<table border="0" cellpadding="0" cellspacing="0" width="100%">
						<tr>
							<td>
								<table width="100%" border="0" cellspacing="0" cellpadding="0">
									<tr>
										<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
										<td class="txtBrancoBold"  background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">INCONSISTÊNCIAS</td>
										<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina($('#divRotina')); return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
										<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
									</tr>
								</table>     
							</td> 
						</tr> 																						
						<tr>
							<td class="tdConteudoTela" align="center">
								<table width="100%" border="0" cellspacing="0" cellpadding="0">
									<tr>
										<td align="left" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
											<div id="divConteudo">																														
																						
												<form id="frmInconsistencias" name="frmInconsistencias" class="formulario">

													<fieldset id="fsetInconsistencias" name="fsetInconsistencias" style="padding:0px; margin:0px; padding-bottom:10px;">
														
														<legend><? echo "Inconsist&ecirc;ncias"; ?></legend>
														
														<div class="divRegistros">		
															<table>
																<thead>
																	<tr>
																		<th>Conta</th>
																		<th>Cr&iacute;tica</th>
																		<th>Valor</th>
																	</tr>
																</thead>
																<tbody>
																	<? for ($i = 0; $i < count($registros); $i++) {    ?>
																	
																		<tr>	
																			<td><span><? echo formataContaDV(getByTagName($registros[$i]->tags,'nrdconta')); ?></span><? echo formataContaDV(getByTagName($registros[$i]->tags,'nrdconta')); ?>
																			<td><span><? echo getByTagName($registros[$i]->tags,'dscritic'); ?></span> <? echo getByTagName($registros[$i]->tags,'dscritic'); ?> </td>
																			<td><span><?php echo str_replace(",",".",getByTagName($registros[$i]->tags,'vldcotas')); ?></span><?php echo number_format(str_replace(",",".",getByTagName($registros[$i]->tags,'vldcotas')),2,",","."); ?>
							
																		</tr>	
																	<? } ?>
																</tbody>	
															</table>
														</div>
														<div id="divRegistrosRodape" class="divRegistrosRodape">
															<table>	
																<tr>
																	<td>&nbsp;</td>
																	<td>Total: <? echo number_format(str_replace(",",".",$vlrtotal),2,",","."); ?></td>
																	<td>&nbsp;</td>
																</tr>
															</table>
														</div>	
													</fieldset>
													
												</form>

												<div id="divBotoesInconsistencias" style='text-align:center; margin-bottom: 10px; margin-top: 10px; display:block;'>
																															
													<a href="#" class="botao" id="btVoltar" onClick="fechaRotina($('#divRotina'),'','estadoInicial();');return false;">Voltar</a>	
													
												</div>

											<div>																																						
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
			
			$('#divRotina').css({'width':'820px'});
			$('#divRotina').centralizaRotinaH();
			exibeRotina($('#divRotina'));
			hideMsgAguardo();
			bloqueiaFundo($('#divRotina'));
			
			formataTabelaContasTedCapital();	
				
		</script>

	<?}
	
?>
