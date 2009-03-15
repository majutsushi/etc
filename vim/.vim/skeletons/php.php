<tskel:before>
let b:tskelLang = input("Language: ", "")
</tskel:before>
<tskel:after>
unlet b:tskelLang
</tskel:after>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html lang="<+b:tskelLang+>">
<head>
    <title><+TITLE+></title>
    <meta http-equiv="content-type" content="text/html; charset=iso-8859-1">
    <meta name="author"   content="<+AUTHOR+>">
    <meta name="language" content="<+b:tskelLang+>">
    <meta name="date"     content="<+DATE+>">
    <link rel="stylesheet" type="text/css" href="<+CSS+>.css">
</head>
<body>

<?php
/*      
<+FILE NAME+><+NOTE+>
@Author:      <+AUTHOR+> (<+EMAIL+>)
@License:     <+LICENSE+>
@Created:     <+DATE+>.
@Last Change: 10-Mär-2005.
@Revision:    0.0
Description:
Usage:
TODO:
CHANGES:
*/

<+CURSOR+>

?>

</body>
</html>

