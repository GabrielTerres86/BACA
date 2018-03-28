<?php 

	/************************************************************************
	 Fonte: titulos_bordero_resumo.php                                        
	 Autor: Alex Sandro (GFT)
	 Data : 22/03/2018                Última Alteração: 
	                                                                  
	 Objetivo  : Resumo de um novo Bordero

	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
	require_once("../../../../includes/controla_secao.php");


	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");
	
	setVarSession("nmrotina","DSC TITS - BORDERO");

	
	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	

	// INICIO - INCLUIR PHP QUE FAZ A CHAMADA PARA O IBRATAM (REPLACE)
	//
	
	$xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    // FAZER O INSERT CRAPRDR e CRAPACA
    $xmlResult = mensageria($xml,"XXXX","XXXX", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

	$titulos   = $xmlObj->roottag->tags[0]->tags;
	$qtTitulos = count($titulos);
	
    // Se ocorrer um erro, mostra mensagem
    /*
	if (strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO') {
       echo 'showError("error","'.$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata.'","Alerta - Ayllos","bloqueiaFundo(divRotina);carregaLimitesTitulos();");';           
	}
	else{
		if($xmlObj->roottag->tags[0]){
			echo 'showError("inform","'.$xmlObj->roottag->tags[0]->cdata.'","Alerta - Ayllos","bloqueiaFundo(divRotina);carregaLimitesTitulos();");';
		} else{
			echo 'showError("inform","An&aacute;lise enviada com sucesso!","Alerta - Ayllos","bloqueiaFundo(divRotina);carregaLimitesTitulos();");';
		}	
	}
	*/

	//
	//
	// FIM - INCLUIR PHP QUE FAZ A CHAMADA PARA O IBRATAM (REPLACE)

	
?>

<div id="divResumoBordero">
	

	<form id="formPesquisaTitulos" class="formulario">
		<input type="hidden" id="nrdconta" name="nrdconta" value="<? echo $nrdconta; ?>" />
		
		<div id="divTitulos" class="formulario">
			<fieldset>
				<legend>Resumo</legend>
				<div class="divRegistrosTitulos divRegistros">
					<table class="tituloRegistros">
						<thead>
							<tr>
								<th>Conv&ecirc;nio</th>
								<th>Boleto n&ordm;</th>
								<th>Nome Pagador</th>
								<th>Data Vencimento</th>
								<th>Valor do T&iacute;tulo</th>
								<th>Situa&ccedil;&atilde;o</th>
								<th>Cr&iacute;tica</th>
							</tr>			
						</thead>
						<tbody>
							<?
								$mtdClick = "selecionaTituloResumo('1', 'Gomercindo Lopes');";
							?>	
							<tr id="trTitulo1>" onFocus="<? echo $mtdClick; ?>" onClick="<? echo $mtdClick; ?>">
										
								<td>XXXXXXXXXXX</td>
								<td>NNNNNNNNNN</td>
								<td>Gomercindo Lopes</td>
								<td>xx/xx/xxxx</td>
								<td>R$ xxxxx,xx</td>
								<td>ATIVO</td>
								<td>SIM</td>
							</tr>

							<?
								$mtdClick = "selecionaTituloResumo('2', 'Juca Santos');";
							?>
							<tr id="trTitulo2>" onFocus="<? echo $mtdClick; ?>" onClick="<? echo $mtdClick; ?>">
								<td>XXXXXXXXXXX</td>
								<td>NNNNNNNNNN</td>
								<td>Juca Santos</td>
								<td>xx/xx/xxxx</td>
								<td>R$ xxxxx,xx</td>
								<td>ATIVO</td>
								<td>NAO</td>
							</tr>
							<tr id="trTitulo3>" onFocus="<? echo $mtdClick; ?>" onClick="<? echo $mtdClick; ?>">
								<td>XXXXXXXXXXX</td>
								<td>NNNNNNNNNN</td>
								<td>Maria Loudes</td>
								<td>xx/xx/xxxx</td>
								<td>R$ xxxxx,xx</td>
								<td>ATIVO</td>
								<td>SIM</td>
							</tr>
							<tr id="trTitulo4>" onFocus="<? echo $mtdClick; ?>" onClick="<? echo $mtdClick; ?>">
								<td>XXXXXXXXXXX</td>
								<td>NNNNNNNNNN</td>
								<td>Roberval Lima</td>
								<td>xx/xx/xxxx</td>
								<td>R$ xxxxx,xx</td>
								<td>ATIVO</td>
								<td>SIM</td>
							</tr>




							<?  for ($i = 0; $i < $qtLimites; $i++) {
									
									$mtdClick = "selecionaTituloResumo('".($i + 1)."', '".$qtTitulos."', '".($titulos[$i]->tags[3]->cdata)."', '".($titulos[$i]->tags[7]->cdata)."', '".($titulos[$i]->tags[8]->cdata)."', '".($titulos[$i]->tags[9]->cdata)."', '".($titulos[$i]->tags[2]->cdata)."');";
												
							?>
								<tr id="trTitulo<? echo $i + 1; ?>" onFocus="<? echo $mtdClick; ?>" onClick="<? echo $mtdClick; ?>">
									<td><span><? echo getByTagName($titulos[$i]->tags,"DTPROPOS"); ?></span>
									<? echo getByTagName($titulos[$i]->tags,"DTPROPOS"); ?></td>
									
									<td><span><? echo $titulos[$i]->tags[1]->cdata; ?></span>
									<? echo $titulos[$i]->tags[1]->cdata; ?></td>
									
									<td><span><? echo $titulos[$i]->tags[3]->cdata; ?></span>
										<? echo formataNumericos('zzz.zzz.zzz',$titulos[$i]->tags[3]->cdata,'.'); ?></td>
									
									<td><span><? echo $titulos[$i]->tags[2]->cdata; ?></span>
										<? echo number_format(str_replace(",",".",$titulos[$i]->tags[2]->cdata),2,",","."); ?></td>
									
									<td><span><? echo $titulos[$i]->tags[4]->cdata; ?></span>
									<? echo $titulos[$i]->tags[4]->cdata; ?></td>
									
									<td><span><? echo $titulos[$i]->tags[5]->cdata; ?></span>
									<? echo $titulos[$i]->tags[5]->cdata; ?></td>
									
									<td><span><? echo $titulos[$i]->tags[7]->cdata; ?></span>
									<? echo $titulos[$i]->tags[7]->cdata; ?></td>
									
									<td><span><? echo $titulos[$i]->tags[8]->cdata; ?></span>
									<? echo $titulos[$i]->tags[8]->cdata; ?></td>

									<td><span><? echo $titulos[$i]->tags[9]->cdata; ?></span>
									<? echo $titulos[$i]->tags[9]->cdata; ?></td>
															
								</tr>
							<?} // Fim do for ?>	
									
						</tbody>
					</table>
				</div>
			</fieldset>
			
		</div>
	</form>
</div>


<div id="divBotoesTitulosLimite" style="margin-bottom:10px;">
	<input type="button" class="botao" value="Voltar"  onClick="carregaBorderosTitulos(); voltaDiv(3,2,4,'DESCONTO DE TÍTULOS - BORDERÔS');return false; " />
	<input type="button" class="botao" value="Remover T&iacute;tulo" onClick="alert('Em desenvolvimento');return false;"/>
	<input type="button" class="botao" value="Ver Detalhes" onClick="mostrarDetalhesPagador();return false;"/>

<script type="text/javascript">
	dscShowHideDiv("divOpcoesDaOpcao4","divOpcoesDaOpcao1;divOpcoesDaOpcao2;divOpcoesDaOpcao3;divOpcoesDaOpcao5");

	// Muda o título da tela
	$("#tdTitRotina").html("DESCONTO DE T&Iacute;TULOS - BORDERO - RESUMO");

	formataLayout('divResumoBordero');

	// Esconde mensagem de aguardo
	hideMsgAguardo();

	// Bloqueia conteúdo que está átras do div da rotina
	blockBackground(parseInt($("#divRotina").css("z-index")));


</script>