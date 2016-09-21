<? 
/*!
 * FONTE        : formulario_endereco.php
 * CRIAÇÃO      : Rodolpho Telmo e Rogérius Militão (DB1)
 * DATA CRIAÇÃO : Abril/2011 
 * OBJETIVO     : Formulário para inclusão generica de endereço
 */	
?>

<div id="divFormularioEndereco" class="divPesquisa">
	<table cellpadding="0" cellspacing="0" border="0" width="100%">
		<tr>
			<td align="center">		
				<table border="0" cellpadding="0" cellspacing="0" width="545px">
					<tr>
						<td>
							<table width="100%" border="0" cellspacing="0" cellpadding="0">
								<tr>
									<td width="11"><img src="<? echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
									<td class="txtBrancoBold ponteiroDrag" style="text-transform: uppercase;" background="<? echo $UrlImagens; ?>background/tit_tela_fundo.gif"><span class="tituloJanelaPesquisa ponteiroDrag"><? echo utf8ToHtml('Inclusão de Endereço'); ?></span></td>
									<td width="12" id="tdTitTela" background="<? echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a class="fecharPesquisa"><img src="<? echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
									<td width="8"><img src="<? echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
								</tr>
							</table>     
						</td> 
					</tr> 																						
					<tr>
						<td class="tdConteudoTela" align="center">
							<table width="100%" border="0" cellspacing="0" cellpadding="0">
								<tr>
									<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
										<table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
											<tr>
												<td align="center" valign="center">												

													<!-- INICIO DO FORMULARIO -->
													<!-- FORMULARIO MONTADO DINAMICAMNETE -->
													<form name="formFormularioEndereco" id="formFormularioEndereco" class="formulario">
														
														<label for="nrcepend"><? echo utf8ToHtml('CEP:') ?></label>
														<input name="nrcepend" id="nrcepend" type="text" />																												
														
														<label for="dstiplog"><? echo utf8ToHtml('Tipo:') ?></label>
														<input name="dstiplog" id="dstiplog" type="text" />														
														<br />
														
														<label for="nmreslog"><? echo utf8ToHtml('Logradouro:') ?></label>
														<input name="nmreslog" id="nmreslog" type="text" />														
														<br />
														
														<label for="dscmplog"><? echo utf8ToHtml('Complemento:') ?></label>
														<input name="dscmplog" id="dscmplog" type="text" />														
														<br />
								
														<label for="nmresbai"><? echo utf8ToHtml('Bairro:') ?></label>
														<input name="nmresbai" id="nmresbai" type="text" />														
														<br />	
														
														<label for="nmrescid"><? echo utf8ToHtml('Cidade:') ?></label>
														<input name="nmrescid" id="nmrescid" type="text" />
														
														<label for="cdufende"><? echo utf8ToHtml('U.F.:') ?></label>
														<? echo selectEstado('cdufende', '', '1' ); ?>														
														<br />														
																											
														<label for="botao"></label>
														<input type="image" id="btSalvar" src="<? echo $UrlImagens; ?>botoes/concluir.gif" />
														<input type="image" id="btLimpar" src="<? echo $UrlImagens; ?>botoes/limpar.gif" />														
													</form>
																										
												</td>
											</tr>
										</table>																												
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

	var rotulos = $('label','#formFormularioEndereco');
	var rotulos_linha = $('label[for="dstiplog"],label[for="cdufende"]','#formFormularioEndereco');	
	rotulos.addClass('rotulo').css({'width':'120px'});
	rotulos_linha.removeClass('rotulo').addClass('rotulo-linha').css('width','');
	
	var campos = $('input[type="text"], select','#formFormularioEndereco');	
	campos.addClass('campo alphanum');
	
	var cCep 			= $('#nrcepend','#formFormularioEndereco');
	var cTipoLogr 		= $('#dstiplog','#formFormularioEndereco');	
	var cLogradouroRes 	= $('#nmreslog','#formFormularioEndereco');	
	var cBairroRes 		= $('#nmresbai','#formFormularioEndereco');	
	var cCidadeRes 		= $('#nmrescid','#formFormularioEndereco');
	var cEstado 		= $('#cdufende','#formFormularioEndereco');
	var cComplemento	= $('#dscmplog','#formFormularioEndereco');

	cCep.addClass('cep').css('width','70px');
	cTipoLogr.attr('maxlength','25').css('width','218px');	
	cLogradouroRes.attr('maxlength','40').css('width','389px');
	cComplemento.attr('maxlength','90').css('width','389px');
	cBairroRes.attr('maxlength','40').css('width','389px');	
	cCidadeRes.attr('maxlength','50').css('width','313px');
	cEstado.css('width','50px');	

	$('#btSalvar','#formFormularioEndereco').click( function(){
		manterEndereco('V');
		return false;
	});
	
	$('#btLimpar','#formFormularioEndereco').click( function(){
		$('#formFormularioEndereco').limpaFormulario();
		return false;
	});	
	
</script>
