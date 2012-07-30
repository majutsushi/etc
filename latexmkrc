$pdf_mode = 1;

$pdflatex = 'pdflatex --shell-escape %O %S';

# Custom dependency to convert tif to png
add_cus_dep('tif', 'png', 0, 'maketif2png');
    sub maketif2png {
        system("convert $_[0].tif $_[0].png");
    }

# vim: ft=perl
