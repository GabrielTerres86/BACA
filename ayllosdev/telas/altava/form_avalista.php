<? 
 /*!
 * FONTE        : form_avalista.php
 * CRIAÇÃO      : Rogerius Militao (DB1)
 * DATA CRIAÇÃO : 21/12/2011
 * OBJETIVO     : Formulário para visualizar os avalista do contrato
 *
 * ALTERAÇÕES   : 21/11/2012 - Alterado botões do tipo campo <input> por
 *				  campo <a>, removido tag <span> (Daniel).
 *
 *				  15/07/2014 - Incluso novos campos (inpessoa e dtnascto). (Daniel) 	
 *				  28/08/2017 - Alterado tipos de documento para utilizarem CI, CN, 
 *							   CH, RE, PP E CT. (PRJ339 - Reinert)
 */	
 ?>

 <?
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	
	$i 			= $_POST['nrindice'];
	$avalista	= (!empty($_POST['avalista'])) ? unserialize($_POST['avalista']) : array()  ;
	$posicao	= $i == 1 ? 'primeiro' : 'segundo';
?>

<table cellpadding="0" cellspacing="0" border="0" >
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0"  >
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">&nbsp;</td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaAvalista(); return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
								<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
							</tr>
						</table>     
					</td> 
				</tr>    
				<tr>
					<td class="tdConteudoTela" align="center">	
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
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<div id="divConteudo">
										 
										 
										<form name="frmAvalista" id="frmAvalista" class="formulario condensado">	

											<fieldset>
												<legend>Dados Avalista <?php echo $i ?></legend>
											
												<label for="nrctaava">Conta:</label>
												<input name="nrctaava" id="nrctaava" type="text" value="<?php echo formataContaDV($avalista[$i]['nrctaava']) ?>" alt="Entre com o nome do <?php echo $posicao ?> avalista/fiador." />
												<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
												<a href="#" class="botao" id="btnOK3" >OK</a>
												
												<br />	
														
												<label for="nmdavali">Nome:</label>
												<input name="nmdavali" id="nmdavali" type="text" value="<?php echo $avalista[$i]['nmdavali'] ?>" alt="Entre com o nome do <?php echo $posicao ?> avalista/fiador." />
												<br />			
												
												<label for="nrcpfcgc">C.P.F.:</label>
												<input name="nrcpfant" id="nrcpfant" type="hidden" value="<?php echo $avalista[$i]['nrcpfcgc'] ?>" />
												<input name="nrcpfcgc" id="nrcpfcgc" type="text" value="<?php echo $avalista[$i]['nrcpfcgc'] ?>" alt="Entre com o CPF do <?php echo $posicao ?>  avalista." />
														
												<label for="tpdocava">Doc.:</label>
												<select name="tpdocava" id="tpdocava" alt="Entre com CI, CN, CH, RE, PP, CT.">
													<option value=""  > - </option> 
													<option value="CI" <?php echo $avalista[$i]['tpdocava'] == 'CI' ? 'selected' : '' ?>>CI</option>
													<option value="CN" <?php echo $avalista[$i]['tpdocava'] == 'CN' ? 'selected' : '' ?>>CN</option>
													<option value="CH" <?php echo $avalista[$i]['tpdocava'] == 'CH' ? 'selected' : '' ?>>CH</option>
													<option value="RE" <?php echo $avalista[$i]['tpdocava'] == 'RE' ? 'selected' : '' ?>>RE</option>
													<option value="PP" <?php echo $avalista[$i]['tpdocava'] == 'PP' ? 'selected' : '' ?>>PP</option>
													<option value="CT" <?php echo $avalista[$i]['tpdocava'] == 'CT' ? 'selected' : '' ?>>CT</option>
												</select>
												<input name="nrdocava" id="nrdocava" type="text" value="<?php echo $avalista[$i]['dscpfcgc'] ?>" alt="Entre com o Docto do <?php echo $posicao ?> avalista/fiador." />
												
												<br />	
												<label for="inpessoa">Tp Nat.:</label>
												<select name="inpessoa" id="inpessoa" alt="Entre com 1-Fisica 2-Juridica.">
													<option value=""  > - </option> 
													<option value="1" <?php echo $avalista[$i]['inpessoa'] == '1' ? 'selected' : '' ?> >1 - Fisica</option>
													<option value="2" <?php echo $avalista[$i]['inpessoa'] == '2' ? 'selected' : '' ?> >2 - Juridica</option>
												</select>	
												<label for="dtnascto">Data Nasc.:</label>
												<input name="dtnascto" id="dtnascto" type="text" value="<?php echo $avalista[$i]['dtnascto'] ?>" alt="Entre com data nascimento do <?php echo $posicao ?> avalista/fiador." />
												<br />
											</fieldset>
											
											<fieldset>
												<legend><? echo utf8ToHtml('Dados Conjugê') ?></legend>
																
												<label for="nmconjug"><?php echo utf8ToHtml('Conjugê:') ?></label>
												<input name="nmconjug" id="nmconjug" type="text" value="<?php echo $avalista[$i]['nmconjug'] ?>" alt="Entre com o nome do conjuge do <?php echo $posicao ?> avalista/fiador." />
																
												<label for="nrcpfcjg">C.P.F.:</label>
												<input name="nrcpfcjg" id="nrcpfcjg" type="text" value="<?php echo $avalista[$i]['nrcpfcjg'] ?>" alt="Entre com o CPF do conjuge do <?php echo $posicao ?>  avalista/fiador." />
													
												<label for="tpdoccjg">Doc.:</label>
												<select name="tpdoccjg" id="tpdoccjg" alt="Entre com CI, CN, CH, RE, PP, CT.">
													<option value=""  > - </option> 
													<option value="CI" <?php echo $avalista[$i]['tpdoccjg'] == 'CI' ? 'selected' : '' ?>>CI</option>
													<option value="CN" <?php echo $avalista[$i]['tpdoccjg'] == 'CN' ? 'selected' : '' ?>>CN</option>
													<option value="CH" <?php echo $avalista[$i]['tpdoccjg'] == 'CH' ? 'selected' : '' ?>>CH</option>
													<option value="RE" <?php echo $avalista[$i]['tpdoccjg'] == 'RE' ? 'selected' : '' ?>>RE</option>
													<option value="PP" <?php echo $avalista[$i]['tpdoccjg'] == 'PP' ? 'selected' : '' ?>>PP</option>
													<option value="CT" <?php echo $avalista[$i]['tpdoccjg'] == 'CT' ? 'selected' : '' ?>>CT</option>
												</select>
												<input name="nrdoccjg" id="nrdoccjg" type="text" value="<?php echo $avalista[$i]['dscpfcjg'] ?>" alt="Entre com o Docto do conjuge do <?php echo $posicao ?> avalista/fiador." />
												<br />
												
											</fieldset>
											
											<fieldset>
												<legend><?php echo utf8ToHtml('Endereço') ?></legend>
												
												<label for="nrcepend">CEP:</label>
												<input name="nrcepend" id="nrcepend" type="text" value="<?php echo formataCep($avalista[$i]['nrcepend']) ?>" alt="Entre com o CEP ou pressione F7 para pesquisar." />
												<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
												
												<label for="dsendre1"><? echo utf8ToHtml('End.:') ?></label>
												<input name="dsendre1" id="dsendre1" type="text" value="<?php echo $avalista[$i]['dsendav1'] ?>" />
												<br />
												
												<label for="nrendere"><? echo utf8ToHtml('Nro.:') ?></label>
												<input name="nrendere" id="nrendere" type="text" value="<?php echo $avalista[$i]['nrendere'] ?>" alt="Entre com o numero do endereco." />
												
												<label for="complend"><? echo utf8ToHtml('Comple.:') ?></label>
												<input name="complend" id="complend" type="text" value="<?php echo $avalista[$i]['complend'] ?>" alt="Informe o complemento do endereco." />
												<br />
												
												<label for="nrcxapst"><? echo utf8ToHtml('C.Postal:') ?></label>
												<input name="nrcxapst" id="nrcxapst" type="text" value="<?php echo $avalista[$i]['nrcxapst'] ?>" alt="Informe o numero da caixa postal." />		
												
												<label for="dsendre2">Bairro:</label>
												<input name="dsendre2" id="dsendre2" type="text" value="<?php echo $avalista[$i]['dsendav2'] ?>" />
												<br />	
												
												<label for="cdufresd">UF:</label>
												<? echo selectEstado('cdufresd',$avalista[$i]['cdufresd'], 1) ?>
														
												<label for="nmcidade">Cidade:</label>
												<input name="nmcidade" id="nmcidade" type="text" value="<?php echo $avalista[$i]['nmcidade'] ?>" />
												<br />
												
											</fieldset>
												
											<fieldset>
												<legend><?php echo utf8ToHtml('Contato') ?></legend>
												
												<label for="dsdemail">E-mail:</label>
												<input name="dsdemail" id="dsdemail" type="text" value="<?php echo $avalista[$i]['dsdemail'] ?>" alt="Entre com o email do <?php echo $posicao ?> avalista/fiador." />
												
												<label for="nrfonres">Fone:</label>
												<input name="nrfonres" id="nrfonres" type="text" value="<?php echo $avalista[$i]['nrfonres'] ?>" alt="Entre com o telefone do <?php echo $posicao ?> avalista/fiador." />
												<br />
													
											</fieldset>
												
										  
										</form>

										<div id="divMsgAjuda">
											<div id="divBotoes" >
												<a href="#" class="botao" id="btVoltar" onClick="fechaAvalista(); return false;">Voltar</a>
												<a href="#" class="botao" id="btSalvar" onClick="btnContinuar(); return false;">Continuar</a>
											</div>
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
