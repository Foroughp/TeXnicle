%% Generated by lilypond-book
%% Options: [indent=0\mm,line-width=410\pt]
\include "lilypond-book-preamble.ly"


% ****************************************************************
% Start cut-&-pastable-section
% ****************************************************************



\paper {
  indent = 0\mm
  line-width = 410\pt
  force-assignment = #""
  line-width = #(- line-width (* mm  3.000000))
}

\layout {
  
}





% ****************************************************************
% ly snippet:
% ****************************************************************
\sourcefileline 0
\version "2.12.0"  % necessary for upgrading to future LilyPond versions.
\paper{
  %top-margin = 3\cm
  %bottom-margin = 3\cm
  %after-title-space = 2\cm
  left-margin = 0\cm
  %indent = #0
  %line-width = 18\cm
  ragged-right = ##f
myStaffSize = #20
#(define fonts 
(make-pango-font-tree "Times New Roman" 
"Nimbus Sans" 
"Luxi Mono" 
(/ myStaffSize 20)))
}
chExceptionMusic = {
  <c ees ges bes>1-\markup { \concat { "m" \super {"7(" \flat "5)"}} } %m7b5 wird nicht als halbvermindert notiert
  <c ees g b>1-\markup { \concat { "m" \super “maj7“ }}
  <c e g b d'>1-\markup { \super "maj9" }
  <c e g a d'>1-\markup { \super "6/9" }
  <c e g bes d' a'>1-\markup { \super "13" }
  <c e g b fis'>1-\markup { \super {"maj7(" \sharp "11)"} }
  <c e g b d' a'>1-\markup { \super "maj13" }
  <c e g b d' fis' a'>1-\markup { \super {"maj13(" \sharp "11)"} }
  <c e g bes d' aes'>1-\markup { \super {"9(" \flat "13)"}}
}
chExceptions = #(append
    (sequential-music-to-chord-exceptions chExceptionMusic #t)
    ignatzekExceptions)
    
\layout {
 \context {
    \Staff
     \remove "Time_signature_engraver"
           }
 \context {
    \Score
     \remove "Bar_number_engraver"
          }
}
<<

\relative c{

\chordmode { 

  a,1:maj13.3- \bar " "
  b,:m13^9 \bar " "
  c:maj13.11+.5+ \bar " "
  d:13.11+ \bar " "
  e:9.13-^11 \bar " "
  fis:m11.5- \bar " "
  gis:m7.5- \bar " "
}
%\break
%\context ChordNames { 
%	\set chordNameExceptions = #chExceptions
%	\set chordChanges = ##t % Akkordsymbole werden nur am Anfang einer Zeile und bei Akkordwechseln angezeigt
%	\set majorSevenSymbol = \markup { maj7 }
%	\chordmode {
%		c1:maj13 d:m11 e:m11^9 f:maj13.11+ g:13 a:m11 b:dim5.7
%		}
%	}
}
>>



% ****************************************************************
% end ly snippet
% ****************************************************************
