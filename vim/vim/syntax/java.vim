" Author: Jan Larres <jan@majutsushi.net>

" syntax keyword javaType boolean char byte short int long float double Thread System Integer String Double Byte Float Long Boolean Char Short

" syntax match javaOperator "[-+&|<>=!\/~.,;:*%&^?()\[\]]"
syntax match javaOperator "[-+&|<>=!\/~,;:*%&^?()\[\]]"
syntax match javaFunction '\(new\)\@3<![ \.]\zs\w\+\ze(' containedin=ALLBUT,javaLineComment,javaComment,javaString

highlight link javaOperator Operator
highlight link javaFunction Function
