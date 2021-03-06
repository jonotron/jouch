/* description: parses couchdb 2.0 querys and constructs query objects */

/* lexical grammar */
%lex

%%
\s+                                 /* skip whitespace */
\"(\\.|[^"])*\"                     yytext = yytext.substr(1, yyleng-2); return 'STRING';
\'(\\.|[^'])*\'                     yytext = yytext.substr(1, yyleng-2); return 'STRING';
"("                                 return '(';
")"                                 return ')';
"["                                 return '[';
"]"                                 return ']';
","                                 return ',';
"=="                                return '==';
"!="                                return '!=';
">="                                return '>=';
"<="                                return '<=';
">"                                 return '>';
"<"                                 return '<';
and[^\w]                            return 'and';
or[^\w]                             return 'or';
not[^\w]                            return 'not';
has[^\w]                            return 'has';
[0-9]+(?:\.[0-9]+)?\b               return 'NUMBER';
[a-zA-Z][\.a-zA-Z0-9_]*             return 'SYMBOL';
<<EOF>>                             return 'EOF';

/lex

/* operator associations and precedence */

%left 'or'
%left 'and'
%left 'not'
%left '==' '!=' 'has'
%left '<' '<=' '>' '>='
%left UMINUS

%start expressions

%% /* language grammar */

expressions
  : e EOF
    {return JSON.stringify($1);}
  ;

e
  : 'not' e
    {$$ = {'%not': $2}; }
  | e 'and' e
    {$$ = {'%and': [$1, $3]};}
  | e 'or' e
    {$$ = {'%or': [$1, $3]};}
  | property 'has' value
    {$$ = {}; $$[$1] = {'$elemMatch': {'$eq': $3}}; }
  | property '==' value
    {$$ = {}; $$[$1] = {'$eq': $3};}
  | property '!=' value
    {$$ = {}; $$[$1] = {'$neq': $3};}
  | property '>=' value
    {$$ = {}; $$[$1] = {'$gte': $3};}
  | property '<=' value
    {$$ = {}; $$[$1] = {'$lte': $3};}
  | property '>' value
    {$$ = {}; $$[$1] = {'$gt': $3};}
  | property '<' value
    {$$ = {}; $$[$1] = {'$lt': $3};}
  | '(' e ')'
    {$$ = $2;}
  ;


property
  : SYMBOL
    {$$ = $1;}
  ;

value
  : NUMBER
    {$$ = Number(yytext);}
  | STRING
    {$$ = yytext; }
  | '[' ElemList ']'
    {$$ = $2; }
  ;

ElemList
  : ElemList ',' value
    {$$ = $1; $$.push($3); }
  | value
    {$$ = [$1]; }
  ;
