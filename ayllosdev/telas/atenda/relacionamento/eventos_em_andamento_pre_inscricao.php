<?php 

	/************************************************************************
	 Fonte: eventos_em_andamento_pre_inscricao.php                                             
	 Autor: Guilherme                                                 
	 Data : Setembro/2009                    Última Alteração: 14/07/2011

	 Objetivo  : Buscar dados para a opcao de pre inscricao

	 Alterações: 25/10/2010 - Adicionar validação de permissão (David).                                                      
				 14/07/2011 - Alterado para layout padrão (Rogerius - DB1). 	
				 13/01/2017 - Alterado mascara do telefone para 9 digitos (Jean Michel). 

	 ************************************************************************/
	session_start();

	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	// Verifica permissão
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"I")) <> "") {
		exibeErro($msgError);		
	}
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nrdconta"]) ||
		!isset($_POST["rowidadp"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$rowidadp = $_POST["rowidadp"];

	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Monta o xml de requisição
	$xmlGetDadosPreInscricao  = "";
	$xmlGetDadosPreInscricao .= "<Root>";
	$xmlGetDadosPreInscricao .= "	<Cabecalho>";
	$xmlGetDadosPreInscricao .= "		<Bo>b1wgen0039.p</Bo>";
	$xmlGetDadosPreInscricao .= "		<Proc>pre-inscricao</Proc>";
	$xmlGetDadosPreInscricao .= "	</Cabecalho>";
	$xmlGetDadosPreInscricao .= "	<Dados>";
	$xmlGetDadosPreInscricao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetDadosPreInscricao .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetDadosPreInscricao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetDadosPreInscricao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetDadosPreInscricao .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetDadosPreInscricao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlGetDadosPreInscricao .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetDadosPreInscricao .= "		<rowidadp>".$rowidadp."</rowidadp>";
	$xmlGetDadosPreInscricao .= "		<idseqttl>1</idseqttl>";
	$xmlGetDadosPreInscricao .= "	</Dados>";
	$xmlGetDadosPreInscricao .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetDadosPreInscricao);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjDadosPreInscricao = getObjectXML($xmlResult);
	
	$infoCooperado = $xmlObjDadosPreInscricao->roottag->tags[0]->tags;
	$qtTTL = count($infoCooperado);
	$parentescos = $xmlObjDadosPreInscricao->roottag->tags[1]->tags;
	$qtParentesco = count($parentescos);
	$inscricoesConta = $xmlObjDadosPreInscricao->roottag->tags[2]->tags;
	$qtInscricoes = count($inscricoesConta);
	
	/* Se é evento exclusivo a cooperados */
	$flgcoope = $xmlObjDadosPreInscricao->roottag->tags[2]->attributes["FLGCOOPE"];

	$listaInscricoes = "";
    //	Monta inscricoes ja existentes neste evento (ou historico)
	for ($i = 0; $i < $qtInscricoes;$i++) {
		
		$listaInscricoes .= "<tr>".
							"  <td class=\\'txtCarregando\\'>".$inscricoesConta[$i]->tags[3]->cdata."</td>".
							"  <td width=\\'10\\'></td>".
							"  <td class=\\'txtCarregando\\'>".$inscricoesConta[$i]->tags[1]->cdata."</td>".
							"  <td width=\\'10\\'></td>".
							"  <td class=\\'txtCarregando\\'>".$inscricoesConta[$i]->tags[0]->cdata."</td>".
							"</tr>";
							
	}
	
	
	?>
	<script type="text/javascript">
		var qtTTL = "<?php echo $qtTTL;?>";
	<?php
	// Parentecos
	for ($i = 0; $i < $qtParentesco; $i++) {
	?>
		cdgraupr[<?php echo $i; ?>] = "<?php echo $parentescos[$i]->tags[0]->cdata . " - " .$parentescos[$i]->tags[1]->cdata; ?>";
	<?php
	}
	?>
	</script>
	<?php
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjDadosPreInscricao->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjDadosPreInscricao->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}	
?>	

<div id="divPreInscricao" style="overflow-y: hidden; overflow-x: hidden; width: 520px;">
	<form action="" name="frmPreInscricao" id="frmPreInscricao" class="formulario" method="post">
		<fieldset>
			<legend>Pré-Inscrição</legend>

			<label for="nmevento">Evento:</label>
			<input name="nmevento" type="text" class="campoTelaSemBorda" id="nmevento" style="width: 300px; " disabled>
			<br />

			<label for="dsrestri">Restrição:</label>
			<input name="dsrestri" type="text" class="campoTelaSemborda" id="dsrestri" style="width: 300px; " disabled>
			<br /><br /><br />
			
			<label for="nmextttl">Titular:</label>
			<select name="nmextttl" id="nmextttl" class="campo" style="width: 300px;">
			<?php 
			// Titulares
			for ($i = 0; $i < $qtTTL; $i++) { 								
			?>
				<option id="<?php echo $i;?>" value="<?php echo $infoCooperado[$i]->tags[0]->cdata; ?>"><?php echo $infoCooperado[$i]->tags[0]->cdata. " - ".$infoCooperado[$i]->tags[3]->cdata; ?></option>
			<?php
			}
			?>
			</select>
			<br />
			
			<?php
			// Um div para cada titular
			for ($i = 1; $i <= $qtTTL; $i++) {
				echo '<div id="divPreInscricaoTTL' . $i . '" style="overflow-y: hidden; overflow-x: hidden; width: 500px; display: block;">';
			?>
			<script type="text/javascript">
			objTTL = new Object();
			objTTL.tpinseve = "yes";
			objTTL.cdgraupr = 9;
			objTTL.nminseve = '<?php echo $infoCooperado[$i-1]->tags[3]->cdata; ?>';
			objTTL.dsdemail = '<?php echo $infoCooperado[$i-1]->tags[4]->cdata; ?>';
			objTTL.nrdddins = '<?php echo $infoCooperado[$i-1]->tags[5]->cdata; ?>';
			objTTL.nrtelefo = '<?php echo $infoCooperado[$i-1]->tags[6]->cdata; ?>';
			objTTL.dsobserv = '<?php echo $infoCooperado[$i-1]->tags[7]->cdata; ?>';
			objTTL.flgdispe = "no";
										
			titular[<?php echo $i; ?>] = objTTL;
			</script>
			
			<label for="tpinseve">Inscri&ccedil;&atilde;o:</label>
			<select name="tpinseve<?php echo $i;?>" id="tpinseve<?php echo $i;?>" class="campo" onchange="onChangeTpInsEve($(this).val());return false;" style="width: 150px;">
				<option id="tpinseve" value="yes">Pr&oacute;pria</option>
				<option id="tpinseve" value="no">Outra pessoa</option>
			</select>
			<br />
			
			<label for="cdgraupr">V&iacute;nculo com cooperado:</label>
			<select name="cdgraupr<?php echo $i;?>" id="cdgraupr<?php echo $i;?>" class="campo" style="width: 150px;">													
			</select>
			<br />

			<label for="nminseve">Nome:</label>
			<input name="nminseve<?php echo $i;?>" type="text" class="campoTelaSemBorda" id="nminseve<?php echo $i;?>" style="width: 300px;" value="<?php echo $infoCooperado[$i-1]->tags[3]->cdata; ?>">
			<br />
			
			<label for="dsdemail">E-mail:</label>
			<input name="dsdemail<?php echo $i;?>" type="text" class="campo" id="dsdemail<?php echo $i;?>" style="width: 300px;" value="<?php echo $infoCooperado[$i-1]->tags[4]->cdata; ?>">
			<br />
			
			<label for="nrdddins">DDD/Fone:</label>
			<input name="nrdddins<?php echo $i;?>" type="text" class="campo" id="nrdddins<?php echo $i;?>" style="width: 30px; text-align: right;" value="<?php echo $infoCooperado[$i-1]->tags[5]->cdata; ?>">
			<input name="nrtelefo<?php echo $i;?>" type="text" class="campo" id="nrtelefo<?php echo $i;?>" style="width: 80px; text-align: right;" value="<?php echo $infoCooperado[$i-1]->tags[6]->cdata; ?>">
			<br />
	
			<label for="dsobserv">Observa&ccedil;&atilde;o:</label>
			<input name="dsobserv<?php echo $i;?>" type="text" class="campo" id="dsobserv<?php echo $i;?>" style="width: 300px;" value="<?php echo $infoCooperado[$i-1]->tags[7]->cdata; ?>">
			<br />
			
			<label for="flgdispe">Confirma&ccedil;&atilde;o:</label>
			<select name="flgdispe<?php echo $i;?>" id="flgdispe<?php echo $i;?>" class="campo" style="width: 100px;">
				<option id="flgdispe" value="no">  Pedir</option>
				<option id="flgdispe" value="yes"> Dispensar</option>
			</select>
			
			
			<?php
			echo "</div>";
			}
			?>
		</fieldset>
	</form>
</div>

<div id="divBotoes">
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick='$("#divOpcoesDaOpcao1").css("display","block");$("#divOpcoesDaOpcao2").css("display","none");return false;'>
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/prosseguir.gif" onClick="listaInscritos('<?php echo $flgcoope; ?>','<?php echo $listaInscricoes; ?>');">
</div>

<script type="text/javascript">

// Formata layout
formataPreInscricao();

$("#divOpcoesDaOpcao1").css("display","none");
$("#divOpcoesDaOpcao2").css("display","block");

$('#nmevento','#frmPreInscricao').val(nmevento);
$('#dsrestri','#frmPreInscricao').val(dsrestri);

$("#nmextttl","#frmPreInscricao").unbind("change");

function onChangeTpInsEve(value) {
	if (value == "yes") {
		removerOptions("cdgraupr"+idseqttl);
		adicionarOption("cdgraupr"+idseqttl, 9, 9, "9 - NENHUM");
		$("#cdgraupr"+idseqttl,"#frmPreInscricao").prop("disabled",true);
		$("#nminseve"+idseqttl,"#frmPreInscricao").attr("class","campoTelaSemBorda");
		$("#nminseve"+idseqttl,"#frmPreInscricao").prop("disabled",true);
		$("#nminseve"+idseqttl,"#frmPreInscricao").val(titular[idseqttl].nminseve);
		$("#dsdemail"+idseqttl,"#frmPreInscricao").val(titular[idseqttl].dsdemail);
		$("#nrdddins"+idseqttl,"#frmPreInscricao").val(titular[idseqttl].nrdddins);
		$("#nrtelefo"+idseqttl,"#frmPreInscricao").val(titular[idseqttl].nrtelefo);
		$("#dsobserv"+idseqttl,"#frmPreInscricao").val(titular[idseqttl].dsobserv);
	} else {
		removerOptions("cdgraupr"+idseqttl);
		for (var i = 0; i < cdgraupr.length; i++){			
			adicionarOption("cdgraupr"+idseqttl, i, cdgraupr[i].substring(0,1) , cdgraupr[i]);			
		}
		$("#cdgraupr"+idseqttl,"#frmPreInscricao").removeProp("disabled");
		$("#nminseve"+idseqttl,"#frmPreInscricao").attr("class","campo");
		$("#nminseve"+idseqttl,"#frmPreInscricao").removeProp("disabled");
		$("#nminseve"+idseqttl,"#frmPreInscricao").val("");
		$("#dsdemail"+idseqttl,"#frmPreInscricao").val("");
		$("#nrdddins"+idseqttl,"#frmPreInscricao").val("");
		$("#nrtelefo"+idseqttl,"#frmPreInscricao").val("");
		$("#dsobserv"+idseqttl,"#frmPreInscricao").val("");		
		
	}
}


$("#nmextttl","#frmPreInscricao").bind("change",function() {
	// Titular em uso
	idseqttl = $(this).val();
	
	// Mostrar apenas o <div> do titular selecionado
	for (var i = 1; i <= qtTTL; i++){
		if ($(this).val() == i){
			$("#divPreInscricaoTTL" + i).css("display","block");
		}else{
			$("#divPreInscricaoTTL" + i).css("display","none");
		}
		
	}
	$("#tpinseve"+idseqttl,"#frmPreInscricao").trigger("change");
});

$("#nmextttl","#frmPreInscricao").trigger("change");

for (var i = 1; i <= qtTTL; i++){
	$("#nrdddins"+i,"#frmPreInscricao").setMask("INTEGER","999","","");
	$("#nrtelefo"+i,"#frmPreInscricao").setMask("INTEGER","999999999","","");
}

hideMsgAguardo();
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>
