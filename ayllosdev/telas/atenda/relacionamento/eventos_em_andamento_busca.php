<?php 

	/************************************************************************
	 Fonte: eventos_em_andamento_busca.php                                             
	 Autor: Guilherme                                                 
	 Data : Setembro/2009                &Uacute;ltima Altera&ccedil;&atilde;o:  14/07/2011    

	 Objetivo  : Buscar eventos em andamento de acordo com o parametro
				 de observa&ccedil;&atilde;o

				 Altera&ccedil;&otilde;es: 
						14/07/2011 - Alterado para layout padr?o (Rogerius - DB1). 
						12/12/2018 - Alterada chamada do botão de pré-inscricao (Bruno Luiz Katzjarowski - Mout's)
						05/07/2019 - Destacar evento do cooperado - P484.2 - Gabriel Marcos (Mouts).
				 
	************************************************************************/
	session_start();

	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");
	
	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	// Se par&acirc;metros necess&aacute;rios n&atilde;o foram informados
	if (!isset($_POST["nrdconta"]) ||
		!isset($_POST["dsobserv"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrcpfcgc = preg_replace( '/[^0-9]/', '', $_POST["nrcpfcgc"]);
	$nrdconta = $_POST["nrdconta"];
	$dsobserv = $_POST["dsobserv"];

	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlGetDadosEventosAndamento  = "";
	$xmlGetDadosEventosAndamento .= "<Root>";
	$xmlGetDadosEventosAndamento .= "	<Cabecalho>";
	$xmlGetDadosEventosAndamento .= "		<Bo>b1wgen0039.p</Bo>";
	$xmlGetDadosEventosAndamento .= "		<Proc>obtem-eventos-andamento</Proc>";
	$xmlGetDadosEventosAndamento .= "	</Cabecalho>";
	$xmlGetDadosEventosAndamento .= "	<Dados>";
	$xmlGetDadosEventosAndamento .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetDadosEventosAndamento .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetDadosEventosAndamento .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetDadosEventosAndamento .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetDadosEventosAndamento .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetDadosEventosAndamento .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlGetDadosEventosAndamento .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetDadosEventosAndamento .= "		<dsobserv>".$dsobserv."</dsobserv>";
	$xmlGetDadosEventosAndamento .= "		<idseqttl>1</idseqttl>";
	$xmlGetDadosEventosAndamento .= "	</Dados>";
	$xmlGetDadosEventosAndamento .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetDadosEventosAndamento);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjDadosEventosAndamento = getObjectXML($xmlResult);
	
	$eventosAndamento = $xmlObjDadosEventosAndamento->roottag->tags[0]->tags;
	$qtEAndamento = count($eventosAndamento);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjDadosEventosAndamento->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjDadosEventosAndamento->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
    $xml  = "";
    $xml .= "<Root>";
    $xml .= "	<Dados>";
    $xml .= "		<nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
    $xml .= "	</Dados>";
    $xml .= "</Root>";
    
    // Executa script para envio do XML
    $xmlResult = mensageria($xml, "CADA0003", "RETORNA_GRUPO_CPF",  //   LISTA_FORNECEDORES
                            $glbvars["cdcooper"],
                            $glbvars["cdagenci"], 
                            $glbvars["nrdcaixa"], 
                            $glbvars["idorigem"], 
                            $glbvars["cdoperad"], 
                            "</Root>");
    
    $xmlObj = new SimpleXMLElement($xmlResult);

    if(isset($xmlObj->{'Erro'})){
        exibeErro($retorno['erro'] = (string) $xmlObj->{'Erro'}->{'Registro'}->{'dscritic'});
    }

	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}	

	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Dados>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlRepresentante = mensageria($xml, "CADA0003", "RETORNA_EVENTOS_ASSEMB",  //   LISTA_FORNECEDORES
																 $glbvars["cdcooper"],
																 $glbvars["cdagenci"],
																 $glbvars["nrdcaixa"],
																 $glbvars["idorigem"],
																 $glbvars["cdoperad"],
																 "</Root>");
															  
	$xmlRepresentante = simplexml_load_string($xmlRepresentante);

	if (!empty($xmlRepresentante)) {

		$contentLinhas  = '';

		foreach ($xmlRepresentante->inf as $linha) {

			$contentLinhas .= '<tr>';
			$contentLinhas .= '<td width=75>' . $linha->nmdgrupo . '</td>';
			$contentLinhas .= '<td width=85>' . $linha->dtinieve . '</td>';
			$contentLinhas .= '<td>' . $linha->nminseve . '</td>';
			$contentLinhas .= '</tr>';

		}

		echo '<script>';
		echo '
			var texto  = "Atenção! Lista de pr&eacute;-inscri&ccedil;&otilde;es em eventos assembleares. <br><br>";
				texto += "<table>";
				texto += "  <tr>";
				texto += "    <td>";
				texto += "      PA/Grupo";
				texto += "    </td>";
				texto += "    <td>";
				texto += "      Data";
				texto += "    </td>";
				texto += "    <td>";
				texto += "      Nome";
				texto += "    </td>";
				texto += "  </tr>";

				texto += "'.$contentLinhas.'";

				texto += "</table>";

			showError("inform", texto, "Alerta - Aimaro", "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");
		';
		echo '</script>';
	}

?>	

<style>

	/* estilos para personalizar a tabela de eventos */
   .txtNegrito { font-weight:bold;}
   .trDestaque { background:  #ffff80 !important;}
   .highlight  { background:  #ffff50 !important;}

</style>

<script>

	// cor de fundo quando o item estiver selecionado
	$(".trDestaque").click(function() {
	    $(this).toggleClass("highlight");
	});


	var texto  = "Atenção! Lista de pr&eacute;-inscri&ccedil;&otilde;es em eventos assembleares. <br><br>";
		texto += "<table>";
		texto += "  <tr>";
		texto += "    <td>";
		texto += "      PA/Grupo";
		texto += "    </td>";
		texto += "    <td>";
		texto += "      Data";
		texto += "    </td>";
		texto += "    <td>";
		texto += "      Nome";
		texto += "    </td>";
		texto += "  </tr>";
		texto += "</table>";

	//showError("inform", texto, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
			
</script>

<form id="frmEventosEmAndamentoBusca" onSubmit="return false" class="formulario">
	<fieldset>
		<legend>Eventos em Andamento</legend>
	
		<div class="divRegistros">	
			<table id="tabelaEventos">
				<thead>
					<tr>
						<th><? echo utf8ToHtml('Evento'); ?></th>
						<th><? echo utf8ToHtml('Grupo'); ?></th>
						<th><? echo utf8ToHtml('Turma');  ?></th>
						<th><? echo utf8ToHtml('Pr&eacute;-Ins');  ?></th>
						<th><? echo utf8ToHtml('Conf');  ?></th>
						<th><? echo utf8ToHtml('In&iacute;cio');  ?></th>
						<th><? echo utf8ToHtml('Fim');  ?></th>
						<th><? echo utf8ToHtml('Obs');  ?></th>
					</tr>
				</thead>
				<tbody>
					<? 
					//relacionamentos
					for ($i = 0; $i < $qtEAndamento; $i++) { 
					$aux = $i + 1;
					$seleciona = "selecionaEventoAndamento('". $aux ."','". $qtEAndamento ."','". $eventosAndamento[$i]->tags[1]->cdata ."','". $eventosAndamento[$i]->tags[0]->cdata ."','". $eventosAndamento[$i]->tags[13]->cdata ."','". $eventosAndamento[$i]->tags[14]->cdata ."','". $eventosAndamento[$i]->tags[9]->cdata ."','". $eventosAndamento[$i]->tags[12]->cdata ."','". $eventosAndamento[$i]->tags[2]->cdata ."','". $eventosAndamento[$i]->tags[10]->cdata ."');";		
					?>
						<!-- pre-inscricao -->
						<tr class="<?=(strval($xmlObj->inf->nmdgrupo) === strval($eventosAndamento[$i]->tags[15]->cdata) ? "txtNegrito trDestaque" : "")?>" 
						     id="trEvento<?php echo $i + 1; ?>" onFocus="<? echo $seleciona ?>" onClick="<? echo $seleciona ?>"
						 data-nmdgrupo='<?php echo $eventosAndamento[$i]->tags[15]->cdata; ?>' 
						 data-idevento='<?php echo $eventosAndamento[$i]->tags[0]->cdata; ?>'
						 
						>
							<td><span><?php echo $eventosAndamento[$i]->tags[2]->cdata; ?></span>
									<?php echo stringTabela($eventosAndamento[$i]->tags[2]->cdata, 32, 'palavra'); ?>
							</td>
							
							<td>
							    <?=$eventosAndamento[$i]->tags[15]->cdata;?>
							</td>

							<td><span><?php echo $eventosAndamento[$i]->tags[3]->cdata; ?></span>
									<?php echo $eventosAndamento[$i]->tags[3]->cdata; ?>
							</td>
							<td><span><?php echo $eventosAndamento[$i]->tags[4]->cdata; ?></span>
									<?php echo $eventosAndamento[$i]->tags[4]->cdata; ?>
							</td>
							<td><span><?php echo $eventosAndamento[$i]->tags[5]->cdata; ?></span>
									<?php echo $eventosAndamento[$i]->tags[5]->cdata; ?>
							</td>
							<td><span><?php echo $eventosAndamento[$i]->tags[6]->cdata; ?></span>
									<?php echo $eventosAndamento[$i]->tags[6]->cdata; ?>
							</td>
							<td><span><?php echo $eventosAndamento[$i]->tags[7]->cdata; ?></span>
									<?php echo $eventosAndamento[$i]->tags[7]->cdata; ?>
							</td>
							<td><span><?php echo $eventosAndamento[$i]->tags[9]->cdata; ?></span>
									<?php echo $eventosAndamento[$i]->tags[9]->cdata; ?>
							</td>
						</tr>
				<? } ?>	
				</tbody>
			</table>
		</div>	
	</fieldset>

</form>

<div id="divBotoes">
<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="acessaOpcaoPrincipal();return false;">
<input type="image" src="<?php echo $UrlImagens; ?>botoes/detalhes_do_evento.gif" onClick="mostraDetalhesEvento();return false;">
<!--  pre inscricao  -->
<input type="image" src="<?php echo $UrlImagens; ?>botoes/pre_inscricao.gif" <?php if (!in_array("I",$glbvars["opcoesTela"])) { echo 'style="cursor: default" onClick="return false;"'; } else { echo 'onClick="validaGrupo();return false;"'; } ?>>
<input type="image" src="<?php echo $UrlImagens; ?>botoes/situacao_da_inscricao.gif" onClick="mostraSituacaoDaInscricaoEvento();return false;">
<input type="image" src="<?php echo $UrlImagens; ?>botoes/historico.gif" onClick="mostraHistoricoEvento();return false;">
</div>

<div id="divEventoDetalhes">
</div>
<script type="text/javascript">

// Formata layout
formataEventosAndamentoBusca();

$("#divConteudoOpcao").css("display","none");
$("#divEventoDetalhes").css("display","none");
$("#divOpcoesDaOpcao2").css("display","none");
// Mostra o <div> com os eventos em andamento
$("#divOpcoesDaOpcao1").css("display","block");

selecionaEventoAndamento(1,<?php echo $qtEAndamento; ?>,'<?php echo $eventosAndamento[0]->tags[1]->cdata; ?>','<?php echo $eventosAndamento[0]->tags[0]->cdata; ?>','<?php echo $eventosAndamento[0]->tags[13]->cdata; ?>','<?php echo $eventosAndamento[0]->tags[14]->cdata; ?>','<?php echo $eventosAndamento[0]->tags[9]->cdata; ?>','<?php echo $eventosAndamento[0]->tags[12]->cdata; ?>','<?php echo $eventosAndamento[0]->tags[2]->cdata; ?>','<?php echo $eventosAndamento[0]->tags[10]->cdata; ?>');

// Esconde mensagem de aguardo
hideMsgAguardo();
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>
