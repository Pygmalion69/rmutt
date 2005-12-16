%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

#include "global.h"
#include "list.h"
#include "dict.h"
#include "grambit.h"
#include "grammar.h"
#include "gstr.h"

  extern GRAMMAR *grammar;
  extern char *topRule;

  extern int includeStackPtr;

  char *curPack = NULL;

  %}

%union {
  struct _grambit *grambit;
  struct _dict_node *dict;
  char *str;
  struct _list *list;
  int integer;
  struct {
    char *rx;
    char *rep;
  } rx;
}

%token PACKAGE
%token USE
%token <str> LABEL
%token <str> LITERAL
%token <integer> INTEGER
%token <rx> RXSUB
%type <str> Label
%type <str> PackagedLabel
%type <str> Namespace
%type <list> Choice
%type <list> Choices
%type <list> Terms
%type <grambit> Term
%type <grambit> QualifiedTerm
%type <grambit> Rule
%type <grambit> Statement
%type <dict> Grammar

%start Top

%pure-parser

%expect 5

%%

Top:
  Grammar {
    grammar = $1;
  };

Grammar:
  Statement ';' {
     GRAMMAR *gram = grammar_new();
     if($1) {
	  grammar_add(gram,$1);
     }
     $$=gram;
  }
  | Grammar Statement ';' {
    if($2) {
	 grammar_add($1,$2);
    }
    $$=$1;
  }
  ;

Statement:
  Rule {
       $$=$1;
       if(!topRule && includeStackPtr == 0) {
	    topRule = rule_getLabel($1);
       }
  }
  | PACKAGE Label {
#ifdef DEBUG
       printf("setting package to %s\n", $2);
#endif
       if(curPack) free(curPack);
       curPack = strdup($2);
       free($2);
       $$=NULL;
  }
  ;

Rule: 
   PackagedLabel ':' Choices {
     GRAMBIT *nr;

     nr = rule_new($1, $3);
     free($1);

     $$=nr;
   }
   | PackagedLabel '=' Choices { 
     GRAMBIT *na;

     na = assignment_new($1, $3);
     free($1);

     $$=na;
   }
;

Choices:
   Choice {
	LIST *choices=list_new();

	list_add(choices,$1);
	$$=choices;
   }
   | Choice '&' INTEGER {
	LIST *choices=list_new();
	{
	     int i;
	     for(i = 0; i < $3; i++) {
		  list_add(choices,$1);
	     }
	}
	$$=choices;
   }
   | Choices '|' Choice {
	list_add($1,$3);
	$$=$1;
   }
   | Choices '|' Choice '&' INTEGER {
	{
	     int i;
	     for(i = 0; i < $5; i++) {
		  list_add($1,$3);
	     }
	}
	$$=$1;
   }
   ;

Choice:
   Terms {
	$$=$1;
   }
   | {
	$$=list_new();
   }
   ;

Terms:
   QualifiedTerm {
	LIST *terms=list_new();
	list_add(terms,$1);
	$$=terms;
   }
   | Terms QualifiedTerm {
	list_add($1,$2);
	$$=$1;
   }
   | Terms ',' QualifiedTerm {
	list_add($1,$3);
	$$=$1;
   }
   ;

QualifiedTerm:
   Term {
	$$=$1;
   }
   | QualifiedTerm '{' INTEGER ',' INTEGER '}' {
	$$=$1;
	$1->min_x = $3;
	$1->max_x = $5;
   }
   | QualifiedTerm '{' INTEGER '}' {
        $$=$1;
	$1->min_x = $3;
	$1->max_x = $3;
   }
   | QualifiedTerm '*' {
        $$=$1;
	$1->min_x = 0;
	$1->max_x = 5;
   }
   | QualifiedTerm '+' {
        $$=$1;
	$1->min_x = 1;
	$1->max_x = 5;
   }
   | QualifiedTerm '?' {
        $$=$1;
	$1->min_x = 0;
	$1->max_x = 1;
   }
   | QualifiedTerm '>' Term {
	$$=trans_new($1,$3);
   }
   ;

Term:
   PackagedLabel { 
     $$=label_new($1);
     free($1);
   }
   | LITERAL {
     $$=literal_new($1);
     free($1);
   }
   | '[' Rule ']' {
     $$=$2;
   }
   | '(' Choices ')' {
     $$=choice_new($2);
   }
   | RXSUB {
     $$=rxsub_new($1.rx, $1.rep);
     free($1.rx);
     free($1.rep);
   }
   | LITERAL '%' QualifiedTerm {
     $$=mapping_new($1,$3);
     free($1);
   }
   ;

PackagedLabel:
   LABEL {
	if(curPack) {
	     char *dotLabel;
	     dotLabel = gstr_cat(".",$1);
	     $$ = gstr_cat(curPack,dotLabel);
	     free(dotLabel);
	     free($1);
	} else {
	     $$=$1;
	}
   }
   | Namespace LABEL {
#ifdef DEBUG
	printf("namespace = %s\n",$1);
#endif
	$$=gstr_catf($1,$2);
   }
   ;

Label:
   LABEL {
	$$=$1;
   }
   ;

Namespace:
   LABEL '.' {
	$$=gstr_cat($1,".");
	free($1);
   }
   | Namespace LABEL '.' {
        $$=gstr_catf($1,gstr_cat($2,"."));
	free($2);
   }
   ;
%%

int yyerror(char *s) {
  fprintf(stderr,"error on line %d: %s\n",g_lineNumber,s);
  return 0;
}
