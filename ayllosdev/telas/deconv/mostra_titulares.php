<?php
/*************************************************************************
	  Fonte: mostra_titulares.php                                               
	  Autor: Gabriel                                                  
	  Data : Junho/2011                       Última Alteração: 20/11/2012		   
	                                                                   
	  Objetivo  : Mostrar os titulares da conta para a DECONV.              
	                                                                 
	  Alterações: 20/11/2012 - Alterado width da linha nmextttl (Daniel).   										   			  
	                 
***************************************************************************/

$i = 0;
					 
?>



var strHTML = ''; 
	
strHTML  = '<form id="frmTitulares" name="frmTitulares" class="formulario condensado" height="600">';
strHTML += '   <table>';	
strHTML += '       <? foreach($titulares as $titular)  { $i++; ?> ';
strHTML += '        <? ($color == '#FFFFFF') ? $color='' : $color='#FFFFFF'; ?>';
strHTML += '        <tr id="titular<? echo $i; ?>" style="text-align:center; cursor:pointer; background-color: <? echo $color; ?> " onclick="SelecionaTit(<? echo $i; ?> , <? echo $qtTitulares; ?>)" >'; 	
strHTML += '          <td style= "width: 80; font-size:12px; text-align:right;" > <? echo formataNumericos("zz9",getByTagName($titular->tags,'idseqttl')); ?> </td> ';
strHTML += '          <td style= "width: 80; font-size:12px; text-align:right;" > <? echo formataContaDV(getByTagName($titular->tags,'nrdconta')); ?> </td>';
strHTML += '          <td style= "width: 340; font-size:12px;" > <? echo getByTagName($titular->tags,'nmextttl'); ?> </td> ';
strHTML += '       </tr>'; 
strHTML += '      <? } ?>';
strHTML += '   </table>';
strHTML += '</form>';
 
<?php

  echo '$("#divTitulares").html(strHTML);';	

?>	