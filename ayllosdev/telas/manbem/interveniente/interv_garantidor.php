<?php

	//************************************************************************//
	//*** Fonte: interv_garantidor.php                                     	***//
	//*** Autor: Maykon D. Granemann                                       	***//
	//*** Data : Agosto/2018                  Última Alteração: 27/08/2018 	***//
	//***                                                                  	***//
	//*** Objetivo  : Montar o HTML para cadastro de interveniente garan-  	***//
	//***             tidor 	                                           	***//
	//***                                                                  	***//	 
	//*** Alterações: 													   	***//
	//***																	***//
	//***                                                                  	***//
	//***																	***//
	//***																   	***//
	//***																	***//
	//*************************************************************************//
?>

<?php
	include('../includes/requires.php');
	$nrcpfcgc = buscaParametroRequisicaoPost('nrcpfcgc');
	$nrcpfcgc = formataTipoPessoaInterveniente($nrcpfcgc);	
?>

<link href="../manbem/css/interveniente.css" rel="stylesheet" type="text/css">
<table cellpadding="0" cellspacing="0" border="0" >
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0"  >
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo utf8ToHtml('Interveniente') ?></td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">
									<a href="#" onClick="cancelaCadastroInterveniente();return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a>
								</td>
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
										<form name="frmIntevAnuente" id="frmIntevAnuente">	

											<input id="nrctremp" name="nrctremp" type="hidden" value="" />
											
											<fieldset>
												<legend>Dados do interveniente</legend>
												<div class="cabecalho">
													<label for="nrctaava">Conta:</label>
													<input name="nrctaava" id="nrctaava" type="text" value="0" disabled/>
												</div>
												<hr>
												<div class="bloco">													
													<div>
														<label for="nmdavali">Nome:</label>
														<input name="nmdavali" id="nmdavali" type="text" value="" />
													</div>
													<div>
														<label for="nrcpfcgc">C.P.F.:</label>
														<input name="nrcpfcgc" id="nrcpfcgc" type="text" value="<?echo $nrcpfcgc?>" disabled/>
													</div>
												</div>
												<div class="bloco">
													<div>
														<label for="tpdocava">Doc.:</label>
														<select name="tpdocava" id="tpdocava" class="menor">
															<option value=""  > - </option> 
															<option value="CH">CH</option>
															<option value="CI">CI</option>
															<option value="CP">CP</option>
															<option value="CT">CT</option>
														</select>
														<label for="nrdocava" style='display:none'>Nr. Doc.:</label>
														<input name="nrdocava" id="nrdocava" type="text" value="" class="medio"/>
													</div>
													<div>
														<label for="cdnacion">Nacio.:</label>
														<input name="cdnacion" id="cdnacion" type="text"  class="menor-lupa"/>
														<a href="javascript:pesquisa('cdnacion');">
															<img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif">
														</a>
														<input name="dsnacion" id="dsnacion" type="text" value="" class="medio" readonly/>
													</div>
												</div>	
											</fieldset>
											
											<fieldset>
												<legend><? echo utf8ToHtml('Dados ConjugÃª') ?></legend>
												<div class="bloco">
													<div>
														<label for="nmconjug"><?php echo utf8ToHtml('ConjugÃª:') ?></label>
														<input name="nmconjug" id="nmconjug" type="text" value="" />
													</div>			
													<div>
														<label for="nrcpfcjg">C.P.F.:</label>
														<input name="nrcpfcjg" id="nrcpfcjg" type="text" value="" onKeyPress="mascaraCPF(event)" onKeyUp="mascaraCPF(event)"/>
													</div>
												</div>
												<div class="bloco">
													<div>
														<label for="tpdoccjg">Doc.:</label>
														<select name="tpdoccjg" id="tpdoccjg" class="menor">
															<option value=""  > - </option> 
															<option value="CH">CH</option>
															<option value="CI">CI</option>
															<option value="CP">CP</option>
															<option value="CT">CT</option>
														</select>														
														<input name="nrdoccjg" id="nrdoccjg" type="text" value="" class="medio"/>
													</div>
												</div>
											</fieldset>
											
											<fieldset>
												<legend><?php echo utf8ToHtml('EndereÃ§o') ?></legend>
												<div class="bloco">
													<div>
														<label for="nrcepend">CEP:</label>
														<input name="nrcepend" id="nrcepend" type="text" value="" />
														<a href="#" onclick="pesquisa('nrcepend')">
															<img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif">
														</a>
													</div>
													<div>
														<label for="nrendere"><? echo utf8ToHtml('Nro.:') ?></label>
														<input name="nrendere" id="nrendere" type="text" value="" />
													</div>
													<div>
														<label for="nrcxapst"><? echo utf8ToHtml('Cx.Postal:') ?></label>
														<input name="nrcxapst" id="nrcxapst" type="text" value="" />		
													</div>
													<div>
														<label for="cdufresd">UF:</label>
														<? echo selectEstado('cdufresd','', 1) ?>
													</div>
												</div>
												<div class="bloco">
													<div>
														<label for="dsendre1"><? echo utf8ToHtml('End.:') ?></label>
														<input name="dsendre1" id="dsendre1" type="text" value=""  class="maior"/>
													</div>
													<div>
														<label for="complend"><? echo utf8ToHtml('Comple.:') ?></label>
														<input name="complend" id="complend" type="text" value="" class="maior"/>
													</div>
													<div>
														<label for="dsendre2">Bairro:</label>
														<input name="dsendre2" id="dsendre2" type="text" value="" class="maior"/>
													</div>
													<div>
														<label for="nmcidade">Cidade:</label>
														<input name="nmcidade" id="nmcidade" type="text" value=""class="maior" />
													</div>
												</div>
											</fieldset>
												
											<fieldset>
												<legend><?php echo utf8ToHtml('Contato') ?></legend>
												<div class="bloco">
													<div>
														<label for="dsdemail">E-mail:</label>
														<input name="dsdemail" id="dsdemail" type="text" value="" />
													</div>
												</div>
												<div class="bloco">
													<div>
														<label for="nrfonres">Fone:</label>
														<input name="nrfonres" id="nrfonres" type="text" value="" />
													</div>
												</div>													
											</fieldset>
										
										</form>	
										<table>
											<tr>
												<td align="center" height="30">
													<table border="0" cellpadding="0" cellspacing="0">
														<tr>
															<td><input type="image" src="<?php echo $UrlImagens; ?>botoes/cancelar.gif" onClick="cancelaCadastroInterveniente();return false;"></td>
															<td width="20"></td>
															<td><input type="image" id="btnGravaInterveniente" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="validaInterveniente();return false;"></td>
														</tr>
													</table>
												</td>
											</tr>										
										</table>																		
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
<div id="pesquisa_endereco_interveniente">

</div>

<script>
$(function(){
	$("#divPesquisaEndereco").css('z-index', 1000);
	$("#divFormularioEndereco").css('z-index', 1001);
	controlaPesquisa();
	recuperaFormInterveniente();
});
</script>