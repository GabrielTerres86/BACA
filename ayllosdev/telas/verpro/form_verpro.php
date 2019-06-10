<?php
/* !
 * FONTE        : form_verpro.php
 * CRIAÇÃO      : Rogérius Militão - DB1 Informatica
 * DATA CRIAÇÃO : 28/10/2011 
 * OBJETIVO     : Tela com o detalhes do protocolo		última alteração: 29/05/2017
 * --------------
 * ALTERAÇÕES   :
 * 001: [30/11/2012] David (CECRED) : Validar session
 * 001: [16/01/2013] Daniel (CECRED) : Implantacao novo layout.
 * 002: [09/10/2014] Adriano (CECRED) : Ajuste para inclusão dos protocolos de resgate de aplicação
 * 003: [23/10/2014] Jorge (CECRE) : Ajuste em Data do Resgate.
 * 004: [04/11/2014] Douglas (CECRED) : Validação das informações para Aplicação Pós e Pré - Chamado 123392
 * 005: [10/04/2015] Reinert (CECRED) : Incluido nome do produto junto ao numero da aplicação para os novos produtos de captação
 * 006: [09/06/2015] Vanessa (CECRED) : Inclusão do campo ISPB para TEDS
 * 007: [13/07/2015] Carlos (CECRED) : #303192 Corrigidos os campos nome do favorecido, CPF/CNPJ do favorecido e finalidade.
 * 008: [17/07/2015] Carlos Rafael (CECRED): Projeto GPS: Criacao da tela do tipo 13 apresentando os dados de GPS
 * 009: [16/11/2015] - Andre Santos (SUPERO) : Aumento do campo Lin.Digitavel e Cod.Barras
 * 010: [05/07/2016] - Odirlei Busana (AMcom) : Exibir protocolo 15 - pagamento debaut - PRJ320 - Oferta Debaut
 * 011: [29/07/2016] - Corrigi o uso da funcao split depreciada. SD 480705 (Carlos R.)
 * 012: [19/09/2016] - Alteraçoes pagamento/agendamento de DARF/DAS pelo InternetBanking (Projeto 338 - Lucas Lunelli) 
 * 013: [23/03/2017] - Inclusão do protocolo de Recarga de celular (PRJ321 - Reinert)
 * 014: [29/05/2017] - Ajuste para apresentar valores corretamente - Adriano SD 679022.
 * 015: [05/09/2017] - Alteração referente ao Projeto Assinatura conjunta (Proj 397)
 * 016: [03/01/2018] - Alteração para tratar os tipos 24-FGTS e 23-DAE (Proj 406).
 * 017: [19/03/2019] - Alterado o id do protocolo de desconto de titulo do 22 para o 32 (Paulo Penteado GFT)
 * 018: [10/06/2019] - Adicionado campos Situação nos detalhes PRJ 470 SM2 (Mateus z / Mouts).
 */

session_start();

// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");
require_once("../../includes/controla_secao.php");
isPostMethod();

$caux = explode(':', $_POST['cdbarras']);
$laux = explode(':', $_POST['lndigita']);

$cdtippro = $_POST['cdtippro'];
$nrdconta = $_POST['nrdconta'];
$nmprimtl = $_POST['nmprimtl'];
$nmprepos = $_POST['nmprepos'];
$nmoperad = $_POST['nmoperad'];
$dsdbanco = $_POST['dsdbanco'];
$dsageban = $_POST['dsageban'];
$nrctafav = $_POST['nrctafav'];
$nmfavore = $_POST['nmfavore'];
$nrcpffav = $_POST['nrcpffav'];
$dsfinali = $_POST['dsfinali'];
$dstransf = $_POST['dstransf'];
$dscedent = $_POST['dscedent'];
$dttransa = $_POST['dttransa'];
$hrautent = $_POST['hrautent'];
$hrautenx = $_POST['hrautenx'];
$dtmvtolt = $_POST['dtmvtolt'];
$vldocmto = $_POST['vldocmto'];
$dsprotoc = $_POST['dsprotoc'];
$cdbarras = trim($caux[1]);
$lndigita = trim($laux[1]);
$nrseqaut = $_POST['nrseqaut'];
$nrdocmto = $_POST['nrdocmto'];
$dslinha1 = $_POST['dslinha1'];
$dslinha2 = $_POST['dslinha2'];
$dslinha3 = $_POST['dslinha3'];	  

// PRJ 470
$dtinclusao = $_POST['dtinclusao'];
$hrinclusao = $_POST['hrinclusao'];
$dsfrase    = utf8ToHtml($_POST['dsfrase']);
$dstippro   = utf8ToHtml($_POST['dstippro']);
//$dsfrase = utf8ToHtml("Documento autorizado mediante digitação de senha por $nmprimtl");

//bruno - prj 470 - tela autorizacao
$dsoperacao = (isset($_POST['dsoperacao']) ? $_POST['dsoperacao'] : ''); 
$cdbanco =    (isset($_POST['cdbanco'])    ? $_POST['cdbanco']    : ''); 
$cdagencia =  (isset($_POST['cdagencia'])  ? $_POST['cdagencia']  : ''); 
$cdconta =    (isset($_POST['cdconta'])    ? $_POST['cdconta']    : ''); 
$nrcheque_i = (isset($_POST['nrcheque_i']) ? $_POST['nrcheque_i'] : ''); 
$nrcheque_f = (isset($_POST['nrcheque_f']) ? $_POST['nrcheque_f'] : ''); 


//Bordero
$qttitbor = $_POST['dslinha2'];		 
// Pj470 - SM2 -- Mateus Zimmermann -- Mouts
$dsativo = $_POST['dsativo'];


$aux_dslinha1 = explode('#', $dslinha1);
$aux_dslinha2 = explode('#', $dslinha2);
$aux_dslinha3 = explode('#', $dslinha3);

//echo "ISPB ".$dsispbif = trim($aux_dslinha2[4]);	
$dsispbif = trim($aux_dslinha2[4]);

$nrcpffav = trim($aux_dslinha2[1]);
$arrayBanco = explode("-", $dsdbanco);

/*
16:"PAGAMENTO DARF";
17:"PAGAMENTO DAS";
18:"AGENDAMENTO DARF";
19:"AGENDAMENTO DAS";
*/

if ($cdtippro >= 16 && $cdtippro <= 19) {
	
	$tpcaptur = trim(substr($aux_dslinha3[0], strpos($aux_dslinha3[0], ":") + 1));

	$nmsolici = trim(substr($aux_dslinha3[1], strpos($aux_dslinha3[1], ":") + 1));
	$dsagtare = trim(substr($aux_dslinha3[2], strpos($aux_dslinha3[2], ":") + 1));
	$dsagenci = trim(substr($aux_dslinha3[3], strpos($aux_dslinha3[3], ":") + 1));
	$tpdocmto = trim(substr($aux_dslinha3[4], strpos($aux_dslinha3[4], ":") + 1));
	$dsnomfon = trim(substr($aux_dslinha3[5], strpos($aux_dslinha3[5], ":") + 1));
		
	if ($tpcaptur == 1){			
		$cdbarras = trim(substr($aux_dslinha3[6], strpos($aux_dslinha3[6], ":") + 1));
		$dslindig = trim(substr($aux_dslinha3[7], strpos($aux_dslinha3[7], ":") + 1));			
		$dtvencto = trim(substr($aux_dslinha3[8], strpos($aux_dslinha3[8], ":") + 1));
		
		if ($cdtippro == 17 || $cdtippro == 19) { //DAS
			$nrdocmto_das = trim(substr($aux_dslinha3[9], strpos($aux_dslinha3[9], ":") + 1));
			$dsidepag = trim(substr($aux_dslinha3[11], strpos($aux_dslinha3[11], ":") + 1));
		} elseif (substr($cdbarras, 15, 4) == 385 && substr($cdbarras, 1, 1) == 5){ // DARF385
			$nrdocmto_drf = trim(substr($aux_dslinha3[9], strpos($aux_dslinha3[9], ":") + 1));
			$dsidepag = trim(substr($aux_dslinha3[11], strpos($aux_dslinha3[11], ":") + 1));
		} else {
			$dsidepag = trim(substr($aux_dslinha3[10], strpos($aux_dslinha3[10], ":") + 1));
		}
		
	} elseif ($tpcaptur == 2){
		$dtapurac = trim(substr($aux_dslinha3[6], strpos($aux_dslinha3[6], ":") + 1));
		$nrcpfcgc = trim(substr($aux_dslinha3[7], strpos($aux_dslinha3[7], ":") + 1));
		$cdtribut = trim(substr($aux_dslinha3[8], strpos($aux_dslinha3[8], ":") + 1));
		
		if ($cdtribut == '6106'){
			$vlrecbru = trim(substr($aux_dslinha3[9], strpos($aux_dslinha3[9], ":") + 1));
			$vlpercen = trim(substr($aux_dslinha3[10], strpos($aux_dslinha3[10], ":") + 1));
		} else {
			$nrrefere = trim(substr($aux_dslinha3[9], strpos($aux_dslinha3[9], ":") + 1));
			$dtvencto = trim(substr($aux_dslinha3[10], strpos($aux_dslinha3[10], ":") + 1));
		}
		
		$vlprinci = trim(substr($aux_dslinha3[11], strpos($aux_dslinha3[11], ":") + 1));
		$vlrmulta = trim(substr($aux_dslinha3[12], strpos($aux_dslinha3[12], ":") + 1));
		$vlrjuros = trim(substr($aux_dslinha3[13], strpos($aux_dslinha3[13], ":") + 1));
		$vltotfat = trim(substr($aux_dslinha3[14], strpos($aux_dslinha3[14], ":") + 1));
		$dsidepag = trim(substr($aux_dslinha3[15], strpos($aux_dslinha3[15], ":") + 1));
	}
}else if($cdtippro == 20){ // Recarga de celular
	$vlrecarga 	 = formataMoeda($vldocmto);
	$nmoperadora = $aux_dslinha2[1];
	$nrtelefo	 = $aux_dslinha2[2];
	$dtrecarga	 = $dttransa;
	$hrrecarga	 = $hrautenx;	
	$dtdebito	 = $dtmvtolt;
	$nsuopera	 = $aux_dslinha2[4];
} elseif ($cdtippro == 21){
	$cpfopera  = trim($aux_dslinha2[0]);
	$nmoperad  = trim($aux_dslinha2[1]);
	$vlrboleto = trim($aux_dslinha2[2]);
	$vlrtrans  = trim($aux_dslinha2[3]);
	$vlrted    = trim($aux_dslinha2[4]); 
	$vlrvrbol  = trim($aux_dslinha2[5]); 
	$vlrflpgto = trim($aux_dslinha2[6]); 
  
} elseif ($cdtippro == 24) { //FGTS
    
    $cdbarras = trim(substr($aux_dslinha3[2], strpos($aux_dslinha3[1], ":") + 1));
    $tpdocmto = trim(substr($aux_dslinha3[0], strpos($aux_dslinha3[0], ":") + 1));
    $dslindig = trim(substr($aux_dslinha3[3], strpos($aux_dslinha3[2], ":") + 1));
    
    $nrconven = substr($cdbarras, 15, 4);
    
    if ($nrconven == '0179' || $nrconven == '0180' || $nrconven == '0181' || $nrconven == '0178' || $nrconven == '0240') { // Modelo 01 e 02
      
      $nrdocpes = trim(substr($aux_dslinha3[4], strpos($aux_dslinha3[4], ":") + 1));
      $cdconven = trim(substr($aux_dslinha3[5], strpos($aux_dslinha3[5], ":") + 1));
      $dtvalida = trim(substr($aux_dslinha3[6], strpos($aux_dslinha3[6], ":") + 1));
      $cdcompet = trim(substr($aux_dslinha3[7], strpos($aux_dslinha3[7], ":") + 1));
      $vltotfat = trim(substr($aux_dslinha3[8], strpos($aux_dslinha3[8], ":") + 1));
      $dsidepag = trim(substr($aux_dslinha3[9], strpos($aux_dslinha3[9], ":") + 1));
      $dtpagmto = trim(substr($aux_dslinha3[10], strpos($aux_dslinha3[10], ":") + 1));
      $hrpagmto = trim(substr($aux_dslinha3[11], strpos($aux_dslinha3[11], ":") + 1));
      
    } elseif ($nrconven == '0239' || $nrconven == '0451') { // Modelo 03

      $cdconven = trim(substr($aux_dslinha3[4], strpos($aux_dslinha3[4], ":") + 1));
      $dtvalida = trim(substr($aux_dslinha3[5], strpos($aux_dslinha3[5], ":") + 1));
      $cdidenti = trim(substr($aux_dslinha3[6], strpos($aux_dslinha3[6], ":") + 1));
      $vltotfat = trim(substr($aux_dslinha3[7], strpos($aux_dslinha3[7], ":") + 1));
      $dsidepag = trim(substr($aux_dslinha3[8], strpos($aux_dslinha3[8], ":") + 1));
      $dtpagmto = trim(substr($aux_dslinha3[9], strpos($aux_dslinha3[9], ":") + 1));
      $hrpagmto = trim(substr($aux_dslinha3[10], strpos($aux_dslinha3[10], ":") + 1));
      
    }
    
} elseif ($cdtippro == 23) { //DAE // Modelo 04

    $dsagtare = trim(substr($aux_dslinha3[1], strpos($aux_dslinha3[1], ":") + 1));
    $tpdocmto = trim(substr($aux_dslinha3[0], strpos($aux_dslinha3[0], ":") + 1));
    $cdbarras = trim(substr($aux_dslinha3[2], strpos($aux_dslinha3[2], ":") + 1));
    $dslindig = trim(substr($aux_dslinha3[3], strpos($aux_dslinha3[3], ":") + 1));
    $nrdocmto_dae = trim(substr($aux_dslinha3[4], strpos($aux_dslinha3[4], ":") + 1));
    $dsidepag = trim(substr($aux_dslinha3[6], strpos($aux_dslinha3[6], ":") + 1));
    $vltotfat = trim(substr($aux_dslinha3[5], strpos($aux_dslinha3[5], ":") + 1));
    $dtpagmto = trim(substr($aux_dslinha3[7], strpos($aux_dslinha3[7], ":") + 1));
    $hrpagmto = trim(substr($aux_dslinha3[8], strpos($aux_dslinha3[8], ":") + 1));
    
// PRJ 470    
} else if ($cdtippro >= 25 && $cdtippro <= 31) {
    
}

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
                                <td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><?php echo utf8ToHtml('DETALHES DO PROTOCOLO') ?></td>
                                <td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina($('#divRotina'));
                                        $('#divRotina').html('');
                                        return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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

                                        <form name="frmVerpro" id="frmVerpro" class="formulario">	
                                            <input name="cdtippro"  id="cdtippro"  type="hidden" value="<?php echo $cdtippro ?>" />
                                            <input name="nrdconta"  id="nrdconta"  type="hidden" value="<?php echo $nrdconta ?>" />
                                            <input name="nmprimtl"  id="nmprimtl"  type="hidden" value="<?php echo $nmprimtl ?>" />
                                            <input name="hrautent"  id="hrautent"  type="hidden" value="<?php echo $hrautent ?>" />
                                            <input name="label"     id="label"     type="hidden" value="<?php echo $label ?>" />
                                            <input name="label2"    id="label2"    type="hidden" value="<?php echo $label2 ?>" />
                                            <input name="auxiliar"  id="auxiliar"  type="hidden" value="<?php echo $auxiliar ?>" />
                                            <input name="auxiliar2" id="auxiliar2" type="hidden" value="<?php echo $auxiliar2 ?>" />
                                            <input name="auxiliar3" id="auxiliar3" type="hidden" value="<?php echo $auxiliar3 ?>" />
                                            <input name="auxiliar4" id="auxiliar4" type="hidden" value="<?php echo $auxiliar4 ?>" />
                                            <input name="cdbarrax"  id="cdbarrax"  type="hidden" value="<?php echo $_POST['cdbarras'] ?>" />
                                            <input name="lndigitx"  id="lndigitx"  type="hidden" value="<?php echo $_POST['lndigita'] ?>" />
                                            <input name="dslinha1"  id="dslinha1"  type="hidden" value="<?php echo $dslinha1 ?>" />
                                            <input name="dslinha2"  id="dslinha2"  type="hidden" value="<?php echo $dslinha2 ?>" />
                                            <input name="dslinha3"  id="dslinha3"  type="hidden" value="<?php echo $dslinha3 ?>" />
                                            <input name="dsispbif"  id="dsispbif"  type="hidden" value="<?php echo ($dsispbif == '0' || $dsispbif == '') && $arrayBanco[0] <> '001' ? "" : str_pad($dsispbif, 8, "0", STR_PAD_LEFT) ?>" />
                                            <input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">

                                            <input name="tpcaptur"  id="tpcaptur"  type="hidden" value="<?php echo $tpcaptur ?>" />
                                            <input name="cdtribut"  id="cdtribut"  type="hidden" value="<?php echo $cdtribut ?>" />

                                            <!-- PRJ 470 -->
                                            <input name="dtinclusao"  id="dtinclusao"  type="hidden" value="<?php echo $dtinclusao ?>" />
                                            <input name="hrinclusao"  id="hrinclusao"  type="hidden" value="<?php echo $hrinclusao ?>" />
											
                                            <fieldset>

                                                <legend> Detalhes do Protocolo </legend>	

                                                
                                                 <!-- campos do protocolo do pagamento de debaut (cdtippro = 15)  --> 
                                                <?php if ($cdtippro == 15) {
                                                    
                                                    $htmlLinhas = '';

                                                    for ($i = 0; $i < count($aux_dslinha3); $i++) {
                                                        // quebra as linhas por ':' e recupera label e value
                                                        list($label, $value) = split(':', $aux_dslinha3[$i]);

                                                        if ( trim($label) != '' && trim($value) != '' ) {
                                                            
                                                            if (strlen($label) > 19){
                                                              $label = substr($label,0,19) . ".";
                                                            }
                                                            
                                                            $htmlLinhas .= '<label style="width: auto; text-align:right; width: 115px;" class="rotulo">'.utf8ToHtml($label).':</label>
                                                                            <input name="" style="width: 440px" type="text" value="'.$value.'" /><br />';
                                                        }
                                                    } 
                                                    echo $htmlLinhas;
                                                } ?>

												<?php if($cdtippro == 21){?>
												<label for="nmprepos"><?php echo utf8ToHtml('Cadastrado por:') ?></label>
                                                <input name="nmprepos" id="nmprepos" type="text" value="<?php echo $nmprepos ?>" />
												<label for="nmoperad"><?php echo utf8ToHtml('Operador:') ?></label>
                                                <input name="nmoperad" id="nmoperad" type="text" value="<?php echo $nmoperad ?>" />
												<label for="nmoperad"><?php echo utf8ToHtml('CPF Operador:') ?></label>
                                                <input name="nmoperad" id="nmoperad" type="text" value="<?php echo formatar($cpfopera, 'cpf') ?>" />
												<?php } else {?>
                                                <label for="nmprepos"><?php echo utf8ToHtml('Preposto:') ?></label>
                                                <input name="nmprepos" id="nmprepos" type="text" value="<?php echo $nmprepos ?>" />

                                                <label for="nmoperad"><?php echo utf8ToHtml('Operador:') ?></label>
                                                <input name="nmoperad" id="nmoperad" type="text" value="<?php echo $nmoperad ?>" />

                                                <label for="nrdocmtx"><?php echo utf8ToHtml('Nr do Plano:') ?></label>
                                                <input name="nrdocmtx" id="nrdocmtx" type="text" value="<?php echo $nrdocmto ?>" />

                                                <label for="tpdpagto"><?php echo utf8ToHtml('Tipo:') ?></label>
                                                <input name="tpdpagto" id="tpdpagto" type="text" value="<?php echo $tpdpagto ?>" />

                                                <label for="dsdbanco"><?php if ($cdtippro == 9) echo utf8ToHtml('Banco Favorecido:');else echo utf8ToHtml('Banco:'); ?></label>
                                                <input name="dsdbanco" id="dsdbanco" type="text" value="<?php echo ($arrayBanco[0] == '000' || $arrayBanco[0] == '0') ? $arrayBanco[1] : $dsdbanco ?>" />
												<?php }?>
                                                <?php if ($cdtippro == 9) { ?>
                                                    <label for="dsispbif"><? echo utf8ToHtml(' ISPB Favorecido:'); ?></label> 
                                                    <input name="dsispbif" id="dsispbif" type="text" value="<?php echo ($dsispbif == '0' || $dsispbif == '') && trim($arrayBanco[0]) != "001" ? "" : str_pad($dsispbif, 8, "0", STR_PAD_LEFT) ?>" />
                                                <?php } ?>
                                                <label for="dsageban"><?php echo utf8ToHtml('Agencia Favorecido:') ?></label>
                                                <input name="dsageban" id="dsageban" type="text" value="<?php echo $dsageban ?>" />

                                                <label for="nrctafav"><?php echo utf8ToHtml('Conta Favorecido:') ?></label>
                                                <input name="nrctafav" id="nrctafav" type="text" value="<?php echo $nrctafav ?>" />

                                                <label for="nmfavore"><?php echo utf8ToHtml('Nome Favorecido:') ?></label>
                                                <input name="nmfavore" id="nmfavore" type="text" value="<?php
                                                if ($cdtippro == 9)
                                                    echo $aux_dslinha3[0];
                                                else
                                                    echo $nmfavore
                                                ?>" />
                                                <label for="nrcpffav"><?php if (strlen($nrcpffav) == 18) echo utf8ToHtml('CNPJ Favorecido:');
													else echo utf8ToHtml('CPF Favorecido:'); ?></label>
                                                <input name="nrcpffav" id="nrcpffav" type="text" value="<?php
                                                if ($cdtippro == 9)
                                                    echo $aux_dslinha3[1];
                                                else
                                                    echo $nrcpffav
                                                    ?>" />

                                                <label for="dsfinali"><?php echo utf8ToHtml('Finalidade:') ?></label>
                                                <input name="dsfinali" id="dsfinali" type="text" value="<?php
                                                if ($cdtippro == 9)
                                                    echo $aux_dslinha3[2];
                                                else
                                                    echo $dsfinali
                                                    ?>" />
													
												<?php if ($cdtippro >= 16 && $cdtippro <= 19) { //DARF/DAS ?> 
													<label for="nmsolici_drf"><?php echo utf8ToHtml('Solicitante:') ?></label>
													<input name="nmsolici_drf" id="nmsolici_drf" type="text" value="<?php echo $nmsolici; ?>" />
													<label for="dsagtare"><?php echo utf8ToHtml('Agente Arrecadador:') ?></label>
													<input name="dsagtare" id="dsagtare" type="text" value="<?php echo $dsagtare; ?>" />
													<label for="dsagenci"><?php echo utf8ToHtml('Agência:') ?></label>
													<input name="dsagenci" id="dsagenci" type="text" value="<?php echo $dsagenci; ?>" />
													<label for="tpdocmto"><?php echo utf8ToHtml('Tipo de Documento:') ?></label>
													<input name="tpdocmto" id="tpdocmto" type="text" value="<?php echo $tpdocmto; ?>" />
													<label for="dsnomfon"><?php echo utf8ToHtml('Nome/Telefone:') ?></label>
													<input name="dsnomfon" id="dsnomfon" type="text" value="<?php echo $dsnomfon; ?>" />
													
													<?php if ($tpcaptur == 1) { //COD BARRA ?> 
														<label for="cdbarras"><?php echo utf8ToHtml('Código de Barras:') ?></label>
														<input name="cdbarras" id="cdbarras" type="text" value="<?php echo $cdbarras; ?>" />
														<label for="dslindig"><?php echo utf8ToHtml('Linha Digitável:') ?></label>
														<input name="dslindig" id="dslindig" type="text" value="<?php echo $dslindig; ?>" />
														<label for="dtvencto_drf"><?php echo utf8ToHtml('Data de Vencimento:') ?></label>
														<input name="dtvencto_drf" id="dtvencto_drf" type="text" value="<?php echo $dtvencto; ?>" />
														
														<?php if ($cdtippro == 17 || $cdtippro == 19) { //DAS ?>
															<label for="nrdocmto_das"><?php echo utf8ToHtml('Nr. Docmto. (DAS):') ?></label>
															<input name="nrdocmto_das" id="nrdocmto_das" type="text" value="<?php echo $nrdocmto_das; ?>" />
														<?php } elseif (substr($cdbarras, 15, 4) == 385 && substr($cdbarras, 1, 1) == 5) { // DARF385 ?>
															<label for="nrdocmto_drf"><?php echo utf8ToHtml('Nr. Docmto.(DARF):') ?></label>
															<input name="nrdocmto_drf" id="nrdocmto_drf" type="text" value="<?php echo $nrdocmto_drf; ?>" />
														<?php } ?>
														
														<label for="vltotfat"><?php echo utf8ToHtml('Valor Total:') ?></label>
														<input name="vltotfat" id="vltotfat" type="text" value="<?php echo formataMoeda($vldocmto); ?>" />
													<?php } elseif ($tpcaptur == 2) { //MANUAL ?> 
														<label for="dtapurac"><?php echo utf8ToHtml('Período de Apuração:') ?></label>
														<input name="dtapurac" id="dtapurac" type="text" value="<?php echo $dtapurac; ?>" />
														<label for="nrcpfcgc"><?php echo utf8ToHtml('Número do CPF ou CNPJ:') ?></label>
														<input name="nrcpfcgc" id="nrcpfcgc" type="text" value="<?php echo $nrcpfcgc; ?>" />
														<label for="cdtribut"><?php echo utf8ToHtml('Código da Receita:') ?></label>
														<input name="cdtribut" id="cdtribut" type="text" value="<?php echo $cdtribut; ?>" />
														
															<?php if ($cdtribut == '6106') {  ?> 
																<label for="vlrecbru"><?php echo utf8ToHtml('Valor da Receita Bruta:') ?></label>
																<input name="vlrecbru" id="vlrecbru" type="text" value="<?php echo formataMoeda($vlrecbru); ?>" />
																<label for="vlpercen"><?php echo utf8ToHtml('Percentual:') ?></label>
																<input name="vlpercen" id="vlpercen" type="text" value="<?php echo formataMoeda($vlpercen); ?>" />
															<?php } else { ?>
																<label for="nrrefere"><?php echo utf8ToHtml('Número de Referência:') ?></label>
																<input name="nrrefere" id="nrrefere" type="text" value="<?php echo $nrrefere; ?>" />
																<label for="dtvencto_drf"><?php echo utf8ToHtml('Data de Vencimento:') ?></label>
																<input name="dtvencto_drf" id="dtvencto_drf" type="text" value="<?php echo $dtvencto; ?>" />
															<?php } ?>
															
														<label for="vlprinci"><?php echo utf8ToHtml('Valor Principal:') ?></label>
														<input name="vlprinci" id="vlprinci" type="text" value="<?php echo $vlprinci; ?>" />
														<label for="vlrmulta"><?php echo utf8ToHtml('Valor Multa:') ?></label>
														<input name="vlrmulta" id="vlrmulta" type="text" value="<?php echo $vlrmulta; ?>" />
														<label for="vlrjuros"><?php echo utf8ToHtml('Valor Juros:') ?></label>
														<input name="vlrjuros" id="vlrjuros" type="text" value="<?php echo $vlrjuros; ?>" />
														<label for="vltotfat"><?php echo utf8ToHtml('Valor Total:') ?></label>
														<input name="vltotfat" id="vltotfat" type="text" value="<?php echo $vltotfat; ?>" />
													<?php } ?>
													
													<label for="dsidepag"><?php echo utf8ToHtml('Descrição do Pagto.:') ?></label>
													<input name="dsidepag" id="dsidepag" type="text" value="<?php echo $dsidepag ?>" />
													<?php if ($cdtippro == 18 || $cdtippro == 19){ ?>		
														<label for="dtmvtdrf"><?php echo utf8ToHtml('Data Transação:') ?></label>
														<input name="dtmvtdrf" id="dtmvtdrf" type="text" value="<?php echo $dtmvtolt ?>" />
													
														<label for="hrautdrf"><?php echo utf8ToHtml('Hora Transação:') ?></label>
														<input name="hrautdrf" id="hrautdrf" type="text" value="<?php echo $hrautenx ?>" />
													<?php }else{ ?>
														<label for="dtmvtdrf"><?php echo utf8ToHtml('Data Pagamento:') ?></label>
														<input name="dtmvtdrf" id="dtmvtdrf" type="text" value="<?php echo $dtmvtolt ?>" />
													
														<label for="hrautdrf"><?php echo utf8ToHtml('Hora Pagamento:') ?></label>
														<input name="hrautdrf" id="hrautdrf" type="text" value="<?php echo $hrautenx ?>" />
													
													<?php } 
														}
													?>
                          
                          <?php if ($cdtippro == 24) { //FGTS ?>
                          
                            <label for="tpdocmto"><?php echo utf8ToHtml('Tipo de Documento:') ?></label>
                            <input name="tpdocmto" id="tpdocmto" type="text" value="<?php echo $tpdocmto; ?>" />
                            
                            <label for="cdbarras"><?php echo utf8ToHtml('Código de Barras:') ?></label>
                            <input name="cdbarras" id="cdbarras" type="text" value="<?php echo $cdbarras; ?>" />
                            
                            <label for="dslindig"><?php echo utf8ToHtml('Linha Digitável:') ?></label>
                            <input name="dslindig" id="dslindig" type="text" value="<?php echo $dslindig; ?>" />
                            
                            <?php if ($cdconven == '0179' || $cdconven == '0180' || $cdconven == '0181') { //Modelo 01 ?>
                            
                              <label for="nrdocpes"><?php echo utf8ToHtml('CNPJ/CEI Empresa/CPF:') ?></label>
                              <input name="nrdocpes" id="nrdocpes" type="text" value="<?php echo $nrdocpes; ?>" />
                            
                            <?php } elseif ($cdconven == '0178' || $cdconven == '0240') { //Modelo 02 ?>
                            
                              <label for="nrdocpes"><?php echo utf8ToHtml('CNPJ/CEI Empresa:') ?></label>
                              <input name="nrdocpes" id="nrdocpes" type="text" value="<?php echo $nrdocpes; ?>" />
                            
                            <?php } ?>
                          
                            <label for="cdconven"><?php echo utf8ToHtml('Cod. Convênio:') ?></label>
                            <input name="cdconven" id="cdconven" type="text" value="<?php echo $cdconven; ?>" />
                            
                            <label for="dtvalida"><?php echo utf8ToHtml('Data da Validade:') ?></label>
                            <input name="dtvalida" id="dtvalida" type="text" value="<?php echo $dtvalida; ?>" />
                            
                            <?php if ($cdconven == '0179' || $cdconven == '0180' || $cdconven == '0181' || $cdconven == '0178' || $cdconven == '0240') { //Modelo 01 e 02 ?>
                            
                              <label for="cdcompet"><?php echo utf8ToHtml('Competência:') ?></label>
                              <input name="cdcompet" id="cdcompet" type="text" value="<?php echo $cdcompet; ?>" />
                            
                            <?php } elseif ($cdconven == '0239' || $cdconven == '0451') { //Modelo 03 ?>
                              
                              <label for="cdidenti"><?php echo utf8ToHtml('Identificador:') ?></label>
                              <input name="cdidenti" id="cdidenti" type="text" value="<?php echo $cdidenti; ?>" />
                              
                            <?php } ?>
                            
                            <label for="vltotfat"><?php echo utf8ToHtml('Valor Total:') ?></label>
                            <input name="vltotfat" id="vltotfat" type="text" value="<?php echo $vltotfat; ?>" />
                            
                            <label for="dsidepag"><?php echo utf8ToHtml('Descrição do Pagto.:') ?></label>
                            <input name="dsidepag" id="dsidepag" type="text" value="<?php echo $dsidepag; ?>" />
                            
                            <label for="dtmvtdrf"><?php echo utf8ToHtml('Data Pagamento:') ?></label>
                            <input name="dtmvtdrf" id="dtmvtdrf" type="text" value="<?php echo $dtpagmto ?>" />
                          
                            <label for="hrautdrf"><?php echo utf8ToHtml('Hora Pagamento:') ?></label>
                            <input name="hrautdrf" id="hrautdrf" type="text" value="<?php echo $hrpagmto ?>" />

                          <?php } elseif ($cdtippro == 23) { //DAE ?>
                            
                            <label for="tpdocmto"><?php echo utf8ToHtml('Tipo de Documento:') ?></label>
                            <input name="tpdocmto" id="tpdocmto" type="text" value="<?php echo $tpdocmto; ?>" />

                            <label for="dsagtare"><?php echo utf8ToHtml('Agente Arrecadador:') ?></label>
                            <input name="dsagtare" id="dsagtare" type="text" value="<?php echo $dsagtare; ?>" />
                            
                            <label for="cdbarras"><?php echo utf8ToHtml('Código de Barras:') ?></label>
                            <input name="cdbarras" id="cdbarras" type="text" value="<?php echo $cdbarras; ?>" />
                            
                            <label for="dslindig"><?php echo utf8ToHtml('Linha Digitável:') ?></label>
                            <input name="dslindig" id="dslindig" type="text" value="<?php echo $dslindig; ?>" />
                            
                            <label for="nrdocmto_dae"><?php echo utf8ToHtml('Nr. Docmto. (DAE):') ?></label>
                            <input name="nrdocmto_dae" id="nrdocmto_dae" type="text" value="<?php echo $nrdocmto_dae; ?>" />
                            
                            <label for="vltotfat"><?php echo utf8ToHtml('Valor Total:') ?></label>
                            <input name="vltotfat" id="vltotfat" type="text" value="<?php echo $vltotfat; ?>" />
                            
                            <label for="dsidepag"><?php echo utf8ToHtml('Descrição do Pagto.:') ?></label>
                            <input name="dsidepag" id="dsidepag" type="text" value="<?php echo $dsidepag; ?>" />
                            
                            <label for="dtmvtdrf"><?php echo utf8ToHtml('Data Pagamento:') ?></label>
                            <input name="dtmvtdrf" id="dtmvtdrf" type="text" value="<?php echo $dtpagmto ?>" />
                          
                            <label for="hrautdrf"><?php echo utf8ToHtml('Hora Pagamento:') ?></label>
                            <input name="hrautdrf" id="hrautdrf" type="text" value="<?php echo $hrpagmto ?>" />
                          
                          <?php
														}
													?>

                          <label for="dstransf"><?php echo utf8ToHtml('Cod.Identificador:') ?></label>
                          <input name="dstransf" id="dstransf" type="text" value="<?php echo $dstransf ?>" />

                          <label for="dscedent"><?php echo utf8ToHtml('Cedente:') ?></label>
                          <input name="dscedent" id="dscedent" type="text" value="<?php echo $dscedent ?>" />

                          <label for="dttransa"><?php echo utf8ToHtml('Data Transação:') ?></label>
                          <input name="dttransa" id="dttransa" type="text" value="<?php echo $dttransa ?>" />

                          <label for="hrautenx"><?php echo utf8ToHtml('Hora:') ?></label>
                          <input name="hrautenx" id="hrautenx" type="text" value="<?php echo $hrautenx ?>" />

												<!-- Pacote de tarfas -->
												<?php if ($cdtippro == 14){?>
												
													<label for="dspacote"><?php echo utf8ToHtml('Serviço:') ?></label>													
													<input name="dspacote" id="dspacote" type="text" value="<?php echo trim(substr($aux_dslinha2[0], strpos($aux_dslinha2[0], "#"))) ?>" />													
												
												<?}?>
                                                
                                                <?php if($cdtippro == 32){?>
                                                    
                                                    <label for="nrborder"><? echo utf8ToHtml('Nr. do Borderô:') ?></label>
                                                    <input name="nrborder" id="nrborder" type="text" value="<? echo $nrdocmto ?>" />
                                                    
                                                    <label for="qttitbor"><? echo utf8ToHtml('Qtd. de títulos:') ?></label>
                                                    <input name="qttitbor" id="qttitbor" type="text" value="<? echo $qttitbor ?>" />
                                                    
                                                <?php }?>
                                                <!-- PRJ 470 - Ajuste para não entrar no IF -->
												<?php if($cdtippro != 21 && ($cdtippro < 25 || $cdtippro > 31)){?>
                                                <label for="dtmvtolt"><?php echo utf8ToHtml('Data Pagamento:') ?></label>
                                                <input name="dtmvtolt" id="dtmvtolt" type="text" value="<?php echo $dtmvtolt ?>" />

                                                <label for="vldocmto"><?php echo utf8ToHtml('Valor:') ?></label>
                                                <input name="vldocmto" id="vldocmto" type="text" value="<?php echo formataMoeda($vldocmto) ?>" />
												<?php }?>
												<!-- Pacote de tarfas -->
												<?php if ($cdtippro == 14){?>
													
													<label for="dtdiadeb"><?php echo utf8ToHtml('Dia do débito:') ?></label>
													<input name="dtdiadeb" id="dtdiadeb" type="text" value="<?php echo trim(substr($aux_dslinha2[2], strpos($aux_dslinha2[2], "#"))) ?>" />
													
													<label for="dtinivig"><?php echo utf8ToHtml('Início Vigência:') ?></label>
													<input name="dtinivig" id="dtinivig" type="text" value="<?php echo trim(substr($aux_dslinha2[3], strpos($aux_dslinha2[3], "#"))) ?>" />
	
												<?php }?>
												
                                                <!-- campos do protocolo de aplicacao (cdtippro = 10) -->
                                                <label for="nrctaapl"><?php echo utf8ToHtml('Conta/dv:') ?></label>
                                                
                                                <!-- PJ 470 -->
                                                <input name="nrctaapl" id="nrctaapl" type="text" value="<?php 
                                                if ($cdtippro >= 25 && $cdtippro <= 31 ) {
                                                    echo substr($nrdconta,0,strlen($nrdconta)-1) . "-" . substr($nrdconta,strlen($nrdconta)-1,1);
                                                } else 
                                                    echo trim(substr($aux_dslinha2[1], strpos($aux_dslinha2[1], ":") + 1)) 
                                                    ?>" />
                                                
                                                <label for="nmsolici"><?php echo utf8ToHtml('Solicitante:') ?></label>
                                                <input name="nmsolici" id="nmsolici" type="text" value="<?php
                                                 if ($cdtippro >= 25 && $cdtippro <= 31) echo $nmprimtl;  else echo trim(substr($dslinha2, 0, strpos($dslinha2, '#')))
                                                 ?>" />

                                                <?php if ($cdtippro == 10) { ?>

                                                    <label for="dtaplica"><?php echo utf8ToHtml('Data da Aplicação:') ?></label>
                                                    <input name="dtaplica" id="dtaplica" type="text" value="<?php echo trim(substr($aux_dslinha3[0], strpos($aux_dslinha3[0], ":") + 1)) ?>" />

                                                    <label for="hraplica"><?php echo utf8ToHtml('Hora da Aplicação:') ?></label>
                                                    <input name="hraplica" id="hraplica" type="text" value="<?php echo $hrautenx ?>" />

                                                    <?php
                                                    if ($aux_dslinha3[10] == "N") {
                                                        ?>
                                                        <label for="nraplica"><?php echo utf8ToHtml('Número da Aplicação:') ?></label>
                                                        <input name="nraplica" id="nraplica" type="text" value="<?php echo trim(substr($aux_dslinha3[1], strpos($aux_dslinha3[1], ":") + 1)) . ' - ' . $aux_dslinha3[11] ?>" />
                                                        <?php
                                                    } else {
                                                        ?>													
                                                        <label for="nraplica"><?php echo utf8ToHtml('Número da Aplicação:') ?></label>
                                                        <input name="nraplica" id="nraplica" type="text" value="<?php echo trim(substr($aux_dslinha3[1], strpos($aux_dslinha3[1], ":") + 1)) ?>" />
                                                        <?php
                                                    }
                                                    ?>

                                                    <label for="vlaplica"><?php echo utf8ToHtml('Valor:') ?></label>
                                                    <input name="vlaplica" id="vlaplica" type="text" value="<?php echo formataMoeda($vldocmto) ?>" />

                                                    <label for="txctrada"><?php echo utf8ToHtml('Taxa Contratada:') ?></label>
                                                    <input name="txctrada" id="txctrada" type="text" value="<?php echo trim(substr($aux_dslinha3[2], strpos($aux_dslinha3[2], ":") + 1)) ?>" />

                                                    <!-- Validar o tipo de aplicação para não exibir a carência quando "Aplicação Pré" e diferenciar as posições do dslinha 3 -->
                                                    <?php if ($aux_dslinha1[0] == 'Aplicacao Pos' || $aux_dslinha3[10] == "N") { ?>
                                                        <label for="txminima"><?php echo utf8ToHtml('Taxa Mínima:') ?></label>
                                                        <input name="txminima" id="txminima" type="text" value="<?php echo trim(substr($aux_dslinha3[3], strpos($aux_dslinha3[3], ":") + 1)) ?>" />

                                                        <label for="dtvencto"><?php echo utf8ToHtml('Vencimento:') ?></label>
                                                        <input name="dtvencto" id="dtvencto" type="text" value="<?php echo trim(substr($aux_dslinha3[4], strpos($aux_dslinha3[4], ":") + 1)) ?>" />

                                                        <label for="carencia"><?php echo utf8ToHtml('Carência:') ?></label>
                                                        <input name="carencia" id="carencia" type="text" value="<?php echo trim(substr($aux_dslinha3[5], strpos($aux_dslinha3[5], ":") + 1)) ?>" />

                                                        <label for="dtcarenc"><?php echo utf8ToHtml('Data da Carência:') ?></label>
                                                        <input name="dtcarenc" id="dtcarenc" type="text" value="<?php echo trim(substr($aux_dslinha3[6], strpos($aux_dslinha3[6], ":") + 1)) ?>" />
                                                    <?php } else { ?>
                                                        <label for="txminima"><?php echo utf8ToHtml('Taxa no Período:') ?></label>
                                                        <input name="txminima" id="txminima" type="text" value="<?php echo trim(substr($aux_dslinha3[10], strpos($aux_dslinha3[10], ":") + 1)) ?>" />

                                                        <label for="dtvencto"><?php echo utf8ToHtml('Vencimento:') ?></label>
                                                        <input name="dtvencto" id="dtvencto" type="text" value="<?php echo trim(substr($aux_dslinha3[3], strpos($aux_dslinha3[3], ":") + 1)) ?>" />

                                                        <label for="carencia"><?php echo utf8ToHtml('Carência:') ?></label>
                                                        <input name="carencia" id="carencia" type="text" value="<?php echo trim(substr($aux_dslinha3[4], strpos($aux_dslinha3[4], ":") + 1)) ?>" />

                                                        <label for="dtcarenc"><?php echo utf8ToHtml('Data da Carência:') ?></label>
                                                        <input name="dtcarenc" id="dtcarenc" type="text" value="<?php echo trim(substr($aux_dslinha3[5], strpos($aux_dslinha3[5], ":") + 1)) ?>" />
                                                    <?php } ?>

                                                    <!-- campos do protocolo de resgate de aplicacao (cdtippro = 12) -->
                                                    <?php } elseif ($cdtippro == 12) { ?>

                                                    <label for="dtresgat"><?php echo utf8ToHtml('Data de Resgate:') ?></label>
                                                    <input name="dtresgat" id="dtresgat" type="text" value="<?php echo trim(substr($aux_dslinha3[0], strpos($aux_dslinha3[0], ":") + 1)) ?>" />

                                                    <label for="hrresgat"><?php echo utf8ToHtml('Hora de Resgate:') ?></label>
                                                    <input name="hrresgat" id="hrresgat" type="text" value="<?php echo $hrautenx ?>" />

                                                    <label for="nraplica"><?php echo utf8ToHtml('Número da Aplicação:') ?></label>
                                                    <input name="nraplica" id="nraplica" type="text" value="<?php echo trim(substr($aux_dslinha3[1], strpos($aux_dslinha3[1], ":") + 1)) ?>" />

                                                    <label for="vlrbruto"><?php echo utf8ToHtml('Valor Bruto:') ?></label>
                                                    <input name="vlrbruto" id="vlrbruto" type="text" value="<?php echo trim(substr($aux_dslinha3[4], strpos($aux_dslinha3[4], ":") + 1)) ?>" />																																	

                                                    <label for="vldoirrf"><?php echo utf8ToHtml('IRRF:') ?></label>
                                                    <input name="vldoirrf" id="vldoirrf" type="text" value="<?php echo trim(substr($aux_dslinha3[2], strpos($aux_dslinha3[2], ":") + 1)) . ' - Imposto de Renda Retido na Fonte' ?>" />

                                                    <label for="vlaliqir"><?php echo utf8ToHtml('Alíquota IRRF:') ?></label>
                                                    <input name="vlaliqir" id="vlaliqir" type="text" value="<?php echo trim(substr($aux_dslinha3[3], strpos($aux_dslinha3[3], ":") + 1)) ?>" />

                                                    <label for="vlliquid"><?php echo utf8ToHtml('Valor Líquido:') ?></label>
                                                    <input name="vlliquid" id="vlliquid" type="text" value="<?php echo formataMoeda($vldocmto) ?>" />

                                                <!-- campos do protocolo de guia da previdencia social (cdtippro = 13) -->
                                                <?php } else if ($cdtippro == 13) { 
                                                    
                                                    $htmlLinhas = '';

                                                    for ($i = 0; $i < count($aux_dslinha3); $i++) {
                                                        // quebra as linhas por ':' e recupera label e value
                                                        list($label, $value) = split(':', $aux_dslinha3[$i]);

                                                        if ( trim($label) != '' && trim($value) != '' ) {

                                                            $htmlLinhas .= '<label style="width: auto; text-align:right; width: 170px;" class="rotulo">'.utf8ToHtml($label).':</label>
                                                                            <input name="" style="width: 380px" type="text" value="'.$value.'" /><br />';
                                                        }
                                                    } 
                                                    echo $htmlLinhas;
												}  elseif ($cdtippro == 20) { ?>

                                                    <label for="vlrecarga">Valor:</label>
                                                    <input name="vlrecarga" id="vlrecarga" type="text" value="<?php echo $vlrecarga ?>" />

                                                    <label for="nmoperadora">Operadora:</label>
                                                    <input name="nmoperadora" id="nmoperadora" type="text" value="<?php echo $nmoperadora ?>" />

                                                    <label for="nrtelefo">DDD/Telefone:</label>
                                                    <input name="nrtelefo" id="nrtelefo" type="text" value="<?php echo $nrtelefo ?>" />

                                                    <label for="dtrecarga">Data da Recarga:</label>
                                                    <input name="dtrecarga" id="dtrecarga" type="text" value="<?php echo $dtrecarga ?>" />																																	

                                                    <label for="hrrecarga">Hora:</label>
                                                    <input name="hrrecarga" id="hrrecarga" type="text" value="<?php echo $hrrecarga ?>" />
													
                                                    <label for="dtdebito">Data do Lan&ccedil;amento:</label>
                                                    <input name="dtdebito" id="dtdebito" type="text" value="<?php echo $dtdebito ?>" />
													
                                                    <label for="nsuopera">NSU Operadora:</label>
                                                    <input name="nsuopera" id="nsuopera" type="text" value="<?php echo $nsuopera ?>" />

                                                <?php } elseif ($cdtippro >= 25 && $cdtippro <= 31) { // PRJ 470 ?>

                                                    <label for="dtinclusao"><?php echo utf8ToHtml('Data da Inclusão:') ?></label>
                                                    <input name="dtinclusao" id="dtinclusao" type="text" value="<?php echo $dtinclusao; ?>" />
                                                    
                                                    <label for="hrinclusao"><?php echo utf8ToHtml('Hora da Inclusão:') ?></label>
                                                    <input name="hrinclusao" id="hrinclusao" type="text" value="<?php echo $hrautenx; ?>" />

                                                    <label for="tpdocmto"><?php echo utf8ToHtml('Tipo de Documento:') ?></label>
                                                    <input name="tpdocmto" id="tpdocmto" type="text" value="<?php echo $dstippro; ?>" />    

                                                    <?php
                                                    //bruno - tela autorizacao
                                                    if($cdtippro == 30 || $cdtippro == 31){
                                                        if($cdtippro == 30){
                                                            ?>
                                                            <label for="dsoperacao"><?php echo utf8ToHtml('Operação:') ?></label>
                                                            <input name="dsoperacao" id="dsoperacao" type="text" value="<?php echo $dsoperacao; ?>" /> 
                                                            <?php
                                                        }
                                                        ?>
                                                        <label for="cdbanco"><?php echo utf8ToHtml('Banco:') ?></label>
                                                        <input name="cdbanco" id="cdbanco" type="text" value="<?php echo $cdbanco; ?>" /> 
                                                        
                                                        <label for="cdagencia"><?php echo utf8ToHtml('Agência:') ?></label>
                                                        <input name="cdagencia" id="cdbanco" type="text" value="<?php echo $cdagencia; ?>" /> 

                                                        <label for="cdconta"><?php echo utf8ToHtml('Conta:') ?></label>
                                                        <input name="cdconta" id="cdconta" type="text" value="<?php echo $cdconta; ?>" /> 

                                                        <label for="nrcheque_i"><?php echo utf8ToHtml('Cheque Inicial:') ?></label>
                                                        <input name="nrcheque_i" id="nrcheque_i" type="text" value="<?php echo $nrcheque_i; ?>" /> 

                                                        <label for="nrcheque_f"><?php echo utf8ToHtml('Cheque Final:') ?></label>
                                                        <input name="nrcheque_f" id="nrcheque_f" type="text" value="<?php echo $nrcheque_f; ?>" />
                                                        <?php
                                                    } 
                                                    ?>

												<?php } ?>

												<?php 
                                                //bruno - prj 470 - tela autorizacao
                                                if($cdtippro != 30 && $cdtippro != 31){ 
                                                    ?>
												<label for="nrdocmto">Nr. Documento:</label>
                                                <input name="nrdocmto" id="nrdocmto" type="text" value="<?php echo $nrdocmto ?>" />
                                                    <?php 
                                                }
                                                if ($cdtippro >= 25 && $cdtippro <= 31) { // PRJ 470
                                                    //bruno - prj 470 - tela autorizacao
                                                    if($cdtippro != 30 && $cdtippro != 31){ 
                                                        ?>
                                                    <label for="vldocmto"><?php echo utf8ToHtml('Valor:') ?></label>
                                                    <input name="vldocmto" id="vldocmto" type="text" value="<?php echo formataMoeda($vldocmto) ?>" />
                                                        <?php
                                                    } 
                                                } 
                                                ?>
												
												<br style="clear:both" />
												
                                                <?php 
                                                //bruno - prj 470 - remover campo seq. autentica
                                                if($cdtippro < 25 || $cdtippro > 31){ ?>
												<label for="nrseqaut">Seq. Autentica&ccedil;&atilde;o:</label>
                                                <input name="nrseqaut" id="nrseqaut" type="text" value="<? echo $nrseqaut ?>" />
                                                <?php 
                                                }
                                                ?>

												<?php if($cdtippro == 21){?>
													<fieldset>
													<legend> Limites </legend>
													<label for="vlrtrans"><?php utf8ToHtml(Transferência)?>:</label>
													<input name="vlrtrans" id="vlrtrans" type="text" value="<?php echo formataMoeda($vlrtrans) ?>" />
													<label for="vlrboleto">Boletos:</label>
													<input name="vlrboleto" id="vlrboleto" type="text" value="<?php echo formataMoeda($vlrboleto) ?>" />
													<label for="vlrted">TED:</label>
													<input name="vlrted" id="vlrted" type="text" value="<?php echo formataMoeda($vlrted) ?>" />
													<label for="vlrvrbol">VR Boletos:</label>
													<input name="vlrvrbol" id="vlrvrbol" type="text" value="<?php echo formataMoeda($vlrvrbol) ?>" />
													<label for="vlrflpgto">Folhas de PGTO:</label>
													<input name="vlrflpgto" id="vlrflpgto" type="text" value="<?php echo formataMoeda($vlrflpgto) ?>" />
													</fieldset>
													<?php if(isset($aux_dslinha3[0])){?>
														<label style="width: auto; text-align:right; width: 170px;" for="preaprov1">Preposto Responsavel:</label>
														<input style="width: 380px" name="preaprov" id="preaprov1" type="text" value="<?php $aux_dslinha3[0]?> - <?php $aux_dslinha3[1]?>" />
													<?php  }?>
													<?php  if(isset($aux_dslinha3[2])){?>
														<label style="width: auto; text-align:right; width: 170px;" for="preaprov1">Prepostos Aprovarores#1:</label>
														<input style="width: 380px" name="preaprov" id="preaprov1" type="text" value="<?php $aux_dslinha3[2]?> - <?php $aux_dslinha3[3]?>" />
													<?php  }?>
													<?php if(isset($aux_dslinha3[4])){?>
														<label style="width: auto; text-align:right; width: 170px;" for="preaprov2">Prepostos Aprovarores#2:</label>
														<input style="width: 380px" name="preaprov" id="preaprov2" type="text" value="<?php $aux_dslinha3[4]?> - <?php $aux_dslinha3[5]?>" />
													<?php }?>
													<?php if(isset($aux_dslinha3[6])){?>
														<label style="width: auto; text-align:right; width: 170px;" for="preaprov3">Prepostos Aprovarores#3:</label>
														<input style="width: 380px" name="preaprov" id="preaprov3" type="text" value="<?php $aux_dslinha3[6]?> - <?php $aux_dslinha3[7]?>" />
													<?php }?>
													<?php if(isset($aux_dslinha3[8])){?>
														<label style="width: auto; text-align:right; width: 170px;" for="preaprov4">Prepostos Aprovarores#4:</label>
														<input style="width: 380px" name="preaprov" id="preaprov4" type="text" value="<?php $aux_dslinha3[8]?> - <?php $aux_dslinha3[9]?>" />
													<?php }?>
													<?php if(isset($aux_dslinha3[10])){?>
														<label style="width: auto; text-align:right; width: 170px;" for="preaprov5">Prepostos Aprovarores#5:</label>
														<input style="width: 380px" name="preaprov" id="preaprov5" type="text" value="<?php $aux_dslinha3[10]?> - <?php $aux_dslinha3[11]?>" />
													<?php }?>
													<?php if(isset($aux_dslinha3[12])){?>
														<label style="width: auto; text-align:right; width: 170px;" for="preaprov<6">Prepostos Aprovarores#6:</label>
														<input style="width: 380px" name="preaprov" id="preaprov6" type="text" value="<?php $aux_dslinha3[12]?> - <?php $aux_dslinha3[13]?>" />
													<?php }?>
													<?php if(isset($aux_dslinha3[14])){?>
														<label style="width: auto; text-align:right; width: 170px;" for="preaprov7">Prepostos Aprovarores#7:</label>
														<input style="width: 380px" name="preaprov" id="preaprov7" type="text" value="<?php $aux_dslinha3[14]?> - <?php $aux_dslinha3[15]?>" />
													<?php }?>
													<?php if(isset($aux_dslinha3[16])){?>
														<label style="width: auto; text-align:right; width: 170px;" for="preaprov8">Prepostos Aprovarores#8:</label>
														<input style="width: 380px" name="preaprov" id="preaprov8" type="text" value="<?php $aux_dslinha3[16]?> - <?php $aux_dslinha3[17]?>" />
													<?php }?>
													<?php if(isset($aux_dslinha3[18])){?>
														<label style="width: auto; text-align:right; width: 170px;" for="preaprov9">Prepostos Aprovarores#9:</label>
														<input style="width: 380px" name="preaprov" id="preaprov9" type="text" value="<?php $aux_dslinha3[18]?> - <?php $aux_dslinha3[19]?>" />
													<?php }?>
													<?php if(isset($aux_dslinha3[20])){?>
														<label style="width: auto; text-align:right; width: 170px;" for="preaprov10">Prepostos Aprovarores#10:</label>
														<input style="width: 380px" name="preaprov" id="preaprov10" type="text" value="<?php $aux_dslinha3[20]?> - <?php $aux_dslinha3[21]?>" />
													<?php }?>
												<?php }?>
                                                <label for="dsprotoc">Protocolo:</label>
                                                <input name="dsprotoc" id="dsprotoc" type="text" value="<?php echo $dsprotoc ?>" />
                                                <!-- Pj470 - SM2 -- Mateus Zimmermann -- Mouts -->
                                                <?php if ($cdtippro >= 25 && $cdtippro <= 31) { ?>

                                                    <label for="dsativo"><?php echo utf8ToHtml('Situação:') ?></label>
                                                    <input name="dsativo" id="dsativo" type="text" value="<?php echo $dsativo ?>" />

                                                <?php } ?>
                                                <!-- Fim Pj470 - SM2 -->

                                                <?php if ($cdtippro >= 25 && $cdtippro <= 31) { // PRJ 470 ?>

                                                    <label for="dsfrase"><?php echo utf8ToHtml('Frase:') ?></label>
                                                    <!-- bruno - prj 470 - verpro -->
                                                    <textarea name="dsfrase" id="dsfrase"><?php echo $dsfrase; ?></textarea>

                                                <?php } ?>

                                            </fieldset>		

                                        </form>
                                        <div id="divBotoes" style="margin-bottom:10px">
                                            <a href="#" class="botao" id="btVoltar" onClick="fechaRotina($('#divRotina'));
                                                    $('#divRotina').html('');
                                                    return false;">Voltar</a>
                                            <a href="#" class="botao" id="btSalvar" onclick="Gera_Impressao();
                                                    return false;">Imprimir</a>
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