<?
/*************************************************************************
	Fonte: consulta-habilita.php
	Autor: Gabriel						Ultima atualizacao: 24/11/2015
	Data : Dezembro/2010
	
	Objetivo: Tela para visualizar a consulta/habilitacao da rotina 
			  de cobranca.
	
	Alteracoes: 19/05/2011 - Tratar cob. regist. (Guilherme).
	
				14/07/2011 - Alterado para layout padrão (Gabriel - DB1).
				
				26/07/2011 - Ajuste para impressao de cobranca registrada
							 (Gabriel)

				08/09/2011 - Ajuste para chamada da lista negra (Adriano).			 
							 
				09/05/2013 - Retirado vampo de valor maximo de boleto. (Jorge)			 
				
				19/09/2013 - Inclusao do campo logico Convenio Homologado,
                             habilitado apenas para o setor COBRANCA (Carlos)
							 
				28/04/2015 - Incluido campos cooperativa emite e expede e
							 cooperado emite e expede. (Reinert)

                24/11/2015 - Inclusao do indicador de negativacao pelo Serasa.
                             (Jaison/Andrino)

*************************************************************************/

session_start();

// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es
require_once("../../../includes/config.php");
require_once("../../../includes/funcoes.php");		
require_once("../../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo m&eacute;todo POST
isPostMethod();	

$nrcnvceb    = $_POST["nrcnvceb"];
$nrconven    = $_POST["nrconven"];
$dsorgarq    = trim($_POST["dsorgarq"]);
$dssitceb    = trim($_POST["dssitceb"]);
$inarqcbr    = $_POST["inarqcbr"];
$cddemail    = $_POST["cddemail"];
$dsdemail    = trim($_POST["dsdemail"]);
$flgcruni    = trim($_POST["flgcruni"]);
$flgregis    = trim($_POST["flgregis"]);
$flcooexp    = trim($_POST["flcooexp"]);
$flceeexp    = trim($_POST["flceeexp"]);
$flserasa    = trim($_POST["flserasa"]);
$cddbanco	 = trim($_POST["cddbanco"]);
$flgcebhm    = trim($_POST["flgcebhm"]);
$cddopcao    = trim($_POST["cddopcao"]);
$dsdmesag    = $_POST["dsdmesag"];
$titulares   = $_POST["titulares"];
$qtTitulares = $_POST["qtTitulares"];
$emails_titular = $_POST["emails"];

$flsercco = $_POST["flsercco"];

// Titulo de tela dependendo a opcao de CONSULTA/HABILITACAO
$dstitulo = ($cddopcao == "C")? "CONSULTA" : "HABILITA&Ccedil;&Atilde;O"; 

$dstitulo .= " - COBRAN&Ccedil;A";

if ($nrcnvceb > 0 ) {
	$dstitulo .= " ( CEB $nrcnvceb )";
}

$campo = ($cddopcao == "C" ) ? "campoTelaSemBorda" : "campo";

?>

<form action="" name="frmConsulta" id="frmConsulta" method="post">
	<input type="hidden" name= "flsercco" id="flsercco" class="campoTelaSemBorda" readonly value = " <?php echo $flsercco; ?>" />

	<fieldset>
		<legend><? echo utf8ToHtml($dstitulo) ?></legend>
		
		<label for="nrconven"><? echo utf8ToHtml('Convênio:') ?></label>
		<input name="nrconven" id="nrconven" class="campoTelaSemBorda" readonly value = " <?php echo formataNumericos("zz.zzz.zz9",$nrconven,'.'); ?> " />
		<br />
		
		<label for="dsorgarq"><? echo utf8ToHtml('Origem Convênio:') ?></label>
		<input name= "dsorgarq" id="dsorgarq" class="campoTelaSemBorda" readonly value = " <?php echo $dsorgarq; ?>" />
		<br />
		
		<label for="dssitceb"><? echo utf8ToHtml('Situação Cobrança:') ?></label>
		<select name="dssitceb" id="dssitceb" class="<?php echo $campo; ?>">					 	
		  <option id="dssitceb" value="yes" <?php if ($dssitceb == "ATIVO") { ?> selected  <?php } ?> > ATIVO   </option>
		  <option id="dssitceb" value="no" <?php if ($dssitceb == "INATIVO" ) { ?> selected <?php } ?> > INATIVO</option>  													
		</select>
		<br />
				
		<label for="flgregis"><? echo utf8ToHtml('Registrada:') ?></label>
		<input name= "flgregis" id="flgregis" class="campoTelaSemBorda" readonly value = " <?php echo $flgregis; ?>" />		
		<br />	

		<? 
		if ($cddbanco == 85){
		?>
			<label for="flcooexp"><? echo utf8ToHtml('Cooperado Emite e Expede:') ?></label>
			<input name="flcooexp" id="flcooexp" type="checkbox" class="checkbox" readonly <?php if ($flcooexp == "SIM" ) { ?> checked <?php } ?> />		
			<br />
			
			<label for="flceeexp"><? echo utf8ToHtml('Cooperativa Emite e Expede:') ?></label>		
			<input name="flceeexp" id="flceeexp" type="checkbox" class="checkbox" readonly <?php if ($flceeexp == "SIM" ) { ?> checked <?php } ?> />		
			<br />	
			
			<div id="divOpcaoSerasa">
                <label for="flserasa"><? echo utf8ToHtml('Negativação via Serasa:') ?></label>
                <input name="flserasa" id="flserasa" type="checkbox" class="checkbox" readonly <?php if ($flserasa == "SIM" ) { ?> checked <?php } ?> />
                <br />
            </div>
		<?
		}
		?>
		
		<label for="inarqcbr"><? echo utf8ToHtml('Recebe Arquivo Retorno:') ?></label>
        <select name="inarqcbr" id="inarqcbr" class="<?php echo $campo; ?>">	
			<option id="inarqcbr" value="0" <?php if ($inarqcbr == 0) { ?> selected <?php } ?> > N&Atilde;O RECEBE </option>
			<option id="inarqcbr" value="1" <?php if ($inarqcbr == 1) { ?> selected <?php } ?> > OUTROS </option>
			<option id="inarqcbr" value="2" <?php if ($inarqcbr == 2) { ?> selected <?php } ?> > FEBRABAN 240 </option>					   
			<option id="inarqcbr" value="3" <?php if ($inarqcbr == 3) { ?> selected <?php } ?> > CNAB 400 </option>
	    </select>
		<br />
		
		<label for="dsdemail"><? echo utf8ToHtml('E-mail Arquivo Retorno:') ?></label>
		<select name="dsdemail" id="dsdemail" class="<?php echo $campo; ?>">
		 
			<?php if ($dsdemail != "") {  $valor = $cddemail; ?>
					<option value="<?php echo "0"; ?>" > <?php echo "SELECIONE O E-MAIL"; ?> </option>							
			<?php } else { 									
					$dsdemail = "SELECIONE O E-MAIL";
					$valor    = "0";									
			} ?>
			
			<option value="<?php echo $valor; ?>" selected > <? echo $dsdemail; ?> </option>
								 
			<?php   $emails = explode("|",$emails_titular); // Dividir os emails
			
			 foreach ($emails as $email) { 
			 
				$email = explode(",",$email);
				$contador = 0;
			  
				foreach ($email as $tag)  {								
					if ($contador == 0) 
						$cddemail = $tag; 									
					else
						$descricao = $tag;										
					$contador++;									
				}	
				
				if ($descricao != $dsdemail) { ?>
				  <option id="dsdemail" value="<?php echo $cddemail;?>">  <?php echo $descricao; ?> </option>							
			<?  } 
			
			} ?>
		</select>		
		<br />
		
		<label for="flgcruni"><? echo utf8ToHtml('Utiliza Crédito Unificado:') ?></label>
		<select name="flgcruni" id="flgcruni" class="<?php echo $campo; ?>">
			<option id="flgcruni" value="yes" <? if ($flgcruni == "SIM") { ?> selected <? } ?> >   SIM </option>
			<option id="flgcruni" value="no"  <? if ($flgcruni == "NAO") { ?> selected <? } ?> >  N&Atilde;O </option>
		</select>	
		
		<?php
		if ($dsorgarq == 'IMPRESSO PELO SOFTWARE') { ?>
		    <script>
				habilitaSetor('<?php echo $glbvars['dsdepart'] ?>');
			</script>
			<br />
			<label for="flgcebhm"><? echo utf8ToHtml('Convênio Homologado:') ?></label>
			<select name="flgcebhm" id="flgcebhm" class="<?php echo $campo; ?>">
				<option value="yes" <? if ($flgcebhm == "SIM") { ?> selected <? } ?> >   SIM </option>
				<option value="no"  <? if ($flgcebhm == "NAO") { ?> selected <? } ?> >  N&Atilde;O </option>
			</select>
			<?php 
		} ?>
		
	</fieldset>
</form>

<div id="divBotoes">
	<input type="image" src="<? echo $UrlImagens; ?>botoes/voltar.gif" onClick="limpaCampos();$('#divConteudoOpcao').css('display','block');$('#divOpcaoConsulta').css('display','none');return false;" />
	
	<? if ($cddopcao != "C") { // Mostrar botao de continuar se for opcao de HABILITACAO ?> 
		<input type="image" src="<? echo $UrlImagens; ?>botoes/continuar.gif" onClick="validaDadosLimites('<? echo "true"; ?> ',' <? echo ""; ?>', '<? echo $cddopcao; ?> ');return false;" />
	<? } ?>

	<? if ($dsorgarq == "INTERNET" && $qtTitulares > 0 && $dsdmesag == "") { // Se convenio INTERNET e tem mais titulares ?>								
		<input type="image" src="<? echo $UrlImagens; ?>botoes/outros_titulares.gif" onClick="titulares('<? echo $cddopcao; ?> ' , ' <? echo $titulares; ?> ');return false;" />
	<? } ?>
</div>

<script type="text/javascript">
controlaLayout('frmConsulta');

$("#divConteudoOpcao").css("display","none");
$("#divOpcaoIncluiAltera").css("display","none");

$("#divOpcaoConsulta").css("display","block");

blockBackground(parseInt($("#divRotina").css("z-index")));

// Se for pessoa fisica esconde indicador Serasa
if (inpessoa == 1) {
    $("#divOpcaoSerasa").hide();
}

<?php 
    if ($cddopcao == "I") { // Se eh inclusao
        ?>
        $("#dssitceb","#divOpcaoConsulta").prop("disabled",true);
        $("#flceeexp","#divOpcaoConsulta").prop("checked",false);
        <?php
    }

    if ($cddopcao == "C") { // Se consulta, desabilita
        ?>
        $("#dssitceb","#divOpcaoConsulta").prop("disabled",true);
        $("#inarqcbr","#divOpcaoConsulta").prop("disabled",true);
        $("#dsdemail","#divOpcaoConsulta").prop("disabled",true);
        $("#flgregis","#divOpcaoConsulta").prop("disabled",true);
        $("#flcooexp","#divOpcaoConsulta").prop("disabled",true);
        $("#flceeexp","#divOpcaoConsulta").prop("disabled",true);
        $("#flgcruni","#divOpcaoConsulta").prop("disabled",true);
        $("#flgcebhm","#divOpcaoConsulta").prop("disabled",true);
        $("#cddbanco","#divOpcaoConsulta").prop("disabled",true);
        $("#flserasa","#divOpcaoConsulta").prop("disabled",true);
        <?php
    } else if ($dsdmesag != "" && $dsorgarq == "INTERNET" ) { // Nao tem senha liberada para Internet
        ?>
        showError("inform","<?php echo $dsdmesag; ?>","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");
        <?php
    }
	
	if ($flsercco == "0") { ?>
		$("#flserasa","#divOpcaoConsulta").prop("disabled",true);
		$("#flserasa","#divOpcaoConsulta").prop("checked",false);
		<?php
	}
	
?>
</script>