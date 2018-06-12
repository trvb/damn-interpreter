%{
    #include "rule.tab.h"
%}

PLUS PLUS
SUBS SUBS
MULT MULT
DIVX DIVX

COPY COPY
READ READ
SAVE SAVE
MOVE MOVE
JUMP JUMP
JCVD JCVD

EQUL EQUL
DIFF DIFF
INFR INFR
INFE INFE
SUPR SUPR
SUPE SUPE

SHOW SHOW

INT [0-9]+
CHAR \'.\'
REG R[0-4]
IDSEP \,
%%

{PLUS} return tPLUS;
{SUBS} return tSUBS;
{MULT} return tMULT;
{DIVX} return tDIVX;
{COPY} return tCOPY;
{READ} return tREAD;
{SAVE} return tSAVE;
{MOVE} return tMOVE;
{JUMP} return tJUMP;
{JCVD} return tJCVD;
{EQUL} return tEQUL;
{DIFF} return tDIFF;
{INFR} return tINFR;
{INFE} return tINFE;
{SUPR} return tSUPR;
{SUPE} return tSUPE;
{SHOW} return tSHOW;
{IDSEP} return tIDSEP;
{REG} {
    yylval.integer = atoi(&yytext[1]);
    return tREG;
}
{CHAR} {
    yylval.character = yytext[1];
    return tCHAR;
}
{INT} {
    yylval.integer = atoi(yytext);
    return tINT;
}

%%