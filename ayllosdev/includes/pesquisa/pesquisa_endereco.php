<? 
/*!
 * FONTE        : pesquisa_endereco.php
 * CRIAÇÃO      : Rodolpho Telmo e Rogérius Militão (DB1)
 * DATA CRIAÇÃO : Abril/2011 
 * OBJETIVO     : Formulário para pesquisa gerérica de endereço
 */	
?>

<div id="divPesquisaEndereco" class="divPesquisa">
	<table cellpadding="0" cellspacing="0" border="0" width="100%">
		<tr>
			<td align="center">		
				<table border="0" cellpadding="0" cellspacing="0" width="545px">
					<tr>
						<td>
							<table width="100%" border="0" cellspacing="0" cellpadding="0">
								<tr>
									<td width="11"><img src="<? echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
									<td class="txtBrancoBold ponteiroDrag" style="text-transform: uppercase;" background="<? echo $UrlImagens; ?>background/tit_tela_fundo.gif"><span class="tituloJanelaPesquisa ponteiroDrag"><? echo utf8ToHtml('Pesquisa Endereço'); ?></span></td>
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
													<form name="formPesquisaEndereco" id="formPesquisaEndereco" class="formulario">
														
														<input type="hidden" name="idForm" id="idForm" value="" />
														<input type="hidden" name="camposOrigem" id="camposOrigem" value="" />
														<input type="hidden" name="nrcepend" id="nrcepend" value="0" />
														
														<label for="dsendere"><? echo utf8ToHtml('Endereço:') ?></label>
														<input name="dsendere" id="dsendere" type="text" />														
														<br />
														
														<label for="nmcidade"><? echo utf8ToHtml('Cidade:') ?></label>
														<input name="nmcidade" id="nmcidade" type="text" />
														<br />
														
														<label for="cdufende"><? echo utf8ToHtml('U.F.:') ?></label>
														<? echo selectEstado('cdufende', '' ); ?>
														<br />
														
														<label for="botao"></label>
														<input type="image" id="btEnter" src="<? echo $UrlImagens; ?>botoes/pesquisar.gif" />
														<input type="image" id="btIncluir" src="<? echo $UrlImagens; ?>botoes/incluir.gif" />
										
														<br style="clear:both" />
													</form>
													
													<div id="divCabecalhoPesquisaEndereco" class="divCabecalhoPesquisa">
														<table>
															<thead>
																<tr>
																<td style="width:54px; text-align:right;">CEP</td>
																<td style="width:174px; text-align:left;">Endere&ccedil;o</td>
																<td style="width:95px; text-align:left;">Bairro</td>
																<td style="width:94px; text-align:left;">Cidade</td>
																<td style="text-align:center;">UF</td>
																</tr>
															</thead>
														</table>
													</div>
													
													<!-- TABELA DE RESULTADO DA CONSULTA -->
													<!-- CONTEUDO MONTADO DINAMICAMENTE -->
													<div id="divResultadoPesquisaEndereco" class="divResultadoPesquisa" style='height:184px'>
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
			</td>
		</tr>
	</table>																			
</div>

<script type="text/javascript">

	var rotulos	= $('label[for="dsendere"],label[for="nmcidade"],label[for="cdufende"],label[for="botao"]','#formPesquisaEndereco');	
	rotulos.addClass('rotulo').css({'width':'100px'});

	var cEndereco	= $('#dsendere','#formPesquisaEndereco');
	var cCidade 	= $('#nmcidade','#formPesquisaEndereco');
	var cEstado		= $('#cdufende','#formPesquisaEndereco');
	
	cEndereco.addClass('alphanum campo').css({'width':'322px'}).attr('maxlength','40');
	cCidade.addClass('alphanum campo').css({'width':'165px'}).attr('maxlength','25');
	cEstado.addClass('campo').css({'width':'165px'});
	
	layoutPadrao();

	$('#btEnter','#formPesquisaEndereco').unbind('click').bind('click', function(){ 
		realizaPesquisaEndereco(1,20,'',''); 
		return false;	
	});
	
	$('#btIncluir','#formPesquisaEndereco').unbind('click').bind('click', function(){
		mostraFormularioEndereco($('#divPesquisaEndereco')); 
		return false;
	});

</script>
