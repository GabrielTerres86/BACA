// Verificar se a resolução vídeo for > 800 X 600
if(screen.width > 800)
{
//	document.write ('<div id=floater style="position:absolute; left:785px; top:10px">')
//	document.write ('<form name="frm"><table border="0" cellpadding="0" cellspacing="0"><tr><td>CABECALHO</td></tr>')
//	document.write ('</table></form>')
//	document.write ('</div>');
}


// para que o cabeçalho flutue

    self.onError=null;
    currentX = currentY = 0;  
    whichIt = null;           
    lastScrollX = 0; lastScrollY = 1;
    NS = (document.layers) ? 1 : 0;
    IE = (document.all) ? 1: 0;

    function heartBeat() {

    if(screen.width < 800)
        {
            return false;
        }	

        if(IE) { diffY = document.body.scrollTop; diffX = document.body.scrollLeft; }
        if(NS) { diffY = self.pageYOffset; diffX = self.pageXOffset; }
        if(diffY != lastScrollY) {
                    percent = .1 * (diffY - lastScrollY);
                    if(percent > 0) percent = Math.ceil(percent);
                    else percent = Math.floor(percent);
                                   if(IE) document.all.floater.style.pixelTop += percent;
                                   if(NS) document.floater.top += percent; 
                    lastScrollY = lastScrollY + percent;
        }
           if(diffX != lastScrollX) {
                    percent = .1 * (diffX - lastScrollX);
                    if(percent > 0) percent = Math.ceil(percent);
                    else percent = Math.floor(percent);
                    if(IE) document.all.floater.style.pixelLeft += percent;
                    if(NS) document.floater.left += percent;
                    lastScrollX = lastScrollX + percent;
            }       
    }



    function checkFocus(x,y) { 

            stalkerx = document.floater.pageX;
            stalkery = document.floater.pageY;
            stalkerwidth = document.floater.clip.width;
            stalkerheight = document.floater.clip.height;
            if( (x > stalkerx && x < (stalkerx+stalkerwidth)) && (y > stalkery && y < (stalkery+stalkerheight))) return true;
            else return false;
    }

    function grabIt(e) {

            if(IE) {
                    whichIt = event.srcElement;
                    while (whichIt.id.indexOf("floater") == -1) {
                            whichIt = whichIt.parentElement;
                            if (whichIt == null) { return true; }
                }
                    whichIt.style.pixelLeft = whichIt.offsetLeft;
                whichIt.style.pixelTop = whichIt.offsetTop;
                    currentX = (event.clientX + document.body.scrollLeft);
                    currentY = (event.clientY + document.body.scrollTop);   
            } else { 
            window.captureEvents(Event.MOUSEMOVE);
            if(checkFocus (e.pageX,e.pageY)) { 
                    whichIt = document.floater;
                    StalkerTouchedX = e.pageX-document.floater.pageX;
                    StalkerTouchedY = e.pageY-document.floater.pageY;
            } 
            }
        return true;
    }
    
    function dropIt() {
            whichIt = null;
        if(NS) window.releaseEvents (Event.MOUSEMOVE);
        return true;
    }

    
    if(NS) {
            window.captureEvents(Event.MOUSEUP|Event.MOUSEDOWN);
            window.onmousedown = grabIt;
            window.onmouseup = dropIt;
    }
    if(IE) {
            document.onmousedown = grabIt;
            document.onmouseup = dropIt;
    }
      
    if(NS || IE) action = window.setInterval("heartBeat()",1);


