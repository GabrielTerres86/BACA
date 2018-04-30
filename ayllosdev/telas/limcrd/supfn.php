<?php
function build_select($id, $values, $cssClass, $radio){
	//echo "<select id=\"$id\" class='campoTelaSemBorda'>";
    $type = $radio ? "radio": "checkbox";
	foreach($values as $opt){
        echo "<input  type=\"".$type."\"  id=\"$id\" name=\"$id\" class=\"$id frmck\" value=\"$opt[1]\">".$opt[0]." ";
		//echo "<option value=\"$opt[1]\"> $opt[0] </option>";
	}
//	echo "</select>";
}


function build_card_adm_select($idSelect, $glbvars){

	$xml = "<Root>
                <Cabecalho>
                    <Bo>b1wgen0182.p</Bo>
                    <Proc>consulta-administradora</Proc>
                </Cabecalho>
                <Dados>
                    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>
                    <cdagenci>0</cdagenci>
                    <nrdcaixa>0</nrdcaixa>
                    <cdoperad>1</cdoperad>
                    <idorigem>5</idorigem>
                    <nmdatela>ADMCRD</nmdatela>
                    <cdadmcrd></cdadmcrd>
                    <nmadmcrd></nmadmcrd>
                    <nriniseq>1</nriniseq>
                    <nrregist>20</nrregist>
                </Dados>
            </Root>";
    $xmlResult = getDataXML($xml,false);
	$objList   =  simplexml_load_string($xmlResult);
	$qtdregis = $objList->crapadc['qtregist'];
	echo"<select class=\"campo\"  id=\"$idSelect\" style=\" width: 155px;\">";
	for($iterator = 0; $iterator < $qtdregis; $iterator++){
		$iObj = $objList->crapadc->Registro[$iterator];
		echo "<option value='". $iObj->cdadmcrd."'> ". utf8ToHtml($iObj->nmadmcrd)." </option>";
		
	}
	echo "</select>";

}



?>

