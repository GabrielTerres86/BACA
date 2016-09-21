/* .............................................................................

   Programa: fontes/fcompile.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
............................................................................. */
/*-------------------------------------------------------------*/
/* fcompile.p (v1.0) - a program to compile PROGRESS programs. */
/*                                                             */
/* A utility designed specifically for Fall '88 CUBE.          */
/*-------------------------------------------------------------*/

/* "file" is an array holding the filenames to be compile */
DEFINE VARIABLE file AS CHARACTER EXTENT 60 FORMAT "x(25)".

/* "loop" is used as a counter in loops */
DEFINE VARIABLE loop AS INTEGER.

/*-------------------------------------------------------------*/
/* The following code reads in a list of all files of the form
   *.p from the current directory.  It performs equally well on
   DOS, OS2, UNIX, VMS and BTOS/CTOS.  Note that we could have
   used the CTOS verb instead of the BTOS verb; they are
   equivalent and either will work properly under the other (i.e.
   the BTOS command works on CTOS systems and the CTOS command
   works on BTOS systems).                                     */

IF OPSYS = "BTOS" THEN
  BTOS SILENT "[Sys]<Sys>Files.run"
  Files
  /* [File list]*           */ *.p
  /* [Details?]             */ No
  /* [Print file]           */ fcompile.fls
  /* [Suppress sort?]       */ No
  /* [Max. Columns]         */ 1
  /* [Sort by suffix?]      */
  /* [Suppress error msgs?] */ .

ELSE IF OPSYS = "MSDOS" THEN DOS  SILENT DIR *.p >fcompile.fls.

ELSE IF OPSYS = "OS2"   THEN OS2  SILENT DIR *.p >fcompile.fls.

ELSE IF OPSYS = "UNIX"  THEN UNIX SILENT ls fontes/*.p >fcompile.fls.

ELSE IF OPSYS = "VMS"   THEN VMS  SILENT
  dir/brief/notr/nosize/nodate/nohead/out=fcompile.fls *.p.

ELSE MESSAGE "Unknown OPSYS -" OPSYS.
/*-------------------------------------------------------------*/


/*-------------------------------------------------------------*/
/* Read in the list of files from fcompile.fls into the file
   array.  REPEAT will automatically exit when the end-of-file
   is reached.  The variable "loop" serves as a counter so that
   we know exactly how many of the records were read in.       */

INPUT FROM fcompile.fls NO-ECHO.
REPEAT loop = 1 TO 60:
  SET file[loop].
END.
INPUT CLOSE.
/*-------------------------------------------------------------*/

/*-------------------------------------------------------------*/
/* Now display the array of filenames (suppressing the default
   field labels PROGRESS normally associates with each variable)
   and position the cursor after the last name (so that the user
   may extend or alter the list of filenames).  Then SET the
   user's input into the displayed array.  Note that the entire
   array will be treated as a unit if the subscript is omitted
   (e.g. "file" vs "file[1], file[2], ..., file[60]".          */

DISPLAY file WITH NO-LABELS NO-BOX.
NEXT-PROMPT file[loop].
SET file.
/*-------------------------------------------------------------*/

/*-------------------------------------------------------------*/
/* Now, we loop through each of the filenames.  If the name is
   not blank, then we change the color of that field to the
   "MESSAGES" attribute (which by default is reverse-video) to
   indicate that this is the file we are working on.
   If the errors occur during compile, PROGRESS will display
   these and automatically pause when the message area is full.
   At the end of the compile we instruct PROGRESS to clear out
   the message area, so that errors from the previous compile to
   not show up when compiling the next file.  HIDE MESSAGE will
   also automatically pause if there are unread messages left on
   the screen.
   After the compile is finished, we change the color to "INPUT"
   (underscoring) to denote completion of the compile.         */

DO loop = 1 TO 60:
  IF file[loop] = "" THEN NEXT.
  COLOR DISPLAY MESSAGES file[loop].
  COMPILE VALUE(file[loop]) SAVE.
  HIDE MESSAGE.
  COLOR DISPLAY INPUT file[loop].
END.
/*-------------------------------------------------------------*/

/*-------------------------------------------------------------*/
/* When finished, delete the fcompile.fls file using the
   appropriate operating system command (or, for better
   performance under BTOS/CTOS, we can use one of the built-in
   OS-commands to avoid having to load the Executive).         */

IF      OPSYS = "BTOS"  THEN BTOS SILENT OS-DELETE fcompile.fls.
ELSE IF OPSYS = "MSDOS" THEN DOS  SILENT del       fcompile.fls.
ELSE IF OPSYS = "OS2"   THEN OS2  SILENT del       fcompile.fls.
ELSE IF OPSYS = "UNIX"  THEN UNIX SILENT rm        fcompile.fls.
ELSE IF OPSYS = "VMS"   THEN VMS  SILENT delete    fcompile.fls;.
ELSE MESSAGE "Unknown OPSYS -" OPSYS.
/*-------------------------------------------------------------*/


/*-------------------------------------------------------------*/
/* PROGRESS Keywords Used:

1.  AS           11. ELSE       21. MESSAGES       31. SET
2.  BTOS         12. END        22. NEXT           32. SILENT
3.  CHARACTER    13. EXTENT     23. NEXT-PROMPT    33. THEN
4.  CLOSE        14. FORMAT     24. NO-ECHO        34. TO
5.  COLOR        15. FROM       25. NO-LABELS      35. UNIX
6.  COMPILE      16. HIDE       26. OPSYS          36. VALUE
7.  DEFINE       17. IF         27. OS-DELETE      37. VARIABLE
8.  DISPLAY      18. INPUT      28. OS2            38. VMS
9.  DO           19. INTEGER    29. REPEAT         39. WITH
10. DOS          20. MESSAGE    30. SAVE                       */
/*-------------------------------------------------------------*/
