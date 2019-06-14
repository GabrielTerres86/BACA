<?php
/*!
 * FONTE        : apresenta_form_cargo_funcao.php                    Última alteração: 
 * CRIAÇÃO      : Jonata (Mouts)
 * DATA CRIAÇÃO : Setembro/2018
 * OBJETIVO     : Rotina para apresentar form de alteração para o cargo/funcao
 * --------------
 * ALTERAÇÕES   :  
 *				1 - Adicionar data em option do select cdfuncao de flgvigencia
 					Bruno Luiz K. - Mouts - 17/09/2018
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

        exibirErro('error',$msgError,'Alerta - Ayllos','',false);
    }


	$cdoperac = (isset($_POST["cdoperac"])) ? $_POST["cdoperac"] : 0; //A -> Alterar, I -> Inserir
	$cdfuncao = (isset($_POST["cdfuncao"])) ? $_POST["cdfuncao"] : 0; 
    $dtinicio_vigencia = (isset($_POST["dtinicio_vigencia"])) ? $_POST["dtinicio_vigencia"] : "";

	$nrdrowid = (isset($_POST["nrdrowid"])) ? $_POST["nrdrowid"] : 0;
		
	$xml = "<Root>";
	$xml .= " <Dados>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "TELA_PESSOA", "BUSCA_CARGOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObject = getObjectXML($xmlResult);
	
	if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
		if ($msgErro == "") {
			$msgErro = $xmlObject->roottag->tags[0]->cdata;
		}

		exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'#btVoltar\',\'divBotoesTabelaCadastro\').focus();',false);
	}

	$registros = $xmlObject->roottag->tags[0]->tags;
   		
	?>
		<table cellpadding="0" cellspacing="0" border="0" width="100%">
			<tr>
				<td align="center">		
					<table border="0" cellpadding="0" cellspacing="0" width="400px">
						<tr>
							<td>
								<table width="100%" border="0" cellspacing="0" cellpadding="0">
									<tr>
										<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
										<td class="txtBrancoBold"  background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo utf8ToHtml('CARGO/FUNÇÃO') ?></td>
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
													<form id="frmCargoFuncao" name="frmCargoFuncao" class="formulario" style="display:none;">														
																		
														<input type="hidden" id="nrdrowid" name="nrdrowid" value="<? echo $nrdrowid; ?>" />							
														<input type="hidden" id="cdfuncao_inativar" name="cdfuncao_inativar" value="<? echo $cdfuncao; ?>" />							
														
														<fieldset id="fsetCargoFuncao" name="fsetCargoFuncao" style="padding:0px; margin:0px; padding-bottom:10px;">
															
															<legend><? echo "Cargo/Fun&ccedil;&atilde;o"; ?></legend>
															
															<label for="dtinicio_vigencia"><? echo utf8ToHtml('Inicio Vig&ecirc;ncia:') ?></label>
															<input type="text" id="dtinicio_vigencia" name="dtinicio_vigencia" 
															value="<?echo getByTagName($registro->tags,'nrdconta');?>"
															/>
															
															<br />
															
															<label for="dtfim_vigencia"><? echo utf8ToHtml('Fim Vig&ecirc;ncia:') ?></label>
															<input type="text" id="dtfim_vigencia" name="dtfim_vigencia" value="<?echo getByTagName($registro->tags,'nrdconta');?>"/>
															
															<br />
															
															<label for="cdfuncao"><? echo utf8ToHtml('Tipo V&iacute;nculo:') ?></label>
															<select id="cdfuncao" name="cdfuncao">
																<?php
																	foreach ($registros as $r) {
																		?>
																			<option 
																			value="<?= getByTagName($r->tags, 'cdfuncao'); ?>" 
																			data-flgvigencia="<? echo getByTagName($r->tags,'flgvigencia'); ?>"
																			>
																			<?= getByTagName($r->tags, 'dsfuncao'); ?>
																			</option> 
																				
																		<?php
																		
																	}
																?>
															</select>
															
														</fieldset>
	
													</form>

													<div id="divBotoesCargoFuncao" style='text-align:center; margin-bottom: 10px; margin-top: 10px; display:none;' >
																																
														<a href="#" class="botao" id="btVoltar" onClick="fechaRotina($('#divRotina')); return false;">Voltar</a>																																							
														
														<?if($cdoperac == 'A'){?>
															<a href="#" class="botao" id="btConcluir" onClick="showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','inativarCargoFuncao();','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));$(\'#btVoltar\',\'#divBotoesCargoFuncao\').focus();','sim.gif','nao.gif');return false;">Concluir</a>	
														<?}else{?>
															<a href="#" class="botao" id="btConcluir" onClick="showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','incluirCargoFuncao();','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));$(\'#btVoltar\',\'#divBotoesCargoFuncao\').focus();','sim.gif','nao.gif');return false;">Concluir</a>	
														<?}?>
														
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
						
			$('#divRotina').centralizaRotinaH();
			exibeRotina($('#divRotina'));
			hideMsgAguardo();
			bloqueiaFundo($('#divRotina'));
			formataFormCargoFuncao('<?echo $cdoperac;?>');
			
			$("#cdfuncao option[value='<? echo $cdfuncao ?>']",'#frmCargoFuncao').attr('selected',"selected");
            $("#dtinicio_vigencia",'#frmCargoFuncao').val('<? echo $dtinicio_vigencia ?>');
            setBehaviorFormCargoFuncao('<?echo $cdoperac;?>');
				
		</script>
	<?
	
 ?>
