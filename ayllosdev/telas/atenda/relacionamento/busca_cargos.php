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
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];

	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}

	// Recebe a operação que está sendo realizada
	$nrdconta       = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0 ; 
	$nrregist		= (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 0 ;
	$nriniseq		= (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 0 ;
	
	// Monta o xml de requisição		
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= " <Dados>";
	$xml 	   .= "     <nrdconta>".$nrdconta."</nrdconta>";
	$xml 	   .= "     <nrregist>30</nrregist>";
	$xml 	   .= "     <nriniseq>0</nriniseq>";
	$xml 	   .= " </Dados>";
	$xml 	   .= "</Root>";

	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "TELA_PESSOA", "BUSCAR_FUN_COOPERADO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	if (empty($xmlObjeto->roottag->tags[0]->tags[1]->tags[0]->name)) {
    exibirErro('error','O cooperado n&atilde;o possui um hist&oacute;rico de cargos.','Alerta - Aimaro','',false);
	}

	$teste = simplexml_load_string($xmlResult);

	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		
		$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
						
		if(empty ($nmdcampo)){ 
			$nmdcampo = "nrdconta";
		}
		
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','formataFiltro();focaCampoErro(\''.$nmdcampo.'\',\'frmFiltro\');',false);		
								
	} 
	
?>	
<form id="frmCargos" onSubmit="return false" class="formulario">
	<fieldset>
		<legend>Cargos</legend>
	
		<div class="divRegistros">	
			<table>
				<thead>
					<tr>
						<th><? echo 'CPF/CNPJ'; ?></th>
						<th><? echo 'Cargo'; ?></th>
						<th><? echo 'Início Vigência' ;  ?></th>
						<th><? echo 'Fim Vigência';  ?></th>
					</tr>
				</thead>
				<tbody>

					<?
						foreach ($teste->Dados->cargos as $key => $value) {
							foreach ($value as $value2) {
								echo '<tr>';
								echo ' <td>' . $value2->nrcpfcgc[0] . '</td>';
								echo ' <td>' . $value2->dsfuncao[0] . '</td>';
								echo ' <td>' . $value2->dtinicio_vigencia[0] . '</td>';
								echo ' <td>' . $value2->dtfim_vigencia[0] . '</td>';
								echo '</tr>'; 
							}
						}
					?>

				</tbody>
			</table>
		</div>	
	</fieldset>

</form>

<div id="divBotoes">
<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="acessaOpcaoPrincipal();return false;">
</div>

<div id="divCargosDetalhes">
</div>
<script type="text/javascript">

// Formata layout
formataCargos();

$("#divConteudoOpcao").css("display","none");
$("#divEventoDetalhes").css("display","none");
$("#divOpcoesDaOpcao2").css("display","none");
// Mostra o <div> com os eventos em andamento
$("#divOpcoesDaOpcao1").css("display","block");

// Esconde mensagem de aguardo
hideMsgAguardo();
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>
